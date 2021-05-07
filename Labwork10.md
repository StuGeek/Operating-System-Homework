# 操作系统实验报告10

## 实验内容

+ 实验内容：线程（1）。
    + 编译运行课件 Lecture13 例程代码：
        + Algorithms 13-1 ~ 13-8


## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### POSIX Pthreads

实验内容原理：

Pthreads是POSIX标准(IEEE 1003.1c)的扩展线程库，它定义了一个用于线程创建和同步的API，可以为用户级库或内核级库提供支持，Pthreads是线程行为的规范，操作系统设计人员可以按照他们希望的任何方式执行实现这些规范。许多系统都实现了Pthreads规范，比如UNIX类型的系统，包括Linux, Mac OS X和Solaris，Pthreads中常用的函数有：

|函数| 功能描述|
|---|---|
|pthread_create| 创建一个新线程|
|pthread_exit| 终止一个线程|
|pthread_join| 等待特定的线程退出|
|pthread_yield| 释放CPU从而让其它线程可以运行|
|pthread_attr_init| 创建和初始化一个线程的属性结构|
|pthread_attr_destroy| 清除一个线程的属性结构|

其中实验中用到的函数有：

    int pthread_create(pthread_t *tidp,const pthread_attr_t *attr,void *(*start_rtn)(void*),void *arg);

```pthread_create()```函数用来创建一个线程，其中第一个参数为指向线程标识符的的一个指针，第二个参数为线程属性，第三个参数为线程运行的函数的起始地址，第四个参数为向运行函数传递的参数。

    int pthread_join(pthread_t thread, void **retval);

```pthread_join()```函数用来等待一个线程结束，其中第一个参数为等待退出的进程的进程号，第二个参数为退出的线程的返回值。

    void pthread_exit(void *retval)

```pthread_exit()```函数用来退出线程，其中参数代表线程的返回值。

    int pthread_attr_init(pthread_attr_t *attr)

```pthread_attr_init()```函数用来初始化一个线程属性对象，其中参数代表线程属性结构体指针变量

+ 验证实验**alg.13-1-pthread-create.c**

执行程序命令：

    gcc alg.13-1-pthread-create.c -pthread
    ./a.out 10
    ./a.out 100
    ./a.out -10
    ./a.out asd

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/1.png)

可以看到，向程序传递一个大于0的参数，程序创建一个线程进行计算后会返回从1到这个参数的所有整数的和，最后输出结果，如果输入的是一个小于等于0或者非数字的参数，那么程序返回结果就是0。

实现细节解释：

一开始使用语句```pthread_create(&ptid, &attr, &runner, argv[1])```创建一个线程，其中参数```&ptid```为指向线程标识符的的一个指针，参数```&attr```为要设置的线程属性，参数```&runner```为线程运行的函数的起始地址，参数```argv[1]```为向运行函数传递的参数，在线程运行函数中：

    static void *runner(void *param)
    {
        int i, upper;

        upper = atoi(param);
        sum = 0;
        for (i =1; i <= upper; i++)
            sum += i;

        pthread_exit(0);
    }

参数```param```指向的是传递的参数```argv[1]```，```sum```是全局变量，函数的作用是对1到参数之间的所有正整数进行求和并把结果保存在全局变量```sum```里，最后使用语句```pthread_exit(0)```返回值为0。

回到主函数中，在创建了线程之后，又使用函数```pthread_join(ptid, NULL)```，其中参数```ptid```即为刚才创建的线程的标识符，```NULL```为默认属性，函数的作用是使主线程等待这个计算求和值的线程运行完后再运行，不然还没得到计算结果主线程就继续向下执行，有可能出错。

最后打印求和值```sum```。

+ 验证实验**alg.13-1-pthread-create-1-1.c**

执行程序命令：

    gcc alg.13-1-pthread-create-1-1.c -pthread
    ./a.out 10
    ./a.out 100
    ./a.out -10
    ./a.out asd

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/2.png)

相比之前一个程序```alg.13-1-pthread-create```，这个程序还打印了计算线程的返回值16

