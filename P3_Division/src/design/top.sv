module top (
    input  logic       clk,          // Reloj de 27 MHz de la Tang Nano [cite: 117]
    input  logic       rst_n,        // Reset activo en bajo
    input  logic [3:0] column_,      // Columnas del teclado matricial [cite: 36]
    input  logic       btn_selector, // Botón físico para alternar entre Cociente y Residuo [cite: 47]
    output logic [3:0] row_,         // Filas del teclado matricial
    output logic [3:0] digit_sel,    // Selector de dígito para el display multiplexado [cite: 33]
    output logic [6:0] led_seg       // Segmentos A-G del display de 7 segmentos [cite: 45]
);
    // Señales internas de interconexión
    logic tick_1ms;
    logic [3:0] key_val;
    logic key_valid;
    logic [13:0] capture_value;
    
    // Conexiones hacia el subsistema de cálculo
    logic [6:0] div_A;         // AHORA: 7 bits
    logic [4:0] div_B;         // AHORA: 5 bits
    logic valid_flag, done_flag;
    logic [6:0] cociente_out;  // AHORA: 7 bits
    logic [4:0] residuo_out;   // AHORA: 5 bits
    
    // NUEVO: Cable para retener el resultado en pantalla
    logic flag_mostrar_res;

    // Generador de la base de tiempo de 1ms [cite: 118]
    clk_divider u_div (
        .clk(clk), 
        .rst(!rst_n), 
        .tick_en(tick_1ms)
    );

    // Subsistema de lectura y filtrado del teclado hexadecimal [cite: 36, 37]
    teclado_top u_keypad (
        .clk(clk), 
        .rst(!rst_n), 
        .tick_en(tick_1ms),
        .cols(column_), 
        .rows(row_),
        .valor_tecla(key_val), 
        .tecla_valida(key_valid)
    );

    // Máquina de estados para la captura de datos y control de flujo [cite: 16]
    control_division u_control (
        .clk(clk), 
        .rst(!rst_n),
        .tecla_val(key_val), 
        .tecla_detectada(key_valid),
        .div_done(done_flag),
        .dividendo(div_A),
        .divisor(div_B),
        .div_valid(valid_flag),
        .valor_a_mostrar(capture_value),
        .en_resultado(flag_mostrar_res) // Conectamos la nueva señal
    );

    // Subsistema algorítmico de cálculo de división de enteros [cite: 30, 40]
    divisor u_divisor (
        .clk(clk),
        .rst(!rst_n),
        .A(div_A),
        .B(div_B),
        .valid(valid_flag),
        .Q(cociente_out),
        .R(residuo_out),
        .done(done_flag)
    );

    // Subsistema de multiplexación y decodificación [cite: 32, 33, 44, 45]
    display_mux_4_pos u_disp (
        .clk(clk), 
        .rst(!rst_n),           
        .tick_1ms(tick_1ms),
        .valor_captura(capture_value),
        .cociente(cociente_out),
        .residuo(residuo_out),
        .mostrar_res(!btn_selector),  // Alterna la visualización [cite: 47]
        .en_resultado(flag_mostrar_res), // Ahora usa la bandera permanente
        .digit_sel(digit_sel), 
        .led_seg(led_seg)
    );
endmodule