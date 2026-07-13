`timescale 1ns / 1ps

module EX_MEM(
    input              clk,
    input              reset,
    
    //data
    input wire  [7:0]  operandBE,
    input wire  [2:0]  writeRegE, 
    input wire  [7:0]  aluResultE,
    
    //control signals
    input wire         regWriteE,         
    input wire  [7:0]  imm8E,     
    input wire  [1:0]  regSrcE,         
    input wire         memWriteE,
    input wire         memReadE,

    //data
    output reg  [7:0]  operandBM,
    output reg  [2:0]  writeRegM, 
    output reg  [7:0]  aluResultM,
    
    //control signals
    output reg         regWriteM,       
    output reg  [7:0]  imm8M,      
    output reg  [1:0]  regSrcM,         
    output reg         memWriteM,
    output reg         memReadM
);

    always @(posedge clk) begin
        if (~reset) begin
            operandBM    <= operandBE;
            writeRegM    <= writeRegE;
            aluResultM   <= aluResultE;
            regWriteM    <= regWriteE;
            imm8M        <= imm8E;
            regSrcM      <= regSrcE;
            memWriteM    <= memWriteE;
            memReadM     <= memReadE;
        end 
        else begin 
            operandBM    <= 8'd0;
            writeRegM    <= 3'd0;
            aluResultM   <= 8'd0;
            regWriteM    <= 1'b0;
            imm8M        <= 8'd0;
            regSrcM      <= 2'd0;
            memWriteM    <= 1'b0;
            memReadM     <= 1'b0;  
        end
    end        
endmodule
