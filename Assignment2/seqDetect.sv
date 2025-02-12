// File: seqDetect.sv
// Description: Detect a sequence of inputs. If correct, assert valid for 1 cycle
// Author: Marcus Fu
// Date: 2024-02-11

module seqDetect #(parameter N=6)(
    output logic valid,
    input logic a, 
    input logic [N-1:0] seq,
    input logic clk, reset_n
);

    typedef enum logic [1:0] {
        DETECT,     // Detects input 'a' for N clock cycles before testing input sequence
        EQUAL,      // Determine if the input matched the given sequence and assert for 1 cycle
        IDLE        // Reset values for next detection sequence
    } states;

    states state; // State machine state
    logic [2:0] wait_count; // Wait counter for delaying cycles 
    logic [N-1:0] seq_temp; // Temporary sequence storage

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wait_count <= 0;
            valid <= 0;
            state <= DETECT;
            seq_temp <= 0;
        end else begin
            case(state)
                DETECT: begin
                    valid <= 0; // Ensure valid is deasserted in DETECT state
                    if (wait_count < N) begin
                        wait_count <= wait_count + 1;
                        seq_temp <= { seq_temp[N-2:0], a }; // Shift in new value
                    end 

                    if (wait_count == N) begin
                        state <= EQUAL;
                    end
                end

                EQUAL: begin
                    if (seq_temp == seq) begin
                        valid <= 1'b1;
                    end else begin
                        valid <= 1'b0;
                    end
                    state <= IDLE;
                end

                IDLE: begin
                    valid <= 0;
                    wait_count <= 0;
                end

                default: 
                    state <= IDLE; // Reset state if state is invalid
            endcase
        end
    end

endmodule