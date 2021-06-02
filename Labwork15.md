# 操作系统实验报告15

## 实验内容

+ 实验内容：进程同步。
    + 内容1：编译运行课件 Lecture18 例程代码。
        + Algorithms 18-1 ~ 18-9. 
    + 内容2：在 Lab Week 13 的基础上用信号量解决线程池分配的互斥问题。
        + 编译、运行、测试用例。
        + 提交新的设计报告

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### 内容1：编译运行课件 Lecture18 例程代码

实验内容原理：

+ Linux版本
    + 在版本2.6之前，Linux为非抢占内核，即使有一个更高优先级的进程能够运行，它也不能抢占在内核模式下运行的其它进程。
    + 版本2.6及更高版本，Linux内核是完全可抢占的。这样在内核态下运行的任务也能被抢占。
+ Linux在内核中提供了几种不同的同步机制：
    + __sync_fetch_类型
    + 自旋锁
    + 互斥锁
    + 信号量
    + 自旋锁和信号量的读者-写者版本。
+ 在单CPU系统上，自旋锁被启用和禁用内核抢占取代。

#### gcc __sync_系列原子操作函数

    // 将value加到*ptr上，结果更新到*ptr，并返回操作之前*ptr的值
    type __sync_fetch_and_add (type *ptr, type value); 
    
    // 从*ptr减去value，结果更新到*ptr，并返回操作之前*ptr的值
    type __sync_fetch_and_sub (type *ptr, type value, ...) 

    // 将*ptr与value相或，结果更新到*ptr， 并返回操作之前*ptr的值
    type __sync_fetch_and_or (type *ptr, type value, ...) 
    
    // 将*ptr与value相与，结果更新到*ptr，并返回操作之前*ptr的值
    type __sync_fetch_and_and (type *ptr, type value, ...) 

    // 将*ptr与value异或，结果更新到*ptr，并返回操作之前*ptr的值
    type __sync_fetch_and_xor (type *ptr, type value, ...) 
    
    // 将*ptr取反后，与value相与，结果更新到*ptr，并返回操作之前*ptr的值
    type __sync_fetch_and_nand (type *ptr, type value, ...) 
    
    // 将value加到*ptr上，结果更新到*ptr，并返回操作之后新*ptr的值
    type __sync_add_and_fetch (type *ptr, type value, ...) 
    
    // 从*ptr减去value，结果更新到*ptr，并返回操作之后新*ptr的值
    type __sync_sub_and_fetch (type *ptr, type value, ...) 
    
    // 将*ptr与value相或， 结果更新到*ptr，并返回操作之后新*ptr的值
    type __sync_or_and_fetch (type *ptr, type value, ...) 
    
    // 将*ptr与value相与，结果更新到*ptr，并返回操作之后新*ptr的值
    type __sync_and_and_fetch (type *ptr, type value, ...) 
    
    // 将*ptr与value异或，结果更新到*ptr，并返回操作之后新*ptr的值
    type __sync_xor_and_fetch (type *ptr, type value, ...)
    
    // 将*ptr取反后，与value相与，结果更新到*ptr，并返回操作之后新*ptr的值
    type __sync_nand_and_fetch (type *ptr, type value, ...) 
    
    // 比较*ptr与oldval的值，如果两者相等，则将newval更新到*ptr并返回true
    bool __sync_bool_compare_and_swap (type *ptr, type oldval type newval, ...)
    
    // 比较*ptr与oldval的值，如果两者相等，则将newval更新到*ptr并返回操作之前*ptr的值
    type __sync_val_compare_and_swap (type *ptr, type oldval type newval, ...) 

    // 发出完整内存栅栏
    __sync_synchronize (...) 

    // 将value写入ptr，对ptr加锁，并返回操作之前ptr的值。
    type __sync_lock_test_and_set (type ptr, type value, ...)

    // 将0写入到ptr，并对*ptr解锁。
    void __sync_lock_release (type ptr, ...)

其中```type```可以是类型```uint8_t```, ```unt16_t```, ```uint32_t```, ```unt64_t```。

+ 验证实验**alg.18-1-syn-fetch-1.c**

执行程序命令：

    gcc alg.18-1-syn-fetch-1.c
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/1.png)

实现细节解释：

一开始先让变量i等于10，然后在同一条打印语句中打印函数```__sync_fetch_and_add(&i, 20)```的返回值和i的值，```__sync_fetch_and_add(&i, 20)```是无锁化原子操作语句，实现的是先取值再加第二个参数即20的操作，返回操作前i的值，所以语句执行后获取到的值还是原来i的值，即是10，而在同一条打印语句中的i的值与函数```__sync_fetch_and_add(&i, 20)```无关，所以i的值还是10，下一条语句还是打印i的值，此时已经执行完函数```__sync_fetch_and_add(&i, 20)```，所以可以看到此时i的值为30。

接着继续让变量i等于10，然后在同一条打印语句中打印函数```__sync_add_and_fetch(&i, 20)```的返回值和i的值，```__sync_add_and_fetch(&i, 20)```是无锁化原子操作语句，实现的是先加第二个参数即20再取值的操作，返回操作后i的值，所以语句执行后获取到的值还是加上20后i的值，即是30，而在同一条打印语句中的i的值与函数```__sync_add_and_fetch(&i, 20)```无关，所以i的值还是10，下一条语句还是打印i的值，此时已经执行完函数```__sync_add_and_fetch(&i, 20)```，所以可以看到此时i的值为30。

+ 验证实验**alg.18-1-syn-fetch-2.c**

执行程序命令：

    gcc alg.18-1-syn-fetch-2.c -pthread
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/2.png)

可以看到，每个线程在加1的时候，因为使用的是```__sync_fetch_and_add()```函数，是原子化操作，所以没有发生条件冲突而产生错误的值，值为40*20000=800000，计算结果正确。

实现细节解释：

一开始使用语句```pthread_create(&ptid[i], NULL, &test_func, NULL)```创建```MAX_N```即40个线程，每个线程的线程执行函数都为：

    void *test_func(void *arg)
    {
        for (int i = 0; i < 20000; ++i)
            __sync_fetch_and_add(&count, 1);
            /* count++; gave a wrong result */ 
        return NULL;
    }

**线程执行函数**的作用为使用```__sync_fetch_and_add(&count, 1)```语句使全局静态变量```count```加1加20000次。

