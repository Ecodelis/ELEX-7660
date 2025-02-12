// File: enc2chan.sv
// Description: encoder to ADC channel module. Converts the encoder output to 
// select a channel for the ADC
// Author: Marcus Fu
// Date: 2024-02-03

module enc2chan
    ( input logic cw, ccw, // outputs from lab 2 encoder module
    output logic [2:0] chan, // desired frequency
    input logic reset_n, clk); // reset and clock

    logic [2:0] cw_pulse_count = 3'd000; // Counts the number of CW pulses
    logic [2:0] ccw_pulse_count = 3'b000; // Counts the number of CCW pulses
    logic [3:0] bcd_count = 4'b0000; // BCD count 

    logic [3:0] max_count = 4'b0101; // Max count
    logic [3:0] min_count = 4'b0000; // Min count

    always_ff @(posedge clk) begin

        if (reset_n == 0) begin
            bcd_count <= 4'b0000; // Reset count
            cw_pulse_count <= 0;
            ccw_pulse_count <= 0;
        end else begin

            // Counting Up
            if (cw) begin 
                if (cw_pulse_count < 3) begin
                    cw_pulse_count <= cw_pulse_count + 1;
                end else begin
                    cw_pulse_count <= 0; // Reset when 4 pulses are counted
                    if (bcd_count < max_count) begin // If count < max_count
                        bcd_count <= bcd_count + 4'b0001; // Increment +1
                    end
                end
            end

            // Counting Down
            if (ccw) begin
                if (ccw_pulse_count < 3) begin
                    ccw_pulse_count <= ccw_pulse_count + 1;
                end else begin
                    ccw_pulse_count <= 0; // Reset when 4 pulses are counted
                    if (bcd_count > min_count) begin // If count > min_count
                        bcd_count <= bcd_count - 4'b0001; // Decrement -1
                        end
                    end
                end
        end
    end



    always_comb begin
        chan = 0; // Default value

        unique case (bcd_count)
            4'b0000: chan = 3'b000; // 0
            4'b0001: chan = 3'b001; // 1
            4'b0010: chan = 3'b010; // 2
            4'b0011: chan = 3'b011; // 3
            4'b0100: chan = 3'b100; // 4
            4'b0101: chan = 3'b101; // 5
            4'b0110: chan = 3'b110; // 6
            4'b0111: chan = 3'b111; // 7
        endcase
    end

endmodule