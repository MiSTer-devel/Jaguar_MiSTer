//`include "defs.v"
// altera message_off 10036

module _address
(
	output [31:0] gpu_dout_out,
	output gpu_dout_oe,
	output a1_outside,
	output [2:0] a1_pixsize,
	output [14:0] a1_win_x,
	output [15:0] a1_x,
	output [1:0] a1addx,
	output a1addy,
	output a1xsign,
	output a1ysign,
	output [2:0] a2_pixsize,
	output [15:0] a2_x,
	output [1:0] a2addx,
	output a2addy,
	output a2xsign,
	output a2ysign,
	output [23:0] address,
	output [2:0] pixa,
	input [2:0] addasel,
	input [1:0] addbsel,
	input addqsel,
	input [2:0] adda_xconst,
	input adda_yconst,
	input addareg,
	input a1baseld,
	input a1flagld,
	input a1fracld,
	input a1incld,
	input a1incfld,
	input a1posrd,
	input a1posfrd,
	input a1ptrld,
	input a1stepld,
	input a1stepfld,
	input a1winld,
	input a2baseld,
	input a2flagld,
	input a2posrd,
	input a2ptrld,
	input a2stepld,
	input a2winld,
	input apipe,
	input clk,
	input gena2,
	input [31:0] gpu_din,
	input load_strobe,
	input [2:0] modx,
	input suba_x,
	input suba_y,
	input zaddr,
	input sys_clk // Generated
);
wire [14:0] gpu_d_lo15;
wire [14:0] gpu_d_hi15;
reg [14:0] a1_win_y = 15'h0;
reg [15:0] a1_y = 16'h0;
reg [15:0] a1_frac_x = 16'h0;
reg [15:0] a1_frac_y = 16'h0;
reg [15:0] a1_inc_x = 16'h0;
reg [15:0] a1_inc_y = 16'h0;
reg [15:0] a1_incf_x = 16'h0;
reg [15:0] a1_incf_y = 16'h0;
wire [15:0] a2_xm;
wire [15:0] a2_ym;
reg [15:0] a2_xr = 16'h0;
reg [15:0] a2_yr = 16'h0;
wire [15:0] adda_x;
wire [15:0] adda_y;
wire [15:0] addb_x;
wire [15:0] addb_y;
wire [15:0] addq_x;
wire [15:0] addq_y;
wire [15:0] data_x;
wire [15:0] data_y;
reg [15:0] a1_xt = 16'h0;
reg [15:0] a2_mask_x = 16'h0;
reg [15:0] a2_mask_y = 16'h0;
wire [15:0] gpu_d_lo16;
wire [15:0] gpu_d_hi16;
reg [20:0] a1_flags = 21'h0;
reg [20:0] a2_flags = 21'h0;
wire [20:0] gpu_d_lo21;
reg [20:0] a1_base = 21'h0;
reg [20:0] a2_base = 21'h0;
wire [20:0] gpu_d_m21;
reg [15:0] a1_step_x = 16'h0;
reg [15:0] a1_step_y = 16'h0;
reg [15:0] a1_stepf_x = 16'h0;
reg [15:0] a1_stepf_y = 16'h0;
wire [15:0] a2_y;
reg [15:0] a2_step_x = 16'h0;
reg [15:0] a2_step_y = 16'h0;
wire a1baseldg;
wire a1flagldg;
wire [1:0] a1_pitch;
wire [1:0] a1_zoffset;
wire [5:0] a1_width;
wire a1winldg;
wire a1stepldg;
wire a1stepfldg;
wire a1incldg;
wire a1incfldg;
wire a2baseldg;
wire a2flagldg;
wire [1:0] a2_pitch;
wire [1:0] a2_zoffset;
wire [5:0] a2_width;
wire a2_mask;
wire a2winldg;
wire a2stepldg;
wire [31:0] a1_pos;
wire [31:0] a1_posf;
wire [31:0] a2_pos;
wire [31:0] grdt0;
wire [31:0] grdt1;
wire grden;