**回到主线程中**，使用```pthread_join(ptid[i], NULL)```语句使主线程等待```MAX_N```即40个线程结束后再继续运行，最后打印```count```的值，值为40*20000=800000，因为```__sync_fetch_and_add()```函数是原子化操作，避免了每个线程在count加1时发生条件冲突，这样得到的结果也是无误的，程序运行正确。

+ 验证实验**alg.18-1-syn-fetch-3.cc**

执行程序命令：

    gcc alg.18-1-syn-fetch-3.c -pthread
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/3.png)

可以看到，每个线程在加1的时候，因为使用的是```count++```语句，不是原子操作语句，所以产生了条件冲突而产生错误的值，值不为40*20000=800000，而是694845， 计算结果错误。

实现细节解释：

和之前一个程序相比，这个程序在线程执行函数中使用的是```count++```语句使全局静态变量```count```加1加20000次，这样因为使用的不是原子操作语句，分成从缓存取到寄存器中，寄存器加一，再存入缓存三步进行，所以各个线程会很容易发生条件冲突，最后产生的是一个错的结果。

+ 验证实验**alg.18-2-syn-compare-test.c**

执行程序命令：

    gcc alg.18-2-syn-compare-test.c
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/4.png)

实现细节解释：

第一个代码片段中，```value```值为200000，```oldval```值为123456，```newval```值为654321，执行语句```__sync_bool_compare_and_swap(&value, oldval, newval)```，比较```value```与```oldval```的值，因为不相等，所以```value```保持原值，并返回```false```给```ret```，所以最后打印结果，```ret```为```0```，```value```为```200000```，```oldval```为```123456```，```newval```为```654321```。

第二个代码片段中，```value```值为200000，```oldval```值为200000，```newval```值为654321，执行语句```__sync_bool_compare_and_swap(&value, oldval, newval)```，比较```value```与```oldval```的值，因为相等，所以```newval```更新到```value```，并返回```true```给```ret```，所以最后打印结果，```ret```为```1```，```value```为```654321```，```oldval```为```123456```，```newval```为```654321```。

第三个代码片段中，```value```值为200000，```oldval```值为123456，```newval```值为654321，执行语句```__sync_val_compare_and_swap(&value, oldval, newval)```，比较```value```与```oldval```的值，因为不相等，所以```value```保持原值，并返回操作之前```value```的值给```ret```，所以最后打印结果，```ret```为```200000```，```value```为```200000```，```oldval```为```123456```，```newval```为```654321```。

第四个代码片段中，```value```值为200000，```oldval```值为200000，```newval```值为654321，执行语句```__sync_val_compare_and_swap(&value, oldval, newval)```，比较```value```与```oldval```的值，因为相等，所以```newval```的值更新到```value```，并返回操作之前```value```的值给```ret```，所以最后打印结果，```ret```为```200000```，```value```为```654321```，```oldval```为```200000```，```newval```为```654321```。

第五个代码片段中，```value```值为200000，```newval```值为654321，执行语句```__sync_lock_test_and_set(&value, newval)```，将```newval```写入```value```，对```value```加锁，并返回操作之前```value```的值，所以最后打印结果，```ret```为```200000```，```value```为```654321```，```newval```为```654321```。

第六个代码片段中，```value```值为200000，执行语句```__sync_lock_release(&value)```，将0写入到```value```，并对```&value```解锁，所以最后打印结果，```value```为```0```。

#### POSIX互斥锁

+ 互斥锁用于保护代码的临界区，即线程在进入临界区之前获取锁，并在退出临界区时释放锁。
+ Pthreads互斥锁采用数据类型```pthread_mutex_t```。一个互斥锁可以使用```pthread_mutex_init()```函数创建。

    ```c
    #include <pthread.h>

    pthread_mutex_t mutex;

      /* 创建并初始化这个互斥锁 */
    pthread_mutex_init(&mutex, NULL);
    ```

    + 第一个参数是指向互斥锁的指针。第二个参数是NULL，表示将互斥锁按照其默认属性初始化。

+ 互斥锁是通过```pthread_mutex_lock()```和```pthread_mutex_unlock()```函数来获取和释放的。如果调用```pthread_mutex_lock()```时互斥锁不可用，则调用线程将被阻塞在等待队列中，直到互斥锁的所有者调用```pthread_mutex_unlock()```释放互斥锁为止。
+ 以下代码说明了如何使用互斥锁保护临界区：

```c
  /*获取互斥锁*/
pthread_mutex_lock(&mutex);
临界区
  /*释放互斥锁*/
pthread_mutex_unlock(&mutex);
剩余区
```
所有互斥函数当操作正确是返回值为0，如果发生错误，这些函数将返回非零错误代码。

+ 验证实验**alg.18-3-syn-pthread-mutex.c**

执行程序命令：

    gcc alg.18-3-syn-pthread-mutex.c -pthread
    ./a.out
    ./a.out syn

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/5.png)

可以看到，当编译命令中没有参数时，得到的加法结果是一个错误的结果；当编译命令中有参数```syn```时，得到的加法结果是正确的结果800000。

实现细节解释：

首先在全局中，使用```pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER```将```pthread_mutex_t```类型变量```mutex```使用宏定义```PTHREAD_MUTEX_INITIALIZER```进行静态初始化，或者在主函数中使用语句```pthread_mutex_init (&mutex, NULL)```进行初始化。主函数最后会等待创建的线程都执行完后再继续进行，然后使用```pthread_mutex_destroy(&mutex)```语句释放互斥锁，最后打印```count```结果。

当程序的编译命令参数是```syn```时，程序创建```MAX_N```即40个线程，每个线程的执行函数都为：

    void *test_func_syn(void *arg)
    {
        for (int i = 0; i < 20000; ++i) {
            pthread_mutex_lock(&mutex);
            count++;
            pthread_mutex_unlock(&mutex);
        }

        pthread_exit(NULL);
    }

在**线程执行函数**中，有一个执行20000次的for循环，里面每次使```count```自增前得到一个互斥锁，然后再令```count```自增，最后再释放互斥锁，这样保证了线程之间不会出现竞争条件冲突，```count```的自增操作有序进行，最后得到的也是正确结果800000。

当程序的编译命令没有参数或参数不是```syn```时，程序创建```MAX_N```即40个线程，每个线程的执行函数都为：

    void *test_func_asy(void *arg)
    {
        for (int i = 0; i < 20000; ++i) {
            count++;
        }

        pthread_exit(NULL);
    }

在**线程执行函数**中，有一个执行20000次的for循环，里面没有使用互斥锁而是直接让```count```进行自增，这样容易发生条件冲突，最后得到的结果也并不正确613245。

