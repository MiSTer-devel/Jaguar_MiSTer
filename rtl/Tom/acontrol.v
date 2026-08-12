//`include "defs.v"

module _acontrol
(
	output [2:0] addasel,
	output [1:0] addbsel,
	output addqsel,
	output [2:0] adda_xconst,
	output adda_yconst,
	output addareg,
	output a1fracldi,
	output a1ptrldi,
	output a2ptrldi,
	output [5:0] dend,
	output dsta2,
	output [5:0] dstart,
	output [15:0] dstxp,
	output [2:0] modx,
	output phrase_cycle,
	output phrase_mode,
	output [2:0] pixsize,
	output [3:0] pwidth,
	output [5:0] srcshift,
	output suba_x,
	output suba_y,
	input [2:0] a1_pixsize,
	input [14:0] a1_win_x,
	input [15:0] a1_x,
	input [1:0] a1addx,
	input a1addy,
	input a1xsign,
	input a1ysign,
	input a1updatei,
	input a1fupdatei,
	input [2:0] a2_pixsize,
	input [15:0] a2_x,
	input [1:0] a2addx,
	input a2addy,
	input a2xsign,
	input a2ysign,
	input a2updatei,
	input [1:0] atick,
	input aticki_0,
	input bcompen,
	input clk,
	input cmdld,
	input dest_cycle_1,
	input dsta_addi,
	input [31:0] gpu_din,
	input [2:0] icount,
	input inner0,
	input [2:0] pixa,
	input srca_addi,
	input srcen,
	input sshftld,
	input step_inner,
	input sys_clk // Generated
);
reg a1update = 1'b0;
reg a1fupdate = 1'b0;
reg a2update = 1'b0;
wire a1_addi;
wire a2_addi;
reg a1_add = 1'b0;
reg a2_add = 1'b0;
wire [2:0] addaseli;
wire addas0t;
wire [2:0] a1xp;
wire [1:0] a1xp1t;
wire a1xp2t;
wire [2:0] a2xp;
wire [1:0] a2xp1t;
wire a2xp2t;
wire [2:0] a1_xconst;
wire [2:0] a2_xconst;
wire [1:0] addaregt;
wire addaregi;
wire [1:0] addbseli;
wire addbsl1t;
wire maska1;
wire [2:0] maska1b;
wire maska2;
wire [2:0] maska2b;
wire [1:0] suba_xt;
wire [1:0] suba_yt;
wire a1pldt;
wire a1fldt;
wire a2pldt;
wire [1:0] mdt;
wire pcsela2;
wire [1:0] phct;
wire [5:3] smask;
wire [1:0] mask4t;
wire [2:0] mask5t;
wire [5:0] dstarta;
wire mpipe_0;
wire [5:0] dstartb;
reg [5:0] dstartbl = 6'h0;
reg [5:0] dstartp = 6'h0;
wire [14:1] pseq;
wire [1:0] rmpt;
wire penden;
wire pixel8;
wire pixel16;
wire pixel32;
wire [5:3] wmb;
wire [1:0] wmb4t;
wire [2:0] wmb5t;
wire [6:3] window_mask;
wire [5:3] imb;
wire [1:0] imb4t;
wire [2:0] imb5t;
wire [6:3] inner_mask;
wire wgt;
wire [5:3] emask;
wire [5:0] pm;
wire [5:0] pma;
wire [4:0] pmc;
wire [5:0] denda;
wire [5:0] dendb;
reg [5:0] dendbl = 6'h0;
reg [5:0] dendp = 6'h0;
wire [5:0] srcxp;
wire [5:0] shftt;
wire [5:0] shftv;
wire pobb0t;
wire [2:0] pobb;
wire pobb1t;
wire pobbsel;
wire loshen_n;
wire [2:0] loshd;
wire [5:0] shfti;
wire hishen_n;

// Output buffers
reg dsta2_obuf = 1'b0;
reg [5:0] srcshift_obuf = 6'h0;
reg [5:0] dstart_ = 6'h0;
reg [5:0] dend_ = 6'h0;
reg [2:0] addasel_ = 3'h0;
reg [1:0] addbsel_ = 2'h0;
reg addareg_ = 1'b0;

