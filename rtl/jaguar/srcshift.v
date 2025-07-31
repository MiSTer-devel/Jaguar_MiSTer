//`include "defs.v"

module _srcshift
(
	output [31:0] srcd_0,
	output [31:0] srcd_1,
	input big_pix,
	input [31:0] srcd1lo,
	input [31:0] srcd1hi,
	input [31:0] srcd2lo,
	input [31:0] srcd2hi,
	input [5:0] srcshift
);
wire [127:0] shsrc;
reg [6:0] besh;
wire [6:0] shift;
//wire [127:8] onep;
//wire [127:40] onel;
//wire [127:56] onew;
reg [127:64] oneb;
wire [71:64] onen;
wire [71:64] onet;
wire [71:64] oneo;

// SRCSHIFT.NET (32) - unshsrc[0-31] : join
assign shsrc[31:0] = srcd2lo[31:0];

// SRCSHIFT.NET (33) - unshsrc[32-63] : join
assign shsrc[63:32] = srcd2hi[31:0];

// SRCSHIFT.NET (34) - unshsrc[64-95] : join
assign shsrc[95:64] = srcd1lo[31:0];

// SRCSHIFT.NET (35) - unshsrc[96-127] : join
assign shsrc[127:96] = srcd1hi[31:0];

// SRCSHIFT.NET (41) - besh[1] : ha1
// SRCSHIFT.NET (43) - besh[2] : eo
//assign besh [2:0] = -srcshift[2:0];//-srcshift for big endian
always @(*)
begin
	case(srcshift[2:0])
		3'b000		: besh[2:0] = 3'h0;
		3'b001		: besh[2:0] = 3'h7;
		3'b010		: besh[2:0] = 3'h6;
		3'b011		: besh[2:0] = 3'h5;
		3'b100		: besh[2:0] = 3'h4;
		3'b101		: besh[2:0] = 3'h3;
		3'b110		: besh[2:0] = 3'h2;
		default		: besh[2:0] = 3'h1;
	endcase
end

// SRCSHIFT.NET (48) - besh[4] : ha1
// SRCSHIFT.NET (50) - besh[5] : ha1
// SRCSHIFT.NET (51) - besh[6] : iv
//assign besh [6:3] = -{1'b0,srcshift[5:3]};//128-srcshift for big endian
always @(*)
begin
	case(srcshift[5:3])
		3'b000		: besh[6:3] = 4'h0;
		3'b001		: besh[6:3] = 4'hF;
		3'b010		: besh[6:3] = 4'hE;
		3'b011		: besh[6:3] = 4'hD;
		3'b100		: besh[6:3] = 4'hC;
		3'b101		: besh[6:3] = 4'hB;
		3'b110		: besh[6:3] = 4'hA;
		default		: besh[6:3] = 4'h9;
	endcase
end

