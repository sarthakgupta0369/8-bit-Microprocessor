`timescale 1ns / 1ps

module booth_decoder (
    input  logic [7:0] a,      
    input  logic [2:0] grp,    
    output logic [7:0] pp      
);

    logic [7:0] pos_a, pos_2a, neg_a, neg_2a;

    assign pos_a  =  a;                       // +A  : wire
    assign pos_2a = {a[6:0], 1'b0};           // +2A : A << 1
    assign neg_a  = (~a) + 8'd1;              // -A  : ~A + 1
    assign neg_2a = (~{a[6:0], 1'b0}) + 8'd1; // -2A : ~(A<<1) + 1


    always_comb begin
        unique case (grp)
            3'b000,
            3'b111: pp = 8'd0;
            3'b001,
            3'b010: pp = pos_a;
            3'b011: pp = pos_2a;
            3'b100: pp = neg_2a;
            3'b101,
            3'b110: pp = neg_a;
            default: pp = 8'd0;
        endcase
    end

endmodule
