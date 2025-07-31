//`include "defs.v"
// altera message_off 10036

module _pix
(
	input [15:0] din,
	input dd,
	input vactive,
	input blank,
	input nextpixa,
	input nextpixd,
	input cry16,
	input rgb24,
	input rg16,
	input [31:0] lbrd,
	input lbraw,
	input lbrar,
	input bcrgwr,
	input bcbwr,
	input resetl,
	input vclk,
	input mptest,
	input incen,
	input binc,
	input lp,
	input rgb16,
	input varmod,
	input word2,
	input pp,
	output [8:0] lbra,
	output [7:0] r,
	output [7:0] g,
	output [7:0] b,
	output inc,
	output [8:0] dr_out,
	output dr_8_0_oe,
	input sys_clk // Generated
);
wire [7:0] red;
wire [7:0] green;
wire [7:0] blue;
wire [31:0] pd1_d;
wire [31:0] lbrd_d;
wire ddl;
wire lbres;
wire [8:0] co;
wire nextpixb;
reg [31:0] pd1 = 32'h00000000;
wire word2b;
wire [15:0] pd2;
wire rgb0;
wire rgb1;
wire rgb;
reg ppdi = 1'b0;
wire ppd;
wire [23:0] pd3;
wire pd20;
wire lpb;
wire [15:0] pd4;
reg [23:0] bc = 24'h000000;
wire sxp;
wire notvactive;
reg bord1 = 1'b0;
reg bord2 = 1'b0;
reg bord3 = 1'b0;
wire border;
wire blankl;
wire borderl;
wire s1i;
wire s1;
wire s01;
wire s0i;
wire s0;
wire [23:0] pd5;
reg [23:0] pd6 = 24'h000000;
reg inc1 = 1'b0;
reg inc2 = 1'b0;
wire inc3;
wire inc4;
reg inc5 = 1'b0;
wire notincen;
wire notvarmod;

// Output buffers
reg [8:0] lbra_obuf = 9'h000;
wire [7:0] r_obuf;
wire [7:0] g_obuf;
wire [7:0] b_obuf;

wire clk = vclk; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign r[7:0] = r_obuf[7:0];
assign g[7:0] = g_obuf[7:0];
assign b[7:0] = b_obuf[7:0];

// PIX.NET (28) - red : join
assign red[7:0] = r_obuf[7:0];

// PIX.NET (29) - green : join
assign green[7:0] = g_obuf[7:0];

// PIX.NET (30) - blue : join
assign blue[7:0] = b_obuf[7:0];

// PIX.NET (34) - lbra : join
assign lbra[8:0] = lbra_obuf[8:0];

// PIX.NET (39) - startdl : iv
assign ddl = ~dd;

// PIX.NET (40) - lbresl : nd2x2
assign lbres = ~(ddl & resetl);

// PIX.NET (41) - lbra[0] : upcnts
always @(posedge sys_clk) // fd1q
begin
	if (~old_clk && clk) begin
		if (lbres) begin
			lbra_obuf[8:0] <= 9'h000;
		end else if (lbraw) begin
			lbra_obuf[8:0] <= din[8:0];
		end else if (nextpixa) begin
			lbra_obuf[8:0] <= lbra_obuf[8:0] + 9'h001;
		end
	end
end

// PIX.NET (45) - lbrad[0-8] : ts
assign dr_out[8:0] = lbra_obuf[8:0];
assign dr_8_0_oe = lbrar;

// PIX.NET (49) - nextpixb : nivu2
assign nextpixb = nextpixd;

// PIX.NET (50) - pd1[0-31] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (nextpixb) begin
			pd1[31:0] <= lbrd[31:0];
		end
	end
end

// PIX.NET (53) - ge1 : join
assign pd1_d[31:0] = pd1[31:0];

// PIX.NET (55) - ge3 : join
assign lbrd_d[31:0] = lbrd[31:0];

// PIX.NET (61) - word2b : nivu2
assign word2b = word2;

// PIX.NET (62) - pd2[0-15] : mx2m
assign pd2[15:0] = (word2b) ? pd1[31:16] : pd1[15:0];

// PIX.NET (70) - rgb0 : iv
assign rgb0 = ~rgb16;

// PIX.NET (71) - rgb1 : nd2
assign rgb1 = ~(varmod & pd2[0]);

