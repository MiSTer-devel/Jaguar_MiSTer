module jaguar
(
	input               xresetl_in,
	input               cold_reset,

	input               sys_clk,

	output      [9:0]   dram_a,
	output              dram_ras_n,
	output              dram_cas_n,
	output      [3:0]   dram_oe_n,
	output      [3:0]   dram_uw_n,
	output      [3:0]   dram_lw_n,
	output      [63:0]  dram_d,
	input       [63:0]  dram_q,
	input       [3:0]   dram_oe,
	input               ram_rdy,
//	output              dram_go,
	output              dram_go_rd,
	output              dram_rw,
	output      [23:0]  dram_addr,
	output      [7:0]   dram_be,
	output              dram_startwep,
//	output              dram_startwe,
	output      [10:3]  dram_addrp,

	output      [23:0]  abus_out,      // Main external address bus output, used for OS ROM (BIOS), cart, etc. Lower 3 bits are masked.

	input       [7:0]   os_rom_q,

	output              cart_ce_n,
	input       [31:0]  cart_q,

	output       [9:0]  bram_addr,
	output      [15:0]  bram_data,
	input       [15:0]  bram_q,
	output              bram_wr,

	output              vvs,
	output              vga_vs_n,
	output              vga_hs_n,
	output              hblank,
	output              vblank,
	output      [7:0]   vga_r,
	output      [7:0]   vga_g,
	output      [7:0]   vga_b,

	output      [15:0]  aud_16_l,
	output      [15:0]  aud_16_r,

	input               xwaitl,        // Assert (LOW) to pause cart ROM reading until the data is ready!

	output              vid_ce,

	input       [31:0]  joystick_0,
	input       [31:0]  joystick_1,
	input       [31:0]  joystick_2,
	input       [31:0]  joystick_3,
	input       [31:0]  joystick_4,
	input       [7:0]   analog_0,      // Unsigned 0..255 analog input
	input       [7:0]   analog_1,      // Unsigned 0..255 analog input
	input       [7:0]   analog_2,      // Unsigned 0..255 analog input
	input       [7:0]   analog_3,      // Unsigned 0..255 analog input
	input       [8:0]   spinner_0,
	input       [8:0]   spinner_1,
	input       [1:0]   spinner_speed,
	input               team_tap_port1,
	input               team_tap_port2,

	input       [24:0]  ps2_mouse,
	input               mouse_ena_1,
	input               mouse_ena_2,

	output              comlynx_tx,
	input               comlynx_rx,

	output              startcas,

// NOT_NETLIST
	input maxc,
	input auto_eeprom,
	output [23:0] addr_ch3,
	input [8:0] toc_addr,
	input [15:0] toc_data,
	input toc_wr,

	output      [28:0]  audbus_out,
	input       [63:0]  aud_in,
	input               audwaitl,
	output              aud_ce,
input aud_sess,

	input               cd_en,
	input               cd_ex,
	output              b_override,
input dohacks,
output xvclk_o,
output overflow,
output underflow,
output errflow,
output unhandled,
	
	input               turbo,
	input               vintbugfix,	
	
	input ddreq,

	input               ntsc
);
assign xvclk_o = xvclk;

wire [1:0] cart_oe_n;
wire [1:0] cart_oe;

assign cart_oe[0] = (~cart_oe_n[0] & ~cart_ce_n);
assign cart_oe[1] = (~cart_oe_n[1] & ~cart_ce_n);

wire d3a;
wire d3b;
wire [7:0] we;
wire startwe;
wire startwep;
assign dram_go_rd = d3a && !startwep && tlw;
//assign dram_go_rd = d3a && !ram_rdy && xrw_in;
//assign dram_go_wr = d3b && !xrw_in;
assign dram_rw = xrw_in;
assign dram_addr[23:0] = xa_in[23:0];
assign dram_be[7:0] = we[7:0];
assign dram_startwep = startwep;

wire os_rom_ce_n;
wire os_rom_oe_n;
wire os_rom_oe = (~os_rom_ce_n & ~os_rom_oe_n);	// os_rom_oe feeds back TO the core, to enable the internal drivers.

assign j_xserin = comlynx_rx;
assign comlynx_tx = j_xserout;

// Note: Turns out the custom chips use synchronous resets.
// So these clocks need to be left running during reset, else the core won't start up correctly the next time the HPS resets it. ElectronAsh.

reg [1:0] clkdiv = 0;

wire xpclk;                         // Processor (Tom & Jerry) Clock.
wire xvclk;                         // Video Clock.
wire tlw;                           // Transparent Latch Write?

reg cpu_toggle;                     // Toggles at 26.6MHz to act as an additional divider for the pixel clock and cpu.

reg old_reset = 1'b1;
reg xresetl = 1'b0;

reg ce_26_6_p0 = 1;
reg ce_26_6_p1 = 0;
reg ce_26_6_p2 = 0;
reg ce_26_6_p3 = 0;

always @(posedge sys_clk) begin
	clkdiv <= clkdiv + 2'd1;
	ce_26_6_p0 <= &clkdiv[1:0];
	ce_26_6_p1 <= ce_26_6_p0;
	ce_26_6_p2 <= ce_26_6_p1;
	ce_26_6_p3 <= ce_26_6_p2;

	if (ce_26_6_p3) begin
		cpu_toggle <= ~cpu_toggle;
	end

	old_reset <= xresetl_in;
	// Reduce non-deterministic behavior.
	if (xresetl_in && ce_26_6_p3 && cpu_toggle) begin
		xresetl    <= 1;
	end
	// Just testing this; Might put back
	if (old_reset && ~xresetl_in) begin
		clkdiv <= 0;
		ce_26_6_p0 <= 1;
		ce_26_6_p1 <= 0;
		ce_26_6_p2 <= 0;
		ce_26_6_p3 <= 0;
		cpu_toggle <= 0;
		xresetl    <= 0;
	end
end

assign xvclk = ce_26_6_p0;// | ce_26_6_p1;
assign tlw = ce_26_6_p3;                  // Transparent Latch Write. This really should just be negedge xvclk, but in our design we need it to be CE.
assign vid_ce = xvclk & cpu_toggle;

// TOM

// TOM - Inputs
wire            xbgl;
wire    [1:0]   xdbrl;
wire            xlp;
wire            xdint;
wire            xtest;

// TOM - Bidirs
wire    [63:0]  xd_out;
wire    [63:0]  xd_oe;
wire    [63:0]  xd_in;
wire    [23:0]  xa_out;
wire    [23:0]  xa_oe;
wire    [23:0]  xa_in;
wire    [10:0]  xma_out;
wire    [10:0]  xma_oe;
wire    [10:0]  xma_in;
wire            xhs_out;
wire            xhs_oe;
wire            xhs_in;
wire            xvs_out;
wire            xvs_oe;
wire            xvs_in;
wire    [1:0]   xsiz_out;
wire    [1:0]   xsiz_oe;
wire    [1:0]   xsiz_in;
wire    [2:0]   xfc_out;
wire    [2:0]   xfc_oe;
wire    [2:0]   xfc_in;
wire            xrw_out;
wire            xrw_oe;
wire            xrw_in;
wire            xdreql_out;
wire            xdreql_oe;
wire            xdreql_in;
wire            xba_out;
wire            xba_oe;
wire            xba_in;
wire            xbrl_out;
wire            xbrl_oe;
wire            xbrl_in;

// TOM - Outputs
wire    [7:0]   xr;
wire    [7:0]   xg;
wire    [7:0]   xb;
wire            xinc;
wire    [2:0]   xoel;
wire    [2:0]   xmaska;
wire    [1:0]   xromcsl;
wire    [1:0]   xcasl;
wire            xdbgl;
wire            xexpl;
wire            xdspcsl;
wire    [7:0]   xwel;
wire    [1:0]   xrasl;
wire            xdtackl;
wire            xintl;

// TOM - Extra signals
wire            hs_o;
wire            hhs_o;
wire            vs_o;
wire            blank;

wire    [2:0]   den;
wire            aen;

// JERRY

// JERRY - Inputs
wire            j_xdspcsl;
wire            j_xpclkosc;
wire            j_xpclkin;
wire            j_xdbgl;
wire            j_xoel_0;
wire            j_xwel_0;
wire            j_xserin;
wire            j_xdtackl;
wire            j_xi2srxd;
wire    [1:0]   j_xeint;
wire            j_xtest;
wire            j_xchrin;
wire            j_xresetil;

// JERRY - Bidirs
wire    [31:0]  j_xd_out;
wire    [31:0]  j_xd_oe;
wire    [31:0]  j_xd_in;
wire    [23:0]  j_xa_out;
wire    [23:0]  j_xa_oe;
wire    [23:0]  j_xa_in;
wire    [3:0]   j_xjoy_out;
wire    [3:0]   j_xjoy_oe;
wire    [3:0]   j_xjoy_in;
wire    [5:0]   j_xgpiol_out; // 4 and 5 included
wire    [3:0]   j_xgpiol_oe;
wire    [3:0]   j_xgpiol_in;
wire            j_xsck_out;
wire            j_xsck_oe;
wire            j_xsck_in;
wire            j_xws_out;
wire            j_xws_oe;
wire            j_xws_in;
wire            j_xvclk_out;
wire            j_xvclk_oe;
wire            j_xvclk_in;
wire    [1:0]   j_xsiz_out;
wire    [1:0]   j_xsiz_oe;
wire    [1:0]   j_xsiz_in;
wire            j_xrw_out;
wire            j_xrw_oe;
wire            j_xrw_in;
wire            j_xdreql_out;
wire            j_xdreql_oe;
wire            j_xdreql_in;

