# 操作系统实验报告18

## 实验内容

+ 实验内容：硬盘调度。
  + 编写 C 程序模拟实现课件 Lecture25 中的硬盘柱面访问调度算法
    包括 FCFS、SSTF、SCAN、C-SCAN、LOOK、C-LOOK，并设计输入用例验证结果。

## 实验环境

+ 架构：Intel x86_64 (虚拟机)
+ 操作系统：Ubuntu 20.04
+ 汇编器：gas (GNU Assembler) in AT&T mode
+ 编译器：gcc

## 技术日志

### 实验内容原理

+ 磁盘
  + 磁盘或硬盘为现代计算机系统提供大量外存。在概念上磁盘比较简单。每个盘片为平的圆状，如同CD一样。盘片的两面都涂着磁质材料。通过在盘片上进行磁性记录可以保存信息。
    + 读写磁头“飞行”在一个盘片的表面上方。磁头附着在磁臂上，磁臂将所有磁头作为一个整体而一起移动。盘片的表面逻辑地分成圆形磁道，再细分为扇区。同一磁臂位置的磁道集合形成了柱面。每个磁盘驱动器有数千个同心柱面，而每个磁道可能包括数百个扇区。常见磁盘驱动器的存储容量按GB来计算。
    + 移动磁头的磁盘装置图：
      ![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/1.png)
    + 当使用磁盘时，驱动器电机高速旋转磁盘。大多数驱动器每秒旋转60~250次，按每分钟转数(RPM)来计。普通驱动器的转速为5400、7200、10000和15000RPM。磁盘速度有两部分。
    + 传输速率是在驱动器和计算机之间的数据流的速率。
    + 定位时间或随机访问时间包括两部分:
      + 寻道时间（移动磁臂到所要柱面的所需时间）
      + 旋转延迟（旋转磁臂到所要扇区的所需时间）
    + 典型的磁盘可以按每秒数兆字节的速率来传输，并且寻道时间和旋转延迟为数毫秒。
+ 磁盘调度
  + 操作系统的职责之一是有效使用硬件。
    + 对于磁盘驱动器，满足这个要求具有较快的访问速度和较宽的磁盘带宽。
  + 对于磁盘，访问时间包括两个主要部分
    + 寻道时间是磁臂移动磁头到包含目标扇区的柱面的时间。
    + 旋转延迟是磁盘旋转目标扇区到磁头下的额外时间。
    + 假设寻道时间约等价于寻道距离
  + 磁盘带宽是传输字节的总数除以从服务请求开始到最后传递结束时的总时间。
  + 通过管理磁盘IO请求的处理次序，可以改善访问时间和带宽。
  + 每当进程需要进行磁盘I/O操作时，它就向操作系统发出一个系统调用。这个请求需要些信息
    + 这个操作是输入还是输出
    + 传输的磁盘地址是什么
    + 传输的内存地址是什么
    + 传输的扇区数是多少
  + 如果所需的磁盘驱动器和控制器空闲，则立即处理请求。如果磁盘驱动器或控制器忙，则任何新的服务请求都会添加磁盘驱动器的待处理请求队列。对于具有多个进程的一个多道程序系统，磁盘队列可能有多个待处理的请求。因此，当一个请求完成时，操作系统可以使用磁盘调度算法选择哪个待处理的请求服务。
+ 磁盘调度算法
  + FCFS先来先服务调度算法
    + 按顺序处理I/O请求
    + 对所有进程都是公平的
    + 如果有许多进程/请求，则在性能上接近随机调度
    + 在全局上会有之字形效应，通常不提供最快的服务
  + SSTF最短寻道时间优先调度算法
    + SSTF从当前磁头位置选择具有最小寻道时间的请求。
      + 也称为最短寻道距离优先（SSDF），因为计算距离更加容易。
      + 是一种最近邻法。
    + 这个算法更加偏重于处理中间的柱面请求。
    + SSTF调度是SJF调度的一种形式；可能会导致某些请求无法满足。
  + SCAN扫描算法
    + 磁臂从磁盘的一端开始，向另一端移动；在移过每个柱面时，处理请求。当到达磁盘的另一端时，磁头移动方向反转，并继续处理。磁头连续来回扫描磁盘。
  + C-SCAN循环扫描算法
    + 是SCAN的一个变种，以提供更均匀的等待时间。
    + 像SCAN一样，C-SCAN移动磁头从磁盘一端到磁盘另一端，并且处理行程上的请求。然而，当磁头到达另一端时，它立即返回到磁盘的开头，而并不处理任何回程上的请求
  + LOOK调度算法和C-LOOK算法
    + SCAN和C-SCAN在磁盘的整个宽度内移动磁臂。实际上，这两种算法通常都不是按这种方式实施的。更常见的是，磁臂只需移到一个方向的最远请求为止。遵循这种模式的SCAN算法和C-SCAN算法分别称为LOOK和 C-LOOK调度，因为它们在向特定方向移动时查看是否会有请求。

