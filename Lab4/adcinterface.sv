`define 12_CYCLES 12 

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
        DONE    // ADC_SCL ONE CYCLE STOP TOGGLE
        } state, next_state;
    logic [3:0] count, next_count;


    always_comb begin
        if (count > 0) begin
            next_count = count - 1;
            next_state = state;
        end else begin
            unique case (state)
                H: begin
                    next_state = L;
                    next_count = 1;
                end
                L: begin
                    next_state = WAIT;
                    next_count = 1;
                end
                WAIT: begin
                    next_state = DONE;
                    next_count = 12_CYCLES;
                end
                DONE: begin
                    next_state = H;
                    next_count = 1;
                end
            endcase
    end


    always_ff @(posedge clk) begin
        if (~reset_n) begin
            count <= 4'b0000;
            state <= H;
        end else begin
            count <= next_count;
            state <= next_state;
        end
        

    end



endmodule