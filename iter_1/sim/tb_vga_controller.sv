module tb_vga_controller;


    logic clk = 0;
    always #5 clk = ~clk; // Toggling clock

    logic rst;
    logic hsync, vsync;
    logic [9:0] px_x;
    logic [8:0] px_y;
    logic visible;

    vga_controller dut (
        .clk(clk),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .px_x(px_x),
        .px_y(px_y),
        .visible(visible)
    );

    initial begin
        $display("=== VGA Controller Test ===");

        // Reset Sequence
        rst = 1;
        repeat(5) @(posedge clk);
        rst = 0;
        $display("Reset released.");

        // 1. Check Start of Frame (0,0)
        @(posedge clk);
        $display("Start: px_x=%d px_y=%d visible=%b", px_x, px_y, visible);

        // 2. Run to end of visible line (640 cycles)
        repeat(640) @(posedge clk);
        $display("End of Visible: px_x=%d visible=%b (Should be 0)", px_x, visible);

        // 3. Run into Front Porch to check HSYNC
        // HSYNC starts 16 cycles after visible area ends
        repeat(20) @(posedge clk);
        $display("HSYNC Check: hsync=%b (Active Low)", hsync);

        // 4. Run to start of NEXT line (Line 1, physical line 2)
        repeat(140) @(posedge clk); 
        $display("Physical Line 1 (vcount=1): px_x=%d px_y=%d (Still y=0 due to scaling)", px_x, px_y);

        // 5. Run one MORE full line (800 cycles) to hit Physical Line 2
        repeat(800) @(posedge clk);
        $display("Physical Line 2 (vcount=2): px_x=%d px_y=%d (Now y should be 1)", px_x, px_y);

        $finish;
    end
endmodule