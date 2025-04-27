//`include "defs.v"
// altera message_off 10036

module _j_jerry
(
	input xdspcsl,
	input xpclkosc,
	input xpclkin,
	input xdbgl,
	input xoel_0,
	input xwel_0,
	input xserin,
	input xdtackl,
	input xi2srxd,
	input [1:0] xeint,
	input xtest,
	input xchrin,
	input xresetil,
	output [31:0] xd_out,
	output [31:0] xd_oe,
	input [31:0] xd_in,
	output [23:0] xa_out,
	output [23:0] xa_oe,
	input [23:0] xa_in,
	output [3:0] xjoy_out,
	output [3:0] xjoy_oe,
	input [3:0] xjoy_in,
	output [5:0] xgpiol_out,
	output [3:0] xgpiol_oe,
	input [3:0] xgpiol_in,
	output xsck_out,
	output xsck_oe,
	input xsck_in,
	output xws_out,
	output xws_oe,
	input xws_in,
	output xvclk_out,
	output xvclk_oe,
	input xvclk_in,
	output [1:0] xsiz_out,
	output [1:0] xsiz_oe,
	input [1:0] xsiz_in,
	output xrw_out,
	output xrw_oe,
	input xrw_in,
	output xdreql_out,
	output xdreql_oe,
	input xdreql_in,
	output [1:0] xdbrl,
	output xint,
	output xserout,
	output xvclkdiv,
	output xchrdiv,
	output xpclkout,
	output xpclkdiv,
	output xresetl,
	output xchrout,
	output [1:0] xrdac,
	output [1:0] xldac,
	output xiordl,
	output xiowrl,
	output xi2stxd,
	output xcpuclk,
	input tlw,
	input tlw_0,
	input tlw_1,
	input tlw_2,
	output aen,
	output den,
	output ainen,
	output [15:0] snd_l,
	output [15:0] snd_r,
	output snd_l_en,
	output snd_r_en,
	output snd_clk,
	
	output [15:0] dspwd,
	
	input sys_clk // Generated
);

wire [15:0] dsprd_out;
wire dsprd_oe;
wire [15:0] dr_out;
wire [15:0] dr_oe;
wire [31:0] din;
wire [79:0] nt;
wire [31:0] dout;
wire [23:0] ain;
wire [23:0] aout;
wire oel_0;
wire wel_0;
wire pclkosc;
wire pclkin;
wire pclkout;
wire cpuclk;
wire vclkin;
wire chrclk;
wire vclken;
wire pclkdiv;
wire vclkdiv;
wire chrdiv;
wire resetli;
wire resetl;
wire [1:0] siz;
wire rws;
wire dreql;
wire dtackl;
wire [1:0] dbrls;
wire dbgl;
wire dspcsl;
wire intt;
wire _int;
wire ndtest;
wire test;
wire serin;
wire serout;
wire sck;
wire sckout;
wire i2sen;
wire ws;
wire wsout;
wire i2srxd;
wire i2stxd;
wire [1:0] eint;
wire [7:0] cfg;
wire joy1rl;
wire cfgen;
wire joy2rl;
wire joy1wl;
wire joyenl;
wire [5:0] gpiol;
wire iordl;
wire iowrl;
wire [1:0] rdac;
wire [1:0] ldac;
wire nottest;
wire testen;
wire ack;
wire clk;
wire [1:0] tint;
wire i2int;
wire dspread;
wire dspwrite;
wire [1:0] dbrl;
wire dint;
wire [31:0] wd;
wire [23:0] a;
wire [2:0] w;
wire rw;
wire mreq;
wire dac1w;
wire dac2w;
wire i2s1w;
wire i2s2w;
wire i2s3w;
wire i2s4w;
wire i2s1r;
wire i2s2r;
wire i2s3r;
wire dspen;
wire pit1w;
wire pit2w;
wire pit3w;
wire pit4w;
wire clk1w;
wire clk2w;
wire clk3w;
wire int1w;
wire u2dwr;
wire u2ctwr;
wire u2psclw;
wire test1w;
wire int1r;
wire u2drd;
wire u2strd;
wire u2psclr;
wire pit1r;
wire pit2r;
wire pit3r;
wire pit4r;
wire internal;
wire [1:0] dinlatch;
wire [1:0] dmuxd;
wire [1:0] dmuxu;
wire dren;
wire xdsrc;
wire cfgw;
wire seta1;
wire masterdata;
wire dsp16;
wire bigend;
wire tlw_unused;
wire uint;
wire ts;

