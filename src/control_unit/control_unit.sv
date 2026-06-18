`timescale 1ns / 1ps

module control_unit (
    input  wire [15:0] instruction,
    
    output reg         RegWrite,     // Write to register file
    output reg  [3:0]  ALUControl,      // ALU operation
    output reg  [2:0]  readReg1,      // First source register
    output reg  [2:0]  readReg2,      /// Second source register / shift amount
    output reg  [2:0]  writeReg,      // Destination register
    output reg  [7:0]  imm8,     // 8-bit immediate value (for ADDI, LI)
    output reg  [15:0] imm16,     //16-bit signextened offset for branches
    output reg         ALUSrc,         /// 0 = register, 1 = immediate
    output reg         RegSrc,         // 00 = ALU, 1 = immediate
    output reg  [1:0] BranchControl, //Controls the Branch MUX
    output reg        Branch         //Activates the branch signal
    
);

    always @(*) begin
        RegWrite   = 0;
        ALUControl = 4'b0000;
        readReg1   = 3'b000;
        readReg2   = 3'b000;
        writeReg   = 3'b000;
        imm8  = 8'd0;
        imm16 = 16'd0;
        ALUSrc     = 0;
        RegSrc     = 0;
        Branch     = 0;
        BranchControl = 2'b00;

        case (instruction[15:12])
            
            4'b0000: begin
                RegWrite   = 1;
                ALUControl = {1'b0, instruction[2:0]};  
                readReg1   = instruction[11:9];        
                readReg2   = instruction[8:6];        
                writeReg   = instruction[5:3];          
                ALUSrc     = 0;
                RegSrc     = 0;
            end

            // R-TYPE SHIFT
            4'b0001: begin
                RegWrite   = 1;
                ALUControl = {1'b1, instruction[2:0]};  
                readReg1   = instruction[11:9];          
                readReg2   = instruction[8:6];         
                writeReg   = instruction[5:3];       
                ALUSrc     = 0;
                RegSrc     = 0;
            end

            //ADDI
            4'b0010: begin
                RegWrite   = 1;
                ALUControl = 4'b0000;     // ADD
                readReg1   = instruction[11:9];         
                readReg2   = 3'b000;                    
                writeReg   = instruction[5:3];         
                imm8  = {{2{instruction[8]}}, instruction[8:6], instruction[2:0]}; 
                ALUSrc     = 1;  // Use immediate
                RegSrc     = 0;
            end

            // LI
           
            4'b0011: begin
                RegWrite   = 1;
                ALUControl = 4'bxxxx;                    
                readReg1   = 3'bxxx;                      
                readReg2   = 3'bxxx;                      
                writeReg   = instruction[5:3];            
                imm8  = {instruction[10:6], instruction[2:0]}; 
                ALUSrc     = 1;  
                RegSrc     = 1;
            end
            
            //BEQ
            
            4'b0110: begin
                RegWrite      = 0;
                ALUControl    = 4'bxxxx;                    
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                     
                writeReg      = 3'bxxx;            
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                ALUSrc        = 1'bx;  
                RegSrc        = 1'bx;
                Branch        = 1;
                BranchControl = 2'b00;
            end
            
            //BNE
            
            4'b0111: begin
                RegWrite      = 0;
                ALUControl    = 4'bxxxx;                    
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                     
                writeReg      = 3'bxxx;            
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                ALUSrc        = 1'bx;  
                RegSrc        = 1'bx;
                Branch        = 1;
                BranchControl = 2'b01;
            end
            
            //BLT
            
            4'b1000: begin
                RegWrite      = 0;
                ALUControl    = 4'bxxxx;                    
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                     
                writeReg      = 3'bxxx;            
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                ALUSrc        = 1'bx;  
                RegSrc        = 1'bx;
                Branch        = 1;
                BranchControl = 2'b10;
            end           
            
            //BGE
            
            4'b1001: begin
                RegWrite      = 0;
                ALUControl    = 4'bxxxx;                    
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                     
                writeReg      = 3'bxxx;            
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                ALUSrc        = 1'bx;  
                RegSrc        = 1'bx;
                Branch        = 1;
                BranchControl = 2'b11;
            end
            
            default: begin
                // Keep defalts
            end
        endcase
    end

endmodule
