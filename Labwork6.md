# 操作系统实验报告6

## 实验内容

+ 实验内容：进程间通信—共享内存。
   
    (1)、验证：编译运行课件 Lecture 08 例程代码：
        + Linux 系统调用示例 reader-writer 问题：Algorithms 8-1 ~ 8-3.
        + POSIX API 应用示例 producer-consumer 问题：Algorithms 8-4 ~ 8-5.
    (2)、设计：Alg.8-1 ~ 8-3 示例只解决单字符串的读写。修改程序将共享空间组织成一个结构类型（比如学号、姓名）的循环队列进行 FIFO 操作，采用共享内存变量控制队列数据的同步（参考数据结构课程有关内容）。

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

+ 在头文件**alg.8-0-shmdata.h**中定义必要的数据和结构

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

+ 验证实验**示例 reader-writer 问题：Algorithms 8-1 ~ 8-3**

执行程序命令：

    gcc -o alg.8-2-shmread.o alg.8-2-shmread.c
    gcc -o alg.8-3-shmwrite.o alg.8-3-shmwrite.c
    gcc alg.8-1-shmcon.c
    ./a.out ./alg.8-2-shmread.o

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork6-pictures/1.png)

分析：

实验内容原理：

首先，进程8-1会通过```ftok()```函数获取一个IPC键值，然后使用```shmget()```函数根据之前的IPC键值和一个计划编号创建一个共享内存对象，并获得共享内存的ID值```shmid```，再根据这个共享内存ID值使用```shmat()```函数把共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存，并返回一个类型为```void *```的附加好的共享内存地址给shmptr，将这个```void *```类型的指针shmptr强制转换为```struct shared_struct *```类型的指针并赋给shared之后，就可以将shared看作为一个共享对象在共享内存区进行操作了，一开始shared的成员变量```written```设为0，表示缓冲区可写。

此时进程8-1已经不再需要使用共享内存，所以及时使用```shmdt()```函数使其与共享内存脱离。

通过```vfork()```得到的两个进程8-2 shmread和8-3 shmwrite同时运行，分别充当reader和writer的角色，两个进程都使用```shmget()```和```shmat()```函数附加到同一块共享内存上，进程8-1直到这两个进程运行完再继续运行。

当shared的成员变量```written```为0时，缓冲区可写，充当reader的进程8-2 shmread暂时休眠，充当writer的进程8-3 shmwrite开始执行，利用```fgets()```函数从键盘读入字符串后，将字符串复制到了shared变量的成员变量```mtext```缓冲区中，并将```written```设为1，写结束。

当shared的成员变量```written```为1时，缓冲区可读，充当writer的进程8-3 shmwrite暂时休眠，充当reader的进程8-2 shmread开始执行，将shared变量的成员变量```mtext```缓冲区中的字符串打印出来后，将```written```设为0，读结束。

当写的过程输入的字符串为```end```时，两个进程都使用```shmdt()```函数从共享内存脱离出来。而且都退出，返回父进程8-1执行完毕后，程序结束。

实现细节解释：

**首先执行程序8-1 shmcon：**

首先程序8-1 shmcon作为进程开始运行，一开始确定共享内存```shmsize```大小为```TEXT_NUM * sizeof(struct shared_struct)```，然后打印语句```max record number = 1, shm size = 4100```，表示最大可以记录消息的条数为1，共享内存的大小为4100

然后进入一个条件判断语句，如果```argc < 2```，那么说明编译命令出错，打印```Usage: ./a.out pathname```提示我们补全路径名，以便之后根据文件信息使用ftok()函数建立共享内存ID值，并返回```EXIT_FAILURE```表示异常退出。

如果编译命令正确，那么继续往下执行，这里为了不用之后使用creat()函数建立一个新文件，我的编译命令为```./a.out ./alg.8-2-shmread.o```，因为```alg.8-2-shmread.o```文件已存在，就不需要再创建新文件。将```argv[1]```中的内容即```./alg.8-2-shmread.o```复制到字符型数组```pathname```中，并获取```alg.8-2-shmread.o```中的文件信息，如果获取文件信息失败，进行异常处理，使用```creat(pathname, O_RDWR)```函数在原来文件路径处创建一个新的同名文件，并把creat()函数的返回值赋给ret，如果ret为-1，说明创建失败，使用宏定义```ERR_EXIT("creat()")```打印错误信息和原因，否则打印语句```shared file object created```，说明创建成功。

