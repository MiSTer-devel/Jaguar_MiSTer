// Cheat Code handling by Kitrinx
// Apr 21, 2019

// Code layout:
// {clock bit, code flags,     32'b address, 32'b compare, 32'b replace}
//  128        127:96          95:64         63:32         31:0
// Integer values are in BIG endian byte order, so it up to the loader
// or generator of the code to re-arrange them correctly.
`define CHEATS_DISABLED

module CODES(
	input  clk,        // Best to not make it too high speed for timing reasons
	input  reset,      // This should only be triggered when a new rom is loaded or before new codes load, not warm reset
	input  enable,
	output available,
	input  [128:0] code,
	input  [ADDR_WIDTH - 1:0] addr_in,
	input  [DATA_WIDTH - 1:0] data_in,
	output [DATA_WIDTH - 1:0] data_out
);


parameter ADDR_WIDTH   = 16; // Not more than 32
parameter DATA_WIDTH   = 8;  // Not more than 32
parameter MAX_CODES    = 32;
parameter BIG_ENDIAN   = 0;

localparam NO_ADDR_LSB = (DATA_WIDTH == 16) ? 1 : 0;
localparam INDEX_SIZE  = (MAX_CODES > 1) ? $clog2(MAX_CODES) : 1;

`ifdef CHEATS_DISABLED
	assign data_out = data_in;
	assign available = 1'b0;
`else

logic [ADDR_WIDTH - 1:0] codes_addr        [MAX_CODES];
logic [DATA_WIDTH - 1:0] codes_compare_mask[MAX_CODES];
logic [DATA_WIDTH - 1:0] codes_compare_val [MAX_CODES];
logic [DATA_WIDTH - 1:0] codes_replace_mask[MAX_CODES];
logic [DATA_WIDTH - 1:0] codes_replace_val [MAX_CODES];
logic                    codes_enable      [MAX_CODES];

logic [INDEX_SIZE:0]     next_index;
logic                    code_change;

logic [ADDR_WIDTH - 1:0] load_addr;
logic [DATA_WIDTH - 1:0] load_compare_raw;
logic [DATA_WIDTH - 1:0] load_replace_raw;
logic                    load_compare_en;
logic                    load_byte_code;
logic [DATA_WIDTH - 1:0] load_compare_mask;
logic [DATA_WIDTH - 1:0] load_compare_val;
logic [DATA_WIDTH - 1:0] load_replace_mask;
logic [DATA_WIDTH - 1:0] load_replace_val;
logic                    found_dup;
logic [INDEX_SIZE-1:0]   dup_index;
logic [INDEX_SIZE-1:0]   load_index;
logic [DATA_WIDTH - 1:0] data_out_next;

assign load_addr        = code[64 +: ADDR_WIDTH] ^ BIG_ENDIAN[0];
assign load_compare_raw = code[32 +: DATA_WIDTH];
assign load_replace_raw = code[0  +: DATA_WIDTH];
assign load_compare_en  = code[96];
assign load_byte_code   = code[97] && (DATA_WIDTH == 16);
assign load_index       = found_dup ? dup_index : next_index[INDEX_SIZE-1:0];

assign available = (next_index != '0);
assign data_out  = enable ? data_out_next : data_in;

always_comb begin
	load_compare_mask = '0;
	load_compare_val  = '0;
	load_replace_mask = '0;
	load_replace_val  = '0;

	if (DATA_WIDTH == 8 || !load_byte_code) begin
		load_replace_mask = {DATA_WIDTH{1'b1}};
		load_replace_val  = load_replace_raw;
		if (load_compare_en) begin
			load_compare_mask = {DATA_WIDTH{1'b1}};
			load_compare_val  = load_compare_raw;
		end
	end else if (load_addr[0]) begin
		load_replace_mask = DATA_WIDTH'(16'hFF00);
		load_replace_val  = DATA_WIDTH'({load_replace_raw[7:0], 8'h00});
		if (load_compare_en) begin
			load_compare_mask = DATA_WIDTH'(16'hFF00);
			load_compare_val  = DATA_WIDTH'({load_compare_raw[7:0], 8'h00});
		end
	end else begin
		load_replace_mask = DATA_WIDTH'(16'h00FF);
		load_replace_val  = DATA_WIDTH'({8'h00, load_replace_raw[7:0]});
		if (load_compare_en) begin
			load_compare_mask = DATA_WIDTH'(16'h00FF);
			load_compare_val  = DATA_WIDTH'({8'h00, load_compare_raw[7:0]});
		end
	end
end

always_comb begin
	int x;

	found_dup = 1'b0;
	dup_index = '0;

	for (x = 0; x < MAX_CODES; x = x + 1) begin
		if (codes_enable[x] && (codes_addr[x] == load_addr)) begin
			found_dup = 1'b1;
			dup_index = x[INDEX_SIZE-1:0];
		end
	end
end

always_ff @(posedge clk) begin
	int x;

	if (reset) begin
		next_index  <= '0;
		code_change <= 1'b0;
		for (x = 0; x < MAX_CODES; x = x + 1) begin
			codes_addr[x]         <= '0;
			codes_compare_mask[x] <= '0;
			codes_compare_val[x]  <= '0;
			codes_replace_mask[x] <= '0;
			codes_replace_val[x]  <= '0;
			codes_enable[x]       <= 1'b0;
		end
	end else begin
		code_change <= code[128];
		if (code[128] && !code_change && (found_dup || (next_index < MAX_CODES))) begin
			codes_addr[load_index]         <= load_addr;
			codes_compare_mask[load_index] <= load_compare_mask;
			codes_compare_val[load_index]  <= load_compare_val;
			codes_replace_mask[load_index] <= load_replace_mask;
			codes_replace_val[load_index]  <= load_replace_val;
			codes_enable[load_index]       <= 1'b1;
			if (!found_dup) next_index <= next_index + 1'b1;
		end
	end
end

always_comb begin
	int x;

	data_out_next = data_in;

	if (enable) begin
		for (x = 0; x < MAX_CODES; x = x + 1) begin
			if (codes_enable[x] && (codes_addr[x][ADDR_WIDTH-1:NO_ADDR_LSB] == addr_in[ADDR_WIDTH-1:NO_ADDR_LSB])) begin
				if (((data_in & codes_compare_mask[x]) == codes_compare_val[x])) begin
					data_out_next = (data_out_next & ~codes_replace_mask[x]) | codes_replace_val[x];
				end
			end
		end
	end
end
`endif

endmodule