//wire resetl = reset_n;
reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// Output buffers
assign dsta2 = dsta2_obuf;
assign srcshift[5:0] = srcshift_obuf[5:0];
assign dstart[5:0] = dstart_[5:0];
assign dend[5:0] = dend_[5:0];
assign addasel[2:0] = addasel_[2:0];
assign addbsel[1:0] = addbsel_[1:0];
assign addareg = addareg_;

// ACONTROL.NET (79) - dsta2 : fdsyncu
// ACONTROL.NET (83) - a1update : fd1
// ACONTROL.NET (84) - a1fupdate : fd1
// ACONTROL.NET (86) - a2update : fd1
// ACONTROL.NET (95) - a1_add : fd1
// ACONTROL.NET (96) - a2_add : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (cmdld) begin
			dsta2_obuf <= gpu_din[11];
		end
		a1update <= a1updatei;
		a1fupdate <= a1fupdatei;
		a2update <= a2updatei;
		a1_add <= a1_addi;
		a2_add <= a2_addi;
	end
end

// ACONTROL.NET (93) - a1_addi : mx2
assign a1_addi = (dsta2) ? srca_addi : dsta_addi;

// ACONTROL.NET (94) - a2_addi : mx2
assign a2_addi = (dsta2) ? dsta_addi : srca_addi;

// ACONTROL.NET (114) - addaseli[2] : join
assign addaseli[2] = a2updatei;

// ACONTROL.NET (115) - addaseli[1] : an3
assign addaseli[1] = a1_addi & a1addx[0] & a1addx[1];

// ACONTROL.NET (116) - addas0t : nd4
assign addas0t = ~(a1_addi & aticki_0 & &a1addx[1:0]);

// ACONTROL.NET (117) - addaseli[0] : nd2
assign addaseli[0] = ~(~a1fupdatei & addas0t);

// ACONTROL.NET (118) - addasel[0-2] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		addasel_[2:0] <= addaseli[2:0];
	end
end

// ACONTROL.NET (135) - a1xp0 : join
assign a1xp[0] = a1_pixsize[0];

// ACONTROL.NET (136) - a1xp1t0 : nd2
assign a1xp1t[0] = ~(~a1_pixsize[0] & ~a1_pixsize[1]);

// ACONTROL.NET (137) - a1xp1t1 : nd3
assign a1xp1t[1] = ~(a1_pixsize[0] & a1_pixsize[1] & ~a1_pixsize[2]);

// ACONTROL.NET (139) - a1xp1 : nd2
assign a1xp[1] = ~(&a1xp1t[1:0]);

// ACONTROL.NET (140) - a1xp2t : nd2
assign a1xp2t = ~(a1_pixsize[0] & a1_pixsize[1]);

// ACONTROL.NET (141) - a1xp2 : an2
assign a1xp[2] = a1xp2t & ~a1_pixsize[2];

// ACONTROL.NET (143) - a2xp0 : join
assign a2xp[0] = a2_pixsize[0];

// ACONTROL.NET (144) - a2xp1t0 : nd2
assign a2xp1t[0] = ~(~a2_pixsize[0] & ~a2_pixsize[1]);

// ACONTROL.NET (145) - a2xp1t1 : nd3
assign a2xp1t[1] = ~(a2_pixsize[0] & a2_pixsize[1] & ~a2_pixsize[2]);

// ACONTROL.NET (147) - a2xp1 : nd2
assign a2xp[1] = ~(a2xp1t[0] & a2xp1t[1]);

// ACONTROL.NET (148) - a2xp2t : nd2
assign a2xp2t = ~(&a2_pixsize[1:0]);

// ACONTROL.NET (149) - a2xp2 : an2
assign a2xp[2] = a2xp2t & ~a2_pixsize[2];

// ACONTROL.NET (153) - a1_xconst[0] : aor1
assign a1_xconst[0] = (a1xp[0] & ~a1addx[0]) | a1addx[1];

// ACONTROL.NET (155) - a1_xconst[1] : aor1
assign a1_xconst[1] = (a1xp[1] & ~a1addx[0]) | a1addx[1];

