//`include "defs.v"

module _pc
(
	output [22:0] pc,
	output [23:0] program_count,
	input clk,
	input go,
	input [31:0] gpu_din,
	input progack,
	input jabs,
	input jrel,
	input pcwr,
	input [2:0] qs_n,
	input reset_n,
	input [31:0] srcd,
	input [31:0] srcdp,
	input sys_clk // Generated
);
wire [22:0] subq;
wire go_n;
wire jrel_n;
wire zerob;
wire [22:0] adda;
wire [22:0] addb;
wire [22:0] pcadd;
wire loadpc;
wire [1:0] sel;
wire sel1t0;
wire sel1t1;
wire [22:0] pcin;

// Output buffers
reg [22:0] pc_obuf = 23'h7F8004;// reset pc is ff0008

wire resetl = reset_n; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign pc[22:0] = pc_obuf[22:0];

// PREFETCH.NET (304) - go\ : iv
assign go_n = ~go;

// PREFETCH.NET (305) - jrel\ : iv
assign jrel_n = ~jrel;

// PREFETCH.NET (312) - sub : subsize
assign subq[22:0] = pc_obuf[22:0] - {20'h0,~qs_n[2:0]} - 23'h1;

// PREFETCH.NET (314) - program_count : join
assign program_count[23:0] = {subq[22:0],1'b0};

// PREFETCH.NET (318) - adda[0] : an2
assign adda[0] = subq[0] & jrel;

// PREFETCH.NET (319) - adda[1-22] : mx2
assign adda[22:1] = (jrel) ? subq[22:1] : pc_obuf[22:1];

// PREFETCH.NET (321) - addb[0] : an2
assign addb[0] = srcdp[0] & jrel;

// PREFETCH.NET (322) - addb[1] : or2
assign addb[1] = srcdp[1] | jrel_n;

// PREFETCH.NET (323) - addb[2-22] : an2
assign addb[22:2] = jrel ? srcdp[22:2] : 21'h0;

// PREFETCH.NET (325) - pcadd : fa23
assign pcadd[22:0] = adda[22:0] + addb[22:0];

// PREFETCH.NET (335) - loadpc : an2
assign loadpc = pcwr & go_n;

// PREFETCH.NET (336) - sel0 : or2u
assign sel[0] = jabs | loadpc;

// PREFETCH.NET (337) - sel1t0 : nr2
assign sel1t0 = ~(progack | jrel);

// PREFETCH.NET (338) - sel1t1 : nr2
assign sel1t1 = ~(sel1t0 | jabs);

// PREFETCH.NET (339) - sel1 : or2u
assign sel[1] = sel1t1 | loadpc;

// PREFETCH.NET (341) - pcin[0-22] : mx4
assign pcin[22:0] = sel[1] ? (sel[0] ? gpu_din[23:1] : pcadd[22:0]) : (sel[0] ? srcd[23:1] : pc[22:0]);

// PREFETCH.NET (349) - pc[0-1] : fd2q
// PREFETCH.NET (350) - pc[2] : fd4q
// PREFETCH.NET (351) - pc[3-14] : fd2q
// PREFETCH.NET (352) - pc[15-22] : fd4q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			pc_obuf[22:0] <= 23'h7F8004;// reset pc is ff0008 // always @(posedge cp or negedge cd)
		end else begin
			pc_obuf[22:0] <= pcin[22:0];
		end
	end
end

// PREFETCH.NET (353) - pc : join
assign pc[22:0] = pc_obuf[22:0];
endmodule
