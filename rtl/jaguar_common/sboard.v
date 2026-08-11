//`include "defs.v"

module _sboard
(
	output [5:0] dsta,
	output sdatreq,
	output dstrwen_n,
	output [31:0] dstwd,
	output resaddrldi,
	output sbwait,
	output [5:0] srca,
	output srcaddrldi,
	output srcrwen_n,
	output [31:0] srcwd,
	input clk,
	input datack,
	input datwe,
	input datwe_raw,
	input del_xld,
	input div_activei,
	input div_instr,
	input div_start,
	input [5:0] dstanwi,
	input [5:0] dstat,
	input dstrrd,
	input dstrrdi,
	input dstrwr,
	input dstrwri,
	input dstwen,
	input exe,
	input flag_depend,
	input flagld,
	input gate_active,
	input [31:0] immdata,
	input immld,
	input immwri,
	input insexei,
	input [31:0] load_data,
	input [31:0] mem_data,
	input memrw,
	input mtx_dover,
	input precomp,
	input [31:0] quotient,
	input reset_n,
	input reswr,
	input [31:0] result,
	input [5:0] srcanwi,
	input [31:0] srcdp,
	input srcrrd,
	input xld_ready,
	input sys_clk // Generated
);
reg [5:0] alu_wbaddr = 6'h0;
reg [5:0] div_wbaddr = 6'h0;
reg [5:0] dstwbaddr = 6'h0;
reg [5:0] hwbaddr;
wire [5:0] ild_wbaddr;
reg [5:0] ild_wbaddrl = 6'h0;
reg [5:0] imm_wbaddr = 6'h0;
wire [5:0] mov_wbaddr;
reg [5:0] srcwbaddr = 6'h0;
reg [5:0] swbaddr;
wire [5:0] xld_wbaddr;
reg [5:0] xlddst = 6'h0;
reg [5:0] xlddst2 = 6'h0;
wire [5:0] zero6;
wire [5:0] dsta_reg;
wire [5:0] srca_reg;
reg [5:0] dstanw = 6'h0;
reg [5:0] srcanw = 6'h0;
wire [31:0] mxdata;
reg [31:0] xld_data = 32'h0;
wire [31:0] ild_data;
reg [31:0] ild_datad = 32'h0;
wire datack_n;
wire datwe_n;
wire del_xld_n;
wire exe_n;
wire memrw_n;
wire mtx_dover_n;
wire precomp_n;
wire zero;
reg insexe = 1'b0;
wire dstren;
wire dsta_reg_ena;
wire srca_reg_ena;
wire pendwr;
reg alu_wback = 1'b0;
wire dp1eq;
wire sp1eq;
wire aluwt;
wire aludwait;
wire mov_wback;
wire immasel;
wire imm_wback;
wire ildwal;
wire ildwbset;
wire ildwbclr;
wire ild_wbackh;
wire ild_wbacks;
wire ildwbt;
reg ild_wbackd = 1'b0;
wire ild_wbacki;
wire ild_wback;
reg ilddselt_n = 1'b0;
wire [2:0] idlet;
reg idle = 1'b1;
reg loading = 1'b0;
wire idlei;
wire idle_n;
wire comp1i;
reg comp1 = 1'b0;
wire comp2i;
reg comp2 = 1'b0;
wire [2:0] loadingt;
wire loadingi;
wire dlaeq;
wire slaeq;
wire [2:0] ldwaitt;
wire ldwait;
wire [2:0] drqt;
wire [3:0] ld1t;
wire ldidle;
reg oneld = 1'b0;
reg xldd_sel = 1'b0;
reg twold = 1'b0;
wire oneldi;
wire [1:0] ld2t;
wire twoldi;
wire [3:0] xlddt;
wire xlddeq;
wire xldseq;
wire xldeq;
wire xld2deq;
wire xld2seq;
wire xld2eq;
wire xlddwait;
wire [3:0] mbsywt;
wire mbusywait;
wire xwbclr;
wire xld_wbackh;
wire xld_wbacks;
wire [1:0] xwbat;
reg xld_wbackl = 1'b0;
wire xld_wback;
reg div_active = 1'b0;
wire divdeq;
wire divseq;
wire diveq;
wire divdwait;
wire dwbset;
wire dwbclr;
wire div_wbackh;
wire div_wbacks;
wire [1:0] dwbat;
reg div_wbackl = 1'b0;
wire div_wback;
wire diviwait;
reg flag_pend = 1'b0;
wire flagwait;
wire wbacki;
reg wback = 1'b0;
wire alu_wbackh;
wire mov_wbackh;
wire imm_wbackh;
wire mov_wbacks;
wire imm_wbackst;
wire imm_wbacks;
wire ild_wbackst;
wire xld_wbackst;
wire div_wbackst;
wire mult_wbacki;
reg mult_wback = 1'b0;
wire [2:0] hasel;
wire [2:0] sasel;
wire [5:0] wbdcmpt;
wire wbdeqi_n;
wire wbdeqit;
wire wbdeqi;
reg wbdeq_n = 1'b0;
wire wbseqi_n;
reg wbseq_n = 1'b0;
wire bothen;
wire wbwaitt;
wire wbwait;
wire [6:0] dwbt;
wire dstwbwei;
reg dstwbwet = 1'b0;
wire dstwbwe;
wire [1:0] swbt;
wire srcwbwei;
reg srcwbwe = 1'b0;
wire xldd_selt;
wire divd_selt;
reg divd_sel = 1'b0;
wire [1:0] dwselt;
reg [1:0] dwsel = 2'h0;
wire [1:0] dwselb;
wire [1:0] swselti;
reg [1:0] swselt = 2'h0;
wire [1:0] swsel;
wire [1:0] swselb;
wire [3:0] sbwaitt;
wire sbwait_tmp;
reg sbwait_ = 1'b0;

