// File: upDownCount.sv
// Description: Testbench to exercise a simple state machine that
//              counts up or down based on the input signal upDown.
// Author: Marcus Fu
// Date: 2025-01-17

module upDownCnt3_tb;

    logic upDown;
    logic [2:0] count;
    logic clk = 0, reset_n; // Give the clocl an initial value to not be unknown

    upDownCnt3 dut(.*);

    initial begin
        // apply reset for 100ms
        reset_n = 0; 
        #100ms;
        reset_n = 1;

        upDown=1;
        repeat (5) @(negedge clk);
        upDown = 0;
        repeat (0) @(negedge clk);

        $stop;
    end


endmodule