/* verilator lint_off LITENDIAN */
//`include "defs.v"

module _j_jmem
(
	input resetl,
	input clk,
	input dbgl,
	input bigend,
	input dsp16,
	input [2:0] w,
	input rw,
	input mreq,
	input dtackl,
	input dspcsl,
	input wel_0,
	input oel_0,
	input testen,
	input at_15,
	input internal,
	input [1:0] dbrl,
	input [1:0] aout,
	input ndtest,
	output ack,
	output den,
	output aen,
	output [1:0] siz,
	output dreql,
	output [1:0] dmuxu,
	output [1:0] dmuxd,
	output dren,
	output xdsrc,
	output iordl,
	output iowrl,
	output dspread,
	output dspwrite,
	output [1:0] dinlatch,
	output ainen,
	output seta1,
	output reads,
	output [1:0] dbrls,
	output dspen,
	output masterdata,
	input sys_clk // Generated
);
reg q0 = 1'b1;
wire d0;
reg q1 = 1'b0;
wire d1;
reg q2 = 1'b0;
wire d2;
reg q3 = 1'b0;
wire d3;
reg q4 = 1'b0;
wire d4;
wire q1b;
wire q3b;
wire d00;
wire d01;
wire notmreq;
wire d02;
wire dbg;
wire dtack;
wire notsplit;
wire d03;
wire d10;
wire d11;
wire d12;
wire d13;
wire d20;
wire split;
wire d21;
wire d30;
wire d31;
wire d32;
wire d40;
wire d41;
wire d42;
wire ack0;
wire ack1;
wire acki;
wire notrw;
wire doll;
reg lwdl = 1'b0;
reg readsi = 1'b0;
wire writes;
wire dl00;
wire dl01;
wire littleend;
wire dl02;
wire [1:0] dinlatchi;
wire dl11;
wire dl12;
wire reset;
wire aeni;
wire den0;
wire notndtest;
wire den1;
wire oe_0;
wire deni;
wire drenl;
wire xdsrci;
wire du0;
wire dmuxui;
wire dd0;
wire dd1;
wire dd2;
wire [1:0] ax;
wire dsp32;
wire dmuxdi;
wire dmuxu0i;
wire dmuxd0i;
wire md0;
wire masterdatai;
wire dspcs;
wire long;
reg [2:0] ws = 3'h0;
reg qs0 = 1'b1;
wire ds0;
reg qs1 = 1'b0;
wire ds1;
reg qs2 = 1'b0;
reg qs3 = 1'b0;
reg qs4 = 1'b0;
wire ds4;
wire ds00;
wire ds01;
wire notstrobe;
wire ds02;
wire ds03;
wire strobe;
wire ds40;
wire ds41;
wire we_0;
wire dspen0;
wire dspen1;
reg [1:0] dbrls_ = 2'b11;

// Output buffers
wire ack_obuf;
wire reads_obuf;


// Output buffers
assign ack = ack_obuf;
assign reads = reads_obuf;
assign dbrls[1:0] = dbrls_[1:0];

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// JMEM.NET (73) - q0 : fd4q
// JMEM.NET (74) - q1 : fd2q
// JMEM.NET (75) - q2 : fd2q
// JMEM.NET (76) - q3 : fd2q
// JMEM.NET (77) - q4 : fd2q
// always @(posedge cp or negedge sd)
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			q0 <= 1'b1;
			q1 <= 1'b0;
			q2 <= 1'b0;
			q3 <= 1'b0;
			q4 <= 1'b0;
		end else begin
			q0 <= d0;
			q1 <= d1;
			q2 <= d2;
			q3 <= d3;
			q4 <= d4;
		end
	end
end

// JMEM.NET (78) - q1b : nivm
// JMEM.NET (79) - q3b : nivm
assign q1b = q1;
assign q3b = q3;

// JMEM.NET (81) - d00 : nd2
assign d00 = ~(q0 & dbgl);

// JMEM.NET (82) - d01 : nd2
assign d01 = ~(q0 & notmreq);

// JMEM.NET (83) - d02 : nd6
assign d02 = ~(q1b & dbg & dtack & notsplit & notmreq);

// JMEM.NET (84) - d03 : nd4
assign d03 = ~(q3b & dbg & dtack & notmreq);

// JMEM.NET (85) - d0 : nd4
assign d0 = ~(d00 & d01 & d02 & d03);

// JMEM.NET (87) - d10 : nd3
assign d10 = ~(q0 & dbg & mreq);

// JMEM.NET (88) - d11 : nd2
assign d11 = ~(q1b & dbgl);

// JMEM.NET (89) - d12 : nd2
assign d12 = ~(q1b & dtackl);

// JMEM.NET (90) - d13 : nd2
assign d13 = ~(q4 & dbg);

// JMEM.NET (91) - d1 : nd4
assign d1 = ~(d10 & d11 & d12 & d13);

// JMEM.NET (93) - d20 : nd4
assign d20 = ~(q1b & dbg & dtack & split);

// JMEM.NET (94) - d21 : nd2
assign d21 = ~(q2 & dtack);

// JMEM.NET (95) - d2 : nd2
assign d2 = ~(d20 & d21);

