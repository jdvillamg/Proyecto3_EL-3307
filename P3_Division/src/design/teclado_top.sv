module teclado_top (
    input  logic       clk,
    input  logic       rst,
    input  logic       tick_en, 
    input  logic [3:0] cols,    
    output logic [3:0] rows,
    output logic [3:0] valor_tecla,
    output logic       tecla_valida
);
    logic [1:0] row_index;
    logic [3:0] cols_clean;
    
    logic raw_press;
    logic [6:0] pause_timer; 
    logic pause_scan;

    assign raw_press = (cols != 4'b0000);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pause_timer <= 7'd0;
        end else begin
            if (raw_press) begin
                pause_timer <= 7'd50; 
            end else if (tick_en && pause_timer > 0) begin
                pause_timer <= pause_timer - 7'd1;
            end
        end
    end

    assign pause_scan = (pause_timer > 0) || raw_press;

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_debouncers
            debouncer u_db (
                .clk(clk), .rst(rst), .tick_en(tick_en),
                .ruido(cols[i]), .clean(cols_clean[i])
            );
        end
    endgenerate

    barrido u_scanner (
        .clk(clk), .rst(rst), .tick_en(tick_en),
        .pause_scan(pause_scan), .rows_out(rows), .row_idx(row_index)
    );

    decodificador u_decoder (
        .clk(clk), .rst(rst), .row_idx(row_index), 
        .cols_clean(cols_clean), .valor_tecla(valor_tecla), 
        .tecla_valida(tecla_valida)
    );
endmodule