`timescale 1ns/1ps

module top_tb;

    logic clk;
    logic rst;
    logic valid;

    logic [5:0] dividendo;
    logic [3:0] divisor;

    logic [5:0] cociente;
    logic [3:0] residuo;
    logic done;

    divisor dut (
        .clk(clk),
        .rst(rst),
        .valid(valid),
        .dividendo(dividendo),
        .divisor(divisor),
        .cociente(cociente),
        .residuo(residuo),
        .done(done)
    );

    always #10 clk = ~clk;

    task probar_division;
        input [5:0] A;
        input [3:0] B;
        input [5:0] Q_esperado;
        input [3:0] R_esperado;
        begin
            dividendo = A;
            divisor   = B;

            @(posedge clk);
            valid = 1'b1;

            @(posedge clk);
            valid = 1'b0;

            wait(done == 1'b1);
            @(posedge clk);

            $display("%0d / %0d = Q:%0d R:%0d", A, B, cociente, residuo);

            if (cociente !== Q_esperado || residuo !== R_esperado) begin
                $display("ERROR: esperado Q:%0d R:%0d", Q_esperado, R_esperado);
            end else begin
                $display("OK");
            end

            @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("divisor.vcd");
        $dumpvars(0, top_tb);

        clk = 0;
        rst = 1;
        valid = 0;
        dividendo = 0;
        divisor = 0;

        #50;
        rst = 0;

        probar_division(6'd63, 4'd15, 6'd4,  4'd3);
        probar_division(6'd13, 4'd2,  6'd6,  4'd1);
        probar_division(6'd10, 4'd5,  6'd2,  4'd0);
        probar_division(6'd31, 4'd4,  6'd7,  4'd3);
        probar_division(6'd7,  4'd7,  6'd1,  4'd0);
        probar_division(6'd5,  4'd9,  6'd0,  4'd5);

        #100;
        $finish;
    end

endmodule