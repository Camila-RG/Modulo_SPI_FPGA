module spi_controller #(
    parameter DATA_BITS = 8
)(
    input wire clk,
    input wire reset,
    input wire tied_SS,

    input wire [DATA_BITS-1:0] palavra0,
    input wire [DATA_BITS-1:0] palavra1,
    input wire [DATA_BITS-1:0] palavra2,
    input wire [DATA_BITS-1:0] palavra3,

    output reg done,

    output wire SCK,
    output wire SS,
    output wire MOSI,
    input wire MISO,

    output reg [DATA_BITS-1:0] received_word0,
    output reg [DATA_BITS-1:0] received_word1,
    output reg [DATA_BITS-1:0] received_word2,
    output reg [DATA_BITS-1:0] received_word3
);

    localparam DATA_WORDS = 4;

    reg spi_en;
    reg [DATA_BITS-1:0] data_in;
    wire ready_out, valid_out;
    wire [DATA_BITS-1:0] data_out;

    reg [$clog2(DATA_WORDS)-1:0] word_index;
    reg [DATA_BITS-1:0] received_words [0:DATA_WORDS-1];

    reg [5:0] data_words_reg = 6'd4;

    reg [DATA_BITS-1:0] palavras_envio [0:DATA_WORDS-1];

    // Copia as entradas individuais para array interno
    always @(*) begin
        palavras_envio[0] = palavra0;
        palavras_envio[1] = palavra1;
        palavras_envio[2] = palavra2;
        palavras_envio[3] = palavra3;
    end

    spi_master #(
        .DATA_BITS(DATA_BITS),
        .CPOL(0),
        .CPHA(1),
        .BRDV(2),
        .LSBF(0)
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

    typedef enum logic [1:0] {
        IDLE,
        SEND,
        WAIT_VALID,
        DONE
    } state_t;

    state_t state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            word_index <= 0;
            spi_en <= 0;
            data_in <= 0;
            done <= 0;

            received_word0 <= 0;
            received_word1 <= 0;
            received_word2 <= 0;
            received_word3 <= 0;
        end else begin
            state <= next_state;

            if (state == IDLE) begin
                word_index <= 0;
                spi_en <= 1;
                data_in <= palavras_envio[0];
                done <= 0;
            end else if (state == WAIT_VALID) begin
                if (valid_out) begin
                    received_words[word_index] <= data_out;
                    if (word_index < DATA_WORDS - 1) begin
                        word_index <= word_index + 1;
                        data_in <= palavras_envio[word_index + 1];
                        spi_en <= 1;
                    end else begin
                        spi_en <= 0;
                    end
                end
            end else if (state == DONE) begin
                done <= 1;
                spi_en <= 0;
            end

            // Atualiza as saídas individuais
            received_word0 <= received_words[0];
            received_word1 <= received_words[1];
            received_word2 <= received_words[2];
            received_word3 <= received_words[3];
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (spi_en) next_state = SEND;
            SEND: if (ready_out) next_state = WAIT_VALID;
            WAIT_VALID: if (valid_out) begin
                if (word_index == DATA_WORDS - 1)
                    next_state = DONE;
                else
                    next_state = SEND;
            end
            DONE: ;
        endcase
    end

endmodule
