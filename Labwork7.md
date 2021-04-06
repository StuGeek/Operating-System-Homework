# 操作系统实验报告7

## 实验内容

+ 实验内容：进程间通信—共享内存。实现一个带有n个单元的线性表的并发维护。

    + 建立一个足够大的共享内存空间(lock, M)，逻辑值lock用来保证同一时间只有一个进程进入M；测试你的系统上M的上限。

    + 设计一个程序在M上建立一个结点信息结构为 (flag, 学号, 姓名) 的静态链表L，逻辑值flag用作结点的删除标识；在L上建立一个以学号为关键字的二元小顶堆，自行设计控制结构(如静态指针数据域)。

    + 设计一个程序对上述堆结构的结点实现插入、删除、修改、查找、重排等操作。该程序的进程可以在多个终端并发执行。

    + 思考：使用逻辑值lock实现的并发机制不能解决条件冲突问题。

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### 测试我的系统上共享内存能申请的最大值

在```ShmMaxLimitsTest.c```文件中对共享内存最大值进行测试。

用到的共享结构为：

    #define TEST_SIZE 39999996

    struct shared_struct {
        char test[TEST_SIZE];
        int lock;
    };

```lock```为要求的保证同一时间只有一个进程进入共享内存的逻辑值，test数组为测试共享内存所用的使用内存的结构，声明为```char```类型有助于更加准确的控制数组的大小。

程序的源代码：

    //ShmMaxLimitsTest.c文件
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>
    #include <sys/stat.h>
    #include <sys/wait.h>
    #include <sys/shm.h>
    #include <fcntl.h>

    #define PERM S_IRUSR|S_IWUSR|IPC_CREAT

    #define ERR_EXIT(m) \
        do { \
            perror(m); \
            exit(EXIT_FAILURE); \
        } while(0)

    #define TEST_SIZE 39999996

    struct shared_struct {
        char test[TEST_SIZE];
        int lock;
    };

    int main(int argc, char *argv[])
    {
        struct stat fileattr;
        key_t key; // of type int
        int shmid; // shared memory ID
        void *shmptr;
        struct shared_struct *shared; // structured shm
        pid_t childpid1, childpid2;
        char pathname[80], key_str[10], cmd_str[80];
        int shmsize, ret;

        shmsize = sizeof(struct shared_struct); //共享内存的大小
        
        // 在编译命令"./a.out"后面还要加上文件路径名
        if(argc <2) {
            printf("Usage: ./a.out pathname\n");
            return EXIT_FAILURE;
        }
        strcpy(pathname, argv[1]);

        if(stat(pathname, &fileattr) == -1) {
            ret = creat(pathname, O_RDWR);
            if (ret == -1) {
                ERR_EXIT("creat()");
            }
            printf("shared file object created\n");
        }
    
        key = ftok(pathname, 0x27); // 0x27 a project ID 0x0001 - 0xffff, 8 least bits used
        if(key == -1) {
            ERR_EXIT("ftok()");
        }

        shmid = shmget((key_t)key, shmsize, 0666|PERM);
        if (shmid == -1) {
            printf("The shared memory size is %d, which is over the max limits\n", shmsize);
            ERR_EXIT("shmget()");
        }

        shmptr = shmat(shmid, 0, 0);

        if(shmptr == (void *)-1) {
            ERR_EXIT("shmat()");
        }
        
        shared = (struct shared_struct *)shmptr;
        shared->lock = 0;

        // detach the shared memory
        if (shmdt(shmptr) == -1) {
            ERR_EXIT("shmdt()");
        }

        
        if (shmctl(shmid, IPC_RMID, 0) == -1) {
            ERR_EXIT("shmcon: shmctl(IPC_RMID)");
        }
    
        printf("The shared memory size is %d, which is under the max limits\n", shmsize);
        exit(EXIT_SUCCESS);
    }

执行程序命令：

    gcc ShmMaxLimitsTest.c
    ./a.out 1

