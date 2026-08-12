//`include "defs.v"

module _cryrgb
(
	output [7:0] r,
	output [7:0] g,
	output [7:0] b,
	input [15:0] cry,
	input vclk,
	input mptest,
	input rgb,
	input ppd,
	input sys_clk // Generated
);
reg [7:0] r_ = 8'h00;
reg [7:0] g_ = 8'h00;
reg [7:0] b_ = 8'h00;
wire [7:0] i;
wire [7:0] c;
wire [7:0] r1;
wire [7:0] g1;
wire [7:0] b1;
reg [7:0] r2 = 8'h00;
reg [7:0] g2 = 8'h00;
reg [7:0] b2 = 8'h00;
reg [7:0] i2 = 8'h00;
wire [7:0] rt;
wire [7:0] gt;
wire [7:0] bt;
wire [9:0] r2a;
wire [9:0] g2a;
wire [9:0] b2a;
wire [9:0] i2a;
wire [19:0] r3;
wire [19:0] g3;
wire [19:0] b3;
wire rgbtsti;
wire rgbtst;
reg rgbdi  = 1'b0;
wire rgbd;
wire [7:0] r3b;
wire [7:0] b3b;
wire [7:0] g3b;

wire clk = vclk; 
reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

assign r[7:0] = r_[7:0];
assign g[7:0] = g_[7:0];
assign b[7:0] = b_[7:0];

// PIX.NET (184) - i : join
assign i[7:0] = cry[7:0];

// PIX.NET (185) - c : join
assign c[7:0] = cry[15:8];

// PIX.NET (201) - red : ra8008a
_ra8008a red_inst
(
	.z /* OUT */ (r1[7:0]),
	.clk /* IN */ (vclk),
	.a /* IN */ (c[7:0]),
	.sys_clk(sys_clk) // Generated
);

// PIX.NET (202) - green : ra8008b
_ra8008b green_inst
(
	.z /* OUT */ (g1[7:0]),
	.clk /* IN */ (vclk),
	.a /* IN */ (c[7:0]),
	.sys_clk(sys_clk) // Generated
);

// PIX.NET (203) - blue : ra8008c
_ra8008c blue_inst
(
	.z /* OUT */ (b1[7:0]),
	.clk /* IN */ (vclk),
	.a /* IN */ (c[7:0]),
	.sys_clk(sys_clk) // Generated
);

// PIX.NET (208) - rgbtsti : or2
assign rgbtsti = rgb | mptest;

// PIX.NET (209) - rgbtst : nivh
assign rgbtst = rgbtsti;

// PIX.NET (210) - rt : mx2
assign rt[7:0] = (rgbtst) ? c[7:0] : r1[7:0];

// PIX.NET (211) - gt : mx2
assign gt[7:0] = (rgbtst) ? c[7:0] : g1[7:0];

// PIX.NET (212) - bt : mx2
assign bt[7:0] = (rgbtst) ? c[7:0] : b1[7:0];

// PIX.NET (216) - r2 : fd1q
// PIX.NET (217) - g2 : fd1q
// PIX.NET (218) - b2 : fd1q
// PIX.NET (219) - i2 : fd1q
// PIX.NET (221) - rgbdi : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		r2[7:0] <= rt[7:0];
		g2[7:0] <= gt[7:0];
		b2[7:0] <= bt[7:0];
		i2[7:0] <= i[7:0];
		rgbdi <= rgb;
	end
end

// PIX.NET (222) - rgbd : nivh
assign rgbd = rgbdi;

// PIX.NET (228) - r2a : join
assign r2a[9:0] = {2'b00, r2[7:0]};

// PIX.NET (229) - g2a : join
assign g2a[9:0] = {2'b00, g2[7:0]};

// PIX.NET (230) - b2a : join
assign b2a[9:0] = {2'b00, b2[7:0]};

// PIX.NET (231) - i2a : join
assign i2a[9:0] = {2'b00, i2[7:0]};

// PIX.NET (249) - r3 : mp1010a
_mp1010a r3_inst
(
	.q /* OUT */ (r3[19:0]),
	.a /* IN */ (r2a[9:0]),
	.b /* IN */ (i2a[9:0])
);

// PIX.NET (250) - g3 : mp1010a
_mp1010a g3_inst
(
	.q /* OUT */ (g3[19:0]),
	.a /* IN */ (g2a[9:0]),
	.b /* IN */ (i2a[9:0])
);

// PIX.NET (251) - b3 : mp1010a
_mp1010a b3_inst
(
	.q /* OUT */ (b3[19:0]),
	.a /* IN */ (b2a[9:0]),
	.b /* IN */ (i2a[9:0])
);

// PIX.NET (256) - r3b[0-2] : mx2
// PIX.NET (257) - r3b[3-7] : mx2
assign r3b[7:0] = (rgbd) ? {r2[7:3], 3'b000} : r3[15:8];

// PIX.NET (259) - b3b[0-2] : mx2
// PIX.NET (260) - b3b[3-4] : mx2
// PIX.NET (261) - b3b[5-7] : mx2
assign b3b[7:0] = (rgbd) ? {r2[2:0], i2[7:6], 3'b000} : b3[15:8];

// PIX.NET (263) - g3b[0-1] : mx2
// PIX.NET (264) - g3b[2-7] : mx2
assign g3b[7:0] = (rgbd) ? {i2[5:0], 2'b00} : g3[15:8];

// PIX.NET (268) - r[0-7] : slatch
// PIX.NET (269) - g[0-7] : slatch
// PIX.NET (270) - b[0-7] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (ppd) begin
			r_[7:0] <= r3b[7:0];
			g_[7:0] <= g3b[7:0];
			b_[7:0] <= b3b[7:0];
		end
	end
end

endmodule

