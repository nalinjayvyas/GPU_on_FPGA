/* Main module that computes in 4 way parallel based on opcode (SIMD)
        Op code reference table for future : 
        0000 - Nothing
        0001 - add A with B
        0010 - Subtract B from A
        0011 - XOR A with B
        0100 - Shifts data from A left by B bits
        0101 - Shifts data from A right by B bits
*/

module vector_alu (

    input [31:0] op_a,
    input [31:0] op_b,
    input [3:0] opcode,

    output [31:0] result
);
reg [7:0] temp_mmry_a [0:3]; // 4 registers of 8 bit 
reg [7:0] temp_mmry_b [0:3];
reg [7:0] temp_result [0:3]; //
integer i;

always @(*) begin
    // break up input a into chunks of 8bits
    temp_mmry_a[0] = op_a[31:24];
    temp_mmry_a[1] = op_a[23:16];
    temp_mmry_a[2] = op_a[15:8];
    temp_mmry_a[3] = op_a[7:0];

    // breakup input b into chunks of 8bits
    temp_mmry_b[0] = op_b[31:24];
    temp_mmry_b[1] = op_b[23:16];
    temp_mmry_b[2] = op_b[15:8];
    temp_mmry_b[3] = op_b[7:0];
    
    // Main code that synthesizes to 4 parallel hardware
    // 4 parallel ways to compute the result using opcode
    for (i=0; i<4;i = i + 1) begin
        case(opcode)
        4'b0001 : temp_result[i] = temp_mmry_a[i] + temp_mmry_b[i];
        4'b0010 : temp_result[i] = temp_mmry_a[i] - temp_mmry_b[i];
        4'b0011 : temp_result[i] = temp_mmry_a[i] ^ temp_mmry_b[i];
        4'b0100 : temp_result[i] = temp_mmry_a[i] << temp_mmry_b[i];
        4'b0101 : temp_result[i] = temp_mmry_a[i] >> temp_mmry_b[i];
        default : temp_result[i] = 0;
        endcase
    end
end
// join all the 4 parallel calculation outputs into one 32 bit output 
assign result = {temp_result[0],temp_result[1],temp_result[2],temp_result[3]}; 

endmodule