//msgsnd.c文件
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/msg.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <fcntl.h>
 
#include "alg.9-0-msgdata.h"

int main(int argc, char *argv[])
{
    char pathname[80];
    struct stat fileattr;
    key_t key;
    struct msg_struct data;
    long int msg_type;
    char buffer[TEXT_SIZE];
    int msqid, ret;
    FILE *fp;
    char key_str[10];
    pid_t childpid;

    if(argc < 2) {
        printf("Usage: ./a.out pathname\n");
        return EXIT_FAILURE;
    }
    strcpy(pathname, argv[1]);

    if(stat(pathname, &fileattr) == -1) {
        ret = creat(pathname, O_RDWR);
        if (ret == -1) {
            ERR_EXIT("creat()");
        }
        printf("shared file object created\n");
    }
    
    //获取一个IPC键值
    key = ftok(pathname, 0x27);
    if(key < 0) {
        ERR_EXIT("msgsnd:ftok()");
    }
    
    //根据IPC键值获得一个消息队列标识符
    msqid = msgget((key_t)key, 0666 | IPC_CREAT);
    if(msqid == -1) {
        ERR_EXIT("msgsnd:msgget()");
    }
 
    //以只读方式打开txt文件
    fp = fopen("./alg.9-0-msgsnd.txt", "rb");
    if(!fp) {
        ERR_EXIT("source data file: ./msgsnd.txt fopen()");
    }

    struct msqid_ds msqattr;

    //将IPC键值传递给进程msgrcv
    sprintf(key_str, "%x", key);
    char *argv1[] = {" ", key_str, pathname, 0};

    //使进程msgrcv和进程msgsnd并发执行
    childpid = vfork();
    if (childpid < 0) {
        ERR_EXIT("msgsnd:Vfork()");
    }
    else if (childpid == 0) {
        execv("./msgrcv.o", argv1);
    }
    else {
        //向消息队列中写入消息
        while (!feof(fp)) {
            //每隔2s写入一次消息
            sleep(2);
            ret = fscanf(fp, "%ld %s", &msg_type, buffer);
            //当读到文件尾时，结束读入消息
            if(ret == EOF) {
                break;
            }
            
            //设置要传入消息队列的结构体data的消息类型号和内容
            data.msg_type = msg_type;
            strcpy(data.mtext, buffer);

            //向消息队列中传入消息
            ret = msgsnd(msqid, (void *)&data, TEXT_SIZE, 0); /* 0: blocking send, waiting when msg queue is full */
            if(ret == -1) {
                ERR_EXIT("msgsnd:msgsnd()");
            }

            //获取和设置消息队列的属性，在msqattr中
            ret = msgctl(msqid, IPC_STAT, &msqattr);
            if(ret == -1) {
                ERR_EXIT("msgsnd:msgctl()");
            }

            //打印传送到消息队列中的消息的内容和消息队列中剩下的消息数
            printf("Sending message: %s\n", buffer);
            printf("number of messages remainded = %ld\n\n", msqattr.msg_qnum);
        }
        wait(&childpid);
        fclose(fp);
        exit(EXIT_SUCCESS);
    }
}
