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
    } state = PAUSE_SCK, next_state;

    // State Machine Signals
    logic [3:0] delay, next_delay;  // Delay counter


    // ADC Interface Signals
    logic [5:0] config_word;  // 6-bit Configuration word for ADC
    logic [2:0] address_select;  // Address select for ADC (assuming single-ended mode)
    logic [2:0] shift_count;  // Shift counter for ADC_SDI
    logic [2:0] shift_count_SDO;  // Shift counter for ADC_SDO
    logic enable_sck;  // Gate clk signal
    

//---------------------------------------------------------
// --- STATE MACHINE LOGIC SECTION ---
//---------------------------------------------------------

    // On every posedge clk, if delay reaches 0, update state and reload delay.
    always_ff @(posedge clk) begin
        if (reset_n == 0) begin
            state <= PAUSE_SCK;
            ADC_CONVST <= 0;
            ADC_SDI <= 0;
            result <= 0;
            delay <= 0;
            shift_count <= 5; // Load shift count for ADC_SDI
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

            shift_count <= 5; // Load shift count for ADC_SDI (MSB)

            shift_count_SDO <= 11; // Load shift count for ADC_SDO  

            config_word <= {1'b1, address_select, 1'b0, 1'b0}; // Load in config while data transfer
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
                result <= {ADC_SDO, result[11:1]};

                shift_count_SDO <= shift_count_SDO - 1;
            end

            enable_sck<= 1; // Enable SCK signal
        end
        
        else begin
            ADC_CONVST <= 0; // safety measure
            enable_sck<= 0; // Disable SCK signal
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

    // Address Select Combinational Logic
    always_comb begin
        // chan2address (assumes single-ended mode)
        case(chan)
            3'b000: address_select = 3'b000; // CH0
            3'b001: address_select = 3'b100; // CH1
            3'b010: address_select = 3'b001; // CH2
            3'b011: address_select = 3'b101; // CH3
            3'b100: address_select = 3'b010; // CH4
            3'b101: address_select = 3'b110; // CH5
            3'b110: address_select = 3'b011; // CH6
            3'b111: address_select = 3'b111; // CH7
            default: address_select = 3'b000; // Default to CH0
        endcase
    end

    always_ff @(negedge clk) begin
        if (reset_n) begin
            ADC_SDI <= 0; // Load shift count for ADC_SDI
        end
        else if (state == DATA_TRANSFER) begin
            if (shift_count >= 0) begin
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