接着，通过```ftok(pathname, 0x27)```指定系统建立共享内存时的ID值，ftok()函数会根据参数```pathname```的文件信息和序号参数```0x27```的计划编号合成IPC key键值并赋给变量key，从而避免用户使用key值时发生冲突。其中序号参数最多有256个即0x00~0xff（最好不使用0）。如果key值为-1，说明ftok()失败，使用宏定义```ERR_EXIT("shmcon: ftok()")```打印错误信息，否则打印```key generated: IPC key = 27053fb0```，表示生成成功的IPC key键值为```27053fb0```。

接下来，使用```shmget((key_t)key, shmsize, 0666|PERM)```创建一个共享内存对象，并把共享存储的ID作为返回值赋给变量shmid，其中参数```(key_t)key```为转换为```(key_t)```类型的之前通过ftok()函数得到的IPC键值，参数```shmsize```为新建的共享内存大小，参数```0666|PERM)```表示赋给用户、用户组的其它成员、其它用户有的进程对共享内存有读写的权限，如果shmid为-1，说明shmget()失败，使用宏定义```ERR_EXIT("shmcon: shmget()")```打印错误信息，否则打印```shmcon: shmid = 32```，表示生成成功的共享内存ID值为```32```。

然后，使用```shmptr = shmat(shmid, 0, 0)```把共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存，返回类型为```void *```的附加好的共享内存地址给shmptr，其中参数```shmid```是共享内存标识符，第二个参数和第三个参数都是0，代表让内核决定共享内存出现在内存地址的什么位置和共享内存具有可读可写权限。如果shmptr为(void *)-1，说明shmat()失败，使用宏定义```ERR_EXIT("shmcon: shmat()")```打印错误信息，否则打印```shmcon: shared Memory attached at 0x7f0bee26f000```，表示附加好的共享内存地址为```0x7f0bee26f000```。

将(void *)类型的指针shmptr强制转换为(struct shared_struct *)类型的指针并赋给shared，设置shared的成员变量written为0，表示shared的缓冲区可写，然后将格式化后的字符串```ipcs -m | grep '32'```赋给字符型数组cmd_str，打印语句```------ Shared Memory Segments ------```作为分割线，然后使用```system(cmd_str)```进行使用系统调用语句```ipcs -m | grep '32'```，其中```ipcs -m```表示向标准输出中写入一些关于当前共享内存段的信息，```grep '32'```表示查找共享内存段中符合```32```的共享内存，语句```ipcs -m | grep '32'```向标准输出中写入一些关于共享内存ID值为32的共享内存信息，为```0x27053fb0 32         ubuntu     666        4100       1 ```。其中```0x27053fb0```代表IPC键值，```32```代表共享内存ID值，```ubuntu```代表当前用户的用户名，```666```是权限，代表共享内存可读可写，```4100```代表共享内存的大小，```1```代表当前进程允许访问这片共享内存。

接着判断```shmdt(shmptr)```的返回值是否为-1，如果是，则shmdt()失败，使用宏定义```ERR_EXIT("shmcon: shmdt()")```打印错误信息，，否则shmdt()成功，会断开与共享内存附加点的地址，将先前用shamt()附加(attach)好的共享内存脱离(detach)目前的进程。
 
再次使用```system(cmd_str)```进行使用系统调用语句```ipcs -m | grep '32'```，发现这次```0x27053fb0 32         ubuntu     666        4100       0```，最后一项发生变化，从1变成了0，说明当前进程不能访问这片共享内存。

然后将IPC键值变量key的十六进制形式转换为字符串赋给key_str，将```{" ", key_str, 0}```赋给char *类型的argv1[]。

接着，使用vfork()函数创建一个新进程，并把返回值赋给childpid1，如果变量```childpid1```小于0，说明在vfork()的过程中出错，则进行错误处理，使用宏定义```ERR_EXIT("shmcon: 1st vfork()")```打印错误信息。

如果vfork()函数在执行过程中没有出错，则继续判断变量```childpid1```的值，若变量```childpid1```为0，说明是子进程，执行结果为使用```execv("./alg.8-2-shmread.o", argv1)```引发程序8-2 shmread作为进程和父进程8-1 shmcon异步执行。

**第一个vfork()进入执行进程8-2 shmread：**

在进程8-2 shmread中，首先使用```sscanf(argv[1], "%x", &key);```将argv[1]中的内容以整型十六进制形式赋给key_t型变量key，然后打印```shmread: IPC key = 27053fb0```，说明IPC键值为```27053fb0```，和之前在作为父进程的8-1 shmcon中生成IPC键值的一样。

