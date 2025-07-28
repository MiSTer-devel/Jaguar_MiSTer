module tap_controller_mux #(
    parameter [3:0] P4 = 4'b1110,
    parameter [3:0] P3 = 4'b1101,
    parameter [3:0] P2 = 4'b1011,
    parameter [3:0] P1 = 4'b0111
) (
    input  wire [3:0] col_n,
    output reg  [5:0] row_n,
    input  wire        but_right,
    input  wire        but_left,
    input  wire        but_down,
    input  wire        but_up,
    input  wire        but_a,
    input  wire        but_b,
    input  wire        but_c,
    input  wire        but_option,
    input  wire        but_pause,
    input  wire        but_1,
    input  wire        but_2,
    input  wire        but_3,
    input  wire        but_4,
    input  wire        but_5,
    input  wire        but_6,
    input  wire        but_7,
    input  wire        but_8,
    input  wire        but_9,
    input  wire        but_0,
    input  wire        but_star,
    input  wire        but_hash,
    // Controller identification signals
    input  wire        c1_id,      // Controller 1 identification
    input  wire        c2_id,      // Controller 2 identification  
    input  wire        c3_id       // Controller 3 identification
);

always @* begin
    case (col_n)
        P4: row_n = ~{ but_up,    but_down, but_left, but_right, but_a,      but_pause };
        P3: row_n = ~{ but_star,  but_7,    but_4,    but_1,    but_b,      c3_id };
        P2: row_n = ~{ but_0,     but_8,    but_5,    but_2,    but_c,      c2_id };
        P1: row_n = ~{ but_hash,  but_9,    but_6,    but_3,    but_option, c1_id };
        default: row_n = 6'b111111;  // Inactive state when not selected
    endcase
end

endmodule

//------------------------------------------------------------------------------

module jag_team_tap (
    input  wire [3:0] col_n,        // Column select from Jaguar (active low)
    input  wire       enable,       // Enable signal for Team Tap
    output wire [5:0] row_n,        // Row data back to Jaguar (active low)

    // Controller A inputs (portA)
    input but_a_right,
    input but_a_left,
    input but_a_down,
    input but_a_up,
    input but_a_a,
    input but_a_b,
    input but_a_c,
    input but_a_option,
    input but_a_pause,
    input but_a_1,
    input but_a_2,
    input but_a_3,
    input but_a_4,
    input but_a_5,
    input but_a_6,
    input but_a_7,
    input but_a_8,
    input but_a_9,
    input but_a_0,
    input but_a_star,
    input but_a_hash,

    // Controller B inputs (portB)
    input but_b_right,
    input but_b_left,
    input but_b_down,
    input but_b_up,
    input but_b_a,
    input but_b_b,
    input but_b_c,
    input but_b_option,
    input but_b_pause,
    input but_b_1,
    input but_b_2,
    input but_b_3,
    input but_b_4,
    input but_b_5,
    input but_b_6,
    input but_b_7,
    input but_b_8,
    input but_b_9,
    input but_b_0,
    input but_b_star,
    input but_b_hash,

    // Controller C inputs (portC)
    input but_c_right,
    input but_c_left,
    input but_c_down,
    input but_c_up,
    input but_c_a,
    input but_c_b,
    input but_c_c,
    input but_c_option,
    input but_c_pause,
    input but_c_1,
    input but_c_2,
    input but_c_3,
    input but_c_4,
    input but_c_5,
    input but_c_6,
    input but_c_7,
    input but_c_8,
    input but_c_9,
    input but_c_0,
    input but_c_star,
    input but_c_hash,

    // Controller D inputs (portD)
    input but_d_right,
    input but_d_left,
    input but_d_down,
    input but_d_up,
    input but_d_a,
    input but_d_b,
    input but_d_c,
    input but_d_option,
    input but_d_pause,
    input but_d_1,
    input but_d_2,
    input but_d_3,
    input but_d_4,
    input but_d_5,
    input but_d_6,
    input but_d_7,
    input but_d_8,
    input but_d_9,
    input but_d_0,
    input but_d_star,
    input but_d_hash
);

wire [5:0] row_a, row_b, row_c, row_d;

