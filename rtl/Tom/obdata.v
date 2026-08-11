//`include "defs.v"
// altera message_off 10036

module _obdata
(
	input aout_9,
	input [15:0] din,
	input reads,
	input palen,
	input clutt,
	input [63:0] d,
	input obdlatch,
	input mode1,
	input mode2,
	input mode4,
	input mode8,
	input mode16,
	input mode24,
	input scaledtype,
	input rmw,
	input [7:1] index,
	input xld,
	input reflected,
	input transen,
	input [7:0] xscale,
	input resetl,
	input clk,
	input obld_1,
	input obld_2,
	input hilo,
	input lbt,
	input [10:1] at,
	output obdone,
	output obdready,
	output [9:1] lbwa,
	output [1:0] lbwe,
	output [31:0] lbwd,
	output offscreen,
	output rmw1,
	output lben,
	output [15:0] dr_out,
	output dr_oe,
	input sys_clk // Generated
);
wire [15:0] di;
wire [7:0] aa;
wire [7:0] ab;
reg [8:0] xrem = 9'h000;
wire [15:0] d9h;
wire [15:0] d9l;
wire [15:0] pda_out;
wire pda_oe;
wire [15:0] pdb_out;
wire pdb_oe;
wire [5:0] pa;
wire obdclk;
reg [63:0] d1 = 64'h0000000000000000;
reg [63:0] d2 = 64'h0000000000000000;
wire nextphrase;
reg scaledi = 1'b0;
wire scaled;
reg rmw1i = 1'b0;
wire empty;
reg full = 1'b0;
wire notfull;
wire notobdlatch;
wire empty0;
wire empty1;
wire empty2;
reg smq0 = 1'b1;
wire [31:0] d3;
wire [15:0] d4;
wire [7:0] d5;
wire [3:0] d6;
wire [1:0] d7;
wire [7:0] pra;
wire [3:0] pra0;
wire [3:0] pra1;
wire [3:0] pra2;
wire [3:0] pra3;
wire [7:0] prb;
wire [3:0] prb0;
wire [3:0] prb1;
wire [3:0] prb2;
wire [3:0] prb3;
wire [7:0] paad;
wire [7:0] pabd;
reg [7:0] paaq = 8'h00;
reg [7:0] pabq = 8'h00;
wire [7:0] paa;
wire [7:0] pab;
wire ncst;
wire busy;
reg busy1 = 1'b0;
wire cs;
wire csl;
wire prw;
wire [15:0] pdi;
reg [15:0] pd = 16'h0000;
wire pden;
wire pdeni;
wire pwdeni;
wire pwden;
wire writes;
wire physicali;
wire phys;
wire hilob;
wire [31:0] d8;
reg [31:0] d9 = 32'h00000000;
reg nextbits1 = 1'b0;
wire nextbits;
reg nextbits2 = 1'b0;
wire delpixi;
wire delpix;
reg [15:0] da = 16'h0000;
wire del1;
reg [9:0] lbwa_ = 10'h000;
reg [1:0] lbwe_ = 2'b00;
wire delayed;
wire notscaled;
wire [15:0] db;
wire pswap;
reg [5:0] ip = 6'h00;
wire reset;
reg [5:0] pad = 6'h00;
wire [5:1] pai;
wire [5:0] ipd;
wire nip;
wire p2done;
wire modew;
wire vcc;
wire [5:1] phd;
wire phdone;
wire notphdone;
reg nextx1 = 1'b0;
wire nextx;
wire nextxx;
reg [11:0] lbwad = 12'h000;
wire lci_0;
wire up;
wire [9:0] lbwadd;
wire lcil_1;
wire nota_4;
wire nota_5;
wire nota_8;
wire nota_10;
wire nota_11;
wire c_5;
wire c_7;
wire c_8;
wire c_9;
wire c_11;
wire left;
wire right;
wire onscreen;
wire offscreeni;
wire notoffscreen;
wire zero1a;
wire zero2a;
wire zero4a;
wire zero8a;
wire zero16a0;
wire zero16a1;
wire trans1a;
wire trans2a;
wire trans4a;
wire trans8a;
wire trans16a;
wire transa;
wire nottransa;
wire zero1b;
wire zero2b;
wire zero4b;
wire zero8b;
wire zero16b0;
wire zero16b1;
wire trans1b;
wire trans2b;
wire trans4b;
wire trans8b;
wire trans16b;
wire transb;
wire nottransb;
wire smd0;
reg smq1 = 1'b0;
wire smd1;
reg smq2i= 1'b0;
wire smd2;
wire smq2;
wire d00;
wire d01;
wire notremgte2;
wire d02;
wire d10;
wire d11;
wire d12;
wire d13;
wire remgte2;
wire d20;
wire notrmw;
wire d21;
wire d22;
wire d23;
wire d24;
wire np0;
wire np1;
wire np2;
wire nextphrasei;
wire nx0;
wire remgte1;
wire nx1;
wire nb0;
wire nb1;
wire nextbitsi;
wire lbwrite;
wire nntransa;
wire nntransb;
wire [8:1] lbwea;
wire [8:1] lbweb;
wire lbweb51;
wire lbweb52;
wire pswapd;
wire lbwea80;
wire lbwea81;
wire notlbwad_0;
wire lbweb80;
wire lbweb81;
reg [3:1] lbw = 3'h0;
wire lbend;
reg lbeni = 1'b0;
reg pa1_0 = 1'b0;
wire pa2_0;
wire oddeven;
reg pswapi = 1'b0;
wire [8:0] xrd;
wire [8:0] sum;
wire [8:0] xs;
wire [8:5] diff;
wire notremgte2i;
wire [15:0] clut_a_a0_out;
wire        clut_a_a0_oe;
wire [15:0] clut_a_a1_out;
wire        clut_a_a1_oe;
wire [15:0] clut_b_a0_out;
wire        clut_b_a0_oe;
wire [15:0] clut_b_a1_out;
wire        clut_b_a1_oe;