wire [15:0] dsprd_dsp_out; //167a0
wire dsprd_dsp_oe;
wire [15:0] dsprd_i2s_out; //167a1
wire dsprd_i2s_oe;

wire [15:0] dr_dsp_out; //183a0
wire dr_dsp_oe;
wire [15:0] dr_jio_out; //183a1
wire dr_jio_oe;
wire [15:0] dr_misc_out; //183a2
wire dr_misc_oe;
wire [15:0] dr_u2_out; //183a3
wire dr_u2_oe;

// Output buffers
wire aen_obuf;
wire den_obuf;
wire ainen_obuf;


// Output buffers
assign aen = aen_obuf;
assign den = den_obuf;
assign ainen = ainen_obuf;

assign snd_clk = clk;

// JERRY.NET (115) - d[0] : bd8t
//assign io_out = a;
//assign io_oe = ~en & tn;
//assign zi = io_in;
//assign po = ~(io_in & pi);
assign xd_out[15:0] = dout[15:0];
assign xd_oe[15:0] = {16{den_obuf}};
assign din[15:0] = xd_in[15:0];
// nt = nand tree appears to be for factory testing only
// Should probably remove. Likely to cause timing problems.
// If kept, chain can likely be safely broken up in steps to help timing. 
// Since test is grounded nt[9] is always 1 and nt[8:1] don't matter.
assign nt[55] = ~(xd_in[0] & nt[54]); //
assign nt[54] = ~(xd_in[1] & nt[53]); //
assign nt[53] = ~(xd_in[2] & nt[52]); //
assign nt[52] = ~(xd_in[3] & nt[51]); //
assign nt[51] = ~(xd_in[4] & nt[50]); //
assign nt[50] = ~(xd_in[5] & nt[49]); //
assign nt[49] = ~(xd_in[6] & nt[48]); //
assign nt[48] = ~(xd_in[7] & nt[47]); //
assign nt[47] = ~(xd_in[8] & nt[46]); //
assign nt[46] = ~(xd_in[9] & nt[45]); //
assign nt[45] = ~(xd_in[10] & nt[44]); //
assign nt[44] = ~(xd_in[11] & nt[43]); //
assign nt[43] = ~(xd_in[12] & nt[42]); //
assign nt[42] = ~(xd_in[13] & nt[41]); //
assign nt[41] = ~(xd_in[14] & nt[40]); //
assign nt[40] = ~(xd_in[15] & nt[39]); //

// JERRY.NET (133) - d[16] : bd8t
assign xd_out[31:16] = dout[31:16];
assign xd_oe[31:16] = {16{den_obuf}};
assign din[31:16] = xd_in[31:16];
assign nt[39] = ~(xd_in[16] & nt[38]); //
assign nt[38] = ~(xd_in[17] & nt[37]); //
assign nt[37] = ~(xd_in[18] & nt[36]); //
assign nt[36] = ~(xd_in[19] & nt[35]); //
assign nt[35] = ~(xd_in[20] & nt[34]); //
assign nt[34] = ~(xd_in[21] & nt[33]); //
assign nt[33] = ~(xd_in[22] & nt[32]); //
assign nt[32] = ~(xd_in[23] & nt[31]); //
assign nt[31] = ~(xd_in[24] & nt[30]); //
assign nt[30] = ~(xd_in[25] & nt[29]); //
assign nt[29] = ~(xd_in[26] & nt[28]); //
assign nt[28] = ~(xd_in[27] & nt[27]); //
assign nt[27] = ~(xd_in[28] & nt[26]); //
assign nt[26] = ~(xd_in[29] & nt[25]); //
assign nt[25] = ~(xd_in[30] & nt[24]); //
assign nt[24] = ~(xd_in[31] & nt[23]); //

