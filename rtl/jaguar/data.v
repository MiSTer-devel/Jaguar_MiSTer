//`include "defs.v"

module _data
(
	output [63:0] wdata_out,
	output wdata_oe,
	output [7:0] dcomp,
	output [7:0] srcd,
	output [3:0] zcomp,
	input big_pix,
	input blit_back,
	input [1:0] blit_breq,
	input clk,
	input clk2,
	input cmpdst,
	input [2:0] daddasel,
	input [2:0] daddbsel,
	input [2:0] daddmode,
	input daddq_sel,
	input [63:0] data,
	input data_ena,
	input [1:0] data_sel,
	input [7:0] dbinh_n,
	input [5:0] dend,
	input [1:0] dpipe,
	input [5:0] dstart,
	input [1:0] dstdld,
	input [1:0] dstzld,
	input [31:0] gpu_din,
	input iincld,
	input [3:0] intld,
	input [3:0] lfu_func,
	input load_strobe,
	input [1:0] patdld,
	input phrase_mode,
	input reset_n,
	input [1:0] srcd1ld,
	input srcdread,
	input srczread,
	input [5:0] srcshift,
	input [1:0] srcz1ld,
	input srcz2add,
	input [1:0] srcz2ld,
	input [3:0] zedld,
	input zincld,
	input [2:0] zmode,
	input [1:0] zpipe,
	input sys_clk // Generated
);
wire [15:0] addb_0;
wire [15:0] addb_1;
wire [15:0] addb_2;
wire [15:0] addb_3;
wire [15:0] gpu_dinlo;
wire [15:0] gpu_dinhi;
wire [15:0] local_data0lo;
wire [15:0] local_data0hi;
wire [15:0] local_data1lo;
wire [15:0] local_data1hi;
reg [15:0] sz1_0 = 16'h0;
reg [15:0] sz1_1 = 16'h0;
reg [15:0] sz1_2 = 16'h0;
reg [15:0] sz1_3 = 16'h0;
wire [15:0] srcz1i_0;
wire [15:0] srcz1i_1;
wire [15:0] srcz1i_2;
wire [15:0] srcz1i_3;
reg [15:0] sz2_0 = 16'h0;
reg [15:0] sz2_1 = 16'h0;
reg [15:0] sz2_2 = 16'h0;
reg [15:0] sz2_3 = 16'h0;
wire [15:0] srcz2i_0;
wire [15:0] srcz2i_1;
wire [15:0] srcz2i_2;
wire [15:0] srcz2i_3;
wire [15:0] srcd1i_0;
wire [15:0] srcd1i_1;
wire [15:0] srcd1i_2;
wire [15:0] srcd1i_3;
reg [15:0] sd1_0 = 16'h0;
reg [15:0] sd1_1 = 16'h0;
reg [15:0] sd1_2 = 16'h0;
reg [15:0] sd1_3 = 16'h0;
reg [31:0] dstd_0 = 32'h0;
reg [31:0] dstd_1 = 32'h0;
reg [31:0] dstz_0 = 32'h0;
reg [31:0] dstz_1 = 32'h0;
reg [31:0] iinc = 32'h0;
wire [31:0] lfu_0;
wire [31:0] lfu_1;
wire [31:0] local_data_0;
wire [31:0] local_data_1;
wire [31:0] local_data0;
wire [31:0] local_data1;
reg [31:0] patd_0 = 32'h0;
reg [31:0] patd_1 = 32'h0;
wire [31:0] patdu_0;
wire [31:0] patdu_1;
reg [31:0] patdo_0 = 32'h0;
reg [31:0] patdo_1 = 32'h0;
wire [31:0] srcd1_0;
wire [31:0] srcd1_1;
reg [31:0] srcd2_0 = 32'h0;
reg [31:0] srcd2_1 = 32'h0;
wire [31:0] srcz1_0;
wire [31:0] srcz1_1;
wire [31:0] srcz2_0;
wire [31:0] srcz2_1;
reg [31:0] srczo_0 = 32'h0;
reg [31:0] srczo_1 = 32'h0;
wire [31:0] srczp_0;
wire [31:0] srczp_1;
reg [31:0] srczpt_0 = 32'h0;
reg [31:0] srczpt_1 = 32'h0;
wire [31:0] srcdlo;
wire [31:0] srcdhi;
reg [31:0] zinc = 32'h0;
wire [31:0] load_data_0;
wire [31:0] load_data_1;
wire [31:0] srcz_0;
wire [31:0] srcz_1;
wire [15:0] adda_0;
wire [15:0] adda_1;
wire [15:0] adda_2;
wire [15:0] adda_3;
wire [15:0] addq_0;
wire [15:0] addq_1;
wire [15:0] addq_2;
wire [15:0] addq_3;
wire [3:0] intldb;
wire srcd2ldg;
wire [3:0] zedldb;
wire [1:0] sz20sel;
wire [1:0] sz21sel;
wire [1:0] sz22sel;
wire [1:0] sz23sel;
wire [1:0] dstdldg;
wire [1:0] dstzldg;
wire [63:0] patdi;
reg [63:0] pdu = 64'h0;
wire dpipeg;
wire dpipe1b;
wire zincldg;
wire iincldg;

