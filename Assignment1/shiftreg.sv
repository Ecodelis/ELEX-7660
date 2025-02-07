// shiftreg.sv - Shift register module for ELEX 7660 Assignment 1
// Author: Marcus Fu
// Date: 2025-02-05

module shiftreg (
    output logic [7:0] q,
    input logic [7:0] a, 
    input logic [1:0] s,
    input logic shiftIn, clk, reset_n);


    always_ff @(posedge clk or negedge reset_n) begin
        if (reset_n == 0)
            q <= 8'b0; // Reset to 0
        else begin
            unique case (s)
                2'b00: q <= a;                 // Parallel load
                2'b01: q <= {shiftIn, q[7:1]}; // Shift right
                2'b10: q <= {q[6:0], shiftIn}; // Shift left
                2'b11: q <= q;                 // Hold
            endcase
        end
    end
endmodule