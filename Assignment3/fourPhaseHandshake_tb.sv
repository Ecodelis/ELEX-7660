// File: fourPhaseHandshake.sv
// Description: Test bench for fourPhaseHandshake.sv. Tests and demonstrates 
//              the transfer of data from one clock domain to another.
// Author: Marcus Fu
// Date: 2024-02-11

// Testbench
module fourPhaseHandshake_tb;
    logic clk1, clk2, reset; // clock signals and reset signal
    logic ready, validIn, validOut; // handshake signals
    logic [7:0] dataIn, dataOut; // data signals
    
    fourPhaseHandshake #(.N(3)) dut (.*); // Instantiate the DUT
    
    always #5 clk1 = ~clk1; // 10 ns period for clk1
    always #7 clk2 = ~clk2; // 14 ns period for clk2
    
    initial begin
        clk1 = 0; clk2 = 0; reset = 1; validIn = 0; dataIn = 0;
        #20 reset = 0;
        
        // Test Case 1: Transfer data 0xAA
        #15 dataIn = 8'hAA; validIn = 1;
        #10 validIn = 0;
        
        // Test Case 2: Transfer data 0x55
        #30 dataIn = 8'h55; validIn = 1;
        #10 validIn = 0;
        
        #100 $stop;
    end
endmodule
