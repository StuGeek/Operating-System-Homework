# 操作系统实验报告17

## 实验内容

+ 实验内容：虚拟存储管理。
  + 编写一个 C 程序模拟实现课件 Lecture24 中的请求页面置换算法
    + 包括FIFO、LRU (stack and matrix implementation)、Second chance，并设计输入用例验证结果。

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### 实验内容原理

+ 页面置换通过在内存中找到一些实际上没有使用的页，并将其调出置换。
  + 通过修改页面错误服务例程以包括页面替换，防止内存过度分配。
  + 使用修改位（脏位）来减少页面传输的开销，因为只有修改过的页面才会写回磁盘。
+ 页面置换完成了逻辑内存和物理内存之间的分离，使得可以在较小的物理内存上提供较大的虚拟内存。
+ 页面置换采用以下方法。如果没有空闲帧，那么就查找当前不在使用的一个帧，并释放它。可以这样来释放一个帧：将其内容写到交换空间，并修改页表（和所有其他表），以表示该页不在内存中。现在可使用空闲帧，来保存进程出错的页面。修改缺页错误处理程序，以包括页面置换：
    1. 找到所需页面的磁盘位置。
    2. 找到一个空闲帧：
        a. 如果有空闲帧，那么就使用它。
        b. 如果没有空闲帧，那么就使用页面置换算法来选择一个牺牲帧。
        c. 将牺牲帧的内容写到磁盘上，修改对应的页表和帧表。
    3. 将所需页面读入（新的）空闲帧，修改页表和帧表。
    4. 从发生缺页错误位置，继续用户进程。
+ 请注意，如果没有空闲帧，那么需要两个页面传输（一个调出，一个调入）。这种情况实际上加倍了缺页错误处理时间，并相应地增加了有效访问时间。
+ 页面置换算法
  + FIFO页面置换
    + FIFO页面置换算法为每个页面记录了调到内存的时间。当必须置换页面时，将选择最旧的页面。请注意，并不需要记录调入页面的确切时间。可以创建一个FIFO队列，来管理所有的内存页面。置换的是队列的首个页面。当需要调入页面到内存时，就将它加到队列的尾部。
    + FIFO页面置换算法容易实现，只需要一个在进程的页框架中循环的指针。
    + 例子：
    + ![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/1.png)
  + Belady异常：对于有些置换算法，随着分配帧的数量的增加，缺页错误率可能会增加。
  + LRU页面置换
    + 实现LRU置换的一种方法是采用页码堆栈。每当页面被引用时，它就从堆栈中移除并放在顶部。这样，最近使用的页面总是在堆栈的顶部，最近最少使用的页面总是在底部。因为必须从堆栈的中间删除条目，所以最好通过使用具有首指针和尾指针的双向链表来实现这种方法。这样，删除一个页面并放在堆栈顶部，在最坏情况下需要改变6个指针。虽说每次更新有点费时，但是置换不需要搜索；指a前的堆栈b之后的堆栈针指向堆栈的底部，这是LRU页面。这种方法特别适用于LRU置换的软件或微代码实现。
    + 实现LRU置换的另一种方法是采用矩阵。用矩阵的方法来实现LRU算法的思想是使用矩阵来记录页面使用的频率和时间。设矩阵是 n×n 维的，n是相关程序当前驻内存的页面数。矩阵的初值为0，每次访问一个页面，例如第i个虛拟页被访问时，可对矩阵进行如下操作：
        一是将第i行的值全部置1；
        二是将第i列的值全部置一是将第i行的值全部置0；
    在每次需要更换页面时，选择矩阵里对应行值最小的页面。行值是指把此行所有的01代码连起来作为二进制的取值。
    + 例子：
    + ![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/2.png)
  + 第二次机会算法
    + 第二次机会置换的基本算法是一种FIFO置换算法。然而，当选择了一个页面时，需要检査其引用位。如果值为0，那么就直接置换此页面;如果引用位设置为1，那么就给此页面第二次机会，并继续选择下一个FIFO页面。当一个页面获得第二次机会时，其引用位被清除，并且到达时间被设为当前时间。因此，获得第二次机会的页面，在所有其他页面被置换（或获得第二次机会）之前，不会被置换。此外，如果一个页面经常使用以致于其引用位总是得到设置，那么它就不会被置换。
    + 实现第二次机会算法（有时称为时钟算法的一种方式是采用循环队列。指针（即时钟指针）指示接下来要置换哪个页面。当需要一个帧时，指针向前移动直到找到一个引用位为0的页面。在向前移动时，它会清除引用位。一旦找到牺牲页面，就置换该页面，并且在循环队列的这个位置上插入新页面。注意，在最坏的情况下，当所有位都已设置，指针会循环遍历整个队列，给每个页面第二次机会。在选择下一个页面进行置换之前，它将清除所有引用位。如果所有位都为1，第二次机会置换退化为FIFO替换。
    + 例子：
    + ![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/3.png)
    + ![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/4.png)