实现细节解释：

与之前一个程序```alg.13-1-pthread-create```相比，这个程序的计算线程函数中：

    static void *runner(void *param)
    {
        int i, upper;

        upper = atoi(param);
        sum = 0;
        for ( i = 1; i <= upper; i++)
            sum += i;

        int *retptr = (int *)malloc(sizeof(int));
        *retptr = 16;

        pthread_exit((void *)retptr);
    }

在线程空间中申请了一块动态内存给一个整型指针，这个整型指针指向整数16，最后使用语句```pthread_exit((void *)retptr)```将这个指针作为线程的返回值，利用指针实现了向主线程传递值。

在主函数中，语句```pthread_join(ptid, (void **)&retptr)```通过整型指针```retptr```接收到了计算线程的返回值，并把这个指针指向的值16打印出来，最后释放指针的动态内存。

+ 验证实验**alg.13-1-pthread-create-1-2.c**

执行程序命令：

    gcc alg.13-1-pthread-create-1-2.c -pthread
    ./a.out 10
    ./a.out 100
    ./a.out -10
    ./a.out asd

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/3.png)

相比之前一个程序```alg.13-1-pthread-create-1-1```，这个程序打印的计算线程的返回值是求和的值

实现细节解释：

与之前一个程序```alg.13-1-pthread-create-1-1```相比，这个程序的计算线程函数中：

    static void *runner(void *param)
    {
        int i, upper;

        upper = atoi(param);
        sum = 0;
        for (i = 1; i <= upper; i++)
            sum += i;

        pthread_exit((void *)&sum);
    }

线程中的```sum```是一个未初始化的全局变量，位于bss段，最后使用的语句```pthread_exit((void *)&sum)```返回的是一个在线程的bss段的一个地址，里面是求和值

在主函数中，语句```pthread_join(ptid, (void **)&retptr)```通过整型指针```retptr```接收到了计算线程的返回值，并把这个指针指向的```sum```的值打印出来。

+ 验证实验**alg.13-1-pthread-create-1-3.c**

执行程序命令：

    gcc alg.13-1-pthread-create-1-3.c -pthread
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/4.png)

相比之前一个程序```alg.13-1-pthread-create-1-2```，这个程序打印的计算线程的返回值是从1到计算线程中的临时变量```upper```即10之间所有正整数求和的值

实现细节解释：

与之前一个程序```alg.13-1-pthread-create-1-2```相比，这个程序的计算线程函数中：

    static void *runner(void *param)
    {
        int *sum = (int *)param;
        int upper = 10;
        int i;

        *sum = 0;
        for (i = 1; i <= upper; i++)
            *sum += i;

        pthread_exit((void *)sum);
    }

线程中的```sum```是线程中的一个临时变量，位于栈段，最后使用的语句```pthread_exit((void *)sum)```返回的是一个在线程的栈段的一个指针，指向的是求和值

在主函数中，语句```pthread_join(ptid, (void **)&retptr)```通过整型指针```retptr```接收到了计算线程的返回值，并把这个指针指向的```sum```的值打印出来。

+ 验证实验**alg.13-1-pthread-create-2.c**

执行程序命令：

    gcc alg.13-1-pthread-create-2.c -pthread
    ./a.out 10
    ./a.out 100
    ./a.out -10
    ./a.out asd

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/5.png)

相比之前的程序```alg.13-1-pthread-create-1-2```，这个程序打印的计算线程的返回值是一个字符串，为```Hello, world!```

实现细节解释：

与之前的程序```alg.13-1-pthread-create-1-2```相比，这个程序的计算线程函数中：

    static void *runner(void *param)
    {
        int i = 1;
        int upper = atoi(param);

        sum = 0;
        for (; i <= upper; i++)
            sum += i;

        char msg[] = "Hello, world!";
        char *retptr = (char *)malloc((strlen(msg)+1)*sizeof(char)); /* allocated in process space */
        strcpy(retptr, msg);

        pthread_exit((void *)retptr);
    }

