//`include "defs.v"
// altera message_off 10036

module _vid
(
	input [11:0] din,
	input vmwr,
	input hcwr,
	input hcrd,
	input hpwr,
	input hbbwr,
	input hbewr,
	input hdb1wr,
	input hdb2wr,
	input hdewr,
	input hswr,
	input hvswr,
	input vcwr,
	input vcrd,
	input vpwr,
	input vbbwr,
	input vbewr,
	input vdbwr,
	input vdewr,
	input vebwr,
	input veewr,
	input vswr,
	input viwr,
	input lphrd,
	input lpvrd,
	input hlock,
	input vlock,
	input resetl,
	input vclk,
	input lp,
	input heqw,
	input test1w,
	input test2r,
	input test3r,
	input wet,
	input vgy,
	input vey,
	input vly,
	input lock,
	output start,
	output dd,
	output lbufa,
	output lbufb,
	output noths,
	output notvs,
	output syncen,
	output vint,
	output vactive,
	output blank,
	output vblank_out,
	output hblank_out,
	output hsync_out,
	output vsync_out,
	output vvs_o,
	output nextpixa,
	output nextpixd,
	output cry16,
	output rgb24,
	output rg16,
	output rgb16,
	output mptest,
	output ndtest,
	output varmod,
	output [10:0] vcl,
	output tcount,
	output incen,
	output binc,
	output bgw,
	output word2,
	output pp,
	output lbaactive,
	output lbbactive,
	output hcb_10,
	output hs_o,
	output hhs_o,
	output vs_o,
	output [15:0] dr_out,
	output dr_11_0_oe, // test3r dr[15:12] driven by misc
	output dr_15_12_oe,
	input sys_clk // Generated
);
reg [10:0] hc = 11'h000;
reg [11:0] vc = 12'h000;
wire lockl;
wire viden;
wire videnl;
reg [11:0] vm = 11'h000;
wire csyncen;
wire bgwen;
wire [2:0] ppn;
wire rg16i;
wire tcountl;
wire startd3;
wire test1ws;
reg mptesti = 1'b0;
wire vcl_;
reg ndtesti = 1'b0;
wire ppresl;
wire notstartd;
reg [2:0] pp_ = 3'b000;
wire ppco;
wire ppl;
wire word2d0;
wire word2l;
wire word2d1;
wire word2d;
wire vres;
wire vresl;
wire hlockl;
wire hcresi;
wire hpeql;
wire hcres;
wire hmres;
wire hcount;
wire hpeq;
reg [9:0] hp = 10'h000;
wire hpe;
wire hpeqt;
wire hpeqi;
wire hbbeq;
wire hbeeq;
wire hdb1eq;
wire hdb2eq;
wire hdeeq;
wire hseq;
wire hvsb;
wire hvse;
wire heqe;
wire nextfieldl;
wire vpeq;
wire nextfield;
wire vlockl;
wire vcresi;
wire vcres;
wire res;
wire vcount;
reg [10:0] vp = 11'h000;
wire vpeqt;
wire vbbeq;
wire vbeeq;
wire vdbeq;
wire vdeeq;
wire vebeq;
wire veeeq;
wire vseq;
wire vieq;
reg vvactive = 1'b0;
wire notvvactive;
wire startd1;
wire startd2;
wire startd;
wire vcli;
wire vclb;
wire startd3p;
wire hdb;
reg vdactive = 1'b0;
wire notvactive;
reg lbufai = 1'b0;
wire lbufbi;
wire lbufad;
wire lbaai;
wire lbbai;
reg vblank = 1'b0;
wire notvblank;
reg hblank = 1'b0;
wire nothblank;
reg hs = 1'b0;
reg vvs = 1'b0;
wire notvvs;
wire hvstart;
reg hvs = 1'b0;
wire nothvs;
reg ves = 1'b0;
wire notves;
wire hestart;
reg hes = 1'b0;
wire nothes;
wire vsl;
wire csync;
wire vintd;
wire vintl;
wire ppnz;
wire longpix;
wire wordpix;
wire sxp;
wire nextpixd0;
wire nextpixd1;
wire nextpixad;
reg nextpixaq = 1'b0;
reg lp1 = 1'b0;
reg lp2 = 1'b0;
wire lp2l;
wire lpldi;
wire lpld;
reg [10:0] lph = 11'h000;
reg [11:0] lpv = 12'h000;
reg lpe = 1'b0;
wire notlpe;
wire e11;
wire e1215;
reg [10:0] vcl_obuf = 11'h000;