其中，语句```shmsize = sizeof(struct shared_struct)```确定了申请的共享内存的大小，从而对所能申请的共享内存的最大值进行测试。

语句```shmid = shmget((key_t)key, shmsize, 0666|PERM)```根据之前所想要申请的共享内存大小```shmsize```创建共享内存对象，如果创建成功，那么程序正常执行，最后打印语句```The shared memory size is shmsize, which is under the max limits```，可以看到当创建成功时，共享内存的大小```shmsize```。

如果创建失败，打印语句```The shared memory size is shmsize, which is over the max limits```，也能看到创建失败时，所申请的共享内存的大小。

当宏定义```TEST_SIZE```为```39999996```，打印语句```The shared memory size is 40000000, which is under the max limits```，创建共享内存成功；

当宏定义```TEST_SIZE```为```39999997```，打印语句```The shared memory size is 40000004, which is over the max limits```，创建共享内存失败。

可以知道，我的系统能申请的共享内存的最大值为40000000字节，除了逻辑值```lock```以外所能申请的M内存大小最大为39999996字节。

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork7-pictures/1.png)

### 实现数据结构部分

实验所用的到的静态链表L和在其上建立的二元小顶堆等数据结构在```SLList_MinHeap.c```文件中进行测试。

学生信息结点的结构为：

    //存储学生信息的结构
    typedef struct node {
        int flag;       //flag=0代表该结点被删除，flag=1代表结点未被删除
        int id;         //学号
        char name[20];  //姓名
        int preNode;    //结点的前一个点在静态链表中的下标，如果没有则为-1
        int nextNode;   //结点的后一个点在静态链表中的下标，如果没有则为-1
    } Student;

其中所用到的静态链表和在其上建立的二元小顶堆的结构为：

    #define MAXSIZE 1024  //静态链表或堆的最大容量

    //栈结构
    typedef struct {
        int index[MAXSIZE];  //存储空闲坐标的数组
        int top;     //指向栈顶结点在数组中的下标
    } Stack;

    //静态链表结构，同时在其上实现最小堆结构
    typedef struct lists {
        Student list[MAXSIZE];  //存储学生信息的静态链表，用一维数组实现
        int headIndex;          //静态链表开头的结点在数组中的下标
        int size;               //静态链表目前存储的结点数目
        Stack unusedIndexs;     //静态链表中还未使用的下标，向静态链表中添加信息时可从中获取空闲下标
    } StaticLinkList, *MinHeap;

提供的操作有：

    //初始化静态链表
    void initialStaticLinkList(StaticLinkList *lists);
    //将学生信息从表头加入静态链表
    void insertListAtHead(StaticLinkList *lists, Student stu);
    //将链表中的学生信息打印出来
    void printStaticLinkList(StaticLinkList *lists);

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

