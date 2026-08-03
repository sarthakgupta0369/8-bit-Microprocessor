`timescale 1ns / 1ps
module cause_register (
    input  wire       clk,
    input  wire       reset,
    input  wire       exc_overflow,
    input  wire       trap,
    input  wire       illegal,
    output reg  [1:0] cause
);
    localparam [1:0] CAUSE_NONE     = 2'b00;
    localparam [1:0] CAUSE_OVERFLOW = 2'b01;
    localparam [1:0] CAUSE_TRAP     = 2'b10;
    localparam [1:0] CAUSE_ILLEGAL  = 2'b11;

    always @(posedge clk or posedge reset) begin
         if (reset) begin
                cause <= CAUSE_NONE;
            end
            else if (trap) begin
                cause <= CAUSE_TRAP;
            end
            else if (exc_overflow) begin
                cause <= CAUSE_OVERFLOW;
            end
            else if (illegal) begin
                cause <= CAUSE_ILLEGAL;
            end     
   end
endmodule