// JERRY.NET (150) - a[0] : bd8t
assign xa_out[23:0] = aout[23:0];
assign xa_oe[23:0] = {24{aen_obuf}};
assign ain[23:0] = xa_in[23:0];
assign nt[79] = ~(xa_in[0] & nt[78]); //
assign nt[78] = ~(xa_in[1] & nt[77]); //
assign nt[77] = ~(xa_in[2] & nt[76]); //
assign nt[76] = ~(xa_in[3] & nt[75]); //
assign nt[75] = ~(xa_in[4] & nt[74]); //
assign nt[74] = ~(xa_in[5] & nt[73]); //
assign nt[73] = ~(xa_in[6] & nt[72]); //
assign nt[72] = ~(xa_in[7] & nt[71]); //
assign nt[71] = ~(xa_in[8] & nt[70]); //
assign nt[70] = ~(xa_in[9] & nt[69]); //
assign nt[69] = ~(xa_in[10] & nt[68]); //
assign nt[68] = ~(xa_in[11] & nt[67]); //
assign nt[67] = ~(xa_in[12] & nt[66]); //
assign nt[66] = ~(xa_in[13] & nt[65]); //
assign nt[65] = ~(xa_in[14] & nt[64]); //
assign nt[64] = ~(xa_in[15] & nt[63]); //
assign nt[63] = ~(xa_in[16] & nt[62]); //
assign nt[62] = ~(xa_in[17] & nt[61]); //
assign nt[61] = ~(xa_in[18] & nt[60]); //
assign nt[60] = ~(xa_in[19] & nt[59]); //
assign nt[59] = ~(xa_in[20] & nt[58]); //
assign nt[58] = ~(xa_in[21] & nt[57]); //
assign nt[57] = ~(xa_in[22] & nt[56]); //
assign nt[56] = ~(xa_in[23] & nt[55]); //

// JERRY.NET (175) - oe[0] : ibuf
assign oel_0 = xoel_0;
assign nt[5] = ~(xoel_0 & nt[4]); //

// JERRY.NET (176) - we[0] : ibuf
assign wel_0 = xwel_0;
assign nt[6] = ~(xwel_0 & nt[5]); //

// JERRY.NET (178) - pclkosc : ibuf
assign pclkosc = xpclkosc;
assign nt[1] = ~(xpclkosc & nt[0]); //

// JERRY.NET (179) - pclkin : ibuf
assign pclkin = xpclkin;
assign nt[2] = ~(xpclkin & nt[1]); //

// JERRY.NET (180) - pclkout : b8h
assign xpclkout = pclkout;

// JERRY.NET (181) - cpuclk : b8h
assign xcpuclk = cpuclk;

// JERRY.NET (182) - vclk : bd8t
assign xvclk_out = chrclk;
assign xvclk_oe = vclken;
assign vclkin = xvclk_in;
assign nt[0] = ~(xvclk_in); //

// JERRY.NET (183) - pclkdiv : b8
assign xpclkdiv = pclkdiv;

// JERRY.NET (184) - vclkdiv : b8
assign xvclkdiv = vclkdiv;

// JERRY.NET (185) - chrdiv : b8
assign xchrdiv = chrdiv;

// JERRY.NET (187) - reseti : ibuf
assign resetli = xresetil;
assign nt[8] = ~(xresetil & nt[7]); //

// JERRY.NET (188) - resetl : b8
assign xresetl = resetl;

// JERRY.NET (190) - siz[0-1] : bt8
assign xsiz_out[1:0] = siz[1:0];
assign xsiz_oe[1:0] = {2{aen_obuf}};

// JERRY.NET (192) - rw : bt8
assign xrw_out = rws;
assign xrw_oe = aen_obuf;

// JERRY.NET (193) - dreq : bt8
assign xdreql_out = dreql;
assign xdreql_oe = aen_obuf;

// JERRY.NET (195) - dtack : ibuf
assign dtackl = xdtackl;
assign nt[4] = ~(xdtackl & nt[3]); //

// JERRY.NET (197) - dbrl[0-1] : b8
assign xdbrl[1:0] = dbrls[1:0];

// JERRY.NET (198) - dbgl : ibuf
assign dbgl = xdbgl;
assign nt[7] = ~(xdbgl & nt[6]); //

// JERRY.NET (199) - dspcsl : ibuf
assign dspcsl = xdspcsl;
assign nt[3] = ~(xdspcsl & nt[2]); //

// JERRY.NET (203) - intlt : mx2p
assign intt = (ndtest) ? nt[79] : _int; //--

// JERRY.NET (204) - xint : b8
assign xint = intt;

// JERRY.NET (206) - test : ibuf
assign test = xtest;
assign nt[9] = ~(xtest & nt[8]); //

// JERRY.NET (208) - serin : ibuf
assign serin = xserin;
assign nt[20] = ~(xserin & nt[19]); //

// JERRY.NET (209) - serout : b8
assign xserout = serout;

