# 操作系统实验报告13

## 实验内容

+ 实验内容：设计实现一个线程池 (Thread Pool)
    + 使用 Pthread API
    + FIFO
    + 先不考虑互斥问题
    + 编译、运行、测试用例

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### 实验内容原理

#### 线程池

实验内容原理：

+ 线程池
    + 问题：
        + 数量上没有限制的线程可能耗尽系统资源，如CPU时间或内存。
    + 解决方案：
        + 在进程启动时创建多个线程，并将它们放入线程池中，它们坐在那里等待工作。
        + 当服务器收到一个请求时，它会从这个池中唤醒一个可用的线程，并将服务请求传递给它。
        + 一旦线程完成其服务，它就会返回到池并等待更多的工作。如果池中不包含可用线程，服务器将等待一个线程空闲。
    + 例子：
        + IA-32中每个进程的最大线程数。
        + 这个数字大约是300，3G地址空间中每个线程的默认堆栈大小为10M。
        + 可以创建少于255个线程的池。
    + 线程池的好处
        + 使用现有线程为请求提供服务通常比等待创建新线程要快一些。
        + 线程池限制任何一点上存在的线程数。对于不能支持大量并发线程的系统，这一点尤为重要。
        + 将要执行的任务与创建任务的机制分离，允许我们使用不同的策略来运行任务。
    + 线程池的大小
        + 池中的线程数可以根据系统中cpu的数量、物理内存的数量和预期的并发客户机请求的数量等因素进行启发式设置。
        + 更为复杂的线程池架构（如Apple的Grand Central Dispatch）可以根据使用模式动态调整池中的线程数。

### 设计报告

#### 线程池设计图

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/1.png)

#### 代码设计

测试代码：

    //threadpools.c文件
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <sched.h>
    #include <pthread.h>
    #include <sys/stat.h>
    #include <sys/types.h>
    #include <sys/wait.h>
    #include <sys/ipc.h>
    #include <sys/msg.h>
    #include <sys/syscall.h>
    #include <fcntl.h>
    #include <unistd.h>

    #define gettid() syscall(__NR_gettid)
    /* wrap the system call syscall(__NR_gettid), __NR_gettid = 224 */
    #define gettidv2() syscall(SYS_gettid) /* a traditional wrapper */

    #define THREADS_NUM 10 // 线程池中的线程个数
    #define TASK_QUEUE_MAX_SIZE 12 // 任务的等待队列的最大长度，等待队列中的最大任务个数为长度减一
    #define TASK_NUM 50 // 要执行的任务总数

    // 线程池中每个线程执行的任务的结构体
    typedef struct {
        void *(*function)(void *); // 执行函数
        void *arg; // 参数
    } Task;

    // 任务循环队列的数据结构
    typedef struct {
        Task tasks[TASK_QUEUE_MAX_SIZE]; // 任务队列数组
        int front; // 队首下标
        int rear; // 队尾下标
    } TaskQueue;

    // 线程池数据结构
    typedef struct {
    pthread_t threads[THREADS_NUM]; // 线程数组
    TaskQueue taskQueue; // 任务队列
    int taskSum; // 剩余任务总数，结束程序用
    } Threadpools;

    // 线程池中每个线程执行的任务
    static void *executeTask(void *arg) {
        // 向每个线程传入的参数是线程池
        Threadpools *pools = (Threadpools *)arg;
        while (1) {
            // 当任务队列为空时
            while (pools->taskQueue.front == pools->taskQueue.rear) {
                // 如果已经没有剩余任务要处理，那么退出线程
                if (pools->taskSum == 0) {
                    printf("Thread %ld exits.\n", gettid());
                    pthread_exit(NULL);
                }
                // 否则等待任务队列中有任务后再取任务进行执行
                printf("Thread %ld is waiting for a task.\n", gettid());
                sleep(1);                
            }
            // 剩余任务总数减一
            pools->taskSum--;
            // 获取任务队列队首的任务
            Task task;
            int front = pools->taskQueue.front;
            task.function = pools->taskQueue.tasks[front].function;
            task.arg = pools->taskQueue.tasks[front].arg;
            // 循环队列队首下标加一
            pools->taskQueue.front = (front + 1) % TASK_QUEUE_MAX_SIZE;
            // 执行任务
            (*(task.function))(task.arg);
        }
    }

    // 初始化线程池
    void initThreadpools(Threadpools *pools) {
        // 任务队列的队首和队尾的坐标都为0
        pools->taskQueue.front = 0;
        pools->taskQueue.rear = 0;
        // 线程池中剩余的任务总数设置为总任务数
        pools->taskSum = TASK_NUM;
        // 创建线程池中的线程
        for(int i = 0; i < THREADS_NUM; ++i) {
            pthread_create(&pools->threads[i], NULL, executeTask, (void *)pools);
        }
    }

    // 向任务队列中添加任务
    void addTask(Threadpools *pools, void *(*function)(void *arg), void *arg) {
        // 当任务队列为满时，等待有任务被取出任务队列不为满再加入队列
        while ((pools->taskQueue.rear + TASK_QUEUE_MAX_SIZE + 1 - 
                        pools->taskQueue.front) % TASK_QUEUE_MAX_SIZE == 0) {
            printf("Task %d is waiting to be added to the task queue.\n", *(int *)arg);
            sleep(1);
        }
        // 向任务队列的队尾加入任务
        Task task;
        task.function = function;
        task.arg = arg;
        int rear = pools->taskQueue.rear;
        pools->taskQueue.tasks[rear] = task;
        // 任务队列队尾下标加一
        pools->taskQueue.rear = (rear + 1) % (TASK_QUEUE_MAX_SIZE);
    }

    // 任务函数
    static void *taskFunction(void *arg) {
        // 获取每个任务的任务号
        int *numptr = (int *)arg;
        int taskId = *numptr;
        // 打印线程池中的哪个线程正在处理此任务
        printf("Thread tid = %ld is dealing with task %d\n", gettid(), taskId);
        // 每个任务休眠1s后继续执行
        printf("Task %d is sleeping for 1s.\n", taskId);
        sleep(1);
        // 打印任务完成信息和线程被复用
        printf("\t\t\t\tTask %d is finished and Thread tid = %ld is reused\n", taskId, gettid());
    }

    int main() {
        // 创建并初始化线程池
        Threadpools pools;
        initThreadpools(&pools);
        // 休眠1s测试线程池中的线程在任务队列为空时是否会等待
        sleep(1);

        // 传入参数数组
        int num[TASK_NUM];
        for(int i = 0; i < TASK_NUM; ++i) {
            num[i] = i + 1;
        }

        // 向任务队列中连续添加任务
        for(int i = 0; i < TASK_NUM; ++i) {
            addTask(&pools, taskFunction, (void *)&num[i]);
        }

        // 主线程等待线程池中的线程全部结束后再继续
        for(int i = 0; i < THREADS_NUM; ++i) {
            pthread_join(pools.threads[i], NULL);
        }

        // 所有任务都执行完，线程池也退出
        printf("\nAll %d tasks have been finished.\n", TASK_NUM);
    }

