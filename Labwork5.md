# 操作系统实验报告5

## 实验内容

+ 实验内容：进程的创建和终止。
    + 编译运行课件 Lecture 06 例程代码：Algorithm 6-1 ~ 6-6.

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

+ 验证实验**alg.6-1-fork-demo.c**

源代码：

    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/types.h>
    #include <unistd.h>
    #include <sys/wait.h>

    int main(void)
    {
        int count = 1;
        pid_t childpid;
        
        childpid = fork(); /* child duplicates parent’s address space */
        if (childpid < 0) {
            perror("fork()");
            return EXIT_FAILURE;
        }
        else /* fork() returns 2 values: 0 for child pro and childpid for parent pro */
            if (childpid == 0) { /* This is child pro */
                count++;
                printf("Child pro pid = %d, count = %d (addr = %p)\n", getpid(), count, &count); 
            }
            else { /* This is parent pro */
                printf("Parent pro pid = %d, child pid = %d, count = %d (addr = %p)\n", getpid(), childpid, count, &count);
                sleep(5);
                wait(0); /* waiting for all children terminated */
            }
        printf("Testing point by %d\n", getpid()); /* child executed this statement and became defunct before parent wait() */
        return EXIT_SUCCESS;
    }

执行程序命令：

    gcc alg.6-1-fork-demo.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/1.png)

分析：

实验内容原理：

fork()函数会创建一个新进程，即子进程，这个子进程直接拷贝父进程的数据段、代码段、堆、栈，父子进程并不共享这些存储空间，子进程有独立的地址空间，子进程和父进程一样都启动一个从fork系统调用之后的下一条指令开始执行的线程，父子进程的执行次序是不确定的。

fork()函数成功调用一次返回两次，一次在子进程中返回，一次在父进程中返回，返回的两个值，子进程返回0，父进程返回子进程的进程号ID，调用出错返回-1。

实现细节解释：

程序一开头，首先```int count = 1```声明变量count为1

然后```pid_t childpid```和```childpid = fork()```使用fork()函数创建一个新进程，这个新建的子进程直接拷贝父进程的数据段和代码段，返回一个进程号并把这个进程号赋给pid_t进程号类型变量```childpid```

接下来是选择分支语句，如果变量```childpid```小于0，说明在fork()的过程中出错，则进行错误处理，将错误原因```"fork()"```函数出错输出到标准设备(stderr)，并返回```EXIT_FAILURE```代表异常退出。

如果fork()函数在执行过程中没有出错，则继续进入一个判断变量```childpid```值的选择分支语句，若变量```childpid```为0，说明是子进程，执行结果为变量```count```自增，打印当前进程的进程号（即子进程），变量```count```的值及其虚拟地址；

若变量```childpid```大于0，说明是父进程，执行结果为直接打印当前进程的进程号（即父进程），变量```childpid```（子进程ID），变量```count```的值及其虚拟地址，然后使用```sleep(5)```让父进程休眠5s，并用```wait(0)```让父进程等待所有子进程结束后再执行，这样就保证了父进程再子进程结束之后再执行。

跳出这个判断一个进程是子进程还是父进程的分支语句后，无论是子进程还是父进程，程序都会执行一个打印测试点语句```Testing point by```，打印当前进程的进程号，并返回```EXIT_SUCCESS```代表正常退出。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/2.jpg)

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/3.jpg)

从上图可以看到，子进程中的变量count与父进程中的变量count具有相同的虚拟地址，但是子进程中的count值与父进程中的count值不同，这是因为fork()得到的子进程具有独立的地址空间，子进程中的count变量被映射到了和父进程不同的物理地址，所以子进程中的count变量的值变为2后，并没有影响父进程中count变量的值仍为1。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/4.jpg)

从上图可以看到，父进程的进程号为6452，子进程的进程号为6453，```Testing point by```后面接的数字是当前执行进程的进程号，可以看到，进程号为6453的进程先执行完打印测试点语句，然后进程号为6452的进程再执行打印测试点语句，即先执行的是子进程，子进程执行完后，父进程再执行，由父进程的选择分支语句中的```sleep(5)```和```wait(0)```保证了这一执行先后顺序。

+ 验证实验**alg.6-2-vfork-demo.c**