assign sbwait = sbwait_;

wire resetl = reset_n; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// SBOARD.NET (102) - insexe : fd1q
// SBOARD.NET (103) - dstanw : fd1q
// SBOARD.NET (104) - srcanw : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		insexe <= insexei;
		dstanw[5:0] <= dstanwi[5:0];
		srcanw[5:0] <= srcanwi[5:0];
	end
end

// SBOARD.NET (108) - dstren : or2
assign dstren = dstrrd | dstrwr;

// SBOARD.NET (127) - dsta_reg : niv
assign dsta_reg[5:0] = dstanw[5:0];

// SBOARD.NET (128) - srca_reg : niv
assign srca_reg[5:0] = srcanw[5:0];

// SBOARD.NET (129) - dsta_reg_ena : join
assign dsta_reg_ena = dstrrd;

// SBOARD.NET (130) - srca_reg_ena : or2
assign srca_reg_ena = srcrrd | precomp;

// SBOARD.NET (136) - alu_wbaddr : fd2qp
// SBOARD.NET (141) - alu_wback : fd2qp
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			alu_wbaddr[5:0] <= 6'h0;
			alu_wback <= 1'b0;
		end else begin
			alu_wbaddr[5:0] <= dstanw[5:0];
			alu_wback <= pendwr;
		end
	end
end

// SBOARD.NET (140) - pendwr : an2
assign pendwr = reswr & exe;

// SBOARD.NET (152) - dp1cmp : cmp6
assign dp1eq = alu_wbaddr[5:0] == dsta_reg[5:0];

// SBOARD.NET (153) - sp1cmp : cmp6
assign sp1eq = alu_wbaddr[5:0] == srca_reg[5:0];

// SBOARD.NET (154) - aluwt : aor2
assign aluwt = (dp1eq & dsta_reg_ena) | (sp1eq & srca_reg_ena);

// SBOARD.NET (156) - aludwait : an2
assign aludwait = aluwt & alu_wback;

// SBOARD.NET (162) - moveai : join
assign mov_wbaddr[5:0] = dstanw[5:0];

// SBOARD.NET (163) - mov_wback\ : nd2p
assign mov_wback = (dstwen & exe);

// SBOARD.NET (171) - immasel : an2
assign immasel = immld & exe;

