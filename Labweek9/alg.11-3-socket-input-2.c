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
