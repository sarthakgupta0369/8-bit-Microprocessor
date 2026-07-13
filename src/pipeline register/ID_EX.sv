`timescale 1ns / 1ps

module ID_EX (
    input             clk,
    input             reset,
    input             clr, //added clr
    
    //data
    input wire  [15:0] pcPlus1D,
    input wire  [7:0]  readData1D,
    input wire  [7:0]  readData2D,
    input wire  [2:0]  writeRegD, 
    
    //control signals
    input wire         regWriteD,     
    input wire  [3:0]  aluControlD,           
    input wire  [7:0]  imm8D,     
    input wire  [15:0] imm16D,     
    input wire         aluSrcD,         
    input wire  [1:0]  regSrcD,         
    input wire         memWriteD,
    input wire         memReadD,
    input wire  [1:0]  branchControlD, 
    input wire         branchD,         
    input wire         jumpD,
    
    //data
    output reg  [15:0] pcPlus1E,
    output reg  [7:0]  readData1E,
    output reg  [7:0]  readData2E,
    output reg  [2:0]  writeRegE, 
    
    //control signals
    output reg         regWriteE,     
    output reg  [3:0]  aluControlE,           
    output reg  [7:0]  imm8E,     
    output reg  [15:0] imm16E,     
    output reg         aluSrcE,         
    output reg  [1:0]  regSrcE,         
    output reg         memWriteE,
    output reg         memReadE,
    output reg  [1:0]  branchControlE, 
    output reg         branchE,         
    output reg         jumpE
);

    always @(posedge clk) begin
        if (~(reset | clr)) begin
            pcPlus1E        <= pcPlus1D;
            readData1E      <= readData1D;
            readData2E      <= readData2D;
            regWriteE       <= regWriteD;
            aluControlE     <= aluControlD;
            writeRegE       <= writeRegD;
            imm8E           <= imm8D;
            imm16E          <= imm16D;
            aluSrcE         <= aluSrcD;
            regSrcE         <= regSrcD;
            memWriteE       <= memWriteD;
            memReadE        <= memReadD;
            branchControlE  <= branchControlD;
            branchE         <= branchD;
            jumpE           <= jumpD;
        end 
        else begin
            pcPlus1E        <= 16'd0;
            readData1E      <= 8'd0;
            readData2E      <= 8'd0;
            regWriteE       <= 1'b0;
            aluControlE     <= 4'd0;
            writeRegE       <= 3'd0;
            imm8E           <= 8'd0;
            imm16E          <= 16'd0;
            aluSrcE         <= 1'b0;
            regSrcE         <= 2'd0;
            memWriteE       <= 1'b0;
            memReadE        <= 1'b0;
            branchControlE  <= 2'd0;
            branchE         <= 1'b0;
            jumpE           <= 1'b0;
        end
    end
endmodule