### 设计报告

#### 代码设计

```c
// page_replacement.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define REFERENCE_STRING_LENGTH 20  // 引用串长度
#define PAGE_SIZE 10                // 页的大小
#define FRAME_SIZE 5                // 页帧大小

typedef struct page_node_LRU {
    int page_num;                // 页码数字
    int page_index;              // 页在页帧中的下标
    struct page_node_LRU *pre;   // 指向上一个点结构的指针
    struct page_node_LRU *next;  // 指向下一个点结构的指针
} PageNode_LRU;  // 用堆栈实现的LRU算法所使用的表示页的点结构

typedef struct {
    PageNode_LRU *head;  // 双向链表表头
    PageNode_LRU *tail;  // 双向链表表尾
} PageStack;  // 用双向链表实现的LRU算法所使用的堆栈

typedef struct page_node_second_chance {
    int page_num;                          // 页码数字
    int page_index;                        // 页在页帧中的下标
    int reference_bit;                     // 引用位
    struct page_node_second_chance *next;  // 指向下一个点结构的指针
} PageNode_Second_Chance; // 第二次机会算法所使用的表示页的点结构

typedef struct {
    PageNode_Second_Chance *head;           // 队列队头
    PageNode_Second_Chance *clock_pointer;  // 时钟指针，指向下个牺牲帧
} PageQueue;  // 第二次机会算法所使用的循环队列

// FIFO页面置换算法使用的函数
void FIFO(int *reference_string);

// 用堆栈实现的LRU页面置换算法使用的函数
PageNode_LRU *creat_PageNode_LRU(int page_num, int page_index);
void init_PageStack(PageStack *stk);
void free_PageStack(PageStack *stk);
void print_LRU_stack(PageStack *stack);
void LRU_stack(int *reference_string);

// 用矩阵实现的LRU页面置换算法使用的函数
void setrow1(int matrix[FRAME_SIZE][FRAME_SIZE], int row);
void setcolumn0(int matrix[FRAME_SIZE][FRAME_SIZE], int column);
int find_least_row(int matrix[FRAME_SIZE][FRAME_SIZE]);
void print_LRU_matrix(int matrix[FRAME_SIZE][FRAME_SIZE]);
void LRU_matrix(int *reference_string);

// 第二次机会页面置换算法使用的函数
PageNode_Second_Chance *creat_PageNode_Second_Chance(int page_num, int page_index);
void init_PageQueue(PageQueue *queue);
void free_PageQueue(PageQueue *queue);
void print_PageQueue(PageQueue *queue);
void Second_Chance(int *reference_string);

// 打印页帧信息
void print_pageframe(int *page_frame);
// 打印引用串
void print_reference_string(int *reference_string);

// 打印页帧信息
void print_pageframe(int *page_frame) {
    for (int i = 0; i < FRAME_SIZE; ++i) {
        printf("|");
        if (page_frame[i] != -1) {
            printf("%d", page_frame[i]);
        } else {
            printf(" ");
        }
        if (i == FRAME_SIZE - 1) {
            printf("|");
        }
    }
}

// FIFO页面置换算法
void FIFO(int *reference_string) {
    printf("\n---------------------------------------\n");
    printf("page-replacement algorithm: FIFO\n\n");
    
    // 初始化页帧中页码数字都为-1
    int page_frame[FRAME_SIZE];
    memset(page_frame, -1, sizeof(page_frame));
    int replace_index = 0;
    int j = 0;

    for (int i = 0; i < REFERENCE_STRING_LENGTH; ++i) {
        int page_num = reference_string[i];
        printf("%d: ", reference_string[i]);

        for (j = 0; j < FRAME_SIZE; ++j) {
            // 如果页帧中已经有要引用的页面，那么没有发生缺页错误，不用进行页面置换
            if (page_frame[j] == page_num) {
                print_pageframe(page_frame);
                printf(", no page fault\n");
                break;
            }
        }
        // 如果页帧中没有要引用的页面，那么发生缺页错误，要进行页面置换
        if (j == FRAME_SIZE) {
            // 将页帧中对应下标的页码改为要引用的页面的页码
            page_frame[replace_index] = page_num;
            // 下一个牺牲帧的下标为页帧中的下一个循环下标
            replace_index = (replace_index + 1) % FRAME_SIZE;
            print_pageframe(page_frame);
            printf(", page fault\n");
        }
    }

    printf("---------------------------------------\n");
}

// 创建用堆栈实现的LRU算法所使用的表示页的点结构
PageNode_LRU *creat_PageNode_LRU(int page_num, int page_index) {
    PageNode_LRU *new_node = (PageNode_LRU *)malloc(sizeof(PageNode_LRU));
    new_node->pre = NULL;
    new_node->next = NULL;
    new_node->page_num = page_num;
    new_node->page_index = page_index;
    return new_node;
}

// 初始化用双向链表实现的LRU算法所使用的堆栈
void init_PageStack(PageStack *stk) {
    // 按照页帧中下标的对应关系创建与页帧大小相同的堆栈
    stk->head = creat_PageNode_LRU(-1, 0);
    PageNode_LRU *cur_node = stk->head;
    for (int i = 1; i < FRAME_SIZE; ++i) {
        PageNode_LRU *new_node = creat_PageNode_LRU(-1, i);
        cur_node->next = new_node;
        new_node->pre = cur_node;
        cur_node = new_node;
    }
    stk->tail = cur_node;
}

// 释放用双向链表实现的LRU算法所使用的堆栈的动态内存
void free_PageStack(PageStack *stk) {
    PageNode_LRU *t = stk->head;
    while (t != NULL) {
        PageNode_LRU *temp = t;
        t = t->next;
        free(temp);
        temp = NULL;
    }
}

// 打印用双向链表实现的LRU算法所使用的堆栈的内容
void print_LRU_stack(PageStack *stack) {
    PageNode_LRU *cur_node = stack->head;
    printf("LRU stack: ");
    while (cur_node != NULL) {
        printf("|");
        if (cur_node->page_num != -1) {
            printf("%d", cur_node->page_num);
        } else {
            printf(" ");
        }
        if (cur_node->next == NULL) {
            printf("|");
        }
        cur_node = cur_node->next;
    }
    printf("(top)\n");
}

// 用堆栈实现的LRU算法
void LRU_stack(int *reference_string) {
    printf("\n------------------------------------------------------------------\n");
    printf("page-replacement algorithm: LRU implemented by stack\n\n");

    // 初始化页帧中页码数字都为-1
    int page_frame[FRAME_SIZE];
    memset(page_frame, -1, sizeof(page_frame));

    PageStack stack;
    init_PageStack(&stack);

    for (int i = 0; i < REFERENCE_STRING_LENGTH; ++i) {
        int page_num = reference_string[i];
        printf("%d: ", reference_string[i]);

        PageNode_LRU *cur_node = stack.head;

        while (cur_node != NULL) {
            // 如果页帧中已经有要引用的页面，那么没有发生缺页错误，不用进行页面置换
            if (cur_node->page_num == page_num) {
                if (cur_node != stack.tail) {
                    // 将这个要引用的页面放到双向链表的表尾，即堆栈的栈顶
                    if (cur_node->pre != NULL) {
                        cur_node->pre->next = cur_node->next;
                    }
                    if (cur_node->next != NULL) {
                        cur_node->next->pre = cur_node->pre;
                    }
                    stack.tail->next = cur_node;
                    cur_node->pre = stack.tail;
                    if (cur_node == stack.head) {
                        stack.head = cur_node->next;
                    }
                    cur_node->next = NULL;
                    stack.tail = cur_node;
                }
                print_pageframe(page_frame);
                printf(", no page fault, ");
                print_LRU_stack(&stack);
                break;
            }
            cur_node = cur_node->next;
        }

        // 如果页帧中没有要引用的页面，那么发生缺页错误，要进行页面置换
        if (cur_node == NULL) {
            // 将堆栈的栈底作为牺牲帧，替换新的引用页面，并把这个页面放到堆栈顶端
            PageNode_LRU *old_head = stack.head;
            stack.head = stack.head->next;
            stack.head->pre = NULL;

            old_head->page_num = page_num;
            page_frame[old_head->page_index] = page_num;
            stack.tail->next = old_head;
            old_head->pre = stack.tail;
            old_head->next = NULL;
            stack.tail = old_head;

            print_pageframe(page_frame);
            printf(", page fault, ");
            print_LRU_stack(&stack);
        }
    }

    free_PageStack(&stack);

    printf("------------------------------------------------------------------\n");
}

// 将二维矩阵的某一行全部设置为1
void setrow1(int matrix[FRAME_SIZE][FRAME_SIZE], int row) {
    for (int i = 0; i < FRAME_SIZE; ++i) {
        matrix[row][i] = 1;
    }
}

// 将二维矩阵的某一列处与列号相等的那一行外全部设置为1
void setcolumn0(int matrix[FRAME_SIZE][FRAME_SIZE], int column) {
    for (int i = 0; i < FRAME_SIZE; ++i) {
        if (i != column) {
            matrix[i][column] = 0;
        }
    }
}

// 找到二维矩阵中1的个数最少的那一行
int find_least_row(int matrix[FRAME_SIZE][FRAME_SIZE]) {
    int least_one_sum = FRAME_SIZE;
    int least_row = 0;
    for (int i = 0; i < FRAME_SIZE; ++i) {
        int one_sum = 0;
        for (int j = 0; j < FRAME_SIZE; ++j) {
            if (matrix[i][j] == 1) {
                one_sum++;
            }
        }
        if (one_sum < least_one_sum) {
            least_one_sum = one_sum;
            least_row = i;
        }
    }
    return least_row;
}

// 打印用矩阵实现的LRU算法的二维矩阵
void print_LRU_matrix(int matrix[FRAME_SIZE][FRAME_SIZE]) {
    printf("LRU matrix:\n");
    for (int i = 0; i < FRAME_SIZE; ++i) {
        for (int j = 0; j < FRAME_SIZE; ++j) {
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }
}

// 用矩阵实现的LRU算法
void LRU_matrix(int *reference_string) {
    printf("\n------------------------------------------------------------------\n");
    printf("page-replacement algorithm: LRU implemented by matrix\n\n");

    // 初始化页帧中页码数字都为-1
    int page_frame[FRAME_SIZE];
    memset(page_frame, -1, sizeof(page_frame));

    // 初始化二维矩阵所有元素都为0
    int matrix[FRAME_SIZE][FRAME_SIZE];
    memset(matrix, 0, sizeof(matrix));

    for (int i = 0; i < REFERENCE_STRING_LENGTH; ++i) {
        int page_num = reference_string[i];
        printf("%d: ", reference_string[i]);

        int j = 0;        
        for (j = 0; j < FRAME_SIZE; ++j) {
            // 如果页帧中已经有要引用的页面，那么没有发生缺页错误，不用进行页面置换
            if (page_frame[j] == page_num) {
                // 将引用的页面在页帧中的下标的那一行的所有元素都设置为1
                setrow1(matrix, j);
                // 将引用的页面在页帧中的下标的那一列的所有元素都设置为0
                setcolumn0(matrix, j);
                print_pageframe(page_frame);
                printf(", no page fault\n");
                print_LRU_matrix(matrix);
                break;
            }
        }

        // 如果页帧中没有要引用的页面，那么发生缺页错误，要进行页面置换
        if (j == FRAME_SIZE) {
            // 找到1的个数最少的那一行，那一行的行号即为牺牲帧在页帧中的下标
            int least_one_row = find_least_row(matrix);
            page_frame[least_one_row] = page_num;
            // 将引用的页面在页帧中的下标的那一行的所有元素都设置为1
            setrow1(matrix, least_one_row);
            // 将引用的页面在页帧中的下标的那一列的所有元素都设置为0
            setcolumn0(matrix, least_one_row);
            print_pageframe(page_frame);
            printf(", page fault\n");
            print_LRU_matrix(matrix);
        }
    }

    printf("------------------------------------------------------------------\n");
}

// 创建第二次机会页面算法所使用的表示页的点结构
PageNode_Second_Chance *creat_PageNode_Second_Chance(int page_num, int page_index) {
    PageNode_Second_Chance *new_node = (PageNode_Second_Chance *)malloc(sizeof(PageNode_Second_Chance));
    new_node->next = NULL;
    new_node->page_num = page_num;
    new_node->page_index = page_index;
    new_node->reference_bit = 0;
    return new_node;
}

// 初始化第二次机会算法所使用的循环队列
void init_PageQueue(PageQueue *queue) {
    // 按照页帧中下标的对应关系创建与页帧大小相同的循环队列
    queue->head = creat_PageNode_Second_Chance(-1, 0);
    PageNode_Second_Chance *cur_node = queue->head;
    for (int i = 1; i < FRAME_SIZE; ++i) {
        PageNode_Second_Chance *new_node = creat_PageNode_Second_Chance(-1, i);
        cur_node->next = new_node;
        cur_node = new_node;
    }
    cur_node->next = queue->head;
    queue->clock_pointer = queue->head;
}

// 释放第二次机会算法所使用的循环队列的动态内存
void free_PageQueue(PageQueue *queue) {
    PageNode_Second_Chance *t = queue->head;
    for (int i = 0; i < FRAME_SIZE; ++i) {
        PageNode_Second_Chance *temp = t;
        t = t->next;
        free(temp);
        temp = NULL;
    }
}

// 打印第二次机会算法所使用的循环队列的内容
void print_PageQueue(PageQueue *queue) {
    PageNode_Second_Chance *cur_node = queue->head;
    printf("page queue: ");
    for (int i = 0; i < FRAME_SIZE; ++i) {
        printf("|");
        if (cur_node->page_num != -1) {
            printf("%d", cur_node->page_num);
            if (cur_node->reference_bit == 1) {
                printf("*");
            }
            if (queue->clock_pointer == cur_node) {
                printf("(C)");
            }
        } else {
            if (queue->clock_pointer == cur_node) {
                printf("(C)");
            } else {
                printf(" ");
            }
        }
        if (i == FRAME_SIZE - 1) {
            printf("|");
        }
        cur_node = cur_node->next;
    }
    printf("\n");
}

// 第二次机会算法
void Second_Chance(int *reference_string) {
    printf("\n------------------------------------------------------------------\n");
    printf("page-replacement algorithm: Second chance\n");
    printf("(\"*\" means the reference bit is 1, \"(C)\" means the clock pointer's position)\n\n");

    // 初始化页帧中页码数字都为-1
    int page_frame[FRAME_SIZE];
    memset(page_frame, -1, sizeof(page_frame));

    PageQueue queue;
    init_PageQueue(&queue);

    for (int i = 0; i < REFERENCE_STRING_LENGTH; ++i) {
        int page_num = reference_string[i];
        printf("%d: ", reference_string[i]);

        PageNode_Second_Chance *cur_node = queue.head;
        for (int j = 0; j < FRAME_SIZE; ++j) {
            // 如果页帧中已经有要引用的页面，那么没有发生缺页错误，不用进行页面置换
            if (cur_node->page_num == page_num) {
                // 将这个引用的页面的引用位设置为1
                cur_node->reference_bit = 1;
                print_pageframe(page_frame);
                printf(", no page fault, ");
                print_PageQueue(&queue);         
                break;
            }
            cur_node = cur_node->next;
        }

        // 如果页帧中没有要引用的页面，那么发生缺页错误，要进行页面置换
        if (cur_node->page_num == page_num) {
            continue;
        }
        // 从时钟指针开始，找到下一个引用位为0的页面，作为牺牲帧
        while (queue.clock_pointer->reference_bit != 0) {
            queue.clock_pointer->reference_bit = 0;
            queue.clock_pointer = queue.clock_pointer->next;
        }

        // 找到引用位为0的页面后，替换新的引用页面
        page_frame[queue.clock_pointer->page_index] = page_num;
        queue.clock_pointer->page_num = page_num;
        queue.clock_pointer->reference_bit = 1;
        // 时钟指针指向下一个页面
        queue.clock_pointer = queue.clock_pointer->next;

        print_pageframe(page_frame);
        printf(", page fault, ");
        print_PageQueue(&queue);
    }

    free_PageQueue(&queue);

    printf("------------------------------------------------------------------\n");
}

// 打印引用串
void print_reference_string(int *reference_string) {
    printf("reference_string:\n");
    for (int i = 0; i < REFERENCE_STRING_LENGTH; ++i) {
        printf("%d ", reference_string[i]);
    }
    printf("\n");
}

int main() {
    int reference_string[REFERENCE_STRING_LENGTH];

    // 生成随机数的方式产生测试样例
    srand((unsigned) time(NULL));
    for (int i = 0; i < REFERENCE_STRING_LENGTH; ++i) {
        int num = rand() % PAGE_SIZE;
        reference_string[i] = num;
    }

    // 手动输入的方式产生测试样例
    /*printf("Please input the reference string(length = %d):\n", REFERENCE_STRING_LENGTH);
    for (int i = 0; i < REFERENCE_STRING_LENGTH; ++i) {
        scanf("%d", reference_string[i]);
    }*/

    print_reference_string(reference_string);
    
    FIFO(reference_string);
    LRU_stack(reference_string);
    LRU_matrix(reference_string);
    Second_Chance(reference_string);
}
```

