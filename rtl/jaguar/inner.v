//`include "defs.v"

module _inner
(
	output [10:2] gpu_dout_10_2_out,
	output gpu_dout_10_2_oe, //statrd; already handled above
	output [31:16] gpu_dout_31_16_out,
	output gpu_dout_31_16_oe, //statrd; already handled above
	output apipe,
	output [1:0] atick,
	output aticki_0,
	output data_ena,
	output dest_cycle_1,
	output [1:0] dpipe,
	output dsta_addi,
	output dstdread,
	output dstzread,
	output dwrite,
	output dwrite1,
	output dzwrite,
	output dzwrite1,
	output gena2,
	output [2:0] icount,
	output indone,
	output inner0,
	output readreq,
	output srca_addi,
	output srcdread,
	output srcdreadd,
	output srcen,
	output srczread,
	output sread_1,
	output sreadx_1,
	output step,
	output writereq,
	output zaddr,
	output [1:0] zpipe,
	input a1_outside,
	input blitack,
	input clk,
	input cmdld,
	input countld,
	input dsta2,
	input [15:0] dstxp,
	input gourd,
	input gourz,
	input [31:0] gpu_din,
	input inhiben,
	input instart,
	input memidle,
	input memready,
	input nowrite,
	input phrase_mode,
	input [2:0] pixsize,
	input read_ack,
	input reset_n,
	input srcshade,
	input statrd,
	input wactive,
	input sys_clk // Generated
);
reg idle = 1'b1;
reg sreadx = 1'b0;
reg szreadx = 1'b0;
reg sread = 1'b0;
reg szread = 1'b0;
reg dread = 1'b0;
reg dzread = 1'b0;
reg srcenz = 1'b0;
reg srcenx = 1'b0;
reg dsten = 1'b0;
reg dstenz = 1'b0;
reg dstwrz = 1'b0;
reg diso_a1 = 1'b0;
wire stupt;
reg stupl = 1'b0;
wire stupi;
wire startup;
wire [6:0] dnrt;
reg dzread_1 = 1'b0;
wire dstzack_n;
reg dread_1 = 1'b0;
wire dstdack_n;
reg szread_1 = 1'b0;
wire srczack_n;
wire srcdack_n;
wire srcdxack_n;
wire dnreadyd;
wire dnready_n;
wire mready_n;
wire mready;
wire [1:0] istept;
wire istep_n;
wire stept_n;
wire aready;
wire stepp1t_n;
wire step_p1;
wire [2:0] idlet;
wire idlei;
wire [1:0] sreadxt;
wire sreadxi;
wire [1:0] szreadxt;
wire szreadxi;
wire [5:0] sreadt;
wire sreadi;
wire [1:0] szreadt;
wire szreadi;
wire [6:0] dreadt;
wire dreadi;
wire [7:0] dzreadt;
wire dzreadi;
wire [8:0] dwritet;
wire dwritei;
wire [1:0] dzwritet;
wire dzwritei;
wire [1:0] atick0t;
wire [1:0] atick_n;
wire indone_n;
wire atickt_1;
wire dpipe0t;
wire dpipe1t0;
reg dpipe1t1 = 1'b0;
wire zpipe0t;
wire zpipe1t0;
reg zpipe1t1 = 1'b0;
wire [1:0] indot;
wire indone_tmp;
wire icntena;
wire oldoutld;
reg srca_add = 1'b0;
wire oldoutside;
reg oldoutsidel = 1'b0;
wire outside;
wire clip_n;
wire rreqt;
wire wreqt;
wire [1:0] sraat;
wire dstaat;
wire gensrc;
wire gendst;
wire dsta2_n;
wire [1:0] gena2t;
wire gena2i;
wire srczxack_n;
reg srcdxpend = 1'b0;
reg srczxpend = 1'b0;
reg srcdpend = 1'b0;
reg srczpend = 1'b0;
reg dstdpend = 1'b0;
wire srcdpset_n;
wire [2:1] srcdpt;
wire srcdxpset_n;
wire [2:1] srcdxpt;
wire sdpend;
wire srcdreadt;
wire srczpset_n;
wire [2:1] srczpt;
wire srczxpset_n;
wire [2:1] srczxpt;
wire szpend;
wire dstdpset_n;
wire [1:0] dstdpt;
wire dstzpset_n;
wire [1:0] dstzpt;
reg dstzpend = 1'b0;
wire [3:0] denat;
reg denat_2 = 1'b0;

