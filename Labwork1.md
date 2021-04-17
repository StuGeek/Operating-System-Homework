# 操作系统实验报告1

## 实验内容

+ 阅读 uCore 实验项目开始文档 (uCore Lab 0)，准备实验平台，熟悉实验工具。

+ uCore Lab 1：系统软件启动过程
(1) 编译运行 uCore Lab 1 的工程代码；
(2) 完成 uCore Lab 1 练习 1-4 的实验报告；
(3) 尝试实现 uCore Lab 1 练习 5-6 的编程作业；
(4) 思考如何实现 uCore Lab 1 扩展练习 1-2。

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## (1)编译运行 uCore Lab 1 的工程代码

在lab1的makefile文件目录下， 输入命令：

    make

即可编译运行 uCore Lab 1 的工程代码

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice1-01.png)

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice1-02.png)

如果输入```make```，程序报错，提示```make: Nothing to be done for 'TARGETS'.```，那么说明文件没有更新而且已经编译过了，想要再次强制编译，只要输入```make clean```，然后再输入```make```就可以编译了：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice1-03.png)

## (2) uCore Lab 1 练习 1-4 实验报告

### lab1 练习 1：理解通过 make 生成执行文件的过程

列出本实验各练习中对应的 OS 原理的知识点，并说明本实验中的实现部分如何对应和体现了原理中的基本概念和关键知识点。

在此练习中，大家需要通过静态分析代码来了解：

#### 操作系统镜像文件 ucore.img 是如何一步一步生成的？(需要比较详细地解释 Makefile 中每一条相关命令和命令参数的含义，以及说明命令导致的结果)

**首先找到makefile文件中注释为```create ucore.img```这一部分的内容：**

    # create ucore.img
    UCOREIMG    := $(call totarget,ucore.img)

    $(UCOREIMG): $(kernel) $(bootblock)
        $(V)dd if=/dev/zero of=$@ count=10000
        $(V)dd if=$(bootblock) of=$@ conv=notrunc
        $(V)dd if=$(kernel) of=$@ seek=1 conv=notrunc

    $(call create_target,ucore.img)

```UCOREIMG    := $(call totarget,ucore.img)```表示调用call函数生成```UCOREIMG```，其中```call```为调用call函数，```totarget,ucore.img```中的```totarget```可以在```tools/function.mk```中找到，定义为```totarget = $(addprefix $(BINDIR)$(SLASH),$(1))```，```addprefix```代表在前面加上，```$(BINDIR)```代表```bin```，```$(SLASH)```代表```/```，所以```totarget,ucore.img```的意思就是在```ucore.img```前面加上```bin/```，调用call函数生成的```UCOREIMG```即为```bin/ucore.img```。

```$(UCOREIMG): $(kernel) $(bootblock)```表示生成```UCOREIMG```首先要依赖```kernel```和```bootblock```这两个文件的生成，这两个文件具体的生成过程会在后面提到。

```$(V)dd if=/dev/zero of=$@ count=10000```表示创建一个每个块默认为512字节，一共10000个块，用0填充的文件，分配给```UCOREIMG```。```if=/dev/zero```代表读取```/dev/zero```文件，```/dev/zero```文件是一个特殊的文件，读取它会提供无限的空字符，```of=$@```的```$@```代表之前读取的数据将会复制到的目标文件，这里是```UCOREIMG```，```count=10000```表示一共10000个块。

```$(V)dd if=$(bootblock) of=$@ conv=notrunc```表示将```bootblock```中的内容写到```UCOREIMG```的第一个块里。```conv=notrun```代表写入文件时防止截断，保持数据完整性。

```$(V)dd if=$(kernel) of=$@ seek=1 conv=notrunc```表示从```UCOREIMG```的第二个块开始写kernel里的内容，```seek=1```代表跳过```seek```个块之后再开始填写，这里为跳过1个块。

```$(call create_target,ucore.img)```直接返回。

**生成```UCOREIMG```首先要依赖```kernel```和```bootblock```这两个文件的生成，首先来看```kernel```文件的生成**

找到makefile文件中注释为```kernel```这一部分的内容：

    KINCLUDE    += kern/debug/ \
                kern/driver/ \
                kern/trap/ \
                kern/mm/

    KSRCDIR	    += kern/init \
                kern/libs \
                kern/debug \
                kern/driver \
                kern/trap \
                kern/mm

    KCFLAGS	    += $(addprefix -I,$(KINCLUDE))

    $(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))

    KOBJS	= $(call read_packet,kernel libs)

    # create kernel target
    kernel = $(call totarget,kernel)

    $(kernel): tools/kernel.ld

    $(kernel): $(KOBJS)
        @echo + ld $@
        $(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)
        @$(OBJDUMP) -S $@ > $(call asmfile,kernel)
        @$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call symfile,kernel)

    $(call create_target,kernel)

一开始的```KINCLUDE```和```KSRCDIR```处的代码将kern目录的前缀定义为```kinclude```和```ksrcdir```

```KCFLAGS		+= $(addprefix -I,$(KINCLUDE))```表示将```kinclude```的目录前缀加上```-I```选项，提供交互模式

```$(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))```生成kern目录下的.o文件，这些.o文件生成时使用的具体命令的参数和方式都差不多，具体含义后面会提到。

```KOBJS	= $(call read_packet,kernel libs)```表示使用call函数链接```read_packet```和```kernel libs```给```KOBJS```

```kernel = $(call totarget,kernel)```代表表示调用call函数生成```kernel```，实际为文件```bin/kernel```

```$(kernel): tools/kernel.ld```表示生成kernel文件需要依赖tools以及kernel.ld链接配置文件

```$(kernel): $(KOBJS)```表示生成kernel时还需要依赖KOBJS

```@echo + ld $@```中的```echo```表示显示内容，```ld```代表链接，```$@```代表目标文件，语句代表将下面的文件和目标文件链接起来，同时打印kernel目标文件名

```$(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)```代表使用kernel.ld作为连接器脚本，链接的文件有obj/libs/和obj/kernel/下的所有的obj文件生成kernel文件，关键参数为```-T <scriptfile>```，代表让连接器使用指定的脚本，这里是kernel.ld

```@$(OBJDUMP) -S $@ > $(call asmfile,kernel)```代表使用objdump工具对kernel文件进行反汇编，便于调试，```-S```选项为交替显示C源码和汇编代码。

```@$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call symfile,kernel)```代表使用objdump工具通过解析kernel文件从而能得到符号表。

```$(call create_target,kernel)```生成kernel直接返回

输入```make "V="```，查看生成kernel文件的具体过程：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice1-04.png)

