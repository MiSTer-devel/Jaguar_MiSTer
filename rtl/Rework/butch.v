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
	input force_music_cd,
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
	input [9:0] toc_addr,
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
	input cd_valid,
	input cd_latency_en,
	output [6:0] dbg_cue_tracks,
	output [6:0] dbg_aud_tracks,
	output [6:0] dbg_dat_track,
	output [7:0] dbg_dsa_sessions,
	output       dbg_sess1_valid,
	output [15:0] dbg_last_ds,
	output [7:0] dbg_last_err,
	output [6:0] dbg_track_idx,
	output [6:0] dbg_cues_addr,
	output [6:0] dbg_cuet_addr,
	output [15:0] dbg_resp_54,
	output [39:0] dbg_toc0,
	output [39:0] dbg_toc1,
	output [15:0] dbg_spin,
	output [15:0] dbg_ltoc0,
	output [15:0] dbg_ltoc1,
	output        dbg_toc_ready,
	input sys_clk
);

wire wet = !cart_ce_n && !(ewe0l && ewe2l);
wire oet = !cart_ce_n && !(eoe0l && eoe1l);
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
//BUTCH     equ  $DFFF00	; base of Butch=interrupt control register, R/W
//assign eint = (!butch_reg[0][0]) || (!fifo_int && !frame_int &&!sub_int && !tbuf_int && !rbuf_int);
// External interrupt line from Butch is active-high in this implementation.
assign eint = cd_en && (butch_reg[0][0]) && (fifo_int || frame_int || sub_int || tbuf_int || rbuf_int);
wire fifo_int = butch_reg[0][9] && butch_reg[0][1];
wire sub_int = butch_reg[0][10] && butch_reg[0][3];
wire frame_int = butch_reg[0][11] && butch_reg[0][2];
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
reg [2:0] ds_resp_size; // max = 5
reg [6:0] ds_resp_loop; // max = numtracks=99
reg updresp; // signals for TOC responses to move to next one
reg updrespa;

