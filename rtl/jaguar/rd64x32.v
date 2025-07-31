//`include "defs.v"

module _rd64x32
(
	output	[31:0]	qa,
	output	[31:0]	qb,
	input						nwea,
	input						clka,
	input		[5:0]		aa,
	input		[31:0]	da,
	input						nweb,
	input						clkb,
	input		[5:0]		ab,
	input		[31:0]	db,	
	input						sys_clk
);

`ifdef SIMULATION

reg	[31:0]	r_qa;
reg	[31:0]	r_qb;
reg	[31:0]	ram_blk [0:(1<<6)-1];

always @(posedge sys_clk)
begin
	if (clka) begin
		if (~nwea) begin
			ram_blk[aa][31:0] <= da;
			//$display("GPU REG WR-A $%x #%x", aa, da);
		end
		//GE r_qa <= ram_blk[aa][31:0];
	end
	if (clkb) begin
		if (~nweb) begin
			ram_blk[ab][31:0] <= db;
			//$display("GPU REG WR-B $%x #%x", ab, db);
		end
		//GE r_qb <= ram_blk[ab][31:0];
	end
	r_qa <= ram_blk[aa][31:0]; //GE
	r_qb <= ram_blk[ab][31:0]; //GE
end

`else

wire	[31:0]	r_qa;
wire	[31:0]	r_qb;

wire wren_a;
wire wren_b;

wire dupwrite = (aa == ab) && wren_b;
assign wren_a = ~nwea & clka && ~dupwrite;
assign wren_b = ~nweb & clkb;

always @(posedge sys_clk)
begin
	if (~nwea & clka) begin
		//$display("GPU REG WR-A $%x #%x", aa, da);
	end
	if (~nweb & clkb) begin
		//$display("GPU REG WR-B $%x #%x", ab, db);
	end
end

	altsyncram	altsyncram_component (
				.wren_a (wren_a),
				.clock0 (sys_clk),
				.wren_b (wren_b),
				.address_a (aa),
				.address_b (ab),
				.data_a (da),
				.data_b (db),
				.q_a (r_qa),
				.q_b (r_qb),
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
		altsyncram_component.intended_device_family = "Cyclone III",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 64,
		altsyncram_component.numwords_b = 64,
		altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_aclr_b = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.outdata_reg_b = "CLOCK0",
		altsyncram_component.power_up_uninitialized = "FALSE",
		//GE altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.read_during_write_mode_mixed_ports = "OLD_DATA", //GE
		altsyncram_component.widthad_a = 6,
		altsyncram_component.widthad_b = 6,
		altsyncram_component.width_a = 32,
		altsyncram_component.width_b = 32,
		altsyncram_component.width_byteena_a = 1,
		altsyncram_component.width_byteena_b = 1,
		altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK0";

`endif

assign qa = r_qa;
assign qb = r_qb;

endmodule