// Output buffers
reg [1:0] atick_obuf = 2'b00;
wire aticki_0_obuf;
reg dwrite_obuf = 1'b0;
reg dwrite1_obuf = 1'b0;
reg dzwrite_obuf = 1'b0;
reg dzwrite1_obuf = 1'b0;
wire inner0_obuf;
wire readreq_obuf;
wire srca_addi_obuf;
reg srcdreadd_obuf = 1'b0;
reg srcen_obuf = 1'b0;
reg sread_1_obuf = 1'b0;
reg sreadx_1_obuf = 1'b0;
wire step_obuf;
wire writereq_obuf;
reg indone_ = 1'b0;
reg gena2_ = 1'b0;
reg data_ena_ = 1'b0;
 
wire resetl = reset_n;
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign atick[1:0] = atick_obuf[1:0];
assign aticki_0 = aticki_0_obuf;
assign dwrite = dwrite_obuf;
assign dwrite1 = dwrite1_obuf;
assign dzwrite = dzwrite_obuf;
assign dzwrite1 = dzwrite1_obuf;
assign inner0 = inner0_obuf;
assign readreq = readreq_obuf;
assign srca_addi = srca_addi_obuf;
assign srcdreadd = srcdreadd_obuf;
assign srcen = srcen_obuf;
assign sread_1 = sread_1_obuf;
assign sreadx_1 = sreadx_1_obuf;
assign step = step_obuf;
assign writereq = writereq_obuf;
assign indone = indone_;
assign gena2 = gena2_;
assign data_ena = data_ena_;
assign denat[2] = denat_2;

// INNER.NET (83) - stat[2] : ts
// INNER.NET (84) - stat[3] : ts
// INNER.NET (85) - stat[4] : ts
// INNER.NET (86) - stat[5] : ts
// INNER.NET (87) - stat[6] : ts
// INNER.NET (88) - stat[7] : ts
// INNER.NET (89) - stat[8] : ts
// INNER.NET (90) - stat[9] : ts
// INNER.NET (91) - stat[10] : ts
assign gpu_dout_10_2_out[2] = idle;
assign gpu_dout_10_2_out[3] = sreadx;
assign gpu_dout_10_2_out[4] = szreadx;
assign gpu_dout_10_2_out[5] = sread;
assign gpu_dout_10_2_out[6] = szread;
assign gpu_dout_10_2_out[7] = dread;
assign gpu_dout_10_2_out[8] = dzread;
assign gpu_dout_10_2_out[9] = dwrite_obuf;
assign gpu_dout_10_2_out[10] = dzwrite_obuf;
assign gpu_dout_10_2_oe = statrd;

// INNER.NET (101) - srcen : fdsync
// INNER.NET (102) - srcenz : fdsync
// INNER.NET (103) - srcenx : fdsync
// INNER.NET (104) - dsten : fdsync
// INNER.NET (105) - dstenzt : fdsync
// INNER.NET (106) - dstenz : nivm
// INNER.NET (107) - dstwrz : fdsync
// INNER.NET (108) - diso_a1 : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (cmdld) begin
			srcen_obuf <= gpu_din[0];
			srcenz <= gpu_din[1];
			srcenx <= gpu_din[2];
			dsten <= gpu_din[3];
			dstenz <= gpu_din[4];
			dstwrz <= gpu_din[5];
			diso_a1 <= gpu_din[6];
		end
	end
end

// INNER.NET (114) - stupt : nd2
assign stupt = ~(idle & stupl);

// INNER.NET (115) - stupi : nd2
assign stupi = ~(~instart & stupt);

