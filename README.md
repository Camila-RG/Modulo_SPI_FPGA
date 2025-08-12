# Controlador SPI com spi_master.sv

Este projeto implementa um módulo controlador para comunicação SPI, utilizando o módulo auxiliar `spi_master.sv` para realizar a transferência de dados.

## 📌 Objetivo

* Transmitir **4 palavras** de dados (`data_words`) para um dispositivo escravo.
* Manter o sinal `SS` ativo entre cada transferência (`tied_SS`).
* Testar o funcionamento com um *testbench*.

## 🔧 Detalhes da implementação

* Palavras transmitidas: **8hFA, 8hFB, 8hFC, 8hFE**
* Palavras recebidas: armazenadas para análise.
* Protocolo utilizado: **SPI**.

## 🖥️ Teste e simulação

A simulação foi realizada utilizando **o terminal e o GTKWave** para inspecionar as formas de onda e validar a comunicação.

## 📂 Estrutura do projeto

```
├── spi_master.sv
├── spi_controller.sv
├── tb_spi_controller.sv
```

## 📜 Licença

Projeto desenvolvido para fins acadêmicos. Uso livre para estudo.