源代码：

    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/types.h>
    #include <unistd.h>
    #include <sys/wait.h>

    int main(void)
    {
        int count = 1;
        pid_t childpid;
        
        childpid = vfork(); /* child shares parent’s address space */
        if (childpid < 0) {
            perror("fork()");
            return EXIT_FAILURE;
        }
        else /* vfork() returns 2 values: 0 for child pro and childpid for parent pro */
            if (childpid == 0) { /* This is child pro, parent hung up until child exit ...  */
                count++;
                printf("Child pro pid = %d, count = %d (addr = %p)\n", getpid(), count, &count); 
                printf("Child taking a nap ...\n");
                sleep(5);
                printf("Child waking up!\n");
                _exit(0); /* or exec(0); "return" will cause stack smashing */
            }
            else { /* This is parent pro, start when the vforked child finished */
                printf("Parent pro pid = %d, child pid = %d, count = %d (addr = %p)\n", getpid(), childpid, count, &count);
                wait(0); /* not waitting this vforked child terminated*/
            }
        printf("Testing point by %d\n", getpid()); /* executed by parent pro only */
        return EXIT_SUCCESS;
    }

执行程序命令：

    gcc alg.6-2-vfork-demo.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/5.png)

分析：

实验内容原理：

vfork()函数会创建一个新进程，即子进程，这个子进程直接共享父进程的数据段，并且将父进程挂起，保证先执行子进程，在调用exec函数或_exit函数之前和父进程数据是共享的，在它调用exec函数或_exit函数之后父进程才会被恢复调度运行。

和fork()函数一样，vfork()函数成功调用一次返回两次，一次在子进程中返回，一次在父进程中返回，返回的两个值，子进程返回0，父进程返回子进程的进程号ID，调用出错返回-1。

实现细节解释：

程序一开头，首先```int count = 1```声明变量count为1

然后```pid_t childpid```和```childpid = vfork()```使用vfork()函数创建一个新进程，这个新建的子进程共享父进程的数据段，并将父进程挂起，返回一个进程号并把这个进程号赋给pid_t进程号类型变量```childpid```

接下来是选择分支语句，如果变量```childpid```小于0，说明在vfork()的过程中出错，则进行错误处理，将错误原因输出到标准设备(stderr)，并返回```EXIT_FAILURE```代表异常退出。

如果vfork()函数在执行过程中没有出错，则继续进入一个判断变量```childpid```值的选择分支语句，若变量```childpid```为0，说明是子进程，执行结果为变量```count```自增，打印当前进程的进程号（即子进程），变量```count```的值及其虚拟地址，再打印```Child taking a nap ...```，使用```sleep(10)```语句让子进程休眠10s，此时父进程并没有执行，说明父进程被挂起，等待子进程调用exec或_exit函数后才接着执行，接着打印```Child waking up!```，最后使用```_exit(0)```直接退出子进程，同时使父进程恢复执行，跳过了最后的打印测试点```Testing point by```语句；

若变量```childpid```大于0，说明是父进程，执行结果为直接打印当前进程的进程号（即父进程），变量```childpid```（子进程ID），变量```count```的值及其虚拟地址，然后使用```wait(0)```让父进程等待所有子进程结束后再执行。

跳出这个判断一个进程是子进程还是父进程的分支语句后，程序会执行一个打印语句，打印当前进程的进程号，并返回```EXIT_SUCCESS```代表正常退出。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/6.jpg)

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/7.jpg)

子进程中的变量count与父进程中的变量count具有相同的虚拟地址。子进程的count值与父进程的count值相同，它们共享同一存储空间，被映射到同一物理地址。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/8.jpg)

父进程被挂起，直到vfork的子进程执行了execv函数才继续执行。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/9.jpg)

子进程在```Testing point by```语句之前就退出，只有父进程执行了这一打印语句。

+ 验证实验**alg.6-3-fork-demo-nowait.c**

源代码：

    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/types.h>
    #include <unistd.h>
    // #include <sys/wait.h>

    int main(void)
    {
        int count = 1;
        pid_t childpid;
        
        childpid = fork(); /* child duplicates parent’s address space */
        if (childpid < 0) {
            perror("fork()");
            return EXIT_FAILURE;
        }
        else
            if (childpid == 0) { /* This is child pro */
                count++;
                printf("child pro pid = %d, count = %d (addr = %p)\n", getpid(), count, &count); 
                printf("child sleeping ...\n");
                sleep(10); /* parent exites during this period and child became an orphan */
                printf("\nchild waking up!\n");
            }
            else { /* This is parent pro */
                printf("Parent pro pid = %d, child pid = %d, count = %d (addr = %p)\n", getpid(), childpid, count, &count);
            }
        printf("\nTesting point by %d\n", getpid()); /* executed both by parent and child */
        return EXIT_SUCCESS;
    }