// INNER.NET (116) - stupl : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			stupl <= 1'b0;
		end else begin
			stupl <= stupi;
		end
	end
end

// INNER.NET (117) - startup : or2
assign startup = instart | stupl;

// INNER.NET (158) - dnrt0 : nd2
assign dnrt[0] = ~(dzread_1 & dstzack_n);

// INNER.NET (159) - dnrt1 : nd3
assign dnrt[1] = ~(dread_1 & ~dstenz & dstdack_n);

// INNER.NET (160) - dnrt2 : nd4
assign dnrt[2] = ~(szread_1 & ~dsten & ~dstenz & srczack_n);

// INNER.NET (162) - dnrt3 : nd5
assign dnrt[3] = ~(sread_1_obuf & ~srcenz & ~dsten & ~dstenz & srcdack_n);

// INNER.NET (164) - dnrt4 : nd6
assign dnrt[4] = ~(sreadx_1_obuf & ~srcenz & ~srcen & ~dsten & ~dstenz & srcdxack_n);

// INNER.NET (166) - dnrt5 : nd5
assign dnrt[5] = ~(&dnrt[4:0]);

// INNER.NET (167) - dnrt6 : fd1q
reg dnrt_6 = 1'b0;
assign dnrt[6] = dnrt_6;
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		dnrt_6 <= dnrt[5];
	end
end

// INNER.NET (168) - dnreadyd : aor1
assign dnreadyd = (srcshade & gourz) | inhiben;

// INNER.NET (169) - dnready : mxi2
assign dnready_n = dnreadyd ? ~dnrt[6] : ~dnrt[5];

// INNER.NET (171) - mready\ : nr2
assign mready_n = ~(memready | memidle);

// INNER.NET (172) - mready : iv
assign mready = ~mready_n;

// INNER.NET (173) - istept0 : or2
assign istept[0] = dwrite1_obuf | dzwrite1_obuf;

// INNER.NET (174) - istept1 : nd2
assign istept[1] = ~(istept[0] & mready_n);

// INNER.NET (175) - istep : nd3
assign istep_n = ~(idle & startup & istept[1]);

// INNER.NET (176) - stept : nd4
assign stept_n = ~(aready & mready & dnready_n & ~idle);

// INNER.NET (177) - step : nd2u
assign step_obuf = ~(stept_n & istep_n);

// INNER.NET (183) - stepp1t : nd3
assign stepp1t_n = ~(aready & mready & dnready_n);

// INNER.NET (184) - step_p1 : nd2m
assign step_p1 = ~(stepp1t_n & istep_n);

// INNER.NET (203) - idlet0 : nd2
assign idlet[0] = ~(idle & ~step);

// INNER.NET (204) - idlet1 : nd3
assign idlet[1] = ~(dzwrite_obuf & step_obuf & inner0_obuf);

// INNER.NET (205) - idlet2 : nd4
assign idlet[2] = ~(dwrite_obuf & step_obuf & ~dstwrz & inner0_obuf);

// INNER.NET (206) - idlet3 : nd3
assign idlei = ~(&idlet[2:0]);

// INNER.NET (207) - idlet : fd4q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			idle <= 1'b1;
		end else begin
			idle <= idlei;
		end
	end
end

// INNER.NET (213) - sreadxt0 : nd3
assign sreadxt[0] = ~(idle & step_obuf & srcenx);

// INNER.NET (214) - sreadxt1 : nd2
assign sreadxt[1] = ~(sreadx & ~step);

// INNER.NET (215) - sreadxt2 : nd2
assign sreadxi = ~(&sreadxt[1:0]);

// INNER.NET (216) - sreadx : fd2qm
// INNER.NET (223) - szreadx : fd2q
// INNER.NET (235) - sread : fd2qm
// INNER.NET (242) - szread : fd2qm
// INNER.NET (258) - dread : fd2q
// INNER.NET (276) - dzread : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			sreadx <= 1'b0;
			szreadx <= 1'b0;
			sread <= 1'b0;
			szread <= 1'b0;
			dread <= 1'b0;
			dzread <= 1'b0;
		end else begin
			sreadx <= sreadxi;
			szreadx <= szreadxi;
			sread <= sreadi;
			szread <= szreadi;
			dread <= dreadi;
			dzread <= dzreadi;
		end
	end