在静态链表上建立小顶堆，并进行小顶堆的插入、删除、修改、查找、重排等操作时，元素存储在静态链表的一维数组中的位置可能改变，但元素在静态链表中的顺序不能改变，使用以下主函数对实现的这一结构进行测试：

    int main() {
        StaticLinkList lists;
        initialStaticLinkList(&lists);

        Student stu1 = {id: 30, name: "name1"};
        Student stu2 = {id: 20, name: "name2"};
        Student stu3 = {id: 40, name: "name3"};
        Student stu4 = {id: 50, name: "name4"};
        Student stu5 = {id: 10, name: "name5"};
        Student stu6 = {id: 5, name: "name6"};
        Student stu7 = {id: 25, name: "name7"};
        
        insertListAtHead(&lists, stu1);
        insertListAtHead(&lists, stu2);
        insertListAtHead(&lists, stu3);
        insertListAtHead(&lists, stu4);
        insertListAtHead(&lists, stu5);

        printf("---------------------------------------------------\n");
        printf("Before initiation:\n");
        printHeap(&lists);
        printf("\n");
        printStaticLinkList(&lists);
        printf("---------------------------------------------------\n\n");

        printf("---------------------------------------------------\n");
        printf("Turn the list into a heap after initiation:\n\n");
        initialHeap(&lists);
        printHeap(&lists);
        printf("\n");
        printStaticLinkList(&lists);
        printf("---------------------------------------------------\n\n");

        printf("---------------------------------------------------\n");
        printf("Push stu6 into the heap(id: 5, name: name6)\n\n");
        pushHeap(&lists, &stu6);
        printHeap(&lists);
        printf("\n");
        printStaticLinkList(&lists);
        printf("---------------------------------------------------\n\n");

        printf("---------------------------------------------------\n");
        printf("Push stu7 into the heap(id: 25, name: name7)\n\n");
        pushHeap(&lists, &stu7);
        printHeap(&lists);
        printf("\n");
        printStaticLinkList(&lists);
        printf("---------------------------------------------------\n\n");
        
        printf("---------------------------------------------------\n");
        printf("Pop heap the first time\n\n");
        popHeap(&lists);
        printHeap(&lists);
        printf("\n");
        printStaticLinkList(&lists);
        printf("---------------------------------------------------\n\n");

        printf("---------------------------------------------------\n");
        printf("Pop heap the second time\n\n");
        popHeap(&lists);
        printHeap(&lists);
        printf("\n");
        printStaticLinkList(&lists);
        printf("---------------------------------------------------\n\n");

        printf("---------------------------------------------------\n");
        printf("Change stu4's id to 5\n\n");
        modifyId(&lists, &stu4, 5);
        printHeap(&lists);
        printf("\n");
        printStaticLinkList(&lists);
        printf("---------------------------------------------------\n\n");

        printf("---------------------------------------------------\n");
        printf("Change the first student's id in the heap to 90\n\n");
        modifyIdByIndex(&lists, 0, 90);
        printHeap(&lists);
        printf("\n");
        printStaticLinkList(&lists);
        printf("---------------------------------------------------\n\n");

        printf("---------------------------------------------------\n");
        printf("Find the stu3's index\n\n");
        int index = findHeap(&lists, &stu3, 0);
        printf("The stu3 is in the index %d\n", index);
        printf("---------------------------------------------------\n\n");
    }

执行程序命令：

    gcc SLList_MinHeap.c
    ./a.out

输出执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork7-pictures/2.png)

**创建静态链表，将stu1到stu5从表头依次插入**

可以看到，执行完：

    printf("Before initiation:\n");
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);

之后，输出为：

    In the MinHeap:
    Index 0: Id: 30 Name: name1 Pre: 1 Next: -1
    Index 1: Id: 20 Name: name2 Pre: 2 Next: 0
    Index 2: Id: 40 Name: name3 Pre: 3 Next: 1
    Index 3: Id: 10 Name: name4 Pre: 4 Next: 2
    Index 4: Id: 50 Name: name5 Pre: -1 Next: 3

    In the static linklist(from head to tail): 
    Id: 50 Name: name5 Pre: -1 Next: 3
    Id: 10 Name: name4 Pre: 4 Next: 2
    Id: 40 Name: name3 Pre: 3 Next: 1
    Id: 20 Name: name2 Pre: 2 Next: 0
    Id: 30 Name: name1 Pre: 1 Next: -1

信息从stu1到stu5依次按下标0~4添加到存储静态链表的数组中，由于是从表头插入，所以静态链表中的顺序为stu5到stu1（Pre和Next表示这个结点的前一个结点和后一个结点在数组中的下标，-1表示开头或结尾）。

---

**在静态链表上建立小顶堆，重排数组但是不改变静态链表中元素的相对顺序**

可以看到，执行完：

    printf("Turn the list into a heap after initiation:\n\n");
    initialHeap(&lists);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);

