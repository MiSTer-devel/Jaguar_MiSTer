//`include "defs.v"

module _blit
(
	output [23:0] blit_addr_out,
	output blit_addr_oe,		// ElectronAsh.
	output [63:0] wdata_out,
	output wdata_oe,
	output justify_out,
	output justify_oe,
	input justify_in,
	output mreq_out,
	output mreq_oe,
	input mreq_in,
	output read_out,
	output read_oe,
	input read_in,
	output [3:0] width_out,
	output width_oe,
	output [31:0] gpu_dout_out,
	output gpu_dout_oe,
	output [1:0] blit_breq,
	output blit_int,
	input ack,
	input big_pix,
	input blit_back,
	input bliten,
	input clk,
	input tlw,
	input [63:0] data,
	input [23:0] gpu_addr,
	input [31:0] gpu_din,
	input gpu_memw,
	input xreset_n,
	input sys_clk // Generated
);
wire [23:0] address;
wire [14:0] a1_win_x;
wire [15:0] a1_x;
wire [15:0] a2_x;
wire loadstrt;
wire load_strobe;
wire [7:0] dcomp;
wire [7:0] srcd;
wire [3:0] zcomp;
wire cmpdst;
wire [2:0] daddasel;
wire [2:0] daddbsel;
wire [2:0] daddmode;
wire daddq_sel;
wire data_ena;
wire [1:0] data_sel;
wire [7:0] dbinh_n;
wire [5:0] dend;
wire [1:0] dpipe;
wire [5:0] dstart;
wire [1:0] dstdld;
wire [1:0] dstzld;
wire iincld;
wire [3:0] intld;
wire [3:0] lfu_func;
wire [1:0] patdld;
wire phrase_mode;
wire reset_n;
wire [1:0] srcd1ld;
wire srcdread;
wire srczread;
wire [5:0] srcshift;
wire [1:0] srcz1ld;
wire srcz2add;
wire [1:0] srcz2ld;
wire [3:0] zedld;
wire zincld;
wire [2:0] zmode;
wire [1:0] zpipe;
wire a1_outside;
wire [2:0] a1_pixsize;
wire [1:0] a1addx;
wire a1addy;
wire a1xsign;
wire a1ysign;
wire [2:0] a2_pixsize;
wire [1:0] a2addx;
wire a2addy;
wire a2xsign;
wire a2ysign;
wire [2:0] pixa;
wire [2:0] addasel;
wire [1:0] addbsel;
wire addqsel;
wire [2:0] adda_xconst;
wire adda_yconst;
wire addareg;
wire a1baseld;
wire a1flagld;
wire a1fracld;
wire a1incld;
wire a1incfld;
wire a1posrd;
wire a1posfrd;
wire a1ptrld;
wire a1stepld;
wire a1stepfld;
wire a1winld;
wire a2baseld;
wire a2flagld;
wire a2posrd;
wire a2ptrld;
wire a2stepld;
wire a2winld;
wire apipe;
wire gena2;
wire [2:0] modx;
wire suba_x;
wire suba_y;
wire zaddr;
wire a1fracldi;
wire a1ptrldi;
wire a2ptrldi;
wire dstdread;
wire dstzread;
wire patdadd;
wire patfadd;
wire srcz1add;
wire cmdld;
wire countld;
wire statrd;
wire stopld;

wire [31:0] gpu_dout_address_out;
wire gpu_dout_address_oe;
wire [31:0] gpu_dout_state_out;
wire gpu_dout_state_oe;

// BLIT.NET (50) - loadstrt : niv
assign loadstrt = tlw;

// BLIT.NET (51) - load_strobe : nivu
assign load_strobe = loadstrt;

