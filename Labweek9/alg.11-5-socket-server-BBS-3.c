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

