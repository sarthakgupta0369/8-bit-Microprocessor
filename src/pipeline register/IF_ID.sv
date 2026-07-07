`timescale 1ns / 1ps

module IF_ID (
    input             clk,
    input             reset,
    
    input wire [15:0] pcPlus1I,
    input wire [15:0] instructionI,
    
    output reg [15:0] pcPlus1D, 
    output reg [15:0] instructionD
);

    always @(posedge clk) begin
        if (~reset) begin
            pcPlus1D    <= pcPlus1I;
            instructionD <= instructionI;
        end 
        else begin
            pcPlus1D    <= 16'd0;
            instructionD <= 16'd0;
        end
    end
endmodule
