module LD_Filter (
    input [2:0] func3,
    input signed [31:0] ld_data,
    output reg signed [31:0] ld_data_f
);


always @(*)
    begin
        case(func3)
            3'b000:  /*lb*/
                ld_data_f = ld_data >>> 24;
            3'b001:  /*lh*/
                ld_data_f = ld_data >>> 16;
            3'b010:  /*lw*/
                ld_data_f = ld_data;
            3'b100:  /*lbu*/
                ld_data_f = ld_data >> 24;
            3'b101:  /*lhu*/
                ld_data_f = ld_data >> 16;
            default:
                ld_data_f = ld_data;
        endcase
    end
endmodule