// Instantiate individual controller mux modules for each controller
tap_controller_mux #(.P4(4'b1110), .P3(4'b1101), .P2(4'b1011), .P1(4'b0111)) controller_a (
    .col_n(col_n),
    .row_n(row_a),
    .but_right(but_a_right),
    .but_left(but_a_left),
    .but_down(but_a_down),
    .but_up(but_a_up),
    .but_a(but_a_a),
    .but_b(but_a_b),
    .but_c(but_a_c),
    .but_option(but_a_option),
    .but_pause(but_a_pause),
    .but_1(but_a_1),
    .but_2(but_a_2),
    .but_3(but_a_3),
    .but_4(but_a_4),
    .but_5(but_a_5),
    .but_6(but_a_6),
    .but_7(but_a_7),
    .but_8(but_a_8),
    .but_9(but_a_9),
    .but_0(but_a_0),
    .but_star(but_a_star),
    .but_hash(but_a_hash),
    .c1_id(1'b0),   // Controller A always responds to C1
    .c2_id(1'b1),   // Controller A doesn't respond to C2
    .c3_id(1'b1)    // Controller A doesn't respond to C3
);

tap_controller_mux #(.P4(4'b0000), .P3(4'b0001), .P2(4'b0010), .P1(4'b0011)) controller_b (
    .col_n(col_n),
    .row_n(row_b),
    .but_right(but_b_right),
    .but_left(but_b_left),
    .but_down(but_b_down),
    .but_up(but_b_up),
    .but_a(but_b_a),
    .but_b(but_b_b),
    .but_c(but_b_c),
    .but_option(but_b_option),
    .but_pause(but_b_pause),
    .but_1(but_b_1),
    .but_2(but_b_2),
    .but_3(but_b_3),
    .but_4(but_b_4),
    .but_5(but_b_5),
    .but_6(but_b_6),
    .but_7(but_b_7),
    .but_8(but_b_8),
    .but_9(but_b_9),
    .but_0(but_b_0),
    .but_star(but_b_star),
    .but_hash(but_b_hash),
    .c1_id(1'b1),   // Controller B doesn't respond to C1
    .c2_id(1'b0),   // Controller B responds to C2
    .c3_id(1'b1)    // Controller B doesn't respond to C3
);

tap_controller_mux #(.P4(4'b0100), .P3(4'b0101), .P2(4'b0110), .P1(4'b1000)) controller_c (
    .col_n(col_n),
    .row_n(row_c),
    .but_right(but_c_right),
    .but_left(but_c_left),
    .but_down(but_c_down),
    .but_up(but_c_up),
    .but_a(but_c_a),
    .but_b(but_c_b),
    .but_c(but_c_c),
    .but_option(but_c_option),
    .but_pause(but_c_pause),
    .but_1(but_c_1),
    .but_2(but_c_2),
    .but_3(but_c_3),
    .but_4(but_c_4),
    .but_5(but_c_5),
    .but_6(but_c_6),
    .but_7(but_c_7),
    .but_8(but_c_8),
    .but_9(but_c_9),
    .but_0(but_c_0),
    .but_star(but_c_star),
    .but_hash(but_c_hash),
    .c1_id(1'b1),   // Controller C doesn't respond to C1
    .c2_id(1'b1),   // Controller C doesn't respond to C2
    .c3_id(1'b0)    // Controller C responds to C3
);

tap_controller_mux #(.P4(4'b1001), .P3(4'b1010), .P2(4'b1100), .P1(4'b1111)) controller_d (
    .col_n(col_n),
    .row_n(row_d),
    .but_right(but_d_right),
    .but_left(but_d_left),
    .but_down(but_d_down),
    .but_up(but_d_up),
    .but_a(but_d_a),
    .but_b(but_d_b),
    .but_c(but_d_c),
    .but_option(but_d_option),
    .but_pause(but_d_pause),
    .but_1(but_d_1),
    .but_2(but_d_2),
    .but_3(but_d_3),
    .but_4(but_d_4),
    .but_5(but_d_5),
    .but_6(but_d_6),
    .but_7(but_d_7),
    .but_8(but_d_8),
    .but_9(but_d_9),
    .but_0(but_d_0),
    .but_star(but_d_star),
    .but_hash(but_d_hash),
    .c1_id(1'b0),   // Controller D responds to C1 (this is key for detection!)
    .c2_id(1'b1),   // Controller D doesn't respond to C2
    .c3_id(1'b1)    // Controller D doesn't respond to C3
);

reg [5:0] selected_row;

always @* begin
    if (!enable) begin
        selected_row = 6'b111111;
    end else begin
        case (col_n)
            // Controller A patterns
            4'b1110, 4'b1101, 4'b1011, 4'b0111: selected_row = row_a;
            // Controller B patterns  
            4'b0000, 4'b0001, 4'b0010, 4'b0011: selected_row = row_b;
            // Controller C patterns
            4'b0100, 4'b0101, 4'b0110, 4'b1000: selected_row = row_c;
            // Controller D patterns
            4'b1001, 4'b1010, 4'b1100, 4'b1111: selected_row = row_d;
            default: selected_row = 6'b111111;
        endcase
    end
end

assign row_n = selected_row;

endmodule