// CLONE_VFORK_test.c
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sched.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <sys/syscall.h>
#include <fcntl.h>
#include <unistd.h>
#define gettid() syscall(__NR_gettid)
  /* wrap the system call syscall(__NR_gettid), __NR_gettid = 224 */
#define gettidv2() syscall(SYS_gettid) /* a traditional wrapper */

#define STACK_SIZE 1024*1024 /* 1Mib. question: what is the upperbound of STACK_SIZE */

#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)

// 测试参数CLONE_VFORK所用到的子线程执行函数
static int CLONE_VFORK_func(void *arg) {
    printf("I am CLONE_VFORK_func, my tid = %ld, pid = %d\n", gettid(), getpid());
    printf("CLONE_VFORK_func sleeping 3s and then exists ...\n");
    // 休眠3s，如果主线程与子线程异步执行，那么主线程有足够时间在这期间继续执行，否则主线程会等待子线程执行完再继续执行
    sleep(3);
    // 标志子线程执行完退出
    printf("CLONE_VFORK_func exists successfully!\n");

    return 0;
}

int main(int argc,char **argv)
{
    // 测试线程所用到的系统栈区
    char *stack_CLONE_VFORK1 = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_VFORK2 = malloc(STACK_SIZE*sizeof(char));

    pid_t chdtid_CLONE_VFORK;

    unsigned long flags = 0;
    int status = 0;
    char buf[100];

    if(!stack_CLONE_VFORK1 || !stack_CLONE_VFORK2) {
        perror("malloc()");
        exit(1);
    }

    // 测试参数CLONE_VFORK
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_VFORK\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    chdtid_CLONE_VFORK = clone(CLONE_VFORK_func, stack_CLONE_VFORK1 + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid_CLONE_VFORK == -1) {
        perror("CLONE_VFORK before:clone()");
        exit(1);
    }
    // 在waitpid()函数之前打印主线程的信息，观察主线程是否会等待子线程执行完后再执行
    printf("I am main thread, my pid = %d\n", getpid());
    waitpid(chdtid_CLONE_VFORK, &status, 0);
    printf("\n");

    printf("After set flags to CLONE_VFORK\n");
    // 设置参数为CLONE_VFORK
    flags |= CLONE_VFORK;
    printf("Result:\n");
    chdtid_CLONE_VFORK = clone(CLONE_VFORK_func, stack_CLONE_VFORK2 + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid_CLONE_VFORK == -1) {
        perror("CLONE_VFORK after:clone()");
        exit(1);
    }
    // 在waitpid()函数之前打印主线程的信息，观察主线程是否会等待子线程执行完后再执行
    printf("I am main thread, my pid = %d\n", getpid());
    waitpid(chdtid_CLONE_VFORK, &status, 0);
    printf("------------------------------------------------------------------\n\n");

    free(stack_CLONE_VFORK1);
    free(stack_CLONE_VFORK2);
    stack_CLONE_VFORK1 = NULL;
    stack_CLONE_VFORK2 = NULL;

    return 0;
}