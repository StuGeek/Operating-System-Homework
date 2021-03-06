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

#### 跳转指令

跳转指令使用单一指令码：

    jmp location

其中location是要跳转到的内存地址

+ 验证实验**jumptest.s**

**1.构建一般可执行程序：**

程序的源代码略。

执行程序命令：

    as --32 -o jumptest.o jumptest.s
    ld -m elf_i386 -o jumptest jumptest.o
    ./jumptest
    echo $?

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/1.png)

分析：程序先把寄存器eax赋值为1，然后使用跳转指令跳过把寄存器ebx赋值为10，跳转到了把寄存器ebx赋值为20的语句，可以看到跳转确实发生了。

**2.使用objdump程序进行反汇编：**

执行程序命令：

    as --32 -gstabs -o jumptest.o jumptest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o jumptest jumptest.o
    objdump -D jumptest

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/2.png)

分析：程序开始时使用的第一个内存位置是```0x8049001```，overhere标签指向的内存位置是```0x8048083```。

**3.使用gdb运行程序：**

执行程序命令：

    as --32 -gstabs -o jumptest.o jumptest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o jumptest jumptest.o
    gdb -q jumptest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/3.png)

分析：

在程序的开始位置设置断点，并运行程序，查看使用的第一个内存位置，显示在寄存器eip中，这个值是```0x8049001```,它和objdump输出中显示的相同内存位置相对应，单步调试至执行了跳转指令，再次显示寄存器eip中的值，这个值是```0x8048083```，在objdump输出中显示，这是overhere标签指向的位置，说明实现跳转。

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

分析：在程序的开始，使用prinif显示第一个文本行，显示程序处于什么位位置。下一步, 使用call指令把控制转移到overhere标签。在overhere标签，寄存器esp的值被复制给指针ebp，以便在函数的结尾可以恢复它.再次使用prinf函数显示第二行文本，然后恢复esp和ebp寄存器。程序的控制返回到紧跟在call指令后面的指令，并且再次使用printf函数显示第三个文本行。

#### 比较指令

CMP指令的格式如下：

    cmp operand1, operand2

CMP指令把第二个操作数和第一个操作数进行比较。在幕后，它对两个操作数执行减法操作(operand2-operand1),比较指令不会修改这两个操作数，但是如果发生减法操作，就设置EFLAGS寄存器.

+ 验证实验**cmptest.s**

程序的源代码略。

执行程序命令：

    as --32 -o cmptest.o cmptest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o cmptest cmptest.o
    ./cmptest
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/5.png)

分析：程序首先把15赋给寄存器eax，把10赋给寄存器ebx，再使用CMP指令比较这两个寄存器，按照比较的结果，使用JGB指令进行分支操作，因为寄存器ebx的值小于寄存器eax的值，所以不执行条件分支，转向下一条指令执行，将1存放到寄存器eax中，可以看到，寄存器ebx中的值确实仍是10，没有进行分支操作。

#### 使用奇偶校检标志

奇偶校验标志表明数学运算答案中应该为1的位的数目。可以使用它作为粗略的错误检查系统.确保数学操作成功执行。

如果结果中被设况为1的位的数目是偶数，则设置奇偶校验位(置1)。如果设置为1的位的数目是奇数，则不设置奇偶校验位(置0)。

+ 验证实验**paritytest.s**

程序的源代码略。

执行程序命令：

    as --32 -o paritytest.o paritytest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o paritytest paritytest.o
    ./paritytest
    echo $?

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/6.png)

分析：减法的结果为1，以二进制表示是00000001。因为为1的位的数目是奇数，所以不设置奇偶校检位，JP指令不会跳转到分支，程序退出，并且以减法的结果1作为结果代码。

为了测试相反的情况，把原程序中的：

    subl $3, %ebx

改为：

    subl $1, %ebx

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/7.png)

分析：减法的结果是3，以二进制表示是00000011，因为为1的位的数目是偶数，所以设置奇偶校检位，并且JP指令应该转到overhere标签的分支，设置结果代码为100。

#### 使用符号标志

符号标志使用在带符号数中，用于表示寄存器中包含的值的符号改变。在带符号数中，最后一位（最高位）用作符号位。它表明数字表示是负值（设置为1）还是正值（设置为0）。

