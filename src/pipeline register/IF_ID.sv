`timescale 1ns / 1ps

module IF_ID (
    input             clk,
    input             reset,
    input             clr,
    input             en,
    
    input wire [15:0] pcPlus1I,
    input wire [15:0] instructionI,
    input wire [15:0] pcCurrent,
    input wire        predictionF,
    input wire [15:0] predictedTargetF,
    
    output reg [15:0] pcPlus1D, 
    output reg [15:0] instructionD,
    output reg [15:0] pcCurrentD,   
    output reg        predictionD,//THIS
    output reg [15:0] predictedTargetD//THIS
);

    always @(posedge clk) begin
       if (reset) begin
            pcPlus1D     <= 16'b0;
            instructionD <= 16'b0;
            pcCurrentD    <= 16'b0;
            predictionD  <= 1'b0; //THIS
            predictedTargetD <= 16'b0; //THIS
        end
        else if (clr) begin
            pcPlus1D     <= pcPlus1I;          
            instructionD <= {{4{1'b1}},{12{1'b0}}};    
            pcCurrentD   <= pcCurrent;
            predictionD  <= 1'b0;     //THIS
            predictedTargetD <=predictedTargetF;  //THIS      
        end
        else if (~en) begin
            pcPlus1D     <= pcPlus1D;          
            instructionD <= instructionD;  
            pcCurrentD   <= pcCurrentD; 
            predictionD  <= predictionD;     //THIS
            predictedTargetD <= predictedTargetD;  //THIS   
        end
        else begin
            pcPlus1D     <= pcPlus1I;
            instructionD <= instructionI;
            pcCurrentD   <= pcCurrent;
            predictionD  <= predictionF;      //THIS
            predictedTargetD <= predictedTargetF;//THIS
        end
    end
endmodule
