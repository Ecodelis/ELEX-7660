// File: lab4.sv
// Description: ELEX 7660 lab1 top-level module. Generates C major scale
//						tones through the speaker as the rotary is turned.
// Author: Robert Trost 
// Updated by: Marcus Fu
// Date: 2024-02-07

module lab4 ( input logic CLOCK_50,       				// 50 MHz clock
			(* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) input logic 
			enc1_a, enc1_b, 										// Encoder 1 pins
            input logic s1,         						// pushbuttons
			input logic ADC_SDO,         						// ADC serial data output
			output logic ADC_CONVST, ADC_SCK, ADC_SDI, 	// ADC control signals

            output logic [7:0] leds,    				// 7-seg LED enables
            output logic [3:0] ct ) ;    				// digit cathodes

   logic [1:0] digit;  // select digit to display
   logic [3:0] disp_digit;  // current digit of count to display
   logic [15:0] clk_div_count; // count used to divide clock
   logic [2:0] chan = 0; // frequency to input
   logic [11:0] result, led_result; // ADC result
   logic onOff = 0; // 1 -> generate output, 0 -> no output
   logic reset_n = 0; // reset signal

   logic [7:0] enc1_count, enc2_count; // count used to track encoder movement and to display
   logic enc1_cw, enc1_ccw, enc2_cw, enc2_ccw;  // encoder module outputs

   // instantiate modules to implement design
   decode2 decode2_0 (.digit(digit), .ct(ct));

   decode7 decode7_0 (.num(disp_digit), .leds(leds));

   encoder encoder_1 (.clk(CLOCK_50), .a(enc1_a), .b(enc1_b), .cw(enc1_cw), .ccw(enc1_ccw));

   enc2chan enc2chan_1 (.cw(enc1_cw), .ccw(enc1_ccw), .chan(chan), .reset_n(reset_n), .clk(CLOCK_50));

   adcinterface adcinterface_1 (.clk(clk_div_count[15]), .reset_n(reset_n), .ADC_SDO(ADC_SDO) , .ADC_CONVST(ADC_CONVST), .ADC_SCK(ADC_SCK), .ADC_SDI(ADC_SDI), .chan(chan), .result(result));

   // reset and onOff signals
   always_ff @(posedge CLOCK_50) begin
		clk_div_count <= clk_div_count + 1'b1 ;
	  
    // Pushbuttons are active low
		 if (s1) begin
			reset_n <= 1;
		 end else begin
			reset_n <= 0;
		 end
		 
		 led_result <= result;
	 end

	// assign the top two bits of count to select digit to display
	assign digit = clk_div_count[15:14]; 

	// Select digit to display (disp_digit)
	// Left two digits (3,2) display encoder 1 hex count and right two digits (1,0) display encoder 2 hex count
	always_comb begin
		 case (digit)
			  2'b11: disp_digit = chan[2:0];
			  2'b10: disp_digit = led_result[11:8];
			  2'b01: disp_digit = led_result[7:4];
			  2'b00: disp_digit = led_result[3:0];
			  default: disp_digit = 4'b0000; // Assign a default value
		 endcase
	end


endmodule


