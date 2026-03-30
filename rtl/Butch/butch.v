// altera message_off 10036

// Functional; no netlist
module _butch
(
	input resetl,
	input clk,
	input cart_ce_n,
	input cd_en,
	input cd_ex,
	input cd_latency_en,
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
	output [29:0] audbus_out,
	input  [63:0] aud_in,
	input  [63:0] aud_cmp,
	output aud_ce,
	input  audwaitl,
	input  aud_cbusy,
	input  [63:0] cdg_in,
	input [9:0] toc_addr,
	input [15:0] toc_data,
	input toc_wr,
	input toc_done,
	input force_music_cd,
	input maxc,
	output [23:0] addr_ch3,
	output eeprom_cs,
	output eeprom_sk,
	output eeprom_dout,
	input eeprom_din,
	// Abstracted
	input dohacks,
	output hackbus,
	output hackbus1,
	output hackbus2,
	output overflowo,
	output underflowo,
	output errflowo,
	output unhandledo,
	input cd_valid,
	input cd_sector2448,
	input sys_clk
);


wire wet = !cart_ce_n && !(ewe0l && ewe2l);
wire oet = !cart_ce_n && !(eoe0l && eoe1l);
localparam integer DSA_MAX_SESSIONS    = 100;
localparam [7:0] DSA_ERR_FOCUS_NO_DISC = 8'h02;
localparam [7:0] DSA_ERR_TOC_STALE     = 8'h08;
localparam [7:0] DSA_ERR_ILLEGAL_CMD   = 8'h22;
localparam [7:0] DSA_ERR_ILLEGAL_VALUE = 8'h29;
localparam [19:0] DSA_STATUS_SETTLE_CYCLES = 20'd262143;
localparam [2:0] STOP_FLUSH_WS_COUNT = 3'd4;
localparam [15:0] DATA_WAIT_TIMEOUT = 16'hFFFF;
//BUTCH     equ  $DFFF00	; base of Butch=interrupt control register, R/W
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
//;BUTCH     equ  $DFFF00		;base of Butch=interrupt control register, R/W
//;
//;  When written (Long):
//;
//;  bit0 - set to enable interrupts
//;  bit1 - enable CD data FIFO half full interrupt
//;  bit2 - enable CD subcode frame-time interrupt (@ 2x spped = 7ms.)
//;  bit3 - enable pre-set subcode time-match found interrupt
//;  bit4 - CD module command transmit buffer empty interrupt
//;  bit5 - CD module command receive buffer full
//;  bit6 - CIRC failure interrupt
//;
//;  bit7-31  reserved, set to 0 
//;
//;
//;  When read (Long):
//;
//;  bit0-8 reserved
//;
//;  bit9  - CD data FIFO half-full flag pending
//;  bit10 - Frame pending
//;  bit11 - Subcode data pending
//;  bit12 - Command to CD drive pending (trans buffer empty if 1)
//;  bit13 - Response from CD drive pending (rec buffer full if 1)
//;  bit14 - CD uncorrectable data error pending
//
// Does not match these - 
//No.          		Description
//"""          		""""""""""""""
//bit 0      set to 1 to enable interrupt per conditions below
//bit 1      set to 1 to interrupt on CD data FIFO half full
//bit 2      set to 1 to interrupt on every CD subcode frame-time at 1X speed (14 ms.)
//bit 3      set to 1 to interrupt on every CD subcode frame-time at 2X speed (7 ms.)
//bit 4      set to 1 to interrupt on your pre-set subcode time-match found
//bit 5      set to 1 to interrupt on CD Module command transmit buffer empty
//bit 6      set to 1 to interrupt on CD Module command receive buffer full
//bit 7      set to 1 to interrupt on current error level 
//bits 8 through 15 are reserved.    Set them to 0.
//Whenever these CD Module registers are read, they return the status of the interface.      The interrupt flag status bits are...
//	bit 9	CD data FIFO half-full flag pending
//	bit 11 	Subcode data pending
//	bit 12	Command to CD drive pending
//	bit 13	Response from CD drive pending
//	bit 14	CD uncorrectable data error pending

//assign eint = (!butch_reg[0][0]) || (!fifo_int && !frame_int &&!sub_int && !tbuf_int && !rbuf_int);
assign eint = (butch_reg[0][0]) && (fifo_int || frame_int || sub_int || tbuf_int || rbuf_int);
wire fifo_int = butch_reg[0][9] && butch_reg[0][1];
wire frame_int = butch_reg[0][11] && butch_reg[0][2];
wire sub_int = butch_reg[0][10] && butch_reg[0][3];
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
// DSA Error Codes
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

// DSA Commands
// 01h Play title                                              - servo - Title number (hex)
// 02h Stop                                                    - servo - xx
// 03h Read TOC                                                - servo - 00
// 04h Pause                                                   - mode  - xx
// 05h Pause Release                                           - mode  - xx
// 06h Search forward at low speed, with Border flag cleared   - servo - 00h
// 06h Search forward at high speed, with Border flag cleared  - servo - 01h
// 06h Search forward at low speed, with Border flag set       - servo - 10h
// 06h Search forward at high speed, with Border flag set      - servo - 11h
// 07h Search backward at low speed, with Border flag cleared  - servo - 00h
// 07h Search backward at high speed, with Border flag cleared - servo - 01h
// 07h Search backward at low speed, with Border flag set      - servo - 10h
// 07h Search backward at high speed, with Border flag set     - servo - 11h
// 08h Search release                                          - servo -
// 09h Get title length                                        - info  - Track number (hex)
// 0Ah Reserved
// 0Bh Reserved
// 0Dh Get complete time                                       - info  - xx
// 10h Goto time                                               - servo - Abs. min. (hex)
// 11h Goto time                                               - servo - Abs. sec. (hex)
// 12h Goto time (start)                                       - servo - Abs. frm. (hex)
// 14h Read Long TOC                                           - servo - 00
// 15h Set mode                                                - mode  - Mode settings
// 16h Get last error                                          - info  - xx
// 17h Clear error                                             - info  - xx
// 18h Spin up                                                 - servo - 00
// 20h Play A-time till B-time                                 - servo - Absolute start time minutes (hex)
// 21h Play A-time till B-time                                 - servo - Absolute start time seconds (hex)
// 22h Play A-time till B-time                                 - servo - Absolute start time frames (hex)
// 23h Play A-time till B-time                                 - servo - Absolute stop time minutes (hex)
// 24h Play A-time till B-time                                 - servo - Absolute stop time seconds (hex)
// 25h Play A-time till B-time (start)                         - servo - Absolute stop time frames (hex)
// 26h Release A->B time                                       - mode  - xx
// 30h Get Disc Identifiers                                    - info  - xx
// 40h Reserved
// 41h Reserved
// 42h Reserved
// 43h Reserved
// 44h Reserved
// 50h Get disc status                                         - info  - xx
// 51h Set volume                                              - mode  - Volume level (hex)
// 52h Reserved
// 54h Reserved
// 6Ah Clear TOC                                               - mode  - xx
// 70h Set DAC mode                                            - mode  - DAC mode
// A0h-AFh Reserved for Vendor Unique

// DSA Reponses
// 01h Found                - servo - Goto title Found (xx)/Goto time Found (40h)/Paused (41h)/Paused Released (42h)/Spinned Up (43h)/Play A-B Start Found (44h)/Play A-B End Found (45h)
// 02h Stopped              - servo - xx
// 03h Disc status          - info  - No disc present / disc present,Disc size 8cm / 12 cm,High/low reflectance disc,Finalised/unfinalised disc
// 04h Error values         - info  - Error value
// 09h Length of title      - info  - Lsb byte of seconds of requested title (hex)
// 0Ah Length of title      - info  - Msb byte of seconds of requested title (hex)
// 0Bh Reserved             - servo
// 0Ch Reserved             - servo
// 0Dh Reserved             - servo
// 10h Actual title         - servo - New track number (hex)
// 11h Actual index         - servo - New index number (hex)
// 12h Actual minutes       - servo - New minutes (hex)
// 13h Actual seconds       - servo - New seconds (hex)
// 14h Absolute time        - info  - New abs. minutes (hex)
// 15h Absolute time        - info  - New abs. seconds (hex)
// 16h Absolute time        - info  - New abs. frames (hex)
// 17h Mode status          - info  - Mode settings
// 20h TOC values           - servo - Min. track number (hex)
// 21h TOC values           - servo - Max. track number (hex)
// 22h TOC values           - servo - Start time lead-out min. (hex)
// 23h TOC values           - servo - Start time lead-out sec. (hex)
// 24h TOC values           - servo - Start time lead-out frm. (hex)
// 26h A->B Time released   - mode  - xx
// 30h Disc identifiers     - info  - Disc identifier 0 of the CD
// 31h Disc identifiers     - info  - Disc identifier 1 of the CD
// 32h Disc identifiers     - info  - Disc identifier 2 of the CD
// 33h Disc identifiers     - info  - Disc identifier 3 of the CD
// 34h Disc identifiers     - info  - Disc identifier 4 of the CD
// 51h Volume level         - mode  - Volume level (hex)
// 52h Reserved             -
// 54h Reserved             -
// 5Dh Reserved             -
// 5Eh Reserved             -
// 5Fh Reserved             -
// 60h Long TOC values      - servo - Track number (hex)
// 61h Long TOC values      - servo - Control & Address field
// 62h Long TOC values      - servo - Start time minutes (hex)
// 63h Long TOC values      - servo - Start time seconds (hex)
// 64h Long TOC values      - servo - Start time frames (hex)
// 65h Reserved             -
// 66h Reserved             -
// 67h Reserved             -
// 68h Reserved             -
// 6Ah TOC Cleared          - info  - xx
// 70h DAC mode             - mode  - DAC mode
// F0h Servo Version Number - servo - Servo version number

//I2CNTRL   equ  BUTCH+$10	; i2s bus control register, R/W
wire i2s_drive = butch_reg[4][0];
wire i2s_jerry = butch_reg[4][1];
wire i2s_fifo_enabled = butch_reg[4][2]; // guess. turned on in read handler (gas/das)
wire i2s_16bit = butch_reg[4][3]; // ? only affects i2s format?
wire i2s_fifonempty = i2s_rfifopos != i2s_wfifopos;//butch_reg[4][4];
reg [31:0] ds_resp [0:5];
reg [2:0] ds_resp_idx;
reg [2:0] ds_resp_size; // max = 6
reg [6:0] ds_resp_loop; // max = numtracks=99
reg updresp; // signals for TOC responses to move to next one
reg updrespa;

