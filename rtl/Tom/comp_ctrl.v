//`include "defs.v"

module _comp_ctrl
(
	output [7:0] dbinh_n,
	output nowrite,
	input bcompen,
	input big_pix,
	input bkgwren,
	input clk,
	input [7:0] dcomp,
	input dcompen,
	input [2:0] icount,
	input [2:0] pixsize,
	input phrase_mode,
	input [7:0] srcd,
	input step_inner,
	input [3:0] zcomp,
	input sys_clk // Generated
);
wire [2:0] bcompselt;
wire bcompbit;
reg [2:0] bcompsel = 3'h0;
wire bcompbitpt;
reg bcompbitp = 1'b0;
wire [4:0] nowt;
wire winht;
wire winhibit;
wire [4:0] di0t;
wire [2:0] di1t;
wire [4:0] di2t;
wire [2:0] di3t;
wire [4:0] di4t;
wire [2:0] di5t;
wire [4:0] di6t;
wire [2:0] di7t;

//wire resetl = xreset_n;
reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// INNER.NET (748) - bcompselt[0-2] : eo
assign bcompselt[2:0] = icount[2:0] ^ {3{big_pix}};

// INNER.NET (749) - bcompbit : mx8
wire [7:0] srcdt = srcd[7:0] << bcompselt[2:0];
assign bcompbit = srcdt[7];

// INNER.NET (755) - bcompsel[0-2] : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (step_inner) begin
			bcompsel[2:0] <= bcompselt[2:0];
		end
	end
end

// INNER.NET (757) - bcompbt : mx8
// Bit shift is slow
//wire [7:0] srcdtt = srcd[7:0] << bcompsel[2:0];
reg srcdtt;
//assign bcompbitpt = srcdtt[7];
assign bcompbitpt = srcdtt;
always @(*)
begin
	case(bcompsel[2:0]) // is this fast enough? could use ternaries
		3'b000		: srcdtt = srcd[7];
		3'b001		: srcdtt = srcd[6];
		3'b010		: srcdtt = srcd[5];
		3'b011		: srcdtt = srcd[4];
		3'b100		: srcdtt = srcd[3];
		3'b101		: srcdtt = srcd[2];
		3'b110		: srcdtt = srcd[1];
		default		: srcdtt = srcd[0];
	endcase
end

// INNER.NET (760) - bcompbitp : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		bcompbitp <= bcompbitpt;
	end
end

// INNER.NET (773) - nowt0 : nd3
assign nowt[0] = ~(bcompen & ~bcompbit & ~phrase_mode);

// INNER.NET (774) - nowt1 : nd6
assign nowt[1] = ~(dcompen & dcomp[0] & ~phrase_mode & ~pixsize[2] & pixsize[0] & pixsize[1]);

// INNER.NET (776) - nowt2 : nd7
assign nowt[2] = ~(dcompen & dcomp[0] & dcomp[1] & ~phrase_mode & pixsize[2] & ~pixsize[0] & ~pixsize[1]);

// INNER.NET (778) - nowt3 : nd5
assign nowt[3] = ~(zcomp[0] & ~phrase_mode & pixsize[2] & ~pixsize[0] & ~pixsize[1]);

// INNER.NET (780) - nowt4 : nd4
assign nowt[4] = ~(&nowt[3:0]);

// INNER.NET (781) - nowrite : an2
assign nowrite = nowt[4] & ~bkgwren;

// INNER.NET (783) - winht : nd3
assign winht = ~(bcompen & ~bcompbitp & ~phrase_mode);

// INNER.NET (784) - winhibit : nd4
assign winhibit = ~(winht & &nowt[3:1]);

// INNER.NET (801) - di0t0 : nd2p
assign di0t[0] = ~(pixsize[2] & zcomp[0]);

// INNER.NET (802) - di0t1 : nd4p
assign di0t[1] = ~(pixsize[2] & &dcomp[1:0] & dcompen);

// INNER.NET (804) - di0t2 : nd2
assign di0t[2] = ~(~srcd[0] & bcompen);

// INNER.NET (805) - di0t3 : nd3
assign di0t[3] = ~(~pixsize[2] & dcomp[0] & dcompen);

// INNER.NET (806) - di0t4 : nd4
assign di0t[4] = ~(&di0t[3:0]);

// INNER.NET (807) - dbinh[0] : anr1p
assign dbinh_n[0] = ~( (di0t[4] & phrase_mode) | winhibit );

// INNER.NET (810) - di1t0 : nd3
assign di1t[0] = ~(~pixsize[2] & dcomp[1] & dcompen);