执行程序命令：

    gcc alg.6-3-fork-demo-nowait.c
    ./a.out

    ps -l

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/10.png)

分析：

实验内容原理：

使用fork()函数创建一个新的子进程，但不在父进程的选择分支语句中使用```wait(0)```语句保证父进程在子进程结束后执行，从而观察父进程和fork()创建出的子进程的执行次序。

实现细节解释：

程序一开头，首先```int count = 1```声明变量count为1

然后```pid_t childpid```和```childpid = fork()```使用fork()函数创建一个新进程，这个新建的子进程直接拷贝父进程的数据段和代码段，返回一个进程号并把这个进程号赋给pid_t进程号类型变量```childpid```

接下来是选择分支语句，如果变量```childpid```小于0，说明在fork()的过程中出错，则进行错误处理，将错误原因输出到标准设备(stderr)，并返回```EXIT_FAILURE```代表异常退出。

如果fork()函数在执行过程中没有出错，则继续进入一个判断变量```childpid```值的选择分支语句，若变量```childpid```为0，说明是子进程，执行结果为变量```count```自增，打印当前进程的进程号（即子进程），变量```count```的值及其虚拟地址，再打印```child sleeping ...```，使用```sleep(10)```语句让子进程休眠10s，此时因为父进程中没有```wait(0)```语句，父进程不会等待子进程执行终止再执行，所以父进程会在子进程休眠的这段时间执行，最后打印```child waking up!```；

若变量```childpid```大于0，说明是父进程，执行结果为直接打印当前进程的进程号（即父进程），变量```childpid```（子进程ID），变量```count```的值及其虚拟地址

跳出这个判断一个进程是子进程还是父进程的分支语句后，无论是子进程还是父进程，程序都会执行一个打印语句，打印当前进程的进程号，并返回```EXIT_SUCCESS```代表正常退出。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/11.jpg)

从上图可以看到，输入```ps -l```后，因为子进程中间休眠了10s，父进程中没有```wait(0)```语句，已经执行完后终止，剩下一个子进程处于休眠状态，变成孤儿进程，进程号pid=6951。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/12.jpg)

从上图可以看到，在什么都没有输入的情况下，进程号为6951的孤儿进程重新工作，打印```child waking up!```和```Testing point by```语句，说明终端（bash）和分叉子级是异步工作的。

+ 验证实验**alg.6-4-fork-demo-wait.c**

源代码：

    #include <stdio.h>
    #include <stdlib.h>
    #include <sys/types.h>
    #include <unistd.h>
    #include <sys/wait.h>

    int main(void)
    {
        int count = 1;
        pid_t childpid, terminatedid;
        
        childpid = fork(); /* child duplicates parent’s address space */
        if (childpid < 0) {
            perror("fork()");
            return EXIT_FAILURE;
        }
        else
            if (childpid == 0) { /* This is child pro */
                count++;
                printf("child pro pid = %d, count = %d (addr = %p)\n", getpid(), count, &count); 
                printf("child sleeping ...\n");
                sleep(5); /* parent wait() during this period */
                printf("\nchild waking up!\n");
            }
            else { /* This is parent pro */
                terminatedid = wait(0);
                printf("Parent pro pid = %d, terminated pid = %d, count = %d (addr = %p)\n", getpid(), terminatedid, count, &count);
            }
        printf("\nTesting point by %d\n", getpid()); /* executed first by child and then parent */
        return EXIT_SUCCESS;
    }

执行程序命令：

    gcc alg.6-4-fork-demo-wait.c
    ./a.out

    ps

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/13.png)

分析：

实验内容原理：

使用fork()函数创建一个新的子进程，且在父进程的选择分支语句中使用```wait(0)```语句保证父进程在子进程结束后执行，并将```wait(0)```的返回值，即最后一个终止的子进程的进程号，赋给一个进程号类型pid_t变量```terminatedid```，再观察父进程和fork()创建出的子进程的执行次序。

实现细节解释：

程序一开头，首先```int count = 1```声明变量count为1

然后```pid_t childpid```和```childpid = fork()```使用fork()函数创建一个新进程，这个新建的子进程直接拷贝父进程的数据段和代码段，返回一个进程号并把这个进程号赋给pid_t进程号类型变量```childpid```

接下来是选择分支语句，如果变量```childpid```小于0，说明在fork()的过程中出错，则进行错误处理，将错误原因输出到标准设备(stderr)，并返回```EXIT_FAILURE```代表异常退出。

