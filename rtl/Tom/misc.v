//`include "defs.v"
// altera message_off 10036

module _misc
(
	input [15:0] din,
	input clk,
	input resetl,
	input pit0w,
	input pit1w,
	input int1w,
	input int2w,
	input intr,
	input obint,
	input gpuint,
	input vint,
	input dint,
	input [3:0] refrate,
	input refback,
	input ack,
	input startref,
	input wet,
	input pit0r,
	input pit1r,
	input tcount,
	input test3r,
	output ihandler,
	output tint,
	output refreq,
	output intl,
	output [15:0] dr_out,
	output dr_oe,
	output dr_15_12_oe, // test3r dr[11:0] driven by vid
	output mreq_out,
	output mreq_oe,
	input mreq_in,	
// NOT_NETLIST
	input vintbugfix,	
	input sys_clk // Generated
);
wire vcc;
wire intw;
reg [4:0] ie = 5'h00;
wire [4:0] ack_;
reg lvint = 1'b0;
wire vclr;
wire ackl_0;
reg vi1 = 1'b0;
reg vi2 = 1'b0;
wire vi2l;
wire vip;
wire gip;
wire oip;
wire tip;
reg di1 = 1'b0;
reg di2 = 1'b0;
wire di2l;
wire dip;
reg [4:0] i = 5'h00;
wire gnd;
wire notint2w;
wire ihd0;
wire ihd;
wire pit0;
wire pit1;
reg [15:0] pd = 16'h0000;
reg [15:0] td = 16'h0000;
wire ten0;
wire ten1;
wire ten;
wire presl;
reg [15:0] tp = 16'h0000;
wire tpld;
wire tpc8;
wire tplac0;
wire tplac1;
wire tpc16;
wire tpldi;
reg [15:0] t = 16'h0000;
wire tld;
wire tc8;
wire tlac0;
wire tlac1;
wire tc16;
wire tldi;
reg [3:0] rc = 4'h0;
reg [5:0] ps = 6'h00;
wire pen;
reg rq = 1'b0;
wire d0;
wire d00;
wire notrq;
wire full;
wire d01;
wire notempty;
wire d02;
wire decl;
wire refack;
wire dec;
wire rpcen;
reg [3:0] rp = 4'h0;
wire lrpc;
wire [3:0] rpl;
wire lrpcl;
wire rpenl;
wire rpen;
wire refcount;
wire [2:0] rfc;
wire notrefack;
wire [15:0] dr_int_out;
wire [15:0] dr_pit0_out;
wire [15:0] dr_pit1_out;
wire [15:12] dr_rc_out;
wire dr_int_oe;
wire dr_pit0_oe;
wire dr_pit1_oe;
wire dr_rc_oe;

// Output buffers
reg ihandler_obuf = 1'b0;
wire tint_obuf;
wire refreq_obuf;
wire intl_obuf;

reg old_clk;
reg old_resetl;
reg old_presl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
	old_presl <= presl;
end


// Output buffers
assign ihandler = ihandler_obuf;
assign tint = tint_obuf;
assign refreq = refreq_obuf;
assign intl = intl_obuf;


// MISC.NET (44) - vcc : tie1
assign vcc = 1'b1;

// MISC.NET (48) - intw : an2
assign intw = int1w & wet;

// MISC.NET (49) - ie[0-4] : ldp2q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (~resetl) begin
		ie <= 5'h00; // ldp2q negedge // always @(d or g or cd)
	end else if (intw) begin
		ie <= din[4:0]; // ldp2q negedge // always @(d or g or cd)
	end
end

// MISC.NET (51) - ack[0-4] : an2
assign ack_[4:0] = int1w ? din[12:8] : 5'h00;

// MISC.NET (55) - lvint : lsrb
// always @(r or s)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin///////check this; timing critical
	if (vint & ~vclr) begin
		lvint <= 1'b1;
	end else if (vclr) begin
		lvint <= 1'b0;
	end