// PIX.NET (72) - rgb : nd2
assign rgb = ~(rgb0 & rgb1);

// PIX.NET (79) - ppdi : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		ppdi <= pp;
	end
end

// PIX.NET (80) - ppd : nivu
assign ppd = ppdi;

// PIX.NET (82) - pd3 : cryrgb
_cryrgb pd3_inst
(
	.r /* OUT */ (pd3[7:0]),
	.g /* OUT */ (pd3[15:8]),
	.b /* OUT */ (pd3[23:16]),
	.cry /* IN */ ({pd2[15:1], pd20}),
	.vclk /* IN */ (vclk),
	.mptest /* IN */ (mptest),
	.rgb /* IN */ (rgb),
	.ppd /* IN */ (ppd),
	.sys_clk(sys_clk) // Generated
);

// PIX.NET (87) - lpb : nivh
assign lpb = lp;

// PIX.NET (88) - pd4[0-15] : mx2
assign pd4[15:0] = (lpb) ? pd1[15:0] : pd1[31:16];

// PIX.NET (92) - bc[0-15] : ldp1q
// PIX.NET (93) - bc[16-23] : ldp1q
// always @(d or g)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (bcrgwr) begin
		bc[15:0] <= din[15:0]; // ldp1q negedge always @(d or g)
	end
	if (bcbwr) begin
		bc[23:16] <= din[7:0]; // ldp1q negedge always @(d or g)
	end
end

// PIX.NET (101) - sxp : or2
assign sxp = cry16 | rgb16;

// PIX.NET (102) - vactivel : iv
assign notvactive = ~vactive;

// PIX.NET (103) - bord1 : fd1q
// PIX.NET (104) - bord2 : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		bord1 <= notvactive;
		bord2 <= bord1;
	end
end

// PIX.NET (105) - bord3 : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (ppd) begin
			bord3 <= bord2;
		end
	end
end

// PIX.NET (106) - border : mx2
assign border = (sxp) ? bord3 : bord1;

// PIX.NET (127) - blankl : iv
assign blankl = ~blank;

// PIX.NET (128) - borderl : iv
assign borderl = ~border;

// PIX.NET (130) - s1i : nd2
assign s1i = ~(blankl & borderl);

// PIX.NET (131) - s1 : nivu
assign s1 = s1i;

// PIX.NET (132) - s01 : nd3
assign s01 = ~(blankl & borderl & rgb24);

// PIX.NET (133) - s0i : nd2
assign s0i = ~(s01 & blankl);

// PIX.NET (134) - s0 : nivu
assign s0 = s0i;

// PIX.NET (136) - pd5[0-23] : mx4
assign pd5[23:0] = s1 ? (s0 ? 24'h000000 : bc[23:0]) : (s0 ? pd1[23:0] : pd3[23:0]);

// PIX.NET (140) - pd6[0-23] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		pd6[23:0] <= pd5[23:0];
	end
end

// PIX.NET (145) - r[0-7] : mx2
assign r_obuf[7:0] = (rg16) ? pd4[7:0] : pd6[7:0];

// PIX.NET (146) - g[0-7] : mx2
assign g_obuf[7:0] = (rg16) ? pd4[15:8] : pd6[15:8];

// PIX.NET (147) - b[0] : mx2
// PIX.NET (148) - b[1] : mx2
// PIX.NET (149) - b[2-7] : mx2
assign b_obuf[7:0] = (rg16) ? {6'h00, vactive, blank} : pd6[23:16];

// PIX.NET (157) - inc1 : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		inc1 <= pd2[0];
	end
end

// PIX.NET (158) - inc2 : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (ppd) begin
			inc2 <= inc1;
		end
	end
end

// PIX.NET (159) - inc3 : mx2
assign inc3 = (rgb24) ? pd1[24] : inc2;

// PIX.NET (160) - inc4 : mx2
assign inc4 = (border) ? binc : inc3;

// PIX.NET (161) - inc5 : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		inc5 <= inc4;
	end
end

// PIX.NET (162) - inc : or2
assign inc = inc5 | notincen;

// PIX.NET (166) - pd20 : an3
assign pd20 = pd2[0] & notincen & notvarmod;

// PIX.NET (168) - notincen : iv
assign notincen = ~incen;

// PIX.NET (169) - notvarmod : iv
assign notvarmod = ~varmod;
endmodule

