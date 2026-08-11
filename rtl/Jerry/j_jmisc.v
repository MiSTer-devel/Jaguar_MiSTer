//`include "defs.v"
// altera message_off 10036

module _j_jmisc
(
	input [15:0] din,
	input clk,
	input resetl,
	input pit1w,
	input pit2w,
	input pit3w,
	input pit4w,
	input int1w,
	input pit1r,
	input pit2r,
	input pit3r,
	input pit4r,
	input int1r,
	input dint,
	input eint,
	input test1w,
	input joy1wl,
	input uint,
	input i2int,
	output [1:0] tint,
	output ts,
	output _int,
	output ndtest,
	output joyenl,
	output [15:0] dr_out,
	output dr_oe,
	input sys_clk // Generated
);
reg [5:0] ie = 6'h0;
wire [5:0] ack;
reg ei1 = 1'b0;
reg ei2 = 1'b0;
wire eip;
wire dip;
wire [1:0] tip;
wire uip;
wire iip;
reg [5:0] i = 6'h0;
wire [5:0] il;
reg [15:0] pd0 = 16'h0;
reg [15:0] td0 = 16'h0;
wire ten0;
wire presl0;
reg [15:0] tp0 = 16'h0;
wire tpld0;
wire tplac00;
wire tplac01;
wire tpc016;
wire tpld0i;
reg [15:0] t0 = 16'h0;
wire tld0;
wire tlac00;
wire tlac01;
wire tc016;
wire tld0i;
reg [15:0] pd1 = 16'h0;
reg [15:0] td1 = 16'h0;
wire ten10;
wire ten11;
wire ten1;
wire presl1;
reg [15:0] tp1 = 16'h0;
wire tpld1;
wire tplac10;
wire tplac11;
wire tpc116;
wire tpld1i;
reg [15:0] t1 = 16'h0;
wire tld1;
wire tlac10;
wire tlac11;
wire tc116;
wire tld1i;
reg joyen = 1'b0;
wire joy1w;

wire [15:0] dr_a0_out;
wire dr_a0_oe;
wire [15:0] dr_a1_out;
wire dr_a1_oe;
wire [15:0] dr_a2_out;
wire dr_a2_oe;
wire [15:0] dr_a3_out;
wire dr_a3_oe;
wire [15:0] dr_a4_out;
wire dr_a4_oe;

// Output buffers
wire [1:0] tint_obuf;
reg ndtest_;

// Output buffers
assign tint[1:0] = tint_obuf[1:0];
assign ndtest = ndtest_;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// JMISC.NET (55) - ie[0-5] : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		ie[5:0] <= 6'h0;
	end else if (int1w) begin
		ie[5:0] <= din[5:0];
	end
end

// JMISC.NET (56) - ack[0-5] : an2
assign ack[5:0] = int1w ? din[13:8] : 6'h0;

// JMISC.NET (60) - ei1 : fd2q
// JMISC.NET (61) - ei2 : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			ei1 <= 1'b0;
			ei2 <= 1'b0;
		end else begin
			ei1 <= eint;
			ei2 <= ei1;
		end
	end
end

// JMISC.NET (63) - eip : an3
assign eip = ei1 & ~ei2 & ie[0];

// JMISC.NET (65) - dip : an2
assign dip = dint & ie[1];

// JMISC.NET (66) - tip[0-1] : an2
assign tip[1:0] = tint_obuf[1:0] & ie[3:2];

// JMISC.NET (67) - uip : an2
assign uip = uint & ie[4];

// JMISC.NET (68) - iip : an2
assign iip = i2int & ie[5];

// JMISC.NET (72) - i[0] : fjk2
// JMISC.NET (73) - i[1] : fjk2
// JMISC.NET (74) - i[2] : fjk2
// JMISC.NET (75) - i[3] : fjk2
// JMISC.NET (76) - i[4] : fjk2
// JMISC.NET (77) - i[5] : fjk2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			i[5:0] <= 1'b0;
		end else begin
			i[5:0] <= (~ip[5:0] & ~ack[5:0] & i[5:0]) | (ip[5:0] & ~ack[5:0]) | (ip[5:0] & ack[5:0] & ~i[5:0]);
		end
	end
