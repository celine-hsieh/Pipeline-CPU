module Reg_PC (
    input clk,
    input rst,
    input [31:0] next_pc,
    input stall,
    output reg [31:0] current_pc
);

always@(posedge clk or posedge rst)
begin
    if(rst) //reset==0
    begin
        current_pc <= 32'd0;

    end
    else if(stall)
        current_pc <= current_pc;
    else
        current_pc <= next_pc;
end

endmodule