// Output buffers
reg start_obuf = 1'b0;
wire dd_obuf;
wire lbufa_obuf;
wire lbufb_obuf;
wire noths_obuf;
reg vactive_obuf = 1'b0;
wire nextpixa_obuf;
wire nextpixd_obuf;
wire cry16_obuf;
wire rgb16_obuf;
wire tcount_obuf;
reg word2_obuf = 1'b0;
reg vint_ = 1'b0;
wire pp_obuf;
wire [10:0] dr_hcb_out;
wire dr_hcb_oe;
wire [11:0] dr_vc_out;
wire dr_vc_oe;
wire [11:0] dr_lph_out;
wire dr_lph_oe;
wire [11:0] dr_lpv_out;
wire dr_lpv_oe;
wire [10:0] dr_test2r_out;
wire dr_test2r_oe;
wire [11:0] dr_test3r_out;
wire dr_test3r_oe;
wire dr_e11_out;
wire dr_e11_oe;

wire clk = vclk;
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign start = start_obuf;
assign dd = dd_obuf;
assign lbufa = lbufa_obuf;
assign lbufb = lbufb_obuf;
assign noths = noths_obuf;
assign vactive = vactive_obuf;
assign nextpixa = nextpixa_obuf;
assign nextpixd = nextpixd_obuf;
assign cry16 = cry16_obuf;
assign rgb16 = rgb16_obuf;
assign tcount = tcount_obuf;
assign word2 = word2_obuf;
assign pp = pp_obuf;
assign vcl[10:0] = vcl_obuf[10:0];
assign vint = vint_;
assign hcb_10 = hc[10];

// VID.NET (34) - lockl : ivm
assign lockl = ~lock;

// VID.NET (54) - vm[0] : ldp2
// VID.NET (55) - vm[1] : ldp1
// VID.NET (56) - vm[2] : ldp1
// VID.NET (57) - vm[3] : ldp2q
// VID.NET (58) - vm[4] : ldp2q
// VID.NET (59) - vm[5] : ldp1q
// VID.NET (60) - vm[6] : ldp1q
// VID.NET (61) - vm[7] : ldp2q
// VID.NET (62) - vm[8] : ldp1q
// VID.NET (63) - ppn[9-11] : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (vmwr) begin
		vm[11:0] <= din[11:0];
	end
	if (~resetl) begin
		vm[0] <= 1'b0;
		vm[4:3] <= 2'b00;
		vm[7] <= 1'b0;
		vm[11:9] <= 3'b000;
	end
end
assign videnl = ~viden;
assign viden = vm[0];
assign incen = vm[4];
assign binc = vm[5];
assign csyncen = vm[6];
assign bgwen = vm[7];
assign varmod = vm[8];
assign ppn[2:0] = vm[11:9];

// VID.NET (65) - cry16 : an2
assign cry16_obuf = vm[2:1] == 2'b00;

// VID.NET (66) - rgb24 : an2
assign rgb24 = vm[2:1] == 2'b01;