// Output buffers
wire [2:0] a1_pixsize_obuf;
reg [14:0] a1_win_x_obuf = 15'h0;
wire [2:0] a2_pixsize_obuf;

//wire resetl = reset_n;
reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end


// Output buffers
assign a1_pixsize[2:0] = a1_pixsize_obuf[2:0];
assign a1_win_x[14:0] = a1_win_x_obuf[14:0];
assign a2_pixsize[2:0] = a2_pixsize_obuf[2:0];


// ADDRESS.NET (81) - gpulo15 : join
assign gpu_d_lo15[14:0] = gpu_din[14:0];

// ADDRESS.NET (82) - gpuhi15 : join
assign gpu_d_hi15[14:0] = gpu_din[30:16];

// ADDRESS.NET (83) - gpulo16 : join
assign gpu_d_lo16[15:0] = gpu_din[15:0];

// ADDRESS.NET (84) - gpuhi16 : join
assign gpu_d_hi16[15:0] = gpu_din[31:16];

// ADDRESS.NET (85) - gpulo21 : join
assign gpu_d_lo21[20:0] = gpu_din[20:0];

// ADDRESS.NET (86) - gpuhi29 : join
assign gpu_d_m21[20:0] = gpu_din[23:3];

// ADDRESS.NET (92) - a1baseldg : an2u
assign a1baseldg = a1baseld & load_strobe;

// ADDRESS.NET (93) - a1base : ldp1q
// ADDRESS.NET (98) - a1flags : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (a1baseldg) begin
		a1_base[20:0] <= gpu_d_m21[20:0];
	end
	if (a1flagldg) begin
		a1_flags[20:0] <= gpu_d_lo21[20:0];
	end
end

// ADDRESS.NET (97) - a1flagldg : an2h
assign a1flagldg = a1flagld & load_strobe;


// ADDRESS.NET (99) - a1_pixp[0-1] : join
// ADDRESS.NET (100) - a1_pixs[0-2] : join
// ADDRESS.NET (101) - a1_zoff[0-1] : join
// ADDRESS.NET (102) - a1unused[0] : join
// ADDRESS.NET (103) - a1_wdth[0-5] : join
// ADDRESS.NET (104) - a1unused[1] : join
// ADDRESS.NET (105) - a1addx[0] : nivm
// ADDRESS.NET (106) - a1addx[1] : nivm
// ADDRESS.NET (107) - a1addy : join
// ADDRESS.NET (108) - a1xsign : join
// ADDRESS.NET (109) - a1ysign : join
assign a1_pitch[1:0] = a1_flags[1:0];
assign a1_pixsize_obuf[2:0] = a1_flags[5:3];
assign a1_zoffset[1:0] = a1_flags[7:6]; ///////////check this - v8 says should be 3 bits including a1_flags[8]
//assign unused_0 = a1_flags[8];
assign a1_width[5:0] = a1_flags[14:9];
//assign unused_1 = a1_flags[15];
assign a1addx[1:0] = a1_flags[17:16];
assign a1addy = a1_flags[18];
assign a1xsign = a1_flags[19];
assign a1ysign = a1_flags[20];

// ADDRESS.NET (113) - a1winldg : an2u
assign a1winldg = a1winld & load_strobe;

// ADDRESS.NET (114) - a1winx : ldp1q
// ADDRESS.NET (115) - a1winy : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (a1winldg) begin
		a1_win_x_obuf[14:0] <= gpu_d_lo15[14:0];
		a1_win_y[14:0] <= gpu_d_hi15[14:0];
	end
end

// ADDRESS.NET (119) - a1xt : fdsync16
// ADDRESS.NET (121) - a1y : fdsync16
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (a1ptrld) begin
			a1_xt[15:0] <= data_x[15:0];
			a1_y[15:0] <= data_y[15:0];
		end
	end
