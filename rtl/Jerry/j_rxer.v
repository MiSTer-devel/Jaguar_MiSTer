//`include "defs.v"
// altera message_off 10036

module _j_rxer
(
	output rbf,
	output pe,
	output oe,
	output fe,
	output error,
	input clr_err,
	input paren,
	input even,
	input u2drd,
	input rxpol,
	input serin,
	input resetl,
	input bx16,
	input clk,
	output [15:0] dr_out,
	output dr_oe,
	input sys_clk // Generated
);
reg [9:0] rsr = 10'h0;
reg [7:0] rdr = 8'h0;
wire [9:0] nrsr;
reg rxins = 1'b0;
wire shiften;
reg shen = 1'b0;
wire rxen;
reg tfr = 1'b0;
wire ntfr;
reg tc = 1'b0;
wire nshen;
wire shena;
wire shenb;
wire shenc;
wire tbegin;
wire errorl;
reg go = 1'b0;
reg rxbrk = 1'b0;
wire nrxbrk;
wire nrxba;
wire nrxbb;
wire nrxbaa;
wire nrxbab;
wire setpol;
wire [2:0] rco;
reg [3:0] rxg = 4'h0;
wire [3:0] nrxg;
reg sync = 1'b0;
reg ro = 1'b0;
wire nro;
reg rod = 1'b0;
reg rxenw = 1'b0;
wire nrxen;
reg start = 1'b0;
wire nstart;
wire sta;
wire stb;
wire stc;
reg startd = 1'b0;
wire nsync;
wire ngo;
wire ngoa;
wire ngob;
reg [3:0] rdc = 4'h0;
wire [3:0] nrdc;
wire [2:0] co;
wire ci_0;
wire ntc;
reg rpar = 1'b0;
wire nrpar;
wire rpa;
wire rpb;
wire rpc;
wire rpd;
wire npe;
wire pea;
wire peb;
wire nfe;
wire fea;
wire feb;
wire fec;
wire feaa;
wire feab;
wire noe;
wire orea;
wire oreb;
wire nnrbf;
wire nrbf;
wire rbfa;
wire dataccl;
reg rds = 1'b0;
reg rdsd = 1'b0;

// Output buffers
reg rbf_obuf = 1'b0;
reg pe_obuf = 1'b0;
reg oe_obuf = 1'b0;
reg fe_obuf = 1'b0;
wire error_obuf;


// Output buffers
assign rbf = rbf_obuf;
assign pe = pe_obuf;
assign oe = oe_obuf;
assign fe = fe_obuf;
assign error = error_obuf;

reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// UART2.NET (169) - rsr[0-9] : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		rsr[9:0] <= nrsr[9:0];
	end
end

// UART2.NET (173) - nrsr[9] : mx2
// UART2.NET (174) - nrsr[0-8] : mx2
assign nrsr[9:0] = (shiften) ? {rxins,rsr[9:1]} : rsr[9:0];

// UART2.NET (176) - shiften : an2h
assign shiften = shen & rxen;

