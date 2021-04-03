//文件shmread.c，充当reader角色
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <sys/shm.h>

#include "shmdata.h"

// 学生信息多字符串读写
int main(int argc, char *argv[])
{
    void *shmptr = NULL;
    struct shared_struct *shared;
    int shmid;
    key_t key;
 
    sscanf(argv[1], "%x", &key);
    
    shmid = shmget((key_t)key, sizeof(struct shared_struct), 0666|PERM);
    if (shmid == -1) {
        ERR_EXIT("shread: shmget()");
    }

    shmptr = shmat(shmid, 0, 0);
    if(shmptr == (void *)-1) {
        ERR_EXIT("shread: shmat()");
    }
    
    shared = (struct shared_struct *)shmptr;
    
    while (1) {
        while (shared->front == shared->rear) {
            sleep(1); // 循环队列为空时不能读
        }
        sleep(3); // 为了方便观察效果，每3秒读一次
        printf("\n%*sYou wrote: %s", 30, " ", shared->mtext[shared->front].text);

        if (strncmp(shared->mtext[shared->front].text, "end", 3) == 0) {
            break;
        }

            // 数据从循环队列读出后，循环队列队首下标加一
        shared->front = (shared->front + 1) % (TEXT_NUM + 1);
    }

        // detach the shared memory
    if (shmdt(shmptr) == -1) {
        ERR_EXIT("shmread: shmdt()");
    }
 
    sleep(1);
    exit(EXIT_SUCCESS);
}

// 学生信息组织结构体
/*int main(int argc, char *argv[])
{
    void *shmptr = NULL;
    struct shared_struct *shared;
    int shmid;
    key_t key;
 
    sscanf(argv[1], "%x", &key);
    
    shmid = shmget((key_t)key, sizeof(struct shared_struct), 0666|PERM);
    if (shmid == -1) {
        ERR_EXIT("shread: shmget()");
    }

    shmptr = shmat(shmid, 0, 0);
    if(shmptr == (void *)-1) {
        ERR_EXIT("shread: shmat()");
    }
    
    shared = (struct shared_struct *)shmptr;
    
    while (1) {
        while (shared->front == shared->rear) {
            sleep(1); // 循环队列为空时不能读
        }
        sleep(10); // 为了方便观察效果，每10秒读一次
        printf("\n%*sstudent information: id:%d name:%s department:%s", 30, " ", 
                shared->students[shared->front].id, 
                shared->students[shared->front].name, 
                shared->students[shared->front].department);

        if (shared->students[shared->front].id == -1) {
            break;
        }

            // 数据从循环队列读出后，循环队列队首下标加一
        shared->front = (shared->front + 1) % (TEXT_NUM + 1);
    }

        // detach the shared memory
    if (shmdt(shmptr) == -1) {
        ERR_EXIT("shmread: shmdt()");
    }
 
    sleep(1);
    exit(EXIT_SUCCESS);
}*/
