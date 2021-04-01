# swaptest.s � An example of using the BSWAP instruction
# as --gstabs -o swaptest.o swaptest.s
# ld -o swaptest swaptest.o
.section .text
.globl _start
_start:
   nop
   movl $0x12345678, %ebx
   bswap %ebx
   movl $1, %eax
   int $0x80
