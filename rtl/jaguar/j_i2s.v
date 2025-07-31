//`include "defs.v"
// altera message_off 10036

module _j_i2s
(
	input resetl,
	input clk,
	input [15:0] din,
	input i2s1w,
	input i2s2w,
	input i2s3w,
	input i2s4w,
	input i2s1r,
	input i2s2r,
	input i2s3r,
	input i2rxd,
	input sckin,
	input wsin,
	output i2txd,
	output sckout,
	output wsout,
	output i2int,
	output i2sen,
	output [15:0] dr_out,
	output dr_oe,
	output [15:0] snd_l,
	output [15:0] snd_r,
	output snd_l_en,
	output snd_r_en,
	input sys_clk // Generated
);
reg [7:0] t = 8'h0;
reg [4:0] b = 5'h0;
reg [3:0] bc = 4'h0;
reg [7:0] p = 8'h0;
wire [7:0] tco;
wire tld;
wire bresl;
wire ben;
wire wsod0;
reg wsen = 1'b0;
wire wsod1;
wire wsod;
wire scks;
wire sck;
wire sckl;
wire wss;
reg [1:0] ws = 2'h0;
wire wsp0;
reg rising = 1'b0;
wire wsp1;
reg falling = 1'b0;
wire wsp2;
wire msb;
reg everyword = 1'b0;
(*keep*) wire wsp;
wire [3:0] bci;
wire bcen;
wire bcresl;
wire bcres0;
wire bcres1;
wire mode16;
wire bcres2;
wire lsb;
reg mode32 = 1'b0;
reg ov = 1'b0;
wire ovd0;
wire ovd1;
wire ovd;
wire ovl;
wire leftd0;
wire leftd1;
reg left = 1'b0;
wire notlsb;
wire leftd2;
wire right;
wire leftd;
wire ll;
wire rr;
wire [14:0] bit_;
wire msbl;
wire msbd;
reg msbi = 1'b0;
reg [15:0] sd = 16'h0;
reg [15:0] lrd = 16'h0;
wire trrd;
reg [15:0] rrd = 16'h0;
wire trld;
reg [15:0] dpl = 16'h0;
reg [15:0] dpr = 16'h0;
wire [15:0] dp;
wire [15:0] ds;
reg [15:0] qs = 16'h0;

wire [15:0] drr_out;
wire drr_oe;
wire [15:0] drl_out;
wire drl_oe;
wire [15:0] drws_out;
wire drws_oe;

// Output buffers
reg sckout_obuf = 1'b0;
reg wsout_obuf = 1'b0;
reg i2sen_obuf = 1'b0;
reg i2int_ = 1'b0;


// Output buffers
assign sckout = sckout_obuf;
assign wsout = wsout_obuf;
assign i2sen = i2sen_obuf;
assign i2int = i2int_;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// I2S.NET (50) - p[0-7] : stlatchc
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			p[7:0] <= 8'h0;
		end else begin
			if (i2s3w) begin
				p[7:0] <= din[7:0];
			end
		end
	end
end
wire [7:0] p_ = i2s3w ? din[7:0] : p[7:0];

