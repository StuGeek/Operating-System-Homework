//threadpools.c文件
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sched.h>
#include <pthread.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/ipc.h>
#include <sys/time.h>
#include <sys/msg.h>
#include <sys/syscall.h>
#include <semaphore.h>
#include <fcntl.h>
#include <unistd.h>

#define gettid() syscall(__NR_gettid)
  /* wrap the system call syscall(__NR_gettid), __NR_gettid = 224 */
#define gettidv2() syscall(SYS_gettid) /* a traditional wrapper */

#define THREADS_NUM 10 // 线程池中的线程个数
#define TASK_QUEUE_MAX_SIZE 12 // 任务的等待队列的最大长度，等待队列中的最大任务个数为长度减一
#define TASK_NUM 100 // 要执行的任务总数

// 线程池中每个线程执行的任务的结构体
typedef struct {
    void *(*function)(void *); // 执行函数
    void *arg; // 参数
} Task;

// 任务循环队列的数据结构
typedef struct {
    Task tasks[TASK_QUEUE_MAX_SIZE]; // 任务队列数组
    int front; // 队首下标
    int rear; // 队尾下标
} TaskQueue;

// 线程池数据结构
typedef struct {
    pthread_t threads[THREADS_NUM]; // 线程数组
    TaskQueue taskQueue; // 任务队列
    int taskSum; // 剩余任务总数，结束程序用
    sem_t sem_mutex; // 互斥信号量
} Threadpools;

// 线程池中每个线程执行的任务
static void *executeTask(void *arg) {
    // 向每个线程传入的参数是线程池
    Threadpools *pools = (Threadpools *)arg;
    while (1) {
        // 等待互斥信号量大于0，防止临界冲突，然后将互斥锁信号量减一，继续执行
        sem_wait(&pools->sem_mutex);
        // 当任务队列为空时
        while (pools->taskQueue.front == pools->taskQueue.rear) {
            // 如果已经没有剩余任务要处理，那么退出线程
            if (pools->taskSum == 0) {
                printf("Thread %ld exits.\n", gettid());
                sem_post(&pools->sem_mutex);
                pthread_exit(NULL);
            }
            // 否则等待任务队列中有任务后再取任务进行执行
            printf("Thread %ld is waiting for a task.\n", gettid());
            sleep(1);         
        }
        // 剩余任务总数减一
        pools->taskSum--;
        // 获取任务队列队首的任务
        Task task;
        int front = pools->taskQueue.front;
        task.function = pools->taskQueue.tasks[front].function;
        task.arg = pools->taskQueue.tasks[front].arg;
        // 循环队列队首下标加一
        pools->taskQueue.front = (front + 1) % TASK_QUEUE_MAX_SIZE;

        // 将互斥锁信号量加一，允许其它线程执行
        sem_post(&pools->sem_mutex);
        
        // 执行任务
        (*(task.function))(task.arg);
    }
}

// 初始化线程池
void initThreadpools(Threadpools *pools) {
    int ret;
    // 任务队列的队首和队尾的坐标都为0
    pools->taskQueue.front = 0;
    pools->taskQueue.rear = 0;
    // 线程池中剩余的任务总数设置为总任务数
    pools->taskSum = TASK_NUM;

    // 初始化互斥信号量为1
    ret = sem_init(&pools->sem_mutex, 1, 1);
    if (ret == -1) {
        perror("sem_init-mutex");
        exit(1);
    }

    // 创建线程池中的线程
    for(int i = 0; i < THREADS_NUM; ++i) {
        ret = pthread_create(&pools->threads[i], NULL, executeTask, (void *)pools);
        if(ret != 0) {
            fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
            exit(1);
        }
    }
}

// 向任务队列中添加任务
void addTask(Threadpools *pools, void *(*function)(void *arg), void *arg) {
    // 当任务队列为满时，等待有任务被取出任务队列不为满再加入队列
    while ((pools->taskQueue.rear + TASK_QUEUE_MAX_SIZE + 1 - 
                    pools->taskQueue.front) % TASK_QUEUE_MAX_SIZE == 0) {
        printf("Task %d is waiting to be added to the task queue.\n", *(int *)arg);
        sleep(1);
    }
    // 向任务队列的队尾加入任务
    Task task;
    task.function = function;
    task.arg = arg;
    int rear = pools->taskQueue.rear;
    pools->taskQueue.tasks[rear] = task;
    // 任务队列队尾下标加一
    pools->taskQueue.rear = (rear + 1) % (TASK_QUEUE_MAX_SIZE);
}

// 任务函数
void *taskFunction(void *arg) {
    // 获取每个任务的任务号
    int *numptr = (int *)arg;
    int taskId = *numptr;
    // 打印线程池中的哪个线程正在处理此任务
    printf("Thread tid = %ld is dealing with task %d\n", gettid(), taskId);
    // 每个任务休眠1s后继续执行
    printf("Task %d is sleeping for 1s.\n", taskId);
    sleep(1);
    // 打印任务完成信息和线程被复用
    printf("\t\t\t\tTask %d is finished and Thread tid = %ld is reused\n", taskId, gettid());
    return 0;
}

int main() {
    int ret;
    // 创建并初始化线程池
    Threadpools pools;
    initThreadpools(&pools);

    // 传入参数数组
    int num[TASK_NUM];
    for(int i = 0; i < TASK_NUM; ++i) {
        num[i] = i + 1;
    }

    // 向任务队列中连续添加任务
    for(int i = 0; i < TASK_NUM; ++i) {
        addTask(&pools, taskFunction, (void *)&num[i]);
    }

    // 主线程等待线程池中的线程全部结束后再继续
    for(int i = 0; i < THREADS_NUM; ++i) {
        ret = pthread_join(pools.threads[i], NULL);
        if(ret != 0) {
            fprintf(stderr, "pthread_join error: %s\n", strerror(ret));
            exit(1);
        }
    }

    // 所有任务都执行完，线程池也退出
    printf("\nAll %d tasks have been finished.\n", TASK_NUM);

    // 销毁互斥信号量
    ret = sem_destroy(&pools.sem_mutex);
    if (ret == -1) {
        perror("sem_destroy sem_mutex");
    }
}
