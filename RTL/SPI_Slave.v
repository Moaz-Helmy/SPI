/*
    Author: Moaz Mohamed 
    Description: Verilog code describing the logic of the SPI slave.
*/
`include "Counter.v"
`include "Data_Memory.v"
module SPI_Slave (
    input wire MOSI,SS_n,tx_valid, rst_n, clk,
    input wire [7:0] tx_data,
    output reg MISO,rx_valid,
    output reg [9:0] rx_data
);

/*System States*/
localparam IDLE = 3'b000,
           CHK_CMD = 3'b001,
           WRITE = 3'b010,
           READ_ADDR = 3'b011,
           READ_DATA = 3'b100;           

/*Temporary signals to store the combinational output for each signal*/
reg rx_valid_next;
reg [9:0] rx_data_next;

/*State Registers*/
reg [2:0]current_state,Next_state;

/*Reading and writing enable signals*/
reg wr_en, rd_en,send_en;

/*A flag to state whether the address has been read in the prev state or not*/
reg raddr_done,raddr_done_next;

/*A flag to state the data has been successfully received form the RAM*/
reg rdata_done,rdata_done_next;

/*Resgister to hold the data received from the RAM*/
reg [7:0] rdata_reg, rdata_next;

/*Shift registers used to receive the data the addresses, and the commands*/
reg [9:0] sh_reg;

/*Internal signals to control the counter & receive its output*/
reg counter_rst,counter_en;
wire [3:0] count;

/*Counter instance*/
Counter C1 (
    .clk(clk),
    .counter_rst(counter_rst),
    .counter_en(counter_en),
    .count(count)
);

/*Data memory instance*/
Data_Memory D1 (
    .clk(clk),
    .rst_n(rst_n),
    .rx_valid(rx_valid),
    .tx_valid(tx_valid),
    .dout(tx_data),
    .din(rx_data)
);

/***********************State Transition******************/
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
    begin
        current_state<= IDLE;
    end
    else
    begin
        current_state <= Next_state;
    end   
end

/******************Output Assignments*********************/
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)
    begin
        rx_data<='b0;
        rx_valid<='b0;
        raddr_done<='b0;
        rdata_done<='b0;
        rdata_reg<='b0;
    end
    else
    begin
        rx_data<=rx_data_next;
        rx_valid<=rx_valid_next;
        raddr_done<=raddr_done_next;
        rdata_done<=rdata_done_next;
        rdata_reg<=rdata_next;
    end
end

/***********************Next State Logic***************/
always @(*) begin
    Next_state = IDLE;
    raddr_done_next = raddr_done;

    case (current_state)
        IDLE:begin
            if(!SS_n)
            begin
                Next_state = CHK_CMD;    
            end
            else
            begin
                Next_state = IDLE;
            end
        end 
        CHK_CMD: begin
            if(SS_n)
            begin
                Next_state = IDLE;
            end
            else
            begin
                /*If MOSI == 1 && raddr_done == 1 --> The operation is READ and the memory has received the read address*/
                if(MOSI && raddr_done)
                begin
                    Next_state = READ_DATA;
                end
                /*If MOSI == 1 && raddr_done == 0 --> The operation is READ and the memory hasn't yet received the read address*/
                else if(MOSI && !raddr_done)
                begin
                    Next_state = READ_ADDR;
                end
                /*Else if MOSI == 0 --> The operation is WRITE*/
                else
                begin
                    Next_state = WRITE;
                end
            end
        end
        READ_ADDR:begin
            /*Set the read address flag to indicate that the memory has received the read address*/
            raddr_done_next = 'b1;

            if(SS_n)
            begin
                Next_state = IDLE;
            end
            else
            begin
                Next_state = READ_ADDR;
            end
        end
        READ_DATA:begin
            if(SS_n)
            begin
                Next_state = IDLE;
            end
            else
            begin
                Next_state = READ_DATA;
            end
        end
        WRITE:begin
            if(SS_n)
            begin
                Next_state = IDLE;
            end
            else
            begin
                Next_state = WRITE;
            end
        end
        default:begin
            /*Keep the values as is*/
            Next_state = IDLE;
            raddr_done_next = raddr_done;
        end
    endcase
end

