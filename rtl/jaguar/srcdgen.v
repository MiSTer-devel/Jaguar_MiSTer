//`include "defs.v"

module _srcdgen
(
	output locdent,
	output [31:0] locsrc,
	input [31:0] program_count,
	input [3:0] srcdat,
	input [4:0] srcop
);
//	 0 = register data
//	 1 = operand field 0-31
//	 2 = operand field 0-31 * 4
//	 3 = operand field negative
//	 4 = constant 0
//	 5 = operand field signed -16 - 15
//	 6 = constant -1
//	 7 = program count
//	 8 = operand field 1-32
//	 9 = operand field selects one bit set
//	10 = operand field selects one bit clear

wire [4:0] botsrc;
wire [4:0] _const;
wire [4:0] opshft;
wire [31:0] gensrc;
wire [31:0] mask;
wire type5;
wire oneselt;
wire onesel;
wire topsrct;
wire topsrc;
wire srcb7;
wire opzero;
wire type2;
wire srcb6;
wire type8;
wire srcb5;
wire type6;
wire constsel;
wire [31:0] maskt_n;
wire type9;
wire type7;
wire type10;
wire [1:0] sdsel;

// INS_EXEC.NET (652) - locdent : or4u
assign locdent = |srcdat[3:0];

// INS_EXEC.NET (664) - type5 : an4
assign type5 = (srcdat[3:0] == 4'h5);

// INS_EXEC.NET (669) - oneselt : eo
assign oneselt = srcdat[0] ^ srcdat[2];

// INS_EXEC.NET (670) - onesel : an3
assign onesel = oneselt & srcdat[1] & ~srcdat[3];

// INS_EXEC.NET (671) - topsrct : aor1
assign topsrct = (srcop[4] & type5) | onesel;

// Top 24 bits can be:
// 0	types 1,2,4,8
// 1	types 3,6
// sign 	types 5
// INS_EXEC.NET (672) - topsrc : nivh
assign topsrc = topsrct;

// INS_EXEC.NET (677) - srcb7 : mx2
assign srcb7 = (type2) ? opzero : topsrc;

// INS_EXEC.NET (682) - type2 : an4m
assign type2 = (srcdat[3:0]==4'h2);

// INS_EXEC.NET (684) - srcb6 : mx2
assign srcb6 = (type2) ? srcop[4] : topsrc;

// INS_EXEC.NET (689) - type8 : an4
assign type8 = (srcdat[3:0]==4'h8);

// INS_EXEC.NET (690) - opzero : nr5
assign opzero = ~(|srcop[4:0]);

// INS_EXEC.NET (691) - srcb5 : mx4
assign srcb5 = type2 ? (type8 ? 1'b0 : srcop[3]) : (type8 ? opzero : topsrc);

// INS_EXEC.NET (697) - type6 : an4
assign type6 = (srcdat[3:0]==4'h6);

// INS_EXEC.NET (702) - constsel : an3p
assign constsel = ~srcdat[0] & srcdat[2] & ~srcdat[3];

// INS_EXEC.NET (705) - const : join
assign _const[4:0] = {5{type6}};

// INS_EXEC.NET (707) - opshft : join
assign opshft[4:0] = {srcop[2:0],2'b00};

// INS_EXEC.NET (708) - botsrc : mx4
assign botsrc[4:0] = type2 ? (opshft[4:0]) : (constsel ? _const[4:0] : srcop[4:0]);

// INS_EXEC.NET (713) - gensrc : join
assign gensrc[4:0] = botsrc[4:0];
assign gensrc[5] = srcb5;
assign gensrc[6] = srcb6;
assign gensrc[7] = srcb7;
assign gensrc[31:8] = {24{topsrc}};

// INS_EXEC.NET (722) - masklo : d416g2l
assign maskt_n[15:0] = ~(~srcop[4] ? (16'h0001 << srcop[3:0]) : 16'h0);

// INS_EXEC.NET (724) - maskhi : d416g2l
assign maskt_n[31:16] = ~(srcop[4] ? (16'h0001 << srcop[3:0]) : 16'h0);

// INS_EXEC.NET (726) - type9 : an4u
assign type9 = (srcdat[3:0]==4'h9);

// INS_EXEC.NET (728) - mask[0-31] : eo
assign mask[31:0] = maskt_n[31:0] ^ {32{type9}};

// INS_EXEC.NET (740) - type7 : an4
assign type7 = (srcdat[3:0]==4'h7);

// INS_EXEC.NET (741) - type10 : an4
assign type10 = (srcdat[3:0]==4'hA);

// INS_EXEC.NET (743) - sdsel0 : or2u
assign sdsel[0] = type9 | type10;

// INS_EXEC.NET (744) - sdsel1 : nivu
assign sdsel[1] = type7;

// INS_EXEC.NET (746) - locsrc : mx4
assign locsrc[31:0] = sdsel[1] ? (program_count[31:0]) : (sdsel[0] ? mask[31:0] : gensrc[31:0]);

endmodule
