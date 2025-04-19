.section ".text.boot"
.global _start

_start:
    // Set up stack pointer
    mov sp, #0x8000

    // Jump directly to kernel_main
    bl kernel_main

    // Infinite loop if kernel_main returns
hang:
    b hang