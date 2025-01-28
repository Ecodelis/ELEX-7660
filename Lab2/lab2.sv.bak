// File: lab1.sv
// Description: ELEX 7660 lab1 top-level module.  Displays last
//              four digits of student number of 4 digit 7-segment
//              display module.
// Author: Robert Trost 
// Date: 2024-01-11

module lab2 ( input logic CLOCK_50,       // 50 MHz clock
              (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) 
              input logic enc1_a, enc1_b, //Encoder 1 pins
				      (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) input logic 
              enc2_a, enc2_b,				      //Encoder 2 pins
              output logic [7:0] leds,    // 7-seg LED enables
              output logic [3:0] ct ) ;   // digit cathodes

   logic [1:0] digit;  // select digit to display
   logic [3:0] disp_digit;  // current digit of count to display
   logic [15:0] clk_div_count; // count used to divide clock

   logic [7:0] enc1_count, enc2_count; // count used to track encoder movement and to display
   logic enc1_cw, enc1_ccw, enc2_cw, enc2_ccw;  // encoder module outputs

   // instantiate modules to implement design
   decode2 decode2_0 (.digit,.ct) ;
   decode7 decode7_0 (.num(disp_digit),.leds) ;

   encoder encoder_1 (.clk(CLOCK_50), .a(enc1_a), .b(enc1_b), .cw(enc1_cw), .ccw(enc1_ccw));
   encoder encoder_2 (.clk(CLOCK_50), .a(enc2_a), .b(enc2_b), .cw(enc2_cw), .ccw(enc2_ccw));

  // encoder counts: enc1_count & enc2_count (increment when cw=1, decrement when ccw=1)
  always_ff @(posedge CLOCK_50)  begin
    
    // encoder 1 count
    if (enc1_cw) enc1_count <= enc1_count + 1'b1;
    else if (enc1_ccw) enc1_count <= enc1_count - 1'b1;

    //encoder 2 count
    if (enc2_cw) enc2_count <= enc2_count + 1'b1;
    else if (enc2_ccw) enc2_count <= enc2_count - 1'b1;
  end

   // use count to divide clock and generate a 2 bit digit counter to determine which digit to display
   always_ff @(posedge CLOCK_50) 
     clk_div_count <= clk_div_count + 1'b1 ;

  // assign the top two bits of count to select digit to display
  assign digit = clk_div_count[15:14]; 

  // Select digit to display (disp_digit)
  // Left two digits (3,2) display encoder 1 hex count and right two digits (1,0) display encoder 2 hex count
  always_comb begin
  
  *** ADD CODE HERE ****
  
  end  

endmodule


