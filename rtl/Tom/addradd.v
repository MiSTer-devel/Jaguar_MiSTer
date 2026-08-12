/* verilator lint_off LITENDIAN */
//`include "defs.v"

module _addradd
(
	output [15:0] addq_x,
	output [15:0] addq_y,
	input a1fracld,
	input [15:0] adda_x,
	input [15:0] adda_y,
	input [15:0] addb_x,
	input [15:0] addb_y,
	input clk,
	input [2:0] modx,
	input suba_x,
	input suba_y,
	input sys_clk // Generated
);
wire [15:0] addqt_x;
wire ci_x_n;
wire ci_y_n;
wire co_x;
wire co_y;
wire cxt_0;
wire cyt_0;
reg cxt_1 = 1'b0;
reg cyt_1 = 1'b0;
wire unused_0;
wire [4:0] masksel;
wire [5:0] maskbit;
wire [6:0] tmaskbit;
reg old_clk;

// ADDRADD.NET (45) - adder_x : fas16_s
//assign {co_x, addqt_x[15:0]} = adda_x[15:0] + addb_x[15:0] + {15'b0000000_00000000, ~ci_x_n};
wire [17:0] addx;
assign addx[17:0] = {adda_x[15:0], ~ci_x_n} + {addb_x[15:0], ~ci_x_n}; // add two halves of ~ci_x_n to reduce 3sum to 2sum
assign {co_x, addqt_x[15:0]} = addx[17:1];

// ADDRADD.NET (54) - adder_y : fas16_s
//assign {co_y, addq_y[15:0]} = adda_y[15:0] + addb_y[15:0] + {15'b0000000_00000000, ~ci_y_n};
wire [17:0] addy;
assign addy[17:0] = {adda_y[15:0], ~ci_y_n} + {addb_y[15:0], ~ci_y_n}; // add two halves of ~ci_y_n to reduce 3sum to 2sum
assign {co_y, addq_y[15:0]} = addy[17:1];

// ADDRADD.NET (67) - cxt0 : an2
assign cxt_0 = co_x & a1fracld;

// ADDRADD.NET (68) - cxt1 : fd1q
// ADDRADD.NET (73) - cyt1 : fd1q
always @(posedge sys_clk)
begin
	old_clk <= clk;
	if (~old_clk && clk) begin
		cxt_1 <= cxt_0;
		cyt_1 <= cyt_0;
	end
end

// ADDRADD.NET (69) - ci_x : en
assign ci_x_n = ~(cxt_1 ^ suba_x);

// ADDRADD.NET (72) - cyt0 : an2
assign cyt_0 = co_y & a1fracld;

// ADDRADD.NET (74) - ci_y : en
assign ci_y_n = ~(cyt_1 ^ suba_y);

// ADDRADD.NET (78) - masksel : d38h
assign tmaskbit[6:0] = 7'h1 << modx[2:0];
assign {maskbit[5],masksel[4:0]} = tmaskbit[6:1];

// ADDRADD.NET (81) - maskbit[0-4] : or2
assign maskbit[4:0] = masksel[4:0] | maskbit[5:1];

// ADDRADD.NET (83) - mask[0-5] : mx2
// ADDRADD.NET (86) - addq_x : join
assign addq_x[5:0] = ~maskbit[5:0] & addqt_x[5:0];
assign addq_x[15:6] = addqt_x[15:6];

endmodule
