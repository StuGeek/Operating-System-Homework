# 操作系统实验报告3

## 实验内容

+ 验证实验 Blum’s Book: Sample programs in Chapter 06, 07 (Controlling Flow and Using Numbers)

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### Chapter 06

+ 验证实验**jumptest.s**

**1.构建一般可执行程序：**

程序的源代码略。

执行程序命令：

    as -o jumptest.o jumptest.s
    ld -o jumptest jumptest.o
    ./jumptest
    echo $?

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/1.png)

**2.使用objdump程序进行反汇编：**

执行程序命令：

    as --32 -gstabs -o jumptest.o jumptest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o jumptest jumptest.o
    objdump -D jumptest

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/2.png)

**3.使用gdb运行程序：**

执行程序命令：

    as --32 -gstabs -o jumptest.o jumptest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o jumptest jumptest.o
    gdb -q jumptest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/3.png)

分析：

一开始在程序开始处设置断点,然后输入run运行，输入命令next\n\step\s可以看见单步调试程序，输入cont程序直接运行完毕，输出

    The processor Vendor ID is 'GenuineIntel'

重新输入run，输入s单步执行至cpuid语句，输入info registers，可以看见所有寄存器中的值，再输入s执行至下一语句，输入info registers，可以看见寄存器中值的变化，可以看见，在执行cpuid语句前寄存器rbx，rcx，rdx的值都为0，执行cpuid后，它们包含从厂商ID字符串得来的值。

print/x $ebx, print/x $edx, print/x $ecx分别以十六进制形式显示寄存器ebx,edx和ecx中的值，可以看到，寄存器ebx中的值为0x756e6547，寄存器edx中的值为0x49656e69，寄存器ecx中的值为0x6c65746e。

x/42cd &output以字符变量的形式显示变量output的前42个字节

**gdb基本指令总结：**

    break *_start:在程序开始处设置断点
    break *end:在程序结束处设置断点
    run:在gdb内运行启动程序(碰到断点便停止)
    step/s/next/n:单步调试程序
    cont:使程序继续运行
    info registers:显示全部寄存器的值
    print:显示某一寄存器或变量的值
    print/d:显示十进制的值
    print/t:显示二进制的值
    print/x:显示十六进制的值
    x/nyz:显示特定内存位置的值,n是要显示的字段数,y是输出格式,z是要显示字段的长度

+ 验证实验**calltest.s**

执行程序命令：

    as --32 -o calltest.o calltest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o calltest -lc calltest.o
    ./calltest

执行结果如下：

    This is section 1
    This is section 2
    This is section 3

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/4.png)

+ 验证实验**cmptest.s**

程序的源代码略。

执行程序命令：

    as -o cmptest.o cmptest.s
    ld -o cmptest cmptest.o
    ./cmptest
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/5.png)

分析：可执行程序文件的总长度为4640字节

+ 验证实验**paritytest.s**

程序的源代码略。

执行程序命令：

    as -o paritytest.o paritytest.s
    ld -o paritytest paritytest.o
    ./paritytest
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/6.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/7.png)

分析：在bss段声明添加了10000字节的缓冲区后，可执行程序文件的总长度为4800字节，比原来只增加了160字节，说明在bss段声明数据不必包含在可执行程序中。

+ 验证实验**signtest.s**

程序的源代码略。

执行程序命令：

    as --32 -o signtest.o signtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o signtest -lc signtest.o
    ./signtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/8.png)

分析：用.fill命令在数据段声明添加了10000字节的缓冲区后，可执行程序文件的总长度为18880字节，比原来增加了14240字节，.fill命令使汇编器自动地创建了10000个数据元素，使它比必要的长度大了很多，说明在数据段定义数据时，其必须被包含在可执行程序中。

#### 传送数据元素

MOV指令基本格式：

    movx source, destination

source和destination可以是内存地址，存储在内存中的数据值，指令语句中定义的数据值，或者是寄存器

+ 验证实验**loop.s**

程序的源代码略。

执行程序命令：

    as --32 -o loop.o loop.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o loop -lc loop.o
    ./loop

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/9.png)

