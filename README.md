

## 📘 Project 1: RISC-V Core Implementation (RV32I)

### 🔧 Overview:
This project involved building a 32-bit RISC-V RV32I core from scratch using Verilog HDL. The objective was to gain a deep understanding of pipelined processor architecture and instruction execution.

### 🚀 Features:
- 5-stage pipeline: IF, ID, EX, MEM, WB
- Hazard detection and forwarding unit
- Control unit supporting RV32I base instruction set
- Immediate generator and ALU
- Register file and memory interface
- Testbench with sample assembly programs

### 🛠️ Tools & Tech:
- Verilog HDL
- GTKWave
- ModelSim/iverilog
- RISC-V GNU Toolchain (for generating `.hex` files)

### 📝 Key Learnings:
- Pipeline hazards and data forwarding
- Instruction decoding and control logic
- Simulation-based debugging

---

## 📘 Project 2: LFSR Random Number Generator with AXI4-Lite Protocol

### 🔧 Overview:
This project aimed at creating a pseudo-random number generator using a Linear Feedback Shift Register (LFSR), integrated into a system via AXI4-Lite protocol for read/write access through an ARM processor (typically in a Zynq SoC environment).

### 🚀 Features:
- 16-bit Galois LFSR
- AXI4-Lite compliant slave interface
- Register map to control LFSR seed, start/stop, and read value
- Test application in C running on ARM (bare-metal or Linux)

### 🛠️ Tools & Tech:
- Verilog HDL (LFSR + AXI wrapper)
- Vivado (for IP packaging and integration)
- Xilinx Zynq SoC
- Vitis SDK or Petalinux (for testing)

### 📝 Key Learnings:
- AXI protocol and handshaking mechanism
- Custom IP packaging in Vivado
- Register interfacing between PL and PS in Zynq

---

## 📘 Project 3: Bare-Metal Kernel on Raspberry Pi 2B

### 🔧 Overview:
A minimal operating system kernel was developed from scratch for Raspberry Pi 2B, focusing on UART communication and exception level transitions. The kernel runs without any OS support and is booted using the Pi’s bootloader.

### 🚀 Features:
- PL011 UART driver for serial communication
- Custom lightweight `printf()` implementation
- Exception level management: EL2 -> EL1 -> EL0
- System call (SVC) mechanism for UART access from EL0
- Memory-mapped I/O handling

### 🛠️ Tools & Tech:
- ARMv7 Assembly and C
- QEMU (for emulation)
- Cross-compiler (arm-none-eabi)
- linker.ld and boot.S (bare-metal boot flow)

### 📝 Key Learnings:
- ARM exception levels and stack separation
- Writing drivers directly to hardware registers
- Bare-metal debugging and simulation with QEMU
- Designing secure syscall interfaces between user/kernel modes

---

## 🔚 Conclusion
These three projects, conducted under the IRIS Embedded Task series, collectively illustrate a comprehensive journey through embedded systems — from digital design and processor architecture to system-level integration and bare-metal kernel programming. The knowledge gained spans hardware design, low-level software, and hardware-software interfacing, forming a solid foundation for advanced research or industry roles in embedded and systems engineering.

---

## 📎 References
- RISC-V ISA Manual
- Xilinx AXI Protocol Specification
- Raspberry Pi Bare-Metal Resources (GitHub, OSDev Wiki)
- ARMv7-A/R Architecture Reference Manual





