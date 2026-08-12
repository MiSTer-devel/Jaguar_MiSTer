//`include "defs.v"

module j_gpuram
(
	output [31:0] gpu_data_out,
	output gpu_data_oe,
	input [31:0] gpu_data_in,
	input clk,
	input [9:0] rama,
	input ramen,
	input ramwe,
	input sys_clk // Generated
);
wire ramcs;

// DSP_RAM.NET (112) - ramcs : clkgen
//
// assign ena_n = ~ena;
// assign ramcs = clk | ena_n;
//
assign ramcs = clk | ~ramen;

// DSP_RAM.NET (114) - ram : aba032a
_aba032a ram_inst
(
	.z_out /* BUS */ (gpu_data_out[31:0]),
	.z_oe /* BUS */ (gpu_data_oe),
	.z_in /* BUS */ (gpu_data_in[31:0]),
	.cs /* IN */ (ramcs),	// Active LOW.
	.we /* IN */ (ramwe),	// Active LOW.
	.a /* IN */ (rama[9:0]),
	.sys_clk(sys_clk) // Generated
);
endmodule

