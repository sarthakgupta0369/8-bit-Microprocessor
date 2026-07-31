`timescale 1ns / 1ps

module MEM_WB (
    input              clk,
    input              reset,
    
    //data
    input wire  [2:0]  writeRegM, 
    input wire  [7:0]  aluResultM,
    input wire  [7:0]  readMemM,
    input wire  [15:0] readStackM,
    
    //control signals
    input wire         regWriteM,         
    input wire  [7:0]  imm8M,     
    input wire  [1:0]  regSrcM,  
    input wire         popWriteNewNewM,       

    //data
    output reg  [2:0]  writeRegW, 
    output reg  [7:0]  aluResultW,
    output reg  [7:0]  readMemW,
    output reg  [15:0] readStackW,
    
    //control signals
    output reg         regWriteW,       
    output reg  [7:0]  imm8W,      
    output reg  [1:0]  regSrcW,
    output reg         popWriteNewNewW
);

    always @(posedge clk) begin
        if(~reset) begin
            writeRegW  <= writeRegM;
            aluResultW <= aluResultM;
            readMemW   <= readMemM;
            regWriteW  <= regWriteM;
            imm8W      <= imm8M;
            regSrcW    <= regSrcM;
            readStackW <= readStackM;
            popWriteNewNewW <= popWriteNewNewM;
        end
        else begin
            writeRegW  <= 3'd0;
            aluResultW <= 8'd0;
            readMemW   <= 8'd0;
            regWriteW  <= 1'b0;
            imm8W      <= 8'd0;
            regSrcW    <= 2'd0;
            readStackW  <= 16'd0;
            popWriteNewNewW <= 1'b0;
        end 
    end
endmodule