可以看到，生成kernel，首先要依赖

    kernel.ld init.o stdio.o readline.o panic.o kdebug.o kmonitor.o clock.o console.o picirq.o intr.o trap.o vectors.o trapentry.o pmm.o string.o printfmt.o

其中kernel.ld已经存在，而生成kernel时，makefile中带@的前缀的指令都不是必需的，编译选项中：

```ld```表示链接，```-m```表示模拟指定的连接器，```-nostdlib```表示不使用标准库，```-T```表示让连接器使用指定的脚本，```tools/kernel.ld```是指定连接器脚本，```-o```表示指定输出文件的名称。

依赖的.o文件生成时使用的具体命令的参数和方式都差不多，比如pmm.o，输入```make "V="```查看编译实际命令：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice1-06.png)

其中的关键参数选项：

```-I<dir>```如```-Ikern/mm/```、```-Ikern/debug/```等表示给搜索头文件添加路径

```-march=i686```表示指定CPU架构为i686

```-fno-builtin```表示除非使用__builtin_前缀，否则不优化builtin函数

```-fno-PIC```表示生成位置无关代码

```-Wall```表示开启所有警告

```-ggdb```表示生成gdb可以使用的调试信息，便于使用qemu和gdb来进行调试

```-m32```表示生成在32位环境下适用的代码，因为ucore是32位的软件

```-gstabs```表示生成stabs格式的调试信息，便于monitor显示函数调用栈信息

```-nostdinc```表示不使用标准库，因为OS内核是提供服务的，不依赖其它服务

```-fno-stack-protector```表示不生成检测缓冲区溢出部分的代码

**然后来看```bootblock```文件的生成**

