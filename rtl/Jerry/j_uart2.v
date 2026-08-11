//`include "defs.v"
// altera message_off 10036

module _j_uart2
(
	input resetl,
	input clk,
	input [15:0] din,
	input u2psclw,
	input u2psclr,
	input u2drd,
	input u2dwr,
	input u2strd,
	input u2ctwr,
	input serin,
	output serout,
	output uint,
	output [15:0] dr_out,
	output dr_oe,
	input sys_clk // Generated
);
wire bx16;
reg txbrk = 1'b0;
reg clr_err = 1'b0;
reg rinten = 1'b0;
reg tinten = 1'b0;
reg rxpol = 1'b0;
reg txpol = 1'b0;
reg paren = 1'b0;
reg even = 1'b0;
wire error;
wire oe;
wire fe;
wire pe;
wire tbe;
wire rbf;
reg rintens = 1'b0;
reg tintens = 1'b0;
wire fep;
wire oep;
wire pep;
wire rbfp;
wire tbep;
wire feq;
reg feqd = 1'b0;
wire peq;
reg peqd = 1'b0;
wire oeq;
reg oeqd = 1'b0;
wire rbfq;
reg rbfqd = 1'b0;
wire tbeq;
reg tbeqd = 1'b0;

wire [15:0] dr_u2ps_out;
wire dr_u2ps_oe;
wire [15:0] dr_u2st_out;
wire dr_u2st_oe;
wire [15:0] dr_u2rx_out;
wire dr_u2rx_oe;

reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// UART2.NET (35) - u2prscl : u2pscl
_j_u2pscl u2prscl_inst
(
	.bx16 /* OUT */ (bx16),
	.din /* IN */ (din[15:0]),
	.u2psclw /* IN */ (u2psclw),
	.u2psclr /* IN */ (u2psclr),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.dr_out /* BUS */ (dr_u2ps_out[15:0]),
	.dr_oe /* BUS */ (dr_u2ps_oe),
	.sys_clk(sys_clk) // Generated
);

// UART2.NET (63) - txbrk : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		txbrk <= 1'b0;
	end else if (u2ctwr) begin
		txbrk <= din[14];
	end
end

// UART2.NET (64) - clr_err : fd1q
// UART2.NET (65) - nclr_err : an2
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		clr_err <= din[6] & u2ctwr;
	end
end

// UART2.NET (66) - rinten : ldp2q
// UART2.NET (67) - tinten : ldp2q
// UART2.NET (68) - rxpol : ldp2q
// UART2.NET (69) - txpol : ldp2q
// UART2.NET (70) - paren : ldp2q
// UART2.NET (71) - even : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		rinten <= 1'b0;
		tinten <= 1'b0;
		rxpol <= 1'b0;
		txpol <= 1'b0;
		paren <= 1'b0;
		even <= 1'b0;
	end else if (u2ctwr) begin
		rinten <= din[5];
		tinten <= din[4];
		rxpol <= din[3];
		txpol <= din[2];
		paren <= din[1];
		even <= din[0];
	end
end

// UART2.NET (75) - rerror : ts
// UART2.NET (76) - rtxbrk : ts
// UART2.NET (77) - rserin : ts
// UART2.NET (78) - dum : ts
// UART2.NET (79) - roe : ts
// UART2.NET (80) - rfe : ts
// UART2.NET (81) - rpe : ts
// UART2.NET (82) - rtbe : ts
// UART2.NET (83) - rrbf : ts
// UART2.NET (84) - ntused[2] : ts
// UART2.NET (85) - rrinten : ts
// UART2.NET (86) - rtinten : ts
// UART2.NET (87) - rrxpol : ts
// UART2.NET (88) - rtxpol : ts
// UART2.NET (89) - rparen : ts
// UART2.NET (90) - reven : ts
assign dr_u2st_oe = u2strd;
assign dr_u2st_out[15] = error;
assign dr_u2st_out[14] = txbrk;
assign dr_u2st_out[13] = serin;
assign dr_u2st_out[12] = 1'b0;
assign dr_u2st_out[11] = oe;
assign dr_u2st_out[10] = fe;
assign dr_u2st_out[9] = pe;
assign dr_u2st_out[8] = tbe;
assign dr_u2st_out[7] = rbf;
assign dr_u2st_out[6] = 1'b0;
assign dr_u2st_out[5] = rinten;
assign dr_u2st_out[4] = tinten;
assign dr_u2st_out[3] = rxpol;
assign dr_u2st_out[2] = txpol;
assign dr_u2st_out[1] = paren;
assign dr_u2st_out[0] = even;

