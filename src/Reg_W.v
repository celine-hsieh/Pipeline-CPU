module Reg_W (
    input clk,
    input rst,
    input [31:0] M_alu_out,
    input [31:0] ld_data,
    
    output reg [31:0] W_alu_out,
    output reg [31:0] W_ld_data
);

always@(posedge clk or posedge rst)
begin
    if(rst) //reset==0
    begin
        W_alu_out <= 32'd0;
        W_ld_data <= 32'd0;
    end
    else 
    begin
        W_alu_out <= M_alu_out;
        W_ld_data <= ld_data;
    end
end

endmodule