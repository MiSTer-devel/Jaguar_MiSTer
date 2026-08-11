//`include "defs.v"

module _daddbmux
(
	output [15:0] addb_0,
	output [15:0] addb_1,
	output [15:0] addb_2,
	output [15:0] addb_3,
	input [31:0] srcdlo,
	input [31:0] srcdhi,
	input [31:0] iinc,
	input [31:0] zinc,
	input [2:0] daddbsel
);
wire [15:0] word;
wire [15:0] iinclo;
wire [15:0] iinchi;
wire [15:0] srcdw_0;
wire [15:0] srcdw_1;
wire [15:0] srcdw_2;
wire [15:0] srcdw_3;
wire [15:0] zinclo;
wire [15:0] zinchi;

// DATAMUX.NET (77) - iinclo : join
assign iinclo[15:0] = iinc[15:0];

// DATAMUX.NET (78) - iinchi : join
assign iinchi[15:0] = iinc[31:16];

// DATAMUX.NET (79) - zinclo : join
assign zinclo[15:0] = zinc[15:0];

// DATAMUX.NET (80) - zinchi : join
assign zinchi[15:0] = zinc[31:16];

// DATAMUX.NET (85) - word : mx4p
assign word[15:0] = daddbsel[1] ? (daddbsel[0] ? zinchi[15:0] : zinclo[15:0]) : (daddbsel[0] ? iinchi[15:0] : iinclo[15:0]);

// DATAMUX.NET (88) - srcdw0 : join
assign srcdw_0[15:0] = srcdlo[15:0];

// DATAMUX.NET (89) - srcdw1 : join
assign srcdw_1[15:0] = srcdlo[31:16];

// DATAMUX.NET (90) - srcdw2 : join
assign srcdw_2[15:0] = srcdhi[15:0];

// DATAMUX.NET (91) - srcdw3 : join
assign srcdw_3[15:0] = srcdhi[31:16];

// DATAMUX.NET (95) - addb[0] : mx2p
assign addb_0[15:0] = (daddbsel[2]) ? word[15:0] : srcdw_0[15:0];

// DATAMUX.NET (96) - addb[1] : mx2p
assign addb_1[15:0] = (daddbsel[2]) ? word[15:0] : srcdw_1[15:0];

// DATAMUX.NET (97) - addb[2] : mx2p
assign addb_2[15:0] = (daddbsel[2]) ? word[15:0] : srcdw_2[15:0];

// DATAMUX.NET (98) - addb[3] : mx2p
assign addb_3[15:0] = (daddbsel[2]) ? word[15:0] : srcdw_3[15:0];
endmodule