**首先进行宏定义：**

    #define THREADS_NUM 10 // 线程池中的线程个数
    #define TASK_QUEUE_MAX_SIZE 12 // 任务的等待队列的最大长度，等待队列中的最大任务个数为长度减一
    #define TASK_NUM 50 // 要执行的任务总数

为了方便测试，这里线程个数和任务队列长度设置的较小，要执行的任务总数相对线程个数较多。

**然后定义使用到的数据结构：**

**任务：**

    // 线程池中每个线程执行的任务的结构体
    typedef struct {
        void *(*function)(void *); // 执行函数
        void *arg; // 参数
    } Task;

**任务队列和线程池：**

    // 任务循环队列的数据结构
    typedef struct {
        Task tasks[TASK_QUEUE_MAX_SIZE]; // 任务队列数组
        int front; // 队首下标
        int rear; // 队尾下标
    } TaskQueue;

    // 线程池数据结构
    typedef struct {
    pthread_t threads[THREADS_NUM]; // 线程数组
    TaskQueue taskQueue; // 任务队列
    int taskSum; // 剩余任务总数，结束程序用
    } Threadpools;

**线程池初始化函数：**

    // 初始化线程池
    void initThreadpools(Threadpools *pools) {
        // 任务队列的队首和队尾的坐标都为0
        pools->taskQueue.front = 0;
        pools->taskQueue.rear = 0;
        // 线程池中剩余的任务总数设置为总任务数
        pools->taskSum = TASK_NUM;
        // 创建线程池中的线程
        for(int i = 0; i < THREADS_NUM; ++i) {
            pthread_create(&pools->threads[i], NULL, executeTask, (void *)pools);
        }
    }

创建线程池中的线程时，可以看到每个线程执行的函数都为```executeTask()```任务执行函数。

对应设计图中的初始化线程池部分：

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/2.png)