#### POSIX信号量

+ POSIX SEM 扩展指定了两种类型的信号量：命名信号量和无名信号量。从内核的版本2.6开始，Linux系统提供对这两种类型的支持。
+ POSIX命名信号量
    + 函数```sem_open()```用于创建新的或打开已经存在的信号量：
        ```c
        #include <fcntl.h>
        #include <sys/stat.h>
        #include <semaphore.h>
        sem_t *sem_open(const char *name, int oflag);
        sem_t *sem_open(const char *name, int oflag, mode_t mode, unsigned int value);
        ```
    + 例如：
  
        ```c
        sem_t *sem;
        sem = sem_open("MYSEM", O_CREAT, 0666, 1);
        ```
        + 命名信号量```MYSEM```被创建并初始化为1。它对其他进程具有读写访问权限。
    + 多个不相关的进程可以简单地通过引用信号量的名称，使用一个通用的命名信号量作为同步机制。
    + 在上面的示例中，一旦创建了信号量```MYSEM```，其他进程随后使用相同参数调用```sem_open()```时，会将描述符```sem```返回给现有的信号量。POSIX分别声明这些操作为```sem_wait(sem)```和```sem_post(sem)```。
    + 下面说明如何使用上面创建的命名信号量保护临界区：
        ```c
        sem_wait(sem); /* 获取信号量 */
        临界区
        sem_post(sem); /* 释放信号量 */
        ...
        sem_close(sem);
         ```
+ POSIX无名信号量
    + 无名信号量是通过```sem_init()```函数进行创建和初始化的，该函数传递了三个参数：
    （1）信号量的指针
    （2）表示共享级别的标志
    （3）信号量的初始值
        ```c
        int sem_init(sem_t *sem, int pshared, unsigned int value)
        ```
    + 例如：
        ```c
        #include <semaphore.h>
        sem_t sem;
        sem_init(&sem, 0, 1); /* 创建信号量并将其初始化为1 */
        ```
    + pshared = 0表示此信号量只能由属于创建该信号量的同一进程的线程共享。
    + 信号量设置为值1。
    + POSIX无名信号量对描述符```sem```也使用了与命名信号量相同的sem_wait(sem)和sem_post(sem)操作。
    + 下面说明如何使用上面创建的无名信号量保护临界区：
        ```c
        sem_wait(&sem); /* 获取信号量 */
        临界区
        sem_post(&sem); /* 释放信号量 */
        ... 
        sem_destroy(&sem);
        ```

通常在进程间同步中使用命名信号量，而无名信号量用于线程间通信。

+ 验证实验**alg.18-4-syn-pthread-sem-unnamed.c**

执行程序命令：

    gcc alg.18-4-syn-pthread-sem-unnamed.c -pthread
    ./a.out syn
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/6.png)

可以看到，当编译命令中有参数```syn```时，得到的加法结果是正确的结果800000；当编译命令中没有参数时，得到的加法结果是一个错误的结果。

实现细节解释：

首先在全局中，声明一个信号量标识符类型```sem_t```变量```unnamed_sem```，然后在主函数中使用语句```sem_init(&unnamed_sem, 0, 1)```创建无名信号量```unnamed_sem```并初始化为1。主函数最后会等待创建的线程都执行完后再继续进行，然后打印```count```结果，最后使用```sem_destroy(&unnamed_sem)```语句销毁信号量。

当程序的编译命令参数是```syn```时，程序创建```MAX_N```即40个线程，每个线程的执行函数都为：

    void *test_func_syn(void *arg)
    {
        for (int i = 0; i < 20000; ++i) {
            sem_wait(&unnamed_sem);
            count++;
            sem_post(&unnamed_sem);
        }

        pthread_exit(NULL);
    }

在**线程执行函数**中，有一个执行20000次的for循环，里面每次使```count```自增前得到一个信号量，然后再令```count```自增，最后再释放信号量，这样保证了线程之间不会出现竞争条件冲突，```count```的自增操作有序进行，最后得到的也是正确结果800000。

当程序的编译命令没有参数或参数不是```syn```时，程序创建```MAX_N```即40个线程，每个线程的执行函数都为：

    void *test_func_asy(void *arg)
    {
        for (int i = 0; i < 20000; ++i) {
            count++;
        }

        pthread_exit(NULL);
    }

在**线程执行函数**中，有一个执行20000次的for循环，里面没有使用信号量而是直接让```count```进行自增，这样容易发生条件冲突，最后得到的结果也并不正确632537。

+ 验证实验**alg.18-5-syn-pthread-sem-named.c**

执行程序命令：

    gcc alg.18-5-syn-pthread-sem-named.c -pthread
    ./a.out syn
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/7.png)

可以看到，当编译命令中有参数```syn```时，得到的加法结果是正确的结果800000；当编译命令中没有参数时，得到的加法结果是一个错误的结果。

实现细节解释：

首先在全局中，声明一个信号量标识符类型```sem_t *```指针变量```named_sem```，然后在主函数中使用语句```named_sem = sem_open("MYSEM", O_CREAT, 0666, 1)```创建命名信号量```MYSEM```并初始化为1，并返回信号量标识符给变量```named_sem ```，这时一个名为```sem.MYSEM```的文件将会在```/dev/shm/```目录下被创建，任何知道这个文件名的进程和线程都可以共享这个信号量。

主函数最后会等待创建的线程都执行完后再继续进行，然后打印```count```结果，接着使用```sem_close(named_sem)```语句关闭命名信号量，最后使用语句```sem_unlink("MYSEM")```从```/dev/shm/```目录下移除```sem.MYSEM```文件当其标识符为0时。

当程序的编译命令参数是```syn```时，程序创建```MAX_N```即40个线程，每个线程的执行函数都为：

    void *test_func_syn(void *arg)
    {
        for (int i = 0; i < 20000; ++i) {
            sem_wait(&unnamed_sem);
            count++;
            sem_post(&unnamed_sem);
        }

        pthread_exit(NULL);
    }

在**线程执行函数**中，有一个执行20000次的for循环，里面每次使```count```自增前得到一个信号量，然后再令```count```自增，最后再释放信号量，这样保证了线程之间不会出现竞争条件冲突，```count```的自增操作有序进行，最后得到的也是正确结果800000。

当程序的编译命令没有参数或参数不是```syn```时，程序创建```MAX_N```即40个线程，每个线程的执行函数都为：

    void *test_func_asy(void *arg)
    {
        for (int i = 0; i < 20000; ++i) {
            count++;
        }

        pthread_exit(NULL);
    }