// SBOARD.NET (172) - imm_wbaddr : fdsync6
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (immasel) begin
			imm_wbaddr[5:0] <= dstanw[5:0];
		end
	end
end

// SBOARD.NET (174) - imm_wback : join
assign imm_wback = immwri;

// SBOARD.NET (188) - ildwal : an2
assign ildwal = memrw & exe;

// SBOARD.NET (189) - ild_wbaddr : mx2
assign ild_wbaddr[5:0] = (ildwal) ? dstat[5:0] : ild_wbaddrl[5:0];

// SBOARD.NET (190) - ild_wbaddrl : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			ild_wbaddrl[5:0] <= 6'h0;
		end else begin
			ild_wbaddrl[5:0] <= ild_wbaddr[5:0];
		end
	end
end

// SBOARD.NET (198) - ildwbset\ : nd4
assign ildwbset = (datack & ~datwe & ~del_xld & ~mtx_dover);

// SBOARD.NET (201) - ildwbclr : nd2
assign ildwbclr = (ild_wbackh | ild_wbacks);

// SBOARD.NET (202) - ildwbt : nr2
assign ildwbt = ~(ild_wbackd | ildwbset);

// SBOARD.NET (203) - ild_wbacki : nr2
assign ild_wbacki = ~(ildwbclr | ildwbt);

// SBOARD.NET (204) - ild_wbackd : fd2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			ild_wbackd <= 1'h0;
		end else begin
			ild_wbackd <= ild_wbacki;
		end
	end
end

// SBOARD.NET (206) - ild_wback : nd2
assign ild_wback = (ildwbset | ild_wbackd);

// SBOARD.NET (209) - ilddselt\ : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		ilddselt_n <= ~ildwbset;
	end
end

// SBOARD.NET (211) - ild_data : mx2
assign ild_data[31:0] = (ilddselt_n) ? ild_datad[31:0] : mem_data[31:0];

// SBOARD.NET (212) - ild_datad : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		ild_datad[31:0] <= ild_data[31:0];
	end
end

// SBOARD.NET (216) - idlet[0] : nd2
assign idlet[0] = ~(idle & ~memrw);

// SBOARD.NET (217) - idlet[1] : nd2
assign idlet[1] = ~(idle & ~exe);

// SBOARD.NET (218) - idlet[2] : nd2
assign idlet[2] = ~(loading & datack);

// SBOARD.NET (219) - idlei : nd3
assign idlei = ~(&idlet[2:0]);

// SBOARD.NET (220) - idle : fd4q
// SBOARD.NET (224) - comp1 : fd2q
// SBOARD.NET (227) - comp2 : fd2q
// SBOARD.NET (234) - loading : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			idle <= 1'b1;
			comp1 <= 1'b0;
			comp2 <= 1'b0;
			loading <= 1'b0;
		end else begin
			idle <= idlei;
			comp1 <= comp1i;
			comp2 <= comp2i;
			loading <= loadingi;
		end
	end
end

// SBOARD.NET (223) - comp1i : an4
assign comp1i = idle & memrw & precomp & exe;

// SBOARD.NET (226) - comp2i : join
assign comp2i = comp1;

// SBOARD.NET (230) - loadingt[0] : nd4
assign loadingt[0] = ~(idle & memrw & ~precomp & exe);

// SBOARD.NET (231) - loadingt[1] : iv
assign loadingt[1] = ~comp2;

// SBOARD.NET (232) - loadingt[2] : nd2
assign loadingt[2] = ~(loading & ~datack);

// SBOARD.NET (233) - loadingi : nd3
assign loadingi = ~(&loadingt[2:0]);

// SBOARD.NET (239) - dlacmp : cmp6
assign dlaeq = ild_wbaddrl[5:0] == dsta_reg[5:0];

// SBOARD.NET (240) - slacmp : cmp6
assign slaeq = ild_wbaddrl[5:0] == srca_reg[5:0];

// SBOARD.NET (241) - ldwaitt0 : aor2
assign ldwaitt[0] = (dlaeq & dsta_reg_ena) | (slaeq & srca_reg_ena);

