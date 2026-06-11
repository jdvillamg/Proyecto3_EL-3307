module control_division (
    input  logic        clk,
    input  logic        rst,
    input  logic [3:0]  tecla_val,
    input  logic        tecla_detectada, 
    input  logic        div_done,        
    output logic [6:0]  dividendo,       // AHORA: Registro de 7 bits (máx 127)
    output logic [4:0]  divisor,         // AHORA: Registro de 5 bits (máx 31)
    output logic        div_valid,       
    output logic [13:0] valor_a_mostrar, 
    output logic        en_resultado     
);
    typedef enum logic [1:0] {ST_DIVIDENDO, ST_DIVISOR, ST_CALCULANDO, ST_RESULTADO} state_t;
    state_t state_reg;

    logic [13:0] n1_reg, n2_reg;

    assign en_resultado = (state_reg == ST_RESULTADO);

    logic es_numero;
    always_comb begin
        case (tecla_val)
            4'h0, 4'h1, 4'h2, 4'h3, 4'h4, 
            4'h5, 4'h6, 4'h7, 4'h8, 4'h9: es_numero = 1'b1;
            default: es_numero = 1'b0;
        endcase
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= ST_DIVIDENDO;
            n1_reg <= 14'd0; n2_reg <= 14'd0;
            dividendo <= 7'd0; divisor <= 5'd0;
            div_valid <= 1'b0;
            valor_a_mostrar <= 14'd0;
        end else begin
            div_valid <= 1'b0; 
            
            if (tecla_detectada) begin
                if (tecla_val == 4'hB) begin 
                    state_reg <= ST_DIVIDENDO;
                    n1_reg <= 14'd0; n2_reg <= 14'd0;
                end else begin
                    case (state_reg)
                        ST_DIVIDENDO: begin
                            if (es_numero) begin
                                // NUEVO LÍMITE: 127
                                if ((n1_reg * 14'd10) + {10'd0, tecla_val} <= 14'd127) begin
                                    n1_reg <= (n1_reg * 14'd10) + {10'd0, tecla_val};
                                end
                            end else if (tecla_val == 4'hF) begin 
                                state_reg <= ST_DIVISOR;
                            end
                        end
                        
                        ST_DIVISOR: begin
                            if (es_numero) begin
                                // NUEVO LÍMITE: 31
                                if ((n2_reg * 14'd10) + {10'd0, tecla_val} <= 14'd31) begin
                                    n2_reg <= (n2_reg * 14'd10) + {10'd0, tecla_val};
                                end
                            end else if (tecla_val == 4'hA) begin 
                                dividendo <= n1_reg[6:0];
                                divisor   <= n2_reg[4:0];
                                div_valid <= 1'b1; 
                                state_reg <= ST_CALCULANDO;
                            end
                        end
                        
                        ST_CALCULANDO: ; 
                        ST_RESULTADO:  ; 
                    endcase
                end
            end

            if (state_reg == ST_CALCULANDO && div_done) begin
                state_reg <= ST_RESULTADO;
            end
            
            case (state_reg)
                ST_DIVIDENDO:   valor_a_mostrar <= n1_reg;
                ST_DIVISOR:     valor_a_mostrar <= n2_reg;
                ST_CALCULANDO:  valor_a_mostrar <= 14'h3FFF; 
                ST_RESULTADO:   valor_a_mostrar <= 14'd0;    
                default:        valor_a_mostrar <= 14'd0;
            endcase
        end
    end
endmodule