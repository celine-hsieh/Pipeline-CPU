module Mux2 (
    input [31:0] reg_rs1_data_out,
    input [31:0] reg_rs2_data_out,
    input [31:0] wb_data,

    input D_rs1_data_sel,
    input D_rs2_data_sel,
    
    output [31:0] mux2_rs1_data_out,
    output [31:0] mux2_rs2_data_out
);

assign mux2_rs1_data_out = (D_rs1_data_sel) ? wb_data : reg_rs1_data_out;
assign mux2_rs2_data_out = (D_rs2_data_sel) ? wb_data : reg_rs2_data_out;

endmodule