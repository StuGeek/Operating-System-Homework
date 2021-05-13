// CLONE_NEWIPC_test.c
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

// 测试参数CLONE_NEWIPC所用到的子线程执行函数
static int CLONE_NEWIPC_func(void *arg) {
    // 查看线程所处的IPC命名空间的消息队列的信息
    printf("Message Queues in CLONE_NEWIPC_func:\n");
    system("ipcs -q");
    
    return 0;
}

int main(int argc,char **argv)
{
    // 测试线程所用到的系统栈区
    char *stack_CLONE_NEWIPC1 = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_NEWIPC2 = malloc(STACK_SIZE*sizeof(char));

    pid_t chdtid_CLONE_NEWIPC;

    int ret;
    unsigned long flags = 0;
    int status = 0;
    char buf[100];

    if(!stack_CLONE_NEWIPC1 || !stack_CLONE_NEWIPC2) {
        perror("malloc()");
        exit(1);
    }

    // 测试参数CLONE_NEWIPC
    printf("------------------------------------------------------------------\n");
    // 首先在主线程中创建一个消息队列
    printf("First create a message queue in main thread\n\n");
    char pathname[10] = {"./test"};
    struct stat fileattr;
    key_t key;
    int msqid;
    if(stat(pathname, &fileattr) == -1) {
        ret = creat(pathname, O_RDWR);
        if (ret == -1) {
            ERR_EXIT("CLONE_NEWIPC: creat()");
        }
        printf("shared file object created\n");
    }
    
    key = ftok(pathname, 0x27);
    if(key < 0) {
        ERR_EXIT("ftok()");
    }
    
    msqid = msgget((key_t)key, 0666 | IPC_CREAT);
    if(msqid == -1) {
        ERR_EXIT("msgget()");
    }

    printf("Before set flags to CLONE_NEWIPC\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n\n");

    // 查看主线程的IPC命名空间中消息队列的情况
    printf("Command: ipcs -q\n\n");
    printf("Message Queues in main thread:\n");
    system("ipcs -q");
    chdtid_CLONE_NEWIPC = clone(CLONE_NEWIPC_func, stack_CLONE_NEWIPC1 + STACK_SIZE, flags | SIGCHLD, NULL);
    if(chdtid_CLONE_NEWIPC == -1) {
        perror("CLONE_NEWIPC before:clone()");
        exit(1);
    }
    // 等待子线程执行完后主线程再继续执行，测试子线程的命名空间是否和主线程一样
    waitpid(chdtid_CLONE_NEWIPC, &status, 0);
    printf("\n");

    printf("After set flags to CLONE_NEWIPC\n");
    // 设置参数为CLONE_NEWIPC
    flags |= CLONE_NEWIPC;
    printf("Result:\n\n");

    // 查看主线程的IPC命名空间中消息队列的情况
    printf("Command: ipcs -q\n\n");
    printf("Message Queues in main thread:\n");
    system("ipcs -q");
    chdtid_CLONE_NEWIPC = clone(CLONE_NEWIPC_func, stack_CLONE_NEWIPC2 + STACK_SIZE, flags | SIGCHLD, NULL);
    if(chdtid_CLONE_NEWIPC == -1) {
        perror("CLONE_NEWIPC after:clone()");
        exit(1);
    }
    // 等待子线程执行完后主线程再继续执行，测试子线程改变了捕捉到Ctrl+C信号的信号处理函数是否会影响到主线程
    waitpid(chdtid_CLONE_NEWIPC, &status, 0);

    // 删除之前创建的消息队列
    sprintf(buf, "ipcrm -q %d", msqid);
    printf("Command: %s\n", buf);
    system(buf);
    printf("------------------------------------------------------------------\n\n");

    free(stack_CLONE_NEWIPC1);
    free(stack_CLONE_NEWIPC2);
    stack_CLONE_NEWIPC1 = NULL;
    stack_CLONE_NEWIPC2 = NULL;

    return 0;
}