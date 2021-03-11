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

分析：程序对存储在AL和BL寄存器中的2字节无符号整数值执行简单的加法。如果加法操作造成进位，则把进位标志设置为1,并且JC指令将跳转到标签over。程序的结果代码要么是加法的结果，要么就是0值（如果结果超过255）。

第一个程序设置寄存器值使加法产生进位，运行程序，然后使用echo命令查看结果代码，结果代码为0，表示正确检测到了进位情况。

第二个程序改动寄存器的值，使加法不产生进位，运行程序之后，加法没有产生进位，没有跳转，并且加法的结果被设置为结果代码200。

+ 验证实验**addtest4.s**

执行程序命令：

    as --32 -o addtest4.o addtest4.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o addtest4 -lc addtest4.o
    ./addtest4

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/5.png)

分析：程序试图把两个大的负数相加，这造成了溢出情况。JO指令用于检查溢出并且把控制传递到标签over。运行程序，输出0，这表明检测到了溢出情况。

把原程序代码中的：

    movl $-1590876934, %ebx
    movl $-1259230143, %eax

改为：

    movl $-190876934, %ebx
    movl $-159230143, %eax

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/6.png)

分析：修改MOVL指令，使两个值相加不产生溢出情况，就会看到加法的结果。

#### ADC指令

使用ADC指令处理非常大的、不能存放到双字数据长度中的带符号或者无符号整数的相加。

ADC指令的格式如下：

    adc source, destination

其中source可以是立即值或者8位、16位或者32位寄存器或内存位置值，destination可以是8位、16位或者32位寄存器或内存位置值。

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

分析：程序把两个64位值相加，一个值保持在EAX：EBX寄存器组合中，另一个值保持在ECX：EDX寄存器组合中。

可以看到，执行加法操作之后，64位整数的十六进制值被加载到了寄存器中，ECX：EDX寄存器对包含结果数据，使用printf函数也显示出了十进制形式的结果。

#### 减法指令

SUB指令的格式如下：

    sub source, destination

其中从destination的值中减去source的值，结果存储在destination操作数的位置。source可以是立即值或者8位、16位或者32位寄存器或内存位置值，destination可以是8位、16位或者32位寄存器或内存位置值。

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

分析：内存位置data1的值（40）减去EAX寄存器中的值（-30），得到正确的结果70。

#### 减法操作中的进位和溢出

+ 验证实验**subtest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o subtest2.o subtest2.s
    ld -m elf_i386 -o subtest2 subtest2.o
    ./subtest2
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/10.png)

分析：对于无符号整数，从2中减去5，可以看到，当结果小于0时，进位标志被设置为1，发生跳转，程序的结果代码为0，检查EBX寄存器中的值，发现为-3，尽管它被“认为是”无符号整数，但是由程序负责确定值是否超出了无符号（或者带符号）值的范围，只能使用进位标志确定无符号整数的减法产生负数结果的情况，如果执行带符号整数的减法，进位标志是没有用处的，因为结果长常常可能是负值，所以要依靠溢出标志来判断到达了数据长度界限的情况。

#### 依靠溢出标志来判断到达了数据长度界限的情况

+ 验证实验**subtest3.s**

程序的源代码略。

执行程序命令：

    as --32 -o subtest3.o subtest3.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o subtest3 -lc subtest3.o
    ./subtest3

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/11.png)

分析：程序演示从存储在EBX寄存器中的负值中减去存储在EAX寄存器中的正值，生产一个超过32位EBX寄存器范围的值。JO指令用于检测溢出标志，并且把程序转到over，把输出设置位0。

可以看到，溢出情况被检测到，并且执行JO指令和进行跳转。

为了测试程序在相反的情况是否正常工作，可以把EAX寄存器的值改为负值，把原程序中的：

    movl $1259230143, %eax

改为：

    movl $-1259230143, %eax

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/12.png)

分析：程序减去负数生成一个绝对值更小的负数，它在数据长度的界限之内，没有设置溢出标志。

#### SBB指令

可以使用进位情况帮助执行大的无符号整数值的减法操作，SBB指令在多字节减法操作中利用进位和溢出标志实现跨越数据边界的借位特性。

SBB指令的格式如下：

    sbb source, destination

