//
// sdram
// Copyright (c) 2015-2019 Sorgelig
//
// Some parts of SDRAM code used from project:
// http://hamsterworks.co.nz/mediawiki/index.php/Simple_SDRAM_Controller
//
// This source file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version. 
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License 
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


// This module is highly specialized to match Jaguar. 
// Ch1 is geared for DRAM and requires using ras/cas addresses and refresh commands. Uses BA 0x0X only.
// Ch2 is geared for ROM and uses BA 0x1X only. Assumes refresh provided by Ch1 or self_refresh on.
module sdram
(
	input             init,        // reset to initialize RAM
	input             clk,         // clock ~100MHz

	inout  reg [15:0] SDRAM_DQ,    // 16 bit bidirectional data bus
	output reg [12:0] SDRAM_A,     // 13 bit multiplexed address bus
	output            SDRAM_DQML,  // two byte masks
	output            SDRAM_DQMH,  // 
	output reg  [1:0] SDRAM_BA,    // two banks
	output            SDRAM_nCS,   // a single chip select
	output            SDRAM_nWE,   // write enable
	output            SDRAM_nRAS,  // row address select
	output            SDRAM_nCAS,  // columns address select
	output            SDRAM_CKE,   // clock enable
	output            SDRAM_CLK,   // clock for chip

//	input      [26:1] ch1_addr,    // 24 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations.
	input      [10:3] ch1_addr,    // 24 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations.
	input      [12:0] ch1_caddr,   // direct control.
	output     [63:0] ch1_dout,    // data output to cpu
	input      [63:0] ch1_din,     // data input from cpu
	input             ch1_reqr,    // request
	input             ch1_reqw,    // request
	input             ch1_ref,     // refquest
	input             ch1_act,     // actquest
	input             ch1_pch,     // pchquest
	input             ch1_rnw,     // 1 - read, 0 - write
	input      [7:0]  ch1_be,      // Byte enable (bits) for burst writes. TODO
	output reg        ch1_ready,
	input             ch1_64,
	
	input      [23:1] ch2_addr,    // 24 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations.
	output reg [31:0] ch2_dout,    // data output to cpu
	input      [15:0] ch2_din,     // data input from cpu
	input             ch2_req,     // request
	input             ch2_rnw,     // 1 - read, 0 - write
	input      [1:0]  ch2_be,      // Byte enable (bits) for writes.
	output reg        ch2_ready,
	
	input      [23:0] ch3_addr,    // 24 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations.
	output reg [31:0] ch3_dout,    // data output to cpu
	input      [31:0] ch3_din,     // data input from cpu
	input             ch3_req,     // request
	input             ch3_rnw,     // 1 - read, 0 - write
	output reg        ch3_ready,
	
	output reg        ram64,

	input             self_refresh // 1 - self control, 0 - refresh on ch1_ref
);

assign SDRAM_nCS  = 0;
assign SDRAM_nRAS = command[2];
assign SDRAM_nCAS = command[1];
assign SDRAM_nWE  = command[0];
assign SDRAM_CKE  = 1;
assign {SDRAM_DQMH,SDRAM_DQML} = SDRAM_A[12:11];


