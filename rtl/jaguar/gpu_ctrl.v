//`include "defs.v"

module _gpu_ctrl
(
	output [15:0] gpu_dout_out,// 6-10 not used
	output gpu_dout_5_0_oe,
	output gpu_dout_15_11_oe,
	output bus_hog,
	output cpu_int,
	output go,
	output gpu_irq_0,
	output single_go,
	output single_step,
	input clk,
	input ctrlwr,
	input ctrlwrgo, //tom only; set to ctrlwr
	input [31:0] gpu_din,
	input reset_n,
	input single_stop,
	input statrd,
	input sys_clk // Generated
);
wire goi;
reg got = 1'b0;
wire cpu_intt;
reg cpu_int_ = 1'b0;
reg gpu_irq_ = 1'b0;
wire gpu_intt;
wire single_got;
reg single_go_ = 1'b0;

// Output buffers
reg bus_hog_obuf = 1'b0;
reg single_step_ = 1'b0;
wire go_obuf;

wire resetl = reset_n; 
reg old_clk;
reg old_resetl;
always @(posedge sys_clk)
begin
	old_clk <= clk;
	old_resetl <= resetl;
end

// Output buffers
assign bus_hog = bus_hog_obuf;
assign go = go_obuf;
assign cpu_int = cpu_int_;
assign gpu_irq_0 = gpu_irq_;
assign single_step = single_step_;
assign single_go = single_go_;

// GPU_CTRL.NET (39) - goi : mx2
assign goi = (ctrlwrgo) ? gpu_din[0] : go_obuf;

// GPU_CTRL.NET (40) - got : fd2q
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			got <= 1'b0; // always @(posedge cp or negedge cd)
		end else begin
			got <= goi;
		end
	end
end

// GPU_CTRL.NET (41) - go : nivh
assign go_obuf = got;

// GPU_CTRL.NET (43) - cpu_intt : an2
assign cpu_intt = ctrlwr & gpu_din[1];

// GPU_CTRL.NET (44) - cpu_int : fd1q
// GPU_CTRL.NET (47) - gpu_int : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		cpu_int_ <= cpu_intt;
		gpu_irq_ <= gpu_intt;
	end
end

// GPU_CTRL.NET (46) - gpu_intt : an2
assign gpu_intt = ctrlwr & gpu_din[2];

// GPU_CTRL.NET (49) - single_step : fdsyncr
// GPU_CTRL.NET (55) - bus_hog : fdsyncr
always @(posedge sys_clk)
begin
	if ((~old_clk && clk) | (old_resetl && ~resetl)) begin
		if (~resetl) begin
			single_step_ <= 1'b0;
			bus_hog_obuf <= 1'b0;
		end else if (ctrlwr) begin
			single_step_ <= gpu_din[3];
			bus_hog_obuf <= gpu_din[11];
		end
	end
end

// GPU_CTRL.NET (52) - single_got : an2
assign single_got = ctrlwr & gpu_din[4];

// GPU_CTRL.NET (53) - single_go : fd1q
always @(posedge sys_clk)
begin
	if (~old_clk && clk) begin
		single_go_ <= single_got;
	end
end

// GPU_CTRL.NET (60) - stat[0] : ts
// GPU_CTRL.NET (61) - stat[1-2] : ts
// GPU_CTRL.NET (62) - stat[3] : ts
// GPU_CTRL.NET (63) - stat[4] : ts
// GPU_CTRL.NET (64) - stat[5] : ts
assign gpu_dout_5_0_oe = statrd;
assign gpu_dout_out[0] = go_obuf;
assign gpu_dout_out[1] = 1'b0;
assign gpu_dout_out[2] = 1'b0;
assign gpu_dout_out[3] = single_stop;
assign gpu_dout_out[4] = 1'b0;
assign gpu_dout_out[5] = 1'b0;
assign gpu_dout_out[10:6] = 5'h0; // not used

// GPU_CTRL.NET (65) - stat[11] : ts
// GPU_CTRL.NET (72) - stat[12] : ts
// GPU_CTRL.NET (73) - stat[13] : ts
// GPU_CTRL.NET (74) - stat[14] : ts
// GPU_CTRL.NET (75) - stat[15] : ts
assign gpu_dout_15_11_oe = statrd;
assign gpu_dout_out[11] = bus_hog_obuf;
assign gpu_dout_out[12] = 1'b0;
assign gpu_dout_out[13] = 1'b1;
assign gpu_dout_out[14] = 1'b0;
assign gpu_dout_out[15] = 1'b0;
endmodule
