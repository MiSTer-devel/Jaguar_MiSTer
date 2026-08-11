//`include "defs.v"

module _state
(
	output [23:0] blit_addr_out,
	output blit_addr_oe,	// ElectronAsh.
	output justify_out,
	output justify_oe,
	input justify_in,
	output mreq_out,
	output mreq_oe,
	input mreq_in,
	output [3:0] width_out,
	output width_oe,
	output read_out,
	output read_oe,
	input read_in,
	output [31:0] gpu_dout_out,
	output gpu_dout_oe,
	output a1fracldi,
	output a1ptrldi,
	output a2ptrldi,
	output [2:0] addasel,
	output [1:0] addbsel,
	output addqsel,
	output [2:0] adda_xconst,
	output adda_yconst,
	output addareg,
	output apipe,
	output [1:0] blit_breq,
	output blit_int,
	output cmpdst,
	output [2:0] daddasel,
	output [2:0] daddbsel,
	output [2:0] daddmode,
	output data_ena,
	output [1:0] data_sel,
	output [7:0] dbinh_n,
	output [5:0] dend,
	output [1:0] dpipe,
	output [5:0] dstart,
	output dstdread,
	output dstzread,
	output gena2,
	output [3:0] lfu_func,
	output daddq_sel,
	output [2:0] modx,
	output patdadd,
	output patfadd,
	output phrase_mode,
	output reset_n,
	output srcdread,
	output [5:0] srcshift,
	output srcz1add,
	output srcz2add,
	output srczread,
	output suba_x,
	output suba_y,
	output zaddr,
	output [2:0] zmode,
	output [1:0] zpipe,
	input a1_outside,
	input [2:0] a1_pixsize,
	input [14:0] a1_win_x,
	input [15:0] a1_x,
	input [1:0] a1addx,
	input a1addy,
	input a1xsign,
	input a1ysign,
	input [2:0] a2_pixsize,
	input [15:0] a2_x,
	input [1:0] a2addx,
	input a2addy,
	input a2xsign,
	input a2ysign,
	input ack,
	input [23:0] address,
	input big_pix,
	input blit_back,
	input clk,
	input cmdld,
	input countld,
	input [7:0] dcomp,
	input [31:0] gpu_din,
	input [2:0] pixa,
	input [7:0] srcd,
	input statrd,
	input stopld,
	input xreset_n,
	input [3:0] zcomp,
	input sys_clk // Generated
);
wire [15:0] dstxp;
reg bcompen = 1'b0;
reg dcompen = 1'b0;
reg bkgwren = 1'b0;
reg srcshade = 1'b0;
wire blit_idle;
wire inhibent;
wire inhiben;
wire [1:0] atick;
wire aticki_0;
wire dest_cycle_1;
wire dsta_addi;
wire dwrite;
wire dwrite_1;
wire dzwrite;
wire dzwrite1;
wire [2:0] icount;
wire indone;
wire inner0;
wire readreq;
wire srca_addi;
wire srcdreadd;
wire srcen;
wire sread_1;
wire sreadx_1;
wire step_inner;
wire writereq;
wire blitack;
wire dsta2;
wire gourd;
wire gourz;
wire instart;
wire memidle;
wire memready;
wire nowrite;
wire [2:0] pixsize;
wire read_ack;
wire wactive;
wire a1updatei;
wire a1fupdatei;
wire a2updatei;
wire sshftld;
wire active;
wire stopped;
wire phrase_cycle;
wire [3:0] pwidth;

// Output buffers
wire [1:0] blit_breq_obuf;
wire phrase_mode_obuf;
wire reset_n_obuf;
reg [2:0] zmode_obuf = 3'h0;
reg [3:0] lfu_func_ = 4'h0;
reg cmpdst_ = 1'b0;

//wire resetl = reset_n;
reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// Output buffers
assign blit_breq[1:0] = blit_breq_obuf[1:0];
assign phrase_mode = phrase_mode_obuf;
assign reset_n = reset_n_obuf;
assign zmode[2:0] = zmode_obuf[2:0];
assign lfu_func[3:0] = lfu_func_[3:0];
assign cmpdst = cmpdst_;

