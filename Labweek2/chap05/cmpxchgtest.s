# cmpxchgtest.s - An example of the cmpxchg instruction
# as --gstabs -o cmpxchgtest.o cmpxchgtest.s
# ld -o cmpxchgtest cmpxchgtest.o
.section .data
data:
   .int 10
.section .text
.globl _start
_start:
   nop
   movl $10, %eax
   movl $5, %ebx
   cmpxchg %ebx, data
   movl $1, %eax
   int $0x80
