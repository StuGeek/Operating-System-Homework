// CLONE_SIGHAND_test.c
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

// 主线程中的信号处理函数
void main_thread_handler(int signo) {
    printf("\nThis is main_thread_handler");
    printf("\nsignal catched: signo = %d\n", signo);
    
    return;
}

// 子线程中的信号处理函数
void CLONE_SIGHAND_handler(int signo) {
    printf("\nThis is CLONE_SIGHAND_handler");
    printf("\nsignal catched: signo = %d\n", signo);
    
    return;
}

// 测试参数CLONE_SIGHAND所用到的子线程执行函数
static int CLONE_SIGHAND_func(void *arg) {
    // 设置捕捉到Ctrl+C信号的信号处理函数为CLONE_SIGHAND_handler
    signal(SIGINT, CLONE_SIGHAND_handler);
    printf("I am CLONE_SIGHAND_func, my tid = %ld, pid = %d, ppid = %d\n", gettid(), getpid(), getppid());
    printf("CLONE_SIGHAND_func set CLONE_SIGHAND_handler\n\n");

    return 0;
}

int main(int argc,char **argv)
{
    // 测试线程所用到的系统栈区
    char *stack_CLONE_SIGHAND1 = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_SIGHAND2 = malloc(STACK_SIZE*sizeof(char));

    pid_t chdtid_CLONE_SIGHAND;

    unsigned long flags = 0;
    int status = 0;

    if(!stack_CLONE_SIGHAND1 || !stack_CLONE_SIGHAND2) {
        perror("malloc()");
        exit(1);
    }

    // 测试参数CLONE_SIGHAND
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_SIGHAND\n");
    // 设置参数为0
    flags = 0;

    printf("Result:\n");
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    printf("In the beginning, main thread set main_thread_handler\n\n");
    // 设置捕捉到Ctrl+C信号的信号处理函数为main_thread_handler
    signal(SIGINT, main_thread_handler);
    // 从linux 2.6.0开始，当指定CLONE_SIGHAND后，必须也指定CLONE_VM
    chdtid_CLONE_SIGHAND = clone(CLONE_SIGHAND_func, stack_CLONE_SIGHAND1 + STACK_SIZE, flags | CLONE_VM | SIGCHLD, NULL);
    if(chdtid_CLONE_SIGHAND == -1) {
        perror("CLONE_SIGHAND before:clone()");
        exit(1);
    }

    // 等待子线程执行完后主线程再继续执行，测试子线程改变了捕捉到Ctrl+C信号的信号处理函数是否会影响到主线程
    waitpid(chdtid_CLONE_SIGHAND, &status, 0);

    // 休眠100s，便于输入Ctrl+C信号，输入后信号处理完毕后主线程继续执行
    printf("now start catching Ctrl+c\n");
    sleep(100);

    printf("\n");

    printf("After set flags to CLONE_SIGHAND\n");
    // 设置参数为CLONE_SIGHAND
    flags |= CLONE_SIGHAND;

    printf("Result:\n");
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    printf("In the beginning, main thread set main_thread_handler\n\n");
    // 设置捕捉到Ctrl+C信号的信号处理函数为main_thread_handler
    signal(SIGINT, main_thread_handler);
    // 从linux 2.6.0开始，当指定CLONE_SIGHAND后，必须也指定CLONE_VM
    chdtid_CLONE_SIGHAND = clone(CLONE_SIGHAND_func, stack_CLONE_SIGHAND2 + STACK_SIZE, flags | CLONE_VM | SIGCHLD, NULL);
    if(chdtid_CLONE_SIGHAND == -1) {
        perror("CLONE_SIGHAND before:clone()");
        exit(1);
    }

    // 等待子线程执行完后主线程再继续执行，测试子线程改变了捕捉到Ctrl+C信号的信号处理函数是否会影响到主线程
    waitpid(chdtid_CLONE_SIGHAND, &status, 0);

    // 休眠100s，便于输入Ctrl+C信号，输入后信号处理完毕后主线程继续执行
    printf("now start catching Ctrl+c\n");
    sleep(100);

    printf("------------------------------------------------------------------\n\n");

    free(stack_CLONE_SIGHAND1);
    free(stack_CLONE_SIGHAND2);
    stack_CLONE_SIGHAND1 = NULL;
    stack_CLONE_SIGHAND2 = NULL;

    return 0;
}