在**线程执行函数**中，有一个执行20000次的for循环，里面没有使用信号量而是直接让```count```进行自增，这样容易发生条件冲突，最后得到的结果也并不正确704064。

+ 验证实验**多生产者-多消费者问题**

执行程序命令：

    gcc alg.18-6-syn-pc-con-6.c -pthread
    gcc alg.18-7-syn-pc-producer-6.c -o alg.18-7-syn-pc-producer-6.o -pthread
    gcc alg.18-8-syn-pc-consumer-6.c -o alg.18-8-syn-pc-consumer-6.o -pthread
    ./a.out myshm
    4 8 2 3

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/8.png)

缓冲区大小为4，生产项目数量为8，生产者数目为2，消费者数量为3时，生产和消费的过程有序进行，直到8个项目被从循环队列中全部取出消费，程序结束。

实现细节解释：

在头文件**alg.18-6-syn-pc-con-6.h**中定义了必要的数据和结构：

```c
#define BASE_ADDR 10
/* 共享内存的前十个单位保留给控制结构体ctln_pc_st，数据从下标为10的单位开始
    循环数据队列由(enqueue | dequeue) % buffer_size + BASE_ADDR表示 */

struct ctln_pc_st
{
    int BUFFER_SIZE;  // 缓冲区大小，共享内存中数据单元的数目
    int MAX_ITEM_NUM; // 要生产的项目数目
    int THREAD_PRO;   // 生产者数目
    int THREAD_CONS;  // 消费者数目
    sem_t sem_mutex;  // 表示互斥信号量
    sem_t stock;      // 表示缓冲区中存储数量的信号量
    sem_t emptyslot;  // 表示缓冲区中空闲单元数目的信号量
    int item_num;     // 已经生产了的项目的总数目
    int consume_num;  // 已经消费了的项目的总数目
    int enqueue;      // 当前生产者在循环队列中的位置
    int dequeue;      // 当前消费者在循环队列中的位置
    int END_FLAG;     // 生产者生产完所有项目完成工作后，置为1，否则置为0，表示生产者还未完成完工作
}; /* 60 bytes */

struct data_pc_st
{
    int item_no;      // 生产项目时的项目序号
    int pro_no;       // 生产者序号
    long int pro_tid; // 生产该项目的生产者的线程号
}; /* 16 bytes */
```

首先，进程```syn-pc-con```会先创建一个共享内存区，然后使用```execv()```函数引发两个子进程，分别为```syn-pc-producer```生产者进程和```syn-pc-consumer```消费者进程，两个子进程异步执行，并将共享内存标识符作为参数传递给子进程，父进程等待子进程执行完后再接着执行，最后结束。

**alg.18-6-syn-pc-con-6.c：**

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/shm.h>
#include <semaphore.h>
#include <wait.h>
#include "alg.18-6-syn-pc-con-6.h"

int shmid;
void *shm = NULL;
int detachshm(void);

int main(int argc, char *argv[])
{
    pid_t childpid, pro_pid, cons_pid;
    struct stat statbuf;
    int buffer_size, max_item_num, thread_pro, thread_cons;
    
      // 需要在编译命令中提供共享对象的文件名或路径
    if (argc < 2) {
        printf("\nshared file object undeclared!\nUsage: syn-pc-con-6.o /home/myshm\n");
        return EXIT_FAILURE;
    }
      // 共享对象的文件应该要存在
    if (stat(argv[1], &statbuf) == -1) {
        perror("stat()");
        return EXIT_FAILURE;
    }
	
    while (1) {
          // 输入缓冲区大小
        printf("Pls input the buffer size(1-100, 0 quit): ");
        scanf("%d", &buffer_size);
        if (buffer_size <= 0) return 0;
        if (buffer_size > 100) continue;
          // 输入要生产的项目的最大个数
        printf("Pls input the max number of items to be produced(1-10000, 0 quit): ");
        scanf("%d", &max_item_num);
        if (max_item_num <= 0) return 0;
        if (max_item_num > 10000) continue;
          // 输入生产者的个数
        printf("Pls input the number of producers(1-500, 0 quit): ");
        scanf("%d", &thread_pro);
        if (thread_pro <= 0) return 0;
        if (thread_pro < 0) continue;
          // 输入消费者的个数
        printf("Pls input the number of consumers(1-500, 0 quit): ");
        scanf("%d", &thread_cons);
        if (thread_cons <= 0) return 0;
        if (thread_cons < 0) continue;
        break;
    }

    struct ctln_pc_st *ctln = NULL;
    struct data_pc_st *data = NULL;
    key_t key;
    int ret;

      // 获取IPC键值
    if ((key = ftok(argv[1], 0x28)) < 0) { 
        perror("ftok()");
        exit(EXIT_FAILURE);
    }
    
      // 获取共享内存标识符
    shmid = shmget((key_t)key, (buffer_size + BASE_ADDR)*sizeof(struct data_pc_st), 0666 | IPC_CREAT);
    if (shmid == -1) {
        perror("shmget()");
        exit(EXIT_FAILURE);
    }

      // 把共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存
    shm = shmat(shmid, 0, 0);
    if (shm == (void *)-1) {
        perror("shmat()");
        exit(EXIT_FAILURE);
    }

      // 设置共享内存，分别设置控制结构体ctln和数据结构体data
    ctln = (struct ctln_pc_st *)shm;
    data = (struct data_pc_st *)shm;

      // 初始化所有的控制参数，共享内存的前十个单位保留给控制参数，数据从下标为10的单位开始
    ctln->BUFFER_SIZE = buffer_size;
    ctln->MAX_ITEM_NUM = max_item_num;
    ctln->THREAD_PRO = thread_pro;
    ctln->THREAD_CONS = thread_cons; 
    ctln->item_num = 0;
    ctln->consume_num = 0;
      // 循环数据队列由(enqueue | dequeue) % buffer_size + BASE_ADDR表示
    ctln->enqueue = 0;
    ctln->dequeue = 0;
    ctln->END_FLAG = 0;

      // 初始化互斥信号量为1，对于进程间共享，sem_init()的第二个参数必须设置为非零
    ret = sem_init(&ctln->sem_mutex, 1, 1);
    if (ret == -1) {
        perror("sem_init-mutex");
        return detachshm();
    }
      // 将表示缓冲区存储数量的信号量ctln->stock初始化为0
    ret = sem_init(&ctln->stock, 1, 0);
    if (ret == -1) {
        perror("sem_init-stock");
        return detachshm();
    }
      // 将表示缓冲区中空闲单元数目的信号量ctln->emptyslot初始化为BUFFER_SIZE
    ret = sem_init(&ctln->emptyslot, 1, ctln->BUFFER_SIZE);
    if (ret == -1) {
        perror("sem_init-emptyslot");
        return detachshm();
    }

      // 打印进程进程号
    printf("\nsyn-pc-con console pid = %d\n", getpid());

     // 将共享内存标识符作为参数传递给生产者进程和消费者进程
    char *argv1[3];
    char execname[] = "./";
    char shmidstring[10];
    sprintf(shmidstring, "%d", shmid);
    argv1[0] = execname;
    argv1[1] = shmidstring;
    argv1[2] = NULL;
        
    childpid = vfork();
    if (childpid < 0) {
        perror("first fork");
        return detachshm();
    } 
    // 调用生产者进程
    else if (childpid == 0) {
        pro_pid = getpid();
        printf("producer pid = %d, shmid = %s\n", pro_pid, argv1[1]);
        execv("./alg.18-7-syn-pc-producer-6.o", argv1);
    }
    else {
        childpid = vfork();
        if (childpid < 0) {
            perror("second fork");
            return detachshm();
        } 
          // 调用消费者进程
        else if (childpid == 0) {
            cons_pid = getpid();
            printf("consumer pid = %d, shmid = %s\n", cons_pid, argv1[1]);
            execv("./alg.18-8-syn-pc-consumer-6.o", argv1);
        }
    }
      // 等待生产者进程和消费者进程结束后父进程再执行
    if (waitpid(pro_pid, 0, 0) != pro_pid)
        perror("wait pro");
    else
        printf("waiting pro_pid %d success.\n", pro_pid);

    if (waitpid(cons_pid, 0, 0) != cons_pid)
        perror("wait cons");
    else
        printf("waiting cons_pid %d success.\n", cons_pid);
        
      // 销毁互斥信号量ctln->sem_mutex
    ret = sem_destroy(&ctln->sem_mutex);
    if (ret == -1)
        perror("sem_destroy sem_mutex");

      // 销毁表示缓冲区存储数量的信号量ctln->sem_stock
    ret = sem_destroy(&ctln->stock);
    if (ret == -1)
        perror("sem_destroy stock");
    
      // 销毁表示缓冲区中空闲单元数目的信号量ctln->emptyslot
    ret = sem_destroy(&ctln->emptyslot);
    if (ret == -1)
        perror("sem_destroy empty_slot");

    return detachshm();
}

  // 断开进程与共享内存附加点的地址，释放共享内存区