// JERRY.NET (211) - sck : bd8t
assign xsck_out = sckout;
assign xsck_oe = i2sen;
assign sck = xsck_in;
assign nt[21] = ~(xsck_in & nt[20]); //

// JERRY.NET (212) - ws : bd8t
assign xws_out = wsout;
assign xws_oe = i2sen;
assign ws = xws_in;
assign nt[22] = ~(xws_in & nt[21]); //

// JERRY.NET (213) - i2srxd : ibuf
assign i2srxd = xi2srxd;
assign nt[23] = ~(xi2srxd & nt[22]); //

// JERRY.NET (214) - i2stxd : b8
assign xi2stxd = i2stxd;

// JERRY.NET (216) - eint[0-1] : ibuf
assign eint[1:0] = xeint[1:0];
assign nt[10] = ~(xeint[0] & nt[9]); //
assign nt[11] = ~(xeint[1] & nt[10]); //

// JERRY.NET (223) - joy[0] : bd8t
assign xjoy_out[3:0] = {joyenl,joy1wl,joy2rl,joy1rl};
assign xjoy_oe[3:0] = {4{cfgen}};
assign cfg[3:0] = xjoy_in[3:0];
assign nt[16] = ~(xjoy_in[0] & nt[15]); //
assign nt[17] = ~(xjoy_in[1] & nt[16]); //
assign nt[18] = ~(xjoy_in[2] & nt[17]); //
assign nt[19] = ~(xjoy_in[3] & nt[18]); //

// JERRY.NET (227) - gpiol[0-3] : bd8t
assign xgpiol_out[3:0] = gpiol[3:0];
assign xgpiol_oe[3:0] = {4{cfgen}};
assign cfg[7:4] = xgpiol_in[3:0];
assign nt[12] = ~(xgpiol_in[0] & nt[11]); //
assign nt[13] = ~(xgpiol_in[0] & nt[12]); //
assign nt[14] = ~(xgpiol_in[0] & nt[13]); //
assign nt[15] = ~(xgpiol_in[0] & nt[14]); //

// JERRY.NET (228) - gpiol[4-5] : b8
assign xgpiol_out[5:4] = gpiol[5:4];

// JERRY.NET (231) - iordl : b8
assign xiordl = iordl;

// JERRY.NET (232) - iowrl : b8
assign xiowrl = iowrl;

// JERRY.NET (234) - rdac[0-1] : b8
assign xrdac[1:0] = rdac[1:0];

// JERRY.NET (235) - ldac[0-1] : b8
assign xldac[1:0] = ldac[1:0];

// JERRY.NET (237) - chrclk : osc4c
assign xchrout = xchrin;
assign chrclk = xchrin;

// JERRY.NET (248) - nottest : iv
assign nottest = ~test;

// JERRY.NET (249) - testen : or2
assign testen = nottest | eint[0];

