module Reg_D (
    input clk,
    input rst,
    input [31:0] inst,
    input [31:0] current_pc,
    input stall,
    input jb,

    output reg [31:0] D_inst,
    output reg [31:0] D_current_pc
);

always@(posedge clk or posedge rst)
begin
    if(rst) //reset==0
    begin
        D_current_pc <= 32'd0;
        D_inst <= 32'd0;
    end
    else if(stall)  //output <= output
    begin
        D_current_pc <= D_current_pc;
        D_inst <= D_inst;
    end
    else if(jb==1)  //output <= nop
    begin
        D_current_pc <= 0;
        D_inst <= 32'b00000000000000000000000000010011;  //nop (addi x0, x0, 0);
    end
    else
    begin
        D_current_pc <= current_pc;
        D_inst <= inst;
    end
end

endmodule

