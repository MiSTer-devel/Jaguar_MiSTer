//`include "defs.v"
// altera message_off 10036

module _addrgen
(
	output [23:0] address,
	output [2:0] pixa,
	input [15:0] a1_x,
	input [15:0] a1_y,
	input [20:0] a1_base,
	input [1:0] a1_pitch,
	input [2:0] a1_pixsize,
	input [5:0] a1_width,
	input [1:0] a1_zoffset,
	input [15:0] a2_x,
	input [15:0] a2_y,
	input [20:0] a2_base,
	input [1:0] a2_pitch,
	input [2:0] a2_pixsize,
	input [5:0] a2_width,
	input [1:0] a2_zoffset,
	input apipe,
	input clk,
	input gena2,
	input zaddr,
	input sys_clk // Generated
);
wire [15:0] pa_b;
wire [23:0] pa_a;
wire [24:0] pa;
wire [20:0] base;
wire [26:0] pixadr;
wire [23:0] addrgen;
reg [23:0] addressi = 24'h0;
wire [15:0] x;
wire [11:0] y;
wire [5:0] width;
wire [2:0] pixsize;
wire [1:0] pitch;
wire [1:0] zoffset;
wire [11:0] ym1;
wire [11:0] ym2;
wire [14:0] ytm;
wire [23:0] ya;
wire [22:15] pacy;
wire [26:0] pixa_;
wire [1:0] pt;
wire [20:0] phradr;
wire shupen;
wire [19:0] shup;
wire [1:0] za;
wire [20:0] addr;

// Output buffers
wire [23:0] address_obuf;

//wire resetl = reset_n;
reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// Output buffers
assign address[23:0] = address_obuf[23:0];
assign pixa[2:0] = pixa_[2:0];

// ADDRGEN.NET (75) - x[0-15] : mx2
assign x[15:0] = (gena2) ? a2_x[15:0] : a1_x[15:0];

// ADDRGEN.NET (78) - y[0-11] : mx2
assign y[11:0] = (gena2) ? a2_y[11:0] : a1_y[11:0];

// ADDRGEN.NET (81) - width[0-5] : mx2u
assign width[5:0] = (gena2) ? a2_width[5:0] : a1_width[5:0];

// ADDRGEN.NET (85) - pixsize[0-2] : mx2u
assign pixsize[2:0] = (gena2) ? a2_pixsize[2:0] : a1_pixsize[2:0];

// ADDRGEN.NET (89) - pitch[0-1] : mx2p
assign pitch[1:0] = (gena2) ? a2_pitch[1:0] : a1_pitch[1:0];

// ADDRGEN.NET (93) - base : mx2p
assign base[20:0] = (gena2) ? a2_base[20:0] : a1_base[20:0];

// ADDRGEN.NET (95) - zoffset[0-1] : mx2
assign zoffset[1:0] = (gena2) ? a2_zoffset[1:0] : a1_zoffset[1:0];

// ADDRGEN.NET (107) - ym1[0-11] : an2p
assign ym1[11:0] = width[1] ? y[11:0] : 12'h0;

// ADDRGEN.NET (108) - ym2[0-11] : an2p
assign ym2[11:0] = width[0] ? y[11:0] : 12'h0;

// ADDRGEN.NET (110) - yadd : fa332
// ADDRGEN.NET (135) - ytm[0-14] : nivh
assign ytm[14:0] = ym2[11:0] + {ym1[11:0],1'b0} + {1'b0,y[11:0],2'b00};

// ADDRGEN.NET (142) - yaddr[0] : mx4g
// ADDRGEN.NET (144) - yaddr[1] : mx4g
wire [34:0] ya_;
assign ya_[34:0] = {11'h000,ytm[14:2],ytm[1:0],9'h0} << width[5:2];
assign ya[23:0] = (&width[5:4]) ? 24'h0 : ya_[34:11];

// ADDRGEN.NET (227) - pa_a : join
assign pa_a[23:0] = ya[23:0];

// ADDRGEN.NET (229) - pa_b : join
assign pa_b[15:0] = x[15:0];

// ADDRGEN.NET (234) - palow : fas16_s
assign pa[24:0] = {1'b0,ya[23:0]} + x[15:0];

// ADDRGEN.NET (260) - pixa0 : mx6
wire [2:0] pixsizet = (&pixsize[2:1]) ? (pixsize[2:0] & 3'b101) : pixsize[2:0]; //[7:6] are the same as [5:4]
wire [31:0] pixat = {2'b00,pa[24:0],5'b00000} << pixsizet[2:0];
assign pixa_[26:0] = pixat[31:5];

// ADDRGEN.NET (275) - pixadr : join
assign pixadr[26:0] = pixa_[26:0];

// ADDRGEN.NET (286) - pt0 : an2u
assign pt[0] = pitch[0] & !pitch[1];

// ADDRGEN.NET (287) - pt1 : an2u
assign pt[1] = pitch[1] & !pitch[0];
 
// ADDRGEN.NET (289) - phradr[0] : mx4p
wire [23:0] phradrt = {pixa_[26:6],3'b000} << pt[1:0];
assign phradr[20:0] = (&pt[1:0]) ? 21'h0 : phradrt[23:3]; // Technically (&pt[1:0) is impossible

// ADDRGEN.NET (300) - shupen : an2u
assign shupen = &pitch[1:0];

// ADDRGEN.NET (301) - shup[0-19] : an2
assign shup[19:0] = shupen ? pixa_[25:6] : 20'h0;

// ADDRGEN.NET (309) - za[0-1] : an2
assign za[1:0] = zaddr ? zoffset[1:0] : 2'h0;

// ADDRGEN.NET (311) - addr[0] : fa1
// ADDRGEN.NET (313) - addr1t : fa1
// ADDRGEN.NET (315) - addr[1] : fa1
// ADDRGEN.NET (317) - addr2t : fa1
// ADDRGEN.NET (319) - addr[2] : fa1
// ADDRGEN.NET (321) - addr3t28 : fa332
assign addr[20:0] = {shup[19:0],1'b0} + base[20:0] + phradr[20:0] + za[1:0];

// ADDRGEN.NET (356) - addrgen : join
assign addrgen[2:0] = pixa_[5:3];
assign addrgen[23:3] = addr[20:0];

// ADDRGEN.NET (361) - addressi : mx2p
assign address_obuf[23:0] = (apipe) ? addrgen[23:0] : addressi[23:0];

// ADDRGEN.NET (362) - address : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		addressi[23:0] <= address_obuf[23:0];
	end
end

endmodule
