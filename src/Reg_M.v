module Reg_M (
    input clk,
    input rst,
    input [31:0] alu_out,
    input [31:0] rs2_data_out,
    
    output reg [31:0] M_alu_out,
    output reg [31:0] M_rs2_data_out
);

always@(posedge clk or posedge rst)
begin
    if(rst) //reset==0
    begin
        M_alu_out <= 32'd0;
        M_rs2_data_out <= 32'd0;
    end
    else 
    begin
        M_alu_out <= alu_out;
        M_rs2_data_out <= rs2_data_out;
    end
end

endmodule