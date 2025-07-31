//`include "defs.v"

module _divider
(
	output [31:0] gpu_data_out,
	output gpu_data_oe,
	output div_activei,
	output [31:0] quotient,
	input clk,
	input div_start,
	input divwr,
	input [31:0] dstd,
	input [31:0] gpu_din,
	input remrd,
	input reset_n,
	input [31:0] srcd,
	input sys_clk // Generated
);
wire [31:0] divhit;
reg [31:0] dividend_hi = 32'h0;
wire [31:0] addq1;
wire [31:0] divein;
reg [31:0] dividend_lo = 32'h0;
reg [31:0] divisor = 32'h0;
wire [31:0] dend1;
wire [31:0] divr1;
wire [31:0] dend2;
wire [31:0] divr2;
wire [31:0] addq2;
reg div_offsett = 1'b0;
wire div_offset;
reg last_neg_n = 1'b0;
wire carry1;
wire unused_0;
wire unused_1;
wire thisnegt;
wire thisneg;
wire addq1_32;
wire carry2;
wire unused_3;
wire unused_4;
wire addq2_32;
wire lnegt_n;
wire dhlsel_0;
wire diveif0;
wire quosh_1;
wire quoti_0;
reg [31:0] quotient_ = 32'h0;
wire cnten;
wire [3:0] cntt;
reg [3:0] count = 4'h0;
wire [3:0] cnti;
wire cnt_zero_n;
wire dat_0;
reg div_active = 1'b0;

wire resetl = reset_n; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
wire div_activei_obuf;

// Output buffers
assign div_activei = div_activei_obuf;

// DIVIDE.NET (78) - div_offsett : fdsyncr
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			div_offsett <= 1'b0;
		end else begin
			if (divwr) begin
				div_offsett <= gpu_din[0];
			end
		end
	end
end

// DIVIDE.NET (80) - div_offset : nivh
assign div_offset = div_offsett;

// DIVIDE.NET (83) - dend1 : join
assign dend1[0] = dividend_lo[31];
assign dend1[31:1] = dividend_hi[30:0];

// DIVIDE.NET (85) - divr1[0-5] : eop
// DIVIDE.NET (86) - divr1[6-11] : eop
// DIVIDE.NET (87) - divr1[12-17] : eop
// DIVIDE.NET (89) - divr1[18-23] : eop
// DIVIDE.NET (91) - divr1[24-29] : eop
// DIVIDE.NET (93) - divr1[30-31] : eop
assign divr1[31:0] = divisor[31:0] ^ {32{last_neg_n}};

