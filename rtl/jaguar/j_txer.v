//`include "defs.v"
// altera message_off 10036

module _j_txer
(
	output serout,
	output tbe,
	input [15:0] din,
	input u2dwr,
	input paren,
	input even,
	input bx16,
	input txpol,
	input txbrk,
	input resetl,
	input clk,
	input sys_clk // Generated
);
reg [7:0] sd = 8'h0;
wire [7:0] ntxr;
reg [7:0] txr = 8'h0;
wire shift;
wire load;
wire txen;
reg seldat = 1'b0;
reg f1 = 1'b0;
wire nf1;
wire nnf1;
wire f1f;
wire f1t;
reg selpar = 1'b0;
reg f0 = 1'b0;
wire nf0;
wire f0f;
wire nseldat;
wire seldatf;
wire nselpar;
wire selparf;
wire tc;
reg txd = 1'b0;
wire txbrkl;
wire ntxd;
wire txda;
wire txdb;
reg tpar = 1'b0;
wire ntpar;
wire tpa;
wire tpb;
wire tpc;
wire tpd;
wire tpe;
reg [2:0] dc = 3'h0;
wire [2:0] ndc;
wire ci_0;
wire [1:0] co;
reg scs = 1'b0;
reg dscs = 1'b0;
wire ntbe;
wire tbea;
wire tbeb;
wire tbec;
reg df1 = 1'b0;
wire [3:0] bco;
reg [3:0] bg = 4'b0;
wire [3:0] nbg ;
reg co3d = 1'b0;
wire txenw;
reg tbe_ = 1'b0;

assign tbe = tbe_;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// UART2.NET (423) - sd[0-7] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (u2dwr) begin
		sd[7:0] <= din[7:0];
	end
end

