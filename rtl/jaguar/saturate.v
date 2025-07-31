//`include "defs.v"

module _saturate
(
	output [23:0] q,
	input [31:0] d,
	input sixteen,
	input twentyfour
);
wire sign_n;
wire oflow24;
wire oflow16;
wire oflow8;
wire [23:0] opt;
wire [23:0] op;
wire op8t15t0;
wire op8t15t1;
wire [4:0] lobt;

// ARITH.NET (535) - sign\ : ivh
assign sign_n = ~d[31];

// ARITH.NET (538) - oflow24 : or7m
assign oflow24 = |d[30:24];

// ARITH.NET (539) - oflow16 : or8
assign oflow16 = |d[23:16];

// ARITH.NET (540) - oflow8 : or8
assign oflow8 = |d[15:8];

// ARITH.NET (549) - opt[16-23] : or2
assign opt[23:16] = oflow24 ? 8'hff : d[23:16];

// ARITH.NET (550) - op[16-23] : an3
assign op[23:16] = (twentyfour & sign_n) ? opt[23:16] : 8'h0;

// ARITH.NET (562) - op8t15t0 : or2
assign op8t15t0 = twentyfour | sixteen;

// ARITH.NET (563) - op8t15t1 : aor1p
assign op8t15t1 = (oflow16 & ~twentyfour) | oflow24;

// ARITH.NET (564) - opt[8-15] : or2
assign opt[15:8] = op8t15t1 ? 8'hff : d[15:8];

// ARITH.NET (565) - op[8-15] : an3
assign op[15:8] = (op8t15t0 & sign_n) ? opt[15:8] : 8'h0;

// ARITH.NET (580) - lobt0 : nr2
assign lobt[0] = ~(sixteen | twentyfour);

// ARITH.NET (581) - lobt1 : nd2
assign lobt[1] = ~(lobt[0] & oflow8);

// ARITH.NET (582) - lobt2 : nd2
assign lobt[2] = ~(oflow16 & sixteen);

// ARITH.NET (583) - lobt3 : iv
assign lobt[3] = ~oflow24;

// ARITH.NET (584) - lobt4 : nd3p
assign lobt[4] = ~(&lobt[3:1]);

// ARITH.NET (585) - opt[0-7] : or2
assign opt[7:0] = lobt[4] ? 8'hff : d[7:0];

// ARITH.NET (586) - op[0-7] : an2
assign op[7:0] = sign_n ? opt[7:0] : 8'h00;

// ARITH.NET (588) - q : join
assign q[23:0] = op[23:0];
endmodule