在线程空间中申请了一块动态内存给一个字符型指针，这个字符串为```Hello, world!```，最后使用语句```pthread_exit((void *)retptr)```将这个字符串作为线程的返回值，利用指针向主线程传递值。

在主函数中，语句```pthread_join(ptid, (void **)&retptr)```通过整型指针```retptr```接收到了计算线程的返回值，并把这个指针的字符串```Hello, world!```打印出来，最后释放指针的动态内存。

+ 验证实验**alg.13-1-pthread-create-3.c**

执行程序命令：

    gcc alg.13-1-pthread-create-3.c -pthread
    ./a.out 5

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/6.png)

可以看到，向程序传递的参数为要创建的线程数，没有传递参数则创建的线程数默认为5，主函数会根据传递的参数的值创建相应的进程数，但是由于向创建的线程中传递的值是容易被主线程改变的值i，所以创建的线程中获得的值很难预测，会出现混乱，造成程序错误

实现细节解释：

一开始使用语句```pthread_create(&ptid[i], NULL, ftn, (void *)&i)```在一个for循环中创建与传递参数的值对应的多个线程，在线程运行函数中：

    static void *ftn(void *arg)
    {
        int *numptr = (int *)arg;
        int num = *numptr;

        char *retval = (char *)malloc(80*sizeof(char));
    
        sprintf(retval, "This is thread-%d, ptid = %lu", num, pthread_self( ));
        printf("%s\n", retval);

        pthread_exit((void *)retval);
    }

参数```arg```指向的是传递的参数```i```，线程会打印语句这是第i个线程，ptid为当前线程的线程号，并返回打印的语句的字符串

回到主函数中，在创建了线程之后，又在一个for循环中使用函数```pthread_join(ptid[i], (void **)&retptr)```，函数的作用是使主线程等待被创建的线程运行完后再运行，不然创建的线程还没返回主线程就继续向下执行，有可能出错，打印是第几个线程以及线程返回的语句。

+ 验证实验**alg.13-1-pthread-create-3-1.c**

执行程序命令：

    gcc alg.13-1-pthread-create-3-1.c -pthread
    ./a.out 5

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/7.png)

相比之前的程序```alg.13-1-pthread-create-3```，这个程序创建的线程按照顺序获取了传递的值，打印的语句的顺序和编号没有发生混乱，实现正常输出。

实现细节解释：

与之前的程序```alg.13-1-pthread-create-3```相比，这个程序的创建线程的for循环中，最后多了一个```sleep(1)```

    for (i = 0; i < max_num; i++) {
        ret = pthread_create(&ptid[i], NULL, ftn, (void *)&i);
        if(ret != 0) {
            fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
            exit(1);
        }
        sleep(1);
    }

每创建一个线程主线程就休眠1s，这样传递进每个线程的值i发生混乱的概率变小，最后打印出的结果每个线程的编号和顺序都保持正常。

+ 验证实验**alg.13-1-pthread-create-4.c**

执行程序命令：

    gcc alg.13-1-pthread-create-4.c -pthread
    ./a.out 5

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/8.png)

相比之前的程序```alg.13-1-pthread-create-3-1```，这个程序并没有再每次创建线程时让主线程休眠1s，而是一开始：

    int thread_num[max_num];
    for (i = 0; i < max_num; i++) {
        thread_num[i] = i;
    }

然后使用语句```pthread_create(&ptid[i], NULL, ftn, (void *)&thread_num[i])```在for循环中创建进程，最后创建的线程也按照顺序获取了传递的值，打印的语句的顺序和编号没有发生混乱，实现正常输出。

实现细节解释：

因为一开始使用了其它的内存放置了变化的i值，所以thread_num数组中的值后面并不会被主线程改变，传递进每个线程中的是一个稳定的值，最后打印出的结果每个线程的编号和顺序都保持正常。

+ 验证实验**alg.13-2-pthread-shm.c**

执行程序命令：

    gcc alg.13-2-pthread-shm.c -pthread
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/9.png)