// UART2.NET (183) - dr[0-7] : ts
// UART2.NET (184) - dr[8-15] : ts
assign dr_out[15:0] = {8'h00,rdr[7:0]};
assign dr_oe = u2drd;

// UART2.NET (193) - rdr[0-7] : ldp1q
`ifdef FAST_CLOCK
always @(posedge sys_clk)
`else
always @(negedge sys_clk) // /!\
`endif
begin
	if (tfr) begin
		rdr[7:0] <= rsr[7:0];
	end
end

// UART2.NET (199) - tfri : fd1
// UART2.NET (203) - sheni : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		tfr <= ntfr;
		shen <= nshen;
	end
end

// UART2.NET (201) - ntfr : an6
assign ntfr = resetl & tc & rxen & ~tfr & shen;

// UART2.NET (205) - nshen : nd3
assign nshen = ~(shena & shenb & shenc);

// UART2.NET (206) - shena : nd6
assign shena = ~(resetl & rxen & tbegin & errorl & ~tfr & ~shen);

// UART2.NET (207) - shenb : nd4
assign shenb = ~(resetl & ~tc & ~tfr & shen);

// UART2.NET (208) - shenc : nd4
assign shenc = ~(resetl & ~rxen & ~tfr & shen);

// UART2.NET (211) - beg : an2
assign tbegin = go & ~rxbrk;

// UART2.NET (220) - rxbrki : fd2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			rxbrk <= 1'b0;
		end else begin
			rxbrk <= nrxbrk;
		end
	end
end

// UART2.NET (222) - nrxbrk : nd2
assign nrxbrk = ~(nrxba & nrxbb);

// UART2.NET (223) - nrxba : nd2
assign nrxba = ~(nrxbaa & nrxbab);

// UART2.NET (224) - nrxbb : nd2
assign nrxbb = ~(rxbrk & ~rxins);

// UART2.NET (226) - nrxbaa : an6
assign nrxbaa = &(~rsr[5:0]);

// UART2.NET (227) - nrxbab : an6
assign nrxbab = &(~rsr[7:6]) & tfr & ~rsr[9] & ~rxbrk;

// UART2.NET (236) - setpol : eo
assign setpol = serin ^ rxpol;

// UART2.NET (237) - rxins : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		rxins <= setpol;
	end
end

// UART2.NET (248) - rco[1-2] : an3
// UART2.NET (249) - rco[0] : an2
assign rco[2:0] = bx16 ? rxg[2:0] & {rco[1:0],1'b1} : 3'b0;

// UART2.NET (250) - rxg[0-3] : fd2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			rxg[3:0] <= 4'h0;
		end else begin
			rxg[3:0] <= nrxg[3:0];
		end
	end
end

// UART2.NET (254) - nrxg[3] : mx2g
// UART2.NET (255) - nrxg[2] : mx2g
// UART2.NET (256) - nrxg[1] : mx2g
// UART2.NET (257) - nrxg[0] : mx2g
assign nrxg[3:0] = sync ? 4'h0 : ({rco[2:0],bx16} ^ rxg[3:0]);

// UART2.NET (259) - ro : fd1q
// UART2.NET (262) - rod : fd1
// UART2.NET (265) - rxenw : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		ro <= nro;
		rod <= ro;
		rxenw <= nrxen;
	end
end

// UART2.NET (260) - nro : an6
assign nro = resetl & rxg[3:0]==4'h5 & bx16;

// UART2.NET (266) - nrxen : an3
assign nrxen = resetl & ro & ~rod;

// UART2.NET (267) - rxen : nivh
assign rxen = rxenw;

// UART2.NET (274) - start : fd2q
// UART2.NET (281) - startd : fd2
// UART2.NET (284) - sync : fd2q
// UART2.NET (288) - go : fd2
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			start <= 1'b0;
			startd <= 1'b0;
			sync <= 1'b0;
			go <= 1'b0;
		end else begin
			start <= nstart;
			startd <= start;
			sync <= nsync;
			go <= ngo;
		end
	end
end

// UART2.NET (275) - nstart : nd3
assign nstart = ~(sta & stb & stc);

// UART2.NET (276) - sta : nd4
assign sta = ~(~tfr & ~shen & ~rxins & ~rxbrk);

// UART2.NET (277) - stb : nd4
assign stb = ~(start & ~shen & errorl & ~rxbrk);

// UART2.NET (278) - stc : nd4
assign stc = ~(start & ~rxen & errorl & ~rxbrk);

// UART2.NET (286) - nsync : an2
assign nsync = start & ~startd;

// UART2.NET (289) - ngo : nd2
assign ngo = ~(ngoa & ngob);

// UART2.NET (290) - ngoa : nd4
assign ngoa = ~(~shen & go & errorl & ~rxbrk);

// UART2.NET (291) - ngob : nd4
assign ngob = ~(sync & ~go & errorl & ~rxbrk);

// UART2.NET (302) - rdc[0-3] : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		rdc[3:0] <= nrdc[3:0];
	end
end

// UART2.NET (306) - nrdc[1-3] : mx4
// UART2.NET (307) - nrdc[0] : mx2g
assign nrdc[3:0] = shen ? ({co[2:0],ci_0} ^ rdc[3:0]): 4'h0;

// UART2.NET (309) - co[2] : an3
// UART2.NET (310) - co[1] : an3
// UART2.NET (311) - co[0] : an2
assign co[2:0] = rxen ? {co[1:0],1'b1} & rdc[2:0] : 3'h0;

// UART2.NET (312) - ci[0] : an2
assign ci_0 = shen & rxen;

// UART2.NET (313) - tc : fd1
// UART2.NET (324) - rpar : fd1
// UART2.NET (335) - pe : fd1
// UART2.NET (347) - fe : fd1
// UART2.NET (366) - oe : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		tc <= ntc;
		rpar <= nrpar;
		pe_obuf <= npe;
		fe_obuf <= nfe;
		oe_obuf <= noe;
	end
end

// UART2.NET (314) - ntc : an6
assign ntc = resetl & rdc[3:0]==4'h9;

// UART2.NET (325) - nrpar : nd4
assign nrpar = ~(rpa & rpb & rpc & rpd);

// UART2.NET (326) - rpa : nd6
assign rpa = ~(resetl & paren & rxen & ~shen & even);

// UART2.NET (327) - rpb : nd6
assign rpb = ~(resetl & paren & rxen & shen & rpar & ~rxins);

// UART2.NET (328) - rpc : nd6
assign rpc = ~(resetl & paren & rxen & shen & ~rpar & rxins);

// UART2.NET (329) - rpd : nd4
assign rpd = ~(resetl & paren & ~rxen & rpar);

// UART2.NET (336) - npe : nd2
assign npe = ~(pea & peb);

// UART2.NET (337) - pea : nd4
assign pea = ~(resetl & tfr & rpar & ~pe);

// UART2.NET (338) - peb : nd3
assign peb = ~(resetl & pe_obuf & ~clr_err);

// UART2.NET (348) - nfe : an6
assign nfe = fea & feb & fec & resetl & ~clr_err;

// UART2.NET (349) - fea : nd2
assign fea = ~(feaa & feab);

// UART2.NET (350) - feb : nd3
assign feb = ~(~fe & tfr & rsr[9]);

// UART2.NET (351) - fec : nd2
assign fec = ~(~tfr & ~fe);

// UART2.NET (353) - feaa : an6
assign feaa = ~fe & tfr & rsr[3:0]==4'h0;

// UART2.NET (354) - feab : an6
assign feab = rsr[9:4]==6'h00;

// UART2.NET (367) - noe : nd2
assign noe = ~(orea & oreb);

// UART2.NET (368) - orea : nd6
assign orea = ~(resetl & ~clr_err & ~oe & rbf_obuf & tfr);

// UART2.NET (369) - oreb : nd3
assign oreb = ~(resetl & ~clr_err & oe_obuf);

// UART2.NET (376) - error : or3
assign error_obuf = pe_obuf | oe_obuf | fe_obuf;

// UART2.NET (377) - errorl : iv
assign errorl = ~error_obuf;

// UART2.NET (387) - rbf : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			rbf_obuf <= 1'b0;
		end else begin
			rbf_obuf <= nnrbf;
		end
	end
end

// UART2.NET (388) - nnrbf : an2
assign nnrbf = nrbf & ~rxbrk;

// UART2.NET (389) - nrbf : nd2
assign nrbf = ~(~tfr & rbfa);

// UART2.NET (390) - rbfa : nd2
assign rbfa = ~(rbf_obuf & dataccl);

// UART2.NET (393) - datacc : nd2
assign dataccl = ~(~rdsd & rds);

// UART2.NET (394) - rds : fd1q
// UART2.NET (395) - rdsd : fd1
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		rds <= u2drd;
		rdsd <= rds;
	end
end

endmodule
