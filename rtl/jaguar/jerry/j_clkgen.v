/* verilator lint_off LITENDIAN */
//`include "defs.v"

module j_clkgen
(
	output ramcs,
	input clk,
	input ena
);
wire ena_n;

// _DUPLO.NET (115) - ena\ : iv
assign ena_n = ~ena;

// _DUPLO.NET (116) - ramcs : or2x3
assign ramcs = clk | ena_n;
endmodule
/* verilator lint_on LITENDIAN */
