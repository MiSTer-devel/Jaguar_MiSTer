/* verilator lint_off LITENDIAN */
//`include "defs.v"

module _arb
(
	input [1:0] bbreq,
	input [1:0] gbreq,
	input obbreq,
	input bglin,
	input brlin,
	input [1:0] dbrl,
	input refreq,
	input ihandler,
	input ack,
	input resetl,
	input clk,
	input bgain,
	input notreadt,
	input dreqin,
	output bback,
	output gback,
	output obback,
	output brlout,
	output dbgl,
	output refack,
	output ba,
	output intbm,
	output cpubm,
	output intbms,
	output intbmw,
	input sys_clk // Generated
);
reg q0 = 1'b1;
reg q1 = 1'b0;
wire q2;
wire d0;
wire d1;
wire d2;
reg q2i = 1'b0;
wire mt00;
wire lbrl;
wire mt01;
wire bgack;
wire mt02;
wire brs;
wire mt03;
wire lbackl;
wire mt04;
wire mt10;
wire lbr;
reg brsl = 1'b0;
wire notbgack;
wire mt11;
wire mt12;
wire mt20;
wire bgin;
wire notdreqin;
wire mt21;
wire lback;
wire mt22;
wire mt23;
wire ackl;
wire brin;
wire brd;
wire [10:0] req;
wire [10:1] dl;
wire [10:2] d;
wire [9:0] pr;
reg [9:0] ack_ = 10'h001;
wire arben;
wire cpub1;
wire intbmt;
wire intbmwd;
wire ack48;
wire pr48;
wire dbg0;
wire dbg1;
reg dbg = 1'b0;
wire dbgd;

// Output buffers
wire brlout_obuf;
wire intbm_obuf;
reg intbms_obuf = 1'b0;
reg intbmw_obuf = 1'b0;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end


// Output buffers
assign brlout = brlout_obuf;
assign intbm = intbm_obuf;
assign intbms = intbms_obuf;
assign intbmw = intbmw_obuf;


// ARB.NET (48) - q0 : fd4q
// ARB.NET (49) - q1 : fd2q
// ARB.NET (50) - q2i : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			q0 <= 1'b1;
			q1 <= 1'b0;
			q2i <= 1'b0;
		end else begin
			q0 <= d0;
			q1 <= d1;
			q2i <= d2;
		end
	end
end

// ARB.NET (51) - q2 : nivm
assign q2 = q2i;

// ARB.NET (53) - mt00 : nd2
assign mt00 = ~(q0 & lbrl);

// ARB.NET (54) - mt01 : nd2
assign mt01 = ~(q0 & bgack);

// ARB.NET (55) - mt02 : nd2
assign mt02 = ~(q0 & brs);

// ARB.NET (56) - mt03 : nd4
assign mt03 = ~(q2 & lbackl & lbrl & ack);

// ARB.NET (57) - mt04 : nd3
assign mt04 = ~(q2 & brs & ack);

// ARB.NET (58) - d0 : nd6
assign d0 = ~(mt00 & mt01 & mt02 & mt03 & mt04);

// ARB.NET (60) - mt10 : nd4
assign mt10 = ~(q0 & lbr & brsl & notbgack);

// ARB.NET (61) - mt11 : nd2
assign mt11 = ~(q1 & bglin);

// ARB.NET (62) - mt12 : nd2
assign mt12 = ~(q1 & dreqin);

// ARB.NET (63) - d1 : nd3
assign d1 = ~(mt10 & mt11 & mt12);

// ARB.NET (65) - mt20 : nd3
assign mt20 = ~(q1 & bgin & notdreqin);

// ARB.NET (66) - mt21 : nd3
assign mt21 = ~(q2 & brsl & lback);

// ARB.NET (67) - mt22 : nd3
assign mt22 = ~(q2 & brsl & lbr);

// ARB.NET (68) - mt23 : nd2
assign mt23 = ~(q2 & ackl);

// ARB.NET (69) - d2 : nd4
assign d2 = ~(mt20 & mt21 & mt22 & mt23);

// ARB.NET (71) - brlout : iv
assign brlout_obuf = ~q1;

// ARB.NET (72) - bgin : iv
assign bgin = ~bglin;

// ARB.NET (73) - ackl : iv
assign ackl = ~ack;

// ARB.NET (74) - ba : nivh
assign ba = q2;

// ARB.NET (75) - bgack : iv
assign bgack = ~bgain;

// ARB.NET (76) - notbgack : iv
assign notbgack = ~bgack;

