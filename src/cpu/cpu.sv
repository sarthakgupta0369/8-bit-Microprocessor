
`timescale 1ns / 1ps

module cpu (
    input  wire clk,
    input  wire reset
);

    wire [15:0] pc_current;
    wire [15:0] pc_next;
    wire [15:0] pcAdderOut; //replaces "target_address"
    wire        pc_write;
    reg  [15:0] pcPlus1; //register that stores pcPlus1
    
    wire [15:0] pcAdderA;
    wire [15:0] pcAdderB;
    
    wire [15:0] instruction;
    
    wire [2:0]  count; //step counter to Control Unit
    
    // Control signals
    wire        RegWrite;
    wire [3:0]  ALUControl;
    wire [2:0]  writeReg;
    wire [7:0]  imm8; 
    wire [15:0] imm16;
    wire        ALUSrc;
    wire [1:0]  BranchControl;
    wire        Branch;
    wire        Jump; //
    wire        memWrite;
    wire        memRead;
    wire        instructionDone; //signals the step counter to 0
    
    reg  [7:0]  imm8Reg; //register to store imm8
    
    wire [2:0]  readReg1;
    wire [2:0]  readReg2;
    // Register file
    wire [7:0]  readData1;
    wire [7:0]  readData2;
    wire [7:0]  writeData;
    wire [1:0]      RegSrc;
    
    // ALU
    wire [7:0]  aluResult;
    wire [7:0]  aluInputB;
    wire        zero, carry, overflow, negative, sign, parity;
    reg  [7:0]  aluOut; //register to store aluResult
    
    //Data Memory
    wire [7:0]  memAddress;
    wire [7:0]  writeMem;
    wire [7:0]  readMem;
    reg  [7:0]  memData; //register to store readMem
    
    //Comparator
    wire        eq;
    wire        lt;
    
    //Branch MUX output
    wire branch_type;
    
    //signal to take branch
    wire is_branch;
    
    wire pcSrcAB; //controls the A and B input muxes of the pcAdder

    
    control_unit ctrl (
        .instruction(instruction),
        .count (count),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .writeReg(writeReg),
        .imm8(imm8),
        .imm16(imm16),
        .ALUSrc(ALUSrc),
        .RegSrc(RegSrc),
        .memWrite(memWrite),
        .memRead(memRead),
        .Branch(Branch),
        .Jump(Jump),                      //
        .BranchControl(BranchControl),
        .instructionDone(instructionDone)
    );
    
    always @(posedge clk) begin
        imm8Reg <= imm8;
    end   
  
    StepCounter sc_inst (
        .clk(clk),
        .reset(reset),
        .instructionDone(instructionDone),
        .count(count)
    );
    
    ProgramCounter pc_inst (
        .clk(clk),
        .rst(reset),
        .pc_write(pc_write),
        .pc_next(pc_next),
        .pc(pc_current)
    );
    
    assign pcSrcAB = Branch|Jump;
    assign pcAdderA = (pcSrcAB)?pcPlus1:pc_current;
    assign pcAdderB = (pcSrcAB)?imm16:16'd1;
    assign pcAdderOut = pcAdderA + pcAdderB;
    
    always @(posedge clk) begin
        pcPlus1 <= pcAdderOut;    
    end  

    assign pc_write = instructionDone;
    
    comparator comp (
    .readData1(readData1),
    .readData2(readData2),
    .eq(eq),
    .lt(lt)
    );
    
    assign branch_type = (BranchControl == 2'b00)? eq:
                         (BranchControl == 2'b01)? ~eq:
                         (BranchControl == 2'b10)? lt:~lt;
                         
    assign is_branch = branch_type&Branch;
    
    assign pc_next = ((is_branch)|Jump)?pcAdderOut:pcPlus1;       //             

    instruction_memory imem (
        .pc(pc_current),
        .instruction(instruction)
    );

    register_file regfile (
        .clk(clk),
        .RegWrite(RegWrite),
        .reset(reset),
        .readReg1(readReg1),
        .readReg2(readReg2),
        .writeReg(writeReg),
        .writeData(writeData),
        .readData1(readData1),
        .readData2(readData2)
    );
    
    assign readReg1 = instruction[11:9];
    assign readReg2 = instruction[8:6];

    assign aluInputB = ALUSrc ? imm8Reg : readData2;
    
    alu alu_inst (
        .a(readData1),
        .b(aluInputB),
        .alu_ctrl(ALUControl),
        .result(aluResult),
        .zero(zero),
        .carry(carry),
        .overflow(overflow),
        .negative(negative),
        .sign(sign),
        .parity(parity)
    );
    
    always @(posedge clk) begin //register to store aluResult
        aluOut <= aluResult;
    end 
     
    ram data_memory (
        .clk(clk),
        .reset(reset),
        .memWrite(memWrite),
        .memRead(memRead),
        .address(memAddress),
        .writeMem(writeMem),
        .readMem(readMem)
    );
    
    always @(posedge clk) begin //register to store readMem
        memData <= readMem;
    end 
    
    assign memAddress = aluOut;
    assign writeMem   = readData2;
    
    assign writeData = (RegSrc == 2'b00) ? aluOut:
                       (RegSrc == 2'b01) ? imm8Reg: 
                       (RegSrc == 2'b10) ? memData:8'd0;

endmodule
