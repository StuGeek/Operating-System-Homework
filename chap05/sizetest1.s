# sizetest1.s � A sample program to view the executable size
# as -o sizetest1.o sizetest1.s
# ld -o sizetest1 sizetest1.o
# ls -al sizetest1
.section .text
.globl _start
_start:
   movl $1, %eax
   movl $0, %ebx
   int $0x80
