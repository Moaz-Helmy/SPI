/*
    Author: Moaz Mohamed 
    Description: Verilog code describing an n-bit counter
*/

module Counter #(
    parameter N= 4
) (
    input wire reset, enable, clk,
    output reg [N-1:0] count,
    output reg tenth_flag
);

/*Combinational output*/
reg [N-1:0]count_comb;

always @(*) begin
    if(count == 4'b1010) begin
        count_comb = count;
        tenth_flag = 1'b1;
    end
    else if (enable)
    begin
        count_comb = count + 4'b0001;
        tenth_flag = 1'b0;
    end
    else
    begin
        count_comb = count;
    end
end

/*Sequential output*/
always @(posedge clk or negedge reset) begin
    if(!reset)
    begin
        count<=4'b0000;
    end
    else
    begin
        count<=count_comb;
    end
end 
endmodule