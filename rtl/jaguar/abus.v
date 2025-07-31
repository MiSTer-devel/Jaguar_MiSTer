//`include "defs.v"
// altera message_off 10036

module _abus
(
	input [23:0] ain,
	input ainen,
	input [2:0] atin,
	input [14:0] din,
	input newrow,
	input resrow,
	input mux,
	input resetl,
	input memc1r,
	input memc2r,
	input memc1w,
	input memc2w,
	input [8:0] cfg,// cfg3,7 not used
	input cfgw,
	input cfgen,
	input ack,
	input clk,
	input ba,
	input [2:0] fc,
	input siz_1,
	input mreq,
	input dreqin,
	input lbufa,
	input d7a,
	input readt,
	input wet,
	output [23:3] aout,
	output [10:0] ma,
	output match,
	output intdev,
	output fintdev,
	output fextdev,
	output fdram,
	output from,
	output [1:0] dspd,
	output [1:0] romspd,
	output [1:0] iospd,
	output dram,
	output [1:0] mw,
	output [3:0] bs,
	output cpu32,
	output [3:0] refrate,
	output bigend,
	output ourack,
	output nocpu,
	output gpuread,
	output gpuwrite,
	output [3:2] abs,
	output hilo,
	output lba,
	output lbb,
	output lbt,
	output clut,
	output clutt,
	output fastrom,
	output m68k,
	output [10:3] atout,
	output [23:0] a_out,
	output a_oe,
	input [23:0] a_in,
	output [15:0] dr_out,
	output dr_oe,
	input sys_clk // Generated
);
wire [2:0] m1d;
wire m1d_13;
wire m1d_14;
wire m2d_12;
wire m1ld;
wire m2ld;
wire memc2;
reg romhii = 1'b0;
wire romhi;
wire romlo;
reg [1:0] romwid = 2'b00;
reg [1:0] cols0 = 2'b00;
reg [1:0] dwid0 = 2'b00;
reg [1:0] cols1 = 2'b00;
reg [1:0] dwid1 = 2'b00;
reg bigd = 1'b0;
reg hiloi = 1'b0;
reg bigendi = 1'b0;
reg m68ki = 1'b0;
wire not68k;
reg [15:3] aouti = 13'h0000;
wire [23:0] at;
wire [23:10] ab;
reg mseti = 1'b0;
wire mset;
wire [23:10] alb;
wire notmset;
wire mreqb;
wire abs01;
wire abs02;
wire abs03;
wire [1:0] abs_;
wire abs10;
wire abs11;
wire abs12;
wire abs13;
wire abs20;
wire abs21;
wire abs30;
wire abs31;
wire fintdev1;
wire fextdevl;
wire [7:0] rom;
wire notdev;
wire romcsl_0;
reg intdevi = 1'b0;
wire abti_2;
wire abt_2;
wire mw01;
wire mw02;
wire dev16;
wire mw03;
wire mw04;
wire mw05;
wire mw06;
wire mw07;
wire mw08;
wire mw09;
wire mw0a;
wire mw0b;
wire mw0c;
wire mw0d;
wire mw0e;
wire mw11;
wire mw12;
wire dev32;
wire mw13;
wire mw14;
wire mw15;
wire mw16;
wire mw17;
wire mw18;
wire mw19;
wire mw1a;
wire mw1b;
wire mw1c;
wire mw1d;
wire mw1e;
wire dev32l;
wire dev160;
wire dev161;
wire notba;
wire bm68k;
wire ai;
wire [1:0] dwidi;
wire [1:0] dwid;
wire [10:0] ald;
wire [2:0] cw0i;
wire [2:0] cw0;
wire [2:0] cw1i;
wire [2:0] cw1;
wire [10:0] ahd0;
wire [10:0] ahd1;
wire [10:0] ahd;
wire [10:0] mad;
wire [1:0] newrow_;
wire reset;
wire bankresl;
wire [1:0] match_;
wire [1:0] m;
wire intd0;
wire intd1;
wire fcl[0];
wire intd;
reg ouracki = 1'b0;
wire notourack;
wire gpuadd;
wire writet;
wire lbufb;
wire lba0;
wire lba1;
wire lbad;
wire lbb0;
wire lbb1;
wire lbbd;
wire clutd;
wire lb0;
wire lb1;
wire lbd;
wire lbat;
wire lbbt;
reg lb = 1'b0;
wire [15:0] dr_a0_out;
wire dr_a0_oe;
wire [15:0] dr_a1_out;
wire dr_a1_oe;

