# 8-bit-Microprocessor

The key changes in the multi-cycles include: A new Step Counter Module, 4 new registers,
readReg signals now go directly from IM to Regfile and an overhaul of the PC next signal
calculation logic.

every instruction is split into loosely 5 stages: IF, ID, EX, MEM, WB.