### 设计报告

#### 代码设计

```c
//HDD_scheduling.c文件
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#define CYLINDER_REQ_NUM 8  // I/O请求块的柱面数目
#define CYLINDER_NUM 200    // 总的柱面数目

// 取一个数的绝对值
int abs_int(int num);

// 硬盘柱面访问调度算法
void FCFS(int *cylinders, int *cylinder_req, int cylinder_head);
void SSTF(int *cylinders, int *cylinder_req, int cylinder_head);
void SCAN(int *cylinders, int *cylinder_req, int cylinder_head, int head_dir);
void C_SCAN(int *cylinders, int *cylinder_req, int cylinder_head, int head_dir);
void LOOK(int *cylinders, int *cylinder_req, int cylinder_head, int head_dir);
void C_LOOK(int *cylinders, int *cylinder_req, int cylinder_head, int head_dir);

// 找到距离当前磁头最近的请求处理的柱面
int find_cylinder_min_seek_dis(int *cylinders, int cylinder_head);
// 将I/O请求块的柱面在硬盘上设置相应的请求
void set_cylinders(int *cylinders, int *cylinder_req);
// 打印I/O请求块的柱面的信息
void print_cylinder_req(int *cylinder_req);
// 打印开始时磁头扫描方向
void print_head_dir(int head_dir);

// 取一个数的绝对值
int abs_int(int num) {
    if (num >= 0) {
        return num;
    } else {
        return -num;
    }
}

// 先来先服务调度算法
void FCFS(int *cylinders, int *cylinder_req, int cylinder_head) {
    printf("\n--------------------------------------------------------\n");
    printf("HDD Scheduling Algorithm: FCFS\n");
    print_cylinder_req(cylinder_req);
    printf("\n");

    // 初始化硬盘柱面，设置相应柱面请求处理
    memset(cylinders, 0, CYLINDER_NUM * sizeof(int));
    set_cylinders(cylinders, cylinder_req);

    int head_move_sum = 0;
    printf("head's movement: ");
    // 打印一开始磁头处于柱面位置
    if (cylinders[cylinder_head] == 0) {
        printf("%d ", cylinder_head);
    }

    for(int i = 0; i < CYLINDER_REQ_NUM; ++i) {
        int cylinder_id = cylinder_req[i];
        // 直接按照柱面请求顺序处理请求柱面
        printf("%d ", cylinder_id);
        // 处理后的柱面在硬盘上的请求数减一
        cylinders[cylinder_id]--;
        // 将磁头移动距离加到磁头移动总距离中
        head_move_sum += abs_int(cylinder_head - cylinder_id);
        // 磁头位置为处理完的柱面位置
        cylinder_head = cylinder_id;
    }

    printf("\nThe total movement of head = %d cylinders\n", head_move_sum);

    printf("--------------------------------------------------------\n");
}

// 最短寻道时间优先调度算法
void SSTF(int *cylinders, int *cylinder_req, int cylinder_head) {
    printf("\n--------------------------------------------------------\n");
    printf("HDD Scheduling Algorithm: SSTF\n");
    print_cylinder_req(cylinder_req);
    printf("\n");

    // 初始化硬盘柱面，设置相应柱面请求处理
    memset(cylinders, 0, CYLINDER_NUM * sizeof(int));
    set_cylinders(cylinders, cylinder_req);

    int head_move_sum = 0;
    printf("head's movement: ");
    // 打印一开始磁头处于柱面位置
    if (cylinders[cylinder_head] == 0) {
        printf("%d ", cylinder_head);
    }

    for(int i = 0; i < CYLINDER_REQ_NUM; ++i) {
        int cylinder_id = find_cylinder_min_seek_dis(cylinders, cylinder_head);
        // 直接按照柱面请求顺序处理请求柱面
        printf("%d ", cylinder_id);
        // 处理后的柱面在硬盘上的请求数减一
        cylinders[cylinder_id]--;
        // 将磁头移动距离加到磁头移动总距离中
        head_move_sum += abs_int(cylinder_head - cylinder_id);
        // 磁头位置为处理完的柱面位置
        cylinder_head = cylinder_id;
    }

    printf("\nThe total movement of head = %d cylinders\n", head_move_sum);

    printf("--------------------------------------------------------\n");
}

// 扫描调度算法
void SCAN(int *cylinders, int *cylinder_req, int cylinder_head, int head_dir) {
    printf("\n--------------------------------------------------------\n");
    printf("HDD Scheduling Algorithm: SCAN\n");
    print_cylinder_req(cylinder_req);
    print_head_dir(head_dir);
    printf("\n");

    // 初始化硬盘柱面，设置相应柱面请求处理
    memset(cylinders, 0, CYLINDER_NUM * sizeof(int));
    set_cylinders(cylinders, cylinder_req);

    int pre_cylinder_head = cylinder_head;
    int head_move_sum = 0;
    printf("head's movement: ");
    // 打印一开始磁头处于柱面位置
    if (cylinders[cylinder_head] == 0) {
        printf("%d ", cylinder_head);
    }

    // 向一个方向扫描直到尽头
    while (cylinder_head >= 0 && cylinder_head < CYLINDER_NUM) {
        // 如果磁头在请求处理的柱面上
        while (cylinders[cylinder_head] > 0) {
            printf("%d ", cylinder_head);
            // 将磁头移动距离加到磁头移动总距离中
            head_move_sum += abs_int(cylinder_head - pre_cylinder_head);
            // 更新磁头上一次处在的位置
            pre_cylinder_head = cylinder_head;
            // 处理后的柱面在硬盘上的请求数减一
            cylinders[cylinder_head]--;
        }
        // 如果head_dir为0，向朝0的方向扫描
        if (head_dir == 0) {
            cylinder_head--;
        } else {
            // 如果head_dir为1，向朝CYLINDER_NUM的方向扫描
            cylinder_head++;
        }
    }

    // 令磁头到达一侧尽头
    if (cylinder_head == -1) {
        cylinder_head++;
    }
    if (cylinder_head == CYLINDER_NUM) {
        cylinder_head--;
    }

    if (pre_cylinder_head != cylinder_head) {
        printf("%d ", cylinder_head);
        head_move_sum += abs_int(cylinder_head - pre_cylinder_head);
        pre_cylinder_head = cylinder_head;
    }

    // 调转扫描方向
    if (head_dir == 0) {
        head_dir = 1;
    } else {
        head_dir = 0;
    }

    // 向另一个方向继续扫描
    while (cylinder_head >= 0 && cylinder_head < CYLINDER_NUM) {
        while (cylinders[cylinder_head] > 0) {
            printf("%d ", cylinder_head);
            head_move_sum += abs_int(cylinder_head - pre_cylinder_head);
            pre_cylinder_head = cylinder_head;
            cylinders[cylinder_head]--;
        }
        if (head_dir == 0) {
            cylinder_head--;
        } else {
            cylinder_head++;
        }
    }

    printf("\nThe total movement of head = %d cylinders\n", head_move_sum);

    printf("--------------------------------------------------------\n");
}

// 循环扫描调度算法
void C_SCAN(int *cylinders, int *cylinder_req, int cylinder_head, int head_dir) {
    printf("\n--------------------------------------------------------\n");
    printf("HDD Scheduling Algorithm: C-SCAN\n");
    print_cylinder_req(cylinder_req);
    print_head_dir(head_dir);
    printf("\n");

    // 初始化硬盘柱面，设置相应柱面请求处理
    memset(cylinders, 0, CYLINDER_NUM * sizeof(int));
    set_cylinders(cylinders, cylinder_req);

    int pre_cylinder_head = cylinder_head;
    int head_move_sum = 0;
    printf("head's movement: ");
    // 打印一开始磁头处于柱面位置
    if (cylinders[cylinder_head] == 0) {
        printf("%d ", cylinder_head);
    }

    // 向一个方向扫描直到尽头
    while (cylinder_head >= 0 && cylinder_head < CYLINDER_NUM) {
        // 如果磁头在请求处理的柱面上
        while (cylinders[cylinder_head] > 0) {
            printf("%d ", cylinder_head);
            // 将磁头移动距离加到磁头移动总距离中
            head_move_sum += abs_int(cylinder_head - pre_cylinder_head);
            // 更新磁头上一次处在的位置
            pre_cylinder_head = cylinder_head;
            // 处理后的柱面在硬盘上的请求数减一
            cylinders[cylinder_head]--;
        }
        // 如果head_dir为0，向朝0的方向扫描
        if (head_dir == 0) {
            cylinder_head--;
        } else {
            // 如果head_dir为1，向朝CYLINDER_NUM的方向扫描
            cylinder_head++;
        }
    }

    // 令磁头到达一侧尽头
    if (cylinder_head == -1) {
        cylinder_head++;
    }
    if (cylinder_head == CYLINDER_NUM) {
        cylinder_head--;
    }

    if (pre_cylinder_head != cylinder_head) {
        printf("%d ", cylinder_head);
        head_move_sum += abs_int(cylinder_head - pre_cylinder_head);
        pre_cylinder_head = cylinder_head;
    }

    // 令磁头直接到达另一侧尽头
    if (cylinder_head == 0) {
        cylinder_head = CYLINDER_NUM - 1;
    } else if (cylinder_head == CYLINDER_NUM - 1) {
        cylinder_head = 0;
    }
    pre_cylinder_head = cylinder_head;

    if (cylinders[cylinder_head] == 0) {
        printf("%d ", cylinder_head);
    }

    // 向同一方向继续扫描
    while (cylinder_head >= 0 && cylinder_head < CYLINDER_NUM) {
        while (cylinders[cylinder_head] > 0) {
            printf("%d ", cylinder_head);
            head_move_sum += abs_int(cylinder_head - pre_cylinder_head);
            pre_cylinder_head = cylinder_head;
            cylinders[cylinder_head]--;
        }
        if (head_dir == 0) {
            cylinder_head--;
        } else {
            cylinder_head++;
        }
    }

    printf("\nThe total movement of head = %d cylinders\n", head_move_sum);

    printf("--------------------------------------------------------\n");
}

// LOOK电梯调度算法
void LOOK(int *cylinders, int *cylinder_req, int cylinder_head, int head_dir) {
    printf("\n--------------------------------------------------------\n");
    printf("HDD Scheduling Algorithm: LOOK\n");
    print_cylinder_req(cylinder_req);
    print_head_dir(head_dir);
    printf("\n");

    // 初始化硬盘柱面，设置相应柱面请求处理
    memset(cylinders, 0, CYLINDER_NUM * sizeof(int));
    set_cylinders(cylinders, cylinder_req);

    int pre_cylinder_head = cylinder_head;
    int head_move_sum = 0;
    printf("head's movement: ");
    // 打印一开始磁头处于柱面位置
    if (cylinders[cylinder_head] == 0) {
        printf("%d ", cylinder_head);
    }

    // 找到两个方向的最远请求
    int cylinder_req_min = cylinder_req[0];
    int cylinder_req_max = cylinder_req[0];

    for(int i = 0; i < CYLINDER_REQ_NUM; ++i) {
        int cylinder_id = cylinder_req[i];
        if (cylinder_req_min > cylinder_id) {
            cylinder_req_min = cylinder_id;
        }
        if (cylinder_req_max < cylinder_id) {
            cylinder_req_max = cylinder_id;
        }
    }

    // 向一个方向扫描
    while (cylinder_head >= 0 && cylinder_head < CYLINDER_NUM) {
        // 如果磁头在请求处理的柱面上
        while (cylinders[cylinder_head] > 0) {
            printf("%d ", cylinder_head);
            // 将磁头移动距离加到磁头移动总距离中
            head_move_sum += abs_int(cylinder_head - pre_cylinder_head);
            // 更新磁头上一次处在的位置
            pre_cylinder_head = cylinder_head;
            // 处理后的柱面在硬盘上的请求数减一
            cylinders[cylinder_head]--;
        }
        // 如果head_dir为0，向朝0的方向扫描
        if (head_dir == 0) {
            cylinder_head--;
        } else {
            // 如果head_dir为1，向朝CYLINDER_NUM的方向扫描
            cylinder_head++;
        }
    }

    // 令磁头到达一侧最远请求
    if (cylinder_head == -1) {
        cylinder_head = cylinder_req_min;
    }
    if (cylinder_head == CYLINDER_NUM) {
        cylinder_head = cylinder_req_max;
    }

    // 调转扫描方向
    if (head_dir == 0) {
        head_dir = 1;
    } else {
        head_dir = 0;
    }

    // 向另一个方向继续扫描
    while (cylinder_head >= cylinder_req_min && cylinder_head <= cylinder_req_max) {
        while (cylinders[cylinder_head] > 0) {
            printf("%d ", cylinder_head);
            head_move_sum += abs_int(cylinder_head - pre_cylinder_head);
            pre_cylinder_head = cylinder_head;
            cylinders[cylinder_head]--;
        }
        if (head_dir == 0) {
            cylinder_head--;
        } else {
            cylinder_head++;
        }
    }

    printf("\nThe total movement of head = %d cylinders\n", head_move_sum);

    printf("--------------------------------------------------------\n");
}

// C-LOOK循环电梯调度算法
void C_LOOK(int *cylinders, int *cylinder_req, int cylinder_head, int head_dir) {
    printf("\n--------------------------------------------------------\n");
    printf("HDD Scheduling Algorithm: C-LOOK\n");
    print_cylinder_req(cylinder_req);
    print_head_dir(head_dir);
    printf("\n");

    // 初始化硬盘柱面，设置相应柱面请求处理
    memset(cylinders, 0, CYLINDER_NUM * sizeof(int));
    set_cylinders(cylinders, cylinder_req);

    int pre_cylinder_head = cylinder_head;
    int head_move_sum = 0;
    printf("head's movement: ");
    // 打印一开始磁头处于柱面位置
    if (cylinders[cylinder_head] == 0) {
        printf("%d ", cylinder_head);
    }

    // 找到两个方向的最远请求
    int cylinder_req_min = cylinder_req[0];
    int cylinder_req_max = cylinder_req[0];

    for(int i = 0; i < CYLINDER_REQ_NUM; ++i) {
        int cylinder_id = cylinder_req[i];
        if (cylinder_req_min > cylinder_id) {
            cylinder_req_min = cylinder_id;
        }
        if (cylinder_req_max < cylinder_id) {
            cylinder_req_max = cylinder_id;
        }
    }

    // 向一个方向扫描
    while (cylinder_head >= 0 && cylinder_head < CYLINDER_NUM) {
        // 如果磁头在请求处理的柱面上
        while (cylinders[cylinder_head] > 0) {
            printf("%d ", cylinder_head);
            // 将磁头移动距离加到磁头移动总距离中
            head_move_sum += abs_int(cylinder_head - pre_cylinder_head);
            // 更新磁头上一次处在的位置
            pre_cylinder_head = cylinder_head;
            // 处理后的柱面在硬盘上的请求数减一
            cylinders[cylinder_head]--;
        }
        // 如果head_dir为0，向朝0的方向扫描
        if (head_dir == 0) {
            cylinder_head--;
        } else {
            // 如果head_dir为1，向朝CYLINDER_NUM的方向扫描
            cylinder_head++;
        }
    }

    // 令磁头到达另一侧最远请求
    if (cylinder_head == -1) {
        cylinder_head = cylinder_req_max;
    }
    if (cylinder_head == CYLINDER_NUM) {
        cylinder_head = cylinder_req_min;
    }
    pre_cylinder_head = cylinder_head;

    // 向同一方向继续扫描
    while (cylinder_head >= cylinder_req_min && cylinder_head <= cylinder_req_max) {
        while (cylinders[cylinder_head] > 0) {
            printf("%d ", cylinder_head);
            head_move_sum += abs_int(cylinder_head - pre_cylinder_head);
            pre_cylinder_head = cylinder_head;
            cylinders[cylinder_head]--;
        }
        if (head_dir == 0) {
            cylinder_head--;
        } else {
            cylinder_head++;
        }
    }

    printf("\nThe total movement of head = %d cylinders\n", head_move_sum);

    printf("--------------------------------------------------------\n");
}

// 找到距离当前磁头最近的请求处理的柱面
int find_cylinder_min_seek_dis(int *cylinders, int cylinder_head) {
    // 朝0方向查找的变量
    int find_head_dir0 = cylinder_head;
    // 朝CYLINDER_NUM方向查找的变量
    int find_head_dir1 = cylinder_head;
    while (find_head_dir0 >= 0 || find_head_dir1 < CYLINDER_NUM) {
        // 每次两个变量移动相同距离查找，当找到有请求的柱面，就是距离磁头最近的柱面，直接返回
        if (find_head_dir0 >= 0) {
            if (cylinders[find_head_dir0] > 0) {
                return find_head_dir0;
            }
            find_head_dir0--;
        }
        if (find_head_dir1 < CYLINDER_NUM) {
            if (cylinders[find_head_dir1] > 0) {
                return find_head_dir1;
            }
            find_head_dir1++;
        }
    }
    // 没有请求处理的柱面则返回-1
    return -1;
}

// 将I/O请求块的柱面在硬盘上设置相应的请求
void set_cylinders(int *cylinders, int *cylinder_req) {
    for(int i = 0; i < CYLINDER_REQ_NUM; ++i) {
        int cylinder_id = cylinder_req[i];
        // 可能同一柱面不止一个请求，所以请求加一
        cylinders[cylinder_id]++;
    }
}

// 打印I/O请求块的柱面的信息
void print_cylinder_req(int *cylinder_req) {
    printf("cylinder request: ");
    for(int i = 0; i < CYLINDER_REQ_NUM; ++i) {
        printf("%d ", cylinder_req[i]);
    }
    printf("\n");
}

// 打印开始时磁头扫描方向
void print_head_dir(int head_dir) {
    printf("The direction of head movement in the beginning: toward cylinder ");
    if (head_dir == 0) {
        printf("0\n");
    } else {
        printf("%d\n", CYLINDER_NUM - 1);
    }
}

int main () {
    int cylinders[CYLINDER_NUM];
    int cylinder_req[CYLINDER_REQ_NUM];
    int cylinder_head;
    int head_dir;

    // 生成随机数的方式产生测试样例
    /*srand((unsigned) time(NULL));
    int num;
    for (int i = 0; i < CYLINDER_REQ_NUM; ++i) {
        num = rand() % CYLINDER_NUM;
        cylinder_req[i] = num;
    }
    num = rand() % CYLINDER_NUM;
    cylinder_head = num;
    num = rand() % 2;
    head_dir = num;*/

    // 手动输入的方式产生测试样例
    printf("Please input the queue with requests for cylinders:\n");
    for(int i = 0; i < CYLINDER_REQ_NUM; ++i) {
        scanf("%d", &cylinder_req[i]);
    }
    printf("Please input the head's position of cylinder: ");
    scanf("%d", &cylinder_head);
    printf("Please input the direction of head movement(0: toward cylinder 0, 1: toward cylinder %d): ", CYLINDER_NUM - 1);
    scanf("%d", &head_dir);

    FCFS(cylinders, cylinder_req, cylinder_head);
    SSTF(cylinders, cylinder_req, cylinder_head);
    SCAN(cylinders, cylinder_req, cylinder_head, head_dir);
    C_SCAN(cylinders, cylinder_req, cylinder_head, head_dir);
    LOOK(cylinders, cylinder_req, cylinder_head, head_dir);
    C_LOOK(cylinders, cylinder_req, cylinder_head, head_dir);
}
```

