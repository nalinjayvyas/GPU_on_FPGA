module tb_shader_core;

    logic clk = 0;
    always #5 clk = ~clk;

    logic valid_in = 0;
    logic [8:0] px_x_base;
    logic [7:0] px_y;

    logic [31:0] R_quad, G_quad, B_quad;
    logic valid_out;

    shader_core dut (
        .clk(clk),
        .px_x_base(px_x_base),
        .px_y(px_y),
        .valid_in(valid_in),
        .R_quad(R_quad),
        .G_quad(G_quad),
        .B_quad(B_quad),
        .valid_out(valid_out)
    );

    initial begin
        $display("=== Shader Core Test ===");

        @(posedge clk);
        px_x_base = 10;
        px_y = 20;

        valid_in = 1;
        @(posedge clk);
        valid_in = 0;

        @(posedge clk);
        $display("R_quad = %h", R_quad);
        $display("G_quad = %h", G_quad);
        $display("B_quad = %h", B_quad);

        $finish;
    end
endmodule
