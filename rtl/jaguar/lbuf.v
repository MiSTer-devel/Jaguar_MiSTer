//`include "defs.v"
// altera message_off 10036

module _lbuf
(
	input aout_1,
	input aout_15,
	input [31:0] dout,
	input siz_2,
	input [8:0] lbwa,
	input [8:0] lbra,
	input [1:0] lbwe,
	input [31:0] lbwd,
	input lbufa,
	input lbufb,
	input lbaw,
	input lbbw,
	input rmw,
	input reads,
	input vclk,
	input clk,
	input lben,
	input bgw,
	input bgwr,
	input vactive,
	input lbaactive,
	input lbbactive,
	input bigend,
	output [31:0] lbrd,
	output [15:0] dr_out,
	output dr_oe,
	input sys_clk // Generated
);
wire [8:0] lbai;
wire [8:0] lbbi;
wire [31:0] lbrd_d;
wire [15:0] wdil;
wire [15:0] wdih;
reg [15:0] bgc = 16'h0000;
wire [15:0] lbadl;
wire [15:0] lbadh;
wire [15:0] lbbdl;
wire [15:0] lbbdh;
wire nota_1;
wire lbad;
wire lba;
wire lbbd;
wire lbb;
wire [8:0] lbwad;
wire [8:0] lbrad;
wire [8:0] lbaadi;
wire [8:0] lbbadi;
wire [8:0] lbaad;
wire [8:0] lbbad;
wire [31:0] dw;
wire down;
wire up;
wire littlend;
wire [31:0] rmwd;
reg [31:0] rmwd1 = 32'h00000000;
wire [31:0] rmwd2;
wire [31:0] wd;
wire extadd;
wire writes;
wire [1:0] lbr;
wire wra0;
wire wra1l;
wire wra1h;
wire wra2l;
wire wra2h;
wire notsiz_2;
wire wrali;
wire notaactive;
wire wrahi;
wire wral;
wire wrah;
wire wrb0;
wire wrb1l;
wire wrb1h;
wire wrb2l;
wire wrb2h;
wire wrbli;
wire notbactive;
wire wrbhi;
wire wrbl;
wire wrbh;
wire cea_0;
wire wea_0;
wire cea_1;
wire wea_1;
wire ceb_0;
wire web_0;
wire ceb_1;
wire web_1;
wire ncst;
wire nvcst;
wire cea0;
wire cea1;
wire cea2;
wire aactive;
wire ceb0;
wire ceb1;
wire ceb2;
wire bactive;
wire wea00;
wire wea01;
wire wea02;
wire wead_0;
wire wea10;
wire wea11;
wire wea12;
wire vcc;
wire wead_1;
wire web00;
wire web01;
wire web02;
wire webd_0;
wire web10;
wire web11;
wire web12;
wire webd_1;
wire [15:0] lbdi;
reg [15:0] lbd = 16'h0000;
wire lbdeni;
wire lbden;
wire bgwa;
wire bgwb;
wire [15:0] lbadl_wdil_out;
wire lbadl_wdil_oe;
wire [15:0] lbadl_ab616a_out;
wire lbadl_ab616a_oe;
wire [15:0] lbadl_bgc_out;
wire lbadl_bgc_oe;
wire [15:0] lbadh_wdih_out;
wire lbadh_wdih_oe;
wire [15:0] lbadh_ab616a_out;
wire lbadh_ab616a_oe;
wire [15:0] lbadh_bgc_out;
wire lbadh_bgc_oe;
wire [15:0] lbbdl_wdil_out;
wire lbbdl_wdil_oe;
wire [15:0] lbbdl_ab616a_out;
wire lbbdl_ab616a_oe;
wire [15:0] lbbdl_bgc_out;
wire lbbdl_bgc_oe;
wire [15:0] lbbdh_wdih_out;
wire lbbdh_wdih_oe;
wire [15:0] lbbdh_ab616a_out;
wire lbbdh_ab616a_oe;
wire [15:0] lbbdh_bgc_out;
wire lbbdh_bgc_oe;

// Output buffers
wire [31:0] lbrd_obuf;

reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// Output buffers
assign lbrd[31:0] = lbrd_obuf[31:0];

// LBUF.NET (58) - nota[1] : iv
assign nota_1 = ~aout_1;

// LBUF.NET (60) - lbad : twoniv // delay needed?
assign lbad = lbaw;

