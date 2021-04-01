# movtest2.s � An example of moving register data to memory
# as -gstabs -o movtest2.o -gstabs movtest2.s
# ld -o movtest2 movtest2.o
# gdb -q movtest2
.section .data
   value:
      .int 1
.section .text
.globl _start
   _start:
      nop
      movl $100, %eax
      movl %eax, value
      movl $1, %eax
      movl $0, %ebx
      int $0x80
