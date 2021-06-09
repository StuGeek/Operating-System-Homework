// scheduler.c文件
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include <pthread.h>
#include <semaphore.h>
#include <signal.h>

#define STATUS_RUNNING 1  // 运行调度状态
#define STATUS_READY 2    // 就绪调度状态
#define STATUS_WAITING 3  // 阻塞调度状态

#define POLICY_FCFS 1             // 先到先服务调度策略
#define POLICY_SJF_PEM 2          // 抢占式最短作业优先调度策略
#define POLICY_SJF_NOT_PEM 3      // 非抢占式最短作业优先调度策略
#define POLICY_PRIORITY_PEM 4     // 抢占式优先级调度策略
#define POLICY_PRIORITY_NOT_PEM 5 // 非抢占式优先级调度策略

#define MAX_TASK_NUM 100 // 最大任务个数

typedef struct node {
    int arrival_time;     // 到达时间
    int WCT;              // 最坏预期执行时间
    int priority;         // 优先级
    int schedule_status;  // 调度状态
    pthread_t ptid;       // 线程号
    sem_t wait_sem;       // 任务启动时的调度等待信号量
    struct node *next;    // 指向下一个结点的指针
} Tasknode; // 管理链队列结点结构

typedef struct {
    Tasknode *head;               // 管理链队列表头
    pthread_t sched_ptid;         // 调度器线程的线程号
    pthread_mutex_t sched_mutex;  // 调度器互斥锁
    int schedule_policy;          // 调度策略
    int finished_task;            // 完成任务的个数
} Scheduler; // 调度器结构

Scheduler sched; // 调度器
sigset_t zeromask; // 阻塞线程函数sigsuspend()所用参数
long wait_sum_time = 0; // 单个线程等待总时间

long begin_us, run_us; // 总计时器部分，测试用
struct timeval t_time;

// 初始化调度器
void init_scheduler(int task_num);
// 创建任务管理信息结点
Tasknode* creat_thread_node(int arrival_time, int WCT, int priority);

// 每个线程执行的任务
void *task_runner(void *arg);
// 调度器运行线程
void *schedule_runner(void *arg);

// 将任务信息结点按照调度策略放入管理链队列
void fcfs(Tasknode *new_node);
void sjf_pem(Tasknode *new_node);
void sjf_not_pem(Tasknode *new_node);
void priority_pem(Tasknode *new_node);
void priority_not_pem(Tasknode *new_node);

// 向管理链队列添加任务
void add_task(Tasknode *node, int sched_policy);
// 从管理链队列删除任务
void delete_task();

// 发送信号阻塞线程，直到接收到一个新的信号
void thread_wait_sighand(int signo);
// 发送信号使阻塞线程继续运行
void thread_cont_sighand(int signo);
// 调度器线程接收信号后调度器选择一个任务，即表头任务运行
void sched_run_sighand(int signo);

// 打印任务信息列表，测试用
void print_tasklist(int *arrival_time, int *WCT, int *priority, int task_num);
// 计算任务平均等待时间
double cal_aver_wait_time(int *arrival_time, int *WCT, int *priority, int task_num, int sched_policy);

// 调度器运行线程
void *schedule_runner(void *arg) {
    int task_num = *(int *)arg;
    // 当完成任务个数等于总任务个数时，调度器线程退出
    while (sched.finished_task != 5 * task_num);
    pthread_exit(0);
}

// 创建任务管理信息结点
Tasknode* creat_thread_node(int arrival_time, int WCT, int priority) {
    Tasknode *new_node = (Tasknode *)malloc(sizeof(Tasknode));
    // 设置线程的到达时间，最长预期执行时间，优先级
    new_node->arrival_time = arrival_time;
    new_node->WCT = WCT;
    new_node->priority = priority;
    new_node->next = NULL;
    // 初始化线程的调度等待信号量为0
    int ret = sem_init(&new_node->wait_sem, 1, 0);
    if (ret == -1) {
        perror("creat_thread_node(): sem_init-wait_sem");
        exit(1);
    }
    return new_node;
}

