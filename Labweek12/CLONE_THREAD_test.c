// CLONE_THREAD_test.c
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

// 测试参数CLONE_THREAD所用到的子线程执行函数
static int CLONE_THREAD_func(void *arg) {
    // 打印子线程的线程号、进程号、父进程号
    printf("I am CLONE_THREADs_func, my tid = %ld, pid = %d, ppid = %d\n", gettid(), getpid(), getppid());

    return 0;
}

int main(int argc,char **argv)
{
    // 测试线程所用到的系统栈区
    char *stack_CLONE_THREAD1 = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_THREAD2 = malloc(STACK_SIZE*sizeof(char));

    pid_t chdtid_CLONE_THREAD;

    unsigned long flags = 0;

    if(!stack_CLONE_THREAD1 || !stack_CLONE_THREAD2) {
        perror("malloc()");
        exit(1);
    }

    // 测试参数CLONE_THREAD
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_THREAD\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    // 从Linux 2.5.35开始，如果指定了CLONE_THREAD，则必须同时指定CLONE_SIGHAND。而从Linux 2.6.0开始，指定CLONE_SIGHAND的同时也必须指定CLONE_VM
    chdtid_CLONE_THREAD = clone(CLONE_THREAD_func, stack_CLONE_THREAD1 + STACK_SIZE, flags | CLONE_VM | CLONE_SIGHAND | SIGCHLD, NULL);
    if(chdtid_CLONE_THREAD == -1) {
        perror("CLONE_THREAD before:clone()");
        exit(1);
    }
    // 打印主线程的进程号和父进程号
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    // 休眠1s以便子线程结束
    sleep(1);
    printf("\n");

    printf("After set flags to CLONE_THREAD\n");
    // 设置参数为CLONE_THREAD
    flags |= CLONE_THREAD;
    printf("Result:\n");
    // 从Linux 2.5.35开始，如果指定了CLONE_THREAD，则必须同时指定CLONE_SIGHAND。而从Linux 2.6.0开始，指定CLONE_SIGHAND的同时也必须指定CLONE_VM
    chdtid_CLONE_THREAD = clone(CLONE_THREAD_func, stack_CLONE_THREAD2 + STACK_SIZE, flags | CLONE_VM | CLONE_SIGHAND | SIGCHLD, NULL);
    if(chdtid_CLONE_THREAD == -1) {
        perror("CLONE_THREAD after:clone()");
        exit(1);
    }
    // 打印主线程的进程号和父进程号
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    // 休眠1s以便子线程结束
    sleep(1);
    printf("------------------------------------------------------------------\n\n");

    free(stack_CLONE_THREAD1);
    free(stack_CLONE_THREAD2);

    stack_CLONE_THREAD1 = NULL;
    stack_CLONE_THREAD2 = NULL;

    return 0;
}