找到makefile文件中注释为```create bootblock```这一部分的内容：

	# create bootblock
	bootfiles = $(call listf_cc,boot)
	$(foreach f,$(bootfiles),$(call cc_compile,$(f),$(CC),$(CFLAGS) -Os -nostdinc))

	bootblock = $(call totarget,bootblock)

	$(bootblock): $(call toobj,$(bootfiles)) | $(call totarget,sign)
		@echo + ld $@
		$(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 $^ -o $(call toobj,bootblock)
		@$(OBJDUMP) -S $(call objfile,bootblock) > $(call asmfile,bootblock)
		@$(OBJCOPY) -S -O binary $(call objfile,bootblock) $(call outfile,bootblock)
		@$(call totarget,sign) $(call outfile,bootblock) $(bootblock)

	$(call create_target,bootblock)


```bootfiles = $(call listf_cc,boot)```中使用call调用listf_cc函数过滤对应目录下的.c和.S文件，用boot替换listf_cc里面的变量，将listf_cc的返回值赋给bootfiles

```$(foreach f,$(bootfiles),$(call cc_compile,$(f),$(CC),$(CFLAGS) -Os -nostdinc))```编译bootfiles生成.o文件，其中```-Os```参数表示为减小代码大小而进行优化

上面两行代码用来生成bootasm.o，bootmain.o，实际的代码是由宏批量生成。

```bootblock = $(call totarget,bootblock)```表示bootblock实际为文件```bin/bootblock```

```$(bootblock): $(call toobj,$(bootfiles)) | $(call totarget,sign)```其中的```toobj```表示给输出参数加上前缀```obj/```，文件后缀名改为.o，语句表示bootblock依赖于obj/boot/*.o与bin/sign文件

```@echo + ld $@```代表将下面的文件和目标文件链接起来，同时打印kernel目标文件名

```$(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 $^ -o $(call toobj,bootblock)```表示链接所有.o文件生成obj/bootblock.o文件，其中```-N```代表设置代码段和数据段均可读写，```-e start```代表指定入口为start，```-Ttext 0x7C00```代表代码段开始位置为```0x7C00```

```@$(OBJDUMP) -S $(call objfile,bootblock) > $(call asmfile,bootblock)```表示使用objdump工具对obj/bootblock.o文件进行反汇编得到obj/bootblock.asm文件，便于调试，```-S```选项为交替显示C源码和汇编代码。

```@$(OBJCOPY) -S -O binary $(call objfile,bootblock) $(call outfile,bootblock)```表示使用objcopy工具将obj/bootblock.o拷贝到obj/bootblock.out文件，其中```-S```选项代表移除所有符号和重定位信息，```-O binary```选项代表指定输出格式为二进制

```@$(call totarget,sign) $(call outfile,bootblock) $(bootblock)```表示使用bin/sign工具将之前的obj/bootblock.out用来生成bin/bootblock目标文件

```$(call create_target,bootblock)```直接返回

输入```make "V="```，查看生成bootblock文件的具体过程：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice1-05.png)

其中之前没有提到过的关键参数有：

```-N```代表设置代码段和数据段均可读写，```-e <entry>```代表指定入口，这里是start，```-Ttext```代表代码段开始位置，这里是```0x7C00```

可以看到，生成bootblock，首先要依赖
	
	bootasm.o bootmain.o sign

**生成bootasm.o依赖bootasm.S，输入```make "V="```，查看生成bootasm.o文件的具体过程：**

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice1-07.png)

编译命令中关键的参数选项有：

```-I<dir>```如```-Iboot/```、```-Ilibs/```等表示给搜索头文件添加路径

```-fno-builtin```表示除非使用__builtin_前缀，否则不优化builtin函数

```-Wall```表示开启所有警告

```-ggdb```表示生成gdb可以使用的调试信息，便于使用qemu和gdb来进行调试

```-m32```表示生成在32位环境下适用的代码，因为ucore是32位的软件

```-gstabs```表示生成stabs格式的调试信息，便于monitor显示函数调用栈信息

```-nostdinc```表示不使用标准库，因为OS内核是提供服务的，不依赖其它服务

```-fno-stack-protector```表示不生成检测缓冲区溢出部分的代码

```-Os```参数表示为减小代码大小而进行优化，因为主引导扇区只有512字节，其中最后两位已被占用，最后写出的bootloader不能大于510字节。

**生成bootmain.o依赖bootmain.c，输入```make "V="```，查看生成bootmain.o文件的具体过程：**

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice1-08.png)

编译命令的过程和参数选项和上面生成bootasm.o差不多。

**找到makefile文件中注释为```create 'sign' tools```这一部分的内容，查看sign的生成过程：**

	# create 'sign' tools
	$(call add_files_host,tools/sign.c,sign,sign)
	$(call create_target_host,sign,sign)

输入```make "V="```，查看生成sign的具体过程：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice1-09.png)

其中和上面相比，之前没有出现过的关键选项参数有：

```-g```代表在编译的时候加入调试信息

```-O2```代表开启O2编译优化

#### 一个被系统认为是符合规范的硬盘主引导扇区的特征是什么？

在sign.c文件中，可以找到以下核心代码：

    char buf[512];
    memset(buf, 0, sizeof(buf));
    FILE *ifp = fopen(argv[1], "rb");
    int size = fread(buf, 1, st.st_size, ifp);
    if (size != st.st_size) {
        fprintf(stderr, "read '%s' error, size is %d.\n", argv[1], size);
        return -1;
    }
    fclose(ifp);
    buf[510] = 0x55;
    buf[511] = 0xAA;

可以看到，代码中```char buf[512]```，```buf[510] = 0x55```，```buf[511] = 0xAA```，说明一个被系统认为是符合规范的硬盘主引导扇区的特征是：

+ 一共512个字节
+ 倒数第二个字节是0x55，倒数第一个字节是0xAA

### lab1 练习 2：使用qemu执行并调试lab1中的软件。（要求在报告中简要写出练习过程）

为了熟悉使用qemu和gdb进行的调试工作，我们进行如下的小练习：
  1. 从CPU加电后执行的第一条指令开始，单步跟踪BIOS的执行。
  2. 在初始化位置0x7c00设置实地址断点,测试断点正常。
  3. 从0x7c00开始跟踪代码运行,将单步跟踪反汇编得到的代码与bootasm.S和 bootblock.asm进行比较。
  4. 自己找一个bootloader或内核中的代码位置，设置断点并进行测试。

#### 1. 从CPU加电后执行的第一条指令开始，单步跟踪BIOS的执行。

根据附录的内容，进行单步调试和查看BIOS的代码：

修改 lab1/tools/gdbinit,

    set architecture i8086 //将执行模式设置为i8086
    target remote :1234 //使用本地端口1234进行qmenu和gdb之间的通信

然后在lab1的目录下输入```make debug```，出现gdb调试界面之后，输入```si```单步跟踪BIOS的执行，通过语句```x /2i $pc```可以显示当前eip处的汇编指令，查看BIOS的代码。

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice2-01.jpg)

可以看到，一开始gdb在BIOS的第一条指令处```0xfff0```停止。

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice2-02.png)

输入si后，可以看到gdb跳转到下一地址处，即可单步跟踪BIOS了，输入```x /2i $pc```会显示当前eip处的汇编指令，输入```x /2i 0xffff0```即可查看```0xffff0```处及往下的一行代码。

#### 2. 在初始化位置0x7c00设置实地址断点,测试断点正常。

在lab1/tools/gdbinit文件中加入```b *0x7c00```或在gdb输入框输入```b *0x7c00```，就可以在```0x7c00```设置断点。

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice2-03.jpg)

可以看到，输入c使程序继续运行后，程序在```0x7c00```处停下，断点正常。

#### 3. 从0x7c00开始跟踪代码运行,将单步跟踪反汇编得到的代码与bootasm.S和 bootblock.asm进行比较。

通过改写Makefile文件，将这部分代码：

	debug: $(UCOREIMG)
		$(V)$(QEMU) -S -s -parallel stdio -hda $< -serial null &
		$(V)sleep 2
		$(V)$(TERMINAL) -e "gdb -q -tui -x tools/gdbinit"

改为：

	debug: $(UCOREIMG)
		$(V)$(TERMINAL) -e "$(QEMU) -S -s -d in_asm -D $(BINDIR)/qemu.log -parallel stdio -hda $< -serial null"
		$(V)sleep 2
		$(V)$(TERMINAL) -e "gdb -q -tui -x tools/gdbinit"

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice2-04.png)

在调用qemu的时候加上了```-d in_asm -D qemu.log```等参数，就可以在```qemu.log```里看到汇编指令（从0x00007c00处开始10行代码）：

	----------------
	IN: 
	0x00007c00:  fa                       cli      

	----------------
	IN: 
	0x00007c01:  fc                       cld      
	0x00007c02:  31 c0                    xorw     %ax, %ax
	0x00007c04:  8e d8                    movw     %ax, %ds
	0x00007c06:  8e c0                    movw     %ax, %es
	0x00007c08:  8e d0                    movw     %ax, %ss

	----------------
	IN: 
	0x00007c0a:  e4 64                    inb      $0x64, %al

	----------------
	IN: 
	0x00007c0c:  a8 02                    testb    $2, %al
	0x00007c0e:  75 fa                    jne      0x7c0a

	----------------
	IN: 
	0x00007c10:  b0 d1                    movb     $0xd1, %al

在```bootasm.S```中：

	.globl start
	start:
	.code16                                             # Assemble for 16-bit mode
		cli                                             # Disable interrupts
		cld                                             # String operations increment

		# Set up the important data segment registers (DS, ES, SS).
		xorw %ax, %ax                                   # Segment number zero
		movw %ax, %ds                                   # -> Data Segment
		movw %ax, %es                                   # -> Extra Segment
		movw %ax, %ss                                   # -> Stack Segment

		# Enable A20:
		#  For backwards compatibility with the earliest PCs, physical
		#  address line 20 is tied low, so that addresses higher than
		#  1MB wrap around to zero by default. This code undoes this.
	seta20.1:
		inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
		testb $0x2, %al
		jnz seta20.1

		movb $0xd1, %al                                 # 0xd1 -> port 0x64

在```bootblock.asm```中：

	.globl start
	start:
	.code16                                             # Assemble for 16-bit mode
		cli                                             # Disable interrupts
		7c00:	fa                   	cli    
		cld                                             # String operations increment
		7c01:	fc                   	cld    

		# Set up the important data segment registers (DS, ES, SS).
		xorw %ax, %ax                                   # Segment number zero
		7c02:	31 c0                	xor    %eax,%eax
		movw %ax, %ds                                   # -> Data Segment
		7c04:	8e d8                	mov    %eax,%ds
		movw %ax, %es                                   # -> Extra Segment
		7c06:	8e c0                	mov    %eax,%es
		movw %ax, %ss                                   # -> Stack Segment
		7c08:	8e d0                	mov    %eax,%ss

	00007c0a <seta20.1>:
		# Enable A20:
		#  For backwards compatibility with the earliest PCs, physical
		#  address line 20 is tied low, so that addresses higher than
		#  1MB wrap around to zero by default. This code undoes this.
	seta20.1:
		inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
		7c0a:	e4 64                	in     $0x64,%al
		testb $0x2, %al
		7c0c:	a8 02                	test   $0x2,%al
		jnz seta20.1
		7c0e:	75 fa                	jne    7c0a <seta20.1>

		movb $0xd1, %al                                 # 0xd1 -> port 0x64
		7c10:	b0 d1                	mov    $0xd1,%al

可以看到，反汇编得到的代码与bootasm.S和bootblock.asm基本相同。

#### 4. 自己找一个bootloader或内核中的代码位置，设置断点并进行测试。

在```0x7c08```处设置断点，进行测试。

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice2-05.png)

可以看到，输入```b *0x7c08```在```0x7c08```设置断点后，再输入c使程序继续运行后，程序在```0x7c08```处停下，断点正常。

### lab1 练习 3：分析bootloader 进入保护模式的过程。

BIOS将通过读取硬盘主引导扇区到内存，并转跳到对应内存中的位置执行bootloader。请分析bootloader是如何完成从实模式进入保护模式的。

提示：需要阅读小节“保护模式和分段机制”和lab1/boot/bootasm.S源码，了解如何从实模式切换到保护模式，需要了解：

  + 为何开启A20，以及如何开启A20
  + 如何初始化GDT表
  + 如何使能和进入保护模式

在```lab1/boot/bootasm.S```文件中，可以看到文件开头有一段注释：

	# The BIOS loads this code from the first sector of the hard disk into
	# memory at physical address 0x7c00 and starts executing in real mode
	# with %cs=0 %ip=7c00.

大概意思是，BIOS将此代码从硬盘的第一个扇区加载到物理地址为```0x7c00```的内存中，并开始以实模式在```cs=0 ip=7c00```执行。

程序一开始先设置内核代码段选择子、内核数据段选择子、保护模式使能标志置为1

	.set PROT_MODE_CSEG,        0x8                     # 内核代码段选择子
	.set PROT_MODE_DSEG,        0x10                    # 内核数据段选择子
	.set CR0_PE_ON,             0x1                     # 保护模式使能标志

然后清理环境，关闭中断将flag置0并设置字符串操作是递增方向，将寄存器ax、ds、es、ss置0：

	.globl start
	start:
	.code16                                             # Assemble for 16-bit mode
		cli                                             # Disable interrupts
		cld                                             # String operations increment

		# Set up the important data segment registers (DS, ES, SS).
		xorw %ax, %ax                                   # Segment number zero
		movw %ax, %ds                                   # -> Data Segment
		movw %ax, %es                                   # -> Extra Segment
		movw %ax, %ss                                   # -> Stack Segment

然后启用A20，将A20地址线置1，根据附录“关于A20 Gate”，因为一开始时A20地址线控制是被屏蔽的（总为0），直到系统软件通过一定的IO操作去打开它。很显然，在实模式下要访问高端内存区，这个开关必须打开，在保护模式下，由于使用32位地址线，如果A20恒等于0，那么系统只能访问奇数兆的内存，即只能访问0–1M、2-3M、4-5M…，这样无法有效访问所有可用内存。所以在保护模式下，为了使能所有地址位的寻址能力，这个开关也必须打开。

为了与最早的PC机向后兼容，物理地址行20被限制在低位，因此高于1MB的地址默认为零。此代码将撤消此操作，通过打开A20，将键盘控制器上的A20线置于高电位，就能使全部32条地址线可用，可以访问4G的内存空间。

因为A20的地址位是由芯片8042管理，这个芯片与键盘控制器有关，通过给8042芯片发命令来激活A20的地址位，8042的两个I/O端口是0x64和0x60，通过发送0xdi命令到0x64端口、发送0xdf到0x60端口就可以激活

打开A20的具体步骤大致如下：

  1. 等待8042 Input buffer为空；
  2. 发送Write 8042 Output Port （P2）命令到8042 Input buffer；
  3. 等待8042 Input buffer为空；
  4. 将8042 Output Port（P2）得到字节的第2位置1，然后写入8042 Input buffer；

下面的代码分为两部分，两部分代码都要通过读0x64端口的第2位确保8042的输入缓冲区为空后再进行操作。

在seta20.1中，首先把数据0xd1写入端口0x64，发送消息给CPU准备往8042芯片的P2端口写数据；

在seta20.2中，首先把数据0xdf写入端口0x60，从而将8042芯片的P2端口的A20地址线设置为1。

	seta20.1:
		inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
		testb $0x2, %al
		jnz seta20.1

		movb $0xd1, %al                                 # 0xd1 -> port 0x64
		outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port

	seta20.2:
		inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
		testb $0x2, %al
		jnz seta20.2

		movb $0xdf, %al                                 # 0xdf -> port 0x60
		outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1

在kern/mm/pmm.c文件中可以找到gdt的初始化函数，通过这段代码完成gdt的初始化：

	static void
	gdt_init(void) {
		ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
		ts.ts_ss0 = KERNEL_DS;

		gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
		gdt[SEG_TSS].sd_s = 0;

		lgdt(&gdt_pd);
		
		ltr(GD_TSS);
	}

而在bootasm.S文件中，可以看到：

	# Bootstrap GDT
	.p2align 2                                          # force 4 byte alignment
	gdt:
		SEG_NULLASM                                     # null seg
		SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)           # code seg for bootloader and kernel
		SEG_ASM(STA_W, 0x0, 0xffffffff)                 # data seg for bootloader and kernel

	gdtdesc:
		.word 0x17                                      # sizeof(gdt) - 1
		.long gdt                                       # address gdt

其中```SEG_ASM```可以在```asm.h```文件中找到：

	#define SEG_ASM(type,base,lim)                                  \
		.word (((lim) >> 12) & 0xffff), ((base) & 0xffff);          \
		.byte (((base) >> 16) & 0xff), (0x90 | (type)),             \
			(0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)

可以看到，```SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)```和```SEG_ASM(STA_W, 0x0, 0xffffffff)```把数据段和代码段的```base```设为0，```lim```即```limit```设置为4G，数据段可读可执行，代码段可写，这样就可以是逻辑地址对应于线性地址。

因为一个简单的GDT表和其描述符已经静态储存在引导区中，所以直接使用lgdt命令初始化后，将gdt的desc段表示内容加载到gdt就行。

	lgdt gdtdesc

将cr0寄存器的PE位置即最低位设置为1，就可以开启保护模式：

	movl %cr0, %eax
	orl $CR0_PE_ON, %eax
	movl %eax, %cr0

接着，通过长跳转使cs的基地址得到更新，将cs修改为32位段寄存器，此时CPU进入32位模式

	ljmp $PROT_MODE_CSEG, $protcseg
	.code32
	protcseg:

设置段寄存器ds、es、fs、gs、ss，并建立堆栈的帧指针和栈指针

	movw $PROT_MODE_DSEG, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %gs
	movw %ax, %ss
	movl $0x0, %ebp
	movl $start, %esp

调用bootmain函数，bootloader从实模式进入保护模式

	call bootmain

### lab1 练习 4：分析bootloader加载ELF格式的OS的过程。

通过阅读bootmain.c，了解bootloader如何加载ELF文件。通过分析源代码和通过qemu来运行并调试bootloader&OS，

   + bootloader如何读取硬盘扇区的？
   + bootloader是如何加载ELF格式的OS？

提示：可阅读“硬盘访问概述”，“ELF执行文件格式概述”这两小节。

在阅读材料“硬盘访问概述中”，表明了磁盘IO地址和对应功能：

| IO地址 |	功能 |
| ------ | ----- |
| 0x1f0 |	读数据，当0x1f7不为忙状态时，可以读。 |
| 0x1f2 |	要读写的扇区数，每次读写前，你需要表明你要读写几个扇区。最小是1个扇区 |
| 0x1f3 |	如果是LBA模式，就是LBA参数的0-7位 |
| 0x1f4 |	如果是LBA模式，就是LBA参数的8-15位 |
| 0x1f5 |	如果是LBA模式，就是LBA参数的16-23位 |
| 0x1f6 |	第0~3位：如果是LBA模式就是24-27位 第4位：为0主盘；为1从盘 |
| 0x1f7 |	状态和命令寄存器。操作时先给命令，再读取，如果不是忙状态就从0x1f0端口读数据 |

读取一个硬盘扇区的流程大致如下：

  1. 等待磁盘准备好
  2. 发出读取扇区的命令
  3. 等待磁盘准备好
  4. 把磁盘扇区数据读到指定内存

在阅读材料“ELF执行文件格式概述”中，表明了bootloader是如何加载ELF格式的OS：

ELF header在文件开始处描述了整个文件的组织。ELF的文件头包含整个执行文件的控制结构，其定义在elf.h中：

	struct elfhdr {
		uint magic;  // must equal ELF_MAGIC
		uchar elf[12];
		ushort type;
		ushort machine;
		uint version;
		uint entry;  // 程序入口的虚拟地址
		uint phoff;  // program header 表的位置偏移
		uint shoff;
		uint flags;
		ushort ehsize;
		ushort phentsize;
		ushort phnum; //program header表中的入口数目
		ushort shentsize;
		ushort shnum;
		ushort shstrndx;
	};

program header描述与程序执行直接相关的目标文件结构信息，用来在文件中定位各个段的映像，同时包含其他一些用来为程序创建进程映像所必需的信息。可执行文件的程序头部是一个program header结构的数组， 每个结构描述了一个段或者系统准备程序执行所必需的其它信息。目标文件的 “段” 包含一个或者多个 “节区”（section） ，也就是“段内容（Segment Contents）” 。程序头部仅对于可执行文件和共享目标文件有意义。可执行目标文件在ELF头部的e_phentsize和e_phnum成员中给出其自身程序头部的大小。程序头部的数据结构如下表所示：

	struct proghdr {
		uint type;   // 段类型
		uint offset;  // 段相对文件头的偏移值
		uint va;     // 段的第一个字节将被放到内存中的虚拟地址
		uint pa;
		uint filesz;
		uint memsz;  // 段在内存映像中占用的字节数
		uint flags;
		uint align;
	};

根据elfhdr和proghdr的结构描述，bootloader就可以完成对ELF格式的ucore操作系统的加载过程（参见boot/bootmain.c中的bootmain函数）。

在```bootmain.c```文件中，首先：

宏定义：

	#define SECTSIZE        512		//表示一个扇区的大小
	#define ELFHDR          ((struct elfhdr *)0x10000)      // 表示虚拟地址的起始地址

接着是：

	static void
	waitdisk(void) {
		while ((inb(0x1F7) & 0xC0) != 0x40)
			/* do nothing */;
	}

