// Automatic CRT aspect ratio calculation for MiSTer cores by Kitrinx


`define AR_TEST

module auto_crt_ar
#(
	// DEFAULT_ARX/DEFAULT_ARY preserve the previous hand-tuned Jaguar fallback
	// ratio until the live timing measurements settle.
	//
	// The visible-aperture parameters are rational approximations of how much of
	// a real analog raster is picture rather than blanked time:
	// - NTSC horizontal visible fraction ~= 52.6us / 63.556us ~= 0.828
	//   encoded as 53/64.
	// - NTSC vertical visible fraction ~= 240 / 262.5 ~= 0.914
	//   encoded as 32/35.
	// - PAL horizontal visible fraction ~= 52.0us / 64.0us = 0.8125
	//   encoded as 13/16.
	// - PAL vertical visible fraction ~= 288 / 312.5 ~= 0.922
	//   encoded as 59/64.
	//
	// These feed the aspect model:
	//   DAR = (4/3)
	//       * (active_clocks / total_clocks)
	//       * (total_lines / active_lines)
	//       * (HVIS_DEN / HVIS_NUM)
	//       * (VVIS_NUM / VVIS_DEN)
	//
	// which is rearranged to an integer ARX:ARY pair:
	//   ARX ~ active_clocks * total_lines  * 4 * HVIS_DEN * VVIS_NUM
	//   ARY ~ total_clocks  * active_lines * 3 * HVIS_NUM * VVIS_DEN
	parameter [11:0] DEFAULT_ARX   = 12'd2896,
	parameter [11:0] DEFAULT_ARY   = 12'd2040,
	parameter [7:0]  NTSC_HVIS_NUM = 8'd53,
	parameter [7:0]  NTSC_HVIS_DEN = 8'd64,
	parameter [7:0]  NTSC_VVIS_NUM = 8'd32,
	parameter [7:0]  NTSC_VVIS_DEN = 8'd35,
	parameter [7:0]  PAL_HVIS_NUM  = 8'd13,
	parameter [7:0]  PAL_HVIS_DEN  = 8'd16,
	parameter [7:0]  PAL_VVIS_NUM  = 8'd59,
	parameter [7:0]  PAL_VVIS_DEN  = 8'd64
)
(
	input         clk_sys,
	input         reset,
	input         ce_pix,
	input         ntsc,
	input         hsync,
	input         vsync,
	input         hblank,
	input         vblank,
	output [11:0] arx,
	output [11:0] ary
);

// This block models the cropped picture inside the full CRT raster.
// Horizontal size on a CRT is set by beam-on time within the real line time,
// not just by the number of active pixels. Likewise vertical size depends on
// active lines within the real frame cadence. We therefore measure both:
//
// - total clocks/line and total lines/frame
// - active clocks/line and active lines/frame
//
// and compare those fractions against nominal NTSC/PAL visible-aperture
// constants. The output is a MiSTer ARX:ARY ratio only; no division operator is
// used. The ratio is normalized with shifts to maximize 12-bit precision.
`ifndef AR_TEST
assign arx = DEFAULT_ARX;
assign ary = DEFAULT_ARY;
`else

reg        prev_hsync = 1'b0;
reg        prev_vsync = 1'b0;
reg        prev_ntsc  = 1'b0;
reg        aspect_valid = 1'b0;
reg [11:0] arx_reg = DEFAULT_ARX;
reg [11:0] ary_reg = DEFAULT_ARY;

reg [11:0] line_total      = 12'd0;
reg [11:0] line_active     = 12'd0;
reg [11:0] frame_htotal    = 12'd0;
reg [11:0] frame_hactive   = 12'd0;
reg [11:0] frame_vtotal    = 12'd0;
reg [11:0] frame_vactive   = 12'd0;

reg [11:0] filt_htotal     = 12'd0;
reg [11:0] filt_hactive    = 12'd0;
reg [11:0] filt_vtotal     = 12'd0;
reg [11:0] filt_vactive    = 12'd0;

reg        calc_pending    = 1'b0;
reg [11:0] req_htotal      = 12'd0;
reg [11:0] req_hactive     = 12'd0;
reg [11:0] req_vtotal      = 12'd0;
reg [11:0] req_vactive     = 12'd0;
reg [15:0] req_num_scale   = 16'd0;
reg [15:0] req_den_scale   = 16'd0;

reg [3:0]  calc_state      = 4'd0;
reg [23:0] base_arx        = 24'd0;
reg [23:0] base_ary        = 24'd0;
reg [47:0] work_num        = 48'd0;
reg [47:0] work_den        = 48'd0;
reg [47:0] mul_acc         = 48'd0;
reg [47:0] mul_multiplicand= 48'd0;
reg [15:0] mul_multiplier  = 16'd0;
reg [5:0]  mul_count       = 6'd0;

wire hs_rise = hsync & ~prev_hsync;
wire vs_rise = vsync & ~prev_vsync;
wire pix_active = ~hblank & ~vblank;

// Pre-fold the constant terms from the parameterized CRT model:
//   ar_num_scale = 4 * HVIS_DEN * VVIS_NUM
//   ar_den_scale = 3 * HVIS_NUM * VVIS_DEN
wire [15:0] ar_num_scale = ntsc ? 16'd8192 : 16'd3776;
wire [15:0] ar_den_scale = ntsc ? 16'd5565 : 16'd2496;
wire [11:0] next_filt_htotal  = aspect_valid ? smooth_u12(filt_htotal,  frame_htotal)  : frame_htotal;
wire [11:0] next_filt_hactive = aspect_valid ? smooth_u12(filt_hactive, frame_hactive) : frame_hactive;
wire [11:0] next_filt_vtotal  = aspect_valid ? smooth_u12(filt_vtotal,  frame_vtotal)  : frame_vtotal;
wire [11:0] next_filt_vactive = aspect_valid ? smooth_u12(filt_vactive, frame_vactive) : frame_vactive;
wire [47:0] mul_sum = mul_acc + (mul_multiplier[0] ? mul_multiplicand : 48'd0);

localparam [3:0] CALC_IDLE        = 4'd0;
localparam [3:0] CALC_MUL_BASE_X  = 4'd1;
localparam [3:0] CALC_MUL_BASE_Y  = 4'd2;
localparam [3:0] CALC_MUL_SCALE_X = 4'd3;
localparam [3:0] CALC_MUL_SCALE_Y = 4'd4;
localparam [3:0] CALC_REDUCE_TWOS = 4'd5;
localparam [3:0] CALC_SHRINK      = 4'd6;
localparam [3:0] CALC_FIX_ZERO    = 4'd7;
localparam [3:0] CALC_GROW        = 4'd8;
localparam [3:0] CALC_DONE        = 4'd9;

assign arx = aspect_valid ? arx_reg : DEFAULT_ARX;
assign ary = aspect_valid ? ary_reg : DEFAULT_ARY;

function automatic [11:0] smooth_u12;
	input [11:0] cur;
	input [11:0] meas;
	reg signed [12:0] delta;
	reg signed [12:0] step;
	reg signed [13:0] next_value;
begin
	delta = $signed({1'b0, meas}) - $signed({1'b0, cur});
	step = delta >>> 2;

	if (!step && delta) begin
		step = delta[12] ? -13'sd1 : 13'sd1;
	end

	next_value = $signed({1'b0, cur}) + $signed(step);
	if (next_value < 0) begin
		smooth_u12 = 12'd0;
	end else if (next_value > 14'sd4095) begin
		smooth_u12 = 12'd4095;
	end else begin
		smooth_u12 = next_value[11:0];
	end
end
endfunction

always @(posedge clk_sys) begin
	if (reset) begin
		prev_hsync   <= 1'b0;
		prev_vsync   <= 1'b0;
		prev_ntsc    <= ntsc;
		aspect_valid <= 1'b0;
		arx_reg      <= DEFAULT_ARX;
		ary_reg      <= DEFAULT_ARY;

		line_total   <= 12'd0;
		line_active  <= 12'd0;
		frame_htotal <= 12'd0;
		frame_hactive<= 12'd0;
		frame_vtotal <= 12'd0;
		frame_vactive<= 12'd0;

		filt_htotal  <= 12'd0;
		filt_hactive <= 12'd0;
		filt_vtotal  <= 12'd0;
		filt_vactive <= 12'd0;

		calc_pending <= 1'b0;
		req_htotal   <= 12'd0;
		req_hactive  <= 12'd0;
		req_vtotal   <= 12'd0;
		req_vactive  <= 12'd0;
		req_num_scale<= 16'd0;
		req_den_scale<= 16'd0;

		calc_state   <= CALC_IDLE;
		base_arx     <= 24'd0;
		base_ary     <= 24'd0;
		work_num     <= 48'd0;
		work_den     <= 48'd0;
		mul_acc      <= 48'd0;
		mul_multiplicand <= 48'd0;
		mul_multiplier   <= 16'd0;
		mul_count    <= 6'd0;
	end else if (prev_ntsc != ntsc) begin
		prev_ntsc    <= ntsc;
		aspect_valid <= 1'b0;
		arx_reg      <= DEFAULT_ARX;
		ary_reg      <= DEFAULT_ARY;

		line_total   <= 12'd0;
		line_active  <= 12'd0;
		frame_htotal <= 12'd0;
		frame_hactive<= 12'd0;
		frame_vtotal <= 12'd0;
		frame_vactive<= 12'd0;

		filt_htotal  <= 12'd0;
		filt_hactive <= 12'd0;
		filt_vtotal  <= 12'd0;
		filt_vactive <= 12'd0;
		calc_pending <= 1'b0;
		req_htotal   <= 12'd0;
		req_hactive  <= 12'd0;
		req_vtotal   <= 12'd0;
		req_vactive  <= 12'd0;
		req_num_scale<= 16'd0;
		req_den_scale<= 16'd0;

		calc_state   <= CALC_IDLE;
		base_arx     <= 24'd0;
		base_ary     <= 24'd0;
		work_num     <= 48'd0;
		work_den     <= 48'd0;
		mul_acc      <= 48'd0;
		mul_multiplicand <= 48'd0;
		mul_multiplier   <= 16'd0;
		mul_count    <= 6'd0;
	end else begin
		if (ce_pix) begin
			prev_hsync <= hsync;
			prev_vsync <= vsync;

			if (hs_rise) begin
				if (line_total > frame_htotal) frame_htotal <= line_total;
				if (line_active > frame_hactive) frame_hactive <= line_active;
				frame_vtotal <= frame_vtotal + 12'd1;
				if (line_active != 12'd0) frame_vactive <= frame_vactive + 12'd1;

				line_total  <= 12'd1;
				line_active <= pix_active ? 12'd1 : 12'd0;
			end else begin
				line_total <= line_total + 12'd1;
				if (pix_active) line_active <= line_active + 12'd1;
			end

			if (vs_rise) begin
				if ((frame_htotal >= 12'd128) &&
				    (frame_hactive >= 12'd128) &&
				    (frame_vtotal >= 12'd200) &&
				    (frame_vactive >= 12'd160) &&
				    (frame_hactive < frame_htotal) &&
				    (frame_vactive < frame_vtotal)) begin
					filt_htotal  <= next_filt_htotal;
					filt_hactive <= next_filt_hactive;
					filt_vtotal  <= next_filt_vtotal;
					filt_vactive <= next_filt_vactive;

					req_htotal    <= next_filt_htotal;
					req_hactive   <= next_filt_hactive;
					req_vtotal    <= next_filt_vtotal;
					req_vactive   <= next_filt_vactive;
					req_num_scale <= ar_num_scale;
					req_den_scale <= ar_den_scale;
					calc_pending  <= 1'b1;
					aspect_valid  <= 1'b1;
				end

				frame_htotal  <= 12'd0;
				frame_hactive <= 12'd0;
				frame_vtotal  <= 12'd0;
				frame_vactive <= 12'd0;
			end
		end

		// The aspect ratio only changes once per frame, so do the expensive math
		// as a tiny background task instead of a permanent wide combinational path.
		case (calc_state)
			CALC_IDLE: begin
				if (calc_pending) begin
					base_arx <= 24'd0;
					base_ary <= 24'd0;
					work_num <= 48'd0;
					work_den <= 48'd0;

					mul_acc          <= 48'd0;
					mul_multiplicand <= {36'd0, req_hactive};
					mul_multiplier   <= {4'd0, req_vtotal};
					mul_count        <= 6'd12;
					calc_state       <= CALC_MUL_BASE_X;
					calc_pending     <= 1'b0;
				end
			end

			CALC_MUL_BASE_X: begin
				mul_acc          <= mul_sum;
				mul_multiplicand <= mul_multiplicand << 1;
				mul_multiplier   <= mul_multiplier >> 1;
				mul_count        <= mul_count - 6'd1;

				if (mul_count == 6'd1) begin
					base_arx         <= mul_sum[23:0];
					mul_acc          <= 48'd0;
					mul_multiplicand <= {36'd0, req_htotal};
					mul_multiplier   <= {4'd0, req_vactive};
					mul_count        <= 6'd12;
					calc_state       <= CALC_MUL_BASE_Y;
				end
			end

			CALC_MUL_BASE_Y: begin
				mul_acc          <= mul_sum;
				mul_multiplicand <= mul_multiplicand << 1;
				mul_multiplier   <= mul_multiplier >> 1;
				mul_count        <= mul_count - 6'd1;

				if (mul_count == 6'd1) begin
					base_ary         <= mul_sum[23:0];
					mul_acc          <= 48'd0;
					mul_multiplicand <= {24'd0, base_arx};
					mul_multiplier   <= req_num_scale;
					mul_count        <= 6'd16;
					calc_state       <= CALC_MUL_SCALE_X;
				end
			end

			CALC_MUL_SCALE_X: begin
				mul_acc          <= mul_sum;
				mul_multiplicand <= mul_multiplicand << 1;
				mul_multiplier   <= mul_multiplier >> 1;
				mul_count        <= mul_count - 6'd1;

				if (mul_count == 6'd1) begin
					work_num         <= mul_sum;
					mul_acc          <= 48'd0;
					mul_multiplicand <= {24'd0, base_ary};
					mul_multiplier   <= req_den_scale;
					mul_count        <= 6'd16;
					calc_state       <= CALC_MUL_SCALE_Y;
				end
			end

			CALC_MUL_SCALE_Y: begin
				mul_acc          <= mul_sum;
				mul_multiplicand <= mul_multiplicand << 1;
				mul_multiplier   <= mul_multiplier >> 1;
				mul_count        <= mul_count - 6'd1;

				if (mul_count == 6'd1) begin
					work_den   <= mul_sum;
					calc_state <= CALC_REDUCE_TWOS;
				end
			end

			CALC_REDUCE_TWOS: begin
				if (work_num && work_den && !work_num[0] && !work_den[0]) begin
					work_num <= work_num >> 1;
					work_den <= work_den >> 1;
				end else begin
					calc_state <= CALC_SHRINK;
				end
			end

			CALC_SHRINK: begin
				if ((work_num > 48'd4095) || (work_den > 48'd4095)) begin
					work_num <= work_num >> 1;
					work_den <= work_den >> 1;
				end else begin
					calc_state <= CALC_FIX_ZERO;
				end
			end

			CALC_FIX_ZERO: begin
				if (!work_num) work_num <= 48'd1;
				if (!work_den) work_den <= 48'd1;
				calc_state <= CALC_GROW;
			end

			CALC_GROW: begin
				if ((work_num < 48'd2048) && (work_den < 48'd2048)) begin
					work_num <= work_num << 1;
					work_den <= work_den << 1;
				end else begin
					calc_state <= CALC_DONE;
				end
			end

			CALC_DONE: begin
				arx_reg    <= work_num[11:0];
				ary_reg    <= work_den[11:0];
				calc_state <= CALC_IDLE;
			end

			default: calc_state <= CALC_IDLE;
		endcase
	end
end
`endif
endmodule