这是一个程序开始后，打印当前进程的pid，ppid的值和休眠秒数secnd的值，然后休眠secnd秒后，再继续执行，打印出```sleeper wakes up and returns```的简单程序。

实现细节解释：

程序一开始将三条信息```message 1 by parent```、```message 2 by parent```和```message 3 by parent```分别存入了```msg.msg1```、```msg.msg2```和```msg.msg3```，并打印parent说了这三条信息。

然后使用语句```pthread_create(&tid1, &attr, &runner1, (void *)&msg)```、```pthread_create(&tid2, &attr, &runner2, (void *)&msg) != 0)```分别创建两个线程，两个函数的作用分别是将字符串```message 1 changed by child1```和```message 2 changed by child2```复制进```msg.msg1```、```msg.msg2```，然后使用```pthread_join(tid1, NULL)```和```pthread_join(tid2, NULL)```使主线程等待两个线程复制完字符串后再执行，最后打印结果，发现确实复制成功。

+ 验证实验**alg.13-3-pthread-stack.c**

执行程序命令：

    gcc alg.13-3-pthread-stack.c -pthread
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/10.png)

每次创建的线程执行后，最后都会再次递归，再次使用线程函数test，第0到4次使用test函数会被打印出来，最后又打印了4次递归，然后递归超过了栈的大小，发生了段错误，程序结束。

514288*4096-1965032*1024 = 94330880，94330880/1965032 = 48(字节), 说明每次迭代的系统开销大概是48字节。

实现细节解释：

程序一开始动态申请了一块大小为```STACK_SIZE```的内存给字符型指针```stackptr```，初始化线程后，使用语句```pthread_attr_setstack(&tattr, stackptr, STACK_SIZE)```设置线程栈的大小和地址，再使用语句```pthread_create(&ptid, &tattr, &test, NULL)```创建线程，开始递归，直到递归超过了设置的线程栈的大小，程序结束。

### OpenMP

OpenMP是一组编译器指令和编程用的API，支持C、C++或FORTRAN编程，它提供了对共享内存环境中并行编程的支持。

OpenMP将并行区域标识为可以并行运行的代码块。

应用程序开发人员在并行区域向代码中插入编译器指令，这些指令指示OpenMP库运行时并行执行该区域。

当OpenMP遇到指令

    #pragma omp parallel

它创建的线程数量与系统中处理内核的数量相同（例如，对于Intel CPU，每个内核有两个线程）。所有线程同时执行并行区域，当每个线程退出并行区域时，它将终止。

如果使用指令

    #pragma omp parallel num_threads(i)

那么可以指定创建的线程数量，将创建i个线程执行并行区域。

+ 验证实验**alg.13-4-openmp-demo.c**

执行程序命令：

    gcc alg.13-4-openmp-demo.c -fopenmp
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/11.png)

程序对于每条打印语句创建了不同的线程数，分别打印各条语句，第一条语句被打印了2次，第二条语句被打印了2次，第三条语句被打印了4次，第四条语句被打印了6次。

从程序的不同线程的tid也可以看到，有时候线程会被复用。

实现细节解释：

对于第一条语句，使用指令```#pragma omp parallel```，默认创建的线程数为2，那么就有两个线程打印了第一条语句，第一条语句被打印的次数为2次，如果使用指令```#pragma omp parallel num_threads(i)```，那么会创建i个线程，来执行代码块中的语句，比如第二条语句为2，第三条语句为4，第四条语句为6，分别被打印了2次、4次、6次。

+ 验证实验**alg.13-5-openmp-matrixadd.c**

执行程序命令：

    gcc alg.13-5-openmp-matrixadd.c -fopenmp
    ./a.out 100
    ./a.out 500
    ./a.out 1000
    ./a.out 5000
    ./a.out 6000

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/12.png)

可以看到，使用两个线程比不使用多线程进行矩阵加法计算速度要快，运行时间更短，说明使用多线程进行并行计算可以提高计算效率，但是使用四个线程比使用两个线程计算时间长，这是因为只有两个核，线程数量比核的数量多时，线程会被频繁切换，这样需要的时间就会变更长，反而会降低计算效率和速度。

