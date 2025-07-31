//`include "defs.v"
// altera message_off 10036

module _inner_cnt
(
	output [31:16] gpu_dout_out,
	output gpu_dout_31_16_oe, //= statrd; already handled above
	output [2:0] icount,
	output inner0,
	input clk,
	input countld,
	input [15:0] dstxp,
	input [31:0] gpu_din,
	input icntena,
	input ireload,
	input phrase_mode,
	input [2:0] pixsize,
	input statrd,
	input sys_clk // Generated
);
wire [15:0] cntval;
reg [15:0] cntvall = 16'h0;
wire [15:0] gpu_d_lo16;
reg [15:0] icount_ = 16'h0;
wire [2:0] pixsize_n_0;
wire pixel8_n;
wire pixel8;
wire pixel16_n;
wire pixel16;
wire pixel32_n;
wire pixel32;
wire countldb;
wire [2:0] inct;
wire incc_1;
wire inc0t;
wire [3:0] inc_n;
wire [4:1] inc1t;
wire [2:0] inc2t;
wire [15:0] count;
wire [14:3] carry;
wire cla10;
reg cntlden = 1'b0;
wire cntisel_1;
wire [15:0] cnti;
wire uflowt;
reg underflow = 1'b0;
wire inner0t;

//wire resetl = reset_n;
reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// Output buffers
assign icount[2:0] = icount_[2:0];

// INNER.NET (578) - pixel8\ : nd3
assign pixel8 = (pixsize[2:0] == 3'b011);

// INNER.NET (580) - pixel16\ : nd3
assign pixel16 = (pixsize[2:0] == 3'b100);

// INNER.NET (582) - pixel32\ : nd3
assign pixel32 = (pixsize[2:0] == 3'b101);

// INNER.NET (586) - gpu_d_lo16 : join
assign gpu_d_lo16[15:0] = gpu_din[15:0];

// INNER.NET (591) - cntval : mx2
assign cntval[15:0] = (countld) ? gpu_d_lo16[15:0] : cntvall[15:0];

// INNER.NET (592) - cntvall : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		cntvall[15:0] <= cntval[15:0];
	end
end

// INNER.NET (606) - inct0 : iv
assign inct[0] = dstxp[0];

// INNER.NET (607) - inct1 : ha1
assign inct[1] = dstxp[0] ^ dstxp[1];
assign incc_1 = ~dstxp[0] & ~dstxp[1];

// INNER.NET (608) - inct2 : eo
assign inct[2] = ~dstxp[2] ^ incc_1;

// INNER.NET (613) - inc0t : nd2
assign inc0t = ~(phrase_mode & inct[0]);

// INNER.NET (614) - inc\[0] : an2
assign inc_n[0] = inc0t & phrase_mode;

// INNER.NET (619) - inc1t1 : nd2
assign inc1t[1] = ~(~pixel8 & ~pixel16);

// INNER.NET (620) - inc1t2 : nd2
assign inc1t[2] = ~(inc1t[1] & inct[1]);

// INNER.NET (621) - inc1t3 : nd2
assign inc1t[3] = ~(pixel32 & ~inct[0]);

// INNER.NET (622) - inc1t4 : nd2
assign inc1t[4] = ~(inc1t[2] & inc1t[3]);

// INNER.NET (623) - inc\[1] : nd2
assign inc_n[1] = ~(phrase_mode & inc1t[4]);

// INNER.NET (628) - inc2t0 : nd2
assign inc2t[0] = ~(pixel8 & inct[2]);

// INNER.NET (629) - inc2t1 : nd3
assign inc2t[1] = ~(pixel16 & ~inct[0] & ~inct[1]);

// INNER.NET (630) - inc2t2 : nd2
assign inc2t[2] = ~(&inc2t[1:0]);

// INNER.NET (631) - inc\[2] : nd2
assign inc_n[2] = ~(phrase_mode & inc2t[2]);

// INNER.NET (635) - inc\[3] : nd5
assign inc_n[3] = ~(phrase_mode & pixel8 & ~inct[0] & ~inct[1] & ~inct[2]);

// INNER.NET (637) - count0t4 : add4
// INNER.NET (639) - count[4-9] : hs1
// INNER.NET (641) - count[10] : en
// INNER.NET (642) - cla10 : or8
// INNER.NET (643) - count[11] : hs1
// INNER.NET (646) - count[15] : en
assign count[15:0] = icount_[15:0] - {12'h0,~inc_n[3:0]};

// INNER.NET (651) - cntlden : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		cntlden <= countld;
	end
end

// INNER.NET (652) - cntisel[1] : or2u
assign cntisel_1 = ireload | cntlden;

// INNER.NET (653) - cnti[0-15] : mx4
assign cnti[15:0] = cntisel_1 ? cntval[15:0] : (icntena ? count[15:0] : icount_[15:0]);

// INNER.NET (657) - icountt[0] : fd1q
// INNER.NET (659) - icount[1-15] : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		icount_[15:0] <= cnti[15:0];
	end
end

// INNER.NET (669) - uflowt : an2
assign uflowt = count[15] & ~icount_[15];

// INNER.NET (670) - uflow : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (icntena) begin
			underflow <= uflowt;
		end
	end
end

// INNER.NET (672) - inner0t : nr16
assign inner0t = ~(|icount_[15:0]);

// INNER.NET (673) - inner0 : or2p
assign inner0 = inner0t | underflow;

// INNER.NET (677) - stat[16-31] : ts
assign gpu_dout_out[31:16] = icount_[15:0];
assign gpu_dout_31_16_oe = statrd;
endmodule