// VID.NET (67) - rg16i : nd2
assign rg16i = ~(vm[2:1] == 2'b10);

// VID.NET (68) - rg16 : ivu
assign rg16 = ~rg16i;

// VID.NET (69) - rgb16 : an2
assign rgb16_obuf = vm[2:1] == 2'b11;

// VID.NET (70) - syncen : iv
assign syncen = ~vm[3];

// VID.NET (82) - tcountl : nd2
assign tcountl = ~(test1w & din[0]);

// VID.NET (83) - tcount : iv
assign tcount_obuf = ~tcountl;

// VID.NET (84) - startd3 : nd2
assign startd3 = ~(test1w & din[1]);

// VID.NET (85) - test1ws : an2
assign test1ws = test1w & wet;

// VID.NET (86) - mptesti : ldp2q
// VID.NET (89) - ndtesti : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		mptesti <= 1'b0;
		ndtesti <= 1'b0;
	end else if (test1ws) begin
		mptesti <= din[2];
		ndtesti <= din[4];
	end
end

// VID.NET (87) - mptest : nivh
assign mptest = mptesti;

// VID.NET (88) - vcl : an2
assign vcl_ = test1w & din[3];

// VID.NET (90) - ndtest : nivh
assign ndtest = ndtesti;

// VID.NET (97) - ppresl : an2
assign ppresl = notstartd & resetl;

// VID.NET (98) - pp[0] : dncnts
// VID.NET (99) - pp[1] : dncnts
// VID.NET (100) - pp[2] : dncnts
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		pp_[2:0] <= ~ppresl ? 3'b000 : (pp_obuf ? ppn[2:0] : (pp_[2:0] - 3'b001));
	end
