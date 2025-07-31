//`include "defs.v"
// altera message_off 10036

module _tom
(
	input xbgl,
	input [1:0] xdbrl,
	input xlp,
	input xdint,
	input xtest,
	input xpclk,
	input xvclk,
	input xwaitl,
	input xresetl,
	output [63:0] xd_out,
	output [63:0] xd_oe,
	input [63:0] xd_in,
	output [23:0] xa_out,
	output [23:0] xa_oe,
	input [23:0] xa_in,
	output [10:0] xma_out,
	output [10:0] xma_oe,
	input [10:0] xma_in,
	output xhs_out,
	output xhs_oe,
	input xhs_in,
	output xvs_out,
	output xvs_oe,
	input xvs_in,
	output [1:0] xsiz_out,
	output [1:0] xsiz_oe,
	input [1:0] xsiz_in,
	output [2:0] xfc_out,
	output [2:0] xfc_oe,
	input [2:0] xfc_in,
	output xrw_out,
	output xrw_oe,
	input xrw_in,
	output xdreql_out,
	output xdreql_oe,
	input xdreql_in,
	output xba_out,
	output xba_oe,
	input xba_in,
	output xbrl_out,
	output xbrl_oe,
	input xbrl_in,
	output [7:0] xr,
	output [7:0] xg,
	output [7:0] xb,
	output xinc,
	output [2:0] xoel,
	output [2:0] xmaska,
	output [1:0] xromcsl,
	output [1:0] xcasl,
	output xdbgl,
	output xexpl,
	output xdspcsl,
	output [7:0] xwel,
	output [1:0] xrasl,
	output xdtackl,
	output xintl,
	// below signals NOT_NETLIST
	output hs_o,
	output hhs_o,
	output vs_o,
	output refreq,
	output obbreq,
	output [1:0] bbreq,
	output [1:0] gbreq,
	output dram,
	output blank,
	output vblank,
	output hblank,
	output hsync,
	output vsync,
	output vvs,
	input tlw,
	input ram_rdy,
	output aen,
	output [2:0] den,
	input sys_clk, // Generated
	output startcas,
	output d3a,
	output d3b,
	output [7:0] we,
	output startwep,
	output startwe,
	output [10:3] atp,	
	input turbo,
	input vintbugfix,	
	output wire hsl,
	output wire vsl
);
wire [63:0] din;
wire [121:1] nt; // nt[8] skipped
wire [15:0] dp;
wire [63:0] dout;
wire [23:0] ain;
wire [2:0] maska;
wire [23:3] aout;
wire [10:0] cfg;
wire [10:0] ma;
wire cfgen;
wire [1:0] romcsl;
wire [1:0] rasl;
wire notndtest;
wire ndtest;
wire [1:0] casl;
wire [2:0] oel;
wire [7:0] wel;
wire pclk;
wire vxclk;
wire resetli;
wire resetl;
wire waitl;
wire notdreqin;
wire dreqlout;
wire dtackl;
wire rwin;
wire reads;
wire [1:0] sizin;
wire [2:0] sizout;
wire dreqin;
wire [1:0] dbrl;
wire dbgl;
wire expl;
wire dspcsl;
wire intlt;
wire intl;
wire hlock;
//wire hsl;
wire snden;
wire vlock;
//wire vsl;
wire syncen;
wire lp;
wire [7:0] r;
wire [7:0] g;
wire [7:0] b;
wire inc;
wire dint;
wire [2:0] fc;
wire fcen;
wire m68k;
wire brlin;
wire brlout;
wire testen;
wire bglin;
wire bgain;
wire ba;
wire test;
wire nottest;
wire ack;
wire bback;
wire gback;
wire clk;
wire grpintreq;
wire tint;
wire gpuread;
wire gpuwrite;
wire nocpu;
wire [63:0] d;
wire [10:0] at;
wire gpuint;
wire lock;
wire intdev;
wire wet;
wire oet;
wire intswe;
wire intwe;
wire lba;
wire lbb;
wire clut;
wire ourack;
wire memc1r;
wire memc2r;
wire hcr;
wire vcr;
wire lphr;
wire lpvr;
wire ob0r;
wire ob1r;
wire ob2r;
wire ob3r;
wire lbrar;
wire test2r;
wire test3r;
wire intr;
wire pit0r;
wire pit1r;
wire memc1w;
wire memc2w;
wire olp1w;
wire olp2w;
wire obfw;
wire vmodew;
wire bord1w;
wire bord2w;
wire hcw;
wire hpw;
wire hbbw;
wire hbew;
wire hsw;
wire hvsw;
wire hdb1w;
wire hdb2w;
wire hdew;
wire vcw;
wire vpw;
wire vbbw;
wire vbew;
wire vsw;
wire vdbw;
wire vdew;
wire vebw;
wire veew;
wire viw;
wire pit0w;
wire pit1w;
wire heqw;
wire test1w;
wire lbraw;
wire int1w;
wire int2w;
wire bgwr;
wire vclk;
wire vgy;
wire vey;
wire vly;
wire start;
wire dd;
wire lbufa;
wire lbufb;
wire vint;
wire vactive;
wire nextpixa;
wire nextpixd;
wire cry16;
wire rgb24;
wire rg16;
wire rgb16;
wire mptest;
wire varmod;
wire [10:0] vc;
wire tcount;
wire incen;
wire binc;
wire bgw;
wire word2;
wire pp;
wire lbaactive;
wire lbbactive;
wire hcb_10;
wire [31:0] lbrd;
wire [8:0] lbra;
wire [7:0] dinlatch;
wire [2:0] dmuxd;
wire [2:0] dmuxu;
wire dren;
wire xdsrc;
wire ainen;
wire newrow;
wire resrow;
wire mux;
wire cfgw;
wire d7a;
wire readt;
wire match;
wire fintdev;
wire fextdev;
wire fdram;
wire from;
wire [1:0] dspd;
wire [1:0] romspd;
wire [1:0] iospd;
wire [1:0] mw;
wire [3:0] bs;
wire cpu32;
wire [3:0] refrate;
wire bigend;
wire [3:2] abs;
wire hilo;
wire lbt;
wire clutt;
wire fastrom;
wire ihandler;
wire obback;
wire refack;
wire [20:0] newdata;
wire [9:0] newheight;
wire [7:0] newrem;
wire obdready;
wire offscreen;
wire wbkdone;
wire obdone;
wire heightnz;
wire scaled;
wire obdlatch;
wire mode1;
wire mode2;
wire mode4;
wire mode8;
wire mode16;
wire mode24;
wire rmw;
wire [7:1] index;
wire xld;
wire reflected;
wire transen;
wire [7:0] hscale;
wire [9:0] dwidth;
wire [7:0] vscale;
wire wbkstart;
wire obint;
wire [2:0] obld;
wire startref;
wire [9:1] lbwa;
wire [1:0] lbwe;
wire [31:0] lbwd;
wire rmw1;
wire lben;
wire tlw_unused;

wire [63:0] wdata_out;
wire wdata_31_0_oe;
wire wdata_63_32_oe;
wire [63:0] wdata_gpu_out;
wire wdata_gpu_31_0_oe;
wire wdata_gpu_63_32_oe;
wire [63:0] wdata_ob_out;
wire wdata_ob_oe;

