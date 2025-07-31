//`include "defs.v"
// altera message_off 10036

module _iodec
(
	input [15:0] a,
	input intdev,
	input wet,
	input oet,
	input intswe,
	input reads,
	input intwe,
	input lba,
	input lbb,
	input clut,
	input ourack,
	input [1:0] romcsl,
	input dspcsl,
	output memc1r,
	output memc2r,
	output hcr,
	output vcr,
	output lphr,
	output lpvr,
	output ob0r,
	output ob1r,
	output ob2r,
	output ob3r,
	output lbrar,
	output test2r,
	output test3r,
	output intr,
	output pit0r,
	output pit1r,
	output memc1w,
	output memc2w,
	output olp1w,
	output olp2w,
	output obfw,
	output vmodew,
	output bord1w,
	output bord2w,
	output hcw,
	output hpw,
	output hbbw,
	output hbew,
	output hsw,
	output hvsw,
	output hdb1w,
	output hdb2w,
	output hdew,
	output vcw,
	output vpw,
	output vbbw,
	output vbew,
	output vsw,
	output vdbw,
	output vdew,
	output vebw,
	output veew,
	output viw,
	output pit0w,
	output pit1w,
	output heqw,
	output test1w,
	output lbraw,
	output int1w,
	output int2w,
	output bgwr,
	output expl
);
wire notintdev;
wire writes;
wire nota00xx;
wire a00xx;
wire nota02xx;
wire i00xxi;
wire i00xx;
wire i02xx;
wire axxx0i;
wire axxx0;
wire axxx2;
wire axxx4;
wire axxx6;
wire axxx8;
wire axxxa;
wire axxxc;
wire axxxe;
wire axx0xi;
wire axx0x;
wire axx1x;
wire axx2x;
wire axx3x;
wire axx4x;
wire axx5x;
wire axxex;
wire notmemc1;
wire float1;
wire lbbr;
wire float2;
wire float3;
wire lbar;
wire clutr;
wire gb1r;
wire gb2r;
wire float4;
wire floaten;
wire float5;
wire notourack;
wire dspcs;
wire exiol;

// Output buffers
wire memc2r_obuf;
wire hcr_obuf;
wire vcr_obuf;
wire lphr_obuf;
wire lpvr_obuf;
wire ob0r_obuf;
wire ob1r_obuf;
wire ob2r_obuf;
wire ob3r_obuf;
wire lbrar_obuf;
wire test2r_obuf;
wire test3r_obuf;
wire intr_obuf;
wire pit0r_obuf;
wire pit1r_obuf;


// Output buffers
assign memc2r = memc2r_obuf;
assign hcr = hcr_obuf;
assign vcr = vcr_obuf;
assign lphr = lphr_obuf;
assign lpvr = lpvr_obuf;
assign ob0r = ob0r_obuf;
assign ob1r = ob1r_obuf;
assign ob2r = ob2r_obuf;
assign ob3r = ob3r_obuf;
assign lbrar = lbrar_obuf;
assign test2r = test2r_obuf;
assign test3r = test3r_obuf;
assign intr = intr_obuf;
assign pit0r = pit0r_obuf;
assign pit1r = pit1r_obuf;

// IODEC.NET (47) - al[1-15] : iv

// IODEC.NET (48) - notintdev : iv
assign notintdev = ~intdev;

// IODEC.NET (49) - writes : iv
assign writes = ~reads;