之后，输出为：

    In the MinHeap:
    Index 0: Id: 10 Name: name4 Pre: 4 Next: 2
    Index 1: Id: 20 Name: name2 Pre: 2 Next: 3
    Index 2: Id: 40 Name: name3 Pre: 0 Next: 1
    Index 3: Id: 30 Name: name1 Pre: 1 Next: -1
    Index 4: Id: 50 Name: name5 Pre: -1 Next: 0

    In the static linklist(from head to tail): 
    Id: 50 Name: name5 Pre: -1 Next: 0
    Id: 10 Name: name4 Pre: 4 Next: 2
    Id: 40 Name: name3 Pre: 0 Next: 1
    Id: 20 Name: name2 Pre: 2 Next: 3
    Id: 30 Name: name1 Pre: 1 Next: -1

此时在静态链表上建立了一个小顶堆，数组元素的位置发生了变化，堆顶为数字中坐标为0的元素，可以看到，在小顶堆中堆顶学号为10，然后左儿子和右儿子学号为20和40，都小于10，左儿子的左儿子的学号为50，小于20，小顶堆重排初始化成功。

而在静态链表中，可以看到，打印出来静态链表元素的相对顺序没有发生改变，依然是stu5到stu1(name5~name1)，结构保持成功。

---

![](http://stugeek.gitee.io/operating-system/Labwork7-pictures/3.png)

**向小顶堆中插入stu6**

可以看到，执行完：

    printf("Push stu6 into the heap(id: 5, name: name6)\n\n");
    pushHeap(&lists, &stu6);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);

之后，输出为：

    In the MinHeap:
    Index 0: Id: 5 Name: name6 Pre: -1 Next: 4
    Index 1: Id: 20 Name: name2 Pre: 5 Next: 3
    Index 2: Id: 10 Name: name4 Pre: 4 Next: 5
    Index 3: Id: 30 Name: name1 Pre: 1 Next: -1
    Index 4: Id: 50 Name: name5 Pre: 0 Next: 2
    Index 5: Id: 40 Name: name3 Pre: 2 Next: 1

    In the static linklist(from head to tail): 
    Id: 5 Name: name6 Pre: -1 Next: 4
    Id: 50 Name: name5 Pre: 0 Next: 2
    Id: 10 Name: name4 Pre: 4 Next: 5
    Id: 40 Name: name3 Pre: 2 Next: 1
    Id: 20 Name: name2 Pre: 5 Next: 3
    Id: 30 Name: name1 Pre: 1 Next: -1

学号为5的stu6被插入到小顶堆中，可以看到，在小顶堆中，堆顶元素为学号最小的5的stu6，然后左儿子和右儿子学号为20和10，都小于5，左儿子的左儿子和右儿子的学号为50和40，小于20，小顶堆插入成功。

而在静态链表中，可以看到，stu6从表头插入到静态链表中，打印出来静态链表元素的相对顺序没有发生改变，依然是stu6到stu1(name6~name1)，结构保持成功。

---

**向小顶堆中插入stu7**

可以看到，执行完：

    printf("Push stu7 into the heap(id: 25, name: name7)\n\n");
    pushHeap(&lists, &stu7);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);

之后，输出为：

    In the MinHeap:
    Index 0: Id: 5 Name: name6 Pre: 6 Next: 2
    Index 1: Id: 20 Name: name2 Pre: 5 Next: 4
    Index 2: Id: 10 Name: name5 Pre: 0 Next: 3
    Index 3: Id: 50 Name: name4 Pre: 2 Next: 5
    Index 4: Id: 30 Name: name1 Pre: 1 Next: -1
    Index 5: Id: 40 Name: name3 Pre: 3 Next: 1
    Index 6: Id: 25 Name: name7 Pre: -1 Next: 0

    In the static linklist(from head to tail): 
    Id: 25 Name: name7 Pre: -1 Next: 0
    Id: 5 Name: name6 Pre: 6 Next: 2
    Id: 10 Name: name5 Pre: 0 Next: 3
    Id: 50 Name: name4 Pre: 2 Next: 5
    Id: 40 Name: name3 Pre: 3 Next: 1
    Id: 20 Name: name2 Pre: 5 Next: 4
    Id: 30 Name: name1 Pre: 1 Next: -1