如果fork()函数在执行过程中没有出错，则继续进入一个判断变量```childpid```值的选择分支语句，若变量```childpid```为0，说明是子进程，执行结果为变量```count```自增，打印当前进程的进程号（即子进程），变量```count```的值及其虚拟地址，再打印```child sleeping ...```，使用```sleep(5)```语句让子进程休眠5s，此时因为父进程中有```wait(0)```语句，父进程会等待子进程执行终止再执行，所以父进程不会在子进程休眠的这段时间执行，最后打印```child waking up!```；

若变量```childpid```大于0，说明是父进程，执行结果为使用```wait(0)```函数，使子进程全部执行完后再执行父进程，并将返回值最后一个终止的子进程的进程号赋给一个进程号类型pid变量```terminatedid```，打印当前进程的进程号（即父进程），变量```terminatedid```，变量```count```的值及其虚拟地址

跳出这个判断一个进程是子进程还是父进程的分支语句后，无论是子进程还是父进程，程序都会执行一个打印语句，打印当前进程的进程号，并返回```EXIT_SUCCESS```代表正常退出。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/14.jpg)

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/15.jpg)

从上图可以看到，父进程等待子进程执行完语句```Testing point by```，正常返回终止后，```wait(0)```将最后一个终止的子进程的进程号7357返回给变量```terminatedid```后，再执行程序，输入```ps```可以看到，子进程和父进程都结束终止了。

+ 验证实验**alg.6-5-0-sleeper.c**

源代码：

    #include <stdio.h>
    #include <stdlib.h>
    #include <unistd.h>

    int main(int argc, char* argv[])
    {
        int secnd = 5;

        if (argc > 1) {
            secnd = atoi(argv[1]);
            if ( secnd <= 0 || secnd > 10)
                secnd = 5;
        }
        
        printf("\nsleeper pid = %d, ppid = %d\nsleeper is taking a nap for %d seconds\n", getpid(), getppid(), secnd); /* ppid - its parent pro id */

        sleep(secnd);
        printf("\nsleeper wakes up and returns\n");

        return 0;
    }

执行程序命令：

    gcc alg.6-5-0-sleeper.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/16.png)

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/17.png)

分析：这是一个程序开始后，打印当前进程的pid，ppid的值和休眠秒数secnd的值，然后休眠secnd秒后，再继续执行，打印出```sleeper wakes up and returns```的简单程序。

+ 验证实验**alg.6-5-vfork-execv-wait.c**

源代码：

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <sys/types.h>
    #include <unistd.h>
    #include <sys/stat.h>
    #include <wait.h>

    int main(int argc, char* argv[])
    {
        pid_t childpid;

        childpid = vfork();
            /* child shares parent's address space */
        if (childpid < 0) {
            perror("fork()");
            return EXIT_FAILURE;
        }
        else
            if (childpid == 0) { /* This is child pro */
                printf("This is child, pid = %d, taking a nap for 2 seconds ...\n", getpid());
                sleep(2); /* parent hung up and do nothing */

                char filename[80];
                struct stat buf;
                strcpy(filename, "./alg.6-5-0-sleeper.o");
                if(stat(filename, &buf) == -1) {
                    perror("\nsleeper stat()");
                    _exit(0);
                }
                char *argv1[] = {filename, argv[1], NULL};
                printf("child waking up and again execv() a sleeper: %s %s\n\n", argv1[0], argv1[1]); 
                execv(filename, argv1);
    /* parent resume at the point 'execv' called. The vforked pro terminated and alg.6-5-sleeper.o spawned as child in the same childpid but with duplicated address space and returns to parent without any stack smashing. parent and child execute asynchronously */
            }
            else { /* This is parent pro, start when the vforked child terminated */
                printf("This is parent, pid = %d, childpid = %d \n", getpid(), childpid);
                    /* parent executed this statement during the EXECV time */
                int retpid = wait(0); 
                    /* without wait(), the spawned EXECV may became an orphan */
                printf("\nwait() returns childpid = %d\n", retpid);
            }
            
        return EXIT_SUCCESS;
    }

执行程序命令：

    gcc alg.6-5-vfork-execv-wait.c
    ./a.out

    ps -l

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/18.png)

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/20.png)

分析：

实验内容原理：