执行命令：

    gcc HDD_scheduling.c
    ./a.out

#### 验证各个磁盘调度算法的正确性

在宏定义处设置I/O请求块的柱面数目、总的柱面数目：

    #define CYLINDER_REQ_NUM 8  // I/O请求块的柱面数目
    #define CYLINDER_NUM 200    // 总的柱面数目

**测试用例1：**

首先按照教材上的用例测试：

    #define CYLINDER_REQ_NUM 8  // I/O请求块的柱面数目
    #define CYLINDER_NUM 200    // 总的柱面数目

    98 183 37 122 14 124 65 67
    53
    0

    98 183 37 122 14 124 65 67
    53
    1

**先来先服务调度算法：**

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/2.png)

可以看到，
一开始，磁头所在的柱面为53；
然后按照I/O请求块的柱面顺序依次处理柱面请求，得到的磁头移动路径和磁头移动总距离与教材相同。

过程符合先来先服务调度算法。

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/3.png)

**最短寻道时间优先调度算法：**

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/4.png)

可以看到，
一开始，磁头所在的柱面为53；
然后按照距离当前磁头所在柱面最短距离的柱面依次处理柱面请求，得到的磁头移动路径和磁头移动总距离与教材相同。

过程符合最短寻道时间优先调度算法。

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/5.png)

