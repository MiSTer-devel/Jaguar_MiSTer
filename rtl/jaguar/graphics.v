//`include "defs.v"
// altera message_off 10036

module _graphics
(
	input [15:0] ima,
	input [31:0] dwrite,
	input ack,
	input blit_back,
	input gpu_back,
	input reset_n,
	input clk,
	input tlw,
	input dint,
	input [3:2] gpu_irq,
	input iord,
	input iowr,
	input reset_lock,
	input [63:0] data,
	input at_1,
	output [1:0] blit_breq,
	output gpu_breq,
	output dma_breq,
	output cpu_int,
	output lock,
	output [63:0] wdata_out,
	output wdata_31_0_oe,
	output wdata_63_32_oe,
	output [23:0] a_out,
	output a_oe,
	input a_15_in,
	output [3:0] width_out,
	output width_oe,
	output read_out,
	output read_oe,
	input read_in,
	output mreq_out,
	output mreq_oe,
	input mreq_in,
	output [15:0] dr_out,
	output dr_oe,
	output justify_out,
	output justify_oe,
	input justify_in,
	input sys_clk // Generated
);
wire [3:0] width;
wire [15:0] io_addr;
wire [23:0] dataddr;
wire [23:0] gpu_addr;
wire [31:0] immdata;
wire [31:0] locsrc;
wire [31:0] result;
wire [31:0] srcd;
wire [31:0] srcdp;
wire [31:0] srcdpa;
wire [31:0] dstwd;
wire [31:0] srcwd;
wire [31:0] load_data;
wire [31:0] mem_data;
wire [31:0] quotient;
wire [31:0] dstdp;
wire [31:0] dstd;
wire [31:0] cpudata;
wire [2:0] alufunc;
wire [5:0] dstanwi;
wire [5:0] srcanwi;
wire [5:0] dstat;
wire [5:0] dsta;
wire [5:0] srca;
wire [21:0] progaddr;
wire [12:0] cpuaddr;
wire [15:0] dread_out;
wire dread_oe;
wire [23:0] address_out;
wire address_oe;
wire [31:0] gpu_data_out;
wire gpu_data_oe;
reg dintd = 1'b0;
wire [1:0] brlmux;
wire datreq;
wire datwe;
wire datwe_raw;
wire div_instr;
wire div_start;
wire dstdgate;
wire dstrrd;
wire dstrrdi;
wire dstrwr;
wire dstrwri;
wire dstwen;
wire exe;
wire flag_depend;
wire flagld;
wire immld;
wire immwri;
wire insexei;
wire locden;
wire macop;
wire memrw;
wire [1:0] msize;
wire mtx_dover;
wire multsel;
wire multsign;
wire pabort;
wire precomp;
wire progreq;
wire resld;
wire [2:0] ressel;
wire reswr;
wire rev_sub;
wire [1:0] satsz;
wire srcrrd;
wire single_stop;
wire big_instr;
wire carry_flag;
wire datack;
wire dbgrd;
wire div_activei;
wire external;
wire flagrd;
wire flagwr;
wire gate_active;
wire go;
wire mtxawr;
wire mtxcwr;
wire nega_flag;
wire pcrd;
wire pcwr;
wire progack;
wire resaddrldi;
wire sbwait;
wire sdatreq;
wire single_go;
wire single_step;
wire srcaddrldi;
wire statrd;
wire zero_flag;
wire dstrwen_n;
wire srcrwen_n;
wire del_xld;
wire xld_ready;
wire divwr;
wire remrd;
wire big_io;
wire big_pix;
wire bliten;
wire ctrlwr;
wire ctrlwrgo;
wire gateack;
wire gpu_memw;
wire hidrd;
wire hidwr;
wire progserv;
wire [11:2] ram_addr;
wire [1:0] ramen; // ramen[1] is jerry only
wire gatereq;
wire ioreq;
wire bus_hog;
wire [5:0] gpu_irq_;
assign gpu_irq_[3:2] = gpu_irq[3:2];
assign gpu_irq_[5] = 1'b0; // jerry only

wire [63:0] wdata_gateway_out; //69a0
wire wdata_gateway_31_0_oe;
wire wdata_gateway_63_32_oe;
wire [63:0] wdata_blit_out; //69a1
wire wdata_blit_oe;

