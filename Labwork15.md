# 操作系统实验报告15

## 实验内容

+ 实验内容：线程（2）。
    + 编译运行课件 Lecture14 例程代码：
        + Algorithms 14-1 ~ 14-7. 
    + 比较 pthread 和 clone() 线程实现机制的异同
    + 对 clone() 的 flags 采用不同的配置，设计测试程序讨论其结果
      + 配置包括 COLNE_PARENT, CLONE_VM, CLONE_VFORK, CLONE_FILES, CLONE_SIGHAND, CLONE_NEWIPC, CLONE_THREAD

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### 编译运行课件 Lecture18 例程代码

#### Thread Local Storage 线程局部存储（TLS）

实验内容原理：

+ 线程本地存储（TLS）允许每个线程拥有自己的数据副本。
+ 当我们无法控制线程创建过程时，TLS很有用。
    + 我们不能向创建的线程传递任何参数。
    + 例如，使用线程池时。
+ TLS不同于局部变量。
    + 局部变量仅在单个函数调用期间可见。
    + TLS在函数调用中是可见的。
+ 与静态数据类似：
    + TLS对每个线程都是唯一的。
+ TLS的实施
    + __thread int tlsvar；//每个线程都有一个变量tlsvar；由语言编译器解释，是TLS的语言级解决方案
    + 通过pthread_key_create()函数

其中实验中用到的函数有：

    int pthread_key_create(pthread_key_t *key, void (*destructor)(void*));

```pthread_key_create```函数用来创建线程私有数据，从TSD池中分配一个值赋给```key```以后使用。

第一个参数为一个```pthread_key_t *```类型的指针，```pthread_key_t```是宏定义```typedef unsigned int pthread_key_t```，参数指向一个这个类型的变量。

第二个参数指向一个destructor即清理函数，如果这个参数为NULL，那么系统会自动调用默认的清理函数，释放第一个参数```key```指向的内存块，否则使用指定的清理函数释放内存块。

创建了```key```后，所有线程都可以访问这个值，但是每个线程可以使用不同的值，相当于一个同名但不同值的全局变量。

    int pthread_setspecific(pthread_key_t key, const void *value);

```pthread_setspecific()```函数用来给指定的线程特定的数据键值设置属于这个线程的特定键值，第一个参数```key```代表要设定的数据键值，第二个参数```value```指向设置给```key```的特定键值。

    void *pthread_getspecific(pthread_key_t key);

```pthread_getspecific()```函数用来获取指定线程的特定键值，其中参数```key```代表要获得的特定键值，返回一个指向这个键值的指针。

    int pthread_key_delete(pthread_key_t key);

```pthread_key_delete()```函数用来销毁线程特定数据键值，释放与该键值相关的所有内存，其中参数```key```代表要销毁的特定数据键值。

+ 验证实验**alg.18-1-syn-fetch-1.c**

执行程序命令：

    gcc alg.18-1-syn-fetch-1.c
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/1.png)

实现细节解释：

一开始先让变量i等于10，然后在同一条打印语句中打印函数```__sync_fetch_and_add(&i, 20)```的值和i的值，```__sync_fetch_and_add(&i, 20)```是无锁化原子操作语句，实现的是先取值再加第二个参数即20的操作，所以语句执行后获取到的值还是原来i的值，即是10，而在同一条打印语句中的i的值与函数```__sync_fetch_and_add(&i, 20)```无关，所以i的值还是10，下一条语句还是打印i的值，此时已经执行完函数```__sync_fetch_and_add(&i, 20)```，所以可以看到此时i的值为30。

接着继续让变量i等于10，然后在同一条打印语句中打印函数```__sync_add_and_fetch(&i, 20)```的值和i的值，```__sync_add_and_fetch(&i, 20)```是无锁化原子操作语句，实现的是先加第二个参数即20再取值的操作，所以语句执行后获取到的值还是加上20后i的值，即是30，而在同一条打印语句中的i的值与函数```__sync_add_and_fetch(&i, 20)```无关，所以i的值还是10，下一条语句还是打印i的值，此时已经执行完函数```__sync_add_and_fetch(&i, 20)```，所以可以看到此时i的值为30。

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

可以看到，每个线程在加1的时候，因为使用的是```count++```语句，所以产生了条件冲突而产生错误的值，值不为40*20000=800000，而是694845， 计算结果错误。

实现细节解释：

和之前一个程序相比，这个程序在线程执行函数中使用的是```count++```语句使全局静态变量```count```加1加20000次，这样各个线程会很容易发生条件冲突，最后产生的是一个错的结果。

+ 验证实验**alg.18-2-syn-compare-test.c**

执行程序命令：

    gcc alg.18-2-syn-compare-test.c
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/4.png)

相比之前一个程序```alg.14-3-tls-pthread-key-2```，这个程序的两个线程没有分别调用```print_msg1()```和```print_msg2()```函数，而是调用了同一个```print_msg()```函数，可以看到，两个线程的```print_msg()```函数打印出线程号和```ptr```首地址不同，说明同一个```print_msg()```函数分别有两个线程各自```ptr```变量的数据副本。

实现细节解释：

与之前一个程序```alg.14-3-tls-pthread-key-2```相比，这个程序的第二个线程运行函数```thread_func2()```的```ptr```由之前的动态内存分配处于堆区变成了临时数组变量处于栈区，两个线程也没有分别调用```print_msg1()```和```print_msg2()```函数，而是调用了同一个```print_msg()```函数，这个```print_msg()```和之前```print_msg1()```函数与```print_msg2()```函数的作用基本相同。

+ 验证实验**alg.18-3-syn-pthread-mutex.c**

执行程序命令：

    gcc alg.18-3-syn-pthread-mutex.c -pthread
    ./a.out
    ./a.out syn

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/5.png)

可以看到，无论与线程私有变量绑定的变量是否有效，数据是否丢失，线程私有变量都可以继续工作。

可以看到，在创建的子线程中调用的函数中将线程栈区的临时变量与线程私有变量绑定时，函数返回时栈区会被释放，在子进程中想打印与线程私有变量绑定的栈区变量时数据会发生丢失，产生乱码，因为栈区数据已经释放掉了。