vfork()函数会创建一个新进程，即子进程，这个子进程直接共享父进程的数据段，并且将父进程挂起，保证先执行子进程，在调用exec函数或_exit函数之前和父进程数据是共享的，在它调用exec函数或_exit函数之后父进程才会被恢复调度运行。如果在vfork函数创建的子进程中使用了exec函数引发了一个新进程，那么这个新进程会继承原来的vfork出的子进程的进程号，新进程的父进程也为原来子进程的父进程，这个新进程并不与父进程共享一片存储空间，而是拥有独立的地址空间，并和父进程异步执行，但父进程中使用了```wait(0)```，所以父进程会等待这个新的子进程执行完后，再执行终止。

实现细节解释：

首先```pid_t childpid```和```childpid = vfork()```使用vfork()函数创建一个新进程，这个新建的子进程共享父进程的数据段，返回一个进程号并把这个进程号赋给pid_t进程号类型变量```childpid```

接下来是选择分支语句，如果变量```childpid```小于0，说明在vfork()的过程中出错，则进行错误处理，将错误原因输出到标准设备(stderr)，并返回```EXIT_FAILURE```代表异常退出。

如果vfork()函数在执行过程中没有出错，则继续进入一个判断变量```childpid```值的选择分支语句，若变量```childpid```为0，说明是子进程，打印当前进程的进程号（即子进程）和语句```taking a nap for 2 sencods```，使用```sleep(2)```语句让子进程休眠2s后继续执行，此时因为父进程被挂起，所以父进程并不会执行。

然后声明一个字符型数组，将字符串```"./alg.6-5-0-sleeper.o"```复制到这个数组中，并获取这个字符串代表的文件路径的文件信息，如果获取文件信息失败，进行错误处理，将错误原因输出到标准设备(stderr)，并直接结束进程，否则打印出```"./alg.6-5-0-sleeper.o"```文件路径名和这个文件sleeper休眠秒数，```execv(filename, argv)```引发```"./alg.6-5-0-sleeper.o"```的文件sleeper作为新的子进程执行，同时父进程在```execv()```这个函数被调用后重新进行，和新的子进程异步执行。

若变量```childpid```大于0，说明是父进程，执行结果为直接打印当前进程的进程号（即父进程），然后使用```wait(0)```，并把返回值最后一个结束的子进程的进程号赋给整型变量```retpid```，让父进程等待所有子进程结束后再执行，最后打印```retpid```。

跳出这个判断一个进程是子进程还是父进程的分支语句后，返回```EXIT_SUCCESS```代表正常退出。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/19.jpg)

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/33.jpg)

可以看到，在原来子进程休眠结束并调用了```execv()```函数引发了一个新的子进程sleeper，父进程也恢复执行后，新的子进程和父进程```wait(0)```之前的语句异步执行，并不能判断执行的先后次序，有时候是父进程先执行完，有时候是sleeper先执行完。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/21.jpg)

从上图可以看出，原来的子进程调用了```execv()```后产生的新的子进程sleeper继承了原来vfork出的子进程的进程号pid（7715），它们的父进程进程号都为7714，说明新的子进程sleeper的父进程是原来vfork出的子进程的父进程。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/22.jpg)

从上图可以看出，父进程在调用execv函数后重新运行，vfork出的子进程终止，sleeper被引发后作为新的子进程和之前的子进程有同一个进程号7715，也具有重复的地址空间，并且返回到父进程时，没有任何堆栈损坏。父进程和新的子进程异步执行。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/23.jpg)

无论如何，父进程需要等待它的子进程执行完终止后再执行，不然原来的子进程引发的sleeper进程作为新的子进程可能会变成孤儿进程。

+ 验证实验**alg.6-6-vfork-execv-nowait.c**

源代码：

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <sys/types.h>
    #include <unistd.h>
    #include <sys/stat.h>
    #include <wait.h>

    int main(int argc, char* argv[])
    {
        pid_t childpid;

        childpid = vfork();
            /* child shares parent's address space */
        if (childpid < 0) {
            perror("fork()");
            return EXIT_FAILURE;
        }
        else
            if (childpid == 0) { /* This is child pro */
                printf("This is child, pid = %d, taking a nap for 2 seconds ... \n", getpid());
                sleep(2); /* parent hung up and do nothing */

                char filename[80];
                struct stat buf;
                strcpy(filename, "./alg.6-5-0-sleeper.o");
                if(stat(filename, &buf) == -1) {
                    perror("\nsleeper stat()");
                    _exit(0);
                }
                char *argv1[] = {filename, argv[1], NULL};
                printf("child waking up and again execv() a sleeper: %s %s\n\n", argv1[0], argv1[1]);
                execv(filename, argv); /* parent resume at the point 'execv' called */
            }
            else { /* This is parent pro, start when the vforked child terminated */
                printf("This is parent, pid = %d, childpid = %d \n",getpid(), childpid);
                    /* parent executed this statement during the EXECV time */
                printf("parent calling shell ps\n");
                system("ps -l");
                sleep(1);
                return EXIT_SUCCESS;
                    /* parent exits without wait() and child may become an orphan */
        }
    }