其中进位位被添加到source值，从destination的值中减去source的值，结果存储在destination操作数的位置。source可以是8位、16位或者32位寄存器或内存位置值，destination可以是8位、16位或者32位寄存器或内存位置值，不能同时使用内存位置作为源和目标值。

+ 验证实验**sbbtest.s**

执行程序命令：

    as --32 -o sbbtest.o sbbtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o sbbtest -lc sbbtest.o
    ./sbbtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/13.png)

分析：结果与课本上预期的结果一样，得到了正确的减法值。

#### 乘法指令

MUL指令用于两个无符号整数相乘，MUL指令的格式如下：

    mul source

其中source可以是8位、16位或者32位寄存器或内存值。

无符号整数乘法需求：

|源操作数长度|目标操作数|目标位置|
|-----------|----------|-------|
|8位|AL|AX|
|16位|AX|DX:AX|
|32位|EAX|EDX:AX|

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

分析：程序演示两个32位无符号整数的乘法操作，并且从EDX：EAX寄存器获得结果。

寄存器对组合EDX：EAX生产结果值，这个值被存储在内存位置result中，并且通过printf函数显示出来，与课本上的预期的结果一致。

#### 带符号整数乘法

MUL指令只能用于无符号整数，而IMUL指令可以用于带符号和无符号整数、但是必须小心结果不使用目标的最高有效位,对于较大的值，IMUL指令只对带符号整数是合法的。为了应付比较复杂的情况，IMUL指令而3种不同的指令格式：

IMUL指令的第一种格式使用一个操作数，其行为和MUL指令完全一样：

    imul source

source操作数可以是8位、16位或者32位寄存器或内存中的值，它与位于AL、AX或者EAX寄存器（取决于源操作数的长度）中的隐含操作数相乘。然后，结果被存放到AX寄存器、DX:AX寄存器对或者EDX:EAX寄存器对中。

IMUL指令的第二种格式允许指定EAX寄存器之外的目标操作数：

    imul source, destination

其中source可以是16位或者32位寄存器或内存中的值，destination必须是16位或者32位通用寄存器。这种格式允许指定把乘法操作的结果存放到哪个位置（而不是强制使用AX和DX寄存器）。

这种格式的缺陷在于乘法操作的结果被限制为单一目标寄存器的长度（非64位结果）。使用这种格式时必须非常小心，不要溢出目标寄存器。

IMUL指令的第三种格式允许指定3个操作数：

    imul multiplier, source destination

其中multiplier是一个立即值，source是16位或者32位寄存器或内存中的值，destination必须是通用寄存器。这种格式允许执行一个值（source）和一个带符号整数（multiplier）的快速乘法操作，把结果存储到通用寄存器（destination）中.

+ 验证实验**imultest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o imultest.o imultest.s
    ld -m elf_i386 -o imultest imultest.o
    gdb -q imultest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/15.png)

分析：EAX寄存器包含EDX寄存器的值（400）和立即值2相乘得到的结果。ECX寄存器包含EBX寄存器的值（10）和最初加载到ECX寄存器中的值（-35）相乘的结果。注意，结果作为带符号整数值被存放到ECX寄存器中。

#### 带符号整数乘法检查溢出

当使用带符号整数和IMUL指令时，总是要检查结果中的溢出。一种方式是使用JO指令检查溢出标志。

+ 验证实验**imultest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o imultest2.o imultest2.s
    ld -m elf_i386 -o imultest2 imultest2.o
    gdb -q imultest2

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/16.png)

分析：程序杷两个值传送到16位寄存器中（AX和CX）,然后使用16位IMUL指令将它们相乘。设置结果会导致16位寄存器溢出，并且JO指令跳转到标签over，这里退出程序，带有结果代码1。

修改加载到寄存器中的立即数值，使结果小于65535，把原程序中的：

    movw $680, %ax

改为：

    movw $60, %ax

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/17.png)

分析：如果修改加载到寄存器中的立即数值，使结果小于65535, IMUL指令就不会把溢出标志设置为1，不会执行JO指令，程序退出，带有结果代码0。

#### 除法指令

DIV指令用于无符号整数的出发操作。DIV指令的格式如下：

    div divisor