// Output buffers
reg [23:16] aout_obuf = 8'h00;
reg [10:0] ma_obuf = 11'h000;
wire fintdev_obuf;
wire fdram_obuf;
reg dram_obuf = 1'b0;
reg [1:0] dspd_obuf = 2'b00;
reg [1:0] romspd_obuf = 2'b00;
reg [1:0] iospd_obuf = 2'b00;
reg [3:0] bs_obuf = 4'h0;
reg cpu32_obuf = 1'b0;
reg [3:0] refrate_obuf = 4'h0;
reg nocpu_obuf = 1'b0;
wire hilo_obuf;
reg lba_obuf = 1'b0;
reg lbb_obuf = 1'b0;
wire lbt_obuf;
reg clut_obuf  = 1'b0;
wire clutt_obuf;
reg fastrom_obuf = 1'b0;
wire m68k_obuf;
wire [10:3] at_obuf;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign aout[23:16] = aout_obuf[23:16];
assign ma[10:0] = ma_obuf[10:0];
assign fintdev = fintdev_obuf;
assign fdram = fdram_obuf;
assign dram = dram_obuf;
assign dspd[1:0] = dspd_obuf[1:0];
assign romspd[1:0] = romspd_obuf[1:0];
assign iospd[1:0] = iospd_obuf[1:0];
assign bs[3:0] = bs_obuf[3:0];
assign cpu32 = cpu32_obuf;


// Inhibit the old DRAM refresh pulses.
// Will help a bit with debugging via SignalTap, and might also help certain games to run a bit faster. ElectronAsh.
//
//assign refrate[3:0] = 4'b0000;
//assign refrate[3:0] = 4'b0100;
assign refrate[3:0] = refrate_obuf[3:0];

assign nocpu = nocpu_obuf;
assign hilo = hilo_obuf;
assign lba = lba_obuf;
assign lbb = lbb_obuf;
assign lbt = lbt_obuf;
assign clut = clut_obuf;
assign clutt = clutt_obuf;
assign fastrom = fastrom_obuf;
assign m68k = m68k_obuf;
assign atout[10:3] = at_obuf[10:3];
assign at[2:0] = atin[2:0];
assign at[10:3] = atout[10:3];
//at[23:11] done below
//assign ab[14:13] = 2'b00; //unused

// ABUS.NET (76) - ma : join
assign ma[10:0] = ma_obuf[10:0];

// ABUS.NET (83) - m1d[0-2] : mx2
assign m1d[2:0] = (cfgen) ? din[2:0] : cfg[2:0];

// ABUS.NET (84) - m1d[13] : mx2
assign m1d_13 = (cfgen) ? din[13] : cfg[4];

// ABUS.NET (85) - m1d[14] : mx2
assign m1d_14 = (cfgen) ? din[14] : cfg[5];

// ABUS.NET (86) - m2d[12] : mx2
assign m2d_12 = (cfgen) ? din[12] : cfg[6];

// ABUS.NET (90) - m1ld : or2
assign m1ld = memc1w | cfgw;

// ABUS.NET (91) - m2ld : or2
assign m2ld = memc2 | cfgw;

// ABUS.NET (94) - romhii : ldp1q
// ABUS.NET (97) - romwid[0-1] : ldp1q
// ABUS.NET (99) - dspd[0-1] : ldp1q
// ABUS.NET (101) - iospd[0-1] : ldp1q
// ABUS.NET (102) - nocpu : ldp1q
// always @(d or g)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (m1ld) begin
		{romwid[1:0], romhii} <= m1d[2:0]; // ldp1q negedge always @(d or g)
		nocpu_obuf <= m1d_13; // ldp1q negedge always @(d or g)
		cpu32_obuf <= m1d_14; // ldp1q negedge always @(d or g)
	end
	if (memc1w) begin
		dspd_obuf[1:0] <= din[6:5]; // ldp1q negedge always @(d or g)
		iospd_obuf[1:0] <= din[12:11]; // ldp1q negedge always @(d or g)
	end
end

// ABUS.NET (95) - romhi : nivh
assign romhi = romhii;

// ABUS.NET (96) - romlo : ivh
assign romlo = ~romhii;

// ABUS.NET (98) - romspd[0-1] : ldp2q
// ABUS.NET (100) - fastrom : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		romspd_obuf[1:0] <= 2'h0; // ldp2q negedge // always @(d or g or cd)
		fastrom_obuf <= 1'b0; // ldp2q negedge // always @(d or g or cd)
	end else if (memc1w) begin
		romspd_obuf[1:0] <= din[4:3]; // ldp2q negedge // always @(d or g or cd)
		fastrom_obuf <= din[7]; // ldp2q negedge // always @(d or g or cd)
	end
