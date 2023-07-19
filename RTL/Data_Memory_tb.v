/*
    Author: Moaz Mohamed 
    Description: Testbench for the 2-single-port synchronous RAM.
*/

`timescale 1ns/100ps

module RAM_2Port_tb ();

reg [9:0] din_tb;
reg rx_valid_tb;
reg clk_tb;
reg rst_n_tb;
wire [7:0] dout_tb;
wire tx_valid_tb;

/*
    Test cases to be covered:
    1) Memory initialized to zero after reset
    2) write address is saved when din[9:8] = 2'b00 & rx_valid is high.
    3) din[7:0] is written in the specified write address, but in the next clock cycle.
    4) If tx_valid is high --> read operation.
    5) During read operation, if din[8] == 0 --> Keep the read address = din[7:0].
    6) When din[8] == 1 --> output data stored at the read address location in memory on the dout bus. But in the next clk cycle.
*/

/*Module instance*/
RAM_2Port DUT (
    .din(din_tb),
    .rx_valid(rx_valid_tb),
    .clk(clk_tb),
    .rst_n(rst_n_tb),
    .dout(dout_tb),
    .tx_valid(tx_valid_tb)
);

/*Clock Generation with 10ns period*/
always #5 clk_tb=~clk_tb;

/*Initial block*/
initial begin
    $dumpfile("Data_mem.vcd");
    $dumpvars;

    /*Initial values*/
    clk_tb=1'b0;
    rx_valid_tb=1'b0;
    rst_n_tb=1'b1;
    din_tb=10'b00_0000_1010;

    /*Test case 1: Reset*/
    #10
    $display("Test Case 1: Reset");
    rst_n_tb=1'b0;
    #5
    rst_n_tb=1'b1;

    /*Test case 2: save write address after setting rx_valid to high*/
    $display("Test Case 2: Save write address");
    #5
    rx_valid_tb=1'b1;
    #10

    /*Test case 3: write data in specified memory location*/
    rx_valid_tb=1'b0;
    din_tb=10'b01_0000_1011;
    #10

    /*Test case 4: save read address if rx_valid and tx-valid are set*/
    rx_valid_tb=1'b1;
    din_tb=10'b10_0000_1010;
    #10
    rx_valid_tb=1'b0;
    din_tb[9:8]=2'b11;
    #10
    $stop;

end
endmodule