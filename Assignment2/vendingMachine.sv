// File: vendingMachine.sv
// Description: Code to simulate a vending machine. Takes in a nickle,
//              dime, or quarter one by one or in parallel. Resets when $1.00 is reached.
// Author: Marcus Fu
// Date: 2024-02-11

module vendingMachine (
    output logic valid,
    input logic nickel, dime, quarter,
    input logic clk, reset_n
    );

    typedef enum logic [1:0] {
        DETECT,     // Detects coins
        DISPENSE,   // Determine if $1.00 has been achieved, raises valid for 1 cycle
        RESET       // Reset values for next detection sequence
    } states;

    states state; // State machine state
    logic [6:0] coin; // Amount in the vending machine

    always_ff @(posedge clk) begin
        if (!reset_n) begin
            coin <= 7'b0000000;
            valid<= 1'b0;
            state <= DETECT;
        end 

        else if (state == RESET) begin 
            coin <= 7'b0000000;
            valid <= 1'b0;
            state <= DETECT;
        end
        
        else if (state == DETECT) begin // Detect coins and increment coin value

            if (nickel) begin
                coin <= coin + 5;
            end

            if (dime) begin
                coin <= coin + 10;
            end

            if (quarter) begin
                coin <= coin + 25;
            end

            if (coin == 100) begin // Dispense
                state <= RESET;
                valid <= 1'b1;
            end
        end
    end



endmodule