// SBOARD.NET (243) - ldwaitt1 : nd2
assign ldwaitt[1] = ~(ldwaitt[0] & ~idle);

// SBOARD.NET (244) - ldwaitt2 : nd2
assign ldwaitt[2] = ~(~idle & memrw);

// SBOARD.NET (245) - ldwait : nd2
assign ldwait = ~(&ldwaitt[2:1]);

// SBOARD.NET (254) - drqt[0] : nd4
assign drqt[0] = ~(idle & exe & ~precomp & memrw);

// SBOARD.NET (255) - drqt[1] : nd2
assign drqt[1] = ~(drqt[0] & ~comp2);

// SBOARD.NET (256) - drqt[2] : cp_latch
reg drqt_2 = 1'b0;
assign drqt[2] = drqt_2;
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			drqt_2 <= 1'b0;
		end else begin
			drqt_2 <= (~datack & (drqt[1] | drqt[2]));
		end
	end
end

// SBOARD.NET (258) - datreq : oan1
assign sdatreq = (|drqt[2:1]) & ~datack;

// SBOARD.NET (264) - srcaddrldi : an4
assign srcaddrldi = idle & exe & ~precomp & memrw;

// SBOARD.NET (271) - resaddrldi : join
assign resaddrldi = comp1;

// SBOARD.NET (284) - ld1t0 : nd2
assign ld1t[0] = ~(del_xld & ldidle);

// SBOARD.NET (285) - ld1t1 : nd3
assign ld1t[1] = ~(oneld & ~del_xld & ~xldd_sel);

// SBOARD.NET (286) - ld1t2 : nd3
assign ld1t[2] = ~(oneld & del_xld & xldd_sel);

// SBOARD.NET (287) - ld1t3 : nd2
assign ld1t[3] = ~(twold & xldd_sel);

// SBOARD.NET (288) - ld1t4 : nd4
assign oneldi = ~(&ld1t[3:0]);

// SBOARD.NET (289) - oneld : fd2qp
// SBOARD.NET (294) - twold : fd2qp
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			oneld <= 1'b0;
			twold <= 1'b0;
		end else begin
			oneld <= oneldi;
			twold <= twoldi;
		end
	end
end

// SBOARD.NET (291) - ld2t0 : nd3
assign ld2t[0] = ~(oneld & del_xld & ~xldd_sel);

// SBOARD.NET (292) - ld2t1 : nd2
assign ld2t[1] = ~(twold & ~xldd_sel);

// SBOARD.NET (293) - ld2t2 : nd2
assign twoldi = ~(&ld2t[1:0]);

// SBOARD.NET (296) - ldidle : nr2p
assign ldidle = ~(twold | oneld);

// SBOARD.NET (314) - xlddt0 : nd2
assign xlddt[0] = ~(del_xld & ldidle);

// SBOARD.NET (315) - xlddt1 : nd3
assign xlddt[1] = ~(del_xld & oneld & xldd_sel);

// SBOARD.NET (316) - xlddt2 : nd2p
assign xlddt[2] = ~(&xlddt[1:0]);

// SBOARD.NET (317) - xlddt3 : an2p
assign xlddt[3] = xldd_sel & twold;

// SBOARD.NET (318) - xlddsti : mx4
assign xld_wbaddr[5:0] = xlddt[3] ? (xlddst2[5:0]) : (xlddt[2] ? ild_wbaddr[5:0] : xlddst[5:0]);

// SBOARD.NET (320) - xlddst : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			xlddst[5:0] <= 6'h0;
		end else begin
			xlddst[5:0] <= xld_wbaddr[5:0];
		end
	end
end

// SBOARD.NET (322) - xlddst2 : fdsyncr6
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			xlddst2[5:0] <= 6'h0;
		end else begin
			if (del_xld) begin
				xlddst2[5:0] <= ild_wbaddr[5:0];
			end
		end
	end
end

// SBOARD.NET (330) - xlddmatch : cmp6
assign xlddeq = dsta_reg[5:0] == xlddst[5:0];

