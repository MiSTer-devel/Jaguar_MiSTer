//`include "defs.v"
// altera message_off 10036

module _memwidth
(
	input [3:0] w,
	input [2:0] ba,
	input [1:0] mw,
	input ack,
	input nextc,
	input clk,
	input bigend,
	output [3:0] maskw,
	output [2:0] maska,
	output [2:0] at,
	output lastcycle,
	output lastc,
	output [7:0] bm,
	input sys_clk // Generated
);
wire [3:0] rw;
wire [3:0] rw1;
wire [2:0] ba1;
reg [3:0] pw = 4'h0;
wire [2:0] nba;
wire [2:0] ba1l;
reg [2:0] maskai = 3'h0;
wire [1:0] mwl;
wire [3:0] cw1;
wire [3:0] d;
wire mw8;
wire mw16;
wire mw32;
wire mw64;
wire [3:0] cw2;
wire direct;
wire [3:0] maskwl;
wire rwc;
wire zerol;
wire dra;
wire drb;
wire w32;
wire drc;
wire w16;
wire drd;
wire [7:0] sa;
wire [3:1] rwl;
wire rwgt1;
wire rwgt2a;
wire rwgt2;
wire rwgt3;
wire rwgt4a;
wire rwgt4b;
wire rwgt4;
wire rwgt5;
wire rwgt6a;
wire rwgt6;
wire rwlte1;
wire rwlte2;
wire rwlte3;
wire rwlte4;
wire [7:1] bmwa;//not used 2 4 6
wire [7:1] bmwb;//not used 2 4 6
wire [7:1] bmw;//not used 2 4 6
wire [7:2] bml;//not used 4 5
wire [7:2] bmla;//not used 4 5
wire [7:2] bmlb;//not used 4 5
wire [7:2] bmlc;//not used 4 5
wire [7:3] bmld;//not used 4 5 6
wire [7:4] bmp;
wire [7:4] bmpa;
wire [7:4] bmpb;
wire [7:4] bmpc;
wire [7:4] bmpd;
wire [7:4] bmpe;
wire [7:5] bmpf;
wire [7:6] bmpg;
wire bmph_7;
wire [7:0] bmd;
wire [7:0] bmd1;
wire last16a;
wire last16b;
wire last16;
wire last32a;
wire last32b;
wire last32c;
wire last32d;
wire last32;
wire [3:0] negba;
wire d216;
reg [7:0] bm_ = 8'h00;

// Output buffers
reg [3:0] maskw_obuf = 4'h0;
wire [2:0] maska_obuf;
wire [2:0] at_obuf;
wire lastc_obuf;

reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// Output buffers
assign maskw[3:0] = maskw_obuf[3:0];
assign maska[2:0] = maska_obuf[2:0];
assign at[2:0] = at_obuf[2:0];
assign lastc = lastc_obuf;
assign bm[7:0] = bm_[7:0];

// MEMWIDTH.NET (69) - rw1[0-3] : mx2h
assign rw1[3:0] = (ack) ? w[3:0] : rw[3:0];

// MEMWIDTH.NET (73) - pw[0-3] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (nextc) begin
			pw[3:0] <= rw1[3:0];
		end
	end
end

// MEMWIDTH.NET (77) - ba1[0-2] : mx2h
assign ba1[2:0] = (ack) ? ba[2:0] : nba[2:0];

// MEMWIDTH.NET (78) - ba1l[0-2] : iv
assign ba1l[2:0] = ~ba1[2:0];

// MEMWIDTH.NET (82) - maskai[0-2] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		maskai[2:0] <= at_obuf[2:0];
	end
end

// MEMWIDTH.NET (83) - at[0-2] : mx2
assign at_obuf[2:0] = (nextc) ? ba1[2:0] : maskai[2:0];

// MEMWIDTH.NET (84) - maska[0] : nivu
// MEMWIDTH.NET (85) - maska[1] : nivu2
// MEMWIDTH.NET (86) - maska[2] : nivu
assign maska_obuf[2:0] = maskai[2:0];

// MEMWIDTH.NET (115) - mwl[0-1] : iv
assign mwl[1:0] = ~mw[1:0];

