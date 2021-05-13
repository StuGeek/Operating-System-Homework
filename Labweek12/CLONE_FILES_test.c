// CLONE_FILES_test.c
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

// 测试参数CLONE_FILES所用到的子线程执行函数
static int CLONE_FILES_func(void *arg) {
    // 获取主线程传来的文件描述符
    int *numptr = (int *)arg;
    int fd = *numptr;
    
    // 设置文件的FD_CLOEXEC参数为1
    fcntl(fd, F_SETFD, 1);
    printf("I am CLONE_FILES_func, my tid = %ld, pid = %d, ppid = %d\n", gettid(), getpid(), getppid());
    printf("CLONE_FILES_func sets the FD_COLEXEC of fd to %d\n", fcntl(fd, F_GETFD));
    
    return 0;
}

int main(int argc,char **argv)
{
    // 测试线程所用到的系统栈区
    char *stack_CLONE_FILES1 = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_FILES2 = malloc(STACK_SIZE*sizeof(char));

    pid_t chdtid_CLONE_FILES;

    unsigned long flags = 0;
    int status = 0;

    if(!stack_CLONE_FILES1 || !stack_CLONE_FILES2) {
        perror("malloc()");
        exit(1);
    }

// 测试参数CLONE_FILES
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_FILES\n");
    int fd = open("./test.txt", O_RDWR | O_CREAT, 0666);
    if (fd < 0) {
        perror("CLONE_FILES:open()");
        exit(EXIT_FAILURE);
    }
    
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    // 设置文件的FD_CLOEXEC参数为0
    fcntl(fd, F_SETFD, 0);
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    printf("In the beginning, main thread sets the FD_COLEXEC of fd to %d\n\n", fcntl(fd, F_GETFD));

    chdtid_CLONE_FILES = clone(CLONE_FILES_func, stack_CLONE_FILES1 + STACK_SIZE, flags | SIGCHLD, &fd);
    if(chdtid_CLONE_FILES == -1) {
        perror("CLONE_FILES before:clone()");
        exit(1);
    }

    // 等待子线程执行完后主线程再继续执行，测试子线程改变了文件的FD_CLOEXEC参数是否会影响到主线程
    waitpid(chdtid_CLONE_FILES, &status, 0);
    // 查看文件的FD_CLOEXEC参数
    printf("\nIn the last, the FD_COLEXEC of fd in main thread is %d\n\n\n", fcntl(fd, F_GETFD));

    printf("After set flags to CLONE_FILES\n");
    // 设置参数为CLONE_FILES
    flags |= CLONE_FILES;
    printf("Result:\n");
    // 设置文件的FD_CLOEXEC参数为0
    fcntl(fd, F_SETFD, 0);
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    printf("In the beginning, main thread sets the FD_COLEXEC of fd to %d\n\n", fcntl(fd, F_GETFD));

    chdtid_CLONE_FILES = clone(CLONE_FILES_func, stack_CLONE_FILES2 + STACK_SIZE, flags | SIGCHLD, &fd);
    if(chdtid_CLONE_FILES == -1) {
        perror("CLONE_FILES after:clone()");
        exit(1);
    }

    // 等待子线程执行完后主线程再继续执行，测试子线程改变了文件的FD_CLOEXEC参数是否会影响到主线程
    waitpid(chdtid_CLONE_FILES, &status, 0);
    // 查看文件的FD_CLOEXEC参数
    printf("\nIn the last, the FD_COLEXEC of fd in main thread is %d\n", fcntl(fd, F_GETFD));
    printf("------------------------------------------------------------------\n\n");

    free(stack_CLONE_FILES1);
    free(stack_CLONE_FILES2);
    stack_CLONE_FILES1 = NULL;
    stack_CLONE_FILES2 = NULL;

    return 0;
}