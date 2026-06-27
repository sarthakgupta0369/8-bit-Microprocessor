`timescale 1ns / 1ps

module control_unit (
    input  wire [15:0] instruction,
    input  wire [2:0]  count,
    
    output reg         RegWrite,     // Write to register file
    output reg  [3:0]  ALUControl,      // ALU operation
    output reg  [2:0]  readReg1,      // First source register
    output reg  [2:0]  readReg2,      /// Second source register / shift amount
    output reg  [2:0]  writeReg,      // Destination register
    output reg  [7:0]  imm8,     // 8-bit immediate value (for ADDI, LI)
    output reg  [15:0] imm16,     //16-bit signextened offset for branches
    output reg         ALUSrc,         /// 0 = register, 1 = immediate
    output reg  [1:0]  RegSrc,         // 00 = ALU, 01 = immediate, 10 = data memory output
    output reg         memWrite,
    output reg         memRead,
    output reg  [1:0]  BranchControl, //Controls the Branch MUX
    output reg         Branch,         //Activates the branch signal
    output reg         Jump,           //jump signal //
    output reg         instructionDone //signal to set count = 0    
    
    
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
        RegSrc     = 2'b00;
        memWrite = 0;
        memRead  = 0;
        Branch     = 0;
        Jump       = 0; //
        BranchControl = 2'b00;
        instructionDone = 0;

        case (instruction[15:12])
            
            4'b0000: begin
                ALUControl = {1'b0, instruction[2:0]};  
                readReg1   = instruction[11:9];        
                readReg2   = instruction[8:6];        
                writeReg   = instruction[5:3];          
                ALUSrc     = 0;
                RegSrc     = 2'b00;
                if (count == 3'd3) begin
                    RegWrite   = 1'b1;
                    instructionDone = 1'b1;
                end 
            end

            // R-TYPE SHIFT
            4'b0001: begin
                ALUControl = {1'b1, instruction[2:0]};  
                readReg1   = instruction[11:9];          
                readReg2   = instruction[8:6];         
                writeReg   = instruction[5:3];       
                ALUSrc     = 0;
                RegSrc     = 2'b00;
                if (count == 3'd3) begin
                    RegWrite   = 1'b1;
                    instructionDone = 1'b1;
                end 
            end

            //ADDI
            4'b0010: begin
                ALUControl = 4'b0000;     // ADD
                readReg1   = instruction[11:9];         
                readReg2   = 3'b000;                    
                writeReg   = instruction[5:3];         
                imm8  = {{2{instruction[8]}}, instruction[8:6], instruction[2:0]}; 
                ALUSrc     = 1'b1;  // Use immediate
                RegSrc     = 2'b00;
                if (count == 3'd3) begin
                    RegWrite   = 1'b1;
                    instructionDone = 1'b1;
                end                  
            end

            // LI
           
            4'b0011: begin
                writeReg = instruction[5:3];
                imm8     = {instruction[11:6], instruction[2:1]};
                ALUSrc   = 1'b1;
                RegSrc   = 2'b01;
                if (count == 3'd2) begin
                    RegWrite        = 1'b1;
                    instructionDone = 1'b1;
                end 
            end
            
            //LOAD
            
            4'b0100: begin
                readReg1   = instruction[11:9];
                writeReg   = instruction[5:3];
                imm8       = {{2{instruction[8]}}, instruction[8:6], instruction[2:0]};
                ALUSrc     = 1'b1;
                ALUControl = 4'b0000;
                RegSrc     = 2'b10;
                if (count == 3'd3) memRead = 1'b1;
                if (count == 3'd4) begin
                    RegWrite        = 1'b1;
                    instructionDone = 1'b1;
                end
            end
            
            //STORE
            
             4'b0101: begin
                readReg1 = instruction[11:9];
                readReg2 = instruction[8:6];
                imm8     = {{2{instruction[5]}}, instruction[5:0]};
                ALUSrc   = 1'b1;
                if (count == 3'd3) begin
                    memWrite        = 1'b1;
                    instructionDone = 1'b1;
                end
            end
            
            //BEQ
            
            4'b0110: begin                   
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                                
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                BranchControl = 2'b00;
                if(count == 3'd2) begin
                    Branch        = 1'b1;
                    instructionDone = 1'b1;
                end
            end
            
            //BNE
            
            4'b0111: begin                 
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                            
                imm16         = {{10{instruction[5]}}, instruction[5:0]};
                BranchControl = 2'b01; 
                if(count == 3'd2) begin
                    Branch        = 1'b1;
                    instructionDone = 1'b1;
                end
            end
            
            //BLT
            
            4'b1000: begin
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                            
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                BranchControl = 2'b10;
                if(count == 3'd2) begin
                    Branch        = 1'b1;
                    instructionDone = 1'b1;
                end
            end           
            
            //BGE
            
            4'b1001: begin
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                            
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                BranchControl = 2'b11;
                if(count == 3'd2) begin
                    Branch        = 1'b1;
                    instructionDone = 1'b1;
                end
            end
            
            //JUMP

            4'b1010: begin
                imm16         = {{4{instruction[11]}}, instruction[11:0]};
                if(count == 3'd2) begin 
                    Jump          = 1'b1;
                    instructionDone = 1'b1;
                end
            end

            //NOP

            4'b1111: begin
                if (count == 3'd1) instructionDone = 1'b1;
            end

            default: begin
                // Keep defalts
            end
        endcase
    end

endmodule
