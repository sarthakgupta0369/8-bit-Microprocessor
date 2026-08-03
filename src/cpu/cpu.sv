`timescale 1ns / 1ps

module cpu (
    input  wire clk,
    input  wire reset,
    input  wire releaseTrap
    
);//IF
    wire [15:0] pcCurrent;
    wire [15:0] pcPlus1;
    wire [15:0] pcNext;
    wire [15:0] instructionF;        
    
    wire [15:0] target_addressE;
    wire        is_branchE;
    wire        pcSrc; // added pcSrc wire
    wire        flushIFID;
    wire        stall;
    
    //IF /ID
    wire [15:0] pcPlus1D;
    wire [15:0] instructionD;
    
    //ID
    wire        regWriteD;
    wire [3:0]  aluControlD;
    wire [2:0]  readReg1D;
    wire [2:0]  readReg2D;
    wire [2:0]  writeRegD;
    wire [7:0]  imm8D;
    wire [15:0] imm16D;
    wire        aluSrcAD;
    wire [1:0]  aluSrcBD;
    wire [1:0]  regSrcD;
    wire        memWriteD;
    wire        memReadD;
    wire [1:0]  branchControlD;
    wire        branchD;
    wire        jumpD;
    wire        illegalD;
    wire       usesAluD;
    
    wire [7:0] readData1D;
    wire [7:0] readData2D;
    
    wire        stackReadD;
    wire        stackWriteD;
    wire        stackSrcD;
    wire        spSrcD;
    
    wire        linkWriteD;
    wire        jrjalrD;
    
    wire        popWriteD;
    
    wire [15:0] pcCurrentD;
    
    //stack pointer
    wire        spWriteD;
    wire [7:0]  writeSP;
    wire [7:0]  spD;
    
    //link register
    wire [15:0] newLR;
    wire [15:0] readLRD;
    wire        linkWritePC;
    wire        writeLR;

    //ID/ EX
    wire [15:0] pcPlus1E;
    wire [7:0]  readData1E;
    wire [7:0]  readData2E;
    wire [2:0]  readReg1E;
    wire [2:0]  readReg2E;
    wire [2:0]  writeRegE;
    wire        regWriteE;
    wire [3:0]  aluControlE;
    wire [7:0]  imm8E;
    wire [15:0] imm16E;
    wire        aluSrcAE;
    wire [1:0]  aluSrcBE;
    wire [1:0]  regSrcE;
    wire        memWriteE;
    wire        memReadE;
    wire [1:0]  branchControlE;
    wire        branchE;
    wire        flushIDEX;
    
    wire        stackSrcE;
    wire [7:0]  spE;
    wire        stackReadE;
    wire        stackWriteE;
    wire [15:0] stackDataE;
    wire [7:0]  stackAddrE;
    wire        spSrcE;
    wire        jrjalrE;
    wire [7:0]  spForwardE;
    wire        forwardSPE;
    wire        forwardLRE;
    wire [15:0] lrForwardE;
    wire [15:0] readLRE;
    
    wire        popWriteE;
    wire        popWriteNewE;
    
    wire [15:0] pcCurrentE;
    
    // alu
    wire [7:0] operandAE;
    wire [7:0] operandBE; //the wire that goes into the aluInputB MUX 
    wire [7:0] aluInputA;
    wire [7:0] aluInputB;
    wire [7:0] aluResultE;
    
    wire       usesAluE;
    //wire       zero, carry, overflow, negative, sign, parity;
    wire       mul_busy;
    wire [1:0] forwardAE;
    wire [1:0] forwardBE;
    wire       overflow_pos, overflow_neg, overflow_u, overflow_0;

    //branch
    wire eq;
    wire lt;
    wire branch_type;
    wire predictionF; //THIS
    wire [15:0] predictedTargetF;//THIS
    wire predictionD;//THIS
    wire [15:0] predictedTargetD;//THIS
    wire predictionE;//THIS
    wire [15:0] predictedTargetE;//THIS
    wire btbHit;//THIS
    wire misprediction;//THIS
    wire [15:0] correctedPC;//THIS

    // EX/MEM
    wire [7:0]  operandBM;
    wire [2:0]  writeRegM;
    wire [7:0]  aluResultM;
    wire        regWriteM; 
    wire [7:0]  imm8M;
    wire [1:0]  regSrcM;
    wire        memWriteM;
    wire        memReadM;
    
    wire        popWriteNewM;
    wire        popWriteNewNewM;
    
    wire        stall_mul;
    
    // MEM
    wire [7:0] readMemM;
    
    //stack
    wire        stackWriteM;
    wire        stackReadM;
    wire [7:0]  stackAddrM;
    wire [15:0] stackDataM;
    wire [15:0] readStackM;
    
    wire        spWriteM;
    
    // MEM/WB 
    wire [7:0]  aluResultW;
    wire [7:0]  readMemW;
    wire [7:0]  imm8W;
    wire [1:0]  regSrcW;
    
    wire [15:0] readStackW;
    
    wire        popWriteNewNewW;
    
    // write feedback
    wire [7:0] writeDataW;
    wire       regWriteW;
    wire [2:0] writeRegW;
    
    //hazard unit
    wire       isJAL;
    
    //execption handling
    wire        trapD;
    wire        exc_overflow;
    wire [1:0]  cause;
    wire [15:0] epc;
    

    ProgramCounter pc_inst (
        .clk      (clk),
        .rst      (reset),
        .pc_write (~(stall||stall_mul)),
        .pc_next  (pcNext),
        .pc       (pcCurrent)
    );

    assign pcPlus1 = pcCurrent + 16'd1;

    instruction_memory imem (
        .pc          (pcCurrent),
        .instruction (instructionF)
    );

    IF_ID if_id (
        .clk          (clk),
        .reset        (reset),
        .clr          (flushIFID),
        .en           (~(stall||stall_mul)),
        .pcCurrent    (pcCurrent),
        .pcPlus1I     (pcPlus1),
        .predictionF  (predictionF),//THIS
        .predictedTargetF(predictedTargetF),//THIS
        .instructionI (instructionF),
        .pcCurrentD   (pcCurrentD),
        .predictionD  (predictionD),//THIS
        .predictedTargetD(predictedTargetD),//THIS
        .pcPlus1D     (pcPlus1D),
        .instructionD (instructionD)
    );

    control_unit ctrl (
        .instruction    (instructionD),
        .regWrite       (regWriteD),
        .aluControl     (aluControlD),
        .imm8           (imm8D),
        .imm16          (imm16D),
        .aluSrcA        (aluSrcAD),
        .aluSrcB        (aluSrcBD),
        .regSrc         (regSrcD),
        .memWrite       (memWriteD),
        .memRead        (memReadD),
        .branch         (branchD),
        .jump           (jumpD),
        .branchControl  (branchControlD),
        .spSrc          (spSrcD),
        .spWrite        (spWriteD),
        .stackSrc       (stackSrcD),
        .stackRead      (stackReadD),
        .stackWrite     (stackWriteD),
        .jrjalr         (jrjalrD),
        .linkWrite      (linkWriteD),
        .popWrite       (popWriteD),
        .trap           (trapD),
        .illegal        (illegalD),
        .usesAlu        (usesAluD)
    );
    
    //link register
    link_register lr (
        .clk(clk),
        .reset(reset),
        .linkEnable(writeLR),
        .newLR(newLR),
        .readLR(readLRD)
    );
    
    //assign linkEnableD = linkWriteD && ~is_branchE && ~jrjalrE;
    //assign newLR = lrSrcD ? readStackW : pcPlus1D;
    assign linkWritePC = linkWriteD && ~is_branchE && ~jrjalrE;
    
    assign newLR = (linkWriteD == 1'b1 && popWriteNewNewW == 1'b0)? pcPlus1D:
                   (linkWriteD == 1'b0 && popWriteNewNewW == 1'b1)? readStackW:
                   (linkWriteD == 1'b1 && popWriteNewNewW == 1'b1)? pcPlus1D: 16'd0;
                   
    assign writeLR = linkWritePC || popWriteNewNewW;
                   
    
    register_file regfile ( 
        .clk       (clk),
        .regWrite  (regWriteW),
        .reset     (reset),
        .readReg1  (readReg1D),
        .readReg2  (readReg2D),
        .writeReg  (writeRegW),
        .writeData (writeDataW),
        .readData1 (readData1D),
        .readData2 (readData2D)
    );
    
        
    assign readReg1D = instructionD [11:9];
    assign readReg2D = instructionD [8:6];
    assign writeRegD = instructionD [5:3];
    
    //stack pointer 
    stack_pointer sp (
        .clk(clk),
        .reset(reset),
        .spWrite(spWriteE),
        .writeSP(writeSP),
        .readSP(spD)
    );
    
    assign lrForwardE = forwardLRE ? readStackW : readLRE;
    assign stackDataE = spSrcE ? {8'b0, operandAE} : lrForwardE;
    
    ID_EX id_ex (
        .clk            (clk),
        .reset          (reset),
        .clr            (flushIDEX),
        .en             (~stall_mul),
        .pcPlus1D       (pcPlus1D),
        .pcCurrentD     (pcCurrentD),//THIS
        .predictionD    (predictionD),//THIS
        .predictedTargetD(predictedTargetD),//THIS
        .readData1D     (readData1D),
        .readData2D     (readData2D),
        .writeRegD      (writeRegD),
        .readReg1D      (readReg1D),
        .readReg2D      (readReg2D),
        .regWriteD      (regWriteD),
        .aluControlD    (aluControlD),
        .imm8D          (imm8D),
        .imm16D         (imm16D),
        .aluSrcAD       (aluSrcAD),
        .aluSrcBD       (aluSrcBD),
        .regSrcD        (regSrcD),
        .memWriteD      (memWriteD),
        .memReadD       (memReadD),
        .branchControlD (branchControlD),
        .branchD        (branchD),
        .stackReadD     (stackReadD),
        .stackWriteD    (stackWriteD),
        .stackSrcD      (stackSrcD),
        .spD            (spD),
        .jrjalrD        (jrjalrD),
        .readLRD        (readLRD),
        .spWriteD       (spWriteD),
        .spSrcD         (spSrcD),
        .popWriteD      (popWriteD),
        .usesAluD       (usesAluD),
        .pcPlus1E       (pcPlus1E),
        .pcCurrentE     (pcCurrentE),
        .predictionE    (predictionE),//THIS
        .predictedTargetE(predictedTargetE),//THIS
        .readData1E     (readData1E),
        .readData2E     (readData2E),
        .writeRegE      (writeRegE),
        .readReg1E      (readReg1E),
        .readReg2E      (readReg2E),
        .regWriteE      (regWriteE),
        .aluControlE    (aluControlE),
        .imm8E          (imm8E),
        .imm16E         (imm16E),
        .aluSrcAE       (aluSrcAE),
        .aluSrcBE       (aluSrcBE),
        .regSrcE        (regSrcE),
        .memWriteE      (memWriteE),
        .memReadE       (memReadE),
        .branchControlE (branchControlE),
        .branchE        (branchE),
        .stackReadE     (stackReadE),
        .stackWriteE    (stackWriteE),
        .stackSrcE      (stackSrcE),
        .spE            (spE),
        .jrjalrE        (jrjalrE),
        .readLRE        (readLRE),
        .spWriteE       (spWriteE),
        .spSrcE         (spSrcE),
        .popWriteE      (popWriteE),
        .usesAluE       (usesAluE)
    );
    
    assign operandAE = (forwardAE == 2'b00) ? readData1E: 
                       (forwardAE == 2'b01) ? aluResultM:
                       (forwardAE == 2'b10) ? writeDataW: imm8M;
                       
    assign operandBE = (forwardBE == 2'b00) ? readData2E:
                       (forwardBE == 2'b01) ? aluResultM:
                       (forwardBE == 2'b10) ? writeDataW: imm8M;
            
    assign spForwardE = forwardSPE ? aluResultM : spE;  
                 
    assign aluInputA = aluSrcAE ? spForwardE : operandAE;                                       
    assign aluInputB = (aluSrcBE == 2'b00) ? operandBE:
                       (aluSrcBE == 2'b01) ? imm8E:
                       (aluSrcBE == 2'b10) ? 8'd1:8'b11111111;
    
    alu alu_inst (
        .clk          (clk),
        .rst_n        (~reset),      
        .a            (aluInputA),
        .b            (aluInputB),
        .alu_ctrl     (aluControlE),
        .result       (aluResultE),
        .mul_busy     (mul_busy),
        .overflow_pos (overflow_pos),
        .overflow_neg (overflow_neg),
        .overflow_u   (overflow_u),
        .overflow_0   (overflow_0)
    );
    
    assign exc_overflow = (overflow_pos | overflow_neg | overflow_u | overflow_0) && usesAluE;
     
//    assign causeEnable = exc_overflow||trapD;
    
    cause_register cause_inst (
        .clk          (clk),
        .reset        (reset),
//        .enable       (causeEnable&&~cause),
        .exc_overflow (exc_overflow),
        .trap         (trapD),
        .illegal      (illegalD),
        .cause        (cause)
    );

    epc_register epc_inst (
        .clk          (clk),
        .reset        (reset),
//        .enable       (causeEnable&&~cause),
        .exc_overflow (exc_overflow),
        .pcE          (pcCurrentE),
        .trap         (trapD),
        .illegal      (illegalD),
        .pcD          (pcCurrentD),
        .epc          (epc)
    );

    comparator comp (
        .readData1 (operandAE),
        .readData2 (operandBE),
        .eq        (eq),
        .lt        (lt)
    );                 


    assign branch_type = (branchControlE == 2'b00) ? eq  :
                         (branchControlE == 2'b01) ? ~eq :
                         (branchControlE == 2'b10) ? lt  : ~lt;

    assign is_branchE = branch_type & branchE;
    assign misprediction = branchE && ((predictionE != is_branchE) | (predictionE && is_branchE && (predictedTargetE != target_addressE)));//THIS
    assign pcSrc = jumpD || jrjalrE ||trapD ;
    
    assign target_addressE = (jrjalrE   ? lrForwardE  :
                             is_branchE ? pcPlus1E : pcPlus1D)
                             + ((jrjalrE || is_branchE) ? imm16E : imm16D); //saves one flush during jal and jump

    assign correctedPC = is_branchE ? target_addressE : pcPlus1E;//THIS
    
    assign pcNext = releaseTrap ? (epc + 16'd1) :
                    pcSrc        ? target_addressE : //THIS
                    misprediction              ? correctedPC :       //THIS
                    (predictionF && btbHit)   ? predictedTargetF :   //THIS
                    pcPlus1;                                         //THIS
    
    //address for stack, updated for PUSH (1), old for POP (0)
    assign stackAddrE = stackSrcE ? aluResultE : spForwardE;
    
    assign writeSP = aluResultE; //can just put aluResultE in sp instantiation  
    
    assign popWriteNewE = popWriteE && ~isJAL;
    
    branchPredictor branchpred (    //THIS
        .clk        (clk),
        .reset      (reset),
        .currentPC  (pcCurrent),
        .prediction (predictionF),
        .predictedTarget (predictedTargetF),
        .btbHit          (btbHit),
        .branch          (branchE),
        .actualTaken     (is_branchE),
        .actualTarget    (target_addressE),
        .pcBranch        (pcCurrentE)
        );
    
    EX_MEM ex_mem (
        .clk        (clk),
        .reset      (reset),
        .clr        (stall_mul),
        .operandBE  (operandBE),
        .writeRegE  (writeRegE),
        .aluResultE (aluResultE),
        .regWriteE  (regWriteE),
        .imm8E      (imm8E),
        .regSrcE    (regSrcE),
        .memWriteE  (memWriteE),
        .memReadE   (memReadE),
        .stackReadE (stackReadE),
        .stackWriteE(stackWriteE),
        .stackDataE (stackDataE),
        .stackAddrE (stackAddrE),
        .spWriteE   (spWriteE),
        .popWriteNewE (popWriteNewE),
        .operandBM  (operandBM),
        .writeRegM  (writeRegM),
        .aluResultM (aluResultM),
        .regWriteM  (regWriteM),
        .imm8M      (imm8M),
        .regSrcM    (regSrcM),
        .memWriteM  (memWriteM),
        .memReadM   (memReadM),
        .stackReadM (stackReadM),
        .stackWriteM(stackWriteM),
        .stackDataM (stackDataM),
        .stackAddrM (stackAddrM),
        .spWriteM   (spWriteM),
        .popWriteNewM (popWriteNewM)
    );

    ram data_memory (
        .clk       (clk),
        .reset     (reset),
        .memWrite  (memWriteM),
        .memRead   (memReadM),
        .address   (aluResultM),
        .writeMem  (operandBM),
        .readMem   (readMemM)
    );
    
    //stack
    stack_memory stack (
        .clk(clk),
        .reset(reset),
        .stackWrite(stackWriteM),
        .stackRead(stackReadM),
        .address(stackAddrM),
        .writeStack(stackDataM),
        .readStack(readStackM)
    );
    
    assign popWriteNewNewM = popWriteNewM && ~isJAL;

    MEM_WB mem_wb (
        .clk        (clk),
        .reset      (reset),
        .writeRegM  (writeRegM),
        .aluResultM (aluResultM),
        .readMemM   (readMemM),
        .regWriteM  (regWriteM),
        .imm8M      (imm8M),
        .regSrcM    (regSrcM),
        .readStackM (readStackM),
        .popWriteNewNewM (popWriteNewNewM),
        .writeRegW  (writeRegW),
        .aluResultW (aluResultW),
        .readMemW   (readMemW),
        .regWriteW  (regWriteW),
        .imm8W      (imm8W),
        .regSrcW    (regSrcW),
        .readStackW (readStackW),
        .popWriteNewNewW (popWriteNewNewW)
    );

    // WB
    assign writeDataW = (regSrcW == 2'b00) ? aluResultW :
                        (regSrcW == 2'b01) ? imm8W      :
                        (regSrcW == 2'b10) ? readMemW   : readStackW[7:0]; //most significant bits discared for readStackW
    
    //hazard unit 
    hazard_unit hu_inst (
        .readReg1E (readReg1E),
        .readReg2E (readReg2E),
        .writeRegM (writeRegM),
        .writeRegW (writeRegW),
        .regWriteM (regWriteM),
        .regWriteW (regWriteW),
        .regSrcM   (regSrcM),
        .instructionD (instructionD),
        .memReadE (memReadE),
        .writeRegE (writeRegE),
        .regWriteE (regWriteE),
        .linkWriteD(linkWriteD),
        .jrjalrD(jrjalrD),
        .jrjalrE(jrjalrE),
        .spWriteE(spWriteE),
        .spWriteM(spWriteM),
        .popWriteE(popWriteE),
        .popWriteNewNewW(popWriteNewNewW),
        .stackWriteE(stackWriteE),
        .stackReadE(stackReadE),
        .mul_busy(mul_busy),
        .trapD(trapD),
        .illegalD(illegalD),
        .forwardAE (forwardAE),
        .forwardBE (forwardBE),
        .forwardSPE(forwardSPE),
        .forwardLRE(forwardLRE),
        .isJAL(isJAL),
        .stall (stall),
        .stall_mul(stall_mul),
        .flushIFID (flushIFID),
        .flushIDEX (flushIDEX)
    );
endmodule