// JERRY.NET (252) - dsp : dsp
_j_dsp dsp_inst
(
	.ima /* IN */ (aout[15:0]),		// I/O address.
	.dout /* IN */ (dout[31:0]),		// slave write / master read data.
	.ack /* IN */ (ack),					// co-processor memory acknowledge.
	.gpu_back /* IN */ (dbgl),			// GPU normal bus acknowledge.
	.reset_n /* IN */ (resetl),		// system reset.
	.clk /* IN */ (clk),					// system clock.
	.eint_n /* IN */ (eint[1:0]),		// external interrupts.
	.tint /* IN */ (tint[1:0]),			// timer interrupts.
	.i2int /* IN */ (i2int),			// I2S interrupt.
	.iord /* IN */ (dspread),			// Look-ahead I/O read strobe for GPU.
	.iowr /* IN */ (dspwrite),			// Look-ahead I/O write strobe for GPU.
	.tlw /* IN */ (tlw),					// Transparent latch write enable timing.
	.tlw_a        (tlw_0),
	.tlw_b        (tlw_1),
	.tlw_c        (tlw_2),
	.gpu_breq /* OUT */ (dbrl[0]),	// GPU normal bus request.
	.dma_breq /* OUT */ (dbrl[1]),	// GPU high-priority bus request.
	.cpu_int /* OUT */ (dint),			// GPU interrupt to CPU.
	.wdata /* OUT */ (wd[31:0]),			// master write data bus.
	.a /* OUT */ (a[23:0]),				// master cycle address bus.
	.width /* OUT */ (w[2:0]),			// master cycle cycle width (in bytes).
	.read /* OUT */ (rw),				// master cycle read request.
	.mreq /* OUT */ (mreq),				// master cycle request.
	.dacw /* OUT */ ({dac2w,dac1w}),			// internal DAC write strobes.
	.gpu_din /* OUT */ (dspwd[15:0]),	// internal I/O write data.
	.i2sw_0 /* OUT */ (i2s1w),    // LTXD Left transmit data F1A148 WO.
	.i2sw_1 /* OUT */ (i2s2w),    // RTXD Right transmit data F1A14C WO.
	.i2sw_2 /* OUT */ (i2s3w),    // SCLK Serial Clock Frequency F1A150 WO.
	.i2sw_3 /* OUT */ (i2s4w),    // SMODE Serial Mode F1A154 WO.
	.i2sr_0 /* OUT */ (i2s1r),		// internal I2S read strobes.
	.i2sr_1 /* OUT */ (i2s2r),
	.i2sr_2 /* OUT */ (i2s3r),
	.dr_out /* BUS */ (dr_dsp_out[15:0]),	// I/O read data (busses split, and OE added, for Verilog translation).
	.dr_oe /* BUS */ (dr_dsp_oe),
	.gpu_dout_o_out /* BUS */ (dsprd_dsp_out[15:0]),	// read data from internal peripherals (GE - renamed).
	.gpu_dout_o_oe /* BUS */ (dsprd_dsp_oe),
	.gpu_dout_o_in /* BUS */ (dsprd_out[15:0]),
	.sys_clk(sys_clk) // Generated
);

// JERRY.NET (263) - jiodec : jiodec
_j_jiodec jiodec_inst
(
	.a /* IN */ (aout[15:0]),
	.dspcsl /* IN */ (dspcsl),
	.wel0 /* IN */ (wel_0),
	.oel0 /* IN */ (oel_0),
	.dspen /* IN */ (dspen),
	.pit1w /* OUT */ (pit1w),
	.pit2w /* OUT */ (pit2w),
	.pit3w /* OUT */ (pit3w),
	.pit4w /* OUT */ (pit4w),
	.clk1w /* OUT */ (clk1w),
	.clk2w /* OUT */ (clk2w),
	.clk3w /* OUT */ (clk3w),
	.int1w /* OUT */ (int1w),
	.u2dwr /* OUT */ (u2dwr),
	.u2ctwr /* OUT */ (u2ctwr),
	.u2psclw /* OUT */ (u2psclw),
	.test1w /* OUT */ (test1w),
	.joy1rl /* OUT */ (joy1rl),
	.joy2rl /* OUT */ (joy2rl),
	.joy1wl /* OUT */ (joy1wl),
	.gpiol /* OUT */ (gpiol[5:0]),
	.int1r /* OUT */ (int1r),
	.u2drd /* OUT */ (u2drd),
	.u2strd /* OUT */ (u2strd),
	.u2psclr /* OUT */ (u2psclr),
	.pit1r /* OUT */ (pit1r),
	.pit2r /* OUT */ (pit2r),
	.pit3r /* OUT */ (pit3r),
	.pit4r /* OUT */ (pit4r),
	.internal /* OUT */ (internal),
	.dr_out /* BUS */ (dr_jio_out[15:0]),
	.dr_oe /* BUS */ (dr_jio_oe)
);

// JERRY.NET (288) - jbus : jbus
_j_jbus jbus_inst
(
	.ain /* IN */ (ain[23:0]),
	.din /* IN */ (din[31:0]),
	.dr /* IN */ (dr_out[15:0]),
	.dinlatch /* IN */ (dinlatch[1:0]),
	.dmuxd /* IN */ (dmuxd[1:0]),
	.dmuxu /* IN */ (dmuxu[1:0]),
	.dren /* IN */ (dren),
	.xdsrc /* IN */ (xdsrc),
	.ack /* IN */ (ack),
	.wd /* IN */ (wd[31:0]),
	.clk /* IN */ (clk),
	.cfg /* IN */ (cfg[1:0]),
	.cfgw /* IN */ (cfgw),
	.a /* IN */ (a[23:0]),
	.ainen /* IN */ (ainen_obuf),
	.seta1 /* IN */ (seta1),
	.masterdata /* IN */ (masterdata),
	.dout /* OUT */ (dout[31:0]),
	.aout /* OUT */ (aout[23:0]),
	.dsp16 /* OUT */ (dsp16),
	.bigend /* OUT */ (bigend),
	.sys_clk(sys_clk) // Generated
);

