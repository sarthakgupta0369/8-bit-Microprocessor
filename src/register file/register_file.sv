`timescale 1ns / 1ps

module register_file(
  input wire clk,
  input wire RegWrite,
  input wire reset,            //??
  input wire [2:0] readReg1,
  input wire [2:0] readReg2,
  input wire [2:0] writeReg,
  input wire [7:0] writeData,
  output wire [7:0] readData1,
  output wire [7:0] readData2
);
  
  reg [7:0] regfile [7:0];
  
  assign readData1 = (RegWrite && (readReg1 == writeReg)) ? writeData : regfile[readReg1];
  assign readData2 = (RegWrite && (readReg2 == writeReg)) ? writeData : regfile[readReg2];
  
  integer  i;
  
  always @ (posedge clk or posedge reset) begin
    if(reset) begin
      for (i = 0; i < 8; i = i + 1) begin
      regfile[i] <= 8'd0;
      end
    end
    else if(RegWrite) begin
      regfile[writeReg] <= writeData;
    end
  end
endmodule
