//`include "defs.v"
// altera message_off 10036

module _j_jiodec
(
	input [15:0] a,
	input dspcsl,
	input wel0,
	input oel0,
	input dspen,
	output pit1w,
	output pit2w,
	output pit3w,
	output pit4w,
	output clk1w,
	output clk2w,
	output clk3w,
	output int1w,
	output u2dwr,
	output u2ctwr,
	output u2psclw,
	output test1w,
	output joy1rl,
	output joy2rl,
	output joy1wl,
	output [5:0] gpiol,
	output int1r,
	output u2drd,
	output u2strd,
	output u2psclr,
	output pit1r,
	output pit2r,
	output pit3r,
	output pit4r,
	output internal,
	output [15:0] dr_out,
	output dr_oe
);
wire [15:0] addr;
wire dspcs;
wire wet;
wire oet;
wire nota00xx;
wire i00xxi;
wire i00xx;
wire axxx0;
wire axxx2;
wire axxx4;
wire axxx6;
wire axxx8;
wire axxxa;
wire axxxc;
wire axx0x;
wire axx1x;
wire axx2x;
wire axx3x;
wire axx6x;
wire notgpio;
wire float1;
wire float2;
wire float3;
wire float;

// Output buffers
wire int1r_obuf;
wire u2drd_obuf;
wire u2strd_obuf;
wire u2psclr_obuf;
wire pit1r_obuf;
wire pit2r_obuf;
wire pit3r_obuf;
wire pit4r_obuf;


// Output buffers
assign int1r = int1r_obuf;
assign u2drd = u2drd_obuf;
assign u2strd = u2strd_obuf;
assign u2psclr = u2psclr_obuf;
assign pit1r = pit1r_obuf;
assign pit2r = pit2r_obuf;
assign pit3r = pit3r_obuf;
assign pit4r = pit4r_obuf;


// JIODEC.NET (31) - addr : join
assign addr[15:0] = a[15:0];

// JIODEC.NET (38) - dspcs : ivh
assign dspcs = ~dspcsl;

// JIODEC.NET (39) - wet : ivh
assign wet = ~wel0;

// JIODEC.NET (40) - oet : ivh
assign oet = ~oel0;

