//`include "defs.v"

module _mp16
(
	output	[31:0]	q,
	input		[15:0]	a,
	input		[15:0]	b,
	input		sign0,
	input		sign1,
	input		unk0,
	input		unk1
);

wire signed [15:0] ai;
wire signed [15:0] bi;
wire signed [31:0] qi;

wire [15:0] uai;
wire [15:0] ubi;
wire [31:0] uqi;

assign ai[15:0] = {a[15], a[14], a[13], a[12], a[11], a[10], 
	a[9], a[8], a[7], a[6], a[5], a[4], a[3], a[2], a[1], a[0]};
assign bi[15:0] = {b[15], b[14], b[13], b[12], b[11], b[10],
	b[9], b[8], b[7], b[6], b[5], b[4], b[3], b[2], b[1], b[0]};

assign qi = ai * bi;

assign uai[15:0] = {a[15], a[14], a[13], a[12], a[11], a[10], 
	a[9], a[8], a[7], a[6], a[5], a[4], a[3], a[2], a[1], a[0]};
assign ubi[15:0] = {b[15], b[14], b[13], b[12], b[11], b[10],
	b[9], b[8], b[7], b[6], b[5], b[4], b[3], b[2], b[1], b[0]};

assign uqi = uai * ubi;

assign q[31:0] = (sign0) ? qi[31:0]	: uqi[31:0];

endmodule
