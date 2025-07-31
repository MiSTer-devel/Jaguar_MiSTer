//`include "defs.v"

module _addamux
(
	output [15:0] adda_x,
	output [15:0] adda_y,
	input [2:0] addasel,
	input [15:0] a1_step_x,
	input [15:0] a1_step_y,
	input [15:0] a1_stepf_x,
	input [15:0] a1_stepf_y,
	input [15:0] a2_step_x,
	input [15:0] a2_step_y,
	input [15:0] a1_inc_x,
	input [15:0] a1_inc_y,
	input [15:0] a1_incf_x,
	input [15:0] a1_incf_y,
	input [2:0] adda_xconst,
	input adda_yconst,
	input addareg,
	input suba_x,
	input suba_y
);
wire [15:0] addac_x;
wire [15:0] addac_y;
wire [15:0] addar_x;
wire [15:0] addar_y;
wire [15:0] addart_x;
wire [15:0] addart_y;

// ADDRMUX.NET (71) - addart_x : mx4
assign addart_x[15:0] = addasel[1] ? (addasel[0] ? a1_incf_x[15:0] : a1_inc_x[15:0]) : (addasel[0] ? a1_stepf_x[15:0] : a1_step_x[15:0]);

// ADDRMUX.NET (73) - addar_x : mx2
assign addar_x[15:0] = addasel[2] ? a2_step_x[15:0] : addart_x[15:0];

// ADDRMUX.NET (74) - addart_y : mx4
assign addart_y[15:0] = addasel[1] ? (addasel[0] ? a1_incf_y[15:0] : a1_inc_y[15:0]) : (addasel[0] ? a1_stepf_y[15:0] : a1_step_y[15:0]);

// ADDRMUX.NET (76) - addar_y : mx2
assign addar_y[15:0] = addasel[2] ? a2_step_y[15:0] : addart_y[15:0];

// ADDRMUX.NET (83) - addac_xlo : d38h
// ADDRMUX.NET (87) - addac_x : join
assign addac_x[6:0] = 7'h01 << adda_xconst[2:0];
assign addac_x[15:7] = 9'h0;

// ADDRMUX.NET (89) - addac_y : join
assign addac_y[0] = adda_yconst;
assign addac_y[15:1] = 15'h0;

// ADDRMUX.NET (95) - addas_x : mx2
// ADDRMUX.NET (100) - suba_x16 : join
// ADDRMUX.NET (108) - adda_x : eo
assign adda_x[15:0] = {16{suba_x}} ^ ((addareg) ? addar_x[15:0] : addac_x[15:0]);

// ADDRMUX.NET (96) - addas_y : mx2
// ADDRMUX.NET (104) - suba_y16 : join
// ADDRMUX.NET (109) - adda_y : eo
assign adda_y[15:0] = {16{suba_y}} ^ ((addareg) ? addar_y[15:0] : addac_y[15:0]);
endmodule
