// Contains the instrcutions that will be decoded later n stuff

module instr_rom(

    input [7:0] addr, // input from PC

    output [15:0] dout // this will be the whole instruction
);

reg [15:0] temp ; // temporary variable to store instr

    always @(*) begin
        case(addr) 
        // 0001 -> ADD ; 0111 -> LDI ; 1111 -> JMP ; 0100 -> SHL;
        //                       opcode_dest_src1_src2
        8'b0000_0000 :  temp = 16'b0111_0010_0000_0010 ;// This instr does LDI v2,2 (Loads the shift amnt)
        8'b0000_0001 :  temp = 16'b0001_0001_1100_1110 ;// This instr does ADD v1,v12,v14 (Combines Lane ID with Buttons)
        8'b0000_0010 :  temp = 16'b0010_0001_0001_1101 ;// This instr does SUB v1,v1,v13 (Subtracts y coord from total)
        8'b0000_0011 :  temp = 16'b0100_0001_0001_0010 ;// This instr does SHL v1,v1,v2 ( Shifts v1 by 2 to make it visible)
        8'b0000_0100 :  temp = 16'b1111_0000_0000_0001 ;// This instr does JMP address 1 ( Loop)
        default : temp = 16'b0; // Default case
        endcase
    end
assign dout = temp;
    

endmodule