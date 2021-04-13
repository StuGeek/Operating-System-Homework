//msgrcv.c文件
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/msg.h>
#include <sys/stat.h>

#include "alg.9-0-msgdata.h" 

int main(int argc, char *argv[]) /* Usage: ./b.out pathname msg_type */
{
    key_t key;
    struct stat fileattr;
    char pathname[80];
    int msqid, ret;
    struct msg_struct data;

    if(argc < 2) {
        printf("Usage: ./msgrcv.o pathname msg_type\n");
        return EXIT_FAILURE;
    }
    strcpy(pathname, argv[2]);

    if(stat(pathname, &fileattr) == -1) {
        ERR_EXIT("shared file object stat error");
    }

    //根据相同的文件路径名和整数标识符获取一个IPC键值
    if((key = ftok(pathname, 0x27)) < 0) {
        ERR_EXIT("msgrcv:ftok()");
    }

    //由于之前已经创建过消息队列，所以不用选择IPC_CREAT选项，再创建一个新的消息队列
    msqid = msgget((key_t)key, 0666);
    if(msqid == -1) {
        ERR_EXIT("msgrcv:msgget()");
    }

    struct msqid_ds msqattr;
    ret = msgctl(msqid, IPC_STAT, &msqattr);

    //从消息队列中读出消息
    while (1) {
        //每隔3s读出一次消息
        sleep(3);
        ret = msgrcv(msqid, (void *)&data, TEXT_SIZE, 0, IPC_NOWAIT); /* Non_blocking receive */
        //当消息队列中的信息被读取完时，结束读取消息
        if(ret == -1) {
            printf("All the messages have been taken out\n");
            break;
        }

        //获取和设置消息队列的属性，在msqattr中
        ret = msgctl(msqid, IPC_STAT, &msqattr);
        if (ret == -1) {
            ERR_EXIT("msgrcv:msgctl()");
        }
        
        //打印从消息队列中的读出消息的内容和消息队列中剩下的消息数
        printf("\t\t\t\tReceiving message: %s\n", data.mtext);
        printf("\t\t\t\tnumber of messages remainding = %ld\n\n", msqattr.msg_qnum); 
    }

    //当消息队列中没有消息时，提示是否删除消息队列
    if(msqattr.msg_qnum == 0) {
        printf("do you want to delete this msg queue?(y/n)");
        if(getchar() == 'y') {
            if(msgctl(msqid, IPC_RMID, 0) == -1)
                perror("msgrcv:msgctl(IPC_RMID)");
        }
    }
   
    exit(EXIT_SUCCESS);
}
