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
wire [7:0] scaled_y = px_y [8:1] ;



always @(posedge clk) begin
    cnt <= cnt + 1;
   clk_25mhz <= cnt[1];
end
// assign clk_25mhz = cnt[1];

// This below blk avoid using the generated sugnal vsync_int as a clk, avoiding warnings
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
            if (btnU) btn_accum <= btn_accum + 1;
            if (btnD) btn_accum <= btn_accum - 1;
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
    if(px_x < 160) lane_data = gpu_result[7:0];
    else if (px_x < 320) lane_data = gpu_result[15:8];
    else if (px_x < 480) lane_data = gpu_result[23:16];
    else lane_data = gpu_result[31:24];
end

assign vgaGreen = visible ? lane_data[7:4] : 0;  // Assigns the vga pins different parts of the screen to show parallel processing things
assign vgaRed = visible ? lane_data[5:2] : 0 ;
assign vgaBlue = visible ? lane_data[3:0] : 0;
assign Vsync = vsync_int;

endmodule