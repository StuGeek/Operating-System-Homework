
bin/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	f3 0f 1e fb          	endbr32 
  100004:	55                   	push   %ebp
  100005:	89 e5                	mov    %esp,%ebp
  100007:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10000a:	b8 20 0d 11 00       	mov    $0x110d20,%eax
  10000f:	2d 16 fa 10 00       	sub    $0x10fa16,%eax
  100014:	89 44 24 08          	mov    %eax,0x8(%esp)
  100018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001f:	00 
  100020:	c7 04 24 16 fa 10 00 	movl   $0x10fa16,(%esp)
  100027:	e8 5c 2e 00 00       	call   102e88 <memset>

    cons_init();                // init the console
  10002c:	e8 20 16 00 00       	call   101651 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 c0 36 10 00 	movl   $0x1036c0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 dc 36 10 00 	movl   $0x1036dc,(%esp)
  100046:	e8 48 02 00 00       	call   100293 <cprintf>

    print_kerninfo();
  10004b:	e8 06 09 00 00       	call   100956 <print_kerninfo>

    grade_backtrace();
  100050:	e8 9a 00 00 00       	call   1000ef <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 dd 2a 00 00       	call   102b37 <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 47 17 00 00       	call   1017a6 <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 ec 18 00 00       	call   101950 <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 6d 0d 00 00       	call   100dd6 <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 84 18 00 00       	call   1018f2 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  10006e:	e8 86 01 00 00       	call   1001f9 <lab1_switch_test>

    /* do nothing */
    while (1);
  100073:	eb fe                	jmp    100073 <kern_init+0x73>

00100075 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100075:	f3 0f 1e fb          	endbr32 
  100079:	55                   	push   %ebp
  10007a:	89 e5                	mov    %esp,%ebp
  10007c:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  10007f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  100086:	00 
  100087:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10008e:	00 
  10008f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100096:	e8 25 0d 00 00       	call   100dc0 <mon_backtrace>
}
  10009b:	90                   	nop
  10009c:	c9                   	leave  
  10009d:	c3                   	ret    

0010009e <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  10009e:	f3 0f 1e fb          	endbr32 
  1000a2:	55                   	push   %ebp
  1000a3:	89 e5                	mov    %esp,%ebp
  1000a5:	53                   	push   %ebx
  1000a6:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000a9:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000af:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1000b5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000c1:	89 04 24             	mov    %eax,(%esp)
  1000c4:	e8 ac ff ff ff       	call   100075 <grade_backtrace2>
}
  1000c9:	90                   	nop
  1000ca:	83 c4 14             	add    $0x14,%esp
  1000cd:	5b                   	pop    %ebx
  1000ce:	5d                   	pop    %ebp
  1000cf:	c3                   	ret    

001000d0 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000d0:	f3 0f 1e fb          	endbr32 
  1000d4:	55                   	push   %ebp
  1000d5:	89 e5                	mov    %esp,%ebp
  1000d7:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000da:	8b 45 10             	mov    0x10(%ebp),%eax
  1000dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000e1:	8b 45 08             	mov    0x8(%ebp),%eax
  1000e4:	89 04 24             	mov    %eax,(%esp)
  1000e7:	e8 b2 ff ff ff       	call   10009e <grade_backtrace1>
}
  1000ec:	90                   	nop
  1000ed:	c9                   	leave  
  1000ee:	c3                   	ret    

001000ef <grade_backtrace>:

void
grade_backtrace(void) {
  1000ef:	f3 0f 1e fb          	endbr32 
  1000f3:	55                   	push   %ebp
  1000f4:	89 e5                	mov    %esp,%ebp
  1000f6:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000f9:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000fe:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100105:	ff 
  100106:	89 44 24 04          	mov    %eax,0x4(%esp)
  10010a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100111:	e8 ba ff ff ff       	call   1000d0 <grade_backtrace0>
}
  100116:	90                   	nop
  100117:	c9                   	leave  
  100118:	c3                   	ret    

00100119 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100119:	f3 0f 1e fb          	endbr32 
  10011d:	55                   	push   %ebp
  10011e:	89 e5                	mov    %esp,%ebp
  100120:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100123:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100126:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100129:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10012c:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10012f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100133:	83 e0 03             	and    $0x3,%eax
  100136:	89 c2                	mov    %eax,%edx
  100138:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  10013d:	89 54 24 08          	mov    %edx,0x8(%esp)
  100141:	89 44 24 04          	mov    %eax,0x4(%esp)
  100145:	c7 04 24 e1 36 10 00 	movl   $0x1036e1,(%esp)
  10014c:	e8 42 01 00 00       	call   100293 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100155:	89 c2                	mov    %eax,%edx
  100157:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  10015c:	89 54 24 08          	mov    %edx,0x8(%esp)
  100160:	89 44 24 04          	mov    %eax,0x4(%esp)
  100164:	c7 04 24 ef 36 10 00 	movl   $0x1036ef,(%esp)
  10016b:	e8 23 01 00 00       	call   100293 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100170:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100174:	89 c2                	mov    %eax,%edx
  100176:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  10017b:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100183:	c7 04 24 fd 36 10 00 	movl   $0x1036fd,(%esp)
  10018a:	e8 04 01 00 00       	call   100293 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  10018f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100193:	89 c2                	mov    %eax,%edx
  100195:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  10019a:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019e:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a2:	c7 04 24 0b 37 10 00 	movl   $0x10370b,(%esp)
  1001a9:	e8 e5 00 00 00       	call   100293 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001ae:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001b2:	89 c2                	mov    %eax,%edx
  1001b4:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001b9:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c1:	c7 04 24 19 37 10 00 	movl   $0x103719,(%esp)
  1001c8:	e8 c6 00 00 00       	call   100293 <cprintf>
    round ++;
  1001cd:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001d2:	40                   	inc    %eax
  1001d3:	a3 20 fa 10 00       	mov    %eax,0x10fa20
}
  1001d8:	90                   	nop
  1001d9:	c9                   	leave  
  1001da:	c3                   	ret    

001001db <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001db:	f3 0f 1e fb          	endbr32 
  1001df:	55                   	push   %ebp
  1001e0:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
    asm volatile (
  1001e2:	16                   	push   %ss
  1001e3:	54                   	push   %esp
  1001e4:	cd 78                	int    $0x78
  1001e6:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp"
	    : 
	    : "i"(T_SWITCH_TOU)
	);
}
  1001e8:	90                   	nop
  1001e9:	5d                   	pop    %ebp
  1001ea:	c3                   	ret    

001001eb <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001eb:	f3 0f 1e fb          	endbr32 
  1001ef:	55                   	push   %ebp
  1001f0:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
  1001f2:	cd 79                	int    $0x79
  1001f4:	89 ec                	mov    %ebp,%esp
	    "int %0 \n"
	    "movl %%ebp, %%esp \n"
	    : 
	    : "i"(T_SWITCH_TOK)
	);
}
  1001f6:	90                   	nop
  1001f7:	5d                   	pop    %ebp
  1001f8:	c3                   	ret    

001001f9 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001f9:	f3 0f 1e fb          	endbr32 
  1001fd:	55                   	push   %ebp
  1001fe:	89 e5                	mov    %esp,%ebp
  100200:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100203:	e8 11 ff ff ff       	call   100119 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100208:	c7 04 24 28 37 10 00 	movl   $0x103728,(%esp)
  10020f:	e8 7f 00 00 00       	call   100293 <cprintf>
    lab1_switch_to_user();
  100214:	e8 c2 ff ff ff       	call   1001db <lab1_switch_to_user>
    lab1_print_cur_status();
  100219:	e8 fb fe ff ff       	call   100119 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10021e:	c7 04 24 48 37 10 00 	movl   $0x103748,(%esp)
  100225:	e8 69 00 00 00       	call   100293 <cprintf>
    lab1_switch_to_kernel();
  10022a:	e8 bc ff ff ff       	call   1001eb <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10022f:	e8 e5 fe ff ff       	call   100119 <lab1_print_cur_status>
}
  100234:	90                   	nop
  100235:	c9                   	leave  
  100236:	c3                   	ret    

00100237 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100237:	f3 0f 1e fb          	endbr32 
  10023b:	55                   	push   %ebp
  10023c:	89 e5                	mov    %esp,%ebp
  10023e:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100241:	8b 45 08             	mov    0x8(%ebp),%eax
  100244:	89 04 24             	mov    %eax,(%esp)
  100247:	e8 36 14 00 00       	call   101682 <cons_putc>
    (*cnt) ++;
  10024c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10024f:	8b 00                	mov    (%eax),%eax
  100251:	8d 50 01             	lea    0x1(%eax),%edx
  100254:	8b 45 0c             	mov    0xc(%ebp),%eax
  100257:	89 10                	mov    %edx,(%eax)
}
  100259:	90                   	nop
  10025a:	c9                   	leave  
  10025b:	c3                   	ret    

0010025c <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10025c:	f3 0f 1e fb          	endbr32 
  100260:	55                   	push   %ebp
  100261:	89 e5                	mov    %esp,%ebp
  100263:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10026d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100270:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100274:	8b 45 08             	mov    0x8(%ebp),%eax
  100277:	89 44 24 08          	mov    %eax,0x8(%esp)
  10027b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10027e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100282:	c7 04 24 37 02 10 00 	movl   $0x100237,(%esp)
  100289:	e8 66 2f 00 00       	call   1031f4 <vprintfmt>
    return cnt;
  10028e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100291:	c9                   	leave  
  100292:	c3                   	ret    

00100293 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100293:	f3 0f 1e fb          	endbr32 
  100297:	55                   	push   %ebp
  100298:	89 e5                	mov    %esp,%ebp
  10029a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10029d:	8d 45 0c             	lea    0xc(%ebp),%eax
  1002a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  1002a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1002ad:	89 04 24             	mov    %eax,(%esp)
  1002b0:	e8 a7 ff ff ff       	call   10025c <vcprintf>
  1002b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002bb:	c9                   	leave  
  1002bc:	c3                   	ret    

001002bd <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002bd:	f3 0f 1e fb          	endbr32 
  1002c1:	55                   	push   %ebp
  1002c2:	89 e5                	mov    %esp,%ebp
  1002c4:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1002ca:	89 04 24             	mov    %eax,(%esp)
  1002cd:	e8 b0 13 00 00       	call   101682 <cons_putc>
}
  1002d2:	90                   	nop
  1002d3:	c9                   	leave  
  1002d4:	c3                   	ret    

001002d5 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002d5:	f3 0f 1e fb          	endbr32 
  1002d9:	55                   	push   %ebp
  1002da:	89 e5                	mov    %esp,%ebp
  1002dc:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002df:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002e6:	eb 13                	jmp    1002fb <cputs+0x26>
        cputch(c, &cnt);
  1002e8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002ec:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002ef:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002f3:	89 04 24             	mov    %eax,(%esp)
  1002f6:	e8 3c ff ff ff       	call   100237 <cputch>
    while ((c = *str ++) != '\0') {
  1002fb:	8b 45 08             	mov    0x8(%ebp),%eax
  1002fe:	8d 50 01             	lea    0x1(%eax),%edx
  100301:	89 55 08             	mov    %edx,0x8(%ebp)
  100304:	0f b6 00             	movzbl (%eax),%eax
  100307:	88 45 f7             	mov    %al,-0x9(%ebp)
  10030a:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  10030e:	75 d8                	jne    1002e8 <cputs+0x13>
    }
    cputch('\n', &cnt);
  100310:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100313:	89 44 24 04          	mov    %eax,0x4(%esp)
  100317:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  10031e:	e8 14 ff ff ff       	call   100237 <cputch>
    return cnt;
  100323:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100326:	c9                   	leave  
  100327:	c3                   	ret    

00100328 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  100328:	f3 0f 1e fb          	endbr32 
  10032c:	55                   	push   %ebp
  10032d:	89 e5                	mov    %esp,%ebp
  10032f:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100332:	90                   	nop
  100333:	e8 78 13 00 00       	call   1016b0 <cons_getc>
  100338:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10033b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10033f:	74 f2                	je     100333 <getchar+0xb>
        /* do nothing */;
    return c;
  100341:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100344:	c9                   	leave  
  100345:	c3                   	ret    

00100346 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100346:	f3 0f 1e fb          	endbr32 
  10034a:	55                   	push   %ebp
  10034b:	89 e5                	mov    %esp,%ebp
  10034d:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100350:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100354:	74 13                	je     100369 <readline+0x23>
        cprintf("%s", prompt);
  100356:	8b 45 08             	mov    0x8(%ebp),%eax
  100359:	89 44 24 04          	mov    %eax,0x4(%esp)
  10035d:	c7 04 24 67 37 10 00 	movl   $0x103767,(%esp)
  100364:	e8 2a ff ff ff       	call   100293 <cprintf>
    }
    int i = 0, c;
  100369:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100370:	e8 b3 ff ff ff       	call   100328 <getchar>
  100375:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100378:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10037c:	79 07                	jns    100385 <readline+0x3f>
            return NULL;
  10037e:	b8 00 00 00 00       	mov    $0x0,%eax
  100383:	eb 78                	jmp    1003fd <readline+0xb7>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100385:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100389:	7e 28                	jle    1003b3 <readline+0x6d>
  10038b:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100392:	7f 1f                	jg     1003b3 <readline+0x6d>
            cputchar(c);
  100394:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100397:	89 04 24             	mov    %eax,(%esp)
  10039a:	e8 1e ff ff ff       	call   1002bd <cputchar>
            buf[i ++] = c;
  10039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003a2:	8d 50 01             	lea    0x1(%eax),%edx
  1003a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1003a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1003ab:	88 90 40 fa 10 00    	mov    %dl,0x10fa40(%eax)
  1003b1:	eb 45                	jmp    1003f8 <readline+0xb2>
        }
        else if (c == '\b' && i > 0) {
  1003b3:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003b7:	75 16                	jne    1003cf <readline+0x89>
  1003b9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003bd:	7e 10                	jle    1003cf <readline+0x89>
            cputchar(c);
  1003bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003c2:	89 04 24             	mov    %eax,(%esp)
  1003c5:	e8 f3 fe ff ff       	call   1002bd <cputchar>
            i --;
  1003ca:	ff 4d f4             	decl   -0xc(%ebp)
  1003cd:	eb 29                	jmp    1003f8 <readline+0xb2>
        }
        else if (c == '\n' || c == '\r') {
  1003cf:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003d3:	74 06                	je     1003db <readline+0x95>
  1003d5:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003d9:	75 95                	jne    100370 <readline+0x2a>
            cputchar(c);
  1003db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003de:	89 04 24             	mov    %eax,(%esp)
  1003e1:	e8 d7 fe ff ff       	call   1002bd <cputchar>
            buf[i] = '\0';
  1003e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003e9:	05 40 fa 10 00       	add    $0x10fa40,%eax
  1003ee:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003f1:	b8 40 fa 10 00       	mov    $0x10fa40,%eax
  1003f6:	eb 05                	jmp    1003fd <readline+0xb7>
        c = getchar();
  1003f8:	e9 73 ff ff ff       	jmp    100370 <readline+0x2a>
        }
    }
}
  1003fd:	c9                   	leave  
  1003fe:	c3                   	ret    

001003ff <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003ff:	f3 0f 1e fb          	endbr32 
  100403:	55                   	push   %ebp
  100404:	89 e5                	mov    %esp,%ebp
  100406:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100409:	a1 40 fe 10 00       	mov    0x10fe40,%eax
  10040e:	85 c0                	test   %eax,%eax
  100410:	75 5b                	jne    10046d <__panic+0x6e>
        goto panic_dead;
    }
    is_panic = 1;
  100412:	c7 05 40 fe 10 00 01 	movl   $0x1,0x10fe40
  100419:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  10041c:	8d 45 14             	lea    0x14(%ebp),%eax
  10041f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100422:	8b 45 0c             	mov    0xc(%ebp),%eax
  100425:	89 44 24 08          	mov    %eax,0x8(%esp)
  100429:	8b 45 08             	mov    0x8(%ebp),%eax
  10042c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100430:	c7 04 24 6a 37 10 00 	movl   $0x10376a,(%esp)
  100437:	e8 57 fe ff ff       	call   100293 <cprintf>
    vcprintf(fmt, ap);
  10043c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10043f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100443:	8b 45 10             	mov    0x10(%ebp),%eax
  100446:	89 04 24             	mov    %eax,(%esp)
  100449:	e8 0e fe ff ff       	call   10025c <vcprintf>
    cprintf("\n");
  10044e:	c7 04 24 86 37 10 00 	movl   $0x103786,(%esp)
  100455:	e8 39 fe ff ff       	call   100293 <cprintf>
    
    cprintf("stack trackback:\n");
  10045a:	c7 04 24 88 37 10 00 	movl   $0x103788,(%esp)
  100461:	e8 2d fe ff ff       	call   100293 <cprintf>
    print_stackframe();
  100466:	e8 3d 06 00 00       	call   100aa8 <print_stackframe>
  10046b:	eb 01                	jmp    10046e <__panic+0x6f>
        goto panic_dead;
  10046d:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  10046e:	e8 8b 14 00 00       	call   1018fe <intr_disable>
    while (1) {
        kmonitor(NULL);
  100473:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10047a:	e8 68 08 00 00       	call   100ce7 <kmonitor>
  10047f:	eb f2                	jmp    100473 <__panic+0x74>

00100481 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100481:	f3 0f 1e fb          	endbr32 
  100485:	55                   	push   %ebp
  100486:	89 e5                	mov    %esp,%ebp
  100488:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  10048b:	8d 45 14             	lea    0x14(%ebp),%eax
  10048e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100491:	8b 45 0c             	mov    0xc(%ebp),%eax
  100494:	89 44 24 08          	mov    %eax,0x8(%esp)
  100498:	8b 45 08             	mov    0x8(%ebp),%eax
  10049b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10049f:	c7 04 24 9a 37 10 00 	movl   $0x10379a,(%esp)
  1004a6:	e8 e8 fd ff ff       	call   100293 <cprintf>
    vcprintf(fmt, ap);
  1004ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1004ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  1004b2:	8b 45 10             	mov    0x10(%ebp),%eax
  1004b5:	89 04 24             	mov    %eax,(%esp)
  1004b8:	e8 9f fd ff ff       	call   10025c <vcprintf>
    cprintf("\n");
  1004bd:	c7 04 24 86 37 10 00 	movl   $0x103786,(%esp)
  1004c4:	e8 ca fd ff ff       	call   100293 <cprintf>
    va_end(ap);
}
  1004c9:	90                   	nop
  1004ca:	c9                   	leave  
  1004cb:	c3                   	ret    

001004cc <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004cc:	f3 0f 1e fb          	endbr32 
  1004d0:	55                   	push   %ebp
  1004d1:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004d3:	a1 40 fe 10 00       	mov    0x10fe40,%eax
}
  1004d8:	5d                   	pop    %ebp
  1004d9:	c3                   	ret    

001004da <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004da:	f3 0f 1e fb          	endbr32 
  1004de:	55                   	push   %ebp
  1004df:	89 e5                	mov    %esp,%ebp
  1004e1:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004e7:	8b 00                	mov    (%eax),%eax
  1004e9:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004ec:	8b 45 10             	mov    0x10(%ebp),%eax
  1004ef:	8b 00                	mov    (%eax),%eax
  1004f1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004fb:	e9 ca 00 00 00       	jmp    1005ca <stab_binsearch+0xf0>
        int true_m = (l + r) / 2, m = true_m;
  100500:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100503:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100506:	01 d0                	add    %edx,%eax
  100508:	89 c2                	mov    %eax,%edx
  10050a:	c1 ea 1f             	shr    $0x1f,%edx
  10050d:	01 d0                	add    %edx,%eax
  10050f:	d1 f8                	sar    %eax
  100511:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100514:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100517:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10051a:	eb 03                	jmp    10051f <stab_binsearch+0x45>
            m --;
  10051c:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  10051f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100522:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100525:	7c 1f                	jl     100546 <stab_binsearch+0x6c>
  100527:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10052a:	89 d0                	mov    %edx,%eax
  10052c:	01 c0                	add    %eax,%eax
  10052e:	01 d0                	add    %edx,%eax
  100530:	c1 e0 02             	shl    $0x2,%eax
  100533:	89 c2                	mov    %eax,%edx
  100535:	8b 45 08             	mov    0x8(%ebp),%eax
  100538:	01 d0                	add    %edx,%eax
  10053a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10053e:	0f b6 c0             	movzbl %al,%eax
  100541:	39 45 14             	cmp    %eax,0x14(%ebp)
  100544:	75 d6                	jne    10051c <stab_binsearch+0x42>
        }
        if (m < l) {    // no match in [l, m]
  100546:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100549:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10054c:	7d 09                	jge    100557 <stab_binsearch+0x7d>
            l = true_m + 1;
  10054e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100551:	40                   	inc    %eax
  100552:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100555:	eb 73                	jmp    1005ca <stab_binsearch+0xf0>
        }

        // actual binary search
        any_matches = 1;
  100557:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10055e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100561:	89 d0                	mov    %edx,%eax
  100563:	01 c0                	add    %eax,%eax
  100565:	01 d0                	add    %edx,%eax
  100567:	c1 e0 02             	shl    $0x2,%eax
  10056a:	89 c2                	mov    %eax,%edx
  10056c:	8b 45 08             	mov    0x8(%ebp),%eax
  10056f:	01 d0                	add    %edx,%eax
  100571:	8b 40 08             	mov    0x8(%eax),%eax
  100574:	39 45 18             	cmp    %eax,0x18(%ebp)
  100577:	76 11                	jbe    10058a <stab_binsearch+0xb0>
            *region_left = m;
  100579:	8b 45 0c             	mov    0xc(%ebp),%eax
  10057c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10057f:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100581:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100584:	40                   	inc    %eax
  100585:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100588:	eb 40                	jmp    1005ca <stab_binsearch+0xf0>
        } else if (stabs[m].n_value > addr) {
  10058a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10058d:	89 d0                	mov    %edx,%eax
  10058f:	01 c0                	add    %eax,%eax
  100591:	01 d0                	add    %edx,%eax
  100593:	c1 e0 02             	shl    $0x2,%eax
  100596:	89 c2                	mov    %eax,%edx
  100598:	8b 45 08             	mov    0x8(%ebp),%eax
  10059b:	01 d0                	add    %edx,%eax
  10059d:	8b 40 08             	mov    0x8(%eax),%eax
  1005a0:	39 45 18             	cmp    %eax,0x18(%ebp)
  1005a3:	73 14                	jae    1005b9 <stab_binsearch+0xdf>
            *region_right = m - 1;
  1005a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005a8:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005ab:	8b 45 10             	mov    0x10(%ebp),%eax
  1005ae:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1005b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005b3:	48                   	dec    %eax
  1005b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1005b7:	eb 11                	jmp    1005ca <stab_binsearch+0xf0>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1005b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005bf:	89 10                	mov    %edx,(%eax)
            l = m;
  1005c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005c7:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1005ca:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005cd:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005d0:	0f 8e 2a ff ff ff    	jle    100500 <stab_binsearch+0x26>
        }
    }

    if (!any_matches) {
  1005d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005da:	75 0f                	jne    1005eb <stab_binsearch+0x111>
        *region_right = *region_left - 1;
  1005dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005df:	8b 00                	mov    (%eax),%eax
  1005e1:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005e4:	8b 45 10             	mov    0x10(%ebp),%eax
  1005e7:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1005e9:	eb 3e                	jmp    100629 <stab_binsearch+0x14f>
        l = *region_right;
  1005eb:	8b 45 10             	mov    0x10(%ebp),%eax
  1005ee:	8b 00                	mov    (%eax),%eax
  1005f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005f3:	eb 03                	jmp    1005f8 <stab_binsearch+0x11e>
  1005f5:	ff 4d fc             	decl   -0x4(%ebp)
  1005f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fb:	8b 00                	mov    (%eax),%eax
  1005fd:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  100600:	7e 1f                	jle    100621 <stab_binsearch+0x147>
  100602:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100605:	89 d0                	mov    %edx,%eax
  100607:	01 c0                	add    %eax,%eax
  100609:	01 d0                	add    %edx,%eax
  10060b:	c1 e0 02             	shl    $0x2,%eax
  10060e:	89 c2                	mov    %eax,%edx
  100610:	8b 45 08             	mov    0x8(%ebp),%eax
  100613:	01 d0                	add    %edx,%eax
  100615:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100619:	0f b6 c0             	movzbl %al,%eax
  10061c:	39 45 14             	cmp    %eax,0x14(%ebp)
  10061f:	75 d4                	jne    1005f5 <stab_binsearch+0x11b>
        *region_left = l;
  100621:	8b 45 0c             	mov    0xc(%ebp),%eax
  100624:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100627:	89 10                	mov    %edx,(%eax)
}
  100629:	90                   	nop
  10062a:	c9                   	leave  
  10062b:	c3                   	ret    