分析：可以看到，执行了movl value, %ecx命令后，内存中存储的值1被传送到了ecx寄存器，ecx寄存器的值从原来的0变成了1，内存位置中的值被传送到了另一寄存器中

+ 验证实验**betterloop.s**

程序的源代码略。

执行程序命令：

    as --32 -o betterloop.o betterloop.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o betterloop -lc betterloop.o
    ./betterloop

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/10.png)

分析：一开始查看value中的值，发现初始值为1，单步执行程序，一直到eax寄存器中的值被传送给了value内存中的位置后，再次查看value中的值，发现值为100，寄存器中的值被传送到了内存位置中

+ 验证实验**ifthen.c**

程序的源代码略。

执行程序命令：

    gcc -S ifthen.c
    cat ifthen.s

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/11.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/12.png)

分析：程序遍历了values标签指定的数据数组，用edi寄存器作为遍历数组用的变址，每个值显示后，edi寄存器的值被递增，依次从10每次增加5打印到60

+ 验证实验**for.c**

程序的源代码略。

执行程序命令：

    gcc -S for.c
    cat for.s

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/13.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/14.png)

分析：程序开始时，首先查看values标签引用的内存位置中存储的值，前4个元素为10，15，20，25。

然后单步运行程序，发现第一个元素从values数组中加载到eax寄存器，即10，现在eax寄存器中的值为10。

继续单步执行，发现values标签引用的内存地址加载到了edi寄存器中，下一条指令又将100传送到了edi寄存器保存的地址之后4字节位置的内存地址，使用寄存器间接寻址，查看发现100保存到了values数组中的第二个元素的位置。

再下一条指令把数组的第二个元素加载到了ebx寄存器中，使用echo $?命令查看第二个数据数组元素的值，也是100。

### Chapter 07

#### 条件传送指令

指令格式：

    cmovx source, destination

其中x是一个或者两个字母的代码，表示将触发传送操作的条件，取决于EFLAGS寄存器的当前值。

+ 验证实验**inttest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o inttest.o inttest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o inttest inttest.o
    gdb -q inttest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/15.png)

分析：寄存器ebx用来保存当前找到的最大整数，然后数组元素被逐个加载到寄存器eax中，并且和寄存器ebx中的值比较，如果寄存器eax中的值更大，就用寄存器eax中的值代替寄存器ebx中的值。

程序一开始，数组的第一个值被加载到寄存器ebx中。为105，第二个值被加载到寄存器eax中，为235，运行cmp和cmova指令，发现寄存器ebx寄存器中的值变成了更大的235，持续操作，直到数组的数全部被遍历完，最后寄存器ebx中的数就是数组中的数的最大值，为315。

#### 数据交换指令

基本指令：

    XCHG:在两个寄存器之间或者寄存器和内存位置之间交换它们的值
    BSWAP:反转一个32位寄存器中的字节顺序
    XADD:交换两个值并且把它们的总和存储在目标操作数中
    CMPXCHG:把一个值和一个外部的 值进行比较，并且交换它和另一个的值
    CMPXCHG8B:比较两个64位的值并且交换它们的值

+ 验证实验**movzxtest.s**

程序的源代码略。

执行程序命令：

    as -gstabs -o  movzxtest.o movzxtest.s
    ld -o movzxtest movzxtest.o
    gdb -q movzxtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/16.png)

分析：程序在第一条movl指令后停止，查看寄存器ebx中的值，为0x12345678，单步执行bswap指令后，显示寄存器ebx中的值，为0x78563412，和原始值尾数顺序相反。

+ 验证实验**movsxtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o movsxtest.o movsxtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o movsxtest movsxtest.o
    gdb -q movsxtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/17.png)

分析：在执行cmpxchg指令前，寄存器ebx中的值为5，data中的值为10，执行cmpxchg指令后，data中的值变为5，寄存器ebx中的值被传送到data的内存位置

+ 验证实验**movsxtest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o movsxtest2.o movsxtest2.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o movsxtest2 movsxtest2.o
    gdb -q movsxtest2

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/18.png)

分析：在执行cmpxchg指令前，寄存器ebx中的值为5，data中的值为10，执行cmpxchg指令后，data中的值变为5，寄存器ebx中的值被传送到data的内存位置