wire [23:0] a_out;
wire a_oe;
wire [23:0] a_gpu_out;
wire a_gpu_oe;
wire [23:0] a_abus_out;
wire a_abus_oe;
wire [23:0] a_ob_out;
wire a_ob_oe;

wire [3:0] w_out;
wire w_oe;
wire [3:0] w_gpu_out;
wire w_gpu_oe;
wire [3:0] w_mem_out;
wire w_mem_oe;
wire [3:0] w_ob_out;
wire w_ob_oe;

wire rw_out;
wire rw_oe;
wire rw_gpu_out;
wire rw_gpu_oe;
wire rw_mem_out;
wire rw_mem_oe;
wire rw_ob_out;
wire rw_ob_oe;

wire mreq_out;
wire mreq_oe;
wire mreq_gpu_out;
wire mreq_gpu_oe;
wire mreq_mem_out;
wire mreq_mem_oe;
wire mreq_ob_out;
wire mreq_ob_oe;
wire mreq_misc_out;
wire mreq_misc_oe;

wire [15:0] dr_out;
wire dr_8_0_oe;
wire dr_11_9_oe;
wire dr_15_12_oe;
wire [15:0] dr_gpu_out;
wire dr_gpu_oe;
wire [15:0] dr_vid_out;
wire dr_vid_11_0_oe; // test3r dr[15:12] driven by misc
wire dr_vid_15_12_oe;
wire [8:0] dr_pix_out;
wire dr_pix_8_0_oe;
wire [15:0] dr_abus_out;
wire dr_abus_oe;
wire [15:0] dr_ob_out;
wire dr_ob_oe;
wire [15:0] dr_obdata_out;
wire dr_obdata_oe;
wire [15:0] dr_lbuf_out;
wire dr_lbuf_oe;
wire [15:0] dr_misc_out;
wire dr_misc_oe;
wire dr_misc_15_12_oe;

wire justify_out;
wire justify_oe;
wire justify_gpu_out;
wire justify_gpu_oe;
wire justify_gpu_in;
wire justify_mem_out;
wire justify_mem_oe;
wire justify_mem_in;
wire justify_ob_out;
wire justify_ob_oe;
wire justify_ob_in;

// Output buffers
wire refreq_obuf;
wire obbreq_obuf;
wire dram_obuf;
wire blank_obuf;
wire aen_obuf;
wire [2:0] den_obuf;

// Output buffers
assign refreq = refreq_obuf;
assign obbreq = obbreq_obuf;
assign dram = dram_obuf;
assign blank = blank_obuf;
assign aen = aen_obuf;
assign den[2:0] = den_obuf[2:0];

//assign io_out = a;
//assign io_oe = ~en & tn;
//assign zi = io_in;
//assign po = ~(io_in & pi);
// TOM.NET (140) - dpad[0] : bd8t
assign xd_out[15:0] = dp[15:0];
assign xd_oe[15:0] = {16{den_obuf[0]}};
assign din[15:0] = xd_in[15:0];
// nt = nand tree appears to be for factory testing only
// Should probably remove. Likely to cause timing problems.
// If kept, chain can likely be safely broken up in steps to help timing. 
// Since test is grounded nt[17] is always 1 and nt[16:1] don't matter.
assign nt[78] = ~(xd_in[0] & nt[77]); //
assign nt[74] = ~(xd_in[1] & nt[73]); //
assign nt[70] = ~(xd_in[2] & nt[69]); //
assign nt[66] = ~(xd_in[3] & nt[65]); //
assign nt[62] = ~(xd_in[4] & nt[61]); //
assign nt[58] = ~(xd_in[5] & nt[57]); //
assign nt[54] = ~(xd_in[6] & nt[53]); //
assign nt[50] = ~(xd_in[7] & nt[49]); //
assign nt[49] = ~(xd_in[8] & nt[48]); //
assign nt[53] = ~(xd_in[9] & nt[52]); //
assign nt[57] = ~(xd_in[10] & nt[56]); //
assign nt[61] = ~(xd_in[11] & nt[60]); //
assign nt[65] = ~(xd_in[12] & nt[64]); //
assign nt[69] = ~(xd_in[13] & nt[68]); //
assign nt[73] = ~(xd_in[14] & nt[72]); //
assign nt[77] = ~(xd_in[15] & nt[76]); //

// TOM.NET (158) - dpad[16] : bd4t
assign xd_out[31:16] = dout[31:16];
assign xd_oe[31:16] = {16{den_obuf[1]}};
assign din[31:16] = xd_in[31:16];
assign nt[76] = ~(xd_in[16] & nt[75]); //
assign nt[72] = ~(xd_in[17] & nt[71]); //
assign nt[68] = ~(xd_in[18] & nt[67]); //
assign nt[64] = ~(xd_in[19] & nt[63]); //
assign nt[60] = ~(xd_in[20] & nt[59]); //
assign nt[56] = ~(xd_in[21] & nt[55]); //
assign nt[52] = ~(xd_in[22] & nt[51]); //
assign nt[48] = ~(xd_in[23] & nt[47]); //
assign nt[47] = ~(xd_in[24] & nt[46]); //
assign nt[51] = ~(xd_in[25] & nt[50]); //
assign nt[55] = ~(xd_in[26] & nt[54]); //
assign nt[59] = ~(xd_in[27] & nt[58]); //
assign nt[63] = ~(xd_in[28] & nt[62]); //
assign nt[67] = ~(xd_in[29] & nt[66]); //
assign nt[71] = ~(xd_in[30] & nt[70]); //
assign nt[75] = ~(xd_in[31] & nt[74]); //

// TOM.NET (176) - dpad[32] : bd4t
assign xd_out[63:32] = dout[63:32];
assign xd_oe[63:32] = {32{den_obuf[2]}};
assign din[63:32] = xd_in[63:32];
assign nt[119] = ~(xd_in[32] & nt[118]); //
assign nt[115] = ~(xd_in[33] & nt[114]); //
assign nt[111] = ~(xd_in[34] & nt[110]); //
assign nt[107] = ~(xd_in[35] & nt[106]); //
assign nt[103] = ~(xd_in[36] & nt[102]); //
assign nt[99] = ~(xd_in[37] & nt[98]); //
assign nt[95] = ~(xd_in[38] & nt[94]); //
assign nt[91] = ~(xd_in[39] & nt[90]); //
assign nt[90] = ~(xd_in[40] & nt[89]); //
assign nt[94] = ~(xd_in[41] & nt[93]); //
assign nt[98] = ~(xd_in[42] & nt[97]); //
assign nt[102] = ~(xd_in[43] & nt[101]); //
assign nt[106] = ~(xd_in[44] & nt[105]); //
assign nt[110] = ~(xd_in[45] & nt[109]); //
assign nt[114] = ~(xd_in[46] & nt[113]); //
assign nt[118] = ~(xd_in[47] & nt[117]); //
assign nt[121] = ~(xd_in[48] & nt[120]); //
assign nt[117] = ~(xd_in[49] & nt[116]); //
assign nt[113] = ~(xd_in[50] & nt[112]); //
assign nt[109] = ~(xd_in[51] & nt[108]); //
assign nt[105] = ~(xd_in[52] & nt[104]); //
assign nt[101] = ~(xd_in[53] & nt[100]); //
assign nt[97] = ~(xd_in[54] & nt[96]); //
assign nt[93] = ~(xd_in[55] & nt[92]); //
assign nt[92] = ~(xd_in[56] & nt[91]); //
assign nt[96] = ~(xd_in[57] & nt[95]); //
assign nt[100] = ~(xd_in[58] & nt[99]); //
assign nt[104] = ~(xd_in[59] & nt[103]); //
assign nt[108] = ~(xd_in[60] & nt[107]); //
assign nt[112] = ~(xd_in[61] & nt[111]); //
assign nt[116] = ~(xd_in[62] & nt[115]); //
assign nt[120] = ~(xd_in[63] & nt[119]); //

