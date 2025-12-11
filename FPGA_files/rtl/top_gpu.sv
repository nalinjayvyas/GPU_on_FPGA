`timescale 1ns / 1ps

module top_gpu(
    input  wire clk,      
    input  wire btnC,     // Reset
    input  wire btnU,     // Mode Switch
    input  wire btnL,     // Sprite Left
    input  wire btnR,     // Sprite Right
    
    // Outputs match your constraints
    output wire Hsync,
    output wire Vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
);

    // ==========================================
    // 1. Clock Divider (100MHz -> 25MHz)
    // ==========================================
    wire clk_25mhz;
    reg [1:0] clk_div = 0;
    always @(posedge clk) clk_div <= clk_div + 1;
    assign clk_25mhz = clk_div[1];

    // ==========================================
    // 2. State Machine & Inputs
    // ==========================================
    reg [31:0] frame_timer = 0;
    reg [1:0]  mode = 2; // Start in Mode 2 (Vaporwave)
    reg [9:0]  sprite_x = 128;
    reg        last_btnU;
    reg [19:0] move_timer;

    always @(posedge clk) begin
        // Switch Mode (0 -> 1 -> 2 -> 0) on Button U press
        if (btnU && !last_btnU) mode <= (mode == 2) ? 0 : mode + 1;
        last_btnU <= btnU;

        // Move Sprite (Simple debounce/delay logic)
        if (move_timer == 200000) begin
            move_timer <= 0;
            if (btnR && sprite_x < 256) sprite_x <= sprite_x + 1;
            if (btnL && sprite_x > 0)   sprite_x <= sprite_x - 1;
        end else move_timer <= move_timer + 1;
    end
    
    // Global Timer (Increments every VSync for animation)
    always @(posedge Vsync) frame_timer <= frame_timer + 1;

    // ==========================================
    // 3. VGA Controller
    // ==========================================
    wire [9:0] px_x;
    wire [8:0] px_y;
    wire visible;
    wire hsync_int, vsync_int;

    // Your 320x240 Logic Controller
    vga_controller vga(
        .clk(clk_25mhz), .rst(btnC),
        .hsync(hsync_int), .vsync(vsync_int),
        .px_x(px_x), .px_y(px_y), .visible(visible)
    );

    // ==========================================
    // 4. PARALLEL SHADER CORE (Backgrounds)
    // ==========================================
    wire [31:0] R_q, G_q, B_q;
    wire valid_q;
    
    shader_core shader (
        .clk(clk_25mhz),
        .px_x_base(px_x & 10'h3FC),
        .px_y(px_y),
        .valid_in(visible),
        .i_time(frame_timer),
        .i_mode(mode),
        .R_quad(R_q), .G_quad(G_q), .B_quad(B_q),
        .valid_out(valid_q)
    );

    // ==========================================
    // 5. PIXEL PIPELINE (Serializer)
    // ==========================================
    wire [7:0] bg_r, bg_g, bg_b;
    wire valid_pix;
    
    pixel_pipeline pipe (
        .clk(clk_25mhz), .valid_quad(valid_q),
        .R_quad(R_q), .G_quad(G_q), .B_quad(B_q),
        .R(bg_r), .G(bg_g), .B(bg_b),
        .valid_pix(valid_pix)
    );

    // ==========================================================
    // 6. TEXTURE UNIT 1: STATIC IMAGE (Mode 1)
    // ==========================================================
    // Resolution Mapping:
    // Screen: 320x240
    // Image:  80x60 (Padded to 100x100 in memory)
    // Scale Factor: 320 / 80 = 4.
    // Operation: Right Shift by 2 (>> 2).
    
    wire [13:0] img_addr;
    
    // (px_y / 4) * 100 + (px_x / 4)
    assign img_addr = (px_y[8:2] * 100) + px_x[9:2];
    
    wire [11:0] img_data;

    rom_image static_tex (
        .clka(clk_25mhz),
        .ena(1'b1),        // ENABLE PIN TIED HIGH
        .addra(img_addr),
        .douta(img_data)
    );

    // ==========================================================
    // 7. TEXTURE UNIT 2: SPRITE (Mode 2)
    // ==========================================================
    localparam SPRITE_Y = 100; // Adjusted Y height for 240p screen
    
    wire in_sprite = (px_x >= sprite_x && px_x < sprite_x + 64 && 
                      px_y >= SPRITE_Y && px_y < SPRITE_Y + 64);
                      
    wire [1:0] anim_frame = frame_timer[5:4];
    wire [13:0] spr_addr = ((px_y - SPRITE_Y) + (anim_frame * 64)) * 64 + (px_x - sprite_x);
    wire [11:0] spr_data;

    rom_sprite dynamic_tex (
        .clka(clk_25mhz),
        .ena(1'b1),        // ENABLE PIN TIED HIGH
        .addra(spr_addr),
        .douta(spr_data)
    );

    // ==========================================
    // 8. FINAL COMPOSITOR / MIXER
    // ==========================================
    reg [3:0] fr, fg, fb;

    always @(*) begin
        // 1. Default Layer: Shader Background
        fr = bg_r[7:4];
        fg = bg_g[7:4];
        fb = bg_b[7:4];

        // 2. Mode 1: Static Image (Full Screen Overlay)
        if (mode == 1) begin
            // Directly output image data (No "if in_rect" check needed)
            fr = img_data[11:8];
            fg = img_data[7:4];
            fb = img_data[3:0];
        end 
        
        // 3. Mode 2: Sprite Overlay on top of Shader
        else if (mode == 2) begin
            if (in_sprite && spr_data != 0) begin
                // Draw sprite if pixel is not black (0)
                fr = spr_data[11:8];
                fg = spr_data[7:4];
                fb = spr_data[3:0];
            end
        end
    end

    // ==========================================
    // 9. Output Assignment
    // ==========================================
    assign vgaRed   = visible ? fr : 0;
    assign vgaGreen = visible ? fg : 0;
    assign vgaBlue  = visible ? fb : 0;
    assign Hsync    = hsync_int;
    assign Vsync    = vsync_int;

endmodule

