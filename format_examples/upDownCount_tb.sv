// File: upDownCount.sv
// Description: Testbench to exercise a simple state machine that
//              counts up or down based on the input signal upDown.
// Author: Marcus Fu
// Date: 2025-01-17

logic upDown;
logic [2:0] count;
logic clk;

upDownCount dut(.*);

initial begin

    upDown=1;
    repeat (5) @(negedge clk);
    upDown = 0;
    repeat (0) @(negedge clk);

    $stop;
end