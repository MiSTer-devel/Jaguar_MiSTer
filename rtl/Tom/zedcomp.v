//`include "defs.v"

module _zedcomp
(
	output [3:0] zcomp,
	input [31:0] srczplo,
	input [31:0] srczphi,
	input [31:0] dstzlo,
	input [31:0] dstzhi,
	input [2:0] zmode
);
wire [3:0] zg;
wire [3:0] ze;
wire [3:0] zl;
wire [3:0] zlt;
wire [3:0] zet;
wire [3:0] zgt;

// DATACOMP.NET (132) - zcomp[0] : mag_16
assign zg[0] = srczplo[15:0] >  dstzlo[15:0];
assign ze[0] = srczplo[15:0] == dstzlo[15:0];
assign zl[0] = srczplo[15:0] <  dstzlo[15:0];

// DATACOMP.NET (134) - zcomp[1] : mag_16
assign zg[1] = srczplo[31:16] >  dstzlo[31:16];
assign ze[1] = srczplo[31:16] == dstzlo[31:16];
assign zl[1] = srczplo[31:16] <  dstzlo[31:16];

// DATACOMP.NET (136) - zcomp[2] : mag_16
assign zg[2] = srczphi[15:0] >  dstzhi[15:0];
assign ze[2] = srczphi[15:0] == dstzhi[15:0];
assign zl[2] = srczphi[15:0] <  dstzhi[15:0];

// DATACOMP.NET (138) - zcomp[3] : mag_16
assign zg[3] = srczphi[31:16] >  dstzhi[31:16];
assign ze[3] = srczphi[31:16] == dstzhi[31:16];
assign zl[3] = srczphi[31:16] <  dstzhi[31:16];

// DATACOMP.NET (141) - zlt[0-3] : nd2
assign zlt[3:0] = zmode[0] ? zl[3:0] : 4'h0;

// DATACOMP.NET (142) - zet[0-3] : nd2
assign zet[3:0] = zmode[1] ? ze[3:0] : 4'h0;

// DATACOMP.NET (143) - zgt[0-3] : nd2
assign zgt[3:0] = zmode[2] ? zg[3:0] : 4'h0;

// DATACOMP.NET (144) - zcmp[0-3] : nd3p
assign zcomp[3:0] = (zlt[3:0] | zet[3:0] | zgt[3:0]);
endmodule
