// altera message_off 10036
 
// Functional; no netlist
module _butch
(
	input resetl,
	input clk,
	input cart_ce_n,
	input cd_en,
	input cd_ex,
	input aud_sess,
	input eoe0l,
	input eoe1l,
	input ewe0l,
	input ewe2l,
	input  [23:0] ain,
	input  [31:0] din,
	output [31:0] dout,
	output doe,
	output i2srxd,
	output sen,
	output sck,
	output ws,
	output eint,
	output override,
	output [28:0] audbus_out,
	input  [63:0] aud_in,
	output aud_ce,
	input  audwaitl,
	input [8:0] toc_addr,
	input [15:0] toc_data,
	input toc_wr,
	input maxc,
	output [23:0] addr_ch3,
	output eeprom_cs,
	output eeprom_sk,
	output eeprom_dout,
	input eeprom_din,
input dohacks,
output hackbus,
output hackbus1,
output hackbus2,
output overflowo,
output underflowo,
output errflowo,
output unhandledo,
	input sys_clk
);


wire wet = !cart_ce_n && !(ewe0l && ewe2l);
wire oet = !cart_ce_n && !(eoe0l && eoe1l);
//BUTCH     equ  $DFFF00	c; base of Butch=interrupt control register, R/W
//DSCNTRL   equ  BUTCH+4	; DSA control register, R/W
//DS_DATA   equ  BUTCH+$A	; DSA TX/RX data, R/W
//I2CNTRL   equ  BUTCH+$10	; i2s bus control register, R/W
//SBCNTRL   equ  BUTCH+$14	; CD subcode control register, R/W
//SUBDATA   equ  BUTCH+$18	; Subcode data register A
//SUBDATB   equ  BUTCH+$1C	; Subcode data register B
//SB_TIME   equ  BUTCH+$20	; Subcode time and compare enable (D24)
//FIFO_DATA equ  BUTCH+$24	; i2s FIFO data
//I2SDAT1   equ  BUTCH+$24	; i2s FIFO data
//I2SDAT2   equ  BUTCH+$28	; i2s FIFO data
//EEPROM    equ  BUTCH+$2C	; interface to CD-eeprom
reg [31:0] butch_reg [0:11];
//BUTCH     equ  $DFFF00	c; base of Butch=interrupt control register, R/W
//assign eint = (!butch_reg[0][0]) || (!fifo_int && !frame_int &&!sub_int && !tbuf_int && !rbuf_int);
assign eint = (butch_reg[0][0]) && (fifo_int || frame_int || sub_int || tbuf_int || rbuf_int);
wire fifo_int = butch_reg[0][9] && butch_reg[0][1];
wire frame_int = butch_reg[0][10] && butch_reg[0][2];
wire sub_int = butch_reg[0][11] && butch_reg[0][3];
wire tbuf_int = butch_reg[0][12] && butch_reg[0][4];
wire rbuf_int = butch_reg[0][13] && butch_reg[0][5];
wire cd_crcerror = butch_reg[0][6];
wire cderror = butch_reg[0][14];
wire cdreset = butch_reg[0][17];
wire cdbios = butch_reg[0][18];
wire cdopenlidreset = butch_reg[0][19];
wire cdkartpullreset = butch_reg[0][20];

//DSCNTRL   equ  BUTCH+4	; DSA control register, R/W
//	tst.l	BUTCH+DSCNTRL	;****22-May-95 clear DSA_rx if any
//	move.l	#$10000,DSCNTRL	; enable DSA
//	move.l	#$10000,O_DSCNTRL(a4)	;turn on DSA bus
//	tst.l	O_DSCNTRL(a4)		;read to clear interrupt flag
//	move.l	#0,BUTCH+4	;clear DSA
//	tst.l	DSCNTRL(a0)	;clear DSA_rx

//DS_DATA   equ  BUTCH+$A	; DSA TX/RX data, R/W
//; Clear pending DSA interrupts
//	move.w	BUTCH+DS_DATA,d0
//	cmpi.w	#$42c,d0	;check for tray error (only recoverable)
//	cmpi.w	#$402,d0	;was it focus error? (no disc)
//	move.w	DS_DATA,d0
//	move.l	DSCNTRL,d0
// 00h No error
// 02h Focus error, or no disc
// 07h Subcode error, no valid subcode
// 08h TOC error, out of lead-in area while reading TOC
// 0Ah Radial error
// 0Ch Fatal sledge error
// 0Dh Turn table motor error
// 30h Emergency Stop
// 1Fh Search time out
// 20h Search binary error
// 21h Search index error
// 22h Search time error
// 28h Illegal command
// 29h Illegal value
// 2Ah Illegal time value
// 2Bh Communication error
// 2Ch Reserved - Tray error??
// 2Dh HF Detector Error

//I2CNTRL   equ  BUTCH+$10	; i2s bus control register, R/W
wire i2s_drive = butch_reg[4][0];
wire i2s_jerry = butch_reg[4][1];
wire i2s_fifo_enabled = butch_reg[4][2]; // guess. turned on in read handler (gas/das)
wire i2s_16bit = butch_reg[4][3]; // ? only affects i2s format?
wire i2s_fifonempty = i2s_rfifopos != i2s_wfifopos;//butch_reg[4][4];
reg [31:0] ds_resp [0:4];
reg [2:0] ds_resp_idx;
reg [2:0] ds_resp_size; // max = 5
reg [6:0] ds_resp_loop; // max = numtracks=99
reg updresp; // signals for TOC responses to move to next one
reg updrespa;

