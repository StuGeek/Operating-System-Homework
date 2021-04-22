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