// UART2.NET (94) - txer : txer
_j_txer txer_inst
(
	.serout /* OUT */ (serout),
	.tbe /* OUT */ (tbe),
	.din /* IN */ (din[15:0]),
	.u2dwr /* IN */ (u2dwr),
	.paren /* IN */ (paren),
	.even /* IN */ (even),
	.bx16 /* IN */ (bx16),
	.txpol /* IN */ (txpol),
	.txbrk /* IN */ (txbrk),
	.resetl /* IN */ (resetl),
	.clk /* IN */ (clk),
	.sys_clk(sys_clk) // Generated
);

// UART2.NET (99) - rxer : rxer
_j_rxer rxer_inst
(
	.rbf /* OUT */ (rbf),
	.pe /* OUT */ (pe),
	.oe /* OUT */ (oe),
	.fe /* OUT */ (fe),
	.error /* OUT */ (error),
	.clr_err /* IN */ (clr_err),
	.paren /* IN */ (paren),
	.even /* IN */ (even),
	.u2drd /* IN */ (u2drd),
	.rxpol /* IN */ (rxpol),
	.serin /* IN */ (serin),
	.resetl /* IN */ (resetl),
	.bx16 /* IN */ (bx16),
	.clk /* IN */ (clk),
	.dr_out /* BUS */ (dr_u2rx_out[15:0]),
	.dr_oe /* BUS */ (dr_u2rx_oe),
	.sys_clk(sys_clk) // Generated
);

// UART2.NET (105) - rintens : fd1q
// UART2.NET (106) - tintens : fd1q
// UART2.NET (112) - feqd : fd1
// UART2.NET (117) - peqd : fd1
// UART2.NET (122) - oeqd : fd1
// UART2.NET (127) - rbfqd : fd1
// UART2.NET (132) - tbeqd : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		rintens <= rinten;
		tintens <= tinten;
		feqd <= feq;
		peqd <= peq;
		oeqd <= oeq;
		rbfqd <= rbfq;
		tbeqd <= tbeq;
	end
end

// UART2.NET (108) - uint : or6
assign uint = fep | oep | pep | rbfp | tbep;

// UART2.NET (110) - fep : an2
assign fep = feq & ~feqd;

// UART2.NET (111) - feq : an2
assign feq = fe & rintens;

// UART2.NET (115) - pep : an2
assign pep = peq & ~peqd;

// UART2.NET (116) - peq : an2
assign peq = pe & rintens;

// UART2.NET (120) - oep : an2
assign oep = oeq & ~oeqd;

// UART2.NET (121) - oeq : an2
assign oeq = oe & rintens;

// UART2.NET (125) - rbfp : an2
assign rbfp = rbfq & ~rbfqd;

// UART2.NET (126) - rbfq : an2
assign rbfq = rbf & rintens;

// UART2.NET (130) - tbep : an2
assign tbep = tbeq & ~tbeqd;

// UART2.NET (131) - tbeq : an2
assign tbeq = tbe & tintens;

// --- Compiler-generated PE for BUS dr[0]
assign dr_out[15:0] = (dr_u2ps_oe ? dr_u2ps_out[15:0] : 16'h0) | (dr_u2st_oe ? dr_u2st_out[15:0] : 16'h0) | (dr_u2rx_oe ? dr_u2rx_out[15:0] : 16'h0);
assign dr_oe = dr_u2ps_oe | dr_u2st_oe | dr_u2rx_oe;

endmodule