int detachshm(void)
{
    if (shmdt(shm) == -1) {
        perror("shmdt()");
        exit(EXIT_FAILURE);
    }
    if (shmctl(shmid, IPC_RMID, 0) == -1) {
        perror("shmctl(IPC_RMID)");
        exit(EXIT_FAILURE);
    }
}
```

生产者进程```syn-pc-producer```会创建THREAD_PRO个生产者线程，异步进行生产。只有当已经生产的产品数量小于要生产的产品数量时，才会执行循环生产代码，生产的产品插入到循环队列中，当已经生产的产品数量等于要生产的产品数量时，完成工作，生产者的进程结束。

**alg.18-7-syn-pc-producer-6.c：**

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/shm.h>
#include <semaphore.h>
#include <unistd.h>
#include <sys/syscall.h>
#include "alg.18-6-syn-pc-con-6.h"

#define gettid() syscall(__NR_gettid)

void *producer(void *arg)
{
      // 获取共享内存结构体，分别为控制结构体和数据结构体
    struct ctln_pc_st *ctln = (struct ctln_pc_st *)arg;
    struct data_pc_st *data = (struct data_pc_st *)arg;
      // 当生产者已经制造的项目数量小于要生产的项目时
    while (ctln->item_num < ctln->MAX_ITEM_NUM) {
          // 等待缓冲区空闲单元数目信号量大于0，表示有空闲单元可以生产后存放项目，然后将空闲单元数目信号量减一，继续执行
        sem_wait(&ctln->emptyslot);
          // 等待互斥信号量大于0，防止临界冲突，然后将互斥锁信号量减一，继续执行
        sem_wait(&ctln->sem_mutex);

          // 当生产者已经制造的项目数量小于要生产的项目时
        if (ctln->item_num < ctln->MAX_ITEM_NUM) {
              // 生产者已经制造的项目数量加一，并将制造的项目设置好项目序列号和制造该项目的线程号后，放入循环队列
            ctln->item_num++;	
            ctln->enqueue = (ctln->enqueue + 1) % ctln->BUFFER_SIZE;
            (data + ctln->enqueue + BASE_ADDR)->item_no = ctln->item_num;
            (data + ctln->enqueue + BASE_ADDR)->pro_tid = gettid();
            printf("producer tid %ld prepared item no %d, now enqueue = %d\n", (data + ctln->enqueue + BASE_ADDR)->pro_tid, (data + ctln->enqueue + BASE_ADDR)->item_no, ctln->enqueue);
              // 当生产者已经制造的项目数量等于要生产的项目时，说明完成工作，设置ctln->END_FLAG为1
            if (ctln->item_num == ctln->MAX_ITEM_NUM)
                ctln->END_FLAG = 1;
              // 将表示缓冲区中存储数量的信号量加一，继续执行
            sem_post(&ctln->stock);
        } 
          // 当生产者已经制造的项目数量不小于要生产的项目时，将表示缓冲区空闲单元数目的信号量加一
        else {
            sem_post(&ctln->emptyslot);
        }
          // 然后将互斥锁信号量加一，允许其它线程执行
        sem_post(&ctln->sem_mutex);
        sleep(1);
    }
    pthread_exit(0);
}

int main(int argc, char *argv[])
{
    struct ctln_pc_st *ctln = NULL;
    struct data_pc_st *data = NULL;

    int shmid;
    void *shm = NULL;
      // 获取共享内存标识符
    shmid = strtol(argv[1], NULL, 10);
      // 把共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存
    shm = shmat(shmid, 0, 0);
    if (shm == (void *)-1) {
        perror("\nproducer shmat()");
        exit(EXIT_FAILURE);
    }

      // 获取共享内存结构体，分别为控制结构体ctln和数据结构体data
    ctln = (struct ctln_pc_st *)shm;
    data = (struct data_pc_st *)shm;

    pthread_t ptid[ctln->THREAD_PRO];
    int i, ret;
      // 创建ctln->THREAD_PRO个生产者线程
    for (i = 0; i < ctln->THREAD_PRO; ++i) {
          // 线程执行函数为producer
        ret = pthread_create(&ptid[i], NULL, &producer, shm);
        if (ret != 0) {
            perror("producer pthread_create()");
            break;
        }
    }    

      // 主线程等待子线程都执行完后再继续执行
    for (i = 0; i < ctln->THREAD_PRO; ++i) {
        pthread_join(ptid[i], NULL);
    }

      // 所有生产者都停止工作，以防止有些消费者会拿走最后的项目，不超过THREAD_CON-1个消费者会停留在sem_wait(&stock)的等待队列中
    for (i = 0; i < ctln->THREAD_CONS - 1; ++i)
        sem_post(&ctln->stock);

      // 断开进程与共享内存附加点的地址
    if (shmdt(shm) == -1) {
        perror("producer shmdt()");
        exit(EXIT_FAILURE);
    }
    return 0;
}
```

