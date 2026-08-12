//`include "defs.v"

module _addrcomp
(
	output a1_outside,
	input [15:0] a1_x,
	input [15:0] a1_y,
	input [14:0] a1_win_x,
	input [14:0] a1_win_y
);
wire a1xgr;
wire a1xeq;
//wire a1xlt;
wire a1ygr;
wire a1yeq;
//wire a1ylt;

// ADDRCOMP.NET (26) - a1_xcomp : mag_15
assign a1xgr = a1_x[14:0] > a1_win_x[14:0];
assign a1xeq = a1_x[14:0] ==a1_win_x[14:0];
//assign a1xlt = a1_x[14:0] < a1_win_x[14:0];

// ADDRCOMP.NET (28) - a1_ycomp : mag_15
assign a1ygr = a1_y[14:0] > a1_win_y[14:0];
assign a1yeq = a1_y[14:0] ==a1_win_y[14:0];
//assign a1ylt = a1_y[14:0] < a1_win_y[14:0];

// ADDRCOMP.NET (30) - a1_outside : or6
assign a1_outside = a1_x[15] | a1xgr | a1xeq | a1_y[15] | a1ygr | a1yeq;

endmodule
