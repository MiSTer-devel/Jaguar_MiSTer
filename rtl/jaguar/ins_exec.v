//`include "defs.v"

module _ins_exec
(
	output [31:0] gpu_data_out,
	output gpu_data_oe,
	input [31:0] gpu_data_in,
	output [31:3] gpu_dout_out, //15 not used
	output gpu_dout_14_3_oe, //flagrd
	output gpu_dout_10_6_oe, //statrd
	output gpu_dout_31_16_oe, //dbgrd = statrd | flagrd
	output [2:0] alufunc,
	output [1:0] brlmux,
	output [23:0] dataddr,
	output datreq,
	output datweb,
	output datwe_raw,
	output div_instr,
	output div_start,
	output [5:0] dstanwi,
	output [5:0] dstat,
	output dstdgate,
	output dstrrd,
	output dstrrdi,
	output dstrwr,
	output dstrwri,
	output dstwen,
	output exe,
	output flag_depend,
	output flagld,
	output [31:0] immdata,
	output immld,
	output immwri,
	output insexei,
	output locden,
	output [31:0] locsrc,
	output macop,
	output memrw,
	output [1:0] msize,
	output mtx_dover,
	output multsel,
	output multsign,
	output pabort,
	output precomp,
	output [21:0] progaddr,
	output progreq,
	output resld,
	output [2:0] ressel,
	output reswr,
	output rev_sub,
	output [1:0] satsz, // satz[1] is tom only
	output srcrrd,
	output single_stop,
	output [5:0] srcanwi,
	input big_instr,
	input carry_flag,
	input clk,
	input clkb, // clkb is jerry only and is buffered clk
	input tlw,
	input datack,
	input dbgrd,
	input div_activei,
	input external,
	input flagrd,
	input flagwr,
	input gate_active,
	input go,
	input [31:0] gpu_din,
	input [5:0] gpu_irq, // gpu_irq[5] = jerry only
	input mtxawr,
	input mtxcwr,
	input nega_flag,
	input pcrd,
	input pcwr,
	input progack,
	input resaddrldi,
	input reset_n,
	input [31:0] result,
	input sbwait,
	input sdatreq,
	input single_go,
	input single_step,
	input srcaddrldi,
	input [31:0] srcd,
	input [31:0] srcdp,
	input [31:0] srcdpa,
	input statrd,
	input zero_flag,
	input sys_clk // Generated
);
parameter JERRY = 0;

reg [4:0] dstop = 5'h0;
wire [4:0] dstopb;
wire [4:0] srcopi;
reg [4:0] srcop = 5'h0;
wire [4:0] dstopi;
wire [4:0] srcopin;
wire [4:0] dstopin;
reg [5:0] opcode = 6'h0;
wire [5:0] opcodei;
wire [5:0] opcodein;
wire [5:0] dstati;
wire [5:0] impdai;
wire [5:0] dstatun;
reg [15:0] immlo = 16'h0;
wire [15:0] instruction;
wire [15:0] insval;
wire [15:0] preinstr;
wire [15:0] intins;
reg [26:0] microword = 27'h0;
wire [26:0] romword27;
wire [26:0] mwordi;
wire [31:0] mtx_addr; // mtx_addr[31:24] = tom only
wire [31:0] prog_count;
wire [26:0] romword;
wire [4:0] srcopb;
wire [23:0] program_count;
wire [15:0] sysins;
wire jump_ena;
wire sysser;
wire intser;
wire insrdy;
wire jump_atomic;
wire jumprel;
wire jumpabs;
wire promold_n;
wire jump_ins;
wire jump_insp;
wire movei;
wire moveild_n;
wire moveild;
wire romold_n;
wire [2:0] idlet;
reg await2 = 1'b0;
reg idle = 1'b1;
wire [2:0] await1t;
reg await1 = 1'b0;
wire [2:0] await2t;
wire [1:0] atomict;
wire movei_atomic;
wire movei_data;
wire atomic;
wire mtx_atomic;
wire mult_atomic;
wire multn;
wire multn_n;
wire multaset;
wire multaclr;
reg multa = 1'b0;
wire imaski;
wire mtx_wait;
wire mtx_mreq;
wire sromold;
wire mtx_mreq_n;
wire mtx_doveri;
wire intser_n;
wire sysser_n;
wire romold;
wire unpack;
reg [1:0] msize_ = 2'h0;
wire [1:0] msizet;
wire [3:0] srcdat;
wire srcrrdt;
wire insexe;
wire memrw_n;
wire datwet_;
wire dsttinv;
wire [5:0] opcd;
wire idc_n_36;
wire idc_n_37;
wire idc_n_43;
wire idc_n_44;
wire idc_n_49;
wire idc_n_50;
wire idc_n_58;
wire idc_n_59;
wire idc_n_60;
wire idc_n_61;
wire [1:0] precompit;
wire precompit_;
wire precompi;
reg precompil = 1'b0;
wire dsttinvit;
wire dsttinvi;
reg dsttinvil = 1'b0;
wire srctinvit;
wire srctinvi;
reg srctinvil = 1'b0;
wire indselit;
wire indseli;
reg indselil = 1'b0;
wire [2:0] datwet;
wire exeb_1;
wire exe_n;
reg datwelat = 1'b0;
wire datwe;
wire datwec;
wire microword_n_8;
wire microword_n_15;
wire alufunc2_n;
wire alufunc7_n;
wire rev_subt;
wire srcdat4;
wire conditional;
wire jump;
wire [1:0] fdt;
wire alufunc_n_2;
wire loimmld;
wire locdent;
wire regpagei;
reg regpage = 1'b0;
wire imaski_n;
wire reghighi;
reg imask_n = 1'b0;
wire reghigh;
wire dsttopi;
wire dsttop;
wire danwsel;
wire srctopti;
wire srctopi;
wire zero_flag_n;
wire other_flag;
wire other_flag_n;
wire [3:0] cond;
wire [1:0] dataseli;
reg datasel0 = 1'b0;
reg datasel1 = 1'b0;
reg [23:0] srcaddrl = 24'h0;
wire addrlatt;
wire addrlat;
wire [17:16] gpu_dout_j; //for jerry
wire gpu_dout_17_16_oe;