end

// MISC.NET (56) - vclr : nd2
//assign vclr = ~(resetl & ackl_0); // Original netlist
// Iron Soldier 2 and Barkley Shut Up and Jam seem to requre one of these
//assign vclr = ~(resetl & ackl_0) | (int1w && din[0]);
// NOT_NETLIST
assign vclr = ~(resetl & ackl_0) | (int1w && din[0] && ~ie[0] && vintbugfix);

// MISC.NET (57) - ackl[0] : iv
assign ackl_0 = ~ack_[0];

// MISC.NET (61) - vi1 : fd2q
// MISC.NET (62) - vi2 : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			vi1 <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			vi2 <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
		end else begin
			vi1 <= lvint; // fd2q negedge // always @(posedge cp or negedge cd)
			vi2 <= vi1; // fd2q negedge // always @(posedge cp or negedge cd)
		end
	end
end

// MISC.NET (63) - vi2l : iv
assign vi2l = ~vi2;

// MISC.NET (64) - vip : an3
assign vip = vi1 & vi2l & ie[0];

// MISC.NET (66) - gip : an2
assign gip = gpuint & ie[1];

// MISC.NET (67) - oip : an2
assign oip = obint & ie[2];

// MISC.NET (68) - tip : an2
assign tip = tint_obuf & ie[3];

// MISC.NET (70) - di1 : fd2q
// MISC.NET (71) - di2 : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			di1 <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
			di2 <= 1'b0; // fd2q negedge // always @(posedge cp or negedge cd)
		end else begin
			di1 <= dint; // fd2q negedge // always @(posedge cp or negedge cd)
			di2 <= di1; // fd2q negedge // always @(posedge cp or negedge cd)
		end
	end
end

// MISC.NET (72) - di2l : iv
assign di2l = ~di2;

// MISC.NET (73) - dip : an3
assign dip = di1 & di2l & ie[4];

// MISC.NET (77) - i[0] : fjk2
// MISC.NET (78) - i[1] : fjk2
// MISC.NET (79) - i[2] : fjk2
// MISC.NET (80) - i[3] : fjk2
// MISC.NET (81) - i[4] : fjk2
//			if (~j & k) begin
//				i <= 1'b0;
//			end else if (j & ~k) begin
//				i <= 1'b1;
//			end else if (j & k) begin
//				i <= ~i;
//			end else if (~j & ~k) begin
//				i <= i;
//			end
//			i <= (j & ~k) | (j & k & ~i) | (~j & ~k & i);
wire [4:0] jf = {dip, tip, oip, gip, vip};
wire [4:0] kf = ack_[4:0];
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			i[4:0] <= 1'b0;
		end else begin
			i[4:0] <= (jf[4:0] & ~kf[4:0]) | (jf[4:0] & kf[4:0] & ~i[4:0]) | (~jf[4:0] & ~kf[4:0] & i[4:0]);
		end
	end
end

// MISC.NET (87) - intl : nr6
assign intl_obuf = ~(|i[4:0]);

