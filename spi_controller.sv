// Módulo de controle SPI para envio e recebimento de 4 palavras de dados
module spi_controller #(
    parameter DATA_BITS = 8 // Largura de cada palavra
)(
    // Entradas de controle
    input wire clk,        
    input wire reset,       
    input wire tied_SS,     

    // Palavras a serem enviadas
    input wire [DATA_BITS-1:0] palavra0,
    input wire [DATA_BITS-1:0] palavra1,
    input wire [DATA_BITS-1:0] palavra2,
    input wire [DATA_BITS-1:0] palavra3,

    // Sinal de finalização
    output reg done,       

    // Interface SPI
    output wire SCK,       
    output wire SS,       
    output wire MOSI,       
    input  wire MISO,      

    // Palavras recebidas do escravo
    output reg [DATA_BITS-1:0] received_word0,
    output reg [DATA_BITS-1:0] received_word1,
    output reg [DATA_BITS-1:0] received_word2,
    output reg [DATA_BITS-1:0] received_word3
);

    // Quantidade de palavras a serem enviadas
    localparam DATA_WORDS = 4;

    // Sinais de controle internos
    reg spi_en;                         // Habilita operação do SPI Master
    reg [DATA_BITS-1:0] data_in;         // Palavra atual a ser enviada ao SPI
    wire ready_out;                      // Indica que o SPI Master está pronto para enviar
    wire valid_out;                      // Indica que dados recebidos são válidos
    wire [DATA_BITS-1:0] data_out;       // Palavra recebida do escravo

    // Índice da palavra atual sendo enviada
    reg [$clog2(DATA_WORDS)-1:0] word_index;

    // Array para armazenar as palavras recebidas
    reg [DATA_BITS-1:0] received_words [0:DATA_WORDS-1];

    // Número de palavras que o SPI vai transmitir
    reg [5:0] data_words_reg = 6'd4;

    // Array para armazenar as palavras de envio
    reg [DATA_BITS-1:0] palavras_envio [0:DATA_WORDS-1];

    // Copia entradas individuais para o array interno
    always @(*) begin
        palavras_envio[0] = palavra0;
        palavras_envio[1] = palavra1;
        palavras_envio[2] = palavra2;
        palavras_envio[3] = palavra3;
    end

    // Instancia o módulo SPI Master
    spi_master #(
        .DATA_BITS(DATA_BITS),
        .CPOL(0),   // Clock ocioso em nível baixo
        .CPHA(1),   // Dados amostrados na borda de subida
        .BRDV(2),   // Divisor de clock para SPI
        .LSBF(0)    // MSB primeiro
    ) master_inst (
        .clk(clk),
        .n_rst(~reset),         
        .spi_en(spi_en),        
        .tied_SS(tied_SS),      
        .MISO(MISO),            
        .data_in(data_in),      
        .data_words(data_words_reg), 
        .SCK(SCK),             
        .SS(SS),                
        .MOSI(MOSI),            
        .ready_out(ready_out),  
        .valid_out(valid_out),  
        .data_out(data_out)     
    );

    // Máquina de estados para controlar o envio das palavras
    typedef enum logic [1:0] {
        IDLE,       
        SEND,       
        WAIT_VALID, 
        DONE       
    } state_t;

    state_t state, next_state;

    // Lógica sequencial (transições de estado e ações por clock)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset geral
            state <= IDLE;
            word_index <= 0;
            spi_en <= 0;
            data_in <= 0;
            done <= 0;

            // Zera palavras recebidas
            received_word0 <= 0;
            received_word1 <= 0;
            received_word2 <= 0;
            received_word3 <= 0;
        end else begin
            state <= next_state; // Atualiza estado

            if (state == IDLE) begin
                // Prepara envio da primeira palavra
                word_index <= 0;
                spi_en <= 1;
                data_in <= palavras_envio[0];
                done <= 0;

            end else if (state == WAIT_VALID) begin
                // Quando dados recebidos estão válidos
                if (valid_out) begin
                    // Armazena palavra recebida
                    received_words[word_index] <= data_out;
                    if (word_index < DATA_WORDS - 1) begin
                        // Avança para próxima palavra
                        word_index <= word_index + 1;
                        data_in <= palavras_envio[word_index + 1];
                        spi_en <= 1;
                    end else begin
                        // Todas as palavras enviadas
                        spi_en <= 0;
                    end
                end

            end else if (state == DONE) begin
                // Finaliza operação
                done <= 1;
                spi_en <= 0;
            end

            // Atualiza as saídas individuais com os dados armazenados
            received_word0 <= received_words[0];
            received_word1 <= received_words[1];
            received_word2 <= received_words[2];
            received_word3 <= received_words[3];
        end
    end

    // Lógica combinacional para definir próximo estado
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: 
                if (spi_en) next_state = SEND;
            SEND: 
                if (ready_out) next_state = WAIT_VALID;
            WAIT_VALID: 
                if (valid_out) begin
                    if (word_index == DATA_WORDS - 1)
                        next_state = DONE;
                    else
                        next_state = SEND;
                end
            DONE: ; // Fica parado
        endcase
    end

endmodule