+ 验证实验**signtest.s**

程序的源代码略。

执行程序命令：

    as --32 -o signtest.o signtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o signtest -lc signtest.o
    ./signtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/8.png)

分析：signtest.s程序反向遍历数据数组，使用寄存器edi作为变址，处理每个数组元素时递减这个寄存器。使用JNS指令检杳寄存器edi的值什么时候变成负值，如果不是负值,则返回到循环的开头。

#### 循环指令

循环指令基本格式：

    loop address

其中address是要跳转到的程序代码位置的标签名称。循环开始前，必须在寄存器ecx中设置执行迭代的次数。

+ 验证实验**loop.s**

程序的源代码略。

执行程序命令：

    as --32 -o loop.o loop.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o loop -lc loop.o
    ./loop

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/9.png)

分析：循环指令执行100以及以内的正整数的相加指令，利用循环实现直到寄存器ecx的值为0，可以看到，结果为5050。

+ 验证实验**betterloop.s**

把loop.s原程序代码中的：

    movl $100, %ecx

改为：

    movl $0, %ecx

执行程序：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/10.png)

分析：将寄存器ecx设置为0时LOOP指令会将其递减为-1，然后继续执行下去，显示错误的值。所以需要使用JCXZ指令执行条件分支避免出错。

执行程序命令：

    as --32 -o betterloop.o betterloop.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o betterloop -lc betterloop.o
    ./betterloop

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/11.png)

分析：结果输出为0，确实正确的循环。

+ 验证实验**ifthen.c**

程序的源代码略。

执行程序命令：

    gcc -m32 -S ifthen.c
    cat ifthen.s

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/12.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/13.png)

分析：实现if-then语句的汇编语言代码逻辑

+ 验证实验**for.c**

程序的源代码略。

执行程序命令：

    gcc -m32 -S for.c
    cat for.s

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/14.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/15.png)

分析：实现for语句的汇编语言代码逻辑

### Chapter 07

#### 使用带符号整数

+ 验证实验**inttest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o inttest.o inttest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o inttest inttest.o
    gdb -q inttest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/16.png)

分析：调试器假设寄存器ebx和ecx包含带符号整数，并且使用我们期望的数据类型显示答案。但是寄存器edx出现了问题。因为调试器试图把整个寄存器edx作为带符号整数数据值显示,所以它假设整个寄存器edx包含一个双字带符号整数（32位）。因为寄存器edx只包含一个单字整数（16位），所以解释出的值是错误的。寄存器中的数据仍然是正确的（0xFFB1），但是调试器认为的这个数字表示的内容是错误的.

#### MOVZE指令

MOVZX指令把长度小的无符号整数值（可以在寄存器中，也可以在内存中）传送给长度大的无符号整数值（只能在寄存器中）。

MOVZX指令格式：

    movzx source, destination

其中source可以是8位或16位寄存器或者内存位置，destination可以是16位或者32位寄存器。

+ 验证实验**movzxtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o movzxtest.o movzxtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o movzxtest movzxtest.o
    gdb -q movzxtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/17.png)

分析：movzxtest.s程序简单地把一个大的值存放到寄存器ecx中，然后使用MOVZX指令把低8位 复制到寄存器ebx。因为存放在寄存器ecx中的值使用长度为字的无符号整数表示它（它大于255），所以CL中的值只表示完整值的一部分。

通过输出寄存器ebx和ecx的十进制值,马上就能发现无符号整数值没有被正确地复制，原始值为279,但是新的值只是23。通过按照十六进制显示值，可以发现为什么会这样。十六进制格式的原始值为0x0117，它占用一个双字。MOVZX指令只传送了寄存器ecx的低位字节，而用0填充了寄存器ebx中剩余的字节，这样就在寄存器ebx中生成了0x17这个值。

#### MOVSX指令

MOVSX指令允许扩展带符号整数并且保留符号，它假设要传送的字节是带符号整数格式，并且试图在传送过程中保持带符号整数的值不变。

+ 验证实验**movsxtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o movsxtest.o movsxtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o movsxtest movsxtest.o
    gdb -q movsxtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/18.png)

