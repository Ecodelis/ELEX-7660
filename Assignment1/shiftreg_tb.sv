// shiftreg_tb.sv - Testbench for the encoder module. 
//                  Tests all possible combinations of inputs
// Author: Marcus Fu
// Date: 2025-02-05

`timescale 1ms/1ms

module shiftreg_tb;

    // Testbench signals
    logic [7:0] q;
    logic [7:0] a; 
    logic [1:0] s;
    logic shiftIn, clk, reset_n;

    // Instantiate the encoder module
    shiftreg dut (.*) ;

    // Clock generation
    always #5 clk = ~clk; 

    initial begin

        clk = 1'b0;
        shiftIn = 1'b0;
        s = 2'b00;
        a = 8'b10101010;

        // reset
        reset_n = 0 ;
        @(negedge clk) ;
        reset_n = 1 ;

        s = 2'b00; // Load a into q
        @(negedge clk) ;
        s = 2'b01; // shift right w/ shiftIn = 0
        @(negedge clk) ;
        s = 2'b11; // hold
        @(negedge clk) ;
        shiftIn = 1'b1;
        s = 2'b10; // shift left w/ shiftIn = 1
        @(negedge clk) ;

        $stop ; // Stop simulation
    end

endmodule