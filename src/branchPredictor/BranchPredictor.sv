`timescale 1ns / 1ps

module branchPredictor(
input clk,
input reset,

input [15:0] currentPC,
output       prediction,
output[15:0] predictedTarget,
output       btbHit,

input        branch,
input        actualTaken,
input [15:0] actualTarget,
input [15:0] pcBranch
    );
    
reg [1:0] PHT [255:0];
reg [15:0] BTB [255:0];
reg [7:0] tagTable[255:0];

wire [7:0] indexE;
wire [7:0] indexF;
assign indexF = currentPC[7:0];

assign prediction = PHT[indexF][1];
assign predictedTarget = BTB[indexF];
assign btbHit = (tagTable[indexF] == currentPC[15:8]);

assign indexE = pcBranch[7:0];
integer i;
always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 256; i = i + 1) begin
            tagTable[i] <= 8'b11111111;
            PHT[i]      <= 2'b00;
        end
    end
    else if (branch) begin
        if (actualTaken) begin
            if (PHT[indexE] != 2'b11) begin
                PHT[indexE] <= PHT[indexE] + 1'b1;     
            end
                
            tagTable[indexE]    <= pcBranch[15:8];
            BTB[indexE] <= actualTarget;
        end 
        else begin
            if (PHT[indexE] != 2'b00) begin
                PHT[indexE] <= PHT[indexE] - 1'b1;    
            end
        end 
    end
end

endmodule
