`timescale 1ns / 1ps

module instruction_memory(
  input [15:0] pc,
  output [15:0] instruction
);
  reg [15:0] instr_mem [65535:0];
  
  initial begin
  $readmemb("machinecode.mem", instr_mem);
  end
  
  assign instruction = instr_mem[pc];
  
endmodule