**扫描调度算法：**

**首先磁头向朝0方向扫描：**

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/6.png)

可以看到，
一开始，磁头所在的柱面为53；
然后按照扫描方向的经过柱面依次处理柱面请求，到达0后，再向朝柱面199方向依次扫描，得到的磁头移动路径和磁头移动总距离与教材相同。

过程符合扫描调度算法。

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/7.png)

**如果首先磁头向朝柱面199方向扫描：**

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/8.png)

可以看到，
一开始，磁头所在的柱面为53；
然后按照扫描方向的经过柱面依次处理柱面请求，到达柱面199后，再向朝0方向依次扫描。

过程符合扫描调度算法。

**循环扫描调度算法：**

**首先磁头向朝0方向扫描：**

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/9.png)

可以看到，
一开始，磁头所在的柱面为53；
然后按照扫描方向的经过柱面依次处理柱面请求，到达0后，直接到达柱面199，再向朝0方向依次扫描。

过程符合循环扫描调度算法。

**如果首先磁头向朝柱面199方向扫描：**

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/10.png)

可以看到，
一开始，磁头所在的柱面为53；
然后按照扫描方向的经过柱面依次处理柱面请求，到达柱面199后，直接到达柱面0，再向朝柱面199方向依次扫描，得到的磁头移动路径和磁头移动总距离与教材相同。

