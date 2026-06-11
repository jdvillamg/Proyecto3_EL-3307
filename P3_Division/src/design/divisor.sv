module divisor (
    input  logic       clk,
    input  logic       rst,
    input  logic       valid,

    input  logic [5:0] dividendo,
    input  logic [3:0] divisor,

    output logic [5:0] cociente,
    output logic [3:0] residuo,
    output logic       done
);

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_CALC,
        ST_DONE
    } state_t;

    state_t state_reg;

    logic [5:0] A_reg;
    logic [3:0] B_reg;

    logic [5:0] Q_reg;
    logic [4:0] R_reg;

    logic [2:0] i_reg;

    logic [4:0] R_shift;
    logic [4:0] D_temp;

    always_comb begin
        R_shift = {R_reg[3:0], A_reg[i_reg]};
        D_temp  = R_shift - {1'b0, B_reg};
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= ST_IDLE;
            A_reg     <= 6'd0;
            B_reg     <= 4'd0;
            Q_reg     <= 6'd0;
            R_reg     <= 5'd0;
            i_reg     <= 3'd0;
            cociente  <= 6'd0;
            residuo   <= 4'd0;
            done      <= 1'b0;
        end else begin
            done <= 1'b0;

            case (state_reg)

                ST_IDLE: begin
                    if (valid) begin
                        A_reg <= dividendo;
                        B_reg <= divisor;
                        Q_reg <= 6'd0;
                        R_reg <= 5'd0;
                        i_reg <= 3'd5;

                        if (divisor == 4'd0) begin
                            cociente  <= 6'd0;
                            residuo   <= 4'd0;
                            done      <= 1'b1;
                            state_reg <= ST_IDLE;
                        end else begin
                            state_reg <= ST_CALC;
                        end
                    end
                end

                ST_CALC: begin
                    if (D_temp[4] == 1'b1) begin
                        Q_reg[i_reg] <= 1'b0;
                        R_reg        <= R_shift;
                    end else begin
                        Q_reg[i_reg] <= 1'b1;
                        R_reg        <= D_temp;
                    end

                    if (i_reg == 3'd0) begin
                        state_reg <= ST_DONE;
                    end else begin
                        i_reg <= i_reg - 3'd1;
                    end
                end

                ST_DONE: begin
                    cociente <= Q_reg;
                    residuo  <= R_reg[3:0];
                    done     <= 1'b1;
                    state_reg <= ST_IDLE;
                end

                default: begin
                    state_reg <= ST_IDLE;
                end

            endcase
        end
    end

endmodule