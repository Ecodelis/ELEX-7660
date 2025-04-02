// File: fourPhaseHandshake.sv
// Description: Transfers data from one clock domain to another using a four-phase handshake
//              protocol with internal req/ack signals and double-flop synchronizers.
// Author: Marcus Fu
// Date: 2024-04-01

module fourPhaseHandshake #(parameter N = 8)(
    // clk1 domain signals
    input  logic clk1, reset_n,       // reset_n is active low
    input  logic [N-1:0] dataIn,
    input  logic validIn,
    output logic ready,               // Indicates the module is ready to accept data

    // clk2 domain signals
    input  logic clk2,
    output logic [N-1:0] dataOut,
    output logic validOut             // Asserted for one clk2 cycle when new data is available
);

    typedef enum logic [1:0] {
        IDLE,       // Waiting for validIn to be asserted and ready to accept new data.
        TRANSFER,   // Data is captured and req is asserted.
        WAIT_ACK    // Waiting for ack from the clk2 domain.
    } state_t;

    state_t state, next_state; 
    logic [N-1:0] dataReg; // Register to hold the data being transferred.

    // Handshake signals (generated in each domain)
    logic req;         // req: Generated in clk1 to request data transfer.
    logic req_sync;    // req_sync: Synchronized version of req in the clk2 domain.
    logic ack;         // ack: Generated in clk2 to acknowledge data reception.
    logic ack_sync;    // ack_sync: Synchronized version of ack in the clk1 domain.

    // State register (clk1 domain)
    always_ff @(posedge clk1 or negedge reset_n) begin
        if (!reset_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Next-state logic (clk1 domain)
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                // If validIn is high and the module is ready, capture data and generate req.
                if (validIn && ready)
                    next_state = TRANSFER;
            end
            TRANSFER: begin
                // After asserting req, move to waiting for ack.
                next_state = WAIT_ACK;
            end
            WAIT_ACK: begin
                // Once the ack is received (synchronized from clk2), return to IDLE.
                if (ack_sync)
                    next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    // Data capture, ready signal, and req generation in clk1 domain.
    always_ff @(posedge clk1 or negedge reset_n) begin
        if (!reset_n) begin
            dataReg <= '0;
            ready   <= 1;  // Initially ready to accept data.
            req     <= 0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1;
                    if (validIn && ready) begin
                        dataReg <= dataIn; // Capture incoming data.
                        req <= 1;          // Generate a one-cycle req pulse.
                        ready <= 0;        // Not ready for new data until transfer completes.
                    end
                end
                TRANSFER: begin
                    // Deassert req after one cycle.
                    req <= 0;
                    ready <= 0;
                end
                WAIT_ACK: begin
                    // Maintain ready low until ack is received.
                    ready <= 0;
                end
                default: begin
                    req <= 0;
                    ready <= 1;
                end
            endcase
        end
    end

    // Synchronize req from clk1 domain to clk2 domain (Double Flop)
    logic req_ff1;
    always_ff @(posedge clk2 or negedge reset_n) begin
        if (!reset_n) begin
            req_ff1  <= 0;
            req_sync <= 0;
        end else begin
            req_ff1  <= req;
            req_sync <= req_ff1;
        end
    end

    // clk2 Domain: Data Transfer and ack Generation
    always_ff @(posedge clk2 or negedge reset_n) begin
        if (!reset_n) begin
            dataOut  <= '0;
            validOut <= 0;
            ack      <= 0;
        end else begin
            if (req_sync) begin
                // When a synchronized req is detected, capture the data.
                dataOut  <= dataReg; // dataReg is assumed to be stable due to handshake.
                validOut <= 1;       // Assert validOut for one clk2 cycle.
                ack      <= 1;       // Generate an ack pulse.
            end else begin
                validOut <= 0;
                ack <= 0;
            end
        end
    end

    // Synchronize ack from clk2 domain back to clk1 domain (Double Flop)
    logic ack_ff1;
    always_ff @(posedge clk1 or negedge reset_n) begin
        if (!reset_n) begin
            ack_ff1  <= 0;
            ack_sync <= 0;
        end else begin
            ack_ff1  <= ack;
            ack_sync <= ack_ff1;
        end
    end

endmodule
