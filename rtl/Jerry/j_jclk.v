//`include "defs.v"
// altera message_off 10036

module _j_jclk
(
	input resetli,
	input pclkosc,
	input pclkin,
	input vclkin,
	input chrin,
	input clk1w,
	input clk2w,
	input clk3w,
	input test,
	input [3:2] cfg,
	input [9:0] din,
	input din_15,
	input ndtest,
	output cfgw,
	output cfgen,
	output clk,
	output pclkout,
	output pclkdiv,
	output vclkdiv,
	output cpuclk,
	output chrdiv,
	output vclken,
	output resetl,
	output tlw,
	input sys_clk // Generated
);
reg pclk2 = 1'b0;
wire tresl;
reg divide = 1'b0;
reg cpuclk_ = 1'b0;
wire pclk;
wire clk1;
wire clk2;
reg cfgwl = 1'b0;
reg cfgend = 1'b0;
wire cfgeni;
wire notndtest;
reg external = 1'b0;
wire internal;
reg [5:0] chrdd = 6'h3F; // ~chrddl
reg [5:0] cd = 6'h0;
reg chrq = 1'b0;
reg extra = 1'b0;
reg [9:0] cld = 10'h0;
reg [9:0] cldd = 10'h001; // ~cldd[0]
wire clkdiv;
reg [9:0] vd = 10'h0;
reg [9:0] vdd = 10'h0;
wire vclkdivi;
wire tres;

// Output buffers
wire cfgw_obuf;
wire pclkout_obuf;
reg pclkdiv_ = 1'b0;
reg vclkdiv_ = 1'b0;
reg vclken_ = 1'b0;


// Output buffers
assign cfgw = cfgw_obuf;
assign pclkout = pclkout_obuf;
assign resetl = resetli;
assign cpuclk = cpuclk_;
assign pclkdiv = pclkdiv_;
assign vclkdiv = vclkdiv_;
assign vclken = vclken_;

reg old_clk;
reg old_resetl;
reg old_tresl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
	old_tresl <= tresl;
end

// JCLK.NET (32) - pclk2 : fd2
reg old_pclkosc;
always @(posedge sys_clk)
begin
	old_pclkosc <= pclkosc;
	if ((~old_pclkosc && pclkosc) | (old_tresl && ~tresl)) begin
		if (~tresl) begin
			pclk2 <= 1'b0;
		end else begin
			pclk2 <= ~pclk2;
		end
	end
end

// JCLK.NET (33) - pclkout : mx2
assign pclkout_obuf = (divide) ? pclk2 : pclkosc;

// JCLK.NET (37) - cclk : fd2
reg old_pclkout_obuf;
always @(posedge sys_clk)
begin
	old_pclkout_obuf <= pclkout_obuf;
	if ((~old_pclkout_obuf && pclkout_obuf) | (old_tresl && ~tresl)) begin
		if (~tresl) begin
			cpuclk_ <= 1'b0;
		end else begin
			cpuclk_ <= ~cpuclk;
		end
	end
end

// JCLK.NET (41) - pclk : nivh
assign pclk = pclkin;

// JCLK.NET (59) - clk1 : niv
assign clk1 = pclk;

// JCLK.NET (60) - clk2 : nivu
assign clk2 = clk1;

// JCLK.NET (61) - clk : bniv310
assign clk = clk2;

// JCLK.NET (66) - tlw : ivu
assign tlw = ~clk1;

// JCLK.NET (87) - cfgwl : fd1q
always @(posedge sys_clk)
begin
	if (~old_pclkosc && pclkosc) begin
		cfgwl <= resetl;
	end
end

// JCLK.NET (88) - cfgw : iv
assign cfgw_obuf = ~cfgwl;