// STATE.NET (103) - zmode[0-2] : fdsync
// STATE.NET (105) - lfu_func[0-3] : fdsyncu
// STATE.NET (107) - cmpdst : fdsync
// STATE.NET (108) - bcompent : fdsync
// STATE.NET (110) - dcompent : fdsync
// STATE.NET (112) - bkgwren : fdsync
// STATE.NET (113) - srcshade : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (cmdld) begin
			zmode_obuf[2:0] <= gpu_din[20:18];
			lfu_func_[3:0] <= gpu_din[24:21];
			cmpdst_ <= gpu_din[25];
			bcompen <= gpu_din[26];
			dcompen <= gpu_din[27];
			bkgwren <= gpu_din[28];
			srcshade <= gpu_din[30];
		end
	end
end

// STATE.NET (117) - blit_idle : nr3
assign blit_idle = ~(|blit_breq_obuf[1:0] | blit_back);

// STATE.NET (118) - stat[0] : ts
assign gpu_dout_out[0] = blit_idle;
assign gpu_dout_oe = statrd; // statrd for all in this file

// STATE.NET (122) - inhibent : nr5
assign inhibent = ~(|zmode_obuf[2:0] | bcompen | dcompen);

// STATE.NET (123) - inhiben : nr3
assign inhiben = ~(inhibent | phrase_mode_obuf | bkgwren);

// STATE.NET (127) - inner : inner
_inner inner_inst
(
	.gpu_dout_10_2_out /* BUS */ (gpu_dout_out[10:2]),
//	.gpu_dout_10_2_oe /* BUS */ (gpu_dout_10_2_oe), = statrd; already handled
	.gpu_dout_31_16_out /* BUS */ (gpu_dout_out[31:16]),
//	.gpu_dout_31_16_oe /* BUS */ (gpu_dout_31_16_oe), = statrd; already handled
	.apipe /* OUT */ (apipe),
	.atick /* OUT */ (atick[1:0]),
	.aticki_0 /* OUT */ (aticki_0),
	.data_ena /* OUT */ (data_ena),
	.dest_cycle_1 /* OUT */ (dest_cycle_1),
	.dpipe /* OUT */ (dpipe[1:0]),
	.dsta_addi /* OUT */ (dsta_addi),
	.dstdread /* OUT */ (dstdread),
	.dstzread /* OUT */ (dstzread),
	.dwrite /* OUT */ (dwrite),
	.dwrite1 /* OUT */ (dwrite_1),
	.dzwrite /* OUT */ (dzwrite),
	.dzwrite1 /* OUT */ (dzwrite1),
	.gena2 /* OUT */ (gena2),
	.icount /* OUT */ (icount[2:0]),
	.indone /* OUT */ (indone),
	.inner0 /* OUT */ (inner0),
	.readreq /* OUT */ (readreq),
	.srca_addi /* OUT */ (srca_addi),
	.srcdread /* OUT */ (srcdread),
	.srcdreadd /* OUT */ (srcdreadd),
	.srcen /* OUT */ (srcen),
	.srczread /* OUT */ (srczread),
	.sread_1 /* OUT */ (sread_1),
	.sreadx_1 /* OUT */ (sreadx_1),
	.step /* OUT */ (step_inner),
	.writereq /* OUT */ (writereq),
	.zaddr /* OUT */ (zaddr),
	.zpipe /* OUT */ (zpipe[1:0]),
	.a1_outside /* IN */ (a1_outside),
	.blitack /* IN */ (blitack),
	.clk /* IN */ (clk),
	.cmdld /* IN */ (cmdld),
	.countld /* IN */ (countld),
	.dsta2 /* IN */ (dsta2),
	.dstxp /* IN */ (dstxp[15:0]),
	.gourd /* IN */ (gourd),
	.gourz /* IN */ (gourz),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.inhiben /* IN */ (inhiben),
	.instart /* IN */ (instart),
	.memidle /* IN */ (memidle),
	.memready /* IN */ (memready),
	.nowrite /* IN */ (nowrite),
	.phrase_mode /* IN */ (phrase_mode_obuf),
	.pixsize /* IN */ (pixsize[2:0]),
	.read_ack /* IN */ (read_ack),
	.reset_n /* IN */ (reset_n_obuf),
	.srcshade /* IN */ (srcshade),
	.statrd /* IN */ (statrd),
	.wactive /* IN */ (wactive),
	.sys_clk(sys_clk) // Generated
);