// JIODEC.NET (42) - nota00xx_ : nd8
assign nota00xx = ~(a[15:8]==8'h00);

// JIODEC.NET (43) - i00xxi : nr2
assign i00xxi = ~(nota00xx | dspcsl);

// JIODEC.NET (44) - i00xx : nivu
assign i00xx = i00xxi;

// JIODEC.NET (46) - axxx0 : an3h
assign axxx0 = a[3:1]==3'h0;

// JIODEC.NET (47) - axxx2 : an3
assign axxx2 = a[3:1]==3'h1;

// JIODEC.NET (48) - axxx4 : an3
assign axxx4 = a[3:1]==3'h2;

// JIODEC.NET (49) - axxx6 : an3
assign axxx6 = a[3:1]==3'h3;

// JIODEC.NET (50) - axxx8 : an3
assign axxx8 = a[3:1]==3'h4;

// JIODEC.NET (51) - axxxa : an3
assign axxxa = a[3:1]==3'h5;

// JIODEC.NET (52) - axxxc : an3
assign axxxc = a[3:1]==3'h6;

// JIODEC.NET (54) - axx0x : an4
assign axx0x = a[7:4]==4'h0;

// JIODEC.NET (55) - axx1x : an4
assign axx1x = a[7:4]==4'h1;

// JIODEC.NET (56) - axx2x : an4
assign axx2x = a[7:4]==4'h2;

// JIODEC.NET (57) - axx3x : an4h
assign axx3x = a[7:4]==4'h3;

// JIODEC.NET (58) - axx6x : an4
assign axx6x = a[7:4]==4'h6;

// JIODEC.NET (71) - gpiol[0] : nd6
assign gpiol[0] = ~(dspcs & a[15:11]==5'b01001);						// F14800-F14FFF. GPIO0. (CD-Interface).

// JIODEC.NET (72) - gpiol[1] : nd6
assign gpiol[1] = ~(dspcs & a[15:12]==4'h5);							// F15000-F15FFF. GPIO1. (DMA ACK).

// JIODEC.NET (73) - gpiol[2] : nd6
assign gpiol[2] = ~(dspcs & a[15:12]==4'h6);							// F16000-F16FFF. GPIO2. (Cartridge).

// JIODEC.NET (74) - gpiol[3] : nd6
assign gpiol[3] = ~(dspcs & a[15:11]==5'b01110);						// F17000-F177FF. GPIO3.

// JIODEC.NET (75) - gpiol[4] : nd8
assign gpiol[4] = ~(dspcs & a[15:10]==6'b011110);		// F17800-F17BFF. GPIO4.

// JIODEC.NET (76) - gpiol[5] : nd8
assign gpiol[5] = ~(dspcs & a[15:10]==6'b011111);		// F17C00-F17FFF. GPIO5. (Paddle Interface).

// JIODEC.NET (78) - joy1r : nd8
assign joy1rl = ~(dspcs & a[15:11]==5'b01000 & axxx0 & oet);	// F14000. JOY1. Joystick register. READ.

// JIODEC.NET (79) - joy2r : nd8
assign joy2rl = ~(dspcs & a[15:11]==5'b01000 & axxx2 & oet);	// F14002. JOY2. Button register. READ.

// JIODEC.NET (80) - joy1w : nd8
assign joy1wl = ~(dspcs & a[15:11]==5'b01000 & axxx0 & wet);	// F14000. JOY1. Joystick register. WRITE

// JIODEC.NET (82) - gpio : nd2
assign notgpio = ~(a[15:14]==2'b01);

// JIODEC.NET (83) - internal : an2
assign internal = dspcs & notgpio;

// JIODEC.NET (87) - int1r : an4h
assign int1r_obuf = i00xx & axx2x & axxx0 & oet;	// F10020. INT.

// JIODEC.NET (88) - u2drd : an4h
assign u2drd_obuf = i00xx & axx3x & axxx0 & oet;	// F10030. ASIDATA.

// JIODEC.NET (89) - u2strd : an4h
assign u2strd_obuf = i00xx & axx3x & axxx2 & oet;	// F10032. ASICTRL.

// JIODEC.NET (90) - u2psclr : an4h
assign u2psclr_obuf = i00xx & axx3x & axxx4 & oet;	// F10034. ASICLK.

// JIODEC.NET (92) - pit1r : an4h
assign pit1r_obuf = i00xx & axx3x & axxx6 & oet;	// F10036. Timer 1 Pre-scaler (READ).

// JIODEC.NET (93) - pit2r : an4h
assign pit2r_obuf = i00xx & axx3x & axxx8 & oet;	// F10038. Timer 1 Divider (READ).

// JIODEC.NET (94) - pit3r : an4h
assign pit3r_obuf = i00xx & axx3x & axxxa & oet;	// F1003A. Timer 2 Pre-scaler (READ).

// JIODEC.NET (95) - pit4r : an4h
assign pit4r_obuf = i00xx & axx3x & axxxc & oet;	// F1003C. Timer 2 Divider (READ).

// JIODEC.NET (108) - float1 : nr6
assign float1 = ~(int1r_obuf | u2drd_obuf | u2strd_obuf | u2psclr_obuf | dspen);

// JIODEC.NET (112) - float2 : nr4
assign float2 = ~(pit1r_obuf | pit2r_obuf | pit3r_obuf | pit4r_obuf);

// JIODEC.NET (113) - float3 : an2
assign float3 = float1 & float2;

// JIODEC.NET (115) - float : nivh
assign float = float3;

// JIODEC.NET (116) - dr[0-15] : ts
assign dr_out[15:0] = 16'h0;
assign dr_oe = float;

// JIODEC.NET (120) - pit1w : an4h
assign pit1w = i00xx & axx0x & axxx0 & wet;	// F10000. Timer 1 Pre-scaler (WRITE).

// JIODEC.NET (121) - pit2w : an4h
assign pit2w = i00xx & axx0x & axxx2 & wet;	// F10002. Timer 1 Divider (WRITE).

// JIODEC.NET (122) - pit3w : an4h
assign pit3w = i00xx & axx0x & axxx4 & wet;	// F10004. Timer 2 Pre-scaler (WRITE).

// JIODEC.NET (123) - pit4w : an4h
assign pit4w = i00xx & axx0x & axxx6 & wet;	// F10006. Timer 2 Pre-scaler (WRITE).

// JIODEC.NET (124) - clk1w : an4h
assign clk1w = i00xx & axx1x & axxx0 & wet;	// F10010. CLK1 Processor Clock Divider (WRITE).

// JIODEC.NET (125) - clk2w : an4h
assign clk2w = i00xx & axx1x & axxx2 & wet;	// F10012. CLK2 Video Clock Divider (WRITE). 

// JIODEC.NET (126) - clk3w : an4h
assign clk3w = i00xx & axx1x & axxx4 & wet;	// F10014. CLK3 Chroma Clock Divider (WRITE).

// JIODEC.NET (127) - int1w : an4h
assign int1w = i00xx & axx2x & axxx0 & wet;	// F10020. INT (WRITE).

// JIODEC.NET (128) - u2dwr : an4h
assign u2dwr = i00xx & axx3x & axxx0 & wet;	// F10030. ASIDATA (WRITE).

// JIODEC.NET (129) - u2ctwr : an4h
assign u2ctwr = i00xx & axx3x & axxx2 & wet;	// F10032. ASICTRL (WRITE).

// JIODEC.NET (130) - u2psclw : an4h
assign u2psclw = i00xx & axx3x & axxx4 & wet;// F10034. ASICLK (WRITE).

// JIODEC.NET (132) - test1w : tie0
assign test1w = 1'b0;

endmodule
