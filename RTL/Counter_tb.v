`timescale 1ns/100ps
module Counter_tb ();
    
    /*Test Signals*/
    reg counter_rst_tb,counter_en_tb,clk_tb;
    wire [3:0]count_tb;
    wire tenth_flag_tb;
    /*clock generator*/
    always #5 clk_tb=~clk_tb;

    /*Initial Block*/
    initial begin
        counter_rst_tb=1'b1;
        counter_en_tb=1'b0;
        clk_tb=1'b0;

        /*1)counter_rst*/
        #10
        counter_rst_tb=1'b0;

        #10
        if(count_tb==0)
            $display("counter_rst passed");
        else
            $display("counter_rst Failed");
        counter_rst_tb=1'b1;

        /*2) counter_en*/
        #10
            if(count_tb==0)
            $display("counter waiting for counter_en passed");
        else
            $display("counter waiting for eanble Failed");
        counter_en_tb=1'b1;
        #10
        if(count_tb==1'b0001)
            $display("counter waiting for counter_en passed");
        else
            $display("counter waiting for eanble Failed");

        /*3) Tenth flag*/
        #90
        if(count_tb == 4'b1010 && tenth_flag_tb==1)
            $display("Flag passed");
        else
            $display("Flag failed");

        $stop;
    end

Counter DUT(
    .counter_rst(counter_rst_tb),
    .clk(clk_tb),
    .counter_en(counter_en_tb),
    .count(count_tb),
    .tenth_flag(tenth_flag_tb)
);
endmodule