// DIVIDE.NET (98) - adder1 : fa32_int
assign {carry1,addq1[31:0]} = {1'b0,dend1[31:0]} + divr1[31:0] + (last_neg_n ? 1'b1 : 1'b0);

// DIVIDE.NET (112) - this_negt : nd4p
assign thisneg = (dividend_hi[31] ^ carry1 ^ last_neg_n);

// DIVIDE.NET (119) - adder1_33 : join
assign addq1_32 = thisneg;

// DIVIDE.NET (123) - dend2 : join
assign dend2[0] = dividend_lo[30];
assign dend2[31:1] = addq1[30:0];

// DIVIDE.NET (135) - divr2 : eop
assign divr2[31:0] = divisor[31:0] ^ {32{~thisneg}};

// DIVIDE.NET (137) - adder2 : fa32_int
assign {carry2,addq2[31:0]} = {1'b0,dend2[31:0]} + divr2[31:0] + (~thisneg ? 1'b1 : 1'b0);

// DIVIDE.NET (139) - adder2_33 : fa1p
assign addq2_32 = addq1[31] ^ carry2 ^ ~thisneg;

// DIVIDE.NET (164) - lnegt0 : an4p
assign lnegt_n = ~((addq1[31] ^ carry2 ^ ~thisneg) & div_active);

// DIVIDE.NET (165) - last_neg\[0-2] : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		last_neg_n <= lnegt_n;
	end
end

// DIVIDE.NET (188) - dhlsel[0] : mx2h
assign dhlsel_0 = (div_start) ? div_offset : div_active;

// DIVIDE.NET (190) - divhit[0-15] : mx4
assign divhit[15:0] = div_start ? (dhlsel_0 ? dstd[31:16] : 16'h0) : (dhlsel_0 ? addq2[15:0] : dividend_hi[15:0]);

// DIVIDE.NET (193) - divhit[16-31] : mx2g
assign divhit[31:16] = div_start ? (16'h0) : (div_active ? addq2[31:16] : dividend_hi[31:16]);

// DIVIDE.NET (197) - dividend_hi : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		dividend_hi[31:0] <= divhit[31:0];
	end
end

// DIVIDE.NET (198) - remrd : ts
assign gpu_data_out[31:0] = dividend_hi[31:0];
assign gpu_data_oe = remrd;

// DIVIDE.NET (207) - diveif0 : an2h
assign diveif0 = div_start & div_offset;

// DIVIDE.NET (208) - divein[0-1] : mx2g
// DIVIDE.NET (210) - divein[2-15] : mx2g
assign divein[1:0] = diveif0 ? (2'h0) : (div_start ? dstd[1:0] : 2'h0);
assign divein[15:2] = diveif0 ? (14'h0) : (div_start ? dstd[15:2] : dividend_lo[13:0]);

// DIVIDE.NET (212) - divein[16-31] : mx4
assign divein[31:16] = div_offset ? (div_start ? dstd[15:0] : dividend_lo[29:14]) : (div_start ? dstd[31:16] : dividend_lo[29:14]);

// DIVIDE.NET (216) - dividend_lo : fd1qp
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		dividend_lo[31:0] <= divein[31:0];
	end
end

// DIVIDE.NET (223) - divisor : fdsync32
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (div_start) begin
			divisor[31:0] <= srcd[31:0];
		end
	end
end

// DIVIDE.NET (230) - quosh[1] : iv
assign quosh_1 = ~addq1_32;

// DIVIDE.NET (231) - quoti[0] : mxi2
assign quoti_0 = div_active ? ~addq2_32 : quotient_[0];

// DIVIDE.NET (233) - quotient[0] : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		quotient_[0] <= quoti_0;
	end
end

// DIVIDE.NET (234) - quotient[1] : fdsync
// DIVIDE.NET (236) - quotient[2-31] : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (div_active) begin
			quotient_[1] <= quosh_1;
			quotient_[31:2] <= quotient_[29:0];
		end
	end
end


// DIVIDE.NET (238) - quotient : join
assign quotient[31:0] = quotient_[31:0];

// DIVIDE.NET (245) - cnten : or2
assign cnten = div_active | div_start;

// DIVIDE.NET (249) - cntt0 : iv
// DIVIDE.NET (250) - cntt1 : ha1
// DIVIDE.NET (251) - cntt2 : ha1
// DIVIDE.NET (252) - cntt3 : eo
assign cntt[3:0] = count[3:0] + 4'h1;

// DIVIDE.NET (254) - cnti[0-3] : an2
assign cnti[3:0] = cnten ? cntt[3:0] : 4'h0;

// DIVIDE.NET (255) - count[0-3] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		count[3:0] <= cnti[3:0];
	end
end

// DIVIDE.NET (257) - cnt_zero : or4
assign cnt_zero_n = |count[3:0];

// DIVIDE.NET (259) - dat0 : nd2
assign dat_0 = ~(div_active & cnt_zero_n);

// DIVIDE.NET (260) - dat1 : nd2
assign div_activei_obuf = ~(~div_start & dat_0);

// DIVIDE.NET (261) - div_active : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			div_active <= 1'b0;
		end else begin
			div_active <= div_activei_obuf;
		end
	end
end

endmodule