实现细节解释：

向程序传递的参数表示要计算的是几行几列的矩阵加法，程序分别不使用omp创建多线程，使用omp创建2个线程，创建4个线程执行矩阵加法，并记录时间进行运行时间的比较。

### 多线程编程中使用fork()函数

实验内容原理：

+ fork()系统调用用于创建一个单独的、重复的进程。但是fork()和exec()系统调用的语义在多线程程序中会发生变化：
    + 如果程序中有一个线程调用fork()，那么新进程可能：
        + 复制所有线程
        + 只复制调用fork()系统调用的线程（在Ubuntu中）
            + 这会造成很高的风险
    + 一些UNIX系统有两个版本的fork()
+ exec()系统调用的工作方式通常是，如果线程调用exec()系统调用，则exec()的参数中指定的程序将替换调用进程，包括其所有线程。
    + 如果在fork()之后立即调用exec()，fork()的进程只需要复制调用线程。
        + 不需要复制所有线程，因为exec()的参数中指定的程序将替换调用进程
    + 否则，fork的进程在fork之后不会调用exec()，它应该复制调用进程的所有线程

一个建议是，尽量避免在多线程编程中使用fork()函数

+ 验证实验**alg.13-6-fork-pthread-demo1.c**

执行程序命令：

    gcc alg.13-6-fork-pthread-demo1.c -pthread
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/13.png)

可以看到，在与a.out有关的子进程中的进程中，pid=22828, spid=22162的进程为父进程，pid=22829, spid=22162的为父进程中在创建子进程之前创建的线程，pid=22830, spid=22828的进程为创建的子进程，说明子进程也复制了父进程的线程

程序一直在打印0，这是由父进程创建的线程所引起的。

实现细节解释：

一开始，程序使用语句```pthread_create(&ptid, NULL, &thread_worker, NULL)```创建了一个线程，线程函数为：

    static void *thread_worker(void *args)
    {
        
        while (1) {
            printf("%d\n", i);
            sleep(1);
        }

        pthread_exit(0);
    }

作用为不停地打印0，这个线程处在父进程中

然后，主函数使用语句```pid_t pid = fork()```创建了一个子进程，在子进程中，将变量i设为1，打印语句```in child```，然后系统调用```ps -l -T```查看父进程，父进程创建的线程，子进程的信息，最后退出。

在父进程中，使用```wait(&pid)```等待子进程结束后，打印语句```in parent```，然后系统调用```ps -l -T```查看父进程，父进程创建的线程，子进程的信息，最后```while (1)```使父进程一直进行，那么父进程之前所创建的线程也会一直进行。

+ 验证实验**alg.13-7-fork-pthread-demo2.c**

执行程序命令：

    gcc alg.13-7-fork-pthread-demo2.c -pthread
    ./a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/14.png)

可以看到，在与a.out有关的子进程中的进程中，pid=23020, spid=22822的进程为父进程，pid=23021, spid=22822的为父进程创建的线程，pid=23022, spid=23020的进程为线程中创建的子进程，说明在线程中创建的子进程复制了作为其父进程的线程和主线程，子进程将其父进程的线程当作了主线程，这会引发一些不可预知的后果

程序一直在交替地打印0和1，打印0是由创建的线程所引起的，打印1是由创建的线程创建的子进程所引起的。

实现细节解释：

一开始，程序使用语句```pthread_create(&ptid, NULL, &thread_worker, NULL)```创建了一个线程，线程函数为：

    static void *thread_worker(void *args)
    {
        pid_t pid = fork();

        if(pid < 0 ) {
            return (void *)EXIT_FAILURE;
        }

        if(pid == 0) { /* child pro */
            i = 1;
            printf("in thread_worker's forked child\n");
            system("ps -l -T | grep a.out");
        }

        sleep(2);

        while (1) {
            printf("%d\n", i); 
            sleep(2);
        }
        
        pthread_exit(0);
    }

