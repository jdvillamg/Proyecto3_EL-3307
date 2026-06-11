`timescale 1ns / 1ps

module top_tb();

    // 1. Declaración de señales de prueba (cables que conectaremos al divisor)
    logic       clk;
    logic       rst;
    logic [6:0] A;
    logic [4:0] B;
    logic       valid;
    logic [6:0] Q;
    logic [4:0] R;
    logic       done;

    // 2. Instanciación del módulo a probar (UUT - Unit Under Test)
    divisor uut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .valid(valid),
        .Q(Q),
        .R(R),
        .done(done)
    );

    // 3. Generación del reloj (27 MHz aprox -> periodo de ~37ns)
    always #18.5 clk = ~clk;

    // 4. Proceso principal de estímulos
    initial begin
        // Configuración para generar el archivo de ondas para GTKWave
        $dumpfile("Proyecto3_Division.vcd");
        $dumpvars(0, top_tb);

        // Estado inicial de las señales
        clk   = 0;
        rst   = 1;
        A     = 7'd0;
        B     = 5'd0;
        valid = 1'b0;

        // Esperamos un poco y soltamos el reset
        #50 rst = 0;
        #50;

        // ----------------------------------------------------
        // PRUEBA 1: Pequeña (El caso donde el Dividendo es menor)
        // ----------------------------------------------------
        $display("----------------------------------------");
        $display("Iniciando Prueba 1: 5 / 12");
        A = 7'd5;
        B = 5'd12;
        valid = 1'b1;     // Damos la orden de iniciar
        #37; valid = 1'b0; // Bajamos la orden al siguiente ciclo
        
        wait(done);       // Esperamos a que el módulo levante la bandera 'done'
        $display("Resultado 1 -> Esperado: Q=0, R=5 | Obtenido: Q=%d, R=%d", Q, R);
        #100;             // Pausa visual antes de la siguiente prueba

        // ----------------------------------------------------
        // PRUEBA 2: Intermedia (División exacta)
        // ----------------------------------------------------
        $display("----------------------------------------");
        $display("Iniciando Prueba 2: 100 / 10");
        A = 7'd100;
        B = 5'd10;
        valid = 1'b1;
        #37; valid = 1'b0;
        
        wait(done);
        $display("Resultado 2 -> Esperado: Q=10, R=0 | Obtenido: Q=%d, R=%d", Q, R);
        #100;

        // ----------------------------------------------------
        // PRUEBA 3: Intermedia (El caso de borde que arreglamos)
        // ----------------------------------------------------
        $display("----------------------------------------");
        $display("Iniciando Prueba 3: 89 / 28");
        A = 7'd89;
        B = 5'd28;
        valid = 1'b1;
        #37; valid = 1'b0;
        
        wait(done);
        $display("Resultado 3 -> Esperado: Q=3, R=5 | Obtenido: Q=%d, R=%d", Q, R);
        #100;

        // ----------------------------------------------------
        // PRUEBA 4: Máxima (Los 35 puntos extra)
        // ----------------------------------------------------
        $display("----------------------------------------");
        $display("Iniciando Prueba 4: 127 / 31");
        A = 7'd127;
        B = 5'd31;
        valid = 1'b1;
        #37; valid = 1'b0;
        
        wait(done);
        $display("Resultado 4 -> Esperado: Q=4, R=3 | Obtenido: Q=%d, R=%d", Q, R);
        #100;

        $display("----------------------------------------");
        $display("Todas las pruebas finalizadas con exito.");
        $finish; // Termina la simulación
    end

endmodule