// Output buffers
wire offscreen_obuf;
wire rmw1_obuf;

// Output buffers
assign offscreen = offscreen_obuf;
assign rmw1 = rmw1_obuf;

assign obdclk = obdlatch;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// OBDATA.NET (70) - d1[0-63] : slatch
// OBDATA.NET (71) - d2[0-63] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (obdclk) begin
			d1[63:0] <= d[63:0];
		end
		if (nextphrase) begin
			d2[63:0] <= d1[63:0];
		end
	end
end

// OBDATA.NET (75) - scaledi : ldp1q
// OBDATA.NET (77) - rmw1i : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (obdclk) begin
		scaledi <= scaledtype; // ldp2q negedge // always @(d or g or cd)
	end
	if (~resetl) begin
		rmw1i <= 1'h0; // ldp2q negedge // always @(d or g or cd)
	end else if (obdclk) begin
		rmw1i <= rmw; // ldp2q negedge // always @(d or g or cd)
	end
end

// OBDATA.NET (76) - scaled : nivm
assign scaled = scaledi;

// OBDATA.NET (78) - rmw1 : nivu
assign rmw1_obuf = rmw1i;

// OBDATA.NET (80) - empty : or2
assign empty = offscreen_obuf | nextphrase;

// OBDATA.NET (81) - full : fjk2
always @(posedge sys_clk) // always @(posedge cp or negedge cd)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~old_resetl) begin
			full <= 1'b0;
		end else begin
			if (~obdlatch & empty) begin
				full <= 1'b0;
			end else if (obdlatch & ~empty) begin
				full <= 1'b1;
			end else if (obdlatch & empty) begin
				full <= ~full;
			end
		end
	end
end
assign notfull = ~full;

// OBDATA.NET (86) - notobdl : iv
assign notobdlatch = ~obdlatch;

// OBDATA.NET (87) - empty0 : nd2
assign empty0 = ~(notfull & notobdlatch);

// OBDATA.NET (88) - empty1 : iv
assign empty1 = ~nextphrase;

// OBDATA.NET (89) - empty2 : iv
assign empty2 = ~smq0;

// OBDATA.NET (91) - obdready : nd3
assign obdready = ~(empty0 & empty1 & empty2);

// OBDATA.NET (99) - d3[0-31] : mx2
assign d3[31:0] = (pa[5]) ? d2[63:32] : d2[31:0];

// OBDATA.NET (100) - d4[0-15] : mx2
assign d4[15:0] = (pa[4]) ? d3[31:16] : d3[15:0];

// OBDATA.NET (101) - d5[0-7] : mx2
assign d5[7:0] = (pa[3]) ? d4[15:8] : d4[7:0];

// OBDATA.NET (102) - d6[0-3] : mx2
assign d6[3:0] = (pa[2]) ? d5[7:4] : d5[3:0];

// OBDATA.NET (103) - d7[0-1] : mx2
assign d7[1:0] = (pa[1]) ? d6[3:2] : d6[1:0];

// OBDATA.NET (107) - pra00 : nd2
assign pra0[0] = ~(d7[0] & mode1);

// OBDATA.NET (108) - pra01 : nd2
assign pra0[1] = ~(d6[0] & mode2);

// OBDATA.NET (109) - pra02 : nd2
assign pra0[2] = ~(d5[0] & mode4);

// OBDATA.NET (110) - pra03 : nd2
assign pra0[3] = ~(d4[0] & mode8);

// OBDATA.NET (111) - pra[0] : nd4
assign pra[0] = ~(&pra0[3:0]);

// OBDATA.NET (113) - pra10 : nd2
assign pra1[0] = ~(index[1] & mode1);

// OBDATA.NET (114) - pra11 : nd2
assign pra1[1] = ~(d6[1] & mode2);

// OBDATA.NET (115) - pra12 : nd2
assign pra1[2] = ~(d5[1] & mode4);