end

// ABUS.NET (105) - d1[0] : ts romhi
// ABUS.NET (106) - d1[1-2] : ts romwid[1:0]
// ABUS.NET (107) - d1[3-4] : ts romspd_obuf[1:0]
// ABUS.NET (108) - d1[5-6] : ts dspd_obuf[1:0]
// ABUS.NET (109) - d1[7] : ts fastrom_obuf
// ABUS.NET (110) - d1[8-10] : ts gnd,
// ABUS.NET (111) - d1[11-12] : ts iospd_obuf[1:0]
// ABUS.NET (112) - d1[13] : ts nocpu_obuf
// ABUS.NET (113) - d1[14] : ts cpu32_obuf
// ABUS.NET (114) - d1[15] : ts gnd
assign dr_a0_out[15:0] = {1'b0,cpu32_obuf,nocpu_obuf,iospd_obuf[1:0],3'h0,fastrom_obuf,dspd_obuf[1:0],romspd_obuf[1:0],romwid[1:0],romhi};
assign dr_a0_oe = memc1r;

// ABUS.NET (118) - memc2 : an2h
assign memc2 = wet & memc2w;

// ABUS.NET (119) - cols0[0-1] : ldp1q
// ABUS.NET (120) - dwid0[0-1] : ldp1q
// ABUS.NET (121) - cols1[0-1] : ldp1q
// ABUS.NET (122) - dwid1[0-1] : ldp1q
// ABUS.NET (124) - bigd : ldp1q
// ABUS.NET (125) - hiloi : ldp1q
// always @(d or g)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (memc2) begin
		cols0[1:0] <= din[1:0]; // ldp1q negedge always @(d or g)
		dwid0[1:0] <= din[3:2]; // ldp1q negedge always @(d or g)
		cols1[1:0] <= din[5:4]; // ldp1q negedge always @(d or g)
		dwid1[1:0] <= din[7:6]; // ldp1q negedge always @(d or g)
		hiloi <= din[13]; // ldp1q negedge always @(d or g)
	end
	if (m2ld) begin
		bigd <= m2d_12; // ldp1q negedge always @(d or g)
	end
end

// ABUS.NET (123) - refrate[0-3] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (memc2w) begin
			refrate_obuf[3:0] <= din[11:8];
		end
	end
end

// ABUS.NET (126) - hilo : nivh
assign hilo_obuf = hiloi;