// Output buffers
wire alufunc_b0_obuf;
wire alufunc_b2_obuf;
wire datweb_obuf;
wire div_instr_obuf;
wire dstwen_obuf;
wire exe_obuf;
wire immld_obuf;
wire insexei_obuf;
wire memrw_obuf;
wire precomp_obuf;

wire resetl = reset_n; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign datweb = datweb_obuf;
assign div_instr = div_instr_obuf;
assign dstwen = dstwen_obuf;
assign exe = exe_obuf;
assign immld = immld_obuf;
assign insexei = insexei_obuf;
assign memrw = memrw_obuf;
assign precomp = precomp_obuf;
assign msize = msize_;


// INS_EXEC.NET (122) - dbgrd[25] : ts
// INS_EXEC.NET (123) - dbgrd[26] : ts
// INS_EXEC.NET (124) - dbgrd[27] : ts
// INS_EXEC.NET (125) - dbgrd[28] : ts
// INS_EXEC.NET (126) - dbgrd[29] : ts
// INS_EXEC.NET (127) - dbgrd[30] : ts
// INS_EXEC.NET (128) - dbgrd[31] : ts
assign gpu_dout_31_16_oe = dbgrd;
assign gpu_dout_out[25] = sbwait;
assign gpu_dout_out[26] = div_activei;
assign gpu_dout_out[27] = external;
assign gpu_dout_out[28] = gate_active;
assign gpu_dout_out[29] = jump_ena;
assign gpu_dout_out[30] = sysser;
assign gpu_dout_out[31] = intser;

// INS_EXEC.NET (132) - prefetch : prefetch
_prefetch prefetch_inst
(
	.gpu_dout_out /* BUS */ (gpu_dout_out[24:22]),
//	.gpu_dout_oe /* BUS */ (gpu_dout_oe), = dbgrd
	.insrdy /* OUT */ (insrdy),
	.instruction /* OUT */ (preinstr[15:0]),
	.jump_atomic /* OUT */ (jump_atomic),
	.pabort /* OUT */ (pabort),
	.progreq /* OUT */ (progreq),
	.progaddr /* OUT */ (progaddr[21:0]),
	.program_count /* OUT */ (program_count[23:0]),
	.big_instr /* IN */ (big_instr),
	.clk /* IN */ (clk),
	.dbgrd /* IN */ (dbgrd),
	.go /* IN */ (go),
	.gpu_data /* IN */ (gpu_data_in[31:0]),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.progack /* IN */ (progack),
	.jumprel /* IN */ (jumprel),
	.jumpabs /* IN */ (jumpabs),
	.pcwr /* IN */ (pcwr),
	.reset_n /* IN */ (reset_n),
	.promoldx_n /* IN */ (promold_n),
	.single_go /* IN */ (single_go),
	.single_step /* IN */ (single_step),
	.srcd /* IN */ (srcd[31:0]),
	.srcdp /* IN */ (srcdp[31:0]),
	.sys_clk(sys_clk) // Generated
);

// INS_EXEC.NET (139) - prog_cnt : join
assign prog_count[23:0] = program_count[23:0];
assign prog_count[31:24] = 8'h00;

