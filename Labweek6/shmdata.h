#define TEXT_SIZE 4*1024  /* = PAGE_SIZE, size of each message */
#define TEXT_NUM 20      /* maximal number of mesages */
    /* total size can not exceed current shmmax,
       or an 'invalid argument' error occurs when shmget */

// 学生信息多字符串读写
typedef struct {
    char text[TEXT_SIZE];
} Queue;

struct shared_struct {
    Queue mtext[TEXT_NUM + 1]; // buffer for message reading and writing
    int front; //队首元素的下标
    int rear; //队尾元素的下标
};

// 将学生的学号、姓名、学院组织成一个结构类型进行读写
/*typedef struct {
    int id;
    char name[20];
    char department[20];
} Queue;

struct shared_struct {
    Queue students[TEXT_NUM + 1]; // buffer for message reading and writing
    int front; // 队首元素的下标
    int rear; // 队尾元素的下标
};*/

#define PERM S_IRUSR|S_IWUSR|IPC_CREAT

#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)