end

// INNER.NET (220) - szreadxt0 : nd3
assign szreadxt[0] = ~(sreadx & step_obuf & srcenz);

// INNER.NET (221) - szreadxt1 : nd2
assign szreadxt[1] = ~(szreadx & ~step);

// INNER.NET (222) - szreadxt2 : nd2
assign szreadxi = ~(&szreadxt[1:0]);

// INNER.NET (227) - sreadt0 : nd2
assign sreadt[0] = ~(szreadx & step_obuf);

// INNER.NET (228) - sreadt1 : nd4
assign sreadt[1] = ~(sreadx & step_obuf & ~srcenz & srcen_obuf);

// INNER.NET (229) - sreadt2 : nd4
assign sreadt[2] = ~(idle & step_obuf & ~srcenx & srcen_obuf);

// INNER.NET (230) - sreadt3 : nd4
assign sreadt[3] = ~(dzwrite_obuf & step_obuf & ~inner0 & srcen_obuf);

// INNER.NET (231) - sreadt4 : nd5
assign sreadt[4] = ~(dwrite_obuf & step_obuf & ~dstwrz & ~inner0 & srcen_obuf);

// INNER.NET (233) - sreadt5 : nd2
assign sreadt[5] = ~(sread & ~step);

// INNER.NET (234) - sreadt6 : nd6
assign sreadi = ~(&sreadt[5:0]);

// INNER.NET (239) - szreadt0 : nd3
assign szreadt[0] = ~(sread & step_obuf & srcenz);

// INNER.NET (240) - szreadt1 : nd2
assign szreadt[1] = ~(szread & ~step);

// INNER.NET (241) - szreadt2 : nd2
assign szreadi = ~(&szreadt[1:0]);

// INNER.NET (246) - dreadt0 : nd3
assign dreadt[0] = ~(szread & step_obuf & dsten);

// INNER.NET (247) - dreadt1 : nd4
assign dreadt[1] = ~(sread & step_obuf & ~srcenz & dsten);

// INNER.NET (248) - dreadt2 : nd5
assign dreadt[2] = ~(sreadx & step_obuf & ~srcenz & ~srcen & dsten);

// INNER.NET (250) - dreadt3 : nd5
assign dreadt[3] = ~(idle & step_obuf & ~srcenx & ~srcen & dsten);

// INNER.NET (252) - dreadt4 : nd5
assign dreadt[4] = ~(dzwrite_obuf & step_obuf & ~inner0 & ~srcen & dsten);

// INNER.NET (254) - dreadt5 : nd6
assign dreadt[5] = ~(dwrite_obuf & step_obuf & ~dstwrz & ~inner0 & ~srcen & dsten);

// INNER.NET (256) - dreadt6 : nd2
assign dreadt[6] = ~(dread & ~step);

// INNER.NET (257) - dreadt7 : nd7
assign dreadi = ~(&dreadt[6:0]);

// INNER.NET (262) - dzreadt0 : nd3
assign dzreadt[0] = ~(dread & step_obuf & dstenz);

// INNER.NET (263) - dzreadt1 : nd4
assign dzreadt[1] = ~(szread & step_obuf & ~dsten & dstenz);

// INNER.NET (264) - dzreadt2 : nd5
assign dzreadt[2] = ~(sread & step_obuf & ~srcenz & ~dsten & dstenz);

// INNER.NET (266) - dzreadt3 : nd6
assign dzreadt[3] = ~(sreadx & step_obuf & ~srcenz & ~srcen & ~dsten & dstenz);

// INNER.NET (268) - dzreadt4 : nd6
assign dzreadt[4] = ~(idle & step_obuf & ~srcenx & ~srcen & ~dsten & dstenz);

