// 2-Read, 1-Write Vector Register File
module vector_reg_file #(parameter DATA_WIDTH = 8, LANES = 4, REG_COUNT = 16)
(
    // no rst cuz rsting mmry is expensive and is usually not done.
    input clk,
    input we,

    // 4 bit addresses
    input [3:0] r_addr1,
    input [3:0] r_addr2,
    input [3:0] w_addr,

    // button inputs 
    input [3:0] buttons,

    // i_time input
    input[7:0] i_time,

    // This takes the Y_coord input from vga controller and uses it to perform 
    // operations on the y axis on screen
    input [7:0] i_y,

    // data to be written into mmry
    input [31:0] w_data,

    // 32 bit packed data output
    output [31:0] r_data1,
    output [31:0] r_data2
);

// temp to replicate the buttons 4 times to fit 32 bit
wire [31:0] temp_button = {4{4'b0,buttons}};
reg [31:0] reg_mmry [0:15]; // 16 registers of 32 bits
integer i;
// This block makes sure all values in the reg_mmry are 0 initially
initial begin
    for (i =0; i<16; i = i + 1) begin
        reg_mmry[i] =0;
    end
end
// write should only happen on clock
always @(posedge clk) begin
    if(we && w_addr != 0) reg_mmry[w_addr] <= w_data; // write action performed on w_addr
end
// Below two assign statements remove the requirement of using always @(*) block and saves space i guess
assign r_data1 =   (r_addr1 == 0)  ? 32'b0 :  // if address is v0, returns 0
                   (r_addr1 == 12) ? temp_button : // if address is v12 return button data
                   (r_addr1 == 14) ? 32'h00503010: // if address is v14 returns lane ids
                   (r_addr1 == 15) ? {4{i_time}} : // reg 15 saves time
                   (r_addr1 == 13) ? 32'h03020100 : // reg 13 stores the y coord from the vga controller
                   reg_mmry[r_addr1]; // checks if r_addr is 0, if its 0 asserts output to 0(as our ISA needs reg_mmry[0] to be null), else to reg_mmry[r_addr]

assign r_data2 =   (r_addr2 == 0)  ? 32'b0 :  // if address is v0, returns 0
                   (r_addr2 == 12) ? temp_button : // if address is v12 return button data
                   (r_addr2 == 14) ? 32'h00503010 : // if address is v14 returns lane ids
                   (r_addr2 == 15) ? {4{i_time}} : // reg 15 saves time
                   (r_addr2 == 13) ? 32'h03020100 : // reg 13 stores y coord from vga 
                   reg_mmry[r_addr2];
endmodule