// 初始化调度器
void init_scheduler(int task_num) {
    // 管理链队列的表头为空
    sched.head = NULL;
    // 调度策略默认为先到先服务
    sched.schedule_policy = POLICY_FCFS;
    // 已经完成任务个数为0
    sched.finished_task = 0;
    // 初始化调度器互斥锁
    pthread_mutex_init(&sched.sched_mutex, NULL);
    // 创建调度器运行线程
    int ret = pthread_create(&sched.sched_ptid, NULL, &schedule_runner, &task_num);
    if (ret != 0) {
        fprintf(stderr, "init_scheduler(): pthread_create error: %s\n", strerror(ret));
        exit(1);
    }
}

// 将任务信息结点按照先到先服务策略放入管理链队列
void fcfs(Tasknode *new_node) {
    // 如果管理链队列的表头为空，那么直接插入结点
    if (sched.head == NULL) {
        sched.head = new_node;
        return;
    }

    // 找到管理链队列的表尾，插入结点
    Tasknode *cur_node = sched.head;
    while (cur_node->next != NULL) {
        cur_node = cur_node->next;
    }
    cur_node->next = new_node;
}

// 将任务信息结点按照抢占式最短作业优先策略放入管理链队列
void sjf_pem(Tasknode *new_node) {
    // 如果管理链队列的表头为空，那么直接插入结点
    if (sched.head == NULL) {
        sched.head = new_node;
        return;
    }
    // 如果结点的WCT小于表头结点的WCT，那么直接在表头结点之前插入结点
    else if (new_node->WCT < sched.head->WCT) {
        new_node->next = sched.head;
        sched.head = new_node;
        return;
    }

    Tasknode *cur_node = sched.head;
    Tasknode *pre_node = NULL;
    
    while (cur_node != NULL && new_node->WCT >= cur_node->WCT) {
        pre_node = cur_node;
        cur_node = cur_node->next;
    }
    pre_node->next = new_node;
    new_node->next = cur_node;
}

// 将任务信息结点按照非抢占式最短作业优先策略放入管理链队列
void sjf_not_pem(Tasknode *new_node) {
    // 如果管理链队列的表头为空，那么直接插入结点
    if (sched.head == NULL) {
        sched.head = new_node;
        return;
    }

    // 寻找管理链队列中前一个结点的WCT小于等于结点，后一个结点的WCT大于结点的位置插入结点，如果没有那么就在表尾插入结点
    Tasknode *cur_node = sched.head->next;
    Tasknode *pre_node = sched.head;
    while (cur_node != NULL && new_node->WCT >= cur_node->WCT) {
        pre_node = cur_node;
        cur_node = cur_node->next;
    }
    pre_node->next = new_node;
    new_node->next = cur_node;
}

// 将任务信息结点按照抢占式优先级策略放入管理链队列
void priority_pem(Tasknode *new_node) {
    // 如果管理链队列的表头为空，那么直接插入结点
    if (sched.head == NULL) {
        sched.head = new_node;
        return;
    }
    // 如果结点的优先级大于表头结点的优先级，那么直接在表头结点之前插入结点
    else if (new_node->priority > sched.head->priority) {
        new_node->next = sched.head;
        sched.head = new_node;
        return;
    }

    // 寻找管理链队列中前一个结点的WCT小于等于结点，后一个结点的WCT大于结点的位置插入结点，如果没有那么就在表尾插入结点
    Tasknode *cur_node = sched.head;
    Tasknode *pre_node = NULL;
    while (cur_node != NULL && new_node->priority <= cur_node->priority) {
        pre_node = cur_node;
        cur_node = cur_node->next;
    }
    pre_node->next = new_node;
    new_node->next = cur_node;
}

// 将任务信息结点按照非抢占式优先级策略放入管理链队列
void priority_not_pem(Tasknode *new_node) {
    // 如果管理链队列的表头为空，那么直接插入结点
    if (sched.head == NULL) {
        sched.head = new_node;
        return;
    }

    // 寻找管理链队列中前一个结点的优先级大于等于结点，后一个结点的优先级小于结点的位置插入结点，如果没有那么就在表尾插入结点
    Tasknode *cur_node = sched.head->next;
    Tasknode *pre_node = sched.head;
    while (cur_node != NULL && new_node->priority <= cur_node->priority) {
        pre_node = cur_node;
        cur_node = cur_node->next;
    }
    pre_node->next = new_node;
    new_node->next = cur_node;
}