// JMEM.NET (97) - d30 : nd2
assign d30 = ~(q2 & dtackl);

// JMEM.NET (98) - d31 : nd2
assign d31 = ~(q3b & dbgl);

// JMEM.NET (99) - d32 : nd2
assign d32 = ~(q3b & dtackl);

// JMEM.NET (100) - d3 : nd3
assign d3 = ~(d30 & d31 & d32);

// JMEM.NET (102) - d40 : nd6
assign d40 = ~(q1b & dbg & dtack & notsplit & mreq);

// JMEM.NET (103) - d41 : nd4
assign d41 = ~(q3b & dbg & dtack & mreq);

// JMEM.NET (104) - d42 : nd2
assign d42 = ~(q4 & dbgl);

// JMEM.NET (105) - d4 : nd3
assign d4 = ~(d40 & d41 & d42);

// JMEM.NET (107) - ack0 : iv
assign ack0 = ~q0;

// JMEM.NET (108) - ack1 : iv
assign ack1 = ~q4;

// JMEM.NET (109) - acki : nd4
assign acki = ~(d02 & d03 & ack0 & ack1);

// JMEM.NET (110) - ack : nivu
assign ack_obuf = acki;

// JMEM.NET (111) - dreql : nr2
assign dreql = ~(q1b | q3b);

// JMEM.NET (115) - notrw : iv
assign notrw = ~rw;

// JMEM.NET (116) - dol : nd3
assign doll = ~(ack_obuf & notrw & mreq);

// JMEM.NET (117) - lwd : fd1q
// JMEM.NET (119) - readsi : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		lwdl <= doll;
		if (ack_obuf) begin
			readsi <= rw;
		end
	end
end

// JMEM.NET (120) - reads : nivh
assign reads_obuf = readsi;

// JMEM.NET (121) - writes : iv
assign writes = ~reads_obuf;

// JMEM.NET (123) - dl00 : nd3
assign dl00 = ~(q1b & reads_obuf & notsplit);

// JMEM.NET (124) - dl01 : nd4
assign dl01 = ~(q1b & reads_obuf & split & littleend);

// JMEM.NET (125) - dl02 : nd3
assign dl02 = ~(q3b & reads_obuf & bigend);

// JMEM.NET (126) - dinlatchi[0] : nd4
assign dinlatchi[0] = ~(dl00 & dl01 & dl02 & lwdl);

// JMEM.NET (128) - dl11 : nd4
assign dl11 = ~(q1b & reads_obuf & split & bigend);

// JMEM.NET (129) - dl12 : nd3
assign dl12 = ~(q3b & reads_obuf & littleend);

// JMEM.NET (130) - dinlatchi[1] : nd4
assign dinlatchi[1] = ~(dl00 & dl11 & dl12 & lwdl);

// JMEM.NET (132) - dinlatch[0-1] : nivh
assign dinlatch[1:0] = dinlatchi[1:0];

// JMEM.NET (134) - reset : iv
assign reset = ~resetl;

// JMEM.NET (135) - aeni : nr3
assign aeni = ~(dbgl | ndtest | reset);

// JMEM.NET (136) - aen : nivu
assign aen = aeni;

// JMEM.NET (145) - den0 : nd6
assign den0 = ~(dbg & writes & testen & notndtest & resetl);

// JMEM.NET (146) - den1 : nd6
assign den1 = ~(oe_0 & internal & testen & notndtest & resetl);

// JMEM.NET (147) - deni : nd2
assign deni = ~(den0 & den1);

// JMEM.NET (148) - den : nivu
assign den = deni;

// JMEM.NET (149) - drenl : nd2
assign drenl = ~(oe_0 & internal);

// JMEM.NET (150) - dren : ivh
assign dren = ~drenl;

// JMEM.NET (151) - ainen : nivu
assign ainen = dbgl;

// JMEM.NET (152) - notndtest : iv
assign notndtest = ~ndtest;

// JMEM.NET (154) - iordl : or2
assign iordl = dspcsl | oel_0;

// JMEM.NET (155) - iowrl : or2
assign iowrl = dspcsl | wel_0;

// JMEM.NET (162) - xdsrci : nd2
assign xdsrci = ~(dbg & writes);

// JMEM.NET (163) - xdsrc : nivu
assign xdsrc = xdsrci;

// JMEM.NET (171) - du0 : nd2
assign du0 = ~(writes & ~ws[2]);

// JMEM.NET (172) - dmuxui : nd3
assign dmuxui = ~(dl11 & dl12 & du0);

// JMEM.NET (173) - dmuxu[1] : nivh
assign dmuxu[1] = dmuxui;

// JMEM.NET (181) - dd0 : nd4
assign dd0 = ~(q1b & writes & split & bigend);

// JMEM.NET (182) - dd1 : nd3
assign dd1 = ~(q3b & writes & littleend);

// JMEM.NET (183) - dd2 : nd4
assign dd2 = ~(~ws[2] & reads_obuf & ax[1] & dsp32);

// JMEM.NET (184) - dmuxdi : nd3
assign dmuxdi = ~(dd0 & dd1 & dd2);

