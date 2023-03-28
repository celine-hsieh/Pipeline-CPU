module Reg_E (
    input clk,
    input rst,
    input [31:0] mux2_rs1_data_out,
    input [31:0] mux2_rs2_data_out,
    input [31:0] imm_ext_out,
    input [31:0] D_current_pc,
    input stall,
    input jb,
    
    output reg [31:0] E_rs1_data_out,
    output reg [31:0] E_rs2_data_out,
    output reg [31:0] E_current_pc,
    output reg [31:0] E_imm_ext_out
);


always@(posedge clk or posedge rst)
begin
    if(rst) //reset==0
    begin
        E_current_pc <= 32'd0;
        E_rs1_data_out <= 32'd0;
        E_rs2_data_out <= 32'd0;
        E_imm_ext_out <= 32'd0;
    end
    else if (stall==1 || jb==1)
    begin
        E_current_pc <= 0;
        E_rs1_data_out <= 32'd0;
        E_rs2_data_out <= 32'd0;
        E_imm_ext_out <= 32'd0;
    end
    else
    begin
        E_current_pc <= D_current_pc;
        E_rs1_data_out <= mux2_rs1_data_out;
        E_rs2_data_out <= mux2_rs2_data_out;
        E_imm_ext_out <= imm_ext_out;
         
    end
end

endmodule