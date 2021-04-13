//msgconsumer.c文件
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <sys/mman.h>
#include <mqueue.h>

#include "alg.9-0-msgdata.h"

int main(int argc, char *argv[])
{
    int ret;
    mqd_t mqid;
    char buffer[BUFSIZ + 1];

    mqid = mq_open(argv[1], O_RDONLY, 0444); //根据父进程传递进的文件路径名打开同一个消息队列，权限为只可读
    if(mqid == -1) {
        ERR_EXIT("msgconsumer: mq_open()");
    }

    struct mq_attr mqAttr;

    //使用while循环不断向消息队列中读出消息
    while (1) {
        //获取消息队列的属性到mqAttr中
        ret = mq_getattr(mqid, &mqAttr);
        if (ret == -1) {
            ERR_EXIT("msgconsumer: mq_getattr()");
        }

        //如果消息队列中没有消息，那么等待消息写入后再读出消息
        while (mqAttr.mq_curmsgs == 0) {
            sleep(1);
            ret = mq_getattr(mqid, &mqAttr);
            if (ret == -1) {
                ERR_EXIT("msgconsumer: mq_getattr()");
            }
        }
        
        //从消息队列里读出消息
        ret = mq_receive(mqid, buffer, mqAttr.mq_msgsize, 0);
        if (ret == -1) {
            ERR_EXIT("msgconsumer: mq_receive()");
        }
        
        printf("Consumer message: %s\n", buffer);

        //如果输入的消息为end，那么结束输入
        if(strncmp(buffer, "end", 3) == 0) {
            break;
        }
    }

    //关闭消息队列
    ret = mq_close(mqid);
    if (ret == -1) {
        ERR_EXIT("msgconsumer: mq_close()");
    }
    
    return EXIT_SUCCESS;
}

