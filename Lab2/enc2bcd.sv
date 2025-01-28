// File: enc2bcd.sv
// Description: Counts up or down every 4 pulses of CW or CCW. Converts binary to decimal.
// Author: Marcus Fu
// Date: 2024-01-18

module enc2bcd (input logic clk, cw, ccw, output logic [7:0] bcd_count) ;

    logic [2:0] cw_pulse_count = 3'd000; // Counts the number of CW pulses
    logic [2:0] ccw_pulse_count = 3'b000; // Counts the number of CCW pulses
    logic cw_pulse = 1'b0; // Clockwise pulse
    logic ccw_pulse = 1'b0; // Counter-clockwise pulse


    always_ff @(posedge clk) begin

        if (cw) begin
            if (cw_pulse_count < 3) begin
                cw_pulse_count = cw_pulse_count + 1;
            end else begin
                cw_pulse_count = 0;
                cw_pulse = 1;
            end
        end

        if (cw_pulse) begin
            cw_pulse = 0;
            cw_pulse_count = 0; // Reset count for next pulse (avoids multiple pulses)

            if (bcd_count < 8'b1001_1001) begin // less than 99


                if (bcd_count[3:0] < 4'b1001) begin // if count < 9, do the following:
                    bcd_count[3:0] = bcd_count[3:0] + 4'b0001; // inc +1
                end


                else begin
                        bcd_count[3:0] = 4'b0000; // reset ones back to 0
                        bcd_count[7:4] = bcd_count[7:4] + 4'b0001; // increase tens
                end


            end else
                bcd_count = bcd_count; // stay at 99

        end

        // FOR COUNTING DOWN
        if (ccw) begin
            if (ccw_pulse_count < 3) begin
                ccw_pulse_count = ccw_pulse_count + 1;
            end else begin
                ccw_pulse_count = 0;
                ccw_pulse = 1;
            end
        end

        if (ccw_pulse) begin
            ccw_pulse = 0;
            ccw_pulse_count = 0; // Reset count for next pulse (avoids stacking pulses due to rotary ripple)

            if (bcd_count > 0) begin // More than 0


                if (bcd_count[3:0] > 0) begin // if count > 0, do the following:
                    bcd_count[3:0] = bcd_count[3:0] - 4'b0001; // inc -1
                end


                else begin
                        bcd_count[3:0] = 4'b1001; // reset ones back to 9
                        bcd_count[7:4] = bcd_count[7:4] - 4'b0001; // decrease tens
                end


            end else
                bcd_count = bcd_count; // stay at 99

        end
    end

endmodule