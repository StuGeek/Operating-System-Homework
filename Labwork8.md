# 操作系统实验报告8

## 实验内容

+ 实验内容1：进程间通信—消息机制

    + 编译运行课件 Lecture 09 例程代码：

        + Algorithms 9-1 ~ 9-2.
        
        + 修改代码，观察在 msgsnd 和 msgrcv 并发执行情况下消息队列的变化情况。

+ 实验内容2：

    + 仿照 alg.8-4~8-6，编制基于 POSIX API 的进程间消息发送和消息接收例程。

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### 实验内容1：进程间通信—消息机制

+ 验证实验**Algorithms 9-1 ~ 9-2**

分析：

实验内容原理：

消息队列是在消息的传输过程中保存消息的容器，消息被发送到队列中，消息队列管理器在将消息从它的源中继到它的目标时充当中间人。队列的主要目的是提供路由并保证消息的传递；如果发送消息时接收者不可用，消息队列会保留消息，直到可以成功地传递它，可以传送多种类型的数据，但是有大小限制。

首先，进程9-1 msgsnd会根据一个IPC 键值使用```msgget()```函数，创建一个消息队列，然后使用```msgctl()```函数获取和设置消息队列的属性，再使用```msgsnd()```函数向消息队列中发送信息，这些消息每条包含一个消息类型号和消息内容，进程9-1 msgsnd结束后，发送的消息还留在消息队列中，并没有被释放。

然后，进程9-2 msgrcv会根据同一个IPC 键值使用```msgget()```函数获取之前创建的同一个消息队列，然后使用```msgctl()```函数获取和设置消息队列的属性，再使用```msgrcv()```函数从消息队列中根据消息类型号获取信息，每次将选择的消息类型号的所有信息获取出来，如果消息类型号为0，那么将消息队列中的全部信息获取出来，并弹出提示是否要删除这个空的消息队列，若是则该消息队列被释放，当消息队列中还有信息时，进程9-2 msgrcv结束并不会释放消息队列，消息队列中的消息也不会被删除。

**首先执行文件alg.9-1-msgsnd.c**

执行程序命令：

    gcc alg.9-1-msgsnd.c
    ./a.out /home/ubuntu/myshm

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork8-pictures/1.png)

实现细节解释：

首先进入一个条件判断语句，如果```argc < 2```，那么说明编译命令出错，打印```Usage: ./a.out pathname```提示我们补全路径名，以便之后根据文件信息使用ftok()函数获得IPC 键值，并返回```EXIT_FAILURE```表示异常退出。

如果编译命令正确，那么继续往下执行，如果获取文件信息失败，进行异常处理，使用```creat(pathname, O_RDWR)```函数在原来文件路径处创建一个新的同名可读可写文件，并把creat()函数的返回值赋给ret，如果ret为-1，说明创建失败，使用宏定义```ERR_EXIT("creat()")```打印错误信息和原因，否则打印语句```shared file object created```，说明创建成功。

接着，通过```ftok(pathname, 0x27)```获得一个IPC 键值，ftok()函数会根据参数```pathname```的文件信息和序号参数```0x27```的计划编号合成IPC key键值并赋给变量key，从而避免用户使用key值时发生冲突。如果key值小于0，说明ftok()失败，使用宏定义```ERR_EXIT("ftok()")```打印错误信息，否则打印```IPC key = 0x```后面跟生成的IPC 键值，显示生成的IPC 键值。

接下来，使用```msgget((key_t)key, 0666 | IPC_CREAT)```创建一个新的或者打开一个已经存在的消息队列，这个消息队列与key值相对应，并把队列标识符作为返回值赋给变量msqid，其中参数```(key_t)key```为转换为```(key_t)```类型的之前通过ftok()函数得到的IPC键值，参数```(0666 | IPC_CREAT)```表示进程对消息队列可读可写，```IPC_CREAT```表示如果消息队列不存在，便创建消息队列，否则就进行打开操作。

如果msqid的值为-1，说明msgget()失败，使用宏定义```ERR_EXIT("msgget()")```打印错误信息，否则继续向下。

然后使用```fopen("./msgsnd.txt", "rb")```以只读方式打开目录下的二进制文件```alg.9-0-msgsnd.txt```，并把指向该文件流的指针赋给fp，如果fp为空指针，说明fopen()失败，文件打开失败，使用宏定义```ERR_EXIT("source data file: ./msgsnd.txt fopen()")```打印错误信息，否则继续向下。

