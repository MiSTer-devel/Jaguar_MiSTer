//`include "defs.v"

module _aba032a
(
	output	[31:0]	z_out,
	output		z_oe,
	input		[31:0]	z_in,
	input						cs,
	input						we,
	input		[9:0]		a,
	input						sys_clk
);
wire [9:0]	a_r;
wire [31:0]	z_out_r;
wire	[31:0]	z_in_r;

assign a_r[9:0] = a[9:0];

assign z_out[31:0] = z_out_r[31:0];

assign z_in_r[31:0] = z_in[31:0];

`ifdef SIMULATION
	reg [31:0]	r_z_out_r;
	reg	[31:0]	r_z_out_r_dly;
	reg	r_z_oe = 1'b0;
	// reg	[0:31]	r_z_oe_dly = 16'h00000000;

	reg	[31:0]	ram_blk [0:(1<<10)-1];

	// assign z_oe = r_z_oe_dly;
	// assign z_out_r = r_z_out_r;
	assign z_out_r = r_z_out_r_dly;
	assign z_oe = r_z_oe;

	always @(posedge sys_clk)
	begin
		r_z_out_r_dly <= r_z_out_r;
		// r_z_oe_dly <= r_z_oe;	
		if (~cs) begin
			if (~we) begin
				ram_blk[a_r][31:0] <= z_in_r;
			end
		end
		r_z_out_r <= ram_blk[a_r][31:0];
		r_z_oe <= (~cs & we) ? 1'b1 : 1'b0;
	end
`else	
	wire	wren;
	reg	r_z_oe = 1'b0;
	// reg	[0:31]	r_z_oe_dly = 32'h00000000;
	
	assign z_oe = r_z_oe;

	always @(posedge sys_clk)
	begin
		r_z_oe <= (~cs & we) ? 1'b1 : 1'b0;
	end

	assign wren = (~cs & ~we);
	
	altsyncram	altsyncram_component (
				.wren_a (wren),
				.clock0 (sys_clk),
				.wren_b (1'b0),
				.address_a (a_r),
				.address_b (10'd0),
				.data_a (z_in_r),
				.data_b (32'd0),
				.q_a (z_out_r),
				.q_b (),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.eccstatus (),
				.rden_a (1'b1),
				.rden_b (1'b1));
	defparam
		altsyncram_component.address_reg_b = "CLOCK0",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_input_b = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.clock_enable_output_b = "BYPASS",
		altsyncram_component.indata_reg_b = "CLOCK0",
		altsyncram_component.intended_device_family = "Stratix II",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 1024,
		altsyncram_component.numwords_b = 1024,
		altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.outdata_reg_b = "CLOCK0",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.widthad_a = 10,
		altsyncram_component.widthad_b = 10,
		altsyncram_component.width_a = 32,
		altsyncram_component.width_b = 32,
		altsyncram_component.width_byteena_a = 1,
		altsyncram_component.width_byteena_b = 1,
		altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK0";

`endif

endmodule
