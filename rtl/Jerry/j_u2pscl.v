//`include "defs.v"

module _j_u2pscl
(
	output bx16,
	input [15:0] din,
	input u2psclw,
	input u2psclr,
	input clk,
	input resetl,
	output [15:0] dr_out,
	output dr_oe,
	input sys_clk // Generated
);
reg [15:0] pd0 = 16'h0;
wire ten0;
wire presl0;
reg [15:0] tp0 = 16'h0;
wire tpld0;
wire tpld0i;

// UART2.NET (576) - pd0[0-15] : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		pd0[15:0] <= 16'h0;
	end else if (u2psclw) begin
		pd0[15:0] <= din[15:0];
	end
end

// UART2.NET (580) - ten00 : or8
// UART2.NET (581) - ten01 : or8
// UART2.NET (582) - ten0 : or2
assign ten0 = |pd0[15:0];

// UART2.NET (583) - presl0 : an2u
assign presl0 = ten0 & resetl;

// UART2.NET (587) - tp0[0] : dncnt
// UART2.NET (588) - tp0[1-7] : dncnt
// UART2.NET (589) - tp0[8] : dncnt
// UART2.NET (590) - tp0[9-15] : dncnt
reg old_clk;
reg old_presl0;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_presl0 <= presl0;

	if ((~old_clk && clk) | (old_presl0 && ~presl0)) begin
		if (~presl0) begin
			tp0[15:0] <= 16'h0;
		end else begin
			tp0[15:0] <= tpld0 ? pd0[15:0] : (tp0[15:0] - (ten0 ? 1'b1 : 1'b0));
		end
	end
end

// UART2.NET (598) - bx16 : nivh
assign bx16 = ~(|tp0[15:0]) & ten0; //carry[15]

// UART2.NET (599) - dtp0[0-15] : ts
assign dr_out[15:0] = tp0[15:0];
assign dr_oe = u2psclr;

// UART2.NET (600) - tpld0i : nr2
assign tpld0i = ~(bx16 | u2psclw);

// UART2.NET (601) - tpld0 : ivh
assign tpld0 = ~tpld0i;
endmodule