// SBOARD.NET (331) - xldsmatch : cmp6
assign xldseq = srca_reg[5:0] == xlddst[5:0];

// SBOARD.NET (332) - xldeq : aor2
assign xldeq = (xlddeq & dsta_reg_ena) | (xldseq & srca_reg_ena);

// SBOARD.NET (334) - xld2dmatch : cmp6
assign xld2deq = dsta_reg[5:0] == xlddst2[5:0];

// SBOARD.NET (335) - xld2smatch : cmp6
assign xld2seq = srca_reg[5:0] == xlddst2[5:0];

// SBOARD.NET (336) - xld2eq : aor2
assign xld2eq = (xld2deq & dsta_reg_ena) | (xld2seq & srca_reg_ena);

// SBOARD.NET (339) - xlddwait : aor2
assign xlddwait = (~ldidle & xldeq) | (twold & xld2eq);

// SBOARD.NET (343) - xld_data : fdsync32
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (xld_ready) begin
			xld_data[31:0] <= load_data[31:0];
		end
	end
end

// SBOARD.NET (353) - mbsywt0 : or2
assign mbsywt[0] = gate_active | twoldi;

// SBOARD.NET (354) - mbsywt1 : nd2
assign mbsywt[1] = ~(mbsywt[0] & memrw);

// SBOARD.NET (355) - mbsywt2 : or2
assign mbsywt[2] = oneldi | twoldi;

// SBOARD.NET (356) - mbsywt3 : nd2
assign mbsywt[3] = ~(mbsywt[2] & datwe_raw);

// SBOARD.NET (357) - mbusywait : nd2
assign mbusywait = ~(mbsywt[1] & mbsywt[3]);

// SBOARD.NET (362) - xwbclr : nd2
assign xwbclr = (xld_wbackh | xld_wbacks);

// SBOARD.NET (363) - xwbat0 : nr2
assign xwbat[0] = ~(xld_wbackl | xld_ready);

// SBOARD.NET (364) - xwbat1 : nr2
assign xwbat[1] = ~(xwbclr | xwbat[0]);

// SBOARD.NET (365) - xldpend : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			xld_wbackl <= 1'b0;
		end else begin
			xld_wbackl <= xwbat[1];
		end
	end
end

// SBOARD.NET (366) - xld_wback : or2
assign xld_wback = xld_wbackl | xld_ready;

// SBOARD.NET (375) - div_active : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		div_active <= div_activei;
	end
end

// SBOARD.NET (378) - divdst : fdsyncr6
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			div_wbaddr[5:0] <= 6'h0;
		end else begin
			if (div_start) begin
				div_wbaddr[5:0] <= dstanw[5:0];
			end
		end
	end
end

// SBOARD.NET (380) - divdmatch : cmp6
assign divdeq = dsta_reg[5:0] == div_wbaddr[5:0];

// SBOARD.NET (381) - divsmatch : cmp6
assign divseq = srca_reg[5:0] == div_wbaddr[5:0];

// SBOARD.NET (382) - diveq : aor2
assign diveq = (divdeq & dsta_reg_ena) | (divseq & srca_reg_ena);

// SBOARD.NET (384) - divdwait : an2
assign divdwait = div_active & diveq;

// SBOARD.NET (390) - dwbset : an2
assign dwbset = div_active & ~div_activei;

// SBOARD.NET (391) - dwbclr : nd2
assign dwbclr = (div_wbackh | div_wbacks);

// SBOARD.NET (392) - dwbat0 : nr2
assign dwbat[0] = ~(div_wbackl | dwbset);

// SBOARD.NET (393) - dwbat1 : nr2
assign dwbat[1] = ~(dwbat[0] | dwbclr);

// SBOARD.NET (394) - dwbat2 : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			div_wbackl <= 1'b0;
		end else begin
			div_wbackl <= dwbat[1];
		end
	end
end

// SBOARD.NET (395) - div_wback : or2
assign div_wback = div_wbackl | dwbset;

