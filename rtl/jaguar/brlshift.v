//`include "defs.v"

module _brlshift
(
	output [31:0] brlq,
	output brl_carry,
	input [1:0] brlmux,
	input [31:0] srcdp,
	input [31:0] brld
);
wire [4:0] srcdpc;
wire scc_1;
wire scc_2;
wire scc_3;
wire rotate_n;
wire rotate;
wire uflowt;
wire uflow;
wire b5t30h_n;
wire b5t30h;
wire shzero;
wire shzero_n;
wire oflowt;
wire oflow;
wire outflowt_n;
wire outflow;
wire outflow_n;
wire [4:0] shiftcnt;
wire mux0t;
wire [1:0] mux;
wire ashr_n;
wire [31:0] z;

// ARITH.NET (415) - srcdc[0] : join
assign srcdpc[4:0] = -(srcdp[4:0]);

// ARITH.NET (429) - rotate\ : nd2
assign rotate_n = ~(brlmux[1:0]==2'b10);

// ARITH.NET (430) - rotate : iv
assign rotate = ~rotate_n;

// ARITH.NET (436) - uflowt : nr26
assign uflowt = ~(|srcdp[30:5]);

// ARITH.NET (437) - uflow : nr2
assign uflow = ~(srcdp[31] | uflowt);

// ARITH.NET (443) - b5t30h\ : nd26
assign b5t30h_n = ~(&srcdp[30:5]);

// ARITH.NET (444) - b5t30h : iv
assign b5t30h = ~b5t30h_n;

// ARITH.NET (445) - shzero : nr5
assign shzero = ~(|srcdp[4:0]);

// ARITH.NET (446) - shzero\ : iv
assign shzero_n = ~shzero;

// ARITH.NET (447) - oflowtt : aor1
assign oflowt = (b5t30h & shzero) | b5t30h_n;

// ARITH.NET (448) - oflow : an2
assign oflow = srcdp[31] & oflowt;

// ARITH.NET (454) - outflowt\ : nr2
assign outflowt_n = ~(oflow | uflow);

// ARITH.NET (455) - outflow : nr2
assign outflow = ~(outflowt_n | rotate);

// ARITH.NET (456) - outflow\ : iv
assign outflow_n = ~outflow;

// ARITH.NET (458) - shiftcnt[0-4] : an2
assign shiftcnt[4:0] = outflow_n ? srcdpc[4:0] : 5'h0;

// ARITH.NET (465) - mux0t : nd3
assign mux0t = ~(~srcdp[31] & rotate_n & shzero_n);

// ARITH.NET (466) - mux0 : nd2
assign mux[0] = ~(mux0t & outflow_n);

// ARITH.NET (474) - ashr\ : nd3
assign ashr_n = ~(~srcdp[31] & brlmux[1:0]==2'b11);

// ARITH.NET (475) - mux1t : nd2
assign mux[1] = ~(ashr_n & rotate_n);

// ARITH.NET (486) - brl : barrel32
_barrel32 brl_inst
(
	.z /* OUT */ (z[31:0]),
	.mux /* IN */ (mux[1:0]),
	.sft /* IN */ (shiftcnt[4:0]),
	.flin /* IN */ (1'b0),
	.a /* IN */ (brld[31:0])
);

// ARITH.NET (489) - brlq : join
assign brlq[31:0] = z[31:0];

// ARITH.NET (494) - brl_carry : mx2
assign brl_carry = (mux[0]) ? brld[0] : brld[31];
endmodule