// MEMWIDTH.NET (135) - cw1[0-3] : mx2p
assign cw1[3:0] = (lastc_obuf) ? rw1[3:0] : d[3:0];

// MEMWIDTH.NET (139) - mw8 : an2p
assign mw8 = &mwl[1:0];

// MEMWIDTH.NET (140) - mw16 : an2p
assign mw16 = mwl[1] & mw[0];

// MEMWIDTH.NET (141) - mw32 : an2p
assign mw32 = mw[1] & mwl[0];

// MEMWIDTH.NET (142) - mw64 : an2p
assign mw64 = &mw[1:0];

// MEMWIDTH.NET (144) - cw2[0] : mx2p
// MEMWIDTH.NET (145) - cw2[1] : mx2p
// MEMWIDTH.NET (146) - cw2[2] : mx2p
// MEMWIDTH.NET (147) - cw2[3] : mx2p
assign cw2[3:0] = (direct) ? {mw64,mw32,mw16,mw8} : cw1[3:0];

// MEMWIDTH.NET (149) - maskw[0-3] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (nextc) begin
			maskw_obuf[3:0] <= cw2[3:0];
		end
	end
end

// MEMWIDTH.NET (154) - maskwl[0-3] : iv
assign maskwl[3:0] = ~maskw_obuf[3:0];

// MEMWIDTH.NET (156) - rw[0] : fa1
// MEMWIDTH.NET (157) - rw[1-3] : fa1
assign {rwc,rw[3:0]} = pw[3:0] + maskwl[3:0] + 5'b1;

// MEMWIDTH.NET (161) - zerol : or4
assign zerol = |rw[3:0];

// MEMWIDTH.NET (162) - lastcycle : nd2
assign lastcycle = ~(zerol & rwc);

// MEMWIDTH.NET (166) - nba[0] : fa1
// MEMWIDTH.NET (167) - nba[1-2] : fa1
assign nba[2:0] = maska_obuf[2:0] + maskw_obuf[2:0];

// MEMWIDTH.NET (172) - dra : nd3
assign dra = ~(mw[1] & mw[0] & rw1[3]);

// MEMWIDTH.NET (173) - drb : nd6
assign drb = ~(mw[1] & mwl[0] & ba1l[0] & ba1l[1] & w32);

// MEMWIDTH.NET (174) - drc : nd4
assign drc = ~(mwl[1] & mw[0] & ba1l[0] & w16);

// MEMWIDTH.NET (175) - drd : nd2
assign drd = ~(mwl[1] & mwl[0]);

// MEMWIDTH.NET (176) - direct : nd4p
assign direct = ~(dra & drb & drc & drd);

// MEMWIDTH.NET (180) - w32 : or2
assign w32 = rw1[2] | rw1[3];

// MEMWIDTH.NET (181) - w16 : or3
assign w16 = rw1[1] | rw1[2] | rw1[3];

// MEMWIDTH.NET (190) - sa : dec38h
assign sa[7:0] = 8'b00000001 << ba1[2:0];

// MEMWIDTH.NET (192) - rwl[1-3] : ivh
//assign rwl[3:1] = ~rw1[3:1];