// STATE.NET (143) - outer : outer
_outer outer_inst
(
	.gpu_dout_out /* BUS */ (gpu_dout_out[15:11]),
//	.gpu_dout_15_11_oe /* BUS */ (gpu_dout_15_11_oe), = statrd; already handled
	.a1updatei /* OUT */ (a1updatei),
	.a1fupdatei /* OUT */ (a1fupdatei),
	.a2updatei /* OUT */ (a2updatei),
	.blit_breq /* OUT */ (blit_breq_obuf[1:0]),
	.blit_int /* OUT */ (blit_int),
	.instart /* OUT */ (instart),
	.sshftld /* OUT */ (sshftld),
	.active /* IN */ (active),
	.clk /* IN */ (clk),
	.cmdld /* IN */ (cmdld),
	.countld /* IN */ (countld),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.indone /* IN */ (indone),
	.reset_n /* IN */ (reset_n_obuf),
	.statrd /* IN */ (statrd),
	.stopped /* IN */ (stopped),
	.sys_clk(sys_clk) // Generated
);

// STATE.NET (151) - mcontrol : mcontrol
_mcontrol mcontrol_inst
(
	.blit_addr_out /* BUS */ (blit_addr_out[23:0]),
	.blit_addr_oe /* BUS */ (blit_addr_oe),	// ElectronAsh.
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
	.active /* OUT */ (active),
	.blitack /* OUT */ (blitack),
	.memidle /* OUT */ (memidle),
	.memready /* OUT */ (memready),
	.read_ack /* OUT */ (read_ack),
	.wactive /* OUT */ (wactive),
	.ack /* IN */ (ack),
	.address /* IN */ (address[23:0]),
	.bcompen /* IN */ (bcompen),
	.blit_back /* IN */ (blit_back),
	.clk /* IN */ (clk),
	.phrase_cycle /* IN */ (phrase_cycle),
	.phrase_mode /* IN */ (phrase_mode_obuf),
	.pixsize /* IN */ (pixsize[2:0]),
	.pwidth /* IN */ (pwidth[3:0]),
	.readreq /* IN */ (readreq),
	.reset_n /* IN */ (reset_n_obuf),
	.sread_1 /* IN */ (sread_1),
	.sreadx_1 /* IN */ (sreadx_1),
	.step_inner /* IN */ (step_inner),
	.writereq /* IN */ (writereq),
	.sys_clk(sys_clk) // Generated
);

// STATE.NET (159) - acontrol : acontrol
_acontrol acontrol_inst
(
	.addasel /* OUT */ (addasel[2:0]),
	.addbsel /* OUT */ (addbsel[1:0]),
	.addqsel /* OUT */ (addqsel),
	.adda_xconst /* OUT */ (adda_xconst[2:0]),
	.adda_yconst /* OUT */ (adda_yconst),
	.addareg /* OUT */ (addareg),
	.a1fracldi /* OUT */ (a1fracldi),
	.a1ptrldi /* OUT */ (a1ptrldi),
	.a2ptrldi /* OUT */ (a2ptrldi),
	.dend /* OUT */ (dend[5:0]),
	.dsta2 /* OUT */ (dsta2),
	.dstart /* OUT */ (dstart[5:0]),
	.dstxp /* OUT */ (dstxp[15:0]),
	.modx /* OUT */ (modx[2:0]),
	.phrase_cycle /* OUT */ (phrase_cycle),
	.phrase_mode /* OUT */ (phrase_mode_obuf),
	.pixsize /* OUT */ (pixsize[2:0]),
	.pwidth /* OUT */ (pwidth[3:0]),
	.srcshift /* OUT */ (srcshift[5:0]),
	.suba_x /* OUT */ (suba_x),
	.suba_y /* OUT */ (suba_y),
	.a1_pixsize /* IN */ (a1_pixsize[2:0]),
	.a1_win_x /* IN */ (a1_win_x[14:0]),
	.a1_x /* IN */ (a1_x[15:0]),
	.a1addx /* IN */ (a1addx[1:0]),
	.a1addy /* IN */ (a1addy),
	.a1xsign /* IN */ (a1xsign),
	.a1ysign /* IN */ (a1ysign),
	.a1updatei /* IN */ (a1updatei),
	.a1fupdatei /* IN */ (a1fupdatei),
	.a2_pixsize /* IN */ (a2_pixsize[2:0]),
	.a2_x /* IN */ (a2_x[15:0]),
	.a2addx /* IN */ (a2addx[1:0]),
	.a2addy /* IN */ (a2addy),
	.a2xsign /* IN */ (a2xsign),
	.a2ysign /* IN */ (a2ysign),
	.a2updatei /* IN */ (a2updatei),
	.atick /* IN */ (atick[1:0]),
	.aticki_0 /* IN */ (aticki_0),
	.bcompen /* IN */ (bcompen),
	.clk /* IN */ (clk),
	.cmdld /* IN */ (cmdld),
	.dest_cycle_1 /* IN */ (dest_cycle_1),
	.dsta_addi /* IN */ (dsta_addi),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.icount /* IN */ (icount[2:0]),
	.inner0 /* IN */ (inner0),
	.pixa /* IN */ (pixa[2:0]),
	.srca_addi /* IN */ (srca_addi),
	.srcen /* IN */ (srcen),
	.sshftld /* IN */ (sshftld),
	.step_inner /* IN */ (step_inner),
	.sys_clk(sys_clk) // Generated
);