而在创建的子线程中调用的函数中将线程堆区的动态内存分配的变量与线程私有变量绑定时，函数返回时堆区数据如果不调用```free()```函数则不会被释放，在子进程中想打印与线程私有变量绑定的堆区变量时数据不会丢失，可以正常打印，这也提醒我们如果不及时释放内存会导致内存泄露。

实现细节解释：

与之前的程序```alg.14-3-tls-pthread-key-2```相比，这个程序的主线程中只创建了一个子线程，**线程函数为**：

    static void *thread_func(void *args)
    {
        struct msg_struct *ptr;

        thread_data1();
        ptr = (struct msg_struct *)pthread_getspecific(tls_key); /* get ptr from thread_data1() */
        perror("pthread_getspecific()");
        printf("ptr from thread_data1() in thread_func(): %p\n", ptr);
        for (int i = 1; i < 6; i++) {
            printf("tid = %ld  i = %2d   %s  %*.*s\n", gettid(), i, (ptr+i-1)->stuno, 8, 8, (ptr+i-1)->stuname);
        }

        thread_data2();
        ptr = (struct msg_struct *)pthread_getspecific(tls_key); /* get ptr from thread_data2() */
        perror("pthread_getspecific()");
        printf("ptr from thread_data2() in thread_func(): %p\n", ptr);
        for (int i = 1; i < 6; i++) {
            printf("tid = %ld  i = %2d   %s  %*.*s\n", gettid(), i, (ptr+i-1)->stuno, 8, 8, (ptr+i-1)->stuname);
        }

        free(ptr);
        ptr = NULL;

        pthread_exit(0);
    }

在这个线程函数中，和之前的程序在创建的子线程中设置线程私有变量```tls_key```的值不同，这个程序在创建的子线程中调用函数在这个函数中设置线程私有变量```tls_key```的值。

首先程序运行了相当于```alg.14-3```中的```thread_func1()```函数作用的```thread_data1()```函数，在函数中将栈区的临时数组变量```ptr```和线程私有变量```tls_key```绑定，但是由于线程栈区在函数返回时会被释放，所以回到子线程中运行和之前```print_msg1()```函数作用相同的代码块时，会发现和线程私有变量```tls_key```绑定的```ptr```发生了丢失，产生许多乱码，因为```ptr```已经被释放掉了。

运行了相当于```alg.14-3```中的```thread_func2()```函数作用的```thread_data2()```函数，在函数中将堆区的动态内存分配的指针变量```ptr```和线程私有变量```tls_key```绑定，但是由于线程堆区的变量在函数返回时如果没有调用```free()```函数就不会被释放，所以回到子线程中运行和之前```print_msg2()```函数作用相同的代码块时，会发现和线程私有变量```tls_key```绑定的```ptr```没有丢失，可以正常打印数据。

#### Linux clone()

+ Linux提供fork()和vfork()系统调用，具有复制进程的传统功能。Linux还提供了使用clone()系统调用创建线程的能力。
    + 事实上，Linux在提到程序中的控制流时使用的是术语“任务”，而不是“进程”或“线程”。它不区分进程和线程。
    + 带有一组标志的clone()允许子任务共享父任务的一些资源。这些标志确定父任务和子任务之间要进行多少共享。
    + 如果在调用clone()时没有设置这些标志，则不会发生共享，这类似于fork()系统调用提供的共享。

        |标志| 含义|
        |----|--------|
        |CLONE_FS| 共享文件系统信息|
        |CLONE_VM| 共享相同的内存空间|
        |CLONE_SIGHAND| 共享信号处理程序|
        |CLONE_FILES| 共享一组打开的文件|

```
int clone(int (*fn)(void *), void *child_stack, int flags, void *arg);
```
clone()函数可以用来创建线程，其中第一个参数```fn```是函数指针，指向线程要执行的函数，第二个参数```child_stack```是为子线程分配的系统堆栈空间，指定子线程使用的堆栈的位置，第三个参数```flags```为复制资源的标志，用来表示子线程需要继承哪些资源，第四个参数```arg```是传给子进程的参数。

+ 验证实验**alg.18-4-syn-pthread-sem-unnamed.c**

执行程序命令：

    gcc alg.18-4-syn-pthread-sem-unnamed.c -pthread
    ./a.out syn
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/6.png)

可以看到，最后```parent read buf```中```buf```中的内容没有被子线程改变，说明每一个线程或进程（任务）都有它的不同内存空间。

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/9.jpg)

主线程等待它创建的任意一个子线程执行结束后再和另外一个子线程异步执行，因为只有一个子线程返回主线程就继续执行然后结束了，所以可以看到线程号为40706的子线程成为了僵尸线程。

若编译指令：

    ./a.out vm

那么```flag```选项设置```CLONE_VM```，父进程和子进程运行时会共享相同的内存空间。

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/10.png)

可以看到，最后```parent read buf```中```buf```中的内容被子线程改变，说明每个线程或进程（任务）共享相同的内存空间。

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/11.png)

主线程先等待和它创建的任意一个子线程结束，然后跟另一个子线程异步执行。

若编译指令：

    ./a.out vm vfork

那么```flag```选项设置```CLONE_VFORK```，那么父进程会被挂起，直到子进程释放虚拟内存资源才继续运行。

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/12.png)

可以看到，主线程被挂起，直到子线程结束后再继续执行。

实现细节解释：

一开始动态内存申请两个大小为```STACK_SIZE```的```char```类型指针```stack1```和```stack2```，初始化标志变量```flag```为0，如果传入的第一个参数为```vm```，那么设置```flag```为```flags | CLONE_VM```，代表可以父进程和子进程运行时共享相同的内存空间，如果传入的第二个参数为```vfork```，那么设置```flag```为```flags | CLONE_VFORK```，代表运行时父进程被挂起，直到子进程释放虚拟内存资源。

