`timescale 1ns / 1ps

module ram(
  input clk,
  input memWrite, 
  input memRead,
  input [7:0] address,
  input [7:0] writeMem,
  output [7:0] readMem
);
  
  reg[7:0] mem [255:0];
  
  always @ (posedge clk) begin
    if(memWrite) begin
      mem[address] <=writeMem;
    end
  end
  
  assign readMem = memRead ? mem[address] : 8'b0;
endmodule
