`timescale 1ns / 1ps

module stack_pointer(
    input clk,
    input reset,
    input spWrite,
    input [7:0] writeSP,
    output [7:0] readSP
    );
    
    reg [7:0] stackPointer;
    
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            stackPointer <= 8'b0;
        end
        else if (spWrite) begin
            stackPointer <= writeSP;
        end
    end 
    
    assign readSP = stackPointer;                       
endmodule