// BLIT.NET (59) - data : data
_data data_inst
(
	.wdata_out /* BUS */ (wdata_out[63:0]),
	.wdata_oe /* BUS */ (wdata_oe),
	.dcomp /* OUT */ (dcomp[7:0]),
	.srcd /* OUT */ (srcd[7:0]),
	.zcomp /* OUT */ (zcomp[3:0]),
	.big_pix /* IN */ (big_pix),
	.blit_back /* IN */ (blit_back),
	.blit_breq /* IN */ (blit_breq[1:0]),
	.clk /* IN */ (clk),
	.clk2 /* IN */ (tlw),
	.cmpdst /* IN */ (cmpdst),
	.daddasel /* IN */ (daddasel[2:0]),
	.daddbsel /* IN */ (daddbsel[2:0]),
	.daddmode /* IN */ (daddmode[2:0]),
	.daddq_sel /* IN */ (daddq_sel),
	.data /* IN */ (data[63:0]),
	.data_ena /* IN */ (data_ena),
	.data_sel /* IN */ (data_sel[1:0]),
	.dbinh_n /* IN */ (dbinh_n[7:0]),
	.dend /* IN */ (dend[5:0]),
	.dpipe /* IN */ (dpipe[1:0]),
	.dstart /* IN */ (dstart[5:0]),
	.dstdld /* IN */ (dstdld[1:0]),
	.dstzld /* IN */ (dstzld[1:0]),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.iincld /* IN */ (iincld),
	.intld /* IN */ (intld[3:0]),
	.lfu_func /* IN */ (lfu_func[3:0]),
	.load_strobe /* IN */ (load_strobe),
	.patdld /* IN */ (patdld[1:0]),
	.phrase_mode /* IN */ (phrase_mode),
	.reset_n /* IN */ (reset_n),
	.srcd1ld /* IN */ (srcd1ld[1:0]),
	.srcdread /* IN */ (srcdread),
	.srczread /* IN */ (srczread),
	.srcshift /* IN */ (srcshift[5:0]),
	.srcz1ld /* IN */ (srcz1ld[1:0]),
	.srcz2add /* IN */ (srcz2add),
	.srcz2ld /* IN */ (srcz2ld[1:0]),
	.zedld /* IN */ (zedld[3:0]),
	.zincld /* IN */ (zincld),
	.zmode /* IN */ (zmode[2:0]),
	.zpipe /* IN */ (zpipe[1:0]),
	.sys_clk(sys_clk) // Generated
);

// BLIT.NET (74) - address : address
_address address_inst
(
	.gpu_dout_out /* BUS */ (gpu_dout_address_out[31:0]),
	.gpu_dout_oe /* BUS */ (gpu_dout_address_oe),
	.a1_outside /* OUT */ (a1_outside),
	.a1_pixsize /* OUT */ (a1_pixsize[2:0]),
	.a1_win_x /* OUT */ (a1_win_x[14:0]),
	.a1_x /* OUT */ (a1_x[15:0]),
	.a1addx /* OUT */ (a1addx[1:0]),
	.a1addy /* OUT */ (a1addy),
	.a1xsign /* OUT */ (a1xsign),
	.a1ysign /* OUT */ (a1ysign),
	.a2_pixsize /* OUT */ (a2_pixsize[2:0]),
	.a2_x /* OUT */ (a2_x[15:0]),
	.a2addx /* OUT */ (a2addx[1:0]),
	.a2addy /* OUT */ (a2addy),
	.a2xsign /* OUT */ (a2xsign),
	.a2ysign /* OUT */ (a2ysign),
	.address /* OUT */ (address[23:0]),
	.pixa /* OUT */ (pixa[2:0]),
	.addasel /* IN */ (addasel[2:0]),
	.addbsel /* IN */ (addbsel[1:0]),
	.addqsel /* IN */ (addqsel),
	.adda_xconst /* IN */ (adda_xconst[2:0]),
	.adda_yconst /* IN */ (adda_yconst),
	.addareg /* IN */ (addareg),
	.a1baseld /* IN */ (a1baseld),
	.a1flagld /* IN */ (a1flagld),
	.a1fracld /* IN */ (a1fracld),
	.a1incld /* IN */ (a1incld),
	.a1incfld /* IN */ (a1incfld),
	.a1posrd /* IN */ (a1posrd),
	.a1posfrd /* IN */ (a1posfrd),
	.a1ptrld /* IN */ (a1ptrld),
	.a1stepld /* IN */ (a1stepld),
	.a1stepfld /* IN */ (a1stepfld),
	.a1winld /* IN */ (a1winld),
	.a2baseld /* IN */ (a2baseld),
	.a2flagld /* IN */ (a2flagld),
	.a2posrd /* IN */ (a2posrd),
	.a2ptrld /* IN */ (a2ptrld),
	.a2stepld /* IN */ (a2stepld),
	.a2winld /* IN */ (a2winld),
	.apipe /* IN */ (apipe),
	.clk /* IN */ (clk),
	.gena2 /* IN */ (gena2),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.load_strobe /* IN */ (load_strobe),
	.modx /* IN */ (modx[2:0]),
	.suba_x /* IN */ (suba_x),
	.suba_y /* IN */ (suba_y),
	.zaddr /* IN */ (zaddr),
	.sys_clk(sys_clk) // Generated
);