//SBCNTRL   equ  BUTCH+$14	; CD subcode control register, R/W
//SUBDATA   equ  BUTCH+$18	; Subcode data register A
//SUBDATB   equ  BUTCH+$1C	; Subcode data register B
//SB_TIME   equ  BUTCH+$20	; Subcode time and compare enable (D24)
reg [6:0] rframes;  // 0-74 // (msf % 75)
reg [5:0] rseconds; // 0-59 // (msf / 75) % 60
reg [6:0] rminutes; // 0-99 // (msf / 75) / 60
reg [6:0] aframes;  // 0-74 // (msf % 75)
reg [5:0] aseconds; // 0-59 // (msf / 75) % 60
reg [6:0] aminutes; // 0-99 // (msf / 75) / 60
reg [6:0] atrack;   // 1-99
wire [7:0] subcode [0:11];
assign subcode[0] = 8'h1; // 2 channel audio no preemphasis, address 1
assign subcode[1] = bcd[atrack]; // trackno bcd
assign subcode[2] = 8'h0; // trackidx bcd
assign subcode[3] = bcd[rminutes]; // rel min bcd
assign subcode[4] = bcd[{1'b0,rseconds}]; // rel sec bcd
assign subcode[5] = bcd[rframes]; // rel frames bcd
assign subcode[6] = 8'h0; // zero
assign subcode[7] = bcd[aminutes]; // abs min bcd
assign subcode[8] = bcd[{1'b0,aseconds}]; // abs sec bcd
assign subcode[9] = bcd[aframes]; // abs frames bcd
assign subcode[10] = crc1; // crc1 Polynomial = P(X)=X16+X12+X5+1
assign subcode[11] = crc0; // crc0
reg [7:0] crc1;
reg [7:0] crc0;
reg [15:0] crc;
reg recrc;
reg [3:0] subidx;
wire [15:0] subresp = {subcode[subidx],4'h1,subidx};
wire subbit = subcode[crcidx[6:3]][~crcidx[2:0]];
wire [15:0] crcs = nextcrcb ? crc ^ {subcode[crcidx[6:3]],8'h00} : crc;
wire [15:0] nextcrc = {crcs[14:0],1'b0};
wire nextcrcb = crcidx[2:0] == 3'h0;
reg [6:0] crcidx;

//FIFO_DATA equ  BUTCH+$24	; i2s FIFO data
//I2SDAT1   equ  BUTCH+$24	; i2s FIFO data
//I2SDAT2   equ  BUTCH+$28	; i2s FIFO data
reg [31:0] i2s_fifo [0:15];
wire [31:0] cur_i2s_fifo = {i2s_fifo[i2s_rfifopos[3:0]]};
reg [4:0] i2s_rfifopos;
reg [4:0] i2s_wfifopos;
reg fifo_inc;
// I2SDAT2 appears to be I2SDAT1 identical. Different to make reading consecutively possible.
wire [4:0] fifo_fill = (i2s_wfifopos - i2s_rfifopos);
// Not sure how big fifo is. CDBIOS seems to say 8 is half but accidentally reads 9?
// Works if 9th is fetched while reading processing 8 (2x speed only)
wire fifo_half = (fifo_fill >= 5'h8);

//EEPROM    equ  BUTCH+$2C	; interface to CD-eeprom
//;  bit3 - busy if 0 after write cmd, or Data In after read cmd 
//;  bit2 - Data Out
//;  bit1 - clock
//;  bit0 - Chip Select (CS)
assign eeprom_cs   = !butch_reg[11][0]; //;  bit0 - Chip Select (CS)
assign eeprom_sk   = butch_reg[11][1]; //;  bit1 - clock
assign eeprom_dout = butch_reg[11][2]; //;  bit2 - Data Out
//assign eeprom_din  = butch_reg[11][3]; //;  bit3 - busy if 0 after write cmd, or Data In after read cmd    // from eeprom

reg [29:0] aud_add; // max 1GB is more than CD
reg [29:0] aud_adds; // max 1GB is more than CD
reg [6:0] track_idx;
reg aud_rd;
reg old_aud_rd;
reg old_aud_rd2;
reg old_aud_rd3;
assign audbus_out = aud_adds[28:0]; // max 64MB - old_aud_rd will delay one cycle to match aud_adds delay
assign aud_ce = cd_en && old_aud_rd2; // give aud_rd two cycles for track offset fetch and addition
assign addr_ch3 = maxc ? add_ch3 : max_ch3;

reg hackwait;
assign hackbus = 1'b0;//cd_en && aud_sess && (ain[23:8]==16'h002C) && hackwait;
//assign hackbus1 = cd_en && aud_sess && (({ain[23:2],2'b00}==24'h050DF4) || ({ain[23:1],1'b0}==24'h050E8A) || ({ain[23:1],1'b0}==24'h050E8C)) && hackwait;
assign hackbus1 = dohacks && cd_en && aud_sess && (({ain[23:2],2'b00}==24'h050DF4)) && hackwait;
assign hackbus2 = 1'b0;//cd_en && aud_sess && (({ain[23:1],1'b0}==24'h050EC0)) && hackwait;
assign override = cdbios && cd_en;
assign doe = cd_en && oet && (breg || (!cdbios && caddr));
assign dout[31:0] = (aeven) ? dout_t[31:0] : {dout_t[15:0],dout_t[15:0]};
wire [31:0] dout_t = doe_ds ? ds_resp[ds_resp_idx] : doe_sub ? {subresp,subresp} : doe_fif ? cur_i2s_fifo : butch_reg[ain[5:2]];
wire aeven = (ain[1]==1'b0); //even is high [31:16]
wire breg = ain[23:8]==24'hdfff;
wire caddr = ain[23:22]==2'b10;
wire dsc_a = ain[5:2]==4'h1;
wire doe_dsc = doe && dsc_a;
wire ds_a = ain[5:2]==4'h2; // should be 0xA not just 0x8?
wire doe_ds = doe && ds_a;
wire ictl_a = ain[5:2]==4'h4; // 0x10
wire doe_ictl = doe && ictl_a;
wire sub_a = ain[5:2]==4'h6; // should be 0x1A not just 0x18?
wire doe_sub = doe && sub_a;
wire fif_a1 = ain[5:2]==4'h9; // 0x24
wire fif_a2 = ain[5:2]==4'hA; // 0x28
wire fif_a = fif_a1 || fif_a2; // 0x24 or 0x28
wire doe_fif = doe && fif_a;
wire mem_a = ain[23:8]==16'hf160;
reg [23:0] add_ch3;
reg [23:0] max_ch3;

reg old_doe_ds;
reg old_doe_dsc;
reg old_doe_sub;
reg old_doe_fif;
reg old_fif_a1;
reg old_ws;

//wire [6:0] num_tracks = 7'd6;
wire [6:0] num_tracks = cue_tracks[6:0];
//  1 frame = 588 longs (samples) = 2352 bytes
// 75 frames = 1 second
// 60 frames = 1 minute
// 90us @ x2 = 31.752 bytes
// 90.703us @ x2 = 32 bytes
// 9647.5 cycles @ 106.36MHz = 90.703us
// 358200 bytes/sec at double rate
// 265909/(358.2*8) = 9.279 cycles/bit
// 746.9MB = 317560 frames = 70.57 minutes max
// 24'h1AF05E = which pattern 0-9
wire [6:0] frames_end = cuest[num_tracks[2:0]+3'h1][6:0];    // 0-74 // (msf % 75)
wire [5:0] seconds_end = cuest[num_tracks[2:0]+3'h1][13:8];  // 0-59 // (msf / 75) % 60
wire [6:0] minutes_end = cuest[num_tracks[2:0]+3'h1][22:16]; // 0-99 // (msf / 75) / 60
reg [9:0] cur_samples;  // 0-587
reg [6:0] cur_frames;   // 0-74 // (msf % 75)
reg [5:0] cur_seconds;  // 0-59 // (msf / 75) % 60
reg [6:0] cur_minutes;  // 0-99 // (msf / 75) / 60
reg [6:0] cur_rframes;   // 0-74 // (msf % 75)
reg [5:0] cur_rseconds;  // 0-59 // (msf / 75) % 60
reg [6:0] cur_rminutes;  // 0-99 // (msf / 75) / 60
reg [6:0] cur_aframes;  // 0-74 // (msf % 75)
reg [5:0] cur_aseconds; // 0-59 // (msf / 75) % 60
reg [6:0] cur_aminutes; // 0-99 // (msf / 75) / 60
reg old_upd_frames;
reg upd_frames;
reg upd_seconds;
reg upd_minutes;

reg [63:0] fifo [0:3];
//reg [1:0] faddr;
wire [1:0] faddr = {cur_samples[0],wsout};
reg valid;
reg [15:0] sdin;
reg [15:0] sdin3;
reg [15:0] sdin4;
reg mounted;
reg spinpause;
reg pause;
reg stop;
reg [4:0] splay;
reg play;
reg old_play;
reg old_clk;
reg old_resetl;
reg [15:0] cntr;
reg [7:0] mode;
wire speed1x = mode[0];
wire speed2x = mode[1];
wire cdrommd = mode[3];//audiomd==0
wire attiabs = mode[4];
wire attirel = mode[5];
wire pausetr = mode[6];

reg updabs;
reg [7:0] seek;
reg [6:0] sframes; // 0-74  // (msf % 75)
reg [5:0] sseconds; // 0-59 // (msf / 75) % 60
reg [6:0] sminutes; // 0-99 // (msf / 75) / 60
reg [2:0] gframes; // 0-6 gap frames

reg [15:0] fdata;
reg [63:0] fd;

reg [7:0] seek_count;
wire aud_busy = (old_aud_rd3) || (old_aud_rd2) || (old_aud_rd) || (aud_rd) || (!audwaitl);
reg [18:0] taud_add;
reg [29:8] taud2_add;
reg [23:4] taud3_add;
reg [5:0] subtseconds; // 0-59
reg [5:0] subtrseconds; // 0-59
reg [15:0] last_ds;
reg [31:0] seek_delay;
reg overflow;
reg underflow;
reg errflow;
reg unhandled;
assign overflowo = overflow;
assign underflowo = underflow;
assign errflowo = errflow;
assign unhandledo = unhandled || pastcdbios;
reg search_forward;
reg search_backward;
reg search_fast;
reg search_borderflag;
reg abplay;
reg [7:0] abseek;
reg [6:0] abaframes; // 0-74  // (msf % 75)
reg [5:0] abaseconds; // 0-59 // (msf / 75) % 60
reg [6:0] abaminutes; // 0-99 // (msf / 75) / 60
reg [6:0] abbframes; // 0-74  // (msf % 75)
reg [5:0] abbseconds; // 0-59 // (msf / 75) % 60
reg [6:0] abbminutes; // 0-99 // (msf / 75) / 60

reg [6:0] cues_addr;
reg [6:0] cuet_addr;
assign cues_add = cues_addr;
assign cuep_add = cues_addr;
assign cuel_add = cues_addr;
assign cuet_add = cuet_addr;
reg [23:0] cues_dinv;
reg [23:0] cuep_dinv;
reg [23:0] cuel_dinv;
reg [31:0] cuet_dinv;
assign cues_din = cues_dinv;
assign cuep_din = cuep_dinv;
assign cuel_din = cuel_dinv;
assign cuet_din = cuet_dinv;
reg cues_wrr;
reg cuep_wrr;
reg cuel_wrr;
reg cuet_wrr;
assign cues_wr = cues_wrr;
assign cuep_wr = cuep_wrr;
assign cuel_wr = cuel_wrr;
assign cuet_wr = cuet_wrr;
reg [7:0] resetstate;

//`define ULS_REBOOT
// Klax, Tetris
//Session 1 has 2 track(s)
//Creating cuesheet...
//Saving  Track:  1  Type: Audio/2352  Size: 3346    LBA: 0       
//Saving  Track:  2  Type: Audio/2352  Size: 894     LBA: 3496    
//                                                          
//Session 2 has 4 track(s)
//Creating cuesheet...
//Saving  Track:  3  Type: Audio/2352  Size: 618     LBA: 15640   
//Saving  Track:  4  Type: Audio/2352  Size: 669     LBA: 16408   
//Saving  Track:  5  Type: Audio/2352  Size: 669     LBA: 17077   
//Saving  Track:  6  Type: Audio/2352  Size: 448     LBA: 17746   
//00 00 01 06 02 04 02 2C 01 00 02 00 00 00 2C 2E
//02 00 2E 2E 00 00 0B 45 03 03 1E 28 01 00 08 12
//04 03 26 3A 01 00 08 45 05 03 2F 34 01 00 08 45 
//06 03 38 2E 01 00 05 49 00 00 00 00 00 00 00 00
reg [6:0] cue_tracks;
reg [6:0] aud_tracks;
reg [6:0] dat_tracks;
reg [6:0] dat_track;
initial begin
	cue_tracks <= 7'd6; //
	aud_tracks <= 7'd2;
	dat_tracks <= 7'd4;
	dat_track <= 7'd3;
end
reg [23:0] cuestop [0:1];
initial begin
	cuestop[1'h0] <= 24'h003A28; //
	cuestop[1'h1] <= 24'h04022C; //
end
// These are redundant with RAMs. Was implemented this way first then, intended to move to ram blocks. Remove when transition complete.
reg [31:0] cuett [0:63];
integer k;
initial begin
	cuett[6'h00] <= 32'h00000000;
	cuett[6'h01] <= 32'h00000000;
	cuett[6'h02] <= 32'h01000000;
	cuett[6'h03] <= 32'h02000000;
	cuett[6'h04] <= 32'h03000000;
	cuett[6'h05] <= 32'h04000000;
	cuett[6'h06] <= 32'h05000000;
 for (k = 7; k < 64; k = k + 1)
 begin
	cuett[k] <= 32'h00;
 end
end
reg [23:0] cuest [0:63];
initial begin
	cuest[6'h00] <= 24'h000000;
	cuest[6'h01] <= 24'h000200; //2s
	cuest[6'h02] <= 24'h002E2E;
	cuest[6'h03] <= 24'h031E28; //2s //h004228
	cuest[6'h04] <= 24'h03263A; //h004C3A
	cuest[6'h05] <= 24'h032F34; //h005736
	cuest[6'h06] <= 24'h03382E; //h006230
 for (k = 7; k < 64; k = k + 1)
 begin
	cuest[k] <= 24'h04022C; //h006A2E
 end
end
reg [23:0] cuept [0:63];
initial begin
	cuept[6'h00] <= 24'h000000;
	cuept[6'h01] <= 24'h000200; //2s
	cuept[6'h02] <= 24'h002E2E;
	cuept[6'h03] <= 24'h031E28; //2s //h004228
	cuept[6'h04] <= 24'h03263A; //h004C3A
	cuept[6'h05] <= 24'h032F34; //h005736
	cuept[6'h06] <= 24'h03382E; //h006230
 for (k = 7; k < 64; k = k + 1)
 begin
	cuept[k] <= 24'h04022C; //h006A2E
 end
end
reg [23:0] cuelt [0:63];
initial begin
	cuelt[6'h00] <= 24'h000000;
	cuelt[6'h01] <= 24'h002C2E; // 7869792 = 3346f == d'004446
	cuelt[6'h02] <= 24'h000B45; // 2102688 =  894f == d'001169
	cuelt[6'h03] <= 24'h000812; // 1453536 =  618f == d'000818
	cuelt[6'h04] <= 24'h000845; // 1573488 =  669f == d'000869
	cuelt[6'h05] <= 24'h000845; // 1573488 =  669f == d'000869
	cuelt[6'h06] <= 24'h000549; // 1053696 =  448f == d'000573
 for (k = 7; k < 64; k = k + 1)
 begin
	cuelt[k] <= 24'h000000;
 end
end

// CRC calculator
always @(posedge sys_clk)
begin
	if (recrc == 1'b1) begin
		crc <= {16'h0000};
		crcidx <= 7'h00;
		crc1  <= 8'h0;
		crc0  <= 8'h0;
		rframes <= cur_rframes;
		rseconds <= cur_rseconds;
		rminutes <= cur_rminutes;
		aframes <= cur_aframes;
		aseconds <= cur_aseconds;
		aminutes <= cur_aminutes;
		atrack <= track_idx;
	end
	if (clk && ~old_clk) begin
		if (crcidx != 7'h50) begin
			crc[15:0] <= nextcrc ^ {crcs[15] ? 16'h1021 : 16'h0000};
			crcidx <= crcidx + 7'd1;
		end
	end
	if (crcidx == 7'h50) begin
		crc1[7:0] <= ~crc[15:8];
		crc0[7:0] <= ~crc[7:0];
	end
end

reg [23:0] cueptemp;
reg [23:16] cuestoptemp;
reg tocsess1;
reg pastcdbios;

always @(posedge sys_clk)
begin
	aud_adds[28:0] <= aud_add[28:0] + cuet_dout[28:0]; // old_aud_rd will delay one cycle to match aud_adds delay
	cuelast[23:0] <= {carrys?cuel_dout[23:16]-8'h1:cuel_dout[23:16],carrys?8'h3B:carryf?cuel_dout[15:8]-8'h1:cuel_dout[15:8],carryf?8'h4A:cuel_dout[7:0]-8'h1};
	recrc <= 1'b0;
	updresp <= 1'b0;
	updrespa <= 1'b0;
	aud_rd <= 1'b0;
	old_doe_ds <= doe_ds;
	old_doe_dsc <= doe_dsc;
	old_doe_sub <= doe_sub;
	old_doe_fif <= doe_fif;
	old_fif_a1 <= fif_a1;
	old_clk <= clk;
	old_resetl <= resetl;
	old_play <= play;
	old_aud_rd <= aud_rd;
	old_aud_rd2 <= old_aud_rd;
	old_aud_rd3 <= old_aud_rd2;
	old_upd_frames <= upd_frames;
	butch_reg[11][3] <= eeprom_din;
	if (!resetl) begin
	hackwait <= 1'b0;
	seek_count <= 8'h0;
	pastcdbios <= 1'b0;
		mounted <= 1'b0;
		splay <= 5'h0;
		play <= 1'b0;
		stop <= 1'b0;
		pause <= 1'b0;
		spinpause <= 1'b0;
		i2s1w <= 1'b0;
		i2s2w <= 1'b0;
		i2s3w <= 1'b0;
		i2s4w <= 1'b0;
		aud_rd <= 1'b0;
		aud_add <= 30'h000000;
		unhandled <= 1'b0;
		upd_frames <= 1'b0;
		upd_seconds <= 1'b0;
		upd_minutes <= 1'b0;
		mode <= 1'b0;
		sdin[15:0] <= 0;
		sdin3[15:0] <= 0;
		sdin4[15:0] <= 0;
		butch_reg[0] <= 32'h40000; // bios_rom
		butch_reg[1] <= 0;
		butch_reg[2] <= 0;
		butch_reg[3] <= 0;
		butch_reg[4] <= 0;
		butch_reg[5] <= 0;
		butch_reg[6] <= 0;
		butch_reg[7] <= 0;
		butch_reg[8] <= 0;
		butch_reg[9] <= 0;
		butch_reg[10] <= 0;
		butch_reg[11] <= 0;
		add_ch3[23:0] <= 24'h543210;
		max_ch3[23:0] <= 24'h543210;
		resetstate <= 8'hFF;
		seek <= 8'h0;
		i2s_rfifopos <= 5'h0;
		i2s_wfifopos <= 5'h0;
		fifo_inc <= 1'b0;
		i2s_fifo[0] <= 0;
		overflow <= 1'b0;
		underflow <= 1'b0;
		errflow <= 1'b0;
	end
	if (!cdbios)
		pastcdbios <= 1'b1;

	if (toc_wr) begin
		if (toc_addr[2:0] == 3'h0) begin
			cuest[toc_addr[8:3]][23:8] <= toc_data[15:0];
			cueptemp[23:8] <= toc_data[15:0];
			//cuept[toc_addr[8:3]][23:8] <= toc_data[15:0];
		end
		if (toc_addr[2:0] == 3'h1) begin
			cuest[toc_addr[8:3]][7:0] <= toc_data[15:8];
			cueptemp[7:0] <= toc_data[15:8];
			//cuept[toc_addr[8:3]][7:0] <= toc_data[15:8];
			cuelt[toc_addr[8:3]][23:16] <= toc_data[7:0];
		end
		if (toc_addr[2:0] == 3'h2) begin
			cuelt[toc_addr[8:3]][15:0] <= toc_data[15:0];
		end
		if (toc_addr[2:0] == 3'h3) begin
			//cue_gap[15:0] <= toc_data[15:0]; // logic below assumes gap is not larger than 2 seconds
			cueptemp[7:0] <= cueptemp[7:0] - toc_data[7:0];
			cueptemp[14:8] <= cueptemp[14:8] - toc_data[14:8];
		end
		if (toc_addr[2:0] == 3'h4) begin
			cuett[toc_addr[8:3]][31:24] <= toc_data[7:0];
			tocsess1 <= 1;
			if (toc_data[15:9] == 0) begin //session 1 == (0 or 1)
				aud_tracks <= toc_addr[8:3];
				tocsess1 <= 0;
			end
			cue_tracks <= toc_addr[8:3];
			if (cueptemp[7]) begin
				cueptemp[7:0] <= cueptemp[7:0] + 8'h4B;
				cueptemp[14:8] <= cueptemp[14:8] - (7'h1);
			end
		end
		if (toc_addr[2:0] == 3'h5) begin
			cuett[toc_addr[8:3]][23:8] <= toc_data[15:0];
			dat_tracks <= cue_tracks - aud_tracks;
			dat_track <= aud_tracks + 4'h1;
			if (cueptemp[14]) begin
				cueptemp[14:8] <= cueptemp[14:8] + 7'h3C;
				cueptemp[23:16] <= cueptemp[23:16] - (1'b1);
			end
		end
		if (toc_addr[2:0] == 3'h6) begin
			cuett[toc_addr[8:3]][7:0] <= toc_data[15:8];
			cuept[toc_addr[8:3]][23:0] <= cueptemp[23:0];
			cuestoptemp[23:16] <= toc_data[7:0];
		end
		if (toc_addr[2:0] == 3'h7) begin
			if (cuestoptemp[23:16] != 0 || toc_data[15:0] != 0) begin
				cuestop[tocsess1][23:16] <= cuestoptemp[23:16];
				cuestop[tocsess1][15:0] <= toc_data[15:0];
			end
		end
	end
	cues_wrr <= 0;
	cuep_wrr <= 0;
	cuel_wrr <= 0;
	cuet_wrr <= 0;
	if (resetstate[7] != 1'b0) begin
		resetstate <= resetstate - 8'h1;
		cues_addr <= {1'h0,resetstate[6:1]};
		cuet_addr <= {1'h0,resetstate[6:1]};
		cues_dinv <= (resetstate[6:1] > cue_tracks) ? cuestop[1'b1] : cuest[resetstate[6:1]];
		cuep_dinv <= (resetstate[6:1] > cue_tracks) ? cuestop[1'b1] : cuept[resetstate[6:1]];
		cuel_dinv <= (resetstate[6:1] > cue_tracks) ? 24'h0 : cuelt[resetstate[6:1]];
		cuet_dinv <= (resetstate[6:1] > cue_tracks) ? 32'h0 : cuett[resetstate[6:1]];
		cues_wrr <= !resetstate[0];
		cuep_wrr <= !resetstate[0];
		cuel_wrr <= !resetstate[0];
		cuet_wrr <= !resetstate[0];
	end
	if (resetstate == 8'h0F) begin
		resetstate <= 8'h0;
	end
	if (updabs) begin
		updabs <= 1'b0;
		cur_aframes <= cues_dout[6:0];
		cur_aseconds <= cues_dout[13:8];
		cur_aminutes <= cues_dout[22:16];
	end
	if (seek != 8'h0) begin
		if (seek[7]) begin
			seek[0] <= !seek[0];
			seek[1] <= seek[0];
			if (!seek[1]) begin
				if ((cues_addr == 7'h0) || ({sminutes,2'b00,sseconds,1'b0,sframes} >= (cuep_dout[22:0]))) begin // fix this
					seek <= 8'h7F;
					track_idx <= cues_addr;
					cur_aframes <= sframes;
					cur_aseconds <= sseconds;
					cur_aminutes <= sminutes;
					if ({sminutes,2'b00,sseconds,1'b0,sframes} < (cuep_dout[22:0])) begin
						seek <= 8'h3F;
						cur_frames <= 7'h0;
						cur_seconds <= 6'h0;
						cur_minutes <= 7'h0;
						cur_rframes <= 7'h0;
						cur_rseconds <= 6'h0;
						cur_rminutes <= 7'h0;
						gframes <= 3'h6;
					end else begin
						cur_frames <= sframes - cuep_dout[6:0] + ((sframes >= cuep_dout[6:0]) ? 7'h0 : 7'h4B);
						subtseconds <= (cuep_dout[13:8] + ((sframes >= cuep_dout[6:0]) ? 6'h0 : 6'h1));
						gframes <= 3'h0;
						if ({sminutes,2'b00,sseconds,1'b0,sframes} < (cuep_dout[22:0])) begin
							cur_rframes <= sframes - cues_dout[6:0] + ((sframes >= cues_dout[6:0]) ? 7'h0 : 7'h4B);
							subtrseconds <= (cues_dout[13:8] + ((sframes >= cues_dout[6:0]) ? 6'h0 : 6'h1));
						end else begin
							cur_rframes <= 7'h0;
							cur_rseconds <= 6'h0;
							cur_rminutes <= 7'h0;
							subtrseconds <= 6'h0;
						end
					end
				end else begin
					cues_addr <= cues_addr - 7'h1;
					cuet_addr <= cues_addr - 7'h1;
					seek[1:0] <= 2'b11;
				end
			end
		end else if (seek[6]) begin
			if (seek[0]) begin
				seek[0] <= 1'b0;
				cur_seconds <= sseconds - subtseconds + ((sseconds >= subtseconds) ? 6'h0 : 6'h3C);
				cur_minutes <= sminutes - cuep_dout[22:16] - ((sseconds >= subtseconds) ? 6'h0 : 6'h1);
				cur_rseconds <= sseconds - subtrseconds + ((sseconds >= subtrseconds) ? 6'h0 : 6'h3C);
				cur_rminutes <= sminutes - cues_dout[22:16] - ((sseconds >= subtrseconds) ? 6'h0 : 6'h1);
			end else begin
				seek <= 8'h3F;
//				cur_seconds <= cur_seconds + ((cues_gap) ? ((cur_seconds == 6'h3B) || (cur_seconds == 6'h3A)) ? 6'h6 : 6'h2 : 6'h0); //6=wrap 2+ 4=64-60
//				cur_minutes <= cur_minutes + ((cues_gap) && ((cur_seconds == 6'h3B) || (cur_seconds == 6'h3A)) ? 7'h1 : 7'h0);
			end
		end else if (seek[5]) begin
			seek[5] <= 1'b0;
			// *60=<<6 - <<2
			taud_add[12:0] <= {{cur_minutes,4'h0} - {4'h0,cur_minutes},2'h0};
			taud_add[18:13] <= 6'h0;
		end else if (seek[4]) begin
			seek[4] <= 1'b0;
			taud_add[12:0] <= {taud_add[12:0]} + {cur_seconds};
		end else if (seek[3]) begin
			seek[3] <= 1'b0;
			// *75=<<6 + <<3 + <<1 + <<0
			taud_add[18:0] <= {taud_add[12:0],6'h0} + {taud_add[12:0],3'h0} + {taud_add[12:0],1'h0} + {taud_add[12:0]};//[19] is always 0
		end else if (seek[2]) begin
			seek[2] <= 1'b0;
			taud_add[18:0] <= {taud_add[18:0]} + {cur_frames};//[19] is always 0
		end else if (seek[1]) begin
			// *2352=<<11 + <<8 + <<5 + <<4
			seek[1] <= 1'b0;
			taud2_add[29:8] <= {taud_add[18:0],3'h0} + {taud_add[18:0]};
			taud3_add[23:4] <= {taud_add[18:0],1'h0} + {taud_add[18:0]};
//			seek_delay <= 31'h3F00;
			seek_delay <= 31'h7000; // TODO: Improve
		end else if (seek[0]) begin
			if (seek_delay != 0) begin
				seek_delay <= seek_delay - 16'h1;
				if (seek_delay == 16'h1) begin
					seek[0] <= 1'b0;
					// *2352=<<11 + <<8 + <<5 + <<4
					aud_add[29:0] <= {{taud2_add[29:8],4'h0} + {taud3_add[23:4]},4'h0};//[31:30] are always 0
					aud_rd <= 1'b1;
					cur_samples <= 10'h0;
					splay <= 5'h5;
					splay[4] <= i2s_jerry || i2s_fifo_enabled;
					stop <= 1'b0;
					upd_frames <= 1'b1;
//					ds_resp[0] <= 32'h0140; // dsa says 0x140; code is looking for 0x100
					ds_resp[0] <= 32'h0100;
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					i2s_wfifopos <= 5'h0;
					i2s_rfifopos <= 5'h0;
					overflow <= 1'b0;
					errflow <= 1'b0;
if (!seek_count[7]) begin
 seek_count <= seek_count + 8'h1;
end
// This is nonesense to keep signals for SignalTap
if (seek_count==8'hff && last_ds==16'hffff && mode==8'hFF) begin
 stop <= 1'b1;
end
hackwait <= (seek_count==4'h1) || (seek_count==4'h4);
				end
			end
		end
	end
	if (clk && ~old_clk) begin
		i2s1w <= 1'b0;
		i2s2w <= 1'b0;
		i2s3w <= 1'b0;
		i2s4w <= 1'b0;
		if (resetl && ~old_resetl) begin
			i2s3w <= 1'b1;
//			sdin3[15:0] <= 16'h3; // 2*(3+1)=8 faster than 9.279
			sdin3[15:0] <= 16'h8; // 2*(8+1)=18 faster than 18.558
		end
		if (splay != 5'h0) begin
			if (splay[3:0] == 4'h5) begin
				if (!aud_busy) begin
					//aud_add <= 32'h0; // Should be already set
					aud_rd <= 1'b1;     // Request Fifo
					splay[3:0] <= 4'h4;
				end
			end else if (splay[3:0] == 4'h4) begin
				if (!aud_busy) begin
					fd <= 64'h0;
					fifo[3] <= 'h0;
					fifo[2] <= 'h0;
					fifo[1] <= 'h0;
					fifo[0] <= aud_in;     // Fill fifo
					aud_add <= aud_add + 4'h8;
					aud_rd <= 1'b1;     // Request next fifo for when fifo used
					//track_idx will never change here.
					if (!splay[4]) begin
						splay <= 5'h0;
					end else begin
						splay <= 5'h3;
					end
				end
			end else begin
				if (splay == 5'h3) begin
					splay <= 5'h2;
					i2s1w <= 1'b1;
					sdin[15:0] <= 16'h0;
				end
				if (splay == 5'h2) begin
					splay <= 5'h1;
					i2s2w <= 1'b1;
					sdin[15:0] <= 16'h0;
				end
				if (splay == 5'h1) begin
					splay <= 5'h0;
					play <= 1'b1;
					i2s4w <= 1'b1;
					sdin4[15:0] <= 16'h5;
				end
			end
		end
		if (play && !pause && !spinpause) begin
			old_ws <= wsout;
			if (old_ws != wsout) begin
				if (stop != 1'b0) begin
					play <= 1'b0;
					i2s4w <= 1'b1;
					sdin4[15:0] <= 16'h0;
					butch_reg[0][13] <= 1'b1; // |= 0x2000
				end else if (seek != 8'h0) begin
					sdin[15:0] <= 16'h0;
				end else begin
//					faddr[1:0] <= faddr[1:0] + 2'h1;
					i2s1w <= !wsout;
					i2s2w <= wsout;
//					fdata[15:0] = faddr[1] ? (faddr[0] ? {fifo[39:32],fifo[47:40]} : {fifo[55:48],fifo[63:56]}) : (faddr[0] ? {fifo[07:00],fifo[15:8]} : {fifo[23:16],fifo[31:24]});
					fdata[15:0] = fd[15:0];
					fd <= {16'h0,fd[63:16]};
					sdin[15:0] <= (gframes[2:1] != 2'h0) ? 16'h0 : fdata[15:0];
					if (i2s_fifo_enabled && faddr[0] == 1'b0) begin
						i2s_fifo[i2s_wfifopos[3:0]][15:0] <= (gframes != 3'h0) ? 16'h0 : fdata[15:0];
					end
					if (i2s_fifo_enabled && faddr[0] == 1'b1) begin
						i2s_fifo[i2s_wfifopos[3:0]][31:16] <= (gframes != 3'h0) ? 16'h0 : fdata[15:0];
						i2s_wfifopos <= i2s_wfifopos + 5'h1;
						if (i2s_wfifopos == (i2s_rfifopos ^ 5'h10)) begin // fifo overflow
							i2s_rfifopos <= i2s_rfifopos + 4'h1;
							overflow <= 1'b1;
						end
					end
					if (gframes != 3'h0) begin
						fd <= 64'h0;
						valid <= 1'b0;
					end
					if ((faddr[1:0] == 2'b01) && (gframes[2:1] == 2'h0)) begin // handles throwing away first 16 bit value and using fifth in its place (plus endian/ordering nonsense)
						fd[15:0] <= {fifo[3][23:16],fifo[3][31:24]}; // use next fifo; replaces current set below
					end
					if ((faddr[1:0] == 2'b11) && (gframes == 3'h0)) begin //Assumes fifo filled before first entrance and next fifo data already pointed at.
						fd <= {fifo[3][39:32],fifo[3][47:40], fifo[3][23:16],fifo[3][31:24], fifo[3][07:00],fifo[3][15:8], fifo[3][55:48],fifo[3][63:56]}; // endian/ordering nonsense
						fifo[3] <= fifo[2];
						fifo[2] <= fifo[1];
						fifo[1] <= fifo[0];
						fifo[0] <= aud_in;
						if ({cur_aminutes,2'b00,cur_aseconds,1'b0,cur_aframes} < cuep_dout[22:0]) begin
							fifo[1] <= 64'h0;
							fifo[0] <= fifo[0];
						end else if ({cur_minutes,2'b00,cur_seconds,1'b0,cur_frames} >= cuelast[22:0]) begin
							if ({cur_minutes,2'b00,cur_seconds,1'b0,cur_frames} > cuelast[22:0]) begin
								fifo[0] <= 64'h0;
							end
							if ({cur_samples[9:1],1'b0} == 10'd584) begin
								aud_add[29:0] <= 30'h0;
								cuet_addr <= track_idx + 7'h1;
							end else if ({cur_samples[9:1],1'b0} == 10'd586) begin
								aud_add <= aud_add + 4'h8;
								fifo[0] <= aud_in; // pull in above
							end
						end else begin
							aud_add <= aud_add + 4'h8;
						end
						aud_rd <= 1'b1;
						if (aud_busy) begin
							underflow <= 1'b1;
						end
					end
					if (wsout) begin
						cur_samples <= cur_samples + 10'h1;
						if (cur_samples == 10'd587) begin
//							recrc <= 1'b1;
							upd_frames <= 1'b1;
							cur_samples <= 10'h0;
							if ({cur_aminutes,2'b00,cur_aseconds,1'b0,cur_aframes} >= cuep_dout[22:0]) begin
								cur_frames <= cur_frames + 7'h1;
								if (cur_frames == 7'd74) begin
									upd_seconds <= 1'b1;
									cur_frames <= 7'h0;
									cur_seconds <= cur_seconds + 6'h1;
									if (cur_seconds == 6'd59) begin
										upd_minutes <= 1'b1;
										cur_seconds <= 6'h0;
										cur_minutes <= cur_minutes + 7'h1;
									end
								end
							end
							if ({cur_aminutes,2'b00,cur_aseconds,1'b0,cur_aframes} >= cues_dout[22:0]) begin
								cur_rframes <= cur_rframes + 7'h1;
								if (cur_rframes == 7'd74) begin
									upd_seconds <= 1'b1;
									cur_rframes <= 7'h0;
									cur_rseconds <= cur_rseconds + 6'h1;
									if (cur_rseconds == 6'd59) begin
										upd_minutes <= 1'b1;
										cur_rseconds <= 6'h0;
										cur_rminutes <= cur_rminutes + 7'h1;
									end
								end
							end
							if ({cur_minutes,2'b00,cur_seconds,1'b0,cur_frames} >= cuelast[22:0]) begin
								track_idx <= track_idx + 7'h1;
								cur_frames <= 7'h0;
								cur_seconds <= 6'h0;
								cur_minutes <= 7'h0;
								cur_rframes <= 7'h0;
								cur_rseconds <= 6'h0;
								cur_rminutes <= 7'h0;
								cues_addr <= track_idx + 7'h1;
							end
							cur_aframes <= cur_aframes + 7'h1;
							if (cur_aframes == 7'd74) begin
								upd_seconds <= 1'b1;
								cur_aframes <= 7'h0;
								cur_aseconds <= cur_aseconds + 6'h1;
								if (cur_aseconds == 6'd59) begin
									upd_minutes <= 1'b1;
									cur_aseconds <= 6'h0;
									cur_aminutes <= cur_aminutes + 7'h1;
								end
							end
						end
					end
				end
			end
		end
	end
	
	if (wet && ain[23:8]==24'hdfff) begin // restrict to lower 0-3f?
		if (ain[5:2]==4'h0) begin  // BUTCH ICR
			if (!ewe2l) begin
				butch_reg[4'h0][31:16] <= din[31:16];
			end
			if (!ewe0l) begin
				butch_reg[4'h0][15:8] <= butch_reg[4'h0][15:8] & ~din[15:8];
				butch_reg[4'h0][7:0] <= din[7:0];
				// interrupt control
			end
		end else if (aeven) begin
			butch_reg[ain[5:2]][31:0] <= din[31:0];
		end else begin
			butch_reg[ain[5:2]][15:0] <= din[15:0];
		end
		if (ain[5:2]==4'h4) begin  // I2SCTRL
			if (!ewe0l && din[2] && !play && seek==0 && splay==0) begin
				splay <= 5'h15;
			end
		end
		if (ds_a) begin
			// DSA info came from later spec. Some of these may be wrong/missing/unsupported for the Jag.
			last_ds <= din[15:0];
			unhandled <= 1'b1;
			if (din[15:8]==8'h01) begin  // Play Title
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0100 | din[7:0];
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				spinpause <= 1'b0;
				splay <= 5'h15;
				stop <= 1'b0;
				aud_add <= 30'h0;
				track_idx <= din[6:0];
				cur_samples <= 10'h0;
				cur_rframes <= 7'h0;
				cur_rseconds <= 6'h2;
				cur_rminutes <= 7'h0;
				gframes <= 3'h0;
				cues_addr <= din[6:0];
				cuet_addr <= din[6:0];
				updabs <= 1'b1;
			end
			if (din[15:8]==8'h02) begin  // Stop
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= !play; // |= 0x2000
				ds_resp[0] <= 32'h0200;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				stop <= play;
				pause <= 1'b0;
				spinpause <= 1'b0;
			end
			if (din[15:8]==8'h03) begin  // Read TOC
				unhandled <= 1'b0;
				if (!cd_ex) begin  // No CD
					ds_resp[0] <= 32'h400;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else if ((din[7:0]==8'h01) && (!aud_sess)) begin  // Multi Session CD, TODO
					ds_resp[0] <= 32'h400;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else if (din[7:0]==8'h02) begin  // Multi Session CD, TODO
					ds_resp[0] <= 32'h400;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else if (din[7:0]==8'hFF) begin  // Multi Session CD, TODO
					ds_resp[0] <= 32'h29;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					/* first track number */
					ds_resp[0] <= 32'h2000 | ((din[7:0]==8'h00) ? 32'h1 : (dat_track));
					/* last track number */
					ds_resp[1] <= 32'h2100 | (((din[7:0]==8'h00) && (aud_sess)) ? aud_tracks : num_tracks);

					/* end of last track minutes */
					ds_resp[2] <= 32'h2200 | (((din[7:0]==8'h00) && (aud_sess)) ? cuestop[1'h0][22:16] : cuestop[1'h1][22:16]);
					/* end of last track seconds */
					ds_resp[3] <= 32'h2300 | (((din[7:0]==8'h00) && (aud_sess)) ? cuestop[1'h0][13:8] : cuestop[1'h1][13:8]);
					/* end of last track frame */
					ds_resp[4] <= 32'h2400 | (((din[7:0]==8'h00) && (aud_sess)) ? cuestop[1'h0][6:0] : cuestop[1'h1][6:0]);
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h5;
					ds_resp_loop <= 7'h0;
				end
			end
			if (din[15:8]==8'h04) begin  // Pause
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0141;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				pause <= 1'b1;
			end
			if (din[15:8]==8'h05) begin  // Pause Release
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0142;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				pause <= 1'b0;
				spinpause <= 1'b0;
			end
			if (din[15:8]==8'h06) begin  // Search Forward - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				search_forward <= 1'b1;
				search_fast <= din[0];
				search_borderflag <= din[1];
			end
			if (din[15:8]==8'h07) begin  // Search Backward - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				search_backward <= 1'b1;
				search_fast <= din[0];
				search_borderflag <= din[1];
			end
			if (din[15:8]==8'h08) begin  // Search Release - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				search_forward <= 1'b0;
				search_backward <= 1'b0;
			end
			if (din[15:8]==8'h09) begin  // Get Title Length - not implemented (only for data CDs?)
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0900 | cuel_dout[7:0];  // needs to wait for data and convert to lba from time format
				ds_resp[1] <= 32'h0A00 | cuel_dout[15:8]; // needs to wait for data and convert to lba from time format
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h2;
				ds_resp_loop <= 7'h0;
//				cuel_add <= din[6:0];
				cues_addr <= din[6:0];
			end
			if (din[15:8]==8'h0A) begin  // Open Tray - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0100; //??
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h0B) begin  // Close Tray - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0100; //??
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h0D) begin  // Get Complete Time - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h1400 | cur_minutes[6:0]; // needs to wait for next change
				ds_resp[1] <= 32'h1500 | cur_seconds[5:0]; // needs to wait for next change
				ds_resp[2] <= 32'h1600 | cur_aframes[6:0]; // needs to wait for next change
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h3;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h10) begin  // 0x10 Goto ABS Min
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
//				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0140;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				sminutes <= din[6:0];
			end
			if (din[15:8]==8'h11) begin  // 0x10 Goto ABS Sec
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
//				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0140;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				sseconds <= din[5:0];
			end
			if (din[15:8]==8'h12) begin  // 0x10 Goto ABS Frame
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
//				butch_reg[0][13] <= 1'b1; // |= 0x2000 // too fast - wait for seek time
//				ds_resp[0] <= 32'h0140; // dsa says 0x140; code is looking for 0x100
//				ds_resp[0] <= 32'h0100; // too fast - wait for seek time
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				sframes <= din[6:0];
				cues_addr <= num_tracks + 7'h1;
				cuet_addr <= num_tracks + 7'h1;
				seek <= 8'hFF;
				stop <= 1'b0;
				spinpause <= 1'b0;
			end
			if (din[15:8]==8'h14) begin  // Read Long TOC
				unhandled <= 1'b0;
				if (!cd_ex) begin  // No CD
					ds_resp[0] <= 32'h400;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
//					for(int i=0;i<num_tracks;i++)
						/* track number */
						ds_resp[0] <= 32'h6000 | ((din[7:0]==8'h00) ? 32'h1 : dat_track);
						/* attributes (?) */
						ds_resp[1] <= 32'h6100;
						/* start of track minutes */
						ds_resp[2] <= 32'h6200;
						/* start of track seconds */
						ds_resp[3] <= 32'h6300;
						/* start of track frame */
						ds_resp[4] <= 32'h6400;

					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h5;
//					ds_resp_loop <= num_tracks[6:0];
					ds_resp_loop <= ((din[7:0]==8'h01) ? dat_tracks : ((aud_sess) ? aud_tracks : num_tracks));
					cues_addr <= ((din[7:0]==8'h00) ? 7'h1 : dat_track);
					updresp <= 1'b1;
				end
			end
			if (din[15:8]==8'h15) begin  // Set Mode
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h1700 | din[7:0];
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				mode <= din[7:0];
				if (din[1]) begin // bit1=speed2x
					sdin3[15:0] <= 16'h3; // 2*(3+1)=8 min for 9.279 (- currently setting 3 will alternate 3 and 4)
				end else begin // bit0=speed1x
					sdin3[15:0] <= 16'h8; // 2*(8+1)=18 min for 18.558
				end
				i2s3w <= 1'b1;
			end
			if (din[15:8]==8'h16) begin  // Get Last Error - No errors - Untested
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h400; // | error[7:0];
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h17) begin  // Clear Error - No errors - Untested
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h400;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h18) begin  // Spin Up
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0100 | 32'h0043;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				mounted <= 1'b0;
				spinpause <= 1'b1;
//				if (splay != 0 || play) begin
				if (mounted) begin
					spinpause <= 1'b0;
				end
					splay <= 5'h15;
					stop <= 1'b0;
				aud_add <= 30'h0;
				track_idx <= (din[6:0] == 0) ? 7'h1 : dat_track;
				cur_samples <= 10'h0;
				cur_rframes <= 7'h0;
				cur_rseconds <= 6'h2;
				cur_rminutes <= 7'h0;
				gframes <= 3'h0;
				cues_addr <= (din[6:0] == 0) ? 7'h1 : dat_track;
				cuet_addr <= (din[6:0] == 0) ? 7'h1 : dat_track;
				updabs <= 1'b1;
			end
			if (din[15:8]==8'h20) begin  // Play A Time To B Time - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				abaminutes <= din[6:0];
			end
			if (din[15:8]==8'h21) begin  // Play A Time To B Time - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				abaseconds <= din[5:0];
			end
			if (din[15:8]==8'h22) begin  // Play A Time To B Time - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				abaframes <= din[6:0];
			end
			if (din[15:8]==8'h23) begin  // Play A Time To B Time - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				abbminutes <= din[6:0];
			end
			if (din[15:8]==8'h24) begin  // Play A Time To B Time - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				abbseconds <= din[5:0];
			end
			if (din[15:8]==8'h25) begin  // Play A Time To B Time - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000 // too fast - wait for seek time
				ds_resp[0] <= 32'h0144; // should be done on seek found
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				abbframes <= din[6:0];
				cues_addr <= num_tracks + 7'h1;
				cuet_addr <= num_tracks + 7'h1;
				abseek <= 8'hFF;
				stop <= 1'b0;
				spinpause <= 1'b0;
			end
			if (din[15:8]==8'h26) begin  // Release A Time To B Time - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000 // too fast - wait for seek time
				ds_resp[0] <= 32'h2600;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				abplay <= 1'b0;
			end
			if (din[15:8]==8'h30) begin  // Get Disc identifiers - not implemented
				unhandled <= 1'b1;
				ds_resp[0] <= 32'h3000; //| disc_identifier[0][7:0]; 
				ds_resp[0] <= 32'h3100; //| disc_identifier[1][7:0]; 
				ds_resp[0] <= 32'h3200; //| disc_identifier[2][7:0]; 
				ds_resp[0] <= 32'h3300; //| disc_identifier[3][7:0]; 
				ds_resp[0] <= 32'h3400; //| disc_identifier[4][7:0]; 
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h5;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h50) begin  // Get Disc Status - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0300; // |= {finalized,low_reflectance,disc_12cm,njukebox,disc_present}; // low_ref=CDRW,high_ref=CDR/CDDA  8cm=0
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h51) begin  // Set Volume - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h5100 | din[7:0]; // 0=mute 1-254=fade 255=full
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h54) begin  // Get Max Session - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h5400 | ((aud_sess) ? 8'h1 : 8'h2); // ?? // if correct only 1 or 2 sessions supported
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h6A) begin  // Clear TOC - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h6A00;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h70) begin  // Set DAC Mode - only 1 and 81 expected (which do nothing)
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h7000 | din[7:0];
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				//0 reserved
				//1 I2S - FS mode (default) DAC mode
				//2 I2S - 2 FS mode         DAC mode
				//3 I2S - 4 FS mode         DAC mode
				//4 Sony 16 bit FS          DAC mode
				//5 Sony 16 bit 2 FS        DAC mode
				//6 Sony 16 bit 4 FS        DAC mode
				//7 Sony 18 bit FS          DAC mode
				//8 Sony 18 bit 2 FS        DAC mode
				//9 Sony 18 bit 4 FS        DAC mode
				//81 I2S - CD-ROM mode      CD-ROM mode
				//82 EIAJ CD-ROM mode       CD-ROM mode
			end
			//    0xa0-0xaf User Define (???)
			//    0xf0 Service
			//    0xf1 Sledge
			//    0xf2 Focus
			//    0xf3 Turntable
			//    0xf4 Radial
			//    0xf5 Laser
			//    0xf6 Diagnostics
			//    0xf7 Gain (Trigenta)
			//    0xf8-0xf9 Jump Grooves
		end
	end
	if (mem_a && ain[7:2]==6'h05) begin
		if (aeven && !ewe0l) begin
			add_ch3[23:16] <= din[23:16];
		end
		if (!aeven && !ewe0l) begin
			add_ch3[15:0] <= din[15:0];
		end
	end
	if (old_doe_ds && !doe_ds) begin
		ds_resp_idx <= ds_resp_idx + 3'h1;
		if (ds_resp_size == ds_resp_idx + 3'h1) begin
			ds_resp_idx <= 3'h0;
			if (ds_resp_loop != 7'h0) begin
				ds_resp_loop <= ds_resp_loop - 7'h1;
				cues_addr <= cues_addr + 7'h1;
				updrespa <= 1'b1;
			end else begin
				butch_reg[0][13] <= 1'b0; // &= ~0x2000
			end
		end
	end	
	if (updrespa) begin
		updrespa <= 1'b0;
		updresp <= 1'b1;
	end
	if (updresp) begin
		ds_resp[0][7:0] <= cues_add;
		ds_resp[2][7:0] <= {1'b0,cues_dout[22:16]};
		ds_resp[3][7:0] <= {2'b0,cues_dout[13:8]};
		ds_resp[4][7:0] <= {1'b0,cues_dout[6:0]};
	end
	if (old_doe_dsc && !doe_dsc) begin
		butch_reg[0][12] <= 1'b0;
		butch_reg[0][13] <= ((ds_resp[0][13:8] == 6'h20) || (ds_resp[0][15:8] == 6'h04)) ? 1'b1 : 1'b0; // gettoc==0x20 or 0x60
	end	
	if (old_doe_sub && !doe_sub) begin
		subidx <= subidx + 4'h1;
		if (4'hC == subidx + 4'h1) begin
			subidx <= 4'h0;
//			butch_reg[0][13] <= 1'b0; // &= ~0x2000
		end
		if (4'h1 == subidx + 4'h1) begin
			upd_frames <= 1'b0;
			recrc <= 1'b1;
		end
	end	
	if (!old_doe_sub && !doe_sub) begin
		if ((4'h0 == subidx) && upd_frames) begin
			upd_frames <= 1'b0;
			recrc <= 1'b1;
		end
	end	
	if (recrc && (attiabs || attirel)) begin
		butch_reg[0][13] <= 1'b1; // |= 0x2000
	end
	
	if (fifo_inc && (!doe_fif || eoe0l || (old_fif_a1 != fif_a1))) begin // if a1!= then swapping 24/28
		fifo_inc <= 1'b0; // will stay 1 if swapping 24/28 below
		if (i2s_rfifopos != i2s_wfifopos) begin
			i2s_rfifopos <= i2s_rfifopos + 5'h1;
		end else begin
			errflow <= 1'b1;
		end
	end
	if (doe_fif && !eoe0l) begin
		fifo_inc <= 1'b1;
	end
	butch_reg[4][4] <= i2s_rfifopos != i2s_wfifopos;//0x10;
	butch_reg[0][9] <= fifo_half; //  0x200
end

wire [6:0] cuet_add;
wire [31:0] cuet_din;
wire [31:0] cuet_dout;
wire cuet_wr;
spram #(.addr_width(7), .data_width(32)) cuet_bram_inst
(
	.clock   ( sys_clk ),

	.address ( cuet_add ),
	.data    ( cuet_din ),
	.wren    ( cuet_wr ),

	.q       ( cuet_dout )
);
//track aud_track_offset

wire [6:0] cues_add;
wire [23:0] cues_din;
wire [23:0] cues_dout;
wire cues_wr;
spram #(.addr_width(7), .data_width(24)) cues_bram_inst
(
	.clock   ( sys_clk ),

	.address ( cues_add ),
	.data    ( cues_din ),
	.wren    ( cues_wr ),

	.q       ( cues_dout )
);
//mmssff start

wire [6:0] cuep_add;
wire [23:0] cuep_din;
wire [23:0] cuep_dout;
wire cuep_wr;
spram #(.addr_width(7), .data_width(24)) cuep_bram_inst
(
	.clock   ( sys_clk ),

	.address ( cuep_add ),
	.data    ( cuep_din ),
	.wren    ( cuep_wr ),

	.q       ( cuep_dout )
);
//mmssff start

wire [6:0] cuel_add;
wire [23:0] cuel_din;
wire [23:0] cuel_dout;
wire carryf = cuel_dout[6:0]==7'h00;
wire carrys = cuel_dout[13:0]==14'h00;
reg [23:0] cuelast;// = {carrys?cuel_dout[23:16]-8'h1:cuel_dout[23:16],carrys?8'h3B:carryf?cuel_dout[15:8]-8'h1:cuel_dout[15:8],carryf?8'h4A:cuel_dout[7:0]-8'h1};
wire cuel_wr;
spram #(.addr_width(7), .data_width(24)) cuel_bram_inst
(
	.clock   ( sys_clk ),

	.address ( cuel_add ),
	.data    ( cuel_din ),
	.wren    ( cuel_wr ),

	.q       ( cuel_dout )
);
//mmssff length

/*
wire [3:0] audb_addr;
wire [63:0] audb_dinr;
wire [63:0] audb_doutr;
wire audb_wrr;
wire [5:0] audb_addw;
wire [63:0] audb_dinw;
wire [63:0] audb_doutw;
wire audb_wrw;
dpram #(6,64) audbufram
(
	.clock     ( sys_clk ),

	.address_a ( audb_addr ),
	.data_a    ( audb_dinr ),
	.wren_a    ( audb_wrr ),
	.q_a       ( audb_doutr ),
	.address_a ( audb_addw ),
	.data_a    ( audb_dinw ),
	.wren_a    ( audb_wrw ),
	.q_a       ( audb_doutw )
);
//audio lba buffer
*/

wire i2txd;
wire sckout;
wire wsout;
wire i2int;
wire i2sen;
assign i2srxd = i2txd;
assign sck = sckout && i2s_jerry;
assign ws = wsout && i2s_jerry;
assign sen = i2sen && i2s_jerry;
reg i2s1w;
reg i2s2w;
reg i2s3w;
reg i2s4w;

_butch_i2s cdi2s
(
	.resetl          (resetl),
	.clk             (clk),
	.din             (sdin[15:0]),
	.din3            (sdin3[15:0]),
	.din4            (sdin4[15:0]),
	.i2s1w           (i2s1w),
	.i2s2w           (i2s2w),
	.i2s3w           (i2s3w),
	.i2s4w           (i2s4w),
	.i2s1r           (1'b0),
	.i2s2r           (1'b0),
	.i2s3r           (1'b0),
	.i2rxd           (1'b0),
	.sckin           (1'b0),
	.wsin            (1'b0),

	.i2txd           (i2txd),
	.sckout          (sckout),
	.wsout           (wsout),
	.i2int           (i2int),
	.i2sen           (i2sen),

	.sys_clk         (sys_clk)
);

reg [7:0] bcd [0:99];
integer i;
integer j;
initial begin
//	bcd[8'd00] <= 8'h00;
//	bcd[8'dij] <= 8'hij;
//	bcd[8'd99] <= 8'h99;
 for (i = 0; i < 10; i = i + 1)
 begin
  for (j = 0; j < 10; j = j + 1)
  begin
	bcd[i * 10 + j] <= {i[3:0],j[3:0]};
  end
 end
end

//;-----------------------------------------
//;
//;
//;   Get (multi-session) Table of Contents
//;
//;
//;   entry:  a0 -> address of 1024 byte buffer for returned multi-session TOC
//;
//;
//;   exit:  all regs preserved
//;
//;
//;  The returned buffer will contain 8-byte records, one for each
//;   track found on the CD in track/time order.  The very first
//;   record (corresponding to the "0th" track) is the exception.
//;
//;   Format for the first record:
//;
//;    +0 - unused, reserved (0)
//;    +1 - unused, reserved (0)
//;    +2 - minimum track number
//;    +3 - maximum track number
//;    +4 - total number of sessions
//;    +5 - start of last lead-out time, absolute minutes
//;    +6 - start of last lead-out time, absolute seconds
//;    +7 - start of last lead-out time, absolute frames
//;
//;   Format for the track records that follow:
//;
//;    +0 - track # (must be non-zero)
//;    +1 - absolute minutes (0..99), start of track
//;    +2 - absolute seconds (0..59), start of track
//;    +3 - absolute frames, (0..74), start of track
//;    +4 - session # (0..99)
//;    +5 - track duration minutes
//;    +6 - track duration seconds
//;    +7 - track duration frames
//;
//;  Note that the track durations are computed by subtracting the
//;   start time of track N by the start time of either track N+1 or by the
//;   start of the lead-out for that session.  This may need to be further
//;   adjusted by the customary 2 seconds of silence between tracks if necessary.


//;				*****************************************
//;				*	 Wait for a frame boundary	*
//;				*****************************************
//JustHere:
//	move.l	$dfff14,d0	; Clear any pending frame ints
//
//Wait4frm:
//	move.l	$dfff00,d0
//	btst	#11,d0
//	beq	Wait4frm
//
//;				*****************************************
//;				*	 Gather subcode data		*
//;				*****************************************
//	move.l	#BUTCH,a0  	; Interrupt control register
//	move.l	#$dfff18,a1	; Subcode data register
//	move.l	#$f14000,a2	; Joystick register
//	move.l	#Bblokbeg,a3	; Buffer for subcode data
//	move.l	#$dfff14,a4	; Subcode control register
//	move.l	#Bblokend,a5	; Buffer limit
//b:
//	bra	SubPend		; First time through subcode will already be 
//				; pending
//get_bits:
//	move.l	(a0),d0		; Read ICR
//	btst	#10,d0		; Poll the subcode interrupt bit
//	beq	get_bits
//	
//SubPend:
//	move.l	(a1),d0		; Read subcode data
//	move.l	d0,d1		; d0=Srxx Used for S
//	swap	d1		; d1=xxsR Used for R 
//	move.l	4(a1),d2	; d2=Wvut Used for W 
//	move.l	d2,d3		
//	move.l	d2,d4		; d4=wvUt Used for U
//	move.l	d2,d5		; d5=wvuT Used for T
//	swap	d3		; d3=utwV Used for V
//
//;				*****************************************
//;				*	 Assemble CD+G symbols		*
//;				*****************************************
//				; Data is now in registers d0-d5, now make 
//				; CD+G symbols from it.
//	move.l	#8,d6		; 8 symbols per subcode int
//
//NxtSym:
//	clr.l	d7
//	roxl.b	#1,d1		; Get the R bit
//	roxl.b	#1,d7		; --> result
//	roxl.l	#1,d0		; S bit
//	roxl.b	#1,d7
//	roxl.b	#1,d5		; T bit
//	roxl.b	#1,d7
//	roxl.w	#1,d4		; U bit
//	roxl.b	#1,d7
//	roxl.b	#1,d3		; V bit
//	roxl.b	#1,d7
//	roxl.l	#1,d2		; W bit
//	roxl.b	#1,d7
//	move.b	d7,(a3)+	; Buffer it
//	cmp.l	a3,a5		; buffer full?
//	beq	set4_cnt	; yes, branch to next routine
//	subq	#1,d6	
//	bne	NxtSym
//	move.l	(a4),d7		; Clear pending interrupt
//	bra	get_bits	; go round again


//CDmode_g:			; init sort of like CD+G mode
//	move.l	#$0,BUTCH	; Butch enable, no DSA 
//	move.l	#$1e8,SBCNTRL	; preload PRN  f2=1x, 1e8=2x
//	move.l	#$3e8,SBCNTRL	; turn on the subcode counter  2f2= 1x, 3e8 2x
//;	move.l	#$7,I2CNTRL	; 
//;        move.l  #$F1A154,a0     ; put address into a0
//;        move.l  #$14,d1         ; external clk, interrupt on every sample pair
//;        move.l  d1,(a0)         ; write to Jerry
//  	rts


endmodule

