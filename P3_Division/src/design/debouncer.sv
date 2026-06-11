module debouncer (
    input  logic clk,
    input  logic rst,
    input  logic tick_en,
    input  logic ruido,       
    output logic clean        
);
    logic [7:0] shift_reg; // Expandido a 8 bits (8ms)

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 8'b00000000;
            clean     <= 1'b0;
        end else begin
            if (tick_en) begin
                shift_reg <= {shift_reg[6:0], ruido};

                // Solo valida si la señal es estable por 8ms completos
                if (shift_reg == 8'h00) begin
                    clean <= 1'b0;
                end else if (shift_reg == 8'hFF) begin
                    clean <= 1'b1;
                end
            end
        end
    end
endmodule