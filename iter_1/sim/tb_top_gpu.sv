`timescale 1ns / 1ps

module tb_top_gpu;

    // 1. Inputs
    logic clk = 0;
    logic rst;

    // 2. Outputs
    logic hsync;
    logic vsync;
    logic [7:0] vga_r;
    logic [7:0] vga_g;
    logic [7:0] vga_b;

    // 3. Clock Generation (25 MHz -> 40ns period)
    always #20 clk = ~clk;

    // 4. DUT Instantiation
    top_gpu dut (
        .clk_25mhz(clk), 
        .rst(rst), 
        .hsync(hsync), 
        .vsync(vsync), 
        .vga_r(vga_r), 
        .vga_g(vga_g), 
        .vga_b(vga_b)
    );

    initial begin
        $dumpfile("gpu_waves.vcd");
        $dumpvars(0, tb_top_gpu);

        $display("=== Top GPU System Test ===");
        
        // Reset sequence
        rst = 1;
        repeat(5) @(posedge clk);
        rst = 0;
        $display("Reset released @ %0t", $time);

        // --- PHASE 1: Wait for Pipeline Fill ---
        // It takes a few cycles for the visible signal to propagate 
        // through shader -> pipeline -> output.
        wait(dut.visible == 1);
        $display("Visible region started @ %0t", $time);
        
        // Wait 3 cycles for pipeline latency
        repeat(3) @(posedge clk);

        // --- PHASE 2: Check Active Video Data ---
        // Monitor the first 10 pixels
        $display("\n--- Checking First 10 Pixels ---");
        for (int i = 0; i < 10; i++) begin
            $display("Time: %0t | X: %0d | RGB: %2h %2h %2h", 
                     $time, dut.px_x, vga_r, vga_g, vga_b);
            @(posedge clk);
        end

        // --- PHASE 3: Fast Forward to HSYNC ---
        // We are at pixel ~10. Visible ends at 320 (internal scale) / 640 (VGA scale).
        // Let's verify data goes to 0 when visible ends.
        
        $display("\n--- Fast Forwarding to End of Line ---");
        wait(dut.visible == 0);
        
        // Data might persist for 1-2 cycles due to pipeline delay, 
        // but 'visible' in top_gpu cuts it off immediately.
        @(posedge clk); 
        if (vga_r == 0 && vga_g == 0 && vga_b == 0)
            $display("SUCCESS: Output is Black (0) in blanking interval.");
        else
            $error("FAILURE: Output is NOT Black in blanking interval! RGB: %h%h%h", vga_r, vga_g, vga_b);

        // --- PHASE 4: Check Sync Signal ---
        // HSync should start shortly after visible ends
        wait(hsync == 0);
        $display("HSYNC Asserted (Active Low) @ %0t", $time);
        
        wait(hsync == 1);
        $display("HSYNC Released @ %0t", $time);

        $display("=== Test Complete ===");
        $finish;
    end

endmodule