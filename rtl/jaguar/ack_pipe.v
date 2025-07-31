//`include "defs.v"

module _ack_pipe
(
	output latch,
	input latchd,
	input ack,
	input clk,
	input resetl,
	input sys_clk // Generated
);
wire notack;
wire d0;
reg q = 1'b0;
wire d1;
wire d;

// OB.NET (689) - notack : iv
assign notack = ~ack;

// OB.NET (690) - d0 : nd2
assign d0 = ~(q & notack);

// OB.NET (691) - d1 : iv
assign d1 = ~latchd;

// OB.NET (692) - d : nd2
assign d = ~(d0 & d1);

// OB.NET (693) - q : fd2q
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			q <= 1'b0;
		end else begin
			q <= d;
		end
	end
end

// OB.NET (694) - latch : an2
assign latch = q & ack;
endmodule

