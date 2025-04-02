// encoder_tb.sv - Testbench for the encoder module. 
//                 Tests all possible inputs a
// Author: Marcus Fu
// Date: 2025-02-05

`timescale 1ms/1ms

module encoder_tb;

    // Testbench signals
    logic [3:0] a ;
    logic [1:0] y ;
    logic valid ;

    // Instantiate the encoder module
    encoder dut (.*) ;

    initial begin
        // Test all possible combinations for input a
        for (int i = 0; i < 4'b1111; i++) begin
            a = i ;
            #1ms ; // wait for 1 ms
        end

        $stop ; // Stop simulation
    end

endmodule