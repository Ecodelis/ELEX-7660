// File: adcinterface.sv
// Description: Interfaces with the ADC to sample the desired channel
// Author: Marcus Fu
// Date: 2024-02-9

module adcinterface(
    input logic clk, reset_n, // clock (1.560mhz) and active-low reset
    input logic [2:0] chan, // ADC channel to sample
    output logic [11:0] result, // ADC result
    // ltc2308 signals
    output logic ADC_CONVST, ADC_SCK, ADC_SDI,
    input logic ADC_SDO
    );

    enum logic [1:0] {
        INIT_CONV,     // Initialize conversion (e.g., assert ADC_CONVST)
        LOW_CONV,      // Conversion signal low
        DATA_TRANSFER, // Data transfer state
        PAUSE_SCK      // Pause state for SCK
    } state, next_state;

    // State Machine Signals
    logic [3:0] delay, next_delay;  // Delay counter
    logic [2:0] shift_count;  // Shift counter for ADC_SDI
    logic [2:0] shift_count_SDO;  // Shift counter for ADC_SDO


    // ADC Interface Signals
    logic [5:0] config_word;  // 6-bit Configuration word for ADC
    logic [11:0] temp_result;  // Temporary store result for ADC
    logic enable_sck;  // Gate clk signal
    

//---------------------------------------------------------
// --- STATE MACHINE LOGIC SECTION ---
//---------------------------------------------------------

    // On every posedge clk, if delay reaches 0, update state and reload delay.
    always_ff @(posedge clk) begin
        if (reset_n == 0) begin
            state <= INIT_CONV;
            enable_sck <= 0; // Disable SCK signal
            ADC_CONVST <= 1;
            result <= 0;
            delay <= 0;
        end else begin
            if (delay <= 1) begin // If delay reaches 1, update state in this cycle, and change state in the next cycle
                state <= next_state; // Update state
                delay <= next_delay; // Load in delay for the next state
            end else begin
                delay <= delay - 1;
            end
        end

        if (state == INIT_CONV) begin
            ADC_CONVST <= 1; // Assert ADC_CONVST (starts conversion)
        end

        else if (state == LOW_CONV) begin
            ADC_CONVST <= 0; // Deassert ADC_CONVST

            shift_count_SDO <= 11; // Load shift count for ADC_SDO  

            config_word <= {1'b1, chan[0], chan[2:1], 1'b1, 1'b0};
        end

        else if (state == DATA_TRANSFER) begin
            // 6-bit configuration word
            // S/D = Single-Ended/Differential Bit
            // O/S = Odd/Sign Bit (acts as extra address bit in single-ended mode)
            // S1 = Address Select Bit 1
            // S0 = Address Select Bit 0
            // UNI = Unipolar/Bipolar Bit
            // SLP = Sleep Mode Bit
            // Filler 0 Bits
    
            // Shift in data from ADC_SDO
            if (shift_count_SDO >= 0) begin
                temp_result <= {temp_result[10:0], ADC_SDO};

                shift_count_SDO <= shift_count_SDO - 1;
            end

            enable_sck<= 1; // Enable SCK signal
        end
        
        else begin
            enable_sck<= 0; // Disable SCK signal
            if (temp_result) // if there is data in temp_result
                result <= temp_result; // Load in result
        end
    end

    // Next State Combinational Logic
    always_comb begin
        // Default next_state assignment
        next_state = state;

        case (state)
            INIT_CONV: begin
                next_state = LOW_CONV;
                next_delay = 1;  // Load 1 cycle delay for the next state
            end
            LOW_CONV: begin
                next_state = DATA_TRANSFER;
                next_delay = 12;  // Load 12 cycle delay for the next state
            end
            DATA_TRANSFER: begin
                next_state = PAUSE_SCK;
                next_delay = 1;  // Load 1 cycle delay for the next state
            end
            PAUSE_SCK: begin
                next_state = INIT_CONV;
                next_delay = 1;  // Load 1 cycle delay for the next state
            end
            default: next_state = INIT_CONV;
        endcase
    end

//---------------------------------------------------------
// --- ADC INTERFACE LOGIC SECTION ---
//---------------------------------------------------------

    // Enable SCK signal during DATA_TRANSFER state
    assign ADC_SCK = (enable_sck) ? clk : 0; // SCK is high during DATA_TRANSFER state

    always_ff @(negedge clk) begin
        if (reset_n == 0) begin
            ADC_SDI <= 0; // Load shift count for ADC_SDI
            shift_count <= 5; // Load shift count for ADC_SDI
        end
        else if (state == LOW_CONV) begin
            shift_count <= 5; // Load shift count for ADC_SDI (MSB)
        end
        else if (state == DATA_TRANSFER) begin
            if (shift_count > 0) begin
            // Shift in address and start conversion from MSB to LSB
            ADC_SDI <= config_word[shift_count];

            // Decrement shift count (next cycle)
            shift_count <= shift_count - 1;
            end else begin
                // do nothing
                
                ADC_SDI <= 0; // Load in 0 after all bits have been shifted
            end

        end
    end
endmodule
