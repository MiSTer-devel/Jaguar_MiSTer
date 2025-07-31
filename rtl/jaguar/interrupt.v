//`include "defs.v"
// altera message_off 10036

module _interrupt
(
	output [13:3] gpu_dout_out,
	output gpu_dout_13_3_oe,
	output gpu_dout_10_6_oe,
	output [17:16] gpu_dout_hi_out, // jerry only
	output gpu_dout_17_16_oe, // jerry only
	output imaski,
	output [15:0] intins,
	output intser,
	input atomic,
	input clk,
	input [31:0] gpu_din,
	input flagrd,
	input flagwr,
	input [5:0] gpu_irq, // gpu_irq[5] = jerry only
	input reset_n,
	input romold,
	input statrd,
	input sys_clk // Generated
);
parameter JERRY = 0;

wire [2:0] _int;
wire [15:0] ins [0:7];
wire zero;
wire atomic_n;
reg [5:0] int_ena = 6'h0;
wire [5:0] ilclr_n;
wire [5:0] ilt;
reg [5:0] ilatch = 6'h0;
wire [5:0] irqm_n;
wire [5:0] ils;
wire irq;
wire ilatch_n_1;
wire int0t0;
wire int0t1;
wire int0t2;
wire int1t0;
wire int1t1;
wire isrset;
wire intser_n;
wire imask_n;
wire isrclr;
wire jumped;
reg intsert = 1'b0;
wire isrt0;
wire isrt1;
wire imset_n;
wire imclr_n;
wire imt_0;
reg imask = 1'b0;
wire cnten;
reg [2:0] icount = 3'h0;

// Output buffers
wire imaski_obuf;
wire intser_obuf;

wire resetl = reset_n; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign imaski = imaski_obuf;
assign intser = intser_obuf;

// INTER-UA.NET (43) - atomic\ : iv
assign atomic_n = ~atomic;

// INTER-UA.NET (51) - int_ena[0-4] : fdsyncr
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			int_ena[5:0] <= 5'h0;
		end else if (flagwr) begin
			int_ena[4:0] <= gpu_din[8:4];
			int_ena[5] <= gpu_din[16] & JERRY!=0;
		end
	end
end

