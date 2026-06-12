# Proyecto III - División en HDL

**Escuela de Ingeniería Electrónica** **EL-3307 Diseño Lógico** **I Semestre 2026**

---
## 1. Abreviaturas y definiciones
* FPGA: Field Programmable Gate Arrays
* FSM: Finite State Machine
* BCD: Binary Coded Decimal

## 2. Introducción
El diseño de sistemas digitales requiere habilidad de implementación de algoritmos por medio de circuitos lógicos. Muchos algoritmos en la práctica usan iteraciones, segmentación (pipelining) o bucles que a la hora de traducirlos a implementaciones de lógica booleana, surge la necesidad de un control lógico que habilite el
correcto flujo de datos en circuito. Asimismo, las interfaces de bloque a bloque se diseñan con protocolos de bus para ayudar a estandarizar la comunicación entre unidades. Estos protocolos de bus facilitan las pruebas unitarias sobre bloques porque toda unidad se puede controlar de una manera similar.

El proyecto consiste en diseñar e implementar en una FPGA (TangNano 9K) una unidad de división de enteros sin signo, usando SystemVerilog. La unidad toma un dividendo de hasta 6 bits (máximo 63) y un divisor de hasta 4 bits (máximo 15), y entrega el cociente y el residuo. El sistema se divide en cuatro subsistemas encadenados: lectura de datos; cálculo de la división; conversión binario a BCD; y despliegue en 7 segmentos.

## 3. Definición del problema, Objetivos y Especificaciones
### 3.1 Definición del problema 
En el diseño de sistemas digitales, la implementación de operaciones aritméticas complejas como la división entera representa un reto significativo, dado que, a diferencia de una suma, no existe una solución combinacional trivial de bajo costo. Se requiere desarrollar un circuito que capture manualmente un dividendo y un divisor en formato decimal desde un teclado hexadecimal, ejecute el algoritmo de división entera sin signo mediante una arquitectura con pipeline, y visualice tanto el cociente como el residuo en un display de 7 segmentos, garantizando la correcta sincronización entre subsistemas mediante señales de control y el manejo adecuado de ruido mecánico en las entradas.

### 3.2 Objetivos
* Objetivo General: Introducir al estudiante a la implementación de algoritmos por medio de máquinas de estados complejas
* Objetivos específicos:
  1. Elaborar una implementación de un diseño digital en una FPGA.
  2. Construir un testbench básico para validar las especificaciones del diseño.
  3. Implementar un algoritmo de división de enteros con una Máquina de estados con técnicas avanzadas.
  4. Coordinación de trabajo en equipo mediante el uso de herramientas de control de versiones.
  5. Practicar planificación de tareas para trabajo de grupo

### 3.3 Especificaciones 
* Frecuencia de reloj: El sistema debe operar exclusivamente a la frecuencia de 27 MHz provista por la TangNano 9K. Solo se permite un único reloj en todo el diseño; las bases de tiempo más lentas deben derivarse mediante divisores de frecuencia.
Lenguaje de descripción: SystemVerilog, siguiendo la metodología y estilo de codificación definidos en el curso, incluyendo el formato estipulado para máquinas de estados finitos (FSM).
* Sincronización: Todas las entradas externas deben registrarse y pasar por un proceso de debouncing para evitar metaestabilidad y rebotes mecánicos.
Capacidad de datos: Soporte para un dividendo decimal de hasta 2 dígitos (máximo 63, representable en 6 bits) y un divisor decimal de 1 dígito (máximo 15, representable en 4 bits).
* Algoritmo de división: Implementación del algoritmo iterativo de división por resta sucesiva descrito en el material "Digital Design and Computer Architecture: ARM Edition" de Harris & Harris, sección 5.2.7, con arquitectura en pipeline de 4 etapas para cumplir con el requisito de velocidad de 27 MHz.
* Señales de control entre subsistemas: El subsistema de lectura debe emitir una bandera valid al subsistema de cálculo cuando los operandos sean estables; el subsistema de cálculo debe emitir una bandera done al subsistema de despliegue cuando el resultado sea estable.
* Visualización: Despliegue del cociente o residuo en display de 7 segmentos, con selección entre ambos resultados mediante una tecla del teclado o botón dedicado. El manejo de los displays debe realizarse a través de transistores, no directamente desde los pines de la FPGA.
* Conversión de formato: El resultado binario debe convertirse a BCD antes del despliegue, utilizando el subsistema desarrollado en el proyecto corto II.

 ## 4. Desarrollo
 ### 4.1 Descripción general del funcionamiento 
