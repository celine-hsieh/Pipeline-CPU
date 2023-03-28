module Imm_Ext (
    input [31:0] inst,
    output reg [31:0] imm_ext_out
);

always @(*)

    case(inst[6:2])
        5'b00000: /*I-type load*/
            imm_ext_out = {{20{inst[31]}}, inst[31:20]};
        5'b00100: /*I-type addi*/
            begin 
            if((inst[14:12]==3'b101)||(inst[14:12]==3'b001))
                imm_ext_out = {{27{inst[24]}}, inst[24:20]};
            else
                imm_ext_out = {{20{inst[31]}}, inst[31:20]};
            end
        5'b01000: /*S-type*/ 
            imm_ext_out = {{20{inst[31]}}, inst[31:25], inst[11:7]};
        5'b11000: /*B-type*/  //inst_code[31]? 20'b1:20'b0
            imm_ext_out = {{20{inst[31]}}, inst[7], inst[30:25],inst[11:8], 1'b0};
        5'b11001: /*I-type jalr*/
            imm_ext_out = {{20{inst[31]}}, inst[31:20]};
        5'b00101: /*U-type auipc*/
            imm_ext_out = {inst[31:12], 12'b0};
        5'b01101: /*U-type lui*/
            imm_ext_out = {inst[31:12], 12'b0};
        5'b01101: /*AUIPC-type*/
            imm_ext_out = {inst[31:12], 12'b0};
        5'b11011: /*J-type jal*/ 
            imm_ext_out = {{20{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
        default: 
            imm_ext_out = inst;
    endcase
endmodule