// SBOARD.NET (402) - diviwait : oan1
assign diviwait = (div_active | div_wback) & div_instr;

// SBOARD.NET (411) - flag_pend : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		flag_pend <= flagld;
	end
end

// SBOARD.NET (412) - flagwait : an2
assign flagwait = flag_pend & flag_depend;

// SBOARD.NET (446) - wbacki : nd6
assign wbacki = (alu_wback | mov_wback | imm_wback | div_wback | xld_wback | ild_wback);

// SBOARD.NET (449) - wback : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		wback <= wbacki;
	end
end

// SBOARD.NET (454) - mov_wbackh : nd2
assign mov_wbackh = (mov_wback & ~alu_wback);

// SBOARD.NET (455) - imm_wbackh : nd3
assign imm_wbackh = (imm_wback & ~mov_wback & ~alu_wback);

// SBOARD.NET (457) - ild_wbackh : nd4p
assign ild_wbackh = (ild_wback & ~imm_wback & ~mov_wback & ~alu_wback);

// SBOARD.NET (459) - xld_wbackh : nd5
assign xld_wbackh = (xld_wback & ~ild_wback & ~imm_wback & ~mov_wback & ~alu_wback);

// SBOARD.NET (461) - div_wbackh : nd6
assign div_wbackh = (div_wback & ~xld_wback & ~ild_wback & ~imm_wback & ~mov_wback & ~alu_wback);

// SBOARD.NET (474) - mov_wbacks : nd2
assign mov_wbacks = (mov_wback & alu_wback);

// SBOARD.NET (477) - imm_wbackst : nd2
assign imm_wbackst = (mov_wbackh | alu_wback);

// SBOARD.NET (478) - imm_wbacks : nd2
assign imm_wbacks = (imm_wback & imm_wbackst);

// SBOARD.NET (482) - ild_wbackst : nd3
assign ild_wbackst = (imm_wbackh | mov_wbackh | alu_wback);

// SBOARD.NET (484) - ild_wbacks : nd4p
assign ild_wbacks = (ild_wback & ild_wbackst & ~imm_wbacks & ~mov_wbacks);

// SBOARD.NET (486) - xld_wbackst : nd4
assign xld_wbackst = (ild_wbackh | imm_wbackh | mov_wbackh | alu_wback);

// SBOARD.NET (488) - xld_wbacks : nd5
assign xld_wbacks = (xld_wback & xld_wbackst & ~imm_wback & ~ild_wbacks & ~mov_wbacks);

// SBOARD.NET (490) - div_wbackst : nd5
assign div_wbackst = (xld_wbackh | ild_wbackh | imm_wbackh | mov_wbackh | alu_wback);

// SBOARD.NET (492) - div_wbacks : nd6
assign div_wbacks = (div_wback & div_wbackst & ~xld_wback & ~imm_wback & ~ild_wbacks & ~mov_wbacks);

// SBOARD.NET (498) - mult_wbacki : nd5
assign mult_wbacki = (mov_wbacks | imm_wbacks | ild_wbacks | xld_wbacks | div_wbacks);

// SBOARD.NET (500) - mult_wback : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		mult_wback <= mult_wbacki;
	end
end

// SBOARD.NET (505) - hasel[0] : nd3
assign hasel[0] = (mov_wbackh | ild_wbackh | div_wbackh);

// SBOARD.NET (507) - hasel[1] : nd2
assign hasel[1] = (imm_wbackh | ild_wbackh);

// SBOARD.NET (508) - hasel[2] : nd2
assign hasel[2] = (xld_wbackh | div_wbackh);

// SBOARD.NET (509) - hwbaddr : mx8p
always @(*)
begin
	case(hasel[2:0])
		3'b000		: hwbaddr[5:0] = alu_wbaddr[5:0];
		3'b001		: hwbaddr[5:0] = mov_wbaddr[5:0];
		3'b010		: hwbaddr[5:0] = imm_wbaddr[5:0];
		3'b011		: hwbaddr[5:0] = ild_wbaddr[5:0];
		3'b100		: hwbaddr[5:0] = xld_wbaddr[5:0];
		3'b101		: hwbaddr[5:0] = div_wbaddr[5:0];
		default		: hwbaddr[5:0] = 6'h0;
	endcase
