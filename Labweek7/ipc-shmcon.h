//ipc-shmcon.h文件
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define PERM S_IRUSR|S_IWUSR|IPC_CREAT

#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)

#define BOOL int
#define MAXSIZE 1024  //静态链表或堆的最大容量

//存储学生信息的结构
typedef struct node {
    int flag;       //flag=0代表该结点被删除，flag=1代表结点未被删除
    int id;         //学号
    char name[30];  //姓名
    int preNode;    //结点的前一个点在静态链表中的下标，如果没有则为-1
    int nextNode;   //结点的后一个点在静态链表中的下标，如果没有则为-1
} Student;

//栈结构
typedef struct {
    int index[MAXSIZE];  //存储空闲坐标的数组
    int top;     //指向栈顶结点在数组中的下标
} Stack;

//静态链表结构，同时在其上实现最小堆结构
typedef struct shared_struct {
    Student list[MAXSIZE];  //存储学生信息的静态链表，用一维数组实现
    int headIndex;          //静态链表开头的结点在数组中的下标
    int size;               //静态链表目前存储的结点数目
    Stack unusedIndexs;     //静态链表中还未使用的下标，向静态链表中添加信息时可从中获取空闲下标
    int lock;
    int operation_time;
} StaticLinkList, *MinHeap;

/*
 * 栈结构的相关操作
 */

//初始化一个栈，里面放静态链表中未使用的下标
void initiateStack(Stack *stk);
//压栈
void pushStack(Stack *stk, int unusedIndex);
//弹栈
void popStack(Stack *stk);
//取栈顶元素
int topStack(const Stack *stk);
//将栈顶和还未使用的元素下标打印出来
void printStack(Stack *stk);

/*
 * 存储学生信息的结构体的相关操作
 */

//打印学生的信息，包括学号和姓名
void printStudent(Student *stu);

/*
 * 静态链表的相关操作
 */

//初始化静态链表
void initialStaticLinkList(StaticLinkList *lists);
//将学生信息从表头加入静态链表
void insertListAtHead(StaticLinkList *lists, Student stu);
//将链表中的学生信息打印出来
void printStaticLinkList(StaticLinkList *lists);

/*
 * 以学号为关键字的最小堆的相关操作
 */

//交换最小堆中的两个结点，包括它们在静态链表中的相对顺序
void swapHeapNode(MinHeap heap, int parent, int child);
//重排初始化最小堆
void initialHeap(MinHeap heap);
//向最小堆中添加学生信息
void pushHeap(MinHeap heap, Student *stu);
//向最小堆中按照姓名学号添加学生信息
void pushHeapByIdAndName(MinHeap heap, int id, char *name);
//从小顶堆中删除根结点的数据
void popHeap(MinHeap heap);
//从小顶堆返回学号最小的学生信息
Student topHeap(MinHeap t);
//判断小顶堆是否为空
BOOL isEmptyHeap(MinHeap t);
//从最小堆中根据学生信息找到该学生在静态链表中的下标
int findHeap(MinHeap heap, Student *stu, int curIndex);
//从最小堆中根据学生学号找到该学生在静态链表中的下标
int findHeapById(MinHeap heap, int id, int curIndex);
//从最小堆中根据学生姓名找到该学生在静态链表中的下标
int findHeapByName(MinHeap heap, char *name, int curIndex);
//根据学生信息找到学生并修改该学生的学号
void modifyId(MinHeap heap, Student *stu, int id);
//根据学生信息找到学生并修改该学生的姓名
void modifyName(MinHeap heap, Student *stu, char *name);
//根据学生信息找到学生并修改该学生的学号和姓名
void modifyIdAndName(MinHeap heap, Student *stu, int id, char *name);
//根据静态链表一维数组的下标找到学生并修改该学生的学号
void modifyIdByIndex(MinHeap heap, int index, int id);
//根据静态链表一维数组的下标找到学生并修改该学生的姓名
void modifyNameByIndex(MinHeap heap, int index, char *name);
//根据静态链表一维数组的下标找到学生并修改该学生的学号和姓名
void modifyIdAndNameByIndex(MinHeap heap, int index, int id, char *name);
//把堆中的元素按照一维数组的顺序打印出来，并显示它们在一维数组中的下标
void printHeap(MinHeap heap);
//按照一定格式打印小顶堆和静态链表中元素的情况
void printHeapAndLists(MinHeap heap);

//初始化一个栈，里面放静态链表中未使用的下标
void initiateStack(Stack *stk) {
    //按照顺序从MAXSIZE - 1到0向栈中添加数字，这样保证信息从0开始向静态链表中添加，有利于构建小顶堆
    for (int i = 0; i < MAXSIZE; ++i) {
        stk->index[i] = MAXSIZE - i - 1;
    }
    stk->top = MAXSIZE - 1;
}

