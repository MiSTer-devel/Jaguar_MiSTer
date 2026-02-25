// jaguar_lightgun.sv – Integrated lightgun with crosshair overlay
module jaguar_lightgun (
	input  logic        clk,           // xvclk
	input  logic        ce,            // clock enable
	input  logic        reset,         // active-high
	input  logic        ntsc,          // 1=NTSC, 0=PAL

	// PS/2 mouse: [24]=pkt, [15:8]=dx, [23:16]=dy
	input  logic [24:0] ps2_mouse,

	// Analog joystick (0..255), ~128 center
	input  logic [7:0]  joy_x,
	input  logic [7:0]  joy_y,
	input  logic        use_joystick,  // 0 = mouse, 1 = joystick

	input  logic        enable,        // module enable
	input  logic        port_select,   // 0->LP0, 1->LP1
	input  logic [1:0]  crosshair_mode,// 0=small, 1=big, 2=medium, 3=off

	// Beam position (video domain)
	input  logic [11:0] cycle,         // beam_x in VIDEO CLOCKS (PWIDTH4)
	input  logic [9:0]  scanline,      // beam_y in lines
	input  logic        vsync,         // active-high
	input  logic        blank,         // 1=blanking (not active video)

	// Outputs
	output logic        lp0,
	output logic        lp1,
	output logic        draw_crosshair // crosshair overlay signal
);

	// ---- Tunables ----
	parameter int  WINDOW_PIX   = 10;  // +/- pixels around reticle
	parameter int  PULSE_CLKS   = 64;  // LP pulse width in xvclk cycles
	parameter int  X_SKEW_PIX   = -37; // + right,  - left
	parameter int  Y_SKEW_PIX   = 11;  // + down,   - up
	parameter int  JOY_DEADZONE = 16;  // +/- from center for snap-back

	// ---- Constants ----
	localparam int FB_W        = 320;
	localparam int FB_H        = 240;
	localparam int HDB_CLOCKS  = 120;
	localparam int X_FUDGE     = 195;
	localparam int NTSC_HP     = 286;
	localparam int PAL_HP      = 341;
	localparam logic signed [31:0] X_SKEW_PIX_S32 = X_SKEW_PIX;
	localparam logic signed [31:0] Y_SKEW_PIX_S32 = Y_SKEW_PIX;
	localparam logic signed [31:0] WINDOW_PIX_S32 = WINDOW_PIX;
	localparam logic signed [11:0] X_SKEW = X_SKEW_PIX_S32[11:0];
	localparam logic signed [11:0] Y_SKEW = Y_SKEW_PIX_S32[11:0];
	localparam logic signed [11:0] WINDOW_PIX_S = WINDOW_PIX_S32[11:0];

	// Constant-divide helpers implemented as reciprocal shift/add.
	// div204_fast/div240_fast are exact in this design's operand ranges.
	// div273_fast is a close approximation (max error 1 LSB over 0..65280).
	function automatic [17:0] div204_fast(input [17:0] x);
		logic [31:0] acc;
		begin
			// floor(x/204) == floor((x*5140 + 5140) >> 20) for x in [0..65280]
			acc = ({14'd0, x} << 12) + ({14'd0, x} << 10) + ({14'd0, x} << 4) + ({14'd0, x} << 2) + 32'd5140;
			div204_fast = acc[31:20];
		end
	endfunction

	function automatic [15:0] div273_fast(input [15:0] x);
		logic [31:0] acc;
		begin
			// approx floor(x/273) ~= floor((x*3841) >> 20), 3841=2^11+2^10+2^9+2^8+1
			acc = ({16'd0, x} << 11) + ({16'd0, x} << 10) + ({16'd0, x} << 9) + ({16'd0, x} << 8) + {16'd0, x};
			div273_fast = acc[31:20];
		end
	endfunction

	function automatic [17:0] div240_fast(input [17:0] x);
		logic [31:0] acc;
		begin
			// floor(x/240) == floor((x*4369 + 4096) >> 20) for x in [0..57480]
			acc = ({14'd0, x} << 12) + ({14'd0, x} << 8) + ({14'd0, x} << 4) + {14'd0, x} + 32'd4096;
			div240_fast = acc[31:20];
		end
	endfunction

	wire [9:0] HP = ntsc ? 10'd286 : 10'd341;

	// ===== CDC: sync inputs into xvclk =====
	logic [24:0] pm_s1, pm_s2;
	logic [7:0] joy_x_s1, joy_x_s2;
	logic [7:0] joy_y_s1, joy_y_s2;
	logic use_joystick_s1, use_joystick_s2;

	always_ff @(posedge clk) if (ce) begin
		// PS/2 Mouse
		pm_s1 <= ps2_mouse;
		pm_s2 <= pm_s1;
		// Joystick
		joy_x_s1 <= joy_x;
		joy_x_s2 <= joy_x_s1;
		joy_y_s1 <= joy_y;
		joy_y_s2 <= joy_y_s1;
		use_joystick_s1 <= use_joystick;
		use_joystick_s2 <= use_joystick_s1;
	end

	// Edge detection
	logic prev_pkt, prev_vsync, prev_blank;
	always_ff @(posedge clk) if (ce) begin
		prev_pkt   <= pm_s2[24];
		prev_vsync <= vsync;
		prev_blank <= blank;
	end

	wire pkt_rise   =  pm_s2[24] & ~prev_pkt;
	wire vsync_rise =  vsync     & ~prev_vsync;
	wire blank_fall =  prev_blank & ~blank; // 1->0
	wire blank_rise = ~prev_blank &  blank; // 0->1

	// Signed mouse deltas
	wire signed [7:0] dx8 = pm_s2[15:8];
	wire signed [7:0] dy8 = pm_s2[23:16];
	wire signed [9:0] dx  = { {2{dx8[7]}}, dx8 };
	wire signed [9:0] dy  = { {2{dy8[7]}}, dy8 };

	// ===== Reticle Position Calculation =====
	logic [9:0] ret_x_int, ret_y_int;

	// --- Joystick position mapping (clocked) ---
	logic [17:0] joy_pos_x_w_q;
	logic [15:0] joy_pos_y_w_q;
	wire [9:0] joy_pos_x_q = joy_pos_x_w_q[9:0];
	wire [9:0] joy_pos_y_q = joy_pos_y_w_q[9:0];

	// Deadzone check
	wire joy_in_deadzone = (joy_x_s2 > (128 - JOY_DEADZONE)) && (joy_x_s2 < (128 + JOY_DEADZONE)) &&
						(joy_y_s2 > (128 - JOY_DEADZONE)) && (joy_y_s2 < (128 + JOY_DEADZONE));

	// --- Mouse position integration ---
	wire signed [10:0] nx_w     = $signed({1'b0,ret_x_int}) + dx;
	wire signed [9:0]  dy_eff_w = -dy;
	wire signed [10:0] ny_w     = $signed({1'b0,ret_y_int}) + dy_eff_w;

	always_ff @(posedge clk) if (ce) begin
		// Clock heavy constant-divide joystick scaling.
		joy_pos_x_w_q <= div204_fast({2'b0, joy_x_s2, 8'd0}) + 18'd3;
		joy_pos_y_w_q <= div273_fast({joy_y_s2, 8'd0});

		if (reset) begin
			ret_x_int <= 10'd160;
			ret_y_int <= 10'd120;
		end else if (use_joystick_s2) begin
			// --- Joystick Logic ---
			if (joy_in_deadzone) begin
				ret_x_int <= 10'd160;
				ret_y_int <= 10'd120;
			end else begin
				ret_x_int <= joy_pos_x_q;
				ret_y_int <= joy_pos_y_q;
			end
		end else if (pkt_rise) begin
			// --- Mouse Logic ---
			// X clamp
			if (nx_w < 0)                 ret_x_int <= 10'd0;
			else if (nx_w > 10'd319)      ret_x_int <= 10'd319;
			else                          ret_x_int <= nx_w[9:0];
			// Y clamp
			if (ny_w < 0)                 ret_y_int <= 10'd0;
			else if (ny_w > 10'd239)      ret_y_int <= 10'd239;
			else                          ret_y_int <= ny_w[9:0];
		end
	end

	// ===== Measure active Y window each frame =====
	logic        y_top_latched, y_bot_latched;
	logic [9:0]  y_top_line, y_bot_line;

	always_ff @(posedge clk) if (ce) begin
		if (reset || vsync_rise) begin
			y_top_latched <= 1'b0;
			y_bot_latched <= 1'b0;
			y_top_line    <= 10'd0;
			y_bot_line    <= 10'd239;
		end else begin
			// Top: first 1->0 of blank anywhere in frame
			if (!y_top_latched && blank_fall) begin
				y_top_line    <= scanline;
				y_top_latched <= 1'b1;
			end
			// Bottom: first 0->1 of blank after top
			if (y_top_latched && !y_bot_latched && blank_rise) begin
				y_bot_line    <= (scanline == 10'd0) ? 10'd0 : (scanline - 10'd1);
				y_bot_latched <= 1'b1;
			end
		end
	end

	// Active height (clamped 1..240)
	wire [9:0] active_h_raw = (y_bot_line > y_top_line) ? (y_bot_line - y_top_line + 10'd1) : 10'd240;
	wire [9:0] active_h     = (active_h_raw > 10'd240) ? 10'd240 : active_h_raw;

	// ===== Screen-space mapping for hit test =====
	wire [9:0] pix_x = cycle[11:2]; // 0..511 (PWIDTH4)
	wire [9:0] pix_y = scanline;     // 0..511

	// X origin in clocks
	wire signed [15:0] halfgap4  = $signed({1'b0,HP}) - 16'sd640;
	wire signed [15:0] xoff4     = 16'sd120 + halfgap4 - 16'sd195;

	// Hit window pipeline for timing closure.
	// Signals are sampled on CE, then processed across the 3 non-CE clocks.
	logic hit_vld_s0, hit_vld_s1, hit_vld_s2, hit_vld_s3;
	logic [9:0] hit_pix_x_s0, hit_pix_y_s0;
	logic [9:0] hit_ret_x_s0, hit_ret_y_s0;
	logic [9:0] hit_top_s0, hit_active_h_s0;

	logic [9:0] hit_pix_x_s1, hit_pix_y_s1;
	logic [9:0] hit_top_s1, hit_active_h_s1;
	logic signed [15:0] hit_scr_x_clk_s1;
	logic [17:0] hit_mult_y_s1;

	logic [9:0] hit_pix_x_s2, hit_pix_y_s2;
	logic [9:0] hit_top_s2, hit_active_h_s2;
	logic [9:0] hit_cx_s2;
	logic [17:0] hit_y_scaled_div_s2;

	wire [9:0] hit_y_scaled_pre = hit_y_scaled_div_s2[9:0];
	wire [9:0] hit_y_scaled = (hit_y_scaled_pre >= hit_active_h_s2) ? (hit_active_h_s2 - 10'd1) : hit_y_scaled_pre;
	wire [10:0] hit_cy_raw = {1'b0, hit_top_s2} + {1'b0, hit_y_scaled};
	wire [9:0] hit_cy = (hit_cy_raw > 11'd511) ? 10'd511 : hit_cy_raw[9:0];
	wire signed [11:0] hit_px_skew = $signed({1'b0, hit_pix_x_s2}) + X_SKEW;
	wire signed [11:0] hit_py_skew = $signed({1'b0, hit_pix_y_s2}) + Y_SKEW;
	wire hit_in_window_comb =
		(hit_px_skew >= $signed({1'b0, hit_cx_s2}) - WINDOW_PIX_S) &&
		(hit_px_skew <= $signed({1'b0, hit_cx_s2}) + WINDOW_PIX_S) &&
		(hit_py_skew >= $signed({1'b0, hit_cy}) - WINDOW_PIX_S) &&
		(hit_py_skew <= $signed({1'b0, hit_cy}) + WINDOW_PIX_S);

	logic hit_in_window_s3;
	logic in_window_q;
	logic [9:0] cx_q, cy_q;

	always_ff @(posedge clk) begin
		if (reset) begin
			hit_vld_s0 <= 1'b0;
			hit_vld_s1 <= 1'b0;
			hit_vld_s2 <= 1'b0;
			hit_vld_s3 <= 1'b0;
			hit_in_window_s3 <= 1'b0;
			in_window_q <= 1'b0;
			cx_q <= 10'd160;
			cy_q <= 10'd120;
		end else begin
			// Stage 0: sample at pixel cadence.
			hit_vld_s0 <= ce;
			if (ce) begin
				hit_pix_x_s0 <= pix_x;
				hit_pix_y_s0 <= pix_y;
				hit_ret_x_s0 <= ret_x_int;
				hit_ret_y_s0 <= ret_y_int;
				hit_top_s0 <= y_top_line;
				hit_active_h_s0 <= active_h;
			end

			// Stage 1: multiplication and X clock-space conversion.
			hit_vld_s1 <= hit_vld_s0;
			if (hit_vld_s0) begin
				hit_pix_x_s1 <= hit_pix_x_s0;
				hit_pix_y_s1 <= hit_pix_y_s0;
				hit_top_s1 <= hit_top_s0;
				hit_active_h_s1 <= hit_active_h_s0;
				hit_mult_y_s1 <= {8'd0, hit_ret_y_s0} * {8'd0, hit_active_h_s0};
				hit_scr_x_clk_s1 <= ($signed({1'b0, hit_ret_x_s0}) <<< 2) + xoff4;
			end

			// Stage 2: divide and X clamp.
			hit_vld_s2 <= hit_vld_s1;
			if (hit_vld_s1) begin
				hit_pix_x_s2 <= hit_pix_x_s1;
				hit_pix_y_s2 <= hit_pix_y_s1;
				hit_top_s2 <= hit_top_s1;
				hit_active_h_s2 <= hit_active_h_s1;
				hit_y_scaled_div_s2 <= div240_fast(hit_mult_y_s1 + 18'd120);
				if (hit_scr_x_clk_s1 < 0) hit_cx_s2 <= 10'd0;
				else if (hit_scr_x_clk_s1 > 16'sd511) hit_cx_s2 <= 10'd511;
				else hit_cx_s2 <= hit_scr_x_clk_s1[9:0];
			end

			// Stage 3: final compare; hold latest window state for CE pulse logic.
			hit_vld_s3 <= hit_vld_s2;
			if (hit_vld_s2) begin
				hit_in_window_s3 <= hit_in_window_comb;
				cx_q <= hit_cx_s2;
				cy_q <= hit_cy;
			end
			if (hit_vld_s3) in_window_q <= hit_in_window_s3;
		end
	end

	// ===== Pulse generator =====
	localparam int PULSEW = (PULSE_CLKS <= 1) ? 1 : $clog2(PULSE_CLKS);
	localparam logic [31:0] PULSE_CLKS_U32 = PULSE_CLKS;
	localparam logic [PULSEW-1:0] PULSE_CLKS_M1 = (PULSE_CLKS_U32 == 0) ? '0 : (PULSE_CLKS_U32[PULSEW-1:0] - 1'b1);
	logic            pulse_active;
	logic [PULSEW-1:0] pulse_cnt;

	wire pulse_start = enable & in_window_q & ~pulse_active;

	always_ff @(posedge clk) if (ce) begin
		if (reset) begin
			pulse_active <= 1'b0;
			pulse_cnt    <= '0;
			lp0          <= 1'b0;
			lp1          <= 1'b0;
		end else begin
			lp0 <= 1'b0; lp1 <= 1'b0;
			if (pulse_start) begin
				pulse_active <= 1'b1;
				pulse_cnt    <= PULSE_CLKS_M1;
			end else if (pulse_active) begin
				if (pulse_cnt != '0) pulse_cnt <= pulse_cnt - 1'b1;
				else                  pulse_active <= 1'b0;
			end

			if (pulse_active) begin
				if (port_select == 1'b0) lp0 <= 1'b1;
				else                     lp1 <= 1'b1;
			end
		end
	end

	// ===== Integrated Crosshair Overlay =====
	wire active_video = ~blank;

	// Crosshair half-length based on mode
	wire [9:0] crosshair_size =
		(crosshair_mode == 2'd0) ? 10'd2   : // Small
		(crosshair_mode == 2'd1) ? 10'd16  : // Medium
		(crosshair_mode == 2'd2) ? 10'd160 : // Big
								   10'd0;    // Off

	// Calculate absolute deltas to avoid underflow
	wire [9:0] dx_abs = (pix_x >= cx_q) ? (pix_x - cx_q) : (cx_q - pix_x);
	wire [9:0] dy_abs = (pix_y >= cy_q) ? (pix_y - cy_q) : (cy_q - pix_y);

	// Draw crosshair lines
	wire draw_h = active_video && (dy_abs <= 10'd0) && (dx_abs <= crosshair_size);
	wire draw_v = active_video && (dx_abs <= 10'd0) && (dy_abs <= crosshair_size);

	assign draw_crosshair = enable && (crosshair_mode != 2'd3) && (draw_h | draw_v);

endmodule
