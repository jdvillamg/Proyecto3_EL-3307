module barrido (
    input  logic       clk,
    input  logic       rst,
    input  logic       tick_en,
    input  logic       pause_scan,
    output logic [3:0] rows_out,
    output logic [1:0] row_idx
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            row_idx <= 2'b00;
        end else if (tick_en && !pause_scan) begin
            row_idx <= row_idx + 1'b1;
        end
    end

    always_comb begin
        case (row_idx)
            2'b00: rows_out = 4'b0001; // Fila 0 activa
            2'b01: rows_out = 4'b0010; // Fila 1 activa
            2'b10: rows_out = 4'b0100; // Fila 2 activa
            2'b11: rows_out = 4'b1000; // Fila 3 activa
            default: rows_out = 4'b0000;
        endcase
    end

endmodule