wire [3:0] width_gateway_out; //133a0
wire width_gateway_oe;
wire [3:0] width_blit_out; //133a1
wire width_blit_oe;

wire read_gateway_out; //137a0
wire read_gateway_oe;
wire read_blit_out; //137a1
wire read_blit_oe;
wire mreq_gateway_out; //138a0
wire mreq_gateway_oe;
wire mreq_blit_out; //138a1
wire mreq_blit_oe;
wire justify_gateway_out; //139a0
wire justify_gateway_oe;
wire justify_blit_out; //139a1
wire justify_blit_oe;

wire [23:0] gateway_addr_out; //140a0
wire gateway_addr_oe; // Added by EA presumably to simplify;
wire [23:0] blit_addr_out; //140a1
wire blit_addr_oe; // Added by EA presumably to simplify;


wire [31:0] gpu_data_ins_exec_out; //164a0
wire gpu_data_ins_exec_oe;
wire [31:0] gpu_data_divider_out;
wire gpu_data_divider_oe;
wire [31:0] gpu_data_mem_out;
wire gpu_data_mem_oe;
wire [31:0] gpu_data_ram_out;
wire gpu_data_ram_oe;
wire [31:0] gpu_data_gateway_out;
wire gpu_data_gateway_oe;

wire [31:3] gpu_dout_ins_out; // 15 is not used // 199a0
wire gpu_dout_ins_14_3_oe; //flagrd
wire gpu_dout_ins_10_6_oe; //statrd
wire gpu_dout_ins_31_16_oe; //flagrd | statrd
wire [2:0] gpu_dout_arith_out;                  //196a0
wire gpu_dout_arith_2_0_oe; //flagrd
wire [15:0] gpu_dout_ctrl_out; // 6-10 is not used
wire gpu_dout_ctrl_5_0_oe; //statrd
wire gpu_dout_ctrl_15_11_oe; //statrd
wire gpu_dout_gateway_15_out;
wire gpu_dout_gateway_15_oe; //flagrd
wire [31:0] gpu_dout_blit_out;
wire gpu_dout_blit_oe;

wire [31:0] gpu_dout_out; //164a5
wire gpu_dout_2_0_oe;   //flagrd | statrd | gpu_dout_blit_oe
wire gpu_dout_5_3_oe;   //flagrd | statrd | gpu_dout_blit_oe
wire gpu_dout_10_6_oe;  //flagrd | statrd | gpu_dout_blit_oe
wire gpu_dout_14_11_oe; //flagrd | statrd | gpu_dout_blit_oe
wire gpu_dout_15_oe;    //flagrd | statrd | gpu_dout_blit_oe
wire gpu_dout_31_16_oe; //flagrd | statrd | gpu_dout_blit_oe
wire gpu_dout_oe = gpu_dout_2_0_oe;   // if any are oe, all are oe

// GRAPHICS.NET (70) - io_addr : join
assign io_addr[15:0] = ima[15:0];

// GRAPHICS.NET (71) - dr[0-15] : join_bus
assign dr_out[15:0] = dread_out[15:0];
assign dr_oe = dread_oe;

// GRAPHICS.NET (75) - a[0-23] : join_bus
assign a_out[23:0] = address_out[23:0];
assign a_oe = address_oe;

// GRAPHICS.NET (79) - dintd : fd1
reg old_clk;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	if (~old_clk && clk) begin
		dintd <= dint;
	end
end

// GRAPHICS.NET (81) - gpu_irq[1] : an2
assign gpu_irq_[1] = dint & ~dintd;

