//`include "defs.v"

module _bus
(
	input reads,
	input ack,
	input intdev,
	input cpu32,
	input [2:0] ba,
	input mws64,
	input mws16,
	input mws8,
	input notdbg,
	input ourack,
	input [3:0] w,
	input erd,
	input justify,
	input intbm,
	input intbms,
	input cpubm,
	input clk,
	input testen,
	input intbmw,
	input resetl,
	input idle,
	output [2:0] den,
	output aen,
	output [2:0] dmuxu,
	output [2:0] dmuxd,
	output dren,
	output xdsrc,
	output ainen,
	input sys_clk // Generated
);
wire den03;
wire busy;
wire notreads;
wire den04;
wire den05;
wire [2:0] deni;
wire den10;
wire ext16;
wire den20;
wire extbms;
wire host16;
wire cpu16;
wire dbg;
wire xp;
wire notjustify;
wire pw640;
wire pw641;
wire pw64;
wire pw160;
wire [3:0] wl;
wire pw161;
wire pw162;
wire pw16;
wire pw8;
reg pws8 = 1'b0;
reg pws16 = 1'b0;
reg pws64 = 1'b0;
wire notpws64;
wire pws816;
wire mws816;
wire notmws64;
wire dmuxu20;
wire ourackl;
wire dmuxu21;
wire [2:0] dmuxui;
wire dmuxu10;
wire dmuxu11;
wire dmuxu00;
wire dmuxu01;
wire dmuxd20;
wire dmuxd21;
wire [2:0] dmuxdi;
wire dmuxd10;
wire dmuxd11;
wire dmuxd00;
wire dmuxd01;
wire dren0;
wire dreni;
wire xdsrc1;
wire xdsrci;

reg old_clk;
always @(posedge sys_clk)
begin
	old_clk <= clk;
end

// BUS.NET (55) - den03 : nd6
assign den03 = ~(intbms & busy & notreads & testen & resetl);

// BUS.NET (56) - den04 : nd2
assign den04 = ~(ourack & resetl);

// BUS.NET (57) - den05 : nd3
assign den05 = ~(erd & testen & resetl);

// BUS.NET (58) - deni[0] : nd3p
assign deni[0] = ~(den03 & den04 & den05);

// BUS.NET (60) - den10 : nd6
assign den10 = ~(ext16 & busy & notreads & testen & resetl);

// BUS.NET (61) - deni[1] : nd3p
assign deni[1] = ~(den10 & den03 & den05);

// BUS.NET (63) - den20 : nd6
assign den20 = ~(extbms & busy & notreads & testen & resetl);

// BUS.NET (64) - deni[2] : nd3p
assign deni[2] = ~(den03 & den20 & den05);

// BUS.NET (66) - den[0-2] : nivu2
assign den[2:0] = deni[2:0];

// BUS.NET (74) - host16 : an2
assign host16 = cpubm & cpu16;

// BUS.NET (75) - ext16 : or2
assign ext16 = dbg | host16;

// BUS.NET (76) - xp : iv
assign xp = ~intbm;

// BUS.NET (77) - extbms : iv
assign extbms = ~intbms;

// BUS.NET (78) - notjustify : iv
assign notjustify = ~justify;

// BUS.NET (100) - pw640 : nd2
assign pw640 = ~(justify & w[3]);

// BUS.NET (101) - pw641 : nd2
assign pw641 = ~(notjustify & intbm);

// BUS.NET (102) - pw64 : nd2
assign pw64 = ~(pw640 & pw641);

