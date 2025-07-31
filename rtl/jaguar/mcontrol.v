//`include "defs.v"

module _mcontrol
(
	output [23:0] blit_addr_out,
	output blit_addr_oe,	// ElectronAsh.
	output justify_out,
	output justify_oe,
	input justify_in,
	output mreq_out,
	output mreq_oe,
	input mreq_in,
	output [3:0] width_out,
	output width_oe,
	output read_out,
	output read_oe,
	input read_in,
	output active,
	output blitack,
	output memidle,
	output memready,
	output read_ack,
	output wactive,
	input ack,
	input [23:0] address,
	input bcompen,
	input blit_back,
	input clk,
	input phrase_cycle,
	input phrase_mode,
	input [2:0] pixsize,
	input [3:0] pwidth,
	input readreq,
	input reset_n,
	input sread_1,
	input sreadx_1,
	input step_inner,
	input writereq,
	input sys_clk // Generated
);
reg [23:0] blita = 24'h0;
wire busen;
wire blitack_n;
wire [3:0] ractvt;
reg ractive = 1'b0;
wire [3:0] wactvt;
wire active_n;
wire wt0t;
wire fontread;
wire [3:0] wt;
wire pwrite;
wire justt;
wire step_innerb;
wire waset_n;
wire wat0;
reg waitack = 1'b0;
wire wat1;

// Output buffers
wire active_obuf;
wire blitack_obuf;
reg wactive_obuf = 1'b0;

wire resetl = reset_n;
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign active = active_obuf;
assign blitack = blitack_obuf;
assign wactive = wactive_obuf;


// MCONTROL.NET (51) - busen : nivu
assign busen = blit_back;

// MCONTROL.NET (55) - blitack\ : nd2
assign blitack_n = ~(ack & blit_back);

// MCONTROL.NET (56) - blitack : iv
assign blitack_obuf = ~blitack_n;

// MCONTROL.NET (60) - ractvt0 : nd2
assign ractvt[0] = ~(~ractive & readreq);

// MCONTROL.NET (61) - ractvt1 : nd2
assign ractvt[1] = ~(ractive & blitack_n);

// MCONTROL.NET (62) - ractvt2 : nd3
assign ractvt[2] = ~(ractive & blitack_obuf & readreq);

// MCONTROL.NET (63) - ractvt3 : nd3
assign ractvt[3] = ~(&ractvt[2:0]);

// MCONTROL.NET (64) - ractive : fd2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			ractive <= 1'b0;
		end else begin
			ractive <= ractvt[3];
		end
	end
end

// MCONTROL.NET (66) - wactvt0 : nd2
assign wactvt[0] = ~(~wactive & writereq);

// MCONTROL.NET (67) - wactvt1 : nd2
assign wactvt[1] = ~(wactive_obuf & blitack_n);

// MCONTROL.NET (68) - wactvt2 : nd3
assign wactvt[2] = ~(wactive_obuf & blitack_obuf & writereq);

// MCONTROL.NET (69) - wactvt3 : nd3
assign wactvt[3] = ~(&wactvt[2:0]);

// MCONTROL.NET (70) - wactive : fd2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			wactive_obuf <= 1'b0;
		end else begin
			wactive_obuf <= wactvt[3];
		end
	end
end

// MCONTROL.NET (73) - active\ : nr2
assign active_n = ~(wactive_obuf | ractive);

// MCONTROL.NET (74) - active : iv
assign active_obuf = ~active_n;

// MCONTROL.NET (78) - memready : an2
assign memready = blitack_obuf & active_obuf;

// MCONTROL.NET (80) - memidle : iv
assign memidle = ~active_obuf;

// MCONTROL.NET (86) - mreq : tsm
assign mreq_out = active_obuf;
assign mreq_oe = busen;

// MCONTROL.NET (88) - read : ts
assign read_out = ractive;
assign read_oe = busen;

// MCONTROL.NET (101) - wt0t : nr2
assign wt0t = ~(~pixsize[2] | fontread);

// MCONTROL.NET (102) - wt0 : nr2
assign wt[0] = ~(wt0t | phrase_cycle);

// MCONTROL.NET (103) - wt1 : nr5
assign wt[1] = ~(~pixsize[2] | pixsize[1] | pixsize[0] | phrase_cycle | fontread);

// MCONTROL.NET (105) - wt2 : nr5
assign wt[2] = ~(~pixsize[2] | pixsize[1] | ~pixsize[0] | phrase_cycle | fontread);

// MCONTROL.NET (107) - pwrite : an2
assign pwrite = phrase_cycle & wactive_obuf;

// MCONTROL.NET (108) - wout[0-2] : mx2
// MCONTROL.NET (109) - wout[3] : mx2
// MCONTROL.NET (111) - width[0-3] : ts
assign wt[3] = phrase_cycle;
assign width_out[3:0] = (pwrite) ? pwidth[3:0] : wt[3:0];
assign width_oe = busen;

// MCONTROL.NET (118) - fontread\ : ond1
assign fontread = ( (sread_1 | sreadx_1) & bcompen );

// MCONTROL.NET (121) - justt : nd2
assign justt = ~(~fontread & phrase_mode);

// MCONTROL.NET (122) - justify : ts
assign justify_out = justt;
assign justify_oe = busen;

// MCONTROL.NET (129) - step_innerb : nivu
assign step_innerb = step_inner;

// MCONTROL.NET (130) - blita : fdsync24
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (step_innerb) begin
			blita[23:0] <= address[23:0];
		end
	end
end

// MCONTROL.NET (131) - blit_addr : tsm
assign blit_addr_out[23:0] = blita[23:0];

// ElectronAsh.
assign blit_addr_oe = busen;

// MCONTROL.NET (137) - waitackset : nd2
assign waset_n = ~(ractive & blitack_obuf);

// MCONTROL.NET (138) - wat0 : nd2
assign wat0 = ~(waitack & ~ack);

// MCONTROL.NET (139) - wat1 : nd2
assign wat1 = ~(waset_n & wat0);

// MCONTROL.NET (140) - waitack : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			waitack <= 1'b0;
		end else begin
			waitack <= wat1;
		end
	end
end

// MCONTROL.NET (141) - read_ack : an2
assign read_ack = waitack & ack;
endmodule