end

// ADDRESS.NET (120) - a1x : nivm
assign a1_x[15:0] = a1_xt[15:0];

// ADDRESS.NET (125) - a1stepldg : an2u
assign a1stepldg = a1stepld & load_strobe;

// ADDRESS.NET (126) - a1stepfldg : an2u
assign a1stepfldg = a1stepfld & load_strobe;

// ADDRESS.NET (127) - a1stepx : ldp1q
// ADDRESS.NET (128) - a1stepy : ldp1q
// ADDRESS.NET (129) - a1stepfx : ldp1q
// ADDRESS.NET (130) - a1stepfy : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (a1stepldg) begin
		a1_step_x[15:0] <= gpu_d_lo16[15:0];
		a1_step_y[15:0] <= gpu_d_hi16[15:0];
	end
	if (a1stepfldg) begin
		a1_stepf_x[15:0] <= gpu_d_lo16[15:0];
		a1_stepf_y[15:0] <= gpu_d_hi16[15:0];
	end
end

// ADDRESS.NET (134) - a1fracx : fdsync16
// ADDRESS.NET (135) - a1fracy : fdsync16
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (a1fracld) begin
			a1_frac_x[15:0] <= data_x[15:0];
			a1_frac_y[15:0] <= data_y[15:0];
		end
	end
end

// ADDRESS.NET (139) - a1incldg : an2u
assign a1incldg = a1incld & load_strobe;

// ADDRESS.NET (140) - a1incfldg : an2u
assign a1incfldg = a1incfld & load_strobe;

// ADDRESS.NET (141) - a1incx : ldp1q
// ADDRESS.NET (142) - a1incy : ldp1q
// ADDRESS.NET (143) - a1incfx : ldp1q
// ADDRESS.NET (144) - a1incfy : ldp1q
// ADDRESS.NET (151) - a2base : ldp1q
// ADDRESS.NET (156) - a2flags : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (a1incldg) begin
		a1_inc_x[15:0] <= gpu_d_lo16[15:0];
		a1_inc_y[15:0] <= gpu_d_hi16[15:0];
	end
	if (a1incfldg) begin
		a1_incf_x[15:0] <= gpu_d_lo16[15:0];
		a1_incf_y[15:0] <= gpu_d_hi16[15:0];
	end
	if (a2baseldg) begin
		a2_base[20:0] <= gpu_d_m21[20:0];
	end
	if (a2flagldg) begin
		a2_flags[20:0] <= gpu_d_lo21[20:0];
	end
end

// ADDRESS.NET (150) - a2baseldg : an2u
assign a2baseldg = a2baseld & load_strobe;

// ADDRESS.NET (155) - a2flagldg : an2h
assign a2flagldg = a2flagld & load_strobe;

// ADDRESS.NET (157) - a2_pixp[0-1] : join
// ADDRESS.NET (158) - a2_pixs[0-2] : join
// ADDRESS.NET (159) - a2_zoff[0-1] : join
// ADDRESS.NET (160) - a2unused[2] : join
// ADDRESS.NET (161) - a2_wdth[0-5] : join
// ADDRESS.NET (162) - a2_mask : nivu
// ADDRESS.NET (163) - a2addx[0-1] : join
// ADDRESS.NET (164) - a2addy : join
// ADDRESS.NET (165) - a2xsign : join
// ADDRESS.NET (166) - a2ysign : join
assign a2_pitch[1:0] = a2_flags[1:0];
assign a2_pixsize_obuf[2:0] = a2_flags[5:3];
assign a2_zoffset[1:0] = a2_flags[7:6];
//assign unused_2 = a2_flags[8];
assign a2_width[5:0] = a2_flags[14:9];
assign a2_mask = a2_flags[15];
assign a2addx[1:0] = a2_flags[17:16];
assign a2addy = a2_flags[18];
assign a2xsign = a2_flags[19];
assign a2ysign = a2_flags[20];