// GRAPHICS.NET (103) - ins_exec : ins_exec
_ins_exec #(.JERRY(0)) ins_exec_inst
(
	.gpu_data_out /* BUS */ (gpu_data_ins_exec_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_ins_exec_oe),
	.gpu_data_in /* BUS */ (gpu_data_out[31:0]),
	.gpu_dout_out /* BUS */ (gpu_dout_ins_out[31:3]), //15 not used
	.gpu_dout_14_3_oe /* BUS */ (gpu_dout_ins_14_3_oe),
	.gpu_dout_10_6_oe /* BUS */ (gpu_dout_ins_10_6_oe),
	.gpu_dout_31_16_oe /* BUS */ (gpu_dout_ins_31_16_oe),
	.alufunc /* OUT */ (alufunc[2:0]),
	.brlmux /* OUT */ (brlmux[1:0]),
	.dataddr /* OUT */ (dataddr[23:0]),
	.datreq /* OUT */ (datreq),
	.datweb /* OUT */ (datwe),
	.datwe_raw /* OUT */ (datwe_raw),
	.div_instr /* OUT */ (div_instr),
	.div_start /* OUT */ (div_start),
	.dstanwi /* OUT */ (dstanwi[5:0]),
	.dstat /* OUT */ (dstat[5:0]),
	.dstdgate /* OUT */ (dstdgate),
	.dstrrd /* OUT */ (dstrrd),
	.dstrrdi /* OUT */ (dstrrdi),
	.dstrwr /* OUT */ (dstrwr),
	.dstrwri /* OUT */ (dstrwri),
	.dstwen /* OUT */ (dstwen),
	.exe /* OUT */ (exe),
	.flag_depend /* OUT */ (flag_depend),
	.flagld /* OUT */ (flagld),
	.immdata /* OUT */ (immdata[31:0]),
	.immld /* OUT */ (immld),
	.immwri /* OUT */ (immwri),
	.insexei /* OUT */ (insexei),
	.locden /* OUT */ (locden),
	.locsrc /* OUT */ (locsrc[31:0]),
	.macop /* OUT */ (macop),
	.memrw /* OUT */ (memrw),
	.msize /* OUT */ (msize[1:0]),
	.mtx_dover /* OUT */ (mtx_dover),
	.multsel /* OUT */ (multsel),
	.multsign /* OUT */ (multsign),
	.pabort /* OUT */ (pabort),
	.precomp /* OUT */ (precomp),
	.progaddr /* OUT */ (progaddr[21:0]),
	.progreq /* OUT */ (progreq),
	.resld /* OUT */ (resld),
	.ressel /* OUT */ (ressel[2:0]),
	.reswr /* OUT */ (reswr),
	.rev_sub /* OUT */ (rev_sub),
	.satsz /* OUT */ (satsz[1:0]),
	.srcrrd /* OUT */ (srcrrd),
	.single_stop /* OUT */ (single_stop),
	.srcanwi /* OUT */ (srcanwi[5:0]),
	.big_instr /* IN */ (big_instr),
	.carry_flag /* IN */ (carry_flag),
	.clk /* IN */ (clk),
	.clkb /* IN */ (clk),
	.tlw /* IN */ (tlw),
	.datack /* IN */ (datack),
	.dbgrd /* IN */ (dbgrd),
	.div_activei /* IN */ (div_activei),
	.external /* IN */ (external),
	.flagrd /* IN */ (flagrd),
	.flagwr /* IN */ (flagwr),
	.gate_active /* IN */ (gate_active),
	.go /* IN */ (go),
	.gpu_din /* IN */ (gpu_data_out[31:0]),
	.gpu_irq /* IN */ (gpu_irq_[5:0]),
	.mtxawr /* IN */ (mtxawr),
	.mtxcwr /* IN */ (mtxcwr),
	.nega_flag /* IN */ (nega_flag),
	.pcrd /* IN */ (pcrd),
	.pcwr /* IN */ (pcwr),
	.progack /* IN */ (progack),
	.resaddrldi /* IN */ (resaddrldi),
	.reset_n /* IN */ (reset_n),
	.result /* IN */ (result[31:0]),
	.sbwait /* IN */ (sbwait),
	.sdatreq /* IN */ (sdatreq),
	.single_go /* IN */ (single_go),
	.single_step /* IN */ (single_step),
	.srcaddrldi /* IN */ (srcaddrldi),
	.srcd /* IN */ (srcd[31:0]),
	.srcdp /* IN */ (srcdp[31:0]),
	.srcdpa /* IN */ (srcdpa[31:0]),
	.statrd /* IN */ (statrd),
	.zero_flag /* IN */ (zero_flag),
	.sys_clk(sys_clk) // Generated
);

