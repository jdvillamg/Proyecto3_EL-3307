module divisor (
    input  logic       clk,
    input  logic       rst,
    input  logic [6:0] A,        // Dividendo (7 bits)
    input  logic [4:0] B,        // Divisor (5 bits)
    input  logic       valid,    
    output logic [6:0] Q,        // Cociente final
    output logic [4:0] R,        // Residuo final
    output logic       done      
);

    typedef enum logic [1:0] {IDLE, SHIFT_SUB, DONE} state_t;
    state_t state;

    // AHORA SÍ: 13 bits (6 bits para el residuo temporal + 7 bits para el cociente)
    logic [12:0] RQ;         
    logic [4:0] divisor_reg; 
    logic [2:0] count;       

    // 1. Shift combinacional (13 bits)
    logic [12:0] shifted_RQ;
    assign shifted_RQ = {RQ[11:0], 1'b0}; 

    // 2. Resta
    // Restamos el divisor (5 bits) a la parte alta de shifted_RQ (que ahora tiene 6 bits seguros).
    // Necesitamos 7 bits para el resultado para guardar el bit de signo (negativo).
    logic [6:0] sub_result; 
    assign sub_result = {1'b0, shifted_RQ[12:7]} - {2'b00, divisor_reg};

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state       <= IDLE;
            Q           <= 7'd0;
            R           <= 5'd0;
            done        <= 1'b0;
            RQ          <= 13'd0;
            divisor_reg <= 5'd0;
            count       <= 3'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (valid) begin
                        // Precargamos: 6 ceros a la izquierda, y los 7 bits de A a la derecha
                        RQ          <= {6'd0, A}; 
                        divisor_reg <= B;
                        count       <= 3'd7; 
                        
                        if (B == 5'd0) begin 
                            Q <= 7'h7F; 
                            R <= 5'd0;
                            done <= 1'b1;
                        end else begin
                            state <= SHIFT_SUB;
                        end
                    end
                end

                SHIFT_SUB: begin
                    if (count == 0) begin
                        // Entregamos el resultado
                        Q <= RQ[6:0];
                        // Aunque el residuo interno usó 6 bits, matemáticamente el residuo final 
                        // nunca será mayor al divisor (max 31), así que cabe perfecto en los 5 bits de salida
                        R <= RQ[11:7]; 
                        done <= 1'b1;
                        state <= DONE;
                    end else begin
                        if (sub_result[6] == 1'b1) begin // Si el bit 6 es 1, es negativo
                            RQ <= shifted_RQ; // No restamos, cociente 0
                        end else begin
                            // Positivo: Guardamos la resta (6 bits) + la cola de Q (6 bits) + un 1 en el LSB
                            RQ <= {sub_result[5:0], shifted_RQ[6:1], 1'b1};
                        end
                        count <= count - 1'b1;
                    end
                end

                DONE: begin
                    if (!valid) begin
                        done <= 1'b0;
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule