/*
    Author: Moaz Mohamed 
    Description: Verilog code describing a 2-single-port synchronous RAM.
*/

module RAM_2Port #(parameter MEM_DEPTH = 256, DATA_SIZE = 8, ADDR_SIZE = 8)
(
    input wire [9:0] din,
    input wire rx_valid,
    input wire clk,
    input wire rst_n,
    output reg [7:0] dout,
    output wire tx_valid
);

/*Create the memory array*/
reg [DATA_SIZE - 1 : 0] RAM [0 : 2**ADDR_SIZE - 1];

/*Define registers to hold the write address & read address*/
reg [7:0]write_add, read_add;

/*Define memory index*/
integer index;

always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
    begin
        for (index = 0 ; index< MEM_DEPTH; index=index+1 ) begin
            RAM[index]<=8'b0000_0000;
        end
        write_add <= 8'b0000_0000;
        read_add <= 8'b0000_0000;
    end
    else
    begin
        case (din[9:8])
            2'b00: if(rx_valid)begin
                write_add <= din[7:0];
            end
            2'b01: RAM[write_add] <= din[7:0];
            2'b10: if (rx_valid) begin
                read_add <= din[7:0];
            end
            2'b11: begin
                if (tx_valid) begin
                    dout <= RAM[read_add];
                end
            end
        endcase
    end
end

/*Assign tx_valid to be high whenever the command is read,.i.e, din[9] = 1*/
assign tx_valid = din[9];
    
endmodule