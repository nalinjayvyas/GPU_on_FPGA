/*  Instruction Breakup is as given below:
    Standard -  [15:12]opcode | [11:8]Dest | [7:4]src1 | [3:0]src2
    Immediate - [15:12]opcode | [11:8]Dest | [7:0]imm
*/

module instr_decoder(
    // 16 bit instruction
    input [15:0] instr,

    // Ouputs after bit slicing
    output [3:0] opcode,
    output [3:0] dest,
    output [3:0] src1,
    output [3:0] src2,
    output [7:0] imm

);

assign opcode = instr[15:12];
assign dest = instr[11:8];
assign src1 = instr[7:4];
assign src2 = instr[3:0];
assign imm = instr[7:0];


endmodule