// ABUS.NET (128) - d2[0-1] : ts cols0[1:0]
// ABUS.NET (129) - d2[2-3] : ts dwid0[1:0]
// ABUS.NET (130) - d2[4-5] : ts cols1[1:0]
// ABUS.NET (131) - d2[6-7] : ts dwid1[1:0]
// ABUS.NET (132) - d2[8-11] : ts refrate_obuf[3:0]
// ABUS.NET (133) - d2[12] : ts bigd
// ABUS.NET (134) - d2[13] : ts hilo_obuf
// ABUS.NET (135) - d2[14-15] : ts gnd
assign dr_a1_out[15:0] = {2'b00,hilo_obuf,bigd,refrate_obuf[3:0],dwid1[1:0],cols1[1:0],dwid0[1:0],cols0[1:0]};
assign dr_a1_oe = memc2r;

// ABUS.NET (142) - bigendi : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		bigendi <= bigd;
	end
end

// ABUS.NET (143) - bigend : nivh
assign bigend = bigendi;

// ABUS.NET (149) - motorola : ldp1
// always @(d or g)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (cfgw) begin
		m68ki <= cfg[8];
	end
end
assign not68k = ~m68ki;

// ABUS.NET (150) - m68k : nivh
assign m68k_obuf = m68ki;

// ABUS.NET (154) - aouti[3-15] : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		aouti[15:3] <= at[15:3];
	end
end

// ABUS.NET (155) - at[3-15] : mx2h
assign {at[15:11], at_obuf[10:3]} = (ack) ? a_in[15:3] : aouti[15:3];

// ABUS.NET (156) - aout[3-8] : nivh
// ABUS.NET (157) - aout[9] : nivu
// ABUS.NET (158) - aout[10-14] : nivh
// ABUS.NET (159) - aout[15] : nivu
assign aout[15:3] = aouti[15:3];

// ABUS.NET (160) - aout[16-23] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		aout_obuf[23:16] <= at[23:16];
	end
end

// ABUS.NET (161) - at[16-23] : mx2m
assign at[23:16] = (ack) ? ab[23:16] : aout_obuf[23:16];

// ABUS.NET (168) - mseti : fd2q
reg old_memc1w = 1'b0;
reg old_cfgen = 1'b0;
always @(posedge sys_clk)
begin
	old_memc1w <= memc1w;
	old_cfgen <= cfgen;
	if ((~old_memc1w && memc1w) | (old_cfgen && ~cfgen)) begin
		if (~cfgen) begin
			mseti <= 1'b0;// always @(posedge cp or negedge sd)
		end else begin
			mseti <= 1'b1;
		end
	end
end

// ABUS.NET (169) - mset : nivh
assign mset = mseti; // after boot config

// ABUS.NET (193) - alb[10-23] : ivu
assign alb[23:10] = ~a_in[23:10];

// ABUS.NET (194) - ab[10-12] : iv
assign ab[12:10] = ~alb[12:10];

// ABUS.NET (195) - ab[15-23] : ivu
assign ab[23:15] = ~alb[23:15];//simplifying below;just use ab
assign ab[14:13] = ~alb[14:13];//simplifying below;just use ab

// ABUS.NET (196) - notmset : iv
assign notmset = ~mset;

// ABUS.NET (198) - mreqb : nivm
assign mreqb = mreq;

// ABUS.NET (200) - abs01 : nd2
assign abs01 = ~(mreqb & notmset); // boot before cfgen set

// ABUS.NET (201) - abs02 : nd6
assign abs02 = ~(mreqb & romlo & (ab[23:21]==3'b000)); // 000000-1FFFFF romlo

// ABUS.NET (202) - abs03 : nd6
assign abs03 = ~(mreqb & romhi & (ab[23:21]==3'b111)); // E00000-FFFFFF romhi

// ABUS.NET (203) - abs0 : nd3
assign abs_[0] = ~(abs01 & abs02 & abs03); // not cart or ram

// ABUS.NET (205) - abs10 : nd6
assign abs10 = ~(mreqb & romlo & (ab[23:21]==3'b001) & mset); // 200000-3FFFFF romlo

// ABUS.NET (206) - abs11 : nd6
assign abs11 = ~(mreqb & romlo & (ab[23:22]==2'b01) & mset); // 400000-7FFFFF romlo

// ABUS.NET (207) - abs12 : nd6
assign abs12 = ~(mreqb & romhi & (ab[23:21]==3'b110) & mset); // C00000-DFFFFF romhi

// ABUS.NET (208) - abs13 : nd6
assign abs13 = ~(mreqb & romhi & (ab[23:22]==2'b10) & mset); // 800000-BFFFFF romhi

// ABUS.NET (209) - abs1 : nd4
assign abs_[1] = ~(abs13 & abs12 & abs11 & abs10); // cart

// ABUS.NET (211) - abs20 : nd6
assign abs20 = ~(mreqb & romlo & (ab[23:22]==2'b10) & mset); // 800000-BFFFFF romlo

// ABUS.NET (212) - abs21 : nd6
assign abs21 = ~(mreqb & romhi & (ab[23:22]==2'b01) & mset); // 400000-7FFFFF romhi

// ABUS.NET (213) - abs2 : nd2
assign abs[2] = ~(abs21 & abs20); // ram1

// ABUS.NET (215) - abs30 : nd6
assign abs30 = ~(mreqb & romlo & (ab[23:22]==2'b11) & mset); // C00000-FFFFFF romlo

// ABUS.NET (216) - abs31 : nd6
assign abs31 = ~(mreqb & romhi & (ab[23:22]==2'b00) & mset); // 000000-3FFFFF romhi

// ABUS.NET (217) - abs3 : nd2
assign abs[3] = ~(abs31 & abs30); // ram0

// ABUS.NET (223) - fdram : or2
assign fdram_obuf = |abs[3:2]; // ram

// ABUS.NET (230) - fintdev1 : nd6
assign fintdev1 = ~(abs_[0] & (ab[20:16]==5'b10000)); // F00000-F0FFFF romhi tom stuff

// ABUS.NET (231) - fintdev : ivh
assign fintdev_obuf = ~fintdev1;

// ABUS.NET (232) - fextdevl : nd6
assign fextdevl = ~(abs_[0] & (ab[20:16]==5'b10001)); // F10000-F1FFFF romhi jerry or ext stuff

// ABUS.NET (233) - fextdev : iv
assign fextdev = ~fextdevl;

// ABUS.NET (246) - rom1 : nd6
assign rom[1] = ~(mset & romlo & (ab[23:21]==3'b000) & notdev); // 000000-0FFFFF / 120000-1FFFFF romlo

// ABUS.NET (247) - rom2 : nd6
assign rom[2] = ~(mset & romhi & (ab[23:21]==3'b111) & notdev); // E00000-EFFFFF / F20000-FFFFFF romhi

// ABUS.NET (248) - rom3 : nd6
assign rom[3] = ~(mset & romlo & (ab[23:21]==3'b001)); // 200000-3FFFFF romlo

// ABUS.NET (249) - rom4 : nd6
assign rom[4] = ~(mset & romhi & (ab[23:21]==3'b110)); // C00000-DFFFFF romhi

// ABUS.NET (250) - rom5 : nd4
assign rom[5] = ~(mset & romlo & (ab[23:22]==2'b01)); // 400000-7FFFFF romlo

// ABUS.NET (251) - rom6 : nd4
assign rom[6] = ~(mset & romhi & (ab[23:22]==2'b10)); // 800000-BFFFFF romhi

// ABUS.NET (252) - rom7 : nd2
assign rom[7] = ~(notmset & notdev);

// ABUS.NET (253) - from : nd8
assign from = ~(&rom[7:1]); // cart or bios

// ABUS.NET (255) - romcsl[0] : an3
assign romcsl_0 = (&rom[2:1]) & rom[7]; // bios

// ABUS.NET (260) - intdevi : slatchc
// always @(posedge cp or negedge cd)
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			intdevi <= 1'b0;
		end else begin
			if (ack) begin
				intdevi <= fintdev_obuf;
			end
		end
	end
end

// ABUS.NET (261) - intdev : nivh
assign intdev = intdevi;

// ABUS.NET (262) - dram : slatch
// ABUS.NET (269) - bs[0] : slatch
// ABUS.NET (270) - bs[1] : slatch
// always @(posedge cp)
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (ack) begin
			dram_obuf <= fdram_obuf;
			bs_obuf[0] <= rom[0];
			bs_obuf[1] <= abs_[1];
		end
	end
end

// ABUS.NET (268) - rom0 : iv
assign rom[0] = ~romcsl_0;

// ABUS.NET (271) - bsi[2] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		bs_obuf[2] <= abti_2;
	end
end

// ABUS.NET (272) - abti[2] : mx2
assign abti_2 = (ack) ? abs[2] : bs_obuf[2];

// ABUS.NET (273) - abt[2] : nivh
assign abt_2 = abti_2;

// ABUS.NET (274) - bs[3] : slatch
// always @(posedge cp)
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (ack) begin
			bs_obuf[3] <= abs[3];
		end
	end
end

// ABUS.NET (275) - bs[2] : nivm
//assign bs_obuf[2] = bsi[2]; already same thing

// ABUS.NET (297) - mw01 : nd3
assign mw01 = ~(notmset & notdev & romwid[0]);

// ABUS.NET (298) - mw02 : nd2
assign mw02 = ~(notmset & dev16);

// ABUS.NET (299) - mw03 : nd8
assign mw03 = ~(mset & romlo & (ab[23:21]==3'b000) & notdev & romwid[0]); // 200000-3FFFFF romlo

// ABUS.NET (300) - mw04 : nd6
assign mw04 = ~(mset & romlo & (ab[23:21]==3'b000) & dev16);

// ABUS.NET (301) - mw05 : nd8
assign mw05 = ~(mset & romhi & (ab[23:21]==3'b111) & notdev & romwid[0]);

// ABUS.NET (302) - mw06 : nd6
assign mw06 = ~(mset & romhi & (ab[23:21]==3'b111) & dev16);

// ABUS.NET (303) - mw07 : nd6
assign mw07 = ~(mset & romlo & (ab[23:21]==3'b001) & romwid[0]);

// ABUS.NET (304) - mw08 : nd6
assign mw08 = ~(mset & romhi & (ab[23:21]==3'b110) & romwid[0]);

// ABUS.NET (305) - mw09 : nd6
assign mw09 = ~(mset & romlo & (ab[23:22]==2'b01) & romwid[0]);

// ABUS.NET (306) - mw0a : nd6
assign mw0a = ~(mset & romhi & (ab[23:22]==2'b10) & romwid[0]);

// ABUS.NET (307) - mw0b : nd6
assign mw0b = ~(mset & romlo & (ab[23:22]==2'b10) & dwid1[0]);

// ABUS.NET (308) - mw0c : nd6
assign mw0c = ~(mset & romhi & (ab[23:22]==2'b01) & dwid1[0]);

// ABUS.NET (309) - mw0d : nd6
assign mw0d = ~(mset & romlo & (ab[23:22]==2'b11) & dwid0[0]);

// ABUS.NET (310) - mw0e : nd6
assign mw0e = ~(mset & romhi & (ab[23:22]==2'b00) & dwid0[0]);

// ABUS.NET (312) - mw[0] : nand14
assign mw[0] = ~(mw01 & mw02 & mw03 & mw04 & mw05 & mw06 & mw07 & mw08 & mw09 & mw0a & mw0b & mw0c & mw0d & mw0e);

// ABUS.NET (315) - mw11 : nd3
assign mw11 = ~(notmset & notdev & romwid[1]);

// ABUS.NET (316) - mw12 : nd2
assign mw12 = ~(notmset & dev32);

// ABUS.NET (317) - mw13 : nd8
assign mw13 = ~(mset & romlo & (ab[23:21]==3'b000) & notdev & romwid[1]); //32 bit bios so never

// ABUS.NET (318) - mw14 : nd6
assign mw14 = ~(mset & romlo & (ab[23:21]==3'b000) & dev32); //32 bit interface to registers

// ABUS.NET (319) - mw15 : nd8
assign mw15 = ~(mset & romhi & (ab[23:21]==3'b111) & notdev & romwid[1]); //32 bit bios so never

// ABUS.NET (320) - mw16 : nd6
assign mw16 = ~(mset & romhi & (ab[23:21]==3'b111) & dev32); //32 bit interface to registers

// ABUS.NET (321) - mw17 : nd6
assign mw17 = ~(mset & romlo & (ab[23:21]==3'b001) & romwid[1]); //32 bit cart

// ABUS.NET (322) - mw18 : nd6
assign mw18 = ~(mset & romhi & (ab[23:21]==3'b110) & romwid[1]); //32 bit cart

// ABUS.NET (323) - mw19 : nd6
assign mw19 = ~(mset & romlo & (ab[23:22]==2'b01) & romwid[1]); //32 bit cart

// ABUS.NET (324) - mw1a : nd6
assign mw1a = ~(mset & romhi & (ab[23:22]==2'b10) & romwid[1]); //32 bit cart

// ABUS.NET (325) - mw1b : nd6
assign mw1b = ~(mset & romlo & (ab[23:22]==2'b10) & dwid1[1]); //64/32 bit dram1

// ABUS.NET (326) - mw1c : nd6
assign mw1c = ~(mset & romhi & (ab[23:22]==2'b01) & dwid1[1]); //64/32 bit dram1

// ABUS.NET (327) - mw1d : nd6
assign mw1d = ~(mset & romlo & (ab[23:22]==2'b11) & dwid0[1]); //64/32 bit dram0

// ABUS.NET (328) - mw1e : nd6
assign mw1e = ~(mset & romhi & (ab[23:22]==2'b00) & dwid0[1]); //64/32 bit dram0

// ABUS.NET (330) - mw[1] : nand14
assign mw[1] = ~(mw11 & mw12 & mw13 & mw14 & mw15 & mw16 & mw17 & mw18 & mw19 & mw1a & mw1b & mw1c & mw1d & mw1e);

// ABUS.NET (333) - notdev : nd4p
assign notdev = ~(ab[20:17]==4'b1000); // 100000-11FFFF

// ABUS.NET (334) - dev32l : nd6
assign dev32l = ~(ab[20:15]==6'b100001); // 108000-10FFFF

// ABUS.NET (335) - dev32 : ivm
assign dev32 = ~dev32l;

// ABUS.NET (336) - dev160 : nd6
assign dev160 = ~(ab[20:15]==6'b100000); // 100000-107FFF

// ABUS.NET (337) - dev161 : nd6
assign dev161 = ~(ab[20:16]==5'b10001); // 110000-11FFFF

// ABUS.NET (338) - dev16 : nd2p
assign dev16 = ~(dev160 & dev161);

// ABUS.NET (346) - notba : iv
assign notba = ~ba;

// ABUS.NET (347) - bm68k : an2
assign bm68k = notba & m68k_obuf;

// ABUS.NET (348) - ai[0] : mx2
assign ai = (bm68k) ? siz_1 : ain[0];

// ABUS.NET (350) - a[0] : tsm
// ABUS.NET (351) - a[1-23] : tsm
assign a_out[0] = ai;
assign a_out[23:1] = ain[23:1];
assign a_oe = ainen;

// ABUS.NET (375) - dwidi[0-1] : mx2
assign dwidi[1:0] = (abt_2) ? dwid1[1:0] : dwid0[1:0];

// ABUS.NET (376) - dwid[0-1] : nivh
assign dwid[1:0] = dwidi[1:0];

// ABUS.NET (378) - ald[0-10] : mx4
assign ald[10:0] = dwid[1] ? (dwid[0] ? at[13:3] : at[12:2]) : (dwid[0] ? at[11:1] : at[10:0]);

// ABUS.NET (383) - cw0i[0] : ha1
// ABUS.NET (384) - cw0i[1] : fa1
assign cw0i[2:0] = {1'b0,dwid0[1:0]} + cols0[1:0];

// ABUS.NET (385) - cw0[0-2] : nivm
assign cw0[2:0] = cw0i[2:0];

// ABUS.NET (387) - cw1i[0] : ha1
// ABUS.NET (388) - cw1i[1] : fa1
assign cw1i[2:0] = {1'b0,dwid1[1:0]} + cols1[1:0];

// ABUS.NET (389) - cw1[0-2] : nivm
assign cw1[2:0] = cw1i[2:0];

// ABUS.NET (393) - ahd0[0-9] : mx8
// ABUS.NET (395) - ahd0[10] : mx8
reg [10:0] ahd0m;
assign ahd0[10:0] = ahd0m[10:0];
always @(*)
begin
	case(cw0[2:0]) // is this fast enough? could use ternaries
		3'b000		: ahd0m[10:0] = at[18:8];
		3'b001		: ahd0m[10:0] = at[19:9];
		3'b010		: ahd0m[10:0] = at[20:10];
		3'b011		: ahd0m[10:0] = at[21:11];
		3'b100		: ahd0m[10:0] = at[22:12];
		3'b101		: ahd0m[10:0] = at[23:13];
		3'b110		: ahd0m[10:0] = {1'b0,at[23:14]};
		default		: ahd0m[10:0] = 10'h000;
	endcase
end

// ABUS.NET (397) - ahd1[0-9] : mx8
// ABUS.NET (399) - ahd1[10] : mx8
reg [10:0] ahd1m;
assign ahd1[10:0] = ahd1m[10:0];
always @(*)
begin
	case(cw1[2:0]) // is this fast enough? could use ternaries
		3'b000		: ahd1m[10:0] = at[18:8];
		3'b001		: ahd1m[10:0] = at[19:9];
		3'b010		: ahd1m[10:0] = at[20:10];
		3'b011		: ahd1m[10:0] = at[21:11];
		3'b100		: ahd1m[10:0] = at[22:12];
		3'b101		: ahd1m[10:0] = at[23:13];
		3'b110		: ahd1m[10:0] = {1'b0,at[23:14]};
		default		: ahd1m[10:0] = 10'h000;
	endcase
end

// ABUS.NET (403) - ahd[0-10] : mx2
assign ahd[10:0] = (abt_2) ? ahd1[10:0] : ahd0[10:0];

// ABUS.NET (404) - mad[0-10] : mx2
assign mad[10:0] = (mux) ? ahd[10:0] : ald[10:0];

// ABUS.NET (405) - ma[0-10] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		ma_obuf[10:0] <= mad[10:0];
	end
end

// ABUS.NET (411) - newrow[0] : an2h
assign newrow_[0] = bs_obuf[3] & newrow;

// ABUS.NET (412) - newrow[1] : an2h
assign newrow_[1] = bs_obuf[2] & newrow;

// ABUS.NET (413) - reset : iv
assign reset = ~resetl;

// ABUS.NET (414) - bankresl : nr2
assign bankresl = ~(reset | resrow);

// ABUS.NET (416) - bank[0] : bank
// ABUS.NET (417) - bank[1] : bank
reg [10:0] bank0 = 11'h000;
reg valid0 = 1'b1;
reg [10:0] bank1 = 11'h000;
reg valid1 = 1'b1;

// ABUS.NET (483) - ra[0-10] : ldp1q
// always @(d or g)
// ABUS.NET (488) - valid : lsra
// always @(rn or sn)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (newrow_[0]) begin
		bank0[10:0] <= ahd0[10:0];
		valid0 <= 1'b1;
	end else if (~bankresl) begin
		valid0 <= 1'b0;
	end
	if (newrow_[1]) begin
		bank1[10:0] <= ahd1[10:0];
		valid1 <= 1'b1;
	end else if (~bankresl) begin
		valid1 <= 1'b0;
	end
end

// ABUS.NET (492) - m[0-10] : en
assign match_[0] = (bank0[10:0] == ahd0[10:0]) & valid0;
assign match_[1] = (bank1[10:0] == ahd1[10:0]) & valid1;

// ABUS.NET (419) - m[0] : nd2
assign m[0] = ~(match_[0] & abs[3]);

// ABUS.NET (420) - m[1] : nd2
assign m[1] = ~(match_[1] & abs[2]);

// ABUS.NET (421) - match : nd2
assign match = ~(&m[1:0]);

// ABUS.NET (429) - intd0 : nd6
assign intd0 = ~(dreqin & (&fc[2:0]) & ainen & m68k_obuf);

// ABUS.NET (430) - intd1 : nd2
assign intd1 = ~(fcl[0] & not68k);

// ABUS.NET (431) - intd : nd2
assign intd = ~(intd0 & intd1);

// ABUS.NET (432) - intas : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		ouracki <= intd;
	end
end

// ABUS.NET (433) - notourack : ivm
assign notourack = ~ouracki;

// ABUS.NET (434) - ourack : ivh
assign ourack = ~notourack;

// ABUS.NET (436) - fcl[0] : iv
assign fcl[0] = ~fc[0];

// ABUS.NET (440) - gpuadd : or2
assign gpuadd = |at[14:13];

// ABUS.NET (441) - gpuread : an3
assign gpuread = gpuadd & readt & d7a;

// ABUS.NET (442) - gpuwrite : an3
assign gpuwrite = gpuadd & writet & d7a;

// ABUS.NET (443) - wr : iv
assign writet = ~readt;

// ABUS.NET (447) - lbufb : iv
assign lbufb = ~lbufa;

// ABUS.NET (448) - lba0 : nd6
assign lba0 = ~(fintdev_obuf & (ab[14:11]==4'b0001) & notourack);

// ABUS.NET (449) - lba1 : nd8
assign lba1 = ~(fintdev_obuf & (ab[14:11]==4'b0011) & lbufb & notourack);

// ABUS.NET (450) - lbad : nd2
assign lbad = ~(lba0 & lba1);

// ABUS.NET (451) - lbb0 : nd6
assign lbb0 = ~(fintdev_obuf & (ab[14:11]==4'b0010) & notourack);

// ABUS.NET (452) - lbb1 : nd8
assign lbb1 = ~(fintdev_obuf & (ab[14:11]==4'b0011) & lbufa & notourack);

// ABUS.NET (453) - lbbd : nd2
assign lbbd = ~(lbb0 & lbb1);

// ABUS.NET (454) - clutd : an8
assign clutd = fintdev_obuf & (ab[15:10]==6'b000001) & notourack;

// ABUS.NET (455) - lb0 : nd6
assign lb0 = ~(fintdev_obuf & (ab[14:13]==2'b00) & (ab[11]==1'b1) & notourack);

// ABUS.NET (456) - lb1 : nd6
assign lb1 = ~(fintdev_obuf & (ab[14:12]==3'b001) & notourack);

// ABUS.NET (457) - lbd : nd2
assign lbd = ~(lb0 & lb1);

// ABUS.NET (459) - lbat : mx2
assign lbat = (ack) ? lbad : lba_obuf;

// ABUS.NET (460) - lbai : fd2qp
// ABUS.NET (463) - lbbi : fd2qp
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			lba_obuf <= 1'b0;// always @(posedge cp or negedge sd)
			lbb_obuf <= 1'b0;// always @(posedge cp or negedge sd)
			lb <= 1'b0;// always @(posedge cp or negedge sd)
			clut_obuf <= 1'b0;// always @(posedge cp or negedge sd)
		end else begin
			lba_obuf <= lbat;
			lbb_obuf <= lbbt;
			lb <= lbt_obuf;
			clut_obuf <= clutt_obuf;
		end
	end
end

// ABUS.NET (462) - lbbt : mx2
assign lbbt = (ack) ? lbbd : lbb_obuf;

// ABUS.NET (465) - lbt : mx2h
assign lbt_obuf = (ack) ? lbd : lb;

// ABUS.NET (466) - lbi : fd2qp

// ABUS.NET (468) - clutt : mx2h
assign clutt_obuf = (ack) ? clutd : clut_obuf;

// ABUS.NET (469) - cluti : fd2qp

// --- Compiler-generated PE for BUS dr[0]
assign dr_out[15:0] = (dr_a0_oe ? dr_a0_out[15:0] : 16'h0000) | (dr_a1_oe ? dr_a1_out[15:0] : 16'h0000);
assign dr_oe = dr_a0_oe | dr_a1_oe;
endmodule
