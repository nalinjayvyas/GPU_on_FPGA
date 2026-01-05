// this module controls jmp, register write and write select signals that will be high or low depending on the opcode.

module control_unit (
    input [3:0] opcode,
    output  reg_we, is_jump, wb_sel
);
// reg_we will be low for store, jump and NOP instructions
assign reg_we = (opcode != 4'b1111 && opcode != 4'b0000 && opcode != 4'b1001);
// is_jump goes high only when opcode intidcates jmp which is 1111.
assign is_jump = (opcode == 4'b1111);
// wb_sel goes high only when immediate instruction is given
assign wb_sel = (opcode == 4'b0111);

// Below is the implementation I tried with always block style
// always @(*) begin
//     reg_we = 0;
//     is_jump = 0;
//     wb_sel = 0;
//     case(opcode)
//     4'b1111: begin is_jump = 1; wb_sel = 0; end
//     4'b0111: begin wb_sel = 1; reg_we = 1; end
//     4'b0000: ;
//     default : reg_we = 1;
//     endcase
// end

endmodule