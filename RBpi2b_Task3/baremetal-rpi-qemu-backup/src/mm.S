.globl memzero
memzero:
    mov r2, #0          @ Use r2 as zero register (ARM32 has no dedicated zero register)
loop:
    str r2, [r0], #4    @ Store zero and increment by 4 bytes (32-bit)
    subs r1, r1, #4     @ Decrement counter by 4
    bgt loop            @ Branch if greater than zero
    bx lr               @ Return using branch exchange