// I2S.NET (54) - t[0] : dncnt
// I2S.NET (55) - t[1-7] : dncnt
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			t[7:0] <= 8'h0;
		end else begin
			t[7:0] <= (tld) ? p_[7:0] : (t[7:0] - 1'b1); // ci==vcc
		end
	end
end

// I2S.NET (56) - tldl : nr2
// I2S.NET (57) - tld : ivm
assign tld = ((t[7:0]==8'h0) | i2s3w); // tco[7] = t[7:0]==0 and ci==vcc

// I2S.NET (62) - sckout : slatchc
// I2S.NET (63) - sckol : iv
reg old_bresl;
always @(posedge sys_clk)
begin
	old_bresl <= bresl;
	if ((~old_clk && clk) | (old_bresl && ~bresl)) begin
		if (~bresl) begin
			sckout_obuf <= 1'b0;
		end else begin
			if (t[7:0]==8'h0) begin //tco[7] = t[7:0]==0
				sckout_obuf <= ~sckout;
			end
		end
	end
end

// I2S.NET (64) - ben : an2
assign ben = sckout & (t[7:0]==8'h0);

// I2S.NET (68) - b[0] : upcnt1
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_bresl && ~bresl)) begin
		if (~bresl) begin
			b[4:0] <= 5'h0;
		end else begin
			b[4:0] <= b[4:0] + (ben ? 1'b1 : 1'b0);
		end
	end
end

// I2S.NET (72) - bresl : an2h
// I2S.NET (73) - i2s3wl : iv
assign bresl = resetl & ~i2s3w;

// I2S.NET (77) - wsod0 : nd3
// I2S.NET (82) - bl[4] : iv
assign wsod0 = ~(ben & b[4:0]==5'b01111 & wsen); // bco[3} == ben & b[3:0]==f

// I2S.NET (78) - wsod1 : nd2
// I2S.NET (81) - notbco[3] : iv
assign wsod1 = ~(wsout_obuf & ~(ben & b[3:0]==4'b1111));

// I2S.NET (79) - wsod : nd2
assign wsod = ~(wsod0 & wsod1);

// I2S.NET (80) - wsi : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			wsout_obuf <= 1'b0;
		end else begin
			wsout_obuf <= wsod;
		end
	end
end

// I2S.NET (87) - scks : mx2p
assign scks = (i2sen) ? sckout : sckin;

// I2S.NET (88) - sck : nivu
assign sck = scks;

// I2S.NET (89) - sckl : ivh
assign sckl = ~scks;

// I2S.NET (108) - wss : mx2p
// I2S.NET (109) - ws : nivh
// I2S.NET (110) - wsl : iv
assign wss = (i2sen) ? wsout_obuf : wsin;

// I2S.NET (111) - ws[0] : fd2
// I2S.NET (112) - ws[1] : fd2
reg old_sck;
always @(posedge sys_clk)
begin
	old_sck <= sck;
	if ((~old_sck && sck) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			ws[1:0] <= 2'h0;
		end else begin
			ws[1:0] <= {ws[0],wss};
		end
	end
end

// I2S.NET (113) - wsp0 : nd3
assign wsp0 = ~(ws[0] & ~ws[1] & rising);

// I2S.NET (114) - wsp1 : nd3
assign wsp1 = ~(~ws[0] & ws[1] & falling);

// I2S.NET (115) - wsp2 : nd2
assign wsp2 = ~(msb & everyword);

// I2S.NET (116) - wsp : nd3
assign wsp = ~(wsp0 & wsp1 & wsp2);

//I2S.NET (117) - i2sint : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		i2int_ <= wsp;
	end
end

// I2S.NET (122) - bci[0] : upcnt1s
// I2S.NET (123) - bci[1-3] : upcnt1s
// I2S.NET (125) - bcl[0-3] : ivm
// I2S.NET (126) - bc[0-3] : ivm
always @(posedge sys_clk)
begin
	if (~old_sck && sck) begin
		if (~bcresl) begin
			bc[3:0] <= 4'h0;
		end else if (bcen) begin
			bc[3:0] <= bc[3:0] + 1'b1;
		end
	end
end

// I2S.NET (128) - bcres0 : nd2
assign bcres0 = ~(~ws[0] & wss);

// I2S.NET (129) - bcres1 : nd3
assign bcres1 = ~(ws[0] & ~wss & mode16);

// I2S.NET (130) - bcres2 : nd2
assign bcres2 = ~(lsb & mode32);

// I2S.NET (131) - bcresl : an4p
assign bcresl = bcres0 & bcres1 & bcres2 & resetl;

// I2S.NET (133) - bcen : nd2
assign bcen = ~(mode16 & ov);

// I2S.NET (137) - ovd0 : nd2
assign ovd0 = ~(ov & bcresl);

// I2S.NET (138) - ovd1 : nd3
assign ovd1 = ~(lsb & mode16 & bcresl);

// I2S.NET (139) - ovd : nd2
assign ovd = ~(ovd0 & ovd1);

// I2S.NET (140) - ov : fd1q
always @(posedge sys_clk)
begin
	if (~old_sck && sck) begin
		ov <= ovd;
	end
end

// I2S.NET (141) - ovl : ivh
assign ovl = ~ov;

// I2S.NET (146) - leftd0 : nd2
assign leftd0 = ~(~ws[0] & wss);

// I2S.NET (147) - leftd1 : nd2
assign leftd1 = ~(left & notlsb);

// I2S.NET (148) - leftd2 : nd2
assign leftd2 = ~(right & lsb);

// I2S.NET (149) - leftd : nd3
assign leftd = ~(leftd0 & leftd1 & leftd2);

// I2S.NET (150) - left : fd1q
always @(posedge sys_clk)
begin
	if (~old_sck && sck) begin
		left <= leftd;
	end
end

// I2S.NET (151) - right : iv
assign right = ~left;

// I2S.NET (153) - ll : mx2
assign ll = (mode32) ? left : ~ws[0];

// I2S.NET (154) - rr : ivh
assign rr = ~ll;

// I2S.NET (158) - bit[14] : an6
assign bit_[14:0] = (ovl & bc[3:0] != 4'h0) ? (15'h1 << (~bc[3:0])) : 15'h0;

// I2S.NET (176) - msbl : ivh
assign msbl = ~msb;

// I2S.NET (177) - lsb : niv
assign lsb = bit_[0];

// I2S.NET (178) - notlsb : iv
assign notlsb = ~lsb;

// I2S.NET (182) - msbd : nr2
assign msbd = ~(ovd | bcresl);

// I2S.NET (183) - msbi : fd1q
always @(posedge sys_clk)
begin
	if (~old_sck && sck) begin
		msbi <= msbd;
	end
end

// I2S.NET (184) - msb : nivh
assign msb = msbi;

// I2S.NET (188) - sd[15] : slatch
// I2S.NET (189) - sd[0-14] : slatchr
always @(posedge sys_clk)
begin
	if (~old_sck && sck) begin
		if (msb) begin
			sd[15] <= i2rxd;
			sd[14:0] <= 15'h0;
		end else begin
			sd[14:0] <= (bit_[14:0] & {15{i2rxd}}) | (~bit_[14:0] & sd[14:0]); // if bc[]!=0 then sd[~bc[]] <= i2rxd;
		end
	end
end


// I2S.NET (193) - lrd[0-15] : slatch
// I2S.NET (194) - rrd[0-15] : slatch
always @(posedge sys_clk)
begin
	if (~old_sck && sck) begin
		if (trrd) begin
			lrd[15:0] <= sd[15:0];
		end
		if (trld) begin
			rrd[15:0] <= sd[15:0];
		end
	end
end

// I2S.NET (195) - trrd : an2h
assign trrd = msb & ll;

// I2S.NET (196) - trld : an2h
assign trld = msb & rr;

// I2S.NET (200) - drr[0-15] : ts
assign drr_out[15:0] = rrd[15:0];
assign drr_oe = i2s1r;

// I2S.NET (201) - drl[0-15] : ts
assign drl_out[15:0] = lrd[15:0];
assign drl_oe = i2s2r;

// I2S.NET (205) - drws : ts
// I2S.NET (206) - drleft : ts
// I2S.NET (207) - dru[2-15] : ts
assign drws_out[15:0] = {14'h0,left,wss};
assign drws_oe = i2s3r;

// I2S.NET (213) - dpl[0-15] : slatch
// I2S.NET (214) - dpr[0-15] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (i2s1w) begin
			dpl[15:0] <= din[15:0];
		end
		if (i2s2w) begin
			dpr[15:0] <= din[15:0];
		end
	end
end

// I2S.NET (215) - dp[0-15] : mx2
assign dp[15:0] = (rr) ? dpr[15:0] : dpl[15:0];

// I2S.NET (219) - ds[0] : mx2
// I2S.NET (220) - ds[1-15] : mx2
assign ds[15:0] = (msb) ? dp[15:0] : {qs[14:0],1'b0};

// I2S.NET (222) - qs[0-15] : fd1q
always @(posedge sys_clk)
begin
	if (old_sck && ~sck) begin // sckl = negedge
		qs[15:0] <= ds[15:0];
	end
end

// I2S.NET (223) - i2txd : join
assign i2txd = qs[15];

// I2S.NET (227) - i2sen : slatchc
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			i2sen_obuf <= 1'b0;
		end else begin
			if (i2s4w) begin
				i2sen_obuf <= din[0];
			end
		end
	end
end

// I2S.NET (228) - mode32 : slatch
// I2S.NET (229) - wsen : slatch
// I2S.NET (230) - rising : slatch
// I2S.NET (231) - falling : slatch
// I2S.NET (232) - everyword : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (i2s4w) begin
			mode32 <= din[1];
			wsen <= din[2];
			rising <= din[3];
			falling <= din[4];
			everyword <= din[5];
		end
	end
end

// I2S.NET (234) - mode16 : iv
assign mode16 = ~mode32;

// I2S.NET (240) - snd_l : join
assign snd_l[15:0] = dpl[15:0];

// I2S.NET (241) - snd_r : join
assign snd_r[15:0] = dpr[15:0];

// I2S.NET (242) - snd_l_en : niv
assign snd_l_en = i2s1w;

// I2S.NET (243) - snd_r_en : niv
assign snd_r_en = i2s2w;

// --- Compiler-generated PE for BUS dr[0]
assign dr_out[15:0] = (drr_oe ? drr_out[15:0] : 16'h0) | (drl_oe ? drl_out[15:0] : 16'h0) | (drws_oe ? drws_out[15:0] : 16'h0);
assign dr_oe = drr_oe | drl_oe | drws_oe;

endmodule
