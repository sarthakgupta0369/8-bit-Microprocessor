`timescale 1ns / 1ps

module EX_MEM(
    input              clk,
    input              reset,
    input              clr,
    
    //data
    input wire  [7:0]  operandBE,
    input wire  [2:0]  writeRegE, 
    input wire  [7:0]  aluResultE,
    input wire [15:0]  stackDataE,
    input wire [7:0]   stackAddrE,

    
    //control signals
    input wire         regWriteE,         
    input wire  [7:0]  imm8E,     
    input wire  [1:0]  regSrcE,         
    input wire         memWriteE,
    input wire         memReadE,
    input wire         stackReadE,
    input wire         stackWriteE,
    input wire         spWriteE,
    input wire         popWriteNewE,

    //data
    output reg  [7:0]  operandBM,
    output reg  [2:0]  writeRegM, 
    output reg  [7:0]  aluResultM,
    output reg  [15:0] stackDataM,
    output reg  [7:0]  stackAddrM,
    output reg         popWriteNewM,
    
    //control signals
    output reg         regWriteM,       
    output reg  [7:0]  imm8M,      
    output reg  [1:0]  regSrcM,         
    output reg         memWriteM,
    output reg         memReadM,
    output reg         stackReadM,
    output reg         stackWriteM,
    output reg         spWriteM
);

    always @(posedge clk) begin
        if (~(reset || clr)) begin
            operandBM    <= operandBE;
            writeRegM    <= writeRegE;
            aluResultM   <= aluResultE;
            regWriteM    <= regWriteE;
            imm8M        <= imm8E;
            regSrcM      <= regSrcE;
            memWriteM    <= memWriteE;
            memReadM     <= memReadE;
            stackReadM  <= stackReadE;
            stackWriteM <= stackWriteE;
            stackDataM  <= stackDataE;
            stackAddrM  <= stackAddrE;
            spWriteM    <= spWriteE;
            popWriteNewM <= popWriteNewE;
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
            stackReadM   <= 1'b0;
            stackWriteM  <= 1'b0;
            stackDataM   <= 16'd0; 
            stackAddrM   <= 8'd0;
            spWriteM     <= 1'b0;
            popWriteNewM <= 1'b0;
        end
    end        
endmodule
