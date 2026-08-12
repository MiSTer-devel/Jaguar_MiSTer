//`include "defs.v"

module _daddamux
(
	output [15:0] adda_0,
	output [15:0] adda_1,
	output [15:0] adda_2,
	output [15:0] adda_3,
	input [31:0] dstd_0,
	input [31:0] dstd_1,
	input [31:0] srcd_0,
	input [31:0] srcd_1,
	input [31:0] patd_0,
	input [31:0] patd_1,
	input [31:0] srcz1_0,
	input [31:0] srcz1_1,
	input [31:0] srcz2_0,
	input [31:0] srcz2_1,
	input [2:0] daddasel
);
wire [31:0] addalo;
wire [31:0] addahi;
wire [31:0] sello;
wire [31:0] selhi;

// DATAMUX.NET (39) - sello : mx4
assign sello[31:0] = daddasel[1] ? (daddasel[0] ? srcz2_0[31:0] : srcz1_0[31:0]) : (daddasel[0] ? patd_0[31:0] : srcd_0[31:0]);

// DATAMUX.NET (41) - selhi : mx4
assign selhi[31:0] = daddasel[1] ? (daddasel[0] ? srcz2_1[31:0] : srcz1_1[31:0]) : (daddasel[0] ? patd_1[31:0] : srcd_1[31:0]);

// DATAMUX.NET (44) - addalo : mx2p
assign addalo[31:0] = (daddasel[2]) ? sello[31:0] : dstd_0[31:0];

// DATAMUX.NET (45) - addahi : mx2p
assign addahi[31:0] = (daddasel[2]) ? selhi[31:0] : dstd_1[31:0];

// DATAMUX.NET (47) - adda[0] : join
assign adda_0[15:0] = addalo[15:0];

// DATAMUX.NET (48) - adda[1] : join
assign adda_1[15:0] = addalo[31:16];

// DATAMUX.NET (49) - adda[2] : join
assign adda_2[15:0] = addahi[15:0];

// DATAMUX.NET (50) - adda[3] : join
assign adda_3[15:0] = addahi[31:16];
endmodule