// ADDRESS.NET (171) - a2winldg : an2u
assign a2winldg = a2winld & load_strobe;

// ADDRESS.NET (172) - a2winx : ldp1q
// ADDRESS.NET (173) - a2winy : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (a2winldg) begin
		a2_mask_x[15:0] <= gpu_d_lo16[15:0];
		a2_mask_y[15:0] <= gpu_d_hi16[15:0];
	end
end

// ADDRESS.NET (177) - a2x : fdsync16
// ADDRESS.NET (178) - a2y : fdsync16
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (a2ptrld) begin
			a2_xr[15:0] <= data_x[15:0];
			a2_yr[15:0] <= data_y[15:0];
		end
	end
end

// ADDRESS.NET (182) - a2_xm : an2
assign a2_xm[15:0] = a2_xr[15:0] & a2_mask_x[15:0];

// ADDRESS.NET (183) - a2_x : mx2
assign a2_x[15:0] = (a2_mask) ? a2_xm[15:0] : a2_xr[15:0];

// ADDRESS.NET (184) - a2_ym : an2
assign a2_ym[15:0] = a2_yr[15:0] & a2_mask_y[15:0];

// ADDRESS.NET (185) - a2_y : mx2
assign a2_y[15:0] = (a2_mask) ? a2_ym[15:0] : a2_yr[15:0];

// ADDRESS.NET (189) - a2stepldg : an2u
assign a2stepldg = a2stepld & load_strobe;

// ADDRESS.NET (190) - a2stepx : ldp1q
// ADDRESS.NET (191) - a2stepy : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (a2stepldg) begin
		a2_step_x[15:0] <= gpu_d_lo16[15:0];
		a2_step_y[15:0] <= gpu_d_hi16[15:0];
	end
end

// ADDRESS.NET (195) - addamux : addamux
_addamux addamux_inst
(
	.adda_x /* OUT */ (adda_x[15:0]),
	.adda_y /* OUT */ (adda_y[15:0]),
	.addasel /* IN */ (addasel[2:0]),
	.a1_step_x /* IN */ (a1_step_x[15:0]),
	.a1_step_y /* IN */ (a1_step_y[15:0]),
	.a1_stepf_x /* IN */ (a1_stepf_x[15:0]),
	.a1_stepf_y /* IN */ (a1_stepf_y[15:0]),
	.a2_step_x /* IN */ (a2_step_x[15:0]),
	.a2_step_y /* IN */ (a2_step_y[15:0]),
	.a1_inc_x /* IN */ (a1_inc_x[15:0]),
	.a1_inc_y /* IN */ (a1_inc_y[15:0]),
	.a1_incf_x /* IN */ (a1_incf_x[15:0]),
	.a1_incf_y /* IN */ (a1_incf_y[15:0]),
	.adda_xconst /* IN */ (adda_xconst[2:0]),
	.adda_yconst /* IN */ (adda_yconst),
	.addareg /* IN */ (addareg),
	.suba_x /* IN */ (suba_x),
	.suba_y /* IN */ (suba_y)
);

// ADDRESS.NET (202) - addbmux : addbmux
assign addb_x[15:0] = addbsel[1] ? (addbsel[0] ? a1_x[15:0] : a1_frac_x[15:0]) : (addbsel[0] ? a2_x[15:0] : a1_x[15:0]);
assign addb_y[15:0] = addbsel[1] ? (addbsel[0] ? a1_y[15:0] : a1_frac_y[15:0]) : (addbsel[0] ? a2_y[15:0] : a1_y[15:0]);

