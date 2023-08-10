/*
    Author: Moaz Moahamed 
    Description: SPI Top Module
*/
`include "SPI_Slave.v"
`include "Data_Memory.v"

module SPI (
    input wire MOSI,SS_n,clk,rst_n,
    output wire MISO
);

/*Intermediate Signals*/
wire [9:0]rx_data;
wire rx_valid;
wire [7:0]tx_data;
wire tx_valid;

/*Inner modules instances*/

/*Data memory instance*/
Data_Memory D1 (
    .clk(clk),
    .rst_n(rst_n),
    .rx_valid(rx_valid),
    .tx_valid(tx_valid),
    .dout(tx_data),
    .din(rx_data)
);

/*SPI Slave*/
SPI_Slave S1(
    .clk(clk),
    .rst_n(rst_n),
    .MOSI(MOSI),
    .MISO(MISO),
    .SS_n(SS_n),
    .rx_data(rx_data),
    .tx_data(tx_data),
    .rx_valid(rx_valid),
    .tx_valid(tx_valid)
);
    
endmodule