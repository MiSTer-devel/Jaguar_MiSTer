//`include "defs.v"
// altera message_off 10036

module _ob
(
	input [15:0] din,
	input olp1w,
	input olp2w,
	input obfw,
	input ob0r,
	input ob1r,
	input ob2r,
	input ob3r,
	input start,
	input [20:0] newdata,
	input [9:0] newheight,
	input [7:0] newrem,
	input obdready,
	input offscreen,
	input refack,
	input obback,
	input mack,
	input clk,
	input resetl,
	input [10:0] vc,
	input wbkdone,
	input obdone,
	input heightnz,
	input [63:0] d,//d_0
	input blback,
	input grpback,
	input wet,
	input hcb_10,
	output scaled,
	output obdlatch,
	output mode1,
	output mode2,
	output mode4,
	output mode8,
	output mode16,
	output mode24,
	output rmw,
	output [7:1] index,
	output xld,
	output reflected,
	output transen,
	output [7:0] hscale,
	output [9:0] dwidth,
	output obbreq,
	output [7:0] vscale,
	output wbkstart,
	output grpintreq,
	output obint,
	output obld_0,
	output obld_1,
	output obld_2,
	output startref,
	output vgy,
	output vey,
	output vly,
	output [63:0] wd_out,
	output wd_oe,
	output [23:0] a_out,
	output a_oe,
	output [3:0] w_out,
	output w_oe,
	output rw_out,
	output rw_oe,
	input rw_in,
	output mreq_out,
	output mreq_oe,
	input mreq_in,
	output justify_out,
	output justify_oe,
	output [15:0] dr_out,
	output dr_oe,
	input sys_clk // Generated
);
reg [2:0] type_ = 3'h0;
wire oblatch_0;
reg [10:0] ypos = 11'h000;
reg [18:0] link = 19'h00000;
reg [20:0] data = 21'h000000;
wire wbken_0;
reg [2:0] depth = 3'h0;
wire oblatch_1;
reg [2:0] skip = 3'h0;
reg [9:0] dwidth_ = 10'h000;
reg [7:1] index_ = 7'h000;
reg reflected_ = 1'b0;
reg rmw_ = 1'b0;
reg transen_ = 1'b0;
reg _release = 1'b0;
wire oblatch_2;
reg [7:5] rem = 3'h0;
wire wbken_2;
reg [23:3] olpd = 21'h000000;
wire [21:3] olpd1;
wire pclink;
reg [21:3] olp = 19'h00000;
wire pcinc;
wire olpld;
wire olpldi;
wire pcld;
wire [2:0] sum;
wire [20:0] dco;
reg dmainc = 1'b0;
wire dmaen;
wire ldinc;
wire [2:0] d1_;
wire dci;
wire dlac9;
wire obfws;
reg obf = 1'b0;
reg [9:0] iwidth = 10'h000;
wire bit0;
wire iwidthz0;
wire iwidthz1;
wire iwidthnz;
wire iwidthz;
reg q0 = 1'b1;
wire d0;
reg q1 = 1'b0;
wire d1;
reg q2 = 1'b0;
wire d2;
reg q3i = 1'b0;
wire d3;
wire q3;
reg q4i = 1'b0;
wire d4;
wire q4;
reg q5 = 1'b0;
wire d5;
reg q7 = 1'b0;
wire d7;
reg q8 = 1'b0;
wire d8;
reg q9 = 1'b0;
wire d9;
wire d00;
wire notstartover;
wire d01;
wire notbitob;
wire notscaled;
wire notgrpob;
wire notbranchob;
wire d10;
wire startover;
wire d11;
wire notobmack;
wire d12;
wire bitob;
wire bitnotinrange;
wire d13;
wire branchob;
wire cctrue;
wire d14;
wire d15;
wire scalednotinrange;
wire d16;
wire obmack;
wire d17;
wire d18;
wire d19;
wire ccfalse;
wire d1a;
wire d1b;
wire d20;
wire d21;
wire d23;
wire notobdone;
wire d30;
wire d31;
wire geq;
wire d32;
wire d40;
wire d41;
wire onscreen;
wire d42;
wire d43;
wire notwbkdone;
wire d44;
wire scaledinrange;
wire d45;
wire d46;
wire d51;
wire d52;
wire d53;
wire d70;
wire grpob;
wire d71;
wire notobfw;
wire d80;
wire d81;
wire d90;
wire d91;
wire obr0;
wire obr1;
wire obr2;
wire obr3;
wire obr4;
wire obbr0;
wire obr5;
wire obbr1;
wire obr6;
wire obr7;
wire hold;
wire omrq0;
wire omrq1;
wire omrq2;
wire omrq3;
wire omrq4;
wire omrq5;
wire omrq6;
wire obmreq;
wire obldd_0;
wire obldd_1;
wire obldd_2;
wire pc1en;
wire pc2en0;
wire pc2en;
wire dmaen0;
wire obdlatchd;
wire dsel0;
wire dsel1;
wire dsel2;
wire dataseli;
wire datasel;
wire pclinki;
wire stopob;
wire obrw1;
wire obrw;
wire wbken2d;
wire wr;
wire eback;
wire ewr;
wire wbken0d;
wire xldi;
wire notstopob;
wire cctrue0;
wire cctrue1;
wire y7ff;
wire cctrue2;
wire cctrue3;
wire cctrue4;
wire cctrue5;
wire mode8i;
reg start1 = 1'b0;
reg start2 = 1'b0;
wire start2l;
wire sstart;
wire ov1;
wire q0l;
wire ov2;
reg overrun = 1'b0;
wire overrund;
wire obeni;
wire oben;
wire obldi_0;
wire obldi_1;
wire obldi_2;
reg wbkeni_0 = 1'b1;
reg wbkeni_2 = 1'b0;
wire equ;
wire [10:0] ve;
wire veyl;
wire y7ff0;
wire y7ff1;
wire remnz;
wire remheightnz;
wire unused;
wire [4:3] olp1;
wire [23:3] oa;
wire [63:0] wd_a_out;
wire wd_a_oe;
wire [63:0] wd_b_out;
wire wd_b_oe;
wire [15:0] dr_a_out;
wire dr_a_oe;
wire [15:0] dr_b_out;
wire dr_b_oe;
wire [15:0] dr_c_out;
wire dr_c_oe;
wire [15:0] dr_d_out;
wire dr_d_oe;