// INS_EXEC.NET (169) - jumpins : or2
assign jump_ins = |microword[24:23];

// INS_EXEC.NET (173) - jumpinsp : an5
assign jump_insp = preinstr[15:11]==5'b11010;

// INS_EXEC.NET (180) - movei : an6
assign movei = preinstr[15:10]==6'b100110;

// INS_EXEC.NET (182) - moveild\ : nd2
assign moveild_n = ~(movei & romold);

// INS_EXEC.NET (183) - moveild : iv
assign moveild = ~moveild_n;

// INS_EXEC.NET (185) - romold\ : iv
assign romold_n = ~romold;

// INS_EXEC.NET (187) - idlet0 : nd2
assign idlet[0] = ~(await2 & romold);

// INS_EXEC.NET (188) - idlet1 : nd2
assign idlet[1] = ~(idle & moveild_n);

// INS_EXEC.NET (189) - idlet2 : nd2
assign idlet[2] = ~(&idlet[1:0]);

// INS_EXEC.NET (190) - idle : fd4q
// INS_EXEC.NET (195) - await1 : fd2q
// INS_EXEC.NET (200) - await2 : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			idle <= 1'b1;
			await1 <= 1'b0;
			await2 <= 1'b0;
		end else begin
			idle <= idlet[2];
			await1 <= await1t[2];
			await2 <= await2t[2];
		end
	end
end

// INS_EXEC.NET (192) - await1t0 : nd2
assign await1t[0] = ~(idle & moveild);

// INS_EXEC.NET (193) - await1t1 : nd2
assign await1t[1] = ~(await1 & romold_n);

// INS_EXEC.NET (194) - await1t2 : nd2
assign await1t[2] = ~(&await1t[1:0]);

// INS_EXEC.NET (197) - await2t0 : nd2
assign await2t[0] = ~(await1 & romold);

// INS_EXEC.NET (198) - await2t1 : nd2
assign await2t[1] = ~(await2 & romold_n);

// INS_EXEC.NET (199) - await2t2 : nd2
assign await2t[2] = ~(&await2t[1:0]);

// INS_EXEC.NET (202) - atomict[0] : an2
assign atomict[0] = movei & insrdy;

// INS_EXEC.NET (203) - atomict[1] : an2
assign atomict[1] = await2 & romold_n;

// INS_EXEC.NET (204) - movei_atomic : or3
assign movei_atomic = |atomict[1:0] | await1;

// INS_EXEC.NET (205) - movei_data : or2
assign movei_data = await1 | await2;

// INS_EXEC.NET (206) - atomic : or6
assign atomic = movei_atomic | mtx_atomic | mult_atomic | jump_atomic | jump_ins | jump_insp;

// INS_EXEC.NET (215) - multn : an5
assign multn = (preinstr[15:10]==6'b010100) | (preinstr[15:10]==6'b010010);

// INS_EXEC.NET (218) - multn\ : iv
assign multn_n = ~multn;

// INS_EXEC.NET (219) - multaset : an3
assign multaset = romold & multn & idle;

// INS_EXEC.NET (220) - multaclr : an2
assign multaclr = romold & multn_n;

// INS_EXEC.NET (221) - multa : cp_latch
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			multa <= 1'b0;
		end else begin
			multa <= (~multaclr & (multaset | multa));
		end
	end
end

// INS_EXEC.NET (223) - mult_atomic : or2
assign mult_atomic = multa | multaset;

// INS_EXEC.NET (227) - interrupt : interrupt
_interrupt #(.JERRY(JERRY)) interrupt_inst
(
	.gpu_dout_out /* BUS */ (gpu_dout_out[13:3]),
	.gpu_dout_13_3_oe /* BUS */ (gpu_dout_14_3_oe), //flagrd; 14 below
	.gpu_dout_10_6_oe /* BUS */ (gpu_dout_10_6_oe), //statrd
	.gpu_dout_hi_out /* BUS */ (gpu_dout_j[17:16]), //flagrd; 14 below
	.gpu_dout_17_16_oe /* BUS */ (gpu_dout_17_16_oe), //statrd
	.imaski /* OUT */ (imaski),
	.intins /* OUT */ (intins[15:0]),
	.intser /* OUT */ (intser),
	.atomic /* IN */ (atomic),
	.clk /* IN */ (clk),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.flagrd /* IN */ (flagrd),
	.flagwr /* IN */ (flagwr),
	.gpu_irq /* IN */ (gpu_irq[5:0]),
	.reset_n /* IN */ (reset_n),
	.romold /* IN */ (romold),
	.statrd /* IN */ (statrd),
	.sys_clk(sys_clk) // Generated
);

