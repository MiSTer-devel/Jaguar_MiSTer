//`include "defs.v"

module _barrel32
(
	output [31:0] z,
	input [1:0] mux,
	input [4:0] sft,
	input flin,
	input [31:0] a
);
wire [31:0] f;
wire [31:0] dcd;
wire [31:0] rmask;
wire [31:0] lmask;
wire lsl;
wire sr;
wire asr_sign;
wire [31:0] opt0;
wire [31:0] opt1;

// ARITH.NET (623) - b[0-15] : mx2
// ARITH.NET (624) - b[16-31] : mx2
wire [63:0] t;
assign t[63:0] = {32'h0,a[31:0]} << sft[4:0];
assign f[31:0] = t[31:0] | t[63:32];

// ARITH.NET (640) - dcd0 : d416gh
assign dcd[15:0] = sft[4] ? 16'h0 : (16'h0001 << sft[3:0]);

// ARITH.NET (641) - dcd1 : d416gh
assign dcd[31:16] = ~sft[4] ? 16'h0 : (16'h0001 << sft[3:0]);

// ARITH.NET (654) - rmask[0] : join
assign rmask[0] = dcd[0];

// ARITH.NET (655) - rmask[1-7] : or2
assign rmask[7:1] = rmask[6:0] | dcd[7:1];

// ARITH.NET (656) - rmask[8] : or9
assign rmask[8] = |dcd[8:0];

// ARITH.NET (657) - rmask[9-15] : or2
assign rmask[15:9] = rmask[14:8] | dcd[15:9];

// ARITH.NET (658) - rmask[16] : or9
assign rmask[16] = (|dcd[16:0]);

// ARITH.NET (659) - rmask[17-23] : or2
assign rmask[23:17] = rmask[22:16] | dcd[23:17];

// ARITH.NET (660) - rmask[24] : or9
assign rmask[24] = (|dcd[24:0]);

// ARITH.NET (661) - rmask[25-31] : or2
assign rmask[31:25] = rmask[30:24] | dcd[31:25];

// ARITH.NET (674) - lmask[31] : join
assign lmask[31] = 1'b0;

// ARITH.NET (675) - lmask[30] : join
assign lmask[30] = dcd[31];

// ARITH.NET (676) - lmask[24-29] : or2
assign lmask[29:24] = lmask[30:25] | dcd[30:25];

// ARITH.NET (677) - lmask[23] : or8
assign lmask[23] = (|dcd[31:24]);

// ARITH.NET (678) - lmask[16-22] : or2
assign lmask[22:16] = lmask[23:17] | dcd[23:17];

// ARITH.NET (679) - lmask[15] : or9
assign lmask[15] = (|dcd[31:16]);

// ARITH.NET (680) - lmask[8-14] : or2
assign lmask[14:8] = lmask[15:9] | dcd[15:9];

// ARITH.NET (681) - lmask[7] : or9
assign lmask[7] = (|dcd[31:8]);

// ARITH.NET (682) - lmask[0-6] : or2
assign lmask[6:0] = lmask[7:1] | dcd[7:1];

// ARITH.NET (687) - lsl : an2u
assign lsl = (mux[1:0] == 2'b00);

// ARITH.NET (688) - sr : nivu
assign sr = mux[0];

// ARITH.NET (689) - asr_sign : an3u
assign asr_sign = (mux[1:0] == 2'b11) & a[31];

// ARITH.NET (692) - opt0[0-31] : anr2
assign opt0[31:0] = ~( (lsl ? lmask[31:0] : 32'h0) | (sr ? rmask[31:0] : 32'h0) );

// ARITH.NET (694) - opt1[0-31] : an2
assign opt1[31:0] = asr_sign ? rmask[31:0] : 32'h0;

// ARITH.NET (695) - opt[0-31] : aor1
assign z[31:0] = (f[31:0] & opt0[31:0]) | opt1[31:0];
endmodule