// GRAPHICS.NET (125) - sboard : sboard
_sboard sboard_inst
(
	.dsta /* OUT */ (dsta[5:0]),
	.sdatreq /* OUT */ (sdatreq),
	.dstrwen_n /* OUT */ (dstrwen_n),
	.dstwd /* OUT */ (dstwd[31:0]),
	.resaddrldi /* OUT */ (resaddrldi),
	.sbwait /* OUT */ (sbwait),
	.srca /* OUT */ (srca[5:0]),
	.srcaddrldi /* OUT */ (srcaddrldi),
	.srcrwen_n /* OUT */ (srcrwen_n),
	.srcwd /* OUT */ (srcwd[31:0]),
	.clk /* IN */ (clk),
	.datack /* IN */ (datack),
	.datwe /* IN */ (datwe),
	.datwe_raw /* IN */ (datwe_raw),
	.del_xld /* IN */ (del_xld),
	.div_activei /* IN */ (div_activei),
	.div_instr /* IN */ (div_instr),
	.div_start /* IN */ (div_start),
	.dstanwi /* IN */ (dstanwi[5:0]),
	.dstat /* IN */ (dstat[5:0]),
	.dstrrd /* IN */ (dstrrd),
	.dstrrdi /* IN */ (dstrrdi),
	.dstrwr /* IN */ (dstrwr),
	.dstrwri /* IN */ (dstrwri),
	.dstwen /* IN */ (dstwen),
	.exe /* IN */ (exe),
	.flag_depend /* IN */ (flag_depend),
	.flagld /* IN */ (flagld),
	.gate_active /* IN */ (gate_active),
	.immdata /* IN */ (immdata[31:0]),
	.immld /* IN */ (immld),
	.immwri /* IN */ (immwri),
	.insexei /* IN */ (insexei),
	.load_data /* IN */ (load_data[31:0]),
	.mem_data /* IN */ (mem_data[31:0]),
	.memrw /* IN */ (memrw),
	.mtx_dover /* IN */ (mtx_dover),
	.precomp /* IN */ (precomp),
	.quotient /* IN */ (quotient[31:0]),
	.reset_n /* IN */ (reset_n),
	.reswr /* IN */ (reswr),
	.result /* IN */ (result[31:0]),
	.srcanwi /* IN */ (srcanwi[5:0]),
	.srcdp /* IN */ (srcdp[31:0]),
	.srcrrd /* IN */ (srcrrd),
	.xld_ready /* IN */ (xld_ready),
	.sys_clk(sys_clk) // Generated
);

