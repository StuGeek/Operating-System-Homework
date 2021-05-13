// CLONE_VM_test.c
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

// 测试参数CLONE_VM所用到的子线程执行函数
static int CLONE_VM_func(void *arg) {
    // 获取主线程传来的缓冲区参数buf
    char *chdbuf = (char*)arg;
    printf("CLONE_VM_func read buf: %s\n", chdbuf);
    sleep(1);
    // 设置缓冲区buf中的内容为子线程的信息
    sprintf(chdbuf, "I am CLONE_VM_func, my tid = %ld, pid = %d", gettid(), getpid());
    printf("CLONE_VM_func set buf: %s\n", chdbuf);
    sleep(1);
    // 子线程退出
    printf("CLONE_VM_func sleeping and then exists ...\n");
    sleep(1);

    return 0;
}

int main(int argc,char **argv)
{
    // 测试线程所用到的系统栈区
    char *stack_CLONE_VM1 = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_VM2 = malloc(STACK_SIZE*sizeof(char));

    pid_t chdtid_CLONE_VM;

    unsigned long flags = 0;
    int status = 0;
    char buf[100];

    if(!stack_CLONE_VM1 || !stack_CLONE_VM2) {
        perror("malloc()");
        exit(1);
    }

    // 测试参数CLONE_VM
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_VM\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    // 设置缓冲区buf中的内容为主线程的信息
    sprintf(buf,"I am main thread, my pid = %d", getpid());
    printf("main thread set buf: %s\n", buf);
    sleep(1);
    printf("parent clone ...\n");
    chdtid_CLONE_VM = clone(CLONE_VM_func, stack_CLONE_VM1 + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid_CLONE_VM == -1) {
        perror("CLONE_VM before:clone()");
        exit(1);
    }
    // 等待子线程执行完后主线程再继续执行，测试子线程改变了缓冲区buf的内容是否会影响到主线程
    waitpid(chdtid_CLONE_VM, &status, 0);
    // 打印此时缓冲区buf中的内容
    printf("parent read buf: %s\n", buf);
    printf("\n");

    printf("After set flags to CLONE_VM\n");
    // 设置参数为CLONE_VM
    flags |= CLONE_VM;
    printf("Result:\n");
    // 设置缓冲区buf中的内容为主线程的信息
    sprintf(buf,"I am main thread, my pid = %d", getpid());
    printf("main thread set buf: %s\n", buf);
    sleep(1);
    printf("parent clone ...\n");
    chdtid_CLONE_VM = clone(CLONE_VM_func, stack_CLONE_VM2 + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid_CLONE_VM == -1) {
        perror("CLONE_VM after:clone()");
        exit(1);
    }
    // 等待子线程执行完后主线程再继续执行，测试子线程改变了缓冲区buf的内容是否会影响到主线程
    waitpid(chdtid_CLONE_VM, &status, 0);
    // 打印此时缓冲区buf中的内容
    printf("parent read buf: %s\n", buf);
    printf("------------------------------------------------------------------\n\n");

    free(stack_CLONE_VM1);
    free(stack_CLONE_VM2);
    stack_CLONE_VM1 = NULL;
    stack_CLONE_VM2 = NULL;

    return 0;
}