0010062c <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10062c:	f3 0f 1e fb          	endbr32 
  100630:	55                   	push   %ebp
  100631:	89 e5                	mov    %esp,%ebp
  100633:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100636:	8b 45 0c             	mov    0xc(%ebp),%eax
  100639:	c7 00 b8 37 10 00    	movl   $0x1037b8,(%eax)
    info->eip_line = 0;
  10063f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100642:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100649:	8b 45 0c             	mov    0xc(%ebp),%eax
  10064c:	c7 40 08 b8 37 10 00 	movl   $0x1037b8,0x8(%eax)
    info->eip_fn_namelen = 9;
  100653:	8b 45 0c             	mov    0xc(%ebp),%eax
  100656:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10065d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100660:	8b 55 08             	mov    0x8(%ebp),%edx
  100663:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100666:	8b 45 0c             	mov    0xc(%ebp),%eax
  100669:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100670:	c7 45 f4 0c 40 10 00 	movl   $0x10400c,-0xc(%ebp)
    stab_end = __STAB_END__;
  100677:	c7 45 f0 d8 cd 10 00 	movl   $0x10cdd8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10067e:	c7 45 ec d9 cd 10 00 	movl   $0x10cdd9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100685:	c7 45 e8 e9 ee 10 00 	movl   $0x10eee9,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10068c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10068f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100692:	76 0b                	jbe    10069f <debuginfo_eip+0x73>
  100694:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100697:	48                   	dec    %eax
  100698:	0f b6 00             	movzbl (%eax),%eax
  10069b:	84 c0                	test   %al,%al
  10069d:	74 0a                	je     1006a9 <debuginfo_eip+0x7d>
        return -1;
  10069f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006a4:	e9 ab 02 00 00       	jmp    100954 <debuginfo_eip+0x328>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1006a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1006b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1006b3:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1006b6:	c1 f8 02             	sar    $0x2,%eax
  1006b9:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1006bf:	48                   	dec    %eax
  1006c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1006c6:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006ca:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1006d1:	00 
  1006d2:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006d9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006e3:	89 04 24             	mov    %eax,(%esp)
  1006e6:	e8 ef fd ff ff       	call   1004da <stab_binsearch>
    if (lfile == 0)
  1006eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006ee:	85 c0                	test   %eax,%eax
  1006f0:	75 0a                	jne    1006fc <debuginfo_eip+0xd0>
        return -1;
  1006f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006f7:	e9 58 02 00 00       	jmp    100954 <debuginfo_eip+0x328>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100702:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100705:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  100708:	8b 45 08             	mov    0x8(%ebp),%eax
  10070b:	89 44 24 10          	mov    %eax,0x10(%esp)
  10070f:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100716:	00 
  100717:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10071a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10071e:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100721:	89 44 24 04          	mov    %eax,0x4(%esp)
  100725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100728:	89 04 24             	mov    %eax,(%esp)
  10072b:	e8 aa fd ff ff       	call   1004da <stab_binsearch>

    if (lfun <= rfun) {
  100730:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100733:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100736:	39 c2                	cmp    %eax,%edx
  100738:	7f 78                	jg     1007b2 <debuginfo_eip+0x186>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10073a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10073d:	89 c2                	mov    %eax,%edx
  10073f:	89 d0                	mov    %edx,%eax
  100741:	01 c0                	add    %eax,%eax
  100743:	01 d0                	add    %edx,%eax
  100745:	c1 e0 02             	shl    $0x2,%eax
  100748:	89 c2                	mov    %eax,%edx
  10074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10074d:	01 d0                	add    %edx,%eax
  10074f:	8b 10                	mov    (%eax),%edx
  100751:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100754:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100757:	39 c2                	cmp    %eax,%edx
  100759:	73 22                	jae    10077d <debuginfo_eip+0x151>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10075b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10075e:	89 c2                	mov    %eax,%edx
  100760:	89 d0                	mov    %edx,%eax
  100762:	01 c0                	add    %eax,%eax
  100764:	01 d0                	add    %edx,%eax
  100766:	c1 e0 02             	shl    $0x2,%eax
  100769:	89 c2                	mov    %eax,%edx
  10076b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10076e:	01 d0                	add    %edx,%eax
  100770:	8b 10                	mov    (%eax),%edx
  100772:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100775:	01 c2                	add    %eax,%edx
  100777:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077a:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10077d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100780:	89 c2                	mov    %eax,%edx
  100782:	89 d0                	mov    %edx,%eax
  100784:	01 c0                	add    %eax,%eax
  100786:	01 d0                	add    %edx,%eax
  100788:	c1 e0 02             	shl    $0x2,%eax
  10078b:	89 c2                	mov    %eax,%edx
  10078d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100790:	01 d0                	add    %edx,%eax
  100792:	8b 50 08             	mov    0x8(%eax),%edx
  100795:	8b 45 0c             	mov    0xc(%ebp),%eax
  100798:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  10079b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10079e:	8b 40 10             	mov    0x10(%eax),%eax
  1007a1:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1007a4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1007a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1007aa:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1007ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1007b0:	eb 15                	jmp    1007c7 <debuginfo_eip+0x19b>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007b5:	8b 55 08             	mov    0x8(%ebp),%edx
  1007b8:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1007bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007be:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1007c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007c4:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007ca:	8b 40 08             	mov    0x8(%eax),%eax
  1007cd:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1007d4:	00 
  1007d5:	89 04 24             	mov    %eax,(%esp)
  1007d8:	e8 1f 25 00 00       	call   102cfc <strfind>
  1007dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  1007e0:	8b 52 08             	mov    0x8(%edx),%edx
  1007e3:	29 d0                	sub    %edx,%eax
  1007e5:	89 c2                	mov    %eax,%edx
  1007e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007ea:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1007f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007f4:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007fb:	00 
  1007fc:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  100803:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100806:	89 44 24 04          	mov    %eax,0x4(%esp)
  10080a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10080d:	89 04 24             	mov    %eax,(%esp)
  100810:	e8 c5 fc ff ff       	call   1004da <stab_binsearch>
    if (lline <= rline) {
  100815:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100818:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10081b:	39 c2                	cmp    %eax,%edx
  10081d:	7f 23                	jg     100842 <debuginfo_eip+0x216>
        info->eip_line = stabs[rline].n_desc;
  10081f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100822:	89 c2                	mov    %eax,%edx
  100824:	89 d0                	mov    %edx,%eax
  100826:	01 c0                	add    %eax,%eax
  100828:	01 d0                	add    %edx,%eax
  10082a:	c1 e0 02             	shl    $0x2,%eax
  10082d:	89 c2                	mov    %eax,%edx
  10082f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100832:	01 d0                	add    %edx,%eax
  100834:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100838:	89 c2                	mov    %eax,%edx
  10083a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10083d:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100840:	eb 11                	jmp    100853 <debuginfo_eip+0x227>
        return -1;
  100842:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100847:	e9 08 01 00 00       	jmp    100954 <debuginfo_eip+0x328>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10084c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10084f:	48                   	dec    %eax
  100850:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100853:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100856:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100859:	39 c2                	cmp    %eax,%edx
  10085b:	7c 56                	jl     1008b3 <debuginfo_eip+0x287>
           && stabs[lline].n_type != N_SOL
  10085d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100860:	89 c2                	mov    %eax,%edx
  100862:	89 d0                	mov    %edx,%eax
  100864:	01 c0                	add    %eax,%eax
  100866:	01 d0                	add    %edx,%eax
  100868:	c1 e0 02             	shl    $0x2,%eax
  10086b:	89 c2                	mov    %eax,%edx
  10086d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100870:	01 d0                	add    %edx,%eax
  100872:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100876:	3c 84                	cmp    $0x84,%al
  100878:	74 39                	je     1008b3 <debuginfo_eip+0x287>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10087a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10087d:	89 c2                	mov    %eax,%edx
  10087f:	89 d0                	mov    %edx,%eax
  100881:	01 c0                	add    %eax,%eax
  100883:	01 d0                	add    %edx,%eax
  100885:	c1 e0 02             	shl    $0x2,%eax
  100888:	89 c2                	mov    %eax,%edx
  10088a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10088d:	01 d0                	add    %edx,%eax
  10088f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100893:	3c 64                	cmp    $0x64,%al
  100895:	75 b5                	jne    10084c <debuginfo_eip+0x220>
  100897:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10089a:	89 c2                	mov    %eax,%edx
  10089c:	89 d0                	mov    %edx,%eax
  10089e:	01 c0                	add    %eax,%eax
  1008a0:	01 d0                	add    %edx,%eax
  1008a2:	c1 e0 02             	shl    $0x2,%eax
  1008a5:	89 c2                	mov    %eax,%edx
  1008a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008aa:	01 d0                	add    %edx,%eax
  1008ac:	8b 40 08             	mov    0x8(%eax),%eax
  1008af:	85 c0                	test   %eax,%eax
  1008b1:	74 99                	je     10084c <debuginfo_eip+0x220>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1008b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1008b9:	39 c2                	cmp    %eax,%edx
  1008bb:	7c 42                	jl     1008ff <debuginfo_eip+0x2d3>
  1008bd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008c0:	89 c2                	mov    %eax,%edx
  1008c2:	89 d0                	mov    %edx,%eax
  1008c4:	01 c0                	add    %eax,%eax
  1008c6:	01 d0                	add    %edx,%eax
  1008c8:	c1 e0 02             	shl    $0x2,%eax
  1008cb:	89 c2                	mov    %eax,%edx
  1008cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008d0:	01 d0                	add    %edx,%eax
  1008d2:	8b 10                	mov    (%eax),%edx
  1008d4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1008d7:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1008da:	39 c2                	cmp    %eax,%edx
  1008dc:	73 21                	jae    1008ff <debuginfo_eip+0x2d3>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008e1:	89 c2                	mov    %eax,%edx
  1008e3:	89 d0                	mov    %edx,%eax
  1008e5:	01 c0                	add    %eax,%eax
  1008e7:	01 d0                	add    %edx,%eax
  1008e9:	c1 e0 02             	shl    $0x2,%eax
  1008ec:	89 c2                	mov    %eax,%edx
  1008ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008f1:	01 d0                	add    %edx,%eax
  1008f3:	8b 10                	mov    (%eax),%edx
  1008f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008f8:	01 c2                	add    %eax,%edx
  1008fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008fd:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008ff:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100902:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100905:	39 c2                	cmp    %eax,%edx
  100907:	7d 46                	jge    10094f <debuginfo_eip+0x323>
        for (lline = lfun + 1;
  100909:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10090c:	40                   	inc    %eax
  10090d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100910:	eb 16                	jmp    100928 <debuginfo_eip+0x2fc>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100912:	8b 45 0c             	mov    0xc(%ebp),%eax
  100915:	8b 40 14             	mov    0x14(%eax),%eax
  100918:	8d 50 01             	lea    0x1(%eax),%edx
  10091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10091e:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100921:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100924:	40                   	inc    %eax
  100925:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100928:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10092b:	8b 45 d8             	mov    -0x28(%ebp),%eax
        for (lline = lfun + 1;
  10092e:	39 c2                	cmp    %eax,%edx
  100930:	7d 1d                	jge    10094f <debuginfo_eip+0x323>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100932:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100935:	89 c2                	mov    %eax,%edx
  100937:	89 d0                	mov    %edx,%eax
  100939:	01 c0                	add    %eax,%eax
  10093b:	01 d0                	add    %edx,%eax
  10093d:	c1 e0 02             	shl    $0x2,%eax
  100940:	89 c2                	mov    %eax,%edx
  100942:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100945:	01 d0                	add    %edx,%eax
  100947:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10094b:	3c a0                	cmp    $0xa0,%al
  10094d:	74 c3                	je     100912 <debuginfo_eip+0x2e6>
        }
    }
    return 0;
  10094f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100954:	c9                   	leave  
  100955:	c3                   	ret    

00100956 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100956:	f3 0f 1e fb          	endbr32 
  10095a:	55                   	push   %ebp
  10095b:	89 e5                	mov    %esp,%ebp
  10095d:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100960:	c7 04 24 c2 37 10 00 	movl   $0x1037c2,(%esp)
  100967:	e8 27 f9 ff ff       	call   100293 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10096c:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  100973:	00 
  100974:	c7 04 24 db 37 10 00 	movl   $0x1037db,(%esp)
  10097b:	e8 13 f9 ff ff       	call   100293 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100980:	c7 44 24 04 ac 36 10 	movl   $0x1036ac,0x4(%esp)
  100987:	00 
  100988:	c7 04 24 f3 37 10 00 	movl   $0x1037f3,(%esp)
  10098f:	e8 ff f8 ff ff       	call   100293 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100994:	c7 44 24 04 16 fa 10 	movl   $0x10fa16,0x4(%esp)
  10099b:	00 
  10099c:	c7 04 24 0b 38 10 00 	movl   $0x10380b,(%esp)
  1009a3:	e8 eb f8 ff ff       	call   100293 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1009a8:	c7 44 24 04 20 0d 11 	movl   $0x110d20,0x4(%esp)
  1009af:	00 
  1009b0:	c7 04 24 23 38 10 00 	movl   $0x103823,(%esp)
  1009b7:	e8 d7 f8 ff ff       	call   100293 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1009bc:	b8 20 0d 11 00       	mov    $0x110d20,%eax
  1009c1:	2d 00 00 10 00       	sub    $0x100000,%eax
  1009c6:	05 ff 03 00 00       	add    $0x3ff,%eax
  1009cb:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009d1:	85 c0                	test   %eax,%eax
  1009d3:	0f 48 c2             	cmovs  %edx,%eax
  1009d6:	c1 f8 0a             	sar    $0xa,%eax
  1009d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009dd:	c7 04 24 3c 38 10 00 	movl   $0x10383c,(%esp)
  1009e4:	e8 aa f8 ff ff       	call   100293 <cprintf>
}
  1009e9:	90                   	nop
  1009ea:	c9                   	leave  
  1009eb:	c3                   	ret    

001009ec <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009ec:	f3 0f 1e fb          	endbr32 
  1009f0:	55                   	push   %ebp
  1009f1:	89 e5                	mov    %esp,%ebp
  1009f3:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009f9:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a00:	8b 45 08             	mov    0x8(%ebp),%eax
  100a03:	89 04 24             	mov    %eax,(%esp)
  100a06:	e8 21 fc ff ff       	call   10062c <debuginfo_eip>
  100a0b:	85 c0                	test   %eax,%eax
  100a0d:	74 15                	je     100a24 <print_debuginfo+0x38>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  100a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  100a12:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a16:	c7 04 24 66 38 10 00 	movl   $0x103866,(%esp)
  100a1d:	e8 71 f8 ff ff       	call   100293 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a22:	eb 6c                	jmp    100a90 <print_debuginfo+0xa4>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a2b:	eb 1b                	jmp    100a48 <print_debuginfo+0x5c>
            fnname[j] = info.eip_fn_name[j];
  100a2d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a30:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a33:	01 d0                	add    %edx,%eax
  100a35:	0f b6 10             	movzbl (%eax),%edx
  100a38:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a41:	01 c8                	add    %ecx,%eax
  100a43:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a45:	ff 45 f4             	incl   -0xc(%ebp)
  100a48:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a4b:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  100a4e:	7c dd                	jl     100a2d <print_debuginfo+0x41>
        fnname[j] = '\0';
  100a50:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a59:	01 d0                	add    %edx,%eax
  100a5b:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  100a5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a61:	8b 55 08             	mov    0x8(%ebp),%edx
  100a64:	89 d1                	mov    %edx,%ecx
  100a66:	29 c1                	sub    %eax,%ecx
  100a68:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a6b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a6e:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a72:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a78:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a7c:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a80:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a84:	c7 04 24 82 38 10 00 	movl   $0x103882,(%esp)
  100a8b:	e8 03 f8 ff ff       	call   100293 <cprintf>
}
  100a90:	90                   	nop
  100a91:	c9                   	leave  
  100a92:	c3                   	ret    

00100a93 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a93:	f3 0f 1e fb          	endbr32 
  100a97:	55                   	push   %ebp
  100a98:	89 e5                	mov    %esp,%ebp
  100a9a:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a9d:	8b 45 04             	mov    0x4(%ebp),%eax
  100aa0:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100aa3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100aa6:	c9                   	leave  
  100aa7:	c3                   	ret    

00100aa8 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100aa8:	f3 0f 1e fb          	endbr32 
  100aac:	55                   	push   %ebp
  100aad:	89 e5                	mov    %esp,%ebp
  100aaf:	53                   	push   %ebx
  100ab0:	83 ec 44             	sub    $0x44,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100ab3:	89 e8                	mov    %ebp,%eax
  100ab5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  100ab8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    /* LAB1 YOUR CODE : STEP 1 */
    /* (1) call read_ebp() to get the value of ebp. the type is (uint32_t);*/
    uint32_t ebp_val = read_ebp();
  100abb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    /* (2) call read_eip() to get the value of eip. the type is (uint32_t);*/
    uint32_t eip_val = read_eip();
  100abe:	e8 d0 ff ff ff       	call   100a93 <read_eip>
  100ac3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    /* (3) from 0 .. STACKFRAME_DEPTH*/
    for (int i = 0; ebp_val != 0 && i < STACKFRAME_DEPTH; ++i) {
  100ac6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100acd:	e9 8a 00 00 00       	jmp    100b5c <print_stackframe+0xb4>
        /* (3.1) printf value of ebp, eip*/
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp_val, eip_val);
  100ad2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100ad5:	89 44 24 08          	mov    %eax,0x8(%esp)
  100ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100adc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ae0:	c7 04 24 94 38 10 00 	movl   $0x103894,(%esp)
  100ae7:	e8 a7 f7 ff ff       	call   100293 <cprintf>
        /* (3.2) (uint32_t)calling arguments [0..4] = the contents in address (uint32_t)ebp +2 [0..4]*/
        uint32_t *call_args = (uint32_t *)ebp_val + 2;
  100aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aef:	83 c0 08             	add    $0x8,%eax
  100af2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        cprintf("0x%08x 0x%08x 0x%08x 0x%08x", call_args[0], call_args[1], call_args[2], call_args[3]);
  100af5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100af8:	83 c0 0c             	add    $0xc,%eax
  100afb:	8b 18                	mov    (%eax),%ebx
  100afd:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b00:	83 c0 08             	add    $0x8,%eax
  100b03:	8b 08                	mov    (%eax),%ecx
  100b05:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b08:	83 c0 04             	add    $0x4,%eax
  100b0b:	8b 10                	mov    (%eax),%edx
  100b0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b10:	8b 00                	mov    (%eax),%eax
  100b12:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100b16:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100b1a:	89 54 24 08          	mov    %edx,0x8(%esp)
  100b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b22:	c7 04 24 b0 38 10 00 	movl   $0x1038b0,(%esp)
  100b29:	e8 65 f7 ff ff       	call   100293 <cprintf>
        /* (3.3) cprintf("\n");*/
        cprintf("\n");
  100b2e:	c7 04 24 cc 38 10 00 	movl   $0x1038cc,(%esp)
  100b35:	e8 59 f7 ff ff       	call   100293 <cprintf>
        /* (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.*/
        print_debuginfo(eip_val - 1);
  100b3a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b3d:	48                   	dec    %eax
  100b3e:	89 04 24             	mov    %eax,(%esp)
  100b41:	e8 a6 fe ff ff       	call   1009ec <print_debuginfo>
        /* (3.5) popup a calling stackframe*/
        /* NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]*/
        eip_val = *((uint32_t *)(ebp_val + 4));
  100b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b49:	83 c0 04             	add    $0x4,%eax
  100b4c:	8b 00                	mov    (%eax),%eax
  100b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        /* the calling funciton's ebp = ss:[ebp]*/
        ebp_val = *((uint32_t *)ebp_val);
  100b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b54:	8b 00                	mov    (%eax),%eax
  100b56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (int i = 0; ebp_val != 0 && i < STACKFRAME_DEPTH; ++i) {
  100b59:	ff 45 ec             	incl   -0x14(%ebp)
  100b5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b60:	74 0a                	je     100b6c <print_stackframe+0xc4>
  100b62:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b66:	0f 8e 66 ff ff ff    	jle    100ad2 <print_stackframe+0x2a>
    }
}
  100b6c:	90                   	nop
  100b6d:	83 c4 44             	add    $0x44,%esp
  100b70:	5b                   	pop    %ebx
  100b71:	5d                   	pop    %ebp
  100b72:	c3                   	ret    

00100b73 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b73:	f3 0f 1e fb          	endbr32 
  100b77:	55                   	push   %ebp
  100b78:	89 e5                	mov    %esp,%ebp
  100b7a:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b7d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b84:	eb 0c                	jmp    100b92 <parse+0x1f>
            *buf ++ = '\0';
  100b86:	8b 45 08             	mov    0x8(%ebp),%eax
  100b89:	8d 50 01             	lea    0x1(%eax),%edx
  100b8c:	89 55 08             	mov    %edx,0x8(%ebp)
  100b8f:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b92:	8b 45 08             	mov    0x8(%ebp),%eax
  100b95:	0f b6 00             	movzbl (%eax),%eax
  100b98:	84 c0                	test   %al,%al
  100b9a:	74 1d                	je     100bb9 <parse+0x46>
  100b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b9f:	0f b6 00             	movzbl (%eax),%eax
  100ba2:	0f be c0             	movsbl %al,%eax
  100ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ba9:	c7 04 24 50 39 10 00 	movl   $0x103950,(%esp)
  100bb0:	e8 11 21 00 00       	call   102cc6 <strchr>
  100bb5:	85 c0                	test   %eax,%eax
  100bb7:	75 cd                	jne    100b86 <parse+0x13>
        }
        if (*buf == '\0') {
  100bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  100bbc:	0f b6 00             	movzbl (%eax),%eax
  100bbf:	84 c0                	test   %al,%al
  100bc1:	74 65                	je     100c28 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100bc3:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100bc7:	75 14                	jne    100bdd <parse+0x6a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100bc9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100bd0:	00 
  100bd1:	c7 04 24 55 39 10 00 	movl   $0x103955,(%esp)
  100bd8:	e8 b6 f6 ff ff       	call   100293 <cprintf>
        }
        argv[argc ++] = buf;
  100bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100be0:	8d 50 01             	lea    0x1(%eax),%edx
  100be3:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100be6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bed:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bf0:	01 c2                	add    %eax,%edx
  100bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  100bf5:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bf7:	eb 03                	jmp    100bfc <parse+0x89>
            buf ++;
  100bf9:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  100bff:	0f b6 00             	movzbl (%eax),%eax
  100c02:	84 c0                	test   %al,%al
  100c04:	74 8c                	je     100b92 <parse+0x1f>
  100c06:	8b 45 08             	mov    0x8(%ebp),%eax
  100c09:	0f b6 00             	movzbl (%eax),%eax
  100c0c:	0f be c0             	movsbl %al,%eax
  100c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c13:	c7 04 24 50 39 10 00 	movl   $0x103950,(%esp)
  100c1a:	e8 a7 20 00 00       	call   102cc6 <strchr>
  100c1f:	85 c0                	test   %eax,%eax
  100c21:	74 d6                	je     100bf9 <parse+0x86>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100c23:	e9 6a ff ff ff       	jmp    100b92 <parse+0x1f>
            break;
  100c28:	90                   	nop
        }
    }
    return argc;
  100c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100c2c:	c9                   	leave  
  100c2d:	c3                   	ret    

00100c2e <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100c2e:	f3 0f 1e fb          	endbr32 
  100c32:	55                   	push   %ebp
  100c33:	89 e5                	mov    %esp,%ebp
  100c35:	53                   	push   %ebx
  100c36:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c39:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c40:	8b 45 08             	mov    0x8(%ebp),%eax
  100c43:	89 04 24             	mov    %eax,(%esp)
  100c46:	e8 28 ff ff ff       	call   100b73 <parse>
  100c4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c52:	75 0a                	jne    100c5e <runcmd+0x30>
        return 0;
  100c54:	b8 00 00 00 00       	mov    $0x0,%eax
  100c59:	e9 83 00 00 00       	jmp    100ce1 <runcmd+0xb3>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c65:	eb 5a                	jmp    100cc1 <runcmd+0x93>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c67:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c6d:	89 d0                	mov    %edx,%eax
  100c6f:	01 c0                	add    %eax,%eax
  100c71:	01 d0                	add    %edx,%eax
  100c73:	c1 e0 02             	shl    $0x2,%eax
  100c76:	05 00 f0 10 00       	add    $0x10f000,%eax
  100c7b:	8b 00                	mov    (%eax),%eax
  100c7d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c81:	89 04 24             	mov    %eax,(%esp)
  100c84:	e8 99 1f 00 00       	call   102c22 <strcmp>
  100c89:	85 c0                	test   %eax,%eax
  100c8b:	75 31                	jne    100cbe <runcmd+0x90>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c8d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c90:	89 d0                	mov    %edx,%eax
  100c92:	01 c0                	add    %eax,%eax
  100c94:	01 d0                	add    %edx,%eax
  100c96:	c1 e0 02             	shl    $0x2,%eax
  100c99:	05 08 f0 10 00       	add    $0x10f008,%eax
  100c9e:	8b 10                	mov    (%eax),%edx
  100ca0:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100ca3:	83 c0 04             	add    $0x4,%eax
  100ca6:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100ca9:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100cac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100caf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cb7:	89 1c 24             	mov    %ebx,(%esp)
  100cba:	ff d2                	call   *%edx
  100cbc:	eb 23                	jmp    100ce1 <runcmd+0xb3>
    for (i = 0; i < NCOMMANDS; i ++) {
  100cbe:	ff 45 f4             	incl   -0xc(%ebp)
  100cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cc4:	83 f8 02             	cmp    $0x2,%eax
  100cc7:	76 9e                	jbe    100c67 <runcmd+0x39>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100cc9:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100ccc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cd0:	c7 04 24 73 39 10 00 	movl   $0x103973,(%esp)
  100cd7:	e8 b7 f5 ff ff       	call   100293 <cprintf>
    return 0;
  100cdc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ce1:	83 c4 64             	add    $0x64,%esp
  100ce4:	5b                   	pop    %ebx
  100ce5:	5d                   	pop    %ebp
  100ce6:	c3                   	ret    

00100ce7 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100ce7:	f3 0f 1e fb          	endbr32 
  100ceb:	55                   	push   %ebp
  100cec:	89 e5                	mov    %esp,%ebp
  100cee:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cf1:	c7 04 24 8c 39 10 00 	movl   $0x10398c,(%esp)
  100cf8:	e8 96 f5 ff ff       	call   100293 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cfd:	c7 04 24 b4 39 10 00 	movl   $0x1039b4,(%esp)
  100d04:	e8 8a f5 ff ff       	call   100293 <cprintf>

    if (tf != NULL) {
  100d09:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100d0d:	74 0b                	je     100d1a <kmonitor+0x33>
        print_trapframe(tf);
  100d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  100d12:	89 04 24             	mov    %eax,(%esp)
  100d15:	e8 00 0e 00 00       	call   101b1a <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100d1a:	c7 04 24 d9 39 10 00 	movl   $0x1039d9,(%esp)
  100d21:	e8 20 f6 ff ff       	call   100346 <readline>
  100d26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100d29:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100d2d:	74 eb                	je     100d1a <kmonitor+0x33>
            if (runcmd(buf, tf) < 0) {
  100d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  100d32:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d39:	89 04 24             	mov    %eax,(%esp)
  100d3c:	e8 ed fe ff ff       	call   100c2e <runcmd>
  100d41:	85 c0                	test   %eax,%eax
  100d43:	78 02                	js     100d47 <kmonitor+0x60>
        if ((buf = readline("K> ")) != NULL) {
  100d45:	eb d3                	jmp    100d1a <kmonitor+0x33>
                break;
  100d47:	90                   	nop
            }
        }
    }
}
  100d48:	90                   	nop
  100d49:	c9                   	leave  
  100d4a:	c3                   	ret    

00100d4b <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d4b:	f3 0f 1e fb          	endbr32 
  100d4f:	55                   	push   %ebp
  100d50:	89 e5                	mov    %esp,%ebp
  100d52:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d55:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d5c:	eb 3d                	jmp    100d9b <mon_help+0x50>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d61:	89 d0                	mov    %edx,%eax
  100d63:	01 c0                	add    %eax,%eax
  100d65:	01 d0                	add    %edx,%eax
  100d67:	c1 e0 02             	shl    $0x2,%eax
  100d6a:	05 04 f0 10 00       	add    $0x10f004,%eax
  100d6f:	8b 08                	mov    (%eax),%ecx
  100d71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d74:	89 d0                	mov    %edx,%eax
  100d76:	01 c0                	add    %eax,%eax
  100d78:	01 d0                	add    %edx,%eax
  100d7a:	c1 e0 02             	shl    $0x2,%eax
  100d7d:	05 00 f0 10 00       	add    $0x10f000,%eax
  100d82:	8b 00                	mov    (%eax),%eax
  100d84:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d88:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d8c:	c7 04 24 dd 39 10 00 	movl   $0x1039dd,(%esp)
  100d93:	e8 fb f4 ff ff       	call   100293 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100d98:	ff 45 f4             	incl   -0xc(%ebp)
  100d9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d9e:	83 f8 02             	cmp    $0x2,%eax
  100da1:	76 bb                	jbe    100d5e <mon_help+0x13>
    }
    return 0;
  100da3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100da8:	c9                   	leave  
  100da9:	c3                   	ret    

00100daa <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100daa:	f3 0f 1e fb          	endbr32 
  100dae:	55                   	push   %ebp
  100daf:	89 e5                	mov    %esp,%ebp
  100db1:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100db4:	e8 9d fb ff ff       	call   100956 <print_kerninfo>
    return 0;
  100db9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100dbe:	c9                   	leave  
  100dbf:	c3                   	ret    

00100dc0 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100dc0:	f3 0f 1e fb          	endbr32 
  100dc4:	55                   	push   %ebp
  100dc5:	89 e5                	mov    %esp,%ebp
  100dc7:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100dca:	e8 d9 fc ff ff       	call   100aa8 <print_stackframe>
    return 0;
  100dcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100dd4:	c9                   	leave  
  100dd5:	c3                   	ret    

00100dd6 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100dd6:	f3 0f 1e fb          	endbr32 
  100dda:	55                   	push   %ebp
  100ddb:	89 e5                	mov    %esp,%ebp
  100ddd:	83 ec 28             	sub    $0x28,%esp
  100de0:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100de6:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100dea:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dee:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100df2:	ee                   	out    %al,(%dx)
}
  100df3:	90                   	nop
  100df4:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dfa:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100dfe:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100e02:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100e06:	ee                   	out    %al,(%dx)
}
  100e07:	90                   	nop
  100e08:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100e0e:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e12:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100e16:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100e1a:	ee                   	out    %al,(%dx)
}
  100e1b:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100e1c:	c7 05 08 09 11 00 00 	movl   $0x0,0x110908
  100e23:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100e26:	c7 04 24 e6 39 10 00 	movl   $0x1039e6,(%esp)
  100e2d:	e8 61 f4 ff ff       	call   100293 <cprintf>
    pic_enable(IRQ_TIMER);
  100e32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e39:	e8 31 09 00 00       	call   10176f <pic_enable>
}
  100e3e:	90                   	nop
  100e3f:	c9                   	leave  
  100e40:	c3                   	ret    

00100e41 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e41:	f3 0f 1e fb          	endbr32 
  100e45:	55                   	push   %ebp
  100e46:	89 e5                	mov    %esp,%ebp
  100e48:	83 ec 10             	sub    $0x10,%esp
  100e4b:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100e51:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e55:	89 c2                	mov    %eax,%edx
  100e57:	ec                   	in     (%dx),%al
  100e58:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e5b:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e61:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e65:	89 c2                	mov    %eax,%edx
  100e67:	ec                   	in     (%dx),%al
  100e68:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e6b:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e71:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e75:	89 c2                	mov    %eax,%edx
  100e77:	ec                   	in     (%dx),%al
  100e78:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e7b:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e81:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e85:	89 c2                	mov    %eax,%edx
  100e87:	ec                   	in     (%dx),%al
  100e88:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e8b:	90                   	nop
  100e8c:	c9                   	leave  
  100e8d:	c3                   	ret    

00100e8e <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e8e:	f3 0f 1e fb          	endbr32 
  100e92:	55                   	push   %ebp
  100e93:	89 e5                	mov    %esp,%ebp
  100e95:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e98:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea2:	0f b7 00             	movzwl (%eax),%eax
  100ea5:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100ea9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eac:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100eb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb4:	0f b7 00             	movzwl (%eax),%eax
  100eb7:	0f b7 c0             	movzwl %ax,%eax
  100eba:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ebf:	74 12                	je     100ed3 <cga_init+0x45>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100ec1:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100ec8:	66 c7 05 66 fe 10 00 	movw   $0x3b4,0x10fe66
  100ecf:	b4 03 
  100ed1:	eb 13                	jmp    100ee6 <cga_init+0x58>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100ed3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ed6:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100eda:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100edd:	66 c7 05 66 fe 10 00 	movw   $0x3d4,0x10fe66
  100ee4:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100ee6:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100eed:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100ef1:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ef5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100ef9:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100efd:	ee                   	out    %al,(%dx)
}
  100efe:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100eff:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100f06:	40                   	inc    %eax
  100f07:	0f b7 c0             	movzwl %ax,%eax
  100f0a:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f0e:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f12:	89 c2                	mov    %eax,%edx
  100f14:	ec                   	in     (%dx),%al
  100f15:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f18:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f1c:	0f b6 c0             	movzbl %al,%eax
  100f1f:	c1 e0 08             	shl    $0x8,%eax
  100f22:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f25:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100f2c:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f30:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f34:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f38:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f3c:	ee                   	out    %al,(%dx)
}
  100f3d:	90                   	nop
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100f3e:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100f45:	40                   	inc    %eax
  100f46:	0f b7 c0             	movzwl %ax,%eax
  100f49:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f4d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f51:	89 c2                	mov    %eax,%edx
  100f53:	ec                   	in     (%dx),%al
  100f54:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f57:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f5b:	0f b6 c0             	movzbl %al,%eax
  100f5e:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100f61:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f64:	a3 60 fe 10 00       	mov    %eax,0x10fe60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f6c:	0f b7 c0             	movzwl %ax,%eax
  100f6f:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
}
  100f75:	90                   	nop
  100f76:	c9                   	leave  
  100f77:	c3                   	ret    

00100f78 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f78:	f3 0f 1e fb          	endbr32 
  100f7c:	55                   	push   %ebp
  100f7d:	89 e5                	mov    %esp,%ebp
  100f7f:	83 ec 48             	sub    $0x48,%esp
  100f82:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100f88:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f8c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100f90:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100f94:	ee                   	out    %al,(%dx)
}
  100f95:	90                   	nop
  100f96:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100f9c:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fa0:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100fa4:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100fa8:	ee                   	out    %al,(%dx)
}
  100fa9:	90                   	nop
  100faa:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100fb0:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fb4:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100fb8:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100fbc:	ee                   	out    %al,(%dx)
}
  100fbd:	90                   	nop
  100fbe:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fc4:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fc8:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fcc:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fd0:	ee                   	out    %al,(%dx)
}
  100fd1:	90                   	nop
  100fd2:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100fd8:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100fdc:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100fe0:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100fe4:	ee                   	out    %al,(%dx)
}
  100fe5:	90                   	nop
  100fe6:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  100fec:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ff0:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100ff4:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100ff8:	ee                   	out    %al,(%dx)
}
  100ff9:	90                   	nop
  100ffa:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  101000:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101004:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101008:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10100c:	ee                   	out    %al,(%dx)
}
  10100d:	90                   	nop
  10100e:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101014:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  101018:	89 c2                	mov    %eax,%edx
  10101a:	ec                   	in     (%dx),%al
  10101b:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  10101e:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101022:	3c ff                	cmp    $0xff,%al
  101024:	0f 95 c0             	setne  %al
  101027:	0f b6 c0             	movzbl %al,%eax
  10102a:	a3 68 fe 10 00       	mov    %eax,0x10fe68
  10102f:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101035:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  101039:	89 c2                	mov    %eax,%edx
  10103b:	ec                   	in     (%dx),%al
  10103c:	88 45 f1             	mov    %al,-0xf(%ebp)
  10103f:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101045:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101049:	89 c2                	mov    %eax,%edx
  10104b:	ec                   	in     (%dx),%al
  10104c:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  10104f:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  101054:	85 c0                	test   %eax,%eax
  101056:	74 0c                	je     101064 <serial_init+0xec>
        pic_enable(IRQ_COM1);
  101058:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10105f:	e8 0b 07 00 00       	call   10176f <pic_enable>
    }
}
  101064:	90                   	nop
  101065:	c9                   	leave  
  101066:	c3                   	ret    

