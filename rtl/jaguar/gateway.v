//`include "defs.v"
// altera message_off 10036

module _gateway
(
	output [23:0] address_out,
	output address_oe,	// ElectronAsh.
	output [63:0] wdata_out, // tom only
	output wdata_31_0_oe, // tom only
	output wdata_63_32_oe, // tom only
	output [31:0] gpu_data_out,
	output gpu_data_oe,
	output justify_out, // tom only
	output justify_oe, // tom only
	output mreq_out,
	output mreq_oe, // tom only
	output read_out,
	output read_oe, // tom only
	output [3:0] width_out, // width[3] tom only
	output width_oe, // tom only
	output gpu_dout_15_out,
	output gpu_dout_15_oe,
	output dma_breq, // tom only
	output dma_breq_n, // jerry only
	output gate_active,
	output gatereq,
	output gpu_breq, // tom only
	output gpu_breq_n, // jerry only
	output [31:0] load_data,
	output xld_ready,
	input ack,
	input bus_hog,
	input clk_0,
	input clk_2, // = tlw 
	input [63:0] data, // data[63:32] tom only
	input external,
	input flagrd,
	input flagwr,
	input gateack,
	input [23:0] gpu_addr,
	input gpu_back, // tom only
//	input gpu_back_n, //jerry only - use gpu_back with inverter
	input [31:0] gpu_din,
	input gpu_memw,
	input hidrd, // tom only
	input hidwr, // tom only
	input [1:0] msize,
	input progserv,
	input reset_n,
	input sys_clk // Generated
);
parameter JERRY = 0;

wire [23:0] out_addr;
reg [23:0] cpu_addr = 24'h0;
reg [23:0] dat_addr = 24'h0;
wire [31:0] hidin;
wire [31:0] hidatai;
reg [31:0] hirdata = 32'h0;
wire [31:0] lddatai;
wire [31:0] lodatai;
wire [31:0] lodin;
reg [31:0] prog_data = 32'h0;
wire ack_n;
wire external_n;
wire gateack_n;
wire gpu_memw_n;
wire progserv_n;
wire one;
reg dmaen = 1'b0;
wire dmaen_n;
wire [2:1] prot;
wire active;
wire gpu_ack;
wire cycgo;
wire idle;
wire cycstart;
wire progoi;
reg progown = 1'b0;
reg progownp = 1'b0;
reg cycpend = 1'b0;
wire progown_n;
reg readp = 1'b0;
wire readi;
reg reada = 1'b0;
wire reada_n;
wire msizelat;
reg [1:0] msized = 2'b00;
wire cyptset;
wire [1:0] cypt;
wire [3:0] activet;
wire gpu_ack_n;
reg activet_ = 1'b0;
wire pawset_n;
wire [1:0] pawt;
reg packwt = 1'b0;
wire pdatld;
wire [2:0] greqt;
wire dawset_n;
wire [1:0] dawt;
reg dackwt = 1'b0;
wire ddatld;
wire busack;
wire tri_en;
wire cald;
wire dald;
wire [1:0] msizet;
wire [3:0] widt;
wire pdatstrb;
wire lodwr;
wire lodstrbt;
wire lodstrb;
wire maskwt_n;
wire maskbt_n;
wire maskld;
reg maskb_n = 1'b0;
reg maskw_n = 1'b0;
wire [31:8] lodm;
wire ddatldb;
wire hidwrb;
wire wdlat;
reg wden = 1'b0;
wire [1:0] wdenb;
wire [5:0] ext_reqt;
wire ext_req_n;
wire [2:0] gpu_bt;

// Output buffers
wire dma_breq_obuf;
wire gpu_breq_obuf;
reg [31:0] load_data_obuf = 32'h0;

wire clk = clk_0;
wire resetl = reset_n;
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign dma_breq = dma_breq_obuf;
assign gpu_breq = gpu_breq_obuf;
assign load_data[31:0] = load_data_obuf[31:0];

// GATEWAY.NET (56) - lodatai : join
assign lodatai[31:0] = data[31:0];

// GATEWAY.NET (57) - hidatai : join
assign hidatai[31:0] = data[63:32];

// GATEWAY.NET (59) - ack\ : iv
assign ack_n = ~ack;

// GATEWAY.NET (60) - external\ : iv
assign external_n = ~external;

// GATEWAY.NET (61) - gateack\ : iv
assign gateack_n = ~gateack;

// GATEWAY.NET (62) - gpu_memw\ : iv
assign gpu_memw_n = ~gpu_memw;

// GATEWAY.NET (63) - progserv\ : iv
assign progserv_n = ~progserv;