然后打印父进程的进程号和语句```parrent clone ...```，表示准备要使用```clone()```函数了。接着使用语句```clone(child_func1, stack1 + STACK_SIZE, flags | SIGCHLD, buf)```创建一个子线程并把返回值即创建的线程的线程号赋给变量```chdtid1```，其中第一个参数```child_func1```是线程执行函数，第二个参数```stack1 + STACK_SIZE```是子线程使用的系统堆栈的栈顶位置，第三个参数```flags | SIGCHLD```代表设置子线程从主线程继承的资源，同时```SIGCHLD```代表在子线程终止时，向主线程发送信号，第四个参数```buf```是向子线程传送的参数。这里是说明主线程的线程号的一条语句。

**在线程运行函数```child_func1()```中：**

    static int child_func1(void *arg)
    {
        char *chdbuf = (char*)arg; /* type casting */
        printf("child_func1 read buf: %s\n", chdbuf);
        sleep(1);
        sprintf(chdbuf, "I am child_func1, my tid = %ld, pid = %d", gettid(), getpid());
        printf("child_func1 set buf: %s\n", chdbuf);
        sleep(1);
        printf("child_func1 sleeping and then exists ...\n");
        sleep(1);

        return 0;
    }

首先打印传递进的字符串的参数的内容，接着休眠1s，打印子线程的线程号和进程号，然后休眠1s，打印语句```child_func1 sleeping and then exists ...```，然后结束。

**回到主线程中，** 然后使用语句```clone(child_func2, stack2 + STACK_SIZE, flags | SIGCHLD, buf)```创建一个子线程并把返回值即创建的线程的线程号赋给变量```chdtid2```，线程执行函数```child_func2()```和之前的```child_func1()```的作用差不多。

接着使用```waitpid(-1, &status, 0) == -1```让主线程等待任意一个子线程结束后再继续执行，参数```-1```表示不等待某个特定的子进程而是回收任意一个子进程，参数```0```表示以默认的阻塞方式来进行等待任意一个子线程结束然后继续执行。

休眠1s，打印父进程的进程号，系统调用语句```ps```显示当前进程状态。

+ 验证实验**alg.18-5-syn-pthread-sem-named.c**

执行程序命令：

    gcc alg.18-5-syn-pthread-sem-named.c -pthread
    ./a.out syn
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/7.png)

可以看到，在实验环境下使用clone()函数创建出的子线程递归调用可以使用栈空间的上限递归次数为732605，514288 *4096-1936125 *1024 = 123931648‬，123931648‬/1936125 = 64(字节), 说明每次递归的实验环境系统开销大概是64字节。

实现细节解释：

一开始动态内存申请一个大小为```STACK_SIZE```的```char```类型指针```stack```，初始化标志变量```flag```为0。

接着使用语句```clone(test, stack + STACK_SIZE, flags | SIGCHLD, buf)```创建一个子线程并把返回值即创建的线程的线程号赋给变量```chdtid```，**在线程运行函数```test()```中：**

    static int test(void *arg)
    { 
        static int i = 0;
        char buffer[1024]; 
        if(i == 0) {
            printf("test: my ptd = %d, tid = %ld, ppid = %d\n", getpid(), gettid(), getppid());
            printf("\niteration = %8d", i); 
        }
        printf("\b\b\b\b\b\b\b\b%8d", i); 
        i++; 
        test(arg); /* recursive calling */
    } 

首先初始化静态变量i为0，然后如果i为0，那么打印子线程的进程号、线程号、父进程号和迭代次数即i的值，退出判断语句，打印i的值，使i自增，最后使用```test(arg)```语句递归调用```test()```函数。

打印传递进的字符串的参数的内容，接着休眠1s，打印子线程的线程号和进程号，然后休眠1s，打印语句```child_func1 sleeping and then exists ...```，然后结束。

**回到主线程中，** 打印父进程的进程号和子线程的线程号，接着使用```waitpid(-1, &status, 0) == -1```让主线程等待任意一个子线程结束后再继续执行，并把返回的子线程的线程号赋给变量```ret```。

休眠2s，打印父进程的进程号和返回的子线程的线程号。

+ 验证实验**多生产者-多消费者问题**

执行程序命令：

    gcc alg.18-6-syn-pc-con-6.c -pthread
    gcc alg.18-7-syn-pc-producer-6.c -o alg.18-7-syn-pc-producer-6.o -pthread
    gcc alg.18-8-syn-pc-consumer-6.c -o alg.18-8-syn-pc-consumer-6.o -pthread
    ./a.out myshm
    4 8 2 3

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/8.png)

可以看到，在实验环境下使用clone()函数创建出的子线程递归调用可以使用栈空间的上限递归次数为732605，514288 *4096-1936125 *1024 = 123931648‬，123931648‬/1936125 = 64(字节), 说明每次递归的实验环境系统开销大概是64字节。

实现细节解释：

一开始动态内存申请一个大小为```STACK_SIZE```的```char```类型指针```stack```，初始化标志变量```flag```为0。

接着使用语句```clone(test, stack + STACK_SIZE, flags | SIGCHLD, buf)```创建一个子线程并把返回值即创建的线程的线程号赋给变量```chdtid```，**在线程运行函数```test()```中：**

    static int test(void *arg)
    { 
        static int i = 0;
        char buffer[1024]; 
        if(i == 0) {
            printf("test: my ptd = %d, tid = %ld, ppid = %d\n", getpid(), gettid(), getppid());
            printf("\niteration = %8d", i); 
        }
        printf("\b\b\b\b\b\b\b\b%8d", i); 
        i++; 
        test(arg); /* recursive calling */
    } 

首先初始化静态变量i为0，然后如果i为0，那么打印子线程的进程号、线程号、父进程号和迭代次数即i的值，退出判断语句，打印i的值，使i自增，最后使用```test(arg)```语句递归调用```test()```函数。

打印传递进的字符串的参数的内容，接着休眠1s，打印子线程的线程号和进程号，然后休眠1s，打印语句```child_func1 sleeping and then exists ...```，然后结束。

**回到主线程中，** 打印父进程的进程号和子线程的线程号，接着使用```waitpid(-1, &status, 0) == -1```让主线程等待任意一个子线程结束后再继续执行，并把返回的子线程的线程号赋给变量```ret```。

休眠2s，打印父进程的进程号和返回的子线程的线程号。

+ 验证实验**alg.18-9-pthread-cond-wait.c**

