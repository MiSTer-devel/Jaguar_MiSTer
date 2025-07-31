`timescale 1ns / 100ps
/*
 * PS2 mouse protocol
 * Bit       7    6    5    4    3    2    1    0  
 * Byte 0: YOVR XOVR YSGN XSGN   1   MBUT RBUT LBUT
 * Byte 1:                 XMOVE
 * Byte 2:                 YMOVE
 */
/*
 * PS2 Mouse to Atari ST interface module
 * Atari ST uses quadrature encoding for mouse movement
 */
module ps2_mouse
(
    input        clk,         // System clock
    input        ce,          // Clock enable
    input        reset,       // Reset signal
    input  [24:0] ps2_mouse,  // PS/2 mouse data
    output reg [1:0] xout,    // X quadrature output (2 bits)
    output reg [1:0] yout,    // Y quadrature output (2 bits)
    output reg       button_l,// Left button (active low)
    output reg       button_r,// Right button (active low)
    output reg       button_m // Middle button (active low)
);

// Detect incoming PS/2 packet strobe
reg old_stb = 0;
wire strobe = (old_stb != ps2_mouse[24]);
always @(posedge clk) old_stb <= ps2_mouse[24];

// Button state handling (active low for Atari ST)
always @(posedge clk or posedge reset)
    if (reset) begin
        button_l <= 1'b1;  // Inactive (not pressed)
        button_r <= 1'b1;  // Inactive (not pressed)
        button_m <= 1'b1;  // Inactive (not pressed)
    end else if (strobe) begin
        button_l <= ~ps2_mouse[0]; // Invert PS/2 button state
        button_r <= ~ps2_mouse[1]; // Invert PS/2 button state
        button_m <= ~ps2_mouse[2]; // Invert PS/2 button state
    end

// Accumulators and threshold handling
reg [11:0] xaccum = 0;
reg [11:0] yaccum = 0;
wire [7:0] threshold = 8'h10; // Threshold for state changes

// Clock divider for quadrature tick
reg [15:0] clkdiv = 0;
always @(posedge clk or posedge reset)
    if (reset)     clkdiv <= 0;
    else if (ce)   clkdiv <= clkdiv + 1'b1;

wire tick = (ce && clkdiv == 0);

// Extract and process movement data
reg [8:0]  xmov_abs;
reg [8:0]  ymov_abs;
reg        x_direction; // 1 = negative, 0 = positive
reg        y_direction; // 1 = negative, 0 = positive

always @(posedge clk) begin
    if (strobe) begin
        // Direction bits
        x_direction <= ps2_mouse[4]; 
        y_direction <= ps2_mouse[5];
        // Absolute movement
        if (ps2_mouse[4])  xmov_abs <= -$signed(ps2_mouse[15:8]);
        else               xmov_abs <= ps2_mouse[15:8];
        if (ps2_mouse[5])  ymov_abs <= -$signed(ps2_mouse[23:16]);
        else               ymov_abs <= ps2_mouse[23:16];
    end
end

// Alternate stepping flag
reg last_was_x = 0;

// Main accumulator & quadrature generator
always @(posedge clk or posedge reset) begin
    if (reset) begin
        xaccum      <= 0;
        yaccum      <= 0;
        xout        <= 2'b00;
        yout        <= 2'b00;
        last_was_x  <= 0;
    end else begin
        // Accumulate on each new packet
        if (strobe) begin
            xaccum <= xaccum + xmov_abs;
            yaccum <= yaccum + ymov_abs;
        end

        // On each tick, step one or both axes
        if (tick) begin
            // Both axes have pending steps?
            if (xaccum >= threshold && yaccum >= threshold) begin
                if (last_was_x) begin
                    // Step Y
                    case ({y_direction, yout})
                        {1'b1,2'b00}: yout <= 2'b01;
                        {1'b1,2'b01}: yout <= 2'b11;
                        {1'b1,2'b11}: yout <= 2'b10;
                        {1'b1,2'b10}: yout <= 2'b00;
                        {1'b0,2'b00}: yout <= 2'b10;
                        {1'b0,2'b10}: yout <= 2'b11;
                        {1'b0,2'b11}: yout <= 2'b01;
                        {1'b0,2'b01}: yout <= 2'b00;
                    endcase
                    yaccum     <= yaccum - threshold;
                    last_was_x <= 0;
                end else begin
                    // Step X
                    case ({x_direction, xout})
                        {1'b1,2'b00}: xout <= 2'b01;
                        {1'b1,2'b01}: xout <= 2'b11;
                        {1'b1,2'b11}: xout <= 2'b10;
                        {1'b1,2'b10}: xout <= 2'b00;
                        {1'b0,2'b00}: xout <= 2'b10;
                        {1'b0,2'b10}: xout <= 2'b11;
                        {1'b0,2'b11}: xout <= 2'b01;
                        {1'b0,2'b01}: xout <= 2'b00;
                    endcase
                    xaccum     <= xaccum - threshold;
                    last_was_x <= 1;
                end
            end
            // Only X pending
            else if (xaccum >= threshold) begin
                case ({x_direction, xout})
                    {1'b1,2'b00}: xout <= 2'b01;
                    {1'b1,2'b01}: xout <= 2'b11;
                    {1'b1,2'b11}: xout <= 2'b10;
                    {1'b1,2'b10}: xout <= 2'b00;
                    {1'b0,2'b00}: xout <= 2'b10;
                    {1'b0,2'b10}: xout <= 2'b11;
                    {1'b0,2'b11}: xout <= 2'b01;
                    {1'b0,2'b01}: xout <= 2'b00;
                endcase
                xaccum     <= xaccum - threshold;
                last_was_x <= 1;
            end
            // Only Y pending
            else if (yaccum >= threshold) begin
                case ({y_direction, yout})
                    {1'b1,2'b00}: yout <= 2'b01;
                    {1'b1,2'b01}: yout <= 2'b11;
                    {1'b1,2'b11}: yout <= 2'b10;
                    {1'b1,2'b10}: yout <= 2'b00;
                    {1'b0,2'b00}: yout <= 2'b10;
                    {1'b0,2'b10}: yout <= 2'b11;
                    {1'b0,2'b11}: yout <= 2'b01;
                    {1'b0,2'b01}: yout <= 2'b00;
                endcase
                yaccum     <= yaccum - threshold;
                last_was_x <= 0;
            end
        end
    end
end

endmodule
