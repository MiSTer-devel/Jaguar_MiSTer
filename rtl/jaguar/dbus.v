//`include "defs.v"
// altera message_off 10036

module _dbus
(
	input [63:0] din,
	input [15:0] dr,
	input [7:0] dinlatch,
	input [2:0] dmuxd,
	input [2:0] dmuxu,
	input dren,
	input xdsrc,
	input ourack,
	input [63:0] wd,
	input clk,
	output [15:0] dp,
	output [15:0] dob,
	output [31:16] dout,
	output [63:32] d5,
	output [63:0] d,
	input sys_clk // Generated
);
wire [15:0] d3i;
wire [63:0] d3;
wire [63:8] d4;
reg [31:0] d5_ = 32'h00000000;
wire [15:0] dout_;
wire [7:0] vd;

// Output buffers
wire [31:16] dout_obuf;
reg [63:32] d5_obuf = 32'h00000000;

// Output buffers
assign dout[31:16] = dout_obuf[31:16];
assign d5[63:32] = d5_obuf[63:32];

// DBUS.NET (53) - d3i[0-15] : mx4
assign d3i[15:0] = xdsrc ? (din[15:0]) : (dren ? dr[15:0] : wd[15:0]);

// DBUS.NET (54) - d3[0-15] : niv
assign d3[15:0] = d3i[15:0];

// DBUS.NET (55) - d3[16-63] : mx2
assign d3[63:16] = (xdsrc) ? din[63:16] : wd[63:16];

// DBUS.NET (59) - d4 : up
_up d4_inst
(
	.din /* IN */ (d3[63:0]),
	.dmuxu /* IN */ (dmuxu[2:0]),
	.dout /* OUT */ (d4[63:8])
);

// DBUS.NET (63) - d5[0-7] : stlatch
reg [63:0] stdata = 64'h0000000000000000;
always @(posedge sys_clk)
begin
	if (dinlatch[0]) begin
		d5_[7:0] <= d3[7:0];
	end else begin
		d5_[7:0] <= stdata[7:0];
	end

	if (clk) begin
		if (dinlatch[0]) begin
			stdata[7:0] <= d3[7:0];
		end
	end
end

// DBUS.NET (64) - d5[8-15] : stlatch
always @(posedge sys_clk)
begin
	if (dinlatch[1]) begin
		d5_[15:8] <= d4[15:8];
	end else begin
		d5_[15:8] <= stdata[15:8];
	end

	if (clk) begin
		if (dinlatch[1]) begin
			stdata[15:8] <= d4[15:8];
		end
	end
end

// DBUS.NET (65) - d5[16-23] : stlatch
always @(posedge sys_clk)
begin
	if (dinlatch[2]) begin
		d5_[23:16] <= d4[23:16];
	end else begin
		d5_[23:16] <= stdata[23:16];
	end

	if (clk) begin
		if (dinlatch[2]) begin
			stdata[23:16] <= d4[23:16];
		end
	end
end

// DBUS.NET (66) - d5[24-31] : stlatch
always @(posedge sys_clk)
begin
	if (dinlatch[3]) begin
		d5_[31:24] <= d4[31:24];
	end else begin
		d5_[31:24] <= stdata[31:24];
	end

	if (clk) begin
		if (dinlatch[3]) begin
			stdata[31:24] <= d4[31:24];
		end
	end
end

// DBUS.NET (67) - d5[32-39] : stlatch
always @(posedge sys_clk)
begin
	if (dinlatch[4]) begin
		d5_obuf[39:32] <= d4[39:32];
	end else begin
		d5_obuf[39:32] <= stdata[39:32];
	end

	if (clk) begin
		if (dinlatch[4]) begin
			stdata[39:32] <= d4[39:32];
		end
	end
end

// DBUS.NET (68) - d5[40-47] : stlatch
always @(posedge sys_clk)
begin
	if (dinlatch[5]) begin
		d5_obuf[47:40] <= d4[47:40];
	end else begin
		d5_obuf[47:40] <= stdata[47:40];
	end

	if (clk) begin
		if (dinlatch[5]) begin
			stdata[47:40] <= d4[47:40];
		end
	end
end

// DBUS.NET (69) - d5[48-55] : stlatch
always @(posedge sys_clk)
begin
	if (dinlatch[6]) begin
		d5_obuf[55:48] <= d4[55:48];
	end else begin
		d5_obuf[55:48] <= stdata[55:48];
	end

	if (clk) begin
		if (dinlatch[6]) begin
			stdata[55:48] <= d4[55:48];
		end
	end
end

// DBUS.NET (70) - d5[56-63] : stlatch
always @(posedge sys_clk)
begin
	if (dinlatch[7]) begin
		d5_obuf[63:56] <= d4[63:56];
	end else begin
		d5_obuf[63:56] <= stdata[63:56];
	end

	if (clk) begin
		if (dinlatch[7]) begin
			stdata[63:56] <= d4[63:56];
		end
	end
end

// DBUS.NET (92) - dout : down
_down dout_inst
(
	.din /* IN */ ({d5_obuf[63:32], d5_[31:0]}),
	.dmuxd /* IN */ (dmuxd[2:0]),
	.dout /* OUT */ ({dout_obuf[31:16], dout_[15:0]})
);

// DBUS.NET (96) - d[0-31] : nivm
assign d[15:0] = dout_[15:0];
assign d[31:16] = dout_obuf[31:16];

// DBUS.NET (97) - d[32-63] : nivm
assign d[63:32] = d5_obuf[63:32];

// DBUS.NET (101) - vd[0-5] : mx2
// DBUS.NET (102) - vd[6] : mx2
// DBUS.NET (103) - vd[7] : mx2
assign vd[7:0] = (ourack) ? 8'h40 : dout_[7:0];

// DBUS.NET (110) - dob[0-7] : nivu2
assign dob[7:0] = vd[7:0];

// DBUS.NET (111) - dob[8-9] : nivu2
// DBUS.NET (112) - dob[10-15] : nivu
assign dob[15:8] = dout_[15:8];

// DBUS.NET (113) - dp[0-7] : niv
assign dp[7:0] = vd[7:0];

// DBUS.NET (114) - dp[8-15] : niv
assign dp[15:8] = dout_[15:8];
endmodule