```waitdisk()```函数用来等待硬盘准备好，不断查询0x1F7寄存器的最高两位，当最高两位为01，即磁盘空闲时，才返回。

然后在文件中找到readsect函数：

	static void
	readsect(void *dst, uint32_t secno) {
		// wait for disk to be ready
	    waitdisk();
	
	    outb(0x1F2, 1);		//读取一个扇区
	    outb(0x1F3, secno & 0xFF);	//制定扇区号的0-7位
	    outb(0x1F4, (secno >> 8) & 0xFF); //制定扇区号的8-15位
	    outb(0x1F5, (secno >> 16) & 0xFF); //制定扇区号的16-23位
	    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0); //制定扇区号的24-31位
	    // 31-29位都是1，28位为0，表示访问"Disk 0",27-0位是偏移量
	    outb(0x1F7, 0x20);		// 使用0x20命令，读取扇区
	
		// wait for disk to be ready
	    waitdisk();

	    insl(0x1F0, dst, SECTSIZE / 4);// 将扇区的数据读取到dst位置
	}

可以看到，```readsect```函数的作用是从设备的第secno个扇区的文章读取数据到dst内存中。

然后找到```readseg```函数：

	// 参数va表示虚拟地址的起始地址，参数count表示读取数据的总大小，参数offset表示偏移量
	static void
	readseg(uintptr_t va, uint32_t count, uint32_t offset) {
	    uintptr_t end_va = va + count;	//计算读取数据的结束地址
	
	    va -= offset % SECTSIZE;  	//用起始地址减去偏移地址，得到块的首地址
	
	    uint32_t secno = (offset / SECTSIZE) + 1; 
	    //0扇区已经被占用，所以ELF文件从1扇区开始
	
		//将end_va和va地址之间的数据读取到内存中
	    for (; va < end_va; va += SECTSIZE, secno ++) {
	        readsect((void *)va, secno);
	    }
	}

