// File: fourPhaseHandshake_tb.sv
// Description: Testbench for fourPhaseHandshake.sv. Tests and demonstrates 
//              the transfer of data from one clock domain to another using a four-phase handshake.
// Author: Marcus Fu
// Date: 2024-04-01

module fourPhaseHandshake_tb;
    // Declare clocks, reset, handshake signals, and data signals
    logic clk1, clk2, reset_n; // Note: reset_n is active low
    logic validIn;
    logic [7:0] dataIn;
    logic ready, validOut;
    logic [7:0] dataOut;
    
    // Instantiate the DUT with parameter N=8 (8-bit data)
    fourPhaseHandshake #(.N(8)) dut (
        .clk1(clk1),
        .clk2(clk2),
        .reset_n(reset_n),
        .validIn(validIn),
        .dataIn(dataIn),
        .ready(ready),
        .validOut(validOut),
        .dataOut(dataOut)
    );
    
    // Clock generation: 10 ns period for clk1 and 14 ns period for clk2.
    always #5 clk1 = ~clk1; 
    always #7 clk2 = ~clk2; 
    
    // Testbench stimulus
    initial begin
        // Initialize signals
        clk1 = 0; 
        clk2 = 0; 
        reset_n = 1; 
        validIn = 0; 
        dataIn = 8'h00;
        
        // Apply reset (active low)
        #10;
        reset_n = 0;
        #20;
        reset_n = 1;
        
        // Test Case 1: Normal Transfer (data = 0xAA)
        // Wait for a short period, then apply validIn while ready is high.
        #15;
        dataIn = 8'hAA;
        validIn = 1;
        #10 validIn = 0;
        
        // Test Case 2: Back-to-Back Transfer (data = 0x55)
        // After some delay, send new data.
        #30;
        dataIn = 8'h55;
        validIn = 1;
        #10 validIn = 0;
        
        // Test Case 3: Assert validIn while module is not ready.
        // The DUT should ignore this transfer.
        #20;
        dataIn = 8'hFF;
        validIn = 1;
        // Hold validIn briefly; if ready is low, it should be ignored.
        #5 validIn = 0;
        
        // Test Case 4: Transfer after delay (data = 0x0F)
        // This ensures the module recovers and is ready again.
        #40;
        dataIn = 8'h0F;
        validIn = 1;
        #10 validIn = 0;
        
        #100;
        $stop;
    end
endmodule