接着，声明一个```struct msqid_ds```类型的消息队列管理结构体变量```msqattr```，使用```msgctl(msqid, IPC_STAT, &msqattr)```获取和设置消息队列的属性，这个函数与共享内存的shmctl函数相似，其中参数```msqid```是队列标识符，参数```IPC_STAT```表示把后一个参数```&msqattr```中的数据设置为消息队列的当前关联值，函数的返回值赋给ret。

然后打印消息队列中存有的信息条数以及消息队列中还剩下的空位数目。

接着进入一个while循环，检测文件指针fp指向的文件流，如果文件结束，那么结束while循环。进入while循环后，一开始执行```fscanf(fp, "%ld %s", &msg_type, buffer);```语句，将文件每一行中开头的数字输入进msg_type，后面的姓名字符串输入到buffer，并把fscanf函数的返回值赋给ret，如果ret变量等于EOF，说明文件已经到末尾了，退出while循环，否则继续。

打印msg_type和buffer中的内容，即文件中每一行的消息类型号和字符串信息，把msg_type赋给```struct msg_struct```类型变量data的成员变量msg_type，把buffer赋给data的成员变量mtext，使用语句```msgsnd(msqid, (void *)&data, TEXT_SIZE, 0)```将消息写入消息队列中，其中参数```msqid```是消息队列的标识符，参数```data```可以是任何类型的结构体，第一个字段为long类型，表明此发送消息的类型，参数```TEXT_SIZE```表示要发送的消息的大小，最后一个参数```0```表示当消息队列满时，函数将会阻塞，直到消息能写进消息队列，并把返回值赋给ret，如果ret为-1，说明msgsnd()失败，使用宏定义```ERR_EXIT("msgsnd()")```打印错误信息，否则继续向下，统计发送消息总条数的```count```加一，继续执行while循环。

从while循环退出后，打印发送消息的总条数，关闭文件指针fp指向的文件流，使用系统命令```ipcs -q```查看使用消息队列进行进程间通信的信息，最后```exit(EXIT_SUCCESS)```正常退出。

**执行文件alg.9-2-msgrcv.c**

执行程序命令：

    gcc -o b.out alg.9-2-msgrcv.c
    ./b.out /home/ubuntu/myshm 2

    ./b.out /home/ubuntu/myshm 0

实现细节解释：

首先进入一个条件判断语句，如果```argc < 2```，那么说明编译命令出错，打印```Usage: ./b.out pathname msg_type```提示我们补全路径名，以便之后根据文件信息使用ftok()函数获得IPC 键值，并返回```EXIT_FAILURE```表示异常退出。

如果编译命令正确，那么继续往下执行，如果获取文件信息失败，进行异常处理，使用宏定义```ERR_EXIT("shared file object stat error")```打印错误信息，否则继续向下执行。

接着，通过```ftok(pathname, 0x27)```获得一个IPC 键值，ftok()函数会根据参数```pathname```的文件信息和序号参数```0x27```的计划编号合成IPC key键值并赋给变量key，从而避免用户使用key值时发生冲突。如果key值小于0，说明ftok()失败，使用宏定义```ERR_EXIT("ftok()")```打印错误信息，否则继续向下执行，打印```IPC key = 0x```后面跟生成的IPC 键值，显示生成的IPC 键值。

接下来，使用```msgget((key_t)key, 0666)```创建一个新的或者打开一个已经存在的消息队列，这个消息队列与key值相对应，并把队列标识符作为返回值赋给变量msqid，其中参数```key```为IPC键值，后一个参数为```0666```，而不是```(0666 | IPC_CREAT)```，因为之前已经创建过一个消息队列了，所以不用再创建一个新的消息队列了。

如果msqid的值为-1，说明msgget()失败，使用宏定义```ERR_EXIT("msgget()")```打印错误信息，否则继续向下。

如果```argc < 3```，那么说明没有指定```msgtype```变量的值，那么默认该值为0，否则将```argv[2]```中的值赋给```msgtype```变量，如果这个值小于0，那么```msgtype```变量的值赋为0，打印语句```Selected message type = ```和```msgtype```的值，显示```msgtype```的值。