可以看到，```readseg```函数使用了```readsect```函数，用来从设备中读入任意长度的内容。

接着，找到```bootmain```函数：

    void
	bootmain(void) {
	    // 首先从磁盘的第一个扇区中将ELF文件bin/kernel的内容读取出来
	    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);
	
	    // 检验ELF头部的e_magic变量判断是不是ELF文件
	    if (ELFHDR->e_magic != ELF_MAGIC) {
	        goto bad;
	    }
	
	    struct proghdr *ph, *eph;
	
		// 读取ELF头部的e_phoff变量得到描述表的头地址。表示ELF文件应该加载到内存的什么位置
	    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
		// 读取ELF头部的e_phnum变量，得到描述表的元素数目。
	    eph = ph + ELFHDR->e_phnum;
	
	    // 按照描述表将ELF文件中数据按照偏移、虚拟地址、长度等信息载入内存
	    for (; ph < eph; ph ++) {
	        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
	    }

	    // 通过ELF头部的e_entry变量储存的入口信息，找到内核的入口地址，并开始执行内核代码
	    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();
	
	bad:
	    outw(0x8A00, 0x8A00);
	    outw(0x8A00, 0x8E00);
	    while (1);
	}

bootloader加载ELF格式的OS的大致过程是先等待磁盘准备就绪，然后先读取ELF的头部判断是否合法，接着读取ELF内存位置的描述表，然后按照描述表的内容，将ELF文件中的数据载入内存，根据ELF头部的入口信息找到内核入口执行内核代码。

