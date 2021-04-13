//msgpthreadcom.c文件
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <mqueue.h>

#include "alg.9-0-msgdata.h"

int main(int argc, char *argv[])
{
    char pathname[80];
    mqd_t mqid;
    int ret;
    pid_t childpid1, childpid2;

    if(argc < 2) {
        printf("Usage: ./a.out filename\n");
        return EXIT_FAILURE;
    }
    strcpy(pathname, argv[1]);

    mqid = mq_open(pathname, O_CREAT|O_RDWR, 0666, 0);  //根据文件路径名创建消息队列
    if (mqid == -1) {
        ERR_EXIT("msgpthreadcon: mq_open()");
    }
    
    char *argv1[] = {" ", argv[1], 0};  //用于向自子进程传递文件路径名以获取同一个消息队列
    
    //创建producer和consumer两个子进程，并发执行，实现通信
    childpid1 = vfork();
    if(childpid1 < 0) {
        ERR_EXIT("msgpthreadcon: 1st vfork()");
    } 
    else if(childpid1 == 0) {
        execv("./msgproducer.o", argv1);
    }
    else {
        childpid2 = vfork();
        if(childpid2 < 0) {
            ERR_EXIT("msgpthreadcon: 2nd vfork()");
        }
        else if (childpid2 == 0) {
            execv("./msgconsumer.o", argv1);
        }
        else {
            wait(&childpid1);
            wait(&childpid2);
            //两个子进程执行完后，删掉消息队列
            ret = mq_unlink(argv[1]);
            if(ret == -1) {
                ERR_EXIT("msgpthreadcon: mq_unlink()");
            }
            printf("The program is over\n");
        }
    }
    exit(EXIT_SUCCESS);
}