//SBCNTRL   equ  BUTCH+$14	; CD subcode control register, R/W
//SUBDATA   equ  BUTCH+$18	; Subcode data register A
//SUBDATB   equ  BUTCH+$1C	; Subcode data register B
//SB_TIME   equ  BUTCH+$20	; Subcode time and compare enable (D24)
//  1 frame = 588 longs (samples) = 2352 bytes data
// 2352 bytes data = 98 bytes subcode (96 data + 2 synchro)
// cdg files only have the 96 data bytes (24 * 4)
//	load	(subdata),R0		;get S R Q & chunk#
//	load	(subdatb),R1		;get W V U T
// bit order appears to be 01234567 for each byte (roxl is used to get each bit at a time)
// To get cdg 09 requires T=0x8X and W=0x8X and RSUV all =0x0X (looking only at top bit)
// SUBDATA is S R Q chunk# (S is MSB. chunk# is 0x10-0x1B)
// SUBDATB is W V U T (W is MSB)
// SBCNTRL read clears the interrupt
// SBCNTRL write 0x200 enables counter
// SBCNTRL write $1FF is the count to use
//  Calls it a PRN. Maybe some kind of LFSR counter?
//	move.l	#$1e8,SBCNTRL	; preload PRN  f2=1x, 1e8=2x
//	move.l	#$3e8,SBCNTRL	; turn on the subcode counter  2f2= 1x, 3e8 2x
//  bit2 - enable CD subcode frame-time interrupt (@ 2x spped = 7ms.)
// 1e8 = 488 = 7ms? f2 = 242 = 3.5ms? 14ms?
reg [6:0] rframes;  // 0-74 // (msf % 75)
reg [5:0] rseconds; // 0-59 // (msf / 75) % 60
reg [6:0] rminutes; // 0-99 // (msf / 75) / 60
reg [6:0] aframes;  // 0-74 // (msf % 75)
reg [5:0] aseconds; // 0-59 // (msf / 75) % 60
reg [6:0] aminutes; // 0-99 // (msf / 75) / 60
reg [6:0] atrack;   // 1-99
wire [7:0] subcodeq [0:11];
wire [6:0] atrack_safe = (atrack > 7'd99) ? 7'd99 : atrack;
wire [7:0] subq_tno;
wire [7:0] subq_index;
assign subcodeq[0] = 8'h1; // 2 channel audio no preemphasis, address 1
assign subcodeq[1] = subq_tno; // track number bcd, or AA in leadout
assign subcodeq[2] = subq_index; // index: 00 pregap, 01 program
assign subcodeq[3] = bcd[rminutes]; // rel min bcd
assign subcodeq[4] = bcd[{1'b0,rseconds}]; // rel sec bcd
assign subcodeq[5] = bcd[rframes]; // rel frames bcd
assign subcodeq[6] = 8'h0; // zero
assign subcodeq[7] = bcd[aminutes]; // abs min bcd
assign subcodeq[8] = bcd[{1'b0,aseconds}]; // abs sec bcd
assign subcodeq[9] = bcd[aframes]; // abs frames bcd
assign subcodeq[10] = crc1; // crc1 Polynomial = P(X)=X16+X12+X5+1
assign subcodeq[11] = crc0; // crc0
reg [7:0] crc1;
reg [7:0] crc0;
reg [15:0] crc;
reg recrc;
reg [3:0] subidx;
reg [7:0] sub_chunk_count;
reg subcode_irq_pending;
reg frame_irq_pending;
wire [7:0] sub_chunk_tag = ((sub_chunk_count < 8'h10) || (sub_chunk_count > 8'h1B)) ? 8'h10 : sub_chunk_count;
reg [5:0] gsubidx;
reg csubg;
wire [5:0] cdg [0:95];
reg [7:0] subcoder [0:31];// = cdg[subidx][5];
reg [7:0] subcodes [0:31];// = cdg[subidx][4];
reg [7:0] subcodet [0:31];// = cdg[subidx][3];
reg [7:0] subcodeu [0:31];// = cdg[subidx][2];
reg [7:0] subcodev [0:31];// = cdg[subidx][1];
reg [7:0] subcodew [0:31];// = cdg[subidx][0];
/*integer kk;
initial begin
 for (kk = 0; kk < 12; kk = kk + 1)
 begin
   subcoder[kk] <= 8'b00000000;
   subcodes[kk] <= 8'b00000000;
   subcodet[kk] <= 8'b10000000;
   subcodeu[kk] <= 8'b00000000;
   subcodev[kk] <= 8'b01111111;
   subcodew[kk] <= 8'b10000000;
 end
   subcodes[6] <= 8'b00100000;
   subcodet[6] <= 8'b10100000;
   subcodeu[6] <= 8'b00100000;
end
*/
/*
integer ii;
always@(*)
begin
 for (ii = 0; ii < 8; ii = ii + 1)
 begin
	subcoder[subidx][ii] <= cdg[5][subidx * 12 + ii];
	subcodes[subidx][ii] <= cdg[4][subidx * 12 + ii];
	subcodet[subidx][ii] <= cdg[3][subidx * 12 + ii];
	subcodeu[subidx][ii] <= cdg[2][subidx * 12 + ii];
	subcodev[subidx][ii] <= cdg[1][subidx * 12 + ii];
	subcodew[subidx][ii] <= cdg[0][subidx * 12 + ii];
 end
end
*/
//wire [7:0] subcodep0 = {cdg_in[63],cdg_in[55],cdg_in[47],cdg_in[39],cdg_in[31],cdg_in[23],cdg_in[15],cdg_in[7]};
//wire [7:0] subcodeq0 = {cdg_in[62],cdg_in[54],cdg_in[46],cdg_in[38],cdg_in[30],cdg_in[22],cdg_in[14],cdg_in[6]};
//wire [7:0] subcoder0 = {cdg_in[61],cdg_in[53],cdg_in[45],cdg_in[37],cdg_in[29],cdg_in[21],cdg_in[13],cdg_in[5]};
//wire [7:0] subcodes0 = {cdg_in[60],cdg_in[52],cdg_in[44],cdg_in[36],cdg_in[28],cdg_in[20],cdg_in[12],cdg_in[4]};
//wire [7:0] subcodet0 = {cdg_in[59],cdg_in[51],cdg_in[43],cdg_in[35],cdg_in[27],cdg_in[19],cdg_in[11],cdg_in[3]};
//wire [7:0] subcodeu0 = {cdg_in[58],cdg_in[50],cdg_in[42],cdg_in[34],cdg_in[26],cdg_in[18],cdg_in[10],cdg_in[2]};
//wire [7:0] subcodev0 = {cdg_in[57],cdg_in[49],cdg_in[41],cdg_in[33],cdg_in[25],cdg_in[17],cdg_in[9],cdg_in[1]};
//wire [7:0] subcodew0 = {cdg_in[56],cdg_in[48],cdg_in[40],cdg_in[32],cdg_in[24],cdg_in[16],cdg_in[8],cdg_in[0]};
wire [7:0] subcoder0 = {cdg_in[21],cdg_in[29],cdg_in[5],cdg_in[13],cdg_in[53],cdg_in[61],cdg_in[37],cdg_in[45]};
wire [7:0] subcodes0 = {cdg_in[20],cdg_in[28],cdg_in[4],cdg_in[12],cdg_in[52],cdg_in[60],cdg_in[36],cdg_in[44]};
wire [7:0] subcodet0 = {cdg_in[19],cdg_in[27],cdg_in[3],cdg_in[11],cdg_in[51],cdg_in[59],cdg_in[35],cdg_in[43]};
wire [7:0] subcodeu0 = {cdg_in[18],cdg_in[26],cdg_in[2],cdg_in[10],cdg_in[50],cdg_in[58],cdg_in[34],cdg_in[42]};
wire [7:0] subcodev0 = {cdg_in[17],cdg_in[25],cdg_in[1],cdg_in[9], cdg_in[49],cdg_in[57],cdg_in[33],cdg_in[41]};
wire [7:0] subcodew0 = {cdg_in[16],cdg_in[24],cdg_in[0],cdg_in[8], cdg_in[48],cdg_in[56],cdg_in[32],cdg_in[40]};
//wire [31:0] subrespa = {subcodes0,subcoder0,subcodeq[subidx],sub_chunk_tag}; //,subcodeq0,};
//wire [31:0] subrespb = {subcodew0,subcodev0,subcodeu0,subcodet0};
wire [31:0] subrespa = {subcodes[{csubg,subidx}],subcoder[{csubg,subidx}],subcodeq[subidx],sub_chunk_tag};
wire [31:0] subrespb = {subcodew[{csubg,subidx}],subcodev[{csubg,subidx}],subcodeu[{csubg,subidx}],subcodet[{csubg,subidx}]};
wire subbit = subcodeq[crcidx[6:3]][~crcidx[2:0]];
wire [15:0] crcs = nextcrcb ? crc ^ {subcodeq[crcidx[6:3]],8'h00} : crc;
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
// CDDoc seems to indicate fifo depth is small on alpine but maybe 16k or 32k on production?
//   Note that 16 kbytes, more or less, of "old" invalid data will be read from the FIFO before good data begins to appear.
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
assign audbus_out = aud_adds[29:0]; // max 64MB - old_aud_rd will delay one cycle to match aud_adds delay
assign aud_ce = cd_en && old_aud_rd2; // give aud_rd two cycles for track offset fetch and addition
assign addr_ch3 = maxc ? add_ch3 : max_ch3;

reg hackwait;
assign hackbus = 1'b0;//cd_en && aud_sess && (ain[23:8]==16'h002C) && hackwait;
//assign hackbus1 = cd_en && aud_sess && (({ain[23:2],2'b00}==24'h050DF4) || ({ain[23:1],1'b0}==24'h050E8A) || ({ain[23:1],1'b0}==24'h050E8C)) && hackwait;
assign hackbus1 = dohacks && cd_en && aud_sess && (({ain[23:2],2'b00}==24'h050DF4)) && hackwait;
assign hackbus2 = 1'b0;//cd_en && aud_sess && (({ain[23:1],1'b0}==24'h050EC0)) && hackwait;
assign override = cdbios && cd_en;
assign doe = cd_en && oet && (breg);// || (!cdbios && caddr)); // not sure how mirroring applies or if reading is sometimes disabled - probably disabled when cdbios is disabled to allow cart pass through for >=4MB
assign dout[31:0] = (aeven) ? dout_t[31:0] : {dout_t[15:0],dout_t[15:0]};
wire [31:0] dout_t = doe_ds ? ds_resp[ds_resp_idx] : doe_suba ? subrespa : doe_subb ? subrespb : doe_fif ? cur_i2s_fifo : butch_reg[ain[5:2]];
wire aeven = (ain[1]==1'b0); //even is high [31:16]
wire breg = ain[23:8]==24'hdfff;
wire caddr = ain[23:22]==2'b10;
wire dsc_a = ain[5:2]==4'h1;
wire doe_dsc = doe && dsc_a;
wire ds_a = ain[5:2]==4'h2; // should be 0xA not just 0x8?
wire doe_ds = doe && ds_a;
wire ictl_a = ain[5:2]==4'h4; // 0x10
wire doe_ictl = doe && ictl_a;
wire sbcntrl_a = ain[5:2]==4'h5; // 0x14
wire doe_sbcntrl = doe && sbcntrl_a;
wire sub_a = ain[5:2]==4'h6;
wire doe_suba = doe && sub_a;
wire sub_b = ain[5:2]==4'h7;
wire doe_subb = doe && sub_b;
wire fif_a1 = ain[5:2]==4'h9; // 0x24
wire fif_a2 = ain[5:2]==4'hA; // 0x28
wire fif_a = fif_a1 || fif_a2; // 0x24 or 0x28
wire doe_fif = doe && fif_a;
wire mem_a = ain[23:8]==16'hf160;
reg [23:0] add_ch3;
reg [23:0] max_ch3;

reg old_doe_ds;
reg old_doe_dsc;
reg old_doe_suba;
reg old_doe_subb;
reg old_doe_sbcntrl;
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
// 352800 bytes/sec at double rate
// 265909/(352.8*8) = 9.4214 cycles/bit
// 746.9MB = 317560 frames = 70.57 minutes max
// 24'h1AF05E = which pattern 0-9
//wire [6:0] frames_end = cuest[num_tracks[2:0]+3'h1][6:0];    // 0-74 // (msf % 75)
//wire [5:0] seconds_end = cuest[num_tracks[2:0]+3'h1][13:8];  // 0-59 // (msf / 75) % 60
//wire [6:0] minutes_end = cuest[num_tracks[2:0]+3'h1][22:16]; // 0-99 // (msf / 75) / 60
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
reg spinpause;
reg pause;
reg pause_mode_indicator;
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
// 5 - 4 = Actual Title, Time, Index (ATTI) setting
// 00 = no title, index or time send during play modes
// 01 = sending title, index and absolute time (min/sec)
// 10 = sending title, index and relative time (min/sec)
// 11 = reserved

reg atti_report_valid;
reg [7:0] atti_last_title;
reg [7:0] atti_last_index;
reg [6:0] atti_last_rel_minutes;
reg [5:0] atti_last_rel_seconds;
reg [6:0] atti_last_abs_minutes;
reg [5:0] atti_last_abs_seconds;
reg atti_evt_title_pending;
reg atti_evt_index_pending;
reg atti_evt_rel_minutes_pending;
reg atti_evt_rel_seconds_pending;
reg atti_evt_abs_minutes_pending;
reg atti_evt_abs_seconds_pending;
reg atti_force_full_update;
reg play_title_pending_rsp;
reg [6:0] play_title_pending_track;
reg title_len_pending_rsp;
reg ab_found_pending_rsp;
reg toc_read_pending_rsp;
reg [7:0] toc_read_pending_session;
reg spin_up_pending_rsp;
reg [7:0] spin_up_pending_session;
reg goto_found_pending_rsp;
reg scan_goto_pending;
reg leadout_title_pending;
reg leadout_seen;

reg updabs;
reg updabs_req;
reg [7:0] seek;
reg [6:0] sframes; // 0-74  // (msf % 75)
reg [5:0] sseconds; // 0-59 // (msf / 75) % 60
reg [6:0] sminutes; // 0-99 // (msf / 75) / 60
reg [6:0] goto_minutes; // latched by 0x10
reg [5:0] goto_seconds; // latched by 0x11
reg seek_found_pending;
reg [2:0] gframes; // 0-6 gap frames

reg [15:0] fdata;
reg [63:0] fd;

reg [7:0] seek_count;
wire aud_busy = (old_aud_rd3) || (old_aud_rd2) || (old_aud_rd) || (aud_rd) || (!audwaitl);
reg [18:0] taud_add;
reg [29:8] taud2_add;
reg [25:4] taud3_add;
reg [5:0] subtseconds; // 0-59
reg [5:0] subtrseconds; // 0-59
reg [15:0] last_ds;
reg [31:0] seek_delay;
reg [31:0] seek_delay_set;
reg old_cd_ex;
reg old_toc_ready;
reg [19:0] dsa_status_settle;
reg [2:0] stop_flush_ws;

reg overflow;
reg underflow;
reg errflow;
reg data_wait_pending;
reg [15:0] data_wait_cycles;
reg unhandled;
assign overflowo = overflow;
assign underflowo = underflow;
assign errflowo = errflow;
assign unhandledo = unhandled || pastcdbios;
reg abplay;
reg [7:0] abseek;
reg [6:0] abaframes; // 0-74  // (msf % 75)
reg [5:0] abaseconds; // 0-59 // (msf / 75) % 60
reg [6:0] abaminutes; // 0-99 // (msf / 75) / 60
reg [6:0] abbframes; // 0-74  // (msf % 75)
reg [5:0] abbseconds; // 0-59 // (msf / 75) % 60
reg [6:0] abbminutes; // 0-99 // (msf / 75) / 60
reg [7:0] dsa_last_error;

task queue_dsa_error;
	input [7:0] error_code;
begin
	butch_reg[0][13] <= 1'b1;
	ds_resp[0] <= 32'h0400 | error_code;
	ds_resp_idx <= 3'h0;
	ds_resp_size <= 3'h1;
	ds_resp_loop <= 7'h0;
	dsa_last_error <= error_code;
end
endtask

task clear_audio_transport;
begin
	cur_samples <= 10'h0;
	gframes <= 3'h0;
	valid <= 1'b0;
	fd <= 64'h0;
	fifo[0] <= 64'h0;
	fifo[1] <= 64'h0;
	fifo[2] <= 64'h0;
	fifo[3] <= 64'h0;
	i2s_wfifopos <= 5'h0;
	i2s_rfifopos <= 5'h0;
	fifo_inc <= 1'b0;
	overflow <= 1'b0;
	underflow <= 1'b0;
	errflow <= 1'b0;
	data_wait_pending <= 1'b0;
	data_wait_cycles <= 16'h0000;
	i2s1w <= 1'b1;
	i2s2w <= 1'b1;
	sdin[15:0] <= 16'h0;
end
endtask

task clear_dsa_runtime_events;
begin
	play_title_pending_rsp <= 1'b0;
	goto_found_pending_rsp <= 1'b0;
	ab_found_pending_rsp <= 1'b0;
	scan_goto_pending <= 1'b0;
	subcode_irq_pending <= 1'b0;
	frame_irq_pending <= 1'b0;
	sub_chunk_count <= 8'h0F;
	subidx <= 4'h0;
	recrc <= 1'b1;
	data_wait_pending <= 1'b0;
	data_wait_cycles <= 16'h0000;
	atti_report_valid <= 1'b0;
	atti_force_full_update <= 1'b0;
	atti_evt_title_pending <= 1'b0;
	atti_evt_index_pending <= 1'b0;
	atti_evt_rel_minutes_pending <= 1'b0;
	atti_evt_rel_seconds_pending <= 1'b0;
	atti_evt_abs_minutes_pending <= 1'b0;
	atti_evt_abs_seconds_pending <= 1'b0;
	leadout_title_pending <= 1'b0;
	leadout_seen <= 1'b0;
end
endtask

task clear_dsa_seek_events;
begin
	goto_found_pending_rsp <= 1'b0;
	ab_found_pending_rsp <= 1'b0;
	scan_goto_pending <= 1'b0;
	subcode_irq_pending <= 1'b0;
	frame_irq_pending <= 1'b0;
	sub_chunk_count <= 8'h0F;
	subidx <= 4'h0;
	recrc <= 1'b1;
	data_wait_pending <= 1'b0;
	data_wait_cycles <= 16'h0000;
	atti_evt_title_pending <= 1'b0;
	atti_evt_index_pending <= 1'b0;
	atti_evt_rel_minutes_pending <= 1'b0;
	atti_evt_rel_seconds_pending <= 1'b0;
	atti_evt_abs_minutes_pending <= 1'b0;
	atti_evt_abs_seconds_pending <= 1'b0;
	leadout_title_pending <= 1'b0;
end
endtask

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
reg cues_wrr_next;
reg cuep_wrr_next;
reg cuel_wrr_next;
reg cuet_wrr_next;
assign cues_wr = cues_wrr;
assign cuep_wr = cuep_wrr;
assign cuel_wr = cuel_wrr;
assign cuet_wr = cuet_wrr;

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
reg [7:0] dsa_sess_count_toc;
reg [6:0] dsa_sess_first_track [0:DSA_MAX_SESSIONS-1];
reg [6:0] dsa_sess_last_track [0:DSA_MAX_SESSIONS-1];
reg [23:0] dsa_sess_leadout [0:DSA_MAX_SESSIONS-1];
reg dsa_sess_valid [0:DSA_MAX_SESSIONS-1];
reg toc_ready;
reg toc_done_pending;
reg [7:0] toc_session_idx;
reg [7:0] dsa_long_toc_session;
integer dsa_sess_i;
wire [7:0] dsa_presence_error = (!cd_ex) ? DSA_ERR_FOCUS_NO_DISC : DSA_ERR_TOC_STALE;
wire dsa_disc_ready = cd_ex && toc_ready;
wire dsa_status_settling = cd_ex && (!toc_ready || (dsa_status_settle != 20'h0));
wire [31:0] dsa_disc_status_resp = !cd_ex ? 32'h0301 : (dsa_status_settling ? 32'h0402 : 32'h0300);
wire [7:0] dsa_session_count = dsa_sess_count_toc;
wire [7:0] dsa_last_sess_idx = (dsa_session_count != 8'h00) ? (dsa_session_count - 8'h1) : 8'h00;
wire [7:0] dsa_visible_session_count = force_music_cd ? ((dsa_session_count != 8'h00) ? 8'h01 : 8'h00) : dsa_session_count;
wire [6:0] dsa_visible_audio_tracks = force_music_cd ? num_tracks : aud_tracks;
wire [6:0] dsa_visible_dat_track = force_music_cd ? 7'h0 : dat_track;
wire [7:0] dsa_disc_id0 = {1'b0, num_tracks[6:0]};
wire [7:0] dsa_disc_id1 = {1'b0, dsa_visible_audio_tracks[6:0]};
wire [7:0] dsa_disc_id2 = {1'b0, dsa_visible_dat_track[6:0]};
wire [7:0] dsa_disc_id3 = {1'b0, dsa_visible_session_count[6:0]};
wire [7:0] dsa_disc_id4 = dsa_sess_leadout[dsa_last_sess_idx][23:16] ^ dsa_sess_leadout[dsa_last_sess_idx][15:8] ^ dsa_sess_leadout[dsa_last_sess_idx][7:0] ^ {1'b0, num_tracks[6:0]};
wire [7:0] dsa_req_session = din[7:0];
wire [7:0] dsa_spin_req_session = din[7:0];
wire dsa_req_sess_in_range = (dsa_req_session < DSA_MAX_SESSIONS);
wire dsa_req_sess_valid = dsa_req_sess_in_range ? dsa_sess_valid[dsa_req_session] : 1'b0;
wire [6:0] dsa_req_first_track = dsa_req_sess_valid ? dsa_sess_first_track[dsa_req_session] : 7'h0;
wire [6:0] dsa_req_last_track = dsa_req_sess_valid ? dsa_sess_last_track[dsa_req_session] : 7'h0;
wire [23:0] dsa_req_leadout = dsa_req_sess_valid ? dsa_sess_leadout[dsa_req_session] : 24'h0;
wire dsa_spin_req_sess_valid = (dsa_spin_req_session < DSA_MAX_SESSIONS) ? dsa_sess_valid[dsa_spin_req_session] : 1'b0;
wire [6:0] dsa_spin_req_first_track = dsa_spin_req_sess_valid ? dsa_sess_first_track[dsa_spin_req_session] : 7'h0;
wire dsa_toc_pending_sess_valid = (toc_read_pending_session < DSA_MAX_SESSIONS) ? dsa_sess_valid[toc_read_pending_session] : 1'b0;
wire [6:0] dsa_toc_pending_first_track = dsa_toc_pending_sess_valid ? dsa_sess_first_track[toc_read_pending_session] : 7'h0;
wire [6:0] dsa_toc_pending_last_track = dsa_toc_pending_sess_valid ? dsa_sess_last_track[toc_read_pending_session] : 7'h0;
wire [23:0] dsa_toc_pending_leadout = dsa_toc_pending_sess_valid ? dsa_sess_leadout[toc_read_pending_session] : 24'h0;
wire dsa_spin_pending_sess_valid = (spin_up_pending_session < DSA_MAX_SESSIONS) ? dsa_sess_valid[spin_up_pending_session] : 1'b0;
wire [6:0] dsa_spin_pending_first_track = dsa_spin_pending_sess_valid ? dsa_sess_first_track[spin_up_pending_session] : 7'h0;
function [19:0] msf_to_frames;
	input [6:0] mins;
	input [5:0] secs;
	input [6:0] frms;
	reg [19:0] mins_frames;
	reg [19:0] secs_frames;
begin
	mins_frames = {mins,12'h000} + {mins,8'h00} + {mins,7'h00} + {mins,4'h0} + {mins,2'h0};
	secs_frames = {secs,6'h00} + {secs,3'h0} + {secs,1'b0} + {14'h0000,secs};
	msf_to_frames = mins_frames + secs_frames + {13'h0000,frms};
end
endfunction

function [15:0] msf_to_seconds;
	input [6:0] mins;
	input [5:0] secs;
	reg [15:0] mins_seconds;
begin
	mins_seconds = {mins,6'h00} - {mins,2'h0};
	msf_to_seconds = mins_seconds + {10'h000,secs};
end
endfunction

wire [22:0] cur_abs_packed = {cur_aminutes,2'b00,cur_aseconds,1'b0,cur_aframes};
wire [22:0] subq_track_start_packed = cues_dout[22:0];
wire [22:0] subq_track_pregap_packed = cuep_dout[22:0];
wire subq_leadout = dsa_disc_ready && (dsa_session_count != 8'h00) && (cur_abs_packed >= dsa_disc_leadout_packed);
wire subq_program = dsa_disc_ready && !subq_leadout && (cur_abs_packed >= subq_track_start_packed);
wire subq_pregap = dsa_disc_ready && !subq_leadout && !subq_program && (cur_abs_packed >= subq_track_pregap_packed);
wire [22:0] dsa_goto_target_packed = {goto_minutes,2'b00,goto_seconds,1'b0,din[6:0]};
wire [19:0] cur_abs_frames = msf_to_frames(cur_aminutes, cur_aseconds, cur_aframes);
wire [19:0] goto_cmd_abs_frames_next = msf_to_frames(goto_minutes, goto_seconds, din[6:0]);
wire [15:0] cuel_seconds = msf_to_seconds(cuel_dout[22:16], cuel_dout[13:8]);
wire [22:0] ab_start_packed = {abaminutes,2'b00,abaseconds,1'b0,abaframes};
wire [22:0] ab_end_packed = {abbminutes,2'b00,abbseconds,1'b0,abbframes};
wire [22:0] ab_end_packed_next = {abbminutes,2'b00,abbseconds,1'b0,din[6:0]};
wire [19:0] ab_start_frames = msf_to_frames(abaminutes, abaseconds, abaframes);
wire [19:0] ab_end_frames = msf_to_frames(abbminutes, abbseconds, abbframes);
wire [19:0] ab_end_frames_next = msf_to_frames(abbminutes, abbseconds, din[6:0]);
wire [20:0] ab_start_delta_frames = (cur_abs_frames >= ab_start_frames) ?
	({1'b0,cur_abs_frames} - {1'b0,ab_start_frames}) :
	({1'b0,ab_start_frames} - {1'b0,cur_abs_frames});
wire [20:0] goto_delta_frames = (cur_abs_frames >= goto_cmd_abs_frames_next) ?
	({1'b0,cur_abs_frames} - {1'b0,goto_cmd_abs_frames_next}) :
	({1'b0,goto_cmd_abs_frames_next} - {1'b0,cur_abs_frames});
wire [22:0] dsa_disc_leadout_packed = {
	dsa_sess_leadout[dsa_last_sess_idx][22:16],
	2'b00,
	dsa_sess_leadout[dsa_last_sess_idx][13:8],
	1'b0,
	dsa_sess_leadout[dsa_last_sess_idx][6:0]
};
wire goto_target_past_leadout = (dsa_session_count != 8'h00) && (dsa_goto_target_packed >= dsa_disc_leadout_packed);
wire [7:0] dsa_long_toc_ctrl_addr = (force_music_cd || (dat_track == 7'h0) || (cues_add < dat_track)) ? 8'h01 : 8'h41;
wire dsa_dac_mode_valid =
	(din[7:0] <= 8'h09) ||
	(din[7:0] == 8'h81) ||
	(din[7:0] == 8'h82);
localparam [31:0] DSA_DELAY_SEEK_TIER1 = 32'd3190800;   // ~30 ms
localparam [31:0] DSA_DELAY_SEEK_TIER2 = 32'd9572400;   // ~90 ms
localparam [31:0] DSA_DELAY_SEEK_TIER3 = 32'd15954000;  // ~150 ms
localparam [31:0] DSA_DELAY_SEEK_TIER4 = 32'd23931000;  // ~225 ms
localparam [31:0] DSA_DELAY_SEEK_TIER5 = 32'h0200_0000; // ~315 ms

function [31:0] goto_seek_delay_cycles;
	input [20:0] delta_frames;
	input latency_en;
begin
	if (!latency_en) begin
		if (delta_frames < 21'd75) begin
			goto_seek_delay_cycles = 32'h0008_0000;
		end else if (delta_frames < 21'd750) begin
			goto_seek_delay_cycles = 32'h000A_0000;
		end else if (delta_frames < 21'd4500) begin
			goto_seek_delay_cycles = 32'h000C_0000;
		end else if (delta_frames < 21'd22500) begin
			goto_seek_delay_cycles = 32'h000E_0000;
		end else begin
			goto_seek_delay_cycles = 32'h0010_0000;
		end
	end else begin
		if (delta_frames < 21'd75) begin
			goto_seek_delay_cycles = DSA_DELAY_SEEK_TIER1;
		end else if (delta_frames < 21'd750) begin
			goto_seek_delay_cycles = DSA_DELAY_SEEK_TIER2;
		end else if (delta_frames < 21'd4500) begin
			goto_seek_delay_cycles = DSA_DELAY_SEEK_TIER3;
		end else if (delta_frames < 21'd22500) begin
			goto_seek_delay_cycles = DSA_DELAY_SEEK_TIER4;
		end else begin
			goto_seek_delay_cycles = DSA_DELAY_SEEK_TIER5;
		end
	end
end
endfunction

assign subq_tno = subq_leadout ? 8'hAA : ((subq_program || subq_pregap) ? bcd[atrack_safe] : 8'h00);
assign subq_index = subq_program ? 8'h01 : 8'h00;
wire [7:0] atti_cur_index = subq_index;
wire [7:0] atti_cur_title = subq_leadout ? 8'hAA : {1'b0,track_idx};
wire atti_runtime_active = play && !stop && !spinpause && !pause && (seek == 8'h0) && (splay == 5'h0);
wire atti_evt_drain_active = atti_runtime_active || atti_force_full_update;
wire atti_setmode_context_valid = play && !stop && !spinpause && (seek == 8'h0) && (splay == 5'h0);
wire interactive_scan_context = pause_mode_indicator || (play && !pause && !spinpause && (attirel || attiabs));
initial begin
	cue_tracks <= 7'd6; //
	aud_tracks <= 7'd2;
	dat_tracks <= 7'd4;
	dat_track <= 7'd3;
	dsa_sess_count_toc <= 8'h0;
	toc_ready <= 1'b0;
	toc_done_pending <= 1'b0;
	toc_session_idx <= 8'h0;
	dsa_long_toc_session <= 8'h0;
	goto_minutes <= 7'h0;
	goto_seconds <= 6'h0;
	seek_found_pending <= 1'b0;
	subidx <= 4'h0;
	sub_chunk_count <= 8'h0F;
	subcode_irq_pending <= 1'b0;
	frame_irq_pending <= 1'b0;
	old_cd_ex <= 1'b0;
	old_toc_ready <= 1'b0;
	dsa_status_settle <= 20'h0;
	stop_flush_ws <= 3'h0;
	updabs_req <= 1'b0;
	pause_mode_indicator <= 1'b0;
	atti_report_valid <= 1'b0;
	atti_last_title <= 8'h0;
	atti_last_index <= 8'h0;
	atti_last_rel_minutes <= 7'h0;
	atti_last_rel_seconds <= 6'h0;
	atti_last_abs_minutes <= 7'h0;
	atti_last_abs_seconds <= 6'h0;
	atti_evt_title_pending <= 1'b0;
	atti_evt_index_pending <= 1'b0;
	atti_evt_rel_minutes_pending <= 1'b0;
	atti_evt_rel_seconds_pending <= 1'b0;
	atti_evt_abs_minutes_pending <= 1'b0;
	atti_evt_abs_seconds_pending <= 1'b0;
	atti_force_full_update <= 1'b0;
	play_title_pending_rsp <= 1'b0;
	play_title_pending_track <= 7'h0;
	goto_found_pending_rsp <= 1'b0;
	scan_goto_pending <= 1'b0;
	leadout_title_pending <= 1'b0;
	leadout_seen <= 1'b0;
	for (dsa_sess_i = 0; dsa_sess_i < DSA_MAX_SESSIONS; dsa_sess_i = dsa_sess_i + 1) begin
		dsa_sess_first_track[dsa_sess_i] <= 7'h0;
		dsa_sess_last_track[dsa_sess_i] <= 7'h0;
		dsa_sess_leadout[dsa_sess_i] <= 24'h0;
		dsa_sess_valid[dsa_sess_i] <= 1'b0;
	end
end
reg [23:0] cuestop [0:1];
initial begin
	cuestop[1'h0] <= 24'h003A28; //
	cuestop[1'h1] <= 24'h04022C; //
end
// These are redundant with RAMs. Was implemented this way first then, intended to move to ram blocks. No longer needed - convert defaults to mif for BRAMs?
/*
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
*/

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
	aud_adds[29:0] <= aud_add[29:0] + cuet_dout[29:0]; // old_aud_rd will delay one cycle to match aud_adds delay
	cuelast[23:0] <= {carrys?cuel_dout[23:16]-8'h1:cuel_dout[23:16],carrys?8'h3B:carryf?cuel_dout[15:8]-8'h1:cuel_dout[15:8],carryf?8'h4A:cuel_dout[7:0]-8'h1};
	recrc <= 1'b0;
	updresp <= 1'b0;
	updrespa <= 1'b0;
	aud_rd <= 1'b0;
	old_doe_ds <= doe_ds;
	old_doe_dsc <= doe_dsc;
	old_doe_suba <= doe_suba;
	old_doe_subb <= doe_subb;
	old_doe_sbcntrl <= doe_sbcntrl;
	old_doe_fif <= doe_fif;
	old_fif_a1 <= fif_a1;
	old_clk <= clk;
	old_resetl <= resetl;
	old_play <= play;
	old_cd_ex <= cd_ex;
	old_toc_ready <= toc_ready;
	old_aud_rd <= aud_rd;
	old_aud_rd2 <= old_aud_rd;
	old_aud_rd3 <= old_aud_rd2;
	old_upd_frames <= upd_frames;
	butch_reg[11][3] <= eeprom_din;
	if (!resetl) begin
	hackwait <= 1'b0;
	seek_count <= 8'h0;
		pastcdbios <= 1'b0;
		goto_minutes <= 7'h0;
		goto_seconds <= 6'h0;
		seek_found_pending <= 1'b0;
		seek_delay_set <= DSA_DELAY_SEEK_TIER5;
		old_cd_ex <= 1'b0;
		old_toc_ready <= 1'b0;
		dsa_status_settle <= 20'h0;
		stop_flush_ws <= 3'h0;
		subidx <= 4'h0;
		sub_chunk_count <= 8'h0F;
		subcode_irq_pending <= 1'b0;
		frame_irq_pending <= 1'b0;
		splay <= 5'h0;
		play <= 1'b0;
		stop <= 1'b0;
		pause <= 1'b0;
		pause_mode_indicator <= 1'b0;
		spinpause <= 1'b0;
		i2s1w <= 1'b0;
		i2s2w <= 1'b0;
		i2s3w <= 1'b0;
		i2s4w <= 1'b0;
		aud_rd <= 1'b0;
		aud_add <= 30'h000000;
		unhandled <= 1'b0;
		dsa_last_error <= 8'h00;
		data_wait_pending <= 1'b0;
		data_wait_cycles <= 16'h0000;
		upd_frames <= 1'b0;
		upd_seconds <= 1'b0;
		upd_minutes <= 1'b0;
		updabs_req <= 1'b0;
		mode <= 8'h21;
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
		seek <= 8'h0;
		i2s_rfifopos <= 5'h0;
		i2s_wfifopos <= 5'h0;
		fifo_inc <= 1'b0;
		i2s_fifo[0] <= 0;
		clear_audio_transport();
		atti_report_valid <= 1'b0;
		atti_last_title <= 8'h0;
		atti_last_index <= 8'h0;
		atti_last_rel_minutes <= 7'h0;
		atti_last_rel_seconds <= 6'h0;
		atti_last_abs_minutes <= 7'h0;
		atti_last_abs_seconds <= 6'h0;
		atti_evt_title_pending <= 1'b0;
		atti_evt_index_pending <= 1'b0;
		atti_evt_rel_minutes_pending <= 1'b0;
		atti_evt_rel_seconds_pending <= 1'b0;
		atti_evt_abs_minutes_pending <= 1'b0;
		atti_evt_abs_seconds_pending <= 1'b0;
		atti_force_full_update <= 1'b0;
		play_title_pending_rsp <= 1'b0;
		title_len_pending_rsp <= 1'b0;
		ab_found_pending_rsp <= 1'b0;
		toc_read_pending_rsp <= 1'b0;
		toc_read_pending_session <= 8'h0;
		spin_up_pending_rsp <= 1'b0;
		spin_up_pending_session <= 8'h0;
		play_title_pending_track <= 7'h0;
		goto_found_pending_rsp <= 1'b0;
		scan_goto_pending <= 1'b0;
		leadout_title_pending <= 1'b0;
		leadout_seen <= 1'b0;
	end
	if (!cdbios)
		pastcdbios <= 1'b1;

	if (!cd_ex) begin
		dsa_status_settle <= 20'h0;
	end else if ((!old_cd_ex && cd_ex) || (!old_toc_ready && toc_ready) || (old_toc_ready && !toc_ready)) begin
		dsa_status_settle <= DSA_STATUS_SETTLE_CYCLES;
	end else if (dsa_status_settle != 20'h0) begin
		dsa_status_settle <= dsa_status_settle - 20'h1;
	end

	cues_wrr_next <= 0;
	cuep_wrr_next <= 0;
	cuel_wrr_next <= 0;
	cuet_wrr_next <= 0;
	cues_wrr <= cues_wrr_next;
	cuep_wrr <= cuep_wrr_next;
	cuel_wrr <= cuel_wrr_next;
	cuet_wrr <= cuet_wrr_next;
	if (toc_done) begin
		toc_done_pending <= 1'b1;
	end
	if (toc_wr) begin
		if (toc_addr == 10'h008) begin
			dsa_sess_count_toc <= 8'h0;
			toc_ready <= 1'b0;
			toc_done_pending <= 1'b0;
			toc_session_idx <= 8'h0;
			dsa_long_toc_session <= 8'h0;
			cue_tracks <= 7'h0;
			aud_tracks <= 7'h0;
			dat_tracks <= 7'h0;
			dat_track <= 7'h0;
			track_idx <= 7'h1;
			unhandled <= 1'b0;
			dsa_last_error <= 8'h00;
			data_wait_pending <= 1'b0;
			data_wait_cycles <= 16'h0000;
			play <= 1'b0;
			stop <= 1'b0;
			stop_flush_ws <= 3'h0;
			pause <= 1'b0;
			pause_mode_indicator <= 1'b0;
			spinpause <= 1'b0;
			splay <= 5'h0;
			seek <= 8'h0;
			seek_found_pending <= 1'b0;
			updabs_req <= 1'b0;
			updabs <= 1'b0;
			goto_minutes <= 7'h0;
			goto_seconds <= 6'h0;
			sminutes <= 7'h0;
			sseconds <= 6'h0;
			sframes <= 7'h0;
			cur_frames <= 7'h0;
			cur_seconds <= 6'h0;
			cur_minutes <= 7'h0;
			cur_rframes <= 7'h0;
			cur_rseconds <= 6'h0;
			cur_rminutes <= 7'h0;
			cur_aframes <= 7'h0;
			cur_aseconds <= 6'h0;
			cur_aminutes <= 7'h0;
			upd_frames <= 1'b0;
			upd_seconds <= 1'b0;
			upd_minutes <= 1'b0;
			play_title_pending_rsp <= 1'b0;
			title_len_pending_rsp <= 1'b0;
			ab_found_pending_rsp <= 1'b0;
			toc_read_pending_rsp <= 1'b0;
			toc_read_pending_session <= 8'h0;
			spin_up_pending_rsp <= 1'b0;
			spin_up_pending_session <= 8'h0;
			goto_found_pending_rsp <= 1'b0;
			scan_goto_pending <= 1'b0;
			atti_report_valid <= 1'b0;
			atti_force_full_update <= 1'b0;
			atti_evt_title_pending <= 1'b0;
			atti_evt_index_pending <= 1'b0;
			atti_evt_rel_minutes_pending <= 1'b0;
			atti_evt_rel_seconds_pending <= 1'b0;
			atti_evt_abs_minutes_pending <= 1'b0;
			atti_evt_abs_seconds_pending <= 1'b0;
			leadout_title_pending <= 1'b0;
			leadout_seen <= 1'b0;
			subcode_irq_pending <= 1'b0;
			frame_irq_pending <= 1'b0;
			sub_chunk_count <= 8'h0F;
			subidx <= 4'h0;
			cues_addr <= 7'h1;
			cuet_addr <= 7'h1;
			clear_audio_transport();
			for (dsa_sess_i = 0; dsa_sess_i < DSA_MAX_SESSIONS; dsa_sess_i = dsa_sess_i + 1) begin
				dsa_sess_first_track[dsa_sess_i] <= 7'h0;
				dsa_sess_last_track[dsa_sess_i] <= 7'h0;
				dsa_sess_leadout[dsa_sess_i] <= 24'h0;
				dsa_sess_valid[dsa_sess_i] <= 1'b0;
			end
		end
		cues_addr <= {toc_addr[9:3]};
		cuet_addr <= {toc_addr[9:3]};
		if (toc_addr[2:0] == 3'h0) begin
			cues_dinv[23:8] <= toc_data[15:0];
			cueptemp[23:8] <= toc_data[15:0];
		end
		if (toc_addr[2:0] == 3'h1) begin
			cues_dinv[7:0] <= toc_data[15:8];
			cueptemp[7:0] <= toc_data[15:8];
			cuel_dinv[23:16] <= toc_data[7:0];
			cues_wrr_next <= 1;
		end
		if (toc_addr[2:0] == 3'h2) begin
			cuel_dinv[15:0] <= toc_data[15:0];
			cuel_wrr_next <= 1;
		end
		if (toc_addr[2:0] == 3'h3) begin
			//cue_gap[15:0] <= toc_data[15:0]; // logic below assumes gap is not larger than 2 seconds
			cueptemp[7:0] <= cueptemp[7:0] - toc_data[7:0];
			cueptemp[14:8] <= cueptemp[14:8] - toc_data[14:8];
		end
		if (toc_addr[2:0] == 3'h4) begin
			cuet_dinv[31:24] <= toc_data[7:0];
			toc_session_idx <= toc_data[15:9];
			if (toc_data[15:9] < DSA_MAX_SESSIONS) begin
				if (!dsa_sess_valid[toc_data[15:9]]) begin
					dsa_sess_first_track[toc_data[15:9]] <= toc_addr[9:3];
				end
				dsa_sess_valid[toc_data[15:9]] <= 1'b1;
				if ((toc_data[15:9] + 8'h1) > dsa_sess_count_toc) begin
					dsa_sess_count_toc <= toc_data[15:9] + 8'h1;
				end
			end
			tocsess1 <= 1;
			if (toc_data[15:9] == 0) begin //session 1 == (0 or 1)
				aud_tracks <= toc_addr[9:3];
				tocsess1 <= 0;
			end
			cue_tracks <= toc_addr[9:3];
			if (cueptemp[7]) begin
				cueptemp[7:0] <= cueptemp[7:0] + 8'h4B;
				cueptemp[14:8] <= cueptemp[14:8] - (7'h1);
			end
		end
		if (toc_addr[2:0] == 3'h5) begin
			cuet_dinv[23:8] <= toc_data[15:0];
			dat_tracks <= cue_tracks - aud_tracks;
			dat_track <= aud_tracks + 4'h1;
			if (cueptemp[14]) begin
				cueptemp[14:8] <= cueptemp[14:8] + 7'h3C;
				cueptemp[23:16] <= cueptemp[23:16] - (1'b1);
			end
		end
		if (toc_addr[2:0] == 3'h6) begin
			cuestoptemp[23:16] <= toc_data[7:0];
			cuet_dinv[7:0] <= toc_data[15:8];
			cuep_dinv <= cueptemp;
			cuet_wrr_next <= 1;
			cuep_wrr_next <= 1;
		end
		if (toc_addr[2:0] == 3'h7) begin
			if (cuestoptemp[23:16] != 0 || toc_data[15:0] != 0) begin
				cuestop[tocsess1][23:16] <= cuestoptemp[23:16];
				cuestop[tocsess1][15:0] <= toc_data[15:0];
				if (toc_session_idx < DSA_MAX_SESSIONS) begin
					dsa_sess_last_track[toc_session_idx] <= toc_addr[9:3];
					dsa_sess_leadout[toc_session_idx] <= {cuestoptemp[23:16], toc_data[15:0]};
				end
			end
		end
	end
	if (clk && !old_clk && toc_done_pending) begin
		toc_ready <= 1'b1;
		toc_done_pending <= 1'b0;
	end
	if (updabs_req) begin
		updabs_req <= 1'b0;
		updabs <= 1'b1;
	end
	if (updabs) begin
		updabs <= 1'b0;
		cur_aframes <= cues_dout[6:0];
		cur_aseconds <= cues_dout[13:8];
		cur_aminutes <= cues_dout[22:16];
	end
	if (play_title_pending_rsp && !updabs_req && !updabs && (ds_resp_size == 3'h0) && !ds_a) begin
		butch_reg[0][12] <= 1'b1;
		butch_reg[0][13] <= 1'b1;
		if (attiabs || attirel) begin
			ds_resp[0] <= 32'h1000 | play_title_pending_track;
			ds_resp[1] <= 32'h1100 | 8'h01;
			ds_resp[4] <= 32'h0100;
			ds_resp_size <= 3'h5;
			atti_report_valid <= 1'b1;
			atti_last_title <= {1'b0, play_title_pending_track};
			atti_last_index <= 8'h01;
			atti_last_abs_minutes <= cues_dout[22:16];
			atti_last_abs_seconds <= cues_dout[13:8];
			atti_last_rel_minutes <= cur_rminutes[6:0];
			atti_last_rel_seconds <= cur_rseconds[5:0];
			if (attiabs) begin
				ds_resp[2] <= 32'h1400 | cues_dout[22:16];
				ds_resp[3] <= 32'h1500 | cues_dout[13:8];
			end else begin
				ds_resp[2] <= 32'h1200 | cur_rminutes[6:0];
				ds_resp[3] <= 32'h1300 | cur_rseconds[5:0];
			end
		end else begin
			ds_resp[0] <= 32'h0100;
			ds_resp_size <= 3'h1;
			atti_report_valid <= 1'b0;
		end
		ds_resp_idx <= 3'h0;
		ds_resp_loop <= 7'h0;
		play_title_pending_rsp <= 1'b0;
	end
	if (title_len_pending_rsp && (ds_resp_size == 3'h0) && !ds_a) begin
		butch_reg[0][12] <= 1'b1;
		butch_reg[0][13] <= 1'b1;
		ds_resp[0] <= 32'h0900 | cuel_seconds[7:0];
		ds_resp[1] <= 32'h0A00 | cuel_seconds[15:8];
		ds_resp_idx <= 3'h0;
		ds_resp_size <= 3'h2;
		ds_resp_loop <= 7'h0;
		title_len_pending_rsp <= 1'b0;
	end
	if (toc_read_pending_rsp && (toc_ready || !cd_ex) && (ds_resp_size == 3'h0) && !ds_a) begin
		butch_reg[0][12] <= 1'b1;
		butch_reg[0][13] <= 1'b1;
		ds_resp_idx <= 3'h0;
		ds_resp_loop <= 7'h0;
		if (!cd_ex) begin
			queue_dsa_error(DSA_ERR_FOCUS_NO_DISC);
		end else if ((toc_read_pending_session >= dsa_visible_session_count) || !dsa_toc_pending_sess_valid) begin
			queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
		end else begin
			clear_dsa_runtime_events();
			play_title_pending_rsp <= 1'b0;
			title_len_pending_rsp <= 1'b0;
			play <= 1'b0;
			stop <= play;
			stop_flush_ws <= play ? STOP_FLUSH_WS_COUNT : 3'h0;
			seek <= 8'h0;
			seek_found_pending <= 1'b0;
			goto_found_pending_rsp <= 1'b0;
			ab_found_pending_rsp <= 1'b0;
			scan_goto_pending <= 1'b0;
			abplay <= 1'b0;
			abseek <= 8'h0;
			subcode_irq_pending <= 1'b0;
			frame_irq_pending <= 1'b0;
			sub_chunk_count <= 8'h0F;
			subidx <= 4'h0;
			recrc <= 1'b1;
			atti_report_valid <= 1'b0;
			atti_force_full_update <= 1'b0;
			atti_evt_title_pending <= 1'b0;
			atti_evt_index_pending <= 1'b0;
			atti_evt_rel_minutes_pending <= 1'b0;
			atti_evt_rel_seconds_pending <= 1'b0;
			atti_evt_abs_minutes_pending <= 1'b0;
			atti_evt_abs_seconds_pending <= 1'b0;
			leadout_title_pending <= 1'b0;
			leadout_seen <= 1'b0;
			clear_audio_transport();
			pause <= 1'b0;
			spinpause <= 1'b1;
			splay <= 5'h15;
			cur_samples <= 10'h0;
			cur_frames <= 7'h0;
			cur_seconds <= 6'h0;
			cur_minutes <= 7'h0;
			cur_rframes <= 7'h0;
			cur_rseconds <= 6'h0;
			cur_rminutes <= 7'h0;
			cur_aframes <= 7'h0;
			cur_aseconds <= 6'h0;
			cur_aminutes <= 7'h0;
			gframes <= 3'h0;
			aud_add <= 30'h0;
			track_idx <= dsa_toc_pending_first_track;
			cues_addr <= dsa_toc_pending_first_track;
			cuet_addr <= dsa_toc_pending_first_track;
			updabs_req <= 1'b1;
			ds_resp[0] <= 32'h2000 | dsa_toc_pending_first_track;
			ds_resp[1] <= 32'h2100 | dsa_toc_pending_last_track;
			ds_resp[2] <= 32'h2200 | dsa_toc_pending_leadout[22:16];
			ds_resp[3] <= 32'h2300 | dsa_toc_pending_leadout[13:8];
			ds_resp[4] <= 32'h2400 | dsa_toc_pending_leadout[6:0];
			ds_resp_size <= 3'h5;
		end
		toc_read_pending_rsp <= 1'b0;
	end
	if (spin_up_pending_rsp && (toc_ready || !cd_ex) && (ds_resp_size == 3'h0) && !ds_a) begin
		butch_reg[0][12] <= 1'b1;
		butch_reg[0][13] <= 1'b1;
		ds_resp_idx <= 3'h0;
		ds_resp_size <= 3'h1;
		ds_resp_loop <= 7'h0;
		if (!cd_ex) begin
			queue_dsa_error(DSA_ERR_FOCUS_NO_DISC);
		end else if (!dsa_spin_pending_sess_valid || (dsa_spin_pending_first_track == 7'h00)) begin
			queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
		end else begin
			ds_resp[0] <= 32'h0100;
			clear_dsa_seek_events();
			subcode_irq_pending <= 1'b0;
			frame_irq_pending <= 1'b0;
			sub_chunk_count <= 8'h0F;
			subidx <= 4'h0;
			recrc <= 1'b1;
			leadout_title_pending <= 1'b0;
			leadout_seen <= 1'b0;
			spinpause <= 1'b1;
			splay <= 5'h15;
			stop <= 1'b0;
			aud_add <= 30'h0;
			track_idx <= dsa_spin_pending_first_track;
			cur_samples <= 10'h0;
			cur_rframes <= 7'h0;
			cur_rseconds <= 6'h2;
			cur_rminutes <= 7'h0;
			gframes <= 3'h0;
			cues_addr <= dsa_spin_pending_first_track;
			cuet_addr <= dsa_spin_pending_first_track;
			updabs_req <= 1'b1;
		end
		spin_up_pending_rsp <= 1'b0;
	end
	if (goto_found_pending_rsp && (ds_resp_size <= 3'h1) && !ds_a && !butch_reg[0][13]) begin
		butch_reg[0][12] <= 1'b1;
		butch_reg[0][13] <= 1'b1;
		if (attiabs || attirel) begin
			ds_resp[0] <= 32'h1000 | atti_cur_title;
			ds_resp[1] <= 32'h1100 | atti_cur_index;
			ds_resp[4] <= 32'h0100;
			ds_resp_size <= 3'h5;
			atti_report_valid <= 1'b1;
			atti_last_title <= atti_cur_title;
			atti_last_index <= atti_cur_index;
			atti_last_abs_minutes <= cur_aminutes[6:0];
			atti_last_abs_seconds <= cur_aseconds[5:0];
			atti_last_rel_minutes <= cur_rminutes[6:0];
			atti_last_rel_seconds <= cur_rseconds[5:0];
			if (attiabs) begin
				ds_resp[2] <= 32'h1400 | cur_aminutes[6:0];
				ds_resp[3] <= 32'h1500 | cur_aseconds[5:0];
			end else begin
				ds_resp[2] <= 32'h1200 | cur_rminutes[6:0];
				ds_resp[3] <= 32'h1300 | cur_rseconds[5:0];
			end
		end else begin
			ds_resp[0] <= 32'h0100;
			ds_resp_size <= 3'h1;
			atti_report_valid <= 1'b0;
		end
		ds_resp_idx <= 3'h0;
		ds_resp_loop <= 7'h0;
		goto_found_pending_rsp <= 1'b0;
	end
	if (gsubidx != 6'h30) begin
		gsubidx <= gsubidx + 6'd1;
		if (gsubidx[1:0]==2'b10) begin
			subcoder[{!csubg,gsubidx[5:2]}] <= subcoder0;
			subcodes[{!csubg,gsubidx[5:2]}] <= subcodes0;
			subcodet[{!csubg,gsubidx[5:2]}] <= subcodet0;
			subcodeu[{!csubg,gsubidx[5:2]}] <= subcodeu0;
			subcodev[{!csubg,gsubidx[5:2]}] <= subcodev0;
			subcodew[{!csubg,gsubidx[5:2]}] <= subcodew0;
		end else if (gsubidx[1:0]==2'b11) begin
			aud_add <= aud_add + 4'h8;
			aud_rd <= 1'b1;
		end
	end
	if (seek != 8'h0) begin
		if (seek[7]) begin       // Loop looking for cues_addr starting at last one
			seek[0] <= !seek[0];  // These two settings do alternate between updating cues_addr and using it
			seek[1] <= seek[0];
			if (!seek[1]) begin   // Check if cues_addr is before/after seek time
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
						if ({sminutes,2'b00,sseconds,1'b0,sframes} < (cues_dout[22:0])) begin
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
			if (seek[0]) begin   // Using seek0 to delay one cycle. necessary?
				seek[0] <= 1'b0;
				if ({sminutes,2'b00,sseconds,1'b0,sframes} <= cuep_dout[22:0]) begin
					cur_seconds <= 6'h0;
					cur_minutes <= 7'h0;
				end else begin
					cur_seconds <= sseconds - subtseconds + ((sseconds >= subtseconds) ? 6'h0 : 6'h3C);
					cur_minutes <= sminutes - cuep_dout[22:16] - ((sseconds >= subtseconds) ? 6'h0 : 6'h1);
				end
				if ({sminutes,2'b00,sseconds,1'b0,sframes} <= cues_dout[22:0]) begin
					cur_rseconds <= 6'h0;
					cur_rminutes <= 7'h0;
				end else begin
					cur_rseconds <= sseconds - subtrseconds + ((sseconds >= subtrseconds) ? 6'h0 : 6'h3C);
					cur_rminutes <= sminutes - cues_dout[22:16] - ((sseconds >= subtrseconds) ? 6'h0 : 6'h1);
				end
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
			// *2448=<<11 + <<8 + <<7 + <<4
			seek[1] <= 1'b0;
			taud2_add[29:8] <= {taud_add[18:0],3'h0} + {taud_add[18:0]};
			if (cd_sector2448) begin
			taud3_add[25:4] <= {taud_add[18:0],3'h0} + {taud_add[18:0]};
			end else begin
			taud3_add[25:4] <= {taud_add[18:0],1'h0} + {taud_add[18:0]};
			end
			seek_delay <= seek_delay_set;
		end else if (seek[0]) begin
			if (seek_delay != 0) begin
				seek_delay <= seek_delay - 16'h1;
				if (seek_delay == seek_delay_set) begin
					aud_add[29:0] <= {{taud2_add[29:8],4'h0} + {taud3_add[25:4]},4'h0};//[31:30] are always 0
					aud_rd <= 1'b1;
				end else if ((seek_delay == 31'h1) && aud_cbusy && !pause_mode_indicator) begin
					seek_delay <= 31'h1;
				end else if ((seek_delay == 31'h1) && cdrommd && !pause_mode_indicator && !cd_valid) begin
					seek_delay <= 31'h1;
					if (!aud_busy && !aud_cbusy) begin
						aud_rd <= 1'b1;
					end
				end else if (seek_delay == 31'h1) begin
					seek[0] <= 1'b0;
					// *2352=<<11 + <<8 + <<5 + <<4
					cur_samples <= 10'h0;
					sub_chunk_count <= 8'h0F;
					subidx <= 4'h0;
					recrc <= 1'b1;
					stop <= 1'b0;
					if (seek_found_pending && pause_mode_indicator) begin
						splay <= 5'h0;
						pause <= 1'b1;
					end else begin
						splay <= 5'h5;
						splay[4] <= 1'b1;
					end
					upd_frames <= 1'b1;
					if (seek_found_pending) begin
						seek_found_pending <= 1'b0;
						scan_goto_pending <= 1'b0;
						atti_evt_title_pending <= 1'b0;
						atti_evt_index_pending <= 1'b0;
						atti_evt_rel_minutes_pending <= 1'b0;
						atti_evt_rel_seconds_pending <= 1'b0;
						atti_evt_abs_minutes_pending <= 1'b0;
						atti_evt_abs_seconds_pending <= 1'b0;
						if (ab_found_pending_rsp) begin
							ds_resp[0] <= 32'h0100 | 32'h0044;
							ds_resp_size <= 3'h1;
							atti_report_valid <= 1'b0;
							ds_resp_idx <= 3'h0;
							ds_resp_loop <= 7'h0;
							butch_reg[0][13] <= 1'b1; // |= 0x2000
							ab_found_pending_rsp <= 1'b0;
						end else if (cdrommd || pause_mode_indicator || scan_goto_pending) begin
							if (attiabs || attirel) begin
								ds_resp[0] <= 32'h1000 | atti_cur_title;
								ds_resp[1] <= 32'h1100 | atti_cur_index;
								ds_resp[4] <= 32'h0100;
								ds_resp_size <= 3'h5;
								atti_report_valid <= 1'b1;
								atti_last_title <= atti_cur_title;
								atti_last_index <= atti_cur_index;
								atti_last_abs_minutes <= cur_aminutes[6:0];
								atti_last_abs_seconds <= cur_aseconds[5:0];
								atti_last_rel_minutes <= cur_rminutes[6:0];
								atti_last_rel_seconds <= cur_rseconds[5:0];
								if (attiabs) begin
									ds_resp[2] <= 32'h1400 | cur_aminutes[6:0];
									ds_resp[3] <= 32'h1500 | cur_aseconds[5:0];
								end else begin
									ds_resp[2] <= 32'h1200 | cur_rminutes[6:0];
									ds_resp[3] <= 32'h1300 | cur_rseconds[5:0];
								end
							end else begin
								ds_resp[0] <= 32'h0100;
								ds_resp_size <= 3'h1;
								atti_report_valid <= 1'b0;
							end
							ds_resp_idx <= 3'h0;
							ds_resp_loop <= 7'h0;
							butch_reg[0][13] <= 1'b1; // |= 0x2000
						end else begin
							goto_found_pending_rsp <= 1'b1;
						end
					end
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
				if (!aud_busy && !aud_cbusy) begin
					//aud_add <= 32'h0; // Should be already set
					aud_rd <= 1'b1;     // Request Fifo
					splay[3:0] <= 4'h4;
				end
			end else if (splay[3:0] == 4'h4) begin
				if (!aud_busy && !aud_cbusy) begin
					if (splay[4] && cdrommd && !cd_valid) begin
						aud_rd <= 1'b1;
					end else begin
						fd <= 64'h0;
						fifo[1] <= 'h0;
						fifo[0] <= 'h0;
						if (!splay[4]) begin
							splay <= 5'h0; // Does this work? Seems like it might skip the first read when splay called again later. Where is transition to play if not here?
						end else begin
							splay <= 5'h3;
						end
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
		if ((play || (stop != 1'b0) || (stop_flush_ws != 3'h0)) && !pause && !spinpause) begin
			old_ws <= wsout;
			if (old_ws != wsout) begin
				if (stop != 1'b0) begin
					play <= 1'b0;
					i2s1w <= 1'b1;
					i2s2w <= 1'b1;
					sdin[15:0] <= 16'h0;
					if (stop_flush_ws != 3'h0) begin
						stop_flush_ws <= stop_flush_ws - 3'h1;
					end
					if (stop_flush_ws == 3'h0) begin
						stop <= 1'b0;
						i2s4w <= 1'b1;
						sdin4[15:0] <= 16'h0;
						butch_reg[0][13] <= 1'b1; // |= 0x2000
					end
				end else if (seek != 8'h0) begin
					sdin[15:0] <= 16'h0;
				end else begin
					i2s1w <= !wsout;
					i2s2w <= wsout;
					if (data_wait_pending) begin
						sdin[15:0] <= 16'h0;
						underflow <= 1'b1;
						if (data_wait_cycles != DATA_WAIT_TIMEOUT) begin
							data_wait_cycles <= data_wait_cycles + 16'h1;
						end else begin
							errflow <= 1'b1;
						end
						if (cd_valid) begin
							data_wait_pending <= 1'b0;
							data_wait_cycles <= 16'h0000;
						end else if (!aud_busy && !aud_cbusy) begin
							aud_rd <= 1'b1;
						end
					end else if ((faddr[1:0] == 2'b11) && (gframes == 3'h0) && !cd_valid) begin
						sdin[15:0] <= 16'h0;
						underflow <= 1'b1;
						data_wait_pending <= 1'b1;
						data_wait_cycles <= 16'h0000;
						if (!aud_busy && !aud_cbusy) begin
							aud_rd <= 1'b1;
						end
					end else begin
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
							fd[15:0] <= {fifo[1][23:16],fifo[1][31:24]}; // use next fifo; replaces current set below
//							fd[15:0] <= {fifo[0][23:16],fifo[0][31:24]}; // use next fifo; replaces current set below
						end
						if ((faddr[1:0] == 2'b11) && (gframes == 3'h0)) begin //Assumes fifo filled before first entrance and next fifo data already pointed at.
							fd <= {fifo[1][39:32],fifo[1][47:40], fifo[1][23:16],fifo[1][31:24], fifo[1][07:00],fifo[1][15:8], fifo[1][55:48],fifo[1][63:56]}; // endian/ordering nonsense
//							fd <= {fifo[0][39:32],fifo[0][47:40], fifo[0][23:16],fifo[0][31:24], fifo[0][07:00],fifo[0][15:8], fifo[0][55:48],fifo[0][63:56]}; // endian/ordering nonsense
							fifo[1] <= fifo[0]; // is this cache necessary or can directly use 0?
							fifo[0] <= aud_in;
//						if (aud_in != aud_cmp) begin
//							underflow <= 1'b1;
//						end
							if ({cur_aminutes,2'b00,cur_aseconds,1'b0,cur_aframes} < cuep_dout[22:0]) begin
								fifo[1] <= 64'h0;
								fifo[0] <= 64'h0;
							end else if ({cur_minutes,2'b00,cur_seconds,1'b0,cur_frames} >= cuelast[22:0]) begin
								aud_add <= aud_add + 4'h8;
								if ({cur_minutes,2'b00,cur_seconds,1'b0,cur_frames} > cuelast[22:0]) begin
									fifo[0] <= 64'h0;
									aud_add[29:0] <= 30'h0;
									cuet_addr <= track_idx + 7'h1;
//						end else if (aud_in != aud_cmp) begin
						end else if (!cd_valid) begin
							underflow <= 1'b1;
								end
								if ({cur_samples[9:1],1'b0} == 10'd586) begin
									aud_add[29:0] <= 30'h0;
									cuet_addr <= track_idx + 7'h1;
								end
							end else begin
								aud_add <= aud_add + 4'h8;
								if (cd_sector2448 && ({cur_samples[9:1],1'b0} == 10'd586)) begin
									gsubidx <= 6'd0;
								end
//						if (aud_in != aud_cmp) begin
						if (!cd_valid) begin
							underflow <= 1'b1;
						end
							end
							aud_rd <= 1'b1;
							if (aud_busy) begin
//								underflow <= 1'b1;
							end
						end
						if (wsout) begin
						cur_samples <= cur_samples + 10'h1;
						if ((sub_chunk_count == 8'h1B) || (sub_chunk_count == 8'h0F)) begin
							if ((cur_samples == 10'd587)) begin
								subcode_irq_pending <= 1'b1;
								sub_chunk_count <= 8'h10;
								subidx <= 4'h0;
								csubg <= !csubg;
							end
						end else
						if ((cur_samples == 10'd48) || (cur_samples == 10'd97) ||
						    (cur_samples == 10'd146) || (cur_samples == 10'd195) ||
						    (cur_samples == 10'd244) || (cur_samples == 10'd293) ||
						    (cur_samples == 10'd342) || (cur_samples == 10'd391) ||
						    (cur_samples == 10'd440) || (cur_samples == 10'd489) ||
						    (cur_samples == 10'd538) || (cur_samples == 10'd587)) begin
							subcode_irq_pending <= 1'b1;
							sub_chunk_count <= sub_chunk_count + 8'h1;
							subidx <= subidx + 4'h1;
						end
						if (cur_samples == 10'd587) begin
							upd_frames <= 1'b1;
							frame_irq_pending <= 1'b1;
							cur_samples <= 10'h0;
							if (abplay && (cur_abs_packed >= ab_end_packed)) begin
								abplay <= 1'b0;
								play <= 1'b0;
								stop <= 1'b1;
								stop_flush_ws <= STOP_FLUSH_WS_COUNT;
								ds_resp[0] <= 32'h0100 | 32'h0045;
								ds_resp_idx <= 3'h0;
								ds_resp_size <= 3'h1;
								ds_resp_loop <= 7'h0;
								butch_reg[0][13] <= 1'b1; // |= 0x2000
								i2s1w <= 1'b1;
								i2s2w <= 1'b1;
								sdin[15:0] <= 16'h0;
							end
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
//						splay <= 5'h5;
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
	end

		if (wet && ain[23:8]==24'hdfff) begin // restrict to lower 0-3f?
		if (ain[5:2]==4'h0) begin  // BUTCH ICR
			if (!ewe2l) begin
				butch_reg[4'h0][31:16] <= din[31:16];
			end
			if (!ewe0l) begin
				butch_reg[4'h0][15:8] <= butch_reg[4'h0][15:8] & ~{din[15:14],4'b0000,din[9:8]}; // I think this wrong. All these should probably be cleared by reading corresponding registers
				butch_reg[4'h0][7:0] <= din[7:0];
				// interrupt control
			end
		end else if (aeven) begin
			butch_reg[ain[5:2]][31:0] <= din[31:0];
		end else begin
			butch_reg[ain[5:2]][15:0] <= din[15:0];
		end
		if (ain[5:2]==4'h4) begin  // I2SCTRL
			// Data-mode BIOS flows use bit 2 as the streaming gate. Only let
			// that gate auto-start transport in CD-ROM mode, and only on a
			// 0->1 transition so audio-path writes do not retrigger playback.
			if (!ewe0l && cdrommd && din[2] && !butch_reg[4][2] && !play && seek==0 && splay==0) begin
				splay <= 5'h15;
			end
		end
		if (ds_a) begin
			// DSA info came from later spec. Some of these may be wrong/missing/unsupported for the Jag.
			last_ds <= din[15:0];
			unhandled <= 1'b1;
			play_title_pending_rsp <= 1'b0;
			title_len_pending_rsp <= 1'b0;
			toc_read_pending_rsp <= 1'b0;
			spin_up_pending_rsp <= 1'b0;
			if (din[15:8]==8'h01) begin  // Play Title
				unhandled <= 1'b0;
				abplay <= 1'b0;
				ab_found_pending_rsp <= 1'b0;
				butch_reg[0][12] <= 1'b1;
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (!dsa_disc_ready) begin
					queue_dsa_error(dsa_presence_error);
				end else begin
					butch_reg[0][13] <= 1'b0;
					ds_resp_size <= 3'h0;
					play_title_pending_rsp <= 1'b1;
					play_title_pending_track <= (din[6:0] == 7'h00) ? 7'h01 : din[6:0];
					goto_found_pending_rsp <= 1'b0;
					scan_goto_pending <= 1'b0;
					atti_report_valid <= 1'b0;
					atti_force_full_update <= 1'b0;
					atti_evt_title_pending <= 1'b0;
					atti_evt_index_pending <= 1'b0;
					atti_evt_rel_minutes_pending <= 1'b0;
					atti_evt_rel_seconds_pending <= 1'b0;
					atti_evt_abs_minutes_pending <= 1'b0;
					atti_evt_abs_seconds_pending <= 1'b0;
					leadout_title_pending <= 1'b0;
					leadout_seen <= 1'b0;
					subcode_irq_pending <= 1'b0;
					frame_irq_pending <= 1'b0;
					sub_chunk_count <= 8'h0F;
					subidx <= 4'h0;
					recrc <= 1'b1;
					play <= 1'b0;
					seek <= 8'h0;
					seek_found_pending <= 1'b0;
					stop_flush_ws <= 3'h0;
					cur_frames <= 7'h0;
					cur_seconds <= 6'h0;
					cur_minutes <= 7'h0;
					cur_rframes <= 7'h0;
					cur_rseconds <= 6'h0;
					cur_rminutes <= 7'h0;
					clear_audio_transport();
					spinpause <= 1'b0;
					splay <= 5'h15;
					stop <= 1'b0;
					aud_add <= 30'h0;
					track_idx <= (din[6:0] == 7'h00) ? 7'h01 : din[6:0];
					cues_addr <= (din[6:0] == 7'h00) ? 7'h01 : din[6:0];
					cuet_addr <= (din[6:0] == 7'h00) ? 7'h01 : din[6:0];
					updabs_req <= 1'b1;
				end
			end
			if (din[15:8]==8'h02) begin  // Stop
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= !play; // |= 0x2000
				ds_resp[0] <= 32'h0200;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				play <= 1'b0;
				stop <= play;
				stop_flush_ws <= play ? STOP_FLUSH_WS_COUNT : 3'h0;
				seek <= 8'h0;
				seek_found_pending <= 1'b0;
				goto_found_pending_rsp <= 1'b0;
				ab_found_pending_rsp <= 1'b0;
				scan_goto_pending <= 1'b0;
				abplay <= 1'b0;
				abseek <= 8'h0;
				clear_dsa_runtime_events();
				subcode_irq_pending <= 1'b0;
				frame_irq_pending <= 1'b0;
				sub_chunk_count <= 8'h0F;
				subidx <= 4'h0;
				recrc <= 1'b1;
				leadout_title_pending <= 1'b0;
				leadout_seen <= 1'b0;
				track_idx <= 7'h1;
				cur_frames <= 7'h0;
				cur_seconds <= 6'h0;
				cur_minutes <= 7'h0;
				cur_rframes <= 7'h0;
				cur_rseconds <= 6'h0;
				cur_rminutes <= 7'h0;
				cur_aframes <= 7'h0;
				cur_aseconds <= 6'h0;
				cur_aminutes <= 7'h0;
				aud_add <= 30'h0;
				cues_addr <= 7'h1;
				cuet_addr <= 7'h1;
				updabs_req <= 1'b0;
				updabs <= 1'b0;
				clear_audio_transport();
				pause <= 1'b0;
				pause_mode_indicator <= 1'b0;
				spinpause <= 1'b0;
			end
			if (din[15:8]==8'h03) begin  // Read TOC
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				if (!cd_ex) begin
					queue_dsa_error(DSA_ERR_FOCUS_NO_DISC);
				end else if (!toc_ready) begin
					butch_reg[0][13] <= 1'b0;
					ds_resp_size <= 3'h0;
					toc_read_pending_rsp <= 1'b1;
					toc_read_pending_session <= din[7:0];
				end else if ((dsa_req_session >= dsa_visible_session_count) || !dsa_req_sess_valid) begin
					queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
				end else begin
					// TOC read leaves the drive paused at the first track of the
					// requested session, but does not alter the pause-mode indicator.
					clear_dsa_runtime_events();
					play_title_pending_rsp <= 1'b0;
					title_len_pending_rsp <= 1'b0;
					play <= 1'b0;
					stop <= play;
					stop_flush_ws <= play ? STOP_FLUSH_WS_COUNT : 3'h0;
					seek <= 8'h0;
					seek_found_pending <= 1'b0;
					goto_found_pending_rsp <= 1'b0;
					ab_found_pending_rsp <= 1'b0;
					scan_goto_pending <= 1'b0;
					abplay <= 1'b0;
					abseek <= 8'h0;
					subcode_irq_pending <= 1'b0;
					frame_irq_pending <= 1'b0;
					sub_chunk_count <= 8'h0F;
					subidx <= 4'h0;
					recrc <= 1'b1;
					atti_report_valid <= 1'b0;
					atti_force_full_update <= 1'b0;
					atti_evt_title_pending <= 1'b0;
					atti_evt_index_pending <= 1'b0;
					atti_evt_rel_minutes_pending <= 1'b0;
					atti_evt_rel_seconds_pending <= 1'b0;
					atti_evt_abs_minutes_pending <= 1'b0;
					atti_evt_abs_seconds_pending <= 1'b0;
					leadout_title_pending <= 1'b0;
					leadout_seen <= 1'b0;
					clear_audio_transport();
					pause <= 1'b0;
					spinpause <= 1'b1;
					splay <= 5'h15;
					cur_samples <= 10'h0;
					cur_frames <= 7'h0;
					cur_seconds <= 6'h0;
					cur_minutes <= 7'h0;
					cur_rframes <= 7'h0;
					cur_rseconds <= 6'h0;
					cur_rminutes <= 7'h0;
					cur_aframes <= 7'h0;
					cur_aseconds <= 6'h0;
					cur_aminutes <= 7'h0;
					gframes <= 3'h0;
					aud_add <= 30'h0;
					track_idx <= dsa_req_first_track;
					cues_addr <= dsa_req_first_track;
					cuet_addr <= dsa_req_first_track;
					updabs_req <= 1'b1;

					/* first track number */
					ds_resp[0] <= 32'h2000 | dsa_req_first_track;
					/* last track number */
					ds_resp[1] <= 32'h2100 | dsa_req_last_track;

					/* end of last track minutes */
					ds_resp[2] <= 32'h2200 | dsa_req_leadout[22:16];
					/* end of last track seconds */
					ds_resp[3] <= 32'h2300 | dsa_req_leadout[13:8];
					/* end of last track frame */
					ds_resp[4] <= 32'h2400 | dsa_req_leadout[6:0];
					ds_resp_size <= 3'h5;
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
				pause_mode_indicator <= 1'b1;
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
				pause_mode_indicator <= 1'b0;
				goto_found_pending_rsp <= 1'b0;
				spinpause <= 1'b0;
			end
			if (din[15:8]==8'h09) begin  // Get Title Length
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (!dsa_disc_ready) begin
					queue_dsa_error(dsa_presence_error);
				end else if ((din[6:0] == 7'h00) || (din[6:0] > aud_tracks)) begin
					queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
				end else begin
					butch_reg[0][13] <= 1'b0;
					ds_resp_size <= 3'h0;
					cues_addr <= din[6:0];
					title_len_pending_rsp <= 1'b1;
				end
			end
			if (din[15:8]==8'h0A) begin  // Open Tray
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0C00;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h0B) begin  // Close Tray
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0D00;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h0C) begin  // Reserved
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				queue_dsa_error(DSA_ERR_ILLEGAL_CMD);
			end
			if (din[15:8]==8'h0D) begin  // Get Complete Time
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h1400 | cur_aminutes[6:0];
				ds_resp[1] <= 32'h1500 | cur_aseconds[5:0];
				ds_resp[2] <= 32'h1600 | cur_aframes[6:0]; // needs to wait for next change
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h3;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h10) begin  // 0x10 Goto ABS Min
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (din[6:0] > 7'd99) begin
					queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
				end else begin
					ds_resp_size <= 3'h0;
					goto_minutes <= din[6:0];
					sminutes <= din[6:0];
				end
			end
			if (din[15:8]==8'h11) begin  // 0x10 Goto ABS Sec
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (din[5:0] > 6'd59) begin
					queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
				end else begin
					ds_resp_size <= 3'h0;
					goto_seconds <= din[5:0];
					sseconds <= din[5:0];
				end
			end
			if (din[15:8]==8'h12) begin  // 0x10 Goto ABS Frame
				unhandled <= 1'b0;
				abplay <= 1'b0;
				ab_found_pending_rsp <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (!dsa_disc_ready) begin
					queue_dsa_error(dsa_presence_error);
					seek_found_pending <= 1'b0;
					goto_found_pending_rsp <= 1'b0;
					scan_goto_pending <= 1'b0;
				end else if ((goto_minutes > 7'd99) || (goto_seconds > 6'd59) || (din[6:0] > 7'd74) || goto_target_past_leadout) begin
					queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
					seek_found_pending <= 1'b0;
					goto_found_pending_rsp <= 1'b0;
					scan_goto_pending <= 1'b0;
				end else begin
//					butch_reg[0][13] <= 1'b1; // |= 0x2000 // too fast - wait for seek time
//					ds_resp[0] <= 32'h0140; // dsa says 0x140; code is looking for 0x100
//					ds_resp[0] <= 32'h0100; // too fast - wait for seek time
					butch_reg[0][13] <= 1'b0;
					ds_resp_size <= 3'h1;
					seek_found_pending <= 1'b1;
					scan_goto_pending <= interactive_scan_context;
					clear_dsa_seek_events();
					scan_goto_pending <= interactive_scan_context;
					subcode_irq_pending <= 1'b0;
					frame_irq_pending <= 1'b0;
					sub_chunk_count <= 8'h0F;
					subidx <= 4'h0;
					recrc <= 1'b1;
					sminutes <= goto_minutes;
					sseconds <= goto_seconds;
					sframes <= din[6:0];
					seek_delay_set <= goto_seek_delay_cycles(goto_delta_frames, cd_latency_en);
					cues_addr <= num_tracks + 7'h1;
					cuet_addr <= num_tracks + 7'h1;
					seek <= 8'hFF;
					stop <= 1'b0;
					spinpause <= 1'b0;
				end
			end
			if (din[15:8]==8'h14) begin  // Read Long TOC
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp_idx <= 3'h0;
				if (!dsa_disc_ready) begin  // No disc / TOC not ready
					queue_dsa_error(dsa_presence_error);
				end else if ((dsa_req_session >= dsa_visible_session_count) || !dsa_req_sess_valid) begin
					queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
				end else begin
					ds_resp[0] <= 32'h6000;
					ds_resp[1] <= 32'h6100;
					ds_resp[2] <= 32'h6200;
					ds_resp[3] <= 32'h6300;
					ds_resp[4] <= 32'h6400;
					ds_resp[5] <= 32'h6500 | dsa_req_session;
					ds_resp_size <= 3'h6;
					ds_resp_loop <= (dsa_req_last_track > dsa_req_first_track) ? (dsa_req_last_track - dsa_req_first_track) : 7'h0;
					dsa_long_toc_session <= dsa_req_session;
					cues_addr <= dsa_req_first_track;
					updrespa <= 1'b1;
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
				if ((((mode[5:4] == 2'b01) && (din[5:4] == 2'b10)) ||
				     ((mode[5:4] == 2'b10) && (din[5:4] == 2'b01))) &&
				    atti_setmode_context_valid) begin
					atti_report_valid <= 1'b1;
					atti_force_full_update <= 1'b1;
					atti_last_title <= atti_cur_title;
					atti_last_index <= atti_cur_index;
					atti_last_rel_minutes <= cur_rminutes[6:0];
					atti_last_rel_seconds <= cur_rseconds[5:0];
					atti_last_abs_minutes <= cur_aminutes[6:0];
					atti_last_abs_seconds <= cur_aseconds[5:0];
					atti_evt_title_pending <= 1'b1;
					atti_evt_index_pending <= 1'b1;
					atti_evt_rel_minutes_pending <= (din[5:4] == 2'b10);
					atti_evt_rel_seconds_pending <= (din[5:4] == 2'b10);
					atti_evt_abs_minutes_pending <= (din[5:4] == 2'b01);
					atti_evt_abs_seconds_pending <= (din[5:4] == 2'b01);
				end else begin
					atti_report_valid <= 1'b0;
					atti_force_full_update <= 1'b0;
					atti_evt_title_pending <= 1'b0;
					atti_evt_index_pending <= 1'b0;
					atti_evt_rel_minutes_pending <= 1'b0;
					atti_evt_rel_seconds_pending <= 1'b0;
					atti_evt_abs_minutes_pending <= 1'b0;
					atti_evt_abs_seconds_pending <= 1'b0;
				end
				if (din[1]) begin // bit1=speed2x
					sdin3[15:0] <= 16'h3; // 2*(3+1)=8 min for 9.279 (- currently setting 3 will alternate 3 and 4)
				end else begin // bit0=speed1x
					sdin3[15:0] <= 16'h8; // 2*(8+1)=18 min for 18.558
				end
				i2s3w <= 1'b1;
			end
			if (din[15:8]==8'h16) begin  // Get Last Error
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0400 | dsa_last_error;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h17) begin  // Clear Error
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0400;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				dsa_last_error <= 8'h00;
			end
			if (din[15:8]==8'h18) begin  // Spin Up
				unhandled <= 1'b0;
				abplay <= 1'b0;
				ab_found_pending_rsp <= 1'b0;
				butch_reg[0][12] <= 1'b1;
				butch_reg[0][13] <= 1'b1;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				if (!cd_ex) begin
					queue_dsa_error(DSA_ERR_FOCUS_NO_DISC);
				end else if (!toc_ready) begin
					butch_reg[0][13] <= 1'b0;
					ds_resp_size <= 3'h0;
					spin_up_pending_rsp <= 1'b1;
					spin_up_pending_session <= din[7:0];
				end else if (!dsa_spin_req_sess_valid || (dsa_spin_req_first_track == 7'h00)) begin
					queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
				end else begin
					ds_resp[0] <= 32'h0100;
					clear_dsa_seek_events();
					subcode_irq_pending <= 1'b0;
					frame_irq_pending <= 1'b0;
					sub_chunk_count <= 8'h0F;
					subidx <= 4'h0;
					recrc <= 1'b1;
					leadout_title_pending <= 1'b0;
					leadout_seen <= 1'b0;
					spinpause <= 1'b1;
					splay <= 5'h15;
					stop <= 1'b0;
					aud_add <= 30'h0;
					track_idx <= dsa_spin_req_first_track;
					cur_samples <= 10'h0;
					cur_rframes <= 7'h0;
					cur_rseconds <= 6'h2;
					cur_rminutes <= 7'h0;
					gframes <= 3'h0;
					cues_addr <= dsa_spin_req_first_track;
					cuet_addr <= dsa_spin_req_first_track;
					updabs_req <= 1'b1;
				end
			end
			if (din[15:8]==8'h20) begin  // Play A Time To B Time Start Min
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				clear_dsa_runtime_events();
				play <= 1'b0;
				stop <= play;
				stop_flush_ws <= play ? STOP_FLUSH_WS_COUNT : 3'h0;
				seek <= 8'h0;
				seek_found_pending <= 1'b0;
				goto_found_pending_rsp <= 1'b0;
				ab_found_pending_rsp <= 1'b0;
				abplay <= 1'b0;
				abaminutes <= din[6:0];
			end
			if (din[15:8]==8'h21) begin  // Play A Time To B Time Start Sec
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				clear_dsa_runtime_events();
				play <= 1'b0;
				stop <= play;
				stop_flush_ws <= play ? STOP_FLUSH_WS_COUNT : 3'h0;
				seek <= 8'h0;
				seek_found_pending <= 1'b0;
				goto_found_pending_rsp <= 1'b0;
				ab_found_pending_rsp <= 1'b0;
				abplay <= 1'b0;
				abaseconds <= din[5:0];
			end
			if (din[15:8]==8'h22) begin  // Play A Time To B Time Start Frame
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				clear_dsa_runtime_events();
				play <= 1'b0;
				stop <= play;
				stop_flush_ws <= play ? STOP_FLUSH_WS_COUNT : 3'h0;
				seek <= 8'h0;
				seek_found_pending <= 1'b0;
				goto_found_pending_rsp <= 1'b0;
				ab_found_pending_rsp <= 1'b0;
				abplay <= 1'b0;
				abaframes <= din[6:0];
			end
			if (din[15:8]==8'h23) begin  // Play A Time To B Time Stop Min
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				clear_dsa_runtime_events();
				play <= 1'b0;
				stop <= play;
				stop_flush_ws <= play ? STOP_FLUSH_WS_COUNT : 3'h0;
				seek <= 8'h0;
				seek_found_pending <= 1'b0;
				goto_found_pending_rsp <= 1'b0;
				ab_found_pending_rsp <= 1'b0;
				abplay <= 1'b0;
				abbminutes <= din[6:0];
			end
			if (din[15:8]==8'h24) begin  // Play A Time To B Time Stop Sec
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				clear_dsa_runtime_events();
				play <= 1'b0;
				stop <= play;
				stop_flush_ws <= play ? STOP_FLUSH_WS_COUNT : 3'h0;
				seek <= 8'h0;
				seek_found_pending <= 1'b0;
				goto_found_pending_rsp <= 1'b0;
				ab_found_pending_rsp <= 1'b0;
				abplay <= 1'b0;
				abbseconds <= din[5:0];
			end
			if (din[15:8]==8'h25) begin  // Play A Time To B Time Stop Frame / Commit
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (!dsa_disc_ready) begin
					queue_dsa_error(dsa_presence_error);
					seek_found_pending <= 1'b0;
					goto_found_pending_rsp <= 1'b0;
					ab_found_pending_rsp <= 1'b0;
					abplay <= 1'b0;
				end else if ((abaminutes > 7'd99) || (abaseconds > 6'd59) || (abaframes > 7'd74) ||
				             (abbminutes > 7'd99) || (abbseconds > 6'd59) || (din[6:0] > 7'd74) ||
				             (ab_start_packed > ab_end_packed_next) ||
				             (ab_start_packed >= dsa_disc_leadout_packed) ||
				             (ab_end_packed_next >= dsa_disc_leadout_packed)) begin
					queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
					seek_found_pending <= 1'b0;
					goto_found_pending_rsp <= 1'b0;
					ab_found_pending_rsp <= 1'b0;
					abplay <= 1'b0;
				end else begin
					butch_reg[0][13] <= 1'b0;
					ds_resp_size <= 3'h1;
					abbframes <= din[6:0];
					abplay <= 1'b1;
					abseek <= 8'hFF;
					ab_found_pending_rsp <= 1'b1;
					goto_found_pending_rsp <= 1'b0;
					scan_goto_pending <= 1'b0;
					clear_dsa_seek_events();
					ab_found_pending_rsp <= 1'b1;
					subcode_irq_pending <= 1'b0;
					frame_irq_pending <= 1'b0;
					sub_chunk_count <= 8'h0F;
					subidx <= 4'h0;
					recrc <= 1'b1;
					leadout_title_pending <= 1'b0;
					leadout_seen <= 1'b0;
					sminutes <= abaminutes;
					sseconds <= abaseconds;
					sframes <= abaframes;
					seek_delay_set <= goto_seek_delay_cycles(ab_start_delta_frames, cd_latency_en);
					cues_addr <= num_tracks + 7'h1;
					cuet_addr <= num_tracks + 7'h1;
					seek <= 8'hFF;
					seek_found_pending <= 1'b1;
					stop <= 1'b0;
					spinpause <= 1'b0;
				end
			end
			if (din[15:8]==8'h26) begin  // Release A Time To B Time
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000 // too fast - wait for seek time
				ds_resp[0] <= 32'h2600;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				abplay <= 1'b0;
				abseek <= 8'h0;
				ab_found_pending_rsp <= 1'b0;
			end
			if (din[15:8]==8'h30) begin  // Get Disc identifiers - not implemented
				unhandled <= 1'b1;
				butch_reg[0][12] <= 1'b1;
				butch_reg[0][13] <= 1'b1;
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (!dsa_disc_ready) begin
					queue_dsa_error(dsa_presence_error);
				end else begin
					ds_resp[0] <= 32'h3000 | dsa_disc_id0;
					ds_resp[1] <= 32'h3100 | dsa_disc_id1;
					ds_resp[2] <= 32'h3200 | dsa_disc_id2;
					ds_resp[3] <= 32'h3300 | dsa_disc_id3;
					ds_resp[4] <= 32'h3400 | dsa_disc_id4;
					ds_resp_size <= 3'h5;
				end
			end
			if ((din[15:8] >= 8'h40) && (din[15:8] <= 8'h44)) begin  // Reserved
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1;
				queue_dsa_error(DSA_ERR_ILLEGAL_CMD);
			end
			if (din[15:8]==8'h50) begin  // Get Disc Status
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= dsa_disc_status_resp;
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
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				if (!dsa_disc_ready) begin
					queue_dsa_error(dsa_presence_error);
				end else begin
					ds_resp[0] <= 32'h5400 | dsa_visible_session_count;
				end
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
			if (din[15:8]==8'h70) begin  // Set DAC Mode
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp_size <= 3'h1;
				if (dsa_dac_mode_valid) begin
					ds_resp[0] <= 32'h7000 | din[7:0];
				end else begin
					queue_dsa_error(DSA_ERR_ILLEGAL_VALUE);
				end
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
			if ((din[15:8] >= 8'hF0) && (din[15:8] <= 8'hF4)) begin
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1;
				queue_dsa_error(DSA_ERR_ILLEGAL_CMD);
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
		if (ds_resp_size == 3'h0) begin
			ds_resp_idx <= 3'h0;
		end else if (ds_resp_size == ds_resp_idx + 3'h1) begin
			ds_resp_idx <= 3'h0;
			if (ds_resp_loop != 7'h0) begin
				ds_resp_loop <= ds_resp_loop - 7'h1;
				cues_addr <= cues_addr + 7'h1;
				updrespa <= 1'b1;
			end else begin
				ds_resp_size <= 3'h0;
//				butch_reg[0][13] <= 1'b0; // &= ~0x2000
			end
		end
	end
	if (updrespa) begin
		updrespa <= 1'b0;
		updresp <= 1'b1;
	end
	if (updresp) begin
		ds_resp[0][15:8] <= 8'h60;
		ds_resp[0][7:0] <= cues_add;
		ds_resp[1][15:8] <= 8'h61;
		ds_resp[1][7:0] <= dsa_long_toc_ctrl_addr;
		ds_resp[2][15:8] <= 8'h62;
		ds_resp[2][7:0] <= {1'b0,cues_dout[22:16]};
		ds_resp[3][15:8] <= 8'h63;
		ds_resp[3][7:0] <= {2'b0,cues_dout[13:8]};
		ds_resp[4][15:8] <= 8'h64;
		ds_resp[4][7:0] <= {1'b0,cues_dout[6:0]};
		ds_resp[5][15:8] <= 8'h65;
		ds_resp[5][7:0] <= dsa_long_toc_session;
	end
	if (atti_force_full_update &&
		!atti_evt_title_pending &&
		!atti_evt_index_pending &&
		!atti_evt_rel_minutes_pending &&
		!atti_evt_rel_seconds_pending &&
		!atti_evt_abs_minutes_pending &&
		!atti_evt_abs_seconds_pending) begin
		atti_force_full_update <= 1'b0;
	end
	if (!(attirel || attiabs)) begin
		atti_report_valid <= 1'b0;
		atti_force_full_update <= 1'b0;
		atti_evt_title_pending <= 1'b0;
		atti_evt_index_pending <= 1'b0;
		atti_evt_rel_minutes_pending <= 1'b0;
		atti_evt_rel_seconds_pending <= 1'b0;
		atti_evt_abs_minutes_pending <= 1'b0;
		atti_evt_abs_seconds_pending <= 1'b0;
	end else if (atti_runtime_active) begin
		if (!atti_report_valid) begin
			atti_report_valid <= 1'b1;
			atti_last_title <= atti_cur_title;
			atti_last_index <= atti_cur_index;
			atti_last_rel_minutes <= cur_rminutes[6:0];
			atti_last_rel_seconds <= cur_rseconds[5:0];
			atti_last_abs_minutes <= cur_aminutes[6:0];
			atti_last_abs_seconds <= cur_aseconds[5:0];
			// Emit an initial ATTI snapshot on first stable playback entry so
			// VLM/UI consumers do not miss the current time if the earlier
			// play-title response path was bypassed or already consumed.
			atti_evt_title_pending <= 1'b1;
			atti_evt_index_pending <= 1'b1;
			atti_evt_rel_minutes_pending <= attirel;
			atti_evt_rel_seconds_pending <= attirel;
			atti_evt_abs_minutes_pending <= attiabs;
			atti_evt_abs_seconds_pending <= attiabs;
		end else begin
			if (atti_cur_title != atti_last_title) begin
				atti_evt_title_pending <= 1'b1;
				atti_last_title <= atti_cur_title;
			end
			if (atti_cur_index != atti_last_index) begin
				atti_evt_index_pending <= 1'b1;
				atti_last_index <= atti_cur_index;
			end
			if (attirel) begin
				if (cur_rminutes[6:0] != atti_last_rel_minutes) begin
					atti_evt_rel_minutes_pending <= 1'b1;
					atti_last_rel_minutes <= cur_rminutes[6:0];
				end
				if (cur_rseconds[5:0] != atti_last_rel_seconds) begin
					atti_evt_rel_seconds_pending <= 1'b1;
					atti_last_rel_seconds <= cur_rseconds[5:0];
				end
			end
			if (attiabs) begin
				if (cur_aminutes[6:0] != atti_last_abs_minutes) begin
					atti_evt_abs_minutes_pending <= 1'b1;
					atti_last_abs_minutes <= cur_aminutes[6:0];
				end
				if (cur_aseconds[5:0] != atti_last_abs_seconds) begin
					atti_evt_abs_seconds_pending <= 1'b1;
					atti_last_abs_seconds <= cur_aseconds[5:0];
				end
			end
		end
	end
	if ((!play || !subq_leadout || cdrommd) && !leadout_title_pending) begin
		leadout_seen <= 1'b0;
	end
	if (!cdrommd && play && !spinpause && subq_leadout && !leadout_seen) begin
		leadout_seen <= 1'b1;
		pause <= 1'b1;
		leadout_title_pending <= 1'b1;
		atti_report_valid <= 1'b0;
		atti_evt_title_pending <= 1'b0;
		atti_evt_index_pending <= 1'b0;
		atti_evt_rel_minutes_pending <= 1'b0;
		atti_evt_rel_seconds_pending <= 1'b0;
		atti_evt_abs_minutes_pending <= 1'b0;
		atti_evt_abs_seconds_pending <= 1'b0;
	end
	if (!atti_evt_drain_active) begin
		atti_evt_title_pending <= 1'b0;
		atti_evt_index_pending <= 1'b0;
		atti_evt_rel_minutes_pending <= 1'b0;
		atti_evt_rel_seconds_pending <= 1'b0;
		atti_evt_abs_minutes_pending <= 1'b0;
		atti_evt_abs_seconds_pending <= 1'b0;
	end
	if ((ds_resp_size == 3'h0) &&
		!ds_a &&
		!updresp &&
		!updrespa &&
		!play_title_pending_rsp) begin
		if (leadout_title_pending) begin
			leadout_title_pending <= 1'b0;
			ds_resp[0] <= 32'h1000 | 8'hAA;
			atti_report_valid <= 1'b1;
			atti_last_title <= 8'hAA;
			atti_last_index <= 8'h01;
		end else if (atti_evt_drain_active && atti_evt_title_pending) begin
			atti_evt_title_pending <= 1'b0;
			ds_resp[0] <= 32'h1000 | atti_cur_title;
		end else if (atti_evt_drain_active && atti_evt_index_pending) begin
			atti_evt_index_pending <= 1'b0;
			ds_resp[0] <= 32'h1100 | atti_cur_index;
		end else if (atti_evt_drain_active && attirel && atti_evt_rel_minutes_pending) begin
			atti_evt_rel_minutes_pending <= 1'b0;
			ds_resp[0] <= 32'h1200 | cur_rminutes[6:0];
		end else if (atti_evt_drain_active && attirel && atti_evt_rel_seconds_pending) begin
			atti_evt_rel_seconds_pending <= 1'b0;
			ds_resp[0] <= 32'h1300 | cur_rseconds[5:0];
		end else if (atti_evt_drain_active && attiabs && atti_evt_abs_minutes_pending) begin
			atti_evt_abs_minutes_pending <= 1'b0;
			ds_resp[0] <= 32'h1400 | cur_aminutes[6:0];
		end else if (atti_evt_drain_active && attiabs && atti_evt_abs_seconds_pending) begin
			atti_evt_abs_seconds_pending <= 1'b0;
			ds_resp[0] <= 32'h1500 | cur_aseconds[5:0];
		end
		if (leadout_title_pending ||
			(atti_evt_drain_active &&
			(atti_evt_title_pending ||
			 atti_evt_index_pending ||
			 (attirel && atti_evt_rel_minutes_pending) ||
			 (attirel && atti_evt_rel_seconds_pending) ||
			 (attiabs && atti_evt_abs_minutes_pending) ||
			 (attiabs && atti_evt_abs_seconds_pending)))) begin
			butch_reg[0][12] <= 1'b1;
			butch_reg[0][13] <= 1'b1;
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
		end
	end
	if (old_doe_suba && !doe_suba) begin
		// SUBDATA reads no longer advance the chunk stream. Transport cadence owns
		// `subidx` and the emitted low-byte chunk tag.
	end
	if (old_doe_dsc && !doe_dsc) begin
		butch_reg[0][12] <= 1'b0;
		butch_reg[0][13] <= ((ds_resp_size == 3'h0) || (ds_resp_size == 3'h1)) ? 1'b0 : 1'b1;
	end
	if (old_doe_sbcntrl && !doe_sbcntrl) begin
		subcode_irq_pending <= 1'b0;
		frame_irq_pending <= 1'b0;
	end
	if (!old_doe_suba && !doe_suba && !old_doe_subb && !doe_subb) begin
		if ((4'h0 == subidx) && upd_frames) begin
			upd_frames <= 1'b0;
			recrc <= 1'b1;
		end
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
	butch_reg[0][10] <= subcode_irq_pending;
	butch_reg[0][11] <= frame_irq_pending;
end

wire [6:0] cuet_add;
wire [31:0] cuet_din;
wire [31:0] cuet_doutt;
wire cuet_wr;
wire [31:0] cuet_dout = (cuet_add > cue_tracks) ? 32'h0 : cuet_doutt;
spram #(.addr_width(7), .data_width(32)) cuet_bram_inst
(
	.clock   ( sys_clk ),

	.address ( cuet_add ),
	.data    ( cuet_din ),
	.wren    ( cuet_wr ),

	.q       ( cuet_doutt )
);
//track aud_track_offset

wire [6:0] cues_add;
wire [23:0] cues_din;
wire [23:0] cues_doutt;
wire cues_wr;
wire [23:0] cues_dout = (cues_add > cue_tracks) ? cuestop[dsa_last_sess_idx[0]] : cues_doutt;
spram #(.addr_width(7), .data_width(24)) cues_bram_inst
(
	.clock   ( sys_clk ),

	.address ( cues_add ),
	.data    ( cues_din ),
	.wren    ( cues_wr ),

	.q       ( cues_doutt )
);
//mmssff start

wire [6:0] cuep_add;
wire [23:0] cuep_din;
wire [23:0] cuep_doutt;
wire cuep_wr;
wire [23:0] cuep_dout = (cuep_add > cue_tracks) ? cuestop[dsa_last_sess_idx[0]] : cuep_doutt;
spram #(.addr_width(7), .data_width(24)) cuep_bram_inst
(
	.clock   ( sys_clk ),

	.address ( cuep_add ),
	.data    ( cuep_din ),
	.wren    ( cuep_wr ),

	.q       ( cuep_doutt )
);
//mmssff pregap

wire [6:0] cuel_add;
wire [23:0] cuel_din;
wire [23:0] cuel_doutt;
wire carryf = cuel_dout[6:0]==7'h00;
wire carrys = cuel_dout[13:0]==14'h00;
reg [23:0] cuelast;// = {carrys?cuel_dout[23:16]-8'h1:cuel_dout[23:16],carrys?8'h3B:carryf?cuel_dout[15:8]-8'h1:cuel_dout[15:8],carryf?8'h4A:cuel_dout[7:0]-8'h1};
wire cuel_wr;
wire [23:0] cuel_dout = (cuel_add > cue_tracks) ? 24'h0 : cuel_doutt;
spram #(.addr_width(7), .data_width(24)) cuel_bram_inst
(
	.clock   ( sys_clk ),

	.address ( cuel_add ),
	.data    ( cuel_din ),
	.wren    ( cuel_wr ),

	.q       ( cuel_doutt )
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
assign i2srxd = i2txd && i2s_jerry;
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

//
//SBuf_Beg	equ	$F03600		;subcode buffer in GPU memory
//SBuf_Mid	equ	$F03660		; midway pointer in subcode buffer
//SBuf_End	equ	$F036C0		; end of subcode buffer
//
//;
//;==============================================================================
//; EXTERNAL INTERRUPT (#1, DSP) - HANDLES SUBCODE INTERRUPT
//;==============================================================================
//;
//sub_isr:
//	load	(gflagptr),gflag	; get GPU flags
//	load	(butchptr),R0		; get the ICR flags
//	btst	#10,R0			; check for subcode interrupt
//	jr	EQ,notours		;br if error--not a subcode irq
//	load	(subdata),R0		;get S R Q & chunk#
//sub_dat:
//	load	(subdatb),R1		;get W V U T
//	move	R0,R2
//	shlq	#24,R2
//	shrq	#24,R2
//	cmp	subcnt,R2		;are we at expected chunk count?
//	jr	EQ,goodchk		;br if good chunk #
//	move	begptr,R3		;assume bad sequence on 1st half
//;
//;  Bad sequence, we must redo the frame
//;
//	cmp	midptr,curptr		;are we in 1st or 2nd half?
//	jr	CS,firsthaf
//	addq	#1,miscount
//;
//	move	midptr,R3
//firsthaf:
//	movei	#resetcnt,R2		;jump to reset subcnt & exit
//	jump	(R2)
//	move	R3,curptr		;start fresh frame
//;	
//;  got a good subcode here
//;
//goodchk:
//	store	R0,(curptr)		;save S R Q & chunk#
//	addq	#1,subcnt		;advance next expected chunk counter
//	addq	#4,curptr		;bump buffer ptr
//	addq	#1,getcount		;increment good counter
//	store	R1,(curptr)		;save W V U T
//	addq	#4,curptr
//	moveq	#1,R1		;set half/full indicator temp (in case we need)
//;
//	cmp	midptr,curptr	;reached end of 1st half?
//	jr	NE,nothalf	;br if not
//	cmp	endptr,curptr	;test end in case we br--else it won't hurt
//;
//;  Reached end of halfway point..
//;
//	load	(hafflgp),R0	;check half buffer semiphore
//	cmp	R1,R0		;already set?
//	jr	NE,resetcnt	;if not, we can set now and exit
//	store	R1,(hafflgp)	;set hafflg=1
//;
//;  Error condition detected--better shutdown
//;
//errx:
//;	movei	#shutdown,R2
//	movei	#exitirq,R2
//	jump	(R2)
//	nop
//;
//nothalf:
//	jr	NE,exitirq
//	load	(fulflgp),R0	
//;
//	cmp	R1,R0
//	jr	EQ,errx		;br to error condition if detected
//	store	R1,(fulflgp)
//;
//	move	begptr,curptr
//resetcnt:
//	moveq	#$10,subcnt
//;
//exitirq:
//	movei	#J_INT,R0	;Jerry's interrupt ACK register
//	movei	#SBCNTRL,R2	;read this to clear the subcode interrupt flag
//;
//	bset	#10,gflag	; set DSP interrupt clear bit 
//	store	gflag,(gflagptr)	; restore flags
//	bclr	#3,gflag	; clear IMASK (for GPU)
//;
//	moveq	#1,R1
//	bset	#8,R1
//	storew	R1,(R0)		;acknowlege Jerry
//;
//	load	(gpustop),R0	;see if 68k wants to stop us
//;
//	load	(R2),R1		;clear the Butch interrupt
//;
//	or	R0,R0
//	jr	NE,shutdown	;br if 68k put a non-zero value here
//;
//;  now exit the irq by the Book
//;
//	load	(stackptr),R0	; get last instruction address
//	addq	#$2,R0		; point at next to be executed
//	addq	#$4,stackptr	; update the stack pointer
//	jump	(R0)		; and return
//	store	gflag,(gflagptr)	; restore flags
//;


endmodule