学号为3的stu7被插入到小顶堆中，可以看到，在小顶堆中，堆顶元素为学号最小的5的stu6，然后左儿子和右儿子学号为20和10，都小于5，左儿子的左儿子和右儿子的学号为50和30，小于20，右儿子的左儿子和右儿子的学号为40和25，小于10，小顶堆插入成功。

而在静态链表中，可以看到，stu7从表头插入到静态链表中，打印出来静态链表元素的相对顺序没有发生改变，依然是stu7到stu1(name7~name1)，结构保持成功。

---

![](http://stugeek.gitee.io/operating-system/Labwork7-pictures/4.png)

**删除小顶堆中堆顶元素**

可以看到，执行完：

    printf("Pop heap the first time\n\n");
    popHeap(&lists);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);

之后，输出为：

    In the MinHeap:
    Index 0: Id: 10 Name: name5 Pre: 2 Next: 3
    Index 1: Id: 20 Name: name2 Pre: 5 Next: 4
    Index 2: Id: 25 Name: name7 Pre: -1 Next: 0
    Index 3: Id: 50 Name: name4 Pre: 0 Next: 5
    Index 4: Id: 30 Name: name1 Pre: 1 Next: -1
    Index 5: Id: 40 Name: name3 Pre: 3 Next: 1

    In the static linklist(from head to tail): 
    Id: 25 Name: name7 Pre: -1 Next: 0
    Id: 10 Name: name5 Pre: 2 Next: 3
    Id: 50 Name: name4 Pre: 0 Next: 5
    Id: 40 Name: name3 Pre: 3 Next: 1
    Id: 20 Name: name2 Pre: 5 Next: 4
    Id: 30 Name: name1 Pre: 1 Next: -1

原来学号最小为5的stu6被从小顶堆中删除，小顶堆重新进行调整，可以看到，在调整后的小顶堆中，堆顶元素为学号最小的10的stu5，然后左儿子和右儿子学号为20和25，都小于10，左儿子的左儿子和右儿子的学号为50和30，小于20，右儿子的左儿子的学号为40，小于25，小顶堆删除成功。

而在静态链表中，可以看到，打印出来静态链表元素的相对顺序没有发生改变，依然是stu7到stu1(除了被删除的stu6之外)，结构保持成功。

---

**再删除小顶堆中堆顶元素**

可以看到，执行完：

    printf("Pop heap the second time\n\n");
    popHeap(&lists);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);

之后，输出为：

    In the MinHeap:
    Index 0: Id: 20 Name: name2 Pre: 1 Next: 4
    Index 1: Id: 40 Name: name3 Pre: 3 Next: 0
    Index 2: Id: 25 Name: name7 Pre: -1 Next: 3
    Index 3: Id: 50 Name: name4 Pre: 2 Next: 1
    Index 4: Id: 30 Name: name1 Pre: 0 Next: -1

    In the static linklist(from head to tail): 
    Id: 25 Name: name7 Pre: -1 Next: 3
    Id: 50 Name: name4 Pre: 2 Next: 1
    Id: 40 Name: name3 Pre: 3 Next: 0
    Id: 20 Name: name2 Pre: 1 Next: 4
    Id: 30 Name: name1 Pre: 0 Next: -1

原来学号最小为10的stu5被从小顶堆中删除，小顶堆重新进行调整，可以看到，在调整后的小顶堆中，堆顶元素为学号最小的20的stu2，然后左儿子和右儿子学号为40和25，都小于20，左儿子的左儿子和右儿子的学号为50和30，小于20，小顶堆删除成功。

而在静态链表中，可以看到，打印出来静态链表元素的相对顺序没有发生改变，依然是stu7到stu1(除了被删除的stu5和stu6之外)，结构保持成功。

