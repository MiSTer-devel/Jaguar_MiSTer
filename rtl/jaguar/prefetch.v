//`include "defs.v"

module _prefetch
(
	output [24:22] gpu_dout_out,
	output gpu_dout_oe,
	output insrdy,
	output [15:0] instruction,
	output jump_atomic,
	output pabort,
	output progreq,
	output [21:0] progaddr,
	output [23:0] program_count,
	input big_instr,
	input clk,
	input dbgrd,
	input go,
	input [31:0] gpu_data,
	input [31:0] gpu_din,
	input progack,
	input jumprel,
	input jumpabs,
	input pcwr,
	input reset_n,
	input promoldx_n,
	input single_go,
	input single_step,
	input [31:0] srcd,
	input [31:0] srcdp,
	input sys_clk // Generated
);
wire [15:0] inshi;
wire [15:0] inslo;
wire [31:0] insin;
reg [31:0] insdata = 32'h0;
reg [31:0] pfdata = 32'h0;
wire [22:0] pc;
wire single_go_n;
wire [2:0] qs;
wire single_adv;
wire insrdyss;
wire insrdyt;
wire [3:0] jat;
wire jabs;
wire [3:0] jrt;
wire jreli;
reg jrel = 1'b0;
wire jrelb;
wire jrel_n;
wire jump_n;
wire oddjump_n;
wire oddjump;
wire progack_n;
wire promold;
wire promold_n;
wire force0_n;
wire [7:0] q0b;
wire [2:0] qsi;
wire [8:0] q1b;
wire [2:0] q2b;
reg [2:0] qst = 3'h0;
wire insrdy_n;
wire [2:0] insldt;
wire insldt1t;
wire insld;
wire pf1sel;
wire ins_swap_n;
wire ins_swap;
wire [3:0] prst;
wire prst1t;

wire resetl = reset_n; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// PREFETCH.NET (63) - single_go\ : iv
assign single_go_n = ~single_go;

// PREFETCH.NET (65) - dbgrd[22-24] : ts
assign gpu_dout_out[24:22] = qs[2:0];
assign gpu_dout_oe = dbgrd;

// PREFETCH.NET (101) - single_adv : nd2
assign single_adv = ~(single_go_n & single_step);

// PREFETCH.NET (102) - insrdyss : an2
assign insrdyss = insrdyt & single_adv;

// PREFETCH.NET (103) - jat0 : nr2
assign jat[0] = ~(jumpabs | jat[2]);

// PREFETCH.NET (104) - jat1 : nr2
assign jat[1] = ~(insrdyss | jat[0]);

// PREFETCH.NET (105) - jat2 : fd2q
// PREFETCH.NET (111) - jrt2 : fd2q
reg jat2 = 1'b0;
reg jrt2 = 1'b0;
assign jat[2] = jat2;
assign jrt[2] = jrt2;
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			jat2 <= 1'b0;// always @(posedge cp or negedge cd)
			jrt2 <= 1'b0;// always @(posedge cp or negedge cd)
		end else begin
			jat2 <= jat[1];
			jrt2 <= jrt[1];
		end
	end
end

// PREFETCH.NET (106) - jat3 : or2
assign jat[3] = jumpabs | jat[2];

// PREFETCH.NET (107) - jabs : an2
assign jabs = jat[3] & insrdyss;

// PREFETCH.NET (109) - jrt0 : nr2
assign jrt[0] = ~(jumprel | jrt[2]);

// PREFETCH.NET (110) - jrt1 : nr2
assign jrt[1] = ~(insrdyss | jrt[0]);

// PREFETCH.NET (112) - jrt3 : or2
assign jrt[3] = jumprel | jrt[2];

// PREFETCH.NET (113) - jreli : an2
assign jreli = jrt[3] & insrdyss;

// PREFETCH.NET (114) - jrel : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		jrel <= jreli;
	end
end

// PREFETCH.NET (115) - jrelb : nivu
assign jrelb = jrel;

// PREFETCH.NET (116) - jrel\ : iv
assign jrel_n = ~jrel;

// PREFETCH.NET (120) - jump_atomic : or4
assign jump_atomic = jumprel | jumpabs | jat[2] | jrt[2];

// PREFETCH.NET (123) - jump\ : nr2m
assign jump_n = ~(jrelb | jabs);

