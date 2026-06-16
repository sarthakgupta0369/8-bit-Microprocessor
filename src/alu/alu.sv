`timescale 1ns / 1ps

module alu #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0]     a,          
    input  logic [WIDTH-1:0]     b,         
    input  logic [3:0]           alu_ctrl,   
    output logic [WIDTH-1:0]     result,
    output logic                 zero,       // result == 0
    output logic                 carry,      // carry out
    output logic                 overflow,   // signed overflow
    output logic                 negative,   // MSB of result
    output logic                  sign,
    output logic                 parity     // even parity of result
);

    // alu_ctrl = {opcode[0], func[2:0]}
    // 0000 = ADD,  0001 = SUB,  0010 = AND,  0011 = XOR
    // 0100 = NOT,  0101 = ADDU, 0110 = SUBU, 0111 = reserved
    // 1000 = SLL,  1001 = SRL,  1010 = SRA,  1011 = ROL
    // 1100 = ROR,  1101-1111 = reserved
  
    
    // Operation type flags
    logic is_add, is_sub, is_addu, is_subu;
    logic is_and, is_xor, is_not;
    logic is_sll, is_srl, is_sra, is_rol, is_ror;
    logic is_shift;
    logic is_arith;      
    logic is_add_op;   
    
    assign is_add   = (alu_ctrl == 4'b0000);
    assign is_sub   = (alu_ctrl == 4'b0001);
    assign is_and   = (alu_ctrl == 4'b0010);
    assign is_xor   = (alu_ctrl == 4'b0011);
    assign is_not   = (alu_ctrl == 4'b0100);
    assign is_addu  = (alu_ctrl == 4'b0101);
    assign is_subu  = (alu_ctrl == 4'b0110);
    
    assign is_sll   = (alu_ctrl == 4'b1000);
    assign is_srl   = (alu_ctrl == 4'b1001);
    assign is_sra   = (alu_ctrl == 4'b1010);
    assign is_rol   = (alu_ctrl == 4'b1011);
    assign is_ror   = (alu_ctrl == 4'b1100);
    
    assign is_shift  = is_sll | is_srl | is_sra | is_rol | is_ror;
    assign is_arith  = is_add | is_sub;
    assign is_add_op = is_add | is_sub | is_addu | is_subu;

    // CARRY LOOKAHEAD ADDER (8-bit, 2-level for speed)

    logic [WIDTH-1:0] b_xor;
    logic             cin;
    
    assign b_xor = (is_sub | is_subu) ? ~b : b;
    assign cin   = (is_sub | is_subu) ? 1'b1 : 1'b0;
    
    logic [WIDTH-1:0] g, p;
    assign g = a & b_xor;          
    assign p = a ^ b_xor;          
    
    logic gg0, gg4;                
    logic gp0, gp4;                
    
    assign gp0 = p[3] & p[2] & p[1] & p[0];
    assign gg0 = g[3] | 
                 (p[3] & g[2]) | 
                 (p[3] & p[2] & g[1]) | 
                 (p[3] & p[2] & p[1] & g[0]);
    
    assign gp4 = p[7] & p[6] & p[5] & p[4];
    assign gg4 = g[7] | 
                 (p[7] & g[6]) | 
                 (p[7] & p[6] & g[5]) | 
                 (p[7] & p[6] & p[5] & g[4]);
    
    // second level
    logic c0, c4, c8;
    assign c0 = cin;
    assign c4 = gg0 | (gp0 & c0);
    assign c8 = gg4 | (gp4 & c4);   // Final carry out
    
    logic [WIDTH:0] c;
    assign c[0] = c0;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & c[2]);
    assign c[4] = c4;
    assign c[5] = g[4] | (p[4] & c[4]);
    assign c[6] = g[5] | (p[5] & c[5]);
    assign c[7] = g[6] | (p[6] & c[6]);
    assign c[8] = c8;
   
    logic [WIDTH-1:0] adder_result;
    assign adder_result = p ^ c[WIDTH-1:0];
    
    // BARREL SHIFTER 
    
    logic [2:0] shift_amt;
    assign shift_amt = b[2:0];      // Use lower 3 bits of b
    
    logic [WIDTH-1:0] sll_out, srl_out, sra_out, rol_out, ror_out;
    
    // Shift Logical Left 
    assign sll_out = a << shift_amt;
    
    // Shift Right Logical 
    assign srl_out = a >> shift_amt;
    
    // Shift Right Arithmetic 
    assign sra_out = $signed(a) >>> shift_amt;
    
    // Rotate Left
    always_comb begin
        case (shift_amt)
            3'd0: rol_out = a;
            3'd1: rol_out = {a[6:0], a[7]};
            3'd2: rol_out = {a[5:0], a[7:6]};
            3'd3: rol_out = {a[4:0], a[7:5]};
            3'd4: rol_out = {a[3:0], a[7:4]};
            3'd5: rol_out = {a[2:0], a[7:3]};
            3'd6: rol_out = {a[1:0], a[7:2]};
            3'd7: rol_out = {a[0],   a[7:1]};
        endcase
    end
    
    // Rotate Right
    always_comb begin
        case (shift_amt)
            3'd0: ror_out = a;
            3'd1: ror_out = {a[0],   a[7:1]};
            3'd2: ror_out = {a[1:0], a[7:2]};
            3'd3: ror_out = {a[2:0], a[7:3]};
            3'd4: ror_out = {a[3:0], a[7:4]};
            3'd5: ror_out = {a[4:0], a[7:5]};
            3'd6: ror_out = {a[5:0], a[7:6]};
            3'd7: ror_out = {a[6:0], a[7]};
        endcase
    end
    
    // Shift result MUX 
    logic [WIDTH-1:0] shift_result;
    assign shift_result = is_sll ? sll_out :
                          is_srl ? srl_out :
                          is_sra ? sra_out :
                          is_rol ? rol_out :
                          is_ror ? ror_out : {WIDTH{1'b0}};
    
    // LOGIC OPERATIONS 
    
    logic [WIDTH-1:0] and_result, xor_result, not_result;
    assign and_result = a & b;
    assign xor_result = a ^ b;
    assign not_result = ~a;
    
    // FINAL RESULT MUX

    always_comb begin
        case (alu_ctrl)
            4'b0000: result = adder_result;   // ADD
            4'b0001: result = adder_result;   // SUB
            4'b0010: result = and_result;     // AND
            4'b0011: result = xor_result;     // XOR
            4'b0100: result = not_result;     // NOT
            4'b0101: result = adder_result;   // ADDU
            4'b0110: result = adder_result;   // SUBU
            4'b1000: result = shift_result;   // SLL
            4'b1001: result = shift_result;   // SRL
            4'b1010: result = shift_result;   // SRA
            4'b1011: result = shift_result;   // ROL
            4'b1100: result = shift_result;   // ROR
            default: result = {WIDTH{1'b0}};
        endcase
    end
    
    // FLAGS GENERATION 
    
    assign zero = ~|result;
    
    assign negative = result[WIDTH-1];
    
    //carry : does it round about
    always_comb begin
        case (alu_ctrl)
            4'b0000: carry = c8;              // ADD
            4'b0001: carry = ~c8;             // SUB (borrow)
            4'b0101: carry = c8;              // ADDU
            4'b0110: carry = ~c8;             // SUBU (borrow)
            default: carry = 1'b0;
        endcase
    end
    
    assign overflow = is_arith ? (c[WIDTH-1] ^ c8) : 1'b0;
    assign sign = overflow^negative;
    assign parity = ~^result; //oddeven

endmodule