// Output buffers
wire scaled_obuf;
reg [7:0] hscale_obuf = 8'h00;
reg [7:0] vscale_obuf = 8'h00;
wire obld_0_obuf;
wire obld_1_obuf;
wire obld_2_obuf;
wire vgy_obuf;
wire vey_obuf;
wire vly_obuf;

// Output buffers
assign scaled = scaled_obuf;
assign hscale[7:0] = hscale_obuf[7:0];
assign vscale[7:0] = vscale_obuf[7:0];
assign obld_0 = obld_0_obuf;
assign obld_1 = obld_1_obuf;
assign obld_2 = obld_2_obuf;
assign vgy = vgy_obuf;
assign vey = vey_obuf;
assign vly = vly_obuf;

assign dwidth = dwidth_;
assign index = index_;
assign reflected = reflected_;
assign rmw = rmw_;
assign transen = transen_;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end


// OB.NET (49) - type[0-2] : slatch
// OB.NET (50) - ypos[0-10] : slatch
// OB.NET (52) - link[0-18] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (oblatch_0) begin
			type_[2:0] <= d[2:0];
			ypos[10:0] <= d[13:3];
			link[18:0] <= d[42:24];
		end
	end
end

// OB.NET (57) - ob0rd[0-2] : ts
assign dr_a_out[2:0] = type_[2:0];
assign dr_a_oe = ob0r;

// OB.NET (58) - ob0rd[3-13] : ts
assign dr_a_out[13:3] = ypos[10:0];

// OB.NET (59) - ob0rd[14-15] : ts
assign dr_a_out[15:14] = newheight[1:0];

// OB.NET (61) - ob1rd[0-7] : ts
assign dr_b_out[7:0] = newheight[9:2];
assign dr_b_oe = ob1r;

// OB.NET (62) - ob1rd[8-15] : ts
assign dr_b_out[15:8] = link[7:0];

// OB.NET (64) - ob2rd[0-10] : ts
assign dr_c_out[10:0] = link[18:8];
assign dr_c_oe = ob2r;

// OB.NET (65) - ob2rd[11-15] : ts
assign dr_c_out[15:11] = data[4:0];

// OB.NET (67) - ob3rd[0-15] : ts
assign dr_d_out[15:0] = data[20:5];
assign dr_d_oe = ob3r;

// OB.NET (71) - obwbk0[0-2] : ts
assign wd_a_out[2:0] = type_[2:0];
assign wd_a_oe = wbken_0;

// OB.NET (72) - obwbk0[3-13] : ts
assign wd_a_out[13:3] = ypos[10:0];

