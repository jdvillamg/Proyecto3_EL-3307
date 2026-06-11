module clk_divider (
    input  logic clk,      
    input  logic rst,      
    output logic tick_en   
);

    localparam int MAX_COUNT = 27000;
    logic [14:0] counter;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 15'd0;
            tick_en <= 1'b0;
        end else begin
            if (counter == (MAX_COUNT - 1)) begin
                counter <= 15'd0;
                tick_en <= 1'b1; // Activo solo por un ciclo
            end else begin
                counter <= counter + 1'b1;
                tick_en <= 1'b0;
            end
        end
    end

endmodule