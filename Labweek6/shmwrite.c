//文件shmwrite.c，充当writer角色
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>
#include <sys/shm.h>

#include "shmdata.h"
 
 //学生信息多字符串读写
int main(int argc, char *argv[])
{
    void *shmptr = NULL;
    struct shared_struct *shared = NULL;
    int shmid;
    key_t key;

    char buffer[BUFSIZ + 1]; // 8192bytes, saved from stdin
    
    sscanf(argv[1], "%x", &key);

    shmid = shmget((key_t)key, sizeof(struct shared_struct), 0666|PERM);
    if (shmid == -1) {
        ERR_EXIT("shmwite: shmget()");
    }

    shmptr = shmat(shmid, 0, 0);
    if(shmptr == (void *)-1) {
        ERR_EXIT("shmwrite: shmat()");
    }
    
    shared = (struct shared_struct *)shmptr;
    
    while (1) {
        while ((shared->rear + 1) % (TEXT_NUM + 1) == shared->front) {
            sleep(1); // 循环队列为满时不能写
        }

        printf("Enter some text: ");
            // 从标准输入区键盘输入数据
        fgets(buffer, BUFSIZ, stdin);
        strncpy(shared->mtext[shared->rear].text, buffer, TEXT_SIZE);

            // 展示shared buffer中的信息
        printf("\n------------------ shared buffer ------------------\n");
            // 打印shared buffer中的信息个数
        printf("The number of elements in the shared buffer is %d\n", (shared->rear + TEXT_NUM + 2 - shared->front) % (TEXT_NUM + 1));
        int i = shared->front;
        while(i != (shared->rear + 1) % (TEXT_NUM + 1)) {
            printf("%s", shared->mtext[i].text);
            i = (i + 1) % (TEXT_NUM + 1);
        }
        printf("------------------ shared buffer ------------------\n\n");

            // 数据写入循环队列后，循环队列队尾下标加一
        shared->rear = (shared->rear + 1) % (TEXT_NUM + 1);
 
        if(strncmp(buffer, "end", 3) == 0) {
            // 提示不能再写入任何信息到shared buffer
            printf("You can't enter any text now\n");
            break;
        }

            // 循环队列满后，提示不能再写入直到有信息读出
        if ((shared->rear + 1) % (TEXT_NUM + 1) == shared->front) {
            printf("The queue is full, please wait until you see \"Enter some text: \"\n");
        }
    }
       // detach the shared memory
    if(shmdt(shmptr) == -1) {
        ERR_EXIT("shmwrite: shmdt()");
    }

    sleep(1);
    exit(EXIT_SUCCESS);
}

// 学生信息组织结构体
/*int main(int argc, char *argv[])
{
    void *shmptr = NULL;
    struct shared_struct *shared = NULL;
    int shmid;
    key_t key;

    char buffer[BUFSIZ + 1]; // 8192bytes, saved from stdin
    
    sscanf(argv[1], "%x", &key);

    shmid = shmget((key_t)key, sizeof(struct shared_struct), 0666|PERM);
    if (shmid == -1) {
        ERR_EXIT("shmwite: shmget()");
    }

    shmptr = shmat(shmid, 0, 0);
    if(shmptr == (void *)-1) {
        ERR_EXIT("shmwrite: shmat()");
    }
    
    shared = (struct shared_struct *)shmptr;
    
    while (1) {
        while ((shared->rear + 1) % (TEXT_NUM + 1) == shared->front) {
            sleep(1); // 循环队列为满时不能写
        }

        printf("Enter the student's id, name, department: \n");
            // 从标准输入区键盘输入数据
        fgets(buffer, BUFSIZ, stdin);
        sscanf(buffer, "%d %s %s", &shared->students[shared->rear].id, 
                shared->students[shared->rear].name, shared->students[shared->rear].department);
        printf("\n\n%d %d %s %s\n\n", shared->rear, shared->students[shared->rear].id, 
                shared->students[shared->rear].name, shared->students[shared->rear].department);

        int id = shared->students[shared->rear].id;

            // 展示shared buffer中的信息
        printf("\n------------------ shared buffer ------------------\n");
            // 打印shared buffer中的信息个数
        printf("The number of elements in the shared buffer is %d\n", (shared->rear + TEXT_NUM + 2 - shared->front) % (TEXT_NUM + 1));
        int i = shared->front;
        while(i != (shared->rear + 1) % (TEXT_NUM + 1)) {
            printf("id:%d name:%s department:%s\n", shared->students[i].id, 
                shared->students[i].name, shared->students[i].department);
            i = (i + 1) % (TEXT_NUM + 1);
        }
        printf("------------------ shared buffer ------------------\n\n");

            // 数据写入循环队列后，循环队列队尾下标加一
        shared->rear = (shared->rear + 1) % (TEXT_NUM + 1);
 
        if(id == -1) {
            // 提示不能再写入任何信息到shared buffer
            printf("You can't enter any text now\n");
            break;
        }

            // 循环队列满后，提示不能再写入直到有信息读出
        if ((shared->rear + 1) % (TEXT_NUM + 1) == shared->front) {
            printf("The queue is full, please wait until you see \"Enter some text: \"\n");
        }
    }
       // detach the shared memory
    if(shmdt(shmptr) == -1) {
        ERR_EXIT("shmwrite: shmdt()");
    }

    sleep(1);
    exit(EXIT_SUCCESS);
}*/
