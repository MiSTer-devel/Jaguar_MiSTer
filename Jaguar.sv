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
assign VGA_F1 = 0;
assign VGA_SCALER = 0;
assign VGA_DISABLE = 0;
assign HDMI_FREEZE = 0;
assign HDMI_BLACKOUT = 0;

assign LED_DISK = 0;
assign LED_POWER = 0;
assign BUTTONS = 0;

assign LED_USER  = ioctl_download | bk_state | bk_pending;

`define FAST_CLOCK

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

assign VIDEO_ARX = (!ar) ? 12'd2776 : (ar - 1'd1);
assign VIDEO_ARY = (!ar) ? 12'd2040 : 12'd0;

// Status Bit Map:
//              Upper                          Lower
// 0         1         2         3          4         5         6
// 01234567890123456789012345678901 23456789012345678901234567890123
// 0123456789ABCDEFGHIJKLMNOPQRSTUV 0123456789ABCDEFGHIJKLMNOPQRSTUV
// X XXXXXXXXXXXXXXXXXXXXX

`include "build_id.v"
localparam CONF_STR = {
	"Jaguar;;",
	"-;",
	"FS1,JAGJ64ROMBIN;",
	"FC2,ROM,Load Bios;",
	"-;",
	"D0RC,Load Backup RAM;",
	"D0RB,Save Backup RAM;",
	"D0OD,Autosave,On,Off;",
	"-;",
	"O4,Region Setting,NTSC,PAL;",
	"O2,Cart Checksum Patch,Off,On;",
	"O78,Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"O9A,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"OI,Crop,No,Yes;",
	"O56,Mouse,Disabled,JoyPort1,JoyPort2;",
	"OE,VSync,vvs,hvs(debug);",
	"-;",
	"O56,Mouse,Disabled,JoyPort1,JoyPort2;",
	"OKL,Spinner Speed,Normal,Faster,Slow,Slower;",
	"RM,P1+P2 Pause;",
	"OH,JagLink,Disabled,Enabled;",
	"-;",
	"O3,CPU Speed,Normal,Turbo;",
	"OJ,Vint Fix,Yes,No;",
	"-;",
	"-Options may crash;",
	"RF,Reset RAM(debug);",
	"D1OG,SDRAM,2,1(debug);",
	"-;",
	"R0,Reset;",
	"J1,A,B,C,Option,Pause,1,2,3,4,5,6,7,8,9,0,Star,Hash;",
	"jn,Y,B,A,Select,Start;",
	"jp,Y,B,A,Select,Start;",
	"-;",
	"V,v",`BUILD_DATE
};

wire [63:0] status;
wire  [1:0] buttons;
wire [31:0] joystick_0;
wire [31:0] joystick_1;
wire        ioctl_download;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [15:0] ioctl_data;
wire  [7:0] ioctl_index;
//reg         ioctl_wait;
wire        ioctl_wait;
reg  [31:0] sd_lba;
reg         sd_rd = 0;
reg         sd_wr = 0;
wire        sd_ack;
wire  [7:0] sd_buff_addr;
wire [15:0] sd_buff_dout;
wire [15:0] sd_buff_din;
wire        sd_buff_wr;
wire        img_mounted;
wire        img_readonly;
wire [63:0] img_size;
wire        forced_scandoubler;
wire [10:0] ps2_key;
wire [24:0] ps2_mouse;
wire [21:0] gamma_bus;
wire [15:0] sdram_sz;
wire [15:0] analog_0;
wire [15:0] analog_1;
wire [8:0]  spinner_0;
wire [8:0]  spinner_1;

wire ram64;

hps_io #(.CONF_STR(CONF_STR), .PS2DIV(1000), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),

	.buttons(buttons),
	.status(status),

	.sdram_sz(sdram_sz),

	.joystick_0(joystick_0),
	.joystick_1(joystick_1),
	.joystick_l_analog_0(analog_0),
	.joystick_l_analog_1(analog_1),

	.new_vmode(0),

	.forced_scandoubler(forced_scandoubler),

	// .status_in({status[31:8],region_req,status[5:0]}),
	// .status_set(region_set),
	.status_menumask({ram64,hide_64,~bk_ena}),

	.ioctl_download(ioctl_download),
	.ioctl_index(ioctl_index),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_data),
	.ioctl_wait(ioctl_wait),

	.sd_lba('{sd_lba}),
	.sd_rd(sd_rd),
	.sd_wr(sd_wr),
	.sd_ack(sd_ack),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din('{sd_buff_din}),
	.sd_buff_wr(sd_buff_wr),
	.img_mounted(img_mounted),
	.img_readonly(img_readonly),
	.img_size(img_size),

	.ps2_key(ps2_key),
	.ps2_mouse(ps2_mouse),

	.spinner_0(spinner_0),
	.spinner_1(spinner_1),

	.gamma_bus(gamma_bus)
);

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

wire rom_index = ioctl_index[5:0] == 1;
wire cart_download   = ioctl_download & rom_index;
assign ioctl_wait = !rom_wrack;

always @(posedge clk_sys)
if (reset) begin
//	ioctl_wait <= 0;
//	status_reg <= 0;
	old_download <= 0;
//	timeout <= 0;
	loader_wr <= 0;
	loader_en <= 0;
	loader_addr <= 32'h0080_0000;
end
else begin
	old_download <= ioctl_download;

	loader_wr <= 0;	// Default!
	old_ramreset <= status[15];

	if (~old_download && ioctl_download && rom_index) begin
		loader_addr <= 32'h0080_0000;   // Force the cart ROM to load at 0x00800000 in DDR for Jag core. (byte address!)
		                                // (The ROM actually gets written at 0x30800000 in DDR, which is done when load_addr gets assigned to DDRAM_ADDR below).
		loader_en <= 1;
//		status_reg <= 0;
//		ioctl_wait <= 0;
//		timeout <= 3000000;
	end

	if (loader_wr) loader_addr <= loader_addr + 2'd2; // Writing a 16-bit WORD at a time!

	if (ioctl_wr && rom_index) begin
		loader_wr <= 1;
//		ioctl_wait <= 1;
	end
//	else if (rom_wrack) ioctl_wait <= 1'b0;

	//if (loader_en && DDRAM_BUSY) ioctl_wait <= 1;
	//else ioctl_wait <= 0;

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
end

wire reset = RESET | status[0] | buttons[1] | status[14];

wire xresetl = !(reset | ioctl_download);	// Forces reset on BIOS (boot.rom) load (ioctl_index==0), AND cart ROM.
wire [9:0] dram_a;
wire dram_ras_n;
wire dram_cas_n;
wire [3:0] dram_oe_n;
wire [3:0] dram_uw_n;
wire [3:0] dram_lw_n;
wire [63:0] dram_d;
wire ch1_ready;
`ifdef MISTER_DUAL_SDRAM
wire ch1_64 = status[16];
wire hide_64 = 0;
`else
wire ch1_64 = 1;
wire hide_64 = 1;
`endif
// From SDRAM to the core.
wire [63:0] dram_q = ch1_64 ? use_fastram ? {fastram[63:32], ch1_dout[31:0]} : ch1_dout[63:0] : {ch1_dout2[63:32], ch1_dout[31:0]};

wire [23:0] abus_out;
wire [7:0] os_rom_q;

wire hblank;
wire vblank;
wire vga_hs_n;
wire vga_vs_n;
wire vvs;
wire vid_ce;

wire [7:0] vga_r;
wire [7:0] vga_g;
wire [7:0] vga_b;

reg cart_ce_n_1 = 1;
wire cart_ce_n;
wire [31:0] cart_q;
wire cart_ce_n_falling = (cart_ce_n_1 && !cart_ce_n);

reg xwaitl;
wire startcas;

wire [15:0] aud_16_l;
wire [15:0] aud_16_r;

wire ser_data_in;
wire ser_data_out;
assign ser_data_in = status[17] ? USER_IN[0] : 1'b1;
assign USER_OUT[1] = status[17] ? ser_data_out : 1'b1;

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
	.dram_startwe( dram_startwe ),
	.dram_startwep( dram_startwep ),
	.dram_addr( dram_address ),
	.dram_addrp( dram_addressp ),
	.dram_go_rd( dram_go_rd ),


	.ram_rdy( ram_rdy ) ,		// input  ram_rdy

	.abus_out( abus_out ) ,			// output [23:0] Main Address bus for Tom/Jerry/68K/BIOS/CART.
	.os_rom_q( os_rom_q ) ,			// input [7:0] os_rom_q

	.cart_ce_n( cart_ce_n ) ,	// output  cart_ce_n
	.cart_q( cart_q ) ,			// input [31:0] cart_q

	.bram_addr( bram_addr ),
	.bram_data( bram_data ),
	.bram_q( bram_q ),
	.bram_wr( bram_wr ),

	.vvs( vvs ),
	.vga_vs_n( vga_vs_n ) ,	// output  vga_vs_n
	.vga_hs_n( vga_hs_n ) ,	// output  vga_hs_n
	.vga_r( vga_r ) ,			// output [7:0] vga_r
	.vga_g( vga_g ) ,			// output [7:0] vga_g
	.vga_b( vga_b ) ,			// output [7:0] vga_b

	.hblank( hblank ) ,		// output hblank
	.vblank( vblank ) ,		// output vblank

	.aud_16_l( aud_16_l ) ,		// output  [15:0] aud_16_l
	.aud_16_r( aud_16_r ) ,		// output  [15:0] aud_16_r

	.xwaitl( xwaitl ) ,

	.vid_ce( vid_ce ) ,

	.joystick_0( {joystick_0[31:9], joystick_0[8]|p1p2pause_active,joystick_0[7:0]} ) ,
	.joystick_1( {joystick_1[31:9], joystick_1[8]|p1p2pause_active,joystick_1[7:0]} ) ,
	.analog_0( $signed(analog_0[7:0]) + 9'sd127 ),
	.analog_1( $signed(analog_0[15:8]) + 9'sd127 ),
	.analog_2( $signed(analog_1[7:0]) + 9'sd127 ),
	.analog_3( $signed(analog_1[15:8]) + 9'sd127 ),
	.spinner_0(spinner_0),
	.spinner_1(spinner_1),
	.spinner_speed(status[21:20]),

	.startcas( startcas ) ,

	.vintbugfix( ~status[19] ),
	.turbo( 0 ) , // Disabled with new cpu

	.ntsc( ~status[4] ) ,

	.ps2_mouse( ps2_mouse ) ,

	.mouse_ena_1( status[6:5]==1 ) ,
	.mouse_ena_2( status[6:5]==2 ) ,

	.comlynx_tx( ser_data_out ) ,
	.comlynx_rx( ser_data_in )
);


reg p1p2pause_active;

always @(posedge clk_sys) begin
  reg status19_old;
  reg [25:0] p1p2pulse;

  status19_old <= status[22];

  p1p2pulse <= p1p2pulse + 1;

  if (~status19_old && status[22]) begin
    p1p2pause_active <= 1;
    p1p2pulse <= 1;
  end


  if (p1p2pulse == 0) begin
    p1p2pause_active <= 0;
  end


end

//wire [1:0] romwidth = status[5:4];
//wire [1:0] romwidth = 2'd2;

//wire os_rom_ce_n;
//wire os_rom_oe_n;
//wire os_rom_oe = (~os_rom_ce_n & ~os_rom_oe_n);	// os_rom_oe feeds back TO the core, to enable the internal drivers.

wire os_download = ioctl_download && (ioctl_index[5:0] == 0 || ioctl_index[5:0] == 2);

wire [16:0] os_rom_addr = (os_download) ? {ioctl_addr[16:1],os_lsb} : abus_out[16:0];

wire [7:0] os_rom_din = (!os_lsb) ? ioctl_data[7:0] : ioctl_data[15:8];

reg os_wren;
wire [7:0] os_rom_dout;

// Ram for the bios
spram #(.addr_width(17), .data_width(8), .mem_name("OS_R")) os_rom_bram_inst
(
	.clock   ( clk_sys ),

	.address ( os_rom_addr ),
	.data    ( os_rom_din ),
	.wren    ( os_wren ),

	.q       ( os_rom_dout )
);

assign os_rom_q = (abus_out[16:0]==17'h0136E && status[2]) ? 8'h60 : os_rom_dout; // Patch the BEQ instruction to a BRA, to skip the cart checksum fail.

reg os_lsb = 1;
always @(posedge clk_sys) begin
	os_wren <= 1'b0;

	if (os_download && ioctl_wr) begin
		os_wren <= 1'b1;
		os_lsb <= 1'b0;
	end
	else if (!os_lsb) begin
		os_wren <= 1'b1;
		os_lsb <= 1'b1;
	end
end

assign CLK_VIDEO = clk_sys;

//assign VGA_SL = {~interlace,~interlace} & sl[1:0];

video_mixer #(.LINE_LENGTH(700), .HALF_DEPTH(0), .GAMMA(1)) video_mixer
(
	.CLK_VIDEO(CLK_VIDEO),      // input clk_sys
	.ce_pix( vid_ce ),          // input ce_pix

	.HDMI_FREEZE(0),
	.freeze_sync(),

	.scandoubler(scale || forced_scandoubler),

	.hq2x(scale==1),

	.gamma_bus(gamma_bus),

	.R(crop ? 0 : vga_r),                  // Input [DW:0] R (set by HALF_DEPTH. is [7:0] here).
	.G(crop ? 0 : vga_g),                  // Input [DW:0] G (set by HALF_DEPTH. is [7:0] here).
	.B(crop ? 0 : vga_b),                  // Input [DW:0] B (set by HALF_DEPTH. is [7:0] here).

	// Positive pulses.
	.HSync(vga_hs_n),           // input HSync
	.VSync(status[14] ? vga_vs_n : vvs),// input VSync
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

reg crop;
reg [13:0] hcount;
always @(posedge clk_sys)
if (reset) begin
	 hcount <= 0;
end else begin
	hcount <= hcount + 1;
   if (hblank) begin
		hcount <= 0;
	end
   if (status[18] && (hcount == ((14'd1394)<<2))) begin //works well for NBA Jam and Flip Out
		crop <= 1;
	end
   if (~status[18] || (hcount == ((14'd45)<<2))) begin
		crop <= 0;
	end
end

// assign VGA_R = vga_r;
// assign VGA_G = vga_g;
// assign VGA_B = vga_b;
// assign VGA_VS = vga_vs_n;
// assign VGA_HS = vga_hs_n;
// assign VGA_DE = hblank & vblank;
// assign CE_PIXEL = vid_ce;

wire aud_l_pwm;
wire aud_r_pwm;

assign AUDIO_S = 1;
assign AUDIO_MIX = 0;
assign AUDIO_L = aud_16_l;
assign AUDIO_R = aud_16_r;

// Cart reading is from DDR now...
assign DDRAM_CLK = clk_sys;
assign DDRAM_BURSTCNT = 1;

// Jag DRAM is now mapped at 0x30000000 in DDR on MiSTer, hence the setting of the upper bits here.
// The cart ROM is loaded at 0x30800000, as the Jag normally expects the cart to be mapped at offset 0x800000.
// DRAM address is using "abus_out" here (byte address, so three LSB bits are ignored!)
// so the MSB bit [23] will be set by the Jag core when reading the cart at 0x800000. TODO - confirm this is always the case!
assign DDRAM_ADDR = (loader_en)  ? {8'b0110000, loader_addr[23:3]} : {8'b0110000, abus_out[23:3]};
assign DDRAM_RD = (loader_en) ? 1'b0 : cart_rd_trig;
assign DDRAM_WE = (loader_en) ? loader_wr : 1'b0;

// Byteswap...
//
// Needs this when loading the ROM on MiSTer, at least under Verilator simulation. ElectronAsh.
//
wire [15:0] loader_data_bs = {loader_data[7:0], loader_data[15:8]};
assign DDRAM_DIN = {loader_data_bs, loader_data_bs, loader_data_bs, loader_data_bs};
assign DDRAM_BE = (loader_en) ? loader_be : 8'b11111111;	// IIRC, the DDR controller needs the byte enables to be High during READS! ElectronAsh.

//wire rom_wrack = 1'b1;	// TESTING!!


reg [23:0] old_abus_out;

wire cart_rd_trig = !cart_ce_n && (cart_ce_n_falling || (abus_out != old_abus_out));
reg xwaitl_latch;
assign xwaitl = DDRAM_DOUT_READY | xwaitl_latch;
always @(posedge clk_sys)
if (reset) begin
	xwaitl_latch <= 1'b1; // De-assert on reset!
	old_abus_out <= 24'h112233;
end else begin
	cart_ce_n_1 <= cart_ce_n;
	old_abus_out <= abus_out;
	cart_diff <= cart_q1 != cart_q;


	if (cart_rd_trig) begin
//		xwaitl_latch <= 1'b0; // Assert this (low) until the Cart data is ready.
	end else if (DDRAM_DOUT_READY)
		xwaitl_latch <= 1'b1; // De-assert, to let the core know.
end


wire [1:0] cart_oe;

// 32-bit cart mode...
//
assign cart_q1 = (!abus_out[2]) ? DDRAM_DOUT[63:32] : DDRAM_DOUT[31:00];

wire [3:0] dram_oe = (~dram_cas_n) ? ~dram_oe_n[3:0] : 4'b0000;
wire ram_rdy = ~ch1_64 || ~ch1_req || use_fastram;// && (ch1_ready);	// Latency kludge.
wire d3a;
wire d3b;

// From the core into SDRAM.
wire ram_read_req = (dram_oe_n != 4'b1111); // The use of "startcas" lets us get a bit lower latency for READ requests. (dram_oe_n bits only asserted for reads? - confirm!")
wire ram_write_req = ({dram_uw_n, dram_lw_n} != 8'b11111111);	// Can (currently) only tell a WRITE request when any of the dram byte enables are asserted.

wire ch1_rnw = !ram_write_req;
wire ram_reread = (dram_addr_old == {1'b1,dram_addressp[10:3]});

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

wire dram_startwe;
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
reg old_ram_write_req;
reg old_startcas;

wire dram_cas_edge = old_cas_n && ~dram_cas_n;
wire dram_ras_edge = old_ras_n && ~dram_ras_n;
wire dram_ras_nedge = ~old_ras_n && dram_ras_n;
wire dram_cas_nedge = ~old_cas_n && dram_cas_n;
wire dram_read_edge = ram_read_req && ~old_ram_read_req;
wire dram_write_edge = ram_write_req && ~old_ram_write_req;

wire [19:0] dram_addr = {ras_latch, dram_a};//abus_out[22:3];//{ras_latch, dram_a};
reg [11:3] dram_addr_old;
wire ch1a_ready, ch1b_ready;

assign ch1_ready = ch1a_ready || ch1b_ready;

wire [31:0] cart_q1;
wire rom_wrack;// = 1'b1;	// TESTING!!
reg cart_diff;

`define FAST_SDRAM
`ifdef FAST_SDRAM
reg [7:0] cas_latch;
wire [17:0] sdram_addr;
assign sdram_addr[17:8] = ras_latch[9:0];
assign sdram_addr[7:0] = cas_latch[7:0];
wire use_fastram = (sdram_addr[17:15] == 3'h0) || (sdram_addr[17:15] == 3'h7); // 256K = 1/4 of address coverage
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
spram #(.addr_width(16), .data_width(8)) dram_bram_inst0
(
	.clock   ( clk_sys ),

	.address ( sdram_addr[15:0] ),
	.data    ( ch1_din[63:56] ),
	.wren    ( fastram_w && ch1_be[7] ),

	.q       ( fastram[63:56] )
);
spram #(.addr_width(16), .data_width(8)) dram_bram_inst1
(
	.clock   ( clk_sys ),

	.address ( sdram_addr[15:0] ),
	.data    ( ch1_din[55:48] ),
	.wren    ( fastram_w && ch1_be[6] ),

	.q       ( fastram[55:48] )
);
spram #(.addr_width(16), .data_width(8)) dram_bram_inst2
(
	.clock   ( clk_sys ),

	.address ( sdram_addr[15:0] ),
	.data    ( ch1_din[47:40] ),
	.wren    ( fastram_w && ch1_be[5] ),

	.q       ( fastram[47:40] )
);
spram #(.addr_width(16), .data_width(8)) dram_bram_inst3
(
	.clock   ( clk_sys ),

	.address ( sdram_addr[15:0] ),
	.data    ( ch1_din[39:32] ),
	.wren    ( fastram_w && ch1_be[4] ),

	.q       ( fastram[39:32] )
);
`else
wire use_fastram = 0;
wire [63:32] fastram;
`endif

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

	.ch2_addr           ((loader_en) ? loader_addr[22:1] : {abus_out[22:2],1'b0}),    // 25 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations.
	.ch2_dout           (cart_q),             // data output to cpu
	.ch2_din            (loader_data_bs),     // data input from cpu
	.ch2_req            ((loader_en) ? loader_wr & rom_index : cart_rd_trig),     // request
	.ch2_rnw            ((loader_en) ? !loader_wr & rom_index : 1'b1),     // 1 - read, 0 - write
	.ch2_ready          (rom_wrack),

	.ram64              (ram64),

	.self_refresh       (loader_en || !xresetl)
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

	.ch2_addr           ({22'h0}),    // 25 bit address for 8bit mode. addr[0] = 0 for 16bit mode for correct operations.
	.ch2_dout           (),    // data output to cpu
	.ch2_din            ({16'h0}),     // data input from cpu
	.ch2_req            (0),     // request
	.ch2_rnw            (0),     // 1 - read, 0 - write

	.self_refresh       (loader_en)
);
`endif

reg old_ras_n;

always @(posedge clk_ram)
if (reset) begin
	ras_latch <= 10'd0;
	old_cas_n <= 1;
	dram_addr_old[11] <= 0;
end
else begin
	old_cas_n <= dram_cas_n;
	old_ras_n <= dram_ras_n;
	old_ram_read_req <= ram_read_req;
	old_ram_write_req <= ram_write_req;
	old_startcas <= startcas;
	if (old_ras_n && ~dram_ras_n)
		ras_latch <= dram_a;
	if (ch1_reqr || ch1_reqw || ch1_ref || ch1_act || ch1_pch)
		dram_addr_old <= {ch1_reqr,dram_addressp[10:3]};
end



reg bk_pending;

always @(posedge clk_sys) begin
	if (bk_ena && ~OSD_STATUS && bram_wr)
		bk_pending <= 1'b1;
	else if (bk_state)
		bk_pending <= 1'b0;
end

wire  [9:0] bram_addr;
wire [15:0] bram_data;
wire [15:0] bram_q;
wire        bram_wr;

wire        bk_int = !sd_lba[31:2];
wire [15:0] bk_int_dout;

assign      sd_buff_din = bk_int_dout;

dpram #(10,16) backram
(
	.clock(clk_sys),
   .address_a(bram_addr),
	.data_a(bram_data),
	.wren_a(bram_wr),
	.q_a(bram_q),

	.address_b({sd_lba[1:0],sd_buff_addr}),
	.data_b(sd_buff_dout),
	.wren_b(bk_int & sd_buff_wr & sd_ack),
	.q_b(bk_int_dout)
);

wire downloading = cart_download;
reg old_downloading = 0;

reg bk_ena = 0;
always @(posedge clk_sys) begin

	old_downloading <= downloading;
	if(~old_downloading & downloading) bk_ena <= 0;

	//Save file always mounted in the end of downloading state.
	if(downloading && img_mounted && !img_readonly) bk_ena <= 1;
end

wire bk_load    = status[12];
wire bk_save    = status[11] | (bk_pending & OSD_STATUS && ~status[13]);
reg  bk_loading = 0;
reg  bk_state   = 0;

always @(posedge clk_sys) begin
	reg old_load = 0, old_save = 0, old_ack;

	old_load <= bk_load;
	old_save <= bk_save;
	old_ack  <= sd_ack;

	if(~old_ack & sd_ack) {sd_rd, sd_wr} <= 0;

	if(!bk_state) begin
		if(bk_ena & ((~old_load & bk_load) | (~old_save & bk_save))) begin
			bk_state <= 1;
			bk_loading <= bk_load;
			sd_lba <= 0;
			sd_rd <=  bk_load;
			sd_wr <= ~bk_load;
		end
		if(old_downloading & ~downloading & bk_ena) begin
			bk_state <= 1;
			bk_loading <= 1;
			sd_lba <= 0;
			sd_rd <= 1;
			sd_wr <= 0;
		end
	end else begin
		if(old_ack & ~sd_ack) begin
			if(&sd_lba[1:0]) begin
				bk_loading <= 0;
				bk_state <= 0;
				sd_lba <= 0;
			end else begin
				sd_lba <= sd_lba + 1'd1;
				sd_rd  <=  bk_loading;
				sd_wr  <= ~bk_loading;
			end
		end
	end

end


endmodule
