module jaguar_cd_stream
(
	clk_sys,
	reset,
	bk_int,
	audbus_out,
	aud_ce,
	cd_stream_start,
	img_size,
	cd_hps_ack,
	sd_buff_addr,
	sd_buff_dout,
	sd_buff_wr,
	cd_hps_lba,
	cd_hps_req,
	jagcd_on_cart_bus,
	cd_session_count,
	cd_toc_addr,
	cd_toc_data,
	cd_toc_wr,
	cd_toc_done,
	cd_valid,
	audbus_busy,
	xwaitl,
	aud_rd_trig,
	lcnt,
	clcnt,
	stream_q
);

input         clk_sys;
input         reset;
input         bk_int;
input  [29:0] audbus_out;
input         aud_ce;
input         cd_stream_start;
input  [63:0] img_size;
input         cd_hps_ack;
input   [7:0] sd_buff_addr;
input  [15:0] sd_buff_dout;
input         sd_buff_wr;

output [31:0] cd_hps_lba;
output        cd_hps_req;
output        jagcd_on_cart_bus;
output  [7:0] cd_session_count;
output  [9:0] cd_toc_addr;
output [15:0] cd_toc_data;
output        cd_toc_wr;
output        cd_toc_done;
output        cd_valid;
output        audbus_busy;
output        xwaitl;
output        aud_rd_trig;
output        lcnt;
output        clcnt;
output [63:0] stream_q;

// This module owns the entire CD streaming path that used to live inside
// Jaguar.sv. It has three tightly related jobs:
//
// 1. Accept 16-bit sector data arriving from HPS and store it into the local
//    dual-port ring buffer while preserving the byte order expected by the
//    Jaguar CD path.
// 2. Prefetch the fixed CDI metadata block once per cd_stream_start, then parse
//    TOC data from stable registers so mount-time bookkeeping never pollutes
//    the live streaming cache.
// 3. Serve 64-bit words back to the Jaguar core using the same addressing,
//    freshness checks, and format-specific byte-lane ordering as the original
//    inlined implementation.
//
// The intent of this refactor is structural only: keep the established timing
// and state-machine behavior intact, but isolate the streaming/cache/parser code
// from the already crowded top-level module.
reg [31:0] cd_hps_lba;
reg        cd_hps_req;
reg        jagcd_on_cart_bus;
reg  [2:0] cd_toc_type;
reg [15:0] cd_toc_data;
reg        cd_toc_wr;
reg        cd_toc_done;

reg [29:0] old_audbus_out;
reg old_aud_ce;
reg        meta_active;

// xwaitl is the cart-side wait-state output when the CD stream is acting as the
// cartridge image. On a cache hit the read can complete immediately. On a miss,
// hold wait low until the requested 64-bit window becomes valid in the ring.
//
// Without a real wait, the BIOS can sample stale metadata/cache data instead of
// the boot sector and incorrectly fall back to the audio player.
wire aud_rd_trig = aud_ce && ((audbus_out != old_audbus_out) || (!old_aud_ce));
wire cd_rd_trig = cd_ce && ((cd_bus_out != old_audbus_out) || (!old_aud_ce));
wire stream_idle = (cd_state == CD_STATE_IDLE) || cd_stream_start;
wire img_rd_trig = stream_idle ? aud_rd_trig : cd_rd_trig;
wire img_ce = stream_idle ? aud_ce : cd_ce;
reg xwaitl_latch;
assign xwaitl = xwaitl_latch;
always @(posedge clk_sys)
if (reset) begin
	xwaitl_latch <= 1'b1; // De-assert on reset!
	old_audbus_out <= 30'h112233;
	old_aud_ce <= 1'b1;
end else begin
	old_audbus_out <= stream_idle ? audbus_out : cd_bus_out;
	old_aud_ce <= stream_idle ? aud_ce : cd_ce;


	if (!jagcd_on_cart_bus) begin
		xwaitl_latch <= 1'b1;
	end else if (img_rd_trig) begin
		xwaitl_latch <= cd_valid;
	end else if (!xwaitl_latch && cd_valid) begin
		xwaitl_latch <= 1'b1;
	end
