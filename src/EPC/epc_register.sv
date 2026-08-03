`timescale 1ns / 1ps
module epc_register (
    input  wire        clk,
    input  wire        reset,
    input  wire        exc_overflow,
    input  wire [15:0] pcE,
    input  wire        trap,
    input  wire        illegal,
    input  wire [15:0] pcD,
    output reg  [15:0] epc
);
    always @(posedge clk or posedge reset) begin
            if (reset)
                epc <= 16'd0;
            else if (trap||illegal)
                epc <= pcD;
            else if (exc_overflow)
                epc <= pcE;
    end
endmodule
