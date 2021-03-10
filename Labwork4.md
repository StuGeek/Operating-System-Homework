# 操作系统实验报告4

## 实验内容

+ 验证实验 Blum’s Book: Sample programs in Chapter 08, 10 (Basic Math Functions and Using Strings)

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### Chapter 08

#### 加法指令

ADD指令用于把两个整数相加，指令格式如下：

    add source, destination

其中source可以是立即值、内存位置或者寄存器。destination参数可以是寄存器或者内存位置中存储的值（但是不能同时使用内存位置作为源和目标）。加法的结果存放在目标位置。

ADD指令可以将8位、16位或者32位值相加。和其他GNU汇编器指令一样，必须通过在ADD助记符的结尾添加b（用于字节）、w（用于字）或者l（用于双字）来指定操作数的长度。

+ 验证实验**addtest1.s**

在程序的源代码的最后:

    movl $1, %eax

这一行前，加上:

    end:
        movl $1, %eax

便于进行断点调试。

执行程序命令：

    as --32 -gstabs -o addtest1.o addtest1.s
    ld -m elf_i386 -o addtest1 addtest1.o
    gdb -q addtest1

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/1.png)

分析：和课本预期的输出结果一致，对无符号数的加法执行正确。

+ 验证实验**addtest2.s**

在程序的源代码的最后:

    movl $1, %eax

这一行前，加上:

    end:
        movl $1, %eax

便于进行断点调试。

执行程序命令：

    as --32 -gstabs -o addtest2.o addtest2.s
    ld -m elf_i386 -o addtest2 addtest2.o
    gdb -q addtest2

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/2.png)

分析：和课本预期的输出结果一致，对带符号整数的加法执行也正确。

验证实验**addtest3.s**

执行程序命令：

    as --32 -gstabs -o addtest3.o addtest3.s
    ld -m elf_i386 -o addtest3 addtest3.o
    ./addtest3
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/3.png)

改动寄存器的值，使加法不产生进位，把原程序代码中的：

    movb $190, %bl
    movb $100, %al

改为：

    movb $190, %bl
    movb $10, %al

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/4.png)

分析：addtest3.s程序对存储在AL和BL寄存器中的2字节无符号整数值执行简单的加法。如果加法操作造成进位，则把进位标志设置为1,并且JC指令将跳转到标签over。程序的结果代码要么是加法的结果，要么就是0值（如果结果超过255）。因为我们设置了AL和BL寄存器中的值，所以我们可以控制程序中出现的情况.

第一个程序设置寄存器值使加法产生进位，运行程序，然后使用echo命令查看结果代码，结果代码为0，表示正确检测到了进位情况。

第二个程序改动寄存器的值，使加法不产生进位，运行程序之后，加法没有产生进位，没有跳转，并且加法的结果被设置位结果代码200。

+ 验证实验**addtest4.s**

执行程序命令：

    as --32 -o addtest4.o addtest4.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o addtest4 -lc addtest4.o
    ./addtest4

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/5.png)

把原程序代码中的：

    movl $-1590876934, %ebx
    movl $-1259230143, %eax

改为：

    movl $-190876934, %ebx
    movl $-159230143, %eax

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/6.png)

分析：addtest4.s程序试图把两个大的负数相加，这造成了溢出情况。JO指令用于检查溢出并且把控制传递到标签over。运行程序，输出0，这表明检测到了溢出情况。

修改MOVL指令，使两个值相加不产生溢出情况，就会看到加法的结果。

#### ADC指令

ADC指令的格式如下：

    cmp operand1, operand2

CMP指令把第二个操作数和第一个操作数进行比较。在幕后，它对两个操作数执行减法操作(operand2-operand1),比较指令不会修改这两个操作数，但是如果发生减法操作，就设置EFLAGS寄存器.

+ 验证实验**adctest.s**

在原程序代码中的：

    addl %ebx, %edx
    adcl %eax, %ecx
    pushl %ecx
    pushl %edx

加上：

    allmov:
        addl %ebx, %edx
        adcl %eax, %ecx
    alladd:
        pushl %ecx
        pushl %edx

便于加断点调试

执行程序命令：

    as --32 -gstabs -o adctest.o adctest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o adctest -lc adctest.o
    gdb -q adctest
    
    as --32 -gstabs -o adctest.o adctest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o adctest -lc adctest.o
    ./adctest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/7.png)

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/8.png)