// JERRY - Outputs
wire    [1:0]   j_xdbrl;
wire            j_xint;
wire            j_xserout;
wire            j_xgpiol_4;
wire            j_xgpiol_5;
wire            j_xvclkdiv;
wire            j_xchrdiv;
wire            j_xpclkout;
wire            j_xpclkdiv;
wire            j_xresetl;
wire            j_xchrout;
wire    [1:0]   j_xrdac;
wire    [1:0]   j_xldac;
wire            j_xiordl;
wire            j_xiowrl;
wire            j_xi2stxd;
wire            j_xcpuclk;

// JERRY - Extra signals
wire            j_den;
wire            j_aen;
wire            j_ainen;
wire    [15:0]  snd_l;
wire    [15:0]  snd_r;

// Tristates / Busses
wire            rw;
wire    [1:0]   siz;
wire            dreql;
wire    [23:0]  abus;
wire    [63:0]  dbus;

// JOYSTICK INTERFACE
wire    [15:0]  joy;
wire    [7:0]   b;
reg             u374_clk_prev = 1'b1;
reg     [7:0]   u374_reg;
wire    [15:0]  joy_bus;
wire            joy_bus_oe;

// 68000
wire            fx68k_clk;
wire            fx68k_rst;
wire            fx68k_halt;
wire            fx68k_rw;
wire            fx68k_as_n;
wire            fx68k_lds_n;
wire            fx68k_uds_n;
wire            fx68k_e;
wire            fx68k_vma_n;
wire    [2:0]   fx68k_fc;
wire            fx68k_dtack_n;
wire            fx68k_vpa_n;
wire            fx68k_berr_n;
wire    [2:0]   fx68k_ipl_n;
wire    [15:0]  fx68k_dout;
wire    [15:0]  fx68k_din;
wire    [22:0]  fx68k_address;
wire            fx68k_bg_n;
wire            fx68k_br_n;
wire            fx68k_bgack_n;
wire    [23:0]  fx68k_byte_addr; // 24-bit address bus including the LSB set to 0
wire            fx68k_fc_z;
wire            fx68k_rw_z;
wire            fx68k_address_z;
wire            fx68k_data_z;

wire            fx68k_bus_en = ~fx68k_as_n & fx68k_bgack_n;
wire            fx68k_fc_en = turbo ? fx68k_bus_en : ~fx68k_fc_z;
wire            fx68k_rw_en =  turbo ? fx68k_bus_en : ~fx68k_rw_z;
wire            fx68k_address_en =  turbo ? fx68k_bus_en : ~fx68k_address_z;
wire            fx68k_data_en = turbo ? (fx68k_bus_en & ~fx68k_rw) : ~fx68k_data_z;

// EEPROM
wire            ee_cs;
wire            ee_sk;
wire            ee_di;
wire            ee_do;

wire            refreq;
wire            obbreq;
wire    [1:0]   gbreq;
wire    [1:0]   bbreq;

// TOM - Inputs
assign xdbrl[0] = j_xdbrl[0];           // Requests the bus for the DSP
assign xdbrl[1] = (j_xdbrl[0] | xdbgl); // Small circuit on the mobo
assign xlp = b[0];                      // Light Pen -- connected to "b0"
assign xdint = j_xint;
assign xtest = 1'b0;                    // "test" pins on both Tom and Jerry are tied to GND on the Jag.

// JERRY - Inputs
assign j_xdspcsl = xdspcsl;
assign j_xpclkosc = xvclk;
assign j_xpclkin = j_xpclkout;
assign j_xdbgl = xdbgl;                 // Bus Grant from Tom
assign j_xoel_0 = xoel[0];              // Output Enable
assign j_xwel_0 = xwel[0];              // Write Enable

assign j_xdtackl = xdtackl;             // Data Acknowledge from Tom (also goes to the 68K)
//assign j_xi2srxd = 1'b1;                // (Async?) I2S receive
//assign j_xeint[0] = 1'b1;               // External Interrupt
assign j_xeint[1] = 1'b1;               // External Interrupt
assign j_xtest = 1'b0;                  // "test" pins on both Tom and Jerry are tied to GND on the Jag
assign j_xchrin = 1'b1;                 // Not used


// ADC (early revisions of the jaguar had an ADC for analog joysticks on the external data bus)
assign j_xgpiol_5 = j_xgpiol_out[5]; // Jerry's GPIO line 5 is connected to the ADC's output enable.
wire adc_oe = ~j_xgpiol_5 & ~j_xiordl;
wire adc_we = ~j_xgpiol_5 & ~j_xiowrl;
reg [7:0] adc_data = 8'd0;

always @(posedge sys_clk) begin
	if (adc_we) begin
		case (e_dbus[3:2])
			2'b00, 2'b10: begin
				case (e_dbus[1:0])
					2'b00: adc_data <= analog_0 < analog_1 ? 8'd0 : analog_0 - analog_1;
					2'b01: adc_data <= analog_1 < analog_0 ? 8'd0 : analog_1 - analog_0;
					2'b10: adc_data <= analog_2 < analog_3 ? 8'd0 : analog_2 - analog_3;
					2'b11: adc_data <= analog_3 < analog_2 ? 8'd0 : analog_3 - analog_2;
				endcase
			end
			2'b01: begin
				case (e_dbus[1:0])
					2'b00: adc_data <= analog_0;
					2'b01: adc_data <= analog_1;
					2'b10: adc_data <= analog_2;
					2'b11: adc_data <= analog_3;
				endcase
			end
			2'b11: begin
				case (e_dbus[1:0])
					2'b00: adc_data <= analog_0 < analog_3 ? 8'd0 : analog_0 - analog_3;
					2'b01: adc_data <= analog_1 < analog_3 ? 8'd0 : analog_1 - analog_3;
					2'b10: adc_data <= analog_2 < analog_3 ? 8'd0 : analog_2 - analog_3;
					2'b11: adc_data <= adc_data;
				endcase
			end
		endcase
	end

	if (~xresetl) begin
		adc_data <= 8'd0; // Power on to undefined state
	end
end

// Tristates between TOM/JERRY/68000

assign rw =
	(xrw_oe)         ? xrw_out   : //1'b1) &
	(j_xrw_oe)       ? j_xrw_out : //1'b1) &
	                   fx68k_rw;
//	(fx68k_bus_en)   ? fx68k_rw  : 1'b1;

assign xrw_in = rw;
assign j_xrw_in = rw;

// Note xsiz_oe[1:0] is 2 copies of aen; could just use aen or any bit of xsiz_oe
// Note j_xsiz_oe[1:0] is 2 copies of j_aen; could just use j_aen or any bit of j_xsiz_oe
assign siz =
	(xsiz_oe[0])      ? xsiz_out    : //2'b11) &
	(j_xsiz_oe[0])    ? j_xsiz_out  : //2'b11) &
	                    {fx68k_uds_n, fx68k_lds_n};
//	(fx68k_bus_en)    ? {fx68k_uds_n, fx68k_lds_n} : 2'b11;

assign xsiz_in = siz;
assign j_xsiz_in = siz;

// Note xdreql_oe is aen; could just use aen
assign dreql =
	(xdreql_oe)        ? xdreql_out   :
	(j_xdreql_oe)      ? j_xdreql_out :
	(fx68k_address_en) ? fx68k_as_n   :
	1'b1;

assign xdreql_in = dreql;
assign j_xdreql_in = dreql;

// Busses between TOM/JERRY/68000

// Address bus
// Note xa_oe[23:0] is 24 copies of aen; could just use aen or any bit of xa_oe
// Note j_xa_oe[23:0] is 24 copies of j_aen; could just use j_aen or any bit of j_xa_oe
assign abus[23:0] =
	(xa_oe[0])         ? xa_out[23:0]           : // Tom.
	(j_xa_oe[0])       ? j_xa_out[23:0]         : // Jerry.
	(fx68k_address_en) ? fx68k_byte_addr[23:0]  : // 68000.
	24'hFFFFFF; // FIXME: It's unknown if this is pulled up weakly by anything.

assign xa_in[23:0] = abus[23:0];

// Avoid inputting jerry's own output for timing reasons
// Note xa_oe[23:0] is 24 copies of aen; could just use aen or any bit of xa_oe
assign j_xa_in[23:0] =
	(xa_oe[0])         ? xa_out[23:0]          : // Tom.
	(fx68k_address_en) ? fx68k_byte_addr[23:0] : // 68000.
	24'hFFFFFF;

// Data Bus

reg [63:0] open_bus; // Chances are this should be capacitance based