//wire resetl = reset_n;
reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// DATA.NET (76) - gpu_datalo : join
assign gpu_dinlo[15:0] = gpu_din[15:0];

// DATA.NET (77) - gpu_datahi : join
assign gpu_dinhi[15:0] = gpu_din[31:16];

// DATA.NET (90) - intldb[0-3] : nivu
assign intldb[3:0] = intld[3:0];

// DATA.NET (91) - srcd1i[0] : mx4
assign srcd1i_0[15:0] = intldb[0] ? (srcd1ld[0] ? 16'h0 : gpu_dinlo[15:0]) : (srcd1ld[0] ? local_data0lo[15:0] : sd1_0[15:0]);

// DATA.NET (93) - srcd1i[1] : mx4
assign srcd1i_1[15:0] = intldb[1] ? (srcd1ld[0] ? 16'h0 : gpu_dinlo[15:0]) : (srcd1ld[0] ? local_data0hi[15:0] : sd1_1[15:0]);

// DATA.NET (95) - srcd1i[2] : mx4
assign srcd1i_2[15:0] = intldb[2] ? (srcd1ld[1] ? 16'h0 : gpu_dinlo[15:0]) : (srcd1ld[1] ? local_data1lo[15:0] : sd1_2[15:0]);

// DATA.NET (97) - srcd1i[3] : mx4
assign srcd1i_3[15:0] = intldb[3] ? (srcd1ld[1] ? 16'h0 : gpu_dinlo[15:0]) : (srcd1ld[1] ? local_data1hi[15:0] : sd1_3[15:0]);

// DATA.NET (99) - sd1[0-3] : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		sd1_0[15:0] <= srcd1i_0[15:0];
		sd1_1[15:0] <= srcd1i_1[15:0];
		sd1_2[15:0] <= srcd1i_2[15:0];
		sd1_3[15:0] <= srcd1i_3[15:0];
	end
end

// DATA.NET (100) - srcd1[0] : join
assign srcd1_0[15:0] = sd1_0[15:0];
assign srcd1_0[31:16] = sd1_1[15:0];

// DATA.NET (101) - srcd1[1] : join
assign srcd1_1[15:0] = sd1_2[15:0];
assign srcd1_1[31:16] = sd1_3[15:0];

// DATA.NET (103) - srcd2ldg[0-1] : an2u
assign srcd2ldg = srcdread & load_strobe;

// DATA.NET (104) - srcd2[0-1] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (srcd2ldg) begin
		srcd2_0[31:0] <= srcd1_0[31:0];
		srcd2_1[31:0] <= srcd1_1[31:0];
	end
end

// DATA.NET (108) - src_shift : srcshift
_srcshift src_shift_inst
(
	.srcd_0 /* OUT */ (srcdlo[31:0]),
	.srcd_1 /* OUT */ (srcdhi[31:0]),
	.big_pix /* IN */ (big_pix),
	.srcd1lo /* IN */ (srcd1_0[31:0]),
	.srcd1hi /* IN */ (srcd1_1[31:0]),
	.srcd2lo /* IN */ (srcd2_0[31:0]),
	.srcd2hi /* IN */ (srcd2_1[31:0]),
	.srcshift /* IN */ (srcshift[5:0])
);

// DATA.NET (111) - srcd[0-7] : niv
assign srcd[7:0] = srcdlo[7:0];

// DATA.NET (121) - zedldb[0-3] : nivh
assign zedldb[3:0] = zedld[3:0];

// DATA.NET (122) - srcz1i[0] : mx4
// DATA.NET (124) - srcz1i[1] : mx4
// DATA.NET (126) - srcz1i[2] : mx4
// DATA.NET (128) - srcz1i[3] : mx4
assign srcz1i_0[15:0] = zedldb[0] ? (srcz1ld[0] ? 16'h0 : gpu_dinhi[15:0]) : (srcz1ld[0] ? local_data0lo[15:0] : sz1_0[15:0]);
assign srcz1i_1[15:0] = zedldb[1] ? (srcz1ld[0] ? 16'h0 : gpu_dinhi[15:0]) : (srcz1ld[0] ? local_data0hi[15:0] : sz1_1[15:0]);
assign srcz1i_2[15:0] = zedldb[2] ? (srcz1ld[1] ? 16'h0 : gpu_dinhi[15:0]) : (srcz1ld[1] ? local_data1lo[15:0] : sz1_2[15:0]);
assign srcz1i_3[15:0] = zedldb[3] ? (srcz1ld[1] ? 16'h0 : gpu_dinhi[15:0]) : (srcz1ld[1] ? local_data1hi[15:0] : sz1_3[15:0]);

// DATA.NET (131) - sz1[0-3] : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		sz1_0[15:0] <= srcz1i_0[15:0];
		sz1_1[15:0] <= srcz1i_1[15:0];
		sz1_2[15:0] <= srcz1i_2[15:0];
		sz1_3[15:0] <= srcz1i_3[15:0];
	end
end

// DATA.NET (132) - srcz1[0] : join
assign srcz1_0[15:0] = sz1_0[15:0];
assign srcz1_0[31:16] = sz1_1[15:0];

// DATA.NET (133) - srcz1[1] : join
assign srcz1_1[15:0] = sz1_2[15:0];
assign srcz1_1[31:16] = sz1_3[15:0];

// DATA.NET (142) - sz20sel0 : or2_h
assign sz20sel[0] = srczread | zedldb[0];

// DATA.NET (143) - sz20sel1 : or3_h
assign sz20sel[1] = srcz2ld[0] | srcz2add | zedldb[0];

// DATA.NET (145) - srcz2i[0] : mx4
assign srcz2i_0[15:0] = sz20sel[1] ? (sz20sel[0] ? gpu_dinlo[15:0] : local_data0lo[15:0]) : (sz20sel[0] ? sz1_0[15:0] : sz2_0[15:0]);

// DATA.NET (147) - sz21sel0 : or2_h
assign sz21sel[0] = srczread | zedldb[1];

// DATA.NET (148) - sz21sel1 : or3_h
assign sz21sel[1] = srcz2ld[0] | srcz2add | zedldb[1];

// DATA.NET (150) - srcz2i[1] : mx4
assign srcz2i_1[15:0] = sz21sel[1] ? (sz21sel[0] ? gpu_dinlo[15:0] : local_data0hi[15:0]) : (sz21sel[0] ? sz1_1[15:0] : sz2_1[15:0]);

// DATA.NET (152) - sz22sel0 : or2_h
assign sz22sel[0] = srczread | zedldb[2];

// DATA.NET (153) - sz22sel1 : or3_h
assign sz22sel[1] = srcz2ld[1] | srcz2add | zedldb[2];

// DATA.NET (155) - srcz2i[2] : mx4
assign srcz2i_2[15:0] = sz22sel[1] ? (sz22sel[0] ? gpu_dinlo[15:0] : local_data1lo[15:0]) : (sz22sel[0] ? sz1_2[15:0] : sz2_2[15:0]);

// DATA.NET (157) - sz23sel0 : or2_h
assign sz23sel[0] = srczread | zedldb[3];

// DATA.NET (158) - sz23sel1 : or3_h
assign sz23sel[1] = srcz2ld[1] | srcz2add | zedldb[3];

// DATA.NET (160) - srcz2i[3] : mx4
assign srcz2i_3[15:0] = sz23sel[1] ? (sz23sel[0] ? gpu_dinlo[15:0] : local_data1hi[15:0]) : (sz23sel[0] ? sz1_3[15:0] : sz2_3[15:0]);

// DATA.NET (163) - sz2[0-3] : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		sz2_0[15:0] <= srcz2i_0[15:0];
		sz2_1[15:0] <= srcz2i_1[15:0];
		sz2_2[15:0] <= srcz2i_2[15:0];
		sz2_3[15:0] <= srcz2i_3[15:0];
	end
end

// DATA.NET (164) - srcz2[0] : join
assign srcz2_0[15:0] = sz2_0[15:0];
assign srcz2_0[31:16] = sz2_1[15:0];

// DATA.NET (165) - srcz2[1] : join
assign srcz2_1[15:0] = sz2_2[15:0];
assign srcz2_1[31:16] = sz2_3[15:0];

// DATA.NET (170) - dstdldg[0-1] : an2u
assign dstdldg[0] = dstdld[0] & load_strobe;
assign dstdldg[1] = dstdld[1] & load_strobe;

// DATA.NET (171) - dstd[0-1] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (dstdldg[0]) begin
		dstd_0[31:0] <= load_data_0[31:0];
	end
	if (dstdldg[1]) begin
		dstd_1[31:0] <= load_data_1[31:0];
	end
end

// DATA.NET (176) - dstzldg[0-1] : an2u
assign dstzldg[1:0] = load_strobe ? dstzld[1:0] : 2'h0;

// DATA.NET (177) - dstz[0-1] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (dstzldg[0]) begin
		dstz_0[31:0] <= load_data_0[31:0];
	end
	if (dstzldg[1]) begin
		dstz_1[31:0] <= load_data_1[31:0];
	end
end

// DATA.NET (188) - patdi[0-7] : mx4
assign patdi[7:0] = intldb[0] ? (patdld[0] ? 8'h0 : gpu_din[23:16]) : (patdld[0] ? local_data0[7:0] : pdu[7:0]);

// DATA.NET (191) - patdi[8-15] : mx2
assign patdi[15:8] = (patdld[0]) ? local_data0[15:8] : pdu[15:8];

// DATA.NET (193) - patdi[16-23] : mx4
assign patdi[23:16] = intldb[1] ? (patdld[0] ? 8'h0 : gpu_din[23:16]) : (patdld[0] ? local_data0[23:16] : pdu[23:16]);

// DATA.NET (196) - patdi[24-31] : mx2
assign patdi[31:24] = (patdld[0]) ? local_data0[31:24] : pdu[31:24];

// DATA.NET (198) - patdi[32-39] : mx4
assign patdi[39:32] = intldb[2] ? (patdld[1] ? 8'h0 : gpu_din[23:16]) : (patdld[1] ? local_data1[7:0] : pdu[39:32]);

// DATA.NET (201) - patdi[40-47] : mx2
assign patdi[47:40] = (patdld[1]) ? local_data1[15:8] : pdu[47:40];

// DATA.NET (203) - patdi[48-55] : mx4
assign patdi[55:48] = intldb[3] ? (patdld[1] ? 8'h0 : gpu_din[23:16]) : (patdld[1] ? local_data1[23:16] : pdu[55:48]);

// DATA.NET (206) - patdi[56-63] : mx2
assign patdi[63:56] = (patdld[1]) ? local_data1[31:24] : pdu[63:56];

// DATA.NET (208) - pdu[0-63] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		pdu[63:0] <= patdi[63:0];
	end
end

// DATA.NET (209) - patdu[0] : join
assign patdu_0[31:0] = pdu[31:0];

// DATA.NET (210) - patdu[1] : join
assign patdu_1[31:0] = pdu[63:32];

// DATA.NET (211) - dpipeg[0-1] : an2u
assign dpipeg = dpipe[0] & clk2;

// DATA.NET (212) - patd[0-1] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (dpipeg) begin
		patd_0[31:0] <= patdu_0[31:0];
		patd_1[31:0] <= patdu_1[31:0];
	end
end

// DATA.NET (219) - dpipe1b[0-1] : nivu
assign dpipe1b = dpipe[1];

// DATA.NET (220) - patdo[0-1] : fdsync32
// always @(posedge cp)
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (dpipe1b) begin
			patdo_0[31:0] <= patd_0[31:0];
			patdo_1[31:0] <= patd_1[31:0];
		end
	end
end

// DATA.NET (225) - lfu : lfu
assign lfu_0[31:0] = ({32{lfu_func[3]}} & srcdlo[31:0] & dstd_0[31:0])
                   | ({32{lfu_func[2]}} & srcdlo[31:0] & ~dstd_0[31:0])
                   | ({32{lfu_func[1]}} & ~srcdlo[31:0] & dstd_0[31:0])
                   | ({32{lfu_func[0]}} & ~srcdlo[31:0] & ~dstd_0[31:0]);
assign lfu_1[31:0] = ({32{lfu_func[3]}} & srcdhi[31:0] & dstd_1[31:0])
                   | ({32{lfu_func[2]}} & srcdhi[31:0] & ~dstd_1[31:0])
                   | ({32{lfu_func[1]}} & ~srcdhi[31:0] & dstd_1[31:0])
                   | ({32{lfu_func[0]}} & ~srcdhi[31:0] & ~dstd_1[31:0]);

// DATA.NET (230) - zincldg : an2u
assign zincldg = zincld & load_strobe;

// DATA.NET (231) - zinc : ldp1q
// DATA.NET (236) - iinc : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (zincldg) begin
		zinc[31:0] <= gpu_din[31:0];
	end
	if (iincldg) begin
		iinc[31:0] <= gpu_din[31:0];
	end
end

// DATA.NET (235) - iincldg : an2u
assign iincldg = iincld & load_strobe;

// DATA.NET (240) - datacomp : datacomp
assign dcomp[0] = (patd_0[7:0] == (cmpdst ? dstd_0[7:0] : srcdlo[7:0]));
assign dcomp[1] = (patd_0[15:8] == (cmpdst ? dstd_0[15:8] : srcdlo[15:8]));
assign dcomp[2] = (patd_0[23:16] == (cmpdst ? dstd_0[23:16] : srcdlo[23:16]));
assign dcomp[3] = (patd_0[31:24] == (cmpdst ? dstd_0[31:24] : srcdlo[31:24]));
assign dcomp[4] = (patd_1[7:0] == (cmpdst ? dstd_1[7:0] : srcdhi[7:0]));
assign dcomp[5] = (patd_1[15:8] == (cmpdst ? dstd_1[15:8] : srcdhi[15:8]));
assign dcomp[6] = (patd_1[23:16] == (cmpdst ? dstd_1[23:16] : srcdhi[23:16]));
assign dcomp[7] = (patd_1[31:24] == (cmpdst ? dstd_1[31:24] : srcdhi[31:24]));

// DATA.NET (245) - zedshift : zedshift
assign srcz_0[31:0] = srcshift[5] ? (srcshift[4] ? {srcz2_0[15:0],srcz1_1[31:16]} : srcz1_1[31:0]) 
                                  : (srcshift[4] ? {srcz1_1[15:0],srcz1_0[31:16]} : srcz1_0[31:0]);
assign srcz_1[31:0] = srcshift[5] ? (srcshift[4] ? {srcz2_1[15:0],srcz2_0[31:16]} : srcz2_0[31:0])
                                  : (srcshift[4] ? {srcz2_0[15:0],srcz1_1[31:16]} : srcz1_1[31:0]);

// DATA.NET (253) - srczp[0] : mx2p
assign srczp_0[31:0] = (zpipe[0]) ? srcz_0[31:0] : srczpt_0[31:0];

// DATA.NET (254) - srczp[1] : mx2p
assign srczp_1[31:0] = (zpipe[0]) ? srcz_1[31:0] : srczpt_1[31:0];

// DATA.NET (255) - srczpt[0-1] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		srczpt_0[31:0] <= srczp_0[31:0];
		srczpt_1[31:0] <= srczp_1[31:0];
	end
end

// DATA.NET (259) - zedcomp : zedcomp
_zedcomp zedcomp_inst
(
	.zcomp /* OUT */ (zcomp[3:0]),
	.srczplo /* IN */ (srczp_0[31:0]),
	.srczphi /* IN */ (srczp_1[31:0]),
	.dstzlo /* IN */ (dstz_0[31:0]),
	.dstzhi /* IN */ (dstz_1[31:0]),
	.zmode /* IN */ (zmode[2:0])
);

// DATA.NET (268) - srczo[0-1] : fdsync32
// always @(posedge cp)
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (zpipe[1]) begin
			srczo_0[31:0] <= srczp_0[31:0];
			srczo_1[31:0] <= srczp_1[31:0];
		end
	end
end

// DATA.NET (273) - addamux : daddamux
_daddamux addamux_inst
(
	.adda_0 /* OUT */ (adda_0[15:0]),
	.adda_1 /* OUT */ (adda_1[15:0]),
	.adda_2 /* OUT */ (adda_2[15:0]),
	.adda_3 /* OUT */ (adda_3[15:0]),
	.dstd_0 /* IN */ (dstd_0[31:0]),
	.dstd_1 /* IN */ (dstd_1[31:0]),
	.srcd_0 /* IN */ (srcdlo[31:0]),
	.srcd_1 /* IN */ (srcdhi[31:0]),
	.patd_0 /* IN */ (patdu_0[31:0]),
	.patd_1 /* IN */ (patdu_1[31:0]),
	.srcz1_0 /* IN */ (srcz1_0[31:0]),
	.srcz1_1 /* IN */ (srcz1_1[31:0]),
	.srcz2_0 /* IN */ (srcz2_0[31:0]),
	.srcz2_1 /* IN */ (srcz2_1[31:0]),
	.daddasel /* IN */ (daddasel[2:0])
);

// DATA.NET (279) - addbmux : daddbmux
_daddbmux addbmux_inst
(
	.addb_0 /* OUT */ (addb_0[15:0]),
	.addb_1 /* OUT */ (addb_1[15:0]),
	.addb_2 /* OUT */ (addb_2[15:0]),
	.addb_3 /* OUT */ (addb_3[15:0]),
	.srcdlo /* IN */ (srcdlo[31:0]),
	.srcdhi /* IN */ (srcdhi[31:0]),
	.iinc /* IN */ (iinc[31:0]),
	.zinc /* IN */ (zinc[31:0]),
	.daddbsel /* IN */ (daddbsel[2:0])
);

// DATA.NET (284) - addarray : addarray
_addarray addarray_inst
(
	.addq_0 /* OUT */ (addq_0[15:0]),
	.addq_1 /* OUT */ (addq_1[15:0]),
	.addq_2 /* OUT */ (addq_2[15:0]),
	.addq_3 /* OUT */ (addq_3[15:0]),
	.adda_0 /* IN */ (adda_0[15:0]),
	.adda_1 /* IN */ (adda_1[15:0]),
	.adda_2 /* IN */ (adda_2[15:0]),
	.adda_3 /* IN */ (adda_3[15:0]),
	.addb_0 /* IN */ (addb_0[15:0]),
	.addb_1 /* IN */ (addb_1[15:0]),
	.addb_2 /* IN */ (addb_2[15:0]),
	.addb_3 /* IN */ (addb_3[15:0]),
	.daddmode /* IN */ (daddmode[2:0]),
	.clk_0 /* IN */ (clk),
	.reset_n /* IN */ (reset_n),
	.sys_clk(sys_clk) // Generated
);

// DATA.NET (289) - data_local : local_mux
assign load_data_0[31:0] = (blit_back | (|blit_breq[1:0])) ? data[31:0] : gpu_din[31:0];
assign load_data_1[31:0] = (blit_back | (|blit_breq[1:0])) ? data[63:32] : gpu_din[31:0];
assign local_data_0[31:0] = (daddq_sel) ? {addq_1[15:0],addq_0[15:0]} : load_data_0[31:0];
assign local_data_1[31:0] = (daddq_sel) ? {addq_3[15:0],addq_2[15:0]} : load_data_1[31:0];

// DATA.NET (292) - local_data0 : join
assign local_data0[31:0] = local_data_0[31:0];

// DATA.NET (293) - local_data1 : join
assign local_data1[31:0] = local_data_1[31:0];

// DATA.NET (294) - local_data0lo : join
assign local_data0lo[15:0] = local_data0[15:0];

// DATA.NET (295) - local_data0hi : join
assign local_data0hi[15:0] = local_data0[31:16];

// DATA.NET (296) - local_data1lo : join
assign local_data1lo[15:0] = local_data1[15:0];

// DATA.NET (297) - local_data1hi : join
assign local_data1hi[15:0] = local_data1[31:16];

// DATA.NET (301) - data_out : data_mux
_data_mux data_out_inst
(
	.wdata_out /* BUS */ (wdata_out[63:0]),
	.wdata_oe /* BUS */ (wdata_oe),
	.addq_0 /* IN */ (addq_0[15:0]),
	.addq_1 /* IN */ (addq_1[15:0]),
	.addq_2 /* IN */ (addq_2[15:0]),
	.addq_3 /* IN */ (addq_3[15:0]),
	.big_pix /* IN */ (big_pix),
	.dstdlo /* IN */ (dstd_0[31:0]),
	.dstdhi /* IN */ (dstd_1[31:0]),
	.dstzlo /* IN */ (dstz_0[31:0]),
	.dstzhi /* IN */ (dstz_1[31:0]),
	.data_sel /* IN */ (data_sel[1:0]),
	.data_ena /* IN */ (data_ena),
	.dstart /* IN */ (dstart[5:0]),
	.dend /* IN */ (dend[5:0]),
	.dbinh_n /* IN */ (dbinh_n[7:0]),
	.lfu_0 /* IN */ (lfu_0[31:0]),
	.lfu_1 /* IN */ (lfu_1[31:0]),
	.patd_0 /* IN */ (patdo_0[31:0]),
	.patd_1 /* IN */ (patdo_1[31:0]),
	.phrase_mode /* IN */ (phrase_mode),
	.srczlo /* IN */ (srczo_0[31:0]),
	.srczhi /* IN */ (srczo_1[31:0])
);
endmodule
