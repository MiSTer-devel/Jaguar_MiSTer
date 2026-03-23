module jaguar_save_slot #(
	parameter integer MAX_BLOCKS = 4
) (
	input         clk_sys,
	input         invalidate_pulse,
	input         mount_pulse,
	input         mount_readonly,
	input  [63:0] mount_size,
	input         load_req,
	input         save_req,
	input         autosave_disable,
	input         osd_status,
	input         dirty_pulse,
	output reg    mounted_writable = 1'b0,
	output reg    pending = 1'b0,
	output reg    busy = 1'b0,
	output reg [31:0] sd_lba = 32'd0,
	output reg    sd_rd = 1'b0,
	output reg    sd_wr = 1'b0,
	input         sd_ack
);

	localparam integer BLOCK_BITS = $clog2(MAX_BLOCKS + 1);

	reg old_mount_pulse = 1'b0;
	reg old_load_req = 1'b0;
	reg old_save_req = 1'b0;
	reg old_sd_ack = 1'b0;
	reg loading = 1'b0;
	reg [BLOCK_BITS-1:0] mounted_blocks = '0;
	reg       mount_readonly_latched = 1'b0;
	reg [BLOCK_BITS-1:0] mount_blocks_latched = '0;

	function automatic [BLOCK_BITS-1:0] blocks_from_size(input [63:0] size_bytes);
		reg [63:0] rounded_bytes;
		reg [63:0] block_count;
	begin
		if (size_bytes == 64'd0) begin
			blocks_from_size = '0;
		end else begin
			rounded_bytes = size_bytes + 64'd511;
			block_count = rounded_bytes >> 9;
			if (block_count == 64'd0) begin
				blocks_from_size = 1;
			end else if (block_count > MAX_BLOCKS) begin
				blocks_from_size = MAX_BLOCKS;
			end else begin
				blocks_from_size = block_count[BLOCK_BITS-1:0];
			end
		end
	end
	endfunction

	always @(posedge clk_sys) begin
		reg mount_rise;
		reg mount_fall;
		reg load_rise;
		reg save_rise;
		reg autosave_now;
		reg [BLOCK_BITS-1:0] next_blocks;

		mount_rise = mount_pulse && !old_mount_pulse;
		mount_fall = old_mount_pulse && !mount_pulse;
		load_rise = load_req && !old_load_req;
		save_rise = save_req && !old_save_req;
		autosave_now = pending && osd_status && !autosave_disable;
		next_blocks = blocks_from_size(mount_size);

		old_mount_pulse <= mount_pulse;
		old_load_req <= load_req;
		old_save_req <= save_req;
		old_sd_ack <= sd_ack;

		if (invalidate_pulse) begin
			mounted_writable <= 1'b0;
			pending <= 1'b0;
			busy <= 1'b0;
			loading <= 1'b0;
			mounted_blocks <= '0;
			mount_readonly_latched <= 1'b0;
			mount_blocks_latched <= '0;
			sd_lba <= 32'd0;
			sd_rd <= 1'b0;
			sd_wr <= 1'b0;
		end

		if (!invalidate_pulse) begin
			if (dirty_pulse && mounted_writable && !osd_status) begin
				pending <= 1'b1;
			end else if (busy && !loading) begin
				pending <= 1'b0;
			end
		end

		if (mount_rise) begin
			// img_readonly/img_size are only valid while img_mounted is asserted,
			// and img_size is populated after the mount bit first rises.
			// Clear current state on the new mount edge, then finalize once the
			// mount pulse drops after the size words have been delivered.
			pending <= 1'b0;
			busy <= 1'b0;
			loading <= 1'b0;
			mounted_writable <= 1'b0;
			mounted_blocks <= '0;
			mount_readonly_latched <= mount_readonly;
			mount_blocks_latched <= next_blocks;
			sd_lba <= 32'd0;
			sd_rd <= 1'b0;
			sd_wr <= 1'b0;
		end else if (!invalidate_pulse) begin
			if (mount_pulse) begin
				mount_readonly_latched <= mount_readonly;
				mount_blocks_latched <= next_blocks;
			end

			if (mount_fall) begin
				mounted_blocks <= mount_blocks_latched;
				mounted_writable <= !mount_readonly_latched && (mount_blocks_latched != '0);
				pending <= 1'b0;
				busy <= 1'b0;
				loading <= 1'b0;
				sd_lba <= 32'd0;
				sd_rd <= 1'b0;
				sd_wr <= 1'b0;

				if (!mount_readonly_latched && (mount_blocks_latched != '0)) begin
					busy <= 1'b1;
					loading <= 1'b1;
					sd_rd <= 1'b1;
				end
			end

			if (!old_sd_ack && sd_ack) begin
				sd_rd <= 1'b0;
				sd_wr <= 1'b0;
			end

			if (busy) begin
				if (old_sd_ack && !sd_ack) begin
					if ((sd_lba + 32'd1) >= mounted_blocks) begin
						busy <= 1'b0;
						loading <= 1'b0;
						sd_lba <= 32'd0;
					end else begin
						sd_lba <= sd_lba + 32'd1;
						sd_rd <= loading;
						sd_wr <= !loading;
					end
				end
			end else if (!mount_pulse && mounted_writable && (load_rise || save_rise || autosave_now)) begin
				busy <= 1'b1;
				loading <= load_rise;
				sd_lba <= 32'd0;
				sd_rd <= load_rise;
				sd_wr <= !load_rise;
			end
		end
	end

endmodule