过程符合循环扫描调度算法。

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/11.png)

**LOOK电梯调度算法：**

**首先磁头向朝0方向扫描：**

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/12.png)

可以看到，
一开始，磁头所在的柱面为53；
然后按照扫描方向的经过柱面依次处理柱面请求，到达朝0方向最远的柱面请求柱面14后，再向朝柱面199方向依次扫描，得到的磁头移动路径和磁头移动总距离与教材相同。

过程符合LOOK电梯调度算法。

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/13.png)

**如果首先磁头向朝柱面199方向扫描：**

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/14.png)

可以看到，
一开始，磁头所在的柱面为53；
然后按照扫描方向的经过柱面依次处理柱面请求，到达朝柱面199方向最远的柱面请求柱面183后，再向朝0方向依次扫描。

过程符合LOOK电梯调度算法。

**C-LOOK循环电梯调度算法：**

**首先磁头向朝0方向扫描：**

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/15.png)

可以看到，
一开始，磁头所在的柱面为53；
然后按照扫描方向的经过柱面依次处理柱面请求，到达朝0方向最远的请求柱面14后，直接到达朝柱面199方向最远的请求柱面183，再向朝0方向依次扫描。

过程符合C-LOOK循环电梯调度算法。

**如果首先磁头向朝柱面199方向扫描：**

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/16.png)

