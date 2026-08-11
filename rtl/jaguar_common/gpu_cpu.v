//`include "defs.v"

module _gpu_cpu
(
	output [15:0] dread_out,
	output dread_oe,
	output [12:0] cpuaddr,
	output [31:0] cpudata,
	output ioreq,
	input at_1, // tom only
	input a_15, // tom only
	input ack, // tom only
	input big_io,
	input clk_0,
	input clk_2,
	input [31:0] dwrite, // dwrite[31:16] tom only
	input [15:0] io_addr,
	input iord,
	input iowr,
	input [31:0] mem_data,
	input reset_n,
	input sys_clk // Generated
);
parameter JERRY = 0;

wire [15:0] cpudlo;
wire [15:0] cpudhi;
wire [15:0] cpudhit;
wire [15:0] dreadt;
wire [15:0] dwritelo;
wire [15:0] dwritehi;
wire [15:0] gpudlo;
wire [15:0] gpudhi;
reg [15:0] lodata = 16'h0;
reg [15:0] latrdata = 16'h0;
wire [15:0] latrdatai;
wire [15:0] immrdata;
wire io_addr_n_1;
wire at_n_1;
wire at_15;
reg atl_15 = 1'b0;
wire iorqt_0;
wire iorqt_2;
wire iorqt_1;
reg rden = 1'b0;
reg rdenp = 1'b0;
reg iowrite = 1'b0;
wire lodld;
wire lodsel;
wire hidld;
wire dreaden;

wire resetl = reset_n; 
wire clk = clk_0; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// GPU_CPU.NET (50) - dwritelo : join
assign dwritelo[15:0] = dwrite[15:0];

// GPU_CPU.NET (51) - dwritehi : join
assign dwritehi[15:0] = dwrite[31:16];

// GPU_CPU.NET (52) - gpudlo : join
assign gpudlo[15:0] = mem_data[15:0];

// GPU_CPU.NET (53) - gpudhi : join
assign gpudhi[15:0] = mem_data[31:16];

// GPU_CPU.NET (54) - io_addr\[1] : iv
assign io_addr_n_1 = ~io_addr[1];

// GPU_CPU.NET (59) - at\[1] : iv
assign at_n_1 = ~at_1;

// GPU_CPU.NET (60) - at[15] : mx2
assign at_15 = (ack) ? a_15 : atl_15;

// GPU_CPU.NET (61) - atl[15] : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		atl_15 <= at_15;
	end
end

// GPU_CPU.NET (67) - iorqt0 : nd2
assign iorqt_0 = ~(iord & (JERRY!=0 ? ~io_addr[1] : at_n_1));

// GPU_CPU.NET (68) - iorqt2 : or2
assign iorqt_2 = at_1 | at_15;

// GPU_CPU.NET (69) - iorqt1 : nd2
assign iorqt_1 = ~(iowr & (JERRY!=0 ? io_addr[1] : iorqt_2));

// GPU_CPU.NET (70) - ioreq : nd2
assign ioreq = ~(iorqt_0 & iorqt_1);

// GPU_CPU.NET (74) - rden : fd2q
// GPU_CPU.NET (75) - rdenp : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			rden <= 1'b0;
			rdenp <= 1'b0;
		end else begin
			rden <= iord;
			rdenp <= rden;
		end
	end
end

// GPU_CPU.NET (76) - iowrite : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		iowrite <= iowr;
	end
end

// GPU_CPU.NET (86) - lodld : an3h
assign lodld = iowrite & clk_2 & io_addr_n_1;

// GPU_CPU.NET (87) - lodata : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (lodld) begin
		lodata[15:0] <= dwritelo[15:0];
	end
	if ((~resetl & (old_resetl | lodld)) & JERRY!=0) begin
		lodata[15:0] <= 16'h0;
	end
end

// GPU_CPU.NET (89) - lodsel : or2_h
assign lodsel = big_io | (JERRY!=0 ? 1'b0 : io_addr[15]);

// GPU_CPU.NET (90) - cpudlo : mx2
assign cpudlo[15:0] = (lodsel) ? dwritelo[15:0] : lodata[15:0];

// GPU_CPU.NET (91) - cpudhit : mx2
assign cpudhit[15:0] = (big_io) ? lodata[15:0] : dwritelo[15:0];

// GPU_CPU.NET (92) - cpudhi : mx2
assign cpudhi[15:0] = (io_addr[15] & (JERRY==0)) ? dwritehi[15:0] : cpudhit[15:0];

// GPU_CPU.NET (93) - cpudata : join
assign cpudata[15:0] = cpudlo[15:0];
assign cpudata[31:16] = cpudhi[15:0];

// GPU_CPU.NET (95) - cpuaddr[2-14] : niv
assign cpuaddr[12:0] = io_addr[14:2];

// GPU_CPU.NET (103) - latrdld : an3h
assign hidld = rdenp & clk_2 & io_addr_n_1;

// GPU_CPU.NET (104) - latrdatai : mx2
assign latrdatai[15:0] = (big_io) ? gpudlo[15:0] : gpudhi[15:0];

// GPU_CPU.NET (105) - latrdata : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (hidld) begin
		latrdata[15:0] <= latrdatai[15:0];
	end
end

// GPU_CPU.NET (108) - immrdatai : mx2
assign immrdata[15:0] = (big_io) ? gpudhi[15:0] : gpudlo[15:0];

// GPU_CPU.NET (110) - dreadt : mx2
assign dreadt[15:0] = (io_addr[1]) ? latrdata[15:0] : immrdata[15:0];

// GPU_CPU.NET (111) - dreaden : or2_h
assign dreaden = rden | rdenp;

// GPU_CPU.NET (112) - dread : tsm
assign dread_out[15:0] = dreadt[15:0];
assign dread_oe = dreaden;
endmodule