执行程序命令：

    gcc alg.18-9-pthread-cond-wait.c -pthread
    ./a.out syn

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/9.png)

可以看到，在实验环境下使用clone()函数创建出的子线程递归调用可以使用栈空间的上限递归次数为732605，514288 *4096-1936125 *1024 = 123931648‬，123931648‬/1936125 = 64(字节), 说明每次递归的实验环境系统开销大概是64字节。

实现细节解释：

一开始动态内存申请一个大小为```STACK_SIZE```的```char```类型指针```stack```，初始化标志变量```flag```为0。

接着使用语句```clone(test, stack + STACK_SIZE, flags | SIGCHLD, buf)```创建一个子线程并把返回值即创建的线程的线程号赋给变量```chdtid```，**在线程运行函数```test()```中：**

    static int test(void *arg)
    { 
        static int i = 0;
        char buffer[1024]; 
        if(i == 0) {
            printf("test: my ptd = %d, tid = %ld, ppid = %d\n", getpid(), gettid(), getppid());
            printf("\niteration = %8d", i); 
        }
        printf("\b\b\b\b\b\b\b\b%8d", i); 
        i++; 
        test(arg); /* recursive calling */
    } 

首先初始化静态变量i为0，然后如果i为0，那么打印子线程的进程号、线程号、父进程号和迭代次数即i的值，退出判断语句，打印i的值，使i自增，最后使用```test(arg)```语句递归调用```test()```函数。

打印传递进的字符串的参数的内容，接着休眠1s，打印子线程的线程号和进程号，然后休眠1s，打印语句```child_func1 sleeping and then exists ...```，然后结束。

**回到主线程中，** 打印父进程的进程号和子线程的线程号，接着使用```waitpid(-1, &status, 0) == -1```让主线程等待任意一个子线程结束后再继续执行，并把返回的子线程的线程号赋给变量```ret```。

休眠2s，打印父进程的进程号和返回的子线程的线程号。

+ 验证实验**alg.18-5-syn-pthread-sem-named.c**

执行程序命令：

    gcc alg.18-5-syn-pthread-sem-named.c -pthread
    ./a.out syn

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/13.png)

可以看到，在实验环境下使用clone()函数创建出的子线程递归调用可以使用栈空间的上限递归次数为732605，514288 *4096-1936125 *1024 = 123931648‬，123931648‬/1936125 = 64(字节), 说明每次递归的实验环境系统开销大概是64字节。

实现细节解释：

一开始动态内存申请一个大小为```STACK_SIZE```的```char```类型指针```stack```，初始化标志变量```flag```为0。

接着使用语句```clone(test, stack + STACK_SIZE, flags | SIGCHLD, buf)```创建一个子线程并把返回值即创建的线程的线程号赋给变量```chdtid```，**在线程运行函数```test()```中：**

    static int test(void *arg)
    { 
        static int i = 0;
        char buffer[1024]; 
        if(i == 0) {
            printf("test: my ptd = %d, tid = %ld, ppid = %d\n", getpid(), gettid(), getppid());
            printf("\niteration = %8d", i); 
        }
        printf("\b\b\b\b\b\b\b\b%8d", i); 
        i++; 
        test(arg); /* recursive calling */
    } 

首先初始化静态变量i为0，然后如果i为0，那么打印子线程的进程号、线程号、父进程号和迭代次数即i的值，退出判断语句，打印i的值，使i自增，最后使用```test(arg)```语句递归调用```test()```函数。

打印传递进的字符串的参数的内容，接着休眠1s，打印子线程的线程号和进程号，然后休眠1s，打印语句```child_func1 sleeping and then exists ...```，然后结束。

**回到主线程中，** 打印父进程的进程号和子线程的线程号，接着使用```waitpid(-1, &status, 0) == -1```让主线程等待任意一个子线程结束后再继续执行，并把返回的子线程的线程号赋给变量```ret```。

休眠2s，打印父进程的进程号和返回的子线程的线程号。

+ 验证实验**alg.18-5-syn-pthread-sem-named.c**

执行程序命令：

    gcc alg.18-5-syn-pthread-sem-named.c -pthread
    ./a.out syn

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/13.png)

可以看到，在实验环境下使用clone()函数创建出的子线程递归调用可以使用栈空间的上限递归次数为732605，514288 *4096-1936125 *1024 = 123931648‬，123931648‬/1936125 = 64(字节), 说明每次递归的实验环境系统开销大概是64字节。

实现细节解释：

一开始动态内存申请一个大小为```STACK_SIZE```的```char```类型指针```stack```，初始化标志变量```flag```为0。

接着使用语句```clone(test, stack + STACK_SIZE, flags | SIGCHLD, buf)```创建一个子线程并把返回值即创建的线程的线程号赋给变量```chdtid```，**在线程运行函数```test()```中：**

    static int test(void *arg)
    { 
        static int i = 0;
        char buffer[1024]; 
        if(i == 0) {
            printf("test: my ptd = %d, tid = %ld, ppid = %d\n", getpid(), gettid(), getppid());
            printf("\niteration = %8d", i); 
        }
        printf("\b\b\b\b\b\b\b\b%8d", i); 
        i++; 
        test(arg); /* recursive calling */
    } 

首先初始化静态变量i为0，然后如果i为0，那么打印子线程的进程号、线程号、父进程号和迭代次数即i的值，退出判断语句，打印i的值，使i自增，最后使用```test(arg)```语句递归调用```test()```函数。

打印传递进的字符串的参数的内容，接着休眠1s，打印子线程的线程号和进程号，然后休眠1s，打印语句```child_func1 sleeping and then exists ...```，然后结束。

**回到主线程中，** 打印父进程的进程号和子线程的线程号，接着使用```waitpid(-1, &status, 0) == -1```让主线程等待任意一个子线程结束后再继续执行，并把返回的子线程的线程号赋给变量```ret```。

休眠2s，打印父进程的进程号和返回的子线程的线程号。

### 比较 pthread 和 clone() 线程实现机制的异同

#### 不同点

**pthread**实现机制是基于用户级线程的，在用户空间运行线程库，线程库完成线程的创建、消息传递等操作，内核感知不到用户线程的存在，此时以进程为单位，管理进程的执行状态。

