//`include "defines.vh"
module numstick
#(
	parameter int HOLD_CYCLES        = 53000000,
	parameter int PRESS_CYCLES       = 7950000,
	parameter int RECENTER_CYCLES    = 2120000,
	parameter int DEADZONE           = 16,
	parameter int GRID_THRESHOLD     = 48,
	parameter int DEFAULT_ACTIVE_W   = 640,
	parameter int DEFAULT_ACTIVE_H   = 240,
	parameter int CELL_W             = 56,
	parameter int CELL_H             = 24,
	parameter int CELL_GAP           = 2,
	parameter int BOX_PAD            = 8,
	parameter int STACK_GAP          = 8,
	parameter int BORDER_THICKNESS   = 2
)
(
	input  logic             clk_sys,
	input  logic             ce_pix,
	input  logic             reset,
	input  logic             enable,
	input  logic             hblank,
	input  logic             vblank,
	input  logic       [7:0] in_r,
	input  logic       [7:0] in_g,
	input  logic       [7:0] in_b,
	input  logic signed [7:0] stick_l_x,
	input  logic signed [7:0] stick_l_y,
	input  logic signed [7:0] stick_r_x,
	input  logic signed [7:0] stick_r_y,
	output logic      [11:0] keypad_press,
	output logic       [7:0] out_r,
	output logic       [7:0] out_g,
	output logic       [7:0] out_b
);

	localparam int HOLD_W       = (HOLD_CYCLES > 1)  ? $clog2(HOLD_CYCLES + 1)  : 1;
	localparam int PRESS_W      = (PRESS_CYCLES > 1) ? $clog2(PRESS_CYCLES + 1) : 1;
	localparam int RECENTER_W   = (RECENTER_CYCLES > 1) ? $clog2(RECENTER_CYCLES + 1) : 1;

	localparam logic [3:0] RIGHT_NONE = 4'hF;
	localparam logic [1:0] LEFT_NONE  = 2'b11;

	localparam int RIGHT_GRID_W = (3 * CELL_W) + (2 * CELL_GAP);
	localparam int RIGHT_GRID_H = (3 * CELL_H) + (2 * CELL_GAP);
	localparam int LEFT_GRID_W  = (3 * CELL_W) + (2 * CELL_GAP);
	localparam int LEFT_GRID_H  = CELL_H;
	localparam int BOX_W        = RIGHT_GRID_W + (2 * BOX_PAD);
	localparam int BOX_H_RIGHT  = RIGHT_GRID_H + (2 * BOX_PAD);
	localparam int BOX_H_LEFT   = LEFT_GRID_H + (2 * BOX_PAD);
	localparam int GLYPH_W      = 8;
	localparam int GLYPH_H      = 8;
	localparam int GLYPH_X_OFF  = (CELL_W - GLYPH_W) >> 1;
	localparam int GLYPH_Y_OFF  = (CELL_H - GLYPH_H) >> 1;

