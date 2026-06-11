module control_division (
    input  logic        clk,
    input  logic        rst,
    input  logic [3:0]  tecla_val,
    input  logic        tecla_detectada,

    output logic [13:0] valor_a_mostrar
);

    typedef enum logic [2:0] {
        ST_DIVIDENDO,
        ST_DIVISOR,
        ST_START_DIV,
        ST_WAIT_DONE,
        ST_RESULTADO
    } state_t;

    state_t state_reg;

    logic [5:0] dividendo_reg;
    logic [3:0] divisor_reg;

    logic [5:0] cociente_wire;
    logic [3:0] residuo_wire;
    logic       done_wire;
    logic       valid_reg;

    logic [5:0] cociente_reg;
    logic [3:0] residuo_reg;

    logic mostrar_residuo;

    logic es_numero;

    always_comb begin
        case (tecla_val)
            4'h0, 4'h1, 4'h2, 4'h3, 4'h4,
            4'h5, 4'h6, 4'h7, 4'h8, 4'h9: es_numero = 1'b1;
            default: es_numero = 1'b0;
        endcase
    end

    divisor u_divisor (
        .clk       (clk),
        .rst       (rst),
        .valid     (valid_reg),
        .dividendo (dividendo_reg),
        .divisor   (divisor_reg),
        .cociente  (cociente_wire),
        .residuo   (residuo_wire),
        .done      (done_wire)
    );

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg       <= ST_DIVIDENDO;
            dividendo_reg   <= 6'd0;
            divisor_reg     <= 4'd0;
            cociente_reg    <= 6'd0;
            residuo_reg     <= 4'd0;
            valid_reg       <= 1'b0;
            mostrar_residuo <= 1'b0;
            valor_a_mostrar <= 14'd0;
        end else begin
            valid_reg <= 1'b0;

            if (tecla_detectada) begin

                if (tecla_val == 4'hB) begin
                    state_reg       <= ST_DIVIDENDO;
                    dividendo_reg   <= 6'd0;
                    divisor_reg     <= 4'd0;
                    cociente_reg    <= 6'd0;
                    residuo_reg     <= 4'd0;
                    mostrar_residuo <= 1'b0;
                end else begin
                    case (state_reg)

                        ST_DIVIDENDO: begin
                            if (es_numero) begin
                                if (((dividendo_reg * 6'd10) + {2'd0, tecla_val}) <= 6'd63) begin
                                    dividendo_reg <= (dividendo_reg * 6'd10) + {2'd0, tecla_val};
                                end
                            end else if (tecla_val == 4'hF) begin
                                state_reg <= ST_DIVISOR;
                            end
                        end

                        ST_DIVISOR: begin
                            if (es_numero) begin
                                if (((divisor_reg * 4'd10) + tecla_val) <= 4'd15) begin
                                    divisor_reg <= (divisor_reg * 4'd10) + tecla_val;
                                end
                            end else if (tecla_val == 4'hA) begin
                                state_reg <= ST_START_DIV;
                            end
                        end

                        ST_RESULTADO: begin
                            if (tecla_val == 4'hC) begin
                                mostrar_residuo <= ~mostrar_residuo;
                            end
                        end

                        default: begin
                        end

                    endcase
                end
            end

            case (state_reg)

                ST_START_DIV: begin
                    valid_reg <= 1'b1;
                    state_reg <= ST_WAIT_DONE;
                end

                ST_WAIT_DONE: begin
                    if (done_wire) begin
                        cociente_reg <= cociente_wire;
                        residuo_reg  <= residuo_wire;
                        state_reg    <= ST_RESULTADO;
                    end
                end

                default: begin
                end

            endcase

            case (state_reg)
                ST_DIVIDENDO: valor_a_mostrar <= {8'd0, dividendo_reg};
                ST_DIVISOR:   valor_a_mostrar <= {10'd0, divisor_reg};

                ST_RESULTADO: begin
                    if (mostrar_residuo) begin
                        valor_a_mostrar <= {10'd0, residuo_reg};
                    end else begin
                        valor_a_mostrar <= {8'd0, cociente_reg};
                    end
                end

                default: valor_a_mostrar <= valor_a_mostrar;
            endcase
        end
    end

endmodule