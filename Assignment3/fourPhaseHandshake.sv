// File: fourPhaseHandshake.sv
// Description: Transfers data from one clock domain to another using a four-phase handshake
//              protocol with internal req/ack signals and double-flop synchronizers.
// Author: Marcus Fu
// Date: 2024-04-01

module fourPhaseHandshake #(parameter N=8)(
    input logic clk1, clk2, reset_n, validIn,
    input logic [N-1:0] dataIn,
    output logic validOut, ready,
    output logic [N-1:0] dataOut
);

    typedef enum logic [1:0] {
        IDLE,       // Waiting for validIn to be asserted
        TRANSFER,   // Transfer data from clk1 to clk2 domain
        DONE        // De-assert req/ack and return to IDLE at the end
    } state_data; 
    
    state_data state, next_state; // State machine state and next state
    logic [N-1:0] dataReg;  // Temp storage in clk1 domain

    // Handshake signals (req and ack)
    logic req, req_sync1, req_sync2;  // req signal with double flip-flop synchronizers
    logic ack, ack_sync1, ack_sync2;  // ack signal with double flip-flop synchronizers

    // State register (synchronous to clk1)
    always_ff @(posedge clk1 or negedge reset_n) begin
        if (!reset_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next-state logic [Conditions needed to switch to next state] (clk1 domain)
    always_comb begin
        next_state = state;
        case (state)
            IDLE: 
                if (validIn && !req) next_state = TRANSFER;  
            TRANSFER: 
                if (ack_sync2) next_state = DONE;
            DONE: 
                if (!ack_sync2) next_state = IDLE;  // Return to IDLE when ack is de-asserted
        endcase
    end

    // CLK1 Domain Logic
    always_ff @(posedge clk1 or negedge reset_n) begin
        if (!reset_n) begin
            dataReg <= 0;
            ready <= 1;  // Ready to accept data when reset is active
            req <= 0;    // No request by default
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1;  // Ready to accept data
                    if (validIn && ready) begin
                        dataReg <= dataIn;  // Store incoming data
                        req <= 1;  // Assert req to request data transfer
                        ready <= 0;  // Stop accepting new data once data is captured
                    end
                end
                TRANSFER: begin
                    ready <= 0;  // Ready is de-asserted during transfer
                end
                DONE: begin
                    req <= 0;  // Deassert req
                end
            endcase
        end
    end

    // (Double Flop): Synchronize req from clk1 domain to clk2 domain 
    always_ff @(posedge clk2 or negedge reset_n) begin
        if (!reset_n) begin
            req_sync1 <= 0;
            req_sync2 <= 0;
        end else begin
            req_sync1 <= req;     // First flip-flop to synchronize the req signal
            req_sync2 <= req_sync1; // Second flip-flop to avoid metastability
        end
    end

    // CLK2 Domain Logic
    always_ff @(posedge clk2 or negedge reset_n) begin
        if (!reset_n) begin
            dataOut  <= 0;
            validOut <= 0;
            ack      <= 0;  // De-assert ack by default
        end else begin
            if (req_sync2) begin  // When synchronized req is detected
                dataOut  <= dataReg; // Transfer data to clk2 domain
                validOut <= 1;       // Assert validOut for one clk2 cycle
                ack      <= 1;       // Generate ack pulse to acknowledge data receipt
            end else begin
                validOut <= 0;
                ack <= 0;
            end
        end
    end

    // (Double Flop): Synchronize ack from clk2 domain back to clk1 domain
    always_ff @(posedge clk1 or negedge reset_n) begin
        if (!reset_n) begin
            ack_sync1 <= 0;
            ack_sync2 <= 0;
        end else begin
            ack_sync1 <= ack;     // First flip-flop to synchronize the ack signal
            ack_sync2 <= ack_sync1; // Second flip-flop to avoid metastability
        end
    end

endmodule
