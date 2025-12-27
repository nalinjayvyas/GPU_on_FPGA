// Simple Program counter that also accounts for a jmp statement

module prgrm_counter (

    input clk,
    input rst,
    input is_jmp, // tells if we need to do jmp like jne,jnc type stuff
    input [7:0] jmp_target, // gives address where to jump

    output reg [7:0] pc_addr // ouput address
);
    always @(posedge clk or posedge rst) begin
        if(rst) pc_addr <= 0; // Resets PC
        else begin
            if(is_jmp) pc_addr <= jmp_target; // jumps to location
            else begin
                pc_addr <= pc_addr + 1; // PC increment
            end
        end
    end

endmodule