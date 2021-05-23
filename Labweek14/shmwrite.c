// shmwrite.c文件
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
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

#define MAX_N 1024  // 所能创建线程的最大数目

static int counter = 0; // 临界区中的进程个数
int level[MAX_N]; // 线程级别数组，每个元素分别对应第0到第MAX_N-1个线程
int waiting[MAX_N-1]; // 线程等候室数组，每个元素分别对应线程级别0到MAX_N-2的线程
int write_thread_num = 20; // 默认的创建线程数目
struct shared_struct *shared; // 共享结构体

static void *ftn(void *arg)
{
    // 获取线程编号
    int *numptr = (int *)arg;
    int thread_num = *numptr;
    int lev, k;

    char buffer[BUFSIZ + 1];
        
    // 最多有write_thread_num-1个线程等候室
    for (lev = 0; lev < write_thread_num-1; ++lev) {
        // 设置此线程的线程级别为lev，lev从0到write_thread_num-2，每次循环都会提升一次此线程的线程级别
        level[thread_num] = lev;
        // 设置等候室中线程级别为lev的线程为此线程
        waiting[lev] = thread_num;
        // 如果等候室中线程级别为lev的线程为此线程，那么线程被阻塞进入等待
        while (waiting[lev] == thread_num) {
            // 如果在此期间，任何线程级别小于此线程的线程j提升线程级别到或大于此线程，那么此线程将被踢出等候室，当被调度时退出while循环
            for (k = 0; k < write_thread_num; k++) {
                // 从0到write_thread_num-1，如果存在不是这个线程的一个线程k，线程级别大于等于这个线程，那么退出for循环
                if(level[k] >= lev && k != thread_num) {
                    break;
                }
                // 再次检查线程等候室数组中的线程级别为lev的线程是否此线程，如果不等于，退出for循环
                if(waiting[lev] != thread_num) {
                    break;
                }
            }
            // 其它任何线程的线程优先级都小于此线程的话，退出while循环，进入临界区
            if(k == write_thread_num) {
                break;
            } 
        }
    }
    // 临界区代码起始处
    counter++;
    // 如果临界区内有多于一个线程，那么终止进程
    if (counter > 1) {
        printf("ERROR! more than one processes in their critical sections\n");
        kill(getpid(), SIGKILL);
    }
    counter--;

    // 共享结构体的成员变量written为1时，说明缓冲区不可写，线程等待缓冲区可写written为0之后再继续执行
    while (shared->written == 1);

    // 写入信息之后，把共享结构体的成员变量written重新设为1，令缓冲区可读
    sprintf(buffer, "\"message from thread tid=%ld\"", gettid());
    printf("\nwrite-thread-%d tid=%ld writes: %s\n", thread_num, gettid(), buffer);
    strncpy(shared->mtext, buffer, TEXT_SIZE);
    shared->written = 1;
    // 临界区代码结束处

    // 将此线程在level数组中的线程级别设为-1，表示线程结束，可以让其它的线程级别为write_thread_num-2的线程退出while循环进入临界区
    level[thread_num] = -1; 

    pthread_exit(0);
}
 
int main(int argc, char *argv[])
{
    void *shmptr = NULL;
    int shmid;
    key_t key;

    // 获取从父进程传递来的IPC键值
    sscanf(argv[1], "%x", &key);
    // 获取从父进程传递来的创建线程个数
    sscanf(argv[2], "%d", &write_thread_num);
    
    // 获取共享内存标识符
    shmid = shmget((key_t)key, TEXT_NUM*sizeof(struct shared_struct), 0666|PERM);
    if (shmid == -1) {
        ERR_EXIT("shread: shmget()");
    }

    // 共享内存区对象映射到调用进程的地址空间，允许本进程访问共享内存
    shmptr = shmat(shmid, 0, 0);
    if(shmptr == (void *)-1) {
        ERR_EXIT("shread: shmat()");
    }
    
    // 获取共享内存结构体
    shared = (struct shared_struct *)shmptr;

    // 初始化level和waiting数组
    memset(level, (-1), sizeof(level));
    memset(waiting, (-1), sizeof(waiting));

    int i, ret;
    int thread_num[write_thread_num];
    pthread_t ptid[write_thread_num];

    // 传入参数数组
    for (i = 0; i < write_thread_num; i++) {
        thread_num[i] = i + 1;
    }

    // 打印写线程的总数
    printf("total wrtie-thread number = %d\n", write_thread_num);  

    // 创建write_thread_num个写线程
    for (i = 0; i < write_thread_num; i++) {
        ret = pthread_create(&ptid[i], NULL, &ftn, (void *)&thread_num[i]);
        if(ret != 0) {
            fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
        }
    }

    // 主线程等待所有子线程退出后再继续执行
    for (i = 0; i < write_thread_num; i++) {
        ret = pthread_join(ptid[i], NULL);
        if(ret != 0) {
           perror("pthread_join()");
        }
    }

    // 断开与共享内存附加点的地址，本进程不能访问共享内存
    if (shmdt(shmptr) == -1) {
        ERR_EXIT("shmread: shmdt()");
    }

    return 0;
}