执行命令：

    gcc page_replacement.c
    ./a.out

#### 验证各个调度算法的正确性

在宏定义处设置输入的引用串的长度、页的大小、页帧大小：

    #define REFERENCE_STRING_LENGTH 20  // 引用串长度
    #define PAGE_SIZE 10                // 页的大小
    #define FRAME_SIZE 5                // 页帧大小

**测试用例1：**

    #define REFERENCE_STRING_LENGTH 10  // 引用串长度
    #define PAGE_SIZE 5                // 页的大小
    #define FRAME_SIZE 3                // 页帧大小

    3 2 0 1 2 1 2 4 1 1 

**FIFO页面置换算法：**

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/5.png)

可以看到，
一开始，引用串的前三个页码3、2、0被放到页帧的三个空闲帧中，按照FIFO置换，此时牺牲帧应该为第一个帧；
下一个引用页是1，替换第一个帧3，变成1、2、0，下一个牺牲帧应该为第二个帧；
下一个引用页是2，在页帧中有，下一个牺牲帧应该为第二个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第二个帧；
下一个引用页是2，在页帧中有，下一个牺牲帧应该为第二个帧；
下一个引用页是4，替换第二个帧2，变成1、4、0，下一个牺牲帧应该为第三个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第三个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第三个帧；