分析：程序首先把15赋给寄存器eax，把10赋给寄存器ebx，再使用CMP指令比较这两个寄存器，按照比较的结果，使用JGB指令进行分支操作，因为寄存器ebx的值小于寄存器eax的值，所以不执行条件分支，转向下一条指令执行，将1存放到寄存器eax中，可以看到，寄存器ebx中的值确实仍是10，没有进行分支操作。

#### 减法指令

奇偶校验标志表明数学运算答案中应该为1的位的数目。可以使用它作为粗略的错误检查系统.确保数学操作成功执行。

如果结果中被设况为1的位的数目是偶数，则设置奇偶校验位(置1)。如果设置为1的位的数目是奇数，则不设置奇偶校验位(置0)。

+ 验证实验**subtest1.s**

在原程序代码中的：

   subl %eax, data
   movl $1, %eax

加上：

    end:
        subl %eax, data
        movl $1, %eax

便于加断点调试

执行程序命令：

    as --32 -gstabs -o subtest1.o subtest1.s
    ld -m elf_i386 -o subtest1 subtest1.o
    gdb -q subtest1

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/9.png)

分析：减法的结果为1，以二进制表示是00000001。因为为1的位的数目是奇数，所以不设置奇偶校检位，JP指令不会跳转到分支，程序退出，并且以减法的结果1作为结果代码。

#### 使用符号标志

符号标志使用在带符号数中，用于表示寄存器中包含的值的符号改变。在带符号数中，最后一位（最高位）用作符号位。它表明数字表示是负值（设置为1）还是正值（设置为0）。

+ 验证实验**subtest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o subtest2.o subtest2.s
    ld -m elf_i386 -o subtest2 subtest2.o
    ./subtest2
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/10.png)

分析：signtest.s程序反向遍历数据数组，使用寄存器edi作为变址，处理每个数组元素时递减这个寄存器。使用JNS指令检杳寄存器edi的值什么时候变成负值，如果不是负值,则返回到循环的开头。

#### 循环指令

循环指令基本格式：

    loop address

其中address是要跳转到的程序代码位置的标签名称。循环开始前，必须在寄存器ecx中设置执行迭代的次数。

+ 验证实验**subtest3.s**

程序的源代码略。

执行程序命令：

    as --32 -o subtest3.o subtest3.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o subtest3 -lc subtest3.o
    ./subtest3

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/11.png)

分析：溢出情况被检测到，并且执行JO指令和进行跳转。

为了测试程序在相反的情况是否正常工作，可以把EAX寄存器的值改为负值，把原程序中的：

    movl $1259230143, %eax

改为：

    movl $-1259230143, %eax

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/12.png)

分析：减法的结果是3，以二进制表示是00000011，因为为1的位的数目是偶数，所以设置奇偶校检位，并且JP指令应该转到overhere标签的分支，设置结果代码为100。dssadja

+ 验证实验**sbbtest.s**

执行程序命令：

    as --32 -o sbbtest.o sbbtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o sbbtest -lc sbbtest.o
    ./sbbtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/13.png)

分析：结果输出为0，确实正确的循环。

+ 验证实验**multest.s**

在原程序代码中的：

    pushl %edx
    pushl %eax

加上：

    aftermul:
        pushl %edx
        pushl %eax

便于加断点调试

执行程序命令：

    as --32 -gstabs -o multest.o multest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o multest -lc multest.o
    gdb -q multest
    ./multest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/14.png)

分析：实现if-then语句的汇编语言代码逻辑

+ 验证实验**imultest.s**

程序的源代码略。

执行程序命令：

as --32 -gstabs -o imultest.o imultest.s
ld -m elf_i386 -o imultest imultest.o
gdb -q imultest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/15.png)

分析：实现for语句的汇编语言代码逻辑

#### 使用带符号整数

+ 验证实验**imultest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o imultest2.o imultest2.s
    ld -m elf_i386 -o imultest2 imultest2.o
    gdb -q imultest2

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/16.png)

分析：调试器假设寄存器ebx和ecx包含带符号整数，并且使用我们期望的数据类型显示答案。但是寄存器edx出现了问题。因为调试器试图把整个寄存器edx作为带符号整数数据值 
显示,所以它假设整个寄存器edx包含一个双字带符号整数（32位）。因为寄存器edx只包含一个单字整数（16位），所以解释出的值是错误的。寄存器中的数据仍然是正确的 
（0xFFB1），但是调试器认为的这个数字表示的内容是错误的。