// TOM.NET (212) - apad[0] : bd4t
assign xa_out[2:0] = maska[2:0];
assign xa_oe[2:0] = {3{aen_obuf}};
assign ain[2:0] = xa_in[2:0];
assign nt[25:23] = ~(xa_in[2:0] & nt[24:22]); //

// TOM.NET (215) - apad[3-23] : bd4t
assign xa_out[23:3] = aout[23:3];
assign xa_oe[23:3] = {21{aen_obuf}};
assign ain[23:3] = xa_in[23:3];
assign nt[46:26] = ~(xa_in[23:3] & nt[45:25]); //

// TOM.NET (217) - mapad[0] : bd16t
assign xma_out[10:0] = ma[10:0];
assign xma_oe[10:0] = {11{cfgen}};
assign cfg[10:0] = xma_in[10:0];
assign nt[89] = ~(xma_in[0] & nt[88]); //
assign nt[88] = ~(xma_in[1] & nt[87]); //
assign nt[87] = ~(xma_in[2] & nt[86]); //
assign nt[86] = ~(xma_in[3] & nt[85]); //
assign nt[85] = ~(xma_in[4] & nt[84]); //
assign nt[84] = ~(xma_in[5] & nt[83]); //
assign nt[83] = ~(xma_in[6] & nt[82]); //
assign nt[82] = ~(xma_in[7] & nt[81]); //
assign nt[81] = ~(xma_in[8] & nt[80]); //
assign nt[80] = ~(xma_in[9] & nt[79]); //
assign nt[79] = ~(xma_in[10] & nt[78]); //

// TOM.NET (231) - maska[0-2] : b2
assign xmaska[2:0] = maska[2:0];

// TOM.NET (234) - romcs[0-1] : b2
assign xromcsl[1:0] = romcsl[1:0];

// TOM.NET (236) - ras[0-1] : b16
assign xrasl[1:0] = rasl[1:0];

// TOM.NET (237) - notndtest : iv
assign notndtest = ~ndtest;

// TOM.NET (239) - cas[0-1] : b16
assign xcasl[1:0] = casl[1:0];

// TOM.NET (241) - oe[0] : b16
// TOM.NET (242) - oe[1] : b8
// TOM.NET (243) - oe[2] : b8
assign xoel[2:0] = oel[2:0];

// TOM.NET (245) - we[0-1] : b16
// TOM.NET (246) - we[2-7] : b4
assign xwel[7:0] = wel[7:0];

// TOM.NET (248) - pclk : ibuf
assign pclk = xpclk;
assign nt[21] = ~(xpclk & nt[20]); //

// TOM.NET (249) - vclk : ibuf
assign vxclk = xvclk;
assign nt[22] = ~(xvclk & nt[21]); //

// TOM.NET (250) - reseti : ibuf
assign resetli = xresetl;
assign nt[16] = ~(xresetl & nt[15]); //

// TOM.NET (251) - reset : bniv34
assign resetl = resetli;

// TOM.NET (253) - wait : ibuf
assign waitl = xwaitl;
assign nt[18] = ~(xwaitl & nt[17]); //

// TOM.NET (256) - dreq : bd2t
assign xdreql_out = dreqlout;
assign xdreql_oe = aen_obuf;
assign notdreqin = xdreql_in;
assign nt[7] = ~(xdreql_in & nt[6]); //

// TOM.NET (257) - dtack : b2
assign xdtackl = dtackl;

// TOM.NET (258) - rw : bd2t
assign xrw_out = reads;
assign xrw_oe = aen_obuf;
assign rwin = xrw_in;
assign nt[9] = ~(xrw_in & nt[7]); //

// TOM.NET (259) - siz[0] : bd2t
assign xsiz_out[1:0] = sizout[1:0];
assign xsiz_oe[1:0] = aen_obuf;
assign sizin[1:0] = xsiz_in[1:0];
assign nt[11:10] = ~(xsiz_in[1:0] & nt[10:9]); //

// TOM.NET (261) - dreqin : ivu
assign dreqin = ~notdreqin;

// TOM.NET (263) - dbrli[0] : ibuf
// TOM.NET (264) - dbrli[1] : ibuf
assign dbrl[1:0] = xdbrl[1:0];
assign nt[20] = ~(xdbrl[0] & nt[19]); //
assign nt[19] = ~(xdbrl[1] & nt[18]); //

// TOM.NET (265) - dbgl : b2
assign xdbgl = dbgl;

// TOM.NET (266) - expl : b4
assign xexpl = expl;

// TOM.NET (267) - dspcsl : b2
assign xdspcsl = dspcsl;

// TOM.NET (271) - intlt : mx2p
assign intlt = (ndtest) ? nt[121] : intl; //

// TOM.NET (272) - xintl : b2
assign xintl = intlt;

// TOM.NET (274) - hs : bd2t
assign xhs_out = hsl;
assign xhs_oe = snden;
assign hlock = xhs_in;
assign nt[1] = ~(xhs_in); //

// TOM.NET (275) - vs : bd2t
assign xvs_out = vsl;
assign xvs_oe = snden;
assign vlock = xvs_in;
assign nt[2] = ~(xvs_in & nt[1]); //

// TOM.NET (277) - snden : an2
assign snden = syncen & notndtest;

// TOM.NET (279) - lp : ibuf
assign lp = xlp;
assign nt[3] = ~(xlp & nt[2]); //

// TOM.NET (281) - r[0-7] : b2
assign xr[7:0] = r[7:0];

// TOM.NET (282) - g[0-7] : b2
assign xg[7:0] = g[7:0];

// TOM.NET (283) - b[0-7] : b2
assign xb[7:0] = b[7:0];

// TOM.NET (285) - inc : b2
assign xinc = inc;

// TOM.NET (287) - dint : ibuf
assign dint = xdint;
assign nt[12] = ~(xdint & nt[11]); //

// TOM.NET (289) - fc[0] : bd2t
assign xfc_out[2:0] = 3'b101;
assign xfc_oe[2:0] = {aen,aen,fcen};
assign fc[2:0] = xfc_in[2:0];
assign nt[6:4] = ~(xfc_in[2:0] & nt[5:3]); //

// TOM.NET (292) - fcen : an2
assign fcen = aen_obuf & m68k;