// OB.NET (73) - obwbk0[14-23] : ts
assign wd_a_out[23:14] = newheight[9:0];

// OB.NET (74) - obwbk0[24-42] : ts
assign wd_a_out[42:24] = link[18:0];

// OB.NET (75) - obwbk0[43-63] : ts
assign wd_a_out[63:43] = newdata[20:0];

// OB.NET (78) - depth[0-2] : slatch
// OB.NET (79) - skip[0-2] : slatch
// OB.NET (80) - dwidth[0-9] : slatch
// OB.NET (82) - index[1-7] : slatch
// OB.NET (83) - reflected : slatch
// OB.NET (85) - transen : slatch
// OB.NET (86) - release : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (oblatch_1) begin
			depth[2:0] <= d[14:12];
			skip[2:0] <= d[17:15];
			dwidth_[9:0] <= d[27:18];
			index_[7:1] <= d[44:38];
			reflected_ <= d[45];
			rmw_ <= d[46];
			transen_ <= d[47];
			_release <= d[48];
		end
	end
end

// OB.NET (88) - hscale[0-7] : slatch
// OB.NET (89) - vscale[0-7] : slatch
// OB.NET (90) - rem[5-7] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (oblatch_2) begin
			hscale_obuf[7:0] <= d[7:0];
			vscale_obuf[7:0] <= d[15:8];
			rem[7:5] <= d[23:21];
		end
	end
end

// OB.NET (94) - obwbk2[0-7] : ts
assign wd_b_out[7:0] = hscale_obuf[7:0];
assign wd_b_oe = wbken_2;

// OB.NET (95) - obwbk2[8-15] : ts
assign wd_b_out[15:8] = vscale_obuf[7:0];

// OB.NET (96) - obwbk2[16-23] : ts
assign wd_b_out[23:16] = newrem[7:0];

// OB.NET (97) - obwbk2[24-63] : ts
assign wd_b_out[63:24] = 40'h00000000;

// OB.NET (101) - olpd[3-15] : ldp1q
// OB.NET (102) - olpd[16-23] : ldp1q
// always @(d or g)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (olp1w) begin
		olpd[15:3] <= din[15:3]; // ldp1q negedge always @(d or g)
	end
	if (olp2w) begin
		olpd[23:16] <= din[7:0]; // ldp1q negedge always @(d or g)
	end
end

// OB.NET (106) - olpd1[3-21] : mx2
assign olpd1[21:3] = (pclink) ? link[18:0] : olpd[21:3];

// OB.NET (110) - olp[3] : upcnt
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			olp[21:3] <= 19'h00000; // fd2q negedge // always @(posedge cp or negedge cd)
		end else if (olpld) begin
			olp[21:3] <= olpd1[21:3]; // fd2q negedge // always @(posedge cp or negedge cd)
		end else if (pcinc) begin
			olp[21:3] <= olp[21:3] + 19'h00001; // fd2q negedge // always @(posedge cp or negedge cd)
		end
	end
end

// OB.NET (122) - olpldi : nr2
assign olpldi = ~(pcld | pclink);

// OB.NET (123) - olpld : ivh
assign olpld = ~olpldi;

// OB.NET (135) - dmainc : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		dmainc <= dmaen;
	end
end

// OB.NET (144) - data[3] : upcnt
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin // fd2q always @(posedge cp or negedge cd)
		if (obld_0_obuf) begin
			data[20:0] <= d[63:43]; // fd2q negedge // always @(posedge cp or negedge cd)
		end else if (dmainc) begin
			data[20:0] <= data[20:0] + skip[2:0]; // fd2q negedge // always @(posedge cp or negedge cd)
		end
		if (~resetl) begin // no reset for lowest 3 bits?
			data[20:3] <= 18'h0000; // fd2q negedge // always @(posedge cp or negedge cd)
		end
	end
	if (old_resetl && ~resetl) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin // no reset for lowest 3 bits?
			data[20:3] <= 18'h0000; // fd2q negedge // always @(posedge cp or negedge cd)
		end
	end
end

// OB.NET (157) - obfws : an2
assign obfws = obfw & wet;

// OB.NET (158) - obf : ldp1q
// always @(d or g)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (obfws) begin
		obf <= din[0];
	end
end

// OB.NET (162) - iwidth[0] : dncnt
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			iwidth[9:0] <= 10'h0;
		end else if (obld_1_obuf) begin
			iwidth[9:0] <= d[37:28];
		end else if (dmaen) begin
			iwidth[9:0] <= iwidth[9:0] - 10'h1;
		end
	end