// 向管理链队列添加任务
void add_task(Tasknode *node, int sched_policy) {
    // 获取调度器的互斥锁，防止其它线程更改调度器
    pthread_mutex_lock(&sched.sched_mutex);
    // 如果有任务正在运行，那么先阻塞这个任务，将这个任务的调度状态改为就绪态
    if (sched.head != NULL) {
        pthread_kill(sched.head->ptid, SIGUSR1);
        sched.head->schedule_status = STATUS_READY;
    }
    // 添加的任务信息结点的调度状态为阻塞态
    node->schedule_status = STATUS_WAITING;

    // 根据调度策略，向管理链队列中插入任务信息结点
    switch (sched_policy) {
        case POLICY_FCFS :
            fcfs(node);
            break;
        case POLICY_SJF_PEM:
            sjf_pem(node);
            break;
        case POLICY_SJF_NOT_PEM:
            sjf_not_pem(node);
            break;
        case POLICY_PRIORITY_PEM:
            priority_pem(node);
            break;
        case POLICY_PRIORITY_NOT_PEM:
            priority_not_pem(node);
            break;
    }
    sleep(0);
    // 向调度器线程发送信号，选取适当的任务执行
    pthread_kill(sched.sched_ptid, SIGUSR2);

    // 释放调度器的互斥锁
    pthread_mutex_unlock(&sched.sched_mutex);
}

// 从管理链队列删除任务
void delete_task() {
    // 获取调度器的互斥锁，防止其它线程更改调度器
    pthread_mutex_lock(&sched.sched_mutex);

    // 运行完了的任务结点是管理链队列的头结点，释放其资源
    Tasknode *temp = sched.head;
    sched.head = sched.head->next;
    sem_destroy(&temp->wait_sem);
    free(temp);
    temp = NULL;
    // 如果管理链队列中还有任务，那么继续运行
    if (sched.head != NULL) {
        pthread_kill(sched.head->ptid, SIGCONT);
    }

    // 释放调度器的互斥锁
    pthread_mutex_unlock(&sched.sched_mutex);
}

// 每个线程执行的任务
void *task_runner(void *arg) {
    int ret;
    // 计时器部分
    long start_us, end_us;
    struct timeval t;

    // 获取每个线程的任务信息结点
    Tasknode *task_node = (Tasknode *)arg;
    struct timespec req, rem;
    // 设置这个任务信息结点的线程号
    task_node->ptid = pthread_self();
    // 设置线程运行时间为任务信息结点中的最长预期执行时间
    req.tv_sec = task_node->WCT;
    req.tv_nsec = 0;

    // 线程休眠任务信息结点中的到达时间后再加入管理链队列，模拟到达时间
    sleep(task_node->arrival_time);
    // 获取任务到达时间
    gettimeofday(&t, 0);
    start_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;
    add_task(task_node, sched.schedule_policy);

    // 获取任务开始时间
    gettimeofday(&t_time, 0);
    run_us = (long)(t_time.tv_sec * 1000 * 1000) + t_time.tv_usec;
    // 打印这个执行任务的线程的开始任务时间点，测试用
    printf("Task ptid = %ld starts at Time: %lf sec\n", pthread_self(), (double)(run_us - begin_us) / 1000000.0);
    // 线程先阻塞，等待调度器调度
    sem_wait(&task_node->wait_sem);
    
    // 线程休眠时间模拟执行时间，如果有信号中断，ret返回-1，剩余时间存储rem中
    ret = nanosleep(&req, &rem);
    // 返回中断后继续休眠剩余时间模拟完整执行时间
    while (ret < 0) {
        req = rem;
        ret = nanosleep(&req, &rem);
    }

    // 获取结束时间
    gettimeofday(&t, 0);
    end_us = (long)(t.tv_sec * 1000 * 1000) + t.tv_usec;
    // 打印任务结束时间
    gettimeofday(&t_time, 0);
    run_us = (long)(t_time.tv_sec * 1000 * 1000) + t_time.tv_usec;
    // 打印这个执行任务的线程的结束任务时间点，测试用
    printf("Task ptid = %ld ends at Time: %lf sec\n", pthread_self(), (double)(run_us - begin_us) / 1000000.0);
    // 等待时间为实际运行时间减去预期执行时间
    wait_sum_time += end_us - start_us - task_node->WCT * 1000 * 1000;
    // 执行完后从管理链队列中删除任务结点
    delete_task();
    // 调度器已完成的任务数加一
    sched.finished_task++;
    
    pthread_exit(0);
}