+ 验证实验**quadtest.s**

程序的源代码略。

执行程序命令：

    as -gstabs -o quadtest.o quadtest.s
    ld -o quadtest quadtest.o
    gdb -q quadtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/19.png)

分析：cmpxchg8b data使data引用一个内存位置，其中的8字节值会与寄存器edx和寄存器eax进行比较，如果目标值和edx:eax中包含的值匹配，就把位于ecx:ebx中的64位值传送给目标内存位置，如果不匹配，就把目标内存位置地址中的值加载到edx:eax寄存器对中，从输出可以看出，ecx:ebx中的值确实传送给了data目标内存位置

+ 验证实验**mmxtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o mmxtest.o mmxtest.s
    ld -m elf_i386 -o mmxtest mmxtest.o
    gdb -q mmxtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/20.png)

分析：程序为冒泡排序算法，程序运行前，values数组为乱序，程序运行完毕后，values数组为升序排序

#### 压入数据和弹出数据

PUSH指令的简单格式：

    pushx source

其中x表示数据元素的长度，source是要放入堆栈的数据元素

POP指令的格式：

    popx destination

其中x表示数据元素的长度，destination是接收数据的位置

+ 验证实验**ssetest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o ssetest.o ssetest.s
    ld -m elf_i386 -o ssetest ssetest.o
    gdb -q ssetest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/21.png)

分析：启动程序前，寄存器esp中的值为0xffffd0d0，当执行完所有的push指令后，寄存器esp中的值为0xffffd0be，开始的值和最后的值相差了18个字节，所有经过push指令的操作数据加起来总长度也是18字节，说明执行push操作时寄存器esp会递减，指向堆栈新的起始位置。

+ 验证实验**bcdtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o bcdtest.o bcdtest.s
    ld -m elf_i386 -o bcdtest bcdtest.o
    gdb -q bcdtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/22.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/23.png)

分析：程序为冒泡排序算法，程序运行前，values数组为乱序，程序运行完毕后，values数组为升序排序

+ 验证实验**floattest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o floattest.o floattest.s
    ld -m elf_i386 -o floattest floattest.o
    gdb -q floattest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/24.png)

分析：程序为冒泡排序算法，程序运行前，values数组为乱序，程序运行完毕后，values数组为升序排序

+ 验证实验**fpuvals.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o fpuvals.o fpuvals.s
    ld -m elf_i386 -o fpuvals fpuvals.o
    gdb -q fpuvals

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/25.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/26.png)

分析：程序为冒泡排序算法，程序运行前，values数组为乱序，程序运行完毕后，values数组为升序排序

+ 验证实验**ssefloat.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o ssefloat.o ssefloat.s
    ld -m elf_i386 -o ssefloat ssefloat.o
    gdb -q ssefloat

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/17.png)

分析：程序为冒泡排序算法，程序运行前，values数组为乱序，程序运行完毕后，values数组为升序排序

+ 验证实验**sse2float.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o sse2float.o sse2float.s
    ld -m elf_i386 -o sse2float sse2float.o
    gdb -q sse2float

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/17.png)

分析：程序为冒泡排序算法，程序运行前，values数组为乱序，程序运行完毕后，values数组为升序排序

+ 验证实验**convtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o convtest.o convtest.s
    ld -m elf_i386 -o convtest convtest.o
    gdb -q convtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/17.png)

分析：程序为冒泡排序算法，程序运行前，values数组为乱序，程序运行完毕后，values数组为升序排序

### 遇到问题

1.signtest.s：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/22.png)

原因是gcc库是64位的，不能编译运行32位的程序

2.当按照课本上命令运行cpuid2.s，会发生错误：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/19.png)

原因是源代码是32位的，在64位的系统上会生成64位的程序，运行时会发生兼容性错误，导致程序无法运行。

**解决方法：**

1.需要安装32位的库：

    sudo apt-get install libc6-dev-i386

执行程序命令改为：

    gcc cpuid.s -m32 -o cpuid

执行结果如下：

    The processor Vendor ID is 'GenuineIntel'

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/23.png)

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

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/20.png)