// BUS.NET (104) - pw160 : nd6
assign pw160 = ~(justify & (w[3:0]==4'b0010));

// BUS.NET (105) - pw161 : nd3
assign pw161 = ~(notjustify & cpubm & cpu16);

// BUS.NET (106) - pw162 : nd2
assign pw162 = ~(notjustify & dbg);

// BUS.NET (107) - pw16 : nd3
assign pw16 = ~(pw160 & pw161 & pw162);

// BUS.NET (109) - pw8 : an4
assign pw8 = justify & (&wl[3:1]);

// BUS.NET (111) - pws8 : slatch
// BUS.NET (112) - pws16 : slatch
// BUS.NET (113) - pws64 : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (ack) begin
			pws8 <= pw8;
			pws16 <= pw16;
			pws64 <= pw64;
		end
	end
end

// BUS.NET (115) - notpws64 : iv
assign notpws64 = ~pws64;

// BUS.NET (116) - pws816 : or2
assign pws816 = pws8 | pws16;

// BUS.NET (117) - wsl[0-3] : iv
assign wl[3:0] = ~w[3:0];

// BUS.NET (126) - aen : nivu
assign aen = intbms;

// BUS.NET (130) - ainen : nivu2
assign ainen = xp;

// BUS.NET (132) - busy : ivh
assign busy = ~idle;

// BUS.NET (133) - notreads : ivh
assign notreads = ~reads;

// BUS.NET (134) - dbg : iv
assign dbg = ~notdbg;

// BUS.NET (135) - cpu16 : iv
assign cpu16 = ~cpu32;

// BUS.NET (136) - mws816 : or2
assign mws816 = mws8 | mws16;

// BUS.NET (137) - notmws64 : iv
assign notmws64 = ~mws64;

// BUS.NET (156) - dmuxu20 : nd4
assign dmuxu20 = ~(notmws64 & ba[2] & reads & ourackl);

// BUS.NET (157) - dmuxu21 : nd2
assign dmuxu21 = ~(notpws64 & notreads);

// BUS.NET (158) - dmuxui[2] : nd2
assign dmuxui[2] = ~(dmuxu20 & dmuxu21);

// BUS.NET (159) - dmuxu[2] : nivu2
assign dmuxu[2] = dmuxui[2];

// BUS.NET (168) - dmuxu10 : nd4
assign dmuxu10 = ~(mws816 & ba[1] & reads & ourackl);

// BUS.NET (169) - dmuxu11 : nd2
assign dmuxu11 = ~(pws816 & notreads);

// BUS.NET (170) - dmuxui[1] : nd2
assign dmuxui[1] = ~(dmuxu10 & dmuxu11);

// BUS.NET (171) - dmuxu[1] : nivu2
assign dmuxu[1] = dmuxui[1];

// BUS.NET (179) - dmuxu00 : nd4
assign dmuxu00 = ~(mws8 & ba[0] & reads & ourackl);

// BUS.NET (180) - dmuxu01 : nd2
assign dmuxu01 = ~(pws8 & notreads);

// BUS.NET (181) - dmuxui[0] : nd2
assign dmuxui[0] = ~(dmuxu00 & dmuxu01);

// BUS.NET (182) - dmuxu[0] : nivu2
assign dmuxu[0] = dmuxui[0];

// BUS.NET (190) - dmuxd20 : nd4
assign dmuxd20 = ~(notpws64 & ba[2] & reads & ourackl);

// BUS.NET (191) - dmuxd21 : nd3
assign dmuxd21 = ~(notmws64 & ba[2] & notreads);

// BUS.NET (192) - dmuxdi[2] : nd2
assign dmuxdi[2] = ~(dmuxd20 & dmuxd21);

// BUS.NET (193) - dmuxd[2] : nivu2
assign dmuxd[2] = dmuxdi[2];

// BUS.NET (201) - dmuxd10 : nd4
assign dmuxd10 = ~(pws816 & ba[1] & reads & ourackl);

// BUS.NET (202) - dmuxd11 : nd3
assign dmuxd11 = ~(mws816 & ba[1] & notreads);

// BUS.NET (203) - dmuxdi[1] : nd2
assign dmuxdi[1] = ~(dmuxd10 & dmuxd11);

// BUS.NET (204) - dmuxd[1] : nivu2
assign dmuxd[1] = dmuxdi[1];

// BUS.NET (212) - dmuxd00 : nd4
assign dmuxd00 = ~(pws8 & ba[0] & reads & ourackl);

// BUS.NET (213) - dmuxd01 : nd3
assign dmuxd01 = ~(mws8 & ba[0] & notreads);

// BUS.NET (214) - dmuxdi[0] : nd2
assign dmuxdi[0] = ~(dmuxd00 & dmuxd01);

// BUS.NET (215) - dmuxd[0] : nivu2
assign dmuxd[0] = dmuxdi[0];

// BUS.NET (219) - dren0 : nd2
assign dren0 = ~(intdev & reads);

// BUS.NET (220) - dreni : nd2
assign dreni = ~(dren0 & ourackl);

// BUS.NET (221) - dren : nivh
assign dren = dreni;

// BUS.NET (233) - xdsrc1 : nd2
assign xdsrc1 = ~(intdev & reads);

// BUS.NET (234) - ourackl : ivm
assign ourackl = ~ourack;

// BUS.NET (235) - xdsrci : an3
assign xdsrci = intbmw & xdsrc1 & ourackl;

// BUS.NET (236) - xdsrc : nivu2
assign xdsrc = xdsrci;
endmodule

