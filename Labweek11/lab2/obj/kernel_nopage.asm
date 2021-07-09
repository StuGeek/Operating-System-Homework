
bin/kernel_nopage:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 a0 11 40       	mov    $0x4011a000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 a0 11 00       	mov    %eax,0x11a000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 90 11 00       	mov    $0x119000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	f3 0f 1e fb          	endbr32 
  10003a:	55                   	push   %ebp
  10003b:	89 e5                	mov    %esp,%ebp
  10003d:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100040:	b8 28 cf 11 00       	mov    $0x11cf28,%eax
  100045:	2d 36 9a 11 00       	sub    $0x119a36,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 9a 11 00 	movl   $0x119a36,(%esp)
  10005d:	e8 6e 59 00 00       	call   1059d0 <memset>

    cons_init();                // init the console
  100062:	e8 5e 16 00 00       	call   1016c5 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 00 62 10 00 	movl   $0x106200,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 1c 62 10 00 	movl   $0x10621c,(%esp)
  10007c:	e8 48 02 00 00       	call   1002c9 <cprintf>

    print_kerninfo();
  100081:	e8 06 09 00 00       	call   10098c <print_kerninfo>

    grade_backtrace();
  100086:	e8 9a 00 00 00       	call   100125 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 e5 32 00 00       	call   103375 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 ab 17 00 00       	call   101840 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 2b 19 00 00       	call   1019c5 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 6d 0d 00 00       	call   100e0c <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 e8 18 00 00       	call   10198c <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  1000a4:	e8 86 01 00 00       	call   10022f <lab1_switch_test>

    /* do nothing */
    while (1);
  1000a9:	eb fe                	jmp    1000a9 <kern_init+0x73>

001000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000ab:	f3 0f 1e fb          	endbr32 
  1000af:	55                   	push   %ebp
  1000b0:	89 e5                	mov    %esp,%ebp
  1000b2:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000b5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000bc:	00 
  1000bd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000c4:	00 
  1000c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000cc:	e8 25 0d 00 00       	call   100df6 <mon_backtrace>
}
  1000d1:	90                   	nop
  1000d2:	c9                   	leave  
  1000d3:	c3                   	ret    

001000d4 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000d4:	f3 0f 1e fb          	endbr32 
  1000d8:	55                   	push   %ebp
  1000d9:	89 e5                	mov    %esp,%ebp
  1000db:	53                   	push   %ebx
  1000dc:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000df:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000e5:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1000eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000f3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000f7:	89 04 24             	mov    %eax,(%esp)
  1000fa:	e8 ac ff ff ff       	call   1000ab <grade_backtrace2>
}
  1000ff:	90                   	nop
  100100:	83 c4 14             	add    $0x14,%esp
  100103:	5b                   	pop    %ebx
  100104:	5d                   	pop    %ebp
  100105:	c3                   	ret    

00100106 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  100106:	f3 0f 1e fb          	endbr32 
  10010a:	55                   	push   %ebp
  10010b:	89 e5                	mov    %esp,%ebp
  10010d:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100110:	8b 45 10             	mov    0x10(%ebp),%eax
  100113:	89 44 24 04          	mov    %eax,0x4(%esp)
  100117:	8b 45 08             	mov    0x8(%ebp),%eax
  10011a:	89 04 24             	mov    %eax,(%esp)
  10011d:	e8 b2 ff ff ff       	call   1000d4 <grade_backtrace1>
}
  100122:	90                   	nop
  100123:	c9                   	leave  
  100124:	c3                   	ret    

00100125 <grade_backtrace>:

void
grade_backtrace(void) {
  100125:	f3 0f 1e fb          	endbr32 
  100129:	55                   	push   %ebp
  10012a:	89 e5                	mov    %esp,%ebp
  10012c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10012f:	b8 36 00 10 00       	mov    $0x100036,%eax
  100134:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  10013b:	ff 
  10013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100140:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100147:	e8 ba ff ff ff       	call   100106 <grade_backtrace0>
}
  10014c:	90                   	nop
  10014d:	c9                   	leave  
  10014e:	c3                   	ret    

0010014f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10014f:	f3 0f 1e fb          	endbr32 
  100153:	55                   	push   %ebp
  100154:	89 e5                	mov    %esp,%ebp
  100156:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100159:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  10015c:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10015f:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100162:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100165:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100169:	83 e0 03             	and    $0x3,%eax
  10016c:	89 c2                	mov    %eax,%edx
  10016e:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100173:	89 54 24 08          	mov    %edx,0x8(%esp)
  100177:	89 44 24 04          	mov    %eax,0x4(%esp)
  10017b:	c7 04 24 21 62 10 00 	movl   $0x106221,(%esp)
  100182:	e8 42 01 00 00       	call   1002c9 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100187:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10018b:	89 c2                	mov    %eax,%edx
  10018d:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100192:	89 54 24 08          	mov    %edx,0x8(%esp)
  100196:	89 44 24 04          	mov    %eax,0x4(%esp)
  10019a:	c7 04 24 2f 62 10 00 	movl   $0x10622f,(%esp)
  1001a1:	e8 23 01 00 00       	call   1002c9 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  1001a6:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  1001aa:	89 c2                	mov    %eax,%edx
  1001ac:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001b1:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001b9:	c7 04 24 3d 62 10 00 	movl   $0x10623d,(%esp)
  1001c0:	e8 04 01 00 00       	call   1002c9 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001c5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001c9:	89 c2                	mov    %eax,%edx
  1001cb:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001d0:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001d8:	c7 04 24 4b 62 10 00 	movl   $0x10624b,(%esp)
  1001df:	e8 e5 00 00 00       	call   1002c9 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001e4:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001e8:	89 c2                	mov    %eax,%edx
  1001ea:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001ef:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001f7:	c7 04 24 59 62 10 00 	movl   $0x106259,(%esp)
  1001fe:	e8 c6 00 00 00       	call   1002c9 <cprintf>
    round ++;
  100203:	a1 00 c0 11 00       	mov    0x11c000,%eax
  100208:	40                   	inc    %eax
  100209:	a3 00 c0 11 00       	mov    %eax,0x11c000
}
  10020e:	90                   	nop
  10020f:	c9                   	leave  
  100210:	c3                   	ret    

00100211 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  100211:	f3 0f 1e fb          	endbr32 
  100215:	55                   	push   %ebp
  100216:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
    asm volatile (
  100218:	16                   	push   %ss
  100219:	54                   	push   %esp
  10021a:	cd 78                	int    $0x78
  10021c:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  10021e:	90                   	nop
  10021f:	5d                   	pop    %ebp
  100220:	c3                   	ret    

00100221 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100221:	f3 0f 1e fb          	endbr32 
  100225:	55                   	push   %ebp
  100226:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
  100228:	cd 79                	int    $0x79
  10022a:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  10022c:	90                   	nop
  10022d:	5d                   	pop    %ebp
  10022e:	c3                   	ret    

0010022f <lab1_switch_test>:

static void
lab1_switch_test(void) {
  10022f:	f3 0f 1e fb          	endbr32 
  100233:	55                   	push   %ebp
  100234:	89 e5                	mov    %esp,%ebp
  100236:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100239:	e8 11 ff ff ff       	call   10014f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10023e:	c7 04 24 68 62 10 00 	movl   $0x106268,(%esp)
  100245:	e8 7f 00 00 00       	call   1002c9 <cprintf>
    lab1_switch_to_user();
  10024a:	e8 c2 ff ff ff       	call   100211 <lab1_switch_to_user>
    lab1_print_cur_status();
  10024f:	e8 fb fe ff ff       	call   10014f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100254:	c7 04 24 88 62 10 00 	movl   $0x106288,(%esp)
  10025b:	e8 69 00 00 00       	call   1002c9 <cprintf>
    lab1_switch_to_kernel();
  100260:	e8 bc ff ff ff       	call   100221 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100265:	e8 e5 fe ff ff       	call   10014f <lab1_print_cur_status>
}
  10026a:	90                   	nop
  10026b:	c9                   	leave  
  10026c:	c3                   	ret    

0010026d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  10026d:	f3 0f 1e fb          	endbr32 
  100271:	55                   	push   %ebp
  100272:	89 e5                	mov    %esp,%ebp
  100274:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100277:	8b 45 08             	mov    0x8(%ebp),%eax
  10027a:	89 04 24             	mov    %eax,(%esp)
  10027d:	e8 74 14 00 00       	call   1016f6 <cons_putc>
    (*cnt) ++;
  100282:	8b 45 0c             	mov    0xc(%ebp),%eax
  100285:	8b 00                	mov    (%eax),%eax
  100287:	8d 50 01             	lea    0x1(%eax),%edx
  10028a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10028d:	89 10                	mov    %edx,(%eax)
}
  10028f:	90                   	nop
  100290:	c9                   	leave  
  100291:	c3                   	ret    

00100292 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100292:	f3 0f 1e fb          	endbr32 
  100296:	55                   	push   %ebp
  100297:	89 e5                	mov    %esp,%ebp
  100299:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10029c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  1002a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1002a6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1002ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  1002b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  1002b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002b8:	c7 04 24 6d 02 10 00 	movl   $0x10026d,(%esp)
  1002bf:	e8 78 5a 00 00       	call   105d3c <vprintfmt>
    return cnt;
  1002c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002c7:	c9                   	leave  
  1002c8:	c3                   	ret    

001002c9 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  1002c9:	f3 0f 1e fb          	endbr32 
  1002cd:	55                   	push   %ebp
  1002ce:	89 e5                	mov    %esp,%ebp
  1002d0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1002d3:	8d 45 0c             	lea    0xc(%ebp),%eax
  1002d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  1002d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1002e3:	89 04 24             	mov    %eax,(%esp)
  1002e6:	e8 a7 ff ff ff       	call   100292 <vcprintf>
  1002eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002f1:	c9                   	leave  
  1002f2:	c3                   	ret    

001002f3 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002f3:	f3 0f 1e fb          	endbr32 
  1002f7:	55                   	push   %ebp
  1002f8:	89 e5                	mov    %esp,%ebp
  1002fa:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  100300:	89 04 24             	mov    %eax,(%esp)
  100303:	e8 ee 13 00 00       	call   1016f6 <cons_putc>
}
  100308:	90                   	nop
  100309:	c9                   	leave  
  10030a:	c3                   	ret    

0010030b <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  10030b:	f3 0f 1e fb          	endbr32 
  10030f:	55                   	push   %ebp
  100310:	89 e5                	mov    %esp,%ebp
  100312:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100315:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  10031c:	eb 13                	jmp    100331 <cputs+0x26>
        cputch(c, &cnt);
  10031e:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  100322:	8d 55 f0             	lea    -0x10(%ebp),%edx
  100325:	89 54 24 04          	mov    %edx,0x4(%esp)
  100329:	89 04 24             	mov    %eax,(%esp)
  10032c:	e8 3c ff ff ff       	call   10026d <cputch>
    while ((c = *str ++) != '\0') {
  100331:	8b 45 08             	mov    0x8(%ebp),%eax
  100334:	8d 50 01             	lea    0x1(%eax),%edx
  100337:	89 55 08             	mov    %edx,0x8(%ebp)
  10033a:	0f b6 00             	movzbl (%eax),%eax
  10033d:	88 45 f7             	mov    %al,-0x9(%ebp)
  100340:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100344:	75 d8                	jne    10031e <cputs+0x13>
    }
    cputch('\n', &cnt);
  100346:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100349:	89 44 24 04          	mov    %eax,0x4(%esp)
  10034d:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100354:	e8 14 ff ff ff       	call   10026d <cputch>
    return cnt;
  100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  10035c:	c9                   	leave  
  10035d:	c3                   	ret    

0010035e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  10035e:	f3 0f 1e fb          	endbr32 
  100362:	55                   	push   %ebp
  100363:	89 e5                	mov    %esp,%ebp
  100365:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100368:	90                   	nop
  100369:	e8 c9 13 00 00       	call   101737 <cons_getc>
  10036e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100371:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100375:	74 f2                	je     100369 <getchar+0xb>
        /* do nothing */;
    return c;
  100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10037a:	c9                   	leave  
  10037b:	c3                   	ret    

0010037c <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10037c:	f3 0f 1e fb          	endbr32 
  100380:	55                   	push   %ebp
  100381:	89 e5                	mov    %esp,%ebp
  100383:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100386:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10038a:	74 13                	je     10039f <readline+0x23>
        cprintf("%s", prompt);
  10038c:	8b 45 08             	mov    0x8(%ebp),%eax
  10038f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100393:	c7 04 24 a7 62 10 00 	movl   $0x1062a7,(%esp)
  10039a:	e8 2a ff ff ff       	call   1002c9 <cprintf>
    }
    int i = 0, c;
  10039f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  1003a6:	e8 b3 ff ff ff       	call   10035e <getchar>
  1003ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  1003ae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1003b2:	79 07                	jns    1003bb <readline+0x3f>
            return NULL;
  1003b4:	b8 00 00 00 00       	mov    $0x0,%eax
  1003b9:	eb 78                	jmp    100433 <readline+0xb7>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  1003bb:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  1003bf:	7e 28                	jle    1003e9 <readline+0x6d>
  1003c1:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  1003c8:	7f 1f                	jg     1003e9 <readline+0x6d>
            cputchar(c);
  1003ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003cd:	89 04 24             	mov    %eax,(%esp)
  1003d0:	e8 1e ff ff ff       	call   1002f3 <cputchar>
            buf[i ++] = c;
  1003d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003d8:	8d 50 01             	lea    0x1(%eax),%edx
  1003db:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1003de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1003e1:	88 90 20 c0 11 00    	mov    %dl,0x11c020(%eax)
  1003e7:	eb 45                	jmp    10042e <readline+0xb2>
        }
        else if (c == '\b' && i > 0) {
  1003e9:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003ed:	75 16                	jne    100405 <readline+0x89>
  1003ef:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003f3:	7e 10                	jle    100405 <readline+0x89>
            cputchar(c);
  1003f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003f8:	89 04 24             	mov    %eax,(%esp)
  1003fb:	e8 f3 fe ff ff       	call   1002f3 <cputchar>
            i --;
  100400:	ff 4d f4             	decl   -0xc(%ebp)
  100403:	eb 29                	jmp    10042e <readline+0xb2>
        }
        else if (c == '\n' || c == '\r') {
  100405:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100409:	74 06                	je     100411 <readline+0x95>
  10040b:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  10040f:	75 95                	jne    1003a6 <readline+0x2a>
            cputchar(c);
  100411:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100414:	89 04 24             	mov    %eax,(%esp)
  100417:	e8 d7 fe ff ff       	call   1002f3 <cputchar>
            buf[i] = '\0';
  10041c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10041f:	05 20 c0 11 00       	add    $0x11c020,%eax
  100424:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  100427:	b8 20 c0 11 00       	mov    $0x11c020,%eax
  10042c:	eb 05                	jmp    100433 <readline+0xb7>
        c = getchar();
  10042e:	e9 73 ff ff ff       	jmp    1003a6 <readline+0x2a>
        }
    }
}
  100433:	c9                   	leave  
  100434:	c3                   	ret    

00100435 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100435:	f3 0f 1e fb          	endbr32 
  100439:	55                   	push   %ebp
  10043a:	89 e5                	mov    %esp,%ebp
  10043c:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  10043f:	a1 20 c4 11 00       	mov    0x11c420,%eax
  100444:	85 c0                	test   %eax,%eax
  100446:	75 5b                	jne    1004a3 <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
  100448:	c7 05 20 c4 11 00 01 	movl   $0x1,0x11c420
  10044f:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100452:	8d 45 14             	lea    0x14(%ebp),%eax
  100455:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100458:	8b 45 0c             	mov    0xc(%ebp),%eax
  10045b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10045f:	8b 45 08             	mov    0x8(%ebp),%eax
  100462:	89 44 24 04          	mov    %eax,0x4(%esp)
  100466:	c7 04 24 aa 62 10 00 	movl   $0x1062aa,(%esp)
  10046d:	e8 57 fe ff ff       	call   1002c9 <cprintf>
    vcprintf(fmt, ap);
  100472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100475:	89 44 24 04          	mov    %eax,0x4(%esp)
  100479:	8b 45 10             	mov    0x10(%ebp),%eax
  10047c:	89 04 24             	mov    %eax,(%esp)
  10047f:	e8 0e fe ff ff       	call   100292 <vcprintf>
    cprintf("\n");
  100484:	c7 04 24 c6 62 10 00 	movl   $0x1062c6,(%esp)
  10048b:	e8 39 fe ff ff       	call   1002c9 <cprintf>
    
    cprintf("stack trackback:\n");
  100490:	c7 04 24 c8 62 10 00 	movl   $0x1062c8,(%esp)
  100497:	e8 2d fe ff ff       	call   1002c9 <cprintf>
    print_stackframe();
  10049c:	e8 3d 06 00 00       	call   100ade <print_stackframe>
  1004a1:	eb 01                	jmp    1004a4 <__panic+0x6f>
        goto panic_dead;
  1004a3:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  1004a4:	e8 ef 14 00 00       	call   101998 <intr_disable>
    while (1) {
        kmonitor(NULL);
  1004a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1004b0:	e8 68 08 00 00       	call   100d1d <kmonitor>
  1004b5:	eb f2                	jmp    1004a9 <__panic+0x74>

001004b7 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  1004b7:	f3 0f 1e fb          	endbr32 
  1004bb:	55                   	push   %ebp
  1004bc:	89 e5                	mov    %esp,%ebp
  1004be:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  1004c1:	8d 45 14             	lea    0x14(%ebp),%eax
  1004c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  1004c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  1004ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1004d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004d5:	c7 04 24 da 62 10 00 	movl   $0x1062da,(%esp)
  1004dc:	e8 e8 fd ff ff       	call   1002c9 <cprintf>
    vcprintf(fmt, ap);
  1004e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1004e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004e8:	8b 45 10             	mov    0x10(%ebp),%eax
  1004eb:	89 04 24             	mov    %eax,(%esp)
  1004ee:	e8 9f fd ff ff       	call   100292 <vcprintf>
    cprintf("\n");
  1004f3:	c7 04 24 c6 62 10 00 	movl   $0x1062c6,(%esp)
  1004fa:	e8 ca fd ff ff       	call   1002c9 <cprintf>
    va_end(ap);
}
  1004ff:	90                   	nop
  100500:	c9                   	leave  
  100501:	c3                   	ret    

00100502 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100502:	f3 0f 1e fb          	endbr32 
  100506:	55                   	push   %ebp
  100507:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100509:	a1 20 c4 11 00       	mov    0x11c420,%eax
}
  10050e:	5d                   	pop    %ebp
  10050f:	c3                   	ret    

00100510 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100510:	f3 0f 1e fb          	endbr32 
  100514:	55                   	push   %ebp
  100515:	89 e5                	mov    %esp,%ebp
  100517:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  10051a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051d:	8b 00                	mov    (%eax),%eax
  10051f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100522:	8b 45 10             	mov    0x10(%ebp),%eax
  100525:	8b 00                	mov    (%eax),%eax
  100527:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10052a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  100531:	e9 ca 00 00 00       	jmp    100600 <stab_binsearch+0xf0>
        int true_m = (l + r) / 2, m = true_m;
  100536:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100539:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10053c:	01 d0                	add    %edx,%eax
  10053e:	89 c2                	mov    %eax,%edx
  100540:	c1 ea 1f             	shr    $0x1f,%edx
  100543:	01 d0                	add    %edx,%eax
  100545:	d1 f8                	sar    %eax
  100547:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10054a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10054d:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100550:	eb 03                	jmp    100555 <stab_binsearch+0x45>
            m --;
  100552:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100555:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100558:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10055b:	7c 1f                	jl     10057c <stab_binsearch+0x6c>
  10055d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100560:	89 d0                	mov    %edx,%eax
  100562:	01 c0                	add    %eax,%eax
  100564:	01 d0                	add    %edx,%eax
  100566:	c1 e0 02             	shl    $0x2,%eax
  100569:	89 c2                	mov    %eax,%edx
  10056b:	8b 45 08             	mov    0x8(%ebp),%eax
  10056e:	01 d0                	add    %edx,%eax
  100570:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100574:	0f b6 c0             	movzbl %al,%eax
  100577:	39 45 14             	cmp    %eax,0x14(%ebp)
  10057a:	75 d6                	jne    100552 <stab_binsearch+0x42>
        }
        if (m < l) {    // no match in [l, m]
  10057c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10057f:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100582:	7d 09                	jge    10058d <stab_binsearch+0x7d>
            l = true_m + 1;
  100584:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100587:	40                   	inc    %eax
  100588:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10058b:	eb 73                	jmp    100600 <stab_binsearch+0xf0>
        }

        // actual binary search
        any_matches = 1;
  10058d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100594:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100597:	89 d0                	mov    %edx,%eax
  100599:	01 c0                	add    %eax,%eax
  10059b:	01 d0                	add    %edx,%eax
  10059d:	c1 e0 02             	shl    $0x2,%eax
  1005a0:	89 c2                	mov    %eax,%edx
  1005a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1005a5:	01 d0                	add    %edx,%eax
  1005a7:	8b 40 08             	mov    0x8(%eax),%eax
  1005aa:	39 45 18             	cmp    %eax,0x18(%ebp)
  1005ad:	76 11                	jbe    1005c0 <stab_binsearch+0xb0>
            *region_left = m;
  1005af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005b5:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  1005b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1005ba:	40                   	inc    %eax
  1005bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1005be:	eb 40                	jmp    100600 <stab_binsearch+0xf0>
        } else if (stabs[m].n_value > addr) {
  1005c0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005c3:	89 d0                	mov    %edx,%eax
  1005c5:	01 c0                	add    %eax,%eax
  1005c7:	01 d0                	add    %edx,%eax
  1005c9:	c1 e0 02             	shl    $0x2,%eax
  1005cc:	89 c2                	mov    %eax,%edx
  1005ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1005d1:	01 d0                	add    %edx,%eax
  1005d3:	8b 40 08             	mov    0x8(%eax),%eax
  1005d6:	39 45 18             	cmp    %eax,0x18(%ebp)
  1005d9:	73 14                	jae    1005ef <stab_binsearch+0xdf>
            *region_right = m - 1;
  1005db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005de:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005e1:	8b 45 10             	mov    0x10(%ebp),%eax
  1005e4:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1005e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005e9:	48                   	dec    %eax
  1005ea:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1005ed:	eb 11                	jmp    100600 <stab_binsearch+0xf0>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1005ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005f5:	89 10                	mov    %edx,(%eax)
            l = m;
  1005f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005fd:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  100600:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100603:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100606:	0f 8e 2a ff ff ff    	jle    100536 <stab_binsearch+0x26>
        }
    }

    if (!any_matches) {
  10060c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100610:	75 0f                	jne    100621 <stab_binsearch+0x111>
        *region_right = *region_left - 1;
  100612:	8b 45 0c             	mov    0xc(%ebp),%eax
  100615:	8b 00                	mov    (%eax),%eax
  100617:	8d 50 ff             	lea    -0x1(%eax),%edx
  10061a:	8b 45 10             	mov    0x10(%ebp),%eax
  10061d:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10061f:	eb 3e                	jmp    10065f <stab_binsearch+0x14f>
        l = *region_right;
  100621:	8b 45 10             	mov    0x10(%ebp),%eax
  100624:	8b 00                	mov    (%eax),%eax
  100626:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100629:	eb 03                	jmp    10062e <stab_binsearch+0x11e>
  10062b:	ff 4d fc             	decl   -0x4(%ebp)
  10062e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100631:	8b 00                	mov    (%eax),%eax
  100633:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  100636:	7e 1f                	jle    100657 <stab_binsearch+0x147>
  100638:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10063b:	89 d0                	mov    %edx,%eax
  10063d:	01 c0                	add    %eax,%eax
  10063f:	01 d0                	add    %edx,%eax
  100641:	c1 e0 02             	shl    $0x2,%eax
  100644:	89 c2                	mov    %eax,%edx
  100646:	8b 45 08             	mov    0x8(%ebp),%eax
  100649:	01 d0                	add    %edx,%eax
  10064b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10064f:	0f b6 c0             	movzbl %al,%eax
  100652:	39 45 14             	cmp    %eax,0x14(%ebp)
  100655:	75 d4                	jne    10062b <stab_binsearch+0x11b>
        *region_left = l;
  100657:	8b 45 0c             	mov    0xc(%ebp),%eax
  10065a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10065d:	89 10                	mov    %edx,(%eax)
}
  10065f:	90                   	nop
  100660:	c9                   	leave  
  100661:	c3                   	ret    

00100662 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100662:	f3 0f 1e fb          	endbr32 
  100666:	55                   	push   %ebp
  100667:	89 e5                	mov    %esp,%ebp
  100669:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  10066c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10066f:	c7 00 f8 62 10 00    	movl   $0x1062f8,(%eax)
    info->eip_line = 0;
  100675:	8b 45 0c             	mov    0xc(%ebp),%eax
  100678:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10067f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100682:	c7 40 08 f8 62 10 00 	movl   $0x1062f8,0x8(%eax)
    info->eip_fn_namelen = 9;
  100689:	8b 45 0c             	mov    0xc(%ebp),%eax
  10068c:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100693:	8b 45 0c             	mov    0xc(%ebp),%eax
  100696:	8b 55 08             	mov    0x8(%ebp),%edx
  100699:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  10069c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10069f:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  1006a6:	c7 45 f4 28 75 10 00 	movl   $0x107528,-0xc(%ebp)
    stab_end = __STAB_END__;
  1006ad:	c7 45 f0 18 3f 11 00 	movl   $0x113f18,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  1006b4:	c7 45 ec 19 3f 11 00 	movl   $0x113f19,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1006bb:	c7 45 e8 58 6a 11 00 	movl   $0x116a58,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1006c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1006c5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1006c8:	76 0b                	jbe    1006d5 <debuginfo_eip+0x73>
  1006ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1006cd:	48                   	dec    %eax
  1006ce:	0f b6 00             	movzbl (%eax),%eax
  1006d1:	84 c0                	test   %al,%al
  1006d3:	74 0a                	je     1006df <debuginfo_eip+0x7d>
        return -1;
  1006d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006da:	e9 ab 02 00 00       	jmp    10098a <debuginfo_eip+0x328>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1006df:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1006e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1006e9:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1006ec:	c1 f8 02             	sar    $0x2,%eax
  1006ef:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1006f5:	48                   	dec    %eax
  1006f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1006f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1006fc:	89 44 24 10          	mov    %eax,0x10(%esp)
  100700:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  100707:	00 
  100708:	8d 45 e0             	lea    -0x20(%ebp),%eax
  10070b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10070f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  100712:	89 44 24 04          	mov    %eax,0x4(%esp)
  100716:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100719:	89 04 24             	mov    %eax,(%esp)
  10071c:	e8 ef fd ff ff       	call   100510 <stab_binsearch>
    if (lfile == 0)
  100721:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100724:	85 c0                	test   %eax,%eax
  100726:	75 0a                	jne    100732 <debuginfo_eip+0xd0>
        return -1;
  100728:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10072d:	e9 58 02 00 00       	jmp    10098a <debuginfo_eip+0x328>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  100732:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100735:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100738:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10073b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  10073e:	8b 45 08             	mov    0x8(%ebp),%eax
  100741:	89 44 24 10          	mov    %eax,0x10(%esp)
  100745:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  10074c:	00 
  10074d:	8d 45 d8             	lea    -0x28(%ebp),%eax
  100750:	89 44 24 08          	mov    %eax,0x8(%esp)
  100754:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100757:	89 44 24 04          	mov    %eax,0x4(%esp)
  10075b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10075e:	89 04 24             	mov    %eax,(%esp)
  100761:	e8 aa fd ff ff       	call   100510 <stab_binsearch>

    if (lfun <= rfun) {
  100766:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100769:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10076c:	39 c2                	cmp    %eax,%edx
  10076e:	7f 78                	jg     1007e8 <debuginfo_eip+0x186>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100770:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100773:	89 c2                	mov    %eax,%edx
  100775:	89 d0                	mov    %edx,%eax
  100777:	01 c0                	add    %eax,%eax
  100779:	01 d0                	add    %edx,%eax
  10077b:	c1 e0 02             	shl    $0x2,%eax
  10077e:	89 c2                	mov    %eax,%edx
  100780:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100783:	01 d0                	add    %edx,%eax
  100785:	8b 10                	mov    (%eax),%edx
  100787:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10078a:	2b 45 ec             	sub    -0x14(%ebp),%eax
  10078d:	39 c2                	cmp    %eax,%edx
  10078f:	73 22                	jae    1007b3 <debuginfo_eip+0x151>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100791:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100794:	89 c2                	mov    %eax,%edx
  100796:	89 d0                	mov    %edx,%eax
  100798:	01 c0                	add    %eax,%eax
  10079a:	01 d0                	add    %edx,%eax
  10079c:	c1 e0 02             	shl    $0x2,%eax
  10079f:	89 c2                	mov    %eax,%edx
  1007a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007a4:	01 d0                	add    %edx,%eax
  1007a6:	8b 10                	mov    (%eax),%edx
  1007a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1007ab:	01 c2                	add    %eax,%edx
  1007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007b0:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  1007b3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1007b6:	89 c2                	mov    %eax,%edx
  1007b8:	89 d0                	mov    %edx,%eax
  1007ba:	01 c0                	add    %eax,%eax
  1007bc:	01 d0                	add    %edx,%eax
  1007be:	c1 e0 02             	shl    $0x2,%eax
  1007c1:	89 c2                	mov    %eax,%edx
  1007c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c6:	01 d0                	add    %edx,%eax
  1007c8:	8b 50 08             	mov    0x8(%eax),%edx
  1007cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007ce:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1007d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007d4:	8b 40 10             	mov    0x10(%eax),%eax
  1007d7:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1007da:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1007dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1007e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1007e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1007e6:	eb 15                	jmp    1007fd <debuginfo_eip+0x19b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1007e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007eb:	8b 55 08             	mov    0x8(%ebp),%edx
  1007ee:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1007f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1007f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  100800:	8b 40 08             	mov    0x8(%eax),%eax
  100803:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  10080a:	00 
  10080b:	89 04 24             	mov    %eax,(%esp)
  10080e:	e8 31 50 00 00       	call   105844 <strfind>
  100813:	8b 55 0c             	mov    0xc(%ebp),%edx
  100816:	8b 52 08             	mov    0x8(%edx),%edx
  100819:	29 d0                	sub    %edx,%eax
  10081b:	89 c2                	mov    %eax,%edx
  10081d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100820:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  100823:	8b 45 08             	mov    0x8(%ebp),%eax
  100826:	89 44 24 10          	mov    %eax,0x10(%esp)
  10082a:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  100831:	00 
  100832:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100835:	89 44 24 08          	mov    %eax,0x8(%esp)
  100839:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  10083c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100843:	89 04 24             	mov    %eax,(%esp)
  100846:	e8 c5 fc ff ff       	call   100510 <stab_binsearch>
    if (lline <= rline) {
  10084b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10084e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100851:	39 c2                	cmp    %eax,%edx
  100853:	7f 23                	jg     100878 <debuginfo_eip+0x216>
        info->eip_line = stabs[rline].n_desc;
  100855:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100858:	89 c2                	mov    %eax,%edx
  10085a:	89 d0                	mov    %edx,%eax
  10085c:	01 c0                	add    %eax,%eax
  10085e:	01 d0                	add    %edx,%eax
  100860:	c1 e0 02             	shl    $0x2,%eax
  100863:	89 c2                	mov    %eax,%edx
  100865:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100868:	01 d0                	add    %edx,%eax
  10086a:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10086e:	89 c2                	mov    %eax,%edx
  100870:	8b 45 0c             	mov    0xc(%ebp),%eax
  100873:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100876:	eb 11                	jmp    100889 <debuginfo_eip+0x227>
        return -1;
  100878:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10087d:	e9 08 01 00 00       	jmp    10098a <debuginfo_eip+0x328>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100882:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100885:	48                   	dec    %eax
  100886:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100889:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10088c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10088f:	39 c2                	cmp    %eax,%edx
  100891:	7c 56                	jl     1008e9 <debuginfo_eip+0x287>
           && stabs[lline].n_type != N_SOL
  100893:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100896:	89 c2                	mov    %eax,%edx
  100898:	89 d0                	mov    %edx,%eax
  10089a:	01 c0                	add    %eax,%eax
  10089c:	01 d0                	add    %edx,%eax
  10089e:	c1 e0 02             	shl    $0x2,%eax
  1008a1:	89 c2                	mov    %eax,%edx
  1008a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008a6:	01 d0                	add    %edx,%eax
  1008a8:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1008ac:	3c 84                	cmp    $0x84,%al
  1008ae:	74 39                	je     1008e9 <debuginfo_eip+0x287>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  1008b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008b3:	89 c2                	mov    %eax,%edx
  1008b5:	89 d0                	mov    %edx,%eax
  1008b7:	01 c0                	add    %eax,%eax
  1008b9:	01 d0                	add    %edx,%eax
  1008bb:	c1 e0 02             	shl    $0x2,%eax
  1008be:	89 c2                	mov    %eax,%edx
  1008c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008c3:	01 d0                	add    %edx,%eax
  1008c5:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1008c9:	3c 64                	cmp    $0x64,%al
  1008cb:	75 b5                	jne    100882 <debuginfo_eip+0x220>
  1008cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008d0:	89 c2                	mov    %eax,%edx
  1008d2:	89 d0                	mov    %edx,%eax
  1008d4:	01 c0                	add    %eax,%eax
  1008d6:	01 d0                	add    %edx,%eax
  1008d8:	c1 e0 02             	shl    $0x2,%eax
  1008db:	89 c2                	mov    %eax,%edx
  1008dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008e0:	01 d0                	add    %edx,%eax
  1008e2:	8b 40 08             	mov    0x8(%eax),%eax
  1008e5:	85 c0                	test   %eax,%eax
  1008e7:	74 99                	je     100882 <debuginfo_eip+0x220>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1008e9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008ec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1008ef:	39 c2                	cmp    %eax,%edx
  1008f1:	7c 42                	jl     100935 <debuginfo_eip+0x2d3>
  1008f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008f6:	89 c2                	mov    %eax,%edx
  1008f8:	89 d0                	mov    %edx,%eax
  1008fa:	01 c0                	add    %eax,%eax
  1008fc:	01 d0                	add    %edx,%eax
  1008fe:	c1 e0 02             	shl    $0x2,%eax
  100901:	89 c2                	mov    %eax,%edx
  100903:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100906:	01 d0                	add    %edx,%eax
  100908:	8b 10                	mov    (%eax),%edx
  10090a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10090d:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100910:	39 c2                	cmp    %eax,%edx
  100912:	73 21                	jae    100935 <debuginfo_eip+0x2d3>
        info->eip_file = stabstr + stabs[lline].n_strx;
  100914:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100917:	89 c2                	mov    %eax,%edx
  100919:	89 d0                	mov    %edx,%eax
  10091b:	01 c0                	add    %eax,%eax
  10091d:	01 d0                	add    %edx,%eax
  10091f:	c1 e0 02             	shl    $0x2,%eax
  100922:	89 c2                	mov    %eax,%edx
  100924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100927:	01 d0                	add    %edx,%eax
  100929:	8b 10                	mov    (%eax),%edx
  10092b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10092e:	01 c2                	add    %eax,%edx
  100930:	8b 45 0c             	mov    0xc(%ebp),%eax
  100933:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100935:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100938:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10093b:	39 c2                	cmp    %eax,%edx
  10093d:	7d 46                	jge    100985 <debuginfo_eip+0x323>
        for (lline = lfun + 1;
  10093f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100942:	40                   	inc    %eax
  100943:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100946:	eb 16                	jmp    10095e <debuginfo_eip+0x2fc>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100948:	8b 45 0c             	mov    0xc(%ebp),%eax
  10094b:	8b 40 14             	mov    0x14(%eax),%eax
  10094e:	8d 50 01             	lea    0x1(%eax),%edx
  100951:	8b 45 0c             	mov    0xc(%ebp),%eax
  100954:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100957:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10095a:	40                   	inc    %eax
  10095b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10095e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100961:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  100964:	39 c2                	cmp    %eax,%edx
  100966:	7d 1d                	jge    100985 <debuginfo_eip+0x323>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100968:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10096b:	89 c2                	mov    %eax,%edx
  10096d:	89 d0                	mov    %edx,%eax
  10096f:	01 c0                	add    %eax,%eax
  100971:	01 d0                	add    %edx,%eax
  100973:	c1 e0 02             	shl    $0x2,%eax
  100976:	89 c2                	mov    %eax,%edx
  100978:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10097b:	01 d0                	add    %edx,%eax
  10097d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100981:	3c a0                	cmp    $0xa0,%al
  100983:	74 c3                	je     100948 <debuginfo_eip+0x2e6>
        }
    }
    return 0;
  100985:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10098a:	c9                   	leave  
  10098b:	c3                   	ret    

0010098c <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10098c:	f3 0f 1e fb          	endbr32 
  100990:	55                   	push   %ebp
  100991:	89 e5                	mov    %esp,%ebp
  100993:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100996:	c7 04 24 02 63 10 00 	movl   $0x106302,(%esp)
  10099d:	e8 27 f9 ff ff       	call   1002c9 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  1009a2:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  1009a9:	00 
  1009aa:	c7 04 24 1b 63 10 00 	movl   $0x10631b,(%esp)
  1009b1:	e8 13 f9 ff ff       	call   1002c9 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  1009b6:	c7 44 24 04 f4 61 10 	movl   $0x1061f4,0x4(%esp)
  1009bd:	00 
  1009be:	c7 04 24 33 63 10 00 	movl   $0x106333,(%esp)
  1009c5:	e8 ff f8 ff ff       	call   1002c9 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1009ca:	c7 44 24 04 36 9a 11 	movl   $0x119a36,0x4(%esp)
  1009d1:	00 
  1009d2:	c7 04 24 4b 63 10 00 	movl   $0x10634b,(%esp)
  1009d9:	e8 eb f8 ff ff       	call   1002c9 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1009de:	c7 44 24 04 28 cf 11 	movl   $0x11cf28,0x4(%esp)
  1009e5:	00 
  1009e6:	c7 04 24 63 63 10 00 	movl   $0x106363,(%esp)
  1009ed:	e8 d7 f8 ff ff       	call   1002c9 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1009f2:	b8 28 cf 11 00       	mov    $0x11cf28,%eax
  1009f7:	2d 36 00 10 00       	sub    $0x100036,%eax
  1009fc:	05 ff 03 00 00       	add    $0x3ff,%eax
  100a01:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  100a07:	85 c0                	test   %eax,%eax
  100a09:	0f 48 c2             	cmovs  %edx,%eax
  100a0c:	c1 f8 0a             	sar    $0xa,%eax
  100a0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a13:	c7 04 24 7c 63 10 00 	movl   $0x10637c,(%esp)
  100a1a:	e8 aa f8 ff ff       	call   1002c9 <cprintf>
}
  100a1f:	90                   	nop
  100a20:	c9                   	leave  
  100a21:	c3                   	ret    

00100a22 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  100a22:	f3 0f 1e fb          	endbr32 
  100a26:	55                   	push   %ebp
  100a27:	89 e5                	mov    %esp,%ebp
  100a29:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100a2f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a36:	8b 45 08             	mov    0x8(%ebp),%eax
  100a39:	89 04 24             	mov    %eax,(%esp)
  100a3c:	e8 21 fc ff ff       	call   100662 <debuginfo_eip>
  100a41:	85 c0                	test   %eax,%eax
  100a43:	74 15                	je     100a5a <print_debuginfo+0x38>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100a45:	8b 45 08             	mov    0x8(%ebp),%eax
  100a48:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a4c:	c7 04 24 a6 63 10 00 	movl   $0x1063a6,(%esp)
  100a53:	e8 71 f8 ff ff       	call   1002c9 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a58:	eb 6c                	jmp    100ac6 <print_debuginfo+0xa4>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a61:	eb 1b                	jmp    100a7e <print_debuginfo+0x5c>
            fnname[j] = info.eip_fn_name[j];
  100a63:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a69:	01 d0                	add    %edx,%eax
  100a6b:	0f b6 10             	movzbl (%eax),%edx
  100a6e:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a77:	01 c8                	add    %ecx,%eax
  100a79:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a7b:	ff 45 f4             	incl   -0xc(%ebp)
  100a7e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a81:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100a84:	7c dd                	jl     100a63 <print_debuginfo+0x41>
        fnname[j] = '\0';
  100a86:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a8f:	01 d0                	add    %edx,%eax
  100a91:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100a94:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a97:	8b 55 08             	mov    0x8(%ebp),%edx
  100a9a:	89 d1                	mov    %edx,%ecx
  100a9c:	29 c1                	sub    %eax,%ecx
  100a9e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100aa1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100aa4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100aa8:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100aae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100ab2:	89 54 24 08          	mov    %edx,0x8(%esp)
  100ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
  100aba:	c7 04 24 c2 63 10 00 	movl   $0x1063c2,(%esp)
  100ac1:	e8 03 f8 ff ff       	call   1002c9 <cprintf>
}
  100ac6:	90                   	nop
  100ac7:	c9                   	leave  
  100ac8:	c3                   	ret    

00100ac9 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100ac9:	f3 0f 1e fb          	endbr32 
  100acd:	55                   	push   %ebp
  100ace:	89 e5                	mov    %esp,%ebp
  100ad0:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100ad3:	8b 45 04             	mov    0x4(%ebp),%eax
  100ad6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100ad9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100adc:	c9                   	leave  
  100add:	c3                   	ret    

00100ade <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100ade:	f3 0f 1e fb          	endbr32 
  100ae2:	55                   	push   %ebp
  100ae3:	89 e5                	mov    %esp,%ebp
  100ae5:	53                   	push   %ebx
  100ae6:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100ae9:	89 e8                	mov    %ebp,%eax
  100aeb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  100aee:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    /* LAB1 YOUR CODE : STEP 1 */
    /* (1) call read_ebp() to get the value of ebp. the type is (uint32_t);*/
    uint32_t ebp_val = read_ebp();
  100af1:	89 45 f4             	mov    %eax,-0xc(%ebp)
    /* (2) call read_eip() to get the value of eip. the type is (uint32_t);*/
    uint32_t eip_val = read_eip();
  100af4:	e8 d0 ff ff ff       	call   100ac9 <read_eip>
  100af9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    /* (3) from 0 .. STACKFRAME_DEPTH*/
    for (int i = 0; ebp_val != 0 && i < STACKFRAME_DEPTH; ++i) {
  100afc:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100b03:	e9 8a 00 00 00       	jmp    100b92 <print_stackframe+0xb4>
        /* (3.1) printf value of ebp, eip*/
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp_val, eip_val);
  100b08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b0b:	89 44 24 08          	mov    %eax,0x8(%esp)
  100b0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b12:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b16:	c7 04 24 d4 63 10 00 	movl   $0x1063d4,(%esp)
  100b1d:	e8 a7 f7 ff ff       	call   1002c9 <cprintf>
        /* (3.2) (uint32_t)calling arguments [0..4] = the contents in address (uint32_t)ebp +2 [0..4]*/
        uint32_t *call_args = (uint32_t *)ebp_val + 2;
  100b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b25:	83 c0 08             	add    $0x8,%eax
  100b28:	89 45 e8             	mov    %eax,-0x18(%ebp)
        cprintf("0x%08x 0x%08x 0x%08x 0x%08x", call_args[0], call_args[1], call_args[2], call_args[3]);
  100b2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b2e:	83 c0 0c             	add    $0xc,%eax
  100b31:	8b 18                	mov    (%eax),%ebx
  100b33:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b36:	83 c0 08             	add    $0x8,%eax
  100b39:	8b 08                	mov    (%eax),%ecx
  100b3b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b3e:	83 c0 04             	add    $0x4,%eax
  100b41:	8b 10                	mov    (%eax),%edx
  100b43:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b46:	8b 00                	mov    (%eax),%eax
  100b48:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100b4c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100b50:	89 54 24 08          	mov    %edx,0x8(%esp)
  100b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b58:	c7 04 24 f0 63 10 00 	movl   $0x1063f0,(%esp)
  100b5f:	e8 65 f7 ff ff       	call   1002c9 <cprintf>
        /* (3.3) cprintf("\n");*/
        cprintf("\n");
  100b64:	c7 04 24 0c 64 10 00 	movl   $0x10640c,(%esp)
  100b6b:	e8 59 f7 ff ff       	call   1002c9 <cprintf>
        /* (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.*/
        print_debuginfo(eip_val - 1);
  100b70:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b73:	48                   	dec    %eax
  100b74:	89 04 24             	mov    %eax,(%esp)
  100b77:	e8 a6 fe ff ff       	call   100a22 <print_debuginfo>
        /* (3.5) popup a calling stackframe*/
        /* NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]*/
        eip_val = *((uint32_t *)(ebp_val + 4));
  100b7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b7f:	83 c0 04             	add    $0x4,%eax
  100b82:	8b 00                	mov    (%eax),%eax
  100b84:	89 45 f0             	mov    %eax,-0x10(%ebp)
        /* the calling funciton's ebp = ss:[ebp]*/
        ebp_val = *((uint32_t *)ebp_val);
  100b87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b8a:	8b 00                	mov    (%eax),%eax
  100b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (int i = 0; ebp_val != 0 && i < STACKFRAME_DEPTH; ++i) {
  100b8f:	ff 45 ec             	incl   -0x14(%ebp)
  100b92:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b96:	74 0a                	je     100ba2 <print_stackframe+0xc4>
  100b98:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b9c:	0f 8e 66 ff ff ff    	jle    100b08 <print_stackframe+0x2a>
    }
}
  100ba2:	90                   	nop
  100ba3:	83 c4 44             	add    $0x44,%esp
  100ba6:	5b                   	pop    %ebx
  100ba7:	5d                   	pop    %ebp
  100ba8:	c3                   	ret    

00100ba9 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100ba9:	f3 0f 1e fb          	endbr32 
  100bad:	55                   	push   %ebp
  100bae:	89 e5                	mov    %esp,%ebp
  100bb0:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100bb3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100bba:	eb 0c                	jmp    100bc8 <parse+0x1f>
            *buf ++ = '\0';
  100bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  100bbf:	8d 50 01             	lea    0x1(%eax),%edx
  100bc2:	89 55 08             	mov    %edx,0x8(%ebp)
  100bc5:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  100bcb:	0f b6 00             	movzbl (%eax),%eax
  100bce:	84 c0                	test   %al,%al
  100bd0:	74 1d                	je     100bef <parse+0x46>
  100bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  100bd5:	0f b6 00             	movzbl (%eax),%eax
  100bd8:	0f be c0             	movsbl %al,%eax
  100bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bdf:	c7 04 24 90 64 10 00 	movl   $0x106490,(%esp)
  100be6:	e8 23 4c 00 00       	call   10580e <strchr>
  100beb:	85 c0                	test   %eax,%eax
  100bed:	75 cd                	jne    100bbc <parse+0x13>
        }
        if (*buf == '\0') {
  100bef:	8b 45 08             	mov    0x8(%ebp),%eax
  100bf2:	0f b6 00             	movzbl (%eax),%eax
  100bf5:	84 c0                	test   %al,%al
  100bf7:	74 65                	je     100c5e <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100bf9:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100bfd:	75 14                	jne    100c13 <parse+0x6a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100bff:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100c06:	00 
  100c07:	c7 04 24 95 64 10 00 	movl   $0x106495,(%esp)
  100c0e:	e8 b6 f6 ff ff       	call   1002c9 <cprintf>
        }
        argv[argc ++] = buf;
  100c13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c16:	8d 50 01             	lea    0x1(%eax),%edx
  100c19:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100c1c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100c23:	8b 45 0c             	mov    0xc(%ebp),%eax
  100c26:	01 c2                	add    %eax,%edx
  100c28:	8b 45 08             	mov    0x8(%ebp),%eax
  100c2b:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100c2d:	eb 03                	jmp    100c32 <parse+0x89>
            buf ++;
  100c2f:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100c32:	8b 45 08             	mov    0x8(%ebp),%eax
  100c35:	0f b6 00             	movzbl (%eax),%eax
  100c38:	84 c0                	test   %al,%al
  100c3a:	74 8c                	je     100bc8 <parse+0x1f>
  100c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  100c3f:	0f b6 00             	movzbl (%eax),%eax
  100c42:	0f be c0             	movsbl %al,%eax
  100c45:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c49:	c7 04 24 90 64 10 00 	movl   $0x106490,(%esp)
  100c50:	e8 b9 4b 00 00       	call   10580e <strchr>
  100c55:	85 c0                	test   %eax,%eax
  100c57:	74 d6                	je     100c2f <parse+0x86>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100c59:	e9 6a ff ff ff       	jmp    100bc8 <parse+0x1f>
            break;
  100c5e:	90                   	nop
        }
    }
    return argc;
  100c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100c62:	c9                   	leave  
  100c63:	c3                   	ret    

00100c64 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100c64:	f3 0f 1e fb          	endbr32 
  100c68:	55                   	push   %ebp
  100c69:	89 e5                	mov    %esp,%ebp
  100c6b:	53                   	push   %ebx
  100c6c:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c6f:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c72:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c76:	8b 45 08             	mov    0x8(%ebp),%eax
  100c79:	89 04 24             	mov    %eax,(%esp)
  100c7c:	e8 28 ff ff ff       	call   100ba9 <parse>
  100c81:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c84:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c88:	75 0a                	jne    100c94 <runcmd+0x30>
        return 0;
  100c8a:	b8 00 00 00 00       	mov    $0x0,%eax
  100c8f:	e9 83 00 00 00       	jmp    100d17 <runcmd+0xb3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c9b:	eb 5a                	jmp    100cf7 <runcmd+0x93>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c9d:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100ca0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ca3:	89 d0                	mov    %edx,%eax
  100ca5:	01 c0                	add    %eax,%eax
  100ca7:	01 d0                	add    %edx,%eax
  100ca9:	c1 e0 02             	shl    $0x2,%eax
  100cac:	05 00 90 11 00       	add    $0x119000,%eax
  100cb1:	8b 00                	mov    (%eax),%eax
  100cb3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100cb7:	89 04 24             	mov    %eax,(%esp)
  100cba:	e8 ab 4a 00 00       	call   10576a <strcmp>
  100cbf:	85 c0                	test   %eax,%eax
  100cc1:	75 31                	jne    100cf4 <runcmd+0x90>
            return commands[i].func(argc - 1, argv + 1, tf);
  100cc3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100cc6:	89 d0                	mov    %edx,%eax
  100cc8:	01 c0                	add    %eax,%eax
  100cca:	01 d0                	add    %edx,%eax
  100ccc:	c1 e0 02             	shl    $0x2,%eax
  100ccf:	05 08 90 11 00       	add    $0x119008,%eax
  100cd4:	8b 10                	mov    (%eax),%edx
  100cd6:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100cd9:	83 c0 04             	add    $0x4,%eax
  100cdc:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100cdf:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100ce5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ced:	89 1c 24             	mov    %ebx,(%esp)
  100cf0:	ff d2                	call   *%edx
  100cf2:	eb 23                	jmp    100d17 <runcmd+0xb3>
    for (i = 0; i < NCOMMANDS; i ++) {
  100cf4:	ff 45 f4             	incl   -0xc(%ebp)
  100cf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cfa:	83 f8 02             	cmp    $0x2,%eax
  100cfd:	76 9e                	jbe    100c9d <runcmd+0x39>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100cff:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100d02:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d06:	c7 04 24 b3 64 10 00 	movl   $0x1064b3,(%esp)
  100d0d:	e8 b7 f5 ff ff       	call   1002c9 <cprintf>
    return 0;
  100d12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d17:	83 c4 64             	add    $0x64,%esp
  100d1a:	5b                   	pop    %ebx
  100d1b:	5d                   	pop    %ebp
  100d1c:	c3                   	ret    

00100d1d <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100d1d:	f3 0f 1e fb          	endbr32 
  100d21:	55                   	push   %ebp
  100d22:	89 e5                	mov    %esp,%ebp
  100d24:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100d27:	c7 04 24 cc 64 10 00 	movl   $0x1064cc,(%esp)
  100d2e:	e8 96 f5 ff ff       	call   1002c9 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100d33:	c7 04 24 f4 64 10 00 	movl   $0x1064f4,(%esp)
  100d3a:	e8 8a f5 ff ff       	call   1002c9 <cprintf>

    if (tf != NULL) {
  100d3f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100d43:	74 0b                	je     100d50 <kmonitor+0x33>
        print_trapframe(tf);
  100d45:	8b 45 08             	mov    0x8(%ebp),%eax
  100d48:	89 04 24             	mov    %eax,(%esp)
  100d4b:	e8 3f 0e 00 00       	call   101b8f <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100d50:	c7 04 24 19 65 10 00 	movl   $0x106519,(%esp)
  100d57:	e8 20 f6 ff ff       	call   10037c <readline>
  100d5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100d5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100d63:	74 eb                	je     100d50 <kmonitor+0x33>
            if (runcmd(buf, tf) < 0) {
  100d65:	8b 45 08             	mov    0x8(%ebp),%eax
  100d68:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d6f:	89 04 24             	mov    %eax,(%esp)
  100d72:	e8 ed fe ff ff       	call   100c64 <runcmd>
  100d77:	85 c0                	test   %eax,%eax
  100d79:	78 02                	js     100d7d <kmonitor+0x60>
        if ((buf = readline("K> ")) != NULL) {
  100d7b:	eb d3                	jmp    100d50 <kmonitor+0x33>
                break;
  100d7d:	90                   	nop
            }
        }
    }
}
  100d7e:	90                   	nop
  100d7f:	c9                   	leave  
  100d80:	c3                   	ret    

00100d81 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d81:	f3 0f 1e fb          	endbr32 
  100d85:	55                   	push   %ebp
  100d86:	89 e5                	mov    %esp,%ebp
  100d88:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d8b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d92:	eb 3d                	jmp    100dd1 <mon_help+0x50>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d97:	89 d0                	mov    %edx,%eax
  100d99:	01 c0                	add    %eax,%eax
  100d9b:	01 d0                	add    %edx,%eax
  100d9d:	c1 e0 02             	shl    $0x2,%eax
  100da0:	05 04 90 11 00       	add    $0x119004,%eax
  100da5:	8b 08                	mov    (%eax),%ecx
  100da7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100daa:	89 d0                	mov    %edx,%eax
  100dac:	01 c0                	add    %eax,%eax
  100dae:	01 d0                	add    %edx,%eax
  100db0:	c1 e0 02             	shl    $0x2,%eax
  100db3:	05 00 90 11 00       	add    $0x119000,%eax
  100db8:	8b 00                	mov    (%eax),%eax
  100dba:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100dbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  100dc2:	c7 04 24 1d 65 10 00 	movl   $0x10651d,(%esp)
  100dc9:	e8 fb f4 ff ff       	call   1002c9 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100dce:	ff 45 f4             	incl   -0xc(%ebp)
  100dd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100dd4:	83 f8 02             	cmp    $0x2,%eax
  100dd7:	76 bb                	jbe    100d94 <mon_help+0x13>
    }
    return 0;
  100dd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100dde:	c9                   	leave  
  100ddf:	c3                   	ret    

00100de0 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100de0:	f3 0f 1e fb          	endbr32 
  100de4:	55                   	push   %ebp
  100de5:	89 e5                	mov    %esp,%ebp
  100de7:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100dea:	e8 9d fb ff ff       	call   10098c <print_kerninfo>
    return 0;
  100def:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100df4:	c9                   	leave  
  100df5:	c3                   	ret    

00100df6 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100df6:	f3 0f 1e fb          	endbr32 
  100dfa:	55                   	push   %ebp
  100dfb:	89 e5                	mov    %esp,%ebp
  100dfd:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100e00:	e8 d9 fc ff ff       	call   100ade <print_stackframe>
    return 0;
  100e05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e0a:	c9                   	leave  
  100e0b:	c3                   	ret    

00100e0c <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100e0c:	f3 0f 1e fb          	endbr32 
  100e10:	55                   	push   %ebp
  100e11:	89 e5                	mov    %esp,%ebp
  100e13:	83 ec 28             	sub    $0x28,%esp
  100e16:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100e1c:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e20:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100e24:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100e28:	ee                   	out    %al,(%dx)
}
  100e29:	90                   	nop
  100e2a:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100e30:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e34:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e38:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e3c:	ee                   	out    %al,(%dx)
}
  100e3d:	90                   	nop
  100e3e:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100e44:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100e48:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100e4c:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100e50:	ee                   	out    %al,(%dx)
}
  100e51:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100e52:	c7 05 0c cf 11 00 00 	movl   $0x0,0x11cf0c
  100e59:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100e5c:	c7 04 24 26 65 10 00 	movl   $0x106526,(%esp)
  100e63:	e8 61 f4 ff ff       	call   1002c9 <cprintf>
    pic_enable(IRQ_TIMER);
  100e68:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e6f:	e8 95 09 00 00       	call   101809 <pic_enable>
}
  100e74:	90                   	nop
  100e75:	c9                   	leave  
  100e76:	c3                   	ret    

00100e77 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e77:	55                   	push   %ebp
  100e78:	89 e5                	mov    %esp,%ebp
  100e7a:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e7d:	9c                   	pushf  
  100e7e:	58                   	pop    %eax
  100e7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e85:	25 00 02 00 00       	and    $0x200,%eax
  100e8a:	85 c0                	test   %eax,%eax
  100e8c:	74 0c                	je     100e9a <__intr_save+0x23>
        intr_disable();
  100e8e:	e8 05 0b 00 00       	call   101998 <intr_disable>
        return 1;
  100e93:	b8 01 00 00 00       	mov    $0x1,%eax
  100e98:	eb 05                	jmp    100e9f <__intr_save+0x28>
    }
    return 0;
  100e9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e9f:	c9                   	leave  
  100ea0:	c3                   	ret    

00100ea1 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100ea1:	55                   	push   %ebp
  100ea2:	89 e5                	mov    %esp,%ebp
  100ea4:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100ea7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100eab:	74 05                	je     100eb2 <__intr_restore+0x11>
        intr_enable();
  100ead:	e8 da 0a 00 00       	call   10198c <intr_enable>
    }
}
  100eb2:	90                   	nop
  100eb3:	c9                   	leave  
  100eb4:	c3                   	ret    

00100eb5 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100eb5:	f3 0f 1e fb          	endbr32 
  100eb9:	55                   	push   %ebp
  100eba:	89 e5                	mov    %esp,%ebp
  100ebc:	83 ec 10             	sub    $0x10,%esp
  100ebf:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ec5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ec9:	89 c2                	mov    %eax,%edx
  100ecb:	ec                   	in     (%dx),%al
  100ecc:	88 45 f1             	mov    %al,-0xf(%ebp)
  100ecf:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100ed5:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100ed9:	89 c2                	mov    %eax,%edx
  100edb:	ec                   	in     (%dx),%al
  100edc:	88 45 f5             	mov    %al,-0xb(%ebp)
  100edf:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100ee5:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100ee9:	89 c2                	mov    %eax,%edx
  100eeb:	ec                   	in     (%dx),%al
  100eec:	88 45 f9             	mov    %al,-0x7(%ebp)
  100eef:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100ef5:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100ef9:	89 c2                	mov    %eax,%edx
  100efb:	ec                   	in     (%dx),%al
  100efc:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100eff:	90                   	nop
  100f00:	c9                   	leave  
  100f01:	c3                   	ret    

00100f02 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100f02:	f3 0f 1e fb          	endbr32 
  100f06:	55                   	push   %ebp
  100f07:	89 e5                	mov    %esp,%ebp
  100f09:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100f0c:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100f13:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f16:	0f b7 00             	movzwl (%eax),%eax
  100f19:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100f1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f20:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100f25:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f28:	0f b7 00             	movzwl (%eax),%eax
  100f2b:	0f b7 c0             	movzwl %ax,%eax
  100f2e:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100f33:	74 12                	je     100f47 <cga_init+0x45>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100f35:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100f3c:	66 c7 05 46 c4 11 00 	movw   $0x3b4,0x11c446
  100f43:	b4 03 
  100f45:	eb 13                	jmp    100f5a <cga_init+0x58>
    } else {
        *cp = was;
  100f47:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f4a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100f4e:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100f51:	66 c7 05 46 c4 11 00 	movw   $0x3d4,0x11c446
  100f58:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100f5a:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f61:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100f65:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f69:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f6d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f71:	ee                   	out    %al,(%dx)
}
  100f72:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
  100f73:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f7a:	40                   	inc    %eax
  100f7b:	0f b7 c0             	movzwl %ax,%eax
  100f7e:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f82:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f86:	89 c2                	mov    %eax,%edx
  100f88:	ec                   	in     (%dx),%al
  100f89:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f8c:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f90:	0f b6 c0             	movzbl %al,%eax
  100f93:	c1 e0 08             	shl    $0x8,%eax
  100f96:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f99:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100fa0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100fa4:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fa8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100fac:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fb0:	ee                   	out    %al,(%dx)
}
  100fb1:	90                   	nop
    pos |= inb(addr_6845 + 1);
  100fb2:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100fb9:	40                   	inc    %eax
  100fba:	0f b7 c0             	movzwl %ax,%eax
  100fbd:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100fc1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100fc5:	89 c2                	mov    %eax,%edx
  100fc7:	ec                   	in     (%dx),%al
  100fc8:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100fcb:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100fcf:	0f b6 c0             	movzbl %al,%eax
  100fd2:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100fd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100fd8:	a3 40 c4 11 00       	mov    %eax,0x11c440
    crt_pos = pos;
  100fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100fe0:	0f b7 c0             	movzwl %ax,%eax
  100fe3:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
}
  100fe9:	90                   	nop
  100fea:	c9                   	leave  
  100feb:	c3                   	ret    

00100fec <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100fec:	f3 0f 1e fb          	endbr32 
  100ff0:	55                   	push   %ebp
  100ff1:	89 e5                	mov    %esp,%ebp
  100ff3:	83 ec 48             	sub    $0x48,%esp
  100ff6:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100ffc:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101000:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101004:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101008:	ee                   	out    %al,(%dx)
}
  101009:	90                   	nop
  10100a:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  101010:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101014:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101018:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  10101c:	ee                   	out    %al,(%dx)
}
  10101d:	90                   	nop
  10101e:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  101024:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101028:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10102c:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  101030:	ee                   	out    %al,(%dx)
}
  101031:	90                   	nop
  101032:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  101038:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10103c:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101040:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101044:	ee                   	out    %al,(%dx)
}
  101045:	90                   	nop
  101046:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  10104c:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101050:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101054:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101058:	ee                   	out    %al,(%dx)
}
  101059:	90                   	nop
  10105a:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  101060:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101064:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101068:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  10106c:	ee                   	out    %al,(%dx)
}
  10106d:	90                   	nop
  10106e:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  101074:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101078:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10107c:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101080:	ee                   	out    %al,(%dx)
}
  101081:	90                   	nop
  101082:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101088:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  10108c:	89 c2                	mov    %eax,%edx
  10108e:	ec                   	in     (%dx),%al
  10108f:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  101092:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101096:	3c ff                	cmp    $0xff,%al
  101098:	0f 95 c0             	setne  %al
  10109b:	0f b6 c0             	movzbl %al,%eax
  10109e:	a3 48 c4 11 00       	mov    %eax,0x11c448
  1010a3:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1010a9:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1010ad:	89 c2                	mov    %eax,%edx
  1010af:	ec                   	in     (%dx),%al
  1010b0:	88 45 f1             	mov    %al,-0xf(%ebp)
  1010b3:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1010b9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1010bd:	89 c2                	mov    %eax,%edx
  1010bf:	ec                   	in     (%dx),%al
  1010c0:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  1010c3:	a1 48 c4 11 00       	mov    0x11c448,%eax
  1010c8:	85 c0                	test   %eax,%eax
  1010ca:	74 0c                	je     1010d8 <serial_init+0xec>
        pic_enable(IRQ_COM1);
  1010cc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1010d3:	e8 31 07 00 00       	call   101809 <pic_enable>
    }
}
  1010d8:	90                   	nop
  1010d9:	c9                   	leave  
  1010da:	c3                   	ret    

001010db <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  1010db:	f3 0f 1e fb          	endbr32 
  1010df:	55                   	push   %ebp
  1010e0:	89 e5                	mov    %esp,%ebp
  1010e2:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  1010e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1010ec:	eb 08                	jmp    1010f6 <lpt_putc_sub+0x1b>
        delay();
  1010ee:	e8 c2 fd ff ff       	call   100eb5 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  1010f3:	ff 45 fc             	incl   -0x4(%ebp)
  1010f6:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  1010fc:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101100:	89 c2                	mov    %eax,%edx
  101102:	ec                   	in     (%dx),%al
  101103:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101106:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10110a:	84 c0                	test   %al,%al
  10110c:	78 09                	js     101117 <lpt_putc_sub+0x3c>
  10110e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101115:	7e d7                	jle    1010ee <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
  101117:	8b 45 08             	mov    0x8(%ebp),%eax
  10111a:	0f b6 c0             	movzbl %al,%eax
  10111d:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  101123:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101126:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10112a:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10112e:	ee                   	out    %al,(%dx)
}
  10112f:	90                   	nop
  101130:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  101136:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10113a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10113e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101142:	ee                   	out    %al,(%dx)
}
  101143:	90                   	nop
  101144:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  10114a:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10114e:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101152:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101156:	ee                   	out    %al,(%dx)
}
  101157:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  101158:	90                   	nop
  101159:	c9                   	leave  
  10115a:	c3                   	ret    

0010115b <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  10115b:	f3 0f 1e fb          	endbr32 
  10115f:	55                   	push   %ebp
  101160:	89 e5                	mov    %esp,%ebp
  101162:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101165:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101169:	74 0d                	je     101178 <lpt_putc+0x1d>
        lpt_putc_sub(c);
  10116b:	8b 45 08             	mov    0x8(%ebp),%eax
  10116e:	89 04 24             	mov    %eax,(%esp)
  101171:	e8 65 ff ff ff       	call   1010db <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  101176:	eb 24                	jmp    10119c <lpt_putc+0x41>
        lpt_putc_sub('\b');
  101178:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10117f:	e8 57 ff ff ff       	call   1010db <lpt_putc_sub>
        lpt_putc_sub(' ');
  101184:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10118b:	e8 4b ff ff ff       	call   1010db <lpt_putc_sub>
        lpt_putc_sub('\b');
  101190:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101197:	e8 3f ff ff ff       	call   1010db <lpt_putc_sub>
}
  10119c:	90                   	nop
  10119d:	c9                   	leave  
  10119e:	c3                   	ret    

0010119f <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  10119f:	f3 0f 1e fb          	endbr32 
  1011a3:	55                   	push   %ebp
  1011a4:	89 e5                	mov    %esp,%ebp
  1011a6:	53                   	push   %ebx
  1011a7:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1011aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1011ad:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1011b2:	85 c0                	test   %eax,%eax
  1011b4:	75 07                	jne    1011bd <cga_putc+0x1e>
        c |= 0x0700;
  1011b6:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1011bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1011c0:	0f b6 c0             	movzbl %al,%eax
  1011c3:	83 f8 0d             	cmp    $0xd,%eax
  1011c6:	74 72                	je     10123a <cga_putc+0x9b>
  1011c8:	83 f8 0d             	cmp    $0xd,%eax
  1011cb:	0f 8f a3 00 00 00    	jg     101274 <cga_putc+0xd5>
  1011d1:	83 f8 08             	cmp    $0x8,%eax
  1011d4:	74 0a                	je     1011e0 <cga_putc+0x41>
  1011d6:	83 f8 0a             	cmp    $0xa,%eax
  1011d9:	74 4c                	je     101227 <cga_putc+0x88>
  1011db:	e9 94 00 00 00       	jmp    101274 <cga_putc+0xd5>
    case '\b':
        if (crt_pos > 0) {
  1011e0:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011e7:	85 c0                	test   %eax,%eax
  1011e9:	0f 84 af 00 00 00    	je     10129e <cga_putc+0xff>
            crt_pos --;
  1011ef:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011f6:	48                   	dec    %eax
  1011f7:	0f b7 c0             	movzwl %ax,%eax
  1011fa:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101200:	8b 45 08             	mov    0x8(%ebp),%eax
  101203:	98                   	cwtl   
  101204:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101209:	98                   	cwtl   
  10120a:	83 c8 20             	or     $0x20,%eax
  10120d:	98                   	cwtl   
  10120e:	8b 15 40 c4 11 00    	mov    0x11c440,%edx
  101214:	0f b7 0d 44 c4 11 00 	movzwl 0x11c444,%ecx
  10121b:	01 c9                	add    %ecx,%ecx
  10121d:	01 ca                	add    %ecx,%edx
  10121f:	0f b7 c0             	movzwl %ax,%eax
  101222:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101225:	eb 77                	jmp    10129e <cga_putc+0xff>
    case '\n':
        crt_pos += CRT_COLS;
  101227:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10122e:	83 c0 50             	add    $0x50,%eax
  101231:	0f b7 c0             	movzwl %ax,%eax
  101234:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10123a:	0f b7 1d 44 c4 11 00 	movzwl 0x11c444,%ebx
  101241:	0f b7 0d 44 c4 11 00 	movzwl 0x11c444,%ecx
  101248:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  10124d:	89 c8                	mov    %ecx,%eax
  10124f:	f7 e2                	mul    %edx
  101251:	c1 ea 06             	shr    $0x6,%edx
  101254:	89 d0                	mov    %edx,%eax
  101256:	c1 e0 02             	shl    $0x2,%eax
  101259:	01 d0                	add    %edx,%eax
  10125b:	c1 e0 04             	shl    $0x4,%eax
  10125e:	29 c1                	sub    %eax,%ecx
  101260:	89 c8                	mov    %ecx,%eax
  101262:	0f b7 c0             	movzwl %ax,%eax
  101265:	29 c3                	sub    %eax,%ebx
  101267:	89 d8                	mov    %ebx,%eax
  101269:	0f b7 c0             	movzwl %ax,%eax
  10126c:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
        break;
  101272:	eb 2b                	jmp    10129f <cga_putc+0x100>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101274:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  10127a:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101281:	8d 50 01             	lea    0x1(%eax),%edx
  101284:	0f b7 d2             	movzwl %dx,%edx
  101287:	66 89 15 44 c4 11 00 	mov    %dx,0x11c444
  10128e:	01 c0                	add    %eax,%eax
  101290:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101293:	8b 45 08             	mov    0x8(%ebp),%eax
  101296:	0f b7 c0             	movzwl %ax,%eax
  101299:	66 89 02             	mov    %ax,(%edx)
        break;
  10129c:	eb 01                	jmp    10129f <cga_putc+0x100>
        break;
  10129e:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  10129f:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1012a6:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1012ab:	76 5d                	jbe    10130a <cga_putc+0x16b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1012ad:	a1 40 c4 11 00       	mov    0x11c440,%eax
  1012b2:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1012b8:	a1 40 c4 11 00       	mov    0x11c440,%eax
  1012bd:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1012c4:	00 
  1012c5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1012c9:	89 04 24             	mov    %eax,(%esp)
  1012cc:	e8 42 47 00 00       	call   105a13 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1012d1:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1012d8:	eb 14                	jmp    1012ee <cga_putc+0x14f>
            crt_buf[i] = 0x0700 | ' ';
  1012da:	a1 40 c4 11 00       	mov    0x11c440,%eax
  1012df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1012e2:	01 d2                	add    %edx,%edx
  1012e4:	01 d0                	add    %edx,%eax
  1012e6:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1012eb:	ff 45 f4             	incl   -0xc(%ebp)
  1012ee:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1012f5:	7e e3                	jle    1012da <cga_putc+0x13b>
        }
        crt_pos -= CRT_COLS;
  1012f7:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1012fe:	83 e8 50             	sub    $0x50,%eax
  101301:	0f b7 c0             	movzwl %ax,%eax
  101304:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10130a:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  101311:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  101315:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101319:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10131d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101321:	ee                   	out    %al,(%dx)
}
  101322:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  101323:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10132a:	c1 e8 08             	shr    $0x8,%eax
  10132d:	0f b7 c0             	movzwl %ax,%eax
  101330:	0f b6 c0             	movzbl %al,%eax
  101333:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  10133a:	42                   	inc    %edx
  10133b:	0f b7 d2             	movzwl %dx,%edx
  10133e:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  101342:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101345:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101349:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10134d:	ee                   	out    %al,(%dx)
}
  10134e:	90                   	nop
    outb(addr_6845, 15);
  10134f:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  101356:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  10135a:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10135e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101362:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101366:	ee                   	out    %al,(%dx)
}
  101367:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  101368:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10136f:	0f b6 c0             	movzbl %al,%eax
  101372:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  101379:	42                   	inc    %edx
  10137a:	0f b7 d2             	movzwl %dx,%edx
  10137d:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  101381:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101384:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101388:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10138c:	ee                   	out    %al,(%dx)
}
  10138d:	90                   	nop
}
  10138e:	90                   	nop
  10138f:	83 c4 34             	add    $0x34,%esp
  101392:	5b                   	pop    %ebx
  101393:	5d                   	pop    %ebp
  101394:	c3                   	ret    

00101395 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101395:	f3 0f 1e fb          	endbr32 
  101399:	55                   	push   %ebp
  10139a:	89 e5                	mov    %esp,%ebp
  10139c:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10139f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1013a6:	eb 08                	jmp    1013b0 <serial_putc_sub+0x1b>
        delay();
  1013a8:	e8 08 fb ff ff       	call   100eb5 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1013ad:	ff 45 fc             	incl   -0x4(%ebp)
  1013b0:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013b6:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013ba:	89 c2                	mov    %eax,%edx
  1013bc:	ec                   	in     (%dx),%al
  1013bd:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1013c0:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1013c4:	0f b6 c0             	movzbl %al,%eax
  1013c7:	83 e0 20             	and    $0x20,%eax
  1013ca:	85 c0                	test   %eax,%eax
  1013cc:	75 09                	jne    1013d7 <serial_putc_sub+0x42>
  1013ce:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1013d5:	7e d1                	jle    1013a8 <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
  1013d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1013da:	0f b6 c0             	movzbl %al,%eax
  1013dd:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  1013e3:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1013e6:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1013ea:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1013ee:	ee                   	out    %al,(%dx)
}
  1013ef:	90                   	nop
}
  1013f0:	90                   	nop
  1013f1:	c9                   	leave  
  1013f2:	c3                   	ret    

001013f3 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1013f3:	f3 0f 1e fb          	endbr32 
  1013f7:	55                   	push   %ebp
  1013f8:	89 e5                	mov    %esp,%ebp
  1013fa:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1013fd:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101401:	74 0d                	je     101410 <serial_putc+0x1d>
        serial_putc_sub(c);
  101403:	8b 45 08             	mov    0x8(%ebp),%eax
  101406:	89 04 24             	mov    %eax,(%esp)
  101409:	e8 87 ff ff ff       	call   101395 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  10140e:	eb 24                	jmp    101434 <serial_putc+0x41>
        serial_putc_sub('\b');
  101410:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101417:	e8 79 ff ff ff       	call   101395 <serial_putc_sub>
        serial_putc_sub(' ');
  10141c:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101423:	e8 6d ff ff ff       	call   101395 <serial_putc_sub>
        serial_putc_sub('\b');
  101428:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10142f:	e8 61 ff ff ff       	call   101395 <serial_putc_sub>
}
  101434:	90                   	nop
  101435:	c9                   	leave  
  101436:	c3                   	ret    

00101437 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101437:	f3 0f 1e fb          	endbr32 
  10143b:	55                   	push   %ebp
  10143c:	89 e5                	mov    %esp,%ebp
  10143e:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101441:	eb 33                	jmp    101476 <cons_intr+0x3f>
        if (c != 0) {
  101443:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101447:	74 2d                	je     101476 <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
  101449:	a1 64 c6 11 00       	mov    0x11c664,%eax
  10144e:	8d 50 01             	lea    0x1(%eax),%edx
  101451:	89 15 64 c6 11 00    	mov    %edx,0x11c664
  101457:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10145a:	88 90 60 c4 11 00    	mov    %dl,0x11c460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101460:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101465:	3d 00 02 00 00       	cmp    $0x200,%eax
  10146a:	75 0a                	jne    101476 <cons_intr+0x3f>
                cons.wpos = 0;
  10146c:	c7 05 64 c6 11 00 00 	movl   $0x0,0x11c664
  101473:	00 00 00 
    while ((c = (*proc)()) != -1) {
  101476:	8b 45 08             	mov    0x8(%ebp),%eax
  101479:	ff d0                	call   *%eax
  10147b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10147e:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101482:	75 bf                	jne    101443 <cons_intr+0xc>
            }
        }
    }
}
  101484:	90                   	nop
  101485:	90                   	nop
  101486:	c9                   	leave  
  101487:	c3                   	ret    

00101488 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101488:	f3 0f 1e fb          	endbr32 
  10148c:	55                   	push   %ebp
  10148d:	89 e5                	mov    %esp,%ebp
  10148f:	83 ec 10             	sub    $0x10,%esp
  101492:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101498:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10149c:	89 c2                	mov    %eax,%edx
  10149e:	ec                   	in     (%dx),%al
  10149f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1014a2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1014a6:	0f b6 c0             	movzbl %al,%eax
  1014a9:	83 e0 01             	and    $0x1,%eax
  1014ac:	85 c0                	test   %eax,%eax
  1014ae:	75 07                	jne    1014b7 <serial_proc_data+0x2f>
        return -1;
  1014b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1014b5:	eb 2a                	jmp    1014e1 <serial_proc_data+0x59>
  1014b7:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1014bd:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  1014c1:	89 c2                	mov    %eax,%edx
  1014c3:	ec                   	in     (%dx),%al
  1014c4:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  1014c7:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1014cb:	0f b6 c0             	movzbl %al,%eax
  1014ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1014d1:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1014d5:	75 07                	jne    1014de <serial_proc_data+0x56>
        c = '\b';
  1014d7:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1014de:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1014e1:	c9                   	leave  
  1014e2:	c3                   	ret    

001014e3 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1014e3:	f3 0f 1e fb          	endbr32 
  1014e7:	55                   	push   %ebp
  1014e8:	89 e5                	mov    %esp,%ebp
  1014ea:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1014ed:	a1 48 c4 11 00       	mov    0x11c448,%eax
  1014f2:	85 c0                	test   %eax,%eax
  1014f4:	74 0c                	je     101502 <serial_intr+0x1f>
        cons_intr(serial_proc_data);
  1014f6:	c7 04 24 88 14 10 00 	movl   $0x101488,(%esp)
  1014fd:	e8 35 ff ff ff       	call   101437 <cons_intr>
    }
}
  101502:	90                   	nop
  101503:	c9                   	leave  
  101504:	c3                   	ret    

00101505 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101505:	f3 0f 1e fb          	endbr32 
  101509:	55                   	push   %ebp
  10150a:	89 e5                	mov    %esp,%ebp
  10150c:	83 ec 38             	sub    $0x38,%esp
  10150f:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101515:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101518:	89 c2                	mov    %eax,%edx
  10151a:	ec                   	in     (%dx),%al
  10151b:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  10151e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101522:	0f b6 c0             	movzbl %al,%eax
  101525:	83 e0 01             	and    $0x1,%eax
  101528:	85 c0                	test   %eax,%eax
  10152a:	75 0a                	jne    101536 <kbd_proc_data+0x31>
        return -1;
  10152c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101531:	e9 56 01 00 00       	jmp    10168c <kbd_proc_data+0x187>
  101536:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10153c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10153f:	89 c2                	mov    %eax,%edx
  101541:	ec                   	in     (%dx),%al
  101542:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101545:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  101549:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10154c:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101550:	75 17                	jne    101569 <kbd_proc_data+0x64>
        // E0 escape character
        shift |= E0ESC;
  101552:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101557:	83 c8 40             	or     $0x40,%eax
  10155a:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  10155f:	b8 00 00 00 00       	mov    $0x0,%eax
  101564:	e9 23 01 00 00       	jmp    10168c <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  101569:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10156d:	84 c0                	test   %al,%al
  10156f:	79 45                	jns    1015b6 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101571:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101576:	83 e0 40             	and    $0x40,%eax
  101579:	85 c0                	test   %eax,%eax
  10157b:	75 08                	jne    101585 <kbd_proc_data+0x80>
  10157d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101581:	24 7f                	and    $0x7f,%al
  101583:	eb 04                	jmp    101589 <kbd_proc_data+0x84>
  101585:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101589:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  10158c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101590:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  101597:	0c 40                	or     $0x40,%al
  101599:	0f b6 c0             	movzbl %al,%eax
  10159c:	f7 d0                	not    %eax
  10159e:	89 c2                	mov    %eax,%edx
  1015a0:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015a5:	21 d0                	and    %edx,%eax
  1015a7:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  1015ac:	b8 00 00 00 00       	mov    $0x0,%eax
  1015b1:	e9 d6 00 00 00       	jmp    10168c <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  1015b6:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015bb:	83 e0 40             	and    $0x40,%eax
  1015be:	85 c0                	test   %eax,%eax
  1015c0:	74 11                	je     1015d3 <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1015c2:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1015c6:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015cb:	83 e0 bf             	and    $0xffffffbf,%eax
  1015ce:	a3 68 c6 11 00       	mov    %eax,0x11c668
    }

    shift |= shiftcode[data];
  1015d3:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015d7:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  1015de:	0f b6 d0             	movzbl %al,%edx
  1015e1:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015e6:	09 d0                	or     %edx,%eax
  1015e8:	a3 68 c6 11 00       	mov    %eax,0x11c668
    shift ^= togglecode[data];
  1015ed:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015f1:	0f b6 80 40 91 11 00 	movzbl 0x119140(%eax),%eax
  1015f8:	0f b6 d0             	movzbl %al,%edx
  1015fb:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101600:	31 d0                	xor    %edx,%eax
  101602:	a3 68 c6 11 00       	mov    %eax,0x11c668

    c = charcode[shift & (CTL | SHIFT)][data];
  101607:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10160c:	83 e0 03             	and    $0x3,%eax
  10160f:	8b 14 85 40 95 11 00 	mov    0x119540(,%eax,4),%edx
  101616:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10161a:	01 d0                	add    %edx,%eax
  10161c:	0f b6 00             	movzbl (%eax),%eax
  10161f:	0f b6 c0             	movzbl %al,%eax
  101622:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101625:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10162a:	83 e0 08             	and    $0x8,%eax
  10162d:	85 c0                	test   %eax,%eax
  10162f:	74 22                	je     101653 <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  101631:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101635:	7e 0c                	jle    101643 <kbd_proc_data+0x13e>
  101637:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  10163b:	7f 06                	jg     101643 <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  10163d:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101641:	eb 10                	jmp    101653 <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  101643:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101647:	7e 0a                	jle    101653 <kbd_proc_data+0x14e>
  101649:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10164d:	7f 04                	jg     101653 <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  10164f:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101653:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101658:	f7 d0                	not    %eax
  10165a:	83 e0 06             	and    $0x6,%eax
  10165d:	85 c0                	test   %eax,%eax
  10165f:	75 28                	jne    101689 <kbd_proc_data+0x184>
  101661:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101668:	75 1f                	jne    101689 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  10166a:	c7 04 24 41 65 10 00 	movl   $0x106541,(%esp)
  101671:	e8 53 ec ff ff       	call   1002c9 <cprintf>
  101676:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  10167c:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101680:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101684:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101687:	ee                   	out    %al,(%dx)
}
  101688:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101689:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10168c:	c9                   	leave  
  10168d:	c3                   	ret    

0010168e <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10168e:	f3 0f 1e fb          	endbr32 
  101692:	55                   	push   %ebp
  101693:	89 e5                	mov    %esp,%ebp
  101695:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101698:	c7 04 24 05 15 10 00 	movl   $0x101505,(%esp)
  10169f:	e8 93 fd ff ff       	call   101437 <cons_intr>
}
  1016a4:	90                   	nop
  1016a5:	c9                   	leave  
  1016a6:	c3                   	ret    

001016a7 <kbd_init>:

static void
kbd_init(void) {
  1016a7:	f3 0f 1e fb          	endbr32 
  1016ab:	55                   	push   %ebp
  1016ac:	89 e5                	mov    %esp,%ebp
  1016ae:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1016b1:	e8 d8 ff ff ff       	call   10168e <kbd_intr>
    pic_enable(IRQ_KBD);
  1016b6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1016bd:	e8 47 01 00 00       	call   101809 <pic_enable>
}
  1016c2:	90                   	nop
  1016c3:	c9                   	leave  
  1016c4:	c3                   	ret    

001016c5 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1016c5:	f3 0f 1e fb          	endbr32 
  1016c9:	55                   	push   %ebp
  1016ca:	89 e5                	mov    %esp,%ebp
  1016cc:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1016cf:	e8 2e f8 ff ff       	call   100f02 <cga_init>
    serial_init();
  1016d4:	e8 13 f9 ff ff       	call   100fec <serial_init>
    kbd_init();
  1016d9:	e8 c9 ff ff ff       	call   1016a7 <kbd_init>
    if (!serial_exists) {
  1016de:	a1 48 c4 11 00       	mov    0x11c448,%eax
  1016e3:	85 c0                	test   %eax,%eax
  1016e5:	75 0c                	jne    1016f3 <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
  1016e7:	c7 04 24 4d 65 10 00 	movl   $0x10654d,(%esp)
  1016ee:	e8 d6 eb ff ff       	call   1002c9 <cprintf>
    }
}
  1016f3:	90                   	nop
  1016f4:	c9                   	leave  
  1016f5:	c3                   	ret    

001016f6 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1016f6:	f3 0f 1e fb          	endbr32 
  1016fa:	55                   	push   %ebp
  1016fb:	89 e5                	mov    %esp,%ebp
  1016fd:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101700:	e8 72 f7 ff ff       	call   100e77 <__intr_save>
  101705:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101708:	8b 45 08             	mov    0x8(%ebp),%eax
  10170b:	89 04 24             	mov    %eax,(%esp)
  10170e:	e8 48 fa ff ff       	call   10115b <lpt_putc>
        cga_putc(c);
  101713:	8b 45 08             	mov    0x8(%ebp),%eax
  101716:	89 04 24             	mov    %eax,(%esp)
  101719:	e8 81 fa ff ff       	call   10119f <cga_putc>
        serial_putc(c);
  10171e:	8b 45 08             	mov    0x8(%ebp),%eax
  101721:	89 04 24             	mov    %eax,(%esp)
  101724:	e8 ca fc ff ff       	call   1013f3 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101729:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10172c:	89 04 24             	mov    %eax,(%esp)
  10172f:	e8 6d f7 ff ff       	call   100ea1 <__intr_restore>
}
  101734:	90                   	nop
  101735:	c9                   	leave  
  101736:	c3                   	ret    

00101737 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101737:	f3 0f 1e fb          	endbr32 
  10173b:	55                   	push   %ebp
  10173c:	89 e5                	mov    %esp,%ebp
  10173e:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101748:	e8 2a f7 ff ff       	call   100e77 <__intr_save>
  10174d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  101750:	e8 8e fd ff ff       	call   1014e3 <serial_intr>
        kbd_intr();
  101755:	e8 34 ff ff ff       	call   10168e <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  10175a:	8b 15 60 c6 11 00    	mov    0x11c660,%edx
  101760:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101765:	39 c2                	cmp    %eax,%edx
  101767:	74 31                	je     10179a <cons_getc+0x63>
            c = cons.buf[cons.rpos ++];
  101769:	a1 60 c6 11 00       	mov    0x11c660,%eax
  10176e:	8d 50 01             	lea    0x1(%eax),%edx
  101771:	89 15 60 c6 11 00    	mov    %edx,0x11c660
  101777:	0f b6 80 60 c4 11 00 	movzbl 0x11c460(%eax),%eax
  10177e:	0f b6 c0             	movzbl %al,%eax
  101781:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101784:	a1 60 c6 11 00       	mov    0x11c660,%eax
  101789:	3d 00 02 00 00       	cmp    $0x200,%eax
  10178e:	75 0a                	jne    10179a <cons_getc+0x63>
                cons.rpos = 0;
  101790:	c7 05 60 c6 11 00 00 	movl   $0x0,0x11c660
  101797:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  10179a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10179d:	89 04 24             	mov    %eax,(%esp)
  1017a0:	e8 fc f6 ff ff       	call   100ea1 <__intr_restore>
    return c;
  1017a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1017a8:	c9                   	leave  
  1017a9:	c3                   	ret    

001017aa <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1017aa:	f3 0f 1e fb          	endbr32 
  1017ae:	55                   	push   %ebp
  1017af:	89 e5                	mov    %esp,%ebp
  1017b1:	83 ec 14             	sub    $0x14,%esp
  1017b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1017b7:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1017bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1017be:	66 a3 50 95 11 00    	mov    %ax,0x119550
    if (did_init) {
  1017c4:	a1 6c c6 11 00       	mov    0x11c66c,%eax
  1017c9:	85 c0                	test   %eax,%eax
  1017cb:	74 39                	je     101806 <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
  1017cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1017d0:	0f b6 c0             	movzbl %al,%eax
  1017d3:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  1017d9:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017dc:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1017e0:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1017e4:	ee                   	out    %al,(%dx)
}
  1017e5:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  1017e6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1017ea:	c1 e8 08             	shr    $0x8,%eax
  1017ed:	0f b7 c0             	movzwl %ax,%eax
  1017f0:	0f b6 c0             	movzbl %al,%eax
  1017f3:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  1017f9:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017fc:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101800:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101804:	ee                   	out    %al,(%dx)
}
  101805:	90                   	nop
    }
}
  101806:	90                   	nop
  101807:	c9                   	leave  
  101808:	c3                   	ret    

00101809 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101809:	f3 0f 1e fb          	endbr32 
  10180d:	55                   	push   %ebp
  10180e:	89 e5                	mov    %esp,%ebp
  101810:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101813:	8b 45 08             	mov    0x8(%ebp),%eax
  101816:	ba 01 00 00 00       	mov    $0x1,%edx
  10181b:	88 c1                	mov    %al,%cl
  10181d:	d3 e2                	shl    %cl,%edx
  10181f:	89 d0                	mov    %edx,%eax
  101821:	98                   	cwtl   
  101822:	f7 d0                	not    %eax
  101824:	0f bf d0             	movswl %ax,%edx
  101827:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  10182e:	98                   	cwtl   
  10182f:	21 d0                	and    %edx,%eax
  101831:	98                   	cwtl   
  101832:	0f b7 c0             	movzwl %ax,%eax
  101835:	89 04 24             	mov    %eax,(%esp)
  101838:	e8 6d ff ff ff       	call   1017aa <pic_setmask>
}
  10183d:	90                   	nop
  10183e:	c9                   	leave  
  10183f:	c3                   	ret    

00101840 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101840:	f3 0f 1e fb          	endbr32 
  101844:	55                   	push   %ebp
  101845:	89 e5                	mov    %esp,%ebp
  101847:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  10184a:	c7 05 6c c6 11 00 01 	movl   $0x1,0x11c66c
  101851:	00 00 00 
  101854:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  10185a:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10185e:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  101862:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  101866:	ee                   	out    %al,(%dx)
}
  101867:	90                   	nop
  101868:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  10186e:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101872:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  101876:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  10187a:	ee                   	out    %al,(%dx)
}
  10187b:	90                   	nop
  10187c:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101882:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101886:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  10188a:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  10188e:	ee                   	out    %al,(%dx)
}
  10188f:	90                   	nop
  101890:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  101896:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10189a:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  10189e:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  1018a2:	ee                   	out    %al,(%dx)
}
  1018a3:	90                   	nop
  1018a4:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  1018aa:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018ae:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1018b2:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  1018b6:	ee                   	out    %al,(%dx)
}
  1018b7:	90                   	nop
  1018b8:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  1018be:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018c2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1018c6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  1018ca:	ee                   	out    %al,(%dx)
}
  1018cb:	90                   	nop
  1018cc:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  1018d2:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018d6:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1018da:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  1018de:	ee                   	out    %al,(%dx)
}
  1018df:	90                   	nop
  1018e0:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  1018e6:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018ea:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1018ee:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1018f2:	ee                   	out    %al,(%dx)
}
  1018f3:	90                   	nop
  1018f4:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  1018fa:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018fe:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101902:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101906:	ee                   	out    %al,(%dx)
}
  101907:	90                   	nop
  101908:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10190e:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101912:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101916:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  10191a:	ee                   	out    %al,(%dx)
}
  10191b:	90                   	nop
  10191c:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101922:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101926:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10192a:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10192e:	ee                   	out    %al,(%dx)
}
  10192f:	90                   	nop
  101930:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  101936:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10193a:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10193e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101942:	ee                   	out    %al,(%dx)
}
  101943:	90                   	nop
  101944:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  10194a:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10194e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101952:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101956:	ee                   	out    %al,(%dx)
}
  101957:	90                   	nop
  101958:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  10195e:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101962:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101966:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10196a:	ee                   	out    %al,(%dx)
}
  10196b:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  10196c:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  101973:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101978:	74 0f                	je     101989 <pic_init+0x149>
        pic_setmask(irq_mask);
  10197a:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  101981:	89 04 24             	mov    %eax,(%esp)
  101984:	e8 21 fe ff ff       	call   1017aa <pic_setmask>
    }
}
  101989:	90                   	nop
  10198a:	c9                   	leave  
  10198b:	c3                   	ret    

0010198c <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  10198c:	f3 0f 1e fb          	endbr32 
  101990:	55                   	push   %ebp
  101991:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  101993:	fb                   	sti    
}
  101994:	90                   	nop
    sti();
}
  101995:	90                   	nop
  101996:	5d                   	pop    %ebp
  101997:	c3                   	ret    

00101998 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101998:	f3 0f 1e fb          	endbr32 
  10199c:	55                   	push   %ebp
  10199d:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  10199f:	fa                   	cli    
}
  1019a0:	90                   	nop
    cli();
}
  1019a1:	90                   	nop
  1019a2:	5d                   	pop    %ebp
  1019a3:	c3                   	ret    

001019a4 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1019a4:	f3 0f 1e fb          	endbr32 
  1019a8:	55                   	push   %ebp
  1019a9:	89 e5                	mov    %esp,%ebp
  1019ab:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1019ae:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1019b5:	00 
  1019b6:	c7 04 24 80 65 10 00 	movl   $0x106580,(%esp)
  1019bd:	e8 07 e9 ff ff       	call   1002c9 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1019c2:	90                   	nop
  1019c3:	c9                   	leave  
  1019c4:	c3                   	ret    

001019c5 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1019c5:	f3 0f 1e fb          	endbr32 
  1019c9:	55                   	push   %ebp
  1019ca:	89 e5                	mov    %esp,%ebp
  1019cc:	83 ec 10             	sub    $0x10,%esp
           (try "make" command in lab1, then you will find vector.S in kern/trap DIR)
           You can use  "extern uintptr_t __vectors[];" to define this extern variable which will be used later. */
    extern uintptr_t __vectors[];
    /* (2) Now you should setup the entries of ISR in Interrupt Description Table (IDT).
           Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT */
    int idt_size = sizeof(idt) / sizeof(struct gatedesc);
  1019cf:	c7 45 f8 00 01 00 00 	movl   $0x100,-0x8(%ebp)
    for (int i = 0; i < idt_size; ++i) {
  1019d6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1019dd:	e9 c4 00 00 00       	jmp    101aa6 <idt_init+0xe1>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1019e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019e5:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  1019ec:	0f b7 d0             	movzwl %ax,%edx
  1019ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019f2:	66 89 14 c5 80 c6 11 	mov    %dx,0x11c680(,%eax,8)
  1019f9:	00 
  1019fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019fd:	66 c7 04 c5 82 c6 11 	movw   $0x8,0x11c682(,%eax,8)
  101a04:	00 08 00 
  101a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a0a:	0f b6 14 c5 84 c6 11 	movzbl 0x11c684(,%eax,8),%edx
  101a11:	00 
  101a12:	80 e2 e0             	and    $0xe0,%dl
  101a15:	88 14 c5 84 c6 11 00 	mov    %dl,0x11c684(,%eax,8)
  101a1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a1f:	0f b6 14 c5 84 c6 11 	movzbl 0x11c684(,%eax,8),%edx
  101a26:	00 
  101a27:	80 e2 1f             	and    $0x1f,%dl
  101a2a:	88 14 c5 84 c6 11 00 	mov    %dl,0x11c684(,%eax,8)
  101a31:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a34:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101a3b:	00 
  101a3c:	80 e2 f0             	and    $0xf0,%dl
  101a3f:	80 ca 0e             	or     $0xe,%dl
  101a42:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101a49:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a4c:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101a53:	00 
  101a54:	80 e2 ef             	and    $0xef,%dl
  101a57:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101a5e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a61:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101a68:	00 
  101a69:	80 e2 9f             	and    $0x9f,%dl
  101a6c:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101a73:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a76:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101a7d:	00 
  101a7e:	80 ca 80             	or     $0x80,%dl
  101a81:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101a88:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a8b:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  101a92:	c1 e8 10             	shr    $0x10,%eax
  101a95:	0f b7 d0             	movzwl %ax,%edx
  101a98:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a9b:	66 89 14 c5 86 c6 11 	mov    %dx,0x11c686(,%eax,8)
  101aa2:	00 
    for (int i = 0; i < idt_size; ++i) {
  101aa3:	ff 45 fc             	incl   -0x4(%ebp)
  101aa6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101aa9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  101aac:	0f 8c 30 ff ff ff    	jl     1019e2 <idt_init+0x1d>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101ab2:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101ab7:	0f b7 c0             	movzwl %ax,%eax
  101aba:	66 a3 48 ca 11 00    	mov    %ax,0x11ca48
  101ac0:	66 c7 05 4a ca 11 00 	movw   $0x8,0x11ca4a
  101ac7:	08 00 
  101ac9:	0f b6 05 4c ca 11 00 	movzbl 0x11ca4c,%eax
  101ad0:	24 e0                	and    $0xe0,%al
  101ad2:	a2 4c ca 11 00       	mov    %al,0x11ca4c
  101ad7:	0f b6 05 4c ca 11 00 	movzbl 0x11ca4c,%eax
  101ade:	24 1f                	and    $0x1f,%al
  101ae0:	a2 4c ca 11 00       	mov    %al,0x11ca4c
  101ae5:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101aec:	24 f0                	and    $0xf0,%al
  101aee:	0c 0e                	or     $0xe,%al
  101af0:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101af5:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101afc:	24 ef                	and    $0xef,%al
  101afe:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101b03:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101b0a:	0c 60                	or     $0x60,%al
  101b0c:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101b11:	0f b6 05 4d ca 11 00 	movzbl 0x11ca4d,%eax
  101b18:	0c 80                	or     $0x80,%al
  101b1a:	a2 4d ca 11 00       	mov    %al,0x11ca4d
  101b1f:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101b24:	c1 e8 10             	shr    $0x10,%eax
  101b27:	0f b7 c0             	movzwl %ax,%eax
  101b2a:	66 a3 4e ca 11 00    	mov    %ax,0x11ca4e
  101b30:	c7 45 f4 60 95 11 00 	movl   $0x119560,-0xc(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b3a:	0f 01 18             	lidtl  (%eax)
}
  101b3d:	90                   	nop
    /* (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
           You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
           Notice: the argument of lidt is idt_pd. try to find it! */
    lidt(&idt_pd);
}
  101b3e:	90                   	nop
  101b3f:	c9                   	leave  
  101b40:	c3                   	ret    

00101b41 <trapname>:

static const char *
trapname(int trapno) {
  101b41:	f3 0f 1e fb          	endbr32 
  101b45:	55                   	push   %ebp
  101b46:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101b48:	8b 45 08             	mov    0x8(%ebp),%eax
  101b4b:	83 f8 13             	cmp    $0x13,%eax
  101b4e:	77 0c                	ja     101b5c <trapname+0x1b>
        return excnames[trapno];
  101b50:	8b 45 08             	mov    0x8(%ebp),%eax
  101b53:	8b 04 85 e0 68 10 00 	mov    0x1068e0(,%eax,4),%eax
  101b5a:	eb 18                	jmp    101b74 <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101b5c:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101b60:	7e 0d                	jle    101b6f <trapname+0x2e>
  101b62:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101b66:	7f 07                	jg     101b6f <trapname+0x2e>
        return "Hardware Interrupt";
  101b68:	b8 8a 65 10 00       	mov    $0x10658a,%eax
  101b6d:	eb 05                	jmp    101b74 <trapname+0x33>
    }
    return "(unknown trap)";
  101b6f:	b8 9d 65 10 00       	mov    $0x10659d,%eax
}
  101b74:	5d                   	pop    %ebp
  101b75:	c3                   	ret    

00101b76 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101b76:	f3 0f 1e fb          	endbr32 
  101b7a:	55                   	push   %ebp
  101b7b:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  101b80:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b84:	83 f8 08             	cmp    $0x8,%eax
  101b87:	0f 94 c0             	sete   %al
  101b8a:	0f b6 c0             	movzbl %al,%eax
}
  101b8d:	5d                   	pop    %ebp
  101b8e:	c3                   	ret    

00101b8f <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101b8f:	f3 0f 1e fb          	endbr32 
  101b93:	55                   	push   %ebp
  101b94:	89 e5                	mov    %esp,%ebp
  101b96:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101b99:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba0:	c7 04 24 de 65 10 00 	movl   $0x1065de,(%esp)
  101ba7:	e8 1d e7 ff ff       	call   1002c9 <cprintf>
    print_regs(&tf->tf_regs);
  101bac:	8b 45 08             	mov    0x8(%ebp),%eax
  101baf:	89 04 24             	mov    %eax,(%esp)
  101bb2:	e8 8d 01 00 00       	call   101d44 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  101bba:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc2:	c7 04 24 ef 65 10 00 	movl   $0x1065ef,(%esp)
  101bc9:	e8 fb e6 ff ff       	call   1002c9 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101bce:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd1:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101bd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd9:	c7 04 24 02 66 10 00 	movl   $0x106602,(%esp)
  101be0:	e8 e4 e6 ff ff       	call   1002c9 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101be5:	8b 45 08             	mov    0x8(%ebp),%eax
  101be8:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101bec:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf0:	c7 04 24 15 66 10 00 	movl   $0x106615,(%esp)
  101bf7:	e8 cd e6 ff ff       	call   1002c9 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  101bff:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c07:	c7 04 24 28 66 10 00 	movl   $0x106628,(%esp)
  101c0e:	e8 b6 e6 ff ff       	call   1002c9 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101c13:	8b 45 08             	mov    0x8(%ebp),%eax
  101c16:	8b 40 30             	mov    0x30(%eax),%eax
  101c19:	89 04 24             	mov    %eax,(%esp)
  101c1c:	e8 20 ff ff ff       	call   101b41 <trapname>
  101c21:	8b 55 08             	mov    0x8(%ebp),%edx
  101c24:	8b 52 30             	mov    0x30(%edx),%edx
  101c27:	89 44 24 08          	mov    %eax,0x8(%esp)
  101c2b:	89 54 24 04          	mov    %edx,0x4(%esp)
  101c2f:	c7 04 24 3b 66 10 00 	movl   $0x10663b,(%esp)
  101c36:	e8 8e e6 ff ff       	call   1002c9 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c3e:	8b 40 34             	mov    0x34(%eax),%eax
  101c41:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c45:	c7 04 24 4d 66 10 00 	movl   $0x10664d,(%esp)
  101c4c:	e8 78 e6 ff ff       	call   1002c9 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101c51:	8b 45 08             	mov    0x8(%ebp),%eax
  101c54:	8b 40 38             	mov    0x38(%eax),%eax
  101c57:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5b:	c7 04 24 5c 66 10 00 	movl   $0x10665c,(%esp)
  101c62:	e8 62 e6 ff ff       	call   1002c9 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101c67:	8b 45 08             	mov    0x8(%ebp),%eax
  101c6a:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c72:	c7 04 24 6b 66 10 00 	movl   $0x10666b,(%esp)
  101c79:	e8 4b e6 ff ff       	call   1002c9 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c81:	8b 40 40             	mov    0x40(%eax),%eax
  101c84:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c88:	c7 04 24 7e 66 10 00 	movl   $0x10667e,(%esp)
  101c8f:	e8 35 e6 ff ff       	call   1002c9 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101c9b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101ca2:	eb 3d                	jmp    101ce1 <print_trapframe+0x152>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca7:	8b 50 40             	mov    0x40(%eax),%edx
  101caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101cad:	21 d0                	and    %edx,%eax
  101caf:	85 c0                	test   %eax,%eax
  101cb1:	74 28                	je     101cdb <print_trapframe+0x14c>
  101cb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101cb6:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101cbd:	85 c0                	test   %eax,%eax
  101cbf:	74 1a                	je     101cdb <print_trapframe+0x14c>
            cprintf("%s,", IA32flags[i]);
  101cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101cc4:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101ccb:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ccf:	c7 04 24 8d 66 10 00 	movl   $0x10668d,(%esp)
  101cd6:	e8 ee e5 ff ff       	call   1002c9 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101cdb:	ff 45 f4             	incl   -0xc(%ebp)
  101cde:	d1 65 f0             	shll   -0x10(%ebp)
  101ce1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101ce4:	83 f8 17             	cmp    $0x17,%eax
  101ce7:	76 bb                	jbe    101ca4 <print_trapframe+0x115>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  101cec:	8b 40 40             	mov    0x40(%eax),%eax
  101cef:	c1 e8 0c             	shr    $0xc,%eax
  101cf2:	83 e0 03             	and    $0x3,%eax
  101cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf9:	c7 04 24 91 66 10 00 	movl   $0x106691,(%esp)
  101d00:	e8 c4 e5 ff ff       	call   1002c9 <cprintf>

    if (!trap_in_kernel(tf)) {
  101d05:	8b 45 08             	mov    0x8(%ebp),%eax
  101d08:	89 04 24             	mov    %eax,(%esp)
  101d0b:	e8 66 fe ff ff       	call   101b76 <trap_in_kernel>
  101d10:	85 c0                	test   %eax,%eax
  101d12:	75 2d                	jne    101d41 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101d14:	8b 45 08             	mov    0x8(%ebp),%eax
  101d17:	8b 40 44             	mov    0x44(%eax),%eax
  101d1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d1e:	c7 04 24 9a 66 10 00 	movl   $0x10669a,(%esp)
  101d25:	e8 9f e5 ff ff       	call   1002c9 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d2d:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d35:	c7 04 24 a9 66 10 00 	movl   $0x1066a9,(%esp)
  101d3c:	e8 88 e5 ff ff       	call   1002c9 <cprintf>
    }
}
  101d41:	90                   	nop
  101d42:	c9                   	leave  
  101d43:	c3                   	ret    

00101d44 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101d44:	f3 0f 1e fb          	endbr32 
  101d48:	55                   	push   %ebp
  101d49:	89 e5                	mov    %esp,%ebp
  101d4b:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  101d51:	8b 00                	mov    (%eax),%eax
  101d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d57:	c7 04 24 bc 66 10 00 	movl   $0x1066bc,(%esp)
  101d5e:	e8 66 e5 ff ff       	call   1002c9 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101d63:	8b 45 08             	mov    0x8(%ebp),%eax
  101d66:	8b 40 04             	mov    0x4(%eax),%eax
  101d69:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d6d:	c7 04 24 cb 66 10 00 	movl   $0x1066cb,(%esp)
  101d74:	e8 50 e5 ff ff       	call   1002c9 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101d79:	8b 45 08             	mov    0x8(%ebp),%eax
  101d7c:	8b 40 08             	mov    0x8(%eax),%eax
  101d7f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d83:	c7 04 24 da 66 10 00 	movl   $0x1066da,(%esp)
  101d8a:	e8 3a e5 ff ff       	call   1002c9 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  101d92:	8b 40 0c             	mov    0xc(%eax),%eax
  101d95:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d99:	c7 04 24 e9 66 10 00 	movl   $0x1066e9,(%esp)
  101da0:	e8 24 e5 ff ff       	call   1002c9 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101da5:	8b 45 08             	mov    0x8(%ebp),%eax
  101da8:	8b 40 10             	mov    0x10(%eax),%eax
  101dab:	89 44 24 04          	mov    %eax,0x4(%esp)
  101daf:	c7 04 24 f8 66 10 00 	movl   $0x1066f8,(%esp)
  101db6:	e8 0e e5 ff ff       	call   1002c9 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  101dbe:	8b 40 14             	mov    0x14(%eax),%eax
  101dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dc5:	c7 04 24 07 67 10 00 	movl   $0x106707,(%esp)
  101dcc:	e8 f8 e4 ff ff       	call   1002c9 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101dd1:	8b 45 08             	mov    0x8(%ebp),%eax
  101dd4:	8b 40 18             	mov    0x18(%eax),%eax
  101dd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ddb:	c7 04 24 16 67 10 00 	movl   $0x106716,(%esp)
  101de2:	e8 e2 e4 ff ff       	call   1002c9 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101de7:	8b 45 08             	mov    0x8(%ebp),%eax
  101dea:	8b 40 1c             	mov    0x1c(%eax),%eax
  101ded:	89 44 24 04          	mov    %eax,0x4(%esp)
  101df1:	c7 04 24 25 67 10 00 	movl   $0x106725,(%esp)
  101df8:	e8 cc e4 ff ff       	call   1002c9 <cprintf>
}
  101dfd:	90                   	nop
  101dfe:	c9                   	leave  
  101dff:	c3                   	ret    

00101e00 <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101e00:	f3 0f 1e fb          	endbr32 
  101e04:	55                   	push   %ebp
  101e05:	89 e5                	mov    %esp,%ebp
  101e07:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  101e0d:	8b 40 30             	mov    0x30(%eax),%eax
  101e10:	83 f8 79             	cmp    $0x79,%eax
  101e13:	0f 84 35 01 00 00    	je     101f4e <trap_dispatch+0x14e>
  101e19:	83 f8 79             	cmp    $0x79,%eax
  101e1c:	0f 87 68 01 00 00    	ja     101f8a <trap_dispatch+0x18a>
  101e22:	83 f8 78             	cmp    $0x78,%eax
  101e25:	0f 84 da 00 00 00    	je     101f05 <trap_dispatch+0x105>
  101e2b:	83 f8 78             	cmp    $0x78,%eax
  101e2e:	0f 87 56 01 00 00    	ja     101f8a <trap_dispatch+0x18a>
  101e34:	83 f8 2f             	cmp    $0x2f,%eax
  101e37:	0f 87 4d 01 00 00    	ja     101f8a <trap_dispatch+0x18a>
  101e3d:	83 f8 2e             	cmp    $0x2e,%eax
  101e40:	0f 83 79 01 00 00    	jae    101fbf <trap_dispatch+0x1bf>
  101e46:	83 f8 24             	cmp    $0x24,%eax
  101e49:	74 68                	je     101eb3 <trap_dispatch+0xb3>
  101e4b:	83 f8 24             	cmp    $0x24,%eax
  101e4e:	0f 87 36 01 00 00    	ja     101f8a <trap_dispatch+0x18a>
  101e54:	83 f8 20             	cmp    $0x20,%eax
  101e57:	74 0a                	je     101e63 <trap_dispatch+0x63>
  101e59:	83 f8 21             	cmp    $0x21,%eax
  101e5c:	74 7e                	je     101edc <trap_dispatch+0xdc>
  101e5e:	e9 27 01 00 00       	jmp    101f8a <trap_dispatch+0x18a>
    case IRQ_OFFSET + IRQ_TIMER:
        /* LAB1 YOUR CODE : STEP 3 */
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c */
        ticks++;
  101e63:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  101e68:	40                   	inc    %eax
  101e69:	a3 0c cf 11 00       	mov    %eax,0x11cf0c
        /* (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks(). */
        if (ticks % TICK_NUM == 0) {
  101e6e:	8b 0d 0c cf 11 00    	mov    0x11cf0c,%ecx
  101e74:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101e79:	89 c8                	mov    %ecx,%eax
  101e7b:	f7 e2                	mul    %edx
  101e7d:	c1 ea 05             	shr    $0x5,%edx
  101e80:	89 d0                	mov    %edx,%eax
  101e82:	c1 e0 02             	shl    $0x2,%eax
  101e85:	01 d0                	add    %edx,%eax
  101e87:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101e8e:	01 d0                	add    %edx,%eax
  101e90:	c1 e0 02             	shl    $0x2,%eax
  101e93:	29 c1                	sub    %eax,%ecx
  101e95:	89 ca                	mov    %ecx,%edx
  101e97:	85 d2                	test   %edx,%edx
  101e99:	0f 85 23 01 00 00    	jne    101fc2 <trap_dispatch+0x1c2>
            print_ticks();
  101e9f:	e8 00 fb ff ff       	call   1019a4 <print_ticks>
            ticks = 0;
  101ea4:	c7 05 0c cf 11 00 00 	movl   $0x0,0x11cf0c
  101eab:	00 00 00 
        }
        /* (3) Too Simple? Yes, I think so! */
        break;
  101eae:	e9 0f 01 00 00       	jmp    101fc2 <trap_dispatch+0x1c2>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101eb3:	e8 7f f8 ff ff       	call   101737 <cons_getc>
  101eb8:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101ebb:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101ebf:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101ec3:	89 54 24 08          	mov    %edx,0x8(%esp)
  101ec7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ecb:	c7 04 24 34 67 10 00 	movl   $0x106734,(%esp)
  101ed2:	e8 f2 e3 ff ff       	call   1002c9 <cprintf>
        break;
  101ed7:	e9 ed 00 00 00       	jmp    101fc9 <trap_dispatch+0x1c9>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101edc:	e8 56 f8 ff ff       	call   101737 <cons_getc>
  101ee1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101ee4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101ee8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101eec:	89 54 24 08          	mov    %edx,0x8(%esp)
  101ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ef4:	c7 04 24 46 67 10 00 	movl   $0x106746,(%esp)
  101efb:	e8 c9 e3 ff ff       	call   1002c9 <cprintf>
        break;
  101f00:	e9 c4 00 00 00       	jmp    101fc9 <trap_dispatch+0x1c9>
//LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        // 如果原先保存在trapframe中的cs不是代表用户态的USER_CS
        if (tf->tf_cs != USER_CS) {
  101f05:	8b 45 08             	mov    0x8(%ebp),%eax
  101f08:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f0c:	83 f8 1b             	cmp    $0x1b,%eax
  101f0f:	0f 84 b0 00 00 00    	je     101fc5 <trap_dispatch+0x1c5>
            // 将保存在trapframe中的cs改成代表用户态的USER_CS
            tf->tf_cs = USER_CS;
  101f15:	8b 45 08             	mov    0x8(%ebp),%eax
  101f18:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            // 将其它的段选择子都修改为代表用户态的USER_DS，保证中断返回之后可以正常访问数据
            tf->tf_ds = USER_DS;
  101f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  101f21:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
            tf->tf_es = USER_DS;
  101f27:	8b 45 08             	mov    0x8(%ebp),%eax
  101f2a:	66 c7 40 28 23 00    	movw   $0x23,0x28(%eax)
            tf->tf_ss = USER_DS;
  101f30:	8b 45 08             	mov    0x8(%ebp),%eax
  101f33:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
            // 为了程序在CPL较低的情况下也能使用IO，需要将对应的IOPL位置改成用户态
            tf->tf_eflags |= FL_IOPL_MASK;
  101f39:	8b 45 08             	mov    0x8(%ebp),%eax
  101f3c:	8b 40 40             	mov    0x40(%eax),%eax
  101f3f:	0d 00 30 00 00       	or     $0x3000,%eax
  101f44:	89 c2                	mov    %eax,%edx
  101f46:	8b 45 08             	mov    0x8(%ebp),%eax
  101f49:	89 50 40             	mov    %edx,0x40(%eax)
        }
        break;
  101f4c:	eb 77                	jmp    101fc5 <trap_dispatch+0x1c5>
    case T_SWITCH_TOK:
        // 如果原先保存在trapframe中的cs不是代表内核态的KERNEL_CS
        if (tf->tf_cs != KERNEL_CS) {
  101f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  101f51:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f55:	83 f8 08             	cmp    $0x8,%eax
  101f58:	74 6e                	je     101fc8 <trap_dispatch+0x1c8>
            // 将保存在trapframe中的cs改成代表内核态的KERNEL_CS
            tf->tf_cs = KERNEL_CS;
  101f5a:	8b 45 08             	mov    0x8(%ebp),%eax
  101f5d:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            // 将其它的段选择子都修改为代表内核态的KERNEL_DS，保证中断返回之后可以正常访问数据
            tf->tf_ds = KERNEL_DS;
  101f63:	8b 45 08             	mov    0x8(%ebp),%eax
  101f66:	66 c7 40 2c 10 00    	movw   $0x10,0x2c(%eax)
            tf->tf_es = KERNEL_DS;
  101f6c:	8b 45 08             	mov    0x8(%ebp),%eax
  101f6f:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
            // 将调用IO所需权限降低，才能输出文本
            tf->tf_eflags |= 0x3000;
  101f75:	8b 45 08             	mov    0x8(%ebp),%eax
  101f78:	8b 40 40             	mov    0x40(%eax),%eax
  101f7b:	0d 00 30 00 00       	or     $0x3000,%eax
  101f80:	89 c2                	mov    %eax,%edx
  101f82:	8b 45 08             	mov    0x8(%ebp),%eax
  101f85:	89 50 40             	mov    %edx,0x40(%eax)
        }
        break;
  101f88:	eb 3e                	jmp    101fc8 <trap_dispatch+0x1c8>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101f8d:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f91:	83 e0 03             	and    $0x3,%eax
  101f94:	85 c0                	test   %eax,%eax
  101f96:	75 31                	jne    101fc9 <trap_dispatch+0x1c9>
            print_trapframe(tf);
  101f98:	8b 45 08             	mov    0x8(%ebp),%eax
  101f9b:	89 04 24             	mov    %eax,(%esp)
  101f9e:	e8 ec fb ff ff       	call   101b8f <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101fa3:	c7 44 24 08 55 67 10 	movl   $0x106755,0x8(%esp)
  101faa:	00 
  101fab:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  101fb2:	00 
  101fb3:	c7 04 24 71 67 10 00 	movl   $0x106771,(%esp)
  101fba:	e8 76 e4 ff ff       	call   100435 <__panic>
        break;
  101fbf:	90                   	nop
  101fc0:	eb 07                	jmp    101fc9 <trap_dispatch+0x1c9>
        break;
  101fc2:	90                   	nop
  101fc3:	eb 04                	jmp    101fc9 <trap_dispatch+0x1c9>
        break;
  101fc5:	90                   	nop
  101fc6:	eb 01                	jmp    101fc9 <trap_dispatch+0x1c9>
        break;
  101fc8:	90                   	nop
        }
    }
}
  101fc9:	90                   	nop
  101fca:	c9                   	leave  
  101fcb:	c3                   	ret    

00101fcc <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101fcc:	f3 0f 1e fb          	endbr32 
  101fd0:	55                   	push   %ebp
  101fd1:	89 e5                	mov    %esp,%ebp
  101fd3:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101fd6:	8b 45 08             	mov    0x8(%ebp),%eax
  101fd9:	89 04 24             	mov    %eax,(%esp)
  101fdc:	e8 1f fe ff ff       	call   101e00 <trap_dispatch>
}
  101fe1:	90                   	nop
  101fe2:	c9                   	leave  
  101fe3:	c3                   	ret    

00101fe4 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101fe4:	6a 00                	push   $0x0
  pushl $0
  101fe6:	6a 00                	push   $0x0
  jmp __alltraps
  101fe8:	e9 69 0a 00 00       	jmp    102a56 <__alltraps>

00101fed <vector1>:
.globl vector1
vector1:
  pushl $0
  101fed:	6a 00                	push   $0x0
  pushl $1
  101fef:	6a 01                	push   $0x1
  jmp __alltraps
  101ff1:	e9 60 0a 00 00       	jmp    102a56 <__alltraps>

00101ff6 <vector2>:
.globl vector2
vector2:
  pushl $0
  101ff6:	6a 00                	push   $0x0
  pushl $2
  101ff8:	6a 02                	push   $0x2
  jmp __alltraps
  101ffa:	e9 57 0a 00 00       	jmp    102a56 <__alltraps>

00101fff <vector3>:
.globl vector3
vector3:
  pushl $0
  101fff:	6a 00                	push   $0x0
  pushl $3
  102001:	6a 03                	push   $0x3
  jmp __alltraps
  102003:	e9 4e 0a 00 00       	jmp    102a56 <__alltraps>

00102008 <vector4>:
.globl vector4
vector4:
  pushl $0
  102008:	6a 00                	push   $0x0
  pushl $4
  10200a:	6a 04                	push   $0x4
  jmp __alltraps
  10200c:	e9 45 0a 00 00       	jmp    102a56 <__alltraps>

00102011 <vector5>:
.globl vector5
vector5:
  pushl $0
  102011:	6a 00                	push   $0x0
  pushl $5
  102013:	6a 05                	push   $0x5
  jmp __alltraps
  102015:	e9 3c 0a 00 00       	jmp    102a56 <__alltraps>

0010201a <vector6>:
.globl vector6
vector6:
  pushl $0
  10201a:	6a 00                	push   $0x0
  pushl $6
  10201c:	6a 06                	push   $0x6
  jmp __alltraps
  10201e:	e9 33 0a 00 00       	jmp    102a56 <__alltraps>

00102023 <vector7>:
.globl vector7
vector7:
  pushl $0
  102023:	6a 00                	push   $0x0
  pushl $7
  102025:	6a 07                	push   $0x7
  jmp __alltraps
  102027:	e9 2a 0a 00 00       	jmp    102a56 <__alltraps>

0010202c <vector8>:
.globl vector8
vector8:
  pushl $8
  10202c:	6a 08                	push   $0x8
  jmp __alltraps
  10202e:	e9 23 0a 00 00       	jmp    102a56 <__alltraps>

00102033 <vector9>:
.globl vector9
vector9:
  pushl $0
  102033:	6a 00                	push   $0x0
  pushl $9
  102035:	6a 09                	push   $0x9
  jmp __alltraps
  102037:	e9 1a 0a 00 00       	jmp    102a56 <__alltraps>

0010203c <vector10>:
.globl vector10
vector10:
  pushl $10
  10203c:	6a 0a                	push   $0xa
  jmp __alltraps
  10203e:	e9 13 0a 00 00       	jmp    102a56 <__alltraps>

00102043 <vector11>:
.globl vector11
vector11:
  pushl $11
  102043:	6a 0b                	push   $0xb
  jmp __alltraps
  102045:	e9 0c 0a 00 00       	jmp    102a56 <__alltraps>

0010204a <vector12>:
.globl vector12
vector12:
  pushl $12
  10204a:	6a 0c                	push   $0xc
  jmp __alltraps
  10204c:	e9 05 0a 00 00       	jmp    102a56 <__alltraps>

00102051 <vector13>:
.globl vector13
vector13:
  pushl $13
  102051:	6a 0d                	push   $0xd
  jmp __alltraps
  102053:	e9 fe 09 00 00       	jmp    102a56 <__alltraps>

00102058 <vector14>:
.globl vector14
vector14:
  pushl $14
  102058:	6a 0e                	push   $0xe
  jmp __alltraps
  10205a:	e9 f7 09 00 00       	jmp    102a56 <__alltraps>

0010205f <vector15>:
.globl vector15
vector15:
  pushl $0
  10205f:	6a 00                	push   $0x0
  pushl $15
  102061:	6a 0f                	push   $0xf
  jmp __alltraps
  102063:	e9 ee 09 00 00       	jmp    102a56 <__alltraps>

00102068 <vector16>:
.globl vector16
vector16:
  pushl $0
  102068:	6a 00                	push   $0x0
  pushl $16
  10206a:	6a 10                	push   $0x10
  jmp __alltraps
  10206c:	e9 e5 09 00 00       	jmp    102a56 <__alltraps>

00102071 <vector17>:
.globl vector17
vector17:
  pushl $17
  102071:	6a 11                	push   $0x11
  jmp __alltraps
  102073:	e9 de 09 00 00       	jmp    102a56 <__alltraps>

00102078 <vector18>:
.globl vector18
vector18:
  pushl $0
  102078:	6a 00                	push   $0x0
  pushl $18
  10207a:	6a 12                	push   $0x12
  jmp __alltraps
  10207c:	e9 d5 09 00 00       	jmp    102a56 <__alltraps>

00102081 <vector19>:
.globl vector19
vector19:
  pushl $0
  102081:	6a 00                	push   $0x0
  pushl $19
  102083:	6a 13                	push   $0x13
  jmp __alltraps
  102085:	e9 cc 09 00 00       	jmp    102a56 <__alltraps>

0010208a <vector20>:
.globl vector20
vector20:
  pushl $0
  10208a:	6a 00                	push   $0x0
  pushl $20
  10208c:	6a 14                	push   $0x14
  jmp __alltraps
  10208e:	e9 c3 09 00 00       	jmp    102a56 <__alltraps>

00102093 <vector21>:
.globl vector21
vector21:
  pushl $0
  102093:	6a 00                	push   $0x0
  pushl $21
  102095:	6a 15                	push   $0x15
  jmp __alltraps
  102097:	e9 ba 09 00 00       	jmp    102a56 <__alltraps>

0010209c <vector22>:
.globl vector22
vector22:
  pushl $0
  10209c:	6a 00                	push   $0x0
  pushl $22
  10209e:	6a 16                	push   $0x16
  jmp __alltraps
  1020a0:	e9 b1 09 00 00       	jmp    102a56 <__alltraps>

001020a5 <vector23>:
.globl vector23
vector23:
  pushl $0
  1020a5:	6a 00                	push   $0x0
  pushl $23
  1020a7:	6a 17                	push   $0x17
  jmp __alltraps
  1020a9:	e9 a8 09 00 00       	jmp    102a56 <__alltraps>

001020ae <vector24>:
.globl vector24
vector24:
  pushl $0
  1020ae:	6a 00                	push   $0x0
  pushl $24
  1020b0:	6a 18                	push   $0x18
  jmp __alltraps
  1020b2:	e9 9f 09 00 00       	jmp    102a56 <__alltraps>

001020b7 <vector25>:
.globl vector25
vector25:
  pushl $0
  1020b7:	6a 00                	push   $0x0
  pushl $25
  1020b9:	6a 19                	push   $0x19
  jmp __alltraps
  1020bb:	e9 96 09 00 00       	jmp    102a56 <__alltraps>

001020c0 <vector26>:
.globl vector26
vector26:
  pushl $0
  1020c0:	6a 00                	push   $0x0
  pushl $26
  1020c2:	6a 1a                	push   $0x1a
  jmp __alltraps
  1020c4:	e9 8d 09 00 00       	jmp    102a56 <__alltraps>

001020c9 <vector27>:
.globl vector27
vector27:
  pushl $0
  1020c9:	6a 00                	push   $0x0
  pushl $27
  1020cb:	6a 1b                	push   $0x1b
  jmp __alltraps
  1020cd:	e9 84 09 00 00       	jmp    102a56 <__alltraps>

001020d2 <vector28>:
.globl vector28
vector28:
  pushl $0
  1020d2:	6a 00                	push   $0x0
  pushl $28
  1020d4:	6a 1c                	push   $0x1c
  jmp __alltraps
  1020d6:	e9 7b 09 00 00       	jmp    102a56 <__alltraps>

001020db <vector29>:
.globl vector29
vector29:
  pushl $0
  1020db:	6a 00                	push   $0x0
  pushl $29
  1020dd:	6a 1d                	push   $0x1d
  jmp __alltraps
  1020df:	e9 72 09 00 00       	jmp    102a56 <__alltraps>

001020e4 <vector30>:
.globl vector30
vector30:
  pushl $0
  1020e4:	6a 00                	push   $0x0
  pushl $30
  1020e6:	6a 1e                	push   $0x1e
  jmp __alltraps
  1020e8:	e9 69 09 00 00       	jmp    102a56 <__alltraps>

001020ed <vector31>:
.globl vector31
vector31:
  pushl $0
  1020ed:	6a 00                	push   $0x0
  pushl $31
  1020ef:	6a 1f                	push   $0x1f
  jmp __alltraps
  1020f1:	e9 60 09 00 00       	jmp    102a56 <__alltraps>

001020f6 <vector32>:
.globl vector32
vector32:
  pushl $0
  1020f6:	6a 00                	push   $0x0
  pushl $32
  1020f8:	6a 20                	push   $0x20
  jmp __alltraps
  1020fa:	e9 57 09 00 00       	jmp    102a56 <__alltraps>

001020ff <vector33>:
.globl vector33
vector33:
  pushl $0
  1020ff:	6a 00                	push   $0x0
  pushl $33
  102101:	6a 21                	push   $0x21
  jmp __alltraps
  102103:	e9 4e 09 00 00       	jmp    102a56 <__alltraps>

00102108 <vector34>:
.globl vector34
vector34:
  pushl $0
  102108:	6a 00                	push   $0x0
  pushl $34
  10210a:	6a 22                	push   $0x22
  jmp __alltraps
  10210c:	e9 45 09 00 00       	jmp    102a56 <__alltraps>

00102111 <vector35>:
.globl vector35
vector35:
  pushl $0
  102111:	6a 00                	push   $0x0
  pushl $35
  102113:	6a 23                	push   $0x23
  jmp __alltraps
  102115:	e9 3c 09 00 00       	jmp    102a56 <__alltraps>

0010211a <vector36>:
.globl vector36
vector36:
  pushl $0
  10211a:	6a 00                	push   $0x0
  pushl $36
  10211c:	6a 24                	push   $0x24
  jmp __alltraps
  10211e:	e9 33 09 00 00       	jmp    102a56 <__alltraps>

00102123 <vector37>:
.globl vector37
vector37:
  pushl $0
  102123:	6a 00                	push   $0x0
  pushl $37
  102125:	6a 25                	push   $0x25
  jmp __alltraps
  102127:	e9 2a 09 00 00       	jmp    102a56 <__alltraps>

0010212c <vector38>:
.globl vector38
vector38:
  pushl $0
  10212c:	6a 00                	push   $0x0
  pushl $38
  10212e:	6a 26                	push   $0x26
  jmp __alltraps
  102130:	e9 21 09 00 00       	jmp    102a56 <__alltraps>

00102135 <vector39>:
.globl vector39
vector39:
  pushl $0
  102135:	6a 00                	push   $0x0
  pushl $39
  102137:	6a 27                	push   $0x27
  jmp __alltraps
  102139:	e9 18 09 00 00       	jmp    102a56 <__alltraps>

0010213e <vector40>:
.globl vector40
vector40:
  pushl $0
  10213e:	6a 00                	push   $0x0
  pushl $40
  102140:	6a 28                	push   $0x28
  jmp __alltraps
  102142:	e9 0f 09 00 00       	jmp    102a56 <__alltraps>

00102147 <vector41>:
.globl vector41
vector41:
  pushl $0
  102147:	6a 00                	push   $0x0
  pushl $41
  102149:	6a 29                	push   $0x29
  jmp __alltraps
  10214b:	e9 06 09 00 00       	jmp    102a56 <__alltraps>

00102150 <vector42>:
.globl vector42
vector42:
  pushl $0
  102150:	6a 00                	push   $0x0
  pushl $42
  102152:	6a 2a                	push   $0x2a
  jmp __alltraps
  102154:	e9 fd 08 00 00       	jmp    102a56 <__alltraps>

00102159 <vector43>:
.globl vector43
vector43:
  pushl $0
  102159:	6a 00                	push   $0x0
  pushl $43
  10215b:	6a 2b                	push   $0x2b
  jmp __alltraps
  10215d:	e9 f4 08 00 00       	jmp    102a56 <__alltraps>

00102162 <vector44>:
.globl vector44
vector44:
  pushl $0
  102162:	6a 00                	push   $0x0
  pushl $44
  102164:	6a 2c                	push   $0x2c
  jmp __alltraps
  102166:	e9 eb 08 00 00       	jmp    102a56 <__alltraps>

0010216b <vector45>:
.globl vector45
vector45:
  pushl $0
  10216b:	6a 00                	push   $0x0
  pushl $45
  10216d:	6a 2d                	push   $0x2d
  jmp __alltraps
  10216f:	e9 e2 08 00 00       	jmp    102a56 <__alltraps>

00102174 <vector46>:
.globl vector46
vector46:
  pushl $0
  102174:	6a 00                	push   $0x0
  pushl $46
  102176:	6a 2e                	push   $0x2e
  jmp __alltraps
  102178:	e9 d9 08 00 00       	jmp    102a56 <__alltraps>

0010217d <vector47>:
.globl vector47
vector47:
  pushl $0
  10217d:	6a 00                	push   $0x0
  pushl $47
  10217f:	6a 2f                	push   $0x2f
  jmp __alltraps
  102181:	e9 d0 08 00 00       	jmp    102a56 <__alltraps>

00102186 <vector48>:
.globl vector48
vector48:
  pushl $0
  102186:	6a 00                	push   $0x0
  pushl $48
  102188:	6a 30                	push   $0x30
  jmp __alltraps
  10218a:	e9 c7 08 00 00       	jmp    102a56 <__alltraps>

0010218f <vector49>:
.globl vector49
vector49:
  pushl $0
  10218f:	6a 00                	push   $0x0
  pushl $49
  102191:	6a 31                	push   $0x31
  jmp __alltraps
  102193:	e9 be 08 00 00       	jmp    102a56 <__alltraps>

00102198 <vector50>:
.globl vector50
vector50:
  pushl $0
  102198:	6a 00                	push   $0x0
  pushl $50
  10219a:	6a 32                	push   $0x32
  jmp __alltraps
  10219c:	e9 b5 08 00 00       	jmp    102a56 <__alltraps>

001021a1 <vector51>:
.globl vector51
vector51:
  pushl $0
  1021a1:	6a 00                	push   $0x0
  pushl $51
  1021a3:	6a 33                	push   $0x33
  jmp __alltraps
  1021a5:	e9 ac 08 00 00       	jmp    102a56 <__alltraps>

001021aa <vector52>:
.globl vector52
vector52:
  pushl $0
  1021aa:	6a 00                	push   $0x0
  pushl $52
  1021ac:	6a 34                	push   $0x34
  jmp __alltraps
  1021ae:	e9 a3 08 00 00       	jmp    102a56 <__alltraps>

001021b3 <vector53>:
.globl vector53
vector53:
  pushl $0
  1021b3:	6a 00                	push   $0x0
  pushl $53
  1021b5:	6a 35                	push   $0x35
  jmp __alltraps
  1021b7:	e9 9a 08 00 00       	jmp    102a56 <__alltraps>

001021bc <vector54>:
.globl vector54
vector54:
  pushl $0
  1021bc:	6a 00                	push   $0x0
  pushl $54
  1021be:	6a 36                	push   $0x36
  jmp __alltraps
  1021c0:	e9 91 08 00 00       	jmp    102a56 <__alltraps>

001021c5 <vector55>:
.globl vector55
vector55:
  pushl $0
  1021c5:	6a 00                	push   $0x0
  pushl $55
  1021c7:	6a 37                	push   $0x37
  jmp __alltraps
  1021c9:	e9 88 08 00 00       	jmp    102a56 <__alltraps>

001021ce <vector56>:
.globl vector56
vector56:
  pushl $0
  1021ce:	6a 00                	push   $0x0
  pushl $56
  1021d0:	6a 38                	push   $0x38
  jmp __alltraps
  1021d2:	e9 7f 08 00 00       	jmp    102a56 <__alltraps>

001021d7 <vector57>:
.globl vector57
vector57:
  pushl $0
  1021d7:	6a 00                	push   $0x0
  pushl $57
  1021d9:	6a 39                	push   $0x39
  jmp __alltraps
  1021db:	e9 76 08 00 00       	jmp    102a56 <__alltraps>

001021e0 <vector58>:
.globl vector58
vector58:
  pushl $0
  1021e0:	6a 00                	push   $0x0
  pushl $58
  1021e2:	6a 3a                	push   $0x3a
  jmp __alltraps
  1021e4:	e9 6d 08 00 00       	jmp    102a56 <__alltraps>

001021e9 <vector59>:
.globl vector59
vector59:
  pushl $0
  1021e9:	6a 00                	push   $0x0
  pushl $59
  1021eb:	6a 3b                	push   $0x3b
  jmp __alltraps
  1021ed:	e9 64 08 00 00       	jmp    102a56 <__alltraps>

001021f2 <vector60>:
.globl vector60
vector60:
  pushl $0
  1021f2:	6a 00                	push   $0x0
  pushl $60
  1021f4:	6a 3c                	push   $0x3c
  jmp __alltraps
  1021f6:	e9 5b 08 00 00       	jmp    102a56 <__alltraps>

001021fb <vector61>:
.globl vector61
vector61:
  pushl $0
  1021fb:	6a 00                	push   $0x0
  pushl $61
  1021fd:	6a 3d                	push   $0x3d
  jmp __alltraps
  1021ff:	e9 52 08 00 00       	jmp    102a56 <__alltraps>

00102204 <vector62>:
.globl vector62
vector62:
  pushl $0
  102204:	6a 00                	push   $0x0
  pushl $62
  102206:	6a 3e                	push   $0x3e
  jmp __alltraps
  102208:	e9 49 08 00 00       	jmp    102a56 <__alltraps>

0010220d <vector63>:
.globl vector63
vector63:
  pushl $0
  10220d:	6a 00                	push   $0x0
  pushl $63
  10220f:	6a 3f                	push   $0x3f
  jmp __alltraps
  102211:	e9 40 08 00 00       	jmp    102a56 <__alltraps>

00102216 <vector64>:
.globl vector64
vector64:
  pushl $0
  102216:	6a 00                	push   $0x0
  pushl $64
  102218:	6a 40                	push   $0x40
  jmp __alltraps
  10221a:	e9 37 08 00 00       	jmp    102a56 <__alltraps>

0010221f <vector65>:
.globl vector65
vector65:
  pushl $0
  10221f:	6a 00                	push   $0x0
  pushl $65
  102221:	6a 41                	push   $0x41
  jmp __alltraps
  102223:	e9 2e 08 00 00       	jmp    102a56 <__alltraps>

00102228 <vector66>:
.globl vector66
vector66:
  pushl $0
  102228:	6a 00                	push   $0x0
  pushl $66
  10222a:	6a 42                	push   $0x42
  jmp __alltraps
  10222c:	e9 25 08 00 00       	jmp    102a56 <__alltraps>

00102231 <vector67>:
.globl vector67
vector67:
  pushl $0
  102231:	6a 00                	push   $0x0
  pushl $67
  102233:	6a 43                	push   $0x43
  jmp __alltraps
  102235:	e9 1c 08 00 00       	jmp    102a56 <__alltraps>

0010223a <vector68>:
.globl vector68
vector68:
  pushl $0
  10223a:	6a 00                	push   $0x0
  pushl $68
  10223c:	6a 44                	push   $0x44
  jmp __alltraps
  10223e:	e9 13 08 00 00       	jmp    102a56 <__alltraps>

00102243 <vector69>:
.globl vector69
vector69:
  pushl $0
  102243:	6a 00                	push   $0x0
  pushl $69
  102245:	6a 45                	push   $0x45
  jmp __alltraps
  102247:	e9 0a 08 00 00       	jmp    102a56 <__alltraps>

0010224c <vector70>:
.globl vector70
vector70:
  pushl $0
  10224c:	6a 00                	push   $0x0
  pushl $70
  10224e:	6a 46                	push   $0x46
  jmp __alltraps
  102250:	e9 01 08 00 00       	jmp    102a56 <__alltraps>

00102255 <vector71>:
.globl vector71
vector71:
  pushl $0
  102255:	6a 00                	push   $0x0
  pushl $71
  102257:	6a 47                	push   $0x47
  jmp __alltraps
  102259:	e9 f8 07 00 00       	jmp    102a56 <__alltraps>

0010225e <vector72>:
.globl vector72
vector72:
  pushl $0
  10225e:	6a 00                	push   $0x0
  pushl $72
  102260:	6a 48                	push   $0x48
  jmp __alltraps
  102262:	e9 ef 07 00 00       	jmp    102a56 <__alltraps>

00102267 <vector73>:
.globl vector73
vector73:
  pushl $0
  102267:	6a 00                	push   $0x0
  pushl $73
  102269:	6a 49                	push   $0x49
  jmp __alltraps
  10226b:	e9 e6 07 00 00       	jmp    102a56 <__alltraps>

00102270 <vector74>:
.globl vector74
vector74:
  pushl $0
  102270:	6a 00                	push   $0x0
  pushl $74
  102272:	6a 4a                	push   $0x4a
  jmp __alltraps
  102274:	e9 dd 07 00 00       	jmp    102a56 <__alltraps>

00102279 <vector75>:
.globl vector75
vector75:
  pushl $0
  102279:	6a 00                	push   $0x0
  pushl $75
  10227b:	6a 4b                	push   $0x4b
  jmp __alltraps
  10227d:	e9 d4 07 00 00       	jmp    102a56 <__alltraps>

00102282 <vector76>:
.globl vector76
vector76:
  pushl $0
  102282:	6a 00                	push   $0x0
  pushl $76
  102284:	6a 4c                	push   $0x4c
  jmp __alltraps
  102286:	e9 cb 07 00 00       	jmp    102a56 <__alltraps>

0010228b <vector77>:
.globl vector77
vector77:
  pushl $0
  10228b:	6a 00                	push   $0x0
  pushl $77
  10228d:	6a 4d                	push   $0x4d
  jmp __alltraps
  10228f:	e9 c2 07 00 00       	jmp    102a56 <__alltraps>

00102294 <vector78>:
.globl vector78
vector78:
  pushl $0
  102294:	6a 00                	push   $0x0
  pushl $78
  102296:	6a 4e                	push   $0x4e
  jmp __alltraps
  102298:	e9 b9 07 00 00       	jmp    102a56 <__alltraps>

0010229d <vector79>:
.globl vector79
vector79:
  pushl $0
  10229d:	6a 00                	push   $0x0
  pushl $79
  10229f:	6a 4f                	push   $0x4f
  jmp __alltraps
  1022a1:	e9 b0 07 00 00       	jmp    102a56 <__alltraps>

001022a6 <vector80>:
.globl vector80
vector80:
  pushl $0
  1022a6:	6a 00                	push   $0x0
  pushl $80
  1022a8:	6a 50                	push   $0x50
  jmp __alltraps
  1022aa:	e9 a7 07 00 00       	jmp    102a56 <__alltraps>

001022af <vector81>:
.globl vector81
vector81:
  pushl $0
  1022af:	6a 00                	push   $0x0
  pushl $81
  1022b1:	6a 51                	push   $0x51
  jmp __alltraps
  1022b3:	e9 9e 07 00 00       	jmp    102a56 <__alltraps>

001022b8 <vector82>:
.globl vector82
vector82:
  pushl $0
  1022b8:	6a 00                	push   $0x0
  pushl $82
  1022ba:	6a 52                	push   $0x52
  jmp __alltraps
  1022bc:	e9 95 07 00 00       	jmp    102a56 <__alltraps>

001022c1 <vector83>:
.globl vector83
vector83:
  pushl $0
  1022c1:	6a 00                	push   $0x0
  pushl $83
  1022c3:	6a 53                	push   $0x53
  jmp __alltraps
  1022c5:	e9 8c 07 00 00       	jmp    102a56 <__alltraps>

001022ca <vector84>:
.globl vector84
vector84:
  pushl $0
  1022ca:	6a 00                	push   $0x0
  pushl $84
  1022cc:	6a 54                	push   $0x54
  jmp __alltraps
  1022ce:	e9 83 07 00 00       	jmp    102a56 <__alltraps>

001022d3 <vector85>:
.globl vector85
vector85:
  pushl $0
  1022d3:	6a 00                	push   $0x0
  pushl $85
  1022d5:	6a 55                	push   $0x55
  jmp __alltraps
  1022d7:	e9 7a 07 00 00       	jmp    102a56 <__alltraps>

001022dc <vector86>:
.globl vector86
vector86:
  pushl $0
  1022dc:	6a 00                	push   $0x0
  pushl $86
  1022de:	6a 56                	push   $0x56
  jmp __alltraps
  1022e0:	e9 71 07 00 00       	jmp    102a56 <__alltraps>

001022e5 <vector87>:
.globl vector87
vector87:
  pushl $0
  1022e5:	6a 00                	push   $0x0
  pushl $87
  1022e7:	6a 57                	push   $0x57
  jmp __alltraps
  1022e9:	e9 68 07 00 00       	jmp    102a56 <__alltraps>

001022ee <vector88>:
.globl vector88
vector88:
  pushl $0
  1022ee:	6a 00                	push   $0x0
  pushl $88
  1022f0:	6a 58                	push   $0x58
  jmp __alltraps
  1022f2:	e9 5f 07 00 00       	jmp    102a56 <__alltraps>

001022f7 <vector89>:
.globl vector89
vector89:
  pushl $0
  1022f7:	6a 00                	push   $0x0
  pushl $89
  1022f9:	6a 59                	push   $0x59
  jmp __alltraps
  1022fb:	e9 56 07 00 00       	jmp    102a56 <__alltraps>

00102300 <vector90>:
.globl vector90
vector90:
  pushl $0
  102300:	6a 00                	push   $0x0
  pushl $90
  102302:	6a 5a                	push   $0x5a
  jmp __alltraps
  102304:	e9 4d 07 00 00       	jmp    102a56 <__alltraps>

00102309 <vector91>:
.globl vector91
vector91:
  pushl $0
  102309:	6a 00                	push   $0x0
  pushl $91
  10230b:	6a 5b                	push   $0x5b
  jmp __alltraps
  10230d:	e9 44 07 00 00       	jmp    102a56 <__alltraps>

00102312 <vector92>:
.globl vector92
vector92:
  pushl $0
  102312:	6a 00                	push   $0x0
  pushl $92
  102314:	6a 5c                	push   $0x5c
  jmp __alltraps
  102316:	e9 3b 07 00 00       	jmp    102a56 <__alltraps>

0010231b <vector93>:
.globl vector93
vector93:
  pushl $0
  10231b:	6a 00                	push   $0x0
  pushl $93
  10231d:	6a 5d                	push   $0x5d
  jmp __alltraps
  10231f:	e9 32 07 00 00       	jmp    102a56 <__alltraps>

00102324 <vector94>:
.globl vector94
vector94:
  pushl $0
  102324:	6a 00                	push   $0x0
  pushl $94
  102326:	6a 5e                	push   $0x5e
  jmp __alltraps
  102328:	e9 29 07 00 00       	jmp    102a56 <__alltraps>

0010232d <vector95>:
.globl vector95
vector95:
  pushl $0
  10232d:	6a 00                	push   $0x0
  pushl $95
  10232f:	6a 5f                	push   $0x5f
  jmp __alltraps
  102331:	e9 20 07 00 00       	jmp    102a56 <__alltraps>

00102336 <vector96>:
.globl vector96
vector96:
  pushl $0
  102336:	6a 00                	push   $0x0
  pushl $96
  102338:	6a 60                	push   $0x60
  jmp __alltraps
  10233a:	e9 17 07 00 00       	jmp    102a56 <__alltraps>

0010233f <vector97>:
.globl vector97
vector97:
  pushl $0
  10233f:	6a 00                	push   $0x0
  pushl $97
  102341:	6a 61                	push   $0x61
  jmp __alltraps
  102343:	e9 0e 07 00 00       	jmp    102a56 <__alltraps>

00102348 <vector98>:
.globl vector98
vector98:
  pushl $0
  102348:	6a 00                	push   $0x0
  pushl $98
  10234a:	6a 62                	push   $0x62
  jmp __alltraps
  10234c:	e9 05 07 00 00       	jmp    102a56 <__alltraps>

00102351 <vector99>:
.globl vector99
vector99:
  pushl $0
  102351:	6a 00                	push   $0x0
  pushl $99
  102353:	6a 63                	push   $0x63
  jmp __alltraps
  102355:	e9 fc 06 00 00       	jmp    102a56 <__alltraps>

0010235a <vector100>:
.globl vector100
vector100:
  pushl $0
  10235a:	6a 00                	push   $0x0
  pushl $100
  10235c:	6a 64                	push   $0x64
  jmp __alltraps
  10235e:	e9 f3 06 00 00       	jmp    102a56 <__alltraps>

00102363 <vector101>:
.globl vector101
vector101:
  pushl $0
  102363:	6a 00                	push   $0x0
  pushl $101
  102365:	6a 65                	push   $0x65
  jmp __alltraps
  102367:	e9 ea 06 00 00       	jmp    102a56 <__alltraps>

0010236c <vector102>:
.globl vector102
vector102:
  pushl $0
  10236c:	6a 00                	push   $0x0
  pushl $102
  10236e:	6a 66                	push   $0x66
  jmp __alltraps
  102370:	e9 e1 06 00 00       	jmp    102a56 <__alltraps>

00102375 <vector103>:
.globl vector103
vector103:
  pushl $0
  102375:	6a 00                	push   $0x0
  pushl $103
  102377:	6a 67                	push   $0x67
  jmp __alltraps
  102379:	e9 d8 06 00 00       	jmp    102a56 <__alltraps>

0010237e <vector104>:
.globl vector104
vector104:
  pushl $0
  10237e:	6a 00                	push   $0x0
  pushl $104
  102380:	6a 68                	push   $0x68
  jmp __alltraps
  102382:	e9 cf 06 00 00       	jmp    102a56 <__alltraps>

00102387 <vector105>:
.globl vector105
vector105:
  pushl $0
  102387:	6a 00                	push   $0x0
  pushl $105
  102389:	6a 69                	push   $0x69
  jmp __alltraps
  10238b:	e9 c6 06 00 00       	jmp    102a56 <__alltraps>

00102390 <vector106>:
.globl vector106
vector106:
  pushl $0
  102390:	6a 00                	push   $0x0
  pushl $106
  102392:	6a 6a                	push   $0x6a
  jmp __alltraps
  102394:	e9 bd 06 00 00       	jmp    102a56 <__alltraps>

00102399 <vector107>:
.globl vector107
vector107:
  pushl $0
  102399:	6a 00                	push   $0x0
  pushl $107
  10239b:	6a 6b                	push   $0x6b
  jmp __alltraps
  10239d:	e9 b4 06 00 00       	jmp    102a56 <__alltraps>

001023a2 <vector108>:
.globl vector108
vector108:
  pushl $0
  1023a2:	6a 00                	push   $0x0
  pushl $108
  1023a4:	6a 6c                	push   $0x6c
  jmp __alltraps
  1023a6:	e9 ab 06 00 00       	jmp    102a56 <__alltraps>

001023ab <vector109>:
.globl vector109
vector109:
  pushl $0
  1023ab:	6a 00                	push   $0x0
  pushl $109
  1023ad:	6a 6d                	push   $0x6d
  jmp __alltraps
  1023af:	e9 a2 06 00 00       	jmp    102a56 <__alltraps>

001023b4 <vector110>:
.globl vector110
vector110:
  pushl $0
  1023b4:	6a 00                	push   $0x0
  pushl $110
  1023b6:	6a 6e                	push   $0x6e
  jmp __alltraps
  1023b8:	e9 99 06 00 00       	jmp    102a56 <__alltraps>

001023bd <vector111>:
.globl vector111
vector111:
  pushl $0
  1023bd:	6a 00                	push   $0x0
  pushl $111
  1023bf:	6a 6f                	push   $0x6f
  jmp __alltraps
  1023c1:	e9 90 06 00 00       	jmp    102a56 <__alltraps>

001023c6 <vector112>:
.globl vector112
vector112:
  pushl $0
  1023c6:	6a 00                	push   $0x0
  pushl $112
  1023c8:	6a 70                	push   $0x70
  jmp __alltraps
  1023ca:	e9 87 06 00 00       	jmp    102a56 <__alltraps>

001023cf <vector113>:
.globl vector113
vector113:
  pushl $0
  1023cf:	6a 00                	push   $0x0
  pushl $113
  1023d1:	6a 71                	push   $0x71
  jmp __alltraps
  1023d3:	e9 7e 06 00 00       	jmp    102a56 <__alltraps>

001023d8 <vector114>:
.globl vector114
vector114:
  pushl $0
  1023d8:	6a 00                	push   $0x0
  pushl $114
  1023da:	6a 72                	push   $0x72
  jmp __alltraps
  1023dc:	e9 75 06 00 00       	jmp    102a56 <__alltraps>

001023e1 <vector115>:
.globl vector115
vector115:
  pushl $0
  1023e1:	6a 00                	push   $0x0
  pushl $115
  1023e3:	6a 73                	push   $0x73
  jmp __alltraps
  1023e5:	e9 6c 06 00 00       	jmp    102a56 <__alltraps>

001023ea <vector116>:
.globl vector116
vector116:
  pushl $0
  1023ea:	6a 00                	push   $0x0
  pushl $116
  1023ec:	6a 74                	push   $0x74
  jmp __alltraps
  1023ee:	e9 63 06 00 00       	jmp    102a56 <__alltraps>

001023f3 <vector117>:
.globl vector117
vector117:
  pushl $0
  1023f3:	6a 00                	push   $0x0
  pushl $117
  1023f5:	6a 75                	push   $0x75
  jmp __alltraps
  1023f7:	e9 5a 06 00 00       	jmp    102a56 <__alltraps>

001023fc <vector118>:
.globl vector118
vector118:
  pushl $0
  1023fc:	6a 00                	push   $0x0
  pushl $118
  1023fe:	6a 76                	push   $0x76
  jmp __alltraps
  102400:	e9 51 06 00 00       	jmp    102a56 <__alltraps>

00102405 <vector119>:
.globl vector119
vector119:
  pushl $0
  102405:	6a 00                	push   $0x0
  pushl $119
  102407:	6a 77                	push   $0x77
  jmp __alltraps
  102409:	e9 48 06 00 00       	jmp    102a56 <__alltraps>

0010240e <vector120>:
.globl vector120
vector120:
  pushl $0
  10240e:	6a 00                	push   $0x0
  pushl $120
  102410:	6a 78                	push   $0x78
  jmp __alltraps
  102412:	e9 3f 06 00 00       	jmp    102a56 <__alltraps>

00102417 <vector121>:
.globl vector121
vector121:
  pushl $0
  102417:	6a 00                	push   $0x0
  pushl $121
  102419:	6a 79                	push   $0x79
  jmp __alltraps
  10241b:	e9 36 06 00 00       	jmp    102a56 <__alltraps>

00102420 <vector122>:
.globl vector122
vector122:
  pushl $0
  102420:	6a 00                	push   $0x0
  pushl $122
  102422:	6a 7a                	push   $0x7a
  jmp __alltraps
  102424:	e9 2d 06 00 00       	jmp    102a56 <__alltraps>

00102429 <vector123>:
.globl vector123
vector123:
  pushl $0
  102429:	6a 00                	push   $0x0
  pushl $123
  10242b:	6a 7b                	push   $0x7b
  jmp __alltraps
  10242d:	e9 24 06 00 00       	jmp    102a56 <__alltraps>

00102432 <vector124>:
.globl vector124
vector124:
  pushl $0
  102432:	6a 00                	push   $0x0
  pushl $124
  102434:	6a 7c                	push   $0x7c
  jmp __alltraps
  102436:	e9 1b 06 00 00       	jmp    102a56 <__alltraps>

0010243b <vector125>:
.globl vector125
vector125:
  pushl $0
  10243b:	6a 00                	push   $0x0
  pushl $125
  10243d:	6a 7d                	push   $0x7d
  jmp __alltraps
  10243f:	e9 12 06 00 00       	jmp    102a56 <__alltraps>

00102444 <vector126>:
.globl vector126
vector126:
  pushl $0
  102444:	6a 00                	push   $0x0
  pushl $126
  102446:	6a 7e                	push   $0x7e
  jmp __alltraps
  102448:	e9 09 06 00 00       	jmp    102a56 <__alltraps>

0010244d <vector127>:
.globl vector127
vector127:
  pushl $0
  10244d:	6a 00                	push   $0x0
  pushl $127
  10244f:	6a 7f                	push   $0x7f
  jmp __alltraps
  102451:	e9 00 06 00 00       	jmp    102a56 <__alltraps>

00102456 <vector128>:
.globl vector128
vector128:
  pushl $0
  102456:	6a 00                	push   $0x0
  pushl $128
  102458:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  10245d:	e9 f4 05 00 00       	jmp    102a56 <__alltraps>

00102462 <vector129>:
.globl vector129
vector129:
  pushl $0
  102462:	6a 00                	push   $0x0
  pushl $129
  102464:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102469:	e9 e8 05 00 00       	jmp    102a56 <__alltraps>

0010246e <vector130>:
.globl vector130
vector130:
  pushl $0
  10246e:	6a 00                	push   $0x0
  pushl $130
  102470:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102475:	e9 dc 05 00 00       	jmp    102a56 <__alltraps>

0010247a <vector131>:
.globl vector131
vector131:
  pushl $0
  10247a:	6a 00                	push   $0x0
  pushl $131
  10247c:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102481:	e9 d0 05 00 00       	jmp    102a56 <__alltraps>

00102486 <vector132>:
.globl vector132
vector132:
  pushl $0
  102486:	6a 00                	push   $0x0
  pushl $132
  102488:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10248d:	e9 c4 05 00 00       	jmp    102a56 <__alltraps>

00102492 <vector133>:
.globl vector133
vector133:
  pushl $0
  102492:	6a 00                	push   $0x0
  pushl $133
  102494:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102499:	e9 b8 05 00 00       	jmp    102a56 <__alltraps>

0010249e <vector134>:
.globl vector134
vector134:
  pushl $0
  10249e:	6a 00                	push   $0x0
  pushl $134
  1024a0:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1024a5:	e9 ac 05 00 00       	jmp    102a56 <__alltraps>

001024aa <vector135>:
.globl vector135
vector135:
  pushl $0
  1024aa:	6a 00                	push   $0x0
  pushl $135
  1024ac:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1024b1:	e9 a0 05 00 00       	jmp    102a56 <__alltraps>

001024b6 <vector136>:
.globl vector136
vector136:
  pushl $0
  1024b6:	6a 00                	push   $0x0
  pushl $136
  1024b8:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1024bd:	e9 94 05 00 00       	jmp    102a56 <__alltraps>

001024c2 <vector137>:
.globl vector137
vector137:
  pushl $0
  1024c2:	6a 00                	push   $0x0
  pushl $137
  1024c4:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1024c9:	e9 88 05 00 00       	jmp    102a56 <__alltraps>

001024ce <vector138>:
.globl vector138
vector138:
  pushl $0
  1024ce:	6a 00                	push   $0x0
  pushl $138
  1024d0:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1024d5:	e9 7c 05 00 00       	jmp    102a56 <__alltraps>

001024da <vector139>:
.globl vector139
vector139:
  pushl $0
  1024da:	6a 00                	push   $0x0
  pushl $139
  1024dc:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1024e1:	e9 70 05 00 00       	jmp    102a56 <__alltraps>

001024e6 <vector140>:
.globl vector140
vector140:
  pushl $0
  1024e6:	6a 00                	push   $0x0
  pushl $140
  1024e8:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1024ed:	e9 64 05 00 00       	jmp    102a56 <__alltraps>

001024f2 <vector141>:
.globl vector141
vector141:
  pushl $0
  1024f2:	6a 00                	push   $0x0
  pushl $141
  1024f4:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1024f9:	e9 58 05 00 00       	jmp    102a56 <__alltraps>

001024fe <vector142>:
.globl vector142
vector142:
  pushl $0
  1024fe:	6a 00                	push   $0x0
  pushl $142
  102500:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102505:	e9 4c 05 00 00       	jmp    102a56 <__alltraps>

0010250a <vector143>:
.globl vector143
vector143:
  pushl $0
  10250a:	6a 00                	push   $0x0
  pushl $143
  10250c:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102511:	e9 40 05 00 00       	jmp    102a56 <__alltraps>

00102516 <vector144>:
.globl vector144
vector144:
  pushl $0
  102516:	6a 00                	push   $0x0
  pushl $144
  102518:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  10251d:	e9 34 05 00 00       	jmp    102a56 <__alltraps>

00102522 <vector145>:
.globl vector145
vector145:
  pushl $0
  102522:	6a 00                	push   $0x0
  pushl $145
  102524:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102529:	e9 28 05 00 00       	jmp    102a56 <__alltraps>

0010252e <vector146>:
.globl vector146
vector146:
  pushl $0
  10252e:	6a 00                	push   $0x0
  pushl $146
  102530:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102535:	e9 1c 05 00 00       	jmp    102a56 <__alltraps>

0010253a <vector147>:
.globl vector147
vector147:
  pushl $0
  10253a:	6a 00                	push   $0x0
  pushl $147
  10253c:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102541:	e9 10 05 00 00       	jmp    102a56 <__alltraps>

00102546 <vector148>:
.globl vector148
vector148:
  pushl $0
  102546:	6a 00                	push   $0x0
  pushl $148
  102548:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  10254d:	e9 04 05 00 00       	jmp    102a56 <__alltraps>

00102552 <vector149>:
.globl vector149
vector149:
  pushl $0
  102552:	6a 00                	push   $0x0
  pushl $149
  102554:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102559:	e9 f8 04 00 00       	jmp    102a56 <__alltraps>

0010255e <vector150>:
.globl vector150
vector150:
  pushl $0
  10255e:	6a 00                	push   $0x0
  pushl $150
  102560:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102565:	e9 ec 04 00 00       	jmp    102a56 <__alltraps>

0010256a <vector151>:
.globl vector151
vector151:
  pushl $0
  10256a:	6a 00                	push   $0x0
  pushl $151
  10256c:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102571:	e9 e0 04 00 00       	jmp    102a56 <__alltraps>

00102576 <vector152>:
.globl vector152
vector152:
  pushl $0
  102576:	6a 00                	push   $0x0
  pushl $152
  102578:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10257d:	e9 d4 04 00 00       	jmp    102a56 <__alltraps>

00102582 <vector153>:
.globl vector153
vector153:
  pushl $0
  102582:	6a 00                	push   $0x0
  pushl $153
  102584:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102589:	e9 c8 04 00 00       	jmp    102a56 <__alltraps>

0010258e <vector154>:
.globl vector154
vector154:
  pushl $0
  10258e:	6a 00                	push   $0x0
  pushl $154
  102590:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102595:	e9 bc 04 00 00       	jmp    102a56 <__alltraps>

0010259a <vector155>:
.globl vector155
vector155:
  pushl $0
  10259a:	6a 00                	push   $0x0
  pushl $155
  10259c:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1025a1:	e9 b0 04 00 00       	jmp    102a56 <__alltraps>

001025a6 <vector156>:
.globl vector156
vector156:
  pushl $0
  1025a6:	6a 00                	push   $0x0
  pushl $156
  1025a8:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1025ad:	e9 a4 04 00 00       	jmp    102a56 <__alltraps>

001025b2 <vector157>:
.globl vector157
vector157:
  pushl $0
  1025b2:	6a 00                	push   $0x0
  pushl $157
  1025b4:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1025b9:	e9 98 04 00 00       	jmp    102a56 <__alltraps>

001025be <vector158>:
.globl vector158
vector158:
  pushl $0
  1025be:	6a 00                	push   $0x0
  pushl $158
  1025c0:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1025c5:	e9 8c 04 00 00       	jmp    102a56 <__alltraps>

001025ca <vector159>:
.globl vector159
vector159:
  pushl $0
  1025ca:	6a 00                	push   $0x0
  pushl $159
  1025cc:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1025d1:	e9 80 04 00 00       	jmp    102a56 <__alltraps>

001025d6 <vector160>:
.globl vector160
vector160:
  pushl $0
  1025d6:	6a 00                	push   $0x0
  pushl $160
  1025d8:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1025dd:	e9 74 04 00 00       	jmp    102a56 <__alltraps>

001025e2 <vector161>:
.globl vector161
vector161:
  pushl $0
  1025e2:	6a 00                	push   $0x0
  pushl $161
  1025e4:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1025e9:	e9 68 04 00 00       	jmp    102a56 <__alltraps>

001025ee <vector162>:
.globl vector162
vector162:
  pushl $0
  1025ee:	6a 00                	push   $0x0
  pushl $162
  1025f0:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1025f5:	e9 5c 04 00 00       	jmp    102a56 <__alltraps>

001025fa <vector163>:
.globl vector163
vector163:
  pushl $0
  1025fa:	6a 00                	push   $0x0
  pushl $163
  1025fc:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102601:	e9 50 04 00 00       	jmp    102a56 <__alltraps>

00102606 <vector164>:
.globl vector164
vector164:
  pushl $0
  102606:	6a 00                	push   $0x0
  pushl $164
  102608:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10260d:	e9 44 04 00 00       	jmp    102a56 <__alltraps>

00102612 <vector165>:
.globl vector165
vector165:
  pushl $0
  102612:	6a 00                	push   $0x0
  pushl $165
  102614:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102619:	e9 38 04 00 00       	jmp    102a56 <__alltraps>

0010261e <vector166>:
.globl vector166
vector166:
  pushl $0
  10261e:	6a 00                	push   $0x0
  pushl $166
  102620:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102625:	e9 2c 04 00 00       	jmp    102a56 <__alltraps>

0010262a <vector167>:
.globl vector167
vector167:
  pushl $0
  10262a:	6a 00                	push   $0x0
  pushl $167
  10262c:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102631:	e9 20 04 00 00       	jmp    102a56 <__alltraps>

00102636 <vector168>:
.globl vector168
vector168:
  pushl $0
  102636:	6a 00                	push   $0x0
  pushl $168
  102638:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  10263d:	e9 14 04 00 00       	jmp    102a56 <__alltraps>

00102642 <vector169>:
.globl vector169
vector169:
  pushl $0
  102642:	6a 00                	push   $0x0
  pushl $169
  102644:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102649:	e9 08 04 00 00       	jmp    102a56 <__alltraps>

0010264e <vector170>:
.globl vector170
vector170:
  pushl $0
  10264e:	6a 00                	push   $0x0
  pushl $170
  102650:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102655:	e9 fc 03 00 00       	jmp    102a56 <__alltraps>

0010265a <vector171>:
.globl vector171
vector171:
  pushl $0
  10265a:	6a 00                	push   $0x0
  pushl $171
  10265c:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102661:	e9 f0 03 00 00       	jmp    102a56 <__alltraps>

00102666 <vector172>:
.globl vector172
vector172:
  pushl $0
  102666:	6a 00                	push   $0x0
  pushl $172
  102668:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  10266d:	e9 e4 03 00 00       	jmp    102a56 <__alltraps>

00102672 <vector173>:
.globl vector173
vector173:
  pushl $0
  102672:	6a 00                	push   $0x0
  pushl $173
  102674:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102679:	e9 d8 03 00 00       	jmp    102a56 <__alltraps>

0010267e <vector174>:
.globl vector174
vector174:
  pushl $0
  10267e:	6a 00                	push   $0x0
  pushl $174
  102680:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102685:	e9 cc 03 00 00       	jmp    102a56 <__alltraps>

0010268a <vector175>:
.globl vector175
vector175:
  pushl $0
  10268a:	6a 00                	push   $0x0
  pushl $175
  10268c:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102691:	e9 c0 03 00 00       	jmp    102a56 <__alltraps>

00102696 <vector176>:
.globl vector176
vector176:
  pushl $0
  102696:	6a 00                	push   $0x0
  pushl $176
  102698:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10269d:	e9 b4 03 00 00       	jmp    102a56 <__alltraps>

001026a2 <vector177>:
.globl vector177
vector177:
  pushl $0
  1026a2:	6a 00                	push   $0x0
  pushl $177
  1026a4:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1026a9:	e9 a8 03 00 00       	jmp    102a56 <__alltraps>

001026ae <vector178>:
.globl vector178
vector178:
  pushl $0
  1026ae:	6a 00                	push   $0x0
  pushl $178
  1026b0:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1026b5:	e9 9c 03 00 00       	jmp    102a56 <__alltraps>

001026ba <vector179>:
.globl vector179
vector179:
  pushl $0
  1026ba:	6a 00                	push   $0x0
  pushl $179
  1026bc:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1026c1:	e9 90 03 00 00       	jmp    102a56 <__alltraps>

001026c6 <vector180>:
.globl vector180
vector180:
  pushl $0
  1026c6:	6a 00                	push   $0x0
  pushl $180
  1026c8:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1026cd:	e9 84 03 00 00       	jmp    102a56 <__alltraps>

001026d2 <vector181>:
.globl vector181
vector181:
  pushl $0
  1026d2:	6a 00                	push   $0x0
  pushl $181
  1026d4:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1026d9:	e9 78 03 00 00       	jmp    102a56 <__alltraps>

001026de <vector182>:
.globl vector182
vector182:
  pushl $0
  1026de:	6a 00                	push   $0x0
  pushl $182
  1026e0:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1026e5:	e9 6c 03 00 00       	jmp    102a56 <__alltraps>

001026ea <vector183>:
.globl vector183
vector183:
  pushl $0
  1026ea:	6a 00                	push   $0x0
  pushl $183
  1026ec:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1026f1:	e9 60 03 00 00       	jmp    102a56 <__alltraps>

001026f6 <vector184>:
.globl vector184
vector184:
  pushl $0
  1026f6:	6a 00                	push   $0x0
  pushl $184
  1026f8:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1026fd:	e9 54 03 00 00       	jmp    102a56 <__alltraps>

00102702 <vector185>:
.globl vector185
vector185:
  pushl $0
  102702:	6a 00                	push   $0x0
  pushl $185
  102704:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102709:	e9 48 03 00 00       	jmp    102a56 <__alltraps>

0010270e <vector186>:
.globl vector186
vector186:
  pushl $0
  10270e:	6a 00                	push   $0x0
  pushl $186
  102710:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102715:	e9 3c 03 00 00       	jmp    102a56 <__alltraps>

0010271a <vector187>:
.globl vector187
vector187:
  pushl $0
  10271a:	6a 00                	push   $0x0
  pushl $187
  10271c:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102721:	e9 30 03 00 00       	jmp    102a56 <__alltraps>

00102726 <vector188>:
.globl vector188
vector188:
  pushl $0
  102726:	6a 00                	push   $0x0
  pushl $188
  102728:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  10272d:	e9 24 03 00 00       	jmp    102a56 <__alltraps>

00102732 <vector189>:
.globl vector189
vector189:
  pushl $0
  102732:	6a 00                	push   $0x0
  pushl $189
  102734:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102739:	e9 18 03 00 00       	jmp    102a56 <__alltraps>

0010273e <vector190>:
.globl vector190
vector190:
  pushl $0
  10273e:	6a 00                	push   $0x0
  pushl $190
  102740:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102745:	e9 0c 03 00 00       	jmp    102a56 <__alltraps>

0010274a <vector191>:
.globl vector191
vector191:
  pushl $0
  10274a:	6a 00                	push   $0x0
  pushl $191
  10274c:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102751:	e9 00 03 00 00       	jmp    102a56 <__alltraps>

00102756 <vector192>:
.globl vector192
vector192:
  pushl $0
  102756:	6a 00                	push   $0x0
  pushl $192
  102758:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  10275d:	e9 f4 02 00 00       	jmp    102a56 <__alltraps>

00102762 <vector193>:
.globl vector193
vector193:
  pushl $0
  102762:	6a 00                	push   $0x0
  pushl $193
  102764:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102769:	e9 e8 02 00 00       	jmp    102a56 <__alltraps>

0010276e <vector194>:
.globl vector194
vector194:
  pushl $0
  10276e:	6a 00                	push   $0x0
  pushl $194
  102770:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102775:	e9 dc 02 00 00       	jmp    102a56 <__alltraps>

0010277a <vector195>:
.globl vector195
vector195:
  pushl $0
  10277a:	6a 00                	push   $0x0
  pushl $195
  10277c:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102781:	e9 d0 02 00 00       	jmp    102a56 <__alltraps>

00102786 <vector196>:
.globl vector196
vector196:
  pushl $0
  102786:	6a 00                	push   $0x0
  pushl $196
  102788:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10278d:	e9 c4 02 00 00       	jmp    102a56 <__alltraps>

00102792 <vector197>:
.globl vector197
vector197:
  pushl $0
  102792:	6a 00                	push   $0x0
  pushl $197
  102794:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102799:	e9 b8 02 00 00       	jmp    102a56 <__alltraps>

0010279e <vector198>:
.globl vector198
vector198:
  pushl $0
  10279e:	6a 00                	push   $0x0
  pushl $198
  1027a0:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1027a5:	e9 ac 02 00 00       	jmp    102a56 <__alltraps>

001027aa <vector199>:
.globl vector199
vector199:
  pushl $0
  1027aa:	6a 00                	push   $0x0
  pushl $199
  1027ac:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1027b1:	e9 a0 02 00 00       	jmp    102a56 <__alltraps>

001027b6 <vector200>:
.globl vector200
vector200:
  pushl $0
  1027b6:	6a 00                	push   $0x0
  pushl $200
  1027b8:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1027bd:	e9 94 02 00 00       	jmp    102a56 <__alltraps>

001027c2 <vector201>:
.globl vector201
vector201:
  pushl $0
  1027c2:	6a 00                	push   $0x0
  pushl $201
  1027c4:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1027c9:	e9 88 02 00 00       	jmp    102a56 <__alltraps>

001027ce <vector202>:
.globl vector202
vector202:
  pushl $0
  1027ce:	6a 00                	push   $0x0
  pushl $202
  1027d0:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1027d5:	e9 7c 02 00 00       	jmp    102a56 <__alltraps>

001027da <vector203>:
.globl vector203
vector203:
  pushl $0
  1027da:	6a 00                	push   $0x0
  pushl $203
  1027dc:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1027e1:	e9 70 02 00 00       	jmp    102a56 <__alltraps>

001027e6 <vector204>:
.globl vector204
vector204:
  pushl $0
  1027e6:	6a 00                	push   $0x0
  pushl $204
  1027e8:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1027ed:	e9 64 02 00 00       	jmp    102a56 <__alltraps>

001027f2 <vector205>:
.globl vector205
vector205:
  pushl $0
  1027f2:	6a 00                	push   $0x0
  pushl $205
  1027f4:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1027f9:	e9 58 02 00 00       	jmp    102a56 <__alltraps>

001027fe <vector206>:
.globl vector206
vector206:
  pushl $0
  1027fe:	6a 00                	push   $0x0
  pushl $206
  102800:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102805:	e9 4c 02 00 00       	jmp    102a56 <__alltraps>

0010280a <vector207>:
.globl vector207
vector207:
  pushl $0
  10280a:	6a 00                	push   $0x0
  pushl $207
  10280c:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102811:	e9 40 02 00 00       	jmp    102a56 <__alltraps>

00102816 <vector208>:
.globl vector208
vector208:
  pushl $0
  102816:	6a 00                	push   $0x0
  pushl $208
  102818:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  10281d:	e9 34 02 00 00       	jmp    102a56 <__alltraps>

00102822 <vector209>:
.globl vector209
vector209:
  pushl $0
  102822:	6a 00                	push   $0x0
  pushl $209
  102824:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102829:	e9 28 02 00 00       	jmp    102a56 <__alltraps>

0010282e <vector210>:
.globl vector210
vector210:
  pushl $0
  10282e:	6a 00                	push   $0x0
  pushl $210
  102830:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102835:	e9 1c 02 00 00       	jmp    102a56 <__alltraps>

0010283a <vector211>:
.globl vector211
vector211:
  pushl $0
  10283a:	6a 00                	push   $0x0
  pushl $211
  10283c:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102841:	e9 10 02 00 00       	jmp    102a56 <__alltraps>

00102846 <vector212>:
.globl vector212
vector212:
  pushl $0
  102846:	6a 00                	push   $0x0
  pushl $212
  102848:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  10284d:	e9 04 02 00 00       	jmp    102a56 <__alltraps>

00102852 <vector213>:
.globl vector213
vector213:
  pushl $0
  102852:	6a 00                	push   $0x0
  pushl $213
  102854:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102859:	e9 f8 01 00 00       	jmp    102a56 <__alltraps>

0010285e <vector214>:
.globl vector214
vector214:
  pushl $0
  10285e:	6a 00                	push   $0x0
  pushl $214
  102860:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102865:	e9 ec 01 00 00       	jmp    102a56 <__alltraps>

0010286a <vector215>:
.globl vector215
vector215:
  pushl $0
  10286a:	6a 00                	push   $0x0
  pushl $215
  10286c:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102871:	e9 e0 01 00 00       	jmp    102a56 <__alltraps>

00102876 <vector216>:
.globl vector216
vector216:
  pushl $0
  102876:	6a 00                	push   $0x0
  pushl $216
  102878:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10287d:	e9 d4 01 00 00       	jmp    102a56 <__alltraps>

00102882 <vector217>:
.globl vector217
vector217:
  pushl $0
  102882:	6a 00                	push   $0x0
  pushl $217
  102884:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102889:	e9 c8 01 00 00       	jmp    102a56 <__alltraps>

0010288e <vector218>:
.globl vector218
vector218:
  pushl $0
  10288e:	6a 00                	push   $0x0
  pushl $218
  102890:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102895:	e9 bc 01 00 00       	jmp    102a56 <__alltraps>

0010289a <vector219>:
.globl vector219
vector219:
  pushl $0
  10289a:	6a 00                	push   $0x0
  pushl $219
  10289c:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1028a1:	e9 b0 01 00 00       	jmp    102a56 <__alltraps>

001028a6 <vector220>:
.globl vector220
vector220:
  pushl $0
  1028a6:	6a 00                	push   $0x0
  pushl $220
  1028a8:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1028ad:	e9 a4 01 00 00       	jmp    102a56 <__alltraps>

001028b2 <vector221>:
.globl vector221
vector221:
  pushl $0
  1028b2:	6a 00                	push   $0x0
  pushl $221
  1028b4:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1028b9:	e9 98 01 00 00       	jmp    102a56 <__alltraps>

001028be <vector222>:
.globl vector222
vector222:
  pushl $0
  1028be:	6a 00                	push   $0x0
  pushl $222
  1028c0:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1028c5:	e9 8c 01 00 00       	jmp    102a56 <__alltraps>

001028ca <vector223>:
.globl vector223
vector223:
  pushl $0
  1028ca:	6a 00                	push   $0x0
  pushl $223
  1028cc:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1028d1:	e9 80 01 00 00       	jmp    102a56 <__alltraps>

001028d6 <vector224>:
.globl vector224
vector224:
  pushl $0
  1028d6:	6a 00                	push   $0x0
  pushl $224
  1028d8:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1028dd:	e9 74 01 00 00       	jmp    102a56 <__alltraps>

001028e2 <vector225>:
.globl vector225
vector225:
  pushl $0
  1028e2:	6a 00                	push   $0x0
  pushl $225
  1028e4:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1028e9:	e9 68 01 00 00       	jmp    102a56 <__alltraps>

001028ee <vector226>:
.globl vector226
vector226:
  pushl $0
  1028ee:	6a 00                	push   $0x0
  pushl $226
  1028f0:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1028f5:	e9 5c 01 00 00       	jmp    102a56 <__alltraps>

001028fa <vector227>:
.globl vector227
vector227:
  pushl $0
  1028fa:	6a 00                	push   $0x0
  pushl $227
  1028fc:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102901:	e9 50 01 00 00       	jmp    102a56 <__alltraps>

00102906 <vector228>:
.globl vector228
vector228:
  pushl $0
  102906:	6a 00                	push   $0x0
  pushl $228
  102908:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  10290d:	e9 44 01 00 00       	jmp    102a56 <__alltraps>

00102912 <vector229>:
.globl vector229
vector229:
  pushl $0
  102912:	6a 00                	push   $0x0
  pushl $229
  102914:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102919:	e9 38 01 00 00       	jmp    102a56 <__alltraps>

0010291e <vector230>:
.globl vector230
vector230:
  pushl $0
  10291e:	6a 00                	push   $0x0
  pushl $230
  102920:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102925:	e9 2c 01 00 00       	jmp    102a56 <__alltraps>

0010292a <vector231>:
.globl vector231
vector231:
  pushl $0
  10292a:	6a 00                	push   $0x0
  pushl $231
  10292c:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102931:	e9 20 01 00 00       	jmp    102a56 <__alltraps>

00102936 <vector232>:
.globl vector232
vector232:
  pushl $0
  102936:	6a 00                	push   $0x0
  pushl $232
  102938:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  10293d:	e9 14 01 00 00       	jmp    102a56 <__alltraps>

00102942 <vector233>:
.globl vector233
vector233:
  pushl $0
  102942:	6a 00                	push   $0x0
  pushl $233
  102944:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102949:	e9 08 01 00 00       	jmp    102a56 <__alltraps>

0010294e <vector234>:
.globl vector234
vector234:
  pushl $0
  10294e:	6a 00                	push   $0x0
  pushl $234
  102950:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102955:	e9 fc 00 00 00       	jmp    102a56 <__alltraps>

0010295a <vector235>:
.globl vector235
vector235:
  pushl $0
  10295a:	6a 00                	push   $0x0
  pushl $235
  10295c:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102961:	e9 f0 00 00 00       	jmp    102a56 <__alltraps>

00102966 <vector236>:
.globl vector236
vector236:
  pushl $0
  102966:	6a 00                	push   $0x0
  pushl $236
  102968:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  10296d:	e9 e4 00 00 00       	jmp    102a56 <__alltraps>

00102972 <vector237>:
.globl vector237
vector237:
  pushl $0
  102972:	6a 00                	push   $0x0
  pushl $237
  102974:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102979:	e9 d8 00 00 00       	jmp    102a56 <__alltraps>

0010297e <vector238>:
.globl vector238
vector238:
  pushl $0
  10297e:	6a 00                	push   $0x0
  pushl $238
  102980:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102985:	e9 cc 00 00 00       	jmp    102a56 <__alltraps>

0010298a <vector239>:
.globl vector239
vector239:
  pushl $0
  10298a:	6a 00                	push   $0x0
  pushl $239
  10298c:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102991:	e9 c0 00 00 00       	jmp    102a56 <__alltraps>

00102996 <vector240>:
.globl vector240
vector240:
  pushl $0
  102996:	6a 00                	push   $0x0
  pushl $240
  102998:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  10299d:	e9 b4 00 00 00       	jmp    102a56 <__alltraps>

001029a2 <vector241>:
.globl vector241
vector241:
  pushl $0
  1029a2:	6a 00                	push   $0x0
  pushl $241
  1029a4:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1029a9:	e9 a8 00 00 00       	jmp    102a56 <__alltraps>

001029ae <vector242>:
.globl vector242
vector242:
  pushl $0
  1029ae:	6a 00                	push   $0x0
  pushl $242
  1029b0:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1029b5:	e9 9c 00 00 00       	jmp    102a56 <__alltraps>

001029ba <vector243>:
.globl vector243
vector243:
  pushl $0
  1029ba:	6a 00                	push   $0x0
  pushl $243
  1029bc:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1029c1:	e9 90 00 00 00       	jmp    102a56 <__alltraps>

001029c6 <vector244>:
.globl vector244
vector244:
  pushl $0
  1029c6:	6a 00                	push   $0x0
  pushl $244
  1029c8:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1029cd:	e9 84 00 00 00       	jmp    102a56 <__alltraps>

001029d2 <vector245>:
.globl vector245
vector245:
  pushl $0
  1029d2:	6a 00                	push   $0x0
  pushl $245
  1029d4:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1029d9:	e9 78 00 00 00       	jmp    102a56 <__alltraps>

001029de <vector246>:
.globl vector246
vector246:
  pushl $0
  1029de:	6a 00                	push   $0x0
  pushl $246
  1029e0:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1029e5:	e9 6c 00 00 00       	jmp    102a56 <__alltraps>

001029ea <vector247>:
.globl vector247
vector247:
  pushl $0
  1029ea:	6a 00                	push   $0x0
  pushl $247
  1029ec:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1029f1:	e9 60 00 00 00       	jmp    102a56 <__alltraps>

001029f6 <vector248>:
.globl vector248
vector248:
  pushl $0
  1029f6:	6a 00                	push   $0x0
  pushl $248
  1029f8:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1029fd:	e9 54 00 00 00       	jmp    102a56 <__alltraps>

00102a02 <vector249>:
.globl vector249
vector249:
  pushl $0
  102a02:	6a 00                	push   $0x0
  pushl $249
  102a04:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102a09:	e9 48 00 00 00       	jmp    102a56 <__alltraps>

00102a0e <vector250>:
.globl vector250
vector250:
  pushl $0
  102a0e:	6a 00                	push   $0x0
  pushl $250
  102a10:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102a15:	e9 3c 00 00 00       	jmp    102a56 <__alltraps>

00102a1a <vector251>:
.globl vector251
vector251:
  pushl $0
  102a1a:	6a 00                	push   $0x0
  pushl $251
  102a1c:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102a21:	e9 30 00 00 00       	jmp    102a56 <__alltraps>

00102a26 <vector252>:
.globl vector252
vector252:
  pushl $0
  102a26:	6a 00                	push   $0x0
  pushl $252
  102a28:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102a2d:	e9 24 00 00 00       	jmp    102a56 <__alltraps>

00102a32 <vector253>:
.globl vector253
vector253:
  pushl $0
  102a32:	6a 00                	push   $0x0
  pushl $253
  102a34:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102a39:	e9 18 00 00 00       	jmp    102a56 <__alltraps>

00102a3e <vector254>:
.globl vector254
vector254:
  pushl $0
  102a3e:	6a 00                	push   $0x0
  pushl $254
  102a40:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102a45:	e9 0c 00 00 00       	jmp    102a56 <__alltraps>

00102a4a <vector255>:
.globl vector255
vector255:
  pushl $0
  102a4a:	6a 00                	push   $0x0
  pushl $255
  102a4c:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102a51:	e9 00 00 00 00       	jmp    102a56 <__alltraps>

00102a56 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102a56:	1e                   	push   %ds
    pushl %es
  102a57:	06                   	push   %es
    pushl %fs
  102a58:	0f a0                	push   %fs
    pushl %gs
  102a5a:	0f a8                	push   %gs
    pushal
  102a5c:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102a5d:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102a62:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102a64:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102a66:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102a67:	e8 60 f5 ff ff       	call   101fcc <trap>

    # pop the pushed stack pointer
    popl %esp
  102a6c:	5c                   	pop    %esp

00102a6d <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102a6d:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102a6e:	0f a9                	pop    %gs
    popl %fs
  102a70:	0f a1                	pop    %fs
    popl %es
  102a72:	07                   	pop    %es
    popl %ds
  102a73:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102a74:	83 c4 08             	add    $0x8,%esp
    iret
  102a77:	cf                   	iret   

00102a78 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102a78:	55                   	push   %ebp
  102a79:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102a7b:	a1 18 cf 11 00       	mov    0x11cf18,%eax
  102a80:	8b 55 08             	mov    0x8(%ebp),%edx
  102a83:	29 c2                	sub    %eax,%edx
  102a85:	89 d0                	mov    %edx,%eax
  102a87:	c1 f8 02             	sar    $0x2,%eax
  102a8a:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102a90:	5d                   	pop    %ebp
  102a91:	c3                   	ret    

00102a92 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102a92:	55                   	push   %ebp
  102a93:	89 e5                	mov    %esp,%ebp
  102a95:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102a98:	8b 45 08             	mov    0x8(%ebp),%eax
  102a9b:	89 04 24             	mov    %eax,(%esp)
  102a9e:	e8 d5 ff ff ff       	call   102a78 <page2ppn>
  102aa3:	c1 e0 0c             	shl    $0xc,%eax
}
  102aa6:	c9                   	leave  
  102aa7:	c3                   	ret    

00102aa8 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  102aa8:	55                   	push   %ebp
  102aa9:	89 e5                	mov    %esp,%ebp
  102aab:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102aae:	8b 45 08             	mov    0x8(%ebp),%eax
  102ab1:	c1 e8 0c             	shr    $0xc,%eax
  102ab4:	89 c2                	mov    %eax,%edx
  102ab6:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102abb:	39 c2                	cmp    %eax,%edx
  102abd:	72 1c                	jb     102adb <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102abf:	c7 44 24 08 30 69 10 	movl   $0x106930,0x8(%esp)
  102ac6:	00 
  102ac7:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  102ace:	00 
  102acf:	c7 04 24 4f 69 10 00 	movl   $0x10694f,(%esp)
  102ad6:	e8 5a d9 ff ff       	call   100435 <__panic>
    }
    return &pages[PPN(pa)];
  102adb:	8b 0d 18 cf 11 00    	mov    0x11cf18,%ecx
  102ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  102ae4:	c1 e8 0c             	shr    $0xc,%eax
  102ae7:	89 c2                	mov    %eax,%edx
  102ae9:	89 d0                	mov    %edx,%eax
  102aeb:	c1 e0 02             	shl    $0x2,%eax
  102aee:	01 d0                	add    %edx,%eax
  102af0:	c1 e0 02             	shl    $0x2,%eax
  102af3:	01 c8                	add    %ecx,%eax
}
  102af5:	c9                   	leave  
  102af6:	c3                   	ret    

00102af7 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  102af7:	55                   	push   %ebp
  102af8:	89 e5                	mov    %esp,%ebp
  102afa:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102afd:	8b 45 08             	mov    0x8(%ebp),%eax
  102b00:	89 04 24             	mov    %eax,(%esp)
  102b03:	e8 8a ff ff ff       	call   102a92 <page2pa>
  102b08:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b0e:	c1 e8 0c             	shr    $0xc,%eax
  102b11:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102b14:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102b19:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102b1c:	72 23                	jb     102b41 <page2kva+0x4a>
  102b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b21:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102b25:	c7 44 24 08 60 69 10 	movl   $0x106960,0x8(%esp)
  102b2c:	00 
  102b2d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  102b34:	00 
  102b35:	c7 04 24 4f 69 10 00 	movl   $0x10694f,(%esp)
  102b3c:	e8 f4 d8 ff ff       	call   100435 <__panic>
  102b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b44:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  102b49:	c9                   	leave  
  102b4a:	c3                   	ret    

00102b4b <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102b4b:	55                   	push   %ebp
  102b4c:	89 e5                	mov    %esp,%ebp
  102b4e:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102b51:	8b 45 08             	mov    0x8(%ebp),%eax
  102b54:	83 e0 01             	and    $0x1,%eax
  102b57:	85 c0                	test   %eax,%eax
  102b59:	75 1c                	jne    102b77 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102b5b:	c7 44 24 08 84 69 10 	movl   $0x106984,0x8(%esp)
  102b62:	00 
  102b63:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  102b6a:	00 
  102b6b:	c7 04 24 4f 69 10 00 	movl   $0x10694f,(%esp)
  102b72:	e8 be d8 ff ff       	call   100435 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102b77:	8b 45 08             	mov    0x8(%ebp),%eax
  102b7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102b7f:	89 04 24             	mov    %eax,(%esp)
  102b82:	e8 21 ff ff ff       	call   102aa8 <pa2page>
}
  102b87:	c9                   	leave  
  102b88:	c3                   	ret    

00102b89 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  102b89:	55                   	push   %ebp
  102b8a:	89 e5                	mov    %esp,%ebp
  102b8c:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  102b92:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102b97:	89 04 24             	mov    %eax,(%esp)
  102b9a:	e8 09 ff ff ff       	call   102aa8 <pa2page>
}
  102b9f:	c9                   	leave  
  102ba0:	c3                   	ret    

00102ba1 <page_ref>:

static inline int
page_ref(struct Page *page) {
  102ba1:	55                   	push   %ebp
  102ba2:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102ba4:	8b 45 08             	mov    0x8(%ebp),%eax
  102ba7:	8b 00                	mov    (%eax),%eax
}
  102ba9:	5d                   	pop    %ebp
  102baa:	c3                   	ret    

00102bab <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102bab:	55                   	push   %ebp
  102bac:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102bae:	8b 45 08             	mov    0x8(%ebp),%eax
  102bb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bb4:	89 10                	mov    %edx,(%eax)
}
  102bb6:	90                   	nop
  102bb7:	5d                   	pop    %ebp
  102bb8:	c3                   	ret    

00102bb9 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  102bb9:	55                   	push   %ebp
  102bba:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  102bbf:	8b 00                	mov    (%eax),%eax
  102bc1:	8d 50 01             	lea    0x1(%eax),%edx
  102bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  102bc7:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  102bcc:	8b 00                	mov    (%eax),%eax
}
  102bce:	5d                   	pop    %ebp
  102bcf:	c3                   	ret    

00102bd0 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102bd0:	55                   	push   %ebp
  102bd1:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102bd3:	8b 45 08             	mov    0x8(%ebp),%eax
  102bd6:	8b 00                	mov    (%eax),%eax
  102bd8:	8d 50 ff             	lea    -0x1(%eax),%edx
  102bdb:	8b 45 08             	mov    0x8(%ebp),%eax
  102bde:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102be0:	8b 45 08             	mov    0x8(%ebp),%eax
  102be3:	8b 00                	mov    (%eax),%eax
}
  102be5:	5d                   	pop    %ebp
  102be6:	c3                   	ret    

00102be7 <__intr_save>:
__intr_save(void) {
  102be7:	55                   	push   %ebp
  102be8:	89 e5                	mov    %esp,%ebp
  102bea:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102bed:	9c                   	pushf  
  102bee:	58                   	pop    %eax
  102bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102bf5:	25 00 02 00 00       	and    $0x200,%eax
  102bfa:	85 c0                	test   %eax,%eax
  102bfc:	74 0c                	je     102c0a <__intr_save+0x23>
        intr_disable();
  102bfe:	e8 95 ed ff ff       	call   101998 <intr_disable>
        return 1;
  102c03:	b8 01 00 00 00       	mov    $0x1,%eax
  102c08:	eb 05                	jmp    102c0f <__intr_save+0x28>
    return 0;
  102c0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102c0f:	c9                   	leave  
  102c10:	c3                   	ret    

00102c11 <__intr_restore>:
__intr_restore(bool flag) {
  102c11:	55                   	push   %ebp
  102c12:	89 e5                	mov    %esp,%ebp
  102c14:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102c17:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102c1b:	74 05                	je     102c22 <__intr_restore+0x11>
        intr_enable();
  102c1d:	e8 6a ed ff ff       	call   10198c <intr_enable>
}
  102c22:	90                   	nop
  102c23:	c9                   	leave  
  102c24:	c3                   	ret    

00102c25 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102c25:	55                   	push   %ebp
  102c26:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102c28:	8b 45 08             	mov    0x8(%ebp),%eax
  102c2b:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102c2e:	b8 23 00 00 00       	mov    $0x23,%eax
  102c33:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102c35:	b8 23 00 00 00       	mov    $0x23,%eax
  102c3a:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102c3c:	b8 10 00 00 00       	mov    $0x10,%eax
  102c41:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102c43:	b8 10 00 00 00       	mov    $0x10,%eax
  102c48:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102c4a:	b8 10 00 00 00       	mov    $0x10,%eax
  102c4f:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102c51:	ea 58 2c 10 00 08 00 	ljmp   $0x8,$0x102c58
}
  102c58:	90                   	nop
  102c59:	5d                   	pop    %ebp
  102c5a:	c3                   	ret    

00102c5b <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102c5b:	f3 0f 1e fb          	endbr32 
  102c5f:	55                   	push   %ebp
  102c60:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102c62:	8b 45 08             	mov    0x8(%ebp),%eax
  102c65:	a3 a4 ce 11 00       	mov    %eax,0x11cea4
}
  102c6a:	90                   	nop
  102c6b:	5d                   	pop    %ebp
  102c6c:	c3                   	ret    

00102c6d <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102c6d:	f3 0f 1e fb          	endbr32 
  102c71:	55                   	push   %ebp
  102c72:	89 e5                	mov    %esp,%ebp
  102c74:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102c77:	b8 00 90 11 00       	mov    $0x119000,%eax
  102c7c:	89 04 24             	mov    %eax,(%esp)
  102c7f:	e8 d7 ff ff ff       	call   102c5b <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102c84:	66 c7 05 a8 ce 11 00 	movw   $0x10,0x11cea8
  102c8b:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102c8d:	66 c7 05 28 9a 11 00 	movw   $0x68,0x119a28
  102c94:	68 00 
  102c96:	b8 a0 ce 11 00       	mov    $0x11cea0,%eax
  102c9b:	0f b7 c0             	movzwl %ax,%eax
  102c9e:	66 a3 2a 9a 11 00    	mov    %ax,0x119a2a
  102ca4:	b8 a0 ce 11 00       	mov    $0x11cea0,%eax
  102ca9:	c1 e8 10             	shr    $0x10,%eax
  102cac:	a2 2c 9a 11 00       	mov    %al,0x119a2c
  102cb1:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  102cb8:	24 f0                	and    $0xf0,%al
  102cba:	0c 09                	or     $0x9,%al
  102cbc:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  102cc1:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  102cc8:	24 ef                	and    $0xef,%al
  102cca:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  102ccf:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  102cd6:	24 9f                	and    $0x9f,%al
  102cd8:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  102cdd:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  102ce4:	0c 80                	or     $0x80,%al
  102ce6:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  102ceb:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  102cf2:	24 f0                	and    $0xf0,%al
  102cf4:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  102cf9:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  102d00:	24 ef                	and    $0xef,%al
  102d02:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  102d07:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  102d0e:	24 df                	and    $0xdf,%al
  102d10:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  102d15:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  102d1c:	0c 40                	or     $0x40,%al
  102d1e:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  102d23:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  102d2a:	24 7f                	and    $0x7f,%al
  102d2c:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  102d31:	b8 a0 ce 11 00       	mov    $0x11cea0,%eax
  102d36:	c1 e8 18             	shr    $0x18,%eax
  102d39:	a2 2f 9a 11 00       	mov    %al,0x119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102d3e:	c7 04 24 30 9a 11 00 	movl   $0x119a30,(%esp)
  102d45:	e8 db fe ff ff       	call   102c25 <lgdt>
  102d4a:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102d50:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102d54:	0f 00 d8             	ltr    %ax
}
  102d57:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  102d58:	90                   	nop
  102d59:	c9                   	leave  
  102d5a:	c3                   	ret    

00102d5b <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102d5b:	f3 0f 1e fb          	endbr32 
  102d5f:	55                   	push   %ebp
  102d60:	89 e5                	mov    %esp,%ebp
  102d62:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102d65:	c7 05 10 cf 11 00 10 	movl   $0x107310,0x11cf10
  102d6c:	73 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102d6f:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102d74:	8b 00                	mov    (%eax),%eax
  102d76:	89 44 24 04          	mov    %eax,0x4(%esp)
  102d7a:	c7 04 24 b0 69 10 00 	movl   $0x1069b0,(%esp)
  102d81:	e8 43 d5 ff ff       	call   1002c9 <cprintf>
    pmm_manager->init();
  102d86:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102d8b:	8b 40 04             	mov    0x4(%eax),%eax
  102d8e:	ff d0                	call   *%eax
}
  102d90:	90                   	nop
  102d91:	c9                   	leave  
  102d92:	c3                   	ret    

00102d93 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102d93:	f3 0f 1e fb          	endbr32 
  102d97:	55                   	push   %ebp
  102d98:	89 e5                	mov    %esp,%ebp
  102d9a:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102d9d:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102da2:	8b 40 08             	mov    0x8(%eax),%eax
  102da5:	8b 55 0c             	mov    0xc(%ebp),%edx
  102da8:	89 54 24 04          	mov    %edx,0x4(%esp)
  102dac:	8b 55 08             	mov    0x8(%ebp),%edx
  102daf:	89 14 24             	mov    %edx,(%esp)
  102db2:	ff d0                	call   *%eax
}
  102db4:	90                   	nop
  102db5:	c9                   	leave  
  102db6:	c3                   	ret    

00102db7 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102db7:	f3 0f 1e fb          	endbr32 
  102dbb:	55                   	push   %ebp
  102dbc:	89 e5                	mov    %esp,%ebp
  102dbe:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102dc1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102dc8:	e8 1a fe ff ff       	call   102be7 <__intr_save>
  102dcd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102dd0:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102dd5:	8b 40 0c             	mov    0xc(%eax),%eax
  102dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  102ddb:	89 14 24             	mov    %edx,(%esp)
  102dde:	ff d0                	call   *%eax
  102de0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102de3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102de6:	89 04 24             	mov    %eax,(%esp)
  102de9:	e8 23 fe ff ff       	call   102c11 <__intr_restore>
    return page;
  102dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102df1:	c9                   	leave  
  102df2:	c3                   	ret    

00102df3 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102df3:	f3 0f 1e fb          	endbr32 
  102df7:	55                   	push   %ebp
  102df8:	89 e5                	mov    %esp,%ebp
  102dfa:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102dfd:	e8 e5 fd ff ff       	call   102be7 <__intr_save>
  102e02:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102e05:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102e0a:	8b 40 10             	mov    0x10(%eax),%eax
  102e0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e10:	89 54 24 04          	mov    %edx,0x4(%esp)
  102e14:	8b 55 08             	mov    0x8(%ebp),%edx
  102e17:	89 14 24             	mov    %edx,(%esp)
  102e1a:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e1f:	89 04 24             	mov    %eax,(%esp)
  102e22:	e8 ea fd ff ff       	call   102c11 <__intr_restore>
}
  102e27:	90                   	nop
  102e28:	c9                   	leave  
  102e29:	c3                   	ret    

00102e2a <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102e2a:	f3 0f 1e fb          	endbr32 
  102e2e:	55                   	push   %ebp
  102e2f:	89 e5                	mov    %esp,%ebp
  102e31:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102e34:	e8 ae fd ff ff       	call   102be7 <__intr_save>
  102e39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102e3c:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102e41:	8b 40 14             	mov    0x14(%eax),%eax
  102e44:	ff d0                	call   *%eax
  102e46:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102e49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e4c:	89 04 24             	mov    %eax,(%esp)
  102e4f:	e8 bd fd ff ff       	call   102c11 <__intr_restore>
    return ret;
  102e54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102e57:	c9                   	leave  
  102e58:	c3                   	ret    

00102e59 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102e59:	f3 0f 1e fb          	endbr32 
  102e5d:	55                   	push   %ebp
  102e5e:	89 e5                	mov    %esp,%ebp
  102e60:	57                   	push   %edi
  102e61:	56                   	push   %esi
  102e62:	53                   	push   %ebx
  102e63:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102e69:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102e70:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102e77:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102e7e:	c7 04 24 c7 69 10 00 	movl   $0x1069c7,(%esp)
  102e85:	e8 3f d4 ff ff       	call   1002c9 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102e8a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e91:	e9 1a 01 00 00       	jmp    102fb0 <page_init+0x157>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102e96:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e99:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e9c:	89 d0                	mov    %edx,%eax
  102e9e:	c1 e0 02             	shl    $0x2,%eax
  102ea1:	01 d0                	add    %edx,%eax
  102ea3:	c1 e0 02             	shl    $0x2,%eax
  102ea6:	01 c8                	add    %ecx,%eax
  102ea8:	8b 50 08             	mov    0x8(%eax),%edx
  102eab:	8b 40 04             	mov    0x4(%eax),%eax
  102eae:	89 45 a0             	mov    %eax,-0x60(%ebp)
  102eb1:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  102eb4:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102eb7:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102eba:	89 d0                	mov    %edx,%eax
  102ebc:	c1 e0 02             	shl    $0x2,%eax
  102ebf:	01 d0                	add    %edx,%eax
  102ec1:	c1 e0 02             	shl    $0x2,%eax
  102ec4:	01 c8                	add    %ecx,%eax
  102ec6:	8b 48 0c             	mov    0xc(%eax),%ecx
  102ec9:	8b 58 10             	mov    0x10(%eax),%ebx
  102ecc:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102ecf:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102ed2:	01 c8                	add    %ecx,%eax
  102ed4:	11 da                	adc    %ebx,%edx
  102ed6:	89 45 98             	mov    %eax,-0x68(%ebp)
  102ed9:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102edc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102edf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ee2:	89 d0                	mov    %edx,%eax
  102ee4:	c1 e0 02             	shl    $0x2,%eax
  102ee7:	01 d0                	add    %edx,%eax
  102ee9:	c1 e0 02             	shl    $0x2,%eax
  102eec:	01 c8                	add    %ecx,%eax
  102eee:	83 c0 14             	add    $0x14,%eax
  102ef1:	8b 00                	mov    (%eax),%eax
  102ef3:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102ef6:	8b 45 98             	mov    -0x68(%ebp),%eax
  102ef9:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102efc:	83 c0 ff             	add    $0xffffffff,%eax
  102eff:	83 d2 ff             	adc    $0xffffffff,%edx
  102f02:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102f08:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102f0e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f11:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f14:	89 d0                	mov    %edx,%eax
  102f16:	c1 e0 02             	shl    $0x2,%eax
  102f19:	01 d0                	add    %edx,%eax
  102f1b:	c1 e0 02             	shl    $0x2,%eax
  102f1e:	01 c8                	add    %ecx,%eax
  102f20:	8b 48 0c             	mov    0xc(%eax),%ecx
  102f23:	8b 58 10             	mov    0x10(%eax),%ebx
  102f26:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102f29:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102f2d:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102f33:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102f39:	89 44 24 14          	mov    %eax,0x14(%esp)
  102f3d:	89 54 24 18          	mov    %edx,0x18(%esp)
  102f41:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102f44:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102f47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102f4b:	89 54 24 10          	mov    %edx,0x10(%esp)
  102f4f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102f53:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102f57:	c7 04 24 d4 69 10 00 	movl   $0x1069d4,(%esp)
  102f5e:	e8 66 d3 ff ff       	call   1002c9 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102f63:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102f66:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102f69:	89 d0                	mov    %edx,%eax
  102f6b:	c1 e0 02             	shl    $0x2,%eax
  102f6e:	01 d0                	add    %edx,%eax
  102f70:	c1 e0 02             	shl    $0x2,%eax
  102f73:	01 c8                	add    %ecx,%eax
  102f75:	83 c0 14             	add    $0x14,%eax
  102f78:	8b 00                	mov    (%eax),%eax
  102f7a:	83 f8 01             	cmp    $0x1,%eax
  102f7d:	75 2e                	jne    102fad <page_init+0x154>
            if (maxpa < end && begin < KMEMSIZE) {
  102f7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f82:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102f85:	3b 45 98             	cmp    -0x68(%ebp),%eax
  102f88:	89 d0                	mov    %edx,%eax
  102f8a:	1b 45 9c             	sbb    -0x64(%ebp),%eax
  102f8d:	73 1e                	jae    102fad <page_init+0x154>
  102f8f:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
  102f94:	b8 00 00 00 00       	mov    $0x0,%eax
  102f99:	3b 55 a0             	cmp    -0x60(%ebp),%edx
  102f9c:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
  102f9f:	72 0c                	jb     102fad <page_init+0x154>
                maxpa = end;
  102fa1:	8b 45 98             	mov    -0x68(%ebp),%eax
  102fa4:	8b 55 9c             	mov    -0x64(%ebp),%edx
  102fa7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102faa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  102fad:	ff 45 dc             	incl   -0x24(%ebp)
  102fb0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102fb3:	8b 00                	mov    (%eax),%eax
  102fb5:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  102fb8:	0f 8c d8 fe ff ff    	jl     102e96 <page_init+0x3d>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102fbe:	ba 00 00 00 38       	mov    $0x38000000,%edx
  102fc3:	b8 00 00 00 00       	mov    $0x0,%eax
  102fc8:	3b 55 e0             	cmp    -0x20(%ebp),%edx
  102fcb:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
  102fce:	73 0e                	jae    102fde <page_init+0x185>
        maxpa = KMEMSIZE;
  102fd0:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102fd7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102fde:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102fe1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102fe4:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102fe8:	c1 ea 0c             	shr    $0xc,%edx
  102feb:	a3 80 ce 11 00       	mov    %eax,0x11ce80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102ff0:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  102ff7:	b8 28 cf 11 00       	mov    $0x11cf28,%eax
  102ffc:	8d 50 ff             	lea    -0x1(%eax),%edx
  102fff:	8b 45 c0             	mov    -0x40(%ebp),%eax
  103002:	01 d0                	add    %edx,%eax
  103004:	89 45 bc             	mov    %eax,-0x44(%ebp)
  103007:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10300a:	ba 00 00 00 00       	mov    $0x0,%edx
  10300f:	f7 75 c0             	divl   -0x40(%ebp)
  103012:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103015:	29 d0                	sub    %edx,%eax
  103017:	a3 18 cf 11 00       	mov    %eax,0x11cf18

    for (i = 0; i < npage; i ++) {
  10301c:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103023:	eb 2f                	jmp    103054 <page_init+0x1fb>
        SetPageReserved(pages + i);
  103025:	8b 0d 18 cf 11 00    	mov    0x11cf18,%ecx
  10302b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10302e:	89 d0                	mov    %edx,%eax
  103030:	c1 e0 02             	shl    $0x2,%eax
  103033:	01 d0                	add    %edx,%eax
  103035:	c1 e0 02             	shl    $0x2,%eax
  103038:	01 c8                	add    %ecx,%eax
  10303a:	83 c0 04             	add    $0x4,%eax
  10303d:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  103044:	89 45 90             	mov    %eax,-0x70(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  103047:	8b 45 90             	mov    -0x70(%ebp),%eax
  10304a:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10304d:	0f ab 10             	bts    %edx,(%eax)
}
  103050:	90                   	nop
    for (i = 0; i < npage; i ++) {
  103051:	ff 45 dc             	incl   -0x24(%ebp)
  103054:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103057:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  10305c:	39 c2                	cmp    %eax,%edx
  10305e:	72 c5                	jb     103025 <page_init+0x1cc>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  103060:	8b 15 80 ce 11 00    	mov    0x11ce80,%edx
  103066:	89 d0                	mov    %edx,%eax
  103068:	c1 e0 02             	shl    $0x2,%eax
  10306b:	01 d0                	add    %edx,%eax
  10306d:	c1 e0 02             	shl    $0x2,%eax
  103070:	89 c2                	mov    %eax,%edx
  103072:	a1 18 cf 11 00       	mov    0x11cf18,%eax
  103077:	01 d0                	add    %edx,%eax
  103079:	89 45 b8             	mov    %eax,-0x48(%ebp)
  10307c:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  103083:	77 23                	ja     1030a8 <page_init+0x24f>
  103085:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103088:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10308c:	c7 44 24 08 04 6a 10 	movl   $0x106a04,0x8(%esp)
  103093:	00 
  103094:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  10309b:	00 
  10309c:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1030a3:	e8 8d d3 ff ff       	call   100435 <__panic>
  1030a8:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1030ab:	05 00 00 00 40       	add    $0x40000000,%eax
  1030b0:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  1030b3:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1030ba:	e9 4b 01 00 00       	jmp    10320a <page_init+0x3b1>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  1030bf:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1030c2:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1030c5:	89 d0                	mov    %edx,%eax
  1030c7:	c1 e0 02             	shl    $0x2,%eax
  1030ca:	01 d0                	add    %edx,%eax
  1030cc:	c1 e0 02             	shl    $0x2,%eax
  1030cf:	01 c8                	add    %ecx,%eax
  1030d1:	8b 50 08             	mov    0x8(%eax),%edx
  1030d4:	8b 40 04             	mov    0x4(%eax),%eax
  1030d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1030da:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1030dd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1030e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1030e3:	89 d0                	mov    %edx,%eax
  1030e5:	c1 e0 02             	shl    $0x2,%eax
  1030e8:	01 d0                	add    %edx,%eax
  1030ea:	c1 e0 02             	shl    $0x2,%eax
  1030ed:	01 c8                	add    %ecx,%eax
  1030ef:	8b 48 0c             	mov    0xc(%eax),%ecx
  1030f2:	8b 58 10             	mov    0x10(%eax),%ebx
  1030f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1030f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1030fb:	01 c8                	add    %ecx,%eax
  1030fd:	11 da                	adc    %ebx,%edx
  1030ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
  103102:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  103105:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103108:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10310b:	89 d0                	mov    %edx,%eax
  10310d:	c1 e0 02             	shl    $0x2,%eax
  103110:	01 d0                	add    %edx,%eax
  103112:	c1 e0 02             	shl    $0x2,%eax
  103115:	01 c8                	add    %ecx,%eax
  103117:	83 c0 14             	add    $0x14,%eax
  10311a:	8b 00                	mov    (%eax),%eax
  10311c:	83 f8 01             	cmp    $0x1,%eax
  10311f:	0f 85 e2 00 00 00    	jne    103207 <page_init+0x3ae>
            if (begin < freemem) {
  103125:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103128:	ba 00 00 00 00       	mov    $0x0,%edx
  10312d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  103130:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  103133:	19 d1                	sbb    %edx,%ecx
  103135:	73 0d                	jae    103144 <page_init+0x2eb>
                begin = freemem;
  103137:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10313a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10313d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  103144:	ba 00 00 00 38       	mov    $0x38000000,%edx
  103149:	b8 00 00 00 00       	mov    $0x0,%eax
  10314e:	3b 55 c8             	cmp    -0x38(%ebp),%edx
  103151:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  103154:	73 0e                	jae    103164 <page_init+0x30b>
                end = KMEMSIZE;
  103156:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  10315d:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  103164:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103167:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10316a:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10316d:	89 d0                	mov    %edx,%eax
  10316f:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  103172:	0f 83 8f 00 00 00    	jae    103207 <page_init+0x3ae>
                begin = ROUNDUP(begin, PGSIZE);
  103178:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  10317f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103182:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103185:	01 d0                	add    %edx,%eax
  103187:	48                   	dec    %eax
  103188:	89 45 ac             	mov    %eax,-0x54(%ebp)
  10318b:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10318e:	ba 00 00 00 00       	mov    $0x0,%edx
  103193:	f7 75 b0             	divl   -0x50(%ebp)
  103196:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103199:	29 d0                	sub    %edx,%eax
  10319b:	ba 00 00 00 00       	mov    $0x0,%edx
  1031a0:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1031a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  1031a6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1031a9:	89 45 a8             	mov    %eax,-0x58(%ebp)
  1031ac:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1031af:	ba 00 00 00 00       	mov    $0x0,%edx
  1031b4:	89 c3                	mov    %eax,%ebx
  1031b6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  1031bc:	89 de                	mov    %ebx,%esi
  1031be:	89 d0                	mov    %edx,%eax
  1031c0:	83 e0 00             	and    $0x0,%eax
  1031c3:	89 c7                	mov    %eax,%edi
  1031c5:	89 75 c8             	mov    %esi,-0x38(%ebp)
  1031c8:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  1031cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1031ce:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1031d1:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1031d4:	89 d0                	mov    %edx,%eax
  1031d6:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  1031d9:	73 2c                	jae    103207 <page_init+0x3ae>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  1031db:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1031de:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1031e1:	2b 45 d0             	sub    -0x30(%ebp),%eax
  1031e4:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  1031e7:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1031eb:	c1 ea 0c             	shr    $0xc,%edx
  1031ee:	89 c3                	mov    %eax,%ebx
  1031f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1031f3:	89 04 24             	mov    %eax,(%esp)
  1031f6:	e8 ad f8 ff ff       	call   102aa8 <pa2page>
  1031fb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1031ff:	89 04 24             	mov    %eax,(%esp)
  103202:	e8 8c fb ff ff       	call   102d93 <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  103207:	ff 45 dc             	incl   -0x24(%ebp)
  10320a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10320d:	8b 00                	mov    (%eax),%eax
  10320f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103212:	0f 8c a7 fe ff ff    	jl     1030bf <page_init+0x266>
                }
            }
        }
    }
}
  103218:	90                   	nop
  103219:	90                   	nop
  10321a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  103220:	5b                   	pop    %ebx
  103221:	5e                   	pop    %esi
  103222:	5f                   	pop    %edi
  103223:	5d                   	pop    %ebp
  103224:	c3                   	ret    

00103225 <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  103225:	f3 0f 1e fb          	endbr32 
  103229:	55                   	push   %ebp
  10322a:	89 e5                	mov    %esp,%ebp
  10322c:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  10322f:	8b 45 0c             	mov    0xc(%ebp),%eax
  103232:	33 45 14             	xor    0x14(%ebp),%eax
  103235:	25 ff 0f 00 00       	and    $0xfff,%eax
  10323a:	85 c0                	test   %eax,%eax
  10323c:	74 24                	je     103262 <boot_map_segment+0x3d>
  10323e:	c7 44 24 0c 36 6a 10 	movl   $0x106a36,0xc(%esp)
  103245:	00 
  103246:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  10324d:	00 
  10324e:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  103255:	00 
  103256:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  10325d:	e8 d3 d1 ff ff       	call   100435 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  103262:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  103269:	8b 45 0c             	mov    0xc(%ebp),%eax
  10326c:	25 ff 0f 00 00       	and    $0xfff,%eax
  103271:	89 c2                	mov    %eax,%edx
  103273:	8b 45 10             	mov    0x10(%ebp),%eax
  103276:	01 c2                	add    %eax,%edx
  103278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10327b:	01 d0                	add    %edx,%eax
  10327d:	48                   	dec    %eax
  10327e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103281:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103284:	ba 00 00 00 00       	mov    $0x0,%edx
  103289:	f7 75 f0             	divl   -0x10(%ebp)
  10328c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10328f:	29 d0                	sub    %edx,%eax
  103291:	c1 e8 0c             	shr    $0xc,%eax
  103294:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  103297:	8b 45 0c             	mov    0xc(%ebp),%eax
  10329a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10329d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1032a5:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  1032a8:	8b 45 14             	mov    0x14(%ebp),%eax
  1032ab:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1032ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1032b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1032b6:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1032b9:	eb 68                	jmp    103323 <boot_map_segment+0xfe>
        pte_t *ptep = get_pte(pgdir, la, 1);
  1032bb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1032c2:	00 
  1032c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1032cd:	89 04 24             	mov    %eax,(%esp)
  1032d0:	e8 8a 01 00 00       	call   10345f <get_pte>
  1032d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  1032d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1032dc:	75 24                	jne    103302 <boot_map_segment+0xdd>
  1032de:	c7 44 24 0c 62 6a 10 	movl   $0x106a62,0xc(%esp)
  1032e5:	00 
  1032e6:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  1032ed:	00 
  1032ee:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  1032f5:	00 
  1032f6:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1032fd:	e8 33 d1 ff ff       	call   100435 <__panic>
        *ptep = pa | PTE_P | perm;
  103302:	8b 45 14             	mov    0x14(%ebp),%eax
  103305:	0b 45 18             	or     0x18(%ebp),%eax
  103308:	83 c8 01             	or     $0x1,%eax
  10330b:	89 c2                	mov    %eax,%edx
  10330d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103310:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  103312:	ff 4d f4             	decl   -0xc(%ebp)
  103315:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10331c:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  103323:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103327:	75 92                	jne    1032bb <boot_map_segment+0x96>
    }
}
  103329:	90                   	nop
  10332a:	90                   	nop
  10332b:	c9                   	leave  
  10332c:	c3                   	ret    

0010332d <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  10332d:	f3 0f 1e fb          	endbr32 
  103331:	55                   	push   %ebp
  103332:	89 e5                	mov    %esp,%ebp
  103334:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  103337:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10333e:	e8 74 fa ff ff       	call   102db7 <alloc_pages>
  103343:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  103346:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10334a:	75 1c                	jne    103368 <boot_alloc_page+0x3b>
        panic("boot_alloc_page failed.\n");
  10334c:	c7 44 24 08 6f 6a 10 	movl   $0x106a6f,0x8(%esp)
  103353:	00 
  103354:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  10335b:	00 
  10335c:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103363:	e8 cd d0 ff ff       	call   100435 <__panic>
    }
    return page2kva(p);
  103368:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10336b:	89 04 24             	mov    %eax,(%esp)
  10336e:	e8 84 f7 ff ff       	call   102af7 <page2kva>
}
  103373:	c9                   	leave  
  103374:	c3                   	ret    

00103375 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  103375:	f3 0f 1e fb          	endbr32 
  103379:	55                   	push   %ebp
  10337a:	89 e5                	mov    %esp,%ebp
  10337c:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  10337f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103384:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103387:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10338e:	77 23                	ja     1033b3 <pmm_init+0x3e>
  103390:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103393:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103397:	c7 44 24 08 04 6a 10 	movl   $0x106a04,0x8(%esp)
  10339e:	00 
  10339f:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1033a6:	00 
  1033a7:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1033ae:	e8 82 d0 ff ff       	call   100435 <__panic>
  1033b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033b6:	05 00 00 00 40       	add    $0x40000000,%eax
  1033bb:	a3 14 cf 11 00       	mov    %eax,0x11cf14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  1033c0:	e8 96 f9 ff ff       	call   102d5b <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  1033c5:	e8 8f fa ff ff       	call   102e59 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  1033ca:	e8 fd 03 00 00       	call   1037cc <check_alloc_page>

    check_pgdir();
  1033cf:	e8 1b 04 00 00       	call   1037ef <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  1033d4:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1033d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1033dc:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1033e3:	77 23                	ja     103408 <pmm_init+0x93>
  1033e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1033e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1033ec:	c7 44 24 08 04 6a 10 	movl   $0x106a04,0x8(%esp)
  1033f3:	00 
  1033f4:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  1033fb:	00 
  1033fc:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103403:	e8 2d d0 ff ff       	call   100435 <__panic>
  103408:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10340b:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  103411:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103416:	05 ac 0f 00 00       	add    $0xfac,%eax
  10341b:	83 ca 03             	or     $0x3,%edx
  10341e:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  103420:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103425:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  10342c:	00 
  10342d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103434:	00 
  103435:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  10343c:	38 
  10343d:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  103444:	c0 
  103445:	89 04 24             	mov    %eax,(%esp)
  103448:	e8 d8 fd ff ff       	call   103225 <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  10344d:	e8 1b f8 ff ff       	call   102c6d <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  103452:	e8 38 0a 00 00       	call   103e8f <check_boot_pgdir>

    print_pgdir();
  103457:	e8 bd 0e 00 00       	call   104319 <print_pgdir>

}
  10345c:	90                   	nop
  10345d:	c9                   	leave  
  10345e:	c3                   	ret    

0010345f <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  10345f:	f3 0f 1e fb          	endbr32 
  103463:	55                   	push   %ebp
  103464:	89 e5                	mov    %esp,%ebp
  103466:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];  // (1) 首先找到页目录项，尝试获得页表
  103469:	8b 45 0c             	mov    0xc(%ebp),%eax
  10346c:	c1 e8 16             	shr    $0x16,%eax
  10346f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  103476:	8b 45 08             	mov    0x8(%ebp),%eax
  103479:	01 d0                	add    %edx,%eax
  10347b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {         // (2) 检查这个页目录项是否存在，存在则直接返回找到的页表项，如果不存在
  10347e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103481:	8b 00                	mov    (%eax),%eax
  103483:	83 e0 01             	and    $0x1,%eax
  103486:	85 c0                	test   %eax,%eax
  103488:	0f 85 b9 00 00 00    	jne    103547 <get_pte+0xe8>
        if (!create) {               // (3) 页目录项不存在且参数不要求创建新的页表，那么返回NULL
  10348e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103492:	75 0a                	jne    10349e <get_pte+0x3f>
            return NULL;
  103494:	b8 00 00 00 00       	mov    $0x0,%eax
  103499:	e9 06 01 00 00       	jmp    1035a4 <get_pte+0x145>
        }
        struct Page *page = alloc_page();  // (3) 否则分配一个物理页存储创建的页表
  10349e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1034a5:	e8 0d f9 ff ff       	call   102db7 <alloc_pages>
  1034aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (page == NULL) {  // (3) 如果分配失败，那么返回NULL
  1034ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1034b1:	75 0a                	jne    1034bd <get_pte+0x5e>
            return NULL;
  1034b3:	b8 00 00 00 00       	mov    $0x0,%eax
  1034b8:	e9 e7 00 00 00       	jmp    1035a4 <get_pte+0x145>
        }
        set_page_ref(page, 1);               // (4) 设置物理页被引用一次
  1034bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1034c4:	00 
  1034c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034c8:	89 04 24             	mov    %eax,(%esp)
  1034cb:	e8 db f6 ff ff       	call   102bab <set_page_ref>
        uintptr_t pa = page2pa(page);        // (5) 获得物理页的线性物理地址
  1034d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034d3:	89 04 24             	mov    %eax,(%esp)
  1034d6:	e8 b7 f5 ff ff       	call   102a92 <page2pa>
  1034db:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);        // (6) 将物理地址转换成虚拟地址后，用memset函数清除页目录进行初始化
  1034de:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1034e1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1034e4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034e7:	c1 e8 0c             	shr    $0xc,%eax
  1034ea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1034ed:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  1034f2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1034f5:	72 23                	jb     10351a <get_pte+0xbb>
  1034f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1034fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1034fe:	c7 44 24 08 60 69 10 	movl   $0x106960,0x8(%esp)
  103505:	00 
  103506:	c7 44 24 04 75 01 00 	movl   $0x175,0x4(%esp)
  10350d:	00 
  10350e:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103515:	e8 1b cf ff ff       	call   100435 <__panic>
  10351a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10351d:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103522:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103529:	00 
  10352a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103531:	00 
  103532:	89 04 24             	mov    %eax,(%esp)
  103535:	e8 96 24 00 00       	call   1059d0 <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;  // (7) 设置页目录项的权限
  10353a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10353d:	83 c8 07             	or     $0x7,%eax
  103540:	89 c2                	mov    %eax,%edx
  103542:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103545:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)]; // (8) 返回虚拟地址la对应的页表项入口地址
  103547:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10354a:	8b 00                	mov    (%eax),%eax
  10354c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103551:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103554:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103557:	c1 e8 0c             	shr    $0xc,%eax
  10355a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10355d:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  103562:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103565:	72 23                	jb     10358a <get_pte+0x12b>
  103567:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10356a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10356e:	c7 44 24 08 60 69 10 	movl   $0x106960,0x8(%esp)
  103575:	00 
  103576:	c7 44 24 04 78 01 00 	movl   $0x178,0x4(%esp)
  10357d:	00 
  10357e:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103585:	e8 ab ce ff ff       	call   100435 <__panic>
  10358a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10358d:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103592:	89 c2                	mov    %eax,%edx
  103594:	8b 45 0c             	mov    0xc(%ebp),%eax
  103597:	c1 e8 0c             	shr    $0xc,%eax
  10359a:	25 ff 03 00 00       	and    $0x3ff,%eax
  10359f:	c1 e0 02             	shl    $0x2,%eax
  1035a2:	01 d0                	add    %edx,%eax
}
  1035a4:	c9                   	leave  
  1035a5:	c3                   	ret    

001035a6 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  1035a6:	f3 0f 1e fb          	endbr32 
  1035aa:	55                   	push   %ebp
  1035ab:	89 e5                	mov    %esp,%ebp
  1035ad:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1035b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1035b7:	00 
  1035b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1035c2:	89 04 24             	mov    %eax,(%esp)
  1035c5:	e8 95 fe ff ff       	call   10345f <get_pte>
  1035ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  1035cd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1035d1:	74 08                	je     1035db <get_page+0x35>
        *ptep_store = ptep;
  1035d3:	8b 45 10             	mov    0x10(%ebp),%eax
  1035d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1035d9:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  1035db:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1035df:	74 1b                	je     1035fc <get_page+0x56>
  1035e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035e4:	8b 00                	mov    (%eax),%eax
  1035e6:	83 e0 01             	and    $0x1,%eax
  1035e9:	85 c0                	test   %eax,%eax
  1035eb:	74 0f                	je     1035fc <get_page+0x56>
        return pte2page(*ptep);
  1035ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1035f0:	8b 00                	mov    (%eax),%eax
  1035f2:	89 04 24             	mov    %eax,(%esp)
  1035f5:	e8 51 f5 ff ff       	call   102b4b <pte2page>
  1035fa:	eb 05                	jmp    103601 <get_page+0x5b>
    }
    return NULL;
  1035fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103601:	c9                   	leave  
  103602:	c3                   	ret    

00103603 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  103603:	55                   	push   %ebp
  103604:	89 e5                	mov    %esp,%ebp
  103606:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {                     // (1) 检查这个页目录项是否存在
  103609:	8b 45 10             	mov    0x10(%ebp),%eax
  10360c:	8b 00                	mov    (%eax),%eax
  10360e:	83 e0 01             	and    $0x1,%eax
  103611:	85 c0                	test   %eax,%eax
  103613:	74 4d                	je     103662 <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep); // (2) 找到这个页目录项对应的页
  103615:	8b 45 10             	mov    0x10(%ebp),%eax
  103618:	8b 00                	mov    (%eax),%eax
  10361a:	89 04 24             	mov    %eax,(%esp)
  10361d:	e8 29 f5 ff ff       	call   102b4b <pte2page>
  103622:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {       // (3) 将这个页的引用数减一
  103625:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103628:	89 04 24             	mov    %eax,(%esp)
  10362b:	e8 a0 f5 ff ff       	call   102bd0 <page_ref_dec>
  103630:	85 c0                	test   %eax,%eax
  103632:	75 13                	jne    103647 <page_remove_pte+0x44>
            free_page(page);                 // (4) 如果这个页的引用数为0，那么释放此页
  103634:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10363b:	00 
  10363c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10363f:	89 04 24             	mov    %eax,(%esp)
  103642:	e8 ac f7 ff ff       	call   102df3 <free_pages>
        }
        *ptep = 0;                           // (5) 清除页目录项
  103647:	8b 45 10             	mov    0x10(%ebp),%eax
  10364a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);           // (6) 当修改的页表正在使用时，那么无效 
  103650:	8b 45 0c             	mov    0xc(%ebp),%eax
  103653:	89 44 24 04          	mov    %eax,0x4(%esp)
  103657:	8b 45 08             	mov    0x8(%ebp),%eax
  10365a:	89 04 24             	mov    %eax,(%esp)
  10365d:	e8 09 01 00 00       	call   10376b <tlb_invalidate>
    }
}
  103662:	90                   	nop
  103663:	c9                   	leave  
  103664:	c3                   	ret    

00103665 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  103665:	f3 0f 1e fb          	endbr32 
  103669:	55                   	push   %ebp
  10366a:	89 e5                	mov    %esp,%ebp
  10366c:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10366f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103676:	00 
  103677:	8b 45 0c             	mov    0xc(%ebp),%eax
  10367a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10367e:	8b 45 08             	mov    0x8(%ebp),%eax
  103681:	89 04 24             	mov    %eax,(%esp)
  103684:	e8 d6 fd ff ff       	call   10345f <get_pte>
  103689:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  10368c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103690:	74 19                	je     1036ab <page_remove+0x46>
        page_remove_pte(pgdir, la, ptep);
  103692:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103695:	89 44 24 08          	mov    %eax,0x8(%esp)
  103699:	8b 45 0c             	mov    0xc(%ebp),%eax
  10369c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036a0:	8b 45 08             	mov    0x8(%ebp),%eax
  1036a3:	89 04 24             	mov    %eax,(%esp)
  1036a6:	e8 58 ff ff ff       	call   103603 <page_remove_pte>
    }
}
  1036ab:	90                   	nop
  1036ac:	c9                   	leave  
  1036ad:	c3                   	ret    

001036ae <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  1036ae:	f3 0f 1e fb          	endbr32 
  1036b2:	55                   	push   %ebp
  1036b3:	89 e5                	mov    %esp,%ebp
  1036b5:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  1036b8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  1036bf:	00 
  1036c0:	8b 45 10             	mov    0x10(%ebp),%eax
  1036c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1036ca:	89 04 24             	mov    %eax,(%esp)
  1036cd:	e8 8d fd ff ff       	call   10345f <get_pte>
  1036d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  1036d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1036d9:	75 0a                	jne    1036e5 <page_insert+0x37>
        return -E_NO_MEM;
  1036db:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  1036e0:	e9 84 00 00 00       	jmp    103769 <page_insert+0xbb>
    }
    page_ref_inc(page);
  1036e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036e8:	89 04 24             	mov    %eax,(%esp)
  1036eb:	e8 c9 f4 ff ff       	call   102bb9 <page_ref_inc>
    if (*ptep & PTE_P) {
  1036f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036f3:	8b 00                	mov    (%eax),%eax
  1036f5:	83 e0 01             	and    $0x1,%eax
  1036f8:	85 c0                	test   %eax,%eax
  1036fa:	74 3e                	je     10373a <page_insert+0x8c>
        struct Page *p = pte2page(*ptep);
  1036fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1036ff:	8b 00                	mov    (%eax),%eax
  103701:	89 04 24             	mov    %eax,(%esp)
  103704:	e8 42 f4 ff ff       	call   102b4b <pte2page>
  103709:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  10370c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10370f:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103712:	75 0d                	jne    103721 <page_insert+0x73>
            page_ref_dec(page);
  103714:	8b 45 0c             	mov    0xc(%ebp),%eax
  103717:	89 04 24             	mov    %eax,(%esp)
  10371a:	e8 b1 f4 ff ff       	call   102bd0 <page_ref_dec>
  10371f:	eb 19                	jmp    10373a <page_insert+0x8c>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  103721:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103724:	89 44 24 08          	mov    %eax,0x8(%esp)
  103728:	8b 45 10             	mov    0x10(%ebp),%eax
  10372b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10372f:	8b 45 08             	mov    0x8(%ebp),%eax
  103732:	89 04 24             	mov    %eax,(%esp)
  103735:	e8 c9 fe ff ff       	call   103603 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  10373a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10373d:	89 04 24             	mov    %eax,(%esp)
  103740:	e8 4d f3 ff ff       	call   102a92 <page2pa>
  103745:	0b 45 14             	or     0x14(%ebp),%eax
  103748:	83 c8 01             	or     $0x1,%eax
  10374b:	89 c2                	mov    %eax,%edx
  10374d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103750:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  103752:	8b 45 10             	mov    0x10(%ebp),%eax
  103755:	89 44 24 04          	mov    %eax,0x4(%esp)
  103759:	8b 45 08             	mov    0x8(%ebp),%eax
  10375c:	89 04 24             	mov    %eax,(%esp)
  10375f:	e8 07 00 00 00       	call   10376b <tlb_invalidate>
    return 0;
  103764:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103769:	c9                   	leave  
  10376a:	c3                   	ret    

0010376b <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  10376b:	f3 0f 1e fb          	endbr32 
  10376f:	55                   	push   %ebp
  103770:	89 e5                	mov    %esp,%ebp
  103772:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103775:	0f 20 d8             	mov    %cr3,%eax
  103778:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  10377b:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  10377e:	8b 45 08             	mov    0x8(%ebp),%eax
  103781:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103784:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  10378b:	77 23                	ja     1037b0 <tlb_invalidate+0x45>
  10378d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103790:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103794:	c7 44 24 08 04 6a 10 	movl   $0x106a04,0x8(%esp)
  10379b:	00 
  10379c:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
  1037a3:	00 
  1037a4:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1037ab:	e8 85 cc ff ff       	call   100435 <__panic>
  1037b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1037b3:	05 00 00 00 40       	add    $0x40000000,%eax
  1037b8:	39 d0                	cmp    %edx,%eax
  1037ba:	75 0d                	jne    1037c9 <tlb_invalidate+0x5e>
        invlpg((void *)la);
  1037bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  1037c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037c5:	0f 01 38             	invlpg (%eax)
}
  1037c8:	90                   	nop
    }
}
  1037c9:	90                   	nop
  1037ca:	c9                   	leave  
  1037cb:	c3                   	ret    

001037cc <check_alloc_page>:

static void
check_alloc_page(void) {
  1037cc:	f3 0f 1e fb          	endbr32 
  1037d0:	55                   	push   %ebp
  1037d1:	89 e5                	mov    %esp,%ebp
  1037d3:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  1037d6:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  1037db:	8b 40 18             	mov    0x18(%eax),%eax
  1037de:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  1037e0:	c7 04 24 88 6a 10 00 	movl   $0x106a88,(%esp)
  1037e7:	e8 dd ca ff ff       	call   1002c9 <cprintf>
}
  1037ec:	90                   	nop
  1037ed:	c9                   	leave  
  1037ee:	c3                   	ret    

001037ef <check_pgdir>:

static void
check_pgdir(void) {
  1037ef:	f3 0f 1e fb          	endbr32 
  1037f3:	55                   	push   %ebp
  1037f4:	89 e5                	mov    %esp,%ebp
  1037f6:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  1037f9:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  1037fe:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103803:	76 24                	jbe    103829 <check_pgdir+0x3a>
  103805:	c7 44 24 0c a7 6a 10 	movl   $0x106aa7,0xc(%esp)
  10380c:	00 
  10380d:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103814:	00 
  103815:	c7 44 24 04 e7 01 00 	movl   $0x1e7,0x4(%esp)
  10381c:	00 
  10381d:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103824:	e8 0c cc ff ff       	call   100435 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  103829:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10382e:	85 c0                	test   %eax,%eax
  103830:	74 0e                	je     103840 <check_pgdir+0x51>
  103832:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103837:	25 ff 0f 00 00       	and    $0xfff,%eax
  10383c:	85 c0                	test   %eax,%eax
  10383e:	74 24                	je     103864 <check_pgdir+0x75>
  103840:	c7 44 24 0c c4 6a 10 	movl   $0x106ac4,0xc(%esp)
  103847:	00 
  103848:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  10384f:	00 
  103850:	c7 44 24 04 e8 01 00 	movl   $0x1e8,0x4(%esp)
  103857:	00 
  103858:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  10385f:	e8 d1 cb ff ff       	call   100435 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  103864:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103869:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103870:	00 
  103871:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103878:	00 
  103879:	89 04 24             	mov    %eax,(%esp)
  10387c:	e8 25 fd ff ff       	call   1035a6 <get_page>
  103881:	85 c0                	test   %eax,%eax
  103883:	74 24                	je     1038a9 <check_pgdir+0xba>
  103885:	c7 44 24 0c fc 6a 10 	movl   $0x106afc,0xc(%esp)
  10388c:	00 
  10388d:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103894:	00 
  103895:	c7 44 24 04 e9 01 00 	movl   $0x1e9,0x4(%esp)
  10389c:	00 
  10389d:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1038a4:	e8 8c cb ff ff       	call   100435 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  1038a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1038b0:	e8 02 f5 ff ff       	call   102db7 <alloc_pages>
  1038b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  1038b8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1038bd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1038c4:	00 
  1038c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1038cc:	00 
  1038cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1038d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  1038d4:	89 04 24             	mov    %eax,(%esp)
  1038d7:	e8 d2 fd ff ff       	call   1036ae <page_insert>
  1038dc:	85 c0                	test   %eax,%eax
  1038de:	74 24                	je     103904 <check_pgdir+0x115>
  1038e0:	c7 44 24 0c 24 6b 10 	movl   $0x106b24,0xc(%esp)
  1038e7:	00 
  1038e8:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  1038ef:	00 
  1038f0:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  1038f7:	00 
  1038f8:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1038ff:	e8 31 cb ff ff       	call   100435 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  103904:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103909:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103910:	00 
  103911:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103918:	00 
  103919:	89 04 24             	mov    %eax,(%esp)
  10391c:	e8 3e fb ff ff       	call   10345f <get_pte>
  103921:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103924:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103928:	75 24                	jne    10394e <check_pgdir+0x15f>
  10392a:	c7 44 24 0c 50 6b 10 	movl   $0x106b50,0xc(%esp)
  103931:	00 
  103932:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103939:	00 
  10393a:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  103941:	00 
  103942:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103949:	e8 e7 ca ff ff       	call   100435 <__panic>
    assert(pte2page(*ptep) == p1);
  10394e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103951:	8b 00                	mov    (%eax),%eax
  103953:	89 04 24             	mov    %eax,(%esp)
  103956:	e8 f0 f1 ff ff       	call   102b4b <pte2page>
  10395b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10395e:	74 24                	je     103984 <check_pgdir+0x195>
  103960:	c7 44 24 0c 7d 6b 10 	movl   $0x106b7d,0xc(%esp)
  103967:	00 
  103968:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  10396f:	00 
  103970:	c7 44 24 04 f1 01 00 	movl   $0x1f1,0x4(%esp)
  103977:	00 
  103978:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  10397f:	e8 b1 ca ff ff       	call   100435 <__panic>
    assert(page_ref(p1) == 1);
  103984:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103987:	89 04 24             	mov    %eax,(%esp)
  10398a:	e8 12 f2 ff ff       	call   102ba1 <page_ref>
  10398f:	83 f8 01             	cmp    $0x1,%eax
  103992:	74 24                	je     1039b8 <check_pgdir+0x1c9>
  103994:	c7 44 24 0c 93 6b 10 	movl   $0x106b93,0xc(%esp)
  10399b:	00 
  10399c:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  1039a3:	00 
  1039a4:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  1039ab:	00 
  1039ac:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1039b3:	e8 7d ca ff ff       	call   100435 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  1039b8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1039bd:	8b 00                	mov    (%eax),%eax
  1039bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1039c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1039c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039ca:	c1 e8 0c             	shr    $0xc,%eax
  1039cd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1039d0:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  1039d5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1039d8:	72 23                	jb     1039fd <check_pgdir+0x20e>
  1039da:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1039dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1039e1:	c7 44 24 08 60 69 10 	movl   $0x106960,0x8(%esp)
  1039e8:	00 
  1039e9:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  1039f0:	00 
  1039f1:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1039f8:	e8 38 ca ff ff       	call   100435 <__panic>
  1039fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103a00:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103a05:	83 c0 04             	add    $0x4,%eax
  103a08:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  103a0b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103a10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a17:	00 
  103a18:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a1f:	00 
  103a20:	89 04 24             	mov    %eax,(%esp)
  103a23:	e8 37 fa ff ff       	call   10345f <get_pte>
  103a28:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103a2b:	74 24                	je     103a51 <check_pgdir+0x262>
  103a2d:	c7 44 24 0c a8 6b 10 	movl   $0x106ba8,0xc(%esp)
  103a34:	00 
  103a35:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103a3c:	00 
  103a3d:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  103a44:	00 
  103a45:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103a4c:	e8 e4 c9 ff ff       	call   100435 <__panic>

    p2 = alloc_page();
  103a51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103a58:	e8 5a f3 ff ff       	call   102db7 <alloc_pages>
  103a5d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  103a60:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103a65:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  103a6c:	00 
  103a6d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103a74:	00 
  103a75:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103a78:	89 54 24 04          	mov    %edx,0x4(%esp)
  103a7c:	89 04 24             	mov    %eax,(%esp)
  103a7f:	e8 2a fc ff ff       	call   1036ae <page_insert>
  103a84:	85 c0                	test   %eax,%eax
  103a86:	74 24                	je     103aac <check_pgdir+0x2bd>
  103a88:	c7 44 24 0c d0 6b 10 	movl   $0x106bd0,0xc(%esp)
  103a8f:	00 
  103a90:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103a97:	00 
  103a98:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  103a9f:	00 
  103aa0:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103aa7:	e8 89 c9 ff ff       	call   100435 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103aac:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103ab1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103ab8:	00 
  103ab9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103ac0:	00 
  103ac1:	89 04 24             	mov    %eax,(%esp)
  103ac4:	e8 96 f9 ff ff       	call   10345f <get_pte>
  103ac9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103acc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103ad0:	75 24                	jne    103af6 <check_pgdir+0x307>
  103ad2:	c7 44 24 0c 08 6c 10 	movl   $0x106c08,0xc(%esp)
  103ad9:	00 
  103ada:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103ae1:	00 
  103ae2:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103ae9:	00 
  103aea:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103af1:	e8 3f c9 ff ff       	call   100435 <__panic>
    assert(*ptep & PTE_U);
  103af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103af9:	8b 00                	mov    (%eax),%eax
  103afb:	83 e0 04             	and    $0x4,%eax
  103afe:	85 c0                	test   %eax,%eax
  103b00:	75 24                	jne    103b26 <check_pgdir+0x337>
  103b02:	c7 44 24 0c 38 6c 10 	movl   $0x106c38,0xc(%esp)
  103b09:	00 
  103b0a:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103b11:	00 
  103b12:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  103b19:	00 
  103b1a:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103b21:	e8 0f c9 ff ff       	call   100435 <__panic>
    assert(*ptep & PTE_W);
  103b26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103b29:	8b 00                	mov    (%eax),%eax
  103b2b:	83 e0 02             	and    $0x2,%eax
  103b2e:	85 c0                	test   %eax,%eax
  103b30:	75 24                	jne    103b56 <check_pgdir+0x367>
  103b32:	c7 44 24 0c 46 6c 10 	movl   $0x106c46,0xc(%esp)
  103b39:	00 
  103b3a:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103b41:	00 
  103b42:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  103b49:	00 
  103b4a:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103b51:	e8 df c8 ff ff       	call   100435 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103b56:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103b5b:	8b 00                	mov    (%eax),%eax
  103b5d:	83 e0 04             	and    $0x4,%eax
  103b60:	85 c0                	test   %eax,%eax
  103b62:	75 24                	jne    103b88 <check_pgdir+0x399>
  103b64:	c7 44 24 0c 54 6c 10 	movl   $0x106c54,0xc(%esp)
  103b6b:	00 
  103b6c:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103b73:	00 
  103b74:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  103b7b:	00 
  103b7c:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103b83:	e8 ad c8 ff ff       	call   100435 <__panic>
    assert(page_ref(p2) == 1);
  103b88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b8b:	89 04 24             	mov    %eax,(%esp)
  103b8e:	e8 0e f0 ff ff       	call   102ba1 <page_ref>
  103b93:	83 f8 01             	cmp    $0x1,%eax
  103b96:	74 24                	je     103bbc <check_pgdir+0x3cd>
  103b98:	c7 44 24 0c 6a 6c 10 	movl   $0x106c6a,0xc(%esp)
  103b9f:	00 
  103ba0:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103ba7:	00 
  103ba8:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  103baf:	00 
  103bb0:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103bb7:	e8 79 c8 ff ff       	call   100435 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103bbc:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103bc1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103bc8:	00 
  103bc9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103bd0:	00 
  103bd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103bd4:	89 54 24 04          	mov    %edx,0x4(%esp)
  103bd8:	89 04 24             	mov    %eax,(%esp)
  103bdb:	e8 ce fa ff ff       	call   1036ae <page_insert>
  103be0:	85 c0                	test   %eax,%eax
  103be2:	74 24                	je     103c08 <check_pgdir+0x419>
  103be4:	c7 44 24 0c 7c 6c 10 	movl   $0x106c7c,0xc(%esp)
  103beb:	00 
  103bec:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103bf3:	00 
  103bf4:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  103bfb:	00 
  103bfc:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103c03:	e8 2d c8 ff ff       	call   100435 <__panic>
    assert(page_ref(p1) == 2);
  103c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c0b:	89 04 24             	mov    %eax,(%esp)
  103c0e:	e8 8e ef ff ff       	call   102ba1 <page_ref>
  103c13:	83 f8 02             	cmp    $0x2,%eax
  103c16:	74 24                	je     103c3c <check_pgdir+0x44d>
  103c18:	c7 44 24 0c a8 6c 10 	movl   $0x106ca8,0xc(%esp)
  103c1f:	00 
  103c20:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103c27:	00 
  103c28:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  103c2f:	00 
  103c30:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103c37:	e8 f9 c7 ff ff       	call   100435 <__panic>
    assert(page_ref(p2) == 0);
  103c3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103c3f:	89 04 24             	mov    %eax,(%esp)
  103c42:	e8 5a ef ff ff       	call   102ba1 <page_ref>
  103c47:	85 c0                	test   %eax,%eax
  103c49:	74 24                	je     103c6f <check_pgdir+0x480>
  103c4b:	c7 44 24 0c ba 6c 10 	movl   $0x106cba,0xc(%esp)
  103c52:	00 
  103c53:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103c5a:	00 
  103c5b:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  103c62:	00 
  103c63:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103c6a:	e8 c6 c7 ff ff       	call   100435 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103c6f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103c74:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103c7b:	00 
  103c7c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103c83:	00 
  103c84:	89 04 24             	mov    %eax,(%esp)
  103c87:	e8 d3 f7 ff ff       	call   10345f <get_pte>
  103c8c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c8f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103c93:	75 24                	jne    103cb9 <check_pgdir+0x4ca>
  103c95:	c7 44 24 0c 08 6c 10 	movl   $0x106c08,0xc(%esp)
  103c9c:	00 
  103c9d:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103ca4:	00 
  103ca5:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  103cac:	00 
  103cad:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103cb4:	e8 7c c7 ff ff       	call   100435 <__panic>
    assert(pte2page(*ptep) == p1);
  103cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103cbc:	8b 00                	mov    (%eax),%eax
  103cbe:	89 04 24             	mov    %eax,(%esp)
  103cc1:	e8 85 ee ff ff       	call   102b4b <pte2page>
  103cc6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103cc9:	74 24                	je     103cef <check_pgdir+0x500>
  103ccb:	c7 44 24 0c 7d 6b 10 	movl   $0x106b7d,0xc(%esp)
  103cd2:	00 
  103cd3:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103cda:	00 
  103cdb:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  103ce2:	00 
  103ce3:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103cea:	e8 46 c7 ff ff       	call   100435 <__panic>
    assert((*ptep & PTE_U) == 0);
  103cef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103cf2:	8b 00                	mov    (%eax),%eax
  103cf4:	83 e0 04             	and    $0x4,%eax
  103cf7:	85 c0                	test   %eax,%eax
  103cf9:	74 24                	je     103d1f <check_pgdir+0x530>
  103cfb:	c7 44 24 0c cc 6c 10 	movl   $0x106ccc,0xc(%esp)
  103d02:	00 
  103d03:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103d0a:	00 
  103d0b:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  103d12:	00 
  103d13:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103d1a:	e8 16 c7 ff ff       	call   100435 <__panic>

    page_remove(boot_pgdir, 0x0);
  103d1f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103d24:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103d2b:	00 
  103d2c:	89 04 24             	mov    %eax,(%esp)
  103d2f:	e8 31 f9 ff ff       	call   103665 <page_remove>
    assert(page_ref(p1) == 1);
  103d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d37:	89 04 24             	mov    %eax,(%esp)
  103d3a:	e8 62 ee ff ff       	call   102ba1 <page_ref>
  103d3f:	83 f8 01             	cmp    $0x1,%eax
  103d42:	74 24                	je     103d68 <check_pgdir+0x579>
  103d44:	c7 44 24 0c 93 6b 10 	movl   $0x106b93,0xc(%esp)
  103d4b:	00 
  103d4c:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103d53:	00 
  103d54:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  103d5b:	00 
  103d5c:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103d63:	e8 cd c6 ff ff       	call   100435 <__panic>
    assert(page_ref(p2) == 0);
  103d68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103d6b:	89 04 24             	mov    %eax,(%esp)
  103d6e:	e8 2e ee ff ff       	call   102ba1 <page_ref>
  103d73:	85 c0                	test   %eax,%eax
  103d75:	74 24                	je     103d9b <check_pgdir+0x5ac>
  103d77:	c7 44 24 0c ba 6c 10 	movl   $0x106cba,0xc(%esp)
  103d7e:	00 
  103d7f:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103d86:	00 
  103d87:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  103d8e:	00 
  103d8f:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103d96:	e8 9a c6 ff ff       	call   100435 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103d9b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103da0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103da7:	00 
  103da8:	89 04 24             	mov    %eax,(%esp)
  103dab:	e8 b5 f8 ff ff       	call   103665 <page_remove>
    assert(page_ref(p1) == 0);
  103db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103db3:	89 04 24             	mov    %eax,(%esp)
  103db6:	e8 e6 ed ff ff       	call   102ba1 <page_ref>
  103dbb:	85 c0                	test   %eax,%eax
  103dbd:	74 24                	je     103de3 <check_pgdir+0x5f4>
  103dbf:	c7 44 24 0c e1 6c 10 	movl   $0x106ce1,0xc(%esp)
  103dc6:	00 
  103dc7:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103dce:	00 
  103dcf:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  103dd6:	00 
  103dd7:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103dde:	e8 52 c6 ff ff       	call   100435 <__panic>
    assert(page_ref(p2) == 0);
  103de3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103de6:	89 04 24             	mov    %eax,(%esp)
  103de9:	e8 b3 ed ff ff       	call   102ba1 <page_ref>
  103dee:	85 c0                	test   %eax,%eax
  103df0:	74 24                	je     103e16 <check_pgdir+0x627>
  103df2:	c7 44 24 0c ba 6c 10 	movl   $0x106cba,0xc(%esp)
  103df9:	00 
  103dfa:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103e01:	00 
  103e02:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  103e09:	00 
  103e0a:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103e11:	e8 1f c6 ff ff       	call   100435 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103e16:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103e1b:	8b 00                	mov    (%eax),%eax
  103e1d:	89 04 24             	mov    %eax,(%esp)
  103e20:	e8 64 ed ff ff       	call   102b89 <pde2page>
  103e25:	89 04 24             	mov    %eax,(%esp)
  103e28:	e8 74 ed ff ff       	call   102ba1 <page_ref>
  103e2d:	83 f8 01             	cmp    $0x1,%eax
  103e30:	74 24                	je     103e56 <check_pgdir+0x667>
  103e32:	c7 44 24 0c f4 6c 10 	movl   $0x106cf4,0xc(%esp)
  103e39:	00 
  103e3a:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103e41:	00 
  103e42:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  103e49:	00 
  103e4a:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103e51:	e8 df c5 ff ff       	call   100435 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103e56:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103e5b:	8b 00                	mov    (%eax),%eax
  103e5d:	89 04 24             	mov    %eax,(%esp)
  103e60:	e8 24 ed ff ff       	call   102b89 <pde2page>
  103e65:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103e6c:	00 
  103e6d:	89 04 24             	mov    %eax,(%esp)
  103e70:	e8 7e ef ff ff       	call   102df3 <free_pages>
    boot_pgdir[0] = 0;
  103e75:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103e7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103e80:	c7 04 24 1b 6d 10 00 	movl   $0x106d1b,(%esp)
  103e87:	e8 3d c4 ff ff       	call   1002c9 <cprintf>
}
  103e8c:	90                   	nop
  103e8d:	c9                   	leave  
  103e8e:	c3                   	ret    

00103e8f <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103e8f:	f3 0f 1e fb          	endbr32 
  103e93:	55                   	push   %ebp
  103e94:	89 e5                	mov    %esp,%ebp
  103e96:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103e99:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103ea0:	e9 ca 00 00 00       	jmp    103f6f <check_boot_pgdir+0xe0>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103ea5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103ea8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103eae:	c1 e8 0c             	shr    $0xc,%eax
  103eb1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103eb4:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  103eb9:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  103ebc:	72 23                	jb     103ee1 <check_boot_pgdir+0x52>
  103ebe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ec1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103ec5:	c7 44 24 08 60 69 10 	movl   $0x106960,0x8(%esp)
  103ecc:	00 
  103ecd:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
  103ed4:	00 
  103ed5:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103edc:	e8 54 c5 ff ff       	call   100435 <__panic>
  103ee1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ee4:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103ee9:	89 c2                	mov    %eax,%edx
  103eeb:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103ef0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103ef7:	00 
  103ef8:	89 54 24 04          	mov    %edx,0x4(%esp)
  103efc:	89 04 24             	mov    %eax,(%esp)
  103eff:	e8 5b f5 ff ff       	call   10345f <get_pte>
  103f04:	89 45 dc             	mov    %eax,-0x24(%ebp)
  103f07:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  103f0b:	75 24                	jne    103f31 <check_boot_pgdir+0xa2>
  103f0d:	c7 44 24 0c 38 6d 10 	movl   $0x106d38,0xc(%esp)
  103f14:	00 
  103f15:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103f1c:	00 
  103f1d:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
  103f24:	00 
  103f25:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103f2c:	e8 04 c5 ff ff       	call   100435 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103f31:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103f34:	8b 00                	mov    (%eax),%eax
  103f36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103f3b:	89 c2                	mov    %eax,%edx
  103f3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103f40:	39 c2                	cmp    %eax,%edx
  103f42:	74 24                	je     103f68 <check_boot_pgdir+0xd9>
  103f44:	c7 44 24 0c 75 6d 10 	movl   $0x106d75,0xc(%esp)
  103f4b:	00 
  103f4c:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103f53:	00 
  103f54:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  103f5b:	00 
  103f5c:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103f63:	e8 cd c4 ff ff       	call   100435 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  103f68:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103f6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103f72:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  103f77:	39 c2                	cmp    %eax,%edx
  103f79:	0f 82 26 ff ff ff    	jb     103ea5 <check_boot_pgdir+0x16>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103f7f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103f84:	05 ac 0f 00 00       	add    $0xfac,%eax
  103f89:	8b 00                	mov    (%eax),%eax
  103f8b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103f90:	89 c2                	mov    %eax,%edx
  103f92:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103f97:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103f9a:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103fa1:	77 23                	ja     103fc6 <check_boot_pgdir+0x137>
  103fa3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103fa6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103faa:	c7 44 24 08 04 6a 10 	movl   $0x106a04,0x8(%esp)
  103fb1:	00 
  103fb2:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  103fb9:	00 
  103fba:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103fc1:	e8 6f c4 ff ff       	call   100435 <__panic>
  103fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103fc9:	05 00 00 00 40       	add    $0x40000000,%eax
  103fce:	39 d0                	cmp    %edx,%eax
  103fd0:	74 24                	je     103ff6 <check_boot_pgdir+0x167>
  103fd2:	c7 44 24 0c 8c 6d 10 	movl   $0x106d8c,0xc(%esp)
  103fd9:	00 
  103fda:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  103fe1:	00 
  103fe2:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  103fe9:	00 
  103fea:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  103ff1:	e8 3f c4 ff ff       	call   100435 <__panic>

    assert(boot_pgdir[0] == 0);
  103ff6:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103ffb:	8b 00                	mov    (%eax),%eax
  103ffd:	85 c0                	test   %eax,%eax
  103fff:	74 24                	je     104025 <check_boot_pgdir+0x196>
  104001:	c7 44 24 0c c0 6d 10 	movl   $0x106dc0,0xc(%esp)
  104008:	00 
  104009:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  104010:	00 
  104011:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  104018:	00 
  104019:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  104020:	e8 10 c4 ff ff       	call   100435 <__panic>

    struct Page *p;
    p = alloc_page();
  104025:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10402c:	e8 86 ed ff ff       	call   102db7 <alloc_pages>
  104031:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  104034:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104039:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104040:	00 
  104041:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  104048:	00 
  104049:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10404c:	89 54 24 04          	mov    %edx,0x4(%esp)
  104050:	89 04 24             	mov    %eax,(%esp)
  104053:	e8 56 f6 ff ff       	call   1036ae <page_insert>
  104058:	85 c0                	test   %eax,%eax
  10405a:	74 24                	je     104080 <check_boot_pgdir+0x1f1>
  10405c:	c7 44 24 0c d4 6d 10 	movl   $0x106dd4,0xc(%esp)
  104063:	00 
  104064:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  10406b:	00 
  10406c:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
  104073:	00 
  104074:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  10407b:	e8 b5 c3 ff ff       	call   100435 <__panic>
    assert(page_ref(p) == 1);
  104080:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104083:	89 04 24             	mov    %eax,(%esp)
  104086:	e8 16 eb ff ff       	call   102ba1 <page_ref>
  10408b:	83 f8 01             	cmp    $0x1,%eax
  10408e:	74 24                	je     1040b4 <check_boot_pgdir+0x225>
  104090:	c7 44 24 0c 02 6e 10 	movl   $0x106e02,0xc(%esp)
  104097:	00 
  104098:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  10409f:	00 
  1040a0:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  1040a7:	00 
  1040a8:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1040af:	e8 81 c3 ff ff       	call   100435 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  1040b4:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1040b9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  1040c0:	00 
  1040c1:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  1040c8:	00 
  1040c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1040cc:	89 54 24 04          	mov    %edx,0x4(%esp)
  1040d0:	89 04 24             	mov    %eax,(%esp)
  1040d3:	e8 d6 f5 ff ff       	call   1036ae <page_insert>
  1040d8:	85 c0                	test   %eax,%eax
  1040da:	74 24                	je     104100 <check_boot_pgdir+0x271>
  1040dc:	c7 44 24 0c 14 6e 10 	movl   $0x106e14,0xc(%esp)
  1040e3:	00 
  1040e4:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  1040eb:	00 
  1040ec:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
  1040f3:	00 
  1040f4:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1040fb:	e8 35 c3 ff ff       	call   100435 <__panic>
    assert(page_ref(p) == 2);
  104100:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104103:	89 04 24             	mov    %eax,(%esp)
  104106:	e8 96 ea ff ff       	call   102ba1 <page_ref>
  10410b:	83 f8 02             	cmp    $0x2,%eax
  10410e:	74 24                	je     104134 <check_boot_pgdir+0x2a5>
  104110:	c7 44 24 0c 4b 6e 10 	movl   $0x106e4b,0xc(%esp)
  104117:	00 
  104118:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  10411f:	00 
  104120:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
  104127:	00 
  104128:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  10412f:	e8 01 c3 ff ff       	call   100435 <__panic>

    const char *str = "ucore: Hello world!!";
  104134:	c7 45 e8 5c 6e 10 00 	movl   $0x106e5c,-0x18(%ebp)
    strcpy((void *)0x100, str);
  10413b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10413e:	89 44 24 04          	mov    %eax,0x4(%esp)
  104142:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  104149:	e8 9e 15 00 00       	call   1056ec <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  10414e:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  104155:	00 
  104156:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  10415d:	e8 08 16 00 00       	call   10576a <strcmp>
  104162:	85 c0                	test   %eax,%eax
  104164:	74 24                	je     10418a <check_boot_pgdir+0x2fb>
  104166:	c7 44 24 0c 74 6e 10 	movl   $0x106e74,0xc(%esp)
  10416d:	00 
  10416e:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  104175:	00 
  104176:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  10417d:	00 
  10417e:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  104185:	e8 ab c2 ff ff       	call   100435 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  10418a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10418d:	89 04 24             	mov    %eax,(%esp)
  104190:	e8 62 e9 ff ff       	call   102af7 <page2kva>
  104195:	05 00 01 00 00       	add    $0x100,%eax
  10419a:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  10419d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1041a4:	e8 e5 14 00 00       	call   10568e <strlen>
  1041a9:	85 c0                	test   %eax,%eax
  1041ab:	74 24                	je     1041d1 <check_boot_pgdir+0x342>
  1041ad:	c7 44 24 0c ac 6e 10 	movl   $0x106eac,0xc(%esp)
  1041b4:	00 
  1041b5:	c7 44 24 08 4d 6a 10 	movl   $0x106a4d,0x8(%esp)
  1041bc:	00 
  1041bd:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
  1041c4:	00 
  1041c5:	c7 04 24 28 6a 10 00 	movl   $0x106a28,(%esp)
  1041cc:	e8 64 c2 ff ff       	call   100435 <__panic>

    free_page(p);
  1041d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1041d8:	00 
  1041d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1041dc:	89 04 24             	mov    %eax,(%esp)
  1041df:	e8 0f ec ff ff       	call   102df3 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  1041e4:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1041e9:	8b 00                	mov    (%eax),%eax
  1041eb:	89 04 24             	mov    %eax,(%esp)
  1041ee:	e8 96 e9 ff ff       	call   102b89 <pde2page>
  1041f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1041fa:	00 
  1041fb:	89 04 24             	mov    %eax,(%esp)
  1041fe:	e8 f0 eb ff ff       	call   102df3 <free_pages>
    boot_pgdir[0] = 0;
  104203:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104208:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  10420e:	c7 04 24 d0 6e 10 00 	movl   $0x106ed0,(%esp)
  104215:	e8 af c0 ff ff       	call   1002c9 <cprintf>
}
  10421a:	90                   	nop
  10421b:	c9                   	leave  
  10421c:	c3                   	ret    

0010421d <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  10421d:	f3 0f 1e fb          	endbr32 
  104221:	55                   	push   %ebp
  104222:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  104224:	8b 45 08             	mov    0x8(%ebp),%eax
  104227:	83 e0 04             	and    $0x4,%eax
  10422a:	85 c0                	test   %eax,%eax
  10422c:	74 04                	je     104232 <perm2str+0x15>
  10422e:	b0 75                	mov    $0x75,%al
  104230:	eb 02                	jmp    104234 <perm2str+0x17>
  104232:	b0 2d                	mov    $0x2d,%al
  104234:	a2 08 cf 11 00       	mov    %al,0x11cf08
    str[1] = 'r';
  104239:	c6 05 09 cf 11 00 72 	movb   $0x72,0x11cf09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  104240:	8b 45 08             	mov    0x8(%ebp),%eax
  104243:	83 e0 02             	and    $0x2,%eax
  104246:	85 c0                	test   %eax,%eax
  104248:	74 04                	je     10424e <perm2str+0x31>
  10424a:	b0 77                	mov    $0x77,%al
  10424c:	eb 02                	jmp    104250 <perm2str+0x33>
  10424e:	b0 2d                	mov    $0x2d,%al
  104250:	a2 0a cf 11 00       	mov    %al,0x11cf0a
    str[3] = '\0';
  104255:	c6 05 0b cf 11 00 00 	movb   $0x0,0x11cf0b
    return str;
  10425c:	b8 08 cf 11 00       	mov    $0x11cf08,%eax
}
  104261:	5d                   	pop    %ebp
  104262:	c3                   	ret    

00104263 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  104263:	f3 0f 1e fb          	endbr32 
  104267:	55                   	push   %ebp
  104268:	89 e5                	mov    %esp,%ebp
  10426a:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  10426d:	8b 45 10             	mov    0x10(%ebp),%eax
  104270:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104273:	72 0d                	jb     104282 <get_pgtable_items+0x1f>
        return 0;
  104275:	b8 00 00 00 00       	mov    $0x0,%eax
  10427a:	e9 98 00 00 00       	jmp    104317 <get_pgtable_items+0xb4>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  10427f:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  104282:	8b 45 10             	mov    0x10(%ebp),%eax
  104285:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104288:	73 18                	jae    1042a2 <get_pgtable_items+0x3f>
  10428a:	8b 45 10             	mov    0x10(%ebp),%eax
  10428d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104294:	8b 45 14             	mov    0x14(%ebp),%eax
  104297:	01 d0                	add    %edx,%eax
  104299:	8b 00                	mov    (%eax),%eax
  10429b:	83 e0 01             	and    $0x1,%eax
  10429e:	85 c0                	test   %eax,%eax
  1042a0:	74 dd                	je     10427f <get_pgtable_items+0x1c>
    }
    if (start < right) {
  1042a2:	8b 45 10             	mov    0x10(%ebp),%eax
  1042a5:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1042a8:	73 68                	jae    104312 <get_pgtable_items+0xaf>
        if (left_store != NULL) {
  1042aa:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1042ae:	74 08                	je     1042b8 <get_pgtable_items+0x55>
            *left_store = start;
  1042b0:	8b 45 18             	mov    0x18(%ebp),%eax
  1042b3:	8b 55 10             	mov    0x10(%ebp),%edx
  1042b6:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  1042b8:	8b 45 10             	mov    0x10(%ebp),%eax
  1042bb:	8d 50 01             	lea    0x1(%eax),%edx
  1042be:	89 55 10             	mov    %edx,0x10(%ebp)
  1042c1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1042c8:	8b 45 14             	mov    0x14(%ebp),%eax
  1042cb:	01 d0                	add    %edx,%eax
  1042cd:	8b 00                	mov    (%eax),%eax
  1042cf:	83 e0 07             	and    $0x7,%eax
  1042d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1042d5:	eb 03                	jmp    1042da <get_pgtable_items+0x77>
            start ++;
  1042d7:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  1042da:	8b 45 10             	mov    0x10(%ebp),%eax
  1042dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1042e0:	73 1d                	jae    1042ff <get_pgtable_items+0x9c>
  1042e2:	8b 45 10             	mov    0x10(%ebp),%eax
  1042e5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1042ec:	8b 45 14             	mov    0x14(%ebp),%eax
  1042ef:	01 d0                	add    %edx,%eax
  1042f1:	8b 00                	mov    (%eax),%eax
  1042f3:	83 e0 07             	and    $0x7,%eax
  1042f6:	89 c2                	mov    %eax,%edx
  1042f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1042fb:	39 c2                	cmp    %eax,%edx
  1042fd:	74 d8                	je     1042d7 <get_pgtable_items+0x74>
        }
        if (right_store != NULL) {
  1042ff:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  104303:	74 08                	je     10430d <get_pgtable_items+0xaa>
            *right_store = start;
  104305:	8b 45 1c             	mov    0x1c(%ebp),%eax
  104308:	8b 55 10             	mov    0x10(%ebp),%edx
  10430b:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  10430d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104310:	eb 05                	jmp    104317 <get_pgtable_items+0xb4>
    }
    return 0;
  104312:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104317:	c9                   	leave  
  104318:	c3                   	ret    

00104319 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  104319:	f3 0f 1e fb          	endbr32 
  10431d:	55                   	push   %ebp
  10431e:	89 e5                	mov    %esp,%ebp
  104320:	57                   	push   %edi
  104321:	56                   	push   %esi
  104322:	53                   	push   %ebx
  104323:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  104326:	c7 04 24 f0 6e 10 00 	movl   $0x106ef0,(%esp)
  10432d:	e8 97 bf ff ff       	call   1002c9 <cprintf>
    size_t left, right = 0, perm;
  104332:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104339:	e9 fa 00 00 00       	jmp    104438 <print_pgdir+0x11f>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10433e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104341:	89 04 24             	mov    %eax,(%esp)
  104344:	e8 d4 fe ff ff       	call   10421d <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  104349:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10434c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10434f:	29 d1                	sub    %edx,%ecx
  104351:	89 ca                	mov    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  104353:	89 d6                	mov    %edx,%esi
  104355:	c1 e6 16             	shl    $0x16,%esi
  104358:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10435b:	89 d3                	mov    %edx,%ebx
  10435d:	c1 e3 16             	shl    $0x16,%ebx
  104360:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104363:	89 d1                	mov    %edx,%ecx
  104365:	c1 e1 16             	shl    $0x16,%ecx
  104368:	8b 7d dc             	mov    -0x24(%ebp),%edi
  10436b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10436e:	29 d7                	sub    %edx,%edi
  104370:	89 fa                	mov    %edi,%edx
  104372:	89 44 24 14          	mov    %eax,0x14(%esp)
  104376:	89 74 24 10          	mov    %esi,0x10(%esp)
  10437a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10437e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104382:	89 54 24 04          	mov    %edx,0x4(%esp)
  104386:	c7 04 24 21 6f 10 00 	movl   $0x106f21,(%esp)
  10438d:	e8 37 bf ff ff       	call   1002c9 <cprintf>
        size_t l, r = left * NPTEENTRY;
  104392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104395:	c1 e0 0a             	shl    $0xa,%eax
  104398:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10439b:	eb 54                	jmp    1043f1 <print_pgdir+0xd8>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10439d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1043a0:	89 04 24             	mov    %eax,(%esp)
  1043a3:	e8 75 fe ff ff       	call   10421d <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1043a8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1043ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043ae:	29 d1                	sub    %edx,%ecx
  1043b0:	89 ca                	mov    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1043b2:	89 d6                	mov    %edx,%esi
  1043b4:	c1 e6 0c             	shl    $0xc,%esi
  1043b7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043ba:	89 d3                	mov    %edx,%ebx
  1043bc:	c1 e3 0c             	shl    $0xc,%ebx
  1043bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043c2:	89 d1                	mov    %edx,%ecx
  1043c4:	c1 e1 0c             	shl    $0xc,%ecx
  1043c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  1043ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043cd:	29 d7                	sub    %edx,%edi
  1043cf:	89 fa                	mov    %edi,%edx
  1043d1:	89 44 24 14          	mov    %eax,0x14(%esp)
  1043d5:	89 74 24 10          	mov    %esi,0x10(%esp)
  1043d9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1043dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1043e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  1043e5:	c7 04 24 40 6f 10 00 	movl   $0x106f40,(%esp)
  1043ec:	e8 d8 be ff ff       	call   1002c9 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1043f1:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  1043f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1043f9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1043fc:	89 d3                	mov    %edx,%ebx
  1043fe:	c1 e3 0a             	shl    $0xa,%ebx
  104401:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104404:	89 d1                	mov    %edx,%ecx
  104406:	c1 e1 0a             	shl    $0xa,%ecx
  104409:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  10440c:	89 54 24 14          	mov    %edx,0x14(%esp)
  104410:	8d 55 d8             	lea    -0x28(%ebp),%edx
  104413:	89 54 24 10          	mov    %edx,0x10(%esp)
  104417:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10441b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10441f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104423:	89 0c 24             	mov    %ecx,(%esp)
  104426:	e8 38 fe ff ff       	call   104263 <get_pgtable_items>
  10442b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10442e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104432:	0f 85 65 ff ff ff    	jne    10439d <print_pgdir+0x84>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  104438:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  10443d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104440:	8d 55 dc             	lea    -0x24(%ebp),%edx
  104443:	89 54 24 14          	mov    %edx,0x14(%esp)
  104447:	8d 55 e0             	lea    -0x20(%ebp),%edx
  10444a:	89 54 24 10          	mov    %edx,0x10(%esp)
  10444e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  104452:	89 44 24 08          	mov    %eax,0x8(%esp)
  104456:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  10445d:	00 
  10445e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  104465:	e8 f9 fd ff ff       	call   104263 <get_pgtable_items>
  10446a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10446d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104471:	0f 85 c7 fe ff ff    	jne    10433e <print_pgdir+0x25>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  104477:	c7 04 24 64 6f 10 00 	movl   $0x106f64,(%esp)
  10447e:	e8 46 be ff ff       	call   1002c9 <cprintf>
}
  104483:	90                   	nop
  104484:	83 c4 4c             	add    $0x4c,%esp
  104487:	5b                   	pop    %ebx
  104488:	5e                   	pop    %esi
  104489:	5f                   	pop    %edi
  10448a:	5d                   	pop    %ebp
  10448b:	c3                   	ret    

0010448c <page2ppn>:
page2ppn(struct Page *page) {
  10448c:	55                   	push   %ebp
  10448d:	89 e5                	mov    %esp,%ebp
    return page - pages;
  10448f:	a1 18 cf 11 00       	mov    0x11cf18,%eax
  104494:	8b 55 08             	mov    0x8(%ebp),%edx
  104497:	29 c2                	sub    %eax,%edx
  104499:	89 d0                	mov    %edx,%eax
  10449b:	c1 f8 02             	sar    $0x2,%eax
  10449e:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  1044a4:	5d                   	pop    %ebp
  1044a5:	c3                   	ret    

001044a6 <page2pa>:
page2pa(struct Page *page) {
  1044a6:	55                   	push   %ebp
  1044a7:	89 e5                	mov    %esp,%ebp
  1044a9:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  1044ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1044af:	89 04 24             	mov    %eax,(%esp)
  1044b2:	e8 d5 ff ff ff       	call   10448c <page2ppn>
  1044b7:	c1 e0 0c             	shl    $0xc,%eax
}
  1044ba:	c9                   	leave  
  1044bb:	c3                   	ret    

001044bc <page_ref>:
page_ref(struct Page *page) {
  1044bc:	55                   	push   %ebp
  1044bd:	89 e5                	mov    %esp,%ebp
    return page->ref;
  1044bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1044c2:	8b 00                	mov    (%eax),%eax
}
  1044c4:	5d                   	pop    %ebp
  1044c5:	c3                   	ret    

001044c6 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  1044c6:	55                   	push   %ebp
  1044c7:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  1044c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1044cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  1044cf:	89 10                	mov    %edx,(%eax)
}
  1044d1:	90                   	nop
  1044d2:	5d                   	pop    %ebp
  1044d3:	c3                   	ret    

001044d4 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  1044d4:	f3 0f 1e fb          	endbr32 
  1044d8:	55                   	push   %ebp
  1044d9:	89 e5                	mov    %esp,%ebp
  1044db:	83 ec 10             	sub    $0x10,%esp
  1044de:	c7 45 fc 1c cf 11 00 	movl   $0x11cf1c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  1044e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1044e8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1044eb:	89 50 04             	mov    %edx,0x4(%eax)
  1044ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1044f1:	8b 50 04             	mov    0x4(%eax),%edx
  1044f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1044f7:	89 10                	mov    %edx,(%eax)
}
  1044f9:	90                   	nop
    // 初始化链表
    list_init(&free_list);
    // 将可用内存块数目设置为0
    nr_free = 0;
  1044fa:	c7 05 24 cf 11 00 00 	movl   $0x0,0x11cf24
  104501:	00 00 00 
}
  104504:	90                   	nop
  104505:	c9                   	leave  
  104506:	c3                   	ret    

00104507 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  104507:	f3 0f 1e fb          	endbr32 
  10450b:	55                   	push   %ebp
  10450c:	89 e5                	mov    %esp,%ebp
  10450e:	83 ec 48             	sub    $0x48,%esp
    // n要大于0
    assert(n > 0);
  104511:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104515:	75 24                	jne    10453b <default_init_memmap+0x34>
  104517:	c7 44 24 0c 98 6f 10 	movl   $0x106f98,0xc(%esp)
  10451e:	00 
  10451f:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104526:	00 
  104527:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  10452e:	00 
  10452f:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104536:	e8 fa be ff ff       	call   100435 <__panic>
    // 令p为连续地址的空闲块的起始页
    struct Page *p = base;
  10453b:	8b 45 08             	mov    0x8(%ebp),%eax
  10453e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 将这个空闲块的每个页面初始化
    for (; p != base + n; p ++) {
  104541:	e9 a7 00 00 00       	jmp    1045ed <default_init_memmap+0xe6>
        // 每次循环首先检查p的PG_reserved位是否设置为1，表示空闲可分配
        assert(PageReserved(p));
  104546:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104549:	83 c0 04             	add    $0x4,%eax
  10454c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  104553:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104556:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104559:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10455c:	0f a3 10             	bt     %edx,(%eax)
  10455f:	19 c0                	sbb    %eax,%eax
  104561:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  104564:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104568:	0f 95 c0             	setne  %al
  10456b:	0f b6 c0             	movzbl %al,%eax
  10456e:	85 c0                	test   %eax,%eax
  104570:	75 24                	jne    104596 <default_init_memmap+0x8f>
  104572:	c7 44 24 0c c9 6f 10 	movl   $0x106fc9,0xc(%esp)
  104579:	00 
  10457a:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104581:	00 
  104582:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
  104589:	00 
  10458a:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104591:	e8 9f be ff ff       	call   100435 <__panic>
        // 设置这一页的flag为0，表示这页空闲
        p->flags = 0;
  104596:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104599:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        // 将这一页的ref设为0，因为这页现在空闲，没有引用
        set_page_ref(p, 0);
  1045a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1045a7:	00 
  1045a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045ab:	89 04 24             	mov    %eax,(%esp)
  1045ae:	e8 13 ff ff ff       	call   1044c6 <set_page_ref>
        // 如果是空闲块的起始页
        if (p == base) {
  1045b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045b6:	3b 45 08             	cmp    0x8(%ebp),%eax
  1045b9:	75 24                	jne    1045df <default_init_memmap+0xd8>
            // 空闲块的第一页的连续空页值property设置为块中的总页数
            p->property = n;
  1045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045be:	8b 55 0c             	mov    0xc(%ebp),%edx
  1045c1:	89 50 08             	mov    %edx,0x8(%eax)
            // 将空闲块的第一页的PG_property位设置为1，表示是起始页，可以被用作分配内存
            SetPageProperty(p);
  1045c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045c7:	83 c0 04             	add    $0x4,%eax
  1045ca:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  1045d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1045d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1045d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1045da:	0f ab 10             	bts    %edx,(%eax)
}
  1045dd:	eb 0a                	jmp    1045e9 <default_init_memmap+0xe2>
        } else {
            // 设置非起始页的property为0，表示不是qisiye起始页
            p->property = 0;
  1045df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    for (; p != base + n; p ++) {
  1045e9:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1045ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  1045f0:	89 d0                	mov    %edx,%eax
  1045f2:	c1 e0 02             	shl    $0x2,%eax
  1045f5:	01 d0                	add    %edx,%eax
  1045f7:	c1 e0 02             	shl    $0x2,%eax
  1045fa:	89 c2                	mov    %eax,%edx
  1045fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1045ff:	01 d0                	add    %edx,%eax
  104601:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104604:	0f 85 3c ff ff ff    	jne    104546 <default_init_memmap+0x3f>
        }
    }
    // 将base->page_link此页链接到free_list中
    list_add_before(&free_list, &(base->page_link));
  10460a:	8b 45 08             	mov    0x8(%ebp),%eax
  10460d:	83 c0 0c             	add    $0xc,%eax
  104610:	c7 45 dc 1c cf 11 00 	movl   $0x11cf1c,-0x24(%ebp)
  104617:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  10461a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10461d:	8b 00                	mov    (%eax),%eax
  10461f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104622:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104625:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104628:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10462b:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  10462e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104631:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104634:	89 10                	mov    %edx,(%eax)
  104636:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104639:	8b 10                	mov    (%eax),%edx
  10463b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10463e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104641:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104644:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104647:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10464a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10464d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  104650:	89 10                	mov    %edx,(%eax)
}
  104652:	90                   	nop
}
  104653:	90                   	nop
    // 将空闲页的数目加n
    nr_free += n;
  104654:	8b 15 24 cf 11 00    	mov    0x11cf24,%edx
  10465a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10465d:	01 d0                	add    %edx,%eax
  10465f:	a3 24 cf 11 00       	mov    %eax,0x11cf24
}
  104664:	90                   	nop
  104665:	c9                   	leave  
  104666:	c3                   	ret    

00104667 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  104667:	f3 0f 1e fb          	endbr32 
  10466b:	55                   	push   %ebp
  10466c:	89 e5                	mov    %esp,%ebp
  10466e:	83 ec 68             	sub    $0x68,%esp
    // n要大于0
    assert(n > 0);
  104671:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  104675:	75 24                	jne    10469b <default_alloc_pages+0x34>
  104677:	c7 44 24 0c 98 6f 10 	movl   $0x106f98,0xc(%esp)
  10467e:	00 
  10467f:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104686:	00 
  104687:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  10468e:	00 
  10468f:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104696:	e8 9a bd ff ff       	call   100435 <__panic>
    // 考虑边界情况，当n大于可以分配的内存数时，直接返回，确保分配不会超出范围，保证软件的鲁棒性
    if (n > nr_free) {
  10469b:	a1 24 cf 11 00       	mov    0x11cf24,%eax
  1046a0:	39 45 08             	cmp    %eax,0x8(%ebp)
  1046a3:	76 0a                	jbe    1046af <default_alloc_pages+0x48>
        return NULL;
  1046a5:	b8 00 00 00 00       	mov    $0x0,%eax
  1046aa:	e9 4e 01 00 00       	jmp    1047fd <default_alloc_pages+0x196>
    }
    struct Page *page = NULL;
  1046af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = &free_list;
  1046b6:	c7 45 f0 1c cf 11 00 	movl   $0x11cf1c,-0x10(%ebp)
    // 遍历空闲链表
    while ((le = list_next(le)) != &free_list) {
  1046bd:	eb 1c                	jmp    1046db <default_alloc_pages+0x74>
        // 由链表元素获得对应的Page指针p
        struct Page *p = le2page(le, page_link);
  1046bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046c2:	83 e8 0c             	sub    $0xc,%eax
  1046c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // 如果当前页面的property大于等于n，说明空闲块的连续空页数大于等于n，可以分配，令page等于p，直接退出
        if (p->property >= n) {
  1046c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1046cb:	8b 40 08             	mov    0x8(%eax),%eax
  1046ce:	39 45 08             	cmp    %eax,0x8(%ebp)
  1046d1:	77 08                	ja     1046db <default_alloc_pages+0x74>
            page = p;
  1046d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1046d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  1046d9:	eb 18                	jmp    1046f3 <default_alloc_pages+0x8c>
  1046db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1046de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  1046e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1046e4:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1046e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1046ea:	81 7d f0 1c cf 11 00 	cmpl   $0x11cf1c,-0x10(%ebp)
  1046f1:	75 cc                	jne    1046bf <default_alloc_pages+0x58>
        }
    }
    // 如果找到了空闲块，进行重新组织
    if (page != NULL) {
  1046f3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1046f7:	0f 84 fd 00 00 00    	je     1047fa <default_alloc_pages+0x193>
        // 在空闲页链表中删除刚刚分配的空闲块
        list_del(&(page->page_link));
  1046fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104700:	83 c0 0c             	add    $0xc,%eax
  104703:	89 45 e0             	mov    %eax,-0x20(%ebp)
    __list_del(listelm->prev, listelm->next);
  104706:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104709:	8b 40 04             	mov    0x4(%eax),%eax
  10470c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10470f:	8b 12                	mov    (%edx),%edx
  104711:	89 55 dc             	mov    %edx,-0x24(%ebp)
  104714:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104717:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10471a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10471d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104720:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104723:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104726:	89 10                	mov    %edx,(%eax)
}
  104728:	90                   	nop
}
  104729:	90                   	nop
        // 如果可以分配的空闲块的连续空页数大于n
        if (page->property > n) {
  10472a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10472d:	8b 40 08             	mov    0x8(%eax),%eax
  104730:	39 45 08             	cmp    %eax,0x8(%ebp)
  104733:	0f 83 9a 00 00 00    	jae    1047d3 <default_alloc_pages+0x16c>
            // 创建一个地址为page+n的新物理页
            struct Page *p = page + n;
  104739:	8b 55 08             	mov    0x8(%ebp),%edx
  10473c:	89 d0                	mov    %edx,%eax
  10473e:	c1 e0 02             	shl    $0x2,%eax
  104741:	01 d0                	add    %edx,%eax
  104743:	c1 e0 02             	shl    $0x2,%eax
  104746:	89 c2                	mov    %eax,%edx
  104748:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10474b:	01 d0                	add    %edx,%eax
  10474d:	89 45 e8             	mov    %eax,-0x18(%ebp)
            // 页面的property设置为page多出来的空闲连续页数
            p->property = page->property - n;
  104750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104753:	8b 40 08             	mov    0x8(%eax),%eax
  104756:	2b 45 08             	sub    0x8(%ebp),%eax
  104759:	89 c2                	mov    %eax,%edx
  10475b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10475e:	89 50 08             	mov    %edx,0x8(%eax)
            // 设置p的Page_property位，表示为新的空闲块的起始页
            SetPageProperty(p);
  104761:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104764:	83 c0 04             	add    $0x4,%eax
  104767:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  10476e:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104771:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104774:	8b 55 b8             	mov    -0x48(%ebp),%edx
  104777:	0f ab 10             	bts    %edx,(%eax)
}
  10477a:	90                   	nop
            // 将新的空闲块的页插入到空闲页链表的后面
            list_add(&free_list, &(p->page_link));
  10477b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10477e:	83 c0 0c             	add    $0xc,%eax
  104781:	c7 45 d4 1c cf 11 00 	movl   $0x11cf1c,-0x2c(%ebp)
  104788:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10478b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10478e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  104791:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104794:	89 45 c8             	mov    %eax,-0x38(%ebp)
    __list_add(elm, listelm, listelm->next);
  104797:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10479a:	8b 40 04             	mov    0x4(%eax),%eax
  10479d:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1047a0:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  1047a3:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1047a6:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1047a9:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next->prev = elm;
  1047ac:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1047af:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1047b2:	89 10                	mov    %edx,(%eax)
  1047b4:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1047b7:	8b 10                	mov    (%eax),%edx
  1047b9:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1047bc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1047bf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1047c2:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1047c5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1047c8:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1047cb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1047ce:	89 10                	mov    %edx,(%eax)
}
  1047d0:	90                   	nop
}
  1047d1:	90                   	nop
}
  1047d2:	90                   	nop
        }
        // 剩余空闲页的数目减n
        nr_free -= n;
  1047d3:	a1 24 cf 11 00       	mov    0x11cf24,%eax
  1047d8:	2b 45 08             	sub    0x8(%ebp),%eax
  1047db:	a3 24 cf 11 00       	mov    %eax,0x11cf24
        // 清除page的Page_property位，表示page已经被分配
        ClearPageProperty(page);
  1047e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047e3:	83 c0 04             	add    $0x4,%eax
  1047e6:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  1047ed:	89 45 ac             	mov    %eax,-0x54(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1047f0:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1047f3:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1047f6:	0f b3 10             	btr    %edx,(%eax)
}
  1047f9:	90                   	nop
    }
    // 没有找到空闲块，则直接返回NULL，否则返回空闲块page
    return page;
  1047fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1047fd:	c9                   	leave  
  1047fe:	c3                   	ret    

001047ff <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  1047ff:	f3 0f 1e fb          	endbr32 
  104803:	55                   	push   %ebp
  104804:	89 e5                	mov    %esp,%ebp
  104806:	81 ec 88 00 00 00    	sub    $0x88,%esp
    // n要大于0
    assert(n > 0);
  10480c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104810:	75 24                	jne    104836 <default_free_pages+0x37>
  104812:	c7 44 24 0c 98 6f 10 	movl   $0x106f98,0xc(%esp)
  104819:	00 
  10481a:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104821:	00 
  104822:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
  104829:	00 
  10482a:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104831:	e8 ff bb ff ff       	call   100435 <__panic>
    // 令p为连续地址的释放块的起始页
    struct Page *p = base;
  104836:	8b 45 08             	mov    0x8(%ebp),%eax
  104839:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 将这个释放块的每个页面初始化
    for (; p != base + n; p ++) {
  10483c:	e9 9d 00 00 00       	jmp    1048de <default_free_pages+0xdf>
        // 检查每一页的Page_reserved位和Page_property是否都未被设置
        assert(!PageReserved(p) && !PageProperty(p));
  104841:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104844:	83 c0 04             	add    $0x4,%eax
  104847:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  10484e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104851:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104854:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104857:	0f a3 10             	bt     %edx,(%eax)
  10485a:	19 c0                	sbb    %eax,%eax
  10485c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  10485f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104863:	0f 95 c0             	setne  %al
  104866:	0f b6 c0             	movzbl %al,%eax
  104869:	85 c0                	test   %eax,%eax
  10486b:	75 2c                	jne    104899 <default_free_pages+0x9a>
  10486d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104870:	83 c0 04             	add    $0x4,%eax
  104873:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  10487a:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10487d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104880:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104883:	0f a3 10             	bt     %edx,(%eax)
  104886:	19 c0                	sbb    %eax,%eax
  104888:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  10488b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  10488f:	0f 95 c0             	setne  %al
  104892:	0f b6 c0             	movzbl %al,%eax
  104895:	85 c0                	test   %eax,%eax
  104897:	74 24                	je     1048bd <default_free_pages+0xbe>
  104899:	c7 44 24 0c dc 6f 10 	movl   $0x106fdc,0xc(%esp)
  1048a0:	00 
  1048a1:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  1048a8:	00 
  1048a9:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
  1048b0:	00 
  1048b1:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  1048b8:	e8 78 bb ff ff       	call   100435 <__panic>
        // 设置每一页的flags都为0，表示可以分配
        p->flags = 0;
  1048bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048c0:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        // 设置每一页的ref都为0，表示这页空闲
        set_page_ref(p, 0);
  1048c7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1048ce:	00 
  1048cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048d2:	89 04 24             	mov    %eax,(%esp)
  1048d5:	e8 ec fb ff ff       	call   1044c6 <set_page_ref>
    for (; p != base + n; p ++) {
  1048da:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1048de:	8b 55 0c             	mov    0xc(%ebp),%edx
  1048e1:	89 d0                	mov    %edx,%eax
  1048e3:	c1 e0 02             	shl    $0x2,%eax
  1048e6:	01 d0                	add    %edx,%eax
  1048e8:	c1 e0 02             	shl    $0x2,%eax
  1048eb:	89 c2                	mov    %eax,%edx
  1048ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1048f0:	01 d0                	add    %edx,%eax
  1048f2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  1048f5:	0f 85 46 ff ff ff    	jne    104841 <default_free_pages+0x42>
    }
    // 释放块起始页的property连续空页数设置为n
    base->property = n;
  1048fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1048fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  104901:	89 50 08             	mov    %edx,0x8(%eax)
    // 设置起始页的Page_property位
    SetPageProperty(base);
  104904:	8b 45 08             	mov    0x8(%ebp),%eax
  104907:	83 c0 04             	add    $0x4,%eax
  10490a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  104911:	89 45 d0             	mov    %eax,-0x30(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104914:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104917:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10491a:	0f ab 10             	bts    %edx,(%eax)
}
  10491d:	90                   	nop
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = &free_list;
  10491e:	c7 45 f0 1c cf 11 00 	movl   $0x11cf1c,-0x10(%ebp)
    // 遍历空闲链表，查看能否将释放块合并到合适的页块中
    while ((le = list_next(le)) != &free_list) {
  104925:	e9 ff 00 00 00       	jmp    104a29 <default_free_pages+0x22a>
        // 由链表元素获得对应的Page指针p
        p = le2page(le, page_link);
  10492a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10492d:	83 e8 0c             	sub    $0xc,%eax
  104930:	89 45 f4             	mov    %eax,-0xc(%ebp)
        // 如果释放块在下一个空闲块起始页的前面，那么进行合并
        if (base + base->property == p) {
  104933:	8b 45 08             	mov    0x8(%ebp),%eax
  104936:	8b 50 08             	mov    0x8(%eax),%edx
  104939:	89 d0                	mov    %edx,%eax
  10493b:	c1 e0 02             	shl    $0x2,%eax
  10493e:	01 d0                	add    %edx,%eax
  104940:	c1 e0 02             	shl    $0x2,%eax
  104943:	89 c2                	mov    %eax,%edx
  104945:	8b 45 08             	mov    0x8(%ebp),%eax
  104948:	01 d0                	add    %edx,%eax
  10494a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10494d:	75 5d                	jne    1049ac <default_free_pages+0x1ad>
            // 释放块的连续空页数要加上空闲块起始页p的连续空页数
            base->property += p->property;
  10494f:	8b 45 08             	mov    0x8(%ebp),%eax
  104952:	8b 50 08             	mov    0x8(%eax),%edx
  104955:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104958:	8b 40 08             	mov    0x8(%eax),%eax
  10495b:	01 c2                	add    %eax,%edx
  10495d:	8b 45 08             	mov    0x8(%ebp),%eax
  104960:	89 50 08             	mov    %edx,0x8(%eax)
            // 清除p的Page_property位，表示p不再是新的空闲块的起始页
            ClearPageProperty(p);
  104963:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104966:	83 c0 04             	add    $0x4,%eax
  104969:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  104970:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104973:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104976:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104979:	0f b3 10             	btr    %edx,(%eax)
}
  10497c:	90                   	nop
            // 将原来的空闲块删除
            list_del(&(p->page_link));
  10497d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104980:	83 c0 0c             	add    $0xc,%eax
  104983:	89 45 cc             	mov    %eax,-0x34(%ebp)
    __list_del(listelm->prev, listelm->next);
  104986:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104989:	8b 40 04             	mov    0x4(%eax),%eax
  10498c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  10498f:	8b 12                	mov    (%edx),%edx
  104991:	89 55 c8             	mov    %edx,-0x38(%ebp)
  104994:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    prev->next = next;
  104997:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10499a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  10499d:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1049a0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1049a3:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1049a6:	89 10                	mov    %edx,(%eax)
}
  1049a8:	90                   	nop
}
  1049a9:	90                   	nop
  1049aa:	eb 7d                	jmp    104a29 <default_free_pages+0x22a>
        }
        // 如果释放块的起始页在上一个空闲块的后面，那么进行合并
        else if (p + p->property == base) {
  1049ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049af:	8b 50 08             	mov    0x8(%eax),%edx
  1049b2:	89 d0                	mov    %edx,%eax
  1049b4:	c1 e0 02             	shl    $0x2,%eax
  1049b7:	01 d0                	add    %edx,%eax
  1049b9:	c1 e0 02             	shl    $0x2,%eax
  1049bc:	89 c2                	mov    %eax,%edx
  1049be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049c1:	01 d0                	add    %edx,%eax
  1049c3:	39 45 08             	cmp    %eax,0x8(%ebp)
  1049c6:	75 61                	jne    104a29 <default_free_pages+0x22a>
            // 空闲块的连续空页数要加上释放块起始页base的连续空页数
            p->property += base->property;
  1049c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049cb:	8b 50 08             	mov    0x8(%eax),%edx
  1049ce:	8b 45 08             	mov    0x8(%ebp),%eax
  1049d1:	8b 40 08             	mov    0x8(%eax),%eax
  1049d4:	01 c2                	add    %eax,%edx
  1049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049d9:	89 50 08             	mov    %edx,0x8(%eax)
            // 清除base的Page_property位，表示base不再是起始页
            ClearPageProperty(base);
  1049dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1049df:	83 c0 04             	add    $0x4,%eax
  1049e2:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1049e9:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1049ec:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1049ef:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1049f2:	0f b3 10             	btr    %edx,(%eax)
}
  1049f5:	90                   	nop
            // 新的空闲块的起始页变成p
            base = p;
  1049f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049f9:	89 45 08             	mov    %eax,0x8(%ebp)
            // 将原来的空闲块删除
            list_del(&(p->page_link));
  1049fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049ff:	83 c0 0c             	add    $0xc,%eax
  104a02:	89 45 b8             	mov    %eax,-0x48(%ebp)
    __list_del(listelm->prev, listelm->next);
  104a05:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104a08:	8b 40 04             	mov    0x4(%eax),%eax
  104a0b:	8b 55 b8             	mov    -0x48(%ebp),%edx
  104a0e:	8b 12                	mov    (%edx),%edx
  104a10:	89 55 b4             	mov    %edx,-0x4c(%ebp)
  104a13:	89 45 b0             	mov    %eax,-0x50(%ebp)
    prev->next = next;
  104a16:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104a19:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104a1c:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104a1f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104a22:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  104a25:	89 10                	mov    %edx,(%eax)
}
  104a27:	90                   	nop
}
  104a28:	90                   	nop
  104a29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a2c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return listelm->next;
  104a2f:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104a32:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104a35:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a38:	81 7d f0 1c cf 11 00 	cmpl   $0x11cf1c,-0x10(%ebp)
  104a3f:	0f 85 e5 fe ff ff    	jne    10492a <default_free_pages+0x12b>
        }
    }
    le = &free_list;
  104a45:	c7 45 f0 1c cf 11 00 	movl   $0x11cf1c,-0x10(%ebp)
    // 遍历空闲链表，将合并好之后的页块加回空闲链表
    while ((le = list_next(le)) != &free_list) {
  104a4c:	eb 25                	jmp    104a73 <default_free_pages+0x274>
        // 由链表元素获得对应的Page指针p
        p = le2page(le, page_link);
  104a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a51:	83 e8 0c             	sub    $0xc,%eax
  104a54:	89 45 f4             	mov    %eax,-0xc(%ebp)
        // 找到能够方向新的合并块的位置
        if (base + base->property <= p) {
  104a57:	8b 45 08             	mov    0x8(%ebp),%eax
  104a5a:	8b 50 08             	mov    0x8(%eax),%edx
  104a5d:	89 d0                	mov    %edx,%eax
  104a5f:	c1 e0 02             	shl    $0x2,%eax
  104a62:	01 d0                	add    %edx,%eax
  104a64:	c1 e0 02             	shl    $0x2,%eax
  104a67:	89 c2                	mov    %eax,%edx
  104a69:	8b 45 08             	mov    0x8(%ebp),%eax
  104a6c:	01 d0                	add    %edx,%eax
  104a6e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104a71:	73 1a                	jae    104a8d <default_free_pages+0x28e>
  104a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a76:	89 45 a0             	mov    %eax,-0x60(%ebp)
  104a79:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104a7c:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  104a7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104a82:	81 7d f0 1c cf 11 00 	cmpl   $0x11cf1c,-0x10(%ebp)
  104a89:	75 c3                	jne    104a4e <default_free_pages+0x24f>
  104a8b:	eb 01                	jmp    104a8e <default_free_pages+0x28f>
            break;
  104a8d:	90                   	nop
        }
    }
    // 将空闲页的数目加n
    nr_free += n;
  104a8e:	8b 15 24 cf 11 00    	mov    0x11cf24,%edx
  104a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  104a97:	01 d0                	add    %edx,%eax
  104a99:	a3 24 cf 11 00       	mov    %eax,0x11cf24
    // 将base->page_link此页链接到le中，插入合适位置
    list_add_before(le, &(base->page_link));
  104a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  104aa1:	8d 50 0c             	lea    0xc(%eax),%edx
  104aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104aa7:	89 45 9c             	mov    %eax,-0x64(%ebp)
  104aaa:	89 55 98             	mov    %edx,-0x68(%ebp)
    __list_add(elm, listelm->prev, listelm);
  104aad:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104ab0:	8b 00                	mov    (%eax),%eax
  104ab2:	8b 55 98             	mov    -0x68(%ebp),%edx
  104ab5:	89 55 94             	mov    %edx,-0x6c(%ebp)
  104ab8:	89 45 90             	mov    %eax,-0x70(%ebp)
  104abb:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104abe:	89 45 8c             	mov    %eax,-0x74(%ebp)
    prev->next = next->prev = elm;
  104ac1:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104ac4:	8b 55 94             	mov    -0x6c(%ebp),%edx
  104ac7:	89 10                	mov    %edx,(%eax)
  104ac9:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104acc:	8b 10                	mov    (%eax),%edx
  104ace:	8b 45 90             	mov    -0x70(%ebp),%eax
  104ad1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104ad4:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104ad7:	8b 55 8c             	mov    -0x74(%ebp),%edx
  104ada:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104add:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104ae0:	8b 55 90             	mov    -0x70(%ebp),%edx
  104ae3:	89 10                	mov    %edx,(%eax)
}
  104ae5:	90                   	nop
}
  104ae6:	90                   	nop
}
  104ae7:	90                   	nop
  104ae8:	c9                   	leave  
  104ae9:	c3                   	ret    

00104aea <default_nr_free_pages>:
static size_t
default_nr_free_pages(void) {
  104aea:	f3 0f 1e fb          	endbr32 
  104aee:	55                   	push   %ebp
  104aef:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104af1:	a1 24 cf 11 00       	mov    0x11cf24,%eax
}
  104af6:	5d                   	pop    %ebp
  104af7:	c3                   	ret    

00104af8 <basic_check>:

static void
basic_check(void) {
  104af8:	f3 0f 1e fb          	endbr32 
  104afc:	55                   	push   %ebp
  104afd:	89 e5                	mov    %esp,%ebp
  104aff:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104b02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b12:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104b15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b1c:	e8 96 e2 ff ff       	call   102db7 <alloc_pages>
  104b21:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104b24:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104b28:	75 24                	jne    104b4e <basic_check+0x56>
  104b2a:	c7 44 24 0c 01 70 10 	movl   $0x107001,0xc(%esp)
  104b31:	00 
  104b32:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104b39:	00 
  104b3a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  104b41:	00 
  104b42:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104b49:	e8 e7 b8 ff ff       	call   100435 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104b4e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b55:	e8 5d e2 ff ff       	call   102db7 <alloc_pages>
  104b5a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104b5d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104b61:	75 24                	jne    104b87 <basic_check+0x8f>
  104b63:	c7 44 24 0c 1d 70 10 	movl   $0x10701d,0xc(%esp)
  104b6a:	00 
  104b6b:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104b72:	00 
  104b73:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  104b7a:	00 
  104b7b:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104b82:	e8 ae b8 ff ff       	call   100435 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104b87:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b8e:	e8 24 e2 ff ff       	call   102db7 <alloc_pages>
  104b93:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104b96:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104b9a:	75 24                	jne    104bc0 <basic_check+0xc8>
  104b9c:	c7 44 24 0c 39 70 10 	movl   $0x107039,0xc(%esp)
  104ba3:	00 
  104ba4:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104bab:	00 
  104bac:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
  104bb3:	00 
  104bb4:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104bbb:	e8 75 b8 ff ff       	call   100435 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104bc3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104bc6:	74 10                	je     104bd8 <basic_check+0xe0>
  104bc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104bcb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104bce:	74 08                	je     104bd8 <basic_check+0xe0>
  104bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bd3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104bd6:	75 24                	jne    104bfc <basic_check+0x104>
  104bd8:	c7 44 24 0c 58 70 10 	movl   $0x107058,0xc(%esp)
  104bdf:	00 
  104be0:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104be7:	00 
  104be8:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
  104bef:	00 
  104bf0:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104bf7:	e8 39 b8 ff ff       	call   100435 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  104bfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104bff:	89 04 24             	mov    %eax,(%esp)
  104c02:	e8 b5 f8 ff ff       	call   1044bc <page_ref>
  104c07:	85 c0                	test   %eax,%eax
  104c09:	75 1e                	jne    104c29 <basic_check+0x131>
  104c0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c0e:	89 04 24             	mov    %eax,(%esp)
  104c11:	e8 a6 f8 ff ff       	call   1044bc <page_ref>
  104c16:	85 c0                	test   %eax,%eax
  104c18:	75 0f                	jne    104c29 <basic_check+0x131>
  104c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c1d:	89 04 24             	mov    %eax,(%esp)
  104c20:	e8 97 f8 ff ff       	call   1044bc <page_ref>
  104c25:	85 c0                	test   %eax,%eax
  104c27:	74 24                	je     104c4d <basic_check+0x155>
  104c29:	c7 44 24 0c 7c 70 10 	movl   $0x10707c,0xc(%esp)
  104c30:	00 
  104c31:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104c38:	00 
  104c39:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  104c40:	00 
  104c41:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104c48:	e8 e8 b7 ff ff       	call   100435 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104c4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c50:	89 04 24             	mov    %eax,(%esp)
  104c53:	e8 4e f8 ff ff       	call   1044a6 <page2pa>
  104c58:	8b 15 80 ce 11 00    	mov    0x11ce80,%edx
  104c5e:	c1 e2 0c             	shl    $0xc,%edx
  104c61:	39 d0                	cmp    %edx,%eax
  104c63:	72 24                	jb     104c89 <basic_check+0x191>
  104c65:	c7 44 24 0c b8 70 10 	movl   $0x1070b8,0xc(%esp)
  104c6c:	00 
  104c6d:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104c74:	00 
  104c75:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  104c7c:	00 
  104c7d:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104c84:	e8 ac b7 ff ff       	call   100435 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104c8c:	89 04 24             	mov    %eax,(%esp)
  104c8f:	e8 12 f8 ff ff       	call   1044a6 <page2pa>
  104c94:	8b 15 80 ce 11 00    	mov    0x11ce80,%edx
  104c9a:	c1 e2 0c             	shl    $0xc,%edx
  104c9d:	39 d0                	cmp    %edx,%eax
  104c9f:	72 24                	jb     104cc5 <basic_check+0x1cd>
  104ca1:	c7 44 24 0c d5 70 10 	movl   $0x1070d5,0xc(%esp)
  104ca8:	00 
  104ca9:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104cb0:	00 
  104cb1:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  104cb8:	00 
  104cb9:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104cc0:	e8 70 b7 ff ff       	call   100435 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104cc8:	89 04 24             	mov    %eax,(%esp)
  104ccb:	e8 d6 f7 ff ff       	call   1044a6 <page2pa>
  104cd0:	8b 15 80 ce 11 00    	mov    0x11ce80,%edx
  104cd6:	c1 e2 0c             	shl    $0xc,%edx
  104cd9:	39 d0                	cmp    %edx,%eax
  104cdb:	72 24                	jb     104d01 <basic_check+0x209>
  104cdd:	c7 44 24 0c f2 70 10 	movl   $0x1070f2,0xc(%esp)
  104ce4:	00 
  104ce5:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104cec:	00 
  104ced:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  104cf4:	00 
  104cf5:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104cfc:	e8 34 b7 ff ff       	call   100435 <__panic>

    list_entry_t free_list_store = free_list;
  104d01:	a1 1c cf 11 00       	mov    0x11cf1c,%eax
  104d06:	8b 15 20 cf 11 00    	mov    0x11cf20,%edx
  104d0c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104d0f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104d12:	c7 45 dc 1c cf 11 00 	movl   $0x11cf1c,-0x24(%ebp)
    elm->prev = elm->next = elm;
  104d19:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104d1c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104d1f:	89 50 04             	mov    %edx,0x4(%eax)
  104d22:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104d25:	8b 50 04             	mov    0x4(%eax),%edx
  104d28:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104d2b:	89 10                	mov    %edx,(%eax)
}
  104d2d:	90                   	nop
  104d2e:	c7 45 e0 1c cf 11 00 	movl   $0x11cf1c,-0x20(%ebp)
    return list->next == list;
  104d35:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104d38:	8b 40 04             	mov    0x4(%eax),%eax
  104d3b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  104d3e:	0f 94 c0             	sete   %al
  104d41:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104d44:	85 c0                	test   %eax,%eax
  104d46:	75 24                	jne    104d6c <basic_check+0x274>
  104d48:	c7 44 24 0c 0f 71 10 	movl   $0x10710f,0xc(%esp)
  104d4f:	00 
  104d50:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104d57:	00 
  104d58:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  104d5f:	00 
  104d60:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104d67:	e8 c9 b6 ff ff       	call   100435 <__panic>

    unsigned int nr_free_store = nr_free;
  104d6c:	a1 24 cf 11 00       	mov    0x11cf24,%eax
  104d71:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  104d74:	c7 05 24 cf 11 00 00 	movl   $0x0,0x11cf24
  104d7b:	00 00 00 

    assert(alloc_page() == NULL);
  104d7e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104d85:	e8 2d e0 ff ff       	call   102db7 <alloc_pages>
  104d8a:	85 c0                	test   %eax,%eax
  104d8c:	74 24                	je     104db2 <basic_check+0x2ba>
  104d8e:	c7 44 24 0c 26 71 10 	movl   $0x107126,0xc(%esp)
  104d95:	00 
  104d96:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104d9d:	00 
  104d9e:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  104da5:	00 
  104da6:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104dad:	e8 83 b6 ff ff       	call   100435 <__panic>

    free_page(p0);
  104db2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104db9:	00 
  104dba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104dbd:	89 04 24             	mov    %eax,(%esp)
  104dc0:	e8 2e e0 ff ff       	call   102df3 <free_pages>
    free_page(p1);
  104dc5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104dcc:	00 
  104dcd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104dd0:	89 04 24             	mov    %eax,(%esp)
  104dd3:	e8 1b e0 ff ff       	call   102df3 <free_pages>
    free_page(p2);
  104dd8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104ddf:	00 
  104de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104de3:	89 04 24             	mov    %eax,(%esp)
  104de6:	e8 08 e0 ff ff       	call   102df3 <free_pages>
    assert(nr_free == 3);
  104deb:	a1 24 cf 11 00       	mov    0x11cf24,%eax
  104df0:	83 f8 03             	cmp    $0x3,%eax
  104df3:	74 24                	je     104e19 <basic_check+0x321>
  104df5:	c7 44 24 0c 3b 71 10 	movl   $0x10713b,0xc(%esp)
  104dfc:	00 
  104dfd:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104e04:	00 
  104e05:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  104e0c:	00 
  104e0d:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104e14:	e8 1c b6 ff ff       	call   100435 <__panic>

    assert((p0 = alloc_page()) != NULL);
  104e19:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e20:	e8 92 df ff ff       	call   102db7 <alloc_pages>
  104e25:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104e28:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104e2c:	75 24                	jne    104e52 <basic_check+0x35a>
  104e2e:	c7 44 24 0c 01 70 10 	movl   $0x107001,0xc(%esp)
  104e35:	00 
  104e36:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104e3d:	00 
  104e3e:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
  104e45:	00 
  104e46:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104e4d:	e8 e3 b5 ff ff       	call   100435 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104e52:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e59:	e8 59 df ff ff       	call   102db7 <alloc_pages>
  104e5e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104e61:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104e65:	75 24                	jne    104e8b <basic_check+0x393>
  104e67:	c7 44 24 0c 1d 70 10 	movl   $0x10701d,0xc(%esp)
  104e6e:	00 
  104e6f:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104e76:	00 
  104e77:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  104e7e:	00 
  104e7f:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104e86:	e8 aa b5 ff ff       	call   100435 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104e8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e92:	e8 20 df ff ff       	call   102db7 <alloc_pages>
  104e97:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104e9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104e9e:	75 24                	jne    104ec4 <basic_check+0x3cc>
  104ea0:	c7 44 24 0c 39 70 10 	movl   $0x107039,0xc(%esp)
  104ea7:	00 
  104ea8:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104eaf:	00 
  104eb0:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  104eb7:	00 
  104eb8:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104ebf:	e8 71 b5 ff ff       	call   100435 <__panic>

    assert(alloc_page() == NULL);
  104ec4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104ecb:	e8 e7 de ff ff       	call   102db7 <alloc_pages>
  104ed0:	85 c0                	test   %eax,%eax
  104ed2:	74 24                	je     104ef8 <basic_check+0x400>
  104ed4:	c7 44 24 0c 26 71 10 	movl   $0x107126,0xc(%esp)
  104edb:	00 
  104edc:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104ee3:	00 
  104ee4:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  104eeb:	00 
  104eec:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104ef3:	e8 3d b5 ff ff       	call   100435 <__panic>

    free_page(p0);
  104ef8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104eff:	00 
  104f00:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104f03:	89 04 24             	mov    %eax,(%esp)
  104f06:	e8 e8 de ff ff       	call   102df3 <free_pages>
  104f0b:	c7 45 d8 1c cf 11 00 	movl   $0x11cf1c,-0x28(%ebp)
  104f12:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104f15:	8b 40 04             	mov    0x4(%eax),%eax
  104f18:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104f1b:	0f 94 c0             	sete   %al
  104f1e:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  104f21:	85 c0                	test   %eax,%eax
  104f23:	74 24                	je     104f49 <basic_check+0x451>
  104f25:	c7 44 24 0c 48 71 10 	movl   $0x107148,0xc(%esp)
  104f2c:	00 
  104f2d:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104f34:	00 
  104f35:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  104f3c:	00 
  104f3d:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104f44:	e8 ec b4 ff ff       	call   100435 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  104f49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f50:	e8 62 de ff ff       	call   102db7 <alloc_pages>
  104f55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104f58:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104f5b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104f5e:	74 24                	je     104f84 <basic_check+0x48c>
  104f60:	c7 44 24 0c 60 71 10 	movl   $0x107160,0xc(%esp)
  104f67:	00 
  104f68:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104f6f:	00 
  104f70:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
  104f77:	00 
  104f78:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104f7f:	e8 b1 b4 ff ff       	call   100435 <__panic>
    assert(alloc_page() == NULL);
  104f84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104f8b:	e8 27 de ff ff       	call   102db7 <alloc_pages>
  104f90:	85 c0                	test   %eax,%eax
  104f92:	74 24                	je     104fb8 <basic_check+0x4c0>
  104f94:	c7 44 24 0c 26 71 10 	movl   $0x107126,0xc(%esp)
  104f9b:	00 
  104f9c:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104fa3:	00 
  104fa4:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
  104fab:	00 
  104fac:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104fb3:	e8 7d b4 ff ff       	call   100435 <__panic>

    assert(nr_free == 0);
  104fb8:	a1 24 cf 11 00       	mov    0x11cf24,%eax
  104fbd:	85 c0                	test   %eax,%eax
  104fbf:	74 24                	je     104fe5 <basic_check+0x4ed>
  104fc1:	c7 44 24 0c 79 71 10 	movl   $0x107179,0xc(%esp)
  104fc8:	00 
  104fc9:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  104fd0:	00 
  104fd1:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  104fd8:	00 
  104fd9:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  104fe0:	e8 50 b4 ff ff       	call   100435 <__panic>
    free_list = free_list_store;
  104fe5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104fe8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104feb:	a3 1c cf 11 00       	mov    %eax,0x11cf1c
  104ff0:	89 15 20 cf 11 00    	mov    %edx,0x11cf20
    nr_free = nr_free_store;
  104ff6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ff9:	a3 24 cf 11 00       	mov    %eax,0x11cf24

    free_page(p);
  104ffe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105005:	00 
  105006:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105009:	89 04 24             	mov    %eax,(%esp)
  10500c:	e8 e2 dd ff ff       	call   102df3 <free_pages>
    free_page(p1);
  105011:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105018:	00 
  105019:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10501c:	89 04 24             	mov    %eax,(%esp)
  10501f:	e8 cf dd ff ff       	call   102df3 <free_pages>
    free_page(p2);
  105024:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10502b:	00 
  10502c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10502f:	89 04 24             	mov    %eax,(%esp)
  105032:	e8 bc dd ff ff       	call   102df3 <free_pages>
}
  105037:	90                   	nop
  105038:	c9                   	leave  
  105039:	c3                   	ret    

0010503a <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  10503a:	f3 0f 1e fb          	endbr32 
  10503e:	55                   	push   %ebp
  10503f:	89 e5                	mov    %esp,%ebp
  105041:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  105047:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10504e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  105055:	c7 45 ec 1c cf 11 00 	movl   $0x11cf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10505c:	eb 6a                	jmp    1050c8 <default_check+0x8e>
        struct Page *p = le2page(le, page_link);
  10505e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105061:	83 e8 0c             	sub    $0xc,%eax
  105064:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  105067:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10506a:	83 c0 04             	add    $0x4,%eax
  10506d:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  105074:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105077:	8b 45 cc             	mov    -0x34(%ebp),%eax
  10507a:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10507d:	0f a3 10             	bt     %edx,(%eax)
  105080:	19 c0                	sbb    %eax,%eax
  105082:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  105085:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  105089:	0f 95 c0             	setne  %al
  10508c:	0f b6 c0             	movzbl %al,%eax
  10508f:	85 c0                	test   %eax,%eax
  105091:	75 24                	jne    1050b7 <default_check+0x7d>
  105093:	c7 44 24 0c 86 71 10 	movl   $0x107186,0xc(%esp)
  10509a:	00 
  10509b:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  1050a2:	00 
  1050a3:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
  1050aa:	00 
  1050ab:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  1050b2:	e8 7e b3 ff ff       	call   100435 <__panic>
        count ++, total += p->property;
  1050b7:	ff 45 f4             	incl   -0xc(%ebp)
  1050ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1050bd:	8b 50 08             	mov    0x8(%eax),%edx
  1050c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1050c3:	01 d0                	add    %edx,%eax
  1050c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1050c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1050cb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  1050ce:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1050d1:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  1050d4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1050d7:	81 7d ec 1c cf 11 00 	cmpl   $0x11cf1c,-0x14(%ebp)
  1050de:	0f 85 7a ff ff ff    	jne    10505e <default_check+0x24>
    }
    assert(total == nr_free_pages());
  1050e4:	e8 41 dd ff ff       	call   102e2a <nr_free_pages>
  1050e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1050ec:	39 d0                	cmp    %edx,%eax
  1050ee:	74 24                	je     105114 <default_check+0xda>
  1050f0:	c7 44 24 0c 96 71 10 	movl   $0x107196,0xc(%esp)
  1050f7:	00 
  1050f8:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  1050ff:	00 
  105100:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
  105107:	00 
  105108:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  10510f:	e8 21 b3 ff ff       	call   100435 <__panic>

    basic_check();
  105114:	e8 df f9 ff ff       	call   104af8 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  105119:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105120:	e8 92 dc ff ff       	call   102db7 <alloc_pages>
  105125:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  105128:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10512c:	75 24                	jne    105152 <default_check+0x118>
  10512e:	c7 44 24 0c af 71 10 	movl   $0x1071af,0xc(%esp)
  105135:	00 
  105136:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  10513d:	00 
  10513e:	c7 44 24 04 3e 01 00 	movl   $0x13e,0x4(%esp)
  105145:	00 
  105146:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  10514d:	e8 e3 b2 ff ff       	call   100435 <__panic>
    assert(!PageProperty(p0));
  105152:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105155:	83 c0 04             	add    $0x4,%eax
  105158:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  10515f:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105162:	8b 45 bc             	mov    -0x44(%ebp),%eax
  105165:	8b 55 c0             	mov    -0x40(%ebp),%edx
  105168:	0f a3 10             	bt     %edx,(%eax)
  10516b:	19 c0                	sbb    %eax,%eax
  10516d:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  105170:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  105174:	0f 95 c0             	setne  %al
  105177:	0f b6 c0             	movzbl %al,%eax
  10517a:	85 c0                	test   %eax,%eax
  10517c:	74 24                	je     1051a2 <default_check+0x168>
  10517e:	c7 44 24 0c ba 71 10 	movl   $0x1071ba,0xc(%esp)
  105185:	00 
  105186:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  10518d:	00 
  10518e:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
  105195:	00 
  105196:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  10519d:	e8 93 b2 ff ff       	call   100435 <__panic>

    list_entry_t free_list_store = free_list;
  1051a2:	a1 1c cf 11 00       	mov    0x11cf1c,%eax
  1051a7:	8b 15 20 cf 11 00    	mov    0x11cf20,%edx
  1051ad:	89 45 80             	mov    %eax,-0x80(%ebp)
  1051b0:	89 55 84             	mov    %edx,-0x7c(%ebp)
  1051b3:	c7 45 b0 1c cf 11 00 	movl   $0x11cf1c,-0x50(%ebp)
    elm->prev = elm->next = elm;
  1051ba:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1051bd:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1051c0:	89 50 04             	mov    %edx,0x4(%eax)
  1051c3:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1051c6:	8b 50 04             	mov    0x4(%eax),%edx
  1051c9:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1051cc:	89 10                	mov    %edx,(%eax)
}
  1051ce:	90                   	nop
  1051cf:	c7 45 b4 1c cf 11 00 	movl   $0x11cf1c,-0x4c(%ebp)
    return list->next == list;
  1051d6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1051d9:	8b 40 04             	mov    0x4(%eax),%eax
  1051dc:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  1051df:	0f 94 c0             	sete   %al
  1051e2:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1051e5:	85 c0                	test   %eax,%eax
  1051e7:	75 24                	jne    10520d <default_check+0x1d3>
  1051e9:	c7 44 24 0c 0f 71 10 	movl   $0x10710f,0xc(%esp)
  1051f0:	00 
  1051f1:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  1051f8:	00 
  1051f9:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
  105200:	00 
  105201:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  105208:	e8 28 b2 ff ff       	call   100435 <__panic>
    assert(alloc_page() == NULL);
  10520d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105214:	e8 9e db ff ff       	call   102db7 <alloc_pages>
  105219:	85 c0                	test   %eax,%eax
  10521b:	74 24                	je     105241 <default_check+0x207>
  10521d:	c7 44 24 0c 26 71 10 	movl   $0x107126,0xc(%esp)
  105224:	00 
  105225:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  10522c:	00 
  10522d:	c7 44 24 04 44 01 00 	movl   $0x144,0x4(%esp)
  105234:	00 
  105235:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  10523c:	e8 f4 b1 ff ff       	call   100435 <__panic>

    unsigned int nr_free_store = nr_free;
  105241:	a1 24 cf 11 00       	mov    0x11cf24,%eax
  105246:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  105249:	c7 05 24 cf 11 00 00 	movl   $0x0,0x11cf24
  105250:	00 00 00 

    free_pages(p0 + 2, 3);
  105253:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105256:	83 c0 28             	add    $0x28,%eax
  105259:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  105260:	00 
  105261:	89 04 24             	mov    %eax,(%esp)
  105264:	e8 8a db ff ff       	call   102df3 <free_pages>
    assert(alloc_pages(4) == NULL);
  105269:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  105270:	e8 42 db ff ff       	call   102db7 <alloc_pages>
  105275:	85 c0                	test   %eax,%eax
  105277:	74 24                	je     10529d <default_check+0x263>
  105279:	c7 44 24 0c cc 71 10 	movl   $0x1071cc,0xc(%esp)
  105280:	00 
  105281:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  105288:	00 
  105289:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
  105290:	00 
  105291:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  105298:	e8 98 b1 ff ff       	call   100435 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  10529d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1052a0:	83 c0 28             	add    $0x28,%eax
  1052a3:	83 c0 04             	add    $0x4,%eax
  1052a6:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1052ad:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1052b0:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1052b3:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1052b6:	0f a3 10             	bt     %edx,(%eax)
  1052b9:	19 c0                	sbb    %eax,%eax
  1052bb:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1052be:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1052c2:	0f 95 c0             	setne  %al
  1052c5:	0f b6 c0             	movzbl %al,%eax
  1052c8:	85 c0                	test   %eax,%eax
  1052ca:	74 0e                	je     1052da <default_check+0x2a0>
  1052cc:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1052cf:	83 c0 28             	add    $0x28,%eax
  1052d2:	8b 40 08             	mov    0x8(%eax),%eax
  1052d5:	83 f8 03             	cmp    $0x3,%eax
  1052d8:	74 24                	je     1052fe <default_check+0x2c4>
  1052da:	c7 44 24 0c e4 71 10 	movl   $0x1071e4,0xc(%esp)
  1052e1:	00 
  1052e2:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  1052e9:	00 
  1052ea:	c7 44 24 04 4b 01 00 	movl   $0x14b,0x4(%esp)
  1052f1:	00 
  1052f2:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  1052f9:	e8 37 b1 ff ff       	call   100435 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  1052fe:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105305:	e8 ad da ff ff       	call   102db7 <alloc_pages>
  10530a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10530d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  105311:	75 24                	jne    105337 <default_check+0x2fd>
  105313:	c7 44 24 0c 10 72 10 	movl   $0x107210,0xc(%esp)
  10531a:	00 
  10531b:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  105322:	00 
  105323:	c7 44 24 04 4c 01 00 	movl   $0x14c,0x4(%esp)
  10532a:	00 
  10532b:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  105332:	e8 fe b0 ff ff       	call   100435 <__panic>
    assert(alloc_page() == NULL);
  105337:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10533e:	e8 74 da ff ff       	call   102db7 <alloc_pages>
  105343:	85 c0                	test   %eax,%eax
  105345:	74 24                	je     10536b <default_check+0x331>
  105347:	c7 44 24 0c 26 71 10 	movl   $0x107126,0xc(%esp)
  10534e:	00 
  10534f:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  105356:	00 
  105357:	c7 44 24 04 4d 01 00 	movl   $0x14d,0x4(%esp)
  10535e:	00 
  10535f:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  105366:	e8 ca b0 ff ff       	call   100435 <__panic>
    assert(p0 + 2 == p1);
  10536b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10536e:	83 c0 28             	add    $0x28,%eax
  105371:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  105374:	74 24                	je     10539a <default_check+0x360>
  105376:	c7 44 24 0c 2e 72 10 	movl   $0x10722e,0xc(%esp)
  10537d:	00 
  10537e:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  105385:	00 
  105386:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
  10538d:	00 
  10538e:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  105395:	e8 9b b0 ff ff       	call   100435 <__panic>

    p2 = p0 + 1;
  10539a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10539d:	83 c0 14             	add    $0x14,%eax
  1053a0:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  1053a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1053aa:	00 
  1053ab:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1053ae:	89 04 24             	mov    %eax,(%esp)
  1053b1:	e8 3d da ff ff       	call   102df3 <free_pages>
    free_pages(p1, 3);
  1053b6:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1053bd:	00 
  1053be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1053c1:	89 04 24             	mov    %eax,(%esp)
  1053c4:	e8 2a da ff ff       	call   102df3 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  1053c9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1053cc:	83 c0 04             	add    $0x4,%eax
  1053cf:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  1053d6:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1053d9:	8b 45 9c             	mov    -0x64(%ebp),%eax
  1053dc:	8b 55 a0             	mov    -0x60(%ebp),%edx
  1053df:	0f a3 10             	bt     %edx,(%eax)
  1053e2:	19 c0                	sbb    %eax,%eax
  1053e4:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  1053e7:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  1053eb:	0f 95 c0             	setne  %al
  1053ee:	0f b6 c0             	movzbl %al,%eax
  1053f1:	85 c0                	test   %eax,%eax
  1053f3:	74 0b                	je     105400 <default_check+0x3c6>
  1053f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1053f8:	8b 40 08             	mov    0x8(%eax),%eax
  1053fb:	83 f8 01             	cmp    $0x1,%eax
  1053fe:	74 24                	je     105424 <default_check+0x3ea>
  105400:	c7 44 24 0c 3c 72 10 	movl   $0x10723c,0xc(%esp)
  105407:	00 
  105408:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  10540f:	00 
  105410:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
  105417:	00 
  105418:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  10541f:	e8 11 b0 ff ff       	call   100435 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  105424:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105427:	83 c0 04             	add    $0x4,%eax
  10542a:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  105431:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105434:	8b 45 90             	mov    -0x70(%ebp),%eax
  105437:	8b 55 94             	mov    -0x6c(%ebp),%edx
  10543a:	0f a3 10             	bt     %edx,(%eax)
  10543d:	19 c0                	sbb    %eax,%eax
  10543f:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  105442:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  105446:	0f 95 c0             	setne  %al
  105449:	0f b6 c0             	movzbl %al,%eax
  10544c:	85 c0                	test   %eax,%eax
  10544e:	74 0b                	je     10545b <default_check+0x421>
  105450:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105453:	8b 40 08             	mov    0x8(%eax),%eax
  105456:	83 f8 03             	cmp    $0x3,%eax
  105459:	74 24                	je     10547f <default_check+0x445>
  10545b:	c7 44 24 0c 64 72 10 	movl   $0x107264,0xc(%esp)
  105462:	00 
  105463:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  10546a:	00 
  10546b:	c7 44 24 04 54 01 00 	movl   $0x154,0x4(%esp)
  105472:	00 
  105473:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  10547a:	e8 b6 af ff ff       	call   100435 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  10547f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105486:	e8 2c d9 ff ff       	call   102db7 <alloc_pages>
  10548b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10548e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105491:	83 e8 14             	sub    $0x14,%eax
  105494:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105497:	74 24                	je     1054bd <default_check+0x483>
  105499:	c7 44 24 0c 8a 72 10 	movl   $0x10728a,0xc(%esp)
  1054a0:	00 
  1054a1:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  1054a8:	00 
  1054a9:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
  1054b0:	00 
  1054b1:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  1054b8:	e8 78 af ff ff       	call   100435 <__panic>
    free_page(p0);
  1054bd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1054c4:	00 
  1054c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1054c8:	89 04 24             	mov    %eax,(%esp)
  1054cb:	e8 23 d9 ff ff       	call   102df3 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  1054d0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  1054d7:	e8 db d8 ff ff       	call   102db7 <alloc_pages>
  1054dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1054df:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1054e2:	83 c0 14             	add    $0x14,%eax
  1054e5:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1054e8:	74 24                	je     10550e <default_check+0x4d4>
  1054ea:	c7 44 24 0c a8 72 10 	movl   $0x1072a8,0xc(%esp)
  1054f1:	00 
  1054f2:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  1054f9:	00 
  1054fa:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
  105501:	00 
  105502:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  105509:	e8 27 af ff ff       	call   100435 <__panic>

    free_pages(p0, 2);
  10550e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  105515:	00 
  105516:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105519:	89 04 24             	mov    %eax,(%esp)
  10551c:	e8 d2 d8 ff ff       	call   102df3 <free_pages>
    free_page(p2);
  105521:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105528:	00 
  105529:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10552c:	89 04 24             	mov    %eax,(%esp)
  10552f:	e8 bf d8 ff ff       	call   102df3 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  105534:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10553b:	e8 77 d8 ff ff       	call   102db7 <alloc_pages>
  105540:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105543:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105547:	75 24                	jne    10556d <default_check+0x533>
  105549:	c7 44 24 0c c8 72 10 	movl   $0x1072c8,0xc(%esp)
  105550:	00 
  105551:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  105558:	00 
  105559:	c7 44 24 04 5d 01 00 	movl   $0x15d,0x4(%esp)
  105560:	00 
  105561:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  105568:	e8 c8 ae ff ff       	call   100435 <__panic>
    assert(alloc_page() == NULL);
  10556d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105574:	e8 3e d8 ff ff       	call   102db7 <alloc_pages>
  105579:	85 c0                	test   %eax,%eax
  10557b:	74 24                	je     1055a1 <default_check+0x567>
  10557d:	c7 44 24 0c 26 71 10 	movl   $0x107126,0xc(%esp)
  105584:	00 
  105585:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  10558c:	00 
  10558d:	c7 44 24 04 5e 01 00 	movl   $0x15e,0x4(%esp)
  105594:	00 
  105595:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  10559c:	e8 94 ae ff ff       	call   100435 <__panic>

    assert(nr_free == 0);
  1055a1:	a1 24 cf 11 00       	mov    0x11cf24,%eax
  1055a6:	85 c0                	test   %eax,%eax
  1055a8:	74 24                	je     1055ce <default_check+0x594>
  1055aa:	c7 44 24 0c 79 71 10 	movl   $0x107179,0xc(%esp)
  1055b1:	00 
  1055b2:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  1055b9:	00 
  1055ba:	c7 44 24 04 60 01 00 	movl   $0x160,0x4(%esp)
  1055c1:	00 
  1055c2:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  1055c9:	e8 67 ae ff ff       	call   100435 <__panic>
    nr_free = nr_free_store;
  1055ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1055d1:	a3 24 cf 11 00       	mov    %eax,0x11cf24

    free_list = free_list_store;
  1055d6:	8b 45 80             	mov    -0x80(%ebp),%eax
  1055d9:	8b 55 84             	mov    -0x7c(%ebp),%edx
  1055dc:	a3 1c cf 11 00       	mov    %eax,0x11cf1c
  1055e1:	89 15 20 cf 11 00    	mov    %edx,0x11cf20
    free_pages(p0, 5);
  1055e7:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  1055ee:	00 
  1055ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1055f2:	89 04 24             	mov    %eax,(%esp)
  1055f5:	e8 f9 d7 ff ff       	call   102df3 <free_pages>

    le = &free_list;
  1055fa:	c7 45 ec 1c cf 11 00 	movl   $0x11cf1c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  105601:	eb 1c                	jmp    10561f <default_check+0x5e5>
        struct Page *p = le2page(le, page_link);
  105603:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105606:	83 e8 0c             	sub    $0xc,%eax
  105609:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  10560c:	ff 4d f4             	decl   -0xc(%ebp)
  10560f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105612:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105615:	8b 40 08             	mov    0x8(%eax),%eax
  105618:	29 c2                	sub    %eax,%edx
  10561a:	89 d0                	mov    %edx,%eax
  10561c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10561f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105622:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  105625:	8b 45 88             	mov    -0x78(%ebp),%eax
  105628:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  10562b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10562e:	81 7d ec 1c cf 11 00 	cmpl   $0x11cf1c,-0x14(%ebp)
  105635:	75 cc                	jne    105603 <default_check+0x5c9>
    }
    assert(count == 0);
  105637:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10563b:	74 24                	je     105661 <default_check+0x627>
  10563d:	c7 44 24 0c e6 72 10 	movl   $0x1072e6,0xc(%esp)
  105644:	00 
  105645:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  10564c:	00 
  10564d:	c7 44 24 04 6b 01 00 	movl   $0x16b,0x4(%esp)
  105654:	00 
  105655:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  10565c:	e8 d4 ad ff ff       	call   100435 <__panic>
    assert(total == 0);
  105661:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105665:	74 24                	je     10568b <default_check+0x651>
  105667:	c7 44 24 0c f1 72 10 	movl   $0x1072f1,0xc(%esp)
  10566e:	00 
  10566f:	c7 44 24 08 9e 6f 10 	movl   $0x106f9e,0x8(%esp)
  105676:	00 
  105677:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
  10567e:	00 
  10567f:	c7 04 24 b3 6f 10 00 	movl   $0x106fb3,(%esp)
  105686:	e8 aa ad ff ff       	call   100435 <__panic>
}
  10568b:	90                   	nop
  10568c:	c9                   	leave  
  10568d:	c3                   	ret    

0010568e <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10568e:	f3 0f 1e fb          	endbr32 
  105692:	55                   	push   %ebp
  105693:	89 e5                	mov    %esp,%ebp
  105695:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105698:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  10569f:	eb 03                	jmp    1056a4 <strlen+0x16>
        cnt ++;
  1056a1:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  1056a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1056a7:	8d 50 01             	lea    0x1(%eax),%edx
  1056aa:	89 55 08             	mov    %edx,0x8(%ebp)
  1056ad:	0f b6 00             	movzbl (%eax),%eax
  1056b0:	84 c0                	test   %al,%al
  1056b2:	75 ed                	jne    1056a1 <strlen+0x13>
    }
    return cnt;
  1056b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1056b7:	c9                   	leave  
  1056b8:	c3                   	ret    

001056b9 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  1056b9:	f3 0f 1e fb          	endbr32 
  1056bd:	55                   	push   %ebp
  1056be:	89 e5                	mov    %esp,%ebp
  1056c0:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  1056c3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1056ca:	eb 03                	jmp    1056cf <strnlen+0x16>
        cnt ++;
  1056cc:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  1056cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1056d2:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1056d5:	73 10                	jae    1056e7 <strnlen+0x2e>
  1056d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1056da:	8d 50 01             	lea    0x1(%eax),%edx
  1056dd:	89 55 08             	mov    %edx,0x8(%ebp)
  1056e0:	0f b6 00             	movzbl (%eax),%eax
  1056e3:	84 c0                	test   %al,%al
  1056e5:	75 e5                	jne    1056cc <strnlen+0x13>
    }
    return cnt;
  1056e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1056ea:	c9                   	leave  
  1056eb:	c3                   	ret    

001056ec <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1056ec:	f3 0f 1e fb          	endbr32 
  1056f0:	55                   	push   %ebp
  1056f1:	89 e5                	mov    %esp,%ebp
  1056f3:	57                   	push   %edi
  1056f4:	56                   	push   %esi
  1056f5:	83 ec 20             	sub    $0x20,%esp
  1056f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1056fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1056fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  105701:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105704:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10570a:	89 d1                	mov    %edx,%ecx
  10570c:	89 c2                	mov    %eax,%edx
  10570e:	89 ce                	mov    %ecx,%esi
  105710:	89 d7                	mov    %edx,%edi
  105712:	ac                   	lods   %ds:(%esi),%al
  105713:	aa                   	stos   %al,%es:(%edi)
  105714:	84 c0                	test   %al,%al
  105716:	75 fa                	jne    105712 <strcpy+0x26>
  105718:	89 fa                	mov    %edi,%edx
  10571a:	89 f1                	mov    %esi,%ecx
  10571c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10571f:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105722:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105725:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105728:	83 c4 20             	add    $0x20,%esp
  10572b:	5e                   	pop    %esi
  10572c:	5f                   	pop    %edi
  10572d:	5d                   	pop    %ebp
  10572e:	c3                   	ret    

0010572f <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  10572f:	f3 0f 1e fb          	endbr32 
  105733:	55                   	push   %ebp
  105734:	89 e5                	mov    %esp,%ebp
  105736:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105739:	8b 45 08             	mov    0x8(%ebp),%eax
  10573c:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  10573f:	eb 1e                	jmp    10575f <strncpy+0x30>
        if ((*p = *src) != '\0') {
  105741:	8b 45 0c             	mov    0xc(%ebp),%eax
  105744:	0f b6 10             	movzbl (%eax),%edx
  105747:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10574a:	88 10                	mov    %dl,(%eax)
  10574c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10574f:	0f b6 00             	movzbl (%eax),%eax
  105752:	84 c0                	test   %al,%al
  105754:	74 03                	je     105759 <strncpy+0x2a>
            src ++;
  105756:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105759:	ff 45 fc             	incl   -0x4(%ebp)
  10575c:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  10575f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105763:	75 dc                	jne    105741 <strncpy+0x12>
    }
    return dst;
  105765:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105768:	c9                   	leave  
  105769:	c3                   	ret    

0010576a <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  10576a:	f3 0f 1e fb          	endbr32 
  10576e:	55                   	push   %ebp
  10576f:	89 e5                	mov    %esp,%ebp
  105771:	57                   	push   %edi
  105772:	56                   	push   %esi
  105773:	83 ec 20             	sub    $0x20,%esp
  105776:	8b 45 08             	mov    0x8(%ebp),%eax
  105779:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10577c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10577f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  105782:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105785:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105788:	89 d1                	mov    %edx,%ecx
  10578a:	89 c2                	mov    %eax,%edx
  10578c:	89 ce                	mov    %ecx,%esi
  10578e:	89 d7                	mov    %edx,%edi
  105790:	ac                   	lods   %ds:(%esi),%al
  105791:	ae                   	scas   %es:(%edi),%al
  105792:	75 08                	jne    10579c <strcmp+0x32>
  105794:	84 c0                	test   %al,%al
  105796:	75 f8                	jne    105790 <strcmp+0x26>
  105798:	31 c0                	xor    %eax,%eax
  10579a:	eb 04                	jmp    1057a0 <strcmp+0x36>
  10579c:	19 c0                	sbb    %eax,%eax
  10579e:	0c 01                	or     $0x1,%al
  1057a0:	89 fa                	mov    %edi,%edx
  1057a2:	89 f1                	mov    %esi,%ecx
  1057a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1057a7:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1057aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  1057ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  1057b0:	83 c4 20             	add    $0x20,%esp
  1057b3:	5e                   	pop    %esi
  1057b4:	5f                   	pop    %edi
  1057b5:	5d                   	pop    %ebp
  1057b6:	c3                   	ret    

001057b7 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  1057b7:	f3 0f 1e fb          	endbr32 
  1057bb:	55                   	push   %ebp
  1057bc:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1057be:	eb 09                	jmp    1057c9 <strncmp+0x12>
        n --, s1 ++, s2 ++;
  1057c0:	ff 4d 10             	decl   0x10(%ebp)
  1057c3:	ff 45 08             	incl   0x8(%ebp)
  1057c6:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  1057c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1057cd:	74 1a                	je     1057e9 <strncmp+0x32>
  1057cf:	8b 45 08             	mov    0x8(%ebp),%eax
  1057d2:	0f b6 00             	movzbl (%eax),%eax
  1057d5:	84 c0                	test   %al,%al
  1057d7:	74 10                	je     1057e9 <strncmp+0x32>
  1057d9:	8b 45 08             	mov    0x8(%ebp),%eax
  1057dc:	0f b6 10             	movzbl (%eax),%edx
  1057df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057e2:	0f b6 00             	movzbl (%eax),%eax
  1057e5:	38 c2                	cmp    %al,%dl
  1057e7:	74 d7                	je     1057c0 <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  1057e9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1057ed:	74 18                	je     105807 <strncmp+0x50>
  1057ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1057f2:	0f b6 00             	movzbl (%eax),%eax
  1057f5:	0f b6 d0             	movzbl %al,%edx
  1057f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1057fb:	0f b6 00             	movzbl (%eax),%eax
  1057fe:	0f b6 c0             	movzbl %al,%eax
  105801:	29 c2                	sub    %eax,%edx
  105803:	89 d0                	mov    %edx,%eax
  105805:	eb 05                	jmp    10580c <strncmp+0x55>
  105807:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10580c:	5d                   	pop    %ebp
  10580d:	c3                   	ret    

0010580e <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  10580e:	f3 0f 1e fb          	endbr32 
  105812:	55                   	push   %ebp
  105813:	89 e5                	mov    %esp,%ebp
  105815:	83 ec 04             	sub    $0x4,%esp
  105818:	8b 45 0c             	mov    0xc(%ebp),%eax
  10581b:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  10581e:	eb 13                	jmp    105833 <strchr+0x25>
        if (*s == c) {
  105820:	8b 45 08             	mov    0x8(%ebp),%eax
  105823:	0f b6 00             	movzbl (%eax),%eax
  105826:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105829:	75 05                	jne    105830 <strchr+0x22>
            return (char *)s;
  10582b:	8b 45 08             	mov    0x8(%ebp),%eax
  10582e:	eb 12                	jmp    105842 <strchr+0x34>
        }
        s ++;
  105830:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105833:	8b 45 08             	mov    0x8(%ebp),%eax
  105836:	0f b6 00             	movzbl (%eax),%eax
  105839:	84 c0                	test   %al,%al
  10583b:	75 e3                	jne    105820 <strchr+0x12>
    }
    return NULL;
  10583d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105842:	c9                   	leave  
  105843:	c3                   	ret    

00105844 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105844:	f3 0f 1e fb          	endbr32 
  105848:	55                   	push   %ebp
  105849:	89 e5                	mov    %esp,%ebp
  10584b:	83 ec 04             	sub    $0x4,%esp
  10584e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105851:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105854:	eb 0e                	jmp    105864 <strfind+0x20>
        if (*s == c) {
  105856:	8b 45 08             	mov    0x8(%ebp),%eax
  105859:	0f b6 00             	movzbl (%eax),%eax
  10585c:	38 45 fc             	cmp    %al,-0x4(%ebp)
  10585f:	74 0f                	je     105870 <strfind+0x2c>
            break;
        }
        s ++;
  105861:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105864:	8b 45 08             	mov    0x8(%ebp),%eax
  105867:	0f b6 00             	movzbl (%eax),%eax
  10586a:	84 c0                	test   %al,%al
  10586c:	75 e8                	jne    105856 <strfind+0x12>
  10586e:	eb 01                	jmp    105871 <strfind+0x2d>
            break;
  105870:	90                   	nop
    }
    return (char *)s;
  105871:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105874:	c9                   	leave  
  105875:	c3                   	ret    

00105876 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105876:	f3 0f 1e fb          	endbr32 
  10587a:	55                   	push   %ebp
  10587b:	89 e5                	mov    %esp,%ebp
  10587d:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105880:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105887:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  10588e:	eb 03                	jmp    105893 <strtol+0x1d>
        s ++;
  105890:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  105893:	8b 45 08             	mov    0x8(%ebp),%eax
  105896:	0f b6 00             	movzbl (%eax),%eax
  105899:	3c 20                	cmp    $0x20,%al
  10589b:	74 f3                	je     105890 <strtol+0x1a>
  10589d:	8b 45 08             	mov    0x8(%ebp),%eax
  1058a0:	0f b6 00             	movzbl (%eax),%eax
  1058a3:	3c 09                	cmp    $0x9,%al
  1058a5:	74 e9                	je     105890 <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
  1058a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1058aa:	0f b6 00             	movzbl (%eax),%eax
  1058ad:	3c 2b                	cmp    $0x2b,%al
  1058af:	75 05                	jne    1058b6 <strtol+0x40>
        s ++;
  1058b1:	ff 45 08             	incl   0x8(%ebp)
  1058b4:	eb 14                	jmp    1058ca <strtol+0x54>
    }
    else if (*s == '-') {
  1058b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1058b9:	0f b6 00             	movzbl (%eax),%eax
  1058bc:	3c 2d                	cmp    $0x2d,%al
  1058be:	75 0a                	jne    1058ca <strtol+0x54>
        s ++, neg = 1;
  1058c0:	ff 45 08             	incl   0x8(%ebp)
  1058c3:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  1058ca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1058ce:	74 06                	je     1058d6 <strtol+0x60>
  1058d0:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  1058d4:	75 22                	jne    1058f8 <strtol+0x82>
  1058d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1058d9:	0f b6 00             	movzbl (%eax),%eax
  1058dc:	3c 30                	cmp    $0x30,%al
  1058de:	75 18                	jne    1058f8 <strtol+0x82>
  1058e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1058e3:	40                   	inc    %eax
  1058e4:	0f b6 00             	movzbl (%eax),%eax
  1058e7:	3c 78                	cmp    $0x78,%al
  1058e9:	75 0d                	jne    1058f8 <strtol+0x82>
        s += 2, base = 16;
  1058eb:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  1058ef:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  1058f6:	eb 29                	jmp    105921 <strtol+0xab>
    }
    else if (base == 0 && s[0] == '0') {
  1058f8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1058fc:	75 16                	jne    105914 <strtol+0x9e>
  1058fe:	8b 45 08             	mov    0x8(%ebp),%eax
  105901:	0f b6 00             	movzbl (%eax),%eax
  105904:	3c 30                	cmp    $0x30,%al
  105906:	75 0c                	jne    105914 <strtol+0x9e>
        s ++, base = 8;
  105908:	ff 45 08             	incl   0x8(%ebp)
  10590b:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105912:	eb 0d                	jmp    105921 <strtol+0xab>
    }
    else if (base == 0) {
  105914:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105918:	75 07                	jne    105921 <strtol+0xab>
        base = 10;
  10591a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105921:	8b 45 08             	mov    0x8(%ebp),%eax
  105924:	0f b6 00             	movzbl (%eax),%eax
  105927:	3c 2f                	cmp    $0x2f,%al
  105929:	7e 1b                	jle    105946 <strtol+0xd0>
  10592b:	8b 45 08             	mov    0x8(%ebp),%eax
  10592e:	0f b6 00             	movzbl (%eax),%eax
  105931:	3c 39                	cmp    $0x39,%al
  105933:	7f 11                	jg     105946 <strtol+0xd0>
            dig = *s - '0';
  105935:	8b 45 08             	mov    0x8(%ebp),%eax
  105938:	0f b6 00             	movzbl (%eax),%eax
  10593b:	0f be c0             	movsbl %al,%eax
  10593e:	83 e8 30             	sub    $0x30,%eax
  105941:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105944:	eb 48                	jmp    10598e <strtol+0x118>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105946:	8b 45 08             	mov    0x8(%ebp),%eax
  105949:	0f b6 00             	movzbl (%eax),%eax
  10594c:	3c 60                	cmp    $0x60,%al
  10594e:	7e 1b                	jle    10596b <strtol+0xf5>
  105950:	8b 45 08             	mov    0x8(%ebp),%eax
  105953:	0f b6 00             	movzbl (%eax),%eax
  105956:	3c 7a                	cmp    $0x7a,%al
  105958:	7f 11                	jg     10596b <strtol+0xf5>
            dig = *s - 'a' + 10;
  10595a:	8b 45 08             	mov    0x8(%ebp),%eax
  10595d:	0f b6 00             	movzbl (%eax),%eax
  105960:	0f be c0             	movsbl %al,%eax
  105963:	83 e8 57             	sub    $0x57,%eax
  105966:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105969:	eb 23                	jmp    10598e <strtol+0x118>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10596b:	8b 45 08             	mov    0x8(%ebp),%eax
  10596e:	0f b6 00             	movzbl (%eax),%eax
  105971:	3c 40                	cmp    $0x40,%al
  105973:	7e 3b                	jle    1059b0 <strtol+0x13a>
  105975:	8b 45 08             	mov    0x8(%ebp),%eax
  105978:	0f b6 00             	movzbl (%eax),%eax
  10597b:	3c 5a                	cmp    $0x5a,%al
  10597d:	7f 31                	jg     1059b0 <strtol+0x13a>
            dig = *s - 'A' + 10;
  10597f:	8b 45 08             	mov    0x8(%ebp),%eax
  105982:	0f b6 00             	movzbl (%eax),%eax
  105985:	0f be c0             	movsbl %al,%eax
  105988:	83 e8 37             	sub    $0x37,%eax
  10598b:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  10598e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105991:	3b 45 10             	cmp    0x10(%ebp),%eax
  105994:	7d 19                	jge    1059af <strtol+0x139>
            break;
        }
        s ++, val = (val * base) + dig;
  105996:	ff 45 08             	incl   0x8(%ebp)
  105999:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10599c:	0f af 45 10          	imul   0x10(%ebp),%eax
  1059a0:	89 c2                	mov    %eax,%edx
  1059a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059a5:	01 d0                	add    %edx,%eax
  1059a7:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  1059aa:	e9 72 ff ff ff       	jmp    105921 <strtol+0xab>
            break;
  1059af:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  1059b0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1059b4:	74 08                	je     1059be <strtol+0x148>
        *endptr = (char *) s;
  1059b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059b9:	8b 55 08             	mov    0x8(%ebp),%edx
  1059bc:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  1059be:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  1059c2:	74 07                	je     1059cb <strtol+0x155>
  1059c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1059c7:	f7 d8                	neg    %eax
  1059c9:	eb 03                	jmp    1059ce <strtol+0x158>
  1059cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  1059ce:	c9                   	leave  
  1059cf:	c3                   	ret    

001059d0 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  1059d0:	f3 0f 1e fb          	endbr32 
  1059d4:	55                   	push   %ebp
  1059d5:	89 e5                	mov    %esp,%ebp
  1059d7:	57                   	push   %edi
  1059d8:	83 ec 24             	sub    $0x24,%esp
  1059db:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059de:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  1059e1:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  1059e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1059e8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1059eb:	88 55 f7             	mov    %dl,-0x9(%ebp)
  1059ee:	8b 45 10             	mov    0x10(%ebp),%eax
  1059f1:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1059f4:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1059f7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1059fb:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1059fe:	89 d7                	mov    %edx,%edi
  105a00:	f3 aa                	rep stos %al,%es:(%edi)
  105a02:	89 fa                	mov    %edi,%edx
  105a04:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105a07:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105a0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105a0d:	83 c4 24             	add    $0x24,%esp
  105a10:	5f                   	pop    %edi
  105a11:	5d                   	pop    %ebp
  105a12:	c3                   	ret    

00105a13 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105a13:	f3 0f 1e fb          	endbr32 
  105a17:	55                   	push   %ebp
  105a18:	89 e5                	mov    %esp,%ebp
  105a1a:	57                   	push   %edi
  105a1b:	56                   	push   %esi
  105a1c:	53                   	push   %ebx
  105a1d:	83 ec 30             	sub    $0x30,%esp
  105a20:	8b 45 08             	mov    0x8(%ebp),%eax
  105a23:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105a26:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a29:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105a2c:	8b 45 10             	mov    0x10(%ebp),%eax
  105a2f:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105a32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a35:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105a38:	73 42                	jae    105a7c <memmove+0x69>
  105a3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a3d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105a40:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a43:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105a46:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a49:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105a4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105a4f:	c1 e8 02             	shr    $0x2,%eax
  105a52:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105a54:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105a57:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105a5a:	89 d7                	mov    %edx,%edi
  105a5c:	89 c6                	mov    %eax,%esi
  105a5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105a60:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105a63:	83 e1 03             	and    $0x3,%ecx
  105a66:	74 02                	je     105a6a <memmove+0x57>
  105a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105a6a:	89 f0                	mov    %esi,%eax
  105a6c:	89 fa                	mov    %edi,%edx
  105a6e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105a71:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105a74:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  105a77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  105a7a:	eb 36                	jmp    105ab2 <memmove+0x9f>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105a7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a7f:	8d 50 ff             	lea    -0x1(%eax),%edx
  105a82:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a85:	01 c2                	add    %eax,%edx
  105a87:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a8a:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a90:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  105a93:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a96:	89 c1                	mov    %eax,%ecx
  105a98:	89 d8                	mov    %ebx,%eax
  105a9a:	89 d6                	mov    %edx,%esi
  105a9c:	89 c7                	mov    %eax,%edi
  105a9e:	fd                   	std    
  105a9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105aa1:	fc                   	cld    
  105aa2:	89 f8                	mov    %edi,%eax
  105aa4:	89 f2                	mov    %esi,%edx
  105aa6:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105aa9:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105aac:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  105aaf:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105ab2:	83 c4 30             	add    $0x30,%esp
  105ab5:	5b                   	pop    %ebx
  105ab6:	5e                   	pop    %esi
  105ab7:	5f                   	pop    %edi
  105ab8:	5d                   	pop    %ebp
  105ab9:	c3                   	ret    

00105aba <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105aba:	f3 0f 1e fb          	endbr32 
  105abe:	55                   	push   %ebp
  105abf:	89 e5                	mov    %esp,%ebp
  105ac1:	57                   	push   %edi
  105ac2:	56                   	push   %esi
  105ac3:	83 ec 20             	sub    $0x20,%esp
  105ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  105ac9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105acc:	8b 45 0c             	mov    0xc(%ebp),%eax
  105acf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105ad2:	8b 45 10             	mov    0x10(%ebp),%eax
  105ad5:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105ad8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105adb:	c1 e8 02             	shr    $0x2,%eax
  105ade:	89 c1                	mov    %eax,%ecx
    asm volatile (
  105ae0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105ae3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ae6:	89 d7                	mov    %edx,%edi
  105ae8:	89 c6                	mov    %eax,%esi
  105aea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105aec:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105aef:	83 e1 03             	and    $0x3,%ecx
  105af2:	74 02                	je     105af6 <memcpy+0x3c>
  105af4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105af6:	89 f0                	mov    %esi,%eax
  105af8:	89 fa                	mov    %edi,%edx
  105afa:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105afd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105b00:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  105b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105b06:	83 c4 20             	add    $0x20,%esp
  105b09:	5e                   	pop    %esi
  105b0a:	5f                   	pop    %edi
  105b0b:	5d                   	pop    %ebp
  105b0c:	c3                   	ret    

00105b0d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105b0d:	f3 0f 1e fb          	endbr32 
  105b11:	55                   	push   %ebp
  105b12:	89 e5                	mov    %esp,%ebp
  105b14:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105b17:	8b 45 08             	mov    0x8(%ebp),%eax
  105b1a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b20:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105b23:	eb 2e                	jmp    105b53 <memcmp+0x46>
        if (*s1 != *s2) {
  105b25:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b28:	0f b6 10             	movzbl (%eax),%edx
  105b2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105b2e:	0f b6 00             	movzbl (%eax),%eax
  105b31:	38 c2                	cmp    %al,%dl
  105b33:	74 18                	je     105b4d <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105b35:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105b38:	0f b6 00             	movzbl (%eax),%eax
  105b3b:	0f b6 d0             	movzbl %al,%edx
  105b3e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105b41:	0f b6 00             	movzbl (%eax),%eax
  105b44:	0f b6 c0             	movzbl %al,%eax
  105b47:	29 c2                	sub    %eax,%edx
  105b49:	89 d0                	mov    %edx,%eax
  105b4b:	eb 18                	jmp    105b65 <memcmp+0x58>
        }
        s1 ++, s2 ++;
  105b4d:	ff 45 fc             	incl   -0x4(%ebp)
  105b50:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  105b53:	8b 45 10             	mov    0x10(%ebp),%eax
  105b56:	8d 50 ff             	lea    -0x1(%eax),%edx
  105b59:	89 55 10             	mov    %edx,0x10(%ebp)
  105b5c:	85 c0                	test   %eax,%eax
  105b5e:	75 c5                	jne    105b25 <memcmp+0x18>
    }
    return 0;
  105b60:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105b65:	c9                   	leave  
  105b66:	c3                   	ret    

00105b67 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105b67:	f3 0f 1e fb          	endbr32 
  105b6b:	55                   	push   %ebp
  105b6c:	89 e5                	mov    %esp,%ebp
  105b6e:	83 ec 58             	sub    $0x58,%esp
  105b71:	8b 45 10             	mov    0x10(%ebp),%eax
  105b74:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105b77:	8b 45 14             	mov    0x14(%ebp),%eax
  105b7a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105b7d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105b80:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105b83:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105b86:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105b89:	8b 45 18             	mov    0x18(%ebp),%eax
  105b8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105b8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105b92:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105b95:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105b98:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105ba1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105ba5:	74 1c                	je     105bc3 <printnum+0x5c>
  105ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105baa:	ba 00 00 00 00       	mov    $0x0,%edx
  105baf:	f7 75 e4             	divl   -0x1c(%ebp)
  105bb2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105bb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  105bbd:	f7 75 e4             	divl   -0x1c(%ebp)
  105bc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105bc3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105bc6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105bc9:	f7 75 e4             	divl   -0x1c(%ebp)
  105bcc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105bcf:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105bd2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105bd5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105bd8:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105bdb:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105bde:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105be1:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105be4:	8b 45 18             	mov    0x18(%ebp),%eax
  105be7:	ba 00 00 00 00       	mov    $0x0,%edx
  105bec:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105bef:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  105bf2:	19 d1                	sbb    %edx,%ecx
  105bf4:	72 4c                	jb     105c42 <printnum+0xdb>
        printnum(putch, putdat, result, base, width - 1, padc);
  105bf6:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105bf9:	8d 50 ff             	lea    -0x1(%eax),%edx
  105bfc:	8b 45 20             	mov    0x20(%ebp),%eax
  105bff:	89 44 24 18          	mov    %eax,0x18(%esp)
  105c03:	89 54 24 14          	mov    %edx,0x14(%esp)
  105c07:	8b 45 18             	mov    0x18(%ebp),%eax
  105c0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  105c0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105c11:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105c14:	89 44 24 08          	mov    %eax,0x8(%esp)
  105c18:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c23:	8b 45 08             	mov    0x8(%ebp),%eax
  105c26:	89 04 24             	mov    %eax,(%esp)
  105c29:	e8 39 ff ff ff       	call   105b67 <printnum>
  105c2e:	eb 1b                	jmp    105c4b <printnum+0xe4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c37:	8b 45 20             	mov    0x20(%ebp),%eax
  105c3a:	89 04 24             	mov    %eax,(%esp)
  105c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  105c40:	ff d0                	call   *%eax
        while (-- width > 0)
  105c42:	ff 4d 1c             	decl   0x1c(%ebp)
  105c45:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105c49:	7f e5                	jg     105c30 <printnum+0xc9>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105c4b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105c4e:	05 ac 73 10 00       	add    $0x1073ac,%eax
  105c53:	0f b6 00             	movzbl (%eax),%eax
  105c56:	0f be c0             	movsbl %al,%eax
  105c59:	8b 55 0c             	mov    0xc(%ebp),%edx
  105c5c:	89 54 24 04          	mov    %edx,0x4(%esp)
  105c60:	89 04 24             	mov    %eax,(%esp)
  105c63:	8b 45 08             	mov    0x8(%ebp),%eax
  105c66:	ff d0                	call   *%eax
}
  105c68:	90                   	nop
  105c69:	c9                   	leave  
  105c6a:	c3                   	ret    

00105c6b <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105c6b:	f3 0f 1e fb          	endbr32 
  105c6f:	55                   	push   %ebp
  105c70:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105c72:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105c76:	7e 14                	jle    105c8c <getuint+0x21>
        return va_arg(*ap, unsigned long long);
  105c78:	8b 45 08             	mov    0x8(%ebp),%eax
  105c7b:	8b 00                	mov    (%eax),%eax
  105c7d:	8d 48 08             	lea    0x8(%eax),%ecx
  105c80:	8b 55 08             	mov    0x8(%ebp),%edx
  105c83:	89 0a                	mov    %ecx,(%edx)
  105c85:	8b 50 04             	mov    0x4(%eax),%edx
  105c88:	8b 00                	mov    (%eax),%eax
  105c8a:	eb 30                	jmp    105cbc <getuint+0x51>
    }
    else if (lflag) {
  105c8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105c90:	74 16                	je     105ca8 <getuint+0x3d>
        return va_arg(*ap, unsigned long);
  105c92:	8b 45 08             	mov    0x8(%ebp),%eax
  105c95:	8b 00                	mov    (%eax),%eax
  105c97:	8d 48 04             	lea    0x4(%eax),%ecx
  105c9a:	8b 55 08             	mov    0x8(%ebp),%edx
  105c9d:	89 0a                	mov    %ecx,(%edx)
  105c9f:	8b 00                	mov    (%eax),%eax
  105ca1:	ba 00 00 00 00       	mov    $0x0,%edx
  105ca6:	eb 14                	jmp    105cbc <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
  105ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  105cab:	8b 00                	mov    (%eax),%eax
  105cad:	8d 48 04             	lea    0x4(%eax),%ecx
  105cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  105cb3:	89 0a                	mov    %ecx,(%edx)
  105cb5:	8b 00                	mov    (%eax),%eax
  105cb7:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105cbc:	5d                   	pop    %ebp
  105cbd:	c3                   	ret    

00105cbe <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105cbe:	f3 0f 1e fb          	endbr32 
  105cc2:	55                   	push   %ebp
  105cc3:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105cc5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105cc9:	7e 14                	jle    105cdf <getint+0x21>
        return va_arg(*ap, long long);
  105ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  105cce:	8b 00                	mov    (%eax),%eax
  105cd0:	8d 48 08             	lea    0x8(%eax),%ecx
  105cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  105cd6:	89 0a                	mov    %ecx,(%edx)
  105cd8:	8b 50 04             	mov    0x4(%eax),%edx
  105cdb:	8b 00                	mov    (%eax),%eax
  105cdd:	eb 28                	jmp    105d07 <getint+0x49>
    }
    else if (lflag) {
  105cdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105ce3:	74 12                	je     105cf7 <getint+0x39>
        return va_arg(*ap, long);
  105ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  105ce8:	8b 00                	mov    (%eax),%eax
  105cea:	8d 48 04             	lea    0x4(%eax),%ecx
  105ced:	8b 55 08             	mov    0x8(%ebp),%edx
  105cf0:	89 0a                	mov    %ecx,(%edx)
  105cf2:	8b 00                	mov    (%eax),%eax
  105cf4:	99                   	cltd   
  105cf5:	eb 10                	jmp    105d07 <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
  105cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  105cfa:	8b 00                	mov    (%eax),%eax
  105cfc:	8d 48 04             	lea    0x4(%eax),%ecx
  105cff:	8b 55 08             	mov    0x8(%ebp),%edx
  105d02:	89 0a                	mov    %ecx,(%edx)
  105d04:	8b 00                	mov    (%eax),%eax
  105d06:	99                   	cltd   
    }
}
  105d07:	5d                   	pop    %ebp
  105d08:	c3                   	ret    

00105d09 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105d09:	f3 0f 1e fb          	endbr32 
  105d0d:	55                   	push   %ebp
  105d0e:	89 e5                	mov    %esp,%ebp
  105d10:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105d13:	8d 45 14             	lea    0x14(%ebp),%eax
  105d16:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105d1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105d20:	8b 45 10             	mov    0x10(%ebp),%eax
  105d23:	89 44 24 08          	mov    %eax,0x8(%esp)
  105d27:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  105d31:	89 04 24             	mov    %eax,(%esp)
  105d34:	e8 03 00 00 00       	call   105d3c <vprintfmt>
    va_end(ap);
}
  105d39:	90                   	nop
  105d3a:	c9                   	leave  
  105d3b:	c3                   	ret    

00105d3c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105d3c:	f3 0f 1e fb          	endbr32 
  105d40:	55                   	push   %ebp
  105d41:	89 e5                	mov    %esp,%ebp
  105d43:	56                   	push   %esi
  105d44:	53                   	push   %ebx
  105d45:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105d48:	eb 17                	jmp    105d61 <vprintfmt+0x25>
            if (ch == '\0') {
  105d4a:	85 db                	test   %ebx,%ebx
  105d4c:	0f 84 c0 03 00 00    	je     106112 <vprintfmt+0x3d6>
                return;
            }
            putch(ch, putdat);
  105d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d59:	89 1c 24             	mov    %ebx,(%esp)
  105d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5f:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105d61:	8b 45 10             	mov    0x10(%ebp),%eax
  105d64:	8d 50 01             	lea    0x1(%eax),%edx
  105d67:	89 55 10             	mov    %edx,0x10(%ebp)
  105d6a:	0f b6 00             	movzbl (%eax),%eax
  105d6d:	0f b6 d8             	movzbl %al,%ebx
  105d70:	83 fb 25             	cmp    $0x25,%ebx
  105d73:	75 d5                	jne    105d4a <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
  105d75:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  105d79:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  105d80:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105d83:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  105d86:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  105d8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105d90:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  105d93:	8b 45 10             	mov    0x10(%ebp),%eax
  105d96:	8d 50 01             	lea    0x1(%eax),%edx
  105d99:	89 55 10             	mov    %edx,0x10(%ebp)
  105d9c:	0f b6 00             	movzbl (%eax),%eax
  105d9f:	0f b6 d8             	movzbl %al,%ebx
  105da2:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105da5:	83 f8 55             	cmp    $0x55,%eax
  105da8:	0f 87 38 03 00 00    	ja     1060e6 <vprintfmt+0x3aa>
  105dae:	8b 04 85 d0 73 10 00 	mov    0x1073d0(,%eax,4),%eax
  105db5:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105db8:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105dbc:	eb d5                	jmp    105d93 <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105dbe:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  105dc2:	eb cf                	jmp    105d93 <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  105dc4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105dcb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105dce:	89 d0                	mov    %edx,%eax
  105dd0:	c1 e0 02             	shl    $0x2,%eax
  105dd3:	01 d0                	add    %edx,%eax
  105dd5:	01 c0                	add    %eax,%eax
  105dd7:	01 d8                	add    %ebx,%eax
  105dd9:	83 e8 30             	sub    $0x30,%eax
  105ddc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  105ddf:	8b 45 10             	mov    0x10(%ebp),%eax
  105de2:	0f b6 00             	movzbl (%eax),%eax
  105de5:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105de8:	83 fb 2f             	cmp    $0x2f,%ebx
  105deb:	7e 38                	jle    105e25 <vprintfmt+0xe9>
  105ded:	83 fb 39             	cmp    $0x39,%ebx
  105df0:	7f 33                	jg     105e25 <vprintfmt+0xe9>
            for (precision = 0; ; ++ fmt) {
  105df2:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105df5:	eb d4                	jmp    105dcb <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105df7:	8b 45 14             	mov    0x14(%ebp),%eax
  105dfa:	8d 50 04             	lea    0x4(%eax),%edx
  105dfd:	89 55 14             	mov    %edx,0x14(%ebp)
  105e00:	8b 00                	mov    (%eax),%eax
  105e02:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105e05:	eb 1f                	jmp    105e26 <vprintfmt+0xea>

        case '.':
            if (width < 0)
  105e07:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105e0b:	79 86                	jns    105d93 <vprintfmt+0x57>
                width = 0;
  105e0d:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  105e14:	e9 7a ff ff ff       	jmp    105d93 <vprintfmt+0x57>

        case '#':
            altflag = 1;
  105e19:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  105e20:	e9 6e ff ff ff       	jmp    105d93 <vprintfmt+0x57>
            goto process_precision;
  105e25:	90                   	nop

        process_precision:
            if (width < 0)
  105e26:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105e2a:	0f 89 63 ff ff ff    	jns    105d93 <vprintfmt+0x57>
                width = precision, precision = -1;
  105e30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105e33:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105e36:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105e3d:	e9 51 ff ff ff       	jmp    105d93 <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  105e42:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  105e45:	e9 49 ff ff ff       	jmp    105d93 <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  105e4a:	8b 45 14             	mov    0x14(%ebp),%eax
  105e4d:	8d 50 04             	lea    0x4(%eax),%edx
  105e50:	89 55 14             	mov    %edx,0x14(%ebp)
  105e53:	8b 00                	mov    (%eax),%eax
  105e55:	8b 55 0c             	mov    0xc(%ebp),%edx
  105e58:	89 54 24 04          	mov    %edx,0x4(%esp)
  105e5c:	89 04 24             	mov    %eax,(%esp)
  105e5f:	8b 45 08             	mov    0x8(%ebp),%eax
  105e62:	ff d0                	call   *%eax
            break;
  105e64:	e9 a4 02 00 00       	jmp    10610d <vprintfmt+0x3d1>

        // error message
        case 'e':
            err = va_arg(ap, int);
  105e69:	8b 45 14             	mov    0x14(%ebp),%eax
  105e6c:	8d 50 04             	lea    0x4(%eax),%edx
  105e6f:	89 55 14             	mov    %edx,0x14(%ebp)
  105e72:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  105e74:	85 db                	test   %ebx,%ebx
  105e76:	79 02                	jns    105e7a <vprintfmt+0x13e>
                err = -err;
  105e78:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  105e7a:	83 fb 06             	cmp    $0x6,%ebx
  105e7d:	7f 0b                	jg     105e8a <vprintfmt+0x14e>
  105e7f:	8b 34 9d 90 73 10 00 	mov    0x107390(,%ebx,4),%esi
  105e86:	85 f6                	test   %esi,%esi
  105e88:	75 23                	jne    105ead <vprintfmt+0x171>
                printfmt(putch, putdat, "error %d", err);
  105e8a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105e8e:	c7 44 24 08 bd 73 10 	movl   $0x1073bd,0x8(%esp)
  105e95:	00 
  105e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  105e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  105ea0:	89 04 24             	mov    %eax,(%esp)
  105ea3:	e8 61 fe ff ff       	call   105d09 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105ea8:	e9 60 02 00 00       	jmp    10610d <vprintfmt+0x3d1>
                printfmt(putch, putdat, "%s", p);
  105ead:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105eb1:	c7 44 24 08 c6 73 10 	movl   $0x1073c6,0x8(%esp)
  105eb8:	00 
  105eb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ebc:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ec0:	8b 45 08             	mov    0x8(%ebp),%eax
  105ec3:	89 04 24             	mov    %eax,(%esp)
  105ec6:	e8 3e fe ff ff       	call   105d09 <printfmt>
            break;
  105ecb:	e9 3d 02 00 00       	jmp    10610d <vprintfmt+0x3d1>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105ed0:	8b 45 14             	mov    0x14(%ebp),%eax
  105ed3:	8d 50 04             	lea    0x4(%eax),%edx
  105ed6:	89 55 14             	mov    %edx,0x14(%ebp)
  105ed9:	8b 30                	mov    (%eax),%esi
  105edb:	85 f6                	test   %esi,%esi
  105edd:	75 05                	jne    105ee4 <vprintfmt+0x1a8>
                p = "(null)";
  105edf:	be c9 73 10 00       	mov    $0x1073c9,%esi
            }
            if (width > 0 && padc != '-') {
  105ee4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105ee8:	7e 76                	jle    105f60 <vprintfmt+0x224>
  105eea:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105eee:	74 70                	je     105f60 <vprintfmt+0x224>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105ef0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ef7:	89 34 24             	mov    %esi,(%esp)
  105efa:	e8 ba f7 ff ff       	call   1056b9 <strnlen>
  105eff:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105f02:	29 c2                	sub    %eax,%edx
  105f04:	89 d0                	mov    %edx,%eax
  105f06:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105f09:	eb 16                	jmp    105f21 <vprintfmt+0x1e5>
                    putch(padc, putdat);
  105f0b:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105f0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  105f12:	89 54 24 04          	mov    %edx,0x4(%esp)
  105f16:	89 04 24             	mov    %eax,(%esp)
  105f19:	8b 45 08             	mov    0x8(%ebp),%eax
  105f1c:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105f1e:	ff 4d e8             	decl   -0x18(%ebp)
  105f21:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105f25:	7f e4                	jg     105f0b <vprintfmt+0x1cf>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105f27:	eb 37                	jmp    105f60 <vprintfmt+0x224>
                if (altflag && (ch < ' ' || ch > '~')) {
  105f29:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105f2d:	74 1f                	je     105f4e <vprintfmt+0x212>
  105f2f:	83 fb 1f             	cmp    $0x1f,%ebx
  105f32:	7e 05                	jle    105f39 <vprintfmt+0x1fd>
  105f34:	83 fb 7e             	cmp    $0x7e,%ebx
  105f37:	7e 15                	jle    105f4e <vprintfmt+0x212>
                    putch('?', putdat);
  105f39:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f40:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105f47:	8b 45 08             	mov    0x8(%ebp),%eax
  105f4a:	ff d0                	call   *%eax
  105f4c:	eb 0f                	jmp    105f5d <vprintfmt+0x221>
                }
                else {
                    putch(ch, putdat);
  105f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f51:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f55:	89 1c 24             	mov    %ebx,(%esp)
  105f58:	8b 45 08             	mov    0x8(%ebp),%eax
  105f5b:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105f5d:	ff 4d e8             	decl   -0x18(%ebp)
  105f60:	89 f0                	mov    %esi,%eax
  105f62:	8d 70 01             	lea    0x1(%eax),%esi
  105f65:	0f b6 00             	movzbl (%eax),%eax
  105f68:	0f be d8             	movsbl %al,%ebx
  105f6b:	85 db                	test   %ebx,%ebx
  105f6d:	74 27                	je     105f96 <vprintfmt+0x25a>
  105f6f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105f73:	78 b4                	js     105f29 <vprintfmt+0x1ed>
  105f75:	ff 4d e4             	decl   -0x1c(%ebp)
  105f78:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105f7c:	79 ab                	jns    105f29 <vprintfmt+0x1ed>
                }
            }
            for (; width > 0; width --) {
  105f7e:	eb 16                	jmp    105f96 <vprintfmt+0x25a>
                putch(' ', putdat);
  105f80:	8b 45 0c             	mov    0xc(%ebp),%eax
  105f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  105f87:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  105f91:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105f93:	ff 4d e8             	decl   -0x18(%ebp)
  105f96:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105f9a:	7f e4                	jg     105f80 <vprintfmt+0x244>
            }
            break;
  105f9c:	e9 6c 01 00 00       	jmp    10610d <vprintfmt+0x3d1>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fa8:	8d 45 14             	lea    0x14(%ebp),%eax
  105fab:	89 04 24             	mov    %eax,(%esp)
  105fae:	e8 0b fd ff ff       	call   105cbe <getint>
  105fb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105fb6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105fbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105fbf:	85 d2                	test   %edx,%edx
  105fc1:	79 26                	jns    105fe9 <vprintfmt+0x2ad>
                putch('-', putdat);
  105fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fca:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105fd1:	8b 45 08             	mov    0x8(%ebp),%eax
  105fd4:	ff d0                	call   *%eax
                num = -(long long)num;
  105fd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105fd9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105fdc:	f7 d8                	neg    %eax
  105fde:	83 d2 00             	adc    $0x0,%edx
  105fe1:	f7 da                	neg    %edx
  105fe3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105fe6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105fe9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105ff0:	e9 a8 00 00 00       	jmp    10609d <vprintfmt+0x361>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105ff5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105ff8:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ffc:	8d 45 14             	lea    0x14(%ebp),%eax
  105fff:	89 04 24             	mov    %eax,(%esp)
  106002:	e8 64 fc ff ff       	call   105c6b <getuint>
  106007:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10600a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  10600d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106014:	e9 84 00 00 00       	jmp    10609d <vprintfmt+0x361>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  106019:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10601c:	89 44 24 04          	mov    %eax,0x4(%esp)
  106020:	8d 45 14             	lea    0x14(%ebp),%eax
  106023:	89 04 24             	mov    %eax,(%esp)
  106026:	e8 40 fc ff ff       	call   105c6b <getuint>
  10602b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10602e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  106031:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  106038:	eb 63                	jmp    10609d <vprintfmt+0x361>

        // pointer
        case 'p':
            putch('0', putdat);
  10603a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10603d:	89 44 24 04          	mov    %eax,0x4(%esp)
  106041:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  106048:	8b 45 08             	mov    0x8(%ebp),%eax
  10604b:	ff d0                	call   *%eax
            putch('x', putdat);
  10604d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106050:	89 44 24 04          	mov    %eax,0x4(%esp)
  106054:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  10605b:	8b 45 08             	mov    0x8(%ebp),%eax
  10605e:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  106060:	8b 45 14             	mov    0x14(%ebp),%eax
  106063:	8d 50 04             	lea    0x4(%eax),%edx
  106066:	89 55 14             	mov    %edx,0x14(%ebp)
  106069:	8b 00                	mov    (%eax),%eax
  10606b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10606e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  106075:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  10607c:	eb 1f                	jmp    10609d <vprintfmt+0x361>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  10607e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106081:	89 44 24 04          	mov    %eax,0x4(%esp)
  106085:	8d 45 14             	lea    0x14(%ebp),%eax
  106088:	89 04 24             	mov    %eax,(%esp)
  10608b:	e8 db fb ff ff       	call   105c6b <getuint>
  106090:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106093:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  106096:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  10609d:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  1060a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1060a4:	89 54 24 18          	mov    %edx,0x18(%esp)
  1060a8:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1060ab:	89 54 24 14          	mov    %edx,0x14(%esp)
  1060af:	89 44 24 10          	mov    %eax,0x10(%esp)
  1060b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1060b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1060bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1060c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1060c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1060cb:	89 04 24             	mov    %eax,(%esp)
  1060ce:	e8 94 fa ff ff       	call   105b67 <printnum>
            break;
  1060d3:	eb 38                	jmp    10610d <vprintfmt+0x3d1>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  1060d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1060dc:	89 1c 24             	mov    %ebx,(%esp)
  1060df:	8b 45 08             	mov    0x8(%ebp),%eax
  1060e2:	ff d0                	call   *%eax
            break;
  1060e4:	eb 27                	jmp    10610d <vprintfmt+0x3d1>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  1060e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1060ed:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1060f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1060f7:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1060f9:	ff 4d 10             	decl   0x10(%ebp)
  1060fc:	eb 03                	jmp    106101 <vprintfmt+0x3c5>
  1060fe:	ff 4d 10             	decl   0x10(%ebp)
  106101:	8b 45 10             	mov    0x10(%ebp),%eax
  106104:	48                   	dec    %eax
  106105:	0f b6 00             	movzbl (%eax),%eax
  106108:	3c 25                	cmp    $0x25,%al
  10610a:	75 f2                	jne    1060fe <vprintfmt+0x3c2>
                /* do nothing */;
            break;
  10610c:	90                   	nop
    while (1) {
  10610d:	e9 36 fc ff ff       	jmp    105d48 <vprintfmt+0xc>
                return;
  106112:	90                   	nop
        }
    }
}
  106113:	83 c4 40             	add    $0x40,%esp
  106116:	5b                   	pop    %ebx
  106117:	5e                   	pop    %esi
  106118:	5d                   	pop    %ebp
  106119:	c3                   	ret    

0010611a <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  10611a:	f3 0f 1e fb          	endbr32 
  10611e:	55                   	push   %ebp
  10611f:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  106121:	8b 45 0c             	mov    0xc(%ebp),%eax
  106124:	8b 40 08             	mov    0x8(%eax),%eax
  106127:	8d 50 01             	lea    0x1(%eax),%edx
  10612a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10612d:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106130:	8b 45 0c             	mov    0xc(%ebp),%eax
  106133:	8b 10                	mov    (%eax),%edx
  106135:	8b 45 0c             	mov    0xc(%ebp),%eax
  106138:	8b 40 04             	mov    0x4(%eax),%eax
  10613b:	39 c2                	cmp    %eax,%edx
  10613d:	73 12                	jae    106151 <sprintputch+0x37>
        *b->buf ++ = ch;
  10613f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106142:	8b 00                	mov    (%eax),%eax
  106144:	8d 48 01             	lea    0x1(%eax),%ecx
  106147:	8b 55 0c             	mov    0xc(%ebp),%edx
  10614a:	89 0a                	mov    %ecx,(%edx)
  10614c:	8b 55 08             	mov    0x8(%ebp),%edx
  10614f:	88 10                	mov    %dl,(%eax)
    }
}
  106151:	90                   	nop
  106152:	5d                   	pop    %ebp
  106153:	c3                   	ret    

00106154 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  106154:	f3 0f 1e fb          	endbr32 
  106158:	55                   	push   %ebp
  106159:	89 e5                	mov    %esp,%ebp
  10615b:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10615e:	8d 45 14             	lea    0x14(%ebp),%eax
  106161:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106164:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106167:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10616b:	8b 45 10             	mov    0x10(%ebp),%eax
  10616e:	89 44 24 08          	mov    %eax,0x8(%esp)
  106172:	8b 45 0c             	mov    0xc(%ebp),%eax
  106175:	89 44 24 04          	mov    %eax,0x4(%esp)
  106179:	8b 45 08             	mov    0x8(%ebp),%eax
  10617c:	89 04 24             	mov    %eax,(%esp)
  10617f:	e8 08 00 00 00       	call   10618c <vsnprintf>
  106184:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  106187:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10618a:	c9                   	leave  
  10618b:	c3                   	ret    

0010618c <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  10618c:	f3 0f 1e fb          	endbr32 
  106190:	55                   	push   %ebp
  106191:	89 e5                	mov    %esp,%ebp
  106193:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  106196:	8b 45 08             	mov    0x8(%ebp),%eax
  106199:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10619c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10619f:	8d 50 ff             	lea    -0x1(%eax),%edx
  1061a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1061a5:	01 d0                	add    %edx,%eax
  1061a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1061aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  1061b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1061b5:	74 0a                	je     1061c1 <vsnprintf+0x35>
  1061b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1061ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1061bd:	39 c2                	cmp    %eax,%edx
  1061bf:	76 07                	jbe    1061c8 <vsnprintf+0x3c>
        return -E_INVAL;
  1061c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  1061c6:	eb 2a                	jmp    1061f2 <vsnprintf+0x66>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  1061c8:	8b 45 14             	mov    0x14(%ebp),%eax
  1061cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1061cf:	8b 45 10             	mov    0x10(%ebp),%eax
  1061d2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1061d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  1061d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1061dd:	c7 04 24 1a 61 10 00 	movl   $0x10611a,(%esp)
  1061e4:	e8 53 fb ff ff       	call   105d3c <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1061e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1061ec:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1061ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1061f2:	c9                   	leave  
  1061f3:	c3                   	ret    
