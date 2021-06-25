# ucore实验报告2

## 实验内容

1. uCore Lab 2：物理内存管理
	(1) 编译运行 uCore Lab 2 的工程代码；
	(2) 完成 uCore Lab 2 练习 1-3 的编程作业；
	(3) 思考如何实现 uCore Lab 2 扩展练习 1-2。

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## (1)编译运行 uCore Lab 2 的工程代码

在lab2的makefile文件目录下， 输入命令：

    make

即可编译运行 uCore Lab 2 的工程代码

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice1-01.png)

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice1-02.png)

如果输入`make`，程序报错，提示`make: Nothing to be done for `TARGETS`.`，那么说明文件没有更新而且已经编译过了，想要再次强制编译，只要输入`make clean`，然后再输入`make`就可以编译了：

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice1-03.png)

## (2) uCore Lab 2 练习 1-3 实验报告

### lab2 练习0：填写已有实验

本实验依赖实验1。请把你做的实验1的代码填入本实验中代码中有LAB1的注释相应部分。提示：可采用diff和patch工具进行半自动的合并（merge），也可用一些图形化的比较/merge工具来手动合并，比如meld，eclipse中的diff/merge工具，understand中的diff/merge工具等。

### lab2 练习1：实现 first-fit 连续物理内存分配算法（需要编程）

在实现first fit 内存分配算法的回收函数时，要考虑地址连续的空闲块之间的合并操作。提示:在建立空闲页块链表时，需要按照空闲页块起始地址来排序，形成一个有序的链表。可能会修改`default_pmm.c`中的`default_init`，`default_init_memmap`，`default_alloc_pages`， `default_free_pages`等相关函数。请仔细查看和理解`default_pmm.c`中的注释。

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

  + 你的first fit算法是否有进一步的改进空间

#### first-fit 连续物理内存分配算法

在First-Fit算法中，空间配置器allocator保留一个空闲块列表（称为空闲列表）。一旦接收到内存分配请求，它将沿着列表扫描第一个足够大以满足请求的块。如果选择的块明显大于请求的块，则通常将其拆分，剩余的块将作为另一个空闲块添加到列表中。

#### 设计实现过程

可以根据注释中的过程部分按照注释内容逐步实现算法设计。

**1. 准备工作：**

在附录中，可以找到实验用到的许多数据结构的定义和作用含义。

**（1）、物理页结构`Page`：**

为了与以后的分页机制配合，我们首先需要建立对整个计算机的每一个物理页的属性用结构`Page`来表示，`Page`在文件`kern/mm/memlayout.h`中定义，它包含了映射此物理页的虚拟页个数，描述物理页属性的`flags`和双向链接各个`Page`结构的`page_link`双向链表：
```c
struct Page {
    int ref;                 // page frame's reference counter
    uint32_t flags;          // array of flags that describe the status of the page frame
    unsigned int property;   // the num of free block, used in first fit pm manager
    list_entry_t page_link;  // free list link
};
```
**成员变量含义：**

`ref`：表示这页被页表的引用记数，如果这个页被页表引用了，即在某页表中有一个页表项设置了一个虚拟页到这个`Page`管理的物理页的映射关系，就会把`Page`的`ref`加一；反之，若页表项取消，即映射关系解除，就会把`Page`的`ref`减一。

`flags`：表示此物理页的状态标记，在`kern/mm/memlayout.h`中的定义，可以看到：
```c
/* Flags describing the status of a page frame */
#define PG_reserved 0  // the page descriptor is reserved for kernel or unusable
#define PG_property 1  // the member 'property' is valid
```
这表示`flags`目前用到了两个bit表示页目前具有的两种属性，bit 0表示此页是否被保留（reserved），如果是被保留的页，则bit 0会设置为1，且不能放到空闲页链表中，即这样的页不是空闲页，不能动态分配与释放。比如目前内核代码占用的空间就属于这样“被保留”的页。在本实验中，bit 1表示此页是否是free的，如果设置为1，表示这页是free的，可以被分配；如果设置为0，表示这页已经被分配出去了，不能被再二次分配。另外，本实验这里取的名字`PG_property`比较不直观 ，主要是我们可以设计不同的页分配算法（best fit, buddy system等），那么这个`PG_property`就有不同的含义了。

`property`：用来记录某连续内存空闲块的大小（即地址连续的空闲页的个数）。这里需要注意的是用到此成员变量的这个`Page`比较特殊，是这个连续内存空闲块地址最小的一页（即头一页， Head Page）。连续内存空闲块利用这个页的成员变量`property`来记录在此块内的空闲页的个数。这里去的名字`property`也不是很直观，原因与上面类似，在不同的页分配算法中，`property`有不同的含义。

`page_link`：这是便于把多个连续内存空闲块链接在一起的双向链表指针（可回顾在lab0实验指导书中有关双向链表数据结构的介绍）。这里需要注意的是用到此成员变量的这个`Page`比较特殊，是这个连续内存空闲块地址最小的一页（即头一页， Head Page）。连续内存空闲块利用这个页的成员变量`page_link`来链接比它地址小和大的其他连续内存空闲块。

**（2）、管理所有的连续内存空闲块的双向链表结构`free_area_t`：**

在初始情况下，也许这个物理内存的空闲物理页都是连续的，这样就形成了一个大的连续内存空闲块。但随着物理页的分配与释放，这个大的连续内存空闲块会分裂为一系列地址不连续的多个小连续内存空闲块，且每个连续内存空闲块内部的物理页是连续的。那么为了有效地管理这些小连续内存空闲块。所有的连续内存空闲块可用一个双向链表管理起来，便于分配和释放，为此定义了一个`free_area_t`数据结构，包含了一个`list_entry`结构的双向链表指针和记录当前空闲页的个数的无符号整型变量`nr_free`。其中的链表指针指向了空闲的物理页。

