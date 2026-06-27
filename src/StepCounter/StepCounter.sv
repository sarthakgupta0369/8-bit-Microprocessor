`timescale 1ns/1ps

module StepCounter(
    input clk,
    input reset, 
    input instructionDone,
    output reg [2:0] count
    );
    
    always @(posedge clk) begin
        if(instructionDone|reset) begin
            count <= 3'b000;
        end
        else begin 
            count <= count + 3'b001;
        end
    end
endmodule 