接着使用```shmget((key_t)key, TEXT_NUM*sizeof(struct shared_struct), 0666|PERM);```创建一个共享内存对象，并把共享存储的ID作为返回值赋给变量shmid，其中参数```(key_t)key```为IPC键值```27053fb0```，参数```shmsize```为共享内存大小，参数```0666|PERM)```表示赋给用户、用户组的其它成员、其它用户有的进程对共享内存有读写的权限，如果shmid为-1，说明shmget()失败，使用宏定义```ERR_EXIT("shread: shmget()")```打印错误信息，否则由于之前内核中已经存在与IPC键值```27053fb0```相等的内存，所以返回该共享内存的标识符```32```给shmid。

然后使用```shmat(shmid, 0, 0)```把共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存，返回类型为```void *```的附加好的共享内存地址给shmptr，其中参数```shmid```是共享内存标识符，第二个参数和第三个参数都是0，代表让内核决定共享内存出现在内存地址的什么位置和共享内存具有可读可写权限。如果shmptr为(void *)-1，说明shmat()失败，使用宏定义```ERR_EXIT("shread: shmat()")```打印错误信息，否则打印```shmread: shmid = 32```表示共享内存的标识符为```32```，打印```shmread: shared memory attached at 0x7f179682c000```，表示附加好的共享内存地址为```0x7f179682c000```，打印```shmread process ready ...```表示进程8-2 shmread已经可以访问共享内存。

接着，将(void *)类型的指针shmptr强制转换为(struct shared_struct *)类型的指针并赋给shared，进入一个while循环，当shared的成员变量written为0时，进程进入一个休眠1s的循环，说明消息还没有准备好被读发送，进程8-2要继续等待，直到shared的成员变量written为1，说明shared的缓冲区可以读了，这时退出休眠1s的循环，打印语句```You wrote:```和输入到shared的成员变量mtext中的字符串，然后将shared的成员变量written置为0，表示缓冲区此时可写但不可读，如果之前输入到shared的成员变量mtext中的字符串为```"end"```的话，那么退出整个while循环，输入的为其它字符串则继续循环。

接着判断```shmdt(shmptr)```的返回值是否为-1，如果是，则shmdt()失败，使用宏定义```ERR_EXIT("shread: shmdt()")```打印错误信息，，否则shmdt()成功，会断开与共享内存附加点的地址，将先前用shamt()附加(attach)好的共享内存脱离(detach)目前的进程8-2 shmread。

休眠1s，使用语句```exit(EXIT_SUCCESS)```，表示退出成功，结束进程8-2 shmread。

**第二个vfork()进入执行进程8-3 shmwrite：**

接着在进程8-1 shmcon中，如果变量```childpid1```大于0，说明是父进程，执行结果为使用vfork()函数创建一个新进程，并把返回值赋给childpid2，如果变量```childpid2```小于0，说明在vfork()的过程中出错，则进行错误处理，使用宏定义```ERR_EXIT("shmwrite: 2nd vfork()")```打印错误信息。

如果vfork()函数在执行过程中没有出错，则继续判断变量```childpid2```的值，若变量```childpid2```为0，说明是子进程，执行结果为使用```execv("./alg.8-3-shmwrite.o", argv1)```引发程序8-3 shmwrite作为进程和父进程8-1 shmcon异步执行。

在进程8-3 shmwrite中，先使用```sscanf(argv[1], "%x", &key);```将argv[1]中的内容以整型十六进制形式赋给key_t型变量key，然后打印```shmwrite: IPC key = 27053fb0```，说明IPC键值为```27053fb0```，和之前在作为父进程的8-1 shmcon中生成IPC键值的一样。

接着使用```shmget((key_t)key, TEXT_NUM*sizeof(struct shared_struct), 0666|PERM);```创建一个共享内存对象，并把共享存储的ID作为返回值赋给变量shmid，其中参数```(key_t)key```为IPC键值```27053fb0```，参数```shmsize```为共享内存大小，参数```0666|PERM)```表示赋给用户、用户组的其它成员、其它用户有的进程对共享内存有读写的权限，如果shmid为-1，说明shmget()失败，使用宏定义```ERR_EXIT("shmwrite: shmget()")```打印错误信息，否则由于之前内核中已经存在与IPC键值```27053fb0```相等的内存，所以返回该共享内存的标识符```32```给shmid。

