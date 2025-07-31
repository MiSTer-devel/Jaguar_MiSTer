//`include "defs.v"

module bank
(
	output match,
	input [10:0] a,
	input newrow,
	input resl,
	input sys_clk // Generated
);
reg [10:0] ra = 11'h000;
reg valid = 1'b1;

// ABUS.NET (483) - ra[0-10] : ldp1q
// always @(d or g)
// ABUS.NET (488) - valid : lsra
// always @(rn or sn)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (newrow) begin
		ra[10:0] <= a[10:0];
		valid <= 1'b1;
	end else if (~resl) begin
		valid <= 1'b0;
	end
end

// ABUS.NET (492) - m[0-10] : en
assign match = (ra[10:0] == a[10:0]) & valid;

endmodule