// ACONTROL.NET (157) - a1_xconst[2] : aor1
assign a1_xconst[2] = (a1xp[2] & ~a1addx[0]) | a1addx[1];

// ACONTROL.NET (159) - a2_xconst[0] : aor1
assign a2_xconst[0] = (a2xp[0] & ~a2addx[0]) | a2addx[1];

// ACONTROL.NET (161) - a2_xconst[1] : aor1
assign a2_xconst[1] = (a2xp[1] & ~a2addx[0]) | a2addx[1];

// ACONTROL.NET (163) - a2_xconst[2] : aor1
assign a2_xconst[2] = (a2xp[2] & ~a2addx[0]) | a2addx[1];

// ACONTROL.NET (165) - adda_xconst[0-2] : mx2
assign adda_xconst[2:0] = (a2_add) ? a2_xconst[2:0] : a1_xconst[2:0];

// ACONTROL.NET (170) - adda_yconst : niv
assign adda_yconst = a1addy;

// ACONTROL.NET (180) - addaregt[0] : an3
assign addaregt[0] = a1_addi & &a1addx[1:0];

// ACONTROL.NET (181) - addaregt[1] : an3
assign addaregt[1] = a2_addi & &a2addx[1:0];

// ACONTROL.NET (182) - addaregi : or5
assign addaregi = |addaregt[1:0] | a1updatei | a1fupdatei | a2updatei;

// ACONTROL.NET (184) - addareg : fd1qu
// ACONTROL.NET (200) - addbsel[0-1] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		addareg_ <= addaregi;
		addbsel_[1:0] <= addbseli[1:0];
	end
end

// ACONTROL.NET (196) - addbseli[0] : or2
assign addbseli[0] = a2updatei | a2_addi;

// ACONTROL.NET (197) - addbsel1t : nd4
assign addbsl1t = ~(a1_addi & aticki_0 & &a1addx[1:0]);

// ACONTROL.NET (199) - addbseli[1] : nd2
assign addbseli[1] = ~(~a1fupdatei & addbsl1t);

// ACONTROL.NET (214) - maska1 : nr3
assign maska1 = ~(|a1addx[1:0] | ~a1_add);

// ACONTROL.NET (215) - maska1b[0-2] : an2
assign maska1b[2:0] = maska1 ? a1xp[2:0] : 3'h0;

// ACONTROL.NET (216) - maska2 : nr3
assign maska2 = ~(|a2addx[1:0] | ~a2_add);

// ACONTROL.NET (217) - maska2b[0-2] : an2
assign maska2b[2:0] = maska2 ? a2xp[2:0] : 3'h0;

// ACONTROL.NET (218) - modx[0-2] : mx2
assign modx[2:0] = (a2_add) ? maska2b[2:0] : maska1b[2:0];

// ACONTROL.NET (224) - addqsel : or5
assign addqsel = a1_add | a2_add | a1update | a1fupdate | a2update;

// ACONTROL.NET (230) - suba_xt0 : nd4
assign suba_xt[0] = ~(a1_add & a1addx[0] & ~a1addx[1] & a1xsign);

// ACONTROL.NET (232) - suba_xt1 : nd4
assign suba_xt[1] = ~(a2_add & a2addx[0] & ~a2addx[1] & a2xsign);

// ACONTROL.NET (234) - suba_x : nd2h
assign suba_x = ~(&suba_xt[1:0]);

// ACONTROL.NET (235) - suba_yt0 : nd3
assign suba_yt[0] = ~(a1_add & a1addy & a1ysign);

// ACONTROL.NET (236) - suba_yt1 : nd3
assign suba_yt[1] = ~(a2_add & a2addy & a2ysign);

// ACONTROL.NET (237) - suba_y : nd2h
assign suba_y = ~(&suba_yt[1:0]);

// ACONTROL.NET (241) - a1pldt : nd2
assign a1pldt = ~(atick[1] & a1_add);

// ACONTROL.NET (242) - a1ptrldi : nd2
assign a1ptrldi = ~(~a1update & a1pldt);

// ACONTROL.NET (244) - a1fldt : nd4
assign a1fldt = ~(atick[0] & a1_add & &a1addx[1:0]);

