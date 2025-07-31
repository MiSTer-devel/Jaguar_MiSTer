//`include "defs.v"

module _blitgpu
(
	output a1baseld,
	output a1flagld,
	output a1fracld,
	output a1incld,
	output a1incfld,
	output a1posrd,
	output a1posfrd,
	output a1ptrld,
	output a1stepld,
	output a1stepfld,
	output a1winld,
	output a2baseld,
	output a2flagld,
	output a2posrd,
	output a2ptrld,
	output a2stepld,
	output a2winld,
	output cmdld,
	output countld,
	output [1:0] dstdld,
	output [1:0] dstzld,
	output iincld,
	output [3:0] intld,
	output [1:0] patdld,
	output [1:0] srcd1ld,
	output [1:0] srcz1ld,
	output [1:0] srcz2ld,
	output statrd,
	output stopld,
	output [3:0] zedld,
	output zincld,
	input a1fracldi,
	input a1ptrldi,
	input a2ptrldi,
	input blit_back,
	input bliten,
	input dstdread,
	input dstzread,
	input [23:0] gpu_addr,
	input gpu_memw,
	input patdadd,
	input patfadd,
	input srcdread,
	input srcz1add,
	input srczread
);
wire wren[4:0];
wire a1ptrldg;
wire a1fracldg;
wire a2ptrldg;
wire cmdldt;
wire countldt;
wire [1:0] srcd1ldg;
wire [1:0] dstdldg;
wire [1:0] dstzldg;
wire [1:0] srcz1ldg;
wire [1:0] patdldg;
wire brd;

// BLITGPU.NET (77) - wren0 : nd5
assign wren[0] = (gpu_addr[7:5] == 3'b000 & bliten & gpu_memw);

// BLITGPU.NET (79) - wren1 : nd5
assign wren[1] = (gpu_addr[7:5] == 3'b001  & bliten & gpu_memw);

// BLITGPU.NET (81) - wren2 : nd6
assign wren[2] = (gpu_addr[7:5] == 3'b010 & bliten & gpu_memw & ~blit_back);

// BLITGPU.NET (83) - wren3 : nd6
assign wren[3] = (gpu_addr[7:5] == 3'b011 & bliten & gpu_memw & ~blit_back);

// BLITGPU.NET (85) - wren4 : nd6
assign wren[4] = (gpu_addr[7:5] == 3'b100 & bliten & gpu_memw & ~blit_back);

// BLITGPU.NET (88) - dec0 : d38gh
assign {a1incld,a1fracldg,a1stepfld,a1stepld,a1ptrldg,a1winld,a1flagld,a1baseld} = wren[0] ? (8'h01 << gpu_addr[4:2]) : 8'h00;

// BLITGPU.NET (91) - dec1 : d38gh
assign {countldt,cmdldt,a2stepld,a2ptrldg,a2winld,a2flagld,a2baseld,a1incfld} = wren[1] ? (8'h01 << gpu_addr[4:2]) : 8'h00;

// BLITGPU.NET (94) - dec2 : d38gh
assign {srcz1ldg[1:0],dstzldg[1:0],dstdldg[1:0],srcd1ldg[1:0]} = wren[2] ? (8'h01 << gpu_addr[4:2]) : 8'h00;

// BLITGPU.NET (97) - dec3 : d38gh
assign {intld[0],stopld,zincld,iincld,patdldg[1:0],srcz2ld[1:0]} = wren[3] ? (8'h01 << gpu_addr[4:2]) : 8'h00;

// BLITGPU.NET (100) - dec4 : d38gh
assign {zedld[3:0],intld[3:1]} = wren[4] ? (7'h01 << gpu_addr[4:2]) : 7'h00;

// BLITGPU.NET (103) - cmdld : nivu
assign cmdld = cmdldt;

// BLITGPU.NET (104) - countld : nivu
assign countld = countldt;

// BLITGPU.NET (108) - a1ptrld : or2u
assign a1ptrld = a1ptrldi | a1ptrldg;

// BLITGPU.NET (109) - a1fracld : or2u
assign a1fracld = a1fracldi | a1fracldg;

// BLITGPU.NET (110) - a2ptrld : or2u
assign a2ptrld = a2ptrldi | a2ptrldg;

// BLITGPU.NET (111) - dstdld[0-1] : or2
assign dstdld[1:0] = dstdread ? 2'b11 : dstdldg[1:0];

// BLITGPU.NET (112) - dstzld[0-1] : or2
assign dstzld[1:0] = dstzread ? 2'b11 : dstzldg[1:0];

// BLITGPU.NET (113) - srcd1ld[0-1] : or3u
assign srcd1ld[1:0] = (srcdread | patfadd) ? 2'b11 : srcd1ldg[1:0];

// BLITGPU.NET (115) - srcz1ld[0-1] : or3u
assign srcz1ld[1:0] = (srczread | srcz1add) ? 2'b11 : srcz1ldg[1:0];

// BLITGPU.NET (121) - patdld[0-1] : or2u
assign patdld[1:0] = patdadd ? 2'b11 : patdldg[1:0];

// BLITGPU.NET (126) - brd : an2
assign brd = bliten & ~gpu_memw;

// 10 Blitter Pointer Read Registers are at the wrong address
// Level 1 software
// Description The blitter pointer registers, which are written at addresses F0220C and F02230, appear for
// read at F02204 and F0222C. This error was also present on version 1 silicon.
// Work-around Read them at the incorrect addresses.

// BLITGPU.NET (128) - statrd : an6u
assign statrd = brd & gpu_addr[6:2] == 5'b011_10; // F02238

// BLITGPU.NET (130) - a1posrd : an6u
assign a1posrd = brd & gpu_addr[6:2] == 5'b000_01; // F02204 - TOM Bug 10 Should have been F0220C

// BLITGPU.NET (132) - a1posfrd : an6u
assign a1posfrd = brd & gpu_addr[6:2] == 5'b001_10; // F02218

// BLITGPU.NET (134) - a2posrd : an6u
assign a2posrd = brd & gpu_addr[6:2] == 5'b010_11; // F0222C - TOM Bug 10 Should have been F02230
endmodule
