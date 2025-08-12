# Controlador SPI com spi_master.sv

Este projeto implementa um módulo controlador de comunicação SPI, responsável por realizar a transferência de dados utilizando o módulo `spi_master.sv`.  
O controlador envia 4 palavras predefinidas e armazena as palavras recebidas do dispositivo escravo.

## Requisitos
- Quantidade de palavras a serem transferidas: **4** (entrada: `data_words`)
- Condição do sinal seletor de escravo **SS** ativo entre transferências (entrada: `tied_SS`)
- Palavras enviadas: `0xFA`, `0xFB`, `0xFC`, `0xFE`

## 🛠️ Testbench
O funcionamento foi validado através de um módulo *testbench*, que simulou a comunicação SPI e exibiu as palavras recebidas no terminal.

## 📝 Resultado da simulação (terminal)
```

\=== RESULTADOS RECEBIDOS ===
Palavra 0 recebida: fa
Palavra 1 recebida: fb
Palavra 2 recebida: fc
Palavra 3 recebida: fe
Simulação finalizada.

```

## 📂 Estrutura
- `spi_master.sv` → Módulo mestre SPI
- `spi_controller.sv` → Módulo controlador
- `tb_spi_controller.sv` → Testbench

## 📜 Licença
Este projeto é de uso educacional no contexto de desenvolvimento com FPGA.
