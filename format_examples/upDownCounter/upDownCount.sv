// File: upDownCount.sv
// Description: Simple state machine that counts up or down based
//              on the input signal upDown.
// Author: Marcus Fu
// Date: 2025-01-17

module upDownCnt3 ( input logic upDown, // signal to determine direction of count
                    output logic [2:0] count, // current count
                    input logic clk, reset_n) ; // clock signal and reset_not (active low)

logic [2:0] nextCount; // signal to determine next state

always_comb begin
    if (upDown = 1'b1) // If the signal is high, count up, else, count down
        nextCount = count + 1;
    else
        nextCount = count - 1;
end

always_ff @(posedge clk) begin
    // if (~reset_n)
    //     count <= 3'b0;
    // else
    //     count <= nextCount;


    ~reset_n ? count <= 3'b0 : count <= nextCount;
end

endmodule