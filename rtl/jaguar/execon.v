//`include "defs.v"

module _execon
(
	output dstdgate,
	output exe,
	output exeb_1,
	output immwri,
	output insexe,
	output insexei,
	output loimmld,
	output romold,
	output stop,
	input clk_0,
	input go,
	input immld,
	input insrdy,
	input memrw,
	input datwe,
	input mtx_wait,
	input precomp,
	input reset_n,
	input sbwait,
	input single_go,
	input single_step,
	input sys_clk // Generated
);
reg insrdyp = 1'b0;
wire vinsset_n;
wire vinsclrt;
reg imm1 = 1'b0;
reg imm2 = 1'b0;
wire vinsclr_n;
wire vinst_0;
reg vins = 1'b0;
wire vinsi;
wire wait_n;
wire compdwait;
wire waitb_n;
wire exe_n;
reg exec = 1'b0;
wire exeb_0;
wire execi;
wire compdwaiti_n;
reg idle = 1'b1;
wire [3:0] idlet;
wire [4:0] exect;
wire [2:0] imm1t;
wire [1:0] imm2t;
wire imm2i;
wire [3:0] stopt;
wire [6:0] romot;
wire romot2t;
wire romoldt;
wire compdldt_n;
reg compdld_n = 1'b0;
wire dstdgt;

// Output buffers
wire exe_obuf;
wire insexei_obuf;
wire romold_obuf;
reg stop_obuf = 1'b0;

wire resetl = reset_n; 
wire clk = clk_0; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end


// Output buffers
assign exe = exe_obuf;
assign insexei = insexei_obuf;
assign romold = romold_obuf;
assign stop = stop_obuf;

// EXECON.NET (58) - insrdy : fd2
// EXECON.NET (75) - vins : fd2qp
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			insrdyp <= 1'b0;
			vins <= 1'b0;
		end else begin
			insrdyp <= insrdy;
			vins <= vinsi;
		end
	end
end

// EXECON.NET (70) - vinsset\ : nd2
assign vinsset_n = ~(romold_obuf & insrdy);

// EXECON.NET (71) - vinsclrt : oan1
assign vinsclrt = (imm1 | imm2) & insrdyp;

// EXECON.NET (72) - vinsclr\ : nr3
assign vinsclr_n = ~(exe_obuf | vinsclrt | ~go);

// EXECON.NET (73) - vinst0 : nd2
assign vinst_0 = ~(vins & vinsclr_n);

// EXECON.NET (74) - vinsi : nd2p
assign vinsi = ~(vinst_0 & vinsset_n);

// EXECON.NET (77) - wait\ : nr3p
assign wait_n = ~(sbwait | compdwait | mtx_wait);

// EXECON.NET (78) - waitb\ : nr3p
assign waitb_n = ~(sbwait | compdwait | mtx_wait);

// EXECON.NET (82) - exe\ : nd3p
assign exe_n = ~(vins & wait_n & exec);

// EXECON.NET (83) - exe : an3u
assign exe_obuf = vins & wait_n & exec;

// EXECON.NET (85) - exeb[0] : an3p
assign exeb_0 = vins & waitb_n & exec;

// EXECON.NET (87) - exeb[1] : an3p
assign exeb_1 = vins & waitb_n & exec;

// EXECON.NET (92) - insexei : an3p
assign insexei_obuf = vinsi & execi & compdwaiti_n;

// EXECON.NET (93) - insexe : fd2qp
// EXECON.NET (106) - idle : fd4q
reg insexe_ = 1'b0;
assign insexe = insexe_;
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			insexe_ <= 1'b0;
			idle <= 1'b1;
		end else begin
			insexe_ <= insexei_obuf;
			idle <= idlet[3];
		end
	end
end

// EXECON.NET (102) - idlet0 : nd2
assign idlet[0] = ~(idle & ~go);

// EXECON.NET (103) - idlet1 : nd2
assign idlet[1] = ~(exec & ~go);

// EXECON.NET (104) - idlet2 : nd2
assign idlet[2] = ~(stop_obuf & ~go);

// EXECON.NET (105) - idlet3 : nd3
assign idlet[3] = ~(&idlet[2:0]);

// EXECON.NET (108) - exect0 : nd2
assign exect[0] = ~(idle & go);

// EXECON.NET (109) - exect1 : nd3
assign exect[1] = ~(exec & go & exe_n);