//进栈
void pushStack(Stack *stk, int unusedIndex) {
    stk->index[++stk->top] = unusedIndex;
}

//出栈
void popStack(Stack *stk) {
    if (stk->top == -1)
        return;
    stk->top--;
}

//取栈顶元素
int topStack(const Stack *stk) {
    if (stk->top == -1)
        return -1;
    return stk->index[stk->top];
}

//将栈顶和还未使用的元素下标打印出来
void printStack(Stack *stk) {
    if (stk->top == -1) {
        printf("Stack is empty\n");
        return;
    }
    printf("Stack: top = %d\n", stk->index[stk->top]);
    printf("Unused units in the stack: ");
    for (int i = 0; i <= stk->top; ++i) {
        printf("%d ", stk->index[i]);
    }
    printf("\n");
    printf("\n");
}

//打印学生的信息，包括学号和姓名
void printStudent(Student *stu) {
    printf("Id: %d Name: %s Pre: %d Next: %d\n", stu->id, stu->name, stu->preNode, stu->nextNode);
}

//初始化静态链表
void initialStaticLinkList(StaticLinkList *lists) {
    //静态链表开始元素在数组中的下标设为-1
    lists->headIndex = -1;
    //静态链表中存储的学生信息数目为0
    lists->size = 0;
    initiateStack(&lists->unusedIndexs);
}

//将学生信息从表头加入静态链表
void insertListAtHead(StaticLinkList *lists, Student stu) {
    //从存储空闲下标的栈中获取下标
    int index = topStack(&lists->unusedIndexs);
    popStack(&lists->unusedIndexs);
    //新结点作为开始元素插入静态链表
    lists->list[index] = stu;
    lists->list[index].flag = 1;
    lists->list[index].preNode = -1;
    lists->list[index].nextNode = lists->headIndex;
    if (lists->headIndex != -1) {
        lists->list[lists->headIndex].preNode = index;
    }
    lists->headIndex = index;
    lists->size++;
}

//将链表中的学生信息打印出来
void printStaticLinkList(StaticLinkList *lists) {
    printf("In the static linklist(from head to tail): \n");
    if (lists->headIndex == -1) {
        printf("It is empty\n");
        return;
    }
    int pre = lists->headIndex;
    int next = lists->list[lists->headIndex].nextNode;
    while (1) {
        printStudent(&lists->list[pre]);
        pre = next;
        if (pre == -1) break;
        next = lists->list[next].nextNode;
    }
}

//交换最小堆中的两个结点，但是不改变它们在静态链表中所处的顺序
void swapHeapNode(MinHeap heap, int parent, int child) {
    //记录两个结点在静态链表中前一个和后一个结点的下标
    int parentPreNodeIndex = heap->list[parent].preNode;
    int parentNextNodeIndex = heap->list[parent].nextNode;
    int childPreNodeIndex = heap->list[child].preNode;
    int childNextNodeIndex = heap->list[child].nextNode;
    //交换两个结点
    Student t = heap->list[parent];
    heap->list[parent] = heap->list[child];
    heap->list[child] = t;
    //如果两个结点在静态链表中不是相邻关系
    if (parentPreNodeIndex != -1 && parentPreNodeIndex != child) {
        heap->list[parentPreNodeIndex].nextNode = child;
    }
    if (parentNextNodeIndex != -1 && parentNextNodeIndex != child) {
        heap->list[parentNextNodeIndex].preNode = child;
    }
    if (childPreNodeIndex != -1 && childPreNodeIndex != parent) {
        heap->list[childPreNodeIndex].nextNode = parent;
    }
    if (childNextNodeIndex != -1 && childNextNodeIndex != parent) {
        heap->list[childNextNodeIndex].preNode = parent;
    }
    //如果两个结点在静态链表中是相邻关系
    if (parentPreNodeIndex == child) {
        heap->list[parent].nextNode = child;
        heap->list[child].preNode = parent;
    }
    if (parentNextNodeIndex == child) {
        heap->list[parent].preNode = child;
        heap->list[child].nextNode = parent;
    }
    //调整表头结点在数组的下标
    if (heap->list[parent].preNode == -1) heap->headIndex = parent;
    if (heap->list[child].preNode == -1) heap->headIndex = child;
}

