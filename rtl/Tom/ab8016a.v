/* verilator lint_off LITENDIAN */
//`include "defs.v"

module _ab8016a
(
	output	[15:0]	z_out,
	output					z_oe,
	input		[15:0]	z_in,
	input						cen,
	input						rw,
	input		[7:0]		a,
	input						sys_clk
);

wire [7:0]	a_r;
wire [15:0]	z_out_r;
wire	[15:0]	z_in_r;

assign a_r = a;

assign z_out = z_out_r;

assign z_in_r = z_in;

`ifdef SIMULATION
	reg [15:0]	r_z_out_r;
	// reg	[15:0]	r_z_out_r_dly;
	reg	r_z_oe = 1'b0;
	// reg	r_z_oe_dly = 1'b0;

	reg	[15:0]	ram_blk [0:(1<<8)-1];

	// assign z_oe = r_z_oe_dly;
	assign z_out_r = r_z_out_r;
	assign z_oe = r_z_oe;

	always @(posedge sys_clk)
	begin
		// r_z_out_r_dly <= r_z_out_r;
		// r_z_oe_dly <= r_z_oe;	

		if (~cen) begin
			if (~rw) begin
				ram_blk[a_r][15:0] <= z_in_r;
			end
			r_z_out_r <= ram_blk[a_r][15:0];
		end
		r_z_oe <= (~cen & rw) ? 1'b1 : 1'b0;
	end
`else
	wire	wren;
	reg	r_z_oe = 1'b0;
	// reg	r_z_oe_dly = 1'b0;
	
	assign z_oe = r_z_oe;

	always @(posedge sys_clk)
	begin
		r_z_oe <= (~cen & rw) ? 1'b1 : 1'b0;
	end

	assign wren = (~cen & ~rw);
	
		altsyncram	altsyncram_component (
				.wren_a (wren),
				.clock0 (sys_clk),
				.address_a (a_r),
				.data_a (z_in_r),
				.q_a (z_out_r),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_b (1'b0));
	defparam
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.intended_device_family = "Cyclone III",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 256,
		altsyncram_component.operation_mode = "SINGLE_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
		altsyncram_component.widthad_a = 8,
		altsyncram_component.width_a = 16,
		altsyncram_component.width_byteena_a = 1;

`endif

endmodule
/* verilator lint_on LITENDIAN */