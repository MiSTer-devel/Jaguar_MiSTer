//`include "defs.v"

module _gpu_ram
(
	output [31:0] gpu_data_out,
	output gpu_data_oe,
	input [31:0] gpu_data_in,
	input clk,
	input gpu_memw,
	input [11:2] ram_addr,
	input ramen,
	input sys_clk // Generated
);
wire [9:0] rama;
wire ramwe;
wire ramcs;

// GPU_RAM.NET (27) - ramad[0-9] : nivniv
assign rama[9:0] = ram_addr[11:2];

// GPU_RAM.NET (31) - ramwe : nd2
assign ramwe = ~(ramen & gpu_memw);

assign ramcs = clk | ~ramen;

// GPU_RAM.NET (69) - ram : aba032a
_aba032a ram_inst
(
	.z_out /* BUS */ (gpu_data_out[31:0]),
	.z_oe /* BUS */ (gpu_data_oe),
	.z_in /* BUS */ (gpu_data_in[31:0]),
	.cs /* IN */ (ramcs),
	.we /* IN */ (ramwe),
	.a /* IN */ (rama[9:0]),
	.sys_clk(sys_clk) // Generated
);

endmodule