`ifndef FAST_COMPILE2

	logic [9:0] pix_x;
	logic [9:0] pix_y;
	logic       old_hblank;
	logic       old_vblank;
	logic [9:0] line_w_max;
	logic [9:0] active_w;
	logic [9:0] active_h;

	logic       right_armed;
	logic       right_popup_open;
	logic [3:0] right_hold_zone;
	logic [HOLD_W-1:0] right_hold_ctr;
	logic       right_press_active;
	logic [PRESS_W-1:0] right_press_ctr;
	logic [11:0] right_press_mask;
	logic [RECENTER_W-1:0] right_recenter_ctr;

	logic       left_armed;
	logic       left_popup_open;
	logic [1:0] left_hold_zone;
	logic [HOLD_W-1:0] left_hold_ctr;
	logic       left_press_active;
	logic [PRESS_W-1:0] left_press_ctr;
	logic [11:0] left_press_mask;
	logic [RECENTER_W-1:0] left_recenter_ctr;

	logic [3:0] right_zone_raw;
	logic [1:0] left_zone_raw;
	logic [3:0] right_zone_cur;
	logic [1:0] left_zone_cur;
	logic       show_right;
	logic       show_left;

	wire frame_start = old_vblank && !vblank;
	wire line_start  = old_hblank && !hblank;

	function automatic int abs_int(input int value);
		begin
			abs_int = (value < 0) ? -value : value;
		end
	endfunction

	function automatic logic [3:0] decode_right_zone
	(
		input logic signed [7:0] x,
		input logic signed [7:0] y
	);
		int xi;
		int yi;
		int row_i;
		int col_i;
		begin
			xi = x;
			yi = y;

			if ((abs_int(xi) <= DEADZONE) && (abs_int(yi) <= DEADZONE)) begin
				decode_right_zone = RIGHT_NONE;
			end else begin
				if (xi <= -GRID_THRESHOLD) col_i = 0;
				else if (xi >= GRID_THRESHOLD) col_i = 2;
				else col_i = 1;

				if (yi <= -GRID_THRESHOLD) row_i = 0;
				else if (yi >= GRID_THRESHOLD) row_i = 2;
				else row_i = 1;

				case ({row_i[1:0], col_i[1:0]})
					4'b00_00: decode_right_zone = 4'd0;
					4'b00_01: decode_right_zone = 4'd1;
					4'b00_10: decode_right_zone = 4'd2;
					4'b01_00: decode_right_zone = 4'd3;
					4'b01_01: decode_right_zone = 4'd4;
					4'b01_10: decode_right_zone = 4'd5;
					4'b10_00: decode_right_zone = 4'd6;
					4'b10_01: decode_right_zone = 4'd7;
					default:  decode_right_zone = 4'd8;
				endcase
			end
		end
	endfunction

	function automatic logic [1:0] decode_left_zone
	(
		input logic signed [7:0] x,
		input logic signed [7:0] y
	);
		int xi;
		int yi;
		begin
			xi = x;
			yi = y;

			if ((abs_int(xi) <= DEADZONE) && (abs_int(yi) <= DEADZONE)) begin
				decode_left_zone = LEFT_NONE;
			end else if (xi <= -GRID_THRESHOLD) begin
				decode_left_zone = 2'd0;
			end else if (xi >= GRID_THRESHOLD) begin
				decode_left_zone = 2'd2;
			end else begin
				decode_left_zone = 2'd1;
			end
		end
	endfunction

	function automatic logic [11:0] right_zone_mask(input logic [3:0] zone);
		begin
			if (zone < 4'd9) right_zone_mask = (12'h001 << zone);
			else right_zone_mask = 12'h000;
		end
	endfunction

	function automatic logic [11:0] left_zone_mask(input logic [1:0] zone);
		begin
			case (zone)
				2'd0: left_zone_mask = 12'h400; // *
				2'd1: left_zone_mask = 12'h200; // 0
				2'd2: left_zone_mask = 12'h800; // #
				default: left_zone_mask = 12'h000;
			endcase
		end
	endfunction

	function automatic logic [7:0] right_zone_char(input logic [3:0] zone);
		begin
			case (zone)
				4'd0: right_zone_char = "1";
				4'd1: right_zone_char = "2";
				4'd2: right_zone_char = "3";
				4'd3: right_zone_char = "4";
				4'd4: right_zone_char = "5";
				4'd5: right_zone_char = "6";
				4'd6: right_zone_char = "7";
				4'd7: right_zone_char = "8";
				default: right_zone_char = "9";
			endcase
		end
	endfunction

	function automatic logic [7:0] left_zone_char(input logic [1:0] zone);
		begin
			case (zone)
				2'd0: left_zone_char = "*";
				2'd1: left_zone_char = "0";
				default: left_zone_char = "#";
			endcase
		end
	endfunction

	function automatic logic [7:0] font_row(input logic [7:0] ch, input logic [2:0] row);
		begin
			font_row = 8'h00;
			case (ch)
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
				"*": case (row)
					3'd0: font_row = 8'h00;
					3'd1: font_row = 8'h66;
					3'd2: font_row = 8'h3C;
					3'd3: font_row = 8'hFF;
					3'd4: font_row = 8'h3C;
					3'd5: font_row = 8'h66;
					3'd6: font_row = 8'h00;
					default: font_row = 8'h00;
				endcase
				"#": case (row)
					3'd0: font_row = 8'h24;
					3'd1: font_row = 8'h24;
					3'd2: font_row = 8'h7E;
					3'd3: font_row = 8'h24;
					3'd4: font_row = 8'h7E;
					3'd5: font_row = 8'h24;
					3'd6: font_row = 8'h24;
					default: font_row = 8'h00;
				endcase
				default: font_row = 8'h00;
			endcase
		end
	endfunction

	function automatic logic [7:0] blend_panel_chan(input logic [7:0] bg, input logic [7:0] tint);
		begin
			blend_panel_chan = (bg >> 2) + (tint >> 2);
		end
	endfunction

	function automatic logic [7:0] blend_fill_chan(input logic [7:0] bg, input logic [7:0] fill);
		begin
			blend_fill_chan = (bg >> 2) + (fill >> 1) + (fill >> 2);
		end
	endfunction

	function automatic logic [7:0] blend_hot_chan(input logic [7:0] bg, input logic [7:0] fill);
		begin
			blend_hot_chan = (bg >> 3) + (fill >> 1) + (fill >> 2) + (fill >> 3);
		end
	endfunction

	function automatic int right_grid_row(input int idx);
		begin
			case (idx)
				0, 1, 2: right_grid_row = 0;
				3, 4, 5: right_grid_row = 1;
				default: right_grid_row = 2;
			endcase
		end
	endfunction

	function automatic int right_grid_col(input int idx);
		begin
			case (idx)
				0, 3, 6: right_grid_col = 0;
				1, 4, 7: right_grid_col = 1;
				default: right_grid_col = 2;
			endcase
		end
	endfunction

	assign right_zone_raw = decode_right_zone(stick_r_x, stick_r_y);
	assign left_zone_raw  = decode_left_zone(stick_l_x, stick_l_y);
	assign right_zone_cur = right_popup_open ? ((right_zone_raw == RIGHT_NONE) ? 4'd4 : right_zone_raw) : right_zone_raw;
	assign left_zone_cur  = left_popup_open  ? ((left_zone_raw  == LEFT_NONE)  ? 2'd1 : left_zone_raw)  : left_zone_raw;
	assign show_right     = enable && right_popup_open && !right_press_active;
	assign show_left      = enable && left_popup_open  && !left_press_active;
	assign keypad_press   = right_press_mask | left_press_mask;

	always_ff @(posedge clk_sys) begin
		if (reset) begin
			pix_x <= 10'd0;
			pix_y <= 10'd0;
			old_hblank <= 1'b1;
			old_vblank <= 1'b1;
			line_w_max <= DEFAULT_ACTIVE_W[9:0];
			active_w <= DEFAULT_ACTIVE_W[9:0];
			active_h <= DEFAULT_ACTIVE_H[9:0];

			right_armed <= 1'b1;
			right_popup_open <= 1'b0;
			right_hold_zone <= RIGHT_NONE;
			right_hold_ctr <= '0;
			right_press_active <= 1'b0;
			right_press_ctr <= '0;
			right_press_mask <= 12'h000;
			right_recenter_ctr <= '0;

			left_armed <= 1'b1;
			left_popup_open <= 1'b0;
			left_hold_zone <= LEFT_NONE;
			left_hold_ctr <= '0;
			left_press_active <= 1'b0;
			left_press_ctr <= '0;
			left_press_mask <= 12'h000;
			left_recenter_ctr <= '0;
		end else begin
			if (ce_pix) begin
				old_hblank <= hblank;
				old_vblank <= vblank;

				if (frame_start) begin
					active_w <= (line_w_max != 10'd0) ? line_w_max : DEFAULT_ACTIVE_W[9:0];
					active_h <= (pix_y != 10'd0) ? pix_y : DEFAULT_ACTIVE_H[9:0];
					line_w_max <= 10'd0;
					pix_x <= 10'd0;
					pix_y <= 10'd0;
				end else if (line_start) begin
					if (pix_x > line_w_max) line_w_max <= pix_x;
					pix_x <= 10'd0;
					if (!vblank) pix_y <= pix_y + 10'd1;
				end else if (!hblank && !vblank) begin
					pix_x <= pix_x + 10'd1;
				end
			end

			if (right_press_active) begin
				if (right_press_ctr >= (PRESS_CYCLES - 1)) begin
					right_press_active <= 1'b0;
					right_press_ctr <= '0;
					right_press_mask <= 12'h000;
				end else begin
					right_press_ctr <= right_press_ctr + 1'd1;
				end
			end else if (!enable) begin
				right_armed <= 1'b1;
				right_popup_open <= 1'b0;
				right_hold_zone <= RIGHT_NONE;
				right_hold_ctr <= '0;
				right_press_mask <= 12'h000;
				right_recenter_ctr <= '0;
			end else if (!right_armed) begin
				right_popup_open <= 1'b0;
				right_hold_zone <= RIGHT_NONE;
				right_hold_ctr <= '0;
				right_press_mask <= 12'h000;
				if (right_zone_raw == RIGHT_NONE) begin
					if (right_recenter_ctr >= (RECENTER_CYCLES - 1)) begin
						right_armed <= 1'b1;
						right_recenter_ctr <= '0;
					end else begin
						right_recenter_ctr <= right_recenter_ctr + 1'd1;
					end
				end else begin
					right_recenter_ctr <= '0;
				end
			end else if (!right_popup_open) begin
				right_hold_zone <= RIGHT_NONE;
				right_hold_ctr <= '0;
				right_press_mask <= 12'h000;
				right_recenter_ctr <= '0;
				if (right_zone_raw != RIGHT_NONE) begin
					right_popup_open <= 1'b1;
					right_hold_zone <= right_zone_raw;
					right_hold_ctr <= {{(HOLD_W-1){1'b0}}, 1'b1};
				end
			end else if (right_zone_cur != right_hold_zone) begin
				right_hold_zone <= right_zone_cur;
				right_hold_ctr <= {{(HOLD_W-1){1'b0}}, 1'b1};
				right_press_mask <= 12'h000;
			end else if (right_hold_ctr >= (HOLD_CYCLES - 1)) begin
				right_press_active <= 1'b1;
				right_press_ctr <= '0;
				right_press_mask <= right_zone_mask(right_zone_cur);
				right_popup_open <= 1'b0;
				right_hold_zone <= RIGHT_NONE;
				right_hold_ctr <= '0;
				right_armed <= 1'b0;
				right_recenter_ctr <= '0;
			end else begin
				right_hold_ctr <= right_hold_ctr + 1'd1;
				right_press_mask <= 12'h000;
			end

			if (left_press_active) begin
				if (left_press_ctr >= (PRESS_CYCLES - 1)) begin
					left_press_active <= 1'b0;
					left_press_ctr <= '0;
					left_press_mask <= 12'h000;
				end else begin
					left_press_ctr <= left_press_ctr + 1'd1;
				end
			end else if (!enable) begin
				left_armed <= 1'b1;
				left_popup_open <= 1'b0;
				left_hold_zone <= LEFT_NONE;
				left_hold_ctr <= '0;
				left_press_mask <= 12'h000;
				left_recenter_ctr <= '0;
			end else if (!left_armed) begin
				left_popup_open <= 1'b0;
				left_hold_zone <= LEFT_NONE;
				left_hold_ctr <= '0;
				left_press_mask <= 12'h000;
				if (left_zone_raw == LEFT_NONE) begin
					if (left_recenter_ctr >= (RECENTER_CYCLES - 1)) begin
						left_armed <= 1'b1;
						left_recenter_ctr <= '0;
					end else begin
						left_recenter_ctr <= left_recenter_ctr + 1'd1;
					end
				end else begin
					left_recenter_ctr <= '0;
				end
			end else if (!left_popup_open) begin
				left_hold_zone <= LEFT_NONE;
				left_hold_ctr <= '0;
				left_press_mask <= 12'h000;
				left_recenter_ctr <= '0;
				if (left_zone_raw != LEFT_NONE) begin
					left_popup_open <= 1'b1;
					left_hold_zone <= left_zone_raw;
					left_hold_ctr <= {{(HOLD_W-1){1'b0}}, 1'b1};
				end
			end else if (left_zone_cur != left_hold_zone) begin
				left_hold_zone <= left_zone_cur;
				left_hold_ctr <= {{(HOLD_W-1){1'b0}}, 1'b1};
				left_press_mask <= 12'h000;
			end else if (left_hold_ctr >= (HOLD_CYCLES - 1)) begin
				left_press_active <= 1'b1;
				left_press_ctr <= '0;
				left_press_mask <= left_zone_mask(left_zone_cur);
				left_popup_open <= 1'b0;
				left_hold_zone <= LEFT_NONE;
				left_hold_ctr <= '0;
				left_armed <= 1'b0;
				left_recenter_ctr <= '0;
			end else begin
				left_hold_ctr <= left_hold_ctr + 1'd1;
				left_press_mask <= 12'h000;
			end
		end
	end

	always @* begin : draw_overlay
		int active_w_i;
		int active_h_i;
		int stack_h_i;
		int stack_y_i;
		int right_box_x_i;
		int right_box_y_i;
		int left_box_x_i;
		int left_box_y_i;
		int box_x_i;
		int box_y_i;
		int box_h_i;
		int local_x_i;
		int local_y_i;
		int cell_x_i;
		int cell_y_i;
		int cell_local_x_i;
		int cell_local_y_i;
		int grid_local_x_i;
		int grid_local_y_i;
		int line_v0_i;
		int line_v1_i;
		int line_h0_i;
		int line_h1_i;
		int row_i;
		int col_i;
		int idx_i;
		int glyph_row_i;
		int glyph_col_i;
		logic [7:0] draw_r;
		logic [7:0] draw_g;
		logic [7:0] draw_b;
		logic       in_any_box;
		logic       pixel_drawn;
		logic [7:0] glyph_char;
		logic [7:0] glyph_bits;
		logic       glyph_on;
		logic       in_grid_i;

		out_r = in_r;
		out_g = in_g;
		out_b = in_b;

		draw_r = 8'h00;
		draw_g = 8'h00;
		draw_b = 8'h00;
		in_any_box = 1'b0;
		pixel_drawn = 1'b0;
		glyph_char = 8'h20;
		glyph_bits = 8'h00;
		glyph_on = 1'b0;
		in_grid_i = 1'b0;

		active_w_i = (active_w != 10'd0) ? active_w : DEFAULT_ACTIVE_W;
		active_h_i = (active_h != 10'd0) ? active_h : DEFAULT_ACTIVE_H;
		stack_h_i = (show_right ? BOX_H_RIGHT : 0) + ((show_right && show_left) ? STACK_GAP : 0) + (show_left ? BOX_H_LEFT : 0);
		stack_y_i = (active_h_i - stack_h_i) >> 1;
		right_box_x_i = (active_w_i - BOX_W) >> 1;
		right_box_y_i = stack_y_i;
		left_box_x_i = (active_w_i - BOX_W) >> 1;
		left_box_y_i = stack_y_i + (show_right ? (BOX_H_RIGHT + STACK_GAP) : 0);
		line_v0_i = BOX_PAD + CELL_W;
		line_v1_i = BOX_PAD + (2 * CELL_W) + CELL_GAP;
		line_h0_i = BOX_PAD + CELL_H;
		line_h1_i = BOX_PAD + (2 * CELL_H) + CELL_GAP;

		if (show_right) begin
			box_x_i = right_box_x_i;
			box_y_i = right_box_y_i;
			box_h_i = BOX_H_RIGHT;

			if ((pix_x >= box_x_i) && (pix_x < (box_x_i + BOX_W)) &&
				(pix_y >= box_y_i) && (pix_y < (box_y_i + box_h_i))) begin
				in_any_box = 1'b1;
				local_x_i = pix_x - box_x_i;
				local_y_i = pix_y - box_y_i;
				grid_local_x_i = local_x_i - BOX_PAD;
				grid_local_y_i = local_y_i - BOX_PAD;
				in_grid_i = (grid_local_x_i >= 0) && (grid_local_x_i < RIGHT_GRID_W) &&
				            (grid_local_y_i >= 0) && (grid_local_y_i < RIGHT_GRID_H);

				for (idx_i = 0; idx_i < 9; idx_i = idx_i + 1) begin
					row_i = right_grid_row(idx_i);
					col_i = right_grid_col(idx_i);
					cell_x_i = BOX_PAD + (col_i * (CELL_W + CELL_GAP));
					cell_y_i = BOX_PAD + (row_i * (CELL_H + CELL_GAP));

					if ((local_x_i >= cell_x_i) && (local_x_i < (cell_x_i + CELL_W)) &&
						(local_y_i >= cell_y_i) && (local_y_i < (cell_y_i + CELL_H))) begin
						cell_local_x_i = local_x_i - cell_x_i;
						cell_local_y_i = local_y_i - cell_y_i;

						if (idx_i == right_zone_cur) begin
							draw_r = blend_hot_chan(in_r, 8'h40);
							draw_g = blend_hot_chan(in_g, 8'hD8);
							draw_b = blend_hot_chan(in_b, 8'h50);
							pixel_drawn = 1'b1;
						end

						if ((cell_local_x_i >= GLYPH_X_OFF) &&
							(cell_local_x_i < (GLYPH_X_OFF + GLYPH_W)) &&
							(cell_local_y_i >= GLYPH_Y_OFF) &&
							(cell_local_y_i < (GLYPH_Y_OFF + GLYPH_H))) begin
							glyph_row_i = cell_local_y_i - GLYPH_Y_OFF;
							glyph_col_i = cell_local_x_i - GLYPH_X_OFF;
							glyph_char = right_zone_char(idx_i[3:0]);
							glyph_bits = font_row(glyph_char, glyph_row_i[2:0]);
							glyph_on = glyph_bits[7 - glyph_col_i];
							if (glyph_on) begin
								draw_r = blend_fill_chan(in_r, 8'hFF);
								draw_g = blend_fill_chan(in_g, 8'hFC);
								draw_b = blend_fill_chan(in_b, 8'hE0);
								pixel_drawn = 1'b1;
							end
						end
					end
				end

				if (in_grid_i) begin
					if (((local_x_i >= line_v0_i) && (local_x_i < (line_v0_i + CELL_GAP))) ||
						((local_x_i >= line_v1_i) && (local_x_i < (line_v1_i + CELL_GAP))) ||
						((local_y_i >= line_h0_i) && (local_y_i < (line_h0_i + CELL_GAP))) ||
						((local_y_i >= line_h1_i) && (local_y_i < (line_h1_i + CELL_GAP)))) begin
						draw_r = blend_fill_chan(in_r, 8'hE8);
						draw_g = blend_fill_chan(in_g, 8'hE8);
						draw_b = blend_fill_chan(in_b, 8'hE8);
						pixel_drawn = 1'b1;
					end
				end
			end
		end

		if (show_left) begin
			box_x_i = left_box_x_i;
			box_y_i = left_box_y_i;
			box_h_i = BOX_H_LEFT;

			if ((pix_x >= box_x_i) && (pix_x < (box_x_i + BOX_W)) &&
				(pix_y >= box_y_i) && (pix_y < (box_y_i + box_h_i))) begin
				in_any_box = 1'b1;
				local_x_i = pix_x - box_x_i;
				local_y_i = pix_y - box_y_i;
				grid_local_x_i = local_x_i - BOX_PAD;
				grid_local_y_i = local_y_i - BOX_PAD;
				in_grid_i = (grid_local_x_i >= 0) && (grid_local_x_i < LEFT_GRID_W) &&
				            (grid_local_y_i >= 0) && (grid_local_y_i < LEFT_GRID_H);

				for (idx_i = 0; idx_i < 3; idx_i = idx_i + 1) begin
					cell_x_i = BOX_PAD + (idx_i * (CELL_W + CELL_GAP));
					cell_y_i = BOX_PAD;

					if ((local_x_i >= cell_x_i) && (local_x_i < (cell_x_i + CELL_W)) &&
						(local_y_i >= cell_y_i) && (local_y_i < (cell_y_i + CELL_H))) begin
						cell_local_x_i = local_x_i - cell_x_i;
						cell_local_y_i = local_y_i - cell_y_i;

						if (idx_i[1:0] == left_zone_cur) begin
							draw_r = blend_hot_chan(in_r, 8'h48);
							draw_g = blend_hot_chan(in_g, 8'hA8);
							draw_b = blend_hot_chan(in_b, 8'hF0);
							pixel_drawn = 1'b1;
						end

						if ((cell_local_x_i >= GLYPH_X_OFF) &&
							(cell_local_x_i < (GLYPH_X_OFF + GLYPH_W)) &&
							(cell_local_y_i >= GLYPH_Y_OFF) &&
							(cell_local_y_i < (GLYPH_Y_OFF + GLYPH_H))) begin
							glyph_row_i = cell_local_y_i - GLYPH_Y_OFF;
							glyph_col_i = cell_local_x_i - GLYPH_X_OFF;
							glyph_char = left_zone_char(idx_i[1:0]);
							glyph_bits = font_row(glyph_char, glyph_row_i[2:0]);
							glyph_on = glyph_bits[7 - glyph_col_i];
							if (glyph_on) begin
								draw_r = blend_fill_chan(in_r, 8'hFF);
								draw_g = blend_fill_chan(in_g, 8'hFC);
								draw_b = blend_fill_chan(in_b, 8'hE0);
								pixel_drawn = 1'b1;
							end
						end
					end
				end

				if (in_grid_i) begin
					if (((local_x_i >= line_v0_i) && (local_x_i < (line_v0_i + CELL_GAP))) ||
						((local_x_i >= line_v1_i) && (local_x_i < (line_v1_i + CELL_GAP)))) begin
						draw_r = blend_fill_chan(in_r, 8'hE8);
						draw_g = blend_fill_chan(in_g, 8'hE8);
						draw_b = blend_fill_chan(in_b, 8'hE8);
						pixel_drawn = 1'b1;
					end
				end
			end
		end

		if (in_any_box) begin
			out_r = blend_panel_chan(in_r, 8'h20);
			out_g = blend_panel_chan(in_g, 8'h24);
			out_b = blend_panel_chan(in_b, 8'h30);

			if (pixel_drawn) begin
				out_r = draw_r;
				out_g = draw_g;
				out_b = draw_b;
			end
		end
	end
`else
	assign out_r = in_r;
	assign out_g = in_g;
	assign out_b = in_b;
`endif
endmodule
