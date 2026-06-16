`timescale 1ns / 1ps

module comparator(
    input signed [7:0] r1,
    input signed [7:0] r2,
    output wire eq,
    output wire lt,
    output wire ge
);

assign eq = (r1 == r2);
assign lt = (r1 < r2);
assign ge = (r1 >= r2);

endmodule