```c
/* free_area_t - maintains a doubly linked list to record free (unused) pages */
typedef struct {
    list_entry_t free_list;  // the list header
    unsigned int nr_free;    // # of free pages in this free list
} free_area_t;
```

**（3）、物理内存页管理器框架`pmm_manager`：**

struct pmm_manager {
    const char *name; //物理内存页管理器的名字
    void (*init)(void); //初始化内存管理器
    void (*init_memmap)(struct Page *base, size_t n); //初始化管理空闲内存页的数据结构
    struct Page *(*alloc_pages)(size_t n); //分配n个物理内存页
    void (*free_pages)(struct Page *base, size_t n); //释放n个物理内存页
    size_t (*nr_free_pages)(void); //返回当前剩余的空闲页数
    void (*check)(void); //用于检测分配/释放实现是否正确的辅助函数
};

**（4）、双向链表`list`结构：**

为了实现First-Fit内存分配（FFMA），需要维护一个查找有序（地址按从小到大排列）空闲块（以页为最小单位的连续地址空间）的数据结构，而双向链表是一个很好的选择。我们应该使用一个列表来管理空闲内存块。使用`free_area_t`结构用于管理可用内存块。

`libs/list.h`定义了可挂接任意元素的通用双向链表结构和对应的操作，所以需要了解如何使用这个文件提供的各种函数，从而可以完成对双向链表的初始化/插入/删除等。需要熟悉头文件`list.h`中的内容，包括`list`的定义，以及对其的一些基本操作，如`list_init`、`list_add`（`list_add_after`）、`list_add_before`、`list_del`、`list_next`、`list_prev`等函数的作用。

`list.h:`

```c
// 双向链表，包括两个分别指向前一个结点和后一个结点的指针
struct list_entry {
    struct list_entry *prev, *next;
};

// list_entry双向链表和list_entry_t等价
typedef struct list_entry list_entry_t;

// 初始化一个新的双向链表，双向链表的表头指针和表尾指针都指向elm，即只有一个结点elm的双向链表
static inline void list_init(list_entry_t *elm) __attribute__((always_inline));
// 将结点elm插到链表项listelm的后面
static inline void list_add(list_entry_t *listelm, list_entry_t *elm) __attribute__((always_inline));
// 将结点elm插到链表项listelm的前面
static inline void list_add_before(list_entry_t *listelm, list_entry_t *elm) __attribute__((always_inline));
// 等价于list_add
static inline void list_add_after(list_entry_t *listelm, list_entry_t *elm) __attribute__((always_inline));
// 删除链表项listem
static inline void list_del(list_entry_t *listelm) __attribute__((always_inline));
// 返回listelm后面的链表项
static inline list_entry_t *list_next(list_entry_t *listelm) __attribute__((always_inline));
// 返回listelm前面的链表项
static inline list_entry_t *list_prev(list_entry_t *listelm) __attribute__((always_inline));

```

`__attribute__((always_inline))`代表强制内联。

**2. 修改`default_init`函数：**

`kern/mm/pmm.h`中定义了一个通用的分配算法的函数列表，用`pmm_manager`表示。其中`init`函数就是用来初始化`free_area`变量的, first_fit分配算法可直接重用`default_init`函数的实现。来初始化`free_area_t`结构中的`free_list`，并将`nr_free`设置为0。`free_list`用于记录可用内存块，`nr_free`是可用内存块的总数。

**`default_init`函数：**

```c
static void
default_init(void) {
    // 初始化链表
    list_init(&free_list);
    // 将可用内存块数目设置为0
    nr_free = 0;
}
```

**3. 修改`default_init_memmap`函数：**

`init_memmap`函数需要根据现有的内存情况构建空闲块列表的初始状态。通过分析代码，可以知道：

`kern_init` --> `pmm_init` --> `page_init` --> `init_memmap` --> `pmm_manager` --> `init_memmap`

所以，`default_init_memmap`需要根据`page_init`函数中传递过来的参数（某个连续地址的空闲块的起始页，页个数）来建立一个连续内存空闲块的双向链表。这里有一个假定p`age_init`函数是按地址从小到大的顺序传来的连续内存空闲块的。链表头是`free_area.free_list`，链表项是`Page`数据结构的`base->page_link`。这样我们就依靠`Page`数据结构中的成员变量`page_link`形成了连续内存空闲块列表。

`default_init_memmap`函数将根据每个物理页帧的情况来建立空闲页链表，且空闲页块应该是根据地址高低形成一个有序链表。根据上述变量的定义，`default_init_memmap`可大致实现如下：

```c
static void
default_init_memmap(struct Page *base, size_t n) {
    // n要大于0
    assert(n > 0);
    // 令p为连续地址的空闲块的起始页
    struct Page *p = base;
    // 将这个空闲块的每个页面初始化
    for (; p != base + n; p ++) {
        // 每次循环首先检查p的PG_reserved位是否设置为1，表示空闲可分配
        assert(PageReserved(p));
        // 设置这一页的flag为0，表示这页空闲
        p->flags = 0;
        // 将这一页的ref设为0，因为这页现在空闲，没有引用
        set_page_ref(p, 0);
        // 如果是空闲块的起始页
        if (p == base) {
            // 空闲块的第一页的连续空页值property设置为块中的总页数
            p->property = n;
            // 将空闲块的第一页的PG_property位设置为1，表示是起始页，可以被用作分配内存
            SetPageProperty(p);
        } else {
            // 设置非起始页的property为0，表示不是起始页
            p->property = 0;
        }
    }
    // 将base->page_link此页链接到free_list中
    list_add_before(&free_list, &(base->page_link));
    // 将空闲页的数目加n
    nr_free += n;
}
```