// LBUF.NET (61) - lba : nivu
assign lba = lbad;

// LBUF.NET (62) - lbbd : twoniv // delay needed?
assign lbbd = lbbw;

// LBUF.NET (63) - lbb : nivu
assign lbb = lbbd;

// LBUF.NET (67) - lbwad[0-8] : hdly1b // delay needed?
assign lbwad[8:0] = lbwa[8:0];

// LBUF.NET (68) - lbrad[0-8] : hdly1b // delay needed?
assign lbrad[8:0] = lbra[8:0];

// LBUF.NET (69) - lbaadi[0-8] : mx2p
assign lbaadi[8:0] = (lbaactive) ? lbrad[8:0] : lbwad[8:0];

// LBUF.NET (70) - lbbadi[0-8] : mx2p
assign lbbadi[8:0] = (lbbactive) ? lbrad[8:0] : lbwad[8:0];

// LBUF.NET (71) - lbaad[0-8] : niv
assign lbaad[8:0] = lbaadi[8:0];

// LBUF.NET (72) - lbbad[0-8] : niv
assign lbbad[8:0] = lbbadi[8:0];

// LBUF.NET (77) - dw[0-15] : mx2
assign dw[15:0] = (down) ? dout[31:16] : dout[15:0];

// LBUF.NET (78) - dw[16-31] : mx2
assign dw[31:16] = (up) ? dout[31:16] : dout[15:0];

// LBUF.NET (79) - littlend : iv
assign littlend = ~bigend;

// LBUF.NET (80) - down : an2h
assign down = aout_15 & bigend;

// LBUF.NET (81) - up : an2h
assign up = aout_15 & littlend;

// LBUF.NET (85) - lbrd[0-15] : mx2
assign lbrd_obuf[15:0] = (lbufa) ? lbadl[15:0] : lbbdl[15:0];

// LBUF.NET (86) - lbrd[16-31] : mx2
assign lbrd_obuf[31:16] = (lbufa) ? lbadh[15:0] : lbbdh[15:0];

// LBUF.NET (89) - ge1 : join
assign lbrd_d[31:0] = lbrd_obuf[31:0];

// LBUF.NET (94) - rmwd[0-15] : mx2
assign rmwd[15:0] = (lbufb) ? lbadl[15:0] : lbbdl[15:0];

// LBUF.NET (95) - rmwd[16-31] : mx2
assign rmwd[31:16] = (lbufb) ? lbadh[15:0] : lbbdh[15:0];

// LBUF.NET (99) - rmwd1[0-31] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		rmwd1[31:0] <= rmwd[31:0];
	end
end