// JERRY.NET (295) - jmem : jmem
_j_jmem jmem_inst
(
	.resetl /* IN */ (resetl),
	.clk /* IN */ (clk),
	.dbgl /* IN */ (dbgl),
	.bigend /* IN */ (bigend),
	.dsp16 /* IN */ (dsp16),
	.w /* IN */ (w[2:0]),
	.rw /* IN */ (rw),
	.mreq /* IN */ (mreq),
	.dtackl /* IN */ (dtackl),
	.dspcsl /* IN */ (dspcsl),
	.wel_0 /* IN */ (wel_0),
	.oel_0 /* IN */ (oel_0),
	.testen /* IN */ (testen),
	.at_15 /* IN */ (aout[15]),
	.internal /* IN */ (internal),
	.dbrl /* IN */ (dbrl[1:0]),
	.aout /* IN */ (aout[1:0]),
	.ndtest /* IN */ (ndtest),
	.ack /* OUT */ (ack),
	.den /* OUT */ (den_obuf),
	.aen /* OUT */ (aen_obuf),
	.siz /* OUT */ (siz[1:0]),
	.dreql /* OUT */ (dreql),
	.dmuxu /* OUT */ (dmuxu[1:0]),
	.dmuxd /* OUT */ (dmuxd[1:0]),
	.dren /* OUT */ (dren),
	.xdsrc /* OUT */ (xdsrc),
	.iordl /* OUT */ (iordl),
	.iowrl /* OUT */ (iowrl),
	.dspread /* OUT */ (dspread),
	.dspwrite /* OUT */ (dspwrite),
	.dinlatch /* OUT */ (dinlatch[1:0]),
	.ainen /* OUT */ (ainen_obuf),
	.seta1 /* OUT */ (seta1),
	.reads /* OUT */ (rws),
	.dbrls /* OUT */ (dbrls[1:0]),
	.dspen /* OUT */ (dspen),
	.masterdata /* OUT */ (masterdata),
	.sys_clk(sys_clk) // Generated
);

// JERRY.NET (303) - jclk : jclk
_j_jclk jclk_inst
(
	.resetli /* IN */ (resetli),
	.pclkosc /* IN */ (pclkosc),
	.pclkin /* IN */ (pclkin),
	.vclkin /* IN */ (vclkin),
	.chrin /* IN */ (chrclk),
	.clk1w /* IN */ (clk1w),
	.clk2w /* IN */ (clk2w),
	.clk3w /* IN */ (clk3w),
	.test /* IN */ (test),
	.cfg /* IN */ (cfg[3:2]),
	.din /* IN */ (dout[9:0]),
	.din_15 /* IN */ (dout[15]),
	.ndtest /* IN */ (ndtest),
	.cfgw /* OUT */ (cfgw),
	.cfgen /* OUT */ (cfgen),
	.clk /* OUT */ (clk),
	.pclkout /* OUT */ (pclkout),
	.pclkdiv /* OUT */ (pclkdiv),
	.vclkdiv /* OUT */ (vclkdiv),
	.cpuclk /* OUT */ (cpuclk),
	.chrdiv /* OUT */ (chrdiv),
	.vclken /* OUT */ (vclken),
	.resetl /* OUT */ (resetl),
	.tlw /* OUT */ (tlw_unused),
	.sys_clk(sys_clk) // Generated
);

// JERRY.NET (318) - jmisc : jmisc
_j_jmisc jmisc_inst
(
	.din /* IN */ (dout[15:0]),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.pit1w /* IN */ (pit1w),
	.pit2w /* IN */ (pit2w),
	.pit3w /* IN */ (pit3w),
	.pit4w /* IN */ (pit4w),
	.int1w /* IN */ (int1w),
	.pit1r /* IN */ (pit1r),
	.pit2r /* IN */ (pit2r),
	.pit3r /* IN */ (pit3r),
	.pit4r /* IN */ (pit4r),
	.int1r /* IN */ (int1r),
	.dint /* IN */ (dint),
	.eint /* IN */ (eint[0]),
	.test1w /* IN */ (test1w),
	.joy1wl /* IN */ (joy1wl),
	.uint /* IN */ (uint),
	.i2int /* IN */ (i2int),
	.tint /* OUT */ (tint[1:0]),
	.ts /* OUT */ (ts),
	._int /* OUT */ (_int),
	.ndtest /* OUT */ (ndtest),
	.joyenl /* OUT */ (joyenl),
	.dr_out /* BUS */ (dr_misc_out[15:0]),
	.dr_oe /* BUS */ (dr_misc_oe),
	.sys_clk(sys_clk) // Generated
);

