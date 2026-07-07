`timescale 1ns / 1ps

module MEM_WB (
    input              clk,
    input              reset,
    
    //data
    input wire  [2:0]  writeRegM, 
    input wire  [7:0]  aluResultM,
    input wire  [7:0]  readMemM,
    
    //control signals
    input wire         regWriteM,         
    input wire  [7:0]  imm8M,     
    input wire  [1:0]  regSrcM,         

    //data
    output reg  [2:0]  writeRegW, 
    output reg  [7:0]  aluResultW,
    output reg  [7:0]  readMemW,
    
    //control signals
    output reg         regWriteW,       
    output reg  [7:0]  imm8W,      
    output reg  [1:0]  regSrcW
);

    always @(posedge clk) begin
        if(~reset) begin
            writeRegW  <= writeRegM;
            aluResultW <= aluResultM;
            readMemW   <= readMemM;
            regWriteW  <= regWriteM;
            imm8W      <= imm8M;
            regSrcW    <= regSrcM;
        end
        else begin
            writeRegW  <= 3'd0;
            aluResultW <= 8'd0;
            readMemW   <= 8'd0;
            regWriteW  <= 1'b0;
            imm8W      <= 8'd0;
            regSrcW    <= 2'd0;
        end 
    end
endmodule
