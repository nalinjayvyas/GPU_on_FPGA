module top_gpu(
    input  wire clk_25mhz,
    input  wire rst,

    output wire hsync,
    output wire vsync,

    output wire [7:0] vga_r,
    output wire [7:0] vga_g,
    output wire [7:0] vga_b
);

    // ===============================
    // 1. VGA Controller
    // ===============================
    wire [9:0] px_x;
    wire [8:0] px_y;
    wire visible;

    vga_controller vga(
        .clk(clk_25mhz),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .px_x(px_x),
        .px_y(px_y),
        .visible(visible)
    );

    // ===============================
    // 2. Shader Core (Quad Generator)
    // ===============================
    wire [31:0] R_quad, G_quad, B_quad;
    wire        valid_quad;

    // Mask the bottom 2 bits of X to align to 4-pixel boundaries
    // and truncate to 9 bits for the shader core input
    wire [8:0] shader_x_base = px_x[8:0] & 9'h1FC;

    shader_core shader(
        .clk(clk_25mhz),
        .px_x_base(shader_x_base),
        .px_y(px_y),
        .valid_in(visible),
        .R_quad(R_quad),  // Fixed: was .R
        .G_quad(G_quad),  // Fixed: was .G
        .B_quad(B_quad),  // Fixed: was .B
        .valid_out(valid_quad)
    );

    // ===============================
    // 3. Pixel Pipeline (Serializer)
    // ===============================
    wire [7:0] R_pix, G_pix, B_pix;
    wire       valid_pix;

    pixel_pipeline pipe(
        .clk(clk_25mhz),
        .valid_quad(valid_quad),
        .R_quad(R_quad),
        .G_quad(G_quad),
        .B_quad(B_quad),
        .R(R_pix),
        .G(G_pix),
        .B(B_pix),
        .valid_pix(valid_pix)
    );

    // ===============================
    // 4. Output to VGA
    // ===============================
    // Note: There is a pipeline delay (Shader+Pipe = 2 clocks).
    // The data appearing here corresponds to the X/Y from 2 clocks ago.
    assign vga_r = visible ? R_pix : 8'h00;
    assign vga_g = visible ? G_pix : 8'h00;
    assign vga_b = visible ? B_pix : 8'h00;

endmodule