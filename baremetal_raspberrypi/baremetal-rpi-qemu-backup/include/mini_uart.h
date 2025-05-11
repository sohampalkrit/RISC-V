#ifndef _UART_H
#define _UART_H

void uart_init(void);
void uart_send(char c);
// char uart_recv(void);
void uart_send_string(const char* str);

#endif  /* _UART_H */