#cpuid2.s View the CPUID Vendor ID string using C library calls
# sudo apt-get update
# sudo apt install lib32z1 lib32ncurses5 g++-multilib libc6-dev-i386
# as --32 -o cpuid2.o cpuid2.s
# ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o cpuid2 -lc cpuid2.o
.code32
.section .data
output:
    .asciz "The processor Vendor ID is '%s'\n"
.section .bss
    .lcomm buffer, 12
.section .text
.globl _start
_start:
    movl $0, %eax
    cpuid
    movl $buffer, %edi
    movl %ebx, (%edi)
    movl %edx, 4(%edi)
    movl %ecx, 8(%edi)
    pushl $buffer
    pushl $output
    call printf
    addl $8, %esp
    pushl $0
    call exit