修改加载到寄存器中的立即数值，使结果小于65535，把原程序中的：

    movw $680, %ax

改为：

    movw $60, %ax

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/17.png)

分析：调试器假设寄存器ebx和ecx包含带符号整数，并且使用我们期望的数据类型显示答案。但是寄存器edx出现了问题。因为调试器试图把整个寄存器edx作为带符号整数数据值 
显示,所以它假设整个寄存器edx包含一个双字带符号整数（32位）。因为寄存器edx只包含一个单字整数（16位），所以解释出的值是错误的。寄存器中的数据仍然是正确的 
（0xFFB1），但是调试器认为的这个数字表示的内容是错误的.

#### 除法指令

MOVZX指令把长度小的无符号整数值（可以在寄存器中，也可以在内存中）传送给长度大的无符号整数值（只能在寄存器中）。

MOVZX指令格式：

    movzx source, destination

其中source可以是8位或16位寄存器或者内存位置，destination可以是16位或者32位寄存器。

+ 验证实验**divtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o divtest.o divtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o divtest -lc divtest.o
    ./divtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/18.png)

分析：movzxtest.s程序简单地把一个大的值存放到寄存器ecx中，然后使用MOVZX指令把低8位 复制到寄存器ebx。因为存放在寄存器ecx中的值使用长度为字的无符号整数表示它（它大于255），所以CL中的值只表示完整值的一部分。

通过输出寄存器ebx和ecx的十进制值,马上就能发现无符号整数值没有被正确地复制，原始值为279,但是新的值只是23。通过按照十六进制显示值，可以发现为什么会这样。十六进 
制格式的原始值为0x0117，它占用一个双字。MOVZX指令只传送了寄存器ecx的低位字节，而用0填充了寄存器ebx中剩余的字节，这样就在寄存器ebx中生成了0x17这个值.

修改除数的值为0，检测除以0的情况，把原程序中的：

    divisor:
        .int 25

改为：

    divisor:
        .int 0

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/19.png)

分析：调试器假设寄存器ebx和ecx包含带符号整数，并且使用我们期望的数据类型显示答案。但是寄存器edx出现了问题。因为调试器试图把整个寄存器edx作为带符号整数数据值 
显示,所以它假设整个寄存器edx包含一个双字带符号整数（32位）。因为寄存器edx只包含一个单字整数（16位），所以解释出的值是错误的。寄存器中的数据仍然是正确的 
（0xFFB1），但是调试器认为的这个数字表示的内容是错误的.

#### MOVSX指令

MOVSX指令允许扩展带符号整数并且保留符号，它假设要传送的字节是带符号整数格式，并且试图在传送过程中保持带符号整数的值不变。

+ 验证实验**saltest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o saltest.o saltest.s
    ld -m elf_i386 -o saltest saltest.o
    gdb -q saltest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/20.png)

分析：movsxtest.s程序在寄存器cx中（双字长度）定义一个负值。然后试图把这个值复制到寄存器ebx中，程序首先使用零填充寄存器ebx，然后使用MOV指令。下一步，使用MOVSX指令把寄存器cx的值传送给寄存器eax。

单步运行程序，一直运行到MOVSX指令之后，可以使用调试器的info命令显示寄存器值。寄存器ecx包含的值是```0x0000FFB1```，低16位包含的值是```0xFFB1```,它是带符号整数格式的-79。当寄存器cx被传送给寄存器ebx时,寄存器ebx包含的值是```0x0000FFB1```,它是带符号整数格式 的65457,这是不对的。

使用MOVSX指令把寄存器cx传送给寄存器eax之后，寄存器eax包含的值是```0xFFFFFFB1```，它是带符号整数格式的-79,MOVSX指令正确地为这个值添加了高位部分的1。

+ 验证实验**aaatest.s**

在原程序代码中的：

    movl $1, %eax
    movl $0, %ebx

加上：

    end:
        movl $1, %eax
        movl $0, %ebx

便于加断点调试

执行程序命令：

    as --32 -gstabs -o aaatest.o aaatest.s
    ld -m elf_i386 -o aaatest aaatest.o
    gdb -q aaatest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/21.png)

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/22.png)

#### 在GNU汇编器中定义整数

```.quad```命令可以定义一个或者多个带符号整数值

+ 验证实验**dastest.s**