00101067 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101067:	f3 0f 1e fb          	endbr32 
  10106b:	55                   	push   %ebp
  10106c:	89 e5                	mov    %esp,%ebp
  10106e:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101071:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101078:	eb 08                	jmp    101082 <lpt_putc_sub+0x1b>
        delay();
  10107a:	e8 c2 fd ff ff       	call   100e41 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10107f:	ff 45 fc             	incl   -0x4(%ebp)
  101082:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  101088:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10108c:	89 c2                	mov    %eax,%edx
  10108e:	ec                   	in     (%dx),%al
  10108f:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101092:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101096:	84 c0                	test   %al,%al
  101098:	78 09                	js     1010a3 <lpt_putc_sub+0x3c>
  10109a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1010a1:	7e d7                	jle    10107a <lpt_putc_sub+0x13>
    }
    outb(LPTPORT + 0, c);
  1010a3:	8b 45 08             	mov    0x8(%ebp),%eax
  1010a6:	0f b6 c0             	movzbl %al,%eax
  1010a9:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  1010af:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1010b2:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010b6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010ba:	ee                   	out    %al,(%dx)
}
  1010bb:	90                   	nop
  1010bc:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010c2:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1010c6:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010ca:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010ce:	ee                   	out    %al,(%dx)
}
  1010cf:	90                   	nop
  1010d0:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010d6:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1010da:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010de:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010e2:	ee                   	out    %al,(%dx)
}
  1010e3:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010e4:	90                   	nop
  1010e5:	c9                   	leave  
  1010e6:	c3                   	ret    

001010e7 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010e7:	f3 0f 1e fb          	endbr32 
  1010eb:	55                   	push   %ebp
  1010ec:	89 e5                	mov    %esp,%ebp
  1010ee:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010f1:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010f5:	74 0d                	je     101104 <lpt_putc+0x1d>
        lpt_putc_sub(c);
  1010f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1010fa:	89 04 24             	mov    %eax,(%esp)
  1010fd:	e8 65 ff ff ff       	call   101067 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  101102:	eb 24                	jmp    101128 <lpt_putc+0x41>
        lpt_putc_sub('\b');
  101104:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10110b:	e8 57 ff ff ff       	call   101067 <lpt_putc_sub>
        lpt_putc_sub(' ');
  101110:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101117:	e8 4b ff ff ff       	call   101067 <lpt_putc_sub>
        lpt_putc_sub('\b');
  10111c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101123:	e8 3f ff ff ff       	call   101067 <lpt_putc_sub>
}
  101128:	90                   	nop
  101129:	c9                   	leave  
  10112a:	c3                   	ret    

0010112b <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  10112b:	f3 0f 1e fb          	endbr32 
  10112f:	55                   	push   %ebp
  101130:	89 e5                	mov    %esp,%ebp
  101132:	53                   	push   %ebx
  101133:	83 ec 34             	sub    $0x34,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101136:	8b 45 08             	mov    0x8(%ebp),%eax
  101139:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10113e:	85 c0                	test   %eax,%eax
  101140:	75 07                	jne    101149 <cga_putc+0x1e>
        c |= 0x0700;
  101142:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  101149:	8b 45 08             	mov    0x8(%ebp),%eax
  10114c:	0f b6 c0             	movzbl %al,%eax
  10114f:	83 f8 0d             	cmp    $0xd,%eax
  101152:	74 72                	je     1011c6 <cga_putc+0x9b>
  101154:	83 f8 0d             	cmp    $0xd,%eax
  101157:	0f 8f a3 00 00 00    	jg     101200 <cga_putc+0xd5>
  10115d:	83 f8 08             	cmp    $0x8,%eax
  101160:	74 0a                	je     10116c <cga_putc+0x41>
  101162:	83 f8 0a             	cmp    $0xa,%eax
  101165:	74 4c                	je     1011b3 <cga_putc+0x88>
  101167:	e9 94 00 00 00       	jmp    101200 <cga_putc+0xd5>
    case '\b':
        if (crt_pos > 0) {
  10116c:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101173:	85 c0                	test   %eax,%eax
  101175:	0f 84 af 00 00 00    	je     10122a <cga_putc+0xff>
            crt_pos --;
  10117b:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101182:	48                   	dec    %eax
  101183:	0f b7 c0             	movzwl %ax,%eax
  101186:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  10118c:	8b 45 08             	mov    0x8(%ebp),%eax
  10118f:	98                   	cwtl   
  101190:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101195:	98                   	cwtl   
  101196:	83 c8 20             	or     $0x20,%eax
  101199:	98                   	cwtl   
  10119a:	8b 15 60 fe 10 00    	mov    0x10fe60,%edx
  1011a0:	0f b7 0d 64 fe 10 00 	movzwl 0x10fe64,%ecx
  1011a7:	01 c9                	add    %ecx,%ecx
  1011a9:	01 ca                	add    %ecx,%edx
  1011ab:	0f b7 c0             	movzwl %ax,%eax
  1011ae:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1011b1:	eb 77                	jmp    10122a <cga_putc+0xff>
    case '\n':
        crt_pos += CRT_COLS;
  1011b3:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1011ba:	83 c0 50             	add    $0x50,%eax
  1011bd:	0f b7 c0             	movzwl %ax,%eax
  1011c0:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011c6:	0f b7 1d 64 fe 10 00 	movzwl 0x10fe64,%ebx
  1011cd:	0f b7 0d 64 fe 10 00 	movzwl 0x10fe64,%ecx
  1011d4:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  1011d9:	89 c8                	mov    %ecx,%eax
  1011db:	f7 e2                	mul    %edx
  1011dd:	c1 ea 06             	shr    $0x6,%edx
  1011e0:	89 d0                	mov    %edx,%eax
  1011e2:	c1 e0 02             	shl    $0x2,%eax
  1011e5:	01 d0                	add    %edx,%eax
  1011e7:	c1 e0 04             	shl    $0x4,%eax
  1011ea:	29 c1                	sub    %eax,%ecx
  1011ec:	89 c8                	mov    %ecx,%eax
  1011ee:	0f b7 c0             	movzwl %ax,%eax
  1011f1:	29 c3                	sub    %eax,%ebx
  1011f3:	89 d8                	mov    %ebx,%eax
  1011f5:	0f b7 c0             	movzwl %ax,%eax
  1011f8:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
        break;
  1011fe:	eb 2b                	jmp    10122b <cga_putc+0x100>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101200:	8b 0d 60 fe 10 00    	mov    0x10fe60,%ecx
  101206:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  10120d:	8d 50 01             	lea    0x1(%eax),%edx
  101210:	0f b7 d2             	movzwl %dx,%edx
  101213:	66 89 15 64 fe 10 00 	mov    %dx,0x10fe64
  10121a:	01 c0                	add    %eax,%eax
  10121c:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  10121f:	8b 45 08             	mov    0x8(%ebp),%eax
  101222:	0f b7 c0             	movzwl %ax,%eax
  101225:	66 89 02             	mov    %ax,(%edx)
        break;
  101228:	eb 01                	jmp    10122b <cga_putc+0x100>
        break;
  10122a:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  10122b:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101232:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  101237:	76 5d                	jbe    101296 <cga_putc+0x16b>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  101239:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  10123e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  101244:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  101249:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101250:	00 
  101251:	89 54 24 04          	mov    %edx,0x4(%esp)
  101255:	89 04 24             	mov    %eax,(%esp)
  101258:	e8 6e 1c 00 00       	call   102ecb <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10125d:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  101264:	eb 14                	jmp    10127a <cga_putc+0x14f>
            crt_buf[i] = 0x0700 | ' ';
  101266:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  10126b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10126e:	01 d2                	add    %edx,%edx
  101270:	01 d0                	add    %edx,%eax
  101272:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101277:	ff 45 f4             	incl   -0xc(%ebp)
  10127a:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101281:	7e e3                	jle    101266 <cga_putc+0x13b>
        }
        crt_pos -= CRT_COLS;
  101283:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  10128a:	83 e8 50             	sub    $0x50,%eax
  10128d:	0f b7 c0             	movzwl %ax,%eax
  101290:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  101296:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  10129d:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  1012a1:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012a5:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012a9:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012ad:	ee                   	out    %al,(%dx)
}
  1012ae:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  1012af:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1012b6:	c1 e8 08             	shr    $0x8,%eax
  1012b9:	0f b7 c0             	movzwl %ax,%eax
  1012bc:	0f b6 c0             	movzbl %al,%eax
  1012bf:	0f b7 15 66 fe 10 00 	movzwl 0x10fe66,%edx
  1012c6:	42                   	inc    %edx
  1012c7:	0f b7 d2             	movzwl %dx,%edx
  1012ca:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  1012ce:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012d1:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012d5:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012d9:	ee                   	out    %al,(%dx)
}
  1012da:	90                   	nop
    outb(addr_6845, 15);
  1012db:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  1012e2:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012e6:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012ea:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1012ee:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012f2:	ee                   	out    %al,(%dx)
}
  1012f3:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  1012f4:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1012fb:	0f b6 c0             	movzbl %al,%eax
  1012fe:	0f b7 15 66 fe 10 00 	movzwl 0x10fe66,%edx
  101305:	42                   	inc    %edx
  101306:	0f b7 d2             	movzwl %dx,%edx
  101309:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  10130d:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101310:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101314:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101318:	ee                   	out    %al,(%dx)
}
  101319:	90                   	nop
}
  10131a:	90                   	nop
  10131b:	83 c4 34             	add    $0x34,%esp
  10131e:	5b                   	pop    %ebx
  10131f:	5d                   	pop    %ebp
  101320:	c3                   	ret    

00101321 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101321:	f3 0f 1e fb          	endbr32 
  101325:	55                   	push   %ebp
  101326:	89 e5                	mov    %esp,%ebp
  101328:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10132b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101332:	eb 08                	jmp    10133c <serial_putc_sub+0x1b>
        delay();
  101334:	e8 08 fb ff ff       	call   100e41 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101339:	ff 45 fc             	incl   -0x4(%ebp)
  10133c:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101342:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101346:	89 c2                	mov    %eax,%edx
  101348:	ec                   	in     (%dx),%al
  101349:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10134c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101350:	0f b6 c0             	movzbl %al,%eax
  101353:	83 e0 20             	and    $0x20,%eax
  101356:	85 c0                	test   %eax,%eax
  101358:	75 09                	jne    101363 <serial_putc_sub+0x42>
  10135a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101361:	7e d1                	jle    101334 <serial_putc_sub+0x13>
    }
    outb(COM1 + COM_TX, c);
  101363:	8b 45 08             	mov    0x8(%ebp),%eax
  101366:	0f b6 c0             	movzbl %al,%eax
  101369:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10136f:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101372:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  101376:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10137a:	ee                   	out    %al,(%dx)
}
  10137b:	90                   	nop
}
  10137c:	90                   	nop
  10137d:	c9                   	leave  
  10137e:	c3                   	ret    

0010137f <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10137f:	f3 0f 1e fb          	endbr32 
  101383:	55                   	push   %ebp
  101384:	89 e5                	mov    %esp,%ebp
  101386:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101389:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10138d:	74 0d                	je     10139c <serial_putc+0x1d>
        serial_putc_sub(c);
  10138f:	8b 45 08             	mov    0x8(%ebp),%eax
  101392:	89 04 24             	mov    %eax,(%esp)
  101395:	e8 87 ff ff ff       	call   101321 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  10139a:	eb 24                	jmp    1013c0 <serial_putc+0x41>
        serial_putc_sub('\b');
  10139c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013a3:	e8 79 ff ff ff       	call   101321 <serial_putc_sub>
        serial_putc_sub(' ');
  1013a8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1013af:	e8 6d ff ff ff       	call   101321 <serial_putc_sub>
        serial_putc_sub('\b');
  1013b4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013bb:	e8 61 ff ff ff       	call   101321 <serial_putc_sub>
}
  1013c0:	90                   	nop
  1013c1:	c9                   	leave  
  1013c2:	c3                   	ret    

001013c3 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1013c3:	f3 0f 1e fb          	endbr32 
  1013c7:	55                   	push   %ebp
  1013c8:	89 e5                	mov    %esp,%ebp
  1013ca:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1013cd:	eb 33                	jmp    101402 <cons_intr+0x3f>
        if (c != 0) {
  1013cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1013d3:	74 2d                	je     101402 <cons_intr+0x3f>
            cons.buf[cons.wpos ++] = c;
  1013d5:	a1 84 00 11 00       	mov    0x110084,%eax
  1013da:	8d 50 01             	lea    0x1(%eax),%edx
  1013dd:	89 15 84 00 11 00    	mov    %edx,0x110084
  1013e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013e6:	88 90 80 fe 10 00    	mov    %dl,0x10fe80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013ec:	a1 84 00 11 00       	mov    0x110084,%eax
  1013f1:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013f6:	75 0a                	jne    101402 <cons_intr+0x3f>
                cons.wpos = 0;
  1013f8:	c7 05 84 00 11 00 00 	movl   $0x0,0x110084
  1013ff:	00 00 00 
    while ((c = (*proc)()) != -1) {
  101402:	8b 45 08             	mov    0x8(%ebp),%eax
  101405:	ff d0                	call   *%eax
  101407:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10140a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  10140e:	75 bf                	jne    1013cf <cons_intr+0xc>
            }
        }
    }
}
  101410:	90                   	nop
  101411:	90                   	nop
  101412:	c9                   	leave  
  101413:	c3                   	ret    

00101414 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101414:	f3 0f 1e fb          	endbr32 
  101418:	55                   	push   %ebp
  101419:	89 e5                	mov    %esp,%ebp
  10141b:	83 ec 10             	sub    $0x10,%esp
  10141e:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101424:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101428:	89 c2                	mov    %eax,%edx
  10142a:	ec                   	in     (%dx),%al
  10142b:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10142e:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101432:	0f b6 c0             	movzbl %al,%eax
  101435:	83 e0 01             	and    $0x1,%eax
  101438:	85 c0                	test   %eax,%eax
  10143a:	75 07                	jne    101443 <serial_proc_data+0x2f>
        return -1;
  10143c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101441:	eb 2a                	jmp    10146d <serial_proc_data+0x59>
  101443:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101449:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10144d:	89 c2                	mov    %eax,%edx
  10144f:	ec                   	in     (%dx),%al
  101450:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101453:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101457:	0f b6 c0             	movzbl %al,%eax
  10145a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10145d:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101461:	75 07                	jne    10146a <serial_proc_data+0x56>
        c = '\b';
  101463:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  10146a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10146d:	c9                   	leave  
  10146e:	c3                   	ret    

0010146f <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10146f:	f3 0f 1e fb          	endbr32 
  101473:	55                   	push   %ebp
  101474:	89 e5                	mov    %esp,%ebp
  101476:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101479:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  10147e:	85 c0                	test   %eax,%eax
  101480:	74 0c                	je     10148e <serial_intr+0x1f>
        cons_intr(serial_proc_data);
  101482:	c7 04 24 14 14 10 00 	movl   $0x101414,(%esp)
  101489:	e8 35 ff ff ff       	call   1013c3 <cons_intr>
    }
}
  10148e:	90                   	nop
  10148f:	c9                   	leave  
  101490:	c3                   	ret    

00101491 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101491:	f3 0f 1e fb          	endbr32 
  101495:	55                   	push   %ebp
  101496:	89 e5                	mov    %esp,%ebp
  101498:	83 ec 38             	sub    $0x38,%esp
  10149b:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1014a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1014a4:	89 c2                	mov    %eax,%edx
  1014a6:	ec                   	in     (%dx),%al
  1014a7:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1014aa:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1014ae:	0f b6 c0             	movzbl %al,%eax
  1014b1:	83 e0 01             	and    $0x1,%eax
  1014b4:	85 c0                	test   %eax,%eax
  1014b6:	75 0a                	jne    1014c2 <kbd_proc_data+0x31>
        return -1;
  1014b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1014bd:	e9 56 01 00 00       	jmp    101618 <kbd_proc_data+0x187>
  1014c2:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1014c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1014cb:	89 c2                	mov    %eax,%edx
  1014cd:	ec                   	in     (%dx),%al
  1014ce:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1014d1:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1014d5:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1014d8:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1014dc:	75 17                	jne    1014f5 <kbd_proc_data+0x64>
        // E0 escape character
        shift |= E0ESC;
  1014de:	a1 88 00 11 00       	mov    0x110088,%eax
  1014e3:	83 c8 40             	or     $0x40,%eax
  1014e6:	a3 88 00 11 00       	mov    %eax,0x110088
        return 0;
  1014eb:	b8 00 00 00 00       	mov    $0x0,%eax
  1014f0:	e9 23 01 00 00       	jmp    101618 <kbd_proc_data+0x187>
    } else if (data & 0x80) {
  1014f5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014f9:	84 c0                	test   %al,%al
  1014fb:	79 45                	jns    101542 <kbd_proc_data+0xb1>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014fd:	a1 88 00 11 00       	mov    0x110088,%eax
  101502:	83 e0 40             	and    $0x40,%eax
  101505:	85 c0                	test   %eax,%eax
  101507:	75 08                	jne    101511 <kbd_proc_data+0x80>
  101509:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10150d:	24 7f                	and    $0x7f,%al
  10150f:	eb 04                	jmp    101515 <kbd_proc_data+0x84>
  101511:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101515:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101518:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151c:	0f b6 80 40 f0 10 00 	movzbl 0x10f040(%eax),%eax
  101523:	0c 40                	or     $0x40,%al
  101525:	0f b6 c0             	movzbl %al,%eax
  101528:	f7 d0                	not    %eax
  10152a:	89 c2                	mov    %eax,%edx
  10152c:	a1 88 00 11 00       	mov    0x110088,%eax
  101531:	21 d0                	and    %edx,%eax
  101533:	a3 88 00 11 00       	mov    %eax,0x110088
        return 0;
  101538:	b8 00 00 00 00       	mov    $0x0,%eax
  10153d:	e9 d6 00 00 00       	jmp    101618 <kbd_proc_data+0x187>
    } else if (shift & E0ESC) {
  101542:	a1 88 00 11 00       	mov    0x110088,%eax
  101547:	83 e0 40             	and    $0x40,%eax
  10154a:	85 c0                	test   %eax,%eax
  10154c:	74 11                	je     10155f <kbd_proc_data+0xce>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  10154e:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101552:	a1 88 00 11 00       	mov    0x110088,%eax
  101557:	83 e0 bf             	and    $0xffffffbf,%eax
  10155a:	a3 88 00 11 00       	mov    %eax,0x110088
    }

    shift |= shiftcode[data];
  10155f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101563:	0f b6 80 40 f0 10 00 	movzbl 0x10f040(%eax),%eax
  10156a:	0f b6 d0             	movzbl %al,%edx
  10156d:	a1 88 00 11 00       	mov    0x110088,%eax
  101572:	09 d0                	or     %edx,%eax
  101574:	a3 88 00 11 00       	mov    %eax,0x110088
    shift ^= togglecode[data];
  101579:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10157d:	0f b6 80 40 f1 10 00 	movzbl 0x10f140(%eax),%eax
  101584:	0f b6 d0             	movzbl %al,%edx
  101587:	a1 88 00 11 00       	mov    0x110088,%eax
  10158c:	31 d0                	xor    %edx,%eax
  10158e:	a3 88 00 11 00       	mov    %eax,0x110088

    c = charcode[shift & (CTL | SHIFT)][data];
  101593:	a1 88 00 11 00       	mov    0x110088,%eax
  101598:	83 e0 03             	and    $0x3,%eax
  10159b:	8b 14 85 40 f5 10 00 	mov    0x10f540(,%eax,4),%edx
  1015a2:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015a6:	01 d0                	add    %edx,%eax
  1015a8:	0f b6 00             	movzbl (%eax),%eax
  1015ab:	0f b6 c0             	movzbl %al,%eax
  1015ae:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1015b1:	a1 88 00 11 00       	mov    0x110088,%eax
  1015b6:	83 e0 08             	and    $0x8,%eax
  1015b9:	85 c0                	test   %eax,%eax
  1015bb:	74 22                	je     1015df <kbd_proc_data+0x14e>
        if ('a' <= c && c <= 'z')
  1015bd:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1015c1:	7e 0c                	jle    1015cf <kbd_proc_data+0x13e>
  1015c3:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1015c7:	7f 06                	jg     1015cf <kbd_proc_data+0x13e>
            c += 'A' - 'a';
  1015c9:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1015cd:	eb 10                	jmp    1015df <kbd_proc_data+0x14e>
        else if ('A' <= c && c <= 'Z')
  1015cf:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1015d3:	7e 0a                	jle    1015df <kbd_proc_data+0x14e>
  1015d5:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1015d9:	7f 04                	jg     1015df <kbd_proc_data+0x14e>
            c += 'a' - 'A';
  1015db:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1015df:	a1 88 00 11 00       	mov    0x110088,%eax
  1015e4:	f7 d0                	not    %eax
  1015e6:	83 e0 06             	and    $0x6,%eax
  1015e9:	85 c0                	test   %eax,%eax
  1015eb:	75 28                	jne    101615 <kbd_proc_data+0x184>
  1015ed:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015f4:	75 1f                	jne    101615 <kbd_proc_data+0x184>
        cprintf("Rebooting!\n");
  1015f6:	c7 04 24 01 3a 10 00 	movl   $0x103a01,(%esp)
  1015fd:	e8 91 ec ff ff       	call   100293 <cprintf>
  101602:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101608:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10160c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  101610:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101613:	ee                   	out    %al,(%dx)
}
  101614:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  101615:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101618:	c9                   	leave  
  101619:	c3                   	ret    

0010161a <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10161a:	f3 0f 1e fb          	endbr32 
  10161e:	55                   	push   %ebp
  10161f:	89 e5                	mov    %esp,%ebp
  101621:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101624:	c7 04 24 91 14 10 00 	movl   $0x101491,(%esp)
  10162b:	e8 93 fd ff ff       	call   1013c3 <cons_intr>
}
  101630:	90                   	nop
  101631:	c9                   	leave  
  101632:	c3                   	ret    

00101633 <kbd_init>:

static void
kbd_init(void) {
  101633:	f3 0f 1e fb          	endbr32 
  101637:	55                   	push   %ebp
  101638:	89 e5                	mov    %esp,%ebp
  10163a:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  10163d:	e8 d8 ff ff ff       	call   10161a <kbd_intr>
    pic_enable(IRQ_KBD);
  101642:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101649:	e8 21 01 00 00       	call   10176f <pic_enable>
}
  10164e:	90                   	nop
  10164f:	c9                   	leave  
  101650:	c3                   	ret    

00101651 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101651:	f3 0f 1e fb          	endbr32 
  101655:	55                   	push   %ebp
  101656:	89 e5                	mov    %esp,%ebp
  101658:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  10165b:	e8 2e f8 ff ff       	call   100e8e <cga_init>
    serial_init();
  101660:	e8 13 f9 ff ff       	call   100f78 <serial_init>
    kbd_init();
  101665:	e8 c9 ff ff ff       	call   101633 <kbd_init>
    if (!serial_exists) {
  10166a:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  10166f:	85 c0                	test   %eax,%eax
  101671:	75 0c                	jne    10167f <cons_init+0x2e>
        cprintf("serial port does not exist!!\n");
  101673:	c7 04 24 0d 3a 10 00 	movl   $0x103a0d,(%esp)
  10167a:	e8 14 ec ff ff       	call   100293 <cprintf>
    }
}
  10167f:	90                   	nop
  101680:	c9                   	leave  
  101681:	c3                   	ret    

00101682 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101682:	f3 0f 1e fb          	endbr32 
  101686:	55                   	push   %ebp
  101687:	89 e5                	mov    %esp,%ebp
  101689:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  10168c:	8b 45 08             	mov    0x8(%ebp),%eax
  10168f:	89 04 24             	mov    %eax,(%esp)
  101692:	e8 50 fa ff ff       	call   1010e7 <lpt_putc>
    cga_putc(c);
  101697:	8b 45 08             	mov    0x8(%ebp),%eax
  10169a:	89 04 24             	mov    %eax,(%esp)
  10169d:	e8 89 fa ff ff       	call   10112b <cga_putc>
    serial_putc(c);
  1016a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1016a5:	89 04 24             	mov    %eax,(%esp)
  1016a8:	e8 d2 fc ff ff       	call   10137f <serial_putc>
}
  1016ad:	90                   	nop
  1016ae:	c9                   	leave  
  1016af:	c3                   	ret    

001016b0 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1016b0:	f3 0f 1e fb          	endbr32 
  1016b4:	55                   	push   %ebp
  1016b5:	89 e5                	mov    %esp,%ebp
  1016b7:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1016ba:	e8 b0 fd ff ff       	call   10146f <serial_intr>
    kbd_intr();
  1016bf:	e8 56 ff ff ff       	call   10161a <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1016c4:	8b 15 80 00 11 00    	mov    0x110080,%edx
  1016ca:	a1 84 00 11 00       	mov    0x110084,%eax
  1016cf:	39 c2                	cmp    %eax,%edx
  1016d1:	74 36                	je     101709 <cons_getc+0x59>
        c = cons.buf[cons.rpos ++];
  1016d3:	a1 80 00 11 00       	mov    0x110080,%eax
  1016d8:	8d 50 01             	lea    0x1(%eax),%edx
  1016db:	89 15 80 00 11 00    	mov    %edx,0x110080
  1016e1:	0f b6 80 80 fe 10 00 	movzbl 0x10fe80(%eax),%eax
  1016e8:	0f b6 c0             	movzbl %al,%eax
  1016eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  1016ee:	a1 80 00 11 00       	mov    0x110080,%eax
  1016f3:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016f8:	75 0a                	jne    101704 <cons_getc+0x54>
            cons.rpos = 0;
  1016fa:	c7 05 80 00 11 00 00 	movl   $0x0,0x110080
  101701:	00 00 00 
        }
        return c;
  101704:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101707:	eb 05                	jmp    10170e <cons_getc+0x5e>
    }
    return 0;
  101709:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10170e:	c9                   	leave  
  10170f:	c3                   	ret    

00101710 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101710:	f3 0f 1e fb          	endbr32 
  101714:	55                   	push   %ebp
  101715:	89 e5                	mov    %esp,%ebp
  101717:	83 ec 14             	sub    $0x14,%esp
  10171a:	8b 45 08             	mov    0x8(%ebp),%eax
  10171d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101721:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101724:	66 a3 50 f5 10 00    	mov    %ax,0x10f550
    if (did_init) {
  10172a:	a1 8c 00 11 00       	mov    0x11008c,%eax
  10172f:	85 c0                	test   %eax,%eax
  101731:	74 39                	je     10176c <pic_setmask+0x5c>
        outb(IO_PIC1 + 1, mask);
  101733:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101736:	0f b6 c0             	movzbl %al,%eax
  101739:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  10173f:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101742:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101746:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10174a:	ee                   	out    %al,(%dx)
}
  10174b:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  10174c:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101750:	c1 e8 08             	shr    $0x8,%eax
  101753:	0f b7 c0             	movzwl %ax,%eax
  101756:	0f b6 c0             	movzbl %al,%eax
  101759:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  10175f:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101762:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  101766:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10176a:	ee                   	out    %al,(%dx)
}
  10176b:	90                   	nop
    }
}
  10176c:	90                   	nop
  10176d:	c9                   	leave  
  10176e:	c3                   	ret    

0010176f <pic_enable>:

void
pic_enable(unsigned int irq) {
  10176f:	f3 0f 1e fb          	endbr32 
  101773:	55                   	push   %ebp
  101774:	89 e5                	mov    %esp,%ebp
  101776:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101779:	8b 45 08             	mov    0x8(%ebp),%eax
  10177c:	ba 01 00 00 00       	mov    $0x1,%edx
  101781:	88 c1                	mov    %al,%cl
  101783:	d3 e2                	shl    %cl,%edx
  101785:	89 d0                	mov    %edx,%eax
  101787:	98                   	cwtl   
  101788:	f7 d0                	not    %eax
  10178a:	0f bf d0             	movswl %ax,%edx
  10178d:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  101794:	98                   	cwtl   
  101795:	21 d0                	and    %edx,%eax
  101797:	98                   	cwtl   
  101798:	0f b7 c0             	movzwl %ax,%eax
  10179b:	89 04 24             	mov    %eax,(%esp)
  10179e:	e8 6d ff ff ff       	call   101710 <pic_setmask>
}
  1017a3:	90                   	nop
  1017a4:	c9                   	leave  
  1017a5:	c3                   	ret    