end

// OB.NET (171) - bit0 : an2
assign bit0 = iwidth[0] & scaled_obuf;

// OB.NET (172) - iwidthz0 : nr6
assign iwidthz0 = ~(bit0 | (|iwidth[5:1]));

// OB.NET (173) - iwidthz1 : nr4
assign iwidthz1 = ~(|iwidth[9:6]);

// OB.NET (174) - iwidthnz : nd2
assign iwidthnz = ~(iwidthz0 & iwidthz1);

// OB.NET (175) - iwidthz : iv
assign iwidthz = ~iwidthnz;

// OB.NET (377) - q0 : fd4q
// OB.NET (378) - q1 : fd2q
// OB.NET (379) - q2 : fd2q
// OB.NET (380) - q3i : fd2q
// OB.NET (382) - q4i : fd2q
// OB.NET (384) - q5 : fd2q
// OB.NET (385) - q7 : fd2q
// OB.NET (386) - q8 : fd2q
// OB.NET (387) - q9 : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			q0 <= 1'b1;// always @(posedge cp or negedge sd)
			q1 <= 1'b0;// always @(posedge cp or negedge cd)
			q2 <= 1'b0;// always @(posedge cp or negedge cd)
			q3i <= 1'b0;// always @(posedge cp or negedge cd)
			q4i <= 1'b0;// always @(posedge cp or negedge cd)
			q5 <= 1'b0;// always @(posedge cp or negedge cd)
			q7 <= 1'b0;// always @(posedge cp or negedge cd)
			q8 <= 1'b0;// always @(posedge cp or negedge cd)
			q9 <= 1'b0;// always @(posedge cp or negedge cd)
		end else begin
			q0 <= d0;
			q1 <= d1;
			q2 <= d2;
			q3i <= d3;
			q4i <= d4;
			q5 <= d5;
			q7 <= d7;
			q8 <= d8;
			q9 <= d9;
		end
	end
end

// OB.NET (381) - q3 : nivm
assign q3 = q3i;

// OB.NET (383) - q4 : nivh
assign q4 = q4i;

// OB.NET (389) - d00 : nd2
assign d00 = ~(q0 & notstartover);

// OB.NET (390) - d01 : nd6
assign d01 = ~(q3 & notbitob & notscaled & notgrpob & notbranchob);

// OB.NET (391) - d0 : nd2
assign d0 = ~(d00 & d01);

// OB.NET (393) - d10 : nd2
assign d10 = ~(q0 & startover);

// OB.NET (394) - d11 : nd2
assign d11 = ~(q1 & notobmack);

// OB.NET (395) - d12 : nd3
assign d12 = ~(q3 & bitob & bitnotinrange);

// OB.NET (396) - d13 : nd3
assign d13 = ~(q3 & branchob & cctrue);

// OB.NET (397) - d14 : nd2
assign d14 = ~(q7 & obfw);

// OB.NET (398) - d15 : nd2
assign d15 = ~(q9 & scalednotinrange);

// OB.NET (399) - d16 : nd6
assign d16 = ~(q4 & iwidthz & wbkdone & obmack & bitob);

// OB.NET (400) - d17 : nd6
assign d17 = ~(q4 & offscreen & wbkdone & obmack & bitob);

// OB.NET (401) - d18 : nd2
assign d18 = ~(q5 & obmack);

// OB.NET (402) - d19 : nd3
assign d19 = ~(q3 & branchob & ccfalse);

// OB.NET (403) - d1a : nd6
assign d1a = ~(d10 & d11 & d12 & d13 & d14 & d15);

// OB.NET (404) - d1b : nd4
assign d1b = ~(d16 & d17 & d18 & d19);

// OB.NET (405) - d1 : or2
assign d1 = d1a | d1b;

// OB.NET (407) - d20 : nd2
assign d20 = ~(q1 & obmack);

// OB.NET (408) - d21 : nd2
assign d21 = ~(q2 & notobmack);

// OB.NET (409) - d23 : nd2
assign d23 = ~(q2 & notobdone);

// OB.NET (410) - d2 : nd3
assign d2 = ~(d20 & d21 & d23);

// OB.NET (412) - d30 : nd3
assign d30 = ~(q2 & obdone & obmack);

// OB.NET (413) - d31 : nd6
assign d31 = ~(q3 & bitob & geq & heightnz & notobmack);

// OB.NET (414) - d32 : nd3
assign d32 = ~(q3 & scaled_obuf & notobmack);

