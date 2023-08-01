/*
    Author: Moaz Mohamed 
    Description: Verilog code describing an n-bit counter
*/

module Counter #(
    parameter N= 4
) (
    input wire counter_rst, counter_en, clk,
    output reg [N-1:0] count
);

/*Combinational output*/
reg [N-1:0]count_comb;

always @(*) begin
    if (counter_en)
    begin
        count_comb = count + 4'b0001;
    end
    else
    begin
        count_comb = count;
    end
end

/*Sequential output*/
always @(posedge clk or negedge counter_rst) begin
    if(!counter_rst)
    begin
        count<=4'b0000;
    end
    else
    begin
        count<=count_comb;
    end
end 
endmodule