**4. 修改`default_alloc_pages`函数：**

firstfit需要从空闲链表头开始查找最小的地址，通过`list_next`找到下一个空闲块元素，通过`le2page`宏可以由链表元素获得对应的`Page`指针`p`。通过`p->property`可以了解此空闲块的大小。如果`p->property >= n`，这就找到了！如果`p->property < n`，则`list_next`，继续查找。直到`list_next == &free_list`，这表示找完了一遍了。找到后，就要从新组织空闲块，然后把找到的`page`返回。所以`default_alloc_pages`可大致实现如下：

```c
static struct Page *
default_alloc_pages(size_t n) {
    // n要大于0
    assert(n > 0);
    // 考虑边界情况，当n大于可以分配的内存数时，直接返回，确保分配不会超出范围，保证软件的鲁棒性
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = &free_list;
    // 遍历空闲链表
    while ((le = list_next(le)) != &free_list) {
        // 由链表元素获得对应的Page指针p
        struct Page *p = le2page(le, page_link);
        // 如果当前页面的property大于等于n，说明空闲块的连续空页数大于等于n，可以分配，令page等于p，直接退出
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    // 如果找到了空闲块，进行重新组织，否则直接返回NULL
    if (page != NULL) {
        // 在空闲页链表中删除刚刚分配的空闲块
        list_del(&(page->page_link));
        // 如果可以分配的空闲块的连续空页数大于n
        if (page->property > n) {
            // 创建一个地址为page+n的新物理页
            struct Page *p = page + n;
            // 页面的property设置为page多出来的空闲连续页数
            p->property = page->property - n;
            // 设置p的Page_property位，表示为新的空闲块的起始页
            SetPageProperty(p);
            // 将新的空闲块的页插入到空闲页链表的后面
            list_add(&free_list, &(p->page_link));
        }
        // 剩余空闲页的数目减n
        nr_free -= n;
        // 清除page的Page_property位，表示page已经被分配
        ClearPageProperty(page);
    }
    return page;
}
```

**5. 修改`default_free_pages`函数：**

default_free_pages函数的实现其实是default_alloc_pages的逆过程，不过需要考虑空闲块的合并问题。将页面重新链接到空闲列表中，可以将小的空闲块合并到大的空闲块中。

```c
static void
default_free_pages(struct Page *base, size_t n) {
    // n要大于0
    assert(n > 0);
    // 令p为连续地址的释放块的起始页
    struct Page *p = base;
    // 将这个释放块的每个页面初始化
    for (; p != base + n; p ++) {
        // 检查每一页的Page_reserved位和Page_property是否都未被设置
        assert(!PageReserved(p) && !PageProperty(p));
        // 设置每一页的flags都为0，表示可以分配
        p->flags = 0;
        // 设置每一页的ref都为0，表示这页空闲
        set_page_ref(p, 0);
    }
    // 释放块起始页的property连续空页数设置为n
    base->property = n;
    // 设置起始页的Page_property位
    SetPageProperty(base);
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = &free_list;
    // 遍历空闲链表，查看能否将释放块合并到合适的页块中
    while ((le = list_next(le)) != &free_list) {
        // 由链表元素获得对应的Page指针p
        p = le2page(le, page_link);
        // 如果释放块在下一个空闲块起始页的前面，那么进行合并
        if (base + base->property == p) {
            // 释放块的连续空页数要加上空闲块起始页p的连续空页数
            base->property += p->property;
            // 清除p的Page_property位，表示p不再是新的空闲块的起始页
            ClearPageProperty(p);
            // 将原来的空闲块删除
            list_del(&(p->page_link));
        }
        // 如果释放块的起始页在上一个空闲块的后面，那么进行合并
        else if (p + p->property == base) {
            // 空闲块的连续空页数要加上释放块起始页base的连续空页数
            p->property += base->property;
            // 清除base的Page_property位，表示base不再是起始页
            ClearPageProperty(base);
            // 新的空闲块的起始页变成p
            base = p;
            // 将原来的空闲块删除
            list_del(&(p->page_link));
        }
    }
    le = &free_list;
    // 遍历空闲链表，将合并好之后的页块加回空闲链表
    while ((le = list_next(le)) != &free_list) {
        // 由链表元素获得对应的Page指针p
        p = le2page(le, page_link);
        // 找到能够方向新的合并块的位置
        if (base + base->property <= p) {
            break;
        }
    }
    // 将空闲页的数目加n
    nr_free += n;
    // 将base->page_link此页链接到le中，插入合适位置
    list_add_before(le, &(base->page_link));
}
```

**6、检验：**

在终端输入make qemu指令：

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice1-04.png)

可以看到，内存成功分配，算法通过测试。

#### firstfit算法的改进

在进行分配以及释放内存的时候，在双向链表上进行操作的时间复杂度为O(n)，如果使用二叉搜索树对地址进行排序，从而对进程进行管理，就可以在查找页块时将时间复杂度降到O(logn)；

将较小的内存块及时合并到其它内存块中，也可以提高空间的利用率，从而使算法得到优化。

### lab2 练习2：实现寻找虚拟地址对应的页表项（需要编程）