// PREFETCH.NET (124) - oddjmp\ : iv
assign oddjump_n = ~oddjump;

// PREFETCH.NET (125) - prgack\ : iv
assign progack_n = ~progack;

// PREFETCH.NET (126) - romold : ivm
assign promold = ~promoldx_n;

// PREFETCH.NET (127) - romold\ : nivm
assign promold_n = promoldx_n;

// PREFETCH.NET (129) - force0 : an2
assign force0_n = jump_n & go;

// PREFETCH.NET (137) - q0b0 : nd6
assign q0b[0] = ~((qs[2:0] == 3'd0) & progack & oddjump & go);//size==0+2-1

// PREFETCH.NET (139) - q0b1 : nd5
assign q0b[1] = ~((qs[2:0] == 3'd1) & progack_n & promold_n);//size==1+0-0

// PREFETCH.NET (140) - q0b2 : nd5
assign q0b[2] = ~((qs[2:0] == 3'd2) & progack_n & promold);//size==2+0-1

// PREFETCH.NET (142) - q0b3 : nd5
assign q0b[3] = ~((qs[2:0] == 3'd1) & progack & promold_n);//size==1+2-0

// PREFETCH.NET (143) - q0b4 : nd5
assign q0b[4] = ~((qs[2:0] == 3'd2) & progack & promold);//size==2+2-1

// PREFETCH.NET (144) - q0b5 : nd4
assign q0b[5] = ~((qs[2:0] == 3'd3) & promold_n);//size==3+0-0

// PREFETCH.NET (145) - q0b6 : nd4
assign q0b[6] = ~((qs[2:0] == 3'd4) & promold);//size==4+0-1

// PREFETCH.NET (146) - q0b7 : nd7
assign q0b[7] = ~(&q0b[6:0]);// bit0= result=1or3

// PREFETCH.NET (147) - qi0 : an2
assign qsi[0] = q0b[7] & force0_n;

// PREFETCH.NET (150) - q1b0 : nd6
assign q1b[0] = ~((qs[2:0] == 3'd0) & progack & oddjump_n & go);//size==0+2-0

// PREFETCH.NET (152) - q1b1 : nd5
assign q1b[1] = ~((qs[2:0] == 3'd1) & progack & promold);//size==1+2-1

// PREFETCH.NET (153) - q1b2 : nd5
assign q1b[2] = ~((qs[2:0] == 3'd2) & progack_n & promold_n);//size==2+0-0

// PREFETCH.NET (154) - q1b3 : nd4
assign q1b[3] = ~((qs[2:0] == 3'd3) & promold);//size==3+0-1

// PREFETCH.NET (156) - q1b4 : nd5
assign q1b[4] = ~((qs[2:0] == 3'd1) & progack & promold_n);//size==1+2-0

// PREFETCH.NET (157) - q1b5 : nd5
assign q1b[5] = ~((qs[2:0] == 3'd2) & progack & promold);//size==2+2-1

// PREFETCH.NET (158) - q1b6 : nd4
assign q1b[6] = ~((qs[2:0] == 3'd3) & promold_n);//size==3+0-0

// PREFETCH.NET (159) - q1b7 : nd4
assign q1b[7] = ~((qs[2:0] == 3'd4) & promold);//size==4+0-1

// PREFETCH.NET (160) - q1b8 : nd8
assign q1b[8] = ~(&q1b[7:0]);// bit1= result=2or3

// PREFETCH.NET (161) - qi1 : an2
assign qsi[1] = q1b[8] & force0_n;

// PREFETCH.NET (164) - q2b0 : nd5
assign q2b[0] = ~((qs[2:0] == 3'd2) & progack & promold_n);//size==2+2-0

// PREFETCH.NET (165) - q2b1 : nd4
assign q2b[1] = ~((qs[2:0] == 3'd4) & promold_n);//size==4+0-0

// PREFETCH.NET (166) - q2b2 : nd2
assign q2b[2] = ~(&q2b[1:0]);// bit2= result=4

// PREFETCH.NET (167) - qi2 : an2
assign qsi[2] = q2b[2] & force0_n;

// PREFETCH.NET (169) - qst[0-2] : fd2qp
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			qst[2:0] <= 3'h0;// always @(posedge cp or negedge cd)
		end else begin
			qst[2:0] <= qsi[2:0];
		end
	end
end

// PREFETCH.NET (170) - qs[0] : nivu
// PREFETCH.NET (171) - qs[1-2] : nivm
assign qs[2:0] = qst[2:0];

// PREFETCH.NET (177) - insrdyt : nd3p
assign insrdyt = ~(qs[2:0] == 3'd0);

// PREFETCH.NET (178) - insrdy\ : nd2
assign insrdy_n = ~(insrdyt & jrel_n);

// PREFETCH.NET (179) - insrdy : ivh
assign insrdy = ~insrdy_n;

// PREFETCH.NET (199) - insldt0 : nd4
assign insldt[0] = ~((qs[2:0] == 3'd0) & progack);

// PREFETCH.NET (200) - insldt1t : an3
assign insldt1t = (qs[2:0] == 3'd1);

// PREFETCH.NET (201) - insldt1 : nd3
assign insldt[1] = ~(insldt1t & promold & progack);

// PREFETCH.NET (202) - insldt2 : nd4
assign insldt[2] = ~((qs[2:0] == 3'd3) & promold);

// PREFETCH.NET (203) - insldt : nd3p
// PREFETCH.NET (204) - insld : nivu3
assign insld = ~(&insldt[2:0]);

// PREFETCH.NET (206) - pfbuf1 : fdsyncr32
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			pfdata[31:0] <= 32'h0;
		end else if (progack) begin
			pfdata[31:0] <= gpu_data[31:0];
		end
	end
end

// PREFETCH.NET (209) - pf1selt : an3u
assign pf1sel = (qs[2:0] == 3'd3);

// PREFETCH.NET (211) - inssel : mx4
assign insin[31:0] = insld ? (pf1sel ? pfdata[31:0] : gpu_data[31:0]) : (insdata[31:0]); //inverted ordr to simplify

// PREFETCH.NET (213) - insdata : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			insdata[31:0] <= 32'h0;
		end else begin
			insdata[31:0] <= insin[31:0];
		end
	end
end

// PREFETCH.NET (217) - inshi : join
assign inshi[15:0] = insdata[31:16];

// PREFETCH.NET (218) - inslo : join
assign inslo[15:0] = insdata[15:0];

// PREFETCH.NET (219) - ins_swap\ : enp
assign ins_swap_n = ~(qst[0] ^ big_instr);

// PREFETCH.NET (220) - ins_swap : ivm
assign ins_swap = ~ins_swap_n;

// PREFETCH.NET (221) - instr : mx2
assign instruction[15:0] = (ins_swap) ? inshi[15:0] : inslo[15:0];

// PREFETCH.NET (236) - prst0 : nd5
assign prst[0] = ~((qs[2:0] == 3'd0) & go & jump_n);

// PREFETCH.NET (237) - prst1t : nd2
assign prst1t = ~(progack & promold_n);

// PREFETCH.NET (238) - prst1 : nd5
assign prst[1] = ~((qs[2:0] == 3'd1) & prst1t & jump_n);

// PREFETCH.NET (239) - prst2 : nd5
assign prst[2] = ~((qs[2:0] == 3'd2) & progack_n & jump_n);

// PREFETCH.NET (240) - prst3 : nd5
assign prst[3] = ~((qs[2:0] == 3'd3) & promold & jump_n);

// PREFETCH.NET (241) - progreq : nd4p
assign progreq = ~(&prst[3:0]);

// PREFETCH.NET (245) - pabort : or2p
assign pabort = jrel | jabs;

// PREFETCH.NET (249) - pc : pc
_pc pc_inst
(
	.pc /* OUT */ (pc[22:0]),
	.program_count /* OUT */ (program_count[23:0]),
	.clk /* IN */ (clk),
	.go /* IN */ (go),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.progack /* IN */ (progack),
	.jabs /* IN */ (jabs),
	.jrel /* IN */ (jrelb),
	.pcwr /* IN */ (pcwr),
	.qs_n /* IN */ (~qs[2:0]),
	.reset_n /* IN */ (reset_n),
	.srcd /* IN */ (srcd[31:0]),
	.srcdp /* IN */ (srcdp[31:0]),
	.sys_clk(sys_clk) // Generated
);

// PREFETCH.NET (252) - oddjump : join
assign oddjump = pc[0];

// PREFETCH.NET (253) - progadr : join
assign progaddr[21:0] = pc[22:1];
endmodule
