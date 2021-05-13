// CLONE_PARENT_test.c
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

// 测试参数CLONE_PARENT所用到的子线程执行函数
static int CLONE_PARENT_func(void *arg) {
    // 打印子线程的线程号、进程号、父进程号
    printf("I am CLONE_PARENT_func, my tid = %ld, pid = %d, ppid = %d\n", gettid(), getpid(), getppid());
    
    return 0;
}

int main(int argc,char **argv)
{
    // 测试线程所用到的系统栈区
    char *stack_CLONE_PARENT1 = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_PARENT2 = malloc(STACK_SIZE*sizeof(char));

    pid_t chdtid_CLONE_PARENT;

    unsigned long flags = 0;

    if(!stack_CLONE_PARENT1 || !stack_CLONE_PARENT2) {
        perror("malloc()");
        exit(1);
    }

    // 测试参数CLONE_PARENT
    printf("------------------------------------------------------------------\n");
    // 设置参数CLONE_PARENT前
    printf("Before set flags to CLONE_PARENT\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    chdtid_CLONE_PARENT = clone(CLONE_PARENT_func, stack_CLONE_PARENT1 + STACK_SIZE, flags | SIGCHLD, NULL);
    if(chdtid_CLONE_PARENT == -1) {
        perror("CLONE_PARENT before:clone()");
        exit(1);
    }
    // 打印主线程的进程号和父进程号
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    // 休眠1s以便子线程结束
    sleep(1);
    printf("\n");

    // 设置参数CLONE_PARENT后
    printf("After set flags to CLONE_PARENT\n");
    // 设置参数为CLONE_PARENT
    flags |= CLONE_PARENT;
    printf("Result:\n");
    chdtid_CLONE_PARENT = clone(CLONE_PARENT_func, stack_CLONE_PARENT2 + STACK_SIZE, flags | SIGCHLD, NULL);
    if(chdtid_CLONE_PARENT == -1) {
        perror("CLONE_PARENT after:clone()");
        exit(1);
    }
    // 打印主线程的进程号和父进程号
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    // 休眠1s以便子线程结束
    sleep(1);
    printf("------------------------------------------------------------------\n\n");

    free(stack_CLONE_PARENT1);
    free(stack_CLONE_PARENT2);
    stack_CLONE_PARENT1 = NULL;
    stack_CLONE_PARENT2 = NULL;

    return 0;
}