其中divisor（除数）是隐含的被除数要除以的值，它可以是8位、16位或者32位寄存器或内存中的值。在执行DIV指令之前，被除数必须已经存储到了AX寄存器（对于16位值）、DX:AX寄存器对（对于32位值）或者EDX:EAX寄存器对（对于64位值）。

允许的除数的最大值取决于被除数的长度。对于16位被除数，除数只能是8位；对于32位被除数，除数只能是16位；对于64位被除数，除数只能是32位。

除法操作的结果是两个单独的数字：商和余数。这两个值都存储在被除数值使用的相同寄存器中。下表列出了其设置的情况。

|被除数|被除数长度|商|余数|
|-----|--------|--|---|
|AX|16位|AL |AH|
|DX:AX|32位|AX|DX|
|EDX:EAX|64位|EAX|EDX|

这就是说，当除法操作完成时，会丢失被除数，所以要确保这不是这个值的唯一拷贝（除非在除法操作之后就不需要被除数的值了）。还要记住，结果会改变DX或者EDX寄存器的值，所以也要小心其中存储的内容。

+ 验证实验**divtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o divtest.o divtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o divtest -lc divtest.o
    ./divtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/18.png)

分析：程序把一个64位四字按数加栽到EDX:EAX寄存器对中，然后使用一个存储在内存中的32位双字整数除这个值。32位的商值存储在一个内存位置中，32位的余数值存储在另一个内存位置中。

修改除数的值为0，检测除以0的情况，把原程序中的：

    divisor:
        .int 25

改为：

    divisor:
        .int 0

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/19.png)

分析：发生除以0的情况时会产生错误，系统会产生中断，需要进行检查。

#### 移位乘法

为了使整数乘以2的乘方，必须把值向左移位。可以使用两个指令使整数值向左移位，SAL（向左算术移位）和SHL（向左逻辑移位）。这两个指令执行相同的操作，并且是可以互换的。它们有3种不同格式：

    sal destination
    sal %c1, destination
    sal shifter, destination

第一种格式把destination的值向左移1位，这等同于使值乘以2。

第二种格式把destination的值向左移动CL寄存器中指定的位数。

最后一个版本把destination的值向左移动shifter值指定的位数。在所有的格式中，目标操作数可以是8位、16位或者32位寄存器或内存中的值。

+ 验证实验**saltest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o saltest.o saltest.s
    ld -m elf_i386 -o saltest saltest.o
    gdb -q saltest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/20.png)

分析：一开始，十进制值10被加载到EBX寄存器中。第一条SAL指令把它移动1位（使之乘以2，结果为20）。第二条SAL指令把它移动2位（使之乘以4,结果为80），第三条SAL指令把它再移动2位（使之乘以4，结果为320）。value1位置中的值（25）被移动1位（使之为50），然后再移动2位（使之为200）。

#### 把二进制结果转化为不打包BCD格式的指令（AAA为调整加法操作的结果）

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

分析：第三次执行ADC指令后，AL寄存器中包含的值为```10```，显示9和1的二进制加法结果为10。

执行AAA指令后，AX寄存器的值为```0x100 256```，它显示AH寄存器中的不打包值为1，AL寄存器中的值为0。1被带人到下一位的值的加法操作。

最后，结果按照不打包BCD格式存放到内存位置sum中。

#### 调整SUB或者SBB指令

+ 验证实验**dastest.s**

执行程序命令：

    as --32 -gstabs -o dastest.o dastest.s
    ld -m elf_i386 -o dastest dastest.o
    gdb -q dastest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/23.png)

分析：程序把第一个打包BCD值加载到AL寄存器中(每次一个十进制位)。然后使用SBB指令从它减去第二个打包BCD值。这样，前一次减法操作留下的任何进位位都会被考虑在内。然后使用DAS指令把结果转换为将存储在内存位置result中的打包BCD格式。ECX寄存器用于控制必须经过的循环次数(每个打包BCD字节一次)。转换之后，如果留有剩下的进位位，就把它存放在结果值中。

第一个减法操作之后，EAX寄存器的值为```0x0e 14```

执行DAS指令之后，这个值改变为```0x08 8```

它表示结果的第一个十进制位。