end

// SBOARD.NET (515) - sasel[0] : nd3
assign sasel[0] = (mov_wbacks | ild_wbacks | div_wbacks);

// SBOARD.NET (517) - sasel[1] : nd2
assign sasel[1] = (imm_wbacks | ild_wbacks);

// SBOARD.NET (518) - sasel[2] : nd2
assign sasel[2] = (xld_wbacks | div_wbacks);

// SBOARD.NET (519) - swbaddr : mx8
always @(*)
begin
	case(sasel[2:0])
		3'b000		: swbaddr[5:0] = alu_wbaddr[5:0];
		3'b001		: swbaddr[5:0] = mov_wbaddr[5:0];
		3'b010		: swbaddr[5:0] = imm_wbaddr[5:0];
		3'b011		: swbaddr[5:0] = ild_wbaddr[5:0];
		3'b100		: swbaddr[5:0] = xld_wbaddr[5:0];
		3'b101		: swbaddr[5:0] = div_wbaddr[5:0];
		default		: swbaddr[5:0] = 6'h0;
	endcase
end

// SBOARD.NET (531) - wbdcmpt[0-5] : enp
assign wbdcmpt[5:0] = ~(hwbaddr[5:0] ^ dstanwi[5:0]);

// SBOARD.NET (532) - wbdeqi\ : nd6
assign wbdeqi_n = ~(&wbdcmpt[5:0]);

// SBOARD.NET (533) - wbdeqit : an4
assign wbdeqit = &wbdcmpt[3:0];

// SBOARD.NET (534) - wbdeqi : an3
assign wbdeqi = wbdeqit & (&wbdcmpt[5:4]);

// SBOARD.NET (536) - wbdeq\ : fd1q
// SBOARD.NET (538) - wbdsq : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		wbdeq_n <= wbdeqi_n;
		wbseq_n <= wbseqi_n;
	end
end

// SBOARD.NET (537) - wbscmp : cmp6i
assign wbseqi_n = hwbaddr[5:0] != srcanwi[5:0];

// SBOARD.NET (539) - bothen : an3
assign bothen = srcrrd & dstren & insexe;

// SBOARD.NET (540) - wbwaitt : nd4
assign wbwaitt = ~(wbdeq_n & wbseq_n & bothen & wback);

// SBOARD.NET (541) - wbwait : nd2
assign wbwait = ~(wbwaitt & ~mult_wback);

// SBOARD.NET (553) - dwbt0 : nd2p
assign dwbt[0] = ~(wbacki & wbdeqi);

// SBOARD.NET (554) - dwbt4 : nd2
assign dwbt[4] = ~(comp1i & datwe);

// SBOARD.NET (555) - dwbt5 : nd2
assign dwbt[5] = ~(insexei & dstrrdi);

// SBOARD.NET (556) - dwbt6 : nd2
assign dwbt[6] = ~(insexei & dstrwri);

// SBOARD.NET (557) - dwbt1 : an3
assign dwbt[1] = &dwbt[6:4];

// SBOARD.NET (558) - dwbt2 : nd2p
assign dwbt[2] = ~(wbacki & dwbt[1]);

// SBOARD.NET (559) - dwbt3 : nd2p
assign dwbt[3] = ~(wbacki & mult_wbacki);

// SBOARD.NET (560) - dstwbwei : nd3
assign dstwbwei = ~(dwbt[0] & &dwbt[3:2]);

// SBOARD.NET (561) - dstwbwe : fd1p
// SBOARD.NET (576) - srcwbwe : fd1qm
// SBOARD.NET (580) - dstwbaddr : fd1q
// SBOARD.NET (585) - srcwbaddr : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		dstwbwet <= dstwbwei;
		srcwbwe <= srcwbwei;
		dstwbaddr[5:0] <= hwbaddr[5:0];
		srcwbaddr[5:0] <= swbaddr[5:0];
	end
end