分析：movsxtest.s程序在寄存器cx中（双字长度）定义一个负值。然后试图把这个值复制到寄存器ebx中，程序首先使用零填充寄存器ebx，然后使用MOV指令。下一步，使用MOVSX指令把寄存器cx的值传送给寄存器eax。

单步运行程序，一直运行到MOVSX指令之后，可以使用调试器的info命令显示寄存器值。寄存器ecx包含的值是```0x0000FFB1```，低16位包含的值是```0xFFB1```,它是带符号整数格式的-79。当寄存器cx被传送给寄存器ebx时,寄存器ebx包含的值是```0x0000FFB1```,它是带符号整数格式 的65457,这是不对的。

使用MOVSX指令把寄存器cx传送给寄存器eax之后，寄存器eax包含的值是```0xFFFFFFB1```，它是带符号整数格式的-79,MOVSX指令正确地为这个值添加了高位部分的1。

+ 验证实验**movsxtest2.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o movsxtest2.o movsxtest2.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o movsxtest2 movsxtest2.o
    gdb -q movsxtest2

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/19.png)

分析：movsxtest2.s和movsxtest.s完成相同的工作，但是使用的是带符号整数正值。当寄存器cx被传送给空的寄存器ebx时。值的格式是正确的（因为高位部分的零对正数是没有问题的）。另外，MOVSX指令正确地使用零填充了寄存器eax，生成了正确的32位带符号整数值。

#### 在GNU汇编器中定义整数

```.quad```命令可以定义一个或者多个带符号整数值

+ 验证实验**quadtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o quadtest.o quadtest.s
    ld -m elf_i386 -dynamic-linker /lib/ld-linux.so.2 -o quadtest quadtest.o
    gdb -q quadtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/20.png)

分析：程序简单地在标签data1的位置定义一个包含5个双子带符号整数的数组，在标签data2的位置定义一个包含5个四字带符号整数的数组，然后退出程序，为了查看执行情况，再次对程序进行汇编并且在调试器中运行它。

首先，显示调试器认为的data1和data2数组的十进制值，data1数组的如期望，data2数组中的值不是程序中使用的值，这是因为调试器假设这些值是双字的带符号整数值。

然后查看内存中标签data1位置的数组值是如何存储的，可以看到，每个数组元素使用4个字节，并且按照小尾数格式存放。

接着查看存储在标签data2位置的数组值，可以看到，标签data2位置的数据值是使用四字编码的，所以每个值使用8个字节，汇编器把这些值放到了正确的位置，但是调试器不知道仅仅通过x/d命令如何显示这些值，需要使用gd选项显示这些值。

+ 验证实验**mmxtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o mmxtest.o mmxtest.s
    ld -m elf_i386 -o mmxtest mmxtest.o
    gdb -q mmxtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/21.png)

分析：程序定义了两个数据数组。第一个数组（value1）定义2个双字带符号整数，第二个数组（value2）定义8个字节带符号整数值。使用MOVQ指令把这些值加载到前2个MMX寄存器中。

可以看到，单步运行到MOVQ指令之后，可以显示MM0和MM1寄存器中的值，显示寄存器时，调试器不知道寄存器中数据的格式是什么，所以它会显示所有可能的情况，第一个pprint命令把MM0寄存器的内容显示为双字整数值。因为前面的例子使用双字整数值，所以唯一有意义的显示格式是int32，它显示正确的信息。可以使用print/f命令使调试器只生成这一格式。

但是MM1寄存器包含字节整数值，所以不能按照十进制模式显示它。可以使用print命令的x参数显示寄存器中的原始字节，可以看到，各个字节被正确地存放到了MM1寄存器中。

#### 传送SSE整数

MOVDQA和MOVDQU指令的简单格式：

    movdqa source, destination

MOVDQA和MOVDQU指令用于把128位数据传送到XMM寄存器中，或者在XMM寄存器之间传送数据，对于对准16个字节边界的数据，就使用A选项，否则，就使用U选项，其中source和destination可以是SSE128位寄存器或者128位的内存地址。

+ 验证实验**ssetest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o ssetest.o ssetest.s
    ld -m elf_i386 -o ssetest ssetest.o
    gdb -q ssetest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/22.png)

分析：程序定义了两个包含不同整数数据类型的数据数组。第一个数组（value1）定义4个双字带符号整数，第二个数组（value2）定义2个四字带符号整数值。使用MOVDQU指令把这两个数据数组传送到SSE寄存器中。

