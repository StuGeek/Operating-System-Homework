// 文件ipc-shmcon.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/shm.h>
#include <fcntl.h>

#include "ipc-shmcon.h"

#define OP_PUSH 1
#define OP_POP 2
#define OP_FIND 3
#define OP_MODIFY 4

char names[30][30] = {"name1", "name2", "name3", "name4", "name5", 
                        "name6", "name7", "name8", "name9", "name10",
                            "name11", "name12", "name13", "name14", "name15", 
                                "name16", "name17", "name18", "name19", "name20",
                                    "name21", "name22", "name23", "name24", "name25", 
                                        "name26", "name27", "name28", "name29", "name30"};

//根据op的值选择操作种类，1为插入，2为删除，3为查找，4为修改
void operation(MinHeap heap, int op) {
    switch (op) {
        case OP_PUSH: {
            printf("Push\nResult: ");
            int pushId = rand() % 30;
            pushHeapByIdAndName(heap, pushId, names[pushId]);
            printf("stu(id: %d name: %s) ", pushId, names[pushId]);
            printf("is pushed into the heap\n");
            break;
        }

        case OP_POP: {
            printf("Pop\nResult: ");
            if (heap->size == 0) {
                printf("The heap is already empty\n");
            }
            else {
                printf("The student(id: %d name: %s) ", heap->list[0].id, heap->list[0].name);
                printf("is pop from the heap\n");
            }
            popHeap(heap);
            break;
        }

        case OP_FIND: {
            printf("Find\nResult: ");
            int findId = rand() % 30;
            int index = findHeapById(heap, findId, 0);
            if (index == -1) {
                printf("Can't find the student(id: %d)\n", findId);
            }
            else {
                printf("The target student's(id: %d) index is %d\n", findId, index);
            }
            break;
        }

        case OP_MODIFY: {
            printf("Modify\nResult: ");
            if (heap->size == 0) {
                printf("The heap is already empty\n");
            }
            else {
                int modifyIndex = rand() % heap->size;
                int nextId = rand() % 30;
                printf("The target student(id: %d name: %s) -> ", heap->list[modifyIndex].id, heap->list[modifyIndex].name);
                modifyIdAndNameByIndex(heap, modifyIndex, nextId, names[nextId]);
                printf("(id: %d name: %s)\n", heap->list[modifyIndex].id, heap->list[modifyIndex].name);
            }
            break;
        }
    }
}

int main(int argc, char *argv[]) {
    struct stat fileattr;
    key_t key; // of type int
    int shmid; // shared memory ID
    void *shmptr;
    struct shared_struct *shared; // structured shm
    char pathname[80];
    int shmsize, ret;

    srand((unsigned) time(NULL));

    shmsize = sizeof(struct shared_struct); // 共享内存的大小

    // 在编译命令"./a.out"后面还要加上文件路径名
    if(argc <2) {
        printf("Usage: ./a.out pathname\n");
        return EXIT_FAILURE;
    }
    strcpy(pathname, argv[1]);

    if(stat(pathname, &fileattr) == -1) {
        ret = creat(pathname, O_RDWR);
        if (ret == -1) {
            ERR_EXIT("creat()");
        }
        printf("shared file object created\n");
    }
 
    key = ftok(pathname, 0x27); // 0x27 a project ID 0x0001 - 0xffff, 8 least bits used
    if(key == -1) {
        ERR_EXIT("shmcon: ftok()");
    }

    shmid = shmget((key_t)key, shmsize, 0666|PERM);
    if(shmid == -1) {
        ERR_EXIT("shmcon: shmget()");
    }

    shmptr = shmat(shmid, 0, 0); // returns the virtual base address mapping to the shared memory, *shmaddr=0 decided by kernel

    if(shmptr == (void *)-1) {
        ERR_EXIT("shmcon: shmat()");
    }
    
    shared = (StaticLinkList *)shmptr; // 创建共享内存中使用的结构体 */
    initialStaticLinkList(shared); //初始化结构体
    shared->lock = 0; //逻辑值lock设为0，代表进程可以执行
    shared->operation_time = 0; //对结构体的操作次数，方便测试用
	
    //方便测试，当结构体中的元素个数为5时，就退出
    while (shared->size < 5) {
        //当逻辑值lock等于1时，进程休眠不执行
        while (shared->lock == 1) {
            sleep(1);
        }
        wait(0);
        //进程执行时，将逻辑值lock设为1，防止其它进程进入共享内存
        shared->lock = 1;
        //对共享结构的操作次数加一，方便测试用
        shared->operation_time++;
        printf("Times: %d\t", shared->operation_time);
        printf("Process id: %d\tOpertion: ", getpid());
        //随机产生操作种类，包括对小顶堆的插入、删除、查找、修改
        int op = rand() % 4 + 1;
        operation(shared, op);
        //打印共享结构，方便测试用
        printHeapAndLists(shared);
        //休眠5s，尽量避免多进程冲突，同时方便测试
        sleep(5);
        //将逻辑值设为0，其它进程可进入共享内存执行
        shared->lock = 0;
    }

    //结束时，打印所有进程总操作次数，打印最后共享结构中的内容，方便测试用
    printf("Total operation times: %d\n", shared->operation_time);
    printf("The final situation of the shared struct:\n");
    printHeapAndLists(shared);

    //记录退出进程的个数，方便最后释放共享内存
    shared->lock++;
    int numOfProExit = shared->lock;

    if(shmdt(shmptr) == -1) {
        ERR_EXIT("shmcon: shmdt()");
    }

    //所有进程退出后，释放共享内存，这里选择的进程数是4,不等所有进程退出就释放会报错
    if (numOfProExit >= 4 && shmctl(shmid, IPC_RMID, 0) == -1) {
        ERR_EXIT("shmcon: shmctl(IPC_RMID)");
    }

    exit(EXIT_SUCCESS);
}