执行程序命令：

    as --32 -gstabs -o dastest.o dastest.s
    ld -m elf_i386 -o dastest dastest.o
    gdb -q dastest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/23.png)

分析：程序简单地在标签data1的位置定义一个包含5个双子带符号整数的数组，在标签data2的位置定义一个包含5个四字带符号整数的数组，然后退出程序，为了查看执行情况，再次对程序进行汇编并且在调试器中运行它。

首先，显示调试器认为的data1和data2数组的十进制值，data1数组的如期望，data2数组中的值不是程序中使用的值，这是因为调试器假设这些值是双字的带符号整数值。

然后查看内存中标签data1位置的数组值是如何存储的，可以看到，每个数组元素使用4个字节，并且按照小尾数格式存放。

接着查看存储在标签data2位置的数组值，可以看到，标签data2位置的数据值是使用四字编码的，所以每个值使用8个字节，汇编器把这些值放到了正确的位置，但是调试器不知道仅仅通过x/d命令如何显示这些值，需要使用gd选项显示这些值。

+ 验证实验**cpuidtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o cpuidtest.o cpuidtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o cpuidtest -lc cpuidtest.o
    ./cpuidtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/24.png)

分析：程序定义了两个数据数组。第一个数组（value1）定义2个双字带符号整数，第二个数组（value2）定义8个字节带符号整数值。使用MOVQ指令把这些值加载到前2个MMX寄存器中。

可以看到，单步运行到MOVQ指令之后，可以显示MM0和MM1寄存器中的值，显示寄存器时，调试器不知道寄存器中数据的格式是什么，所以它会显示所有可能的情况，第一个pprint命令把MM0寄存器的内容显示为双字整数值。因为前面的例子使用双字整数值，所以唯一有意义的显示格式是int32，它显示正确的信息。可以使用print/f命令使调试器只生成这一格式。

但是MM1寄存器包含字节整数值，所以不能按照十进制模式显示它。可以使用print命令的x参数显示寄存器中的原始字节，可以看到，各个字节被正确地存放到了MM1寄存器中。

### Chapter 10

#### 传送SSE整数

MOVDQA和MOVDQU指令的简单格式：

    movdqa source, destination

MOVDQA和MOVDQU指令用于把128位数据传送到XMM寄存器中，或者在XMM寄存器之间传送数据，对于对准16个字节边界的数据，就使用A选项，否则，就使用U选项，其中source和destination可以是SSE128位寄存器或者128位的内存地址。

+ 验证实验**movstest1.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o movstest1.o movstest1.s
    ld -m elf_i386 -o movstest1 movstest1.o
    gdb -q movstest1

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/25.png)

分析：程序定义了两个包含不同整数数据类型的数据数组。第一个数组（value1）定义4个双字带符号整数，第二个数组（value2）定义2个四字带符号整数值。使用MOVDQU指令把这两个数据数组传送到SSE寄存器中。

可以看到，MOVDQU指令执行之后，XMM0和XMM1寄存器包含数据段中定义的数据值。XMM0寄存器包含4个双字带符号整数数据值，XMM1寄存器包含2个四字带符号整数数据值。

#### 传送BCD值

IA-32指令集包含处理80位打包BCD值的指令。可以使用FBLD和FBSTP指令把80位打包 BCD值加载到FPU寄存器中以及从FPU寄存器获取这些值。

使用FPU寄存器的方式和使用通用寄存器稍微有些区别。8个FPU寄存器的行为类似于内存中的堆栈区域。可以把值压入和弹出FPU寄存器池。ST0引用位于堆栈顶部的寄存器。当值被压 
入FPU寄存器堆栈时.它被存放在ST0寄存器中，ST0中原来的值被加载到ST1中。

+ 验证实验**movstest2.s**

在原程序代码中的：

    movl $1, %eax
    movl $0, %ebx

加上：

    end:
        movl $1, %eax
        movl $0, %ebx

便于加断点调试

执行程序命令：

    as --32 -gstabs -o movstest2.o movstest2.s
    ld -m elf_i386 -o movstest2 movstest2.o
    gdb -q movstest2

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/26.png)

分析：bcdtest.s程序在标签data1定义的内存位置创建一个表示十进制值1234的简单的BCD值（记住Intel使用小尾数表示法）。使用FBLD指令把这个值加载到FPU寄存器堆栈的顶部（ ST0）。使用FIMUL指令把ST0寄存器和data2所在的内存位置中的整数值相乘。最后，使用FBSTP指令把堆栈中新的值传送回data1所在的内存位置中。