// sadd = unsigned + signed saturating
// LBUF.NET (106) - rmwd2[0] : sadd8
wire [8:0] rmwd2a = {1'b0,rmwd1[7:0]} + lbwd[7:0];
assign rmwd2[7:0] = (rmwd2a[8] ^ lbwd[7]) ? {8{rmwd2a[8]}} : rmwd2a[7:0];

// LBUF.NET (107) - rmwd2[8] : sadd4
wire [12:8] rmwd2b = {1'b0,rmwd1[11:8]} + lbwd[11:8];
assign rmwd2[11:8] = (rmwd2b[12] ^ lbwd[11]) ? {4{rmwd2b[12]}} : rmwd2b[11:8];

// LBUF.NET (108) - rmwd2[12] : sadd4
wire [16:12] rmwd2c = {1'b0,rmwd1[15:12]} + lbwd[15:12];
assign rmwd2[15:12] = (rmwd2c[16] ^ lbwd[15]) ? {4{rmwd2c[16]}} : rmwd2c[15:12];

// LBUF.NET (109) - rmwd2[16] : sadd8
wire [24:16] rmwd2d = {1'b0,rmwd1[23:16]} + lbwd[23:16];
assign rmwd2[23:16] = (rmwd2d[24] ^ lbwd[23]) ? {8{rmwd2d[24]}} : rmwd2d[23:16];

// LBUF.NET (110) - rmwd2[24] : sadd4
wire [28:24] rmwd2e = {1'b0,rmwd1[27:24]} + lbwd[27:24];
assign rmwd2[27:24] = (rmwd2e[28] ^ lbwd[27]) ? {4{rmwd2e[28]}} : rmwd2e[27:24];

// LBUF.NET (111) - rmwd2[28] : sadd4
wire [32:28] rmwd2f = {1'b0,rmwd1[31:28]} + lbwd[31:28];
assign rmwd2[31:28] = (rmwd2f[32] ^ lbwd[31]) ? {4{rmwd2f[32]}} : rmwd2f[31:28];

// LBUF.NET (120) - wd[0-31] : mx4p
assign wd[31:0] = extadd ? dw[31:0] : (rmw ? rmwd2[31:0] : lbwd[31:0]);

// LBUF.NET (123) - extadd : ivu
assign extadd = ~lben;

// LBUF.NET (124) - wdil : join
assign wdil[15:0] = wd[15:0];

// LBUF.NET (125) - wdih : join
assign wdih[15:0] = wd[31:16];

// LBUF.NET (133) - writes : ivm
assign writes = ~reads;

// LBUF.NET (134) - lbr[0-1] : iv
assign lbr[0] = ~lbwe[0];
assign lbr[1] = ~lbwe[1];

// LBUF.NET (136) - wra0 : nd2
assign wra0 = ~(lba & reads);

// LBUF.NET (137) - wra1l : nd3
assign wra1l = ~(lbufb & lben & lbr[0]);

// LBUF.NET (138) - wra1h : nd3
assign wra1h = ~(lbufb & lben & lbr[1]);

// LBUF.NET (139) - wra2l : nd3
assign wra2l = ~(lba & writes & aout_1);

// LBUF.NET (140) - wra2h : nd4
assign wra2h = ~(lba & writes & notsiz_2 & nota_1);

// LBUF.NET (141) - wrali : an4
assign wrali = wra0 & wra1l & wra2l & notaactive;

// LBUF.NET (142) - wrahi : an4
assign wrahi = wra0 & wra1h & wra2h & notaactive;

// LBUF.NET (143) - wral : nivu
assign wral = wrali;

// LBUF.NET (144) - wrah : nivu
assign wrah = wrahi;

// LBUF.NET (146) - wrb0 : nd2
assign wrb0 = ~(lbb & reads);

// LBUF.NET (147) - wrb1l : nd3
assign wrb1l = ~(lbufa & lben & lbr[0]);

// LBUF.NET (148) - wrb1h : nd3
assign wrb1h = ~(lbufa & lben & lbr[1]);

// LBUF.NET (149) - wrb2l : nd3
assign wrb2l = ~(lbb & writes & aout_1);

// LBUF.NET (150) - wrb2h : nd4
assign wrb2h = ~(lbb & writes & notsiz_2 & nota_1);

// LBUF.NET (151) - wrbli : an4
assign wrbli = wrb0 & wrb1l & wrb2l & notbactive;

// LBUF.NET (152) - wrbhi : an4
assign wrbhi = wrb0 & wrb1h & wrb2h & notbactive;

// LBUF.NET (153) - wrbl : nivu
assign wrbl = wrbli;

// LBUF.NET (154) - wrbh : nivu
assign wrbh = wrbhi;

// LBUF.NET (156) - lbadl : ts
assign lbadl_wdil_out[15:0] = wdil[15:0];
assign lbadl_wdil_oe = wral;

// LBUF.NET (157) - lbadh : ts
assign lbadh_wdih_out[15:0] = wdih[15:0];
assign lbadh_wdih_oe = wrah;

// LBUF.NET (158) - lbbdl : ts
assign lbbdl_wdil_out[15:0] = wdil[15:0];
assign lbbdl_wdil_oe = wrbl;

// LBUF.NET (159) - lbbdh : ts
assign lbbdh_wdih_out[15:0] = wdih[15:0];
assign lbbdh_wdih_oe = wrbh;

// LBUF.NET (163) - lbai : join
assign lbai[8:0] = lbaad[8:0];

// LBUF.NET (164) - lbbi : join
assign lbbi[8:0] = lbbad[8:0];

// LBUF.NET (167) - lbufal : ab8616a
_ab8616a lbufal_inst
(
	.z_out /* BUS */ (lbadl_ab616a_out[15:0]),
	.z_oe /* BUS */ (lbadl_ab616a_oe),
	.z_in /* BUS */ (lbadl[15:0]),
	.cen /* IN */ (cea_0),
	.rw /* IN */ (wea_0),
	.a /* IN */ (lbai[8:0]),
	.sys_clk(sys_clk) // Generated
);

// LBUF.NET (168) - lbufah : ab8616a
_ab8616a lbufah_inst
(
	.z_out /* BUS */ (lbadh_ab616a_out[15:0]),
	.z_oe /* BUS */ (lbadh_ab616a_oe),
	.z_in /* BUS */ (lbadh[15:0]),
	.cen /* IN */ (cea_1),
	.rw /* IN */ (wea_1),
	.a /* IN */ (lbai[8:0]),
	.sys_clk(sys_clk) // Generated
);

// LBUF.NET (169) - lbufbl : ab8616a
_ab8616a lbufbl_inst
(
	.z_out /* BUS */ (lbbdl_ab616a_out[15:0]),
	.z_oe /* BUS */ (lbbdl_ab616a_oe),
	.z_in /* BUS */ (lbbdl[15:0]),
	.cen /* IN */ (ceb_0),
	.rw /* IN */ (web_0),
	.a /* IN */ (lbbi[8:0]),
	.sys_clk(sys_clk) // Generated
);

// LBUF.NET (170) - lbufbh : ab8616a
_ab8616a lbufbh_inst
(
	.z_out /* BUS */ (lbbdh_ab616a_out[15:0]),
	.z_oe /* BUS */ (lbbdh_ab616a_oe),
	.z_in /* BUS */ (lbbdh[15:0]),
	.cen /* IN */ (ceb_1),
	.rw /* IN */ (web_1),
	.a /* IN */ (lbbi[8:0]),
	.sys_clk(sys_clk) // Generated
);

// LBUF.NET (172) - ncst : ivh
assign ncst = ~clk;

// LBUF.NET (174) - ge1 : tie1
assign nvcst = 1'b1;

// LBUF.NET (177) - cea0 : nd2
assign cea0 = ~(lbufb & lben);

// LBUF.NET (178) - cea1 : iv
assign cea1 = ~lba;

// LBUF.NET (179) - cea2 : nd2
assign cea2 = ~(cea0 & cea1);

// LBUF.NET (180) - cea[0-1] : anr23
assign cea_0 = ~( (cea2 & ncst) | (aactive & nvcst) );
assign cea_1 = ~( (cea2 & ncst) | (aactive & nvcst) );

// LBUF.NET (182) - ceb0 : nd2
assign ceb0 = ~(lbufa & lben);

// LBUF.NET (183) - ceb1 : iv
assign ceb1 = ~lbb;

// LBUF.NET (184) - ceb2 : nd2
assign ceb2 = ~(ceb0 & ceb1);

// LBUF.NET (185) - ceb[0-1] : anr23
assign ceb_0 = ~( (ceb2 & ncst) | (bactive & nvcst) );
assign ceb_1 = ~( (ceb2 & ncst) | (bactive & nvcst) );

// LBUF.NET (187) - wea00 : nd2
assign wea00 = ~(lbwe[0] & lbufb);

// LBUF.NET (188) - wea01 : nd3
assign wea01 = ~(nota_1 & lba & writes);

// LBUF.NET (189) - wea02 : nd2
assign wea02 = ~(lbufa & bgw);

// LBUF.NET (190) - wead[0] : an3
assign wead_0 = wea00 & wea01 & wea02;

// LBUF.NET (192) - wea10 : nd2
assign wea10 = ~(lbwe[1] & lbufb);

// LBUF.NET (193) - wea11 : nd3
assign wea11 = ~(aout_1 & lba & writes);

// LBUF.NET (194) - wea12 : nd6
assign wea12 = ~(aout_15 & nota_1 & siz_2 & lba & writes & vcc);

// LBUF.NET (195) - wead[1] : an4
assign wead_1 = wea10 & wea11 & wea12 & wea02;

// LBUF.NET (197) - web00 : nd2
assign web00 = ~(lbwe[0] & lbufa);

// LBUF.NET (198) - web01 : nd3
assign web01 = ~(nota_1 & lbb & writes);

// LBUF.NET (199) - web02 : nd2
assign web02 = ~(lbufb & bgw);

// LBUF.NET (200) - webd[0] : an3
assign webd_0 = web00 & web01 & web02;

// LBUF.NET (202) - web10 : nd2
assign web10 = ~(lbwe[1] & lbufa);

// LBUF.NET (203) - web11 : nd3
assign web11 = ~(aout_1 & lbb & writes);

// LBUF.NET (204) - web12 : nd6
assign web12 = ~(aout_15 & nota_1 & siz_2 & lbb & writes);

// LBUF.NET (205) - webd[1] : an4
assign webd_1 = web10 & web11 & web12 & web02;

// LBUF.NET (207) - wea[0-1] : twoniv // delay needed?
assign wea_0 = wead_0;
assign wea_1 = wead_1;

// LBUF.NET (208) - web[0-1] : twoniv // delay needed?
assign web_0 = webd_0;
assign web_1 = webd_1;

// LBUF.NET (210) - notaactive : nd2
assign notaactive = ~(lbufa & vactive);

// LBUF.NET (211) - notbactive : nd2
assign notbactive = ~(lbufb & vactive);

// LBUF.NET (212) - aactive : iv
assign aactive = ~notaactive;

// LBUF.NET (213) - bactive : iv
assign bactive = ~notbactive;

// LBUF.NET (215) - vcc : tie1
assign vcc = 1'b1;

// LBUF.NET (216) - notsiz[2] : iv
assign notsiz_2 = ~siz_2;

// LBUF.NET (220) - lbdi[0-15] : mx4
assign lbdi[15:0] = lbb ? (aout_1 ? lbbdh[15:0] : lbbdl[15:0]) : (aout_1 ? lbadh[15:0] : lbadl[15:0]);

// LBUF.NET (225) - lbd[0-15] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		lbd[15:0] <= lbdi[15:0];
	end
end

// LBUF.NET (227) - lbdeni : nd2
assign lbdeni = ~(wra0 & wrb0);

// LBUF.NET (228) - lbden : nivh
assign lbden = lbdeni;

// LBUF.NET (229) - dr[0-15] : ts
assign dr_out[15:0] = lbd[15:0];
assign dr_oe = lbden;

// LBUF.NET (233) - bgc[0-15] : ldp1q
// always @(d or g)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (bgwr) begin
		bgc[15:0] <= dw[15:0]; // ldp1q negedge always @(d or g)
	end
end

// LBUF.NET (238) - bwadl : ts
assign lbadl_bgc_out[15:0] = bgc[15:0];
assign lbadl_bgc_oe = bgwa;

// LBUF.NET (239) - bwadh : ts
assign lbadh_bgc_out[15:0] = bgc[15:0];
assign lbadh_bgc_oe = bgwa;

// LBUF.NET (240) - bwbdl : ts
assign lbbdl_bgc_out[15:0] = bgc[15:0];
assign lbbdl_bgc_oe = bgwb;

// LBUF.NET (241) - bwbdh : ts
assign lbbdh_bgc_out[15:0] = bgc[15:0];
assign lbbdh_bgc_oe = bgwb;

// LBUF.NET (243) - bgwa : an2u
assign bgwa = bgw & aactive;

// LBUF.NET (244) - bgwb : an2u
assign bgwb = bgw & bactive;

// --- Compiler-generated local PE for BUS lbadl<0>
assign lbadl[15:0] = ((lbadl_wdil_oe) ? lbadl_wdil_out[15:0] : 16'h0000 ) | ((lbadl_ab616a_oe) ? lbadl_ab616a_out[15:0] : 16'h0000 ) | ((lbadl_bgc_oe) ? lbadl_bgc_out[15:0] : 16'h0000);

// --- Compiler-generated local PE for BUS lbadh<0>
assign lbadh[15:0] = ((lbadh_wdih_oe) ? lbadh_wdih_out[15:0] : 16'h0000 ) | ((lbadh_ab616a_oe) ? lbadh_ab616a_out[15:0] : 16'h0000 ) | ((lbadh_bgc_oe) ? lbadh_bgc_out[15:0] : 16'h0000);

// --- Compiler-generated local PE for BUS lbbdl<0>
assign lbbdl[15:0] = ((lbbdl_wdil_oe) ? lbbdl_wdil_out[15:0] : 16'h0000 ) | ((lbbdl_ab616a_oe) ? lbbdl_ab616a_out[15:0] : 16'h0000 ) | ((lbbdl_bgc_oe) ? lbbdl_bgc_out[15:0] : 16'h0000);

// --- Compiler-generated local PE for BUS lbbdh<0>
assign lbbdh[15:0] = ((lbbdh_wdih_oe) ? lbbdh_wdih_out[15:0] : 16'h0000 ) | ((lbbdh_ab616a_oe) ? lbbdh_ab616a_out[15:0] : 16'h0000 ) | ((lbbdh_bgc_oe) ? lbbdh_bgc_out[15:0] : 16'h0000);

endmodule