通过设置页表和对应的页表项，可建立虚拟内存地址和物理内存地址的对应关系。其中的`get_pte`函数是设置页表项环节中的一个重要步骤。此函数找到一个虚地址对应的二级页表项的内核虚地址，如果此二级页表项不存在，则分配一个包含此项的二级页表。本练习需要补全`get_pte`函数 in `kern/mm/pmm.c`，实现其功能。请仔细查看和理解`get_pte`函数中的注释。`get_pte`函数的调用关系图如下所示：

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice2-01.png)

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

  + 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中每个组成部分的含义以及对ucore而言的潜在用处。
  + 如果ucore执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

#### 段页式管理基本概念

在保护模式中，x86 体系结构将内存地址分成三种：逻辑地址（也称虚地址）、线性地址和物理地址。逻辑地址即是程序指令中使用的地址，物理地址是实际访问内存的地址。逻 辑地址通过段式管理的地址映射可以得到线性地址，线性地址通过页式管理的地址映射得到物理地址。

段页式管理总体框架图：

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice2-02.png)

段式管理前一个实验已经讨论过。在 ucore 中段式管理只起到了一个过渡作用，它将逻辑地址不加转换直接映射成线性地址，所以我们在下面的讨论中可以对这两个地址不加区分（目前的 OS 实现也是不加区分的）。

页式管理将线性地址分成三部分（分页机制管理图中的 Linear Address 的 Directory 部分、 Table 部分和 Offset 部分）。ucore 的页式管理通过一个二级的页表实现。一级页表的起始物理地址存放在 cr3 寄存器中，这个地址必须是一个页对齐的地址，也就是低 12 位必须为 0。目前，ucore 用boot_cr3（mm/pmm.c）记录这个值。

分页机制管理：

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice2-03.png)

为了实现分页机制，需要建立好虚拟内存和物理内存的页映射关系，即正确建立二级页表。此过程涉及硬件细节，不同的地址映射关系组合，相对比较复杂。

#### 建立虚拟页和物理页帧的地址映射关系

##### 建立二级页表

整个页目录表和页表所占空间大小取决与二级页表要管理和映射的物理页数。假定当前物理内存0~16MB，每物理页（也称Page Frame）大小为4KB，则有4096个物理页，也就意味这有4个页目录项和4096个页表项需要设置。一个页目录项（Page Directory Entry，PDE）和一个页表项（Page Table Entry，PTE）占4B。即使是4个页目录项也需要一个完整的页目录表（占4KB）。而4096个页表项需要16KB（即4096*4B）的空间，也就是4个物理页，16KB的空间。所以对16MB物理页建立一一映射的16MB虚拟页，需要5个物理页，即20KB的空间来形成二级页表。

完成前一节所述的前两个阶段的地址映射变化后，为把0~KERNSIZE（明确ucore设定实际物理内存不能超过KERNSIZE值，即0x38000000字节，896MB，3670016个物理页）的物理地址一一映射到页目录项和页表项的内容，其大致流程如下：

  1. 指向页目录表的指针已存储在boot_pgdir变量中。
  2. 映射0~4MB的首个页表已经填充好。
  3. 调用boot_map_segment函数进一步建立一一映射关系，具体处理过程以页为单位进行设置，即

    linear addr = phy addr + 0xC0000000

设一个32bit线性地址la有一个对应的32bit物理地址pa，如果在以la的高10位为索引值的页目录项中的存在位（PTE_P）为0，表示缺少对应的页表空间，则可通过alloc_page获得一个空闲物理页给页表，页表起始物理地址是按4096字节对齐的，这样填写页目录项的内容为

    页目录项内容 = (页表起始物理地址 & ~0x0FFF) | PTE_U | PTE_W | PTE_P

进一步对于页表中以线性地址la的中10位为索引值对应页表项的内容为

    页表项内容 = (pa & ~0x0FFF) | PTE_P | PTE_W

其中：

  4. PTE_U：位3，表示用户态的软件可以读取对应地址的物理内存页内容
  5. PTE_W：位2，表示物理内存页内容可写
  6. PTE_P：位1，表示物理内存页存在

ucore的内存管理经常需要查找页表：给定一个虚拟地址，找出这个虚拟地址在二级页表中对应的项。通过更改此项的值可以方便地将虚拟地址映射到另外的页上。可完成此功能的这个函数是get_pte函数。它的原型为

    pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)

**1. 准备工作：**

根据注释的指引，可以找到实验用到的许多数据结构的定义和作用含义。

`PDX(la)`：返回虚拟地址la的页目录项索引
`KADDR(pa)`：获取pa的物理地址并返回相应的内核虚拟地址
`set_page_ref(page,1)`：表示此页被引用一次
`page2pa(page)`：获得page管理的那一页的物理内存地址
`struct Page * alloc_page()`：分配一页
`memset(void * s, char c, size_t n)`：设置s指向内存区域的前面n个字节为字符c
`PTE_P 0x001`：位1，表示物理内存页存在
`PTE_W 0x002`：位2，表示物理内存页内容可写
`PTE_U 0x004`：位3，表示用户态的软件可以读取对应地址的物理内存页内容

涉及到的三个类型`pte_t`、`pde_t`和`uintptr_t`。通过参见`mm/mmlayout.h`和`libs/types.h`，可知它们其实都是`unsigned int`类型。在此做区分，是为了分清概念。

```c
    typedef unsigned int uint32_t;
    typedef uint32_t uintptr_t;
    typedef uintptr_t pte_t;
    typedef uintptr_t pde_t;
```

**2. 按照注释的步骤，实现`get_pte`函数：**

`pde_t`全称为page directory entry，也就是一级页表的表项（注意：`pgdir`实际不是表项，而是一级页表本身。实际上应该新定义一个类型`pgd_t`来表示一级页表本身）。`pte_t`全称为 page table entry，表示二级页表的表项。`uintptr_t`表示为线性地址，由于段式管理只做直接映射，所以它也是逻辑地址。