// ADDRESS.NET (205) - addradd : addradd
_addradd addradd_inst
(
	.addq_x /* OUT */ (addq_x[15:0]),
	.addq_y /* OUT */ (addq_y[15:0]),
	.a1fracld /* IN */ (a1fracld),
	.adda_x /* IN */ (adda_x[15:0]),
	.adda_y /* IN */ (adda_y[15:0]),
	.addb_x /* IN */ (addb_x[15:0]),
	.addb_y /* IN */ (addb_y[15:0]),
	.clk /* IN */ (clk),
	.modx /* IN */ (modx[2:0]),
	.suba_x /* IN */ (suba_x),
	.suba_y /* IN */ (suba_y),
	.sys_clk(sys_clk) // Generated
);

// ADDRESS.NET (211) - datamux : datamux
assign data_x[15:0] = addqsel ? addq_x[15:0] : gpu_din[15:0];
assign data_y[15:0] = addqsel ? addq_y[15:0] : gpu_din[31:16];

// ADDRESS.NET (216) - addrgen : addrgen
_addrgen addrgen_inst
(
	.address /* OUT */ (address[23:0]),
	.pixa /* OUT */ (pixa[2:0]),
	.a1_x /* IN */ (a1_x[15:0]),
	.a1_y /* IN */ (a1_y[15:0]),
	.a1_base /* IN */ (a1_base[20:0]),
	.a1_pitch /* IN */ (a1_pitch[1:0]),
	.a1_pixsize /* IN */ (a1_pixsize_obuf[2:0]),
	.a1_width /* IN */ (a1_width[5:0]),
	.a1_zoffset /* IN */ (a1_zoffset[1:0]),
	.a2_x /* IN */ (a2_x[15:0]),
	.a2_y /* IN */ (a2_y[15:0]),
	.a2_base /* IN */ (a2_base[20:0]),
	.a2_pitch /* IN */ (a2_pitch[1:0]),
	.a2_pixsize /* IN */ (a2_pixsize_obuf[2:0]),
	.a2_width /* IN */ (a2_width[5:0]),
	.a2_zoffset /* IN */ (a2_zoffset[1:0]),
	.apipe /* IN */ (apipe),
	.clk /* IN */ (clk),
	.gena2 /* IN */ (gena2),
	.zaddr /* IN */ (zaddr),
	.sys_clk(sys_clk) // Generated
);

// ADDRESS.NET (226) - addrcomp : addrcomp
_addrcomp addrcomp_inst
(
	.a1_outside /* OUT */ (a1_outside),
	.a1_x /* IN */ (a1_x[15:0]),
	.a1_y /* IN */ (a1_y[15:0]),
	.a1_win_x /* IN */ (a1_win_x_obuf[14:0]),
	.a1_win_y /* IN */ (a1_win_y[14:0])
);

// ADDRESS.NET (231) - a1_pos[0-15] : join
assign a1_pos[15:0] = a1_x[15:0];

// ADDRESS.NET (232) - a1_pos[16-31] : join
assign a1_pos[31:16] = a1_y[15:0];

// ADDRESS.NET (233) - a1_posf[0-15] : join
assign a1_posf[15:0] = a1_frac_x[15:0];

// ADDRESS.NET (234) - a1_posf[16-31] : join
assign a1_posf[31:16] = a1_frac_y[15:0];

// ADDRESS.NET (235) - a2_pos[0-15] : join
assign a2_pos[15:0] = a2_x[15:0];

// ADDRESS.NET (236) - a2_pos[16-31] : join
assign a2_pos[31:16] = a2_y[15:0];

// ADDRESS.NET (238) - grdt0[0-31] : mx2
assign grdt0[31:0] = (a1posfrd) ? a1_posf[31:0] : a1_pos[31:0];

// ADDRESS.NET (240) - grdt1[0-31] : mx2
assign grdt1[31:0] = (a2posrd) ? a2_pos[31:0] : grdt0[31:0];

// ADDRESS.NET (242) - grden : or3u
assign grden = a1posrd | a1posfrd | a2posrd;

// ADDRESS.NET (243) - grd[0-31] : ts
assign gpu_dout_out[31:0] = grdt1[31:0];
assign gpu_dout_oe = grden;

endmodule