+ 验证实验**cpuidtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o cpuidtest.o cpuidtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o cpuidtest -lc cpuidtest.o
    ./cpuidtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/24.png)

分析：程序首先使用PUSHFL指令把EFLAGS寄存器的值保存到堆栈顶部。然后,使用POPL指令把EFLAGS值读取到EAX寄存器中。

下一个步骤演示如何使用XOR指令设置寄存器的一位。使用MOVL指令把EFLAGS值的拷贝 
保存到EDX寄存器中，然后使用XOR指令设置ID位（仍然在EAX寄存器中）为值1。XOR指令使用一个设置了ID位的立即值。EAX寄存器经过异或操作之后，就确保ID位被设置为1了。下一个步骤把新的EAX寄存器值压入到堆栈中，然后使用POPFL指令把它存储在EFLAGS寄存器中。

现在必须确定是否成功地设置了ID标志。再一次使用PUSHFL指令把EFLAGS寄存器压入堆栈，然后使用POPL指令把它弹出到EAX寄存器中。这个值和原始的EFLAGS值（先前存储在EDX寄存器中）进行XOR操作，查看值改变成了什么。

最后，使用TEST指令查看ID标志位是否改变了。如果是，那么EAX中的值就不为零，然后使用JNZ指令进行跳转，输出适当的消息。

### Chapter 10

#### 传送字符串

创建MOVS指令是为了把字符串从一个内存位置传送到另一个内存位置，MOVS指令有3种格式：

+ MOVSB:传送单一字节
+ MOVSW:传送一个字（2字节）
+ MOVSL:传送一个双字（4字节）

MOVS指令使用隐含的源和目标操作数。隐含的源操作数是ESI寄存器。它指向源字字符串的内存位置。隐含的目标操作数是EDI寄存器。它指向字符串要被复制到的目标内存位置。记住操作数顺序的好方法是ESI中的S代表源（source），而EDI中的D代表目标（destination）。

使用GNU汇编器时，有两种方式加载ESI和EDI值。第一种方式是使用间接寻址。通过在内存位置标签前面添加$，内存位置的地址被加载到了ESI或者EDI寄存器中:

    movl $output, %edi

这条指令把output标签的32位内存位置传送给EDI寄存器。

指定内存位置的另一种方式是LEA指令。LEA指令加载一个对象的有效地址。因为Linux使用32位值引用内存位置，所以对象的内存地址必须存储在32位的目标值中，源操作数必须指向一个内存位置，比如.data段中使用的标签。指令
    
    leal output, %edi

把output标签的32位内存位置加载到EDI寄存器中。

+ 验证实验**movstest1.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o movstest1.o movstest1.s
    ld -m elf_i386 -o movstest1 movstest1.o
    gdb -q movstest1

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/25.png)

分析：程序把内存位置value1的位置加载到ESI寄存器中。把output内存位置的位置加载到EDI寄存器中。当执行MOVSB指令时，它把1字节的数据从value1位置传送到output位置。因为在.bss段中声明output变量，所以存放在这里的任何字符串数据的结尾会被自动地加上空字符。

可以看到，MOVSB指令把“T”从value1位置传送到output位置。但是，无须改变ESI和EDI寄存器，当运行MOVSW指令时.它没有传送"Th"（字符串的前2个字节），而是把"hi"从value1位置传送到了output位置。然后MOVSL指令继续添加下4个字节的值。

+ 验证实验**movstest2.s**

使用STD指令时，ESI和EDI寄存器在每条MOVS指令执行之后递减,所以它们应该指向字 
符串的末尾，而不是开头。

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

分析：这一次，value1内存位置的地址位置被存放到EAX寄存器中，测试字符串的长度（减去1是因为字符串从地址0开始）与它相加。这个值被存放到ESI寄存器中。这使ESI寄存器指向测试字符串的末尾。对EDI进行相同的操作，使它指向内存位置output的末尾，STD指令用于设置DF标志，使ESI和EDI寄存器在每条MOVS指令执行之后递减。