// INNER.NET (270) - dzreadt5 : nd6
assign dzreadt[5] = ~(dzwrite_obuf & step_obuf & ~inner0 & ~srcen & ~dsten & dstenz);

// INNER.NET (272) - dzreadt6 : nd7
assign dzreadt[6] = ~(dwrite_obuf & step_obuf & ~dstwrz & ~inner0 & ~srcen & ~dsten & dstenz);

// INNER.NET (274) - dzreadt7 : nd2
assign dzreadt[7] = ~(dzread & ~step);

// INNER.NET (275) - dzreadt8 : nd8
assign dzreadi = ~(&dzreadt[7:0]);

// INNER.NET (280) - dwritet0 : nd2
assign dwritet[0] = ~(dzread & step_obuf);

// INNER.NET (281) - dwritet1 : nd3
assign dwritet[1] = ~(dread & step_obuf & ~dstenz);

// INNER.NET (282) - dwritet2 : nd4
assign dwritet[2] = ~(szread & step_obuf & ~dsten & ~dstenz);

// INNER.NET (283) - dwritet3 : nd5
assign dwritet[3] = ~(sread & step_obuf & ~srcenz & ~dsten & ~dstenz);

// INNER.NET (285) - dwritet4 : nd6
assign dwritet[4] = ~(sreadx & step_obuf & ~srcenz & ~srcen & ~dsten & ~dstenz);

// INNER.NET (287) - dwritet5 : nd6
assign dwritet[5] = ~(idle & step_obuf & ~srcenx & ~srcen & ~dsten & ~dstenz);

// INNER.NET (289) - dwritet6 : nd6
assign dwritet[6] = ~(dzwrite_obuf & step_obuf & ~inner0 & ~srcen & ~dsten & ~dstenz);

// INNER.NET (291) - dwritet7 : nd7
assign dwritet[7] = ~(dwrite_obuf & step_obuf & ~dstwrz & ~inner0 & ~srcen & ~dsten & ~dstenz);

// INNER.NET (293) - dwritet8 : nd2
assign dwritet[8] = ~(dwrite_obuf & ~step);

// INNER.NET (294) - dwritet9 : nd9
assign dwritei = ~(&dwritet[8:0]);

// INNER.NET (295) - dwrite : fd2qh
// INNER.NET (302) - dzwrite : fd2qu
// INNER.NET (312) - atick0 : fd2h
// INNER.NET (314) - atick1 : fd2qp
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			dwrite_obuf <= 1'b0;
			dzwrite_obuf <= 1'b0;
			atick_obuf[0] <= 1'b0;
			atick_obuf[1] <= 1'b0;
		end else begin
			dwrite_obuf <= dwritei;
			dzwrite_obuf <= dzwritei;
			atick_obuf[0] <= aticki_0_obuf;
			atick_obuf[1] <= atick_obuf[0];
		end
	end
end

// INNER.NET (299) - dzwritet0 : nd2
assign dzwritet[0] = ~(dzwrite_obuf & ~step);

// INNER.NET (300) - dzwritet1 : nd3
assign dzwritet[1] = ~(dwrite_obuf & step_obuf & dstwrz);

// INNER.NET (301) - dzwritet2 : nd2
assign dzwritei = ~(&dzwritet[1:0]);

// INNER.NET (309) - atick0t0 : nd4
assign atick0t[0] = ~(&(~atick[1:0]) & step_obuf & indone_n);

// INNER.NET (310) - atick0t1 : nd3
assign atick0t[1] = ~(atick_obuf[1] & step_obuf & indone_n);

// INNER.NET (311) - atick0t2 : nd2
assign aticki_0_obuf = ~(&atick0t[1:0]);

// INNER.NET (320) - aready : join
assign aready = ~atick[0];

// INNER.NET (324) - apipe : niv
assign apipe = atick_obuf[1];

// INNER.NET (337) - dpipe0t : nd2
assign dpipe0t = ~(atick_obuf[1] & dwrite_obuf);

