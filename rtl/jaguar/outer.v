//`include "defs.v"

module _outer
(
	output [15:11] gpu_dout_out,
	output gpu_dout_15_11_oe, // statrd; already handled above
	output a1updatei,
	output a1fupdatei,
	output a2updatei,
	output [1:0] blit_breq,
	output blit_int,
	output instart,
	output sshftld,
	input active,
	input clk,
	input cmdld,
	input countld,
	input [31:0] gpu_din,
	input indone,
	input reset_n,
	input statrd,
	input stopped,
	input sys_clk // Generated
);
reg idle = 1'b1;
reg inner = 1'b0;
reg a1fupdate = 1'b0;
reg a1update = 1'b0;
reg a2update = 1'b0;
reg upda1f = 1'b0;
reg upda1 = 1'b0;
reg upda2 = 1'b0;
reg bushi = 1'b0;
reg go = 1'b0;
wire outer0;
wire [2:0] idlet;
wire [5:0] innert;
wire innert2t;
wire [1:0] a1updt;
wire [1:0] a2updt;
wire ocntena;
wire breqt_n;
wire idledt;
reg idled = 1'b1;

// Output buffers
wire a1updatei_obuf;
wire a1fupdatei_obuf;
wire a2updatei_obuf;
wire instart_obuf;
reg sshftld_ = 1'b0;

wire resetl = reset_n;
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign a1updatei = a1updatei_obuf;
assign a1fupdatei = a1fupdatei_obuf;
assign a2updatei = a2updatei_obuf;
assign instart = instart_obuf;
assign sshftld = sshftld_;

// OUTER.NET (46) - stat[11] : ts
// OUTER.NET (47) - stat[12] : ts
// OUTER.NET (48) - stat[13] : ts
// OUTER.NET (49) - stat[14] : ts
// OUTER.NET (50) - stat[15] : ts
assign gpu_dout_out[11] = idle;
assign gpu_dout_out[12] = inner;
assign gpu_dout_out[13] = a1fupdate;
assign gpu_dout_out[14] = a1update;
assign gpu_dout_out[15] = a2update;
assign gpu_dout_15_11_oe = statrd;

// OUTER.NET (54) - upda1f : fdsync
// OUTER.NET (55) - upda1 : fdsync
// OUTER.NET (56) - upda2 : fdsync
// OUTER.NET (60) - bushi : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (cmdld) begin
			upda1f <= gpu_din[8];
			upda1 <= gpu_din[9];
			upda2 <= gpu_din[10];
			bushi <= gpu_din[29];
		end
		go <= cmdld & ~gpu_din[7];
	end
end

// OUTER.NET (80) - idle0 : nd2
assign idlet[0] = ~(idle & ~go);

// OUTER.NET (81) - idle1 : nd3
assign idlet[1] = ~(inner & outer0 & indone);

// OUTER.NET (82) - idle2 : nd2
assign idlet[2] = ~(&idlet[1:0]);

// OUTER.NET (83) - idle : fd4q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			idle <= 1'b1;
		end else begin
			idle <= idlet[2];
		end
	end
end

// OUTER.NET (88) - inner0 : nd2
assign innert[0] = ~(idle & go);

// OUTER.NET (89) - inner1 : nd2
assign innert[1] = ~(inner & ~indone);

// OUTER.NET (90) - inner2t : an5
assign innert2t = inner & ~outer0 & ~upda1f & ~upda1 & ~upda2;

// OUTER.NET (92) - inner2 : nd2
assign innert[2] = ~(indone & innert2t);

// OUTER.NET (93) - inner3 : nd2
assign innert[3] = ~(a1update & ~upda2);

// OUTER.NET (94) - inner4 : iv
assign innert[4] = ~a2update;

// OUTER.NET (95) - inner5 : nd5
assign innert[5] = ~(&innert[4:0]);

// OUTER.NET (96) - inner : fd2q
// OUTER.NET (102) - a1fupdate : fd2q
// OUTER.NET (110) - a1update : fd2q
// OUTER.NET (118) - a2update : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			inner <= 1'b0;
			a1fupdate <= 1'b0;
			a1update <= 1'b0;
			a2update <= 1'b0;
		end else begin
			inner <= innert[5];
			a1fupdate <= a1fupdatei_obuf;
			a1update <= a1updatei_obuf;
			a2update <= a2updatei_obuf;
		end
	end
end

// OUTER.NET (100) - a1fupd0 : an4
assign a1fupdatei_obuf = inner & indone & ~outer0 & upda1f;

// OUTER.NET (106) - a1upd0 : iv
assign a1updt[0] = ~a1fupdate;

// OUTER.NET (107) - a1upd1 : nd5
assign a1updt[1] = ~(inner & indone & ~outer0 & ~upda1f & upda1);

// OUTER.NET (109) - a1upd2 : nd2
assign a1updatei_obuf = ~(&a1updt[1:0]);

// OUTER.NET (114) - a2upd0 : nd2
assign a2updt[0] = ~(a1update & upda2);

// OUTER.NET (115) - a2upd1 : nd6
assign a2updt[1] = ~(inner & indone & ~outer0 & ~upda1f & ~upda1 & upda2);

// OUTER.NET (117) - a2upd2 : nd2
assign a2updatei_obuf = ~(&a2updt[1:0]);

// OUTER.NET (125) - instart : nd4u
assign instart_obuf = ~(innert[0] & &innert[4:2]);

// OUTER.NET (129) - sshftld : fd1qm
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		sshftld_ <= instart_obuf;
	end
end

// OUTER.NET (134) - ocntena : join
assign ocntena = instart_obuf;

// OUTER.NET (139) - breqt : nr2
assign breqt_n = ~(~idle | active);

// OUTER.NET (140) - blit_breq[0] : nr3
assign blit_breq[0] = ~(breqt_n | stopped | bushi);

// OUTER.NET (141) - blit_breq[1] : nr3
assign blit_breq[1] = ~(breqt_n | stopped | ~bushi);

// OUTER.NET (145) - outer_cnt : outer_cnt
reg [15:0] ocount = 16'h0;
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		ocount[15:0] <= countld ? gpu_din[31:16] : (ocntena ? (ocount[15:0] - 1'b1): ocount[15:0]);
	end
end
assign outer0 = ~(|ocount[15:0]);

// OUTER.NET (156) - idledt : nr2
assign idledt = ~(~idle | active);

// OUTER.NET (157) - idled : fd4q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			idled <= 1'b1;
		end else begin
			idled <= idledt;
		end
	end
end

// OUTER.NET (159) - blit_int : an2
assign blit_int = ~idled & idledt;
endmodule

