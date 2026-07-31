`timescale 1ns / 1ps

module stack_memory (
    input clk, 
    input reset,
    input stackWrite,
    input stackRead,
    input [7:0] address,
    input [15:0] writeStack,
    output [15:0] readStack
    );
    
    reg [15:0] stack [255:0];
    
    integer i; 
    
    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            for (i = 0; i < 256; i = i + 1) begin
                stack[i] <= 16'd0;
        end
    end
        else if(stackWrite) begin
          stack[address] <= writeStack;
        end
    end
    
    assign readStack = stackRead ? stack[address] : 16'b0;
endmodule
