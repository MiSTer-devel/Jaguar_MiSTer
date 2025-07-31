//`include "defs.v"

module _arith
(
	output [31:0] gpu_data_out, // jerry only
	output gpu_data_oe, // jerry only
	output [2:0] gpu_dout_out,
	output gpu_dout_oe,
	output carry_flag,
	output nega_flag,
	output [31:0] result,
	output zero_flag,
	input accumrd, // jerry only
	input [31:0] dstdp,
	input [31:0] srcdp,
	input srcd_31,
	input [2:0] alufunc,
	input [1:0] brlmux,
	input clk,
	input flagld,
	input flagrd,
	input flagwr,
	input [31:0] gpu_din,
	input macop,
	input modulowr, // jerry only
	input multsel,
	input multsign,
	input reset_n,
	input resld,
	input [2:0] ressel,
	input rev_sub,
	input [1:0] satsz, // satsz[1] tom only
	input sys_clk // Generated
);
parameter JERRY = 0;

reg [2:0] alufnc = 3'h0;
wire [2:0] alufnci;
wire [15:0] losrcdp;
wire [15:0] hisrcdp;
wire [15:0] mula;
wire [15:0] mulb;
wire [22:0] mantissa;
wire [31:0] alua;
wire [31:0] aluat;
wire [31:0] alub;
wire [31:0] aluq;
wire [31:0] mant;
wire [31:0] mulq;
reg [31:0] mulqp = 32'h0;
wire [31:0] normi;
reg [31:0] resd;
wire [31:0] satval;
wire [31:0] pack;
wire [31:0] unpack;
wire [31:0] accum;
wire [31:0] modalu;
wire [31:0] mirror;
wire [31:0] brlq;
wire [23:0] satvallo;
wire [31:0] satvalhi;
reg [39:32] acctop = 8'h0;
reg [1:0] brlmuxp = 2'h0;
reg flagldp = 1'b0;
reg resldp = 1'b0;
reg multselp = 1'b0;
reg multsignp = 1'b0;
reg [2:0] resselp = 3'h0;
reg rev_subp = 1'b0;
reg macop_p = 1'b0;
reg macop_ppt = 1'b0;
wire macop_pp;
reg [1:0] satszp = 2'h0;
wire mantmodei;
reg mantmode = 1'b0;
wire addtosubi_n;
wire alufunc_n_1;
wire alufn_1;
reg [31:0] topset;
wire aluazero_n;
wire alu_co;
wire mulqpsgn;
wire [39:32] accuma;
wire accuminit;
wire mulqsgn;
wire [39:32] accumb;
wire accums;
wire brl_carry;
reg [31:0] modulo = 32'h0;
wire resldt;
wire zerodet;
wire zfi;
wire [1:0] cfisel;
wire cfi;
wire nfi;

// Output buffers
reg carry_flag_obuf = 1'b0;
reg nega_flag_obuf = 1'b0;
reg [31:0] result_obuf = 32'h0;
reg zero_flag_obuf = 1'b0;

wire resetl = reset_n; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign carry_flag = carry_flag_obuf;
assign nega_flag = nega_flag_obuf;
assign result[31:0] = result_obuf[31:0];
assign zero_flag = zero_flag_obuf;

// ARITH.NET (63) - brlmuxp[0-1] : fd1q
// ARITH.NET (64) - flagldp : fd2q
// ARITH.NET (65) - resldp : fd1q
// ARITH.NET (66) - multselp : fd1qh
// ARITH.NET (67) - multsignp : fd1q
// ARITH.NET (68) - resselp[0-2] : fd1qu
// ARITH.NET (70) - rev_subp : fd1q
// ARITH.NET (71) - macop_p : fd1q
// ARITH.NET (72) - macop_ppt : fd1q
// ARITH.NET (74) - satszp[0-1] : fd1qu
// ARITH.NET (81) - mantmode : fd1q
// ARITH.NET (93) - alufncp : fd1qp
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			flagldp <= 1'b0;
		end else begin
			flagldp <= flagld;
		end
	end
	if (~old_clk && clk) begin
		brlmuxp[1:0] <= brlmux[1:0];
		resldp <= resld;
		multselp <= multsel;
		multsignp <= multsign;
		resselp[2:0] <= ressel[2:0];
		rev_subp <= rev_sub;
		macop_p <= macop;
		macop_ppt <= macop_p;
		satszp[1:0] <= satsz[1:0];
		mantmode <= mantmodei;
		alufnc[2:0] <= alufnci[2:0];
	end