// OBDATA.NET (116) - pra13 : nd2
assign pra1[3] = ~(d4[1] & mode8);

// OBDATA.NET (117) - pra[1] : nd4
assign pra[1] = ~(&pra1[3:0]);

// OBDATA.NET (119) - pra20 : nd2
assign pra2[0] = ~(index[2] & mode1);

// OBDATA.NET (120) - pra21 : nd2
assign pra2[1] = ~(index[2] & mode2);

// OBDATA.NET (121) - pra22 : nd2
assign pra2[2] = ~(d5[2] & mode4);

// OBDATA.NET (122) - pra23 : nd2
assign pra2[3] = ~(d4[2] & mode8);

// OBDATA.NET (123) - pra[2] : nd4
assign pra[2] = ~(&pra2[3:0]);

// OBDATA.NET (125) - pra30 : nd2
assign pra3[0] = ~(index[3] & mode1);

// OBDATA.NET (126) - pra31 : nd2
assign pra3[1] = ~(index[3] & mode2);

// OBDATA.NET (127) - pra32 : nd2
assign pra3[2] = ~(d5[3] & mode4);

// OBDATA.NET (128) - pra33 : nd2
assign pra3[3] = ~(d4[3] & mode8);

// OBDATA.NET (129) - pra[3] : nd4
assign pra[3] = ~(&pra3[3:0]);

// OBDATA.NET (131) - pra[4] : mx2
assign pra[7:4] = (mode8) ? d4[7:4] : index[7:4];

// OBDATA.NET (136) - prb00 : nd2
assign prb0[0] = ~(d7[1] & mode1);

// OBDATA.NET (137) - prb01 : nd2
assign prb0[1] = ~(d6[2] & mode2);

// OBDATA.NET (138) - prb02 : nd2
assign prb0[2] = ~(d5[4] & mode4);

// OBDATA.NET (139) - prb03 : nd2
assign prb0[3] = ~(d4[8] & mode8);

// OBDATA.NET (140) - prb[0] : nd4
assign prb[0] = ~(&prb0[3:0]);

// OBDATA.NET (142) - prb10 : nd2
assign prb1[0] = ~(index[1] & mode1);

// OBDATA.NET (143) - prb11 : nd2
assign prb1[1] = ~(d6[3] & mode2);

// OBDATA.NET (144) - prb12 : nd2
assign prb1[2] = ~(d5[5] & mode4);

// OBDATA.NET (145) - prb13 : nd2
assign prb1[3] = ~(d4[9] & mode8);

// OBDATA.NET (146) - prb[1] : nd4
assign prb[1] = ~(&prb1[3:0]);

// OBDATA.NET (148) - prb20 : nd2
assign prb2[0] = ~(index[2] & mode1);

// OBDATA.NET (149) - prb21 : nd2
assign prb2[1] = ~(index[2] & mode2);

// OBDATA.NET (150) - prb22 : nd2
assign prb2[2] = ~(d5[6] & mode4);

// OBDATA.NET (151) - prb23 : nd2
assign prb2[3] = ~(d4[10] & mode8);

// OBDATA.NET (152) - prb[2] : nd4
assign prb[2] = ~(&prb2[3:0]);

// OBDATA.NET (154) - prb30 : nd2
assign prb3[0] = ~(index[3] & mode1);

// OBDATA.NET (155) - prb31 : nd2
assign prb3[1] = ~(index[3] & mode2);

// OBDATA.NET (156) - prb32 : nd2
assign prb3[2] = ~(d5[7] & mode4);

// OBDATA.NET (157) - prb33 : nd2
assign prb3[3] = ~(d4[11] & mode8);

// OBDATA.NET (158) - prb[3] : nd4
assign prb[3] = ~(&prb3[3:0]);

// OBDATA.NET (160) - prb[4] : mx2
assign prb[7:4] = (mode8) ? d4[15:12] : index[7:4];

// OBDATA.NET (167) - paad[0-7] : mx2p
assign paad[7:0] = (clutt) ? at[8:1] : pra[7:0];

// OBDATA.NET (168) - pabd[0-7] : mx2p
assign pabd[7:0] = (clutt) ? at[8:1] : prb[7:0];

// OBDATA.NET (172) - pral[0-7] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		paaq[7:0] <= paad[7:0];
		pabq[7:0] <= pabd[7:0];
	end
end

// OBDATA.NET (175) - paa[0-7] : hdly2b
assign paa[7:0] = paaq[7:0]; // delay only needed if using external memory (not bram)?

// OBDATA.NET (176) - pab[0-7] : hdly2b
assign pab[7:0] = pabq[7:0]; // delay only needed if using external memory (not bram)?

// OBDATA.NET (178) - aa : join
assign aa[7:0] = paa[7:0];

// OBDATA.NET (179) - ab : join
assign ab[7:0] = pab[7:0];

// OBDATA.NET (183) - ncst : ivh
assign ncst = ~clk;

// OBDATA.NET (184) - busy : iv
assign busy = ~smq0;

