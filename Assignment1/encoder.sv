// encoder.sv - Priority encoder module for ELEX 7660 Assignment 1
// Author: Marcus Fu
// Date: 2025-02-05

module encoder (
    output logic [1:0] y, 
    output logic valid, 
    input logic [3:0] a
);

    always_comb begin
        // Default assignments if input is 0000
        y = 2'b00;
        valid = 1'b0;

        priority case (1'b1)
            (a == 4'b0001): begin
                y = 2'b00;
                valid = 1'b1;
            end
            ((a & 4'b1110) == 4'b0010): begin // Match: 001x
                y = 2'b01;
                valid = 1'b1;
            end
            ((a & 4'b1100) == 4'b0100): begin // Match: 01xx
                y = 2'b10;
                valid = 1'b1;
            end
            ((a & 4'b1000) == 4'b1000): begin // Match: 1xxx
                y = 2'b11;
                valid = 1'b1;
            end
        endcase
    end

endmodule
