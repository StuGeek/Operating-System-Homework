# 操作系统实验报告2

## 实验内容

+ 了解 Linux 下 x86 汇编语言编程环境；
+ 验证实验 Blum’s Book: Sample programs in Chapter 04, 05 (Moving Data)。

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### Chapter 04

+ 验证实验**cpuid.s**

程序的源代码略。

**1.构建一般可执行程序：**

执行程序命令：

    as -o cpuid.o cpuid.s
    ld -o cpuid cpuid.o
    ./cpuid

执行结果如下：

    The processor Vendor ID is 'GenuineIntel'

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/1.png)

**2.使用编译器进行汇编**

将原程序代码中的：

    .globl _start
    _start:

改为：
    .globl main
    main:

安装32位的gcc库：

    sudo apt-get install libc6-dev-i386

执行程序命令：

    gcc cpuid.s -m32 -o cpuid

执行结果如下：

    The processor Vendor ID is 'GenuineIntel'

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/2.png)

**3.使用gdb运行程序：**

执行程序命令：

    as -gstabs -o cpuid.o cpuid.s
    ld -o cpuid cpuid.o
    gdb cpuid

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/3.png)

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/4.png)

分析：

一开始在程序开始处设置断点,然后输入run运行，输入命令next\n\step\s可以看见单步调试程序，输入cont程序直接运行完毕，输出

    The processor Vendor ID is 'GenuineIntel'

重新输入run，输入s单步执行至cpuid语句，输入info registers，可以看见所有寄存器中的值，再输入s执行至下一语句，输入info registers，可以看见寄存器中值的变化，可以看见，在执行cpuid语句前寄存器rbx，rcx，rdx的值都为0，执行cpuid后，它们包含从厂商ID字符串得来的值。

print/x $ebx, print/x $edx, print/x $ecx分别以十六进制形式显示寄存器ebx,edx和ecx中的值，可以看到，寄存器ebx中的值为0x756e6547，寄存器edx中的值为0x49656e69，寄存器ecx中的值为0x6c65746e。

x/42cd &output以字符变量的形式显示变量output的前42个字节

+ 验证实验**cpuid2.s**

在程序的源代码开头之前加上：

    .code32

并安装程序运行所需32位库：

    sudo apt-get update
    sudo apt install lib32z1 lib32ncurses5 g++-multilib libc6-dev-i386

执行程序命令：

    as --32 -o cpuid2.o cpuid2.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o cpuid2 -lc cpuid2.o
    ./cpuid2

执行结果如下：

    The processor Vendor ID is 'GenuineIntel'

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/5.png)

---

### Chapter 05

+ 验证实验**sizetest1.s**

程序的源代码略。

执行程序命令：

    as -o sizetest1.o sizetest1.s
    ld -o sizetest1 sizetest1.o
    ls -al sizetest1

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/6.png)

分析：可执行程序文件的总长度为4640字节

+ 验证实验**sizetest2.s**

程序的源代码略。

执行程序命令：

    as -o sizetest2.o sizetest2.s
    ld -o sizetest2 sizetest2.o
    ls -al sizetest2

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/7.png)

分析：在bss段声明添加了10000字节的缓冲区后，可执行程序文件的总长度为4800字节，比原来只增加了160字节。

+ 验证实验**sizetest3.s**

程序的源代码略。

执行程序命令：

    as -o sizetest3.o sizetest3.s
    ld -o sizetest3 sizetest3.o
    ls -al sizetest3

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/8.png)

分析：用.fill命令在数据段声明添加了10000字节的缓冲区后，可执行程序文件的总长度为18880字节，比原来增加了14240字节，.fill命令使汇编器自动地创建了10000个数据元素，比原来的长度大了很多。

+ 验证实验**movetest1.s**

程序的源代码略。

执行程序命令：

    as -gstabs -o movtest1.o movtest1.s
    ld -o movtest1 movtest1.o
    gdb -q movtest1

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/9.png)

分析：可以看到，执行了movl value, %ecx命令后，内存中存储的值1被传送到了ecx寄存器，ecx寄存器的值从原来的0变成了1，寄存器中的值被传送到了另一寄存器中

+ 验证实验**movetest2.s**

程序的源代码略。

执行程序命令：

    as -gstabs -o movtest2.o movtest2.s
    ld -o movtest2 movtest2.o
    gdb -q movtest2

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/10.png)

分析：一开始查看value中的值，发现初始值为1，单步执行程序，一直到eax寄存器中的值被传送给了value内存中的位置后，再次查看value中的值，发现值为100，寄存器中的值被传送到了内存位置中

+ 验证实验**movetest3.s**

程序的源代码略。

执行程序命令：

    as --32 -o movtest3.o movtest3.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -lc -o movtest3 movtest3.o
    ./movtest3

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/11.png)

分析：程序遍历了values标签指定的数据数组，用edi寄存器作为遍历数组用的变址，每个值显示后，edi寄存器的值被递增，依次从10每次增加5打印到60

+ 验证实验**movetest4.s**

程序的源代码略。

