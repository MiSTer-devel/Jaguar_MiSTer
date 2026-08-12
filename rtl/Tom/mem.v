//`include "defs.v"
// altera message_off 10036

module _mem
(
	input [1:0] bbreq,
	input [1:0] gbreq,
	input obbreq,
	input [1:0] sizin,
	input [1:0] dbrl,
	input dreqin,
	input rwin,
	input [3:0] bs,
	input match,
	input intdev,
	input dram,
	input fextdev,
	input fintdev,
	input fdram,
	input from,
	input cpu32,
	input refreq,
	input [1:0] dspd,
	input [1:0] romspd,
	input [1:0] iospd,
	input [2:0] a,
	input [1:0] mw,
	input ourack,
	input resetl,
	input clk,
	input bglin,
	input brlin,
	input ihandler,
	input bigend,
	input bgain,
	input [3:2] abs,
	input testen,
	input waitl,
	input fastrom,
	input m68k,
	input pclk,
	output ack,
	output bback,
	output gback,
	output obback,
	output [1:0] romcsl,
	output [1:0] rasl,
	output [1:0] casl,
	output [2:0] oel,
	output [7:0] wel,
	output [2:0] sizout,
	output [2:0] den,
	output aen,
	output dtackl,
	output brlout,
	output dbgl,
	output dreqlout,
	output d7a,
	output readt,
	output [7:0] dinlatch,
	output [2:0] dmuxu,
	output [2:0] dmuxd,
	output dren,
	output xdsrc,
	output [2:0] maska,
	output [2:0] at,
	output ainen,
	output newrow,
	output resrow,
	output mux,
	output refack,
	output reads,
	output wet,
	output oet,
	output ba,
	output intswe,
	output intwe,
	output dspcsl,
	output [3:0] w_out,
	output w_oe,
	input [3:0] w_in,
	output rw_out,
	output rw_oe,
	input rw_in,
	output mreq_out,
	output mreq_oe,
	input mreq_in,
	output justify_out,
	output justify_oe,
	input justify_in,
	input tlw,

	// below signals NOT_NETLIST
	input ram_rdy,
	input sys_clk, // Generated
	output d3a,
	output d3b,
	output [7:0] we_,
	output startwep,
	output startwe_out,
	output startcas_out,
	input turbo
);
wire notreadt;
wire intbm;
wire cpubm;
wire intbms;
wire intbmw;
wire [1:0] mwt;
wire nextc;
wire [3:0] maskw;
wire lastcycle;
wire lastc;
wire [7:0] bm;
wire [2:0] ba_;
wire mws64;
wire mws16;
wire mws8;
wire erd;
reg idle = 1'b1;
wire notack;
wire d0;
reg q1a = 1'b0;
wire d1a;
reg q1b = 1'b0;
wire d1b;
reg q1c = 1'b0;
wire d1c;
reg q1d = 1'b0;
wire d1d;
reg q2a = 1'b0;
reg q2b = 1'b0;
wire d2b;
reg q2c = 1'b0;
wire d2c;
reg q3a = 1'b0;
//wire d3a;
reg q3b = 1'b0;
//wire d3b;
reg q4a = 1'b0;
wire d4a;
reg q4b = 1'b0;
wire d4b;
reg q4c = 1'b0;
wire d4c;
reg q4d = 1'b0;
wire d4d;
reg q4e = 1'b0;
reg q4f = 1'b0;
wire d4f;
reg q4g = 1'b0;
wire d4g;
reg q4h = 1'b0;
wire d4h;
reg q4i = 1'b0;
reg q5ai = 1'b0;
wire d5a;
reg q5b = 1'b0;
wire d5b;
reg q5c = 1'b0;
wire d5c;
reg q7a = 1'b0;
reg q7b = 1'b0;
wire d7b;
reg q8a = 1'b0;
wire d8a;
reg q8b = 1'b0;
wire d8b;
reg q8c = 1'b0;
wire d8c;
reg q10 = 1'b0;
wire d10;
wire q5a;
wire mtb0;
wire mtb1;
wire mtb2;
wire mtb3;
wire mtb5;
wire mtb6;
wire mtb8;
wire mtb9;
wire mtba;
wire mtbb;
wire mtbd;
reg mtb = 1'b1;
wire notmreq;
wire mreqb;
wire notmatch;
wire notrefack;
wire notourack;
wire mt1b0;
wire [3:0] dramspeed;
wire mt1b1;
wire mt1c0;
wire mt1c1;
wire mt1d0;
wire mt1d1;
wire mt2b0;
wire mt2b1;
wire mt2c0;
wire mt2c1;
wire mt3a0;
wire mt3a1;
wire mt3a2;
wire mt3a3;
wire notlastcycle;
wire ram_bsy;
wire mt3a4;
wire mt4b0;
wire mt4b1;
wire mt4c0;
wire mt4c1;
wire mt4d0;
wire mt4d1;
wire mt4g0;
wire mt4g1;
wire mt4g2;
wire mt4h0;
wire mt4h1;
wire mt5a0;
wire mt5a1;
wire mt5b0;
wire slowrom;
wire mt5b1;
wire notwaitdone;
wire mt5c0;
wire mt5c1;
wire waitdone;
wire mt7a0;
wire mt7a1;
wire notreads;
wire mt7a2;
wire mt8a0;
wire mt8a1;
wire mt8b0;
wire mt8b1;
wire wait1;
wire wait2;
wire wait30;
wire wait31;
wire wait3;
wire wait5;
wire wait70;
wire [3:0] romspeed;
wire wait71;
wire wait7;
wire wait15;
wire [3:0] iospeed;
wire [2:1] rasoffl;
wire rason;
wire muxi;
wire oet0;
wire oet1;
wire oet2;
wire oet3;
wire oet4;
wire oet5;
wire oet6;
wire oet7;
wire oeti;
//wire startcas;
wire dinl0;
wire dinl1;
wire dinl3;
wire dinl4;
wire dinlatchd;
wire dinlatch_;
wire iwnext;
wire nextci;
wire sw0;
wire swd;
reg startwe = 1'b0;
wire notrw;
wire doll;
reg lwdli1 = 1'b0;
reg lwdli2 = 1'b0;
wire lwdl;
wire allrasoffl;
wire allrasonl;
wire allcasonl;
reg [3:0] wq = 4'h0;
wire [2:0] wd;
wire wcen;
wire wld;
wire _wait;
wire waitdonei;
wire clkl;
wire pclkl;
wire [1:0] casd;
reg cas00 = 1'b1;
reg cas01 = 1'b1;
reg cas10 = 1'b1;
reg cas11 = 1'b1;
wire romcst;
wire dspcsli;
wire int_wel;
wire [1:0] mwsl;
reg [1:0] mws = 2'b00;
reg wet0 = 1'b0;
wire wet0l;
wire weti;
wire mws32;
wire we00;
wire we01;
wire we02;
wire we03;
wire we04;
wire we05;
wire [3:0] we;
wire we10;
wire we11;
wire we12;
wire we13;
wire we14;
wire we15;
wire we16;
wire we20;
wire we21;
wire we22;
wire we30;
wire we31;
wire we32;
wire oe00;
wire oe01;
wire oe02;
wire oe03;
wire oe04;
wire oe05;
wire oe10;
wire oe11;
wire oe12;
wire oe13;
wire oe14;
wire oe15;
wire oe20;
wire oe21;
wire oe22;
wire oe23;
wire [7:0] dinlatchl;
reg readsi = 1'b0;
wire [1:0] mwti;
wire dreqd;
reg dreqlout_;