// BLIT.NET (89) - state : state
_state state_inst
(
	.blit_addr_out /* BUS */ (blit_addr_out[23:0]),
	.blit_addr_oe /* BUS */ (blit_addr_oe),
	.justify_out /* BUS */ (justify_out),
	.justify_oe /* BUS */ (justify_oe),
	.justify_in /* BUS */ (justify_in),
	.mreq_out /* BUS */ (mreq_out),
	.mreq_oe /* BUS */ (mreq_oe),
	.mreq_in /* BUS */ (mreq_in),
	.width_out /* BUS */ (width_out[3:0]),
	.width_oe /* BUS */ (width_oe),
	.read_out /* BUS */ (read_out),
	.read_oe /* BUS */ (read_oe),
	.read_in /* BUS */ (read_in),
	.gpu_dout_out /* BUS */ (gpu_dout_state_out[31:0]),
	.gpu_dout_oe /* BUS */ (gpu_dout_state_oe),
	.a1fracldi /* OUT */ (a1fracldi),
	.a1ptrldi /* OUT */ (a1ptrldi),
	.a2ptrldi /* OUT */ (a2ptrldi),
	.addasel /* OUT */ (addasel[2:0]),
	.addbsel /* OUT */ (addbsel[1:0]),
	.addqsel /* OUT */ (addqsel),
	.adda_xconst /* OUT */ (adda_xconst[2:0]),
	.adda_yconst /* OUT */ (adda_yconst),
	.addareg /* OUT */ (addareg),
	.apipe /* OUT */ (apipe),
	.blit_breq /* OUT */ (blit_breq[1:0]),
	.blit_int /* OUT */ (blit_int),
	.cmpdst /* OUT */ (cmpdst),
	.daddasel /* OUT */ (daddasel[2:0]),
	.daddbsel /* OUT */ (daddbsel[2:0]),
	.daddmode /* OUT */ (daddmode[2:0]),
	.data_ena /* OUT */ (data_ena),
	.data_sel /* OUT */ (data_sel[1:0]),
	.dbinh_n /* OUT */ (dbinh_n[7:0]),
	.dend /* OUT */ (dend[5:0]),
	.dpipe /* OUT */ (dpipe[1:0]),
	.dstart /* OUT */ (dstart[5:0]),
	.dstdread /* OUT */ (dstdread),
	.dstzread /* OUT */ (dstzread),
	.gena2 /* OUT */ (gena2),
	.lfu_func /* OUT */ (lfu_func[3:0]),
	.daddq_sel /* OUT */ (daddq_sel),
	.modx /* OUT */ (modx[2:0]),
	.patdadd /* OUT */ (patdadd),
	.patfadd /* OUT */ (patfadd),
	.phrase_mode /* OUT */ (phrase_mode),
	.reset_n /* OUT */ (reset_n),
	.srcdread /* OUT */ (srcdread),
	.srcshift /* OUT */ (srcshift[5:0]),
	.srcz1add /* OUT */ (srcz1add),
	.srcz2add /* OUT */ (srcz2add),
	.srczread /* OUT */ (srczread),
	.suba_x /* OUT */ (suba_x),
	.suba_y /* OUT */ (suba_y),
	.zaddr /* OUT */ (zaddr),
	.zmode /* OUT */ (zmode[2:0]),
	.zpipe /* OUT */ (zpipe[1:0]),
	.a1_outside /* IN */ (a1_outside),
	.a1_pixsize /* IN */ (a1_pixsize[2:0]),
	.a1_win_x /* IN */ (a1_win_x[14:0]),
	.a1_x /* IN */ (a1_x[15:0]),
	.a1addx /* IN */ (a1addx[1:0]),
	.a1addy /* IN */ (a1addy),
	.a1xsign /* IN */ (a1xsign),
	.a1ysign /* IN */ (a1ysign),
	.a2_pixsize /* IN */ (a2_pixsize[2:0]),
	.a2_x /* IN */ (a2_x[15:0]),
	.a2addx /* IN */ (a2addx[1:0]),
	.a2addy /* IN */ (a2addy),
	.a2xsign /* IN */ (a2xsign),
	.a2ysign /* IN */ (a2ysign),
	.ack /* IN */ (ack),
	.address /* IN */ (address[23:0]),
	.big_pix /* IN */ (big_pix),
	.blit_back /* IN */ (blit_back),
	.clk /* IN */ (clk),
	.cmdld /* IN */ (cmdld),
	.countld /* IN */ (countld),
	.dcomp /* IN */ (dcomp[7:0]),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.pixa /* IN */ (pixa[2:0]),
	.srcd /* IN */ (srcd[7:0]),
	.statrd /* IN */ (statrd),
	.stopld /* IN */ (stopld),
	.xreset_n /* IN */ (xreset_n),
	.zcomp /* IN */ (zcomp[3:0]),
	.sys_clk(sys_clk) // Generated
);