## (3) 尝试实现 uCore Lab 1 练习 5-6 的编程作业；

### lab1 练习 5：实现函数调用堆栈跟踪函数

首先需要根据阅读材料“函数堆栈”，了解函数堆栈的概念：

栈是一个很重要的编程概念（编译课和程序设计课都讲过相关内容），与编译器和编程语言有紧密的联系。理解调用栈最重要的两点是：栈的结构，EBP寄存器的作用。一个函数调用动作可分解为：零到多个PUSH指令（用于参数入栈），一个CALL指令。CALL指令内部其实还暗含了一个将返回地址（即CALL指令下一条指令的地址）压栈的动作（由硬件完成）。几乎所有本地编译器都会在每个函数体之前插入类似如下的汇编指令：

	pushl   %ebp
	movl   %esp , %ebp

这样在程序执行到一个函数的实际指令前，已经有以下数据顺序入栈：参数、返回地址、ebp寄存器。由此得到类似如下的栈结构（参数入栈顺序跟调用方式有关，这里以C语言默认的CDECL为例）：

	+|  栈底方向        | 高位地址
	|    ...        |
	|    ...        |
	|  参数3        |
	|  参数2        |
	|  参数1        |
	|  返回地址        |
	|  上一层[ebp]    | <-------- [ebp]
	|  局部变量        |  低位地址

这两条汇编指令的含义是：首先将ebp寄存器入栈，然后将栈顶指针esp赋值给ebp。“mov ebp esp”这条指令表面上看是用esp覆盖ebp原来的值，其实不然。因为给ebp赋值之前，原ebp值已经被压栈（位于栈顶），而新的ebp又恰恰指向栈顶。此时ebp寄存器就已经处于一个非常重要的地位，该寄存器中存储着栈中的一个地址（原ebp入栈后的栈顶），从该地址为基准，向上（栈底方向）能获取返回地址、参数值，向下（栈顶方向）能获取函数局部变量值，而该地址处又存储着上一层函数调用时的ebp值。

一般而言，ss:[ebp+4]处为返回地址，ss:[ebp+8]处为第一个参数值（最后一个入栈的参数值，此处假设其占用4字节内存），ss:[ebp-4]处为第一个局部变量，ss:[ebp]处为上一层ebp值。由于ebp中的地址处总是“上一层函数调用时的ebp值”，而在每一层函数调用中，都能通过当时的ebp值“向上（栈底方向）”能获取返回地址、参数值，“向下（栈顶方向）”能获取函数局部变量值。如此形成递归，直至到达栈底。这就是函数调用栈。

我们需要在lab1中完成kdebug.c中函数print_stackframe的实现，可以通过函数print_stackframe来跟踪函数调用堆栈中记录的返回地址。在如果能够正确实现此函数，可在lab1中执行 “make qemu”后，在qemu模拟器中得到类似如下的输出：

	ebp:0x00007b28 eip:0x00100992 args:0x00010094 0x00010094 0x00007b58 0x00100096
		kern/debug/kdebug.c:305: print_stackframe+22
	ebp:0x00007b38 eip:0x00100c79 args:0x00000000 0x00000000 0x00000000 0x00007ba8
		kern/debug/kmonitor.c:125: mon_backtrace+10
	ebp:0x00007b58 eip:0x00100096 args:0x00000000 0x00007b80 0xffff0000 0x00007b84
		kern/init/init.c:48: grade_backtrace2+33
	ebp:0x00007b78 eip:0x001000bf args:0x00000000 0xffff0000 0x00007ba4 0x00000029
		kern/init/init.c:53: grade_backtrace1+38
	ebp:0x00007b98 eip:0x001000dd args:0x00000000 0x00100000 0xffff0000 0x0000001d
		kern/init/init.c:58: grade_backtrace0+23
	ebp:0x00007bb8 eip:0x00100102 args:0x0010353c 0x00103520 0x00001308 0x00000000
		kern/init/init.c:63: grade_backtrace+34
	ebp:0x00007be8 eip:0x00100059 args:0x00000000 0x00000000 0x00000000 0x00007c53
		kern/init/init.c:28: kern_init+88
	ebp:0x00007bf8 eip:0x00007d73 args:0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8
	<unknow>: -- 0x00007d72 –

按照函数print_stackframe中所给的详细的注释，一步一步进行编写函数print_stackframe，首先使用```read_ebp()```和```read_eip()```获取32位的寄存器ebp和eip中的值并分别赋给32位变量```ebp_val```和```eip_val```。

然后进入一个for循环，从0到STACKFRAME_DEPTH，即遍历栈，打印每个栈帧的信息，每次循环，使用变量```call_args```指向存放参数的ss:[ebp+8]的位置，然后依次打印调用函数的四个参数，输出换行符后，打印eip和ebp相关的信息，最后eip指向返回地址，ebp指向原ebp的地址。

	void
	print_stackframe(void) {
		/* LAB1 YOUR CODE : STEP 1 */
		/* (1) call read_ebp() to get the value of ebp. the type is (uint32_t);*/
		uint32_t ebp_val = read_ebp();
		/* (2) call read_eip() to get the value of eip. the type is (uint32_t);*/
		uint32_t eip_val = read_eip();
		/* (3) from 0 .. STACKFRAME_DEPTH*/
		for (int i = 0; ebp_val != 0 && i < STACKFRAME_DEPTH; ++i) {
			/* (3.1) printf value of ebp, eip*/
			cprintf("ebp:0x%08x eip:0x%08x args:", ebp_val, eip_val);
			/* (3.2) (uint32_t)calling arguments [0..4] = the contents in address (uint32_t)ebp +2 [0..4]*/
			uint32_t *call_args = (uint32_t *)ebp_val + 2;
			cprintf("0x%08x 0x%08x 0x%08x 0x%08x", call_args[0], call_args[1], call_args[2], call_args[3]);
			/* (3.3) cprintf("\n");*/
			cprintf("\n");
			/* (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.*/
			print_debuginfo(eip_val - 1);
			/* (3.5) popup a calling stackframe*/
			/* NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]*/
			eip_val = *((uint32_t *)(ebp_val + 4));
			/* the calling funciton's ebp = ss:[ebp]*/
			ebp_val = *((uint32_t *)ebp_val);
		}
	}

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice5-01.png)

可以看到，输出与上述显示大致一致，最后一行是：