首先，在执行程序前，使用```x/10xb &data1```查看data1所在的内存位置值。1234的BCD值被加载到了data1所在的内存位置。

然后，单步执行FBLD指令，并且使用```info all```命令查看ST0寄存器中的值，ST0寄存器的值应该显示它加载了十进制值1234，但是这个寄存器的十六进制不是80位打包BCD格式，在FPU中，BCD值被转换成了浮点表示方式。

接着单步执行下一条指令（FIMUL），并且再次查看寄存器，发现ST0寄存器中的值和2相乘了。

最后把ST0中的值存放回data1所在的内存位置中，使用```x/10xb &data1```显示这个内存位置，可以看到，新的值被存放到了data1所在的内存位置，并且转换回了BCD格式。

#### 传送浮点值

FLD指令用于把浮点值传送入和传送出FPU寄存器。FLD指令的格式是：

    fld source

其中source可以是32位、64位或者80位内存位置。

+ 验证实验**movstest3.s**

在原程序代码中的：

    movl $1, %eax
    movl $0, %ebx

加上：

    end:
        movl $1, %eax
        movl $0, %ebx

便于加断点调试

执行程序命令：

    as --32 -gstabs -o movstest3.o movstest3.s
    ld -m elf_i386 -o movstest3 movstest3.o
    gdb -q movstest3

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/27.png)

分析：标签value1指向存储在4个字节内存中的单精度浮点值。标签value2指向存储在8个字节内存 
中的双精度浮点值。标签data指向内存中的空缓冲区，它将被用于传输双精度浮点值。

IA-32的FLD指令用于把存储在内存中的单精度和双精度浮点数加载到FPU寄存器堆栈中。为了区分这两种数据长度，GNU汇编器使用FLDS指令加载单精度浮点数，而使用FLDL指令加 
裁双精度浮点数。

类似地，FST指令用于获取FPU寄存器堆栈中顶部的值，并且把这个值存放到内存位置中。对于单精度数字，使用的指令是FSTS，双精度数字使用的指令是FSTL。

首先使用```x/f &value1```和```x/gf &value2```查看十进制值。f选项显示单精度数字，需要使用gf选项显示双精度值，显示四字值，当调试器试图计算要显示的值时，已经存在舍入错误。

接着，使用```x/4xb &value1```和```x/8xb &value2```查看浮点值是如何存储在内存位置的。

然后，单步运行第一条FLDS指令，使用```print $st0```查看ST0寄存器的值，可以看到，位于value1内存位置中的值```12.340000152587890625```被正确存放到了ST0寄存器中。

接下来，单步运行下一条指令，并且查看ST0寄存器中的值，这个值已经被替换为新加载的双精度值```2353.63099999999985812```

为了查看对原来加载的值进行了什么处理，查看ST1寄存器，发现当加载新的值时，ST0中的值被下移到了ST1寄存器中。

再查看data标签的值，单步执行FSTL指令，并且再次查看，发现FSTL指令把ST0寄存器中的值加载到了data标签指向的内存位置。

+ 验证实验**reptest1.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o reptest1.o reptest1.s
    ld -m elf_i386 -o reptest1 reptest1.o
    gdb -q reptest1

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/28.png)

分析：程序简单地把各个浮点常量压入到FPU寄存器堆栈中。值的顺序和它们被存放到堆栈中的顺序是相反的。

+ 验证实验**reptest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o reptest2.o reptest2.s
    ld -m elf_i386 -o reptest2 reptest2.o
    gdb -q reptest2

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/29.png)

分析：程序创建两个数据数组，每个数组由4个单精度浮点值组成。它们将成为被存储到XMM寄存器中的打包数据值，还创建了一个数据缓冲区。它有足够的空间保存4个单精度浮点值（即一个打包的值）。然后程序使用MOVUPS指令在XMM寄存器和内存之间传送打包单精度浮点值。

可以看到，所以数据都被正确地加载到了XMM寄存器中。v4_float格式显示使用的打包单精度浮点值。最后是把XMM寄存器的值复制到data位置。可以使用```x/4f```命令显示结果。

按照十六进制复查答案，发现内存位置data和内存位置value1中的值是匹配的。

+ 验证实验**reptest3.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o reptest3.o reptest3.s
    ld -m elf_i386 -o reptest3 reptest3.o
    gdb -q reptest3

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/30.png)

