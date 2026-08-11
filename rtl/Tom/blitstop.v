//`include "defs.v"

module _blitstop
(
	output gpu_dout_1_out,
	output gpu_dout_1_oe,
	output stopped,
	output reset_n,
	input clk,
	input dwrite_1,
	input [31:0] gpu_din,
	input nowrite,
	input statrd,
	input stopld,
	input xreset_n,
	input sys_clk // Generated
);
wire resume_n;
wire coll_abort_n;
wire coll_abort;
reg stopen = 1'b0;
wire collidea;
reg collideb = 1'b0;
wire collide;
wire idle;
reg drv_reset = 1'b0;
wire [2:0] stt;
wire drst;

// Output buffers
reg stopped_obuf = 1'b0;

wire resetl = xreset_n;
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign stopped = stopped_obuf;


// BLITSTOP.NET (38) - resume\ : nd2
assign resume_n = ~(stopld & gpu_din[0]);

// BLITSTOP.NET (39) - coll_abort\ : nd2
assign coll_abort_n = ~(stopld & gpu_din[1]);

// BLITSTOP.NET (40) - coll_abort : iv
assign coll_abort = ~coll_abort_n;

// BLITSTOP.NET (41) - stopen : fdsyncr
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			stopen <= 1'b0;
		end else begin
			if (stopld) begin
				stopen <= gpu_din[2];
			end
		end
	end
end

// BLITSTOP.NET (46) - stat[1] : ts
assign gpu_dout_1_out = stopped_obuf;
assign gpu_dout_1_oe = statrd;

// BLITSTOP.NET (53) - collidea : an3
assign collidea = nowrite & stopen & dwrite_1;

// BLITSTOP.NET (54) - collideb : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		collideb <= collidea;
	end
end

// BLITSTOP.NET (56) - collide : an2
assign collide = collidea & ~collideb;

// BLITSTOP.NET (60) - idle : nr2
assign idle = ~(stopped_obuf | drv_reset);

// BLITSTOP.NET (62) - stt0 : nd2
assign stt[0] = ~(idle & collide);

// BLITSTOP.NET (63) - stt1 : nd3
assign stt[1] = ~(stopped_obuf & resume_n & coll_abort_n);

// BLITSTOP.NET (64) - stt2 : nd2
assign stt[2] = ~(&stt[1:0]);

// BLITSTOP.NET (65) - stopped : fd2q
// BLITSTOP.NET (68) - drv_reset : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			stopped_obuf <= 1'b0;
			drv_reset <= 1'b0;
		end else begin
			stopped_obuf <= stt[2];
			drv_reset <= drst;
		end
	end
end

// BLITSTOP.NET (67) - drst : an2
assign drst = stopped_obuf & coll_abort;

// BLITSTOP.NET (74) - reset\ : an2u
assign reset_n = xreset_n & ~drv_reset;
endmodule