`pgdir`给出页表起始地址。通过查找这个页表，我们需要给出二级页表中对应项的地址。虽然目前我们只有`boot_pgdir`一个页表，但是引入进程的概念之后每个进程都会有自己的页表。

有可能根本就没有对应的二级页表的情况，所以二级页表不必要一开始就分配，而是等到需要的时候再添加对应的二级页表。如果在查找二级页表项时，发现对应的二级页表不存在，则需要根据`create`参数的值来处理是否创建新的二级页表。如果`create`参数为`0`，则`get_pte`返回`NULL`；如果`create`参数不为`0`，则`get_pte`需要申请一个新的物理页（通过`alloc_page`来实现，可在`mm/pmm.h`中找到它的定义），再在一级页表中添加页目录项指向表示二级页表的新物理页。注意，新申请的页必须全部设定为零，因为这个页所代表的虚拟地址都没有被映射。

当建立从一级页表到二级页表的映射时，需要注意设置控制位。这里应该设置同时设置上`PTE_U`、`PTE_W`和`PTE_P`（定义可在`mm/mmu.h`）。如果原来就有二级页表，或者新建立了页表，则只需返回对应项的地址即可。

```c
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    pde_t *pdep = &pgdir[PDX(la)];  // (1) 首先找到页目录项，尝试获得页表
    if (!(*pdep & PTE_P)) {         // (2) 检查这个页目录项是否存在，存在则直接返回找到的页表项，如果不存在
        if (!create) {               // (3) 页目录项不存在且参数不要求创建新的页表，那么返回NULL
            return NULL;
        }
        struct Page *page = alloc_page();  // (3) 否则分配一个物理页存储创建的页表
        if (page == NULL) {  // (3) 如果分配失败，那么返回NULL
            return NULL;
        }
        set_page_ref(page, 1);               // (4) 设置物理页被引用一次
        uintptr_t pa = page2pa(page);        // (5) 获得物理页的线性物理地址
        memset(KADDR(pa), 0, PGSIZE);        // (6) 将物理地址转换成虚拟地址后，用memset函数清除页目录进行初始化
        *pdep = pa | PTE_U | PTE_W | PTE_P;  // (7) 设置页目录项的权限
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)]; // (8) 返回虚拟地址la对应的页表项入口地址
}
```
#### 请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中每个组成部分的含义以及对ucore而言的潜在用处。

##### 页目录项

组成如图所示：

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice2-04.png)

每个组成部分的含义：

|地址|页目录项组成部分|ucore中的对应以及对ucore而言的潜在用处|
|----|--------------|-------------------------------------|
|31:12|Page Table 4-kB aligned Address|这个页目录项对应的页表指向的物理页的物理地址，用于定位页表位置|
|11:9|Avail|PTE_AVAIL，保留给OS使用|
|8|Ignored|可忽略|
|7|Page Size(0 for 4kb)|PTE_PS，用于确认页的大小，0表示4kb|
|6|0|PTE_MBZ，恒为0，保留位信息|
|5|Accessed|PTE_A，用来表示页表是否被使用|
|4|Cache Disabled|PTE_PCD，表示是否对页表进行缓存|
|3|Write Through|PTE_PWT，表示缓存是否使用write through写策略|
|2|Use\Supervisor|PTE_U，表示访问该页需要的特权级|
|1|Read\Write|PTE_W，表示页表是否允许读写。内存分配和释放时需要置位|
|0|Present|PTE_P，是存在位，如果为1表示存在，如果为0表示不存在，需要再分配一个物理页给页表|

##### 页表项

组成如图所示：

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice2-05.png)

每个组成部分的含义：

|地址|页目录项组成部分|ucore中的对应以及对ucore而言的潜在用处|
|----|--------------|-------------------------------------|
|31:12|PAGE FRAME ADDRESS|页表项指向的物理页的物理地址，用于定位页表位置|
|11:9|AVAIL|PTE_AVAIL，保留给OS使用|
|8:7|0|PTE_MBZ，恒为0，保留位信息|
|6|Dirty|表示是否要在swap out的时候写回外存|
|5|Accessed|PTE_A，用来表示页表是否被访问|
|4:3|0|恒为0，保留位信息|
|2|Use\Supervisor|PTE_U，表示访问该页需要的特权级|
|1|Read\Write|PTE_W，表示页表是否允许读写。内存分配和释放时需要置位|
|0|Present|PTE_P，是存在位，如果为1表示存在，如果为0表示不存在，需要再分配一个物理页给页表|

对ucore而言的潜在用处：

页目录项和页表项中的保留位可以帮助ucore实现功能的扩展，可以用来进行内存管理，完成一些内存管理相关的算法，比如记录一段时间内被访问的次数，实现LRU等算法。

#### 如果ucore执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？

+ 将发生页访问异常的地址保存在cr2寄存器中;
+ 设置错误代码，向栈中压入EFLAGS，CS, EIP，和错误代码error code，如果发生在用户态，则之前还要先压入ss和esp，并切换到内核态；
+ 引发Page Fault，根据中断描述符表查询到对应Page Fault的ISR，跳转到对应的ISR处执行，进行Page Fault处理，将外存的数据换到内存中；
+ 进行上下文切换，返回中断之前的状态

### lab2 练习3：释放某虚地址所在的页并取消对应二级页表项的映射（需要编程）