---

![](http://stugeek.gitee.io/operating-system/Labwork7-pictures/5.png)

**将小顶堆中的stu4元素的学号改为5**

可以看到，执行完：

    printf("Change stu4's id to 5\n\n");
    modifyId(&lists, &stu4, 5);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);

之后，输出为：

    In the MinHeap:
    Index 0: Id: 5 Name: name4 Pre: 2 Next: 3
    Index 1: Id: 20 Name: name2 Pre: 3 Next: 4
    Index 2: Id: 25 Name: name7 Pre: -1 Next: 0
    Index 3: Id: 40 Name: name3 Pre: 0 Next: 1
    Index 4: Id: 30 Name: name1 Pre: 1 Next: -1

    In the static linklist(from head to tail): 
    Id: 25 Name: name7 Pre: -1 Next: 0
    Id: 5 Name: name4 Pre: 2 Next: 3
    Id: 40 Name: name3 Pre: 0 Next: 1
    Id: 20 Name: name2 Pre: 3 Next: 4
    Id: 30 Name: name1 Pre: 1 Next: -1

原来stu4(姓名为name4)的学号被改为5，数组立即进行重排，重排后重新成为小顶堆，堆顶元素为学号最小的5的stu4，然后左儿子和右儿子学号为20和25，都小于5，左儿子的左儿子和右儿子的学号为40和30，小于20，小顶堆修改成功。

而在静态链表中，可以看到，打印出来静态链表元素的相对顺序没有发生改变，依然是stu7到stu1(除了被删除的stu5和stu6之外)，结构保持成功。

---

**将小顶堆数组中下标为0的元素的学号改为90**

可以看到，执行完：

    printf("Change the first student's id in the heap to 90\n\n");
    modifyIdByIndex(&lists, 0, 90);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);

之后，输出为：

    In the MinHeap:
    Index 0: Id: 20 Name: name2 Pre: 3 Next: 1
    Index 1: Id: 30 Name: name1 Pre: 0 Next: -1
    Index 2: Id: 25 Name: name7 Pre: -1 Next: 4
    Index 3: Id: 40 Name: name3 Pre: 4 Next: 0
    Index 4: Id: 90 Name: name4 Pre: 2 Next: 3

    In the static linklist(from head to tail): 
    Id: 25 Name: name7 Pre: -1 Next: 4
    Id: 90 Name: name4 Pre: 2 Next: 3
    Id: 40 Name: name3 Pre: 4 Next: 0
    Id: 20 Name: name2 Pre: 3 Next: 1
    Id: 30 Name: name1 Pre: 0 Next: -1

原来数组找中的第一个元素stu4(姓名为name4)的学号被改为90，数组立即进行重排，重排后重新成为小顶堆，堆顶元素为学号最小的20的stu2，然后左儿子和右儿子学号为30和25，都小于20，左儿子的左儿子和右儿子的学号为40和90，小于30，小顶堆修改成功。

而在静态链表中，可以看到，打印出来静态链表元素的相对顺序没有发生改变，依然是stu7到stu1(除了被删除的stu5和stu6之外)，结构保持成功。

---

**找到小顶堆中的stu3元素的下标**

可以看到，执行完：

    printf("Find the stu3's index\n\n");
    int index = findHeap(&lists, &stu3, 0);
    printf("The stu3 is in the index %d\n", index);

之后，输出为：

    The stu3 is in the index 3

数组中stu3的下标确实为3，查找操作成功。

---

可以看到，静态链表和小顶堆的插入、删除、修改、查找、重排（每次修改都会根据需要将数组重排成为小顶堆）等操作基本都成功。

### 多终端并发执行程序

实验原理：