// MISC.NET (91) - di[0-4] : ts
// MISC.NET (92) - di[5-15] : ts
assign dr_int_out[15:0] = {11'h000, i[4:0]};
assign dr_int_oe = intr;

// MISC.NET (93) - gnd : tie0
assign gnd = 1'b0;

// MISC.NET (100) - notint2w : iv
assign notint2w = ~int2w;

// MISC.NET (101) - ihd0 : nd2
assign ihd0 = ~(ihandler_obuf & notint2w);

// MISC.NET (102) - ihd : nd2
assign ihd = ~(ihd0 & intl_obuf);

// MISC.NET (103) - ihandler : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			ihandler_obuf <= 1'b0;// always @(posedge cp or negedge cd)
		end else begin
			ihandler_obuf <= ihd;
		end
	end
end

// MISC.NET (110) - pit0 : nivh
assign pit0 = pit0w;

// MISC.NET (111) - pit1 : an2h
assign pit1 = wet & pit1w;

// MISC.NET (113) - pd[0-15] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (pit0) begin
			pd[15:0] <= din[15:0];
		end
	end
end

// MISC.NET (114) - td[0-15] : ldp1q
// always @(d or g)
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (pit1) begin
		td[15:0] <= din[15:0]; // ldp1q negedge always @(d or g)
	end
end

// MISC.NET (118) - ten0 : or8
assign ten0 = |pd[7:0];

// MISC.NET (119) - ten1 : or8
assign ten1 = |pd[15:8];

// MISC.NET (120) - ten : or2
assign ten = ten0 | ten1;

// MISC.NET (121) - presl : an2u
assign presl = ten & resetl;

// MISC.NET (125) - tp[0] : dncnt
// MISC.NET (126) - tp[1-7] : dncnt
// MISC.NET (127) - tp[8] : dncnt
// MISC.NET (128) - tp[9-15] : dncnt
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_presl && ~presl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~presl) begin
			tp[15:0] <= 16'h0;
		end else if (tpld) begin
			tp[15:0] <= pd[15:0];
		end else if (ten) begin
			tp[15:0] <= tp[15:0] - 16'h1;
		end
	end
end

// MISC.NET (132) - tplac0 : nr8
assign tplac0 = ~(|tp[7:0]);

// MISC.NET (133) - tplac1 : nr8
assign tplac1 = ~(|tp[15:8]);

// MISC.NET (134) - tpc8 : an2
assign tpc8 = tplac0 & ten;

// MISC.NET (135) - tpc16 : an3
assign tpc16 = tplac0 & tplac1 & ten;

// MISC.NET (137) - tpldi : nr2
assign tpldi = ~(tpc16 | pit0w);

// MISC.NET (138) - tpld : ivh
assign tpld = ~tpldi;

// MISC.NET (140) - dtp[0-15] : ts
assign dr_pit0_out = tp[15:0];
assign dr_pit0_oe = pit0r;

// MISC.NET (144) - t[0] : dncnt
// MISC.NET (145) - t[1-7] : dncnt
// MISC.NET (146) - t[8] : dncnt
// MISC.NET (147) - t[9-15] : dncnt
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_presl && ~presl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~presl) begin
			t[15:0] <= 16'h0;
		end else if (tld) begin
			t[15:0] <= td[15:0];
		end else if (tpc16) begin
			t[15:0] <= t[15:0] - 16'h1;
		end
	end
end

// MISC.NET (151) - tlac0 : nr8
assign tlac0 = ~(|t[7:0]);

// MISC.NET (152) - tlac1 : nr8
assign tlac1 = ~(|t[15:8]);

// MISC.NET (153) - tc8 : an2
assign tc8 = tlac0 & tpc16;

// MISC.NET (154) - tc16 : an3
assign tc16 = tlac0 & tlac1 & tpc16;

// MISC.NET (155) - tldi : nr2
assign tldi = ~(tc16 | pit1w);

// MISC.NET (156) - tld : ivh
assign tld = ~tldi;

// MISC.NET (158) - dt[0-15] : ts
assign dr_pit1_out = t[15:0];
assign dr_pit1_oe = pit1r;

// MISC.NET (160) - tint : niv
assign tint_obuf = tc16;

// MISC.NET (175) - ps[0] : upcnt1
// MISC.NET (176) - ps[1-5] : upcnt1
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			ps[5:0] <= 6'h00; // fd2q negedge // always @(posedge cp or negedge cd)
		end else begin
			ps[5:0] <= ps[5:0] + 6'h01; // fd2q negedge // always @(posedge cp or negedge cd)
		end
	end
end

// MISC.NET (177) - pen : an6
assign pen = &ps[5:0];

