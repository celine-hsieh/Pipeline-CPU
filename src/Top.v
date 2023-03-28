`include "./src/Adder.v"
`include "./src/ALU.v"
`include "./src/Controller.v"
`include "./src/Decoder.v"
`include "./src/Imme_Ext.v"
`include "./src/JB_Unit.v"
`include "./src/LD_Filter.v"
`include "./src/Mux.v"
`include "./src/Mux2.v"
`include "./src/Mux3.v"
`include "./src/Reg_PC.v"
`include "./src/Reg_D.v"
`include "./src/Reg_E.v"
`include "./src/Reg_M.v"
`include "./src/Reg_W.v"
`include "./src/RegFile.v"
`include "./src/SRAM.v"


module Top (
    input clk,
    input rst
);

//ALU Wires
wire [31:0]alu_operand1, alu_operand2;
wire [31:0]alu_out;

//Controller Wires
wire [4:0]E_opcode;
wire [2:0]E_func3, W_f3;
wire E_func7; 
wire next_pc_sel, W_wb_en, E_alu_op1_sel, E_alu_op2_sel, E_jb_op1_sel, W_wb_data_sel;
wire [3:0]F_im_w_en, M_dm_w_en;
wire D_rs1_data_sel, D_rs2_data_sel;
wire [1:0]E_rs1_data_sel, E_rs2_data_sel;
wire stall;
wire [4:0] W_rd;

//Decoder Wires
wire [31:0]inst;
wire [4:0]dc_out_opcode, dc_out_rs1_index, dc_out_rs2_index, dc_out_rd_index;
wire [2:0]dc_out_func3;
wire dc_out_func7;

//Imm_Ext Wires
wire [31:0]imm_ext_out;

//JB_Unit Wires
wire [31:0]jb_operand1, jb_out;

//LD_Filter Wires
wire [31:0]ld_data, ld_data_f;

//Reg_D Wires
wire [31:0] D_inst;
wire [31:0] D_current_pc;

//Reg_E Wires
wire [31:0] E_rs1_data_out;
wire [31:0] E_rs2_data_out;
wire [31:0] E_current_pc;
wire [31:0] E_imm_ext_out;

//Reg_M Wires
wire [31:0] M_alu_out;
wire [31:0] M_rs2_data_out;

//Reg_W Wires
wire [31:0] W_alu_out;
wire [31:0] W_ld_data;

//Mux Wires
wire [31:0]rs1_data_out, rs2_data_out, wb_data;
wire jb;

//Mux2 Wires
wire [31:0]reg_rs1_data_out, reg_rs2_data_out, mux2_rs1_data_out, mux2_rs2_data_out;

//Reg_PC Wires
wire [31:0]next_pc, current_pc;

//Adder Wires
wire [31:0]PCPlus4;


Adder adder(
    .PC(current_pc),
    .PCPlus4(PCPlus4)
);

ALU alu(
    .opcode(E_opcode),
    .func3(E_func3),
    .func7(E_func7),
    .operand1(alu_operand1),
    .operand2(alu_operand2),
    .alu_out(alu_out)
);

Controller controller(
    .clk(clk),
    .rst(rst),
    .opcode(dc_out_opcode),
    .func3(dc_out_func3),
    .func7(dc_out_func7),
    .rs1(dc_out_rs1_index),
    .rs2(dc_out_rs2_index),
    .rd(dc_out_rd_index),
    .alu_out(alu_out),
    .next_pc_sel(next_pc_sel),
    .stall(stall),
    .F_im_w_en(F_im_w_en),
    .W_wb_en(W_wb_en),
    .W_rd(W_rd),
    .E_alu_op1_sel(E_alu_op1_sel),
    .E_alu_op2_sel(E_alu_op2_sel),
    .E_jb_op1_sel(E_jb_op1_sel),
    .D_rs1_data_sel(D_rs1_data_sel),
    .D_rs2_data_sel(D_rs2_data_sel),
    .E_rs1_data_sel(E_rs1_data_sel),
    .E_rs2_data_sel(E_rs2_data_sel),
    .E_opcode(E_opcode),
    .E_func3(E_func3),
    .E_func7(E_func7),
    .M_dm_w_en(M_dm_w_en),
    .W_wb_data_sel(W_wb_data_sel),
    .W_f3(W_f3)
);

Decoder decoder(
    .inst(D_inst),
    .dc_out_opcode(dc_out_opcode),
    .dc_out_func3(dc_out_func3),
    .dc_out_func7(dc_out_func7),
    .dc_out_rs1_index(dc_out_rs1_index),
    .dc_out_rs2_index(dc_out_rs2_index),
    .dc_out_rd_index(dc_out_rd_index)
);

Imm_Ext imm_ext(
    .inst(D_inst),
    .imm_ext_out(imm_ext_out)
);

JB_Unit jb_unit(
    .operand1(jb_operand1),
    .operand2(E_imm_ext_out),
    .jb_out(jb_out)
);

LD_Filter ld_filter(
    .func3(W_f3),
    .ld_data(W_ld_data),
    .ld_data_f(ld_data_f)
);

Mux mux(
    .rs1_data_out(rs1_data_out),
    .PC(E_current_pc),
    .E_alu_op1_sel(E_alu_op1_sel),
    .E_jb_op1_sel(E_jb_op1_sel),
    .rs2_data_out(rs2_data_out),
    .imm_ext_out(E_imm_ext_out),
    .E_alu_op2_sel(E_alu_op2_sel),
    .ld_data_f(ld_data_f),
    .alu_out(W_alu_out),
    .W_wb_data_sel(W_wb_data_sel),
    .PCPlus4(PCPlus4),
    .jb_out(jb_out),
    .next_pc_sel(next_pc_sel),
    .alu_operand1(alu_operand1),
    .alu_operand2(alu_operand2),
    .jb_operand1(jb_operand1),
    .wb_data(wb_data),
    .next_pc(next_pc),
    .jb(jb)
);

Mux2 mux2(
    .reg_rs1_data_out(reg_rs1_data_out),
    .reg_rs2_data_out(reg_rs2_data_out),
    .mux2_rs1_data_out(mux2_rs1_data_out),
    .mux2_rs2_data_out(mux2_rs2_data_out),
    .D_rs1_data_sel(D_rs1_data_sel),
    .D_rs2_data_sel(D_rs2_data_sel),
    .wb_data(wb_data)
);

Mux3 mux3(
    .E_rs1_data_out(E_rs1_data_out),
    .E_rs2_data_out(E_rs2_data_out),
    .wb_data(wb_data),
    .alu_out(M_alu_out),
    .E_rs1_data_sel(E_rs1_data_sel),
    .E_rs2_data_sel(E_rs2_data_sel),
    .rs1_data_out(rs1_data_out),
    .rs2_data_out(rs2_data_out)
);

Reg_PC reg_pc(
    .clk(clk),
    .rst(rst),
    .next_pc(next_pc),
    .stall(stall),
    .current_pc(current_pc)
);

Reg_D reg_d(
    .clk(clk),
    .rst(rst),
    .inst(inst),
    .current_pc(current_pc),
    .stall(stall),
    .jb(jb),
    .D_inst(D_inst),
    .D_current_pc(D_current_pc)
);

Reg_E reg_e(
    .clk(clk),
    .rst(rst),
    .mux2_rs1_data_out(mux2_rs1_data_out),
    .mux2_rs2_data_out(mux2_rs2_data_out),
    .imm_ext_out(imm_ext_out),
    .D_current_pc(D_current_pc),
    .stall(stall),
    .jb(jb),
    .E_rs1_data_out(E_rs1_data_out),
    .E_rs2_data_out(E_rs2_data_out),
    .E_current_pc(E_current_pc),
    .E_imm_ext_out(E_imm_ext_out)
);

Reg_M reg_m(
    .clk(clk),
    .rst(rst),
    .alu_out(alu_out),
    .rs2_data_out(rs2_data_out),
    .M_alu_out(M_alu_out),
    .M_rs2_data_out(M_rs2_data_out)
);

Reg_W reg_w(
    .clk(clk),
    .rst(rst),
    .M_alu_out(M_alu_out),
    .ld_data(ld_data),
    .W_alu_out(W_alu_out),
    .W_ld_data(W_ld_data)
);


RegFile regfile(
    .clk(clk),
    .W_wb_en(W_wb_en),
    .wb_data(wb_data),
    .rd_index(W_rd),
    .rs1_index(dc_out_rs1_index),
    .rs2_index(dc_out_rs2_index),
    .rs1_data_out(reg_rs1_data_out),
    .rs2_data_out(reg_rs2_data_out)
);

SRAM im (
    .clk(clk),
    .w_en(F_im_w_en),
    .address(current_pc[15:0]),
    .write_data(rs2_data_out),
    .read_data(inst)
);

SRAM dm (
    .clk(clk),
    .w_en(M_dm_w_en),
    .address(M_alu_out[15:0]),
    .write_data(M_rs2_data_out),
    .read_data(ld_data)
);

endmodule