在创建共享内存时，首先```ftok()```函数会根据一个已经存在的文件路径名和一个整数标识符生成一个IPC 键值，然后后面调用```shmid()```函数会根据这个IPC 键值创建一个共享对象或者获取共享对象标识符，因为当ftok()函数参数的文件路径名和整数标识符不变时，生成的IPC 键值总是不变，所以在多个终端运行程序时，获取的IPC 键值也总是一样，最后获得的是同一个共享对象，就可以在程序中对这个共享对象进行操作。

实现细节解释：

程序的核心代码：

    shared = (StaticLinkList *)shmptr; // 创建共享内存中使用的结构体 */
    initialStaticLinkList(shared); //初始化结构体
    shared->lock = 0; //逻辑值lock设为0，代表进程可以执行
    shared->operation_time = 0; //对结构体的操作次数，方便测试用
	
    //方便测试，当结构体中的元素个数为5时，就退出
    while (shared->size < 5) {
        //当逻辑值lock等于1时，进程休眠不执行
        while (shared->lock == 1) {
            sleep(1);
        }
        wait(0);
        //进程执行时，将逻辑值lock设为1，防止其它进程进入共享内存
        shared->lock = 1;
        //对共享结构的操作次数加一，方便测试用
        shared->operation_time++;
        printf("Times: %d\t", shared->operation_time);
        printf("Process id: %d\tOpertion: ", getpid());
        //随机产生操作种类，包括对小顶堆的插入、删除、查找、修改
        int op = rand() % 4 + 1;
        operation(shared, op);
        //打印共享结构，方便测试用
        printHeapAndLists(shared);
        //休眠5s，尽量避免多进程冲突，同时方便测试
        sleep(5);
        //将逻辑值设为0，其它进程可进入共享内存执行
        shared->lock = 0;
    }

    //结束时，打印所有进程总操作次数，打印最后共享结构中的内容，方便测试用
    printf("Total operation times: %d\n", shared->operation_time);
    printf("The final situation of the shared struct:\n");
    printHeapAndLists(shared);

    //记录退出进程的个数，方便最后释放共享内存
    shared->lock++;
    int numOfProExit = shared->lock;

    if(shmdt(shmptr) == -1) {
        ERR_EXIT("shmcon: shmdt()");
    }

    //所有进程退出后，释放共享内存，这里选择的进程数是4，不等所有进程退出就释放会报错
    if (numOfProExit >= 4 && shmctl(shmid, IPC_RMID, 0) == -1) {
        ERR_EXIT("shmcon: shmctl(IPC_RMID)");
    }

因为每次在一个终端运行程序，共享结构体```shared```都会进行一次初始化，而且其中的变量```operation_time```都会变成0， 所以为了程序的可运行性和测试方便，最好多个终端同时启动运行程序。

执行程序命令：

    gcc ipc-shmcon.c
    ./a.out 1

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork7-pictures/6.jpg)

图中的```Times```代表对共享结构体是第几个操作，```Process id```代表对这个共享结构体进行操作的进程的进程号，```Operation```代表这个进程对共享结构体执行的操作，然后显示操作结果和每次操作之后共享结构体中的元素信息。

可以看到，四个终端对共享结构体分别执行了第62、63、64、65次操作，在不同的终端对同一个共享结构体进行了插入、删除、查找、修改（每次修改都会根据需要进行重排操作）等操作是行的。

![](http://stugeek.gitee.io/operating-system/Labwork7-pictures/7.jpg)

程序结束后，可以看到不同终端显示的对共享结构体的总操作次数相同，共享结构体里的信息也相同，说明是同一个共享结构体。

### 思考：使用逻辑值lock实现的并发机制不能解决条件冲突问题

因为每次在一个终端运行程序，语句```shared->lock = 0```都会把共享结构体的成员变量```lock```变成0，此时其它进程也可能再次运行，同一时间可能会有多个进程运行，所以并不能解决条件冲突问题。而且在while循环中，一个进程执行完操作会重新将```lock```值设为0，此时也可能有其它进程运行，同一时间可能有多个进程运行。