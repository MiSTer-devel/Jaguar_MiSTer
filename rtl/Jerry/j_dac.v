//`include "defs.v"
// altera message_off 10036

module _j_dac
(
	input resetl,
	input clk,
	input dac1w,
	input dac2w,
	input tint_0,
	input ts,
	input [15:0] dspd,
	output [1:0] rdac,
	output [1:0] ldac,
	input sys_clk // Generated
);
reg [7:0] p = 8'h0;
reg [15:2] dl1 = 14'h0;
reg [15:2] dr1 = 14'h0;
reg [15:2] dl2 = 14'h0;
reg [15:2] dr2 = 14'h0;
wire go;
wire stop;
wire dli_15;
wire dri_15;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// DAC.NET (24) - dl1[2-15] : slatchc
// DAC.NET (25) - dr1[2-15] : slatchc
// DAC.NET (31) - dl2[2-15] : slatchc
// DAC.NET (32) - dr2[2-15] : slatchc
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			dl1[15:2] <= 14'h0;
			dr1[15:2] <= 14'h0;
			dl2[15:2] <= 14'h0;
			dr2[15:2] <= 14'h0;
		end else begin
			if (dac1w) begin
				dl1[15:2] <= dspd[15:2];
			end
			if (dac2w) begin
				dr1[15:2] <= dspd[15:2];
			end
			if (tint_0) begin
				dl2[15:2] <= dl1[15:2];
				dr2[15:2] <= dr1[15:2];
			end
		end
	end
end

// DAC.NET (39) - pi[0] : dncnt
// DAC.NET (40) - pi[1-6] : dncnt
// DAC.NET (41) - pi[7] : dncnt
// DAC.NET (45) - p[0-7] : nivm
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			p[7:0] <= 8'h0;
		end else begin
			p[7:0] <= (ts) ? 8'h80 : (p[7:0] - (go ? 1'b1 : 1'b0)); // d[7]==vcc
		end
	end
end

// DAC.NET (52) - go : nd2
assign go = ~(p[6] & p[7]);

// DAC.NET (53) - stop : iv
assign stop = ~go;

// DAC.NET (60) - ldac[0] : pulse
_j_pulse ldac_index_0_inst
(
	.a /* IN */ (p[7:0]),
	.b /* IN */ (dl2[8:2]),
	.stop /* IN */ (stop),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.pulse /* OUT */ (ldac[0]),
	.sys_clk(sys_clk) // Generated
);

// DAC.NET (61) - ldac[1] : pulse
_j_pulse ldac_index_1_inst
(
	.a /* IN */ (p[7:0]),
	.b /* IN */ ({~dl2[15],dl2[14:9]}),//dli[15]
	.stop /* IN */ (stop),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.pulse /* OUT */ (ldac[1]),
	.sys_clk(sys_clk) // Generated
);

// DAC.NET (62) - rdac[0] : pulse
_j_pulse rdac_index_0_inst
(
	.a /* IN */ (p[7:0]),
	.b /* IN */ (dr2[8:2]),
	.stop /* IN */ (stop),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.pulse /* OUT */ (rdac[0]),
	.sys_clk(sys_clk) // Generated
);

// DAC.NET (63) - rdac[1] : pulse
_j_pulse rdac_index_1_inst
(
	.a /* IN */ (p[7:0]),
	.b /* IN */ ({~dr2[15],dr2[14:9]}),//dri[15]
	.stop /* IN */ (stop),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.pulse /* OUT */ (rdac[1]),
	.sys_clk(sys_clk) // Generated
);

endmodule
