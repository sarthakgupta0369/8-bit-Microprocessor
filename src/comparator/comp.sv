`timescale 1ns / 1ps

module comparator(
    input [7:0] r1,
    input [7:0] r2,
    output wire eq,
    output wire lt
);

assign eq = (r1 == r2);
assign lt = ($signed(r1) < $signed(r2));

endmodule