// INNER.NET (338) - dpipe[0] : nd2
assign dpipe[0] = ~(dpipe0t & gourd);

// INNER.NET (339) - dpipe1t0 : an2
assign dpipe1t0 = writereq_obuf & dwrite_obuf;

// INNER.NET (340) - dpipe1t1 : fd1q
// INNER.NET (353) - zpipe1t1 : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		dpipe1t1 <= dpipe1t0;
		zpipe1t1 <= zpipe1t0;
	end
end

// INNER.NET (341) - dpipe[1] : or2
assign dpipe[1] = dpipe1t1 | ~gourd;

// INNER.NET (349) - zpipe0t0 : nd2
assign zpipe0t = ~(atick_obuf[0] & dzwrite_obuf);

// INNER.NET (350) - zpipe0t1 : nd2
assign zpipe[0] = ~(zpipe0t & gourz);

// INNER.NET (352) - zpipe1t0 : an2
assign zpipe1t0 = writereq_obuf & dzwrite_obuf;

// INNER.NET (354) - zpipe[1] : or2p
assign zpipe[1] = zpipe1t1 | ~gourz;

// INNER.NET (359) - indot0 : nd3
assign indot[0] = ~(dzwrite_obuf & step_obuf & inner0_obuf);

// INNER.NET (360) - indot1 : nd4
assign indot[1] = ~(dwrite_obuf & step_obuf & ~dstwrz & inner0_obuf);

// INNER.NET (363) - indone_tmp : nd2p
assign indone_tmp = ~(&indot[1:0]);

// INNER.NET (364) - indone\ : iv
assign indone_n = ~indone_tmp;

// INNER.NET (365) - indone : sysclkdly
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	indone_ <= indone_tmp;
end

// INNER.NET (371) - icntena : an2u
assign icntena = atick_obuf[0] & dwrite_obuf;

// INNER.NET (373) - inner_count : inner_cnt
_inner_cnt inner_count_inst
(
	.gpu_dout_out /* BUS */ (gpu_dout_31_16_out[31:16]),
	.gpu_dout_31_16_oe /* BUS */ (gpu_dout_31_16_oe), //= statrtd; handled above
	.icount /* OUT */ (icount[2:0]),
	.inner0 /* OUT */ (inner0_obuf),
	.clk /* IN */ (clk),
	.countld /* IN */ (countld),
	.dstxp /* IN */ (dstxp[15:0]),
	.gpu_din /* IN */ (gpu_din[31:0]),
	.icntena /* IN */ (icntena),
	.ireload /* IN */ (instart),
	.phrase_mode /* IN */ (phrase_mode),
	.pixsize /* IN */ (pixsize[2:0]),
	.statrd /* IN */ (statrd),
	.sys_clk(sys_clk) // Generated
);

// INNER.NET (389) - oldoutld : an2
assign oldoutld = srca_add & atick_obuf[1];

// INNER.NET (390) - oldoutside : mx2
assign oldoutside = (oldoutld) ? a1_outside : oldoutsidel;

// INNER.NET (392) - oldoutsidel : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		oldoutsidel <= oldoutside;
	end
end

// INNER.NET (393) - outside : mx2
assign outside = (dsta2) ? oldoutside : a1_outside;

// INNER.NET (394) - clip\ : nd2
assign clip_n = ~(diso_a1 & outside);

// INNER.NET (401) - rreqt : or6
assign rreqt = sreadx | szreadx | sread | szread | dread | dzread;

// INNER.NET (403) - readreq : an2p
assign readreq_obuf = rreqt & step_obuf;

// INNER.NET (404) - wreqt : or2
assign wreqt = dwrite_obuf | dzwrite_obuf;

// INNER.NET (405) - writereq : an4
assign writereq_obuf = wreqt & step_obuf & ~nowrite & clip_n;

// INNER.NET (410) - sraat0 : an2
assign sraat[0] = sreadxi & ~srcenz;

