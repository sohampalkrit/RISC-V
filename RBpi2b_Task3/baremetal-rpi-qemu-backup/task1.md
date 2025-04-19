# Task 1: Bare-Metal UART Implementation on Raspberry Pi using QEMU

This documentation explains the implementation of a **bare-metal UART driver** on the Raspberry Pi 2B, tested using the **QEMU emulator**. The system is written in C and ARM64 assembly, targeting EL1 (privileged mode).

---

## 🧠 Objective
- Initialize UART (PL011) on Raspberry Pi in bare-metal (no OS).
- Send and receive characters via UART.
- Use `printf()` for formatted output.
- Run and debug using QEMU.

---

## 📁 Project Structure
```
BAREMETAL-RPI-QEMU-BACKUP/
├── src/
│   ├── boot.S              # Startup assembly code
│   ├── kernel.c            # Main kernel logic
│   ├── pl011_uart.c        # UART initialization and functions
│   ├── printf.c            # Lightweight printf implementation
│   ├── utils.c/.h          # Delay function, utility macros
│   ├── linker.ld           # Linker script
├── include/                # Header files
├── output/kernel7.img      # Final compiled image
├── makefile                # Build automation
```

---

## 📜 Detailed Explanation

### 1. **UART Initialization (pl011_uart.c)**
```c
void uart_init() {
    *UART0_CR = 0; // Disable UART0
    
    // GPIO14 and GPIO15 to ALT0
    unsigned int selector = *GPFSEL1;
    selector &= ~(7 << 12);
    selector |= 4 << 12;
    selector &= ~(7 << 15);
    selector |= 4 << 15;
    *GPFSEL1 = selector;

    *GPPUD = 0; // Disable pull-up/down
    delay(150);
    *GPPUDCLK0 = (1 << 14) | (1 << 15);
    delay(150);
    *GPPUDCLK0 = 0;

    *UART0_ICR = 0x7FF; // Clear interrupts
    *UART0_IBRD = 26;   // Integer part of baud rate
    *UART0_FBRD = 3;    // Fractional part
    *UART0_LCRH = (1 << 4) | (1 << 5) | (1 << 6); // Enable FIFO, 8N1
    *UART0_IMSC = ... // Mask all interrupts (optional)
    *UART0_CR = (1 << 0) | (1 << 8) | (1 << 9); // Enable UART, TX, RX
}
```

#### ✅ Why?
- UART0 on Pi uses GPIO14/15.
- Proper sequence ensures stable communication.
- Disabling pull-up/down prevents electrical interference.

---

### 2. **UART Send/Receive (pl011_uart.c)**
```c
void uart_putc(unsigned char c) {
    while (*UART0_FR & (1 << 5)); // Wait until TX ready
    *UART0_DR = c;
}

unsigned char uart_getc() {
    while (*UART0_FR & (1 << 4)); // Wait until RX ready
    return *UART0_DR & 0xFF;
}

void uart_puts(const char* str) {
    while (*str) {
        if (*str == '\n') uart_putc('\r');
        uart_putc(*str++);
    }
}
```

#### ✅ Why?
- `uart_putc` waits for the FIFO to be empty before sending.
- `uart_getc` blocks until a character is received.
- `uart_puts` handles newline correctly for terminal display.

---

### 3. **Formatted Output with printf (printf.c)**
```c
void printf(const char* fmt, ...) {
    va_list args;
    va_start(args, fmt);
    tfp_format(uart_putc, fmt, args);
    va_end(args);
}
```
- Uses a minimal implementation (`tiny printf`) that writes characters to UART.
- Handy for debugging via serial terminal.

---

### 4. **Entry Point and Delay (boot.S, utils.c)**
#### boot.S:
- Sets up stack pointer
- Jumps to `kernel_main`

#### utils.c:
```c
void delay(u64 ticks) {
    while (ticks--) asm volatile("nop");
}
```

---

## ✅ Checklist of Working Features

| Feature                        | Status |
|-------------------------------|--------|
| UART0 Initialization          | ✅     |
| Send character via UART       | ✅     |
| Receive character via UART    | ✅     |
| String output (`uart_puts`)   | ✅     |
| Formatted output (`printf`)   | ✅     |
| Running on QEMU               | ✅     |
| Assembly entry + linker setup | ✅     |

---

## 🧪 Testing with QEMU
```bash
qemu-system-aarch64 \
    -M raspi2 \
    -kernel output/kernel7.img \
    -nographic
```
Expected Output:
```
Hello World!
```

---

## 🔚 Summary
This task involved setting up the low-level UART interface of Raspberry Pi in a **bare-metal environment**, using a minimal C runtime and ARM assembly. The result is a foundational I/O system that enables further kernel development and debugging capabilities via serial output.

> Next step: move to EL0 and implement system calls!