El circuito diseñado constituye una unidad de división entera sincrónica para números decimales sin signo, implementada sobre la arquitectura de la FPGA Tang Nano 9K. El sistema opera bajo un esquema de jerarquía modular, donde un reloj de 27 MHz sincroniza tanto los periféricos de baja velocidad como la lógica aritmética interna. El flujo de datos se inicia con la captura de un dividendo y un divisor desde un teclado hexadecimal matricial, los cuales son procesados y convertidos a su representación binaria. Una vez que el subsistema de lectura valida los operandos mediante la bandera valid, el subsistema de cálculo ejecuta el algoritmo iterativo de división entera mediante una arquitectura con pipeline de 4 etapas, reduciendo el camino crítico para operar a la frecuencia requerida. Al concluir la operación, se emite la bandera done y el cociente o residuo resultante es convertido a formato BCD para su despliegue dinámico en los displays de 7 segmentos, con posibilidad de seleccionar entre ambos resultados mediante una entrada dedicada.

### 4.2 Descripción de cada subsistema y su diagrama de bloques
1. Subsistema de Lectura: 
Este subsistema tiene la función crítica de actuar como interfaz entre los elementos analógicos/mecánicos y el núcleo digital. Su objetivo es convertir la pulsación de las teclas en un valores binarios únicos y estables.

![Lectura](./Imagenes/Subsistema_de_Lectura.png)

Debido a que los contactos metálicos del teclado oscilan antes de estabilizarse, el debouncer o filtro antirrebote utiliza un registro de desplazamiento para muestrear la señal de las columnas. Solo cuando la señal se mantiene constante durante varios ciclos de tick_en, el filtro emite un valor limpio, eliminando falsos disparos. 

![Lectura1](./Imagenes/debouncer.png)

El barrido es un contador de anillo que genera un cero caminante en las filas del teclado. Al poner una fila en nivel bajo (0) de forma secuencial, permite identificar cuál tecla se ha cerrado al monitorear las columnas. El decodificador es el bloque de lógica combinacional que asocia la coordenada (Fila, Columna) con un valor de 4 bits (0-F). Su función fundamental es el mapeo lógico de la matriz física al lenguaje hexadecimal. Por último, el detector de flanco es el elemento que asegura que, aunque una tecla se mantenga presionada por mucho tiempo, el sistema solo registre la pulsación una vez. Genera un pulso de un solo ciclo de reloj que activa el resto de la lógica del sistema.

![Lectura2](./Imagenes/barridoydeco.png)

2. Subsistema  de cálculo de la división entera:
Este subsistema tiene la función crítica de administrar la interfaz de usuario para la captura de operandos y ejecutar de manera segura el algoritmo matemático de la división entera en hardware. Su objetivo es recibir las pulsaciones del teclado, consolidar numéricamente el dividendo A y el divisor B, procesar la operación aritmética de forma síncrona y coordinar la entrega estable de los resultados (cociente Q y residuo R) hacia la etapa de visualización.

![Division](./Imagenes/SubsistemaDeDivision.png)

Debido a que el usuario introduce los datos dígito por dígito en base decimal, el control de división es una FSM que acumula los valores multiplicándolos sucesivamente por 10. Para garantizar la integridad del hardware, este bloque implementa comparadores de límites dinámicos que restringen las magnitudes a un rango estricto de 7 bits para el dividendo (máximo 127) y 5 bits para el divisor (máximo 31). Una vez validados y confirmados los operandos, se inicia un protocolo de comunicación mediante la bandera div_valid para utilizar el núcleo matemático. 

Aqui falta imagen

El divisor es el modulo aritmético del subsistema y opera mediante una FSM dedicada que ejecuta el algoritmo de desplazamiento y resta sucesiva en 7 ciclos de reloj. Utiliza un registro integrado de 13 bits (RQ) que fusiona el residuo parcial y el cociente en formación. En cada ciclo, una unidad restadora combinacional evalúa si el divisor cabe en el residuo temporal inspeccionando el bit de signo del resultado; con base en este bit, se decide si se resta el valor y se inserta un '1' o un '0' en el cociente. El diseño incluye además un bloque de protección contra división por cero que aborta el ciclo iterativo instantáneamente si el divisor es nulo, asignando el valor máximo al cociente y levantando de inmediato la bandera done para notificar que el resultado es estable y seguro de desplegar.

![Division2](./Imagenes/divisor.png)




3. Subsistema de conversión de binario a representación BCD y viceversa
Este último subsistema consiste en la interfaz de salida. Este subsistema gestiona la potencia y el despliegue de la información mediante multiplexación temporal.

![Suma](./Imagenes/Subsistema_de_Despliegue.png)