end

// ARITH.NET (73) - macop_pp : nivu2
assign macop_pp = macop_ppt;

// ARITH.NET (80) - mantmodei : an3
assign mantmodei = (ressel[2:0]==3'b100);

// ARITH.NET (85) - addtosubi\ : nd2
assign addtosubi_n = ~(mantmodei & srcd_31);

// ARITH.NET (89) - alufunc\[1] : iv
assign alufunc_n_1 = ~alufunc[1];

// ARITH.NET (90) - alufn[1] : nd2
assign alufn_1 = ~(alufunc_n_1 & addtosubi_n);

// ARITH.NET (91) - alufnc : join
assign alufnci[0] = alufunc[0];
assign alufnci[1] = alufn_1;
assign alufnci[2] = alufunc[2];

// ARITH.NET (98) - losrcdp : join
assign losrcdp[15:0] = srcdp[15:0];

// ARITH.NET (99) - hisrcdp : join
assign hisrcdp[15:0] = srcdp[31:16];

// ARITH.NET (100) - mulb : join
assign mulb[15:0] = dstdp[15:0];

// ARITH.NET (101) - mula : mx2
assign mula[15:0] = (multselp) ? hisrcdp[15:0] : losrcdp[15:0];

// ARITH.NET (105) - mult : mp16
_mp16 mult_inst
(
	.q /* OUT */ (mulq[31:0]),
	.a /* IN */ (mula[15:0]),
	.b /* IN */ (mulb[15:0]),
	.sign0 /* IN */ (multsignp),
	.sign1 /* IN */ (multsignp),
	.unk0 /* IN */ (1'b1),
	.unk1 /* IN */ (1'b0)
);

// ARITH.NET (111) - mulqp : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		mulqp[31:0] <= mulq[31:0];
	end
end

// ARITH.NET (120) - mantissa : join
assign mantissa[22:0] = srcdp[22:0];

// ARITH.NET (121) - mant : join
assign mant[22:0] = mantissa[22:0];
assign mant[23] = 1'b1;
assign mant[31:24] = 8'h00;

// ARITH.NET (134) - topset[31] : niv
reg [31:0] topset0;
reg [31:0] topset4;
reg [31:0] topset8;
reg [31:0] topset12;
reg [31:0] topset16;
reg [31:0] topset20;
reg [31:0] topset24;
always @(*)
begin
	casex(srcdp[3:0])
		{4'b1XXX}		: topset0 = 32'h00000008;
		{4'b01XX}		: topset0 = 32'h00000004;
		{4'b001X}		: topset0 = 32'h00000002;
		{4'b0001}		: topset0 = 32'h00000001;
		{4'b0000}		: topset0 = 32'h00000000;
	endcase
	casex(srcdp[7:4])
		{4'b1XXX}		: topset4 = 32'h00000080;
		{4'b01XX}		: topset4 = 32'h00000040;
		{4'b001X}		: topset4 = 32'h00000020;
		{4'b0001}		: topset4 = 32'h00000010;
		{4'b0000}		: topset4 = topset0;
	endcase
	casex(srcdp[11:8])
		{4'b1XXX}		: topset8 = 32'h00000800;
		{4'b01XX}		: topset8 = 32'h00000400;
		{4'b001X}		: topset8 = 32'h00000200;
		{4'b0001}		: topset8 = 32'h00000100;
		{4'b0000}		: topset8 = topset4;
	endcase
	casex(srcdp[15:12])
		{4'b1XXX}		: topset12 = 32'h00008000;
		{4'b01XX}		: topset12 = 32'h00004000;
		{4'b001X}		: topset12 = 32'h00002000;
		{4'b0001}		: topset12 = 32'h00001000;
		{4'b0000}		: topset12 = topset8;
	endcase
	casex(srcdp[19:16])
		{4'b1XXX}		: topset16 = 32'h00080000;
		{4'b01XX}		: topset16 = 32'h00040000;
		{4'b001X}		: topset16 = 32'h00020000;
		{4'b0001}		: topset16 = 32'h00010000;
		{4'b0000}		: topset16 = topset12;
	endcase
	casex(srcdp[23:20])
		{4'b1XXX}		: topset20 = 32'h00800000;
		{4'b01XX}		: topset20 = 32'h00400000;
		{4'b001X}		: topset20 = 32'h00200000;
		{4'b0001}		: topset20 = 32'h00100000;
		{4'b0000}		: topset20 = topset16;
	endcase
	casex(srcdp[27:24])
		{4'b1XXX}		: topset24 = 32'h08000000;
		{4'b01XX}		: topset24 = 32'h04000000;
		{4'b001X}		: topset24 = 32'h02000000;
		{4'b0001}		: topset24 = 32'h01000000;
		{4'b0000}		: topset24 = topset20;
	endcase
	casex(srcdp[31:28])
		{4'b1XXX}		: topset = 32'h80000000;
		{4'b01XX}		: topset = 32'h40000000;
		{4'b001X}		: topset = 32'h20000000;
		{4'b0001}		: topset = 32'h10000000;
		{4'b0000}		: topset = topset24;
	endcase
end
// ARITH.NET (135) - topset[30] : tben
// ARITH.NET (137) - topset[25-29] : tben
// ARITH.NET (139) - topset[24] : tbenw
// ARITH.NET (140) - inh[24] : or8
// ARITH.NET (142) - topset[17-23] : tben
// ARITH.NET (144) - topset[16] : tbenw
// ARITH.NET (145) - inh[16] : or9
// ARITH.NET (147) - topset[9-15] : tben
// ARITH.NET (149) - topset[8] : tbenw
// ARITH.NET (150) - inh[8] : or9
// ARITH.NET (152) - topset[1-7] : tben
// ARITH.NET (154) - topset[0] : tbenw

// ARITH.NET (158) - normi[0] : or16
// ARITH.NET (164) - normi[1] : or16
// ARITH.NET (168) - normi[2] : or16
// ARITH.NET (170) - normi[3] : or16
// ARITH.NET (172) - normi[4] : an2
// ARITH.NET (173) - normi[5] : ivu
assign normi[0] = |(topset & 32'h55555555); // even indexes
assign normi[1] = |(topset & 32'h66666666); // 1;2;5;6;9;10...
assign normi[2] = |(topset & 32'h78787878); // 3;4;5;6;11;12...
assign normi[3] = |(topset & 32'h807F807F); // 0;1;2;3;4;5;6;15;16...
assign normi[4] = |(topset & 32'h007FFF80); //7-22;
assign normi[5] = ~(|(topset & 32'hFF800000)); //0-22 or none(==0)

// ARITH.NET (176) - normi : join
assign normi[31:6] = {26{normi[5]}};

// ARITH.NET (192) - aluamux : mx2
assign aluat[31:0] = (macop_pp) ? result_obuf[31:0] : dstdp[31:0];

// ARITH.NET (193) - aluazero\ : ivu
assign aluazero_n = ~mantmode;

// ARITH.NET (194) - alua[0-31] : an2p
assign alua[31:0] = aluazero_n ? aluat[31:0] : 32'h0;

// ARITH.NET (203) - alubmux : mx4p
assign alub[31:0] = mantmode ? (mant[31:0]) : (macop_pp ? mulqp[31:0] : srcdp[31:0]);

// ARITH.NET (208) - alu : alu32
_alu32 alu_inst
(
	.aluq /* OUT */ (aluq[31:0]),
	.alu_co /* OUT */ (alu_co),
	.alua /* IN */ (alua[31:0]),
	.alub /* IN */ (alub[31:0]),
	.carry_flag /* IN */ (carry_flag_obuf),
	.alufunc /* IN */ (alufnc[2:0]),
	.dstdp_31 /* IN */ (dstdp[31]),
	.rev_subp /* IN */ (rev_subp)
);

// DSP_A-5Q.NET (226) - mulqpsgn : nivm
assign mulqpsgn = mulqp[31];

// DSP_A-5Q.NET (243) - ge1 : add4
// DSP_A-5Q.NET (244) - ge2 : add4
assign accuma[39:32] = acctop[39:32] + {8{mulqpsgn}} + alu_co;

// DSP_A-5Q.NET (250) - accuminit : an4p
assign accuminit = resldp & resselp[0] & resselp[1] & ~resselp[2];

// DSP_A-5Q.NET (252) - mulqsgn : nivm
assign mulqsgn = mulq[31];

// DSP_A-5Q.NET (253) - accumb[32-39] : mx4
assign accumb[39:32] = accuminit ? (macop_pp ? 8'h0 : {8{mulqsgn}}) : (macop_pp ? accuma[39:32] : acctop[39:32]);

// DSP_A-5Q.NET (256) - accum[32-39] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		acctop[39:32] <= accumb[39:32];
	end
end

// DSP_A-5Q.NET (258) - accumsign : nivu
assign accums = acctop[39];

// DSP_A-5Q.NET (259) - accum : join
assign accum[7:0] = acctop[39:32];
assign accum[31:8] = {24{accums}};

// DSP_A-5Q.NET (267) - accumrd : ts
assign gpu_data_out[31:0] = accum[31:0];
assign gpu_data_oe = accumrd;

// ARITH.NET (213) - brl : brlshift
_brlshift brl_inst
(
	.brlq /* OUT */ (brlq[31:0]),
	.brl_carry /* OUT */ (brl_carry),
	.brlmux /* IN */ (brlmuxp[1:0]),
	.srcdp /* IN */ (srcdp[31:0]),
	.brld /* IN */ (dstdp[31:0])
);

// ARITH.NET (218) - saturate : saturate
_saturate saturate_inst
(
	.q /* OUT */ (satvallo[23:0]),
	.d /* IN */ (dstdp[31:0]),
	.sixteen /* IN */ (satszp[0]),
	.twentyfour /* IN */ (satszp[1])
);

// DSP_A-5Q.NET (276) - saturate : saturate
_j_saturate jsaturate_inst
(
	.q /* OUT */ (satvalhi[31:0]),
	.d /* IN */ (dstdp[31:0]),
	.satszp /* IN */ (satszp[0]),
	.accum /* IN */ (acctop[39:32])
);

// ARITH.NET (219) - satval : join
assign satval[23:0] = (JERRY==0) ? satvallo[23:0] : satvalhi[23:0];
assign satval[31:24] = (JERRY==0) ? 8'h00 : satvalhi[31:24];

// ARITH.NET (224) - unpack : join
assign unpack[7:0] = dstdp[7:0];
assign unpack[12:8] = 5'h00;
assign unpack[16:13] = dstdp[11:8];
assign unpack[21:17] = 5'h00;
assign unpack[25:22] = dstdp[15:12];
assign unpack[31:26] = 6'h00;

// ARITH.NET (229) - pack : join
assign pack[7:0] = dstdp[7:0];
assign pack[11:8] = dstdp[16:13];
assign pack[15:12] = dstdp[25:22];
assign pack[31:16] = 16'h0000;

// DSP_A-5Q.NET (281) - modulo[0-31] : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (modulowr) begin
			modulo[31:0] <= gpu_din[31:0];
		end
	end
end

// DSP_A-5Q.NET (283) - modalu[0-31] : mx2
assign modalu[31:0] = (modulo[31:0] & dstdp[31:0]) | (~modulo[31:0] & aluq[31:0]);

// DSP_A-5Q.NET (289) - mirror[0] : join
assign mirror[0] = dstdp[31];
assign mirror[1] = dstdp[30];
assign mirror[2] = dstdp[29];
assign mirror[3] = dstdp[28];
assign mirror[4] = dstdp[27];
assign mirror[5] = dstdp[26];
assign mirror[6] = dstdp[25];
assign mirror[7] = dstdp[24];
assign mirror[8] = dstdp[23];
assign mirror[9] = dstdp[22];
assign mirror[10] = dstdp[21];
assign mirror[11] = dstdp[20];
assign mirror[12] = dstdp[19];
assign mirror[13] = dstdp[18];
assign mirror[14] = dstdp[17];
assign mirror[15] = dstdp[16];
assign mirror[16] = dstdp[15];
assign mirror[17] = dstdp[14];
assign mirror[18] = dstdp[13];
assign mirror[19] = dstdp[12];
assign mirror[20] = dstdp[11];
assign mirror[21] = dstdp[10];
assign mirror[22] = dstdp[9];
assign mirror[23] = dstdp[8];
assign mirror[24] = dstdp[7];
assign mirror[25] = dstdp[6];
assign mirror[26] = dstdp[5];
assign mirror[27] = dstdp[4];
assign mirror[28] = dstdp[3];
assign mirror[29] = dstdp[2];
assign mirror[30] = dstdp[1];
assign mirror[31] = dstdp[0];

// ARITH.NET (237) - resmux : mx8p
always @(*)
begin
	case(resselp[2:0])
		3'b000		: resd[31:0] = aluq[31:0];
		3'b001		: resd[31:0] = brlq[31:0];
		3'b010		: resd[31:0] = satval[31:0];
		3'b011		: resd[31:0] = mulq[31:0];
		3'b100		: resd[31:0] = aluq[31:0];
		3'b101		: resd[31:0] = normi[31:0];
		3'b110		: resd[31:0] = (JERRY==0) ? pack[31:0] : modalu[31:0];
		default		: resd[31:0] = (JERRY==0) ? unpack[31:0] : mirror[31:0];
	endcase
end

// ARITH.NET (243) - resldt : or2u
assign resldt = resldp | macop_pp;

// ARITH.NET (244) - resreg : fdsync32
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (resldt) begin
			result_obuf[31:0] <= resd[31:0];
		end
	end
end

// ARITH.NET (249) - zerodet : nr32
assign zerodet = ~(|resd[31:0]);

// ARITH.NET (250) - zfi : mx4
assign zfi = flagwr ? (gpu_din[0]) : (flagldp ? zerodet : zero_flag_obuf);

// ARITH.NET (252) - zeroflag : fd2q
// ARITH.NET (264) - carryflag : fd2q
// ARITH.NET (269) - negaflag : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			zero_flag_obuf <= 1'b0;
			carry_flag_obuf <= 1'b0;
			nega_flag_obuf <= 1'b0;
		end else begin
			zero_flag_obuf <= zfi;
			carry_flag_obuf <= cfi;
			nega_flag_obuf <= nfi;
		end
	end
end

// ARITH.NET (260) - cfisel0 : aor1
assign cfisel[0] = (flagldp & ~resselp[0]) | flagwr;

// ARITH.NET (261) - cfisel1 : aor1
assign cfisel[1] = (flagldp & resselp[0]) | flagwr;

// ARITH.NET (262) - cfi : mx4
assign cfi = cfisel[1] ? (cfisel[0] ? gpu_din[1] : brl_carry) : (cfisel[0] ? alu_co : carry_flag_obuf);

// ARITH.NET (267) - nfi : mx4
assign nfi = flagwr ? (gpu_din[2]) : (flagldp ? resd[31] : nega_flag_obuf);

// ARITH.NET (273) - flagrd[0] : ts
assign gpu_dout_out[0] = zero_flag_obuf;
assign gpu_dout_oe = flagrd;

// ARITH.NET (274) - flagrd[1] : ts
assign gpu_dout_out[1] = carry_flag_obuf;

// ARITH.NET (275) - flagrd[2] : ts
assign gpu_dout_out[2] = nega_flag_obuf;
endmodule
