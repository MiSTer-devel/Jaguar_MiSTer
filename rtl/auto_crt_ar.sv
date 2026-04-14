`include "defines.vh"

// Please note this module is a timing *nightmare*. I very much do not suggest including it in your
// final RTL but rather using it to figure out correct aspect ratios for MiSTer cores, signaltapping them
// and then implementing them as static parameters.

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
`ifdef FAST_COMPILE
assign arx = DEFAULT_ARX;
assign ary = DEFAULT_ARY;
`else

// reg        prev_hsync = 1'b0;
// reg        prev_vsync = 1'b0;
// reg        prev_ntsc  = 1'b0;
// reg        aspect_valid = 1'b0;

// reg [11:0] line_total      = 12'd0;
// reg [11:0] line_active     = 12'd0;
// reg [11:0] frame_htotal    = 12'd0;
// reg [11:0] frame_hactive   = 12'd0;
// reg [11:0] frame_vtotal    = 12'd0;
// reg [11:0] frame_vactive   = 12'd0;

// reg [11:0] filt_htotal     = 12'd0;
// reg [11:0] filt_hactive    = 12'd0;
// reg [11:0] filt_vtotal     = 12'd0;
// reg [11:0] filt_vactive    = 12'd0;

// wire hs_rise = hsync & ~prev_hsync;
// wire vs_rise = vsync & ~prev_vsync;
// wire pix_active = ~hblank & ~vblank;

// // Pre-fold the constant terms from the parameterized CRT model:
// //   ar_num_scale = 4 * HVIS_DEN * VVIS_NUM
// //   ar_den_scale = 3 * HVIS_NUM * VVIS_DEN
// wire [15:0] ar_num_scale = ntsc ? 16'd8192 : 16'd3776;
// wire [15:0] ar_den_scale = ntsc ? 16'd5565 : 16'd2496;

// wire [23:0] base_arx = filt_hactive * filt_vtotal;
// wire [23:0] base_ary = filt_htotal  * filt_vactive;
// wire [39:0] raw_arx = base_arx * ar_num_scale;
// wire [39:0] raw_ary = base_ary * ar_den_scale;
// wire [23:0] norm_pair = normalize_pair(raw_arx, raw_ary);

// assign arx = aspect_valid ? norm_pair[23:12] : DEFAULT_ARX;
// assign ary = aspect_valid ? norm_pair[11:0]  : DEFAULT_ARY;

// function automatic [11:0] smooth_u12;
// 	input [11:0] cur;
// 	input [11:0] meas;
// 	reg signed [12:0] delta;
// 	reg signed [12:0] step;
// 	reg signed [13:0] next_value;
// begin
// 	delta = $signed({1'b0, meas}) - $signed({1'b0, cur});
// 	step = delta >>> 2;

// 	if (!step && delta) begin
// 		step = delta[12] ? -13'sd1 : 13'sd1;
// 	end

// 	next_value = $signed({1'b0, cur}) + $signed(step);
// 	if (next_value < 0) begin
// 		smooth_u12 = 12'd0;
// 	end else if (next_value > 14'sd4095) begin
// 		smooth_u12 = 12'd4095;
// 	end else begin
// 		smooth_u12 = next_value[11:0];
// 	end
// end
// endfunction

// function automatic [23:0] normalize_pair;
// 	input [47:0] num_in;
// 	input [47:0] den_in;
// 	reg [47:0] num;
// 	reg [47:0] den;
// 	integer i;
// begin
// 	num = num_in;
// 	den = den_in;

// 	if (!num || !den) begin
// 		normalize_pair = {DEFAULT_ARX, DEFAULT_ARY};
// 	end else begin
// 		for (i = 0; i < 48; i = i + 1) begin
// 			if ((num > 48'd4095) || (den > 48'd4095)) begin
// 				num = num >> 1;
// 				den = den >> 1;
// 			end
// 		end

// 		if (!num) num = 48'd1;
// 		if (!den) den = 48'd1;

// 		for (i = 0; i < 11; i = i + 1) begin
// 			if ((num < 48'd2048) && (den < 48'd2048)) begin
// 				num = num << 1;
// 				den = den << 1;
// 			end
// 		end

// 		normalize_pair = {num[11:0], den[11:0]};
// 	end
// end
// endfunction

// always @(posedge clk_sys) begin
// 	if (reset) begin
// 		prev_hsync   <= 1'b0;
// 		prev_vsync   <= 1'b0;
// 		prev_ntsc    <= ntsc;
// 		aspect_valid <= 1'b0;

// 		line_total   <= 12'd0;
// 		line_active  <= 12'd0;
// 		frame_htotal <= 12'd0;
// 		frame_hactive<= 12'd0;
// 		frame_vtotal <= 12'd0;
// 		frame_vactive<= 12'd0;

// 		filt_htotal  <= 12'd0;
// 		filt_hactive <= 12'd0;
// 		filt_vtotal  <= 12'd0;
// 		filt_vactive <= 12'd0;
// 	end else if (prev_ntsc != ntsc) begin
// 		prev_ntsc    <= ntsc;
// 		aspect_valid <= 1'b0;

// 		line_total   <= 12'd0;
// 		line_active  <= 12'd0;
// 		frame_htotal <= 12'd0;
// 		frame_hactive<= 12'd0;
// 		frame_vtotal <= 12'd0;
// 		frame_vactive<= 12'd0;

// 		filt_htotal  <= 12'd0;
// 		filt_hactive <= 12'd0;
// 		filt_vtotal  <= 12'd0;
// 		filt_vactive <= 12'd0;
// 	end else if (ce_pix) begin
// 		prev_hsync <= hsync;
// 		prev_vsync <= vsync;

// 		if (hs_rise) begin
// 			if (line_total > frame_htotal) frame_htotal <= line_total;
// 			if (line_active > frame_hactive) frame_hactive <= line_active;
// 			frame_vtotal <= frame_vtotal + 12'd1;
// 			if (line_active != 12'd0) frame_vactive <= frame_vactive + 12'd1;

// 			line_total  <= 12'd1;
// 			line_active <= pix_active ? 12'd1 : 12'd0;
// 		end else begin
// 			line_total <= line_total + 12'd1;
// 			if (pix_active) line_active <= line_active + 12'd1;
// 		end

// 		if (vs_rise) begin
// 			if ((frame_htotal >= 12'd128) &&
// 			    (frame_hactive >= 12'd128) &&
// 			    (frame_vtotal >= 12'd200) &&
// 			    (frame_vactive >= 12'd160) &&
// 			    (frame_hactive < frame_htotal) &&
// 			    (frame_vactive < frame_vtotal)) begin
// 				if (!aspect_valid) begin
// 					filt_htotal  <= frame_htotal;
// 					filt_hactive <= frame_hactive;
// 					filt_vtotal  <= frame_vtotal;
// 					filt_vactive <= frame_vactive;
// 				end else begin
// 					filt_htotal  <= smooth_u12(filt_htotal,  frame_htotal);
// 					filt_hactive <= smooth_u12(filt_hactive, frame_hactive);
// 					filt_vtotal  <= smooth_u12(filt_vtotal,  frame_vtotal);
// 					filt_vactive <= smooth_u12(filt_vactive, frame_vactive);
// 				end
// 				aspect_valid <= 1'b1;
// 			end

// 			frame_htotal  <= 12'd0;
// 			frame_hactive <= 12'd0;
// 			frame_vtotal  <= 12'd0;
// 			frame_vactive <= 12'd0;
// 		end
// 	end
// end
`endif
endmodule
