module decode7 ( input logic [3:0] num, 	// num of bcitID
					output logic [7:0] leds );	// active high led segment enable


	always_comb
		case (num)
			4'h0 : leds = 8'h3F; // 0
			4'h1 : leds = 8'h06; // 1
			4'h2 : leds = 8'h5B; // 2
			4'h3 : leds = 8'h4F; // 3
			
			4'h4 : leds = 8'h66; // 4
			4'h5 : leds = 8'h6D; // 5
			4'h6 : leds = 8'h7D; // 6
			4'h7 : leds = 8'h07; // 7
			
			4'h8 : leds = 8'h7F; // 8
			4'h9 : leds = 8'h67; // 9
			4'hA : leds = 8'h77; // A
			4'hB : leds = 8'h7C; // B

			4'hC : leds = 8'h39; // C
			4'hD : leds = 8'h5E; // D
			4'hE : leds = 8'h79; // E
			4'hF : leds = 8'h71; // F
		endcase



endmodule