// JMEM.NET (185) - dmuxd[1] : nivh
assign dmuxd[1] = dmuxdi;

// JMEM.NET (191) - dmuxu0i : nd3
assign dmuxu0i = ~(writes & &(~ws[2:1]));

// JMEM.NET (192) - dmuxu[0] : ivh
assign dmuxu[0] = ~dmuxu0i;

// JMEM.NET (198) - dmuxd0i : nd4
assign dmuxd0i = ~(reads_obuf & &(~ws[2:1]) & ax[0]);

// JMEM.NET (199) - dmuxd[0] : ivh
assign dmuxd[0] = ~dmuxd0i;

// JMEM.NET (201) - ax[0-1] : eo
assign ax[1:0] = aout[1:0] ^ {2{bigend}};

// JMEM.NET (209) - md0 : nd2
assign md0 = ~(dbg & writes);

// JMEM.NET (210) - mdi : nd2
assign masterdatai = ~(md0 & dspcs);

// JMEM.NET (211) - masterdata : nivh
assign masterdata = masterdatai;

// JMEM.NET (226) - split : an2
assign split = dsp16 & ws[2];

// JMEM.NET (227) - notsplit : iv
assign notsplit = ~split;

// JMEM.NET (228) - long : an2
assign long = dsp32 & ws[2];

// JMEM.NET (229) - dsp32 : iv
assign dsp32 = ~dsp16;

// JMEM.NET (231) - siz[0] : or2
assign siz[0] = ws[0] | long;

// JMEM.NET (232) - siz[1] : or2
assign siz[1] = |ws[2:1];

// JMEM.NET (234) - seta1 : niv
assign seta1 = q3b;

// JMEM.NET (236) - notmreq : iv
assign notmreq = ~mreq;

// JMEM.NET (237) - dbg : ivh
assign dbg = ~dbgl;

// JMEM.NET (238) - dtack : iv
assign dtack = ~dtackl;

// JMEM.NET (239) - littlend : iv
assign littleend = ~bigend;

// JMEM.NET (243) - ws[0-2] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (ack_obuf) begin
			ws[2:0] <= w[2:0];
		end
	end
end

// JMEM.NET (244) - dbrls[0-1] : slatchp
// always @(posedge cp or negedge sd)
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			dbrls_[1:0] <= 2'b11;
		end else if (ack_obuf) begin
			dbrls_[1:0] <= dbrl[1:0];
		end
	end
end

// JMEM.NET (270) - qs0 : fd4q
// JMEM.NET (271) - qs1 : fd2q
// JMEM.NET (272) - qs2 : fd2q
// JMEM.NET (273) - qs3 : fd2q
// JMEM.NET (274) - qs4 : fd2q
// always @(posedge cp or negedge sd)
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			qs0 <= 1'b1;
			qs1 <= 1'b0;
			qs2 <= 1'b0;
			qs3 <= 1'b0;
			qs4 <= 1'b0;
		end else begin
			qs0 <= ds0;
			qs1 <= ds1;
			qs2 <= qs1;
			qs3 <= qs2;
			qs4 <= ds4;
		end
	end
end

// JMEM.NET (276) - ds00 : nd2
assign ds00 = ~(qs0 & dspcsl);

// JMEM.NET (277) - ds01 : nd2
assign ds01 = ~(qs0 & notstrobe);

// JMEM.NET (278) - ds02 : nd2
assign ds02 = ~(qs3 & notstrobe);

// JMEM.NET (279) - ds03 : nd2
assign ds03 = ~(qs4 & notstrobe);

// JMEM.NET (280) - ds0 : nd4
assign ds0 = ~(ds00 & ds01 & ds02 & ds03);

// JMEM.NET (282) - ds1 : an3
assign ds1 = qs0 & dspcs & strobe;

// JMEM.NET (284) - ds40 : nd2
assign ds40 = ~(qs3 & strobe);

// JMEM.NET (285) - ds41 : nd2
assign ds41 = ~(qs4 & strobe);

// JMEM.NET (286) - ds4 : nd2
assign ds4 = ~(ds40 & ds41);

// JMEM.NET (288) - strobe : nd2
assign strobe = ~(oel_0 & wel_0);

// JMEM.NET (289) - notstrobe : iv
assign notstrobe = ~strobe;

// JMEM.NET (291) - dspread : an3
assign dspread = qs1 & at_15 & oe_0;

// JMEM.NET (292) - dspwrite : an3
assign dspwrite = qs1 & at_15 & we_0;

// JMEM.NET (294) - oe[0] : iv
assign oe_0 = ~oel_0;

// JMEM.NET (295) - we[0] : iv
assign we_0 = ~wel_0;

// JMEM.NET (296) - dspcs : iv
assign dspcs = ~dspcsl;

// JMEM.NET (298) - dspen0 : nd3
assign dspen0 = ~(oe_0 & qs2 & at_15);

// JMEM.NET (299) - dspen1 : nd3
assign dspen1 = ~(oe_0 & qs3 & at_15);

// JMEM.NET (300) - dspen : nd2
assign dspen = ~(dspen0 & dspen1);

endmodule
/* verilator lint_on LITENDIAN */
