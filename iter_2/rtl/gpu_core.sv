module gpu_core (
    input clk, rst,
    input [3:0] buttons, // Takes the button inputs from the fpga
    input [7:0] i_time,
    input [7:0] i_y, // This take the y coord from the vga controller
    output [31:0] debug_out
);

logic [7:0] pc_out;
logic [15:0] instr_raw;
logic reg_we, is_jump, wb_sel;
logic [3:0] opcode, dest, src1, src2;
logic [7:0] imm;
logic [31:0] reg_data1, reg_data2, alu_result;
logic [31:0] writeback_data;

// Below is a mux that helps identify if data is coming from the immediate or alu
// If wb_sel = 0, writeback is alu_reult, else it is imm, but its copied 4 times as imm is 8 bit but writeback is 32 bit
assign writeback_data = wb_sel ? {4{imm}} : alu_result; 
// Same block coded in always style
// always @(*) begin
//     if (wb_sel) begin
//     writeback_data = {4{imm}};
// end
// else writeback_data = alu_result;
// end


prgrm_counter pc (.clk(clk), .rst(rst),
                  .is_jmp(is_jump), .jmp_target(imm),
                  .pc_addr(pc_out)
                );

instr_rom rom (.addr(pc_out), .dout(instr_raw));

instr_decoder decode (.instr(instr_raw), .opcode(opcode), 
.dest(dest), .src1(src1), .src2(src2), .imm(imm));

control_unit ctrl (.opcode(opcode), .reg_we(reg_we), .is_jump(is_jump), .wb_sel(wb_sel));

vector_alu alu (.op_a(reg_data1), .op_b(reg_data2), .opcode(opcode), .result(alu_result));

vector_reg_file v1 (.clk(clk), .we(reg_we), .r_addr1(src1),
 .r_addr2(src2), .w_addr(dest), .w_data(writeback_data), 
 .r_data1(reg_data1), .r_data2(reg_data2),.buttons(buttons), 
 .i_time(i_time), .i_y(i_y));

assign debug_out = reg_data1;

endmodule