// SRCSHIFT.NET (53) - shift[0] : nivm
// SRCSHIFT.NET (54) - shift[1] : mx2m
// SRCSHIFT.NET (55) - shift[2] : mx2m
// SRCSHIFT.NET (56) - shiftt[3] : niv
// SRCSHIFT.NET (57) - shiftt[4] : mx2
// SRCSHIFT.NET (58) - shiftt[5] : mx2
// SRCSHIFT.NET (59) - shiftt[6] : an2
assign shift[6:0] = (big_pix) ? besh[6:0] : {1'b0,srcshift[5:0]};//0 and 3 are identical for big_pix

// SRCSHIFT.NET (68) - onep[8-63] : mx2
//assign onep[63:8] = (shift[6]) ? shsrc[127:72] : shsrc[63:8];

// SRCSHIFT.NET (70) - onep[64-127] : mx2
//assign onep[127:64] = (shift[6]) ? shsrc[63:0] : shsrc[127:64];

// SRCSHIFT.NET (75) - onel[40-127] : mx2
//assign onel[127:40] = (shift[5]) ? onep[95:8] : onep[127:40];

// SRCSHIFT.NET (80) - onew[56-127] : mx2
//assign onew[127:56] = (shift[4]) ? onel[111:40] : onel[127:56];

// SRCSHIFT.NET (85) - oneb[64-127] : mx2
//assign oneb[127:64] = (shift[3]) ? onew[119:56] : onew[127:64];
//wire [183:0] onebt = {shsrc[127:0],shsrc[127:72]} << ({shift,3'b000});
//assign oneb[127:64] = onebt[183:120];
always @(*)
begin
//	case({big_pix,srcshift[5:3]})
//		4'b0000,
//		4'b1000		: oneb[127:64] = {srcd1hi[31:0], srcd1lo[31:0]};//shsrc[127:64]; // 0
//		4'b0001		: oneb[127:64] = {srcd1hi[23:0], srcd1lo[31:0], srcd2hi[31:24]};//shsrc[119:56]; // 1
//		4'b0010		: oneb[127:64] = {srcd1hi[15:0], srcd1lo[31:0], srcd2hi[31:16]};//shsrc[111:48]; // 2
//		4'b0011		: oneb[127:64] = {srcd1hi[7:0], srcd1lo[31:0], srcd2hi[31:8]};//shsrc[103:40]; // 3
//		4'b0100		: oneb[127:64] = {srcd1lo[31:0], srcd2hi[31:0]};//shsrc[95:32]; // 4
//		4'b0101		: oneb[127:64] = {srcd1lo[23:0], srcd2hi[31:0], srcd2lo[31:24]};//shsrc[87:24]; // 5
//		4'b0110		: oneb[127:64] = {srcd1lo[15:0], srcd2hi[31:0], srcd2lo[31:16]};//shsrc[79:16]; // 6
//		4'b0111		: oneb[127:64] = {srcd1lo[7:0], srcd2hi[31:0], srcd2lo[31:8]};//shsrc[71:8]; // 7
//		4'b1001		: oneb[127:64] = {srcd2lo[7:0], srcd1hi[31:0], srcd1lo[31:8]};//{shsrc[7:0],shsrc[127:72]}; // F
//		4'b1010		: oneb[127:64] = {srcd2lo[15:0], srcd1hi[31:0], srcd1lo[31:16]};//{shsrc[15:0],shsrc[127:80]}; // E
//		4'b1011		: oneb[127:64] = {srcd2lo[23:0], srcd1hi[31:0], srcd1lo[31:24]};//{shsrc[23:0],shsrc[127:88]}; // D
//		4'b1100		: oneb[127:64] = {srcd2lo[31:0], srcd1hi[31:0]};//{shsrc[31:0],shsrc[127:96]}; // C
//		4'b1101		: oneb[127:64] = {srcd2hi[7:0], srcd2lo[31:0], srcd1hi[31:8]};//{shsrc[39:0],shsrc[127:104]}; // B
//		4'b1110		: oneb[127:64] = {srcd2hi[15:0], srcd2lo[31:0], srcd1hi[31:16]};//{shsrc[47:0],shsrc[127:112]}; // A
//		4'b1111		: oneb[127:64] = {srcd2hi[23:0], srcd2lo[31:0], srcd1hi[31:24]};//{shsrc[55:0],shsrc[127:120]}; // 9
//	endcase
	case({big_pix,srcshift[5:3]})
		4'b0000		: oneb[127:64] = shsrc[127:64]; // 0
		4'b0001		: oneb[127:64] = shsrc[119:56]; // 1
		4'b0010		: oneb[127:64] = shsrc[111:48]; // 2
		4'b0011		: oneb[127:64] = shsrc[103:40]; // 3
		4'b0100		: oneb[127:64] = shsrc[95:32]; // 4
		4'b0101		: oneb[127:64] = shsrc[87:24]; // 5
		4'b0110		: oneb[127:64] = shsrc[79:16]; // 6
		4'b0111		: oneb[127:64] = shsrc[71:8]; // 7
		4'b1000		: oneb[127:64] = shsrc[127:64]; // 0 
		4'b1001		: oneb[127:64] = {shsrc[7:0],shsrc[127:72]}; // F
		4'b1010		: oneb[127:64] = {shsrc[15:0],shsrc[127:80]}; // E
		4'b1011		: oneb[127:64] = {shsrc[23:0],shsrc[127:88]}; // D
		4'b1100		: oneb[127:64] = {shsrc[31:0],shsrc[127:96]}; // C
		4'b1101		: oneb[127:64] = {shsrc[39:0],shsrc[127:104]}; // B
		4'b1110		: oneb[127:64] = {shsrc[47:0],shsrc[127:112]}; // A
		4'b1111		: oneb[127:64] = {shsrc[55:0],shsrc[127:120]}; // 9
	endcase
//	case({big_pix,srcshift[2:0]})
//		4'b0000,
//		4'b1000		: oneo[71:64] = oneb[71:64]; // 0
//		4'b0001,
//		4'b1111		: oneo[71:64] = {oneb[70:64],oneb[71]}; // 1
//		4'b0010,
//		4'b1110		: oneo[71:64] = {oneb[69:64],oneb[71:70]}; // 2
//		4'b0011,
//		4'b1101		: oneo[71:64] = {oneb[68:64],oneb[71:69]}; // 3
//		4'b0100,
//		4'b1100		: oneo[71:64] = {oneb[67:64],oneb[71:68]}; // 4
//		4'b0101,
//		4'b1011		: oneo[71:64] = {oneb[66:64],oneb[71:67]}; // 5
//		4'b0110,
//		4'b1010		: oneo[71:64] = {oneb[65:64],oneb[71:66]}; // 6
//		4'b0111,
//		4'b1001		: oneo[71:64] = {oneb[64],oneb[71:65]}; // 7
//	endcase
end

// SRCSHIFT.NET (90) - onen[64-67] : mx2
assign onen[67:64] = (shift[2]) ? oneb[71:68] : oneb[67:64];

// SRCSHIFT.NET (92) - onen[68-71] : mx2
assign onen[71:68] = (shift[2]) ? oneb[67:64] : oneb[71:68];

// SRCSHIFT.NET (97) - onet[64-65] : mx2
assign onet[65:64] = (shift[1]) ? onen[71:70] : onen[65:64];

// SRCSHIFT.NET (99) - onet[66-71] : mx2
assign onet[71:66] = (shift[1]) ? onen[69:64] : onen[71:66];

// SRCSHIFT.NET (104) - oneo[64] : mx2
assign oneo[64] = (shift[0]) ? onet[71] : onet[64];

// SRCSHIFT.NET (106) - oneo[65-71] : mx2
assign oneo[71:65] = (shift[0]) ? onet[70:64] : onet[71:65];

// SRCSHIFT.NET (110) - srcd[0] : join
assign srcd_0[7:0] = oneo[71:64];
assign srcd_0[31:8] = oneb[95:72];

// SRCSHIFT.NET (111) - srcd[1] : join
assign srcd_1[31:0] = oneb[127:96];
endmodule