always @(posedge sys_clk) begin
	open_bus <= dbus;
end

wire fx68k_dout_en = fx68k_bus_en & ~fx68k_rw; // The xba_in signal is because I don't trust accurate timing of the fx68k signals so we use tom to de-slop it.

// External Data Bus
wire e_dbus_oe = ~xexpl & rw;
wire e_dbus_we = ~xexpl & ~rw;

// The external data bus (ED) is driven when RW is high and XEXPL is low.
wire [7:0] e_dbus_7_0 =
	(os_rom_oe)         ? os_rom_q[7:0]     : // BIOS.
	(cart_oe[0])        ? cart_qt[7:0]      : // Cart ROM.
	(joy_bus_oe)        ? joy_bus[7:0]      : // Joyports.
	(adc_oe)            ? adc_data[7:0]     : // Joystick DAC.. no idea what the out value of this should really be.
	8'hFF;                                    // External bus is pulled up.

wire [7:0] e_dbus_15_8 =
	(cart_oe[0])        ? cart_qt[15:8]     : // Cart ROM.
	(joy_bus_oe)        ? joy_bus[15:8]     : // Joyports.
	8'hFF;                                    // External bus is pulled up.

wire [15:0] e_dbus_15_0 = {e_dbus_15_8, e_dbus_7_0};

wire [15:0] e_dbus_31_16 =
	(cart_oe[1])        ? cart_qt[31:16]    : // Cart ROM.
	16'hFFFF;                                 // External bus is pulled up.

wire [31:0] e_dbus = (e_dbus_we) ? dbus[31:0] : {e_dbus_31_16, e_dbus_15_8, e_dbus_7_0}; // Internal data bus writing.

// Primary Data Bus
wire [7:0] dbus_7_0 =
	(fx68k_data_en)      ? fx68k_dout[7:0]  : // 68000.
	open_bus[7:0];                            // Open bus.

wire [7:0] dbus_15_8 =
	(fx68k_data_en)      ? fx68k_dout[15:8] : // 68000.
	open_bus[15:8];                           // Open bus.

wire [15:0] dbus_15_0_no_j =
	(den[0])            ? xd_out[15:0]      : // Tom.
	(dram_oe[0])        ? dram_q[15:0]      : // DRAM.
	(e_dbus_oe)         ? e_dbus_15_0       : // External Bus.
	{dbus_15_8, dbus_7_0};                    // 68000, Open bus.

wire [15:0] dbus_15_0 =
	(j_den)             ? j_xd_out[15:0]    : // Jerry.
	(dbus_15_0_no_j);                         // Everything else.

wire [15:0] dbus_31_16 =
	(den[1])            ? xd_out[31:16]     : // Tom.
	(dram_oe[1])        ? dram_q[31:16]     : // DRAM.
	(e_dbus_oe)         ? e_dbus_31_16      : // Cart ROM (External Bus).
	open_bus[31:16];                          // Open bus.

wire [15:0] dbus_47_32 =
	(den[2])            ? xd_out[47:32]     : // Tom.
	(dram_oe[2])        ? dram_q[47:32]     : // DRAM.
	open_bus[47:32];                          // Open bus.

wire [15:0] dbus_63_48 =
	(den[2])            ? xd_out[63:48]     : // Tom.
	(dram_oe[2])        ? dram_q[63:48]     : // DRAM.
	open_bus[63:48];                          // Open bus.

assign dbus = {dbus_63_48, dbus_47_32, dbus_31_16, dbus_15_0};

assign xd_in[63:0] = dbus[63:0];
assign j_xd_in[15:0] = dbus_15_0_no_j;         // If we let jerry mux it's own lines it creates tons of logic loops
assign j_xd_in[31:16] = (j_den) ? j_xd_out[31:16] : 16'b11111111_11111111;	// Data bus bits [31:16] on Jerry are pulled High on the Jag schematic.

// DRAM

assign dram_a[9:0] = xma_in[9:0];
assign dram_d[63:0] = dbus[63:0];
assign dram_ras_n = xrasl[0];
assign dram_cas_n = xcasl[0];
assign dram_uw_n[3:0] = {xwel[7], xwel[5], xwel[3], xwel[1]};
assign dram_lw_n[3:0] = {xwel[6], xwel[4], xwel[2], xwel[0]};
assign dram_oe_n[3:0] = {xoel[2], xoel[2], xoel[1], xoel[0]}; // Note: OEL bit 2 is hooked up twice. This is true for the Jag schematic as well.

// TOM-specific tristates

// 8 FC[0..2] should be ignored when Jerry owns the bus
// Level 0 hardware
// Description These signals have to be tied off with resistors, as otherwise Tom can assume Jerry bus
// master cycles are the wrong type.

// Resistors are tied to 2 1 0 = vcc gnd vcc = 3'b101
assign xfc_in[0] = ((xfc_oe[0] ? xfc_out[0] : 1'd1) & (~fx68k_fc_en ? 1'd1 : fx68k_fc[0]));
assign xfc_in[1] = ((xfc_oe[1] ? xfc_out[1] : 1'd1) & (~fx68k_fc_en ? 1'd0 : fx68k_fc[1]));
assign xfc_in[2] = ((xfc_oe[2] ? xfc_out[2] : 1'd1) & (~fx68k_fc_en ? 1'd1 : fx68k_fc[2]));

// Wire-ORed with pullup (?)
assign xba_in = xba_oe ? xba_out : 1'b1;    // Bus Acknowledge.

// Wire-ORed with pullup (?)
assign xbrl_in = xbrl_oe ? xbrl_out : 1'b1; // Bus Request.
assign xhs_in = xhs_oe ? xhs_out : 1'b0;    // These are pulled down if not driven
assign xvs_in = xvs_oe ? xvs_out : 1'b0;

// Latching of memory configuration register on startup
// This XMA pins are pulled High or Low by resistors on the Jag board.
assign xma_in[0]  = (xma_oe[0])  ? xma_out[0]  : 1'b1; // ROMHI
assign xma_in[1]  = (xma_oe[1])  ? xma_out[1]  : 1'b0; // ROMWID0
assign xma_in[2]  = (xma_oe[2])  ? xma_out[2]  : 1'b0; // ROMWID1
assign xma_in[3]  = (xma_oe[3])  ? xma_out[3]  : 1'b0; // ?
assign xma_in[4]  = (xma_oe[4])  ? xma_out[4]  : 1'b0; // NOCPU (?)
assign xma_in[5]  = (xma_oe[5])  ? xma_out[5]  : 1'b0; // CPU32
assign xma_in[6]  = (xma_oe[6])  ? xma_out[6]  : 1'b1; // BIGEND
assign xma_in[7]  = (xma_oe[7])  ? xma_out[7]  : 1'b0; // EXTCLK
assign xma_in[8]  = (xma_oe[8])  ? xma_out[8]  : 1'b1; // 68K (?)
assign xma_in[9]  = (xma_oe[9])  ? xma_out[9]  : 1'b0;
assign xma_in[10] = (xma_oe[10]) ? xma_out[10] : 1'b0;

// JERRY-specific tristates

assign j_xjoy_in[0] = (j_xjoy_oe[0]) ? j_xjoy_out[0] : 1'b1; // DSP16.
assign j_xjoy_in[1] = (j_xjoy_oe[1]) ? j_xjoy_out[1] : 1'b1; // BIGEND.
assign j_xjoy_in[2] = (j_xjoy_oe[2]) ? j_xjoy_out[2] : 1'b0; // PCLK/2.
assign j_xjoy_in[3] = (j_xjoy_oe[3]) ? j_xjoy_out[3] : 1'b0; // EXTCLK.

assign j_xgpiol_in[0] = (j_xgpiol_oe[0]) ? j_xgpiol_out[0] : 1'b1;
assign j_xgpiol_in[1] = (j_xgpiol_oe[1]) ? j_xgpiol_out[1] : 1'b1;
assign j_xgpiol_in[2] = (j_xgpiol_oe[2]) ? j_xgpiol_out[2] : 1'b1;
assign j_xgpiol_in[3] = (j_xgpiol_oe[3]) ? j_xgpiol_out[3] : 1'b1;

assign j_xsck_in = j_xsck_oe ? j_xsck_out : b_xsck_oe ? b_xsck_out : 1'b1;
assign j_xws_in = j_xws_oe ? j_xws_out : b_xws_oe ? b_xws_out : 1'b1;
assign j_xvclk_in = j_xvclk_oe ? j_xvclk_out : j_xchrdiv;

wire [1:0] mouseX;
wire [1:0] mouseY;
wire mouseButton_l;
wire mouseButton_r;
wire mouseButton_m;

ps2_mouse mouse
(
	.reset(~xresetl),

	.clk(sys_clk),
	.ce(ce_26_6_p3),

	.ps2_mouse(ps2_mouse),      // 25-bit bus, from hps_io.

	.xout(mouseX),
	.yout(mouseY),
	.button_l(mouseButton_l),   // Active-LOW output!
	.button_r(mouseButton_r),   // Active-LOW output!
	.button_m(mouseButton_m)    // Active-LOW output!
);