//SBCNTRL   equ  BUTCH+$14	; CD subcode control register, R/W
//SUBDATA   equ  BUTCH+$18	; Subcode data register A
//SUBDATB   equ  BUTCH+$1C	; Subcode data register B
//SB_TIME   equ  BUTCH+$20	; Subcode time and compare enable (D24)
reg [6:0] rframes;  // 0-74 // (msf % 75)
reg [6:0] rseconds; // 0-59 // (msf / 75) % 60
reg [6:0] rminutes; // 0-99 // (msf / 75) / 60
reg [6:0] aframes;  // 0-74 // (msf % 75)
reg [6:0] aseconds; // 0-59 // (msf / 75) % 60
reg [6:0] aminutes; // 0-99 // (msf / 75) / 60
reg [6:0] atrack;   // 1-99
wire [7:0] subcode [0:11];
wire [6:0] atrack_safe = (atrack > 7'd99) ? 7'd99 : atrack;
wire [7:0] subq_tno;
wire [7:0] subq_index;
assign subcode[0] = 8'h1; // ctrl/addr; keep stable for compatibility with current subcode path
assign subcode[1] = subq_tno; // track no: 00 lead-in/pregap, 01..99 program, AA lead-out
assign subcode[2] = subq_index; // index: 00 pregap, 01 program
assign subcode[3] = bcd[rminutes]; // rel min bcd
assign subcode[4] = bcd[rseconds]; // rel sec bcd
assign subcode[5] = bcd[rframes]; // rel frames bcd
assign subcode[6] = 8'h0; // zero
assign subcode[7] = bcd[aminutes]; // abs min bcd
assign subcode[8] = bcd[aseconds]; // abs sec bcd
assign subcode[9] = bcd[aframes]; // abs frames bcd
assign subcode[10] = crc1; // crc1 Polynomial = P(X)=X16+X12+X5+1
assign subcode[11] = crc0; // crc0
reg [7:0] crc1;
reg [7:0] crc0;
reg [15:0] crc;
reg recrc;
reg [3:0] subidx;
reg [7:0] sub_chunk_count;
reg subcode_irq_pending;
reg frame_irq_pending;
wire [15:0] subresp = {subcode[subidx],sub_chunk_count};
wire [15:0] subresp_b = {8'h00,sub_chunk_count};
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
wire [31:0] dout_t = doe_ds ? ds_resp[ds_resp_idx] :
	doe_sub ? {subresp,subresp} :
	doe_subb ? {subresp_b,subresp_b} :
	doe_fif ? cur_i2s_fifo :
	(ain[5:2] < 4'd12) ? butch_reg[ain[5:2]] : 32'hFFFFFFFF;
wire aeven = (ain[1]==1'b0); //even is high [31:16]
wire breg = ain[23:8]==24'hdfff;
wire caddr = ain[23:22]==2'b10;
wire dsc_a = ain[5:2]==4'h1;
wire doe_dsc = doe && dsc_a;
wire ds_a = ain[5:2]==4'h2; // should be 0xA not just 0x8?
wire doe_ds = doe && ds_a;
wire dsa_cmd_stop_wr = cd_en && wet && (ain[23:8] == 24'hdfff) && ds_a && (din[15:8] == 8'h02);
wire ictl_a = ain[5:2]==4'h4; // 0x10
wire doe_ictl = doe && ictl_a;
wire sbcntrl_a = ain[5:2]==4'h5; // 0x14 (SBCNTRL)
wire doe_sbcntrl = doe && sbcntrl_a;
wire sub_a = ain[5:2]==4'h6; // should be 0x1A not just 0x18?
wire doe_sub = doe && sub_a;
wire subb_a = ain[5:2]==4'h7; // 0x1C (SUBDATB)
wire doe_subb = doe && subb_a;
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
reg old_doe_sbcntrl;
reg old_doe_fif;
reg old_fif_a1;
reg old_ws;

//wire [6:0] num_tracks = 7'd6;
wire [6:0] num_tracks = cue_tracks[6:0];
wire [6:0] num_tracks_safe = (num_tracks != 7'h0) ? num_tracks : 7'h1;
wire [6:0] cues_addr_clamped =
	(cues_addr < 7'h1) ? 7'h1 :
	((cues_addr > num_tracks_safe) ? num_tracks_safe : cues_addr);
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
wire pause_data_junk = pause && cdrommd;
// 5 - 4 = Actual Title, Time, Index (ATTI) setting
// 00 = no title, index or time send during play modes
// 01 = sending title, index and absolute time (min/sec)
// 10 = sending title, index and relative time (min/sec)
// 11 = reserved

// ATTI runtime reporting state.
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
reg play_title_pending_rsp;
reg [6:0] play_title_pending_track;
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
reg [2:0] gframes; // 0-6 gap frames

reg [15:0] fdata;
reg [63:0] fd;

reg [7:0] seek_count;
reg [7:0] dsa_volume;
wire aud_busy = (old_aud_rd3) || (old_aud_rd2) || (old_aud_rd) || (aud_rd) || (!audwaitl);
reg [18:0] taud_add;
reg [29:8] taud2_add;
reg [23:4] taud3_add;
reg [5:0] subtseconds; // 0-59
reg [5:0] subtrseconds; // 0-59
reg [15:0] last_ds;
reg [31:0] seek_delay;
reg [31:0] seek_delay_set;
reg seek_skip_cbusy_wait;
reg seek_found_pending;
reg [19:0] seek_src_abs;
reg [19:0] seek_dst_abs;
reg [20:0] seek_delta_abs;
reg [19:0] seek_mid_abs;
reg [7:0] dsa_last_error;
reg title_len_pending;
reg dsa_delay_pending;
reg [31:0] dsa_delay_ctr;
reg dsa_spinup_wait_toc;
reg [7:0] dsa_spinup_session;
reg dsa_long_toc_active;
reg [6:0] dsa_long_toc_first_track;
reg [6:0] dsa_long_toc_last_track;
reg toc_ready;

localparam [31:0] DSA_DELAY_PLAY_TITLE = 32'd21272000;  // 200 ms
localparam [31:0] DSA_DELAY_STOP_INNER = 32'd79770000;  // 750 ms
localparam [31:0] DSA_DELAY_STOP_MID   = 32'd159540000; // 1500 ms
localparam [31:0] DSA_DELAY_STOP_OUTER = 32'd239310000; // 2250 ms
localparam [31:0] DSA_DELAY_PAUSE      = 32'd7977000;   // 75 ms
localparam [31:0] DSA_DELAY_UNPAUSE    = 32'd13295000;  // 125 ms
localparam [31:0] DSA_DELAY_SPIN_UP    = 32'd319080000; // 3000 ms
localparam [31:0] DSA_DELAY_SCAN_GOTO  = 32'd3190800;   // 30 ms (interactive VLM scan)
localparam integer DSA_MAX_SESSIONS    = 100;
localparam [7:0]  DSA_SERVO_VERSION    = 8'h01;
localparam [7:0]  DSA_ERR_NONE         = 8'h00;
localparam [7:0]  DSA_ERR_FOCUS_NO_DISC= 8'h02;
localparam [7:0]  DSA_ERR_TOC_STALE    = 8'h08;
localparam [7:0]  DSA_ERR_ILLEGAL_CMD  = 8'h22;
localparam [7:0]  DSA_ERR_ILLEGAL_VALUE= 8'h29;

// CD-DA/CD-ROM frame time is mm:ss:ff with 75 frames/sec.
function [19:0] msf_to_frames;
	input [6:0] mins;
	input [5:0] secs;
	input [6:0] frms;
	reg [19:0] mins_frames;
	reg [19:0] secs_frames;
begin
	// mins * 4500 = mins * (4096 + 256 + 128 + 16 + 4)
	mins_frames = {mins,12'h000} + {mins,8'h00} + {mins,7'h00} + {mins,4'h0} + {mins,2'h0};
	// secs * 75 = secs * (64 + 8 + 2 + 1)
	secs_frames = {secs,6'h00} + {secs,3'h0} + {secs,1'b0} + {14'h0000,secs};
	msf_to_frames = mins_frames + secs_frames + {13'h0000,frms};
end
endfunction

function [15:0] msf_to_seconds;
	input [6:0] mins;
	input [5:0] secs;
	input [6:0] frms;
	reg [15:0] mins_secs;
begin
	// mins * 60 = mins * (64 - 4)
	mins_secs = {mins,6'h00} - {mins,2'h0};
	// DSA title length is integer seconds. Round frame component to nearest second.
	msf_to_seconds = mins_secs + {10'h000,secs} + {15'h0000,(frms >= 7'd38)};
end
endfunction

function [23:0] msf_sub_small_gap;
	input [23:0] start_msf;
	input [15:0] gap_msf;
	reg [7:0] mins;
	reg [7:0] secs;
	reg [7:0] frms;
begin
	mins = start_msf[23:16];
	secs = start_msf[15:8];
	frms = start_msf[7:0];

	if (frms < gap_msf[7:0]) begin
		frms = frms + 8'h4B - gap_msf[7:0];
		if (secs == 8'h00) begin
			secs = 8'h3B;
			mins = mins - 8'h1;
		end else begin
			secs = secs - 8'h1;
		end
	end else begin
		frms = frms - gap_msf[7:0];
	end

	if (secs < gap_msf[15:8]) begin
		secs = secs + 8'h3C - gap_msf[15:8];
		mins = mins - 8'h1;
	end else begin
		secs = secs - gap_msf[15:8];
	end

	msf_sub_small_gap = {mins, secs, frms};
end
endfunction

function [31:0] seek_delay_cycles;
	input [20:0] delta_frames;
	input [19:0] mid_frames;
	input speed_2x;
	reg [20:0] eff_delta;
	reg [31:0] seek_cycles;
begin
	// Position-aware distance scaling:
	// near inner radius, same LBA delta is a larger radial move than outer radius.
	eff_delta = delta_frames;
	if (mid_frames < 20'd120000) begin
		eff_delta = {delta_frames[19:0],1'b0}; // *2
	end else if (mid_frames >= 20'd240000) begin
		eff_delta = delta_frames >> 1;         // /2
	end

	// Seek timing model derived from Atari CD-ROM latency table.
	// Values are tuned to a realistic profile (~25% under worst-case).
	if (eff_delta < 21'd4500) begin
		// Short seek within 1-minute span:
		// 1st 37 minutes: 250 ms -> 188 ms
		// 2nd 37 minutes: 375 ms -> 281 ms
		seek_cycles = (mid_frames < 20'd166500) ? 32'd19995680 : 32'd29887160;
	end else if (eff_delta < 21'd90000) begin
		seek_cycles = 32'd39885000;    // 375 ms (0..20 min)
	end else if (eff_delta < 21'd180000) begin
		seek_cycles = 32'd49989200;    // 470 ms (21..40 min)
	end else if (eff_delta < 21'd270000) begin
		seek_cycles = 32'd59774320;    // 562 ms (41..60 min)
	end else if (eff_delta < 21'd315000) begin
		seek_cycles = 32'd79770000;    // 750 ms (61..74 min)
	end else begin
		seek_cycles = 32'd119655000;   // 1125 ms (long 0..74 min)
	end

	// 1x mode has higher rotational latency; add a fixed penalty.
	if (!speed_2x) begin
		seek_cycles = seek_cycles + 32'd8508800; // +80 ms
	end
	seek_delay_cycles = seek_cycles;
end
endfunction

function [31:0] stop_delay_cycles;
	input [19:0] mid_frames;
begin
	// Stop + park head:
	// base 1s with radial adders (middle +1s, outer +2s), scaled by ~0.75.
	if (mid_frames < 20'd120000) begin
		stop_delay_cycles = DSA_DELAY_STOP_INNER;
	end else if (mid_frames < 20'd240000) begin
		stop_delay_cycles = DSA_DELAY_STOP_MID;
	end else begin
		stop_delay_cycles = DSA_DELAY_STOP_OUTER;
	end
end
endfunction

wire [19:0] cur_abs_frames = msf_to_frames(cur_aminutes, cur_aseconds, cur_aframes);
wire [19:0] cur_rel_frames_abs = msf_to_frames(cur_minutes, cur_seconds, cur_frames);
wire [19:0] seek_cmd_abs_frames = msf_to_frames(sminutes, sseconds, sframes);
wire [19:0] seek_cmd_abs_frames_next = msf_to_frames(sminutes, sseconds, din[6:0]);
wire [19:0] goto_cmd_abs_frames_next = msf_to_frames(goto_minutes, goto_seconds, din[6:0]);
wire [19:0] ab_stop_abs_frames = msf_to_frames(abbminutes, abbseconds, abbframes);
wire [19:0] subq_track_start_frames = msf_to_frames(cues_dout[23:16], cues_dout[15:8], cues_dout[6:0]);
wire [19:0] subq_track_pregap_frames = msf_to_frames(cuep_dout[23:16], cuep_dout[15:8], cuep_dout[6:0]);
wire [19:0] subq_disc_leadout_frames = msf_to_frames(
	dsa_sess_leadout[dsa_last_sess_idx][23:16],
	dsa_sess_leadout[dsa_last_sess_idx][15:8],
	dsa_sess_leadout[dsa_last_sess_idx][6:0]
);
wire subq_leadout = dsa_disc_ready &&
	(subq_disc_leadout_frames != 20'h0) &&
	(cur_abs_frames >= subq_disc_leadout_frames);
wire subq_program = dsa_disc_ready && !subq_leadout && (cur_abs_frames >= subq_track_start_frames);
wire subq_pregap = dsa_disc_ready && !subq_leadout && !subq_program &&
	(cur_abs_frames >= subq_track_pregap_frames);
assign subq_tno = subq_leadout ? 8'hAA :
	((subq_program || subq_pregap) ? bcd[atrack_safe] : 8'h00);
assign subq_index = subq_program ? 8'h01 : 8'h00;
wire [7:0] atti_cur_index = subq_index;
wire [7:0] atti_cur_title = subq_leadout ? 8'hAA : {1'b0,track_idx};
wire [19:0] track_len_frames = msf_to_frames(cuel_dout[23:16], cuel_dout[15:8], cuel_dout[6:0]);
wire [19:0] search_border_stop_frames = (track_len_frames > 20'd375) ? (track_len_frames - 20'd375) : 20'h0;
wire [19:0] search_step_frames = search_fast ? 20'd600 : 20'd150;
wire [19:0] dsa_cmd_search_step_frames = din[0] ? 20'd600 : 20'd150;
wire [6:0] seek_scan_start_track = (num_tracks != 7'h0) ? num_tracks : 7'h1;
wire goto_target_past_leadout =
	(subq_disc_leadout_frames != 20'h0) &&
	(goto_cmd_abs_frames_next >= subq_disc_leadout_frames);
wire track_is_data = cdrommd && (dat_track != 7'h0) && (track_idx >= dat_track);
wire search_forward_border_hit =
	search_borderflag &&
	((cur_rel_frames_abs + search_step_frames) >= search_border_stop_frames);
wire search_backward_border_hit =
	search_borderflag &&
	(cur_rel_frames_abs <= search_step_frames);
wire dsa_cmd_search_forward_border_hit =
	din[1] &&
	((cur_rel_frames_abs + dsa_cmd_search_step_frames) >= search_border_stop_frames);
wire dsa_cmd_search_backward_border_hit =
	din[1] &&
	(cur_rel_frames_abs <= dsa_cmd_search_step_frames);
wire [7:0] dsa_presence_error = (!cd_ex) ? DSA_ERR_FOCUS_NO_DISC : DSA_ERR_TOC_STALE;
wire dsa_disc_present = cd_ex;
wire dsa_disc_ready = dsa_disc_present && toc_ready;
// Emulated image media defaults:
// bit4=1 finalized, bit3=0 normal reflectance (not RW), bit2=1 12cm disc.
// bit0 reports TOC-read readiness.
wire [4:0] dsa_disc_status = dsa_disc_present ? (5'b10100 | {4'b0000, dsa_disc_ready}) : 5'b00000;
wire [7:0] dsa_last_sess_idx = ((dsa_session_count != 8'h00) && (dsa_session_count <= 8'd100)) ? (dsa_session_count - 8'h1) : 8'h00;
wire [7:0] dsa_disc_id0 = {1'b0, num_tracks[6:0]};
wire [7:0] dsa_disc_id1 = {1'b0, aud_tracks[6:0]};
wire [7:0] dsa_disc_id2 = {1'b0, dat_track[6:0]};
wire [7:0] dsa_disc_id3 = {1'b0, dsa_session_count[6:0]};
wire [7:0] dsa_disc_id4 = dsa_sess_leadout[dsa_last_sess_idx][23:16] ^ dsa_sess_leadout[dsa_last_sess_idx][15:8] ^ dsa_sess_leadout[dsa_last_sess_idx][7:0] ^ {1'b0, num_tracks[6:0]};
wire [7:0] dsa_long_toc_ctrl_addr = ((dat_track != 7'h0) && (cues_add >= dat_track)) ? 8'h41 : 8'h01;
wire dsa_dac_mode_valid =
	(din[7:0] <= 8'h09) ||
	(din[7:0] == 8'h81) ||
	(din[7:0] == 8'h82);

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
reg [4:0] search_div;
reg dsa_service_mode;
reg dsa_sledge_out;
reg dsa_focus_on;
reg dsa_spindle_on;
reg dsa_radial_on;
reg dsa_laser_on;
reg dsa_high_gain;
reg [7:0] dsa_diag_last;
reg [15:0] dsa_jump_grooves;
reg abplay;
reg [7:0] abseek;
reg [6:0] abaframes; // 0-74  // (msf % 75)
reg [5:0] abaseconds; // 0-59 // (msf / 75) % 60
reg [6:0] abaminutes; // 0-99 // (msf / 75) / 60
reg [6:0] abbframes; // 0-74  // (msf % 75)
reg [5:0] abbseconds; // 0-59 // (msf / 75) % 60
reg [6:0] abbminutes; // 0-99 // (msf / 75) / 60
reg [23:0] cueptemp;
reg [23:16] cuestoptemp;
reg tocsess1;

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
reg [29:0] cueb [0:127];
// Disc metadata is now delivered as one direct per-track record. The cue BRAMs
// remain because the playback/search logic already consumes them well, but the
// mount-time path no longer relies on the legacy packed TOC word stream.
reg [7:0] dsa_sess_count_toc;
reg [6:0] dsa_sess_first_track [0:DSA_MAX_SESSIONS-1];
reg [6:0] dsa_sess_last_track [0:DSA_MAX_SESSIONS-1];
reg [23:0] dsa_sess_leadout [0:DSA_MAX_SESSIONS-1];
reg dsa_sess_valid [0:DSA_MAX_SESSIONS-1];
integer dsa_sess_i;
// Once metadata has been reconstructed, the session map built from the per-track
// records is authoritative. Before that, report no sessions and force callers to
// observe the TOC-not-ready path instead of silently falling back to "1 session".
wire [7:0] dsa_session_count = dsa_sess_count_toc;

initial begin
	cue_tracks <= 7'd0;
	aud_tracks <= 7'd0;
	dat_tracks <= 7'd0;
	dat_track <= 7'd0;
	dsa_volume <= 8'hFF;
	dsa_service_mode <= 1'b0;
	dsa_sledge_out <= 1'b0;
	dsa_focus_on <= 1'b0;
	dsa_spindle_on <= 1'b0;
	dsa_radial_on <= 1'b0;
	dsa_laser_on <= 1'b0;
	dsa_high_gain <= 1'b0;
	dsa_diag_last <= 8'h0;
	dsa_jump_grooves <= 16'h0000;
	dsa_sess_count_toc <= 8'h0;
	dsa_spinup_wait_toc <= 1'b0;
	dsa_spinup_session <= 8'h00;
	for (dsa_sess_i = 0; dsa_sess_i < DSA_MAX_SESSIONS; dsa_sess_i = dsa_sess_i + 1) begin
		dsa_sess_first_track[dsa_sess_i] <= 7'h0;
		dsa_sess_last_track[dsa_sess_i] <= 7'h0;
		dsa_sess_leadout[dsa_sess_i] <= 24'h0;
		dsa_sess_valid[dsa_sess_i] <= 1'b0;
	end
	toc_ready <= 1'b0;
	dsa_long_toc_active <= 1'b0;
	dsa_long_toc_first_track <= 7'h0;
	dsa_long_toc_last_track <= 7'h0;
end
reg [23:0] cuestop [0:1];
initial begin
	cuestop[1'h0] <= 24'h0;
	cuestop[1'h1] <= 24'h0;
end
// aud_sess is a user menu override for "force audio session":
// 0 = normal Jaguar behavior (commands are constrained to session 0),
// 1 = allow explicit session argument from DSA command byte (din[7:0]).
wire [7:0] dsa_req_session = aud_sess ? din[7:0] : 8'h00;
wire [7:0] dsa_spin_req_session = aud_sess ? din[7:0] : 8'h00;
wire dsa_req_sess_valid = dsa_sess_valid[dsa_req_session];
wire [6:0] dsa_req_first_track = dsa_sess_valid[dsa_req_session] ? dsa_sess_first_track[dsa_req_session] : 7'h0;
wire [6:0] dsa_req_last_track = dsa_sess_valid[dsa_req_session] ? dsa_sess_last_track[dsa_req_session] : 7'h0;
wire [23:0] dsa_req_leadout = dsa_sess_valid[dsa_req_session] ? dsa_sess_leadout[dsa_req_session] : 24'h0;
wire [7:0] dsa_max_session_rsp = force_music_cd ? 8'h01 :
	((dsa_session_count != 8'h00) ? dsa_session_count : 8'h01);
wire dsa_cmd_known =
	(din[15:8] == 8'h01) ||
	(din[15:8] == 8'h02) ||
	(din[15:8] == 8'h03) ||
	(din[15:8] == 8'h04) ||
	(din[15:8] == 8'h05) ||
	(din[15:8] == 8'h06) ||
	(din[15:8] == 8'h07) ||
	(din[15:8] == 8'h08) ||
	(din[15:8] == 8'h09) ||
	(din[15:8] == 8'h0A) ||
	(din[15:8] == 8'h0B) ||
	(din[15:8] == 8'h0C) ||
	(din[15:8] == 8'h0D) ||
	(din[15:8] == 8'h10) ||
	(din[15:8] == 8'h11) ||
	(din[15:8] == 8'h12) ||
	(din[15:8] == 8'h14) ||
	(din[15:8] == 8'h15) ||
	(din[15:8] == 8'h16) ||
	(din[15:8] == 8'h17) ||
	(din[15:8] == 8'h18) ||
	(din[15:8] == 8'h20) ||
	(din[15:8] == 8'h21) ||
	(din[15:8] == 8'h22) ||
	(din[15:8] == 8'h23) ||
	(din[15:8] == 8'h24) ||
	(din[15:8] == 8'h25) ||
	(din[15:8] == 8'h26) ||
	(din[15:8] == 8'h30) ||
	((din[15:8] >= 8'h40) && (din[15:8] <= 8'h44)) ||
	(din[15:8] == 8'h50) ||
	(din[15:8] == 8'h51) ||
	(din[15:8] == 8'h52) ||
	(din[15:8] == 8'h54) ||
	(din[15:8] == 8'h6A) ||
	(din[15:8] == 8'h70) ||
	(din[15:8] == 8'hF0) ||
	((din[15:8] >= 8'hF1) && (din[15:8] <= 8'hF9));
assign dbg_cue_tracks = cue_tracks;
assign dbg_aud_tracks = aud_tracks;
assign dbg_dat_track = dat_track;
assign dbg_dsa_sessions = dsa_session_count;
assign dbg_sess1_valid = dsa_sess_valid[8'h01];
assign dbg_last_ds = last_ds;
assign dbg_last_err = dsa_last_error;
assign dbg_track_idx = track_idx;
assign dbg_cues_addr = cues_addr;
assign dbg_cuet_addr = cuet_addr;

reg [15:0] dbg_resp_54_r;
reg [39:0] dbg_toc0_r;
reg [39:0] dbg_toc1_r;
reg [15:0] dbg_spin_r;
reg [15:0] dbg_ltoc0_r;
reg [15:0] dbg_ltoc1_r;

assign dbg_resp_54 = dbg_resp_54_r;
assign dbg_toc0 = dbg_toc0_r;
assign dbg_toc1 = dbg_toc1_r;
assign dbg_spin = dbg_spin_r;
assign dbg_ltoc0 = dbg_ltoc0_r;
assign dbg_ltoc1 = dbg_ltoc1_r;
assign dbg_toc_ready = toc_ready;
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
		rseconds <= {1'b0, cur_rseconds};
		rminutes <= cur_rminutes;
		aframes <= cur_aframes;
		aseconds <= {1'b0, cur_aseconds};
		aminutes <= cur_aminutes;
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

reg pastcdbios;

always @(posedge sys_clk)
begin
	aud_adds[29:0] <= aud_add[29:0] + cuet_dout[29:0]; // old_aud_rd will delay one cycle to match aud_adds delay
	cuelast[23:0] <= {carrys?cuel_dout[23:16]-8'h1:cuel_dout[23:16],carrys?8'h3B:carryf?cuel_dout[15:8]-8'h1:cuel_dout[15:8],carryf?8'h4A:cuel_dout[7:0]-8'h1};
	atrack <= track_idx;
	recrc <= 1'b0;
	updresp <= 1'b0;
	updrespa <= 1'b0;
	aud_rd <= 1'b0;
	old_doe_ds <= doe_ds;
	old_doe_dsc <= doe_dsc;
	old_doe_sub <= doe_sub;
	old_doe_sbcntrl <= doe_sbcntrl;
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
	if (dsa_delay_pending) begin
		if (!cd_latency_en) begin
			dsa_delay_pending <= 1'b0;
			dsa_delay_ctr <= 32'h0;
			// Some commands stage completion after an additional state transition
			// (e.g. PLAY TITLE/GOTO FOUND). Don't assert RBUF-ready early.
			if (!play_title_pending_rsp && !seek_found_pending && !dsa_spinup_wait_toc) begin
				butch_reg[0][13] <= 1'b1;
			end
		end else if (dsa_delay_ctr > 32'h1) begin
			dsa_delay_ctr <= dsa_delay_ctr - 32'h1;
		end else begin
			dsa_delay_pending <= 1'b0;
			dsa_delay_ctr <= 32'h0;
			// Some commands stage completion after an additional state transition
			// (e.g. PLAY TITLE/GOTO FOUND). Don't assert RBUF-ready early.
			if (!play_title_pending_rsp && !seek_found_pending && !dsa_spinup_wait_toc) begin
				butch_reg[0][13] <= 1'b1;
			end
		end
	end

	// If Spin Up is requested before TOC/session metadata is fully ingested,
	// keep the drive busy and only complete after toc_ready is asserted.
	if (dsa_spinup_wait_toc) begin
		butch_reg[0][13] <= 1'b0;
		if (!cd_ex) begin
			dsa_spinup_wait_toc <= 1'b0;
			dsa_delay_pending <= 1'b0;
			dsa_delay_ctr <= 32'h0;
			dsa_last_error <= DSA_ERR_FOCUS_NO_DISC;
			ds_resp[0] <= 32'h0400 | DSA_ERR_FOCUS_NO_DISC;
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
			butch_reg[0][13] <= 1'b1;
		end else if (toc_ready) begin
			dsa_spinup_wait_toc <= 1'b0;
			dsa_last_error <= DSA_ERR_NONE;
			ds_resp[0] <= 32'h0100 | 32'h0043;
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
			mounted <= 1'b1;
			spinpause <= 1'b1;
			if (mounted) begin
				spinpause <= 1'b0;
			end
			splay <= 5'h15;
			stop <= 1'b0;
			aud_add <= 30'h0;
			if (dsa_sess_valid[dsa_spinup_session] && (dsa_sess_first_track[dsa_spinup_session] != 7'h00)) begin
				track_idx <= dsa_sess_first_track[dsa_spinup_session];
				dbg_spin_r <= {
					1'b1,
					dsa_sess_first_track[dsa_spinup_session],
					dsa_spinup_session
				};
			end else begin
				track_idx <= 7'h1;
				dbg_spin_r <= {
					1'b1,
					7'h01,
					dsa_spinup_session
				};
			end
			cur_samples <= 10'h0;
			cur_rframes <= 7'h0;
			cur_rseconds <= 6'h2;
			cur_rminutes <= 7'h0;
			gframes <= 3'h0;
			if (dsa_sess_valid[dsa_spinup_session] && (dsa_sess_first_track[dsa_spinup_session] != 7'h00)) begin
				cues_addr <= dsa_sess_first_track[dsa_spinup_session];
				cuet_addr <= dsa_sess_first_track[dsa_spinup_session];
			end else begin
				cues_addr <= 7'h1;
				cuet_addr <= 7'h1;
			end
			updabs_req <= 1'b1;
			if (cd_latency_en) begin
				dsa_delay_pending <= 1'b1;
				dsa_delay_ctr <= DSA_DELAY_SPIN_UP;
			end else begin
				butch_reg[0][13] <= 1'b1;
			end
		end
	end

	if (title_len_pending) begin
		title_len_pending <= 1'b0;
		butch_reg[0][12] <= 1'b1;
		butch_reg[0][13] <= 1'b1;
		ds_resp[0] <= 32'h0900 | (msf_to_seconds(cuel_dout[23:16], cuel_dout[15:8], cuel_dout[6:0]) & 16'h00FF);
		ds_resp[1] <= 32'h0A00 | ((msf_to_seconds(cuel_dout[23:16], cuel_dout[15:8], cuel_dout[6:0]) >> 8) & 16'h00FF);
		ds_resp_idx <= 3'h0;
		ds_resp_size <= 3'h2;
		ds_resp_loop <= 7'h0;
	end

	cues_wrr_next <= 0;
	cuep_wrr_next <= 0;
	cuel_wrr_next <= 0;
	cuet_wrr_next <= 0;
	cues_wrr <= cues_wrr_next;
	cuep_wrr <= cuep_wrr_next;
	cuel_wrr <= cuel_wrr_next;
	cuet_wrr <= cuet_wrr_next;
	if (toc_wr && (toc_addr == 10'h008)) begin
		toc_ready <= 1'b0;
		dsa_long_toc_active <= 1'b0;
		dsa_sess_count_toc <= 8'h0;
		cue_tracks <= 7'h0;
		aud_tracks <= 7'h0;
		dat_tracks <= 7'h0;
		dat_track <= 7'h0;
		dbg_toc0_r <= 40'h0;
		dbg_toc1_r <= 40'h0;
		dbg_spin_r <= 16'h0000;
		dbg_ltoc0_r <= 16'h0000;
		dbg_ltoc1_r <= 16'h0000;
		track_idx <= 7'h1;
		atrack <= 7'h1;
		cues_addr <= 7'h1;
		cuet_addr <= 7'h1;
		play <= 1'b0;
		stop <= 1'b0;
		pause <= 1'b0;
		spinpause <= 1'b0;
		splay <= 5'h0;
		seek <= 8'h0;
		seek_found_pending <= 1'b0;
		updabs_req <= 1'b0;
		search_forward <= 1'b0;
		search_backward <= 1'b0;
		search_fast <= 1'b0;
		search_borderflag <= 1'b0;
		play_title_pending_rsp <= 1'b0;
		leadout_title_pending <= 1'b0;
		leadout_seen <= 1'b0;
		atti_report_valid <= 1'b0;
		atti_evt_title_pending <= 1'b0;
		atti_evt_index_pending <= 1'b0;
		atti_evt_rel_minutes_pending <= 1'b0;
		atti_evt_rel_seconds_pending <= 1'b0;
		atti_evt_abs_minutes_pending <= 1'b0;
		atti_evt_abs_seconds_pending <= 1'b0;
		frame_irq_pending <= 1'b0;
		subcode_irq_pending <= 1'b0;
		// Present first emitted chunk as 0x10 to match legacy GPU/VLM handlers.
		sub_chunk_count <= 8'h0F;
		for (dsa_sess_i = 0; dsa_sess_i < DSA_MAX_SESSIONS; dsa_sess_i = dsa_sess_i + 1) begin
			dsa_sess_first_track[dsa_sess_i] <= 7'h0;
			dsa_sess_last_track[dsa_sess_i] <= 7'h0;
			dsa_sess_leadout[dsa_sess_i] <= 24'h0;
			dsa_sess_valid[dsa_sess_i] <= 1'b0;
		end
	end
	if (toc_wr) begin
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
			cues_wrr_next <= 1'b1;
		end
		if (toc_addr[2:0] == 3'h2) begin
			cuel_dinv[15:0] <= toc_data[15:0];
			cuel_wrr_next <= 1'b1;
		end
		if (toc_addr[2:0] == 3'h3) begin
			cueptemp[7:0] <= cueptemp[7:0] - toc_data[7:0];
			cueptemp[14:8] <= cueptemp[14:8] - toc_data[14:8];
		end
		if (toc_addr[2:0] == 3'h4) begin
			cuet_dinv[31:24] <= toc_data[7:0];
			tocsess1 <= 1'b1;
			if (toc_data[15:9] == 0) begin
				aud_tracks <= toc_addr[9:3];
				tocsess1 <= 1'b0;
			end
			cue_tracks <= toc_addr[9:3];
			if (toc_data[15:9] < DSA_MAX_SESSIONS) begin
				if (!dsa_sess_valid[toc_data[15:9]]) begin
					dsa_sess_first_track[toc_data[15:9]] <= toc_addr[9:3];
				end
				dsa_sess_valid[toc_data[15:9]] <= 1'b1;
				if ((toc_data[15:9] + 8'h1) > dsa_sess_count_toc) begin
					dsa_sess_count_toc <= toc_data[15:9] + 8'h1;
				end
			end
			if (cueptemp[7]) begin
				cueptemp[7:0] <= cueptemp[7:0] + 8'h4B;
				cueptemp[14:8] <= cueptemp[14:8] - 7'h1;
			end
		end
		if (toc_addr[2:0] == 3'h5) begin
			cuet_dinv[23:8] <= toc_data[15:0];
			dat_tracks <= cue_tracks - aud_tracks;
			dat_track <= aud_tracks + 7'h1;
			if (cueptemp[14]) begin
				cueptemp[14:8] <= cueptemp[14:8] + 7'h3C;
				cueptemp[23:16] <= cueptemp[23:16] - 8'h1;
			end
		end
		if (toc_addr[2:0] == 3'h6) begin
			cuestoptemp[23:16] <= toc_data[7:0];
			cuet_dinv[7:0] <= toc_data[15:8];
			cuep_dinv <= cueptemp;
			cuet_wrr_next <= 1'b1;
			cuep_wrr_next <= 1'b1;
		end
		if (toc_addr[2:0] == 3'h7) begin
			if (cuestoptemp[23:16] != 8'h00 || toc_data[15:0] != 16'h0000) begin
				cuestop[tocsess1][23:16] <= cuestoptemp[23:16];
				cuestop[tocsess1][15:0] <= toc_data[15:0];
				toc_ready <= 1'b1;
				dsa_sess_last_track[tocsess1] <= toc_addr[9:3];
				dsa_sess_leadout[tocsess1] <= {cuestoptemp[23:16], toc_data[15:0]};
			end
		end
	end
	// `cues_dout` is synchronous RAM output; stage absolute-time updates one cycle
	// after changing `cues_addr` to avoid latching stale track starts.
	if (updabs_req) begin
		updabs_req <= 1'b0;
		updabs <= 1'b1;
	end
	if (updabs) begin // Everything below here should be reset when resetl is low
		updabs <= 1'b0;
		cur_aframes <= cues_dout[6:0];
		cur_aseconds <= cues_dout[13:8];
		cur_aminutes <= cues_dout[22:16];
	end
	if (play_title_pending_rsp &&
		!updabs &&
		(ds_resp_size == 3'h0) &&
		!dsa_delay_pending &&
		!dsa_spinup_wait_toc &&
		!ds_a) begin
		butch_reg[0][12] <= 1'b1;
		butch_reg[0][13] <= 1'b1;
		if (attiabs) begin
			ds_resp[0] <= 32'h1000 | play_title_pending_track;
			ds_resp[1] <= 32'h1100 | 8'h01;
			ds_resp[2] <= 32'h1400 | cues_dout[22:16];
			ds_resp[3] <= 32'h1500 | cues_dout[13:8];
			ds_resp[4] <= 32'h0100;
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h5;
			ds_resp_loop <= 7'h0;
			atti_report_valid <= 1'b1;
			atti_last_title <= {1'b0,play_title_pending_track};
			atti_last_index <= 8'h01;
			atti_last_abs_minutes <= cues_dout[22:16];
			atti_last_abs_seconds <= cues_dout[13:8];
			atti_last_rel_minutes <= cur_rminutes[6:0];
			atti_last_rel_seconds <= cur_rseconds[5:0];
		end else if (attirel) begin
			ds_resp[0] <= 32'h1000 | play_title_pending_track;
			ds_resp[1] <= 32'h1100 | 8'h01;
			ds_resp[2] <= 32'h1200 | cur_rminutes[6:0];
			ds_resp[3] <= 32'h1300 | cur_rseconds[5:0];
			ds_resp[4] <= 32'h0100;
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h5;
			ds_resp_loop <= 7'h0;
			atti_report_valid <= 1'b1;
			atti_last_title <= {1'b0,play_title_pending_track};
			atti_last_index <= 8'h01;
			atti_last_abs_minutes <= cues_dout[22:16];
			atti_last_abs_seconds <= cues_dout[13:8];
			atti_last_rel_minutes <= cur_rminutes[6:0];
			atti_last_rel_seconds <= cur_rseconds[5:0];
		end else begin
			// No-ATTI mode expects a plain FOUND completion without title payload.
			ds_resp[0] <= 32'h0100;
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
			atti_report_valid <= 1'b0;
		end
		play_title_pending_rsp <= 1'b0;
	end
	if (seek != 8'h0) begin
		if (seek[7]) begin       // Loop looking for cues_addr starting at last one
			seek[0] <= !seek[0];  // These two settings do alternate between updating cues_addr and using it
			seek[1] <= seek[0];
			if (!seek[1]) begin   // Check if cues_addr is before/after seek time
				if ((cues_addr <= 7'h1) || ({sminutes,2'b00,sseconds,1'b0,sframes} >= (cuep_dout[22:0]))) begin // fix this
					seek <= 8'h7F;
					track_idx <= cues_addr_clamped;
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
					// Never step seek scan into track slot 0.
					cues_addr <= (cues_addr > 7'h1) ? (cues_addr - 7'h1) : 7'h1;
					cuet_addr <= (cues_addr > 7'h1) ? (cues_addr - 7'h1) : 7'h1;
					seek[1:0] <= 2'b11;
				end
			end
		end else if (seek[6]) begin
			if (seek[0]) begin   // Using seek0 to delay one cycle. necessary?
				seek[0] <= 1'b0;
				// Clamp boundary math to avoid transient boundary artifacts
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
			seek[1] <= 1'b0;
			taud2_add[29:8] <= {taud_add[18:0],3'h0} + {taud_add[18:0]};
			taud3_add[23:4] <= {taud_add[18:0],1'h0} + {taud_add[18:0]};
			seek_delay <= seek_delay_set;
		end else if (seek[0]) begin
			if (seek_delay != 0) begin
				seek_delay <= seek_delay - 16'h1;
				if (seek_delay == seek_delay_set) begin
					aud_add[29:0] <= {{taud2_add[29:8],4'h0} + {taud3_add[23:4]},4'h0};//[31:30] are always 0
					aud_rd <= 1'b1;
				end else if ((seek_delay == 31'h1) && (aud_cbusy) && !seek_skip_cbusy_wait) begin
					seek_delay <= 31'h1;
				end else if (seek_delay == 31'h1) begin
					seek[0] <= 1'b0;
					seek_skip_cbusy_wait <= 1'b0;
					// *2352=<<11 + <<8 + <<5 + <<4
					cur_samples <= 10'h0;
					// Seek landed at a new logical position. Re-prime subcode stream
					// from chunk 0x10 and recompute CRC from the new Q payload now.
					sub_chunk_count <= 8'h0F;
					subidx <= 4'h0;
					recrc <= 1'b1;
					// Only arm transport start when seek completes from an active
					// playback context. Positioning seeks (e.g. VLM init/STOP-time
					// GOTO updates) must not restart audio.
					if (((play || search_forward || search_backward || abplay) && !pause && !spinpause) ||
					    play_title_pending_rsp) begin
						splay <= 5'h5;
						splay[4] <= i2s_jerry || i2s_fifo_enabled;
						stop <= 1'b0;
					end else begin
						splay <= 5'h0;
						play <= 1'b0;
					end
					upd_frames <= 1'b1;
//					ds_resp[0] <= 32'h0140; // dsa says 0x140; code is looking for 0x100
					if (!dsa_cmd_stop_wr && (abseek != 8'h0)) begin
						ds_resp[0] <= 32'h0144;
						ds_resp_idx <= 3'h0;
						ds_resp_size <= 3'h1;
						ds_resp_loop <= 7'h0;
						butch_reg[0][13] <= 1'b1; // response word ready
						atti_report_valid <= 1'b0;
						abseek <= 8'h0;
					end else if (!dsa_cmd_stop_wr && seek_found_pending &&
						(play || search_forward || search_backward || abplay || play_title_pending_rsp)) begin
						ds_resp[0] <= 32'h0100;
						ds_resp_idx <= 3'h0;
						ds_resp_size <= 3'h1;
						ds_resp_loop <= 7'h0;
						butch_reg[0][13] <= 1'b1; // response word ready
						seek_found_pending <= 1'b0;
						atti_evt_title_pending <= 1'b0;
						atti_evt_index_pending <= 1'b0;
						atti_evt_rel_minutes_pending <= 1'b0;
						atti_evt_rel_seconds_pending <= 1'b0;
						atti_evt_abs_minutes_pending <= 1'b0;
						atti_evt_abs_seconds_pending <= 1'b0;
						if (attirel || attiabs) begin
							atti_report_valid <= 1'b1;
							atti_last_title <= atti_cur_title;
							atti_last_index <= atti_cur_index;
							atti_last_abs_minutes <= cur_aminutes[6:0];
							atti_last_abs_seconds <= cur_aseconds[5:0];
							atti_last_rel_minutes <= cur_rminutes[6:0];
							atti_last_rel_seconds <= cur_rseconds[5:0];
						end else begin
							atti_report_valid <= 1'b0;
						end
					end else begin
						// SEARCH fwd/back internal seeks don't emit FOUND responses.
						butch_reg[0][13] <= 1'b0;
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
					fd <= 64'h0;
					fifo[1] <= 'h0;
					fifo[0] <= 'h0;
					if (!splay[4]) begin
						splay <= 5'h0; // Does this work? Seems like it might skip the first read when splay called again later. Where is transition to play if not here?
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
		if (play && !spinpause && (!pause || cdrommd)) begin
			if (abplay && (abseek == 8'h0) && (seek == 8'h0) && (cur_abs_frames >= ab_stop_abs_frames)) begin
				abplay <= 1'b0;
				pause <= 1'b1;
				butch_reg[0][12] <= 1'b1;
				butch_reg[0][13] <= 1'b1;
				ds_resp[0] <= 32'h0145;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			old_ws <= wsout;
			if (old_ws != wsout) begin
				if (stop != 1'b0) begin
					play <= 1'b0;
					i2s4w <= 1'b1;
					sdin4[15:0] <= 16'h0;
					if (!dsa_delay_pending) begin
						butch_reg[0][13] <= 1'b1; // |= 0x2000
					end
				end else if (seek != 8'h0) begin
					sdin[15:0] <= 16'h0;
				end else begin
					i2s1w <= !wsout;
					i2s2w <= wsout;
					if (pause_data_junk) begin
						// In data mode, pause keeps transfer active but returns nonsensical data.
						fdata[15:0] = 16'h0;
						sdin[15:0] <= 16'h0;
						if (i2s_fifo_enabled && faddr[0] == 1'b0) begin
							i2s_fifo[i2s_wfifopos[3:0]][15:0] <= 16'h0;
						end
						if (i2s_fifo_enabled && faddr[0] == 1'b1) begin
							i2s_fifo[i2s_wfifopos[3:0]][31:16] <= 16'h0;
							i2s_wfifopos <= i2s_wfifopos + 5'h1;
							if (i2s_wfifopos == (i2s_rfifopos ^ 5'h10)) begin // fifo overflow
								i2s_rfifopos <= i2s_rfifopos + 4'h1;
								overflow <= 1'b1;
							end
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
							end else if ((track_is_data && (cueb_dout != 30'h0) && ((aud_add + 30'h8) >= cueb_dout)) ||
							             ({cur_minutes,2'b00,cur_seconds,1'b0,cur_frames} >= cuelast[22:0])) begin
								aud_add <= aud_add + 4'h8;
								if ((track_is_data && (cueb_dout != 30'h0) && ((aud_add + 30'h8) >= cueb_dout)) ||
								    ({cur_minutes,2'b00,cur_seconds,1'b0,cur_frames} > cuelast[22:0])) begin
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
					end
					if (wsout && !pause_data_junk && (seek == 8'h0)) begin
						cur_samples <= cur_samples + 10'h1;
						// Subcode chunk interrupt cadence: 12 chunk interrupts per 588-sample CD frame.
						if ((cur_samples == 10'd48)  || (cur_samples == 10'd97)  ||
							(cur_samples == 10'd146) || (cur_samples == 10'd195) ||
							(cur_samples == 10'd244) || (cur_samples == 10'd293) ||
							(cur_samples == 10'd342) || (cur_samples == 10'd391) ||
							(cur_samples == 10'd440) || (cur_samples == 10'd489) ||
							(cur_samples == 10'd538) || (cur_samples == 10'd587)) begin
							subcode_irq_pending <= 1'b1;
							// Keep chunk counter in canonical 0x10..0x1B range.
							if (sub_chunk_count == 8'h1B) begin
								sub_chunk_count <= 8'h10;
								subidx <= 4'h0;
							end else begin
								sub_chunk_count <= sub_chunk_count + 8'h1;
								// Counter starts at 0x0F so first emitted chunk (0x10) maps to subidx 0.
								if (sub_chunk_count == 8'h0F) begin
									subidx <= 4'h0;
								end else begin
									subidx <= subidx + 4'h1;
								end
							end
						end
						if (cur_samples == 10'd587) begin
//							recrc <= 1'b1;
							upd_frames <= 1'b1;
							frame_irq_pending <= 1'b1;
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
							if ((search_forward || search_backward) && (seek == 8'h0) && (splay == 5'h0)) begin
								if ((search_forward && search_forward_border_hit) || (search_backward && search_backward_border_hit)) begin
									search_forward <= 1'b0;
									search_backward <= 1'b0;
									search_fast <= 1'b0;
									search_borderflag <= 1'b0;
									search_div <= 5'h0;
								end else if (search_div == (search_fast ? 5'd1 : 5'd5)) begin
									search_div <= 5'h0;
									sframes <= cur_aframes;
									if (search_forward) begin
										if (search_fast) begin
											if (cur_aseconds >= 6'd52) begin
												if (cur_aminutes == 7'd99) begin
													sminutes <= 7'd99;
													sseconds <= 6'd59;
													sframes <= 7'd74;
												end else begin
													sminutes <= cur_aminutes + 7'd1;
													sseconds <= cur_aseconds - 6'd52;
												end
											end else begin
												sminutes <= cur_aminutes;
												sseconds <= cur_aseconds + 6'd8;
											end
										end else begin
											if (cur_aseconds >= 6'd58) begin
												if (cur_aminutes == 7'd99) begin
													sminutes <= 7'd99;
													sseconds <= 6'd59;
													sframes <= 7'd74;
												end else begin
													sminutes <= cur_aminutes + 7'd1;
													sseconds <= cur_aseconds - 6'd58;
												end
											end else begin
												sminutes <= cur_aminutes;
												sseconds <= cur_aseconds + 6'd2;
											end
										end
									end else begin
										if (search_fast) begin
											if ((cur_aminutes == 7'd0) && (cur_aseconds < 6'd8)) begin
												sminutes <= 7'd0;
												sseconds <= 6'd0;
												sframes <= 7'd0;
											end else if (cur_aseconds < 6'd8) begin
												sminutes <= cur_aminutes - 7'd1;
												sseconds <= cur_aseconds + 6'd52;
											end else begin
												sminutes <= cur_aminutes;
												sseconds <= cur_aseconds - 6'd8;
											end
										end else begin
											if ((cur_aminutes == 7'd0) && (cur_aseconds < 6'd2)) begin
												sminutes <= 7'd0;
												sseconds <= 6'd0;
												sframes <= 7'd0;
											end else if (cur_aseconds < 6'd2) begin
												sminutes <= cur_aminutes - 7'd1;
												sseconds <= cur_aseconds + 6'd58;
											end else begin
												sminutes <= cur_aminutes;
												sseconds <= cur_aseconds - 6'd2;
											end
										end
									end
									cues_addr <= seek_scan_start_track;
									cuet_addr <= seek_scan_start_track;
									seek_skip_cbusy_wait <= 1'b1;
									seek_found_pending <= 1'b0;
									seek <= 8'hFF;
									abseek <= 8'h0;
									stop <= 1'b0;
									spinpause <= 1'b0;
									seek_delay_set <= cd_latency_en ? 32'd500000 : 32'd100000;
								end else begin
									search_div <= search_div + 5'h1;
								end
							end else begin
								search_div <= 5'h0;
							end
						end
					end
				end
			end
		end
	end

	if (!play || !subq_leadout) begin
		leadout_seen <= 1'b0;
	end
	if (play && !spinpause && subq_leadout && !leadout_seen) begin
		leadout_seen <= 1'b1;
		pause <= 1'b1; // Enter pause mode automatically on lead-out entry.
		leadout_title_pending <= 1'b1; // Emit explicit ACTUAL TITLE=AAh notification.
		atti_report_valid <= 1'b0;
		atti_evt_title_pending <= 1'b0;
		atti_evt_index_pending <= 1'b0;
		atti_evt_rel_minutes_pending <= 1'b0;
		atti_evt_rel_seconds_pending <= 1'b0;
		atti_evt_abs_minutes_pending <= 1'b0;
		atti_evt_abs_seconds_pending <= 1'b0;
	end

	if (cd_en && wet && ain[23:8]==24'hdfff) begin // restrict to lower 0-3f?
		if (ain[5:2]==4'h0) begin  // BUTCH ICR
			if (!ewe2l) begin
				butch_reg[4'h0][31:16] <= din[31:16];
			end
			if (!ewe0l) begin
				butch_reg[4'h0][15:8] <= butch_reg[4'h0][15:8] & ~{din[15:14],2'b00,din[11:8]};
				butch_reg[4'h0][7:0] <= din[7:0];
				if (din[10]) subcode_irq_pending <= 1'b0;
				if (din[11]) frame_irq_pending <= 1'b0;
				// interrupt control
			end
		end else if (aeven && ain[5:2] < 4'd12) begin
			butch_reg[ain[5:2]][31:0] <= din[31:0];
		end else if (ain[5:2] < 4'd12) begin
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
			dsa_spinup_wait_toc <= 1'b0;
			dsa_delay_pending <= 1'b0;
			dsa_delay_ctr <= 32'h0;
			if (din[15:8] != 8'h14) begin
				dsa_long_toc_active <= 1'b0;
			end
			if (din[15:8]==8'h01) begin  // Play Title
				unhandled <= 1'b0;
				play_title_pending_rsp <= 1'b0;
				if (!cd_ex || !toc_ready) begin
					dsa_last_error <= dsa_presence_error;
					ds_resp[0] <= 32'h0400 | dsa_presence_error;
					butch_reg[0][12] <= 1'b1;
					butch_reg[0][13] <= 1'b1;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else if (((din[6:0] == 7'h00) ? 7'h01 : din[6:0]) > num_tracks) begin
					dsa_last_error <= DSA_ERR_ILLEGAL_VALUE;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_VALUE;
					butch_reg[0][12] <= 1'b1;
					butch_reg[0][13] <= 1'b1;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					abplay <= 1'b0;
					abseek <= 8'h0;
					leadout_title_pending <= 1'b0;
					leadout_seen <= 1'b0;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					// Report completion once the play-title position has been latched.
					butch_reg[0][13] <= 1'b0;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h0;
					ds_resp_loop <= 7'h0;
					play_title_pending_rsp <= 1'b1;
					play_title_pending_track <= (din[6:0] == 7'h00) ? 7'h01 : din[6:0];
					atti_report_valid <= 1'b0;
					atti_evt_title_pending <= 1'b0;
					atti_evt_index_pending <= 1'b0;
					atti_evt_rel_minutes_pending <= 1'b0;
					atti_evt_rel_seconds_pending <= 1'b0;
					atti_evt_abs_minutes_pending <= 1'b0;
					atti_evt_abs_seconds_pending <= 1'b0;
					if (cd_latency_en) begin
						dsa_delay_pending <= 1'b1;
						dsa_delay_ctr <= DSA_DELAY_PLAY_TITLE;
					end
					spinpause <= 1'b0;
					splay <= 5'h15;
					stop <= 1'b0;
					aud_add <= 30'h0;
					track_idx <= (din[6:0] == 7'h00) ? 7'h01 : din[6:0];
					cur_samples <= 10'h0;
					cur_rframes <= 7'h0;
					cur_rseconds <= 6'h0;
					cur_rminutes <= 7'h0;
					gframes <= 3'h0;
					cues_addr <= (din[6:0] == 7'h00) ? 7'h01 : din[6:0];
					cuet_addr <= (din[6:0] == 7'h00) ? 7'h01 : din[6:0];
					updabs_req <= 1'b1;
				end
			end
			if (din[15:8]==8'h02) begin  // Stop
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				if (!cd_ex) begin
					dsa_last_error <= DSA_ERR_FOCUS_NO_DISC;
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp[0] <= 32'h0400 | DSA_ERR_FOCUS_NO_DISC;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					if (cd_latency_en) begin
						butch_reg[0][13] <= 1'b0;
						dsa_delay_pending <= 1'b1;
						dsa_delay_ctr <= stop_delay_cycles(cur_abs_frames);
					end else begin
						butch_reg[0][13] <= 1'b1; // immediate STOP completion when latency is disabled
					end
					// STOP completion is "stopped" class in existing BIOS/VLM paths.
					ds_resp[0] <= 32'h0200;
				end
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				// Quiesce transport immediately so software-visible STOP state is
				// stable without waiting for the next audio word-select edge.
				play <= 1'b0;
				stop <= 1'b0;
				splay <= 5'h0;
				seek <= 8'h0;
				seek_skip_cbusy_wait <= 1'b0;
				seek_found_pending <= 1'b0;
				abplay <= 1'b0;
				abseek <= 8'h0;
				search_forward <= 1'b0;
				search_backward <= 1'b0;
				search_fast <= 1'b0;
				search_borderflag <= 1'b0;
				search_div <= 5'h0;
				play_title_pending_rsp <= 1'b0;
				atti_report_valid <= 1'b0;
				atti_evt_title_pending <= 1'b0;
				atti_evt_index_pending <= 1'b0;
				atti_evt_rel_minutes_pending <= 1'b0;
				atti_evt_rel_seconds_pending <= 1'b0;
				atti_evt_abs_minutes_pending <= 1'b0;
				atti_evt_abs_seconds_pending <= 1'b0;
				leadout_title_pending <= 1'b0;
				leadout_seen <= 1'b0;
				pause <= 1'b0;
				spinpause <= 1'b0;
				subcode_irq_pending <= 1'b0;
				frame_irq_pending <= 1'b0;
				sub_chunk_count <= 8'h0F;
				subidx <= 4'h0;
				cur_samples <= 10'h0;
				recrc <= 1'b1;
				fd <= 64'h0;
				fifo[1] <= 64'h0;
				fifo[0] <= 64'h0;
				i2s_wfifopos <= 5'h0;
				i2s_rfifopos <= 5'h0;
				i2s1w <= 1'b1;
				i2s2w <= 1'b1;
				sdin[15:0] <= 16'h0;
				i2s4w <= 1'b1;
				sdin4[15:0] <= 16'h0;
			end
			if (din[15:8]==8'h03) begin  // Read TOC
				unhandled <= 1'b0;
				if (!cd_ex || !toc_ready) begin
					dsa_last_error <= dsa_presence_error;
					ds_resp[0] <= 32'h0400 | dsa_presence_error;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else if ((!aud_sess && (din[7:0] != 8'h00)) || (din[7:0] >= dsa_session_count) || (din[7:0] >= DSA_MAX_SESSIONS) || !dsa_req_sess_valid) begin
					dsa_last_error <= DSA_ERR_ILLEGAL_VALUE;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_VALUE;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					ds_resp[0] <= 32'h2000 | dsa_req_first_track;
					ds_resp[1] <= 32'h2100 | dsa_req_last_track;
					ds_resp[2] <= 32'h2200 | dsa_req_leadout[22:16];
					ds_resp[3] <= 32'h2300 | dsa_req_leadout[13:8];
					ds_resp[4] <= 32'h2400 | dsa_req_leadout[6:0];
					if (dsa_req_session == 8'h00) begin
						dbg_toc0_r <= {
							dsa_req_first_track,
							dsa_req_last_track,
							dsa_req_leadout
						};
					end else if (dsa_req_session == 8'h01) begin
						dbg_toc1_r <= {
							dsa_req_first_track,
							dsa_req_last_track,
							dsa_req_leadout
						};
					end
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
				if (cd_latency_en) begin
					butch_reg[0][13] <= 1'b0;
					dsa_delay_pending <= 1'b1;
					dsa_delay_ctr <= DSA_DELAY_PAUSE;
				end else begin
					butch_reg[0][13] <= 1'b1; // |= 0x2000
				end
				ds_resp[0] <= 32'h0141;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				pause <= 1'b1;
			end
			if (din[15:8]==8'h05) begin  // Pause Release
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				if (cd_latency_en) begin
					butch_reg[0][13] <= 1'b0;
					dsa_delay_pending <= 1'b1;
					dsa_delay_ctr <= DSA_DELAY_UNPAUSE;
				end else begin
					butch_reg[0][13] <= 1'b1; // |= 0x2000
				end
				ds_resp[0] <= 32'h0142;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
				pause <= 1'b0;
				spinpause <= 1'b0;
			end
			if (din[15:8]==8'h06) begin  // Search Forward
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b0; // no immediate response
				// No response
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (!cd_ex || !toc_ready) begin
					dsa_last_error <= dsa_presence_error;
					search_forward <= 1'b0;
					search_backward <= 1'b0;
					search_fast <= 1'b0;
					search_borderflag <= 1'b0;
					search_div <= 5'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					if (play && !pause && !spinpause && (seek == 8'h0) && (splay == 5'h0) && !dsa_delay_pending) begin
						if (dsa_cmd_search_forward_border_hit) begin
							search_forward <= 1'b0;
							search_backward <= 1'b0;
							search_fast <= 1'b0;
							search_borderflag <= 1'b0;
							search_div <= 5'h0;
						end else begin
							search_forward <= 1'b1;
							search_backward <= 1'b0;
							search_fast <= din[0];
							search_borderflag <= din[1];
							search_div <= 5'h0;
						end
					end else begin
						search_forward <= 1'b0;
						search_backward <= 1'b0;
						search_fast <= 1'b0;
						search_borderflag <= 1'b0;
						search_div <= 5'h0;
					end
				end
			end
			if (din[15:8]==8'h07) begin  // Search Backward
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b0; // no immediate response
				// No response
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (!cd_ex || !toc_ready) begin
					dsa_last_error <= dsa_presence_error;
					search_forward <= 1'b0;
					search_backward <= 1'b0;
					search_fast <= 1'b0;
					search_borderflag <= 1'b0;
					search_div <= 5'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					if (play && !pause && !spinpause && (seek == 8'h0) && (splay == 5'h0) && !dsa_delay_pending) begin
						if (dsa_cmd_search_backward_border_hit) begin
							search_forward <= 1'b0;
							search_backward <= 1'b0;
							search_fast <= 1'b0;
							search_borderflag <= 1'b0;
							search_div <= 5'h0;
						end else begin
							search_forward <= 1'b0;
							search_backward <= 1'b1;
							search_fast <= din[0];
							search_borderflag <= din[1];
							search_div <= 5'h0;
						end
					end else begin
						search_forward <= 1'b0;
						search_backward <= 1'b0;
						search_fast <= 1'b0;
						search_borderflag <= 1'b0;
						search_div <= 5'h0;
					end
				end
			end
			if (din[15:8]==8'h08) begin  // Search Release
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b0; // no immediate response
				// No response
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h0;
				ds_resp_loop <= 7'h0;
				dsa_last_error <= DSA_ERR_NONE;
				search_forward <= 1'b0;
				search_backward <= 1'b0;
				search_fast <= 1'b0;
				search_borderflag <= 1'b0;
				search_div <= 5'h0;
			end
			if (din[15:8]==8'h09) begin  // Get Title Length
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				if (!cd_ex || !toc_ready) begin
					dsa_last_error <= dsa_presence_error;
					seek_found_pending <= 1'b0;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | dsa_presence_error;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else if ((din[6:0] == 7'h00) || (din[6:0] > num_tracks)) begin
					dsa_last_error <= DSA_ERR_ILLEGAL_VALUE;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_VALUE;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					butch_reg[0][13] <= 1'b0;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h0;
					ds_resp_loop <= 7'h0;
					cues_addr <= din[6:0];
					title_len_pending <= 1'b1;
				end
			end
			if (din[15:8]==8'h0A) begin  // Reserved
				unhandled <= 1'b0;
				dsa_last_error <= DSA_ERR_ILLEGAL_CMD;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_CMD;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h0B) begin  // Reserved
				unhandled <= 1'b0;
				dsa_last_error <= DSA_ERR_ILLEGAL_CMD;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_CMD;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h0C) begin  // Reserved
				unhandled <= 1'b0;
				dsa_last_error <= DSA_ERR_ILLEGAL_CMD;
				butch_reg[0][12] <= 1'b1;
				butch_reg[0][13] <= 1'b1;
				ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_CMD;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h0D) begin  // Get Complete Time
				unhandled <= 1'b0;
				if (!cd_ex) begin
					dsa_last_error <= dsa_presence_error;
					butch_reg[0][12] <= 1'b1;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | dsa_presence_error;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp[0] <= 32'h1400 | cur_aminutes[6:0];
					ds_resp[1] <= 32'h1500 | cur_aseconds[5:0];
					ds_resp[2] <= 32'h1600 | cur_aframes[6:0];
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h3;
					ds_resp_loop <= 7'h0;
				end
			end
			if (din[15:8]==8'h10) begin  // 0x10 Goto ABS Min
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				if (din[6:0] > 7'd99) begin
					dsa_last_error <= DSA_ERR_ILLEGAL_VALUE;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_VALUE;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h0;
					ds_resp_loop <= 7'h0;
					dsa_last_error <= DSA_ERR_NONE;
					goto_minutes <= din[6:0];
					sminutes <= din[6:0];
				end
			end
			if (din[15:8]==8'h11) begin  // 0x10 Goto ABS Sec
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				if (din[5:0] > 6'd59) begin
					dsa_last_error <= DSA_ERR_ILLEGAL_VALUE;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_VALUE;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h0;
					ds_resp_loop <= 7'h0;
					dsa_last_error <= DSA_ERR_NONE;
					goto_seconds <= din[5:0];
					sseconds <= din[5:0];
				end
			end
			if (din[15:8]==8'h12) begin  // 0x10 Goto ABS Frame
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				if (!cd_ex || !toc_ready) begin
					dsa_last_error <= dsa_presence_error;
					seek_found_pending <= 1'b0;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | dsa_presence_error;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else if ((goto_minutes > 7'd99) || (goto_seconds > 6'd59) || (din[6:0] > 7'd74) || goto_target_past_leadout) begin
					dsa_last_error <= DSA_ERR_ILLEGAL_VALUE;
					seek_found_pending <= 1'b0;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_VALUE;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					butch_reg[0][13] <= 1'b0; // response is posted after seek delay completes
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
					// Drop stale IRQ pending from the prior position and restart
					// subcode chunk stream at canonical first chunk (0x10).
					subcode_irq_pending <= 1'b0;
					frame_irq_pending <= 1'b0;
					sub_chunk_count <= 8'h0F;
					subidx <= 4'h0;
					atti_report_valid <= 1'b0;
					atti_evt_title_pending <= 1'b0;
					atti_evt_index_pending <= 1'b0;
					atti_evt_rel_minutes_pending <= 1'b0;
					atti_evt_rel_seconds_pending <= 1'b0;
					atti_evt_abs_minutes_pending <= 1'b0;
					atti_evt_abs_seconds_pending <= 1'b0;
					sminutes <= goto_minutes;
					sseconds <= goto_seconds;
					sframes <= din[6:0];
					seek_skip_cbusy_wait <= play && !pause && !spinpause;
					seek_src_abs <= cur_abs_frames;
					seek_dst_abs <= goto_cmd_abs_frames_next;
					seek_mid_abs <= (cur_abs_frames + goto_cmd_abs_frames_next) >> 1;
					if (goto_cmd_abs_frames_next >= cur_abs_frames) begin
						seek_delta_abs <= goto_cmd_abs_frames_next - cur_abs_frames;
						seek_delay_set <= seek_delay_cycles(goto_cmd_abs_frames_next - cur_abs_frames, (cur_abs_frames + goto_cmd_abs_frames_next) >> 1, speed2x);
					end else begin
						seek_delta_abs <= cur_abs_frames - goto_cmd_abs_frames_next;
						seek_delay_set <= seek_delay_cycles(cur_abs_frames - goto_cmd_abs_frames_next, (cur_abs_frames + goto_cmd_abs_frames_next) >> 1, speed2x);
					end

					if (!cd_latency_en) begin
						seek_delay_set <= 32'h1_000_000;
					end
					if (play && !pause && !spinpause) begin
						seek_delay_set <= cd_latency_en ? DSA_DELAY_SCAN_GOTO : 32'h0008_0000;
					end

					search_forward <= 1'b0;
					search_backward <= 1'b0;
					search_fast <= 1'b0;
					search_borderflag <= 1'b0;
					search_div <= 5'h0;
					leadout_title_pending <= 1'b0;
					leadout_seen <= 1'b0;
					cues_addr <= seek_scan_start_track;
					cuet_addr <= seek_scan_start_track;
					seek_found_pending <= 1'b1;
					seek <= 8'hFF;
					abseek <= 8'h0;
					stop <= 1'b0;
					spinpause <= 1'b0;
				end
			end
			if (din[15:8]==8'h14) begin  // Read Long TOC
				unhandled <= 1'b0;
				if (!cd_ex || !toc_ready) begin
					dsa_last_error <= dsa_presence_error;
					dsa_long_toc_active <= 1'b0;
					ds_resp[0] <= 32'h0400 | dsa_presence_error;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else if ((!aud_sess && (din[7:0] != 8'h00)) || (din[7:0] >= dsa_session_count) || (din[7:0] >= DSA_MAX_SESSIONS) || !dsa_req_sess_valid) begin
					dsa_last_error <= DSA_ERR_ILLEGAL_VALUE;
					dsa_long_toc_active <= 1'b0;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_VALUE;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					dsa_long_toc_active <= 1'b1;
					dsa_long_toc_first_track <= dsa_req_first_track;
					dsa_long_toc_last_track <= dsa_req_last_track;
					ds_resp[0] <= 32'h6000 | dsa_req_first_track;
					ds_resp[1] <= 32'h6100 | (((dat_track != 7'h0) && (dsa_req_first_track >= dat_track)) ? 8'h41 : 8'h01);
					ds_resp[2] <= 32'h6200;
					ds_resp[3] <= 32'h6300;
					ds_resp[4] <= 32'h6400;
					if (dsa_req_session == 8'h00) begin
						dbg_ltoc0_r <= {
							1'b1,
							dsa_req_first_track,
							(((dat_track != 7'h0) && (dsa_req_first_track >= dat_track)) ? 8'h41 : 8'h01)
						};
					end else if (dsa_req_session == 8'h01) begin
						dbg_ltoc1_r <= {
							1'b1,
							dsa_req_first_track,
							(((dat_track != 7'h0) && (dsa_req_first_track >= dat_track)) ? 8'h41 : 8'h01)
						};
					end

					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h5;
					ds_resp_loop <= 7'h0;
					cues_addr <= dsa_req_first_track;
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
				atti_report_valid <= 1'b0;
				atti_evt_title_pending <= 1'b0;
				atti_evt_index_pending <= 1'b0;
				atti_evt_rel_minutes_pending <= 1'b0;
				atti_evt_rel_seconds_pending <= 1'b0;
				atti_evt_abs_minutes_pending <= 1'b0;
				atti_evt_abs_seconds_pending <= 1'b0;
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
				dsa_last_error <= DSA_ERR_NONE;
				ds_resp[0] <= 32'h400;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h18) begin  // Spin Up
				unhandled <= 1'b0;
				if (!cd_ex) begin
					dsa_last_error <= DSA_ERR_FOCUS_NO_DISC;
					ds_resp[0] <= 32'h0400 | DSA_ERR_FOCUS_NO_DISC;
					butch_reg[0][12] <= 1'b1;
					butch_reg[0][13] <= 1'b1;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else if (!toc_ready) begin
					// Accept command but keep drive busy until TOC/session metadata arrives.
					dsa_last_error <= DSA_ERR_NONE;
					abplay <= 1'b0;
					abseek <= 8'h0;
					search_forward <= 1'b0;
					search_backward <= 1'b0;
					search_fast <= 1'b0;
					search_borderflag <= 1'b0;
					search_div <= 5'h0;
					butch_reg[0][12] <= 1'b1;
					butch_reg[0][13] <= 1'b0;
					ds_resp[0] <= 32'h0100 | 32'h0043;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
					dsa_spinup_wait_toc <= 1'b1;
					dsa_spinup_session <= dsa_spin_req_session;
				end else begin
					abplay <= 1'b0;
					abseek <= 8'h0;
					search_forward <= 1'b0;
					search_backward <= 1'b0;
					search_fast <= 1'b0;
					search_borderflag <= 1'b0;
					search_div <= 5'h0;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					if (cd_latency_en) begin
						butch_reg[0][13] <= 1'b0;
						dsa_delay_pending <= 1'b1;
						dsa_delay_ctr <= DSA_DELAY_SPIN_UP;
					end else begin
						butch_reg[0][13] <= 1'b1; // |= 0x2000
					end
					ds_resp[0] <= 32'h0100 | 32'h0043;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
					mounted <= 1'b1;
					spinpause <= 1'b1;
					if (mounted) begin
						spinpause <= 1'b0;
					end
					splay <= 5'h15;
					stop <= 1'b0;
					aud_add <= 30'h0;
					if (dsa_sess_valid[dsa_spin_req_session] && (dsa_sess_first_track[dsa_spin_req_session] != 7'h00)) begin
						track_idx <= dsa_sess_first_track[dsa_spin_req_session];
						dbg_spin_r <= {
							1'b1,
							dsa_sess_first_track[dsa_spin_req_session],
							dsa_spin_req_session
						};
					end else begin
						track_idx <= 7'h1;
						dbg_spin_r <= {
							1'b1,
							7'h01,
							dsa_spin_req_session
						};
					end
					cur_samples <= 10'h0;
					cur_rframes <= 7'h0;
					cur_rseconds <= 6'h2;
					cur_rminutes <= 7'h0;
					gframes <= 3'h0;
					if (dsa_sess_valid[dsa_spin_req_session] && (dsa_sess_first_track[dsa_spin_req_session] != 7'h00)) begin
						cues_addr <= dsa_sess_first_track[dsa_spin_req_session];
						cuet_addr <= dsa_sess_first_track[dsa_spin_req_session];
					end else begin
						cues_addr <= 7'h1;
						cuet_addr <= 7'h1;
					end
					updabs_req <= 1'b1;
				end
			end
			if (din[15:8]==8'h20) begin  // Play A Time To B Time
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h0;
				ds_resp_loop <= 7'h0;
				abaminutes <= din[6:0];
			end
			if (din[15:8]==8'h21) begin  // Play A Time To B Time
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h0;
				ds_resp_loop <= 7'h0;
				abaseconds <= din[5:0];
			end
			if (din[15:8]==8'h22) begin  // Play A Time To B Time
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h0;
				ds_resp_loop <= 7'h0;
				abaframes <= din[6:0];
			end
			if (din[15:8]==8'h23) begin  // Play A Time To B Time
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h0;
				ds_resp_loop <= 7'h0;
				abbminutes <= din[6:0];
			end
			if (din[15:8]==8'h24) begin  // Play A Time To B Time
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				// No response
				//butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h0;
				ds_resp_loop <= 7'h0;
				abbseconds <= din[5:0];
			end
			if (din[15:8]==8'h25) begin  // Play A Time To B Time (start)
				unhandled <= 1'b0;
				abbframes <= din[6:0];
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				if (!cd_ex) begin
					dsa_last_error <= dsa_presence_error;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | dsa_presence_error;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
					abplay <= 1'b0;
					abseek <= 8'h0;
				end else if ({abaminutes,2'b00,abaseconds,1'b0,abaframes} > {abbminutes,2'b00,abbseconds,1'b0,din[6:0]}) begin
					dsa_last_error <= DSA_ERR_ILLEGAL_VALUE;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_VALUE;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
					abplay <= 1'b0;
					abseek <= 8'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					butch_reg[0][13] <= 1'b0; // response after A-time seek completes
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
					sminutes <= abaminutes;
					sseconds <= abaseconds;
					sframes <= abaframes;
					seek_skip_cbusy_wait <= 1'b0;
					cues_addr <= seek_scan_start_track;
					cuet_addr <= seek_scan_start_track;
					seek_found_pending <= 1'b0;
					seek <= 8'hFF;
					abseek <= 8'hFF;
					abplay <= 1'b1;
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
			end
			if (din[15:8]==8'h30) begin  // Get Disc identifiers
				unhandled <= 1'b0;
				if (!cd_ex || !toc_ready) begin
					dsa_last_error <= dsa_presence_error;
					ds_resp[0] <= 32'h0400 | dsa_presence_error;
					butch_reg[0][12] <= 1'b1;
					butch_reg[0][13] <= 1'b1;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					ds_resp[0] <= 32'h3000 | dsa_disc_id0;
					ds_resp[1] <= 32'h3100 | dsa_disc_id1;
					ds_resp[2] <= 32'h3200 | dsa_disc_id2;
					ds_resp[3] <= 32'h3300 | dsa_disc_id3;
					ds_resp[4] <= 32'h3400 | dsa_disc_id4;
					butch_reg[0][12] <= 1'b1; // |= 0x1000
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h5;
					ds_resp_loop <= 7'h0;
				end
			end
			if ((din[15:8] >= 8'h40) && (din[15:8] <= 8'h44)) begin  // Reserved
				unhandled <= 1'b0;
				dsa_last_error <= DSA_ERR_ILLEGAL_CMD;
				butch_reg[0][12] <= 1'b1;
				butch_reg[0][13] <= 1'b1;
				ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_CMD;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h50) begin  // Get Disc Status
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h0300 | dsa_disc_status;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h51) begin  // Set Volume
				unhandled <= 1'b0;
				dsa_volume <= din[7:0];
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				butch_reg[0][13] <= 1'b1; // |= 0x2000
				ds_resp[0] <= 32'h5100 | din[7:0]; // 0=mute 1-254=fade 255=full
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h52) begin  // Get Mode Status (compatibility alias)
				unhandled <= 1'b0;
				dsa_last_error <= DSA_ERR_NONE;
				butch_reg[0][12] <= 1'b1;
				butch_reg[0][13] <= 1'b1;
				ds_resp[0] <= 32'h1700 | mode;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
			end
			if (din[15:8]==8'h54) begin  // Get Max Session
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				if (!cd_ex || !toc_ready) begin
					dsa_last_error <= dsa_presence_error;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | dsa_presence_error;
					dbg_resp_54_r <= 16'h0400 | dsa_presence_error;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp[0] <= 32'h5400 | dsa_max_session_rsp;
					dbg_resp_54_r <= 16'h5400 | dsa_max_session_rsp;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end
			end
			if (din[15:8]==8'h6A) begin  // Clear TOC
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				if (play || (seek != 8'h0) || (splay != 5'h0)) begin
					dsa_last_error <= DSA_ERR_ILLEGAL_CMD;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_CMD;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end else begin
					dsa_last_error <= DSA_ERR_NONE;
					dsa_long_toc_active <= 1'b0;
					dsa_long_toc_first_track <= 7'h0;
					dsa_long_toc_last_track <= 7'h0;
					toc_ready <= 1'b0;
					dsa_sess_count_toc <= 8'h0;
					cue_tracks <= 7'h0;
					aud_tracks <= 7'h0;
					dat_tracks <= 7'h0;
					dat_track <= 7'h0;
					for (dsa_sess_i = 0; dsa_sess_i < DSA_MAX_SESSIONS; dsa_sess_i = dsa_sess_i + 1) begin
						dsa_sess_first_track[dsa_sess_i] <= 7'h0;
						dsa_sess_last_track[dsa_sess_i] <= 7'h0;
						dsa_sess_leadout[dsa_sess_i] <= 24'h0;
						dsa_sess_valid[dsa_sess_i] <= 1'b0;
					end
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp[0] <= 32'h6A00;
					ds_resp_idx <= 3'h0;
					ds_resp_size <= 3'h1;
					ds_resp_loop <= 7'h0;
				end
			end
			if (din[15:8]==8'h70) begin  // Set DAC Mode (validate against documented DAC mode set)
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1; // |= 0x1000
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (dsa_dac_mode_valid) begin
					dsa_last_error <= DSA_ERR_NONE;
					butch_reg[0][13] <= 1'b1; // |= 0x2000
					ds_resp[0] <= 32'h7000 | din[7:0];
					ds_resp_size <= 3'h1;
				end else begin
					dsa_last_error <= DSA_ERR_ILLEGAL_VALUE;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_VALUE;
					ds_resp_size <= 3'h1;
				end
			end
			if (din[15:8]==8'hF0) begin  // Service mode control
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1;
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (din[7:0] == 8'h01) begin  // request servo version + enter service mode
					dsa_last_error <= DSA_ERR_NONE;
					dsa_service_mode <= 1'b1;
					dsa_sledge_out <= 1'b0;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'hF000 | DSA_SERVO_VERSION;
					ds_resp_size <= 3'h1;
				end else if (din[7:0] == 8'h00) begin  // service mode off
					dsa_last_error <= DSA_ERR_NONE;
					dsa_service_mode <= 1'b0;
					dsa_sledge_out <= 1'b0;
					dsa_focus_on <= 1'b0;
					dsa_spindle_on <= 1'b0;
					dsa_radial_on <= 1'b0;
					dsa_laser_on <= 1'b0;
					butch_reg[0][13] <= 1'b0;
					ds_resp_size <= 3'h0; // no response
				end else begin
					dsa_last_error <= DSA_ERR_ILLEGAL_VALUE;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_VALUE;
					ds_resp_size <= 3'h1;
				end
			end
			if ((din[15:8] >= 8'hF1) && (din[15:8] <= 8'hF9)) begin  // Service commands
				unhandled <= 1'b0;
				butch_reg[0][12] <= 1'b1;
				ds_resp_idx <= 3'h0;
				ds_resp_loop <= 7'h0;
				if (dsa_service_mode) begin
					ds_resp_size <= 3'h0; // no response
					butch_reg[0][13] <= 1'b0;
					dsa_last_error <= DSA_ERR_NONE;
					if (din[15:8]==8'hF1) begin
						dsa_sledge_out <= din[0];
					end
					if (din[15:8]==8'hF2) begin
						dsa_focus_on <= din[0];
						if (!din[0]) begin
							dsa_radial_on <= 1'b0;
							dsa_spindle_on <= 1'b0;
							dsa_laser_on <= 1'b0;
						end else begin
							dsa_laser_on <= 1'b1;
						end
					end
					if (din[15:8]==8'hF3) begin
						dsa_spindle_on <= din[0];
						if (!din[0]) begin
							dsa_radial_on <= 1'b0;
						end else begin
							dsa_laser_on <= 1'b1;
							dsa_focus_on <= 1'b1;
						end
					end
					if (din[15:8]==8'hF4) begin
						dsa_radial_on <= din[0];
						if (din[0]) begin
							dsa_laser_on <= 1'b1;
							dsa_focus_on <= 1'b1;
							dsa_spindle_on <= 1'b1;
						end
					end
					if (din[15:8]==8'hF5) begin
						dsa_laser_on <= din[0];
						if (!din[0]) begin
							dsa_radial_on <= 1'b0;
							dsa_spindle_on <= 1'b0;
							dsa_focus_on <= 1'b0;
						end
					end
					if (din[15:8]==8'hF6) begin
						dsa_diag_last <= din[7:0];
					end
					if (din[15:8]==8'hF7) begin
						dsa_high_gain <= din[0];
					end
					if (din[15:8]==8'hF8) begin
						dsa_jump_grooves[15:8] <= din[7:0];
					end
					if (din[15:8]==8'hF9) begin
						dsa_jump_grooves[7:0] <= din[7:0];
					end
				end else begin
					dsa_last_error <= DSA_ERR_ILLEGAL_CMD;
					butch_reg[0][13] <= 1'b1;
					ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_CMD;
					ds_resp_size <= 3'h1;
				end
			end
			if (!dsa_cmd_known) begin
				dsa_last_error <= DSA_ERR_ILLEGAL_CMD;
				butch_reg[0][12] <= 1'b1;
				butch_reg[0][13] <= 1'b1;
				ds_resp[0] <= 32'h0400 | DSA_ERR_ILLEGAL_CMD;
				ds_resp_idx <= 3'h0;
				ds_resp_size <= 3'h1;
				ds_resp_loop <= 7'h0;
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
			end else if (dsa_long_toc_active && (ds_resp_size == 3'h5)) begin
				if (dsa_long_toc_last_track > dsa_long_toc_first_track) begin
					if (cues_addr >= dsa_long_toc_last_track) begin
						cues_addr <= dsa_long_toc_first_track;
					end else begin
						cues_addr <= cues_addr + 7'h1;
					end
				end else begin
					cues_addr <= dsa_long_toc_first_track;
				end
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
		ds_resp[0][7:0] <= cues_add;
		ds_resp[1][15:8] <= 8'h61;
		ds_resp[1][7:0] <= dsa_long_toc_ctrl_addr;
		ds_resp[2][15:8] <= 8'h62;
		ds_resp[2][7:0] <= {1'b0,cues_dout[22:16]};
		ds_resp[3][15:8] <= 8'h63;
		ds_resp[3][7:0] <= {2'b0,cues_dout[13:8]};
		ds_resp[4][15:8] <= 8'h64;
		ds_resp[4][7:0] <= {1'b0,cues_dout[6:0]};
	end
	// ATTI runtime notifications: emit only when title/index/time fields actually change.
	if (!(attirel || attiabs)) begin
		atti_report_valid <= 1'b0;
		atti_evt_title_pending <= 1'b0;
		atti_evt_index_pending <= 1'b0;
		atti_evt_rel_minutes_pending <= 1'b0;
		atti_evt_rel_seconds_pending <= 1'b0;
		atti_evt_abs_minutes_pending <= 1'b0;
		atti_evt_abs_seconds_pending <= 1'b0;
	end else if (play && !stop && !spinpause && !pause && (seek == 8'h0) && (splay == 5'h0) && !dsa_delay_pending) begin
		if (!atti_report_valid) begin
			atti_report_valid <= 1'b1;
			atti_last_title <= atti_cur_title;
			atti_last_index <= atti_cur_index;
			atti_last_rel_minutes <= cur_rminutes[6:0];
			atti_last_rel_seconds <= cur_rseconds[5:0];
			atti_last_abs_minutes <= cur_aminutes[6:0];
			atti_last_abs_seconds <= cur_aseconds[5:0];
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
	// Drain one ATTI event at a time so responses match hardware-style discrete updates.
	if ((ds_resp_size == 3'h0) &&
		!ds_a &&
		!updresp &&
		!updrespa &&
		!dsa_delay_pending &&
		!dsa_spinup_wait_toc &&
		!play_title_pending_rsp) begin
		if (leadout_title_pending) begin
			leadout_title_pending <= 1'b0;
			butch_reg[0][12] <= 1'b1;
			butch_reg[0][13] <= 1'b1;
			ds_resp[0] <= 32'h1000 | 8'hAA;
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
			atti_report_valid <= 1'b1;
			atti_last_title <= 8'hAA;
			atti_last_index <= 8'h01;
		end else if (atti_evt_title_pending) begin
			atti_evt_title_pending <= 1'b0;
			butch_reg[0][12] <= 1'b1;
			butch_reg[0][13] <= 1'b1;
			ds_resp[0] <= 32'h1000 | atti_cur_title;
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
		end else if (atti_evt_index_pending) begin
			atti_evt_index_pending <= 1'b0;
			butch_reg[0][12] <= 1'b1;
			butch_reg[0][13] <= 1'b1;
			ds_resp[0] <= 32'h1100 | atti_cur_index;
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
		end else if (attirel && atti_evt_rel_minutes_pending) begin
			atti_evt_rel_minutes_pending <= 1'b0;
			butch_reg[0][12] <= 1'b1;
			butch_reg[0][13] <= 1'b1;
			ds_resp[0] <= 32'h1200 | cur_rminutes[6:0];
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
		end else if (attirel && atti_evt_rel_seconds_pending) begin
			atti_evt_rel_seconds_pending <= 1'b0;
			butch_reg[0][12] <= 1'b1;
			butch_reg[0][13] <= 1'b1;
			ds_resp[0] <= 32'h1300 | cur_rseconds[5:0];
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
		end else if (attiabs && atti_evt_abs_minutes_pending) begin
			atti_evt_abs_minutes_pending <= 1'b0;
			butch_reg[0][12] <= 1'b1;
			butch_reg[0][13] <= 1'b1;
			ds_resp[0] <= 32'h1400 | cur_aminutes[6:0];
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
		end else if (attiabs && atti_evt_abs_seconds_pending) begin
			atti_evt_abs_seconds_pending <= 1'b0;
			butch_reg[0][12] <= 1'b1;
			butch_reg[0][13] <= 1'b1;
			ds_resp[0] <= 32'h1500 | cur_aseconds[5:0];
			ds_resp_idx <= 3'h0;
			ds_resp_size <= 3'h1;
			ds_resp_loop <= 7'h0;
		end
	end
	if (old_doe_dsc && !doe_dsc) begin
		butch_reg[0][12] <= 1'b0;
//		butch_reg[0][13] <= ((ds_resp[0][13:8] == 6'h20) || (ds_resp[0][15:8] == 6'h04)) ? 1'b1 : 1'b0; // gettoc==0x20 or 0x60
		butch_reg[0][13] <= ((ds_resp_size == 3'h0) || (ds_resp_size == 3'h1)) ? 1'b0 : 1'b1; // gettoc==0x20 or 0x60
	end
	if (old_doe_sbcntrl && !doe_sbcntrl) begin
		// Real software (e.g. VLM GPU ISR) reads SBCNTRL ($DFFF14) to clear
		// pending subcode/frame interrupt status bits.
		subcode_irq_pending <= 1'b0;
		frame_irq_pending <= 1'b0;
	end
	if (!old_doe_sub && !doe_sub) begin
		if ((4'h0 == subidx) && upd_frames) begin
			upd_frames <= 1'b0;
			recrc <= 1'b1;
		end
	end
	if (dsa_delay_pending && cd_latency_en && (dsa_delay_ctr > 32'h1)) begin
		butch_reg[0][13] <= 1'b0;
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

	// When CD hardware is disabled, force all drive-generated interrupt and
	// deferred-response state quiescent so Butch cannot perturb cart/system boot.
	if (!cd_en) begin
		subcode_irq_pending <= 1'b0;
		frame_irq_pending <= 1'b0;
		butch_reg[0][9] <= 1'b0;
		butch_reg[0][10] <= 1'b0;
		butch_reg[0][11] <= 1'b0;
		butch_reg[0][12] <= 1'b0;
		butch_reg[0][13] <= 1'b0;
		play <= 1'b0;
		stop <= 1'b0;
		pause <= 1'b0;
		spinpause <= 1'b0;
		seek <= 8'h0;
		seek_skip_cbusy_wait <= 1'b0;
		seek_found_pending <= 1'b0;
		splay <= 5'h0;
		abplay <= 1'b0;
		abseek <= 8'h0;
		search_forward <= 1'b0;
		search_backward <= 1'b0;
		dsa_delay_pending <= 1'b0;
		dsa_delay_ctr <= 32'h0;
		dsa_spinup_wait_toc <= 1'b0;
		dsa_long_toc_active <= 1'b0;
		play_title_pending_rsp <= 1'b0;
		ds_resp_idx <= 3'h0;
		ds_resp_size <= 3'h0;
		ds_resp_loop <= 7'h0;
		atti_report_valid <= 1'b0;
		atti_evt_title_pending <= 1'b0;
		atti_evt_index_pending <= 1'b0;
		atti_evt_rel_minutes_pending <= 1'b0;
		atti_evt_rel_seconds_pending <= 1'b0;
		atti_evt_abs_minutes_pending <= 1'b0;
		atti_evt_abs_seconds_pending <= 1'b0;
		leadout_title_pending <= 1'b0;
		leadout_seen <= 1'b0;
	end

	if (!resetl) begin
		hackwait <= 1'b0;
		seek_count <= 8'h0;
		pastcdbios <= 1'b0;
		recrc <= 1'b0;
		subidx <= 4'h0;
		sub_chunk_count <= 8'h0F;
		frame_irq_pending <= 1'b0;
		subcode_irq_pending <= 1'b0;
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
		track_idx <= 7'h1;
		atrack <= 7'h1;
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
		upd_frames <= 1'b0;
		upd_seconds <= 1'b0;
		upd_minutes <= 1'b0;
		updabs <= 1'b0;
		updabs_req <= 1'b0;
		ds_resp[0] <= 32'h0;
		ds_resp[1] <= 32'h0;
		ds_resp[2] <= 32'h0;
		ds_resp[3] <= 32'h0;
		ds_resp[4] <= 32'h0;
		ds_resp[5] <= 32'h0;
		ds_resp_idx <= 3'h0;
		ds_resp_size <= 3'h0;
		ds_resp_loop <= 7'h0;
		updresp <= 1'b0;
		updrespa <= 1'b0;
		mode <= 8'h01; // default: 1x audio mode until BIOS/program sets explicit mode
		sdin[15:0] <= 0;
		sdin3[15:0] <= 0;
		sdin4[15:0] <= 0;
		last_ds <= 16'h0;
		dbg_resp_54_r <= 16'h0000;
		dbg_toc0_r <= 40'h0;
		dbg_toc1_r <= 40'h0;
		dbg_spin_r <= 16'h0000;
		dbg_ltoc0_r <= 16'h0000;
		dbg_ltoc1_r <= 16'h0000;
		dsa_last_error <= DSA_ERR_NONE;
		dsa_volume <= 8'hFF;
		title_len_pending <= 1'b0;
		seek_delay_set <= 32'h2000000;
		seek_src_abs <= 20'h0;
		seek_dst_abs <= 20'h0;
		seek_delta_abs <= 21'h0;
		seek_mid_abs <= 20'h0;
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
		sframes <= 7'h0;
		sseconds <= 6'h0;
		sminutes <= 7'h0;
		goto_minutes <= 7'h0;
		goto_seconds <= 6'h0;
		gframes <= 3'h0;
		subtseconds <= 6'h0;
		subtrseconds <= 6'h0;
		taud_add <= 19'h0;
		taud2_add <= 22'h0;
		taud3_add <= 20'h0;
		seek_delay <= 32'h0;
		seek_skip_cbusy_wait <= 1'b0;
		seek_found_pending <= 1'b0;
		dsa_delay_pending <= 1'b0;
		dsa_delay_ctr <= 32'h0;
		dsa_spinup_wait_toc <= 1'b0;
		dsa_spinup_session <= 8'h00;
		dsa_long_toc_active <= 1'b0;
		dsa_long_toc_first_track <= 7'h0;
		dsa_long_toc_last_track <= 7'h0;
		i2s_rfifopos <= 5'h0;
		i2s_wfifopos <= 5'h0;
		fifo_inc <= 1'b0;
		i2s_fifo[0] <= 0;
		i2s_fifo[1] <= 0;
		i2s_fifo[2] <= 0;
		i2s_fifo[3] <= 0;
		i2s_fifo[4] <= 0;
		i2s_fifo[5] <= 0;
		i2s_fifo[6] <= 0;
		i2s_fifo[7] <= 0;
		i2s_fifo[8] <= 0;
		i2s_fifo[9] <= 0;
		i2s_fifo[10] <= 0;
		i2s_fifo[11] <= 0;
		i2s_fifo[12] <= 0;
		i2s_fifo[13] <= 0;
		i2s_fifo[14] <= 0;
		i2s_fifo[15] <= 0;
		search_forward <= 1'b0;
		search_backward <= 1'b0;
		search_fast <= 1'b0;
		search_borderflag <= 1'b0;
		search_div <= 5'h0;
		dsa_service_mode <= 1'b0;
		dsa_sledge_out <= 1'b0;
		dsa_focus_on <= 1'b0;
		dsa_spindle_on <= 1'b0;
		dsa_radial_on <= 1'b0;
		dsa_laser_on <= 1'b0;
		dsa_high_gain <= 1'b0;
		dsa_diag_last <= 8'h0;
		dsa_jump_grooves <= 16'h0000;
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
		play_title_pending_rsp <= 1'b0;
		play_title_pending_track <= 7'h0;
		leadout_title_pending <= 1'b0;
		leadout_seen <= 1'b0;
		abplay <= 1'b0;
		abseek <= 8'h0;
		abaframes <= 7'h0;
		abaseconds <= 6'h0;
		abaminutes <= 7'h0;
		abbframes <= 7'h0;
		abbseconds <= 6'h0;
		abbminutes <= 7'h0;
		overflow <= 1'b0;
		underflow <= 1'b0;
		errflow <= 1'b0;
		old_doe_sbcntrl <= 1'b0;
	end
	if (!cdbios)
		pastcdbios <= 1'b1;
end

wire [6:0] cuet_add;
wire [31:0] cuet_din;
wire [31:0] cuet_doutt;
wire cuet_wr;
wire [31:0] cuet_dout = (cuet_add > cue_tracks) ? 32'h0 : cuet_doutt;
wire [29:0] cueb_dout = 30'h0;
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
wire [23:0] cues_dout = (cues_add > cue_tracks) ? cuestop[1'b1] : cues_doutt;
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
wire [23:0] cuep_dout = (cuep_add > cue_tracks) ? cuestop[1'b1] : cuep_doutt;
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


endmodule