//重排初始化最小堆
void initialHeap(MinHeap heap) {
    int n = heap->size;
    for (int i = n / 2 - 1; i >= 0; --i) {
        Student temp = heap->list[i];
        int parent = i;
        int child = (i << 1) + 1;
        while (child < n) {
            //选择儿子结点中较小的那个结点
            if (child + 1 < n && heap->list[child].id > heap->list[child + 1].id) {
                child = child + 1;
            }
            //如果分支结点的值更大，进行调整
            if (temp.id > heap->list[child].id) {
                swapHeapNode(heap, parent, child);
                parent = child;
                child = (parent << 1) + 1;
            } else
                break;
        }
    }
}

//向最小堆中添加学生信息
void pushHeap(MinHeap heap, Student *stu) {
    int child = topStack(&heap->unusedIndexs);
    popStack(&heap->unusedIndexs);
    //向数组的空闲下标的位置插入数据
    heap->list[child].id = stu->id;
    strcpy(heap->list[child].name, stu->name);
    //对学生信息进行加工调整后再添加
    if(heap->headIndex != -1) {
        heap->list[heap->headIndex].preNode = child;
    }
    heap->list[child].flag = 1;
    heap->list[child].preNode = -1;
    heap->list[child].nextNode = heap->headIndex;
    heap->size++;
    int parent = (child - 1) / 2;
    //如果此时插入元素的学号比它的父亲大，同时插入数据还没有成为根结点，那么将它的父亲保存到小顶堆的位置，插入元素继续向上比较
    while (stu->id < heap->list[parent].id && child > 0) {
        swapHeapNode(heap, parent, child);
        child = parent;
        parent = (child - 1) / 2;
    }
    heap->headIndex = child;
}

//向最小堆中按照姓名学号添加学生信息
void pushHeapByIdAndName(MinHeap heap, int id, char *name) {
    int child = topStack(&heap->unusedIndexs);
    popStack(&heap->unusedIndexs);
    //向数组的空闲下标的位置插入数据
    heap->list[child].id = id;
    strcpy(heap->list[child].name, name);
    //对学生信息进行加工调整后再添加
    if(heap->headIndex != -1) {
        heap->list[heap->headIndex].preNode = child;
    }
    heap->list[child].flag = 1;
    heap->list[child].preNode = -1;
    heap->list[child].nextNode = heap->headIndex;
    heap->size++;
    int parent = (child - 1) / 2;
    //如果此时插入元素的学号比它的父亲大，同时插入数据还没有成为根结点，那么将它的父亲保存到小顶堆的位置，插入元素继续向上比较
    while (id < heap->list[parent].id && child > 0) {
        swapHeapNode(heap, parent, child);
        child = parent;
        parent = (child - 1) / 2;
    }
    heap->headIndex = child;
}

//从小顶堆中删除根结点的数据
void popHeap(MinHeap heap) {
    //小顶堆为空，直接返回
    if (heap->size == 0) return;
    int high, low;
    //获取小顶堆数组的最后一个元素
    Student temp = heap->list[--heap->size];
    pushStack(&heap->unusedIndexs, heap->size);
    heap->list[heap->headIndex].flag = 0;
    if (heap->size == 0) {
        heap->headIndex = -1;   
        return;
    }
    swapHeapNode(heap, 0, heap->size);
    for (high = 0; high * 2 + 1 < heap->size; high = low) {
        //从根结点开始，high为父亲结点的位置，low为左儿子的位置
        low = high * 2 + 1;
        //选择儿子结点中学号较小的那个结点
        if (low != heap->size - 1 && heap->list[low].id > heap->list[low + 1].id) {
            low += 1;
        }
        //如果这个结点比小顶堆数组的最后一个元素的学号小，那么将这个结点放到它的父亲结点
        if (heap->list[low].id < temp.id) {
            swapHeapNode(heap, high, low);
        }
        else break;
    }
    //调整被删除结点前后结点的坐标相对顺序和表头结点
    int preNodeIndex = heap->list[heap->size].preNode;
    int nextNodeIndex = heap->list[heap->size].nextNode;
    if (preNodeIndex != -1) heap->list[preNodeIndex].nextNode = nextNodeIndex;
    if (nextNodeIndex != -1) heap->list[nextNodeIndex].preNode = preNodeIndex; 
    if (preNodeIndex == -1) heap->headIndex = nextNodeIndex;
}

//从小顶堆返回最小元素
Student topHeap(MinHeap t) {
    return t->list[0];
}

//判断小顶堆是否为空
BOOL isEmptyHeap(MinHeap t) {
    return t->size == 0;
}