消费者进程```syn-pc-consumer```会创建THREAD_CONS个消费者线程，异步进行消费。只有当当消费者已经消费的项目数量小于生产者已经生产的项目数量，或生产者还没完成工作时，才会执行循环消费代码，消费的产品从循环队列中取出。

**alg.18-8-syn-pc-consumer-6.c：**

```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/shm.h>
#include <semaphore.h>
#include <unistd.h>
#include <sys/syscall.h>
#include "alg.18-6-syn-pc-con-6.h"

#define gettid() syscall(__NR_gettid)

void *consumer(void *arg)
{
      // 获取共享内存结构体，分别为控制结构体和数据结构体
    struct ctln_pc_st *ctln = (struct ctln_pc_st *)arg;
    struct data_pc_st *data = (struct data_pc_st *)arg;

      // 当消费者已经消费的项目数量小于生产者已经生产的项目数量，或生产者还没完成工作时
    while ((ctln->consume_num < ctln->item_num) || (ctln->END_FLAG == 0))  { 
          // 等待表示缓冲区中存储数量的信号量大于0，表示缓冲区中有项目可以消费，然后将存储数量信号量减一，继续执行。如果存储数量是空的，且所有的生产者都停止工作，那么一个或多个消费者可能会永远等待
        sem_wait(&ctln->stock);
          // 等待互斥信号量大于0，防止临界冲突，然后将互斥锁信号量减一，继续执行
        sem_wait(&ctln->sem_mutex);
          // 当消费者已经消费的项目数量小于生产者已经生产的项目数量
        if (ctln->consume_num < ctln->item_num) { 
              // 从循环队列中取出项目消费，打印取出项目的相关信息
            ctln->dequeue = (ctln->dequeue + 1) % ctln->BUFFER_SIZE;
            printf("\t\t\t\tconsumer tid %ld taken item no %d by pro %ld, now dequeue = %d\n", gettid(), (data + ctln->dequeue + BASE_ADDR)->item_no, (data + ctln->dequeue + BASE_ADDR)->pro_tid, ctln->dequeue);
            ctln->consume_num++;
              // 将表示缓冲区空闲单元数目的信号量加一，继续执行
            sem_post(&ctln->emptyslot);
        }
          // 当消费者已经消费的项目数量不小于生产者已经生产的项目数量，将表示缓冲区中存储数量的信号量加一
        else {
            sem_post(&ctln->stock);
        }
          // 然后将互斥锁信号量加一，允许其它线程执行
        sem_post(&ctln->sem_mutex);
    }
    pthread_exit(0);
}

int main(int argc, char *argv[])
{
    struct ctln_pc_st *ctln = NULL;
    struct data_pc_st *data = NULL;

    int shmid;
    void *shm = NULL;
      // 获取共享内存标识符
    shmid = strtol(argv[1], NULL, 10);
      // 把共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存
    shm = shmat(shmid, 0, 0);
    if (shm == (void *)-1) {
        perror("consumer shmat()");
        exit(EXIT_FAILURE);
    }

      // 获取共享内存结构体，分别为控制结构体ctln和数据结构体data
    ctln = (struct ctln_pc_st *)shm;
    data = (struct data_pc_st *)shm;

    pthread_t ptid[ctln->THREAD_CONS];
    int i, ret;
      // 创建ctln->THREAD_CONS个消费者线程
    for (i = 0; i < ctln->THREAD_CONS; ++i) {
          // 线程执行函数为consumer
        ret = pthread_create(&ptid[i], NULL, &consumer, shm); 
        if (ret != 0) {
            perror("consumer pthread_create()");
            break;
        }
    } 

      // 主线程等待子线程都执行完后再继续执行
    for (i = 0; i < ctln->THREAD_CONS; ++i)
        pthread_join(ptid[i], NULL);

      // 断开进程与共享内存附加点的地址
    if (shmdt(shm) == -1) {
        perror("consumer shmdt()");
        exit(EXIT_FAILURE);
    }  
    return 0;
}
```

#### POSIX条件变量

+ Pthreads中的条件变量的行为类似于监视器上下文中使用的条件变量，后者提供了一种锁定机制来确保数据完整性。
+ Pthreads通常用于C程序中。由于C语言没有监视器，互斥锁与条件变量相关联以完成锁定。
+ Pthreads中的条件变量使用```pthread_cond_t```数据类型，并由```pthread_cond_init()```初始化。以下代码创建并初始化条件变量及其关联的互斥锁：
    ```c
    pthread_mutex_t mutex;
    pthread_cond_t cond_var;

    pthread_mutex_init(&mutex, NULL);
    pthread_cond_init(&cond_var, NULL);
    ```
+ 例子：
    + 线程可以使用Pthread条件变量等待条件子句(a == b)变为true：
        ```c
        pthread_mutex_lock(&mutex);
        while (a != b)
            pthread_cond_wait(&cond_var, &mutex);
        临界区
        pthread_mutex_unlock(&mutex);
        ```

+ 在调用```pthread_cond_wait()```函数之前，必须锁定与```cond_var```关联的互斥锁，因为它用于保护条件子句中的数据不受可能的竞争条件的影响。
+ ```pthread_cond_wait()```函数用于等待条件变量。
+ 一旦获得了这个锁，线程就会检查条件并调用```pthread_cond_wait()```，当(a != b)时，将互斥锁和```cond_var```作为参数传递，条件不正确。
+ pthread_cond_wait()将调用线程放在条件等待队列的末尾，释放互斥锁以允许另一个线程访问共享数据，并可能更新其值，以便条件子句(a == b)的判断结果为true。当调用线程被激活时，它将锁定互斥锁并再次检查条件。
    + 这一点很重要，因为当条件子句为true时，条件等待队列中调用线程之前的另一个线程可能会被调度。
