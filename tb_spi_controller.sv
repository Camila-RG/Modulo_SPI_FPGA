module tb_spi_controller;

    // Sinais de clock, reset e controle
    reg clk = 0;        
    reg reset = 1;        
    reg tied_SS = 1;     

    // Largura de palavra
    localparam DATA_BITS = 8;

    // Palavras a serem enviadas pelo mestre
    reg [DATA_BITS-1:0] palavra0;
    reg [DATA_BITS-1:0] palavra1;
    reg [DATA_BITS-1:0] palavra2;
    reg [DATA_BITS-1:0] palavra3;

    // Sinais SPI
    wire SCK, SS, MOSI;
    reg MISO;

    // Sinal de término da transmissão
    wire done;

    // Palavras recebidas do escravo
    wire [DATA_BITS-1:0] received_word0;
    wire [DATA_BITS-1:0] received_word1;
    wire [DATA_BITS-1:0] received_word2;
    wire [DATA_BITS-1:0] received_word3;

    // Instancia o módulo a ser testado (DUT)
    spi_controller #(
        .DATA_BITS(DATA_BITS)
    ) dut (
        .clk(clk),
        .reset(reset),
        .tied_SS(tied_SS),
        .palavra0(palavra0),
        .palavra1(palavra1),
        .palavra2(palavra2),
        .palavra3(palavra3),
        .done(done),
        .SCK(SCK),
        .SS(SS),
        .MOSI(MOSI),
        .MISO(MISO),
        .received_word0(received_word0),
        .received_word1(received_word1),
        .received_word2(received_word2),
        .received_word3(received_word3)
    );

    // Inicialização e configuração para GTKWave
    initial begin
        $dumpfile("spi_controller_tb.vcd"); // Arquivo de saída para GTKWave
        $dumpvars(0, tb_spi);               // Salva os sinais do testbench

        // Define as palavras a serem enviadas
        palavra0 = 8'hFA;
        palavra1 = 8'hFB;
        palavra2 = 8'hFC;
        palavra3 = 8'hFE;
    end

    // Geração do clock de 10 ns (100 MHz)
    always #5 clk = ~clk;

    // Lógica do escravo SPI que responde com palavras pré-definidas
    reg [7:0] shift_out;        
    reg [2:0] bit_count;        
    reg ss_reg = 1;              
    reg sck_reg = 0;         
    reg [7:0] palavras_resposta [0:3];
    reg [1:0] palavra_atual;     

    assign MISO = shift_out[7]; // Sempre envia o bit mais significativo

    // Captura bordas de SS e SCK
    always @(posedge clk) begin
        ss_reg <= SS;
        sck_reg <= SCK;
    end

    // Reinicia índice da palavra quando SS sobe
    always @(posedge SS) begin
        palavra_atual <= 0;
    end

    // Envia bits do escravo para o mestre
    always @(negedge sck_reg or posedge ss_reg) begin
        if (ss_reg) begin
            bit_count <= 0;
            shift_out <= palavras_resposta[palavra_atual];
        end else begin
            shift_out <= {shift_out[6:0], 1'b0};
            bit_count <= bit_count + 1;
            if (bit_count == 7) begin
                bit_count <= 0;
                palavra_atual <= palavra_atual + 1;
                shift_out <= palavras_resposta[palavra_atual + 1];
            end
        end
    end

    // Inicializa respostas do escravo
    initial begin
        palavras_resposta[0] = 8'hFA;
        palavras_resposta[1] = 8'hFB;
        palavras_resposta[2] = 8'hFC;
        palavras_resposta[3] = 8'hFE;
    end

    // Sequência de teste
    initial begin
        #20 reset = 0; // Libera reset

        wait(done);    // Espera até que a transmissão seja concluída
        #20;

        // Mostra resultados no console
        $display("=== RESULTADOS RECEBIDOS ===");
        $display("Palavra 0 recebida: %02h", received_word0);
        $display("Palavra 1 recebida: %02h", received_word1);
        $display("Palavra 2 recebida: %02h", received_word2);
        $display("Palavra 3 recebida: %02h", received_word3);

        $display("Simulacao finalizada.");
        $finish; // Encerra simulação
    end

endmodule