分析：存储在内存中的数值被改为双精度浮点值。因为程序将传输打包值，所以创建了一个包含2个值的数组。

可以看到，对于v2_double数据类型，正确的值已经被传送到了寄存器中。因为内存位置data包含2个双精度浮点值，所以使用```x/2gf```命令显示存储在这个内存位置的2个值，发现确实正确的值也被复制到了这里。

#### 转换指令

+ 验证实验**reptest4.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o reptest4.o reptest4.s
    ld -m elf_i386 -o reptest4 reptest4.o
    gdb -q reptest4

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/31.png)

分析：convtest.s程序在内存位置value1定义一个打包单精度浮点值，在内存位置value2定义一个打包双字整数值。第一对指令可以比较CVTPS2DQ和CVTTPS2DQ指令的结果。第一条指令执行一般的舍入，第二条指令通过向零方向舍入进行截断。

按照v4_int32格式，值被正确地显示出来，正如所见，一般转换把浮点值124.79舍入为125。但是截断转换把它向零方向舍入，使之成为124。内存位置data的值被转换为打包双字整数后，可以使用x/4d命令显示它。可以看到，显示出了舍入后的整数值。

+ 验证实验**stostest1.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o stostest1.o stostest1.s
    ld -m elf_i386 -o stostest1 stostest1.o
    gdb -q stostest1

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/32.png)

分析：程序简单地把各个浮点常量压入到FPU寄存器堆栈中。值的顺序和它们被存放到堆栈中的顺序是相反的。

+ 验证实验**convert.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o convert.o convert.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o convert -lc convert.o
    ./convert

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/33.png)

分析：程序简单地把各个浮点常量压入到FPU寄存器堆栈中。值的顺序和它们被存放到堆栈中的顺序是相反的。

+ 验证实验**cmpstest1.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o cmpstest1.o cmpstest1.s
    ld -m elf_i386 -o cmpstest1 cmpstest1.o
    ./cmpstest1
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/34.png)

分析：程序简单地把各个浮点常量压入到FPU寄存器堆栈中。值的顺序和它们被存放到堆栈中的顺序是相反的。

+ 验证实验**cmpstest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o cmpstest2.o cmpstest2.s
    ld -m elf_i386 -o cmpstest2 cmpstest2.o
    ./cmpstest2
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/35.png)

分析：程序简单地把各个浮点常量压入到FPU寄存器堆栈中。值的顺序和它们被存放到堆栈中的顺序是相反的。

+ 验证实验**strcomp.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o strcomp.o strcomp.s
    ld -m elf_i386 -o strcomp strcomp.o
    ./strcomp
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/36.png)

分析：程序简单地把各个浮点常量压入到FPU寄存器堆栈中。值的顺序和它们被存放到堆栈中的顺序是相反的。

+ 验证实验**scastest1.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o scastest1.o scastest1.s
    ld -m elf_i386 -o scastest1 scastest1.o
    ./scastest1
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/37.png)

分析：程序简单地把各个浮点常量压入到FPU寄存器堆栈中。值的顺序和它们被存放到堆栈中的顺序是相反的。

+ 验证实验**scastest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o scastest2.o scastest2.s
    ld -m elf_i386 -o scastest2 scastest2.o
    ./scastest2
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/38.png)

分析：程序简单地把各个浮点常量压入到FPU寄存器堆栈中。值的顺序和它们被存放到堆栈中的顺序是相反的。

+ 验证实验**strsize.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o strsize.o strsize.s
    ld -m elf_i386 -o strsize strsize.o
    ./strsize
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/39.png)

分析：程序简单地把各个浮点常量压入到FPU寄存器堆栈中。值的顺序和它们被存放到堆栈中的顺序是相反的。

### 遇到问题

1.当运行signtest.s时，会发生报错，显示```Error: can't open signtest.s for reading: No such file or directory```

原因是课本提供的原来的代码的有一行的的寄存器出错：

    add $8, $esp

解决方案：这行代码应该改为：

    add $8, %esp

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/33.png)

2.有时候按照课本的方式进行gdb调试，比如运行quadtest.s程序，使用```x/20b &data1```想以十六进制显示data1数组里的数值时，最后显示的是十进制的数值。

解决方法：把```x/20b &data1```改为```x/20xb &data1```，在代表显示数值长度的n=20后面加上x，就可以以十六进制显示数字，其它的程序显示时也是一样。

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/34.png)