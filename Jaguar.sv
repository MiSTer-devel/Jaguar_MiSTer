//============================================================================
//
//  Port to MiSTer.
//  Copyright (C) 2018 Sorgelig
//
//  Jaguar core code.
//  Copyright (C) 2018 Gregory Estrade (Torlus).
//
//  Port of Jaguar core to MiSTer (ElectronAsh / OzOnE).
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [48:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler
	output        VGA_DISABLE, // analog out is off

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,
	output        HDMI_FREEZE,
	output        HDMI_BLACKOUT,
	output        HDMI_BOB_DEINT,

`ifdef MISTER_FB
	// Use framebuffer in DDRAM
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
	//Secondary SDRAM
	//Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);
///////// Default values for ports not used in this core /////////

assign ADC_BUS  = 'Z;
assign {UART_RTS, UART_TXD, UART_DTR} = 0;
assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;

assign USER_OUT[0] = 1'b1;
assign USER_OUT[2] = 1'b1;
assign USER_OUT[3] = 1'b1;
assign USER_OUT[4] = 1'b1;
assign USER_OUT[5] = 1'b1;
assign USER_OUT[6] = 1'b1;

assign VGA_SL = 0;
assign VGA_F1 = vga_field;
assign VGA_SCALER = 0;
assign VGA_DISABLE = 0;
assign HDMI_FREEZE = 0;
assign HDMI_BLACKOUT = 0;
assign HDMI_BOB_DEINT = 0;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

wire save_busy;
wire save_pending;
assign LED_USER = ioctl_download | save_busy | save_pending;

`define FAST_CLOCK
`include "rtl/defines.vh"

wire clk_106m, clk_26m, clk_53m;

wire pll_locked;
pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_106m),
	.outclk_1(clk_26m),
	.outclk_2(clk_53m),
	.locked(pll_locked)
);

`ifdef FAST_CLOCK
wire clk_sys = clk_106m;
`else
wire clk_sys = clk_53m;
`endif

wire clk_ram = clk_106m;

wire [1:0] scale = status[10:9];
wire [1:0] ar = status[8:7];
wire ntsc = ~status[4];
wire [11:0] auto_video_arx;
wire [11:0] auto_video_ary;

assign VIDEO_ARX = (!ar) ? auto_video_arx : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? auto_video_ary : 12'd0;

// Status Bit Map:
//         0123456789ABCDEF
// 000-015 ..X.XXXXXXX..XX.  000 001 002 003 004 005 006 007 008 009 010 011 012 013 014 015
// 016-031 ..XXXX.XXXXXXXXX  016 017 018 019 020 021 022 023 024 025 026 027 028 029 030 031
// 032-047 XXXXXXXXXXXX....  032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047
// 048-063 ....XXXXX.....XX  048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063
// 064-079 ................  064 065 066 067 068 069 070 071 072 073 074 075 076 077 078 079
// 080-095 .XX.XX..........  080 081 082 083 084 085 086 087 088 089 090 091 092 093 094 095
// 096-111 ................  096 097 098 099 100 101 102 103 104 105 106 107 108 109 110 111
// 112-127 ................  112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127

`include "build_id.v"
localparam CONF_STR = {
	"Jaguar;;",
	"-;",
	"FS1,JAGJ64ROMBIN;",
	"S1,CDI,Stream CD;",
	"-;",
	"H2SC2,JMC,MemoryTrack Save;",
	"H2-;",
	"C,Cheats;",
	"H1O[23],Cheats Enabled,Yes,No;",
	"-;",
	// Audio Video Options
	"P1,Audio & Video;",
	"P1-;",
	"P1O[4],Region Setting,NTSC,PAL;",
	"P1O[8:7],Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"P1O[10:9],Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	// "P1O[19:18],Crop,None,Small,Primal;",
	"P1O[87],Visual Area,Active,Original;",
	// "P1O[87],Active Video Crop,Off,On;",
	// "P1O[88],Fixed Blank Sizes,Off,On;",
	// Input Options
	"P2,Input Options;",
	"P2-;",
	"P2O[85],Numstick,On,Off;",
	"P2O[83],Keyboard As P1,Off,On;",
	"P2O[86],Swap P1/P2,Off,On;",
	"P2-;",
	"P2O[21:20],Spinner Speed,Normal,Faster,Slow,Slower;",
	"P2O[33:32],Team Tap,Disabled,JoyPort1,JoyPort2;",
	"P2O[6:5],Mouse,Disabled,JoyPort1,JoyPort2;",
	"P2-;",
	"P2RM,P1+P2 Pause;",
	"P2-;",
	//"P2O[41:40],Light Gun,Disabled,Joy1,Joy2,Mouse;",
//	"DDP2O[43:42],Cross,Small,Medium,Large,None;",
	// BIOS Menu
	"P3,Assign BIOS Files;",
	"P3-;",
	"P3FC2,JAGJ64ROMBIN,Assign Jaguar BIOS;",
	"P3FC3,JAGJ64ROMBIN,Assign CD BIOS;",
	"P3FC4,JAGJ64ROMBIN,Assign MemoryTrack BIOS;",
	"P3SC3,JCE,CD EEPROM Save;",
	// Advanced Options
	"P4,Advanced Options;",
	"P4-;",
	"D0P4RC,Load Backup RAM;",
	"D0P4RB,Save Backup RAM;",
	"D0P4O[13],Autosave,On,Off;",
	"P4-;",
	"P4O[30],Homebrew Support,On,Off;",
	"P4-;",
	"P4O[52],Force CD Enabled,Off,On;",
	"H2P4O[56],Force MemoryTrack,Off,On;",
	"P4O[55],Force Music CD,Off,On;",
	"P4O[82],CD Timing,Accurate,Fast;",
	"P4-;",
	`ifndef MISTER_DUAL_SDRAM
	"P4O[36:34],FastRAM1,0,1,2,3,4,5,6,7;",
	"P4O[39:37],FastRAM2,7,6,5,4,3,2,1,0;",
	`endif
	"-;",
	"R0,Reset;",
	"J1,A,B,C,Option,Pause,1,2,3,4,5,6,7,8,9,0,Star,Hash;",
	"jn,Y,B,A,Select,Start;",
	"jp,Y,B,A,Select,Start;",
	"-;",
	"I,",
	"Info1,",
	"Info2,",
	"Info3,",
	"Info4,",
	"Info5,",
	"Info6,",
	"Info7,",
	"Info8,",
	"Inf01,",
	"Inf02,",
	"Inf03,",
	"Inf04,",
	"Inf05,",
	"Inf06,",
	"Inf07,",
	"Inf08,",
	"V,v",`BUILD_DATE
};

wire [127:0] status;
wire  [1:0] buttons;

