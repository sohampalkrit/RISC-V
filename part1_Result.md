# Single Cycle RISC-V CPU Project

## Introduction
This project implements a single-cycle RISC-V CPU, handling instruction fetch, decode, execute, memory access, and write-back within one clock cycle. The design includes key components such as the ALU, ALU Control, Control Unit, Program Counter, and Register File.

## Components Overview

### 1. **Arithmetic Logic Unit (ALU)**
The ALU performs arithmetic and logic operations based on control signals. It takes two inputs and produces a result along with status flags.
- Supports multiple arithmetic and logical operations
- Generates zero and comparison flags
- Handles various instruction types

### 2. **ALU Control**
The ALU Control unit generates signals to determine the operation performed by the ALU, based on the instruction type and function codes.
- Decodes ALU operation from instruction bits
- Maps control signals to specific ALU operations
- Interprets `funct3` and `funct7` instruction fields

### 3. **Control Unit**
The Control Unit generates control signals to guide the flow of data and operation execution, decoding opcodes to enable correct instruction execution.
- Generates control signals for:
  - Register write
  - Memory read/write
  - Branch conditions
  - ALU operation selection
- Handles different instruction formats

### 4. **Program Counter (PC)**
The Program Counter holds the address of the current instruction and updates to the next instruction address after execution.
- Manages sequential instruction fetch
- Supports branch and jump instructions
- Increments by 4 bytes for standard instruction progression

### 5. **Single-Cycle CPU Design**
The entire execution of an instruction is completed within a single clock cycle. The pipeline includes:
- **Instruction Fetch**: Retrieve instruction from memory
- **Instruction Decode**: Interpret instruction opcode and generate control signals
- **Execution**: Perform ALU operations
- **Memory Access**: Read or write data memory
- **Write Back**: Update register file with results

## Key Features
- Full RISC-V instruction set support
- Single-cycle instruction execution
- Modular design with separate components
- Supports various instruction types (R-type, I-type, S-type, B-type)

## Output Waveforms


![Waveform 1](waveforms/waveform1.jpg)
![Waveform 2](waveforms/waveform2.jpg)
## Conclusion
This project demonstrates the implementation of a basic single-cycle RISC-V CPU, covering instruction execution and data flow. Further improvements can be made by optimizing performance or transitioning to a pipelined architecture.

## Future Improvements
- Implement pipelined architecture
- Add more complex branch prediction
- Optimize critical path timing
- Extend instruction set support

## References
- RISC-V Instruction Set Architecture
- Computer Architecture Principles
- Digital Design Fundamentals
```

