//`include "defs.v"

module _gpu_mem
(
	output [31:0] gpu_data_out,
	output gpu_data_oe,
	output [31:16] gpu_dout_out, // jerry only
//	output gpu_dout_15_0_oe, // jerry only
	output gpu_dout_31_16_oe, // jerry only
	output accumrd, // jerry only
	output big_instr,
	output big_io,
	output big_pix, // tom only
	output bliten, // tom only
	output ctrlwr,
	output ctrlwrgo, // tom only
	output [1:0] dacw, // jerry only
	output datack,
	output dbgrd,
	output del_xld,
	output divwr,
	output externalb,
	output flagrd,
	output flagwr,
	output gateack,
	output [23:0] gpu_addr,
	output gpu_memw,
	output hidrd, // tom only
	output hidwr, // tom only
	output lock, // tom only
	output [2:0] i2sr, // jerry only
	output [3:0] i2sw, // jerry only
	output [31:0] mem_data,
	output modulowr, // jerry only
	output mtxawr,
	output mtxcwr,
	output pcrd,
	output pcwr,
	output progack,
	output progserv,
	output [11:2] ram_addr,
	output [1:0] ramen, // ramen[1] is jerry only
	output remrd,
	output romen, // jerry only
	output statrd,
	input clk,
	input [12:0] cpuaddr,
	input [31:0] cpudata,
	input [23:0] dataddr,
	input [31:0] dstd,
	input dstdgate,
	input datreq,
	input datwe,
	input gatereq,
	input go,
	input [31:0] gpu_din,
	input ioreq,
	input iowr,
	input pabort,
	input [21:0] progaddr,
	input progreq,
	input reset_n,
	input reset_lock, // tom only
	input sys_clk // Generated
);
parameter JERRY = 0;

reg [31:0] datdata = 32'h0;
wire [31:0] wdata;
reg [31:0] mem_data_ = 32'h0;
wire gatereqa;
wire datreqa;
wire progreqa;
reg ioservt = 1'b0;
wire ioserv;
reg gateserv = 1'b0;
reg datservt = 1'b0;
wire datserv;
reg progservt = 1'b0;
wire busactive_n;
wire xpabortset_n;
reg xprog = 1'b0;
wire [1:0] xpabortt;
reg xpabort = 1'b0;
wire xprogset_n;
wire xprogt_0;
wire xprogi;
wire external;
wire xprt;
wire [1:0] progat;
wire gpu_memwi;
reg gpu_memwt = 1'b0;
wire dstdld_n;
wire cpudsel;
wire gpuden;
wire gpuprd;
wire [14:12] ram_addr_;
wire [23:13] locala;
wire localat;
wire localaddr_n;
wire [1:0] localt;
wire _local;
wire extt;
wire idle_n;
wire gpuen;
wire disable_n;
wire [1:0] rament;
wire gpuireg;
wire gpuictrl;
wire bigwr;
wire i2shien;
wire big_ioi;
reg big_iot = 1'b1;
wire big_pixi;
reg big_pixt = 1'b1;
wire locki;

// Output buffers
wire flagrd_obuf;
wire gpu_memw_obuf;
reg lock_obuf = 1'b0;
wire progserv_obuf;
wire [11:2] ram_addr_obuf;
wire statrd_obuf;
reg big_instr_ = 1'b0;

wire resetl = reset_n; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end


// Output buffers
assign externalb = external;
assign flagrd = flagrd_obuf;
assign gpu_memw = gpu_memw_obuf;
assign lock = lock_obuf;
assign progserv = progserv_obuf;
assign ram_addr[11:2] = ram_addr_obuf[11:2];
assign statrd = statrd_obuf;
assign big_instr = big_instr_;
assign mem_data[31:0] = mem_data_[31:0];


// GPU_MEM.NET (123) - gatereqa : an2
assign gatereqa = gatereq & ~ioreq;

// GPU_MEM.NET (124) - datreqa : an3h
assign datreqa = datreq & ~gatereq & ~ioreq;

// GPU_MEM.NET (125) - progreqa : an5p
assign progreqa = progreq & ~datreq & ~gatereq & ~ioreq & ~xprogi;

// GPU_MEM.NET (131) - ioservt : fd2q
// GPU_MEM.NET (135) - gateserv : fd2q
// GPU_MEM.NET (137) - datservt : fd2q
// GPU_MEM.NET (141) - progservt : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			ioservt <= 1'b0;
			gateserv <= 1'b0;
			datservt <= 1'b0;
			progservt <= 1'b0;
		end else begin
			ioservt <= ioreq;
			gateserv <= gatereqa;
			datservt <= datreqa;
			progservt <= progreqa;
		end
	end
end

