// File: vendingMachine_tb.sv
// Description: Test bench for vendingMachine.sv. Tests all possible coin inputs and valid outputs
// Author: Marcus Fu
// Date: 2024-02-11


module vendingMachine_tb;

    `timescale 1ms/1ms // Time unit: 1ms, Precision: 1ms


    // Testbench signals
    logic nickel = 0, dime = 0, quarter = 0;
    logic valid = 0;
    logic clk = 0;
    logic reset_n;

    // Clock generation
    always #1 clk = ~clk; 

    vendingMachine dut (.*);

    // Assert a signal for one clock cycle
    task automatic single_coin(ref logic signal);
        begin
            signal = 1;
            @(posedge clk);
            signal = 0;
            @(posedge clk);
        end
    endtask

    task automatic multi_coin(ref logic signal1, signal2);
        begin
            signal1 = 1;
            signal2 = 1;
            @(posedge clk);
            signal1 = 0;
            signal2 = 0;
            @(posedge clk);
        end
    endtask


    initial begin
        reset_n = 0;
        repeat(5) @(posedge clk);
        reset_n = 1;

        // Test nickel, dime, quarter
        single_coin(nickel);
        single_coin(dime);
        single_coin(quarter);

        // test multiple coins
        multi_coin(nickel, dime);
        multi_coin(quarter, dime);        

        // Test quarter
        single_coin(dime);
        single_coin(quarter); // should be $1.15


        repeat(3) @(posedge clk); // Delay 3 clock cycles to allow valid to be asserted

        // See if a quarter can be detected after $1.00
        single_coin(quarter);

        $stop; // Stop simulation

    end




endmodule