`timescale 1ns / 1ps

module link_register(
    input wire clk,
    input wire reset,
    input wire linkEnable,
    input wire [15:0] newLR,

    output wire [15:0]readLR
    );
    reg [15:0] linkRegister;

    assign readLR = linkRegister;

    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            linkRegister <= 16'b0;
        end
        else if(linkEnable) begin
            linkRegister <= newLR;
        end
    end
endmodule
