module display_mux_4_pos (
    input  logic        clk,
    input  logic        rst,      
    input  logic        tick_1ms, 
    input  logic [13:0] valor_captura, 
    input  logic [6:0]  cociente,      // AHORA: 7 bits
    input  logic [4:0]  residuo,       // AHORA: 5 bits
    input  logic        mostrar_res,   
    input  logic        en_resultado,  
    output logic [3:0]  digit_sel,
    output logic [6:0]  led_seg
);
    logic [3:0] d0, d1, d2, d3;
    logic [1:0] sel;
    logic [3:0] hex_actual;
    logic [13:0] valor_a_bcd;

    always_comb begin
        if (en_resultado) begin
            // AHORA: Rellenamos con ceros para completar los 14 bits exactos
            if (mostrar_res) valor_a_bcd = {9'd0, residuo}; 
            else             valor_a_bcd = {7'd0, cociente};
        end else begin
            valor_a_bcd = valor_captura;
        end
    end

    bin2bcd u_conv (
        .clk(clk),
        .rst(rst),
        .bin(valor_a_bcd),
        .mil(d3), .cen(d2), .dec(d1), .uni(d0)
    );
    
    always_ff @(posedge clk) begin
        if (tick_1ms) sel <= sel + 1'b1;
    end

    always_comb begin
        case(sel)
            2'b00: begin digit_sel = 4'b0001; hex_actual = d3; end 
            2'b01: begin digit_sel = 4'b0010; hex_actual = d2; end 
            2'b10: begin digit_sel = 4'b0100; hex_actual = d1; end 
            2'b11: begin digit_sel = 4'b1000; hex_actual = d0; end 
        endcase
    end

    display_hex_7seg u_dec (
        .hex     (hex_actual),
        .led_seg (led_seg)
    );
endmodule