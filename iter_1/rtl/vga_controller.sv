module vga_controller(
    input  wire clk,           // 25 MHz pixel clock
    input  wire rst,

    output reg  hsync,
    output reg  vsync,
    output wire [9:0] px_x,    // 0..319
    output wire [8:0] px_y,    // 0..239
    output wire visible
);

    // VGA params (640×480)
    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;

    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;

    reg [9:0] hcount = 0;
    reg [9:0] vcount = 0;

    always @(posedge clk) begin
        if (rst) begin
            hcount <= 0;
            vcount <= 0;
        end else begin
            if (hcount == H_TOTAL-1) begin
                hcount <= 0;
                if (vcount == V_TOTAL-1)
                    vcount <= 0;
                else
                    vcount <= vcount + 1;
            end else begin
                hcount <= hcount + 1;
            end
        end
    end

    // HSYNC generation (active low)
    always @(*) begin
        hsync = ~((hcount >= H_VISIBLE + H_FRONT) &&
                  (hcount <  H_VISIBLE + H_FRONT + H_SYNC));
    end

    // VSYNC generation (active low)
    always @(*) begin
        vsync = ~((vcount >= V_VISIBLE + V_FRONT) &&
                  (vcount <  V_VISIBLE + V_FRONT + V_SYNC));
    end

    assign visible = (hcount < H_VISIBLE) && (vcount < V_VISIBLE);

    // Convert 640×480 → 320×240 coordinates
    assign px_x = hcount[9:1];  // divide by 2
    assign px_y = vcount[8:1];

endmodule
