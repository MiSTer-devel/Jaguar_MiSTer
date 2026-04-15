module eeprom_93c46_x16
(
	input  sys_clk,
	input  resetl,
	input  autosize,
	input  hintw,
	input  cs,
	input  sk,
	input  din,
	output dout,
	output dout_oe,

	output       [9:0]  bram_addr,
	output      [15:0]  bram_data,
	input       [15:0]  bram_q,
	output              bram_wr
);

localparam [2:0] EE93_IDLE     = 3'b000;
localparam [2:0] EE93_DATA     = 3'b001;
localparam [2:0] EE93_READ     = 3'b010;
localparam [2:0] EE93_FETCH    = 3'b011;
localparam [2:0] EE93_WR_BEGIN = 3'b100;
localparam [2:0] EE93_WR_WRITE = 3'b101;
localparam [2:0] EE93_WR_LOOP  = 3'b110;
localparam [2:0] EE93_WR_END   = 3'b111;

reg         sk_prev = 1'b0;
reg         ee_type = 1'b0;   // 0 = 128 bytes/9-bit IR, 1 = 2048 bytes/13-bit IR
reg         detect = 1'b0;
reg         write_enable = 1'b0;
reg [2:0]   status = EE93_IDLE;
reg [3:0]   cnt = 4'd0;
reg [12:0]  ir = 13'd0;
reg [15:0]  dr = 16'd0;
reg         r_dout = 1'b1;
reg [9:0]   rdaddr = 10'd0;
reg [9:0]   wraddr = 10'd0;
reg [15:0]  wrdata = 16'hFFFF;
reg         wrloop = 1'b0;
reg         bram_wr_r = 1'b0;

wire [5:0]  irhi = ee_type ? ir[12:7] : ir[8:3];
wire [9:0]  ir_addr = ee_type ? ir[9:0] : {4'h0, ir[5:0]};
wire [9:0]  ir_addr_next = ee_type ? {ir[8:0], din} : {4'h0, ir[4:0], din};
wire        write_data_op = (irhi[3:2] == 2'b01) || (irhi[3:0] == 4'b0001);
wire        erase_op = (irhi[3:2] == 2'b11) || (irhi[3:0] == 4'b0010);
wire        wr_last_addr = ee_type ? (wraddr == 10'h3FF) : (wraddr[5:0] == 6'h3F);

assign dout = r_dout;
assign dout_oe = cs && resetl;
assign bram_addr = status[2] ? wraddr :
				   (status == EE93_FETCH || status == EE93_READ) ? rdaddr :
				   ir_addr_next;
assign bram_data = wrdata;
assign bram_wr = bram_wr_r;

always @(posedge sys_clk) begin
	sk_prev <= sk;
	bram_wr_r <= 1'b0;

	if (!resetl) begin
		status <= EE93_IDLE;
		cnt <= 4'd0;
		ir <= 13'd0;
		dr <= 16'd0;
		r_dout <= 1'b1;
		rdaddr <= 10'd0;
		wraddr <= 10'd0;
		wrdata <= 16'hFFFF;
		wrloop <= 1'b0;
		write_enable <= 1'b0;
		ee_type <= 1'b0;
		detect <= autosize;
	end else if (status == EE93_FETCH) begin
		dr <= bram_q;
		r_dout <= 1'b0;
		status <= EE93_READ;
	end else if (status[2]) begin
		case (status)
			EE93_WR_BEGIN: begin
				r_dout <= 1'b0;
				status <= EE93_WR_WRITE;
				if (irhi[4:3] == 2'b11) begin
					wraddr <= ir_addr;
					wrloop <= 1'b0;
					wrdata <= 16'hFFFF;
				end else if (irhi[4:3] == 2'b01) begin
					wraddr <= ir_addr;
					wrloop <= 1'b0;
					wrdata <= dr;
				end else if (irhi[4:1] == 4'b0010) begin
					wraddr <= 10'd0;
					wrloop <= 1'b1;
					wrdata <= 16'hFFFF;
				end else if (irhi[4:1] == 4'b0001) begin
					wraddr <= 10'd0;
					wrloop <= 1'b1;
					wrdata <= dr;
				end
			end

			EE93_WR_WRITE: begin
				if (write_enable) begin
					bram_wr_r <= 1'b1;
				end
				status <= EE93_WR_LOOP;
			end

			EE93_WR_LOOP: begin
				if (!wrloop) begin
					status <= EE93_WR_END;
				end else begin
					wraddr <= wraddr + 10'd1;
					if (wr_last_addr) begin
						status <= EE93_WR_END;
					end else begin
						status <= EE93_WR_WRITE;
					end
				end
			end

			EE93_WR_END: begin
				r_dout <= 1'b1;
				status <= EE93_IDLE;
			end
		endcase
	end else if (!cs) begin
		status <= EE93_IDLE;
		cnt <= 4'd0;
		ir <= 13'd0;
		dr <= 16'd0;
		r_dout <= 1'b1;
		rdaddr <= 10'd0;
		wraddr <= 10'd0;
		wrdata <= 16'hFFFF;
		wrloop <= 1'b0;
		if (detect) begin
			if (ir[9]) begin
				ee_type <= 1'b0;
				detect <= 1'b0;
			end
			if (ir[12]) begin
				ee_type <= 1'b1;
				detect <= 1'b0;
			end
		end
	end else if (~sk_prev & sk) begin
		if (status == EE93_IDLE) begin
			if (ir[9]) begin
				detect <= 1'b0;
			end
			ir <= {ir[11:0], din};
			if (irhi[4]) begin
				if (irhi[3:2] == 2'b10) begin
					rdaddr <= ir_addr_next;
					status <= EE93_FETCH;
				end else if (irhi[3:0] == 4'b0011) begin
					write_enable <= 1'b1;
				end else if (erase_op) begin
					status <= write_enable ? EE93_WR_BEGIN : EE93_IDLE;
				end else if (write_data_op) begin
					status <= write_enable ? EE93_DATA : EE93_IDLE;
				end else if (irhi[3:0] == 4'b0000) begin
					write_enable <= 1'b0;
					status <= EE93_IDLE;
				end
			end
		end else if (status == EE93_DATA) begin
			detect <= 1'b0;
			dr <= {dr[14:0], din};
			cnt <= cnt + 4'd1;
			if (cnt == 4'd15) begin
				status <= EE93_WR_BEGIN;
				cnt <= 4'd0;
			end
		end else if (status == EE93_READ) begin
			detect <= 1'b0;
			r_dout <= dr[15];
			dr <= {dr[14:0], 1'b0};
		end
	end else if (!sk && !hintw && detect && ir[8]) begin
		ee_type <= 1'b1;
		detect <= 1'b0;
		status <= EE93_IDLE;
	end
end

endmodule
