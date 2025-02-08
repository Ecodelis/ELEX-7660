`define CYCLE_12 12 
`define CYCLE_1 1

module adcinterface(
    input logic clk, reset_n, // clock (1.560 MHz) and reset
    input logic [2:0] chan, // ADC channel to sample
    output logic [11:0] result, // ADC result
    
    // ltc2308 signals
    output logic ADC_CONVST, ADC_SCK, ADC_SDI,
    input logic ADC_SDO );

    enum logic [1:0] { 
        H,      // ADC_CONVST HIGH
        L,      // ADC_CONVST LOW
        WAIT,   // 12 CYCLES
        STOP    // ADC_SCL ONE CYCLE STOP TOGGLE
        } state, next_state;
    logic [3:0] count, next_count; // count logic for cycle control
    logic [3:0] shift_index, next_shift_index; // shift index for shifting the word into ADC_SDI

    logic [11:0] config_word; // 12-bit configuration word to ADC
    logic [2:0] address_select; // 3-bit address select (Assuming single-ended mode)
    logic OS; // Odd/Sign Bit

    assign ADC_SCK = (state == WAIT) ? clk : 0;

    always_comb begin
        // chan2address (assumes single-ended mode)
        unique case(chan)
            3'b000: address_select = 3'b000; // CH0
            3'b001: address_select = 3'b100; // CH1
            3'b010: address_select = 3'b001; // CH2
            3'b011: address_select = 3'b101; // CH3
            3'b100: address_select = 3'b010; // CH4
            3'b101: address_select = 3'b110; // CH5
            3'b110: address_select = 3'b011; // CH6
            3'b111: address_select = 3'b111; // CH7
        endcase

        if (count > 0) begin
            next_count = count - 1;
            next_state = state;
            
        end else begin
            unique case (state)
                H: begin
                    next_state = L;
                    next_count = `CYCLE_1;
                end
                L: begin
                    next_state = WAIT;
                    next_count = `CYCLE_1;
                end
                WAIT: begin
                    next_state = STOP;
                    next_count = `CYCLE_12;
                end
                STOP: begin
                    next_state = H;
                    next_count = `CYCLE_1;
                end
            endcase
        end

        // Control next_shift_index based on current state
        if (state == WAIT && shift_index > 0) begin
            next_shift_index = shift_index - 1;  // Decrement shift_index after sending the bit
        end else if (state == L) begin
            next_shift_index = 11; // Reset shift index before shifting starts
        end else begin
            next_shift_index = shift_index; // Maintain current shift_index
        end
    end

    always_ff @(posedge clk) begin
        if (~reset_n) begin
            count <= 1;
            result <= 0;
            state <= H;
            ADC_SDI <= 0;
            ADC_CONVST <= 0;
            shift_index <= 11; // Initialize shift_index to 11
        end else begin
            count <= next_count;
            state <= next_state;
            shift_index <= next_shift_index; // Update shift_index only once per clock cycle

            unique case(state)
                H: begin
                    ADC_CONVST <= 1;
                end
                L: begin
                    ADC_CONVST <= 0;

                    // 12-bit configuration word
                    config_word <= {1'b1, address_select, 1'b0, 1'b0, 6'b000000};
                    // S/D = Single-Ended/Differential Bit
                    // O/S = Odd/Sign Bit (acts as extra address bit in single-ended mode)
                    // S1 = Address Select Bit 1
                    // S0 = Address Select Bit 0
                    // UNI = Unipolar/Bipolar Bit
                    // SLP = Sleep Mode Bit
                    // Filler 0 Bits
                end
                WAIT: begin
                    // Shift in the ADC_SDO data every posedge
                    result <= { result[10:0], ADC_SDO };
                end
                STOP: begin
                    ADC_CONVST <= 0;
                end
            endcase
        end
    end

    // Shift the configuration word out on ADC_SDI (falling edge of ADC_SCK)
    always_ff @(negedge clk) begin
        if (state == WAIT && shift_index >= 0) begin
            ADC_SDI <= config_word[shift_index];  // Shift out one bit
        end
    end

endmodule