// INNER.NET (411) - sraat1 : an2
assign sraat[1] = sreadi & ~srcenz;

// INNER.NET (412) - srca_addi : or4
assign srca_addi_obuf = szreadxi | szreadi | |sraat[1:0];

// INNER.NET (413) - srca_add : fd1q
// INNER.NET (428) - gena2 : fd1qu
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		srca_add <= srca_addi_obuf;
		gena2_ <= gena2i;
	end
end

// INNER.NET (415) - dstaat : an2
assign dstaat = dwritei & ~dstwrz;

// INNER.NET (416) - dsta_addi : or2
assign dsta_addi = dzwritei | dstaat;

// INNER.NET (420) - gensrc : or4
assign gensrc = sreadxi | szreadxi | sreadi | szreadi;

// INNER.NET (422) - gendst : or4
assign gendst = dreadi | dzreadi | dwritei | dzwritei;

// INNER.NET (424) - dsta2\ : iv
assign dsta2_n = ~dsta2;

// INNER.NET (425) - gena2t0 : nd2
assign gena2t[0] = ~(gensrc & dsta2_n);

// INNER.NET (426) - gena2t1 : nd2
assign gena2t[1] = ~(gendst & dsta2);

// INNER.NET (427) - gena2i : nd2
assign gena2i = ~(&gena2t[1:0]);

// INNER.NET (430) - zaddr : or4
assign zaddr = szreadx | szread | dzread | dzwrite_obuf;

// INNER.NET (434) - sreadx1 : fdsyncr
// INNER.NET (436) - sread1 : fdsyncr
// INNER.NET (438) - szread1 : fdsyncr
// INNER.NET (440) - dread1 : fdsyncr
// INNER.NET (442) - dzread1 : fdsyncr
// INNER.NET (444) - dwrite1 : fdsync
// INNER.NET (445) - dzwrite1 : fdsync
// INNER.NET (529) - denat2 : fdsyncr
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			sreadx_1_obuf <= 1'b0;
			sread_1_obuf <= 1'b0;
			szread_1 <= 1'b0;
			dread_1 <= 1'b0;
			dzread_1 <= 1'b0;
			denat_2 <= 1'b0;
		end else begin
			if (step_p1) begin
				sreadx_1_obuf <= sreadx;
				sread_1_obuf <= sread;
				szread_1 <= szread;
				dread_1 <= dread;
				dzread_1 <= dzread;
				denat_2 <= denat[1];
			end
		end
	end
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (step_p1) begin
			dwrite1_obuf <= dwrite_obuf;
			dzwrite1_obuf <= dzwrite_obuf;
		end
	end
end

// INNER.NET (449) - dest_cycle[1] : or4
assign dest_cycle_1 = dread_1 | dzread_1 | dwrite1_obuf | dzwrite1_obuf;

// INNER.NET (457) - srcdxack : join
assign srcdxack_n = ~read_ack;

// INNER.NET (458) - srczxack : or2
assign srczxack_n = ~read_ack | srcdxpend;

// INNER.NET (459) - srcdack : or3
assign srcdack_n = ~read_ack | srcdxpend | srczxpend;

// INNER.NET (461) - srczack : or4
assign srczack_n = ~read_ack | srcdpend | srcdxpend | srczxpend;

// INNER.NET (463) - dstdack : or5
assign dstdack_n = ~read_ack | srcdpend | srczpend | srcdxpend | srczxpend;

// INNER.NET (465) - dstzack : or6
assign dstzack_n = ~read_ack | dstdpend | srcdpend | srczpend | srcdxpend | srczxpend;

// INNER.NET (470) - srcdpset\ : nd2
assign srcdpset_n = ~(readreq_obuf & sread);

// INNER.NET (471) - srcdpt1 : nd2
assign srcdpt[1] = ~(srcdpend & srcdack_n);

// INNER.NET (472) - srcdpt2 : nd2
assign srcdpt[2] = ~(srcdpset_n & srcdpt[1]);

