//`include "defs.v"
// altera message_off 10036

module lbuf
(
	input aout_1,
	input aout_15,
	input dout_0,
	input dout_1,
	input dout_2,
	input dout_3,
	input dout_4,
	input dout_5,
	input dout_6,
	input dout_7,
	input dout_8,
	input dout_9,
	input dout_10,
	input dout_11,
	input dout_12,
	input dout_13,
	input dout_14,
	input dout_15,
	input dout_16,
	input dout_17,
	input dout_18,
	input dout_19,
	input dout_20,
	input dout_21,
	input dout_22,
	input dout_23,
	input dout_24,
	input dout_25,
	input dout_26,
	input dout_27,
	input dout_28,
	input dout_29,
	input dout_30,
	input dout_31,
	input siz_2,
	input lbwa_0,
	input lbwa_1,
	input lbwa_2,
	input lbwa_3,
	input lbwa_4,
	input lbwa_5,
	input lbwa_6,
	input lbwa_7,
	input lbwa_8,
	input lbra_0,
	input lbra_1,
	input lbra_2,
	input lbra_3,
	input lbra_4,
	input lbra_5,
	input lbra_6,
	input lbra_7,
	input lbra_8,
	input lbwe_0,
	input lbwe_1,
	input lbwd_0,
	input lbwd_1,
	input lbwd_2,
	input lbwd_3,
	input lbwd_4,
	input lbwd_5,
	input lbwd_6,
	input lbwd_7,
	input lbwd_8,
	input lbwd_9,
	input lbwd_10,
	input lbwd_11,
	input lbwd_12,
	input lbwd_13,
	input lbwd_14,
	input lbwd_15,
	input lbwd_16,
	input lbwd_17,
	input lbwd_18,
	input lbwd_19,
	input lbwd_20,
	input lbwd_21,
	input lbwd_22,
	input lbwd_23,
	input lbwd_24,
	input lbwd_25,
	input lbwd_26,
	input lbwd_27,
	input lbwd_28,
	input lbwd_29,
	input lbwd_30,
	input lbwd_31,
	input lbufa,
	input lbufb,
	input lbaw,
	input lbbw,
	input rmw,
	input reads,
	input vclk,
	input clk_0,
	input lben,
	input bgw,
	input bgwr,
	input vactive,
	input lbaactive,
	input lbbactive,
	input bigend,
	output lbrd_0,
	output lbrd_1,
	output lbrd_2,
	output lbrd_3,
	output lbrd_4,
	output lbrd_5,
	output lbrd_6,
	output lbrd_7,
	output lbrd_8,
	output lbrd_9,
	output lbrd_10,
	output lbrd_11,
	output lbrd_12,
	output lbrd_13,
	output lbrd_14,
	output lbrd_15,
	output lbrd_16,
	output lbrd_17,
	output lbrd_18,
	output lbrd_19,
	output lbrd_20,
	output lbrd_21,
	output lbrd_22,
	output lbrd_23,
	output lbrd_24,
	output lbrd_25,
	output lbrd_26,
	output lbrd_27,
	output lbrd_28,
	output lbrd_29,
	output lbrd_30,
	output lbrd_31,
	output dr_0_out,
	output dr_0_oe,
	input dr_0_in,
	output dr_1_out,
	output dr_1_oe,
	input dr_1_in,
	output dr_2_out,
	output dr_2_oe,
	input dr_2_in,
	output dr_3_out,
	output dr_3_oe,
	input dr_3_in,
	output dr_4_out,
	output dr_4_oe,
	input dr_4_in,
	output dr_5_out,
	output dr_5_oe,
	input dr_5_in,
	output dr_6_out,
	output dr_6_oe,
	input dr_6_in,
	output dr_7_out,
	output dr_7_oe,
	input dr_7_in,
	output dr_8_out,
	output dr_8_oe,
	input dr_8_in,
	output dr_9_out,
	output dr_9_oe,
	input dr_9_in,
	output dr_10_out,
	output dr_10_oe,
	input dr_10_in,
	output dr_11_out,
	output dr_11_oe,
	input dr_11_in,
	output dr_12_out,
	output dr_12_oe,
	input dr_12_in,
	output dr_13_out,
	output dr_13_oe,
	input dr_13_in,
	output dr_14_out,
	output dr_14_oe,
	input dr_14_in,
	output dr_15_out,
	output dr_15_oe,
	input dr_15_in,
	input sys_clk // Generated
);
wire [31:0] dout = {dout_31,dout_30,
dout_29,dout_28,dout_27,dout_26,dout_25,dout_24,dout_23,dout_22,dout_21,dout_20,
dout_19,dout_18,dout_17,dout_16,dout_15,dout_14,dout_13,dout_12,dout_11,dout_10,
dout_9,dout_8,dout_7,dout_6,dout_5,dout_4,dout_3,dout_2,dout_1,dout_0};
wire [8:0] lbwa = {lbwa_8,lbwa_7,lbwa_6,lbwa_5,lbwa_4,lbwa_3,lbwa_2,lbwa_1,lbwa_0};
wire [8:0] lbra = {lbra_8,lbra_7,lbra_6,lbra_5,lbra_4,lbra_3,lbra_2,lbra_1,lbra_0};
wire [1:0] lbwe = {lbwe_1,lbwe_0};
wire [31:0] lbwd = {lbwd_31,lbwd_30,
lbwd_29,lbwd_28,lbwd_27,lbwd_26,lbwd_25,lbwd_24,lbwd_23,lbwd_22,lbwd_21,lbwd_20,
lbwd_19,lbwd_18,lbwd_17,lbwd_16,lbwd_15,lbwd_14,lbwd_13,lbwd_12,lbwd_11,lbwd_10,
lbwd_9,lbwd_8,lbwd_7,lbwd_6,lbwd_5,lbwd_4,lbwd_3,lbwd_2,lbwd_1,lbwd_0};
wire [31:0] lbrd;
assign {lbrd_31,lbrd_30,
lbrd_29,lbrd_28,lbrd_27,lbrd_26,lbrd_25,lbrd_24,lbrd_23,lbrd_22,lbrd_21,lbrd_20,
lbrd_19,lbrd_18,lbrd_17,lbrd_16,lbrd_15,lbrd_14,lbrd_13,lbrd_12,lbrd_11,lbrd_10,
lbrd_9,lbrd_8,lbrd_7,lbrd_6,lbrd_5,lbrd_4,lbrd_3,lbrd_2,lbrd_1,lbrd_0} = lbrd[31:0];
wire [15:0] dr_out;
assign {dr_15_out,dr_14_out,dr_13_out,dr_12_out,dr_11_out,dr_10_out,dr_9_out,dr_8_out,dr_7_out,dr_6_out,dr_5_out,dr_4_out,dr_3_out,dr_2_out,dr_1_out,dr_0_out} = dr_out[15:0];
assign {dr_15_oe,dr_14_oe,dr_13_oe,dr_12_oe,dr_11_oe,dr_10_oe,dr_9_oe,dr_8_oe,dr_7_oe,dr_6_oe,dr_5_oe,dr_4_oe,dr_3_oe,dr_2_oe,dr_1_oe} = {15{dr_0_oe}};
_lbuf lbuf_inst
(
	.aout_1 /* IN */ (aout_1),
	.aout_15 /* IN */ (aout_15),
	.dout /* IN */ (dout[31:0]),
	.siz_2 /* IN */ (siz_2),
	.lbwa /* IN */ (lbwa[8:0]),
	.lbra /* IN */ (lbra[8:0]),
	.lbwe /* IN */ (lbwe[1:0]),
	.lbwd /* IN */ (lbwd[31:0]),
	.lbufa /* IN */ (lbufa),
	.lbufb /* IN */ (lbufb),
	.lbaw /* IN */ (lbaw),
	.lbbw /* IN */ (lbbw),
	.rmw /* IN */ (rmw),
	.reads /* IN */ (reads),
	.vclk /* IN */ (vclk),
	.clk /* IN */ (clk_0),
	.lben /* IN */ (lben),
	.bgw /* IN */ (bgw),
	.bgwr /* IN */ (bgwr),
	.vactive /* IN */ (vactive),
	.lbaactive /* IN */ (lbaactive),
	.lbbactive /* IN */ (lbbactive),
	.bigend /* IN */ (bigend),
	.lbrd /* OUT */ (lbrd[31:0]),
	.dr_out /* BUS */ (dr_out[15:0]),
	.dr_oe /* BUS */ (dr_0_oe),
	.sys_clk(sys_clk) // Generated
);
endmodule