// TOM.NET (294) - brl : bd2t
assign xbrl_out = 1'b0;
assign xbrl_oe = (~brlout & testen);
assign brlin = xbrl_in;
assign nt[13] = ~(xbrl_in & nt[12]); //

// TOM.NET (295) - bgl : ibuf
assign bglin = xbgl;
assign nt[14] = ~(xbgl & nt[13]); //

// TOM.NET (296) - ba : bd2t
assign xba_out = 1'b0;
assign xba_oe = (ba);
assign bgain = xba_in;
assign nt[15] = ~(xba_in & nt[14]); //

// TOM.NET (298) - test : ibuf
assign test = xtest;
assign nt[17] = ~(xtest & nt[16]); //

// TOM.NET (309) - nottest : iv
assign nottest = ~test;

// TOM.NET (310) - testen : or2
assign testen = nottest | dint;

// TOM.NET (313) - gpu : graphics
_graphics gpu_inst
(
	.ima /* IN */ ({aout[15:3],maska[2:0]}),
	.dwrite /* IN */ (dout[31:0]),
	.ack /* IN */ (ack),
	.blit_back /* IN */ (bback),
	.gpu_back /* IN */ (gback),
	.reset_n /* IN */ (resetl),
	.clk /* IN */ (clk),
	.tlw /* IN */ (tlw),
	.dint /* IN */ (dint),
	.gpu_irq /* IN */ ({grpintreq,tint}),//3 2
	.iord /* IN */ (gpuread),
	.iowr /* IN */ (gpuwrite),
	.reset_lock /* IN */ (nocpu),
	.data /* IN */ (d[63:0]),
	.at_1 /* IN */ (at[1]),
	.blit_breq /* OUT */ (bbreq[1:0]),
	.gpu_breq /* OUT */ (gbreq[0]),
	.dma_breq /* OUT */ (gbreq[1]),
	.cpu_int /* OUT */ (gpuint),
	.lock /* OUT */ (lock),
	.wdata_out /* BUS */ (wdata_gpu_out[63:0]),
	.wdata_31_0_oe /* BUS */ (wdata_gpu_31_0_oe),
	.wdata_63_32_oe /* BUS */ (wdata_gpu_63_32_oe),
	.a_out /* BUS */ (a_gpu_out[23:0]),
	.a_oe /* BUS */ (a_gpu_oe),
	.a_15_in /* BUS */ (a_out[15]),
	.width_out /* BUS */ (w_gpu_out[3:0]),
	.width_oe /* BUS */ (w_gpu_oe),
	.read_out /* BUS */ (rw_gpu_out),
	.read_oe /* BUS */ (rw_gpu_oe),
	.read_in /* BUS */ (rw_out),
	.mreq_out /* BUS */ (mreq_gpu_out),
	.mreq_oe /* BUS */ (mreq_gpu_oe),
	.mreq_in /* BUS */ (mreq_out),
	.dr_out /* BUS */ (dr_gpu_out[15:0]),
	.dr_oe /* BUS */ (dr_gpu_oe),
	.justify_out /* BUS */ (justify_gpu_out),
	.justify_oe /* BUS */ (justify_gpu_oe),
	.justify_in /* BUS */ (justify_out),
	.sys_clk(sys_clk) // Generated
);

// TOM.NET (321) - iodec : iodec
_iodec iodec_inst
(
	.a /* IN */ ({aout[15:3],maska[2:0]}),
	.intdev /* IN */ (intdev),
	.wet /* IN */ (wet),
	.oet /* IN */ (oet),
	.intswe /* IN */ (intswe),
	.reads /* IN */ (reads),
	.intwe /* IN */ (intwe),
	.lba /* IN */ (lba),
	.lbb /* IN */ (lbb),
	.clut /* IN */ (clut),
	.ourack /* IN */ (ourack),
	.romcsl /* IN */ (romcsl[1:0]),
	.dspcsl /* IN */ (dspcsl),
	.memc1r /* OUT */ (memc1r),
	.memc2r /* OUT */ (memc2r),
	.hcr /* OUT */ (hcr),
	.vcr /* OUT */ (vcr),
	.lphr /* OUT */ (lphr),
	.lpvr /* OUT */ (lpvr),
	.ob0r /* OUT */ (ob0r),
	.ob1r /* OUT */ (ob1r),
	.ob2r /* OUT */ (ob2r),
	.ob3r /* OUT */ (ob3r),
	.lbrar /* OUT */ (lbrar),
	.test2r /* OUT */ (test2r),
	.test3r /* OUT */ (test3r),
	.intr /* OUT */ (intr),
	.pit0r /* OUT */ (pit0r),
	.pit1r /* OUT */ (pit1r),
	.memc1w /* OUT */ (memc1w),
	.memc2w /* OUT */ (memc2w),
	.olp1w /* OUT */ (olp1w),
	.olp2w /* OUT */ (olp2w),
	.obfw /* OUT */ (obfw),
	.vmodew /* OUT */ (vmodew),
	.bord1w /* OUT */ (bord1w),
	.bord2w /* OUT */ (bord2w),
	.hcw /* OUT */ (hcw),
	.hpw /* OUT */ (hpw),
	.hbbw /* OUT */ (hbbw),
	.hbew /* OUT */ (hbew),
	.hsw /* OUT */ (hsw),
	.hvsw /* OUT */ (hvsw),
	.hdb1w /* OUT */ (hdb1w),
	.hdb2w /* OUT */ (hdb2w),
	.hdew /* OUT */ (hdew),
	.vcw /* OUT */ (vcw),
	.vpw /* OUT */ (vpw),
	.vbbw /* OUT */ (vbbw),
	.vbew /* OUT */ (vbew),
	.vsw /* OUT */ (vsw),
	.vdbw /* OUT */ (vdbw),
	.vdew /* OUT */ (vdew),
	.vebw /* OUT */ (vebw),
	.veew /* OUT */ (veew),
	.viw /* OUT */ (viw),
	.pit0w /* OUT */ (pit0w),
	.pit1w /* OUT */ (pit1w),
	.heqw /* OUT */ (heqw),
	.test1w /* OUT */ (test1w),
	.lbraw /* OUT */ (lbraw),
	.int1w /* OUT */ (int1w),
	.int2w /* OUT */ (int2w),
	.bgwr /* OUT */ (bgwr),
	.expl /* OUT */ (expl)
);

