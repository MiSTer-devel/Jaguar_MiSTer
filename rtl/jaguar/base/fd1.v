//`include "defs.v"

module fd1
(
	output	q,
	output	qn,
	input		d,
	input		cp,
	input		sys_clk
);

reg	fd_data = 1'b0;

assign q = fd_data;
assign qn = ~fd_data;
reg old_cp;
// always @(posedge cp)
always @(posedge sys_clk)
begin
	old_cp <= cp;
	if (~old_cp && cp) begin
		fd_data <= d;
	end
end

endmodule