当释放一个包含某虚地址的物理内存页时，需要让对应此物理内存页的管理数据结构Page做相关的清除处理，使得此物理内存页成为空闲；另外还需把表示虚地址与物理地址对应关系的二级页表项清除。请仔细查看和理解`page_remove_pte`函数中的注释。为此，需要补全在`kern/mm/pmm.c`中的`page_remove_pte`函数。`page_remove_pte`函数的调用关系图如下所示：

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice3-01.png)

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

+ 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？
+ 如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题

**1. 准备工作：**

根据注释的指引，可以找到实验用到的许多数据结构的定义和作用含义。

`struct Page *page pte2page(*ptep)`：获取ptep页表项对应的物理页
`free_page`：释放一页
`page_ref_dec(page)`：使得此页的引用数减一，并返回引用数，如果此页的引用数为0，那么应该被释放
`tlb_invalidate(pde_t *pgdir, uintptr_t la)`：当修改的页表是那些正在使用的页表，那么无效

`PTE_P 0x001`：位1，表示物理内存页存在

涉及到的两个个类型`pde_t`和`uintptr_t`。通过参见`mm/mmlayout.h`和`libs/types.h`，可知它们其实都是`unsigned int`类型。在此做区分，是为了分清概念。

```c
    typedef unsigned int uint32_t;
    typedef uint32_t uintptr_t;
    typedef uintptr_t pde_t;
```

**2. 按照注释的步骤，实现`page_remove_pte`函数：**

只有当一级二级页表的项都设置了用户写权限后，用户才能对对应的物理地址进行读写。所以我们可以在一级页表先给用户写权限，再在二级页表上面根据需要限制用户的权限，对物理页进行保护。由于一个物理页可能被映射到不同的虚拟地址上去（譬如一块内存在不同进程间共享），当这个页需要在一个地址上解除映射时，操作系统不能直接把这个页回收，而是要先看看它还有没有映射到别的虚拟地址上。这是通过查找管理该物理页的`Page`数据结构的成员变量`ref`（用来表示虚拟页到物理页的映射关系的个数）来实现的，如果`ref`为`0`了，表示没有虚拟页到物理页的映射关系了，就可以把这个物理页给回收了，从而这个物理页是free的了，可以再被分配。`page_insert`函数将物理页映射在了页表上。可参看`page_insert`函数的实现来了解ucore内核是如何维护这个变量的。当不需要再访问这块虚拟地址时，可以把这块物理页回收并在将来用在其他地方。取消映射由`page_remove`来做，这其实是`page_insert`的逆操作。

```c
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    if (*ptep & PTE_P) {                     // (1) 检查这个页目录项是否存在
        struct Page *page = pte2page(*ptep); // (2) 找到这个页目录项对应的页
        if (page_ref_dec(page) == 0) {       // (3) 将这个页的引用数减一
            free_page(page);                 // (4) 如果这个页的引用数为0，那么释放此页
        }
        *ptep = 0;                           // (5) 清除页目录项
        tlb_invalidate(pgdir, la);           // (6) 当修改的页表正在使用时，那么无效 
    }
}
```

#### 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？

答：有对应关系，因为每个页目录项记录了一个页表项的信息，每一个页表项也记录了一个物理页的信息，而数据结构Page的全局变量的每一项也记录一个物理页的信息，那么页目录项和页表项中保存的物理页面地址也会对应数据结构Page的全局变量的某一页。

#### 如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ 鼓励通过编程来具体完成这个问题

根据附录，lab1中通过ld工具形成的ucore的起始虚拟地址从`0x100000`开始，这个地址是虚拟地址，建立的段地址映射关系为对等关系，物理地址也是从`0x100000`开始，虚拟地址、线性地址以及物理地址相同，在lab2中建立了从虚拟地址到物理地址的映射，那么只需要取消映射，就可以实现虚拟地址以及物理地址相等。

首先找到`tools/kernel.ld`，将`tools/kernel.ld`改回lab1的数字，将链接脚本的`0xC0100000`改为`0x100000`：

    ENTRY(kern_init)

    SECTIONS {
                /* Load the kernel at this address: "." means the current address */
                . = 0x100000;

                .text : {
                        *(.text .stub .text.* .gnu.linkonce.t.*)
                }

然后按照lab1，将偏移量从`0xC0000000`改为`0`，并将开启页表关闭：

```c
#define KERNBASE 0x0
```

### 验证 lab2 练习1~3正确性

输入命令`make qemu`和`make grade`：

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice3-02.png)

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice3-03.png)

可以看到，程序编写正确。

### lab2 扩展练习Challenge：buddy system（伙伴系统）分配算法（需要编程）

Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...