可以看到，MOVDQU指令执行之后，XMM0和XMM1寄存器包含数据段中定义的数据值。XMM0寄存器包含4个双字带符号整数数据值，XMM1寄存器包含2个四字带符号整数数据值。

#### 传送BCD值

IA-32指令集包含处理80位打包BCD值的指令。可以使用FBLD和FBSTP指令把80位打包 BCD值加载到FPU寄存器中以及从FPU寄存器获取这些值。

使用FPU寄存器的方式和使用通用寄存器稍微有些区别。8个FPU寄存器的行为类似于内存中的堆栈区域。可以把值压入和弹出FPU寄存器池。ST0引用位于堆栈顶部的寄存器。当值被压 
入FPU寄存器堆栈时.它被存放在ST0寄存器中，ST0中原来的值被加载到ST1中。

+ 验证实验**bcdtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o bcdtest.o bcdtest.s
    ld -m elf_i386 -o bcdtest bcdtest.o
    gdb -q bcdtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/23.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/24.png)

分析：bcdtest.s程序在标签data1定义的内存位置创建一个表示十进制值1234的简单的BCD值（记住Intel使用小尾数表示法）。使用FBLD指令把这个值加载到FPU寄存器堆栈的顶部（ ST0）。使用FIMUL指令把ST0寄存器和data2所在的内存位置中的整数值相乘。最后，使用FBSTP指令把堆栈中新的值传送回data1所在的内存位置中。

首先，在执行程序前，使用```x/10xb &data1```查看data1所在的内存位置值。1234的BCD值被加载到了data1所在的内存位置。

然后，单步执行FBLD指令，并且使用```info all```命令查看ST0寄存器中的值，ST0寄存器的值应该显示它加载了十进制值1234，但是这个寄存器的十六进制不是80位打包BCD格式，在FPU中，BCD值被转换成了浮点表示方式。

接着单步执行下一条指令（FIMUL），并且再次查看寄存器，发现ST0寄存器中的值和2相乘了。

最后把ST0中的值存放回data1所在的内存位置中，使用```x/10xb &data1```显示这个内存位置，可以看到，新的值被存放到了data1所在的内存位置，并且转换回了BCD格式。

#### 传送浮点值

FLD指令用于把浮点值传送入和传送出FPU寄存器。FLD指令的格式是：

    fld source

其中source可以是32位、64位或者80位内存位置。

+ 验证实验**floattest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o floattest.o floattest.s
    ld -m elf_i386 -o floattest floattest.o
    gdb -q floattest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/25.png)

分析：标签value1指向存储在4个字节内存中的单精度浮点值。标签value2指向存储在8个字节内存 中的双精度浮点值。标签data指向内存中的空缓冲区，它将被用于传输双精度浮点值。

IA-32的FLD指令用于把存储在内存中的单精度和双精度浮点数加载到FPU寄存器堆栈中。为了区分这两种数据长度，GNU汇编器使用FLDS指令加载单精度浮点数，而使用FLDL指令加载双精度浮点数。

类似地，FST指令用于获取FPU寄存器堆栈中顶部的值，并且把这个值存放到内存位置中。对于单精度数字，使用的指令是FSTS，双精度数字使用的指令是FSTL。

首先使用```x/f &value1```和```x/gf &value2```查看十进制值。f选项显示单精度数字，需要使用gf选项显示双精度值，显示四字值，当调试器试图计算要显示的值时，已经存在舍入错误。

接着，使用```x/4xb &value1```和```x/8xb &value2```查看浮点值是如何存储在内存位置的。

然后，单步运行第一条FLDS指令，使用```print $st0```查看ST0寄存器的值，可以看到，位于value1内存位置中的值```12.340000152587890625```被正确存放到了ST0寄存器中。

接下来，单步运行下一条指令，并且查看ST0寄存器中的值，这个值已经被替换为新加载的双精度值```2353.63099999999985812```

为了查看对原来加载的值进行了什么处理，查看ST1寄存器，发现当加载新的值时，ST0中的值被下移到了ST1寄存器中。

再查看data标签的值，单步执行FSTL指令，并且再次查看，发现FSTL指令把ST0寄存器中的值加载到了data标签指向的内存位置。

