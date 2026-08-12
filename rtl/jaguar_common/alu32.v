//`include "defs.v"

module _alu32
(
	output [31:0] aluq,
	output alu_co,
	input [31:0] alua,
	input [31:0] alub,
	input carry_flag,
	input [2:0] alufunc,
	input dstdp_31,
	input rev_subp
);
// alufunc
//	0 = add
//	1 = add with carry
//	2 = subtract
//	3 = sub with carry
//	4 = and
//	5 = or
//	6 = xor 
//	7 = sub if alua neg
//	    add if alua pos
// the rev_sub bit changes subtract from alua-alub to alub-alua

wire [31:0] _and;
wire [31:0] _or;
wire [31:0] _xor;
wire [31:0] adda;
wire [31:0] addb;
wire [31:0] sum;
wire [1:0] subt;
wire subtract;
wire cint;
wire cin;
wire alu_cout;
wire [1:0] unused;
wire [1:0] sel;

// ARITH.NET (320) - subt0 : nd4p
assign subt[0] = ~(alufunc[2:0]==3'b111 & dstdp_31);

// ARITH.NET (321) - subt1 : nd2p
assign subt[1] = ~(alufunc[2:1]==2'b01);

// ARITH.NET (322) - subtract : nd2p
assign subtract = ~(&subt[1:0]);

// ARITH.NET (348) - adda : eo
assign adda[31:0] = alua[31:0] ^ {32{subtract & rev_subp}};

// ARITH.NET (349) - addb : eo
assign addb[31:0] = alub[31:0] ^ {32{subtract & ~rev_subp}};

// ARITH.NET (354) - cint : an3
assign cint = alufunc[0] & ~alufunc[2] & carry_flag;

// ARITH.NET (355) - cin : eo
assign cin = cint ^ subtract;

// ARITH.NET (359) - sum : fa32_int
assign {alu_cout,sum[31:0]} = {1'b0,adda[31:0]} + addb[31:0] + (cin?1'b1:1'b0);

// ARITH.NET (364) - and : an2
assign _and[31:0] = alua[31:0] & alub[31:0];

// ARITH.NET (365) - or : or2
assign _or[31:0] = alua[31:0] | alub[31:0];

// ARITH.NET (366) - xor : eo
assign _xor[31:0] = alua[31:0] ^ alub[31:0];

// ARITH.NET (370) - selt0 : aor1
assign sel[0] = alufunc[0] | ~alufunc[2];

// ARITH.NET (372) - selt1 : aor1
assign sel[1] = alufunc[1] | ~alufunc[2];

// ARITH.NET (375) - aluq : mx4p
assign aluq[31:0] = sel[1] ? (sel[0] ? sum[31:0] : _xor[31:0]) : (sel[0] ? _or[31:0] : _and[31:0]);

// ARITH.NET (379) - alu_co : eo
assign alu_co = alu_cout ^ subtract;

// ARITH.NET (381) - unused[0-1] : dummy
endmodule