+ 参考[伙伴分配器的一个极简实现](https://coolshell.cn/articles/10427.html)， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

#### 思考如何实现

伙伴分配的实质就是一种特殊的“分离适配”，即将内存按2的幂进行划分，相当于分离出若干个块大小一致的空闲链表，搜索该链表并给出同需求最佳匹配的大小。其优点是快速搜索合并（O(logN)时间复杂度）以及低外部碎片（最佳适配best-fit）；其缺点是内部碎片，因为按2的幂划分块，如果碰上66单位大小，那么必须划分128单位大小的块。但若需求本身就按2的幂分配，比如可以先分配若干个内存池，在其基础上进一步细分就很有吸引力了。

根据参考文章《伙伴分配器的一个极简实现》，我们可以使用一个数组形式的完全二叉树来管理内存，二叉树的节点用于标记相应内存块的使用状态，高层节点对应大的块，低层节点对应小的块，在分配和释放中我们就通过这些节点的标记属性来进行块的分离合并。如图所示，假设总大小为16单位的内存，我们就建立一个深度为5的满二叉树，根节点从数组下标[0]开始，监控大小16的块；它的左右孩子节点下标[1~2]，监控大小8的块；第三层节点下标[3~6]监控大小4的块……依此类推。

![](http://stugeek.gitee.io/operating-system/Labwork11-pictures/practice4-01.png)

在分配阶段，首先要搜索大小适配的块，假设第一次分配3，转换成2的幂是4，我们先要对整个内存进行对半切割，从16切割到4需要两步，那么从下标[0]节点开始深度搜索到下标[3]的节点并将其标记为已分配。第二次再分配3那么就标记下标[4]的节点。第三次分配6，即大小为8，那么搜索下标[2]的节点，因为下标[1]所对应的块被下标[3~4]占用了。

在释放阶段，我们依次释放上述第一次和第二次分配的块，即先释放[3]再释放[4]，当释放下标[4]节点后，我们发现之前释放的[3]是相邻的，于是我们立马将这两个节点进行合并，这样一来下次分配大小8的时候，我们就可以搜索到下标[1]适配了。若进一步释放下标[2]，同[1]合并后整个内存就回归到初始状态。

### lab2 扩展练习Challenge：任意大小的内存单元slub分配算法（需要编程）

slub算法，实现两层架构的高效内存单元分配，第一层是基于页大小的内存分配，第二层是在第一层基础上实现基于任意大小的内存分配。可简化实现，能够体现其主体思想即可。

+ 参考[linux的slub分配算法](https://www.cnblogs.com/papam/archive/2009/08/25/1553733.html)实现slub分配算法。要求有比较充分的测试用例说明实现的正确性，需要有设计文档。

#### 思考如何实现

根据参考文章《linux的slub分配算法》中的SLUB分配器，可以实现分配和释放等功能。

SLAB 分配器为每种使用的内核对象建立单独的缓冲区。每种缓冲区由多个 slab 组成，每个 slab就是一组连续的物理内存页框，被划分成了固定数目的对象。根据对象大小的不同，缺省情况下一个 slab 最多可以由 1024 个物理内存页框构成。

内核使用 kmem_cache 数据结构管理缓冲区。由于 kmem_cache 自身也是一种内核对象，所以需要一个专门的缓冲区。所有缓冲区的 kmem_cache 控制结构被组织成以 cache_chain 为队列头的一个双向循环队列，同时 cache_cache 全局变量指向kmem_cache 对象缓冲区的 kmem_cache 对象。每个 slab 都需要一个类型为 struct slab 的描述符数据结构管理其状态，同时还需要一个 kmem_bufctl_t（被定义为无符号整数）的结构数组来管理空闲对象。如果对象不超过 1/8 个物理内存页框的大小，那么这些 slab 管理结构直接存放在 slab 的内部，位于分配给 slab 的第一个物理内存页框的起始位置；否则的话，存放在 slab 外部，位于由 kmalloc 分配的通用对象缓冲区中。

slab 中的对象有 2 种状态：已分配或空闲。为了有效地管理 slab，根据已分配对象的数目，slab 可以有 3 种状态，动态地处于缓冲区相应的队列中：

  1. Full 队列，此时该 slab 中没有空闲对象。
  2. Partial 队列，此时该 slab 中既有已分配的对象，也有空闲对象。
  3. Empty 队列，此时该 slab 中全是空闲对象。

在 SLUB 分配器中，一个 slab 就是一组连续的物理内存页框，被划分成了固定数目的对象。slab 没有额外的空闲对象队列（这与 SLAB 不同），而是重用了空闲对象自身的空间。slab 也没有额外的描述结构，因为 SLUB 分配器在代表物理页框的 page 结构中加入 freelist，inuse 和 slab 的 union 字段，分别代表第一个空闲对象的指针，已分配对象的数目和缓冲区 kmem_cache 结构的指针，所以 slab 的第一个物理页框的 page 结构就可以描述自己。

每个处理器都有一个本地的活动 slab，由 kmem_cache_cpu 结构描述。

**分配时：**

`slab_alloc`函数：

```c
static __always_inline void *slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node, void *addr)
{
    void **object;
    struct kmem_cache_cpu *c;
    unsigned long flags;

    local_irq_save(flags);
    c = get_cpu_slab(s, smp_processor_id()); // (a)
    if (unlikely(!c->freelist || !node_match(c, node)))
        object = __slab_alloc(s, gfpflags, node, addr, c); // (b)
    else {
        object = c->freelist; // (c)
        c->freelist = object[c->offset];
        stat(c, ALLOC_FASTPATH);
    }
    local_irq_restore(flags);

    if (unlikely((gfpflags & __GFP_ZERO) && object))
        memset(object, 0, c->objsize);

    return object; // (d)
}
```
  1. 获取本处理器的 kmem_cache_cpu 数据结构。
  2. 假如当前活动 slab 没有空闲对象，或本处理器所在节点与指定节点不一致，则调用 __slab_alloc 函数。
  3. 获得第一个空闲对象的指针，然后更新指针使其指向下一个空闲对象。
  4. 返回对象地址。

`__slab_alloc`函数：

```c
static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node, void *addr, struct kmem_cache_cpu *c)
{
    void **object;
    struct page *new;

    gfpflags &= ~__GFP_ZERO;

    if (!c->page) // (a)
        goto new_slab;

    slab_lock(c->page);
    if (unlikely(!node_match(c, node))) // (b)
        goto another_slab;

    stat(c, ALLOC_REFILL);

    load_freelist:
    object = c->page->freelist;
    if (unlikely(!object)) // (c)
        goto another_slab;
    if (unlikely(SlabDebug(c->page)))
        goto debug;

    c->freelist = object[c->offset]; // (d)
    c->page->inuse = s->objects;
    c->page->freelist = NULL;
    c->node = page_to_nid(c->page);
    unlock_out:
    slab_unlock(c->page);
    stat(c, ALLOC_SLOWPATH);
    return object;

    another_slab:
    deactivate_slab(s, c); // (e)

    new_slab:
    new = get_partial(s, gfpflags, node); // (f)
    if (new) {
        c->page = new;
        stat(c, ALLOC_FROM_PARTIAL);
        goto load_freelist;
    }

    if (gfpflags & __GFP_WAIT) // (g)
        local_irq_enable();

    new = new_slab(s, gfpflags, node); // (h)

    if (gfpflags & __GFP_WAIT)
        local_irq_disable();

    if (new) {
        c = get_cpu_slab(s, smp_processor_id());
        stat(c, ALLOC_SLAB);
        if (c->page)
            flush_slab(s, c);
        slab_lock(new);
        SetSlabFrozen(new);
        c->page = new;
        goto load_freelist;
    }
    if (!(gfpflags & __GFP_NORETRY) && (s->flags & __PAGE_ALLOC_FALLBACK)) {
        if (gfpflags & __GFP_WAIT)
            local_irq_enable();
        object = kmalloc_large(s->objsize, gfpflags); // (i)
        if (gfpflags & __GFP_WAIT)
            local_irq_disable();
            return object;
    }
    return NULL;
    debug:
    if (!alloc_debug_processing(s, c->page, object, addr))
        goto another_slab;

    c->page->inuse++;
    c->page->freelist = object[c->offset];
    c->node = -1;
    goto unlock_out;
}
```

  1. 如果没有本地活动 slab，转到 (f) 步骤获取 slab 。
  2. 如果本处理器所在节点与指定节点不一致，转到 (e) 步骤。
  3. 检查处理器活动 slab 没有空闲对象，转到 (e) 步骤。
  4. 此时活动 slab 尚有空闲对象，将 slab 的空闲对象队列指针复制到 kmem_cache_cpu 结构的 freelist 字段，把 slab 的空闲对象队列指针设置为空，从此以后只从 kmem_cache_cpu 结构的 freelist 字段获得空闲对象队列信息。
  5. 取消当前活动 slab，将其加入到所在 NUMA 节点的 Partial 队列中。
  6. 优先从指定 NUMA 节点上获得一个 Partial slab。
  7. 加入 gfpflags 标志置有 __GFP_WAIT，开启中断，故后续创建 slab 操作可以睡眠。
  8. 创建一个 slab，并初始化所有对象。
  9. 如果内存不足，无法创建 slab，调用 kmalloc_large（实际调用物理页框分配器）分配对象。

**释放时：**

`slab_free`函数：

```c
static __always_inline void slab_free(struct kmem_cache *s, struct page *page, void *x, void *addr)
{
    void **object = (void *)x;
    struct kmem_cache_cpu *c;
    unsigned long flags;

    local_irq_save(flags);
    c = get_cpu_slab(s, smp_processor_id());
    debug_check_no_locks_freed(object, c->objsize);
    if (likely(page == c->page && c->node >= 0)) { // (a)
        object[c->offset] = c->freelist;
        c->freelist = object;
        stat(c, FREE_FASTPATH);
    } else
        __slab_free(s, page, x, addr, c->offset); // (b)

    local_irq_restore(flags);
}
```

1. 如果对象属于处理器当前活动的 slab，或处理器所在 NUMA 节点号不为 -1（调试使用的值），将对象放回空闲对象队列。
2. 否则调用 __slab_free 函数。

`__slab_free`函数：

```c
static void __slab_free(struct kmem_cache *s, struct page *page,
void *x, void *addr, unsigned int offset)
{
    void *prior;
    void **object = (void *)x;
    struct kmem_cache_cpu *c;

    c = get_cpu_slab(s, raw_smp_processor_id());
    stat(c, FREE_SLOWPATH);
    slab_lock(page);

    if (unlikely(SlabDebug(page)))
        goto debug;

    checks_ok:
    prior = object = page->freelist; // (a)
    page->freelist = object;
    page->inuse--;

    if (unlikely(SlabFrozen(page))) {
        stat(c, FREE_FROZEN);
        goto out_unlock;
    }

    if (unlikely(!page->inuse)) // (b)
        goto slab_empty;

    if (unlikely(!prior)) { // (c)
        add_partial(get_node(s, page_to_nid(page)), page, 1);
        stat(c, FREE_ADD_PARTIAL);
    }

    out_unlock:
    slab_unlock(page);
    return;

    slab_empty:
    if (prior) { // (d)
        remove_partial(s, page);
        stat(c, FREE_REMOVE_PARTIAL);
    }
    slab_unlock(page);
    stat(c, FREE_SLAB);
    discard_slab(s, page);
    return;

    debug:
    if (!free_debug_processing(s, page, x, addr))
        goto out_unlock;
    goto checks_ok;
}
```

   1. 执行本函数表明对象所属 slab 并不是某个活动 slab。保存空闲对象队列的指针，将对象放回此队列，最后把已分配对象数目减一。
   2. 如果已分配对象数为 0，说明 slab 处于 Empty 状态，转到 (d) 步骤。
   3. 如果原空闲对象队列的指针为空，说明 slab 原来的状态为 Full，那么现在的状态应该是 Partial，将该 slab 加到所在节点的 Partial 队列中。
   4. 如果 slab 状态转为 Empty，且先前位于节点的 Partial 队列中，则将其剔出并释放所占内存空间。