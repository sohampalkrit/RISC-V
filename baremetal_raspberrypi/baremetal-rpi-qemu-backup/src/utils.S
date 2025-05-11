.globl put32
put32:
    str r1, [r0]    @ Store r1 to address in r0
    bx lr           @ Return

.globl get32
get32:
    ldr r0, [r0]    @ Load from address in r0 to r0
    bx lr           @ Return

.globl delay
delay:
    subs r0, r0, #1 @ Subtract 1 from r0
    bne delay       @ Branch if not equal to zero
    bx lr           @ Return