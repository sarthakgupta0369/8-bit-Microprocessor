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


    ProgramCounter pc_inst (
        .clk      (clk),
        .rst      (reset),
        .pc_write (1'b1),
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
        .clk           (clk),
        .reset         (reset),
        .pcPlus1I     (pcPlus1),
        .instructionI  (instructionF),
        .pcPlus1D     (pcPlus1D),
        .instructionD  (instructionD)
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

 //ID/ EX
    wire [15:0] pcPlus1E;
    wire [7:0]  readData1E;
    wire [7:0]  readData2E;
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

    ID_EX id_ex (
        .clk            (clk),
        .reset          (reset),
        .pcPlus1D       (pcPlus1D),
        .readData1D     (readData1D),
        .readData2D     (readData2D),
        .writeRegD      (writeRegD),
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
    wire [7:0] aluInputB;
    wire [7:0] aluResultE;
    wire       zero, carry, overflow, negative, sign, parity;

    assign aluInputB = aluSrcE ? imm8E : readData2E;

    alu alu_inst (
        .a        (readData1E),
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

  //branch
    wire eq;
    wire lt;
    wire branch_type;

    comparator comp (
        .readData1 (readData1E),
        .readData2 (readData2E),
        .eq        (eq),
        .lt        (lt)
    );


    assign branch_type = (branchControlE == 2'b00) ? eq  :
                         (branchControlE == 2'b01) ? ~eq :
                         (branchControlE == 2'b10) ? lt  : ~lt;

    assign is_branchE = branch_type & branchE;

    assign target_addressE = pcPlus1E + imm16E;

    assign pcNext = (is_branchE | jumpE) ? target_addressE : pcPlus1;

    // EX/MEM
    wire [7:0]  readData2M;
    wire [2:0]  writeRegM;
    wire [7:0]  aluResultM;
    wire        regWriteM;
    wire [7:0]  imm8M;
    wire [1:0]  regSrcM;
    wire        memWriteM;
    wire        memReadM;

    EX_MEM ex_mem (
        .clk        (clk),
        .reset      (reset),
        .readData2E (readData2E),
        .writeRegE  (writeRegE),
        .aluResultE (aluResultE),
        .regWriteE  (regWriteE),
        .imm8E      (imm8E),
        .regSrcE    (regSrcE),
        .memWriteE  (memWriteE),
        .memReadE   (memReadE),
        .readData2M (readData2M),
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
        .writeMem  (readData2M),
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