// INS_EXEC.NET (234) - systolic : systolic
_systolic systolic_inst
(
	.mtx_atomic /* OUT */ (mtx_atomic),
	.mtx_dover /* OUT */ (mtx_dover),
	.mtx_wait /* OUT */ (mtx_wait),
	.mtxaddr /* OUT */ (mtx_addr[11:2]),
	.mtx_mreq /* OUT */ (mtx_mreq),
	.multsel /* OUT */ (multsel),
	.sysins /* OUT */ (sysins[15:0]),
	.sysser /* OUT */ (sysser),
	.movei_data /* IN */ (movei_data),
	.clk /* IN */ (clk),
	.datack /* IN */ (datack),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.instruction /* IN */ (preinstr[15:0]),
	.mtxawr /* IN */ (mtxawr),
	.mtxcwr /* IN */ (mtxcwr),
	.reset_n /* IN */ (reset_n),
	.romold /* IN */ (sromold),
	.sys_clk(sys_clk) // Generated
);

// INS_EXEC.NET (239) - mtx_mreq\ : iv
assign mtx_mreq_n = ~mtx_mreq;

// INS_EXEC.NET (240) - mtx_doveri : join
assign mtx_doveri = mtx_mreq;

// INS_EXEC.NET (246) - instruction : mx4p
assign instruction[15:0] = intser ? (intins[15:0]) : (sysser ? sysins[15:0] : preinstr[15:0]);

// INS_EXEC.NET (252) - intser\ : iv
assign intser_n = ~intser;

// INS_EXEC.NET (253) - sysser\ : iv
assign sysser_n = ~sysser;

// INS_EXEC.NET (254) - promold : nd3p
assign promold_n = ~(romold & intser_n & sysser_n);

// INS_EXEC.NET (259) - sromold : an2h
assign sromold = romold & intser_n;

// INS_EXEC.NET (263) - opcodei : join
assign opcodei[5:0] = instruction[15:10];

// INS_EXEC.NET (264) - srcopi : join
assign srcopi[4:0] = instruction[9:5];

// INS_EXEC.NET (265) - dstopi : join
assign dstopi[4:0] = instruction[4:0];