// STATE.NET (178) - dcontrol : dcontrol
_dcontrol dcontrol_inst
(
	.daddasel /* OUT */ (daddasel[2:0]),
	.daddbsel /* OUT */ (daddbsel[2:0]),
	.daddmode /* OUT */ (daddmode[2:0]),
	.data_sel /* OUT */ (data_sel[1:0]),
	.daddq_sel /* OUT */ (daddq_sel),
	.gourd /* OUT */ (gourd),
	.gourz /* OUT */ (gourz),
	.patdadd /* OUT */ (patdadd),
	.patfadd /* OUT */ (patfadd),
	.srcz1add /* OUT */ (srcz1add),
	.srcz2add /* OUT */ (srcz2add),
	.atick /* IN */ (atick[1:0]),
	.clk /* IN */ (clk),
	.cmdld /* IN */ (cmdld),
	.dwrite /* IN */ (dwrite),
	.dzwrite /* IN */ (dzwrite),
	.dzwrite1 /* IN */ (dzwrite1),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.srcdreadd /* IN */ (srcdreadd),
	.srcshade /* IN */ (srcshade),
	.sys_clk(sys_clk) // Generated
);

// STATE.NET (187) - comp_ctrl : comp_ctrl
_comp_ctrl comp_ctrl_inst
(
	.dbinh_n /* OUT */ (dbinh_n[7:0]),
	.nowrite /* OUT */ (nowrite),
	.bcompen /* IN */ (bcompen),
	.big_pix /* IN */ (big_pix),
	.bkgwren /* IN */ (bkgwren),
	.clk /* IN */ (clk),
	.dcomp /* IN */ (dcomp[7:0]),
	.dcompen /* IN */ (dcompen),
	.icount /* IN */ (icount[2:0]),
	.pixsize /* IN */ (pixsize[2:0]),
	.phrase_mode /* IN */ (phrase_mode_obuf),
	.srcd /* IN */ (srcd[7:0]),
	.step_inner /* IN */ (step_inner),
	.zcomp /* IN */ (zcomp[3:0]),
	.sys_clk(sys_clk) // Generated
);

// STATE.NET (195) - blitstop : blitstop
_blitstop blitstop_inst
(
	.gpu_dout_1_out /* BUS */ (gpu_dout_out[1]),
//	.gpu_dout_1_oe /* BUS */ (gpu_dout_1_oe), = statrd; already handled
	.stopped /* OUT */ (stopped),
	.reset_n /* OUT */ (reset_n_obuf),
	.clk /* IN */ (clk),
	.dwrite_1 /* IN */ (dwrite_1),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.nowrite /* IN */ (nowrite),
	.statrd /* IN */ (statrd),
	.stopld /* IN */ (stopld),
	.xreset_n /* IN */ (xreset_n),
	.sys_clk(sys_clk) // Generated
);
endmodule