001017a6 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1017a6:	f3 0f 1e fb          	endbr32 
  1017aa:	55                   	push   %ebp
  1017ab:	89 e5                	mov    %esp,%ebp
  1017ad:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1017b0:	c7 05 8c 00 11 00 01 	movl   $0x1,0x11008c
  1017b7:	00 00 00 
  1017ba:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  1017c0:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017c4:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017c8:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017cc:	ee                   	out    %al,(%dx)
}
  1017cd:	90                   	nop
  1017ce:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  1017d4:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017d8:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  1017dc:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  1017e0:	ee                   	out    %al,(%dx)
}
  1017e1:	90                   	nop
  1017e2:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  1017e8:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1017ec:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  1017f0:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  1017f4:	ee                   	out    %al,(%dx)
}
  1017f5:	90                   	nop
  1017f6:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  1017fc:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101800:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101804:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101808:	ee                   	out    %al,(%dx)
}
  101809:	90                   	nop
  10180a:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101810:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101814:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101818:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10181c:	ee                   	out    %al,(%dx)
}
  10181d:	90                   	nop
  10181e:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  101824:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101828:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10182c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101830:	ee                   	out    %al,(%dx)
}
  101831:	90                   	nop
  101832:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  101838:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10183c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101840:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101844:	ee                   	out    %al,(%dx)
}
  101845:	90                   	nop
  101846:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  10184c:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101850:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101854:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101858:	ee                   	out    %al,(%dx)
}
  101859:	90                   	nop
  10185a:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  101860:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101864:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101868:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10186c:	ee                   	out    %al,(%dx)
}
  10186d:	90                   	nop
  10186e:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101874:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101878:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  10187c:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101880:	ee                   	out    %al,(%dx)
}
  101881:	90                   	nop
  101882:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  101888:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  10188c:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101890:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101894:	ee                   	out    %al,(%dx)
}
  101895:	90                   	nop
  101896:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  10189c:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1018a0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1018a4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1018a8:	ee                   	out    %al,(%dx)
}
  1018a9:	90                   	nop
  1018aa:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  1018b0:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1018b4:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1018b8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1018bc:	ee                   	out    %al,(%dx)
}
  1018bd:	90                   	nop
  1018be:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  1018c4:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1018c8:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1018cc:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1018d0:	ee                   	out    %al,(%dx)
}
  1018d1:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1018d2:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  1018d9:	3d ff ff 00 00       	cmp    $0xffff,%eax
  1018de:	74 0f                	je     1018ef <pic_init+0x149>
        pic_setmask(irq_mask);
  1018e0:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  1018e7:	89 04 24             	mov    %eax,(%esp)
  1018ea:	e8 21 fe ff ff       	call   101710 <pic_setmask>
    }
}
  1018ef:	90                   	nop
  1018f0:	c9                   	leave  
  1018f1:	c3                   	ret    

001018f2 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1018f2:	f3 0f 1e fb          	endbr32 
  1018f6:	55                   	push   %ebp
  1018f7:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  1018f9:	fb                   	sti    
}
  1018fa:	90                   	nop
    sti();
}
  1018fb:	90                   	nop
  1018fc:	5d                   	pop    %ebp
  1018fd:	c3                   	ret    

001018fe <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  1018fe:	f3 0f 1e fb          	endbr32 
  101902:	55                   	push   %ebp
  101903:	89 e5                	mov    %esp,%ebp

static inline void
cli(void) {
    asm volatile ("cli");
  101905:	fa                   	cli    
}
  101906:	90                   	nop
    cli();
}
  101907:	90                   	nop
  101908:	5d                   	pop    %ebp
  101909:	c3                   	ret    

0010190a <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
  10190a:	f3 0f 1e fb          	endbr32 
  10190e:	55                   	push   %ebp
  10190f:	89 e5                	mov    %esp,%ebp
  101911:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101914:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10191b:	00 
  10191c:	c7 04 24 40 3a 10 00 	movl   $0x103a40,(%esp)
  101923:	e8 6b e9 ff ff       	call   100293 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  101928:	c7 04 24 4a 3a 10 00 	movl   $0x103a4a,(%esp)
  10192f:	e8 5f e9 ff ff       	call   100293 <cprintf>
    panic("EOT: kernel seems ok.");
  101934:	c7 44 24 08 58 3a 10 	movl   $0x103a58,0x8(%esp)
  10193b:	00 
  10193c:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  101943:	00 
  101944:	c7 04 24 6e 3a 10 00 	movl   $0x103a6e,(%esp)
  10194b:	e8 af ea ff ff       	call   1003ff <__panic>

00101950 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101950:	f3 0f 1e fb          	endbr32 
  101954:	55                   	push   %ebp
  101955:	89 e5                	mov    %esp,%ebp
  101957:	83 ec 10             	sub    $0x10,%esp
           (try "make" command in lab1, then you will find vector.S in kern/trap DIR)
           You can use  "extern uintptr_t __vectors[];" to define this extern variable which will be used later. */
    extern uintptr_t __vectors[];
    /* (2) Now you should setup the entries of ISR in Interrupt Description Table (IDT).
           Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT */
    int idt_size = sizeof(idt) / sizeof(struct gatedesc);
  10195a:	c7 45 f8 00 01 00 00 	movl   $0x100,-0x8(%ebp)
    for (int i = 0; i < idt_size; ++i) {
  101961:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101968:	e9 c4 00 00 00       	jmp    101a31 <idt_init+0xe1>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  10196d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101970:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  101977:	0f b7 d0             	movzwl %ax,%edx
  10197a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197d:	66 89 14 c5 a0 00 11 	mov    %dx,0x1100a0(,%eax,8)
  101984:	00 
  101985:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101988:	66 c7 04 c5 a2 00 11 	movw   $0x8,0x1100a2(,%eax,8)
  10198f:	00 08 00 
  101992:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101995:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  10199c:	00 
  10199d:	80 e2 e0             	and    $0xe0,%dl
  1019a0:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  1019a7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019aa:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  1019b1:	00 
  1019b2:	80 e2 1f             	and    $0x1f,%dl
  1019b5:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  1019bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019bf:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  1019c6:	00 
  1019c7:	80 e2 f0             	and    $0xf0,%dl
  1019ca:	80 ca 0e             	or     $0xe,%dl
  1019cd:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  1019d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019d7:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  1019de:	00 
  1019df:	80 e2 ef             	and    $0xef,%dl
  1019e2:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  1019e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019ec:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  1019f3:	00 
  1019f4:	80 e2 9f             	and    $0x9f,%dl
  1019f7:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  1019fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a01:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101a08:	00 
  101a09:	80 ca 80             	or     $0x80,%dl
  101a0c:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101a13:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a16:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  101a1d:	c1 e8 10             	shr    $0x10,%eax
  101a20:	0f b7 d0             	movzwl %ax,%edx
  101a23:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a26:	66 89 14 c5 a6 00 11 	mov    %dx,0x1100a6(,%eax,8)
  101a2d:	00 
    for (int i = 0; i < idt_size; ++i) {
  101a2e:	ff 45 fc             	incl   -0x4(%ebp)
  101a31:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a34:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  101a37:	0f 8c 30 ff ff ff    	jl     10196d <idt_init+0x1d>
    }
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101a3d:	a1 c4 f7 10 00       	mov    0x10f7c4,%eax
  101a42:	0f b7 c0             	movzwl %ax,%eax
  101a45:	66 a3 68 04 11 00    	mov    %ax,0x110468
  101a4b:	66 c7 05 6a 04 11 00 	movw   $0x8,0x11046a
  101a52:	08 00 
  101a54:	0f b6 05 6c 04 11 00 	movzbl 0x11046c,%eax
  101a5b:	24 e0                	and    $0xe0,%al
  101a5d:	a2 6c 04 11 00       	mov    %al,0x11046c
  101a62:	0f b6 05 6c 04 11 00 	movzbl 0x11046c,%eax
  101a69:	24 1f                	and    $0x1f,%al
  101a6b:	a2 6c 04 11 00       	mov    %al,0x11046c
  101a70:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101a77:	24 f0                	and    $0xf0,%al
  101a79:	0c 0e                	or     $0xe,%al
  101a7b:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a80:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101a87:	24 ef                	and    $0xef,%al
  101a89:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a8e:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101a95:	0c 60                	or     $0x60,%al
  101a97:	a2 6d 04 11 00       	mov    %al,0x11046d
  101a9c:	0f b6 05 6d 04 11 00 	movzbl 0x11046d,%eax
  101aa3:	0c 80                	or     $0x80,%al
  101aa5:	a2 6d 04 11 00       	mov    %al,0x11046d
  101aaa:	a1 c4 f7 10 00       	mov    0x10f7c4,%eax
  101aaf:	c1 e8 10             	shr    $0x10,%eax
  101ab2:	0f b7 c0             	movzwl %ax,%eax
  101ab5:	66 a3 6e 04 11 00    	mov    %ax,0x11046e
  101abb:	c7 45 f4 60 f5 10 00 	movl   $0x10f560,-0xc(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd));
  101ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101ac5:	0f 01 18             	lidtl  (%eax)
}
  101ac8:	90                   	nop
    /* (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
           You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
           Notice: the argument of lidt is idt_pd. try to find it! */
    lidt(&idt_pd);
}
  101ac9:	90                   	nop
  101aca:	c9                   	leave  
  101acb:	c3                   	ret    

00101acc <trapname>:

static const char *
trapname(int trapno) {
  101acc:	f3 0f 1e fb          	endbr32 
  101ad0:	55                   	push   %ebp
  101ad1:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ad6:	83 f8 13             	cmp    $0x13,%eax
  101ad9:	77 0c                	ja     101ae7 <trapname+0x1b>
        return excnames[trapno];
  101adb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ade:	8b 04 85 c0 3d 10 00 	mov    0x103dc0(,%eax,4),%eax
  101ae5:	eb 18                	jmp    101aff <trapname+0x33>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101ae7:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101aeb:	7e 0d                	jle    101afa <trapname+0x2e>
  101aed:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101af1:	7f 07                	jg     101afa <trapname+0x2e>
        return "Hardware Interrupt";
  101af3:	b8 7f 3a 10 00       	mov    $0x103a7f,%eax
  101af8:	eb 05                	jmp    101aff <trapname+0x33>
    }
    return "(unknown trap)";
  101afa:	b8 92 3a 10 00       	mov    $0x103a92,%eax
}
  101aff:	5d                   	pop    %ebp
  101b00:	c3                   	ret    

00101b01 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101b01:	f3 0f 1e fb          	endbr32 
  101b05:	55                   	push   %ebp
  101b06:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101b08:	8b 45 08             	mov    0x8(%ebp),%eax
  101b0b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b0f:	83 f8 08             	cmp    $0x8,%eax
  101b12:	0f 94 c0             	sete   %al
  101b15:	0f b6 c0             	movzbl %al,%eax
}
  101b18:	5d                   	pop    %ebp
  101b19:	c3                   	ret    

00101b1a <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101b1a:	f3 0f 1e fb          	endbr32 
  101b1e:	55                   	push   %ebp
  101b1f:	89 e5                	mov    %esp,%ebp
  101b21:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101b24:	8b 45 08             	mov    0x8(%ebp),%eax
  101b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b2b:	c7 04 24 d3 3a 10 00 	movl   $0x103ad3,(%esp)
  101b32:	e8 5c e7 ff ff       	call   100293 <cprintf>
    print_regs(&tf->tf_regs);
  101b37:	8b 45 08             	mov    0x8(%ebp),%eax
  101b3a:	89 04 24             	mov    %eax,(%esp)
  101b3d:	e8 8d 01 00 00       	call   101ccf <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101b42:	8b 45 08             	mov    0x8(%ebp),%eax
  101b45:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101b49:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4d:	c7 04 24 e4 3a 10 00 	movl   $0x103ae4,(%esp)
  101b54:	e8 3a e7 ff ff       	call   100293 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101b59:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5c:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101b60:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b64:	c7 04 24 f7 3a 10 00 	movl   $0x103af7,(%esp)
  101b6b:	e8 23 e7 ff ff       	call   100293 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b70:	8b 45 08             	mov    0x8(%ebp),%eax
  101b73:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b77:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7b:	c7 04 24 0a 3b 10 00 	movl   $0x103b0a,(%esp)
  101b82:	e8 0c e7 ff ff       	call   100293 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b87:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8a:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b92:	c7 04 24 1d 3b 10 00 	movl   $0x103b1d,(%esp)
  101b99:	e8 f5 e6 ff ff       	call   100293 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba1:	8b 40 30             	mov    0x30(%eax),%eax
  101ba4:	89 04 24             	mov    %eax,(%esp)
  101ba7:	e8 20 ff ff ff       	call   101acc <trapname>
  101bac:	8b 55 08             	mov    0x8(%ebp),%edx
  101baf:	8b 52 30             	mov    0x30(%edx),%edx
  101bb2:	89 44 24 08          	mov    %eax,0x8(%esp)
  101bb6:	89 54 24 04          	mov    %edx,0x4(%esp)
  101bba:	c7 04 24 30 3b 10 00 	movl   $0x103b30,(%esp)
  101bc1:	e8 cd e6 ff ff       	call   100293 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc9:	8b 40 34             	mov    0x34(%eax),%eax
  101bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd0:	c7 04 24 42 3b 10 00 	movl   $0x103b42,(%esp)
  101bd7:	e8 b7 e6 ff ff       	call   100293 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  101bdf:	8b 40 38             	mov    0x38(%eax),%eax
  101be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be6:	c7 04 24 51 3b 10 00 	movl   $0x103b51,(%esp)
  101bed:	e8 a1 e6 ff ff       	call   100293 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101bf2:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfd:	c7 04 24 60 3b 10 00 	movl   $0x103b60,(%esp)
  101c04:	e8 8a e6 ff ff       	call   100293 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101c09:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0c:	8b 40 40             	mov    0x40(%eax),%eax
  101c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c13:	c7 04 24 73 3b 10 00 	movl   $0x103b73,(%esp)
  101c1a:	e8 74 e6 ff ff       	call   100293 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c1f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101c26:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101c2d:	eb 3d                	jmp    101c6c <print_trapframe+0x152>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c32:	8b 50 40             	mov    0x40(%eax),%edx
  101c35:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101c38:	21 d0                	and    %edx,%eax
  101c3a:	85 c0                	test   %eax,%eax
  101c3c:	74 28                	je     101c66 <print_trapframe+0x14c>
  101c3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c41:	8b 04 85 80 f5 10 00 	mov    0x10f580(,%eax,4),%eax
  101c48:	85 c0                	test   %eax,%eax
  101c4a:	74 1a                	je     101c66 <print_trapframe+0x14c>
            cprintf("%s,", IA32flags[i]);
  101c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c4f:	8b 04 85 80 f5 10 00 	mov    0x10f580(,%eax,4),%eax
  101c56:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5a:	c7 04 24 82 3b 10 00 	movl   $0x103b82,(%esp)
  101c61:	e8 2d e6 ff ff       	call   100293 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c66:	ff 45 f4             	incl   -0xc(%ebp)
  101c69:	d1 65 f0             	shll   -0x10(%ebp)
  101c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c6f:	83 f8 17             	cmp    $0x17,%eax
  101c72:	76 bb                	jbe    101c2f <print_trapframe+0x115>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c74:	8b 45 08             	mov    0x8(%ebp),%eax
  101c77:	8b 40 40             	mov    0x40(%eax),%eax
  101c7a:	c1 e8 0c             	shr    $0xc,%eax
  101c7d:	83 e0 03             	and    $0x3,%eax
  101c80:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c84:	c7 04 24 86 3b 10 00 	movl   $0x103b86,(%esp)
  101c8b:	e8 03 e6 ff ff       	call   100293 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c90:	8b 45 08             	mov    0x8(%ebp),%eax
  101c93:	89 04 24             	mov    %eax,(%esp)
  101c96:	e8 66 fe ff ff       	call   101b01 <trap_in_kernel>
  101c9b:	85 c0                	test   %eax,%eax
  101c9d:	75 2d                	jne    101ccc <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca2:	8b 40 44             	mov    0x44(%eax),%eax
  101ca5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ca9:	c7 04 24 8f 3b 10 00 	movl   $0x103b8f,(%esp)
  101cb0:	e8 de e5 ff ff       	call   100293 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb8:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc0:	c7 04 24 9e 3b 10 00 	movl   $0x103b9e,(%esp)
  101cc7:	e8 c7 e5 ff ff       	call   100293 <cprintf>
    }
}
  101ccc:	90                   	nop
  101ccd:	c9                   	leave  
  101cce:	c3                   	ret    

00101ccf <print_regs>:

void
print_regs(struct pushregs *regs) {
  101ccf:	f3 0f 1e fb          	endbr32 
  101cd3:	55                   	push   %ebp
  101cd4:	89 e5                	mov    %esp,%ebp
  101cd6:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  101cdc:	8b 00                	mov    (%eax),%eax
  101cde:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce2:	c7 04 24 b1 3b 10 00 	movl   $0x103bb1,(%esp)
  101ce9:	e8 a5 e5 ff ff       	call   100293 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101cee:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf1:	8b 40 04             	mov    0x4(%eax),%eax
  101cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf8:	c7 04 24 c0 3b 10 00 	movl   $0x103bc0,(%esp)
  101cff:	e8 8f e5 ff ff       	call   100293 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101d04:	8b 45 08             	mov    0x8(%ebp),%eax
  101d07:	8b 40 08             	mov    0x8(%eax),%eax
  101d0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0e:	c7 04 24 cf 3b 10 00 	movl   $0x103bcf,(%esp)
  101d15:	e8 79 e5 ff ff       	call   100293 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d1d:	8b 40 0c             	mov    0xc(%eax),%eax
  101d20:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d24:	c7 04 24 de 3b 10 00 	movl   $0x103bde,(%esp)
  101d2b:	e8 63 e5 ff ff       	call   100293 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d30:	8b 45 08             	mov    0x8(%ebp),%eax
  101d33:	8b 40 10             	mov    0x10(%eax),%eax
  101d36:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d3a:	c7 04 24 ed 3b 10 00 	movl   $0x103bed,(%esp)
  101d41:	e8 4d e5 ff ff       	call   100293 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101d46:	8b 45 08             	mov    0x8(%ebp),%eax
  101d49:	8b 40 14             	mov    0x14(%eax),%eax
  101d4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d50:	c7 04 24 fc 3b 10 00 	movl   $0x103bfc,(%esp)
  101d57:	e8 37 e5 ff ff       	call   100293 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101d5f:	8b 40 18             	mov    0x18(%eax),%eax
  101d62:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d66:	c7 04 24 0b 3c 10 00 	movl   $0x103c0b,(%esp)
  101d6d:	e8 21 e5 ff ff       	call   100293 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d72:	8b 45 08             	mov    0x8(%ebp),%eax
  101d75:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d78:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d7c:	c7 04 24 1a 3c 10 00 	movl   $0x103c1a,(%esp)
  101d83:	e8 0b e5 ff ff       	call   100293 <cprintf>
}
  101d88:	90                   	nop
  101d89:	c9                   	leave  
  101d8a:	c3                   	ret    

00101d8b <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d8b:	f3 0f 1e fb          	endbr32 
  101d8f:	55                   	push   %ebp
  101d90:	89 e5                	mov    %esp,%ebp
  101d92:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101d95:	8b 45 08             	mov    0x8(%ebp),%eax
  101d98:	8b 40 30             	mov    0x30(%eax),%eax
  101d9b:	83 f8 79             	cmp    $0x79,%eax
  101d9e:	0f 84 35 01 00 00    	je     101ed9 <trap_dispatch+0x14e>
  101da4:	83 f8 79             	cmp    $0x79,%eax
  101da7:	0f 87 68 01 00 00    	ja     101f15 <trap_dispatch+0x18a>
  101dad:	83 f8 78             	cmp    $0x78,%eax
  101db0:	0f 84 da 00 00 00    	je     101e90 <trap_dispatch+0x105>
  101db6:	83 f8 78             	cmp    $0x78,%eax
  101db9:	0f 87 56 01 00 00    	ja     101f15 <trap_dispatch+0x18a>
  101dbf:	83 f8 2f             	cmp    $0x2f,%eax
  101dc2:	0f 87 4d 01 00 00    	ja     101f15 <trap_dispatch+0x18a>
  101dc8:	83 f8 2e             	cmp    $0x2e,%eax
  101dcb:	0f 83 79 01 00 00    	jae    101f4a <trap_dispatch+0x1bf>
  101dd1:	83 f8 24             	cmp    $0x24,%eax
  101dd4:	74 68                	je     101e3e <trap_dispatch+0xb3>
  101dd6:	83 f8 24             	cmp    $0x24,%eax
  101dd9:	0f 87 36 01 00 00    	ja     101f15 <trap_dispatch+0x18a>
  101ddf:	83 f8 20             	cmp    $0x20,%eax
  101de2:	74 0a                	je     101dee <trap_dispatch+0x63>
  101de4:	83 f8 21             	cmp    $0x21,%eax
  101de7:	74 7e                	je     101e67 <trap_dispatch+0xdc>
  101de9:	e9 27 01 00 00       	jmp    101f15 <trap_dispatch+0x18a>
    case IRQ_OFFSET + IRQ_TIMER:
        /* LAB1 YOUR CODE : STEP 3 */
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c */
        ticks++;
  101dee:	a1 08 09 11 00       	mov    0x110908,%eax
  101df3:	40                   	inc    %eax
  101df4:	a3 08 09 11 00       	mov    %eax,0x110908
        /* (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks(). */
        if (ticks % TICK_NUM == 0) {
  101df9:	8b 0d 08 09 11 00    	mov    0x110908,%ecx
  101dff:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101e04:	89 c8                	mov    %ecx,%eax
  101e06:	f7 e2                	mul    %edx
  101e08:	c1 ea 05             	shr    $0x5,%edx
  101e0b:	89 d0                	mov    %edx,%eax
  101e0d:	c1 e0 02             	shl    $0x2,%eax
  101e10:	01 d0                	add    %edx,%eax
  101e12:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101e19:	01 d0                	add    %edx,%eax
  101e1b:	c1 e0 02             	shl    $0x2,%eax
  101e1e:	29 c1                	sub    %eax,%ecx
  101e20:	89 ca                	mov    %ecx,%edx
  101e22:	85 d2                	test   %edx,%edx
  101e24:	0f 85 23 01 00 00    	jne    101f4d <trap_dispatch+0x1c2>
            print_ticks();
  101e2a:	e8 db fa ff ff       	call   10190a <print_ticks>
            ticks = 0;
  101e2f:	c7 05 08 09 11 00 00 	movl   $0x0,0x110908
  101e36:	00 00 00 
        }
        /* (3) Too Simple? Yes, I think so! */
        break;
  101e39:	e9 0f 01 00 00       	jmp    101f4d <trap_dispatch+0x1c2>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101e3e:	e8 6d f8 ff ff       	call   1016b0 <cons_getc>
  101e43:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101e46:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e4a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e4e:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e52:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e56:	c7 04 24 29 3c 10 00 	movl   $0x103c29,(%esp)
  101e5d:	e8 31 e4 ff ff       	call   100293 <cprintf>
        break;
  101e62:	e9 ed 00 00 00       	jmp    101f54 <trap_dispatch+0x1c9>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101e67:	e8 44 f8 ff ff       	call   1016b0 <cons_getc>
  101e6c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101e6f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e73:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e77:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e7f:	c7 04 24 3b 3c 10 00 	movl   $0x103c3b,(%esp)
  101e86:	e8 08 e4 ff ff       	call   100293 <cprintf>
        break;
  101e8b:	e9 c4 00 00 00       	jmp    101f54 <trap_dispatch+0x1c9>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        // 如果原先保存在trapframe中的cs不是代表用户态的USER_CS
        if (tf->tf_cs != USER_CS) {
  101e90:	8b 45 08             	mov    0x8(%ebp),%eax
  101e93:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e97:	83 f8 1b             	cmp    $0x1b,%eax
  101e9a:	0f 84 b0 00 00 00    	je     101f50 <trap_dispatch+0x1c5>
            // 将保存在trapframe中的cs改成代表用户态的USER_CS
            tf->tf_cs = USER_CS;
  101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ea3:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            // 将其它的段选择子都修改为代表用户态的USER_DS，保证中断返回之后可以正常访问数据
            tf->tf_ds = USER_DS;
  101ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  101eac:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
            tf->tf_es = USER_DS;
  101eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  101eb5:	66 c7 40 28 23 00    	movw   $0x23,0x28(%eax)
            tf->tf_ss = USER_DS;
  101ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ebe:	66 c7 40 48 23 00    	movw   $0x23,0x48(%eax)
            // 为了程序在CPL较低的情况下也能使用IO，需要将对应的IOPL位置改成用户态
            tf->tf_eflags |= FL_IOPL_MASK;
  101ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  101ec7:	8b 40 40             	mov    0x40(%eax),%eax
  101eca:	0d 00 30 00 00       	or     $0x3000,%eax
  101ecf:	89 c2                	mov    %eax,%edx
  101ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ed4:	89 50 40             	mov    %edx,0x40(%eax)
        }
        break;
  101ed7:	eb 77                	jmp    101f50 <trap_dispatch+0x1c5>
    case T_SWITCH_TOK:
        // 如果原先保存在trapframe中的cs不是代表内核态的KERNEL_CS
        if (tf->tf_cs != KERNEL_CS) {
  101ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  101edc:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ee0:	83 f8 08             	cmp    $0x8,%eax
  101ee3:	74 6e                	je     101f53 <trap_dispatch+0x1c8>
            // 将保存在trapframe中的cs改成代表内核态的KERNEL_CS
            tf->tf_cs = KERNEL_CS;
  101ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee8:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            // 将其它的段选择子都修改为代表内核态的KERNEL_DS，保证中断返回之后可以正常访问数据
            tf->tf_ds = KERNEL_DS;
  101eee:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef1:	66 c7 40 2c 10 00    	movw   $0x10,0x2c(%eax)
            tf->tf_es = KERNEL_DS;
  101ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  101efa:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
            // 将调用IO所需权限降低，才能输出文本
            tf->tf_eflags |= 0x3000;
  101f00:	8b 45 08             	mov    0x8(%ebp),%eax
  101f03:	8b 40 40             	mov    0x40(%eax),%eax
  101f06:	0d 00 30 00 00       	or     $0x3000,%eax
  101f0b:	89 c2                	mov    %eax,%edx
  101f0d:	8b 45 08             	mov    0x8(%ebp),%eax
  101f10:	89 50 40             	mov    %edx,0x40(%eax)
        }
        break;
  101f13:	eb 3e                	jmp    101f53 <trap_dispatch+0x1c8>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101f15:	8b 45 08             	mov    0x8(%ebp),%eax
  101f18:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f1c:	83 e0 03             	and    $0x3,%eax
  101f1f:	85 c0                	test   %eax,%eax
  101f21:	75 31                	jne    101f54 <trap_dispatch+0x1c9>
            print_trapframe(tf);
  101f23:	8b 45 08             	mov    0x8(%ebp),%eax
  101f26:	89 04 24             	mov    %eax,(%esp)
  101f29:	e8 ec fb ff ff       	call   101b1a <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101f2e:	c7 44 24 08 4a 3c 10 	movl   $0x103c4a,0x8(%esp)
  101f35:	00 
  101f36:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
  101f3d:	00 
  101f3e:	c7 04 24 6e 3a 10 00 	movl   $0x103a6e,(%esp)
  101f45:	e8 b5 e4 ff ff       	call   1003ff <__panic>
        break;
  101f4a:	90                   	nop
  101f4b:	eb 07                	jmp    101f54 <trap_dispatch+0x1c9>
        break;
  101f4d:	90                   	nop
  101f4e:	eb 04                	jmp    101f54 <trap_dispatch+0x1c9>
        break;
  101f50:	90                   	nop
  101f51:	eb 01                	jmp    101f54 <trap_dispatch+0x1c9>
        break;
  101f53:	90                   	nop
        }
    }
}
  101f54:	90                   	nop
  101f55:	c9                   	leave  
  101f56:	c3                   	ret    

00101f57 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101f57:	f3 0f 1e fb          	endbr32 
  101f5b:	55                   	push   %ebp
  101f5c:	89 e5                	mov    %esp,%ebp
  101f5e:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101f61:	8b 45 08             	mov    0x8(%ebp),%eax
  101f64:	89 04 24             	mov    %eax,(%esp)
  101f67:	e8 1f fe ff ff       	call   101d8b <trap_dispatch>
}
  101f6c:	90                   	nop
  101f6d:	c9                   	leave  
  101f6e:	c3                   	ret    

00101f6f <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101f6f:	6a 00                	push   $0x0
  pushl $0
  101f71:	6a 00                	push   $0x0
  jmp __alltraps
  101f73:	e9 69 0a 00 00       	jmp    1029e1 <__alltraps>

00101f78 <vector1>:
.globl vector1
vector1:
  pushl $0
  101f78:	6a 00                	push   $0x0
  pushl $1
  101f7a:	6a 01                	push   $0x1
  jmp __alltraps
  101f7c:	e9 60 0a 00 00       	jmp    1029e1 <__alltraps>

00101f81 <vector2>:
.globl vector2
vector2:
  pushl $0
  101f81:	6a 00                	push   $0x0
  pushl $2
  101f83:	6a 02                	push   $0x2
  jmp __alltraps
  101f85:	e9 57 0a 00 00       	jmp    1029e1 <__alltraps>

00101f8a <vector3>:
.globl vector3
vector3:
  pushl $0
  101f8a:	6a 00                	push   $0x0
  pushl $3
  101f8c:	6a 03                	push   $0x3
  jmp __alltraps
  101f8e:	e9 4e 0a 00 00       	jmp    1029e1 <__alltraps>

00101f93 <vector4>:
.globl vector4
vector4:
  pushl $0
  101f93:	6a 00                	push   $0x0
  pushl $4
  101f95:	6a 04                	push   $0x4
  jmp __alltraps
  101f97:	e9 45 0a 00 00       	jmp    1029e1 <__alltraps>

00101f9c <vector5>:
.globl vector5
vector5:
  pushl $0
  101f9c:	6a 00                	push   $0x0
  pushl $5
  101f9e:	6a 05                	push   $0x5
  jmp __alltraps
  101fa0:	e9 3c 0a 00 00       	jmp    1029e1 <__alltraps>

00101fa5 <vector6>:
.globl vector6
vector6:
  pushl $0
  101fa5:	6a 00                	push   $0x0
  pushl $6
  101fa7:	6a 06                	push   $0x6
  jmp __alltraps
  101fa9:	e9 33 0a 00 00       	jmp    1029e1 <__alltraps>

00101fae <vector7>:
.globl vector7
vector7:
  pushl $0
  101fae:	6a 00                	push   $0x0
  pushl $7
  101fb0:	6a 07                	push   $0x7
  jmp __alltraps
  101fb2:	e9 2a 0a 00 00       	jmp    1029e1 <__alltraps>

