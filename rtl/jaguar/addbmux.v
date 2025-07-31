//`include "defs.v"

module addbmux
(
	output [15:0] addb_x,
	output [15:0] addb_y,
	input [1:0] addbsel,
	input [15:0] a1_x,
	input [15:0] a1_y,
	input [15:0] a2_x,
	input [15:0] a2_y,
	input [15:0] a1_frac_x,
	input [15:0] a1_frac_y
);

// ADDRMUX.NET (136) - addb_x : mx4
assign addb_x[15:0] = addbsel[1] ? (addbsel[0] ? a1_x[15:0] : a1_frac_x[15:0]) : (addbsel[0] ? a2_x[15:0] : a1_x[15:0]);

// ADDRMUX.NET (138) - addb_y : mx4
assign addb_y[15:0] = addbsel[1] ? (addbsel[0] ? a1_y[15:0] : a1_frac_y[15:0]) : (addbsel[0] ? a2_y[15:0] : a1_y[15:0]);
endmodule
