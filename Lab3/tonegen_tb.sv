// tonegen_tb.sv - testbench for ELEX 7660 202010 Lab 3
// test tone generator with frequencies 1Hz and 10Hz using a clock frequency of 20Hz
// Robert Trost
// Jan 22, 2024


`timescale 1ms/1ms

module tonegen_tb ;

   logic [31:0] freq = 1 ;
   logic onOff = 1;
   logic spkr ;
   logic reset_n, clk = 1 ;

   tonegen #(.FCLK(20)) dut_0 (.*) ;      // fclk=20Hz

   initial begin

      // reset
      reset_n = 0 ;
      repeat(2) @(negedge clk) ;
      reset_n = 1 ;

      // should have no output here (freq should be zero)
      repeat(10) @(negedge clk) ;

      // set frequency to 1Hz (10 clock cycles high, 10 clock cycles low)
      freq = 1  ;
      repeat(25) @(negedge clk) ;

      // set frequency to 10 Hz (1 clock cycle high, 1 clock cycle low)
      freq = 10 ;
      repeat(8) @(negedge clk) ;

      // turn off output
      onOff = 0;
      repeat(8) @(negedge clk) ;
      
      $stop ;
    
   end

   // 20 Hz clock
   always
     #25ms clk = ~clk ;
   
endmodule      

