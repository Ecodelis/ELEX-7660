// File: seqDetect_tb.sv
// Description: Testbench for the seqDetect module. Tests all possible inputs 'a'
// Author: Marcus Fu
// Date: 2025-02-11

`timescale 1ms/1ms // Time unit: 1ns, Precision: 1ps

module seqDetect_tb;
   // Testbench signals
   logic a;
   logic [2:0] seq;
   logic valid;
   logic reset_n;
   logic clk = 0;

   // Clock generation
   always #1 clk = ~clk; 
   // Instantiate module
   seqDetect #(.N(3)) dut (.*);

   initial begin
      // Reset
      reset_n = 0;
      a = 0;
      valid = 0;
      seq = 0;
      repeat(5) @(posedge clk);
      reset_n = 1;
      seq = 3'b101 ; // Sequence to detect

      // Simulate correct sequence
      for (int i = 0; i < 3; i++) begin
         a = ~a;
         @(posedge clk);
      end

      a = 0;
      repeat(3) @(posedge clk); // wait 3 clock cycles
      
      // Reset
      reset_n = 0;
      a = 0;
      valid = 0;
      repeat(5) @(posedge clk);
      reset_n = 1;

      seq = 3'b000 ; // Sequence to detect

      // Simulation incorrect sequence
      for (int i = 0; i < 3; i++) begin
         a = i;
         @(posedge clk);
      end

      repeat(3) @(posedge clk); // wait 3 clock cycles

      $stop; // Stop simulation
   end

endmodule