因为pthread创建出的线程是用户线程，所以可以跨操作系统运行，不需要切换到内核模式就可以完成线程的切换，节省开销和内核资源。但是在操作系统调度进程时，因为每个进程只有一个创建出来的线程可以执行，所以这个线程阻塞就会使整个进程阻塞，只能使用非内核调度自己实现的调度算法来实现这个线程。

**clone()** 实现机制是基于轻量级进程（LWP）的，LWP是内核支持的用户线程，进行建立线程等操作时，内核可以感知用户线程的存在，并且进行调度。

每个LWP都是独立的线程调度单元，和特定的内核线程相联系，具有部分内核线程的特点，会消耗内核栈空间，进行系统调度时需要在内核线程和用户线程之间切换，系统调用的代价较高，所以一个系统不能支持大量LWP，但是因为每个LWP是独立的线程调度单元，所以在操作系统调度进程时，即使创建出来的LWP被阻塞，不会影响整个进程的执行。

#### 相同点

在Linux系统中，由于并没有进程线程的区分，统一称为任务，所以pthread中创建线程的pthread_create()函数，内部使用的也是clone()函数，为clone()函数设置特定标志后，实现了pthread_create()。

### 对 clone() 的 flags 采用不同的配置，设计测试程序讨论其结果

+ 配置包括 CLONE_PARENT, CLONE_VM, CLONE_VFORK, CLONE_FILES, CLONE_SIGHAND, CLONE_NEWIPC, CLONE_THREAD

|标志|含义|
|---|-----|
|CLONE_PARENT|子进程和调用者共享父进程|
|CLONE_VM|共享内存空间|
|CLONE_VFORK|运行时父进程被挂起，直至子进程释放内存资源|
|CLONE_FILES|共享文件描述符表|
|CLONE_SIGHAND|共享信号处理表|
|CLONE_NEWIPC|子进程使用新的IPC命名空间|
|CLONE_THREAD|共享线程群|

在文件```alg.14-6-clone-demo.c```中，已经测试了参数```CLONE_VM```和```CLONE_VFORK```的作用，所以设计程序时，参照了文件```alg.14-6-clone-demo.c```的部分内容。

+ 测试参数CLONE_PARENT

子线程执行函数：

    // 测试参数CLONE_PARENT所用到的子线程执行函数
    static int CLONE_PARENT_func(void *arg) {
        // 打印子线程的线程号、进程号、父进程号
        printf("I am CLONE_PARENT_func, my tid = %ld, pid = %d, ppid = %d\n", gettid(), getpid(), getppid());
        
        return 0;
    }

主函数中的测试代码：

    // 测试参数CLONE_PARENT
    printf("------------------------------------------------------------------\n");
    // 设置参数CLONE_PARENT前
    printf("Before set flags to CLONE_PARENT\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    chdtid_CLONE_PARENT = clone(CLONE_PARENT_func, stack_CLONE_PARENT + STACK_SIZE, flags | SIGCHLD, NULL);
    if(chdtid_CLONE_PARENT == -1) {
        perror("CLONE_PARENT before:clone()");
        exit(1);
    }
    // 打印主线程的进程号和父进程号
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    // 休眠1s以便子线程结束
    sleep(1);
    printf("\n");

    // 设置参数CLONE_PARENT后
    printf("After set flags to CLONE_PARENT\n");
    // 设置参数为CLONE_PARENT
    flags |= CLONE_PARENT;
    printf("Result:\n");
    chdtid_CLONE_PARENT = clone(CLONE_PARENT_func, stack_CLONE_PARENT + STACK_SIZE, flags | SIGCHLD, NULL);
    if(chdtid_CLONE_PARENT == -1) {
        perror("CLONE_PARENT after:clone()");
        exit(1);
    }
    // 打印主线程的进程号和父进程号
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    // 休眠1s以便子线程结束
    sleep(1);
    printf("------------------------------------------------------------------\n\n");

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/14.png)

可以看到，在没有设置参数时，主线程的线程号是81752，子线程的父进程的线程号是81752，说明子线程的父进程是创建它的主线程。

在设置了参数之后，主线程的父进程的线程号是79440，子线程的父进程的线程号是81572，说明子线程的父进程也是创建它的主线程的父进程，子线程和主线程是“兄弟”关系，共享同一个父进程。

+ 测试参数CLONE_VM

子线程执行函数：

    // 测试参数CLONE_VM所用到的子线程执行函数
    static int CLONE_VM_func(void *arg) {
        // 获取主线程传来的缓冲区参数buf
        char *chdbuf = (char*)arg;
        printf("CLONE_VM_func read buf: %s\n", chdbuf);
        sleep(1);
        // 设置缓冲区buf中的内容为子线程的信息
        sprintf(chdbuf, "I am CLONE_VM_func, my tid = %ld, pid = %d", gettid(), getpid());
        printf("CLONE_VM_func set buf: %s\n", chdbuf);
        sleep(1);
        // 子线程退出
        printf("CLONE_VM_func sleeping and then exists ...\n");
        sleep(1);

        return 0;
    }

主函数中的测试代码：

    // 测试参数CLONE_VM
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_VM\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    // 设置缓冲区buf中的内容为主线程的信息
    sprintf(buf,"I am main thread, my pid = %d", getpid());
    printf("main thread set buf: %s\n", buf);
    sleep(1);
    printf("parent clone ...\n");
    chdtid_CLONE_VM = clone(CLONE_VM_func, stack_CLONE_VM + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid_CLONE_VM == -1) {
        perror("CLONE_VM before:clone()");
        exit(1);
    }
    // 等待子线程执行完后主线程再继续执行，测试子线程改变了缓冲区buf的内容是否会影响到主线程
    waitpid(chdtid_CLONE_VM, &status, 0);
    // 打印此时缓冲区buf中的内容
    printf("parent read buf: %s\n", buf);
    printf("\n");

    printf("After set flags to CLONE_VM\n");
    // 设置参数为CLONE_VM
    flags |= CLONE_VM;
    printf("Result:\n");
    // 设置缓冲区buf中的内容为主线程的信息
    sprintf(buf,"I am main thread, my pid = %d", getpid());
    printf("main thread set buf: %s\n", buf);
    sleep(1);
    printf("parent clone ...\n");
    chdtid_CLONE_VM = clone(CLONE_VM_func, stack_CLONE_VM + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid_CLONE_VM == -1) {
        perror("CLONE_VM after:clone()");
        exit(1);
    }
    // 等待子线程执行完后主线程再继续执行，测试子线程改变了缓冲区buf的内容是否会影响到主线程
    waitpid(chdtid_CLONE_VM, &status, 0);
    // 打印此时缓冲区buf中的内容
    printf("parent read buf: %s\n", buf);
    printf("------------------------------------------------------------------\n\n");

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/15.png)