// GRAPHICS.NET (140) - arith : arith
_arith #(.JERRY(0)) arith_inst
(
	.gpu_dout_out /* BUS */ (gpu_dout_arith_out[2:0]),
	.gpu_dout_oe /* BUS */ (gpu_dout_arith_2_0_oe),
	.carry_flag /* OUT */ (carry_flag),
	.nega_flag /* OUT */ (nega_flag),
	.result /* OUT */ (result[31:0]),
	.zero_flag /* OUT */ (zero_flag),
	.accumrd /* IN */ (1'b0), // jerry only
	.dstdp /* IN */ (dstdp[31:0]),
	.srcdp /* IN */ (srcdp[31:0]),
	.srcd_31 /* IN */ (srcd[31]),
	.alufunc /* IN */ (alufunc[2:0]),
	.brlmux /* IN */ (brlmux[1:0]),
	.clk /* IN */ (clk),
	.flagld /* IN */ (flagld),
	.flagrd /* IN */ (flagrd),
	.flagwr /* IN */ (flagwr),
	.gpu_din /* IN */ (gpu_data_out[31:0]),
	.macop /* IN */ (macop),
	.modulowr /* IN */ (1'b0), // jerry only
	.multsel /* IN */ (multsel),
	.multsign /* IN */ (multsign),
	.reset_n /* IN */ (reset_n),
	.resld /* IN */ (resld),
	.ressel /* IN */ (ressel[2:0]),
	.rev_sub /* IN */ (rev_sub),
	.satsz /* IN */ (satsz[1:0]),
	.sys_clk(sys_clk) // Generated
);

// GRAPHICS.NET (149) - divide : divider
_divider divide_inst
(
	.gpu_data_out /* BUS */ (gpu_data_divider_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_divider_oe),
	.div_activei /* OUT */ (div_activei),
	.quotient /* OUT */ (quotient[31:0]),
	.clk /* IN */ (clk),
	.div_start /* IN */ (div_start),
	.divwr /* IN */ (divwr),
	.dstd /* IN */ (dstd[31:0]),
	.gpu_din /* IN */ (gpu_data_out[31:0]),
	.remrd /* IN */ (remrd),
	.reset_n /* IN */ (reset_n),
	.srcd /* IN */ (srcd[31:0]),
	.sys_clk(sys_clk) // Generated
);

// GRAPHICS.NET (155) - registers : registers
_registers registers_inst
(
	.srcd /* OUT */ (srcd[31:0]),
	.srcdp /* OUT */ (srcdp[31:0]),
	.srcdpa /* OUT */ (srcdpa[31:0]),
	.dstd /* OUT */ (dstd[31:0]),
	.dstdp /* OUT */ (dstdp[31:0]),
	.clk /* IN */ (clk),
	.dsta /* IN */ (dsta[5:0]),
	.dstrwen_n /* IN */ (dstrwen_n),
	.dstwd /* IN */ (dstwd[31:0]),
	.exe /* IN */ (exe),
	.locden /* IN */ (locden),
	.locsrc /* IN */ (locsrc[31:0]),
	.mem_data /* IN */ (mem_data[31:0]),
	.mtx_dover /* IN */ (mtx_dover),
	.srca /* IN */ (srca[5:0]),
	.srcrwen_n /* IN */ (srcrwen_n),
	.srcwd /* IN */ (srcwd[31:0]),
	.sys_clk(sys_clk) // Generated
);

// GRAPHICS.NET (162) - gpu_mem : gpu_mem
_gpu_mem gpu_mem_inst
(
	.gpu_data_out /* BUS */ (gpu_data_mem_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_mem_oe),
	.big_instr /* OUT */ (big_instr),
	.big_io /* OUT */ (big_io),
	.big_pix /* OUT */ (big_pix),
	.bliten /* OUT */ (bliten),
	.ctrlwr /* OUT */ (ctrlwr),
	.ctrlwrgo /* OUT */ (ctrlwrgo),
	.datack /* OUT */ (datack),
	.dbgrd /* OUT */ (dbgrd),
	.del_xld /* OUT */ (del_xld),
	.divwr /* OUT */ (divwr),
	.externalb /* OUT */ (external),
	.flagrd /* OUT */ (flagrd),
	.flagwr /* OUT */ (flagwr),
	.gateack /* OUT */ (gateack),
	.gpu_addr /* OUT */ (gpu_addr[23:0]),
	.gpu_memw /* OUT */ (gpu_memw),
	.hidrd /* OUT */ (hidrd),
	.hidwr /* OUT */ (hidwr),
	.lock /* OUT */ (lock),
	.mem_data /* OUT */ (mem_data[31:0]),
	.mtxawr /* OUT */ (mtxawr),
	.mtxcwr /* OUT */ (mtxcwr),
	.pcrd /* OUT */ (pcrd),
	.pcwr /* OUT */ (pcwr),
	.progack /* OUT */ (progack),
	.progserv /* OUT */ (progserv),
	.ram_addr /* OUT */ (ram_addr[11:2]),
	.ramen /* OUT */ (ramen[1:0]),
	.remrd /* OUT */ (remrd),
	.statrd /* OUT */ (statrd),
	.clk /* IN */ (clk),
	.cpuaddr /* IN */ (cpuaddr[12:0]),
	.cpudata /* IN */ (cpudata[31:0]),
	.dataddr /* IN */ (dataddr[23:0]),
	.dstd /* IN */ (dstd[31:0]),
	.dstdgate /* IN */ (dstdgate),
	.datreq /* IN */ (datreq),
	.datwe /* IN */ (datwe),
	.gatereq /* IN */ (gatereq),
	.go /* IN */ (go),
	.gpu_din /* IN */ (gpu_data_out[31:0]),
	.ioreq /* IN */ (ioreq),
	.iowr /* IN */ (iowr),
	.pabort /* IN */ (pabort),
	.progaddr /* IN */ (progaddr[21:0]),
	.progreq /* IN */ (progreq),
	.reset_n /* IN */ (reset_n),
	.reset_lock /* IN */ (reset_lock),
	.sys_clk(sys_clk) // Generated
);

// GRAPHICS.NET (176) - gpu_ctrl : gpu_ctrl
_gpu_ctrl gpu_ctrl_inst
(
	.gpu_dout_out /* BUS */ (gpu_dout_ctrl_out[15:0]),
	.gpu_dout_5_0_oe /* BUS */ (gpu_dout_ctrl_5_0_oe), 
	.gpu_dout_15_11_oe /* BUS */ (gpu_dout_ctrl_15_11_oe),
	.bus_hog /* OUT */ (bus_hog),
	.cpu_int /* OUT */ (cpu_int),
	.go /* OUT */ (go),
	.gpu_irq_0 /* OUT */ (gpu_irq_[0]),
	.single_go /* OUT */ (single_go),
	.single_step /* OUT */ (single_step),
	.clk /* IN */ (clk),
	.ctrlwr /* IN */ (ctrlwr),
	.ctrlwrgo /* IN */ (ctrlwrgo),
	.gpu_din /* IN */ (gpu_data_out[31:0]),
	.reset_n /* IN */ (reset_n),
	.single_stop /* IN */ (single_stop),
	.statrd /* IN */ (statrd),
	.sys_clk(sys_clk) // Generated
);

// GRAPHICS.NET (184) - gpu_ram : gpu_ram
_gpu_ram gpu_ram_inst
(
	.gpu_data_out /* BUS */ (gpu_data_ram_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_ram_oe),
	.gpu_data_in /* BUS */ (gpu_data_out[31:0]),
	.clk /* IN */ (clk),
	.gpu_memw /* IN */ (gpu_memw),
	.ram_addr /* IN */ (ram_addr[11:2]),
	.ramen /* IN */ (ramen[0]),
	.sys_clk(sys_clk) // Generated
);

// GRAPHICS.NET (189) - gpu_cpu : gpu_cpu
_gpu_cpu #(.JERRY(0)) gpu_cpu_inst
(
	.dread_out /* BUS */ (dread_out[15:0]),
	.dread_oe /* BUS */ (dread_oe),
	.cpuaddr /* OUT */ (cpuaddr[12:0]),
	.cpudata /* OUT */ (cpudata[31:0]),
	.ioreq /* OUT */ (ioreq),
	.at_1 /* IN */ (at_1),
	.a_15 /* IN */ (a_15_in),
	.ack /* IN */ (ack),
	.big_io /* IN */ (big_io),
	.clk_0 /* IN */ (clk),
	.clk_2 /* IN */ (tlw),
	.dwrite /* IN */ (dwrite[31:0]),
	.io_addr /* IN */ (io_addr[15:0]),
	.iord /* IN */ (iord),
	.iowr /* IN */ (iowr),
	.mem_data /* IN */ (mem_data[31:0]),
	.reset_n /* IN */ (reset_n),
	.sys_clk(sys_clk) // Generated
);

// GRAPHICS.NET (195) - gateway : gateway
_gateway #(.JERRY(0)) gateway_inst
(
	.address_out /* BUS */ (gateway_addr_out[23:0]),
	.address_oe /* BUS */ (gateway_addr_oe),
	.wdata_out /* BUS */ (wdata_gateway_out[63:0]),
	.wdata_31_0_oe /* BUS */ (wdata_gateway_31_0_oe),
	.wdata_63_32_oe /* BUS */ (wdata_gateway_63_32_oe),
	.gpu_data_out /* BUS */ (gpu_data_gateway_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_gateway_oe),
	.justify_out /* BUS */ (justify_gateway_out),
	.justify_oe /* BUS */ (justify_gateway_oe),
	.mreq_out /* BUS */ (mreq_gateway_out),
	.mreq_oe /* BUS */ (mreq_gateway_oe),
	.read_out /* BUS */ (read_gateway_out),
	.read_oe /* BUS */ (read_gateway_oe),
	.width_out /* BUS */ (width_gateway_out[3:0]),
	.width_oe /* BUS */ (width_gateway_oe),
	.gpu_dout_15_out /* BUS */ (gpu_dout_gateway_15_out),
	.gpu_dout_15_oe /* BUS */ (gpu_dout_gateway_15_oe),
	.dma_breq /* OUT */ (dma_breq),
	.gate_active /* OUT */ (gate_active),
	.gatereq /* OUT */ (gatereq),
	.gpu_breq /* OUT */ (gpu_breq),
	.load_data /* OUT */ (load_data[31:0]),
	.xld_ready /* OUT */ (xld_ready),
	.ack /* IN */ (ack),
	.bus_hog /* IN */ (bus_hog),
	.clk_0 /* IN */ (clk),
	.clk_2 /* IN */ (tlw),
	.data /* IN */ (data[63:0]),
	.external /* IN */ (external),
	.flagrd /* IN */ (flagrd),
	.flagwr /* IN */ (flagwr),
	.gateack /* IN */ (gateack),
	.gpu_addr /* IN */ (gpu_addr[23:0]),
	.gpu_back /* IN */ (gpu_back),
	.gpu_din /* IN */ (gpu_data_out[31:0]),
	.gpu_memw /* IN */ (gpu_memw),
	.hidrd /* IN */ (hidrd),
	.hidwr /* IN */ (hidwr),
	.msize /* IN */ (msize[1:0]),
	.progserv /* IN */ (progserv),
	.reset_n /* IN */ (reset_n),
	.sys_clk(sys_clk) // Generated
);

// GRAPHICS.NET (205) - blit : blit
_blit blit_inst
(
	.blit_addr_out /* BUS */ (blit_addr_out[23:0]),
	.blit_addr_oe /* BUS */ (blit_addr_oe),	// ElectronAsh.
	.wdata_out /* BUS */ (wdata_blit_out[63:0]),
	.wdata_oe /* BUS */ (wdata_blit_oe),
	.justify_out /* BUS */ (justify_blit_out),
	.justify_oe /* BUS */ (justify_blit_oe),
	.justify_in /* BUS */ (justify_in),
	.mreq_out /* BUS */ (mreq_blit_out),
	.mreq_oe /* BUS */ (mreq_blit_oe),
	.mreq_in /* BUS */ (mreq_in),
	.read_out /* BUS */ (read_blit_out),
	.read_oe /* BUS */ (read_blit_oe),
	.read_in /* BUS */ (read_in),
	.width_out /* BUS */ (width_blit_out[3:0]),
	.width_oe /* BUS */ (width_blit_oe),
	.gpu_dout_out /* BUS */ (gpu_dout_blit_out[31:0]),
	.gpu_dout_oe /* BUS */ (gpu_dout_blit_oe),
	.blit_breq /* OUT */ (blit_breq[1:0]),
	.blit_int /* OUT */ (gpu_irq_[4]),
	.ack /* IN */ (ack),
	.big_pix /* IN */ (big_pix),
	.blit_back /* IN */ (blit_back),
	.bliten /* IN */ (bliten),
	.clk /* IN */ (clk),
	.tlw /* IN */ (tlw),
	.data /* IN */ (data[63:0]),
	.gpu_addr /* IN */ (gpu_addr[23:0]),
	.gpu_din /* IN */ (gpu_data_out[31:0]),
	.gpu_memw /* IN */ (gpu_memw),
	.xreset_n /* IN */ (reset_n),
	.sys_clk(sys_clk) // Generated
);

// --- Compiler-generated PE for BUS wdata[0]
assign wdata_out[31:0] = (wdata_blit_oe ? wdata_blit_out[31:0]:32'h0) | ((wdata_gateway_31_0_oe ? wdata_gateway_out[31:0]:32'h0));
assign wdata_31_0_oe = wdata_blit_oe | wdata_gateway_31_0_oe;
assign wdata_out[63:32] = (wdata_blit_oe ? wdata_blit_out[63:32]:32'h0) | ((wdata_gateway_63_32_oe ? wdata_gateway_out[63:32]:32'h0));
assign wdata_63_32_oe = wdata_blit_oe | wdata_gateway_63_32_oe;

