// enc2freq_tb.sv - testbench the enc2freq module
// test if cw and ccw pulses properly adjust frequency output
// Author: Marcus Fu
// Date: 2025-02-01

`timescale 1ms/1ms

module enc2freq_tb;

    // Testbench signals
    logic cw, ccw;
    logic reset_n, clk;
    logic [31:0] freq;

    // Instantiate the enc2freq module as dut
    enc2freq dut (
        .cw(cw),
        .ccw(ccw),
        .freq(freq),
        .reset_n(reset_n),
        .clk(clk)
    );

    // Clock generation (20Hz)
    always begin
        #25ms clk = ~clk;
    end

    initial begin
        // Initialize signals for testing
        clk = 0;
        reset_n = 0;
        cw = 0;
        ccw = 0;

        // reset module
        reset_n = 0 ;
        repeat(2) @(negedge clk) ;
        reset_n = 1 ;

        // Test case: Increment bcd_count by generating CW pulses
        repeat (4) begin
            cw = 1;
            repeat(5) @(negedge clk) ; 
            cw = 0;
            repeat(5) @(negedge clk) ;
        end

        // Test case: Decrement bcd_count by generating CCW pulses
        repeat (3) begin
            ccw = 1;
            repeat(5) @(negedge clk) ; 
            ccw = 0;
            repeat(5) @(negedge clk) ;
        end

        // Test case: Increment bcd_count beyond 7 to check upper bound
        repeat (10) begin
            cw = 1;
            repeat(5) @(negedge clk) ; 
            cw = 0;
            repeat(5) @(negedge clk) ;
        end

        // Test case: Decrement bcd_count beyond 0 to check lower bound
        repeat (10) begin
            ccw = 1;
            repeat(5) @(negedge clk) ; 
            ccw = 0;
            repeat(5) @(negedge clk) ;
        end

        $stop;
    end

endmodule