可以看到，在没有设置参数时，在主线程设置了缓冲区```buf```里的内容之后，即使子线程在线程执行函数中也修改了缓冲区```buf```中的内容，但是回到主线程后，缓冲区```buf```中的内容仍为之前主线程设置的内容。

在设置了参数之后，在主线程设置了缓冲区```buf```里的内容之后，子线程在线程执行函数中也修改了缓冲区```buf```中的内容，回到主线程后，缓冲区```buf```中的内容变成了子线程设置的内容。

说明设置参数后，子线程和主线程在运行时共享内存空间。

+ 测试参数CLONE_VFORK

子线程执行函数：

    // 测试参数CLONE_VFORK所用到的子线程执行函数
    static int CLONE_VFORK_func(void *arg) {
        printf("I am CLONE_VFORK_func, my tid = %ld, pid = %d\n", gettid(), getpid());
        printf("CLONE_VFORK_func sleeping 3s and then exists ...\n");
        // 休眠3s，如果主线程与子线程异步执行，那么主线程有足够时间在这期间继续执行，否则主线程会等待子线程执行完再继续执行
        sleep(3);
        // 标志子线程执行完退出
        printf("CLONE_VFORK_func exists successfully!\n");

        return 0;
    }

主函数中的测试代码：

    // 测试参数CLONE_VFORK
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_VFORK\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    chdtid_CLONE_VFORK = clone(CLONE_VFORK_func, stack_CLONE_VFORK + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid_CLONE_VFORK == -1) {
        perror("CLONE_VFORK before:clone()");
        exit(1);
    }
    // 在waitpid()函数之前打印主线程的信息，观察主线程是否会等待子线程执行完后再执行
    printf("I am main thread, my pid = %d\n", getpid());
    waitpid(chdtid_CLONE_VFORK, &status, 0);
    printf("\n");

    printf("After set flags to CLONE_VFORK\n");
    // 设置参数为CLONE_VFORK
    flags |= CLONE_VFORK;
    printf("Result:\n");
    chdtid_CLONE_VFORK = clone(CLONE_VFORK_func, stack_CLONE_VFORK + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid_CLONE_VFORK == -1) {
        perror("CLONE_VFORK after:clone()");
        exit(1);
    }
    // 在waitpid()函数之前打印主线程的信息，观察主线程是否会等待子线程执行完后再执行
    printf("I am main thread, my pid = %d\n", getpid());
    waitpid(chdtid_CLONE_VFORK, &status, 0);
    printf("------------------------------------------------------------------\n\n");

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/16.png)

可以看到，在没有设置参数时，子线程和主线程异步执行，打印主线程信息的语句在子线程还未执行完就直接执行。

在设置了参数之后，主线程被挂起，直到子线程终止后再继续执行，即使子线程休眠了3s，主线程也未执行打印语句，直到子线程退出后，主线程才继续执行，打印了主线程信息语句。

说明设置参数后，主线程被挂起，直到子线程执行完释放资源后再继续执行。

+ 测试参数CLONE_FILES

子线程执行函数：

    // 测试参数CLONE_FILES所用到的子线程执行函数
    static int CLONE_FILES_func(void *arg) {
        // 获取主线程传来的文件描述符
        int *numptr = (int *)arg;
        int fd = *numptr;
        
        // 设置文件的FD_CLOEXEC参数为1
        fcntl(fd, F_SETFD, 1);
        printf("I am CLONE_FILES_func, my tid = %ld, pid = %d, ppid = %d\n", gettid(), getpid(), getppid());
        printf("CLONE_FILES_func sets the FD_COLEXEC of fd to %d\n", fcntl(fd, F_GETFD));
        
        return 0;
    }

主函数中的测试代码：

    // 测试参数CLONE_FILES
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_FILES\n");
    int fd = open("./test.txt", O_RDWR | O_CREAT, 0666);
    if (fd < 0) {
        perror("CLONE_FILES:open()");
        exit(EXIT_FAILURE);
    }
    
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    // 设置文件的FD_CLOEXEC参数为0
    fcntl(fd, F_SETFD, 0);
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    printf("In the beginning, main thread sets the FD_COLEXEC of fd to %d\n\n", fcntl(fd, F_GETFD));

    chdtid_CLONE_FILES = clone(CLONE_FILES_func, stack_CLONE_FILES + STACK_SIZE, flags | SIGCHLD, &fd);
    if(chdtid_CLONE_FILES == -1) {
        perror("CLONE_FILES before:clone()");
        exit(1);
    }

    // 等待子线程执行完后主线程再继续执行，测试子线程改变了文件的FD_CLOEXEC参数是否会影响到主线程
    waitpid(chdtid_CLONE_FILES, &status, 0);
    // 查看文件的FD_CLOEXEC参数
    printf("\nIn the last, the FD_COLEXEC of fd in main thread is %d\n\n\n", fcntl(fd, F_GETFD));

    printf("After set flags to CLONE_FILES\n");
    // 设置参数为CLONE_FILES
    flags |= CLONE_FILES;
    printf("Result:\n");
    // 设置文件的FD_CLOEXEC参数为0
    fcntl(fd, F_SETFD, 0);
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    printf("In the beginning, main thread sets the FD_COLEXEC of fd to %d\n\n", fcntl(fd, F_GETFD));

    chdtid_CLONE_FILES = clone(CLONE_FILES_func, stack_CLONE_FILES + STACK_SIZE, flags | SIGCHLD, &fd);
    if(chdtid_CLONE_FILES == -1) {
        perror("CLONE_FILES after:clone()");
        exit(1);
    }

    // 等待子线程执行完后主线程再继续执行，测试子线程改变了文件的FD_CLOEXEC参数是否会影响到主线程
    waitpid(chdtid_CLONE_FILES, &status, 0);
    // 查看文件的FD_CLOEXEC参数
    printf("\nIn the last, the FD_COLEXEC of fd in main thread is %d\n", fcntl(fd, F_GETFD));
    printf("------------------------------------------------------------------\n\n");

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/17.png)

