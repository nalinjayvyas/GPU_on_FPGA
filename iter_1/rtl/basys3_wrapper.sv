module basys3_wrapper(
    input  wire clk,         // 100 MHz Oscillator on Basys3
    input  wire btnC,        // Center Button (Reset)
    
    // Physical VGA Pins
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue,
    output wire Hsync,
    output wire Vsync
);

    // -----------------------------------------------------------
    // 1. Clock Divider (100 MHz -> 25 MHz)
    // -----------------------------------------------------------
    // We need to divide by 4. A 2-bit counter: 00, 01, 10, 11...
    // The MSB (bit 1) toggles every 2 cycles high / 2 cycles low.
    // 100MHz / 4 = 25MHz.
    reg [1:0] clk_counter = 0;
    reg clk_25mhz_int = 0;

    always @(posedge clk) begin
        clk_counter <= clk_counter + 1;
        clk_25mhz_int <= clk_counter[1];
    end

    // -----------------------------------------------------------
    // 2. Instantiate Your GPU Core
    // -----------------------------------------------------------
    // Internal 8-bit color signals
    wire [7:0] core_r, core_g, core_b;
    wire core_hsync, core_vsync;

    top_gpu gpu_core (
        .clk_25mhz(clk_25mhz_int),
        .rst(btnC),               // Button pressed = Reset
        .hsync(core_hsync),
        .vsync(core_vsync),
        .vga_r(core_r),
        .vga_g(core_g),
        .vga_b(core_b)
    );

    // -----------------------------------------------------------
    // 3. Map Outputs to Physical Pins
    // -----------------------------------------------------------
    assign Hsync = core_hsync;
    assign Vsync = core_vsync;

    // Basys3 has 4 bits per color. We take the 4 Most Significant Bits.
    // This drops the lower precision bits but keeps the color roughly correct.
    assign vgaRed   = core_r[7:4];
    assign vgaGreen = core_g[7:4];
    assign vgaBlue  = core_b[7:4];

endmodule