// INNER.NET (473) - srcdpend : fd2q
// INNER.NET (478) - srcdxpend : fd2q
// INNER.NET (496) - srczpend : fd2q
// INNER.NET (501) - srczxpend : fd2q
// INNER.NET (511) - dstdpend : fd2q
// INNER.NET (519) - dstzpend : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			srcdpend <= 1'b0;
			srcdxpend <= 1'b0;
			srczpend <= 1'b0;
			srczxpend <= 1'b0;
			dstdpend <= 1'b0;
			dstzpend <= 1'b0;
		end else begin
			srcdpend <= srcdpt[2];
			srcdxpend <= srcdxpt[2];
			srczpend <= srczpt[2];
			srczxpend <= srczxpt[2];
			dstdpend <= dstdpt[1];
			dstzpend <= dstzpt[1];
		end
	end
end

// INNER.NET (475) - srcdxpset\ : nd2
assign srcdxpset_n = ~(readreq_obuf & sreadx);

// INNER.NET (476) - srcdxpt1 : nd2
assign srcdxpt[1] = ~(srcdxpend & srcdxack_n);

// INNER.NET (477) - srcdxpt2 : nd2
assign srcdxpt[2] = ~(srcdxpset_n & srcdxpt[1]);

// INNER.NET (480) - sdpend : or2
assign sdpend = srcdxpend | srcdpend;

// INNER.NET (481) - srcdreadt : an2
assign srcdreadt = sdpend & read_ack;

// INNER.NET (488) - srcdreadd : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		srcdreadd_obuf <= srcdreadt;
	end
end

// INNER.NET (489) - srcdread : aor1
assign srcdread = (srcshade & srcdreadd_obuf) | srcdreadt;

// INNER.NET (493) - srczpset\ : nd2
assign srczpset_n = ~(readreq_obuf & szread);

// INNER.NET (494) - srczpt1 : nd2
assign srczpt[1] = ~(srczpend & srczack_n);

// INNER.NET (495) - srczpt2 : nd2
assign srczpt[2] = ~(srczpset_n & srczpt[1]);

// INNER.NET (498) - srczxpset\ : nd2
assign srczxpset_n = ~(readreq_obuf & szreadx);

// INNER.NET (499) - srczxpt1 : nd2
assign srczxpt[1] = ~(srczxpend & srczxack_n);

// INNER.NET (500) - srczxpt2 : nd2
assign srczxpt[2] = ~(srczxpset_n & srczxpt[1]);

// INNER.NET (503) - szpend : or2
assign szpend = srczpend | srczxpend;

// INNER.NET (504) - srczread : an2
assign srczread = szpend & read_ack;

// INNER.NET (508) - dstdpset\ : nd2
assign dstdpset_n = ~(readreq_obuf & dread);

// INNER.NET (509) - dstdpt0 : nd2
assign dstdpt[0] = ~(dstdpend & dstdack_n);

// INNER.NET (510) - dstdpt1 : nd2
assign dstdpt[1] = ~(dstdpset_n & dstdpt[0]);

// INNER.NET (512) - dstdread : an2
assign dstdread = dstdpend & read_ack;

// INNER.NET (516) - dstzpset\ : nd2
assign dstzpset_n = ~(readreq_obuf & dzread);

// INNER.NET (517) - dstzpt0 : nd2
assign dstzpt[0] = ~(dstzpend & dstzack_n);

// INNER.NET (518) - dstzpt1 : nd2
assign dstzpt[1] = ~(dstzpset_n & dstzpt[0]);

// INNER.NET (520) - dstzread : an2
assign dstzread = dstzpend & read_ack;

// INNER.NET (527) - denat0 : or2
assign denat[0] = dwrite_obuf | dzwrite_obuf;

// INNER.NET (528) - denat1 : an3
assign denat[1] = denat[0] & ~nowrite & clip_n;

// INNER.NET (531) - dstdwt : an3
assign denat[3] = blitack & wactive & denat[2];

// INNER.NET (532) - data_ena : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		data_ena_ <= denat[3];
	end
end
endmodule
