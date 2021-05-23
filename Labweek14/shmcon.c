// shmcon.c文件
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <sys/syscall.h>
#include <fcntl.h>
#include <unistd.h>

#include "shmdata.h"

#define gettid() syscall(__NR_gettid)
  /* wrap the system call syscall(__NR_gettid), __NR_gettid = 224 */
#define gettidv2() syscall(SYS_gettid) /* a traditional wrapper */

#define THREAD_NUM 10 // 读写进程所要创建线程数

int main(int argc, char *argv[])
{
    struct stat fileattr;
    key_t key; // 即int类型
    int shmid; // 共享内存标识符
    void *shmptr;
    struct shared_struct *shared; // 共享内存结构体
    pid_t childpid1, childpid2;
    char pathname[80], key_str[10], thread_num_str[10];
    int shmsize, ret;

    // 确定共享内存的大小
    shmsize = TEXT_NUM*sizeof(struct shared_struct);

    // 获取共享文件对象路径名
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
 
    // 获取IPC键值
    key = ftok(pathname, 0x27);
    if(key == -1) {
        ERR_EXIT("shmcon: ftok()");
    }

    // 获取共享内存标识符
    shmid = shmget((key_t)key, shmsize, 0666|PERM);
    if(shmid == -1) {
        ERR_EXIT("shmcon: shmget()");
    }

    // 把共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存
    shmptr = shmat(shmid, 0, 0);

    if(shmptr == (void *)-1) {
        ERR_EXIT("shmcon: shmat()");
    }
    
    // 获取共享结构体，并把共享结构体的结构体的成员变量written设为0，表示缓冲区可写但不可读
    shared = (struct shared_struct *)shmptr;
    shared->written = 0;

    // 断开与共享内存附加点的地址，本进程不能访问共享内存
    if(shmdt(shmptr) == -1) {
        ERR_EXIT("shmcon: shmdt()");
    }

    // 将IPC键值和读写进程所要创建的线程数作为参数传递给读写进程
    sprintf(key_str, "%x", key);
    sprintf(thread_num_str, "%d", THREAD_NUM);
    char *argv1[] = {" ", key_str, thread_num_str, 0};

    childpid1 = vfork();
    if(childpid1 < 0) {
        ERR_EXIT("shmcon: 1st vfork()");
    } 
    else if(childpid1 == 0) {
        // 异步执行读进程
        execv("./shmread.o", argv1);
    }
    else {
        childpid2 = vfork();
        if(childpid2 < 0) {
            ERR_EXIT("shmcon: 2nd vfork()");
        }
        else if (childpid2 == 0) {
            // 异步执行写进程
            execv("./shmwrite.o", argv1);
        }
        else {
            // 等待子进程都结束后父进程再执行
            wait(&childpid1);
            wait(&childpid2);
            // 释放共享内存区
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

