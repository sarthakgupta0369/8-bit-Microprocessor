`timescale 1ns / 1ps

module ProgramCounter(
    input clk,
    input rst,
    input pc_write, //should be useful when we extend our cpu to be multi-cycled/pipelined
    input [15:0] pc_next,
    output reg [15:0] pc
);
    initial begin
        pc <= 16'b0;
    end
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin 
            pc <= 16'b0;
        end
        else if(pc_write) begin
            pc <= pc_next;
        end 
    end
endmodule