Dado que la suma se realiza en binario, el convertidor es fundamental para separar el número en unidades, decenas, centenas y millares (si fuera necesario). Transforma un valor de hasta 14 bits en cuatro grupos de 4 bits independientes. El contador de refresco genera un índice cíclico a una frecuencia de aproximadamente 1 kHz. Este índice determina qué posición del display se está atendiendo en cada microsegundo. El multiplexor toma los cuatro dígitos del convertidor BCD y, sincronizado con el contador de refresco, selecciona cuál dígito enviar al decodificador de segmentos. El decodificador de ánodos toma el índice del contador y activa físicamente el pin que energiza el display correspondiente. Esto asegura que el dígito de las "unidades" solo se encienda en la posición de las unidades. Por último, mediante el decodificador de segmentos, la tabla de verdad convertida a hardware traduce el número de 4 bits al patrón de encendido de los ledes necesarios para dibujar el número.

4. Subsistema de despliegue en display de 7 segmentos.


## 5. Máquinas de Estados Finitos / Finite State Machines (FSMs) implementadas
El comportamiento secuencial del sistema está bajo el control de tres Máquinas de Estados Finitas (FSM) que operan de manera concurrente para gestionar la captura, el procesamiento y la validación de los datos.

1. FSM Unidad de Control Lógico:

```
always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= ST_NUM1;
            n1_reg <= 14'd0; n2_reg <= 14'd0; res_reg <= 14'd0;
            valor_a_mostrar <= 14'd0;
        end else begin
            if (tecla_detectada) begin
                if (tecla_val == 4'hB) begin // B: Borrar todo
                    state_reg <= ST_NUM1;
                    n1_reg <= 14'd0; n2_reg <= 14'd0; res_reg <= 14'd0;
                end else begin
                    case (state_reg)
                        ST_NUM1: begin
                            
                            if (es_numero && n1_reg <= 14'd99) 
                                n1_reg <= (n1_reg * 14'd10) + {10'd0, tecla_val};
                            else if (tecla_val == 4'hF) // #: Enter N1
                                state_reg <= ST_NUM2;
                        end
                        ST_NUM2: begin
                            
                            if (es_numero && n2_reg <= 14'd99)
                                n2_reg <= (n2_reg * 14'd10) + {10'd0, tecla_val};
                            else if (tecla_val == 4'hA) begin // A: Resultado
                                res_reg   <= n1_reg + n2_reg;
                                state_reg <= ST_RESULT;
                            end
                        end
                        ST_RESULT: ; // Bloqueado hasta presionar B
                    endcase
                end
            end
            
            
            case (state_reg)
                ST_NUM1:   valor_a_mostrar <= n1_reg;
                ST_NUM2:   valor_a_mostrar <= n2_reg;
                ST_RESULT: valor_a_mostrar <= res_reg;
                default:   valor_a_mostrar <= 14'd0;
            endcase
        end
```

