//`include "defs.v"

module _outer_cnt
(
	output outer0,
	input clk,
	input countld,
	input [31:0] gpu_din,
	input ocntena,
	input sys_clk // Generated
);
reg [15:0] ocount = 16'h0;

// OUTER.NET (188) - counto : dcount16
reg old_clk;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	if (~old_clk && clk) begin
		ocount[15:0] <= countld ? gpu_din[31:16] : (ocntena ? (ocount[15:0] - 1'b1): ocount[15:0]);
	end
end

// OUTER.NET (195) - outer0 : an2
assign outer0 = ~(|ocount[15:0]);
endmodule
