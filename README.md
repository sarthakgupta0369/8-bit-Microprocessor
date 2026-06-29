# 8-bit-Microprocessor

- For now, Single-Cycle is being treated as the main branch
- For Multi-Cycle, click [here](https://github.com/sarthakgupta0369/8-bit-Microprocessor/tree/multi_cycle).
- For Assembler, click [here](https://github.com/sarthakgupta0369/8-bit-Microprocessor/tree/assembler).

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
| 1111   | NOP      | —    |

---

# Single-Cycle
![Single_Cycle_Datapath](Single_Cylce_Datapath.png)

In a single-cycle processor, each instruction completes in exactly one clock cycle. This keeps the datapath simple and easy to follow.

Components include:
- ALU
- Comparator
- Control-Unit
- Program Counter
- Instruction Memory
- Data Memory
- Register File

