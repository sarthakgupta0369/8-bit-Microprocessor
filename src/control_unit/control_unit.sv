`timescale 1ns / 1ps

module control_unit (
    input  wire [15:0] instruction,
    
    output reg         regWrite,     // Write to register file
    output reg  [3:0]  aluControl,      // alu operation
    output reg  [7:0]  imm8,     // 8-bit immediate value (for ADDI, LI)
    output reg  [15:0] imm16,     //16-bit signextened offset for branches
    output reg  [1:0]  aluSrcB,         /// 00 = operandB, 01 = immediate, 10 = +1, 11 = -1
    output reg         aluSrcA,       //0 = operandA, 1 = sp
    output reg  [1:0]  regSrc,         // 00 = alu, 01 = immediate, 10 = data memory output
    output reg         memWrite,
    output reg         memRead,
    output reg  [1:0]  branchControl, //Controls the branch MUX
    output reg         branch,         //Activates the branch signal
    output reg         jump,           //jump signal //
    output reg         spSrc,
    output reg         spWrite,
    output reg         stackSrc,
    output reg         stackRead,
    output reg         stackWrite,
    output reg         jrjalr,
    output reg         linkWrite,
    output reg         popWrite
);

    always @(*) begin
        regWrite   = 0;
        aluControl = 4'b0000;
        imm8  = 8'd0;
        imm16 = 16'd0;
        aluSrcA = 0;
        aluSrcB     = 2'b00;
        regSrc     = 2'b00;
        memWrite = 0;
        memRead  = 0;
        branch     = 0;
        jump       = 0; //
        branchControl = 2'b00;
        spSrc = 0;
        spWrite = 0;
        stackSrc = 0;
        stackRead = 0;
        stackWrite = 0;
        jrjalr = 0;
        linkWrite = 0;
        popWrite = 0;

        case (instruction[15:12])
            
            4'b0000: begin
                regWrite   = 1;
                aluControl = {1'b0, instruction[2:0]};          
                aluSrcB    = 2'b00;
                regSrc     = 2'b00;
            end

            // R-TYPE SHIFT
            4'b0001: begin
                regWrite   = 1;
                aluControl = {1'b1, instruction[2:0]};    
                aluSrcB    = 2'b00;
                regSrc     = 2'b00;
            end

            //ADDI
            4'b0010: begin
                regWrite   = 1;
                aluControl = 4'b0000;     // ADD         
                imm8       = {{2{instruction[8]}}, instruction[8:6], instruction[2:0]}; 
                aluSrcB    = 2'b01;  // Use immediate
                regSrc     = 2'b00;
            end

            // LI
           
            4'b0011: begin
                regWrite   = 1;                              
                imm8       = {instruction[11:6], instruction[2:1]}; 
                aluSrcB    = 2'b01;  
                regSrc     = 2'b01;
            end
            
            //LOAD
            
            4'b0100: begin
                regWrite   = 1;
                aluControl = 4'b0000;   //ADD                           
                imm8       = {{2{instruction[8]}},instruction[8:6], instruction[2:0]}; 
                aluSrcB    = 2'b01;  
                regSrc     = 2'b10;
                memWrite   = 0;
                memRead    = 1;
            end
            
            //STORE
            
             4'b0101: begin
                regWrite   = 0;
                aluControl = 4'b0000;  //ADD                    
                imm8       = {{2{instruction[5]}},instruction[5:0]}; 
                aluSrcB    = 2'b01;  
                regSrc     = 2'bxx;
                memWrite   = 1;
                memRead    = 0;
            end
            
            //BEQ
            
            4'b0110: begin
                regWrite      = 0;                      
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                branch        = 1;
                branchControl = 2'b00;
            end
            
            //BNE
            
            4'b0111: begin
                regWrite      = 0;                          
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                branch        = 1;
                branchControl = 2'b01;
            end
            
            //BLT
            
            4'b1000: begin
                regWrite      = 0;                           
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                branch        = 1;
                branchControl = 2'b10;
            end           
            
            //BGE
            
            4'b1001: begin
                regWrite      = 0;                         
                imm16         = {{10{instruction[5]}}, instruction[5:0]}; 
                branch        = 1;
                branchControl = 2'b11;
            end
            
            //jump

           4'b1010: begin
                imm16         = {{6{instruction[11]}}, instruction[11:2]}; 
                jump          = 1;
                
                case (instruction[1:0])
                
                    2'b00: begin //JMP
                        jrjalr    = 0;
                        linkWrite = 0;
                    end
                    
                    2'b01: begin //JAL
                        jrjalr    = 0;
                        linkWrite = 1;
                    end
                    
                    2'b10: begin //JR
                        jrjalr    = 1;
                        linkWrite = 0;
                    end
                    
                    2'b11: begin //JALR
                        jrjalr    = 1;
                        linkWrite = 1;
                    end
                endcase 
            end
            
            //PUSH
            4'b1011: begin
                imm8 = instruction[8:1];
                aluSrcA = 1'b1;
                stackWrite = 1'b1;
                spWrite = 1'b1; //useless, always 1
                stackSrc = 1'b1;
                stackRead = 1'b0;
                aluSrcB = 2'b10;
                //if (imm8 == 8'd0 || imm8 == 8'b11111111) begin
                        //aluSrcB = 2'b10;
                    //end
                    //else begin
                        //aluSrcB = 2'b01; 
                    //end
                case (instruction[0])
                    1'b0: begin //LR
                        spSrc = 1'b0;
                    end
                    1'b1: begin //RegFile
                        spSrc = 1'b1;
                    end
                 endcase  
            end
            
            //POP
            4'b1100: begin
                imm8 = {instruction[11:6],instruction[2:1]};
                aluSrcA = 1'b1;
                stackWrite = 1'b0;
                stackRead = 1'b1;
                stackSrc = 1'b0;
                spWrite = 1'b1;
                aluSrcB = 2'b11;
                //if (imm8 == 8'd0 || imm8 == 8'd1) begin
                        //aluSrcB = 2'b11;
                    //end
                    //else begin
                        //aluSrcB = 2'b01; 
                    //end
                case (instruction[0])
                    1'b0: begin //LR
                        spSrc = 1'b0;
                        popWrite = 1'b1;
                    end
                    1'b1: begin //RegFile
                        spSrc = 1'b1;
                        regWrite = 1'b1;
                        regSrc = 2'b11;
                    end
                endcase  
            end          

            //NOP

            4'b1111: begin
            //all quiet on the frontal lobe
            end

            default: begin
                        regWrite   = 0;
                        aluControl = 4'b0000;
                        imm8  = 8'd0;
                        imm16 = 16'd0;
                        aluSrcA = 0;
                        aluSrcB     = 2'b00;
                        regSrc     = 2'b00;
                        memWrite = 0;
                        memRead  = 0;
                        branch     = 0;
                        jump       = 0; //
                        branchControl = 2'b00;
                        spSrc = 0;
                        spWrite = 0;
                        stackSrc = 0;
                        stackRead = 0;
                        stackWrite = 0;
                        jrjalr = 0;
                        linkWrite = 0;
                        popWrite = 0;
            end
        endcase
    end

endmodule