// Output buffers
wire ack_obuf;
wire dbgl_obuf;
wire d7a_obuf;
wire readt_obuf;
wire [2:0] maska_obuf;
wire refack_obuf;
wire reads_obuf;
wire wet_obuf;
wire oet_obuf;
wire ba_obuf;


// Output buffers
assign ack = ack_obuf;
assign dbgl = dbgl_obuf;
assign d7a = d7a_obuf;
assign readt = readt_obuf;
assign maska = maska_obuf;
assign refack = refack_obuf;
assign reads = reads_obuf;
assign wet = wet_obuf;
assign oet = oet_obuf;
assign ba = ba_obuf;
assign dreqlout = dreqlout_;

//`define ORIGINAL_RAM

// MEM.NET (117) - arb : arb
_arb arb_inst
(
	.bbreq /* IN */ (bbreq[1:0]),
	.gbreq /* IN */ (gbreq[1:0]),
	.obbreq /* IN */ (obbreq),
	.bglin /* IN */ (bglin),
	.brlin /* IN */ (brlin),
	.dbrl /* IN */ (dbrl[1:0]),
	.refreq /* IN */ (refreq),
	.ihandler /* IN */ (ihandler),
	.ack /* IN */ (ack_obuf),
	.resetl /* IN */ (resetl),
	.clk /* IN */ (clk),
	.bgain /* IN */ (bgain),
	.notreadt /* IN */ (notreadt),
	.dreqin /* IN */ (dreqin),
	.bback /* OUT */ (bback),
	.gback /* OUT */ (gback),
	.obback /* OUT */ (obback),
	.brlout /* OUT */ (brlout),
	.dbgl /* OUT */ (dbgl_obuf),
	.refack /* OUT */ (refack_obuf),
	.ba /* OUT */ (ba_obuf),
	.intbm /* OUT */ (intbm),
	.cpubm /* OUT */ (cpubm),
	.intbms /* OUT */ (intbms),
	.intbmw /* OUT */ (intbmw),
	.sys_clk(sys_clk) // Generated
);

// MEM.NET (124) - mw : memwidth
_memwidth mw_inst
(
	.w /* IN */ (w_in[3:0]),
	.ba /* IN */ (a[2:0]),
	.mw /* IN */ (mwt[1:0]),
	.ack /* IN */ (ack_obuf),
	.nextc /* IN */ (nextc),
	.clk /* IN */ (clk),
	.bigend /* IN */ (bigend),
	.maskw /* OUT */ (maskw[3:0]),
	.maska /* OUT */ (maska_obuf[2:0]),
	.at /* OUT */ (at[2:0]),
	.lastcycle /* OUT */ (lastcycle),
	.lastc /* OUT */ (lastc),
	.bm /* OUT */ (bm[7:0]),
	.sys_clk(sys_clk) // Generated
);