3条MOVS指令在两个字符串位置之间传送1、2和4个字节的数据，output位置的字符串从字符串的末尾开始填充，但是3条MOVS指令执行之后，只有4个内存位置被填充了。在向前移动的movstest1.s程序中，使用相同的3条指令却填充了7个内存位置。这是因为尽管ESI和EDI寄存器向后计数。MOVSW和MOVSL指令还是按照向前的顺序获得内存位置。当MOVSB指令完成时，它使ESI和EDI寄存器递减1，但是M0VSW指令获得两个内存位置。同样，当M0VSW指令完成时，它使ESI和EDI寄存器递减2，但是MOVSL指令获得4个内存位置。

+ 验证实验**movstest3.s**

把MOVSL指令放在循环中，通过把ECX寄存器设置为字符串的长度来进行控制。

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

分析：ESI和EDI寄存器被设置为源和目标内存位置。ECX寄存器被设置为要传送的字符串的长度。循环部分持续地执行MOVSB指令。直到整个字符串传送完毕。可以看到，查看内存位置output的字符串值与课本上的预期输出一样。

#### REP前缀

REP指令用于按照特定次数重复执行字符串指令，由ECX寄存器中的值进行控制。这和使用循环类似,但是不需要额外的LOOP指令。REP指令重复地执行紧跟在它后面的字符串指令，直到ECX寄存器中的值为零。

+ 验证实验**reptest1.s**

MOVSB指令可以和REP指令一起使用，每次1字节地把字符串传送到另一个位置。

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o reptest1.o reptest1.s
    ld -m elf_i386 -o reptest1 reptest1.o
    gdb -q reptest1

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/28.png)

分析：要传送的字符串长度被加载到ECX寄存器中，然后使用REP指令执行MOVSB指令23次（字符串的长度），每次传送1字节的数据。在调试器中单步执行程序时，REP指令仍然只被算作一个指令步骤，而不是23个。

虽然单步执行指令时，REP指令只占用一个步骤，但是在这个步骤之后，源字符申的所有23个字节都被传送到了目标字符串位置。

+ 验证实验**reptest2.s**

也可以使用MOVSW和MOVSL指令在每次迭代中传送1字节以上的数据。

如果使用MOVSW和MOVSL指令，ECX寄存器就应该包含遍历字符串所需的迭代次数。例如，如果要传送8字节的字符串，如果使用MOVSB指令的话，就需要把ECX设置为8,使用MOVSW指令就设置为4，使用MOVSL指令就设置为2。

使用MOVSW和MOVSL指令遍历字符串时，小心不要超出字符串的边界。

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o reptest2.o reptest2.s
    ld -m elf_i386 -o reptest2 reptest2.o
    gdb -q reptest2

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/29.png)

分析：程序通过6次循环，传送每个5字节的数据块。但是源字符串的整个数据长度并不正好是4的倍数。最后一次执行MOVSL指令时，它不仅获得value1字符串的末尾，而且会错误地获得定义的下一个字符串一字节的数据。

可以看到，output字符串的输出包含value2字符串的第一个字符，它被添加到了value1字符串中，是错误的结果。

+ 验证实验**reptest3.s**

当知道字符串的长度时，就容易执行整数除法以便确定字符串中包含多少个双字。然后余数可以使用MOVSB指令进行传送（迭代次数应该小于3次）。

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o reptest3.o reptest3.s
    ld -m elf_i386 -o reptest3 reptest3.o
    gdb -q reptest3

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/30.png)

分析：程序把源和目标内存位置加载到ESI和EDI寄存器中，但是然后把字符串长度值加载到AX寄存器中。为了使字符串长度被4整除，使用SHR指令把长度值向右移动2位（这和被4整除相同），再把商值加载到ECX寄存器中。然后使REP MOVSL指令组合执行这个值指定的次数。完成之后，确定余数值。

如果除数是2的乘方，可以通过从除数中减去1，然后把它和被除数进行AND操作快速地获得余数。然后把这个值加载到ECX寄存器中，执行REP MOVSB指令组合来传送剩余的字符。

可以看到，首先，在执行REP MOVSL指令组合之后停止程序，显示内存位置buffer的内容：

    "This is a test of the conversion program"

注意，前40个字符从源字符串传送到了目标字符串。下面，执行REP MOVSB指令组合，并且再次查看内存位置buffer的内容：

    "This is a test of the conversion program!\n"

字符串中的最后两个字符被成功地传送了。