// TOM.NET (335) - vid : vid
_vid vid_inst
(
	.din /* IN */ (dout[11:0]),
	.vmwr /* IN */ (vmodew),
	.hcwr /* IN */ (hcw),
	.hcrd /* IN */ (hcr),
	.hpwr /* IN */ (hpw),
	.hbbwr /* IN */ (hbbw),
	.hbewr /* IN */ (hbew),
	.hdb1wr /* IN */ (hdb1w),
	.hdb2wr /* IN */ (hdb2w),
	.hdewr /* IN */ (hdew),
	.hswr /* IN */ (hsw),
	.hvswr /* IN */ (hvsw),
	.vcwr /* IN */ (vcw),
	.vcrd /* IN */ (vcr),
	.vpwr /* IN */ (vpw),
	.vbbwr /* IN */ (vbbw),
	.vbewr /* IN */ (vbew),
	.vdbwr /* IN */ (vdbw),
	.vdewr /* IN */ (vdew),
	.vebwr /* IN */ (vebw),
	.veewr /* IN */ (veew),
	.vswr /* IN */ (vsw),
	.viwr /* IN */ (viw),
	.lphrd /* IN */ (lphr),
	.lpvrd /* IN */ (lpvr),
	.hlock /* IN */ (hlock),
	.vlock /* IN */ (vlock),
	.resetl /* IN */ (resetl),
	.vclk /* IN */ (vclk),
	.lp /* IN */ (lp),
	.heqw /* IN */ (heqw),
	.test1w /* IN */ (test1w),
	.test2r /* IN */ (test2r),
	.test3r /* IN */ (test3r),
	.wet /* IN */ (wet),
	.vgy /* IN */ (vgy),
	.vey /* IN */ (vey),
	.vly /* IN */ (vly),
	.lock /* IN */ (lock),
	.start /* OUT */ (start),
	.dd /* OUT */ (dd),
	.lbufa /* OUT */ (lbufa),
	.lbufb /* OUT */ (lbufb),
	.noths /* OUT */ (hsl),
	.notvs /* OUT */ (vsl),
	.syncen /* OUT */ (syncen),
	.vint /* OUT */ (vint),
	.vactive /* OUT */ (vactive),
	.blank /* OUT */ (blank_obuf),
	.hblank_out     (hblank),
	.vblank_out      (vblank),
	.hsync_out      (hsync),
	.vsync_out      (vsync),
	.vvs_o          (vvs),
	.nextpixa /* OUT */ (nextpixa),
	.nextpixd /* OUT */ (nextpixd),
	.cry16 /* OUT */ (cry16),
	.rgb24 /* OUT */ (rgb24),
	.rg16 /* OUT */ (rg16),
	.rgb16 /* OUT */ (rgb16),
	.mptest /* OUT */ (mptest),
	.ndtest /* OUT */ (ndtest),
	.varmod /* OUT */ (varmod),
	.vcl /* OUT */ (vc[10:0]),
	.tcount /* OUT */ (tcount),
	.incen /* OUT */ (incen),
	.binc /* OUT */ (binc),
	.bgw /* OUT */ (bgw),
	.word2 /* OUT */ (word2),
	.pp /* OUT */ (pp),
	.lbaactive /* OUT */ (lbaactive),
	.lbbactive /* OUT */ (lbbactive),
	.hcb_10 /* OUT */ (hcb_10),
	.hs_o /* OUT */ (hs_o),
	.hhs_o /* OUT */ (hhs_o),
	.vs_o /* OUT */ (vs_o),
	.dr_out /* BUS */ (dr_vid_out[15:0]),
	.dr_11_0_oe /* BUS */ (dr_vid_11_0_oe),
	.dr_15_12_oe /* BUS */ (dr_vid_15_12_oe), // test3r dr[15:12] driven by misc
	.sys_clk(sys_clk) // Generated
);

// TOM.NET (352) - pix : pix
_pix pix_inst
(
	.din /* IN */ (dout[15:0]),
	.dd /* IN */ (dd),
	.vactive /* IN */ (vactive),
	.blank /* IN */ (blank_obuf),
	.nextpixa /* IN */ (nextpixa),
	.nextpixd /* IN */ (nextpixd),
	.cry16 /* IN */ (cry16),
	.rgb24 /* IN */ (rgb24),
	.rg16 /* IN */ (rg16),
	.lbrd /* IN */ (lbrd[31:0]),
	.lbraw /* IN */ (lbraw),
	.lbrar /* IN */ (lbrar),
	.bcrgwr /* IN */ (bord1w),
	.bcbwr /* IN */ (bord2w),
	.resetl /* IN */ (resetl),
	.vclk /* IN */ (vclk),
	.mptest /* IN */ (mptest),
	.incen /* IN */ (incen),
	.binc /* IN */ (binc),
	.lp /* IN */ (lp),
	.rgb16 /* IN */ (rgb16),
	.varmod /* IN */ (varmod),
	.word2 /* IN */ (word2),
	.pp /* IN */ (pp),
	.lbra /* OUT */ (lbra[8:0]),
	.r /* OUT */ (r[7:0]),
	.g /* OUT */ (g[7:0]),
	.b /* OUT */ (b[7:0]),
	.inc /* OUT */ (inc),
	.dr_out /* BUS */ (dr_pix_out[8:0]),
	.dr_8_0_oe /* BUS */ (dr_pix_8_0_oe),
	.sys_clk(sys_clk) // Generated
);

// TOM.NET (363) - dbus : dbus
_dbus dbus_inst
(
	.din /* IN */ (din[63:0]),
	.dr /* IN */ (dr_out[15:0]),
	.dinlatch /* IN */ (dinlatch[7:0]),
	.dmuxd /* IN */ (dmuxd[2:0]),
	.dmuxu /* IN */ (dmuxu[2:0]),
	.dren /* IN */ (dren),
	.xdsrc /* IN */ (xdsrc),
	.ourack /* IN */ (ourack),
	.wd /* IN */ (wdata_out[63:0]),
	.clk /* IN */ (clk),
	.dp /* OUT */ (dp[15:0]),
	.dob /* OUT */ (dout[15:0]),
	.dout /* OUT */ (dout[31:16]),
	.d5 /* OUT */ (dout[63:32]),
	.d /* OUT */ (d[63:0]),
	.sys_clk(sys_clk) // Generated
);

assign atp[10:3] = at[10:3]; 
// TOM.NET (369) - abus : abus
_abus abus_inst
(
	.ain /* IN */ (ain[23:0]),
	.ainen /* IN */ (ainen),
	.atin /* IN */ (at[2:0]),
	.din /* IN */ (dout[14:0]),
	.newrow /* IN */ (newrow),
	.resrow /* IN */ (resrow),
	.mux /* IN */ (mux),
	.resetl /* IN */ (resetl),
	.memc1r /* IN */ (memc1r),
	.memc2r /* IN */ (memc2r),
	.memc1w /* IN */ (memc1w),
	.memc2w /* IN */ (memc2w),
	.cfg /* IN */ (cfg[8:0]),
	.cfgw /* IN */ (cfgw),
	.cfgen /* IN */ (cfgen),
	.ack /* IN */ (ack),
	.clk /* IN */ (clk),
	.ba /* IN */ (ba),
	.fc /* IN */ (fc[2:0]),
	.siz_1 /* IN */ (sizin[1]),
	.mreq /* IN */ (mreq_out),
	.dreqin /* IN */ (dreqin),
	.lbufa /* IN */ (lbufa),
	.d7a /* IN */ (d7a),
	.readt /* IN */ (readt),
	.wet /* IN */ (wet),
	.aout /* OUT */ (aout[23:3]),
	.ma /* OUT */ (ma[10:0]),
	.match /* OUT */ (match),
	.intdev /* OUT */ (intdev),
	.fintdev /* OUT */ (fintdev),
	.fextdev /* OUT */ (fextdev),
	.fdram /* OUT */ (fdram),
	.from /* OUT */ (from),
	.dspd /* OUT */ (dspd[1:0]),
	.romspd /* OUT */ (romspd[1:0]),
	.iospd /* OUT */ (iospd[1:0]),
	.dram /* OUT */ (dram_obuf),
	.mw /* OUT */ (mw[1:0]),
	.bs /* OUT */ (bs[3:0]),
	.cpu32 /* OUT */ (cpu32),
	.refrate /* OUT */ (refrate[3:0]),
	.bigend /* OUT */ (bigend),
	.ourack /* OUT */ (ourack),
	.nocpu /* OUT */ (nocpu),
	.gpuread /* OUT */ (gpuread),
	.gpuwrite /* OUT */ (gpuwrite),
	.abs /* OUT */ (abs[3:2]),
	.hilo /* OUT */ (hilo),
	.lba /* OUT */ (lba),
	.lbb /* OUT */ (lbb),
	.lbt /* OUT */ (lbt),
	.clut /* OUT */ (clut),
	.clutt /* OUT */ (clutt),
	.fastrom /* OUT */ (fastrom),
	.m68k /* OUT */ (m68k),
	.atout /* OUT */ (at[10:3]),
	.a_out /* BUS */ (a_abus_out[23:0]),
	.a_oe /* BUS */ (a_abus_oe),
	.a_in /* BUS */ (a_out[23:0]),
	.dr_out /* BUS */ (dr_abus_out[15:0]),
	.dr_oe /* BUS */ (dr_abus_oe),
	.sys_clk(sys_clk) // Generated
);

