# RISC-V Control Signals and Execution Steps

## Control Signal Table (Before CTZ)

This table represents the control signals for RISC-V instructions **before** adding the `CTZ` instruction.

| Instruction   | Opcode   | RegWrite | MemRead | MemtoReg | ALUOp | MemWrite | ALUSrc | Branch |
|--------------|---------|----------|---------|----------|-------|----------|--------|--------|
| LW          | 0000011 | 1        | 1       | 1        | 00    | 0        | 1      | 0      |
| SW          | 0100011 | 0        | 0       | x        | 00    | 1        | 1      | 0      |
| R-type      | 0110011 | 1        | 0       | 0        | 10    | 0        | 0      | 0      |
| BEQ/BGT     | 1100011 | 0        | 0       | x        | 01    | 0        | 0      | 1      |
| JAL         | 1101111 | 1        | 0       | 0        | xx    | 0        | x      | 0      |
| ADDI/ORI/SLLI | 0010011 | 1      | 0       | 0        | 11    | 0        | 1      | 0      |

### Explanation:
- These instructions include **load (LW), store (SW), R-type operations, branches, jumps, and immediate-based operations**.
- **RegWrite** enables writing to registers.
- **MemRead** and **MemWrite** manage memory access.
- **ALUOp** determines which operation is performed.
- **Branch** indicates control flow instructions.

---

## Control Signal Table (After Adding CTZ)

This table includes the **CTZ (Count Trailing Zeros)** instruction, which is an additional R-type instruction.

| Instruction   | Opcode   | RegWrite | MemRead | MemtoReg | ALUOp | MemWrite | ALUSrc | Branch |
|--------------|---------|----------|---------|----------|-------|----------|--------|--------|
| LW          | 0000011 | 1        | 1       | 1        | 00    | 0        | 1      | 0      |
| SW          | 0100011 | 0        | 0       | x        | 00    | 1        | 1      | 0      |
| R-type      | 0110011 | 1        | 0       | 0        | 10    | 0        | 0      | 0      |
| BEQ/BGT     | 1100011 | 0        | 0       | x        | 01    | 0        | 0      | 1      |
| JAL         | 1101111 | 1        | 0       | 0        | xx    | 0        | x      | 0      |
| ADDI/ORI/SLLI | 0010011 | 1      | 0       | 0        | 11    | 0        | 1      | 0      |
| **CTZ**     | 1110011 | 1        | 0       | 0        | 11    | 0        | 1      | 0      |

### Explanation:
- **CTZ (Count Trailing Zeros)** is an added instruction that operates like other R-type instructions.
- It updates **RegWrite** but does not access memory.
- The **ALUOp (11)** ensures that the ALU performs the trailing zero count.

---

## Execution Breakdown of Loop Code

### Initial Values:
- **x0**: Always 0 (hardwired zero register)
- **x1**: 8 (initial value)
- **x2**: 2 (initial value)

### Code Execution:

#### 1st Iteration:
1. `slt x2, x0, x1`  
   - Since `0 < 8`, `x2 = 1`.
2. `beq x2, x0, DONE`  
   - `x2 ≠ x0`, so **branch not taken**.
3. `addi x1, x1, -1`  
   - `x1 = 8 - 1 = 7`.
4. `addi x2, x2, 2`  
   - `x2 = 1 + 2 = 3`.
5. `j loop`  
   - **Jump back to loop**.

#### 2nd Iteration:
1. `slt x2, x0, x1` → `x2 = 1`  
2. `beq x2, x0, DONE` → **branch not taken**  
3. `addi x1, x1, -1` → `x1 = 6`  
4. `addi x2, x2, 2` → `x2 = 3`  
5. `j loop` → **Jump back**  

This continues until `x1 = 0`, at which point the `beq` instruction branches to `DONE`.

### Final Values:
- `x2 = 0` (as the last iteration doesn't execute `addi x2, x2, 2`).