end
wire [5:0] ip = {iip,uip,tip[1:0],dip,eip}; //j ; k=ack[]]

// JMISC.NET (83) - int : nd6
assign _int = ~(i[5:0]==6'b0);

// JMISC.NET (87) - dii[0-5] : ts
// JMISC.NET (88) - dii[6-15] : ts
assign dr_a0_out[15:0] = {10'h0,i[5:0]};
assign dr_a0_oe = int1r;

// JMISC.NET (99) - pd0[0-15] : ldp2q
// JMISC.NET (100) - td0[0-15] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		pd0[15:0] <= 16'h0;
	end else if (pit1w) begin
		pd0[15:0] <= din[15:0];
	end
	if (pit2w) begin
		td0[15:0] <= din[15:0];
	end
end

// JMISC.NET (106) - ten0 : or2
assign ten0 = |pd0[15:0];

// JMISC.NET (107) - presl0 : an2u
assign presl0 = ten0 & resetl;

// JMISC.NET (111) - tp0[0] : dncnt
reg old_presl0;
always @(posedge sys_clk)
begin
	old_presl0 <= presl0;

	if ((~old_clk && clk) | (old_presl0 && ~presl0)) begin
		if (~presl0) begin
			tp0[15:0] <= 16'h0;
		end else begin
			tp0[15:0] <= tpld0 ? pd0[15:0] : (tp0[15:0] - (ten0 ? 1'b1 : 1'b0));
		end
	end
end

// JMISC.NET (118) - tplac00 : nr8
assign tplac00 = ~(|tp0[7:0]);

// JMISC.NET (119) - tplac01 : nr8
assign tplac01 = ~(|tp0[15:8]);

// JMISC.NET (121) - tpc016 : an3
assign tpc016 = tplac00 & tplac01 & ten0;

// JMISC.NET (122) - ts : nivh
assign ts = tpc016; //carry

// JMISC.NET (124) - tpld0i : nr2
assign tpld0i = ~(tpc016 | pit1w);

// JMISC.NET (125) - tpld0 : ivh
assign tpld0 = ~tpld0i;

// JMISC.NET (127) - dtp0[0-15] : ts
assign dr_a1_out[15:0] = tp0[15:0];
assign dr_a1_oe = pit1r;

// JMISC.NET (131) - t0[0] : dncnt
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_presl0 && ~presl0)) begin
		if (~presl0) begin
			t0[15:0] <= 16'h0;
		end else begin
			t0[15:0] <= tld0 ? td0[15:0] : (t0[15:0] - (tpc016 ? 1'b1 : 1'b0));
		end
	end
end

// JMISC.NET (138) - tlac00 : nr8
assign tlac00 = ~(|t0[7:0]);

// JMISC.NET (139) - tlac01 : nr8
assign tlac01 = ~(|t0[15:8]);

// JMISC.NET (141) - tc016 : an3
assign tc016 = tlac00 & tlac01 & tpc016; // carry

// JMISC.NET (142) - tld0i : nr2
assign tld0i = ~(tc016 | pit2w);

// JMISC.NET (143) - tld0 : ivh
assign tld0 = ~tld0i;

// JMISC.NET (145) - dt0[0-15] : ts
assign dr_a2_out[15:0] = t0[15:0];
assign dr_a2_oe = pit2r;

// JMISC.NET (147) - tint[0] : nivu
assign tint_obuf[0] = tc016;

// JMISC.NET (156) - pd1[0-15] : ldp1q
// JMISC.NET (157) - td1[0-15] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (pit3w) begin
		pd1[15:0] <= din[15:0];
	end
	if (pit4w) begin
		td1[15:0] <= din[15:0];
	end