//从最小堆中根据学生信息找到该学生在静态链表中的下标，递归方式
int findHeap(MinHeap heap, Student *stu, int curIndex) {
    if (curIndex >= heap->size) return -1;
    if (heap->list[curIndex].id == stu->id && strcmp(heap->list[curIndex].name, stu->name) == 0) {
        return curIndex;
    }
    int leftIndex = -1;
    int rightIndex = -1;
    if (curIndex * 2 + 1 < heap->size) {
        leftIndex = findHeap(heap, stu, curIndex * 2 + 1);
    }
    if (leftIndex != -1) return leftIndex;
    if (curIndex * 2 + 2 < heap->size) {
        rightIndex = findHeap(heap, stu, curIndex * 2 + 2);
    }
    if (rightIndex != -1) return rightIndex;
    return -1;
}

//从最小堆中根据学生学号找到该学生在静态链表中的下标
int findHeapById(MinHeap heap, int id, int curIndex) {
    if (curIndex >= heap->size) return -1;
    if (heap->list[curIndex].id == id) {
        return curIndex;
    }
    int leftIndex = -1;
    int rightIndex = -1;
    if (curIndex * 2 + 1 < heap->size) {
        leftIndex = findHeapById(heap, id, curIndex * 2 + 1);
    }
    if (leftIndex != -1) return leftIndex;
    if (curIndex * 2 + 2 < heap->size) {
        rightIndex = findHeapById(heap, id, curIndex * 2 + 2);
    }
    if (rightIndex != -1) return rightIndex;
    return -1;
}

//从最小堆中根据学生姓名找到该学生在静态链表中的下标
int findHeapByName(MinHeap heap, char *name, int curIndex) {
    if (curIndex >= heap->size) return -1;
    if (strcmp(heap->list[curIndex].name, name) == 0) {
        return curIndex;
    }
    int leftIndex = -1;
    int rightIndex = -1;
    if (curIndex * 2 + 1 < heap->size) {
        leftIndex = findHeapByName(heap, name, curIndex * 2 + 1);
    }
    if (leftIndex != -1) return leftIndex;
    if (curIndex * 2 + 2 < heap->size) {
        rightIndex = findHeapByName(heap, name, curIndex * 2 + 2);
    }
    if (rightIndex != -1) return rightIndex;
    return -1;
}

//根据学生信息找到学生并修改该学生的学号
void modifyId(MinHeap heap, Student *stu, int id) {
    int index = findHeap(heap, stu, 0);
    if (index == -1) {
        printf("can't find the target student!\n");
    } else {
        heap->list[index].id = id;
        initialHeap(heap);
    }
}

//根据学生信息找到学生并修改该学生的姓名
void modifyName(MinHeap heap, Student *stu, char *name) {
    int index = findHeap(heap, stu, 0);
    if (index == -1) {
        printf("can't find the target student!\n");
    } else {
        strcpy(heap->list[index].name, name);

    }
}

//根据学生信息找到学生并修改该学生的学号和姓名
void modifyIdAndName(MinHeap heap, Student *stu, int id, char *name) {
    int index = findHeap(heap, stu, 0);
    if (index == -1) {
        printf("can't find the target student!\n");
    } else {
        heap->list[index].id = id;
        strcpy(heap->list[index].name, name);
        initialHeap(heap);
    }
}

//根据静态链表一维数组的下标找到学生并修改该学生的学号
void modifyIdByIndex(MinHeap heap, int index, int id) {
    if (index >= heap->size) {
        printf("can't find the target student!\n");
    } else {
        heap->list[index].id = id;
        initialHeap(heap);

    }
}

//根据静态链表一维数组的下标找到学生并修改该学生的姓名
void modifyNameByIndex(MinHeap heap, int index, char *name) {
    if (index >= heap->size) {
        printf("can't find the target student!\n");
    } else {
        strcpy(heap->list[index].name, name);
    }
}

//根据静态链表一维数组的下标找到学生并修改该学生的学号和姓名
void modifyIdAndNameByIndex(MinHeap heap, int index, int id, char *name) {
    if (index >= heap->size) {
        printf("can't find the target student!\n");
    } else {
        heap->list[index].id = id;
        strcpy(heap->list[index].name, name);
        initialHeap(heap);
    }
}

//把堆中的元素按照一维数组的顺序打印出来，并显示它们在一维数组中的下标
void printHeap(MinHeap heap) {
    printf("In the MinHeap:\n");
    if (heap->size == 0) {
        printf("It is empty\n");
        return;
    }
    for(int i = 0; i < heap->size; ++i) {
        printf("Index %d: ", i);
        printStudent(&heap->list[i]);
    }
}

//按照一定格式打印小顶堆和静态链表中元素的情况
void printHeapAndLists(MinHeap heap) {
    printf("----------------------Shared Struct----------------\n");
    printHeap(heap);
    printf("\n");
    printStaticLinkList(heap);
    printf("---------------------------------------------------\n\n");
}