+ 验证实验**reptest4.s**

向后执行和向前执行REP指令都是可以的。可以把DF标志设置为对字符串进行向后处理，按照相反的方向在内存位置之间传送它。

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o reptest4.o reptest4.s
    ld -m elf_i386 -o reptest4 reptest4.o
    gdb -q reptest4

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/31.png)

分析：程序把源和目标字符串的末尾加载到ESI和EDI寄存器中，然后使用STD指令设置DF标志。这使目标字符串按照相反的顺序被存储。

#### STOS指令

使用LODS指令把字符串值存放到EAX寄存器之后，可以使用STOS指令把它存放到另一个
内存位置中。和LODS指令类似，根据要传送的数据的数量，STOS指令有3种格式：

+ STOSB: 存储AL寄存器中一个字节的数据
+ STOSW: 存储AX寄存器中一个字（2字节）的数据
+ STOSL: 存储EAX寄存器中一个双字（4个字节）的数据

STOS指令使用EDI寄存器作为隐含的目标操作数。执行STOS指令时，它按照使用的数据长
度递增或者递减EDI寄存器的值。

STOS指令可以和REP指令一起使用，多次把一个字符串值复制到大型字符串值中。

+ 验证实验**stostest1.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o stostest1.o stostest1.s
    ld -m elf_i386 -o stostest1 stostest1.o
    gdb -q stostest1

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/32.png)

分析：程序吧ASCII空格字符加载到AL寄存器中，然后把它复制到buffer标签指向的内存位置中256次。

可以看到，通过LODSB指令把空格字符加载到了AL寄存器中。在STOSB指令执行之前，内存位置buffer包含0。STOSB指令执行之后，内存位置buffer包含的都是空格。

#### 构建自己的字符串函数

STOS和LODS 指令可以用于各种字符串操作，通过使ESI和EDI寄存器指向相同的字符串，可以对字符串执行简单的操作。可以使用LODS指令遍历字符串，一次把一个字符加载到AL寄存器中，对这个字符执行某些操作，然后使用STOS指令把新的字符加载回字符串中。

+ 验证实验**convert.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o convert.o convert.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o convert -lc convert.o
    ./convert

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/33.png)

分析：程序把ASCII字符串都转换为大写字母。

程序把内存位置string1加载到ESI和EDI寄存器中，把字符串长度加载到ECX寄存器中。然后程序使用LOOP指令对字符串中的每个字符执行字符检查。程序进行字符检查的方法是，把每个字符加载到AL寄存器中，并且判断它是否小于字母a的ASCII值（0x61），或者大于字母z的ASCII值（0x7a）。如果字符在这个范围之内，那么它必然是小写字母，必须通过减去0x20把它转换为大写字母。

不管是否对字符进行了转换，都必须把它存放回字符串，以便保持ESI和EDI寄存器的同步。对每个字符都运行STOSB指令，然后代码向后循环到下一个字符，直到完成字符串中所有字符的处理。

可以看到，确实所有的字母都被转换成了大写字母。

#### 比较字符串

CMPS指令系列用于比较字符串值。和其他字符串指令一样，CMPS指令有3种格式：

+ CMPSB:比较字节值
+ CMPSW:比较字（2字节）值
+ CMPSL:比较双字（4字节）值

和其他字符串指令一样，隐含的源和目标操作数的位置同样存储在ESI和EDI寄存器中。每次执行CMPS指令时，根据DF标志的设置，ESI和EDI寄存器按照被比较的数据的长度递增或者递减。

CMPS指令从源字符串中减去目标字符串，并且适当地设置EFLAGS寄存器的进位、符号、
溢出、零、奇偶校验和辅助进位标志。CMPS指令执行之后，可以根据字符串的值，使用一般的条件跳转指令跳转到分支。

+ 验证实验**cmpstest1.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o cmpstest1.o cmpstest1.s
    ld -m elf_i386 -o cmpstest1 cmpstest1.o
    ./cmpstest1
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/34.png)

