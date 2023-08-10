`timescale 1ns/1ps


module  SPI_tb();

/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////

parameter Clock_PERIOD = 10;
parameter Test_Cases = 5;

/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////

reg rst_n_tb;
reg clk_tb;
reg MOSI_tb;
reg SS_n_tb;
wire MISO_tb;

/////////////////////////////////////////////////////////
//////////////////////// Variables //////////////////////
/////////////////////////////////////////////////////////

integer index;

/////////////////////////////////////////////////////////
/////////////////////// Memories ////////////////////////
/////////////////////////////////////////////////////////

reg [12:0] Test [0:3];
reg [12:0] Data_sent;
reg [7:0] Data_received;

////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////

initial 
 begin
 
 // System Functions
 $dumpfile("SPI.vcd") ;       
 $dumpvars; 
 
 //Read input File
 $readmemb("Input.txt",Test);

 // initialization
 initialize();
 
 // Test Cases
 Reset();

 for(index=0 ; index<4; index=index+1)
 begin
    Data_sent=Test[index];
    Send(Data_sent);
 end
 #(Clock_PERIOD*9)
 SS_n_tb=1'b1;
 #100
 $stop;

 end

////////////////////////////////////////////////////////
/////////////////////// TASKS //////////////////////////
////////////////////////////////////////////////////////

/////////////// Signals Initialization //////////////////

task initialize ;
 begin
   clk_tb='b0;
   rst_n_tb='b1;
   MOSI_tb='b0;
   SS_n_tb='b1;
 end
endtask

///////////////////////// RESET /////////////////////////

task Reset;
begin
    @(negedge clk_tb) 
    rst_n_tb='b0;
    #(Clock_PERIOD)
    rst_n_tb='b1;
end
endtask

////////////////// Test Operations ////////////////////

task Send;
input [12:0] Data;
begin
    #(Clock_PERIOD)
    SS_n_tb = Data[0];
    for(index=1; index<12;index=index+1)
    begin
        #(Clock_PERIOD)
        MOSI_tb = Data[index];
    end
    #(Clock_PERIOD)
    SS_n_tb=Data[12];
end
endtask

////////////////// Check Out Response  ////////////////////


////////////////////////////////////////////////////////
////////////////// Clock Generator  ////////////////////
////////////////////////////////////////////////////////

always #(Clock_PERIOD/2) clk_tb=~clk_tb;

////////////////////////////////////////////////////////
/////////////////// DUT Instantation ///////////////////
////////////////////////////////////////////////////////

SPI S1 (
    .clk(clk_tb),
    .rst_n(rst_n_tb),
    .MOSI(MOSI_tb),
    .MISO(MISO_tb),
    .SS_n(SS_n_tb)
);
endmodule