`timescale 1ns / 1ps

module comparator(
    input [7:0] readData1,
    input [7:0] readData2,
    output wire eq,
    output wire lt
);

assign eq = (readData1 == readData2);
assign lt = ($signed(readData1) < $signed(readData2));

endmodule
