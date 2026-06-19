
`timescale 1ns / 1ps

module cpu (
    input  wire clk,
    input  wire reset
);

    
    wire [15:0] pc_current;
    wire [15:0] pc_next;
    wire [15:0] pc_plus1;
    wire [15:0] target_address;
    
    wire [15:0] instruction;
    
    // Control signals
    wire        RegWrite;
    wire [3:0]  ALUControl;
    wire [2:0]  readReg1;
    wire [2:0]  readReg2;
    wire [2:0]  writeReg;
    wire [7:0]  imm8; 
    wire [15:0] imm16;
    wire        ALUSrc;
    wire [1:0]  BranchControl;
    wire        Branch;
    wire        Jump; //
    wire        memWrite;
    wire        memRead;
    
    
    // Register file
    wire [7:0]  readData1;
    wire [7:0]  readData2;
    wire [7:0]  writeData;
    wire [1:0]      RegSrc;
    
    // ALU
    wire [7:0]  aluResult;
    wire [7:0]  aluInputB;
    wire        zero, carry, overflow, negative, sign, parity;
    
    //Data Memory
    wire [7:0]  memAddress;
    wire [7:0]  writeMem;
    wire [7:0]  readMem;
    
    //Comparator
    wire        eq;
    wire        lt;
    
    //Branch MUX output
    wire branch_type;
    
    //signal to take branch
    wire is_branch;

    
    control_unit ctrl (
        .instruction(instruction),
        .RegWrite(RegWrite),
        .ALUControl(ALUControl),
        .readReg1(readReg1),
        .readReg2(readReg2),
        .writeReg(writeReg),
        .imm8(imm8),
        .imm16(imm16),
        .ALUSrc(ALUSrc),
        .RegSrc(RegSrc),
        .memWrite(memWrite),
        .memRead(memRead),
        .Branch(Branch),
        .Jump(Jump),                      //
        .BranchControl(BranchControl)
    );

    ProgramCounter pc_inst (
        .clk(clk),
        .rst(reset),
        .pc_write(1'b1),
        .pc_next(pc_next),
        .pc(pc_current)
    );
    
    assign pc_plus1 = pc_current + 16'd1;
    assign target_address = pc_plus1 + imm16;
    
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
    
    assign pc_next = ((is_branch)|Jump)?target_address:pc_plus1;       //             

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

    assign aluInputB = ALUSrc ? imm8 : readData2;
    
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
     
    ram data_memory (
        .clk(clk),
        .memWrite(memWrite),
        .memRead(memRead),
        .address(memAddress),
        .writeMem(writeMem),
        .readMem(readMem)
    );
    
     assign memAddress = aluResult;
     assign writeMem   = readData2;
    
     assign writeData = (RegSrc == 2'b00) ? aluResult:
                       (RegSrc == 2'b01) ? imm8: 
                       (RegSrc == 2'b10) ? readMem:8'd0;

endmodule// New file