// MEM.NET (130) - bus : bus
_bus bus_inst
(
	.reads /* IN */ (reads_obuf),
	.ack /* IN */ (ack_obuf),
	.intdev /* IN */ (intdev),
	.cpu32 /* IN */ (cpu32),
	.ba /* IN */ (ba_[2:0]),
	.mws64 /* IN */ (mws64),
	.mws16 /* IN */ (mws16),
	.mws8 /* IN */ (mws8),
	.notdbg /* IN */ (dbgl_obuf),
	.ourack /* IN */ (ourack),
	.w /* IN */ (w_in[3:0]),
	.erd /* IN */ (erd),
	.justify /* IN */ (justify_in),
	.intbm /* IN */ (intbm),
	.intbms /* IN */ (intbms),
	.cpubm /* IN */ (cpubm),
	.clk /* IN */ (clk),
	.testen /* IN */ (testen),
	.intbmw /* IN */ (intbmw),
	.resetl /* IN */ (resetl),
	.idle /* IN */ (idle),
	.den /* OUT */ (den[2:0]),
	.aen /* OUT */ (aen),
	.dmuxu /* OUT */ (dmuxu[2:0]),
	.dmuxd /* OUT */ (dmuxd[2:0]),
	.dren /* OUT */ (dren),
	.xdsrc /* OUT */ (xdsrc),
	.ainen /* OUT */ (ainen),
	.sys_clk(sys_clk) // Generated
);

// MEM.NET (140) - cpu : cpu
_cpu cpu_inst
(
	.sizin /* IN */ (sizin[1:0]),
	.rwin /* IN */ (rwin),
	.notack /* IN */ (notack),
	.ack /* IN */ (ack_obuf),
	.dreqin /* IN */ (dreqin),
	.resetl /* IN */ (resetl),
	.clk_0 /* IN */ (clk),
	.intbm /* IN */ (intbm),
	.intbms /* IN */ (intbms),
	.m68k /* IN */ (m68k),
	.ba /* IN */ (ba_obuf),
	.dbgl /* IN */ (dbgl_obuf),
	.dtackl /* OUT */ (dtackl),
	.erd /* OUT */ (erd),
	.w_out /* BUS */ (w_out[3:0]),
	.w_oe /* BUS */ (w_oe),
	.w_in /* BUS */ (w_in[3:0]),
	.rw_out /* BUS */ (rw_out),
	.rw_oe /* BUS */ (rw_oe),
	.rw_in /* BUS */ (rw_in),
	.mreq_out /* BUS */ (mreq_out),
	.mreq_oe /* BUS */ (mreq_oe),
	.justify_out /* BUS */ (justify_out),
	.justify_oe /* BUS */ (justify_oe),
	.sys_clk(sys_clk) // Generated
);

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end


// MEM.NET (276) - q0 : fd4q
// MEM.NET (277) - q1a : fd2q
// MEM.NET (278) - q1b : fd2q
// MEM.NET (279) - q1c : fd2q
// MEM.NET (280) - q1d : fd2q
// MEM.NET (281) - q2a : fd2q
// MEM.NET (282) - q2b : fd2q
// MEM.NET (283) - q2c : fd2q
// MEM.NET (284) - q3a : fd2q
// MEM.NET (288) - q3b : fd2q
// MEM.NET (290) - q4a : fd2q
// MEM.NET (291) - q4b : fd2q
// MEM.NET (292) - q4c : fd2q
// MEM.NET (293) - q4d : fd2q
// MEM.NET (294) - q4e : fd2q
// MEM.NET (295) - q4f : fd2q
// MEM.NET (296) - q4g : fd2q
// MEM.NET (297) - q4h : fd2q
// MEM.NET (298) - q4i : fd2q
// MEM.NET (299) - q5ai : fd2q
// MEM.NET (300) - q5b : fd2q
// MEM.NET (301) - q5c : fd2q
// MEM.NET (302) - q7a : fd2q
// MEM.NET (303) - q7b : fd2q
// MEM.NET (304) - q8a : fd2q
// MEM.NET (305) - q8b : fd2q
// MEM.NET (306) - q8c : fd2q
// MEM.NET (307) - q10 : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			idle <= 1'b1; // fd2q negedge // always @(posedge cp or negedge cd)
			q1a <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q1b <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q1c <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q1d <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q2a <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q2b <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q2c <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q3a <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
`ifdef ORIGINAL_RAM
			q3b <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
`else
			q3b <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
`endif
			q4a <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q4b <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q4c <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q4d <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q4e <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q4f <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q4g <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q4h <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q4i <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q5ai <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q5b <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q5c <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q7a <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q7b <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q8a <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q8b <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q8c <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			q10 <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
		end else begin
			idle <= d0;
			q1a <= d1a;
			q1b <= d1b;
			q1c <= d1c;
			q1d <= d1d;
			q2a <= q1d;
			q2b <= d2b;
			q2c <= d2c;
			q3a <= d3a;
`ifdef ORIGINAL_RAM
			q3b <= q3a;
`else
			q3b <= d3b;
`endif
			q4a <= d4a;
			q4b <= d4b;
			q4c <= d4c;
			q4d <= d4d;
			q4e <= q4d;
			q4f <= d4f;
			q4g <= d4g;
			q4h <= d4h;
			q4i <= q4h;
			q5ai <= d5a;
			q5b <= d5b;
			q5c <= d5c;
			q7a <= d7a_obuf;
			q7b <= d7b;
			q8a <= d8a;
			q8b <= d8b;
			q8c <= d8c;
			q10 <= d10;
		end
	end
end

// MEM.NET (309) - q5a : niv
assign q5a = q5ai;

// MEM.NET (318) - mtb0 : iv
assign mtb0 = ~d0;