// Burst length = 4
localparam BURST_LENGTH        = 2;
localparam BURST_CODE          = (BURST_LENGTH == 8) ? 3'b011 : (BURST_LENGTH == 4) ? 3'b010 : (BURST_LENGTH == 2) ? 3'b001 : 3'b000;  // 000=1, 001=2, 010=4, 011=8
localparam ACCESS_TYPE         = 1'b0;     // 0=sequential, 1=interleaved
localparam CAS_LATENCY         = 3'd2;     // 2 for < 100MHz, 3 for >100MHz
localparam OP_MODE             = 2'b00;    // only 00 (standard operation) allowed
localparam NO_WRITE_BURST      = 1'b1;     // 0=write burst enabled, 1=only single access write
localparam MODE                = {3'b000, NO_WRITE_BURST, OP_MODE, CAS_LATENCY, ACCESS_TYPE, BURST_CODE};

localparam sdram_startup_cycles= 14'd12100;// 100us, plus a little more, @ 100MHz
localparam cycles_per_refresh  = 14'd780;  // (64000*100)/8192-1 Calc'd as (64ms @ 100MHz)/8192 rows
//localparam cycles_per_refresh  = 14'd608;  // (64000*78)/8192-1 Calc'd as (64ms @ 78MHz)/8192 rows
localparam startup_refresh_max = 14'b11111111111111;

// SDRAM commands - ras, cas, we
wire [2:0] CMD_NOP             = 3'b111;
//wire [2:0] CMD_BURST_STOP      = 3'b110;
wire [2:0] CMD_ACTIVE          = 3'b011;
wire [2:0] CMD_READ            = 3'b101;
wire [2:0] CMD_WRITE           = 3'b100;
wire [2:0] CMD_PRECHARGE       = 3'b010;
wire [2:0] CMD_AUTO_REFRESH    = 3'b001;
wire [2:0] CMD_LOAD_MODE       = 3'b000;

reg [13:0] refresh_count = startup_refresh_max - sdram_startup_cycles;
reg  [2:0] command;

localparam STATE_STARTUP = 0;
localparam STATE_WAIT    = 1;
localparam STATE_RW1     = 2;
localparam STATE_RW2     = 3;
localparam STATE_IDLE    = 4;
localparam STATE_IDLE_1  = 5;
localparam STATE_IDLE_2  = 6;
localparam STATE_IDLE_3  = 7;
localparam STATE_IDLE_4  = 8;
localparam STATE_IDLE_5  = 9;
localparam STATE_IDLE_6  = 10;
localparam STATE_RFSH    = 11;
localparam STATE_RW3     = 12;
localparam STATE_RW4     = 13;
localparam STATE_ACT1    = 14;
localparam STATE_ACT2    = 15;
localparam STATE_PRE1    = 16;
localparam STATE_PRE2    = 17;

(*noprune*) reg [CAS_LATENCY+BURST_LENGTH+2:0] data_ready_delay1, data_ready_delay2;
reg [15:0] dq_reg;
//reg [31:0] ch1_dout_;
//assign ch1_dout[31:0] = {ch1_dout_[31:16],data_ready_delay1[0] ? dq_reg[15:0] : ch1_dout_[15:0]};

always @(posedge clk) begin

	reg        saved_wr;
	reg [12:0] cas_addr;
	reg [63:0] saved_data;
	reg  [4:0] state = STATE_STARTUP;
	reg  [7:0] saved_mask;
	reg [10:3] saved_addr;
	
	reg [15:0] ch2_data;
	reg [23:1] ch2_add;
	reg        ch2_wr;

	reg [31:0] ch3_data;
	reg [22:1] ch3_add;
	reg        ch3_wr;
	reg [3:0]  ch_temp;

	reg       ch;
	reg       ch1_rqr, ch1_rqw, ch2_rq;
	reg       ch1_rf, ch1_ac, ch1_pc;
	reg       ch1_active;

	ch1_rqr <= ch1_rqr | ch1_reqr;
	ch1_rqw <= ch1_rqw | ch1_reqw;
	ch1_rf <= ch1_rf | ch1_ref;
	ch1_ac <= ch1_ac | ch1_act;
	ch1_pc <= (ch1_pc | ch1_pch) && ch1_active;

	refresh_count <= refresh_count+1'b1;

	data_ready_delay1 <= data_ready_delay1>>1;
	data_ready_delay2 <= data_ready_delay2>>1;

	dq_reg <= SDRAM_DQ;
	
	// MSB Byte is read/written FIRST now. ElectronAsh.
	if(data_ready_delay1[3]) ch1_dout[31:16] <= dq_reg;
	if(data_ready_delay1[2]) ch1_dout[15:00] <= dq_reg;
	if(data_ready_delay1[1]) ch1_dout[63:48] <= dq_reg;
	if(data_ready_delay1[0]) ch1_dout[47:32] <= dq_reg;
	if(data_ready_delay1[2] && ~ch1_64) ch1_ready <= 1;
	if(data_ready_delay1[0] && ch1_64) ch1_ready <= 1;
	
	if(data_ready_delay2[1]) ch2_dout[31:16] <= dq_reg;
	if(data_ready_delay2[0]) ch2_dout[15:00] <= dq_reg;
	if(data_ready_delay2[0]) ch2_ready <= 1;

	SDRAM_DQ <= 16'bZ;
	
	if (ch2_req) begin
		ch2_rq  <= 1;
		ch2_data  <= ch2_din;
		ch2_add   <= ch2_addr;
		ch2_wr    <= !ch2_rnw;
		ch2_ready <= 0;
		ch_temp   <= ch_tmp;
	end
	if (ch1_reqr) begin
		saved_addr <= ch1_addr;
	end
	ch3_ready <= 0;
	

	command <= CMD_NOP;
	case (state)
		STATE_STARTUP: begin
			SDRAM_A    <= 0;
			SDRAM_BA   <= 0;

			// All the commands during the startup are NOPS, except these
			if (refresh_count == startup_refresh_max-63) begin
				// ensure all rows are closed
				command     <= CMD_PRECHARGE;
				SDRAM_A[10] <= 1;  // all banks
				SDRAM_BA    <= 2'b00;
			end
			if (refresh_count == startup_refresh_max-55) begin
				// these refreshes need to be at least tREF (66ns) apart
				command     <= CMD_AUTO_REFRESH;
			end
			if (refresh_count == startup_refresh_max-47) begin
				command     <= CMD_AUTO_REFRESH;
			end
			if (refresh_count == startup_refresh_max-39) begin
				// Now load the mode register
				command     <= CMD_LOAD_MODE;
				SDRAM_A     <= MODE;
			end
			if (refresh_count == startup_refresh_max-32) begin
				// Determine chip size is 64MB or 32MB
				{SDRAM_BA,SDRAM_A} <= {2'b00,13'h0}; // no auto precharge
				ch         <= 0;
				command    <= CMD_ACTIVE;
			end
			if (refresh_count == startup_refresh_max-30) begin
				// activate bank 0
				SDRAM_A <= {13'h0000}; // no auto precharge
				command  <= CMD_WRITE;
				SDRAM_DQ <= 16'h0;
				SDRAM_A[12:11] <= 2'b00; //~be; always write
			end
			if (refresh_count == startup_refresh_max-28) begin
				// Write 2 to column 0
				SDRAM_A <= {13'h0000}; // no auto precharge
				command  <= CMD_WRITE;
				SDRAM_DQ <= 16'h2;
				SDRAM_A[12:11] <= 2'b00; //~be; always write
			end
			if (refresh_count == startup_refresh_max-27) begin
				// Write 1 to column bit-9
				SDRAM_A <= {13'h0200}; // no auto precharge
				command  <= CMD_WRITE;
				SDRAM_DQ <= 16'h1;
				SDRAM_A[12:11] <= 2'b00; //~be; always write
			end
			if (refresh_count == startup_refresh_max-26) begin
				// Read column 0
				SDRAM_A <= {13'h0000}; // no auto precharge
				command <= CMD_READ;
			end
			if (refresh_count == startup_refresh_max-24+CAS_LATENCY) begin
				// If column 9-bit write didn't overwrite column 0 then 64MB
				ram64 <= (dq_reg[0] == 1'b0);
			end
			if (refresh_count == startup_refresh_max-24+CAS_LATENCY+BURST_LENGTH) begin
				// Close bank
				{SDRAM_BA,SDRAM_A} <= {2'b00,2'b00,1'b0,10'h0}; // no auto precharge
				command    <= CMD_PRECHARGE;
			end

			if (!refresh_count) begin
				state   <= STATE_IDLE;
				refresh_count <= 0;
			end
		end

		STATE_IDLE_6: state <= STATE_IDLE_5;
		STATE_IDLE_5: state <= STATE_IDLE_4;
		STATE_IDLE_4: state <= STATE_IDLE_3;
		STATE_IDLE_3: state <= STATE_IDLE_2;
		STATE_IDLE_2: state <= STATE_IDLE_1;
		STATE_IDLE_1: state <= STATE_IDLE;

		STATE_RFSH: begin
			//------------------------------------------------------------------------
			//-- Start the refresh cycle. 
			//-- This tasks tRFC (66ns), so 7 idle cycles are needed @ 120MHz
			//------------------------------------------------------------------------
			state    <= STATE_IDLE_6;
			command  <= CMD_AUTO_REFRESH;
			refresh_count <= refresh_count - cycles_per_refresh + 1'd1;
			ch2_ready   <= 0;
		end

		STATE_IDLE: begin
			ch1_ready   <= 1;
			ch2_ready   <= 1;
			if ((refresh_count > cycles_per_refresh) && (self_refresh))  begin
				// Priority is to issue a refresh if one is outstanding
				state <= STATE_RFSH;
				ch2_ready   <= 0;
			end
			else if(ch1_rf | ch1_ref) begin	// Trying to save one clock cycle, by checking for ch1_req here.
														// Note: this will only work for accesses where we're in STATE_IDLE when ch1_req pulses High.
				state <= STATE_RFSH;
				ch1_active <= 0;
				ch1_rf <= 0;
				ch2_ready  <= 0;
			end
			else if(ch1_ac | ch1_act) begin	// Trying to save one clock cycle, by checking for ch1_req here.
														// Note: this will only work for accesses where we're in STATE_IDLE when ch1_req pulses High.
				{SDRAM_BA,SDRAM_A} <= {2'b00,ch1_caddr[12:0]}; // no auto precharge
				ch         <= 0;
				command    <= CMD_ACTIVE;
				state      <= STATE_ACT1;
				ch1_ac     <= 0;
				ch1_active <= 1;
			end
			else if((ch1_pc | ch1_pch) && ch1_active) begin	// Trying to save one clock cycle, by checking for ch1_req here.
														// Note: this will only work for accesses where we're in STATE_IDLE when ch1_req pulses High.
				{SDRAM_BA,SDRAM_A} <= {2'b00,2'b00,1'b0,10'h0}; // no auto precharge
				ch         <= 0;
				command    <= CMD_PRECHARGE;
				state      <= STATE_PRE1;
				ch1_pc     <= 0;
				ch1_active <= 0;
			end
			else if((ch1_rqr | ch1_reqr)) begin	// Trying to save one clock cycle, by checking for ch1_req here.
														// Note: this will only work for accesses where we're in STATE_IDLE when ch1_req pulses High.
//				{SDRAM_BA,SDRAM_A} <= {2'b00,2'b00,1'b0,1'b0,ch1_caddr[7:0],1'b0}; // no auto precharge
				{SDRAM_BA,SDRAM_A} <= {2'b00,2'b00,1'b0,1'b0,ch1_reqr?ch1_addr[10:3]:saved_addr[10:3],1'b0}; // no auto precharge
				command <= CMD_READ;
				state   <= ch1_64 ? STATE_RW1 : STATE_IDLE_4;
				data_ready_delay1[CAS_LATENCY+BURST_LENGTH+2] <= 1;
				saved_addr <= ch1_reqr?ch1_addr[10:3]:saved_addr[10:3];
				saved_wr   <= 0;
				ch1_rqr <= 0;
				ch     <= 0;
			end
			else if((ch1_rqw | ch1_reqw)) begin	// Trying to save one clock cycle, by checking for ch1_req here.
														// Note: this will only work for accesses where we're in STATE_IDLE when ch1_req pulses High.
				{SDRAM_BA,SDRAM_A} <= {2'b00,2'b00,1'b0,1'b0,ch1_caddr[7:0],1'b0}; // no auto precharge
				command  <= CMD_WRITE;
				SDRAM_DQ <= ch1_din[31:16];
				SDRAM_A[12:11] <= ~ch1_be[3:2];
				state <= STATE_RW2;
				saved_data <= ch1_din;
				saved_wr   <= ~ch1_rnw;
				saved_mask[7:0] <= ~ch1_be[7:0];
				ch1_rqw <= 0;
				ch     <= 0;
			end
			else if(ch2_rq) begin
//				{cas_addr[12:9],SDRAM_BA,SDRAM_A,cas_addr[8:0]} <= {2'b00, 1'b1, 1'b0, 1'b1, ch2_add[22:10], 1'b0, ch2_add[9:1]}; // auto precharge
				{cas_addr[12:9],SDRAM_BA,SDRAM_A,cas_addr[8:0]} <= {2'b00, 1'b1, 1'b0, 1'b1, ch_temp, ch2_add[19:10], ch2_add[9:1]}; // auto precharge
				saved_data <= {ch2_data,ch2_data,ch2_data,ch2_data};
				saved_wr   <= ch2_wr;
				saved_mask[3:2] <= ~ch2_be[1:0]; // first write uses [3:2]
				ch         <= 1;
				ch2_rq     <= 0;
				command    <= CMD_ACTIVE;
				state      <= STATE_WAIT;
				ch2_ready  <= 0;
			end
		end

		STATE_WAIT: begin
			state <= STATE_RW1;	// Wait state (NOP) for CL=2.
										// CL=3 would need an extra wait state here, I think? ElectronAsh.
		end
		
		STATE_RW1: begin
			SDRAM_A <= cas_addr;
			if(saved_wr) begin
				command  <= CMD_WRITE;
				SDRAM_DQ <= saved_data[31:16];
				SDRAM_A[12:11] <= saved_mask[3:2];//(ch == 0) ? saved_mask[3:2] : 2'b00; //~be; always write
				state <= (ch == 0) ? STATE_RW2 : STATE_IDLE_3;
			end else if (ch == 1) begin
				command <= CMD_READ;
				state   <= STATE_IDLE_3;
				data_ready_delay2[CAS_LATENCY+BURST_LENGTH] <= 1;
			end else begin
				state   <= STATE_RW2;
			end
		end

		STATE_RW2: begin
			if (saved_wr) begin
				state       <= ch1_64 ? STATE_RW3 : STATE_IDLE;
				command     <= CMD_WRITE;
				SDRAM_DQ <= saved_data[15:0];
				SDRAM_A[12:11] <= saved_mask[1:0];
				SDRAM_A[0] <= 1'b1;
				ch1_ready   <= ch1_64 ? 1'b0 : 1'b1;
			end else begin
				{SDRAM_BA,SDRAM_A} <= {2'b01,2'b00,1'b0,1'b0,saved_addr[10:3],1'b0}; // no auto precharge
				command <= CMD_READ;
				state   <= STATE_IDLE_4;
			end;
		end
		
		STATE_RW3: begin
			state       <= STATE_RW4;
			command     <= CMD_WRITE;
			SDRAM_DQ <= saved_data[63:48];
			SDRAM_A[12:11] <= saved_mask[7:6];
			SDRAM_BA <= {2'b01};
			SDRAM_A[0] <= 1'b0;
		end

		STATE_RW4: begin
			state       <= STATE_IDLE;
			command     <= CMD_WRITE;
			SDRAM_DQ <= saved_data[47:32];
			SDRAM_A[12:11] <= saved_mask[5:4];
			SDRAM_A[0] <= 1'b1;
			ch1_ready   <= 1;
		end

		STATE_ACT1: begin
			state      <= STATE_ACT2;
		end
		
		STATE_ACT2: begin
			{SDRAM_BA,SDRAM_A} <= {2'b01,ch1_caddr[12:0]}; // no auto precharge
			command    <= CMD_ACTIVE;
			state      <= STATE_IDLE;
		end
		
		STATE_PRE1: begin
			state      <= STATE_PRE2;
		end
		
		STATE_PRE2: begin
			{SDRAM_BA,SDRAM_A} <= {2'b01,2'b00,1'b0,10'h0}; // no auto precharge
			command    <= CMD_PRECHARGE;
			state      <= STATE_IDLE;
		end
	endcase

	if(ch3_req && ch3_rnw) begin
		ch3_dout  <= ch3_din;
//		ch3_data  <= ch3_din;
		ch3_ready <= 0;
	end

	if (init) begin
		state <= STATE_STARTUP;
		refresh_count <= startup_refresh_max - sdram_startup_cycles;
		ch2_ready <= 0;
	end
end
wire [3:0] ch_tmp = ch2_addr[23:20]==4'h5 ? ch3_addr[23:20] : ch2_addr[23:20]==4'h4 ? ch3_addr[19:16] : ch2_addr[23:20]==4'h3 ? ch3_addr[15:12] 
                  : ch2_addr[23:20]==4'h2 ? ch3_addr[11:8]  : ch2_addr[23:20]==4'h1 ? ch3_addr[7:4]   : ch2_addr[23:20]==4'h0 ? ch3_addr[3:0]
						: ch2_addr[23:20];

altddio_out
#(
	.extend_oe_disable("OFF"),
	.intended_device_family("Cyclone V"),
	.invert_output("OFF"),
	.lpm_hint("UNUSED"),
	.lpm_type("altddio_out"),
	.oe_reg("UNREGISTERED"),
	.power_up_high("OFF"),
	.width(1)
)
sdramclk_ddr
(
	.datain_h(1'b0),
	.datain_l(1'b1),
	.outclock(clk),
	.dataout(SDRAM_CLK),
	.aclr(1'b0),
	.aset(1'b0),
	.oe(1'b1),
	.outclocken(1'b1),
	.sclr(1'b0),
	.sset(1'b0)
);

endmodule