// UART2.NET (429) - ntxr[0-6] : mx4
// UART2.NET (430) - ntxr[7] : mx4
assign ntxr[7:0] = load ? sd[7:0] : shift ? {1'b0,txr[7:1]} : txr[7:0];

// UART2.NET (431) - txr[0-7] : fd1q
// UART2.NET (443) - f1 : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		txr[7:0] <= ntxr[7:0];
		f1 <= nf1;
	end
end

// UART2.NET (433) - shift : an2h
assign shift = txen & seldat;

// UART2.NET (434) - load : an2h
assign load = txen & f1;

// UART2.NET (444) - nf1 : nd2
assign nf1 = ~(nnf1 & resetl);

// UART2.NET (445) - nnf1 : mx2
assign nnf1 = (f1) ? f1t : f1f;

// UART2.NET (446) - f1f : nd2
assign f1f = ~(selpar & txen);

// UART2.NET (447) - f1t : an2
assign f1t = ~tbe & txen;

// UART2.NET (449) - f0 : fd2
// UART2.NET (454) - seldat : fd2
// UART2.NET (458) - selpar : fd2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			f0 <= 1'b0;
			seldat <= 1'b0;
			selpar <= 1'b0;
		end else begin
			f0 <= nf0;
			seldat <= nseldat;
			selpar <= nselpar;
		end
	end
end

// UART2.NET (451) - nf0 : mx2
assign nf0 = (f0) ? ~txen : f0f;

// UART2.NET (452) - f0f : an3
assign f0f = f1 & ~tbe & txen;

// UART2.NET (455) - nseldat : mx2
assign nseldat = (seldat) ? ~tc : seldatf;

// UART2.NET (456) - seldatf : an2
assign seldatf = f0 & txen;

// UART2.NET (460) - nselpar : mx2
assign nselpar = (selpar) ? ~txen : selparf;

// UART2.NET (461) - selparf : an2
assign selparf = seldat & tc;

// UART2.NET (467) - serout : eo
assign serout = txd ^ txpol;

// UART2.NET (469) - txbrkl : iv
assign txbrkl = ~txbrk;

// UART2.NET (470) - txd : fd2q
reg old_txbrkl;
always @(posedge sys_clk)
begin
	old_txbrkl <= txbrkl;
	if ((~old_clk && clk) | (old_txbrkl && ~txbrkl)) begin
		if (~txbrkl) begin
			txd <= 1'b0;
		end else begin
			txd <= ntxd;
		end
	end
end

// UART2.NET (471) - ntxd : nd3
assign ntxd = ~(txda & txdb & ~f1);

// UART2.NET (472) - txda : nd2
assign txda = ~(tpar & selpar);

// UART2.NET (473) - txdb : nd2
assign txdb = ~(seldat & txr[0]);

// UART2.NET (486) - tpar : fd1
// UART2.NET (504) - dc[0-2] : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		tpar <= ntpar;
		dc[2:0] <= ndc[2:0];
	end
end

// UART2.NET (487) - ntpar : nd6
assign ntpar = ~(tpa & tpb & tpc & tpd & tpe);

// UART2.NET (488) - tpa : nd3
assign tpa = ~(txen & ~even & ~seldat);

// UART2.NET (489) - tpb : nd3
assign tpb = ~(txen & even & ~paren);

// UART2.NET (490) - tpc : nd6
assign tpc = ~(txen & ~txr[0] & seldat & paren & tpar);

// UART2.NET (491) - tpd : nd6
assign tpd = ~(txen & txr[0] & seldat & paren & ~tpar);

// UART2.NET (492) - tpe : nd2
assign tpe = ~(~txen & tpar);

// UART2.NET (506) - ci[0] : an2
assign ci_0 = seldat & txen;

// UART2.NET (507) - co[0] : an3
assign co[0] = ci_0 & dc[0] & txen;

// UART2.NET (508) - co[1] : an3
assign co[1] = co[0] & dc[1] & txen;

// UART2.NET (509) - tc : an2
assign tc = co[1] & dc[2];

// UART2.NET (512) - ndc[0] : mx4
// UART2.NET (513) - ndc[1-2] : mx4
assign ndc[2:0] = {co[1:0],ci_0} ? 3'h0 : (dc[2:0] ^ {3{~seldat}});

// UART2.NET (520) - scs : fd1
// UART2.NET (521) - dscs : fd1q
// UART2.NET (523) - tbe : fd1
// UART2.NET (529) - df1 : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		scs <= u2dwr;
		dscs <= scs;
		tbe_ <= ntbe;
		df1 <= f1;
	end
end

// UART2.NET (524) - ntbe : an3
assign ntbe = tbea & tbeb & tbec;

// UART2.NET (525) - tbea : nd3
assign tbea = ~(resetl & ~scs & dscs);

// UART2.NET (526) - tbeb : nd3
assign tbeb = ~(resetl & ~tbe & f1);

// UART2.NET (527) - tbec : nd3
assign tbec = ~(resetl & ~tbe & ~df1);

// UART2.NET (539) - bco[3] : an6
assign bco[3] = &bg[3:0] & bx16;

// UART2.NET (540) - bco[2] : an4
assign bco[2] = bg[2] & &bco[1:0] & bx16;

// UART2.NET (541) - bco[1] : an3
assign bco[1] = &bg[1:0] & bx16;

// UART2.NET (542) - bco[0] : an2
assign bco[0] = bg[0] & bx16;

// UART2.NET (545) - bg[0-3] : fd2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			bg[3:0] <= 4'h0;
		end else begin
			bg[3:0] <= nbg[3:0];
		end
	end
end

// UART2.NET (549) - nbg[3] : mx2
// UART2.NET (550) - nbg[2] : mx2
// UART2.NET (551) - nbg[1] : mx2
// UART2.NET (552) - nbg[0] : mx2
assign nbg[3:0] = {bco[2:0],bx16} ^ bg[3:0];

// UART2.NET (554) - co3d : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		co3d <= bco[3];
	end
end

// UART2.NET (556) - txenw : an2
assign txenw = bco[3] & ~co3d;

// UART2.NET (558) - txen : nivh
assign txen = txenw;

endmodule
