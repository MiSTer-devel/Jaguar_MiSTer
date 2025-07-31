//`include "defs.v"

module _data_mux
(
	output [63:0] wdata_out,
	output wdata_oe,
	input [15:0] addq_0,
	input [15:0] addq_1,
	input [15:0] addq_2,
	input [15:0] addq_3,
	input big_pix,
	input [31:0] dstdlo,
	input [31:0] dstdhi,
	input [31:0] dstzlo,
	input [31:0] dstzhi,
	input [1:0] data_sel,
	input data_ena,
	input [5:0] dstart,
	input [5:0] dend,
	input [7:0] dbinh_n,
	input [31:0] lfu_0,
	input [31:0] lfu_1,
	input [31:0] patd_0,
	input [31:0] patd_1,
	input phrase_mode,
	input [31:0] srczlo,
	input [31:0] srczhi
);
wire [31:0] addql_0;
wire [31:0] addql_1;
wire [31:0] ddatlo;
wire [31:0] ddathi;
wire phrase_mode_n;
wire edis_n;
reg [7:0] e_coarse_n;
reg [7:0] e_fine_n;
reg [7:0] s_coarse;
wire sfen_n;
reg [7:0] s_fine;
wire [14:0] maskt;
wire masktla;
wire mir_bit;
wire mir_byte;
wire [14:0] masku;
wire [14:0] mask;
wire dsel0b;
wire dsel1b;
wire zed_sel;
wire [63:0] dat;

// DATAMUX.NET (192) - phrase_mode\ : iv
assign phrase_mode_n = ~phrase_mode;

// DATAMUX.NET (202) - edis : or6
assign edis_n = |dend[5:0];

// DATAMUX.NET (203) - ecoarse : decl38e
// Bit shift is slow
//assign e_coarse_n[7:0] = edis_n ? ~(8'h01 << dend[5:3]) : 8'hFF;
always @(*)
begin
	case({edis_n,dend[5:3]}) // is this fast enough? could use ternaries
		4'b1000		: e_coarse_n[7:0] = 8'hFE;
		4'b1001		: e_coarse_n[7:0] = 8'hFD;
		4'b1010		: e_coarse_n[7:0] = 8'hFB;
		4'b1011		: e_coarse_n[7:0] = 8'hF7;
		4'b1100		: e_coarse_n[7:0] = 8'hEF;
		4'b1101		: e_coarse_n[7:0] = 8'hDF;
		4'b1110		: e_coarse_n[7:0] = 8'hBF;
		4'b1111		: e_coarse_n[7:0] = 8'h7F;
		default		: e_coarse_n[7:0] = 8'hFF;
	endcase
end

// DATAMUX.NET (205) - efine : decl38e
// Bit shift is slow
//assign e_fine_n[7:0] = (~e_coarse_n[0] ? ~(8'h01 << dend[2:0]) : 8'hFF);
always @(*)
begin
	case({edis_n,dend[5:0]}) // is this fast enough? could use ternaries
		7'b1000000		: e_fine_n[7:0] = 8'hFE;
		7'b1000001		: e_fine_n[7:0] = 8'hFD;
		7'b1000010		: e_fine_n[7:0] = 8'hFB;
		7'b1000011		: e_fine_n[7:0] = 8'hF7;
		7'b1000100		: e_fine_n[7:0] = 8'hEF;
		7'b1000101		: e_fine_n[7:0] = 8'hDF;
		7'b1000110		: e_fine_n[7:0] = 8'hBF;
		7'b1000111		: e_fine_n[7:0] = 8'h7F;
		default			: e_fine_n[7:0] = 8'hFF;
	endcase
end