00101fb7 <vector8>:
.globl vector8
vector8:
  pushl $8
  101fb7:	6a 08                	push   $0x8
  jmp __alltraps
  101fb9:	e9 23 0a 00 00       	jmp    1029e1 <__alltraps>

00101fbe <vector9>:
.globl vector9
vector9:
  pushl $0
  101fbe:	6a 00                	push   $0x0
  pushl $9
  101fc0:	6a 09                	push   $0x9
  jmp __alltraps
  101fc2:	e9 1a 0a 00 00       	jmp    1029e1 <__alltraps>

00101fc7 <vector10>:
.globl vector10
vector10:
  pushl $10
  101fc7:	6a 0a                	push   $0xa
  jmp __alltraps
  101fc9:	e9 13 0a 00 00       	jmp    1029e1 <__alltraps>

00101fce <vector11>:
.globl vector11
vector11:
  pushl $11
  101fce:	6a 0b                	push   $0xb
  jmp __alltraps
  101fd0:	e9 0c 0a 00 00       	jmp    1029e1 <__alltraps>

00101fd5 <vector12>:
.globl vector12
vector12:
  pushl $12
  101fd5:	6a 0c                	push   $0xc
  jmp __alltraps
  101fd7:	e9 05 0a 00 00       	jmp    1029e1 <__alltraps>

00101fdc <vector13>:
.globl vector13
vector13:
  pushl $13
  101fdc:	6a 0d                	push   $0xd
  jmp __alltraps
  101fde:	e9 fe 09 00 00       	jmp    1029e1 <__alltraps>

00101fe3 <vector14>:
.globl vector14
vector14:
  pushl $14
  101fe3:	6a 0e                	push   $0xe
  jmp __alltraps
  101fe5:	e9 f7 09 00 00       	jmp    1029e1 <__alltraps>

00101fea <vector15>:
.globl vector15
vector15:
  pushl $0
  101fea:	6a 00                	push   $0x0
  pushl $15
  101fec:	6a 0f                	push   $0xf
  jmp __alltraps
  101fee:	e9 ee 09 00 00       	jmp    1029e1 <__alltraps>

00101ff3 <vector16>:
.globl vector16
vector16:
  pushl $0
  101ff3:	6a 00                	push   $0x0
  pushl $16
  101ff5:	6a 10                	push   $0x10
  jmp __alltraps
  101ff7:	e9 e5 09 00 00       	jmp    1029e1 <__alltraps>

00101ffc <vector17>:
.globl vector17
vector17:
  pushl $17
  101ffc:	6a 11                	push   $0x11
  jmp __alltraps
  101ffe:	e9 de 09 00 00       	jmp    1029e1 <__alltraps>

00102003 <vector18>:
.globl vector18
vector18:
  pushl $0
  102003:	6a 00                	push   $0x0
  pushl $18
  102005:	6a 12                	push   $0x12
  jmp __alltraps
  102007:	e9 d5 09 00 00       	jmp    1029e1 <__alltraps>

0010200c <vector19>:
.globl vector19
vector19:
  pushl $0
  10200c:	6a 00                	push   $0x0
  pushl $19
  10200e:	6a 13                	push   $0x13
  jmp __alltraps
  102010:	e9 cc 09 00 00       	jmp    1029e1 <__alltraps>

00102015 <vector20>:
.globl vector20
vector20:
  pushl $0
  102015:	6a 00                	push   $0x0
  pushl $20
  102017:	6a 14                	push   $0x14
  jmp __alltraps
  102019:	e9 c3 09 00 00       	jmp    1029e1 <__alltraps>

0010201e <vector21>:
.globl vector21
vector21:
  pushl $0
  10201e:	6a 00                	push   $0x0
  pushl $21
  102020:	6a 15                	push   $0x15
  jmp __alltraps
  102022:	e9 ba 09 00 00       	jmp    1029e1 <__alltraps>

00102027 <vector22>:
.globl vector22
vector22:
  pushl $0
  102027:	6a 00                	push   $0x0
  pushl $22
  102029:	6a 16                	push   $0x16
  jmp __alltraps
  10202b:	e9 b1 09 00 00       	jmp    1029e1 <__alltraps>

00102030 <vector23>:
.globl vector23
vector23:
  pushl $0
  102030:	6a 00                	push   $0x0
  pushl $23
  102032:	6a 17                	push   $0x17
  jmp __alltraps
  102034:	e9 a8 09 00 00       	jmp    1029e1 <__alltraps>

00102039 <vector24>:
.globl vector24
vector24:
  pushl $0
  102039:	6a 00                	push   $0x0
  pushl $24
  10203b:	6a 18                	push   $0x18
  jmp __alltraps
  10203d:	e9 9f 09 00 00       	jmp    1029e1 <__alltraps>

00102042 <vector25>:
.globl vector25
vector25:
  pushl $0
  102042:	6a 00                	push   $0x0
  pushl $25
  102044:	6a 19                	push   $0x19
  jmp __alltraps
  102046:	e9 96 09 00 00       	jmp    1029e1 <__alltraps>

0010204b <vector26>:
.globl vector26
vector26:
  pushl $0
  10204b:	6a 00                	push   $0x0
  pushl $26
  10204d:	6a 1a                	push   $0x1a
  jmp __alltraps
  10204f:	e9 8d 09 00 00       	jmp    1029e1 <__alltraps>

00102054 <vector27>:
.globl vector27
vector27:
  pushl $0
  102054:	6a 00                	push   $0x0
  pushl $27
  102056:	6a 1b                	push   $0x1b
  jmp __alltraps
  102058:	e9 84 09 00 00       	jmp    1029e1 <__alltraps>

0010205d <vector28>:
.globl vector28
vector28:
  pushl $0
  10205d:	6a 00                	push   $0x0
  pushl $28
  10205f:	6a 1c                	push   $0x1c
  jmp __alltraps
  102061:	e9 7b 09 00 00       	jmp    1029e1 <__alltraps>

00102066 <vector29>:
.globl vector29
vector29:
  pushl $0
  102066:	6a 00                	push   $0x0
  pushl $29
  102068:	6a 1d                	push   $0x1d
  jmp __alltraps
  10206a:	e9 72 09 00 00       	jmp    1029e1 <__alltraps>

0010206f <vector30>:
.globl vector30
vector30:
  pushl $0
  10206f:	6a 00                	push   $0x0
  pushl $30
  102071:	6a 1e                	push   $0x1e
  jmp __alltraps
  102073:	e9 69 09 00 00       	jmp    1029e1 <__alltraps>

00102078 <vector31>:
.globl vector31
vector31:
  pushl $0
  102078:	6a 00                	push   $0x0
  pushl $31
  10207a:	6a 1f                	push   $0x1f
  jmp __alltraps
  10207c:	e9 60 09 00 00       	jmp    1029e1 <__alltraps>

00102081 <vector32>:
.globl vector32
vector32:
  pushl $0
  102081:	6a 00                	push   $0x0
  pushl $32
  102083:	6a 20                	push   $0x20
  jmp __alltraps
  102085:	e9 57 09 00 00       	jmp    1029e1 <__alltraps>

0010208a <vector33>:
.globl vector33
vector33:
  pushl $0
  10208a:	6a 00                	push   $0x0
  pushl $33
  10208c:	6a 21                	push   $0x21
  jmp __alltraps
  10208e:	e9 4e 09 00 00       	jmp    1029e1 <__alltraps>

00102093 <vector34>:
.globl vector34
vector34:
  pushl $0
  102093:	6a 00                	push   $0x0
  pushl $34
  102095:	6a 22                	push   $0x22
  jmp __alltraps
  102097:	e9 45 09 00 00       	jmp    1029e1 <__alltraps>

0010209c <vector35>:
.globl vector35
vector35:
  pushl $0
  10209c:	6a 00                	push   $0x0
  pushl $35
  10209e:	6a 23                	push   $0x23
  jmp __alltraps
  1020a0:	e9 3c 09 00 00       	jmp    1029e1 <__alltraps>

001020a5 <vector36>:
.globl vector36
vector36:
  pushl $0
  1020a5:	6a 00                	push   $0x0
  pushl $36
  1020a7:	6a 24                	push   $0x24
  jmp __alltraps
  1020a9:	e9 33 09 00 00       	jmp    1029e1 <__alltraps>

001020ae <vector37>:
.globl vector37
vector37:
  pushl $0
  1020ae:	6a 00                	push   $0x0
  pushl $37
  1020b0:	6a 25                	push   $0x25
  jmp __alltraps
  1020b2:	e9 2a 09 00 00       	jmp    1029e1 <__alltraps>

001020b7 <vector38>:
.globl vector38
vector38:
  pushl $0
  1020b7:	6a 00                	push   $0x0
  pushl $38
  1020b9:	6a 26                	push   $0x26
  jmp __alltraps
  1020bb:	e9 21 09 00 00       	jmp    1029e1 <__alltraps>

001020c0 <vector39>:
.globl vector39
vector39:
  pushl $0
  1020c0:	6a 00                	push   $0x0
  pushl $39
  1020c2:	6a 27                	push   $0x27
  jmp __alltraps
  1020c4:	e9 18 09 00 00       	jmp    1029e1 <__alltraps>

001020c9 <vector40>:
.globl vector40
vector40:
  pushl $0
  1020c9:	6a 00                	push   $0x0
  pushl $40
  1020cb:	6a 28                	push   $0x28
  jmp __alltraps
  1020cd:	e9 0f 09 00 00       	jmp    1029e1 <__alltraps>

001020d2 <vector41>:
.globl vector41
vector41:
  pushl $0
  1020d2:	6a 00                	push   $0x0
  pushl $41
  1020d4:	6a 29                	push   $0x29
  jmp __alltraps
  1020d6:	e9 06 09 00 00       	jmp    1029e1 <__alltraps>

001020db <vector42>:
.globl vector42
vector42:
  pushl $0
  1020db:	6a 00                	push   $0x0
  pushl $42
  1020dd:	6a 2a                	push   $0x2a
  jmp __alltraps
  1020df:	e9 fd 08 00 00       	jmp    1029e1 <__alltraps>

001020e4 <vector43>:
.globl vector43
vector43:
  pushl $0
  1020e4:	6a 00                	push   $0x0
  pushl $43
  1020e6:	6a 2b                	push   $0x2b
  jmp __alltraps
  1020e8:	e9 f4 08 00 00       	jmp    1029e1 <__alltraps>

001020ed <vector44>:
.globl vector44
vector44:
  pushl $0
  1020ed:	6a 00                	push   $0x0
  pushl $44
  1020ef:	6a 2c                	push   $0x2c
  jmp __alltraps
  1020f1:	e9 eb 08 00 00       	jmp    1029e1 <__alltraps>

001020f6 <vector45>:
.globl vector45
vector45:
  pushl $0
  1020f6:	6a 00                	push   $0x0
  pushl $45
  1020f8:	6a 2d                	push   $0x2d
  jmp __alltraps
  1020fa:	e9 e2 08 00 00       	jmp    1029e1 <__alltraps>

001020ff <vector46>:
.globl vector46
vector46:
  pushl $0
  1020ff:	6a 00                	push   $0x0
  pushl $46
  102101:	6a 2e                	push   $0x2e
  jmp __alltraps
  102103:	e9 d9 08 00 00       	jmp    1029e1 <__alltraps>

00102108 <vector47>:
.globl vector47
vector47:
  pushl $0
  102108:	6a 00                	push   $0x0
  pushl $47
  10210a:	6a 2f                	push   $0x2f
  jmp __alltraps
  10210c:	e9 d0 08 00 00       	jmp    1029e1 <__alltraps>

00102111 <vector48>:
.globl vector48
vector48:
  pushl $0
  102111:	6a 00                	push   $0x0
  pushl $48
  102113:	6a 30                	push   $0x30
  jmp __alltraps
  102115:	e9 c7 08 00 00       	jmp    1029e1 <__alltraps>

0010211a <vector49>:
.globl vector49
vector49:
  pushl $0
  10211a:	6a 00                	push   $0x0
  pushl $49
  10211c:	6a 31                	push   $0x31
  jmp __alltraps
  10211e:	e9 be 08 00 00       	jmp    1029e1 <__alltraps>

00102123 <vector50>:
.globl vector50
vector50:
  pushl $0
  102123:	6a 00                	push   $0x0
  pushl $50
  102125:	6a 32                	push   $0x32
  jmp __alltraps
  102127:	e9 b5 08 00 00       	jmp    1029e1 <__alltraps>

0010212c <vector51>:
.globl vector51
vector51:
  pushl $0
  10212c:	6a 00                	push   $0x0
  pushl $51
  10212e:	6a 33                	push   $0x33
  jmp __alltraps
  102130:	e9 ac 08 00 00       	jmp    1029e1 <__alltraps>

00102135 <vector52>:
.globl vector52
vector52:
  pushl $0
  102135:	6a 00                	push   $0x0
  pushl $52
  102137:	6a 34                	push   $0x34
  jmp __alltraps
  102139:	e9 a3 08 00 00       	jmp    1029e1 <__alltraps>

0010213e <vector53>:
.globl vector53
vector53:
  pushl $0
  10213e:	6a 00                	push   $0x0
  pushl $53
  102140:	6a 35                	push   $0x35
  jmp __alltraps
  102142:	e9 9a 08 00 00       	jmp    1029e1 <__alltraps>

00102147 <vector54>:
.globl vector54
vector54:
  pushl $0
  102147:	6a 00                	push   $0x0
  pushl $54
  102149:	6a 36                	push   $0x36
  jmp __alltraps
  10214b:	e9 91 08 00 00       	jmp    1029e1 <__alltraps>

00102150 <vector55>:
.globl vector55
vector55:
  pushl $0
  102150:	6a 00                	push   $0x0
  pushl $55
  102152:	6a 37                	push   $0x37
  jmp __alltraps
  102154:	e9 88 08 00 00       	jmp    1029e1 <__alltraps>

00102159 <vector56>:
.globl vector56
vector56:
  pushl $0
  102159:	6a 00                	push   $0x0
  pushl $56
  10215b:	6a 38                	push   $0x38
  jmp __alltraps
  10215d:	e9 7f 08 00 00       	jmp    1029e1 <__alltraps>

00102162 <vector57>:
.globl vector57
vector57:
  pushl $0
  102162:	6a 00                	push   $0x0
  pushl $57
  102164:	6a 39                	push   $0x39
  jmp __alltraps
  102166:	e9 76 08 00 00       	jmp    1029e1 <__alltraps>

0010216b <vector58>:
.globl vector58
vector58:
  pushl $0
  10216b:	6a 00                	push   $0x0
  pushl $58
  10216d:	6a 3a                	push   $0x3a
  jmp __alltraps
  10216f:	e9 6d 08 00 00       	jmp    1029e1 <__alltraps>

00102174 <vector59>:
.globl vector59
vector59:
  pushl $0
  102174:	6a 00                	push   $0x0
  pushl $59
  102176:	6a 3b                	push   $0x3b
  jmp __alltraps
  102178:	e9 64 08 00 00       	jmp    1029e1 <__alltraps>

0010217d <vector60>:
.globl vector60
vector60:
  pushl $0
  10217d:	6a 00                	push   $0x0
  pushl $60
  10217f:	6a 3c                	push   $0x3c
  jmp __alltraps
  102181:	e9 5b 08 00 00       	jmp    1029e1 <__alltraps>

00102186 <vector61>:
.globl vector61
vector61:
  pushl $0
  102186:	6a 00                	push   $0x0
  pushl $61
  102188:	6a 3d                	push   $0x3d
  jmp __alltraps
  10218a:	e9 52 08 00 00       	jmp    1029e1 <__alltraps>

0010218f <vector62>:
.globl vector62
vector62:
  pushl $0
  10218f:	6a 00                	push   $0x0
  pushl $62
  102191:	6a 3e                	push   $0x3e
  jmp __alltraps
  102193:	e9 49 08 00 00       	jmp    1029e1 <__alltraps>

00102198 <vector63>:
.globl vector63
vector63:
  pushl $0
  102198:	6a 00                	push   $0x0
  pushl $63
  10219a:	6a 3f                	push   $0x3f
  jmp __alltraps
  10219c:	e9 40 08 00 00       	jmp    1029e1 <__alltraps>

001021a1 <vector64>:
.globl vector64
vector64:
  pushl $0
  1021a1:	6a 00                	push   $0x0
  pushl $64
  1021a3:	6a 40                	push   $0x40
  jmp __alltraps
  1021a5:	e9 37 08 00 00       	jmp    1029e1 <__alltraps>

001021aa <vector65>:
.globl vector65
vector65:
  pushl $0
  1021aa:	6a 00                	push   $0x0
  pushl $65
  1021ac:	6a 41                	push   $0x41
  jmp __alltraps
  1021ae:	e9 2e 08 00 00       	jmp    1029e1 <__alltraps>

001021b3 <vector66>:
.globl vector66
vector66:
  pushl $0
  1021b3:	6a 00                	push   $0x0
  pushl $66
  1021b5:	6a 42                	push   $0x42
  jmp __alltraps
  1021b7:	e9 25 08 00 00       	jmp    1029e1 <__alltraps>

001021bc <vector67>:
.globl vector67
vector67:
  pushl $0
  1021bc:	6a 00                	push   $0x0
  pushl $67
  1021be:	6a 43                	push   $0x43
  jmp __alltraps
  1021c0:	e9 1c 08 00 00       	jmp    1029e1 <__alltraps>

001021c5 <vector68>:
.globl vector68
vector68:
  pushl $0
  1021c5:	6a 00                	push   $0x0
  pushl $68
  1021c7:	6a 44                	push   $0x44
  jmp __alltraps
  1021c9:	e9 13 08 00 00       	jmp    1029e1 <__alltraps>

001021ce <vector69>:
.globl vector69
vector69:
  pushl $0
  1021ce:	6a 00                	push   $0x0
  pushl $69
  1021d0:	6a 45                	push   $0x45
  jmp __alltraps
  1021d2:	e9 0a 08 00 00       	jmp    1029e1 <__alltraps>

001021d7 <vector70>:
.globl vector70
vector70:
  pushl $0
  1021d7:	6a 00                	push   $0x0
  pushl $70
  1021d9:	6a 46                	push   $0x46
  jmp __alltraps
  1021db:	e9 01 08 00 00       	jmp    1029e1 <__alltraps>

001021e0 <vector71>:
.globl vector71
vector71:
  pushl $0
  1021e0:	6a 00                	push   $0x0
  pushl $71
  1021e2:	6a 47                	push   $0x47
  jmp __alltraps
  1021e4:	e9 f8 07 00 00       	jmp    1029e1 <__alltraps>

001021e9 <vector72>:
.globl vector72
vector72:
  pushl $0
  1021e9:	6a 00                	push   $0x0
  pushl $72
  1021eb:	6a 48                	push   $0x48
  jmp __alltraps
  1021ed:	e9 ef 07 00 00       	jmp    1029e1 <__alltraps>

001021f2 <vector73>:
.globl vector73
vector73:
  pushl $0
  1021f2:	6a 00                	push   $0x0
  pushl $73
  1021f4:	6a 49                	push   $0x49
  jmp __alltraps
  1021f6:	e9 e6 07 00 00       	jmp    1029e1 <__alltraps>

001021fb <vector74>:
.globl vector74
vector74:
  pushl $0
  1021fb:	6a 00                	push   $0x0
  pushl $74
  1021fd:	6a 4a                	push   $0x4a
  jmp __alltraps
  1021ff:	e9 dd 07 00 00       	jmp    1029e1 <__alltraps>

00102204 <vector75>:
.globl vector75
vector75:
  pushl $0
  102204:	6a 00                	push   $0x0
  pushl $75
  102206:	6a 4b                	push   $0x4b
  jmp __alltraps
  102208:	e9 d4 07 00 00       	jmp    1029e1 <__alltraps>

0010220d <vector76>:
.globl vector76
vector76:
  pushl $0
  10220d:	6a 00                	push   $0x0
  pushl $76
  10220f:	6a 4c                	push   $0x4c
  jmp __alltraps
  102211:	e9 cb 07 00 00       	jmp    1029e1 <__alltraps>

00102216 <vector77>:
.globl vector77
vector77:
  pushl $0
  102216:	6a 00                	push   $0x0
  pushl $77
  102218:	6a 4d                	push   $0x4d
  jmp __alltraps
  10221a:	e9 c2 07 00 00       	jmp    1029e1 <__alltraps>

0010221f <vector78>:
.globl vector78
vector78:
  pushl $0
  10221f:	6a 00                	push   $0x0
  pushl $78
  102221:	6a 4e                	push   $0x4e
  jmp __alltraps
  102223:	e9 b9 07 00 00       	jmp    1029e1 <__alltraps>

00102228 <vector79>:
.globl vector79
vector79:
  pushl $0
  102228:	6a 00                	push   $0x0
  pushl $79
  10222a:	6a 4f                	push   $0x4f
  jmp __alltraps
  10222c:	e9 b0 07 00 00       	jmp    1029e1 <__alltraps>

00102231 <vector80>:
.globl vector80
vector80:
  pushl $0
  102231:	6a 00                	push   $0x0
  pushl $80
  102233:	6a 50                	push   $0x50
  jmp __alltraps
  102235:	e9 a7 07 00 00       	jmp    1029e1 <__alltraps>

0010223a <vector81>:
.globl vector81
vector81:
  pushl $0
  10223a:	6a 00                	push   $0x0
  pushl $81
  10223c:	6a 51                	push   $0x51
  jmp __alltraps
  10223e:	e9 9e 07 00 00       	jmp    1029e1 <__alltraps>

00102243 <vector82>:
.globl vector82
vector82:
  pushl $0
  102243:	6a 00                	push   $0x0
  pushl $82
  102245:	6a 52                	push   $0x52
  jmp __alltraps
  102247:	e9 95 07 00 00       	jmp    1029e1 <__alltraps>

0010224c <vector83>:
.globl vector83
vector83:
  pushl $0
  10224c:	6a 00                	push   $0x0
  pushl $83
  10224e:	6a 53                	push   $0x53
  jmp __alltraps
  102250:	e9 8c 07 00 00       	jmp    1029e1 <__alltraps>

00102255 <vector84>:
.globl vector84
vector84:
  pushl $0
  102255:	6a 00                	push   $0x0
  pushl $84
  102257:	6a 54                	push   $0x54
  jmp __alltraps
  102259:	e9 83 07 00 00       	jmp    1029e1 <__alltraps>

0010225e <vector85>:
.globl vector85
vector85:
  pushl $0
  10225e:	6a 00                	push   $0x0
  pushl $85
  102260:	6a 55                	push   $0x55
  jmp __alltraps
  102262:	e9 7a 07 00 00       	jmp    1029e1 <__alltraps>

00102267 <vector86>:
.globl vector86
vector86:
  pushl $0
  102267:	6a 00                	push   $0x0
  pushl $86
  102269:	6a 56                	push   $0x56
  jmp __alltraps
  10226b:	e9 71 07 00 00       	jmp    1029e1 <__alltraps>

00102270 <vector87>:
.globl vector87
vector87:
  pushl $0
  102270:	6a 00                	push   $0x0
  pushl $87
  102272:	6a 57                	push   $0x57
  jmp __alltraps
  102274:	e9 68 07 00 00       	jmp    1029e1 <__alltraps>

00102279 <vector88>:
.globl vector88
vector88:
  pushl $0
  102279:	6a 00                	push   $0x0
  pushl $88
  10227b:	6a 58                	push   $0x58
  jmp __alltraps
  10227d:	e9 5f 07 00 00       	jmp    1029e1 <__alltraps>

00102282 <vector89>:
.globl vector89
vector89:
  pushl $0
  102282:	6a 00                	push   $0x0
  pushl $89
  102284:	6a 59                	push   $0x59
  jmp __alltraps
  102286:	e9 56 07 00 00       	jmp    1029e1 <__alltraps>

0010228b <vector90>:
.globl vector90
vector90:
  pushl $0
  10228b:	6a 00                	push   $0x0
  pushl $90
  10228d:	6a 5a                	push   $0x5a
  jmp __alltraps
  10228f:	e9 4d 07 00 00       	jmp    1029e1 <__alltraps>

00102294 <vector91>:
.globl vector91
vector91:
  pushl $0
  102294:	6a 00                	push   $0x0
  pushl $91
  102296:	6a 5b                	push   $0x5b
  jmp __alltraps
  102298:	e9 44 07 00 00       	jmp    1029e1 <__alltraps>

0010229d <vector92>:
.globl vector92
vector92:
  pushl $0
  10229d:	6a 00                	push   $0x0
  pushl $92
  10229f:	6a 5c                	push   $0x5c
  jmp __alltraps
  1022a1:	e9 3b 07 00 00       	jmp    1029e1 <__alltraps>

001022a6 <vector93>:
.globl vector93
vector93:
  pushl $0
  1022a6:	6a 00                	push   $0x0
  pushl $93
  1022a8:	6a 5d                	push   $0x5d
  jmp __alltraps
  1022aa:	e9 32 07 00 00       	jmp    1029e1 <__alltraps>

001022af <vector94>:
.globl vector94
vector94:
  pushl $0
  1022af:	6a 00                	push   $0x0
  pushl $94
  1022b1:	6a 5e                	push   $0x5e
  jmp __alltraps
  1022b3:	e9 29 07 00 00       	jmp    1029e1 <__alltraps>

001022b8 <vector95>:
.globl vector95
vector95:
  pushl $0
  1022b8:	6a 00                	push   $0x0
  pushl $95
  1022ba:	6a 5f                	push   $0x5f
  jmp __alltraps
  1022bc:	e9 20 07 00 00       	jmp    1029e1 <__alltraps>

001022c1 <vector96>:
.globl vector96
vector96:
  pushl $0
  1022c1:	6a 00                	push   $0x0
  pushl $96
  1022c3:	6a 60                	push   $0x60
  jmp __alltraps
  1022c5:	e9 17 07 00 00       	jmp    1029e1 <__alltraps>

001022ca <vector97>:
.globl vector97
vector97:
  pushl $0
  1022ca:	6a 00                	push   $0x0
  pushl $97
  1022cc:	6a 61                	push   $0x61
  jmp __alltraps
  1022ce:	e9 0e 07 00 00       	jmp    1029e1 <__alltraps>

001022d3 <vector98>:
.globl vector98
vector98:
  pushl $0
  1022d3:	6a 00                	push   $0x0
  pushl $98
  1022d5:	6a 62                	push   $0x62
  jmp __alltraps
  1022d7:	e9 05 07 00 00       	jmp    1029e1 <__alltraps>

001022dc <vector99>:
.globl vector99
vector99:
  pushl $0
  1022dc:	6a 00                	push   $0x0
  pushl $99
  1022de:	6a 63                	push   $0x63
  jmp __alltraps
  1022e0:	e9 fc 06 00 00       	jmp    1029e1 <__alltraps>

001022e5 <vector100>:
.globl vector100
vector100:
  pushl $0
  1022e5:	6a 00                	push   $0x0
  pushl $100
  1022e7:	6a 64                	push   $0x64
  jmp __alltraps
  1022e9:	e9 f3 06 00 00       	jmp    1029e1 <__alltraps>

001022ee <vector101>:
.globl vector101
vector101:
  pushl $0
  1022ee:	6a 00                	push   $0x0
  pushl $101
  1022f0:	6a 65                	push   $0x65
  jmp __alltraps
  1022f2:	e9 ea 06 00 00       	jmp    1029e1 <__alltraps>

001022f7 <vector102>:
.globl vector102
vector102:
  pushl $0
  1022f7:	6a 00                	push   $0x0
  pushl $102
  1022f9:	6a 66                	push   $0x66
  jmp __alltraps
  1022fb:	e9 e1 06 00 00       	jmp    1029e1 <__alltraps>

00102300 <vector103>:
.globl vector103
vector103:
  pushl $0
  102300:	6a 00                	push   $0x0
  pushl $103
  102302:	6a 67                	push   $0x67
  jmp __alltraps
  102304:	e9 d8 06 00 00       	jmp    1029e1 <__alltraps>

00102309 <vector104>:
.globl vector104
vector104:
  pushl $0
  102309:	6a 00                	push   $0x0
  pushl $104
  10230b:	6a 68                	push   $0x68
  jmp __alltraps
  10230d:	e9 cf 06 00 00       	jmp    1029e1 <__alltraps>

00102312 <vector105>:
.globl vector105
vector105:
  pushl $0
  102312:	6a 00                	push   $0x0
  pushl $105
  102314:	6a 69                	push   $0x69
  jmp __alltraps
  102316:	e9 c6 06 00 00       	jmp    1029e1 <__alltraps>

0010231b <vector106>:
.globl vector106
vector106:
  pushl $0
  10231b:	6a 00                	push   $0x0
  pushl $106
  10231d:	6a 6a                	push   $0x6a
  jmp __alltraps
  10231f:	e9 bd 06 00 00       	jmp    1029e1 <__alltraps>

00102324 <vector107>:
.globl vector107
vector107:
  pushl $0
  102324:	6a 00                	push   $0x0
  pushl $107
  102326:	6a 6b                	push   $0x6b
  jmp __alltraps
  102328:	e9 b4 06 00 00       	jmp    1029e1 <__alltraps>

0010232d <vector108>:
.globl vector108
vector108:
  pushl $0
  10232d:	6a 00                	push   $0x0
  pushl $108
  10232f:	6a 6c                	push   $0x6c
  jmp __alltraps
  102331:	e9 ab 06 00 00       	jmp    1029e1 <__alltraps>

00102336 <vector109>:
.globl vector109
vector109:
  pushl $0
  102336:	6a 00                	push   $0x0
  pushl $109
  102338:	6a 6d                	push   $0x6d
  jmp __alltraps
  10233a:	e9 a2 06 00 00       	jmp    1029e1 <__alltraps>

0010233f <vector110>:
.globl vector110
vector110:
  pushl $0
  10233f:	6a 00                	push   $0x0
  pushl $110
  102341:	6a 6e                	push   $0x6e
  jmp __alltraps
  102343:	e9 99 06 00 00       	jmp    1029e1 <__alltraps>

00102348 <vector111>:
.globl vector111
vector111:
  pushl $0
  102348:	6a 00                	push   $0x0
  pushl $111
  10234a:	6a 6f                	push   $0x6f
  jmp __alltraps
  10234c:	e9 90 06 00 00       	jmp    1029e1 <__alltraps>