// BLIT.NET (111) - blitgpu : blitgpu
_blitgpu blitgpu_inst
(
	.a1baseld /* OUT */ (a1baseld),
	.a1flagld /* OUT */ (a1flagld),
	.a1fracld /* OUT */ (a1fracld),
	.a1incld /* OUT */ (a1incld),
	.a1incfld /* OUT */ (a1incfld),
	.a1posrd /* OUT */ (a1posrd),
	.a1posfrd /* OUT */ (a1posfrd),
	.a1ptrld /* OUT */ (a1ptrld),
	.a1stepld /* OUT */ (a1stepld),
	.a1stepfld /* OUT */ (a1stepfld),
	.a1winld /* OUT */ (a1winld),
	.a2baseld /* OUT */ (a2baseld),
	.a2flagld /* OUT */ (a2flagld),
	.a2posrd /* OUT */ (a2posrd),
	.a2ptrld /* OUT */ (a2ptrld),
	.a2stepld /* OUT */ (a2stepld),
	.a2winld /* OUT */ (a2winld),
	.cmdld /* OUT */ (cmdld),
	.countld /* OUT */ (countld),
	.dstdld /* OUT */ (dstdld[1:0]),
	.dstzld /* OUT */ (dstzld[1:0]),
	.iincld /* OUT */ (iincld),
	.intld /* OUT */ (intld[3:0]),
	.patdld /* OUT */ (patdld[1:0]),
	.srcd1ld /* OUT */ (srcd1ld[1:0]),
	.srcz1ld /* OUT */ (srcz1ld[1:0]),
	.srcz2ld /* OUT */ (srcz2ld[1:0]),
	.statrd /* OUT */ (statrd),
	.stopld /* OUT */ (stopld),
	.zedld /* OUT */ (zedld[3:0]),
	.zincld /* OUT */ (zincld),
	.a1fracldi /* IN */ (a1fracldi),
	.a1ptrldi /* IN */ (a1ptrldi),
	.a2ptrldi /* IN */ (a2ptrldi),
	.blit_back /* IN */ (blit_back),
	.bliten /* IN */ (bliten),
	.dstdread /* IN */ (dstdread),
	.dstzread /* IN */ (dstzread),
	.gpu_addr /* IN */ (gpu_addr[23:0]),
	.gpu_memw /* IN */ (gpu_memw),
	.patdadd /* IN */ (patdadd),
	.patfadd /* IN */ (patfadd),
	.srcdread /* IN */ (srcdread),
	.srcz1add /* IN */ (srcz1add),
	.srczread /* IN */ (srczread)
);

// --- Compiler-generated PE for BUS gpu_dout[0]
assign gpu_dout_out = (gpu_dout_address_oe ? gpu_dout_address_out[31:0] : 32'h0) | (gpu_dout_state_oe ? gpu_dout_state_out[31:0] : 32'h0);
assign gpu_dout_oe = gpu_dout_address_oe | gpu_dout_state_oe;

endmodule

