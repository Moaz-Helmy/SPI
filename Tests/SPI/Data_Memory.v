/*
    Author: Moaz Mohamed 
    Description: Verilog code describing a 2-single-port synchronous RAM.
*/

module Data_Memory #(parameter MEM_DEPTH = 256, DATA_SIZE = 8, ADDR_SIZE = 8)
(
    input wire [9:0] din,
    input wire rx_valid,
    input wire clk,
    input wire rst_n,
    output reg [7:0] dout,
    output reg tx_valid
);

/*Create the memory array*/
reg [DATA_SIZE - 1 : 0] RAM [0 : 2**ADDR_SIZE - 1];

/*Write enable signal that is used to write data in RAM*/
reg wr_en;

/*Define registers to hold the write address & read address*/
reg [7:0]write_add_reg, write_add_next, read_add_reg, read_add_next;

/*Define register to hold the data output from the RAM*/
reg [7:0] RAM_next;

/*Define memory index*/
integer index;

always @(posedge clk , negedge rst_n) begin
    if(!rst_n)
    begin
        for (index = 0 ; index< MEM_DEPTH; index=index+1 ) begin
            RAM[index]<=8'b0000_0000;
        end
        write_add_reg <= 8'b0000_0000;
        read_add_reg <= 8'b0000_0000;
    end
    else
    begin
        if(wr_en)
        begin
            RAM[write_add_reg]<= RAM_next;
        end
        write_add_reg <= write_add_next;
        read_add_reg <= read_add_next;
    end
end   

/*Next State & Output logic*/
always @(*) begin
    write_add_next = write_add_reg;
    read_add_next = read_add_reg;
    wr_en = 1'b0;
    RAM_next = 'b0;
    tx_valid = 1'b0;
    case (din[9:8])
            2'b00: begin //save write address
                if(rx_valid)
                begin
                    write_add_next = din[7:0];
                end
                else
                begin
                    write_add_next = write_add_reg;
                end
            end
            2'b01: begin //write data into the saved write address
                if(rx_valid)
                begin
                    RAM_next = din[7:0];
                    wr_en = 1'b1;
                end
                else
                begin
                    wr_en = 1'b0;
                    RAM_next = 'b0;
                end
            end
            2'b10: begin //save read address
                if (rx_valid)
                begin
                    read_add_next = din[7:0];
                end
                else
                begin
                    read_add_next = read_add_reg; 
                end
            end
            2'b11: begin //read from the saved read address
                    tx_valid = 1'b1;
            end
            default: begin
                write_add_next = write_add_reg;
                read_add_next = read_add_reg;
                wr_en = 1'b0;
                RAM_next = 'b0;
                tx_valid = 1'b0;
            end
        endcase
end

/*Assign the output bus to hold the data stored at the read address all the time*/
always @(*) begin
    dout = RAM[read_add_reg];
end
endmodule