// SBOARD.NET (562) - dstwbweb : nivm
assign dstwbwe = dstwbwet;

// SBOARD.NET (573) - swbt0 : nd4
assign swbt[0] = ~(wbacki & dwbt[0] & (&dwbt[3:2]));

// SBOARD.NET (574) - swbt1 : nd2
assign swbt[1] = ~(wbacki & mult_wbacki);

// SBOARD.NET (575) - srcwbwei : nd2
assign srcwbwei = ~(&swbt[1:0]);

// SBOARD.NET (581) - dsta : mx2
assign dsta[5:0] = (dstwbwe) ? dstwbaddr[5:0] : dstanw[5:0];

// SBOARD.NET (586) - srca : mx4
assign srca[5:0] = (~dstwbwe) ? (srcwbwe ? dstwbaddr[5:0] : srcanw[5:0]) : (srcwbwe ? srcwbaddr[5:0] : srcanw[5:0]);

// SBOARD.NET (596) - xldd_selt : nd2
assign xldd_selt = (xld_wbackh | xld_wbacks);

// SBOARD.NET (597) - xldd_sel : fd1qu
// SBOARD.NET (600) - divd_sel : fd1qu
// SBOARD.NET (611) - dwsel[0-1] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		xldd_sel <= xldd_selt;
		divd_sel <= divd_selt;
		dwsel[1:0] <= dwselt[1:0];
	end
end

// SBOARD.NET (599) - divd_selt : nd2
assign divd_selt = (div_wbackh | div_wbacks);

// SBOARD.NET (601) - mxdata : mx4
assign mxdata[31:0] = (xldd_sel) ? (xld_data[31:0]) : (divd_sel ? quotient[31:0] : immdata[31:0]);

// SBOARD.NET (609) - dwselt[0] : nd2
assign dwselt[0] = (alu_wback | mov_wbackh);

// SBOARD.NET (610) - dwselt[1] : nd2
assign dwselt[1] = (ild_wbackh | mov_wbackh);

// SBOARD.NET (613) - dstwdmux : mx4
assign dstwd[31:0] = (dwsel[1]) ? (dwsel[0] ? srcdp[31:0] : ild_data[31:0]) : (dwsel[0] ? result[31:0] : mxdata[31:0]);

// SBOARD.NET (622) - swselti[0] : iv
assign swselti[0] = mov_wbacks;

// SBOARD.NET (623) - swselti[1] : nd2
assign swselti[1] = (ild_wbacks | mov_wbacks);

// SBOARD.NET (624) - swselt[0-1] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		swselt[1:0] <= swselti[1:0];
	end
end

// SBOARD.NET (625) - swsel[0-1] : mx2
assign swsel[1:0] = (dstwbwe) ? swselt[1:0] : dwsel[1:0];

// SBOARD.NET (628) - srcwdmux : mx4
assign srcwd[31:0] = (swsel[1]) ? (swsel[0] ? srcdp[31:0] : ild_data[31:0]) : (swsel[0] ? result[31:0] : mxdata[31:0]);

// SBOARD.NET (633) - srcrwen\ : iv
assign srcrwen_n = ~srcwbwe;

// SBOARD.NET (637) - dstrwen\ : iv
assign dstrwen_n = ~dstwbwe;

// SBOARD.NET (641) - sbwaitt0 : nr2
assign sbwaitt[0] = ~(wbwait | divdwait);

// SBOARD.NET (642) - sbwaitt1 : nr2
assign sbwaitt[1] = ~(diviwait | aludwait);

// SBOARD.NET (643) - sbwaitt2 : nr2
assign sbwaitt[2] = ~(flagwait | xlddwait);

// SBOARD.NET (644) - sbwaitt3 : nr2
assign sbwaitt[3] = ~(mbusywait | ldwait);

// SBOARD.NET (646) - sbwait_tmp : nd4p
assign sbwait_tmp = ~(&sbwaitt[3:0]);

// SBOARD.NET (647) - sbwait : sysclkdly
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	sbwait_ <= sbwait_tmp;
end
endmodule
