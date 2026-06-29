`timescale 1ns / 1ps

module ram(
  input clk,
  input reset,
  input memWrite, 
  input memRead,
  input [7:0] address,
  input [7:0] writeMem,
  output [7:0] readMem
);
  
  reg [7:0] mem [255:0];
  
  integer i;
  
  always @ (posedge clk or posedge reset) begin
    if(reset) begin
      for (i = 0; i < 256; i = i + 1) begin
        mem[i] <= 8'd0;
      end
    end
    else if(memWrite) begin
      mem[address] <= writeMem;
    end
  end
  
  assign readMem = memRead ? mem[address] : 8'b0;

endmodule
