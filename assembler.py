import re

opcode_map = {
    "ADD"    : "0000",
    "SUB"    : "0000",
    "AND"    : "0000",
    "XOR"    : "0000",
    "NOT"    : "0000",
    "ADDU"   : "0000",
    "SUBU"   : "0000",
    "MUL"    : "0000",
    "SLL"    : "0001",
    "SRL"    : "0001",
    "SRA"    : "0001",
    "ROL"    : "0001",
    "ROR"    : "0001",
    "ADDI"   : "0010",
    "LI"     : "0011",
    "LOAD"   : "0100",
    "STORE"  : "0101",
    "BEQ"    : "0110",
    "BNE"    : "0111",
    "BLT"    : "1000",
    "BGE"    : "1001",
    "JMP"    : "1010",
    "JAL"    : "1010",
    "JR"     : "1010",
    "JALR"   : "1010",
    "PUSHLR"   : "1011",
    "PUSHR"    : "1011",
    "POPLR"    : "1100",
    "POPR"     : "1100",
    "NOP"    : "1111",
    "TRAP"   : "1101"
}

funct_codes = {
    "ADD"    : "000",
    "SUB"    : "001",
    "AND"    : "010",
    "XOR"    : "011",
    "NOT"    : "100",
    "ADDU"   : "101",
    "SUBU"   : "110",
    "MUL"    : "111",
    "SLL"    : "000",
    "SRL"    : "001",
    "SRA"    : "010",
    "ROL"    : "011",
    "ROR"    : "100",
    "JMP"    : "00",
    "JAL"    : "01",
    "JR"     : "10",
    "JALR"   : "11",
    "PUSHLR" : "0",
    "PUSHR"  : "1", 
    "POPLR"  : "0", 
    "POPR"   : "1"
}

types = {
    "ADD"    : "rtype",
    "SUB"    : "rtype",
    "AND"    : "rtype",
    "XOR"    : "rtype",
    "NOT"    : "rtype",
    "ADDU"   : "rtype",
    "SUBU"   : "rtype",
    "MUL"    : "rtype",
    "SLL"    : "rtype",
    "SRL"    : "rtype",
    "SRA"    : "rtype",
    "ROL"    : "rtype",
    "ROR"    : "rtype",
    "ADDI"   : "itype",
    "LI"     : "litype",
    "LOAD"   : "mtype",
    "STORE"  : "mtype", 
    "BEQ"    : "btype",
    "BNE"    : "btype",
    "BLT"    : "btype",
    "BGE"    : "btype",
    "JMP"    : "jtype",
    "JAL"    : "jtype",
    "JR"     : "jtype",
    "JALR"   : "jtype",
    "PUSHLR" : "stype",
    "PUSHR"  : "stype", 
    "POPLR"  : "stype", 
    "POPR"   : "stype",
    "NOP"    : "jtype",
    "TRAP"   : "etype"

}

label_dict = {}
label = re.compile(r"^(\w+):$")
cleaned = []

registers = {
    f"R{i}": f"{i:03b}" for i in range(8)
}

instructions = []

def b(val, bits):
    if isinstance(val, str):
        val = int(val, 0)
    else:
        val = int(val)
    if val < 0:
        val = (1 << bits) + val
    return f"{val:0{bits}b}"[-bits:]

def first_parse(lines):
    for line in lines:
        line = line.split("#")[0].strip()
        if not line:
            continue
        cleaned.append(line)
    trap_label_invalid = "TRAP:"
    for line in cleaned:
        trap_search = re.search("TRAP", line)
        trap_invalid_search = re.search(trap_label_invalid, line)
        if trap_search and not trap_invalid_search:
            cleaned.append("TRAP:")
            cleaned.append("JMP TRAP")
            break
    lines = cleaned
    # print(lines) #debug
    t = 0
    for i, line in enumerate(lines):
        m = label.match(line)
        if m:
            label_dict[m.group(1)] = i + 1 - t
            t += 1
    # print(label_dict) #debug


def assemble(lines):
    address = 0
    for i, line in enumerate(lines):
        field = line.replace(",", " ").split()
        m = label.match(line)
        if m:
            continue
        else:
            address += 1
        # print(field) #debug
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
                off = b((label_dict[field[3]] - address -1), 6)

                machine_instr = op + rs1 + rs2 + off[0:3] + off[3:6]
            elif types[instr] == "jtype":
                if instr == "NOP": #NOP is not jtype but i've left it in here
                    machine_instr = op + "0" * 12
                elif instr == "JR": #JR
                    machine_instr = op + "0"*10 + funct_codes[instr]
                else: # JMP/JAL/JALR
                    off = b((label_dict[field[1]]- address -1), 10)

                    machine_instr = op + off + funct_codes[instr]
            elif types[instr] == "stype":
                if instr == "PUSHLR":
                    if len(field) == 1:
                        off = "0" * 8
                    elif len(field) == 2:
                        off = b(field[1], 8)
                    
                    machine_instr = op + "000" + off + funct_codes[instr]
                elif instr == "PUSHR": 
                    rs = registers[field[1].upper()]
                    if len(field) == 2:
                        off = "0" * 8
                    elif len(field) == 3:
                        off = b(field[2], 8)    

                    machine_instr = op + rs + off + funct_codes[instr]
                elif instr == "POPLR":
                    if len(field) == 1:
                        off = "0" * 8
                    elif len(field) == 2:
                        off = b(field[1], 8)

                    machine_instr = op + off[0:6] + "000" + off[6:8] + funct_codes[instr]
                elif instr == "POPR":
                    rd = registers[field[1].upper()]
                    if len(field) == 2:
                        off = "0" * 8
                    elif len(field) == 3:
                        off = b(field[2], 8)

                    machine_instr = op + off[0:6] + rd + off[6:8] + funct_codes[instr]
            elif types[instr] == "etype":
                if instr == "TRAP":
                    off = b((label_dict["TRAP"]- address -1), 12)
                    machine_instr = op + off
            
            instructions.append(machine_instr)
        else:
            print(f"ERROR: UNKNOWN INSTRUCTION: {instr}")

if __name__ == "__main__":
    with open("assemblycode.asm", "r") as f:
        lines = f.readlines()
    # print(lines) #debug
    first_parse(lines)
    assemble(cleaned)
    # print(instructions) #debug
    with open("machinecode.mem", "w") as f:
        f.write("\n".join(instructions))