00102351 <vector112>:
.globl vector112
vector112:
  pushl $0
  102351:	6a 00                	push   $0x0
  pushl $112
  102353:	6a 70                	push   $0x70
  jmp __alltraps
  102355:	e9 87 06 00 00       	jmp    1029e1 <__alltraps>

0010235a <vector113>:
.globl vector113
vector113:
  pushl $0
  10235a:	6a 00                	push   $0x0
  pushl $113
  10235c:	6a 71                	push   $0x71
  jmp __alltraps
  10235e:	e9 7e 06 00 00       	jmp    1029e1 <__alltraps>

00102363 <vector114>:
.globl vector114
vector114:
  pushl $0
  102363:	6a 00                	push   $0x0
  pushl $114
  102365:	6a 72                	push   $0x72
  jmp __alltraps
  102367:	e9 75 06 00 00       	jmp    1029e1 <__alltraps>

0010236c <vector115>:
.globl vector115
vector115:
  pushl $0
  10236c:	6a 00                	push   $0x0
  pushl $115
  10236e:	6a 73                	push   $0x73
  jmp __alltraps
  102370:	e9 6c 06 00 00       	jmp    1029e1 <__alltraps>

00102375 <vector116>:
.globl vector116
vector116:
  pushl $0
  102375:	6a 00                	push   $0x0
  pushl $116
  102377:	6a 74                	push   $0x74
  jmp __alltraps
  102379:	e9 63 06 00 00       	jmp    1029e1 <__alltraps>

0010237e <vector117>:
.globl vector117
vector117:
  pushl $0
  10237e:	6a 00                	push   $0x0
  pushl $117
  102380:	6a 75                	push   $0x75
  jmp __alltraps
  102382:	e9 5a 06 00 00       	jmp    1029e1 <__alltraps>

00102387 <vector118>:
.globl vector118
vector118:
  pushl $0
  102387:	6a 00                	push   $0x0
  pushl $118
  102389:	6a 76                	push   $0x76
  jmp __alltraps
  10238b:	e9 51 06 00 00       	jmp    1029e1 <__alltraps>

00102390 <vector119>:
.globl vector119
vector119:
  pushl $0
  102390:	6a 00                	push   $0x0
  pushl $119
  102392:	6a 77                	push   $0x77
  jmp __alltraps
  102394:	e9 48 06 00 00       	jmp    1029e1 <__alltraps>

00102399 <vector120>:
.globl vector120
vector120:
  pushl $0
  102399:	6a 00                	push   $0x0
  pushl $120
  10239b:	6a 78                	push   $0x78
  jmp __alltraps
  10239d:	e9 3f 06 00 00       	jmp    1029e1 <__alltraps>

001023a2 <vector121>:
.globl vector121
vector121:
  pushl $0
  1023a2:	6a 00                	push   $0x0
  pushl $121
  1023a4:	6a 79                	push   $0x79
  jmp __alltraps
  1023a6:	e9 36 06 00 00       	jmp    1029e1 <__alltraps>

001023ab <vector122>:
.globl vector122
vector122:
  pushl $0
  1023ab:	6a 00                	push   $0x0
  pushl $122
  1023ad:	6a 7a                	push   $0x7a
  jmp __alltraps
  1023af:	e9 2d 06 00 00       	jmp    1029e1 <__alltraps>

001023b4 <vector123>:
.globl vector123
vector123:
  pushl $0
  1023b4:	6a 00                	push   $0x0
  pushl $123
  1023b6:	6a 7b                	push   $0x7b
  jmp __alltraps
  1023b8:	e9 24 06 00 00       	jmp    1029e1 <__alltraps>

001023bd <vector124>:
.globl vector124
vector124:
  pushl $0
  1023bd:	6a 00                	push   $0x0
  pushl $124
  1023bf:	6a 7c                	push   $0x7c
  jmp __alltraps
  1023c1:	e9 1b 06 00 00       	jmp    1029e1 <__alltraps>

001023c6 <vector125>:
.globl vector125
vector125:
  pushl $0
  1023c6:	6a 00                	push   $0x0
  pushl $125
  1023c8:	6a 7d                	push   $0x7d
  jmp __alltraps
  1023ca:	e9 12 06 00 00       	jmp    1029e1 <__alltraps>

001023cf <vector126>:
.globl vector126
vector126:
  pushl $0
  1023cf:	6a 00                	push   $0x0
  pushl $126
  1023d1:	6a 7e                	push   $0x7e
  jmp __alltraps
  1023d3:	e9 09 06 00 00       	jmp    1029e1 <__alltraps>

001023d8 <vector127>:
.globl vector127
vector127:
  pushl $0
  1023d8:	6a 00                	push   $0x0
  pushl $127
  1023da:	6a 7f                	push   $0x7f
  jmp __alltraps
  1023dc:	e9 00 06 00 00       	jmp    1029e1 <__alltraps>

001023e1 <vector128>:
.globl vector128
vector128:
  pushl $0
  1023e1:	6a 00                	push   $0x0
  pushl $128
  1023e3:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  1023e8:	e9 f4 05 00 00       	jmp    1029e1 <__alltraps>

001023ed <vector129>:
.globl vector129
vector129:
  pushl $0
  1023ed:	6a 00                	push   $0x0
  pushl $129
  1023ef:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  1023f4:	e9 e8 05 00 00       	jmp    1029e1 <__alltraps>

001023f9 <vector130>:
.globl vector130
vector130:
  pushl $0
  1023f9:	6a 00                	push   $0x0
  pushl $130
  1023fb:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102400:	e9 dc 05 00 00       	jmp    1029e1 <__alltraps>

00102405 <vector131>:
.globl vector131
vector131:
  pushl $0
  102405:	6a 00                	push   $0x0
  pushl $131
  102407:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  10240c:	e9 d0 05 00 00       	jmp    1029e1 <__alltraps>

00102411 <vector132>:
.globl vector132
vector132:
  pushl $0
  102411:	6a 00                	push   $0x0
  pushl $132
  102413:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102418:	e9 c4 05 00 00       	jmp    1029e1 <__alltraps>

0010241d <vector133>:
.globl vector133
vector133:
  pushl $0
  10241d:	6a 00                	push   $0x0
  pushl $133
  10241f:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102424:	e9 b8 05 00 00       	jmp    1029e1 <__alltraps>

00102429 <vector134>:
.globl vector134
vector134:
  pushl $0
  102429:	6a 00                	push   $0x0
  pushl $134
  10242b:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102430:	e9 ac 05 00 00       	jmp    1029e1 <__alltraps>

00102435 <vector135>:
.globl vector135
vector135:
  pushl $0
  102435:	6a 00                	push   $0x0
  pushl $135
  102437:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  10243c:	e9 a0 05 00 00       	jmp    1029e1 <__alltraps>

00102441 <vector136>:
.globl vector136
vector136:
  pushl $0
  102441:	6a 00                	push   $0x0
  pushl $136
  102443:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102448:	e9 94 05 00 00       	jmp    1029e1 <__alltraps>

0010244d <vector137>:
.globl vector137
vector137:
  pushl $0
  10244d:	6a 00                	push   $0x0
  pushl $137
  10244f:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102454:	e9 88 05 00 00       	jmp    1029e1 <__alltraps>

00102459 <vector138>:
.globl vector138
vector138:
  pushl $0
  102459:	6a 00                	push   $0x0
  pushl $138
  10245b:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  102460:	e9 7c 05 00 00       	jmp    1029e1 <__alltraps>

00102465 <vector139>:
.globl vector139
vector139:
  pushl $0
  102465:	6a 00                	push   $0x0
  pushl $139
  102467:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10246c:	e9 70 05 00 00       	jmp    1029e1 <__alltraps>

00102471 <vector140>:
.globl vector140
vector140:
  pushl $0
  102471:	6a 00                	push   $0x0
  pushl $140
  102473:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102478:	e9 64 05 00 00       	jmp    1029e1 <__alltraps>

0010247d <vector141>:
.globl vector141
vector141:
  pushl $0
  10247d:	6a 00                	push   $0x0
  pushl $141
  10247f:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102484:	e9 58 05 00 00       	jmp    1029e1 <__alltraps>

00102489 <vector142>:
.globl vector142
vector142:
  pushl $0
  102489:	6a 00                	push   $0x0
  pushl $142
  10248b:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102490:	e9 4c 05 00 00       	jmp    1029e1 <__alltraps>

00102495 <vector143>:
.globl vector143
vector143:
  pushl $0
  102495:	6a 00                	push   $0x0
  pushl $143
  102497:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10249c:	e9 40 05 00 00       	jmp    1029e1 <__alltraps>

001024a1 <vector144>:
.globl vector144
vector144:
  pushl $0
  1024a1:	6a 00                	push   $0x0
  pushl $144
  1024a3:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1024a8:	e9 34 05 00 00       	jmp    1029e1 <__alltraps>

001024ad <vector145>:
.globl vector145
vector145:
  pushl $0
  1024ad:	6a 00                	push   $0x0
  pushl $145
  1024af:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1024b4:	e9 28 05 00 00       	jmp    1029e1 <__alltraps>

001024b9 <vector146>:
.globl vector146
vector146:
  pushl $0
  1024b9:	6a 00                	push   $0x0
  pushl $146
  1024bb:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1024c0:	e9 1c 05 00 00       	jmp    1029e1 <__alltraps>

001024c5 <vector147>:
.globl vector147
vector147:
  pushl $0
  1024c5:	6a 00                	push   $0x0
  pushl $147
  1024c7:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1024cc:	e9 10 05 00 00       	jmp    1029e1 <__alltraps>

001024d1 <vector148>:
.globl vector148
vector148:
  pushl $0
  1024d1:	6a 00                	push   $0x0
  pushl $148
  1024d3:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1024d8:	e9 04 05 00 00       	jmp    1029e1 <__alltraps>

001024dd <vector149>:
.globl vector149
vector149:
  pushl $0
  1024dd:	6a 00                	push   $0x0
  pushl $149
  1024df:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  1024e4:	e9 f8 04 00 00       	jmp    1029e1 <__alltraps>

001024e9 <vector150>:
.globl vector150
vector150:
  pushl $0
  1024e9:	6a 00                	push   $0x0
  pushl $150
  1024eb:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  1024f0:	e9 ec 04 00 00       	jmp    1029e1 <__alltraps>

001024f5 <vector151>:
.globl vector151
vector151:
  pushl $0
  1024f5:	6a 00                	push   $0x0
  pushl $151
  1024f7:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  1024fc:	e9 e0 04 00 00       	jmp    1029e1 <__alltraps>

00102501 <vector152>:
.globl vector152
vector152:
  pushl $0
  102501:	6a 00                	push   $0x0
  pushl $152
  102503:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102508:	e9 d4 04 00 00       	jmp    1029e1 <__alltraps>

0010250d <vector153>:
.globl vector153
vector153:
  pushl $0
  10250d:	6a 00                	push   $0x0
  pushl $153
  10250f:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102514:	e9 c8 04 00 00       	jmp    1029e1 <__alltraps>

00102519 <vector154>:
.globl vector154
vector154:
  pushl $0
  102519:	6a 00                	push   $0x0
  pushl $154
  10251b:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102520:	e9 bc 04 00 00       	jmp    1029e1 <__alltraps>

00102525 <vector155>:
.globl vector155
vector155:
  pushl $0
  102525:	6a 00                	push   $0x0
  pushl $155
  102527:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  10252c:	e9 b0 04 00 00       	jmp    1029e1 <__alltraps>

00102531 <vector156>:
.globl vector156
vector156:
  pushl $0
  102531:	6a 00                	push   $0x0
  pushl $156
  102533:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102538:	e9 a4 04 00 00       	jmp    1029e1 <__alltraps>

0010253d <vector157>:
.globl vector157
vector157:
  pushl $0
  10253d:	6a 00                	push   $0x0
  pushl $157
  10253f:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102544:	e9 98 04 00 00       	jmp    1029e1 <__alltraps>

00102549 <vector158>:
.globl vector158
vector158:
  pushl $0
  102549:	6a 00                	push   $0x0
  pushl $158
  10254b:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102550:	e9 8c 04 00 00       	jmp    1029e1 <__alltraps>

00102555 <vector159>:
.globl vector159
vector159:
  pushl $0
  102555:	6a 00                	push   $0x0
  pushl $159
  102557:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10255c:	e9 80 04 00 00       	jmp    1029e1 <__alltraps>

00102561 <vector160>:
.globl vector160
vector160:
  pushl $0
  102561:	6a 00                	push   $0x0
  pushl $160
  102563:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102568:	e9 74 04 00 00       	jmp    1029e1 <__alltraps>

0010256d <vector161>:
.globl vector161
vector161:
  pushl $0
  10256d:	6a 00                	push   $0x0
  pushl $161
  10256f:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102574:	e9 68 04 00 00       	jmp    1029e1 <__alltraps>

00102579 <vector162>:
.globl vector162
vector162:
  pushl $0
  102579:	6a 00                	push   $0x0
  pushl $162
  10257b:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  102580:	e9 5c 04 00 00       	jmp    1029e1 <__alltraps>

00102585 <vector163>:
.globl vector163
vector163:
  pushl $0
  102585:	6a 00                	push   $0x0
  pushl $163
  102587:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10258c:	e9 50 04 00 00       	jmp    1029e1 <__alltraps>

00102591 <vector164>:
.globl vector164
vector164:
  pushl $0
  102591:	6a 00                	push   $0x0
  pushl $164
  102593:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102598:	e9 44 04 00 00       	jmp    1029e1 <__alltraps>

0010259d <vector165>:
.globl vector165
vector165:
  pushl $0
  10259d:	6a 00                	push   $0x0
  pushl $165
  10259f:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1025a4:	e9 38 04 00 00       	jmp    1029e1 <__alltraps>

001025a9 <vector166>:
.globl vector166
vector166:
  pushl $0
  1025a9:	6a 00                	push   $0x0
  pushl $166
  1025ab:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1025b0:	e9 2c 04 00 00       	jmp    1029e1 <__alltraps>

001025b5 <vector167>:
.globl vector167
vector167:
  pushl $0
  1025b5:	6a 00                	push   $0x0
  pushl $167
  1025b7:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1025bc:	e9 20 04 00 00       	jmp    1029e1 <__alltraps>

001025c1 <vector168>:
.globl vector168
vector168:
  pushl $0
  1025c1:	6a 00                	push   $0x0
  pushl $168
  1025c3:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1025c8:	e9 14 04 00 00       	jmp    1029e1 <__alltraps>

001025cd <vector169>:
.globl vector169
vector169:
  pushl $0
  1025cd:	6a 00                	push   $0x0
  pushl $169
  1025cf:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1025d4:	e9 08 04 00 00       	jmp    1029e1 <__alltraps>

001025d9 <vector170>:
.globl vector170
vector170:
  pushl $0
  1025d9:	6a 00                	push   $0x0
  pushl $170
  1025db:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1025e0:	e9 fc 03 00 00       	jmp    1029e1 <__alltraps>

001025e5 <vector171>:
.globl vector171
vector171:
  pushl $0
  1025e5:	6a 00                	push   $0x0
  pushl $171
  1025e7:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  1025ec:	e9 f0 03 00 00       	jmp    1029e1 <__alltraps>

001025f1 <vector172>:
.globl vector172
vector172:
  pushl $0
  1025f1:	6a 00                	push   $0x0
  pushl $172
  1025f3:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  1025f8:	e9 e4 03 00 00       	jmp    1029e1 <__alltraps>

001025fd <vector173>:
.globl vector173
vector173:
  pushl $0
  1025fd:	6a 00                	push   $0x0
  pushl $173
  1025ff:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102604:	e9 d8 03 00 00       	jmp    1029e1 <__alltraps>

00102609 <vector174>:
.globl vector174
vector174:
  pushl $0
  102609:	6a 00                	push   $0x0
  pushl $174
  10260b:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102610:	e9 cc 03 00 00       	jmp    1029e1 <__alltraps>

00102615 <vector175>:
.globl vector175
vector175:
  pushl $0
  102615:	6a 00                	push   $0x0
  pushl $175
  102617:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10261c:	e9 c0 03 00 00       	jmp    1029e1 <__alltraps>

00102621 <vector176>:
.globl vector176
vector176:
  pushl $0
  102621:	6a 00                	push   $0x0
  pushl $176
  102623:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102628:	e9 b4 03 00 00       	jmp    1029e1 <__alltraps>

0010262d <vector177>:
.globl vector177
vector177:
  pushl $0
  10262d:	6a 00                	push   $0x0
  pushl $177
  10262f:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102634:	e9 a8 03 00 00       	jmp    1029e1 <__alltraps>

00102639 <vector178>:
.globl vector178
vector178:
  pushl $0
  102639:	6a 00                	push   $0x0
  pushl $178
  10263b:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102640:	e9 9c 03 00 00       	jmp    1029e1 <__alltraps>

00102645 <vector179>:
.globl vector179
vector179:
  pushl $0
  102645:	6a 00                	push   $0x0
  pushl $179
  102647:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10264c:	e9 90 03 00 00       	jmp    1029e1 <__alltraps>

00102651 <vector180>:
.globl vector180
vector180:
  pushl $0
  102651:	6a 00                	push   $0x0
  pushl $180
  102653:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102658:	e9 84 03 00 00       	jmp    1029e1 <__alltraps>

0010265d <vector181>:
.globl vector181
vector181:
  pushl $0
  10265d:	6a 00                	push   $0x0
  pushl $181
  10265f:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102664:	e9 78 03 00 00       	jmp    1029e1 <__alltraps>

00102669 <vector182>:
.globl vector182
vector182:
  pushl $0
  102669:	6a 00                	push   $0x0
  pushl $182
  10266b:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  102670:	e9 6c 03 00 00       	jmp    1029e1 <__alltraps>

00102675 <vector183>:
.globl vector183
vector183:
  pushl $0
  102675:	6a 00                	push   $0x0
  pushl $183
  102677:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10267c:	e9 60 03 00 00       	jmp    1029e1 <__alltraps>

00102681 <vector184>:
.globl vector184
vector184:
  pushl $0
  102681:	6a 00                	push   $0x0
  pushl $184
  102683:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102688:	e9 54 03 00 00       	jmp    1029e1 <__alltraps>

0010268d <vector185>:
.globl vector185
vector185:
  pushl $0
  10268d:	6a 00                	push   $0x0
  pushl $185
  10268f:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102694:	e9 48 03 00 00       	jmp    1029e1 <__alltraps>

00102699 <vector186>:
.globl vector186
vector186:
  pushl $0
  102699:	6a 00                	push   $0x0
  pushl $186
  10269b:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1026a0:	e9 3c 03 00 00       	jmp    1029e1 <__alltraps>

001026a5 <vector187>:
.globl vector187
vector187:
  pushl $0
  1026a5:	6a 00                	push   $0x0
  pushl $187
  1026a7:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1026ac:	e9 30 03 00 00       	jmp    1029e1 <__alltraps>

001026b1 <vector188>:
.globl vector188
vector188:
  pushl $0
  1026b1:	6a 00                	push   $0x0
  pushl $188
  1026b3:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1026b8:	e9 24 03 00 00       	jmp    1029e1 <__alltraps>

001026bd <vector189>:
.globl vector189
vector189:
  pushl $0
  1026bd:	6a 00                	push   $0x0
  pushl $189
  1026bf:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1026c4:	e9 18 03 00 00       	jmp    1029e1 <__alltraps>

001026c9 <vector190>:
.globl vector190
vector190:
  pushl $0
  1026c9:	6a 00                	push   $0x0
  pushl $190
  1026cb:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1026d0:	e9 0c 03 00 00       	jmp    1029e1 <__alltraps>

001026d5 <vector191>:
.globl vector191
vector191:
  pushl $0
  1026d5:	6a 00                	push   $0x0
  pushl $191
  1026d7:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1026dc:	e9 00 03 00 00       	jmp    1029e1 <__alltraps>

001026e1 <vector192>:
.globl vector192
vector192:
  pushl $0
  1026e1:	6a 00                	push   $0x0
  pushl $192
  1026e3:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  1026e8:	e9 f4 02 00 00       	jmp    1029e1 <__alltraps>

001026ed <vector193>:
.globl vector193
vector193:
  pushl $0
  1026ed:	6a 00                	push   $0x0
  pushl $193
  1026ef:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  1026f4:	e9 e8 02 00 00       	jmp    1029e1 <__alltraps>

001026f9 <vector194>:
.globl vector194
vector194:
  pushl $0
  1026f9:	6a 00                	push   $0x0
  pushl $194
  1026fb:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102700:	e9 dc 02 00 00       	jmp    1029e1 <__alltraps>

00102705 <vector195>:
.globl vector195
vector195:
  pushl $0
  102705:	6a 00                	push   $0x0
  pushl $195
  102707:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10270c:	e9 d0 02 00 00       	jmp    1029e1 <__alltraps>

00102711 <vector196>:
.globl vector196
vector196:
  pushl $0
  102711:	6a 00                	push   $0x0
  pushl $196
  102713:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102718:	e9 c4 02 00 00       	jmp    1029e1 <__alltraps>

0010271d <vector197>:
.globl vector197
vector197:
  pushl $0
  10271d:	6a 00                	push   $0x0
  pushl $197
  10271f:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102724:	e9 b8 02 00 00       	jmp    1029e1 <__alltraps>

00102729 <vector198>:
.globl vector198
vector198:
  pushl $0
  102729:	6a 00                	push   $0x0
  pushl $198
  10272b:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102730:	e9 ac 02 00 00       	jmp    1029e1 <__alltraps>

00102735 <vector199>:
.globl vector199
vector199:
  pushl $0
  102735:	6a 00                	push   $0x0
  pushl $199
  102737:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  10273c:	e9 a0 02 00 00       	jmp    1029e1 <__alltraps>

00102741 <vector200>:
.globl vector200
vector200:
  pushl $0
  102741:	6a 00                	push   $0x0
  pushl $200
  102743:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102748:	e9 94 02 00 00       	jmp    1029e1 <__alltraps>

0010274d <vector201>:
.globl vector201
vector201:
  pushl $0
  10274d:	6a 00                	push   $0x0
  pushl $201
  10274f:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102754:	e9 88 02 00 00       	jmp    1029e1 <__alltraps>

00102759 <vector202>:
.globl vector202
vector202:
  pushl $0
  102759:	6a 00                	push   $0x0
  pushl $202
  10275b:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  102760:	e9 7c 02 00 00       	jmp    1029e1 <__alltraps>

00102765 <vector203>:
.globl vector203
vector203:
  pushl $0
  102765:	6a 00                	push   $0x0
  pushl $203
  102767:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10276c:	e9 70 02 00 00       	jmp    1029e1 <__alltraps>

00102771 <vector204>:
.globl vector204
vector204:
  pushl $0
  102771:	6a 00                	push   $0x0
  pushl $204
  102773:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102778:	e9 64 02 00 00       	jmp    1029e1 <__alltraps>

0010277d <vector205>:
.globl vector205
vector205:
  pushl $0
  10277d:	6a 00                	push   $0x0
  pushl $205
  10277f:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102784:	e9 58 02 00 00       	jmp    1029e1 <__alltraps>

00102789 <vector206>:
.globl vector206
vector206:
  pushl $0
  102789:	6a 00                	push   $0x0
  pushl $206
  10278b:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102790:	e9 4c 02 00 00       	jmp    1029e1 <__alltraps>

00102795 <vector207>:
.globl vector207
vector207:
  pushl $0
  102795:	6a 00                	push   $0x0
  pushl $207
  102797:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10279c:	e9 40 02 00 00       	jmp    1029e1 <__alltraps>

001027a1 <vector208>:
.globl vector208
vector208:
  pushl $0
  1027a1:	6a 00                	push   $0x0
  pushl $208
  1027a3:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1027a8:	e9 34 02 00 00       	jmp    1029e1 <__alltraps>

001027ad <vector209>:
.globl vector209
vector209:
  pushl $0
  1027ad:	6a 00                	push   $0x0
  pushl $209
  1027af:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1027b4:	e9 28 02 00 00       	jmp    1029e1 <__alltraps>

001027b9 <vector210>:
.globl vector210
vector210:
  pushl $0
  1027b9:	6a 00                	push   $0x0
  pushl $210
  1027bb:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1027c0:	e9 1c 02 00 00       	jmp    1029e1 <__alltraps>

001027c5 <vector211>:
.globl vector211
vector211:
  pushl $0
  1027c5:	6a 00                	push   $0x0
  pushl $211
  1027c7:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1027cc:	e9 10 02 00 00       	jmp    1029e1 <__alltraps>

001027d1 <vector212>:
.globl vector212
vector212:
  pushl $0
  1027d1:	6a 00                	push   $0x0
  pushl $212
  1027d3:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1027d8:	e9 04 02 00 00       	jmp    1029e1 <__alltraps>

001027dd <vector213>:
.globl vector213
vector213:
  pushl $0
  1027dd:	6a 00                	push   $0x0
  pushl $213
  1027df:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  1027e4:	e9 f8 01 00 00       	jmp    1029e1 <__alltraps>

001027e9 <vector214>:
.globl vector214
vector214:
  pushl $0
  1027e9:	6a 00                	push   $0x0
  pushl $214
  1027eb:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  1027f0:	e9 ec 01 00 00       	jmp    1029e1 <__alltraps>

001027f5 <vector215>:
.globl vector215
vector215:
  pushl $0
  1027f5:	6a 00                	push   $0x0
  pushl $215
  1027f7:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  1027fc:	e9 e0 01 00 00       	jmp    1029e1 <__alltraps>

00102801 <vector216>:
.globl vector216
vector216:
  pushl $0
  102801:	6a 00                	push   $0x0
  pushl $216
  102803:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102808:	e9 d4 01 00 00       	jmp    1029e1 <__alltraps>

0010280d <vector217>:
.globl vector217
vector217:
  pushl $0
  10280d:	6a 00                	push   $0x0
  pushl $217
  10280f:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102814:	e9 c8 01 00 00       	jmp    1029e1 <__alltraps>

00102819 <vector218>:
.globl vector218
vector218:
  pushl $0
  102819:	6a 00                	push   $0x0
  pushl $218
  10281b:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102820:	e9 bc 01 00 00       	jmp    1029e1 <__alltraps>

00102825 <vector219>:
.globl vector219
vector219:
  pushl $0
  102825:	6a 00                	push   $0x0
  pushl $219
  102827:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  10282c:	e9 b0 01 00 00       	jmp    1029e1 <__alltraps>

00102831 <vector220>:
.globl vector220
vector220:
  pushl $0
  102831:	6a 00                	push   $0x0
  pushl $220
  102833:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102838:	e9 a4 01 00 00       	jmp    1029e1 <__alltraps>

0010283d <vector221>:
.globl vector221
vector221:
  pushl $0
  10283d:	6a 00                	push   $0x0
  pushl $221
  10283f:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102844:	e9 98 01 00 00       	jmp    1029e1 <__alltraps>

00102849 <vector222>:
.globl vector222
vector222:
  pushl $0
  102849:	6a 00                	push   $0x0
  pushl $222
  10284b:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102850:	e9 8c 01 00 00       	jmp    1029e1 <__alltraps>

00102855 <vector223>:
.globl vector223
vector223:
  pushl $0
  102855:	6a 00                	push   $0x0
  pushl $223
  102857:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10285c:	e9 80 01 00 00       	jmp    1029e1 <__alltraps>

00102861 <vector224>:
.globl vector224
vector224:
  pushl $0
  102861:	6a 00                	push   $0x0
  pushl $224
  102863:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102868:	e9 74 01 00 00       	jmp    1029e1 <__alltraps>

0010286d <vector225>:
.globl vector225
vector225:
  pushl $0
  10286d:	6a 00                	push   $0x0
  pushl $225
  10286f:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102874:	e9 68 01 00 00       	jmp    1029e1 <__alltraps>

00102879 <vector226>:
.globl vector226
vector226:
  pushl $0
  102879:	6a 00                	push   $0x0
  pushl $226
  10287b:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102880:	e9 5c 01 00 00       	jmp    1029e1 <__alltraps>

00102885 <vector227>:
.globl vector227
vector227:
  pushl $0
  102885:	6a 00                	push   $0x0
  pushl $227
  102887:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10288c:	e9 50 01 00 00       	jmp    1029e1 <__alltraps>

00102891 <vector228>:
.globl vector228
vector228:
  pushl $0
  102891:	6a 00                	push   $0x0
  pushl $228
  102893:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102898:	e9 44 01 00 00       	jmp    1029e1 <__alltraps>

0010289d <vector229>:
.globl vector229
vector229:
  pushl $0
  10289d:	6a 00                	push   $0x0
  pushl $229
  10289f:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1028a4:	e9 38 01 00 00       	jmp    1029e1 <__alltraps>

001028a9 <vector230>:
.globl vector230
vector230:
  pushl $0
  1028a9:	6a 00                	push   $0x0
  pushl $230
  1028ab:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1028b0:	e9 2c 01 00 00       	jmp    1029e1 <__alltraps>

001028b5 <vector231>:
.globl vector231
vector231:
  pushl $0
  1028b5:	6a 00                	push   $0x0
  pushl $231
  1028b7:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1028bc:	e9 20 01 00 00       	jmp    1029e1 <__alltraps>

001028c1 <vector232>:
.globl vector232
vector232:
  pushl $0
  1028c1:	6a 00                	push   $0x0
  pushl $232
  1028c3:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  1028c8:	e9 14 01 00 00       	jmp    1029e1 <__alltraps>

001028cd <vector233>:
.globl vector233
vector233:
  pushl $0
  1028cd:	6a 00                	push   $0x0
  pushl $233
  1028cf:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  1028d4:	e9 08 01 00 00       	jmp    1029e1 <__alltraps>

001028d9 <vector234>:
.globl vector234
vector234:
  pushl $0
  1028d9:	6a 00                	push   $0x0
  pushl $234
  1028db:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  1028e0:	e9 fc 00 00 00       	jmp    1029e1 <__alltraps>

001028e5 <vector235>:
.globl vector235
vector235:
  pushl $0
  1028e5:	6a 00                	push   $0x0
  pushl $235
  1028e7:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  1028ec:	e9 f0 00 00 00       	jmp    1029e1 <__alltraps>

