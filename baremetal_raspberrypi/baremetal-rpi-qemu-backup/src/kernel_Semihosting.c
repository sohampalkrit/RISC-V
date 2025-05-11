#include "mini_uart.h"
#include "printf.h"
// working_uart.c
// improved_uart.c

//The following code is working only for 4 character string
// Simple kernel with UART output for Raspberry Pi 2B on QEMU



void kernel_main(void) {
   
    char msg1[5] ="Hell";
    char msg2[5]="o wo";
    char msg3[5]="rld!";
    printf(msg1);
    printf(msg2);
    printf(msg3);
    

}
