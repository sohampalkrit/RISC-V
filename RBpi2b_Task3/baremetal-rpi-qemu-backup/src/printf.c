#include "mini_uart.h"
#include "printf.h"

void printf(char str[]) {
    // char buffer[64];
  

    // // Sanity default content
    // buffer[0] = 'H';
    // buffer[1] = 'e';
    // buffer[2] = 'l';
    // buffer[3] = 'l';
    // buffer[4] = 'o';
    // buffer[5] = 'W';
    // buffer[6] = 'o';
    // buffer[7] = 'r';
    // buffer[8] = 'l';
    // buffer[9] = 'd';
    // buffer[10] = '\0';
    // uart_send(str);
    //printf(buffer);
    // Send it directly (this will confirm if UART and buffer work)
    uart_send_string(str);
}