// GPU_MEM.NET (132) - ioserv : niv
assign ioserv = ioservt;

// GPU_MEM.NET (139) - datserv : nivu
assign datserv = datservt;

// GPU_MEM.NET (142) - progserv : nivm
assign progserv_obuf = progservt;

// GPU_MEM.NET (147) - busactive\ : nr4
assign busactive_n = ~(ioserv | gateserv | datserv | progserv_obuf);

// GPU_MEM.NET (159) - xpabortset : nd3
assign xpabortset_n = ~(xprog & ~progreq & ~gateserv);

// GPU_MEM.NET (160) - xpabortt0 : nd2
assign xpabortt[0] = ~(xpabort & ~gateserv);

// GPU_MEM.NET (161) - xpabortt1 : nd2
assign xpabortt[1] = ~(xpabortset_n & xpabortt[0]);

// GPU_MEM.NET (162) - xpabort : fd2q
// GPU_MEM.NET (180) - xprog : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			xpabort <= 1'b0;
			xprog <= 1'b0;
		end else begin
			xpabort <= xpabortt[1];
			xprog <= xprogi;
		end
	end
end

// GPU_MEM.NET (176) - xprogset\ : nd3p
assign xprogset_n = ~(progserv_obuf & external & ~pabort);

// GPU_MEM.NET (177) - xprogt0 : nd2
assign xprogt_0 = ~(xprog & ~gateserv);

// GPU_MEM.NET (178) - xprogi : nd2
assign xprogi = ~(xprogt_0 & xprogset_n);

// GPU_MEM.NET (192) - del_xld : an3m
assign del_xld = datserv & external & ~datwe;

// GPU_MEM.NET (201) - xprt : nd2p
assign xprt = ~(~xprog & xprogset_n);

// GPU_MEM.NET (203) - progat0 : nd3
assign progat[0] = ~(~xprt & progserv_obuf & ~pabort);

// GPU_MEM.NET (204) - progat1 : nd3
assign progat[1] = ~(xprt & gateserv & ~xpabort);

// GPU_MEM.NET (205) - progack : nd2u
assign progack = ~(&progat[1:0]);

// GPU_MEM.NET (209) - datack : nivu
assign datack = datserv;

// GPU_MEM.NET (213) - gateack : nivu
assign gateack = gateserv;

// GPU_MEM.NET (220) - gpu_memwi : aor2
assign gpu_memwi = (datwe & datreqa) | (iowr & ioreq);

// GPU_MEM.NET (222) - gpu_memwt : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		gpu_memwt <= gpu_memwi;
	end
end

// GPU_MEM.NET (224) - gpu_memw : nivh
assign gpu_memw_obuf = gpu_memwt;

// GPU_MEM.NET (238) - dstdld : nr2u
assign dstdld_n = ~(dstdgate | ~go);

// GPU_MEM.NET (239) - datdata : fd1e
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (~dstdld_n) begin
			datdata[31:0] <= dstd[31:0];
		end
	end
end

// GPU_MEM.NET (243) - cpusel : an2u
assign cpudsel = ioserv & ~gpuprd;

// GPU_MEM.NET (244) - gpuden : or4u
assign gpuden = gpu_memw_obuf | gpuprd | busactive_n | external;

// GPU_MEM.NET (246) - wseld : mx2
assign wdata[31:0] = (cpudsel) ? cpudata[31:0] : datdata[31:0];

// GPU_MEM.NET (247) - gpu_data : ts
assign gpu_data_out[31:0] = wdata[31:0];
assign gpu_data_oe = gpuden;

// GPU_MEM.NET (252) - mem_data : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		mem_data_[31:0] <= gpu_din[31:0];
	end
end

// GPU_MEM.NET (265) - gpu_addr[0-1] : an2
assign gpu_addr[1:0] = datserv ? dataddr[1:0] : 2'h0;