过程符合FIFO页面置换算法。

**用堆栈实现的LRU页面置换算法：**

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/6.png)

可以看到，
一开始，引用串的前三个页码3、2、0被放到页帧的三个空闲帧中，按照LRU算法，此时牺牲帧应该为第一个帧；
下一个引用页是1，替换第一个帧3，变成1、2、0，下一个牺牲帧应该为第二个帧；
下一个引用页是2，在页帧中有，下一个牺牲帧应该为第三个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第三个帧；
下一个引用页是2，在页帧中有，下一个牺牲帧应该为第三个帧；
下一个引用页是4，替换第三个帧0，变成1、2、4，下一个牺牲帧应该为第一个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第二个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第二个帧；

过程符合用堆栈实现的LRU页面置换算法。

**用矩阵实现的LRU页面置换算法：**

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/7.png)

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/8.png)

可以看到，
一开始，引用串的前三个页码3、2、0被放到页帧的三个空闲帧中，按照LRU算法，此时牺牲帧应该为第一个帧；
下一个引用页是1，替换第一个帧3，变成1、2、0，下一个牺牲帧应该为第二个帧；
下一个引用页是2，在页帧中有，下一个牺牲帧应该为第三个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第三个帧；
下一个引用页是2，在页帧中有，下一个牺牲帧应该为第三个帧；
下一个引用页是4，替换第三个帧0，变成1、2、4，下一个牺牲帧应该为第一个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第二个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第二个帧；

