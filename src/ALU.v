module ALU (
    input [4:0] opcode,
    input [2:0] func3,
    input func7,
    input [31:0] operand1,
    input [31:0] operand2,
    output reg [31:0] alu_out
);

wire signed [31:0]op1, op2, slt, sgte;
assign op1 = operand1;
assign op2 = operand2;
assign slt = op1 < op2;
assign sgte = op1 >= op2;

always @(*)
    begin

        case(opcode)
            5'b00000: /*I-type load*/
                if(func3==3'b000 || func3==3'b001 || func3==3'b010)
                    alu_out = op1 + op2;            
                else   
                    alu_out = operand1 + operand2;  //operand2 = imm
            5'b00100: /*I-type addi*/               //operand2 = imm
            begin
                if(func3==3'b000)
                    alu_out = operand1 + operand2;            //addi
                else if(func3==3'b001)
                    alu_out = operand1 << operand2[4:0];      //slli
                else if(func3==3'b010)
                    alu_out = slt ? 1 : 0;                    //slti
                else if(func3==3'b011)
                    alu_out = operand1 < operand2 ? 1 : 0;    //sltiu
                else if(func3==3'b100)
                    alu_out = operand1 ^ operand2;            //xori
                else if(func3==3'b101 && func7==0)
                    alu_out = operand1 >> operand2[4:0];      //srli
                else if(func3==3'b101 && func7==1)
                    alu_out = op1 >>> op2[4:0];               //srai
                else if(func3==3'b110)
                    alu_out = operand1 | operand2;            //ori
                else if(func3==3'b111)
                    alu_out = operand1 & operand2;            //andi
                else
                    alu_out = alu_out;
            end 
            5'b01000: /*S-type store */
                alu_out = operand1 + operand2;  //operand2 = imm 
            5'b11000: /*B-type branch*/    
                if(func3==3'b000)    
                    alu_out = operand1 == operand2 ? 1 : 0;    //beq
                else if(func3==3'b001)    
                    alu_out = operand1 != operand2 ? 1 : 0;    //bne
                else if(func3==3'b100)    
                    alu_out = slt ? 1 : 0;                     //blt
                else if(func3==3'b101)    
                    alu_out = sgte ? 1 : 0;                    //bge
                else if(func3==3'b110)    
                    alu_out = operand1 < operand2 ? 1 : 0;     //bltu
                else if(func3==3'b111)    
                    alu_out = operand1 >= operand2 ? 1 : 0;    //bgeu
            5'b11001: /*I-type jalr*/
                alu_out = (operand1 + 4);             //operand1 = pc
            5'b00101: /*U-type auipc*/
                alu_out = operand1 + operand2;  //operand1 = pc
            5'b01101: /*U-type lui*/
                alu_out = operand2;
            5'b11011: /*J-type jal*/
                alu_out = (operand1 + 4);             //operand1 = pc
            5'b01100: /*R-type*/
            begin
                if(func3==3'b000 && func7==0)
                    alu_out = operand1 + operand2;            //add
                else if(func3==3'b000 && func7==1)
                    alu_out = operand1 - operand2;            //sub 
                else if(func3==3'b001)
                    alu_out = operand1 << operand2[4:0];      //sll 
                else if(func3==3'b010)
                    alu_out = slt ? 1 : 0;                    //slt 
                else if(func3==3'b011)
                    alu_out = operand1 < operand2 ? 1 : 0;    //sltu
                else if(func3==3'b100)
                    alu_out = operand1 ^ operand2;            //xor
                else if(func3==3'b101 && func7==0)
                    alu_out = operand1 >> operand2[4:0];      //srl
                else if(func3==3'b101 && func7==1)
                    alu_out = op1 >>> op2[4:0];               //sra
                else if(func3==3'b110)
                    alu_out = operand1 | operand2;            //or
                else if(func3==3'b111)
                    alu_out = operand1 & operand2;            //and
                else
                    alu_out = alu_out;
            end
            default:
                alu_out = 0;
        endcase        
    end

endmodule