// --- Compiler-generated PE for BUS width[0]
assign width_out[3:0] = (width_blit_oe ? width_blit_out[3:0]:4'h0) | (width_gateway_oe ? width_gateway_out[3:0]:4'h0);
assign width_oe = width_blit_oe | width_gateway_oe;

// --- Compiler-generated PE for BUS read
assign read_out = (read_gateway_oe & read_gateway_out ) | (read_blit_oe & read_blit_out );
assign read_oe = read_gateway_oe | read_blit_oe;

// --- Compiler-generated PE for BUS mreq
assign mreq_out = (mreq_gateway_oe & mreq_gateway_out ) | (mreq_blit_oe & mreq_blit_out );
assign mreq_oe = mreq_gateway_oe | mreq_blit_oe;

// --- Compiler-generated PE for BUS justify
assign justify_out = (justify_gateway_oe & justify_gateway_out ) | (justify_blit_oe & justify_blit_out );
assign justify_oe = justify_gateway_oe | justify_blit_oe;

// --- Compiler-generated local PE for BUS address<0>
assign address_out[23:0] = (gateway_addr_oe ? gateway_addr_out[23:0] : blit_addr_out[23:0]);
assign address_oe = gateway_addr_oe | blit_addr_oe;

// --- Compiler-generated local PE for BUS gpu_data<0>
// Ternaries/muxes are better than stacking ors; assumes no bus conflicts
assign gpu_data_out[31:0] = gpu_data_ins_exec_oe ? gpu_data_ins_exec_out[31:0]:
                           gpu_data_divider_oe ? gpu_data_divider_out[31:0] :
                           gpu_data_mem_oe ? gpu_data_mem_out[31:0] :
                           gpu_data_ram_oe ? gpu_data_ram_out[31:0] :
                           gpu_data_gateway_oe ? gpu_data_gateway_out[31:0] :
                           (gpu_dout_oe ? gpu_dout_out[31:0] :32'h0);
assign gpu_data_oe = gpu_data_ins_exec_oe | gpu_data_divider_oe | gpu_data_mem_oe | gpu_data_ram_oe | gpu_data_gateway_oe | gpu_dout_oe;

// --- Compiler-generated local PE for BUS gpu_dout[0]
assign gpu_dout_out[2:0] = (gpu_dout_arith_2_0_oe ? gpu_dout_arith_out[2:0] : 3'h0) | (gpu_dout_ctrl_5_0_oe ? gpu_dout_ctrl_out[2:0] : 3'h0) | (gpu_dout_blit_oe ? gpu_dout_blit_out[2:0] : 3'h0);
assign gpu_dout_2_0_oe = gpu_dout_arith_2_0_oe | gpu_dout_ctrl_5_0_oe | gpu_dout_blit_oe;

assign gpu_dout_out[5:3] = (gpu_dout_ins_14_3_oe ? gpu_dout_ins_out[5:3] : 3'h0) | (gpu_dout_ctrl_5_0_oe ? gpu_dout_ctrl_out[5:3] : 3'h0) | (gpu_dout_blit_oe ? gpu_dout_blit_out[5:3] : 3'h0);
assign gpu_dout_5_3_oe = gpu_dout_ins_14_3_oe | gpu_dout_ctrl_5_0_oe | gpu_dout_blit_oe;

assign gpu_dout_out[10:6] = ((gpu_dout_ins_14_3_oe | gpu_dout_ins_10_6_oe) ? gpu_dout_ins_out[10:6] : 5'h0) | (gpu_dout_blit_oe ? gpu_dout_blit_out[10:6] : 5'h0);
assign gpu_dout_10_6_oe = gpu_dout_ins_14_3_oe | gpu_dout_ins_10_6_oe | gpu_dout_blit_oe;

assign gpu_dout_out[14:11] = (gpu_dout_ins_14_3_oe ? gpu_dout_ins_out[14:11] : 4'h0) | (gpu_dout_ctrl_15_11_oe ? gpu_dout_ctrl_out[14:11] : 4'h0) | (gpu_dout_blit_oe ? gpu_dout_blit_out[14:11] : 4'h0);
assign gpu_dout_14_11_oe = gpu_dout_ins_14_3_oe | gpu_dout_ctrl_15_11_oe | gpu_dout_blit_oe;

assign gpu_dout_out[15] = (gpu_dout_ctrl_15_11_oe ? gpu_dout_ctrl_out[15] : 1'h0) | (gpu_dout_gateway_15_oe ? gpu_dout_gateway_15_out : 1'h0) | (gpu_dout_blit_oe ? gpu_dout_blit_out[15] : 1'h0);
assign gpu_dout_15_oe = gpu_dout_ctrl_15_11_oe | gpu_dout_gateway_15_oe | gpu_dout_blit_oe;

assign gpu_dout_out[31:16] = (gpu_dout_ins_31_16_oe ? gpu_dout_ins_out[31:16] : 16'h0) | (gpu_dout_blit_oe ? gpu_dout_blit_out[31:16] : 16'h0);
assign gpu_dout_31_16_oe = gpu_dout_ins_31_16_oe | gpu_dout_blit_oe;

endmodule