// OB.NET (415) - d3 : nd3
assign d3 = ~(d30 & d31 & d32);

// OB.NET (417) - d40 : nd6
assign d40 = ~(q3 & bitob & geq & heightnz & obmack);

// OB.NET (418) - d41 : nd3
assign d41 = ~(q4 & onscreen & iwidthnz);

// OB.NET (419) - d42 : nd4
assign d42 = ~(q4 & iwidthz & wbkdone & notobmack);

// OB.NET (420) - d43 : nd3
assign d43 = ~(q4 & iwidthz & notwbkdone);

// OB.NET (421) - d44 : nd3
assign d44 = ~(q9 & scaledinrange & obmack);

// OB.NET (422) - d45 : nd4
assign d45 = ~(q4 & offscreen & wbkdone & notobmack);

// OB.NET (423) - d46 : nd3
assign d46 = ~(q4 & offscreen & notwbkdone);

// OB.NET (424) - d4 : nd8
assign d4 = ~(d40 & d41 & d42 & d43 & d44 & d45 & d46);

// OB.NET (426) - d51 : nd6
assign d51 = ~(q4 & iwidthz & wbkdone & obmack & scaled_obuf);

// OB.NET (427) - d52 : nd2
assign d52 = ~(q5 & notobmack);

// OB.NET (428) - d53 : nd6
assign d53 = ~(q4 & offscreen & wbkdone & obmack & scaled_obuf);

// OB.NET (429) - d5 : nd3
assign d5 = ~(d51 & d52 & d53);

// OB.NET (431) - d70 : nd2
assign d70 = ~(q3 & grpob);

// OB.NET (432) - d71 : nd2
assign d71 = ~(q7 & notobfw);

// OB.NET (433) - d7 : nd2
assign d7 = ~(d70 & d71);

// OB.NET (435) - d80 : nd3
assign d80 = ~(q3 & scaled_obuf & obmack);

// OB.NET (436) - d81 : nd2
assign d81 = ~(q8 & notobmack);

// OB.NET (437) - d8 : nd2
assign d8 = ~(d80 & d81);

// OB.NET (439) - d90 : nd2
assign d90 = ~(q8 & obmack);

// OB.NET (440) - d91 : nd3
assign d91 = ~(q9 & scaledinrange & notobmack);

// OB.NET (441) - d9 : nd2
assign d9 = ~(d90 & d91);

// OB.NET (443) - pcld : iv
assign pcld = ~d10;

// OB.NET (448) - obr0 : nr4
assign obr0 = ~(q1 | q5 | q8 | q9);

// OB.NET (449) - obr1 : nd2
assign obr1 = ~(q3 & bitob);

// OB.NET (450) - obr2 : nd2
assign obr2 = ~(q3 & branchob);

// OB.NET (451) - obr3 : nd2
assign obr3 = ~(q3 & scaled_obuf);

// OB.NET (452) - obr4 : nd2
assign obr4 = ~(q2 & obbr0);

// OB.NET (453) - obr5 : nd4
assign obr5 = ~(q4 & onscreen & iwidthnz & obbr1);

// OB.NET (454) - obr6 : nd2
assign obr6 = ~(q4 & offscreen);

// OB.NET (455) - obr7 : nd2
assign obr7 = ~(q4 & iwidthz);

// OB.NET (456) - obbreq : nd8
assign obbreq = ~(obr0 & obr1 & obr2 & obr3 & obr4 & obr5 & obr6 & obr7);

// OB.NET (457) - obbr0 : or2
assign obbr0 = obdone | hold;

// OB.NET (458) - obbr1 : or2
assign obbr1 = obdready | hold;

// OB.NET (460) - omrq0 : nr2
assign omrq0 = ~(q1 | q5);

// OB.NET (461) - omrq1 : nd4
assign omrq1 = ~(q3 & bitob & geq & heightnz);

// OB.NET (462) - omrq2 : nd4
assign omrq2 = ~(q4 & onscreen & iwidthnz & obdready);

// OB.NET (463) - omrq3 : nd3
assign omrq3 = ~(q4 & iwidthz & wbkdone);

// OB.NET (464) - omrq4 : nd2
assign omrq4 = ~(q9 & scaledinrange);

// OB.NET (465) - omrq5 : nd2
assign omrq5 = ~(q2 & obdone);

// OB.NET (466) - omrq6 : nd3
assign omrq6 = ~(q4 & offscreen & wbkdone);

// OB.NET (467) - obmreq : nd8
assign obmreq = ~(omrq0 & omrq1 & omrq2 & omrq3 & omrq4 & omrq5 & omrq6 & obr3);