然后使用```shmat(shmid, 0, 0)```把共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存，返回类型为```void *```的附加好的共享内存地址给shmptr，其中参数```shmid```是共享内存标识符，第二个参数和第三个参数都是0，代表让内核决定共享内存出现在内存地址的什么位置和共享内存具有可读可写权限。如果shmptr为(void *)-1，说明shmat()失败，使用宏定义```ERR_EXIT("shmwrite: shmat()")```打印错误信息，否则打印```shmwrite: shmid = 32```表示共享内存的标识符为```32```，打印```shmwrite: shared memory attached at 0x7fd1e6b06000```，表示附加好的共享内存地址为```0x7fd1e6b06000```，打印```shmwrite process ready ...```表示进程8-3 shmread已经可以访问共享内存。

接着，将(void *)类型的指针shmptr强制转换为(struct shared_struct *)类型的指针并赋给shared，进入一个while循环，当shared的成员变量written为1时，进程进入一个休眠1s的循环，说明消息还没有准备好读入，进程8-3要继续等待，直到shared的成员变量written为0，说明shared的缓冲区可以写了，这时退出休眠1s的循环，打印语句```Enter some text:```，用```fgets(buffer, BUFSIZ, stdin)```语句从标准输入即键盘读入内容到可读长度为```BUFSIZ```的字符型数组```buffer```中，然后用```strncpy(shared->mtext, buffer, TEXT_SIZE)```将buffer中最大长度为```TEXT_SIZE```的内容复制到shared的成员变量mtext中，接着打印语句```shared buffer:```和mtext中的内容，设置将shared的成员变量written置为1，表示缓冲区此时可读但不可写，如果buffer中的字符串为```"end"```的话，那么退出整个while循环。

接着判断```shmdt(shmptr)```的返回值是否为-1，如果是，则shmdt()失败，使用宏定义```ERR_EXIT("shmwrite: shmdt()")```打印错误信息，否则shmdt()成功，会断开与共享内存附加点的地址，将先前用shamt()附加(attach)好的共享内存脱离(detach)目前的进程8-3 shmwrite。使用语句```exit(EXIT_SUCCESS)```，表示退出成功，结束进程8-3 shmwrite。

若变量```childpid2```大于0，说明是父进程，执行结果为使用语句```wait(&childpid1)```和```wait(&childpid2)```等待子进程8-2 shmread和子进程8-3 shmwrite执行完再继续执行，此时共享内存的ID值可以被任意知道IPC键值的进程删除，等待子进程执行完后，判断```shmctl(shmid, IPC_RMID, 0)```的返回值是否为-1，如果是，则shmctl()失败，使用宏定义```ERR_EXIT("shmcon: shmctl(IPC_RMID)")```打印错误信息，否则shmctl()成功，释放标识符为32的共享内存区，再次使用```system(cmd_str)```语句尝试向标准输出中写入一些关于共享内存ID值为32的共享内存信息，结果并没有任何输出，最后打印```nothing found ...```。

最后使用语句```exit(EXIT_SUCCESS)```，表示退出成功，结束进程8-1 shmcon。

