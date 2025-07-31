//`include "defs.v"

module _registers
(
	output [31:0] srcd,
	output [31:0] srcdp,
	output [31:0] srcdpa,
	output [31:0] dstd,
	output [31:0] dstdp,
	input clk,
	input [5:0] dsta,
	input dstrwen_n,
	input [31:0] dstwd,
	input exe,
	input locden,
	input [31:0] locsrc,
	input [31:0] mem_data,
	input mtx_dover,
	input [5:0] srca,
	input srcrwen_n,
	input [31:0] srcwd,
	input sys_clk // Generated
);
wire [31:0] dstdr;
wire [31:0] srcdr;
reg [31:0] dstdpt0 = 32'h0;
wire [31:0] dstdpt1;
wire addreq;
wire dwtosr_n;
wire swtodr;
wire [1:0] srcdsel;
wire [1:0] dstdsel;
wire stba;
wire stbb;
wire stbc;
wire stbd;
wire stbe;
wire stb;
reg mtx_doverp = 1'b0;

// Output buffers
wire [31:0] srcd_obuf;
reg [31:0] srcdpa_obuf = 32'h0;
wire [31:0] dstd_obuf;

//wire resetl = reset_n; 
reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end


// Output buffers
assign srcd[31:0] = srcd_obuf[31:0];
assign srcdpa[31:0] = srcdpa_obuf[31:0];
assign dstd[31:0] = dstd_obuf[31:0];

// REGIS-WA.NET (53) - addreq : cmp6
assign addreq = srca[5:0] == dsta[5:0];

// REGIS-WA.NET (54) - dwtosr : nd3
assign dwtosr_n = ~(addreq & ~dstrwen_n & srcrwen_n);

// REGIS-WA.NET (55) - swtodr : an3
assign swtodr = addreq & dstrwen_n & ~srcrwen_n;

// REGIS-WA.NET (57) - srcdsel[0] : nd2u
assign srcdsel[0] = ~(srcrwen_n & ~locden);

// REGIS-WA.NET (58) - srcdsel[1] : nd2u
assign srcdsel[1] = ~(dwtosr_n & ~locden);

// REGIS-WA.NET (60) - dstdsel[0] : nivu
assign dstdsel[0] = ~dstrwen_n;

// REGIS-WA.NET (61) - dstdsel[1] : nivu
assign dstdsel[1] = swtodr;

// REGIS-WA.NET (86) - stba : dly8
// REGIS-WA.NET (87) - stbb : dly8
// REGIS-WA.NET (88) - stbc : dly8
// REGIS-WA.NET (89) - stbd : dly8
// REGIS-WA.NET (90) - stbe : dly8
// REGIS-WA.NET (91) - stb : dly8
/*reg r_z = 1'b0;
always @(posedge sys_clk)
begin
	stba <= clk;
	stbb <= stba;
	stbc <= stbb;
	stbd <= stbc;
	stbe <= stbd;
	stb <= stbe;
end*/
assign stba = clk;
assign stbb = stba;
assign stbc = stbb;
assign stbd = stbc;
assign stbe = stbd;
assign stb = stbe;

// REGIS-WA.NET (93) - reg_ram : rd64x32
_rd64x32 reg_ram_inst
(
	.qa /* OUT */ (srcdr[31:0]),
	.qb /* OUT */ (dstdr[31:0]),
	.nwea /* IN */ (srcrwen_n),
	.clka /* IN */ (stb),
	.aa /* IN */ (srca[5:0]),
	.da /* IN */ (srcwd[31:0]),
	.nweb /* IN */ (dstrwen_n),
	.clkb /* IN */ (stb),
	.ab /* IN */ (dsta[5:0]),
	.db /* IN */ (dstwd[31:0]),
	.sys_clk(sys_clk) // Generated
);

// REGIS-WA.NET (124) - srcd : mx4p
assign srcd_obuf[31:0] = srcdsel[1] ? (srcdsel[0] ? locsrc[31:0] : dstwd[31:0]) : (srcdsel[0] ? srcwd[31:0] : srcdr[31:0]);

// REGIS-WA.NET (126) - srcdpt : fdsync32
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (exe) begin
			srcdpa_obuf[31:0] <= srcd_obuf[31:0];
		end
	end
end

// REGIS-WA.NET (127) - srcdp : nivh
assign srcdp[31:0] = srcdpa_obuf[31:0];

// REGIS-WA.NET (129) - dstd : mx4p
assign dstd_obuf[31:0] = dstdsel[1] ? (dstdsel[0] ? 32'h0 : srcwd[31:0]) : (dstdsel[0] ? dstwd[31:0] : dstdr[31:0]);

// REGIS-WA.NET (131) - dstdpt : fd1q
// REGIS-WA.NET (132) - mtx_doverp : fd1qu
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		dstdpt0[31:0] <= dstd_obuf[31:0];
		mtx_doverp <= mtx_dover;
	end
end

// REGIS-WA.NET (133) - dstdpt1 : mx2p
assign dstdpt1[31:0] = (mtx_doverp) ? mem_data[31:0] : dstdpt0[31:0];

// REGIS-WA.NET (134) - dstdp : nivh
assign dstdp[31:0] = dstdpt1[31:0];
endmodule
