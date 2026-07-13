`timescale 1ns / 1ps

module cpu (
    input  wire clk,
    input  wire reset
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

    ProgramCounter pc_inst (
        .clk      (clk),
        .rst      (reset),
        .pc_write (~stall),
        .pc_next  (pcNext),
        .pc       (pcCurrent)
    );

    assign pcPlus1 = pcCurrent + 16'd1;

   
    instruction_memory imem (
        .pc          (pcCurrent),
        .instruction (instructionF)
    );

    //IF /ID
    wire [15:0] pcPlus1D;
    wire [15:0] instructionD;

    IF_ID if_id (
        .clk          (clk),
        .reset        (reset),
        .clr          (flushIFID),
        .en           (~stall),
        .pcPlus1I     (pcPlus1),
        .instructionI (instructionF),
        .pcPlus1D     (pcPlus1D),
        .instructionD (instructionD)
    );


  //ID

    wire        regWriteD;
    wire [3:0]  aluControlD;
    wire [2:0]  readReg1D;
    wire [2:0]  readReg2D;
    wire [2:0]  writeRegD;
    wire [7:0]  imm8D;
    wire [15:0] imm16D;
    wire        aluSrcD;
    wire [1:0]  regSrcD;
    wire        memWriteD;
    wire        memReadD;
    wire [1:0]  branchControlD;
    wire        branchD;
    wire        jumpD;

    control_unit ctrl (
        .instruction    (instructionD),
        .regWrite       (regWriteD),
        .aluControl     (aluControlD),
        .readReg1       (readReg1D),
        .readReg2       (readReg2D),
        .writeReg       (writeRegD),
        .imm8           (imm8D),
        .imm16          (imm16D),
        .aluSrc         (aluSrcD),
        .regSrc         (regSrcD),
        .memWrite       (memWriteD),
        .memRead        (memReadD),
        .branch         (branchD),
        .jump           (jumpD),
        .branchControl  (branchControlD)
    );

   
    wire [7:0] readData1D;
    wire [7:0] readData2D;

// write feedback
    wire [7:0] writeDataW;
    wire       regWriteW;
    wire [2:0] writeRegW;

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
    
    // EX/MEM
    wire [7:0]  operandBM;
    wire [2:0]  writeRegM;
    wire [7:0]  aluResultM;
    wire        regWriteM; 
    wire [7:0]  imm8M;
    wire [1:0]  regSrcM;
    wire        memWriteM;
    wire        memReadM;

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
    wire        aluSrcE;
    wire [1:0]  regSrcE;
    wire        memWriteE;
    wire        memReadE;
    wire [1:0]  branchControlE;
    wire        branchE;
    wire        jumpE;
    wire        flushIDEX;

    ID_EX id_ex (
        .clk            (clk),
        .reset          (reset),
        .clr            (flushIDEX),
        .pcPlus1D       (pcPlus1D),
        .readData1D     (readData1D),
        .readData2D     (readData2D),
        .writeRegD      (writeRegD),
        .readReg1D      (readReg1D),
        .readReg2D      (readReg2D),
        .regWriteD      (regWriteD),
        .aluControlD    (aluControlD),
        .imm8D          (imm8D),
        .imm16D         (imm16D),
        .aluSrcD        (aluSrcD),
        .regSrcD        (regSrcD),
        .memWriteD      (memWriteD),
        .memReadD       (memReadD),
        .branchControlD (branchControlD),
        .branchD        (branchD),
        .jumpD          (jumpD),
        .pcPlus1E       (pcPlus1E),
        .readData1E     (readData1E),
        .readData2E     (readData2E),
        .writeRegE      (writeRegE),
        .readReg1E      (readReg1E),
        .readReg2E      (readReg2E),
        .regWriteE      (regWriteE),
        .aluControlE    (aluControlE),
        .imm8E          (imm8E),
        .imm16E         (imm16E),
        .aluSrcE        (aluSrcE),
        .regSrcE        (regSrcE),
        .memWriteE      (memWriteE),
        .memReadE       (memReadE),
        .branchControlE (branchControlE),
        .branchE        (branchE),
        .jumpE          (jumpE)
    );

    // alu
    wire [7:0] operandAE;
    wire [7:0] operandBE; //the wire that goes into the aluInputB MUX 
    wire [7:0] aluInputB;
    wire [7:0] aluResultE;
    wire       zero, carry, overflow, negative, sign, parity;
    wire [1:0] forwardAE;
    wire [1:0] forwardBE;
    
    assign operandAE = (forwardAE == 2'b00) ? readData1E: 
                       (forwardAE == 2'b01) ? aluResultM:
                       (forwardAE == 2'b10) ? writeDataW: imm8M;
                       
    assign operandBE = (forwardBE == 2'b00) ? readData2E:
                       (forwardBE == 2'b01) ? aluResultM:
                       (forwardBE == 2'b10) ? writeDataW: imm8M;
                                           
    assign aluInputB = aluSrcE ? imm8E : operandBE;

    alu alu_inst (
        .a        (operandAE),
        .b        (aluInputB),
        .alu_ctrl (aluControlE),
        .result   (aluResultE),
        .zero     (zero),
        .carry    (carry),
        .overflow (overflow),
        .negative (negative),
        .sign     (sign),
        .parity   (parity)
    );
    
    //hazard unit 
    
    hazard_unit hu_inst (
        .readReg1E (readReg1E),
        .readReg2E (readReg2E),
        .writeRegM (writeRegM),
        .writeRegW (writeRegW),
        .regWriteM (regWriteM),
        .regWriteW (regWriteW),
        .regSrcM   (regSrcM),
        .is_branchE (is_branchE),
        .instructionD (instructionD),
        .memReadE (memReadE),
        .writeRegE (writeRegE),
        .regWriteE (regWriteE),
        .forwardAE (forwardAE),
        .forwardBE (forwardBE),
        .stall (stall),
        .flushIFID (flushIFID),
        .flushIDEX (flushIDEX)
    );

  //branch
    wire eq;
    wire lt;
    wire branch_type;

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
    assign pcSrc = is_branchE | jumpD;
    
    assign target_addressE = is_branchE ? (pcPlus1E + imm16E) : (pcPlus1D + imm16D); //saves one cycle during jumps

    assign pcNext = (pcSrc) ? target_addressE : pcPlus1;


    EX_MEM ex_mem (
        .clk        (clk),
        .reset      (reset),
        .operandBE  (operandBE),
        .writeRegE  (writeRegE),
        .aluResultE (aluResultE),
        .regWriteE  (regWriteE),
        .imm8E      (imm8E),
        .regSrcE    (regSrcE),
        .memWriteE  (memWriteE),
        .memReadE   (memReadE),
        .operandBM  (operandBM),
        .writeRegM  (writeRegM),
        .aluResultM (aluResultM),
        .regWriteM  (regWriteM),
        .imm8M      (imm8M),
        .regSrcM    (regSrcM),
        .memWriteM  (memWriteM),
        .memReadM   (memReadM)
    );

    // MEM

    wire [7:0] readMemM;

    ram data_memory (
        .clk       (clk),
        .reset     (reset),
        .memWrite  (memWriteM),
        .memRead   (memReadM),
        .address   (aluResultM),
        .writeMem  (operandBM),
        .readMem   (readMemM)
    );

    // MEM/WB 
    wire [7:0]  aluResultW;
    wire [7:0]  readMemW;
    wire [7:0]  imm8W;
    wire [1:0]  regSrcW;

    MEM_WB mem_wb (
        .clk        (clk),
        .reset      (reset),
        .writeRegM  (writeRegM),
        .aluResultM (aluResultM),
        .readMemM   (readMemM),
        .regWriteM  (regWriteM),
        .imm8M      (imm8M),
        .regSrcM    (regSrcM),
        .writeRegW  (writeRegW),
        .aluResultW (aluResultW),
        .readMemW   (readMemW),
        .regWriteW  (regWriteW),
        .imm8W      (imm8W),
        .regSrcW    (regSrcW)
    );


    // WB
    assign writeDataW = (regSrcW == 2'b00) ? aluResultW :
                        (regSrcW == 2'b01) ? imm8W      :
                        (regSrcW == 2'b10) ? readMemW   : 8'd0;

endmodule