+ 例子：
    + 线程可以调用```pthread_cond_signal()```函数，从而发出一个线程在等待条件变量的信号。
        ```c
        pthread_mutex_lock(&mutex);
        if (a == b)
            pthread_cond_signal(&cond_var);
        pthread_mutex_unlock(&mutex);
        ```
+ 需要注意的是：
    + ```pthread_cond_signal()```不会释放互斥锁。
    + ```pthread_mutex_unlock()```释放互斥锁。
    + 一旦释放互斥锁，发出信号的线程就成为互斥锁的所有者，并从```pthread_cond_wait()```调用返回控制。


+ 验证实验**alg.18-9-pthread-cond-wait.c**

执行程序命令：

    gcc alg.18-9-pthread-cond-wait.c -pthread
    ./a.out syn

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/9.png)

可以看到，变量```count```的自增和自减有序进行，没有发生竞争条件导致```count```的值错乱的情况。

实现细节解释：

首先在全局中，将```pthread_mutex_t```互斥锁标识符类型变量```mutex```使用宏定义```PTHREAD_MUTEX_INITIALIZER```进行静态初始化，将```pthread_cond_t```条件变量类型变量```cond```使用宏定义```PTHREAD_COND_INITIALIZER```进行初始化，

主函数最后会等待创建的线程都执行完后再继续进行，然后使用```pthread_mutex_destroy(&mutex)```语句销毁互斥锁，使用语句```pthread_cond_destroy(&cond)```销毁条件变量，结束程序。

主函数中会创建两个线程，两个线程异步执行，其中一个线程的执行函数为：

    void *decrement(void *arg)
    {  
        for (int i = 0; i < 4; i++) {
            pthread_mutex_lock(&mutex);  
            while (count <= 0)  /* wait until count > 0 */
                pthread_cond_wait(&cond, &mutex);  
            count--;  
            printf("\t\t\t\tcount = %d.\n", count);  
            printf("\t\t\t\tUnlock decrement.\n");  
            pthread_mutex_unlock(&mutex);  
        }
        return NULL;
    }  

在**线程执行函数**中，有一个执行4次的for循环，里面每次循环首先获取一个互斥锁，以防止多个线程同时请求```pthread_cond_wait()```的竞争条件，当变量```count```小于等于0时，```pthread_cond_wait()```会先解除互斥锁，然后在等待队列中休眠，直到变量```count```大于0且等待条件成立被唤醒后才继续执行，先锁定互斥锁，然后```count```自减，打印此时```count```的值并释放互斥锁。

另一个线程的执行函数为：
  
    void *increment(void *arg) 
    {
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 10000; j++) ; /* sleep for a while */
            pthread_mutex_lock(&mutex);  
            count++;  
            printf("count = %d.\n", count);
            if (count > 0)  
                pthread_cond_signal(&cond);  
            printf("Unlock increment.\n");  
            pthread_mutex_unlock(&mutex);  
        }
        return NULL;
    }  

在**线程执行函数**中，有一个执行4次的for循环，里面每次循环首先利用for循环等待一段时间，然后获取一个互斥锁，接着使```count```自增，如果此时```count```大于0时，使用语句```pthread_cond_signal(&cond)```激活一个正在等待该条件的线程，最后释放互斥锁。

### 内容2：在 Lab Week 13 的基础上用信号量解决线程池分配的互斥问题。

#### 设计报告

##### 线程池设计图

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/1.png)

##### 代码设计

测试代码：

```c
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
#include <sys/time.h>
#include <sys/msg.h>
#include <sys/syscall.h>
#include <semaphore.h>
#include <fcntl.h>
#include <unistd.h>

#define gettid() syscall(__NR_gettid)
  /* wrap the system call syscall(__NR_gettid), __NR_gettid = 224 */
#define gettidv2() syscall(SYS_gettid) /* a traditional wrapper */

#define THREADS_NUM 10 // 线程池中的线程个数
#define TASK_QUEUE_MAX_SIZE 12 // 任务的等待队列的最大长度，等待队列中的最大任务个数为长度减一
#define TASK_NUM 100 // 要执行的任务总数

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
    sem_t sem_mutex; // 互斥信号量
} Threadpools;

// 线程池中每个线程执行的任务
static void *executeTask(void *arg) {
    // 向每个线程传入的参数是线程池
    Threadpools *pools = (Threadpools *)arg;
    while (1) {
        // 等待互斥信号量大于0，防止临界冲突，然后将互斥锁信号量减一，继续执行
        sem_wait(&pools->sem_mutex);
        // 当任务队列为空时
        while (pools->taskQueue.front == pools->taskQueue.rear) {
            // 如果已经没有剩余任务要处理，那么退出线程
            if (pools->taskSum == 0) {
                printf("Thread %ld exits.\n", gettid());
                sem_post(&pools->sem_mutex);
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

        // 将互斥锁信号量加一，允许其它线程执行
        sem_post(&pools->sem_mutex);
        
        // 执行任务
        (*(task.function))(task.arg);
    }
}

// 初始化线程池
void initThreadpools(Threadpools *pools) {
    int ret;
    // 任务队列的队首和队尾的坐标都为0
    pools->taskQueue.front = 0;
    pools->taskQueue.rear = 0;
    // 线程池中剩余的任务总数设置为总任务数
    pools->taskSum = TASK_NUM;

    // 初始化互斥信号量为1
    ret = sem_init(&pools->sem_mutex, 1, 1);
    if (ret == -1) {
        perror("sem_init-mutex");
        exit(1);
    }

    // 创建线程池中的线程
    for(int i = 0; i < THREADS_NUM; ++i) {
        ret = pthread_create(&pools->threads[i], NULL, executeTask, (void *)pools);
        if(ret != 0) {
            fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
            exit(1);
        }
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
void *taskFunction(void *arg) {
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
    return 0;
}

int main() {
    int ret;
    // 创建并初始化线程池
    Threadpools pools;
    initThreadpools(&pools);

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
        ret = pthread_join(pools.threads[i], NULL);
        if(ret != 0) {
            fprintf(stderr, "pthread_join error: %s\n", strerror(ret));
            exit(1);
        }
    }

    // 所有任务都执行完，线程池也退出
    printf("\nAll %d tasks have been finished.\n", TASK_NUM);

    // 销毁互斥信号量
    ret = sem_destroy(&pools.sem_mutex);
    if (ret == -1) {
        perror("sem_destroy sem_mutex");
    }
}
```