// INNER.NET (811) - di1t1 : nd2
assign di1t[1] = ~(~srcd[1] & bcompen);

// INNER.NET (812) - di1t2 : nd4
assign di1t[2] = ~(&di0t[1:0] &  &di1t[1:0]);

// INNER.NET (813) - dbinh[1] : anr1
assign dbinh_n[1] = ~( (di1t[2] & phrase_mode) | winhibit );

// INNER.NET (816) - di2t0 : nd2p
assign di2t[0] = ~(pixsize[2] & zcomp[1]);

// INNER.NET (817) - di2t1 : nd4p
assign di2t[1] = ~(pixsize[2] & dcomp[2] & dcomp[3] & dcompen);

// INNER.NET (819) - di2t2 : nd2
assign di2t[2] = ~(~srcd[2] & bcompen);

// INNER.NET (820) - di2t3 : nd3
assign di2t[3] = ~(~pixsize[2] & dcomp[2] & dcompen);

// INNER.NET (821) - di2t4 : nd4
assign di2t[4] = ~(di2t[0] & di2t[1] & di2t[2] & di2t[3]);

// INNER.NET (822) - dbinh[2] : anr1
assign dbinh_n[2] = ~( (di2t[4] & phrase_mode) | winhibit );

// INNER.NET (825) - di3t0 : nd3
assign di3t[0] = ~(~pixsize[2] & dcomp[3] & dcompen);

// INNER.NET (826) - di3t1 : nd2
assign di3t[1] = ~(~srcd[3] & bcompen);

// INNER.NET (827) - di3t2 : nd4
assign di3t[2] = ~(di2t[0] & di2t[1] & di3t[0] & di3t[1]);

// INNER.NET (828) - dbinh[3] : anr1
assign dbinh_n[3] = ~( (di3t[2] & phrase_mode) | winhibit );

// INNER.NET (831) - di4t0 : nd2p
assign di4t[0] = ~(pixsize[2] & zcomp[2]);

// INNER.NET (832) - di4t1 : nd4p
assign di4t[1] = ~(pixsize[2] & dcomp[4] & dcomp[5] & dcompen);

// INNER.NET (834) - di4t2 : nd2
assign di4t[2] = ~(~srcd[4] & bcompen);

// INNER.NET (835) - di4t3 : nd3
assign di4t[3] = ~(~pixsize[2] & dcomp[4] & dcompen);

// INNER.NET (836) - di4t4 : nd4
assign di4t[4] = ~(di4t[0] & di4t[1] & di4t[2] & di4t[3]);

// INNER.NET (837) - dbinh[4] : nd2
assign dbinh_n[4] = ~(di4t[4] & phrase_mode);

// INNER.NET (839) - di5t0 : nd3
assign di5t[0] = ~(~pixsize[2] & dcomp[5] & dcompen);

// INNER.NET (840) - di5t1 : nd2
assign di5t[1] = ~(~srcd[5] & bcompen);

// INNER.NET (841) - di5t2 : nd4
assign di5t[2] = ~(di4t[0] & di4t[1] & di5t[0] & di5t[1]);

// INNER.NET (842) - dbinh[5] : nd2
assign dbinh_n[5] = ~(di5t[2] & phrase_mode);

// INNER.NET (844) - di6t0 : nd2p
assign di6t[0] = ~(pixsize[2] & zcomp[3]);

// INNER.NET (845) - di6t1 : nd4p
assign di6t[1] = ~(pixsize[2] & &dcomp[7:6] & dcompen);

// INNER.NET (847) - di6t2 : nd2
assign di6t[2] = ~(~srcd[6] & bcompen);

// INNER.NET (848) - di6t3 : nd3
assign di6t[3] = ~(~pixsize[2] & dcomp[6] & dcompen);

// INNER.NET (849) - di6t4 : nd4
assign di6t[4] = ~(di6t[0] & di6t[1] & di6t[2] & di6t[3]);

// INNER.NET (850) - dbinh[6] : nd2
assign dbinh_n[6] = ~(di6t[4] & phrase_mode);

// INNER.NET (852) - di7t0 : nd3
assign di7t[0] = ~(~pixsize[2] & dcomp[7] & dcompen);

// INNER.NET (853) - di7t1 : nd2
assign di7t[1] = ~(~srcd[7] & bcompen);

// INNER.NET (854) - di7t2 : nd4
assign di7t[2] = ~(di6t[0] & di6t[1] & di7t[0] & di7t[1]);

// INNER.NET (855) - dbinh[7] : nd2
assign dbinh_n[7] = ~(di7t[2] & phrase_mode);
endmodule
