//`include "defs.v"

module _cpu
(
	input [1:0] sizin,
	input rwin,
	input notack,
	input ack,
	input dreqin,
	input resetl,
	input clk_0,
	input intbm,
	input intbms,
	input m68k,
	input ba,
	input dbgl,
	output dtackl,
	output erd,
	output [3:0] w_out,
	output w_oe,
	input [3:0] w_in,
	output rw_out,
	output rw_oe,
	input rw_in,
	output mreq_out,
	output mreq_oe,
	output justify_out,
	output justify_oe,
	input sys_clk // Generated
);
wire [1:0] w68k;
wire bmcpu;
wire bm68k;
wire sizin_2;
wire [2:0] xw;
wire xp;
wire extbms;
wire dbg;
wire cmreq;
reg [13:11] q = 3'b000;
wire [13:11] d;
wire idlei;
wire idle;
wire mt11a;
wire mt11b;
wire not68k;
wire mt11c;
wire lds;
wire mt11d;
wire uds;
wire mt111;
wire mt120;
wire mt121;
wire mt130;
wire mt13a;
wire mt13b;
wire mt13c;
wire mt13d;
reg readcycle = 1'b0;

wire clk = clk_0;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// CPU.NET (31) - w68k[1] : nr2
assign w68k[1] = ~(|sizin[1:0]);

// CPU.NET (32) - w68k[0] : iv
assign w68k[0] = ~w68k[1];

// CPU.NET (33) - bmcpu : iv
assign bmcpu = ~ba;

// CPU.NET (34) - bm68k : an2
assign bm68k = m68k & bmcpu;

// CPU.NET (35) - jsizin[2] : nr2
assign sizin_2 = ~(|sizin[1:0]);

// CPU.NET (38) - xw[0] : mx2
// CPU.NET (39) - xw[1] : mx2
// CPU.NET (40) - xw[2] : mx2
assign xw[2:0] = (bm68k) ? {1'b0,w68k[1:0]} : {sizin_2,sizin[1:0]};

// CPU.NET (42) - xp : ivm
assign xp = ~intbm;

// CPU.NET (43) - extbms : ivm
assign extbms = ~intbms;

// CPU.NET (44) - dbg : iv
assign dbg = ~dbgl;

// CPU.NET (46) - w[0-2] : ts
// CPU.NET (47) - w[3] : ts
assign w_out[3:0] = {1'b0,xw[2:0]};
assign w_oe = xp;

// CPU.NET (48) - rw : ts
assign rw_out = rwin;
assign rw_oe = xp;

// CPU.NET (49) - mreq : tsm
assign mreq_out = cmreq;
assign mreq_oe = xp;

// CPU.NET (50) - justify : ts
assign justify_out = 1'b0;
assign justify_oe = xp;

// CPU.NET (74) - q11 : fd2q
// CPU.NET (75) - q12 : fd2q
// CPU.NET (76) - q13 : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			q[13:11] <= 3'h0;
		end else begin
			q[13:11] <= d[13:11];
		end
	end
end

// CPU.NET (78) - idlei : nr3
assign idlei = ~(|q[13:11]);

// CPU.NET (79) - idle : niv
assign idle = idlei;

// CPU.NET (81) - mt11a : nd3
assign mt11a = ~(dbg & dreqin & idle);

// CPU.NET (82) - mt11b : nd6
assign mt11b = ~(bmcpu & dreqin & not68k & extbms & idle);

// CPU.NET (83) - mt11c : nd6
assign mt11c = ~(bmcpu & dreqin & lds & m68k & extbms & idle);

// CPU.NET (84) - mt11d : nd6
assign mt11d = ~(bmcpu & dreqin & uds & m68k & extbms & idle);

// CPU.NET (85) - mt111 : nd2
assign mt111 = ~(q[11] & notack);

// CPU.NET (86) - d11 : nd6
assign d[11] = ~(mt11a & mt11b & mt11c & mt11d & mt111);

// CPU.NET (88) - mt120 : nd2
assign mt120 = ~(q[11] & ack);

// CPU.NET (89) - mt121 : nd2
assign mt121 = ~(q[12] & notack);

// CPU.NET (90) - d12 : nd2
assign d[12] = ~(mt120 & mt121);

// CPU.NET (92) - mt130 : nd2
assign mt130 = ~(q[12] & ack);

// CPU.NET (93) - mt13a : nd4
assign mt13a = ~(ba & dreqin & extbms & q[13]);

// CPU.NET (94) - mt13b : nd6
assign mt13b = ~(bmcpu & dreqin & not68k & extbms & q[13]);

// CPU.NET (95) - mt13c : nd6
assign mt13c = ~(bmcpu & dreqin & lds & m68k & extbms & q[13]);

// CPU.NET (96) - mt13d : nd6
assign mt13d = ~(bmcpu & dreqin & uds & m68k & extbms & q[13]);

// CPU.NET (97) - d13 : nd6
assign d[13] = ~(mt130 & mt13a & mt13b & mt13c & mt13d);

// CPU.NET (99) - cmreq : niv
assign cmreq = q[11];

// CPU.NET (101) - dt1 : iv
assign dtackl = ~q[13];

// CPU.NET (103) - erd1 : an2
assign erd = q[13] & readcycle;

// CPU.NET (107) - readcycle : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (q[11]) begin
			readcycle <= rw_in;
		end
	end
end

// CPU.NET (109) - lds : iv
// CPU.NET (110) - uds : iv
assign {uds,lds} = ~sizin[1:0];

// CPU.NET (111) - not68k : iv
assign not68k = ~m68k;
endmodule

