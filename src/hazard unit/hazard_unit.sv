`timescale 1ns / 1ps

module hazard_unit(
    input [2:0] readReg1E,
    input [2:0] readReg2E,
    input [2:0] writeRegM, 
    input [2:0] writeRegW,
    input       regWriteM,
    input       regWriteW,
    input [1:0] regSrcM,                //to decide bw aluResultM and imm8M
    
    input              is_branchE,
    input  wire [15:0] instructionD,   // Raw instruction currently in ID
    input  wire        memReadE,       // 1 = instruction in EX is LOAD
    input  wire [2:0]  writeRegE,      // Destination reg [5:3] of instr in EX
    input  wire        regWriteE,
    
    output reg [1:0] forwardAE,        //forward signals to contorl the MUXes near alu input
    output reg [1:0] forwardBE,

    output wire        stall,         // 1 = freeze PC & IF/ID, bubble ID/EX
    output             flushIFID,
    output             flushIDEX
    );
    
    //forwarding
    always @(*) begin
        if ((readReg1E == writeRegM)&& regWriteM) begin
            if (regSrcM == 2'b01) begin
                forwardAE = 2'b11; //for imm8M
            end
            else begin  
                forwardAE = 2'b01; //for aluResultM
            end
        end
        else if ((readReg1E == writeRegW) && regWriteW) begin
            forwardAE = 2'b10; //for writeDataW
        end
        else begin
            forwardAE = 2'b00;
        end
     end
     
     always @(*) begin
        if ((readReg2E == writeRegM)&& regWriteM) begin
            if (regSrcM == 2'b01) begin
                forwardBE = 2'b11; //for imm8M
            end
            else begin
                forwardBE = 2'b01; //for aluResultM
            end
        end
        else if ((readReg2E == writeRegW) && regWriteW) begin
            forwardBE = 2'b10; //for writeDataW
        end
        else begin
            forwardBE = 2'b00;
        end
     end
    
    //stall
    wire [3:0] opcodeD = instructionD[15:12];

        // read[11:9]?
    wire usesRs1_D =
        (opcodeD == 4'b0000)|    // R-type
        (opcodeD == 4'b0001)|   // Rtype shift
        (opcodeD == 4'b0010)|     // ADDI
        (opcodeD == 4'b0100)|    // LOAD
        (opcodeD == 4'b0101)|     // STORE
        (opcodeD == 4'b0110)|   // BEQ
        (opcodeD == 4'b0111)|   // BNE
        (opcodeD == 4'b1000)|    // BLT
        (opcodeD == 4'b1001);    // BGE

    // read [8:6]
    wire usesRs2_D =
        (opcodeD == 4'b0000)|    // R-type
        (opcodeD == 4'b0001)|    // R-type shift
        (opcodeD == 4'b0101)|     // STORE
        (opcodeD == 4'b0110)|    // BEQ
        (opcodeD == 4'b0111)|     // BNE
        (opcodeD == 4'b1000)|     // BLT
        (opcodeD == 4'b1001);     // BGE

    wire rs1Hazard = usesRs1_D && (instructionD[11:9] == writeRegE);
    wire rs2Hazard = usesRs2_D && (instructionD[8:6]  == writeRegE);

    assign stall = memReadE && (rs1Hazard || rs2Hazard);
    
    //flush
    assign flushIFID = is_branchE || (opcodeD == 4'b1010);
    assign flushIDEX = is_branchE || stall; 
        
endmodule
