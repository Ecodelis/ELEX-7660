// File: lab3.sv
// Description: ELEX 7660 lab1 top-level module. Generates C major scale
//						tones through the speaker as the rotary is turned.
// Author: Robert Trost 
// Updated by: Marcus Fu
// Date: 2024-02-01

module lab3 ( input logic CLOCK_50,       // 50 MHz clock
				  (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) input logic 
              enc2_a, enc2_b,				      //Encoder 2 pins
              input logic s1, s2,         // pushbuttons
              output logic [7:0] leds,    // 7-seg LED enables
              output logic [3:0] ct,       // digit cathodes
              output logic spkr ) ;       // buzzer output

   logic [1:0] digit;  // select digit to display
   logic [3:0] disp_digit;  // current digit of count to display
   logic [15:0] clk_div_count; // count used to divide clock
   logic [31:0] tone_freq = 0; // frequency to input
   logic onOff = 0; // 1 -> generate output, 0 -> no output
   logic reset_n = 0; // reset signal

   logic [7:0] enc1_count, enc2_count; // count used to track encoder movement and to display
   logic enc1_cw, enc1_ccw, enc2_cw, enc2_ccw;  // encoder module outputs

   // instantiate modules to implement design
	decode2 decode2_0 (.digit(digit), .ct(ct));
   decode7 decode7_0 (.num(disp_digit), .leds(leds));

   encoder encoder_2 (.clk(CLOCK_50), .a(enc2_a), .b(enc2_b), .cw(enc2_cw), .ccw(enc2_ccw));

   tonegen #(.FCLK(50000000)) tonegen_1 (.clk(CLOCK_50), .reset_n(reset_n), .freq(tone_freq), .onOff(onOff), .spkr(spkr));

   enc2freq enc2freq_2 (.clk(CLOCK_50), .cw(enc2_cw), .ccw(enc2_ccw), .freq(tone_freq), .reset_n(reset_n));

   // reset and onOff signals
   always_ff @(posedge CLOCK_50) begin
		clk_div_count <= clk_div_count + 1'b1 ;
	  
    // Pushbuttons are active low
		 if (s1) begin
			reset_n <= 1;
		 end else begin
			reset_n <= 0;
		 end


		 if(s2) begin
			onOff <= 1;
		 end else begin
			onOff <= 0;
		 end
	  
	 end

	// assign the top two bits of count to select digit to display
	assign digit = clk_div_count[15:14]; 

	// Select digit to display (disp_digit)
	// Left two digits (3,2) display encoder 1 hex count and right two digits (1,0) display encoder 2 hex count
	always_comb begin
		 // avoid latching
		 disp_digit = 4'b0000;

		 case (digit)
			  2'b01: disp_digit = tone_freq[3:0]; // Left tens
			  2'b00: disp_digit = tone_freq[7:4]; // left ones
			  
			  2'b11: disp_digit = tone_freq[11:8]; // right tens
			  2'b10: disp_digit = tone_freq[15:12]; // right ones
			  default: disp_digit = 4'b0000; // Assign a default value
		 endcase
	end


endmodule


