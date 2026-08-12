//`include "defs.v"

module _addarray
(
	output [15:0] addq_0,
	output [15:0] addq_1,
	output [15:0] addq_2,
	output [15:0] addq_3,
	input [15:0] adda_0,
	input [15:0] adda_1,
	input [15:0] adda_2,
	input [15:0] adda_3,
	input [15:0] addb_0,
	input [15:0] addb_1,
	input [15:0] addb_2,
	input [15:0] addb_3,
	input [2:0] daddmode,
	input clk_0,
	input reset_n,
	input sys_clk // Generated
);
wire cinsel;
reg [3:0] carryq = 4'h0;
wire [3:0] co;
wire [3:0] cin;
wire eightbit;
wire sat;
wire hicinh;

wire clk=clk_0;
wire resetl=reset_n;
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// ADDARRAY.NET (60) - cinsel : nr2p
assign cinsel = ~(&(~daddmode[1:0]) | daddmode[2]);

// ADDARRAY.NET (64) - carrylat[0-3] : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			carryq[3:0] <= 4'b0; // fd2q negedge // always @(posedge cp or negedge cd)
		end else begin
			carryq[3:0] <= co[3:0];
		end
	end
end

// ADDARRAY.NET (68) - cin[0-3] : an2
assign cin[3:0] = cinsel ? carryq[3:0] : 4'h0;

// ADDARRAY.NET (72) - eightbit : join
assign eightbit = daddmode[1];
// ADDARRAY.NET (76) - sat : or2p
assign sat = |daddmode[1:0];
// ADDARRAY.NET (80) - hicinh : an2p
assign hicinh = &daddmode[1:0];

// ADDARRAY.NET (84) - adder1 : add16sat
_add16sat adder1_inst
(
	.r /* OUT */ (addq_0[15:0]),
	.co /* OUT */ (co[0]),
	.a /* IN */ (adda_0[15:0]),
	.b /* IN */ (addb_0[15:0]),
	.cin /* IN */ (cin[0]),
	.sat /* IN */ (sat),
	.eightbit /* IN */ (eightbit),
	.hicinh /* IN */ (hicinh)
);

// ADDARRAY.NET (87) - adder2 : add16sat
_add16sat adder2_inst
(
	.r /* OUT */ (addq_1[15:0]),
	.co /* OUT */ (co[1]),
	.a /* IN */ (adda_1[15:0]),
	.b /* IN */ (addb_1[15:0]),
	.cin /* IN */ (cin[1]),
	.sat /* IN */ (sat),
	.eightbit /* IN */ (eightbit),
	.hicinh /* IN */ (hicinh)
);

// ADDARRAY.NET (90) - adder3 : add16sat
_add16sat adder3_inst
(
	.r /* OUT */ (addq_2[15:0]),
	.co /* OUT */ (co[2]),
	.a /* IN */ (adda_2[15:0]),
	.b /* IN */ (addb_2[15:0]),
	.cin /* IN */ (cin[2]),
	.sat /* IN */ (sat),
	.eightbit /* IN */ (eightbit),
	.hicinh /* IN */ (hicinh)
);

// ADDARRAY.NET (93) - adder4 : add16sat
_add16sat adder4_inst
(
	.r /* OUT */ (addq_3[15:0]),
	.co /* OUT */ (co[3]),
	.a /* IN */ (adda_3[15:0]),
	.b /* IN */ (addb_3[15:0]),
	.cin /* IN */ (cin[3]),
	.sat /* IN */ (sat),
	.eightbit /* IN */ (eightbit),
	.hicinh /* IN */ (hicinh)
);
endmodule