分析：程序比较两个字符串值，并且根据比较的结果设置程序的返回代码。程序首先把
exit系统调用值加载到EAX寄存器中。把要测试的两个字符串的位置加载到ESI和EDI寄存器中之后，程序使用CMPSL指令比较字符串的前4个字节。如果字符串相等，就使用JE指令跳转到标签equal，这里把程序结果代码设置为0并且退出。如果字符串不相等，则不会跳转到分支，程序顺序执行，设置结果代码为1并且退出。

可以看到，结果代码为0，表示字符串互相匹配。

+ 验证实验**cmpstest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o cmpstest2.o cmpstest2.s
    ld -m elf_i386 -o cmpstest2 cmpstest2.o
    ./cmpstest2
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/35.png)

分析：程序把源和目标字符串的位置加载到ESI和EDI寄存器中，把字符串长度加载到
ECX寄存器中。REPE CMPSB指令逐字节地重复字符串的比较，直到ECX寄存器为零，或者零标志被设置，这表明不匹配。

REPE指令执行之后，像以往那样使JE指令检查EFLAGS寄存器以便确定字符串是否相等。
如果REPE指令退出，则零标志将被设置，JE指令不跳转到分支，表示字符串不相同。ESI和EDI寄存器将包含字符串中不匹配字符的内存位置，并且ECX寄存器将包含不匹配字符在字符串中的位置（从字符串的末尾向回计数）。

可以看出，字符串比较是区分大小写的。两个字符串之间只有一个字符的大小写有区
别，这会被比较程序检测到。CMP指令从源字符串的十六进制值中减去目标字符串的值，得到结果```11```。

#### 字符串不等

+ 验证实验**strcomp.s**

程序定义两个字符串string1和string2，还有它们的长度（length1和length2）。程序生成的结果代码反映两个字符串的比较情况：

|结果代码|描述|
|--------|---|
|255|string1小于string2|
|0|string1等于string2|
|1|string1大于string2|

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o strcomp.o strcomp.s
    ld -m elf_i386 -o strcomp strcomp.o
    ./strcomp
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/36.png)

分析：从结果```255```可以看出，第一个字符串"test"小于第二个字符串"test1"。

#### 扫描字符串

SCAS指令系列用于扫描字符串搜索一个或者多个字符。和其他字符串指令一样，SCAS指
令有3个版本：

+ SCASB:比较内存中的一个字节和AL寄存器的值
+ SCASW:比较内存中的一个字和AX寄存器的值
+ SCASL:比较内存中的一个双字和EAX寄存器的值
  
SCAS指令使用EDI寄存器作为隐含的目标操作数。EDI寄存器必须包含要扫描的字符串的
内存地址。和其他字符串指令一样，当执行SCAS指令时，EDI寄存器的值按照搜索字符的数据长度递增或者递减（这取决于DF标志的值）。

+ 验证实验**scastest1.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o scastest1.o scastest1.s
    ld -m elf_i386 -o scastest1 scastest1.o
    ./scastest1
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/37.png)

分析：可以看到，在字符串的第16个位置找到了"-"字符。

#### 搜索多个字符

+ 验证实验**scastest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o scastest2.o scastest2.s
    ld -m elf_i386 -o scastest2 scastest2.o
    ./scastest2
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/38.png)

分析：程序试图在字符串中查找字符序列“test"。它把整个搜索字符串加载到EAX寄存
器中，然后使用SCASL指令一次检查字符串的4个字节。注意ECX寄存器没有被设置为字符串的长度，而是被设置为REPNE指令遍历整个字符串所需的迭代次数。因为每次迭代检查4个字节，所以ECX寄存器的值是整个字符串长度44的四分之一。

可以看到，结果代码为0，说明SCASL指令在字符串中没有找到字符序列"test"。显然，出现了某些错误。

这是因为REPNE指令的第一次选代比较4个字节的"This"和EAX中的字符序列。因为它们不匹配，所以ECX寄存器递增4，然后检查下面的4个字节"is"。被测试的每一组4个字节都不和搜索字符序列相匹配，尽管这个序列确实在这个字符串中。

#### 计算字符串的长度

+ 验证实验**strsize.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o strsize.o strsize.s
    ld -m elf_i386 -o strsize strsize.o
    ./strsize
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/39.png)

分析：程序结果说明字符串的长度为35。

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

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/21.png)

![](http://stugeek.gitee.io/operating-system/Labwork4-pictures/22.png)
