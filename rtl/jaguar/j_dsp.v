/* verilator lint_off LITENDIAN */
//`include "defs.v"

module _j_dsp
(
	input [15:0] ima,
	input [31:0] dout,
	input tlw_a,
	input tlw_b,
	input tlw_c,
	input ack,
	input gpu_back,
	input reset_n,
	input clk,
	input [1:0] eint_n,
	input [1:0] tint,
	input i2int,
	input iord,
	input iowr,
	input tlw,
	output gpu_breq,
	output dma_breq,
	output cpu_int,
	output [31:0] wdata,
	output [23:0] a,
	output [2:0] width,
	output read,
	output mreq,
	output [1:0] dacw,
	output [15:0] gpu_din,
	output i2sw_0,
	output i2sw_1,
	output i2sw_2,
	output i2sw_3,
	output i2sr_0,
	output i2sr_1,
	output i2sr_2,
	output [15:0] dr_out,
	output dr_oe,
	output [15:0] gpu_dout_o_out,
	output gpu_dout_o_oe,
	input [15:0] gpu_dout_o_in,
	input sys_clk // Generated
);
wire [15:0] io_addr;
wire [31:0] gpu_din_;
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
wire [23:0] address;
wire [15:0] dread_out;
wire dread_oe;
wire [31:0] gpu_data_out;
wire gpu_data_oe;
wire [31:0] gpu_data_in;
wire [31:0] gpu_dout_out;
wire gpu_dout_oe;
wire [31:0] gpu_dout_in;
wire tlw_0;
wire tlw_1;
wire tlw_2;
reg [1:0] eints_n = 2'h0;
wire [1:0] eints;
reg [1:0] eintd_n = 2'h0;
wire [5:0] gpu_irq;
wire i2int_n;
reg i2intd_n = 1'b0;
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
wire accumrd;
wire modulowr;
wire divwr;
wire remrd;
wire big_io;
wire ctrlwr;
wire gateack;
wire gpu_memw;
wire progserv;
wire [11:2] ram_addr;
wire [1:0] ramen;
wire romen;
wire gatereq;
wire ioreq;
wire bus_hog;
wire [3:0] i2sw;
wire [2:0] i2sr;
assign {i2sw_3, i2sw_2, i2sw_1, i2sw_0} = i2sw[3:0];
assign {i2sr_2, i2sr_1, i2sr_0} = i2sr[2:0];

wire [31:0] gpu_data_ins_out; //39a0
wire gpu_data_ins_oe;
wire [31:0] gpu_data_arith_out; //39a1
wire gpu_data_arith_oe;
wire [31:0] gpu_data_div_out; //39a2
wire gpu_data_div_oe;
wire [31:0] gpu_data_mem_out; //39a3
wire gpu_data_mem_oe;
wire [31:0] gpu_data_ram_out; //39a4
wire gpu_data_ram_oe;
wire [31:0] gpu_data_gate_out; //39a5
wire gpu_data_gate_oe;
wire [31:0] gpu_data_bits_out; //39a6
wire gpu_data_bits_oe;

wire [31:0] gpu_dout_ins_out; //74a0(71)
wire gpu_dout_ins_14_3_oe;
wire gpu_dout_ins_10_6_oe;
wire gpu_dout_ins_31_16_oe;
wire [2:0] gpu_dout_arith_out; //71a0
wire gpu_dout_arith_oe;
wire [31:16] gpu_dout_mem_out; //71a1
//wire gpu_dout_mem_15_0_oe; // This doesnt really exist. should pass through when gpu_dout_mem_31_16_oe == 1
wire gpu_dout_mem_31_16_oe;
wire [15:0] gpu_dout_ctrl_out; //71a2
wire gpu_dout_ctrl_5_0_oe;
wire gpu_dout_ctrl_15_11_oe;
wire gpu_dout_gate_15_out; //86a2
wire gpu_dout_gate_15_oe;

