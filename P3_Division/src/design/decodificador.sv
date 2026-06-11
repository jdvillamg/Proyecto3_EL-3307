module decodificador (
    input  logic       clk,
    input  logic       rst,
    input  logic [1:0] row_idx,
    input  logic [3:0] cols_clean,
    output logic [3:0] valor_tecla,
    output logic       cualquier_tecla,
    output logic       tecla_valida
);
    assign cualquier_tecla = (cols_clean != 4'b0000);

    always @* begin
        valor_tecla = 4'h0;
        if (cualquier_tecla) begin
            case (row_idx)
                2'b00: begin // Fila 0
                    if      (cols_clean[0]) valor_tecla = 4'h1;
                    else if (cols_clean[1]) valor_tecla = 4'h2;
                    else if (cols_clean[2]) valor_tecla = 4'h3;
                    else if (cols_clean[3]) valor_tecla = 4'hA;
                end
                2'b01: begin // Fila 1
                    if      (cols_clean[0]) valor_tecla = 4'h4;
                    else if (cols_clean[1]) valor_tecla = 4'h5;
                    else if (cols_clean[2]) valor_tecla = 4'h6;
                    else if (cols_clean[3]) valor_tecla = 4'hB;
                end
                2'b10: begin // Fila 2
                    if      (cols_clean[0]) valor_tecla = 4'h7;
                    else if (cols_clean[1]) valor_tecla = 4'h8;
                    else if (cols_clean[2]) valor_tecla = 4'h9; 
                    else if (cols_clean[3]) valor_tecla = 4'hC;
                end
                2'b11: begin // Fila 3
                    if      (cols_clean[0]) valor_tecla = 4'hE; 
                    else if (cols_clean[1]) valor_tecla = 4'h0;
                    else if (cols_clean[2]) valor_tecla = 4'hF; // #
                    else if (cols_clean[3]) valor_tecla = 4'hD;
                end
            endcase
        end
    end

    logic prev_pressed;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_pressed <= 1'b0;
            tecla_valida <= 1'b0;
        end else begin
            prev_pressed <= cualquier_tecla;
            tecla_valida <= cualquier_tecla && !prev_pressed;
        end
    end
endmodule