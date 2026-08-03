# 8-bit-Microprocessor
---
## Instruction Set Architecture

| Opcode | Mnemonic | Type |
|--------|----------|------|
| 0000   | ADD      | R    |
| 0000   | SUB      | R    |
| 0000   | AND      | R    |
| 0000   | XOR      | R    |
| 0000   | NOT      | R    |
| 0000   | ADDU     | R    |
| 0000   | SUBU     | R    |
| 0001   | SLL      | R    |
| 0001   | SRL      | R    |
| 0001   | SRA      | R    |
| 0001   | ROL      | R    |
| 0001   | ROR      | R    |
| 0010   | ADDI     | I    |
| 0011   | LI       | LI   |
| 0100   | LOAD     | M    |
| 0101   | STORE    | M    |
| 0110   | BEQ      | B    |
| 0111   | BNE      | B    |
| 1000   | BLT      | B    |
| 1001   | BGE      | B    |
| 1010   | JMP      | J    |
| 1010   | JAL      | J    |
| 1010   | JR       | J    |
| 1010   | JALR     | J    |
| 1011   | PUSHLR   | S    |
| 1011   | PUSHR    | S    |
| 1100   | POPLR    | S    |
| 1100   | POPR     | S    |
| 1101   | TRAP     | E    |
| 1111   | NOP      | —    |

---

# Pipelined
Components include:

- ALU
- Comparator
- Control-Unit
- Program Counter
- Instruction Memory
- Data Memory
- Register File
- Pipeline Registers
- Hazard Unit
- Branch Predictor

