//`include "defs.v"

module _add16sat
(
	output [15:0] r,
	output co,
	input [15:0] a,
	input [15:0] b,
	input cin,
	input sat,
	input eightbit,
	input hicinh
);
wire eightbit_n;
wire hicinh_n;
wire [7:0] q0;
wire [15:0] q1;
wire [15:8] q2;
wire [15:12] q3;
wire carryt;
wire [3:0] carry;
wire btop;
wire ctop;
wire ctopb;
wire satt;
wire saturate;
wire hisaturate;

// ADDARRAY.NET (125) - eightbit\ : iv
assign eightbit_n = ~eightbit;

// ADDARRAY.NET (130) - hicinh\ : iv
//assign hicinh_n = ~hicinh;

// ADDARRAY.NET (132) - add0 : add4
// ADDARRAY.NET (133) - add1 : add4
// Expand addition by one bit with cin to avoid 3 argument add
// Use seperate adders for each case to avoid stacking adds
wire z0,z1;
assign {carry[0],q0[7:0],z0} = {1'b0,a[7:0],cin} + {b[7:0],cin};
assign {carry[1],q1[15:0],z1} = {1'b0,a[15:0],cin} + {b[15:0],cin};
//assign {carry[0],q[7:0]} = {1'b0,a[7:0]} + b[7:0] + cin;

// ADDARRAY.NET (136) - carry[1] : an2
//assign carry[1] = eightbit_n & carry[0];

// ADDARRAY.NET (138) - add2 : add4
assign {carry[2],q2[15:8]} = {1'b0,a[15:8]} + b[15:8];
//assign {carry[2],q[11:8]} = {1'b0,a[11:8]} + b[11:8] + carry[1];

// ADDARRAY.NET (141) - carry[3] : an2
//assign carry[3] = hicinh_n & carry[2];

// ADDARRAY.NET (143) - add3 : add4
assign {carry[3],q3[15:12]} = {1'b0,a[15:12]} + b[15:12];
//assign {co,q[15:12]} = {1'b0,a[15:12]} + b[15:12] + carry[3];
assign co = hicinh ? carry[3] : eightbit ? carry[2] : carry[1];

// ADDARRAY.NET (207) - btop : mx2
assign btop = (eightbit) ? b[7] : b[15];

// ADDARRAY.NET (208) - ctop : mx2p
assign ctop = (eightbit) ? carry[0] : co;

// ADDARRAY.NET (209) - ctopb : nivh
assign ctopb = ctop;

// ADDARRAY.NET (213) - satt : eo
assign satt = btop ^ ctop;

// ADDARRAY.NET (214) - saturate : an2p
assign saturate = sat & satt;

// ADDARRAY.NET (215) - saturateb : nivh

// ADDARRAY.NET (219) - hisaturate : an2m
assign hisaturate = eightbit_n & saturate;

// ADDARRAY.NET (223) - r[0-7] : mx2p
assign r[7:0] = (saturate) ? {8{ctopb}} : q0[7:0];

// ADDARRAY.NET (224) - r[8-15] : mx2p
assign r[15:12] = (hisaturate) ? {4{ctopb}} : hicinh ? {q3[15:12]} : eightbit ? q2[15:12] : q1[15:12];
assign r[11:8] = (hisaturate) ? {4{ctopb}} : eightbit ? q2[11:8] : q1[11:8];

endmodule