// GPU_MEM.NET (266) - amux[2-5] : mx4p
// GPU_MEM.NET (269) - amux[6-9] : mx4p
// GPU_MEM.NET (272) - amux[10-14] : mx4p
assign ram_addr_obuf[11:2] = ioserv ? (datserv ? 10'h0 : cpuaddr[9:0]) : (datserv ? dataddr[11:2] : progaddr[9:0]);
assign ram_addr_[14:12] = ioserv ? (datserv ? 3'h0 : cpuaddr[12:10]) : (datserv ? dataddr[14:12] : progaddr[12:10]);

// GPU_MEM.NET (276) - gpu_addr[2-14] : nivm
assign gpu_addr[11:2] = ram_addr_obuf[11:2];
assign gpu_addr[14:12] = ram_addr_[14:12];

// GPU_MEM.NET (277) - amux[15-23] : mx2
assign gpu_addr[23:15] = (datserv) ? dataddr[23:15] : progaddr[21:13];

// GPU_MEM.NET (303) - locala[13-14] : mx2
// GPU_MEM.NET (305) - locala[15-19] : mxi2p
// GPU_MEM.NET (307) - locala[20-21] : mx2p
// GPU_MEM.NET (309) - locala[22-23] : mx2p
assign locala[23:13] = (datserv) ? dataddr[23:13] : progaddr[21:11];

// GPU_MEM.NET (311) - localat : or2p
assign localat = |locala[14:13]; // xx2000-xx7fff

// GPU_MEM.NET (312) - localaddr\ : nd10
assign localaddr_n = (JERRY==0) ? ~(locala[23:15] == 9'b1111_0000_0 & localat) //f02000-f07fff
                                : ~(locala[23:15] == 9'b1111_0001_1);          //f18000-f1ffff

// GPU_MEM.NET (315) - localt0 : nd2
assign localt[0] = (progserv | datserv);

// GPU_MEM.NET (316) - localt1 : nd11
assign localt[1] = (JERRY==0) ? ~(locala[23:15] == 9'b1111_0000_0 & localt[0] & localat) //f02000-f07fff
                              : ~(locala[23:15] == 9'b1111_0001_1 & localt[0]);          //f18000-f1ffff

// GPU_MEM.NET (318) - local : nd2p
assign _local = ~(~ioserv & localt[1]);

// GPU_MEM.NET (323) - extt : nd2
assign extt = (datserv | progserv);

// GPU_MEM.NET (324) - external : an2
assign external = localaddr_n & extt;

// GPU_MEM.NET (336) - idle\ : or3
assign idle_n = ioserv | datserv | progserv_obuf;

// GPU_MEM.NET (337) - gpuen : an8
assign gpuen = gpu_addr[14:9] == 6'b010_000 & _local & idle_n;

// GPU_MEM.NET (339) - bliten : an10
assign bliten = gpu_addr[14:8] == 7'h22 & _local & idle_n & disable_n;

// GPU_MEM.NET (342) - rament : an3
assign rament[0] = ram_addr_[14:12] == 3'b011;
assign rament[1] = ram_addr_[14:12] == 3'b100;

// GPU_MEM.NET (343) - ramen : an4p
assign ramen[0] = rament[0] & _local & idle_n & (disable_n | JERRY!=0);
assign ramen[1] = rament[1] & _local & idle_n;
assign romen = ram_addr_[14:12] == 3'b101 & _local & idle_n;

// GPU_MEM.NET (352) - gpuprd\ : nd4
assign gpuprd = (gpuen & ~gpu_addr[8] & ~go & ~gpu_memw);

// GPU_MEM.NET (359) - disable\ : nd2
assign disable_n = ~(ioserv & lock_obuf);

// GPU_MEM.NET (360) - gpuireg : an4m
assign gpuireg = gpuen & gpu_addr[8:7]==2'b10 & (disable_n | JERRY!=0);

// GPU_MEM.NET (365) - gpuictrl : an3
assign gpuictrl = gpuen & gpu_addr[8:7]==2'b10;

// GPU_MEM.NET (374) - flagwr : an7h
assign flagwr = gpu_addr[6:2]==5'b000_00 & gpuireg & gpu_memw;

// GPU_MEM.NET (376) - mtxcwr : an7m
assign mtxcwr = gpu_addr[6:2]==5'b000_01 & gpuireg & gpu_memw;

// GPU_MEM.NET (378) - mtxawr : an7m
assign mtxawr = gpu_addr[6:2]==5'b000_10 & gpuireg & gpu_memw;

// GPU_MEM.NET (380) - bigwr : an7
assign bigwr = gpu_addr[6:2]==5'b000_11 & gpuireg & gpu_memw;

// GPU_MEM.NET (382) - pcwr : an7
assign pcwr = gpu_addr[6:2]==5'b001_00 & gpuireg & gpu_memw;

// GPU_MEM.NET (384) - ctrlwrgo : an7
assign ctrlwrgo = gpu_addr[6:2]==5'b001_01 & gpuictrl & gpu_memw;

// GPU_MEM.NET (387) - ctrlwr : an7m
assign ctrlwr = gpu_addr[6:2]==5'b001_01 & gpuireg & gpu_memw;

// GPU_MEM.NET (390) - hidwr : an7
assign hidwr = gpu_addr[6:2]==5'b001_10 & gpuireg & gpu_memw;

// DSP_MEM.NET (381) - modulowr : an7u
assign modulowr = hidwr; // hidwr is tom, modulowr is jerry

// GPU_MEM.NET (393) - divwr : an7
assign divwr = gpu_addr[6:2]==5'b001_11 & gpuireg & gpu_memw;

// DSP_MEM.NET (387) - dacw[0] : an7h
assign dacw[0] = gpu_addr[6:2]==5'b100_00 & gpuireg & gpu_memw;

// DSP_MEM.NET (389) - dacw[1] : an7h
assign dacw[1] = gpu_addr[6:2]==5'b100_01 & gpuireg & gpu_memw;

// DSP_MEM.NET (391) - i2sw[0] : an7h
assign i2sw[0] = gpu_addr[6:2]==5'b100_10 & gpuireg & gpu_memw;	// LTXD Left transmit data F1A148 WO.

// DSP_MEM.NET (394) - i2sw[1] : an7h
assign i2sw[1] = gpu_addr[6:2]==5'b100_11 & gpuireg & gpu_memw;		// RTXD Right transmit data F1A14C WO.

// DSP_MEM.NET (397) - i2sw[2] : an7h
assign i2sw[2] = gpu_addr[6:2]==5'b101_00 & gpuireg & gpu_memw;	// SCLK Serial Clock Frequency F1A150 WO.

// DSP_MEM.NET (400) - i2sw[3] : an7h
assign i2sw[3] = gpu_addr[6:2]==5'b101_01 & gpuireg & gpu_memw;		// SMODE Serial Mode F1A154 WO.

// GPU_MEM.NET (398) - flagrd : an7h
assign flagrd_obuf = gpu_addr[6:2]==5'b000_00 & gpuireg & ~gpu_memw;

// GPU_MEM.NET (400) - pcrd : an7u
assign pcrd = gpu_addr[6:2]==5'b001_00 & gpuireg & ~gpu_memw;

// GPU_MEM.NET (402) - statrd : an7h
assign statrd_obuf = gpu_addr[6:2]==5'b001_01 & gpuireg & ~gpu_memw;

// GPU_MEM.NET (405) - hidrd : an7u
assign hidrd = gpu_addr[6:2]==5'b001_10 & gpuireg & ~gpu_memw;

// GPU_MEM.NET (408) - remrd : an7u
assign remrd = gpu_addr[6:2]==5'b001_11 & gpuireg & ~gpu_memw;

// DSP_MEM.NET (415) - accumrd : an7u
assign accumrd = gpu_addr[6:2]==5'b010_00 & gpuireg & ~gpu_memw;

// GPU_MEM.NET (411) - dbgrd : or2_h
assign dbgrd = flagrd_obuf | statrd_obuf;

// DSP_MEM.NET (420) - i2sr[0] : an7h
assign i2sr[0] = gpu_addr[6:2]==5'b100_10 & gpuireg & ~gpu_memw;

// DSP_MEM.NET (423) - i2sr[1] : an7h
assign i2sr[1] = gpu_addr[6:2]==5'b100_11 & gpuireg & ~gpu_memw;

// DSP_MEM.NET (426) - i2sr[2] : an7h
assign i2sr[2] = gpu_addr[6:2]==5'b101_00 & gpuireg & ~gpu_memw;

// DSP_MEM.NET (432) - i2shien : or3_h
assign i2shien = |i2sr[2:0];

// DSP_MEM.NET (433) - i2shid[16-31] : ts
assign gpu_dout_out[31:16] = gpu_din[15:0];
assign gpu_dout_31_16_oe = i2shien;

// DSP_MEM.NET (436) - i2shid[0-15] : ts
//assign gpu_dout_out[15:0] = 16'h0;
//assign gpu_dout_15_0_oe = 1'b0;

// GPU_MEM.NET (415) - big_ioi : mx2
assign big_ioi = (bigwr) ? gpu_din[0] : big_iot;

// GPU_MEM.NET (416) - big_iot : fd4q
// GPU_MEM.NET (420) - big_pixt : fd4q
// GPU_MEM.NET (423) - big_instr : fdsyncr
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			big_iot <= 1'b1;
			big_pixt <= 1'b1;
			big_instr_ <= 1'b0;
		end else begin
			big_iot <= big_ioi;
			big_pixt <= big_pixi;
			if (bigwr) begin
				big_instr_ <= gpu_din[2];
			end
		end
	end
end

// GPU_MEM.NET (417) - big_io : nivu
assign big_io = big_iot;

// GPU_MEM.NET (419) - big_pixi : mx2
assign big_pixi = (bigwr) ? gpu_din[1] : big_pixt;

// GPU_MEM.NET (421) - big_pix : nivm
assign big_pix = big_pixt;

// GPU_MEM.NET (429) - locki : mx4
assign locki = reset_n ? (bigwr ? 1'b0 : lock_obuf) : (bigwr ? lock_obuf : reset_lock);

// GPU_MEM.NET (431) - lock : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		lock_obuf <= locki;
	end
end
endmodule