在这个线程函数中，可以看到，使用语句```pid_t pid = fork()```在线程中创建了一个进程，在子进程中，设置变量i为1，打印语句```in thread_worker's forked child```，然后系统调用```ps -l -T | grep a.out```查看与a.out有关的进程的信息，然后```sleep(2)```休眠2s，接着不停每隔2s打印一次i的值1。

在父进程中，首先```sleep(2)```休眠2s，接着不停每隔2s打印一次i的值0。

回到主线程中，首先```sleep(2)```休眠2s，打印语句```in start main()```，然后系统调用```ps -l -T | grep a.out```查看与a.out有关的进程的信息，最后```while (1)```使父进程一直进行，那么父进程之前所创建的线程也会一直进行。

如果在主线程中添加一条语句```return 1```：

    int main(void)
    {
        pthread_t ptid;
        pthread_create(&ptid, NULL, &thread_worker, NULL);

        sleep(2) ;
        printf("in start main()\n");
        system("ps -l -T | grep a.out");

        return 1;

        while (1) ;

        pthread_join(ptid, NULL);

        return EXIT_SUCCESS;
    }

执行命令：

    gcc alg.13-7-fork-pthread-demo2.c -pthread
    ./a.out
    pkill -f a.out

分析：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/15.png)

可以看到，pid=23057, spid=22882的为父进程中的主线程，pid=23058, spid=22882的为父进程创建的线程，pid=23059, spid=23057的进程为线程中创建的子进程，说明在线程中创建的子进程复制了作为其父进程的线程和主线程，子进程将其父进程的线程当作了主线程，这会引发一些不可预知的后果

程序不停地打印1，即使按下ctrl+c也无法停止程序，使用ps查看发现pid为23059的线程中创建的子进程仍在执行，只能使用指令```pkill -f a.out```才能停止程序。

实现细节解释：

在主线程中加上了语句```return 1```之后，主线程还未等创建的线程及其创建的子进程结束就直接结束了，这会造成一些不可预知的后果。

### 信号处理

实验内容原理：

+ UNIX系统中使用一个信号来通知进程某个特定事件已经发生：
    + 信号可以同步或异步接收
+ 所有信号应遵循以下模式：
    + 特定事件的发生会产生一个信号。
    + 信号被传送到进程。
    + 信号一旦发出，就必须进行处理。
+ 信号由这两个信号处理程序之一处理
    + 内核运行的默认处理程序
    + 可以重写默认处理程序的用户定义处理程序。
+ 对于单线程，一个信号传递给一个进程。

+ 验证实验**alg.13-8-sigaction-demo.c**

执行程序命令：

    gcc alg.13-8-sigaction-demo.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork10-pictures/16.png)

分析：

程序开始后，准备捕捉信号Ctrl+c，当在终端输入Ctrl+c后，程序捕捉到，进入处理程序，在这段处理程序中，Ctrl+\暂时被屏蔽，信号没用，休眠10s后，处理程序完成，重新取消屏蔽，继续准备捕捉信号Ctrl+c，如果输入的是Ctrl+\，可以直接导致core dumped错误，程序结束。

实现细节解释：

首先定义一个```struct sigaction```类型的变量```newact```，```struct sigaction```类型是一个与检查或修改与指定信号相关联的处理动作相关的结构体。

然后语句```newact.sa_handler = my_handler```，表示设置处理信号函数为用户自定义的```my_handler()```函数。

接着使用```sigemptyset(&newact.sa_mask)```将```newact```的信号集初始化为空，使用```sigaddset(&newact.sa_mask, SIGQUIT)```将信号编号为3的```SIGQUIT```(Ctrl+\\)添加到信号集中，```newact```的参数```sa_flags```设置为默认值0

然后打印语句```now start catching Ctrl+c```，使用函数```sigaction(SIGINT, &newact, NULL)```将信号编号为2的```SIGINT```(Ctrl+c)指定新的信号处理方式```newact```，并进行记录。

最后```while (1)```使进程一直进行。