// ACONTROL.NET (245) - a1fracldi : nd2
assign a1fracldi = ~(~a1fupdate & a1fldt);

// ACONTROL.NET (247) - a2pldt : nd2
assign a2pldt = ~(atick[1] & a2_add);

// ACONTROL.NET (248) - a2ptrldi : nd2
assign a2ptrldi = ~(~a2update & a2pldt);

// ACONTROL.NET (255) - mdt0 : nd3
assign mdt[0] = ~(dsta2 & ~a2addx[0] & ~a2addx[1]);

// ACONTROL.NET (256) - mdt1 : nd3
assign mdt[1] = ~(~dsta2 & ~a1addx[0] & ~a1addx[1]);

// ACONTROL.NET (257) - phrase_mode : nd2h
assign phrase_mode = ~(mdt[0] & mdt[1]);

// ACONTROL.NET (266) - pcsela2 : en
assign pcsela2 = ~(dsta2 ^ dest_cycle_1);

// ACONTROL.NET (268) - phct0 : nd3
assign phct[0] = ~(pcsela2 & ~a2addx[0] & ~a2addx[1]);

// ACONTROL.NET (269) - phct1 : nd3
assign phct[1] = ~(~pcsela2 & ~a1addx[0] & ~a1addx[1]);

// ACONTROL.NET (270) - phrase_cycle : nd2
assign phrase_cycle = ~(&phct[1:0]);

// ACONTROL.NET (286) - pixsize[0-2] : mx2u
assign pixsize[2:0] = (dsta2) ? a2_pixsize[2:0] : a1_pixsize[2:0];

// ACONTROL.NET (290) - mask[3] : an4
assign smask[3] = dstxp[0] & pixsize[2:0] == 3'b011;

