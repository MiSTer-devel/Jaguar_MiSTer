//`include "defs.v"

module _dcontrol
(
	output [2:0] daddasel,
	output [2:0] daddbsel,
	output [2:0] daddmode,
	output [1:0] data_sel,
	output daddq_sel,
	output gourd,
	output gourz,
	output patdadd,
	output patfadd,
	output srcz1add,
	output srcz2add,
	input [1:0] atick,
	input clk,
	input cmdld,
	input dwrite,
	input dzwrite,
	input dzwrite1,
	input [31:0] gpu_din,
	input srcdreadd,
	input srcshade,
	input sys_clk // Generated
);
reg topben = 1'b0;
reg topnen = 1'b0;
reg patdsel = 1'b0;
reg adddsel = 1'b0;
wire atickboth;
wire shadeadd;
wire [1:0] dasel0t;
wire [1:0]dbsel0t;
wire [1:0] dbsel2t;
wire [4:0] dm0t;
wire [2:0] dm1t;
wire srcshadd;
reg dzwrite1d = 1'b0;
wire dsel0t;

// Output buffers
reg gourd_obuf = 1'b0;
reg gourz_obuf = 1'b0;
wire patdadd_obuf;
wire patfadd_obuf;
wire srcz1add_obuf;
wire srcz2add_obuf;

//wire resetl = xreset_n;
reg old_clk;
//reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
//	old_resetl <= resetl;
end

// Output buffers
assign gourd = gourd_obuf;
assign gourz = gourz_obuf;
assign patdadd = patdadd_obuf;
assign patfadd = patfadd_obuf;
assign srcz1add = srcz1add_obuf;
assign srcz2add = srcz2add_obuf;


// DCONTROL.NET (40) - gourd : fdsyncm
// DCONTROL.NET (41) - gourz : fdsyncm
// DCONTROL.NET (42) - topben : fdsync
// DCONTROL.NET (43) - topnen : fdsync
// DCONTROL.NET (44) - patdsel : fdsync
// DCONTROL.NET (45) - adddsel : fdsync
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		if (cmdld) begin
			gourd_obuf <= gpu_din[12];
			gourz_obuf <= gpu_din[13];
			topben <= gpu_din[14];
			topnen <= gpu_din[15];
			patdsel <= gpu_din[16];
			adddsel <= gpu_din[17];
		end
	end
end

// DCONTROL.NET (53) - atickboth : or2p
assign atickboth = |atick[1:0];

// DCONTROL.NET (70) - shadeadd\ : nd2p
assign shadeadd = (dwrite & srcshade);

// DCONTROL.NET (72) - dasel0t0 : nd3
assign dasel0t[0] = ~(dwrite & gourd_obuf & atick[1]);

// DCONTROL.NET (73) - dasel0t1 : nd3
assign dasel0t[1] = ~(dzwrite & gourz_obuf & atick[0]);

// DCONTROL.NET (74) - daddasel[0] : nd2p
assign daddasel[0] = ~(&dasel0t[1:0]);

// DCONTROL.NET (75) - daddasel[1] : an3p
assign daddasel[1] = dzwrite & gourz_obuf & atickboth;

// DCONTROL.NET (76) - daddasel[2] : or3p
assign daddasel[2] = gourd_obuf | gourz_obuf | shadeadd;

// DCONTROL.NET (94) - dbsel0t0 : nd3
assign dbsel0t[0] = ~(dwrite & gourd_obuf & atick[1]);

// DCONTROL.NET (95) - dbsel0t1 : nd3
assign dbsel0t[1] = ~(dzwrite & gourz_obuf & atick[1]);

// DCONTROL.NET (96) - daddbsel[0] : nd3p
assign daddbsel[0] = ~(&dbsel0t[1:0] & ~shadeadd);

// DCONTROL.NET (97) - daddbsel[1] : an3p
assign daddbsel[1] = dzwrite & gourz_obuf & atickboth;

// DCONTROL.NET (98) - dbsel2t0 : nd3
assign dbsel2t[0] = ~(dwrite & gourd_obuf & atickboth);

// DCONTROL.NET (99) - dbsel2t1 : nd3
assign dbsel2t[1] = ~(dzwrite & gourz_obuf & atickboth);

// DCONTROL.NET (100) - daddbsel[2] : nd3p
assign daddbsel[2] = ~(&dbsel2t[1:0] & ~shadeadd);

// DCONTROL.NET (133) - dm0t0 : nd3
assign dm0t[0] = ~(dzwrite & gourz_obuf & atick[1]);

// DCONTROL.NET (134) - dm0t1 : en
assign dm0t[1] = ~(topben ^ topnen);

// DCONTROL.NET (135) - dm0t2 : nd4
assign dm0t[2] = ~(dwrite & gourd_obuf & atick[1] & dm0t[1]);

// DCONTROL.NET (136) - dm0t3 : nd3
assign dm0t[3] = ~(~gourd & ~gourz & dm0t[1]);

// DCONTROL.NET (137) - dm0t4 : nd2
assign dm0t[4] = ~(shadeadd & dm0t[1]);

// DCONTROL.NET (138) - daddmode[0] : nd4p
assign daddmode[0] = ~(&dm0t[4:0]);

// DCONTROL.NET (140) - dm1t0 : nd4
assign dm1t[0] = ~(dwrite & gourd_obuf & atick[1] & ~topben);

// DCONTROL.NET (141) - dm1t1 : nd3
assign dm1t[1] = ~(~gourd & ~gourz & ~topben);

// DCONTROL.NET (142) - dm1t2 : nd2
assign dm1t[2] = ~(shadeadd & ~topben);

// DCONTROL.NET (143) - daddmode[1] : nd3h
assign daddmode[1] = ~(&dm1t[2:0]);

// DCONTROL.NET (145) - daddmode[2] : aor1p
assign daddmode[2] = (~gourd & ~gourz) | shadeadd;

// DCONTROL.NET (160) - patfadd : an3
assign patfadd_obuf = dwrite & gourd_obuf & atick[0];

// DCONTROL.NET (161) - patdadd : an3
assign patdadd_obuf = dwrite & gourd_obuf & atick[1];

// DCONTROL.NET (162) - srcz1add : an3
assign srcz1add_obuf = dzwrite & gourz_obuf & atick[1];

// DCONTROL.NET (163) - srcz2add : an3
assign srcz2add_obuf = dzwrite & gourz_obuf & atick[0];

// DCONTROL.NET (164) - srcshadd : an2
assign srcshadd = srcdreadd & srcshade;

// DCONTROL.NET (165) - daddq_sel : or5
assign daddq_sel = patfadd_obuf | patdadd_obuf | srcz1add_obuf | srcz2add_obuf | srcshadd;

// DCONTROL.NET (185) - dzwrite1d : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		dzwrite1d <= dzwrite1;
	end
end

// DCONTROL.NET (187) - dsel0t : nr2
assign dsel0t = ~(patdsel | adddsel);

// DCONTROL.NET (188) - data_sel[0] : or2
assign data_sel[0] = dzwrite1d | dsel0t;

// DCONTROL.NET (190) - data_sel[1] : or2
assign data_sel[1] = dzwrite1d | adddsel;
endmodule