可以看到，
一开始，磁头所在的柱面为53；
然后按照扫描方向的经过柱面依次处理柱面请求，到达朝柱面199方向最远的请求柱面183后，直接到达朝0方向最远的请求柱面14，再向柱面199方向依次扫描，得到的磁头移动路径和磁头移动总距离与教材相同。

过程符合C-LOOK循环电梯调度算法。

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/17.png)

**测试用例2：**

    #define CYLINDER_REQ_NUM 8  // I/O请求块的柱面数目
    #define CYLINDER_NUM 200    // 总的柱面数目

    176 17 23 42 5 21 186 92
    156
    0

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/18.png)

可以看到，磁头的移动路径和移动总距离都正确。

**测试用例3：**

    #define CYLINDER_REQ_NUM 8  // I/O请求块的柱面数目
    #define CYLINDER_NUM 200    // 总的柱面数目

    81 87 138 193 99 99 79 67
    14
    1

这个样例中，磁头一开始的位置比朝0方向的最远请求柱面距离0更近，中间有两个柱面请求为同一个柱面。

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/19.png)

可以看到，磁头的移动路径和移动总距离都正确。

LOOK算法和C-LOOK算法的移动路径和移动总距离都相同，因为磁头第一次朝一个方向扫时就已经处理完所有的柱面请求，符合算法。

**测试用例4：**

    #define CYLINDER_REQ_NUM 8  // I/O请求块的柱面数目
    #define CYLINDER_NUM 200    // 总的柱面数目

    53 53 43 53 43 53 53 53
    53
    1

这个样例中，磁头一开始的位置和第一个请求的柱面位置一样，中间有多个重复请求的柱面位置。

执行截图：

![](http://stugeek.gitee.io/operating-system/Labwork18-pictures/20.png)

可以看到，磁头的移动路径和移动总距离都正确。

C-LOOK算法中，磁头首先到达最远请求柱面53，然后直接到达另一侧的最远请求柱面43，所有磁头移动总距离为0，符合算法。
