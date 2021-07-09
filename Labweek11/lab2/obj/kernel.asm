
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 a0 11 00       	mov    $0x11a000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 a0 11 c0       	mov    %eax,0xc011a000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 90 11 c0       	mov    $0xc0119000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	f3 0f 1e fb          	endbr32 
c010003a:	55                   	push   %ebp
c010003b:	89 e5                	mov    %esp,%ebp
c010003d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c0100040:	b8 28 cf 11 c0       	mov    $0xc011cf28,%eax
c0100045:	2d 00 c0 11 c0       	sub    $0xc011c000,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 c0 11 c0 	movl   $0xc011c000,(%esp)
c010005d:	e8 6e 59 00 00       	call   c01059d0 <memset>

    cons_init();                // init the console
c0100062:	e8 5e 16 00 00       	call   c01016c5 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 00 62 10 c0 	movl   $0xc0106200,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 1c 62 10 c0 	movl   $0xc010621c,(%esp)
c010007c:	e8 48 02 00 00       	call   c01002c9 <cprintf>

    print_kerninfo();
c0100081:	e8 06 09 00 00       	call   c010098c <print_kerninfo>

    grade_backtrace();
c0100086:	e8 9a 00 00 00       	call   c0100125 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 e5 32 00 00       	call   c0103375 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 ab 17 00 00       	call   c0101840 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 2b 19 00 00       	call   c01019c5 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 6d 0d 00 00       	call   c0100e0c <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 e8 18 00 00       	call   c010198c <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
c01000a4:	e8 86 01 00 00       	call   c010022f <lab1_switch_test>

    /* do nothing */
    while (1);
c01000a9:	eb fe                	jmp    c01000a9 <kern_init+0x73>

c01000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000ab:	f3 0f 1e fb          	endbr32 
c01000af:	55                   	push   %ebp
c01000b0:	89 e5                	mov    %esp,%ebp
c01000b2:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000bc:	00 
c01000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c4:	00 
c01000c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000cc:	e8 25 0d 00 00       	call   c0100df6 <mon_backtrace>
}
c01000d1:	90                   	nop
c01000d2:	c9                   	leave  
c01000d3:	c3                   	ret    

c01000d4 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d4:	f3 0f 1e fb          	endbr32 
c01000d8:	55                   	push   %ebp
c01000d9:	89 e5                	mov    %esp,%ebp
c01000db:	53                   	push   %ebx
c01000dc:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000df:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000e2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000e5:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01000eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000ef:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000f7:	89 04 24             	mov    %eax,(%esp)
c01000fa:	e8 ac ff ff ff       	call   c01000ab <grade_backtrace2>
}
c01000ff:	90                   	nop
c0100100:	83 c4 14             	add    $0x14,%esp
c0100103:	5b                   	pop    %ebx
c0100104:	5d                   	pop    %ebp
c0100105:	c3                   	ret    

c0100106 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100106:	f3 0f 1e fb          	endbr32 
c010010a:	55                   	push   %ebp
c010010b:	89 e5                	mov    %esp,%ebp
c010010d:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100110:	8b 45 10             	mov    0x10(%ebp),%eax
c0100113:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100117:	8b 45 08             	mov    0x8(%ebp),%eax
c010011a:	89 04 24             	mov    %eax,(%esp)
c010011d:	e8 b2 ff ff ff       	call   c01000d4 <grade_backtrace1>
}
c0100122:	90                   	nop
c0100123:	c9                   	leave  
c0100124:	c3                   	ret    

c0100125 <grade_backtrace>:

void
grade_backtrace(void) {
c0100125:	f3 0f 1e fb          	endbr32 
c0100129:	55                   	push   %ebp
c010012a:	89 e5                	mov    %esp,%ebp
c010012c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010012f:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100134:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010013b:	ff 
c010013c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100147:	e8 ba ff ff ff       	call   c0100106 <grade_backtrace0>
}
c010014c:	90                   	nop
c010014d:	c9                   	leave  
c010014e:	c3                   	ret    

c010014f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010014f:	f3 0f 1e fb          	endbr32 
c0100153:	55                   	push   %ebp
c0100154:	89 e5                	mov    %esp,%ebp
c0100156:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100159:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c010015c:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010015f:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100162:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100165:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100169:	83 e0 03             	and    $0x3,%eax
c010016c:	89 c2                	mov    %eax,%edx
c010016e:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100173:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100177:	89 44 24 04          	mov    %eax,0x4(%esp)
c010017b:	c7 04 24 21 62 10 c0 	movl   $0xc0106221,(%esp)
c0100182:	e8 42 01 00 00       	call   c01002c9 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100187:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010018b:	89 c2                	mov    %eax,%edx
c010018d:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100192:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100196:	89 44 24 04          	mov    %eax,0x4(%esp)
c010019a:	c7 04 24 2f 62 10 c0 	movl   $0xc010622f,(%esp)
c01001a1:	e8 23 01 00 00       	call   c01002c9 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c01001a6:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001aa:	89 c2                	mov    %eax,%edx
c01001ac:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001b1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001b5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001b9:	c7 04 24 3d 62 10 c0 	movl   $0xc010623d,(%esp)
c01001c0:	e8 04 01 00 00       	call   c01002c9 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001c5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001c9:	89 c2                	mov    %eax,%edx
c01001cb:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001d0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001d8:	c7 04 24 4b 62 10 c0 	movl   $0xc010624b,(%esp)
c01001df:	e8 e5 00 00 00       	call   c01002c9 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001e4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001e8:	89 c2                	mov    %eax,%edx
c01001ea:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001ef:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001f7:	c7 04 24 59 62 10 c0 	movl   $0xc0106259,(%esp)
c01001fe:	e8 c6 00 00 00       	call   c01002c9 <cprintf>
    round ++;
c0100203:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c0100208:	40                   	inc    %eax
c0100209:	a3 00 c0 11 c0       	mov    %eax,0xc011c000
}
c010020e:	90                   	nop
c010020f:	c9                   	leave  
c0100210:	c3                   	ret    

c0100211 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100211:	f3 0f 1e fb          	endbr32 
c0100215:	55                   	push   %ebp
c0100216:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
    asm volatile (
c0100218:	16                   	push   %ss
c0100219:	54                   	push   %esp
c010021a:	cd 78                	int    $0x78
c010021c:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
c010021e:	90                   	nop
c010021f:	5d                   	pop    %ebp
c0100220:	c3                   	ret    

c0100221 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100221:	f3 0f 1e fb          	endbr32 
c0100225:	55                   	push   %ebp
c0100226:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
c0100228:	cd 79                	int    $0x79
c010022a:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
c010022c:	90                   	nop
c010022d:	5d                   	pop    %ebp
c010022e:	c3                   	ret    

c010022f <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010022f:	f3 0f 1e fb          	endbr32 
c0100233:	55                   	push   %ebp
c0100234:	89 e5                	mov    %esp,%ebp
c0100236:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100239:	e8 11 ff ff ff       	call   c010014f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010023e:	c7 04 24 68 62 10 c0 	movl   $0xc0106268,(%esp)
c0100245:	e8 7f 00 00 00       	call   c01002c9 <cprintf>
    lab1_switch_to_user();
c010024a:	e8 c2 ff ff ff       	call   c0100211 <lab1_switch_to_user>
    lab1_print_cur_status();
c010024f:	e8 fb fe ff ff       	call   c010014f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100254:	c7 04 24 88 62 10 c0 	movl   $0xc0106288,(%esp)
c010025b:	e8 69 00 00 00       	call   c01002c9 <cprintf>
    lab1_switch_to_kernel();
c0100260:	e8 bc ff ff ff       	call   c0100221 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100265:	e8 e5 fe ff ff       	call   c010014f <lab1_print_cur_status>
}
c010026a:	90                   	nop
c010026b:	c9                   	leave  
c010026c:	c3                   	ret    

c010026d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010026d:	f3 0f 1e fb          	endbr32 
c0100271:	55                   	push   %ebp
c0100272:	89 e5                	mov    %esp,%ebp
c0100274:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100277:	8b 45 08             	mov    0x8(%ebp),%eax
c010027a:	89 04 24             	mov    %eax,(%esp)
c010027d:	e8 74 14 00 00       	call   c01016f6 <cons_putc>
    (*cnt) ++;
c0100282:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100285:	8b 00                	mov    (%eax),%eax
c0100287:	8d 50 01             	lea    0x1(%eax),%edx
c010028a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010028d:	89 10                	mov    %edx,(%eax)
}
c010028f:	90                   	nop
c0100290:	c9                   	leave  
c0100291:	c3                   	ret    

c0100292 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100292:	f3 0f 1e fb          	endbr32 
c0100296:	55                   	push   %ebp
c0100297:	89 e5                	mov    %esp,%ebp
c0100299:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010029c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c01002a3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01002a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01002aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01002ad:	89 44 24 08          	mov    %eax,0x8(%esp)
c01002b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
c01002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002b8:	c7 04 24 6d 02 10 c0 	movl   $0xc010026d,(%esp)
c01002bf:	e8 78 5a 00 00       	call   c0105d3c <vprintfmt>
    return cnt;
c01002c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002c7:	c9                   	leave  
c01002c8:	c3                   	ret    

c01002c9 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002c9:	f3 0f 1e fb          	endbr32 
c01002cd:	55                   	push   %ebp
c01002ce:	89 e5                	mov    %esp,%ebp
c01002d0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002d3:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002dc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01002e3:	89 04 24             	mov    %eax,(%esp)
c01002e6:	e8 a7 ff ff ff       	call   c0100292 <vcprintf>
c01002eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002f1:	c9                   	leave  
c01002f2:	c3                   	ret    

c01002f3 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002f3:	f3 0f 1e fb          	endbr32 
c01002f7:	55                   	push   %ebp
c01002f8:	89 e5                	mov    %esp,%ebp
c01002fa:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100300:	89 04 24             	mov    %eax,(%esp)
c0100303:	e8 ee 13 00 00       	call   c01016f6 <cons_putc>
}
c0100308:	90                   	nop
c0100309:	c9                   	leave  
c010030a:	c3                   	ret    

c010030b <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c010030b:	f3 0f 1e fb          	endbr32 
c010030f:	55                   	push   %ebp
c0100310:	89 e5                	mov    %esp,%ebp
c0100312:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100315:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c010031c:	eb 13                	jmp    c0100331 <cputs+0x26>
        cputch(c, &cnt);
c010031e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0100322:	8d 55 f0             	lea    -0x10(%ebp),%edx
c0100325:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100329:	89 04 24             	mov    %eax,(%esp)
c010032c:	e8 3c ff ff ff       	call   c010026d <cputch>
    while ((c = *str ++) != '\0') {
c0100331:	8b 45 08             	mov    0x8(%ebp),%eax
c0100334:	8d 50 01             	lea    0x1(%eax),%edx
c0100337:	89 55 08             	mov    %edx,0x8(%ebp)
c010033a:	0f b6 00             	movzbl (%eax),%eax
c010033d:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100340:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100344:	75 d8                	jne    c010031e <cputs+0x13>
    }
    cputch('\n', &cnt);
c0100346:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100349:	89 44 24 04          	mov    %eax,0x4(%esp)
c010034d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100354:	e8 14 ff ff ff       	call   c010026d <cputch>
    return cnt;
c0100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010035c:	c9                   	leave  
c010035d:	c3                   	ret    

c010035e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010035e:	f3 0f 1e fb          	endbr32 
c0100362:	55                   	push   %ebp
c0100363:	89 e5                	mov    %esp,%ebp
c0100365:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100368:	90                   	nop
c0100369:	e8 c9 13 00 00       	call   c0101737 <cons_getc>
c010036e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100371:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100375:	74 f2                	je     c0100369 <getchar+0xb>
        /* do nothing */;
    return c;
c0100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037a:	c9                   	leave  
c010037b:	c3                   	ret    

c010037c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010037c:	f3 0f 1e fb          	endbr32 
c0100380:	55                   	push   %ebp
c0100381:	89 e5                	mov    %esp,%ebp
c0100383:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100386:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010038a:	74 13                	je     c010039f <readline+0x23>
        cprintf("%s", prompt);
c010038c:	8b 45 08             	mov    0x8(%ebp),%eax
c010038f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100393:	c7 04 24 a7 62 10 c0 	movl   $0xc01062a7,(%esp)
c010039a:	e8 2a ff ff ff       	call   c01002c9 <cprintf>
    }
    int i = 0, c;
c010039f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c01003a6:	e8 b3 ff ff ff       	call   c010035e <getchar>
c01003ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c01003ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01003b2:	79 07                	jns    c01003bb <readline+0x3f>
            return NULL;
c01003b4:	b8 00 00 00 00       	mov    $0x0,%eax
c01003b9:	eb 78                	jmp    c0100433 <readline+0xb7>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c01003bb:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c01003bf:	7e 28                	jle    c01003e9 <readline+0x6d>
c01003c1:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c01003c8:	7f 1f                	jg     c01003e9 <readline+0x6d>
            cputchar(c);
c01003ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003cd:	89 04 24             	mov    %eax,(%esp)
c01003d0:	e8 1e ff ff ff       	call   c01002f3 <cputchar>
            buf[i ++] = c;
c01003d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d8:	8d 50 01             	lea    0x1(%eax),%edx
c01003db:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003de:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003e1:	88 90 20 c0 11 c0    	mov    %dl,-0x3fee3fe0(%eax)
c01003e7:	eb 45                	jmp    c010042e <readline+0xb2>
        }
        else if (c == '\b' && i > 0) {
c01003e9:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003ed:	75 16                	jne    c0100405 <readline+0x89>
c01003ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f3:	7e 10                	jle    c0100405 <readline+0x89>
            cputchar(c);
c01003f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003f8:	89 04 24             	mov    %eax,(%esp)
c01003fb:	e8 f3 fe ff ff       	call   c01002f3 <cputchar>
            i --;
c0100400:	ff 4d f4             	decl   -0xc(%ebp)
c0100403:	eb 29                	jmp    c010042e <readline+0xb2>
        }
        else if (c == '\n' || c == '\r') {
c0100405:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c0100409:	74 06                	je     c0100411 <readline+0x95>
c010040b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c010040f:	75 95                	jne    c01003a6 <readline+0x2a>
            cputchar(c);
c0100411:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100414:	89 04 24             	mov    %eax,(%esp)
c0100417:	e8 d7 fe ff ff       	call   c01002f3 <cputchar>
            buf[i] = '\0';
c010041c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010041f:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c0100424:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c0100427:	b8 20 c0 11 c0       	mov    $0xc011c020,%eax
c010042c:	eb 05                	jmp    c0100433 <readline+0xb7>
        c = getchar();
c010042e:	e9 73 ff ff ff       	jmp    c01003a6 <readline+0x2a>
        }
    }
}
c0100433:	c9                   	leave  
c0100434:	c3                   	ret    

c0100435 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100435:	f3 0f 1e fb          	endbr32 
c0100439:	55                   	push   %ebp
c010043a:	89 e5                	mov    %esp,%ebp
c010043c:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c010043f:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
c0100444:	85 c0                	test   %eax,%eax
c0100446:	75 5b                	jne    c01004a3 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
c0100448:	c7 05 20 c4 11 c0 01 	movl   $0x1,0xc011c420
c010044f:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100452:	8d 45 14             	lea    0x14(%ebp),%eax
c0100455:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100458:	8b 45 0c             	mov    0xc(%ebp),%eax
c010045b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010045f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100462:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100466:	c7 04 24 aa 62 10 c0 	movl   $0xc01062aa,(%esp)
c010046d:	e8 57 fe ff ff       	call   c01002c9 <cprintf>
    vcprintf(fmt, ap);
c0100472:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100475:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100479:	8b 45 10             	mov    0x10(%ebp),%eax
c010047c:	89 04 24             	mov    %eax,(%esp)
c010047f:	e8 0e fe ff ff       	call   c0100292 <vcprintf>
    cprintf("\n");
c0100484:	c7 04 24 c6 62 10 c0 	movl   $0xc01062c6,(%esp)
c010048b:	e8 39 fe ff ff       	call   c01002c9 <cprintf>
    
    cprintf("stack trackback:\n");
c0100490:	c7 04 24 c8 62 10 c0 	movl   $0xc01062c8,(%esp)
c0100497:	e8 2d fe ff ff       	call   c01002c9 <cprintf>
    print_stackframe();
c010049c:	e8 3d 06 00 00       	call   c0100ade <print_stackframe>
c01004a1:	eb 01                	jmp    c01004a4 <__panic+0x6f>
        goto panic_dead;
c01004a3:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c01004a4:	e8 ef 14 00 00       	call   c0101998 <intr_disable>
    while (1) {
        kmonitor(NULL);
c01004a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01004b0:	e8 68 08 00 00       	call   c0100d1d <kmonitor>
c01004b5:	eb f2                	jmp    c01004a9 <__panic+0x74>

c01004b7 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c01004b7:	f3 0f 1e fb          	endbr32 
c01004bb:	55                   	push   %ebp
c01004bc:	89 e5                	mov    %esp,%ebp
c01004be:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c01004c1:	8d 45 14             	lea    0x14(%ebp),%eax
c01004c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c01004c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004ca:	89 44 24 08          	mov    %eax,0x8(%esp)
c01004ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01004d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004d5:	c7 04 24 da 62 10 c0 	movl   $0xc01062da,(%esp)
c01004dc:	e8 e8 fd ff ff       	call   c01002c9 <cprintf>
    vcprintf(fmt, ap);
c01004e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01004e4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004e8:	8b 45 10             	mov    0x10(%ebp),%eax
c01004eb:	89 04 24             	mov    %eax,(%esp)
c01004ee:	e8 9f fd ff ff       	call   c0100292 <vcprintf>
    cprintf("\n");
c01004f3:	c7 04 24 c6 62 10 c0 	movl   $0xc01062c6,(%esp)
c01004fa:	e8 ca fd ff ff       	call   c01002c9 <cprintf>
    va_end(ap);
}
c01004ff:	90                   	nop
c0100500:	c9                   	leave  
c0100501:	c3                   	ret    

c0100502 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100502:	f3 0f 1e fb          	endbr32 
c0100506:	55                   	push   %ebp
c0100507:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100509:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
}
c010050e:	5d                   	pop    %ebp
c010050f:	c3                   	ret    

c0100510 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100510:	f3 0f 1e fb          	endbr32 
c0100514:	55                   	push   %ebp
c0100515:	89 e5                	mov    %esp,%ebp
c0100517:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c010051a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051d:	8b 00                	mov    (%eax),%eax
c010051f:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100522:	8b 45 10             	mov    0x10(%ebp),%eax
c0100525:	8b 00                	mov    (%eax),%eax
c0100527:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010052a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c0100531:	e9 ca 00 00 00       	jmp    c0100600 <stab_binsearch+0xf0>
        int true_m = (l + r) / 2, m = true_m;
c0100536:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100539:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010053c:	01 d0                	add    %edx,%eax
c010053e:	89 c2                	mov    %eax,%edx
c0100540:	c1 ea 1f             	shr    $0x1f,%edx
c0100543:	01 d0                	add    %edx,%eax
c0100545:	d1 f8                	sar    %eax
c0100547:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010054a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010054d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100550:	eb 03                	jmp    c0100555 <stab_binsearch+0x45>
            m --;
c0100552:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100555:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100558:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010055b:	7c 1f                	jl     c010057c <stab_binsearch+0x6c>
c010055d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100560:	89 d0                	mov    %edx,%eax
c0100562:	01 c0                	add    %eax,%eax
c0100564:	01 d0                	add    %edx,%eax
c0100566:	c1 e0 02             	shl    $0x2,%eax
c0100569:	89 c2                	mov    %eax,%edx
c010056b:	8b 45 08             	mov    0x8(%ebp),%eax
c010056e:	01 d0                	add    %edx,%eax
c0100570:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100574:	0f b6 c0             	movzbl %al,%eax
c0100577:	39 45 14             	cmp    %eax,0x14(%ebp)
c010057a:	75 d6                	jne    c0100552 <stab_binsearch+0x42>
        }
        if (m < l) {    // no match in [l, m]
c010057c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010057f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100582:	7d 09                	jge    c010058d <stab_binsearch+0x7d>
            l = true_m + 1;
c0100584:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100587:	40                   	inc    %eax
c0100588:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010058b:	eb 73                	jmp    c0100600 <stab_binsearch+0xf0>
        }

        // actual binary search
        any_matches = 1;
c010058d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100594:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100597:	89 d0                	mov    %edx,%eax
c0100599:	01 c0                	add    %eax,%eax
c010059b:	01 d0                	add    %edx,%eax
c010059d:	c1 e0 02             	shl    $0x2,%eax
c01005a0:	89 c2                	mov    %eax,%edx
c01005a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01005a5:	01 d0                	add    %edx,%eax
c01005a7:	8b 40 08             	mov    0x8(%eax),%eax
c01005aa:	39 45 18             	cmp    %eax,0x18(%ebp)
c01005ad:	76 11                	jbe    c01005c0 <stab_binsearch+0xb0>
            *region_left = m;
c01005af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005b5:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01005b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01005ba:	40                   	inc    %eax
c01005bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01005be:	eb 40                	jmp    c0100600 <stab_binsearch+0xf0>
        } else if (stabs[m].n_value > addr) {
c01005c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005c3:	89 d0                	mov    %edx,%eax
c01005c5:	01 c0                	add    %eax,%eax
c01005c7:	01 d0                	add    %edx,%eax
c01005c9:	c1 e0 02             	shl    $0x2,%eax
c01005cc:	89 c2                	mov    %eax,%edx
c01005ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01005d1:	01 d0                	add    %edx,%eax
c01005d3:	8b 40 08             	mov    0x8(%eax),%eax
c01005d6:	39 45 18             	cmp    %eax,0x18(%ebp)
c01005d9:	73 14                	jae    c01005ef <stab_binsearch+0xdf>
            *region_right = m - 1;
c01005db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005de:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005e1:	8b 45 10             	mov    0x10(%ebp),%eax
c01005e4:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01005e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005e9:	48                   	dec    %eax
c01005ea:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005ed:	eb 11                	jmp    c0100600 <stab_binsearch+0xf0>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005ef:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005f5:	89 10                	mov    %edx,(%eax)
            l = m;
c01005f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005fd:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c0100600:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100603:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0100606:	0f 8e 2a ff ff ff    	jle    c0100536 <stab_binsearch+0x26>
        }
    }

    if (!any_matches) {
c010060c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100610:	75 0f                	jne    c0100621 <stab_binsearch+0x111>
        *region_right = *region_left - 1;
c0100612:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100615:	8b 00                	mov    (%eax),%eax
c0100617:	8d 50 ff             	lea    -0x1(%eax),%edx
c010061a:	8b 45 10             	mov    0x10(%ebp),%eax
c010061d:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010061f:	eb 3e                	jmp    c010065f <stab_binsearch+0x14f>
        l = *region_right;
c0100621:	8b 45 10             	mov    0x10(%ebp),%eax
c0100624:	8b 00                	mov    (%eax),%eax
c0100626:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100629:	eb 03                	jmp    c010062e <stab_binsearch+0x11e>
c010062b:	ff 4d fc             	decl   -0x4(%ebp)
c010062e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100631:	8b 00                	mov    (%eax),%eax
c0100633:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100636:	7e 1f                	jle    c0100657 <stab_binsearch+0x147>
c0100638:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010063b:	89 d0                	mov    %edx,%eax
c010063d:	01 c0                	add    %eax,%eax
c010063f:	01 d0                	add    %edx,%eax
c0100641:	c1 e0 02             	shl    $0x2,%eax
c0100644:	89 c2                	mov    %eax,%edx
c0100646:	8b 45 08             	mov    0x8(%ebp),%eax
c0100649:	01 d0                	add    %edx,%eax
c010064b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010064f:	0f b6 c0             	movzbl %al,%eax
c0100652:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100655:	75 d4                	jne    c010062b <stab_binsearch+0x11b>
        *region_left = l;
c0100657:	8b 45 0c             	mov    0xc(%ebp),%eax
c010065a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010065d:	89 10                	mov    %edx,(%eax)
}
c010065f:	90                   	nop
c0100660:	c9                   	leave  
c0100661:	c3                   	ret    

c0100662 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100662:	f3 0f 1e fb          	endbr32 
c0100666:	55                   	push   %ebp
c0100667:	89 e5                	mov    %esp,%ebp
c0100669:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010066c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010066f:	c7 00 f8 62 10 c0    	movl   $0xc01062f8,(%eax)
    info->eip_line = 0;
c0100675:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100678:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010067f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100682:	c7 40 08 f8 62 10 c0 	movl   $0xc01062f8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100689:	8b 45 0c             	mov    0xc(%ebp),%eax
c010068c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100693:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100696:	8b 55 08             	mov    0x8(%ebp),%edx
c0100699:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010069c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010069f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c01006a6:	c7 45 f4 28 75 10 c0 	movl   $0xc0107528,-0xc(%ebp)
    stab_end = __STAB_END__;
c01006ad:	c7 45 f0 18 3f 11 c0 	movl   $0xc0113f18,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c01006b4:	c7 45 ec 19 3f 11 c0 	movl   $0xc0113f19,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01006bb:	c7 45 e8 58 6a 11 c0 	movl   $0xc0116a58,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01006c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006c5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01006c8:	76 0b                	jbe    c01006d5 <debuginfo_eip+0x73>
c01006ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01006cd:	48                   	dec    %eax
c01006ce:	0f b6 00             	movzbl (%eax),%eax
c01006d1:	84 c0                	test   %al,%al
c01006d3:	74 0a                	je     c01006df <debuginfo_eip+0x7d>
        return -1;
c01006d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006da:	e9 ab 02 00 00       	jmp    c010098a <debuginfo_eip+0x328>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01006df:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01006e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01006e9:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01006ec:	c1 f8 02             	sar    $0x2,%eax
c01006ef:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006f5:	48                   	dec    %eax
c01006f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01006fc:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100700:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c0100707:	00 
c0100708:	8d 45 e0             	lea    -0x20(%ebp),%eax
c010070b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010070f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c0100712:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100716:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100719:	89 04 24             	mov    %eax,(%esp)
c010071c:	e8 ef fd ff ff       	call   c0100510 <stab_binsearch>
    if (lfile == 0)
c0100721:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100724:	85 c0                	test   %eax,%eax
c0100726:	75 0a                	jne    c0100732 <debuginfo_eip+0xd0>
        return -1;
c0100728:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010072d:	e9 58 02 00 00       	jmp    c010098a <debuginfo_eip+0x328>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c0100732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100735:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100738:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010073b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c010073e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100741:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100745:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c010074c:	00 
c010074d:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100750:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100754:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100757:	89 44 24 04          	mov    %eax,0x4(%esp)
c010075b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075e:	89 04 24             	mov    %eax,(%esp)
c0100761:	e8 aa fd ff ff       	call   c0100510 <stab_binsearch>

    if (lfun <= rfun) {
c0100766:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100769:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010076c:	39 c2                	cmp    %eax,%edx
c010076e:	7f 78                	jg     c01007e8 <debuginfo_eip+0x186>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100770:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100773:	89 c2                	mov    %eax,%edx
c0100775:	89 d0                	mov    %edx,%eax
c0100777:	01 c0                	add    %eax,%eax
c0100779:	01 d0                	add    %edx,%eax
c010077b:	c1 e0 02             	shl    $0x2,%eax
c010077e:	89 c2                	mov    %eax,%edx
c0100780:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100783:	01 d0                	add    %edx,%eax
c0100785:	8b 10                	mov    (%eax),%edx
c0100787:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010078a:	2b 45 ec             	sub    -0x14(%ebp),%eax
c010078d:	39 c2                	cmp    %eax,%edx
c010078f:	73 22                	jae    c01007b3 <debuginfo_eip+0x151>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100791:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100794:	89 c2                	mov    %eax,%edx
c0100796:	89 d0                	mov    %edx,%eax
c0100798:	01 c0                	add    %eax,%eax
c010079a:	01 d0                	add    %edx,%eax
c010079c:	c1 e0 02             	shl    $0x2,%eax
c010079f:	89 c2                	mov    %eax,%edx
c01007a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007a4:	01 d0                	add    %edx,%eax
c01007a6:	8b 10                	mov    (%eax),%edx
c01007a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01007ab:	01 c2                	add    %eax,%edx
c01007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b0:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c01007b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007b6:	89 c2                	mov    %eax,%edx
c01007b8:	89 d0                	mov    %edx,%eax
c01007ba:	01 c0                	add    %eax,%eax
c01007bc:	01 d0                	add    %edx,%eax
c01007be:	c1 e0 02             	shl    $0x2,%eax
c01007c1:	89 c2                	mov    %eax,%edx
c01007c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007c6:	01 d0                	add    %edx,%eax
c01007c8:	8b 50 08             	mov    0x8(%eax),%edx
c01007cb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ce:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01007d1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d4:	8b 40 10             	mov    0x10(%eax),%eax
c01007d7:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01007da:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01007dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01007e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01007e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01007e6:	eb 15                	jmp    c01007fd <debuginfo_eip+0x19b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01007e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007eb:	8b 55 08             	mov    0x8(%ebp),%edx
c01007ee:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100800:	8b 40 08             	mov    0x8(%eax),%eax
c0100803:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c010080a:	00 
c010080b:	89 04 24             	mov    %eax,(%esp)
c010080e:	e8 31 50 00 00       	call   c0105844 <strfind>
c0100813:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100816:	8b 52 08             	mov    0x8(%edx),%edx
c0100819:	29 d0                	sub    %edx,%eax
c010081b:	89 c2                	mov    %eax,%edx
c010081d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100820:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c0100823:	8b 45 08             	mov    0x8(%ebp),%eax
c0100826:	89 44 24 10          	mov    %eax,0x10(%esp)
c010082a:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c0100831:	00 
c0100832:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100835:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100839:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c010083c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100840:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100843:	89 04 24             	mov    %eax,(%esp)
c0100846:	e8 c5 fc ff ff       	call   c0100510 <stab_binsearch>
    if (lline <= rline) {
c010084b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100851:	39 c2                	cmp    %eax,%edx
c0100853:	7f 23                	jg     c0100878 <debuginfo_eip+0x216>
        info->eip_line = stabs[rline].n_desc;
c0100855:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100858:	89 c2                	mov    %eax,%edx
c010085a:	89 d0                	mov    %edx,%eax
c010085c:	01 c0                	add    %eax,%eax
c010085e:	01 d0                	add    %edx,%eax
c0100860:	c1 e0 02             	shl    $0x2,%eax
c0100863:	89 c2                	mov    %eax,%edx
c0100865:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100868:	01 d0                	add    %edx,%eax
c010086a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010086e:	89 c2                	mov    %eax,%edx
c0100870:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100873:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100876:	eb 11                	jmp    c0100889 <debuginfo_eip+0x227>
        return -1;
c0100878:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010087d:	e9 08 01 00 00       	jmp    c010098a <debuginfo_eip+0x328>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100882:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100885:	48                   	dec    %eax
c0100886:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100889:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010088c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010088f:	39 c2                	cmp    %eax,%edx
c0100891:	7c 56                	jl     c01008e9 <debuginfo_eip+0x287>
           && stabs[lline].n_type != N_SOL
c0100893:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100896:	89 c2                	mov    %eax,%edx
c0100898:	89 d0                	mov    %edx,%eax
c010089a:	01 c0                	add    %eax,%eax
c010089c:	01 d0                	add    %edx,%eax
c010089e:	c1 e0 02             	shl    $0x2,%eax
c01008a1:	89 c2                	mov    %eax,%edx
c01008a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008a6:	01 d0                	add    %edx,%eax
c01008a8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008ac:	3c 84                	cmp    $0x84,%al
c01008ae:	74 39                	je     c01008e9 <debuginfo_eip+0x287>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c01008b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008b3:	89 c2                	mov    %eax,%edx
c01008b5:	89 d0                	mov    %edx,%eax
c01008b7:	01 c0                	add    %eax,%eax
c01008b9:	01 d0                	add    %edx,%eax
c01008bb:	c1 e0 02             	shl    $0x2,%eax
c01008be:	89 c2                	mov    %eax,%edx
c01008c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008c3:	01 d0                	add    %edx,%eax
c01008c5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01008c9:	3c 64                	cmp    $0x64,%al
c01008cb:	75 b5                	jne    c0100882 <debuginfo_eip+0x220>
c01008cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008d0:	89 c2                	mov    %eax,%edx
c01008d2:	89 d0                	mov    %edx,%eax
c01008d4:	01 c0                	add    %eax,%eax
c01008d6:	01 d0                	add    %edx,%eax
c01008d8:	c1 e0 02             	shl    $0x2,%eax
c01008db:	89 c2                	mov    %eax,%edx
c01008dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e0:	01 d0                	add    %edx,%eax
c01008e2:	8b 40 08             	mov    0x8(%eax),%eax
c01008e5:	85 c0                	test   %eax,%eax
c01008e7:	74 99                	je     c0100882 <debuginfo_eip+0x220>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008e9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008ef:	39 c2                	cmp    %eax,%edx
c01008f1:	7c 42                	jl     c0100935 <debuginfo_eip+0x2d3>
c01008f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008f6:	89 c2                	mov    %eax,%edx
c01008f8:	89 d0                	mov    %edx,%eax
c01008fa:	01 c0                	add    %eax,%eax
c01008fc:	01 d0                	add    %edx,%eax
c01008fe:	c1 e0 02             	shl    $0x2,%eax
c0100901:	89 c2                	mov    %eax,%edx
c0100903:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100906:	01 d0                	add    %edx,%eax
c0100908:	8b 10                	mov    (%eax),%edx
c010090a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010090d:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100910:	39 c2                	cmp    %eax,%edx
c0100912:	73 21                	jae    c0100935 <debuginfo_eip+0x2d3>
        info->eip_file = stabstr + stabs[lline].n_strx;
c0100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100917:	89 c2                	mov    %eax,%edx
c0100919:	89 d0                	mov    %edx,%eax
c010091b:	01 c0                	add    %eax,%eax
c010091d:	01 d0                	add    %edx,%eax
c010091f:	c1 e0 02             	shl    $0x2,%eax
c0100922:	89 c2                	mov    %eax,%edx
c0100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100927:	01 d0                	add    %edx,%eax
c0100929:	8b 10                	mov    (%eax),%edx
c010092b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010092e:	01 c2                	add    %eax,%edx
c0100930:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100933:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100935:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100938:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010093b:	39 c2                	cmp    %eax,%edx
c010093d:	7d 46                	jge    c0100985 <debuginfo_eip+0x323>
        for (lline = lfun + 1;
c010093f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100942:	40                   	inc    %eax
c0100943:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100946:	eb 16                	jmp    c010095e <debuginfo_eip+0x2fc>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100948:	8b 45 0c             	mov    0xc(%ebp),%eax
c010094b:	8b 40 14             	mov    0x14(%eax),%eax
c010094e:	8d 50 01             	lea    0x1(%eax),%edx
c0100951:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100954:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100957:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010095a:	40                   	inc    %eax
c010095b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010095e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100961:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
c0100964:	39 c2                	cmp    %eax,%edx
c0100966:	7d 1d                	jge    c0100985 <debuginfo_eip+0x323>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100968:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010096b:	89 c2                	mov    %eax,%edx
c010096d:	89 d0                	mov    %edx,%eax
c010096f:	01 c0                	add    %eax,%eax
c0100971:	01 d0                	add    %edx,%eax
c0100973:	c1 e0 02             	shl    $0x2,%eax
c0100976:	89 c2                	mov    %eax,%edx
c0100978:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010097b:	01 d0                	add    %edx,%eax
c010097d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100981:	3c a0                	cmp    $0xa0,%al
c0100983:	74 c3                	je     c0100948 <debuginfo_eip+0x2e6>
        }
    }
    return 0;
c0100985:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010098a:	c9                   	leave  
c010098b:	c3                   	ret    

c010098c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010098c:	f3 0f 1e fb          	endbr32 
c0100990:	55                   	push   %ebp
c0100991:	89 e5                	mov    %esp,%ebp
c0100993:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100996:	c7 04 24 02 63 10 c0 	movl   $0xc0106302,(%esp)
c010099d:	e8 27 f9 ff ff       	call   c01002c9 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c01009a2:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c01009a9:	c0 
c01009aa:	c7 04 24 1b 63 10 c0 	movl   $0xc010631b,(%esp)
c01009b1:	e8 13 f9 ff ff       	call   c01002c9 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c01009b6:	c7 44 24 04 f4 61 10 	movl   $0xc01061f4,0x4(%esp)
c01009bd:	c0 
c01009be:	c7 04 24 33 63 10 c0 	movl   $0xc0106333,(%esp)
c01009c5:	e8 ff f8 ff ff       	call   c01002c9 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01009ca:	c7 44 24 04 00 c0 11 	movl   $0xc011c000,0x4(%esp)
c01009d1:	c0 
c01009d2:	c7 04 24 4b 63 10 c0 	movl   $0xc010634b,(%esp)
c01009d9:	e8 eb f8 ff ff       	call   c01002c9 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01009de:	c7 44 24 04 28 cf 11 	movl   $0xc011cf28,0x4(%esp)
c01009e5:	c0 
c01009e6:	c7 04 24 63 63 10 c0 	movl   $0xc0106363,(%esp)
c01009ed:	e8 d7 f8 ff ff       	call   c01002c9 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009f2:	b8 28 cf 11 c0       	mov    $0xc011cf28,%eax
c01009f7:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01009fc:	05 ff 03 00 00       	add    $0x3ff,%eax
c0100a01:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c0100a07:	85 c0                	test   %eax,%eax
c0100a09:	0f 48 c2             	cmovs  %edx,%eax
c0100a0c:	c1 f8 0a             	sar    $0xa,%eax
c0100a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a13:	c7 04 24 7c 63 10 c0 	movl   $0xc010637c,(%esp)
c0100a1a:	e8 aa f8 ff ff       	call   c01002c9 <cprintf>
}
c0100a1f:	90                   	nop
c0100a20:	c9                   	leave  
c0100a21:	c3                   	ret    

c0100a22 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c0100a22:	f3 0f 1e fb          	endbr32 
c0100a26:	55                   	push   %ebp
c0100a27:	89 e5                	mov    %esp,%ebp
c0100a29:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100a2f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100a32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a36:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a39:	89 04 24             	mov    %eax,(%esp)
c0100a3c:	e8 21 fc ff ff       	call   c0100662 <debuginfo_eip>
c0100a41:	85 c0                	test   %eax,%eax
c0100a43:	74 15                	je     c0100a5a <print_debuginfo+0x38>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c0100a45:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a4c:	c7 04 24 a6 63 10 c0 	movl   $0xc01063a6,(%esp)
c0100a53:	e8 71 f8 ff ff       	call   c01002c9 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a58:	eb 6c                	jmp    c0100ac6 <print_debuginfo+0xa4>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a61:	eb 1b                	jmp    c0100a7e <print_debuginfo+0x5c>
            fnname[j] = info.eip_fn_name[j];
c0100a63:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a69:	01 d0                	add    %edx,%eax
c0100a6b:	0f b6 10             	movzbl (%eax),%edx
c0100a6e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a77:	01 c8                	add    %ecx,%eax
c0100a79:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a7b:	ff 45 f4             	incl   -0xc(%ebp)
c0100a7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0100a84:	7c dd                	jl     c0100a63 <print_debuginfo+0x41>
        fnname[j] = '\0';
c0100a86:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a8f:	01 d0                	add    %edx,%eax
c0100a91:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c0100a94:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a97:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a9a:	89 d1                	mov    %edx,%ecx
c0100a9c:	29 c1                	sub    %eax,%ecx
c0100a9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100aa1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100aa4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100aa8:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100aae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100ab2:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aba:	c7 04 24 c2 63 10 c0 	movl   $0xc01063c2,(%esp)
c0100ac1:	e8 03 f8 ff ff       	call   c01002c9 <cprintf>
}
c0100ac6:	90                   	nop
c0100ac7:	c9                   	leave  
c0100ac8:	c3                   	ret    

c0100ac9 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100ac9:	f3 0f 1e fb          	endbr32 
c0100acd:	55                   	push   %ebp
c0100ace:	89 e5                	mov    %esp,%ebp
c0100ad0:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100ad3:	8b 45 04             	mov    0x4(%ebp),%eax
c0100ad6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100ad9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100adc:	c9                   	leave  
c0100add:	c3                   	ret    

c0100ade <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100ade:	f3 0f 1e fb          	endbr32 
c0100ae2:	55                   	push   %ebp
c0100ae3:	89 e5                	mov    %esp,%ebp
c0100ae5:	53                   	push   %ebx
c0100ae6:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100ae9:	89 e8                	mov    %ebp,%eax
c0100aeb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c0100aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    /* LAB1 YOUR CODE : STEP 1 */
    /* (1) call read_ebp() to get the value of ebp. the type is (uint32_t);*/
    uint32_t ebp_val = read_ebp();
c0100af1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    /* (2) call read_eip() to get the value of eip. the type is (uint32_t);*/
    uint32_t eip_val = read_eip();
c0100af4:	e8 d0 ff ff ff       	call   c0100ac9 <read_eip>
c0100af9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    /* (3) from 0 .. STACKFRAME_DEPTH*/
    for (int i = 0; ebp_val != 0 && i < STACKFRAME_DEPTH; ++i) {
c0100afc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100b03:	e9 8a 00 00 00       	jmp    c0100b92 <print_stackframe+0xb4>
        /* (3.1) printf value of ebp, eip*/
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp_val, eip_val);
c0100b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b0b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b12:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b16:	c7 04 24 d4 63 10 c0 	movl   $0xc01063d4,(%esp)
c0100b1d:	e8 a7 f7 ff ff       	call   c01002c9 <cprintf>
        /* (3.2) (uint32_t)calling arguments [0..4] = the contents in address (uint32_t)ebp +2 [0..4]*/
        uint32_t *call_args = (uint32_t *)ebp_val + 2;
c0100b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b25:	83 c0 08             	add    $0x8,%eax
c0100b28:	89 45 e8             	mov    %eax,-0x18(%ebp)
        cprintf("0x%08x 0x%08x 0x%08x 0x%08x", call_args[0], call_args[1], call_args[2], call_args[3]);
c0100b2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b2e:	83 c0 0c             	add    $0xc,%eax
c0100b31:	8b 18                	mov    (%eax),%ebx
c0100b33:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b36:	83 c0 08             	add    $0x8,%eax
c0100b39:	8b 08                	mov    (%eax),%ecx
c0100b3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b3e:	83 c0 04             	add    $0x4,%eax
c0100b41:	8b 10                	mov    (%eax),%edx
c0100b43:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b46:	8b 00                	mov    (%eax),%eax
c0100b48:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100b4c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100b50:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100b54:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b58:	c7 04 24 f0 63 10 c0 	movl   $0xc01063f0,(%esp)
c0100b5f:	e8 65 f7 ff ff       	call   c01002c9 <cprintf>
        /* (3.3) cprintf("\n");*/
        cprintf("\n");
c0100b64:	c7 04 24 0c 64 10 c0 	movl   $0xc010640c,(%esp)
c0100b6b:	e8 59 f7 ff ff       	call   c01002c9 <cprintf>
        /* (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.*/
        print_debuginfo(eip_val - 1);
c0100b70:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b73:	48                   	dec    %eax
c0100b74:	89 04 24             	mov    %eax,(%esp)
c0100b77:	e8 a6 fe ff ff       	call   c0100a22 <print_debuginfo>
        /* (3.5) popup a calling stackframe*/
        /* NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]*/
        eip_val = *((uint32_t *)(ebp_val + 4));
c0100b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b7f:	83 c0 04             	add    $0x4,%eax
c0100b82:	8b 00                	mov    (%eax),%eax
c0100b84:	89 45 f0             	mov    %eax,-0x10(%ebp)
        /* the calling funciton's ebp = ss:[ebp]*/
        ebp_val = *((uint32_t *)ebp_val);
c0100b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b8a:	8b 00                	mov    (%eax),%eax
c0100b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (int i = 0; ebp_val != 0 && i < STACKFRAME_DEPTH; ++i) {
c0100b8f:	ff 45 ec             	incl   -0x14(%ebp)
c0100b92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b96:	74 0a                	je     c0100ba2 <print_stackframe+0xc4>
c0100b98:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b9c:	0f 8e 66 ff ff ff    	jle    c0100b08 <print_stackframe+0x2a>
    }
}
c0100ba2:	90                   	nop
c0100ba3:	83 c4 44             	add    $0x44,%esp
c0100ba6:	5b                   	pop    %ebx
c0100ba7:	5d                   	pop    %ebp
c0100ba8:	c3                   	ret    

c0100ba9 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100ba9:	f3 0f 1e fb          	endbr32 
c0100bad:	55                   	push   %ebp
c0100bae:	89 e5                	mov    %esp,%ebp
c0100bb0:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100bb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bba:	eb 0c                	jmp    c0100bc8 <parse+0x1f>
            *buf ++ = '\0';
c0100bbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bbf:	8d 50 01             	lea    0x1(%eax),%edx
c0100bc2:	89 55 08             	mov    %edx,0x8(%ebp)
c0100bc5:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bcb:	0f b6 00             	movzbl (%eax),%eax
c0100bce:	84 c0                	test   %al,%al
c0100bd0:	74 1d                	je     c0100bef <parse+0x46>
c0100bd2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd5:	0f b6 00             	movzbl (%eax),%eax
c0100bd8:	0f be c0             	movsbl %al,%eax
c0100bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bdf:	c7 04 24 90 64 10 c0 	movl   $0xc0106490,(%esp)
c0100be6:	e8 23 4c 00 00       	call   c010580e <strchr>
c0100beb:	85 c0                	test   %eax,%eax
c0100bed:	75 cd                	jne    c0100bbc <parse+0x13>
        }
        if (*buf == '\0') {
c0100bef:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bf2:	0f b6 00             	movzbl (%eax),%eax
c0100bf5:	84 c0                	test   %al,%al
c0100bf7:	74 65                	je     c0100c5e <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bf9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bfd:	75 14                	jne    c0100c13 <parse+0x6a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bff:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100c06:	00 
c0100c07:	c7 04 24 95 64 10 c0 	movl   $0xc0106495,(%esp)
c0100c0e:	e8 b6 f6 ff ff       	call   c01002c9 <cprintf>
        }
        argv[argc ++] = buf;
c0100c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c16:	8d 50 01             	lea    0x1(%eax),%edx
c0100c19:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100c1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100c23:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100c26:	01 c2                	add    %eax,%edx
c0100c28:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c2b:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c2d:	eb 03                	jmp    c0100c32 <parse+0x89>
            buf ++;
c0100c2f:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100c32:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c35:	0f b6 00             	movzbl (%eax),%eax
c0100c38:	84 c0                	test   %al,%al
c0100c3a:	74 8c                	je     c0100bc8 <parse+0x1f>
c0100c3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c3f:	0f b6 00             	movzbl (%eax),%eax
c0100c42:	0f be c0             	movsbl %al,%eax
c0100c45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c49:	c7 04 24 90 64 10 c0 	movl   $0xc0106490,(%esp)
c0100c50:	e8 b9 4b 00 00       	call   c010580e <strchr>
c0100c55:	85 c0                	test   %eax,%eax
c0100c57:	74 d6                	je     c0100c2f <parse+0x86>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100c59:	e9 6a ff ff ff       	jmp    c0100bc8 <parse+0x1f>
            break;
c0100c5e:	90                   	nop
        }
    }
    return argc;
c0100c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c62:	c9                   	leave  
c0100c63:	c3                   	ret    

c0100c64 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c64:	f3 0f 1e fb          	endbr32 
c0100c68:	55                   	push   %ebp
c0100c69:	89 e5                	mov    %esp,%ebp
c0100c6b:	53                   	push   %ebx
c0100c6c:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c6f:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c76:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c79:	89 04 24             	mov    %eax,(%esp)
c0100c7c:	e8 28 ff ff ff       	call   c0100ba9 <parse>
c0100c81:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c88:	75 0a                	jne    c0100c94 <runcmd+0x30>
        return 0;
c0100c8a:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c8f:	e9 83 00 00 00       	jmp    c0100d17 <runcmd+0xb3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c9b:	eb 5a                	jmp    c0100cf7 <runcmd+0x93>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c9d:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100ca0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ca3:	89 d0                	mov    %edx,%eax
c0100ca5:	01 c0                	add    %eax,%eax
c0100ca7:	01 d0                	add    %edx,%eax
c0100ca9:	c1 e0 02             	shl    $0x2,%eax
c0100cac:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100cb1:	8b 00                	mov    (%eax),%eax
c0100cb3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100cb7:	89 04 24             	mov    %eax,(%esp)
c0100cba:	e8 ab 4a 00 00       	call   c010576a <strcmp>
c0100cbf:	85 c0                	test   %eax,%eax
c0100cc1:	75 31                	jne    c0100cf4 <runcmd+0x90>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100cc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100cc6:	89 d0                	mov    %edx,%eax
c0100cc8:	01 c0                	add    %eax,%eax
c0100cca:	01 d0                	add    %edx,%eax
c0100ccc:	c1 e0 02             	shl    $0x2,%eax
c0100ccf:	05 08 90 11 c0       	add    $0xc0119008,%eax
c0100cd4:	8b 10                	mov    (%eax),%edx
c0100cd6:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100cd9:	83 c0 04             	add    $0x4,%eax
c0100cdc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100cdf:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100ce5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ced:	89 1c 24             	mov    %ebx,(%esp)
c0100cf0:	ff d2                	call   *%edx
c0100cf2:	eb 23                	jmp    c0100d17 <runcmd+0xb3>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cf4:	ff 45 f4             	incl   -0xc(%ebp)
c0100cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cfa:	83 f8 02             	cmp    $0x2,%eax
c0100cfd:	76 9e                	jbe    c0100c9d <runcmd+0x39>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cff:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100d02:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d06:	c7 04 24 b3 64 10 c0 	movl   $0xc01064b3,(%esp)
c0100d0d:	e8 b7 f5 ff ff       	call   c01002c9 <cprintf>
    return 0;
c0100d12:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d17:	83 c4 64             	add    $0x64,%esp
c0100d1a:	5b                   	pop    %ebx
c0100d1b:	5d                   	pop    %ebp
c0100d1c:	c3                   	ret    

c0100d1d <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100d1d:	f3 0f 1e fb          	endbr32 
c0100d21:	55                   	push   %ebp
c0100d22:	89 e5                	mov    %esp,%ebp
c0100d24:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100d27:	c7 04 24 cc 64 10 c0 	movl   $0xc01064cc,(%esp)
c0100d2e:	e8 96 f5 ff ff       	call   c01002c9 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100d33:	c7 04 24 f4 64 10 c0 	movl   $0xc01064f4,(%esp)
c0100d3a:	e8 8a f5 ff ff       	call   c01002c9 <cprintf>

    if (tf != NULL) {
c0100d3f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100d43:	74 0b                	je     c0100d50 <kmonitor+0x33>
        print_trapframe(tf);
c0100d45:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d48:	89 04 24             	mov    %eax,(%esp)
c0100d4b:	e8 3f 0e 00 00       	call   c0101b8f <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d50:	c7 04 24 19 65 10 c0 	movl   $0xc0106519,(%esp)
c0100d57:	e8 20 f6 ff ff       	call   c010037c <readline>
c0100d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d63:	74 eb                	je     c0100d50 <kmonitor+0x33>
            if (runcmd(buf, tf) < 0) {
c0100d65:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d68:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d6f:	89 04 24             	mov    %eax,(%esp)
c0100d72:	e8 ed fe ff ff       	call   c0100c64 <runcmd>
c0100d77:	85 c0                	test   %eax,%eax
c0100d79:	78 02                	js     c0100d7d <kmonitor+0x60>
        if ((buf = readline("K> ")) != NULL) {
c0100d7b:	eb d3                	jmp    c0100d50 <kmonitor+0x33>
                break;
c0100d7d:	90                   	nop
            }
        }
    }
}
c0100d7e:	90                   	nop
c0100d7f:	c9                   	leave  
c0100d80:	c3                   	ret    

c0100d81 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d81:	f3 0f 1e fb          	endbr32 
c0100d85:	55                   	push   %ebp
c0100d86:	89 e5                	mov    %esp,%ebp
c0100d88:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d92:	eb 3d                	jmp    c0100dd1 <mon_help+0x50>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d94:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d97:	89 d0                	mov    %edx,%eax
c0100d99:	01 c0                	add    %eax,%eax
c0100d9b:	01 d0                	add    %edx,%eax
c0100d9d:	c1 e0 02             	shl    $0x2,%eax
c0100da0:	05 04 90 11 c0       	add    $0xc0119004,%eax
c0100da5:	8b 08                	mov    (%eax),%ecx
c0100da7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100daa:	89 d0                	mov    %edx,%eax
c0100dac:	01 c0                	add    %eax,%eax
c0100dae:	01 d0                	add    %edx,%eax
c0100db0:	c1 e0 02             	shl    $0x2,%eax
c0100db3:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100db8:	8b 00                	mov    (%eax),%eax
c0100dba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100dbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100dc2:	c7 04 24 1d 65 10 c0 	movl   $0xc010651d,(%esp)
c0100dc9:	e8 fb f4 ff ff       	call   c01002c9 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100dce:	ff 45 f4             	incl   -0xc(%ebp)
c0100dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100dd4:	83 f8 02             	cmp    $0x2,%eax
c0100dd7:	76 bb                	jbe    c0100d94 <mon_help+0x13>
    }
    return 0;
c0100dd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dde:	c9                   	leave  
c0100ddf:	c3                   	ret    

c0100de0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100de0:	f3 0f 1e fb          	endbr32 
c0100de4:	55                   	push   %ebp
c0100de5:	89 e5                	mov    %esp,%ebp
c0100de7:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100dea:	e8 9d fb ff ff       	call   c010098c <print_kerninfo>
    return 0;
c0100def:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100df4:	c9                   	leave  
c0100df5:	c3                   	ret    

c0100df6 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100df6:	f3 0f 1e fb          	endbr32 
c0100dfa:	55                   	push   %ebp
c0100dfb:	89 e5                	mov    %esp,%ebp
c0100dfd:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100e00:	e8 d9 fc ff ff       	call   c0100ade <print_stackframe>
    return 0;
c0100e05:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e0a:	c9                   	leave  
c0100e0b:	c3                   	ret    

c0100e0c <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100e0c:	f3 0f 1e fb          	endbr32 
c0100e10:	55                   	push   %ebp
c0100e11:	89 e5                	mov    %esp,%ebp
c0100e13:	83 ec 28             	sub    $0x28,%esp
c0100e16:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100e1c:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e20:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100e24:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100e28:	ee                   	out    %al,(%dx)
}
c0100e29:	90                   	nop
c0100e2a:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100e30:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e34:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100e38:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100e3c:	ee                   	out    %al,(%dx)
}
c0100e3d:	90                   	nop
c0100e3e:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100e44:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e48:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100e4c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100e50:	ee                   	out    %al,(%dx)
}
c0100e51:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100e52:	c7 05 0c cf 11 c0 00 	movl   $0x0,0xc011cf0c
c0100e59:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e5c:	c7 04 24 26 65 10 c0 	movl   $0xc0106526,(%esp)
c0100e63:	e8 61 f4 ff ff       	call   c01002c9 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e6f:	e8 95 09 00 00       	call   c0101809 <pic_enable>
}
c0100e74:	90                   	nop
c0100e75:	c9                   	leave  
c0100e76:	c3                   	ret    

c0100e77 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e77:	55                   	push   %ebp
c0100e78:	89 e5                	mov    %esp,%ebp
c0100e7a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e7d:	9c                   	pushf  
c0100e7e:	58                   	pop    %eax
c0100e7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e85:	25 00 02 00 00       	and    $0x200,%eax
c0100e8a:	85 c0                	test   %eax,%eax
c0100e8c:	74 0c                	je     c0100e9a <__intr_save+0x23>
        intr_disable();
c0100e8e:	e8 05 0b 00 00       	call   c0101998 <intr_disable>
        return 1;
c0100e93:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e98:	eb 05                	jmp    c0100e9f <__intr_save+0x28>
    }
    return 0;
c0100e9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e9f:	c9                   	leave  
c0100ea0:	c3                   	ret    

c0100ea1 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100ea1:	55                   	push   %ebp
c0100ea2:	89 e5                	mov    %esp,%ebp
c0100ea4:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100ea7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100eab:	74 05                	je     c0100eb2 <__intr_restore+0x11>
        intr_enable();
c0100ead:	e8 da 0a 00 00       	call   c010198c <intr_enable>
    }
}
c0100eb2:	90                   	nop
c0100eb3:	c9                   	leave  
c0100eb4:	c3                   	ret    

c0100eb5 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100eb5:	f3 0f 1e fb          	endbr32 
c0100eb9:	55                   	push   %ebp
c0100eba:	89 e5                	mov    %esp,%ebp
c0100ebc:	83 ec 10             	sub    $0x10,%esp
c0100ebf:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ec5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100ec9:	89 c2                	mov    %eax,%edx
c0100ecb:	ec                   	in     (%dx),%al
c0100ecc:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100ecf:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100ed5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ed9:	89 c2                	mov    %eax,%edx
c0100edb:	ec                   	in     (%dx),%al
c0100edc:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100edf:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100ee5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100ee9:	89 c2                	mov    %eax,%edx
c0100eeb:	ec                   	in     (%dx),%al
c0100eec:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100eef:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100ef5:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100ef9:	89 c2                	mov    %eax,%edx
c0100efb:	ec                   	in     (%dx),%al
c0100efc:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100eff:	90                   	nop
c0100f00:	c9                   	leave  
c0100f01:	c3                   	ret    

c0100f02 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100f02:	f3 0f 1e fb          	endbr32 
c0100f06:	55                   	push   %ebp
c0100f07:	89 e5                	mov    %esp,%ebp
c0100f09:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100f0c:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100f13:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f16:	0f b7 00             	movzwl (%eax),%eax
c0100f19:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100f1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f20:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100f25:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f28:	0f b7 00             	movzwl (%eax),%eax
c0100f2b:	0f b7 c0             	movzwl %ax,%eax
c0100f2e:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100f33:	74 12                	je     c0100f47 <cga_init+0x45>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100f35:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100f3c:	66 c7 05 46 c4 11 c0 	movw   $0x3b4,0xc011c446
c0100f43:	b4 03 
c0100f45:	eb 13                	jmp    c0100f5a <cga_init+0x58>
    } else {
        *cp = was;
c0100f47:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f4a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100f4e:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100f51:	66 c7 05 46 c4 11 c0 	movw   $0x3d4,0xc011c446
c0100f58:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f5a:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f61:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f65:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f69:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f6d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f71:	ee                   	out    %al,(%dx)
}
c0100f72:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f73:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f7a:	40                   	inc    %eax
c0100f7b:	0f b7 c0             	movzwl %ax,%eax
c0100f7e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f82:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f86:	89 c2                	mov    %eax,%edx
c0100f88:	ec                   	in     (%dx),%al
c0100f89:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f8c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f90:	0f b6 c0             	movzbl %al,%eax
c0100f93:	c1 e0 08             	shl    $0x8,%eax
c0100f96:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f99:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100fa0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100fa4:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fa8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100fac:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fb0:	ee                   	out    %al,(%dx)
}
c0100fb1:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100fb2:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100fb9:	40                   	inc    %eax
c0100fba:	0f b7 c0             	movzwl %ax,%eax
c0100fbd:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100fc1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100fc5:	89 c2                	mov    %eax,%edx
c0100fc7:	ec                   	in     (%dx),%al
c0100fc8:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100fcb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100fcf:	0f b6 c0             	movzbl %al,%eax
c0100fd2:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100fd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100fd8:	a3 40 c4 11 c0       	mov    %eax,0xc011c440
    crt_pos = pos;
c0100fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100fe0:	0f b7 c0             	movzwl %ax,%eax
c0100fe3:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
}
c0100fe9:	90                   	nop
c0100fea:	c9                   	leave  
c0100feb:	c3                   	ret    

c0100fec <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100fec:	f3 0f 1e fb          	endbr32 
c0100ff0:	55                   	push   %ebp
c0100ff1:	89 e5                	mov    %esp,%ebp
c0100ff3:	83 ec 48             	sub    $0x48,%esp
c0100ff6:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100ffc:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101000:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101004:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101008:	ee                   	out    %al,(%dx)
}
c0101009:	90                   	nop
c010100a:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0101010:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101014:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101018:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c010101c:	ee                   	out    %al,(%dx)
}
c010101d:	90                   	nop
c010101e:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0101024:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101028:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010102c:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0101030:	ee                   	out    %al,(%dx)
}
c0101031:	90                   	nop
c0101032:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0101038:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010103c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101040:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101044:	ee                   	out    %al,(%dx)
}
c0101045:	90                   	nop
c0101046:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c010104c:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101050:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101054:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101058:	ee                   	out    %al,(%dx)
}
c0101059:	90                   	nop
c010105a:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0101060:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101064:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101068:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c010106c:	ee                   	out    %al,(%dx)
}
c010106d:	90                   	nop
c010106e:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0101074:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101078:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010107c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101080:	ee                   	out    %al,(%dx)
}
c0101081:	90                   	nop
c0101082:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101088:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c010108c:	89 c2                	mov    %eax,%edx
c010108e:	ec                   	in     (%dx),%al
c010108f:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101092:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101096:	3c ff                	cmp    $0xff,%al
c0101098:	0f 95 c0             	setne  %al
c010109b:	0f b6 c0             	movzbl %al,%eax
c010109e:	a3 48 c4 11 c0       	mov    %eax,0xc011c448
c01010a3:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01010a9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01010ad:	89 c2                	mov    %eax,%edx
c01010af:	ec                   	in     (%dx),%al
c01010b0:	88 45 f1             	mov    %al,-0xf(%ebp)
c01010b3:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01010b9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010bd:	89 c2                	mov    %eax,%edx
c01010bf:	ec                   	in     (%dx),%al
c01010c0:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c01010c3:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c01010c8:	85 c0                	test   %eax,%eax
c01010ca:	74 0c                	je     c01010d8 <serial_init+0xec>
        pic_enable(IRQ_COM1);
c01010cc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01010d3:	e8 31 07 00 00       	call   c0101809 <pic_enable>
    }
}
c01010d8:	90                   	nop
c01010d9:	c9                   	leave  
c01010da:	c3                   	ret    

c01010db <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01010db:	f3 0f 1e fb          	endbr32 
c01010df:	55                   	push   %ebp
c01010e0:	89 e5                	mov    %esp,%ebp
c01010e2:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01010ec:	eb 08                	jmp    c01010f6 <lpt_putc_sub+0x1b>
        delay();
c01010ee:	e8 c2 fd ff ff       	call   c0100eb5 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01010f3:	ff 45 fc             	incl   -0x4(%ebp)
c01010f6:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010fc:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101100:	89 c2                	mov    %eax,%edx
c0101102:	ec                   	in     (%dx),%al
c0101103:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101106:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010110a:	84 c0                	test   %al,%al
c010110c:	78 09                	js     c0101117 <lpt_putc_sub+0x3c>
c010110e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101115:	7e d7                	jle    c01010ee <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
c0101117:	8b 45 08             	mov    0x8(%ebp),%eax
c010111a:	0f b6 c0             	movzbl %al,%eax
c010111d:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c0101123:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101126:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c010112a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010112e:	ee                   	out    %al,(%dx)
}
c010112f:	90                   	nop
c0101130:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c0101136:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010113a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010113e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101142:	ee                   	out    %al,(%dx)
}
c0101143:	90                   	nop
c0101144:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c010114a:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010114e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0101152:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101156:	ee                   	out    %al,(%dx)
}
c0101157:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101158:	90                   	nop
c0101159:	c9                   	leave  
c010115a:	c3                   	ret    

c010115b <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c010115b:	f3 0f 1e fb          	endbr32 
c010115f:	55                   	push   %ebp
c0101160:	89 e5                	mov    %esp,%ebp
c0101162:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101165:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101169:	74 0d                	je     c0101178 <lpt_putc+0x1d>
        lpt_putc_sub(c);
c010116b:	8b 45 08             	mov    0x8(%ebp),%eax
c010116e:	89 04 24             	mov    %eax,(%esp)
c0101171:	e8 65 ff ff ff       	call   c01010db <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101176:	eb 24                	jmp    c010119c <lpt_putc+0x41>
        lpt_putc_sub('\b');
c0101178:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010117f:	e8 57 ff ff ff       	call   c01010db <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101184:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010118b:	e8 4b ff ff ff       	call   c01010db <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101190:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101197:	e8 3f ff ff ff       	call   c01010db <lpt_putc_sub>
}
c010119c:	90                   	nop
c010119d:	c9                   	leave  
c010119e:	c3                   	ret    

c010119f <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c010119f:	f3 0f 1e fb          	endbr32 
c01011a3:	55                   	push   %ebp
c01011a4:	89 e5                	mov    %esp,%ebp
c01011a6:	53                   	push   %ebx
c01011a7:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01011aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01011ad:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011b2:	85 c0                	test   %eax,%eax
c01011b4:	75 07                	jne    c01011bd <cga_putc+0x1e>
        c |= 0x0700;
c01011b6:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c01011bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01011c0:	0f b6 c0             	movzbl %al,%eax
c01011c3:	83 f8 0d             	cmp    $0xd,%eax
c01011c6:	74 72                	je     c010123a <cga_putc+0x9b>
c01011c8:	83 f8 0d             	cmp    $0xd,%eax
c01011cb:	0f 8f a3 00 00 00    	jg     c0101274 <cga_putc+0xd5>
c01011d1:	83 f8 08             	cmp    $0x8,%eax
c01011d4:	74 0a                	je     c01011e0 <cga_putc+0x41>
c01011d6:	83 f8 0a             	cmp    $0xa,%eax
c01011d9:	74 4c                	je     c0101227 <cga_putc+0x88>
c01011db:	e9 94 00 00 00       	jmp    c0101274 <cga_putc+0xd5>
    case '\b':
        if (crt_pos > 0) {
c01011e0:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011e7:	85 c0                	test   %eax,%eax
c01011e9:	0f 84 af 00 00 00    	je     c010129e <cga_putc+0xff>
            crt_pos --;
c01011ef:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011f6:	48                   	dec    %eax
c01011f7:	0f b7 c0             	movzwl %ax,%eax
c01011fa:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101200:	8b 45 08             	mov    0x8(%ebp),%eax
c0101203:	98                   	cwtl   
c0101204:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101209:	98                   	cwtl   
c010120a:	83 c8 20             	or     $0x20,%eax
c010120d:	98                   	cwtl   
c010120e:	8b 15 40 c4 11 c0    	mov    0xc011c440,%edx
c0101214:	0f b7 0d 44 c4 11 c0 	movzwl 0xc011c444,%ecx
c010121b:	01 c9                	add    %ecx,%ecx
c010121d:	01 ca                	add    %ecx,%edx
c010121f:	0f b7 c0             	movzwl %ax,%eax
c0101222:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101225:	eb 77                	jmp    c010129e <cga_putc+0xff>
    case '\n':
        crt_pos += CRT_COLS;
c0101227:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010122e:	83 c0 50             	add    $0x50,%eax
c0101231:	0f b7 c0             	movzwl %ax,%eax
c0101234:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010123a:	0f b7 1d 44 c4 11 c0 	movzwl 0xc011c444,%ebx
c0101241:	0f b7 0d 44 c4 11 c0 	movzwl 0xc011c444,%ecx
c0101248:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c010124d:	89 c8                	mov    %ecx,%eax
c010124f:	f7 e2                	mul    %edx
c0101251:	c1 ea 06             	shr    $0x6,%edx
c0101254:	89 d0                	mov    %edx,%eax
c0101256:	c1 e0 02             	shl    $0x2,%eax
c0101259:	01 d0                	add    %edx,%eax
c010125b:	c1 e0 04             	shl    $0x4,%eax
c010125e:	29 c1                	sub    %eax,%ecx
c0101260:	89 c8                	mov    %ecx,%eax
c0101262:	0f b7 c0             	movzwl %ax,%eax
c0101265:	29 c3                	sub    %eax,%ebx
c0101267:	89 d8                	mov    %ebx,%eax
c0101269:	0f b7 c0             	movzwl %ax,%eax
c010126c:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
        break;
c0101272:	eb 2b                	jmp    c010129f <cga_putc+0x100>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101274:	8b 0d 40 c4 11 c0    	mov    0xc011c440,%ecx
c010127a:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101281:	8d 50 01             	lea    0x1(%eax),%edx
c0101284:	0f b7 d2             	movzwl %dx,%edx
c0101287:	66 89 15 44 c4 11 c0 	mov    %dx,0xc011c444
c010128e:	01 c0                	add    %eax,%eax
c0101290:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101293:	8b 45 08             	mov    0x8(%ebp),%eax
c0101296:	0f b7 c0             	movzwl %ax,%eax
c0101299:	66 89 02             	mov    %ax,(%edx)
        break;
c010129c:	eb 01                	jmp    c010129f <cga_putc+0x100>
        break;
c010129e:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c010129f:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01012a6:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c01012ab:	76 5d                	jbe    c010130a <cga_putc+0x16b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01012ad:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c01012b2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01012b8:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c01012bd:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c01012c4:	00 
c01012c5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01012c9:	89 04 24             	mov    %eax,(%esp)
c01012cc:	e8 42 47 00 00       	call   c0105a13 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012d1:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c01012d8:	eb 14                	jmp    c01012ee <cga_putc+0x14f>
            crt_buf[i] = 0x0700 | ' ';
c01012da:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c01012df:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01012e2:	01 d2                	add    %edx,%edx
c01012e4:	01 d0                	add    %edx,%eax
c01012e6:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c01012eb:	ff 45 f4             	incl   -0xc(%ebp)
c01012ee:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c01012f5:	7e e3                	jle    c01012da <cga_putc+0x13b>
        }
        crt_pos -= CRT_COLS;
c01012f7:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01012fe:	83 e8 50             	sub    $0x50,%eax
c0101301:	0f b7 c0             	movzwl %ax,%eax
c0101304:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010130a:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0101311:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0101315:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101319:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010131d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101321:	ee                   	out    %al,(%dx)
}
c0101322:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c0101323:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010132a:	c1 e8 08             	shr    $0x8,%eax
c010132d:	0f b7 c0             	movzwl %ax,%eax
c0101330:	0f b6 c0             	movzbl %al,%eax
c0101333:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c010133a:	42                   	inc    %edx
c010133b:	0f b7 d2             	movzwl %dx,%edx
c010133e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c0101342:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101345:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101349:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010134d:	ee                   	out    %al,(%dx)
}
c010134e:	90                   	nop
    outb(addr_6845, 15);
c010134f:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0101356:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010135a:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010135e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101362:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101366:	ee                   	out    %al,(%dx)
}
c0101367:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c0101368:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010136f:	0f b6 c0             	movzbl %al,%eax
c0101372:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c0101379:	42                   	inc    %edx
c010137a:	0f b7 d2             	movzwl %dx,%edx
c010137d:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101381:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101384:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101388:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010138c:	ee                   	out    %al,(%dx)
}
c010138d:	90                   	nop
}
c010138e:	90                   	nop
c010138f:	83 c4 34             	add    $0x34,%esp
c0101392:	5b                   	pop    %ebx
c0101393:	5d                   	pop    %ebp
c0101394:	c3                   	ret    

c0101395 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101395:	f3 0f 1e fb          	endbr32 
c0101399:	55                   	push   %ebp
c010139a:	89 e5                	mov    %esp,%ebp
c010139c:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010139f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01013a6:	eb 08                	jmp    c01013b0 <serial_putc_sub+0x1b>
        delay();
c01013a8:	e8 08 fb ff ff       	call   c0100eb5 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01013ad:	ff 45 fc             	incl   -0x4(%ebp)
c01013b0:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013b6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013ba:	89 c2                	mov    %eax,%edx
c01013bc:	ec                   	in     (%dx),%al
c01013bd:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01013c0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01013c4:	0f b6 c0             	movzbl %al,%eax
c01013c7:	83 e0 20             	and    $0x20,%eax
c01013ca:	85 c0                	test   %eax,%eax
c01013cc:	75 09                	jne    c01013d7 <serial_putc_sub+0x42>
c01013ce:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01013d5:	7e d1                	jle    c01013a8 <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
c01013d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01013da:	0f b6 c0             	movzbl %al,%eax
c01013dd:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c01013e3:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01013e6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01013ea:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01013ee:	ee                   	out    %al,(%dx)
}
c01013ef:	90                   	nop
}
c01013f0:	90                   	nop
c01013f1:	c9                   	leave  
c01013f2:	c3                   	ret    

c01013f3 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c01013f3:	f3 0f 1e fb          	endbr32 
c01013f7:	55                   	push   %ebp
c01013f8:	89 e5                	mov    %esp,%ebp
c01013fa:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01013fd:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101401:	74 0d                	je     c0101410 <serial_putc+0x1d>
        serial_putc_sub(c);
c0101403:	8b 45 08             	mov    0x8(%ebp),%eax
c0101406:	89 04 24             	mov    %eax,(%esp)
c0101409:	e8 87 ff ff ff       	call   c0101395 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c010140e:	eb 24                	jmp    c0101434 <serial_putc+0x41>
        serial_putc_sub('\b');
c0101410:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101417:	e8 79 ff ff ff       	call   c0101395 <serial_putc_sub>
        serial_putc_sub(' ');
c010141c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101423:	e8 6d ff ff ff       	call   c0101395 <serial_putc_sub>
        serial_putc_sub('\b');
c0101428:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010142f:	e8 61 ff ff ff       	call   c0101395 <serial_putc_sub>
}
c0101434:	90                   	nop
c0101435:	c9                   	leave  
c0101436:	c3                   	ret    

c0101437 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101437:	f3 0f 1e fb          	endbr32 
c010143b:	55                   	push   %ebp
c010143c:	89 e5                	mov    %esp,%ebp
c010143e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101441:	eb 33                	jmp    c0101476 <cons_intr+0x3f>
        if (c != 0) {
c0101443:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101447:	74 2d                	je     c0101476 <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
c0101449:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c010144e:	8d 50 01             	lea    0x1(%eax),%edx
c0101451:	89 15 64 c6 11 c0    	mov    %edx,0xc011c664
c0101457:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010145a:	88 90 60 c4 11 c0    	mov    %dl,-0x3fee3ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101460:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101465:	3d 00 02 00 00       	cmp    $0x200,%eax
c010146a:	75 0a                	jne    c0101476 <cons_intr+0x3f>
                cons.wpos = 0;
c010146c:	c7 05 64 c6 11 c0 00 	movl   $0x0,0xc011c664
c0101473:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101476:	8b 45 08             	mov    0x8(%ebp),%eax
c0101479:	ff d0                	call   *%eax
c010147b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010147e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101482:	75 bf                	jne    c0101443 <cons_intr+0xc>
            }
        }
    }
}
c0101484:	90                   	nop
c0101485:	90                   	nop
c0101486:	c9                   	leave  
c0101487:	c3                   	ret    

c0101488 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101488:	f3 0f 1e fb          	endbr32 
c010148c:	55                   	push   %ebp
c010148d:	89 e5                	mov    %esp,%ebp
c010148f:	83 ec 10             	sub    $0x10,%esp
c0101492:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101498:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010149c:	89 c2                	mov    %eax,%edx
c010149e:	ec                   	in     (%dx),%al
c010149f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01014a2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01014a6:	0f b6 c0             	movzbl %al,%eax
c01014a9:	83 e0 01             	and    $0x1,%eax
c01014ac:	85 c0                	test   %eax,%eax
c01014ae:	75 07                	jne    c01014b7 <serial_proc_data+0x2f>
        return -1;
c01014b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014b5:	eb 2a                	jmp    c01014e1 <serial_proc_data+0x59>
c01014b7:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014bd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01014c1:	89 c2                	mov    %eax,%edx
c01014c3:	ec                   	in     (%dx),%al
c01014c4:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c01014c7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01014cb:	0f b6 c0             	movzbl %al,%eax
c01014ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01014d1:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c01014d5:	75 07                	jne    c01014de <serial_proc_data+0x56>
        c = '\b';
c01014d7:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c01014de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01014e1:	c9                   	leave  
c01014e2:	c3                   	ret    

c01014e3 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c01014e3:	f3 0f 1e fb          	endbr32 
c01014e7:	55                   	push   %ebp
c01014e8:	89 e5                	mov    %esp,%ebp
c01014ea:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c01014ed:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c01014f2:	85 c0                	test   %eax,%eax
c01014f4:	74 0c                	je     c0101502 <serial_intr+0x1f>
        cons_intr(serial_proc_data);
c01014f6:	c7 04 24 88 14 10 c0 	movl   $0xc0101488,(%esp)
c01014fd:	e8 35 ff ff ff       	call   c0101437 <cons_intr>
    }
}
c0101502:	90                   	nop
c0101503:	c9                   	leave  
c0101504:	c3                   	ret    

c0101505 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101505:	f3 0f 1e fb          	endbr32 
c0101509:	55                   	push   %ebp
c010150a:	89 e5                	mov    %esp,%ebp
c010150c:	83 ec 38             	sub    $0x38,%esp
c010150f:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101515:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101518:	89 c2                	mov    %eax,%edx
c010151a:	ec                   	in     (%dx),%al
c010151b:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c010151e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101522:	0f b6 c0             	movzbl %al,%eax
c0101525:	83 e0 01             	and    $0x1,%eax
c0101528:	85 c0                	test   %eax,%eax
c010152a:	75 0a                	jne    c0101536 <kbd_proc_data+0x31>
        return -1;
c010152c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101531:	e9 56 01 00 00       	jmp    c010168c <kbd_proc_data+0x187>
c0101536:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010153c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010153f:	89 c2                	mov    %eax,%edx
c0101541:	ec                   	in     (%dx),%al
c0101542:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101545:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101549:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010154c:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101550:	75 17                	jne    c0101569 <kbd_proc_data+0x64>
        // E0 escape character
        shift |= E0ESC;
c0101552:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101557:	83 c8 40             	or     $0x40,%eax
c010155a:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c010155f:	b8 00 00 00 00       	mov    $0x0,%eax
c0101564:	e9 23 01 00 00       	jmp    c010168c <kbd_proc_data+0x187>
    } else if (data & 0x80) {
c0101569:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010156d:	84 c0                	test   %al,%al
c010156f:	79 45                	jns    c01015b6 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101571:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101576:	83 e0 40             	and    $0x40,%eax
c0101579:	85 c0                	test   %eax,%eax
c010157b:	75 08                	jne    c0101585 <kbd_proc_data+0x80>
c010157d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101581:	24 7f                	and    $0x7f,%al
c0101583:	eb 04                	jmp    c0101589 <kbd_proc_data+0x84>
c0101585:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101589:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c010158c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101590:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c0101597:	0c 40                	or     $0x40,%al
c0101599:	0f b6 c0             	movzbl %al,%eax
c010159c:	f7 d0                	not    %eax
c010159e:	89 c2                	mov    %eax,%edx
c01015a0:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015a5:	21 d0                	and    %edx,%eax
c01015a7:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c01015ac:	b8 00 00 00 00       	mov    $0x0,%eax
c01015b1:	e9 d6 00 00 00       	jmp    c010168c <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
c01015b6:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015bb:	83 e0 40             	and    $0x40,%eax
c01015be:	85 c0                	test   %eax,%eax
c01015c0:	74 11                	je     c01015d3 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01015c2:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01015c6:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015cb:	83 e0 bf             	and    $0xffffffbf,%eax
c01015ce:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    }

    shift |= shiftcode[data];
c01015d3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015d7:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c01015de:	0f b6 d0             	movzbl %al,%edx
c01015e1:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015e6:	09 d0                	or     %edx,%eax
c01015e8:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    shift ^= togglecode[data];
c01015ed:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015f1:	0f b6 80 40 91 11 c0 	movzbl -0x3fee6ec0(%eax),%eax
c01015f8:	0f b6 d0             	movzbl %al,%edx
c01015fb:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101600:	31 d0                	xor    %edx,%eax
c0101602:	a3 68 c6 11 c0       	mov    %eax,0xc011c668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101607:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010160c:	83 e0 03             	and    $0x3,%eax
c010160f:	8b 14 85 40 95 11 c0 	mov    -0x3fee6ac0(,%eax,4),%edx
c0101616:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010161a:	01 d0                	add    %edx,%eax
c010161c:	0f b6 00             	movzbl (%eax),%eax
c010161f:	0f b6 c0             	movzbl %al,%eax
c0101622:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101625:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010162a:	83 e0 08             	and    $0x8,%eax
c010162d:	85 c0                	test   %eax,%eax
c010162f:	74 22                	je     c0101653 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
c0101631:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101635:	7e 0c                	jle    c0101643 <kbd_proc_data+0x13e>
c0101637:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c010163b:	7f 06                	jg     c0101643 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
c010163d:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101641:	eb 10                	jmp    c0101653 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
c0101643:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101647:	7e 0a                	jle    c0101653 <kbd_proc_data+0x14e>
c0101649:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010164d:	7f 04                	jg     c0101653 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
c010164f:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101653:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101658:	f7 d0                	not    %eax
c010165a:	83 e0 06             	and    $0x6,%eax
c010165d:	85 c0                	test   %eax,%eax
c010165f:	75 28                	jne    c0101689 <kbd_proc_data+0x184>
c0101661:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101668:	75 1f                	jne    c0101689 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
c010166a:	c7 04 24 41 65 10 c0 	movl   $0xc0106541,(%esp)
c0101671:	e8 53 ec ff ff       	call   c01002c9 <cprintf>
c0101676:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c010167c:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101680:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c0101684:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101687:	ee                   	out    %al,(%dx)
}
c0101688:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101689:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010168c:	c9                   	leave  
c010168d:	c3                   	ret    

c010168e <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c010168e:	f3 0f 1e fb          	endbr32 
c0101692:	55                   	push   %ebp
c0101693:	89 e5                	mov    %esp,%ebp
c0101695:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101698:	c7 04 24 05 15 10 c0 	movl   $0xc0101505,(%esp)
c010169f:	e8 93 fd ff ff       	call   c0101437 <cons_intr>
}
c01016a4:	90                   	nop
c01016a5:	c9                   	leave  
c01016a6:	c3                   	ret    

c01016a7 <kbd_init>:

static void
kbd_init(void) {
c01016a7:	f3 0f 1e fb          	endbr32 
c01016ab:	55                   	push   %ebp
c01016ac:	89 e5                	mov    %esp,%ebp
c01016ae:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01016b1:	e8 d8 ff ff ff       	call   c010168e <kbd_intr>
    pic_enable(IRQ_KBD);
c01016b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01016bd:	e8 47 01 00 00       	call   c0101809 <pic_enable>
}
c01016c2:	90                   	nop
c01016c3:	c9                   	leave  
c01016c4:	c3                   	ret    

c01016c5 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01016c5:	f3 0f 1e fb          	endbr32 
c01016c9:	55                   	push   %ebp
c01016ca:	89 e5                	mov    %esp,%ebp
c01016cc:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01016cf:	e8 2e f8 ff ff       	call   c0100f02 <cga_init>
    serial_init();
c01016d4:	e8 13 f9 ff ff       	call   c0100fec <serial_init>
    kbd_init();
c01016d9:	e8 c9 ff ff ff       	call   c01016a7 <kbd_init>
    if (!serial_exists) {
c01016de:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c01016e3:	85 c0                	test   %eax,%eax
c01016e5:	75 0c                	jne    c01016f3 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
c01016e7:	c7 04 24 4d 65 10 c0 	movl   $0xc010654d,(%esp)
c01016ee:	e8 d6 eb ff ff       	call   c01002c9 <cprintf>
    }
}
c01016f3:	90                   	nop
c01016f4:	c9                   	leave  
c01016f5:	c3                   	ret    

c01016f6 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c01016f6:	f3 0f 1e fb          	endbr32 
c01016fa:	55                   	push   %ebp
c01016fb:	89 e5                	mov    %esp,%ebp
c01016fd:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101700:	e8 72 f7 ff ff       	call   c0100e77 <__intr_save>
c0101705:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101708:	8b 45 08             	mov    0x8(%ebp),%eax
c010170b:	89 04 24             	mov    %eax,(%esp)
c010170e:	e8 48 fa ff ff       	call   c010115b <lpt_putc>
        cga_putc(c);
c0101713:	8b 45 08             	mov    0x8(%ebp),%eax
c0101716:	89 04 24             	mov    %eax,(%esp)
c0101719:	e8 81 fa ff ff       	call   c010119f <cga_putc>
        serial_putc(c);
c010171e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101721:	89 04 24             	mov    %eax,(%esp)
c0101724:	e8 ca fc ff ff       	call   c01013f3 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101729:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010172c:	89 04 24             	mov    %eax,(%esp)
c010172f:	e8 6d f7 ff ff       	call   c0100ea1 <__intr_restore>
}
c0101734:	90                   	nop
c0101735:	c9                   	leave  
c0101736:	c3                   	ret    

c0101737 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101737:	f3 0f 1e fb          	endbr32 
c010173b:	55                   	push   %ebp
c010173c:	89 e5                	mov    %esp,%ebp
c010173e:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101748:	e8 2a f7 ff ff       	call   c0100e77 <__intr_save>
c010174d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101750:	e8 8e fd ff ff       	call   c01014e3 <serial_intr>
        kbd_intr();
c0101755:	e8 34 ff ff ff       	call   c010168e <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c010175a:	8b 15 60 c6 11 c0    	mov    0xc011c660,%edx
c0101760:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101765:	39 c2                	cmp    %eax,%edx
c0101767:	74 31                	je     c010179a <cons_getc+0x63>
            c = cons.buf[cons.rpos ++];
c0101769:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c010176e:	8d 50 01             	lea    0x1(%eax),%edx
c0101771:	89 15 60 c6 11 c0    	mov    %edx,0xc011c660
c0101777:	0f b6 80 60 c4 11 c0 	movzbl -0x3fee3ba0(%eax),%eax
c010177e:	0f b6 c0             	movzbl %al,%eax
c0101781:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101784:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c0101789:	3d 00 02 00 00       	cmp    $0x200,%eax
c010178e:	75 0a                	jne    c010179a <cons_getc+0x63>
                cons.rpos = 0;
c0101790:	c7 05 60 c6 11 c0 00 	movl   $0x0,0xc011c660
c0101797:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c010179a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010179d:	89 04 24             	mov    %eax,(%esp)
c01017a0:	e8 fc f6 ff ff       	call   c0100ea1 <__intr_restore>
    return c;
c01017a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01017a8:	c9                   	leave  
c01017a9:	c3                   	ret    

c01017aa <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01017aa:	f3 0f 1e fb          	endbr32 
c01017ae:	55                   	push   %ebp
c01017af:	89 e5                	mov    %esp,%ebp
c01017b1:	83 ec 14             	sub    $0x14,%esp
c01017b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01017b7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01017bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01017be:	66 a3 50 95 11 c0    	mov    %ax,0xc0119550
    if (did_init) {
c01017c4:	a1 6c c6 11 c0       	mov    0xc011c66c,%eax
c01017c9:	85 c0                	test   %eax,%eax
c01017cb:	74 39                	je     c0101806 <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
c01017cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01017d0:	0f b6 c0             	movzbl %al,%eax
c01017d3:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c01017d9:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017dc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01017e0:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01017e4:	ee                   	out    %al,(%dx)
}
c01017e5:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c01017e6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01017ea:	c1 e8 08             	shr    $0x8,%eax
c01017ed:	0f b7 c0             	movzwl %ax,%eax
c01017f0:	0f b6 c0             	movzbl %al,%eax
c01017f3:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c01017f9:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017fc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101800:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101804:	ee                   	out    %al,(%dx)
}
c0101805:	90                   	nop
    }
}
c0101806:	90                   	nop
c0101807:	c9                   	leave  
c0101808:	c3                   	ret    

c0101809 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101809:	f3 0f 1e fb          	endbr32 
c010180d:	55                   	push   %ebp
c010180e:	89 e5                	mov    %esp,%ebp
c0101810:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101813:	8b 45 08             	mov    0x8(%ebp),%eax
c0101816:	ba 01 00 00 00       	mov    $0x1,%edx
c010181b:	88 c1                	mov    %al,%cl
c010181d:	d3 e2                	shl    %cl,%edx
c010181f:	89 d0                	mov    %edx,%eax
c0101821:	98                   	cwtl   
c0101822:	f7 d0                	not    %eax
c0101824:	0f bf d0             	movswl %ax,%edx
c0101827:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c010182e:	98                   	cwtl   
c010182f:	21 d0                	and    %edx,%eax
c0101831:	98                   	cwtl   
c0101832:	0f b7 c0             	movzwl %ax,%eax
c0101835:	89 04 24             	mov    %eax,(%esp)
c0101838:	e8 6d ff ff ff       	call   c01017aa <pic_setmask>
}
c010183d:	90                   	nop
c010183e:	c9                   	leave  
c010183f:	c3                   	ret    

c0101840 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101840:	f3 0f 1e fb          	endbr32 
c0101844:	55                   	push   %ebp
c0101845:	89 e5                	mov    %esp,%ebp
c0101847:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c010184a:	c7 05 6c c6 11 c0 01 	movl   $0x1,0xc011c66c
c0101851:	00 00 00 
c0101854:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c010185a:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010185e:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0101862:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c0101866:	ee                   	out    %al,(%dx)
}
c0101867:	90                   	nop
c0101868:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c010186e:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101872:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c0101876:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c010187a:	ee                   	out    %al,(%dx)
}
c010187b:	90                   	nop
c010187c:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101882:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101886:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c010188a:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c010188e:	ee                   	out    %al,(%dx)
}
c010188f:	90                   	nop
c0101890:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c0101896:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010189a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c010189e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c01018a2:	ee                   	out    %al,(%dx)
}
c01018a3:	90                   	nop
c01018a4:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c01018aa:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018ae:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01018b2:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c01018b6:	ee                   	out    %al,(%dx)
}
c01018b7:	90                   	nop
c01018b8:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c01018be:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018c2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01018c6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c01018ca:	ee                   	out    %al,(%dx)
}
c01018cb:	90                   	nop
c01018cc:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c01018d2:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018d6:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01018da:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c01018de:	ee                   	out    %al,(%dx)
}
c01018df:	90                   	nop
c01018e0:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c01018e6:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018ea:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01018ee:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01018f2:	ee                   	out    %al,(%dx)
}
c01018f3:	90                   	nop
c01018f4:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c01018fa:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018fe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101902:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101906:	ee                   	out    %al,(%dx)
}
c0101907:	90                   	nop
c0101908:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010190e:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101912:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101916:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010191a:	ee                   	out    %al,(%dx)
}
c010191b:	90                   	nop
c010191c:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c0101922:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101926:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010192a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010192e:	ee                   	out    %al,(%dx)
}
c010192f:	90                   	nop
c0101930:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c0101936:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010193a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010193e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0101942:	ee                   	out    %al,(%dx)
}
c0101943:	90                   	nop
c0101944:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c010194a:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010194e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101952:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101956:	ee                   	out    %al,(%dx)
}
c0101957:	90                   	nop
c0101958:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c010195e:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101962:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c0101966:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010196a:	ee                   	out    %al,(%dx)
}
c010196b:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c010196c:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c0101973:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101978:	74 0f                	je     c0101989 <pic_init+0x149>
        pic_setmask(irq_mask);
c010197a:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c0101981:	89 04 24             	mov    %eax,(%esp)
c0101984:	e8 21 fe ff ff       	call   c01017aa <pic_setmask>
    }
}
c0101989:	90                   	nop
c010198a:	c9                   	leave  
c010198b:	c3                   	ret    

c010198c <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c010198c:	f3 0f 1e fb          	endbr32 
c0101990:	55                   	push   %ebp
c0101991:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c0101993:	fb                   	sti    
}
c0101994:	90                   	nop
    sti();
}
c0101995:	90                   	nop
c0101996:	5d                   	pop    %ebp
c0101997:	c3                   	ret    

c0101998 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101998:	f3 0f 1e fb          	endbr32 
c010199c:	55                   	push   %ebp
c010199d:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c010199f:	fa                   	cli    
}
c01019a0:	90                   	nop
    cli();
}
c01019a1:	90                   	nop
c01019a2:	5d                   	pop    %ebp
c01019a3:	c3                   	ret    

c01019a4 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01019a4:	f3 0f 1e fb          	endbr32 
c01019a8:	55                   	push   %ebp
c01019a9:	89 e5                	mov    %esp,%ebp
c01019ab:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01019ae:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01019b5:	00 
c01019b6:	c7 04 24 80 65 10 c0 	movl   $0xc0106580,(%esp)
c01019bd:	e8 07 e9 ff ff       	call   c01002c9 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01019c2:	90                   	nop
c01019c3:	c9                   	leave  
c01019c4:	c3                   	ret    

c01019c5 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01019c5:	f3 0f 1e fb          	endbr32 
c01019c9:	55                   	push   %ebp
c01019ca:	89 e5                	mov    %esp,%ebp
c01019cc:	83 ec 10             	sub    $0x10,%esp
           (try "make" command in lab1, then you will find vector.S in kern/trap DIR)
           You can use  "extern uintptr_t __vectors[];" to define this extern variable which will be used later. */
    extern uintptr_t __vectors[];
    /* (2) Now you should setup the entries of ISR in Interrupt Description Table (IDT).
           Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT */
    int idt_size = sizeof(idt) / sizeof(struct gatedesc);
c01019cf:	c7 45 f8 00 01 00 00 	movl   $0x100,-0x8(%ebp)
    for (int i = 0; i < idt_size; ++i) {
c01019d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01019dd:	e9 c4 00 00 00       	jmp    c0101aa6 <idt_init+0xe1>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01019e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019e5:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c01019ec:	0f b7 d0             	movzwl %ax,%edx
c01019ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019f2:	66 89 14 c5 80 c6 11 	mov    %dx,-0x3fee3980(,%eax,8)
c01019f9:	c0 
c01019fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019fd:	66 c7 04 c5 82 c6 11 	movw   $0x8,-0x3fee397e(,%eax,8)
c0101a04:	c0 08 00 
c0101a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a0a:	0f b6 14 c5 84 c6 11 	movzbl -0x3fee397c(,%eax,8),%edx
c0101a11:	c0 
c0101a12:	80 e2 e0             	and    $0xe0,%dl
c0101a15:	88 14 c5 84 c6 11 c0 	mov    %dl,-0x3fee397c(,%eax,8)
c0101a1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a1f:	0f b6 14 c5 84 c6 11 	movzbl -0x3fee397c(,%eax,8),%edx
c0101a26:	c0 
c0101a27:	80 e2 1f             	and    $0x1f,%dl
c0101a2a:	88 14 c5 84 c6 11 c0 	mov    %dl,-0x3fee397c(,%eax,8)
c0101a31:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a34:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101a3b:	c0 
c0101a3c:	80 e2 f0             	and    $0xf0,%dl
c0101a3f:	80 ca 0e             	or     $0xe,%dl
c0101a42:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101a49:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a4c:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101a53:	c0 
c0101a54:	80 e2 ef             	and    $0xef,%dl
c0101a57:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101a5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a61:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101a68:	c0 
c0101a69:	80 e2 9f             	and    $0x9f,%dl
c0101a6c:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101a73:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a76:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101a7d:	c0 
c0101a7e:	80 ca 80             	or     $0x80,%dl
c0101a81:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101a88:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a8b:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c0101a92:	c1 e8 10             	shr    $0x10,%eax
c0101a95:	0f b7 d0             	movzwl %ax,%edx
c0101a98:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a9b:	66 89 14 c5 86 c6 11 	mov    %dx,-0x3fee397a(,%eax,8)
c0101aa2:	c0 
    for (int i = 0; i < idt_size; ++i) {
c0101aa3:	ff 45 fc             	incl   -0x4(%ebp)
c0101aa6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101aa9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c0101aac:	0f 8c 30 ff ff ff    	jl     c01019e2 <idt_init+0x1d>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c0101ab2:	a1 c4 97 11 c0       	mov    0xc01197c4,%eax
c0101ab7:	0f b7 c0             	movzwl %ax,%eax
c0101aba:	66 a3 48 ca 11 c0    	mov    %ax,0xc011ca48
c0101ac0:	66 c7 05 4a ca 11 c0 	movw   $0x8,0xc011ca4a
c0101ac7:	08 00 
c0101ac9:	0f b6 05 4c ca 11 c0 	movzbl 0xc011ca4c,%eax
c0101ad0:	24 e0                	and    $0xe0,%al
c0101ad2:	a2 4c ca 11 c0       	mov    %al,0xc011ca4c
c0101ad7:	0f b6 05 4c ca 11 c0 	movzbl 0xc011ca4c,%eax
c0101ade:	24 1f                	and    $0x1f,%al
c0101ae0:	a2 4c ca 11 c0       	mov    %al,0xc011ca4c
c0101ae5:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101aec:	24 f0                	and    $0xf0,%al
c0101aee:	0c 0e                	or     $0xe,%al
c0101af0:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101af5:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101afc:	24 ef                	and    $0xef,%al
c0101afe:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101b03:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101b0a:	0c 60                	or     $0x60,%al
c0101b0c:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101b11:	0f b6 05 4d ca 11 c0 	movzbl 0xc011ca4d,%eax
c0101b18:	0c 80                	or     $0x80,%al
c0101b1a:	a2 4d ca 11 c0       	mov    %al,0xc011ca4d
c0101b1f:	a1 c4 97 11 c0       	mov    0xc01197c4,%eax
c0101b24:	c1 e8 10             	shr    $0x10,%eax
c0101b27:	0f b7 c0             	movzwl %ax,%eax
c0101b2a:	66 a3 4e ca 11 c0    	mov    %ax,0xc011ca4e
c0101b30:	c7 45 f4 60 95 11 c0 	movl   $0xc0119560,-0xc(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b3a:	0f 01 18             	lidtl  (%eax)
}
c0101b3d:	90                   	nop
    /* (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
           You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
           Notice: the argument of lidt is idt_pd. try to find it! */
    lidt(&idt_pd);
}
c0101b3e:	90                   	nop
c0101b3f:	c9                   	leave  
c0101b40:	c3                   	ret    

c0101b41 <trapname>:

static const char *
trapname(int trapno) {
c0101b41:	f3 0f 1e fb          	endbr32 
c0101b45:	55                   	push   %ebp
c0101b46:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101b48:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b4b:	83 f8 13             	cmp    $0x13,%eax
c0101b4e:	77 0c                	ja     c0101b5c <trapname+0x1b>
        return excnames[trapno];
c0101b50:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b53:	8b 04 85 e0 68 10 c0 	mov    -0x3fef9720(,%eax,4),%eax
c0101b5a:	eb 18                	jmp    c0101b74 <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101b5c:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101b60:	7e 0d                	jle    c0101b6f <trapname+0x2e>
c0101b62:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101b66:	7f 07                	jg     c0101b6f <trapname+0x2e>
        return "Hardware Interrupt";
c0101b68:	b8 8a 65 10 c0       	mov    $0xc010658a,%eax
c0101b6d:	eb 05                	jmp    c0101b74 <trapname+0x33>
    }
    return "(unknown trap)";
c0101b6f:	b8 9d 65 10 c0       	mov    $0xc010659d,%eax
}
c0101b74:	5d                   	pop    %ebp
c0101b75:	c3                   	ret    

c0101b76 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101b76:	f3 0f 1e fb          	endbr32 
c0101b7a:	55                   	push   %ebp
c0101b7b:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101b7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b84:	83 f8 08             	cmp    $0x8,%eax
c0101b87:	0f 94 c0             	sete   %al
c0101b8a:	0f b6 c0             	movzbl %al,%eax
}
c0101b8d:	5d                   	pop    %ebp
c0101b8e:	c3                   	ret    

c0101b8f <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101b8f:	f3 0f 1e fb          	endbr32 
c0101b93:	55                   	push   %ebp
c0101b94:	89 e5                	mov    %esp,%ebp
c0101b96:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101b99:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ba0:	c7 04 24 de 65 10 c0 	movl   $0xc01065de,(%esp)
c0101ba7:	e8 1d e7 ff ff       	call   c01002c9 <cprintf>
    print_regs(&tf->tf_regs);
c0101bac:	8b 45 08             	mov    0x8(%ebp),%eax
c0101baf:	89 04 24             	mov    %eax,(%esp)
c0101bb2:	e8 8d 01 00 00       	call   c0101d44 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101bb7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bba:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bc2:	c7 04 24 ef 65 10 c0 	movl   $0xc01065ef,(%esp)
c0101bc9:	e8 fb e6 ff ff       	call   c01002c9 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101bce:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd1:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd9:	c7 04 24 02 66 10 c0 	movl   $0xc0106602,(%esp)
c0101be0:	e8 e4 e6 ff ff       	call   c01002c9 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101be5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be8:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101bec:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bf0:	c7 04 24 15 66 10 c0 	movl   $0xc0106615,(%esp)
c0101bf7:	e8 cd e6 ff ff       	call   c01002c9 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101bfc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bff:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c07:	c7 04 24 28 66 10 c0 	movl   $0xc0106628,(%esp)
c0101c0e:	e8 b6 e6 ff ff       	call   c01002c9 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101c13:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c16:	8b 40 30             	mov    0x30(%eax),%eax
c0101c19:	89 04 24             	mov    %eax,(%esp)
c0101c1c:	e8 20 ff ff ff       	call   c0101b41 <trapname>
c0101c21:	8b 55 08             	mov    0x8(%ebp),%edx
c0101c24:	8b 52 30             	mov    0x30(%edx),%edx
c0101c27:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101c2b:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101c2f:	c7 04 24 3b 66 10 c0 	movl   $0xc010663b,(%esp)
c0101c36:	e8 8e e6 ff ff       	call   c01002c9 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101c3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c3e:	8b 40 34             	mov    0x34(%eax),%eax
c0101c41:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c45:	c7 04 24 4d 66 10 c0 	movl   $0xc010664d,(%esp)
c0101c4c:	e8 78 e6 ff ff       	call   c01002c9 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101c51:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c54:	8b 40 38             	mov    0x38(%eax),%eax
c0101c57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c5b:	c7 04 24 5c 66 10 c0 	movl   $0xc010665c,(%esp)
c0101c62:	e8 62 e6 ff ff       	call   c01002c9 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101c67:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c6a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c72:	c7 04 24 6b 66 10 c0 	movl   $0xc010666b,(%esp)
c0101c79:	e8 4b e6 ff ff       	call   c01002c9 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c81:	8b 40 40             	mov    0x40(%eax),%eax
c0101c84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c88:	c7 04 24 7e 66 10 c0 	movl   $0xc010667e,(%esp)
c0101c8f:	e8 35 e6 ff ff       	call   c01002c9 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101c9b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101ca2:	eb 3d                	jmp    c0101ce1 <print_trapframe+0x152>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ca7:	8b 50 40             	mov    0x40(%eax),%edx
c0101caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101cad:	21 d0                	and    %edx,%eax
c0101caf:	85 c0                	test   %eax,%eax
c0101cb1:	74 28                	je     c0101cdb <print_trapframe+0x14c>
c0101cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cb6:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101cbd:	85 c0                	test   %eax,%eax
c0101cbf:	74 1a                	je     c0101cdb <print_trapframe+0x14c>
            cprintf("%s,", IA32flags[i]);
c0101cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cc4:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ccf:	c7 04 24 8d 66 10 c0 	movl   $0xc010668d,(%esp)
c0101cd6:	e8 ee e5 ff ff       	call   c01002c9 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101cdb:	ff 45 f4             	incl   -0xc(%ebp)
c0101cde:	d1 65 f0             	shll   -0x10(%ebp)
c0101ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101ce4:	83 f8 17             	cmp    $0x17,%eax
c0101ce7:	76 bb                	jbe    c0101ca4 <print_trapframe+0x115>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101ce9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cec:	8b 40 40             	mov    0x40(%eax),%eax
c0101cef:	c1 e8 0c             	shr    $0xc,%eax
c0101cf2:	83 e0 03             	and    $0x3,%eax
c0101cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf9:	c7 04 24 91 66 10 c0 	movl   $0xc0106691,(%esp)
c0101d00:	e8 c4 e5 ff ff       	call   c01002c9 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101d05:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d08:	89 04 24             	mov    %eax,(%esp)
c0101d0b:	e8 66 fe ff ff       	call   c0101b76 <trap_in_kernel>
c0101d10:	85 c0                	test   %eax,%eax
c0101d12:	75 2d                	jne    c0101d41 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101d14:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d17:	8b 40 44             	mov    0x44(%eax),%eax
c0101d1a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d1e:	c7 04 24 9a 66 10 c0 	movl   $0xc010669a,(%esp)
c0101d25:	e8 9f e5 ff ff       	call   c01002c9 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101d2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d2d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101d31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d35:	c7 04 24 a9 66 10 c0 	movl   $0xc01066a9,(%esp)
c0101d3c:	e8 88 e5 ff ff       	call   c01002c9 <cprintf>
    }
}
c0101d41:	90                   	nop
c0101d42:	c9                   	leave  
c0101d43:	c3                   	ret    

c0101d44 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101d44:	f3 0f 1e fb          	endbr32 
c0101d48:	55                   	push   %ebp
c0101d49:	89 e5                	mov    %esp,%ebp
c0101d4b:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101d4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d51:	8b 00                	mov    (%eax),%eax
c0101d53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d57:	c7 04 24 bc 66 10 c0 	movl   $0xc01066bc,(%esp)
c0101d5e:	e8 66 e5 ff ff       	call   c01002c9 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101d63:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d66:	8b 40 04             	mov    0x4(%eax),%eax
c0101d69:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d6d:	c7 04 24 cb 66 10 c0 	movl   $0xc01066cb,(%esp)
c0101d74:	e8 50 e5 ff ff       	call   c01002c9 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101d79:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d7c:	8b 40 08             	mov    0x8(%eax),%eax
c0101d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d83:	c7 04 24 da 66 10 c0 	movl   $0xc01066da,(%esp)
c0101d8a:	e8 3a e5 ff ff       	call   c01002c9 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101d8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d92:	8b 40 0c             	mov    0xc(%eax),%eax
c0101d95:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d99:	c7 04 24 e9 66 10 c0 	movl   $0xc01066e9,(%esp)
c0101da0:	e8 24 e5 ff ff       	call   c01002c9 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101da5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101da8:	8b 40 10             	mov    0x10(%eax),%eax
c0101dab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101daf:	c7 04 24 f8 66 10 c0 	movl   $0xc01066f8,(%esp)
c0101db6:	e8 0e e5 ff ff       	call   c01002c9 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101dbb:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dbe:	8b 40 14             	mov    0x14(%eax),%eax
c0101dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dc5:	c7 04 24 07 67 10 c0 	movl   $0xc0106707,(%esp)
c0101dcc:	e8 f8 e4 ff ff       	call   c01002c9 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dd4:	8b 40 18             	mov    0x18(%eax),%eax
c0101dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ddb:	c7 04 24 16 67 10 c0 	movl   $0xc0106716,(%esp)
c0101de2:	e8 e2 e4 ff ff       	call   c01002c9 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101de7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dea:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101ded:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101df1:	c7 04 24 25 67 10 c0 	movl   $0xc0106725,(%esp)
c0101df8:	e8 cc e4 ff ff       	call   c01002c9 <cprintf>
}
c0101dfd:	90                   	nop
c0101dfe:	c9                   	leave  
c0101dff:	c3                   	ret    

c0101e00 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101e00:	f3 0f 1e fb          	endbr32 
c0101e04:	55                   	push   %ebp
c0101e05:	89 e5                	mov    %esp,%ebp
c0101e07:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e0d:	8b 40 30             	mov    0x30(%eax),%eax
c0101e10:	83 f8 79             	cmp    $0x79,%eax
c0101e13:	0f 84 35 01 00 00    	je     c0101f4e <trap_dispatch+0x14e>
c0101e19:	83 f8 79             	cmp    $0x79,%eax
c0101e1c:	0f 87 68 01 00 00    	ja     c0101f8a <trap_dispatch+0x18a>
c0101e22:	83 f8 78             	cmp    $0x78,%eax
c0101e25:	0f 84 da 00 00 00    	je     c0101f05 <trap_dispatch+0x105>
c0101e2b:	83 f8 78             	cmp    $0x78,%eax
c0101e2e:	0f 87 56 01 00 00    	ja     c0101f8a <trap_dispatch+0x18a>
c0101e34:	83 f8 2f             	cmp    $0x2f,%eax
c0101e37:	0f 87 4d 01 00 00    	ja     c0101f8a <trap_dispatch+0x18a>
c0101e3d:	83 f8 2e             	cmp    $0x2e,%eax
c0101e40:	0f 83 79 01 00 00    	jae    c0101fbf <trap_dispatch+0x1bf>
c0101e46:	83 f8 24             	cmp    $0x24,%eax
c0101e49:	74 68                	je     c0101eb3 <trap_dispatch+0xb3>
c0101e4b:	83 f8 24             	cmp    $0x24,%eax
c0101e4e:	0f 87 36 01 00 00    	ja     c0101f8a <trap_dispatch+0x18a>
c0101e54:	83 f8 20             	cmp    $0x20,%eax
c0101e57:	74 0a                	je     c0101e63 <trap_dispatch+0x63>
c0101e59:	83 f8 21             	cmp    $0x21,%eax
c0101e5c:	74 7e                	je     c0101edc <trap_dispatch+0xdc>
c0101e5e:	e9 27 01 00 00       	jmp    c0101f8a <trap_dispatch+0x18a>
    case IRQ_OFFSET + IRQ_TIMER:
        /* LAB1 YOUR CODE : STEP 3 */
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c */
        ticks++;
c0101e63:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0101e68:	40                   	inc    %eax
c0101e69:	a3 0c cf 11 c0       	mov    %eax,0xc011cf0c
        /* (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks(). */
        if (ticks % TICK_NUM == 0) {
c0101e6e:	8b 0d 0c cf 11 c0    	mov    0xc011cf0c,%ecx
c0101e74:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101e79:	89 c8                	mov    %ecx,%eax
c0101e7b:	f7 e2                	mul    %edx
c0101e7d:	c1 ea 05             	shr    $0x5,%edx
c0101e80:	89 d0                	mov    %edx,%eax
c0101e82:	c1 e0 02             	shl    $0x2,%eax
c0101e85:	01 d0                	add    %edx,%eax
c0101e87:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101e8e:	01 d0                	add    %edx,%eax
c0101e90:	c1 e0 02             	shl    $0x2,%eax
c0101e93:	29 c1                	sub    %eax,%ecx
c0101e95:	89 ca                	mov    %ecx,%edx
c0101e97:	85 d2                	test   %edx,%edx
c0101e99:	0f 85 23 01 00 00    	jne    c0101fc2 <trap_dispatch+0x1c2>
            print_ticks();
c0101e9f:	e8 00 fb ff ff       	call   c01019a4 <print_ticks>
            ticks = 0;
c0101ea4:	c7 05 0c cf 11 c0 00 	movl   $0x0,0xc011cf0c
c0101eab:	00 00 00 
        }
        /* (3) Too Simple? Yes, I think so! */
        break;
c0101eae:	e9 0f 01 00 00       	jmp    c0101fc2 <trap_dispatch+0x1c2>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101eb3:	e8 7f f8 ff ff       	call   c0101737 <cons_getc>
c0101eb8:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101ebb:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101ebf:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101ec3:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ecb:	c7 04 24 34 67 10 c0 	movl   $0xc0106734,(%esp)
c0101ed2:	e8 f2 e3 ff ff       	call   c01002c9 <cprintf>
        break;
c0101ed7:	e9 ed 00 00 00       	jmp    c0101fc9 <trap_dispatch+0x1c9>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101edc:	e8 56 f8 ff ff       	call   c0101737 <cons_getc>
c0101ee1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101ee4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101ee8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101eec:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ef4:	c7 04 24 46 67 10 c0 	movl   $0xc0106746,(%esp)
c0101efb:	e8 c9 e3 ff ff       	call   c01002c9 <cprintf>
        break;
c0101f00:	e9 c4 00 00 00       	jmp    c0101fc9 <trap_dispatch+0x1c9>
//LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        // 如果原先保存在trapframe中的cs不是代表用户态的USER_CS
        if (tf->tf_cs != USER_CS) {
c0101f05:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f08:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f0c:	83 f8 1b             	cmp    $0x1b,%eax
c0101f0f:	0f 84 b0 00 00 00    	je     c0101fc5 <trap_dispatch+0x1c5>
            // 将保存在trapframe中的cs改成代表用户态的USER_CS
            tf->tf_cs = USER_CS;
c0101f15:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f18:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            // 将其它的段选择子都修改为代表用户态的USER_DS，保证中断返回之后可以正常访问数据
            tf->tf_ds = USER_DS;
c0101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f21:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
            tf->tf_es = USER_DS;
c0101f27:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f2a:	66 c7 40 28 23 00    	movw   $0x23,0x28(%eax)
            tf->tf_ss = USER_DS;
c0101f30:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f33:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
            // 为了程序在CPL较低的情况下也能使用IO，需要将对应的IOPL位置改成用户态
            tf->tf_eflags |= FL_IOPL_MASK;
c0101f39:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f3c:	8b 40 40             	mov    0x40(%eax),%eax
c0101f3f:	0d 00 30 00 00       	or     $0x3000,%eax
c0101f44:	89 c2                	mov    %eax,%edx
c0101f46:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f49:	89 50 40             	mov    %edx,0x40(%eax)
        }
        break;
c0101f4c:	eb 77                	jmp    c0101fc5 <trap_dispatch+0x1c5>
    case T_SWITCH_TOK:
        // 如果原先保存在trapframe中的cs不是代表内核态的KERNEL_CS
        if (tf->tf_cs != KERNEL_CS) {
c0101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f51:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f55:	83 f8 08             	cmp    $0x8,%eax
c0101f58:	74 6e                	je     c0101fc8 <trap_dispatch+0x1c8>
            // 将保存在trapframe中的cs改成代表内核态的KERNEL_CS
            tf->tf_cs = KERNEL_CS;
c0101f5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f5d:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            // 将其它的段选择子都修改为代表内核态的KERNEL_DS，保证中断返回之后可以正常访问数据
            tf->tf_ds = KERNEL_DS;
c0101f63:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f66:	66 c7 40 2c 10 00    	movw   $0x10,0x2c(%eax)
            tf->tf_es = KERNEL_DS;
c0101f6c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f6f:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
            // 将调用IO所需权限降低，才能输出文本
            tf->tf_eflags |= 0x3000;
c0101f75:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f78:	8b 40 40             	mov    0x40(%eax),%eax
c0101f7b:	0d 00 30 00 00       	or     $0x3000,%eax
c0101f80:	89 c2                	mov    %eax,%edx
c0101f82:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f85:	89 50 40             	mov    %edx,0x40(%eax)
        }
        break;
c0101f88:	eb 3e                	jmp    c0101fc8 <trap_dispatch+0x1c8>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f8d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f91:	83 e0 03             	and    $0x3,%eax
c0101f94:	85 c0                	test   %eax,%eax
c0101f96:	75 31                	jne    c0101fc9 <trap_dispatch+0x1c9>
            print_trapframe(tf);
c0101f98:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f9b:	89 04 24             	mov    %eax,(%esp)
c0101f9e:	e8 ec fb ff ff       	call   c0101b8f <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101fa3:	c7 44 24 08 55 67 10 	movl   $0xc0106755,0x8(%esp)
c0101faa:	c0 
c0101fab:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c0101fb2:	00 
c0101fb3:	c7 04 24 71 67 10 c0 	movl   $0xc0106771,(%esp)
c0101fba:	e8 76 e4 ff ff       	call   c0100435 <__panic>
        break;
c0101fbf:	90                   	nop
c0101fc0:	eb 07                	jmp    c0101fc9 <trap_dispatch+0x1c9>
        break;
c0101fc2:	90                   	nop
c0101fc3:	eb 04                	jmp    c0101fc9 <trap_dispatch+0x1c9>
        break;
c0101fc5:	90                   	nop
c0101fc6:	eb 01                	jmp    c0101fc9 <trap_dispatch+0x1c9>
        break;
c0101fc8:	90                   	nop
        }
    }
}
c0101fc9:	90                   	nop
c0101fca:	c9                   	leave  
c0101fcb:	c3                   	ret    

c0101fcc <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101fcc:	f3 0f 1e fb          	endbr32 
c0101fd0:	55                   	push   %ebp
c0101fd1:	89 e5                	mov    %esp,%ebp
c0101fd3:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101fd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fd9:	89 04 24             	mov    %eax,(%esp)
c0101fdc:	e8 1f fe ff ff       	call   c0101e00 <trap_dispatch>
}
c0101fe1:	90                   	nop
c0101fe2:	c9                   	leave  
c0101fe3:	c3                   	ret    

c0101fe4 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101fe4:	6a 00                	push   $0x0
  pushl $0
c0101fe6:	6a 00                	push   $0x0
  jmp __alltraps
c0101fe8:	e9 69 0a 00 00       	jmp    c0102a56 <__alltraps>

c0101fed <vector1>:
.globl vector1
vector1:
  pushl $0
c0101fed:	6a 00                	push   $0x0
  pushl $1
c0101fef:	6a 01                	push   $0x1
  jmp __alltraps
c0101ff1:	e9 60 0a 00 00       	jmp    c0102a56 <__alltraps>

c0101ff6 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101ff6:	6a 00                	push   $0x0
  pushl $2
c0101ff8:	6a 02                	push   $0x2
  jmp __alltraps
c0101ffa:	e9 57 0a 00 00       	jmp    c0102a56 <__alltraps>

c0101fff <vector3>:
.globl vector3
vector3:
  pushl $0
c0101fff:	6a 00                	push   $0x0
  pushl $3
c0102001:	6a 03                	push   $0x3
  jmp __alltraps
c0102003:	e9 4e 0a 00 00       	jmp    c0102a56 <__alltraps>

c0102008 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102008:	6a 00                	push   $0x0
  pushl $4
c010200a:	6a 04                	push   $0x4
  jmp __alltraps
c010200c:	e9 45 0a 00 00       	jmp    c0102a56 <__alltraps>

c0102011 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102011:	6a 00                	push   $0x0
  pushl $5
c0102013:	6a 05                	push   $0x5
  jmp __alltraps
c0102015:	e9 3c 0a 00 00       	jmp    c0102a56 <__alltraps>

c010201a <vector6>:
.globl vector6
vector6:
  pushl $0
c010201a:	6a 00                	push   $0x0
  pushl $6
c010201c:	6a 06                	push   $0x6
  jmp __alltraps
c010201e:	e9 33 0a 00 00       	jmp    c0102a56 <__alltraps>

c0102023 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102023:	6a 00                	push   $0x0
  pushl $7
c0102025:	6a 07                	push   $0x7
  jmp __alltraps
c0102027:	e9 2a 0a 00 00       	jmp    c0102a56 <__alltraps>

c010202c <vector8>:
.globl vector8
vector8:
  pushl $8
c010202c:	6a 08                	push   $0x8
  jmp __alltraps
c010202e:	e9 23 0a 00 00       	jmp    c0102a56 <__alltraps>

c0102033 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102033:	6a 00                	push   $0x0
  pushl $9
c0102035:	6a 09                	push   $0x9
  jmp __alltraps
c0102037:	e9 1a 0a 00 00       	jmp    c0102a56 <__alltraps>

c010203c <vector10>:
.globl vector10
vector10:
  pushl $10
c010203c:	6a 0a                	push   $0xa
  jmp __alltraps
c010203e:	e9 13 0a 00 00       	jmp    c0102a56 <__alltraps>

c0102043 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102043:	6a 0b                	push   $0xb
  jmp __alltraps
c0102045:	e9 0c 0a 00 00       	jmp    c0102a56 <__alltraps>

c010204a <vector12>:
.globl vector12
vector12:
  pushl $12
c010204a:	6a 0c                	push   $0xc
  jmp __alltraps
c010204c:	e9 05 0a 00 00       	jmp    c0102a56 <__alltraps>

c0102051 <vector13>:
.globl vector13
vector13:
  pushl $13
c0102051:	6a 0d                	push   $0xd
  jmp __alltraps
c0102053:	e9 fe 09 00 00       	jmp    c0102a56 <__alltraps>

c0102058 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102058:	6a 0e                	push   $0xe
  jmp __alltraps
c010205a:	e9 f7 09 00 00       	jmp    c0102a56 <__alltraps>

c010205f <vector15>:
.globl vector15
vector15:
  pushl $0
c010205f:	6a 00                	push   $0x0
  pushl $15
c0102061:	6a 0f                	push   $0xf
  jmp __alltraps
c0102063:	e9 ee 09 00 00       	jmp    c0102a56 <__alltraps>

c0102068 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102068:	6a 00                	push   $0x0
  pushl $16
c010206a:	6a 10                	push   $0x10
  jmp __alltraps
c010206c:	e9 e5 09 00 00       	jmp    c0102a56 <__alltraps>

c0102071 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102071:	6a 11                	push   $0x11
  jmp __alltraps
c0102073:	e9 de 09 00 00       	jmp    c0102a56 <__alltraps>

c0102078 <vector18>:
.globl vector18
vector18:
  pushl $0
c0102078:	6a 00                	push   $0x0
  pushl $18
c010207a:	6a 12                	push   $0x12
  jmp __alltraps
c010207c:	e9 d5 09 00 00       	jmp    c0102a56 <__alltraps>

c0102081 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102081:	6a 00                	push   $0x0
  pushl $19
c0102083:	6a 13                	push   $0x13
  jmp __alltraps
c0102085:	e9 cc 09 00 00       	jmp    c0102a56 <__alltraps>

c010208a <vector20>:
.globl vector20
vector20:
  pushl $0
c010208a:	6a 00                	push   $0x0
  pushl $20
c010208c:	6a 14                	push   $0x14
  jmp __alltraps
c010208e:	e9 c3 09 00 00       	jmp    c0102a56 <__alltraps>

c0102093 <vector21>:
.globl vector21
vector21:
  pushl $0
c0102093:	6a 00                	push   $0x0
  pushl $21
c0102095:	6a 15                	push   $0x15
  jmp __alltraps
c0102097:	e9 ba 09 00 00       	jmp    c0102a56 <__alltraps>

c010209c <vector22>:
.globl vector22
vector22:
  pushl $0
c010209c:	6a 00                	push   $0x0
  pushl $22
c010209e:	6a 16                	push   $0x16
  jmp __alltraps
c01020a0:	e9 b1 09 00 00       	jmp    c0102a56 <__alltraps>

c01020a5 <vector23>:
.globl vector23
vector23:
  pushl $0
c01020a5:	6a 00                	push   $0x0
  pushl $23
c01020a7:	6a 17                	push   $0x17
  jmp __alltraps
c01020a9:	e9 a8 09 00 00       	jmp    c0102a56 <__alltraps>

c01020ae <vector24>:
.globl vector24
vector24:
  pushl $0
c01020ae:	6a 00                	push   $0x0
  pushl $24
c01020b0:	6a 18                	push   $0x18
  jmp __alltraps
c01020b2:	e9 9f 09 00 00       	jmp    c0102a56 <__alltraps>

c01020b7 <vector25>:
.globl vector25
vector25:
  pushl $0
c01020b7:	6a 00                	push   $0x0
  pushl $25
c01020b9:	6a 19                	push   $0x19
  jmp __alltraps
c01020bb:	e9 96 09 00 00       	jmp    c0102a56 <__alltraps>

c01020c0 <vector26>:
.globl vector26
vector26:
  pushl $0
c01020c0:	6a 00                	push   $0x0
  pushl $26
c01020c2:	6a 1a                	push   $0x1a
  jmp __alltraps
c01020c4:	e9 8d 09 00 00       	jmp    c0102a56 <__alltraps>

c01020c9 <vector27>:
.globl vector27
vector27:
  pushl $0
c01020c9:	6a 00                	push   $0x0
  pushl $27
c01020cb:	6a 1b                	push   $0x1b
  jmp __alltraps
c01020cd:	e9 84 09 00 00       	jmp    c0102a56 <__alltraps>

c01020d2 <vector28>:
.globl vector28
vector28:
  pushl $0
c01020d2:	6a 00                	push   $0x0
  pushl $28
c01020d4:	6a 1c                	push   $0x1c
  jmp __alltraps
c01020d6:	e9 7b 09 00 00       	jmp    c0102a56 <__alltraps>

c01020db <vector29>:
.globl vector29
vector29:
  pushl $0
c01020db:	6a 00                	push   $0x0
  pushl $29
c01020dd:	6a 1d                	push   $0x1d
  jmp __alltraps
c01020df:	e9 72 09 00 00       	jmp    c0102a56 <__alltraps>

c01020e4 <vector30>:
.globl vector30
vector30:
  pushl $0
c01020e4:	6a 00                	push   $0x0
  pushl $30
c01020e6:	6a 1e                	push   $0x1e
  jmp __alltraps
c01020e8:	e9 69 09 00 00       	jmp    c0102a56 <__alltraps>

c01020ed <vector31>:
.globl vector31
vector31:
  pushl $0
c01020ed:	6a 00                	push   $0x0
  pushl $31
c01020ef:	6a 1f                	push   $0x1f
  jmp __alltraps
c01020f1:	e9 60 09 00 00       	jmp    c0102a56 <__alltraps>

c01020f6 <vector32>:
.globl vector32
vector32:
  pushl $0
c01020f6:	6a 00                	push   $0x0
  pushl $32
c01020f8:	6a 20                	push   $0x20
  jmp __alltraps
c01020fa:	e9 57 09 00 00       	jmp    c0102a56 <__alltraps>

c01020ff <vector33>:
.globl vector33
vector33:
  pushl $0
c01020ff:	6a 00                	push   $0x0
  pushl $33
c0102101:	6a 21                	push   $0x21
  jmp __alltraps
c0102103:	e9 4e 09 00 00       	jmp    c0102a56 <__alltraps>

c0102108 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102108:	6a 00                	push   $0x0
  pushl $34
c010210a:	6a 22                	push   $0x22
  jmp __alltraps
c010210c:	e9 45 09 00 00       	jmp    c0102a56 <__alltraps>

c0102111 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102111:	6a 00                	push   $0x0
  pushl $35
c0102113:	6a 23                	push   $0x23
  jmp __alltraps
c0102115:	e9 3c 09 00 00       	jmp    c0102a56 <__alltraps>

c010211a <vector36>:
.globl vector36
vector36:
  pushl $0
c010211a:	6a 00                	push   $0x0
  pushl $36
c010211c:	6a 24                	push   $0x24
  jmp __alltraps
c010211e:	e9 33 09 00 00       	jmp    c0102a56 <__alltraps>

c0102123 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102123:	6a 00                	push   $0x0
  pushl $37
c0102125:	6a 25                	push   $0x25
  jmp __alltraps
c0102127:	e9 2a 09 00 00       	jmp    c0102a56 <__alltraps>

c010212c <vector38>:
.globl vector38
vector38:
  pushl $0
c010212c:	6a 00                	push   $0x0
  pushl $38
c010212e:	6a 26                	push   $0x26
  jmp __alltraps
c0102130:	e9 21 09 00 00       	jmp    c0102a56 <__alltraps>

c0102135 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102135:	6a 00                	push   $0x0
  pushl $39
c0102137:	6a 27                	push   $0x27
  jmp __alltraps
c0102139:	e9 18 09 00 00       	jmp    c0102a56 <__alltraps>

c010213e <vector40>:
.globl vector40
vector40:
  pushl $0
c010213e:	6a 00                	push   $0x0
  pushl $40
c0102140:	6a 28                	push   $0x28
  jmp __alltraps
c0102142:	e9 0f 09 00 00       	jmp    c0102a56 <__alltraps>

c0102147 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102147:	6a 00                	push   $0x0
  pushl $41
c0102149:	6a 29                	push   $0x29
  jmp __alltraps
c010214b:	e9 06 09 00 00       	jmp    c0102a56 <__alltraps>

c0102150 <vector42>:
.globl vector42
vector42:
  pushl $0
c0102150:	6a 00                	push   $0x0
  pushl $42
c0102152:	6a 2a                	push   $0x2a
  jmp __alltraps
c0102154:	e9 fd 08 00 00       	jmp    c0102a56 <__alltraps>

c0102159 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102159:	6a 00                	push   $0x0
  pushl $43
c010215b:	6a 2b                	push   $0x2b
  jmp __alltraps
c010215d:	e9 f4 08 00 00       	jmp    c0102a56 <__alltraps>

c0102162 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102162:	6a 00                	push   $0x0
  pushl $44
c0102164:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102166:	e9 eb 08 00 00       	jmp    c0102a56 <__alltraps>

c010216b <vector45>:
.globl vector45
vector45:
  pushl $0
c010216b:	6a 00                	push   $0x0
  pushl $45
c010216d:	6a 2d                	push   $0x2d
  jmp __alltraps
c010216f:	e9 e2 08 00 00       	jmp    c0102a56 <__alltraps>

c0102174 <vector46>:
.globl vector46
vector46:
  pushl $0
c0102174:	6a 00                	push   $0x0
  pushl $46
c0102176:	6a 2e                	push   $0x2e
  jmp __alltraps
c0102178:	e9 d9 08 00 00       	jmp    c0102a56 <__alltraps>

c010217d <vector47>:
.globl vector47
vector47:
  pushl $0
c010217d:	6a 00                	push   $0x0
  pushl $47
c010217f:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102181:	e9 d0 08 00 00       	jmp    c0102a56 <__alltraps>

c0102186 <vector48>:
.globl vector48
vector48:
  pushl $0
c0102186:	6a 00                	push   $0x0
  pushl $48
c0102188:	6a 30                	push   $0x30
  jmp __alltraps
c010218a:	e9 c7 08 00 00       	jmp    c0102a56 <__alltraps>

c010218f <vector49>:
.globl vector49
vector49:
  pushl $0
c010218f:	6a 00                	push   $0x0
  pushl $49
c0102191:	6a 31                	push   $0x31
  jmp __alltraps
c0102193:	e9 be 08 00 00       	jmp    c0102a56 <__alltraps>

c0102198 <vector50>:
.globl vector50
vector50:
  pushl $0
c0102198:	6a 00                	push   $0x0
  pushl $50
c010219a:	6a 32                	push   $0x32
  jmp __alltraps
c010219c:	e9 b5 08 00 00       	jmp    c0102a56 <__alltraps>

c01021a1 <vector51>:
.globl vector51
vector51:
  pushl $0
c01021a1:	6a 00                	push   $0x0
  pushl $51
c01021a3:	6a 33                	push   $0x33
  jmp __alltraps
c01021a5:	e9 ac 08 00 00       	jmp    c0102a56 <__alltraps>

c01021aa <vector52>:
.globl vector52
vector52:
  pushl $0
c01021aa:	6a 00                	push   $0x0
  pushl $52
c01021ac:	6a 34                	push   $0x34
  jmp __alltraps
c01021ae:	e9 a3 08 00 00       	jmp    c0102a56 <__alltraps>

c01021b3 <vector53>:
.globl vector53
vector53:
  pushl $0
c01021b3:	6a 00                	push   $0x0
  pushl $53
c01021b5:	6a 35                	push   $0x35
  jmp __alltraps
c01021b7:	e9 9a 08 00 00       	jmp    c0102a56 <__alltraps>

c01021bc <vector54>:
.globl vector54
vector54:
  pushl $0
c01021bc:	6a 00                	push   $0x0
  pushl $54
c01021be:	6a 36                	push   $0x36
  jmp __alltraps
c01021c0:	e9 91 08 00 00       	jmp    c0102a56 <__alltraps>

c01021c5 <vector55>:
.globl vector55
vector55:
  pushl $0
c01021c5:	6a 00                	push   $0x0
  pushl $55
c01021c7:	6a 37                	push   $0x37
  jmp __alltraps
c01021c9:	e9 88 08 00 00       	jmp    c0102a56 <__alltraps>

c01021ce <vector56>:
.globl vector56
vector56:
  pushl $0
c01021ce:	6a 00                	push   $0x0
  pushl $56
c01021d0:	6a 38                	push   $0x38
  jmp __alltraps
c01021d2:	e9 7f 08 00 00       	jmp    c0102a56 <__alltraps>

c01021d7 <vector57>:
.globl vector57
vector57:
  pushl $0
c01021d7:	6a 00                	push   $0x0
  pushl $57
c01021d9:	6a 39                	push   $0x39
  jmp __alltraps
c01021db:	e9 76 08 00 00       	jmp    c0102a56 <__alltraps>

c01021e0 <vector58>:
.globl vector58
vector58:
  pushl $0
c01021e0:	6a 00                	push   $0x0
  pushl $58
c01021e2:	6a 3a                	push   $0x3a
  jmp __alltraps
c01021e4:	e9 6d 08 00 00       	jmp    c0102a56 <__alltraps>

c01021e9 <vector59>:
.globl vector59
vector59:
  pushl $0
c01021e9:	6a 00                	push   $0x0
  pushl $59
c01021eb:	6a 3b                	push   $0x3b
  jmp __alltraps
c01021ed:	e9 64 08 00 00       	jmp    c0102a56 <__alltraps>

c01021f2 <vector60>:
.globl vector60
vector60:
  pushl $0
c01021f2:	6a 00                	push   $0x0
  pushl $60
c01021f4:	6a 3c                	push   $0x3c
  jmp __alltraps
c01021f6:	e9 5b 08 00 00       	jmp    c0102a56 <__alltraps>

c01021fb <vector61>:
.globl vector61
vector61:
  pushl $0
c01021fb:	6a 00                	push   $0x0
  pushl $61
c01021fd:	6a 3d                	push   $0x3d
  jmp __alltraps
c01021ff:	e9 52 08 00 00       	jmp    c0102a56 <__alltraps>

c0102204 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102204:	6a 00                	push   $0x0
  pushl $62
c0102206:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102208:	e9 49 08 00 00       	jmp    c0102a56 <__alltraps>

c010220d <vector63>:
.globl vector63
vector63:
  pushl $0
c010220d:	6a 00                	push   $0x0
  pushl $63
c010220f:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102211:	e9 40 08 00 00       	jmp    c0102a56 <__alltraps>

c0102216 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102216:	6a 00                	push   $0x0
  pushl $64
c0102218:	6a 40                	push   $0x40
  jmp __alltraps
c010221a:	e9 37 08 00 00       	jmp    c0102a56 <__alltraps>

c010221f <vector65>:
.globl vector65
vector65:
  pushl $0
c010221f:	6a 00                	push   $0x0
  pushl $65
c0102221:	6a 41                	push   $0x41
  jmp __alltraps
c0102223:	e9 2e 08 00 00       	jmp    c0102a56 <__alltraps>

c0102228 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102228:	6a 00                	push   $0x0
  pushl $66
c010222a:	6a 42                	push   $0x42
  jmp __alltraps
c010222c:	e9 25 08 00 00       	jmp    c0102a56 <__alltraps>

c0102231 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102231:	6a 00                	push   $0x0
  pushl $67
c0102233:	6a 43                	push   $0x43
  jmp __alltraps
c0102235:	e9 1c 08 00 00       	jmp    c0102a56 <__alltraps>

c010223a <vector68>:
.globl vector68
vector68:
  pushl $0
c010223a:	6a 00                	push   $0x0
  pushl $68
c010223c:	6a 44                	push   $0x44
  jmp __alltraps
c010223e:	e9 13 08 00 00       	jmp    c0102a56 <__alltraps>

c0102243 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102243:	6a 00                	push   $0x0
  pushl $69
c0102245:	6a 45                	push   $0x45
  jmp __alltraps
c0102247:	e9 0a 08 00 00       	jmp    c0102a56 <__alltraps>

c010224c <vector70>:
.globl vector70
vector70:
  pushl $0
c010224c:	6a 00                	push   $0x0
  pushl $70
c010224e:	6a 46                	push   $0x46
  jmp __alltraps
c0102250:	e9 01 08 00 00       	jmp    c0102a56 <__alltraps>

c0102255 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102255:	6a 00                	push   $0x0
  pushl $71
c0102257:	6a 47                	push   $0x47
  jmp __alltraps
c0102259:	e9 f8 07 00 00       	jmp    c0102a56 <__alltraps>

c010225e <vector72>:
.globl vector72
vector72:
  pushl $0
c010225e:	6a 00                	push   $0x0
  pushl $72
c0102260:	6a 48                	push   $0x48
  jmp __alltraps
c0102262:	e9 ef 07 00 00       	jmp    c0102a56 <__alltraps>

c0102267 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102267:	6a 00                	push   $0x0
  pushl $73
c0102269:	6a 49                	push   $0x49
  jmp __alltraps
c010226b:	e9 e6 07 00 00       	jmp    c0102a56 <__alltraps>

c0102270 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102270:	6a 00                	push   $0x0
  pushl $74
c0102272:	6a 4a                	push   $0x4a
  jmp __alltraps
c0102274:	e9 dd 07 00 00       	jmp    c0102a56 <__alltraps>

c0102279 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102279:	6a 00                	push   $0x0
  pushl $75
c010227b:	6a 4b                	push   $0x4b
  jmp __alltraps
c010227d:	e9 d4 07 00 00       	jmp    c0102a56 <__alltraps>

c0102282 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102282:	6a 00                	push   $0x0
  pushl $76
c0102284:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102286:	e9 cb 07 00 00       	jmp    c0102a56 <__alltraps>

c010228b <vector77>:
.globl vector77
vector77:
  pushl $0
c010228b:	6a 00                	push   $0x0
  pushl $77
c010228d:	6a 4d                	push   $0x4d
  jmp __alltraps
c010228f:	e9 c2 07 00 00       	jmp    c0102a56 <__alltraps>

c0102294 <vector78>:
.globl vector78
vector78:
  pushl $0
c0102294:	6a 00                	push   $0x0
  pushl $78
c0102296:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102298:	e9 b9 07 00 00       	jmp    c0102a56 <__alltraps>

c010229d <vector79>:
.globl vector79
vector79:
  pushl $0
c010229d:	6a 00                	push   $0x0
  pushl $79
c010229f:	6a 4f                	push   $0x4f
  jmp __alltraps
c01022a1:	e9 b0 07 00 00       	jmp    c0102a56 <__alltraps>

c01022a6 <vector80>:
.globl vector80
vector80:
  pushl $0
c01022a6:	6a 00                	push   $0x0
  pushl $80
c01022a8:	6a 50                	push   $0x50
  jmp __alltraps
c01022aa:	e9 a7 07 00 00       	jmp    c0102a56 <__alltraps>

c01022af <vector81>:
.globl vector81
vector81:
  pushl $0
c01022af:	6a 00                	push   $0x0
  pushl $81
c01022b1:	6a 51                	push   $0x51
  jmp __alltraps
c01022b3:	e9 9e 07 00 00       	jmp    c0102a56 <__alltraps>

c01022b8 <vector82>:
.globl vector82
vector82:
  pushl $0
c01022b8:	6a 00                	push   $0x0
  pushl $82
c01022ba:	6a 52                	push   $0x52
  jmp __alltraps
c01022bc:	e9 95 07 00 00       	jmp    c0102a56 <__alltraps>

c01022c1 <vector83>:
.globl vector83
vector83:
  pushl $0
c01022c1:	6a 00                	push   $0x0
  pushl $83
c01022c3:	6a 53                	push   $0x53
  jmp __alltraps
c01022c5:	e9 8c 07 00 00       	jmp    c0102a56 <__alltraps>

c01022ca <vector84>:
.globl vector84
vector84:
  pushl $0
c01022ca:	6a 00                	push   $0x0
  pushl $84
c01022cc:	6a 54                	push   $0x54
  jmp __alltraps
c01022ce:	e9 83 07 00 00       	jmp    c0102a56 <__alltraps>

c01022d3 <vector85>:
.globl vector85
vector85:
  pushl $0
c01022d3:	6a 00                	push   $0x0
  pushl $85
c01022d5:	6a 55                	push   $0x55
  jmp __alltraps
c01022d7:	e9 7a 07 00 00       	jmp    c0102a56 <__alltraps>

c01022dc <vector86>:
.globl vector86
vector86:
  pushl $0
c01022dc:	6a 00                	push   $0x0
  pushl $86
c01022de:	6a 56                	push   $0x56
  jmp __alltraps
c01022e0:	e9 71 07 00 00       	jmp    c0102a56 <__alltraps>

c01022e5 <vector87>:
.globl vector87
vector87:
  pushl $0
c01022e5:	6a 00                	push   $0x0
  pushl $87
c01022e7:	6a 57                	push   $0x57
  jmp __alltraps
c01022e9:	e9 68 07 00 00       	jmp    c0102a56 <__alltraps>

c01022ee <vector88>:
.globl vector88
vector88:
  pushl $0
c01022ee:	6a 00                	push   $0x0
  pushl $88
c01022f0:	6a 58                	push   $0x58
  jmp __alltraps
c01022f2:	e9 5f 07 00 00       	jmp    c0102a56 <__alltraps>

c01022f7 <vector89>:
.globl vector89
vector89:
  pushl $0
c01022f7:	6a 00                	push   $0x0
  pushl $89
c01022f9:	6a 59                	push   $0x59
  jmp __alltraps
c01022fb:	e9 56 07 00 00       	jmp    c0102a56 <__alltraps>

c0102300 <vector90>:
.globl vector90
vector90:
  pushl $0
c0102300:	6a 00                	push   $0x0
  pushl $90
c0102302:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102304:	e9 4d 07 00 00       	jmp    c0102a56 <__alltraps>

c0102309 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102309:	6a 00                	push   $0x0
  pushl $91
c010230b:	6a 5b                	push   $0x5b
  jmp __alltraps
c010230d:	e9 44 07 00 00       	jmp    c0102a56 <__alltraps>

c0102312 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102312:	6a 00                	push   $0x0
  pushl $92
c0102314:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102316:	e9 3b 07 00 00       	jmp    c0102a56 <__alltraps>

c010231b <vector93>:
.globl vector93
vector93:
  pushl $0
c010231b:	6a 00                	push   $0x0
  pushl $93
c010231d:	6a 5d                	push   $0x5d
  jmp __alltraps
c010231f:	e9 32 07 00 00       	jmp    c0102a56 <__alltraps>

c0102324 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102324:	6a 00                	push   $0x0
  pushl $94
c0102326:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102328:	e9 29 07 00 00       	jmp    c0102a56 <__alltraps>

c010232d <vector95>:
.globl vector95
vector95:
  pushl $0
c010232d:	6a 00                	push   $0x0
  pushl $95
c010232f:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102331:	e9 20 07 00 00       	jmp    c0102a56 <__alltraps>

c0102336 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102336:	6a 00                	push   $0x0
  pushl $96
c0102338:	6a 60                	push   $0x60
  jmp __alltraps
c010233a:	e9 17 07 00 00       	jmp    c0102a56 <__alltraps>

c010233f <vector97>:
.globl vector97
vector97:
  pushl $0
c010233f:	6a 00                	push   $0x0
  pushl $97
c0102341:	6a 61                	push   $0x61
  jmp __alltraps
c0102343:	e9 0e 07 00 00       	jmp    c0102a56 <__alltraps>

c0102348 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102348:	6a 00                	push   $0x0
  pushl $98
c010234a:	6a 62                	push   $0x62
  jmp __alltraps
c010234c:	e9 05 07 00 00       	jmp    c0102a56 <__alltraps>

c0102351 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102351:	6a 00                	push   $0x0
  pushl $99
c0102353:	6a 63                	push   $0x63
  jmp __alltraps
c0102355:	e9 fc 06 00 00       	jmp    c0102a56 <__alltraps>

c010235a <vector100>:
.globl vector100
vector100:
  pushl $0
c010235a:	6a 00                	push   $0x0
  pushl $100
c010235c:	6a 64                	push   $0x64
  jmp __alltraps
c010235e:	e9 f3 06 00 00       	jmp    c0102a56 <__alltraps>

c0102363 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102363:	6a 00                	push   $0x0
  pushl $101
c0102365:	6a 65                	push   $0x65
  jmp __alltraps
c0102367:	e9 ea 06 00 00       	jmp    c0102a56 <__alltraps>

c010236c <vector102>:
.globl vector102
vector102:
  pushl $0
c010236c:	6a 00                	push   $0x0
  pushl $102
c010236e:	6a 66                	push   $0x66
  jmp __alltraps
c0102370:	e9 e1 06 00 00       	jmp    c0102a56 <__alltraps>

c0102375 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102375:	6a 00                	push   $0x0
  pushl $103
c0102377:	6a 67                	push   $0x67
  jmp __alltraps
c0102379:	e9 d8 06 00 00       	jmp    c0102a56 <__alltraps>

c010237e <vector104>:
.globl vector104
vector104:
  pushl $0
c010237e:	6a 00                	push   $0x0
  pushl $104
c0102380:	6a 68                	push   $0x68
  jmp __alltraps
c0102382:	e9 cf 06 00 00       	jmp    c0102a56 <__alltraps>

c0102387 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102387:	6a 00                	push   $0x0
  pushl $105
c0102389:	6a 69                	push   $0x69
  jmp __alltraps
c010238b:	e9 c6 06 00 00       	jmp    c0102a56 <__alltraps>

c0102390 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102390:	6a 00                	push   $0x0
  pushl $106
c0102392:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102394:	e9 bd 06 00 00       	jmp    c0102a56 <__alltraps>

c0102399 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102399:	6a 00                	push   $0x0
  pushl $107
c010239b:	6a 6b                	push   $0x6b
  jmp __alltraps
c010239d:	e9 b4 06 00 00       	jmp    c0102a56 <__alltraps>

c01023a2 <vector108>:
.globl vector108
vector108:
  pushl $0
c01023a2:	6a 00                	push   $0x0
  pushl $108
c01023a4:	6a 6c                	push   $0x6c
  jmp __alltraps
c01023a6:	e9 ab 06 00 00       	jmp    c0102a56 <__alltraps>

c01023ab <vector109>:
.globl vector109
vector109:
  pushl $0
c01023ab:	6a 00                	push   $0x0
  pushl $109
c01023ad:	6a 6d                	push   $0x6d
  jmp __alltraps
c01023af:	e9 a2 06 00 00       	jmp    c0102a56 <__alltraps>

c01023b4 <vector110>:
.globl vector110
vector110:
  pushl $0
c01023b4:	6a 00                	push   $0x0
  pushl $110
c01023b6:	6a 6e                	push   $0x6e
  jmp __alltraps
c01023b8:	e9 99 06 00 00       	jmp    c0102a56 <__alltraps>

c01023bd <vector111>:
.globl vector111
vector111:
  pushl $0
c01023bd:	6a 00                	push   $0x0
  pushl $111
c01023bf:	6a 6f                	push   $0x6f
  jmp __alltraps
c01023c1:	e9 90 06 00 00       	jmp    c0102a56 <__alltraps>

c01023c6 <vector112>:
.globl vector112
vector112:
  pushl $0
c01023c6:	6a 00                	push   $0x0
  pushl $112
c01023c8:	6a 70                	push   $0x70
  jmp __alltraps
c01023ca:	e9 87 06 00 00       	jmp    c0102a56 <__alltraps>

c01023cf <vector113>:
.globl vector113
vector113:
  pushl $0
c01023cf:	6a 00                	push   $0x0
  pushl $113
c01023d1:	6a 71                	push   $0x71
  jmp __alltraps
c01023d3:	e9 7e 06 00 00       	jmp    c0102a56 <__alltraps>

c01023d8 <vector114>:
.globl vector114
vector114:
  pushl $0
c01023d8:	6a 00                	push   $0x0
  pushl $114
c01023da:	6a 72                	push   $0x72
  jmp __alltraps
c01023dc:	e9 75 06 00 00       	jmp    c0102a56 <__alltraps>

c01023e1 <vector115>:
.globl vector115
vector115:
  pushl $0
c01023e1:	6a 00                	push   $0x0
  pushl $115
c01023e3:	6a 73                	push   $0x73
  jmp __alltraps
c01023e5:	e9 6c 06 00 00       	jmp    c0102a56 <__alltraps>

c01023ea <vector116>:
.globl vector116
vector116:
  pushl $0
c01023ea:	6a 00                	push   $0x0
  pushl $116
c01023ec:	6a 74                	push   $0x74
  jmp __alltraps
c01023ee:	e9 63 06 00 00       	jmp    c0102a56 <__alltraps>

c01023f3 <vector117>:
.globl vector117
vector117:
  pushl $0
c01023f3:	6a 00                	push   $0x0
  pushl $117
c01023f5:	6a 75                	push   $0x75
  jmp __alltraps
c01023f7:	e9 5a 06 00 00       	jmp    c0102a56 <__alltraps>

c01023fc <vector118>:
.globl vector118
vector118:
  pushl $0
c01023fc:	6a 00                	push   $0x0
  pushl $118
c01023fe:	6a 76                	push   $0x76
  jmp __alltraps
c0102400:	e9 51 06 00 00       	jmp    c0102a56 <__alltraps>

c0102405 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102405:	6a 00                	push   $0x0
  pushl $119
c0102407:	6a 77                	push   $0x77
  jmp __alltraps
c0102409:	e9 48 06 00 00       	jmp    c0102a56 <__alltraps>

c010240e <vector120>:
.globl vector120
vector120:
  pushl $0
c010240e:	6a 00                	push   $0x0
  pushl $120
c0102410:	6a 78                	push   $0x78
  jmp __alltraps
c0102412:	e9 3f 06 00 00       	jmp    c0102a56 <__alltraps>

c0102417 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102417:	6a 00                	push   $0x0
  pushl $121
c0102419:	6a 79                	push   $0x79
  jmp __alltraps
c010241b:	e9 36 06 00 00       	jmp    c0102a56 <__alltraps>

c0102420 <vector122>:
.globl vector122
vector122:
  pushl $0
c0102420:	6a 00                	push   $0x0
  pushl $122
c0102422:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102424:	e9 2d 06 00 00       	jmp    c0102a56 <__alltraps>

c0102429 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102429:	6a 00                	push   $0x0
  pushl $123
c010242b:	6a 7b                	push   $0x7b
  jmp __alltraps
c010242d:	e9 24 06 00 00       	jmp    c0102a56 <__alltraps>

c0102432 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102432:	6a 00                	push   $0x0
  pushl $124
c0102434:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102436:	e9 1b 06 00 00       	jmp    c0102a56 <__alltraps>

c010243b <vector125>:
.globl vector125
vector125:
  pushl $0
c010243b:	6a 00                	push   $0x0
  pushl $125
c010243d:	6a 7d                	push   $0x7d
  jmp __alltraps
c010243f:	e9 12 06 00 00       	jmp    c0102a56 <__alltraps>

c0102444 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102444:	6a 00                	push   $0x0
  pushl $126
c0102446:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102448:	e9 09 06 00 00       	jmp    c0102a56 <__alltraps>

c010244d <vector127>:
.globl vector127
vector127:
  pushl $0
c010244d:	6a 00                	push   $0x0
  pushl $127
c010244f:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102451:	e9 00 06 00 00       	jmp    c0102a56 <__alltraps>

c0102456 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102456:	6a 00                	push   $0x0
  pushl $128
c0102458:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c010245d:	e9 f4 05 00 00       	jmp    c0102a56 <__alltraps>

c0102462 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102462:	6a 00                	push   $0x0
  pushl $129
c0102464:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102469:	e9 e8 05 00 00       	jmp    c0102a56 <__alltraps>

c010246e <vector130>:
.globl vector130
vector130:
  pushl $0
c010246e:	6a 00                	push   $0x0
  pushl $130
c0102470:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102475:	e9 dc 05 00 00       	jmp    c0102a56 <__alltraps>

c010247a <vector131>:
.globl vector131
vector131:
  pushl $0
c010247a:	6a 00                	push   $0x0
  pushl $131
c010247c:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102481:	e9 d0 05 00 00       	jmp    c0102a56 <__alltraps>

c0102486 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102486:	6a 00                	push   $0x0
  pushl $132
c0102488:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c010248d:	e9 c4 05 00 00       	jmp    c0102a56 <__alltraps>

c0102492 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102492:	6a 00                	push   $0x0
  pushl $133
c0102494:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102499:	e9 b8 05 00 00       	jmp    c0102a56 <__alltraps>

c010249e <vector134>:
.globl vector134
vector134:
  pushl $0
c010249e:	6a 00                	push   $0x0
  pushl $134
c01024a0:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01024a5:	e9 ac 05 00 00       	jmp    c0102a56 <__alltraps>

c01024aa <vector135>:
.globl vector135
vector135:
  pushl $0
c01024aa:	6a 00                	push   $0x0
  pushl $135
c01024ac:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01024b1:	e9 a0 05 00 00       	jmp    c0102a56 <__alltraps>

c01024b6 <vector136>:
.globl vector136
vector136:
  pushl $0
c01024b6:	6a 00                	push   $0x0
  pushl $136
c01024b8:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01024bd:	e9 94 05 00 00       	jmp    c0102a56 <__alltraps>

c01024c2 <vector137>:
.globl vector137
vector137:
  pushl $0
c01024c2:	6a 00                	push   $0x0
  pushl $137
c01024c4:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01024c9:	e9 88 05 00 00       	jmp    c0102a56 <__alltraps>

c01024ce <vector138>:
.globl vector138
vector138:
  pushl $0
c01024ce:	6a 00                	push   $0x0
  pushl $138
c01024d0:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01024d5:	e9 7c 05 00 00       	jmp    c0102a56 <__alltraps>

c01024da <vector139>:
.globl vector139
vector139:
  pushl $0
c01024da:	6a 00                	push   $0x0
  pushl $139
c01024dc:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01024e1:	e9 70 05 00 00       	jmp    c0102a56 <__alltraps>

c01024e6 <vector140>:
.globl vector140
vector140:
  pushl $0
c01024e6:	6a 00                	push   $0x0
  pushl $140
c01024e8:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01024ed:	e9 64 05 00 00       	jmp    c0102a56 <__alltraps>

c01024f2 <vector141>:
.globl vector141
vector141:
  pushl $0
c01024f2:	6a 00                	push   $0x0
  pushl $141
c01024f4:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01024f9:	e9 58 05 00 00       	jmp    c0102a56 <__alltraps>

c01024fe <vector142>:
.globl vector142
vector142:
  pushl $0
c01024fe:	6a 00                	push   $0x0
  pushl $142
c0102500:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102505:	e9 4c 05 00 00       	jmp    c0102a56 <__alltraps>

c010250a <vector143>:
.globl vector143
vector143:
  pushl $0
c010250a:	6a 00                	push   $0x0
  pushl $143
c010250c:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102511:	e9 40 05 00 00       	jmp    c0102a56 <__alltraps>

c0102516 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102516:	6a 00                	push   $0x0
  pushl $144
c0102518:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c010251d:	e9 34 05 00 00       	jmp    c0102a56 <__alltraps>

c0102522 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102522:	6a 00                	push   $0x0
  pushl $145
c0102524:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102529:	e9 28 05 00 00       	jmp    c0102a56 <__alltraps>

c010252e <vector146>:
.globl vector146
vector146:
  pushl $0
c010252e:	6a 00                	push   $0x0
  pushl $146
c0102530:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102535:	e9 1c 05 00 00       	jmp    c0102a56 <__alltraps>

c010253a <vector147>:
.globl vector147
vector147:
  pushl $0
c010253a:	6a 00                	push   $0x0
  pushl $147
c010253c:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102541:	e9 10 05 00 00       	jmp    c0102a56 <__alltraps>

c0102546 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102546:	6a 00                	push   $0x0
  pushl $148
c0102548:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c010254d:	e9 04 05 00 00       	jmp    c0102a56 <__alltraps>

c0102552 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102552:	6a 00                	push   $0x0
  pushl $149
c0102554:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102559:	e9 f8 04 00 00       	jmp    c0102a56 <__alltraps>

c010255e <vector150>:
.globl vector150
vector150:
  pushl $0
c010255e:	6a 00                	push   $0x0
  pushl $150
c0102560:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102565:	e9 ec 04 00 00       	jmp    c0102a56 <__alltraps>

c010256a <vector151>:
.globl vector151
vector151:
  pushl $0
c010256a:	6a 00                	push   $0x0
  pushl $151
c010256c:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102571:	e9 e0 04 00 00       	jmp    c0102a56 <__alltraps>

c0102576 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102576:	6a 00                	push   $0x0
  pushl $152
c0102578:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c010257d:	e9 d4 04 00 00       	jmp    c0102a56 <__alltraps>

c0102582 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102582:	6a 00                	push   $0x0
  pushl $153
c0102584:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102589:	e9 c8 04 00 00       	jmp    c0102a56 <__alltraps>

c010258e <vector154>:
.globl vector154
vector154:
  pushl $0
c010258e:	6a 00                	push   $0x0
  pushl $154
c0102590:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102595:	e9 bc 04 00 00       	jmp    c0102a56 <__alltraps>

c010259a <vector155>:
.globl vector155
vector155:
  pushl $0
c010259a:	6a 00                	push   $0x0
  pushl $155
c010259c:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01025a1:	e9 b0 04 00 00       	jmp    c0102a56 <__alltraps>

c01025a6 <vector156>:
.globl vector156
vector156:
  pushl $0
c01025a6:	6a 00                	push   $0x0
  pushl $156
c01025a8:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01025ad:	e9 a4 04 00 00       	jmp    c0102a56 <__alltraps>

c01025b2 <vector157>:
.globl vector157
vector157:
  pushl $0
c01025b2:	6a 00                	push   $0x0
  pushl $157
c01025b4:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01025b9:	e9 98 04 00 00       	jmp    c0102a56 <__alltraps>

c01025be <vector158>:
.globl vector158
vector158:
  pushl $0
c01025be:	6a 00                	push   $0x0
  pushl $158
c01025c0:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01025c5:	e9 8c 04 00 00       	jmp    c0102a56 <__alltraps>

c01025ca <vector159>:
.globl vector159
vector159:
  pushl $0
c01025ca:	6a 00                	push   $0x0
  pushl $159
c01025cc:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01025d1:	e9 80 04 00 00       	jmp    c0102a56 <__alltraps>

c01025d6 <vector160>:
.globl vector160
vector160:
  pushl $0
c01025d6:	6a 00                	push   $0x0
  pushl $160
c01025d8:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01025dd:	e9 74 04 00 00       	jmp    c0102a56 <__alltraps>

c01025e2 <vector161>:
.globl vector161
vector161:
  pushl $0
c01025e2:	6a 00                	push   $0x0
  pushl $161
c01025e4:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01025e9:	e9 68 04 00 00       	jmp    c0102a56 <__alltraps>

c01025ee <vector162>:
.globl vector162
vector162:
  pushl $0
c01025ee:	6a 00                	push   $0x0
  pushl $162
c01025f0:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01025f5:	e9 5c 04 00 00       	jmp    c0102a56 <__alltraps>

c01025fa <vector163>:
.globl vector163
vector163:
  pushl $0
c01025fa:	6a 00                	push   $0x0
  pushl $163
c01025fc:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102601:	e9 50 04 00 00       	jmp    c0102a56 <__alltraps>

c0102606 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102606:	6a 00                	push   $0x0
  pushl $164
c0102608:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c010260d:	e9 44 04 00 00       	jmp    c0102a56 <__alltraps>

c0102612 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102612:	6a 00                	push   $0x0
  pushl $165
c0102614:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102619:	e9 38 04 00 00       	jmp    c0102a56 <__alltraps>

c010261e <vector166>:
.globl vector166
vector166:
  pushl $0
c010261e:	6a 00                	push   $0x0
  pushl $166
c0102620:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102625:	e9 2c 04 00 00       	jmp    c0102a56 <__alltraps>

c010262a <vector167>:
.globl vector167
vector167:
  pushl $0
c010262a:	6a 00                	push   $0x0
  pushl $167
c010262c:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102631:	e9 20 04 00 00       	jmp    c0102a56 <__alltraps>

c0102636 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102636:	6a 00                	push   $0x0
  pushl $168
c0102638:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c010263d:	e9 14 04 00 00       	jmp    c0102a56 <__alltraps>

c0102642 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102642:	6a 00                	push   $0x0
  pushl $169
c0102644:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102649:	e9 08 04 00 00       	jmp    c0102a56 <__alltraps>

c010264e <vector170>:
.globl vector170
vector170:
  pushl $0
c010264e:	6a 00                	push   $0x0
  pushl $170
c0102650:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102655:	e9 fc 03 00 00       	jmp    c0102a56 <__alltraps>

c010265a <vector171>:
.globl vector171
vector171:
  pushl $0
c010265a:	6a 00                	push   $0x0
  pushl $171
c010265c:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102661:	e9 f0 03 00 00       	jmp    c0102a56 <__alltraps>

c0102666 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102666:	6a 00                	push   $0x0
  pushl $172
c0102668:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c010266d:	e9 e4 03 00 00       	jmp    c0102a56 <__alltraps>

c0102672 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102672:	6a 00                	push   $0x0
  pushl $173
c0102674:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102679:	e9 d8 03 00 00       	jmp    c0102a56 <__alltraps>

c010267e <vector174>:
.globl vector174
vector174:
  pushl $0
c010267e:	6a 00                	push   $0x0
  pushl $174
c0102680:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102685:	e9 cc 03 00 00       	jmp    c0102a56 <__alltraps>

c010268a <vector175>:
.globl vector175
vector175:
  pushl $0
c010268a:	6a 00                	push   $0x0
  pushl $175
c010268c:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102691:	e9 c0 03 00 00       	jmp    c0102a56 <__alltraps>

c0102696 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102696:	6a 00                	push   $0x0
  pushl $176
c0102698:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c010269d:	e9 b4 03 00 00       	jmp    c0102a56 <__alltraps>

c01026a2 <vector177>:
.globl vector177
vector177:
  pushl $0
c01026a2:	6a 00                	push   $0x0
  pushl $177
c01026a4:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01026a9:	e9 a8 03 00 00       	jmp    c0102a56 <__alltraps>

c01026ae <vector178>:
.globl vector178
vector178:
  pushl $0
c01026ae:	6a 00                	push   $0x0
  pushl $178
c01026b0:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01026b5:	e9 9c 03 00 00       	jmp    c0102a56 <__alltraps>

c01026ba <vector179>:
.globl vector179
vector179:
  pushl $0
c01026ba:	6a 00                	push   $0x0
  pushl $179
c01026bc:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01026c1:	e9 90 03 00 00       	jmp    c0102a56 <__alltraps>

c01026c6 <vector180>:
.globl vector180
vector180:
  pushl $0
c01026c6:	6a 00                	push   $0x0
  pushl $180
c01026c8:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01026cd:	e9 84 03 00 00       	jmp    c0102a56 <__alltraps>

c01026d2 <vector181>:
.globl vector181
vector181:
  pushl $0
c01026d2:	6a 00                	push   $0x0
  pushl $181
c01026d4:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01026d9:	e9 78 03 00 00       	jmp    c0102a56 <__alltraps>

c01026de <vector182>:
.globl vector182
vector182:
  pushl $0
c01026de:	6a 00                	push   $0x0
  pushl $182
c01026e0:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01026e5:	e9 6c 03 00 00       	jmp    c0102a56 <__alltraps>

c01026ea <vector183>:
.globl vector183
vector183:
  pushl $0
c01026ea:	6a 00                	push   $0x0
  pushl $183
c01026ec:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01026f1:	e9 60 03 00 00       	jmp    c0102a56 <__alltraps>

c01026f6 <vector184>:
.globl vector184
vector184:
  pushl $0
c01026f6:	6a 00                	push   $0x0
  pushl $184
c01026f8:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01026fd:	e9 54 03 00 00       	jmp    c0102a56 <__alltraps>

c0102702 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102702:	6a 00                	push   $0x0
  pushl $185
c0102704:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102709:	e9 48 03 00 00       	jmp    c0102a56 <__alltraps>

c010270e <vector186>:
.globl vector186
vector186:
  pushl $0
c010270e:	6a 00                	push   $0x0
  pushl $186
c0102710:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102715:	e9 3c 03 00 00       	jmp    c0102a56 <__alltraps>

c010271a <vector187>:
.globl vector187
vector187:
  pushl $0
c010271a:	6a 00                	push   $0x0
  pushl $187
c010271c:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102721:	e9 30 03 00 00       	jmp    c0102a56 <__alltraps>

c0102726 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102726:	6a 00                	push   $0x0
  pushl $188
c0102728:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c010272d:	e9 24 03 00 00       	jmp    c0102a56 <__alltraps>

c0102732 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102732:	6a 00                	push   $0x0
  pushl $189
c0102734:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102739:	e9 18 03 00 00       	jmp    c0102a56 <__alltraps>

c010273e <vector190>:
.globl vector190
vector190:
  pushl $0
c010273e:	6a 00                	push   $0x0
  pushl $190
c0102740:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102745:	e9 0c 03 00 00       	jmp    c0102a56 <__alltraps>

c010274a <vector191>:
.globl vector191
vector191:
  pushl $0
c010274a:	6a 00                	push   $0x0
  pushl $191
c010274c:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102751:	e9 00 03 00 00       	jmp    c0102a56 <__alltraps>

c0102756 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102756:	6a 00                	push   $0x0
  pushl $192
c0102758:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c010275d:	e9 f4 02 00 00       	jmp    c0102a56 <__alltraps>

c0102762 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102762:	6a 00                	push   $0x0
  pushl $193
c0102764:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102769:	e9 e8 02 00 00       	jmp    c0102a56 <__alltraps>

c010276e <vector194>:
.globl vector194
vector194:
  pushl $0
c010276e:	6a 00                	push   $0x0
  pushl $194
c0102770:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102775:	e9 dc 02 00 00       	jmp    c0102a56 <__alltraps>

c010277a <vector195>:
.globl vector195
vector195:
  pushl $0
c010277a:	6a 00                	push   $0x0
  pushl $195
c010277c:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102781:	e9 d0 02 00 00       	jmp    c0102a56 <__alltraps>

c0102786 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102786:	6a 00                	push   $0x0
  pushl $196
c0102788:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c010278d:	e9 c4 02 00 00       	jmp    c0102a56 <__alltraps>

c0102792 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102792:	6a 00                	push   $0x0
  pushl $197
c0102794:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102799:	e9 b8 02 00 00       	jmp    c0102a56 <__alltraps>

c010279e <vector198>:
.globl vector198
vector198:
  pushl $0
c010279e:	6a 00                	push   $0x0
  pushl $198
c01027a0:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01027a5:	e9 ac 02 00 00       	jmp    c0102a56 <__alltraps>

c01027aa <vector199>:
.globl vector199
vector199:
  pushl $0
c01027aa:	6a 00                	push   $0x0
  pushl $199
c01027ac:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01027b1:	e9 a0 02 00 00       	jmp    c0102a56 <__alltraps>

c01027b6 <vector200>:
.globl vector200
vector200:
  pushl $0
c01027b6:	6a 00                	push   $0x0
  pushl $200
c01027b8:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01027bd:	e9 94 02 00 00       	jmp    c0102a56 <__alltraps>

c01027c2 <vector201>:
.globl vector201
vector201:
  pushl $0
c01027c2:	6a 00                	push   $0x0
  pushl $201
c01027c4:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01027c9:	e9 88 02 00 00       	jmp    c0102a56 <__alltraps>

c01027ce <vector202>:
.globl vector202
vector202:
  pushl $0
c01027ce:	6a 00                	push   $0x0
  pushl $202
c01027d0:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01027d5:	e9 7c 02 00 00       	jmp    c0102a56 <__alltraps>

c01027da <vector203>:
.globl vector203
vector203:
  pushl $0
c01027da:	6a 00                	push   $0x0
  pushl $203
c01027dc:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01027e1:	e9 70 02 00 00       	jmp    c0102a56 <__alltraps>

c01027e6 <vector204>:
.globl vector204
vector204:
  pushl $0
c01027e6:	6a 00                	push   $0x0
  pushl $204
c01027e8:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01027ed:	e9 64 02 00 00       	jmp    c0102a56 <__alltraps>

c01027f2 <vector205>:
.globl vector205
vector205:
  pushl $0
c01027f2:	6a 00                	push   $0x0
  pushl $205
c01027f4:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01027f9:	e9 58 02 00 00       	jmp    c0102a56 <__alltraps>

c01027fe <vector206>:
.globl vector206
vector206:
  pushl $0
c01027fe:	6a 00                	push   $0x0
  pushl $206
c0102800:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102805:	e9 4c 02 00 00       	jmp    c0102a56 <__alltraps>

c010280a <vector207>:
.globl vector207
vector207:
  pushl $0
c010280a:	6a 00                	push   $0x0
  pushl $207
c010280c:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102811:	e9 40 02 00 00       	jmp    c0102a56 <__alltraps>

c0102816 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102816:	6a 00                	push   $0x0
  pushl $208
c0102818:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c010281d:	e9 34 02 00 00       	jmp    c0102a56 <__alltraps>

c0102822 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102822:	6a 00                	push   $0x0
  pushl $209
c0102824:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102829:	e9 28 02 00 00       	jmp    c0102a56 <__alltraps>

c010282e <vector210>:
.globl vector210
vector210:
  pushl $0
c010282e:	6a 00                	push   $0x0
  pushl $210
c0102830:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102835:	e9 1c 02 00 00       	jmp    c0102a56 <__alltraps>

c010283a <vector211>:
.globl vector211
vector211:
  pushl $0
c010283a:	6a 00                	push   $0x0
  pushl $211
c010283c:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102841:	e9 10 02 00 00       	jmp    c0102a56 <__alltraps>

c0102846 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102846:	6a 00                	push   $0x0
  pushl $212
c0102848:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c010284d:	e9 04 02 00 00       	jmp    c0102a56 <__alltraps>

c0102852 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102852:	6a 00                	push   $0x0
  pushl $213
c0102854:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102859:	e9 f8 01 00 00       	jmp    c0102a56 <__alltraps>

c010285e <vector214>:
.globl vector214
vector214:
  pushl $0
c010285e:	6a 00                	push   $0x0
  pushl $214
c0102860:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102865:	e9 ec 01 00 00       	jmp    c0102a56 <__alltraps>

c010286a <vector215>:
.globl vector215
vector215:
  pushl $0
c010286a:	6a 00                	push   $0x0
  pushl $215
c010286c:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102871:	e9 e0 01 00 00       	jmp    c0102a56 <__alltraps>

c0102876 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102876:	6a 00                	push   $0x0
  pushl $216
c0102878:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c010287d:	e9 d4 01 00 00       	jmp    c0102a56 <__alltraps>

c0102882 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102882:	6a 00                	push   $0x0
  pushl $217
c0102884:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102889:	e9 c8 01 00 00       	jmp    c0102a56 <__alltraps>

c010288e <vector218>:
.globl vector218
vector218:
  pushl $0
c010288e:	6a 00                	push   $0x0
  pushl $218
c0102890:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102895:	e9 bc 01 00 00       	jmp    c0102a56 <__alltraps>

c010289a <vector219>:
.globl vector219
vector219:
  pushl $0
c010289a:	6a 00                	push   $0x0
  pushl $219
c010289c:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01028a1:	e9 b0 01 00 00       	jmp    c0102a56 <__alltraps>

c01028a6 <vector220>:
.globl vector220
vector220:
  pushl $0
c01028a6:	6a 00                	push   $0x0
  pushl $220
c01028a8:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01028ad:	e9 a4 01 00 00       	jmp    c0102a56 <__alltraps>

c01028b2 <vector221>:
.globl vector221
vector221:
  pushl $0
c01028b2:	6a 00                	push   $0x0
  pushl $221
c01028b4:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01028b9:	e9 98 01 00 00       	jmp    c0102a56 <__alltraps>

c01028be <vector222>:
.globl vector222
vector222:
  pushl $0
c01028be:	6a 00                	push   $0x0
  pushl $222
c01028c0:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01028c5:	e9 8c 01 00 00       	jmp    c0102a56 <__alltraps>

c01028ca <vector223>:
.globl vector223
vector223:
  pushl $0
c01028ca:	6a 00                	push   $0x0
  pushl $223
c01028cc:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01028d1:	e9 80 01 00 00       	jmp    c0102a56 <__alltraps>

c01028d6 <vector224>:
.globl vector224
vector224:
  pushl $0
c01028d6:	6a 00                	push   $0x0
  pushl $224
c01028d8:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01028dd:	e9 74 01 00 00       	jmp    c0102a56 <__alltraps>

c01028e2 <vector225>:
.globl vector225
vector225:
  pushl $0
c01028e2:	6a 00                	push   $0x0
  pushl $225
c01028e4:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01028e9:	e9 68 01 00 00       	jmp    c0102a56 <__alltraps>

c01028ee <vector226>:
.globl vector226
vector226:
  pushl $0
c01028ee:	6a 00                	push   $0x0
  pushl $226
c01028f0:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01028f5:	e9 5c 01 00 00       	jmp    c0102a56 <__alltraps>

c01028fa <vector227>:
.globl vector227
vector227:
  pushl $0
c01028fa:	6a 00                	push   $0x0
  pushl $227
c01028fc:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102901:	e9 50 01 00 00       	jmp    c0102a56 <__alltraps>

c0102906 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102906:	6a 00                	push   $0x0
  pushl $228
c0102908:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010290d:	e9 44 01 00 00       	jmp    c0102a56 <__alltraps>

c0102912 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102912:	6a 00                	push   $0x0
  pushl $229
c0102914:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102919:	e9 38 01 00 00       	jmp    c0102a56 <__alltraps>

c010291e <vector230>:
.globl vector230
vector230:
  pushl $0
c010291e:	6a 00                	push   $0x0
  pushl $230
c0102920:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102925:	e9 2c 01 00 00       	jmp    c0102a56 <__alltraps>

c010292a <vector231>:
.globl vector231
vector231:
  pushl $0
c010292a:	6a 00                	push   $0x0
  pushl $231
c010292c:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102931:	e9 20 01 00 00       	jmp    c0102a56 <__alltraps>

c0102936 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102936:	6a 00                	push   $0x0
  pushl $232
c0102938:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010293d:	e9 14 01 00 00       	jmp    c0102a56 <__alltraps>

c0102942 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102942:	6a 00                	push   $0x0
  pushl $233
c0102944:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102949:	e9 08 01 00 00       	jmp    c0102a56 <__alltraps>

c010294e <vector234>:
.globl vector234
vector234:
  pushl $0
c010294e:	6a 00                	push   $0x0
  pushl $234
c0102950:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102955:	e9 fc 00 00 00       	jmp    c0102a56 <__alltraps>

c010295a <vector235>:
.globl vector235
vector235:
  pushl $0
c010295a:	6a 00                	push   $0x0
  pushl $235
c010295c:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102961:	e9 f0 00 00 00       	jmp    c0102a56 <__alltraps>

c0102966 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102966:	6a 00                	push   $0x0
  pushl $236
c0102968:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c010296d:	e9 e4 00 00 00       	jmp    c0102a56 <__alltraps>

c0102972 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102972:	6a 00                	push   $0x0
  pushl $237
c0102974:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102979:	e9 d8 00 00 00       	jmp    c0102a56 <__alltraps>

c010297e <vector238>:
.globl vector238
vector238:
  pushl $0
c010297e:	6a 00                	push   $0x0
  pushl $238
c0102980:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102985:	e9 cc 00 00 00       	jmp    c0102a56 <__alltraps>

c010298a <vector239>:
.globl vector239
vector239:
  pushl $0
c010298a:	6a 00                	push   $0x0
  pushl $239
c010298c:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102991:	e9 c0 00 00 00       	jmp    c0102a56 <__alltraps>

c0102996 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102996:	6a 00                	push   $0x0
  pushl $240
c0102998:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c010299d:	e9 b4 00 00 00       	jmp    c0102a56 <__alltraps>

c01029a2 <vector241>:
.globl vector241
vector241:
  pushl $0
c01029a2:	6a 00                	push   $0x0
  pushl $241
c01029a4:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01029a9:	e9 a8 00 00 00       	jmp    c0102a56 <__alltraps>

c01029ae <vector242>:
.globl vector242
vector242:
  pushl $0
c01029ae:	6a 00                	push   $0x0
  pushl $242
c01029b0:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01029b5:	e9 9c 00 00 00       	jmp    c0102a56 <__alltraps>

c01029ba <vector243>:
.globl vector243
vector243:
  pushl $0
c01029ba:	6a 00                	push   $0x0
  pushl $243
c01029bc:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01029c1:	e9 90 00 00 00       	jmp    c0102a56 <__alltraps>

c01029c6 <vector244>:
.globl vector244
vector244:
  pushl $0
c01029c6:	6a 00                	push   $0x0
  pushl $244
c01029c8:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01029cd:	e9 84 00 00 00       	jmp    c0102a56 <__alltraps>

c01029d2 <vector245>:
.globl vector245
vector245:
  pushl $0
c01029d2:	6a 00                	push   $0x0
  pushl $245
c01029d4:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01029d9:	e9 78 00 00 00       	jmp    c0102a56 <__alltraps>

c01029de <vector246>:
.globl vector246
vector246:
  pushl $0
c01029de:	6a 00                	push   $0x0
  pushl $246
c01029e0:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01029e5:	e9 6c 00 00 00       	jmp    c0102a56 <__alltraps>

c01029ea <vector247>:
.globl vector247
vector247:
  pushl $0
c01029ea:	6a 00                	push   $0x0
  pushl $247
c01029ec:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01029f1:	e9 60 00 00 00       	jmp    c0102a56 <__alltraps>

c01029f6 <vector248>:
.globl vector248
vector248:
  pushl $0
c01029f6:	6a 00                	push   $0x0
  pushl $248
c01029f8:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01029fd:	e9 54 00 00 00       	jmp    c0102a56 <__alltraps>

c0102a02 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102a02:	6a 00                	push   $0x0
  pushl $249
c0102a04:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102a09:	e9 48 00 00 00       	jmp    c0102a56 <__alltraps>

c0102a0e <vector250>:
.globl vector250
vector250:
  pushl $0
c0102a0e:	6a 00                	push   $0x0
  pushl $250
c0102a10:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102a15:	e9 3c 00 00 00       	jmp    c0102a56 <__alltraps>

c0102a1a <vector251>:
.globl vector251
vector251:
  pushl $0
c0102a1a:	6a 00                	push   $0x0
  pushl $251
c0102a1c:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102a21:	e9 30 00 00 00       	jmp    c0102a56 <__alltraps>

c0102a26 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102a26:	6a 00                	push   $0x0
  pushl $252
c0102a28:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102a2d:	e9 24 00 00 00       	jmp    c0102a56 <__alltraps>

c0102a32 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102a32:	6a 00                	push   $0x0
  pushl $253
c0102a34:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102a39:	e9 18 00 00 00       	jmp    c0102a56 <__alltraps>

c0102a3e <vector254>:
.globl vector254
vector254:
  pushl $0
c0102a3e:	6a 00                	push   $0x0
  pushl $254
c0102a40:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102a45:	e9 0c 00 00 00       	jmp    c0102a56 <__alltraps>

c0102a4a <vector255>:
.globl vector255
vector255:
  pushl $0
c0102a4a:	6a 00                	push   $0x0
  pushl $255
c0102a4c:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102a51:	e9 00 00 00 00       	jmp    c0102a56 <__alltraps>

c0102a56 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102a56:	1e                   	push   %ds
    pushl %es
c0102a57:	06                   	push   %es
    pushl %fs
c0102a58:	0f a0                	push   %fs
    pushl %gs
c0102a5a:	0f a8                	push   %gs
    pushal
c0102a5c:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102a5d:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102a62:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102a64:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102a66:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102a67:	e8 60 f5 ff ff       	call   c0101fcc <trap>

    # pop the pushed stack pointer
    popl %esp
c0102a6c:	5c                   	pop    %esp

c0102a6d <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102a6d:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102a6e:	0f a9                	pop    %gs
    popl %fs
c0102a70:	0f a1                	pop    %fs
    popl %es
c0102a72:	07                   	pop    %es
    popl %ds
c0102a73:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102a74:	83 c4 08             	add    $0x8,%esp
    iret
c0102a77:	cf                   	iret   

c0102a78 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102a78:	55                   	push   %ebp
c0102a79:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102a7b:	a1 18 cf 11 c0       	mov    0xc011cf18,%eax
c0102a80:	8b 55 08             	mov    0x8(%ebp),%edx
c0102a83:	29 c2                	sub    %eax,%edx
c0102a85:	89 d0                	mov    %edx,%eax
c0102a87:	c1 f8 02             	sar    $0x2,%eax
c0102a8a:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102a90:	5d                   	pop    %ebp
c0102a91:	c3                   	ret    

c0102a92 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102a92:	55                   	push   %ebp
c0102a93:	89 e5                	mov    %esp,%ebp
c0102a95:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102a98:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a9b:	89 04 24             	mov    %eax,(%esp)
c0102a9e:	e8 d5 ff ff ff       	call   c0102a78 <page2ppn>
c0102aa3:	c1 e0 0c             	shl    $0xc,%eax
}
c0102aa6:	c9                   	leave  
c0102aa7:	c3                   	ret    

c0102aa8 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0102aa8:	55                   	push   %ebp
c0102aa9:	89 e5                	mov    %esp,%ebp
c0102aab:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102aae:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ab1:	c1 e8 0c             	shr    $0xc,%eax
c0102ab4:	89 c2                	mov    %eax,%edx
c0102ab6:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102abb:	39 c2                	cmp    %eax,%edx
c0102abd:	72 1c                	jb     c0102adb <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102abf:	c7 44 24 08 30 69 10 	movl   $0xc0106930,0x8(%esp)
c0102ac6:	c0 
c0102ac7:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0102ace:	00 
c0102acf:	c7 04 24 4f 69 10 c0 	movl   $0xc010694f,(%esp)
c0102ad6:	e8 5a d9 ff ff       	call   c0100435 <__panic>
    }
    return &pages[PPN(pa)];
c0102adb:	8b 0d 18 cf 11 c0    	mov    0xc011cf18,%ecx
c0102ae1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ae4:	c1 e8 0c             	shr    $0xc,%eax
c0102ae7:	89 c2                	mov    %eax,%edx
c0102ae9:	89 d0                	mov    %edx,%eax
c0102aeb:	c1 e0 02             	shl    $0x2,%eax
c0102aee:	01 d0                	add    %edx,%eax
c0102af0:	c1 e0 02             	shl    $0x2,%eax
c0102af3:	01 c8                	add    %ecx,%eax
}
c0102af5:	c9                   	leave  
c0102af6:	c3                   	ret    

c0102af7 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0102af7:	55                   	push   %ebp
c0102af8:	89 e5                	mov    %esp,%ebp
c0102afa:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102afd:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b00:	89 04 24             	mov    %eax,(%esp)
c0102b03:	e8 8a ff ff ff       	call   c0102a92 <page2pa>
c0102b08:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b0e:	c1 e8 0c             	shr    $0xc,%eax
c0102b11:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102b14:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102b19:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102b1c:	72 23                	jb     c0102b41 <page2kva+0x4a>
c0102b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b21:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102b25:	c7 44 24 08 60 69 10 	movl   $0xc0106960,0x8(%esp)
c0102b2c:	c0 
c0102b2d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0102b34:	00 
c0102b35:	c7 04 24 4f 69 10 c0 	movl   $0xc010694f,(%esp)
c0102b3c:	e8 f4 d8 ff ff       	call   c0100435 <__panic>
c0102b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b44:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102b49:	c9                   	leave  
c0102b4a:	c3                   	ret    

c0102b4b <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102b4b:	55                   	push   %ebp
c0102b4c:	89 e5                	mov    %esp,%ebp
c0102b4e:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102b51:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b54:	83 e0 01             	and    $0x1,%eax
c0102b57:	85 c0                	test   %eax,%eax
c0102b59:	75 1c                	jne    c0102b77 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102b5b:	c7 44 24 08 84 69 10 	movl   $0xc0106984,0x8(%esp)
c0102b62:	c0 
c0102b63:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0102b6a:	00 
c0102b6b:	c7 04 24 4f 69 10 c0 	movl   $0xc010694f,(%esp)
c0102b72:	e8 be d8 ff ff       	call   c0100435 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102b7f:	89 04 24             	mov    %eax,(%esp)
c0102b82:	e8 21 ff ff ff       	call   c0102aa8 <pa2page>
}
c0102b87:	c9                   	leave  
c0102b88:	c3                   	ret    

c0102b89 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0102b89:	55                   	push   %ebp
c0102b8a:	89 e5                	mov    %esp,%ebp
c0102b8c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102b8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102b97:	89 04 24             	mov    %eax,(%esp)
c0102b9a:	e8 09 ff ff ff       	call   c0102aa8 <pa2page>
}
c0102b9f:	c9                   	leave  
c0102ba0:	c3                   	ret    

c0102ba1 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102ba1:	55                   	push   %ebp
c0102ba2:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102ba4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ba7:	8b 00                	mov    (%eax),%eax
}
c0102ba9:	5d                   	pop    %ebp
c0102baa:	c3                   	ret    

c0102bab <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102bab:	55                   	push   %ebp
c0102bac:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102bae:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bb1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bb4:	89 10                	mov    %edx,(%eax)
}
c0102bb6:	90                   	nop
c0102bb7:	5d                   	pop    %ebp
c0102bb8:	c3                   	ret    

c0102bb9 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102bb9:	55                   	push   %ebp
c0102bba:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102bbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bbf:	8b 00                	mov    (%eax),%eax
c0102bc1:	8d 50 01             	lea    0x1(%eax),%edx
c0102bc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bc7:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102bc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bcc:	8b 00                	mov    (%eax),%eax
}
c0102bce:	5d                   	pop    %ebp
c0102bcf:	c3                   	ret    

c0102bd0 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102bd0:	55                   	push   %ebp
c0102bd1:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102bd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bd6:	8b 00                	mov    (%eax),%eax
c0102bd8:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102bdb:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bde:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102be0:	8b 45 08             	mov    0x8(%ebp),%eax
c0102be3:	8b 00                	mov    (%eax),%eax
}
c0102be5:	5d                   	pop    %ebp
c0102be6:	c3                   	ret    

c0102be7 <__intr_save>:
__intr_save(void) {
c0102be7:	55                   	push   %ebp
c0102be8:	89 e5                	mov    %esp,%ebp
c0102bea:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102bed:	9c                   	pushf  
c0102bee:	58                   	pop    %eax
c0102bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102bf5:	25 00 02 00 00       	and    $0x200,%eax
c0102bfa:	85 c0                	test   %eax,%eax
c0102bfc:	74 0c                	je     c0102c0a <__intr_save+0x23>
        intr_disable();
c0102bfe:	e8 95 ed ff ff       	call   c0101998 <intr_disable>
        return 1;
c0102c03:	b8 01 00 00 00       	mov    $0x1,%eax
c0102c08:	eb 05                	jmp    c0102c0f <__intr_save+0x28>
    return 0;
c0102c0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102c0f:	c9                   	leave  
c0102c10:	c3                   	ret    

c0102c11 <__intr_restore>:
__intr_restore(bool flag) {
c0102c11:	55                   	push   %ebp
c0102c12:	89 e5                	mov    %esp,%ebp
c0102c14:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102c17:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102c1b:	74 05                	je     c0102c22 <__intr_restore+0x11>
        intr_enable();
c0102c1d:	e8 6a ed ff ff       	call   c010198c <intr_enable>
}
c0102c22:	90                   	nop
c0102c23:	c9                   	leave  
c0102c24:	c3                   	ret    

c0102c25 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102c25:	55                   	push   %ebp
c0102c26:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102c28:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c2b:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102c2e:	b8 23 00 00 00       	mov    $0x23,%eax
c0102c33:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102c35:	b8 23 00 00 00       	mov    $0x23,%eax
c0102c3a:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102c3c:	b8 10 00 00 00       	mov    $0x10,%eax
c0102c41:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102c43:	b8 10 00 00 00       	mov    $0x10,%eax
c0102c48:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102c4a:	b8 10 00 00 00       	mov    $0x10,%eax
c0102c4f:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102c51:	ea 58 2c 10 c0 08 00 	ljmp   $0x8,$0xc0102c58
}
c0102c58:	90                   	nop
c0102c59:	5d                   	pop    %ebp
c0102c5a:	c3                   	ret    

c0102c5b <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102c5b:	f3 0f 1e fb          	endbr32 
c0102c5f:	55                   	push   %ebp
c0102c60:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102c62:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c65:	a3 a4 ce 11 c0       	mov    %eax,0xc011cea4
}
c0102c6a:	90                   	nop
c0102c6b:	5d                   	pop    %ebp
c0102c6c:	c3                   	ret    

c0102c6d <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102c6d:	f3 0f 1e fb          	endbr32 
c0102c71:	55                   	push   %ebp
c0102c72:	89 e5                	mov    %esp,%ebp
c0102c74:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102c77:	b8 00 90 11 c0       	mov    $0xc0119000,%eax
c0102c7c:	89 04 24             	mov    %eax,(%esp)
c0102c7f:	e8 d7 ff ff ff       	call   c0102c5b <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102c84:	66 c7 05 a8 ce 11 c0 	movw   $0x10,0xc011cea8
c0102c8b:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102c8d:	66 c7 05 28 9a 11 c0 	movw   $0x68,0xc0119a28
c0102c94:	68 00 
c0102c96:	b8 a0 ce 11 c0       	mov    $0xc011cea0,%eax
c0102c9b:	0f b7 c0             	movzwl %ax,%eax
c0102c9e:	66 a3 2a 9a 11 c0    	mov    %ax,0xc0119a2a
c0102ca4:	b8 a0 ce 11 c0       	mov    $0xc011cea0,%eax
c0102ca9:	c1 e8 10             	shr    $0x10,%eax
c0102cac:	a2 2c 9a 11 c0       	mov    %al,0xc0119a2c
c0102cb1:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0102cb8:	24 f0                	and    $0xf0,%al
c0102cba:	0c 09                	or     $0x9,%al
c0102cbc:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0102cc1:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0102cc8:	24 ef                	and    $0xef,%al
c0102cca:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0102ccf:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0102cd6:	24 9f                	and    $0x9f,%al
c0102cd8:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0102cdd:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0102ce4:	0c 80                	or     $0x80,%al
c0102ce6:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0102ceb:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0102cf2:	24 f0                	and    $0xf0,%al
c0102cf4:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0102cf9:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0102d00:	24 ef                	and    $0xef,%al
c0102d02:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0102d07:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0102d0e:	24 df                	and    $0xdf,%al
c0102d10:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0102d15:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0102d1c:	0c 40                	or     $0x40,%al
c0102d1e:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0102d23:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0102d2a:	24 7f                	and    $0x7f,%al
c0102d2c:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0102d31:	b8 a0 ce 11 c0       	mov    $0xc011cea0,%eax
c0102d36:	c1 e8 18             	shr    $0x18,%eax
c0102d39:	a2 2f 9a 11 c0       	mov    %al,0xc0119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102d3e:	c7 04 24 30 9a 11 c0 	movl   $0xc0119a30,(%esp)
c0102d45:	e8 db fe ff ff       	call   c0102c25 <lgdt>
c0102d4a:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102d50:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102d54:	0f 00 d8             	ltr    %ax
}
c0102d57:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0102d58:	90                   	nop
c0102d59:	c9                   	leave  
c0102d5a:	c3                   	ret    

c0102d5b <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102d5b:	f3 0f 1e fb          	endbr32 
c0102d5f:	55                   	push   %ebp
c0102d60:	89 e5                	mov    %esp,%ebp
c0102d62:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102d65:	c7 05 10 cf 11 c0 10 	movl   $0xc0107310,0xc011cf10
c0102d6c:	73 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102d6f:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102d74:	8b 00                	mov    (%eax),%eax
c0102d76:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102d7a:	c7 04 24 b0 69 10 c0 	movl   $0xc01069b0,(%esp)
c0102d81:	e8 43 d5 ff ff       	call   c01002c9 <cprintf>
    pmm_manager->init();
c0102d86:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102d8b:	8b 40 04             	mov    0x4(%eax),%eax
c0102d8e:	ff d0                	call   *%eax
}
c0102d90:	90                   	nop
c0102d91:	c9                   	leave  
c0102d92:	c3                   	ret    

c0102d93 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102d93:	f3 0f 1e fb          	endbr32 
c0102d97:	55                   	push   %ebp
c0102d98:	89 e5                	mov    %esp,%ebp
c0102d9a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102d9d:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102da2:	8b 40 08             	mov    0x8(%eax),%eax
c0102da5:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102da8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102dac:	8b 55 08             	mov    0x8(%ebp),%edx
c0102daf:	89 14 24             	mov    %edx,(%esp)
c0102db2:	ff d0                	call   *%eax
}
c0102db4:	90                   	nop
c0102db5:	c9                   	leave  
c0102db6:	c3                   	ret    

c0102db7 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102db7:	f3 0f 1e fb          	endbr32 
c0102dbb:	55                   	push   %ebp
c0102dbc:	89 e5                	mov    %esp,%ebp
c0102dbe:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102dc1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102dc8:	e8 1a fe ff ff       	call   c0102be7 <__intr_save>
c0102dcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102dd0:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102dd5:	8b 40 0c             	mov    0xc(%eax),%eax
c0102dd8:	8b 55 08             	mov    0x8(%ebp),%edx
c0102ddb:	89 14 24             	mov    %edx,(%esp)
c0102dde:	ff d0                	call   *%eax
c0102de0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102de6:	89 04 24             	mov    %eax,(%esp)
c0102de9:	e8 23 fe ff ff       	call   c0102c11 <__intr_restore>
    return page;
c0102dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102df1:	c9                   	leave  
c0102df2:	c3                   	ret    

c0102df3 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102df3:	f3 0f 1e fb          	endbr32 
c0102df7:	55                   	push   %ebp
c0102df8:	89 e5                	mov    %esp,%ebp
c0102dfa:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102dfd:	e8 e5 fd ff ff       	call   c0102be7 <__intr_save>
c0102e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102e05:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102e0a:	8b 40 10             	mov    0x10(%eax),%eax
c0102e0d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102e10:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102e14:	8b 55 08             	mov    0x8(%ebp),%edx
c0102e17:	89 14 24             	mov    %edx,(%esp)
c0102e1a:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e1f:	89 04 24             	mov    %eax,(%esp)
c0102e22:	e8 ea fd ff ff       	call   c0102c11 <__intr_restore>
}
c0102e27:	90                   	nop
c0102e28:	c9                   	leave  
c0102e29:	c3                   	ret    

c0102e2a <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102e2a:	f3 0f 1e fb          	endbr32 
c0102e2e:	55                   	push   %ebp
c0102e2f:	89 e5                	mov    %esp,%ebp
c0102e31:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102e34:	e8 ae fd ff ff       	call   c0102be7 <__intr_save>
c0102e39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102e3c:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102e41:	8b 40 14             	mov    0x14(%eax),%eax
c0102e44:	ff d0                	call   *%eax
c0102e46:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e4c:	89 04 24             	mov    %eax,(%esp)
c0102e4f:	e8 bd fd ff ff       	call   c0102c11 <__intr_restore>
    return ret;
c0102e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102e57:	c9                   	leave  
c0102e58:	c3                   	ret    

c0102e59 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102e59:	f3 0f 1e fb          	endbr32 
c0102e5d:	55                   	push   %ebp
c0102e5e:	89 e5                	mov    %esp,%ebp
c0102e60:	57                   	push   %edi
c0102e61:	56                   	push   %esi
c0102e62:	53                   	push   %ebx
c0102e63:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102e69:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102e70:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102e77:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102e7e:	c7 04 24 c7 69 10 c0 	movl   $0xc01069c7,(%esp)
c0102e85:	e8 3f d4 ff ff       	call   c01002c9 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102e8a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e91:	e9 1a 01 00 00       	jmp    c0102fb0 <page_init+0x157>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102e96:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e99:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e9c:	89 d0                	mov    %edx,%eax
c0102e9e:	c1 e0 02             	shl    $0x2,%eax
c0102ea1:	01 d0                	add    %edx,%eax
c0102ea3:	c1 e0 02             	shl    $0x2,%eax
c0102ea6:	01 c8                	add    %ecx,%eax
c0102ea8:	8b 50 08             	mov    0x8(%eax),%edx
c0102eab:	8b 40 04             	mov    0x4(%eax),%eax
c0102eae:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0102eb1:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0102eb4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102eb7:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102eba:	89 d0                	mov    %edx,%eax
c0102ebc:	c1 e0 02             	shl    $0x2,%eax
c0102ebf:	01 d0                	add    %edx,%eax
c0102ec1:	c1 e0 02             	shl    $0x2,%eax
c0102ec4:	01 c8                	add    %ecx,%eax
c0102ec6:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102ec9:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ecc:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102ecf:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102ed2:	01 c8                	add    %ecx,%eax
c0102ed4:	11 da                	adc    %ebx,%edx
c0102ed6:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102ed9:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102edc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102edf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ee2:	89 d0                	mov    %edx,%eax
c0102ee4:	c1 e0 02             	shl    $0x2,%eax
c0102ee7:	01 d0                	add    %edx,%eax
c0102ee9:	c1 e0 02             	shl    $0x2,%eax
c0102eec:	01 c8                	add    %ecx,%eax
c0102eee:	83 c0 14             	add    $0x14,%eax
c0102ef1:	8b 00                	mov    (%eax),%eax
c0102ef3:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102ef6:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102ef9:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102efc:	83 c0 ff             	add    $0xffffffff,%eax
c0102eff:	83 d2 ff             	adc    $0xffffffff,%edx
c0102f02:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102f08:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102f0e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f11:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f14:	89 d0                	mov    %edx,%eax
c0102f16:	c1 e0 02             	shl    $0x2,%eax
c0102f19:	01 d0                	add    %edx,%eax
c0102f1b:	c1 e0 02             	shl    $0x2,%eax
c0102f1e:	01 c8                	add    %ecx,%eax
c0102f20:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102f23:	8b 58 10             	mov    0x10(%eax),%ebx
c0102f26:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102f29:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102f2d:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102f33:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102f39:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102f3d:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102f41:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102f44:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102f47:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102f4b:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102f4f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102f53:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102f57:	c7 04 24 d4 69 10 c0 	movl   $0xc01069d4,(%esp)
c0102f5e:	e8 66 d3 ff ff       	call   c01002c9 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102f63:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102f66:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102f69:	89 d0                	mov    %edx,%eax
c0102f6b:	c1 e0 02             	shl    $0x2,%eax
c0102f6e:	01 d0                	add    %edx,%eax
c0102f70:	c1 e0 02             	shl    $0x2,%eax
c0102f73:	01 c8                	add    %ecx,%eax
c0102f75:	83 c0 14             	add    $0x14,%eax
c0102f78:	8b 00                	mov    (%eax),%eax
c0102f7a:	83 f8 01             	cmp    $0x1,%eax
c0102f7d:	75 2e                	jne    c0102fad <page_init+0x154>
            if (maxpa < end && begin < KMEMSIZE) {
c0102f7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102f82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102f85:	3b 45 98             	cmp    -0x68(%ebp),%eax
c0102f88:	89 d0                	mov    %edx,%eax
c0102f8a:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c0102f8d:	73 1e                	jae    c0102fad <page_init+0x154>
c0102f8f:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0102f94:	b8 00 00 00 00       	mov    $0x0,%eax
c0102f99:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c0102f9c:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c0102f9f:	72 0c                	jb     c0102fad <page_init+0x154>
                maxpa = end;
c0102fa1:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102fa4:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0102fa7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102faa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c0102fad:	ff 45 dc             	incl   -0x24(%ebp)
c0102fb0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102fb3:	8b 00                	mov    (%eax),%eax
c0102fb5:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0102fb8:	0f 8c d8 fe ff ff    	jl     c0102e96 <page_init+0x3d>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102fbe:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0102fc3:	b8 00 00 00 00       	mov    $0x0,%eax
c0102fc8:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c0102fcb:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c0102fce:	73 0e                	jae    c0102fde <page_init+0x185>
        maxpa = KMEMSIZE;
c0102fd0:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102fd7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102fde:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102fe1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102fe4:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102fe8:	c1 ea 0c             	shr    $0xc,%edx
c0102feb:	a3 80 ce 11 c0       	mov    %eax,0xc011ce80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102ff0:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0102ff7:	b8 28 cf 11 c0       	mov    $0xc011cf28,%eax
c0102ffc:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102fff:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0103002:	01 d0                	add    %edx,%eax
c0103004:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0103007:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010300a:	ba 00 00 00 00       	mov    $0x0,%edx
c010300f:	f7 75 c0             	divl   -0x40(%ebp)
c0103012:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103015:	29 d0                	sub    %edx,%eax
c0103017:	a3 18 cf 11 c0       	mov    %eax,0xc011cf18

    for (i = 0; i < npage; i ++) {
c010301c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0103023:	eb 2f                	jmp    c0103054 <page_init+0x1fb>
        SetPageReserved(pages + i);
c0103025:	8b 0d 18 cf 11 c0    	mov    0xc011cf18,%ecx
c010302b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010302e:	89 d0                	mov    %edx,%eax
c0103030:	c1 e0 02             	shl    $0x2,%eax
c0103033:	01 d0                	add    %edx,%eax
c0103035:	c1 e0 02             	shl    $0x2,%eax
c0103038:	01 c8                	add    %ecx,%eax
c010303a:	83 c0 04             	add    $0x4,%eax
c010303d:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c0103044:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0103047:	8b 45 90             	mov    -0x70(%ebp),%eax
c010304a:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010304d:	0f ab 10             	bts    %edx,(%eax)
}
c0103050:	90                   	nop
    for (i = 0; i < npage; i ++) {
c0103051:	ff 45 dc             	incl   -0x24(%ebp)
c0103054:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103057:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c010305c:	39 c2                	cmp    %eax,%edx
c010305e:	72 c5                	jb     c0103025 <page_init+0x1cc>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0103060:	8b 15 80 ce 11 c0    	mov    0xc011ce80,%edx
c0103066:	89 d0                	mov    %edx,%eax
c0103068:	c1 e0 02             	shl    $0x2,%eax
c010306b:	01 d0                	add    %edx,%eax
c010306d:	c1 e0 02             	shl    $0x2,%eax
c0103070:	89 c2                	mov    %eax,%edx
c0103072:	a1 18 cf 11 c0       	mov    0xc011cf18,%eax
c0103077:	01 d0                	add    %edx,%eax
c0103079:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010307c:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c0103083:	77 23                	ja     c01030a8 <page_init+0x24f>
c0103085:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103088:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010308c:	c7 44 24 08 04 6a 10 	movl   $0xc0106a04,0x8(%esp)
c0103093:	c0 
c0103094:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010309b:	00 
c010309c:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01030a3:	e8 8d d3 ff ff       	call   c0100435 <__panic>
c01030a8:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01030ab:	05 00 00 00 40       	add    $0x40000000,%eax
c01030b0:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c01030b3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01030ba:	e9 4b 01 00 00       	jmp    c010320a <page_init+0x3b1>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01030bf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01030c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01030c5:	89 d0                	mov    %edx,%eax
c01030c7:	c1 e0 02             	shl    $0x2,%eax
c01030ca:	01 d0                	add    %edx,%eax
c01030cc:	c1 e0 02             	shl    $0x2,%eax
c01030cf:	01 c8                	add    %ecx,%eax
c01030d1:	8b 50 08             	mov    0x8(%eax),%edx
c01030d4:	8b 40 04             	mov    0x4(%eax),%eax
c01030d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01030da:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01030dd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01030e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01030e3:	89 d0                	mov    %edx,%eax
c01030e5:	c1 e0 02             	shl    $0x2,%eax
c01030e8:	01 d0                	add    %edx,%eax
c01030ea:	c1 e0 02             	shl    $0x2,%eax
c01030ed:	01 c8                	add    %ecx,%eax
c01030ef:	8b 48 0c             	mov    0xc(%eax),%ecx
c01030f2:	8b 58 10             	mov    0x10(%eax),%ebx
c01030f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01030f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01030fb:	01 c8                	add    %ecx,%eax
c01030fd:	11 da                	adc    %ebx,%edx
c01030ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103102:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0103105:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103108:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010310b:	89 d0                	mov    %edx,%eax
c010310d:	c1 e0 02             	shl    $0x2,%eax
c0103110:	01 d0                	add    %edx,%eax
c0103112:	c1 e0 02             	shl    $0x2,%eax
c0103115:	01 c8                	add    %ecx,%eax
c0103117:	83 c0 14             	add    $0x14,%eax
c010311a:	8b 00                	mov    (%eax),%eax
c010311c:	83 f8 01             	cmp    $0x1,%eax
c010311f:	0f 85 e2 00 00 00    	jne    c0103207 <page_init+0x3ae>
            if (begin < freemem) {
c0103125:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103128:	ba 00 00 00 00       	mov    $0x0,%edx
c010312d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0103130:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0103133:	19 d1                	sbb    %edx,%ecx
c0103135:	73 0d                	jae    c0103144 <page_init+0x2eb>
                begin = freemem;
c0103137:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010313a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010313d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0103144:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0103149:	b8 00 00 00 00       	mov    $0x0,%eax
c010314e:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c0103151:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0103154:	73 0e                	jae    c0103164 <page_init+0x30b>
                end = KMEMSIZE;
c0103156:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c010315d:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0103164:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103167:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010316a:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010316d:	89 d0                	mov    %edx,%eax
c010316f:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0103172:	0f 83 8f 00 00 00    	jae    c0103207 <page_init+0x3ae>
                begin = ROUNDUP(begin, PGSIZE);
c0103178:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c010317f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103182:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103185:	01 d0                	add    %edx,%eax
c0103187:	48                   	dec    %eax
c0103188:	89 45 ac             	mov    %eax,-0x54(%ebp)
c010318b:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010318e:	ba 00 00 00 00       	mov    $0x0,%edx
c0103193:	f7 75 b0             	divl   -0x50(%ebp)
c0103196:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103199:	29 d0                	sub    %edx,%eax
c010319b:	ba 00 00 00 00       	mov    $0x0,%edx
c01031a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01031a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c01031a6:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01031a9:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01031ac:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01031af:	ba 00 00 00 00       	mov    $0x0,%edx
c01031b4:	89 c3                	mov    %eax,%ebx
c01031b6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c01031bc:	89 de                	mov    %ebx,%esi
c01031be:	89 d0                	mov    %edx,%eax
c01031c0:	83 e0 00             	and    $0x0,%eax
c01031c3:	89 c7                	mov    %eax,%edi
c01031c5:	89 75 c8             	mov    %esi,-0x38(%ebp)
c01031c8:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c01031cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01031ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01031d1:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01031d4:	89 d0                	mov    %edx,%eax
c01031d6:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01031d9:	73 2c                	jae    c0103207 <page_init+0x3ae>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c01031db:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01031de:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01031e1:	2b 45 d0             	sub    -0x30(%ebp),%eax
c01031e4:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c01031e7:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01031eb:	c1 ea 0c             	shr    $0xc,%edx
c01031ee:	89 c3                	mov    %eax,%ebx
c01031f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01031f3:	89 04 24             	mov    %eax,(%esp)
c01031f6:	e8 ad f8 ff ff       	call   c0102aa8 <pa2page>
c01031fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01031ff:	89 04 24             	mov    %eax,(%esp)
c0103202:	e8 8c fb ff ff       	call   c0102d93 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c0103207:	ff 45 dc             	incl   -0x24(%ebp)
c010320a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010320d:	8b 00                	mov    (%eax),%eax
c010320f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103212:	0f 8c a7 fe ff ff    	jl     c01030bf <page_init+0x266>
                }
            }
        }
    }
}
c0103218:	90                   	nop
c0103219:	90                   	nop
c010321a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0103220:	5b                   	pop    %ebx
c0103221:	5e                   	pop    %esi
c0103222:	5f                   	pop    %edi
c0103223:	5d                   	pop    %ebp
c0103224:	c3                   	ret    

c0103225 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0103225:	f3 0f 1e fb          	endbr32 
c0103229:	55                   	push   %ebp
c010322a:	89 e5                	mov    %esp,%ebp
c010322c:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c010322f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103232:	33 45 14             	xor    0x14(%ebp),%eax
c0103235:	25 ff 0f 00 00       	and    $0xfff,%eax
c010323a:	85 c0                	test   %eax,%eax
c010323c:	74 24                	je     c0103262 <boot_map_segment+0x3d>
c010323e:	c7 44 24 0c 36 6a 10 	movl   $0xc0106a36,0xc(%esp)
c0103245:	c0 
c0103246:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c010324d:	c0 
c010324e:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0103255:	00 
c0103256:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c010325d:	e8 d3 d1 ff ff       	call   c0100435 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103262:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103269:	8b 45 0c             	mov    0xc(%ebp),%eax
c010326c:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103271:	89 c2                	mov    %eax,%edx
c0103273:	8b 45 10             	mov    0x10(%ebp),%eax
c0103276:	01 c2                	add    %eax,%edx
c0103278:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010327b:	01 d0                	add    %edx,%eax
c010327d:	48                   	dec    %eax
c010327e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103281:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103284:	ba 00 00 00 00       	mov    $0x0,%edx
c0103289:	f7 75 f0             	divl   -0x10(%ebp)
c010328c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010328f:	29 d0                	sub    %edx,%eax
c0103291:	c1 e8 0c             	shr    $0xc,%eax
c0103294:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103297:	8b 45 0c             	mov    0xc(%ebp),%eax
c010329a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010329d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032a5:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c01032a8:	8b 45 14             	mov    0x14(%ebp),%eax
c01032ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01032ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01032b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032b6:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01032b9:	eb 68                	jmp    c0103323 <boot_map_segment+0xfe>
        pte_t *ptep = get_pte(pgdir, la, 1);
c01032bb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01032c2:	00 
c01032c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01032c6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01032ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01032cd:	89 04 24             	mov    %eax,(%esp)
c01032d0:	e8 8a 01 00 00       	call   c010345f <get_pte>
c01032d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c01032d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01032dc:	75 24                	jne    c0103302 <boot_map_segment+0xdd>
c01032de:	c7 44 24 0c 62 6a 10 	movl   $0xc0106a62,0xc(%esp)
c01032e5:	c0 
c01032e6:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c01032ed:	c0 
c01032ee:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c01032f5:	00 
c01032f6:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01032fd:	e8 33 d1 ff ff       	call   c0100435 <__panic>
        *ptep = pa | PTE_P | perm;
c0103302:	8b 45 14             	mov    0x14(%ebp),%eax
c0103305:	0b 45 18             	or     0x18(%ebp),%eax
c0103308:	83 c8 01             	or     $0x1,%eax
c010330b:	89 c2                	mov    %eax,%edx
c010330d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103310:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103312:	ff 4d f4             	decl   -0xc(%ebp)
c0103315:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010331c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103323:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103327:	75 92                	jne    c01032bb <boot_map_segment+0x96>
    }
}
c0103329:	90                   	nop
c010332a:	90                   	nop
c010332b:	c9                   	leave  
c010332c:	c3                   	ret    

c010332d <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c010332d:	f3 0f 1e fb          	endbr32 
c0103331:	55                   	push   %ebp
c0103332:	89 e5                	mov    %esp,%ebp
c0103334:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103337:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010333e:	e8 74 fa ff ff       	call   c0102db7 <alloc_pages>
c0103343:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0103346:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010334a:	75 1c                	jne    c0103368 <boot_alloc_page+0x3b>
        panic("boot_alloc_page failed.\n");
c010334c:	c7 44 24 08 6f 6a 10 	movl   $0xc0106a6f,0x8(%esp)
c0103353:	c0 
c0103354:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c010335b:	00 
c010335c:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103363:	e8 cd d0 ff ff       	call   c0100435 <__panic>
    }
    return page2kva(p);
c0103368:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010336b:	89 04 24             	mov    %eax,(%esp)
c010336e:	e8 84 f7 ff ff       	call   c0102af7 <page2kva>
}
c0103373:	c9                   	leave  
c0103374:	c3                   	ret    

c0103375 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0103375:	f3 0f 1e fb          	endbr32 
c0103379:	55                   	push   %ebp
c010337a:	89 e5                	mov    %esp,%ebp
c010337c:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010337f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103384:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103387:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010338e:	77 23                	ja     c01033b3 <pmm_init+0x3e>
c0103390:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103393:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103397:	c7 44 24 08 04 6a 10 	movl   $0xc0106a04,0x8(%esp)
c010339e:	c0 
c010339f:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01033a6:	00 
c01033a7:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01033ae:	e8 82 d0 ff ff       	call   c0100435 <__panic>
c01033b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033b6:	05 00 00 00 40       	add    $0x40000000,%eax
c01033bb:	a3 14 cf 11 c0       	mov    %eax,0xc011cf14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c01033c0:	e8 96 f9 ff ff       	call   c0102d5b <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c01033c5:	e8 8f fa ff ff       	call   c0102e59 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c01033ca:	e8 fd 03 00 00       	call   c01037cc <check_alloc_page>

    check_pgdir();
c01033cf:	e8 1b 04 00 00       	call   c01037ef <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c01033d4:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01033d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01033dc:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01033e3:	77 23                	ja     c0103408 <pmm_init+0x93>
c01033e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01033e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01033ec:	c7 44 24 08 04 6a 10 	movl   $0xc0106a04,0x8(%esp)
c01033f3:	c0 
c01033f4:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c01033fb:	00 
c01033fc:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103403:	e8 2d d0 ff ff       	call   c0100435 <__panic>
c0103408:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010340b:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0103411:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103416:	05 ac 0f 00 00       	add    $0xfac,%eax
c010341b:	83 ca 03             	or     $0x3,%edx
c010341e:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103420:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103425:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010342c:	00 
c010342d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103434:	00 
c0103435:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c010343c:	38 
c010343d:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0103444:	c0 
c0103445:	89 04 24             	mov    %eax,(%esp)
c0103448:	e8 d8 fd ff ff       	call   c0103225 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c010344d:	e8 1b f8 ff ff       	call   c0102c6d <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0103452:	e8 38 0a 00 00       	call   c0103e8f <check_boot_pgdir>

    print_pgdir();
c0103457:	e8 bd 0e 00 00       	call   c0104319 <print_pgdir>

}
c010345c:	90                   	nop
c010345d:	c9                   	leave  
c010345e:	c3                   	ret    

c010345f <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010345f:	f3 0f 1e fb          	endbr32 
c0103463:	55                   	push   %ebp
c0103464:	89 e5                	mov    %esp,%ebp
c0103466:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];  // (1) 首先找到页目录项，尝试获得页表
c0103469:	8b 45 0c             	mov    0xc(%ebp),%eax
c010346c:	c1 e8 16             	shr    $0x16,%eax
c010346f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103476:	8b 45 08             	mov    0x8(%ebp),%eax
c0103479:	01 d0                	add    %edx,%eax
c010347b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {         // (2) 检查这个页目录项是否存在，存在则直接返回找到的页表项，如果不存在
c010347e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103481:	8b 00                	mov    (%eax),%eax
c0103483:	83 e0 01             	and    $0x1,%eax
c0103486:	85 c0                	test   %eax,%eax
c0103488:	0f 85 b9 00 00 00    	jne    c0103547 <get_pte+0xe8>
        if (!create) {               // (3) 页目录项不存在且参数不要求创建新的页表，那么返回NULL
c010348e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103492:	75 0a                	jne    c010349e <get_pte+0x3f>
            return NULL;
c0103494:	b8 00 00 00 00       	mov    $0x0,%eax
c0103499:	e9 06 01 00 00       	jmp    c01035a4 <get_pte+0x145>
        }
        struct Page *page = alloc_page();  // (3) 否则分配一个物理页存储创建的页表
c010349e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034a5:	e8 0d f9 ff ff       	call   c0102db7 <alloc_pages>
c01034aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (page == NULL) {  // (3) 如果分配失败，那么返回NULL
c01034ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01034b1:	75 0a                	jne    c01034bd <get_pte+0x5e>
            return NULL;
c01034b3:	b8 00 00 00 00       	mov    $0x0,%eax
c01034b8:	e9 e7 00 00 00       	jmp    c01035a4 <get_pte+0x145>
        }
        set_page_ref(page, 1);               // (4) 设置物理页被引用一次
c01034bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01034c4:	00 
c01034c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034c8:	89 04 24             	mov    %eax,(%esp)
c01034cb:	e8 db f6 ff ff       	call   c0102bab <set_page_ref>
        uintptr_t pa = page2pa(page);        // (5) 获得物理页的线性物理地址
c01034d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034d3:	89 04 24             	mov    %eax,(%esp)
c01034d6:	e8 b7 f5 ff ff       	call   c0102a92 <page2pa>
c01034db:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);        // (6) 将物理地址转换成虚拟地址后，用memset函数清除页目录进行初始化
c01034de:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01034e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01034e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034e7:	c1 e8 0c             	shr    $0xc,%eax
c01034ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01034ed:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c01034f2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01034f5:	72 23                	jb     c010351a <get_pte+0xbb>
c01034f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01034fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01034fe:	c7 44 24 08 60 69 10 	movl   $0xc0106960,0x8(%esp)
c0103505:	c0 
c0103506:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
c010350d:	00 
c010350e:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103515:	e8 1b cf ff ff       	call   c0100435 <__panic>
c010351a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010351d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103522:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103529:	00 
c010352a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103531:	00 
c0103532:	89 04 24             	mov    %eax,(%esp)
c0103535:	e8 96 24 00 00       	call   c01059d0 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;  // (7) 设置页目录项的权限
c010353a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010353d:	83 c8 07             	or     $0x7,%eax
c0103540:	89 c2                	mov    %eax,%edx
c0103542:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103545:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)]; // (8) 返回虚拟地址la对应的页表项入口地址
c0103547:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010354a:	8b 00                	mov    (%eax),%eax
c010354c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103551:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103554:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103557:	c1 e8 0c             	shr    $0xc,%eax
c010355a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010355d:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0103562:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103565:	72 23                	jb     c010358a <get_pte+0x12b>
c0103567:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010356a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010356e:	c7 44 24 08 60 69 10 	movl   $0xc0106960,0x8(%esp)
c0103575:	c0 
c0103576:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
c010357d:	00 
c010357e:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103585:	e8 ab ce ff ff       	call   c0100435 <__panic>
c010358a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010358d:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103592:	89 c2                	mov    %eax,%edx
c0103594:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103597:	c1 e8 0c             	shr    $0xc,%eax
c010359a:	25 ff 03 00 00       	and    $0x3ff,%eax
c010359f:	c1 e0 02             	shl    $0x2,%eax
c01035a2:	01 d0                	add    %edx,%eax
}
c01035a4:	c9                   	leave  
c01035a5:	c3                   	ret    

c01035a6 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c01035a6:	f3 0f 1e fb          	endbr32 
c01035aa:	55                   	push   %ebp
c01035ab:	89 e5                	mov    %esp,%ebp
c01035ad:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01035b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01035b7:	00 
c01035b8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01035bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01035bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01035c2:	89 04 24             	mov    %eax,(%esp)
c01035c5:	e8 95 fe ff ff       	call   c010345f <get_pte>
c01035ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c01035cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01035d1:	74 08                	je     c01035db <get_page+0x35>
        *ptep_store = ptep;
c01035d3:	8b 45 10             	mov    0x10(%ebp),%eax
c01035d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01035d9:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c01035db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01035df:	74 1b                	je     c01035fc <get_page+0x56>
c01035e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035e4:	8b 00                	mov    (%eax),%eax
c01035e6:	83 e0 01             	and    $0x1,%eax
c01035e9:	85 c0                	test   %eax,%eax
c01035eb:	74 0f                	je     c01035fc <get_page+0x56>
        return pte2page(*ptep);
c01035ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035f0:	8b 00                	mov    (%eax),%eax
c01035f2:	89 04 24             	mov    %eax,(%esp)
c01035f5:	e8 51 f5 ff ff       	call   c0102b4b <pte2page>
c01035fa:	eb 05                	jmp    c0103601 <get_page+0x5b>
    }
    return NULL;
c01035fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103601:	c9                   	leave  
c0103602:	c3                   	ret    

c0103603 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103603:	55                   	push   %ebp
c0103604:	89 e5                	mov    %esp,%ebp
c0103606:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {                     // (1) 检查这个页目录项是否存在
c0103609:	8b 45 10             	mov    0x10(%ebp),%eax
c010360c:	8b 00                	mov    (%eax),%eax
c010360e:	83 e0 01             	and    $0x1,%eax
c0103611:	85 c0                	test   %eax,%eax
c0103613:	74 4d                	je     c0103662 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep); // (2) 找到这个页目录项对应的页
c0103615:	8b 45 10             	mov    0x10(%ebp),%eax
c0103618:	8b 00                	mov    (%eax),%eax
c010361a:	89 04 24             	mov    %eax,(%esp)
c010361d:	e8 29 f5 ff ff       	call   c0102b4b <pte2page>
c0103622:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {       // (3) 将这个页的引用数减一
c0103625:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103628:	89 04 24             	mov    %eax,(%esp)
c010362b:	e8 a0 f5 ff ff       	call   c0102bd0 <page_ref_dec>
c0103630:	85 c0                	test   %eax,%eax
c0103632:	75 13                	jne    c0103647 <page_remove_pte+0x44>
            free_page(page);                 // (4) 如果这个页的引用数为0，那么释放此页
c0103634:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010363b:	00 
c010363c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010363f:	89 04 24             	mov    %eax,(%esp)
c0103642:	e8 ac f7 ff ff       	call   c0102df3 <free_pages>
        }
        *ptep = 0;                           // (5) 清除页目录项
c0103647:	8b 45 10             	mov    0x10(%ebp),%eax
c010364a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);           // (6) 当修改的页表正在使用时，那么无效 
c0103650:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103653:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103657:	8b 45 08             	mov    0x8(%ebp),%eax
c010365a:	89 04 24             	mov    %eax,(%esp)
c010365d:	e8 09 01 00 00       	call   c010376b <tlb_invalidate>
    }
}
c0103662:	90                   	nop
c0103663:	c9                   	leave  
c0103664:	c3                   	ret    

c0103665 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0103665:	f3 0f 1e fb          	endbr32 
c0103669:	55                   	push   %ebp
c010366a:	89 e5                	mov    %esp,%ebp
c010366c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010366f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103676:	00 
c0103677:	8b 45 0c             	mov    0xc(%ebp),%eax
c010367a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010367e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103681:	89 04 24             	mov    %eax,(%esp)
c0103684:	e8 d6 fd ff ff       	call   c010345f <get_pte>
c0103689:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c010368c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103690:	74 19                	je     c01036ab <page_remove+0x46>
        page_remove_pte(pgdir, la, ptep);
c0103692:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103695:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103699:	8b 45 0c             	mov    0xc(%ebp),%eax
c010369c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01036a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01036a3:	89 04 24             	mov    %eax,(%esp)
c01036a6:	e8 58 ff ff ff       	call   c0103603 <page_remove_pte>
    }
}
c01036ab:	90                   	nop
c01036ac:	c9                   	leave  
c01036ad:	c3                   	ret    

c01036ae <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c01036ae:	f3 0f 1e fb          	endbr32 
c01036b2:	55                   	push   %ebp
c01036b3:	89 e5                	mov    %esp,%ebp
c01036b5:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c01036b8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c01036bf:	00 
c01036c0:	8b 45 10             	mov    0x10(%ebp),%eax
c01036c3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01036c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01036ca:	89 04 24             	mov    %eax,(%esp)
c01036cd:	e8 8d fd ff ff       	call   c010345f <get_pte>
c01036d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c01036d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01036d9:	75 0a                	jne    c01036e5 <page_insert+0x37>
        return -E_NO_MEM;
c01036db:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c01036e0:	e9 84 00 00 00       	jmp    c0103769 <page_insert+0xbb>
    }
    page_ref_inc(page);
c01036e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01036e8:	89 04 24             	mov    %eax,(%esp)
c01036eb:	e8 c9 f4 ff ff       	call   c0102bb9 <page_ref_inc>
    if (*ptep & PTE_P) {
c01036f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036f3:	8b 00                	mov    (%eax),%eax
c01036f5:	83 e0 01             	and    $0x1,%eax
c01036f8:	85 c0                	test   %eax,%eax
c01036fa:	74 3e                	je     c010373a <page_insert+0x8c>
        struct Page *p = pte2page(*ptep);
c01036fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01036ff:	8b 00                	mov    (%eax),%eax
c0103701:	89 04 24             	mov    %eax,(%esp)
c0103704:	e8 42 f4 ff ff       	call   c0102b4b <pte2page>
c0103709:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010370c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010370f:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103712:	75 0d                	jne    c0103721 <page_insert+0x73>
            page_ref_dec(page);
c0103714:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103717:	89 04 24             	mov    %eax,(%esp)
c010371a:	e8 b1 f4 ff ff       	call   c0102bd0 <page_ref_dec>
c010371f:	eb 19                	jmp    c010373a <page_insert+0x8c>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103721:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103724:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103728:	8b 45 10             	mov    0x10(%ebp),%eax
c010372b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010372f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103732:	89 04 24             	mov    %eax,(%esp)
c0103735:	e8 c9 fe ff ff       	call   c0103603 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c010373a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010373d:	89 04 24             	mov    %eax,(%esp)
c0103740:	e8 4d f3 ff ff       	call   c0102a92 <page2pa>
c0103745:	0b 45 14             	or     0x14(%ebp),%eax
c0103748:	83 c8 01             	or     $0x1,%eax
c010374b:	89 c2                	mov    %eax,%edx
c010374d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103750:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103752:	8b 45 10             	mov    0x10(%ebp),%eax
c0103755:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103759:	8b 45 08             	mov    0x8(%ebp),%eax
c010375c:	89 04 24             	mov    %eax,(%esp)
c010375f:	e8 07 00 00 00       	call   c010376b <tlb_invalidate>
    return 0;
c0103764:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103769:	c9                   	leave  
c010376a:	c3                   	ret    

c010376b <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010376b:	f3 0f 1e fb          	endbr32 
c010376f:	55                   	push   %ebp
c0103770:	89 e5                	mov    %esp,%ebp
c0103772:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103775:	0f 20 d8             	mov    %cr3,%eax
c0103778:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c010377b:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c010377e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103781:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103784:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010378b:	77 23                	ja     c01037b0 <tlb_invalidate+0x45>
c010378d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103790:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103794:	c7 44 24 08 04 6a 10 	movl   $0xc0106a04,0x8(%esp)
c010379b:	c0 
c010379c:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
c01037a3:	00 
c01037a4:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01037ab:	e8 85 cc ff ff       	call   c0100435 <__panic>
c01037b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037b3:	05 00 00 00 40       	add    $0x40000000,%eax
c01037b8:	39 d0                	cmp    %edx,%eax
c01037ba:	75 0d                	jne    c01037c9 <tlb_invalidate+0x5e>
        invlpg((void *)la);
c01037bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01037bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c01037c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037c5:	0f 01 38             	invlpg (%eax)
}
c01037c8:	90                   	nop
    }
}
c01037c9:	90                   	nop
c01037ca:	c9                   	leave  
c01037cb:	c3                   	ret    

c01037cc <check_alloc_page>:

static void
check_alloc_page(void) {
c01037cc:	f3 0f 1e fb          	endbr32 
c01037d0:	55                   	push   %ebp
c01037d1:	89 e5                	mov    %esp,%ebp
c01037d3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c01037d6:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c01037db:	8b 40 18             	mov    0x18(%eax),%eax
c01037de:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c01037e0:	c7 04 24 88 6a 10 c0 	movl   $0xc0106a88,(%esp)
c01037e7:	e8 dd ca ff ff       	call   c01002c9 <cprintf>
}
c01037ec:	90                   	nop
c01037ed:	c9                   	leave  
c01037ee:	c3                   	ret    

c01037ef <check_pgdir>:

static void
check_pgdir(void) {
c01037ef:	f3 0f 1e fb          	endbr32 
c01037f3:	55                   	push   %ebp
c01037f4:	89 e5                	mov    %esp,%ebp
c01037f6:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c01037f9:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c01037fe:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103803:	76 24                	jbe    c0103829 <check_pgdir+0x3a>
c0103805:	c7 44 24 0c a7 6a 10 	movl   $0xc0106aa7,0xc(%esp)
c010380c:	c0 
c010380d:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103814:	c0 
c0103815:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
c010381c:	00 
c010381d:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103824:	e8 0c cc ff ff       	call   c0100435 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0103829:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010382e:	85 c0                	test   %eax,%eax
c0103830:	74 0e                	je     c0103840 <check_pgdir+0x51>
c0103832:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103837:	25 ff 0f 00 00       	and    $0xfff,%eax
c010383c:	85 c0                	test   %eax,%eax
c010383e:	74 24                	je     c0103864 <check_pgdir+0x75>
c0103840:	c7 44 24 0c c4 6a 10 	movl   $0xc0106ac4,0xc(%esp)
c0103847:	c0 
c0103848:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c010384f:	c0 
c0103850:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
c0103857:	00 
c0103858:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c010385f:	e8 d1 cb ff ff       	call   c0100435 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0103864:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103869:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103870:	00 
c0103871:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103878:	00 
c0103879:	89 04 24             	mov    %eax,(%esp)
c010387c:	e8 25 fd ff ff       	call   c01035a6 <get_page>
c0103881:	85 c0                	test   %eax,%eax
c0103883:	74 24                	je     c01038a9 <check_pgdir+0xba>
c0103885:	c7 44 24 0c fc 6a 10 	movl   $0xc0106afc,0xc(%esp)
c010388c:	c0 
c010388d:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103894:	c0 
c0103895:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
c010389c:	00 
c010389d:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01038a4:	e8 8c cb ff ff       	call   c0100435 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01038a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01038b0:	e8 02 f5 ff ff       	call   c0102db7 <alloc_pages>
c01038b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01038b8:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01038bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01038c4:	00 
c01038c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01038cc:	00 
c01038cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01038d0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01038d4:	89 04 24             	mov    %eax,(%esp)
c01038d7:	e8 d2 fd ff ff       	call   c01036ae <page_insert>
c01038dc:	85 c0                	test   %eax,%eax
c01038de:	74 24                	je     c0103904 <check_pgdir+0x115>
c01038e0:	c7 44 24 0c 24 6b 10 	movl   $0xc0106b24,0xc(%esp)
c01038e7:	c0 
c01038e8:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c01038ef:	c0 
c01038f0:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c01038f7:	00 
c01038f8:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01038ff:	e8 31 cb ff ff       	call   c0100435 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103904:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103909:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103910:	00 
c0103911:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103918:	00 
c0103919:	89 04 24             	mov    %eax,(%esp)
c010391c:	e8 3e fb ff ff       	call   c010345f <get_pte>
c0103921:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103924:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103928:	75 24                	jne    c010394e <check_pgdir+0x15f>
c010392a:	c7 44 24 0c 50 6b 10 	movl   $0xc0106b50,0xc(%esp)
c0103931:	c0 
c0103932:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103939:	c0 
c010393a:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0103941:	00 
c0103942:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103949:	e8 e7 ca ff ff       	call   c0100435 <__panic>
    assert(pte2page(*ptep) == p1);
c010394e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103951:	8b 00                	mov    (%eax),%eax
c0103953:	89 04 24             	mov    %eax,(%esp)
c0103956:	e8 f0 f1 ff ff       	call   c0102b4b <pte2page>
c010395b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010395e:	74 24                	je     c0103984 <check_pgdir+0x195>
c0103960:	c7 44 24 0c 7d 6b 10 	movl   $0xc0106b7d,0xc(%esp)
c0103967:	c0 
c0103968:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c010396f:	c0 
c0103970:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
c0103977:	00 
c0103978:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c010397f:	e8 b1 ca ff ff       	call   c0100435 <__panic>
    assert(page_ref(p1) == 1);
c0103984:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103987:	89 04 24             	mov    %eax,(%esp)
c010398a:	e8 12 f2 ff ff       	call   c0102ba1 <page_ref>
c010398f:	83 f8 01             	cmp    $0x1,%eax
c0103992:	74 24                	je     c01039b8 <check_pgdir+0x1c9>
c0103994:	c7 44 24 0c 93 6b 10 	movl   $0xc0106b93,0xc(%esp)
c010399b:	c0 
c010399c:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c01039a3:	c0 
c01039a4:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c01039ab:	00 
c01039ac:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01039b3:	e8 7d ca ff ff       	call   c0100435 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01039b8:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01039bd:	8b 00                	mov    (%eax),%eax
c01039bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01039c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01039c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039ca:	c1 e8 0c             	shr    $0xc,%eax
c01039cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01039d0:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c01039d5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01039d8:	72 23                	jb     c01039fd <check_pgdir+0x20e>
c01039da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01039dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01039e1:	c7 44 24 08 60 69 10 	movl   $0xc0106960,0x8(%esp)
c01039e8:	c0 
c01039e9:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c01039f0:	00 
c01039f1:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01039f8:	e8 38 ca ff ff       	call   c0100435 <__panic>
c01039fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a00:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103a05:	83 c0 04             	add    $0x4,%eax
c0103a08:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0103a0b:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103a10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a17:	00 
c0103a18:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a1f:	00 
c0103a20:	89 04 24             	mov    %eax,(%esp)
c0103a23:	e8 37 fa ff ff       	call   c010345f <get_pte>
c0103a28:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103a2b:	74 24                	je     c0103a51 <check_pgdir+0x262>
c0103a2d:	c7 44 24 0c a8 6b 10 	movl   $0xc0106ba8,0xc(%esp)
c0103a34:	c0 
c0103a35:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103a3c:	c0 
c0103a3d:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0103a44:	00 
c0103a45:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103a4c:	e8 e4 c9 ff ff       	call   c0100435 <__panic>

    p2 = alloc_page();
c0103a51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103a58:	e8 5a f3 ff ff       	call   c0102db7 <alloc_pages>
c0103a5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0103a60:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103a65:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0103a6c:	00 
c0103a6d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103a74:	00 
c0103a75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103a78:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103a7c:	89 04 24             	mov    %eax,(%esp)
c0103a7f:	e8 2a fc ff ff       	call   c01036ae <page_insert>
c0103a84:	85 c0                	test   %eax,%eax
c0103a86:	74 24                	je     c0103aac <check_pgdir+0x2bd>
c0103a88:	c7 44 24 0c d0 6b 10 	movl   $0xc0106bd0,0xc(%esp)
c0103a8f:	c0 
c0103a90:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103a97:	c0 
c0103a98:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c0103a9f:	00 
c0103aa0:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103aa7:	e8 89 c9 ff ff       	call   c0100435 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103aac:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103ab1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103ab8:	00 
c0103ab9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103ac0:	00 
c0103ac1:	89 04 24             	mov    %eax,(%esp)
c0103ac4:	e8 96 f9 ff ff       	call   c010345f <get_pte>
c0103ac9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103acc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103ad0:	75 24                	jne    c0103af6 <check_pgdir+0x307>
c0103ad2:	c7 44 24 0c 08 6c 10 	movl   $0xc0106c08,0xc(%esp)
c0103ad9:	c0 
c0103ada:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103ae1:	c0 
c0103ae2:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103ae9:	00 
c0103aea:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103af1:	e8 3f c9 ff ff       	call   c0100435 <__panic>
    assert(*ptep & PTE_U);
c0103af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103af9:	8b 00                	mov    (%eax),%eax
c0103afb:	83 e0 04             	and    $0x4,%eax
c0103afe:	85 c0                	test   %eax,%eax
c0103b00:	75 24                	jne    c0103b26 <check_pgdir+0x337>
c0103b02:	c7 44 24 0c 38 6c 10 	movl   $0xc0106c38,0xc(%esp)
c0103b09:	c0 
c0103b0a:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103b11:	c0 
c0103b12:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0103b19:	00 
c0103b1a:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103b21:	e8 0f c9 ff ff       	call   c0100435 <__panic>
    assert(*ptep & PTE_W);
c0103b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b29:	8b 00                	mov    (%eax),%eax
c0103b2b:	83 e0 02             	and    $0x2,%eax
c0103b2e:	85 c0                	test   %eax,%eax
c0103b30:	75 24                	jne    c0103b56 <check_pgdir+0x367>
c0103b32:	c7 44 24 0c 46 6c 10 	movl   $0xc0106c46,0xc(%esp)
c0103b39:	c0 
c0103b3a:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103b41:	c0 
c0103b42:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0103b49:	00 
c0103b4a:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103b51:	e8 df c8 ff ff       	call   c0100435 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103b56:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103b5b:	8b 00                	mov    (%eax),%eax
c0103b5d:	83 e0 04             	and    $0x4,%eax
c0103b60:	85 c0                	test   %eax,%eax
c0103b62:	75 24                	jne    c0103b88 <check_pgdir+0x399>
c0103b64:	c7 44 24 0c 54 6c 10 	movl   $0xc0106c54,0xc(%esp)
c0103b6b:	c0 
c0103b6c:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103b73:	c0 
c0103b74:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0103b7b:	00 
c0103b7c:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103b83:	e8 ad c8 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p2) == 1);
c0103b88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b8b:	89 04 24             	mov    %eax,(%esp)
c0103b8e:	e8 0e f0 ff ff       	call   c0102ba1 <page_ref>
c0103b93:	83 f8 01             	cmp    $0x1,%eax
c0103b96:	74 24                	je     c0103bbc <check_pgdir+0x3cd>
c0103b98:	c7 44 24 0c 6a 6c 10 	movl   $0xc0106c6a,0xc(%esp)
c0103b9f:	c0 
c0103ba0:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103ba7:	c0 
c0103ba8:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0103baf:	00 
c0103bb0:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103bb7:	e8 79 c8 ff ff       	call   c0100435 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103bbc:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103bc1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103bc8:	00 
c0103bc9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103bd0:	00 
c0103bd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103bd4:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103bd8:	89 04 24             	mov    %eax,(%esp)
c0103bdb:	e8 ce fa ff ff       	call   c01036ae <page_insert>
c0103be0:	85 c0                	test   %eax,%eax
c0103be2:	74 24                	je     c0103c08 <check_pgdir+0x419>
c0103be4:	c7 44 24 0c 7c 6c 10 	movl   $0xc0106c7c,0xc(%esp)
c0103beb:	c0 
c0103bec:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103bf3:	c0 
c0103bf4:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0103bfb:	00 
c0103bfc:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103c03:	e8 2d c8 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p1) == 2);
c0103c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c0b:	89 04 24             	mov    %eax,(%esp)
c0103c0e:	e8 8e ef ff ff       	call   c0102ba1 <page_ref>
c0103c13:	83 f8 02             	cmp    $0x2,%eax
c0103c16:	74 24                	je     c0103c3c <check_pgdir+0x44d>
c0103c18:	c7 44 24 0c a8 6c 10 	movl   $0xc0106ca8,0xc(%esp)
c0103c1f:	c0 
c0103c20:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103c27:	c0 
c0103c28:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0103c2f:	00 
c0103c30:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103c37:	e8 f9 c7 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p2) == 0);
c0103c3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103c3f:	89 04 24             	mov    %eax,(%esp)
c0103c42:	e8 5a ef ff ff       	call   c0102ba1 <page_ref>
c0103c47:	85 c0                	test   %eax,%eax
c0103c49:	74 24                	je     c0103c6f <check_pgdir+0x480>
c0103c4b:	c7 44 24 0c ba 6c 10 	movl   $0xc0106cba,0xc(%esp)
c0103c52:	c0 
c0103c53:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103c5a:	c0 
c0103c5b:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0103c62:	00 
c0103c63:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103c6a:	e8 c6 c7 ff ff       	call   c0100435 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103c6f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103c74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103c7b:	00 
c0103c7c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103c83:	00 
c0103c84:	89 04 24             	mov    %eax,(%esp)
c0103c87:	e8 d3 f7 ff ff       	call   c010345f <get_pte>
c0103c8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103c93:	75 24                	jne    c0103cb9 <check_pgdir+0x4ca>
c0103c95:	c7 44 24 0c 08 6c 10 	movl   $0xc0106c08,0xc(%esp)
c0103c9c:	c0 
c0103c9d:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103ca4:	c0 
c0103ca5:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0103cac:	00 
c0103cad:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103cb4:	e8 7c c7 ff ff       	call   c0100435 <__panic>
    assert(pte2page(*ptep) == p1);
c0103cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cbc:	8b 00                	mov    (%eax),%eax
c0103cbe:	89 04 24             	mov    %eax,(%esp)
c0103cc1:	e8 85 ee ff ff       	call   c0102b4b <pte2page>
c0103cc6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103cc9:	74 24                	je     c0103cef <check_pgdir+0x500>
c0103ccb:	c7 44 24 0c 7d 6b 10 	movl   $0xc0106b7d,0xc(%esp)
c0103cd2:	c0 
c0103cd3:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103cda:	c0 
c0103cdb:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0103ce2:	00 
c0103ce3:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103cea:	e8 46 c7 ff ff       	call   c0100435 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103cf2:	8b 00                	mov    (%eax),%eax
c0103cf4:	83 e0 04             	and    $0x4,%eax
c0103cf7:	85 c0                	test   %eax,%eax
c0103cf9:	74 24                	je     c0103d1f <check_pgdir+0x530>
c0103cfb:	c7 44 24 0c cc 6c 10 	movl   $0xc0106ccc,0xc(%esp)
c0103d02:	c0 
c0103d03:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103d0a:	c0 
c0103d0b:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0103d12:	00 
c0103d13:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103d1a:	e8 16 c7 ff ff       	call   c0100435 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103d1f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103d24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103d2b:	00 
c0103d2c:	89 04 24             	mov    %eax,(%esp)
c0103d2f:	e8 31 f9 ff ff       	call   c0103665 <page_remove>
    assert(page_ref(p1) == 1);
c0103d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d37:	89 04 24             	mov    %eax,(%esp)
c0103d3a:	e8 62 ee ff ff       	call   c0102ba1 <page_ref>
c0103d3f:	83 f8 01             	cmp    $0x1,%eax
c0103d42:	74 24                	je     c0103d68 <check_pgdir+0x579>
c0103d44:	c7 44 24 0c 93 6b 10 	movl   $0xc0106b93,0xc(%esp)
c0103d4b:	c0 
c0103d4c:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103d53:	c0 
c0103d54:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0103d5b:	00 
c0103d5c:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103d63:	e8 cd c6 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p2) == 0);
c0103d68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d6b:	89 04 24             	mov    %eax,(%esp)
c0103d6e:	e8 2e ee ff ff       	call   c0102ba1 <page_ref>
c0103d73:	85 c0                	test   %eax,%eax
c0103d75:	74 24                	je     c0103d9b <check_pgdir+0x5ac>
c0103d77:	c7 44 24 0c ba 6c 10 	movl   $0xc0106cba,0xc(%esp)
c0103d7e:	c0 
c0103d7f:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103d86:	c0 
c0103d87:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0103d8e:	00 
c0103d8f:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103d96:	e8 9a c6 ff ff       	call   c0100435 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103d9b:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103da0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103da7:	00 
c0103da8:	89 04 24             	mov    %eax,(%esp)
c0103dab:	e8 b5 f8 ff ff       	call   c0103665 <page_remove>
    assert(page_ref(p1) == 0);
c0103db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103db3:	89 04 24             	mov    %eax,(%esp)
c0103db6:	e8 e6 ed ff ff       	call   c0102ba1 <page_ref>
c0103dbb:	85 c0                	test   %eax,%eax
c0103dbd:	74 24                	je     c0103de3 <check_pgdir+0x5f4>
c0103dbf:	c7 44 24 0c e1 6c 10 	movl   $0xc0106ce1,0xc(%esp)
c0103dc6:	c0 
c0103dc7:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103dce:	c0 
c0103dcf:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0103dd6:	00 
c0103dd7:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103dde:	e8 52 c6 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p2) == 0);
c0103de3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103de6:	89 04 24             	mov    %eax,(%esp)
c0103de9:	e8 b3 ed ff ff       	call   c0102ba1 <page_ref>
c0103dee:	85 c0                	test   %eax,%eax
c0103df0:	74 24                	je     c0103e16 <check_pgdir+0x627>
c0103df2:	c7 44 24 0c ba 6c 10 	movl   $0xc0106cba,0xc(%esp)
c0103df9:	c0 
c0103dfa:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103e01:	c0 
c0103e02:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0103e09:	00 
c0103e0a:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103e11:	e8 1f c6 ff ff       	call   c0100435 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103e16:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103e1b:	8b 00                	mov    (%eax),%eax
c0103e1d:	89 04 24             	mov    %eax,(%esp)
c0103e20:	e8 64 ed ff ff       	call   c0102b89 <pde2page>
c0103e25:	89 04 24             	mov    %eax,(%esp)
c0103e28:	e8 74 ed ff ff       	call   c0102ba1 <page_ref>
c0103e2d:	83 f8 01             	cmp    $0x1,%eax
c0103e30:	74 24                	je     c0103e56 <check_pgdir+0x667>
c0103e32:	c7 44 24 0c f4 6c 10 	movl   $0xc0106cf4,0xc(%esp)
c0103e39:	c0 
c0103e3a:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103e41:	c0 
c0103e42:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0103e49:	00 
c0103e4a:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103e51:	e8 df c5 ff ff       	call   c0100435 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103e56:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103e5b:	8b 00                	mov    (%eax),%eax
c0103e5d:	89 04 24             	mov    %eax,(%esp)
c0103e60:	e8 24 ed ff ff       	call   c0102b89 <pde2page>
c0103e65:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103e6c:	00 
c0103e6d:	89 04 24             	mov    %eax,(%esp)
c0103e70:	e8 7e ef ff ff       	call   c0102df3 <free_pages>
    boot_pgdir[0] = 0;
c0103e75:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103e7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103e80:	c7 04 24 1b 6d 10 c0 	movl   $0xc0106d1b,(%esp)
c0103e87:	e8 3d c4 ff ff       	call   c01002c9 <cprintf>
}
c0103e8c:	90                   	nop
c0103e8d:	c9                   	leave  
c0103e8e:	c3                   	ret    

c0103e8f <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103e8f:	f3 0f 1e fb          	endbr32 
c0103e93:	55                   	push   %ebp
c0103e94:	89 e5                	mov    %esp,%ebp
c0103e96:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103e99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103ea0:	e9 ca 00 00 00       	jmp    c0103f6f <check_boot_pgdir+0xe0>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ea8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103eae:	c1 e8 0c             	shr    $0xc,%eax
c0103eb1:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103eb4:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0103eb9:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0103ebc:	72 23                	jb     c0103ee1 <check_boot_pgdir+0x52>
c0103ebe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ec1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103ec5:	c7 44 24 08 60 69 10 	movl   $0xc0106960,0x8(%esp)
c0103ecc:	c0 
c0103ecd:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0103ed4:	00 
c0103ed5:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103edc:	e8 54 c5 ff ff       	call   c0100435 <__panic>
c0103ee1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ee4:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103ee9:	89 c2                	mov    %eax,%edx
c0103eeb:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103ef0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103ef7:	00 
c0103ef8:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103efc:	89 04 24             	mov    %eax,(%esp)
c0103eff:	e8 5b f5 ff ff       	call   c010345f <get_pte>
c0103f04:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103f07:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0103f0b:	75 24                	jne    c0103f31 <check_boot_pgdir+0xa2>
c0103f0d:	c7 44 24 0c 38 6d 10 	movl   $0xc0106d38,0xc(%esp)
c0103f14:	c0 
c0103f15:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103f1c:	c0 
c0103f1d:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0103f24:	00 
c0103f25:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103f2c:	e8 04 c5 ff ff       	call   c0100435 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103f31:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103f34:	8b 00                	mov    (%eax),%eax
c0103f36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103f3b:	89 c2                	mov    %eax,%edx
c0103f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f40:	39 c2                	cmp    %eax,%edx
c0103f42:	74 24                	je     c0103f68 <check_boot_pgdir+0xd9>
c0103f44:	c7 44 24 0c 75 6d 10 	movl   $0xc0106d75,0xc(%esp)
c0103f4b:	c0 
c0103f4c:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103f53:	c0 
c0103f54:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0103f5b:	00 
c0103f5c:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103f63:	e8 cd c4 ff ff       	call   c0100435 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c0103f68:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103f6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103f72:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0103f77:	39 c2                	cmp    %eax,%edx
c0103f79:	0f 82 26 ff ff ff    	jb     c0103ea5 <check_boot_pgdir+0x16>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103f7f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103f84:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103f89:	8b 00                	mov    (%eax),%eax
c0103f8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103f90:	89 c2                	mov    %eax,%edx
c0103f92:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103f97:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f9a:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103fa1:	77 23                	ja     c0103fc6 <check_boot_pgdir+0x137>
c0103fa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fa6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103faa:	c7 44 24 08 04 6a 10 	movl   $0xc0106a04,0x8(%esp)
c0103fb1:	c0 
c0103fb2:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0103fb9:	00 
c0103fba:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103fc1:	e8 6f c4 ff ff       	call   c0100435 <__panic>
c0103fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103fc9:	05 00 00 00 40       	add    $0x40000000,%eax
c0103fce:	39 d0                	cmp    %edx,%eax
c0103fd0:	74 24                	je     c0103ff6 <check_boot_pgdir+0x167>
c0103fd2:	c7 44 24 0c 8c 6d 10 	movl   $0xc0106d8c,0xc(%esp)
c0103fd9:	c0 
c0103fda:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0103fe1:	c0 
c0103fe2:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0103fe9:	00 
c0103fea:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0103ff1:	e8 3f c4 ff ff       	call   c0100435 <__panic>

    assert(boot_pgdir[0] == 0);
c0103ff6:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103ffb:	8b 00                	mov    (%eax),%eax
c0103ffd:	85 c0                	test   %eax,%eax
c0103fff:	74 24                	je     c0104025 <check_boot_pgdir+0x196>
c0104001:	c7 44 24 0c c0 6d 10 	movl   $0xc0106dc0,0xc(%esp)
c0104008:	c0 
c0104009:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0104010:	c0 
c0104011:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c0104018:	00 
c0104019:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0104020:	e8 10 c4 ff ff       	call   c0100435 <__panic>

    struct Page *p;
    p = alloc_page();
c0104025:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010402c:	e8 86 ed ff ff       	call   c0102db7 <alloc_pages>
c0104031:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104034:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104039:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104040:	00 
c0104041:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0104048:	00 
c0104049:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010404c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104050:	89 04 24             	mov    %eax,(%esp)
c0104053:	e8 56 f6 ff ff       	call   c01036ae <page_insert>
c0104058:	85 c0                	test   %eax,%eax
c010405a:	74 24                	je     c0104080 <check_boot_pgdir+0x1f1>
c010405c:	c7 44 24 0c d4 6d 10 	movl   $0xc0106dd4,0xc(%esp)
c0104063:	c0 
c0104064:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c010406b:	c0 
c010406c:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c0104073:	00 
c0104074:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c010407b:	e8 b5 c3 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p) == 1);
c0104080:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104083:	89 04 24             	mov    %eax,(%esp)
c0104086:	e8 16 eb ff ff       	call   c0102ba1 <page_ref>
c010408b:	83 f8 01             	cmp    $0x1,%eax
c010408e:	74 24                	je     c01040b4 <check_boot_pgdir+0x225>
c0104090:	c7 44 24 0c 02 6e 10 	movl   $0xc0106e02,0xc(%esp)
c0104097:	c0 
c0104098:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c010409f:	c0 
c01040a0:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c01040a7:	00 
c01040a8:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01040af:	e8 81 c3 ff ff       	call   c0100435 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01040b4:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01040b9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01040c0:	00 
c01040c1:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c01040c8:	00 
c01040c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01040cc:	89 54 24 04          	mov    %edx,0x4(%esp)
c01040d0:	89 04 24             	mov    %eax,(%esp)
c01040d3:	e8 d6 f5 ff ff       	call   c01036ae <page_insert>
c01040d8:	85 c0                	test   %eax,%eax
c01040da:	74 24                	je     c0104100 <check_boot_pgdir+0x271>
c01040dc:	c7 44 24 0c 14 6e 10 	movl   $0xc0106e14,0xc(%esp)
c01040e3:	c0 
c01040e4:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c01040eb:	c0 
c01040ec:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c01040f3:	00 
c01040f4:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01040fb:	e8 35 c3 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p) == 2);
c0104100:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104103:	89 04 24             	mov    %eax,(%esp)
c0104106:	e8 96 ea ff ff       	call   c0102ba1 <page_ref>
c010410b:	83 f8 02             	cmp    $0x2,%eax
c010410e:	74 24                	je     c0104134 <check_boot_pgdir+0x2a5>
c0104110:	c7 44 24 0c 4b 6e 10 	movl   $0xc0106e4b,0xc(%esp)
c0104117:	c0 
c0104118:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c010411f:	c0 
c0104120:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0104127:	00 
c0104128:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c010412f:	e8 01 c3 ff ff       	call   c0100435 <__panic>

    const char *str = "ucore: Hello world!!";
c0104134:	c7 45 e8 5c 6e 10 c0 	movl   $0xc0106e5c,-0x18(%ebp)
    strcpy((void *)0x100, str);
c010413b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010413e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104142:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104149:	e8 9e 15 00 00       	call   c01056ec <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010414e:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0104155:	00 
c0104156:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c010415d:	e8 08 16 00 00       	call   c010576a <strcmp>
c0104162:	85 c0                	test   %eax,%eax
c0104164:	74 24                	je     c010418a <check_boot_pgdir+0x2fb>
c0104166:	c7 44 24 0c 74 6e 10 	movl   $0xc0106e74,0xc(%esp)
c010416d:	c0 
c010416e:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c0104175:	c0 
c0104176:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c010417d:	00 
c010417e:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c0104185:	e8 ab c2 ff ff       	call   c0100435 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c010418a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010418d:	89 04 24             	mov    %eax,(%esp)
c0104190:	e8 62 e9 ff ff       	call   c0102af7 <page2kva>
c0104195:	05 00 01 00 00       	add    $0x100,%eax
c010419a:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c010419d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01041a4:	e8 e5 14 00 00       	call   c010568e <strlen>
c01041a9:	85 c0                	test   %eax,%eax
c01041ab:	74 24                	je     c01041d1 <check_boot_pgdir+0x342>
c01041ad:	c7 44 24 0c ac 6e 10 	movl   $0xc0106eac,0xc(%esp)
c01041b4:	c0 
c01041b5:	c7 44 24 08 4d 6a 10 	movl   $0xc0106a4d,0x8(%esp)
c01041bc:	c0 
c01041bd:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c01041c4:	00 
c01041c5:	c7 04 24 28 6a 10 c0 	movl   $0xc0106a28,(%esp)
c01041cc:	e8 64 c2 ff ff       	call   c0100435 <__panic>

    free_page(p);
c01041d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041d8:	00 
c01041d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01041dc:	89 04 24             	mov    %eax,(%esp)
c01041df:	e8 0f ec ff ff       	call   c0102df3 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c01041e4:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01041e9:	8b 00                	mov    (%eax),%eax
c01041eb:	89 04 24             	mov    %eax,(%esp)
c01041ee:	e8 96 e9 ff ff       	call   c0102b89 <pde2page>
c01041f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01041fa:	00 
c01041fb:	89 04 24             	mov    %eax,(%esp)
c01041fe:	e8 f0 eb ff ff       	call   c0102df3 <free_pages>
    boot_pgdir[0] = 0;
c0104203:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104208:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c010420e:	c7 04 24 d0 6e 10 c0 	movl   $0xc0106ed0,(%esp)
c0104215:	e8 af c0 ff ff       	call   c01002c9 <cprintf>
}
c010421a:	90                   	nop
c010421b:	c9                   	leave  
c010421c:	c3                   	ret    

c010421d <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c010421d:	f3 0f 1e fb          	endbr32 
c0104221:	55                   	push   %ebp
c0104222:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0104224:	8b 45 08             	mov    0x8(%ebp),%eax
c0104227:	83 e0 04             	and    $0x4,%eax
c010422a:	85 c0                	test   %eax,%eax
c010422c:	74 04                	je     c0104232 <perm2str+0x15>
c010422e:	b0 75                	mov    $0x75,%al
c0104230:	eb 02                	jmp    c0104234 <perm2str+0x17>
c0104232:	b0 2d                	mov    $0x2d,%al
c0104234:	a2 08 cf 11 c0       	mov    %al,0xc011cf08
    str[1] = 'r';
c0104239:	c6 05 09 cf 11 c0 72 	movb   $0x72,0xc011cf09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0104240:	8b 45 08             	mov    0x8(%ebp),%eax
c0104243:	83 e0 02             	and    $0x2,%eax
c0104246:	85 c0                	test   %eax,%eax
c0104248:	74 04                	je     c010424e <perm2str+0x31>
c010424a:	b0 77                	mov    $0x77,%al
c010424c:	eb 02                	jmp    c0104250 <perm2str+0x33>
c010424e:	b0 2d                	mov    $0x2d,%al
c0104250:	a2 0a cf 11 c0       	mov    %al,0xc011cf0a
    str[3] = '\0';
c0104255:	c6 05 0b cf 11 c0 00 	movb   $0x0,0xc011cf0b
    return str;
c010425c:	b8 08 cf 11 c0       	mov    $0xc011cf08,%eax
}
c0104261:	5d                   	pop    %ebp
c0104262:	c3                   	ret    

c0104263 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0104263:	f3 0f 1e fb          	endbr32 
c0104267:	55                   	push   %ebp
c0104268:	89 e5                	mov    %esp,%ebp
c010426a:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c010426d:	8b 45 10             	mov    0x10(%ebp),%eax
c0104270:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104273:	72 0d                	jb     c0104282 <get_pgtable_items+0x1f>
        return 0;
c0104275:	b8 00 00 00 00       	mov    $0x0,%eax
c010427a:	e9 98 00 00 00       	jmp    c0104317 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c010427f:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c0104282:	8b 45 10             	mov    0x10(%ebp),%eax
c0104285:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104288:	73 18                	jae    c01042a2 <get_pgtable_items+0x3f>
c010428a:	8b 45 10             	mov    0x10(%ebp),%eax
c010428d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104294:	8b 45 14             	mov    0x14(%ebp),%eax
c0104297:	01 d0                	add    %edx,%eax
c0104299:	8b 00                	mov    (%eax),%eax
c010429b:	83 e0 01             	and    $0x1,%eax
c010429e:	85 c0                	test   %eax,%eax
c01042a0:	74 dd                	je     c010427f <get_pgtable_items+0x1c>
    }
    if (start < right) {
c01042a2:	8b 45 10             	mov    0x10(%ebp),%eax
c01042a5:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01042a8:	73 68                	jae    c0104312 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
c01042aa:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01042ae:	74 08                	je     c01042b8 <get_pgtable_items+0x55>
            *left_store = start;
c01042b0:	8b 45 18             	mov    0x18(%ebp),%eax
c01042b3:	8b 55 10             	mov    0x10(%ebp),%edx
c01042b6:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c01042b8:	8b 45 10             	mov    0x10(%ebp),%eax
c01042bb:	8d 50 01             	lea    0x1(%eax),%edx
c01042be:	89 55 10             	mov    %edx,0x10(%ebp)
c01042c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01042c8:	8b 45 14             	mov    0x14(%ebp),%eax
c01042cb:	01 d0                	add    %edx,%eax
c01042cd:	8b 00                	mov    (%eax),%eax
c01042cf:	83 e0 07             	and    $0x7,%eax
c01042d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01042d5:	eb 03                	jmp    c01042da <get_pgtable_items+0x77>
            start ++;
c01042d7:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c01042da:	8b 45 10             	mov    0x10(%ebp),%eax
c01042dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01042e0:	73 1d                	jae    c01042ff <get_pgtable_items+0x9c>
c01042e2:	8b 45 10             	mov    0x10(%ebp),%eax
c01042e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01042ec:	8b 45 14             	mov    0x14(%ebp),%eax
c01042ef:	01 d0                	add    %edx,%eax
c01042f1:	8b 00                	mov    (%eax),%eax
c01042f3:	83 e0 07             	and    $0x7,%eax
c01042f6:	89 c2                	mov    %eax,%edx
c01042f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01042fb:	39 c2                	cmp    %eax,%edx
c01042fd:	74 d8                	je     c01042d7 <get_pgtable_items+0x74>
        }
        if (right_store != NULL) {
c01042ff:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104303:	74 08                	je     c010430d <get_pgtable_items+0xaa>
            *right_store = start;
c0104305:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104308:	8b 55 10             	mov    0x10(%ebp),%edx
c010430b:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c010430d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104310:	eb 05                	jmp    c0104317 <get_pgtable_items+0xb4>
    }
    return 0;
c0104312:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104317:	c9                   	leave  
c0104318:	c3                   	ret    

c0104319 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0104319:	f3 0f 1e fb          	endbr32 
c010431d:	55                   	push   %ebp
c010431e:	89 e5                	mov    %esp,%ebp
c0104320:	57                   	push   %edi
c0104321:	56                   	push   %esi
c0104322:	53                   	push   %ebx
c0104323:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0104326:	c7 04 24 f0 6e 10 c0 	movl   $0xc0106ef0,(%esp)
c010432d:	e8 97 bf ff ff       	call   c01002c9 <cprintf>
    size_t left, right = 0, perm;
c0104332:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104339:	e9 fa 00 00 00       	jmp    c0104438 <print_pgdir+0x11f>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010433e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104341:	89 04 24             	mov    %eax,(%esp)
c0104344:	e8 d4 fe ff ff       	call   c010421d <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104349:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c010434c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010434f:	29 d1                	sub    %edx,%ecx
c0104351:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104353:	89 d6                	mov    %edx,%esi
c0104355:	c1 e6 16             	shl    $0x16,%esi
c0104358:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010435b:	89 d3                	mov    %edx,%ebx
c010435d:	c1 e3 16             	shl    $0x16,%ebx
c0104360:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104363:	89 d1                	mov    %edx,%ecx
c0104365:	c1 e1 16             	shl    $0x16,%ecx
c0104368:	8b 7d dc             	mov    -0x24(%ebp),%edi
c010436b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010436e:	29 d7                	sub    %edx,%edi
c0104370:	89 fa                	mov    %edi,%edx
c0104372:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104376:	89 74 24 10          	mov    %esi,0x10(%esp)
c010437a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010437e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104382:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104386:	c7 04 24 21 6f 10 c0 	movl   $0xc0106f21,(%esp)
c010438d:	e8 37 bf ff ff       	call   c01002c9 <cprintf>
        size_t l, r = left * NPTEENTRY;
c0104392:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104395:	c1 e0 0a             	shl    $0xa,%eax
c0104398:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010439b:	eb 54                	jmp    c01043f1 <print_pgdir+0xd8>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010439d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043a0:	89 04 24             	mov    %eax,(%esp)
c01043a3:	e8 75 fe ff ff       	call   c010421d <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01043a8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c01043ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043ae:	29 d1                	sub    %edx,%ecx
c01043b0:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01043b2:	89 d6                	mov    %edx,%esi
c01043b4:	c1 e6 0c             	shl    $0xc,%esi
c01043b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043ba:	89 d3                	mov    %edx,%ebx
c01043bc:	c1 e3 0c             	shl    $0xc,%ebx
c01043bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043c2:	89 d1                	mov    %edx,%ecx
c01043c4:	c1 e1 0c             	shl    $0xc,%ecx
c01043c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c01043ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043cd:	29 d7                	sub    %edx,%edi
c01043cf:	89 fa                	mov    %edi,%edx
c01043d1:	89 44 24 14          	mov    %eax,0x14(%esp)
c01043d5:	89 74 24 10          	mov    %esi,0x10(%esp)
c01043d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01043dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01043e1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01043e5:	c7 04 24 40 6f 10 c0 	movl   $0xc0106f40,(%esp)
c01043ec:	e8 d8 be ff ff       	call   c01002c9 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01043f1:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c01043f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01043f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01043fc:	89 d3                	mov    %edx,%ebx
c01043fe:	c1 e3 0a             	shl    $0xa,%ebx
c0104401:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104404:	89 d1                	mov    %edx,%ecx
c0104406:	c1 e1 0a             	shl    $0xa,%ecx
c0104409:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c010440c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104410:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104413:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104417:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010441b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010441f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104423:	89 0c 24             	mov    %ecx,(%esp)
c0104426:	e8 38 fe ff ff       	call   c0104263 <get_pgtable_items>
c010442b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010442e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104432:	0f 85 65 ff ff ff    	jne    c010439d <print_pgdir+0x84>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104438:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c010443d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104440:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0104443:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104447:	8d 55 e0             	lea    -0x20(%ebp),%edx
c010444a:	89 54 24 10          	mov    %edx,0x10(%esp)
c010444e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0104452:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104456:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c010445d:	00 
c010445e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0104465:	e8 f9 fd ff ff       	call   c0104263 <get_pgtable_items>
c010446a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010446d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104471:	0f 85 c7 fe ff ff    	jne    c010433e <print_pgdir+0x25>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104477:	c7 04 24 64 6f 10 c0 	movl   $0xc0106f64,(%esp)
c010447e:	e8 46 be ff ff       	call   c01002c9 <cprintf>
}
c0104483:	90                   	nop
c0104484:	83 c4 4c             	add    $0x4c,%esp
c0104487:	5b                   	pop    %ebx
c0104488:	5e                   	pop    %esi
c0104489:	5f                   	pop    %edi
c010448a:	5d                   	pop    %ebp
c010448b:	c3                   	ret    

c010448c <page2ppn>:
page2ppn(struct Page *page) {
c010448c:	55                   	push   %ebp
c010448d:	89 e5                	mov    %esp,%ebp
    return page - pages;
c010448f:	a1 18 cf 11 c0       	mov    0xc011cf18,%eax
c0104494:	8b 55 08             	mov    0x8(%ebp),%edx
c0104497:	29 c2                	sub    %eax,%edx
c0104499:	89 d0                	mov    %edx,%eax
c010449b:	c1 f8 02             	sar    $0x2,%eax
c010449e:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c01044a4:	5d                   	pop    %ebp
c01044a5:	c3                   	ret    

c01044a6 <page2pa>:
page2pa(struct Page *page) {
c01044a6:	55                   	push   %ebp
c01044a7:	89 e5                	mov    %esp,%ebp
c01044a9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01044ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01044af:	89 04 24             	mov    %eax,(%esp)
c01044b2:	e8 d5 ff ff ff       	call   c010448c <page2ppn>
c01044b7:	c1 e0 0c             	shl    $0xc,%eax
}
c01044ba:	c9                   	leave  
c01044bb:	c3                   	ret    

c01044bc <page_ref>:
page_ref(struct Page *page) {
c01044bc:	55                   	push   %ebp
c01044bd:	89 e5                	mov    %esp,%ebp
    return page->ref;
c01044bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01044c2:	8b 00                	mov    (%eax),%eax
}
c01044c4:	5d                   	pop    %ebp
c01044c5:	c3                   	ret    

c01044c6 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c01044c6:	55                   	push   %ebp
c01044c7:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c01044c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01044cc:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044cf:	89 10                	mov    %edx,(%eax)
}
c01044d1:	90                   	nop
c01044d2:	5d                   	pop    %ebp
c01044d3:	c3                   	ret    

c01044d4 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c01044d4:	f3 0f 1e fb          	endbr32 
c01044d8:	55                   	push   %ebp
c01044d9:	89 e5                	mov    %esp,%ebp
c01044db:	83 ec 10             	sub    $0x10,%esp
c01044de:	c7 45 fc 1c cf 11 c0 	movl   $0xc011cf1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01044e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01044e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01044eb:	89 50 04             	mov    %edx,0x4(%eax)
c01044ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01044f1:	8b 50 04             	mov    0x4(%eax),%edx
c01044f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01044f7:	89 10                	mov    %edx,(%eax)
}
c01044f9:	90                   	nop
    // 初始化链表
    list_init(&free_list);
    // 将可用内存块数目设置为0
    nr_free = 0;
c01044fa:	c7 05 24 cf 11 c0 00 	movl   $0x0,0xc011cf24
c0104501:	00 00 00 
}
c0104504:	90                   	nop
c0104505:	c9                   	leave  
c0104506:	c3                   	ret    

c0104507 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0104507:	f3 0f 1e fb          	endbr32 
c010450b:	55                   	push   %ebp
c010450c:	89 e5                	mov    %esp,%ebp
c010450e:	83 ec 48             	sub    $0x48,%esp
    // n要大于0
    assert(n > 0);
c0104511:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104515:	75 24                	jne    c010453b <default_init_memmap+0x34>
c0104517:	c7 44 24 0c 98 6f 10 	movl   $0xc0106f98,0xc(%esp)
c010451e:	c0 
c010451f:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104526:	c0 
c0104527:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010452e:	00 
c010452f:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104536:	e8 fa be ff ff       	call   c0100435 <__panic>
    // 令p为连续地址的空闲块的起始页
    struct Page *p = base;
c010453b:	8b 45 08             	mov    0x8(%ebp),%eax
c010453e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 将这个空闲块的每个页面初始化
    for (; p != base + n; p ++) {
c0104541:	e9 a7 00 00 00       	jmp    c01045ed <default_init_memmap+0xe6>
        // 每次循环首先检查p的PG_reserved位是否设置为1，表示空闲可分配
        assert(PageReserved(p));
c0104546:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104549:	83 c0 04             	add    $0x4,%eax
c010454c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0104553:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104556:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104559:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010455c:	0f a3 10             	bt     %edx,(%eax)
c010455f:	19 c0                	sbb    %eax,%eax
c0104561:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0104564:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104568:	0f 95 c0             	setne  %al
c010456b:	0f b6 c0             	movzbl %al,%eax
c010456e:	85 c0                	test   %eax,%eax
c0104570:	75 24                	jne    c0104596 <default_init_memmap+0x8f>
c0104572:	c7 44 24 0c c9 6f 10 	movl   $0xc0106fc9,0xc(%esp)
c0104579:	c0 
c010457a:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104581:	c0 
c0104582:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
c0104589:	00 
c010458a:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104591:	e8 9f be ff ff       	call   c0100435 <__panic>
        // 设置这一页的flag为0，表示这页空闲
        p->flags = 0;
c0104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104599:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        // 将这一页的ref设为0，因为这页现在空闲，没有引用
        set_page_ref(p, 0);
c01045a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01045a7:	00 
c01045a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045ab:	89 04 24             	mov    %eax,(%esp)
c01045ae:	e8 13 ff ff ff       	call   c01044c6 <set_page_ref>
        // 如果是空闲块的起始页
        if (p == base) {
c01045b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045b6:	3b 45 08             	cmp    0x8(%ebp),%eax
c01045b9:	75 24                	jne    c01045df <default_init_memmap+0xd8>
            // 空闲块的第一页的连续空页值property设置为块中的总页数
            p->property = n;
c01045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045be:	8b 55 0c             	mov    0xc(%ebp),%edx
c01045c1:	89 50 08             	mov    %edx,0x8(%eax)
            // 将空闲块的第一页的PG_property位设置为1，表示是起始页，可以被用作分配内存
            SetPageProperty(p);
c01045c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045c7:	83 c0 04             	add    $0x4,%eax
c01045ca:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01045d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01045d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01045d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01045da:	0f ab 10             	bts    %edx,(%eax)
}
c01045dd:	eb 0a                	jmp    c01045e9 <default_init_memmap+0xe2>
        } else {
            // 设置非起始页的property为0，表示不是qisiye起始页
            p->property = 0;
c01045df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    for (; p != base + n; p ++) {
c01045e9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01045ed:	8b 55 0c             	mov    0xc(%ebp),%edx
c01045f0:	89 d0                	mov    %edx,%eax
c01045f2:	c1 e0 02             	shl    $0x2,%eax
c01045f5:	01 d0                	add    %edx,%eax
c01045f7:	c1 e0 02             	shl    $0x2,%eax
c01045fa:	89 c2                	mov    %eax,%edx
c01045fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01045ff:	01 d0                	add    %edx,%eax
c0104601:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104604:	0f 85 3c ff ff ff    	jne    c0104546 <default_init_memmap+0x3f>
        }
    }
    // 将base->page_link此页链接到free_list中
    list_add_before(&free_list, &(base->page_link));
c010460a:	8b 45 08             	mov    0x8(%ebp),%eax
c010460d:	83 c0 0c             	add    $0xc,%eax
c0104610:	c7 45 dc 1c cf 11 c0 	movl   $0xc011cf1c,-0x24(%ebp)
c0104617:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010461a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010461d:	8b 00                	mov    (%eax),%eax
c010461f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104622:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104625:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104628:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010462b:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010462e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104631:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104634:	89 10                	mov    %edx,(%eax)
c0104636:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104639:	8b 10                	mov    (%eax),%edx
c010463b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010463e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104641:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104644:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104647:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010464a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010464d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0104650:	89 10                	mov    %edx,(%eax)
}
c0104652:	90                   	nop
}
c0104653:	90                   	nop
    // 将空闲页的数目加n
    nr_free += n;
c0104654:	8b 15 24 cf 11 c0    	mov    0xc011cf24,%edx
c010465a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010465d:	01 d0                	add    %edx,%eax
c010465f:	a3 24 cf 11 c0       	mov    %eax,0xc011cf24
}
c0104664:	90                   	nop
c0104665:	c9                   	leave  
c0104666:	c3                   	ret    

c0104667 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0104667:	f3 0f 1e fb          	endbr32 
c010466b:	55                   	push   %ebp
c010466c:	89 e5                	mov    %esp,%ebp
c010466e:	83 ec 68             	sub    $0x68,%esp
    // n要大于0
    assert(n > 0);
c0104671:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104675:	75 24                	jne    c010469b <default_alloc_pages+0x34>
c0104677:	c7 44 24 0c 98 6f 10 	movl   $0xc0106f98,0xc(%esp)
c010467e:	c0 
c010467f:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104686:	c0 
c0104687:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
c010468e:	00 
c010468f:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104696:	e8 9a bd ff ff       	call   c0100435 <__panic>
    // 考虑边界情况，当n大于可以分配的内存数时，直接返回，确保分配不会超出范围，保证软件的鲁棒性
    if (n > nr_free) {
c010469b:	a1 24 cf 11 c0       	mov    0xc011cf24,%eax
c01046a0:	39 45 08             	cmp    %eax,0x8(%ebp)
c01046a3:	76 0a                	jbe    c01046af <default_alloc_pages+0x48>
        return NULL;
c01046a5:	b8 00 00 00 00       	mov    $0x0,%eax
c01046aa:	e9 4e 01 00 00       	jmp    c01047fd <default_alloc_pages+0x196>
    }
    struct Page *page = NULL;
c01046af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = &free_list;
c01046b6:	c7 45 f0 1c cf 11 c0 	movl   $0xc011cf1c,-0x10(%ebp)
    // 遍历空闲链表
    while ((le = list_next(le)) != &free_list) {
c01046bd:	eb 1c                	jmp    c01046db <default_alloc_pages+0x74>
        // 由链表元素获得对应的Page指针p
        struct Page *p = le2page(le, page_link);
c01046bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046c2:	83 e8 0c             	sub    $0xc,%eax
c01046c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // 如果当前页面的property大于等于n，说明空闲块的连续空页数大于等于n，可以分配，令page等于p，直接退出
        if (p->property >= n) {
c01046c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046cb:	8b 40 08             	mov    0x8(%eax),%eax
c01046ce:	39 45 08             	cmp    %eax,0x8(%ebp)
c01046d1:	77 08                	ja     c01046db <default_alloc_pages+0x74>
            page = p;
c01046d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01046d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01046d9:	eb 18                	jmp    c01046f3 <default_alloc_pages+0x8c>
c01046db:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c01046e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01046e4:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01046e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046ea:	81 7d f0 1c cf 11 c0 	cmpl   $0xc011cf1c,-0x10(%ebp)
c01046f1:	75 cc                	jne    c01046bf <default_alloc_pages+0x58>
        }
    }
    // 如果找到了空闲块，进行重新组织
    if (page != NULL) {
c01046f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01046f7:	0f 84 fd 00 00 00    	je     c01047fa <default_alloc_pages+0x193>
        // 在空闲页链表中删除刚刚分配的空闲块
        list_del(&(page->page_link));
c01046fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104700:	83 c0 0c             	add    $0xc,%eax
c0104703:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104706:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104709:	8b 40 04             	mov    0x4(%eax),%eax
c010470c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010470f:	8b 12                	mov    (%edx),%edx
c0104711:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0104714:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104717:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010471a:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010471d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104720:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104723:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104726:	89 10                	mov    %edx,(%eax)
}
c0104728:	90                   	nop
}
c0104729:	90                   	nop
        // 如果可以分配的空闲块的连续空页数大于n
        if (page->property > n) {
c010472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010472d:	8b 40 08             	mov    0x8(%eax),%eax
c0104730:	39 45 08             	cmp    %eax,0x8(%ebp)
c0104733:	0f 83 9a 00 00 00    	jae    c01047d3 <default_alloc_pages+0x16c>
            // 创建一个地址为page+n的新物理页
            struct Page *p = page + n;
c0104739:	8b 55 08             	mov    0x8(%ebp),%edx
c010473c:	89 d0                	mov    %edx,%eax
c010473e:	c1 e0 02             	shl    $0x2,%eax
c0104741:	01 d0                	add    %edx,%eax
c0104743:	c1 e0 02             	shl    $0x2,%eax
c0104746:	89 c2                	mov    %eax,%edx
c0104748:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010474b:	01 d0                	add    %edx,%eax
c010474d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            // 页面的property设置为page多出来的空闲连续页数
            p->property = page->property - n;
c0104750:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104753:	8b 40 08             	mov    0x8(%eax),%eax
c0104756:	2b 45 08             	sub    0x8(%ebp),%eax
c0104759:	89 c2                	mov    %eax,%edx
c010475b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010475e:	89 50 08             	mov    %edx,0x8(%eax)
            // 设置p的Page_property位，表示为新的空闲块的起始页
            SetPageProperty(p);
c0104761:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104764:	83 c0 04             	add    $0x4,%eax
c0104767:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c010476e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104771:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104774:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104777:	0f ab 10             	bts    %edx,(%eax)
}
c010477a:	90                   	nop
            // 将新的空闲块的页插入到空闲页链表的后面
            list_add(&free_list, &(p->page_link));
c010477b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010477e:	83 c0 0c             	add    $0xc,%eax
c0104781:	c7 45 d4 1c cf 11 c0 	movl   $0xc011cf1c,-0x2c(%ebp)
c0104788:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010478b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010478e:	89 45 cc             	mov    %eax,-0x34(%ebp)
c0104791:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104794:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_add(elm, listelm, listelm->next);
c0104797:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010479a:	8b 40 04             	mov    0x4(%eax),%eax
c010479d:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01047a0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c01047a3:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01047a6:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01047a9:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next->prev = elm;
c01047ac:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01047af:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01047b2:	89 10                	mov    %edx,(%eax)
c01047b4:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01047b7:	8b 10                	mov    (%eax),%edx
c01047b9:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01047bc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01047bf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01047c2:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01047c5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01047c8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01047cb:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01047ce:	89 10                	mov    %edx,(%eax)
}
c01047d0:	90                   	nop
}
c01047d1:	90                   	nop
}
c01047d2:	90                   	nop
        }
        // 剩余空闲页的数目减n
        nr_free -= n;
c01047d3:	a1 24 cf 11 c0       	mov    0xc011cf24,%eax
c01047d8:	2b 45 08             	sub    0x8(%ebp),%eax
c01047db:	a3 24 cf 11 c0       	mov    %eax,0xc011cf24
        // 清除page的Page_property位，表示page已经被分配
        ClearPageProperty(page);
c01047e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047e3:	83 c0 04             	add    $0x4,%eax
c01047e6:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c01047ed:	89 45 ac             	mov    %eax,-0x54(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01047f0:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01047f3:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01047f6:	0f b3 10             	btr    %edx,(%eax)
}
c01047f9:	90                   	nop
    }
    // 没有找到空闲块，则直接返回NULL，否则返回空闲块page
    return page;
c01047fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01047fd:	c9                   	leave  
c01047fe:	c3                   	ret    

c01047ff <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c01047ff:	f3 0f 1e fb          	endbr32 
c0104803:	55                   	push   %ebp
c0104804:	89 e5                	mov    %esp,%ebp
c0104806:	81 ec 88 00 00 00    	sub    $0x88,%esp
    // n要大于0
    assert(n > 0);
c010480c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104810:	75 24                	jne    c0104836 <default_free_pages+0x37>
c0104812:	c7 44 24 0c 98 6f 10 	movl   $0xc0106f98,0xc(%esp)
c0104819:	c0 
c010481a:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104821:	c0 
c0104822:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0104829:	00 
c010482a:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104831:	e8 ff bb ff ff       	call   c0100435 <__panic>
    // 令p为连续地址的释放块的起始页
    struct Page *p = base;
c0104836:	8b 45 08             	mov    0x8(%ebp),%eax
c0104839:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 将这个释放块的每个页面初始化
    for (; p != base + n; p ++) {
c010483c:	e9 9d 00 00 00       	jmp    c01048de <default_free_pages+0xdf>
        // 检查每一页的Page_reserved位和Page_property是否都未被设置
        assert(!PageReserved(p) && !PageProperty(p));
c0104841:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104844:	83 c0 04             	add    $0x4,%eax
c0104847:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010484e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104851:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104854:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104857:	0f a3 10             	bt     %edx,(%eax)
c010485a:	19 c0                	sbb    %eax,%eax
c010485c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c010485f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104863:	0f 95 c0             	setne  %al
c0104866:	0f b6 c0             	movzbl %al,%eax
c0104869:	85 c0                	test   %eax,%eax
c010486b:	75 2c                	jne    c0104899 <default_free_pages+0x9a>
c010486d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104870:	83 c0 04             	add    $0x4,%eax
c0104873:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c010487a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010487d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104880:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104883:	0f a3 10             	bt     %edx,(%eax)
c0104886:	19 c0                	sbb    %eax,%eax
c0104888:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c010488b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c010488f:	0f 95 c0             	setne  %al
c0104892:	0f b6 c0             	movzbl %al,%eax
c0104895:	85 c0                	test   %eax,%eax
c0104897:	74 24                	je     c01048bd <default_free_pages+0xbe>
c0104899:	c7 44 24 0c dc 6f 10 	movl   $0xc0106fdc,0xc(%esp)
c01048a0:	c0 
c01048a1:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c01048a8:	c0 
c01048a9:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
c01048b0:	00 
c01048b1:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c01048b8:	e8 78 bb ff ff       	call   c0100435 <__panic>
        // 设置每一页的flags都为0，表示可以分配
        p->flags = 0;
c01048bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048c0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        // 设置每一页的ref都为0，表示这页空闲
        set_page_ref(p, 0);
c01048c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01048ce:	00 
c01048cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048d2:	89 04 24             	mov    %eax,(%esp)
c01048d5:	e8 ec fb ff ff       	call   c01044c6 <set_page_ref>
    for (; p != base + n; p ++) {
c01048da:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01048de:	8b 55 0c             	mov    0xc(%ebp),%edx
c01048e1:	89 d0                	mov    %edx,%eax
c01048e3:	c1 e0 02             	shl    $0x2,%eax
c01048e6:	01 d0                	add    %edx,%eax
c01048e8:	c1 e0 02             	shl    $0x2,%eax
c01048eb:	89 c2                	mov    %eax,%edx
c01048ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01048f0:	01 d0                	add    %edx,%eax
c01048f2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c01048f5:	0f 85 46 ff ff ff    	jne    c0104841 <default_free_pages+0x42>
    }
    // 释放块起始页的property连续空页数设置为n
    base->property = n;
c01048fb:	8b 45 08             	mov    0x8(%ebp),%eax
c01048fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104901:	89 50 08             	mov    %edx,0x8(%eax)
    // 设置起始页的Page_property位
    SetPageProperty(base);
c0104904:	8b 45 08             	mov    0x8(%ebp),%eax
c0104907:	83 c0 04             	add    $0x4,%eax
c010490a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0104911:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104914:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104917:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010491a:	0f ab 10             	bts    %edx,(%eax)
}
c010491d:	90                   	nop
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = &free_list;
c010491e:	c7 45 f0 1c cf 11 c0 	movl   $0xc011cf1c,-0x10(%ebp)
    // 遍历空闲链表，查看能否将释放块合并到合适的页块中
    while ((le = list_next(le)) != &free_list) {
c0104925:	e9 ff 00 00 00       	jmp    c0104a29 <default_free_pages+0x22a>
        // 由链表元素获得对应的Page指针p
        p = le2page(le, page_link);
c010492a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010492d:	83 e8 0c             	sub    $0xc,%eax
c0104930:	89 45 f4             	mov    %eax,-0xc(%ebp)
        // 如果释放块在下一个空闲块起始页的前面，那么进行合并
        if (base + base->property == p) {
c0104933:	8b 45 08             	mov    0x8(%ebp),%eax
c0104936:	8b 50 08             	mov    0x8(%eax),%edx
c0104939:	89 d0                	mov    %edx,%eax
c010493b:	c1 e0 02             	shl    $0x2,%eax
c010493e:	01 d0                	add    %edx,%eax
c0104940:	c1 e0 02             	shl    $0x2,%eax
c0104943:	89 c2                	mov    %eax,%edx
c0104945:	8b 45 08             	mov    0x8(%ebp),%eax
c0104948:	01 d0                	add    %edx,%eax
c010494a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010494d:	75 5d                	jne    c01049ac <default_free_pages+0x1ad>
            // 释放块的连续空页数要加上空闲块起始页p的连续空页数
            base->property += p->property;
c010494f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104952:	8b 50 08             	mov    0x8(%eax),%edx
c0104955:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104958:	8b 40 08             	mov    0x8(%eax),%eax
c010495b:	01 c2                	add    %eax,%edx
c010495d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104960:	89 50 08             	mov    %edx,0x8(%eax)
            // 清除p的Page_property位，表示p不再是新的空闲块的起始页
            ClearPageProperty(p);
c0104963:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104966:	83 c0 04             	add    $0x4,%eax
c0104969:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c0104970:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104973:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104976:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104979:	0f b3 10             	btr    %edx,(%eax)
}
c010497c:	90                   	nop
            // 将原来的空闲块删除
            list_del(&(p->page_link));
c010497d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104980:	83 c0 0c             	add    $0xc,%eax
c0104983:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104986:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104989:	8b 40 04             	mov    0x4(%eax),%eax
c010498c:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010498f:	8b 12                	mov    (%edx),%edx
c0104991:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0104994:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next;
c0104997:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010499a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c010499d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01049a0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01049a3:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01049a6:	89 10                	mov    %edx,(%eax)
}
c01049a8:	90                   	nop
}
c01049a9:	90                   	nop
c01049aa:	eb 7d                	jmp    c0104a29 <default_free_pages+0x22a>
        }
        // 如果释放块的起始页在上一个空闲块的后面，那么进行合并
        else if (p + p->property == base) {
c01049ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049af:	8b 50 08             	mov    0x8(%eax),%edx
c01049b2:	89 d0                	mov    %edx,%eax
c01049b4:	c1 e0 02             	shl    $0x2,%eax
c01049b7:	01 d0                	add    %edx,%eax
c01049b9:	c1 e0 02             	shl    $0x2,%eax
c01049bc:	89 c2                	mov    %eax,%edx
c01049be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049c1:	01 d0                	add    %edx,%eax
c01049c3:	39 45 08             	cmp    %eax,0x8(%ebp)
c01049c6:	75 61                	jne    c0104a29 <default_free_pages+0x22a>
            // 空闲块的连续空页数要加上释放块起始页base的连续空页数
            p->property += base->property;
c01049c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049cb:	8b 50 08             	mov    0x8(%eax),%edx
c01049ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01049d1:	8b 40 08             	mov    0x8(%eax),%eax
c01049d4:	01 c2                	add    %eax,%edx
c01049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049d9:	89 50 08             	mov    %edx,0x8(%eax)
            // 清除base的Page_property位，表示base不再是起始页
            ClearPageProperty(base);
c01049dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01049df:	83 c0 04             	add    $0x4,%eax
c01049e2:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01049e9:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01049ec:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01049ef:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01049f2:	0f b3 10             	btr    %edx,(%eax)
}
c01049f5:	90                   	nop
            // 新的空闲块的起始页变成p
            base = p;
c01049f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049f9:	89 45 08             	mov    %eax,0x8(%ebp)
            // 将原来的空闲块删除
            list_del(&(p->page_link));
c01049fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049ff:	83 c0 0c             	add    $0xc,%eax
c0104a02:	89 45 b8             	mov    %eax,-0x48(%ebp)
    __list_del(listelm->prev, listelm->next);
c0104a05:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104a08:	8b 40 04             	mov    0x4(%eax),%eax
c0104a0b:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0104a0e:	8b 12                	mov    (%edx),%edx
c0104a10:	89 55 b4             	mov    %edx,-0x4c(%ebp)
c0104a13:	89 45 b0             	mov    %eax,-0x50(%ebp)
    prev->next = next;
c0104a16:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104a19:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104a1c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104a1f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104a22:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0104a25:	89 10                	mov    %edx,(%eax)
}
c0104a27:	90                   	nop
}
c0104a28:	90                   	nop
c0104a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a2c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return listelm->next;
c0104a2f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104a32:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a38:	81 7d f0 1c cf 11 c0 	cmpl   $0xc011cf1c,-0x10(%ebp)
c0104a3f:	0f 85 e5 fe ff ff    	jne    c010492a <default_free_pages+0x12b>
        }
    }
    le = &free_list;
c0104a45:	c7 45 f0 1c cf 11 c0 	movl   $0xc011cf1c,-0x10(%ebp)
    // 遍历空闲链表，将合并好之后的页块加回空闲链表
    while ((le = list_next(le)) != &free_list) {
c0104a4c:	eb 25                	jmp    c0104a73 <default_free_pages+0x274>
        // 由链表元素获得对应的Page指针p
        p = le2page(le, page_link);
c0104a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a51:	83 e8 0c             	sub    $0xc,%eax
c0104a54:	89 45 f4             	mov    %eax,-0xc(%ebp)
        // 找到能够方向新的合并块的位置
        if (base + base->property <= p) {
c0104a57:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a5a:	8b 50 08             	mov    0x8(%eax),%edx
c0104a5d:	89 d0                	mov    %edx,%eax
c0104a5f:	c1 e0 02             	shl    $0x2,%eax
c0104a62:	01 d0                	add    %edx,%eax
c0104a64:	c1 e0 02             	shl    $0x2,%eax
c0104a67:	89 c2                	mov    %eax,%edx
c0104a69:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a6c:	01 d0                	add    %edx,%eax
c0104a6e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104a71:	73 1a                	jae    c0104a8d <default_free_pages+0x28e>
c0104a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a76:	89 45 a0             	mov    %eax,-0x60(%ebp)
c0104a79:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104a7c:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0104a7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104a82:	81 7d f0 1c cf 11 c0 	cmpl   $0xc011cf1c,-0x10(%ebp)
c0104a89:	75 c3                	jne    c0104a4e <default_free_pages+0x24f>
c0104a8b:	eb 01                	jmp    c0104a8e <default_free_pages+0x28f>
            break;
c0104a8d:	90                   	nop
        }
    }
    // 将空闲页的数目加n
    nr_free += n;
c0104a8e:	8b 15 24 cf 11 c0    	mov    0xc011cf24,%edx
c0104a94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a97:	01 d0                	add    %edx,%eax
c0104a99:	a3 24 cf 11 c0       	mov    %eax,0xc011cf24
    // 将base->page_link此页链接到le中，插入合适位置
    list_add_before(le, &(base->page_link));
c0104a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104aa1:	8d 50 0c             	lea    0xc(%eax),%edx
c0104aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104aa7:	89 45 9c             	mov    %eax,-0x64(%ebp)
c0104aaa:	89 55 98             	mov    %edx,-0x68(%ebp)
    __list_add(elm, listelm->prev, listelm);
c0104aad:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104ab0:	8b 00                	mov    (%eax),%eax
c0104ab2:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104ab5:	89 55 94             	mov    %edx,-0x6c(%ebp)
c0104ab8:	89 45 90             	mov    %eax,-0x70(%ebp)
c0104abb:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104abe:	89 45 8c             	mov    %eax,-0x74(%ebp)
    prev->next = next->prev = elm;
c0104ac1:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104ac4:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0104ac7:	89 10                	mov    %edx,(%eax)
c0104ac9:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104acc:	8b 10                	mov    (%eax),%edx
c0104ace:	8b 45 90             	mov    -0x70(%ebp),%eax
c0104ad1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104ad4:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104ad7:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104ada:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104add:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104ae0:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104ae3:	89 10                	mov    %edx,(%eax)
}
c0104ae5:	90                   	nop
}
c0104ae6:	90                   	nop
}
c0104ae7:	90                   	nop
c0104ae8:	c9                   	leave  
c0104ae9:	c3                   	ret    

c0104aea <default_nr_free_pages>:
static size_t
default_nr_free_pages(void) {
c0104aea:	f3 0f 1e fb          	endbr32 
c0104aee:	55                   	push   %ebp
c0104aef:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104af1:	a1 24 cf 11 c0       	mov    0xc011cf24,%eax
}
c0104af6:	5d                   	pop    %ebp
c0104af7:	c3                   	ret    

c0104af8 <basic_check>:

static void
basic_check(void) {
c0104af8:	f3 0f 1e fb          	endbr32 
c0104afc:	55                   	push   %ebp
c0104afd:	89 e5                	mov    %esp,%ebp
c0104aff:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104b02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b12:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104b15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b1c:	e8 96 e2 ff ff       	call   c0102db7 <alloc_pages>
c0104b21:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104b24:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104b28:	75 24                	jne    c0104b4e <basic_check+0x56>
c0104b2a:	c7 44 24 0c 01 70 10 	movl   $0xc0107001,0xc(%esp)
c0104b31:	c0 
c0104b32:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104b39:	c0 
c0104b3a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0104b41:	00 
c0104b42:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104b49:	e8 e7 b8 ff ff       	call   c0100435 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104b4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b55:	e8 5d e2 ff ff       	call   c0102db7 <alloc_pages>
c0104b5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b61:	75 24                	jne    c0104b87 <basic_check+0x8f>
c0104b63:	c7 44 24 0c 1d 70 10 	movl   $0xc010701d,0xc(%esp)
c0104b6a:	c0 
c0104b6b:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104b72:	c0 
c0104b73:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0104b7a:	00 
c0104b7b:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104b82:	e8 ae b8 ff ff       	call   c0100435 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104b87:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b8e:	e8 24 e2 ff ff       	call   c0102db7 <alloc_pages>
c0104b93:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104b9a:	75 24                	jne    c0104bc0 <basic_check+0xc8>
c0104b9c:	c7 44 24 0c 39 70 10 	movl   $0xc0107039,0xc(%esp)
c0104ba3:	c0 
c0104ba4:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104bab:	c0 
c0104bac:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c0104bb3:	00 
c0104bb4:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104bbb:	e8 75 b8 ff ff       	call   c0100435 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bc3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104bc6:	74 10                	je     c0104bd8 <basic_check+0xe0>
c0104bc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bcb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104bce:	74 08                	je     c0104bd8 <basic_check+0xe0>
c0104bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bd3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104bd6:	75 24                	jne    c0104bfc <basic_check+0x104>
c0104bd8:	c7 44 24 0c 58 70 10 	movl   $0xc0107058,0xc(%esp)
c0104bdf:	c0 
c0104be0:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104be7:	c0 
c0104be8:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c0104bef:	00 
c0104bf0:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104bf7:	e8 39 b8 ff ff       	call   c0100435 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104bfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bff:	89 04 24             	mov    %eax,(%esp)
c0104c02:	e8 b5 f8 ff ff       	call   c01044bc <page_ref>
c0104c07:	85 c0                	test   %eax,%eax
c0104c09:	75 1e                	jne    c0104c29 <basic_check+0x131>
c0104c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c0e:	89 04 24             	mov    %eax,(%esp)
c0104c11:	e8 a6 f8 ff ff       	call   c01044bc <page_ref>
c0104c16:	85 c0                	test   %eax,%eax
c0104c18:	75 0f                	jne    c0104c29 <basic_check+0x131>
c0104c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c1d:	89 04 24             	mov    %eax,(%esp)
c0104c20:	e8 97 f8 ff ff       	call   c01044bc <page_ref>
c0104c25:	85 c0                	test   %eax,%eax
c0104c27:	74 24                	je     c0104c4d <basic_check+0x155>
c0104c29:	c7 44 24 0c 7c 70 10 	movl   $0xc010707c,0xc(%esp)
c0104c30:	c0 
c0104c31:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104c38:	c0 
c0104c39:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c0104c40:	00 
c0104c41:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104c48:	e8 e8 b7 ff ff       	call   c0100435 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104c4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c50:	89 04 24             	mov    %eax,(%esp)
c0104c53:	e8 4e f8 ff ff       	call   c01044a6 <page2pa>
c0104c58:	8b 15 80 ce 11 c0    	mov    0xc011ce80,%edx
c0104c5e:	c1 e2 0c             	shl    $0xc,%edx
c0104c61:	39 d0                	cmp    %edx,%eax
c0104c63:	72 24                	jb     c0104c89 <basic_check+0x191>
c0104c65:	c7 44 24 0c b8 70 10 	movl   $0xc01070b8,0xc(%esp)
c0104c6c:	c0 
c0104c6d:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104c74:	c0 
c0104c75:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c0104c7c:	00 
c0104c7d:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104c84:	e8 ac b7 ff ff       	call   c0100435 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104c8c:	89 04 24             	mov    %eax,(%esp)
c0104c8f:	e8 12 f8 ff ff       	call   c01044a6 <page2pa>
c0104c94:	8b 15 80 ce 11 c0    	mov    0xc011ce80,%edx
c0104c9a:	c1 e2 0c             	shl    $0xc,%edx
c0104c9d:	39 d0                	cmp    %edx,%eax
c0104c9f:	72 24                	jb     c0104cc5 <basic_check+0x1cd>
c0104ca1:	c7 44 24 0c d5 70 10 	movl   $0xc01070d5,0xc(%esp)
c0104ca8:	c0 
c0104ca9:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104cb0:	c0 
c0104cb1:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0104cb8:	00 
c0104cb9:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104cc0:	e8 70 b7 ff ff       	call   c0100435 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104cc8:	89 04 24             	mov    %eax,(%esp)
c0104ccb:	e8 d6 f7 ff ff       	call   c01044a6 <page2pa>
c0104cd0:	8b 15 80 ce 11 c0    	mov    0xc011ce80,%edx
c0104cd6:	c1 e2 0c             	shl    $0xc,%edx
c0104cd9:	39 d0                	cmp    %edx,%eax
c0104cdb:	72 24                	jb     c0104d01 <basic_check+0x209>
c0104cdd:	c7 44 24 0c f2 70 10 	movl   $0xc01070f2,0xc(%esp)
c0104ce4:	c0 
c0104ce5:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104cec:	c0 
c0104ced:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0104cf4:	00 
c0104cf5:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104cfc:	e8 34 b7 ff ff       	call   c0100435 <__panic>

    list_entry_t free_list_store = free_list;
c0104d01:	a1 1c cf 11 c0       	mov    0xc011cf1c,%eax
c0104d06:	8b 15 20 cf 11 c0    	mov    0xc011cf20,%edx
c0104d0c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104d0f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104d12:	c7 45 dc 1c cf 11 c0 	movl   $0xc011cf1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0104d19:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d1c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104d1f:	89 50 04             	mov    %edx,0x4(%eax)
c0104d22:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d25:	8b 50 04             	mov    0x4(%eax),%edx
c0104d28:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104d2b:	89 10                	mov    %edx,(%eax)
}
c0104d2d:	90                   	nop
c0104d2e:	c7 45 e0 1c cf 11 c0 	movl   $0xc011cf1c,-0x20(%ebp)
    return list->next == list;
c0104d35:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104d38:	8b 40 04             	mov    0x4(%eax),%eax
c0104d3b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0104d3e:	0f 94 c0             	sete   %al
c0104d41:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104d44:	85 c0                	test   %eax,%eax
c0104d46:	75 24                	jne    c0104d6c <basic_check+0x274>
c0104d48:	c7 44 24 0c 0f 71 10 	movl   $0xc010710f,0xc(%esp)
c0104d4f:	c0 
c0104d50:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104d57:	c0 
c0104d58:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0104d5f:	00 
c0104d60:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104d67:	e8 c9 b6 ff ff       	call   c0100435 <__panic>

    unsigned int nr_free_store = nr_free;
c0104d6c:	a1 24 cf 11 c0       	mov    0xc011cf24,%eax
c0104d71:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c0104d74:	c7 05 24 cf 11 c0 00 	movl   $0x0,0xc011cf24
c0104d7b:	00 00 00 

    assert(alloc_page() == NULL);
c0104d7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104d85:	e8 2d e0 ff ff       	call   c0102db7 <alloc_pages>
c0104d8a:	85 c0                	test   %eax,%eax
c0104d8c:	74 24                	je     c0104db2 <basic_check+0x2ba>
c0104d8e:	c7 44 24 0c 26 71 10 	movl   $0xc0107126,0xc(%esp)
c0104d95:	c0 
c0104d96:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104d9d:	c0 
c0104d9e:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
c0104da5:	00 
c0104da6:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104dad:	e8 83 b6 ff ff       	call   c0100435 <__panic>

    free_page(p0);
c0104db2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104db9:	00 
c0104dba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104dbd:	89 04 24             	mov    %eax,(%esp)
c0104dc0:	e8 2e e0 ff ff       	call   c0102df3 <free_pages>
    free_page(p1);
c0104dc5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104dcc:	00 
c0104dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104dd0:	89 04 24             	mov    %eax,(%esp)
c0104dd3:	e8 1b e0 ff ff       	call   c0102df3 <free_pages>
    free_page(p2);
c0104dd8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104ddf:	00 
c0104de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104de3:	89 04 24             	mov    %eax,(%esp)
c0104de6:	e8 08 e0 ff ff       	call   c0102df3 <free_pages>
    assert(nr_free == 3);
c0104deb:	a1 24 cf 11 c0       	mov    0xc011cf24,%eax
c0104df0:	83 f8 03             	cmp    $0x3,%eax
c0104df3:	74 24                	je     c0104e19 <basic_check+0x321>
c0104df5:	c7 44 24 0c 3b 71 10 	movl   $0xc010713b,0xc(%esp)
c0104dfc:	c0 
c0104dfd:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104e04:	c0 
c0104e05:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0104e0c:	00 
c0104e0d:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104e14:	e8 1c b6 ff ff       	call   c0100435 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0104e19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e20:	e8 92 df ff ff       	call   c0102db7 <alloc_pages>
c0104e25:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104e28:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104e2c:	75 24                	jne    c0104e52 <basic_check+0x35a>
c0104e2e:	c7 44 24 0c 01 70 10 	movl   $0xc0107001,0xc(%esp)
c0104e35:	c0 
c0104e36:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104e3d:	c0 
c0104e3e:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0104e45:	00 
c0104e46:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104e4d:	e8 e3 b5 ff ff       	call   c0100435 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104e52:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e59:	e8 59 df ff ff       	call   c0102db7 <alloc_pages>
c0104e5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104e61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104e65:	75 24                	jne    c0104e8b <basic_check+0x393>
c0104e67:	c7 44 24 0c 1d 70 10 	movl   $0xc010701d,0xc(%esp)
c0104e6e:	c0 
c0104e6f:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104e76:	c0 
c0104e77:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0104e7e:	00 
c0104e7f:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104e86:	e8 aa b5 ff ff       	call   c0100435 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104e8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e92:	e8 20 df ff ff       	call   c0102db7 <alloc_pages>
c0104e97:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e9e:	75 24                	jne    c0104ec4 <basic_check+0x3cc>
c0104ea0:	c7 44 24 0c 39 70 10 	movl   $0xc0107039,0xc(%esp)
c0104ea7:	c0 
c0104ea8:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104eaf:	c0 
c0104eb0:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0104eb7:	00 
c0104eb8:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104ebf:	e8 71 b5 ff ff       	call   c0100435 <__panic>

    assert(alloc_page() == NULL);
c0104ec4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104ecb:	e8 e7 de ff ff       	call   c0102db7 <alloc_pages>
c0104ed0:	85 c0                	test   %eax,%eax
c0104ed2:	74 24                	je     c0104ef8 <basic_check+0x400>
c0104ed4:	c7 44 24 0c 26 71 10 	movl   $0xc0107126,0xc(%esp)
c0104edb:	c0 
c0104edc:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104ee3:	c0 
c0104ee4:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c0104eeb:	00 
c0104eec:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104ef3:	e8 3d b5 ff ff       	call   c0100435 <__panic>

    free_page(p0);
c0104ef8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104eff:	00 
c0104f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f03:	89 04 24             	mov    %eax,(%esp)
c0104f06:	e8 e8 de ff ff       	call   c0102df3 <free_pages>
c0104f0b:	c7 45 d8 1c cf 11 c0 	movl   $0xc011cf1c,-0x28(%ebp)
c0104f12:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104f15:	8b 40 04             	mov    0x4(%eax),%eax
c0104f18:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104f1b:	0f 94 c0             	sete   %al
c0104f1e:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0104f21:	85 c0                	test   %eax,%eax
c0104f23:	74 24                	je     c0104f49 <basic_check+0x451>
c0104f25:	c7 44 24 0c 48 71 10 	movl   $0xc0107148,0xc(%esp)
c0104f2c:	c0 
c0104f2d:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104f34:	c0 
c0104f35:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0104f3c:	00 
c0104f3d:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104f44:	e8 ec b4 ff ff       	call   c0100435 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0104f49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f50:	e8 62 de ff ff       	call   c0102db7 <alloc_pages>
c0104f55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104f58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104f5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104f5e:	74 24                	je     c0104f84 <basic_check+0x48c>
c0104f60:	c7 44 24 0c 60 71 10 	movl   $0xc0107160,0xc(%esp)
c0104f67:	c0 
c0104f68:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104f6f:	c0 
c0104f70:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
c0104f77:	00 
c0104f78:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104f7f:	e8 b1 b4 ff ff       	call   c0100435 <__panic>
    assert(alloc_page() == NULL);
c0104f84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104f8b:	e8 27 de ff ff       	call   c0102db7 <alloc_pages>
c0104f90:	85 c0                	test   %eax,%eax
c0104f92:	74 24                	je     c0104fb8 <basic_check+0x4c0>
c0104f94:	c7 44 24 0c 26 71 10 	movl   $0xc0107126,0xc(%esp)
c0104f9b:	c0 
c0104f9c:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104fa3:	c0 
c0104fa4:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0104fab:	00 
c0104fac:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104fb3:	e8 7d b4 ff ff       	call   c0100435 <__panic>

    assert(nr_free == 0);
c0104fb8:	a1 24 cf 11 c0       	mov    0xc011cf24,%eax
c0104fbd:	85 c0                	test   %eax,%eax
c0104fbf:	74 24                	je     c0104fe5 <basic_check+0x4ed>
c0104fc1:	c7 44 24 0c 79 71 10 	movl   $0xc0107179,0xc(%esp)
c0104fc8:	c0 
c0104fc9:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0104fd0:	c0 
c0104fd1:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
c0104fd8:	00 
c0104fd9:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0104fe0:	e8 50 b4 ff ff       	call   c0100435 <__panic>
    free_list = free_list_store;
c0104fe5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104fe8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104feb:	a3 1c cf 11 c0       	mov    %eax,0xc011cf1c
c0104ff0:	89 15 20 cf 11 c0    	mov    %edx,0xc011cf20
    nr_free = nr_free_store;
c0104ff6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ff9:	a3 24 cf 11 c0       	mov    %eax,0xc011cf24

    free_page(p);
c0104ffe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105005:	00 
c0105006:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105009:	89 04 24             	mov    %eax,(%esp)
c010500c:	e8 e2 dd ff ff       	call   c0102df3 <free_pages>
    free_page(p1);
c0105011:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105018:	00 
c0105019:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010501c:	89 04 24             	mov    %eax,(%esp)
c010501f:	e8 cf dd ff ff       	call   c0102df3 <free_pages>
    free_page(p2);
c0105024:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010502b:	00 
c010502c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010502f:	89 04 24             	mov    %eax,(%esp)
c0105032:	e8 bc dd ff ff       	call   c0102df3 <free_pages>
}
c0105037:	90                   	nop
c0105038:	c9                   	leave  
c0105039:	c3                   	ret    

c010503a <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c010503a:	f3 0f 1e fb          	endbr32 
c010503e:	55                   	push   %ebp
c010503f:	89 e5                	mov    %esp,%ebp
c0105041:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0105047:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010504e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0105055:	c7 45 ec 1c cf 11 c0 	movl   $0xc011cf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010505c:	eb 6a                	jmp    c01050c8 <default_check+0x8e>
        struct Page *p = le2page(le, page_link);
c010505e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105061:	83 e8 0c             	sub    $0xc,%eax
c0105064:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0105067:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010506a:	83 c0 04             	add    $0x4,%eax
c010506d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0105074:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105077:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010507a:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010507d:	0f a3 10             	bt     %edx,(%eax)
c0105080:	19 c0                	sbb    %eax,%eax
c0105082:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c0105085:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c0105089:	0f 95 c0             	setne  %al
c010508c:	0f b6 c0             	movzbl %al,%eax
c010508f:	85 c0                	test   %eax,%eax
c0105091:	75 24                	jne    c01050b7 <default_check+0x7d>
c0105093:	c7 44 24 0c 86 71 10 	movl   $0xc0107186,0xc(%esp)
c010509a:	c0 
c010509b:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c01050a2:	c0 
c01050a3:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c01050aa:	00 
c01050ab:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c01050b2:	e8 7e b3 ff ff       	call   c0100435 <__panic>
        count ++, total += p->property;
c01050b7:	ff 45 f4             	incl   -0xc(%ebp)
c01050ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01050bd:	8b 50 08             	mov    0x8(%eax),%edx
c01050c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050c3:	01 d0                	add    %edx,%eax
c01050c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01050c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050cb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c01050ce:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01050d1:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c01050d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01050d7:	81 7d ec 1c cf 11 c0 	cmpl   $0xc011cf1c,-0x14(%ebp)
c01050de:	0f 85 7a ff ff ff    	jne    c010505e <default_check+0x24>
    }
    assert(total == nr_free_pages());
c01050e4:	e8 41 dd ff ff       	call   c0102e2a <nr_free_pages>
c01050e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01050ec:	39 d0                	cmp    %edx,%eax
c01050ee:	74 24                	je     c0105114 <default_check+0xda>
c01050f0:	c7 44 24 0c 96 71 10 	movl   $0xc0107196,0xc(%esp)
c01050f7:	c0 
c01050f8:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c01050ff:	c0 
c0105100:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0105107:	00 
c0105108:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c010510f:	e8 21 b3 ff ff       	call   c0100435 <__panic>

    basic_check();
c0105114:	e8 df f9 ff ff       	call   c0104af8 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0105119:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105120:	e8 92 dc ff ff       	call   c0102db7 <alloc_pages>
c0105125:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0105128:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010512c:	75 24                	jne    c0105152 <default_check+0x118>
c010512e:	c7 44 24 0c af 71 10 	movl   $0xc01071af,0xc(%esp)
c0105135:	c0 
c0105136:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c010513d:	c0 
c010513e:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
c0105145:	00 
c0105146:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c010514d:	e8 e3 b2 ff ff       	call   c0100435 <__panic>
    assert(!PageProperty(p0));
c0105152:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105155:	83 c0 04             	add    $0x4,%eax
c0105158:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010515f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105162:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105165:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0105168:	0f a3 10             	bt     %edx,(%eax)
c010516b:	19 c0                	sbb    %eax,%eax
c010516d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0105170:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0105174:	0f 95 c0             	setne  %al
c0105177:	0f b6 c0             	movzbl %al,%eax
c010517a:	85 c0                	test   %eax,%eax
c010517c:	74 24                	je     c01051a2 <default_check+0x168>
c010517e:	c7 44 24 0c ba 71 10 	movl   $0xc01071ba,0xc(%esp)
c0105185:	c0 
c0105186:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c010518d:	c0 
c010518e:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
c0105195:	00 
c0105196:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c010519d:	e8 93 b2 ff ff       	call   c0100435 <__panic>

    list_entry_t free_list_store = free_list;
c01051a2:	a1 1c cf 11 c0       	mov    0xc011cf1c,%eax
c01051a7:	8b 15 20 cf 11 c0    	mov    0xc011cf20,%edx
c01051ad:	89 45 80             	mov    %eax,-0x80(%ebp)
c01051b0:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01051b3:	c7 45 b0 1c cf 11 c0 	movl   $0xc011cf1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01051ba:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01051bd:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01051c0:	89 50 04             	mov    %edx,0x4(%eax)
c01051c3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01051c6:	8b 50 04             	mov    0x4(%eax),%edx
c01051c9:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01051cc:	89 10                	mov    %edx,(%eax)
}
c01051ce:	90                   	nop
c01051cf:	c7 45 b4 1c cf 11 c0 	movl   $0xc011cf1c,-0x4c(%ebp)
    return list->next == list;
c01051d6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01051d9:	8b 40 04             	mov    0x4(%eax),%eax
c01051dc:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c01051df:	0f 94 c0             	sete   %al
c01051e2:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01051e5:	85 c0                	test   %eax,%eax
c01051e7:	75 24                	jne    c010520d <default_check+0x1d3>
c01051e9:	c7 44 24 0c 0f 71 10 	movl   $0xc010710f,0xc(%esp)
c01051f0:	c0 
c01051f1:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c01051f8:	c0 
c01051f9:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
c0105200:	00 
c0105201:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0105208:	e8 28 b2 ff ff       	call   c0100435 <__panic>
    assert(alloc_page() == NULL);
c010520d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105214:	e8 9e db ff ff       	call   c0102db7 <alloc_pages>
c0105219:	85 c0                	test   %eax,%eax
c010521b:	74 24                	je     c0105241 <default_check+0x207>
c010521d:	c7 44 24 0c 26 71 10 	movl   $0xc0107126,0xc(%esp)
c0105224:	c0 
c0105225:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c010522c:	c0 
c010522d:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
c0105234:	00 
c0105235:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c010523c:	e8 f4 b1 ff ff       	call   c0100435 <__panic>

    unsigned int nr_free_store = nr_free;
c0105241:	a1 24 cf 11 c0       	mov    0xc011cf24,%eax
c0105246:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0105249:	c7 05 24 cf 11 c0 00 	movl   $0x0,0xc011cf24
c0105250:	00 00 00 

    free_pages(p0 + 2, 3);
c0105253:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105256:	83 c0 28             	add    $0x28,%eax
c0105259:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105260:	00 
c0105261:	89 04 24             	mov    %eax,(%esp)
c0105264:	e8 8a db ff ff       	call   c0102df3 <free_pages>
    assert(alloc_pages(4) == NULL);
c0105269:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0105270:	e8 42 db ff ff       	call   c0102db7 <alloc_pages>
c0105275:	85 c0                	test   %eax,%eax
c0105277:	74 24                	je     c010529d <default_check+0x263>
c0105279:	c7 44 24 0c cc 71 10 	movl   $0xc01071cc,0xc(%esp)
c0105280:	c0 
c0105281:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0105288:	c0 
c0105289:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
c0105290:	00 
c0105291:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0105298:	e8 98 b1 ff ff       	call   c0100435 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010529d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052a0:	83 c0 28             	add    $0x28,%eax
c01052a3:	83 c0 04             	add    $0x4,%eax
c01052a6:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01052ad:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01052b0:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01052b3:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01052b6:	0f a3 10             	bt     %edx,(%eax)
c01052b9:	19 c0                	sbb    %eax,%eax
c01052bb:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01052be:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01052c2:	0f 95 c0             	setne  %al
c01052c5:	0f b6 c0             	movzbl %al,%eax
c01052c8:	85 c0                	test   %eax,%eax
c01052ca:	74 0e                	je     c01052da <default_check+0x2a0>
c01052cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01052cf:	83 c0 28             	add    $0x28,%eax
c01052d2:	8b 40 08             	mov    0x8(%eax),%eax
c01052d5:	83 f8 03             	cmp    $0x3,%eax
c01052d8:	74 24                	je     c01052fe <default_check+0x2c4>
c01052da:	c7 44 24 0c e4 71 10 	movl   $0xc01071e4,0xc(%esp)
c01052e1:	c0 
c01052e2:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c01052e9:	c0 
c01052ea:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
c01052f1:	00 
c01052f2:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c01052f9:	e8 37 b1 ff ff       	call   c0100435 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c01052fe:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105305:	e8 ad da ff ff       	call   c0102db7 <alloc_pages>
c010530a:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010530d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105311:	75 24                	jne    c0105337 <default_check+0x2fd>
c0105313:	c7 44 24 0c 10 72 10 	movl   $0xc0107210,0xc(%esp)
c010531a:	c0 
c010531b:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0105322:	c0 
c0105323:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
c010532a:	00 
c010532b:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0105332:	e8 fe b0 ff ff       	call   c0100435 <__panic>
    assert(alloc_page() == NULL);
c0105337:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010533e:	e8 74 da ff ff       	call   c0102db7 <alloc_pages>
c0105343:	85 c0                	test   %eax,%eax
c0105345:	74 24                	je     c010536b <default_check+0x331>
c0105347:	c7 44 24 0c 26 71 10 	movl   $0xc0107126,0xc(%esp)
c010534e:	c0 
c010534f:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0105356:	c0 
c0105357:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
c010535e:	00 
c010535f:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0105366:	e8 ca b0 ff ff       	call   c0100435 <__panic>
    assert(p0 + 2 == p1);
c010536b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010536e:	83 c0 28             	add    $0x28,%eax
c0105371:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105374:	74 24                	je     c010539a <default_check+0x360>
c0105376:	c7 44 24 0c 2e 72 10 	movl   $0xc010722e,0xc(%esp)
c010537d:	c0 
c010537e:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0105385:	c0 
c0105386:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c010538d:	00 
c010538e:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0105395:	e8 9b b0 ff ff       	call   c0100435 <__panic>

    p2 = p0 + 1;
c010539a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010539d:	83 c0 14             	add    $0x14,%eax
c01053a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01053a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01053aa:	00 
c01053ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053ae:	89 04 24             	mov    %eax,(%esp)
c01053b1:	e8 3d da ff ff       	call   c0102df3 <free_pages>
    free_pages(p1, 3);
c01053b6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01053bd:	00 
c01053be:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01053c1:	89 04 24             	mov    %eax,(%esp)
c01053c4:	e8 2a da ff ff       	call   c0102df3 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01053c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053cc:	83 c0 04             	add    $0x4,%eax
c01053cf:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c01053d6:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01053d9:	8b 45 9c             	mov    -0x64(%ebp),%eax
c01053dc:	8b 55 a0             	mov    -0x60(%ebp),%edx
c01053df:	0f a3 10             	bt     %edx,(%eax)
c01053e2:	19 c0                	sbb    %eax,%eax
c01053e4:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c01053e7:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c01053eb:	0f 95 c0             	setne  %al
c01053ee:	0f b6 c0             	movzbl %al,%eax
c01053f1:	85 c0                	test   %eax,%eax
c01053f3:	74 0b                	je     c0105400 <default_check+0x3c6>
c01053f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053f8:	8b 40 08             	mov    0x8(%eax),%eax
c01053fb:	83 f8 01             	cmp    $0x1,%eax
c01053fe:	74 24                	je     c0105424 <default_check+0x3ea>
c0105400:	c7 44 24 0c 3c 72 10 	movl   $0xc010723c,0xc(%esp)
c0105407:	c0 
c0105408:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c010540f:	c0 
c0105410:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
c0105417:	00 
c0105418:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c010541f:	e8 11 b0 ff ff       	call   c0100435 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105424:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105427:	83 c0 04             	add    $0x4,%eax
c010542a:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0105431:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105434:	8b 45 90             	mov    -0x70(%ebp),%eax
c0105437:	8b 55 94             	mov    -0x6c(%ebp),%edx
c010543a:	0f a3 10             	bt     %edx,(%eax)
c010543d:	19 c0                	sbb    %eax,%eax
c010543f:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0105442:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0105446:	0f 95 c0             	setne  %al
c0105449:	0f b6 c0             	movzbl %al,%eax
c010544c:	85 c0                	test   %eax,%eax
c010544e:	74 0b                	je     c010545b <default_check+0x421>
c0105450:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105453:	8b 40 08             	mov    0x8(%eax),%eax
c0105456:	83 f8 03             	cmp    $0x3,%eax
c0105459:	74 24                	je     c010547f <default_check+0x445>
c010545b:	c7 44 24 0c 64 72 10 	movl   $0xc0107264,0xc(%esp)
c0105462:	c0 
c0105463:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c010546a:	c0 
c010546b:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
c0105472:	00 
c0105473:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c010547a:	e8 b6 af ff ff       	call   c0100435 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010547f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105486:	e8 2c d9 ff ff       	call   c0102db7 <alloc_pages>
c010548b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010548e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105491:	83 e8 14             	sub    $0x14,%eax
c0105494:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105497:	74 24                	je     c01054bd <default_check+0x483>
c0105499:	c7 44 24 0c 8a 72 10 	movl   $0xc010728a,0xc(%esp)
c01054a0:	c0 
c01054a1:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c01054a8:	c0 
c01054a9:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
c01054b0:	00 
c01054b1:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c01054b8:	e8 78 af ff ff       	call   c0100435 <__panic>
    free_page(p0);
c01054bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01054c4:	00 
c01054c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054c8:	89 04 24             	mov    %eax,(%esp)
c01054cb:	e8 23 d9 ff ff       	call   c0102df3 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c01054d0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c01054d7:	e8 db d8 ff ff       	call   c0102db7 <alloc_pages>
c01054dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01054df:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054e2:	83 c0 14             	add    $0x14,%eax
c01054e5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01054e8:	74 24                	je     c010550e <default_check+0x4d4>
c01054ea:	c7 44 24 0c a8 72 10 	movl   $0xc01072a8,0xc(%esp)
c01054f1:	c0 
c01054f2:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c01054f9:	c0 
c01054fa:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c0105501:	00 
c0105502:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0105509:	e8 27 af ff ff       	call   c0100435 <__panic>

    free_pages(p0, 2);
c010550e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0105515:	00 
c0105516:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105519:	89 04 24             	mov    %eax,(%esp)
c010551c:	e8 d2 d8 ff ff       	call   c0102df3 <free_pages>
    free_page(p2);
c0105521:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105528:	00 
c0105529:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010552c:	89 04 24             	mov    %eax,(%esp)
c010552f:	e8 bf d8 ff ff       	call   c0102df3 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0105534:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010553b:	e8 77 d8 ff ff       	call   c0102db7 <alloc_pages>
c0105540:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105543:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105547:	75 24                	jne    c010556d <default_check+0x533>
c0105549:	c7 44 24 0c c8 72 10 	movl   $0xc01072c8,0xc(%esp)
c0105550:	c0 
c0105551:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0105558:	c0 
c0105559:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
c0105560:	00 
c0105561:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0105568:	e8 c8 ae ff ff       	call   c0100435 <__panic>
    assert(alloc_page() == NULL);
c010556d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105574:	e8 3e d8 ff ff       	call   c0102db7 <alloc_pages>
c0105579:	85 c0                	test   %eax,%eax
c010557b:	74 24                	je     c01055a1 <default_check+0x567>
c010557d:	c7 44 24 0c 26 71 10 	movl   $0xc0107126,0xc(%esp)
c0105584:	c0 
c0105585:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c010558c:	c0 
c010558d:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
c0105594:	00 
c0105595:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c010559c:	e8 94 ae ff ff       	call   c0100435 <__panic>

    assert(nr_free == 0);
c01055a1:	a1 24 cf 11 c0       	mov    0xc011cf24,%eax
c01055a6:	85 c0                	test   %eax,%eax
c01055a8:	74 24                	je     c01055ce <default_check+0x594>
c01055aa:	c7 44 24 0c 79 71 10 	movl   $0xc0107179,0xc(%esp)
c01055b1:	c0 
c01055b2:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c01055b9:	c0 
c01055ba:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
c01055c1:	00 
c01055c2:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c01055c9:	e8 67 ae ff ff       	call   c0100435 <__panic>
    nr_free = nr_free_store;
c01055ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055d1:	a3 24 cf 11 c0       	mov    %eax,0xc011cf24

    free_list = free_list_store;
c01055d6:	8b 45 80             	mov    -0x80(%ebp),%eax
c01055d9:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01055dc:	a3 1c cf 11 c0       	mov    %eax,0xc011cf1c
c01055e1:	89 15 20 cf 11 c0    	mov    %edx,0xc011cf20
    free_pages(p0, 5);
c01055e7:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c01055ee:	00 
c01055ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01055f2:	89 04 24             	mov    %eax,(%esp)
c01055f5:	e8 f9 d7 ff ff       	call   c0102df3 <free_pages>

    le = &free_list;
c01055fa:	c7 45 ec 1c cf 11 c0 	movl   $0xc011cf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105601:	eb 1c                	jmp    c010561f <default_check+0x5e5>
        struct Page *p = le2page(le, page_link);
c0105603:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105606:	83 e8 0c             	sub    $0xc,%eax
c0105609:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c010560c:	ff 4d f4             	decl   -0xc(%ebp)
c010560f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105612:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105615:	8b 40 08             	mov    0x8(%eax),%eax
c0105618:	29 c2                	sub    %eax,%edx
c010561a:	89 d0                	mov    %edx,%eax
c010561c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010561f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105622:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0105625:	8b 45 88             	mov    -0x78(%ebp),%eax
c0105628:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c010562b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010562e:	81 7d ec 1c cf 11 c0 	cmpl   $0xc011cf1c,-0x14(%ebp)
c0105635:	75 cc                	jne    c0105603 <default_check+0x5c9>
    }
    assert(count == 0);
c0105637:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010563b:	74 24                	je     c0105661 <default_check+0x627>
c010563d:	c7 44 24 0c e6 72 10 	movl   $0xc01072e6,0xc(%esp)
c0105644:	c0 
c0105645:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c010564c:	c0 
c010564d:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
c0105654:	00 
c0105655:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c010565c:	e8 d4 ad ff ff       	call   c0100435 <__panic>
    assert(total == 0);
c0105661:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105665:	74 24                	je     c010568b <default_check+0x651>
c0105667:	c7 44 24 0c f1 72 10 	movl   $0xc01072f1,0xc(%esp)
c010566e:	c0 
c010566f:	c7 44 24 08 9e 6f 10 	movl   $0xc0106f9e,0x8(%esp)
c0105676:	c0 
c0105677:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c010567e:	00 
c010567f:	c7 04 24 b3 6f 10 c0 	movl   $0xc0106fb3,(%esp)
c0105686:	e8 aa ad ff ff       	call   c0100435 <__panic>
}
c010568b:	90                   	nop
c010568c:	c9                   	leave  
c010568d:	c3                   	ret    

c010568e <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010568e:	f3 0f 1e fb          	endbr32 
c0105692:	55                   	push   %ebp
c0105693:	89 e5                	mov    %esp,%ebp
c0105695:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105698:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c010569f:	eb 03                	jmp    c01056a4 <strlen+0x16>
        cnt ++;
c01056a1:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c01056a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01056a7:	8d 50 01             	lea    0x1(%eax),%edx
c01056aa:	89 55 08             	mov    %edx,0x8(%ebp)
c01056ad:	0f b6 00             	movzbl (%eax),%eax
c01056b0:	84 c0                	test   %al,%al
c01056b2:	75 ed                	jne    c01056a1 <strlen+0x13>
    }
    return cnt;
c01056b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01056b7:	c9                   	leave  
c01056b8:	c3                   	ret    

c01056b9 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c01056b9:	f3 0f 1e fb          	endbr32 
c01056bd:	55                   	push   %ebp
c01056be:	89 e5                	mov    %esp,%ebp
c01056c0:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01056c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01056ca:	eb 03                	jmp    c01056cf <strnlen+0x16>
        cnt ++;
c01056cc:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c01056cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01056d2:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01056d5:	73 10                	jae    c01056e7 <strnlen+0x2e>
c01056d7:	8b 45 08             	mov    0x8(%ebp),%eax
c01056da:	8d 50 01             	lea    0x1(%eax),%edx
c01056dd:	89 55 08             	mov    %edx,0x8(%ebp)
c01056e0:	0f b6 00             	movzbl (%eax),%eax
c01056e3:	84 c0                	test   %al,%al
c01056e5:	75 e5                	jne    c01056cc <strnlen+0x13>
    }
    return cnt;
c01056e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01056ea:	c9                   	leave  
c01056eb:	c3                   	ret    

c01056ec <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01056ec:	f3 0f 1e fb          	endbr32 
c01056f0:	55                   	push   %ebp
c01056f1:	89 e5                	mov    %esp,%ebp
c01056f3:	57                   	push   %edi
c01056f4:	56                   	push   %esi
c01056f5:	83 ec 20             	sub    $0x20,%esp
c01056f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01056fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01056fe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105701:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105704:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105707:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010570a:	89 d1                	mov    %edx,%ecx
c010570c:	89 c2                	mov    %eax,%edx
c010570e:	89 ce                	mov    %ecx,%esi
c0105710:	89 d7                	mov    %edx,%edi
c0105712:	ac                   	lods   %ds:(%esi),%al
c0105713:	aa                   	stos   %al,%es:(%edi)
c0105714:	84 c0                	test   %al,%al
c0105716:	75 fa                	jne    c0105712 <strcpy+0x26>
c0105718:	89 fa                	mov    %edi,%edx
c010571a:	89 f1                	mov    %esi,%ecx
c010571c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010571f:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105722:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105725:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105728:	83 c4 20             	add    $0x20,%esp
c010572b:	5e                   	pop    %esi
c010572c:	5f                   	pop    %edi
c010572d:	5d                   	pop    %ebp
c010572e:	c3                   	ret    

c010572f <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c010572f:	f3 0f 1e fb          	endbr32 
c0105733:	55                   	push   %ebp
c0105734:	89 e5                	mov    %esp,%ebp
c0105736:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105739:	8b 45 08             	mov    0x8(%ebp),%eax
c010573c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010573f:	eb 1e                	jmp    c010575f <strncpy+0x30>
        if ((*p = *src) != '\0') {
c0105741:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105744:	0f b6 10             	movzbl (%eax),%edx
c0105747:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010574a:	88 10                	mov    %dl,(%eax)
c010574c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010574f:	0f b6 00             	movzbl (%eax),%eax
c0105752:	84 c0                	test   %al,%al
c0105754:	74 03                	je     c0105759 <strncpy+0x2a>
            src ++;
c0105756:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0105759:	ff 45 fc             	incl   -0x4(%ebp)
c010575c:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c010575f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105763:	75 dc                	jne    c0105741 <strncpy+0x12>
    }
    return dst;
c0105765:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105768:	c9                   	leave  
c0105769:	c3                   	ret    

c010576a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c010576a:	f3 0f 1e fb          	endbr32 
c010576e:	55                   	push   %ebp
c010576f:	89 e5                	mov    %esp,%ebp
c0105771:	57                   	push   %edi
c0105772:	56                   	push   %esi
c0105773:	83 ec 20             	sub    $0x20,%esp
c0105776:	8b 45 08             	mov    0x8(%ebp),%eax
c0105779:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010577c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010577f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0105782:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105785:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105788:	89 d1                	mov    %edx,%ecx
c010578a:	89 c2                	mov    %eax,%edx
c010578c:	89 ce                	mov    %ecx,%esi
c010578e:	89 d7                	mov    %edx,%edi
c0105790:	ac                   	lods   %ds:(%esi),%al
c0105791:	ae                   	scas   %es:(%edi),%al
c0105792:	75 08                	jne    c010579c <strcmp+0x32>
c0105794:	84 c0                	test   %al,%al
c0105796:	75 f8                	jne    c0105790 <strcmp+0x26>
c0105798:	31 c0                	xor    %eax,%eax
c010579a:	eb 04                	jmp    c01057a0 <strcmp+0x36>
c010579c:	19 c0                	sbb    %eax,%eax
c010579e:	0c 01                	or     $0x1,%al
c01057a0:	89 fa                	mov    %edi,%edx
c01057a2:	89 f1                	mov    %esi,%ecx
c01057a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01057a7:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01057aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c01057ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01057b0:	83 c4 20             	add    $0x20,%esp
c01057b3:	5e                   	pop    %esi
c01057b4:	5f                   	pop    %edi
c01057b5:	5d                   	pop    %ebp
c01057b6:	c3                   	ret    

c01057b7 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01057b7:	f3 0f 1e fb          	endbr32 
c01057bb:	55                   	push   %ebp
c01057bc:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01057be:	eb 09                	jmp    c01057c9 <strncmp+0x12>
        n --, s1 ++, s2 ++;
c01057c0:	ff 4d 10             	decl   0x10(%ebp)
c01057c3:	ff 45 08             	incl   0x8(%ebp)
c01057c6:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01057c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01057cd:	74 1a                	je     c01057e9 <strncmp+0x32>
c01057cf:	8b 45 08             	mov    0x8(%ebp),%eax
c01057d2:	0f b6 00             	movzbl (%eax),%eax
c01057d5:	84 c0                	test   %al,%al
c01057d7:	74 10                	je     c01057e9 <strncmp+0x32>
c01057d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01057dc:	0f b6 10             	movzbl (%eax),%edx
c01057df:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057e2:	0f b6 00             	movzbl (%eax),%eax
c01057e5:	38 c2                	cmp    %al,%dl
c01057e7:	74 d7                	je     c01057c0 <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c01057e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01057ed:	74 18                	je     c0105807 <strncmp+0x50>
c01057ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01057f2:	0f b6 00             	movzbl (%eax),%eax
c01057f5:	0f b6 d0             	movzbl %al,%edx
c01057f8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01057fb:	0f b6 00             	movzbl (%eax),%eax
c01057fe:	0f b6 c0             	movzbl %al,%eax
c0105801:	29 c2                	sub    %eax,%edx
c0105803:	89 d0                	mov    %edx,%eax
c0105805:	eb 05                	jmp    c010580c <strncmp+0x55>
c0105807:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010580c:	5d                   	pop    %ebp
c010580d:	c3                   	ret    

c010580e <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c010580e:	f3 0f 1e fb          	endbr32 
c0105812:	55                   	push   %ebp
c0105813:	89 e5                	mov    %esp,%ebp
c0105815:	83 ec 04             	sub    $0x4,%esp
c0105818:	8b 45 0c             	mov    0xc(%ebp),%eax
c010581b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c010581e:	eb 13                	jmp    c0105833 <strchr+0x25>
        if (*s == c) {
c0105820:	8b 45 08             	mov    0x8(%ebp),%eax
c0105823:	0f b6 00             	movzbl (%eax),%eax
c0105826:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105829:	75 05                	jne    c0105830 <strchr+0x22>
            return (char *)s;
c010582b:	8b 45 08             	mov    0x8(%ebp),%eax
c010582e:	eb 12                	jmp    c0105842 <strchr+0x34>
        }
        s ++;
c0105830:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105833:	8b 45 08             	mov    0x8(%ebp),%eax
c0105836:	0f b6 00             	movzbl (%eax),%eax
c0105839:	84 c0                	test   %al,%al
c010583b:	75 e3                	jne    c0105820 <strchr+0x12>
    }
    return NULL;
c010583d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105842:	c9                   	leave  
c0105843:	c3                   	ret    

c0105844 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105844:	f3 0f 1e fb          	endbr32 
c0105848:	55                   	push   %ebp
c0105849:	89 e5                	mov    %esp,%ebp
c010584b:	83 ec 04             	sub    $0x4,%esp
c010584e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105851:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105854:	eb 0e                	jmp    c0105864 <strfind+0x20>
        if (*s == c) {
c0105856:	8b 45 08             	mov    0x8(%ebp),%eax
c0105859:	0f b6 00             	movzbl (%eax),%eax
c010585c:	38 45 fc             	cmp    %al,-0x4(%ebp)
c010585f:	74 0f                	je     c0105870 <strfind+0x2c>
            break;
        }
        s ++;
c0105861:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105864:	8b 45 08             	mov    0x8(%ebp),%eax
c0105867:	0f b6 00             	movzbl (%eax),%eax
c010586a:	84 c0                	test   %al,%al
c010586c:	75 e8                	jne    c0105856 <strfind+0x12>
c010586e:	eb 01                	jmp    c0105871 <strfind+0x2d>
            break;
c0105870:	90                   	nop
    }
    return (char *)s;
c0105871:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105874:	c9                   	leave  
c0105875:	c3                   	ret    

c0105876 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105876:	f3 0f 1e fb          	endbr32 
c010587a:	55                   	push   %ebp
c010587b:	89 e5                	mov    %esp,%ebp
c010587d:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105880:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105887:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010588e:	eb 03                	jmp    c0105893 <strtol+0x1d>
        s ++;
c0105890:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0105893:	8b 45 08             	mov    0x8(%ebp),%eax
c0105896:	0f b6 00             	movzbl (%eax),%eax
c0105899:	3c 20                	cmp    $0x20,%al
c010589b:	74 f3                	je     c0105890 <strtol+0x1a>
c010589d:	8b 45 08             	mov    0x8(%ebp),%eax
c01058a0:	0f b6 00             	movzbl (%eax),%eax
c01058a3:	3c 09                	cmp    $0x9,%al
c01058a5:	74 e9                	je     c0105890 <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
c01058a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01058aa:	0f b6 00             	movzbl (%eax),%eax
c01058ad:	3c 2b                	cmp    $0x2b,%al
c01058af:	75 05                	jne    c01058b6 <strtol+0x40>
        s ++;
c01058b1:	ff 45 08             	incl   0x8(%ebp)
c01058b4:	eb 14                	jmp    c01058ca <strtol+0x54>
    }
    else if (*s == '-') {
c01058b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01058b9:	0f b6 00             	movzbl (%eax),%eax
c01058bc:	3c 2d                	cmp    $0x2d,%al
c01058be:	75 0a                	jne    c01058ca <strtol+0x54>
        s ++, neg = 1;
c01058c0:	ff 45 08             	incl   0x8(%ebp)
c01058c3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01058ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01058ce:	74 06                	je     c01058d6 <strtol+0x60>
c01058d0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01058d4:	75 22                	jne    c01058f8 <strtol+0x82>
c01058d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01058d9:	0f b6 00             	movzbl (%eax),%eax
c01058dc:	3c 30                	cmp    $0x30,%al
c01058de:	75 18                	jne    c01058f8 <strtol+0x82>
c01058e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01058e3:	40                   	inc    %eax
c01058e4:	0f b6 00             	movzbl (%eax),%eax
c01058e7:	3c 78                	cmp    $0x78,%al
c01058e9:	75 0d                	jne    c01058f8 <strtol+0x82>
        s += 2, base = 16;
c01058eb:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c01058ef:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c01058f6:	eb 29                	jmp    c0105921 <strtol+0xab>
    }
    else if (base == 0 && s[0] == '0') {
c01058f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01058fc:	75 16                	jne    c0105914 <strtol+0x9e>
c01058fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105901:	0f b6 00             	movzbl (%eax),%eax
c0105904:	3c 30                	cmp    $0x30,%al
c0105906:	75 0c                	jne    c0105914 <strtol+0x9e>
        s ++, base = 8;
c0105908:	ff 45 08             	incl   0x8(%ebp)
c010590b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105912:	eb 0d                	jmp    c0105921 <strtol+0xab>
    }
    else if (base == 0) {
c0105914:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105918:	75 07                	jne    c0105921 <strtol+0xab>
        base = 10;
c010591a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105921:	8b 45 08             	mov    0x8(%ebp),%eax
c0105924:	0f b6 00             	movzbl (%eax),%eax
c0105927:	3c 2f                	cmp    $0x2f,%al
c0105929:	7e 1b                	jle    c0105946 <strtol+0xd0>
c010592b:	8b 45 08             	mov    0x8(%ebp),%eax
c010592e:	0f b6 00             	movzbl (%eax),%eax
c0105931:	3c 39                	cmp    $0x39,%al
c0105933:	7f 11                	jg     c0105946 <strtol+0xd0>
            dig = *s - '0';
c0105935:	8b 45 08             	mov    0x8(%ebp),%eax
c0105938:	0f b6 00             	movzbl (%eax),%eax
c010593b:	0f be c0             	movsbl %al,%eax
c010593e:	83 e8 30             	sub    $0x30,%eax
c0105941:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105944:	eb 48                	jmp    c010598e <strtol+0x118>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105946:	8b 45 08             	mov    0x8(%ebp),%eax
c0105949:	0f b6 00             	movzbl (%eax),%eax
c010594c:	3c 60                	cmp    $0x60,%al
c010594e:	7e 1b                	jle    c010596b <strtol+0xf5>
c0105950:	8b 45 08             	mov    0x8(%ebp),%eax
c0105953:	0f b6 00             	movzbl (%eax),%eax
c0105956:	3c 7a                	cmp    $0x7a,%al
c0105958:	7f 11                	jg     c010596b <strtol+0xf5>
            dig = *s - 'a' + 10;
c010595a:	8b 45 08             	mov    0x8(%ebp),%eax
c010595d:	0f b6 00             	movzbl (%eax),%eax
c0105960:	0f be c0             	movsbl %al,%eax
c0105963:	83 e8 57             	sub    $0x57,%eax
c0105966:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105969:	eb 23                	jmp    c010598e <strtol+0x118>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010596b:	8b 45 08             	mov    0x8(%ebp),%eax
c010596e:	0f b6 00             	movzbl (%eax),%eax
c0105971:	3c 40                	cmp    $0x40,%al
c0105973:	7e 3b                	jle    c01059b0 <strtol+0x13a>
c0105975:	8b 45 08             	mov    0x8(%ebp),%eax
c0105978:	0f b6 00             	movzbl (%eax),%eax
c010597b:	3c 5a                	cmp    $0x5a,%al
c010597d:	7f 31                	jg     c01059b0 <strtol+0x13a>
            dig = *s - 'A' + 10;
c010597f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105982:	0f b6 00             	movzbl (%eax),%eax
c0105985:	0f be c0             	movsbl %al,%eax
c0105988:	83 e8 37             	sub    $0x37,%eax
c010598b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010598e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105991:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105994:	7d 19                	jge    c01059af <strtol+0x139>
            break;
        }
        s ++, val = (val * base) + dig;
c0105996:	ff 45 08             	incl   0x8(%ebp)
c0105999:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010599c:	0f af 45 10          	imul   0x10(%ebp),%eax
c01059a0:	89 c2                	mov    %eax,%edx
c01059a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059a5:	01 d0                	add    %edx,%eax
c01059a7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c01059aa:	e9 72 ff ff ff       	jmp    c0105921 <strtol+0xab>
            break;
c01059af:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c01059b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01059b4:	74 08                	je     c01059be <strtol+0x148>
        *endptr = (char *) s;
c01059b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059b9:	8b 55 08             	mov    0x8(%ebp),%edx
c01059bc:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01059be:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01059c2:	74 07                	je     c01059cb <strtol+0x155>
c01059c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01059c7:	f7 d8                	neg    %eax
c01059c9:	eb 03                	jmp    c01059ce <strtol+0x158>
c01059cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01059ce:	c9                   	leave  
c01059cf:	c3                   	ret    

c01059d0 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01059d0:	f3 0f 1e fb          	endbr32 
c01059d4:	55                   	push   %ebp
c01059d5:	89 e5                	mov    %esp,%ebp
c01059d7:	57                   	push   %edi
c01059d8:	83 ec 24             	sub    $0x24,%esp
c01059db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059de:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c01059e1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c01059e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01059e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01059eb:	88 55 f7             	mov    %dl,-0x9(%ebp)
c01059ee:	8b 45 10             	mov    0x10(%ebp),%eax
c01059f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c01059f4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c01059f7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01059fb:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01059fe:	89 d7                	mov    %edx,%edi
c0105a00:	f3 aa                	rep stos %al,%es:(%edi)
c0105a02:	89 fa                	mov    %edi,%edx
c0105a04:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105a07:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105a0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105a0d:	83 c4 24             	add    $0x24,%esp
c0105a10:	5f                   	pop    %edi
c0105a11:	5d                   	pop    %ebp
c0105a12:	c3                   	ret    

c0105a13 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105a13:	f3 0f 1e fb          	endbr32 
c0105a17:	55                   	push   %ebp
c0105a18:	89 e5                	mov    %esp,%ebp
c0105a1a:	57                   	push   %edi
c0105a1b:	56                   	push   %esi
c0105a1c:	53                   	push   %ebx
c0105a1d:	83 ec 30             	sub    $0x30,%esp
c0105a20:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a23:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105a26:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a29:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a2c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a2f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a35:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105a38:	73 42                	jae    c0105a7c <memmove+0x69>
c0105a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105a40:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a43:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105a46:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a49:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105a4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105a4f:	c1 e8 02             	shr    $0x2,%eax
c0105a52:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105a54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105a57:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105a5a:	89 d7                	mov    %edx,%edi
c0105a5c:	89 c6                	mov    %eax,%esi
c0105a5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105a60:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105a63:	83 e1 03             	and    $0x3,%ecx
c0105a66:	74 02                	je     c0105a6a <memmove+0x57>
c0105a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105a6a:	89 f0                	mov    %esi,%eax
c0105a6c:	89 fa                	mov    %edi,%edx
c0105a6e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105a71:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105a74:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0105a77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0105a7a:	eb 36                	jmp    c0105ab2 <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105a7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a7f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105a82:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a85:	01 c2                	add    %eax,%edx
c0105a87:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a8a:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a90:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c0105a93:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a96:	89 c1                	mov    %eax,%ecx
c0105a98:	89 d8                	mov    %ebx,%eax
c0105a9a:	89 d6                	mov    %edx,%esi
c0105a9c:	89 c7                	mov    %eax,%edi
c0105a9e:	fd                   	std    
c0105a9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105aa1:	fc                   	cld    
c0105aa2:	89 f8                	mov    %edi,%eax
c0105aa4:	89 f2                	mov    %esi,%edx
c0105aa6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105aa9:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105aac:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c0105aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105ab2:	83 c4 30             	add    $0x30,%esp
c0105ab5:	5b                   	pop    %ebx
c0105ab6:	5e                   	pop    %esi
c0105ab7:	5f                   	pop    %edi
c0105ab8:	5d                   	pop    %ebp
c0105ab9:	c3                   	ret    

c0105aba <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105aba:	f3 0f 1e fb          	endbr32 
c0105abe:	55                   	push   %ebp
c0105abf:	89 e5                	mov    %esp,%ebp
c0105ac1:	57                   	push   %edi
c0105ac2:	56                   	push   %esi
c0105ac3:	83 ec 20             	sub    $0x20,%esp
c0105ac6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ac9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105acc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105acf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105ad2:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ad5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105ad8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105adb:	c1 e8 02             	shr    $0x2,%eax
c0105ade:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0105ae0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ae6:	89 d7                	mov    %edx,%edi
c0105ae8:	89 c6                	mov    %eax,%esi
c0105aea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105aec:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105aef:	83 e1 03             	and    $0x3,%ecx
c0105af2:	74 02                	je     c0105af6 <memcpy+0x3c>
c0105af4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105af6:	89 f0                	mov    %esi,%eax
c0105af8:	89 fa                	mov    %edi,%edx
c0105afa:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105afd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105b00:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c0105b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105b06:	83 c4 20             	add    $0x20,%esp
c0105b09:	5e                   	pop    %esi
c0105b0a:	5f                   	pop    %edi
c0105b0b:	5d                   	pop    %ebp
c0105b0c:	c3                   	ret    

c0105b0d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105b0d:	f3 0f 1e fb          	endbr32 
c0105b11:	55                   	push   %ebp
c0105b12:	89 e5                	mov    %esp,%ebp
c0105b14:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105b17:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b1a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b20:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105b23:	eb 2e                	jmp    c0105b53 <memcmp+0x46>
        if (*s1 != *s2) {
c0105b25:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b28:	0f b6 10             	movzbl (%eax),%edx
c0105b2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105b2e:	0f b6 00             	movzbl (%eax),%eax
c0105b31:	38 c2                	cmp    %al,%dl
c0105b33:	74 18                	je     c0105b4d <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105b35:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105b38:	0f b6 00             	movzbl (%eax),%eax
c0105b3b:	0f b6 d0             	movzbl %al,%edx
c0105b3e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105b41:	0f b6 00             	movzbl (%eax),%eax
c0105b44:	0f b6 c0             	movzbl %al,%eax
c0105b47:	29 c2                	sub    %eax,%edx
c0105b49:	89 d0                	mov    %edx,%eax
c0105b4b:	eb 18                	jmp    c0105b65 <memcmp+0x58>
        }
        s1 ++, s2 ++;
c0105b4d:	ff 45 fc             	incl   -0x4(%ebp)
c0105b50:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c0105b53:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b56:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105b59:	89 55 10             	mov    %edx,0x10(%ebp)
c0105b5c:	85 c0                	test   %eax,%eax
c0105b5e:	75 c5                	jne    c0105b25 <memcmp+0x18>
    }
    return 0;
c0105b60:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105b65:	c9                   	leave  
c0105b66:	c3                   	ret    

c0105b67 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105b67:	f3 0f 1e fb          	endbr32 
c0105b6b:	55                   	push   %ebp
c0105b6c:	89 e5                	mov    %esp,%ebp
c0105b6e:	83 ec 58             	sub    $0x58,%esp
c0105b71:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b74:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105b77:	8b 45 14             	mov    0x14(%ebp),%eax
c0105b7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105b7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105b80:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105b83:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105b86:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105b89:	8b 45 18             	mov    0x18(%ebp),%eax
c0105b8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105b8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105b92:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105b95:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105b98:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105ba1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105ba5:	74 1c                	je     c0105bc3 <printnum+0x5c>
c0105ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105baa:	ba 00 00 00 00       	mov    $0x0,%edx
c0105baf:	f7 75 e4             	divl   -0x1c(%ebp)
c0105bb2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105bb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105bb8:	ba 00 00 00 00       	mov    $0x0,%edx
c0105bbd:	f7 75 e4             	divl   -0x1c(%ebp)
c0105bc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105bc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105bc9:	f7 75 e4             	divl   -0x1c(%ebp)
c0105bcc:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105bcf:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105bd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105bd5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105bd8:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105bdb:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105bde:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105be1:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105be4:	8b 45 18             	mov    0x18(%ebp),%eax
c0105be7:	ba 00 00 00 00       	mov    $0x0,%edx
c0105bec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105bef:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c0105bf2:	19 d1                	sbb    %edx,%ecx
c0105bf4:	72 4c                	jb     c0105c42 <printnum+0xdb>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105bf6:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105bf9:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105bfc:	8b 45 20             	mov    0x20(%ebp),%eax
c0105bff:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105c03:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105c07:	8b 45 18             	mov    0x18(%ebp),%eax
c0105c0a:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105c0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105c11:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105c14:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c18:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c23:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c26:	89 04 24             	mov    %eax,(%esp)
c0105c29:	e8 39 ff ff ff       	call   c0105b67 <printnum>
c0105c2e:	eb 1b                	jmp    c0105c4b <printnum+0xe4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105c30:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c37:	8b 45 20             	mov    0x20(%ebp),%eax
c0105c3a:	89 04 24             	mov    %eax,(%esp)
c0105c3d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c40:	ff d0                	call   *%eax
        while (-- width > 0)
c0105c42:	ff 4d 1c             	decl   0x1c(%ebp)
c0105c45:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105c49:	7f e5                	jg     c0105c30 <printnum+0xc9>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105c4b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105c4e:	05 ac 73 10 c0       	add    $0xc01073ac,%eax
c0105c53:	0f b6 00             	movzbl (%eax),%eax
c0105c56:	0f be c0             	movsbl %al,%eax
c0105c59:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105c5c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105c60:	89 04 24             	mov    %eax,(%esp)
c0105c63:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c66:	ff d0                	call   *%eax
}
c0105c68:	90                   	nop
c0105c69:	c9                   	leave  
c0105c6a:	c3                   	ret    

c0105c6b <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105c6b:	f3 0f 1e fb          	endbr32 
c0105c6f:	55                   	push   %ebp
c0105c70:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105c72:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105c76:	7e 14                	jle    c0105c8c <getuint+0x21>
        return va_arg(*ap, unsigned long long);
c0105c78:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c7b:	8b 00                	mov    (%eax),%eax
c0105c7d:	8d 48 08             	lea    0x8(%eax),%ecx
c0105c80:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c83:	89 0a                	mov    %ecx,(%edx)
c0105c85:	8b 50 04             	mov    0x4(%eax),%edx
c0105c88:	8b 00                	mov    (%eax),%eax
c0105c8a:	eb 30                	jmp    c0105cbc <getuint+0x51>
    }
    else if (lflag) {
c0105c8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105c90:	74 16                	je     c0105ca8 <getuint+0x3d>
        return va_arg(*ap, unsigned long);
c0105c92:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c95:	8b 00                	mov    (%eax),%eax
c0105c97:	8d 48 04             	lea    0x4(%eax),%ecx
c0105c9a:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c9d:	89 0a                	mov    %ecx,(%edx)
c0105c9f:	8b 00                	mov    (%eax),%eax
c0105ca1:	ba 00 00 00 00       	mov    $0x0,%edx
c0105ca6:	eb 14                	jmp    c0105cbc <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105ca8:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cab:	8b 00                	mov    (%eax),%eax
c0105cad:	8d 48 04             	lea    0x4(%eax),%ecx
c0105cb0:	8b 55 08             	mov    0x8(%ebp),%edx
c0105cb3:	89 0a                	mov    %ecx,(%edx)
c0105cb5:	8b 00                	mov    (%eax),%eax
c0105cb7:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105cbc:	5d                   	pop    %ebp
c0105cbd:	c3                   	ret    

c0105cbe <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105cbe:	f3 0f 1e fb          	endbr32 
c0105cc2:	55                   	push   %ebp
c0105cc3:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105cc5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105cc9:	7e 14                	jle    c0105cdf <getint+0x21>
        return va_arg(*ap, long long);
c0105ccb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cce:	8b 00                	mov    (%eax),%eax
c0105cd0:	8d 48 08             	lea    0x8(%eax),%ecx
c0105cd3:	8b 55 08             	mov    0x8(%ebp),%edx
c0105cd6:	89 0a                	mov    %ecx,(%edx)
c0105cd8:	8b 50 04             	mov    0x4(%eax),%edx
c0105cdb:	8b 00                	mov    (%eax),%eax
c0105cdd:	eb 28                	jmp    c0105d07 <getint+0x49>
    }
    else if (lflag) {
c0105cdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105ce3:	74 12                	je     c0105cf7 <getint+0x39>
        return va_arg(*ap, long);
c0105ce5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ce8:	8b 00                	mov    (%eax),%eax
c0105cea:	8d 48 04             	lea    0x4(%eax),%ecx
c0105ced:	8b 55 08             	mov    0x8(%ebp),%edx
c0105cf0:	89 0a                	mov    %ecx,(%edx)
c0105cf2:	8b 00                	mov    (%eax),%eax
c0105cf4:	99                   	cltd   
c0105cf5:	eb 10                	jmp    c0105d07 <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
c0105cf7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cfa:	8b 00                	mov    (%eax),%eax
c0105cfc:	8d 48 04             	lea    0x4(%eax),%ecx
c0105cff:	8b 55 08             	mov    0x8(%ebp),%edx
c0105d02:	89 0a                	mov    %ecx,(%edx)
c0105d04:	8b 00                	mov    (%eax),%eax
c0105d06:	99                   	cltd   
    }
}
c0105d07:	5d                   	pop    %ebp
c0105d08:	c3                   	ret    

c0105d09 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105d09:	f3 0f 1e fb          	endbr32 
c0105d0d:	55                   	push   %ebp
c0105d0e:	89 e5                	mov    %esp,%ebp
c0105d10:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105d13:	8d 45 14             	lea    0x14(%ebp),%eax
c0105d16:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105d20:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d23:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d31:	89 04 24             	mov    %eax,(%esp)
c0105d34:	e8 03 00 00 00       	call   c0105d3c <vprintfmt>
    va_end(ap);
}
c0105d39:	90                   	nop
c0105d3a:	c9                   	leave  
c0105d3b:	c3                   	ret    

c0105d3c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105d3c:	f3 0f 1e fb          	endbr32 
c0105d40:	55                   	push   %ebp
c0105d41:	89 e5                	mov    %esp,%ebp
c0105d43:	56                   	push   %esi
c0105d44:	53                   	push   %ebx
c0105d45:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105d48:	eb 17                	jmp    c0105d61 <vprintfmt+0x25>
            if (ch == '\0') {
c0105d4a:	85 db                	test   %ebx,%ebx
c0105d4c:	0f 84 c0 03 00 00    	je     c0106112 <vprintfmt+0x3d6>
                return;
            }
            putch(ch, putdat);
c0105d52:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d55:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d59:	89 1c 24             	mov    %ebx,(%esp)
c0105d5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5f:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105d61:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d64:	8d 50 01             	lea    0x1(%eax),%edx
c0105d67:	89 55 10             	mov    %edx,0x10(%ebp)
c0105d6a:	0f b6 00             	movzbl (%eax),%eax
c0105d6d:	0f b6 d8             	movzbl %al,%ebx
c0105d70:	83 fb 25             	cmp    $0x25,%ebx
c0105d73:	75 d5                	jne    c0105d4a <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
c0105d75:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0105d79:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0105d80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d83:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0105d86:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0105d8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105d90:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0105d93:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d96:	8d 50 01             	lea    0x1(%eax),%edx
c0105d99:	89 55 10             	mov    %edx,0x10(%ebp)
c0105d9c:	0f b6 00             	movzbl (%eax),%eax
c0105d9f:	0f b6 d8             	movzbl %al,%ebx
c0105da2:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105da5:	83 f8 55             	cmp    $0x55,%eax
c0105da8:	0f 87 38 03 00 00    	ja     c01060e6 <vprintfmt+0x3aa>
c0105dae:	8b 04 85 d0 73 10 c0 	mov    -0x3fef8c30(,%eax,4),%eax
c0105db5:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105db8:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105dbc:	eb d5                	jmp    c0105d93 <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105dbe:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0105dc2:	eb cf                	jmp    c0105d93 <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0105dc4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105dcb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105dce:	89 d0                	mov    %edx,%eax
c0105dd0:	c1 e0 02             	shl    $0x2,%eax
c0105dd3:	01 d0                	add    %edx,%eax
c0105dd5:	01 c0                	add    %eax,%eax
c0105dd7:	01 d8                	add    %ebx,%eax
c0105dd9:	83 e8 30             	sub    $0x30,%eax
c0105ddc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0105ddf:	8b 45 10             	mov    0x10(%ebp),%eax
c0105de2:	0f b6 00             	movzbl (%eax),%eax
c0105de5:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105de8:	83 fb 2f             	cmp    $0x2f,%ebx
c0105deb:	7e 38                	jle    c0105e25 <vprintfmt+0xe9>
c0105ded:	83 fb 39             	cmp    $0x39,%ebx
c0105df0:	7f 33                	jg     c0105e25 <vprintfmt+0xe9>
            for (precision = 0; ; ++ fmt) {
c0105df2:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0105df5:	eb d4                	jmp    c0105dcb <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105df7:	8b 45 14             	mov    0x14(%ebp),%eax
c0105dfa:	8d 50 04             	lea    0x4(%eax),%edx
c0105dfd:	89 55 14             	mov    %edx,0x14(%ebp)
c0105e00:	8b 00                	mov    (%eax),%eax
c0105e02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105e05:	eb 1f                	jmp    c0105e26 <vprintfmt+0xea>

        case '.':
            if (width < 0)
c0105e07:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105e0b:	79 86                	jns    c0105d93 <vprintfmt+0x57>
                width = 0;
c0105e0d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0105e14:	e9 7a ff ff ff       	jmp    c0105d93 <vprintfmt+0x57>

        case '#':
            altflag = 1;
c0105e19:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0105e20:	e9 6e ff ff ff       	jmp    c0105d93 <vprintfmt+0x57>
            goto process_precision;
c0105e25:	90                   	nop

        process_precision:
            if (width < 0)
c0105e26:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105e2a:	0f 89 63 ff ff ff    	jns    c0105d93 <vprintfmt+0x57>
                width = precision, precision = -1;
c0105e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e33:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105e36:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105e3d:	e9 51 ff ff ff       	jmp    c0105d93 <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0105e42:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0105e45:	e9 49 ff ff ff       	jmp    c0105d93 <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0105e4a:	8b 45 14             	mov    0x14(%ebp),%eax
c0105e4d:	8d 50 04             	lea    0x4(%eax),%edx
c0105e50:	89 55 14             	mov    %edx,0x14(%ebp)
c0105e53:	8b 00                	mov    (%eax),%eax
c0105e55:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105e58:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105e5c:	89 04 24             	mov    %eax,(%esp)
c0105e5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e62:	ff d0                	call   *%eax
            break;
c0105e64:	e9 a4 02 00 00       	jmp    c010610d <vprintfmt+0x3d1>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0105e69:	8b 45 14             	mov    0x14(%ebp),%eax
c0105e6c:	8d 50 04             	lea    0x4(%eax),%edx
c0105e6f:	89 55 14             	mov    %edx,0x14(%ebp)
c0105e72:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0105e74:	85 db                	test   %ebx,%ebx
c0105e76:	79 02                	jns    c0105e7a <vprintfmt+0x13e>
                err = -err;
c0105e78:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0105e7a:	83 fb 06             	cmp    $0x6,%ebx
c0105e7d:	7f 0b                	jg     c0105e8a <vprintfmt+0x14e>
c0105e7f:	8b 34 9d 90 73 10 c0 	mov    -0x3fef8c70(,%ebx,4),%esi
c0105e86:	85 f6                	test   %esi,%esi
c0105e88:	75 23                	jne    c0105ead <vprintfmt+0x171>
                printfmt(putch, putdat, "error %d", err);
c0105e8a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105e8e:	c7 44 24 08 bd 73 10 	movl   $0xc01073bd,0x8(%esp)
c0105e95:	c0 
c0105e96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ea0:	89 04 24             	mov    %eax,(%esp)
c0105ea3:	e8 61 fe ff ff       	call   c0105d09 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105ea8:	e9 60 02 00 00       	jmp    c010610d <vprintfmt+0x3d1>
                printfmt(putch, putdat, "%s", p);
c0105ead:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105eb1:	c7 44 24 08 c6 73 10 	movl   $0xc01073c6,0x8(%esp)
c0105eb8:	c0 
c0105eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ebc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ec0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ec3:	89 04 24             	mov    %eax,(%esp)
c0105ec6:	e8 3e fe ff ff       	call   c0105d09 <printfmt>
            break;
c0105ecb:	e9 3d 02 00 00       	jmp    c010610d <vprintfmt+0x3d1>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105ed0:	8b 45 14             	mov    0x14(%ebp),%eax
c0105ed3:	8d 50 04             	lea    0x4(%eax),%edx
c0105ed6:	89 55 14             	mov    %edx,0x14(%ebp)
c0105ed9:	8b 30                	mov    (%eax),%esi
c0105edb:	85 f6                	test   %esi,%esi
c0105edd:	75 05                	jne    c0105ee4 <vprintfmt+0x1a8>
                p = "(null)";
c0105edf:	be c9 73 10 c0       	mov    $0xc01073c9,%esi
            }
            if (width > 0 && padc != '-') {
c0105ee4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105ee8:	7e 76                	jle    c0105f60 <vprintfmt+0x224>
c0105eea:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105eee:	74 70                	je     c0105f60 <vprintfmt+0x224>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105ef0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ef7:	89 34 24             	mov    %esi,(%esp)
c0105efa:	e8 ba f7 ff ff       	call   c01056b9 <strnlen>
c0105eff:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105f02:	29 c2                	sub    %eax,%edx
c0105f04:	89 d0                	mov    %edx,%eax
c0105f06:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105f09:	eb 16                	jmp    c0105f21 <vprintfmt+0x1e5>
                    putch(padc, putdat);
c0105f0b:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105f0f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105f12:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f16:	89 04 24             	mov    %eax,(%esp)
c0105f19:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f1c:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105f1e:	ff 4d e8             	decl   -0x18(%ebp)
c0105f21:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105f25:	7f e4                	jg     c0105f0b <vprintfmt+0x1cf>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105f27:	eb 37                	jmp    c0105f60 <vprintfmt+0x224>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105f29:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105f2d:	74 1f                	je     c0105f4e <vprintfmt+0x212>
c0105f2f:	83 fb 1f             	cmp    $0x1f,%ebx
c0105f32:	7e 05                	jle    c0105f39 <vprintfmt+0x1fd>
c0105f34:	83 fb 7e             	cmp    $0x7e,%ebx
c0105f37:	7e 15                	jle    c0105f4e <vprintfmt+0x212>
                    putch('?', putdat);
c0105f39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f40:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105f47:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f4a:	ff d0                	call   *%eax
c0105f4c:	eb 0f                	jmp    c0105f5d <vprintfmt+0x221>
                }
                else {
                    putch(ch, putdat);
c0105f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f51:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f55:	89 1c 24             	mov    %ebx,(%esp)
c0105f58:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f5b:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105f5d:	ff 4d e8             	decl   -0x18(%ebp)
c0105f60:	89 f0                	mov    %esi,%eax
c0105f62:	8d 70 01             	lea    0x1(%eax),%esi
c0105f65:	0f b6 00             	movzbl (%eax),%eax
c0105f68:	0f be d8             	movsbl %al,%ebx
c0105f6b:	85 db                	test   %ebx,%ebx
c0105f6d:	74 27                	je     c0105f96 <vprintfmt+0x25a>
c0105f6f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105f73:	78 b4                	js     c0105f29 <vprintfmt+0x1ed>
c0105f75:	ff 4d e4             	decl   -0x1c(%ebp)
c0105f78:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105f7c:	79 ab                	jns    c0105f29 <vprintfmt+0x1ed>
                }
            }
            for (; width > 0; width --) {
c0105f7e:	eb 16                	jmp    c0105f96 <vprintfmt+0x25a>
                putch(' ', putdat);
c0105f80:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105f87:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105f8e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f91:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105f93:	ff 4d e8             	decl   -0x18(%ebp)
c0105f96:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105f9a:	7f e4                	jg     c0105f80 <vprintfmt+0x244>
            }
            break;
c0105f9c:	e9 6c 01 00 00       	jmp    c010610d <vprintfmt+0x3d1>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fa8:	8d 45 14             	lea    0x14(%ebp),%eax
c0105fab:	89 04 24             	mov    %eax,(%esp)
c0105fae:	e8 0b fd ff ff       	call   c0105cbe <getint>
c0105fb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105fb6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fbf:	85 d2                	test   %edx,%edx
c0105fc1:	79 26                	jns    c0105fe9 <vprintfmt+0x2ad>
                putch('-', putdat);
c0105fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fca:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105fd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fd4:	ff d0                	call   *%eax
                num = -(long long)num;
c0105fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105fd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105fdc:	f7 d8                	neg    %eax
c0105fde:	83 d2 00             	adc    $0x0,%edx
c0105fe1:	f7 da                	neg    %edx
c0105fe3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105fe6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105fe9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105ff0:	e9 a8 00 00 00       	jmp    c010609d <vprintfmt+0x361>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ffc:	8d 45 14             	lea    0x14(%ebp),%eax
c0105fff:	89 04 24             	mov    %eax,(%esp)
c0106002:	e8 64 fc ff ff       	call   c0105c6b <getuint>
c0106007:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010600a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010600d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106014:	e9 84 00 00 00       	jmp    c010609d <vprintfmt+0x361>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0106019:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010601c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106020:	8d 45 14             	lea    0x14(%ebp),%eax
c0106023:	89 04 24             	mov    %eax,(%esp)
c0106026:	e8 40 fc ff ff       	call   c0105c6b <getuint>
c010602b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010602e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0106031:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0106038:	eb 63                	jmp    c010609d <vprintfmt+0x361>

        // pointer
        case 'p':
            putch('0', putdat);
c010603a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010603d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106041:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0106048:	8b 45 08             	mov    0x8(%ebp),%eax
c010604b:	ff d0                	call   *%eax
            putch('x', putdat);
c010604d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106050:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106054:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c010605b:	8b 45 08             	mov    0x8(%ebp),%eax
c010605e:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0106060:	8b 45 14             	mov    0x14(%ebp),%eax
c0106063:	8d 50 04             	lea    0x4(%eax),%edx
c0106066:	89 55 14             	mov    %edx,0x14(%ebp)
c0106069:	8b 00                	mov    (%eax),%eax
c010606b:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010606e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0106075:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c010607c:	eb 1f                	jmp    c010609d <vprintfmt+0x361>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010607e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106081:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106085:	8d 45 14             	lea    0x14(%ebp),%eax
c0106088:	89 04 24             	mov    %eax,(%esp)
c010608b:	e8 db fb ff ff       	call   c0105c6b <getuint>
c0106090:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106093:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0106096:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010609d:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c01060a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060a4:	89 54 24 18          	mov    %edx,0x18(%esp)
c01060a8:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01060ab:	89 54 24 14          	mov    %edx,0x14(%esp)
c01060af:	89 44 24 10          	mov    %eax,0x10(%esp)
c01060b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01060b9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01060bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01060c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01060cb:	89 04 24             	mov    %eax,(%esp)
c01060ce:	e8 94 fa ff ff       	call   c0105b67 <printnum>
            break;
c01060d3:	eb 38                	jmp    c010610d <vprintfmt+0x3d1>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c01060d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060d8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060dc:	89 1c 24             	mov    %ebx,(%esp)
c01060df:	8b 45 08             	mov    0x8(%ebp),%eax
c01060e2:	ff d0                	call   *%eax
            break;
c01060e4:	eb 27                	jmp    c010610d <vprintfmt+0x3d1>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c01060e6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01060ed:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c01060f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01060f7:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c01060f9:	ff 4d 10             	decl   0x10(%ebp)
c01060fc:	eb 03                	jmp    c0106101 <vprintfmt+0x3c5>
c01060fe:	ff 4d 10             	decl   0x10(%ebp)
c0106101:	8b 45 10             	mov    0x10(%ebp),%eax
c0106104:	48                   	dec    %eax
c0106105:	0f b6 00             	movzbl (%eax),%eax
c0106108:	3c 25                	cmp    $0x25,%al
c010610a:	75 f2                	jne    c01060fe <vprintfmt+0x3c2>
                /* do nothing */;
            break;
c010610c:	90                   	nop
    while (1) {
c010610d:	e9 36 fc ff ff       	jmp    c0105d48 <vprintfmt+0xc>
                return;
c0106112:	90                   	nop
        }
    }
}
c0106113:	83 c4 40             	add    $0x40,%esp
c0106116:	5b                   	pop    %ebx
c0106117:	5e                   	pop    %esi
c0106118:	5d                   	pop    %ebp
c0106119:	c3                   	ret    

c010611a <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c010611a:	f3 0f 1e fb          	endbr32 
c010611e:	55                   	push   %ebp
c010611f:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106121:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106124:	8b 40 08             	mov    0x8(%eax),%eax
c0106127:	8d 50 01             	lea    0x1(%eax),%edx
c010612a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010612d:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106130:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106133:	8b 10                	mov    (%eax),%edx
c0106135:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106138:	8b 40 04             	mov    0x4(%eax),%eax
c010613b:	39 c2                	cmp    %eax,%edx
c010613d:	73 12                	jae    c0106151 <sprintputch+0x37>
        *b->buf ++ = ch;
c010613f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106142:	8b 00                	mov    (%eax),%eax
c0106144:	8d 48 01             	lea    0x1(%eax),%ecx
c0106147:	8b 55 0c             	mov    0xc(%ebp),%edx
c010614a:	89 0a                	mov    %ecx,(%edx)
c010614c:	8b 55 08             	mov    0x8(%ebp),%edx
c010614f:	88 10                	mov    %dl,(%eax)
    }
}
c0106151:	90                   	nop
c0106152:	5d                   	pop    %ebp
c0106153:	c3                   	ret    

c0106154 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106154:	f3 0f 1e fb          	endbr32 
c0106158:	55                   	push   %ebp
c0106159:	89 e5                	mov    %esp,%ebp
c010615b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010615e:	8d 45 14             	lea    0x14(%ebp),%eax
c0106161:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106164:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106167:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010616b:	8b 45 10             	mov    0x10(%ebp),%eax
c010616e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106172:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106175:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106179:	8b 45 08             	mov    0x8(%ebp),%eax
c010617c:	89 04 24             	mov    %eax,(%esp)
c010617f:	e8 08 00 00 00       	call   c010618c <vsnprintf>
c0106184:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106187:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010618a:	c9                   	leave  
c010618b:	c3                   	ret    

c010618c <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c010618c:	f3 0f 1e fb          	endbr32 
c0106190:	55                   	push   %ebp
c0106191:	89 e5                	mov    %esp,%ebp
c0106193:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106196:	8b 45 08             	mov    0x8(%ebp),%eax
c0106199:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010619c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010619f:	8d 50 ff             	lea    -0x1(%eax),%edx
c01061a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01061a5:	01 d0                	add    %edx,%eax
c01061a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01061aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c01061b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01061b5:	74 0a                	je     c01061c1 <vsnprintf+0x35>
c01061b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01061ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061bd:	39 c2                	cmp    %eax,%edx
c01061bf:	76 07                	jbe    c01061c8 <vsnprintf+0x3c>
        return -E_INVAL;
c01061c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01061c6:	eb 2a                	jmp    c01061f2 <vsnprintf+0x66>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01061c8:	8b 45 14             	mov    0x14(%ebp),%eax
c01061cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01061cf:	8b 45 10             	mov    0x10(%ebp),%eax
c01061d2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01061d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01061d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061dd:	c7 04 24 1a 61 10 c0 	movl   $0xc010611a,(%esp)
c01061e4:	e8 53 fb ff ff       	call   c0105d3c <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01061e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061ec:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01061ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01061f2:	c9                   	leave  
c01061f3:	c3                   	ret    
