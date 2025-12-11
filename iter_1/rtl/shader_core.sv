module shader_core #(
    parameter BITS_X = 9,
    parameter BITS_Y = 8
)(
    input  wire clk,
    input  wire [BITS_X-1:0] px_x_base,
    input  wire [BITS_Y-1:0] px_y,
    input  wire valid_in,

    output reg [31:0] R_quad,   // 4 × 8-bit packed
    output reg [31:0] G_quad,
    output reg [31:0] B_quad,
    output reg        valid_out
);

    integer i;
    reg [7:0] Rtmp[0:3];
    reg [7:0] Gtmp[0:3];
    reg [7:0] Btmp[0:3];

    always @(posedge clk) begin
        if (valid_in) begin
            for (i = 0; i < 4; i++) begin
                Rtmp[i] = (px_x_base + i) >> 2;
                Gtmp[i] = px_y >> 1;
                Btmp[i] = (px_x_base + i) ^ px_y;
            end

            // pack into 32-bit output buses
            R_quad <= {Rtmp[0], Rtmp[1], Rtmp[2], Rtmp[3]};
            G_quad <= {Gtmp[0], Gtmp[1], Gtmp[2], Gtmp[3]};
            B_quad <= {Btmp[0], Btmp[1], Btmp[2], Btmp[3]};

            valid_out <= 1;
        end else begin
            valid_out <= 0;
        end
    end

endmodule