// EXECON.NET (110) - exect2 : nd5
assign exect[2] = ~(exec & go & exe_obuf & ~single_step & ~immld);

// EXECON.NET (112) - exect3 : nd3
assign exect[3] = ~(imm2 & insrdyp & ~single_step);

// EXECON.NET (113) - exect4 : nd3
assign exect[4] = ~(stop_obuf & single_go & go);

// EXECON.NET (114) - exect5 : nd5
assign execi = ~(&exect[4:0]);

// EXECON.NET (115) - exect : fd2q
// EXECON.NET (121) - imm1 : fd2q
// EXECON.NET (126) - imm2 : fd2q
// EXECON.NET (133) - stop : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			exec <= 1'b0;
			imm1 <= 1'b0;
			imm2 <= 1'b0;
			stop_obuf <= 1'b0;
		end else begin
			exec <= execi;
			imm1 <= imm1t[2];
			imm2 <= imm2i;
			stop_obuf <= stopt[3];
		end
	end
end

// EXECON.NET (118) - imm1t0 : nd4
assign imm1t[0] = ~(exec & go & exe_obuf & immld);

// EXECON.NET (119) - imm1t1 : nd2
assign imm1t[1] = ~(imm1 & ~insrdyp);

// EXECON.NET (120) - imm1t2 : nd2
assign imm1t[2] = ~(&imm1t[1:0]);

// EXECON.NET (123) - imm2t0 : nd2
assign imm2t[0] = ~(imm1 & insrdyp);

// EXECON.NET (124) - imm2t1 : nd2
assign imm2t[1] = ~(imm2 & ~insrdyp);

// EXECON.NET (125) - imm2t2 : nd2
assign imm2i = ~(imm2t[0] & imm2t[1]);

// EXECON.NET (128) - stopt0 : nd5
assign stopt[0] = ~(exec & go & exe_obuf & ~immld & single_step);

// EXECON.NET (130) - stopt1 : nd3
assign stopt[1] = ~(imm2 & insrdyp & single_step);

// EXECON.NET (131) - stopt2 : nd3
assign stopt[2] = ~(stop_obuf & ~single_go & go);

// EXECON.NET (132) - stopt3 : nd3
assign stopt[3] = ~(&stopt[2:0]);

// EXECON.NET (150) - romot0 : nd2p
assign romot[0] = ~(imm1 & insrdy);

// EXECON.NET (151) - romot1 : nd3p
assign romot[1] = ~(imm2 & ~single_step & insrdy);

// EXECON.NET (152) - romot2t : nd3
assign romot2t = ~(memrw & datwe & precomp);

// EXECON.NET (153) - romot2 : nd5p
assign romot[2] = ~(exec & exeb_0 & ~single_step & insrdy & romot2t);

// EXECON.NET (155) - romot3 : nd3
assign romot[3] = ~(exec & exe_n & compdwait);

// EXECON.NET (156) - romot4 : nd5
assign romot[4] = ~(exec & exeb_0 & immld & single_step & insrdy);

// EXECON.NET (158) - romot5 : nd4
assign romot[5] = ~(exec & exe_n & wait_n & insrdy);

// EXECON.NET (159) - romot6 : nd3
assign romot[6] = ~(stop_obuf & single_go & insrdy);

// EXECON.NET (160) - romoldt : an4p
assign romoldt = &romot[6:3];

// EXECON.NET (161) - romold : nd4p
assign romold_obuf = ~(&romot[2:0] & romoldt);

// EXECON.NET (171) - loimmld : an2h
assign loimmld = insrdyp & imm1;

// EXECON.NET (183) - compdldt : nd4
assign compdldt_n = ~(exe_obuf & memrw & datwe & precomp);

// EXECON.NET (184) - compdld : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		compdld_n <= compdldt_n;
	end
end

// EXECON.NET (185) - dstdgt0 : nd4
assign dstdgt = ~(exe_obuf & memrw & datwe & ~precomp);

// EXECON.NET (186) - dstgate : nd2
assign dstdgate = ~(dstdgt & compdld_n);

// EXECON.NET (188) - compdwait : iv
assign compdwait = ~compdld_n;

// EXECON.NET (189) - compdwaiti\ : join
assign compdwaiti_n = compdldt_n;

// EXECON.NET (194) - immwri : an2
assign immwri = insrdy & imm2i;
endmodule