// TOM.NET (386) - mem : mem
_mem mem_inst
(
	.bbreq /* IN */ (bbreq[1:0]),
	.gbreq /* IN */ (gbreq[1:0]),
	.obbreq /* IN */ (obbreq_obuf),
	.sizin /* IN */ (sizin[1:0]),
	.dbrl /* IN */ (dbrl[1:0]),
	.dreqin /* IN */ (dreqin),
	.rwin /* IN */ (rwin),
	.bs /* IN */ (bs[3:0]),
	.match /* IN */ (match),
	.intdev /* IN */ (intdev),
	.dram /* IN */ (dram_obuf),
	.fextdev /* IN */ (fextdev),
	.fintdev /* IN */ (fintdev),
	.fdram /* IN */ (fdram),
	.from /* IN */ (from),
	.cpu32 /* IN */ (cpu32),
	.refreq /* IN */ (refreq_obuf),
	.dspd /* IN */ (dspd[1:0]),
	.romspd /* IN */ (romspd[1:0]),
	.iospd /* IN */ (iospd[1:0]),
	.a /* IN */ (a_out[2:0]),
	.mw /* IN */ (mw[1:0]),
	.ourack /* IN */ (ourack),
	.resetl /* IN */ (resetl),
	.clk /* IN */ (clk),
	.bglin /* IN */ (bglin),
	.brlin /* IN */ (brlin),
	.ihandler /* IN */ (ihandler),
	.bigend /* IN */ (bigend),
	.bgain /* IN */ (bgain),
	.abs /* IN */ (abs[3:2]),
	.testen /* IN */ (testen),
	.waitl /* IN */ (waitl),
	.fastrom /* IN */ (fastrom),
	.m68k /* IN */ (m68k),
	.pclk /* IN */ (pclk),
	.ack /* OUT */ (ack),
	.bback /* OUT */ (bback),
	.gback /* OUT */ (gback),
	.obback /* OUT */ (obback),
	.romcsl /* OUT */ (romcsl[1:0]),
	.rasl /* OUT */ (rasl[1:0]),
	.casl /* OUT */ (casl[1:0]),
	.oel /* OUT */ (oel[2:0]),
	.wel /* OUT */ (wel[7:0]),
	.sizout /* OUT */ (sizout[2:0]),
	.den /* OUT */ (den_obuf[2:0]),
	.aen /* OUT */ (aen_obuf),
	.dtackl /* OUT */ (dtackl),
	.brlout /* OUT */ (brlout),
	.dbgl /* OUT */ (dbgl),
	.dreqlout /* OUT */ (dreqlout),
	.d7a /* OUT */ (d7a),
	.readt /* OUT */ (readt),
	.dinlatch /* OUT */ (dinlatch[7:0]),
	.dmuxu /* OUT */ (dmuxu[2:0]),
	.dmuxd /* OUT */ (dmuxd[2:0]),
	.dren /* OUT */ (dren),
	.xdsrc /* OUT */ (xdsrc),
	.maska /* OUT */ (maska[2:0]),
	.at /* OUT */ (at[2:0]),
	.ainen /* OUT */ (ainen),
	.newrow /* OUT */ (newrow),
	.resrow /* OUT */ (resrow),
	.mux /* OUT */ (mux),
	.refack /* OUT */ (refack),
	.reads /* OUT */ (reads),
	.wet /* OUT */ (wet),
	.oet /* OUT */ (oet),
	.ba /* OUT */ (ba),
	.intswe /* OUT */ (intswe),
	.intwe /* OUT */ (intwe),
	.dspcsl /* OUT */ (dspcsl),
	.w_out /* BUS */ (w_mem_out[3:0]),
	.w_oe /* BUS */ (w_mem_oe),
	.w_in /* BUS */ (w_out[3:0]),
	.rw_out /* BUS */ (rw_mem_out),
	.rw_oe /* BUS */ (rw_mem_oe),
	.rw_in /* BUS */ (rw_out),
	.mreq_out /* BUS */ (mreq_mem_out),
	.mreq_oe /* BUS */ (mreq_mem_oe),
	.mreq_in /* BUS */ (mreq_out),
	.justify_out /* BUS */ (justify_mem_out),
	.justify_oe /* BUS */ (justify_mem_oe),
	.justify_in /* BUS */ (justify_out),
	.tlw /* IN */ (tlw),
	.ram_rdy /* IN */ (ram_rdy),
	.sys_clk(sys_clk), // Generated
	.d3a(d3a),
	.d3b(d3b),
	.we_(we[7:0]),
	.startwep(startwep),
	.startwe_out(startwe),
	.startcas_out(startcas)
);

