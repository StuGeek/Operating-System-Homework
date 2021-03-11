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

使用ADC指令处理非常大的、不能存放到双字数据长度中的带符号或者无符号证书的相加。

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

分析：标签value1指向存储在4个字节内存中的单精度浮点值。标签value2指向存储在8个字节内存中的双精度浮点值。标签data指向内存中的空缓冲区，它将被用于传输双精度浮点值。

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