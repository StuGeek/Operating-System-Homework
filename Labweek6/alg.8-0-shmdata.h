#define TEXT_SIZE 4*1024  /* = PAGE_SIZE, size of each message */
#define TEXT_NUM 20      /* maximal number of mesages */
    /* total size can not exceed current shmmax,
       or an 'invalid argument' error occurs when shmget */

typedef struct {
    char text[TEXT_SIZE];
} Queue;

/* a demo structure, modified as needed */
struct shared_struct {
    Queue mtext[TEXT_NUM + 1]; /* buffer for message reading and writing */
    int front; /*队首元素的下标*/
    int rear; /*队尾元素的下标*/
};

#define PERM S_IRUSR|S_IWUSR|IPC_CREAT

#define ERR_EXIT(m) \
    do { \
        perror(m); \
        exit(EXIT_FAILURE); \
    } while(0)


