# 操作系统实验报告14

## 实验内容

+ 实验内容：Peterson 算法。
    + 把 Lecture08 示例 alg.8-1~8-3 拓展到多个读线程和多个写线程，应用 Peterson 算法原理设计实现共享内存互斥。

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### 实验内容原理

#### Peterson算法

+ Peterson算法是一个实现互斥锁的并发程序设计算法，适用于两个线程交替执行临界区和剩余区，并且可以满足互斥、进步、有限等待等要求，算法使用两个控制变量flag与turn. 其中flag[n]的值为真，表示编号为n的进程希望进入该临界区，变量turn保存有权访问共享资源的进程的编号。可以控制两个线程访问同一个共享资源而不发生条件冲突。而且Peterson算法可以扩展到多个线程的情况。

+ Peterson算法推广到N个线程的算法：
    + 使用N个不同的线程级别，用数组level[N]存储
        + 每一个线程级别都代表另一个在进入临界区之前的“等候室”
        + 每个线程级别将允许至少一个线程继续执行进入临界区，同时保持一个线程在等待
    + 线程级别达到N-1的线程Pi(level(i) == N-1)将退出for循环并进入其临界区。
    + 任何线程Pi都会将其线程级别lev升级到lev+1(即退出while循环)或：
        + 其他的线程Pj将其线程级别升级到Pi(然后是代码level(j)==lev和waiting[lev]==j)或：
        + 任何其他线程的线程级别都低于lev。

**过程图解：**

