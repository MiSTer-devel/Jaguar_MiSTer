//`include "defs.v"

module _j_saturate
(
	output [31:0] q,
	input [31:0] d,
	input satszp,
	input [39:32] accum
);
wire sat16;
wire pos16t;
wire pos16;
wire neg16t;
wire neg16;
wire sat32;
wire pos32t;
wire pos32;
wire neg32t;
wire neg32;
wire [1:0] uncht;
wire unch;
wire bit0to14;
wire bit15to30;
wire bit31;

// DSP_A-5Q.NET (634) - sat16 : iv
assign sat16 = ~satszp;

// DSP_A-5Q.NET (642) - pos16t : or16
assign pos16t = |d[30:15];

// DSP_A-5Q.NET (643) - pos16 : an3
assign pos16 = sat16 & ~d[31] & pos16t;

// DSP_A-5Q.NET (644) - neg16t : nd16
assign neg16t = ~(&d[30:15]);

// DSP_A-5Q.NET (645) - neg16 : an3
assign neg16 = sat16 & d[31] & neg16t;

// DSP_A-5Q.NET (651) - sat32 : join
assign sat32 = satszp;

// DSP_A-5Q.NET (659) - pos32t : or8
assign pos32t = d[31] | |accum[38:32];

// DSP_A-5Q.NET (660) - pos32 : an3
assign pos32 = sat32 & ~accum[39] & pos32t;

// DSP_A-5Q.NET (661) - neg32t : nd8
assign neg32t = ~(d[31] & &accum[38:32]);

// DSP_A-5Q.NET (662) - neg32 : an3
assign neg32 = sat32 & accum[39] & neg32t;

// DSP_A-5Q.NET (672) - uncht0 : nd3
assign uncht[0] = ~(sat16 & ~pos16 & ~neg16);

// DSP_A-5Q.NET (673) - uncht1 : nd3
assign uncht[1] = ~(sat32 & ~pos32 & ~neg32);

// DSP_A-5Q.NET (674) - unch : nd2u
assign unch = ~(&uncht[1:0]);

// DSP_A-5Q.NET (683) - bit0to14 : or2p
assign bit0to14 = pos32 | pos16;

// DSP_A-5Q.NET (684) - bit15to30 : or2_h
assign bit15to30 = pos32 | neg16;

// DSP_A-5Q.NET (685) - bit31 : or2
assign bit31 = neg16 | neg32;

// DSP_A-5Q.NET (687) - sato[0-14] : mx2
assign q[14:0] = (unch) ? d[14:0] : {15{bit0to14}};

// DSP_A-5Q.NET (688) - sato[15-30] : mx2
assign q[30:15] = (unch) ? d[30:15] : {16{bit15to30}};

// DSP_A-5Q.NET (689) - sato[31] : mx2
assign q[31] = (unch) ? d[31] : bit31;

endmodule
