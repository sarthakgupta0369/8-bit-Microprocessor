`timescale 1ns / 1ps

module control_unit (
    input  wire [15:0] instruction,
    
    output reg         RegWrite,     // Write to register file
    output reg  [3:0]  ALUControl,      // ALU operation
    output reg  [2:0]  readReg1,      // First source register
    output reg  [2:0]  readReg2,      /// Second source register / shift amount
    output reg  [2:0]  writeReg,      // Destination register
    output reg  [7:0]  immediate,     // 8-bit immediate value (for ADDI, LI)
    output reg         ALUSrc,         /// 0 = register, 1 = immediate
    output reg  [1:0]  RegSrc         // 00 = ALU, 1 = immediate
);

    always @(*) begin
        RegWrite   = 0;
        ALUControl = 4'b0000;
        readReg1   = 3'b000;
        readReg2   = 3'b000;
        writeReg   = 3'b000;
        immediate  = 8'd0;
        ALUSrc     = 0;
        RegSrc     = 0;

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
                immediate  = {{2{instruction[8]}}, instruction[8:6], instruction[2:0]}; 
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
                immediate  = {instruction[10:6], instruction[2:0]}; 
                ALUSrc     = 1;  
                RegSrc     = 1;
            end
            default: begin
                // Keep defalts
            end
        endcase
    end

endmodule
