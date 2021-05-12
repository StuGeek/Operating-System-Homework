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

// 测试参数CLONE_NEWIPC所用到的子线程执行函数
static int CLONE_NEWIPC_func(void *arg) {
    // 查看线程所处的IPC命名空间的消息队列的信息
    printf("Message Queues in CLONE_NEWIPC_func:\n");
    system("ipcs -q");
    
    return 0;
}

// 测试参数CLONE_THREAD所用到的子线程执行函数
static int CLONE_THREAD_func(void *arg) {
    // 打印子线程的线程号、进程号、父进程号
    printf("I am CLONE_THREADs_func, my tid = %ld, pid = %d, ppid = %d\n", gettid(), getpid(), getppid());

    return 0;
}

int main(int argc,char **argv)
{
    // 测试线程所用到的系统栈区
    char *stack_CLONE_PARENT = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_VM = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_VFORK = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_FILES = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_SIGHAND = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_NEWIPC = malloc(STACK_SIZE*sizeof(char));
    char *stack_CLONE_THREAD = malloc(STACK_SIZE*sizeof(char));

    pid_t chdtid_CLONE_PARENT, chdtid_CLONE_VM, chdtid_CLONE_VFORK, 
            chdtid_CLONE_FILES, chdtid_CLONE_SIGHAND, chdtid_CLONE_NEWIPC, chdtid_CLONE_THREAD;

    int ret;
    unsigned long flags = 0;
    int status = 0;
    char buf[100];

    if(!stack_CLONE_PARENT || !stack_CLONE_VFORK || !stack_CLONE_VFORK ||
            !stack_CLONE_FILES || !stack_CLONE_SIGHAND || !stack_CLONE_NEWIPC || 
                !stack_CLONE_THREAD) {
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
    chdtid_CLONE_PARENT = clone(CLONE_PARENT_func, stack_CLONE_PARENT + STACK_SIZE, flags | SIGCHLD, NULL);
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
    chdtid_CLONE_PARENT = clone(CLONE_PARENT_func, stack_CLONE_PARENT + STACK_SIZE, flags | SIGCHLD, NULL);
    if(chdtid_CLONE_PARENT == -1) {
        perror("CLONE_PARENT after:clone()");
        exit(1);
    }
    // 打印主线程的进程号和父进程号
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    // 休眠1s以便子线程结束
    sleep(1);
    printf("------------------------------------------------------------------\n\n");


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
    chdtid_CLONE_VM = clone(CLONE_VM_func, stack_CLONE_VM + STACK_SIZE, flags | SIGCHLD, buf);
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
    chdtid_CLONE_VM = clone(CLONE_VM_func, stack_CLONE_VM + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid_CLONE_VM == -1) {
        perror("CLONE_VM after:clone()");
        exit(1);
    }
    // 等待子线程执行完后主线程再继续执行，测试子线程改变了缓冲区buf的内容是否会影响到主线程
    waitpid(chdtid_CLONE_VM, &status, 0);
    // 打印此时缓冲区buf中的内容
    printf("parent read buf: %s\n", buf);
    printf("------------------------------------------------------------------\n\n");


    // 测试参数CLONE_VFORK
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_VFORK\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    chdtid_CLONE_VFORK = clone(CLONE_VFORK_func, stack_CLONE_VFORK + STACK_SIZE, flags | SIGCHLD, buf);
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
    chdtid_CLONE_VFORK = clone(CLONE_VFORK_func, stack_CLONE_VFORK + STACK_SIZE, flags | SIGCHLD, buf);
    if(chdtid_CLONE_VFORK == -1) {
        perror("CLONE_VFORK after:clone()");
        exit(1);
    }
    // 在waitpid()函数之前打印主线程的信息，观察主线程是否会等待子线程执行完后再执行
    printf("I am main thread, my pid = %d\n", getpid());
    waitpid(chdtid_CLONE_VFORK, &status, 0);
    printf("------------------------------------------------------------------\n\n");


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

    chdtid_CLONE_FILES = clone(CLONE_FILES_func, stack_CLONE_FILES + STACK_SIZE, flags | SIGCHLD, &fd);
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

    chdtid_CLONE_FILES = clone(CLONE_FILES_func, stack_CLONE_FILES + STACK_SIZE, flags | SIGCHLD, &fd);
    if(chdtid_CLONE_FILES == -1) {
        perror("CLONE_FILES after:clone()");
        exit(1);
    }

    // 等待子线程执行完后主线程再继续执行，测试子线程改变了文件的FD_CLOEXEC参数是否会影响到主线程
    waitpid(chdtid_CLONE_FILES, &status, 0);
    // 查看文件的FD_CLOEXEC参数
    printf("\nIn the last, the FD_COLEXEC of fd in main thread is %d\n", fcntl(fd, F_GETFD));
    printf("------------------------------------------------------------------\n\n");
    

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
    chdtid_CLONE_SIGHAND = clone(CLONE_SIGHAND_func, stack_CLONE_SIGHAND + STACK_SIZE, flags | CLONE_VM | SIGCHLD, NULL);
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
    chdtid_CLONE_SIGHAND = clone(CLONE_SIGHAND_func, stack_CLONE_SIGHAND + STACK_SIZE, flags | CLONE_VM | SIGCHLD, NULL);
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
    chdtid_CLONE_NEWIPC = clone(CLONE_NEWIPC_func, stack_CLONE_NEWIPC + STACK_SIZE, flags | SIGCHLD, NULL);
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
    chdtid_CLONE_NEWIPC = clone(CLONE_NEWIPC_func, stack_CLONE_NEWIPC + STACK_SIZE, flags | SIGCHLD, NULL);
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


    // 测试参数CLONE_THREAD
    printf("------------------------------------------------------------------\n");
    printf("Before set flags to CLONE_THREAD\n");
    // 设置参数为0
    flags = 0;
    printf("Result:\n");
    // 从Linux 2.5.35开始，如果指定了CLONE_THREAD，则必须同时指定CLONE_SIGHAND。而从Linux 2.6.0开始，指定CLONE_SIGHAND的同时也必须指定CLONE_VM
    chdtid_CLONE_THREAD = clone(CLONE_THREAD_func, stack_CLONE_THREAD + STACK_SIZE, flags | CLONE_VM | CLONE_SIGHAND | SIGCHLD, NULL);
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
    chdtid_CLONE_THREAD = clone(CLONE_THREAD_func, stack_CLONE_THREAD + STACK_SIZE, flags | CLONE_VM | CLONE_SIGHAND | SIGCHLD, NULL);
    if(chdtid_CLONE_THREAD == -1) {
        perror("CLONE_THREAD after:clone()");
        exit(1);
    }
    // 打印主线程的进程号和父进程号
    printf("I am main thread, my pid = %d, my ppid = %d\n", getpid(), getppid());
    // 休眠1s以便子线程结束
    sleep(1);
    printf("------------------------------------------------------------------\n\n");

    free(stack_CLONE_PARENT);
    free(stack_CLONE_VM);
    free(stack_CLONE_VFORK);
    free(stack_CLONE_FILES);
    free(stack_CLONE_SIGHAND);
    free(stack_CLONE_NEWIPC);
    free(stack_CLONE_THREAD);

    stack_CLONE_PARENT = NULL;
    stack_CLONE_VM = NULL;
    stack_CLONE_VFORK = NULL;
    stack_CLONE_FILES = NULL;
    stack_CLONE_SIGHAND = NULL;
    stack_CLONE_NEWIPC = NULL;
    stack_CLONE_THREAD = NULL;

    return 0;
}