可以看到，在没有设置参数时，一开始，主线程先设置文件的```FD_CLOEXEC```文件描述符标志为0，然后子线程设置文件的```FD_CLOEXEC```文件描述符标志为1，最后在主线程中，查看文件的```FD_CLOEXEC```文件描述符标志，发现为0，说明子线程和主线程并不共享文件描述符表。

在设置了参数之后，一开始，主线程先设置文件的```FD_CLOEXEC```文件描述符标志为0，然后子线程设置文件的```FD_CLOEXEC```文件描述符标志为1，最后在主线程中，查看文件的```FD_CLOEXEC```文件描述符标志，发现为1，说明子线程和主线程共享文件描述符表。

+ 测试参数CLONE_SIGHAND

信号处理函数：

    // 主线程中的信号处理函数
    void main_thread_handler(int signo) {
        printf("\nThis is main_thread_handler");
        printf("\nsignal catched: signo = %d\n", signo);
        
        return;
    }

    // 子线程中的信号处理函数
    void CLONE_SIGHAND_handler(int signo) {
        printf("\nThis is CLONE_SIGHAND_handler");
        printf("\nsignal catched: signo = %d\n", signo);
        
        return;
    }

子线程执行函数：

    // 测试参数CLONE_SIGHAND所用到的子线程执行函数
    static int CLONE_SIGHAND_func(void *arg) {
        // 设置捕捉到Ctrl+C信号的信号处理函数为CLONE_SIGHAND_handler
        signal(SIGINT, CLONE_SIGHAND_handler);
        printf("I am CLONE_SIGHAND_func, my tid = %ld, pid = %d, ppid = %d\n", gettid(), getpid(), getppid());
        printf("CLONE_SIGHAND_func set CLONE_SIGHAND_handler\n\n");

        return 0;
    }

主函数中的测试代码：

    // 测试参数CLONE_SIGHAND
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_SIGHAND\n");
    // 设置参数为0
    flags = 0;

    printf("Result:\n");
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    printf("In the beginning, main thread set main_thread_handler\n\n");
    // 设置捕捉到Ctrl+C信号的信号处理函数为main_thread_handler
    signal(SIGINT, main_thread_handler);
    // 从linux 2.6.0开始，当指定CLONE_SIGHAND后，必须也指定CLONE_VM
    chdtid_CLONE_SIGHAND = clone(CLONE_SIGHAND_func, stack_CLONE_SIGHAND + STACK_SIZE, flags | CLONE_VM | SIGCHLD, NULL);
    if(chdtid_CLONE_SIGHAND == -1) {
        perror("CLONE_SIGHAND before:clone()");
        exit(1);
    }

    // 等待子线程执行完后主线程再继续执行，测试子线程改变了捕捉到Ctrl+C信号的信号处理函数是否会影响到主线程
    waitpid(chdtid_CLONE_SIGHAND, &status, 0);

    // 休眠100s，便于输入Ctrl+C信号，输入后信号处理完毕后主线程继续执行
    printf("now start catching Ctrl+c\n");
    sleep(100);

    printf("\n");

    printf("After set flags to CLONE_SIGHAND\n");
    // 设置参数为CLONE_SIGHAND
    flags |= CLONE_SIGHAND;

    printf("Result:\n");
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    printf("In the beginning, main thread set main_thread_handler\n\n");
    // 设置捕捉到Ctrl+C信号的信号处理函数为main_thread_handler
    signal(SIGINT, main_thread_handler);
    // 从linux 2.6.0开始，当指定CLONE_SIGHAND后，必须也指定CLONE_VM
    chdtid_CLONE_SIGHAND = clone(CLONE_SIGHAND_func, stack_CLONE_SIGHAND + STACK_SIZE, flags | CLONE_VM | SIGCHLD, NULL);
    if(chdtid_CLONE_SIGHAND == -1) {
        perror("CLONE_SIGHAND before:clone()");
        exit(1);
    }

    // 等待子线程执行完后主线程再继续执行，测试子线程改变了捕捉到Ctrl+C信号的信号处理函数是否会影响到主线程
    waitpid(chdtid_CLONE_SIGHAND, &status, 0);

    // 休眠100s，便于输入Ctrl+C信号，输入后信号处理完毕后主线程继续执行
    printf("now start catching Ctrl+c\n");
    sleep(100);

    printf("------------------------------------------------------------------\n\n");

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/18.png)

可以看到，在没有设置参数时，一开始，主线程先设置捕捉到```Ctrl+C```信号后的信号处理函数为```main_thread_handler```，然后子线程设置捕捉到```Ctrl+C```信号后的信号处理函数为```CLONE_SIGHAND_handler```，最后在主线程中，运行程序准备捕捉```Ctrl+C```信号，捕捉到后发现信号处理函数为```main_thread_handler```，说明子线程和主线程并不共享信号处理表。

在设置了参数之后，一开始，主线程先设置捕捉到```Ctrl+C```信号后的信号处理函数为```main_thread_handler```，然后子线程设置捕捉到```Ctrl+C```信号后的信号处理函数为```CLONE_SIGHAND_handler```，最后在主线程中，运行程序准备捕捉```Ctrl+C```信号，捕捉到后发现信号处理函数为```CLONE_SIGHAND_handler```，说明子线程和主线程共享信号处理表。

+ 测试参数CLONE_NEWIPC

子线程执行函数：

    // 测试参数CLONE_NEWIPC所用到的子线程执行函数
    static int CLONE_NEWIPC_func(void *arg) {
        // 查看线程所处的IPC命名空间的消息队列的信息
        printf("Message Queues in CLONE_NEWIPC_func:\n");
        system("ipcs -q");
        
        return 0;
    }

