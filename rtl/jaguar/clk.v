//`include "defs.v"
// altera message_off 10036

module _clk
(
	input resetl,
	
	input pclk,
	input vxclk,
	
	input ndtest,
	input cfg_7,
	
	output cfgw,
	output cfgen,
	
	output clk,		// Direct from pclk.
	output vclk,	// Direct from vxclk (xvclk).
	output tlw,		// Inverted pclk.
	
	input sys_clk // Generated
);
wire clk1;
wire clk2;
wire vclk1;
reg cfgwl = 1'b0;
reg cfgend = 1'b0;
wire nottest;
wire cfgeni;
reg external = 1'b0;
wire internal;

// Output buffers
wire cfgw_obuf;


// Output buffers
assign cfgw = cfgw_obuf;


// CLK.NET (35) - clk1 : niv
assign clk1 = pclk;

// CLK.NET (36) - clk2 : nivu
assign clk2 = clk1;

// CLK.NET (37) - clk : bniv310
assign clk = clk2;

// CLK.NET (42) - tlw : ivu
assign tlw = ~clk1;

// CLK.NET (58) - vclk1 : nivh
assign vclk1 = vxclk;

// CLK.NET (59) - vclk : bniv34
assign vclk = vclk1;

// CLK.NET (80) - cfgwl : fd1q
reg old_pclk;
always @(posedge sys_clk)
begin
	old_pclk <= pclk;
	if (~old_pclk && pclk) begin
		cfgwl <= resetl;
	end
end

// CLK.NET (81) - cfgw : iv
assign cfgw_obuf = ~cfgwl;

// CLK.NET (82) - cfgend : fd2q
reg old_resetl;
always @(posedge sys_clk)
begin
	old_resetl <= resetl;

	if ((~old_pclk && pclk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			cfgend <= 1'b0;
		end else begin
			cfgend <= cfgwl;
		end
	end
end

// CLK.NET (83) - nottest : iv
assign nottest = ~ndtest;

// CLK.NET (84) - cfgeni : nd2
assign cfgeni = ~(cfgend & nottest);

// CLK.NET (85) - cfgen : ivh
assign cfgen = ~cfgeni;

// CLK.NET (87) - external : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (cfgw_obuf) begin
		external <= cfg_7;
	end
end

// CLK.NET (88) - internal : iv
assign internal = ~external;
endmodule
