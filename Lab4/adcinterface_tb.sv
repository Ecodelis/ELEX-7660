// ELEX 7660 202010 Lab 3
// Testbench to test the ADC interface module
// Robert Trost 2020/1/21


module adcinterface_tb();

parameter N = 12; // Number of ADC bits (LTC2308 is a 12-bit ADC)

logic clk, reset_n;			 // clock and reset
logic [2:0] chan;			 // channel to be sampled
logic [N-1:0] result;		 // result read by adc interface module
logic [N-1:0] adcoutput = 0;  // randomly generated ADC output
logic [N-1:0] configword = 0; // capture configuration word from adcinterface
	
// ltc2308 signals
logic ADC_CONVST, ADC_SCK, ADC_SDI;
logic ADC_SDO = 0;

adcinterface dut_0 (.*);  // device under test


initial begin
	clk = 0;
	reset_n = 0;
	chan = 0;
	
	// hold in reset for two clock cycles
	repeat(2) @(posedge clk);
	
	reset_n = 1;
	
	// loop for each possible channel
	do begin

	// wait for conversion start signal
	@(posedge ADC_CONVST);
	
		// generate a random n-bit ADC output
		adcoutput = $urandom_range('hfff, 0);

		for (int i = N-1; i>=0; i--)	begin
			// place each data bit on SDO and wait for negative edge of serial clock to change output
			ADC_SDO = adcoutput[i];
			@(posedge ADC_SCK);
			// capture config word on positive edge
			configword[i] = ADC_SDI;
			@(negedge ADC_SCK);
		end
		
	repeat(2) @(posedge clk);
	
	// check that results matches the serial data transmitted by ADC module
	$display ("ADC output check - %s: expected ADC ouput %3h, received %3h",  adcoutput == result ? "PASS" : "****FAIL****", adcoutput, result);
	
	// verify that correct configuration word is sent for the selected channel
	$display ("Config word Check - %s: channel %1d, expected config word %2h, received %2h",  configword[N-1:6] == {1'b1, chan[0], chan[2:1], 1'b1, 1'b0} ? "PASS" : "****FAIL****", chan, {1'b1, chan[0], chan[2:1], 1'b1, 1'b0}, configword[N-1:6]);

	chan++;
	
	end while (chan != 0);
		
	$stop;

end

// generate clock
always
	#1ms clk = ~clk;
	

endmodule

