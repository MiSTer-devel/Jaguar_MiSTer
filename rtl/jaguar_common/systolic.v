//`include "defs.v"

module _systolic
(
	output mtx_atomic,
	output mtx_dover,
	output mtx_wait,
	output [11:2] mtxaddr,
	output mtx_mreq,
	output multsel,
	output [15:0] sysins,
	output sysser,
	input movei_data,
	input clk,
	input datack,
	input [31:0] gpu_din,
	input [15:0] instruction,
	input mtxawr,
	input mtxcwr,
	input reset_n,
	input romold,
	input sys_clk // Generated
);
wire mmult;
wire mtx_active;
reg [3:0] mwidth = 4'h0;
reg maddw = 1'b0;
wire macnten;
wire [2:0] idlet;
reg idle = 1'b1;
reg resmac = 1'b0;
wire [2:0] imultnt;
reg imultn = 1'b0;
wire [3:0] imacnt;
reg imacn = 1'b0;
wire count1_n;
wire [2:0] resmact;
wire count1;
wire mcnten;
reg reghalf = 1'b0;
reg [4:0] sysr1 = 5'h0;
reg [4:0] sysr2 = 5'h0;
wire bit11;
wire oneb;
wire zerob;
wire zeroc;
wire mtx_mreqt;
wire multselt;

// Output buffers
reg mtx_dover_obuf = 1'b0;
wire mtx_mreq_obuf;

wire resetl = reset_n; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end


// Output buffers
assign mtx_dover = mtx_dover_obuf;
assign mtx_mreq = mtx_mreq_obuf;


// SYSTOLIC.NET (54) - mmultt : nr2
// SYSTOLIC.NET (55) - mmult\ : nd7
assign mmult = (~movei_data & romold & (instruction[15:10] == 6'b110110));

// SYSTOLIC.NET (63) - mtx_atomic : or2
assign mtx_atomic = mtx_active | mmult;

// SYSTOLIC.NET (67) - mwidth[0-3] : fdsync
// SYSTOLIC.NET (69) - maddw : fdsync
// SYSTOLIC.NET (82) - mtxaddr : macount
reg [11:2] mtxaddr_ = 10'h0;
assign mtxaddr = mtxaddr_;
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (mtxcwr) begin
			mwidth[3:0] <= gpu_din[3:0];
			maddw <= gpu_din[4];
		end
		if (mtxawr) begin
			mtxaddr_[11:2] <= gpu_din[11:2];
		end else if (macnten) begin
			mtxaddr_[11:2] <= mtxaddr[11:2] + (maddw ? mwidth[3:0] : 4'h1);
		end
	end
end

// SYSTOLIC.NET (81) - macnten : an2h
assign macnten = mtx_dover_obuf & datack;

// SYSTOLIC.NET (88) - idlet0 : nd2
assign idlet[0] = ~(idle & ~mmult);

// SYSTOLIC.NET (89) - idlet1 : nd2
assign idlet[1] = ~(resmac & romold);

// SYSTOLIC.NET (90) - idlet2 : nd2
assign idlet[2] = ~(&idlet[1:0]);

// SYSTOLIC.NET (91) - idle : fd4q
// SYSTOLIC.NET (96) - imultn : fd2q
// SYSTOLIC.NET (102) - imacn : fd2q
// SYSTOLIC.NET (107) - resmac : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			idle <= 1'b1;
			imultn <= 1'b0;
			imacn <= 1'b0;
			resmac <= 1'b0;
		end else begin
			idle <= idlet[2];
			imultn <= imultnt[2];
			imacn <= imacnt[3];
			resmac <= resmact[2];
		end
	end
end

// SYSTOLIC.NET (93) - imultnt0 : nd2
assign imultnt[0] = ~(idle & mmult);

// SYSTOLIC.NET (94) - imultnt1 : nd2
assign imultnt[1] = ~(imultn & ~romold);

// SYSTOLIC.NET (95) - imultnt2 : nd2
assign imultnt[2] = ~(&imultnt[1:0]);

// SYSTOLIC.NET (98) - imacnt0 : nd2
assign imacnt[0] = ~(imultn & romold);

// SYSTOLIC.NET (99) - imacnt1 : nd2
assign imacnt[1] = ~(imacn & ~count1);

// SYSTOLIC.NET (100) - imacnt2 : nd2
assign imacnt[2] = ~(imacn & ~romold);

// SYSTOLIC.NET (101) - imacnt3 : nd3
assign imacnt[3] = ~(&imacnt[2:0]);

// SYSTOLIC.NET (104) - resmact0 : nd3
assign resmact[0] = ~(imacn & count1 & romold);

// SYSTOLIC.NET (105) - resmact1 : nd2
assign resmact[1] = ~(resmac & ~romold);

// SYSTOLIC.NET (106) - resmact2 : nd2
assign resmact[2] = ~(&resmact[1:0]);

// SYSTOLIC.NET (109) - mtx_active : iv
assign mtx_active = ~idle;

// SYSTOLIC.NET (115) - mcnten : an2
assign mcnten = romold & mtx_active;

// SYSTOLIC.NET (116) - mcount : mcount
// SYSTOLIC.NET (124) - r1count : r1count
reg [3:0] mcount = 4'h0;
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (mmult) begin
			mcount[3:0] <= mwidth[3:0];
		end else if (mcnten) begin
			mcount[3:0] <= mcount[3:0] - 4'h1;
		end
		if (mmult) begin
			{sysr1[4:0],reghalf} <= {instruction[9:5],1'b0};
		end else if (romold) begin
			{sysr1[4:0],reghalf} <= {sysr1[4:0],reghalf} + 6'h1;
		end
	end
end
assign count1 = (mcount[3:0] == 4'h1);

// SYSTOLIC.NET (129) - sysr2[0-4] : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (mmult) begin
			sysr2[4:0] <= instruction[4:0];
		end
	end
end

// SYSTOLIC.NET (141) - bit11 : or2
assign bit11 = imultn | resmac;

// imultn	010010 r1count reg2
// imacn 	010100 r1count reg2
// resmac	010011 x       reg2
// SYSTOLIC.NET (146) - sysins : join
assign sysins[4:0] = sysr2[4:0];
assign sysins[9:5] = sysr1[4:0];
assign sysins[10] = resmac;
assign sysins[11] = bit11;
assign sysins[12] = imacn;
assign sysins[15:13] = 3'b010;

// SYSTOLIC.NET (152) - sysser : ivu
assign sysser = ~idle;

// SYSTOLIC.NET (158) - mtx_mreqt : or2
assign mtx_mreqt = imultn | imacn;

// SYSTOLIC.NET (159) - mtx_mreq : aor1
assign mtx_mreq_obuf = (mtx_dover_obuf & ~datack) | mtx_mreqt;

// SYSTOLIC.NET (164) - mtx_dover : fd2qu
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			mtx_dover_obuf <= 1'b0;
		end else begin
			mtx_dover_obuf <= mtx_mreq_obuf;
		end
	end
end

// SYSTOLIC.NET (168) - mtx_wait : an2
assign mtx_wait = mtx_dover_obuf & ~datack;

// SYSTOLIC.NET (174) - multselt : an2
assign multselt = reghalf & mtx_active;

// SYSTOLIC.NET (175) - multsel : fdsync
reg multsel_ = 1'b0;
assign multsel = multsel_;
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (romold) begin
			multsel_ <= multselt;
		end
	end
end
endmodule
