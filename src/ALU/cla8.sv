module cla8 (
    input  logic [7:0] a,
    input  logic [7:0] b,
    input  logic       cin,
    output logic [7:0] sum,
    output logic       cout
);

    logic c4;
    logic pg0, gg0;
    logic pg1, gg1;
    logic unused_c0, unused_c1;

    cla4 u_low (
        .a    (a[3:0]),
        .b    (b[3:0]),
        .cin  (cin),
        .sum  (sum[3:0]),
        .cout (unused_c0),
        .pg   (pg0),
        .gg   (gg0)
    );

    assign c4 = gg0 | (pg0 & cin);

    cla4 u_high (
        .a    (a[7:4]),
        .b    (b[7:4]),
        .cin  (c4),
        .sum  (sum[7:4]),
        .cout (unused_c1),
        .pg   (pg1),
        .gg   (gg1)
    );

    assign cout = gg1 | (pg1 & gg0) | (pg1 & pg0 & cin);

endmodule