end

localparam [5:0] CD_RING_DEPTH = 6'd32;
localparam [4:0] CD_STATE_IDLE              = 5'd0;
localparam [4:0] CD_STATE_META_PREFETCH     = 5'd1;
localparam [4:0] CD_STATE_CDI_TAIL_REQ      = 5'd3;
localparam [4:0] CD_STATE_CDI_TAIL_READ     = 5'd4;
localparam [4:0] CD_STATE_CDI_SESSIONS      = 5'd5;
localparam [4:0] CD_STATE_CDI_TRACKS        = 5'd6;
localparam [4:0] CD_STATE_CDI_FILENAME      = 5'd7;
localparam [4:0] CD_STATE_CDI_PREGAP_LEN    = 5'd8;
localparam [4:0] CD_STATE_CDI_START_TOTLEN  = 5'd9;
localparam [4:0] CD_STATE_CDI_PREP_START    = 5'd10;
localparam [4:0] CD_STATE_CDI_WRITE_START   = 5'd11;
localparam [4:0] CD_STATE_CDI_WRITE_OFFSET  = 5'd12;
localparam [4:0] CD_STATE_CDI_WRITE_LENGTH  = 5'd13;
localparam [4:0] CD_STATE_CDI_WRITE_PREGAP  = 5'd14;
localparam [4:0] CD_STATE_CDI_WRITE_SESSION = 5'd15;
localparam [4:0] CD_STATE_CDI_WRITE_END     = 5'd16;
localparam [4:0] CD_STATE_CDI_TRACK_DONE    = 5'd17;

localparam [4:0] CD_STATE_EMIT_START        = CD_STATE_CDI_WRITE_START;
localparam [4:0] CD_STATE_EMIT_OFFSET       = CD_STATE_CDI_WRITE_OFFSET;
localparam [4:0] CD_STATE_EMIT_LENGTH       = CD_STATE_CDI_WRITE_LENGTH;
localparam [4:0] CD_STATE_EMIT_PREGAP       = CD_STATE_CDI_WRITE_PREGAP;
localparam [4:0] CD_STATE_EMIT_SESSION      = CD_STATE_CDI_WRITE_SESSION;
localparam [4:0] CD_STATE_EMIT_END          = CD_STATE_CDI_WRITE_END;
localparam [4:0] CD_STATE_EMIT_TRACK_DONE   = CD_STATE_CDI_TRACK_DONE;

// The ring buffer stores sectors in 64-bit read granules because Butch consumes
// streamed CD data in that width. HPS still arrives as 16-bit words, so the
// four RAMs preserve the existing lane packing and let the parser and stream
// reader share the same storage.
wire [29:0] imgbus_out;
wire [29:0] ringbus_out = imgbus_out;
wire [10:0] cd_ring_rd_addr = {ringbus_out[13:9], ringbus_out[8:3]};
wire [10:0] cd_ring_wr_addr = {cd_hps_lba[4:0], sd_buff_addr[7:2]};

