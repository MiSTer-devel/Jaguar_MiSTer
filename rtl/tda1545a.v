module tda1545a
#(
	parameter integer SYS_CLK_HZ = 106666667,
	parameter [15:0] NOMINAL_IREF = 16'h8000
)
(
	input               sys_clk,
	input               reset_n,

	// Physical TDA1545A pins.
	input               BCK,   // Pin 1: serial bit clock input.
	input               WS,    // Pin 2: LOW routes data to the right input register, HIGH routes data to the left.
	input               DATA,  // Pin 3: serial audio data input, 16-bit words, MSB first.
	input               GND,   // Pin 4: ground reference.
	input       [15:0]  IREF,  // Pin 7: reference-current programming input. Sets the DAC full-scale current.
	output      [17:0]  IOL,   // Pin 6: left-channel analog current output.
	output      [17:0]  IOR,   // Pin 8: right-channel analog current output.

	// FPGA-facing helper taps.
	output reg signed [15:0] pcm_l,
	output reg signed [15:0] pcm_r,
	output reg          sample_strobe
);

localparam integer SOFT_MUTE_DURATION_US = 8000;
localparam integer SOFT_MUTE_UPDATE_US = 250;
localparam integer SOFT_MUTE_TICK_CLKS = (SYS_CLK_HZ / 1000000) * SOFT_MUTE_UPDATE_US;
localparam integer SOFT_MUTE_STEP_COUNT = SOFT_MUTE_DURATION_US / SOFT_MUTE_UPDATE_US;
localparam integer SOFT_MUTE_STEP = (16'd32768 + SOFT_MUTE_STEP_COUNT - 1) / SOFT_MUTE_STEP_COUNT;

reg bck_state = 1'b0;
reg bck_prev = 1'b0;
reg ws_state = 1'b0;
reg data_state = 1'b0;

reg current_channel = 1'b0;
reg [4:0] bit_count = 5'd0;
reg [15:0] shift_left = 16'h0000;
reg [15:0] shift_right = 16'h0000;
reg left_valid = 1'b0;
reg right_valid = 1'b0;
reg [31:0] soft_mute_ctr = 32'd0;
reg capture_pending = 1'b0;

wire [15:0] iref_eff = (IREF == 16'h0000) ? NOMINAL_IREF : IREF;

wire word_boundary = (ws_state != current_channel);
wire [4:0] capture_index = word_boundary ? 5'd0 : bit_count;
wire [15:0] left_shift_next = {shift_left[14:0], data_state};
wire [15:0] right_shift_next = {shift_right[14:0], data_state};
wire power_good = reset_n & ~GND & (|iref_eff);

function [17:0] sample_to_current;
	input signed [15:0] sample;
	reg [16:0] offset_binary;
	begin
		offset_binary = $signed(sample) + 17'sd32768;
		sample_to_current = {offset_binary[15:0], 2'b00};
	end
endfunction

function signed [15:0] step_toward_zero;
	input signed [15:0] sample;
	begin
		if (sample > $signed(SOFT_MUTE_STEP[15:0]))
			step_toward_zero = sample - $signed(SOFT_MUTE_STEP[15:0]);
		else if (sample < -$signed(SOFT_MUTE_STEP[15:0]))
			step_toward_zero = sample + $signed(SOFT_MUTE_STEP[15:0]);
		else
			step_toward_zero = 16'sd0;
	end
endfunction

assign IOL = power_good ? sample_to_current(pcm_l) : 18'd0;
assign IOR = power_good ? sample_to_current(pcm_r) : 18'd0;

always @(posedge sys_clk) begin
	sample_strobe <= 1'b0;

	if (!power_good) begin
		bck_state <= 1'b0;
		bck_prev <= 1'b0;
		ws_state <= 1'b0;
		data_state <= 1'b0;
		current_channel <= 1'b0;
		bit_count <= 5'd0;
		shift_left <= 16'h0000;
		shift_right <= 16'h0000;
		left_valid <= 1'b0;
		right_valid <= 1'b0;
		capture_pending <= 1'b0;
		// This is an attempt to reduce popping and clicking when we reset.
		if (soft_mute_ctr == SOFT_MUTE_TICK_CLKS - 1) begin
			soft_mute_ctr <= 16'd0;
			pcm_l <= step_toward_zero(pcm_l);
			pcm_r <= step_toward_zero(pcm_r);
		end else begin
			soft_mute_ctr <= soft_mute_ctr + 16'd1;
		end
	end else begin
		soft_mute_ctr <= 16'd0;
		bck_prev <= bck_state;
		bck_state <= BCK;
		ws_state <= WS;
		data_state <= DATA;

		// Delay capture by one sys_clk so WS/DATA settle after the detected BCK edge.
		if (capture_pending) begin
			if (word_boundary) begin
				current_channel <= ws_state;
			end

			// The datasheet describes 16-bit, MSB-first stereo words routed into
			// left/right input registers by the current WS level. Model those
			// registers directly instead of assuming generic I2S LRCLK semantics.
			if (capture_index < 5'd16) begin
				if (ws_state) begin
					shift_left <= left_shift_next;
					if (capture_index == 5'd15) begin
						if (right_valid) begin
							pcm_l <= $signed(left_shift_next);
							pcm_r <= $signed(shift_right);
							sample_strobe <= 1'b1;
							left_valid <= 1'b0;
							right_valid <= 1'b0;
						end else begin
							left_valid <= 1'b1;
						end
					end
				end else begin
					shift_right <= right_shift_next;
					if (capture_index == 5'd15) begin
						if (left_valid) begin
							pcm_l <= $signed(shift_left);
							pcm_r <= $signed(right_shift_next);
							sample_strobe <= 1'b1;
							left_valid <= 1'b0;
							right_valid <= 1'b0;
						end else begin
							right_valid <= 1'b1;
						end
					end
				end

				bit_count <= capture_index + 5'd1;
			end

			capture_pending <= 1'b0;
		end

		// The verified Jaguar hardware path presents DATA stable after BCK falls
		// and retimes WS separately before the DAC, so consume bits on falling
		// edges at the DAC pins.
		if (bck_prev && !bck_state) begin
			capture_pending <= 1'b1;
		end
	end
end

endmodule