// JCLK.NET (89) - cfgend : fd2q
always @(posedge sys_clk)
begin
	if ((~old_pclkosc && pclkosc) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			cfgend <= 1'b0;
		end else begin
			cfgend <= cfgwl;
		end
	end
end

// JCLK.NET (90) - cfgeni : nd2
assign cfgeni = ~(cfgend & notndtest);

// JCLK.NET (91) - cfgen : ivh
assign cfgen = ~cfgeni;

// JCLK.NET (93) - notndtest : iv
assign notndtest = ~ndtest;

// JCLK.NET (100) - divide : ldp1q
// JCLK.NET (102) - external : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (cfgw_obuf) begin
		divide <= cfg[2];
		external <= cfg[3];
	end
end

// JCLK.NET (103) - internal : iv
assign internal = ~external;

// JCLK.NET (111) - chrddl[0-5] : ldp2q
// JCLK.NET (112) - chrdd[0-5] : iv
// JCLK.NET (113) - vclken : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		chrdd[5:0] <= 6'h3F; // ~chrddl
		vclken_ <= 1'b0;
	end else if (clk3w) begin
		chrdd[5:0] <= din[5:0];
		vclken_ <= din_15;
	end
end

// JCLK.NET (114) - cd[0] : dncnt
// JCLK.NET (115) - cd[1-5] : dncnt
// JCLK.NET (123) - gt : agtb
// JCLK.NET (124) - chrq : fd2q
// JCLK.NET (129) - odd : an2
// JCLK.NET (130) - extra : fd2q
// JCLK.NET (131) - chrinl : iv
reg old_chrin;
always @(posedge sys_clk)
begin
	old_chrin <= chrin;

	if ((~old_chrin && chrin) | (old_tresl && ~tresl)) begin
		if (~tresl) begin
			cd[5:0] <= 6'h0;
			chrq <= 1'b0;
		end else begin
			cd[5:0] <= (cd[5:0]==6'h0) ? chrdd[5:0] : (cd[5:0] - 1'b1); //cdco[5] = cd[5:0]==0 and ci[0]==1 (vcc)
			chrq <= cd[5:0] > {1'b0,chrdd[5:1]}; // gt
		end
	end
	if ((old_chrin && ~chrin) | (old_tresl && ~tresl)) begin // chrinl = negedge
		if (~tresl) begin
			extra <= 1'b0;
		end else begin
			extra <= ~chrdd[0] & chrq; // odd
		end
	end
end

// JCLK.NET (133) - chrdiv : or2
assign chrdiv = chrq | extra;

// JCLK.NET (138) - cld[0] : dncnt
// JCLK.NET (139) - cld[1-9] : dncnt
always @(posedge sys_clk)
begin
	if ((~old_pclkosc && pclkosc) | (old_tresl && ~tresl)) begin
		if (~tresl) begin
			cld[9:0] <= 10'h0;
		end else begin
			cld[9:0] <= (clkdiv) ? cldd[9:0] : (cld[9:0] - 1'b1); //cdco[5] = cd[5:0]==0 and ci[0]==1 (vcc)
		end
	end
end

// JCLK.NET (141) - clkdiv : nivm
assign clkdiv = cld[9:0] == 10'h0; // vi is vcc so co is cld[]==0

// JCLK.NET (142) - pclkdiv : fd1q
always @(posedge sys_clk)
begin
	if (~old_pclkosc && pclkosc) begin
		pclkdiv_ <= clkdiv;
	end
end

// JCLK.NET (147) - clddl[0] : ldp2q
// JCLK.NET (148) - cldd[0] : iv
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		cldd[9:0] <= 10'h01; // ~cldd[0]
	end else if (clk1w) begin
		cldd[9:0] <= din[9:0];
	end
end

// JCLK.NET (153) - vd[0] : dncnt
// JCLK.NET (154) - vd[1-9] : dncnt
reg old_vclkin;
always @(posedge sys_clk)
begin
	old_vclkin <= vclkin;
	if ((~old_vclkin && vclkin) | (old_tresl && ~tresl)) begin
		if (~tresl) begin
			vd[9:0] <= 10'h0;
		end else begin
			vd[9:0] <= (vclkdivi) ? vdd[9:0] : (vd[9:0] - 1'b1); //cdco[5] = cd[5:0]==0 and ci[0]==1 (vcc)
		end
	end
end

// JCLK.NET (156) - vclkdivi : nivm
assign vclkdivi = vd[9:0] == 10'h0; // vi is vcc so co is vd[]==0

// JCLK.NET (157) - vclkdiv : fd1q
always @(posedge sys_clk)
begin
	if (~old_vclkin && vclkin) begin
		if (~resetl) begin
			vclkdiv_ <= 1'b0;
		end else begin
			vclkdiv_ <= vclkdivi;
		end
	end
end

// JCLK.NET (159) - vdd[0-9] : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		vdd[9:0] <= 10'h0;
	end else if (clk2w) begin
		vdd[9:0] <= din[9:0];
	end
end

// JCLK.NET (161) - testl : iv
// JCLK.NET (162) - tres : nr2
assign tres = ~(resetli | ~test);

// JCLK.NET (163) - tresl : ivu
assign tresl = ~tres;
endmodule