// DATAMUX.NET (208) - scoarse : dech38
// Bit shift is slow
//assign s_coarse[7:0] = 8'h01 << dstart[5:3];
always @(*)
begin
	case(dstart[5:3]) // is this fast enough? could use ternaries
		3'b000		: s_coarse[7:0] = 8'h01;
		3'b001		: s_coarse[7:0] = 8'h02;
		3'b010		: s_coarse[7:0] = 8'h04;
		3'b011		: s_coarse[7:0] = 8'h08;
		3'b100		: s_coarse[7:0] = 8'h10;
		3'b101		: s_coarse[7:0] = 8'h20;
		3'b110		: s_coarse[7:0] = 8'h40;
		3'b111		: s_coarse[7:0] = 8'h80;
	endcase
end

// DATAMUX.NET (209) - sfen\ : iv
assign sfen_n = ~s_coarse[0];

// DATAMUX.NET (210) - sfine : dech38el
// Bit shift is slow
//assign s_fine[7:0] = ~sfen_n ? (8'h01 << dstart[2:0]) : 8'h00;
always @(*)
begin
	case(dstart[5:0]) // is this fast enough? could use ternaries
		6'b000000		: s_fine[7:0] = 8'h01;
		6'b000001		: s_fine[7:0] = 8'h02;
		6'b000010		: s_fine[7:0] = 8'h04;
		6'b000011		: s_fine[7:0] = 8'h08;
		6'b000100		: s_fine[7:0] = 8'h10;
		6'b000101		: s_fine[7:0] = 8'h20;
		6'b000110		: s_fine[7:0] = 8'h40;
		6'b000111		: s_fine[7:0] = 8'h80;
		default			: s_fine[7:0] = 8'h00;
	endcase
end

// DATAMUX.NET (212) - maskt[0] : niv
assign maskt[0] = s_fine[0];

// DATAMUX.NET (213) - maskt[1-7] : oan1p
assign maskt[7:1] = (maskt[6:0] | s_fine[7:1]) & e_fine_n[7:1];

// DATAMUX.NET (218) - masktla : an2
assign masktla = s_coarse[0] & e_coarse_n[0];

// DATAMUX.NET (219) - maskt[8] : oan1p
// DATAMUX.NET (221) - maskt[9-14] : oan1p
assign maskt[14:8] = ({maskt[13:8],masktla} | s_coarse[7:1]) & e_coarse_n[7:1];

// DATAMUX.NET (228) - mirror_bit : an2m
assign mir_bit = phrase_mode_n & big_pix;

// DATAMUX.NET (229) - mirror_byte : an2h
assign mir_byte = phrase_mode & big_pix;

