`timescale 1ns/100ps
module Counter_tb ();
    
    /*Test Signals*/
    reg reset_tb,enable_tb,clk_tb;
    wire [3:0]count_tb;
    wire tenth_flag_tb;
    /*clock generator*/
    always #5 clk_tb=~clk_tb;

    /*Initial Block*/
    initial begin
        reset_tb=1'b1;
        enable_tb=1'b0;
        clk_tb=1'b0;

        /*1)Reset*/
        #10
        reset_tb=1'b0;

        #10
        if(count_tb==0)
            $display("Reset passed");
        else
            $display("Reset Failed");
        reset_tb=1'b1;

        /*2) enable*/
        #10
            if(count_tb==0)
            $display("counter waiting for enable passed");
        else
            $display("counter waiting for eanble Failed");
        enable_tb=1'b1;
        #10
        if(count_tb==1'b0001)
            $display("counter waiting for enable passed");
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
    .reset(reset_tb),
    .clk(clk_tb),
    .enable(enable_tb),
    .count(count_tb),
    .tenth_flag(tenth_flag_tb)
);
endmodule