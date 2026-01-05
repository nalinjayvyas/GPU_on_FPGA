// Top module to interface GPU with VGA controller

module top_programmable (
    input clk, btnC, btnU ,btnD, btnL, btnR,
    output Hsync,Vsync,
    output [3:0] vgaRed,vgaGreen,vgaBlue
);

logic [1:0] cnt;
logic [9:0] px_x; // x cord from vga
logic [8:0] px_y; // y cord from vga
logic visible;
logic [31:0] gpu_result;
logic clk_25mhz; 
reg [31:0] frame_timer;
reg [7:0] lane_data;
logic [7:0] slow_time; // slows down the clk to have an observable change in output
wire vsync_int;
reg vsync_prev = 0;
reg [3:0] btn_accum = 0;

// below wire helps include y coord in the gpu core
wire [7:0] scaled_y =  px_y[7:0] ;

// Registers declared to do the 4 bar separation

reg [7:0] lane_brightness = 0;
reg [3:0] r_ch, g_ch, b_ch = 0;



always @(posedge clk) begin
    cnt <= cnt + 1;
   clk_25mhz <= cnt[1];
end
// assign clk_25mhz = cnt[1];

// This below blk avoid using the generated signal vsync_int as a clk, avoiding warnings
always @(posedge clk_25mhz) begin
    if (btnC) begin 
        frame_timer <= 0;
        vsync_prev <= 0;
        btn_accum <= 0;
    end
    else begin 
        vsync_prev <= vsync_int;
        if(vsync_prev == 0 && vsync_int == 1)begin 
             frame_timer <= frame_timer + 1;
            if (btnU) btn_accum <= btn_accum + 2;
            if (btnD) btn_accum <= btn_accum - 2;
            if (btnR) btn_accum <= btn_accum + 4;
            if (btnL) btn_accum <= btn_accum - 4;
        end
    end
end

assign slow_time = frame_timer[12:5] ; // slower clock for animation


vga_controller vga (.clk(clk_25mhz), .rst(btnC),
                    .hsync(Hsync), .vsync(vsync_int), 
                    .px_x(px_x),.px_y(px_y), .visible(visible));

gpu_core gpu (.clk(clk_25mhz), .rst(btnC),
              .buttons({btn_accum}),
              .debug_out(gpu_result),
              .i_time(slow_time),.i_y(scaled_y));


always @(*) begin
    // 1. Reset Colors to Black (Default)
    r_ch = 0; 
    g_ch = 0; 
    b_ch = 0;
    lane_brightness = 0; 

    // 2. Divide Screen into 3 Columns (640 / 3 = 213 pixels)
    if (px_x < 90) begin
        // --- LEFT COLUMN: RED (Lane 0) ---
        lane_brightness = gpu_result[7:0];   // Read Lane 0
        
        // Draw Bar if Y is low enough, AND not on a Grid Line
        if ((scaled_y > (8'd240 - lane_brightness)) && (px_y[3:0] > 2)) begin
            r_ch = 4'hA; // Full Red
            g_ch = 4'hF;
            b_ch = 4'h3;
            
        end
    end 
    else if (px_x < 180) begin
        // --- MIDDLE COLUMN: GREEN (Lane 1) ---
        lane_brightness = gpu_result[15:8];  // Read Lane 1
        
        if ((scaled_y > (8'd240 - lane_brightness)) && (px_y[3:0] > 2)) begin
            g_ch = 4'hF; // Full Green
        end
    end 
    else if (px_x < 270) begin
         // --- LEFT COLUMN: RED (Lane 2) ---
        lane_brightness = gpu_result[7:0];   // Read Lane 0
        
        // Draw Bar if Y is low enough, AND not on a Grid Line
        if ((scaled_y > (8'd240 - lane_brightness)) && (px_y[3:0] > 2)) begin
            r_ch = 4'hF; // Full Red
        end
    end 
    else begin
        // --- RIGHT COLUMN: BLUE (Lane 3) ---
        lane_brightness = gpu_result[23:16]; // Read Lane 2
        
        if ((scaled_y > (8'd240 - lane_brightness)) && (px_y[3:0] > 2)) begin
            b_ch = 4'hF; // Full Blue
        end
    end
end
assign vgaGreen = visible ? g_ch : 0;  // Assigns the vga pins different parts of the screen to show parallel processing things
assign vgaRed = visible ? r_ch : 0 ;
assign vgaBlue = visible ? b_ch : 0;
assign Vsync = vsync_int;

endmodule