// OBDATA.NET (185) - busy1 : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		busy1 <= busy;
	end
end

// OBDATA.NET (186) - cs : or2
assign cs = palen | busy1;

// OBDATA.NET (187) - csl : nd2x3
assign csl = ~(ncst & cs);

// OBDATA.NET (189) - clut1 : ab8016a
_ab8016a clut1_inst
(
	.z_out /* BUS */ (clut_a_a0_out[15:0]),
	.z_oe /* BUS */ (clut_a_a0_oe),
	.z_in /* BUS */ (pda_out[15:0]),
	.cen /* IN */ (csl),
	.rw /* IN */ (prw),
	.a /* IN */ (aa[7:0]),
	.sys_clk(sys_clk) // Generated
);

// OBDATA.NET (190) - clut2 : ab8016a
_ab8016a clut2_inst
(
	.z_out /* BUS */ (clut_b_a0_out[15:0]),
	.z_oe /* BUS */ (clut_b_a0_oe),
	.z_in /* BUS */ (pdb_out[15:0]),
	.cen /* IN */ (csl),
	.rw /* IN */ (prw),
	.a /* IN */ (ab[7:0]),
	.sys_clk(sys_clk) // Generated
);

// OBDATA.NET (194) - pdi[0-15] : mx2
assign pdi[15:0] = (aout_9) ? pdb_out[15:0] : pda_out[15:0];

// OBDATA.NET (195) - pd[0-15] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		pd[15:0] <= pdi[15:0];
	end
end

// OBDATA.NET (196) - dr[0-15] : ts
assign dr_out[15:0] = pd[15:0];
assign dr_oe = pden;

// OBDATA.NET (197) - pdeni : nd2
assign pdeni = ~(palen & reads);

// OBDATA.NET (198) - pden : ivh
assign pden = ~pdeni;

// OBDATA.NET (202) - pwdeni : nr2
assign pwdeni = ~(busy1 | pden);

// OBDATA.NET (203) - pwden : nivu
assign pwden = pwdeni;

// OBDATA.NET (205) - pwda : ts
assign clut_a_a1_out[15:0] = din[15:0];
assign clut_a_a1_oe = pwden;

// OBDATA.NET (206) - pwdb : ts
assign clut_b_a1_out[15:0] = din[15:0];
assign clut_b_a1_oe = pwden;

// OBDATA.NET (210) - iw : iv
assign writes = ~reads;

// OBDATA.NET (211) - prw : nd2
assign prw = ~(writes & palen);

// OBDATA.NET (215) - physicali : or2
assign physicali = mode16 | mode24;

// OBDATA.NET (216) - physical : nivu2
assign phys = physicali;

// OBDATA.NET (217) - hilob : nivu
assign hilob = hilo;

// OBDATA.NET (221) - d8[0-15] : mx4
assign d8[15:0] =
   (~phys & ~hilob)   ? pda_out[15:0] :
   ( phys & ~hilob)   ? d3[15:0]     :
   (~phys &  hilob)   ? pdb_out[15:0] :
 /*( phys &  hilob)*/   d3[31:16];

assign d8[31:16] =
   (~phys & ~hilob)   ? pdb_out[15:0] :
   ( phys & ~hilob)   ? d3[31:16]     :
   (~phys &  hilob)   ? pda_out[15:0] :
 /*( phys &  hilob)*/   d3[15:0];

// OBDATA.NET (226) - d9[0-31] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		d9[31:0] <= d8[31:0];
	end
end

// OBDATA.NET (227) - d9l : join
assign d9l[15:0] = d9[15:0];

// OBDATA.NET (228) - d9lu : dummy

// OBDATA.NET (229) - d9h : join
assign d9h = d9[31:16];

// OBDATA.NET (230) - d9hu : dummy

// OBDATA.NET (268) - nextbits1 : fd1q
// OBDATA.NET (269) - nextbits2 : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		nextbits1 <= nextbits;
		nextbits2 <= nextbits1;
	end
end

// OBDATA.NET (270) - delpixi : mx2
assign delpixi = (phys) ? nextbits1 : nextbits2;

// OBDATA.NET (271) - delpix : nivh
assign delpix = delpixi;

// OBDATA.NET (272) - da[0-15] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (delpix) begin
			da[15:0] <= d9[31:16];
		end
	end
end

// OBDATA.NET (274) - del1 : eo
assign del1 = lbwa_[0] ^ reflected;

// OBDATA.NET (275) - delayed : an2h
assign delayed = del1 & notscaled;

// OBDATA.NET (277) - db[0-15] : mx2
assign db[15:0] = (delayed) ? da[15:0] : d9[31:16];

// OBDATA.NET (279) - lbwd[0-15] : mx2
assign lbwd[15:0] = (pswap) ? db[15:0] : d9[15:0];

// OBDATA.NET (280) - lbwd[16-31] : mx2
assign lbwd[31:16] = (pswap) ? d9[15:0] : db[15:0];

