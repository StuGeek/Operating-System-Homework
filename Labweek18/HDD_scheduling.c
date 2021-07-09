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

    head_move_sum += CYLINDER_NUM - 1;
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

    // 如果磁头一开始在两个最远请求外侧，那么首先扫到最近一侧的尽头
    if (cylinder_head < cylinder_req_min) {
        cylinder_head = cylinder_req_min;
        head_move_sum += cylinder_req_min - cylinder_head;
    } else if (cylinder_head > cylinder_req_max) {
        cylinder_head = cylinder_req_max;
        head_move_sum += cylinder_req_max - cylinder_req_min;
    }

    // 向一个方向扫描
    while (cylinder_head >= cylinder_req_min && cylinder_head <= cylinder_req_max) {
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
    if (cylinder_head == cylinder_req_min - 1) {
        cylinder_head = cylinder_req_min;
    }
    if (cylinder_head == cylinder_req_max + 1) {
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

    // 如果磁头一开始在两个最远请求外侧，那么首先扫到最近一侧的尽头
    if (cylinder_head < cylinder_req_min) {
        cylinder_head = cylinder_req_min;
        head_move_sum += cylinder_req_min - cylinder_head;
    } else if (cylinder_head > cylinder_req_max) {
        cylinder_head = cylinder_req_max;
        head_move_sum += cylinder_req_max - cylinder_req_min;
    }

    // 向一个方向扫描
    while (cylinder_head >= cylinder_req_min && cylinder_head <= cylinder_req_max) {
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
    head_move_sum += cylinder_req_max - cylinder_req_min;
    if (cylinder_head == cylinder_req_min - 1) {
        cylinder_head = cylinder_req_max;
    }
    if (cylinder_head == cylinder_req_max + 1) {
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