// DATAMUX.NET (232) - masku[0] : mx4
// DATAMUX.NET (234) - masku[1] : mx4
// DATAMUX.NET (236) - masku[2] : mx4
// DATAMUX.NET (238) - masku[3] : mx4
// DATAMUX.NET (240) - masku[4] : mx4
// DATAMUX.NET (242) - masku[5] : mx4
// DATAMUX.NET (244) - masku[6] : mx4
// DATAMUX.NET (246) - masku[7] : mx4
wire [7:0] imaskt0 = {maskt[0],maskt[1],maskt[2],maskt[3],maskt[4],maskt[5],maskt[6],maskt[7]};
assign masku[7:0] = mir_byte ? (mir_bit ? 8'h0 : {8{maskt[14]}}) : (mir_bit ? imaskt0[7:0] : maskt[7:0]);

// DATAMUX.NET (248) - masku[8] : mx2
// DATAMUX.NET (249) - masku[9] : mx2
// DATAMUX.NET (250) - masku[10] : mx2
// DATAMUX.NET (251) - masku[11] : mx2
// DATAMUX.NET (252) - masku[12] : mx2
// DATAMUX.NET (253) - masku[13] : mx2
// DATAMUX.NET (254) - masku[14] : mx2
wire [13:8] imaskt8 = {maskt[8],maskt[9],maskt[10],maskt[11],maskt[12],maskt[13]};
assign masku[14:8] = mir_byte ? {maskt[0],imaskt8[13:8]} : maskt[14:8];

// DATAMUX.NET (259) - mask[0-7] : an2
assign mask[7:0] = dbinh_n[0] ? masku[7:0] : 8'h00;

// DATAMUX.NET (260) - mask[8-14] : an2h
assign mask[14:8] = dbinh_n[7:1] & masku[14:8];

// DATAMUX.NET (262) - addql[0] : join
assign addql_0[15:0] = addq_0[15:0];
assign addql_0[31:16] = addq_1[15:0];

// DATAMUX.NET (263) - addql[1] : join
assign addql_1[15:0] = addq_2[15:0];
assign addql_1[31:16] = addq_3[15:0];

// DATAMUX.NET (265) - dsel0b[0-1] : nivu
assign dsel0b = data_sel[0];

// DATAMUX.NET (266) - dsel1b[0-1] : nivu
assign dsel1b = data_sel[1];

// DATAMUX.NET (267) - ddatlo : mx4
assign ddatlo[31:0] = dsel1b ? (dsel0b ? 32'h0 : addql_0[31:0]) : (dsel0b ? lfu_0[31:0] : patd_0[31:0]);

// DATAMUX.NET (269) - ddathi : mx4
assign ddathi[31:0] = dsel1b ? (dsel0b ? 32'h0 : addql_1[31:0]) : (dsel0b ? lfu_1[31:0] : patd_1[31:0]);

// DATAMUX.NET (272) - zed_sel : an2
assign zed_sel = &data_sel[1:0];

// DATAMUX.NET (275) - dat[0-7] : mx4
assign dat[7:0] = zed_sel ? ((mask[7:0] & srczlo[7:0]) | (~mask[7:0] & dstzlo[7:0])) : ((mask[7:0] & ddatlo[7:0]) | (~mask[7:0] & dstdlo[7:0]));

// DATAMUX.NET (278) - dat[8-15] : mx4
assign dat[15:8] = zed_sel ? (mask[8] ? srczlo[15:8] : dstzlo[15:8]) : (mask[8] ? ddatlo[15:8] : dstdlo[15:8]);

// DATAMUX.NET (281) - dat[16-23] : mx4
assign dat[23:16] = zed_sel ? (mask[9] ? srczlo[23:16] : dstzlo[23:16]) : (mask[9] ? ddatlo[23:16] : dstdlo[23:16]);

// DATAMUX.NET (284) - dat[24-31] : mx4
assign dat[31:24] = zed_sel ? (mask[10] ? srczlo[31:24] : dstzlo[31:24]) : (mask[10] ? ddatlo[31:24] : dstdlo[31:24]);

// DATAMUX.NET (287) - dat[32-39] : mx4
assign dat[39:32] = zed_sel ? (mask[11] ? srczhi[7:0] : dstzhi[7:0]) : (mask[11] ? ddathi[7:0] : dstdhi[7:0]);

// DATAMUX.NET (290) - dat[40-47] : mx4
assign dat[47:40] = zed_sel ? (mask[12] ? srczhi[15:8] : dstzhi[15:8]) : (mask[12] ? ddathi[15:8] : dstdhi[15:8]);

// DATAMUX.NET (293) - dat[48-55] : mx4
assign dat[55:48] = zed_sel ? (mask[13] ? srczhi[23:16] : dstzhi[23:16]) : (mask[13] ? ddathi[23:16] : dstdhi[23:16]);

// DATAMUX.NET (296) - dat[56-63] : mx4
assign dat[63:56] = zed_sel ? (mask[14] ? srczhi[31:24] : dstzhi[31:24]) : (mask[14] ? ddathi[31:24] : dstdhi[31:24]);

// DATAMUX.NET (301) - datadrv[0-31] : ts
// DATAMUX.NET (302) - datadrv[32-63] : ts
assign wdata_out[63:0] = dat[63:0];
assign wdata_oe = data_ena;

endmodule