// DSP_EXEC.NET (277) - clkdela : dly8
// DSP_EXEC.NET (278) - clkdelb : dly8
// DSP_EXEC.NET (279) - clkdelc : dly8
// DSP_EXEC.NET (280) - clkdeld : dly8
// DSP_EXEC.NET (281) - clkdele : dly8
wire clkdela = clk;
wire clkdelb = clkdela;
wire clkdelc = clkdelb;
wire clkdeld = clkdelc;
wire clkdele = clkdeld;
// DSP_EXEC.NET (282) - clkdel\ : iv
wire clkdel_n = ~clkdele;
// DSP_EXEC.NET (283) - romcs : an2
wire romcs = clk & (JERRY==0 ? 1'b1 : clkdel_n); // This doesnt do anything for tom or jerry with delays and ignores cs anyway

// INS_EXEC.NET (270) - mcode : ra6032a
_ra6032a #(.JERRY(JERRY)) mcode_inst
(
	.z /* OUT */ (romword[26:0]),
	.clk /* IN */ (romcs),
	.a /* IN */ (opcodei[5:0]),
	.sys_clk(sys_clk) // Generated
);

// INS_EXEC.NET (271) - romword : join
assign romword27[26:0] = romword[26:0];

// INS_EXEC.NET (275) - mwordi : mx2p
assign mwordi[26:0] = (romold) ? romword27[26:0] : microword[26:0];

// INS_EXEC.NET (276) - mcodepipe : fd2qp
// INS_EXEC.NET (278) - srcop : fd2qp
// INS_EXEC.NET (281) - dstop : fd2qp
// INS_EXEC.NET (284) - opcode : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			microword[26:0] <= 27'h0;
			srcop[4:0] <= 5'h0;
			dstop[4:0] <= 5'h0;
			opcode[5:0] <= 6'h0;
		end else begin
			microword[26:0] <= mwordi[26:0];
			srcop[4:0] <= srcopin[4:0];
			dstop[4:0] <= dstopin[4:0];
			opcode[5:0] <= opcodein[5:0];
		end
	end
end

// INS_EXEC.NET (277) - srcopin : mx2
assign srcopin[4:0] = (romold) ? srcopi[4:0] : srcopb[4:0];

// INS_EXEC.NET (279) - srcopb : nivm
assign srcopb[4:0] = srcop[4:0];

// INS_EXEC.NET (280) - dstopin : mx2p
assign dstopin[4:0] = (romold) ? dstopi[4:0] : dstopb[4:0];

// INS_EXEC.NET (282) - dstopb : nivm
assign dstopb[4:0] = dstop[4:0];

// INS_EXEC.NET (283) - opcodein : mx2
assign opcodein[5:0] = (romold) ? opcodei[5:0] : opcode[5:0];

// INS_EXEC.NET (289) - dbgrd[16-21] : ts
assign gpu_dout_out[21:18] = opcode[5:2];
assign gpu_dout_out[17:16] = (JERRY==0) ? opcode[1:0] : gpu_dout_j[17:16];

// INS_EXEC.NET (291) - ressel[0] : or2
// INS_EXEC.NET (292) - ressel[1-2] : join
assign ressel[0] = unpack | microword[0];
assign ressel[2:1] = microword[2:1];

// INS_EXEC.NET (293) - brlmux[0-1] : join
assign brlmux[1:0] = microword[4:3];

// INS_EXEC.NET (294) - multsign : niv
assign multsign = microword[4];

// INS_EXEC.NET (295) - msizet[0-1] : join
assign msizet[1:0] = microword[4:3];

// INS_EXEC.NET (296) - satsz[0] : join
assign satsz[0] = microword[5];

// INS_EXEC.NET (297) - mac : an2
assign macop = exe_obuf & microword[6];

// INS_EXEC.NET (298) - alufunc : join
assign alufunc[2:0] = microword[9:7];

// INS_EXEC.NET (300) - flagld : an2
assign flagld = exe_obuf & microword[11];

// INS_EXEC.NET (301) - resld : an2
assign resld = exe_obuf & microword[12];

// INS_EXEC.NET (302) - srcdat[0-3] : niv
assign srcdat[3:0] = microword[16:13];

// INS_EXEC.NET (303) - srcrrdt : nr4
assign srcrrdt = ~(|microword[16:13]);

// INS_EXEC.NET (304) - srcrrd : niv
assign srcrrd = srcrrdt;

// INS_EXEC.NET (305) - reswr : an2
assign reswr = insexe & microword[17];

// INS_EXEC.NET (306) - dstrrd : join
assign dstrrd = microword[18];

// INS_EXEC.NET (307) - dstrrdi : join
assign dstrrdi = mwordi[18];

// INS_EXEC.NET (308) - memrw : an2p
assign memrw_obuf = insexe & microword[19];

// INS_EXEC.NET (309) - memrw\ : iv
assign memrw_n = ~memrw_obuf;

// INS_EXEC.NET (310) - datwet : an2
assign datwet_ = go & microword[20];

// INS_EXEC.NET (311) - datwe_raw : an2
assign datwe_raw = insexe & microword[20];

// INS_EXEC.NET (312) - precomp : nivu
assign precomp_obuf = microword[21];

// INS_EXEC.NET (313) - immld : join
assign immld_obuf = microword[22];

// INS_EXEC.NET (314) - jumprel : an3
assign jumprel = exe_obuf & jump_ena & microword[23];

// INS_EXEC.NET (315) - jumpabs : an3
assign jumpabs = exe_obuf & jump_ena & microword[24];

// INS_EXEC.NET (316) - dstwen : an2
assign dstwen_obuf = insexe & microword[25];

// INS_EXEC.NET (317) - dstrwr : niv
assign dstrwr = microword[25];

// INS_EXEC.NET (318) - dstrwri : join
assign dstrwri = mwordi[25];

// INS_EXEC.NET (319) - dsttinv : an2
assign dsttinv = microword[1] & dstwen_obuf;

// INS_EXEC.NET (320) - satsz[1] : join
assign satsz[1] = microword[26];

// INS_EXEC.NET (332) - opcd[0-4] : niv
// INS_EXEC.NET (333) - opcd[5] : nivm
assign opcd[5:0] = opcodei[5:0];

// INS_EXEC.NET (340) - idc\[36] : nd6
assign idc_n_36 = ~(opcd[5:0]==6'h24);

// INS_EXEC.NET (342) - idc\[37] : nd6
assign idc_n_37 = ~(opcd[5:0]==6'h25);

// INS_EXEC.NET (344) - idc\[43] : nd6
assign idc_n_43 = ~(opcd[5:0]==6'h2B);

// INS_EXEC.NET (346) - idc\[44] : nd6
assign idc_n_44 = ~(opcd[5:0]==6'h2C);

// INS_EXEC.NET (348) - idc\[49] : nd6
assign idc_n_49 = ~(opcd[5:0]==6'h31);

// INS_EXEC.NET (350) - idc\[50] : nd6
assign idc_n_50 = ~(opcd[5:0]==6'h32);

// INS_EXEC.NET (352) - idc\[58] : nd6
assign idc_n_58 = ~(opcd[5:0]==6'h3A);

// INS_EXEC.NET (354) - idc\[59] : nd6
assign idc_n_59 = ~(opcd[5:0]==6'h3B);

// INS_EXEC.NET (356) - idc\[60] : nd6
assign idc_n_60 = ~(opcd[5:0]==6'h3C);

// INS_EXEC.NET (358) - idc\[61] : nd6
assign idc_n_61 = ~(opcd[5:0]==6'h3D);

// INS_EXEC.NET (362) - precompit0 : an4
assign precompit[0] = idc_n_43 & idc_n_44 & idc_n_49 & idc_n_50;

// INS_EXEC.NET (363) - precompit1 : an4
assign precompit[1] = idc_n_58 & idc_n_59 & idc_n_60 & idc_n_61;

// INS_EXEC.NET (364) - precompit : nd2
assign precompit_ = ~(&precompit[1:0]);

// INS_EXEC.NET (365) - precompi : mx2
assign precompi = (romold) ? precompit_ : precompil;

// INS_EXEC.NET (367) - precompil : fd2q
// INS_EXEC.NET (380) - dsttinvil : fd2q
// INS_EXEC.NET (387) - srctinvil : fd2q
// INS_EXEC.NET (395) - indselil : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			precompil <= 1'b0;
			dsttinvil <= 1'b0;
			srctinvil <= 1'b0;
			indselil <= 1'b0;
		end else begin
			precompil <= precompi;
			dsttinvil <= dsttinvi;
			srctinvil <= srctinvi;
			indselil <= indseli;
		end
	end
end

// INS_EXEC.NET (377) - dsttinvit : iv
assign dsttinvit = ~idc_n_36;

// INS_EXEC.NET (378) - dsttinvi : mx2
assign dsttinvi = (romold) ? dsttinvit : dsttinvil;

// INS_EXEC.NET (384) - srctinvit : iv
assign srctinvit = ~idc_n_37;

// INS_EXEC.NET (385) - srctinvi : mx2
assign srctinvi = (romold) ? srctinvit : srctinvil;

// INS_EXEC.NET (391) - indselit : nd4
assign indselit = ~(idc_n_44 & idc_n_50 & idc_n_59 & idc_n_61);

// INS_EXEC.NET (393) - indseli : mx2
assign indseli = (romold) ? indselit : indselil;

// INS_EXEC.NET (399) - unpack : an7
assign unpack = &opcode[5:0] & srcopb[0] & (JERRY==0);

// INS_EXEC.NET (414) - datwet[0] : nd4
assign datwet[0] = ~(mtx_mreq_n & datwet_ & exeb_1 & memrw_obuf);

// INS_EXEC.NET (416) - exe\ : iv
assign exe_n = ~exeb_1;

// INS_EXEC.NET (417) - datwet[1] : nd3
assign datwet[1] = ~(mtx_mreq_n & datwelat & exe_n);

// INS_EXEC.NET (418) - datwet[2] : nd3
assign datwet[2] = ~(mtx_mreq_n & datwelat & memrw_n);

// INS_EXEC.NET (419) - datwe : nd3p
assign datwe = ~(&datwet[2:0]);

// INS_EXEC.NET (421) - datweb : niv
assign datweb_obuf = datwe;

// INS_EXEC.NET (422) - datwel : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		datwelat <= datweb_obuf;
	end
end

// INS_EXEC.NET (424) - datwec : an2p
assign datwec = exe_obuf & memrw_obuf;

// INS_EXEC.NET (425) - msize[0-1] : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (datwec) begin
			msize_[1:0] <= msizet[1:0];
		end
	end
end

// INS_EXEC.NET (432) - alufunc2\ : or3
assign alufunc2_n = ~(microword[9:7]==3'b010);

// INS_EXEC.NET (434) - alufunc7\ : nd3
assign alufunc7_n = ~(microword[9:7]==3'b111);

// INS_EXEC.NET (435) - rev_subt : nd2
assign rev_subt = ~(alufunc2_n & alufunc7_n);

// INS_EXEC.NET (436) - srcdat4 : nr4
assign srcdat4 = (microword[16:13]==4'b0100);

// INS_EXEC.NET (438) - rev_sub : an2
assign rev_sub = rev_subt & srcdat4;

// INS_EXEC.NET (443) - div_instr : an6
assign div_instr_obuf = opcode[5:0]==6'b010101;

// INS_EXEC.NET (446) - div_start : an2m
assign div_start = exe_obuf & div_instr_obuf;

// INS_EXEC.NET (452) - conditional : or5
assign conditional = |dstopb[4:0];

// INS_EXEC.NET (453) - jump : or2
assign jump = |microword[24:23];

// INS_EXEC.NET (454) - fdt0 : nd2
assign fdt[0] = ~(conditional & jump);

// INS_EXEC.NET (456) - fdt1 : nd2
assign fdt[1] = ~(alufunc[0] & ~alufunc[2]);

// INS_EXEC.NET (457) - flag_depend : nd2
assign flag_depend = ~(&fdt[1:0]);

// INS_EXEC.NET (461) - insval : join
assign insval[4:0] = dstopb[4:0];
assign insval[9:5] = srcopb[4:0];
assign insval[15:10] = opcode[5:0];

// INS_EXEC.NET (462) - immlo : fdsync16
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (loimmld) begin
			immlo[15:0] <= insval[15:0];
		end
	end
end

// INS_EXEC.NET (463) - immdata : join
assign immdata[15:0] = immlo[15:0];
assign immdata[31:16] = insval[15:0];

// INS_EXEC.NET (467) - srcdgen : srcdgen
_srcdgen srcdgen_inst
(
	.locdent /* OUT */ (locdent),
	.locsrc /* OUT */ (locsrc[31:0]),
	.program_count /* IN */ (prog_count[31:0]),
	.srcdat /* IN */ (srcdat[3:0]),
	.srcop /* IN */ (srcopb[4:0])
);

// INS_EXEC.NET (473) - locden : an2u
assign locden = locdent & exe_obuf;

// INS_EXEC.NET (481) - regpagei : mx2
assign regpagei = (flagwr) ? gpu_din[14] : regpage;

// INS_EXEC.NET (482) - regpage : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			regpage <= 1'b0;
		end else begin
			regpage <= regpagei;
		end
	end
end

// INS_EXEC.NET (483) - flagrd[14] : ts
//assign gpu_dout_14_3_oe = flagrd;
assign gpu_dout_out[14] = regpage;
assign gpu_dout_out[15] = 1'b0; // not used

// INS_EXEC.NET (484) - imaski\ : iv
assign imaski_n = ~imaski;

// INS_EXEC.NET (485) - reghighi : an2
assign reghighi = regpagei & imaski_n;

// INS_EXEC.NET (486) - imask\ : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		imask_n <= imaski_n;
	end
end

// INS_EXEC.NET (487) - reghigh : an2
assign reghigh = regpage & imask_n;

// INS_EXEC.NET (499) - dsttopi : eo
assign dsttopi = dsttinvi ^ reghighi;

// INS_EXEC.NET (500) - dstati : join
assign dstati[4:0] = dstopin[4:0];
assign dstati[5] = dsttopi;

// INS_EXEC.NET (501) - impdai : join
assign impdai[0] = indseli;
assign impdai[4:1] = 4'h7;
assign impdai[5] = dsttopi;

// INS_EXEC.NET (503) - dsttop : eo
assign dsttop = dsttinv ^ reghigh;

// INS_EXEC.NET (504) - dstatun : join
assign dstatun[4:0] = dstop[4:0];
assign dstatun[5] = dsttop;

// INS_EXEC.NET (505) - dstat : nivh
assign dstat[5:0] = dstatun[5:0];

// INS_EXEC.NET (515) - danwsel1 : an2p
assign danwsel = insexei_obuf & precompi;

// INS_EXEC.NET (516) - dstanwi : mx2p
assign dstanwi[5:0] = (danwsel) ? impdai[5:0] : dstati[5:0];

// INS_EXEC.NET (522) - srctopti : eo
assign srctopti = srctinvi ^ reghighi;

// INS_EXEC.NET (523) - srctopi : or2
assign srctopi = srctopti | mtx_doveri;

// INS_EXEC.NET (524) - srcanwi : join
assign srcanwi[4:0] = srcopin[4:0];
assign srcanwi[5] = srctopi;

// INS_EXEC.NET (528) - execon : execon
_execon execon_inst
(
	.dstdgate /* OUT */ (dstdgate),
	.exe /* OUT */ (exe_obuf),
	.exeb_1 /* OUT */ (exeb_1),
	.immwri /* OUT */ (immwri),
	.insexe /* OUT */ (insexe),
	.insexei /* OUT */ (insexei_obuf),
	.loimmld /* OUT */ (loimmld),
	.romold /* OUT */ (romold),
	.stop /* OUT */ (single_stop),
	.clk_0 /* IN */ (clk),
	.go /* IN */ (go),
	.immld /* IN */ (immld_obuf),
	.insrdy /* IN */ (insrdy),
	.memrw /* IN */ (memrw_obuf),
	.datwe /* IN */ (datwe),
	.mtx_wait /* IN */ (mtx_wait),
	.precomp /* IN */ (precomp_obuf),
	.reset_n /* IN */ (reset_n),
	.sbwait /* IN */ (sbwait),
	.single_go /* IN */ (single_go),
	.single_step /* IN */ (single_step),
	.sys_clk(sys_clk) // Generated
);

// INS_EXEC.NET (544) - zero_flag\ : iv
assign zero_flag_n = ~zero_flag;

// INS_EXEC.NET (545) - other_flag : mx2
assign other_flag = (dstopb[4]) ? nega_flag : carry_flag;

// INS_EXEC.NET (547) - other_flag\ : iv
assign other_flag_n = ~other_flag;

// INS_EXEC.NET (548) - cond0 : nd2
assign cond[0] = ~(dstopb[0] & zero_flag);

// INS_EXEC.NET (549) - cond1 : nd2
assign cond[1] = ~(dstopb[1] & zero_flag_n);

// INS_EXEC.NET (550) - cond2 : nd2
assign cond[2] = ~(dstopb[2] & other_flag);

// INS_EXEC.NET (551) - cond3 : nd2
assign cond[3] = ~(dstopb[3] & other_flag_n);

// INS_EXEC.NET (552) - conddis : an4
assign jump_ena = &cond[3:0];

// INS_EXEC.NET (566) - mtx_addr : join
assign mtx_addr[1:0] = 2'b00;
//assign mtx_addr[11:2] = mtxaddr[11:2];
assign mtx_addr[31:12] = (JERRY==0) ? 20'h00F03 : 20'h00F1B;

// INS_EXEC.NET (571) - dataseli[0] : or2
assign dataseli[0] = srcaddrldi | mtx_doveri;

// INS_EXEC.NET (572) - dataseli[1] : or2
assign dataseli[1] = resaddrldi | mtx_doveri;

// INS_EXEC.NET (573) - datasel0[0-5] : fd1qp
// INS_EXEC.NET (574) - datasel1[0-5] : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		datasel0 <= dataseli[0];
		datasel1 <= dataseli[1];
	end
end

// INS_EXEC.NET (576) - dataddr[0-3] : mx4p
// INS_EXEC.NET (579) - dataddr[4-7] : mx4p
// INS_EXEC.NET (582) - dataddr[8-11] : mx4p
// INS_EXEC.NET (585) - dataddr[12-15] : mx4p
// INS_EXEC.NET (588) - dataddr[16-19] : mx4p
// INS_EXEC.NET (591) - dataddr[20-23] : mx4p
//assign dataddr[3:0] = datasel1[0] ? (datasel0[0] ? mtx_addr[3:0] : result[3:0]) : (datasel0[0] ? srcdpa[3:0] : srcaddrl[3:0]);
//assign dataddr[7:4] = datasel1[1] ? (datasel0[1] ? mtx_addr[7:4] : result[7:4]) : (datasel0[1] ? srcdpa[7:4] : srcaddrl[7:4]);
//assign dataddr[11:8] = datasel1[2] ? (datasel0[2] ? mtx_addr[11:8] : result[11:8]) : (datasel0[2] ? srcdpa[11:8] : srcaddrl[11:8]);
//assign dataddr[15:12] = datasel1[3] ? (datasel0[3] ? mtx_addr[15:12] : result[15:12]) : (datasel0[3] ? srcdpa[15:12] : srcaddrl[15:12]);
//assign dataddr[19:16] = datasel1[4] ? (datasel0[4] ? mtx_addr[19:16] : result[19:16]) : (datasel0[4] ? srcdpa[19:16] : srcaddrl[19:16]);
//assign dataddr[23:20] = datasel1[5] ? (datasel0[5] ? mtx_addr[23:20] : result[23:20]) : (datasel0[5] ? srcdpa[23:20] : srcaddrl[23:20]);
assign dataddr[23:0] = datasel1 ? (datasel0 ? mtx_addr[23:0] : result[23:0]) : (datasel0 ? srcdpa[23:0] : srcaddrl[23:0]);

// INS_EXEC.NET (598) - addrlatt : oan1
assign addrlatt = (datasel0 | datasel1) & tlw;

// INS_EXEC.NET (600) - addrlat : nivu
assign addrlat = addrlatt;

// INS_EXEC.NET (601) - srcaddrl[0-23] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (addrlat) begin
		srcaddrl[23:0] <= dataddr[23:0];
	end
end

// INS_EXEC.NET (606) - datreq : or2
assign datreq = sdatreq | mtx_mreq;

// INS_EXEC.NET (610) - pcrd : ts
assign gpu_data_out[31:0] = prog_count[31:0];
assign gpu_data_oe = pcrd;
endmodule
