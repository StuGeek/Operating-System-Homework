# 操作系统实验报告9

## 实验内容

+ 实验内容：进程间通信—管道和 socket 通信。
    + 编译运行课件 Lecture11 例程代码：
        + alg.11-3-socket-input-2.c
        + alg.11-4-socket-connector-BBS-2.c
        + alg.11-5-socket-server-BBS-3.c


## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### 实验内容：进程间通信—管道和 socket 通信

+ 验证实验**Lecture11 例程代码**

分析：

实验内容原理：

进程间通信—管道和socket通信常用的函数一般在头文件```#include<sys/socket.h>```中里，其中有：

**int socket(int domain, int type, int protocol)**

```socket()```函数的作用是创建一个socket的描述符

其中参数```domain```是协议族，常用的协议有AF_INET(IPV4协议)、AD_INET6(IPV6协议)、AF_UNIX(单一Unix系统中进程间通信)、AF_LOCAL、AF_ROUTE等

```type```是套接口类型，常用值有SOCK_STREAM(流套接字，对应TCP协议)、SOCK_DGRAM(数据报套接字，对应UDP协议)、SOCK_RAW(原始套接字，提供原始网络协议存取)

```protocol```是协议类型，一般取为0，会自动选择```type```类型对应的协议，常用值有IPPROTO_TCP(对应TCP)、IPPROTO_UDP(对应UDP)、IPPROTO_ICMP(对应ICMP)

**int bind(int sockfd, const struct sockaddr \*addr, socklen_t addrlen)**

```bind()```函数的作用是将一个地址族中的特定地址绑定给一套接字

其中参数```sockfd```代表要绑定的套接字的描述符，是之前通过```socket()```函数创建的；

```addr```表示服务器的通信地址，代表指向绑定给```sockfd```的协议地址的结构体；

```addrlen```是参数```addr```的长度，因为```addr```可以接受多种类型的结构体，所以需要```addrlen```额外指定结构体长度

**int getsockname(int sockfd, struct sockaddr \*restrict_addr, socklen_t \*restrict_addrlen)**

```getsockname()```函数的作用获取一个套接字的名字

其中参数```sockfd```代表需要获取名称的套接字的标识符

```restrict_addr```是存放所获取的套接字名称的结构体

```restrict_addrlen```是参数```addr```的长度，因为```addr```可以接受多种类型的结构体，所以需要```addrlen```额外指定结构体长度

**int listen(int sockfd, int backlog)**

在使用socket()、bind()函数建立套接字并绑定后，套接字默认是主动类型，```listen()```函数的作用是监听这个套接字，并把这个套接字变成被动类型，等待来自客户端的连接请求

其中参数```sockfd```代表监听的套接字的描述符

```backlog```表示相应的套接字可以排队的最大连接个数

**int connect(int sockfd, const struct sockaddr \*serv_addr, socklen_t addrlen)**

```connect()```函数的作用是客户端可以通过调用这个函数和服务器发出连接请求建立连接

其中参数```sockfd```代表客户端的socket的描述符

```serv_addr```表示服务器的socket地址

```addrlen```是套接字地址的长度

**int accept(int sockfd, struct sockaddr restrict \*addr, socklen_t restrict \*addrlen)**

```accept()```函数的作用是服务器通过```listen()```函数监听到客户端通过```connect()```函数发出的连接请求后，可以建立连接

其中参数```sockfd```代表服务器的套接字的描述符，也叫监听套接字

```addr```表示客户端的通信地址，存放在一个结构体里

```addrlen```是参数```addr```的长度

**ssize_t send(int sockfd, const void \*buf, socklen_t len, int flags)**

```send()```函数的作用是向一个处在连接状态的套接字发送数据

其中参数```sockfd```代表要发送给的套接字的描述符

```buf```表示存放要发送数据的一个缓冲区

```len```表示缓冲区中要发送的数据的字节数

```flags```是调用执行方式，一般是0，常用值有MSG_CONFIRM(用来告诉链路层)，MSG_DONTWAIT(启用非阻塞操作)，MSG_DONTROUTE(只发送到直接连接的主机上)等。

**ssize_t recv(int sockfd, void \*buf, socklen_t len, int flags)**

```recv()```函数的作用是令服务端或客户端可以从另一端接收数据

其中参数```sockfd```代表接收端的套接字的描述符

```buf```表示存放接收来的数据的一个缓冲区

```len```表示缓冲区中数据的字节数

```flags```表示调用执行方式，一般置0

**int setsockopt(int sockfd, int level, int optname, const void \*optval, socklen_t optlen)**

```setsockopt()```函数的作用是设置一个套接口的选项值

其中参数```sockfd```代表要设置的socket的描述符

```level```代表选项值定义的层次，值包括```SOL_SOCKET```和```IPPROTO_TCP```

```optname```要设置的套接口的选项

```optval```是指向存放设置的选项值的缓冲区，是一个指针

```optlen```是之前的参数```optval```的长度

下面两个函数依赖的头文件为```#include <sys/types.h>```和```#include <ifaddrs.h>```

**int getifaddrs(struct ifaddrs \*\*ifap)**

```getifaddrs()```函数的作用是获取本地网络接口信息，储存在一个链表中，链表的头结点的地址保存在参数```*ifap```中

**void freeifaddrs(struct ifaddrs \*ifap)**

```freeifaddrs()```函数的作用是将之前使用```getifaddrs()```函数动态分配内存获得的参数```ifap```释放掉

**网络编程的基本流程为：**

