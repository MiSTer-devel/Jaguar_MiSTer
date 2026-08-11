/* verilator lint_off LITENDIAN */
//`include "defs.v"
// altera message_off 10036

module _j_sinerom
(
	output [31:0] gpu_data_out,
	output gpu_data_oe,
	input gpu_data_in_15,
	input clk,
	input [9:0] roma,
	input romen,
	input sys_clk // Generated
);
wire romcs;

// DSP_RAM.NET (132) - romcs : clkgen
assign romcs = clk | ~romen;

// DSP_RAM.NET (133) - sinerom : raa016a
_raa016a sinerom_inst
(
	.z_out /* BUS */ (gpu_data_out[15:0]),
	.z_oe /* BUS */ (gpu_data_oe),
	.cs /* IN */ (romcs),
	.a /* IN */ (roma[9:0]),
	.sys_clk(sys_clk) // Generated
);

// DSP_RAM.NET (138) - gpu_data : join_bus
assign gpu_data_out[31:16] = {16{gpu_data_in_15}};
endmodule
/* verilator lint_on LITENDIAN */