过程符合用矩阵实现的LRU页面置换算法。

**第二次机会页面置换算法：**

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/9.png)

可以看到，
一开始，引用串的前三个页码3、2、0被放到页帧的三个空闲帧中，三个帧的引用位都为1。
下一个引用页是1，时钟指针在循环队列中找了一轮后，将所有帧的引用位都设置为0，按照第二次机会算法，此时牺牲帧应该为第一个帧，替换第一个帧3，变成1、2、0，第二个和第三个帧的引用位都为0，下一个牺牲帧应该为第二个帧；
下一个引用页是2，在页帧中有，第二个帧的引用位被设为1，下一个牺牲帧应该为第三个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第三个帧；
下一个引用页是2，在页帧中有，下一个牺牲帧应该为第三个帧；
下一个引用页是4，替换第三个帧0，变成1、2、4，第二个帧的引用位变成0，下一个牺牲帧应该为第二个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第二个帧；
下一个引用页是1，在页帧中有，下一个牺牲帧应该为第二个帧。

过程符合第二次机会页面置换算法。

**测试用例2：**

为了方便查看，将代码中的```print_LRU_matrix()```函数注释掉，即不显示用矩阵实现的LRU页面置换算法中矩阵的变化结果，结果可对比用堆栈实现的LRU页面置换算法看是否正确。

    #define REFERENCE_STRING_LENGTH 20  // 引用串长度
    #define PAGE_SIZE 10                // 页的大小
    #define FRAME_SIZE 5                // 页帧大小

    4 5 3 0 6 1 9 1 2 7 6 4 3 7 0 8 8 8 3 8 

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/10.png)

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/11.png)

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/12.png)

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/13.png)

分析过程见图。

**测试用例3：**

    #define REFERENCE_STRING_LENGTH 40  // 引用串长度
    #define PAGE_SIZE 10                // 页的大小
    #define FRAME_SIZE 5                // 页帧大小

    9 5 8 2 0 1 2 4 5 1 2 8 7 6 0 9 6 9 9 6 3 4 4 4 5 7 7 0 8 4 5 7 0 6 0 2 7 2 9 3 

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/14.png)

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/15.png)

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/16.png)

![](http://stugeek.gitee.io/operating-system/Labwork17-pictures/17.png)

分析过程见图。