// Team Tap for Port 1
wire [5:0] team_tap_port1_row_n;

jag_team_tap team_tap_port1_inst (
	.col_n(~j_xjoy_in[3] ? u374_reg[3:0] : 4'b1111),
	.enable(team_tap_port1),
	.row_n(team_tap_port1_row_n),
	
	// Controller A inputs
	.but_a_right(joystick_0[0]),
	.but_a_left(joystick_0[1]),
	.but_a_down(joystick_0[2]),
	.but_a_up(joystick_0[3]),
	.but_a_a(joystick_0[4]),
	.but_a_b(joystick_0[5]),
	.but_a_c(joystick_0[6]),
	.but_a_option(joystick_0[7]),
	.but_a_pause(joystick_0[8]),
	.but_a_1(joystick_0[9]),
	.but_a_2(joystick_0[10]),
	.but_a_3(joystick_0[11]),
	.but_a_4(joystick_0[12]),
	.but_a_5(joystick_0[13]),
	.but_a_6(joystick_0[14]),
	.but_a_7(joystick_0[15]),
	.but_a_8(joystick_0[16]),
	.but_a_9(joystick_0[17]),
	.but_a_0(joystick_0[18]),
	.but_a_star(joystick_0[19]),
	.but_a_hash(joystick_0[20]),
	
	// Controller B inputs
	.but_b_right(joystick_1[0]),
	.but_b_left(joystick_1[1]),
	.but_b_down(joystick_1[2]),
	.but_b_up(joystick_1[3]),
	.but_b_a(joystick_1[4]),
	.but_b_b(joystick_1[5]),
	.but_b_c(joystick_1[6]),
	.but_b_option(joystick_1[7]),
	.but_b_pause(joystick_1[8]),
	.but_b_1(joystick_1[9]),
	.but_b_2(joystick_1[10]),
	.but_b_3(joystick_1[11]),
	.but_b_4(joystick_1[12]),
	.but_b_5(joystick_1[13]),
	.but_b_6(joystick_1[14]),
	.but_b_7(joystick_1[15]),
	.but_b_8(joystick_1[16]),
	.but_b_9(joystick_1[17]),
	.but_b_0(joystick_1[18]),
	.but_b_star(joystick_1[19]),
	.but_b_hash(joystick_1[20]),
	
	// Controller C inputs
	.but_c_right(joystick_2[0]),
	.but_c_left(joystick_2[1]),
	.but_c_down(joystick_2[2]),
	.but_c_up(joystick_2[3]),
	.but_c_a(joystick_2[4]),
	.but_c_b(joystick_2[5]),
	.but_c_c(joystick_2[6]),
	.but_c_option(joystick_2[7]),
	.but_c_pause(joystick_2[8]),
	.but_c_1(joystick_2[9]),
	.but_c_2(joystick_2[10]),
	.but_c_3(joystick_2[11]),
	.but_c_4(joystick_2[12]),
	.but_c_5(joystick_2[13]),
	.but_c_6(joystick_2[14]),
	.but_c_7(joystick_2[15]),
	.but_c_8(joystick_2[16]),
	.but_c_9(joystick_2[17]),
	.but_c_0(joystick_2[18]),
	.but_c_star(joystick_2[19]),
	.but_c_hash(joystick_2[20]),
	
	// Controller D inputs
	.but_d_right(joystick_3[0]),
	.but_d_left(joystick_3[1]),
	.but_d_down(joystick_3[2]),
	.but_d_up(joystick_3[3]),
	.but_d_a(joystick_3[4]),
	.but_d_b(joystick_3[5]),
	.but_d_c(joystick_3[6]),
	.but_d_option(joystick_3[7]),
	.but_d_pause(joystick_3[8]),
	.but_d_1(joystick_3[9]),
	.but_d_2(joystick_3[10]),
	.but_d_3(joystick_3[11]),
	.but_d_4(joystick_3[12]),
	.but_d_5(joystick_3[13]),
	.but_d_6(joystick_3[14]),
	.but_d_7(joystick_3[15]),
	.but_d_8(joystick_3[16]),
	.but_d_9(joystick_3[17]),
	.but_d_0(joystick_3[18]),
	.but_d_star(joystick_3[19]),
	.but_d_hash(joystick_3[20])
);

// Team Tap for Port 2
wire [5:0] team_tap_port2_row_n;
wire [3:0] joy2_col_reversed = {u374_reg[4], u374_reg[5], u374_reg[6], u374_reg[7]};

jag_team_tap team_tap_port2_inst (
	.col_n(~j_xjoy_in[3] ? joy2_col_reversed : 4'b1111),
	.enable(team_tap_port2),
	.row_n(team_tap_port2_row_n),
	
	// Controller A inputs
	.but_a_right(joystick_1[0]),
	.but_a_left(joystick_1[1]),
	.but_a_down(joystick_1[2]),
	.but_a_up(joystick_1[3]),
	.but_a_a(joystick_1[4]),
	.but_a_b(joystick_1[5]),
	.but_a_c(joystick_1[6]),
	.but_a_option(joystick_1[7]),
	.but_a_pause(joystick_1[8]),
	.but_a_1(joystick_1[9]),
	.but_a_2(joystick_1[10]),
	.but_a_3(joystick_1[11]),
	.but_a_4(joystick_1[12]),
	.but_a_5(joystick_1[13]),
	.but_a_6(joystick_1[14]),
	.but_a_7(joystick_1[15]),
	.but_a_8(joystick_1[16]),
	.but_a_9(joystick_1[17]),
	.but_a_0(joystick_1[18]),
	.but_a_star(joystick_1[19]),
	.but_a_hash(joystick_1[20]),
	
	// Controller B inputs
	.but_b_right(joystick_2[0]),
	.but_b_left(joystick_2[1]),
	.but_b_down(joystick_2[2]),
	.but_b_up(joystick_2[3]),
	.but_b_a(joystick_2[4]),
	.but_b_b(joystick_2[5]),
	.but_b_c(joystick_2[6]),
	.but_b_option(joystick_2[7]),
	.but_b_pause(joystick_2[8]),
	.but_b_1(joystick_2[9]),
	.but_b_2(joystick_2[10]),
	.but_b_3(joystick_2[11]),
	.but_b_4(joystick_2[12]),
	.but_b_5(joystick_2[13]),
	.but_b_6(joystick_2[14]),
	.but_b_7(joystick_2[15]),
	.but_b_8(joystick_2[16]),
	.but_b_9(joystick_2[17]),
	.but_b_0(joystick_2[18]),
	.but_b_star(joystick_2[19]),
	.but_b_hash(joystick_2[20]),
	
	// Controller C inputs
	.but_c_right(joystick_3[0]),
	.but_c_left(joystick_3[1]),
	.but_c_down(joystick_3[2]),
	.but_c_up(joystick_3[3]),
	.but_c_a(joystick_3[4]),
	.but_c_b(joystick_3[5]),
	.but_c_c(joystick_3[6]),
	.but_c_option(joystick_3[7]),
	.but_c_pause(joystick_3[8]),
	.but_c_1(joystick_3[9]),
	.but_c_2(joystick_3[10]),
	.but_c_3(joystick_3[11]),
	.but_c_4(joystick_3[12]),
	.but_c_5(joystick_3[13]),
	.but_c_6(joystick_3[14]),
	.but_c_7(joystick_3[15]),
	.but_c_8(joystick_3[16]),
	.but_c_9(joystick_3[17]),
	.but_c_0(joystick_3[18]),
	.but_c_star(joystick_3[19]),
	.but_c_hash(joystick_3[20]),
	
	// Controller D inputs
	.but_d_right(joystick_4[0]),
	.but_d_left(joystick_4[1]),
	.but_d_down(joystick_4[2]),
	.but_d_up(joystick_4[3]),
	.but_d_a(joystick_4[4]),
	.but_d_b(joystick_4[5]),
	.but_d_c(joystick_4[6]),
	.but_d_option(joystick_4[7]),
	.but_d_pause(joystick_4[8]),
	.but_d_1(joystick_4[9]),
	.but_d_2(joystick_4[10]),
	.but_d_3(joystick_4[11]),
	.but_d_4(joystick_4[12]),
	.but_d_5(joystick_4[13]),
	.but_d_6(joystick_4[14]),
	.but_d_7(joystick_4[15]),
	.but_d_8(joystick_4[16]),
	.but_d_9(joystick_4[17]),
	.but_d_0(joystick_4[18]),
	.but_d_star(joystick_4[19]),
	.but_d_hash(joystick_4[20])
);

// Standard controller mux instances (used when Team Tap is not active)
wire [5:0] joy2_row_n;
wire [5:0] joy1_row_n;


jag_controller_mux controller_mux_1
(
	.col_n      (~j_xjoy_in[3] ? u374_reg[3:0] : 4'b1111),
	.row_n      (joy1_row_n),

	.but_right  ((!mouse_ena_1) ? joystick_0[0] | sp_out0[0] : mouseY[0]),
	.but_left   ((!mouse_ena_1) ? joystick_0[1] | sp_out0[1] : mouseY[1]),
	.but_down   ((!mouse_ena_1) ? joystick_0[2] : mouseX[1]),
	.but_up     ((!mouse_ena_1) ? joystick_0[3] : mouseX[0]),
	.but_a      ((!mouse_ena_1) ? joystick_0[4] : ~mouseButton_l),
	.but_b      ((!mouse_ena_1) ? joystick_0[5] : ~mouseButton_m),
	.but_c      (joystick_0[6]),
	.but_option (joystick_0[7]),
	.but_pause  ((!mouse_ena_1) ? joystick_0[8] : ~mouseButton_r),
	.but_1      (joystick_0[9]),
	.but_2      (joystick_0[10]),
	.but_3      (joystick_0[11]),
	.but_4      (joystick_0[12]),
	.but_5      (joystick_0[13]),
	.but_6      (joystick_0[14]),
	.but_7      (joystick_0[15]),
	.but_8      (joystick_0[16]),
	.but_9      (joystick_0[17]),
	.but_0      (joystick_0[18]),
	.but_star   (joystick_0[19]),
	.but_hash   (joystick_0[20])
);

jag_controller_mux controller_mux_2
(
	.col_n      (~j_xjoy_in[3] ? joy2_col_reversed : 4'b1111),
	.row_n      (joy2_row_n),
	.but_right  ((!mouse_ena_2) ? (team_tap_port1 ? joystick_4[0] : joystick_1[0]) | sp_out1[0] : mouseY[0]),
	.but_left   ((!mouse_ena_2) ? (team_tap_port1 ? joystick_4[1] : joystick_1[1]) | sp_out1[1] : mouseY[1]),
	.but_down   ((!mouse_ena_2) ? (team_tap_port1 ? joystick_4[2] : joystick_1[2]) : mouseX[1]),
	.but_up     ((!mouse_ena_2) ? (team_tap_port1 ? joystick_4[3] : joystick_1[3]) : mouseX[0]),
	.but_a      ((!mouse_ena_2) ? (team_tap_port1 ? joystick_4[4] : joystick_1[4]) : ~mouseButton_l),
	.but_b      ((!mouse_ena_2) ? (team_tap_port1 ? joystick_4[5] : joystick_1[5]) : ~mouseButton_m),
	.but_c      (team_tap_port1 ? joystick_4[6] : joystick_1[6]),
	.but_option (team_tap_port1 ? joystick_4[7] : joystick_1[7]),
	.but_pause  ((!mouse_ena_2) ? (team_tap_port2 ? joystick_4[8] : joystick_1[8]) : ~mouseButton_r),
	.but_1      (team_tap_port1 ? joystick_4[9] : joystick_1[9]),
	.but_2      (team_tap_port1 ? joystick_4[10] : joystick_1[10]),
	.but_3      (team_tap_port1 ? joystick_4[11] : joystick_1[11]),
	.but_4      (team_tap_port1 ? joystick_4[12] : joystick_1[12]),
	.but_5      (team_tap_port1 ? joystick_4[13] : joystick_1[13]),
	.but_6      (team_tap_port1 ? joystick_4[14] : joystick_1[14]),
	.but_7      (team_tap_port1 ? joystick_4[15] : joystick_1[15]),
	.but_8      (team_tap_port1 ? joystick_4[16] : joystick_1[16]),
	.but_9      (team_tap_port1 ? joystick_4[17] : joystick_1[17]),
	.but_0      (team_tap_port1 ? joystick_4[18] : joystick_1[18]),
	.but_star   (team_tap_port1 ? joystick_4[19] : joystick_1[19]),
	.but_hash   (team_tap_port1 ? joystick_4[20] : joystick_1[20])
);


reg [1:0] sp_out0;
reg [1:0] sp_out1;
wire [7:0] spthresh = spinner_speed[1] ? 12'h8<<spinner_speed : 12'h8>>spinner_speed;

always @(posedge sys_clk) begin
	reg [1:0] sp_prev;
	reg [11:0] accum_0;
	reg [11:0] accum_1;
	reg [8:0] spinner_0_abs;
	reg [8:0] spinner_1_abs;

	if (spinner_0[7]) begin
		spinner_0_abs <= -$signed(spinner_0[7:0]);
	end else begin
		spinner_0_abs <= spinner_0[7:0];
	end

	if (spinner_1[7]) begin
		spinner_1_abs <= -$signed(spinner_1[7:0]);
	end else begin
		spinner_1_abs <= spinner_1[7:0];
	end

	sp_prev <= {spinner_1[8], spinner_0[8]};
	if (spinner_0[8] != sp_prev[0]) begin
		accum_0 <= accum_0 + spinner_0_abs;
	end

	if (spinner_1[8] != sp_prev[1]) begin
		accum_1 <= accum_1 + spinner_1_abs;
	end

	if (ce_26_6_p3) begin
		if (accum_0 >= spthresh) begin
			case({spinner_0[7], sp_out0})
				{1'b1, 2'b00}: sp_out0 <= 2'b01;
				{1'b1, 2'b01}: sp_out0 <= 2'b11;
				{1'b1, 2'b11}: sp_out0 <= 2'b10;
				{1'b1, 2'b10}: sp_out0 <= 2'b00;
				{1'b0, 2'b00}: sp_out0 <= 2'b10;
				{1'b0, 2'b10}: sp_out0 <= 2'b11;
				{1'b0, 2'b11}: sp_out0 <= 2'b01;
				{1'b0, 2'b01}: sp_out0 <= 2'b00;
			endcase
			accum_0 <= 0;
		end

		if (accum_1 >= spthresh) begin
			case({spinner_1[7], sp_out1})
				{1'b1, 2'b00}: sp_out1 <= 2'b01;
				{1'b1, 2'b01}: sp_out1 <= 2'b11;
				{1'b1, 2'b11}: sp_out1 <= 2'b10;
				{1'b1, 2'b10}: sp_out1 <= 2'b00;
				{1'b0, 2'b00}: sp_out1 <= 2'b10;
				{1'b0, 2'b10}: sp_out1 <= 2'b11;
				{1'b0, 2'b11}: sp_out1 <= 2'b01;
				{1'b0, 2'b01}: sp_out1 <= 2'b00;
			endcase
			accum_1 <= 0;
		end
	end
end

// JOYSTICK INTERFACE
//
// There are two joystick connectors each of which is a 15-pin high
// density 'D' socket. The pinouts are as follows:
//
// PIN    J5        J6
// 1      JOY3      JOY4      /COL0 out
// 2      JOY2      JOY5      /COL1 out
// 3      JOY1      JOY6      /COL2 out
// 4      JOY0      JOY7      /COL3 out
// 5      PAD0X     PAD1X
// 6      BO/LP0    B2/LP1    /ROW0 in
// 7      +5V       +5V
// 8      NC        NC
// 9      GND       GND
// 10     B1        B3
// 11     JOY11     JOY15     /ROW1 in
// 12     JOY10     JOY14     /ROW2 in
// 13     JOY9      JOY13     /ROW3 in
// 14     JOY8      JOY12     /ROW4 in
// 15     PAD0Y     PAD1Y
//
assign joy[0] = ee_do;
assign joy[7:1] = ~j_xjoy_in[3] ? u374_reg[7:1] : 7'b1111_111;      // Port 1, pins 4:2. / Port 2, pins 4:1.

// Select the appropriate row data based on Team Tap configuration
wire [5:0] selected_joy1_row = team_tap_port1 ? team_tap_port1_row_n : joy1_row_n;
wire [5:0] selected_joy2_row = team_tap_port2 ? team_tap_port2_row_n : joy2_row_n;

assign joy[8]  = selected_joy1_row[5];        // Port 1, pin 14. Mouse XB.
assign joy[9]  = selected_joy1_row[4];        // Port 1, pin 13. Mouse XA.
assign joy[10] = selected_joy1_row[3];        // Port 1, pin 12. Mouse YA / Rotary Encoder XA.
assign joy[11] = selected_joy1_row[2];        // Port 1, pin 11. Mouse YB / Rotary Encoder XB.
assign b[1]    = selected_joy1_row[1];        // Port 1, pin 10. B1. Mouse Left Button / Rotary Encoder button.
assign b[0]    = selected_joy1_row[0];        // Port 1, pin 6. BO/Light Pen 0. Mouse Right Button.

assign joy[12] = selected_joy2_row[5];        // Port 2, pin 14.
assign joy[13] = selected_joy2_row[4];        // Port 2, pin 13.
assign joy[14] = selected_joy2_row[3];        // Port 2, pin 12.
assign joy[15] = selected_joy2_row[2];        // Port 2, pin 11.
assign b[3]    = selected_joy2_row[1];        // Port 2, pin 10. B3.
assign b[2]    = selected_joy2_row[0];        // Port 2, pin 6. B2/Light Pen 1.

assign b[4] = ntsc;             // 0=PAL, 1=NTSC
assign b[5] = 1'b1;             // 256 (number of columns of the DRAM)
assign b[6] = 1'b1;             // Unused open
assign b[7] = 1'b0;             // Unused short

always @(posedge sys_clk) begin
	u374_clk_prev <= j_xjoy_in[2];
	if (~u374_clk_prev & j_xjoy_in[2]) begin
		u374_reg[7:0] <= e_dbus[7:0];
	end
	if (~xresetl) begin
		u374_reg[7:0] <= 8'b11111111;
	end
end

assign joy_bus[7:0] =
	((~j_xjoy_in[0]) ? joy[7:0] : 8'hFF) &  // enables joystick on the ebus, which can be either the latch if xjoy_in[3] is low, or the joystick inputs.
	((~j_xjoy_in[1]) ? b[7:0] : 8'hFF);     // Enables system jumper "b bus" output onto the external bus.

assign joy_bus[15:8] = (~j_xjoy_in[0]) ? joy[15:8] : 8'b11111111; // Output enables the 16 joystick input pins onto the ebus. (upper byte).
assign joy_bus_oe = (~j_xjoy_in[0] | ~j_xjoy_in[1]);

// EEPROM INTERFACE
// Weird, but I don't see how it could work otherwise...
assign ee_cs = cd_en ? b_ee_cs : j_xgpiol_in[1];
assign ee_sk = cd_en ? b_ee_sk : j_xgpiol_in[0];
assign ee_di = cd_en ? b_ee_din : dbus[0];
wire ee_hintw = xwel[0];
assign b_ee_dout = ee_do;

// FIXME: ee_di should be e_dbus[0]. The schematic very clearly shows that the eternal bus is
// connected to the cart slot and thus the EEPROM. However, when the eeprom's address is put onto
// the address bus to trigger jerry's GPIO pins, it triggers tom to disconnect the external bus. I'm
// uncertain how this worked on a real system, but I can only guess there was some kind of delay in
// the eeprom's latching of DI.

eeprom eeprom_inst
(
	.sys_clk (sys_clk),
	.resetl  (xresetl),
	.autosize(auto_eeprom && !cd_en),
	.hintw   (ee_hintw),
	.cs      (ee_cs),
	.sk      (ee_sk),
	.din     (ee_di),
	.dout    (ee_do),

	.bram_addr( bram_addr ),
	.bram_data( bram_data ),
	.bram_q   ( bram_q ),
	.bram_wr  ( bram_wr )
);

assign abus_out[23:0] = {abus[23:3], xmaska[2:0]};

// OS ROM
assign os_rom_ce_n = xromcsl[0];
assign os_rom_oe_n = xoel[0];

// CART
assign cart_ce_n = xromcsl[1];
assign cart_oe_n[0] = xoel[0];
assign cart_oe_n[1] = xoel[1];

// TOM
wire tom_tlw;

_tom tom_inst
(
	.xbgl            (xbgl),
	.xdbrl           (xdbrl[1:0]),
	.xlp             (xlp),
	.xdint           (xdint),
	.xtest           (xtest),
	.xpclk           (j_xpclkout),
	.xvclk           (xvclk),
	.xwaitl          (xwaitl),
	.xresetl         (j_xresetl),
	.xd_out          (xd_out[63:0]),
	.xd_oe           (xd_oe[63:0]),
	.xd_in           (xd_in[63:0]),
	.xa_out          (xa_out[23:0]),
	.xa_oe           (xa_oe[23:0]),
	.xa_in           (xa_in[23:0]),
	.xma_out         (xma_out[10:0]),
	.xma_oe          (xma_oe[10:0]),
	.xma_in          (xma_in[10:0]),
	.xhs_out         (xhs_out),
	.xhs_oe          (xhs_oe),
	.xhs_in          (xhs_in),
	.xvs_out         (xvs_out),
	.xvs_oe          (xvs_oe),
	.xvs_in          (xvs_in),
	.xsiz_out        (xsiz_out[1:0]),
	.xsiz_oe         (xsiz_oe[1:0]),
	.xsiz_in         (xsiz_in[1:0]),
	.xfc_out         (xfc_out[2:0]),
	.xfc_oe          (xfc_oe[2:0]),
	.xfc_in          (xfc_in[2:0]),
	.xrw_out         (xrw_out),
	.xrw_oe          (xrw_oe),
	.xrw_in          (xrw_in),
	.xdreql_out      (xdreql_out),
	.xdreql_oe       (xdreql_oe),
	.xdreql_in       (xdreql_in),
	.xba_out         (xba_out),
	.xba_oe          (xba_oe),
	.xba_in          (xba_in),
	.xbrl_out        (xbrl_out),
	.xbrl_oe         (xbrl_oe),
	.xbrl_in         (xbrl_in),
	.xr              (xr[7:0]),
	.xg              (xg[7:0]),
	.xb              (xb[7:0]),
	.xinc            (xinc),
	.xoel            (xoel[2:0]),
	.xmaska          (xmaska[2:0]),
	.xromcsl         (xromcsl[1:0]),
	.xcasl           (xcasl[1:0]),
	.xdbgl           (xdbgl),
	.xexpl           (xexpl),
	.xdspcsl         (xdspcsl),
	.xwel            (xwel[7:0]),
	.xrasl           (xrasl[1:0]),
	.xdtackl         (xdtackl),
	.xintl           (xintl),
	// below signals NOT_NETLIST
	.hs_o            (hs_o),
	.hhs_o           (hhs_o),
	.vs_o            (vs_o),
	.refreq          (refreq),
	.obbreq          (obbreq),
	.bbreq           (bbreq[1:0]),
	.gbreq           (gbreq[1:0]),
	.blank           (blank),
	.hblank          (hblank),
	.vblank          (vblank),
//	.hsync           (vga_hs_n),
	.vsync           (vga_vs_n),
	.vvs             (vvs),
	.tlw             (tlw),
	.ram_rdy         (ram_rdy),
	.aen             (aen),
	.den             (den[2:0]),
	.sys_clk         (sys_clk),
	.startcas        (startcas),
	.d3a             (d3a),
	.d3b             (d3b),
	.we              (we[7:0]),
	.startwep        (startwep),
	.startwe         (startwe),
	.atp             (dram_addrp[10:3]),
	.vintbugfix      (vintbugfix),
	.turbo           (turbo)
);

assign vga_hs_n = ~xhs_out;
//assign vga_vs_n = ~xvs_out;

wire audio_clk;
wire jerry_tlw;

wire [15:0] dspwd;

_j_jerry jerry_inst
(
	.xdspcsl         (j_xdspcsl),
	.xpclkosc        (xvclk),
	.xpclkin         (j_xpclkin),
	.xdbgl           (j_xdbgl),
	.xoel_0          (j_xoel_0),
	.xwel_0          (j_xwel_0),
	.xserin          (j_xserin),
	.xdtackl         (j_xdtackl),
	.xi2srxd         (j_xi2srxd),
	.xeint           (j_xeint[1:0]),
	.xtest           (j_xtest),
	.xchrin          (j_xchrin),  // Should be 14.3mhz, ntsc clock. Not needed for fpga design.
	.xresetil        (xresetl),
	.xd_out          (j_xd_out[31:0]),
	.xd_oe           (j_xd_oe[31:0]),
	.xd_in           (j_xd_in[31:0]),
	.xa_out          (j_xa_out[23:0]),
	.xa_oe           (j_xa_oe[23:0]),
	.xa_in           (j_xa_in[23:0]),
	.xjoy_out        (j_xjoy_out[3:0]),
	.xjoy_oe         (j_xjoy_oe[3:0]),
	.xjoy_in         (j_xjoy_in[3:0]),
	.xgpiol_out      (j_xgpiol_out[5:0]), // 4 and 5 included
	.xgpiol_oe       (j_xgpiol_oe[3:0]),
	.xgpiol_in       (j_xgpiol_in[3:0]),
	.xsck_out        (j_xsck_out),
	.xsck_oe         (j_xsck_oe),
	.xsck_in         (j_xsck_in),
	.xws_out         (j_xws_out),
	.xws_oe          (j_xws_oe),
	.xws_in          (j_xws_in),
	.xvclk_out       (j_xvclk_out),
	.xvclk_oe        (j_xvclk_oe),
	.xvclk_in        (j_xvclk_in),
	.xsiz_out        (j_xsiz_out[1:0]),
	.xsiz_oe         (j_xsiz_oe[1:0]),
	.xsiz_in         (j_xsiz_in[1:0]),
	.xrw_out         (j_xrw_out),
	.xrw_oe          (j_xrw_oe),
	.xrw_in          (j_xrw_in),
	.xdreql_out      (j_xdreql_out),
	.xdreql_oe       (j_xdreql_oe),
	.xdreql_in       (j_xdreql_in),
	.xdbrl           (j_xdbrl[1:0]),
	.xint            (j_xint),
	.xserout         (j_xserout),
	.xvclkdiv        (j_xvclkdiv),
	.xchrdiv         (j_xchrdiv),
	.xpclkout        (j_xpclkout),
	.xpclkdiv        (j_xpclkdiv),
	.xresetl         (j_xresetl),
	.xchrout         (j_xchrout),
	.xrdac           (j_xrdac[1:0]),
	.xldac           (j_xldac[1:0]),
	.xiordl          (j_xiordl),
	.xiowrl          (j_xiowrl),
	.xi2stxd         (j_xi2stxd),
	.xcpuclk         (j_xcpuclk),
	.tlw             (tlw),
	.tlw_0           (tlw),
	.tlw_1           (tlw),
	.tlw_2           (tlw),
	.aen             (j_aen),
	.den             (j_den),
	.ainen           (j_ainen),
	.snd_l           (snd_l),
	.snd_r           (snd_r),
	.snd_clk         (audio_clk),
	.dspwd           (dspwd),
	.sys_clk         (sys_clk)
);

wire b_ewe0l = xwel[0];
wire b_ewe2l = xwel[2];
wire b_eoe0l = xoel[0];
wire b_eoe1l = xoel[1];
wire [31:0] b_dout;
wire b_doe;
wire b_ee_cs;
wire b_ee_sk;
wire b_ee_dout;
wire b_ee_din;
wire [31:0] cart_qt = b_doe ? b_dout : cart_q;
_butch butch_inst
(
	.resetl          (xresetl),
	.clk             (xvclk),
	.cart_ce_n       (cart_ce_n),
	.cd_en           (cd_en),
	.cd_ex           (cd_ex),
	.eoe0l           (b_eoe0l),
	.eoe1l           (b_eoe1l),
	.ewe0l           (b_ewe0l),
	.ewe2l           (b_ewe2l),
	.ain             (xa_in[23:0]),
	.din             (xd_in[31:0]),
	.dout            (b_dout[31:0]),
	.doe             (b_doe),
	.audbus_out      (audbus_out[28:0]),
	.aud_in          (aud_in[63:0]),
	.audwaitl        (audwaitl),
	.i2srxd          (j_xi2srxd),
	.eint            (j_xeint[0]),
	.sen             (b_xsck_oe),
	.sck             (b_xsck_out),
	.ws              (b_xws_out),
	.override        (b_override),
	.aud_ce          (aud_ce),
	.aud_sess        (aud_sess),
	.eeprom_cs       (b_ee_cs),
	.eeprom_sk       (b_ee_sk),
	.eeprom_dout     (b_ee_din),
	.eeprom_din      (b_ee_dout),
	.maxc            (maxc),
	.addr_ch3        (addr_ch3[23:0]),
	.toc_addr        (toc_addr),
	.toc_data        (toc_data),
	.toc_wr          (toc_wr),
	.dohacks (dohacks),
	.hackbus (hackbus),
	.hackbus1 (hackbus1),
	.hackbus2 (hackbus2),
	.overflowo (overflow),
	.underflowo (underflow),
	.errflowo (errflow),
	.unhandledo (unhandled),
	.sys_clk         (sys_clk)
);
wire b_xsck_oe;
wire b_xsck_out;
wire b_xws_oe = b_xsck_oe;
wire b_xws_out;
wire hackbus;
wire hackbus1;
wire hackbus2;
// Motorola 68000
wire fx68k_reset_pull, fx68k_halt_pull;
assign fx68k_halt      = ~fx68k_halt_pull & fx68k_rst;
assign fx68k_rst       = ~fx68k_reset_pull & j_xresetl & xresetl;
assign fx68k_dtack_n   = xdtackl;               // Should be able to just use xdtackl directly now, as the Bus Request signals are hooked up to FX68K.
assign fx68k_vpa_n     = 1'b1;                  // The real Jag has VPA_N on the 68K tied High, which means it's NOT using auto-vector for the interrupt. ElectronAsh.
assign fx68k_berr_n    = 1'b1;                  // The real Jag has BERR_N on the 68K tied High.
assign fx68k_ipl_n     = {1'b1, xintl, 1'b1};   // The Jag only uses Interrupt level 2 on the 68000.
assign fx68k_din       = hackbus ? 16'h0 : hackbus1 ? 16'h4e71: hackbus2 ? (dbus[15:0] ^ 16'h0100):dbus[15:0];
assign fx68k_br_n      = xbrl_in;               // Bus Request.
assign fx68k_bgack_n   = xba_in;                // Bus Grant Acknowledge.
assign fx68k_byte_addr = {fx68k_address, 1'b0};

// 74AC74 flip-flop for the 68K's BG signal, presumably to address one of the documented hardware bugs
flipflop xbgl_ff
(
	.sys_clk (sys_clk),
	.clk     (~fx68k_bg_n),
	.set     (fx68k_bgack_n),
	.data    (1'b0),
	.clear   (1'b1),
	.q       (xbgl)
);

assign fx68k_clk = turbo ? (ce_26_6_p1 | ce_26_6_p2) : j_xcpuclk;

m68kcpu m68k_inst
(
	.MCLK         (sys_clk),
	.CLK          (fx68k_clk),
	.VPA          (fx68k_vpa_n),
	.BR           (fx68k_br_n),
	.BGACK        (fx68k_bgack_n),
	.DTACK        (fx68k_dtack_n),
	.IPL          (fx68k_ipl_n),
	.BERR         (fx68k_berr_n),
	.RESET_i      (fx68k_rst),
	.RESET_pull   (fx68k_reset_pull),
	.HALT_i       (fx68k_halt),
	.HALT_pull    (fx68k_halt_pull),
	.DATA_i       (fx68k_din),
	.DATA_o       (fx68k_dout),
	.DATA_z       (fx68k_data_z),
	.E_CLK        (fx68k_e),
	.BG           (fx68k_bg_n),
	.FC           (fx68k_fc),
	.FC_z         (fx68k_fc_z),
	.RW           (fx68k_rw),
	.RW_z         (fx68k_rw_z),
	.ADDRESS      (fx68k_address),
	.ADDRESS_z    (fx68k_address_z),
	.AS           (fx68k_as_n),
	.LDS          (fx68k_lds_n),
	.UDS          (fx68k_uds_n),
	.strobe_z     ()
);

// NTSC Virtual Jaguar:
// 68000: 6525   GPU Internal: 88554   GPU External: 89907
// H/W NTSC:
// 68000: 2101   GPU Internal: 10545   GPU External: 11057
// H/W PAL:
// 68000: 2679   GPU Internal: 12865   GPU External: 13452
// Mister NTSC:
// 68000: 2168   GPU Internal: 10819   GPU External: 1138
/*
fx68k fx68k_inst
(
	.clk            (sys_clk),         // input system clock
	.HALTn          (1'b1),
	.extReset       (~j_xresetl),      // input
	.pwrUp          (fx68k_rst),       // input
	.enPhi1         (fx68k_phi1),      // input
	.enPhi2         (fx68k_phi2),      // input
	.eRWn           (fx68k_rw),        // output
	.ASn            (fx68k_as_n),      // output
	.LDSn           (fx68k_lds_n),     // output
	.UDSn           (fx68k_uds_n),     // output
	.E              (fx68k_e),         // output
	.VMAn           (fx68k_vma_n),     // output
	.FC0            (fx68k_fc[0]),     // output
	.FC1            (fx68k_fc[1]),     // output
	.FC2            (fx68k_fc[2]),     // output
//  .oRESETn        (oRESETn),         // output
//  .oHALTEDn       (oHALTEDn),        // output
	.DTACKn         (fx68k_dtack_n),   // input
	.VPAn           (fx68k_vpa_n),     // input - Tied HIGH on the real Jag.
	.BERRn          (fx68k_berr_n),    // input - Tied HIGH on the real Jag.
	.BRn            (fx68k_br_n),      // input
	.BGn            (fx68k_bg_n),      // output
	.BGACKn         (fx68k_bgack_n),   // input
	.IPL0n          (fx68k_ipl_n[0]),  // input
	.IPL1n          (fx68k_ipl_n[1]),  // input
	.IPL2n          (fx68k_ipl_n[2]),  // input
	.iEdb           (fx68k_din),       // input
	.oEdb           (fx68k_dout),      // output
	.eab            (fx68k_address)    // output
);
*/
// VIDEO / 15 KHz (native) output...
assign vga_r = xr[7:0];
assign vga_g = xg[7:0];
assign vga_b = xb[7:0];
//assign vga_b = {xb[7:1], 1'b0}; // FIXME: Real Jaguar has the LSB of blue disconnected for no obvious reason.

// AUDIO / I2S receiver
wire   i2s_ws   = j_xws_in;
wire   i2s_data = j_xi2stxd;
wire   i2s_clk  = j_xsck_in;
wire   qws;
wire   mute;

flipflop mute_ff
(
	.sys_clk (sys_clk),
	.clk     (j_xjoy_in[2]),
	.set     (1'b1),
	.data    (e_dbus[8]),
	.clear   (xresetl),
	.q       (mute)
);

flipflop i2s_ws_ff
(
	.sys_clk (sys_clk),
	.clk     (i2s_clk),
	.set     (1'b1),
	.data    (i2s_ws),
	.clear   (mute & xresetl),
	.q       (qws)
);

// Technically this should probably be run through a LPF but that can be
// done in at the top level by just setting a filter in the framework.
i2s_receiver i2s_receiver_inst
(
	.sys_clk  (sys_clk),
	.reset_n  (xresetl),
	.i2s_ws   (qws),
	.i2s_data (i2s_data),
	.i2s_clk  (i2s_clk),
	.left     (aud_16_l),
	.right    (aud_16_r)
);

endmodule

module eeprom
(
	input  sys_clk,
	input  resetl,
	input  autosize,
	input  hintw,
	input  cs,
	input  sk,
	input  din,
	output dout,

	output       [9:0]  bram_addr,
	output      [15:0]  bram_data,
	input       [15:0]  bram_q,
	output              bram_wr
);

`define EE_IDLE      3'b000
`define EE_DATA      3'b001
`define EE_READ      3'b010

`define EE_WR_BEGIN  3'b100
`define EE_WR_WRITE  3'b101
`define EE_WR_LOOP   3'b110
`define EE_WR_END    3'b111

reg          sk_prev = 1'b0;
reg          ee_type = 1'b0;   // 0 = 128 bytes/9bit ir -- 1 = 2048 bytes/13bit ir 
reg          detect = 1'b0; 
// autosize detect assumes first command after reset is pulsed cs signal then 9 or 13 bit command followed by cs or reads
// After cs then 9 bits, if next is not cs or write then is ee_type 0. Otherwise type 1.
//reg [15:0]   mem[0:(1<<6)-1];
reg          ewen = 1'b0;
reg [2:0]    status = `EE_IDLE;
reg [3:0]    cnt = 4'd0;           // Bit counter
reg [12:0]   ir = 13'd0;           // Instruction Register
reg [15:0]   dr = 16'd0;           // Data Register
reg          r_dout = 1'b1;        // Data Out
assign       dout = r_dout;

reg [9:0]    wraddr = 10'b0000000000;
reg [15:0]   wrdata = 16'hFFFF;
reg          wrloop = 1'b0;

wire [5:0]   irhi = ee_type ? ir[12:7] : ir[8:3];

assign       bram_addr = {status[2] ? wraddr : ee_type ? { ir[8:0], din } : { 4'h0,ir[4:0], din }};
assign       bram_data = wrdata;
assign       bram_wr = bram_wr_;
reg          bram_wr_;

always @(posedge sys_clk) begin
	sk_prev <= sk;
	bram_wr_ <= 1'b0;
	if (~cs || ~resetl) begin
		// Reset
		status <= `EE_IDLE;
		cnt <= 4'd0;
		ir <= 13'd0;
		dr <= 16'd0;
		r_dout <= 1'b1;
		wraddr <= 10'b0000000000;
		wrdata <= 16'hFFFF;
		wrloop <= 1'b0;
		if (detect) begin
			if (ir[9]) begin
				ee_type <= 1'b0;
				detect <= 1'b0;
			end
			if (ir[12]) begin
				ee_type <= 1'b1;
				detect <= 1'b0;
			end
		end
		if (~resetl) begin
			ewen <= 1'b0;
			ee_type <= 1'b0;
			detect <= autosize;
		end


	end else if (~sk_prev & sk) begin
		if (ir[9]) begin
			detect <= 1'b0;
		end
		if (status == `EE_IDLE) begin
			ir <= { ir[11:0], din };
			if (irhi[4]) begin // Instruction complete
				if (irhi[3:2] == 2'b10) begin
					// READ
					dr[15:0] <= bram_q[15:0];
					r_dout <= 1'b0; // Dummy bit
					status <= `EE_READ;
				end else if (irhi[3:0] == 4'b0011) begin
					// EWEN
					ewen <= 1'b1;
					status <= `EE_IDLE;
				end else if (irhi[3:2] == 2'b11) begin
					// ERASE
					status <= `EE_WR_BEGIN;
				end else if (irhi[3:2] == 2'b01) begin
					// WRITE
					status <= `EE_DATA;
				end else if (irhi[3:0] == 4'b0010) begin
					// ERAL
					status <= `EE_WR_BEGIN;
				end else if (irhi[3:0] == 4'b0001) begin
					// WRAL
					status <= `EE_DATA;
				end else if (irhi[3:0] == 4'b0000) begin
					// EWEN
					ewen <= 1'b0;
					status <= `EE_IDLE;
				end
			end
		end else if (status == `EE_DATA) begin
			detect <= 1'b0;
			dr <= { dr[14:0], din };
			cnt <= cnt + 4'd1;
			if (cnt == 4'b1111) begin
				status <= `EE_WR_BEGIN;
			end
		end else if (status == `EE_READ) begin
			detect <= 1'b0;
			r_dout <= dr[15];
			dr <= { dr[14:0], 1'b0 };
		end
	end else if (~sk && ~hintw && detect && ir[8]) begin
		ee_type <= 1'b1; //not read means 13 bit command
		detect <= 1'b0;
		status <= `EE_IDLE; // continue in progress command READ or EWEN
	end else if (status[2]) begin // Internal processing (writes)
		detect <= 1'b0;
		if (status == `EE_WR_BEGIN) begin
			r_dout <= 1'b0; // Busy
			status <= `EE_WR_WRITE;
			if (irhi[4:3] == 2'b11) begin
				// ERASE
				wraddr <= ee_type ? ir[9:0] : {4'h0,ir[5:0]};
				wrloop <= 1'b0;
				wrdata <= 16'hFFFF;
			end else if (irhi[4:3] == 2'b01) begin
				// WRITE
				wraddr <= ee_type ? ir[9:0] : {4'h0,ir[5:0]};
				wrloop <= 1'b0;
				wrdata <= dr;
			end else if (irhi[4:1] == 4'b0010) begin
				// ERAL
				wraddr <= 10'b0000000000;
				wrloop <= 1'b1;
				wrdata <= 16'hFFFF;
			end else if (irhi[4:1] == 4'b0001) begin
				// WRAL
				wraddr <= 10'b0000000000;
				wrloop <= 1'b1;
				wrdata <= dr;
			end
		end else if (status == `EE_WR_WRITE) begin
			if (ewen) begin
				bram_wr_ <= 1'b1;
			end
			status <= `EE_WR_LOOP;
		end else if (status == `EE_WR_LOOP) begin
			if (~wrloop) begin
				status <= `EE_WR_END;
			end else begin
				wraddr <= wraddr + 10'd1;
				if ((wraddr == 10'b1111111111) && (ee_type)) begin
					status <= `EE_WR_END;
				end else if ((wraddr[5:0] == 6'b111111) && (!ee_type)) begin
					status <= `EE_WR_END;
				end else begin
					status <= `EE_WR_WRITE;
				end
			end
		end else if (status == `EE_WR_END) begin
			r_dout <= 1'b1; // Ready
			status <= `EE_IDLE;
		end
	end
end

endmodule

module flipflop
(
	input sys_clk,
	input clk,   // Rising edge only
	input clear, // Active low
	input set,   // Active low
	input data,

	output q,
	output q_n
);

reg data_latch = 0;
reg old_clk = 0;

wire clk_rising_edge = ~old_clk & clk;

always @(posedge sys_clk) begin
	old_clk <= clk;
	if (clk_rising_edge)
		data_latch <= data;
	if (~clear)
		data_latch <= 1'b0;
	if (~set)
		data_latch <= 1'b1;
end

assign q = set ? (clear ? (clk_rising_edge ? data : data_latch) : 1'b0) : 1'b1;
assign q_n = (~set & ~clear) ? 1'b1 : ~q;

endmodule

module i2s_receiver
(
	input sys_clk,
	input reset_n,
	input i2s_clk,
	input i2s_ws,
	input i2s_data,
	output [15:0] left,
	output [15:0] right
);

reg [15:0] output_buffer_l;
reg [15:0] output_buffer_r;

assign left = output_buffer_l;
assign right = output_buffer_r;

always @(posedge sys_clk) begin : i2s_proc
	reg [15:0] i2s_buf[2];
	reg  [4:0] i2s_cnt;
	reg        old_clk, old_ws, side, i2s_next;

	// Latch data on falling edge
	old_clk <= i2s_clk;
	if (~i2s_clk && old_clk) begin
		if (~i2s_cnt[4]) begin // Ignore any bits that overflow
			i2s_cnt <= i2s_cnt + 1'd1;
			i2s_buf[side][4'd15 - i2s_cnt[3:0]] <= i2s_data;
		end
		old_ws <= i2s_ws;
		if (old_ws != i2s_ws)
			i2s_next <= 1;
	end

	// Check WS on rising edge
	if (i2s_clk && ~old_clk) begin
		if (i2s_next) begin
			i2s_cnt <= 0;
			side <= i2s_ws;
			i2s_next <= 0;

			if (~i2s_ws) begin
				i2s_buf[0] <= 16'd0;
				i2s_buf[1] <= 16'd0;
				output_buffer_l <= i2s_buf[0];
				output_buffer_r <= i2s_buf[1];
			end
		end
	end

	if (~reset_n) begin
		old_clk <= i2s_clk;
		old_ws <= i2s_ws;
		side <= i2s_ws;
		output_buffer_l <= 0;
		output_buffer_r <= 0;
	end
end

endmodule
