#include "mini_uart.h"
#include "peripherals/mini_uart.h"
#include "peripherals/gpio.h"

// void uart_send(char c)
// {
//     // Wait until transmit FIFO is not full
//     while(get32(UART0_FR) & (1 << 5));
//     put32(UART0_DR, c);
// }

// char uart_recv(void)
// {
//     // Wait until receive FIFO is not empty
//     while(get32(UART0_FR) & (1 << 4));
//     return (get32(UART0_DR) & 0xFF);
// }

// void uart_send_string(char* str)
// {
//     for (int i = 0; str[i] != '\0'; i++) {
//         uart_send((char)str[i]);
//     }
// }
// UART register addresses
#define UART0_DR    ((volatile unsigned int*)0x3F201000)  // Data Register
#define UART0_FR    ((volatile unsigned int*)0x3F201018)  // Flag Register
#define UART0_CR    ((volatile unsigned int*)0x3F201030)  // Control Register

// Initialize UART - minimal initialization for QEMU
// void uart_init(void) {
//     *UART0_CR = 0x301;  // Enable UART, TX, RX
// }

// Send a single character
// Main kernel entry point
// Simplest possible kernel
// Simple kernel with reliable UART output

void uart_send(char c) {
    // volatile unsigned int* UART0_DR = (volatile unsigned int*)0x3F201000;
    *UART0_DR = c;
    for(volatile int i = 0; i < 100000; i++); // Delay after each character
}

void uart_send_string(const char* str) {
    for(int i = 0; str[i] != '\0'; i++) {
        uart_send(str[i]);
        // Additional delay between characters in a string
        for(volatile int j = 0; j < 50000; j++);
        // printf(str[i]);
    }
}


void uart_init(void)
{
    unsigned int selector;
    
    // Disable UART0
    put32(UART0_CR, 0);
    
    // Setup GPIO pins 14 and 15
    selector = get32(GPFSEL1);
    selector &= ~(7 << 12);  // Clean GPIO14
    selector |= 4 << 12;     // Set alt0 for GPIO14 (UART0_TXD)
    selector &= ~(7 << 15);  // Clean GPIO15
    selector |= 4 << 15;     // Set alt0 for GPIO15 (UART0_RXD)
    put32(GPFSEL1, selector);
    
    // Disable pull up/down for pins
    put32(GPPUD, 0);
    delay(150);
    put32(GPPUDCLK0, (1 << 14) | (1 << 15));
    delay(150);
    put32(GPPUDCLK0, 0);
    
    // Clear pending interrupts
    put32(UART0_ICR, 0x7FF);
    
    // Set integer & fractional part of baud rate
    // Divider = UART_CLOCK/(16 * Baud)
    // UART_CLOCK = 3MHz for QEMU
    // Baud = 115200
    // Divider = 3000000/(16 * 115200) = 1.627 = ~1.6
    // Integer part = 1
    // Fractional part = (.627 * 64) + 0.5 = 40.6 = ~40
    put32(UART0_IBRD, 26);
    put32(UART0_FBRD, 3);
    
    // Enable FIFO & 8-bit data transmission (1 stop bit, no parity)
    put32(UART0_LCRH, (1 << 4) | (1 << 5) | (1 << 6));
    
    // Mask all interrupts
    put32(UART0_IMSC, (1 << 1) | (1 << 4) | (1 << 5) | 
                       (1 << 6) | (1 << 7) | (1 << 8) | 
                       (1 << 9) | (1 << 10));
    
    // Enable UART0, receive & transfer
    put32(UART0_CR, (1 << 0) | (1 << 8) | (1 << 9));
}