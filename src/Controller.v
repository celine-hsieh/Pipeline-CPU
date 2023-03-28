module Controller(
        input clk,
        input rst,

        input [4:0] opcode,
        input [2:0] func3,
        input func7,
        input [4:0] rs1,
        input [4:0] rs2,
        input [4:0] rd,
        input [31:0] alu_out,


        //pc control 
        output reg next_pc_sel,
        output reg stall,
        
        //instruction mem control
        output [3:0]F_im_w_en,
        
        //reg control
        output reg W_wb_en,
        output reg [4:0] W_rd,

        //mux control
        output reg E_alu_op1_sel,
        output reg E_alu_op2_sel,
        output reg E_jb_op1_sel, 

        //mux2 control
        output reg [1:0] D_rs1_data_sel,
        output reg [1:0] D_rs2_data_sel,

        //mux3 control
        output reg [1:0] E_rs1_data_sel,
        output reg [1:0] E_rs2_data_sel,

        //alu control
        output reg [4:0] E_opcode,
        output reg [2:0] E_func3,
        output reg E_func7, 
        
        // data mem control
        output reg [3:0]M_dm_w_en,
        
        //wb control 
        output reg W_wb_data_sel,

        //LD_Filter control
        output reg [2:0] W_f3
        
    );

    reg is_D_rs1_W_rd_overlap, is_D_rs2_W_rd_overlap, is_D_use_rs1, is_D_use_rs2, is_W_use_rd;
    reg is_E_rs1_M_rd_overlap, is_E_rs1_W_rd_overlap, is_E_use_rs1, is_E_use_rs2, is_M_use_rd;
    reg is_E_rs2_M_rd_overlap, is_E_rs2_W_rd_overlap;
    reg is_D_rs1_E_rd_overlap, is_D_rs2_E_rd_overlap, is_DE_overlap;
    reg [4:0] M_opcode, W_opcode;
    reg [2:0] M_func3;
    reg [4:0] M_rd;
    reg [4:0] E_rs1;
    reg [4:0] E_rs2;
    reg [4:0] E_rd;

    assign F_im_w_en = 4'b0000;

    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            E_opcode <= 5'd0;
            E_func3 <= 3'd0;
            E_func7 <= 1'd0;
            E_rs1 <= 5'd0;
            E_rs2 <= 5'd0;
            E_rd <= 5'd0;

            M_opcode <= 5'd0;
            M_func3 <= 3'd0;
            M_rd <= 5'd0;

            W_opcode <= 5'd0;
            W_f3 <= 3'd0;
            W_rd <= 5'd0;
        end
        else
        begin
            if(stall || next_pc_sel)
            begin
                E_opcode <= 00100;
                E_func3 <= 0;
                E_func7 <= 0;
                E_rs1 <= 0;
                E_rs2 <= 0;
                E_rd <= 0;  
            end
            else
            begin  
                E_opcode <= opcode;
                E_func3 <= func3;
                E_func7 <= func7;
                E_rs1 <= rs1;
                E_rs2 <= rs2;
                E_rd <= rd;
            end

            M_opcode <= E_opcode;
            M_func3 <= E_func3;
            M_rd <= E_rd;

            W_opcode <= M_opcode;
            W_f3 <= M_func3;
            W_rd <= M_rd;
        end
    end

    always @(*)   /*D*/
    begin
        case(opcode)
            5'b00000: /*I-type load*/
            begin
                is_D_use_rs1 = 1'b1;
                is_D_use_rs2 = 1'b0;
            end
            5'b00100: /*I-type addi*/
            begin
                is_D_use_rs1 = 1'b1;
                is_D_use_rs2 = 1'b0;
            end
            5'b01000: /*S-type store*/
            begin
                is_D_use_rs1 = 1'b1;
                is_D_use_rs2 = 1'b1;
            end
            5'b11000: /*B-type branch*/ 
            begin
                is_D_use_rs1 = 1'b1;
                is_D_use_rs2 = 1'b1;
            end
            5'b11001: /*I-type jalr*/
            begin
                is_D_use_rs1 = 1'b1;
                is_D_use_rs2 = 1'b0;
            end
            5'b00101: /*U-type auipc*/
            begin
                is_D_use_rs1 = 1'b0;
                is_D_use_rs2 = 1'b0;
            end
            5'b01101: /*U-type lui*/
            begin
                is_D_use_rs1 = 1'b0;
                is_D_use_rs2 = 1'b0;
            end
            5'b11011: /*J-type jal*/
            begin
                is_D_use_rs1 = 1'b0;
                is_D_use_rs2 = 1'b0;
            end
            5'b01100: /*R-type*/
            begin
                is_D_use_rs1 = 1'b1;
                is_D_use_rs2 = 1'b1;
            end
            default:
            begin
                is_D_use_rs1 = 1'b0;
                is_D_use_rs2 = 1'b0;
            end
        endcase
        begin
            is_D_rs1_W_rd_overlap = is_D_use_rs1 & is_W_use_rd & (rs1 == W_rd) & W_rd != 0;
            D_rs1_data_sel = is_D_rs1_W_rd_overlap ? 1'd1 : 1'd0;
            is_D_rs2_W_rd_overlap = is_D_use_rs2 & is_W_use_rd & (rs2 == W_rd) & W_rd != 0;
            D_rs2_data_sel = is_D_rs2_W_rd_overlap ? 1'd1 : 1'd0;

        end
    end

    always @(*)   /*E*/
    begin
        case(E_opcode) 
            5'b00000: /*I-type load*/
            begin
                E_alu_op1_sel = 1'b1;    //rs1
                E_alu_op2_sel = 1'b0;    //imm
                E_jb_op1_sel = 1'b0;
                next_pc_sel = 1'b0;
                is_E_use_rs1 = 1'b1;
                is_E_use_rs2 = 1'b0;
            end
            5'b00100: /*I-type addi*/
            begin
                E_alu_op1_sel = 1'b1;    //rs1
                E_alu_op2_sel = 1'b0;    //imm
                E_jb_op1_sel = 1'b0;
                next_pc_sel = 1'b0;
                is_E_use_rs1 = 1'b1;
                is_E_use_rs2 = 1'b0;
            end
            5'b01000: /*S-type store*/
            begin
                E_alu_op1_sel = 1'b1;    //rs1
                E_alu_op2_sel = 1'b0;    //imm
                E_jb_op1_sel = 1'b0;
                next_pc_sel = 1'b0;
                is_E_use_rs1 = 1'b1;
                is_E_use_rs2 = 1'b1;
            end
            5'b11000: /*B-type branch*/ 
            begin
                E_alu_op1_sel = 1'b1;    //rs1
                E_alu_op2_sel = 1'b1;    //rs2
                E_jb_op1_sel = 1'b0;
                is_E_use_rs1 = 1'b1;
                is_E_use_rs2 = 1'b1;
                case(alu_out)
                    32'd1:  /*sb*/
                        next_pc_sel = 1'b1;
                    32'd0:
                        next_pc_sel = 1'b0;
                    default:
                        next_pc_sel = 1'b0;
                endcase
            end
            5'b11001: /*I-type jalr*/
            begin
                E_alu_op1_sel = 1'b0;    //pc
                E_alu_op2_sel = 1'b0;    //-
                E_jb_op1_sel = 1'b1;
                next_pc_sel = 1'b1;
                is_E_use_rs1 = 1'b1;
                is_E_use_rs2 = 1'b0;
            end
            5'b00101: /*U-type auipc*/
            begin
                E_alu_op1_sel = 1'b0;    //pc
                E_alu_op2_sel = 1'b0;    //imm
                E_jb_op1_sel = 1'b0;
                next_pc_sel = 1'b0;
                is_E_use_rs1 = 1'b0;
                is_E_use_rs2 = 1'b0;
            end
            5'b01101: /*U-type lui*/
            begin
                E_alu_op1_sel = 1'b0;    //pc
                E_alu_op2_sel = 1'b0;    //imm
                E_jb_op1_sel = 1'b0;
                next_pc_sel = 1'b0;
                is_E_use_rs1 = 1'b0;
                is_E_use_rs2 = 1'b0;
            end
            5'b11011: /*J-type jal*/
            begin
                E_alu_op1_sel = 1'b0;    //pc
                E_alu_op2_sel = 1'b0;    //-
                E_jb_op1_sel = 1'b0;
                next_pc_sel = 1'b1;
                is_E_use_rs1 = 1'b0;
                is_E_use_rs2 = 1'b0;
            end
            5'b01100: /*R-type*/
            begin
                E_alu_op1_sel = 1'b1;    //rs1
                E_alu_op2_sel = 1'b1;    //rs2
                E_jb_op1_sel = 1'b0;
                next_pc_sel = 1'b0;
                is_E_use_rs1 = 1'b1;
                is_E_use_rs2 = 1'b1;
            end
            default:
            begin
                E_alu_op1_sel = 1'b0; //1'b0; 
                E_alu_op2_sel = 1'b0; //1'b0;    
                E_jb_op1_sel = 1'b0; //1'b0;
                next_pc_sel = 1'b0;  //1'b0;
                is_E_use_rs1 = 1'b0;
                is_E_use_rs2 = 1'b0;
            end
        endcase
        begin
            is_E_rs1_W_rd_overlap = is_E_use_rs1 & is_W_use_rd & (E_rs1 == W_rd) & W_rd != 0;
            is_E_rs1_M_rd_overlap = is_E_use_rs1 & is_M_use_rd & (E_rs1 == M_rd) & M_rd != 0;
            E_rs1_data_sel = is_E_rs1_M_rd_overlap ? 2'd1 :
                             is_E_rs1_W_rd_overlap ? 2'd0 : 2'd2;


            is_E_rs2_W_rd_overlap = is_E_use_rs2 & is_W_use_rd & (E_rs2 == W_rd) & W_rd != 0;
            is_E_rs2_M_rd_overlap = is_E_use_rs2 & is_M_use_rd & (E_rs2 == M_rd) & M_rd != 0;
            E_rs2_data_sel = is_E_rs2_M_rd_overlap ? 2'd1 :
                             is_E_rs2_W_rd_overlap ? 2'd0 : 2'd2;

        end
    end

    always @(*)   /*M*/
    begin
        case(M_opcode)  
            5'b00000: /*I-type load*/
            begin
                M_dm_w_en = 4'b0000;
                is_M_use_rd = 1'b1;
            end
            5'b00100: /*I-type addi*/
            begin
                M_dm_w_en = 4'b0000;
                is_M_use_rd = 1'b1;
            end
            5'b01000: /*S-type store*/
            begin
                is_M_use_rd = 1'b0;
                case(M_func3)
                    3'b000:  /*sb*/
                        M_dm_w_en = 4'b0001;
                    3'b001:  /*sh*/
                        M_dm_w_en = 4'b0011;
                    3'b010:  /*sw*/
                        M_dm_w_en = 4'b1111;
                    default:
                        M_dm_w_en = 4'b1111;
                endcase
            end
            5'b11000: /*B-type branch*/ 
            begin
                M_dm_w_en = 4'b0000;
                is_M_use_rd = 1'b0;
            end
            5'b11001: /*I-type jalr*/
            begin
                M_dm_w_en = 4'b0000;
                is_M_use_rd = 1'b1;
            end
            5'b00101: /*U-type auipc*/
            begin
                M_dm_w_en = 4'b0000;
                is_M_use_rd = 1'b1;
            end
            5'b01101: /*U-type lui*/
            begin
                M_dm_w_en = 4'b0000;
                is_M_use_rd = 1'b1;
            end
            5'b11011: /*J-type jal*/
            begin
                M_dm_w_en = 4'b0000;
                is_M_use_rd = 1'b1;
            end
            5'b01100: /*R-type*/
            begin
                M_dm_w_en = 4'b0000;
                is_M_use_rd = 1'b1;
            end
            default:
            begin
                M_dm_w_en = 4'b0000; //4'b0000;
                is_M_use_rd = 1'b0;
            end
        endcase
    end

    always @(*)   /*W*/
    begin
        case(W_opcode)
            5'b00000: /*I-type load*/
            begin
                W_wb_en = 1'b1;
                W_wb_data_sel = 1'b1;
                is_W_use_rd = 1'b1;
            end
            5'b00100: /*I-type addi*/
            begin
                W_wb_en = 1'b1;
                W_wb_data_sel = 1'b0;
                is_W_use_rd = 1'b1;
            end
            5'b01000: /*S-type store*/
            begin
                W_wb_en = 1'b0;
                W_wb_data_sel = 1'b0;
                is_W_use_rd = 1'b0;
            end
            5'b11000: /*B-type branch*/ 
            begin
                W_wb_en = 1'b0;
                W_wb_data_sel = 1'b0;
                is_W_use_rd = 1'b0;
            end
            5'b11001: /*I-type jalr*/
            begin
                W_wb_en = 1'b1;
                W_wb_data_sel = 1'b0;
                is_W_use_rd = 1'b1;
            end
            5'b00101: /*U-type auipc*/
            begin
                W_wb_en = 1'b1;
                W_wb_data_sel = 1'b0;
                is_W_use_rd = 1'b1;
            end
            5'b01101: /*U-type lui*/
            begin
                W_wb_en = 1'b1;
                W_wb_data_sel = 1'b0;
                is_W_use_rd = 1'b1;
            end
            5'b11011: /*J-type jal*/
            begin
                W_wb_en = 1'b1;
                W_wb_data_sel = 1'b0;
                is_W_use_rd = 1'b1;
            end
            5'b01100: /*R-type*/
            begin
                W_wb_en = 1'b1;
                W_wb_data_sel = 1'b0;
                is_W_use_rd = 1'b1;
            end
            default:
            begin
                W_wb_en = 1'b1; //1'b1;
                W_wb_data_sel = 1'b0;  //1'b0;
                is_W_use_rd = 1'b0;
            end
        endcase
    end

    always @(*)
    begin
        is_D_rs1_E_rd_overlap = is_D_use_rs1 & (rs1 == E_rd) & E_rd != 0;
        is_D_rs2_E_rd_overlap = is_D_use_rs2 & (rs2 == E_rd) & E_rd != 0;
        is_DE_overlap = (is_D_rs1_E_rd_overlap | is_D_rs2_E_rd_overlap);
        stall = (E_opcode == 5'b00000) & is_DE_overlap;
    end
    endmodule