主函数中的测试代码：

    // 测试参数CLONE_NEWIPC
    printf("------------------------------------------------------------------\n");
    // 首先在主线程中创建一个消息队列
    printf("First create a message queue in main thread\n\n");
    char pathname[10] = {"./test"};
    struct stat fileattr;
    key_t key;
    int msqid;
    if(stat(pathname, &fileattr) == -1) {
        ret = creat(pathname, O_RDWR);
        if (ret == -1) {
            ERR_EXIT("CLONE_NEWIPC: creat()");
        }
        printf("shared file object created\n");
    }
    
    key = ftok(pathname, 0x27);
    if(key < 0) {
        ERR_EXIT("ftok()");
    }
    
    msqid = msgget((key_t)key, 0666 | IPC_CREAT);
    if(msqid == -1) {
        ERR_EXIT("msgget()");
    }

    printf("Before set flags to CLONE_NEWIPC\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n\n");

    // 查看主线程的IPC命名空间中消息队列的情况
    printf("Command: ipcs -q\n\n");
    printf("Message Queues in main thread:\n");
    system("ipcs -q");
    chdtid_CLONE_NEWIPC = clone(CLONE_NEWIPC_func, stack_CLONE_NEWIPC + STACK_SIZE, flags | SIGCHLD, NULL);
    if(chdtid_CLONE_NEWIPC == -1) {
        perror("CLONE_NEWIPC before:clone()");
        exit(1);
    }
    // 等待子线程执行完后主线程再继续执行，测试子线程的命名空间是否和主线程一样
    waitpid(chdtid_CLONE_NEWIPC, &status, 0);
    printf("\n");

    printf("After set flags to CLONE_NEWIPC\n");
    // 设置参数为CLONE_NEWIPC
    flags |= CLONE_NEWIPC;
    printf("Result:\n\n");

    // 查看主线程的IPC命名空间中消息队列的情况
    printf("Command: ipcs -q\n\n");
    printf("Message Queues in main thread:\n");
    system("ipcs -q");
    chdtid_CLONE_NEWIPC = clone(CLONE_NEWIPC_func, stack_CLONE_NEWIPC + STACK_SIZE, flags | SIGCHLD, NULL);
    if(chdtid_CLONE_NEWIPC == -1) {
        perror("CLONE_NEWIPC after:clone()");
        exit(1);
    }
    // 等待子线程执行完后主线程再继续执行，测试子线程改变了捕捉到Ctrl+C信号的信号处理函数是否会影响到主线程
    waitpid(chdtid_CLONE_NEWIPC, &status, 0);

    // 删除之前创建的消息队列
    sprintf(buf, "ipcrm -q %d", msqid);
    printf("Command: %s\n", buf);
    system(buf);
    printf("------------------------------------------------------------------\n\n");

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/19.png)

可以看到，首先创建一个消息队列，在没有设置参数时，在主线程和子线程中分别查看线程所处的IPC命名空间中的消息队列情况，发现主线程和子线程所处的IPC命名空间中消息队列的情况一样，说明主线程和子线程处在同一个IPC命名空间中。

在设置了参数之后，，在主线程和子线程中分别查看线程所处的IPC命名空间中的消息队列情况，发现主线程和子线程所处的IPC命名空间中消息队列的情况不一样，子线程的IPC命名空间中没有消息队列，说明主线程和子线程不处在同一个IPC命名空间中，子线程和主线程隔离。

+ 测试参数CLONE_THREAD

子线程执行函数：

    // 测试参数CLONE_THREAD所用到的子线程执行函数
    static int CLONE_THREAD_func(void *arg) {
        // 打印子线程的线程号、进程号、父进程号
        printf("I am CLONE_THREADs_func, my tid = %ld, pid = %d, ppid = %d\n", gettid(), getpid(), getppid());

        return 0;
    }

主函数中的测试代码：

    // 测试参数CLONE_THREAD
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_THREAD\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    // 从Linux 2.5.35开始，如果指定了CLONE_THREAD，则必须同时指定CLONE_SIGHAND。而从Linux 2.6.0开始，指定CLONE_SIGHAND的同时也必须指定CLONE_VM
    chdtid_CLONE_THREAD = clone(CLONE_THREAD_func, stack_CLONE_THREAD + STACK_SIZE, flags | CLONE_VM | CLONE_SIGHAND | SIGCHLD, NULL);
    if(chdtid_CLONE_THREAD == -1) {
        perror("CLONE_THREAD before:clone()");
        exit(1);
    }
    // 打印主线程的进程号和父进程号
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    // 休眠1s以便子线程结束
    sleep(1);
    printf("\n");

    printf("After set flags to CLONE_THREAD\n");
    // 设置参数为CLONE_THREAD
    flags |= CLONE_THREAD;
    printf("Result:\n");
    // 从Linux 2.5.35开始，如果指定了CLONE_THREAD，则必须同时指定CLONE_SIGHAND。而从Linux 2.6.0开始，指定CLONE_SIGHAND的同时也必须指定CLONE_VM
    chdtid_CLONE_THREAD = clone(CLONE_THREAD_func, stack_CLONE_THREAD + STACK_SIZE, flags | CLONE_VM | CLONE_SIGHAND | SIGCHLD, NULL);
    if(chdtid_CLONE_THREAD == -1) {
        perror("CLONE_THREAD after:clone()");
        exit(1);
    }
    // 打印主线程的进程号和父进程号
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    // 休眠1s以便子线程结束
    sleep(1);
    printf("------------------------------------------------------------------\n\n");

分析：

![](http://stugeek.gitee.io/operating-system/Labwork15-pictures/20.png)

可以看到，在没有设置参数时，主线程的线程号是81752，子线程的父进程的线程号是81752，说明子线程的父进程是创建它的主线程。

在设置了参数之后，主线程的父进程的线程号是79440，子线程的父进程的线程号是81572，说明子线程的父进程也是创建它的主线程的父进程，子线程和主线程是“兄弟”关系，共享线程群。