// INTER-UA.NET (58) - ilclr\[0-4] : nd2
assign ilclr_n[4:0] = ~(flagwr ? gpu_din[13:9] : 5'h0);
assign ilclr_n[5] = ~(flagwr ? gpu_din[17] : 1'b0);

// INTER-UA.NET (59) - ilt[0-4] : nd2
assign ilt[5:0] = ~(ilatch[5:0] & ilclr_n[5:0]);

// INTER-UA.NET (60) - gpu_irqm[0-4] : nd2
assign irqm_n[5:0] = ~(gpu_irq[5:0] & int_ena[5:0]);

// INTER-UA.NET (61) - ils[0-4] : nd2
assign ils[5:0] = ~(irqm_n[5:0] & ilt[5:0]);

// INTER-UA.NET (62) - ilatch[0-4] : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			ilatch[5:0] <= 6'h0;
		end else begin
			ilatch[5:0] <= ils[5:0];
		end
	end
end

// INTER-UA.NET (66) - flagrd[4-8] : ts
assign gpu_dout_out[5:4] = int_ena[1:0];
assign gpu_dout_13_3_oe = flagrd;
//assign gpu_dout_out[8:6] = int_ena[4:2];

// INTER-UA.NET (67) - flagrd[9-13] : ts
//assign gpu_dout_out[10:9] = 2'h0;
assign gpu_dout_out[13:11] = 3'h0;

// INTER-UA.NET (68) - statrd[6-10] : ts
//assign gpu_dout_out[10:6] = ilatch[4:0];

// --- Compiler-generated PE for BUS gpu_dout[6]
assign gpu_dout_out[10:6] = (flagrd ? {2'b00,int_ena[4:2]}:5'h0) | (statrd ? {ilatch[4:0]}:5'h0);
assign gpu_dout_10_6_oe = flagrd | statrd;
assign gpu_dout_hi_out[17:16] = {1'b0,(flagrd & int_ena[5]) | (statrd & ilatch[5])};
assign gpu_dout_17_16_oe = (flagrd | statrd) & JERRY!=0;

// INTER-UA.NET (72) - irq : or5
assign irq = |ilatch[5:0];

// This logic is optimized version of converting msb set to int[2:0] (5 is jerry only)
// int[2:0] = ilatch[5] ? 3'h5 : ilatch[4] ? 3'h4 : ilatch[3] ? 3'h3 : ilatch[2] ? 3'h2 : ilatch[1] ? 3'h1 : 3'h0; 
// INTER-UA.NET (82) - ilatch\[1] : iv
assign ilatch_n_1 = ~ilatch[1];

// INTER-UA.NET (83) - int0t0 : nr2
assign int0t0 = ~(~ilatch[1] | ilatch[2]);

// INTER-UA.NET (84) - int0t1 : nr2
assign int0t1 = ~(ilatch[3] | int0t0);

// INTER-UA.NET (85) - int[0] : nr2
assign int0t2 = ~(ilatch[4] | int0t1);
assign _int[0] = (ilatch[5] | int0t2);

// INTER-UA.NET (86) - int1t : nr2
assign int1t0 = |ilatch[3:2];

// INTER-UA.NET (87) - int[1] : nr2
assign int1t1 = ~(|ilatch[5:4]);
assign _int[1] = (int1t1 & int1t0);

// INTER-UA.NET (88) - int : join
assign _int[2] = |ilatch[5:4];

// INTER-UA.NET (97) - isrset : an4
assign isrset = irq & intser_n & imask_n & atomic_n;

// INTER-UA.NET (98) - isrclr : an2
assign isrclr = jumped & intsert;

// INTER-UA.NET (99) - isrt0 : nr2
assign isrt0 = ~(isrset | intsert);

// INTER-UA.NET (100) - isrt1 : nr2
assign isrt1 = ~(isrt0 | isrclr);

// INTER-UA.NET (101) - intsert : fd2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			intsert <= 1'b0;
		end else begin
			intsert <= isrt1;
		end
	end
end
assign intser_n = ~intsert;

// INTER-UA.NET (102) - intser : nivh
assign intser_obuf = intsert;

// INTER-UA.NET (109) - imset : nd2
assign imset_n = ~(romold & intser_obuf);

// INTER-UA.NET (111) - imclr : nd2
assign imclr_n = ~(flagwr & ~gpu_din[3]);

// INTER-UA.NET (112) - imt0 : nd2
assign imt_0 = ~(imask & imclr_n);

// INTER-UA.NET (113) - imt1 : nd2
assign imaski_obuf = ~(imset_n & imt_0);

// INTER-UA.NET (114) - imask : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			imask <= 1'b0;
		end else begin
			imask <= imaski_obuf;
		end
	end
end

// INTER-UA.NET (115) - imask\ : iv
assign imask_n = ~imask;

// INTER-UA.NET (116) - flagrd[3] : ts
assign gpu_dout_out[3] = imask;
//assign gpu_dout_13_3_oe = flagrd;

// INTER-UA.NET (122) - cnten : an2
assign cnten = romold & intser_obuf;

// INTER-UA.NET (123) - cnter : cnte3
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			icount[2:0] <= 3'h0;
		end else if (cnten) begin
			icount[2:0] <= icount[2:0] + 3'h1;
		end
	end
end

// INTER-UA.NET (125) - jumped : an4
assign jumped = romold & (&icount[2:0]);

//000111 00100 11111 	subqt	r31,4
//110011 00000 11110	move	r30,pc 
//101111 11111 11110	store	(r31),r30
//100110 00000 11110	movei	r30,service address
//---  service  ----	(low word)
//---  address  ----	(high word)
//110100 11110 00000	jump	(r30)
//111001 00000 00000	nop
// The service address is based on 00F03000h (00F1B000h=Jerry), plus 16 * the interrupt
// number - to allow 8 instructions at each location, enough for
// a jump or a simple acknowledge.
// INTER-UA.NET (144) - ins0 : join
// INTER-UA.NET (145) - ins1 : join
// INTER-UA.NET (146) - ins2 : join
// INTER-UA.NET (147) - ins3 : join
// INTER-UA.NET (148) - ins4 : join
// INTER-UA.NET (149) - ins5 : join
// INTER-UA.NET (150) - ins6 : join
// INTER-UA.NET (151) - ins7 : join
assign ins[0] = 16'h1C9F;
assign ins[1] = 16'hCC1E;
assign ins[2] = 16'hBFFE;
assign ins[3] = 16'h981E;
assign ins[4] = {(JERRY!=0 ? 8'hB0: 8'h30),1'b0,_int[2:0],4'h0};//16'h3000-70
assign ins[5] = (JERRY!=0 ? 16'h00F1 : 16'h00F0);
assign ins[6] = 16'hD3C0;
assign ins[7] = 16'hE400;

// INTER-UA.NET (153) - inssel : mx8p
assign intins[15:0] = ins[icount[2:0]][15:0];

endmodule
