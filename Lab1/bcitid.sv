module bcitid ( input logic [1:0] digit, 		// digit counter
					output logic [3:0] idnum );	// studentID num for each digit

	logic [3:0] myID [3:0] = '{4'h1, 4'h4, 4'h6, 4'h8};
 
	always_comb
		case (digit)
			2'b00 : idnum = myID[0]; 	// Seg 1
			2'b01 : idnum = myID[1];	// Seg 2
			2'b10 : idnum = myID[2];	// Seg 3
			2'b11 : idnum = myID[3];	// Seg 4
		endcase

endmodule