// 发送信号阻塞线程，直到接收到一个新的信号
void thread_wait_sighand(int signo) {
    // 获取当前时间
    gettimeofday(&t_time, 0);
    run_us = (long)(t_time.tv_sec * 1000 * 1000) + t_time.tv_usec;
    // 打印这个执行任务的线程的阻塞时间点，测试用
    printf("Task ptid = %ld stops at Time: %lf sec\n", pthread_self(), (double)(run_us - begin_us) / 1000000.0);
    sigsuspend(&zeromask);
}

// 发送信号使阻塞线程继续运行
void thread_cont_sighand(int signo) {
    // 获取当前时间
    gettimeofday(&t_time, 0);
    run_us = (long)(t_time.tv_sec * 1000 * 1000) + t_time.tv_usec;
    // 打印这个执行任务的线程的阻塞之后继续运行时间点，测试用
    printf("Task ptid = %ld continues at Time: %lf sec\n", pthread_self(), (double)(run_us - begin_us) / 1000000.0);
}

// 调度器线程接收信号后调度器选择一个任务，即表头任务运行
void sched_run_sighand(int signo) {
    // 如果这个任务处于阻塞态，那么先转为就绪态，再转为运行态，用sem_post()函数开始运行任务
    if (sched.head->schedule_status == STATUS_WAITING) {
        sched.head->schedule_status = STATUS_READY;
        sched.head->schedule_status = STATUS_RUNNING;
        sem_post(&sched.head->wait_sem);
        // 获取任务执行时间点 
        gettimeofday(&t_time, 0);
        run_us = (long)(t_time.tv_sec * 1000 * 1000) + t_time.tv_usec;
        // 打印这个执行任务的线程的运行任务时间点，测试用
        printf("Task ptid = %ld starts to run at Time: %lf sec\n", sched.head->ptid, (double)(run_us - begin_us) / 1000000.0);
    }
    // 如果这个任务处于就绪态，那么转为运行态，发送信号使其继续运行
    else if (sched.head->schedule_status == STATUS_READY) {
        sched.head->schedule_status = STATUS_RUNNING;
        pthread_kill(sched.head->ptid, SIGCONT);
    }
}

// 打印任务信息列表，测试用
void print_tasklist(int *arrival_time, int *WCT, int *priority, int task_num) {
    printf("Task list:\n");
    printf("------------------------------\n");
    printf("|Id|Arrival time|WCT|Priority|\n");
    printf("------------------------------\n");
    for (int i = 0; i < task_num; ++i) {
        printf("|%2d|    %3d     |%3d|   %2d   |\n", i + 1, arrival_time[i], WCT[i], priority[i]);
    }
    printf("------------------------------\n");
    printf("\n");
}

// 计算任务平均等待时间
double cal_aver_wait_time(int *arrival_time, int *WCT, int *priority, int task_num, int sched_policy) {
    int ret;
    pthread_t ptid[MAX_TASK_NUM];
    double aver_wait_time;
    printf("\n----------------------------------------------------------\n");
    printf("schedule policy: ");
    // 打印调度策略
    switch (sched_policy) {
        case POLICY_FCFS :
            printf("FCFS\n\n");
            break;
        case POLICY_SJF_PEM:
            printf("SJF(preemptive)\n\n");
            break;
        case POLICY_SJF_NOT_PEM:
            printf("SJF(not preemptive)\n\n");
            break;
        case POLICY_PRIORITY_PEM:
            printf("Priority(preemptive)\n\n");
            break;
        case POLICY_PRIORITY_NOT_PEM:
            printf("Priority(not preemptive)\n\n");
            break;
    }
    // 打印任务列表
    print_tasklist(arrival_time, WCT, priority, task_num);
    // 设置调度策略
    sched.schedule_policy = sched_policy;
    wait_sum_time = 0;
    // 获取计时开始时间
    gettimeofday(&t_time, 0);
    begin_us = (long)(t_time.tv_sec * 1000 * 1000) + t_time.tv_usec;
    // 根据信息创建任务信息结点和相应的线程
    for (int i = 0; i < task_num; i++) {
        Tasknode *new_node = creat_thread_node(arrival_time[i], WCT[i], priority[i]);
        ret = pthread_create(&ptid[i], NULL, &task_runner, (void *)new_node);
        if(ret != 0) {
            fprintf(stderr, "pthread_create error: %s\n", strerror(ret));
            exit(1);
        }
        printf("Task%d ptid:%ld\n", i + 1, ptid[i]);
    }
    printf("\n");
    // 主线程等待所有子线程运行结束后再继续执行
    for (int i = 0; i < task_num; i++) {
        ret = pthread_join(ptid[i], NULL);
        if(ret != 0) {
            fprintf(stderr, "pthread_join error: %s\n", strerror(ret));
            exit(1);
        }
    }
    // 计算任务平均等待时间
    printf("\nThe waiting time = %lf sec\n", (double)wait_sum_time / 1000000.0);
    aver_wait_time = (double)wait_sum_time / 1000000.0 / (double)task_num;
    printf("The average of waiting time = %lf sec\n", aver_wait_time);
    printf("----------------------------------------------------------\n");

    return aver_wait_time;
}