+ 验证实验**fpuvals.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o fpuvals.o fpuvals.s
    ld -m elf_i386 -o fpuvals fpuvals.o
    gdb -q fpuvals

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/26.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/27.png)

分析：程序简单地把各个浮点常量压入到FPU寄存器堆栈中。值的顺序和它们被存放到堆栈中的顺序是相反的。

+ 验证实验**ssefloat.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o ssefloat.o ssefloat.s
    ld -m elf_i386 -o ssefloat ssefloat.o
    gdb -q ssefloat

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/28.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/29.png)

分析：程序创建两个数据数组，每个数组由4个单精度浮点值组成。它们将成为被存储到XMM寄存器中的打包数据值，还创建了一个数据缓冲区。它有足够的空间保存4个单精度浮点值（即一个打包的值）。然后程序使用MOVUPS指令在XMM寄存器和内存之间传送打包单精度浮点值。

可以看到，所以数据都被正确地加载到了XMM寄存器中。v4_float格式显示使用的打包单精度浮点值。最后是把XMM寄存器的值复制到data位置。可以使用```x/4f```命令显示结果。

按照十六进制复查答案，发现内存位置data和内存位置value1中的值是匹配的。

+ 验证实验**sse2float.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o sse2float.o sse2float.s
    ld -m elf_i386 -o sse2float sse2float.o
    gdb -q sse2float

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/30.png)

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/31.png)

分析：存储在内存中的数值被改为双精度浮点值。因为程序将传输打包值，所以创建了一个包含2个值的数组。

可以看到，对于v2_double数据类型，正确的值已经被传送到了寄存器中。因为内存位置data包含2个双精度浮点值，所以使用```x/2gf```命令显示存储在这个内存位置的2个值，发现确实正确的值也被复制到了这里。

#### 转换指令

+ 验证实验**convtest.s**

程序的源代码略。

执行程序命令：

    as --32 -gstabs -o convtest.o convtest.s
    ld -m elf_i386 -o convtest convtest.o
    gdb -q convtest

执行结果如下：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/32.png)

分析：convtest.s程序在内存位置value1定义一个打包单精度浮点值，在内存位置value2定义一个打包双字整数值。第一对指令可以比较CVTPS2DQ和CVTTPS2DQ指令的结果。第一条指令执行一般的舍入，第二条指令通过向零方向舍入进行截断。

按照v4_int32格式，值被正确地显示出来，正如所见，一般转换把浮点值124.79舍入为125。但是截断转换把它向零方向舍入，使之成为124。内存位置data的值被转换为打包双字整数后，可以使用x/4d命令显示它。可以看到，显示出了舍入后的整数值。

### 遇到问题

1.当运行signtest.s时，会发生报错，显示```Error: can't open signtest.s for reading: No such file or directory```

原因是课本提供的原来的代码的有一行的的寄存器出错：

    add $8, $esp

解决方案：这行代码应该改为：

    add $8, %esp

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/33.png)

2.有时候按照课本的方式进行gdb调试，比如运行quadtest.s程序，使用```x/20b &data1```想以十六进制显示data1数组里的数值时，最后显示的是十进制的数值。

解决方法：把```x/20b &data1```改为```x/20xb &data1```，在代表显示数值长度的n=20后面加上x，就可以以十六进制显示数字，其它的程序显示时也是一样。

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/34.png)

3.当运行convtest.s时，会发生报错，显示```Error: symbol `data' is already defined```

原因是课本提供的原来的代码的data命名重复了

    data:
        .lcomm data, 16

和

    movdqu %xmm0, data

都与开头的```.section .data```重复

解决方案：代码应该改为：

    data1:
        .lcomm data, 16

和

    movdqu %xmm0, data1

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork3-pictures/35.png)

4.当运行ifthen.c和for.c时，如果按照课本上给的指令编译：

    gcc -S ifthen.c
    cat ifthen.s

    gcc -S for.c
    cat for.s

生成的.s文件是64位的，与课本上的代码不符。

解决方案：

应该使用32位命令进行编译：

    gcc -m32 -S ifthen.c
    cat ifthen.s

    gcc -m32 -S for.c
    cat for.s

这样生成的.s文件就是32位的，与课本上的代码相符。
