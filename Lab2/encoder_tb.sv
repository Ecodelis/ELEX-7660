// File: encoder_tb.svA
// Description: Testbench to check functionality of the lab2 encoder module
// Author: Robert Trost 
// Date: 2024-01-15


// function: check_value()
// description: check to see that expected value matches actual value.  
// Returns '1' if test fails, '0' for pass
function logic check_value (int expected_value, int actual_value);

    if (expected_value != actual_value) begin
        $display("FAIL: expected value is %d => actual value is %d", expected_value, actual_value) ;
        check_value = 1;
    end else
        check_value = 0;

endfunction

module encoder_tb;

logic a, b, cw, ccw;  // signals to connect to encoder
logic clk = 0; // clock signal

int encoder_count = 0 ; // count to track encoder output
int expected_count = 0 ; // expected encoder count

logic [1:0] encoderAB_seq [4] = '{2'b00, 2'b10, 2'b11, 2'b01};  // define sequence of rotary encoder "AB" outputs
logic [1:0] index = 0;  // index into encoder sequence

logic tb_fail = 0; // flag to track if testbench failed

// device under test
encoder dut (.*);

initial begin

    repeat(3) @(negedge clk) ;  // wait two clock cycles

    tb_fail |= check_value (expected_count, encoder_count);  // check counts match

    // simulate 6 turns in the clockwise direction
    for ( int i = 0 ; i < 6 ; i++ ) begin

        // simulate clockwise turn
        index++;
        expected_count++;

        repeat(3) @(negedge clk) ; // wait two clock cycles

        tb_fail |= check_value (expected_count, encoder_count); // check counts match


    end

    // simulate 6 turns in the counter-clockwise direction
    for ( int i = 0 ; i < 6 ; i++ ) begin

        // simulate counter-clockwise turn
        index--;
        expected_count--;

        repeat(3) @(negedge clk) ; // wait two clock cycles

        tb_fail |= check_value (expected_count, encoder_count); // check counts match

    end

    if (tb_fail)
        $display("Lab 2 Encoder Simulation *** FAILED ***  See transcript for details") ;
    else
        $display("Lab 2 Encoder Simulation *** PASSED ***") ;

    $stop;

end

// generate encoder AB outputs
assign { a, b } = encoderAB_seq[index];

// encoder output count, +1 for each clockwise pulse, -1 for each counter-clockwise pulse
always begin
    @(negedge clk) ;  // wait for falling clock edge
    if (cw) encoder_count++;
    if (ccw) encoder_count--;
end

// generate 50 MHz clock
always
    #20ns clk = ~clk ;

endmodule