```ebp:0x00007bf8 eip:0x00007d74 args:0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8 <unknow>: -- 0x00007d72 –```

其中```ebp:0x00007bf8```中ebp的值```0x00007bf8```代表kern_init函数的栈顶地址；

```eip:0x00007d74```中eip的值```eip:0x00007d74```代表kern_init函数的返回地址，即bootmain函数调用kern_init函数之后对应的下一条指令的地址；

```args:0xc031fcfa 0xc08ed88e 0x64e4d08e 0xfa7502a8```代表的是bootloader指令的前16个字节。

```<unknow>: -- 0x00007d72 –```代表的是bootmain函数内调用OS kernel入口函数的该指令的地址

最后一行代表的是堆栈最深的一层，对应的是第一个使用堆栈的函数，堆栈从0x7c00开始，然后使用了bootmain函数，指令压栈，所以bootmaind中寄存器ebp的值为```0x7bf8```

### lab1 练习 6：完善中断初始化和处理

请完成编码工作和回答如下问题：

   1. 中断描述符表（也可简称为保护模式下的中断向量表）中一个表项占多少字节？其中哪几位代表中断处理代码的入口？

   2. 请编程完善kern/trap/trap.c中对中断向量表进行初始化的函数idt_init。在idt_init函数中，依次对所有中断入口进行初始化。使用mmu.h中的SETGATE宏，填充idt数组内容。每个中断的入口由tools/vectors.c生成，使用trap.c中声明的vectors数组即可。

   3. 请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写trap函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”。

	【注意】除了系统调用中断(T_SYSCALL)使用陷阱门描述符且权限为用户态权限以外，其它中断均使用
	特权级(DPL)为０的中断门描述符，权限为内核态权限；而ucore的应用程序处于特权级３，需要采用｀
	int 0x80`指令操作（这种方式称为软中断，软件中断，Tra中断，在lab5会碰到）来发出系统调用请求，
	并要能实现从特权级３到特权级０的转换，所以系统调用中断(T_SYSCALL)所对应的中断门描述符中的
	特权级（DPL）需要设置为３。

要求完成问题2和问题3提出的相关函数实现，提交改进后的源代码包（可以编译执行），并在实验报告中简要说明实现过程，并写出对问题1的回答。完成这问题2和3要求的部分代码后，运行整个系统，可以看到大约每1秒会输出一次“100 ticks”，而按下的键也会在屏幕上显示。

提示：可阅读小节“中断与异常”。

#### 1. 中断向量表中一个表项占多少字节？其中哪几位代表中断处理代码的入口？

答：在中断向量表中，一个表项会占8个字节，其中第0-1和第6-7字节组合在一起表示偏移量，第2~3字节表示段选择的编号，在选择的段中，计算偏移量后得到的位置，就是中断处理代码的入口。

![](https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1_figs/image008.png)

#### 2. 请编程完善kern/trap/trap.c中对中断向量表进行初始化的函数idt_init。

根据注释完成代码，首先根据（1）注释中的```You can use "extern uintptr_t __vectors[];" to define this extern variable which will be used later. ```定义一个```extern uintptr_t```类型变量```__vectors[]```，用来存放256个在vectors.S定义的中断处理例程的入口地址

然后根据（2）注释，使用SETGATE宏，通过循环语句对中断描述符表中的每一个表项进行设置，其中SETGATE宏可以在```mmu.h```中找到：

	#define SETGATE(gate, istrap, sel, off, dpl)

宏的参数```gate```代表选择的idt数组的项，是处理函数的入口地址

参数```istrap```为1时代表系统段，为0时代表中断门

参数```sel```是中断处理函数的段选择子，```GD_KTEXT```代表是.text段

参数```off```是__vectors数组内容，在vector.S中，有256个中断处理例程

参数```dpl```是优先级，宏定义```DPL_KERNEL```是0代表内核级，宏定义```DPL_USER```是3代表用户级。

宏定义```T_SWITCH_TOK```是用于用户态切换到内核态的中断号。

接着根据（3）注释，使用lidt函数加载中断描述符表。

代码如下：

	void
	idt_init(void) {
		/* LAB1 YOUR CODE : STEP 2 */
		/* (1) Where are the entry addrs of each Interrupt Service Routine (ISR)?
			All ISR's entry addrs are stored in __vectors. where is uintptr_t __vectors[] ?
			__vectors[] is in kern/trap/vector.S which is produced by tools/vector.c
			(try "make" command in lab1, then you will find vector.S in kern/trap DIR)
			You can use  "extern uintptr_t __vectors[];" to define this extern variable which will be used later. */
		extern uintptr_t __vectors[];
		/* (2) Now you should setup the entries of ISR in Interrupt Description Table (IDT).
			Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT */
		int idt_size = sizeof(idt) / sizeof(struct gatedesc);
		for (int i = 0; i < idt_size; ++i) {
			SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
		}
		SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
		/* (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
			You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
			Notice: the argument of lidt is idt_pd. try to find it! */
		lidt(&idt_pd);
	}

#### 3. 请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写trap函数

根据注释完成代码，首先（1）注释要求让用于记录时钟中断次数的位于```kern/driver/clock.c```的全局变量```ticks```加一，代码语句```ticks++```

然后（2）注释让每个TICK_NUM的循环完成后，都调用一次```print_ticks()```函数打印“100 ticks”，然后将ticks置为0，以便下一次时重新进行TICK_NUM循环。

程序实现功能是操作系统在每遇到100次时钟中断后，就使用一次```print_ticks()```打印一次“100 ticks”。

代码如下：

	case IRQ_OFFSET + IRQ_TIMER:
        /* LAB1 YOUR CODE : STEP 3 */
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c */
        ticks++;
        /* (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks(). */
        if (ticks % TICK_NUM == 0) {
            print_ticks();
            ticks = 0;
        }
        /* (3) Too Simple? Yes, I think so! */
        break;

问题（2）和问题（3）都完成后，执行程序截图：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice6-01.png)

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice6-02.png)

可以看到，大概每1秒输出一次“100 ticks”文字，而且按下的键也会在屏幕上显示。

## (4) 思考如何实现 uCore Lab 1 扩展练习 1-2。

### 扩展练习 Challenge 1

扩展proj4,增加syscall功能，即增加一用户态函数（可执行一特定系统调用：获得时钟计数值），当内核初始完毕后，可从内核态返回到用户态的函数，而用户态的函数又通过系统调用得到内核态的服务。

提示： 规范一下 challenge 的流程。

kern_init 调用 switch_test，该函数如下：

    static void
    switch_test(void) {
        print_cur_status();          // print 当前 cs/ss/ds 等寄存器状态
        cprintf("+++ switch to  user  mode +++\n");
        switch_to_user();            // switch to user mode
        print_cur_status();
        cprintf("+++ switch to kernel mode +++\n");
        switch_to_kernel();         // switch to kernel mode
        print_cur_status();
    }

switchto* 函数建议通过 中断处理的方式实现。主要要完成的代码是在 trap 里面处理 T_SWITCH_TO* 中断，并设置好返回的状态。

在 lab1 里面完成代码以后，执行 make grade 应该能够评测结果是否正确。

首先，要在```init.c```文件的```kern_init()```函数里面，将原先被注释掉的代码```lab1_switch_test()```去掉注释，变成可以执行的语句。

然后看到下面的```static void lab1_switch_to_user(void)```和```static void lab1_switch_to_kernel(void)```需要实现，对于```static void lab1_switch_to_user(void)```，这个函数的功能是从内核态返回到用户态，需要调用```T_SWITCH_TOU```中断，在函数中使用内联汇编实现：

    asm volatile (
	    "pushl %%ss \n"
        "pushl %%esp \n"
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);

在调用中断之前首先需要使用语句```"pushl %%ss \n""```和```pushl %%esp \n"```提前将ss、esp压入栈，因为当切换优先级时，中断返回时iret指令会额外弹出ss和esp两位，但使用```"int %0 \n"```语句调用```T_SWITCH_TOU```中断时并不会产生特权级的切换，因此不用压入ss和esp，所以要先将栈压两位，预先留出空间，在中断返回后使用```"movl %%ebp, %%esp" : : "i"(T_SWITCH_TOU)```语句恢复栈指针，修复esp。

而在函数```static void lab1_switch_to_user(void)```中，实现的功能是从内核态切换回用户态，需要调用```T_SWITCH_TOU```中断，在函数中使用内联汇编实现：

	asm volatile (
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);

从用户态切换到内核态时，由于用户态使用```"int %0 \n"```语句调用```T_SWITCH_TOU```中断时会自动切换到内核态，不会另外弹出ss、esp两位，中断返回时，esp仍在堆栈中，在中断返回后要使用	```"movl %%ebp, %%esp \n" : : "i"(T_SWITCH_TOK)```语句恢复栈指针，修复esp。

然后在```trap.c```文件中，找到```trap_dispatch()```函数中等待完成的```case T_SWITCH_TOU```和```case T_SWITCH_TOK```，先定义一个```struct trapframe```类型的变量```switchktou```和一个```struct trapframe *```类型的指针变量```switchutok```。

对于```case T_SWITCH_TOU```情况，要实现的是内核态转换到用户态时寄存器的修改，代码如下：

    case T_SWITCH_TOU:
        // 如果原先保存在trapframe中的cs不是代表用户态的USER_CS
        if (tf->tf_cs != USER_CS) {
            // 将保存在trapframe中的cs改成代表用户态的USER_CS
            tf->tf_cs = USER_CS;
            // 将其它的段选择子都修改为代表用户态的USER_DS，保证中断返回之后可以正常访问数据
            tf->tf_ds = USER_DS;
            tf->tf_es = USER_DS;
            tf->tf_ss = USER_DS;
            // 为了程序在CPL较低的情况下也能使用IO，需要将对应的IOPL位置改成用户态
            tf->tf_eflags |= FL_IOPL_MASK;
        }
        break;

指令iret认定发生中断的时候是否发生了PL的切换，是通过判断CPL和跳转回的地址的cs对应的段描述符的CPL是否相等来确定的，所以将保存在trapframe中的cs改成代表用户态的USER_CS，将其它的段选择子都修改为代表用户态的USER_DS，保证中断返回之后可以正常访问数据，中断返回才能正常。

对于```case T_SWITCH_TOK```情况，要实现的是内核态转换到用户态时寄存器的修改，代码如下：

    case T_SWITCH_TOK:
        // 如果原先保存在trapframe中的cs不是代表内核态的KERNEL_CS
        if (tf->tf_cs != KERNEL_CS) {
            // 将保存在trapframe中的cs改成代表内核态的KERNEL_CS
            tf->tf_cs = KERNEL_CS;
            // 将其它的段选择子都修改为代表内核态的KERNEL_DS，保证中断返回之后可以正常访问数据
            tf->tf_ds = KERNEL_DS;
            tf->tf_es = KERNEL_DS;
            // 将调用IO所需权限降低，才能输出文本
            tf->tf_eflags |= 0x3000;
        }
        break;

为了能够执行```T_SWITCH_TOK```的软中断，将trapframe中保存的cs修改为代表内核态的段选择子KERNEL_CS，并且将其它的段选择子都修改为代表内核态KERNEL_DS，然后进行正常的中断返回，为了输出文本，还需要将调用IO所需权限降低。

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork1-pictures/practice7-01.png)

### 扩展练习 Challenge 2

用键盘实现用户模式内核模式切换。具体目标是：“键盘输入3时切换到用户模式，键盘输入0时切换到内核模式”。 基本思路是借鉴软中断(syscall功能)的代码，并且把trap.c中软中断处理的设置语句拿过来。

注意：

1. 关于调试工具，不建议用lab1_print_cur_status()来显示，要注意到寄存器的值要在中断完成后tranentry.S里面iret结束的时候才写回，所以在trap.c里面不好观察，建议用print_trapframe(tf)

2. 关于内联汇编，最开始调试的时候，参数容易出现错误，可能的错误代码如下

	asm volatile ( "sub $0x8, %%esp \n"
		"int %0 \n"
		"movl %%ebp, %%esp"
		: )

要去掉参数int %0 \n这一行

3. 软中断是利用了临时栈来处理的，所以有压栈和出栈的汇编语句。硬件中断本身就在内核态了，直接处理就可以了。

首先在```trap.c```文件中找到与键盘中断返回有关的代码，即```case IRQ_OFFSET + IRQ_KBD```，在其中加入一个感知键盘输入数组的条件判断语句，如果输入是3则进入用户模式，如果输入是0则进入内核模式。因为在内核态进入到用户态的过程中，iret指令中断返回时会额外弹出两位，所以为了保护堆栈上的信息，可以将trapframe的地址保存到一个变量中，当键盘输入3准备从内核模式切换到用户模式时，可以可以从这个变量中获取正确的trapframe的地址，恢复栈指针，修复esp。

而因为用户态进入到内核态的过程中，因为iret指令调用中断时是系统默认的从权限较低的模式转换到权限较高的模式，所以中断时会自动切换到内核态，堆栈不会再弹出另外的两位，所以当键盘输入0准备从用户模式切换到内核模式，实现中断返回时，原来的esp还在堆栈中，所以需要把ebp的值传送给esp，恢复栈指针，修复esp。