// TOM.NET (412) - ob : ob
_ob ob_inst
(
	.din /* IN */ (dout[15:0]),
	.olp1w /* IN */ (olp1w),
	.olp2w /* IN */ (olp2w),
	.obfw /* IN */ (obfw),
	.ob0r /* IN */ (ob0r),
	.ob1r /* IN */ (ob1r),
	.ob2r /* IN */ (ob2r),
	.ob3r /* IN */ (ob3r),
	.start /* IN */ (start),
	.newdata /* IN */ (newdata[20:0]),
	.newheight /* IN */ (newheight[9:0]),
	.newrem /* IN */ (newrem[7:0]),
	.obdready /* IN */ (obdready),
	.offscreen /* IN */ (offscreen),
	.refack /* IN */ (refack),
	.obback /* IN */ (obback),
	.mack /* IN */ (ack),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.vc /* IN */ (vc[10:0]),
	.wbkdone /* IN */ (wbkdone),
	.obdone /* IN */ (obdone),
	.heightnz /* IN */ (heightnz),
	.d /* IN */ (d[63:0]),
	.blback /* IN */ (bback),
	.grpback /* IN */ (gback),
	.wet /* IN */ (wet),
	.hcb_10 /* IN */ (hcb_10),
	.scaled /* OUT */ (scaled),
	.obdlatch /* OUT */ (obdlatch),
	.mode1 /* OUT */ (mode1),
	.mode2 /* OUT */ (mode2),
	.mode4 /* OUT */ (mode4),
	.mode8 /* OUT */ (mode8),
	.mode16 /* OUT */ (mode16),
	.mode24 /* OUT */ (mode24),
	.rmw /* OUT */ (rmw),
	.index /* OUT */ (index[7:1]),
	.xld /* OUT */ (xld),
	.reflected /* OUT */ (reflected),
	.transen /* OUT */ (transen),
	.hscale /* OUT */ (hscale[7:0]),
	.dwidth /* OUT */ (dwidth[9:0]),
	.obbreq /* OUT */ (obbreq_obuf),
	.vscale /* OUT */ (vscale[7:0]),
	.wbkstart /* OUT */ (wbkstart),
	.grpintreq /* OUT */ (grpintreq),
	.obint /* OUT */ (obint),
	.obld_0 /* OUT */ (obld[0]),
	.obld_1 /* OUT */ (obld[1]),
	.obld_2 /* OUT */ (obld[2]),
	.startref /* OUT */ (startref),
	.vgy /* OUT */ (vgy),
	.vey /* OUT */ (vey),
	.vly /* OUT */ (vly),
	.wd_out /* BUS */ (wdata_ob_out[63:0]),
	.wd_oe /* BUS */ (wdata_ob_oe),
	.a_out /* BUS */ (a_ob_out[23:0]),
	.a_oe /* BUS */ (a_ob_oe),
	.w_out /* BUS */ (w_ob_out[3:0]),
	.w_oe /* BUS */ (w_ob_oe),
	.rw_out /* BUS */ (rw_ob_out),
	.rw_oe /* BUS */ (rw_ob_oe),
	.rw_in /* BUS */ (rw_out),
	.mreq_out /* BUS */ (mreq_ob_out),
	.mreq_oe /* BUS */ (mreq_ob_oe),
	.mreq_in /* BUS */ (mreq_out),
	.justify_out /* BUS */ (justify_ob_out),
	.justify_oe /* BUS */ (justify_ob_oe),
	.dr_out /* BUS */ (dr_ob_out[15:0]),
	.dr_oe /* BUS */ (dr_ob_oe),
	.sys_clk(sys_clk) // Generated
);

// TOM.NET (427) - wbk : wbk
_wbk wbk_inst
(
	.d /* IN */ (d[63:0]),// only d[23:14] and d[63:43] used
	.obld_0 /* IN */ (obld[0]),
	.obld_2 /* IN */ (obld[2]),
	.dwidth /* IN */ (dwidth[9:0]),
	.vscale /* IN */ (vscale[7:0]),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.scaled /* IN */ (scaled),
	.wbkstart /* IN */ (wbkstart),
	.newdata /* OUT */ (newdata[20:0]),
	.newheight /* OUT */ (newheight[9:0]),
	.newrem /* OUT */ (newrem[7:0]),
	.heightnz /* OUT */ (heightnz),
	.wbkdone /* OUT */ (wbkdone),
	.sys_clk(sys_clk) // Generated
);

// TOM.NET (435) - obd : obdata
_obdata obd_inst
(
	.aout_9 /* IN */ (aout[9]),
	.din /* IN */ (dout[15:0]),
	.reads /* IN */ (reads),
	.palen /* IN */ (clut),
	.clutt /* IN */ (clutt),
	.d /* IN */ (d[63:0]),
	.obdlatch /* IN */ (obdlatch),
	.mode1 /* IN */ (mode1),
	.mode2 /* IN */ (mode2),
	.mode4 /* IN */ (mode4),
	.mode8 /* IN */ (mode8),
	.mode16 /* IN */ (mode16),
	.mode24 /* IN */ (mode24),
	.scaledtype /* IN */ (scaled),
	.rmw /* IN */ (rmw),
	.index /* IN */ (index[7:1]),
	.xld /* IN */ (xld),
	.reflected /* IN */ (reflected),
	.transen /* IN */ (transen),
	.xscale /* IN */ (hscale[7:0]),
	.resetl /* IN */ (resetl),
	.clk /* IN */ (clk),
	.obld_1 /* IN */ (obld[1]),
	.obld_2 /* IN */ (obld[2]),
	.hilo /* IN */ (hilo),
	.lbt /* IN */ (lbt),
	.at /* IN */ (at[10:1]),
	.obdone /* OUT */ (obdone),
	.obdready /* OUT */ (obdready),
	.lbwa /* OUT */ (lbwa[9:1]),
	.lbwe /* OUT */ (lbwe[1:0]),
	.lbwd /* OUT */ (lbwd[31:0]),
	.offscreen /* OUT */ (offscreen),
	.rmw1 /* OUT */ (rmw1),
	.lben /* OUT */ (lben),
	.dr_out /* BUS */ (dr_obdata_out[15:0]),
	.dr_oe /* BUS */ (dr_obdata_oe),
	.sys_clk(sys_clk) // Generated
);

// TOM.NET (444) - lbuf : lbuf
_lbuf lbuf_inst
(
	.aout_1 /* IN */ (maska[1]),
	.aout_15 /* IN */ (aout[15]),
	.dout /* IN */ (dout[31:0]),
	.siz_2 /* IN */ (sizout[2]),
	.lbwa /* IN */ (lbwa[9:1]),
	.lbra /* IN */ (lbra[8:0]),
	.lbwe /* IN */ (lbwe[1:0]),
	.lbwd /* IN */ (lbwd[31:0]),
	.lbufa /* IN */ (lbufa),
	.lbufb /* IN */ (lbufb),
	.lbaw /* IN */ (lba),
	.lbbw /* IN */ (lbb),
	.rmw /* IN */ (rmw1),
	.reads /* IN */ (reads),
	.vclk /* IN */ (vclk),
	.clk /* IN */ (clk),
	.lben /* IN */ (lben),
	.bgw /* IN */ (bgw),
	.bgwr /* IN */ (bgwr),
	.vactive /* IN */ (vactive),
	.lbaactive /* IN */ (lbaactive),
	.lbbactive /* IN */ (lbbactive),
	.bigend /* IN */ (bigend),
	.lbrd /* OUT */ (lbrd[31:0]),
	.dr_out /* BUS */ (dr_lbuf_out[15:0]),
	.dr_oe /* BUS */ (dr_lbuf_oe),
	.sys_clk(sys_clk) // Generated
);

// TOM.NET (453) - clk : clk
_clk clk_inst
(
	.resetl /* IN */ (resetl),
	.pclk /* IN */ (pclk),
	.vxclk /* IN */ (vxclk),
	.ndtest /* IN */ (ndtest),
	.cfg_7 /* IN */ (cfg[7]),
	.cfgw /* OUT */ (cfgw),
	.cfgen /* OUT */ (cfgen),
	.clk /* OUT */ (clk),
	.vclk /* OUT */ (vclk),
	.tlw /* OUT */ (tlw_unused),
	.sys_clk(sys_clk) // Generated
);