**线程执行函数：**

    // 线程池中每个线程执行的任务
    static void *executeTask(void *arg) {
        // 向每个线程传入的参数是线程池
        Threadpools *pools = (Threadpools *)arg;
        while (1) {
            // 当任务队列为空时
            while (pools->taskQueue.front == pools->taskQueue.rear) {
                // 如果已经没有剩余任务要处理，那么退出线程
                if (pools->taskSum == 0) {
                    printf("Thread %ld exits.\n", gettid());
                    pthread_exit(NULL);
                }
                // 否则等待任务队列中有任务后再取任务进行执行
                printf("Thread %ld is waiting for a task.\n", gettid());
                sleep(1);                
            }
            // 剩余任务总数减一
            pools->taskSum--;
            // 获取任务队列队首的任务
            Task task;
            int front = pools->taskQueue.front;
            task.function = pools->taskQueue.tasks[front].function;
            task.arg = pools->taskQueue.tasks[front].arg;
            // 循环队列队首下标加一
            pools->taskQueue.front = (front + 1) % TASK_QUEUE_MAX_SIZE;
            // 执行任务
            (*(task.function))(task.arg);
        }
    }

可以看到，每个线程执行完任务后，若还有剩余任务且任务队列不为空，线程会自动从任务队列中获取任务，继续执行任务，而不用手动为每一个任务指定一个空闲线程进行执行，任务队列为循环队列，每次从任务队列的队首获取任务，保证了FIFO。

对应设计图中的每个线程获取任务的箭头部分：

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/3.png)

**将任务添加到任务队列函数：**

    // 向任务队列中添加任务
    void addTask(Threadpools *pools, void *(*function)(void *arg), void *arg) {
        // 当任务队列为满时，等待有任务被取出任务队列不为满再加入队列
        while ((pools->taskQueue.rear + TASK_QUEUE_MAX_SIZE + 1 - 
                        pools->taskQueue.front) % TASK_QUEUE_MAX_SIZE == 0) {
            printf("Task %d is waiting to be added to the task queue.\n", *(int *)arg);
            sleep(1);
        }
        // 向任务队列的队尾加入任务
        Task task;
        task.function = function;
        task.arg = arg;
        int rear = pools->taskQueue.rear;
        pools->taskQueue.tasks[rear] = task;
        // 任务队列队尾下标加一
        pools->taskQueue.rear = (rear + 1) % (TASK_QUEUE_MAX_SIZE);
    }

可以看到，任务队列为循环队列，每次向任务队列的队尾添加任务，保证了FIFO。

对应设计图中的将任务添加到任务队列的箭头部分：

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/4.png)

**每个任务执行的函数：**

    // 任务函数
    static void *taskFunction(void *arg) {
        // 获取每个任务的任务号
        int *numptr = (int *)arg;
        int taskId = *numptr;
        // 打印线程池中的哪个线程正在处理此任务
        printf("Thread tid = %ld is dealing with task %d\n", gettid(), taskId);
        // 每个任务休眠1s后继续执行
        printf("Task %d is sleeping for 1s.\n", taskId);
        sleep(1);
        // 打印任务完成信息和线程被复用
        printf("\t\t\t\tTask %d is finished and Thread tid = %ld is reused\n", taskId, gettid());
    }

对应设计图中的每个任务执行的内容部分：

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/5.png)

**主函数中：**

    int main() {
        // 创建并初始化线程池
        Threadpools pools;
        initThreadpools(&pools);
        // 休眠1s测试线程池中的线程在任务队列为空时是否会等待
        sleep(1);

        // 传入参数数组
        int num[TASK_NUM];
        for(int i = 0; i < TASK_NUM; ++i) {
            num[i] = i + 1;
        }

        // 向任务队列中连续添加任务
        for(int i = 0; i < TASK_NUM; ++i) {
            addTask(&pools, taskFunction, (void *)&num[i]);
        }

        // 主线程等待线程池中的线程全部结束后再继续
        for(int i = 0; i < THREADS_NUM; ++i) {
            pthread_join(pools.threads[i], NULL);
        }

        // 所有任务都执行完，线程池也退出
        printf("\nAll %d tasks have been finished.\n", TASK_NUM);
    }

主函数中，先创建线程池，此时线程处在等待状态，然后再添加任务，线程池中的线程执行完所有的任务后，再退出程序。

执行命令：

    gcc threadpools.c -pthread
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/6.png)

可以看到，一开始当任务队列中还没有任务时，线程池中的线程会等待任务队列中有任务后再取出任务接着执行。

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/7.png)

可以看到，每个线程按照FIFO从任务队列中取出任务进行执行，每个任务会休眠1s，如果任务队列已满，新的任务会等待任务队列有任务被取出后再加入任务队列。

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/8.png)

可以看到，任务执行完成之后，线程池中的线程会被复用，同一个tid的线程会自动从任务队列中获取任务，可以执行不同的任务。

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/9.png)

可以看到，当所有的任务都被执行完后，线程池中所有线程退出，回到主线程之后继续，程序正常退出。