![](http://stugeek.gitee.io/operating-system/Labwork9-pictures/7.png)

**这次的BBS程序中，服务端部分：**

在```alg.11-5-socket-server-BBS-3.c```程序中，首先使用一个socket()函数创建了一个使用IPV4和TCP协议的套接字server_fd，设置服务端的IP地址和端口号后，使用bind()函数将服务器的地址绑定给套接字，接着使用listen()函数监听是否有来自客户端的连接请求，有请求后，使用accept()函数接收客户端的连接请求并建立连接，建立连接后，使用recv_send_data()函数与客户端使用命名管道进行发送和接收信息，最后使用close()函数关闭管道。

**客户端部分：**

在```alg.11-4-socket-connector-BBS-2.c```程序中，也是首先使用一个socket()函数创建了一个使用IPV4和TCP协议的套接字connect_fd，设置这个客户端的IP地址和端口号后，使用connect()函数向服务端发出连接请求并成功连接之后，创建一个子进程，实现发送消息和接收消息的进程同步进行，同步收发数据，当在```alg.11-3-socket-input-2.c```程序运行后，在其终端输入信息，信息会通过管道传输到connector中，当输入的数据是"#0"或者接收到的数据是"Console: #0"时，退出收发消息的循环，使用close()函数关闭套接字，并退出客户端的进程。

**程序总体结构**:

首先运行```alg.11-5-socket-server-BBS-3.c```程序设置好端口号后建立一个server，server和自己设计的结构控制台Console使用一个命名管道进行通信，管道文件名为test，控制台Console用来输出改名等等信息。

然后建立三个客户端，分别运行```alg.11-4-socket-connector-BBS-2.c```程序和```alg.11-3-socket-input-2.c```程序三次，一个connector和一个input对应，并使用命名管道进行connector和input通信，三个客户端的命名管道文件分别为test1、test2、test3，当有消息从input输入后，会通过命名管道传输到对应的connector中，这三个客户端的connector与服务端server建立连接后进行收发数据，server通过recv_send_data()函数使用匿名管道传送消息，使用的是```fd_msg```，在pipe_data()函数处理完管道信息后，把结果又通过匿名管道```fn[sn]```使用recv_send_data()函数传递到第sn个客户端中，实现聊天通信。

执行程序命令：

    gcc -o server.o alg.11-5-socket-server-BBS-3.c
    gcc -o connector.o alg.11-4-socket-connector-BBS-2.c
    gcc -o input.o alg.11-3-socket-input-2.c

    ./server.o test

    ./connector.o test1
    ./input.o test1

    ./connector.o test2
    ./input.o test2

    ./connector.o test3
    ./input.o test3

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork9-pictures/1.png)

首先在一个终端输入编译命令获得server、connector、input的.o文件，输入```./server.o test```，弹出```input server port number:```的提示后输入```9000```，使BBS的服务端运行起来，可以看到，输出显示```Bind success! Listening ...```，服务端正在等待客户端发送消息