![](http://stugeek.gitee.io/operating-system/Labwork6-pictures/2.jpg)

从上图可以看到，三个进程使用的共享内存IPC键值都为```0x27053fb0```，说明使用的是同一块共享内存。

![](http://stugeek.gitee.io/operating-system/Labwork6-pictures/3.jpg)

可以看到，三个进程附加到共享内存的地址都不同，说明不同进程附加到同一块共享内存的共享内存地址不一定相同。

![](http://stugeek.gitee.io/operating-system/Labwork6-pictures/4.jpg)

三次使用```system(cmd_str)```语句尝试向标准输出中写入一些关于共享内存ID值为32的共享内存信息，第一次进程8-1 shmcon使用shmat()语句附加到了共享内存，可以看到信息的最后一项为1，说明当前进程8-1 shmcon可以访问共享内存，第二次进程8-1 shmcon使用shmdt()语句脱离共享内存，可以看到信息的最后一项为0，说明当前进程8-1 shmcon不能访问共享内存，最后8-1 shmcon使用shmctl()语句释放了共享内存区，可以看到没有任何信息，说明共享内存已经被释放了。

+ 验证实验**示例 producer-consumer 问题：Algorithms 8-4 ~ 8-5**

执行程序命令：

    gcc alg.8-4-shmpthreadcon.c -lrt
    gcc -o alg.8-5-shmproducer.o alg.8-5-shmproducer.c -lrt
    gcc -o alg.8-6-shmconsumer.o alg.8-6-shmconsumer.c -lrt
    ./a.out myshm

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork6-pictures/5.png)

分析：

实验内容原理：

首先，进程8-4会使用```shm_open(argv[1], O_CREAT|O_RDWR, 0666)```语句创建一个共享内存对象```/dev/shm/myshm```。

然后通过```vfork()```得到的两个进程8-5 shmproducer和8-6 shmconsumer同时运行，分别充当producer和consumer的角色，两个进程都使用```shm_open()```函数对同一个共享内存对象进行操作，然后使用```mmap()```函数在进程虚拟内存地址空间中分配地址空间，创建和物理内存的映射关系，从而对同一块共享内存进行操作，进程8-4直到这两个进程运行完再继续运行。

充当producer的进程8-5 shmproducer把自己的字符串```message_0```里的内容赋给共享内存对象，充当consumer的进程8-6 shmconsumer从共享内存对象中打印，得到同一份内容，然后两个进程都退出返回父进程8-4执行完毕后，程序结束。

实现细节解释：

**首先执行程序8-4 shmpthreadcon：**

首先程序8-4 shmpthreadcon作为进程开始运行，进入一个条件判断语句，如果```argc < 2```，那么说明编译命令出错，打印```Usage: ./a.out pathname```提示我们补全路径名，以便之后根据文件信息使用ftok()函数建立共享内存ID值，并返回```EXIT_FAILURE```表示异常退出。

如果编译命令正确，那么继续往下执行，使用```shm_open(argv[1], O_CREAT|O_RDWR, 0666)```语句创建一个共享内存对象，权限为可读可写，其中```O_CREAT```表示若文件不存在则创建它，权限为```0666```指定的可读可写，```O_RDWR```表示可读可写，并把返回值赋给变量fd，如果fd为-1，表示shm_open()失败，使用宏定义```ERR_EXIT("con: shm_open()")```打印错误信息，否则将```/dev/shm/filename```作为共享内存对象，如果这个文件不存在那么创建它。因为在编译命令中```./a.out myshm```，所以```filename```为```myshm```，```/dev/shm/myshm```为共享内存对象。

程序继续向下运行，系统调用命令```ls -l /dev/shm/```，使用```ls -l```命令查看```/dev/shm/```目录下的文件信息，可以看到，第一行的```total```为0，代表该目录下所有文件所占空间的总和为0，接下来是该目录下唯一一个文件即共享内存对象myshm一个7个字段的列表```-rw-rw-r-- 1 ubuntu ubuntu 0 3月  30 10:57 myshm```，其中```-rw-rw-r--```表示该文件是一个普通文件，用户和用户组的其他成员对该文件有读写的权限，其他用户只有读的权限，```1```代表这个文件只有一个文件名，只有一个指向该链接的硬链接，```ubuntu ubuntu```表示文件拥有者和文件拥有者所在组，```0```代表文件所占用的空间，```3月  30 10:57```表示文件最近访问或修改时间，```myshm```表示文件名。

接着，确定共享内存```shmsize```大小为```TEXT_NUM * sizeof(struct shared_struct)```，然后使用```ftruncate(fd, shmsize)```语句，将参数fd指定的文件大小改为参数shmsize指定的大小，并把返回值赋给ret，如果ret的值为-1，则ftruncate()失败，使用宏定义```ERR_EXIT("con: ftruncate()")```打印错误信息，否则继续向下。

将```{" ", argv[1], 0}```赋给char *类型的argv1[]。

接着，使用vfork()函数创建一个新进程，并把返回值赋给childpid1，如果变量```childpid1```小于0，说明在vfork()的过程中出错，则进行错误处理，使用宏定义```ERR_EXIT("shmpthreadcon: 1st vfork()")```打印错误信息。

如果vfork()函数在执行过程中没有出错，则继续判断变量```childpid1```的值，若变量```childpid1```为0，说明是子进程，执行结果为使用```execv("./alg.8-5-shmproducer.o", argv1)```引发程序8-5 shmproducer作为进程和父进程8-4 shmpthreadcon异步执行。

**第一个vfork()进入执行进程8-5 shmproducer：**

在进程8-5 shmproducer中，首先定义一个const char *类型字符串message_0为```Hello World!```，然后使用```shm_open(argv[1], O_RDWR, 0666)```把```/dev/shm/myshm```作为共享内存对象，权限为可读可写，并把返回值赋给fd，如果fd值为-1，说明shm_open()失败，使用宏定义```ERR_EXIT("con: shm_open()")```打印错误信息，否则向下执行。

接着，确定共享内存```shmsize```大小为```TEXT_NUM * sizeof(struct shared_struct)```，然后使用```(char *)mmap(0, shmsize, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0)```在进程虚拟内存地址空间中分配地址空间，创建和物理内存的映射关系，其中第一个参数```0```表示由系统决定映射区的起始地址，第二个参数```shmsize```代表映射区的长度，第三个参数```PROT_READ|PROT_WRITE ```表示内容可读可写，第四个参数```MAP_SHARED```表示与其它所有映射这个对象的进程共享映射空间，第五个参数```fd```是先前的文件描述词，第六个参数```0```代表被映射对象内容的起点，并把返回值被映射区的指针赋给shmptr，如果shmptr的值为(void *)-1，则mmap()失败，使用宏定义```ERR_EXIT("producer: mmap()")```打印错误信息，否则继续向下。

将message_0的内容以标准格式赋给shmptr，接着打印语句```produced message:```和shmptr中的字符串，这里是```produced message: Hello World!```，最后使用语句```exit(EXIT_SUCCESS)```，表示退出成功，结束进程8-5 shmproducer。

**第二个vfork()进入执行进程8-6 shmconsumer：**

接着在进程8-4 shmpthreadcon中，如果变量```childpid1```大于0，说明是父进程，执行结果为使用vfork()函数创建一个新进程，并把返回值赋给childpid2，如果变量```childpid2```小于0，说明在vfork()的过程中出错，则进行错误处理，使用宏定义```ERR_EXIT("shmpthreadcon: 2nd vfork()")```打印错误信息。

如果vfork()函数在执行过程中没有出错，则继续判断变量```childpid2```的值，若变量```childpid2```为0，说明是子进程，执行结果为使用```execv("./alg.8-6-shmconsumer.o", argv1)```引发程序8-6 shmconsumer作为进程和父进程8-4 shmpthreadcon异步执行。

在进程8-6 shmconsumer中，先使用```shm_open(argv[1], O_RDONLY, 0444)```把```/dev/shm/myshm```作为共享内存对象，权限为只可读，并把返回值赋给fd，如果fd值为-1，说明shm_open()失败，使用宏定义```ERR_EXIT("consumer: shm_open()")```打印错误信息，否则向下执行。

接着，确定共享内存```shmsize```大小为```TEXT_NUM * sizeof(struct shared_struct)```，然后使用```(char *)mmap(0, shmsize, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0)```在进程虚拟内存地址空间中分配地址空间，创建和物理内存的映射关系，其中第一个参数```0```表示由系统决定映射区的起始地址，第二个参数```shmsize```代表映射区的长度，第三个参数```PROT_READ```表示内容只可读，第四个参数```MAP_SHARED```表示与其它所有映射这个对象的进程共享映射空间，第五个参数```fd```是先前的文件描述词，第六个参数```0```代表被映射对象内容的起点，并把返回值被映射区的指针赋给shmptr，如果shmptr的值为(void *)-1，则mmap()失败，使用宏定义```ERR_EXIT("consumer: mmap()")```打印错误信息，否则继续向下。

打印语句```consumed message:```和shmptr中的字符串，这里是```consumed message: Hello World!```，最后使用语句```exit(EXIT_SUCCESS)```，表示退出成功，结束进程8-6 shmconsumer。

若变量```childpid2```大于0，说明是父进程，执行结果为使用语句```wait(&childpid1)```和```wait(&childpid2)```等待子进程8-5 shmproducer和子进程8-6 shmconsumer执行完再继续执行，此时共享内存对象可以被任意知道文件名的进程删除，等待子进程执行完后，判断```shm_unlink(argv[1])```的返回值是否为-1，如果是，则shm_unlink()失败，使用宏定义```ERR_EXIT("con: shm_unlink()")```打印错误信息，否则shm_unlink()成功，释放共享内存，删除之前的共享内存对象```myshm```文件，再次使用```system(ls -l /dev/shm/)```，使用```ls -l```命令查看```/dev/shm/```目录下的文件信息，结果显示该目录下文件所占空间的总大小为0，没有任何文件。

最后使用语句```exit(EXIT_SUCCESS)```，表示退出成功，结束进程8-6 shmconsumer。
