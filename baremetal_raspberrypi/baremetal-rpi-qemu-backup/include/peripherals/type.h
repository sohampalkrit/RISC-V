#ifndef TYPES_H
#define TYPES_H

// Standard integer types
typedef unsigned char       uint8_t;
typedef unsigned short      uint16_t;
typedef unsigned int        uint32_t;
typedef unsigned long long  uint64_t;

typedef signed char         int8_t;
typedef signed short        int16_t;
typedef signed int          int32_t;
typedef signed long long    int64_t;

// Size types
typedef unsigned long       size_t;
typedef signed long         ssize_t;
typedef long                ptrdiff_t;

// Max-width integer types
typedef signed long long    intmax_t;
typedef unsigned long long  uintmax_t;

// Pointer integer types
typedef unsigned long       uintptr_t;
typedef signed long         intptr_t;

// NULL definition
#ifndef NULL
#define NULL ((void*)0)
#endif


#endif // TYPES_H