module jaguar_cd_stream
(
	clk_sys,
	reset,
	bk_int,
	DDRAM_DOUT_READY,
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
	cd_img_mounted,
	cd_state_idle,
	cd_session_count,
	cd_toc_addr,
	cd_toc_data,
	cd_toc_wr,
	cd_valid,
	audbus_busy,
	xwaitl,
	aud_rd_trig,
	lcnt,
	clcnt,
	dbg_cd_fmt,
	dbg_cd_state,
	dbg_cd_track,
	dbg_cd_session,
	dbg_cd_desc_index,
	dbg_first_aud_addr0,
	dbg_first_aud_addr1,
	dbg_first_grant_seen,
	dbg_first_grant_addr,
	dbg_first_grant_file_addr,
	dbg_first_grant_word,
	dbg_cur_file_addr,
	stream_q,
	cd_boot
);

input         clk_sys;
input         reset;
input         bk_int;
input         DDRAM_DOUT_READY;
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
output        cd_img_mounted;
output        cd_state_idle;
output  [7:0] cd_session_count;
output  [9:0] cd_toc_addr;
output [15:0] cd_toc_data;
output        cd_toc_wr;
output        cd_valid;
output        audbus_busy;
output        xwaitl;
output        aud_rd_trig;
output        lcnt;
output        clcnt;
output  [1:0] dbg_cd_fmt;
output  [4:0] dbg_cd_state;
output  [7:0] dbg_cd_track;
output  [7:0] dbg_cd_session;
output  [7:0] dbg_cd_desc_index;
output [29:0] dbg_first_aud_addr0;
output [29:0] dbg_first_aud_addr1;
output        dbg_first_grant_seen;
output [29:0] dbg_first_grant_addr;
output [29:0] dbg_first_grant_file_addr;
output [63:0] dbg_first_grant_word;
output [29:0] dbg_cur_file_addr;
output [63:0] stream_q;
output        cd_boot;

// This module owns the entire CD streaming path that used to live inside
// Jaguar.sv. It has three tightly related jobs:
//
// 1. Accept 16-bit sector data arriving from HPS and store it into the local
//    dual-port ring buffer while preserving the byte order expected by the
//    Jaguar CD path.
// 2. Stage static image metadata once per cd_stream_start, then parse TOC data
//    from stable registers so mount-time bookkeeping never pollutes the live
//    streaming cache.
// 3. Serve 64-bit words back to the Jaguar core using the same addressing,
//    freshness checks, and format-specific byte-lane ordering as the original
//    inlined implementation.
//
// The intent of this refactor is structural only: keep the established timing
// and state-machine behavior intact, but isolate the streaming/cache/parser code
// from the already crowded top-level module.
reg [31:0] cd_hps_lba;
reg        cd_hps_req;
reg        cd_img_mounted;
reg  [2:0] cd_toc_type;
reg [15:0] cd_toc_data;
reg        cd_toc_wr;

reg [29:0] old_audbus_out;
reg old_aud_ce;
reg        meta_active;
reg        meta_is_jcd;
reg  [1:0] meta_sector;
reg [31:0] meta_magic;
reg  [1:0] dbg_first_aud_count;
reg [29:0] dbg_first_aud_addr0;
reg [29:0] dbg_first_aud_addr1;
reg        dbg_first_grant_seen;
reg [29:0] dbg_first_grant_addr;
reg [29:0] dbg_first_grant_file_addr;
reg [63:0] dbg_first_grant_word;

// xwaitl is the cart-side wait-state output when the CD stream is acting as the
// cartridge image. On a cache hit the read can complete immediately. On a miss,
// hold wait low until the requested 64-bit window becomes valid in the ring.
//
// This is especially important for JCD because the fixed metadata lives at the
// front of the file while the first data track can be far away. Without a real
// wait, the BIOS can sample stale metadata/cache data instead of the boot
// sector and incorrectly fall back to the audio player.
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


	if (!cd_img_mounted) begin
		xwaitl_latch <= 1'b1;
	end else if (img_rd_trig) begin
		xwaitl_latch <= cd_valid;
	end else if (!xwaitl_latch && cd_valid) begin
		xwaitl_latch <= 1'b1;
	end