// MISC.NET (195) - rq : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			rq <= 1'b0;// always @(posedge cp or negedge cd)
		end else begin
			rq <= d0;
		end
	end
end

// MISC.NET (197) - d00 : nd2
assign d00 = ~(notrq & full);

// MISC.NET (198) - d01 : nd3
assign d01 = ~(notrq & startref & notempty);

// MISC.NET (199) - d02 : nd2
assign d02 = ~(rq & notempty);

// MISC.NET (200) - d0 : nd3
assign d0 = ~(d00 & d01 & d02);

// MISC.NET (202) - refbreq : an2
assign refreq_obuf = rq & notempty;

// MISC.NET (203) - mreq : ts
assign mreq_out = refreq_obuf;
assign mreq_oe = refback;

// MISC.NET (205) - decl : nd2
assign decl = ~(refack & mreq_in);

// MISC.NET (206) - dec : iv
assign dec = ~decl;

// MISC.NET (215) - rpcen : or2
assign rpcen = pen | tcount;

// MISC.NET (217) - rp[0] : dncnt
// MISC.NET (218) - rp[1-3] : dncnt
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			rp[3:0] <= 4'h0;
		end else if (lrpc) begin
			rp[3:0] <= refrate[3:0];
		end else if (rpcen) begin
			rp[3:0] <= rp[3:0] - 4'h1;
		end
	end
end

// MISC.NET (222) - rpl[0-3] : iv
assign rpl[3:0] = ~rp[3:0];

// MISC.NET (223) - lrpcl : nd6
assign lrpcl = ~((&rpl[3:0]) & rpcen);

// MISC.NET (224) - lrpc : ivh
assign lrpc = ~lrpcl;

// MISC.NET (228) - rpenl : nr4p
assign rpenl = ~(|refrate[3:0]);

// MISC.NET (229) - rpen : iv
assign rpen = ~rpenl;

// MISC.NET (237) - rc[0] : udcnt1
// MISC.NET (238) - rc[1-3] : udcnt1
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			rc[3:0] <= 4'h0; // fd2q
		end else begin
			if (lrpc & refcount) begin // I think this is the same as the optimized logic in netlist
				rc[3:0] <= rc[3:0] + 4'h1;
			end else if (~lrpc & refcount) begin
				rc[3:0] <= rc[3:0] - 4'h1;
			end
		end
	end
end

// MISC.NET (245) - drc[0-3] : ts
assign dr_rc_out[15:12] = rc[3:0];
assign dr_rc_oe = test3r;

// MISC.NET (247) - rfc0 : nd3
assign rfc[0] = ~(lrpc & rpen & decl);

// MISC.NET (248) - rfc1 : nd2
assign rfc[1] = ~(lrpcl & dec);

// MISC.NET (249) - rfc2 : nd2
assign rfc[2] = ~(rpenl & dec);

// MISC.NET (250) - refcount : nd3
assign refcount = ~(&rfc[2:0]);

// MISC.NET (252) - full : niv
assign full = rc[3];

// MISC.NET (253) - notempty : or4
assign notempty = |rc[3:0];

// MISC.NET (255) - notrefack : nd2
assign notrefack = ~(refback & ack);

// MISC.NET (256) - refack : iv
assign refack = ~notrefack;

// MISC.NET (258) - notrq : iv
assign notrq = ~rq;

// --- Compiler-generated PE for BUS dr[0]
assign dr_out = ((dr_int_oe) ? dr_int_out[15:0] : 16'h0000) | ((dr_pit0_oe) ? dr_pit0_out[15:0] : 16'h0000) | ((dr_pit1_oe) ? dr_pit1_out[15:0] : 16'h0000) | {((dr_rc_oe) ? dr_rc_out[15:12] : 4'h0),12'h000};
assign dr_oe = dr_int_oe | dr_pit0_oe | dr_pit1_oe;
assign dr_15_12_oe = dr_rc_oe;

endmodule