end
assign ppco = (pp_[2:0]==3'b000); //cin = 1

// VID.NET (101) - pp : nivm
assign pp_obuf = ppco;

// VID.NET (102) - ppl : iv
assign ppl = ~pp_obuf;

// VID.NET (111) - word2d0 : nd2
assign word2d0 = ~(word2l & pp_obuf);

// VID.NET (112) - word2d1 : nd2
assign word2d1 = ~(word2_obuf & ppl);

// VID.NET (113) - word2d : nd3
assign word2d = ~(word2d0 & word2d1 & notstartd);

// VID.NET (114) - word2 : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		word2_obuf <= word2d;
	end
end
assign word2l = ~word2_obuf;

// VID.NET (130) - vres : nd3
assign vres = ~(lockl & viden & resetl);

// VID.NET (131) - vresl : ivh
assign vresl = ~vres;

// VID.NET (132) - hlockl : nd2
assign hlockl = ~(vm[3] & hlock);

// VID.NET (133) - hcresi : nd4
assign hcresi = ~(resetl & hpeql & hlockl & lockl);

// VID.NET (134) - hcres : nivm
assign hcres = hcresi;

// VID.NET (135) - hmresl : nd2
assign hmres = ~(resetl & hlockl);

// VID.NET (136) - hcount : nd2
assign hcount = ~(videnl & tcountl);

// VID.NET (138) - hc[0] : upcnts
// VID.NET (139) - hc[1-9] : upcnts
// VID.NET (141) - hc[10] : upcnts
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		hc[9:0] <= hcres ? 10'h000 : (hcwr ? din[9:0] : (hc[9:0] + (hcount ? 10'h001 : 10'h000)));
		hc[10] <= hmres ? 1'b0 : (hcwr ? din[10] : (hc[10] ^ hpeq));
	end
end

// VID.NET (144) - hcd[0-10] : ts
assign dr_hcb_out[10:0] = hc[10:0];
assign dr_hcb_oe = hcrd;

// VID.NET (152) - hp[0-9] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (hpwr) begin
		hp[9:0] <= din[9:0];
	end
end

// VID.NET (156) - hpe[0-9] : en
assign hpe = (hp[9:0] == hc[9:0]);

// VID.NET (157) - hpeqt : and10
assign hpeqt = hpe;

// VID.NET (158) - hpeqi : and11
assign hpeqi = hpe & viden;

// VID.NET (159) - hpeq : niv
assign hpeq = hpeqi;

// VID.NET (160) - hpeql : iv
assign hpeql = ~hpeq;

// VID.NET (164) - hbb : creg11
// VID.NET (165) - hbe : creg11
// VID.NET (166) - hdb1 : creg11
// VID.NET (167) - hdb2 : creg11
// VID.NET (168) - hde : creg11
// VID.NET (175) - hs[0-10] : ldp1q
// VID.NET (184) - hvs[0-9] : ldp1q
// VID.NET (191) - heq[0-9] : ldp1q
reg [10:0] hbb_ = 11'h000;
reg [10:0] hbe_ = 11'h000;
reg [10:0] hdb1_ = 11'h000;
reg [10:0] hdb2_ = 11'h000;
reg [10:0] hde_ = 11'h000;
reg [10:0] hs_ = 11'h000;
reg [9:0] hvs_ = 10'h000;
reg [9:0] heq_ = 10'h000;
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (hbbwr) begin
		hbb_[10:0] <= din[10:0];
	end
	if (hbewr) begin
		hbe_[10:0] <= din[10:0];
	end
	if (hdb1wr) begin
		hdb1_[10:0] <= din[10:0];
	end
	if (hdb2wr) begin
		hdb2_[10:0] <= din[10:0];
	end
	if (hdewr) begin
		hde_[10:0] <= din[10:0];
	end
	if (hswr) begin
		hs_[10:0] <= din[10:0];
	end
	if (hvswr) begin
		hvs_[9:0] <= din[9:0];
	end
	if (heqw) begin
		heq_[9:0] <= din[9:0];
	end
end
assign hbbeq = hbb_[10:0] == hc[10:0];
assign hbeeq = hbe_[10:0] == hc[10:0];
assign hdb1eq = hdb1_[10:0] == hc[10:0];
assign hdb2eq = hdb2_[10:0] == hc[10:0];
assign hdeeq = hde_[10:0] == hc[10:0];

// VID.NET (177) - hseq : and11
assign hseq = hs_[10:0] == hc[10:0];

// VID.NET (178) - hvsb : and10
assign hvsb = hs_[9:0] == hc[9:0];// 9:0 only

// VID.NET (185) - hvse[0-9] : en
// VID.NET (186) - hvse : and10
assign hvse = hvs_[9:0] == hc[9:0];

// VID.NET (192) - heqe[0-9] : en
// VID.NET (193) - heqe : and10
assign heqe = heq_[9:0] == hc[9:0];

// VID.NET (202) - nextfieldl : nd2
assign nextfieldl = ~(vpeq & hpeq);

// VID.NET (203) - nextfield : iv
assign nextfield = ~nextfieldl;

// VID.NET (204) - vlockl : nd2
assign vlockl = ~(vm[3] & vlock);

// VID.NET (205) - vcresi : nd4
assign vcresi = ~(resetl & nextfieldl & vlockl & lockl);

// VID.NET (206) - vcres : nivm
assign vcres = vcresi;

// VID.NET (207) - res : iv
assign res = ~resetl;

// VID.NET (208) - vcount : or2
assign vcount = hpeq | tcount_obuf;

// VID.NET (210) - vc[0] : upcnts
// VID.NET (211) - vc[1-10] : upcnts
// VID.NET (212) - vc[11] : upcnts
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		vc[10:0] <= vcres ? 11'h000 : (vcwr ? din[10:0] : (vc[10:0] + (vcount ? 11'h001 : 11'h000)));
		vc[11] <= res ? 1'b0 : (vcwr ? din[11] : (vc[11] ^ nextfield));
	end
end

// VID.NET (215) - vcd[0-11] : ts
assign dr_vc_out[11:0] = vc[11:0];
assign dr_vc_oe = vcrd;

// VID.NET (222) - vp[0-10] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (vpwr) begin
		vp[10:0] <= din[10:0];
	end
end

// VID.NET (223) - vpe[0-10] : en
// VID.NET (224) - vpeqt : and11
assign vpeqt = vp[10:0] == vc[10:0];

// VID.NET (225) - vpeq : and12
assign vpeq = (vp[10:0] == vc[10:0]) & viden;

// VID.NET (227) - vbb : creg11
// VID.NET (228) - vbe : creg11
// VID.NET (229) - vdb : creg11
// VID.NET (230) - vde : creg11
// VID.NET (231) - veb : creg11
// VID.NET (232) - vee : creg11
// VID.NET (233) - vs : creg11
// VID.NET (234) - vi : creg11
reg [10:0] vbb = 11'h000;
reg [10:0] vbe = 11'h000;
reg [10:0] vdb = 11'h000;
reg [10:0] vde = 11'h000;
reg [10:0] veb = 11'h000;
reg [10:0] vee = 11'h000;
reg [10:0] vs = 11'h000;
reg [10:0] vi = 11'h000;
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (vbbwr) begin
		vbb[10:0] <= din[10:0];
	end
	if (vbewr) begin
		vbe[10:0] <= din[10:0];
	end
	if (vdbwr) begin
		vdb[10:0] <= din[10:0];
	end
	if (vdewr) begin
		vde[10:0] <= din[10:0];
	end
	if (vebwr) begin
		veb[10:0] <= din[10:0];
	end
	if (veewr) begin
		vee[10:0] <= din[10:0];
	end
	if (vswr) begin
		vs[10:0] <= din[10:0];
	end
	if (viwr) begin
		vi[10:0] <= din[10:0];
	end
end
assign vbbeq = vbb[10:0] == vc[10:0];
assign vbeeq = vbe[10:0] == vc[10:0];
assign vdbeq = vdb[10:0] == vc[10:0];
assign vdeeq = vde[10:0] == vc[10:0];
assign vebeq = veb[10:0] == vc[10:0];
assign veeeq = vee[10:0] == vc[10:0];
assign vseq = vs[10:0] == vc[10:0];
assign vieq = vi[10:0] == vc[10:0];

// VID.NET (238) - vvactive : fjkr
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		vvactive <= ((vdbeq & ~vvactive) | (~vdeeq & vvactive)) & vresl;
	end
end
assign notvvactive = ~vvactive;

// VID.NET (255) - startd1 : nd2
assign startd1 = ~(hdb1eq & vvactive);

// VID.NET (256) - startd2 : nd2
assign startd2 = ~(hdb2eq & vvactive);

// VID.NET (257) - startd : nd3
assign startd = ~(startd1 & startd2 & startd3);

// VID.NET (258) - start : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			start_obuf <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
		end else begin
			start_obuf <= startd;
		end
	end
end

// VID.NET (262) - vcli : nr2
assign vcli = ~(vcl_ | start_obuf);

// VID.NET (263) - vclb : ivh
assign vclb = ~vcli;

// VID.NET (264) - vcl[0-10] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (vclb) begin
			vcl_obuf[10:0] <= vc[10:0]; 
		end
	end
end

// VID.NET (271) - startd3p : iv
assign startd3p = ~startd3;

// VID.NET (272) - hdb : or3
assign hdb = hdb1eq | hdb2eq | startd3p;

// VID.NET (273) - vdactive : slatchr
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (~vresl) begin
			vdactive <= 1'b0; 
		end else if (hdb) begin
			vdactive <= vvactive; 
		end
	end
end

// VID.NET (274) - dd : an2
assign dd_obuf = vdactive & hdb;

// VID.NET (275) - vactive : fjkr
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		vactive_obuf <= ((dd_obuf & ~vactive_obuf) | (~hdeeq & vactive_obuf)) & vresl;
	end
end
assign notvactive = ~vactive_obuf;

// VID.NET (278) - lbufai : fdr
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		lbufai <= vresl & lbufad;
	end
end
assign lbufbi = ~lbufai;

// VID.NET (279) - lbufd : mx2
assign lbufad = (dd_obuf) ? lbufb_obuf : lbufa_obuf;

// VID.NET (280) - lbufa : nivu2
assign lbufa_obuf = lbufai;

// VID.NET (281) - lbufb : nivu2
assign lbufb_obuf = lbufbi;

// VID.NET (283) - lbaai : nd2
assign lbaai = ~(lbufai & vactive_obuf);

// VID.NET (284) - lbbai : nd2
assign lbbai = ~(lbufbi & vactive_obuf);

// VID.NET (285) - lbaactive : ivu
assign lbaactive = ~lbaai;

// VID.NET (286) - lbbactive : ivu
assign lbbactive = ~lbbai;

// Kitrinx - add some signals
assign vblank_out = vblank;
assign hblank_out = hblank;

// VID.NET (288) - vblank : fjkr
// VID.NET (289) - hblank : fjkr
// VID.NET (295) - hs : fjkr
// VID.NET (303) - vvsync : fjkr
// VID.NET (306) - hvsync : fjkr
// VID.NET (307) - vesync : fjkr
// VID.NET (310) - hesync : fjkr
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		vblank <= ((vbbeq & ~vblank) | (~vbeeq & vblank)) & vresl;
		hblank <= ((hbbeq & ~hblank) | (~hbeeq & hblank)) & vresl;
		hs <= ((hseq & ~hs) | (~hpeq & hs)) & vresl;
		vvs <= ((vseq & ~vvs) | (~vpeq & vvs)) & vresl;
		hvs <= ((hvstart & ~hvs) | (~hvse & hvs)) & vresl;
		ves <= ((vebeq & ~ves) | (~veeeq & ves)) & vresl;
		hes <= ((hestart & ~hes) | (~heqe & hes)) & vresl;
	end
end
assign notvblank = ~vblank;
assign nothblank = ~hblank;
assign noths_obuf = ~hs;
assign notvvs = ~vvs;
assign nothvs = ~hvs;
assign notves = ~ves;
assign nothes = ~hes;

// VID.NET (290) - blank : nd2
assign blank = ~(notvblank & nothblank);

// VID.NET (305) - hvstart : an2
assign hvstart = hvsb & vvs;

assign vsync_out = hvs;
assign vvs_o = vvs;
assign hsync_out = hes;

// VID.NET (309) - hestart : an2
assign hestart = hvsb & ves;

// VID.NET (311) - vsync : an2
assign vsl = nothvs & nothes;

// VID.NET (312) - csync : mx2
assign csync = (ves) ? vsl : noths_obuf;

// VID.NET (313) - notvs : mx2
assign notvs = (csyncen) ? csync : vsl;

// VID.NET (319) - vintd : an2
assign vintd = vieq & hdeeq;

// VID.NET (320) - vint : fdr
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		vint_ <= vresl & vintd;
	end
end

// VID.NET (327) - ppnz : or3
assign ppnz = |ppn[2:0];

// VID.NET (328) - longpix : nr2
assign longpix = ~(cry16_obuf | rgb16_obuf);

// VID.NET (329) - wordpix : iv
assign wordpix = ~longpix;

// VID.NET (330) - sxp : or2
assign sxp = wordpix | ppnz;

// VID.NET (331) - notstartd : iv
assign notstartd = ~startd;

// VID.NET (332) - nextpixd0 : nd2
assign nextpixd0 = ~(word2_obuf & pp_obuf);

// VID.NET (333) - nextpixd1 : nd2
assign nextpixd1 = ~(longpix & pp_obuf);

// VID.NET (334) - nextpixd : nd2
assign nextpixd_obuf = ~(nextpixd0 & nextpixd1);

// VID.NET (341) - nextpixad : an2
assign nextpixad = nextpixd_obuf & notstartd;

// VID.NET (342) - nextpixaq : fd1q
// VID.NET (348) - lp1 : fd1q
// VID.NET (349) - lp2 : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		nextpixaq <= nextpixad;
		lp1 <= lp;
		lp2 <= lp1;
	end
end
assign lp2l = ~lp2;

// VID.NET (343) - nextpixa : mx2
assign nextpixa_obuf = (sxp) ? nextpixaq : nextpixd_obuf;

// VID.NET (344) - bgw : an3
assign bgw = bgwen & nextpixa_obuf & sxp;

// VID.NET (350) - lpldi : nd2
assign lpldi = ~(lp1 & lp2l);

// VID.NET (351) - lpld : ivh
assign lpld = ~lpldi;

// VID.NET (354) - lph[0-10] : slatch
// VID.NET (355) - lpv[0-11] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (lpld) begin
			lph[10:0] <= hc[10:0]; 
			lpv[11:0] <= vc[11:0]; 
		end
	end
end

// VID.NET (356) - lphd[0-10] : ts
assign dr_lph_out[10:0] = lph[10:0];
assign dr_lph_oe = lphrd;

// VID.NET (357) - lphd[11] : ts
assign dr_lph_out[11] = lpe;

// VID.NET (358) - lpvd[0-11] : ts
assign dr_lpv_out[11:0] = lpv[11:0];
assign dr_lpv_oe = lpvrd;

// VID.NET (360) - lp_event : fjk2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			lpe <= 1'b0;
		end else begin
			lpe <= (lpld & ~lpe) | (~nextfield & lpe);
		end
	end
end
assign notlpe = ~lpe;

// VID.NET (365) - td2[0] : ts
// VID.NET (366) - td2[1] : ts
// VID.NET (367) - td2[2] : ts
// VID.NET (368) - td2[3] : ts
// VID.NET (369) - td2[4] : ts
// VID.NET (370) - td2[5] : ts
// VID.NET (371) - td2[6] : ts
// VID.NET (372) - td2[7] : ts
// VID.NET (373) - td2[8] : ts
// VID.NET (374) - td2[9] : ts
// VID.NET (375) - td2[10] : ts
assign dr_test2r_out[0] = hpeqt;
assign dr_test2r_out[1] = hbbeq;
assign dr_test2r_out[2] = hbeeq;
assign dr_test2r_out[3] = hdb1eq;
assign dr_test2r_out[4] = hdb2eq;
assign dr_test2r_out[5] = hdeeq;
assign dr_test2r_out[6] = hseq;
assign dr_test2r_out[7] = hvsb;
assign dr_test2r_out[8] = hvse;
assign dr_test2r_out[9] = heqe;
assign dr_test2r_out[10] = 1'b0;
assign dr_test2r_oe = test2r;

// VID.NET (377) - td3[0] : ts
// VID.NET (378) - td3[1] : ts
// VID.NET (379) - td3[2] : ts
// VID.NET (380) - td3[3] : ts
// VID.NET (381) - td3[4] : ts
// VID.NET (382) - td3[5] : ts
// VID.NET (383) - td3[6] : ts
// VID.NET (384) - td3[7] : ts
// VID.NET (385) - td3[8] : ts
// VID.NET (386) - td3[9] : ts
// VID.NET (387) - td3[10] : ts
// VID.NET (388) - td3[11] : ts
assign dr_test3r_out[0] = vpeqt;
assign dr_test3r_out[1] = vbbeq;
assign dr_test3r_out[2] = vbeeq;
assign dr_test3r_out[3] = vdbeq;
assign dr_test3r_out[4] = vdeeq;
assign dr_test3r_out[5] = vebeq;
assign dr_test3r_out[6] = veeeq;
assign dr_test3r_out[7] = vseq;
assign dr_test3r_out[8] = vieq;
assign dr_test3r_out[9] = vgy;
assign dr_test3r_out[10] = vey;
assign dr_test3r_out[11] = vly;
assign dr_test3r_oe = test3r;

// VID.NET (395) - e11 : or2
assign e11 = hcrd | test2r;

// VID.NET (396) - e1215 : or4
assign e1215 = e11 | vcrd | lpvrd | lphrd;

// VID.NET (398) - dr[11] : ts
assign dr_e11_out = 1'b0;
assign dr_e11_oe = e11;

// VID.NET (399) - dr[12-15] : ts
assign dr_out[15:12] = 4'h0;
assign dr_15_12_oe = e1215;

// VID.NET (402) - hso : join
assign hs_o = hseq;

// VID.NET (403) - hhso : join
assign hhs_o = hvsb;

// VID.NET (404) - vso : join
assign vs_o = vvs;

// --- Compiler-generated PE for BUS dr[0]
assign dr_out[10:0] = (dr_hcb_oe ? dr_hcb_out[10:0] : 11'h000) | (dr_vc_oe ? dr_vc_out[10:0] : 11'h000) | (dr_lph_oe ? dr_lph_out[10:0] : 11'h000) | (dr_lpv_oe ? dr_lpv_out[10:0] : 11'h000) | (dr_test2r_oe ? dr_test2r_out[10:0] : 11'h000);
assign dr_out[11] = (dr_vc_oe & dr_vc_out[11]) | (dr_lph_oe & dr_lph_out[11]) | (dr_lpv_oe & dr_lpv_out[11]) | (dr_test3r_oe & dr_test3r_out[11]);
//dr_e11_out is 0 so dr_e11_oe doesnt matter if using this method

assign dr_11_0_oe = dr_15_12_oe | dr_test3r_oe;

endmodule