// TOM.NET (465) - misc_ : misc
_misc misc__inst
(
	.din /* IN */ (dout[15:0]),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.pit0w /* IN */ (pit0w),
	.pit1w /* IN */ (pit1w),
	.int1w /* IN */ (int1w),
	.int2w /* IN */ (int2w),
	.intr /* IN */ (intr),
	.obint /* IN */ (obint),
	.gpuint /* IN */ (gpuint),
	.vint /* IN */ (vint),
	.dint /* IN */ (dint),
	.refrate /* IN */ (refrate[3:0]),
	.refback /* IN */ (refack),
	.ack /* IN */ (ack),
	.startref /* IN */ (startref),
	.wet /* IN */ (wet),
	.pit0r /* IN */ (pit0r),
	.pit1r /* IN */ (pit1r),
	.tcount /* IN */ (tcount),
	.test3r /* IN */ (test3r),
	.ihandler /* OUT */ (ihandler),
	.tint /* OUT */ (tint),
	.refreq /* OUT */ (refreq_obuf),
	.intl /* OUT */ (intl),
	.dr_out /* BUS */ (dr_misc_out[15:0]),
	.dr_oe /* BUS */ (dr_misc_oe),
	.dr_15_12_oe /* BUS */ (dr_misc_15_12_oe), // test3r dr[11:0] driven by vid
	.mreq_out /* BUS */ (mreq_misc_out),
	.mreq_oe /* BUS */ (mreq_misc_oe),
	.mreq_in /* BUS */ (mreq_out),
// NOT_NETLIST
	.vintbugfix(vintbugfix),
	.sys_clk(sys_clk) // Generated
);

// --- Compiler-generated local PE for BUS wd[0]
// Ternaries/muxes are better than stacking ors; assumes no bus conflicts
assign wdata_out[31:0] = wdata_gpu_31_0_oe ? wdata_gpu_out[31:0] : (wdata_ob_oe ? wdata_ob_out[31:0] : 32'h0);
assign wdata_31_0_oe = wdata_gpu_31_0_oe | wdata_ob_oe;
assign wdata_out[63:32] = wdata_gpu_63_32_oe ? wdata_gpu_out[63:32] : (wdata_ob_oe ? wdata_ob_out[63:32] : 32'h0);
assign wdata_63_32_oe = wdata_gpu_63_32_oe | wdata_ob_oe;

// --- Compiler-generated local PE for BUS a[0]
assign a_out[23:0] = (a_gpu_oe ? a_gpu_out[23:0] : 24'h0) | (a_abus_oe ? a_abus_out[23:0] : 24'h0) | (a_ob_oe ? a_ob_out[23:0] : 24'h0);
assign a_oe = a_gpu_oe | a_abus_oe | a_ob_oe;

// --- Compiler-generated local PE for BUS w[0]
assign w_out[3:0] = (w_gpu_oe ? w_gpu_out[3:0] : 4'h0) | (w_mem_oe ? w_mem_out[3:0] : 4'h0) | (w_ob_oe ? w_ob_out[3:0] : 4'h0);
assign w_oe = w_gpu_oe | w_mem_oe | w_ob_oe;

// --- Compiler-generated local PE for BUS rw
assign rw_out = (rw_gpu_oe ? rw_gpu_out : 1'b0) | (rw_mem_oe ? rw_mem_out : 1'b0) | (rw_ob_oe ? rw_ob_out : 1'b0);
assign rw_oe = rw_gpu_oe | rw_mem_oe | rw_ob_oe;

// --- Compiler-generated local PE for BUS mreq
assign mreq_out = (mreq_gpu_oe ? mreq_gpu_out : 1'b0) | (mreq_mem_oe ? mreq_mem_out : 1'b0) | (mreq_ob_oe ? mreq_ob_out : 1'b0) | (mreq_misc_oe ? mreq_misc_out : 1'b0);
assign mreq_oe = mreq_gpu_oe | mreq_mem_oe | mreq_ob_oe | mreq_misc_oe;

// --- Compiler-generated local PE for BUS dr[0]
assign dr_out[8:0] = (dr_gpu_oe ? dr_gpu_out[8:0] : 9'h0)
                   | (dr_vid_11_0_oe ? dr_vid_out[8:0] : 9'h0)
                   | (dr_pix_8_0_oe ? dr_pix_out[8:0] : 9'h0)
                   | (dr_abus_oe ? dr_abus_out[8:0] : 9'h0)
                   | (dr_ob_oe ? dr_ob_out[8:0] : 9'h0)
                   | (dr_obdata_oe ? dr_obdata_out[8:0] : 9'h0)
                   | (dr_lbuf_oe ? dr_lbuf_out[8:0] : 9'h0)
                   | (dr_misc_oe ? dr_misc_out[8:0] : 9'h0);
assign dr_8_0_oe = dr_gpu_oe | dr_vid_11_0_oe | dr_pix_8_0_oe | dr_abus_oe | dr_ob_oe | dr_obdata_oe | dr_lbuf_oe | dr_misc_oe;
						 
assign dr_out[11:9] = (dr_gpu_oe ? dr_gpu_out[11:9] : 3'h0)
                    | (dr_vid_11_0_oe ? dr_vid_out[11:9] : 3'h0)
                    | (dr_abus_oe ? dr_abus_out[11:9] : 3'h0)
                    | (dr_ob_oe ? dr_ob_out[11:9] : 3'h0)
                    | (dr_obdata_oe ? dr_obdata_out[11:9] : 3'h0)
                    | (dr_lbuf_oe ? dr_lbuf_out[11:9] : 3'h0)
                    | (dr_misc_oe ? dr_misc_out[11:9] : 3'h0);
assign dr_11_9_oe = dr_gpu_oe | dr_vid_11_0_oe | dr_abus_oe | dr_ob_oe | dr_obdata_oe | dr_lbuf_oe | dr_misc_oe;

assign dr_out[15:12] = (dr_gpu_oe ? dr_gpu_out[15:12] : 4'h0)
                     | (dr_vid_15_12_oe ? dr_vid_out[15:12] : 4'h0)
                     | (dr_abus_oe ? dr_abus_out[15:12] : 4'h0)
                     | (dr_ob_oe ? dr_ob_out[15:12] : 4'h0)
                     | (dr_obdata_oe ? dr_obdata_out[15:12] : 4'h0)
                     | (dr_lbuf_oe ? dr_lbuf_out[15:12] : 4'h0)
                     | ((dr_misc_oe | dr_misc_15_12_oe) ? dr_misc_out[15:12] : 4'h0);
assign dr_15_12_oe = dr_gpu_oe | dr_vid_15_12_oe | dr_abus_oe | dr_ob_oe | dr_obdata_oe | dr_lbuf_oe | dr_misc_oe | dr_misc_15_12_oe;

// --- Compiler-generated local PE for BUS justify
assign justify_out = (justify_gpu_oe ? justify_gpu_out : 1'b0) | (justify_mem_oe ? justify_mem_out : 1'b0) | (justify_ob_oe ? justify_ob_out : 1'b0);
assign justify_oe = justify_gpu_oe | justify_mem_oe | justify_ob_oe;
endmodule

