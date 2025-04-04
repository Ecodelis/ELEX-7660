// File: fourPhaseHandshake_tb.sv
// Description: Testbench for fourPhaseHandshake.sv. Tests and demonstrates 
//              the transfer of data from one clock domain to another using a four-phase handshake.
// Author: Marcus Fu
// Date: 2024-04-01

`timescale 1ms/1ms

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
        validIn = 0; 
        dataIn = 8'h00;
        
        // Apply reset (active low)
        reset_n = 0;
        #10;
        reset_n = 1;
        #10;
        
        // Test Case 1: Normal Transfer (data = 0xAA)
        // Wait for a short period, then apply validIn while ready is high.
        #15;
        dataIn = 8'hAA;
        validIn = 1;
        // Wait for ready to be high to ensure the DUT can accept the data
        wait(ready == 1);
        #10 validIn = 0;
        // Wait for the transfer to complete
        wait(ready == 0);
        wait(ready == 1);
        

        // Test Case 2: Assert validIn while module is not ready (data = 0xBB)
        // Apply 3 validIn pulses while read is low. This should not do anything
        #15;
        dataIn = 8'hBB;
        validIn = 1;
        // Wait for ready to be high to ensure the DUT can accept the data
        wait(ready == 1);
        repeat(5) #8 validIn = ~validIn;
        validIn = 0;
        // Wait for the transfer to complete
        wait(ready == 0);
        wait(ready == 1);


        // Test Case 3: Normal Transfer after test case 2 (data = 0xF4)
        // Wait for a short period, then apply validIn while ready is high.
        #15;
        dataIn = 8'hF4;
        validIn = 1;
        // Wait for ready to be high to ensure the DUT can accept the data
        wait(ready == 1);
        #10 validIn = 0;
        // Wait for the transfer to complete
        wait(ready == 0);
        wait(ready == 1);

        

        #100;
        $stop;
    end
endmodule