end

// JMISC.NET (161) - ten10 : or8
assign ten10 = |pd1[7:0];

// JMISC.NET (162) - ten11 : or8
assign ten11 = |pd1[15:8];

// JMISC.NET (163) - ten1 : or2
assign ten1 = ten10 | ten11;

// JMISC.NET (164) - presl1 : an2u
assign presl1 = ten1 & resetl;

// JMISC.NET (168) - tp1[0] : dncnt
reg old_presl1;
always @(posedge sys_clk)
begin
	old_presl1 <= presl1;

	if ((~old_clk && clk) | (old_presl1 && ~presl1)) begin
		if (~presl1) begin
			tp1[15:0] <= 16'h0;
		end else begin
			tp1[15:0] <= tpld1 ? pd1[15:0] : (tp1[15:0] - (ten1 ? 1'b1 : 1'b0));
		end
	end
end

// JMISC.NET (175) - tplac10 : nr8
assign tplac10 = ~(|tp1[7:0]);

// JMISC.NET (176) - tplac11 : nr8
assign tplac11 = ~(|tp1[15:8]);

// JMISC.NET (178) - tpc116 : an3
assign tpc116 = tplac10 & tplac11 & ten1;

// JMISC.NET (180) - tpld1i : nr2
assign tpld1i = ~(tpc116 | pit3w);

// JMISC.NET (181) - tpld1 : ivh
assign tpld1 = ~tpld1i;

// JMISC.NET (183) - dtp1[0-15] : ts
assign dr_a3_out[15:0] = tp1[15:0];
assign dr_a3_oe = pit3r;

// JMISC.NET (187) - t1[0] : dncnt
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_presl1 && ~presl1)) begin
		if (~presl1) begin
			t1[15:0] <= 16'h0;
		end else begin
			t1[15:0] <= tld1 ? td1[15:0] : (t1[15:0] - (tpc116 ? 1'b1 : 1'b0));
		end
	end
end

// JMISC.NET (194) - tlac10 : nr8
assign tlac10 = ~(|t1[7:0]);

// JMISC.NET (195) - tlac11 : nr8
assign tlac11 = ~(|t1[15:8]);

// JMISC.NET (197) - tc116 : an3
assign tc116 = tlac10 & tlac11 & tpc116; // carry

// JMISC.NET (198) - tld1i : nr2
assign tld1i = ~(tc116 | pit4w);

// JMISC.NET (199) - tld1 : ivh
assign tld1 = ~tld1i;

// JMISC.NET (201) - dt1[0-15] : ts
assign dr_a4_out[15:0] = t1[15:0];
assign dr_a4_oe = pit4r;

// JMISC.NET (203) - tint[1] : niv
assign tint_obuf[1] = tc116;

// JMISC.NET (212) - ndtest : ldp2q
// JMISC.NET (216) - joyen : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		ndtest_ <= 1'b0;
	end else if (test1w) begin
		ndtest_ <= din[0];
	end
	if (~resetl) begin
		joyen <= 1'b0;
	end else if (joy1w) begin
		joyen <= din[15];
	end
end

// JMISC.NET (217) - joy1w : iv
assign joy1w = ~joy1wl;

// JMISC.NET (218) - joyenl : iv
assign joyenl = ~joyen;

// --- Compiler-generated PE for BUS dr[0]
// Ternaries/muxes are better than stacking ors; assumes no bus conflicts
assign dr_out[15:0] = (dr_a0_oe ? dr_a0_out[15:0] : dr_a1_oe ? dr_a1_out[15:0] : dr_a2_oe ? dr_a2_out[15:0] : dr_a3_oe ? dr_a3_out[15:0] : dr_a4_oe ? dr_a4_out[15:0] : 16'h0);
assign dr_oe = dr_a0_oe | dr_a1_oe | dr_a2_oe | dr_a3_oe | dr_a4_oe;

endmodule