**首先进行宏定义：**

    #define THREADS_NUM 10 // 线程池中的线程个数
    #define TASK_QUEUE_MAX_SIZE 12 // 任务的等待队列的最大长度，等待队列中的最大任务个数为长度减一
    #define TASK_NUM 100 // 要执行的任务总数

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
        sem_t sem_mutex; // 互斥信号量
    } Threadpools;

**线程池初始化函数：**

    // 初始化线程池
    void initThreadpools(Threadpools *pools) {
        int ret;
        // 任务队列的队首和队尾的坐标都为0
        pools->taskQueue.front = 0;
        pools->taskQueue.rear = 0;
        // 线程池中剩余的任务总数设置为总任务数
        pools->taskSum = TASK_NUM;

        // 初始化互斥信号量为1
        ret = sem_init(&pools->sem_mutex, 1, 1);
        if (ret == -1) {
            perror("sem_init-mutex");
            exit(1);
        }

        // 创建线程池中的线程
        for(int i = 0; i < THREADS_NUM; ++i) {
            ret = pthread_create(&pools->threads[i], NULL, executeTask, (void *)pools);
            if(ret != 0) {
                fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
                exit(1);
            }
        }
    }

创建线程池中的线程时，可以看到每个线程执行的函数都为```executeTask()```任务执行函数。

对应设计图中的初始化线程池部分：

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/2.png)

**接着实现函数部分：**

**线程执行函数：**

    // 线程池中每个线程执行的任务
    static void *executeTask(void *arg) {
        // 向每个线程传入的参数是线程池
        Threadpools *pools = (Threadpools *)arg;
        while (1) {
            // 等待互斥信号量大于0，防止临界冲突，然后将互斥锁信号量减一，继续执行
            sem_wait(&pools->sem_mutex);
            // 当任务队列为空时
            while (pools->taskQueue.front == pools->taskQueue.rear) {
                // 如果已经没有剩余任务要处理，那么退出线程
                if (pools->taskSum == 0) {
                    printf("Thread %ld exits.\n", gettid());
                    sem_post(&pools->sem_mutex);
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
            // 将互斥锁信号量加一，允许其它线程执行
            sem_post(&pools->sem_mutex);
            
            // 执行任务
            (*(task.function))(task.arg);
        }
    }

当线程从任务队列中获取任务执行时，有可能发生条件竞争，多个线程同时取同一个任务进行执行，所以要在线程执行函数处用信号量避免这种冲突，使线程取任务执行有序进行。

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
    void *taskFunction(void *arg) {
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
        return 0;
    }

对应设计图中的每个任务执行的内容部分：

![](http://stugeek.gitee.io/operating-system/Labwork13-pictures/5.png)

**主函数中：**

    int main() {
        int ret;
        // 创建并初始化线程池
        Threadpools pools;
        initThreadpools(&pools);

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
            ret = pthread_join(pools.threads[i], NULL);
            if(ret != 0) {
                fprintf(stderr, "pthread_join error: %s\n", strerror(ret));
                exit(1);
            }
        }

        // 所有任务都执行完，线程池也退出
        printf("\nAll %d tasks have been finished.\n", TASK_NUM);

        // 销毁互斥信号量
        ret = sem_destroy(&pools.sem_mutex);
        if (ret == -1) {
            perror("sem_destroy sem_mutex");
        }
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

#### 测试用例：

在宏定义处，改变线程池中的线程个数，任务队列的最大长度和要执行的认为总数，可以进行测试程序：

**测试用例1：**

线程个数为10，任务队列最大长度为12（最大任务个数为11），任务总数为50：

    #define THREADS_NUM 10 // 线程池中的线程个数
    #define TASK_QUEUE_MAX_SIZE 12 // 任务的等待队列的最大长度，等待队列中的最大任务个数为长度减一
    #define TASK_NUM 50 // 要执行的任务总数

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/10.png)

任务总数稍大于线程个数和任务队列长度时，可以看到，线程池可以正常运行。

**测试用例2：**

线程个数为10，任务队列最大长度为12（最大任务个数为11），任务总数为5：

    #define THREADS_NUM 10 // 线程池中的线程个数
    #define TASK_QUEUE_MAX_SIZE 12 // 任务的等待队列的最大长度，等待队列中的最大任务个数为长度减一
    #define TASK_NUM 5 // 要执行的任务总数

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/11.png)

任务总数小于线程个数和任务队列长度时，可以看到，线程池可以正常运行。

**测试用例3：**

线程个数为10，任务队列最大长度为12（最大任务个数为11），任务总数为10000：

    #define THREADS_NUM 10 // 线程池中的线程个数
    #define TASK_QUEUE_MAX_SIZE 12 // 任务的等待队列的最大长度，等待队列中的最大任务个数为长度减一
    #define TASK_NUM 10000 // 要执行的任务总数

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/12.png)

相比之前一个测试样例，这个样例的线程个数较大，线程池可以正常运行，同时因为同时运行的线程较多，所以运行速度相比之前一个样例快了很多。

**测试用例4：**

线程个数为500，任务队列最大长度为500（最大任务个数为499），任务总数为10000：

    #define THREADS_NUM 500 // 线程池中的线程个数
    #define TASK_QUEUE_MAX_SIZE 500 // 任务的等待队列的最大长度，等待队列中的最大任务个数为长度减一
    #define TASK_NUM 10000 // 要执行的任务总数

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/13.png)

可以看到，当线程个数较多时，线程池可以正常运行，由于使用了信号量，所以多个线程在获取任务时不会发生条件竞争，导致冲突

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/14.png)

使用之前没有用信号量的程序进行运行相同参数的程序时，可以看到，由于发生条件竞争，出现了无限阻塞现象，线程之间获取任务时有冲突。

**测试用例5：**

线程个数为3000，任务队列最大长度为4000（最大任务个数为3999），任务总数为500000：

    #define THREADS_NUM 3000 // 线程池中的线程个数
    #define TASK_QUEUE_MAX_SIZE 4000 // 任务的等待队列的最大长度，等待队列中的最大任务个数为长度减一
    #define TASK_NUM 500000 // 要执行的任务总数

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/15.png)

进行多线程高并发测试，可以看到，线程池可以正常运行。
