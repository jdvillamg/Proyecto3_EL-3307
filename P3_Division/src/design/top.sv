module top (
    input  logic       clk,      
    input  logic       rst_n,
    input  logic [3:0] column_,
    output logic [3:0] row_,
    output logic [3:0] digit_sel,
    output logic [6:0] led_seg
);
    logic tick_1ms;
    logic [3:0] key_val;
    logic key_valid;
    logic [13:0] current_value;

    clk_divider u_div (
        .clk(clk), 
        .rst(!rst_n), 
        .tick_en(tick_1ms)
    );

    
    teclado_top u_keypad (
        .clk(clk), 
        .rst(!rst_n), 
        .tick_en(tick_1ms),
        .cols(column_), 
        .rows(row_),
        .valor_tecla(key_val), 
        .tecla_valida(key_valid)
    );

    
    control_division u_calc (
    .clk(clk), 
    .rst(!rst_n),
    .tecla_val(key_val), 
    .tecla_detectada(key_valid),
    .valor_a_mostrar(current_value)
    );

    
    display_mux_4_pos u_disp (
        .clk(clk), 
        .rst(!rst_n),           
        .tick_1ms(tick_1ms),
        .valor(current_value),
        .digit_sel(digit_sel), 
        .led_seg(led_seg)
    );
    
endmodule