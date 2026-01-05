`timescale 1ns/1ps

module tb_gpu_core ;

reg clk, rst;
wire [31:0] result;

gpu_core dut (.clk(clk), .rst(rst), .debug_out(result));

initial begin
    clk = 0;
    rst = 1;
    #20 rst = 0;
    #200;

    $display("Simulation Finished");
    $finish;
end

always #5 clk = ~clk;

initial begin
    $monitor("Time : %t | PC: %d | Op: %b | Reg3: %h", $time, dut.pc_out, dut.opcode, dut.v1.reg_mmry[3]);
end



endmodule