Esta es una máquina de estados tipo Moore encargada de orquestar la ruta de datos. 
* ST_NUM1 (Operando 1): Estado inicial de reposo. El sistema habilita la escritura en el primer registro (n1_reg) y la lógica de acumulación decimal. Transita al siguiente estado únicamente al recibir el pulso de validación de la tecla 'Enter' (4'hF).
* ST_NUM2 (Operando 2): El sistema bloquea el primer registro y dirige los nuevos datos hacia el registro secundario (n2_reg). La transición ocurre al detectar la pulsación de la tecla 'Resultado' (4'hA).
* ST_RESULT (Resultado): El sistema deshabilita la captura de nuevos dígitos y enruta la salida del sumador combinacional hacia el registro de resultado (res_reg), manteniéndolo estable en pantalla. El sistema permanece en este estado hasta que se aplique un reinicio general mediante la tecla 'Borrar' (4'hB), la cual fuerza el retorno a ST_NUM1.

![Control](./Imagenes/FSM1.png)

2. FSM Barrido de Matriz:

```
always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            row_idx <= 2'b00;
        end else if (tick_en && !pause_scan) begin
            row_idx <= row_idx + 1'b1;
        end
    end

    always_comb begin
        case (row_idx)
            2'b00: rows_out = 4'b0001; // Fila 0 activa
            2'b01: rows_out = 4'b0010; // Fila 1 activa
            2'b10: rows_out = 4'b0100; // Fila 2 activa
            2'b11: rows_out = 4'b1000; // Fila 3 activa
            default: rows_out = 4'b0000;
        endcase
    end
```

Máquina de estados cíclica y autónoma diseñada para la exploración secuencial del teclado matricial. Posee cuatro estados correspondientes al índice lógico de las filas del teclado (2'b00, 2'b01, 2'b10, 2'b11).
En cada ciclo del reloj base (o tick de habilitación), la FSM avanza al siguiente estado, desplazando un cero lógico (0) por los pines de salida conectados a las filas.
Si el decodificador detecta un nivel lógico bajo en alguna de las columnas (indicando que una tecla fue presionada), la FSM suspende temporalmente sus transiciones de estado. Congela la fila activa para permitir que el filtro antirrebote estabilice la lectura sin perder la coordenada espacial del botón presionado.

![Barrido](./Imagenes/FSM2.png)

3. FSM de Detección de Flanco Positivo:

```
always @* begin
        valor_tecla = 4'h0;
        if (cualquier_tecla) begin
            case (row_idx)
                2'b00: begin // Fila 0
                    if      (cols_clean[0]) valor_tecla = 4'h1;
                    else if (cols_clean[1]) valor_tecla = 4'h2;
                    else if (cols_clean[2]) valor_tecla = 4'h3;
                    else if (cols_clean[3]) valor_tecla = 4'hA;
                end
                2'b01: begin // Fila 1
                    if      (cols_clean[0]) valor_tecla = 4'h4;
                    else if (cols_clean[1]) valor_tecla = 4'h5;
                    else if (cols_clean[2]) valor_tecla = 4'h6;
                    else if (cols_clean[3]) valor_tecla = 4'hB;
                end
                2'b10: begin // Fila 2
                    if      (cols_clean[0]) valor_tecla = 4'h7;
                    else if (cols_clean[1]) valor_tecla = 4'h8;
                    else if (cols_clean[2]) valor_tecla = 4'h9; 
                    else if (cols_clean[3]) valor_tecla = 4'hC;
                end
                2'b11: begin // Fila 3
                    if      (cols_clean[0]) valor_tecla = 4'hE; 
                    else if (cols_clean[1]) valor_tecla = 4'h0;
                    else if (cols_clean[2]) valor_tecla = 4'hF; // #
                    else if (cols_clean[3]) valor_tecla = 4'hD;
                end
            endcase
        end
    end

    logic prev_pressed;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            prev_pressed <= 1'b0;
            tecla_valida <= 1'b0;
        end else begin
            prev_pressed <= cualquier_tecla;
            tecla_valida <= cualquier_tecla && !prev_pressed;
        end
    end
```

Una FSM más pequeña, de dos estados, que funciona como un filtro temporal que transforma el nivel lógico sostenido de una pulsación mecánica en un único pulso digital de un ciclo de reloj.
* Espera: El registro de memoria (prev_pressed) se encuentra en 0. El sistema monitorea la señal proveniente del filtro antirrebote. Al detectar un cambio a nivel alto, la salida de validación (tecla_valida) se dispara a 1 y la FSM transita al siguiente estado.
* Pulsado: El registro memoriza que la tecla ya fue procesada (prev_pressed = 1). En este estado, la señal de validación se fuerza inmediatamente a 0, previniendo múltiples lecturas accidentales del mismo dígito. El sistema permanece bloqueado en este estado hasta que el usuario libere físicamente el botón, momento en el cual transita de vuelta al estado de espera.

![Detección](./Imagenes/FSM3.png)

## 6. Simulación funcional del sistema
Para verificar la correctitud, se desarrolló un entorno de pruebas (testbench). Se estimularon las entradas del sistema emulando el comportamiento asincrónico del teclado matricial y se monitorearon las señales de control internas de la FSM, así como los registros del datapath.
A continuación, se presenta el análisis de la forma de onda resultante, dividiendo la operación en las fases del sistema:

![Simulación del calculador](./Imagenes/Testbench.jpeg)

### 6.1 Condiciones Iniciales y Reinicio (Reset)
En el instante [t = 10 ms], se aplica un pulso en alto a la señal de rst. Como se observa en la simulación, esto inicializa el sistema de manera sincrónica:

El registro de estado de la máquina de control (state_reg) se establece en su valor de reposo: ST_NUM1. Los registros de almacenamiento de datos (n1_reg, n2_reg, y res_reg) se limpian y muestran un valor de 0. La salida del multiplexor principal (valor_a_mostrar) refleja correctamente el valor 0, validando la lógica combinacional de selección inicial.

### 6.2. Captura de operandos y suma
A partir del instante [t = 10 ms], se emula la pulsación de teclas numéricas para el primer operando. Al colocar el primer valor (4'h1) y forzar un pulso en la señal tecla_detectada, se observa cómo la FSM evalúa la condición es_numero == 1. En el siguiente flanco de subida del reloj, el registro n1_reg actualiza su valor a 1. Al ingresar un segundo dígito (4'h5), la lógica de acumulación decimal multiplica el valor anterior por 10 y suma el nuevo dígito, resultando en n1_reg = 15 (el cual se visualiza en la simulación). Durante esta fase, el sistema permanece estable en ST_NUM1.

Posteriormente, tras la transición al estado ST_NUM2, se repite el proceso para el segundo operando. Al ingresar el dígito 4'h0, el registro n2_reg se mantiene en 0. Al introducir el segundo dígito (4'h9), la lógica de control actualiza el registro a 9 (hexadecimal 09). Finalmente, al presionar la tecla de ejecución (4'hA), en el tiempo [t = 310 ms], se emula la pulsación de la tecla de confirmación o Enter. El sistema captura la suma de ambos registros, resultando en 24, dentro del registro res_reg.

Se realiza un ejemplo similar pero ahora con números de tres digitos. Se coloca el 999 en el teclado dos veces, resultando la suma en el número 1998.

## 7. Análisis de consumo de recursos y potencia 
Tras el proceso de síntesis y mapeo en la FPGA Tang Nano 9k, utilizando el flujo de herramientas de OSS CAD Suite, se obtuvieron los siguientes resultados para una frecuencia objetivo de 27.00 MHz:


--------------------------------------------------------------------------------------------------------------------------------------------------
## Análisis de Recursos y Síntesis

### Utilización Física del Dispositivo (Place & Route)

Esta tabla refleja el impacto del diseño sobre los bloques físicos disponibles en la FPGA. El diseño es sumamente eficiente, ocupando aproximadamente un 10% de la capacidad total del chip.

| Recurso de la FPGA | Usado | Disponible | Utilización |
| :--- | :---: | :---: | :---: |
| **SLICE** (Celdas Lógicas) | 936 | 8640 | `10.83%` |
| **IOB** (Pines de Entrada/Salida) | 22 | 274 | `8.03%` |
| **MUX2_LUT5** (Multiplexores de 5 entradas) | 96 | 4320 | `2.22%` |
| **MUX2_LUT6** (Multiplexores de 6 entradas) | 29 | 2160 | `1.34%` |
| **MUX2_LUT7** (Multiplexores de 7 entradas) | 9 | 1080 | `0.83%` |
| **MUX2_LUT8** (Multiplexores de 8 entradas) | 2 | 1056 | `0.19%` |
| **GSR** (Global Set/Reset) | 1 | 1 | `100.00%` |
| **RAMW** (Bloques de Memoria BRAM) | 0 | 270 | `0.00%` |
| **OSC / rPLL** (Relojes integrados) | 0 | 3 | `0.00%` |

### Desglose de Primitivas Lógicas (Síntesis)

Elementos individuales inferidos por el sintetizador a partir del código SystemVerilog:

| Categoría | Detalle de Componentes | Cantidad | Total |
| :--- | :--- | :---: | :---: |
| **Tablas de Búsqueda (LUTs)** | LUT1 (322), LUT2 (177), LUT3 (71), LUT4 (95) | - | **665** |
| **Registros (Flip-Flops)** | DFFC (37), DFFCE (166), DFFE (2), DFFP (1), DFFPE (14) | - | **220** |
| **Aritmética** | ALU | 137 | **137** |
| **Búferes I/O** | Entradas (7), Salidas (15) | - | **22** |

### Notas de Rendimiento
* **Memoria:** El diseño actual opera puramente con lógica combinacional y Flip-Flops distribuidos, sin requerir el uso de bloques de memoria RAM dedicados.
* **Frecuencia Máxima (fmax):** El diseño cumple holgadamente con los requisitos de tiempo de la placa base (27.00 MHz), logrando una frecuencia máxima teórica de reloj de **93.26 MHz**.


--------------------------------------------------------------------------------------------------------------------------------------------------
A diferencia de un diseño puramente combinacional, este sistema secuencial reporta un uso del 8% de los bloques lógicos (SLICEs). Este incremento es el esperado por la implementación de las tres Máquinas de Estados Finitas (FSM), los contadores para el barrido y refresco, y los registros de 14 bits para el almacenamiento de los operandos y el resultado. 

Además, el uso de 21 bloques de entrada/salida (IOB) coincide exactamente con la arquitectura del hardware físico: pines para las filas y columnas del teclado matricial, los segmentos y ánodos del display, el Clock y el botón de reinicio. El diseño es eficiente, dejando más del 90% del libre por si se desea hacer expansiones.

### 7.2 Estimación de Consumo Energético
Tomando en cuenta las características del flujo de síntesis y el reporte de recursos, el análisis energético se proyecta de la siguiente manera:
* **Potencia Estática:** Se mantiene en niveles mínimos propios de la familia GW1NR-9, dado que la mayor parte del silicio (92%) se encuentra inactiva.
* **Potencia Dinámica:** A diferencia de diseños asincrónicos, este sistema es impulsado por un Clock operando a **27.00 MHz**. Por lo tanto, existe un consumo dinámico continuo originado por el contador de barrido del teclado y la multiplexación de los displays a 1 kHz. Sin embargo, debido a la baja cantidad de lógica de conmutación (770 SLICEs), la disipación térmica y el consumo eléctrico general siguen siendo despreciables y manejables por la alimentación estándar del USB.

## 8. Reporte de velocidades máximas de reloj posibles 
El análisis de temporización estática fue generado por la herramienta de Place and Route (NextPNR) tras la síntesis del diseño y el enrutamiento lógico en la FPGA. Dado que la placa Tang Nano 9k cuenta con un oscilador de cristal integrado de 27.00 MHz, el diseño fue restringido para cumplir con este presupuesto de tiempo base.

### 8.1 Resultados del Análisis de Temporización:
* Frecuencia: 27.00 MHz
* Frecuencia Máxima Estimada (F_max): 122.52 MHz

### 8.2 Análisis de la Ruta Crítica (Critical Path):
La velocidad máxima de un diseño digital está dictada por su ruta crítica, es decir, el camino combinacional más largo entre dos flip-flops. En la arquitectura de esta calculadora, la mayor profundidad lógica recae en los módulos aritméticos. Específicamente, el bloque combinacional del sumador y el módulo convertidor de binario a BCD (`bin2bcd`) imponen los mayores retardos de propagación debido a las múltiples compuertas en cascada necesarias para procesar buses de 14 bits.

Dado que la frecuencia máxima soportada por la lógica enrutada (122.52 MHz) es superior a la frecuencia de operación real del Clock, el sistema tiene un margen de tiempo positivo. Esto garantiza que el diseño cumple con todos los requerimientos de *setup* y *hold*, asegurando la estabilidad sincrónica del circuito sin riesgo de incurrir en estados de metaestabilidad.

## 9. Ejercicios
### 9.1 Contadores sincrónicos

En este ejercicio se implementó y analizó el funcionamiento de contadores sincrónicos 74HC163 conectados en cascada. Para realizar la prueba, se generó una señal de reloj desde la FPGA TangNano 9k. Posteriormente, se observaron las salidas del contador mediante el osciloscopio/analizador lógico, con el fin de verificar el conteo binario, la división de frecuencia, el funcionamiento de la salida de acarreo `RCO` y la conexión en cascada entre dos contadores.

El 74HC163 es un contador binario sincrónico de 4 bits. Esto significa que sus salidas cambian de estado únicamente en sincronía con el flanco activo del reloj. En este caso, el conteo ocurre con el flanco positivo de la señal `CLK`. Al tratarse de un contador de 4 bits, sus salidas `QA`, `QB`, `QC` y `QD` representan un número binario desde `0000` hasta `1111`, equivalente a los valores decimales de 0 a 15.

#### Verificación del conteo

En la siguiente captura se observa la señal de reloj junto con las salidas del contador.

![Salidas QA QB QC QD con referencia al CLK](./Imagenes/ejercicio1_2.png)

| Señal | Frecuencia medida | Relación esperada |
|---|---:|---|
| `CLK` | 1.799 MHz | Frecuencia base |
| `QA` | 931 kHz | `CLK / 2` |
| `QB` | 457.7 kHz | `CLK / 4` |
| `QC` | 231.64 kHz | `CLK / 8` |

Estos resultados permiten comprobar que el contador funciona correctamente. La salida `QA` cambia aproximadamente a la mitad de la frecuencia del reloj. La salida `QB` cambia aproximadamente a la mitad de `QA`, y la salida `QC` cambia aproximadamente a la mitad de `QB`. 

En términos de conteo, las salidas siguen una secuencia binaria como la siguiente:

| Decimal | `QD` | `QC` | `QB` | `QA` |
|---:|---:|---:|---:|---:|
| 0 | 0 | 0 | 0 | 0 |
| 1 | 0 | 0 | 0 | 1 |
| 2 | 0 | 0 | 1 | 0 |
| 3 | 0 | 0 | 1 | 1 |
| 4 | 0 | 1 | 0 | 0 |
| ... | ... | ... | ... | ... |
| 15 | 1 | 1 | 1 | 1 |

Después de llegar a `1111`, el contador vuelve a `0000`.


De aqui, se logra ver la salida `RCO`, la cual corresponde al acarreo del contador. Su función es indicar que el contador ha alcanzado su valor máximo y que está listo para producir un acarreo hacia otro contador.

Como el 74HC163 es un contador de 4 bits, su valor máximo es `1111`, que corresponde al número decimal 15. Cuando el contador llega a `1111` y las entradas de habilitación permiten el conteo, la salida `RCO` se activa. Esta señal indica que el contador completó su ciclo de conteo y que, en el siguiente avance, volverá a `0000`.

La función de `RCO` es similar al acarreo que ocurre en una suma binaria. Por ejemplo, cuando una cifra llega a su valor máximo, se genera una señal para incrementar la siguiente cifra. En este caso, cuando el primer contador llega a 15, `RCO` permite que el segundo contador avance una unidad. Por lo tanto, `RCO` sirve para extender la capacidad de conteo al conectar varios contadores en cascada.

`RCO` del primer contador se conecta a la entrada `T/ENT` del segundo contador para formar una conexión en cascada.

El primer contador funciona como la parte menos significativa del conteo. Este contador avanza en cada pulso de reloj y cuenta desde `0000` hasta `1111`. Cuando completa ese ciclo, activa la salida `RCO`.

La entrada `T/ENT` del segundo contador funciona como una habilitación de conteo. Por eso, al conectar `RCO` del primer contador con `T/ENT` del segundo, se logra que el segundo contador no avance en todos los pulsos del reloj, sino solamente cuando el primer contador ha completado su secuencia.

La conexión en cascada permite que dos contadores de 4 bits trabajen como si fueran un contador de mayor capacidad.

Ambos contadores reciben la misma señal de reloj. Sin embargo, el segundo contador solo puede avanzar cuando su entrada `T/ENT` está habilitada. Como esta entrada está conectada al `RCO` del primer contador, el segundo contador solo cambia de estado cuando el primero llega a su valor máximo.

El primer contador realiza la secuencia `0000`, `0001`, `0010`, `0011`, hasta llegar a `1111`. Mientras el primer contador realiza esa secuencia, el segundo contador mantiene su estado. Cuando el primer contador pasa de `1111` a `0000`, se genera el acarreo mediante `RCO`, y el segundo contador incrementa su valor en una unidad.

El conteo completo puede interpretarse de esta manera:

| Segundo contador | Primer contador | Valor general |
|---|---|---|
| `0000` | `0000` | Inicio del conteo |
| `0000` | `0001` | Avanza el primer contador |
| `0000` | `0010` | Avanza el primer contador |
| `0000` | `...` | Continúa el primer contador |
| `0000` | `1111` | Primer contador en valor máximo |
| `0001` | `0000` | Avanza el segundo contador |

En algunos datasheets del 74HC163, las entradas `T` y `P` aparecen con los nombres `ENT` y `ENP`. En este caso, `P` corresponde a `ENP` y `T` corresponde a `ENT`.

Ambas entradas sirven para habilitar el conteo, pero no cumplen la misma función.Mientars que la entrada `P` o `ENP` permite que el contador avance cuando se produce el flanco activo del reloj. Si esta entrada no está habilitada, el contador mantiene su valor actual y no cuenta.

La entrada `T` o `ENT` también permite que el contador avance, pero además participa en la generación de la señal `RCO`. Esto significa que `ENT` no solo habilita el conteo, sino que también influye en la salida de acarreo que permite conectar contadores en cascada.

La diferencia puede resumirse así:

| Entrada | Nombre alternativo | Función |
|---|---|---|
| `P` | `ENP` | Habilita el conteo del contador |
| `T` | `ENT` | Habilita el conteo y participa en la generación de `RCO` |

Para que un contador individual cuente normalmente, ambas entradas deben estar en nivel lógico alto. En una conexión en cascada, la entrada `ENT/T` del segundo contador se conecta al `RCO` del primer contador. Esto permite que el segundo contador avance solamente cuando el primero completa su ciclo de conteo. Por esta razón, `ENT/T` es fundamental para extender el conteo utilizando varios contadores.

El tiempo que tarda una salida del contador en cambiar después del flanco positivo del reloj se conoce como retardo de propagación el cual fue de aprpoximadamente 21ns.

Aunque el 74HC163 es un contador sincrónico, sus salidas no cambian exactamente en el mismo instante en que ocurre el flanco positivo de `CLK`. Internamente, el flanco de reloj debe activar los flip-flops del contador, y luego la señal debe propagarse hasta las salidas `QA`, `QB`, `QC` y `QD`.

Para este, si puede importar cuál bit de salida se escoja.

La salida `QA` es el bit menos significativo, por lo que cambia con mayor frecuencia. Su frecuencia es aproximadamente `CLK / 2`. La salida `QB` cambia más lento, aproximadamente `CLK / 4`. La salida `QC` cambia aproximadamente `CLK / 8`, y la salida `QD` cambia aproximadamente `CLK / 16`.

Por esta razón, `QA` suele ser la salida más conveniente para medir el retardo, ya que presenta más transiciones y facilita la captura del evento en el osciloscopio.

Además, aunque las salidas pertenecen al mismo contador sincrónico, pueden existir pequeñas diferencias prácticas debido a la lógica interna del circuito integrado o la carga conectada a cada salida. 

Por lo tanto, sí importa cuál bit se escoja, especialmente desde el punto de vista práctico de la medición. Una salida que cambia con mayor frecuencia permite observar y medir más fácilmente el retardo respecto al reloj.

En la siguiente captura se observa la señal de reloj junto con la salida `RCO` del contador menos significativo.

![CLK con salida RCO](./Imagenes/ejercicio1_3.png)

La señal `RCO` no cambia en cada pulso del reloj. A diferencia de las salidas `QA`, `QB`, `QC` y `QD`, que representan los bits del conteo, `RCO` solo se activa cuando el contador alcanza la condición de acarreo.

Durante la medición realizada no se observó claramente una falla o glitch en la salida `RCO`. La señal se comportó de forma estable dentro de la resolución utilizada en el osciloscopio/analizador lógico.

Sin embargo, esto no significa que no puedan existir glitches. Un glitch es un pulso muy corto no deseado que puede aparecer en una señal digital debido a diferencias de retardo dentro de la lógica combinacional.

En nuestro caso, no se logró identificar visualmente un glitch claro en la señal `RCO`.

En el caso del 74HC163, la salida `RCO` depende de la condición de conteo máximo y de las señales de habilitación. Esto significa que `RCO` se genera a partir de una combinación interna de varias señales del contador.

Cuando el contador cambia de un estado a otro, las salidas internas no cambian exactamente al mismo tiempo. Aunque el contador sea sincrónico, cada señal interna puede tener un pequeño retardo de propagación diferente. Si la lógica que genera `RCO` recibe esos cambios en instantes ligeramente distintos, puede producirse un pulso breve no deseado.

Un caso especialmente importante es la transición de `1111` a `0000`. En esta transición cambian varios bits del contador al mismo tiempo. Debido a los pequeños retardos internos, la lógica que genera `RCO` puede interpretar momentáneamente una combinación incorrecta de señales y producir un glitch.

Por esta razón, es más esperable hallar glitches en `RCO` durante transiciones donde cambian varios bits simultáneamente, especialmente alrededor del valor máximo del conteo.


### 9.2 Construcción de un cerrojo Set-Reset con compuertas NAND

En este ejercicio se construyó un cerrojo `SR` positivo utilizando compuertas NAND del circuito integrado `74HC00`. La señal de reloj fue generada desde la FPGA y aplicada al circuito para controlar cuándo el cerrojo podía cambiar de estado. El objetivo fue comprobar el funcionamiento de las entradas `S` y `R`, observar las salidas `Q` y `QN`, y analizar el caso no permitido cuando ambas entradas se activan al mismo tiempo.

El cerrojo `SR` funciona como una memoria básica de un bit. La entrada `S` se utiliza para colocar la salida `Q` en alto, mientras que la entrada `R` se utiliza para reiniciar la salida `Q` a bajo. Como el circuito está controlado por reloj, los cambios en la salida solamente ocurren cuando `CLK` está en nivel alto. Cuando `CLK` está en bajo, el cerrojo mantiene su estado anterior.

La conexión general utilizada fue la siguiente:

| Señal | Función |
|---|---|
| `S` | Entrada de Set |
| `R` | Entrada de Reset |
| `CLK` | Señal de habilitación generada por la FPGA |
| `Q` | Salida principal |
| `QN` | Salida complementaria |

La tabla de funcionamiento del cerrojo es:

| `CLK` | `S` | `R` | `Q` siguiente | `QN` siguiente | Operación |
|---:|---:|---:|---:|---:|---|
| 0 | X | X | Mantiene | Mantiene | Sin cambio |
| 1 | 0 | 0 | Mantiene | Mantiene | Memoria |
| 1 | 1 | 0 | 1 | 0 | Set |
| 1 | 0 | 1 | 0 | 1 | Reset |
| 1 | 1 | 1 | No permitido | No permitido | Condición inválida |

![Diagrama](./Imagenes/DiagramaDeCompuerta.jpeg)

En la condición de **Set**, cuando `CLK = 1`, `S = 1` y `R = 0`, la salida `Q` se coloca en alto y `QN` se coloca en bajo. Esto demuestra que el cerrojo puede almacenar un `1`.

![Set](./Imagenes/EjExtra2.2.jpeg)

En la condición de **Reset**, cuando `CLK = 1`, `S = 0` y `R = 1`, la salida `Q` se coloca en bajo y `QN` se coloca en alto. Esto demuestra que el cerrojo puede borrar el valor almacenado.

![Reset](./Imagenes/EjExtra2.3.jpeg)

Cuando `CLK = 0`, el cerrojo no responde a los cambios en `S` o `R`, por lo que mantiene el estado anterior. Esto se debe a que las compuertas de entrada quedan deshabilitadas por el reloj.

![Clock 0-0](./Imagenes/EjExtra2.1.jpeg)

El caso `S = 1` y `R = 1` con `CLK = 1` se considera una condición no permitida. En este caso, el circuito recibe dos instrucciones contradictorias: hacer Set y Reset al mismo tiempo. Por esta razón, las salidas pueden dejar de comportarse como complementarias y el estado final puede ser impredecible cuando las entradas vuelvan a cambiar. Esta condición se debe evitar en el uso normal del cerrojo.

![Metaestable](./Imagenes/EjExtra2.4.jpeg)

## 10. Dificultades y problemas durante el trabajo
* Problema con el tiempo: Hubo dificultades para tener una distribución correcta del tiempo durante el trabajo. Se requirió planificar de mejor manera las tareas para aprovechar correctamente el tiempo disponible para realizar y entregar el proyecto.