// JERRY.NET (341) - uart2 : uart2
_j_uart2 uart2_inst
(
	.resetl /* IN */ (resetl),
	.clk /* IN */ (clk),
	.din /* IN */ (din[15:0]),
	.u2psclw /* IN */ (u2psclw),
	.u2psclr /* IN */ (u2psclr),
	.u2drd /* IN */ (u2drd),
	.u2dwr /* IN */ (u2dwr),
	.u2strd /* IN */ (u2strd),
	.u2ctwr /* IN */ (u2ctwr),
	.serin /* IN */ (serin),
	.serout /* OUT */ (serout),
	.uint /* OUT */ (uint),
	.dr_out /* BUS */ (dr_u2_out[15:0]),
	.dr_oe /* BUS */ (dr_u2_oe),
	.sys_clk(sys_clk) // Generated
);

// JERRY.NET (347) - i2s : i2s
_j_i2s i2s_inst
(
	.resetl /* IN */ (resetl),
	.clk /* IN */ (clk),
	.din /* IN */ (dspwd[15:0]),
	.i2s1w /* IN */ (i2s1w),
	.i2s2w /* IN */ (i2s2w),
	.i2s3w /* IN */ (i2s3w),
	.i2s4w /* IN */ (i2s4w),
	.i2s1r /* IN */ (i2s1r),
	.i2s2r /* IN */ (i2s2r),
	.i2s3r /* IN */ (i2s3r),
	.i2rxd /* IN */ (i2srxd),
	.sckin /* IN */ (sck),
	.wsin /* IN */ (ws),
	.i2txd /* OUT */ (i2stxd),
	.sckout /* OUT */ (sckout),
	.wsout /* OUT */ (wsout),
	.i2int /* OUT */ (i2int),
	.i2sen /* OUT */ (i2sen),
	.dr_out /* BUS */ (dsprd_i2s_out[15:0]),
	.dr_oe /* BUS */ (dsprd_i2s_oe),
	.snd_l /* OUT */ (snd_l[15:0]),
	.snd_r /* OUT */ (snd_r[15:0]),
	.snd_l_en /* OUT */ (snd_l_en),
	.snd_r_en /* OUT */ (snd_r_en),
	.sys_clk(sys_clk) // Generated
);

// JERRY.NET (354) - dac : dac
_j_dac dac_inst
(
	.resetl /* IN */ (resetl),
	.clk /* IN */ (clk),
	.dac1w /* IN */ (dac1w),
	.dac2w /* IN */ (dac2w),
	.tint_0 /* IN */ (tint[0]),
	.ts /* IN */ (ts),
	.dspd /* IN */ (dspwd[15:0]),
	.rdac /* OUT */ (rdac[1:0]),
	.ldac /* OUT */ (ldac[1:0]),
	.sys_clk(sys_clk) // Generated
);

// --- Compiler-generated local PE for BUS dsprd[0]
// Ternaries/muxes are better than stacking ors; assumes no bus conflicts
assign dsprd_out[15:0] = (dsprd_i2s_oe ? dsprd_i2s_out[15:0] : (dsprd_dsp_oe ? dsprd_dsp_out[15:0] : 16'h0)); // if i2s oe then dsprd_dsp_oe is lying (only outputing a copy of i2s on 31:16. Not driving 15:0) Fix?
assign dsprd_oe = dsprd_dsp_oe | dsprd_i2s_oe;

// --- Compiler-generated local PE for BUS dr[0]
// Ternaries/muxes are better than stacking ors; assumes no bus conflicts
assign dr_out[15:0] = (dr_dsp_oe ? dr_dsp_out[15:0] : dr_jio_oe ? dr_jio_out[15:0] : dr_misc_oe ? dr_misc_out[15:0] : dr_u2_oe ? dr_u2_out[15:0] : 16'h0);
assign dr_oe = dr_dsp_oe | dr_jio_oe | dr_misc_oe | dr_u2_oe;

endmodule
