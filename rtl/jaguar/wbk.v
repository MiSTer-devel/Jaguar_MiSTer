//`include "defs.v"
// altera message_off 10036

module _wbk
(
	input [63:0] d,// only d[23:14] and d[63:43] used
	input obld_0,
	input obld_2,
	input [9:0] dwidth,
	input [7:0] vscale,
	input clk,
	input resetl,
	input scaled,
	input wbkstart,
	output [20:0] newdata,
	output [9:0] newheight,
	output [7:0] newrem,
	output heightnz,
	output wbkdone,
	input sys_clk // Generated
);

reg [2:0] q = 3'h1;
wire [2:0] d_;
wire d00;
wire d01;
wire d02;
wire d03;
wire d20;
wire d21;
wire notwbkstart;
wire notscaled;
wire heightz;
wire intremnz;
wire intremz;
wire decheight;
wire addnewdata;
wire addrem;
wire decrem;
wire intremz0;
wire [8:0] rd;
wire [8:0] rs;
wire [8:0] rc;
wire [8:0] rem;
wire latchrem;
wire latchremi;
wire heightz0;
wire heightz1;
wire [20:0] ds;
wire [20:0] data;
wire newdataclk;
wire latchdata;

// Output buffers
reg [20:0] newdata_obuf = 20'h00000;
reg [9:0] newheight_obuf = 10'h0;
reg [8:0] newrem_obuf = 9'h000;
wire heightnz_obuf;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign heightnz = heightnz_obuf;

// WBK.NET (23) - newrem : join
assign newrem[7:0] = newrem_obuf[7:0]; //newrem 8 does not output

// WBK.NET (25) - newheight : join
assign newheight[9:0] = newheight_obuf[9:0];

// WBK.NET (27) - newdata : join
assign newdata[20:0] = newdata_obuf[20:0];

// WBK.NET (45) - q0 : fd4q
// WBK.NET (46) - q1 : fd2q
// WBK.NET (47) - q2 : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd4q and fd2q always @(posedge cp or negedge sd)
		if (~resetl) begin
			q[2:0] <= 3'h1;
		end else begin
			q[2:0] <= d_[2:0];
		end
	end
end

// WBK.NET (49) - d00 : nd2
assign d00 = ~(q[0] & notwbkstart);

// WBK.NET (50) - d01 : nd2
assign d01 = ~(q[1] & notscaled);

// WBK.NET (51) - d02 : nd2
assign d02 = ~(q[2] & heightz);

// WBK.NET (52) - d03 : nd2
assign d03 = ~(q[2] & intremnz);

// WBK.NET (53) - d0 : nd4
assign d_[0] = ~(d00 & d01 & d02 & d03);

// WBK.NET (55) - d1 : an2
assign d_[1] = q[0] & wbkstart;

// WBK.NET (57) - d20 : nd2
assign d20 = ~(q[1] & scaled);

// WBK.NET (58) - d21 : nd3
assign d21 = ~(q[2] & heightnz_obuf & intremz);

// WBK.NET (59) - d2 : nd2
assign d_[2] = ~(d20 & d21);

// WBK.NET (61) - wbkdone : nivh
assign wbkdone = q[0];

// WBK.NET (63) - decheight : nd2
assign decheight = ~(d01 & d21);

// WBK.NET (64) - addnewdata : nd2
assign addnewdata = ~(d01 & d21);

// WBK.NET (65) - addrem : iv
assign addrem = ~d21;

// WBK.NET (66) - decrem : ivm
assign decrem = ~d20;

// WBK.NET (68) - notwbkstart : iv
assign notwbkstart = ~wbkstart;

// WBK.NET (69) - notscaled : iv
assign notscaled = ~scaled;

// WBK.NET (73) - intremz0 : nr4
assign intremz0 = ~(|newrem_obuf[8:5]);

// WBK.NET (74) - intremz : or2
assign intremz = intremz0 | newrem_obuf[8];

// WBK.NET (75) - intremnz : iv
assign intremnz = ~intremz;

// WBK.NET (83) - rd[0-4] : mx2
// WBK.NET (84) - rd[5-7] : mx2
// WBK.NET (85) - rd[8] : niv
assign rd[7:0] = (decrem) ? 8'hE0 : vscale[7:0]; // e0 is -1 rem
assign rd[8] = decrem;

// WBK.NET (87) - rs[0] : ha1
assign rs[8:0] = newrem_obuf[8:0] + rd[8:0];

// WBK.NET (92) - rem[0-7] : mx2
// WBK.NET (93) - rem[8] : mx2
assign rem[8:0] = (obld_2) ? {1'b0, d[23:16]} : rs[8:0];

// WBK.NET (95) - newrem[0-8] : slatch
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (latchrem) begin
			newrem_obuf[8:0] <= rem[8:0];
		end
	end
end

// WBK.NET (97) - latchremi : nr3
assign latchremi = ~(obld_2 | addrem | decrem);

// WBK.NET (98) - latchrem : ivm
assign latchrem = ~latchremi;

// WBK.NET (103) - newheighti[0] : dncnt
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin // fd2q always @(posedge cp or negedge cd)
		if (~resetl) begin
			newheight_obuf[9:0] <= 10'h0;
		end else if (obld_0) begin
			newheight_obuf[9:0] <= d[23:14];
		end else if (decheight) begin
			newheight_obuf[9:0] <= newheight_obuf[9:0] - 10'h1;
		end
	end
end

// WBK.NET (108) - heightz0 : nr6
assign heightz0 = ~(|newheight_obuf[5:0]);

// WBK.NET (109) - heightz1 : nr4
assign heightz1 = ~(|newheight_obuf[9:6]);

// WBK.NET (110) - heightnz : nd2
assign heightnz_obuf = ~(heightz0 & heightz1);

// WBK.NET (111) - heightz : iv
assign heightz = ~heightnz_obuf;

// WBK.NET (118) - ds[0] : add4
assign ds[20:0] = newdata_obuf[20:0] + dwidth[9:0];

// WBK.NET (126) - data[0-20] : mx4p
assign data[20:0] = (~newdataclk) ? newdata_obuf[20:0] : (obld_0 ? d[63:43] : ds[20:0]);

// WBK.NET (128) - newdata[0-10] : fd1q
// WBK.NET (129) - newdatai[11-15] : fd1q
// WBK.NET (130) - newdata[16-20] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		newdata_obuf[20:0] <= data[20:0];
	end
end

// WBK.NET (133) - latchdata : or2
assign latchdata = obld_0 | addnewdata;

// WBK.NET (134) - newdataclk : nivh
assign newdataclk = latchdata;

endmodule

