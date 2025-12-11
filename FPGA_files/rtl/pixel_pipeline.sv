`timescale 1ns / 1ps

module pixel_pipeline(
    input  wire        clk,
    input  wire        valid_quad,
    input  wire [31:0] R_quad,
    input  wire [31:0] G_quad,
    input  wire [31:0] B_quad,

    output reg  [7:0]  R,
    output reg  [7:0]  G,
    output reg  [7:0]  B,
    output reg         valid_pix
);

    reg [1:0] idx = 0;

    always @(posedge clk) begin
        if (valid_quad) idx <= 0;
        else idx <= idx + 1;

        // Select the correct byte from the 32-bit quad
        R <= R_quad[31 - idx*8 -: 8];
        G <= G_quad[31 - idx*8 -: 8];
        B <= B_quad[31 - idx*8 -: 8];

        valid_pix <= valid_quad || (idx != 0);
    end
endmodule