# sizetest2.s - A sample program to view the executable size
# as -o sizetest2.o sizetest2.s
# ld -o sizetest2 sizetest2.o
# ls -al sizetest2
.section .bss
   .lcomm buffer, 10000
.section .text
.globl _start
_start:
   movl $1, %eax
   movl $0, %ebx
   int $0x80