![](http://stugeek.gitee.io/operating-system/Labwork14-pictures/1.png)

线程等候室中的线程不能退出while循环，也不能提升线程级别即使这个线程正在被调度，除非它是当前最高线程级别的唯一线程。任何不在等候室中的线程都将退出while循环，并被提升线程级别如果在被调度的话。

![](http://stugeek.gitee.io/operating-system/Labwork14-pictures/2.png)

因此，任何低于当前最高线程级别的等候室都必须被占用。

![](http://stugeek.gitee.io/operating-system/Labwork14-pictures/3.png)

当线程级别为q的线程Pk被调度时，它退出while循环，线程级别升级到q+1并占用q+1线程级别的等候室，Pi被移出等候室。

![](http://stugeek.gitee.io/operating-system/Labwork14-pictures/4.png)

当线程级别为q+1的线程Pi被调度时，它退出while循环，线程级别升级到q+2，并占用q+2线程级别的等候室。Pt被移出等候室。

![](http://stugeek.gitee.io/operating-system/Labwork14-pictures/5.png)

一种极端情况是：线程级别为0到N-2的等候室都被线程级别为N-2的线程Pt和线程Ps占用，Pt不能退出while循环即使被调度，因为它与Ps的线程级别相同。

![](http://stugeek.gitee.io/operating-system/Labwork14-pictures/6.png)

当线程Ps被调度时，它退出while循环，因为它不在等候室中，并立即结束for循环，进入它的临界区。

![](http://stugeek.gitee.io/operating-system/Labwork14-pictures/7.png)

进入临界区的线程将按其等候室编号N-2、N-3、...、2、1和0的顺序排列。

#### 代码部分

代码基于alg.8-1~8-3和老师给的示例文件```alg.15-1-peterson-counter.c```改造而来。

+ 在头文件**shmdata.h**中定义必要的数据和结构

```#define TEXT_SIZE 4*1024```定义了每一条消息的大小

```#define TEXT_NUM 1```定义了消息的最大条数

消息的的总大小不能超过当前最大共享内存，不然会发生无效参数的错误

```#define PERM S_IRUSR|S_IWUSR|IPC_CREAT```定义了用户的读、写、创建权限，```PERM | 0666```代表该文件拥有者、拥有者所在组其他成员、其他用户组的成员对该文件有读写的权限，但是没有操作的权限，```PERM | 0777```另外有操作的权限。
    
    #define ERR_EXIT(m)
    do {
        perror(m);
        exit(EXIT_FAILURE);
    } while(0)

```ERR_EXIT(m)```定义了一个异常处理的模板
    
    struct shared_struct {
        int written; /* flag = 0: buffer writable; others: readable */
        char mtext[TEXT_SIZE]; /* buffer for message reading and writing */
    };

```shared_struct```定义了一个共享内存中使用的结构体，其中```mtext[TEXT_SIZE]```是提供给消息进行读写的缓冲区，```written```为0时代表缓冲区可写，为其它值代表缓冲区可读。

**执行程序命令：**

    gcc -o shmread.o shmread.c -pthread
    gcc -o shmwrite.o shmwrite.c -pthread
    gcc shmcon.c -pthread
    ./a.out myshm

**实现细节解释：**

首先，进程```shmcon```会先创建一个共享内存区，然后使用```execv()```函数引发两个子进程，分别为读进程和写进程，两个子进程异步执行，并将IPC键值和两个子进程分别要创建的线程数目作为参数传递给子进程，这样保证了读进程和写进程创建的读线程和写线程数目一致，保证读写的正确。

**shmcon.c：**

    // shmcon.c文件
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>
    #include <sys/stat.h>
    #include <sys/wait.h>
    #include <sys/shm.h>
    #include <sys/syscall.h>
    #include <fcntl.h>
    #include <unistd.h>

    #include "shmdata.h"

    #define gettid() syscall(__NR_gettid)
    /* wrap the system call syscall(__NR_gettid), __NR_gettid = 224 */
    #define gettidv2() syscall(SYS_gettid) /* a traditional wrapper */

    #define THREAD_NUM 10 // 读写进程所要创建线程数

    int main(int argc, char *argv[])
    {
        struct stat fileattr;
        key_t key; // 即int类型
        int shmid; // 共享内存标识符
        void *shmptr;
        struct shared_struct *shared; // 共享内存结构体
        pid_t childpid1, childpid2;
        char pathname[80], key_str[10], thread_num_str[10];
        int shmsize, ret;

        // 确定共享内存的大小
        shmsize = TEXT_NUM*sizeof(struct shared_struct);

        // 获取共享文件对象路径名
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
    
        // 获取IPC键值
        key = ftok(pathname, 0x27);
        if(key == -1) {
            ERR_EXIT("shmcon: ftok()");
        }

        // 获取共享内存标识符
        shmid = shmget((key_t)key, shmsize, 0666|PERM);
        if(shmid == -1) {
            ERR_EXIT("shmcon: shmget()");
        }

        // 把共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存
        shmptr = shmat(shmid, 0, 0);

        if(shmptr == (void *)-1) {
            ERR_EXIT("shmcon: shmat()");
        }
        
        // 获取共享结构体，并把共享结构体的结构体的成员变量written设为0，表示缓冲区可写但不可读
        shared = (struct shared_struct *)shmptr;
        shared->written = 0;

        // 断开与共享内存附加点的地址，本进程不能访问共享内存
        if(shmdt(shmptr) == -1) {
            ERR_EXIT("shmcon: shmdt()");
        }

        // 将IPC键值和读写进程所要创建的线程数作为参数传递给读写进程
        sprintf(key_str, "%x", key);
        sprintf(thread_num_str, "%d", THREAD_NUM);
        char *argv1[] = {" ", key_str, thread_num_str, 0};

        childpid1 = vfork();
        if(childpid1 < 0) {
            ERR_EXIT("shmcon: 1st vfork()");
        } 
        else if(childpid1 == 0) {
            // 异步执行读进程
            execv("./shmread.o", argv1);
        }
        else {
            childpid2 = vfork();
            if(childpid2 < 0) {
                ERR_EXIT("shmcon: 2nd vfork()");
            }
            else if (childpid2 == 0) {
                // 异步执行写进程
                execv("./shmwrite.o", argv1);
            }
            else {
                // 等待子进程都结束后父进程再执行
                wait(&childpid1);
                wait(&childpid2);
                // 释放共享内存区
                if (shmctl(shmid, IPC_RMID, 0) == -1) {
                    ERR_EXIT("shmcon: shmctl(IPC_RMID)");
                }
                else {
                    printf("The program is over\n"); 
                }
            }
        }
        exit(EXIT_SUCCESS);
    }

读进程```shmread```和写进程```shmwrite```首先会根据父进程传来的IPC键值获取共享内存，然后根据父进程传来的创建线程数分别创建多个读线程和写线程，线程执行函数中使用了N个线程的Peterson算法实现了互斥锁，多个读线程和多个写线程分别对共享内存区的内容进行同时的读和写，同时读操作和写操作使用共享结构体的成员变量```written```防止冲突，实现了多线程读写。

**shmread.c：**

    // shmread.c文件
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>
    #include <pthread.h>
    #include <signal.h>
    #include <sys/stat.h>
    #include <sys/wait.h>
    #include <sys/shm.h>
    #include <sys/syscall.h>
    #include <fcntl.h>
    #include <unistd.h>

    #include "shmdata.h"

    #define gettid() syscall(__NR_gettid)
    /* wrap the system call syscall(__NR_gettid), __NR_gettid = 224 */
    #define gettidv2() syscall(SYS_gettid) /* a traditional wrapper */

    #define MAX_N 1024 // 所能创建线程的最大数目

    static int counter = 0; // 临界区中的进程个数
    int level[MAX_N]; // 线程级别数组，每个元素分别对应第0到第MAX_N-1个线程
    int waiting[MAX_N-1]; // 线程等候室数组，每个元素分别对应线程级别0到MAX_N-2的线程
    int read_thread_num = 20; // 默认的创建线程数目
    struct shared_struct *shared; // 共享结构体

    static void *ftn(void *arg)
    {
        // 获取线程编号
        int *numptr = (int *)arg;
        int thread_num = *numptr;
        int lev, k;
        
        // 最多有read_thread_num-1个线程等候室
        for (lev = 0; lev < read_thread_num-1; ++lev) {
            // 设置此线程的线程级别为lev，lev从0到read_thread_num-2，每次循环都会提升一次此线程的线程级别
            level[thread_num] = lev;
            // 设置等候室中线程级别为lev的线程为此线程
            waiting[lev] = thread_num;
            // 如果等候室中线程级别为lev的线程为此线程，那么线程被阻塞进入等待
            while (waiting[lev] == thread_num) {
                // 如果在此期间，任何线程级别小于此线程的线程j提升线程级别到或大于此线程，那么此线程将被踢出等候室，当被调度时退出while循环
                for (k = 0; k < read_thread_num; k++) {
                    // 从0到read_thread_num-1，如果存在不是这个线程的一个线程k，线程级别大于等于这个线程，那么退出for循环
                    if(level[k] >= lev && k != thread_num) {
                        break;
                    }
                    // 再次检查线程等候室数组中的线程级别为lev的线程是否此线程，如果不等于，退出for循环
                    if(waiting[lev] != thread_num) {
                        break;
                    }
                }
                // 其它任何线程的线程优先级都小于此线程的话，退出while循环，进入临界区
                if(k == read_thread_num) {
                    break;
                } 
            }
        }  
        // 临界区代码起始处
        counter++;
        // 如果临界区内有多于一个线程，那么终止进程
        if (counter > 1) {
            printf("ERROR! more than one processes in their critical sections\n");
            kill(getpid(), SIGKILL);
        }
        counter--;

        // 共享结构体的成员变量written为0时，说明缓冲区不可读，线程等待缓冲区可读written为1之后再继续执行
        while (shared->written == 0);
        
        // 打印读出的信息之后，把共享结构体的成员变量重新written设为0，令缓冲区可写
        printf("%*s%s is read by read-thread-%d tid=%ld\n", 30, " ", shared->mtext, thread_num, gettid());
        shared->written = 0;
        // 临界区代码结束处

        // 将此线程在level数组中的线程级别设为-1，表示线程结束，可以让其它的线程级别为read_thread_num-2的线程退出while循环进入临界区
        level[thread_num] = -1; 

        pthread_exit(0);
    }
    
    int main(int argc, char *argv[])
    {
        void *shmptr = NULL;
        int shmid;
        key_t key;

        // 获取从父进程传递来的IPC键值
        sscanf(argv[1], "%x", &key);
        // 获取从父进程传递来的创建线程个数
        sscanf(argv[2], "%d", &read_thread_num);
        
        // 获取共享内存标识符
        shmid = shmget((key_t)key, TEXT_NUM*sizeof(struct shared_struct), 0666|PERM);
        if (shmid == -1) {
            ERR_EXIT("shread: shmget()");
        }

        // 共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存
        shmptr = shmat(shmid, 0, 0);
        if(shmptr == (void *)-1) {
            ERR_EXIT("shread: shmat()");
        }
        
        // 获取共享内存结构体
        shared = (struct shared_struct *)shmptr;

        // 初始化level和waiting数组
        memset(level, (-1), sizeof(level));
        memset(waiting, (-1), sizeof(waiting));

        int i, ret;
        int thread_num[read_thread_num];
        pthread_t ptid[read_thread_num];

        // 传入参数数组
        for (i = 0; i < read_thread_num; i++) {
            thread_num[i] = i + 1;
        }

        // 打印读线程的总数
        printf("total read-thread number = %d\n", read_thread_num);  

        // 创建read_thread_num个读线程
        for (i = 0; i < read_thread_num; i++) {
            ret = pthread_create(&ptid[i], NULL, &ftn, (void *)&thread_num[i]);
            if(ret != 0) {
                fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
            }
        }

        // 主线程等待所有子线程退出后再继续执行
        for (i = 0; i < read_thread_num; i++) {
            ret = pthread_join(ptid[i], NULL);
            if(ret != 0) {
            perror("pthread_join()");
            }
        }

        // 断开与共享内存附加点的地址，本进程不能访问共享内存
        if (shmdt(shmptr) == -1) {
            ERR_EXIT("shmread: shmdt()");
        }

        return 0;
    }

**shmwrite.c：**

    // shmwrite.c文件
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <unistd.h>
    #include <pthread.h>
    #include <signal.h>
    #include <sys/stat.h>
    #include <sys/wait.h>
    #include <sys/shm.h>
    #include <sys/syscall.h>
    #include <fcntl.h>
    #include <unistd.h>

    #include "shmdata.h"

    #define gettid() syscall(__NR_gettid)
    /* wrap the system call syscall(__NR_gettid), __NR_gettid = 224 */
    #define gettidv2() syscall(SYS_gettid) /* a traditional wrapper */

    #define MAX_N 1024  // 所能创建线程的最大数目

    static int counter = 0; // 临界区中的进程个数
    int level[MAX_N]; // 线程级别数组，每个元素分别对应第0到第MAX_N-1个线程
    int waiting[MAX_N-1]; // 线程等候室数组，每个元素分别对应线程级别0到MAX_N-2的线程
    int write_thread_num = 20; // 默认的创建线程数目
    struct shared_struct *shared; // 共享结构体

    static void *ftn(void *arg)
    {
        // 获取线程编号
        int *numptr = (int *)arg;
        int thread_num = *numptr;
        int lev, k;

        char buffer[BUFSIZ + 1];
            
        // 最多有write_thread_num-1个线程等候室
        for (lev = 0; lev < write_thread_num-1; ++lev) {
            // 设置此线程的线程级别为lev，lev从0到write_thread_num-2，每次循环都会提升一次此线程的线程级别
            level[thread_num] = lev;
            // 设置等候室中线程级别为lev的线程为此线程
            waiting[lev] = thread_num;
            // 如果等候室中线程级别为lev的线程为此线程，那么线程被阻塞进入等待
            while (waiting[lev] == thread_num) {
                // 如果在此期间，任何线程级别小于此线程的线程j提升线程级别到或大于此线程，那么此线程将被踢出等候室，当被调度时退出while循环
                for (k = 0; k < write_thread_num; k++) {
                    // 从0到write_thread_num-1，如果存在不是这个线程的一个线程k，线程级别大于等于这个线程，那么退出for循环
                    if(level[k] >= lev && k != thread_num) {
                        break;
                    }
                    // 再次检查线程等候室数组中的线程级别为lev的线程是否此线程，如果不等于，退出for循环
                    if(waiting[lev] != thread_num) {
                        break;
                    }
                }
                // 其它任何线程的线程优先级都小于此线程的话，退出while循环，进入临界区
                if(k == write_thread_num) {
                    break;
                } 
            }
        }
        // 临界区代码起始处
        counter++;
        // 如果临界区内有多于一个线程，那么终止进程
        if (counter > 1) {
            printf("ERROR! more than one processes in their critical sections\n");
            kill(getpid(), SIGKILL);
        }
        counter--;

        // 共享结构体的成员变量written为1时，说明缓冲区不可写，线程等待缓冲区可写written为0之后再继续执行
        while (shared->written == 1);

        // 写入信息之后，把共享结构体的成员变量written重新设为1，令缓冲区可读
        sprintf(buffer, "\"message from thread tid=%ld\"", gettid());
        printf("\nwrite-thread-%d tid=%ld writes: %s\n", thread_num, gettid(), buffer);
        strncpy(shared->mtext, buffer, TEXT_SIZE);
        shared->written = 1;
        // 临界区代码结束处

        // 将此线程在level数组中的线程级别设为-1，表示线程结束，可以让其它的线程级别为write_thread_num-2的线程退出while循环进入临界区
        level[thread_num] = -1; 

        pthread_exit(0);
    }
    
    int main(int argc, char *argv[])
    {
        void *shmptr = NULL;
        int shmid;
        key_t key;

        // 获取从父进程传递来的IPC键值
        sscanf(argv[1], "%x", &key);
        // 获取从父进程传递来的创建线程个数
        sscanf(argv[2], "%d", &write_thread_num);
        
        // 获取共享内存标识符
        shmid = shmget((key_t)key, TEXT_NUM*sizeof(struct shared_struct), 0666|PERM);
        if (shmid == -1) {
            ERR_EXIT("shread: shmget()");
        }

        // 共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存
        shmptr = shmat(shmid, 0, 0);
        if(shmptr == (void *)-1) {
            ERR_EXIT("shread: shmat()");
        }
        
        // 获取共享内存结构体
        shared = (struct shared_struct *)shmptr;

        // 初始化level和waiting数组
        memset(level, (-1), sizeof(level));
        memset(waiting, (-1), sizeof(waiting));

        int i, ret;
        int thread_num[write_thread_num];
        pthread_t ptid[write_thread_num];

        // 传入参数数组
        for (i = 0; i < write_thread_num; i++) {
            thread_num[i] = i + 1;
        }

        // 打印写线程的总数
        printf("total wrtie-thread number = %d\n", write_thread_num);  

        // 创建write_thread_num个写线程
        for (i = 0; i < write_thread_num; i++) {
            ret = pthread_create(&ptid[i], NULL, &ftn, (void *)&thread_num[i]);
            if(ret != 0) {
                fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
            }
        }

        // 主线程等待所有子线程退出后再继续执行
        for (i = 0; i < write_thread_num; i++) {
            ret = pthread_join(ptid[i], NULL);
            if(ret != 0) {
            perror("pthread_join()");
            }
        }

        // 断开与共享内存附加点的地址，本进程不能访问共享内存
        if (shmdt(shmptr) == -1) {
            ERR_EXIT("shmread: shmdt()");
        }

        return 0;
    }

**分析：**

在```shmcon.c```文件中，改变要创建的线程数量，可以对程序进行测试

**测试用例1：**

当创建的读线程和写线程数量分别为10个时：

    #define THREAD_NUM 10

![](http://stugeek.gitee.io/operating-system/Labwork14-pictures/8.png)

可以看到，多个读线程并发进行读，多个写线程并发进行写，由于使用了Peterson算法和成员变量written，读写有序进行，每次写入一个内容，读出的是相同的内容，多个读线程并发读没有冲突，多个写线程并发写也没有冲突，在读线程和写线程数量分别为10时，线程数量较少，程序可以正常进行。

**测试用例2：**

当创建的读线程和写线程数量分别为100个时：

    #define THREAD_NUM 100

![](http://stugeek.gitee.io/operating-system/Labwork14-pictures/9.png)

可以看到，多个读线程并发进行读，多个写线程并发进行写，读写有序进行，每次写入一个内容，读出的是相同的内容，多个读线程并发读没有冲突，多个写线程并发写也没有冲突，程序可以正常进行，在读线程和写线程数量分别为100时，线程数量一般，因为for循环的循环次数增多，所以程序运行的速度稍微变慢。

**测试用例3：**

当创建的读线程和写线程数量分别为500个时：

    #define THREAD_NUM 500

![](http://stugeek.gitee.io/operating-system/Labwork14-pictures/10.png)

可以看到，多个读线程并发进行读，多个写线程并发进行写，读写有序进行，每次写入一个内容，读出的是相同的内容，多个读线程并发读没有冲突，多个写线程并发写也没有冲突，程序可以正常进行。在读线程和写线程数量分别为500时，线程数量较多，因为for循环的循环次数变的太多，所以程序运行的速度非常的慢。