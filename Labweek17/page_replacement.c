// page_replacement.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define REFERENCE_STRING_LENGTH 20  // 引用串的长度
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
    printf("\n------------------------------------\n");
    printf("page-replacement algorithm: FIFO\n");
    
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

    printf("------------------------------------\n");
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
    printf("\n------------------------------------\n");
    printf("page-replacement algorithm: LRU implemented by stack\n");

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

    printf("------------------------------------\n");
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
    printf("\n------------------------------------\n");
    printf("page-replacement algorithm: LRU implemented by matrix\n");

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

    printf("------------------------------------\n");
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
    printf("\n------------------------------------\n");
    printf("page-replacement algorithm: Second chance(\"*\" means the reference bit is 1, \"(C)\" means the clock pointer's position)\n");

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

    printf("------------------------------------\n");
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