# 操作系统实验报告5

## 实验内容

+ 实验内容：进程的创建和终止。
    + 编译运行课件 Lecture 06 例程代码：Algorithm 6-1 ~ 6-6.

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

+ 验证实验**alg.6-1-fork-demo.c**

执行程序命令：

    gcc alg.6-1-fork-demo.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/1.png)

分析：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/2.jpg)

可以看到，子进程中的变量count与父进程中的变量count具有相同的虚拟地址。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/3.jpg)

子进程中的count值与父进程中的count值不同。它们被映射到不同进程映像中的不同物理地址。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/4.jpg)

由子进程和父进程执行的测试点

+ 验证实验**alg.6-2-vfork-demo.c**

执行程序命令：

    gcc alg.6-2-vfork-demo.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/5.png)

分析：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/6.jpg)

子进程中的变量计数与父进程中的变量计数具有相同的虚拟地址。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/7.jpg)

子进程的count值与父进程的count值相同。它们被映射到同一进程映像中的同一物理地址。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/8.jpg)

父进程被挂起，直到vfork的子进程终止。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/9.jpg)

子级在测试点之前退出，并且仅由父级执行

+ 验证实验**alg.6-3-fork-demo-nowait.c**

执行程序命令：

    gcc alg.6-3-fork-demo-nowait.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/10.png)

分析：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/11.jpg)

父进程终止，剩下一个孤立的pid=15432。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/12.jpg)

这里发生了什么？终端（bash）和分叉子级是异步工作的。

+ 验证实验**alg.6-4-fork-demo-wait.c**

执行程序命令：

    gcc alg.6-4-fork-demo-wait.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/13.png)

分析：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/14.jpg)

父进程正在等待子进程终止。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/15.jpg)

先由孩子完成，然后由家长完成的测试点

+ 验证实验**alg.6-5-0-sleeper.c**

执行程序命令：

    gcc alg.6-5-0-sleeper.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/16.png)

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/17.png)

分析：

+ 验证实验**alg.6-5-vfork-execv-wait.c**

执行程序命令：

    gcc alg.6-5-vfork-execv-wait.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/18.png)

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/19.png)

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/20.png)

分析：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/21.jpg)

睡眠者继承vWorked子级的pid（15477）

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/22.jpg)

父pro在调用的点“execv”处恢复，vWorked pro终止，sleeper作为子进程派生到同一个childpid中，但具有重复的地址空间，并返回到父进程，没有任何堆栈损坏。父级和子级异步执行。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/23.jpg)

任何方式父母需要等待他的孩子，或产卵睡眠专业可能成为孤儿

+ 验证实验**alg.6-6-vfork-execv-nowait.c**

执行程序命令：

    gcc alg.6-6-vfork-execv-nowait.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/24.png)

分析：bash是start main（）的父pro

start main（）是sleeper的父pro，它从execv（）继承vorked子级的pid

start main（）是system（）的父pro

sh是ps from system（“ps-l”）的父pro

Start main（）终止，控制返回bash，我从终端键入“ps-l”

它表明，睡眠者想念他的父母，并通过1484年

终端（bash）和睡眠者是异步工作的。

pid 1484是“systemd”的守护进程（代替“init”）

### 遇到问题

1.当运行某些程序时，如果需要进行调试，按照单步执行一步一步按```s```真的很慢，而且也容易因为按键太多而出一些错误。比如按照课本进行单步调试aaatest.s时，需要进行三四十步单步调试，才能退出中间的循环，在程序结束前查看结果的值，比较复杂：

    # aaatest.s - An example of using the AAA instruction
    .section .data
    value1:
        .byte 0x05, 0x02, 0x01, 0x08, 0x02
    value2:
        .byte 0x03, 0x03, 0x09, 0x02, 0x05
    .section .bss
        .lcomm sum, 6
    .section .text
    .globl _start
    _start:
        nop
        xor %edi, %edi
        movl $5, %ecx
        clc
    loop1:
        movb value1(, %edi, 1), %al
        adcb value2(, %edi, 1), %al
        aaa
        movb %al, sum(, %edi, 1)
        inc %edi
        loop loop1
        adcb $0, sum(, %edi, 4)
        movl $1, %eax
        movl $0, %ebx
        int $0x80


解决方案：在程序适当的地方设置断点，通过```cont```命令使程序在适当的地方停下来，而不需要一次一次地手动去按```s```进行单步调试：

    # aaatest.s - An example of using the AAA instruction
    .section .data
    value1:
        .byte 0x05, 0x02, 0x01, 0x08, 0x02
    value2:
        .byte 0x03, 0x03, 0x09, 0x02, 0x05
    .section .bss
        .lcomm sum, 6
    .section .text
    .globl _start
    _start:
        nop
        xor %edi, %edi
        movl $5, %ecx
        clc
    loop1:
        movb value1(, %edi, 1), %al
        adcb value2(, %edi, 1), %al
        aaa
        movb %al, sum(, %edi, 1)
        inc %edi
        loop loop1
        adcb $0, sum(, %edi, 4)
    end:
        movl $1, %eax
        movl $0, %ebx
        int $0x80

在loop1和end处设置断点，一个控制程序中间的循环，使得循环还未结束时每次输入```cont```都能在循环开始处停住，一个控制程序退出循环后，在结束程序前得到结果之后停住能够查看结果。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/21.png)

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/22.png)