// ARB.NET (77) - notdreqin : iv
assign notdreqin = ~dreqin;

// ARB.NET (81) - brin : iv
assign brin = ~brlin;

// ARB.NET (82) - brd : nd2
assign brd = ~(brin & brlout_obuf);

// ARB.NET (83) - brs : fd1
// always @(posedge cp)
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		brsl <= brd;
	end
end
assign brs = ~brsl;

// ARB.NET (85) - req[10] : an2 (q2 & brs)
// ARB.NET (86) - req[9] : niv refreq
// ARB.NET (87) - req[8] : iv ~dbrl_1
// ARB.NET (88) - req[7] : niv gbreq_1
// ARB.NET (89) - req[6] : niv bbreq_1
// ARB.NET (90) - req[5] : niv obbreq
// ARB.NET (91) - req[4] : iv ~dbrl_0
// ARB.NET (92) - req[3] : niv ihandler
// ARB.NET (93) - req[2] : niv gbreq_0
// ARB.NET (94) - req[1] : niv bbreq_0
// ARB.NET (95) - req[0] : niv vcc
assign req[10:0] = {(q2 & brs),refreq,~dbrl[1],gbreq[1],bbreq[1],obbreq,~dbrl[0],ihandler,gbreq[0],bbreq[0],1'b1};

// ARB.NET (97) - dl[10] : iv
// ARB.NET (98) - dl[1-9] : nr2
assign dl[10:1] = ~({1'b0,d[10:2]} | req[10:1]);

// ARB.NET (99) - d[2-10] : iv
assign d[10:2] = ~dl[10:2];

// ARB.NET (103) - pr[0-9] : an2
assign pr[9:0] = req[9:0] & dl[10:1];

// ARB.NET (109) - ack[1-9] : slatchc
// ARB.NET (110) - ack[0] : slatchp
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			ack_[9:0] <= 10'h001;
		end else begin
			if (arben) begin
				ack_[9:0] <= pr[9:0];
			end
		end
	end
end

// ARB.NET (114) - lbrl : nr8
assign lbrl = ~(|pr[9:4] | |pr[2:1]);

// ARB.NET (115) - lbr : iv
assign lbr = ~lbrl;

// ARB.NET (116) - lbackl : nr8
assign lbackl = ~(|ack_[9:4] | |ack_[2:1]);

// ARB.NET (117) - lback : iv
assign lback = ~lbackl;

// ARB.NET (124) - arben : an2m
assign arben = q2 & ack;

// ARB.NET (133) - cpub1 : an2
assign cpub1 = q0 & brsl;

// ARB.NET (134) - cpuback : or4
assign cpubm = ack_[0] | ack_[3] | q1 | cpub1;

// ARB.NET (135) - bback : or2
assign bback = ack_[1] | ack_[6];

// ARB.NET (136) - gback : or2
assign gback = ack_[2] | ack_[7];

// ARB.NET (137) - obback : nivh
assign obback = ack_[5];

// ARB.NET (138) - refack : niv
assign refack = ack_[9];

// ARB.NET (143) - intbm : or6
assign intbm_obuf = (|ack_[2:1]) | (|ack_[7:5]) | ack_[9];

// ARB.NET (144) - intbmt : mx2
assign intbmt = (ack) ? intbm_obuf : intbms_obuf;

// ARB.NET (145) - intbms : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			intbms_obuf <= 1'b0;// always @(posedge cp or negedge sd)
		end else begin
			intbms_obuf <= intbmt;
		end
	end
end

// ARB.NET (147) - intbmwd : nd2
assign intbmwd = ~(notreadt & intbmt);

// ARB.NET (148) - intbmw : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		intbmw_obuf <= intbmwd;
	end
end

// ARB.NET (152) - ack48 : or2
assign ack48 = ack_[4] | ack_[8];

// ARB.NET (153) - pr48 : or2
assign pr48 = pr[4] | pr[8];

// ARB.NET (155) - dbg0 : nd3
assign dbg0 = ~(ack48 & ack & pr48);

// ARB.NET (156) - dbg1 : nd2
assign dbg1 = ~(dbg & pr48);

// ARB.NET (157) - dbgd : nd2
assign dbgd = ~(dbg0 & dbg1);

// ARB.NET (159) - dbg : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			dbg <= 1'b0;// always @(posedge cp or negedge sd)
		end else begin
			dbg <= dbgd;
		end
	end
end

// ARB.NET (160) - dbgl : iv
assign dbgl = ~dbg;
endmodule