int main() {
    int arrival_time[MAX_TASK_NUM];
    int WCT[MAX_TASK_NUM];
    int priority[MAX_TASK_NUM];

    int task_num;
    printf("Please input the number of tasks: ");
    scanf("%d", &task_num);

    // 设置不同捕捉信号的信号处理函数
    struct sigaction act1, act2, act3;
    memset(&act1, 0, sizeof(act1));
    memset(&act2, 0, sizeof(act2));
    memset(&act3, 0, sizeof(act3));
    sigemptyset(&act1.sa_mask);
    sigemptyset(&act2.sa_mask);
    sigemptyset(&act3.sa_mask);
    act1.sa_flags = 0;
    act2.sa_flags = 0;
    act3.sa_flags = 0;
    act1.sa_handler = thread_wait_sighand;
    act2.sa_handler = thread_cont_sighand;
    act3.sa_handler = sched_run_sighand;
    // 设置捕捉到SIGUSR1后信号处理函数为使线程阻塞
    sigaction(SIGUSR1, &act1, NULL);
    // 设置捕捉到SIGCONT后信号处理函数为使阻塞的线程继续
    sigaction(SIGCONT, &act2, NULL);
    // 设置捕捉到SIGUSR2后信号处理函数为使调度器选择一个任务运行
    sigaction(SIGUSR2, &act3, NULL);

    // 初始化调度器
    init_scheduler(task_num);

    // 输入每个任务的到达时间，最长预期运行时间，优先级等
    for (int i = 0; i < task_num; i++) {
        printf("Please input task%d's arrival_time, WCT, priority:\n", i + 1);
        scanf("%d %d %d", &arrival_time[i], &WCT[i], &priority[i]);
    }

    double aver_wait_time_fcfs = cal_aver_wait_time(arrival_time, WCT, priority, task_num, POLICY_FCFS);
    double aver_wait_time_sjf_pem = cal_aver_wait_time(arrival_time, WCT, priority, task_num, POLICY_SJF_PEM);
    double aver_wait_time_sjf_not_pem = cal_aver_wait_time(arrival_time, WCT, priority, task_num, POLICY_SJF_NOT_PEM);
    double aver_wait_time_priority_pem = cal_aver_wait_time(arrival_time, WCT, priority, task_num, POLICY_PRIORITY_PEM);
    double aver_wait_time_priority_not_pem = cal_aver_wait_time(arrival_time, WCT, priority, task_num, POLICY_PRIORITY_NOT_PEM);

    // 打印不同调度策略平均等待时间列表
    printf("\nAverage waiting time list(sec):\n");
    printf("-----------------------------------------------\n");
    printf("|         Policy         |Average waiting time|\n");
    printf("-----------------------------------------------\n");
    printf("|          FCFS          |     %10lf     |\n", aver_wait_time_fcfs);
    printf("|     SJF(preemptive)    |     %10lf     |\n", aver_wait_time_sjf_pem);
    printf("|   SJF(not preemptive)  |     %10lf     |\n", aver_wait_time_sjf_not_pem);
    printf("|  Priority(preemptive)  |     %10lf     |\n", aver_wait_time_priority_pem);
    printf("|Priority(not preemptive)|     %10lf     |\n", aver_wait_time_priority_not_pem);
    printf("-----------------------------------------------\n");
}
