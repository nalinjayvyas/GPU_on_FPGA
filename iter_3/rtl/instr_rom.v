module instr_rom(
    input [7:0] addr, 
    output [15:0] dout
);
reg [15:0] temp;

    always @(*) begin
        case(addr)
           // 0. LOAD BASE: 50 (Hex 32). Safe low value.
            8'd0: temp = 16'b0111_0001_0011_0010; 

            // 1. ADD LANE IDs: Staggers the heights
            8'd1: temp = 16'b0001_0001_0001_1110;

            // 2. ADD BUTTONS: Moves them up/down
            8'd2: temp = 16'b0001_0001_0001_1100;

            // 3. NOP (No shifting, no subtracting - keep it stable)
            8'd3: temp = 16'b0000_0000_0000_0000; 

            // 4. DISPLAY DUMMY: Output v1
            8'd4: temp = 16'b0001_0000_0001_0000;

            // 5. LOOP: Restart
            8'd5: temp = 16'b1111_0000_0000_0000;

            default: temp = 16'b0;
        endcase
    end
assign dout = temp;
endmodule