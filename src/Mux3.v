module Mux3 (
    input [31:0] E_rs1_data_out,
    input [31:0] E_rs2_data_out,

    input [31:0] alu_out,
    input [31:0] wb_data,

    input [1:0] E_rs1_data_sel,
    input [1:0] E_rs2_data_sel,

    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out

);

    always @(*) 
    begin
        case (E_rs1_data_sel)
            2'b00 : rs1_data_out = wb_data;
            2'b01 : rs1_data_out = alu_out;
            2'b10 : rs1_data_out = E_rs1_data_out;
            2'b11 : rs1_data_out = 32'b0;
            default : rs1_data_out = 32'b0;
        endcase

        case (E_rs2_data_sel)
            2'b00 : rs2_data_out = wb_data;
            2'b01 : rs2_data_out = alu_out;
            2'b10 : rs2_data_out = E_rs2_data_out;
            2'b11 : rs2_data_out = 32'b0;
            default : rs2_data_out = 32'b0;
        endcase
    end 

endmodule