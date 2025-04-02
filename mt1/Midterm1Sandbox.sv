// module oneCount mt2020
/*
module Midterm1Sandbox (input logic [31:0] data, 
								output logic [4:0] count );


	logic [4:0] counter = 0;

	always_comb begin
		for (int i = 0; i < 32; i++) begin
			if (data[i] == 1)
				counter = counter + 1;
		end
		
		count = counter;
		counter = 0;

	
	end


endmodule
*/

// Case statement error problem
/*
always_comb
    case (num)    // .GFEDCBA Active Low
        0 : leds = 8'b11000000;
        1 : leds = 8'b11111001;
        2 : leds = 8'b10100100;
        3 : leds = 8'b10110000;
        4 : leds = 8'b10011001;
        5 : leds = 8'b10010010;
        6 : leds = 8'b10000010;
        7 : leds = 8'b11111000;
        8 : leds = 8'b10000000;
        9 : leds = 8'b10010000;
        default : leds = '0; // Handles unspecified cases
    endcase
*/

// module problem4
/*
module Midterm1Sandbox (input logic clk, reset, e, a, output logic y);


	always_ff @(posedge clk) begin
		if (reset)
			y <= '0;
		else
			if (e)
				y <= y & a;
			else
				y <= y | a;
	
	end


endmodule
*/


// module problem6a
module Midterm1Sandbox (input logic clk, a, reset, output logic y);
logic b, c;


	always_ff @(posedge clk or negedge reset) begin
	if (!reset) begin
		b = 0;
		c = 0;
	end
	else begin
		b = a;
		c = b;
		y = c;
	end
			
	
	end


endmodule