执行程序命令：

    as -gstabs -o movtest4.o movtest4.s
    ld -o movtest4 movtest4.o
    gdb -q movtest4

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/12.png)

分析：程序开始时，首先查看values标签引用的内存位置中存储的值，前4个元素为10，15，20，25。

然后单步运行程序，发现第一个元素从values数组中加载到eax寄存器，即10，现在eax寄存器中的值为10。

继续单步执行，发现values标签引用的内存地址加载到了edi寄存器中，下一条指令又将100传送到了edi寄存器保存的地址之后4字节位置的内存地址，查看发现100保存到了values数组中的第二个元素的位置。

再下一条指令把数组的第二个元素加载到了ebx寄存器中，使用echo $?命令查看第二个数据数组元素的值，也是100。

+ 验证实验**cmovetest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o cmovtest.o cmovtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -lc -o cmovtest cmovtest.o
    ./cmovtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/13.png)
![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/14.png)

分析：寄存器ebx用来保存当前找到的最大整数，然后数组元素被逐个加载到寄存器eax中，并且和寄存器ebx中的值比较，如果寄存器eax中的值更大，就用寄存器eax中的值代替寄存器ebx中的值。

程序一开始，数组的第一个值被加载到寄存器ebx中。为105，第二个值被加载到寄存器eax中，为235，运行cmp和cmova指令，发现寄存器ebx寄存器中的值变成了更大的235，持续操作，直到数组的数全部被遍历完，最后寄存器ebx中的数就是数组中的数的最大值，为315。

+ 验证实验**swaptest.s**

程序的源代码略。

执行程序命令：

    as --gstabs -o swaptest.o swaptest.s
    ld -o swaptest swaptest.o
    gdb -q swaptest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/15.png)

分析：程序在第一条movl指令后停止，查看寄存器ebx中的值，为0x12345678，单步执行bswap指令后，显示寄存器ebx中的值，为0x78563412，和原始值尾数顺序相反。

+ 验证实验**cmpxchgtest.s**

程序的源代码略。

执行程序命令：

    as --gstabs -o cmpxchgtest.o cmpxchgtest.s
    ld -o cmpxchgtest cmpxchgtest.o
    gdb -q cmpxchgtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/16.png)

分析：在执行cmpxchg指令前，寄存器ebx中的值为5，data中的值为10，执行cmpxchg指令后，data中的值变为5，寄存器ebx中的值被传送到data的内存位置

+ 验证实验**cmpxchg8btest.s**

程序的源代码略。

执行程序命令：

    as -gstabs -o cmpxchg8btest.o cmpxchg8btest.s
    ld -o cmpxchg8btest cmpxchg8btest.o
    gdb -q cmpxchg8btest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/21.png)

分析：cmpxchg8b data使data引用一个内存位置，其中的8字节值会与寄存器edx和寄存器eax进行比较，如果目标值和edx:eax中包含的值匹配，就把位于ecx:ebx中的64位值传送给目标内存位置，如果不匹配，就把目标内存位置地址中的值加载到edx:eax寄存器对中，从输出可以看出，ecx:ebx中的6值确实传送给了data目标内存位置

+ 验证实验**bubble.s**

程序的源代码略。

执行程序命令：

    as -gstabs -o bubble.o bubble.s
    ld -o bubble bubble.o
    gdb -q bubble

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/17.png)

分析：程序为冒泡排序算法，程序运行前，values数组为乱序，程序运行完毕后，values数组为升序排序

+ 验证实验**pushpop.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o pushpop.o pushpop.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -lc -o pushpop pushpop.o
    gdb -q pushpop

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/18.png)

分析：启动程序前，寄存器esp中的值为0xffffd0d0，当执行完所有的push指令后，寄存器esp中的值为0xffffd0be，开始的值和最后的值相差了18个字节，所有经过push指令的操作数据加起来总长度也是18字节，说明执行push操作时寄存器esp会递减，指向堆栈新的起始位置。

### 遇到问题

1.一开始当使用gcc运行cpuid.s时，会发生错误：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/22.png)

原因是gcc库是64位的，不能编译运行32位的程序

2.当按照课本上命令运行cpuid2.s，会发生错误：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/19.png)

原因是源代码是32位的，在64位的系统上会生成64位的程序，运行时会发生兼容性错误，导致程序无法运行。

**解决方法：**

1.需要安装32位的库：

    sudo apt-get install libc6-dev-i386

执行程序命令改为：

    gcc cpuid.s -m32 -o cpuid

执行结果如下：

    The processor Vendor ID is 'GenuineIntel'

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/23.png)

2.可以将文件从64位强行编译成32位的程序，然后再运行。

在程序的源代码开头之前加上：

    .code32

并安装程序运行所需32位库：

    sudo apt-get update
    sudo apt install lib32z1 lib32ncurses5 g++-multilib libc6-dev-i386

执行程序命令改为：

    as --32 -o cpuid2.o cpuid2.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o cpuid2 -lc cpuid2.o
    ./cpuid2

执行结果如下：

    The processor Vendor ID is 'GenuineIntel'

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork2-pictures/20.png)