dpram #(11,16) cdram_inst0
(
	.clock(clk_sys),
	.address_a(cd_ring_rd_addr),
	.q_a({cdram_dout[55:48],cdram_dout[63:56]}),

	.address_b(cd_ring_wr_addr),
	.data_b(sd_buff_dout),
	.wren_b(bk_int & sd_buff_wr & cd_hps_ack & (sd_buff_addr[1:0] == 2'b00))
);

dpram #(11,16) cdram_inst1
(
	.clock(clk_sys),
	.address_a(cd_ring_rd_addr),
	.q_a({cdram_dout[39:32],cdram_dout[47:40]}),

	.address_b(cd_ring_wr_addr),
	.data_b(sd_buff_dout),
	.wren_b(bk_int & sd_buff_wr & cd_hps_ack & (sd_buff_addr[1:0] == 2'b01))
);

dpram #(11,16) cdram_inst2
(
	.clock(clk_sys),
	.address_a(cd_ring_rd_addr),
	.q_a({cdram_dout[23:16],cdram_dout[31:24]}),

	.address_b(cd_ring_wr_addr),
	.data_b(sd_buff_dout),
	.wren_b(bk_int & sd_buff_wr & cd_hps_ack & (sd_buff_addr[1:0] == 2'b10))
);

dpram #(11,16) cdram_inst3
(
	.clock(clk_sys),
	.address_a(cd_ring_rd_addr),
	.q_a({cdram_dout[7:0],cdram_dout[15:8]}),

	.address_b(cd_ring_wr_addr),
	.data_b(sd_buff_dout),
	.wren_b(bk_int & sd_buff_wr & cd_hps_ack & (sd_buff_addr[1:0] == 2'b11))
);

wire [63:0] cdram_dout;
wire audbus_busy = img_ce || img_rd_trig || load_state || meta_active;
reg load_state;
reg cd_ring_armed;
reg [20:0] cd_ring_base_lba;
reg [5:0] cd_ring_count;
reg cd_startup_prefetch_pending;
wire [20:0] cd_ring_end_lba = cd_ring_base_lba + {15'h0, cd_ring_count};
reg [31:0] load_cnt;
reg [31:0] max_load_cnt;
wire lcnt = max_load_cnt == load_cnt;
reg [31:0] cload_cnt;
reg [31:0] max_cload_cnt;
wire clcnt = max_cload_cnt == cload_cnt;
localparam [5:0] CD_STARTUP_PREFETCH_DEPTH = 6'd4;
wire [5:0] cd_ring_target_depth = stream_idle ? CD_RING_DEPTH : 6'd1;
reg [4:0] cd_state;
reg [29:0] cd_size;
reg [29:0] cd_bus_out;
reg cd_ce;
assign imgbus_out = stream_idle ? audbus_out : cd_bus_out;
reg [2:0] cd_cnt;
reg [31:0] cd_header;
reg [7:0] cd_sessions;
reg [7:0] cd_session;
wire [7:0] cd_session_count = (cd_sessions != 8'h00) ? cd_sessions : 8'h01;
reg [7:0] cd_tracks;
reg [7:0] cd_track;
wire [7:0] cd_data = cdram_dout[8*(7-cd_bus_out[2:0]) +:8];
reg [23:0] cd_pregap;
reg [29:4] cd_pregap_pos;
reg [31:0] cd_length;
reg [31:0] cd_startlba;
reg [31:0] cd_totlength;
reg [31:0] cd_start;
reg [31:0] cd_track_end;
reg [29:0] cd_file_offset;
reg        cd_emit_calc_offset;
reg [19:0] cd_add1; // max lba fits in 19bits
reg [23:0] cd_tomsf;
reg do_tomsf;
reg [6:0] cd_min;
reg [5:0] cd_sec;
wire [6:0] cd_frame = cd_tomsf[6:0];
wire [23:0] cd_msf = {1'b0, cd_min, 2'b0, cd_sec, 1'b0, cd_frame};
wire [23:0] min_to_frames = 24'd4500; // 60*75
wire [23:0] sec_to_frames = 24'd75; // 75
reg [7:0] cd_tmp;
reg [29:0] cd_bus_add;
reg cd_bus_size;
reg cd_bus_header;
reg old_msf;
reg old_ack = 1'b0;
reg old_reset = 1'b0;
reg djv2;
reg djv3;
wire [9:0] cd_toc_addr = {cd_track[6:0], cd_toc_type[2:0]};
wire [20:0] cd_file_lba = ringbus_out[29:9];
wire cd_lba_in_ring = (cd_ring_count != 6'd0) && (cd_file_lba >= cd_ring_base_lba) && (cd_file_lba < cd_ring_end_lba);
wire cd_lba_loading = load_state && (cd_hps_lba[20:0] == cd_file_lba);
wire [7:0] cd_line_last_word = {ringbus_out[8:3], 2'b11};
wire cd_fresh = !(cd_lba_loading && (cd_line_last_word >= sd_buff_addr[7:0]));
wire [20:0] cd_img_total_lba = cd_size[29:9] + {20'h0, |cd_size[8:0]};
wire cd_startup_prefetch_ready =
	!stream_idle ||
	!cd_startup_prefetch_pending ||
	(cd_lba_in_ring && ((cd_ring_count >= CD_STARTUP_PREFETCH_DEPTH) || (cd_ring_end_lba >= cd_img_total_lba)));
wire cd_valid = jagcd_on_cart_bus && cd_lba_in_ring && cd_fresh && cd_startup_prefetch_ready;

// This controller multiplexes two related state machines into one sequential
// process:
// - metadata parsing / TOC generation during mount and re-mount
// - cache fill / refill for streaming reads once Butch starts consuming data
always @(posedge clk_sys) begin
	reg [20:0] lba_delta;
	reg miss_request_now;

	miss_request_now = 1'b0;
	old_reset <= reset;

	if (reset && ~old_reset)
		cd_size[29:0] <= img_size[29:0]; // rising edge of reset is asserted when the HPS is signaling that image has been mounted and img_size is valid.

	if (cd_stream_start) begin
		jagcd_on_cart_bus <= 1'b1;
		cd_hps_req <= 1'b1;
		cd_state <= CD_STATE_META_PREFETCH;
		meta_active <= 1'b1;
	end else if (reset) begin
		jagcd_on_cart_bus <= 1'b0;
		cd_hps_req <= 0;
		cd_state <= CD_STATE_IDLE;
		meta_active <= 1'b0;
	end

	if (cd_stream_start || reset) begin
		load_state <= 1'b0;
		cd_ring_armed <= 1'b0;
		cd_ring_base_lba <= 21'h0;
		cd_ring_count <= 6'h0;
		cd_startup_prefetch_pending <= 1'b0;
		cd_hps_lba[31:0] <= 32'h0;
		load_cnt[31:0] <= 32'h0;
		max_load_cnt[31:0] <= 32'h0;
		cload_cnt[31:0] <= 32'h0;
		max_cload_cnt[31:0] <= 32'h0;
		cd_bus_out[29:0] <= 30'h0;
		cd_cnt <= 3'h0;
		cd_header <= 32'h0;
		cd_sessions <= 8'h1;
		cd_session <= 8'h0;
		cd_tracks <= 8'h0;
		cd_track <= 8'h1;
		cd_toc_type[2:0] <= 3'h0;
		cd_toc_data[15:0] <= 16'h0;
		cd_toc_wr <= 1'b0;
		cd_toc_done <= 1'b0;
		cd_pregap <= 24'h0;
		cd_pregap_pos <= 26'h0;
		cd_length <= 32'h0;
		cd_startlba <= 32'h0;
		cd_totlength <= 32'h0;
		cd_start <= 32'h0;
		cd_track_end <= 32'h0;
		cd_file_offset <= 30'h0;
		cd_emit_calc_offset <= 1'b0;
		cd_add1 <= 20'h0;
		cd_tomsf <= 24'h0;
		do_tomsf <= 1'b0;
		cd_min <= 7'h0;
		cd_sec <= 6'h0;
		cd_tmp <= 8'h0;
		old_msf <= 1'b0;
		djv2 <= 1'b0;
		djv3 <= 1'b0;
		old_ack <= 1'b0;
	end

	cd_ce <= 0;
	cd_toc_wr <= 0;
	cd_toc_done <= 0;
	old_msf <= do_tomsf;
	if (do_tomsf) begin
		if (!old_msf) begin
			cd_min <= 'h0;
			cd_sec <= 'h0;
		end else if (cd_tomsf >= min_to_frames) begin
			cd_tomsf <= cd_tomsf - min_to_frames;
			cd_min <= cd_min + 7'd1;
		end else if (cd_tomsf >= sec_to_frames) begin
			cd_tomsf <= cd_tomsf - sec_to_frames;
			cd_sec <= cd_sec + 6'd1;
		end else begin
			do_tomsf <= 0;
		end
	end
	if (!audbus_busy && !do_tomsf) begin
		// Parser byte-source conventions:
		// - cd_data is one byte selected from the 64-bit cache line by cd_bus_out[2:0].
		// - cd_cnt advances once per parser beat and is used as the byte index inside each state.
		// - cd_bus_out updates at the end of the cycle, so each state uses the same
		//   "prime then consume" access pattern.
		//
			// Format references used for field mapping:
			// - CDI container layout and traversal: CDIrip parser flow (session header,
			//   track blocks, tail footer).
		cd_cnt <= cd_cnt + 3'h1;
		cd_bus_header = 0;
		cd_bus_size = 0;
		cd_bus_add = 30'h0;

		if ((cd_state == CD_STATE_EMIT_START) ||
			(cd_state == CD_STATE_EMIT_OFFSET) ||
			(cd_state == CD_STATE_EMIT_LENGTH) ||
			(cd_state == CD_STATE_EMIT_PREGAP) ||
			(cd_state == CD_STATE_EMIT_SESSION) ||
			(cd_state == CD_STATE_EMIT_END) ||
			(cd_state == CD_STATE_EMIT_TRACK_DONE)) begin
			if (cd_state == CD_STATE_EMIT_START) begin
				cd_toc_type[2:0] <= 3'h0;
				cd_toc_data[15:0] <= cd_msf[23:8];
				cd_tmp[7:0] <= cd_msf[7:0];
				cd_toc_wr <= 1;
				cd_state <= CD_STATE_EMIT_OFFSET;
				cd_tomsf <= cd_totlength[23:0];
				do_tomsf <= 1;
				cd_cnt <= 3'h0;
			end else if (cd_state == CD_STATE_EMIT_OFFSET) begin
				if (cd_emit_calc_offset) begin
					if (cd_cnt[1:0] == 2'b00) begin
						cd_pregap_pos[29:4] <= {7'h0, cd_add1[18:0]};
					end else if (cd_cnt[1:0] == 2'b01) begin
						cd_pregap_pos[29:5] <= cd_pregap_pos[29:5] + {6'h0, cd_add1[18:0]};
					end else if (cd_cnt[1:0] == 2'b10) begin
						cd_pregap_pos[29:8] <= cd_pregap_pos[29:8] + {3'h0, cd_add1[18:0]};
					end else begin
						cd_pregap_pos[29:11] <= cd_pregap_pos[29:11] + {cd_add1[18:0]};
					end
				end else if (cd_cnt[1:0] == 2'b00) begin
					cd_pregap_pos[29:4] <= cd_file_offset[29:4];
				end
				if (cd_cnt[1:0] == 2'b11) begin
					cd_toc_type[2:0] <= 3'h1;
					cd_toc_data[15:8] <= cd_tmp[7:0];
					cd_toc_data[7:0] <= cd_msf[23:16];
					cd_toc_wr <= 1;
					cd_state <= CD_STATE_EMIT_LENGTH;
				end
			end else if (cd_state == CD_STATE_EMIT_LENGTH) begin
				cd_toc_type[2:0] <= 3'h2;
				cd_toc_data[15:0] <= cd_msf[15:0];
				cd_toc_wr <= 1;
				cd_state <= CD_STATE_EMIT_PREGAP;
				cd_tomsf <= cd_pregap;
				do_tomsf <= 1;
				cd_add1[18:0] <= cd_add1[18:0] + cd_pregap[18:0];
			end else if (cd_state == CD_STATE_EMIT_PREGAP) begin
				cd_toc_type[2:0] <= 3'h3;
				cd_toc_data[15:0] <= cd_msf[15:0];
				cd_toc_wr <= 1;
				cd_state <= CD_STATE_EMIT_SESSION;
				cd_add1[18:0] <= cd_add1[18:0] + cd_length[18:0];
				cd_cnt <= 3'h0;
			end else if (cd_state == CD_STATE_EMIT_SESSION) begin
				if (cd_cnt[0] == 1'b0) begin
					cd_toc_type[2:0] <= 3'h4;
					// Legacy Butch TOC ingest expects session index in bits [15:9].
					// Using [15:8] shifts the value and collapses session 1 to 0.
					cd_toc_data[15:9] <= cd_session[6:0];
					cd_toc_data[8] <= 1'b0;
					cd_toc_data[7:0] <= {2'b00, cd_pregap_pos[29:24]};
				end else begin
					cd_toc_type[2:0] <= 3'h5;
					cd_toc_data[15:0] <= {cd_pregap_pos[23:8]};
					cd_state <= CD_STATE_EMIT_END;
					cd_cnt <= 3'h0;
				end
				cd_toc_wr <= 1;
				cd_tomsf <= cd_track_end[23:0];
				do_tomsf <= 1;
			end else if (cd_state == CD_STATE_EMIT_END) begin
				if (cd_cnt[0] == 1'b0) begin
					cd_toc_type[2:0] <= 3'h6;
					cd_toc_data[15:8] <= {cd_pregap_pos[7:4], 4'h0};
					cd_toc_data[7:0] <= cd_msf[23:16];
				end else begin
					cd_toc_type[2:0] <= 3'h7;
					cd_toc_data[15:0] <= cd_msf[15:0];
					cd_state <= CD_STATE_EMIT_TRACK_DONE;
				end
				cd_toc_wr <= 1;
				end else if (cd_state == CD_STATE_EMIT_TRACK_DONE) begin
					cd_state <= CD_STATE_CDI_FILENAME;
					cd_cnt <= 3'h0;
					cd_track <= cd_track + 8'h1;
					cd_bus_add = 30'h1C;
					cd_ce <= 1;
					if (cd_track == cd_tracks) begin
						if ((cd_session + 8'h1) < cd_session_count) begin
							cd_session <= cd_session + 8'h1;
							cd_state <= CD_STATE_CDI_TRACKS;
							cd_bus_add = djv2 ? 30'hC : 30'hD;
						end else begin
							cd_state <= CD_STATE_IDLE;
							jagcd_on_cart_bus <= 1'b1;
							cd_toc_done <= 1'b1;
							cd_bus_add = 30'h0;
						end
					end
				end
			end else begin
			// CDI parser: footer lookup, session-header traversal, then per-track
			// canonical field decode before handing off to the shared emitter.
			if (cd_state == CD_STATE_CDI_TAIL_REQ) begin
				cd_bus_size = 1;
				cd_bus_add = 30'h8;
				cd_ce <= 1;
				cd_cnt <= 3'h0;
				cd_state <= CD_STATE_CDI_TAIL_READ;
			end else if (cd_state == CD_STATE_CDI_TAIL_READ) begin
				if (cd_cnt == 3'h0) begin
					if (cd_data == 8'h6) begin
						djv2 <= 1'b0;
						djv3 <= 1'b0;
					end else if (cd_data == 8'h5) begin
						djv2 <= 1'b0;
						djv3 <= 1'b1;
					end else if (cd_data == 8'h4) begin
						djv2 <= 1'b1;
						djv3 <= 1'b0;
					end else begin
						cd_state <= CD_STATE_IDLE;
						//jagcd_on_cart_bus <= 1'b0;
					end
				end
				if ((cd_cnt == 3'h1) || (cd_cnt == 3'h2)) begin
					if (cd_data != 8'h0) begin
						cd_state <= CD_STATE_IDLE;
						//jagcd_on_cart_bus <= 1'b0;
					end
				end
				if ((cd_cnt == 3'h3) && (cd_data != 8'h80)) begin
					cd_state <= CD_STATE_IDLE;
					//jagcd_on_cart_bus <= 1'b0;
				end
				if (cd_cnt[2] == 1'b1) begin
					cd_header[8*cd_cnt[1:0] +:8] <= cd_data;
				end
				cd_bus_add = 30'h1;
				cd_ce <= 1;
				if (cd_cnt == 3'h7) begin
					cd_state <= CD_STATE_CDI_SESSIONS;
					cd_bus_add = 30'h0;
				end
			end else if (cd_state == CD_STATE_CDI_SESSIONS) begin
				if (cd_cnt[0] == 1'b0) begin
					cd_bus_size = 1;
					cd_bus_header = djv2 || djv3;
					cd_bus_add = cd_header[29:0];
				end else begin
					cd_sessions <= cd_data;
					cd_state <= CD_STATE_CDI_TRACKS;
					cd_bus_add = 30'h2;
				end
				cd_ce <= 1;
				cd_session <= 8'h0;
				cd_track <= 8'h1;
				cd_tracks <= 8'h0;
				cd_add1 <= 'h0;
			end else if (cd_state == CD_STATE_CDI_TRACKS) begin
				cd_tracks <= cd_tracks + cd_data;
				if (cd_data == 8'h0) begin
					// Some CDI images advertise trailing empty sessions. Skip them
					// instead of falling through into phantom track-entry parsing.
					if ((cd_session + 8'h1) < cd_session_count) begin
						cd_session <= cd_session + 8'h1;
						cd_state <= CD_STATE_CDI_TRACKS;
						cd_bus_add = djv2 ? 30'hC : 30'hD;
						cd_ce <= 1;
					end else begin
						cd_state <= CD_STATE_IDLE;
						jagcd_on_cart_bus <= 1'b1;
						cd_toc_done <= 1'b1;
						cd_bus_add = 30'h0;
					end
				end else begin
					cd_state <= CD_STATE_CDI_FILENAME;
					cd_bus_add = 30'h1E;
					cd_ce <= 1;
					cd_cnt <= 3'h0;
				end
			end else if (cd_state == CD_STATE_CDI_FILENAME) begin
				if (cd_cnt[0] == 1'b0) begin
					cd_bus_add = cd_data;
				end else begin
					cd_bus_add = djv2 ? 30'h1A : 30'h22;
					cd_state <= CD_STATE_CDI_PREGAP_LEN;
					cd_ce <= 1;
					cd_cnt <= 3'h0;
				end
			end else if (cd_state == CD_STATE_CDI_PREGAP_LEN) begin
				if (cd_cnt[2] == 1'b0) begin
					cd_pregap[8*cd_cnt[1:0] +:8] <= cd_data;
				end else begin
					cd_length[8*cd_cnt[1:0] +:8] <= cd_data;
				end
				cd_bus_add = 30'h1;
				cd_ce <= 1;
				if (cd_cnt == 3'h7) begin
					cd_state <= CD_STATE_CDI_START_TOTLEN;
					cd_cnt <= 3'h0;
					cd_bus_add = 30'h17;
				end
			end else if (cd_state == CD_STATE_CDI_START_TOTLEN) begin
				if (cd_cnt[2] == 1'b0) begin
					cd_startlba[8*cd_cnt[1:0] +:8] <= cd_data;
				end else begin
					cd_totlength[8*cd_cnt[1:0] +:8] <= cd_data;
				end
				cd_bus_add = 30'h1;
				cd_ce <= 1;
				if (cd_cnt == 3'h7) begin
					cd_state <= CD_STATE_CDI_PREP_START;
					cd_cnt <= 3'h0;
					cd_bus_add = djv2 ? 30'h32 : 30'h89;
				end
				end else if (cd_state == CD_STATE_CDI_PREP_START) begin
					cd_state <= CD_STATE_EMIT_START;
					cd_emit_calc_offset <= 1'b1;
				cd_file_offset <= 30'h0;
				cd_start <= cd_startlba + cd_pregap;
					cd_track_end <= cd_startlba + cd_pregap + cd_length;
					cd_tomsf <= cd_startlba[23:0] + cd_pregap;
					do_tomsf <= 1;
				end
			end

			cd_bus_out[29:0] <= cd_bus_header ? cd_bus_add[29:0] :
			cd_bus_size ? (cd_size[29:0] - cd_bus_add[29:0]) :
			(cd_bus_out[29:0] + cd_bus_add[29:0]);
	end
//		3 lbatomsf(startlba+pregap)
//		3 lbatomsf(length)
//		2 0 (pregap)
//		1 session index (0-based)
//		4 troffset = position + pregap*2352
//		3 lbatomsf(sessend = startlba+pregap+length)
	old_ack  <= cd_hps_ack;

	if (~old_ack && cd_hps_ack) begin
		cd_hps_req <= 1'b0;
	end

	if (stream_idle && cd_startup_prefetch_pending &&
		cd_lba_in_ring &&
		((cd_ring_count >= CD_STARTUP_PREFETCH_DEPTH) || (cd_ring_end_lba >= cd_img_total_lba))) begin
		cd_startup_prefetch_pending <= 1'b0;
	end

		// The first metadata sector is always fetched outside the ring buffer so the
		// mount path can prime CDI parsing without perturbing stream cache state.
		if (meta_active && old_ack && ~cd_hps_ack) begin
			meta_active <= 1'b0;
			cd_state <= CD_STATE_CDI_TAIL_REQ;
			cd_cnt <= 3'h0;
			cd_bus_out <= 30'h0;
		end else if (load_state && old_ack && ~cd_hps_ack) begin
		load_state <= 1'b0;
		if ((cd_ring_count < CD_RING_DEPTH) && (cd_hps_lba[20:0] == cd_ring_end_lba)) begin
			cd_ring_count <= cd_ring_count + 6'd1;
		end
	end

		// Mounted playback always uses the ring. During mount, the CDI parser is the
		// only consumer that should trigger cache-miss servicing before TOC ingest
		// completes.
		if (img_rd_trig && (jagcd_on_cart_bus || !stream_idle)) begin
		load_cnt[31:0] <= 32'h0;
		cload_cnt[31:0] <= 32'h0;
		cd_ring_armed <= 1'b1;
		if (!cd_lba_in_ring) begin
			cd_ring_base_lba <= cd_file_lba;
			cd_ring_count <= 6'd0;
			if (stream_idle) begin
				// A real CD path normally resumes after some rotational/decoder
				// headroom exists, not after exposing only the first sector and
				// immediately chasing every following miss. Hold cart-bus reads
				// until a small contiguous read-ahead window has been rebuilt.
				cd_startup_prefetch_pending <= 1'b1;
			end
			if (!load_state) begin
				cd_hps_lba <= {11'h000, cd_file_lba};
				cd_hps_req <= 1'b1;
				load_state <= 1'b1;
				miss_request_now = 1'b1;
			end
		end else if (cd_file_lba != cd_ring_base_lba) begin
			lba_delta = cd_file_lba - cd_ring_base_lba;
			cd_ring_base_lba <= cd_file_lba;
			// Saturate window shrink on forward base moves to avoid modulo underflow
			// when the consumer jumps beyond current cache depth.
			if (lba_delta >= {15'h0000, cd_ring_count}) begin
				cd_ring_count <= 6'd0;
			end else begin
				cd_ring_count <= cd_ring_count - lba_delta[5:0];
			end
		end
	end

	if (cd_ring_armed && !cd_lba_in_ring) begin
		load_cnt <= load_cnt + 1'd1;
		if (load_cnt > max_load_cnt) begin
			max_load_cnt <= load_cnt;
		end
	end

	if (load_state || (cd_hps_req && !meta_active)) begin
		cload_cnt <= cload_cnt + 1'd1;
		if (cload_cnt > max_cload_cnt) begin
			max_cload_cnt <= cload_cnt;
		end
	end

	// if (jagcd_on_cart_bus && cd_ring_armed && !load_state && !miss_request_now && (cd_ring_count < cd_ring_target_depth)) begin
	if (jagcd_on_cart_bus &&
		cd_ring_armed &&
		!load_state &&
		!miss_request_now &&
		(cd_ring_count < cd_ring_target_depth) &&
		(cd_ring_end_lba < cd_img_total_lba)) begin
		cd_hps_lba <= {11'h000, cd_ring_end_lba};
		cd_hps_req <= 1'b1;
		load_state <= 1'b1;
	end

end

// Present cached data in the exact 64-bit lane order the top level previously
// exposed for CDI streaming.
wire [63:0] cdram_q_stream = {cdram_dout[31:00],cdram_dout[63:32]};
assign stream_q = cdram_q_stream;

endmodule
