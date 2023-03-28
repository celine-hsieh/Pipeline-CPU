module SRAM (
    input clk,
    input [3:0]w_en,
    input [15:0]address,  //alu_out
    input [31:0]write_data,
    output reg[31:0]read_data
);

    reg [7:0] mem[0:65535];  // 2^16 = 65536
	reg [31:0]write;

always @(*)
	begin
		read_data[7:0] = mem[address];
		read_data[15:8] = mem[address + 1];
		read_data[23:16] = mem[address + 2];
		read_data[31:24] = mem[address + 3];
	end

always @(posedge clk)
	begin
		if(w_en==4'b0001)
		begin
			mem[address] <= write_data[7:0];
		end
		else if(w_en==4'b0011)
		begin
			mem[address] <= write_data[7:0];
			mem[address + 1] <= write_data[15:8];
		end
		else if(w_en==4'b1111)
		begin
			mem[address] <= write_data[7:0];
			mem[address + 1] <= write_data[15:8];
			mem[address + 2] <= write_data[23:16];
			mem[address + 3] <= write_data[31:24];
		end
	end

endmodule