// MEM.NET (320) - mtb1 : nd2
`ifdef ORIGINAL_RAM
assign mtb1 = ~(q3a & lastcycle); // was d3b
`else
assign mtb1 = ~(d3b & lastcycle);
`endif

// MEM.NET (322) - mtb2 : iv
assign mtb2 = ~q4h;

// MEM.NET (323) - mtb3 : nd2
assign mtb3 = ~(d5c & lastcycle);

// MEM.NET (324) - mtb5 : nd3
assign mtb5 = ~(d7a_obuf & lastc & notreadt);

// MEM.NET (325) - mtb6 : nd2
assign mtb6 = ~(d8c & lastcycle);

// MEM.NET (326) - mtb8 : iv
assign mtb8 = ~d10;

// MEM.NET (327) - mtb9 : nd2
assign mtb9 = ~(d7b & lastcycle);

// MEM.NET (328) - notreadt : ivm
assign notreadt = ~readt_obuf;

// MEM.NET (330) - mtba : an6
assign mtba = mtb0 & mtb1 & mtb2 & mtb3 & mtb5;

// MEM.NET (331) - mtbb : an3
assign mtbb = mtb6 & mtb8 & mtb9;

// MEM.NET (332) - mtbd : nd2
assign mtbd = ~(mtba & mtbb);

// MEM.NET (333) - mtb : fd4q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			mtb <= 1'b1; // fd2q negedge // always @(posedge cp or negedge cd)
		end else begin
			mtb <= mtbd;
		end
	end
end

// MEM.NET (334) - ack : nivu2
assign ack_obuf = mtb;

// MEM.NET (336) - d0 : an2
assign d0 = ack_obuf & notmreq;

// MEM.NET (337) - d1a : an6
assign d1a = ack_obuf & mreqb & fdram & notmatch & notrefack & notourack;

// MEM.NET (339) - mt1b0 : nd2
assign mt1b0 = ~(q1a & dramspeed[0]);

// MEM.NET (340) - mt1b1 : nd2
assign mt1b1 = ~(q1a & dramspeed[1]);

// MEM.NET (341) - d1b : nd2
assign d1b = ~(mt1b0 & mt1b1);

// MEM.NET (343) - mt1c0 : nd2
assign mt1c0 = ~(q1a & dramspeed[2]);

// MEM.NET (344) - mt1c1 : iv
assign mt1c1 = ~q1b;

// MEM.NET (345) - d1c : nd2
assign d1c = ~(mt1c0 & mt1c1);

// MEM.NET (347) - mt1d0 : nd2
assign mt1d0 = ~(q1a & dramspeed[3]);

// MEM.NET (348) - mt1d1 : iv
assign mt1d1 = ~q1c;

// MEM.NET (349) - d1d : nd2
assign d1d = ~(mt1d0 & mt1d1);

// MEM.NET (351) - mt2b0 : nd2
assign mt2b0 = ~(q2a & dramspeed[0]);

// MEM.NET (352) - mt2b1 : nd2
assign mt2b1 = ~(q2a & dramspeed[1]);

// MEM.NET (353) - d2b : nd2
assign d2b = ~(mt2b0 & mt2b1);

// MEM.NET (355) - mt2c0 : nd2
assign mt2c0 = ~(q2a & dramspeed[2]);

// MEM.NET (356) - mt2c1 : iv
assign mt2c1 = ~q2b;

// MEM.NET (357) - d2c : nd2
assign d2c = ~(mt2c0 & mt2c1);

// MEM.NET (359) - mt3a0 : nd6
assign mt3a0 = ~(ack_obuf & mreqb & fdram & match & notrefack & notourack);

// MEM.NET (360) - mt3a1 : nd2
assign mt3a1 = ~(q2a & dramspeed[3]);

// MEM.NET (361) - mt3a2 : iv
assign mt3a2 = ~q2c;

// MEM.NET (362) - mt3a3 : nd2
assign mt3a3 = ~(q3b & notlastcycle);

// MEM.NET (364) - rambsy : iv
assign ram_bsy = ~ram_rdy;

// MEM.NET (365) - mt3a4 : nd2
assign mt3a4 = ~(q3a & ram_bsy);

// MEM.NET (366) - d3a : nd5
assign d3a = ~(mt3a0 & mt3a1 & mt3a2 & mt3a3 & mt3a4);

// MEM.NET (369) - d3b : an2
assign d3b = q3a & ram_rdy;

// MEM.NET (371) - d4a : an3
assign d4a = ack_obuf & mreqb & refack_obuf;

// MEM.NET (373) - mt4b0 : nd2
assign mt4b0 = ~(q4a & dramspeed[0]);

// MEM.NET (374) - mt4b1 : nd2
assign mt4b1 = ~(q4a & dramspeed[1]);

// MEM.NET (375) - d4b : nd2
assign d4b = ~(mt4b0 & mt4b1);

// MEM.NET (377) - mt4c0 : nd2
assign mt4c0 = ~(q4a & dramspeed[2]);

// MEM.NET (378) - mt4c1 : iv
assign mt4c1 = ~q4b;

// MEM.NET (379) - d4c : nd2
assign d4c = ~(mt4c0 & mt4c1);

// MEM.NET (381) - mt4d0 : nd2
assign mt4d0 = ~(q4a & dramspeed[3]);

// MEM.NET (382) - mt4d1 : iv
assign mt4d1 = ~q4c;

// MEM.NET (383) - d4d : nd2
assign d4d = ~(mt4d0 & mt4d1);

// MEM.NET (385) - d4f : an2
assign d4f = q4e & dramspeed[0];

// MEM.NET (387) - mt4g0 : nd2
assign mt4g0 = ~(q4e & dramspeed[1]);

// MEM.NET (388) - mt4g1 : nd2
assign mt4g1 = ~(q4e & dramspeed[2]);

// MEM.NET (389) - mt4g2 : iv
assign mt4g2 = ~q4f;

// MEM.NET (390) - d4g : nd3
assign d4g = ~(mt4g0 & mt4g1 & mt4g2);

// MEM.NET (392) - mt4h0 : nd2
assign mt4h0 = ~(q4e & dramspeed[3]);

// MEM.NET (393) - mt4h1 : iv
assign mt4h1 = ~q4g;

// MEM.NET (394) - d4h : nd2
assign d4h = ~(mt4h0 & mt4h1);

// MEM.NET (396) - mt5a0 : nd6
assign mt5a0 = ~(ack_obuf & mreqb & from & notrefack & notourack);

// MEM.NET (397) - mt5a1 : nd2
assign mt5a1 = ~(q5c & notlastcycle);

// MEM.NET (398) - d5a : nd2
assign d5a = ~(mt5a0 & mt5a1);

// MEM.NET (400) - mt5b0 : nd2
assign mt5b0 = ~(q5a & slowrom);

// MEM.NET (401) - mt5b1 : nd2
assign mt5b1 = ~(q5b & notwaitdone);

// MEM.NET (402) - d5b : nd2
assign d5b = ~(mt5b0 & mt5b1);

// MEM.NET (404) - slowrom : iv
assign slowrom = ~(fastrom || turbo); // turbo NOT_NETLIST

// MEM.NET (405) - mt5c0 : nd2
assign mt5c0 = ~(q5a & (fastrom || turbo)); // turbo NOT_NETLIST

// MEM.NET (406) - mt5c1 : nd2
assign mt5c1 = ~(q5b & waitdone);

// MEM.NET (407) - d5c : nd2
assign d5c = ~(mt5c0 & mt5c1);

// MEM.NET (409) - mt7a0 : nd6
assign mt7a0 = ~(ack_obuf & mreqb & fintdev & notrefack & notourack);

// MEM.NET (410) - mt7a1 : nd3
assign mt7a1 = ~(q7a & notreads & notlastcycle);

// MEM.NET (411) - mt7a2 : nd2
assign mt7a2 = ~(q7b & notlastcycle);

// MEM.NET (412) - d7a : nd3
assign d7a_obuf = ~(mt7a0 & mt7a1 & mt7a2);

// MEM.NET (414) - d7b : an2
assign d7b = q7a & reads_obuf;

// MEM.NET (416) - mt8a0 : nd6
assign mt8a0 = ~(ack_obuf & mreqb & fextdev & notrefack & notourack);

// MEM.NET (417) - mt8a1 : nd2
assign mt8a1 = ~(q8c & notlastcycle);

// MEM.NET (418) - d8a : nd2
assign d8a = ~(mt8a0 & mt8a1);

// MEM.NET (420) - mt8b0 : iv
assign mt8b0 = ~q8a;

// MEM.NET (421) - mt8b1 : nd2
assign mt8b1 = ~(q8b & notwaitdone);

// MEM.NET (422) - d8b : nd2
assign d8b = ~(mt8b0 & mt8b1);

// MEM.NET (424) - d8c : an2
assign d8c = q8b & waitdone;

// MEM.NET (426) - d10 : an4
assign d10 = ack_obuf & mreqb & ourack & notrefack;

// MEM.NET (428) - wait1 : an2
assign wait1 = iospeed[2] & q8a;

// MEM.NET (430) - wait2 : an3
assign wait2 = romspeed[3] & q5a & slowrom;

// MEM.NET (432) - wait30 : nd3
assign wait30 = ~(romspeed[2] & q5a & slowrom);

// MEM.NET (433) - wait31 : nd2
assign wait31 = ~(iospeed[3] & q8a);

// MEM.NET (434) - wait3 : nd2
assign wait3 = ~(wait30 & wait31);

// MEM.NET (436) - wait5 : an3
assign wait5 = romspeed[1] & q5a & slowrom;

// MEM.NET (438) - wait70 : nd3
assign wait70 = ~(romspeed[0] & q5a & slowrom);

// MEM.NET (439) - wait71 : nd2
assign wait71 = ~(iospeed[1] & q8a);

// MEM.NET (440) - wait7 : nd2
assign wait7 = ~(wait70 & wait71);

// MEM.NET (442) - wait15 : an2
assign wait15 = iospeed[0] & q8a;

// MEM.NET (446) - rasoffl[1-2] : nd2
assign rasoffl[2:1] = ~({d1a,d1a} & abs[3:2]);

// MEM.NET (448) - rason : niv
assign rason = q1d;

// MEM.NET (450) - muxi : nr2
assign muxi = ~(d1d | q1d);

// MEM.NET (451) - mux : ivm
assign mux = ~muxi;

// MEM.NET (462) - oet0 : nd2
assign oet0 = ~(q3a & reads_obuf);

// MEM.NET (463) - oet1 : nd2
assign oet1 = ~(q3b & reads_obuf);

// MEM.NET (464) - oet2 : nd2
assign oet2 = ~(q5a & reads_obuf);

// MEM.NET (465) - oet3 : nd2
assign oet3 = ~(q5b & reads_obuf);

// MEM.NET (466) - oet4 : nd2
assign oet4 = ~(q5c & reads_obuf);

// MEM.NET (467) - oet5 : nd2
assign oet5 = ~(q7a & reads_obuf);

// MEM.NET (468) - oet6 : nd2
assign oet6 = ~(q7b & reads_obuf);

// MEM.NET (469) - oet7 : nd2
assign oet7 = ~(q8b & reads_obuf);

// MEM.NET (470) - oeti : nd8
assign oeti = ~(oet0 & oet1 & oet2 & oet3 & oet4 & oet5 & oet6 & oet7);

// MEM.NET (471) - oet : nivu2
assign oet_obuf = oeti;

// MEM.NET (473) - startcas : an2
wire startcas = q3a & dram;
//assign startcas_out = d3a & dram;	// Saving one clock cycle for SDRAM reads, using d3a. ElectronAsh.
assign startcas_out = q3a & dram;

// MEM.NET (475) - dinl0 : nd2
assign dinl0 = ~(q3b & reads_obuf);

// MEM.NET (476) - dinl1 : nd2
assign dinl1 = ~(q5c & reads_obuf);

// MEM.NET (477) - dinl3 : nd2
assign dinl3 = ~(q7b & reads_obuf);

// MEM.NET (478) - dinl4 : nd2
assign dinl4 = ~(d8c & reads_obuf);

// MEM.NET (479) - dinlatchd : nd4
assign dinlatchd = ~(dinl0 & dinl1 & dinl3 & dinl4);

// MEM.NET (481) - dinlatch : nivh
assign dinlatch_ = dinlatchd;

// MEM.NET (483) - iwnext : an2
assign iwnext = q7a & notreads;

// MEM.NET (484) - nextci : nr6
assign nextci = ~(q3b | q5c | iwnext | q7b | q8c | ack_obuf);

// MEM.NET (485) - nextc : ivh
assign nextc = ~nextci;

// MEM.NET (487) - sw0 : nr4
assign sw0 = ~(d3a | d5a | d5b | d8b);

// MEM.NET (488) - swd : nr2
assign swd = ~(sw0 | readt_obuf);

// MEM.NET (489) - startwe : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		startwe <= swd;
	end
end
assign startwe_out = startwe;
assign startwep = swd;

// MEM.NET (493) - notrw : iv
assign notrw = ~rw_in;

// MEM.NET (494) - dol : nd3
assign doll = ~(ack_obuf & notrw & mreqb);

// MEM.NET (499) - lwdli1 : fd1q
// MEM.NET (500) - lwdli2 : fd1q
reg old_tlw = 1'b0;
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		lwdli1 <= doll;
	end
	if (~old_tlw && tlw) begin
		lwdli2 <= doll;
	end
end

// MEM.NET (501) - lwdl : an2
assign lwdl = lwdli1 & lwdli2;

// MEM.NET (503) - allrasoffl : nr2
assign allrasoffl = ~(d4a | q4i);

// MEM.NET (504) - allrasonl : iv
assign allrasonl = ~q4d;

// MEM.NET (505) - allcasonl : nr2
assign allcasonl = ~(q4d | q4e);

// MEM.NET (506) - resrow : niv
assign resrow = q4a;

// MEM.NET (512) - w[0] : dncnt
// MEM.NET (513) - w[1] : dncnt
// MEM.NET (514) - w[2] : dncnt
// MEM.NET (515) - w[3] : dncnt
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			wq[3:0] <= 4'h0;
		end else if (wld) begin
			wq[3:0] <= {wait15,wd[2:0]};
		end else if (wcen) begin
			wq[3:0] <= wq[3:0] - 4'h1;
		end
	end
end

// MEM.NET (517) - wcen : or4
assign wcen = |wq[3:0];

// MEM.NET (519) - wld : or6
assign wld = wait1 | wait2 | wait3 | wait5 | wait7 | wait15;

// MEM.NET (521) - wait : iv
assign _wait = ~waitl;

// MEM.NET (522) - waitdonei : nr6
assign waitdonei = ~(|wq[3:0] | _wait);

// MEM.NET (523) - notwaitdone : iv
assign notwaitdone = ~waitdonei;

// MEM.NET (524) - waitdone : iv
assign waitdone = ~notwaitdone;

// MEM.NET (526) - wd[0] : or6
assign wd[0] = wait1 | wait3 | wait5 | wait7 | wait15;

// MEM.NET (527) - wd[1] : or4
assign wd[1] = wait2 | wait3 | wait7 | wait15;

// MEM.NET (528) - wd[2] : or3
assign wd[2] = wait5 | wait7 | wait15;

// MEM.NET (534) - dramspeed0 : an2
// MEM.NET (535) - dramspeed1 : an2
// MEM.NET (536) - dramspeed2 : an2
// MEM.NET (537) - dramspeed3 : an2
assign dramspeed[3:0] = 4'h1 << dspd[1:0];

// MEM.NET (539) - iospeed0 : an2
// MEM.NET (540) - iospeed1 : an2
// MEM.NET (541) - iospeed2 : an2
// MEM.NET (542) - iospeed3 : an2
assign iospeed[3:0] = 4'h1 << iospd[1:0];

// MEM.NET (544) - romspeed0 : an2
// MEM.NET (545) - romspeed1 : an2
// MEM.NET (546) - romspeed2 : an2
// MEM.NET (547) - romspeed3 : an2
assign romspeed[3:0] = 4'h1 << romspd[1:0];

// MEM.NET (552) - rasl[0] : rasgen
_rasgen rasl_index_0_inst
(
	.csl /* OUT */ (rasl[0]),
	.on1 /* IN */ (rason),
	.roffl /* IN */ (rasoffl[2]),
	.bs /* IN */ (bs[3]),
	.allonl /* IN */ (allrasonl),
	.alloffl /* IN */ (allrasoffl),
	.clk /* IN */ (clk),
	.resl /* IN */ (resetl),
	.sys_clk(sys_clk) // Generated
);

// MEM.NET (554) - rasl[1] : rasgen
_rasgen rasl_index_1_inst
(
	.csl /* OUT */ (rasl[1]),
	.on1 /* IN */ (rason),
	.roffl /* IN */ (rasoffl[1]),
	.bs /* IN */ (bs[2]),
	.allonl /* IN */ (allrasonl),
	.alloffl /* IN */ (allrasoffl),
	.clk /* IN */ (clk),
	.resl /* IN */ (resetl),
	.sys_clk(sys_clk) // Generated
);

// MEM.NET (560) - clkl : niv
assign clkl = tlw;

// MEM.NET (561) - pclkl : nivh
assign pclkl = tlw;

// MEM.NET (564) - casd[0] : nd2
assign casd[0] = ~(startcas & bs[3]);

// MEM.NET (565) - casd[1] : nd2
assign casd[1] = ~(startcas & bs[2]);

// MEM.NET (566) - cas00 : fd4q
// MEM.NET (567) - cas01 : fd4q
// MEM.NET (568) - cas10 : fd4q
// MEM.NET (569) - cas11 : fd4q
reg old_pclkl = 1'b0;
always @(posedge sys_clk)
begin
	if ((~old_pclkl && pclkl) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			cas00 <= 1'b1; // fd2q negedge // always @(posedge cp or negedge cd)
			cas10 <= 1'b1; // fd2q negedge // always @(posedge cp or negedge cd)
		end else begin
			cas00 <= casd[0];
			cas10 <= casd[1];
		end
	end
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			cas01 <= 1'b1; // fd2q negedge // always @(posedge cp or negedge cd)
			cas11 <= 1'b1; // fd2q negedge // always @(posedge cp or negedge cd)
		end else begin
			cas01 <= casd[0];
			cas11 <= casd[1];
		end
	end
end


// MEM.NET (570) - casl[0] : an3
assign casl[0] = cas00 & cas01 & allcasonl;

// MEM.NET (571) - casl[1] : an3
assign casl[1] = cas10 & cas11 & allcasonl;

// MEM.NET (573) - romcst : or3
assign romcst = q5a | q5b | q5c;

// MEM.NET (574) - romcsl[0-1] : nd2
assign romcsl[1:0] = ~(bs[1:0] & {romcst,romcst});

// MEM.NET (576) - dspcsli : nr3
assign dspcsli = ~(q8a | q8b | q8c);

// MEM.NET (577) - dspcsl : niv
assign dspcsl = dspcsli;

// MEM.NET (581) - int_we : nd2
assign int_wel = ~(q7a & notreads);

// MEM.NET (583) - intwe : ivm
assign intwe = ~int_wel;

// MEM.NET (584) - intswe : an2
assign intswe = q7a & notreads;

// MEM.NET (586) - ba[0-2] : eo
assign ba_[2:0] = maska_obuf[2:0] ^ {bigend,bigend,bigend};

// MEM.NET (599) - mwsl[0-1] : iv
assign mwsl[1:0] = ~mws[1:0];

// MEM.NET (601) - wet0 : fd2
always @(posedge sys_clk)
begin
	if ((~old_tlw && tlw) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			wet0 <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
		end else begin
			wet0 <= startwe;
		end
	end
end
assign wet0l = ~wet0;

// MEM.NET (605) - weti : nd2
assign weti = ~(wet0l & int_wel);

// MEM.NET (606) - wet : nivu
assign wet_obuf = weti;

// MEM.NET (609) - mws8 : an2
assign mws8 = mwsl[1] & mwsl[0];

// MEM.NET (610) - mws16 : an2m
assign mws16 = mwsl[1] & mws[0];

// MEM.NET (611) - mws32 : an2m
assign mws32 = mws[1] & mwsl[0];

// MEM.NET (612) - mws64 : an2m
assign mws64 = mws[1] & mws[0];

// MEM.NET (614) - we00 : iv
assign we00 = ~mws8;

// MEM.NET (615) - we01 : iv
assign we01 = ~bm[0];

// MEM.NET (616) - we02 : nd2
assign we02 = ~(mws16 & bm[2]);

// MEM.NET (617) - we03 : nd2
assign we03 = ~(mws16 & bm[4]);

// MEM.NET (618) - we04 : nd2
assign we04 = ~(mws16 & bm[6]);

// MEM.NET (619) - we05 : nd2
assign we05 = ~(mws32 & bm[4]);

// MEM.NET (620) - we[0] : nd6
assign we[0] = ~(we00 & we01 & we02 & we03 & we04 & we05);

// MEM.NET (631) - we10 : nd2
assign we10 = ~(mws16 & bm[1]);

// MEM.NET (632) - we11 : nd2
assign we11 = ~(mws16 & bm[3]);

// MEM.NET (633) - we12 : nd2
assign we12 = ~(mws16 & bm[5]);

// MEM.NET (634) - we13 : nd2
assign we13 = ~(mws16 & bm[7]);

// MEM.NET (635) - we14 : nd2
assign we14 = ~(mws32 & bm[1]);

// MEM.NET (636) - we15 : nd2
assign we15 = ~(mws32 & bm[5]);

// MEM.NET (637) - we16 : nd2
assign we16 = ~(mws64 & bm[1]);

// MEM.NET (638) - we[1] : nd8
assign we[1] = ~(we10 & we11 & we12 & we13 & we14 & we15 & we16);

// MEM.NET (648) - we20 : nd2
assign we20 = ~(mws32 & bm[2]);

// MEM.NET (649) - we21 : nd2
assign we21 = ~(mws32 & bm[6]);

// MEM.NET (650) - we22 : nd2
assign we22 = ~(mws64 & bm[2]);

// MEM.NET (651) - we[2] : nd3
assign we[2] = ~(we20 & we21 & we22);

// MEM.NET (661) - we30 : nd2
assign we30 = ~(mws32 & bm[3]);

// MEM.NET (662) - we31 : nd2
assign we31 = ~(mws32 & bm[7]);

// MEM.NET (663) - we32 : nd2
assign we32 = ~(mws64 & bm[3]);

// MEM.NET (664) - we[3] : nd3
assign we[3] = ~(we30 & we31 & we32);

// MEM.NET (666) - wel[0-3] : nd2
assign wel[3:0] = wet_obuf ? ~(we[3:0]) : 4'b1111;
assign we_[3:0] = (we[3:0]);

// MEM.NET (667) - wel[4-7] : nd3
assign wel[7:4] = (wet_obuf & mws64) ? ~(bm[7:4]) : 4'b1111;
assign we_[7:4] = (mws64) ? (bm[7:4]) : 4'b0000;

// MEM.NET (691) - oe00 : nd2
assign oe00 = ~(oet_obuf & mws8);

// MEM.NET (692) - oe01 : nd2
assign oe01 = ~(oet_obuf & mws16);

// MEM.NET (693) - oe02 : nd2
assign oe02 = ~(oet_obuf & bm[0]);

// MEM.NET (694) - oe03 : nd2
assign oe03 = ~(oet_obuf & bm[1]);

// MEM.NET (695) - oe04 : nd3
assign oe04 = ~(oet_obuf & mws32 & bm[4]);

// MEM.NET (696) - oe05 : nd3
assign oe05 = ~(oet_obuf & mws32 & bm[5]);

// MEM.NET (697) - oel[0] : an6
assign oel[0] = oe00 & oe01 & oe02 & oe03 & oe04 & oe05;

// MEM.NET (699) - oe10 : nd3
assign oe10 = ~(oet_obuf & mws32 & bm[2]);

// MEM.NET (700) - oe11 : nd3
assign oe11 = ~(oet_obuf & mws32 & bm[3]);

// MEM.NET (701) - oe12 : nd3
assign oe12 = ~(oet_obuf & mws32 & bm[6]);

// MEM.NET (702) - oe13 : nd3
assign oe13 = ~(oet_obuf & mws32 & bm[7]);

// MEM.NET (703) - oe14 : nd3
assign oe14 = ~(oet_obuf & mws64 & bm[2]);

// MEM.NET (704) - oe15 : nd3
assign oe15 = ~(oet_obuf & mws64 & bm[3]);

// MEM.NET (705) - oel[1] : an6
assign oel[1] = oe10 & oe11 & oe12 & oe13 & oe14 & oe15;

// MEM.NET (707) - oe20 : nd3
assign oe20 = ~(oet_obuf & mws64 & bm[4]);

// MEM.NET (708) - oe21 : nd3
assign oe21 = ~(oet_obuf & mws64 & bm[5]);

// MEM.NET (709) - oe22 : nd3
assign oe22 = ~(oet_obuf & mws64 & bm[6]);

// MEM.NET (710) - oe23 : nd3
assign oe23 = ~(oet_obuf & mws64 & bm[7]);

// MEM.NET (711) - oel[2] : an4
assign oel[2] = oe20 & oe21 & oe22 & oe23;

// MEM.NET (715) - dinlatchl[0-7] : nd2p
assign dinlatchl[7:0] = dinlatch_ ? ~(bm[7:0]) : 8'hff;

// MEM.NET (716) - dinlatch[0-7] : nd2p
assign dinlatch[7:0] = lwdl ? ~(dinlatchl[7:0]) : 8'hff;

// MEM.NET (720) - sizout[0-2] : niv
assign sizout[2:0] = maskw[2:0];

// MEM.NET (723) - readsi : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		readsi <= readt_obuf;
	end
end

// MEM.NET (724) - readt : mx2p
assign readt_obuf = (ack_obuf) ? rw_in : readsi;

// MEM.NET (725) - reads : nivu
assign reads_obuf = readsi;

// MEM.NET (729) - mwti[0-1] : mx2p
assign mwti[1:0] = (ack_obuf) ? mw[1:0] : mws[1:0];

// MEM.NET (730) - mws[0-1] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		mws[1:0] <= mwti[1:0];
	end
end

// MEM.NET (731) - mwt[0-1] : nivh
assign mwt[1:0] = mwti[1:0];

// MEM.NET (733) - mreqb : nivh
assign mreqb = mreq_in;

// MEM.NET (734) - notmreq : iv
assign notmreq = ~mreqb;

// MEM.NET (735) - notmatch : iv
assign notmatch = ~match;

// MEM.NET (736) - notlastcycle : iv
assign notlastcycle = ~lastcycle;

// MEM.NET (737) - notreads : iv
assign notreads = ~readsi;

// MEM.NET (738) - notack : iv
assign notack = ~ack_obuf;

// MEM.NET (739) - notrefack : iv
assign notrefack = ~refack_obuf;

// MEM.NET (740) - notourack : iv
assign notourack = ~ourack;

// MEM.NET (743) - newrow : niv
assign newrow = q1a;

// MEM.NET (747) - dreqd : nd2
assign dreqd = ~(mreqb & ack_obuf);

// MEM.NET (748) - jdreqlout : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		dreqlout_ <= dreqd;
	end
end
endmodule

