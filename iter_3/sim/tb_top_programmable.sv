`timescale 1ns / 1ps

module tb_top_programmable;

    reg clk, btnC;
    reg btnU, btnD, btnL, btnR;
    wire Hsync, Vsync;
    wire [3:0] vgaRed, vgaGreen, vgaBlue;

    top_programmable dut (
        .clk(clk), .btnC(btnC),
        .btnU(btnU), .btnD(btnD), .btnL(btnL), .btnR(btnR),
        .Hsync(Hsync), .Vsync(Vsync),
        .vgaRed(vgaRed), .vgaGreen(vgaGreen), .vgaBlue(vgaBlue)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("final_report_wave.vcd");
        $dumpvars(0, tb_top_programmable);
        
        clk = 0; btnC = 1; 
        btnU = 0; btnD = 0; btnL = 0; btnR = 0;

        #100 btnC = 0;
        $display("[TB] Reset Released.");

        // 1. Simulate Button Press to grow bars
        btnU = 1;
        repeat(3) begin
            wait(Vsync == 0);
            wait(Vsync == 1); 
        end
        btnU = 0;

        // 2. Wait for Active Video at the BOTTOM of the screen
        // We use Line 430. 
        // px_y = 215. 
        // 215 % 16 = 7 (Greater than 2, so NOT a black grid line).
        wait(dut.vga.vcount == 430); 
        
        // 3. Probe the 4 Lanes
        // Recall: px_x = hcount / 2.
        
        // Lane 0 (Red Area): X < 90. 
        // Target X=45 -> hcount=90.
        wait(dut.vga.hcount == 90);
        $display("[TB] Lane 0 (X=45)  | Color: %h%h%h", vgaRed, vgaGreen, vgaBlue);

        // Lane 1 (Green Area): 90 < X < 180. 
        // Target X=135 -> hcount=270.
        wait(dut.vga.hcount == 270);
        $display("[TB] Lane 1 (X=135) | Color: %h%h%h", vgaRed, vgaGreen, vgaBlue);

        // Lane 2 (Red Area): 180 < X < 270. 
        // Target X=225 -> hcount=450.
        wait(dut.vga.hcount == 450);
        $display("[TB] Lane 2 (X=225) | Color: %h%h%h", vgaRed, vgaGreen, vgaBlue);

        // Lane 3 (Blue Area): X > 270. 
        // Target X=315 -> hcount=630.
        wait(dut.vga.hcount == 630);
        $display("[TB] Lane 3 (X=315) | Color: %h%h%h", vgaRed, vgaGreen, vgaBlue);

        #100;
        $finish;
    end

endmodule