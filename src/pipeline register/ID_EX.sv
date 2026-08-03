`timescale 1ns / 1ps

module ID_EX (
    input             clk,
    input             reset,
    input             clr,
    input             en,
    
    //data
    input wire  [15:0] pcPlus1D,
    input wire  [7:0]  readData1D,
    input wire  [7:0]  readData2D,
    input wire  [2:0]  writeRegD, 
    input wire  [2:0]  readReg1D,
    input wire  [2:0]  readReg2D,
    input wire  [7:0]  spD,

    
    //control signals
    input wire         regWriteD,     
    input wire  [3:0]  aluControlD,           
    input wire  [7:0]  imm8D,     
    input wire  [15:0] imm16D, 
    input wire         aluSrcAD,    
    input wire  [1:0]  aluSrcBD,         
    input wire  [1:0]  regSrcD,         
    input wire         memWriteD,
    input wire         memReadD,
    input wire  [1:0]  branchControlD, 
    input wire         branchD, 
    input wire         stackReadD,
    input wire         stackWriteD,
    input wire         stackSrcD,  
    input wire         jrjalrD,      
    input wire [15:0]  readLRD,
    input wire         spWriteD,
    input wire         spSrcD,
    input wire         popWriteD,
    input wire [15:0]  pcCurrentD,
    input wire         usesAluD,
    
    //data
    output reg  [15:0] pcPlus1E,
    output reg  [7:0]  readData1E,
    output reg  [7:0]  readData2E,
    output reg  [2:0]  writeRegE, 
    output reg  [2:0]  readReg1E,
    output reg  [2:0]  readReg2E,
    output reg  [7:0]  spE,
    
    //control signals
    output reg         regWriteE,     
    output reg  [3:0]  aluControlE,           
    output reg  [7:0]  imm8E,     
    output reg  [15:0] imm16E,  
    output reg         aluSrcAE,   
    output reg  [1:0]  aluSrcBE,         
    output reg  [1:0]  regSrcE,         
    output reg         memWriteE,
    output reg         memReadE,
    output reg  [1:0]  branchControlE, 
    output reg         branchE,
    output reg         stackReadE,
    output reg         stackWriteE,
    output reg         stackSrcE,
    output reg         jrjalrE,
    output reg  [15:0] readLRE,
    output reg         spWriteE,
    output reg         spSrcE,
    output reg         popWriteE,
    output reg  [15:0] pcCurrentE,
    output reg         usesAluE
);

    always @(posedge clk) begin
        if (reset||clr) begin
            pcPlus1E        <= 16'd0;
            readData1E      <= 8'd0;
            readData2E      <= 8'd0;
            regWriteE       <= 1'b0;
            aluControlE     <= 4'd0;
            writeRegE       <= 3'd0;
            readReg1E       <= 3'd0;
            readReg2E       <= 3'd0;
            imm8E           <= 8'd0;
            imm16E          <= 16'd0;
            aluSrcAE        <= 1'b0;
            aluSrcBE        <= 2'd0;
            regSrcE         <= 2'd0;
            memWriteE       <= 1'b0;
            memReadE        <= 1'b0;
            branchControlE  <= 2'd0;
            branchE         <= 1'b0;
            stackReadE      <= 1'b0;
            stackWriteE     <= 1'b0;
            stackSrcE       <= 1'b0;
            spE             <= 8'd0;
            jrjalrE         <= 1'b0;
            readLRE         <= 16'b0;
            spWriteE        <= 1'b0;
            spSrcE          <= 1'b0;
            popWriteE       <= 1'b0;
            pcCurrentE      <= 1'b0;
            usesAluE        <= 1'b0;
        end 
        else if (~en) begin
            pcPlus1E        <= pcPlus1E;
            readData1E      <= readData1E;
            readData2E      <= readData2E;
            regWriteE       <= regWriteE;
            aluControlE     <= aluControlE;
            writeRegE       <= writeRegE;
            readReg1E       <= readReg1E;
            readReg2E       <= readReg2E;
            imm8E           <= imm8E;
            imm16E          <= imm16E;
            aluSrcAE        <= aluSrcAE;
            aluSrcBE        <= aluSrcBE;
            regSrcE         <= regSrcE;
            memWriteE       <= memWriteE;
            memReadE        <= memReadE;
            branchControlE  <= branchControlE;
            branchE         <= branchE;
            stackReadE      <= stackReadE;
            stackWriteE     <= stackWriteE;
            stackSrcE       <= stackSrcE;
            spE             <= spE;
            jrjalrE         <= jrjalrE;
            readLRE         <= readLRE;
            spWriteE        <= spWriteE;
            spSrcE          <= spSrcE;
            popWriteE       <= popWriteE;
            pcCurrentE      <= pcCurrentE;
            usesAluE        <= usesAluE;
        end
        else begin
            pcPlus1E        <= pcPlus1D;
            readData1E      <= readData1D;
            readData2E      <= readData2D;
            regWriteE       <= regWriteD;
            aluControlE     <= aluControlD;
            writeRegE       <= writeRegD;
            readReg1E       <= readReg1D;
            readReg2E       <= readReg2D;
            imm8E           <= imm8D;
            imm16E          <= imm16D;
            aluSrcAE        <= aluSrcAD;
            aluSrcBE        <= aluSrcBD;
            regSrcE         <= regSrcD;
            memWriteE       <= memWriteD;
            memReadE        <= memReadD;
            branchControlE  <= branchControlD;
            branchE         <= branchD;
            stackReadE      <= stackReadD;
            stackWriteE     <= stackWriteD;
            stackSrcE       <= stackSrcD;
            spE             <= spD;
            jrjalrE         <= jrjalrD;
            readLRE         <= readLRD;
            spWriteE        <= spWriteD;
            spSrcE          <= spSrcD;
            popWriteE       <= popWriteD;
            pcCurrentE      <= pcCurrentD;
            usesAluE        <= usesAluD;
        end
    end
endmodule
