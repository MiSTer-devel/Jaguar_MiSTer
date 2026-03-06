module jaguar_debug_overlay
(
	input  logic        clk_sys,
	input  logic        ce_pix,
	input  logic        reset,
	input  logic        enable,
	input  logic        hblank,
	input  logic        vblank,
	input  logic  [7:0] in_r,
	input  logic  [7:0] in_g,
	input  logic  [7:0] in_b,
	input  logic        cd_drive_en,
	input  logic        cd_img_mounted,
	input  logic        cd_inserted,
	input  logic        cd_valid,
	input  logic  [1:0] cd_fmt,
	input  logic  [4:0] cd_state,
	input  logic  [7:0] cd_track,
	input  logic  [7:0] cd_session,
	input  logic  [7:0] cd_desc_index,
	input  logic  [7:0] cd_session_count,
	input  logic        cd_toc_wr,
	input  logic  [9:0] cd_toc_addr,
	input  logic [15:0] cd_toc_data,
	input  logic        cd_hps_req,
	input  logic        cd_hps_ack,
	input  logic        xwaitl,
	input  logic        cd_stream_boot_pending,
	input  logic        cd_state_idle_dbg,
	input  logic        xresetlp_dbg,
	input  logic        xresetl_dbg,
	input  logic        bootcopy_active,
	input  logic [31:0] cd_hps_lba,
	input  logic [31:0] audbus_out_dbg,
	input  logic        butch_aud_sess,
	input  logic  [6:0] butch_cue_tracks,
	input  logic  [6:0] butch_aud_tracks,
	input  logic  [6:0] butch_dat_track,
	input  logic  [7:0] butch_dsa_sessions,
	input  logic        butch_sess1_valid,
	input  logic [15:0] butch_last_ds,
	input  logic  [7:0] butch_last_err,
	input  logic  [6:0] butch_track_idx,
	input  logic  [6:0] butch_cues_addr,
	input  logic  [6:0] butch_cuet_addr,
	input  logic [15:0] butch_resp_54,
	input  logic [39:0] butch_toc0,
	input  logic [39:0] butch_toc1,
	input  logic [15:0] butch_spin,
	input  logic [15:0] butch_ltoc0,
	input  logic [15:0] butch_ltoc1,
	input  logic [29:0] first_aud_addr0,
	input  logic [29:0] first_aud_addr1,
	input  logic        first_grant_seen,
	input  logic  [6:0] first_grant_track,
	input  logic  [6:0] first_grant_cuet,
	input  logic [29:0] first_grant_addr,
	input  logic [29:0] first_grant_file_addr,
	input  logic [63:0] first_grant_word,
	input  logic [63:0] stream_q_dbg,
	output logic  [7:0] out_r,
	output logic  [7:0] out_g,
	output logic  [7:0] out_b
);

	// This is intentionally simple and self-contained:
	// - It watches the existing pixel cadence (`ce_pix`) and blanking signals.
	// - It reconstructs an active-video X/Y coordinate in the same clock domain.
	// - It renders a compact fixed text block using an internal 8x8 bitmap font.
	// - It overlays useful CD state so image-format and mount issues can be seen
	//   immediately on screen without external probes.
	//
	// The text map is fixed on purpose. Editing the `char_code` case below is the
	// low-risk way to swap in different debug fields later.

	localparam int BOX_X       = 8;
	localparam int BOX_Y       = 8;
	localparam int CHAR_W      = 8;
	localparam int CHAR_H      = 8;
	localparam int TEXT_COLS   = 32;
	localparam int TEXT_ROWS   = 15;
	localparam int BOX_W       = TEXT_COLS * CHAR_W;
	localparam int BOX_H       = TEXT_ROWS * CHAR_H;

	logic [9:0] pix_x;
	logic [9:0] pix_y;
	logic       old_hblank;
	logic       old_vblank;
	logic       toc_seen;
	logic  [9:0] toc_addr_last;
	logic [15:0] toc_data_last;
	logic [15:0] track2_toc [0:7];
	integer      track2_i;

	wire frame_start = old_vblank && !vblank;
	wire line_start  = old_hblank && !hblank;

	always_ff @(posedge clk_sys) begin
		if (reset) begin
			pix_x      <= 10'd0;
			pix_y      <= 10'd0;
			old_hblank <= 1'b1;
			old_vblank <= 1'b1;
			toc_seen   <= 1'b0;
			toc_addr_last <= 10'h000;
			toc_data_last <= 16'h0000;
			for (track2_i = 0; track2_i < 8; track2_i = track2_i + 1) begin
				track2_toc[track2_i] <= 16'h0000;
			end
		end else begin
			if (cd_toc_wr) begin
				toc_seen <= 1'b1;
				toc_addr_last <= cd_toc_addr;
				toc_data_last <= cd_toc_data;
				if (cd_toc_addr == 10'h008) begin
					for (track2_i = 0; track2_i < 8; track2_i = track2_i + 1) begin
						track2_toc[track2_i] <= 16'h0000;
					end
				end
				if (cd_toc_addr[9:3] == 7'h02) begin
					track2_toc[cd_toc_addr[2:0]] <= cd_toc_data;
				end
			end

			if (ce_pix) begin
				old_hblank <= hblank;
				old_vblank <= vblank;

				if (frame_start) begin
					pix_x <= 10'd0;
					pix_y <= 10'd0;
				end else if (line_start) begin
					pix_x <= 10'd0;
					if (!vblank) pix_y <= pix_y + 10'd1;
				end else if (!hblank && !vblank) begin
					pix_x <= pix_x + 10'd1;
				end
			end
		end
	end

	function automatic [7:0] bit_char(input logic bit_value);
		bit_char = bit_value ? "1" : "0";
	endfunction

	function automatic [7:0] hex_char(input logic [3:0] nibble);
		case (nibble)
			4'h0: hex_char = "0";
			4'h1: hex_char = "1";
			4'h2: hex_char = "2";
			4'h3: hex_char = "3";
			4'h4: hex_char = "4";
			4'h5: hex_char = "5";
			4'h6: hex_char = "6";
			4'h7: hex_char = "7";
			4'h8: hex_char = "8";
			4'h9: hex_char = "9";
			4'hA: hex_char = "A";
			4'hB: hex_char = "B";
			4'hC: hex_char = "C";
			4'hD: hex_char = "D";
			4'hE: hex_char = "E";
			default: hex_char = "F";
		endcase
	endfunction

	function automatic [7:0] font_row(input logic [7:0] ch, input logic [2:0] row);
		begin
			font_row = 8'h00;
			case (ch)
				" ": font_row = 8'h00;
				":": case (row)
					3'd1: font_row = 8'h18;
					3'd2: font_row = 8'h18;
					3'd5: font_row = 8'h18;
					3'd6: font_row = 8'h18;
					default: font_row = 8'h00;
				endcase
				"0": case (row)
					3'd0: font_row = 8'h3C;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h6E;
					3'd3: font_row = 8'h76;
					3'd4: font_row = 8'h66;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h3C;
					default: font_row = 8'h00;
				endcase
				"1": case (row)
					3'd0: font_row = 8'h18;
					3'd1: font_row = 8'h38;
					3'd2: font_row = 8'h18;
					3'd3: font_row = 8'h18;
					3'd4: font_row = 8'h18;
					3'd5: font_row = 8'h18;
					3'd6: font_row = 8'h3C;
					default: font_row = 8'h00;
				endcase
				"2": case (row)
					3'd0: font_row = 8'h3C;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h06;
					3'd3: font_row = 8'h0C;
					3'd4: font_row = 8'h18;
					3'd5: font_row = 8'h30;
					3'd6: font_row = 8'h7E;
					default: font_row = 8'h00;
				endcase
				"3": case (row)
					3'd0: font_row = 8'h3C;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h06;
					3'd3: font_row = 8'h1C;
					3'd4: font_row = 8'h06;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h3C;
					default: font_row = 8'h00;
				endcase
				"4": case (row)
					3'd0: font_row = 8'h0C;
					3'd1: font_row = 8'h1C;
					3'd2: font_row = 8'h3C;
					3'd3: font_row = 8'h6C;
					3'd4: font_row = 8'h7E;
					3'd5: font_row = 8'h0C;
					3'd6: font_row = 8'h0C;
					default: font_row = 8'h00;
				endcase
				"5": case (row)
					3'd0: font_row = 8'h7E;
					3'd1: font_row = 8'h60;
					3'd2: font_row = 8'h7C;
					3'd3: font_row = 8'h06;
					3'd4: font_row = 8'h06;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h3C;
					default: font_row = 8'h00;
				endcase
				"6": case (row)
					3'd0: font_row = 8'h1C;
					3'd1: font_row = 8'h30;
					3'd2: font_row = 8'h60;
					3'd3: font_row = 8'h7C;
					3'd4: font_row = 8'h66;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h3C;
					default: font_row = 8'h00;
				endcase
				"7": case (row)
					3'd0: font_row = 8'h7E;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h06;
					3'd3: font_row = 8'h0C;
					3'd4: font_row = 8'h18;
					3'd5: font_row = 8'h18;
					3'd6: font_row = 8'h18;
					default: font_row = 8'h00;
				endcase
				"8": case (row)
					3'd0: font_row = 8'h3C;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h66;
					3'd3: font_row = 8'h3C;
					3'd4: font_row = 8'h66;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h3C;
					default: font_row = 8'h00;
				endcase
				"9": case (row)
					3'd0: font_row = 8'h3C;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h66;
					3'd3: font_row = 8'h3E;
					3'd4: font_row = 8'h06;
					3'd5: font_row = 8'h0C;
					3'd6: font_row = 8'h38;
					default: font_row = 8'h00;
				endcase
				"A": case (row)
					3'd0: font_row = 8'h18;
					3'd1: font_row = 8'h3C;
					3'd2: font_row = 8'h66;
					3'd3: font_row = 8'h66;
					3'd4: font_row = 8'h7E;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h66;
					default: font_row = 8'h00;
				endcase
				"B": case (row)
					3'd0: font_row = 8'h7C;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h66;
					3'd3: font_row = 8'h7C;
					3'd4: font_row = 8'h66;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h7C;
					default: font_row = 8'h00;
				endcase
				"C": case (row)
					3'd0: font_row = 8'h3C;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h60;
					3'd3: font_row = 8'h60;
					3'd4: font_row = 8'h60;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h3C;
					default: font_row = 8'h00;
				endcase
				"D": case (row)
					3'd0: font_row = 8'h78;
					3'd1: font_row = 8'h6C;
					3'd2: font_row = 8'h66;
					3'd3: font_row = 8'h66;
					3'd4: font_row = 8'h66;
					3'd5: font_row = 8'h6C;
					3'd6: font_row = 8'h78;
					default: font_row = 8'h00;
				endcase
				"E": case (row)
					3'd0: font_row = 8'h7E;
					3'd1: font_row = 8'h60;
					3'd2: font_row = 8'h60;
					3'd3: font_row = 8'h7C;
					3'd4: font_row = 8'h60;
					3'd5: font_row = 8'h60;
					3'd6: font_row = 8'h7E;
					default: font_row = 8'h00;
				endcase
				"F": case (row)
					3'd0: font_row = 8'h7E;
					3'd1: font_row = 8'h60;
					3'd2: font_row = 8'h60;
					3'd3: font_row = 8'h7C;
					3'd4: font_row = 8'h60;
					3'd5: font_row = 8'h60;
					3'd6: font_row = 8'h60;
					default: font_row = 8'h00;
				endcase
				"I": case (row)
					3'd0: font_row = 8'h3C;
					3'd1: font_row = 8'h18;
					3'd2: font_row = 8'h18;
					3'd3: font_row = 8'h18;
					3'd4: font_row = 8'h18;
					3'd5: font_row = 8'h18;
					3'd6: font_row = 8'h3C;
					default: font_row = 8'h00;
				endcase
				"L": case (row)
					3'd0: font_row = 8'h60;
					3'd1: font_row = 8'h60;
					3'd2: font_row = 8'h60;
					3'd3: font_row = 8'h60;
					3'd4: font_row = 8'h60;
					3'd5: font_row = 8'h60;
					3'd6: font_row = 8'h7E;
					default: font_row = 8'h00;
				endcase
				"M": case (row)
					3'd0: font_row = 8'h63;
					3'd1: font_row = 8'h77;
					3'd2: font_row = 8'h7F;
					3'd3: font_row = 8'h6B;
					3'd4: font_row = 8'h63;
					3'd5: font_row = 8'h63;
					3'd6: font_row = 8'h63;
					default: font_row = 8'h00;
				endcase
				"P": case (row)
					3'd0: font_row = 8'h7C;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h66;
					3'd3: font_row = 8'h7C;
					3'd4: font_row = 8'h60;
					3'd5: font_row = 8'h60;
					3'd6: font_row = 8'h60;
					default: font_row = 8'h00;
				endcase
				"Q": case (row)
					3'd0: font_row = 8'h3C;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h66;
					3'd3: font_row = 8'h66;
					3'd4: font_row = 8'h6E;
					3'd5: font_row = 8'h3C;
					3'd6: font_row = 8'h0E;
					default: font_row = 8'h00;
				endcase
				"R": case (row)
					3'd0: font_row = 8'h7C;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h66;
					3'd3: font_row = 8'h7C;
					3'd4: font_row = 8'h6C;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h66;
					default: font_row = 8'h00;
				endcase
				"S": case (row)
					3'd0: font_row = 8'h3E;
					3'd1: font_row = 8'h60;
					3'd2: font_row = 8'h60;
					3'd3: font_row = 8'h3C;
					3'd4: font_row = 8'h06;
					3'd5: font_row = 8'h06;
					3'd6: font_row = 8'h7C;
					default: font_row = 8'h00;
				endcase
				"T": case (row)
					3'd0: font_row = 8'h7E;
					3'd1: font_row = 8'h18;
					3'd2: font_row = 8'h18;
					3'd3: font_row = 8'h18;
					3'd4: font_row = 8'h18;
					3'd5: font_row = 8'h18;
					3'd6: font_row = 8'h18;
					default: font_row = 8'h00;
				endcase
				"U": case (row)
					3'd0: font_row = 8'h66;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h66;
					3'd3: font_row = 8'h66;
					3'd4: font_row = 8'h66;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h3C;
					default: font_row = 8'h00;
				endcase
				"V": case (row)
					3'd0: font_row = 8'h66;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h66;
					3'd3: font_row = 8'h66;
					3'd4: font_row = 8'h66;
					3'd5: font_row = 8'h3C;
					3'd6: font_row = 8'h18;
					default: font_row = 8'h00;
				endcase
				"W": case (row)
					3'd0: font_row = 8'h63;
					3'd1: font_row = 8'h63;
					3'd2: font_row = 8'h63;
					3'd3: font_row = 8'h6B;
					3'd4: font_row = 8'h7F;
					3'd5: font_row = 8'h77;
					3'd6: font_row = 8'h63;
					default: font_row = 8'h00;
				endcase
				"X": case (row)
					3'd0: font_row = 8'h66;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h3C;
					3'd3: font_row = 8'h18;
					3'd4: font_row = 8'h3C;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h66;
					default: font_row = 8'h00;
				endcase
				default: font_row = 8'h00;
			endcase
		end
	endfunction

	logic       in_box;
	logic [5:0] text_col;
	logic [3:0] text_row;
	logic [2:0] glyph_x;
	logic [2:0] glyph_y;
	logic [7:0] char_code;
	logic [7:0] glyph_bits;
	logic       text_pixel;

	always @* begin
		in_box = enable &&
			!hblank &&
			!vblank &&
			(pix_x >= BOX_X) &&
			(pix_x < (BOX_X + BOX_W)) &&
			(pix_y >= BOX_Y) &&
			(pix_y < (BOX_Y + BOX_H));

		text_col  = 6'd0;
		text_row  = 4'd0;
		glyph_x   = 3'd0;
		glyph_y   = 3'd0;
		char_code = " ";
		glyph_bits = 8'h00;
		text_pixel = 1'b0;

		if (in_box) begin
			text_col  = (pix_x - BOX_X) >> 3;
			text_row  = (pix_y - BOX_Y) >> 3;
			glyph_x   = (pix_x - BOX_X) & 10'd7;
			glyph_y   = (pix_y - BOX_Y) & 10'd7;

			case (text_row)
				4'd0: begin
					case (text_col)
						6'd0:  char_code = "C";
						6'd1:  char_code = "D";
						6'd2:  char_code = " ";
						6'd3:  char_code = "D";
						6'd4:  char_code = ":";
						6'd5:  char_code = bit_char(cd_drive_en);
						6'd6:  char_code = " ";
						6'd7:  char_code = "M";
						6'd8:  char_code = ":";
						6'd9:  char_code = bit_char(cd_img_mounted);
						6'd10: char_code = " ";
						6'd11: char_code = "I";
						6'd12: char_code = ":";
						6'd13: char_code = bit_char(cd_inserted);
						6'd14: char_code = " ";
						6'd15: char_code = "V";
						6'd16: char_code = ":";
						6'd17: char_code = bit_char(cd_valid);
						6'd18: char_code = " ";
						6'd19: char_code = "F";
						6'd20: char_code = ":";
						6'd21: char_code = hex_char({2'b00, cd_fmt});
						6'd22: char_code = " ";
						6'd23: char_code = "T";
						6'd24: char_code = ":";
						6'd25: char_code = hex_char({3'b000, cd_state[4]});
						6'd26: char_code = hex_char(cd_state[3:0]);
						default: char_code = " ";
					endcase
				end
				4'd1: begin
					case (text_col)
						6'd0:  char_code = "S";
						6'd1:  char_code = ":";
						6'd2:  char_code = hex_char(cd_session_count[7:4]);
						6'd3:  char_code = hex_char(cd_session_count[3:0]);
						6'd4:  char_code = " ";
						6'd5:  char_code = "Q";
						6'd6:  char_code = ":";
						6'd7:  char_code = bit_char(cd_hps_req);
						6'd8:  char_code = " ";
						6'd9:  char_code = "A";
						6'd10: char_code = ":";
						6'd11: char_code = bit_char(cd_hps_ack);
						6'd12: char_code = " ";
						6'd13: char_code = "X";
						6'd14: char_code = ":";
						6'd15: char_code = bit_char(xwaitl);
						6'd16: char_code = " ";
						6'd17: char_code = "P";
						6'd18: char_code = ":";
						6'd19: char_code = bit_char(cd_stream_boot_pending);
						default: char_code = " ";
					endcase
				end
				4'd2: begin
					case (text_col)
						6'd0:  char_code = "T";
						6'd1:  char_code = "R";
						6'd2:  char_code = ":";
						6'd3:  char_code = hex_char(cd_track[7:4]);
						6'd4:  char_code = hex_char(cd_track[3:0]);
						6'd5:  char_code = " ";
						6'd6:  char_code = "S";
						6'd7:  char_code = "S";
						6'd8:  char_code = ":";
						6'd9:  char_code = hex_char(cd_session[7:4]);
						6'd10: char_code = hex_char(cd_session[3:0]);
						6'd11: char_code = " ";
						6'd12: char_code = "D";
						6'd13: char_code = "I";
						6'd14: char_code = ":";
						6'd15: char_code = hex_char(cd_desc_index[7:4]);
						6'd16: char_code = hex_char(cd_desc_index[3:0]);
						default: char_code = " ";
					endcase
				end
				4'd3: begin
					case (text_col)
						6'd0:  char_code = "T";
						6'd1:  char_code = "W";
						6'd2:  char_code = ":";
						6'd3:  char_code = bit_char(toc_seen);
						6'd4:  char_code = " ";
						6'd5:  char_code = "A";
						6'd6:  char_code = ":";
						6'd7:  char_code = hex_char({2'b00, toc_addr_last[9:8]});
						6'd8:  char_code = hex_char(toc_addr_last[7:4]);
						6'd9:  char_code = hex_char(toc_addr_last[3:0]);
						6'd10: char_code = " ";
						6'd11: char_code = "D";
						6'd12: char_code = ":";
						6'd13: char_code = hex_char(toc_data_last[15:12]);
						6'd14: char_code = hex_char(toc_data_last[11:8]);
						6'd15: char_code = hex_char(toc_data_last[7:4]);
						6'd16: char_code = hex_char(toc_data_last[3:0]);
						default: char_code = " ";
					endcase
				end
				4'd4: begin
					case (text_col)
						6'd0:  char_code = "C";
						6'd1:  char_code = "Q";
						6'd2:  char_code = ":";
						6'd3:  char_code = hex_char({1'b0, butch_cue_tracks[6:4]});
						6'd4:  char_code = hex_char(butch_cue_tracks[3:0]);
						6'd5:  char_code = " ";
						6'd6:  char_code = "A";
						6'd7:  char_code = "Q";
						6'd8:  char_code = ":";
						6'd9:  char_code = hex_char({1'b0, butch_aud_tracks[6:4]});
						6'd10: char_code = hex_char(butch_aud_tracks[3:0]);
						6'd11: char_code = " ";
						6'd12: char_code = "D";
						6'd13: char_code = "T";
						6'd14: char_code = ":";
						6'd15: char_code = hex_char({1'b0, butch_dat_track[6:4]});
						6'd16: char_code = hex_char(butch_dat_track[3:0]);
						6'd17: char_code = " ";
						6'd18: char_code = "S";
						6'd19: char_code = "1";
						6'd20: char_code = ":";
						6'd21: char_code = bit_char(butch_sess1_valid);
						6'd22: char_code = " ";
						6'd23: char_code = "S";
						6'd24: char_code = "C";
						6'd25: char_code = ":";
						6'd26: char_code = hex_char(butch_dsa_sessions[7:4]);
						6'd27: char_code = hex_char(butch_dsa_sessions[3:0]);
						default: char_code = " ";
					endcase
				end
				4'd5: begin
					case (text_col)
						6'd0:  char_code = "T";
						6'd1:  char_code = "I";
						6'd2:  char_code = ":";
						6'd3:  char_code = hex_char({1'b0, butch_track_idx[6:4]});
						6'd4:  char_code = hex_char(butch_track_idx[3:0]);
						6'd5:  char_code = " ";
						6'd6:  char_code = "C";
						6'd7:  char_code = "S";
						6'd8:  char_code = ":";
						6'd9:  char_code = hex_char({1'b0, butch_cues_addr[6:4]});
						6'd10: char_code = hex_char(butch_cues_addr[3:0]);
						6'd11: char_code = " ";
						6'd12: char_code = "C";
						6'd13: char_code = "T";
						6'd14: char_code = ":";
						6'd15: char_code = hex_char({1'b0, butch_cuet_addr[6:4]});
						6'd16: char_code = hex_char(butch_cuet_addr[3:0]);
						default: char_code = " ";
					endcase
				end
				4'd6: begin
					case (text_col)
						6'd0:  char_code = "F";
						6'd1:  char_code = "T";
						6'd2:  char_code = ":";
						6'd3:  char_code = hex_char({1'b0, first_grant_track[6:4]});
						6'd4:  char_code = hex_char(first_grant_track[3:0]);
						6'd5:  char_code = " ";
						6'd6:  char_code = "F";
						6'd7:  char_code = "C";
						6'd8:  char_code = ":";
						6'd9:  char_code = hex_char({1'b0, first_grant_cuet[6:4]});
						6'd10: char_code = hex_char(first_grant_cuet[3:0]);
						6'd11: char_code = " ";
						6'd12: char_code = "G";
						6'd13: char_code = "S";
						6'd14: char_code = ":";
						6'd15: char_code = bit_char(first_grant_seen);
						default: char_code = " ";
					endcase
				end
				4'd7: begin
					case (text_col)
						6'd0:  char_code = "2";
						6'd1:  char_code = "0";
						6'd2:  char_code = ":";
						6'd3:  char_code = hex_char(track2_toc[0][15:12]);
						6'd4:  char_code = hex_char(track2_toc[0][11:8]);
						6'd5:  char_code = hex_char(track2_toc[0][7:4]);
						6'd6:  char_code = hex_char(track2_toc[0][3:0]);
						6'd7:  char_code = " ";
						6'd8:  char_code = "2";
						6'd9:  char_code = "1";
						6'd10: char_code = ":";
						6'd11: char_code = hex_char(track2_toc[1][15:12]);
						6'd12: char_code = hex_char(track2_toc[1][11:8]);
						6'd13: char_code = hex_char(track2_toc[1][7:4]);
						6'd14: char_code = hex_char(track2_toc[1][3:0]);
						6'd15: char_code = " ";
						6'd16: char_code = "2";
						6'd17: char_code = "2";
						6'd18: char_code = ":";
						6'd19: char_code = hex_char(track2_toc[2][15:12]);
						6'd20: char_code = hex_char(track2_toc[2][11:8]);
						6'd21: char_code = hex_char(track2_toc[2][7:4]);
						6'd22: char_code = hex_char(track2_toc[2][3:0]);
						default: char_code = " ";
					endcase
				end
				4'd8: begin
					case (text_col)
						6'd0:  char_code = "2";
						6'd1:  char_code = "3";
						6'd2:  char_code = ":";
						6'd3:  char_code = hex_char(track2_toc[3][15:12]);
						6'd4:  char_code = hex_char(track2_toc[3][11:8]);
						6'd5:  char_code = hex_char(track2_toc[3][7:4]);
						6'd6:  char_code = hex_char(track2_toc[3][3:0]);
						6'd7:  char_code = " ";
						6'd8:  char_code = "2";
						6'd9:  char_code = "4";
						6'd10: char_code = ":";
						6'd11: char_code = hex_char(track2_toc[4][15:12]);
						6'd12: char_code = hex_char(track2_toc[4][11:8]);
						6'd13: char_code = hex_char(track2_toc[4][7:4]);
						6'd14: char_code = hex_char(track2_toc[4][3:0]);
						6'd15: char_code = " ";
						6'd16: char_code = "2";
						6'd17: char_code = "5";
						6'd18: char_code = ":";
						6'd19: char_code = hex_char(track2_toc[5][15:12]);
						6'd20: char_code = hex_char(track2_toc[5][11:8]);
						6'd21: char_code = hex_char(track2_toc[5][7:4]);
						6'd22: char_code = hex_char(track2_toc[5][3:0]);
						default: char_code = " ";
					endcase
				end
				4'd9: begin
					case (text_col)
						6'd0:  char_code = "2";
						6'd1:  char_code = "6";
						6'd2:  char_code = ":";
						6'd3:  char_code = hex_char(track2_toc[6][15:12]);
						6'd4:  char_code = hex_char(track2_toc[6][11:8]);
						6'd5:  char_code = hex_char(track2_toc[6][7:4]);
						6'd6:  char_code = hex_char(track2_toc[6][3:0]);
						6'd7:  char_code = " ";
						6'd8:  char_code = "2";
						6'd9:  char_code = "7";
						6'd10: char_code = ":";
						6'd11: char_code = hex_char(track2_toc[7][15:12]);
						6'd12: char_code = hex_char(track2_toc[7][11:8]);
						6'd13: char_code = hex_char(track2_toc[7][7:4]);
						6'd14: char_code = hex_char(track2_toc[7][3:0]);
						default: char_code = " ";
					endcase
				end
				4'd10: begin
					case (text_col)
						6'd0:  char_code = "R";
						6'd1:  char_code = ":";
						6'd2:  char_code = bit_char(reset);
						6'd3:  char_code = " ";
						6'd4:  char_code = "C";
						6'd5:  char_code = ":";
						6'd6:  char_code = bit_char(cd_state_idle_dbg);
						6'd7:  char_code = " ";
						6'd8:  char_code = "P";
						6'd9:  char_code = ":";
						6'd10: char_code = bit_char(xresetlp_dbg);
						6'd11: char_code = " ";
						6'd12: char_code = "X";
						6'd13: char_code = ":";
						6'd14: char_code = bit_char(xresetl_dbg);
						6'd15: char_code = " ";
						6'd16: char_code = "B";
						6'd17: char_code = ":";
						6'd18: char_code = bit_char(bootcopy_active);
						6'd19: char_code = " ";
						6'd20: char_code = "L";
						6'd21: char_code = ":";
						6'd22: char_code = hex_char(butch_last_ds[15:12]);
						6'd23: char_code = hex_char(butch_last_ds[11:8]);
						6'd24: char_code = hex_char(butch_last_ds[7:4]);
						6'd25: char_code = hex_char(butch_last_ds[3:0]);
						6'd26: char_code = " ";
						6'd27: char_code = "E";
						6'd28: char_code = ":";
						6'd29: char_code = hex_char(butch_last_err[7:4]);
						6'd30: char_code = hex_char(butch_last_err[3:0]);
						default: char_code = " ";
					endcase
				end
				4'd11: begin
					case (text_col)
						6'd0:  char_code = "3";
						6'd1:  char_code = "0";
						6'd2:  char_code = ":";
						6'd3:  char_code = hex_char(butch_toc0[39:36]);
						6'd4:  char_code = hex_char(butch_toc0[35:32]);
						6'd5:  char_code = " ";
						6'd6:  char_code = hex_char(butch_toc0[31:28]);
						6'd7:  char_code = hex_char(butch_toc0[27:24]);
						6'd8:  char_code = " ";
						6'd9:  char_code = hex_char(butch_toc0[23:20]);
						6'd10: char_code = hex_char(butch_toc0[19:16]);
						6'd11: char_code = hex_char(butch_toc0[15:12]);
						6'd12: char_code = hex_char(butch_toc0[11:8]);
						6'd13: char_code = hex_char(butch_toc0[7:4]);
						6'd14: char_code = hex_char(butch_toc0[3:0]);
						default: char_code = " ";
					endcase
				end
				4'd12: begin
					case (text_col)
						6'd0:  char_code = "3";
						6'd1:  char_code = "1";
						6'd2:  char_code = ":";
						6'd3:  char_code = hex_char(butch_toc1[39:36]);
						6'd4:  char_code = hex_char(butch_toc1[35:32]);
						6'd5:  char_code = " ";
						6'd6:  char_code = hex_char(butch_toc1[31:28]);
						6'd7:  char_code = hex_char(butch_toc1[27:24]);
						6'd8:  char_code = " ";
						6'd9:  char_code = hex_char(butch_toc1[23:20]);
						6'd10: char_code = hex_char(butch_toc1[19:16]);
						6'd11: char_code = hex_char(butch_toc1[15:12]);
						6'd12: char_code = hex_char(butch_toc1[11:8]);
						6'd13: char_code = hex_char(butch_toc1[7:4]);
						6'd14: char_code = hex_char(butch_toc1[3:0]);
						default: char_code = " ";
					endcase
				end
				4'd13: begin
					case (text_col)
						6'd0:  char_code = "L";
						6'd1:  char_code = "0";
						6'd2:  char_code = ":";
						6'd3:  char_code = bit_char(butch_ltoc0[15]);
						6'd4:  char_code = " ";
						6'd5:  char_code = hex_char({1'b0, butch_ltoc0[14:12]});
						6'd6:  char_code = hex_char(butch_ltoc0[11:8]);
						6'd7:  char_code = " ";
						6'd8:  char_code = hex_char(butch_ltoc0[7:4]);
						6'd9:  char_code = hex_char(butch_ltoc0[3:0]);
						6'd10: char_code = " ";
						6'd11: char_code = "L";
						6'd12: char_code = "1";
						6'd13: char_code = ":";
						6'd14: char_code = bit_char(butch_ltoc1[15]);
						6'd15: char_code = " ";
						6'd16: char_code = hex_char({1'b0, butch_ltoc1[14:12]});
						6'd17: char_code = hex_char(butch_ltoc1[11:8]);
						6'd18: char_code = " ";
						6'd19: char_code = hex_char(butch_ltoc1[7:4]);
						6'd20: char_code = hex_char(butch_ltoc1[3:0]);
						default: char_code = " ";
					endcase
				end
				4'd14: begin
					case (text_col)
						6'd0:  char_code = "F";
						6'd1:  char_code = "0";
						6'd2:  char_code = ":";
						6'd3:  char_code = hex_char(first_aud_addr0[29:28]);
						6'd4:  char_code = hex_char(first_aud_addr0[27:24]);
						6'd5:  char_code = hex_char(first_aud_addr0[23:20]);
						6'd6:  char_code = hex_char(first_aud_addr0[19:16]);
						6'd7:  char_code = hex_char(first_aud_addr0[15:12]);
						6'd8:  char_code = hex_char(first_aud_addr0[11:8]);
						6'd9:  char_code = hex_char(first_aud_addr0[7:4]);
						6'd10: char_code = hex_char(first_aud_addr0[3:0]);
						6'd11: char_code = " ";
						6'd12: char_code = "F";
						6'd13: char_code = "1";
						6'd14: char_code = ":";
						6'd15: char_code = hex_char(first_aud_addr1[29:28]);
						6'd16: char_code = hex_char(first_aud_addr1[27:24]);
						6'd17: char_code = hex_char(first_aud_addr1[23:20]);
						6'd18: char_code = hex_char(first_aud_addr1[19:16]);
						6'd19: char_code = hex_char(first_aud_addr1[15:12]);
						6'd20: char_code = hex_char(first_aud_addr1[11:8]);
						6'd21: char_code = hex_char(first_aud_addr1[7:4]);
						6'd22: char_code = hex_char(first_aud_addr1[3:0]);
						default: char_code = " ";
					endcase
				end
				default: char_code = " ";
			endcase

			glyph_bits = font_row(char_code, glyph_y);
			text_pixel = glyph_bits[7 - glyph_x];
		end
	end

	always @* begin
		out_r = in_r;
		out_g = in_g;
		out_b = in_b;

		if (in_box) begin
			// Darkened backdrop makes the text readable on bright scenes while
			// still letting the underlying image show through.
			out_r = {2'b00, in_r[7:2]};
			out_g = {2'b00, in_g[7:2]};
			out_b = {1'b0, in_b[7:1]};

			if (text_pixel) begin
				out_r = 8'hFF;
				out_g = 8'hF0;
				out_b = 8'h80;
			end
		end
	end

endmodule