001028f1 <vector236>:
.globl vector236
vector236:
  pushl $0
  1028f1:	6a 00                	push   $0x0
  pushl $236
  1028f3:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  1028f8:	e9 e4 00 00 00       	jmp    1029e1 <__alltraps>

001028fd <vector237>:
.globl vector237
vector237:
  pushl $0
  1028fd:	6a 00                	push   $0x0
  pushl $237
  1028ff:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102904:	e9 d8 00 00 00       	jmp    1029e1 <__alltraps>

00102909 <vector238>:
.globl vector238
vector238:
  pushl $0
  102909:	6a 00                	push   $0x0
  pushl $238
  10290b:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102910:	e9 cc 00 00 00       	jmp    1029e1 <__alltraps>

00102915 <vector239>:
.globl vector239
vector239:
  pushl $0
  102915:	6a 00                	push   $0x0
  pushl $239
  102917:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  10291c:	e9 c0 00 00 00       	jmp    1029e1 <__alltraps>

00102921 <vector240>:
.globl vector240
vector240:
  pushl $0
  102921:	6a 00                	push   $0x0
  pushl $240
  102923:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102928:	e9 b4 00 00 00       	jmp    1029e1 <__alltraps>

0010292d <vector241>:
.globl vector241
vector241:
  pushl $0
  10292d:	6a 00                	push   $0x0
  pushl $241
  10292f:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102934:	e9 a8 00 00 00       	jmp    1029e1 <__alltraps>

00102939 <vector242>:
.globl vector242
vector242:
  pushl $0
  102939:	6a 00                	push   $0x0
  pushl $242
  10293b:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102940:	e9 9c 00 00 00       	jmp    1029e1 <__alltraps>

00102945 <vector243>:
.globl vector243
vector243:
  pushl $0
  102945:	6a 00                	push   $0x0
  pushl $243
  102947:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  10294c:	e9 90 00 00 00       	jmp    1029e1 <__alltraps>

00102951 <vector244>:
.globl vector244
vector244:
  pushl $0
  102951:	6a 00                	push   $0x0
  pushl $244
  102953:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102958:	e9 84 00 00 00       	jmp    1029e1 <__alltraps>

0010295d <vector245>:
.globl vector245
vector245:
  pushl $0
  10295d:	6a 00                	push   $0x0
  pushl $245
  10295f:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102964:	e9 78 00 00 00       	jmp    1029e1 <__alltraps>

00102969 <vector246>:
.globl vector246
vector246:
  pushl $0
  102969:	6a 00                	push   $0x0
  pushl $246
  10296b:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102970:	e9 6c 00 00 00       	jmp    1029e1 <__alltraps>

00102975 <vector247>:
.globl vector247
vector247:
  pushl $0
  102975:	6a 00                	push   $0x0
  pushl $247
  102977:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  10297c:	e9 60 00 00 00       	jmp    1029e1 <__alltraps>

00102981 <vector248>:
.globl vector248
vector248:
  pushl $0
  102981:	6a 00                	push   $0x0
  pushl $248
  102983:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102988:	e9 54 00 00 00       	jmp    1029e1 <__alltraps>

0010298d <vector249>:
.globl vector249
vector249:
  pushl $0
  10298d:	6a 00                	push   $0x0
  pushl $249
  10298f:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102994:	e9 48 00 00 00       	jmp    1029e1 <__alltraps>

00102999 <vector250>:
.globl vector250
vector250:
  pushl $0
  102999:	6a 00                	push   $0x0
  pushl $250
  10299b:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1029a0:	e9 3c 00 00 00       	jmp    1029e1 <__alltraps>

001029a5 <vector251>:
.globl vector251
vector251:
  pushl $0
  1029a5:	6a 00                	push   $0x0
  pushl $251
  1029a7:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1029ac:	e9 30 00 00 00       	jmp    1029e1 <__alltraps>

001029b1 <vector252>:
.globl vector252
vector252:
  pushl $0
  1029b1:	6a 00                	push   $0x0
  pushl $252
  1029b3:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1029b8:	e9 24 00 00 00       	jmp    1029e1 <__alltraps>

001029bd <vector253>:
.globl vector253
vector253:
  pushl $0
  1029bd:	6a 00                	push   $0x0
  pushl $253
  1029bf:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  1029c4:	e9 18 00 00 00       	jmp    1029e1 <__alltraps>

001029c9 <vector254>:
.globl vector254
vector254:
  pushl $0
  1029c9:	6a 00                	push   $0x0
  pushl $254
  1029cb:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  1029d0:	e9 0c 00 00 00       	jmp    1029e1 <__alltraps>

001029d5 <vector255>:
.globl vector255
vector255:
  pushl $0
  1029d5:	6a 00                	push   $0x0
  pushl $255
  1029d7:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  1029dc:	e9 00 00 00 00       	jmp    1029e1 <__alltraps>

001029e1 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  1029e1:	1e                   	push   %ds
    pushl %es
  1029e2:	06                   	push   %es
    pushl %fs
  1029e3:	0f a0                	push   %fs
    pushl %gs
  1029e5:	0f a8                	push   %gs
    pushal
  1029e7:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  1029e8:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  1029ed:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  1029ef:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  1029f1:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  1029f2:	e8 60 f5 ff ff       	call   101f57 <trap>

    # pop the pushed stack pointer
    popl %esp
  1029f7:	5c                   	pop    %esp

001029f8 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  1029f8:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  1029f9:	0f a9                	pop    %gs
    popl %fs
  1029fb:	0f a1                	pop    %fs
    popl %es
  1029fd:	07                   	pop    %es
    popl %ds
  1029fe:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  1029ff:	83 c4 08             	add    $0x8,%esp
    iret
  102a02:	cf                   	iret   

00102a03 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102a03:	55                   	push   %ebp
  102a04:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102a06:	8b 45 08             	mov    0x8(%ebp),%eax
  102a09:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102a0c:	b8 23 00 00 00       	mov    $0x23,%eax
  102a11:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102a13:	b8 23 00 00 00       	mov    $0x23,%eax
  102a18:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a1a:	b8 10 00 00 00       	mov    $0x10,%eax
  102a1f:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a21:	b8 10 00 00 00       	mov    $0x10,%eax
  102a26:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a28:	b8 10 00 00 00       	mov    $0x10,%eax
  102a2d:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a2f:	ea 36 2a 10 00 08 00 	ljmp   $0x8,$0x102a36
}
  102a36:	90                   	nop
  102a37:	5d                   	pop    %ebp
  102a38:	c3                   	ret    

00102a39 <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a39:	f3 0f 1e fb          	endbr32 
  102a3d:	55                   	push   %ebp
  102a3e:	89 e5                	mov    %esp,%ebp
  102a40:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102a43:	b8 20 09 11 00       	mov    $0x110920,%eax
  102a48:	05 00 04 00 00       	add    $0x400,%eax
  102a4d:	a3 a4 08 11 00       	mov    %eax,0x1108a4
    ts.ts_ss0 = KERNEL_DS;
  102a52:	66 c7 05 a8 08 11 00 	movw   $0x10,0x1108a8
  102a59:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  102a5b:	66 c7 05 08 fa 10 00 	movw   $0x68,0x10fa08
  102a62:	68 00 
  102a64:	b8 a0 08 11 00       	mov    $0x1108a0,%eax
  102a69:	0f b7 c0             	movzwl %ax,%eax
  102a6c:	66 a3 0a fa 10 00    	mov    %ax,0x10fa0a
  102a72:	b8 a0 08 11 00       	mov    $0x1108a0,%eax
  102a77:	c1 e8 10             	shr    $0x10,%eax
  102a7a:	a2 0c fa 10 00       	mov    %al,0x10fa0c
  102a7f:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102a86:	24 f0                	and    $0xf0,%al
  102a88:	0c 09                	or     $0x9,%al
  102a8a:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102a8f:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102a96:	0c 10                	or     $0x10,%al
  102a98:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102a9d:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102aa4:	24 9f                	and    $0x9f,%al
  102aa6:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102aab:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102ab2:	0c 80                	or     $0x80,%al
  102ab4:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102ab9:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102ac0:	24 f0                	and    $0xf0,%al
  102ac2:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102ac7:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102ace:	24 ef                	and    $0xef,%al
  102ad0:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102ad5:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102adc:	24 df                	and    $0xdf,%al
  102ade:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102ae3:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102aea:	0c 40                	or     $0x40,%al
  102aec:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102af1:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102af8:	24 7f                	and    $0x7f,%al
  102afa:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102aff:	b8 a0 08 11 00       	mov    $0x1108a0,%eax
  102b04:	c1 e8 18             	shr    $0x18,%eax
  102b07:	a2 0f fa 10 00       	mov    %al,0x10fa0f
    gdt[SEG_TSS].sd_s = 0;
  102b0c:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102b13:	24 ef                	and    $0xef,%al
  102b15:	a2 0d fa 10 00       	mov    %al,0x10fa0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102b1a:	c7 04 24 10 fa 10 00 	movl   $0x10fa10,(%esp)
  102b21:	e8 dd fe ff ff       	call   102a03 <lgdt>
  102b26:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102b2c:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b30:	0f 00 d8             	ltr    %ax
}
  102b33:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  102b34:	90                   	nop
  102b35:	c9                   	leave  
  102b36:	c3                   	ret    

00102b37 <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102b37:	f3 0f 1e fb          	endbr32 
  102b3b:	55                   	push   %ebp
  102b3c:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102b3e:	e8 f6 fe ff ff       	call   102a39 <gdt_init>
}
  102b43:	90                   	nop
  102b44:	5d                   	pop    %ebp
  102b45:	c3                   	ret    

00102b46 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102b46:	f3 0f 1e fb          	endbr32 
  102b4a:	55                   	push   %ebp
  102b4b:	89 e5                	mov    %esp,%ebp
  102b4d:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102b50:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102b57:	eb 03                	jmp    102b5c <strlen+0x16>
        cnt ++;
  102b59:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  102b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  102b5f:	8d 50 01             	lea    0x1(%eax),%edx
  102b62:	89 55 08             	mov    %edx,0x8(%ebp)
  102b65:	0f b6 00             	movzbl (%eax),%eax
  102b68:	84 c0                	test   %al,%al
  102b6a:	75 ed                	jne    102b59 <strlen+0x13>
    }
    return cnt;
  102b6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102b6f:	c9                   	leave  
  102b70:	c3                   	ret    

00102b71 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  102b71:	f3 0f 1e fb          	endbr32 
  102b75:	55                   	push   %ebp
  102b76:	89 e5                	mov    %esp,%ebp
  102b78:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102b7b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102b82:	eb 03                	jmp    102b87 <strnlen+0x16>
        cnt ++;
  102b84:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102b87:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102b8a:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102b8d:	73 10                	jae    102b9f <strnlen+0x2e>
  102b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  102b92:	8d 50 01             	lea    0x1(%eax),%edx
  102b95:	89 55 08             	mov    %edx,0x8(%ebp)
  102b98:	0f b6 00             	movzbl (%eax),%eax
  102b9b:	84 c0                	test   %al,%al
  102b9d:	75 e5                	jne    102b84 <strnlen+0x13>
    }
    return cnt;
  102b9f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102ba2:	c9                   	leave  
  102ba3:	c3                   	ret    

00102ba4 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  102ba4:	f3 0f 1e fb          	endbr32 
  102ba8:	55                   	push   %ebp
  102ba9:	89 e5                	mov    %esp,%ebp
  102bab:	57                   	push   %edi
  102bac:	56                   	push   %esi
  102bad:	83 ec 20             	sub    $0x20,%esp
  102bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  102bb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102bb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  102bbc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bc2:	89 d1                	mov    %edx,%ecx
  102bc4:	89 c2                	mov    %eax,%edx
  102bc6:	89 ce                	mov    %ecx,%esi
  102bc8:	89 d7                	mov    %edx,%edi
  102bca:	ac                   	lods   %ds:(%esi),%al
  102bcb:	aa                   	stos   %al,%es:(%edi)
  102bcc:	84 c0                	test   %al,%al
  102bce:	75 fa                	jne    102bca <strcpy+0x26>
  102bd0:	89 fa                	mov    %edi,%edx
  102bd2:	89 f1                	mov    %esi,%ecx
  102bd4:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102bd7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  102bda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  102bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  102be0:	83 c4 20             	add    $0x20,%esp
  102be3:	5e                   	pop    %esi
  102be4:	5f                   	pop    %edi
  102be5:	5d                   	pop    %ebp
  102be6:	c3                   	ret    

00102be7 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  102be7:	f3 0f 1e fb          	endbr32 
  102beb:	55                   	push   %ebp
  102bec:	89 e5                	mov    %esp,%ebp
  102bee:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  102bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  102bf4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  102bf7:	eb 1e                	jmp    102c17 <strncpy+0x30>
        if ((*p = *src) != '\0') {
  102bf9:	8b 45 0c             	mov    0xc(%ebp),%eax
  102bfc:	0f b6 10             	movzbl (%eax),%edx
  102bff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102c02:	88 10                	mov    %dl,(%eax)
  102c04:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102c07:	0f b6 00             	movzbl (%eax),%eax
  102c0a:	84 c0                	test   %al,%al
  102c0c:	74 03                	je     102c11 <strncpy+0x2a>
            src ++;
  102c0e:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  102c11:	ff 45 fc             	incl   -0x4(%ebp)
  102c14:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  102c17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102c1b:	75 dc                	jne    102bf9 <strncpy+0x12>
    }
    return dst;
  102c1d:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102c20:	c9                   	leave  
  102c21:	c3                   	ret    

00102c22 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102c22:	f3 0f 1e fb          	endbr32 
  102c26:	55                   	push   %ebp
  102c27:	89 e5                	mov    %esp,%ebp
  102c29:	57                   	push   %edi
  102c2a:	56                   	push   %esi
  102c2b:	83 ec 20             	sub    $0x20,%esp
  102c2e:	8b 45 08             	mov    0x8(%ebp),%eax
  102c31:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102c34:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c37:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  102c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102c40:	89 d1                	mov    %edx,%ecx
  102c42:	89 c2                	mov    %eax,%edx
  102c44:	89 ce                	mov    %ecx,%esi
  102c46:	89 d7                	mov    %edx,%edi
  102c48:	ac                   	lods   %ds:(%esi),%al
  102c49:	ae                   	scas   %es:(%edi),%al
  102c4a:	75 08                	jne    102c54 <strcmp+0x32>
  102c4c:	84 c0                	test   %al,%al
  102c4e:	75 f8                	jne    102c48 <strcmp+0x26>
  102c50:	31 c0                	xor    %eax,%eax
  102c52:	eb 04                	jmp    102c58 <strcmp+0x36>
  102c54:	19 c0                	sbb    %eax,%eax
  102c56:	0c 01                	or     $0x1,%al
  102c58:	89 fa                	mov    %edi,%edx
  102c5a:	89 f1                	mov    %esi,%ecx
  102c5c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102c5f:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102c62:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  102c65:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102c68:	83 c4 20             	add    $0x20,%esp
  102c6b:	5e                   	pop    %esi
  102c6c:	5f                   	pop    %edi
  102c6d:	5d                   	pop    %ebp
  102c6e:	c3                   	ret    

00102c6f <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102c6f:	f3 0f 1e fb          	endbr32 
  102c73:	55                   	push   %ebp
  102c74:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102c76:	eb 09                	jmp    102c81 <strncmp+0x12>
        n --, s1 ++, s2 ++;
  102c78:	ff 4d 10             	decl   0x10(%ebp)
  102c7b:	ff 45 08             	incl   0x8(%ebp)
  102c7e:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102c81:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102c85:	74 1a                	je     102ca1 <strncmp+0x32>
  102c87:	8b 45 08             	mov    0x8(%ebp),%eax
  102c8a:	0f b6 00             	movzbl (%eax),%eax
  102c8d:	84 c0                	test   %al,%al
  102c8f:	74 10                	je     102ca1 <strncmp+0x32>
  102c91:	8b 45 08             	mov    0x8(%ebp),%eax
  102c94:	0f b6 10             	movzbl (%eax),%edx
  102c97:	8b 45 0c             	mov    0xc(%ebp),%eax
  102c9a:	0f b6 00             	movzbl (%eax),%eax
  102c9d:	38 c2                	cmp    %al,%dl
  102c9f:	74 d7                	je     102c78 <strncmp+0x9>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102ca1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102ca5:	74 18                	je     102cbf <strncmp+0x50>
  102ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  102caa:	0f b6 00             	movzbl (%eax),%eax
  102cad:	0f b6 d0             	movzbl %al,%edx
  102cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cb3:	0f b6 00             	movzbl (%eax),%eax
  102cb6:	0f b6 c0             	movzbl %al,%eax
  102cb9:	29 c2                	sub    %eax,%edx
  102cbb:	89 d0                	mov    %edx,%eax
  102cbd:	eb 05                	jmp    102cc4 <strncmp+0x55>
  102cbf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102cc4:	5d                   	pop    %ebp
  102cc5:	c3                   	ret    

00102cc6 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102cc6:	f3 0f 1e fb          	endbr32 
  102cca:	55                   	push   %ebp
  102ccb:	89 e5                	mov    %esp,%ebp
  102ccd:	83 ec 04             	sub    $0x4,%esp
  102cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  102cd3:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102cd6:	eb 13                	jmp    102ceb <strchr+0x25>
        if (*s == c) {
  102cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  102cdb:	0f b6 00             	movzbl (%eax),%eax
  102cde:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102ce1:	75 05                	jne    102ce8 <strchr+0x22>
            return (char *)s;
  102ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  102ce6:	eb 12                	jmp    102cfa <strchr+0x34>
        }
        s ++;
  102ce8:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  102ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  102cee:	0f b6 00             	movzbl (%eax),%eax
  102cf1:	84 c0                	test   %al,%al
  102cf3:	75 e3                	jne    102cd8 <strchr+0x12>
    }
    return NULL;
  102cf5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102cfa:	c9                   	leave  
  102cfb:	c3                   	ret    

00102cfc <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102cfc:	f3 0f 1e fb          	endbr32 
  102d00:	55                   	push   %ebp
  102d01:	89 e5                	mov    %esp,%ebp
  102d03:	83 ec 04             	sub    $0x4,%esp
  102d06:	8b 45 0c             	mov    0xc(%ebp),%eax
  102d09:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102d0c:	eb 0e                	jmp    102d1c <strfind+0x20>
        if (*s == c) {
  102d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  102d11:	0f b6 00             	movzbl (%eax),%eax
  102d14:	38 45 fc             	cmp    %al,-0x4(%ebp)
  102d17:	74 0f                	je     102d28 <strfind+0x2c>
            break;
        }
        s ++;
  102d19:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  102d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  102d1f:	0f b6 00             	movzbl (%eax),%eax
  102d22:	84 c0                	test   %al,%al
  102d24:	75 e8                	jne    102d0e <strfind+0x12>
  102d26:	eb 01                	jmp    102d29 <strfind+0x2d>
            break;
  102d28:	90                   	nop
    }
    return (char *)s;
  102d29:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102d2c:	c9                   	leave  
  102d2d:	c3                   	ret    

00102d2e <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  102d2e:	f3 0f 1e fb          	endbr32 
  102d32:	55                   	push   %ebp
  102d33:	89 e5                	mov    %esp,%ebp
  102d35:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  102d38:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  102d3f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102d46:	eb 03                	jmp    102d4b <strtol+0x1d>
        s ++;
  102d48:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  102d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  102d4e:	0f b6 00             	movzbl (%eax),%eax
  102d51:	3c 20                	cmp    $0x20,%al
  102d53:	74 f3                	je     102d48 <strtol+0x1a>
  102d55:	8b 45 08             	mov    0x8(%ebp),%eax
  102d58:	0f b6 00             	movzbl (%eax),%eax
  102d5b:	3c 09                	cmp    $0x9,%al
  102d5d:	74 e9                	je     102d48 <strtol+0x1a>
    }

    // plus/minus sign
    if (*s == '+') {
  102d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  102d62:	0f b6 00             	movzbl (%eax),%eax
  102d65:	3c 2b                	cmp    $0x2b,%al
  102d67:	75 05                	jne    102d6e <strtol+0x40>
        s ++;
  102d69:	ff 45 08             	incl   0x8(%ebp)
  102d6c:	eb 14                	jmp    102d82 <strtol+0x54>
    }
    else if (*s == '-') {
  102d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  102d71:	0f b6 00             	movzbl (%eax),%eax
  102d74:	3c 2d                	cmp    $0x2d,%al
  102d76:	75 0a                	jne    102d82 <strtol+0x54>
        s ++, neg = 1;
  102d78:	ff 45 08             	incl   0x8(%ebp)
  102d7b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102d82:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102d86:	74 06                	je     102d8e <strtol+0x60>
  102d88:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102d8c:	75 22                	jne    102db0 <strtol+0x82>
  102d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  102d91:	0f b6 00             	movzbl (%eax),%eax
  102d94:	3c 30                	cmp    $0x30,%al
  102d96:	75 18                	jne    102db0 <strtol+0x82>
  102d98:	8b 45 08             	mov    0x8(%ebp),%eax
  102d9b:	40                   	inc    %eax
  102d9c:	0f b6 00             	movzbl (%eax),%eax
  102d9f:	3c 78                	cmp    $0x78,%al
  102da1:	75 0d                	jne    102db0 <strtol+0x82>
        s += 2, base = 16;
  102da3:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  102da7:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102dae:	eb 29                	jmp    102dd9 <strtol+0xab>
    }
    else if (base == 0 && s[0] == '0') {
  102db0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102db4:	75 16                	jne    102dcc <strtol+0x9e>
  102db6:	8b 45 08             	mov    0x8(%ebp),%eax
  102db9:	0f b6 00             	movzbl (%eax),%eax
  102dbc:	3c 30                	cmp    $0x30,%al
  102dbe:	75 0c                	jne    102dcc <strtol+0x9e>
        s ++, base = 8;
  102dc0:	ff 45 08             	incl   0x8(%ebp)
  102dc3:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102dca:	eb 0d                	jmp    102dd9 <strtol+0xab>
    }
    else if (base == 0) {
  102dcc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102dd0:	75 07                	jne    102dd9 <strtol+0xab>
        base = 10;
  102dd2:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  102ddc:	0f b6 00             	movzbl (%eax),%eax
  102ddf:	3c 2f                	cmp    $0x2f,%al
  102de1:	7e 1b                	jle    102dfe <strtol+0xd0>
  102de3:	8b 45 08             	mov    0x8(%ebp),%eax
  102de6:	0f b6 00             	movzbl (%eax),%eax
  102de9:	3c 39                	cmp    $0x39,%al
  102deb:	7f 11                	jg     102dfe <strtol+0xd0>
            dig = *s - '0';
  102ded:	8b 45 08             	mov    0x8(%ebp),%eax
  102df0:	0f b6 00             	movzbl (%eax),%eax
  102df3:	0f be c0             	movsbl %al,%eax
  102df6:	83 e8 30             	sub    $0x30,%eax
  102df9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102dfc:	eb 48                	jmp    102e46 <strtol+0x118>
        }
        else if (*s >= 'a' && *s <= 'z') {
  102dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  102e01:	0f b6 00             	movzbl (%eax),%eax
  102e04:	3c 60                	cmp    $0x60,%al
  102e06:	7e 1b                	jle    102e23 <strtol+0xf5>
  102e08:	8b 45 08             	mov    0x8(%ebp),%eax
  102e0b:	0f b6 00             	movzbl (%eax),%eax
  102e0e:	3c 7a                	cmp    $0x7a,%al
  102e10:	7f 11                	jg     102e23 <strtol+0xf5>
            dig = *s - 'a' + 10;
  102e12:	8b 45 08             	mov    0x8(%ebp),%eax
  102e15:	0f b6 00             	movzbl (%eax),%eax
  102e18:	0f be c0             	movsbl %al,%eax
  102e1b:	83 e8 57             	sub    $0x57,%eax
  102e1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102e21:	eb 23                	jmp    102e46 <strtol+0x118>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  102e23:	8b 45 08             	mov    0x8(%ebp),%eax
  102e26:	0f b6 00             	movzbl (%eax),%eax
  102e29:	3c 40                	cmp    $0x40,%al
  102e2b:	7e 3b                	jle    102e68 <strtol+0x13a>
  102e2d:	8b 45 08             	mov    0x8(%ebp),%eax
  102e30:	0f b6 00             	movzbl (%eax),%eax
  102e33:	3c 5a                	cmp    $0x5a,%al
  102e35:	7f 31                	jg     102e68 <strtol+0x13a>
            dig = *s - 'A' + 10;
  102e37:	8b 45 08             	mov    0x8(%ebp),%eax
  102e3a:	0f b6 00             	movzbl (%eax),%eax
  102e3d:	0f be c0             	movsbl %al,%eax
  102e40:	83 e8 37             	sub    $0x37,%eax
  102e43:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  102e46:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e49:	3b 45 10             	cmp    0x10(%ebp),%eax
  102e4c:	7d 19                	jge    102e67 <strtol+0x139>
            break;
        }
        s ++, val = (val * base) + dig;
  102e4e:	ff 45 08             	incl   0x8(%ebp)
  102e51:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e54:	0f af 45 10          	imul   0x10(%ebp),%eax
  102e58:	89 c2                	mov    %eax,%edx
  102e5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e5d:	01 d0                	add    %edx,%eax
  102e5f:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  102e62:	e9 72 ff ff ff       	jmp    102dd9 <strtol+0xab>
            break;
  102e67:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  102e68:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102e6c:	74 08                	je     102e76 <strtol+0x148>
        *endptr = (char *) s;
  102e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e71:	8b 55 08             	mov    0x8(%ebp),%edx
  102e74:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  102e76:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  102e7a:	74 07                	je     102e83 <strtol+0x155>
  102e7c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102e7f:	f7 d8                	neg    %eax
  102e81:	eb 03                	jmp    102e86 <strtol+0x158>
  102e83:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  102e86:	c9                   	leave  
  102e87:	c3                   	ret    

00102e88 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  102e88:	f3 0f 1e fb          	endbr32 
  102e8c:	55                   	push   %ebp
  102e8d:	89 e5                	mov    %esp,%ebp
  102e8f:	57                   	push   %edi
  102e90:	83 ec 24             	sub    $0x24,%esp
  102e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e96:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  102e99:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  102e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  102ea3:	88 55 f7             	mov    %dl,-0x9(%ebp)
  102ea6:	8b 45 10             	mov    0x10(%ebp),%eax
  102ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  102eac:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  102eaf:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  102eb3:	8b 55 f8             	mov    -0x8(%ebp),%edx
  102eb6:	89 d7                	mov    %edx,%edi
  102eb8:	f3 aa                	rep stos %al,%es:(%edi)
  102eba:	89 fa                	mov    %edi,%edx
  102ebc:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102ebf:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  102ec2:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  102ec5:	83 c4 24             	add    $0x24,%esp
  102ec8:	5f                   	pop    %edi
  102ec9:	5d                   	pop    %ebp
  102eca:	c3                   	ret    

00102ecb <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  102ecb:	f3 0f 1e fb          	endbr32 
  102ecf:	55                   	push   %ebp
  102ed0:	89 e5                	mov    %esp,%ebp
  102ed2:	57                   	push   %edi
  102ed3:	56                   	push   %esi
  102ed4:	53                   	push   %ebx
  102ed5:	83 ec 30             	sub    $0x30,%esp
  102ed8:	8b 45 08             	mov    0x8(%ebp),%eax
  102edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ee1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102ee4:	8b 45 10             	mov    0x10(%ebp),%eax
  102ee7:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  102eea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102eed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  102ef0:	73 42                	jae    102f34 <memmove+0x69>
  102ef2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ef5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  102ef8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102efb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102efe:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f01:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102f04:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102f07:	c1 e8 02             	shr    $0x2,%eax
  102f0a:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102f0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102f0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102f12:	89 d7                	mov    %edx,%edi
  102f14:	89 c6                	mov    %eax,%esi
  102f16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102f18:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  102f1b:	83 e1 03             	and    $0x3,%ecx
  102f1e:	74 02                	je     102f22 <memmove+0x57>
  102f20:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102f22:	89 f0                	mov    %esi,%eax
  102f24:	89 fa                	mov    %edi,%edx
  102f26:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  102f29:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102f2c:	89 45 d0             	mov    %eax,-0x30(%ebp)
            : "memory");
    return dst;
  102f2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  102f32:	eb 36                	jmp    102f6a <memmove+0x9f>
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  102f34:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f37:	8d 50 ff             	lea    -0x1(%eax),%edx
  102f3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f3d:	01 c2                	add    %eax,%edx
  102f3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f42:	8d 48 ff             	lea    -0x1(%eax),%ecx
  102f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f48:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  102f4b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102f4e:	89 c1                	mov    %eax,%ecx
  102f50:	89 d8                	mov    %ebx,%eax
  102f52:	89 d6                	mov    %edx,%esi
  102f54:	89 c7                	mov    %eax,%edi
  102f56:	fd                   	std    
  102f57:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102f59:	fc                   	cld    
  102f5a:	89 f8                	mov    %edi,%eax
  102f5c:	89 f2                	mov    %esi,%edx
  102f5e:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  102f61:	89 55 c8             	mov    %edx,-0x38(%ebp)
  102f64:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  102f67:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  102f6a:	83 c4 30             	add    $0x30,%esp
  102f6d:	5b                   	pop    %ebx
  102f6e:	5e                   	pop    %esi
  102f6f:	5f                   	pop    %edi
  102f70:	5d                   	pop    %ebp
  102f71:	c3                   	ret    