接着进入一个while循环，，一开始执行```msgrcv(msqid, (void *)&data, TEXT_SIZE, msgtype, IPC_NOWAIT)```语句，从消息队列中读取消息，然后把此消息从消息队列中删除，其中参数```msqid```是消息队列的标识符，参数```data```是存放消息的结构体，结构体类型要与msgsnd()函数发送的类型相同，参数```TEXT_SIZE```表示要接收的消息的大小，参数```msgtype```为0时表示接收第一个消息，大于0表示接收等于```msgtype```的第一个消息，最后一个参数```IPC_NOWAIT```表示如果没有返回条件的信息调用立即返回，函数返回值赋给ret，如果ret为-1，说明该种```msgtype```类型的信息已经读取完了，打印读取的信息数，并退出while循环，否则继续执行。打印读取到的消息的消息类型号和内容，代表读取的信息数量的```count```变量数值加一，继续while循环。

退出while循环后，声明一个```struct msqid_ds```类型的变量```msqattr```，然后使用```msgctl(msqid, IPC_STAT, &msqattr)```获取和设置消息队列的属性，把参数```&msqattr```中的数据设置为消息队列的当前关联值，函数的返回值赋给ret。

打印此时消息队列中存有的消息条数，如果消息条数等于0，打印语句```do you want to delete this msg queue?(y/n)```，并进入选择判断语句```if (getchar() == 'y')```，如果接下来输入的字符为```'y'```，那么使用```msgctl(msqid, IPC_RMID, 0)```语句删除消息队列，如果函数的返回值为-1，说明msgctl()失败，使用```perror("msgctl(IPC_RMID)")```打印错误信息，否则继续向下。

使用系统命令```ipcs -q```打印使用消息队列进行进程间通信的信息，最后```exit(EXIT_SUCCESS)```正常退出。

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork8-pictures/2.png)

可以看到，当输入的msgtype值为2时，消息队列中两个msgtype值为2的消息被取出，消息队列中的消息数从8变成6，当输入的msgtype值为0时，因为每次都会不区分类型地将消息队列中的第一条消息取出，所以最后全部消息被取出，消息队列为空，输入'y'删除这个空的消息队列。

+ 修改代码，观察在 msgsnd 和 msgrcv 并发执行情况下消息队列的变化情况。

实验内容原理：

首先，进程msgsnd先被执行，使用一个文件路径名和整数标识符通过ftok()获得一个IPC键值，利用这个IPC键值创建一个消息队列，然后使用vfork()和execv()将创建IPC键值时使用的文件路径名传给msgrcv进程，msgrcv进程通过同样的文件路径名和整数表标识符获得同样的IPC键值，通过这个IPC键值获得同一个消息队列。

此时msgrcv进程和msgsnd进程并发执行，在父进程msgsnd进程中，每休眠2s，向消息队列发送一次消息，在子进程msgrcv进程中，每休眠3s，从消息队列中读取一次消息，消息队列中的消息被一边写一边读，写的速度比读快，不会出现先读完还有消息未写入进程msgrcv就退出的情况。

当最后消息写完时，msgsnd进程的while循环先退出，消息不再写入，等待msgrcv进程结束，到了消息读完时，msgrcv进程的while循环退出，弹出提示是否删除消息队列的提示，进行完操作后，msgrcv进程结束，然后msgsnd进程结束，程序退出。

执行程序命令：

    gcc -o msgrcv.o msgrcv.c
    gcc msgsnd.c
    ./a.out /home/ubuntu/myshm

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork8-pictures/3.png)