// OB.NET (469) - obldd[0] : iv
assign obldd_0 = ~d20;

// OB.NET (470) - obldd[1] : iv
assign obldd_1 = ~d30;

// OB.NET (471) - obldd[2] : iv
assign obldd_2 = ~d80;

// OB.NET (477) - pc1en : iv
assign pc1en = ~d30;

// OB.NET (478) - pc2en0 : nd2
assign pc2en0 = ~(q5 & obmack);

// OB.NET (479) - pc2en : nd2
assign pc2en = ~(d80 & pc2en0);

// OB.NET (481) - dmaen0 : nd6
assign dmaen0 = ~(q4 & onscreen & iwidthnz & obdready & obmack);

// OB.NET (482) - dmaen : nd3
assign dmaen = ~(d40 & dmaen0 & d44);

// OB.NET (483) - obdlatchd : niv
assign obdlatchd = dmaen;

// OB.NET (485) - dsel0 : nd2
assign dsel0 = ~(q3 & bitob);

// OB.NET (486) - dsel1 : iv
assign dsel1 = ~q9;

// OB.NET (487) - dsel2 : nd3
assign dsel2 = ~(q4 & onscreen & iwidthnz);

// OB.NET (488) - dataseli : nd3
assign dataseli = ~(dsel0 & dsel1 & dsel2);

// OB.NET (489) - datasel : nivu
assign datasel = dataseli;

// OB.NET (491) - pclinki : nd6
assign pclinki = ~(d12 & d13 & d15 & d16 & d17 & d18);

// OB.NET (492) - pclink : nivh
assign pclink = pclinki;

// OB.NET (493) - pcinc : nd2
assign pcinc = ~(d70 & d19);

// OB.NET (495) - grpintreq : iv
assign grpintreq = ~d70;

// OB.NET (496) - obint : an3
assign obint = q3 & stopob & ypos[0];

// OB.NET (497) - startref : an2
assign startref = q3 & stopob;

// OB.NET (499) - obrw1 : iv
assign obrw1 = ~q5;

// OB.NET (500) - obrw : an3
assign obrw = obrw1 & omrq3 & omrq6;

// OB.NET (505) - wbkstart : nd2
assign wbkstart = ~(d40 & omrq4);

// OB.NET (507) - wbken2d : iv
assign wbken2d = ~pc2en0;

// OB.NET (515) - wr : iv
assign wr = ~rw_in;

// OB.NET (516) - eback : or2
assign eback = blback | grpback;

// OB.NET (517) - ewr : an4
assign ewr = eback & wr & mack & mreq_in;

// OB.NET (518) - wbken0d : nr2
assign wbken0d = ~(wbken2d | ewr);

// OB.NET (520) - xldi : nd2
assign xldi = ~(d40 & d80);

// OB.NET (521) - xld : nivm
assign xld = xldi;