// GATEWAY.NET (65) - one : tie1
assign one = 1'b1;

// GATEWAY.NET (70) - dmaen : fdsyncr
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			dmaen <= 1'b0;
		end else begin
			if (flagwr) begin
				dmaen <= gpu_din[15];
			end
		end
	end
end

// GATEWAY.NET (72) - dmaen\ : iv
assign dmaen_n = ~dmaen;

// GATEWAY.NET (73) - dmaenr : ts
assign gpu_dout_15_out = dmaen;
assign gpu_dout_15_oe = flagrd;

// GATEWAY.NET (82) - prot1 : nd3
assign prot[1] = ~(active & gpu_ack & cycgo);

// GATEWAY.NET (83) - prot2 : nd2
assign prot[2] = ~(idle & external);

// GATEWAY.NET (84) - cycstart : nd2
assign cycstart = ~(&prot[2:1]);

// GATEWAY.NET (88) - progoi : mx4
assign progoi = cycstart ? (cycpend ? progownp : progserv) : (progown);

// GATEWAY.NET (90) - progown : fd2qu
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			progown <= 1'b0;
		end else begin
			progown <= progoi;
		end
	end
end

// GATEWAY.NET (91) - progown\ : iv
assign progown_n = ~progown;

// GATEWAY.NET (95) - progownp : fdsync
// GATEWAY.NET (99) - readp : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (external) begin
			progownp <= progserv;
			readp <= gpu_memw_n;
		end
	end
end

// GATEWAY.NET (101) - readi : mx4
assign readi = cycstart ? (cycpend ? readp : gpu_memw_n) : (reada);

// GATEWAY.NET (103) - reada : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		reada <= readi;
	end
end

// GATEWAY.NET (104) - reada\ : iv
assign reada_n = ~reada;

// GATEWAY.NET (108) - msizelat : an3
assign msizelat = external & progserv_n & clk_2;

// GATEWAY.NET (109) - msized[0-1] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (msizelat) begin
		msized[1:0] <= msize[1:0];
	end
end

// GATEWAY.NET (114) - cyptset : nr3
assign cyptset = ~(external_n | idle | cycstart);

// GATEWAY.NET (115) - cypt0 : nr2
assign cypt[0] = ~(cyptset | cycpend);

// GATEWAY.NET (116) - cypt1 : nr2
assign cypt[1] = ~(cypt[0] | cycstart);

// GATEWAY.NET (117) - cycpend : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~reset_n) begin
			cycpend <= 1'b0;
		end else begin
			cycpend <= cypt[1];
		end
	end
end

// GATEWAY.NET (119) - cycgo : or2
assign cycgo = external | cycpend;

// GATEWAY.NET (123) - activet0 : nd2
assign activet[0] = ~(idle & external);

// GATEWAY.NET (124) - activet1 : nd2
assign activet[1] = ~(active & gpu_ack_n);

// GATEWAY.NET (125) - activet2 : nd3
assign activet[2] = ~(active & gpu_ack & cycgo);

// GATEWAY.NET (126) - activet3 : nd3
assign activet[3] = ~(&activet[2:0]);

// GATEWAY.NET (127) - activet : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~reset_n) begin
			activet_ <= 1'b0;
		end else begin
			activet_ <= activet[3];
		end
	end
end

// GATEWAY.NET (128) - active : nivm
assign active = activet_;

// GATEWAY.NET (129) - idle : iv
assign idle = ~active;

// GATEWAY.NET (136) - gate_active : niv
assign gate_active = active;

// GATEWAY.NET (142) - pawset\ : nd3
assign pawset_n = ~(active & progown & gpu_ack);

// GATEWAY.NET (143) - pawt0 : nd2
assign pawt[0] = ~(packwt & ack_n);

// GATEWAY.NET (144) - pawt1 : nd2
assign pawt[1] = ~(pawset_n & pawt[0]);

// GATEWAY.NET (145) - packwt : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~reset_n) begin
			packwt <= 1'b0;
		end else begin
			packwt <= pawt[1];
		end
	end
end

// GATEWAY.NET (146) - pdatld : an2
assign pdatld = packwt & ack;

// GATEWAY.NET (153) - greqt0 : nr2
assign greqt[0] = ~(pdatld | greqt[2]);

// GATEWAY.NET (154) - greqt1 : nr2
assign greqt[1] = ~(gateack | greqt[0]);

// GATEWAY.NET (155) - greqt2 : fd2q
reg greqt_2 = 1'b0;
assign greqt[2] = greqt_2;
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~reset_n) begin
			greqt_2 <= 1'b0;
		end else begin
			greqt_2 <= greqt[1];
		end
	end
