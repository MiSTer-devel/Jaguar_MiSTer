//`include "defs.v"

module _j_jbus
(
	input [23:0] ain,
	input [31:0] din,
	input [15:0] dr,
	input [1:0] dinlatch,
	input [1:0] dmuxd,
	input [1:0] dmuxu,
	input dren,
	input xdsrc,
	input ack,
	input [31:0] wd,
	input clk,
	input [1:0] cfg,
	input cfgw,
	input [23:0] a,
	input ainen,
	input seta1,
	input masterdata,
	output [31:0] dout,
	output [23:0] aout,
	output dsp16,
	output bigend,
	input sys_clk // Generated
);
wire [15:0] d5;
wire [31:0] d1;
wire [15:8] d1a;
wire [31:16] d2;
reg [31:0] d3 = 32'h0;
wire [15:0] d4;
wire [7:0] d4a;
wire [15:0] d6;
reg [23:0] ad = 24'h0;
reg dsp16_ = 1'b0;
reg bigend_ = 1'b0;
assign dsp16 = dsp16_;
assign bigend = bigend_;

reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// JBUS.NET (44) - d5[0-15] : mx2
assign d5[15:0] = (dren) ? dr[15:0] : din[15:0];

// JBUS.NET (48) - d1[0-31] : mx2
assign d1[31:0] = (xdsrc) ? din[31:0] : wd[31:0];

// JBUS.NET (52) - d1a[8-15] : mx2
assign d1a[15:8] = (dmuxu[0]) ? d1[7:0] : d1[15:8];

// JBUS.NET (53) - d2[16-23] : mx2
assign d2[23:16] = (dmuxu[1]) ? d1[7:0] : d1[23:16];

// JBUS.NET (54) - d2[24-31] : mx2
assign d2[31:24] = (dmuxu[1]) ? d1a[15:8] : d1[31:24];

// JBUS.NET (58) - d3[0-7] : stlatch
// JBUS.NET (59) - d3[8-15] : stlatch
// JBUS.NET (60) - d3[16-31] : stlatch
reg [31:0] d3data = 32'h0;
always @(posedge sys_clk)
begin
	if (dinlatch[0]) begin
		d3[7:0] <= d1[7:0];
		d3[15:8] <= d1a[15:8];
	end else begin
		d3[15:0] <= d3data[15:0];
	end
	if (dinlatch[1]) begin
		d3[31:16] <= d2[31:16];
	end else begin
		d3[31:16] <= d3data[31:16];
	end

	if (clk) begin
		if (dinlatch[0]) begin
			d3data[7:0] <= d1[7:0];
			d3data[15:8] <= d1a[15:8];
		end
		if (dinlatch[1]) begin
			d3data[31:16] <= d2[31:16];
		end
	end
end

// JBUS.NET (72) - d4[0-15] : mx2
assign d4[15:0] = (dmuxd[1]) ? d3[31:16] : d3[15:0];

// JBUS.NET (73) - d4a[0-7] : mx2
assign d4a[7:0] = (dmuxd[0]) ? d4[15:8] : d4[7:0];

// JBUS.NET (77) - d6[0-7] : mx2
assign d6[7:0] = (masterdata) ? d4a[7:0] : d5[7:0];

// JBUS.NET (78) - d6[8-15] : mx2
assign d6[15:8] = (masterdata) ? d4[15:8] : d5[15:8];

// JBUS.NET (82) - dout[0-15] : nivh
assign dout[15:0] = d6[15:0];

// JBUS.NET (83) - dout[16-31] : nivm
assign dout[31:16] = d3[31:16];

// JBUS.NET (87) - dsp16 : ldp1q
// JBUS.NET (88) - bigend : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (cfgw) begin
		dsp16_ <= cfg[0];
		bigend_ <= cfg[1];
	end
end

// JBUS.NET (94) - ad[0-23] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (ack) begin
			ad[23:0] <= a[23:0];
		end
	end
end

// JBUS.NET (96) - as[1] : or2
// JBUS.NET (98) - aout[0] : mx2
// JBUS.NET (99) - aouti[1] : mx2
// JBUS.NET (100) - aout[1] : nivu
// JBUS.NET (101) - aout[2-13] : mx2
// JBUS.NET (103) - aout[14] : nivh
// JBUS.NET (104) - aout[15-23] : mx2
assign aout[23:0] = (ainen) ? ain[23:0] : (ad[23:0] | {22'h0,seta1,1'b0});
endmodule
