// File: bcitid.sv
// Description: A 4x4 bit memory that will store the last 
// 				 four digits of my BCIT ID
// Author: Marcus Fu
// Date: 2025/01/17

module bcitid ( input logic [1:0] digit, 		// digit counter
					output logic [3:0] idnum );	// studentID num for each digit

	logic [3:0] myID [3:0] = '{4'h1, 4'h4, 4'h6, 4'h8}; // Stores last 4 numbers of the student ID in hexcode
 
	always_comb
		case (digit) // Displays ID number corresponding to the active digit
			2'b00 : idnum = myID[0]; 
			2'b01 : idnum = myID[1];
			2'b10 : idnum = myID[2];
			2'b11 : idnum = myID[3];
		endcase

endmodule
