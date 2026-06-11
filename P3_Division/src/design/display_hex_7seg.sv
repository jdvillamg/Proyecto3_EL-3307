
module display_hex_7seg (
    input  logic [3:0] hex,
    output logic [6:0] led_seg
);
    logic [6:0] seg_pos; 

    always_comb begin
        case (hex)
            4'h0: seg_pos = 7'b0111111; // 0
            4'h1: seg_pos = 7'b0000110; // 1
            4'h2: seg_pos = 7'b1011011; // 2
            4'h3: seg_pos = 7'b1001111; // 3
            4'h4: seg_pos = 7'b1100110; // 4
            4'h5: seg_pos = 7'b1101101; // 5
            4'h6: seg_pos = 7'b1111101; // 6
            4'h7: seg_pos = 7'b0000111; // 7
            4'h8: seg_pos = 7'b1111111; // 8
            4'h9: seg_pos = 7'b1101111; // 9
            default: seg_pos = 7'b0000000;
        endcase
    end

    assign led_seg = ~seg_pos; 

endmodule