reg old_clk;
always @(posedge sys_clk)
begin
	old_clk <= clk;
end

// DSP.NET (75) - tlw[0-2] : nivu
assign tlw_0 = tlw_a;
assign tlw_1 = tlw_b;
assign tlw_2 = tlw_c;

// DSP.NET (77) - io_addr : join
assign io_addr[15:0] = ima[15:0];

// DSP.NET (78) - dr[0-15] : join_bus
assign dr_out[15:0] = dread_out[15:0];
assign dr_oe = dread_oe;

// DSP.NET (80) - a[0-23] : join
assign a[23:0] = address[23:0];

// DSP.NET (81) - gpu_din[0-15] : join
assign gpu_din[15:0] = gpu_din_[15:0];

// DSP.NET (83) - wddrv[0-31] : join
assign wdata[31:0] = load_data[31:0];

// DSP.NET (88) - eints[0-1] : fd1
// DSP.NET (89) - eintd[0-1] : fd1q
// DSP.NET (97) - i2intd\ : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		eints_n[1:0] <= eint_n[1:0];
		eintd_n[1:0] <= eints_n[1:0];
		i2intd_n <= i2int_n;
	end
end
assign eints[1:0] = ~eints_n[1:0];

// DSP.NET (90) - gpu_irq[4-5] : an2
assign gpu_irq[5:4] = eints[1:0] & eintd_n[1:0];

// DSP.NET (93) - gpu_irq[2-3] : join
assign gpu_irq[3:2] = tint[1:0];

// DSP.NET (96) - i2int\ : iv
assign i2int_n = ~i2int;

// DSP.NET (98) - gpu_irq[1] : an2
assign gpu_irq[1] = i2int & i2intd_n;

