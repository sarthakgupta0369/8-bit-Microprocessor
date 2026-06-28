opcode_map = {
    "ADD"   : "0000",
    "SUB"   : "0000",
    "AND"   : "0000",
    "XOR"   : "0000",
    "NOT"   : "0000",
    "ADDU"  : "0000",
    "SUBU"  : "0000",
    "SLL"   : "0001",
    "SRL"   : "0001",
    "SRA"   : "0001",
    "ROL"   : "0001",
    "ROR"   : "0001",
    "ADDI"  : "0010",
    "LI"    : "0011",
    "LOAD"  : "0100",
    "STORE" : "0101",
    "BEQ"   : "0110",
    "BNE"   : "0111",
    "BLT"   : "1000",
    "BGE"   : "1001",
    "JMP"   : "1010",
    "NOP"   : "1111"
}

funct_codes = {
    "ADD"   : "000",
    "SUB"   : "001",
    "AND"   : "010",
    "XOR"   : "011",
    "NOT"   : "100",
    "ADDU"  : "101",
    "SUBU"  : "110",
    "SLL"   : "000",
    "SRL"   : "001",
    "SRA"   : "010",
    "ROL"   : "011",
    "ROR"   : "100"
}

types = {
    "ADD"   : "rtype",
    "SUB"   : "rtype",
    "AND"   : "rtype",
    "XOR"   : "rtype",
    "NOT"   : "rtype",
    "ADDU"  : "rtype",
    "SUBU"  : "rtype",
    "SLL"   : "rtype",
    "SRL"   : "rtype",
    "SRA"   : "rtype",
    "ROL"   : "rtype",
    "ROR"   : "rtype",
    "ADDI"  : "itype",
    "LI"    : "litype",
    "LOAD"  : "mtype",
    "STORE" : "mtype", ###
    "BEQ"   : "btype",
    "BNE"   : "btype",
    "BLT"   : "btype",
    "BGE"   : "btype",
    "JMP"   : "jtype",
    "NOP"   : "jtype"
}

registers = {
    f"R{i}": f"{i:03b}" for i in range(8)
}

instructions = []

def b(val, bits): ####
    val = int(val, 0)
    if val < 0:
        val = (1 << bits) + val
    return f"{val:0{bits}b}"[-bits:]

def assemble(lines):
    for line in lines:
        line = line.split("#")[0].strip()
        if not line:
            continue
        field = line.replace(",", " ").split()
        print(field) #debug
        instr = field[0].upper()
        
        if instr in opcode_map:
            op = opcode_map[instr]
            if types[instr] == "rtype":
                rd = registers[field[1].upper()]
                rs1 = registers[field[2].upper()]
                rs2 = "000" if instr == "NOT" else registers[field[3].upper()]
                funct = funct_codes[instr]
                
                machine_instr = op + rs1 + rs2 + rd + funct
            elif types[instr] == "itype":
                rd = registers[field[1].upper()]
                rs1 = registers[field[2].upper()]
                imm = b(field[3], 6)
                
                machine_instr = op + rs1 + imm[0:3] + rd + imm[3:6]
            elif types[instr] == "litype":
                rd = registers[field[1].upper()]
                imm = b(field[2], 8) + "0"
                
                machine_instr = op + imm[0:6] + rd + imm[6:9]
            elif types[instr] == "mtype":
                if instr == "LOAD":
                    rd = registers[field[1].upper()]
                    rb = registers[field[2].upper()]
                    off = b(field[3], 6)
                    
                    machine_instr = op + rb + off[0:3] + rd + off[3:6]
                elif instr == "STORE":
                    rs2 = registers[field[1].upper()]
                    rb = registers[field[2].upper()]
                    off = b(field[3], 6)
                    
                    machine_instr = op + rb + rs2 + off[0:3] + off[3:6]
            elif types[instr] == "btype":
                rs1 = registers[field[1].upper()]
                rs2 = registers[field[2].upper()]
                off = b(field[3], 6)
                
                machine_instr = op + rs1 + rs2 + off[0:3] + off[3:6]
            elif types[instr] == "jtype": #to-be-changed
                if instr == "JMP":
                    off = b(field[1], 12)
                
                machine_instr =  op + (off if instr == "JMP" else "000000000000")
            
            instructions.append(machine_instr)
        else:
            print(f"ERROR: UNKNOWN INSTRUCTION: {instr}")

if __name__ == "__main__":
    with open("assemblycode.asm", "r") as f:
        lines = f.readlines()
    assemble(lines)
    print(instructions) #debug
    with open("machinecode.mem", "w") as f:
        f.write("\n".join(instructions))