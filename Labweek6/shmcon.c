// 文件shmcon.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <fcntl.h>

#include "shmdata.h"

int main(int argc, char *argv[])
{
    struct stat fileattr;
    key_t key; /* of type int */
    int shmid; /* shared memory ID */
    void *shmptr;
    struct shared_struct *shared; /* structured shm */
    pid_t childpid1, childpid2;
    char pathname[80], key_str[10];
    int shmsize, ret;

    shmsize = sizeof(struct shared_struct); /* 共享内存的大小 */

        /* 在编译命令"./a.out"后面还要加上文件路径名 */
    if(argc <2) {
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
 
    key = ftok(pathname, 0x27); /* 0x27 a project ID 0x0001 - 0xffff, 8 least bits used */
    if(key == -1) {
        ERR_EXIT("shmcon: ftok()");
    }

    shmid = shmget((key_t)key, shmsize, 0666|PERM);
    if(shmid == -1) {
        ERR_EXIT("shmcon: shmget()");
    }

    shmptr = shmat(shmid, 0, 0); /* returns the virtual base address mapping to the shared memory, *shmaddr=0 decided by kernel */

    if(shmptr == (void *)-1) {
        ERR_EXIT("shmcon: shmat()");
    }
    
    //创建共享内存中使用的结构体，初始化结构体中的循环队列的队首和
    shared = (struct shared_struct *)shmptr; /* 创建共享内存中使用的结构体 */
    shared->front = 0; /* 初始化结构体中的循环队列的队首下标为0 */
    shared->rear = 0; /* 初始化结构体中的循环队列的队尾下标为0 */
	
    if(shmdt(shmptr) == -1) {
        ERR_EXIT("shmcon: shmdt()");
    }

    sprintf(key_str, "%x", key);
    char *argv1[] = {" ", key_str, 0};

    childpid1 = vfork();
    if(childpid1 < 0) {
        ERR_EXIT("shmcon: 1st vfork()");
    } 
    else if(childpid1 == 0) {
        execv("./shmread.o", argv1); /* call shm_read with IPC key */
    }
    else {
        childpid2 = vfork();
        if(childpid2 < 0) {
            ERR_EXIT("shmcon: 2nd vfork()");
        }
        else if (childpid2 == 0) {
            execv("./shmwrite.o", argv1); /* call shmwrite with IPC key */
        }
        else {
            wait(&childpid1);
            wait(&childpid2);
                 /* shmid can be removed by any process knewn the IPC key */
            if (shmctl(shmid, IPC_RMID, 0) == -1) {
                ERR_EXIT("shmcon: shmctl(IPC_RMID)");
            }
            else {
                printf("The program is over\n");
            }
        }
    }
    exit(EXIT_SUCCESS);
}