wire [31:0] joystick_0; // Bit Order: Hash, Star, 0, 9, 8, 7, 6, 5, 4, 3, 2, 1, Option, Pause, A, B, C, Down, Left, Right, Up
wire [31:0] joystick_1;
wire [31:0] joystick_2;
wire [31:0] joystick_3;
wire [31:0] joystick_4;
wire [11:0] numstick_keypad;
wire        ioctl_download;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [15:0] ioctl_data;
wire  [7:0] ioctl_index;
//reg         ioctl_wait;
wire        ioctl_wait;
wire [31:0] sd_lba;
wire        sd_rd;
wire        sd_wr;
wire        sd_ack;
wire [31:0] eeprom_lba;
wire  [7:0] sd_buff_addr;
wire [15:0] sd_buff_dout;
wire        sd_buff_wr;
wire        img_mounted;
wire        img_readonly;
wire [63:0] img_size;
wire        forced_scandoubler;
wire [10:0] ps2_key;
wire [24:0] ps2_mouse;
wire [21:0] gamma_bus;
wire [15:0] sdram_sz;
wire [15:0] analog_0_l;
wire [15:0] analog_1_l;
wire [15:0] analog_2_l;
wire [15:0] analog_3_l;
wire [15:0] analog_4_l;
wire [15:0] analog_0_r;
wire [15:0] analog_1_r;
wire [15:0] analog_2_r;
wire [15:0] analog_3_r;
wire [15:0] analog_4_r;
wire [8:0]  spinner_0;
wire [8:0]  spinner_1;
wire [1:0]  lightgun_mode = status[41:40];
wire        crossmenu_disable = (lightgun_mode == 2'd0);

wire [31:0] cd_hps_lba;
wire        cd_hps_req;
wire        cd_hps_ack;
wire        cd_media_change;
wire        jagcd_on_cart_bus;

wire        nvram_hps_ack;
bit         nvram_hps_wr;
bit         nvram_hps_rd;
bit  [15:0] nvram_hps_din;
// wire        nvram_media_change;

// // Flag which becomes active for some time when an NvRAM image is mounted
// wire        nvram_img_mount = nvram_media_change && img_size != 0;
// Flag which becomes active for some time when an NvRAM image is mounted
// wire        cd_img_mount = cd_media_change && img_size != 0;

wire ram64;
// wire tapclock = status[28] ? xvclk_o: clk_sys;
wire xvclk_o;
// wire aud_16_eq = 0;
wire memtrack;
wire memtrak_save_mount;
wire eeprom_save_mount;
wire eeprom_rd;
wire eeprom_wr;
wire eeprom_ack;
wire [15:0] cart_save_sd_buff_din;
wire [15:0] memtrak_save_sd_buff_din;
wire [15:0] eeprom_save_sd_buff_din;
wire cart_save_busy;
wire cart_save_pending;
wire cart_save_enabled;
wire memtrak_save_busy;
wire memtrak_save_pending;
wire memtrak_save_enabled;
wire eeprom_save_busy;
wire eeprom_save_pending;
wire eeprom_save_enabled;
wire bk_ena;
wire [9:0] cart_bram_addr;
wire [15:0] cart_bram_data;
wire [15:0] cart_bram_q;
wire        cart_bram_wr;
wire [9:0] cd_bram_addr;
wire [15:0] cd_bram_data;
wire [15:0] cd_bram_q;
wire        cd_bram_wr;
wire [31:0] memtrak_slot_lba;
wire        memtrak_slot_rd;
wire        memtrak_slot_wr;
wire        memtrak_slot_ack;
wire  [1:0] memtrack_wr_be;
wire        memtrack_dirty;
wire        memtrack_fastcache_hps_wr;
wire [15:0] memtrack_fastcache_addr;
wire [15:0] memtrack_fastcache_q16;
wire [15:0] memtrack_hps_addr;
wire [15:0] memtrack_hps_q16;
wire [31:0] memtrack_fastcache_q;

hps_io #(.CONF_STR(CONF_STR), .PS2DIV(1000), .WIDE(1), .VDNUM(4)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.buttons(buttons),
	.status(status),

	.sdram_sz(sdram_sz),

	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.joystick_2(joystick_2),
	.joystick_3(joystick_3),
	.joystick_4(joystick_4),

	// analog -127..+127, Y: [15:8], X: [7:0]
	.joystick_l_analog_0(analog_0_l),
	.joystick_l_analog_1(analog_1_l),
	.joystick_l_analog_2(analog_2_l),
	.joystick_l_analog_3(analog_3_l),
	.joystick_l_analog_4(analog_4_l),

	.joystick_r_analog_0(analog_0_r),
	.joystick_r_analog_1(analog_1_r),
	.joystick_r_analog_2(analog_2_r),
	.joystick_r_analog_3(analog_3_r),
	.joystick_r_analog_4(analog_4_r),



	.new_vmode(0),

	.forced_scandoubler(forced_scandoubler),

	// .status_in({status[31:8],region_req,status[5:0]}),
	// .status_set(region_set),
	.status_menumask({~memtrak_bios_exists,~gg_available,~bk_ena}),
	.info_req(j_info_req),
	.info(j_info),

	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_data),
	.ioctl_wait(ioctl_wait),

	.sd_lba('{sd_lba, cd_hps_lba, memtrak_slot_lba, eeprom_lba}),
	.sd_blk_cnt('{6'd0, 6'd0, 6'd0, 6'd0}),
	.sd_rd({eeprom_rd, memtrak_slot_rd, cd_hps_req, sd_rd}),
	.sd_wr({eeprom_wr, memtrak_slot_wr, 1'b0, sd_wr}),
	.sd_ack({eeprom_ack, memtrak_slot_ack, cd_hps_ack, sd_ack}),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din('{cart_save_sd_buff_din, 16'h0000, memtrak_save_sd_buff_din, eeprom_save_sd_buff_din}),
	.sd_buff_wr(sd_buff_wr),
	.img_mounted({eeprom_save_mount, memtrak_save_mount, cd_media_change, img_mounted}),
	.img_readonly(img_readonly),
	.img_size(img_size),

	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),

	.spinner_0(spinner_0),
	.spinner_1(spinner_1),

	.gamma_bus(gamma_bus)
);

wire j_info_req = 0;//joystick_0[4];
wire [7:0] j_info = found_cd ? 8'h2 : 8'h1;//{5'b00,status[36:34]};//found_cd ? 8'h2 : 8'h1;
reg [31:0] loader_addr;

//reg [15:0] loader_data;
wire [15:0] loader_data = ioctl_data;

reg        loader_wr;
reg        loader_en;

wire [7:0] loader_be = (loader_en && loader_addr[2:0]==0) ? 8'b11000000 :
	(loader_en && loader_addr[2:0]==2) ? 8'b00110000 :
	(loader_en && loader_addr[2:0]==4) ? 8'b00001100 :
	(loader_en && loader_addr[2:0]==6) ? 8'b00000011 :
	8'b11111111;

//reg [1:0] status_reg = 0;
reg       old_download;
reg       old_ramreset;
//integer   timeout = 0;

wire boot_index = ioctl_index[5:0] == 0;
wire os_index = (boot_index && (ioctl_index[7:6] == 0)) || ioctl_index[5:0] == 2;
wire cart_index = ioctl_index[5:0] == 1;
wire cdos_index = (boot_index && (ioctl_index[7:6] == 1)) || ioctl_index[5:0] == 3;
wire nvme_index = (boot_index && (ioctl_index[7:6] == 2)) || ioctl_index[5:0] == 4;
wire os_download = ioctl_download && os_index;
wire cart_download = ioctl_download & cart_index;
wire code_download = ioctl_download & &ioctl_index;
wire cdos_download = ioctl_download && cdos_index;
wire nvme_download = ioctl_download && nvme_index;
wire override;
assign ioctl_wait = !cart_wrack;
wire  [7:0] cd_session_count;
wire        cd_toc_wr;
wire        cd_toc_done;
wire  [9:0] cd_toc_addr;
wire [15:0] cd_toc_data;
wire        cd_valid;
wire        cd_sector2448;
wire        audbus_busy;
wire        aud_rd_trig;
wire        lcnt;
wire        clcnt;
reg [22:20] cart_mask;
reg found_cd = 0;
reg bios_overwrote = 0;
reg cd_loaded = 0;
reg old_cmc = 1'b0;

wire cd_mount_prestart = !old_cmc && cd_media_change;
wire cd_mount_start = old_cmc && !cd_media_change;
// reg cd_mount_start_pending = 0;

// Initialize the CD unit's internal EEPROM to erased state once at startup.
// It should persist across disc changes during the session.
reg [5:0] eep_clear = 6'd0;
wire eep_clearing = |eep_clear;

reg vga_field = 0;
always @(posedge clk_sys) begin
	reg old_vsync = 0;
	old_vsync <= vga_vs;
	if (interlaced) begin
		if (old_vsync && !vga_vs) begin
			vga_field <= ~vga_field;
		end
	end else begin
		vga_field <= 0;
	end
end

always @(posedge clk_sys) begin
	old_cmc <= cd_media_change;

	if (nvme_download)
		memtrak_bios_exists <= 1;

	if (|eep_clear)
		eep_clear <= eep_clear - 1'b1;

	if (cd_mount_prestart) begin
		cd_loaded <= 1;
		// cd_mount_start_pending <= 1;
		cart_mask <= '0;
		loader_addr <= 32'h0000_0000;
		// if (~eeprom_save_enabled)
		// 	eep_clear <= 6'b111111;
	end

	// if (cd_mount_start) begin
	// 	cd_mount_start_pending <= 0;
	// end

	if (reset && !ioctl_download) begin
	//	ioctl_wait <= 0;
	//	status_reg <= 0;
		old_download <= 0;
	//	timeout <= 0;
		loader_wr <= 0;
		loader_en <= 0;
		loader_addr <= 32'h0000_0000;
		// mismatch <= 0;
	end else begin
		old_download <= ioctl_download;

		loader_wr <= 0; // Default!
		old_ramreset <= status[15];

		if (~old_download && ioctl_download && (cart_index || os_index || cdos_index || nvme_index)) begin
			loader_addr <= 32'h0000_0000;   // Force the cart ROM to load at 0x00800000 in DDR for Jag core. (byte address!)
											// (The ROM actually gets written at 0x30800000 in DDR, which is done when load_addr gets assigned to DDRAM_ADDR below).
			loader_en <= 1;
	//		status_reg <= 0;
	//		ioctl_wait <= 0;
	//		timeout <= 3000000;
			if (cdos_index) begin
				found_cd <= 1;
			end
		end
		if (old_download && ~ioctl_download && cart_index) begin
			cd_loaded <= 0;
			cart_mask[22:20] = 3'h7; //not exact=don't modify
			if (loader_addr[19:0]==20'h0) begin
				if (loader_addr[24:20]==5'h1) begin
					cart_mask[22:20] = 3'h0; // 1MB
				end else if (loader_addr[24:20]==5'h2) begin
					cart_mask[22:20] = 3'h1; // 2MB
				end else if (loader_addr[24:20]==5'h4) begin
					cart_mask[22:20] = 3'h3; // 4MB
				end
			end
			if (loader_addr[23:0]==24'hFE0000) begin //technically should check next address
	//			bios_overwrote <= 1;
			end
		end
		if (loader_wr) loader_addr <= loader_addr + 2'd2; // Writing a 16-bit WORD at a time!

	//	if (ioctl_wr && (cart_index || aud_index)) begin
		if (ioctl_wr && (cart_index || os_index || cdos_index || nvme_index)) begin
			loader_wr <= 1;
		end
	//	else if (cart_wrack) ioctl_wait <= 1'b0;

	/*
		if(ioctl_wait && !loader_wr) begin
			if(cnt) begin
				cnt <= cnt - 1'd1;
				loader_wr <= 1;
			end
			else if(timeout) timeout <= timeout - 1;
			else {status_reg,ioctl_wait} <= 0;
		end
	*/

		if(old_download && ~ioctl_download) begin
			loader_en <= 0;
	//		ioctl_wait <= 0;
		end
	//	if (RESET) ioctl_wait <= 0;

		if (loader_wr)	begin
			// if (be_save[6] && loader_save != DDRAM_DOUT[63:48]) begin
			// 	mismatch <= 1;
			// end
			// if (be_save[4] && loader_save != DDRAM_DOUT[47:32]) begin
			// 	mismatch <= 1;
			// end
			// if (be_save[2] && loader_save != DDRAM_DOUT[31:16]) begin
			// 	mismatch <= 1;
			// end
			// if (be_save[0] && loader_save != DDRAM_DOUT[15:0]) begin
			// 	mismatch <= 1;
			// end
			loader_save <= loader_data_bs;
			be_save <= loader_be;
		end
	end
end

wire reset = RESET | status[0] | buttons[1] | status[15] | cd_stream_reset;

wire xresetlp = !(reset | os_download | cart_download | cdos_download | nvme_download);
wire sdram_xresetlp = !(reset | os_download | cart_download | cdos_download | nvme_download);
wire xresetl = xresetlp && !(|bootcopy);
reg [18:0] bootcopy; // 128k_bios+256k_cdbios+128k_nvbios == 512k
wire [9:0] dram_a;
wire dram_ras_n;
wire dram_cas_n;
wire [3:0] dram_oe_n;
wire [3:0] dram_uw_n;
wire [3:0] dram_lw_n;
wire [63:0] dram_d;
// wire ch1_ready;
`ifdef MISTER_DUAL_SDRAM
wire ch1_64 = status[16];
// wire hide_64 = 0;
//`define FAST_SDRAM
`else
wire ch1_64 = 1;
wire hide_64 = 1;
`define FAST_SDRAM
`endif
// From SDRAM to the core.
wire [63:0] dram_q = ch1_64 ? use_fastram ? {fastram[63:32], ch1_dout[31:0]} : ch1_dout[63:0] : {ch1_dout2[63:32], ch1_dout[31:0]};

wire [23:0] abus_out;
wire [29:0] audbus_out;
wire [7:0] os_rom_q;

wire hblank;
wire vblank;
wire vga_hs;
wire vga_vs;
wire vid_ce;
wire ar_vsync = vga_vs;

wire [7:0] vga_r;
wire [7:0] vga_g;
wire [7:0] vga_b;

auto_crt_ar auto_crt_ar
(
	.clk_sys(clk_sys),
	.reset(reset),
	.ce_pix(vid_ce),
	.ntsc(ntsc),
	.hsync(vga_hs),
	.vsync(ar_vsync),
	.hblank(hblank),
	.vblank(vblank),
	.arx(auto_video_arx),
	.ary(auto_video_ary)
);

// reg os_ce_n_1 = 1;
wire os_ce_n;
// wire os_ce_n_falling = (os_ce_n_1 && !os_ce_n);
// reg cart_ce_n_1 = 1;
wire cart_ce_n;
wire [31:0] cart_q;
// wire cart_ce_n_falling = (cart_ce_n_1 && !cart_ce_n);

wire xwaitl;
wire startcas;

wire [15:0] aud_16_l;
wire [15:0] aud_16_r;

wire ser_data_in;
wire ser_data_out;
assign ser_data_in = USER_IN[2];
assign USER_OUT[1] = ser_data_out;

wire m68k_clk;
wire [23:1] m68k_addr;
wire [15:0] m68k_bus_do;

wire max_compat = !status[30];
wire gamedrive_enable = max_compat;

wire patch_checksums = status[2] || max_compat;

wire cd_drive_en = cd_loaded || status[52];
wire cd_inserted = (cd_drive_en);
wire cd_latency_en = !status[82];

wire cd_stream_reset = cd_drive_en && cd_media_change;

reg memtrak_bios_exists = 0;

//	"P1O[88:87],Fixed w/Crop,Fixed,Active,Original;",

wire active_video = !status[87];
wire interlaced;

jaguar jaguar_inst
(
	.xresetl_in( xresetl ) ,	// input  xresetl
	.cold_reset( ioctl_download ), // power cycle
	.sys_clk( clk_sys ) ,		// input  clk_sys

	.dram_a( dram_a ) ,			// output [9:0] dram_a
	.dram_ras_n( dram_ras_n ) ,// output  dram_ras_n
	.dram_cas_n( dram_cas_n ) ,// output  dram_cas_n
	.dram_oe_n( dram_oe_n ) ,	// output [3:0] dram_oe_n
	.dram_uw_n( dram_uw_n ) ,	// output [3:0] dram_uw_n
	.dram_lw_n( dram_lw_n ) ,	// output [3:0] dram_lw_n
	.dram_d( dram_d ) ,			// output [63:0] dram_d
	.dram_q( dram_q ) ,			// input [63:0] dram_q
	.dram_oe( dram_oe ) ,		// input [3:0] dram_oe
	.dram_be( dram_be ),
//	.dram_startwe( dram_startwe ),
	.dram_startwep( dram_startwep ),
	.dram_addr( dram_address ),
	.dram_addrp( dram_addressp ),
	.dram_go_rd( dram_go_rd ),


	.ram_rdy( ram_rdy ) ,		// input  ram_rdy

	.abus_out( abus_out ) ,			// output [23:0] Main Address bus for Tom/Jerry/68K/BIOS/CART.
	.os_rom_ce_n( os_ce_n ) ,	// output  os_ce_n
	.os_rom_q( os_rom_q ) ,			// input [7:0] os_rom_q

	.cart_ce_n( cart_ce_n ) ,	// output  cart_ce_n
	.cart_q( cart_q ) ,			// input [31:0] cart_q

	.cart_bram_addr( cart_bram_addr ),
	.cart_bram_data( cart_bram_data ),
	.cart_bram_q( cart_bram_q ),
	.cart_bram_wr( cart_bram_wr ),
	.cd_bram_addr( cd_bram_addr ),
	.cd_bram_data( cd_bram_data ),
	.cd_bram_q( cd_bram_q ),
	.cd_bram_wr( cd_bram_wr ),

	.vga_vs( vga_vs ) ,	// output  vga_vs
	.vga_hs( vga_hs ) ,	// output  vga_hs
	.vga_r( vga_r ) ,			// output [7:0] vga_r
	.vga_g( vga_g ) ,			// output [7:0] vga_g
	.vga_b( vga_b ) ,			// output [7:0] vga_b
	.active_video(active_video),

	.hblank( hblank ) ,		// output hblank
	.vblank( vblank ) ,		// output vblank
	.interlaced (interlaced ) ,	// output interlaced

	.aud_16_l( aud_16_l ) ,		// output  [15:0] aud_16_l
	.aud_16_r( aud_16_r ) ,		// output  [15:0] aud_16_r

	.xwaitl( 1'b1 ) ,

	.vid_ce( vid_ce ) ,

	.joystick_0( joystick_0_mux ) ,
	.joystick_1( {joystick_p2[31:9], joystick_p2[8]|p1p2pause_active,joystick_p2[7:0]} ) ,
	.joystick_2( {joystick_2[31:9], joystick_2[8]|p1p2pause_active,joystick_2[7:0]} ) ,
	.joystick_3( {joystick_3[31:9], joystick_3[8]|p1p2pause_active,joystick_3[7:0]} ) ,
	.joystick_4( {joystick_4[31:9], joystick_4[8]|p1p2pause_active,joystick_4[7:0]} ) ,
	.analog_0( $signed(analog_p1_l[7:0]) + 9'sd127 ),
	.analog_1( $signed(analog_p1_l[15:8]) + 9'sd127 ),
	.analog_2( $signed(analog_p2_l[7:0]) + 9'sd127 ),
	.analog_3( $signed(analog_p2_l[15:8]) + 9'sd127 ),
	.spinner_0(spinner_p1),
	.spinner_1(spinner_p2),
	.spinner_speed(status[21:20]),
	.team_tap_port1( status[33:32]==1 ),
	.team_tap_port2( status[33:32]==2 ),
	.lightgun_mode( lightgun_mode ),
	.lightgun_crosshair( status[43:42] ),

	.startcas( startcas ) ,

	.turbo( 0),//status[3] ) ,
	.vintbugfix( max_compat ),
	.olpbugfix( max_compat ),
	.cd_en( cd_drive_en ),
	.cd_ex( cd_inserted ),
	.cd_latency_en( cd_latency_en ),
	.b_override(override),
	.maxc(max_compat),
	.auto_eeprom(max_compat),
	.addr_ch3(addr_ch3[23:0]),
	.toc_addr(cd_toc_addr),
	.toc_data(cd_toc_data),
	.toc_wr(cd_toc_wr),
	.toc_done(cd_toc_done),
	.audbus_out( audbus_out ) ,
	.aud_in( cart_q1 ) ,
	.audwaitl( xwaitl ) ,
	.aud_ce(aud_ce),
	.aud_busy(audbus_busy),
	// aud_sess: menu-driven audio-session override into Butch.
  .aud_sess(~status[55]),
	.cdg_in( cdg_in ) ,
	.force_music_cd(status[55]),
	.dohacks(patch_checksums),
	.xvclk_o(xvclk_o),
	.overflow (overflow),
	.underflow (underflow),
	.errflow (errflow),
	.unhandled (unhandled),
	.cd_valid(cd_valid),
	.cd_sector2448(cd_sector2448),
	.ntsc( ntsc ) ,

	.ps2_mouse( ps2_mouse ) ,

	.mouse_ena_1( status[6:5]==1 ) ,
	.mouse_ena_2( status[6:5]==2 ) ,

	.ddreq(1'b1 /*!status[54]*/),
	.comlynx_tx( ser_data_out ) ,
	.comlynx_rx( ser_data_in ) ,

	// cheat engine
	.m68k_clk(m68k_clk),
	.m68k_addr(m68k_addr),
	.m68k_bus_do(m68k_bus_do),
	.m68k_di(m68k_data),
	.gamedrive_enable(gamedrive_enable)

);

wire aud_ce;

reg p1p2pause_active;
reg old_ps2_stb = 0;
reg [20:0] keyboard_joystick = 0;
wire keyboard_joystick_en = status[83];
wire numstick_en = !status[85];
wire swap_p1p2 = status[86];
wire [31:0] joystick_p1 = swap_p1p2 ? joystick_1 : joystick_0;
wire [31:0] joystick_p2 = swap_p1p2 ? joystick_0 : joystick_1;
wire [31:0] joystick_p1_combined = joystick_p1 | (keyboard_joystick_en ? {11'd0, keyboard_joystick} : 32'd0);
wire [15:0] analog_p1_l = swap_p1p2 ? analog_1_l : analog_0_l;
wire [15:0] analog_p1_r = swap_p1p2 ? analog_1_r : analog_0_r;
wire [15:0] analog_p2_l = swap_p1p2 ? analog_0_l : analog_1_l;
// wire [15:0] analog_p2_r = swap_p1p2 ? analog_0_r : analog_1_r;
wire  [8:0] spinner_p1 = swap_p1p2 ? spinner_1 : spinner_0;
wire  [8:0] spinner_p2 = swap_p1p2 ? spinner_0 : spinner_1;
wire [31:0] joystick_0_mux = {
	joystick_p1_combined[31:21],
	(numstick_en ? numstick_keypad : joystick_p1_combined[20:9]),
	(joystick_p1_combined[8] | p1p2pause_active),
	joystick_p1_combined[7:0]
};

always @(posedge clk_sys) begin
  reg status19_old;
  reg [25:0] p1p2pulse;

  status19_old <= status[22];

  p1p2pulse <= p1p2pulse + 26'h1;

  if (~status19_old && status[22]) begin
	p1p2pause_active <= 1;
	p1p2pulse <= 1;
  end


  if (p1p2pulse == 0) begin
	p1p2pause_active <= 0;
  end


end

always @(posedge clk_sys) begin
	old_ps2_stb <= ps2_key[10];

	if(old_ps2_stb != ps2_key[10]) begin
		case (ps2_key[8:0])
			9'h16B: keyboard_joystick[1]  <= ps2_key[9]; // Left
			9'h172: keyboard_joystick[2]  <= ps2_key[9]; // Down
			9'h174: keyboard_joystick[0]  <= ps2_key[9]; // Right
			9'h175: keyboard_joystick[3]  <= ps2_key[9]; // Up
			9'h00D: keyboard_joystick[7]  <= ps2_key[9]; // Tab -> Option
			9'h05A: keyboard_joystick[8]  <= ps2_key[9]; // Enter -> Pause
			9'h01A: keyboard_joystick[4]  <= ps2_key[9]; // Z -> A
			9'h022: keyboard_joystick[5]  <= ps2_key[9]; // X -> B
			9'h021: keyboard_joystick[6]  <= ps2_key[9]; // C -> C
			9'h069: keyboard_joystick[9]  <= ps2_key[9]; // Num 1
			9'h072: keyboard_joystick[10] <= ps2_key[9]; // Num 2
			9'h07A: keyboard_joystick[11] <= ps2_key[9]; // Num 3
			9'h06B: keyboard_joystick[12] <= ps2_key[9]; // Num 4
			9'h073: keyboard_joystick[13] <= ps2_key[9]; // Num 5
			9'h074: keyboard_joystick[14] <= ps2_key[9]; // Num 6
			9'h06C: keyboard_joystick[15] <= ps2_key[9]; // Num 7
			9'h075: keyboard_joystick[16] <= ps2_key[9]; // Num 8
			9'h07D: keyboard_joystick[17] <= ps2_key[9]; // Num 9
			9'h070: keyboard_joystick[18] <= ps2_key[9]; // Num 0
			9'h07C: keyboard_joystick[19] <= ps2_key[9]; // Num *
			9'h079: keyboard_joystick[20] <= ps2_key[9]; // Num +
			default: ;
		endcase
	end
end

assign CLK_VIDEO = clk_sys;

//assign VGA_SL = {~interlace,~interlace} & sl[1:0];

reg crop;
reg [13:0] hcount;

wire [7:0] base_video_r = crop ? 8'h00 : vga_r;
wire [7:0] base_video_g = crop ? 8'h00 : vga_g;
wire [7:0] base_video_b = crop ? 8'h00 : vga_b;
wire [7:0] mix_video_r;
wire [7:0] mix_video_g;
wire [7:0] mix_video_b;

numstick numstick_inst
(
	.clk_sys(clk_sys),
	.ce_pix(vid_ce),
	.reset(reset),
	.enable(numstick_en),
	.hblank(hblank),
	.vblank(vblank),
	.in_r(base_video_r),
	.in_g(base_video_g),
	.in_b(base_video_b),
	.stick_l_x($signed(analog_p1_l[7:0])),
	.stick_l_y($signed(analog_p1_l[15:8])),
	.stick_r_x($signed(analog_p1_r[7:0])),
	.stick_r_y($signed(analog_p1_r[15:8])),
	.keypad_press(numstick_keypad),
	.out_r(mix_video_r),
	.out_g(mix_video_g),
	.out_b(mix_video_b)
);

video_mixer #(.LINE_LENGTH(800), .HALF_DEPTH(0), .GAMMA(1)) video_mixer
(
	.CLK_VIDEO(CLK_VIDEO),      // input clk_sys
	.ce_pix( vid_ce ),          // input ce_pix

	.HDMI_FREEZE(0),
	.freeze_sync(),

	.scandoubler(scale || forced_scandoubler),

	.hq2x(scale==1),

	.gamma_bus(gamma_bus),

	.R(mix_video_r),                  // Input [DW:0] R (set by HALF_DEPTH. is [7:0] here).
	.G(mix_video_g),                  // Input [DW:0] G (set by HALF_DEPTH. is [7:0] here).
	.B(mix_video_b),                  // Input [DW:0] B (set by HALF_DEPTH. is [7:0] here).

	// Positive pulses.
	.HSync(vga_hs),           // input HSync
	.VSync(ar_vsync),           // input VSync
	.HBlank(hblank),            // input HBlank
	.VBlank(vblank),            // input VBlank

	.VGA_R( VGA_R ),         // output [7:0] VGA_R
	.VGA_G( VGA_G ),         // output [7:0] VGA_G
	.VGA_B( VGA_B ),         // output [7:0] VGA_B
	.VGA_VS( VGA_VS ),       // output VGA_VS
	.VGA_HS( VGA_HS ),       // output VGA_HS
	.VGA_DE( VGA_DE ),          // output VGA_DE
	.CE_PIXEL(CE_PIXEL)
);

// always @(posedge clk_sys)
// if (reset) begin
// 	 hcount <= 0;
// end else begin
// 	hcount <= hcount + 14'd1;
//    if (hblank) begin
// 		hcount <= 0;
// 	end
//    if (hcount == ((status[18] ? 14'd1394 : 14'd1365)<<2)) begin // 1394 works well for NBA Jam and Flip Out; 1365 for Primal Rage
// 		crop <= 1;
// 	end
//    if (hcount == ((status[18] ? 14'd45 : 14'd84)<<2)) begin  // 45 works well for NBA Jam and Flip Out; 84 for Primal Rage
// 		crop <= 0;
// 	end
//    if (status[19:18]==2'b00) begin
// 		crop <= 0;
// 	end
// end

// assign VGA_R = vga_r;
// assign VGA_G = vga_g;
// assign VGA_B = vga_b;
// assign VGA_VS = vga_vs;
// assign VGA_HS = vga_hs;
// assign VGA_DE = hblank & vblank;
// assign CE_PIXEL = vid_ce;

wire aud_l_pwm;
wire aud_r_pwm;

assign AUDIO_S = 1;
assign AUDIO_MIX = 0;
assign AUDIO_L = aud_16_l;
assign AUDIO_R = aud_16_r;

// Legacy cart/loader DDRAM path. Streamed CD data bypasses DDRAM and drives
// cart_q1 directly from cd_stream_q while a disc image is mounted.
assign DDRAM_CLK = clk_sys;
wire [28:3] premixed_addr = loader_en ? boot_addr[28:3] : audbus_out[28:3];
wire [28:3] boot_addr;
assign boot_addr[28:20] = (os_index) ? 9'h1FF : (cdos_index) ? 9'h1FE : 9'h1FC; //nvme_index = default
//assign boot_addr[28:20] = (os_index) ? 9'h01F : (cdos_index) ? 9'h01E : 9'h01D; //nvme_index = default
assign boot_addr[19:3] = audbus_out[19:3];

// Byteswap...
//
// Needs this when loading the ROM on MiSTer, at least under Verilator simulation. ElectronAsh.
//
wire [15:0] loader_data_bs = {loader_data[7:0], loader_data[15:8]};
wire [28:0] legacy_ddram_addr = {3'h1,~premixed_addr[28:23],premixed_addr[22:3]};
wire        legacy_ddram_rd = (loader_en) ? 1'b0 : (!jagcd_on_cart_bus && aud_rd_trig);
wire        legacy_ddram_we = (loader_en) ? loader_wr && (os_index || cdos_index || nvme_index): 1'b0;
wire [63:0] legacy_ddram_din = {loader_data_bs, loader_data_bs, loader_data_bs, loader_data_bs};
wire  [7:0] legacy_ddram_be = (loader_en) ? loader_be : 8'b11111111;	// IIRC, the DDR controller needs the byte enables to be High during READS! ElectronAsh.
assign DDRAM_BURSTCNT = 8'd1;
assign DDRAM_ADDR = legacy_ddram_addr;
assign DDRAM_RD = legacy_ddram_rd;
assign DDRAM_WE = legacy_ddram_we;
assign DDRAM_DIN = legacy_ddram_din;
assign DDRAM_BE = legacy_ddram_be;

//wire cart_wrack = 1'b1;	// TESTING!!
reg [15:0] loader_save;
// reg mismatch;
reg [7:0] be_save;
reg [23:0] old_abus_out;
wire overflow;
wire underflow;
wire errflow;
wire unhandled;
wire [63:0] cd_stream_q;

always @(posedge clk_sys) begin
	if (reset) begin
		old_abus_out <= 24'h112233;
	end else begin
		old_abus_out <= abus_out;
	end
end

// Keep the top level focused on bus selection and reset policy. All CD image
// caching, parsing, TOC synthesis, and stream refill logic now lives in
// rtl/cd_stream.sv.
jaguar_cd_stream cd_stream_inst
(
	.clk_sys(clk_sys),
	// Keep the mounted CD image/cache alive across menu soft resets. A menu reset
	// should reset the emulated console, not force the streamed disc to vanish
	// until cd_media_change toggles again. Reserve the stream reset for the
	// framework-level reset input only.
	.reset(RESET || cd_mount_prestart),
	.bk_int(bk_int),
	.audbus_out(audbus_out),
	.aud_ce(aud_ce),
	.cd_stream_start(cd_mount_start),
	.img_size(img_size),
	.cd_hps_ack(cd_hps_ack),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_wr(sd_buff_wr),
	.cd_hps_lba(cd_hps_lba),
	.cd_hps_req(cd_hps_req),
	.jagcd_on_cart_bus(jagcd_on_cart_bus),
	.cd_session_count(cd_session_count),
	.cd_toc_wr(cd_toc_wr),
	.cd_toc_done(cd_toc_done),
	.cd_toc_addr(cd_toc_addr),
	.cd_toc_data(cd_toc_data),
	.cd_valid(cd_valid),
	.cd_sector2448(cd_sector2448),
	.audbus_busy(audbus_busy),
	.xwaitl(xwaitl),
	.aud_rd_trig(aud_rd_trig),
	.lcnt(lcnt),
	.clcnt(clcnt),
	.stream_q(cd_stream_q)
);

// 32-bit cart mode...
assign cart_q1 = jagcd_on_cart_bus ? cd_stream_q : {DDRAM_DOUT[31:00],DDRAM_DOUT[63:32]};

wire [3:0] dram_oe = (~dram_cas_n) ? ~dram_oe_n[3:0] : 4'b0000;
wire ram_rdy = ~ch1_64 || ~ch1_req || use_fastram;// && (ch1_ready);	// Latency kludge.
wire d3a;
wire d3b;

// From the core into SDRAM.
wire ram_read_req = (dram_oe_n != 4'b1111); // The use of "startcas" lets us get a bit lower latency for READ requests. (dram_oe_n bits only asserted for reads? - confirm!")
wire ram_write_req = ({dram_uw_n, dram_lw_n} != 8'b11111111);	// Can (currently) only tell a WRITE request when any of the dram byte enables are asserted.

wire ch1_rnw = !ram_write_req;
// wire ram_reread = (dram_addr_old == {1'b1,dram_addressp[10:3]}); // Possible speed improvement for single ram here

wire ch1_reqr = dram_go_rd;// && !ram_reread;// Latency kludge. (ensure ch1_req only pulses for ONE clock cycle.)
//wire ch1_reqr = startcas && ~old_startcas && !dram_startwe;// && !ram_reread;// Latency kludge. (ensure ch1_req only pulses for ONE clock cycle.)
wire ch1_req = dram_cas_edge && ~dram_ras_n && !ram_write_req;// && !ram_reread;// Latency kludge. (ensure ch1_req only pulses for ONE clock cycle.)
//wire ch1_reqr = dram_cas_edge && ~dram_ras_n && !ram_write_req && !ram_reread;// Latency kludge. (ensure ch1_req only pulses for ONE clock cycle.)
wire ch1_reqw = dram_cas_edge && ~dram_ras_n && ram_write_req;// Latency kludge. (ensure ch1_req only pulses for ONE clock cycle.)
//wire ch1_req = dram_read_edge || dram_write_edge || (ram_read_req && dram_cas_nedge);// Latency kludge. (ensure ch1_req only pulses for ONE clock cycle.)
wire ch1_ref = dram_cas_edge && dram_ras_n;// Latency kludge. (ensure ch1_req only pulses for ONE clock cycle.)
wire ch1_act = dram_ras_edge && dram_cas_n;// Latency kludge. (ensure ch1_req only pulses for ONE clock cycle.)
wire ch1_pch = dram_ras_nedge && dram_cas_n;// Latency kludge. (ensure ch1_req only pulses for ONE clock cycle.)

wire [63:0] ch1_din = dram_d;	// Write data, from core to SDRAM.

//wire dram_startwe;
wire dram_startwep;
wire dram_go_rd;
wire [7:0] dram_be;
wire [23:0] dram_address;
wire [10:3] dram_addressp;
//wire [7:0] ch1_be = ~dram_be[7:0];
wire [7:0] ch1_be = ~{
	dram_uw_n[3], dram_lw_n[3], // Byte Enable bits from the core to SDRAM.
	dram_uw_n[2], dram_lw_n[2], // (Note the 16-bit upper/lower interleaving, due to the 16-bit DRAM chips used on the Jag.)
	dram_uw_n[1], dram_lw_n[1],
	dram_uw_n[0], dram_lw_n[0]
};

wire [63:0] ch1_dout;	// Read data, TO the core.
wire [63:0] ch1_dout2;	// Read data, TO the core.
reg [9:0] ras_latch;
reg old_cas_n;
reg old_ram_read_req;
// reg old_ram_write_req;
// reg old_startcas;

wire dram_cas_edge = old_cas_n && ~dram_cas_n;
wire dram_ras_edge = old_ras_n && ~dram_ras_n;
wire dram_ras_nedge = ~old_ras_n && dram_ras_n;
// wire dram_cas_nedge = ~old_cas_n && dram_cas_n;
// wire dram_read_edge = ram_read_req && ~old_ram_read_req;
// wire dram_write_edge = ram_write_req && ~old_ram_write_req;

// wire [19:0] dram_addr = {ras_latch, dram_a};//abus_out[22:3];//{ras_latch, dram_a};
// reg [11:3] dram_addr_old;
wire ch1a_ready, ch1b_ready;

// assign ch1_ready = ch1a_ready || ch1b_ready;

wire [63:0] cart_q1;
wire [63:0] cdg_in = cd_stream_q;
wire cart_wrack;// = 1'b1;	// TESTING!!
assign cart_wrack = sdram_ch2_ready;
reg cart_diff;

//32'h04040404; // 32 bit
//32'h02020202; // 16 bit
//32'h00000000; // 8 bit
reg [1:0] cart_b = 0;
reg [1:0] bios_b = 0;
reg [1:0] nvme_b = 0;
reg [1:0] addr_b = 0;
reg bios_m = 0;
always @(posedge clk_sys)
begin
	if (cart_rd_trig || memtrack_rd_trig)
			addr_b[1:0] <= abus_out[1:0];

	if (loader_addr[23:1]==22'h0009B7 && loader_en && loader_wr && os_index) //136e/2=9b7
		if (loader_data_bs[15:8]==8'h67)
			bios_m <= 1'b0;
	if (loader_addr[23:1]==22'h000CE3 && loader_en && loader_wr && os_index) //19c6/2=ce3
		if (loader_data_bs[15:8]==8'h67)
			bios_m <= 1'b1;

	if (loader_addr[23:1]==22'h000200 && loader_en && loader_wr && cart_index)
		if (loader_data_bs[15:0]==16'h0202)
			cart_b[1:0] <= 2'b01;
		else if (loader_data_bs[15:0]==16'h0000)
			cart_b[1:0] <= 2'b10;
		else
			cart_b[1:0] <= 2'b00;
	if (loader_addr[23:1]==22'h000201 && loader_en && loader_wr && cart_index)
		if (loader_data_bs[15:0]==16'h0202 && cart_b[1:0]==2'b01)
			cart_b[1:0] <= 2'b01;
		else if (loader_data_bs[15:0]==16'h0000 && cart_b[1:0]==2'b10)
			cart_b[1:0] <= 2'b10;
		else
			cart_b[1:0] <= 2'b00;
	if (loader_addr[23:1]==22'h000200 && loader_en && loader_wr && cdos_index)
		if (loader_data_bs[15:0]==16'h0202)
			bios_b[1:0] <= 2'b01;
		else if (loader_data_bs[15:0]==16'h0000)
			bios_b[1:0] <= 2'b10;
		else
			bios_b[1:0] <= 2'b00;
	if (loader_addr[23:1]==22'h000201 && loader_en && loader_wr && cdos_index)
		if (loader_data_bs[15:0]==16'h0202 && bios_b[1:0]==2'b01)
			bios_b[1:0] <= 2'b01;
		else if (loader_data_bs[15:0]==16'h0000 && bios_b[1:0]==2'b10)
			bios_b[1:0] <= 2'b10;
		else
			bios_b[1:0] <= 2'b00;
	if (loader_addr[23:1]==22'h000200 && loader_en && loader_wr && nvme_index)
		if (loader_data_bs[15:0]==16'h0202)
			nvme_b[1:0] <= 2'b01;
		else if (loader_data_bs[15:0]==16'h0000)
			nvme_b[1:0] <= 2'b10;
		else
			nvme_b[1:0] <= 2'b00;
	if (loader_addr[23:1]==22'h000201 && loader_en && loader_wr && nvme_index)
		if (loader_data_bs[15:0]==16'h0202 && nvme_b[1:0]==2'b01)
			nvme_b[1:0] <= 2'b01;
		else if (loader_data_bs[15:0]==16'h0000 && nvme_b[1:0]==2'b10)
			nvme_b[1:0] <= 2'b10;
		else
			nvme_b[1:0] <= 2'b00;
end

wire [23:0] addr_ch3;
wire [3:0] use_b;
// The 0x900000-0x91FFFF Memory Track backing RAM is a 16-bit data window even
// though the nvram.rom cart image itself is tagged as 8-bit in its loader
// header. Using nvme_b for memtrack_ram reads makes word accesses get routed
// through the 8-bit cart_q steering path, which duplicates one byte (for
// example A55A -> A5A5 on the low halfword). Keep the cart/probe path on
// nvme_b, but force the local RAM window to the 16-bit steering path.
assign use_b[3:2] = override ? bios_b : memtrack_ram ? 2'b01 : memtrack ? nvme_b : cart_b;
assign use_b[1:0] = addr_b;
assign cart_q[31:16] = cart_qs[31:16];
assign cart_q[15:8] = (use_b[2] && ~use_b[1]) ? cart_qs[31:24] : cart_qs[15:8]; // 16bit high or default
assign cart_q[7:0] = (use_b==4'b1000) ? cart_qs[31:24] // 8 bit
	:(use_b==4'b1001) ? cart_qs[23:16] // 8 bit
	:(use_b==4'b1010) ? cart_qs[15:8]  // 8 bit
	:(use_b==4'b1011) ? cart_qs[7:0]  // 8 bit
	:(use_b==4'b0100) ? cart_qs[23:16] // 16 bit high
	:(use_b==4'b0101) ? cart_qs[23:16] // 16 bit high
	:(use_b==4'b0110) ? cart_qs[7:0] // 16 bit low
	:(use_b==4'b0111) ? cart_qs[7:0] // 16 bit low
	: cart_qs[7:0]; //default 32 bit

//wire [1:0] romwidth = status[5:4];
//wire [1:0] romwidth = 2'd2;

//wire os_rom_ce_n;
//wire os_rom_oe_n;
//wire os_rom_oe = (~os_rom_ce_n & ~os_rom_oe_n);	// os_rom_oe feeds back TO the core, to enable the internal drivers.

wire [16:0] os_rom_addr = (os_download) ? {ioctl_addr[16:1],os_lsb} : abus_out[16:0];
//wire [16:0] os_rom_addr = (nvme_download) ? {ioctl_addr[16:1],os_lsb} : o_abus_out[16:0];
// reg [16:0] o_abus_out;

wire [7:0] os_rom_din = (!os_lsb) ? ioctl_data[7:0] : ioctl_data[15:8];

reg os_wren;
wire [7:0] os_rom_dout;

//assign os_rom_q = (abus_out[16:0]==17'h0136E && patch_checksums) ? 8'h60 : os_rom_dout; // Patch the BEQ instruction to a BRA, to skip the cart checksum fail.
assign os_rom_q = (((abus_out[16:0]==17'h0136E && !bios_m) || (abus_out[16:0]==17'h019C6 && bios_m)) && patch_checksums) ? 8'h60 : bios_overwrote ? fastram2[8*(3-abus_out[1:0]) +:8] : cart_qsc[8*(3-abus_out[1:0]) +:8]; // Patch the BEQ instruction to a BRA, to skip the cart checksum fail.
// kbios 136e
// mbios 19c6
// 67->60 = beq->bra

reg os_lsb = 1;
always @(posedge clk_sys) begin
	os_wren <= 1'b0;

	if (os_download && ioctl_wr) begin
//	if (nvme_download && ioctl_wr) begin
		os_wren <= 1'b1;
		os_lsb <= 1'b0;
	end
	else if (!os_lsb) begin
		os_wren <= 1'b1;
		os_lsb <= 1'b1;
	end
	// if (abus_out[23:20]==4'h8) begin
	// 	o_abus_out[16:0] <= abus_out[16:0];
	// end
end

//`define FAST_SDRAM
`ifdef FAST_SDRAM
reg [7:0] cas_latch;
wire [17:0] sdram_addr;
assign sdram_addr[17:8] = ras_latch[9:0];
assign sdram_addr[7:0] = cas_latch[7:0];
wire [63:32] fastram0;
wire [63:32] fastram1;
wire [63:32] fastram2;
wire cache0 = sdram_addr[17:15] == status[36:34];
wire cache1 = !memtrack && (sdram_addr[17:15] == (status[39:37] ^ 3'b111));
wire cache2 = sdram_addr[17:15] == (status[36:34] ^ 3'b001);
wire [3:0] wr0 = {4{fastram_w & cache0}} & ch1_be[7:4];
wire [3:0] wr1 = {4{fastram_w & cache1}} & ch1_be[7:4];
wire [3:0] wr2 = {4{fastram_w & cache2}} & ch1_be[7:4];
assign fastram[63:32] = cache1 ? fastram1[63:32] : cache2 ? fastram2[63:32] : fastram0[63:32];
wire use_fastram = (cache0 || cache1 || cache2); // 256K = 1/4 of address coverage
wire [63:32] fastram;
reg fastram_w;
reg old_ch1_reqw;
always @(posedge clk_ram)
begin
	fastram_w <= 0;
	old_ch1_reqw <= ch1_reqw;
	if (ch1_reqr)
		cas_latch <= dram_addressp[10:3];
	if (ch1_reqw)
		cas_latch <= dram_a[7:0];
	if (old_ch1_reqw && use_fastram)
		fastram_w <= 1;
end

spram_byte_32x15 fastcache0
(
	.clk   ( clk_sys ),
	.addr  ( sdram_addr[14:0] ),
	.din   ( ch1_din[63:32] ),
	.wr    ( wr0 ),
	.dout  ( fastram0[63:32] )
);

spram_byte_32x15 fastcache1_sdram
(
	.clk        ( clk_sys ),
	.addr       ( sdram_addr[14:0] ),
	.din        ( ch1_din[63:32] ),
	.wr         ( memtrack ? 4'b0000 : wr1 ),
	.dout       ( fastram1[63:32] ),
	.addr_b     ( 15'd0 ),
	.din_b      ( 32'd0 ),
	.wr_b       ( 4'd0 ),
	.dout_b     ( ),
	.use_16_bit ( memtrack ),
	.addr_16    ( memtrack_fastcache_addr ),
	.dout_16    ( memtrack_fastcache_q16 ),
	.din_16     ( dram_d[15:0] ),
	.wr_16      ( memtrack_wr_valid ? memtrack_wr_be : 2'b00 ),
	.addr_b_16  ( memtrack_hps_addr ),
	.dout_b_16  ( memtrack_hps_q16 ),
	.din_b_16   ( sd_buff_dout ),
	.wr_b_16    ( memtrack_fastcache_hps_wr ? 2'b11 : 2'b00 )
);

spram_byte_32x15 fastcache2
(
	.clk   ( clk_sys ),
	.addr  ( use_fastram ? sdram_addr[14:0] : os_rom_addr[16:2]),
	.din   ( use_fastram ? ch1_din[63:32] : {4{os_rom_din[7:0]}} ),
	.wr    ( use_fastram ? wr2 : os_wren ? (4'h1 << os_rom_addr[1:0]) : 4'b0),
	.dout  ( fastram2[63:32] )
);
// Ram for the bios
/*spram #(.addr_width(17), .data_width(8), .mem_name("OS_R")) os_rom_bram_inst
(
	.clock   ( clk_sys ),

	.address ( os_rom_addr ),
	.data    ( os_rom_din ),
	.wren    ( os_wren ),

	.q       ( os_rom_dout )
);
*/
`else
wire use_fastram = 0;
wire [63:32] fastram = 0;
wire [63:32] fastram2;

spram_byte_32x15 fastcache2
(
	.clk   ( clk_sys ),
	.addr  ( os_rom_addr[16:2]),
	.din   ( {4{os_rom_din[7:0]}} ),
	.wr    ( os_wren ? (4'h1 << os_rom_addr[1:0]) : 4'b0),
	.dout  ( fastram2[63:32] )
);
`endif

assign memtrack = (status[56] || cd_loaded) && memtrak_bios_exists;
wire memtrack_wr = memtrack && ram_write_req;
wire memtrack_ram = memtrack && abus_out[23:20]==4'h9;
wire memtrack_wrram = memtrack_wr && memtrack_ram;
//wire memtrack_wro0 = memtrack_wr && abus_out[23:0]==24'h815554;
wire memtrack_wro1 = memtrack_wr && abus_out[23:0]==24'h80AAA8;
wire memtrack_rdo1 = memtrack && !ram_write_req && abus_out[23:0]==24'h80AAA8 && memtrack_override1;
reg memtrack_override1;
wire cart_wr_trig = !cart_ce_n && memtrack_wrram && (!old_memtrack_wrram || abus_out[23:0]!=old_abus_out[23:0]);
wire debug_wrram = memtrack && ram_write_req && abus_out[23:12] == 12'hA00;
wire debug_wr_trig = !cart_ce_n && debug_wrram && (!old_debug_wrram || abus_out[23:0] != old_abus_out[23:0]);
wire memtrack_rd_trig = !cart_ce_n && ram_read_req && memtrack_ram && (!old_ram_read_req || (abus_out != old_abus_out));
wire cart_rd_trig = !cart_ce_n && ram_read_req && !memtrack_ram && (!old_ram_read_req || (abus_out != old_abus_out));
wire os_rd_trig = !os_ce_n && ram_read_req && (!old_ram_read_req || (abus_out != old_abus_out));
reg old_memtrack_wrram;
reg old_debug_wrram;
always @(posedge clk_sys)
begin
	// sequence1 == 815554=00AA, 80AAA8=0055, 815554=0090 override memtrack flash in place of cart rom
	// sequence2 == 815554=00AA, 80AAA8=0055, 815554=00F0 undo memtrack flash in place of cart rom
	// True for non romulator memory track
	// In override reads 800000 for manufacturer id and 800004 for device id
	//cmp.b	#$01,d2		; AMD manufacturer ID == 01
	//bne.b	.notAMD
	//cmp.b	#$20,d3		; check for device == AM29F010
	//cmp.b	#$1f,d2		; AMTEL manufacturer ID == $1f
	//bne.b	.notATMEL
	//cmp.b	#$d5,d3		; check for device == AT29C010
	// Same sequence used for romulator, but it just overwrites the data in 815554 and 80AAA8 and checks 80AAA8
	//; next, check for ROMULATOR
	//move.w	$800000+(4*$2aaa),d0
	//cmp.w	#$0055,d0
	// To avoid having to fix these writes on reboot just override temporarily.
	// Only 80AAA8 is read this way. Actual save data is at 9XXXXXX.

	if (reset) begin
		memtrack_override1 <= 1'b0;
	end else begin
		if (memtrack_wro1 && ch1_be[7:0]==8'h0C && dram_d[15:0]==16'h0055) begin
			memtrack_override1 <= 1'b1;
		end
	end
	old_memtrack_wrram <= memtrack_wrram;
	old_debug_wrram <= debug_wrram;
end
//wire [31:0] cart_qs = memtrack_rdo1 ? 32'h00550055 : cart_qsc;
//wire [31:0] cart_qs = memtrack_rdo1 ? 32'h00550055 : (!os_rd_trig && !override && memtrack && !memtrack_ram) ? {fastram2[39:32],fastram2[47:40],fastram2[55:48],fastram2[63:56]} : cart_qsc;
// The local 0x9xxxxx Memory Track window is fed by the same cart-side 16-bit
// byte-enable mapping used for channel 2. A1 still selects the halfword via
// addr_16[0]; wr_16 should only carry the two byte strobes for that halfword.
wire memtrack_wr_valid = cart_wr_trig && cd_drive_en && memtrack;
assign memtrack_wr_be = abus_out[1] ? ch1_be[1:0] : ch1_be[3:2];
assign memtrack_dirty = memtrack_wr_valid && |memtrack_wr_be;
assign memtrack_fastcache_hps_wr = sd_buff_wr & memtrak_slot_ack;
assign memtrack_fastcache_addr = abus_out[16:1];
wire [15:0] memtrack_wr_data = dram_d[15:0];
assign memtrack_hps_addr = {memtrak_slot_lba[7:0], sd_buff_addr};
assign memtrack_fastcache_q = addr_b[1] ? {16'h0000, memtrack_fastcache_q16} : {memtrack_fastcache_q16, 16'h0000};

`ifndef FAST_SDRAM
// Local memtrack RAM backing store for the full 0x900000-0x91FFFF Romulator window.
spram_byte_32x15 fastcache1
(
	.clk        ( clk_sys ),
	.addr       ( 15'd0 ),
	.din        ( 32'd0 ),
	.wr         ( 4'd0 ),
	.dout       ( ),
	.addr_b     ( 15'd0 ),
	.din_b      ( 32'd0 ),
	.wr_b       ( 4'd0 ),
	.dout_b     ( ),
	.use_16_bit ( 1'b1 ),
	.addr_16    ( memtrack_fastcache_addr ),
	.dout_16    ( memtrack_fastcache_q16 ),
	.din_16     ( memtrack_wr_data ),
	.wr_16      ( memtrack_wr_valid ? memtrack_wr_be : 2'b00 ),
	.addr_b_16  ( memtrack_hps_addr ),
	.dout_b_16  ( memtrack_hps_q16 ),
	.din_b_16   ( sd_buff_dout ),
	.wr_b_16    ( memtrack_fastcache_hps_wr ? 2'b11 : 2'b00 )
);
`endif
wire [31:0] cart_qs = memtrack_rdo1 ? 32'h00550055 : memtrack_ram ? memtrack_fastcache_q : (!os_rd_trig && !override && memtrack && !memtrack_ram) ? {cart_qsc[31:24],cart_qsc[23:16],cart_qsc[15:8],cart_qsc[7:0]} : cart_qsc;
wire [31:0] cart_qsc;
wire [23:1] cart_ch2_addr = (loader_en) ? loader_addr[23:1] | (os_index ? 23'h7F0000 : cdos_index ? 23'h7C0000 : nvme_index ? 23'h7E0000 : 23'h000000) : {1'b0,abus_out[22:20] & cart_mask[22:20],abus_out[19:2],memtrack_wr ? abus_out[1] : 1'b0} | (os_rd_trig ? 23'h7F0000 : override ? 23'h7C0000 : memtrack ? 23'h7E0000 : 23'h000000);
wire        cart_ch2_addr_ext = (loader_en) ? (os_index | cdos_index | nvme_index) : (os_rd_trig | override | memtrack);
wire [15:0] cart_ch2_din = (loader_en) ? loader_data_bs : dram_d[15:0];
wire        cart_ch2_req = (loader_en) ? loader_wr & (cart_index || os_index || cdos_index || nvme_index) : os_rd_trig | cart_rd_trig;
wire        cart_ch2_rnw = (loader_en) ? !loader_wr & (cart_index || os_index || cdos_index || nvme_index) : !memtrack_wrram;
wire  [1:0] cart_ch2_be = (loader_en) ? 2'b11 : abus_out[1] ? ch1_be[1:0] : ch1_be[3:2];
wire        sdram_ch2_ready;
sdram sdram
(
	.init               (~pll_locked || (~old_ramreset && status[15])),

	.clk                (clk_ram),

	.SDRAM_DQ           (SDRAM_DQ),
	.SDRAM_A            (SDRAM_A),
	.SDRAM_DQML         (SDRAM_DQML),
	.SDRAM_DQMH         (SDRAM_DQMH),
	.SDRAM_BA           (SDRAM_BA),
	.SDRAM_nCS          (SDRAM_nCS),
	.SDRAM_nWE          (SDRAM_nWE),
	.SDRAM_nRAS         (SDRAM_nRAS),
	.SDRAM_nCAS         (SDRAM_nCAS),
	.SDRAM_CKE          (SDRAM_CKE),
	.SDRAM_CLK          (SDRAM_CLK),

	// Port 2
	.ch1_addr           (dram_addressp[10:3]),
	.ch1_caddr          ({3'b000, dram_a}),
	.ch1_dout           ({ch1_dout[63:48], ch1_dout[47:32], ch1_dout[31:16], ch1_dout[15:0]}),
	.ch1_din            ({ch1_din[63:48], ch1_din[47:32], ch1_din[31:16], ch1_din[15:0]}),
	.ch1_reqr           (ch1_reqr),
	.ch1_reqw           (ch1_reqw),
	.ch1_ref            (ch1_ref),
	.ch1_act            (ch1_act),
	.ch1_pch            (ch1_pch),
	.ch1_rnw            (ch1_rnw),
	.ch1_be             ({ch1_be[7:6], ch1_be[5:4], ch1_be[3:2], ch1_be[1:0]}),
	.ch1_ready          (ch1a_ready),
	.ch1_64             (ch1_64),

	.ch2_addr           (cart_ch2_addr),    // 24 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations. 23'h7E0000=24'hFC0000
	.ch2_addr_ext       (cart_ch2_addr_ext),    // 24 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations. 23'h7E0000=24'hFC0000
	.ch2_dout           (cart_qsc),            // data output to cpu
	.ch2_din            (cart_ch2_din),     // data input from cpu
	.ch2_req            (cart_ch2_req),     // request
	.ch2_rnw            (cart_ch2_rnw),     // 1 - read, 0 - write
	.ch2_be             (cart_ch2_be), // could probably simplyfiy. code always writes 16 bits so if writing always 2'b11
	.ch2_ready          (sdram_ch2_ready),

	.ch3_addr           (addr_ch3),
	.ch3_dout           (),
	.ch3_din            (32'h0),
	.ch3_req            (1'b1),     // request
	.ch3_rnw            (1'b1),     // 1 - read, 0 - write
	.ch3_ready          (),

	.ram64              (ram64),

	.self_refresh       (loader_en || !sdram_xresetlp)
);

`ifdef MISTER_DUAL_SDRAM
sdram sdram2
(
	.init               (~pll_locked || (~old_ramreset && status[15])),
	.clk                (clk_ram),

	.SDRAM_DQ           (SDRAM2_DQ),
	.SDRAM_A            (SDRAM2_A),
	.SDRAM_DQML         (),
	.SDRAM_DQMH         (),
	.SDRAM_BA           (SDRAM2_BA),
	.SDRAM_nCS          (SDRAM2_nCS),
	.SDRAM_nWE          (SDRAM2_nWE),
	.SDRAM_nRAS         (SDRAM2_nRAS),
	.SDRAM_nCAS         (SDRAM2_nCAS),
	.SDRAM_CKE          (),
	.SDRAM_CLK          (SDRAM2_CLK),

	// Port 2
	.ch1_addr           (dram_addressp[10:3]),
	.ch1_caddr          ({3'b000, dram_a}),
	.ch1_dout           ({ch1_dout2[31:16], ch1_dout2[15:0], ch1_dout2[63:48], ch1_dout2[47:32]}),
	.ch1_din            ({32'h0,ch1_din[63:48], ch1_din[47:32]}),
	.ch1_reqr           (ch1_reqr),
	.ch1_reqw           (ch1_reqw),
	.ch1_ref            (ch1_ref),
	.ch1_act            (ch1_act),
	.ch1_pch            (ch1_pch),
	.ch1_rnw            (ch1_rnw),
	.ch1_be             ({4'h0, ch1_be[7:6], ch1_be[5:4]}),
	.ch1_ready          (ch1b_ready),
	.ch1_64             (0),

	.ch2_addr           ({23'h0}),    // 24 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations.
	.ch2_addr_ext       (0),
	.ch2_dout           (),    // data output to cpu
	.ch2_din            ({16'h0}),     // data input from cpu
	.ch2_req            (0),     // request
	.ch2_rnw            (0),     // 1 - read, 0 - write

	.ch3_addr           (addr_ch3),
	.ch3_dout           (),
	.ch3_din            (32'h0),
	.ch3_req            (1'b1),     // request
	.ch3_rnw            (1'b1),     // 1 - read, 0 - write
	.ch3_ready          (),

	.self_refresh       (loader_en || !sdram_xresetlp)
);
`endif

reg old_ras_n;

always @(posedge clk_ram)
if (reset) begin
	ras_latch <= 10'd0;
	old_cas_n <= 1;
// 	dram_addr_old[11] <= 0;
//	bootcopy <= 19'h7FFFF;
	bootcopy <= 19'h0;
end
else begin
	old_cas_n <= dram_cas_n;
	old_ras_n <= dram_ras_n;
	old_ram_read_req <= ram_read_req;
//  old_ram_write_req <= ram_write_req;
//	old_startcas <= startcas;
	if (old_ras_n && ~dram_ras_n)
		ras_latch <= dram_a;
	// if (ch1_reqr || ch1_reqw || ch1_ref || ch1_act || ch1_pch)
	// 	dram_addr_old <= {ch1_reqr,dram_addressp[10:3]};
	if (|bootcopy)
		bootcopy <= bootcopy - 19'h1;
end

wire        bk_int = 1'b1;
wire [15:0] cart_save_int_dout;
wire [15:0] cd_eeprom_int_dout;
wire [15:0] cd_eeprom_raw_dout;
wire [15:0] save_backram_q_a;
wire [12:0] save_backram_addr_a = {3'b000, cart_bram_addr};
wire [15:0] save_backram_data_a = cart_bram_data;
wire        save_backram_wren_a = cart_bram_wr;
wire [12:0] save_backram_addr_b = {3'b000, sd_lba[1:0], sd_buff_addr};
wire        save_backram_wren_b = sd_buff_wr & sd_ack;

assign cart_save_sd_buff_din = /*status[62] ? db_int_douts : */ cart_save_int_dout;
assign memtrak_save_sd_buff_din = memtrack_hps_q16;
assign eeprom_save_sd_buff_din = cd_eeprom_int_dout;
assign cart_bram_q = save_backram_q_a;

dpram #(13,16) cart_backram
(
	.clock(clk_sys),
   .address_a(save_backram_addr_a),
	.data_a(save_backram_data_a),
	.wren_a(save_backram_wren_a),
	.q_a(save_backram_q_a),

	.address_b(save_backram_addr_b),
	.data_b(sd_buff_dout),
	.wren_b(save_backram_wren_b),
	.q_b(cart_save_int_dout)
);

// Jaguar CD EEPROM is 128 bytes: 64 x 16-bit words.
dpram #(6,16) cd_eeprom_backram
(
	.clock(clk_sys),
	.address_a(eep_clearing ? eep_clear : cd_bram_addr[5:0]),
	.data_a(eep_clearing ? 16'hFFFF : cd_bram_data),
	.wren_a(eep_clearing | cd_bram_wr),
	.q_a(cd_bram_q),

	.address_b(sd_buff_addr[5:0]),
	.data_b(sd_buff_dout),
	.wren_b(sd_buff_wr & eeprom_ack & ~|sd_buff_addr[7:6]),
	.q_b(cd_eeprom_raw_dout)
);

assign cd_eeprom_int_dout = (~|sd_buff_addr[7:6]) ? cd_eeprom_raw_dout : 16'h0000;

wire debug_trig = abus_out[23:12] == 12'hA00 && memtrack;
wire debug_wr = debug_trig && debug_wr_trig;
wire [15:0] debug_q;

spram #(.ADDR_WIDTH(11), .DATA_WIDTH(16), .MEM_NAME("DBG")) debug_rom
(
	.clock(clk_sys),
	.address(abus_out[11:1]),
	.data(dram_d[15:0]),
	.wren(debug_wr),
	.q(debug_q)
);

//`define DEBUG_TOC
`ifdef DEBUG_TOC
wire [15:0] db_int_douts = db_int_dout[(~sd_buff_addr[1:0])*16 +: 16];
wire [63:0] db_int_dout;
reg [7:0] dcas_latch;
wire [17:0] dsdram_addr;
assign dsdram_addr[17:8] = ras_latch[9:0];
assign dsdram_addr[7:0] = dcas_latch[7:0];
wire use_dbgram = (dsdram_addr[17:7] == 11'h00B); // ==002c00-002fff
reg dbgram_w;
reg oldd_ch1_reqw;
always @(posedge clk_ram)
begin
	dbgram_w <= 0;
	oldd_ch1_reqw <= ch1_reqw;
	if (ch1_reqr)
		dcas_latch <= dram_addressp[10:3];
	if (ch1_reqw)
		dcas_latch <= dram_a[7:0];
	if (oldd_ch1_reqw && use_dbgram)
		dbgram_w <= 1;
end
dpram #(8,8) debugram7
(
	.clock(clk_sys),
	.address_a(dsdram_addr[7:0]),
	.data_a(ch1_din[63:56]),
	.wren_a(dbgram_w && ch1_be[7]),
	.q_a(),

	.address_b({sd_lba[1:0],sd_buff_addr[7:2]}),
	.data_b(sd_buff_dout),
	.wren_b(1'b0),
	.q_b(db_int_dout[63:56])
);
dpram #(8,8) debugram6
(
	.clock(clk_sys),
	.address_a(dsdram_addr[7:0]),
	.data_a(ch1_din[55:48]),
	.wren_a(dbgram_w && ch1_be[6]),
	.q_a(),

	.address_b({sd_lba[1:0],sd_buff_addr[7:2]}),
	.data_b(sd_buff_dout),
	.wren_b(1'b0),
	.q_b(db_int_dout[55:48])
);
dpram #(8,8) debugram5
(
	.clock(clk_sys),
	.address_a(dsdram_addr[7:0]),
	.data_a(ch1_din[47:40]),
	.wren_a(dbgram_w && ch1_be[5]),
	.q_a(),

	.address_b({sd_lba[1:0],sd_buff_addr[7:2]}),
	.data_b(sd_buff_dout),
	.wren_b(1'b0),
	.q_b(db_int_dout[47:40])
);
dpram #(8,8) debugram4
(
	.clock(clk_sys),
	.address_a(dsdram_addr[7:0]),
	.data_a(ch1_din[39:32]),
	.wren_a(dbgram_w && ch1_be[4]),
	.q_a(),

	.address_b({sd_lba[1:0],sd_buff_addr[7:2]}),
	.data_b(sd_buff_dout),
	.wren_b(1'b0),
	.q_b(db_int_dout[39:32])
);
dpram #(8,8) debugram3
(
	.clock(clk_sys),
	.address_a(dsdram_addr[7:0]),
	.data_a(ch1_din[31:24]),
	.wren_a(dbgram_w && ch1_be[3]),
	.q_a(),

	.address_b({sd_lba[1:0],sd_buff_addr[7:2]}),
	.data_b(sd_buff_dout),
	.wren_b(1'b0),
	.q_b(db_int_dout[31:24])
);
dpram #(8,8) debugram2
(
	.clock(clk_sys),
	.address_a(dsdram_addr[7:0]),
	.data_a(ch1_din[23:16]),
	.wren_a(dbgram_w && ch1_be[2]),
	.q_a(),

	.address_b({sd_lba[1:0],sd_buff_addr[7:2]}),
	.data_b(sd_buff_dout),
	.wren_b(1'b0),
	.q_b(db_int_dout[23:16])
);
dpram #(8,8) debugram1
(
	.clock(clk_sys),
	.address_a(dsdram_addr[7:0]),
	.data_a(ch1_din[15:8]),
	.wren_a(dbgram_w && ch1_be[1]),
	.q_a(),

	.address_b({sd_lba[1:0],sd_buff_addr[7:2]}),
	.data_b(sd_buff_dout),
	.wren_b(1'b0),
	.q_b(db_int_dout[15:8])
);
dpram #(8,8) debugram0
(
	.clock(clk_sys),
	.address_a(dsdram_addr[7:0]),
	.data_a(ch1_din[7:0]),
	.wren_a(dbgram_w && ch1_be[0]),
	.q_a(),

	.address_b({sd_lba[1:0],sd_buff_addr[7:2]}),
	.data_b(sd_buff_dout),
	.wren_b(1'b0),
	.q_b(db_int_dout[8:0])
);
`else
wire [15:0] db_int_douts = cart_save_int_dout;
wire dbgram_w = 0;
`endif

wire downloading = cart_download;
reg old_downloading = 0;
always @(posedge clk_sys) begin
	old_downloading <= downloading;
end

assign bk_ena = memtrack ? memtrak_save_enabled : cart_save_enabled;
assign save_busy = (memtrack ? memtrak_save_busy : cart_save_busy) | eeprom_save_busy;
assign save_pending = (memtrack ? memtrak_save_pending : cart_save_pending) | eeprom_save_pending;

jaguar_save_slot #(
	.MAX_BLOCKS(4)
) cart_save_slot (
	.clk_sys(clk_sys),
	.invalidate_pulse(!old_downloading && downloading),
	.mount_pulse(img_mounted),
	.mount_readonly(img_readonly),
	.mount_size(img_size),
	.load_req(status[12]),
	.save_req(status[11]),
	.autosave_disable(status[13]),
	.osd_status(OSD_STATUS),
	.dirty_pulse(~memtrack && ~cd_drive_en && (cart_bram_wr /*|| (dbgram_w && status[62])*/)),
	.mounted_writable(cart_save_enabled),
	.pending(cart_save_pending),
	.busy(cart_save_busy),
	.sd_lba(sd_lba),
	.sd_rd(sd_rd),
	.sd_wr(sd_wr),
	.sd_ack(sd_ack)
);

jaguar_save_slot #(
	.MAX_BLOCKS(256)
) memtrak_save_slot (
	.clk_sys(clk_sys),
	.invalidate_pulse(1'b0),
	.mount_pulse(memtrak_save_mount),
	.mount_readonly(img_readonly),
	.mount_size(img_size),
	.load_req(status[12]),
	.save_req(status[11]),
	.autosave_disable(status[13]),
	.osd_status(OSD_STATUS),
	.dirty_pulse(memtrack_dirty),
	.mounted_writable(memtrak_save_enabled),
	.pending(memtrak_save_pending),
	.busy(memtrak_save_busy),
	.sd_lba(memtrak_slot_lba),
	.sd_rd(memtrak_slot_rd),
	.sd_wr(memtrak_slot_wr),
	.sd_ack(memtrak_slot_ack)
);

jaguar_save_slot #(
	.MAX_BLOCKS(1)
) cd_eeprom_save_slot (
	.clk_sys(clk_sys),
	.invalidate_pulse(1'b0),
	.mount_pulse(eeprom_save_mount),
	.mount_readonly(img_readonly),
	.mount_size(img_size),
	.load_req(status[12]),
	.save_req(status[11]),
	.autosave_disable(1'b0),
	.osd_status(OSD_STATUS),
	.dirty_pulse(cd_bram_wr && cd_drive_en),
	.mounted_writable(eeprom_save_enabled),
	.pending(eeprom_save_pending),
	.busy(eeprom_save_busy),
	.sd_lba(eeprom_lba),
	.sd_rd(eeprom_rd),
	.sd_wr(eeprom_wr),
	.sd_ack(eeprom_ack)
);

///////////////////////////////////////////////////
// Cheat codes loading for WIDE IO (16 bit)
reg [128:0] gg_code;
wire        gg_available;

// Code layout:
// {clock bit, code flags,     32'b address, 32'b compare, 32'b replace}
//  128        127:96          95:64         63:32         31:0
// Integer values are in BIG endian byte order, so it up to the loader
// or generator of the code to re-arrange them correctly.

always_ff @(posedge clk_sys) begin
	gg_code[128] <= 1'b0;

	if (code_download & ioctl_wr) begin
		case (ioctl_addr[3:0])
			0:  gg_code[111:96]  <= ioctl_data; // Flags Bottom Word
			2:  gg_code[127:112] <= ioctl_data; // Flags Top Word
			4:  gg_code[79:64]   <= ioctl_data; // Address Bottom Word
			6:  gg_code[95:80]   <= ioctl_data; // Address Top Word
			8:  gg_code[47:32]   <= ioctl_data; // Compare Bottom Word
			10: gg_code[63:48]   <= ioctl_data; // Compare top Word
			12: gg_code[15:0]    <= ioctl_data; // Replace Bottom Word
			14: begin
				gg_code[31:16]   <= ioctl_data; // Replace Top Word
				gg_code[128]     <=  1'b1;      // Clock it in
			end
		endcase
	end
end

reg [15:0] m68k_data;
always @(posedge clk_sys)
	if (m68k_clk) m68k_data <= m68k_genie_data;

wire [15:0] m68k_genie_data;
CODES #(.ADDR_WIDTH(24), .DATA_WIDTH(16), .BIG_ENDIAN(1)) codes_68k
(
	.clk(clk_sys),
	.reset(cart_download | (code_download && ioctl_wr && !ioctl_addr)),
	.enable(~status[23]),
	.code(gg_code),
	.available(gg_available),
	.addr_in({m68k_addr, 1'b0}),
	.data_in(m68k_bus_do),
	.data_out(m68k_genie_data)
);

endmodule
