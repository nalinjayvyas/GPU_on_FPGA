`timescale 1ns / 1ps

module shader_core #(
    parameter BITS_X = 10,
    parameter BITS_Y = 9
)(
    input  wire clk,
    input  wire [BITS_X-1:0] px_x_base, // Base X (aligned to 4)
    input  wire [BITS_Y-1:0] px_y,
    input  wire valid_in,
    
    // Uniforms (Global Variables)
    input  wire [31:0] i_time,
    input  wire [1:0]  i_mode, // 0=Plasma, 1=Static, 2=Vaporwave

    // Parallel Output (Packed Quad)
    output reg [31:0] R_quad,
    output reg [31:0] G_quad,
    output reg [31:0] B_quad,
    output reg        valid_out
);

    integer i;
    reg [7:0] r_temp [0:3];
    reg [7:0] g_temp [0:3];
    reg [7:0] b_temp [0:3];
    
    // Calculation Variables (Declared outside the loop for compatibility)
    reg [BITS_X-1:0] cx;
    reg [BITS_Y-1:0] cy;
    reg [7:0] wave;
    reg [8:0] grid_y;

    always @(posedge clk) begin
        if (valid_in) begin
            
            // --- PARALLEL EXECUTION LOOP (SIMD) ---
            // This loop unrolls in hardware to create 4 parallel calculation units.
            for (i = 0; i < 4; i = i + 1) begin
                
                cx = px_x_base + i; // Current X for this lane
                cy = px_y;          // Current Y
                
                // MODE 0: PLASMA (Math Heavy)
                if (i_mode == 0) begin
                    wave = cx + cy + i_time[7:0];
                    r_temp[i] = wave;
                    g_temp[i] = wave ^ cx[7:0];
                    b_temp[i] = wave + i_time[7:0];
                end 
                
                // MODE 1: STATIC (Debug/Clear)
                else if (i_mode == 1) begin
                    r_temp[i] = 8'h20; 
                    g_temp[i] = 8'h20; 
                    b_temp[i] = 8'h20;
                end
                
                // MODE 2: VAPORWAVE GRID (Logic Heavy)
                else if (i_mode == 2) begin
                    // Calculate moving floor perspective
                    grid_y = cy + i_time[5:0];
                    
                    // Grid Logic: Horizon line at Y=120
                    if (cy < 120) begin
                        // Sky Gradient (Black to Purple)
                        r_temp[i] = {cy[6:0], 1'b0}; 
                        g_temp[i] = 0; 
                        b_temp[i] = {cy[6:0], 1'b0} + 8'h40;
                    end else begin
                        // Floor Grid (Pink lines on Blue)
                        if ((grid_y[4:0] < 3) || (cx[4:0] < 3)) begin
                            // Grid Lines (Neon Pink)
                            r_temp[i] = 8'hFF; g_temp[i] = 8'h00; b_temp[i] = 8'hCC;
                        end else begin
                            // Floor (Dark Blue)
                            r_temp[i] = 0; g_temp[i] = 0; b_temp[i] = 8'h40;
                        end
                    end
                end
            end

            // PACK RESULTS into 32-bit Quads
            R_quad <= {r_temp[0], r_temp[1], r_temp[2], r_temp[3]};
            G_quad <= {g_temp[0], g_temp[1], g_temp[2], g_temp[3]};
            B_quad <= {b_temp[0], b_temp[1], b_temp[2], b_temp[3]};
            valid_out <= 1;

        end else begin
            valid_out <= 0;
            R_quad <= 0; G_quad <= 0; B_quad <= 0;
        end
    end
endmodule