/***********************Output Logic*********************/
always @(*) begin
    counter_rst=1'b1;
    counter_en=1'b1;
    MISO='b0;
    rx_valid=1'b0;
    rx_data='b0;
    wr_en=1'b0;
    rd_en=1'b0;
    raddr_done_next=raddr_done;
    send_en='b0;
    case (current_state)
        IDLE: begin
            /*Assign all output signals to be zero*/
            rx_data_next='b0;
            rx_valid_next='b0;

            /*Reset the counter and disable the count enable signal*/
            counter_rst='b0;
            counter_en='b0;
        end 
        CHK_CMD:begin
            /*Assign all output signals to be zero*/
            rx_data_next='b0;
            rx_valid_next='b0;
            
            /*Reset the counter and disable the count enable signal*/
            counter_rst='b0;
            counter_en='b0;
        end
        READ_ADDR:begin
            /*Check if the count has reached 10, .i.e, 10 cycles have passed*/
            if(count == 'd10)
            begin
                /*Cease receiving the data from MOSI port*/
                rd_en = 'b0;

                /*Send the data to the RAM*/
                rx_valid_next = 'b1;
                rx_data_next = sh_reg;

                /*Stop the counter, but don't reset because it's needed to retain its value*/
                counter_en='b0;
                counter_rst='b1;
            end
            else
            begin
                /*Enable the counter*/
                counter_rst = 'b1;
                counter_en = 'b1;

                /*Disable the rx_valid signal*/
                rx_data_next = 'b0;
                rx_data_next = rx_data;

                /*Keep receiving the data from the MOSI port*/
                rd_en = 'b1;
            end
        end
        READ_DATA: begin
            /*Poll on the tx_valid signal. When it's high, receive the data sent from memory*/
            if(tx_valid)
            begin
                /*Set the rdata flag*/
                rdata_done_next = 'b1;

                /*Hold in the received data*/
                rdata_next = tx_data;
            end
            else
            begin
                /*Keep the value stored in the received data register*/
                rdata_next = rdata_reg;

                if(rdata_done)
                begin
                    /*Enable the counter*/
                    counter_rst='b1;
                    counter_en='b1;

                    /*Wait 8 clock cycles so that all 8-bit data have been sent*/
                    if(count == 'd8)
                    begin
                        /*Stop the counter*/
                        counter_en='b0;

                        /*Reset the data flag*/
                        rdata_done_next = 'b0;

                        /*Stop sending the data*/
                        send_en='b0;
                    end
                    else
                    begin
                        /*Keep sending the data on the MISO port*/
                        send_en = 'b1;

                        /*Keep the data flag set*/
                        rdata_done_next = 'b1;

                        /*Keep the counter enabled*/
                        counter_en='b1;
                    end
                end
                else
                begin
                    /*Disable the counter*/
                    counter_en='b0;

                    /*Reset all flags*/
                    rdata_done_next='b0;
                    send_en='b0;
                end 
            end
        end
        WRITE:begin
            /*Check if the count has reached 10, .i.e, 10 cycles have passed*/
            if(count == 'd10)
            begin
                /*Cease receiving the data from MOSI port*/
                rd_en = 'b0;

                /*Send the data to the RAM*/
                rx_valid_next = 'b1;
                rx_data_next = sh_reg;

                /*Stop the counter, but don't reset because it's needed to retain its value*/
                counter_en='b0;
                counter_rst='b1;
            end
            else
            begin
                /*Enable the counter*/
                counter_rst = 'b1;
                counter_en = 'b1;

                /*Disable the rx_valid signal*/
                rx_data_next = 'b0;
                rx_data_next = rx_data;

                /*Keep receiving the data from the MOSI port*/
                rd_en = 'b1;
            end
        end
         
    endcase
end

/*************************Receiving Addresses Logic*****************************/
always @(posedge clk) begin
    if(rd_en)
    begin
        sh_reg <= {MOSI,sh_reg[9:1]};
    end
    else
    begin
        sh_reg <= sh_reg;
    end
end

/**************************Sending data on MISO Port Logic************************/
always @(posedge clk) begin
   if(send_en)
   begin
        MISO <= rdata_reg[count-1'b1];
   end
   else
   begin
        MISO<='b0;
   end
end
    
endmodule