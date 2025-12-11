`timescale 1ns/1ps

module tb_shader_pipeline;

    // ------------------------------
    // Clock + Reset
    // ------------------------------
    logic clk = 0;
    logic rst = 1;

    always #5 clk = ~clk;   // 100 MHz clock

    // ------------------------------
    // Shader Core Inputs
    // ------------------------------
    logic valid_in;
    logic [8:0] px_x_base;      // BITS_X = 9
    logic [7:0] px_y;           // BITS_Y = 8

    // ------------------------------
    // Shader Core Outputs (4-pixel quad)
    // ------------------------------
    logic        valid_quad;
    logic [7:0]  R_quad [0:3];
    logic [7:0]  G_quad [0:3];
    logic [7:0]  B_quad [0:3];

    // ------------------------------
    // Pixel Pipeline Outputs
    // ------------------------------
    logic [7:0] R_pix, G_pix, B_pix;
    logic       valid_pix;

    // ==============================================================
    // DUT Instantiation — Shader Core
    // ==============================================================
    shader_core #(
        .BITS_X(9),
        .BITS_Y(8)
    ) dut_shader (
        .clk(clk),
        .px_x_base(px_x_base),
        .px_y(px_y),
        .valid_in(valid_in),
        .R(R_quad),
        .G(G_quad),
        .B(B_quad),
        .valid_out(valid_quad)
    );

    // ==============================================================
    // DUT Instantiation — Pixel Pipeline
    // ==============================================================
    pixel_pipeline dut_pipe (
    .clk(clk),
    .valid_quad(valid_quad),
    .R_quad(R_quad),
    .G_quad(G_quad),
    .B_quad(B_quad),
    .R(R_pix),
    .G(G_pix),
    .B(B_pix),
    .valid_pix(valid_pix)
);


    // ------------------------------
    // Test Logic
    // ------------------------------
    initial begin
        $display("===== Shader + Pixel Pipeline Testbench =====");

        // Reset
        valid_in   = 0;
        px_x_base  = 0;
        px_y       = 0;

        #50 rst = 0;
        $display("[TB] Reset released.");

        repeat (5) begin
            // Random base x and y
            px_x_base = $urandom_range(0, 315);   // leave room for +3
            px_y      = $urandom_range(0, 239);

            // Pulse valid_in for 1 clock
            @(posedge clk);
            valid_in = 1;

            @(posedge clk);
            valid_in = 0;

            // Wait for shader valid
            wait(valid_quad);

            $display("\n--- New Quad: x=%0d, y=%0d ---", px_x_base, px_y);

            // Print the quad pixels coming from shader
            for (int i = 0; i < 4; i++) begin
                $display("Shader Pixel[%0d] = R=%0d G=%0d B=%0d",
                         i, R_quad[i], G_quad[i], B_quad[i]);
            end

            // Now observe pixel pipeline streaming 4 pixels out
            repeat (4) begin
                @(posedge clk);
                if (valid_pix)
                    $display("Pipeline Out: R=%0d G=%0d B=%0d", 
                             R_pix, G_pix, B_pix);
            end

            @(posedge clk);
        end

        $display("\n===== Test Completed =====");
        $finish;
    end

endmodule