end

localparam [5:0] CD_RING_DEPTH = 6'd32;
localparam [1:0] CD_FMT_UNKNOWN = 2'd0;
localparam [1:0] CD_FMT_CDI     = 2'd1;
localparam [1:0] CD_FMT_JCD     = 2'd2;
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
localparam [4:0] CD_STATE_JCD_HEADER        = 5'd18;
localparam [4:0] CD_STATE_JCD_DESC_HEAD     = 5'd19;
localparam [4:0] CD_STATE_JCD_DESC_TAIL     = 5'd20;
localparam [4:0] CD_STATE_JCD_PREP_START    = 5'd21;
localparam [4:0] CD_STATE_JCD_WRITE_START   = 5'd22;
localparam [4:0] CD_STATE_JCD_WRITE_OFFSET  = 5'd23;
localparam [4:0] CD_STATE_JCD_WRITE_LENGTH  = 5'd24;
localparam [4:0] CD_STATE_JCD_WRITE_PREGAP  = 5'd25;
localparam [4:0] CD_STATE_JCD_WRITE_SESSION = 5'd26;
localparam [4:0] CD_STATE_JCD_WRITE_END     = 5'd27;
localparam [4:0] CD_STATE_JCD_TRACK_DONE    = 5'd28;
localparam [29:0] JCD_PAYLOAD_BASE          = 30'h000600;
localparam [7:0] JCD_MAX_TRACKS             = 8'd120;

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
wire jcd_stream_read = stream_idle && cd_img_mounted && (cd_fmt == CD_FMT_JCD);
wire [29:0] ringbus_out = jcd_stream_read ? (imgbus_out + JCD_PAYLOAD_BASE) : imgbus_out;
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
wire [20:0] cd_ring_end_lba = cd_ring_base_lba + {15'h0, cd_ring_count};
reg [31:0] load_cnt;
reg [31:0] max_load_cnt;
wire lcnt = max_load_cnt == load_cnt;
reg [31:0] cload_cnt;
reg [31:0] max_cload_cnt;
wire clcnt = max_cload_cnt == cload_cnt;
wire [5:0] cd_ring_target_depth = stream_idle ? CD_RING_DEPTH : 6'd1;
reg [4:0] cd_state;
reg [29:0] cd_size;
reg [29:0] cd_bus_out;
reg cd_ce;
assign imgbus_out = stream_idle ? audbus_out : cd_bus_out;
reg [2:0] cd_cnt;
reg [31:0] cd_header;
reg [1:0] cd_fmt;
reg [7:0] cd_sessions;
reg [7:0] cd_session;
wire [7:0] cd_session_count = (cd_sessions != 8'h00) ? cd_sessions : 8'h01;
reg [7:0] cd_tracks;
reg [7:0] cd_track;
reg [7:0] cd_desc_index;
reg [7:0] cd_jcd_track_first;
reg [7:0] cd_jcd_track_last;
reg [7:0] cd_jcd_desc_count;
reg [7:0] cd_jcd_start_min;
reg [7:0] cd_jcd_start_sec;
reg [7:0] cd_jcd_start_frame;
reg [7:0] cd_jcd_len_min;
reg [7:0] cd_jcd_len_sec;
reg [7:0] cd_jcd_len_frame;
reg [7:0] cd_jcd_lba_hi;
reg [7:0] cd_jcd_lba_mid;
reg [31:0] cd_jcd_data_off;
reg [7:0] cd_jcd_leadout_min;
reg [7:0] cd_jcd_leadout_sec;
reg [7:0] cd_jcd_leadout_frame;
reg [7:0] cd_jcd_prev_session;
reg [23:0] cd_jcd_start_tab [0:119];
reg [23:0] cd_jcd_len_tab [0:119];
reg [29:0] cd_jcd_off_tab [0:119];
reg [7:0] cd_jcd_session_tab [0:119];
reg [7:0] cd_jcd_track_tab [0:119];
wire cd_jcd_last_desc = ((cd_desc_index + 8'h1) == cd_jcd_desc_count);
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
reg [3:0] cd_boot_sr;
reg cd_bus_size;
reg cd_bus_header;
reg old_msf;
reg djv2;
reg djv3;
wire [9:0] cd_toc_addr = {cd_track[6:0], cd_toc_type[2:0]};
function [23:0] msf_to_frames24;
	input [7:0] mins;
	input [7:0] secs;
	input [7:0] frms;
	reg [23:0] mins_frames;
	reg [23:0] secs_frames;
begin
	// mins * 4500 = mins * (4096 + 256 + 128 + 16 + 4)
	mins_frames = {mins,12'h000} + {mins,8'h00} + {mins,7'h00} + {mins,4'h0} + {mins,2'h0};
	// secs * 75 = secs * (64 + 8 + 2 + 1)
	secs_frames = {secs,6'h00} + {secs,3'h0} + {secs,1'b0} + {16'h0000,secs};
	msf_to_frames24 = mins_frames + secs_frames + {16'h0000,frms};
end
endfunction
wire [20:0] cd_file_lba = ringbus_out[29:9];
wire cd_lba_in_ring = (cd_ring_count != 6'd0) && (cd_file_lba >= cd_ring_base_lba) && (cd_file_lba < cd_ring_end_lba);
wire cd_lba_loading = load_state && (cd_hps_lba[20:0] == cd_file_lba);
wire [7:0] cd_line_last_word = {ringbus_out[8:3], 2'b11};
wire cd_fresh = !(cd_lba_loading && (cd_line_last_word >= sd_buff_addr[7:0]));
wire jcd_track_is_session_first = (cd_desc_index == 8'h00) || (cd_session != cd_jcd_prev_session);
wire jcd_track_is_disc_first = jcd_track_is_session_first && (cd_startlba == 32'h0000_0000);
wire [23:0] jcd_track_pregap = jcd_track_is_session_first ? 24'd150 : 24'd0;
wire [31:0] jcd_track_pregap_ext = {8'h00, jcd_track_pregap};
wire [23:0] jcd_track_start_shift = jcd_track_is_disc_first ? 24'd150 : 24'd0;
wire [31:0] jcd_track_start_shift_ext = {8'h00, jcd_track_start_shift};
wire cd_valid = cd_img_mounted && cd_lba_in_ring && cd_fresh;

assign cd_boot = |cd_boot_sr;

// This controller multiplexes two related state machines into one sequential
// process:
// - metadata parsing / TOC generation during mount and re-mount
// - cache fill / refill for streaming reads once Butch starts consuming data
always @(posedge clk_sys) begin
	reg old_ack;
	reg [20:0] lba_delta;
	reg miss_request_now;
	reg [31:0] jcd_cur_start_lba;
	reg [31:0] jcd_cur_len_lba;
	reg [29:0] jcd_cur_file_off;
	reg [7:0] jcd_cur_session;
	reg [7:0] jcd_cur_track;
	reg [31:0] jcd_src_start_lba;
	reg [31:0] jcd_prog_len_lba;
	reg [31:0] jcd_total_len_lba;
	reg jcd_emit_session_first;
	reg jcd_emit_disc_first;
	miss_request_now = 1'b0;
	jcd_cur_start_lba = 32'h0;
	jcd_cur_len_lba = 32'h0;
	jcd_cur_file_off = 30'h0;
	jcd_cur_session = 8'h0;
	jcd_cur_track = 8'h0;
	jcd_src_start_lba = 32'h0;
	jcd_prog_len_lba = 32'h0;
	jcd_total_len_lba = 32'h0;
	jcd_emit_session_first = 1'b0;
	jcd_emit_disc_first = 1'b0;

	cd_boot_sr <= {cd_boot_sr[2:0], 1'b0};

	if (reset) begin
		cd_boot_sr <= 4'd0;
		load_state <= 1'b0;
		cd_ring_armed <= 1'b0;
		cd_ring_base_lba <= 21'h0;
		cd_ring_count <= 6'h0;
		cd_img_mounted <= 1'b0;
		cd_hps_req <= 0;
		cd_hps_lba[31:0] <= 32'h0;
		load_cnt[31:0] <= 32'h0;
		max_load_cnt[31:0] <= 32'h0;
		cload_cnt[31:0] <= 32'h0;
		max_cload_cnt[31:0] <= 32'h0;
		cd_state <= CD_STATE_IDLE;
		cd_size[29:0] <= 30'h0;
		cd_fmt <= CD_FMT_UNKNOWN;
		cd_sessions <= 8'h1;
		cd_session <= 8'h0;
		cd_toc_type[2:0] <= 3'h0;
		cd_toc_data[15:0] <= 16'h0;
		cd_toc_wr <= 0;
		cd_desc_index <= 8'h0;
		cd_jcd_track_first <= 8'h1;
		cd_jcd_track_last <= 8'h1;
		cd_jcd_desc_count <= 8'h0;
		cd_jcd_start_min <= 8'h0;
		cd_jcd_start_sec <= 8'h0;
		cd_jcd_start_frame <= 8'h0;
		cd_jcd_len_min <= 8'h0;
		cd_jcd_len_sec <= 8'h0;
		cd_jcd_len_frame <= 8'h0;
		cd_jcd_lba_hi <= 8'h0;
		cd_jcd_lba_mid <= 8'h0;
		cd_jcd_data_off <= 32'h0;
		cd_jcd_leadout_min <= 8'h0;
		cd_jcd_leadout_sec <= 8'h0;
		cd_jcd_leadout_frame <= 8'h0;
		cd_jcd_prev_session <= 8'hFF;
		cd_track_end <= 32'h0;
		cd_file_offset <= 30'h0;
		cd_emit_calc_offset <= 1'b0;
		meta_active <= 1'b0;
		meta_is_jcd <= 1'b0;
		meta_sector <= 2'h0;
		meta_magic <= 32'h0;
		dbg_first_aud_count <= 2'h0;
		dbg_first_aud_addr0 <= 30'h0;
		dbg_first_aud_addr1 <= 30'h0;
		dbg_first_grant_seen <= 1'b0;
		dbg_first_grant_addr <= 30'h0;
		dbg_first_grant_file_addr <= 30'h0;
		dbg_first_grant_word <= 64'h0;
	end

	if (cd_stream_start) begin
		cd_boot_sr[0] <= 1'b1;
		cd_img_mounted <= 1'b1;
		cd_state <= CD_STATE_META_PREFETCH;
		cd_size[29:0] <= img_size[29:0];
		load_state <= 1'b0;
		cd_ring_armed <= 1'b0;
		cd_ring_base_lba <= 21'h0;
		cd_ring_count <= 6'h0;
		cd_hps_req <= 1'b1;
		cd_hps_lba[31:0] <= 32'h0;
		load_cnt[31:0] <= 32'h0;
		max_load_cnt[31:0] <= 32'h0;
		cload_cnt[31:0] <= 32'h0;
		max_cload_cnt[31:0] <= 32'h0;
		cd_bus_out[29:0] <= 30'h0;
		cd_cnt <= 3'h0;
		cd_header <= 32'h0;
		cd_fmt <= CD_FMT_UNKNOWN;
		cd_sessions <= 8'h1;
		cd_session <= 8'h0;
		cd_tracks <= 8'h0;
		cd_track <= 8'h1;
		cd_desc_index <= 8'h0;
		cd_jcd_track_first <= 8'h1;
		cd_jcd_track_last <= 8'h1;
		cd_jcd_desc_count <= 8'h0;
		cd_jcd_start_min <= 8'h0;
		cd_jcd_start_sec <= 8'h0;
		cd_jcd_start_frame <= 8'h0;
		cd_jcd_len_min <= 8'h0;
		cd_jcd_len_sec <= 8'h0;
		cd_jcd_len_frame <= 8'h0;
		cd_jcd_lba_hi <= 8'h0;
		cd_jcd_lba_mid <= 8'h0;
		cd_jcd_data_off <= 32'h0;
		cd_jcd_leadout_min <= 8'h0;
		cd_jcd_leadout_sec <= 8'h0;
		cd_jcd_leadout_frame <= 8'h0;
		cd_jcd_prev_session <= 8'hFF;
		cd_toc_type[2:0] <= 3'h0;
		cd_toc_data[15:0] <= 16'h0;
		cd_toc_wr <= 1'b0;
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
		meta_active <= 1'b1;
		meta_is_jcd <= 1'b0;
		meta_sector <= 2'h0;
		meta_magic <= 32'h0;
		dbg_first_aud_count <= 2'h0;
		dbg_first_aud_addr0 <= 30'h0;
		dbg_first_aud_addr1 <= 30'h0;
		dbg_first_grant_seen <= 1'b0;
		dbg_first_grant_addr <= 30'h0;
		dbg_first_grant_file_addr <= 30'h0;
		dbg_first_grant_word <= 64'h0;
	end

	// Mount-time metadata rides through the same ring RAM the stream path already
	// owns. To keep logic density under control, only the few fixed header bytes
	// that matter globally are latched here; JCD descriptors are read back from
	// the ring one byte at a time during the JCD parser walk.
	if (meta_active && cd_hps_ack && sd_buff_wr) begin
		if (meta_sector == 2'd0) begin
			case (sd_buff_addr)
				8'h00: begin
					meta_magic[7:0] <= sd_buff_dout[7:0];
					meta_magic[15:8] <= sd_buff_dout[15:8];
				end
				8'h01: begin
					meta_magic[23:16] <= sd_buff_dout[7:0];
					meta_magic[31:24] <= sd_buff_dout[15:8];
				end
				8'h03: begin
					cd_jcd_track_first <= (sd_buff_dout[7:0] != 8'h00) ? sd_buff_dout[7:0] : 8'h1;
					cd_jcd_track_last <= sd_buff_dout[15:8];
				end
				8'h04: begin
					cd_sessions <= (sd_buff_dout[7:0] != 8'h00) ? sd_buff_dout[7:0] : 8'h1;
					cd_jcd_leadout_min <= sd_buff_dout[15:8];
				end
				8'h05: begin
					cd_jcd_leadout_sec <= sd_buff_dout[7:0];
					cd_jcd_leadout_frame <= sd_buff_dout[15:8];
				end
				default: ;
			endcase
		end
	end

	cd_ce <= 0;
	cd_toc_wr <= 0;
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
		// - JCD layout: resources/JCD_FILE_SPEC.txt (header 0x00..0x0B, then 12-byte
		//   descriptors starting at 0x0C).
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
				if (cd_fmt == CD_FMT_CDI) begin
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
							cd_img_mounted <= 1'b1;
							cd_bus_add = 30'h0;
						end
					end
				end else begin
					cd_jcd_prev_session <= cd_session;
					if ((cd_desc_index + 8'h1) < cd_jcd_desc_count) begin
						cd_desc_index <= cd_desc_index + 8'h1;
						cd_state <= CD_STATE_JCD_PREP_START;
						cd_cnt <= 3'h0;
					end else begin
						cd_state <= CD_STATE_IDLE;
						cd_img_mounted <= 1'b1;
						cd_bus_add = 30'h0;
					end
				end
			end
		end else if (cd_fmt == CD_FMT_CDI) begin
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
						//cd_img_mounted <= 1'b0;
					end
				end
				if ((cd_cnt == 3'h1) || (cd_cnt == 3'h2)) begin
					if (cd_data != 8'h0) begin
						cd_state <= CD_STATE_IDLE;
						//cd_img_mounted <= 1'b0;
					end
				end
				if ((cd_cnt == 3'h3) && (cd_data != 8'h80)) begin
					cd_state <= CD_STATE_IDLE;
					//cd_img_mounted <= 1'b0;
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
				cd_state <= CD_STATE_CDI_FILENAME;
				cd_bus_add = 30'h1E;
				cd_ce <= 1;
				cd_cnt <= 3'h0;
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
		end else if (cd_fmt == CD_FMT_JCD) begin
			// JCD parser: fixed header fields were already latched during sector 0
			// capture. Each 12-byte descriptor fills the same canonical track fields
			// used by CDI, then hands off to the shared emitter.
			if (cd_state == CD_STATE_JCD_HEADER) begin
				if (cd_jcd_track_last == 8'h00) begin
					cd_state <= CD_STATE_IDLE;
					//cd_img_mounted <= 1'b0;
				end else begin
					if (cd_jcd_track_last >= cd_jcd_track_first) begin
						cd_jcd_desc_count <= (cd_jcd_track_last - cd_jcd_track_first) + 8'h1;
					end else begin
						cd_jcd_desc_count <= cd_jcd_track_last;
					end
					cd_state <= CD_STATE_JCD_DESC_HEAD;
					cd_cnt <= 3'h0;
					cd_desc_index <= 8'h0;
					cd_track <= cd_jcd_track_first;
					cd_session <= 8'h0;
					cd_add1 <= 20'h0;
					cd_bus_header = 1;
					cd_bus_add = 30'hC;
					cd_ce <= 1;
				end
			end else if (cd_state == CD_STATE_JCD_DESC_HEAD) begin
				case (cd_cnt)
					3'h0: cd_track <= cd_data;
					3'h1: cd_jcd_start_min <= cd_data;
					3'h2: cd_jcd_start_sec <= cd_data;
					3'h3: cd_jcd_start_frame <= cd_data;
					3'h4: cd_session <= cd_data;
					3'h5: cd_jcd_len_min <= cd_data;
					3'h6: cd_jcd_len_sec <= cd_data;
					3'h7: begin
						cd_jcd_len_frame <= cd_data;
						cd_state <= CD_STATE_JCD_DESC_TAIL;
						cd_cnt <= 3'h0;
					end
					default: ;
				endcase
				cd_ce <= 1;
				cd_bus_add = 30'h1;
			end else if (cd_state == CD_STATE_JCD_DESC_TAIL) begin
				case (cd_cnt)
					3'h1: cd_jcd_lba_hi <= cd_data;
					3'h2: cd_jcd_lba_mid <= cd_data;
					3'h3: begin
						if (({8'h00, cd_jcd_lba_hi, cd_jcd_lba_mid, cd_data} << 9) >= JCD_PAYLOAD_BASE) begin
							// JCD descriptor +0x09..+0x0B points at the already-converted
							// payload inside the JCD container. The converter's "+2" source
							// bias was applied when the file was created; re-applying it here
							// is wrong and becomes catastrophic because Butch stores the track
							// offset in 16-byte granularity. Keep the TOC offset aligned to the
							// true 0x200-byte payload sector start and let the normal JCD lane
							// shuffle present the expected logical bytes on the bus.
							cd_jcd_data_off <= (({8'h00, cd_jcd_lba_hi, cd_jcd_lba_mid, cd_data}) << 9) - JCD_PAYLOAD_BASE;
						end else begin
							cd_jcd_data_off <= 32'h0;
						end
						if (cd_desc_index < JCD_MAX_TRACKS) begin
							cd_jcd_track_tab[cd_desc_index] <= cd_track;
							cd_jcd_session_tab[cd_desc_index] <= cd_session;
							cd_jcd_start_tab[cd_desc_index] <= msf_to_frames24(cd_jcd_start_min, cd_jcd_start_sec, cd_jcd_start_frame);
							cd_jcd_len_tab[cd_desc_index] <= msf_to_frames24(cd_jcd_len_min, cd_jcd_len_sec, cd_jcd_len_frame);
							if (({8'h00, cd_jcd_lba_hi, cd_jcd_lba_mid, cd_data} << 9) >= JCD_PAYLOAD_BASE) begin
								cd_jcd_off_tab[cd_desc_index] <= (({8'h00, cd_jcd_lba_hi, cd_jcd_lba_mid, cd_data}) << 9) - JCD_PAYLOAD_BASE;
							end else begin
								cd_jcd_off_tab[cd_desc_index] <= 30'h0;
							end
						end
						if ((cd_desc_index + 8'h1) < cd_jcd_desc_count) begin
							cd_desc_index <= cd_desc_index + 8'h1;
							cd_state <= CD_STATE_JCD_DESC_HEAD;
							cd_cnt <= 3'h0;
							cd_bus_add = 30'h1;
							cd_ce <= 1;
						end else begin
							cd_desc_index <= 8'h0;
							cd_jcd_prev_session <= 8'hFF;
							cd_state <= CD_STATE_JCD_PREP_START;
							cd_cnt <= 3'h0;
						end
					end
					default: ;
				endcase
				if (cd_cnt != 3'h3) begin
					cd_ce <= 1;
					cd_bus_add = 30'h1;
				end
			end else if (cd_state == CD_STATE_JCD_PREP_START) begin
				jcd_cur_track = cd_jcd_track_tab[cd_desc_index];
				jcd_cur_session = cd_jcd_session_tab[cd_desc_index];
				jcd_cur_start_lba = {8'h00, cd_jcd_start_tab[cd_desc_index]};
				jcd_cur_len_lba = {8'h00, cd_jcd_len_tab[cd_desc_index]};
				jcd_cur_file_off = cd_jcd_off_tab[cd_desc_index];
				jcd_emit_session_first = (cd_desc_index == 8'h00) ||
					(jcd_cur_session != cd_jcd_session_tab[cd_desc_index - 8'h1]);
				jcd_emit_disc_first = jcd_emit_session_first && (jcd_cur_start_lba == 32'h0000_0000);

				// cd2jcd stores descriptor starts as:
				// - track 1: 00:00:00
				// - later tracks: source_start + 1 frame
				// Convert back to source-style absolute starts so JCD TOC timing
				// tracks CDI behavior at Butch.
				if (jcd_emit_disc_first) begin
					jcd_src_start_lba = 32'h0;
				end else if (jcd_cur_start_lba != 32'h0) begin
					jcd_src_start_lba = jcd_cur_start_lba - 32'h1;
				end else begin
					jcd_src_start_lba = 32'h0;
				end

				// Descriptor-native model:
				// Use descriptor length and offset as authoritative values and keep
				// the session-first 150-frame pregap policy for Butch TOC generation.
				jcd_prog_len_lba = jcd_cur_len_lba;
				jcd_total_len_lba = jcd_cur_len_lba + (jcd_emit_session_first ? 32'd150 : 32'd0);

				cd_track <= jcd_cur_track;
				cd_session <= jcd_cur_session;
				cd_startlba <= jcd_src_start_lba;
				cd_file_offset <= jcd_cur_file_off;
				cd_totlength <= jcd_total_len_lba;
				cd_length <= jcd_prog_len_lba;
				cd_pregap <= jcd_emit_session_first ? 24'd150 : 24'd0;
				cd_start <= jcd_src_start_lba + (jcd_emit_session_first ? 32'd150 : 32'd0);
				cd_track_end <= jcd_src_start_lba + (jcd_emit_session_first ? 32'd150 : 32'd0) + jcd_prog_len_lba;
				cd_state <= CD_STATE_EMIT_START;
				cd_emit_calc_offset <= 1'b0;
				cd_tomsf <= jcd_src_start_lba[23:0] + (jcd_emit_session_first ? 24'd150 : 24'd0);
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
	// Latch the first couple of mounted data-read addresses after each stream
	// start. Later VLM traffic can move the live BUS display far away from the
	// initial boot probe, so keeping these values stable makes it easier to see
	// where the BIOS first tried to read game data.
	if (cd_img_mounted && aud_rd_trig && (dbg_first_aud_count != 2'h2)) begin
		if (dbg_first_aud_count == 2'h0) begin
			dbg_first_aud_addr0 <= audbus_out;
		end else begin
			dbg_first_aud_addr1 <= audbus_out;
		end
		dbg_first_aud_count <= dbg_first_aud_count + 2'h1;
	end
	if (cd_img_mounted && !dbg_first_grant_seen &&
		(((img_rd_trig && cd_valid) || (!xwaitl_latch && cd_valid)))) begin
		dbg_first_grant_seen <= 1'b1;
		dbg_first_grant_addr <= imgbus_out;
		dbg_first_grant_file_addr <= ringbus_out;
		dbg_first_grant_word <= cdram_q_stream_final;
	end

	old_ack  <= cd_hps_ack;

	if (~old_ack && cd_hps_ack) begin
		cd_hps_req <= 1'b0;
	end

	// The first metadata sector is always fetched outside the ring buffer so the
	// mount path can identify the image type without perturbing stream cache
	// state. If it is JCD, fetch the rest of the fixed 0x600-byte metadata area
	// (sectors 1 and 2) before starting the parser.
	if (meta_active && old_ack && ~cd_hps_ack) begin
		if (!meta_is_jcd) begin
			if (meta_magic == 32'h0044434A) begin
				cd_fmt <= CD_FMT_JCD;
				meta_is_jcd <= 1'b1;
				meta_sector <= 2'd1;
				cd_hps_lba <= 32'h1;
				cd_hps_req <= 1'b1;
			end else begin
				meta_active <= 1'b0;
				meta_is_jcd <= 1'b0;
				meta_sector <= 2'h0;
				cd_fmt <= CD_FMT_CDI;
				cd_state <= CD_STATE_CDI_TAIL_REQ;
				cd_cnt <= 3'h0;
				cd_bus_out <= 30'h0;
			end
		end else if (meta_sector < 2'd2) begin
			meta_sector <= meta_sector + 2'd1;
			cd_hps_lba <= ({30'h0, meta_sector} + 32'd1);
			cd_hps_req <= 1'b1;
		end else begin
			meta_active <= 1'b0;
			cd_state <= CD_STATE_JCD_HEADER;
			cd_cnt <= 3'h0;
			cd_bus_out <= 30'h4;
		end
	end else if (load_state && old_ack && ~cd_hps_ack) begin
		load_state <= 1'b0;
		if ((cd_ring_count < CD_RING_DEPTH) && (cd_hps_lba[20:0] == cd_ring_end_lba)) begin
			cd_ring_count <= cd_ring_count + 6'd1;
		end
	end

	// Mounted playback always uses the ring. During mount, only the CDI parser
	// should be allowed to trigger cache-miss servicing before cd_img_mounted
	// goes high. JCD mount parsing reads only the prefetched metadata bytes that
	// were already written into the ring and should not initiate new misses.
	if (img_rd_trig && (cd_img_mounted || ((cd_fmt == CD_FMT_CDI) && !stream_idle))) begin
		load_cnt[31:0] <= 32'h0;
		cload_cnt[31:0] <= 32'h0;
		cd_ring_armed <= 1'b1;
		if (!cd_lba_in_ring) begin
			cd_ring_base_lba <= cd_file_lba;
			cd_ring_count <= 6'd0;
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

	if (cd_img_mounted && cd_ring_armed && !load_state && !miss_request_now && (cd_ring_count < cd_ring_target_depth)) begin
		cd_hps_lba <= {11'h000, cd_ring_end_lba};
		cd_hps_req <= 1'b1;
		load_state <= 1'b1;
	end

end

// Present cached data in the exact 64-bit lane order the top level previously
// exposed. JCD needs one extra shuffle here because its payload packing differs
// from CDI after the metadata/header region.
wire [63:0] cdram_q_stream = {cdram_dout[31:00],cdram_dout[63:32]};
wire [63:0] cdram_q_stream_jcd = {cdram_q_stream[47:32], cdram_q_stream[63:48], cdram_q_stream[15:0], cdram_q_stream[31:16]};
wire [63:0] cdram_q_stream_final = (cd_fmt == CD_FMT_JCD) ? cdram_q_stream_jcd : cdram_q_stream;
assign cd_state_idle = (cd_state == CD_STATE_IDLE);
assign dbg_cd_fmt = cd_fmt;
assign dbg_cd_state = cd_state;
assign dbg_cd_track = cd_track;
assign dbg_cd_session = cd_session;
assign dbg_cd_desc_index = cd_desc_index;
assign dbg_cur_file_addr = ringbus_out;
assign stream_q = cdram_q_stream_final;

endmodule
