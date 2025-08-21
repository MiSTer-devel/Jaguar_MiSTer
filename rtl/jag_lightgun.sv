// jaguar_lightgun.sv – Integrated lightgun with crosshair overlay
module jaguar_lightgun (
    input  logic        clk,           // xvclk
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
    
    wire [9:0] HP = ntsc ? NTSC_HP : PAL_HP;

    // ===== CDC: sync inputs into xvclk =====
    logic [24:0] pm_s1, pm_s2;
    logic [7:0] joy_x_s1, joy_x_s2;
    logic [7:0] joy_y_s1, joy_y_s2;
    logic use_joystick_s1, use_joystick_s2;

    always_ff @(posedge clk) begin
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
    always_ff @(posedge clk) begin
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

    // --- Joystick position mapping ---
    wire [17:0] scaled_jx = {2'b0, joy_x_s2, 8'd0}; // joy_x * 256
    wire [9:0]  joy_pos_x = (scaled_jx / 204) + 3;
    
    wire [15:0] scaled_jy = {joy_y_s2, 8'd0}; // joy_y * 256
    wire [9:0]  joy_pos_y = scaled_jy / 273;

    // Deadzone check
    wire joy_in_deadzone = (joy_x_s2 > (128 - JOY_DEADZONE)) && (joy_x_s2 < (128 + JOY_DEADZONE)) &&
                           (joy_y_s2 > (128 - JOY_DEADZONE)) && (joy_y_s2 < (128 + JOY_DEADZONE));

    // --- Mouse position integration ---
    wire signed [10:0] nx_w     = $signed({1'b0,ret_x_int}) + dx;
    wire signed [9:0]  dy_eff_w = -dy;
    wire signed [10:0] ny_w     = $signed({1'b0,ret_y_int}) + dy_eff_w;

    always_ff @(posedge clk) begin
        if (reset) begin
            ret_x_int <= FB_W >> 1; // 160
            ret_y_int <= FB_H >> 1; // 120
        end else if (use_joystick_s2) begin
            // --- Joystick Logic ---
            if (joy_in_deadzone) begin
                ret_x_int <= FB_W >> 1;
                ret_y_int <= FB_H >> 1;
            end else begin
                ret_x_int <= joy_pos_x;
                ret_y_int <= joy_pos_y;
            end
        end else if (pkt_rise) begin
            // --- Mouse Logic ---
            // X clamp
            if (nx_w < 0)                 ret_x_int <= 10'd0;
            else if (nx_w > FB_W-1)       ret_x_int <= FB_W-1;
            else                          ret_x_int <= nx_w[9:0];
            // Y clamp
            if (ny_w < 0)                 ret_y_int <= 10'd0;
            else if (ny_w > FB_H-1)       ret_y_int <= FB_H-1;
            else                          ret_y_int <= ny_w[9:0];
        end
    end

    // ===== Measure active Y window each frame =====
    logic        y_top_latched, y_bot_latched;
    logic [9:0]  y_top_line, y_bot_line;

    always_ff @(posedge clk) begin
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

    // ===== Map ret_y_int (0..239) -> 0..active_h-1 (rounded) =====
    wire [17:0] mult_y       = {8'd0, ret_y_int} * {8'd0, active_h};
    wire [17:0] add_y        = mult_y + 18'd120; // +FB_H/2 for rounding
    wire [9:0]  y_scaled_pre = add_y / 10'd240;
    wire [9:0]  y_scaled     = (y_scaled_pre >= active_h) ? (active_h - 10'd1) : y_scaled_pre;

    // ===== Screen-space mapping for hit test =====
    wire [9:0] pix_x = cycle   >> 2; // 0..511 (PWIDTH4)
    wire [9:0] pix_y = scanline;     // 0..511

    // X origin in clocks
    wire signed [15:0] halfgap4  = ( $signed({1'b0,HP}) * 2 - (FB_W * 4) ) >>> 1;
    wire signed [15:0] xoff4     = $signed(HDB_CLOCKS) + halfgap4 - $signed(X_FUDGE);
    wire signed [15:0] ret_x_clk = $signed({1'b0,ret_x_int}) <<< 2; // *4
    wire signed [15:0] scr_x_clk = ret_x_clk + xoff4;

    // Clamp to screen pixels for center
    wire [9:0] cx = (scr_x_clk < 0)         ? 10'd0   :
                    (scr_x_clk > 16'sd511)  ? 10'd511 : scr_x_clk[9:0];

    // Y: top of visible + scaled
    wire [10:0] cy_raw = {1'b0, y_top_line} + {1'b0, y_scaled};
    wire [9:0]  cy     = (cy_raw > 11'd511) ? 10'd511 : cy_raw[9:0];

    // Apply pixel skews for window compare
    wire signed [11:0] px_skew = $signed({1'b0,pix_x}) + $signed(X_SKEW_PIX);
    wire signed [11:0] py_skew = $signed({1'b0,pix_y}) + $signed(Y_SKEW_PIX);

    // Hit window (continuous tracking)
    wire in_window =
        (px_skew >= $signed({1'b0,cx}) - $signed(WINDOW_PIX)) &&
        (px_skew <= $signed({1'b0,cx}) + $signed(WINDOW_PIX)) &&
        (py_skew >= $signed({1'b0,cy}) - $signed(WINDOW_PIX)) &&
        (py_skew <= $signed({1'b0,cy}) + $signed(WINDOW_PIX));

    // ===== Pulse generator =====
    localparam int PULSEW = (PULSE_CLKS <= 1) ? 1 : $clog2(PULSE_CLKS);
    logic            pulse_active;
    logic [PULSEW-1:0] pulse_cnt;

    wire pulse_start = enable & in_window & ~pulse_active;

    always_ff @(posedge clk) begin
        if (reset) begin
            pulse_active <= 1'b0;
            pulse_cnt    <= '0;
            lp0          <= 1'b0;
            lp1          <= 1'b0;
        end else begin
            lp0 <= 1'b0; lp1 <= 1'b0;
            if (pulse_start) begin
                pulse_active <= 1'b1;
                pulse_cnt    <= (PULSE_CLKS > 0) ? PULSE_CLKS-1 : '0;
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
    wire [9:0] dx_abs = (pix_x >= cx) ? (pix_x - cx) : (cx - pix_x);
    wire [9:0] dy_abs = (pix_y >= cy) ? (pix_y - cy) : (cy - pix_y);

    // Draw crosshair lines
    wire draw_h = active_video && (dy_abs <= 10'd0) && (dx_abs <= crosshair_size);
    wire draw_v = active_video && (dx_abs <= 10'd0) && (dy_abs <= crosshair_size);
    
    assign draw_crosshair = enable && (crosshair_mode != 2'd3) && (draw_h | draw_v);

endmodule