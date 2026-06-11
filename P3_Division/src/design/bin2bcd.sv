module bin2bcd (
    input  logic        clk,
    input  logic        rst,
    input  logic [13:0] bin,
    output logic [3:0]  mil,
    output logic [3:0]  cen,
    output logic [3:0]  dec,
    output logic [3:0]  uni
);
    logic [13:0] bin_reg;
    logic [13:0] bin_prev;
    logic [3:0]  m, c, d, u;

    typedef enum logic {IDLE, COUNT} state_t;
    state_t state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            bin_prev <= 14'h3FFF;
            bin_reg  <= 0;
            m <= 0; c <= 0; d <= 0; u <= 0;
            mil <= 0; cen <= 0; dec <= 0; uni <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (bin != bin_prev) begin
                        bin_prev <= bin;
                        bin_reg  <= bin;     // Copiamos el número a descontar
                        m <= 0; c <= 0; d <= 0; u <= 0; // Limpiamos BCD
                        state    <= COUNT;
                    end
                end

                COUNT: begin
                    if (bin_reg == 0) begin
                        // Terminamos de contar, pasamos los datos a la salida
                        mil <= m; 
                        cen <= c; 
                        dec <= d; 
                        uni <= u;
                        state <= IDLE;
                    end else begin
                        // 1. Le restamos 1 al número binario
                        bin_reg <= bin_reg - 1'b1;

                        // 2. Le sumamos 1 al BCD (Lógica de reloj digital tradicional)
                        if (u == 4'd9) begin
                            u <= 4'd0;
                            if (d == 4'd9) begin
                                d <= 4'd0;
                                if (c == 4'd9) begin
                                    c <= 4'd0;
                                    m <= m + 1'b1;
                                end else begin
                                    c <= c + 1'b1;
                                end
                            end else begin
                                d <= d + 1'b1;
                            end
                        end else begin
                            u <= u + 1'b1;
                        end
                    end
                end
            endcase
        end
    end
endmodule