end

// GATEWAY.NET (156) - gatereq : oan1
assign gatereq = (pdatld | greqt[2]) & gateack_n;

// GATEWAY.NET (160) - dawset\ : nd4
assign dawset_n = ~(active & progown_n & gpu_ack & reada);

// GATEWAY.NET (161) - dawt0 : nd2
assign dawt[0] = ~(dackwt & ack_n);

// GATEWAY.NET (162) - dawt1 : nd2
assign dawt[1] = ~(dawset_n & dawt[0]);

// GATEWAY.NET (163) - dackwt : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~reset_n) begin
			dackwt <= 1'b0;
		end else begin
			dackwt <= dawt[1];
		end
	end
end

// GATEWAY.NET (164) - ddatld : an2
assign ddatld = dackwt & ack;

// GATEWAY.NET (168) - xld_ready : fd1qu
reg xld_ready_ = 1'b0;
assign xld_ready = xld_ready_;
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		xld_ready_ <= ddatld;
	end
end

// GATEWAY.NET (172) - busack : oan1
assign busack = (gpu_breq_obuf | dma_breq_obuf) & gpu_back;

// GATEWAY.NET (176) - tri_en : nivu
assign tri_en = gpu_back;

// GATEWAY.NET (180) - gpu_ack\ : nd2
assign gpu_ack_n = ~(ack & busack);

// GATEWAY.NET (181) - gpu_ack : iv
assign gpu_ack = ~gpu_ack_n;

// GATEWAY.NET (185) - cald : an3u
assign cald = external & progserv & clk_2;

// GATEWAY.NET (186) - cpu_addr : ldp1q
// GATEWAY.NET (188) - dat_addr : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (cald) begin
		cpu_addr[23:0] <= gpu_addr[23:0];
	end
	if (dald) begin
		dat_addr[23:0] <= gpu_addr[23:0];
	end
end

// GATEWAY.NET (187) - dald : an3u
assign dald = external & progserv_n & clk_2;

// GATEWAY.NET (192) - out_addr : mx2
assign out_addr[23:0] = (progown) ? cpu_addr[23:0] : dat_addr[23:0];

// GATEWAY.NET (193) - address : tsm
assign address_out[23:0] = out_addr[23:0];
assign address_oe = tri_en;	// ElectronAsh.

// GATEWAY.NET (197) - mreq : tsm
assign mreq_out = active;
assign mreq_oe = tri_en;

// GATEWAY.NET (198) - read : ts
assign read_out = reada;
assign read_oe = tri_en;

// GATEWAY.NET (199) - justify : ts
assign justify_out = one;
assign justify_oe = tri_en;

// GATEWAY.NET (204) - msizet[0] : an2
assign msizet[0] = msized[0] & progown_n;

// GATEWAY.NET (205) - msizet[1] : or2
assign msizet[1] = msized[1] | progown;

// GATEWAY.NET (206) - widt : d24h
assign widt[3:0] = 4'b0001 << msizet[1:0];

// GATEWAY.NET (207) - width[0-3] : ts
assign width_out[3:0] = widt[3:0];
assign width_oe = tri_en;

// GATEWAY.NET (211) - pdatstrb : an2u
assign pdatstrb = pdatld & clk_2;

// GATEWAY.NET (212) - prog_data : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
begin
	if (pdatstrb & (JERRY==0)) begin
		prog_data[31:0] <= lodatai[31:0];
	end
	if (~old_clk && clk & (JERRY!=0) & pdatld) begin
		prog_data[31:0] <= lodatai[31:0];
	end
end
`else
always @(negedge sys_clk) // /!\
begin
	if (pdatstrb & (JERRY==0)) begin
		prog_data[31:0] <= lodatai[31:0];
	end
end
always @(posedge sys_clk)
begin
	if (~old_clk && clk & (JERRY!=0) & pdatld) begin
		prog_data[31:0] <= lodatai[31:0];
	end
end
`endif

// GATEWAY.NET (220) - lodwr : an3u
assign lodwr = external & progserv_n & gpu_memw;

// GATEWAY.NET (221) - lodstrbt : oan1
assign lodstrbt = (lodwr | ddatld) & clk_2;

// GATEWAY.NET (222) - lodstrb : nivu
assign lodstrb = lodstrbt;

// GATEWAY.NET (230) - maskwt : join
assign maskwt_n = msizet[1];

// GATEWAY.NET (231) - maskbt : or2
assign maskbt_n = msizet[0] | msizet[1];

// GATEWAY.NET (233) - maskld : an2
assign maskld = active & gpu_ack;