// IODEC.NET (51) - nota00xx_ : nd8
assign nota00xx = ~(a[15:8] == 8'h00);

// IODEC.NET (52) - a00xx : iv
assign a00xx = ~nota00xx;

// IODEC.NET (53) - nota02xx_ : nd8
assign nota02xx = ~(a[15:8] == 8'h02);

// IODEC.NET (54) - i00xxi : nr2
assign i00xxi = ~(nota00xx | notintdev);

// IODEC.NET (55) - i00xx : nivu
assign i00xx = i00xxi;

// IODEC.NET (56) - i02xx_ : nr2
assign i02xx = ~(nota02xx | notintdev);

// IODEC.NET (58) - axxx0i : nd3
assign axxx0i = ~(a[3:1] == 3'b000);

// IODEC.NET (59) - axxx0 : ivm
assign axxx0 = ~axxx0i;

// IODEC.NET (60) - axxx2_ : an3m
assign axxx2 = a[3:1] == 3'b001;

// IODEC.NET (61) - axxx4_ : an3
assign axxx4 = a[3:1] == 3'b010;

// IODEC.NET (62) - axxx6_ : an3
assign axxx6 = a[3:1] == 3'b011;

// IODEC.NET (63) - axxx8_ : an3
assign axxx8 = a[3:1] == 3'b100;

// IODEC.NET (64) - axxxa_ : an3
assign axxxa = a[3:1] == 3'b101;

// IODEC.NET (65) - axxxc_ : an3
assign axxxc = a[3:1] == 3'b110;

// IODEC.NET (66) - axxxe_ : an3
assign axxxe = a[3:1] == 3'b111;

// IODEC.NET (68) - axx0xi : nd4
assign axx0xi = ~(a[7:4] == 4'h0);

// IODEC.NET (69) - axx0x : ivm
assign axx0x = ~axx0xi;

// IODEC.NET (70) - axx1x_ : an4
assign axx1x = a[7:4] == 4'h1;

// IODEC.NET (71) - axx2x_ : an4m
assign axx2x = a[7:4] == 4'h2;

// IODEC.NET (72) - axx3x_ : an4m
assign axx3x = a[7:4] == 4'h3;

// IODEC.NET (73) - axx4x_ : an4m
assign axx4x = a[7:4] == 4'h4;

// IODEC.NET (74) - axx5x_ : an4
assign axx5x = a[7:4] == 4'h5;

// IODEC.NET (75) - axxex_ : an4
assign axxex = a[7:4] == 4'hE;

// IODEC.NET (79) - notmemc1 : nd4
assign notmemc1 = ~(i00xx & axx0x & axxx0 & oet);

// IODEC.NET (80) - memc2r_ : an4h
assign memc2r_obuf = i00xx & axx0x & axxx2 & oet;

// IODEC.NET (81) - hcr_ : an4h
assign hcr_obuf = i00xx & axx0x & axxx4 & oet;

// IODEC.NET (82) - vcr_ : an4h
assign vcr_obuf = i00xx & axx0x & axxx6 & oet;

// IODEC.NET (83) - lphr_ : an4h
assign lphr_obuf = i00xx & axx0x & axxx8 & oet;

// IODEC.NET (84) - lpvr_ : an4h
assign lpvr_obuf = i00xx & axx0x & axxxa & oet;

// IODEC.NET (85) - ob0r_ : an4h
assign ob0r_obuf = i00xx & axx1x & axxx0 & oet;

// IODEC.NET (86) - ob1r_ : an4h
assign ob1r_obuf = i00xx & axx1x & axxx2 & oet;

// IODEC.NET (87) - ob2r_ : an4h
assign ob2r_obuf = i00xx & axx1x & axxx4 & oet;

// IODEC.NET (88) - ob3r_ : an4h
assign ob3r_obuf = i00xx & axx1x & axxx6 & oet;

// IODEC.NET (89) - test2r : an4h
assign test2r_obuf = i00xx & axx2x & axxx0 & oet;

// IODEC.NET (90) - test3r : an4h
assign test3r_obuf = i00xx & axx2x & axxx2 & oet;

// IODEC.NET (91) - pit0r_ : an4h
assign pit0r_obuf = i00xx & axx5x & axxx0 & oet;

// IODEC.NET (92) - pit1r_ : an4h
assign pit1r_obuf = i00xx & axx5x & axxx2 & oet;

// IODEC.NET (94) - intr : an4h
assign intr_obuf = i00xx & axxex & axxx0 & oet;

// IODEC.NET (96) - lbrar : an4h
assign lbrar_obuf = i02xx & axx0x & axxx0 & oet;

// IODEC.NET (103) - float1 : or8
assign float1 = lbbr | memc2r_obuf | hcr_obuf | vcr_obuf | lphr_obuf | lpvr_obuf | ob0r_obuf | ob1r_obuf;

// IODEC.NET (104) - float2 : or4
assign float2 = ob2r_obuf | ob3r_obuf | lbrar_obuf | test2r_obuf;

// IODEC.NET (105) - float3 : or8
assign float3 = test3r_obuf | intr_obuf | pit0r_obuf | pit1r_obuf | lbar | clutr | gb1r | gb2r;

// IODEC.NET (106) - float4 : nr3
assign float4 = ~(float1 | float2 | float3);

// IODEC.NET (107) - floaten : nd2
assign floaten = ~(oet & intdev);

// IODEC.NET (108) - float5 : nd2
assign float5 = ~(float4 & floaten);

// IODEC.NET (109) - memc1r : nd2x3
assign memc1r = ~(notmemc1 & float5);

// IODEC.NET (113) - memc1w_ : an4h
assign memc1w = i00xx & axx0x & axxx0 & wet;

// IODEC.NET (114) - memc2w_ : an4h
assign memc2w = i00xx & axx0x & axxx2 & intswe;

// IODEC.NET (115) - hcw_ : an4h
assign hcw = i00xx & axx0x & axxx4 & writes;

// IODEC.NET (116) - vcw_ : an4h
assign vcw = i00xx & axx0x & axxx6 & writes;

// IODEC.NET (117) - olp1w_ : an4h
assign olp1w = i00xx & axx2x & axxx0 & wet;

// IODEC.NET (118) - olp2w_ : an4h
assign olp2w = i00xx & axx2x & axxx2 & wet;

// IODEC.NET (119) - obfw_ : an4
assign obfw = i00xx & axx2x & axxx6 & writes;

// IODEC.NET (120) - vmodew_ : an4h
assign vmodew = i00xx & axx2x & axxx8 & intwe;

// IODEC.NET (121) - bord1w_ : an4h
assign bord1w = i00xx & axx2x & axxxa & wet;

// IODEC.NET (122) - bord2w_ : an4h
assign bord2w = i00xx & axx2x & axxxc & wet;

// IODEC.NET (123) - hpw_ : an4h
assign hpw = i00xx & axx2x & axxxe & wet;

// IODEC.NET (124) - hbbw_ : an4h
assign hbbw = i00xx & axx3x & axxx0 & wet;

// IODEC.NET (125) - hbew_ : an4h
assign hbew = i00xx & axx3x & axxx2 & wet;

// IODEC.NET (126) - hsw_ : an4h
assign hsw = i00xx & axx3x & axxx4 & wet;

// IODEC.NET (127) - hvsw_ : an4h
assign hvsw = i00xx & axx3x & axxx6 & wet;

// IODEC.NET (128) - hdb1w_ : an4h
assign hdb1w = i00xx & axx3x & axxx8 & wet;

// IODEC.NET (129) - hdb2w_ : an4h
assign hdb2w = i00xx & axx3x & axxxa & wet;

// IODEC.NET (130) - hdew_ : an4h
assign hdew = i00xx & axx3x & axxxc & wet;

// IODEC.NET (131) - vpw_ : an4h
assign vpw = i00xx & axx3x & axxxe & wet;

// IODEC.NET (132) - vbbw_ : an4h
assign vbbw = i00xx & axx4x & axxx0 & wet;

// IODEC.NET (133) - vbew_ : an4h
assign vbew = i00xx & axx4x & axxx2 & wet;

// IODEC.NET (134) - vsw_ : an4h
assign vsw = i00xx & axx4x & axxx4 & wet;

// IODEC.NET (135) - vdbw_ : an4h
assign vdbw = i00xx & axx4x & axxx6 & wet;

// IODEC.NET (136) - vdew_ : an4h
assign vdew = i00xx & axx4x & axxx8 & wet;

// IODEC.NET (137) - vebw_ : an4h
assign vebw = i00xx & axx4x & axxxa & wet;

// IODEC.NET (138) - veew_ : an4h
assign veew = i00xx & axx4x & axxxc & wet;

// IODEC.NET (139) - viw_ : an4h
assign viw = i00xx & axx4x & axxxe & wet;

// IODEC.NET (140) - pit0w_ : an4
assign pit0w = i00xx & axx5x & axxx0 & intswe;

// IODEC.NET (141) - pit1w_ : an4
assign pit1w = i00xx & axx5x & axxx2 & intswe;

// IODEC.NET (142) - heqw_ : an4h
assign heqw = i00xx & axx5x & axxx4 & wet;

// IODEC.NET (145) - test1w_ : tie0
assign test1w = 1'b0;

// IODEC.NET (147) - bgw_ : an4h
assign bgwr = i00xx & axx5x & axxx8 & wet;

// IODEC.NET (149) - intw : an4
assign int1w = i00xx & axxex & axxx0 & writes;

// IODEC.NET (150) - int2w : an4
assign int2w = i00xx & axxex & axxx2 & writes;

// IODEC.NET (152) - lbraw : an4h
assign lbraw = i02xx & axx0x & axxx0 & writes;

// IODEC.NET (156) - lbar : an2
assign lbar = lba & reads;

// IODEC.NET (157) - lbbr : an2
assign lbbr = lbb & reads;

// IODEC.NET (158) - clutr : an2
assign clutr = clut & reads;

// IODEC.NET (159) - gb1r : an4
assign gb1r = a[13] & intdev & reads & notourack;

// IODEC.NET (160) - gb2r : an4
assign gb2r = a[14] & intdev & reads & notourack;

// IODEC.NET (161) - notourack : iv
assign notourack = ~ourack;

// IODEC.NET (166) - dspcs : iv
assign dspcs = ~dspcsl;

// IODEC.NET (167) - exiol : nd3
assign exiol = ~(dspcs & a[14] & ~a[15]);

// IODEC.NET (168) - expl : an3
assign expl = exiol & (&romcsl[1:0]);
endmodule