![](http://stugeek.gitee.io/operating-system/Labwork9-pictures/2.png)

然后在另外两个终端分别输入```./connector.o test1```和```./input.o test1```，分别作为同一个客户端的```connector```和```input```，在一个终端输入```./connector.o test1```，提示```Input server's hostname/ipv4: ```时，输入服务端显示的ipv4地址，这里是```192.168.244.128```，然后弹出提示```Input server's port number:```，输入之前在服务端确定的端口号```9000```，客户端就与服务端实现连接，这个```connector```对应的```input```就可以输入消息了。

![](http://stugeek.gitee.io/operating-system/Labwork9-pictures/3.png)

在第一个```connector```对应的```input```中，首先输入```#1xiaoming```，可以看到，服务端中显示第一个```input```对应的```nickname```由匿名```Anonymous```改为了```xiaoming```，同时向第一个```input```对应的```connector```发送```nickname```已经被修改的信息，并在前面加上```Console: ```，提示是控制台信息，不是用户发送的聊天信息

![](http://stugeek.gitee.io/operating-system/Labwork9-pictures/4.png)

在第二个和第三个```connector```中，按照之前开启第一个客户端的步骤开启第二个和第三个客户端，并把第二个客户端的```nickname```命名为```xiaohong```，第三个客户端的```nickname```命名为```xiaogang```。

在第一个```input```中，输入聊天信息```Hello World！```，可以看到，服务端中显示```SN-1: Hello World!```，表示用户1```xiaoming```发送的信息```Hello World！```到达了服务端，然后服务端把信息储存在缓冲区```send_buf```中，接着以广播形式向所有的客户端转发，可以看到，在所有客户端的```connector```中，都显示了信息```xiaoming: Hello World!```

![](http://stugeek.gitee.io/operating-system/Labwork9-pictures/5.png)

测试BBS系统的私聊功能，即输入```@```+客户的```nickname```+消息，可以单独指定这个客户发送消息，其它用户不会收到消息，在第三个```input```中，输入```@xiaoming sayhello!```，表示第三个客户```xiaogang```向客户```nickname```为```xiaoming```的用户发送私聊消息```sayhello!```，可以看到，只有客户1```xiaoming```收到了客户3```xiaogang```发来的```sayhello!```的消息。

![](http://stugeek.gitee.io/operating-system/Labwork9-pictures/6.png)

测试BBS的修改昵称功能，在第三个```input```中，输入```#1xiaowei```，表示第三个客户```xiaogang```的```nickname```改为```xiaowei```，可以看到，服务端在收到改名的请求后，完成改名后，发送消息告诉第三个客户```nickname```已经改为了```xiaowei```。

![](http://stugeek.gitee.io/operating-system/Labwork9-pictures/8.png)

测试BBS的客户端退出功能，在第一个```input```中，输入```#0```，表示第一个客户端退出聊天程序，可以看到，第一个```connector```退出进程，说明断开连接，即使这时再在第一个```input```中输入信息，服务端不会有任何显示，其它客户端也不会收到信息。

实现细节解释：

```

// 文件alg.11-3-socket-input-2.c，充当输入信息并通过管道将信息传输给客户端connector的input角色
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>

#define BUFFER_SIZE 1024

/* input terminal, data packed without '\n' */
/* write to pipe_data() through a named pipe */
int main(int argc, char *argv[])
{
    char fifoname[80], write_buf[BUFFER_SIZE];
    int fdw, flags, ret, i;

    if(argc < 2) {
        printf("Usage: ./a.out pathname\n");
        return EXIT_FAILURE;
    }
    strcpy(fifoname, argv[1]);
    // access()函数用来判断是否有读取文件的权限，其中参数fifoname代表FIFO文件路径名，F_OK用来判断FIFO文件是否存在，如果返回值为-1管道文件不存在，那么创建文件
    if(access(fifoname, F_OK) == -1) {
        // mkfifo()函数用来创建一个命名管道，权限为可读可写，如果返回值不为0，说明创建失败，进行异常处理
        if(mkfifo(fifoname, 0666) != 0) {
            perror("mkfifo()");
            exit(EXIT_FAILURE);
        }
        else
            printf("new fifo %s created ...\n", fifoname);
    }

    // 用open()函数打开一个FIFO文件，其中fifoname是FIFO文件路径名，O_RDWR代表权限可读可写，默认情况下以阻塞模式进行读写，当管道满时阻塞，返回一个FIFO的文件描述符给fdw
    fdw = open(fifoname, O_RDWR);

    // 如果fdw小于0，说明打开管道失败，进行错误处理
    if(fdw < 0) { 
        perror("pipe open()");
        exit(EXIT_FAILURE);
    }
    // 否则打开管道成功
    else {
        // 使用fcntl()函数设置已打开的FIFO文件的文件性质，其中fdw是文件描述符，F_GETFL表示取得fdw对应的文件的打开方式状态标志，最后一个参数可以默认为0
        flags = fcntl(fdw, F_GETFL, 0);
        // 使用fcntl()函数把文件标识符为fdw的FIFO文件的写设置为非阻塞模式，其中F_SETFL表示设置文件打开方式为flags | O_NONBLOCK方式，即之前方式的基础上加上非阻塞方式，当管道满时直接返回-1
        fcntl(fdw, F_SETFL, flags | O_NONBLOCK);
        // 进入循环用于输入信息
        while (1) {
            printf("Enter some text (#0-quit | #1-nickname): \n");
            // 先把用来存放写入信息的缓冲区write_buf清空
            memset(write_buf, 0, BUFFER_SIZE);
            // 从标准输入流即键盘向缓冲区write_buf写入信息
            fgets(write_buf, BUFFER_SIZE, stdin);
            // 在缓冲区的末尾设置0，截断可能溢出的信息
            write_buf[BUFFER_SIZE-1] = 0;
            // 把缓冲区中出现换行符的位置设置为0即结尾，过滤掉换行符
            for (i = 0; i < BUFFER_SIZE; i++) {
            	if(write_buf[i] == '\n') {
                    write_buf[i] = 0;
                }
            }
            // 使用非阻塞方式将缓冲区write_buf中的信息写入命名管道中，并将write()函数的返回值赋给ret
            ret = write(fdw, write_buf, BUFFER_SIZE);
            // 如果ret小于等于0，说明管道已满，暂时阻塞写入，进程睡眠1s后再尝试把信息写入管道
            if(ret <= 0) {
                perror("write()");
                printf("Pipe blocked, try again ...\n");
                sleep(1);
            }
       	}
    }
	
    //使用close()函数关闭管道的文件标识符
    close(fdw);

    exit(EXIT_SUCCESS);
}

```

```

// 文件alg.11-4-socket-connector-BBS-2.c，充当客户端connector角色，用于接收input输入的信息，并与服务端进行收发信息的通信
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/signal.h>
#include <fcntl.h>
#include <sys/stat.h>

#define BUFFER_SIZE 1024
#define NICKNAME_L 11
#define MSG_SIZE BUFFER_SIZE+NICKNAME_L+4
#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)

/* asynchronous send-receive version; separated input terminal*/

int main(int argc, char *argv[])
{
    char fifoname[80], nickname[80];
    int fdr, connect_fd;
    char ip_name_str[INET_ADDRSTRLEN];
    uint16_t port_num;
    char stdin_buf[BUFFER_SIZE], msg_buf[MSG_SIZE];
    int sendbytes, recvbytes, ret;
    char clr;
    struct hostent *host;
    struct sockaddr_in server_addr, connect_addr;
    socklen_t addr_len;
    pid_t childpid;
    
    if(argc < 2) {
        printf("Usage: ./a.out pathname\n");
        return EXIT_FAILURE;
    }
    strcpy(fifoname, argv[1]);
    // access()函数用来判断是否有读取文件的权限，其中参数fifoname代表FIFO文件路径名，F_OK用来判断FIFO文件是否存在，如果返回值为-1管道文件不存在，那么创建文件
    if(access(fifoname, F_OK) == -1) {
        // mkfifo()函数用来创建一个命名管道，权限为可读可写，如果返回值不为0，说明创建失败，进行异常处理
        if(mkfifo(fifoname, 0666) != 0) {
            perror("mkfifo()");
            exit(EXIT_FAILURE);
        }
        else
            printf("new fifo %s named pipe created\n", fifoname);
    }
    
    // 用open()函数打开一个FIFO文件，其中fifoname是FIFO文件路径名，O_RDWR代表权限可读可写，默认情况下以阻塞模式进行读写，返回一个FIFO的文件描述符给fdr
    fdr = open(fifoname, O_RDWR);
    if(fdr < 0) {
        perror("pipe read open()");
        exit(EXIT_FAILURE);
    }

    // www.baidu.com or an ipv4 address
    printf("Input server's hostname/ipv4: ");
    // 输入服务端的主机名或ipv4地址到缓冲区stdin_buf中
    scanf("%s", stdin_buf);
    // 清空输入缓冲区
    while((clr = getchar()) != '\n' && clr != EOF);
    printf("Input server's port number: ");
    // 输入端口号到port_num
    scanf("%hu", &port_num);
    while((clr = getchar()) != '\n' && clr != EOF);

    // 使用gethostbyname()函数通过域名或主机名获取IP地址
    if((host = gethostbyname(stdin_buf)) == NULL) {
        printf("invalid name or ip-address\n");
        exit(EXIT_FAILURE);
    }
    // 打印规范名
    printf("server's official name = %s\n", host->h_name);
    char** ptr = host->h_addr_list;
    for(; *ptr != NULL; ptr++) {
        inet_ntop(host->h_addrtype, *ptr, ip_name_str, sizeof(ip_name_str));
        printf("\tserver address = %s\n", ip_name_str);
    }
    
    // 建立客户端的套接字，使用IPV4和TCP协议
    if((connect_fd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        ERR_EXIT("socket()");
    }
    
    // 设置IP地址类型为IPV4
    server_addr.sin_family = AF_INET;
    // 设置端口号，htons()函数用于将端口号从主机字节顺序变成网络字节顺序
    server_addr.sin_port = htons(port_num);
    // 设置IP地址，从host的成员变量h_addr中获取
    server_addr.sin_addr = *((struct in_addr *)host->h_addr);
    // 将server_addr的成员变量sin_zero的前八个字节清空
    bzero(&(server_addr.sin_zero), 8);

    addr_len = sizeof(struct sockaddr);
    // 使用connect()函数使客户端可以和服务端发出请求建立连接
    ret = connect(connect_fd, (struct sockaddr *)&server_addr, addr_len);
    if(ret == -1) {
        close(connect_fd);
        ERR_EXIT("connect()"); 
    }

    // 客户端和服务端建立连接之后，客户端会被分配一个端口
    addr_len = sizeof(struct sockaddr);
    // 使用getsockname()函数获取客户端的套接字的名字
    ret = getsockname(connect_fd, (struct sockaddr *)&connect_addr, &addr_len);
    if(ret == -1) {
        close(connect_fd);
        ERR_EXIT("getsockname()");
    }
    // 获取客户端被分配的端口号，使用ntohs()函数将一个16位数由网络字节顺序转换为主机字节顺序
    port_num = ntohs(connect_addr.sin_port);
    // 获取客户端的IP地址，使用inet_ntoa()函数将网络地址转换为"."点隔的字符串格式
    strcpy(ip_name_str, inet_ntoa(connect_addr.sin_addr));
    printf("Local port: %hu, IP addr: %s\n", port_num, ip_name_str);
    
    // 获取服务端的IP地址
    strcpy(ip_name_str, inet_ntoa(server_addr.sin_addr));

    // 创建子进程
    childpid = fork();
    if(childpid < 0)
        ERR_EXIT("fork()");
    // 在父进程中
    if(childpid > 0) {
        // 进入一个发数据的循环中
        while(1) { /* sending cycle */
            // 以阻塞方式读从命名管道中读取数据，当管道满时阻塞，数据从终端中输入
            ret = read(fdr, stdin_buf, BUFFER_SIZE);
            if(ret <= 0) {
                perror("read()"); 
                break;
            } 
            stdin_buf[BUFFER_SIZE-1] = 0;
            // 使用send()函数以阻塞方式向客户端的套接字发送数据
            sendbytes = send(connect_fd, stdin_buf, BUFFER_SIZE, 0);
            if(sendbytes <= 0) {
                printf("sendbytes = %d. Connection terminated ...\n", sendbytes);
                break;
            }
            // 如果输入的数据是"#0"，那么清空输入缓冲区，以阻塞方式向客户端的套接字发送消息"I quit ... "，然后退出
            if(strncmp(stdin_buf, "#0", 2) == 0) {
                memset(stdin_buf, 0, BUFFER_SIZE);
                strcpy(stdin_buf, "I quit ... ");
                sendbytes = send(connect_fd, stdin_buf, BUFFER_SIZE, 0);
                break;
            }  
        }
        // 关闭管道
        close(fdr);
        // 关闭套接字
        close(connect_fd);
        // 结束子进程
        kill(childpid, SIGKILL);
    }
    // 在子进程中
    else {
        // 进入一个接收数据的循环中
        while(1) {
            // 使用recv()函数接收套接字的数据并存放到msg_buf中
            recvbytes = recv(connect_fd, msg_buf, MSG_SIZE, 0);
            if(recvbytes <= 0) {
                printf("recvbytes = %d. Connection terminated ...\n", recvbytes);
                break;
            }
            msg_buf[MSG_SIZE-1] = 0;
            // 打印接收到的数据
            printf("%s\n", msg_buf); 
            // 如果传送来的消息是"Console: #0"，那么退出循环
            ret = strncmp(msg_buf, "Console: #0", 11);
            if(ret == 0) {
                break;
            }
        }
        // 关闭套接字
        close(connect_fd);
        // 终止当前进程
        kill(getppid(), SIGKILL);
    }

    return EXIT_SUCCESS;
}

```

```

// 文件alg.11-5-socket-server-BBS-3.c，服务端server角色
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <sys/shm.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <ctype.h>

#define BUFFER_SIZE 1024 /* each pipe has at least 64 blocks for this sze */
#define NICKNAME_L 11 /* 10 chars for nickname */
#define MSG_SIZE BUFFER_SIZE+NICKNAME_L+4 /* msg exchanged between pipe_data() and recv_send_data() */
#define MAX_QUE_CONN_NM 5 /* length of ESTABLISHED queue */
#define MAX_CONN_NUM 10 /* cumulative number of connecting processes */
#define STAT_EMPTY 0
#define STAT_NORMAL 1
#define STAT_ENDED -1

#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)

/* one server, m clients BBS, with private chatting */

struct {
    int stat;
    char nickname[NICKNAME_L];
} sn_attri[MAX_CONN_NUM+1];

int connect_sn, max_sn; /* from 1 to MAX_CONN_NUM */
int server_fd, connect_fd[MAX_CONN_NUM+1];
int fd[MAX_CONN_NUM+1][2];
                /* ordinary pipe: pipe_data() gets max_sn from main() by fd[0][0]
                   recv_send_data(sn) get send_buf from pipe_data() by fd[sn][0], 0<sn<MAX_CONN_NUM+1 */
int fd_stat[2]; /* ordinary pipe: pipe_data() gets stat of connect_sn from main() */
int fd_msg[2];  /* ordinary pipe: pipe_data() gets message of connect_sn from recv_send_data() */
int fdr;   /* named pipe: pipe_data() gets stdin_buf from input terminal */
struct sockaddr_in server_addr, connect_addr;

// 获取ipv4地址，如果是ipv6地址的话也可以获取ipv6地址
int getipv4addr(char *ip_addr)
{
    struct ifaddrs *ifaddrsptr = NULL;
    struct ifaddrs *ifa = NULL;
    void *tmpptr = NULL;
    int ret;
    
    ret = getifaddrs(&ifaddrsptr);
    if(ret == -1)
        ERR_EXIT("getifaddrs()");

    for(ifa = ifaddrsptr; ifa != NULL; ifa = ifa->ifa_next) {
        if(!ifa->ifa_addr) {
            continue;
        }
        if(ifa->ifa_addr->sa_family == AF_INET) { /* IP4 */
            tmpptr = &((struct sockaddr_in *)ifa->ifa_addr)->sin_addr;
            char addr_buf[INET_ADDRSTRLEN];
            inet_ntop(AF_INET, tmpptr, addr_buf, INET_ADDRSTRLEN);
            printf("%s IPv4 address %s\n", ifa->ifa_name, addr_buf);
            if(strcmp(ifa->ifa_name, "lo") != 0)
                strcpy(ip_addr, addr_buf); /* return the ipv4 address */
        } else if(ifa->ifa_addr->sa_family == AF_INET6) { /* IP6 */
            tmpptr = &((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_addr;
            char addr_buf[INET6_ADDRSTRLEN];
            inet_ntop(AF_INET6, tmpptr, addr_buf, INET6_ADDRSTRLEN);
            printf("%s IPv6 address %s\n", ifa->ifa_name, addr_buf);
        }
    }

    if(ifaddrsptr != NULL) {
        freeifaddrs(ifaddrsptr);
    }

    return EXIT_SUCCESS;
}

// 处理管道数据
void pipe_data(void)
{
/* get sidin_buf from input terminal
   update max_sn from main()
   update sn_stat from main() - STAT_EMPTY->STAT_NORMAL
   update sn_stat from recv_send_data() STAT_NORMAL->STAT_ENDED
   update sn_nickname from recv_send_data()
   select connect_sn by the descritor @**** in start of send_buf */

    char send_buf[BUFFER_SIZE], stat_buf[BUFFER_SIZE], stdin_buf[BUFFER_SIZE];
	char msg_buf[MSG_SIZE]; /* sn(4)nickname(10)recv_buff(BUFFER_SIZE) */
    int flags, sn, ret, i, new_stat;
    char nickname[NICKNAME_L];

    // 使用fcntl()函数获得fd[0][0]的文件状态描述符
    flags = fcntl(fd[0][0], F_GETFL, 0);
    // 设置fd[0][0]使用非阻塞状态读取管道，当管道满时直接返回-1
    fcntl(fd[0][0], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking read ord-pipe */
    // 使用fcntl()函数获得fd_stat[0]的文件状态描述符
    flags = fcntl(fd_stat[0], F_GETFL, 0);
    // 设置fd_stat[0]使用非阻塞状态读取管道，当管道满时直接返回-1
    fcntl(fd_stat[0], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking read ord-pipe */
    // 使用fcntl()函数获得fd_msg[0]的文件状态描述符
    flags = fcntl(fd_msg[0], F_GETFL, 0);
    // 设置fd_msg[0]使用非阻塞状态读取管道，当管道满时直接返回-1
    fcntl(fd_msg[0], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking read ord-pipe */
    // 使用fcntl()函数获得fdr的文件状态描述符
    flags = fcntl(fdr, F_GETFL, 0);
    // 设置fdr使用非阻塞状态读取管道，当管道满时直接返回-1
    fcntl(fdr, F_SETFL, flags | O_NONBLOCK); /* set to non-blocking read nam-pipe */

    while(1) { 
        while (1) { /* get the last current max_sn from main() */
            ret = read(fd[0][0], &sn, sizeof(sn)); /* non-blocking read ord-pipe from main() */
            if(ret <= 0) { /* pipe empty */
                break;
            } 
            max_sn = sn;
            printf("max_sn changed to: %d\n", max_sn);
        }

        while (1) { /* update sn_stat from main() */
            ret = read(fd_stat[0], stat_buf, BUFFER_SIZE); /* non-blocking read ord-pipe from main() */
            if(ret <= 0) { /* pipe empty */
                break;
            } 
            sscanf(stat_buf, "%d,%d", &sn, &new_stat);
            printf("SN stat changed: sn = %d, stat: %d -> %d\n", sn, sn_attri[sn].stat, new_stat);
            sn_attri[sn].stat = new_stat;
        }  
	
        while (1) { /* update sn_stat and nickname from recv_send_data(), or brocast msg to all sn */
            ret = read(fd_msg[0], msg_buf, MSG_SIZE); /* non-blocking read ord-pipe from recv_send_data() */
            if(ret <= 0) { /* pipe empty */
                break;
            }
            sscanf(msg_buf, "%4d%s", &sn, stat_buf);
            if(msg_buf[4] == '#') {
                if(msg_buf[5] == '0') { /* #0: terminating the connect_fd */
                    new_stat = STAT_ENDED;
                    printf("SN stat changed: sn = %d, stat: %d -> %d\n", sn, sn_attri[sn].stat, new_stat);
                    sn_attri[sn].stat = new_stat;
                }
                if(msg_buf[5] == '1') { /* #1name: renaming the nickname */
                    strncpy(nickname, &msg_buf[6], NICKNAME_L);
                    for (i = 0; i < NICKNAME_L-1; i++) {
                     	if(nickname[i] == ' ') {
                            nickname[i] = '_';
                        }
                     	if(nickname[i] == '\n') {
                            nickname[i] = 0;
                        }
                    }
                    nickname[i] = 0;
                    printf("SN stat changed: sn = %d, nickname: %s -> %s\n", sn, sn_attri[sn].nickname, nickname);
                    for (i=0; i<=max_sn; i++) { /* sn_attri[0].nickname = "Console" */
                        ret = strcmp(sn_attri[i].nickname, nickname);
                    	if(ret == 0) {
                            memset(msg_buf, 0, MSG_SIZE);
                            sprintf(msg_buf, "Console: this nickname occupied: %s", nickname);
                            ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                            if(ret <= 0) {
                                printf("sn = %d write error, message missed ...\n", sn);
                            }    
                            break;
                        }
                    }
                    if(i > max_sn) {
                        strncpy(sn_attri[sn].nickname, nickname, NICKNAME_L);
                        memset(msg_buf, 0, MSG_SIZE);
                        sprintf(msg_buf, "Console: your nickname changed to %s", sn_attri[sn].nickname);
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                        if(ret <= 0) {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                    }
                }  
                /* ignore the message from recv_send_data() otherwise */
            }
            // 私聊功能，输入@+要私聊的用户的nickname，再输入信息即可
            else if(msg_buf[4] == '@') {
                for (i = 0; i < NICKNAME_L-1; i++) {
                    nickname[i] = msg_buf[5+i];
                    if(msg_buf[5+i] == 0 || msg_buf[5+i] == ' ') {
                    	break;
                    }
                }
                nickname[i] = 0;
                if(msg_buf[5+i] == ' ') {
                    i++;
                }
                strcpy(stdin_buf, &msg_buf[5+i]);

                memset(msg_buf, 0, MSG_SIZE);
                sprintf(msg_buf, "%s@: %s", sn_attri[sn].nickname, stdin_buf);
                for (sn = 1; sn <= max_sn; sn++) { /* message sent to all sn's by ord-pipes fd[sn][1] */
                    if(sn_attri[sn].stat == STAT_NORMAL && strcmp(sn_attri[sn].nickname, nickname) == 0) {
                        flags = fcntl(fd[sn][1], F_GETFL, 0);
                        fcntl(fd[sn][1], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking write ord-pipe */
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                        if(ret <= 0) {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                    }
                }
            }
            else {
                strcpy(stdin_buf, &msg_buf[4]);
                memset(msg_buf, 0, MSG_SIZE);
                sprintf(msg_buf, "%s: %s", sn_attri[sn].nickname, stdin_buf);
                for (sn = 1; sn <= max_sn; sn++) { /* message sent to all sn's by ord-pipes fd[sn][1] */
                    if(sn_attri[sn].stat == STAT_NORMAL) {
                        flags = fcntl(fd[sn][1], F_GETFL, 0);
                        fcntl(fd[sn][1], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking write ord-pipe */
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                        if(ret <= 0) {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                    }
                }
            }
        }

        while (1) { /* read from input terminal and brocast to all sn */
			ret = read(fdr, stdin_buf, BUFFER_SIZE); /* non-blocking read nam-pipe from input terminal */
            if(ret <= 0) {
                break;
            } 
            if(stdin_buf[0] == '@') {
                sn = atoi(&stdin_buf[1]);
                if(sn > 0 && sn <= max_sn && sn_attri[sn].stat == STAT_NORMAL) {
                    for (i = 1; isdigit(stdin_buf[i]); i++) ;
                    if(stdin_buf[i] == '#' && stdin_buf[i+1] == '0') { /* #0: terminating the connect_fd */
                        new_stat = STAT_ENDED;
                        printf("SN stat changed: sn = %d, stat: %d -> %d\n", sn, sn_attri[sn].stat, new_stat);
                        sn_attri[sn].stat = new_stat;
                        memset(msg_buf, 0, MSG_SIZE);
                        sprintf(msg_buf, "%s: %s", sn_attri[0].nickname, "#0 your connection terminated!");
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                        if(ret <= 0) {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                        ;
                    }
                    else {
                        flags = fcntl(fd[sn][1], F_GETFL, 0);
                        fcntl(fd[sn][1], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking write ord-pipe */
                        memset(msg_buf, 0, MSG_SIZE);
                        sprintf(msg_buf, "%s: %s", sn_attri[0].nickname, &stdin_buf[i]);
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                        if(ret <= 0) {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                    }
                }
                ; /* invalid connect_sn ignored */
            } 
            else {
                memset(msg_buf, 0, MSG_SIZE);
                sprintf(msg_buf, "%s: %s", sn_attri[0].nickname, stdin_buf);
                for (sn = 1; sn <= max_sn; sn++) { /* message sent to all sn's by ord-pipes fd[sn][1] */
                    if(sn_attri[sn].stat == STAT_NORMAL) {
                        flags = fcntl(fd[sn][1], F_GETFL, 0);
                        fcntl(fd[sn][1], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking write ord-pipe */
                        ret = write(fd[sn][1], msg_buf, MSG_SIZE); /* non-blocking write ord-pipe */
                        if(ret <= 0) {
                            printf("sn = %d write error, message missed ...\n", sn);
                        }
                    }
                }
            }
        }
    } 
    return;
}

void recv_send_data(int sn)
{
    char recv_buf[BUFFER_SIZE], send_buf[BUFFER_SIZE];
    char msg_buf[MSG_SIZE]; /* sn(4)nickname(10)recv_buff(BUFFER_SIZE) */
    int recvbytes, sendbytes, ret, flags;
    int stat;

    flags = fcntl(connect_fd[sn], F_GETFL, 0);
    fcntl(connect_fd[sn], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking mode to socket recv */
    flags = fcntl(fd[sn][0], F_GETFL, 0);
    fcntl(fd[sn][0], F_SETFL, flags | O_NONBLOCK); /* set to non-blocking mode to ord-pipe read */

    while(1) { /* receiving and sending cycle */
        recvbytes = recv(connect_fd[sn], recv_buf, BUFFER_SIZE, MSG_DONTWAIT); /* non-blocking socket recv */
        if(recvbytes > 0) {
            printf("===>>> SN-%d: %s\n", sn, recv_buf);
            memset(msg_buf, 0, MSG_SIZE);
            sprintf(msg_buf, "%4d%s", sn, recv_buf);
            ret = write(fd_msg[1], msg_buf, MSG_SIZE); /* blocking write ord-pipe to pipe_data() */
            if(ret <= 0) {
                perror("fd_stat write() to pipe_data()");
                break;
            }
        }
        ret = read(fd[sn][0], msg_buf, MSG_SIZE); /* non-blocking read ord-pipe from pipe_data() */
        if(ret > 0) {
            printf("sn = %d send_buf ready: %s\n", sn, msg_buf);
            sendbytes = send(connect_fd[sn], msg_buf, MSG_SIZE, 0); /* blocking socket send */
            if(sendbytes <= 0) {
                break;
            }
        } 
        sleep(1); /* heart beating */
    }
    return;
}


int main(int argc, char *argv[])
{
    socklen_t addr_len;
    pid_t pipe_pid, recv_pid, send_pid;
    char stdin_buf[BUFFER_SIZE], ip4_addr[INET_ADDRSTRLEN];
    uint16_t port_num;
    int ret;
    char fifoname[80], clr;
    int stat;
  
    if(argc < 2) {
        printf("Usage: ./a.out pathname\n");
        return EXIT_FAILURE;
    }
    strcpy(fifoname, argv[1]);
    // access()函数用来判断是否有读取文件的权限，其中参数fifoname代表FIFO文件路径名，F_OK用来判断FIFO文件是否存在，如果返回值为-1管道文件不存在，那么创建文件
    if(access(fifoname, F_OK) == -1) {
        // mkfifo()函数用来创建一个命名管道，权限为可读可写，如果返回值不为0，说明创建失败，进行异常处理
        if(mkfifo(fifoname, 0666) != 0) {
            perror("mkfifo()");
            exit(EXIT_FAILURE);
        }
        else {
            printf("new fifo %s named pipe created\n", fifoname);
        }
    }
    // 用open()函数打开一个FIFO文件，其中fifoname是FIFO文件路径名，O_RDWR代表权限可读可写，默认情况下以阻塞模式进行读写，返回一个FIFO的文件描述符给fdr
    fdr = open(fifoname, O_RDWR);
    // 如果fdw小于0，说明打开管道失败，进行错误处理，否则打开管道成功
    if(fdr < 0) {
        perror("named pipe read open()");
        exit(EXIT_FAILURE);
    }
    
    // 为fd数组中每个元素即管道标识符建立一个管道，如果建立失败，打印错误原因
    for (int i = 0; i <= MAX_CONN_NUM; i++) {
        ret = pipe(fd[i]);
        if(ret == -1) {
            perror("fd pipe()");
        }
    }
   
    // 为fd_stat建立一个管道
    ret = pipe(fd_stat);
    if(ret == -1) {
        perror("fd_stat pipe()");
    }
    
    // 为fd_msg建立一个管道
    ret = pipe(fd_msg);
    if(ret == -1) {
        perror("fd_msg pipe()");
    }

    // 所有客户端的状态都被初始化为STAT_EMPTY空状态，昵称为"Anonymous"匿名
    for (int i = 0; i <= MAX_CONN_NUM; i++) {
        sn_attri[i].stat = STAT_EMPTY;
        strcpy(sn_attri[i].nickname, "Anonymous");
    }

    // 第一个客户端的昵称为"Console"控制台
    strcpy(sn_attri[0].nickname, "Console");
   
    // 使用socket()函数创建一个socket的描述符返回给server_fd，AF_INET代表使用IPV4协议，SOCK_STREAM对应TCP协议，0为自动选择协议类型，这里对应TCP
    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    // 创建失败，就退出程序
    if(server_fd == -1) {
        ERR_EXIT("socket()");
    }
    printf("server_fd = %d\n", server_fd);

    // 获取IPV4地址到ip4_addr中
    getipv4addr(ip4_addr);

    // 输入不超过5位数的服务器端口号到port_num
    printf("input server port number: ");
    memset(stdin_buf, 0, BUFFER_SIZE);
    fgets(stdin_buf, 6, stdin);
    stdin_buf[5] = 0;
    port_num = atoi(stdin_buf);

    // 设置服务端的IP地址类型为IPV4
    server_addr.sin_family = AF_INET;
    // 设置服务端的端口号，htons()函数用于将端口号从主机字节顺序变成网络字节顺序
    server_addr.sin_port = htons(port_num);
    // 设置服务端的IP地址，inet_addr()函数用于将一个点分十进制的IP转换成一个长整型整数
    server_addr.sin_addr.s_addr = inet_addr(ip4_addr);
    // 将server_addr的成员变量sin_zero的前八个字节清空
    bzero(&(server_addr.sin_zero), 8);

    int opt_val = 1;
    // 使用setsockopt()函数设置服务端的套接字使得相同的地址和端口可以被重用
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt_val, sizeof(opt_val));
    
    // 使用bind()函数将服务端的地址绑定给套接字
    addr_len = sizeof(struct sockaddr);
    ret = bind(server_fd, (struct sockaddr *)&server_addr, addr_len);
    // 绑定失败，关闭服务端，退出程序
    if(ret == -1) {
        close(server_fd);
        ERR_EXIT("bind()");    
    }
    printf("Bind success!\n");
    
    // 监听与服务器地址绑定的套接字，等待来自客户端的连接请求，可以排队的最大连接个数为MAX_QUE_CONN_NM
    ret = listen(server_fd, MAX_QUE_CONN_NM);
    // 绑定失败，关闭服务端，退出程序
    if(ret == -1) {
        close(server_fd);
        ERR_EXIT("listen()");
    }
    printf("Listening ...\n");
   
    // 创建管道子进程，实现进程同步
    pipe_pid = fork();
    if(pipe_pid < 0) {
        close(server_fd);
        ERR_EXIT("fork()");
    }
    // 在子进程中使用管道处理数据
    if(pipe_pid == 0) {
        pipe_data();
        exit(EXIT_SUCCESS); /* ignoring all the next statements */
    }

    max_sn = 0;
    connect_sn = 1;
    while (1) {
        // 当连接的客户端进程数超过最大值时，循环结束，退出聊天程序
        if(connect_sn > MAX_CONN_NUM) {
           printf("connect_sn = %d out of range\n", connect_sn);
           break;
        }
        // 每次accept()函数被调用时都要分配一次addr_len的大小
        addr_len = sizeof(struct sockaddr);
        // 服务端通过accept()函数接收第connect_sn个客户端的连接请求后建立连接
        connect_fd[connect_sn] = accept(server_fd, (struct sockaddr *)&connect_addr, &addr_len);
        if(connect_fd[connect_sn] == -1) {
            perror("accept()");
            continue;
        }
        // 获取要连接的客户端的端口号到port_num，ntoh()函数用于将一个16位数由网络字节顺序转换为主机字节顺序
        port_num = ntohs(connect_addr.sin_port);
        // 获取要连接的客户端的地址到ip4_addr，inet_ntoa()函数用于将网络地址转换为"."点隔的字符串格式
        strcpy(ip4_addr, inet_ntoa(connect_addr.sin_addr));
        printf("New connection sn = %d, fd = %d, IP_addr = %s, port = %hu\n", connect_sn, connect_fd[connect_sn], ip4_addr, port_num);
        
        // 将服务端的状态设置为已经和有的客户端建立连接且还可以继续其它客户端建立连接的状态
        stat = STAT_NORMAL;
        sprintf(stdin_buf, "%d,%d", connect_sn, stat);
        // 用缓冲区stdin_buf中的内容设置客户端的状态
        ret = write(fd_stat[1], stdin_buf, sizeof(stdin_buf)); /* blocking write ordinary pipe to pipe_data() */
        if(ret <= 0) {
            perror("fd_stat write() from recv_send_data() to pipe_data()");
        }
		
        // 申请一个用来传输数据的子进程
        recv_pid = fork();
        if(recv_pid < 0) {
            perror("fork()");
            break;
        }
        if(recv_pid == 0) {
            // 子进程用来向客户端接收和发送数据
            recv_send_data(connect_sn);
            exit(EXIT_SUCCESS);
        }
        
        ret = max_sn = connect_sn;
        // 以阻塞方式将数据写入管道，当管道满时阻塞
        write(fd[0][1], &max_sn, sizeof(max_sn));
        if(ret <= 0) {
            perror("fd_stat write() from recv_send_data() to pipe_data()");
        }
        // 连接的客户端数加一
        connect_sn++;
        // 此时父进程继续监听是否有新的客户端请求连接
    }

    wait(0);
    // 关闭所有客户端用到的管道
    for (int sn = 1; sn <= max_sn; sn++) {
        close(connect_fd[sn]);
    }
    // 关闭服务端
    close(server_fd);
    exit(EXIT_SUCCESS);
}

```

## 改进代码：

在实验中，要用到语句```bzero(&(server_addr.sin_zero), 8)```来将server_addr的成员变量sin_zero的前8个字节变成0，但是bzero并不是一个ANSI C函数，而在POSIX.1-2001标准里面，bzero函数已经被标记为了遗留函数，所以不推荐使用，在某些平台或环境下运行可能会出现问题，和memset函数比起来，它唯一的好处是只有两个参数，便于记忆，但是在写程序时，为了更好地遵从规范，最好还是用memset函数代替bzero函数，可以使用宏定义替换程序各处出现的bzero：

    #define bzero(s, n) memset(s, 0, n)