![](http://stugeek.gitee.io/operating-system/Labwork8-pictures/4.png)

分析：

可以看到，当有消息写入消息队列时，消息队列的消息数加一，当有消息从消息队列中读出时，消息队列的消息数减一。

### 实验内容2：仿照 alg.8-4~8-6，编制基于 POSIX API 的进程间消息发送和消息接收例程。

实验内容原理：

基于 POSIX API 的进程间消息发送和消息接收使用消息队列进行，首先要在程序中包含头文件```#include <mqueue.h>```，在这个头文件中：

    #include <bits/types.h>

    typedef int mqd_t;

    struct mq_attr
    {
    __syscall_slong_t mq_flags;	/* Message queue flags.  */
    __syscall_slong_t mq_maxmsg;	/* Maximum number of messages.  */
    __syscall_slong_t mq_msgsize;	/* Maximum message size.  */
    __syscall_slong_t mq_curmsgs;	/* Number of messages currently queued.  */
    __syscall_slong_t __pad[4];
    };

可以看到```mqd_t```类型实际为```int```型，消息队列属性mq_attr的结构中，```__syscall_slong_t```实际上为```long```型，所有的成员变量都为长整型，```mq_flags```代表消息队列的标志，```0```为阻塞模式，```O_NONBLOCK```为非阻塞模式，```mq_maxmsg```代表最大消息数，```mq_msgsize```代表每个消息最大的字节数，```mq_curmsgs```代表当前的消息数目。

使用POSIX标准规定的函数在进程操作消息队列，相关的函数有：

    mq_open()用于打开或创建一个消息队列。

    mq_getattr()用于获取当前消息队列的属性

    mq_send()用于向消息队列中写入一条消息

    mq_receive()用于从消息队列中读取一条消息

    mq_close()用于关闭一个消息队列

    mq_unlink()用于删除一个消息队列

实现细节解释：

首先在进程msgpthreadcon中使用语句```mq_open(pathname, O_CREAT|O_RDWR, 0666, 0)```根据文件路径名创建一个可读可写的消息队列，其中参数
```pathname```为消息队列的名字，```O_CREAT|O_RDWR```为打开的方式，这里为可读可写，没有则创建，```0666```代表默认访问权限为可读可写，```0```代表采取默认属性。然后创建msgproducer和msgconsumer两个子进程，并发执行，实现通信，同时把创建消息队列时用到的文件路径名传给这两个进程。

**在进程msgproducer中：**

在进程msgproducer中，首先使用语句```mq_open(argv[1], O_RDWR, 0666)```根据和父进程相同的文件路径名获取同一个消息队列，然后声明一个```struct mq_attr```的变量mqAttr，用来获取消息队列的属性。

然后进入一个while循环，在while循环中，每次一开始便使用```mq_getattr(mqid, &mqAttr)```获取消息队列的属性到mqAttr，如果消息队列中还有消息，那么每次进程休眠1s，等待消息读出后再读入消息，从键盘读入消息到字符型数组buffer后，使用```mq_send(mqid, buffer, mqAttr.mq_msgsize, 0)```函数将buffer中的内容送到消息队列，其中参数```mqid```为消息队列的标识符，```buffer```为要传送的内容，```mqAttr.mq_msgsize```消息的长度，```0```为消息的优先级，这里表示不设置优先级。

如果输入的消息为```"end"```，那么退出循环，使用```mq_close(mqid)```关闭消息队列，退出进程。

**在进程msgconsumer中：**

首先使用语句```mq_open(argv[1], O_RDWR, 0666)```根据和父进程相同的文件路径名获取之前创建的消息队列，然后声明一个```struct mq_attr```的变量mqAttr，用来获取消息队列的属性。

然后进入一个while循环，在while循环中，每次一开始便使用```mq_getattr(mqid, &mqAttr)```获取消息队列的属性到mqAttr，如果消息队列中没有消息，那么每次进程休眠1s，等待消息写入后再读出消息，使用```mq_receive(mqid, buffer, mqAttr.mq_msgsize, 0)```函数将消息队列中的消息读入字符型数组buffer中，其中参数```mqid```为消息队列的标识符，```buffer```为要读入的字符型数组，```mqAttr.mq_msgsize```消息的长度，```0```为消息的优先级，这里表示不设置优先级。

如果读出的消息为```"end"```，那么退出循环，使用```mq_close(mqid)```关闭消息队列，退出进程。

两个进程都执行完后，回到进程msgpthreadcon重新执行，使用语句```mq_unlink(argv[1])```删除消息队列，程序退出。

执行程序命令：

    gcc msgpthreadcon.c -lrt
    gcc -o msgproducer.o msgproducer.c -lrt
    gcc -o msgconsumer.o msgconsumer.c -lrt
    ./a.out /mymsg

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork8-pictures/5.png)

分析：

可以看到，Producer输入什么，Consumer就输出什么，每次输入的内容和输出的内容一样，实现了Prodecer和Consumer之间的通信，当输入的内容为```end```时，通信程序结束。