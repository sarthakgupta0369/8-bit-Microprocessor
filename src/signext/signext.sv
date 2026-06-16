`timescale 1ns / 1ps

module SignExtend(
    input [5:0] imm6,
    input [11:0] imm12,
    input imm_sel,
    output [15:0] imm_ext
);
assign imm_ext = imm_sel
               ? {{4{imm12[11]}}, imm12}
               : {{10{imm6[5]}}, imm6}; //use imm_ext[7:0] when feeding to ALU in load/addi
endmodule