// DSP.NET (102) - ins_exec : dsp_exec
_ins_exec #(.JERRY(1)) ins_exec_inst
(
	.gpu_data_out /* BUS */ (gpu_data_ins_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_ins_oe),
	.gpu_data_in /* BUS */ (gpu_data_in[31:0]),
	.gpu_dout_out /* BUS */ (gpu_dout_ins_out[31:3]),
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
	.tlw /* IN */ (tlw_0),
	.datack /* IN */ (datack),
	.dbgrd /* IN */ (dbgrd),
	.div_activei /* IN */ (div_activei),
	.external /* IN */ (external),
	.flagrd /* IN */ (flagrd),
	.flagwr /* IN */ (flagwr),
	.gate_active /* IN */ (gate_active),
	.go /* IN */ (go),
	.gpu_din /* IN */ (gpu_din_[31:0]),
	.gpu_irq /* IN */ (gpu_irq[5:0]),
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

// DSP.NET (124) - sboard : sboard
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

// DSP.NET (139) - arith : dsp_arith
_arith #(.JERRY(1)) arith_inst
(
	.gpu_data_out /* BUS */ (gpu_data_arith_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_arith_oe),
	.gpu_dout_out /* BUS */ (gpu_dout_arith_out[2:0]),
	.gpu_dout_oe /* BUS */ (gpu_dout_arith_oe),
	.carry_flag /* OUT */ (carry_flag),
	.nega_flag /* OUT */ (nega_flag),
	.result /* OUT */ (result[31:0]),
	.zero_flag /* OUT */ (zero_flag),
	.accumrd /* IN */ (accumrd),
	.dstdp /* IN */ (dstdp[31:0]),
	.srcdp /* IN */ (srcdp[31:0]),
	.srcd_31 /* IN */ (srcd[31]),
	.alufunc /* IN */ (alufunc[2:0]),
	.brlmux /* IN */ (brlmux[1:0]),
	.clk /* IN */ (clk),
	.flagld /* IN */ (flagld),
	.flagrd /* IN */ (flagrd),
	.flagwr /* IN */ (flagwr),
	.gpu_din /* IN */ (gpu_din_[31:0]),
	.macop /* IN */ (macop),
	.modulowr /* IN */ (modulowr),
	.multsel /* IN */ (multsel),
	.multsign /* IN */ (multsign),
	.reset_n /* IN */ (reset_n),
	.resld /* IN */ (resld),
	.ressel /* IN */ (ressel[2:0]),
	.rev_sub /* IN */ (rev_sub),
	.satsz /* IN */ (satsz[1:0]), // satsz[1] isnt used
	.sys_clk(sys_clk) // Generated
);

// DSP.NET (148) - divide : divide
_divider divide_inst
(
	.gpu_data_out /* BUS */ (gpu_data_div_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_div_oe),
	.div_activei /* OUT */ (div_activei),
	.quotient /* OUT */ (quotient[31:0]),
	.clk /* IN */ (clk),
	.div_start /* IN */ (div_start),
	.divwr /* IN */ (divwr),
	.dstd /* IN */ (dstd[31:0]),
	.gpu_din /* IN */ (gpu_din_[31:0]),
	.remrd /* IN */ (remrd),
	.reset_n /* IN */ (reset_n),
	.srcd /* IN */ (srcd[31:0]),
	.sys_clk(sys_clk) // Generated
);

// DSP.NET (154) - registers : registers
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

// DSP.NET (161) - dsp_mem : dsp_mem
_gpu_mem #(.JERRY(1)) dsp_mem_inst
(
	.gpu_data_out /* BUS */ (gpu_data_mem_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_mem_oe),
	.gpu_dout_out /* BUS */ (gpu_dout_mem_out[31:16]),
//	.gpu_dout_15_0_oe /* BUS */ (gpu_dout_mem_15_0_oe),
	.gpu_dout_31_16_oe /* BUS */ (gpu_dout_mem_31_16_oe),
	.accumrd /* OUT */ (accumrd),
	.big_instr /* OUT */ (big_instr),
	.big_io /* OUT */ (big_io),
	.ctrlwr /* OUT */ (ctrlwr),
	.dacw /* OUT */ (dacw[1:0]),
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
	.i2sr /* OUT */ (i2sr[2:0]),
	.i2sw /* OUT */ (i2sw[3:0]),
	.mem_data /* OUT */ (mem_data[31:0]),
	.modulowr /* OUT */ (modulowr),
	.mtxawr /* OUT */ (mtxawr),
	.mtxcwr /* OUT */ (mtxcwr),
	.pcrd /* OUT */ (pcrd),
	.pcwr /* OUT */ (pcwr),
	.progack /* OUT */ (progack),
	.progserv /* OUT */ (progserv),
	.ram_addr /* OUT */ (ram_addr[11:2]),
	.ramen /* OUT */ (ramen[1:0]),
	.remrd /* OUT */ (remrd),
	.romen /* OUT */ (romen),
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
	.gpu_din /* IN */ (gpu_din_[31:0]),
	.ioreq /* IN */ (ioreq),
	.iowr /* IN */ (iowr),
	.pabort /* IN */ (pabort),
	.progaddr /* IN */ (progaddr[21:0]),
	.progreq /* IN */ (progreq),
	.reset_n /* IN */ (reset_n),
	.sys_clk(sys_clk) // Generated
);

// DSP.NET (174) - dsp_ctrl : dsp_ctrl
_gpu_ctrl dsp_ctrl_inst
(
	.gpu_dout_out /* BUS */ (gpu_dout_ctrl_out[15:0]),
	.gpu_dout_5_0_oe /* BUS */ (gpu_dout_ctrl_5_0_oe),
	.gpu_dout_15_11_oe /* BUS */ (gpu_dout_ctrl_15_11_oe),
	.bus_hog /* OUT */ (bus_hog),
	.cpu_int /* OUT */ (cpu_int),
	.go /* OUT */ (go),
	.gpu_irq_0 /* OUT */ (gpu_irq[0]),
	.single_go /* OUT */ (single_go),
	.single_step /* OUT */ (single_step),
	.clk /* IN */ (clk),
	.ctrlwr /* IN */ (ctrlwr),
	.ctrlwrgo /* IN */ (ctrlwr), //tom only; set to ctrlwr
	.gpu_din /* IN */ (gpu_din_[31:0]),
	.reset_n /* IN */ (reset_n),
	.single_stop /* IN */ (single_stop),
	.statrd /* IN */ (statrd),
	.sys_clk(sys_clk) // Generated
);

// DSP.NET (182) - dsp_ram : dsp_ram
_j_dsp_ram dsp_ram_inst
(
	.gpu_data_out /* BUS */ (gpu_data_ram_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_ram_oe),
	.gpu_data_in /* BUS */ (gpu_data_in[31:0]),
	.clk /* IN */ (clk),
	.gpu_memw /* IN */ (gpu_memw),
	.ram_addr /* IN */ (ram_addr[11:2]),
	.ramen /* IN */ (ramen[1:0]),
	.romen /* IN */ (romen),
	.sys_clk(sys_clk) // Generated
);

// DSP.NET (187) - dsp_slave : dsp_slave
_gpu_cpu #(.JERRY(1)) dsp_slave_inst
(
	.dread_out /* BUS */ (dread_out[15:0]),
	.dread_oe /* BUS */ (dread_oe),
	.cpuaddr /* OUT */ (cpuaddr[12:0]),
	.cpudata /* OUT */ (cpudata[31:0]),
	.at_1 /* IN */ (1'b0),
	.a_15 /* IN */ (1'b0),
	.ack /* IN */ (1'b0),
	.ioreq /* OUT */ (ioreq),
	.big_io /* IN */ (big_io),
	.clk_0 /* IN */ (clk),
	.clk_2 /* IN */ (tlw_1),
	.dwrite /* IN */ ({16'h0,dout[15:0]}),
	.io_addr /* IN */ (io_addr[15:0]),
	.iord /* IN */ (iord),
	.iowr /* IN */ (iowr),
	.mem_data /* IN */ (mem_data[31:0]),
	.reset_n /* IN */ (reset_n),
	.sys_clk(sys_clk) // Generated
);

wire dummy;
// DSP.NET (193) - gateway : dsp_gate
_gateway #(.JERRY(1)) gateway_inst
(
	.gpu_data_out /* BUS */ (gpu_data_gate_out[31:0]),
	.gpu_data_oe /* BUS */ (gpu_data_gate_oe),
//	.gpu_data_in /* BUS */ (gpu_data_in[31:0]),
	.gpu_dout_15_out /* BUS */ (gpu_dout_gate_15_out),
	.gpu_dout_15_oe /* BUS */ (gpu_dout_gate_15_oe),
	.address_out /* OUT */ (address[23:0]),
	.mreq_out /* OUT */ (mreq),
	.read_out /* OUT */ (read),
	.width_out /* OUT */ ({dummy,width[2:0]}),
	.dma_breq_n /* OUT */ (dma_breq),
	.gate_active /* OUT */ (gate_active),
	.gatereq /* OUT */ (gatereq),
	.gpu_breq_n /* OUT */ (gpu_breq),
	.load_data /* OUT */ (load_data[31:0]),
	.xld_ready /* OUT */ (xld_ready),
	.ack /* IN */ (ack),
	.bus_hog /* IN */ (bus_hog),
	.clk_0 /* IN */ (clk),
	.clk_2 /* IN */ (tlw_2),
	.data /* IN */ ({32'h0,dout[31:0]}),
	.external /* IN */ (external),
	.flagrd /* IN */ (flagrd),
	.flagwr /* IN */ (flagwr),
	.gateack /* IN */ (gateack),
	.gpu_addr /* IN */ (gpu_addr[23:0]),
	.gpu_back /* IN */ (~gpu_back), //signal is inverted from above and opposite of tom
	.gpu_din /* IN */ (gpu_din_[31:0]),
	.gpu_memw /* IN */ (gpu_memw),
	.msize /* IN */ (msize[1:0]),
	.progserv /* IN */ (progserv),
	.reset_n /* IN */ (reset_n),
	.sys_clk(sys_clk) // Generated
);

//wire [31:0] gpu_data_bits_out; //39a6
//wire gpu_data_bits_oe;//gpu_dout_out
// DSP.NET (203) - gpu_dout : join_bus
assign gpu_data_bits_out[31:0] = gpu_dout_out[31:0];
assign gpu_data_bits_oe = gpu_dout_oe;

// DSP.NET (207) - gpu_din : nivh
assign gpu_din_[31:0] = gpu_data_in[31:0];

// DSP.NET (210) - ge : join_bus
assign gpu_dout_o_out[15:0] = gpu_data_out[15:0];
assign gpu_dout_o_oe = gpu_data_oe;
assign gpu_data_in[15:0] = gpu_dout_o_in[15:0];
// --- Compiler-generated local LB for BUS gpu_data<16>
assign gpu_data_in[31:16] = gpu_data_out[31:16];


// --- Compiler-generated local PE for BUS gpu_data<0>
assign gpu_data_out[31:0] = (gpu_data_ins_oe ? gpu_data_ins_out[31:0] : 32'h0)
                          | (gpu_data_arith_oe ? gpu_data_arith_out[31:0] : 32'h0)
                          | (gpu_data_div_oe ? gpu_data_div_out[31:0] : 32'h0)
                          | (gpu_data_mem_oe ? gpu_data_mem_out[31:0] : 32'h0)
                          | (gpu_data_ram_oe ? gpu_data_ram_out[31:0] : 32'h0)
                          | (gpu_data_gate_oe ? gpu_data_gate_out[31:0] : 32'h0)
                          | (gpu_data_bits_oe ? gpu_data_bits_out[31:0] : 32'h0);
assign gpu_data_oe = gpu_data_ins_oe | gpu_data_arith_oe | gpu_data_div_oe | gpu_data_mem_oe | gpu_data_ram_oe | gpu_data_gate_oe | gpu_data_bits_oe;

wire gpu_dout_2_0_oe;
wire gpu_dout_5_3_oe;
wire gpu_dout_10_6_oe;
wire gpu_dout_14_11_oe;
wire gpu_dout_15_oe;
wire gpu_dout_31_16_oe;
assign gpu_dout_oe = gpu_dout_2_0_oe | gpu_dout_5_3_oe | gpu_dout_10_6_oe | gpu_dout_14_11_oe | gpu_dout_15_oe | gpu_dout_31_16_oe;
// below is unnecessary. if any bit is set all will be and should not have overlap so could just use ternaries
//wire gpu_dout_mem_15_0_oe; // This doesnt really exist. should pass through when gpu_dout_mem_31_16_oe == 1. This happens for i2sr0/1/2 = f1a148/4c/50
// --- Compiler-generated local PE for BUS gpu_dout[0]
//assign gpu_dout_out[2:0] = (gpu_dout_arith_oe ? gpu_dout_arith_out[2:0] : 3'h0) | (gpu_dout_mem_15_0_oe ? gpu_dout_mem_out[2:0] : 3'h0) | (gpu_dout_ctrl_5_0_oe ? gpu_dout_ctrl_out[2:0] : 3'h0);
//assign gpu_dout_2_0_oe = gpu_dout_arith_oe | gpu_dout_mem_15_0_oe | gpu_dout_ctrl_5_0_oe;
//assign gpu_dout_out[5:3] = (gpu_dout_ins_14_3_oe ? gpu_dout_ins_out[5:3] : 3'h0) | (gpu_dout_mem_15_0_oe ? gpu_dout_mem_out[5:3] : 3'h0) | (gpu_dout_ctrl_5_0_oe ? gpu_dout_ctrl_out[5:3] : 3'h0);
//assign gpu_dout_5_3_oe = gpu_dout_ins_14_3_oe | gpu_dout_mem_15_0_oe | gpu_dout_ctrl_5_0_oe;
//assign gpu_dout_out[10:6] = (gpu_dout_ins_10_6_oe ? gpu_dout_ins_out[10:6] : 5'h0) | (gpu_dout_mem_15_0_oe ? gpu_dout_mem_out[10:6] : 5'h0);
//assign gpu_dout_10_6_oe = gpu_dout_ins_10_6_oe | gpu_dout_mem_15_0_oe;
//assign gpu_dout_out[14:11] = (gpu_dout_ins_14_3_oe ? gpu_dout_ins_out[14:11] : 3'h0) | (gpu_dout_mem_15_0_oe ? gpu_dout_mem_out[14:11] : 3'h0) | (gpu_dout_ctrl_15_11_oe ? gpu_dout_ctrl_out[14:11] : 3'h0);
//assign gpu_dout_14_11_oe = gpu_dout_ins_14_3_oe | gpu_dout_mem_15_0_oe | gpu_dout_ctrl_15_11_oe;
//assign gpu_dout_out[15] = (gpu_dout_gate_15_oe ? gpu_dout_gate_15_out : 1'b0) | (gpu_dout_mem_15_0_oe ? gpu_dout_mem_out[15] : 1'b0) | (gpu_dout_ctrl_15_11_oe ? gpu_dout_ctrl_out[15] : 1'h0);
//assign gpu_dout_15_oe = gpu_dout_gate_15_oe | gpu_dout_mem_15_0_oe | gpu_dout_ctrl_15_11_oe;

assign gpu_dout_out[2:0] = (gpu_dout_arith_oe ? gpu_dout_arith_out[2:0] : 3'h0) | (gpu_dout_ctrl_5_0_oe ? gpu_dout_ctrl_out[2:0] : 3'h0);
assign gpu_dout_2_0_oe = gpu_dout_arith_oe | gpu_dout_ctrl_5_0_oe;

assign gpu_dout_out[5:3] = (gpu_dout_ins_14_3_oe ? gpu_dout_ins_out[5:3] : 3'h0) | (gpu_dout_ctrl_5_0_oe ? gpu_dout_ctrl_out[5:3] : 3'h0);
assign gpu_dout_5_3_oe = gpu_dout_ins_14_3_oe | gpu_dout_ctrl_5_0_oe;

assign gpu_dout_out[10:6] = (gpu_dout_ins_10_6_oe ? gpu_dout_ins_out[10:6] : 5'h0);
assign gpu_dout_10_6_oe = gpu_dout_ins_10_6_oe;

assign gpu_dout_out[14:11] = (gpu_dout_ins_14_3_oe ? gpu_dout_ins_out[14:11] : 3'h0) | (gpu_dout_ctrl_15_11_oe ? gpu_dout_ctrl_out[14:11] : 3'h0);
assign gpu_dout_14_11_oe = gpu_dout_ins_14_3_oe | gpu_dout_ctrl_15_11_oe;

assign gpu_dout_out[15] = (gpu_dout_gate_15_oe ? gpu_dout_gate_15_out : 1'b0) | (gpu_dout_ctrl_15_11_oe ? gpu_dout_ctrl_out[15] : 1'h0);
assign gpu_dout_15_oe = gpu_dout_gate_15_oe | gpu_dout_ctrl_15_11_oe;

assign gpu_dout_out[31:16] = (gpu_dout_ins_31_16_oe ? gpu_dout_ins_out[31:16] : 16'h0) | (gpu_dout_mem_31_16_oe ? gpu_dout_mem_out[31:16] : 16'h0);
assign gpu_dout_31_16_oe = gpu_dout_ins_31_16_oe | gpu_dout_mem_31_16_oe;

endmodule