// GATEWAY.NET (234) - maskb : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (maskld) begin
			maskb_n <= maskbt_n;
			maskw_n <= maskwt_n;
		end
	end
end

// GATEWAY.NET (237) - lodm[8-15] : an2
assign lodm[15:8] = maskb_n ? data[15:8] : 8'h00;

// GATEWAY.NET (238) - lodm[16-31] : an2
assign lodm[31:16] = maskw_n ? data[31:16] : 16'h0000;

// GATEWAY.NET (240) - lddatai : join
assign lddatai[7:0] = data[7:0];
assign lddatai[31:8] = lodm[31:8];

// GATEWAY.NET (241) - lodin : mx2
assign lodin[31:0] = (lodwr) ? ((ddatldb & JERRY!=0) ? 32'h0 : gpu_din[31:0]) : ((~ddatldb & JERRY!=0) ? load_data[31:0] : lddatai[31:0]);

// GATEWAY.NET (242) - loaddata : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
begin
	if (lodstrb & (JERRY==0)) begin
		load_data_obuf[31:0] <= lodin[31:0];
	end
	if (~old_clk && clk & (JERRY!=0)) begin
		load_data_obuf[31:0] <= lodin[31:0];
	end
end
`else
always @(negedge sys_clk) // /!\
begin
	if (lodstrb & (JERRY==0)) begin
		load_data_obuf[31:0] <= lodin[31:0];
	end
end
always @(posedge sys_clk)
begin
	if (~old_clk && clk & (JERRY!=0)) begin
		load_data_obuf[31:0] <= lodin[31:0];
	end
end
`endif

// GATEWAY.NET (246) - ddatldb : nivu
assign ddatldb = ddatld;

// GATEWAY.NET (247) - hidwrb : nivu
assign hidwrb = hidwr;

// GATEWAY.NET (248) - hidin : mx4
assign hidin[31:0] = ddatldb ? (hidatai[31:0]) : (hidwrb ? gpu_din[31:0] : hirdata[31:0]);

// GATEWAY.NET (250) - hirdata : fd1q
// GATEWAY.NET (257) - wden : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		hirdata[31:0] <= hidin[31:0];
		wden <= wdlat;
	end
end

// GATEWAY.NET (256) - wdlat : an3
assign wdlat = active & reada_n & gpu_ack;

// GATEWAY.NET (258) - wdenb[0-1] : nivu
assign wdenb[1:0] = {2{wden}};

// GATEWAY.NET (259) - wddrv[0-31] : ts
assign wdata_out[31:0] = load_data[31:0];
assign wdata_31_0_oe = wdenb[0];

// GATEWAY.NET (260) - wddrv[32-63] : ts
assign wdata_out[63:32] = hirdata[31:0];
assign wdata_63_32_oe = wdenb[1];

// GATEWAY.NET (267) - ext_reqt0 : an2
assign ext_reqt[0] = (active & progown) | (packwt & JERRY!=0);

// GATEWAY.NET (268) - ext_reqt[1-4] : fd1q
reg [4:1] ext_reqt_ = 4'h0;
assign ext_reqt[4:1] = ext_reqt_[4:1];
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		ext_reqt_[4:1] <= ext_reqt[3:0];
	end
end

// GATEWAY.NET (269) - ext_reqt[5] : or4
assign ext_reqt[5] = |ext_reqt[4:1];

// GATEWAY.NET (270) - ext_req\ : nd2
assign ext_req_n = ~(ext_reqt[5] & bus_hog);

// GATEWAY.NET (278) - gpu_bt0 : nd2
assign gpu_bt[0] = ~(progown_n & dmaen_n);

// GATEWAY.NET (279) - gpu_bt1 : nd2
assign gpu_bt[1] = ~(gpu_bt[0] & progown_n);

// GATEWAY.NET (280) - gpu_bt2 : nd2
assign gpu_bt[2] = ~(gpu_bt[1] & active);

// GATEWAY.NET (281) - gpu_breq : nd2
assign gpu_breq_obuf = ~(gpu_bt[2] & ext_req_n);
assign gpu_breq_n = ~gpu_breq;

// GATEWAY.NET (283) - dma_breq : an3
assign dma_breq_obuf = active & progown_n & dmaen;
assign dma_breq_n = ~dma_breq;

// --- Compiler-generated PE for BUS gpu_data<0>
assign gpu_data_out[31:0] = (gateack ? prog_data[31:0] : 32'h0) | (hidrd ? hirdata[31:0] : 32'h0);
assign gpu_data_oe = gateack | hidrd;

endmodule