// OB.NET (529) - notbitob : nd3
assign notbitob = ~(type_[2:0]==3'b000);

// OB.NET (530) - notscaled : nd3
assign notscaled = ~(type_[2:0]==3'b001);

// OB.NET (531) - notgrpob : nd3
assign notgrpob = ~(type_[2:0]==3'b010);

// OB.NET (532) - notbranchob : nd3
assign notbranchob = ~(type_[2:0]==3'b011);

// OB.NET (533) - notstopob : nd3
assign notstopob = ~(type_[2:0]==3'b100);

// OB.NET (535) - bitob : ivm
assign bitob = ~notbitob;

// OB.NET (536) - scaled : ivm
assign scaled_obuf = ~notscaled;

// OB.NET (537) - grpob : iv
assign grpob = ~notgrpob;

// OB.NET (538) - branchob : iv
assign branchob = ~notbranchob;

// OB.NET (539) - stopob : iv
assign stopob = ~notstopob;

// OB.NET (546) - cctrue0 : nd4
assign cctrue0 = ~(newheight[2:0]==3'b000 & vey_obuf);

// OB.NET (547) - cctrue1 : nd4
assign cctrue1 = ~(newheight[2:0]==3'b000 & y7ff);

// OB.NET (548) - cctrue2 : nd4
assign cctrue2 = ~(newheight[2:0]==3'b001 & vly_obuf);

// OB.NET (549) - cctrue3 : nd4
assign cctrue3 = ~(newheight[2:0]==3'b010 & vgy_obuf);

// OB.NET (550) - cctrue4 : nd4
assign cctrue4 = ~(newheight[2:0]==3'b011 & obf);

// OB.NET (551) - cctrue5 : nd4
assign cctrue5 = ~(newheight[2:0]==3'b100 & hcb_10);

// OB.NET (552) - cctrue : nd6
assign cctrue = ~(cctrue0 & cctrue1 & cctrue2 & cctrue3 & cctrue4 & cctrue5);

// OB.NET (553) - ccfalse : iv
assign ccfalse = ~cctrue;

// OB.NET (557) - mode1 : an3h
assign mode1 = depth[2:0]==3'b000;

// OB.NET (558) - mode2 : an3h
assign mode2 = depth[2:0]==3'b001;

// OB.NET (559) - mode4 : an3h
assign mode4 = depth[2:0]==3'b010;

// OB.NET (560) - mode8i : nd3
assign mode8i = ~(depth[2:0]==3'b011);

// OB.NET (561) - mode8 : ivh
assign mode8 = ~mode8i;

// OB.NET (562) - mode16 : an3
assign mode16 = depth[2:0]==3'b100;

// OB.NET (563) - mode24 : an3
assign mode24 = depth[2:0]==3'b101;

// OB.NET (567) - start1 : fd2q
// OB.NET (568) - start2 : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			start1 <= 1'b0;// always @(posedge cp or negedge cd)
			start2 <= 1'b0;// always @(posedge cp or negedge cd)
		end else begin
			start1 <= start;
			start2 <= start1;
		end
	end
end

// OB.NET (569) - start2l : iv
assign start2l = ~start2;

// OB.NET (570) - sstart : an2
assign sstart = start1 & start2l;

// OB.NET (576) - ov1 : nd2
assign ov1 = ~(sstart & q0l);

// OB.NET (577) - ov2 : nd2
assign ov2 = ~(overrun & q0l);

// OB.NET (578) - overrund : nd2
assign overrund = ~(ov1 & ov2);

// OB.NET (579) - overrun : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		overrun <= overrund;
	end
end

// OB.NET (580) - notstartover : nr2
assign notstartover = ~(overrun | sstart);

// OB.NET (581) - startover : iv
assign startover = ~notstartover;

// OB.NET (582) - q0l : iv
assign q0l = ~q0;

// OB.NET (584) - notobmack : nd2x3
assign notobmack = ~(obback & mack);

// OB.NET (585) - obmack : ivh
assign obmack = ~notobmack;

// OB.NET (589) - obeni : or2
assign obeni = obback | refack;

// OB.NET (590) - oben : nivu2
assign oben = obeni;

// OB.NET (591) - rw : ts
assign rw_out = obrw;
assign rw_oe = oben;

// OB.NET (592) - mreq : tsm
assign mreq_out = obmreq;
assign mreq_oe = obback;

// OB.NET (593) - justify : ts
assign justify_out = 1'b0;
assign justify_oe = oben;

// OB.NET (594) - w[0-2] : ts
// OB.NET (595) - w[3] : ts
assign w_out = 4'b1000;
assign w_oe = oben;

// OB.NET (610) - obdlatch : ack_pipe
_ack_pipe obdlatch_inst
(
	.latch /* OUT */ (obdlatch),
	.latchd /* IN */ (obdlatchd),
	.ack /* IN */ (mack),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.sys_clk(sys_clk) // Generated
);

// OB.NET (611) - obldi[0] : ack_pipe
_ack_pipe obldi_index_0_inst
(
	.latch /* OUT */ (obldi_0),
	.latchd /* IN */ (obldd_0),
	.ack /* IN */ (mack),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.sys_clk(sys_clk) // Generated
);

// OB.NET (612) - obldi[1] : ack_pipe
_ack_pipe obldi_index_1_inst
(
	.latch /* OUT */ (obldi_1),
	.latchd /* IN */ (obldd_1),
	.ack /* IN */ (mack),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.sys_clk(sys_clk) // Generated
);

// OB.NET (613) - obldi[2] : ack_pipe
_ack_pipe obldi_index_2_inst
(
	.latch /* OUT */ (obldi_2),
	.latchd /* IN */ (obldd_2),
	.ack /* IN */ (mack),
	.clk /* IN */ (clk),
	.resetl /* IN */ (resetl),
	.sys_clk(sys_clk) // Generated
);

// OB.NET (614) - obld[0] : nivu2
assign obld_0_obuf = obldi_0;

// OB.NET (615) - obld[1] : nivh
assign obld_1_obuf = obldi_1;

// OB.NET (616) - obld[2] : nivh
assign obld_2_obuf = obldi_2;

// OB.NET (618) - oblatch[0-2] : nivu
assign oblatch_0 = obld_0_obuf;
assign oblatch_1 = obld_1_obuf;
assign oblatch_2 = obld_2_obuf;

// OB.NET (620) - wbkeni[0] : fd4q
// OB.NET (622) - wbkeni[2] : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			wbkeni_0 <= 1'b1;// always @(posedge cp or negedge cd)
			wbkeni_2 <= 1'b0;// always @(posedge cp or negedge cd)
		end else begin
			wbkeni_0 <= wbken0d;
			wbkeni_2 <= wbken2d;
		end
	end
end

// OB.NET (621) - wbken[0] : nivu2
assign wbken_0 = wbkeni_0;

// OB.NET (623) - wbken[2] : nivu2
assign wbken_2 = wbkeni_2;

// OB.NET (627) - comp : mag11
assign vgy_obuf = vc[10:0] > ypos[10:0];
assign equ      = vc[10:0] ==ypos[10:0];
assign vly_obuf = vc[10:0] < ypos[10:0];

// OB.NET (628) - geq : iv
assign geq = ~vly_obuf;

// OB.NET (629) - equ : dummy

// OB.NET (633) - ve[0-10] : en
assign ve[10:0] = ~(vc[10:0] ^ ypos[10:0]);

// OB.NET (634) - veyl : nd11
assign veyl = ~(&ve[10:0]);

// OB.NET (635) - vey : iv
assign vey_obuf = ~veyl;

// OB.NET (637) - y7ff0 : nd6
assign y7ff0 = ~(&ypos[5:0]);

// OB.NET (638) - y7ff1 : nd6
assign y7ff1 = ~(&ypos[10:6]);

// OB.NET (639) - y7ff : nr2
assign y7ff = ~(y7ff0 | y7ff1);

// OB.NET (644) - remnz : or3
assign remnz = rem[5] | rem[6] | rem[7];

// OB.NET (646) - bitnotinrange : nd2
assign bitnotinrange = ~(geq & heightnz);

// OB.NET (648) - remheightnz : or2
assign remheightnz = heightnz | remnz;

// OB.NET (649) - scalednotinrange : nd2
assign scalednotinrange = ~(geq & remheightnz);

// OB.NET (650) - scaledinrange : iv
assign scaledinrange = ~scalednotinrange;

// OB.NET (652) - onscreen : iv
assign onscreen = ~offscreen;

// OB.NET (653) - notwbkdone : iv
assign notwbkdone = ~wbkdone;

// OB.NET (654) - notobfw : iv
assign notobfw = ~obfw;

// OB.NET (655) - notobdone : iv
assign notobdone = ~obdone;

// OB.NET (656) - hold : iv
assign hold = ~_release;

// OB.NET (666) - olp1[3] : or2
assign olp1[3] = olp[3] | pc1en;

// OB.NET (667) - olp1[4] : or2
assign olp1[4] = olp[4] | pc2en;

// OB.NET (669) - oa[3-4] : mx2
assign oa[4:3] = (datasel) ? data[1:0] : olp1[4:3];

// OB.NET (670) - oa[5-21] : mx2
assign oa[21:5] = (datasel) ? data[18:2] : olp[21:5];

// OB.NET (671) - oa[22] : mx2
assign oa[23:22] = (datasel) ? data[20:19] : olpd[23:22];

// OB.NET (676) - oa1[0-2] : tsm
assign a_out[2:0] = 3'h0;
assign a_oe = oben;

// OB.NET (677) - oa1[3-23] : tsm
assign a_out[23:3] = oa[23:3];

// --- Compiler-generated PE for BUS wd[0]
assign wd_out[63:0] = ((wd_a_oe) ? wd_a_out[63:0] : 64'h0000) | ((wd_b_oe) ? wd_b_out[63:0] : 64'h0000);
assign wd_oe = wd_a_oe | wd_b_oe;

// --- Compiler-generated PE for BUS dr[0]
assign dr_out[15:0] = ((dr_a_oe) ? dr_a_out[15:0] : 16'h0000) | ((dr_b_oe) ? dr_b_out[15:0] : 16'h0000) | ((dr_c_oe) ? dr_c_out[15:0] : 16'h0000) | ((dr_d_oe) ? dr_d_out[15:0] : 16'h0000);
assign dr_oe = dr_a_oe | dr_b_oe | dr_c_oe | dr_d_oe;

endmodule

