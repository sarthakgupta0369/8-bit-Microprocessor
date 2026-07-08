`timescale 1ns / 1ps

module control_unit (
    input  wire [15:0] instruction,
    
    output reg         regWrite,     // Write to register file
    output reg  [3:0]  aluControl,      // alu operation
    output reg  [2:0]  readReg1,      // First source register
    output reg  [2:0]  readReg2,      /// Second source register / shift amount
    output reg  [2:0]  writeReg,      // Destination register
    output reg  [7:0]  imm8,     // 8-bit immediate value (for ADDI, LI)
    output reg  [15:0] imm16,     //16-bit signextened offset for branches
    output reg         aluSrc,         /// 0 = register, 1 = immediate
    output reg  [1:0]  regSrc,         // 00 = alu, 01 = immediate, 10 = data memory output
    output reg         memWrite,
    output reg         memRead,
    output reg  [1:0]  branchControl, //Controls the branch MUX
    output reg         branch,         //Activates the branch signal
    output reg         jump           //jump signal //
    
);

    always @(*) begin
        regWrite   = 0;
        aluControl = 4'b0000;
        readReg1   = 3'b000;
        readReg2   = 3'b000;
        writeReg   = 3'b000;
        imm8  = 8'd0;
        imm16 = 16'd0;
        aluSrc     = 0;
        regSrc     = 2'b00;
        memWrite = 0;
        memRead  = 0;
        branch     = 0;
        jump       = 0; //
        branchControl = 2'b00;

        case (instruction[15:12])
            
            4'b0000: begin
                regWrite   = 1;
                aluControl = {1'b0, instruction[2:0]};  
                readReg1   = instruction[11:9];        
                readReg2   = instruction[8:6];        
                writeReg   = instruction[5:3];          
                aluSrc     = 0;
                regSrc     = 2'b00;
            end

            // R-TYPE SHIFT
            4'b0001: begin
                regWrite   = 1;
                aluControl = {1'b1, instruction[2:0]};  
                readReg1   = instruction[11:9];          
                readReg2   = instruction[8:6];         
                writeReg   = instruction[5:3];       
                aluSrc     = 0;
                regSrc     = 2'b00;
            end

            //ADDI
            4'b0010: begin
                regWrite   = 1;
                aluControl = 4'b0000;     // ADD
                readReg1   = instruction[11:9];         
                readReg2   = 3'b000;                    
                writeReg   = instruction[5:3];         
                imm8  = {{2{instruction[8]}}, instruction[8:6], instruction[2:0]}; 
                aluSrc     = 1;  // Use immediate
                regSrc     = 2'b00;
            end

            // LI
           
            4'b0011: begin
                regWrite   = 1;
                aluControl = 4'bxxxx;                    
                readReg1   = 3'bxxx;                      
                readReg2   = 3'bxxx;                      
                writeReg   = instruction[5:3];            
                imm8  = {instruction[11:6], instruction[2:1]}; 
                aluSrc     = 1;  
                regSrc     = 2'b01;
            end
            
            //LOAD
            
            4'b0100: begin
                regWrite   = 1;
                aluControl = 4'b0000;   //ADD                  
                readReg1   = instruction[11:9];                      
                readReg2   = 3'bxxx;                      
                writeReg   = instruction[5:3];            
                imm8  = {{2{instruction[8]}},instruction[8:6], instruction[2:0]}; 
                aluSrc     = 1;  
                regSrc     = 2'b10;
                memWrite   = 0;
                memRead    = 1;
            end
            
            //STORE
            
             4'b0101: begin
                regWrite   = 0;
                aluControl = 4'b0000;  //ADD                   
                readReg1   = instruction[11:9];                      
                readReg2   = instruction[8:6];                      
                writeReg   = 3'bxxx;            
                imm8  = {{2{instruction[5]}},instruction[5:0]}; 
                aluSrc     = 1;  
                regSrc     = 2'bxx;
                memWrite   = 1;
                memRead    = 0;
            end
            
            //BEQ
            
            4'b0110: begin
                regWrite      = 0;
                aluControl    = 4'bxxxx;                    
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                     
                writeReg      = 3'bxxx;            
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                aluSrc        = 1'bx;  
                regSrc        = 2'bxx;
                branch        = 1;
                branchControl = 2'b00;
            end
            
            //BNE
            
            4'b0111: begin
                regWrite      = 0;
                aluControl    = 4'bxxxx;                    
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                     
                writeReg      = 3'bxxx;            
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                aluSrc        = 1'bx;  
                regSrc        = 2'bxx;
                branch        = 1;
                branchControl = 2'b01;
            end
            
            //BLT
            
            4'b1000: begin
                regWrite      = 0;
                aluControl    = 4'bxxxx;                    
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                     
                writeReg      = 3'bxxx;            
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                aluSrc        = 1'bx;  
                regSrc        = 2'bxx;
                branch        = 1;
                branchControl = 2'b10;
            end           
            
            //BGE
            
            4'b1001: begin
                regWrite      = 0;
                aluControl    = 4'bxxxx;                    
                readReg1      = instruction[11:9];          
                readReg2      = instruction[8:6];                     
                writeReg      = 3'bxxx;            
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                aluSrc        = 1'bx;  
                regSrc        = 2'bxx;
                branch        = 1;
                branchControl = 2'b11;
            end
            
            //jump

            4'b1010: begin
                aluControl    = 4'bxxxx;
                writeReg      = 3'bxxx;
                imm16         = {{4{instruction[11]}}, instruction[11:0]}; 
                aluSrc        = 1'bx;  
                regSrc        = 2'bxx;
                jump          = 1;
            end

            //NOP

            4'b1111: begin
                aluControl    = 4'bxxxx;
                writeReg      = 3'bxxx;
                imm8          = 8'dx;
                imm16         = 16'dx;
                aluSrc        = 1'bx;
                regSrc        = 2'bxx;
            end

            default: begin
                // Keep defalts
            end
        endcase
    end

endmodule
