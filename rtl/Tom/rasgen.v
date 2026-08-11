//`include "defs.v"

module _rasgen
(
	output csl,
	input on1,
	input roffl,
	input bs,
	input allonl,
	input alloffl,
	input clk,
	input resl,
	input sys_clk // Generated
);
wire ronl;
wire ron;
wire roff;
reg cs = 1'b0;

// MEM.NET (760) - ronl : nd2
assign ronl = ~(bs & on1);

// MEM.NET (761) - ron : nd2
assign ron = ~(ronl & allonl);

// MEM.NET (762) - roff : nd2
assign roff = ~(roffl & alloffl);

assign csl = ~cs;
reg old_clk, old_resl;

// always @(posedge cp or negedge cd)
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resl <= resl;

	if ((~old_clk && clk) | (old_resl && ~resl)) begin
		if (~resl) begin
			cs <= 1'b0;
		end else begin
			if (~ron & roff) begin
				cs <= 1'b0;
			end else if (ron & ~roff) begin
				cs <= 1'b1;
			end else if (ron & roff) begin
				cs <= ~cs;
			end
		end
	end
end

// MEM.NET (764) - csl : dummy
endmodule