// ACONTROL.NET (292) - mask4t0 : nd4
assign mask4t[0] = ~(dstxp[1] & pixsize[2:0] == 3'b011);

// ACONTROL.NET (294) - mask4t1 : nd4
assign mask4t[1] = ~(dstxp[0] & pixsize[2:0] == 3'b100);

// ACONTROL.NET (296) - mask[4] : nd2
assign smask[4] = ~(&mask4t[1:0]);

// ACONTROL.NET (297) - mask5t0 : nd4
assign mask5t[0] = ~(dstxp[2] & pixsize[2:0] == 3'b011);

// ACONTROL.NET (299) - mask5t1 : nd4
assign mask5t[1] = ~(dstxp[1] & pixsize[2:0] == 3'b100);

// ACONTROL.NET (301) - mask5t2 : nd4
assign mask5t[2] = ~(dstxp[0] & pixsize[2:0] == 3'b101);

// ACONTROL.NET (303) - mask[5] : nd3
assign smask[5] = ~(&mask5t[2:0]);

// ACONTROL.NET (308) - dstarta[0-2] : an2
assign dstarta[2:0] = ~phrase_mode ? pixa[2:0] : 3'h0;

// ACONTROL.NET (309) - dstarta[3-5] : an2
assign dstarta[5:3] = phrase_mode ? smask[5:3] : 3'h0;

// ACONTROL.NET (311) - mpipe[0] : nivm
assign mpipe_0 = atick[1];

// ACONTROL.NET (312) - dstartb[0-5] : mx2
assign dstartb[5:0] = (mpipe_0) ? dstarta[5:0] : dstartbl[5:0];

// ACONTROL.NET (313) - dstartbl[0-5] : fd1q
// ACONTROL.NET (318) - dstartp[0-5] : fdsync
// ACONTROL.NET (320) - dstart[0-5] : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (step_inner) begin
			dstartp[5:0] <= dstartb[5:0];
		end
		dstartbl[5:0] <= dstartb[5:0];
		dstart_[5:0] <= dstartp[5:0];
	end
end

// ACONTROL.NET (347) - dstxp : mx2
assign dstxp[15:0] = (dsta2) ? a2_x[15:0] : a1_x[15:0];

// ACONTROL.NET (349) - pseq[1-14] : eo
assign pseq[14:1] = dstxp[14:1] ^ a1_win_x[14:1];

// ACONTROL.NET (360) - rmpt0 : an4
assign rmpt[0] = pseq[1] & pixsize[2:0] == 3'b101;

// ACONTROL.NET (362) - rmpt1 : an3
assign rmpt[1] = pseq[2] & pixsize[2:1] == 2'b10;

// ACONTROL.NET (368) - ewmt5 : nr14
assign penden = ~(|rmpt[1:0] | |pseq[14:3]);

// ACONTROL.NET (374) - pixel8 : an3p
assign pixel8 = pixsize[2:0] == 3'b011;

// ACONTROL.NET (375) - pixel16 : an3
assign pixel16 = pixsize[2:0] == 3'b100;

// ACONTROL.NET (376) - pixel32 : an3
assign pixel32 = pixsize[2:0] == 3'b101;

// ACONTROL.NET (379) - wmb3 : an2
assign wmb[3] = a1_win_x[0] & pixel8;

// ACONTROL.NET (380) - wmb4t0 : nd2
assign wmb4t[0] = ~(a1_win_x[1] & pixel8);

// ACONTROL.NET (381) - wmb4t1 : nd2
assign wmb4t[1] = ~(a1_win_x[0] & pixel16);

// ACONTROL.NET (382) - wmb4 : nd2
assign wmb[4] = ~(&wmb4t[1:0]);

// ACONTROL.NET (383) - wmb5t0 : nd2
assign wmb5t[0] = ~(a1_win_x[2] & pixel8);

// ACONTROL.NET (384) - wmb5t1 : nd2
assign wmb5t[1] = ~(a1_win_x[1] & pixel16);

// ACONTROL.NET (385) - wmb5t2 : nd2
assign wmb5t[2] = ~(a1_win_x[0] & pixel32);

// ACONTROL.NET (386) - wmb5 : nd3
assign wmb[5] = ~(&wmb5t[2:0]);

// ACONTROL.NET (388) - wmt[3-5] : an2
assign window_mask[5:3] = penden ? wmb[5:3] : 3'h0;

// ACONTROL.NET (393) - imb3 : an2
assign imb[3] = icount[0] & pixel8;

// ACONTROL.NET (394) - imb4t0 : nd2
assign imb4t[0] = ~(icount[1] & pixel8);

// ACONTROL.NET (395) - imb4t1 : nd2
assign imb4t[1] = ~(icount[0] & pixel16);

// ACONTROL.NET (396) - imb4 : nd2
assign imb[4] = ~(imb4t[0] & imb4t[1]);

// ACONTROL.NET (397) - imb5t0 : nd2
assign imb5t[0] = ~(icount[2] & pixel8);

// ACONTROL.NET (398) - imb5t1 : nd2
assign imb5t[1] = ~(icount[1] & pixel16);

// ACONTROL.NET (399) - imb5t2 : nd2
assign imb5t[2] = ~(icount[0] & pixel32);

// ACONTROL.NET (400) - imb5 : nd3
assign imb[5] = ~(&imb5t[2:0]);

// ACONTROL.NET (402) - innerm[3-5] : an2
assign inner_mask[5:3] = inner0 ? imb[5:3] : 3'h0;

// ACONTROL.NET (407) - window_mask[6] : nr3
assign window_mask[6] = ~(|window_mask[5:3]);

// ACONTROL.NET (408) - inner_mask[6] : nr3p
assign inner_mask[6] = ~(|inner_mask[5:3]);

// ACONTROL.NET (413) - mcomp : mag4
assign wgt = window_mask[6:3] > inner_mask[6:3];

// ACONTROL.NET (419) - emask[3-5] : mx2
assign emask[5:3] = (wgt) ? inner_mask[5:3] : window_mask[5:3];

// ACONTROL.NET (425) - pm0 : an3
assign pm[0] = pixsize[2:0]==3'h0;

// ACONTROL.NET (426) - pm1 : an3
assign pm[1] = pixsize[2:0]==3'h1;

// ACONTROL.NET (427) - pm2 : an3
assign pm[2] = pixsize[2:0]==3'h2;

// ACONTROL.NET (428) - pm3 : an3
assign pm[3] = pixsize[2:0]==3'h3;

// ACONTROL.NET (429) - pm4 : an3
assign pm[4] = pixsize[2:0]==3'h4;

// ACONTROL.NET (430) - pm5 : an3
assign pm[5] = pixsize[2:0]==3'h5;

// ACONTROL.NET (432) - pma[0] : ha1
assign pma[5:0] = pm[5:0] + pixa[2:0];

// ACONTROL.NET (441) - denda[0-2] : an2
// ACONTROL.NET (442) - denda[3-5] : mx2
assign denda[2:0] = ~phrase_mode ? pma[2:0] : 3'h0;
assign denda[5:3] = ~phrase_mode ? pma[5:3] : emask[5:3];

// ACONTROL.NET (445) - dendb[0-5] : mx2
assign dendb[5:0] = (mpipe_0) ? denda[5:0] : dendbl[5:0];

// ACONTROL.NET (447) - dendbl[0-5] : fd1q
// ACONTROL.NET (449) - dendp[0-5] : fdsync
// ACONTROL.NET (451) - dend[0-5] : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (step_inner) begin
			dendp[5:0] <= dendb[5:0];
		end
		dendbl[5:0] <= dendb[5:0];
		dend_[5:0] <= dendp[5:0];
	end
end

// ACONTROL.NET (472) - srcxp\[0-5] : mxi2
assign srcxp[5:0] = dsta2 ? a1_x[5:0] : a2_x[5:0];

// ACONTROL.NET (474) - shftt[0] : fa1
assign shftt[5:0] = dstxp[5:0] - srcxp[5:0];

// ACONTROL.NET (490) - shftv0 : an4
// ACONTROL.NET (492) - shftv1 : mx2g
wire [2:0] pixsizet = (&pixsize[2:1]) ? (pixsize[2:0] & 3'b101) : pixsize[2:0]; //[7:6] are the same as [5:4] 
wire [5:0] shftv_ = shftt[5:0] << pixsizet[2:0];
assign shftv[5:2] = shftv_[5:2];
assign shftv[1] = shftv_[1] & ~pixsize[1];  // Check this. This looks like a bug; should have pixsize_0_obuf as input s on line 492
assign shftv[0] = shftv_[0];

// ACONTROL.NET (508) - pobb0t : or3
assign pobb0t = pixel8 | pixel16 | pixel32;

// ACONTROL.NET (509) - pobb0 : an2
assign pobb[0] = pobb0t & dstxp[0];

// ACONTROL.NET (510) - pobb1t : or2
assign pobb1t = pixel8 | pixel16;

// ACONTROL.NET (511) - pobb1 : an2
assign pobb[1] = pobb1t & dstxp[1];

// ACONTROL.NET (512) - pobb2 : an2
assign pobb[2] = pixel8 & dstxp[2];

// ACONTROL.NET (514) - pobbsel : an2
assign pobbsel = phrase_mode & bcompen;

// ACONTROL.NET (515) - loshen : nr2
assign loshen_n = ~(srcen | pobbsel);

// ACONTROL.NET (516) - loshd[0-2] : mx2
assign loshd[2:0] = (pobbsel) ? pobb[2:0] : shftv[2:0];

// ACONTROL.NET (518) - shfti[0-2] : mx2g
assign shfti[2:0] = loshen_n ? 3'h0 : (sshftld ? loshd[2:0] : srcshift_obuf[2:0]);

// ACONTROL.NET (523) - hishen\ : nd2
assign hishen_n = ~(srcen & phrase_mode);

// ACONTROL.NET (524) - shfti[3-5] : mx2g
assign shfti[5:3] = hishen_n ? 3'h0 : (sshftld ? shftv[5:3] : srcshift_obuf[5:3]);

// ACONTROL.NET (526) - srcshift[0-5] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		srcshift_obuf[5:0] <= shfti[5:0];
	end
end

// ACONTROL.NET (541) - pwidth0 : fa1
// ACONTROL.NET (543) - pwidth1 : fa1
// ACONTROL.NET (545) - pwidth2 : fa1
assign pwidth[2:0] = dendp[5:3] - dstartp[5:3];

// ACONTROL.NET (547) - pwidth3 : nr6
assign pwidth[3] = ~(|dendp[5:3] | |dstartp[5:3]);

endmodule