00102f72 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  102f72:	f3 0f 1e fb          	endbr32 
  102f76:	55                   	push   %ebp
  102f77:	89 e5                	mov    %esp,%ebp
  102f79:	57                   	push   %edi
  102f7a:	56                   	push   %esi
  102f7b:	83 ec 20             	sub    $0x20,%esp
  102f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  102f81:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f84:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f87:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102f8a:	8b 45 10             	mov    0x10(%ebp),%eax
  102f8d:	89 45 ec             	mov    %eax,-0x14(%ebp)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  102f90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102f93:	c1 e8 02             	shr    $0x2,%eax
  102f96:	89 c1                	mov    %eax,%ecx
    asm volatile (
  102f98:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102f9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f9e:	89 d7                	mov    %edx,%edi
  102fa0:	89 c6                	mov    %eax,%esi
  102fa2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  102fa4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  102fa7:	83 e1 03             	and    $0x3,%ecx
  102faa:	74 02                	je     102fae <memcpy+0x3c>
  102fac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  102fae:	89 f0                	mov    %esi,%eax
  102fb0:	89 fa                	mov    %edi,%edx
  102fb2:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102fb5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  102fb8:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  102fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  102fbe:	83 c4 20             	add    $0x20,%esp
  102fc1:	5e                   	pop    %esi
  102fc2:	5f                   	pop    %edi
  102fc3:	5d                   	pop    %ebp
  102fc4:	c3                   	ret    

00102fc5 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  102fc5:	f3 0f 1e fb          	endbr32 
  102fc9:	55                   	push   %ebp
  102fca:	89 e5                	mov    %esp,%ebp
  102fcc:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  102fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  102fd2:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  102fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  102fd8:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  102fdb:	eb 2e                	jmp    10300b <memcmp+0x46>
        if (*s1 != *s2) {
  102fdd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102fe0:	0f b6 10             	movzbl (%eax),%edx
  102fe3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102fe6:	0f b6 00             	movzbl (%eax),%eax
  102fe9:	38 c2                	cmp    %al,%dl
  102feb:	74 18                	je     103005 <memcmp+0x40>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  102fed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ff0:	0f b6 00             	movzbl (%eax),%eax
  102ff3:	0f b6 d0             	movzbl %al,%edx
  102ff6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  102ff9:	0f b6 00             	movzbl (%eax),%eax
  102ffc:	0f b6 c0             	movzbl %al,%eax
  102fff:	29 c2                	sub    %eax,%edx
  103001:	89 d0                	mov    %edx,%eax
  103003:	eb 18                	jmp    10301d <memcmp+0x58>
        }
        s1 ++, s2 ++;
  103005:	ff 45 fc             	incl   -0x4(%ebp)
  103008:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  10300b:	8b 45 10             	mov    0x10(%ebp),%eax
  10300e:	8d 50 ff             	lea    -0x1(%eax),%edx
  103011:	89 55 10             	mov    %edx,0x10(%ebp)
  103014:	85 c0                	test   %eax,%eax
  103016:	75 c5                	jne    102fdd <memcmp+0x18>
    }
    return 0;
  103018:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10301d:	c9                   	leave  
  10301e:	c3                   	ret    

0010301f <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  10301f:	f3 0f 1e fb          	endbr32 
  103023:	55                   	push   %ebp
  103024:	89 e5                	mov    %esp,%ebp
  103026:	83 ec 58             	sub    $0x58,%esp
  103029:	8b 45 10             	mov    0x10(%ebp),%eax
  10302c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10302f:	8b 45 14             	mov    0x14(%ebp),%eax
  103032:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  103035:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103038:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10303b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10303e:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  103041:	8b 45 18             	mov    0x18(%ebp),%eax
  103044:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103047:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10304a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10304d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103050:	89 55 f0             	mov    %edx,-0x10(%ebp)
  103053:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103056:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103059:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10305d:	74 1c                	je     10307b <printnum+0x5c>
  10305f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103062:	ba 00 00 00 00       	mov    $0x0,%edx
  103067:	f7 75 e4             	divl   -0x1c(%ebp)
  10306a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10306d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103070:	ba 00 00 00 00       	mov    $0x0,%edx
  103075:	f7 75 e4             	divl   -0x1c(%ebp)
  103078:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10307b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10307e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103081:	f7 75 e4             	divl   -0x1c(%ebp)
  103084:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103087:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10308a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10308d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103090:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103093:	89 55 ec             	mov    %edx,-0x14(%ebp)
  103096:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103099:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10309c:	8b 45 18             	mov    0x18(%ebp),%eax
  10309f:	ba 00 00 00 00       	mov    $0x0,%edx
  1030a4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  1030a7:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1030aa:	19 d1                	sbb    %edx,%ecx
  1030ac:	72 4c                	jb     1030fa <printnum+0xdb>
        printnum(putch, putdat, result, base, width - 1, padc);
  1030ae:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1030b1:	8d 50 ff             	lea    -0x1(%eax),%edx
  1030b4:	8b 45 20             	mov    0x20(%ebp),%eax
  1030b7:	89 44 24 18          	mov    %eax,0x18(%esp)
  1030bb:	89 54 24 14          	mov    %edx,0x14(%esp)
  1030bf:	8b 45 18             	mov    0x18(%ebp),%eax
  1030c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  1030c6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1030c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1030cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  1030d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1030d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030db:	8b 45 08             	mov    0x8(%ebp),%eax
  1030de:	89 04 24             	mov    %eax,(%esp)
  1030e1:	e8 39 ff ff ff       	call   10301f <printnum>
  1030e6:	eb 1b                	jmp    103103 <printnum+0xe4>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1030e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1030ef:	8b 45 20             	mov    0x20(%ebp),%eax
  1030f2:	89 04 24             	mov    %eax,(%esp)
  1030f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1030f8:	ff d0                	call   *%eax
        while (-- width > 0)
  1030fa:	ff 4d 1c             	decl   0x1c(%ebp)
  1030fd:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  103101:	7f e5                	jg     1030e8 <printnum+0xc9>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  103103:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103106:	05 90 3e 10 00       	add    $0x103e90,%eax
  10310b:	0f b6 00             	movzbl (%eax),%eax
  10310e:	0f be c0             	movsbl %al,%eax
  103111:	8b 55 0c             	mov    0xc(%ebp),%edx
  103114:	89 54 24 04          	mov    %edx,0x4(%esp)
  103118:	89 04 24             	mov    %eax,(%esp)
  10311b:	8b 45 08             	mov    0x8(%ebp),%eax
  10311e:	ff d0                	call   *%eax
}
  103120:	90                   	nop
  103121:	c9                   	leave  
  103122:	c3                   	ret    

00103123 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  103123:	f3 0f 1e fb          	endbr32 
  103127:	55                   	push   %ebp
  103128:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10312a:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10312e:	7e 14                	jle    103144 <getuint+0x21>
        return va_arg(*ap, unsigned long long);
  103130:	8b 45 08             	mov    0x8(%ebp),%eax
  103133:	8b 00                	mov    (%eax),%eax
  103135:	8d 48 08             	lea    0x8(%eax),%ecx
  103138:	8b 55 08             	mov    0x8(%ebp),%edx
  10313b:	89 0a                	mov    %ecx,(%edx)
  10313d:	8b 50 04             	mov    0x4(%eax),%edx
  103140:	8b 00                	mov    (%eax),%eax
  103142:	eb 30                	jmp    103174 <getuint+0x51>
    }
    else if (lflag) {
  103144:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103148:	74 16                	je     103160 <getuint+0x3d>
        return va_arg(*ap, unsigned long);
  10314a:	8b 45 08             	mov    0x8(%ebp),%eax
  10314d:	8b 00                	mov    (%eax),%eax
  10314f:	8d 48 04             	lea    0x4(%eax),%ecx
  103152:	8b 55 08             	mov    0x8(%ebp),%edx
  103155:	89 0a                	mov    %ecx,(%edx)
  103157:	8b 00                	mov    (%eax),%eax
  103159:	ba 00 00 00 00       	mov    $0x0,%edx
  10315e:	eb 14                	jmp    103174 <getuint+0x51>
    }
    else {
        return va_arg(*ap, unsigned int);
  103160:	8b 45 08             	mov    0x8(%ebp),%eax
  103163:	8b 00                	mov    (%eax),%eax
  103165:	8d 48 04             	lea    0x4(%eax),%ecx
  103168:	8b 55 08             	mov    0x8(%ebp),%edx
  10316b:	89 0a                	mov    %ecx,(%edx)
  10316d:	8b 00                	mov    (%eax),%eax
  10316f:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  103174:	5d                   	pop    %ebp
  103175:	c3                   	ret    

00103176 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  103176:	f3 0f 1e fb          	endbr32 
  10317a:	55                   	push   %ebp
  10317b:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10317d:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  103181:	7e 14                	jle    103197 <getint+0x21>
        return va_arg(*ap, long long);
  103183:	8b 45 08             	mov    0x8(%ebp),%eax
  103186:	8b 00                	mov    (%eax),%eax
  103188:	8d 48 08             	lea    0x8(%eax),%ecx
  10318b:	8b 55 08             	mov    0x8(%ebp),%edx
  10318e:	89 0a                	mov    %ecx,(%edx)
  103190:	8b 50 04             	mov    0x4(%eax),%edx
  103193:	8b 00                	mov    (%eax),%eax
  103195:	eb 28                	jmp    1031bf <getint+0x49>
    }
    else if (lflag) {
  103197:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10319b:	74 12                	je     1031af <getint+0x39>
        return va_arg(*ap, long);
  10319d:	8b 45 08             	mov    0x8(%ebp),%eax
  1031a0:	8b 00                	mov    (%eax),%eax
  1031a2:	8d 48 04             	lea    0x4(%eax),%ecx
  1031a5:	8b 55 08             	mov    0x8(%ebp),%edx
  1031a8:	89 0a                	mov    %ecx,(%edx)
  1031aa:	8b 00                	mov    (%eax),%eax
  1031ac:	99                   	cltd   
  1031ad:	eb 10                	jmp    1031bf <getint+0x49>
    }
    else {
        return va_arg(*ap, int);
  1031af:	8b 45 08             	mov    0x8(%ebp),%eax
  1031b2:	8b 00                	mov    (%eax),%eax
  1031b4:	8d 48 04             	lea    0x4(%eax),%ecx
  1031b7:	8b 55 08             	mov    0x8(%ebp),%edx
  1031ba:	89 0a                	mov    %ecx,(%edx)
  1031bc:	8b 00                	mov    (%eax),%eax
  1031be:	99                   	cltd   
    }
}
  1031bf:	5d                   	pop    %ebp
  1031c0:	c3                   	ret    

001031c1 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1031c1:	f3 0f 1e fb          	endbr32 
  1031c5:	55                   	push   %ebp
  1031c6:	89 e5                	mov    %esp,%ebp
  1031c8:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1031cb:	8d 45 14             	lea    0x14(%ebp),%eax
  1031ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1031d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1031d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1031d8:	8b 45 10             	mov    0x10(%ebp),%eax
  1031db:	89 44 24 08          	mov    %eax,0x8(%esp)
  1031df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1031e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1031e9:	89 04 24             	mov    %eax,(%esp)
  1031ec:	e8 03 00 00 00       	call   1031f4 <vprintfmt>
    va_end(ap);
}
  1031f1:	90                   	nop
  1031f2:	c9                   	leave  
  1031f3:	c3                   	ret    

001031f4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1031f4:	f3 0f 1e fb          	endbr32 
  1031f8:	55                   	push   %ebp
  1031f9:	89 e5                	mov    %esp,%ebp
  1031fb:	56                   	push   %esi
  1031fc:	53                   	push   %ebx
  1031fd:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  103200:	eb 17                	jmp    103219 <vprintfmt+0x25>
            if (ch == '\0') {
  103202:	85 db                	test   %ebx,%ebx
  103204:	0f 84 c0 03 00 00    	je     1035ca <vprintfmt+0x3d6>
                return;
            }
            putch(ch, putdat);
  10320a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10320d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103211:	89 1c 24             	mov    %ebx,(%esp)
  103214:	8b 45 08             	mov    0x8(%ebp),%eax
  103217:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  103219:	8b 45 10             	mov    0x10(%ebp),%eax
  10321c:	8d 50 01             	lea    0x1(%eax),%edx
  10321f:	89 55 10             	mov    %edx,0x10(%ebp)
  103222:	0f b6 00             	movzbl (%eax),%eax
  103225:	0f b6 d8             	movzbl %al,%ebx
  103228:	83 fb 25             	cmp    $0x25,%ebx
  10322b:	75 d5                	jne    103202 <vprintfmt+0xe>
        }

        // Process a %-escape sequence
        char padc = ' ';
  10322d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  103231:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  103238:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10323b:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  10323e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103245:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103248:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  10324b:	8b 45 10             	mov    0x10(%ebp),%eax
  10324e:	8d 50 01             	lea    0x1(%eax),%edx
  103251:	89 55 10             	mov    %edx,0x10(%ebp)
  103254:	0f b6 00             	movzbl (%eax),%eax
  103257:	0f b6 d8             	movzbl %al,%ebx
  10325a:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10325d:	83 f8 55             	cmp    $0x55,%eax
  103260:	0f 87 38 03 00 00    	ja     10359e <vprintfmt+0x3aa>
  103266:	8b 04 85 b4 3e 10 00 	mov    0x103eb4(,%eax,4),%eax
  10326d:	3e ff e0             	notrack jmp *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  103270:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  103274:	eb d5                	jmp    10324b <vprintfmt+0x57>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  103276:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10327a:	eb cf                	jmp    10324b <vprintfmt+0x57>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10327c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  103283:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103286:	89 d0                	mov    %edx,%eax
  103288:	c1 e0 02             	shl    $0x2,%eax
  10328b:	01 d0                	add    %edx,%eax
  10328d:	01 c0                	add    %eax,%eax
  10328f:	01 d8                	add    %ebx,%eax
  103291:	83 e8 30             	sub    $0x30,%eax
  103294:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  103297:	8b 45 10             	mov    0x10(%ebp),%eax
  10329a:	0f b6 00             	movzbl (%eax),%eax
  10329d:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  1032a0:	83 fb 2f             	cmp    $0x2f,%ebx
  1032a3:	7e 38                	jle    1032dd <vprintfmt+0xe9>
  1032a5:	83 fb 39             	cmp    $0x39,%ebx
  1032a8:	7f 33                	jg     1032dd <vprintfmt+0xe9>
            for (precision = 0; ; ++ fmt) {
  1032aa:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  1032ad:	eb d4                	jmp    103283 <vprintfmt+0x8f>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  1032af:	8b 45 14             	mov    0x14(%ebp),%eax
  1032b2:	8d 50 04             	lea    0x4(%eax),%edx
  1032b5:	89 55 14             	mov    %edx,0x14(%ebp)
  1032b8:	8b 00                	mov    (%eax),%eax
  1032ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1032bd:	eb 1f                	jmp    1032de <vprintfmt+0xea>

        case '.':
            if (width < 0)
  1032bf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1032c3:	79 86                	jns    10324b <vprintfmt+0x57>
                width = 0;
  1032c5:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1032cc:	e9 7a ff ff ff       	jmp    10324b <vprintfmt+0x57>

        case '#':
            altflag = 1;
  1032d1:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1032d8:	e9 6e ff ff ff       	jmp    10324b <vprintfmt+0x57>
            goto process_precision;
  1032dd:	90                   	nop

        process_precision:
            if (width < 0)
  1032de:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1032e2:	0f 89 63 ff ff ff    	jns    10324b <vprintfmt+0x57>
                width = precision, precision = -1;
  1032e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1032eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1032ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1032f5:	e9 51 ff ff ff       	jmp    10324b <vprintfmt+0x57>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1032fa:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  1032fd:	e9 49 ff ff ff       	jmp    10324b <vprintfmt+0x57>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  103302:	8b 45 14             	mov    0x14(%ebp),%eax
  103305:	8d 50 04             	lea    0x4(%eax),%edx
  103308:	89 55 14             	mov    %edx,0x14(%ebp)
  10330b:	8b 00                	mov    (%eax),%eax
  10330d:	8b 55 0c             	mov    0xc(%ebp),%edx
  103310:	89 54 24 04          	mov    %edx,0x4(%esp)
  103314:	89 04 24             	mov    %eax,(%esp)
  103317:	8b 45 08             	mov    0x8(%ebp),%eax
  10331a:	ff d0                	call   *%eax
            break;
  10331c:	e9 a4 02 00 00       	jmp    1035c5 <vprintfmt+0x3d1>

        // error message
        case 'e':
            err = va_arg(ap, int);
  103321:	8b 45 14             	mov    0x14(%ebp),%eax
  103324:	8d 50 04             	lea    0x4(%eax),%edx
  103327:	89 55 14             	mov    %edx,0x14(%ebp)
  10332a:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  10332c:	85 db                	test   %ebx,%ebx
  10332e:	79 02                	jns    103332 <vprintfmt+0x13e>
                err = -err;
  103330:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  103332:	83 fb 06             	cmp    $0x6,%ebx
  103335:	7f 0b                	jg     103342 <vprintfmt+0x14e>
  103337:	8b 34 9d 74 3e 10 00 	mov    0x103e74(,%ebx,4),%esi
  10333e:	85 f6                	test   %esi,%esi
  103340:	75 23                	jne    103365 <vprintfmt+0x171>
                printfmt(putch, putdat, "error %d", err);
  103342:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  103346:	c7 44 24 08 a1 3e 10 	movl   $0x103ea1,0x8(%esp)
  10334d:	00 
  10334e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103351:	89 44 24 04          	mov    %eax,0x4(%esp)
  103355:	8b 45 08             	mov    0x8(%ebp),%eax
  103358:	89 04 24             	mov    %eax,(%esp)
  10335b:	e8 61 fe ff ff       	call   1031c1 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  103360:	e9 60 02 00 00       	jmp    1035c5 <vprintfmt+0x3d1>
                printfmt(putch, putdat, "%s", p);
  103365:	89 74 24 0c          	mov    %esi,0xc(%esp)
  103369:	c7 44 24 08 aa 3e 10 	movl   $0x103eaa,0x8(%esp)
  103370:	00 
  103371:	8b 45 0c             	mov    0xc(%ebp),%eax
  103374:	89 44 24 04          	mov    %eax,0x4(%esp)
  103378:	8b 45 08             	mov    0x8(%ebp),%eax
  10337b:	89 04 24             	mov    %eax,(%esp)
  10337e:	e8 3e fe ff ff       	call   1031c1 <printfmt>
            break;
  103383:	e9 3d 02 00 00       	jmp    1035c5 <vprintfmt+0x3d1>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  103388:	8b 45 14             	mov    0x14(%ebp),%eax
  10338b:	8d 50 04             	lea    0x4(%eax),%edx
  10338e:	89 55 14             	mov    %edx,0x14(%ebp)
  103391:	8b 30                	mov    (%eax),%esi
  103393:	85 f6                	test   %esi,%esi
  103395:	75 05                	jne    10339c <vprintfmt+0x1a8>
                p = "(null)";
  103397:	be ad 3e 10 00       	mov    $0x103ead,%esi
            }
            if (width > 0 && padc != '-') {
  10339c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1033a0:	7e 76                	jle    103418 <vprintfmt+0x224>
  1033a2:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  1033a6:	74 70                	je     103418 <vprintfmt+0x224>
                for (width -= strnlen(p, precision); width > 0; width --) {
  1033a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1033ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033af:	89 34 24             	mov    %esi,(%esp)
  1033b2:	e8 ba f7 ff ff       	call   102b71 <strnlen>
  1033b7:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1033ba:	29 c2                	sub    %eax,%edx
  1033bc:	89 d0                	mov    %edx,%eax
  1033be:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1033c1:	eb 16                	jmp    1033d9 <vprintfmt+0x1e5>
                    putch(padc, putdat);
  1033c3:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1033c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  1033ca:	89 54 24 04          	mov    %edx,0x4(%esp)
  1033ce:	89 04 24             	mov    %eax,(%esp)
  1033d1:	8b 45 08             	mov    0x8(%ebp),%eax
  1033d4:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  1033d6:	ff 4d e8             	decl   -0x18(%ebp)
  1033d9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1033dd:	7f e4                	jg     1033c3 <vprintfmt+0x1cf>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1033df:	eb 37                	jmp    103418 <vprintfmt+0x224>
                if (altflag && (ch < ' ' || ch > '~')) {
  1033e1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1033e5:	74 1f                	je     103406 <vprintfmt+0x212>
  1033e7:	83 fb 1f             	cmp    $0x1f,%ebx
  1033ea:	7e 05                	jle    1033f1 <vprintfmt+0x1fd>
  1033ec:	83 fb 7e             	cmp    $0x7e,%ebx
  1033ef:	7e 15                	jle    103406 <vprintfmt+0x212>
                    putch('?', putdat);
  1033f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033f8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1033ff:	8b 45 08             	mov    0x8(%ebp),%eax
  103402:	ff d0                	call   *%eax
  103404:	eb 0f                	jmp    103415 <vprintfmt+0x221>
                }
                else {
                    putch(ch, putdat);
  103406:	8b 45 0c             	mov    0xc(%ebp),%eax
  103409:	89 44 24 04          	mov    %eax,0x4(%esp)
  10340d:	89 1c 24             	mov    %ebx,(%esp)
  103410:	8b 45 08             	mov    0x8(%ebp),%eax
  103413:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  103415:	ff 4d e8             	decl   -0x18(%ebp)
  103418:	89 f0                	mov    %esi,%eax
  10341a:	8d 70 01             	lea    0x1(%eax),%esi
  10341d:	0f b6 00             	movzbl (%eax),%eax
  103420:	0f be d8             	movsbl %al,%ebx
  103423:	85 db                	test   %ebx,%ebx
  103425:	74 27                	je     10344e <vprintfmt+0x25a>
  103427:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  10342b:	78 b4                	js     1033e1 <vprintfmt+0x1ed>
  10342d:	ff 4d e4             	decl   -0x1c(%ebp)
  103430:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103434:	79 ab                	jns    1033e1 <vprintfmt+0x1ed>
                }
            }
            for (; width > 0; width --) {
  103436:	eb 16                	jmp    10344e <vprintfmt+0x25a>
                putch(' ', putdat);
  103438:	8b 45 0c             	mov    0xc(%ebp),%eax
  10343b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10343f:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103446:	8b 45 08             	mov    0x8(%ebp),%eax
  103449:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  10344b:	ff 4d e8             	decl   -0x18(%ebp)
  10344e:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103452:	7f e4                	jg     103438 <vprintfmt+0x244>
            }
            break;
  103454:	e9 6c 01 00 00       	jmp    1035c5 <vprintfmt+0x3d1>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  103459:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10345c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103460:	8d 45 14             	lea    0x14(%ebp),%eax
  103463:	89 04 24             	mov    %eax,(%esp)
  103466:	e8 0b fd ff ff       	call   103176 <getint>
  10346b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10346e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  103471:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103474:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103477:	85 d2                	test   %edx,%edx
  103479:	79 26                	jns    1034a1 <vprintfmt+0x2ad>
                putch('-', putdat);
  10347b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10347e:	89 44 24 04          	mov    %eax,0x4(%esp)
  103482:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  103489:	8b 45 08             	mov    0x8(%ebp),%eax
  10348c:	ff d0                	call   *%eax
                num = -(long long)num;
  10348e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103491:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103494:	f7 d8                	neg    %eax
  103496:	83 d2 00             	adc    $0x0,%edx
  103499:	f7 da                	neg    %edx
  10349b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10349e:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  1034a1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1034a8:	e9 a8 00 00 00       	jmp    103555 <vprintfmt+0x361>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  1034ad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034b4:	8d 45 14             	lea    0x14(%ebp),%eax
  1034b7:	89 04 24             	mov    %eax,(%esp)
  1034ba:	e8 64 fc ff ff       	call   103123 <getuint>
  1034bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1034c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1034c5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1034cc:	e9 84 00 00 00       	jmp    103555 <vprintfmt+0x361>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1034d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1034d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034d8:	8d 45 14             	lea    0x14(%ebp),%eax
  1034db:	89 04 24             	mov    %eax,(%esp)
  1034de:	e8 40 fc ff ff       	call   103123 <getuint>
  1034e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1034e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1034e9:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1034f0:	eb 63                	jmp    103555 <vprintfmt+0x361>

        // pointer
        case 'p':
            putch('0', putdat);
  1034f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034f9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  103500:	8b 45 08             	mov    0x8(%ebp),%eax
  103503:	ff d0                	call   *%eax
            putch('x', putdat);
  103505:	8b 45 0c             	mov    0xc(%ebp),%eax
  103508:	89 44 24 04          	mov    %eax,0x4(%esp)
  10350c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  103513:	8b 45 08             	mov    0x8(%ebp),%eax
  103516:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  103518:	8b 45 14             	mov    0x14(%ebp),%eax
  10351b:	8d 50 04             	lea    0x4(%eax),%edx
  10351e:	89 55 14             	mov    %edx,0x14(%ebp)
  103521:	8b 00                	mov    (%eax),%eax
  103523:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103526:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  10352d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  103534:	eb 1f                	jmp    103555 <vprintfmt+0x361>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  103536:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103539:	89 44 24 04          	mov    %eax,0x4(%esp)
  10353d:	8d 45 14             	lea    0x14(%ebp),%eax
  103540:	89 04 24             	mov    %eax,(%esp)
  103543:	e8 db fb ff ff       	call   103123 <getuint>
  103548:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10354b:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  10354e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  103555:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  103559:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10355c:	89 54 24 18          	mov    %edx,0x18(%esp)
  103560:	8b 55 e8             	mov    -0x18(%ebp),%edx
  103563:	89 54 24 14          	mov    %edx,0x14(%esp)
  103567:	89 44 24 10          	mov    %eax,0x10(%esp)
  10356b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10356e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103571:	89 44 24 08          	mov    %eax,0x8(%esp)
  103575:	89 54 24 0c          	mov    %edx,0xc(%esp)
  103579:	8b 45 0c             	mov    0xc(%ebp),%eax
  10357c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103580:	8b 45 08             	mov    0x8(%ebp),%eax
  103583:	89 04 24             	mov    %eax,(%esp)
  103586:	e8 94 fa ff ff       	call   10301f <printnum>
            break;
  10358b:	eb 38                	jmp    1035c5 <vprintfmt+0x3d1>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  10358d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103590:	89 44 24 04          	mov    %eax,0x4(%esp)
  103594:	89 1c 24             	mov    %ebx,(%esp)
  103597:	8b 45 08             	mov    0x8(%ebp),%eax
  10359a:	ff d0                	call   *%eax
            break;
  10359c:	eb 27                	jmp    1035c5 <vprintfmt+0x3d1>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  10359e:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035a5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  1035ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1035af:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  1035b1:	ff 4d 10             	decl   0x10(%ebp)
  1035b4:	eb 03                	jmp    1035b9 <vprintfmt+0x3c5>
  1035b6:	ff 4d 10             	decl   0x10(%ebp)
  1035b9:	8b 45 10             	mov    0x10(%ebp),%eax
  1035bc:	48                   	dec    %eax
  1035bd:	0f b6 00             	movzbl (%eax),%eax
  1035c0:	3c 25                	cmp    $0x25,%al
  1035c2:	75 f2                	jne    1035b6 <vprintfmt+0x3c2>
                /* do nothing */;
            break;
  1035c4:	90                   	nop
    while (1) {
  1035c5:	e9 36 fc ff ff       	jmp    103200 <vprintfmt+0xc>
                return;
  1035ca:	90                   	nop
        }
    }
}
  1035cb:	83 c4 40             	add    $0x40,%esp
  1035ce:	5b                   	pop    %ebx
  1035cf:	5e                   	pop    %esi
  1035d0:	5d                   	pop    %ebp
  1035d1:	c3                   	ret    

001035d2 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1035d2:	f3 0f 1e fb          	endbr32 
  1035d6:	55                   	push   %ebp
  1035d7:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1035d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035dc:	8b 40 08             	mov    0x8(%eax),%eax
  1035df:	8d 50 01             	lea    0x1(%eax),%edx
  1035e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035e5:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1035e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035eb:	8b 10                	mov    (%eax),%edx
  1035ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035f0:	8b 40 04             	mov    0x4(%eax),%eax
  1035f3:	39 c2                	cmp    %eax,%edx
  1035f5:	73 12                	jae    103609 <sprintputch+0x37>
        *b->buf ++ = ch;
  1035f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035fa:	8b 00                	mov    (%eax),%eax
  1035fc:	8d 48 01             	lea    0x1(%eax),%ecx
  1035ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  103602:	89 0a                	mov    %ecx,(%edx)
  103604:	8b 55 08             	mov    0x8(%ebp),%edx
  103607:	88 10                	mov    %dl,(%eax)
    }
}
  103609:	90                   	nop
  10360a:	5d                   	pop    %ebp
  10360b:	c3                   	ret    

0010360c <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  10360c:	f3 0f 1e fb          	endbr32 
  103610:	55                   	push   %ebp
  103611:	89 e5                	mov    %esp,%ebp
  103613:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  103616:	8d 45 14             	lea    0x14(%ebp),%eax
  103619:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  10361c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10361f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103623:	8b 45 10             	mov    0x10(%ebp),%eax
  103626:	89 44 24 08          	mov    %eax,0x8(%esp)
  10362a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10362d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103631:	8b 45 08             	mov    0x8(%ebp),%eax
  103634:	89 04 24             	mov    %eax,(%esp)
  103637:	e8 08 00 00 00       	call   103644 <vsnprintf>
  10363c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10363f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103642:	c9                   	leave  
  103643:	c3                   	ret    

00103644 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  103644:	f3 0f 1e fb          	endbr32 
  103648:	55                   	push   %ebp
  103649:	89 e5                	mov    %esp,%ebp
  10364b:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  10364e:	8b 45 08             	mov    0x8(%ebp),%eax
  103651:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103654:	8b 45 0c             	mov    0xc(%ebp),%eax
  103657:	8d 50 ff             	lea    -0x1(%eax),%edx
  10365a:	8b 45 08             	mov    0x8(%ebp),%eax
  10365d:	01 d0                	add    %edx,%eax
  10365f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103662:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  103669:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10366d:	74 0a                	je     103679 <vsnprintf+0x35>
  10366f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103675:	39 c2                	cmp    %eax,%edx
  103677:	76 07                	jbe    103680 <vsnprintf+0x3c>
        return -E_INVAL;
  103679:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  10367e:	eb 2a                	jmp    1036aa <vsnprintf+0x66>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  103680:	8b 45 14             	mov    0x14(%ebp),%eax
  103683:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103687:	8b 45 10             	mov    0x10(%ebp),%eax
  10368a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10368e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103691:	89 44 24 04          	mov    %eax,0x4(%esp)
  103695:	c7 04 24 d2 35 10 00 	movl   $0x1035d2,(%esp)
  10369c:	e8 53 fb ff ff       	call   1031f4 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  1036a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1036a4:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  1036a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1036aa:	c9                   	leave  
  1036ab:	c3                   	ret    
