module tb_pixel_pipeline;

    logic clk = 0;
    always #5 clk = ~clk;

    logic valid_quad;
    logic [31:0] R_quad = 32'h10203040;
    logic [31:0] G_quad = 32'h11213141;
    logic [31:0] B_quad = 32'h12223242;

    logic [7:0] R,G,B;
    logic valid_pix;

    pixel_pipeline dut (
        .clk(clk),
        .valid_quad(valid_quad),
        .R_quad(R_quad),
        .G_quad(G_quad),
        .B_quad(B_quad),
        .R(R), .G(G), .B(B),
        .valid_pix(valid_pix)
    );

    initial begin
        $display("=== tb_pixel_pipeline ===");
        valid_quad = 1;
        @(posedge clk);
        valid_quad = 0;

        repeat (5) begin
            @(posedge clk);
            $display("Out: R=%h G=%h B=%h", R, G, B);
        end

        $finish;
    end
endmodule