// MEMWIDTH.NET (193) - rwgt1 : nd3p
assign rwgt1 = ~(rw1[3:1] == 3'b000);

// MEMWIDTH.NET (194) - rwgt2a : nd2
assign rwgt2a = ~(rw1[1:0] == 2'b11);

// MEMWIDTH.NET (195) - rwgt2 : nd3p
assign rwgt2 = ~(rwgt2a & (rw1[3:2] == 2'b00));

// MEMWIDTH.NET (196) - rwgt3 : nd2p
assign rwgt3 = ~(rw1[3:2] == 2'b00);

// MEMWIDTH.NET (197) - rwgt4a : nd2
assign rwgt4a = ~(rw1[0] & rw1[2]);

// MEMWIDTH.NET (198) - rwgt4b : nd2
assign rwgt4b = ~(rw1[2:1] == 2'b11);

// MEMWIDTH.NET (199) - rwgt4 : nd3p
assign rwgt4 = ~(rwgt4a & rwgt4b & ~rw1[3]);

// MEMWIDTH.NET (200) - rwgt5 : nd2p
assign rwgt5 = ~(rwgt4b & ~rw1[3]);

// MEMWIDTH.NET (201) - rwgt6a : nd3
assign rwgt6a = ~(rw1[2:0] == 3'b111);

// MEMWIDTH.NET (202) - rwgt6 : nd2p
assign rwgt6 = ~(rwgt6a & ~rw1[3]);

// MEMWIDTH.NET (203) - rwlte1 : ivh
assign rwlte1 = ~rwgt1;

// MEMWIDTH.NET (204) - rwlte2 : ivh
assign rwlte2 = ~rwgt2;

// MEMWIDTH.NET (205) - rwlte3 : ivh
assign rwlte3 = ~rwgt3;

// MEMWIDTH.NET (206) - rwlte4 : ivh
assign rwlte4 = ~rwgt4;

// MEMWIDTH.NET (211) - bmwa[1] : iv
assign bmwa[1] = ~sa[1];

// MEMWIDTH.NET (212) - bmwb[1] : nd2
assign bmwb[1] = ~(sa[0] & rwgt1);

// MEMWIDTH.NET (213) - bmw[1] : nd2
assign bmw[1] = ~(bmwa[1] & bmwb[1]);

// MEMWIDTH.NET (214) - bmwa[3] : iv
assign bmwa[3] = ~sa[3];

// MEMWIDTH.NET (215) - bmwb[3] : nd2
assign bmwb[3] = ~(sa[2] & rwgt1);

// MEMWIDTH.NET (216) - bmw[3] : nd2
assign bmw[3] = ~(bmwa[3] & bmwb[3]);

// MEMWIDTH.NET (217) - bmwa[5] : iv
assign bmwa[5] = ~sa[5];

// MEMWIDTH.NET (218) - bmwb[5] : nd2
assign bmwb[5] = ~(sa[4] & rwgt1);

// MEMWIDTH.NET (219) - bmw[5] : nd2
assign bmw[5] = ~(bmwa[5] & bmwb[5]);

// MEMWIDTH.NET (220) - bmwa[7] : iv
assign bmwa[7] = ~sa[7];

// MEMWIDTH.NET (221) - bmwb[7] : nd2
assign bmwb[7] = ~(sa[6] & rwgt1);

// MEMWIDTH.NET (222) - bmw[7] : nd2
assign bmw[7] = ~(bmwa[7] & bmwb[7]);

// MEMWIDTH.NET (226) - bmla[2] : iv
assign bmla[2] = ~sa[2];

// MEMWIDTH.NET (227) - bmlb[2] : nd2
assign bmlb[2] = ~(sa[0] & rwgt2);

// MEMWIDTH.NET (228) - bmlc[2] : nd2
assign bmlc[2] = ~(sa[1] & rwgt1);

// MEMWIDTH.NET (229) - bml[2] : nd3
assign bml[2] = ~(bmla[2] & bmlb[2] & bmlc[2]);

// MEMWIDTH.NET (230) - bmla[3] : iv
assign bmla[3] = ~sa[3];

// MEMWIDTH.NET (231) - bmlb[3] : nd2
assign bmlb[3] = ~(sa[0] & rwgt3);

// MEMWIDTH.NET (232) - bmlc[3] : nd2
assign bmlc[3] = ~(sa[1] & rwgt2);

// MEMWIDTH.NET (233) - bmld[3] : nd2
assign bmld[3] = ~(sa[2] & rwgt1);

// MEMWIDTH.NET (234) - bml[3] : nd4
assign bml[3] = ~(bmla[3] & bmlb[3] & bmlc[3] & bmld[3]);

// MEMWIDTH.NET (235) - bmla[6] : iv
assign bmla[6] = ~sa[6];

// MEMWIDTH.NET (236) - bmlb[6] : nd2
assign bmlb[6] = ~(sa[4] & rwgt2);

// MEMWIDTH.NET (237) - bmlc[6] : nd2
assign bmlc[6] = ~(sa[5] & rwgt1);

// MEMWIDTH.NET (238) - bml[6] : nd3
assign bml[6] = ~(bmla[6] & bmlb[6] & bmlc[6]);

// MEMWIDTH.NET (239) - bmla[7] : iv
assign bmla[7] = ~sa[7];

// MEMWIDTH.NET (240) - bmlb[7] : nd2
assign bmlb[7] = ~(sa[4] & rwgt3);

// MEMWIDTH.NET (241) - bmlc[7] : nd2
assign bmlc[7] = ~(sa[5] & rwgt2);

// MEMWIDTH.NET (242) - bmld[7] : nd2
assign bmld[7] = ~(sa[6] & rwgt1);

// MEMWIDTH.NET (243) - bml[7] : nd4
assign bml[7] = ~(bmla[7] & bmlb[7] & bmlc[7] & bmld[7]);

// MEMWIDTH.NET (247) - bmpa[4] : iv
assign bmpa[4] = ~sa[4];

// MEMWIDTH.NET (248) - bmpb[4] : nd2
assign bmpb[4] = ~(sa[0] & rwgt4);

// MEMWIDTH.NET (249) - bmpc[4] : nd2
assign bmpc[4] = ~(sa[1] & rwgt3);

// MEMWIDTH.NET (250) - bmpd[4] : nd2
assign bmpd[4] = ~(sa[2] & rwgt2);

// MEMWIDTH.NET (251) - bmpe[4] : nd2
assign bmpe[4] = ~(sa[3] & rwgt1);

// MEMWIDTH.NET (252) - bmp[4] : nd6
assign bmp[4] = ~(bmpa[4] & bmpb[4] & bmpc[4] & bmpd[4] & bmpe[4]);

// MEMWIDTH.NET (253) - bmpa[5] : iv
assign bmpa[5] = ~sa[5];

// MEMWIDTH.NET (254) - bmpb[5] : nd2
assign bmpb[5] = ~(sa[0] & rwgt5);

// MEMWIDTH.NET (255) - bmpc[5] : nd2
assign bmpc[5] = ~(sa[1] & rwgt4);

// MEMWIDTH.NET (256) - bmpd[5] : nd2
assign bmpd[5] = ~(sa[2] & rwgt3);

// MEMWIDTH.NET (257) - bmpe[5] : nd2
assign bmpe[5] = ~(sa[3] & rwgt2);

// MEMWIDTH.NET (258) - bmpf[5] : nd2
assign bmpf[5] = ~(sa[4] & rwgt1);

// MEMWIDTH.NET (259) - bmp[5] : nd6
assign bmp[5] = ~(bmpa[5] & bmpb[5] & bmpc[5] & bmpd[5] & bmpe[5] & bmpf[5]);

// MEMWIDTH.NET (260) - bmpa[6] : iv
assign bmpa[6] = ~sa[6];

// MEMWIDTH.NET (261) - bmpb[6] : nd2
assign bmpb[6] = ~(sa[0] & rwgt6);

// MEMWIDTH.NET (262) - bmpc[6] : nd2
assign bmpc[6] = ~(sa[1] & rwgt5);

// MEMWIDTH.NET (263) - bmpd[6] : nd2
assign bmpd[6] = ~(sa[2] & rwgt4);

// MEMWIDTH.NET (264) - bmpe[6] : nd2
assign bmpe[6] = ~(sa[3] & rwgt3);

// MEMWIDTH.NET (265) - bmpf[6] : nd2
assign bmpf[6] = ~(sa[4] & rwgt2);

// MEMWIDTH.NET (266) - bmpg[6] : nd2
assign bmpg[6] = ~(sa[5] & rwgt1);

// MEMWIDTH.NET (267) - bmp[6] : nd8
assign bmp[6] = ~(bmpa[6] & bmpb[6] & bmpc[6] & bmpd[6] & bmpe[6] & bmpf[6] & bmpg[6]);

// MEMWIDTH.NET (269) - bmpa[7] : iv
assign bmpa[7] = ~sa[7];

// MEMWIDTH.NET (270) - bmpb[7] : nd2
assign bmpb[7] = ~(sa[0] & rw1[3]);

// MEMWIDTH.NET (271) - bmpc[7] : nd2
assign bmpc[7] = ~(sa[1] & rwgt6);

// MEMWIDTH.NET (272) - bmpd[7] : nd2
assign bmpd[7] = ~(sa[2] & rwgt5);

// MEMWIDTH.NET (273) - bmpe[7] : nd2
assign bmpe[7] = ~(sa[3] & rwgt4);

// MEMWIDTH.NET (274) - bmpf[7] : nd2
assign bmpf[7] = ~(sa[4] & rwgt3);

// MEMWIDTH.NET (275) - bmpg[7] : nd2
assign bmpg[7] = ~(sa[5] & rwgt2);

// MEMWIDTH.NET (276) - bmph[7] : nd2
assign bmph_7 = ~(sa[6] & rwgt1);

// MEMWIDTH.NET (277) - bmp[7] : nd8
assign bmp[7] = ~(bmpa[7] & bmpb[7] & bmpc[7] & bmpd[7] & bmpe[7] & bmpf[7] & bmpg[7] & bmph_7);

// MEMWIDTH.NET (282) - bmd[0] : niv
assign bmd[0] = sa[0];

// MEMWIDTH.NET (283) - bmd[1] : mx4p
assign bmd[7:1] = mw[1] ? (mw[0] ? {bmp[7:4],bml[3:2],bmw[1]} : {bml[7:6],bmw[5],sa[4],bml[3:2],bmw[1]})
                        : (mw[0] ? {bmw[7],sa[6],bmw[5],sa[4],bmw[3],sa[2],bmw[1]} : sa[7:1]);

// MEMWIDTH.NET (293) - bmd1[0] : mx2
// MEMWIDTH.NET (294) - bmd1[1] : mx2
// MEMWIDTH.NET (295) - bmd1[2] : mx2
// MEMWIDTH.NET (296) - bmd1[3] : mx2
// MEMWIDTH.NET (297) - bmd1[4] : mx2
// MEMWIDTH.NET (298) - bmd1[5] : mx2
// MEMWIDTH.NET (299) - bmd1[6] : mx2
// MEMWIDTH.NET (300) - bmd1[7] : mx2
assign bmd1[7:0] = (bigend) ? {bmd[0],bmd[1],bmd[2],bmd[3],bmd[4],bmd[5],bmd[6],bmd[7]} : bmd[7:0];

// MEMWIDTH.NET (302) - bm[0-7] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (nextc) begin
			bm_[7:0] <= bmd1[7:0];
		end
	end
end

// MEMWIDTH.NET (310) - last16a : nd2
assign last16a = ~(ba1[0] & rwlte1);

// MEMWIDTH.NET (311) - last16b : nd2
assign last16b = ~(ba1l[0] & rwlte2);

// MEMWIDTH.NET (312) - last16 : nd2
assign last16 = ~(last16a & last16b);

// MEMWIDTH.NET (316) - last32a : nd3
assign last32a = ~(ba1[1] & ba1[0] & rwlte1);

// MEMWIDTH.NET (317) - last32b : nd3
assign last32b = ~(ba1[1] & ba1l[0] & rwlte2);

// MEMWIDTH.NET (318) - last32c : nd3
assign last32c = ~(ba1l[1] & ba1[0] & rwlte3);

// MEMWIDTH.NET (319) - last32d : nd3
assign last32d = ~(ba1l[1] & ba1l[0] & rwlte4);

// MEMWIDTH.NET (320) - last32 : nd4
assign last32 = ~(last32a & last32b & last32c & last32d);

// MEMWIDTH.NET (324) - lastc : mx4p
assign lastc_obuf = mw[1] ? (mw[0] ? 1'b1 : last32) : (mw[0] ? last16 : rwlte1);

// MEMWIDTH.NET (333) - negba[0] : ha1p
assign negba[3:0] = ba1l[2:0] + 4'b0001;

// MEMWIDTH.NET (339) - d[0] : mx4p
// MEMWIDTH.NET (340) - d[1] : mx4p
// MEMWIDTH.NET (341) - d[2] : mx4p
// MEMWIDTH.NET (342) - d[3] : mx4p
assign d[3:0] = mw[1] ? (mw[0] ? {negba[3:0]} : {1'b0,d216,negba[1:0]})
                      : (mw[0] ? {2'b00,ba1l[0],negba[0]} : {4'b0001});

// MEMWIDTH.NET (344) - d216 : an2
assign d216 = ba1l[0] & ba1l[1];
endmodule