// OBDATA.NET (294) - pa[0] : upcnts
wire [5:0] combined = {modew, mode8, mode4, mode2, mode1, 1'b0}; // assumes modes are exclusive
wire [5:0] simplified = ~scaled ? combined[5:0] : (pa[0] ? combined[5:0] - 6'h01 : 6'h01); // Needs to be checked
always @(posedge sys_clk) // fd1q
begin
	if (~old_clk && clk) begin
		if (reset) begin
			pad[5:0] <= 6'h00;
		end else if (nextphrase) begin
			pad[5:0] <= ip[5:0];
		end else if (nextbits) begin
			pad[5:0] <= pad[5:0] + simplified[5:0];
		end
	end
end

// OBDATA.NET (301) - pai[1-5] : en
//assign pai[5:1] = ~(pad[5:1] ^ (hilo, hilo, hilo, hilo, hilo));
assign pai[5:1] = hilo ? (pad[5:1]) : ~(pad[5:1]);

// OBDATA.NET (302) - pa[1-3] : ivm
assign pa[5:1] = ~pai[5:1];
assign pa[0] = pad[0];

// OBDATA.NET (306) - reset : iv
assign reset = ~resetl;

// OBDATA.NET (310) - ipd[0-5] : an2
assign ipd[5:0] = obld_1 ? d[54:49] : 6'h00;

// OBDATA.NET (311) - ip[0-5] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (nip) begin
			ip[5:0] <= ipd[5:0];
		end
	end
end

// OBDATA.NET (312) - nip : or2
assign nip = obld_1 | nextphrase;

// OBDATA.NET (316) - notscaled : ivm
assign notscaled = ~scaled;

// OBDATA.NET (317) - p2done : or2x3
assign p2done = pa[0] | notscaled;

// OBDATA.NET (328) - modew : or2
assign modew = mode16 | mode24;

// OBDATA.NET (332) - vcc : tie1
assign vcc = 1'b1;

// OBDATA.NET (333) - phd[1] : nd8
assign phd[1] = ~(p2done & (&pad[5:1]) & mode1);

// OBDATA.NET (334) - phd[2] : nd6
assign phd[2] = ~(p2done & (&pad[5:2]) & mode2);

// OBDATA.NET (335) - phd[3] : nd6
assign phd[3] = ~(p2done & (&pad[5:3]) & mode4);

// OBDATA.NET (336) - phd[4] : nd4
assign phd[4] = ~(p2done & (&pad[5:4]) & mode8);

// OBDATA.NET (337) - phd[5] : nd3
assign phd[5] = ~(p2done & pad[5] & modew);

// OBDATA.NET (338) - phdone : nd6
assign phdone = ~(&phd[5:1]);

// OBDATA.NET (339) - notphdone : iv
assign notphdone = ~phdone;

// OBDATA.NET (350) - nextxx : mx2
assign nextxx = (phys) ? nextx : nextx1;

// OBDATA.NET (356) - lbwadd[0-9] : mx2
assign lbwadd[9:0] = (lbt) ? at[10:1] : lbwad[9:0];

// OBDATA.NET (349) - nextx1 : fd1q
// OBDATA.NET (352) - lbwad[0] : udcnt
// OBDATA.NET (357) - lbwa[0-9] : fd1q
assign lbwa[9:1] = lbwa_[9:1];
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		nextx1 <= nextx;
		lbwa_[9:0] <= lbwadd[9:0];
		if (xld) begin
			lbwad[11:0] <= d[11:0]; // fd1q
		end else begin
			if (up & lci_0) begin // I think this is the same as the optimized logic in netlist
				lbwad[11:0] <= lbwad[11:0] + 12'h1;
			end else if (~up & lci_0) begin
				lbwad[11:0] <= lbwad[11:0] - 12'h1;
			end else if (up & ~lcil_1) begin
				lbwad[11:0] <= lbwad[11:0] + 12'h2;
			end else if (~up & ~lcil_1) begin
				lbwad[11:0] <= lbwad[11:0] - 12'h2;
			end
		end
	end
end

// OBDATA.NET (359) - up : ivh
assign up = ~reflected;

// OBDATA.NET (360) - lci[0] : an2
assign lci_0 = nextxx & scaled;

// OBDATA.NET (362) - lcil[1] : nd2
assign lcil_1 = ~(nextxx & notscaled);

// OBDATA.NET (408) - nota[4] : iv
assign nota_4 = ~lbwad[4];

// OBDATA.NET (409) - nota[5] : iv
assign nota_5 = ~lbwad[5];

// OBDATA.NET (410) - nota[8] : iv
assign nota_8 = ~lbwad[8];

// OBDATA.NET (411) - nota[10] : iv
assign nota_10 = ~lbwad[10];

// OBDATA.NET (412) - nota[11] : iv
assign nota_11 = ~lbwad[11];

// OBDATA.NET (414) - c[5] : nd2
assign c_5 = ~(nota_4 & nota_5);

// OBDATA.NET (415) - c[7] : nd3
assign c_7 = ~(c_5 & lbwad[6] & lbwad[7]);

// OBDATA.NET (416) - c[8] : nd2
assign c_8 = ~(c_7 & nota_8);

// OBDATA.NET (417) - c[9] : nd2
assign c_9 = ~(c_8 & lbwad[9]);

// OBDATA.NET (418) - c[11] : nd3
assign c_11 = ~(c_9 & nota_10 & nota_11);

// OBDATA.NET (420) - left : niv
assign left = lbwad[11];

// OBDATA.NET (421) - right : an2
assign right = c_11 & nota_11;

// OBDATA.NET (423) - onscreen : nr2
assign onscreen = ~(left | right);

// OBDATA.NET (424) - offscreeni : mx2
assign offscreeni = (reflected) ? left : right;

// OBDATA.NET (425) - offscreen : nivm
assign offscreen_obuf = offscreeni;

// OBDATA.NET (426) - notoffscreen : ivm
assign notoffscreen = ~offscreen_obuf;

// OBDATA.NET (435) - zero1a : iv
assign zero1a = ~d7[0];

// OBDATA.NET (436) - zero2a : nr2
assign zero2a = ~(|d6[1:0]);

// OBDATA.NET (437) - zero4a : nr4
assign zero4a = ~(|d5[3:0]);

// OBDATA.NET (438) - zero8a : nr8
assign zero8a = ~(|d4[7:0]);

// OBDATA.NET (439) - zero16a0 : nr8
assign zero16a0 = ~(|d3[7:0]);

// OBDATA.NET (440) - zero16a1 : nr8
assign zero16a1 = ~(|d3[15:8]);

// OBDATA.NET (442) - trans1a : nd2
assign trans1a = ~(mode1 & zero1a);

// OBDATA.NET (443) - trans2a : nd2
assign trans2a = ~(mode2 & zero2a);

// OBDATA.NET (444) - trans4a : nd2
assign trans4a = ~(mode4 & zero4a);

// OBDATA.NET (445) - trans8a : nd2
assign trans8a = ~(mode8 & zero8a);

// OBDATA.NET (446) - trans16a : nd3
assign trans16a = ~(mode16 & zero16a0 & zero16a1);

// OBDATA.NET (447) - transa : nd6
assign transa = ~(trans1a & trans2a & trans4a & trans8a & trans16a & vcc);

// OBDATA.NET (449) - nottransa : nd2
assign nottransa = ~(transa & transen);

// OBDATA.NET (451) - zero1b : iv
assign zero1b = ~d7[1];

// OBDATA.NET (452) - zero2b : nr2
assign zero2b = ~(|d6[3:2]);

// OBDATA.NET (453) - zero4b : nr4
assign zero4b = ~(|d5[7:4]);

// OBDATA.NET (454) - zero8b : nr8
assign zero8b = ~(|d4[15:8]);

// OBDATA.NET (455) - zero16b0 : nr8
assign zero16b0 = ~(|d3[23:16]);

// OBDATA.NET (456) - zero16b1 : nr8
assign zero16b1 = ~(|d3[31:24]);

// OBDATA.NET (458) - trans1b : nd2
assign trans1b = ~(mode1 & zero1b);

// OBDATA.NET (459) - trans2b : nd2
assign trans2b = ~(mode2 & zero2b);

// OBDATA.NET (460) - trans4b : nd2
assign trans4b = ~(mode4 & zero4b);

// OBDATA.NET (461) - trans8b : nd2
assign trans8b = ~(mode8 & zero8b);

// OBDATA.NET (462) - trans16b : nd3
assign trans16b = ~(mode16 & zero16b0 & zero16b1);

// OBDATA.NET (463) - transb : nd6
assign transb = ~(trans1b & trans2b & trans4b & trans8b & trans16b & vcc);

// OBDATA.NET (465) - nottransb : nd2
assign nottransb = ~(transb & transen);

// OBDATA.NET (515) - idle : fd4q
// OBDATA.NET (516) - read : fd2q
// OBDATA.NET (517) - write : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			smq0 <= 1'b1;// always @(posedge cp or negedge sd)
			smq1 <= 1'b0;// always @(posedge cp or negedge cd)
			smq2i <= 1'b0;// always @(posedge cp or negedge cd)
		end else begin
			smq0 <= smd0;
			smq1 <= smd1;
			smq2i <= smd2;
		end
	end
end

// OBDATA.NET (518) - smq2 : nivm
assign smq2 = smq2i;

// OBDATA.NET (520) - d00 : nd2
assign d00 = ~(smq0 & notfull);

// OBDATA.NET (521) - d01 : nd6
assign d01 = ~(smq2 & scaled & notremgte2 & phdone & notfull & vcc);

// OBDATA.NET (522) - d02 : nd4
assign d02 = ~(smq2 & notscaled & phdone & notfull);

// OBDATA.NET (523) - d0 : nd4
assign smd0 = ~(d00 & d01 & d02 & notoffscreen);

// OBDATA.NET (525) - d10 : nd4
assign d10 = ~(smq0 & full & rmw & notoffscreen);

// OBDATA.NET (526) - d11 : nd4
assign d11 = ~(smq2 & full & rmw & notoffscreen);

// OBDATA.NET (527) - d12 : nd4
assign d12 = ~(smq2 & notphdone & rmw & notoffscreen);

// OBDATA.NET (528) - d13 : nd6
assign d13 = ~(smq2 & scaled & remgte2 & rmw & notoffscreen & vcc);

// OBDATA.NET (529) - d1 : nd4
assign smd1 = ~(d10 & d11 & d12 & d13);

// OBDATA.NET (531) - d20 : nd4
assign d20 = ~(smq0 & full & notrmw & notoffscreen);

// OBDATA.NET (532) - d21 : nd4
assign d21 = ~(smq2 & full & notrmw & notoffscreen);

// OBDATA.NET (533) - d22 : nd4
assign d22 = ~(smq2 & notphdone & notrmw & notoffscreen);

// OBDATA.NET (534) - d23 : nd2
assign d23 = ~(smq1 & notoffscreen);

// OBDATA.NET (535) - d24 : nd6
assign d24 = ~(smq2 & scaled & remgte2 & notrmw & notoffscreen & vcc);

// OBDATA.NET (536) - d2 : nd6
assign smd2 = ~(d20 & d21 & d22 & d23 & d24 & vcc);

// OBDATA.NET (538) - np0 : nd2
assign np0 = ~(smq0 & full);

// OBDATA.NET (539) - np1 : nd6
assign np1 = ~(smq2 & scaled & notremgte2 & phdone & full & vcc);

// OBDATA.NET (540) - np2 : nd4
assign np2 = ~(smq2 & notscaled & phdone & full);

// OBDATA.NET (541) - nextphrasei : nd3
assign nextphrasei = ~(np0 & np1 & np2);

// OBDATA.NET (542) - nextphrase : nivu2
assign nextphrase = nextphrasei;

// OBDATA.NET (544) - nx0 : nd3
assign nx0 = ~(smq2 & scaled & remgte1);

// OBDATA.NET (545) - nx1 : nd2
assign nx1 = ~(smq2 & notscaled);

// OBDATA.NET (546) - nextx : nd2x2
assign nextx = ~(nx0 & nx1);

// OBDATA.NET (548) - nb0 : nd3
assign nb0 = ~(smq2 & scaled & notremgte2);

// OBDATA.NET (549) - nb1 : nd2
assign nb1 = ~(smq2 & notscaled);

// OBDATA.NET (550) - nextbitsi : nd2
assign nextbitsi = ~(nb0 & nb1);

// OBDATA.NET (551) - nextbits : nivh
assign nextbits = nextbitsi;

// OBDATA.NET (553) - lbwrite : niv
assign lbwrite = smq2;

// OBDATA.NET (554) - obdone : iv
assign obdone = ~d00;

// OBDATA.NET (556) - notrmw : iv
assign notrmw = ~rmw;

// OBDATA.NET (576) - nntransa : mx2
assign nntransa = (hilob) ? nottransb : nottransa;

// OBDATA.NET (577) - nntransb : mx2
assign nntransb = (hilob) ? nottransa : nottransb;

// OBDATA.NET (578) - lbwea1 : an2
assign lbwea[1] = lbwrite & nntransa;

// OBDATA.NET (579) - lbweb1 : an2
assign lbweb[1] = lbwrite & nntransb;

// OBDATA.NET (581) - lbwea2 : fd1q
// OBDATA.NET (582) - lbweb2 : fd1q
// OBDATA.NET (590) - lbweb51 : fd1q
// OBDATA.NET (591) - lbweb52 : fd1q
reg lbwea2_;
reg lbweb2_;
reg lbweb51_;
reg lbweb52_;
assign lbwea[2] = lbwea2_;
assign lbweb[2] = lbweb2_;
assign lbweb51 = lbweb51_;
assign lbweb52 = lbweb52_;
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		lbwea2_ <= lbwea[1];
		lbweb2_ <= lbweb[1];
		lbweb51_ <= lbweb[4];
		lbweb52_ <= lbweb51;
	end
end

// OBDATA.NET (584) - lbwea4 : mx2
assign lbwea[4] = (phys) ? lbwea[1] : lbwea[2];

// OBDATA.NET (585) - lbweb4 : mx2
assign lbweb[4] = (phys) ? lbweb[1] : lbweb[2];

// OBDATA.NET (592) - lbweb5 : mx2
assign lbweb[5] = (rmw1_obuf) ? lbweb52 : lbweb51;

// OBDATA.NET (594) - lbweb6 : mx2
assign lbweb[6] = (delayed) ? lbweb[5] : lbweb[4];

// OBDATA.NET (596) - lbwea7 : mx2
assign lbwea[7] = (pswapd) ? lbweb[6] : lbwea[4];

// OBDATA.NET (597) - lbweb7 : mx2
assign lbweb[7] = (pswapd) ? lbwea[4] : lbweb[6];

// OBDATA.NET (599) - lbwea80 : nd3
assign lbwea80 = ~(lbwea[7] & notscaled & onscreen);

// OBDATA.NET (600) - lbwea81 : nd6
assign lbwea81 = ~(lbwea[7] & scaled & onscreen & notlbwad_0 & nextxx);

// OBDATA.NET (601) - lbwea8 : nd2
assign lbwea[8] = ~(lbwea80 & lbwea81);

// OBDATA.NET (603) - lbweb80 : nd3
assign lbweb80 = ~(lbweb[7] & notscaled & onscreen);

// OBDATA.NET (604) - lbweb81 : nd6
assign lbweb81 = ~(lbweb[7] & scaled & onscreen & lbwad[0] & nextxx);

// OBDATA.NET (605) - lbweb8 : nd2
assign lbweb[8] = ~(lbweb80 & lbweb81);

// OBDATA.NET (607) - lbwe[0] : fd1q
// OBDATA.NET (608) - lbwe[1] : fd1q
assign lbwe[1:0] = lbwe_[1:0];
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		lbwe_[0] <= lbwea[8];
		lbwe_[1] <= lbweb[8];
	end
end

// OBDATA.NET (610) - notlbwad[0] : iv
assign notlbwad_0 = ~lbwad[0];

// OBDATA.NET (617) - lbw1 : fd1q
// OBDATA.NET (618) - lbw2 : fd1q
// OBDATA.NET (619) - lbw3 : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		lbw[3:1] <= {lbw[2:1], lbwrite};
	end
end

// OBDATA.NET (620) - lbend : or6
assign lbend = smd2 | lbwrite | (|lbw[3:1]);

// OBDATA.NET (621) - lbeni : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			lbeni <= 1'b0;// always @(posedge cp or negedge cd)
		end else begin
			lbeni <= lbend;
		end
	end
end

// OBDATA.NET (622) - lben : nivh
assign lben = lbeni;

// OBDATA.NET (634) - pa1[0] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		pa1_0 <= pa[0];
	end
end

// OBDATA.NET (635) - pa2[0] : mx2
assign pa2_0 = (phys) ? pa[0] : pa1_0;

// OBDATA.NET (636) - oddeven : eo
assign oddeven = lbwad[0] ^ pa2_0;

// OBDATA.NET (637) - pswapd : mx2
assign pswapd = (scaled) ? oddeven : lbwad[0];

// OBDATA.NET (638) - pswapi : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		pswapi <= pswapd;
	end
end

// OBDATA.NET (639) - pswap : nivu
assign pswap = pswapi;

// OBDATA.NET (646) - xrem[0-8] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		xrem[8:0] <= xrd[8:0];
	end
end

// OBDATA.NET (648) - sum[0] : ha1
assign sum[8:0] = xrem[7:0] + xscale[7:0]; // check this; xrem8 not used; ensure sum8 is set

// OBDATA.NET (652) - xs[0-8] : mx2
assign xs[8:0] = (nextbits) ? sum[8:0] : xrem[8:0];

// OBDATA.NET (654) - diff[5] : ha1
assign diff [8:5]= xs[8:5] + {nextx, nextx, nextx, nextx};

// OBDATA.NET (659) - xrd[0-4] : mx2
assign xrd[4:0] = (obld_2) ? d[4:0] : xs[4:0];

// OBDATA.NET (660) - xrd[5-7] : mx2
assign xrd[7:5] = (obld_2) ? d[7:5] : diff[7:5];

// OBDATA.NET (661) - xrd[8] : mx2
assign xrd[8] = (obld_2) ? 1'b0 : diff[8];

// OBDATA.NET (663) - notremgte2i : nr3
assign notremgte2i = ~(|xrem[8:6]);

// OBDATA.NET (664) - notremgte2 : niv
assign notremgte2 = notremgte2i;

// OBDATA.NET (665) - remgte2 : iv
assign remgte2 = ~notremgte2;

// OBDATA.NET (666) - remgte1 : or4
assign remgte1 = |xrem[8:5];

// --- Compiler-generated local PE for BUS pda<0>
assign pda_out[15:0] = ((clut_a_a0_oe) ? clut_a_a0_out[15:0] : 16'h0000) | ((clut_a_a1_oe) ? clut_a_a1_out[15:0] : 16'h0000);
assign pda_oe = clut_a_a0_oe | clut_a_a1_oe;

// --- Compiler-generated local PE for BUS pda<15>
assign pdb_out[15:0] = ((clut_b_a0_oe) ? clut_b_a0_out[15:0] : 16'h0000) | ((clut_b_a1_oe) ? clut_b_a1_out[15:0] : 16'h0000);
assign pdb_oe = clut_b_a0_oe | clut_b_a1_oe;

endmodule