执行程序命令：

    gcc alg.6-6-vfork-execv-nowait.c
    ./a.out

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/24.png)

分析：

实验内容原理：

vfork()函数会创建一个新进程，即子进程，这个子进程直接共享父进程的数据段，并且将父进程挂起，保证先执行子进程，在调用exec函数或_exit函数之前和父进程数据是共享的，在它调用exec函数或_exit函数之后父进程才会被恢复调度运行。如果在vfork函数创建的子进程中使用了exec函数引发了一个新进程，那么这个新进程会继承原来的vfork出的子进程的进程号，新进程的父进程也为原来子进程的父进程，这个新进程并不与父进程共享一片存储空间，而是拥有独立的地址空间，并和父进程异步执行，这次父进程中不使用```wait(0)```，那么由于执行次序不确定，所以新的子进程sleeper有可能成为孤儿进程，观察父进程和新的子进程sleeper的执行情况。

实现细节解释：

首先```pid_t childpid```和```childpid = vfork()```使用vfork()函数创建一个新进程，这个新建的子进程共享父进程的数据段，返回一个进程号并把这个进程号赋给pid_t进程号类型变量```childpid```

接下来是选择分支语句，如果变量```childpid```小于0，说明在vfork()的过程中出错，则进行错误处理，将错误原因输出到标准设备(stderr)，并返回```EXIT_FAILURE```代表异常退出。

如果vfork()函数在执行过程中没有出错，则继续进入一个判断变量```childpid```值的选择分支语句，若变量```childpid```为0，说明是子进程，打印当前进程的进程号（即子进程）和语句```taking a nap for 2 sencods```，使用```sleep(2)```语句让子进程休眠2s后继续执行，此时因为父进程被挂起，所以父进程并不会执行。

然后声明一个字符型数组，将字符串```"./alg.6-5-0-sleeper.o"```复制到这个数组中，并获取这个字符串代表的文件路径的文件信息，如果获取文件信息失败，进行错误处理，将错误原因输出到标准设备(stderr)，并直接结束进程，否则打印出```"./alg.6-5-0-sleeper.o"```文件路径名和sleeper休眠秒数，```execv(filename, argv)```引发```"./alg.6-5-0-sleeper.o"```的文件sleeper作为新的子进程执行，同时父进程在```execv()```这个函数被调用后重新进行，和新的子进程异步执行。

若变量```childpid```大于0，说明是父进程，执行结果为直接打印当前进程的进程号（即父进程），打印```parent calling shell ps```并使用系统调用命令```system("ps -l")```直接查看和bash相关的进程，然后使用```sleep(1)```语句让父进程休眠1s后继续执行，返回```EXIT_SUCCESS```代表正常退出。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/25.jpg)

从上图可以看到，bash的父进程的进程号pid为6106，start main()的父进程的父进程的进程号ppid也为6106,说明bash是start main()的父进程。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/26.jpg)

而start main()的父进程的进程号pid为8961，从vfork出的子进程中的execv()语句引发的sleeper进程的父进程的父进程的进程号ppid也为8961,说明start main()是sleeper的父进程。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/27.jpg)

start main()的父进程的进程号pid和system()父进程的父进程的进程号ppid相同，都为为8961，说明start main()是system()的父进程。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/28.jpg)

system()的父进程的进程号pid和system("ps -l")父进程的父进程的进程号ppid相同，都为为8963，说明system()是system("ps -l")的父进程。

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/29.jpg)

start main()终止且控制权移交给了bash，从终端再输入```"ps -l"```

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/30.jpg)

可以看到，由于父进程中没有使用```wait(0)```，所以父进程在sleeper进程执行完前就终止了，sleeper成为了孤儿进程，又被进程号为1348的进程所收养作为子进程

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/31.jpg)

终端(bash)和sleeper进程异步执行

![](http://stugeek.gitee.io/operating-system/Labwork5-pictures/32.jpg)

进程号为1348的进程是"systemd"的守护进程(代替了"init")
