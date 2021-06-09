/* compiling with –lpthread option */
#include <pthread.h>
#include <stdio.h>

#define NUM_THREADS 5

void *runner(void *);

int main(int argc, char *argv[]) {
    int i, policy;
    pthread_t tid[NUM_THREADS];
    struct sched_param param;
    pthread_attr_t attr;
    /* get the default attributes */
    pthread_attr_init(&attr);
    /* get the current scheduling policy */
    if (pthread_attr_getschedpolicy(&attr, &policy) != 0)
        printf("Unable to get policy.\n");
    else {
        printf("The current scheduling policy is ");
        if (policy == SCHED_OTHER)
            printf("SCHED_OTHER\n");
        else if (policy == SCHED_RR)
            printf("SCHED_RR\n");
        else if (policy == SCHED_FIFO)
            printf("SCHED_FIFO\n");
    }
    /* get the current priority */
    if (pthread_attr_getschedparam(&attr, &param) != 0)
        printf("Unable to get priority from SCHED_OTHER.\n");
    else
        printf("current sched_priority = %d\n", param.sched_priority);
    printf("priority_min of OTHER is %d, max is %d\n",
           sched_get_priority_min(SCHED_OTHER), sched_get_priority_max(SCHED_OTHER));
    param.sched_priority = 10; /* set the priority to 10 */
    if (pthread_attr_setschedparam(&attr, &param) != 0)
        printf("Unable to set prority to 10.\n");
    /* get the current priority */
    if (pthread_attr_getschedparam(&attr, &param) != 0)
        printf("Unable to get prioty from SCHED_RR.\n");
    else
        printf("The new sched_priority = %d\n", param.sched_priority);
    /* set the scheduling policy to RR */
    if (pthread_attr_setschedpolicy(&attr, SCHED_RR) != 0)
        printf("Unable to set policy to SCHED_RR.\n");
    /* get the current scheduling policy */
    if (pthread_attr_getschedpolicy(&attr, &policy) != 0)
        printf("Unable to get policy.\n");
    else {
        printf("The new scheduling policy is ");
        if (policy == SCHED_OTHER)
            printf("SCHED_OTHER\n");
        else if (policy == SCHED_RR)
            printf("SCHED_RR\n");
        else if (policy == SCHED_FIFO)
            printf("SCHED_FIFO\n");
    }
    /* get the current priority */
    if (pthread_attr_getschedparam(&attr, &param) != 0)
        printf("Unable to get prioty from SCHED_RR.\n");
    else
        printf("current sched_priority = %d\n", param.sched_priority);
    printf("priority_min of RR is %d, max is %d\n",
           sched_get_priority_min(SCHED_RR), sched_get_priority_max(SCHED_RR));
    /* set the priority to 10 */
    param.sched_priority = 10;
    if (pthread_attr_setschedparam(&attr, &param) != 0)
        printf("Unable to set prority.\n");
    /* get the current priority */
    if (pthread_attr_getschedparam(&attr, &param) != 0)
        printf("Unable to get prioty from SCHED_RR.\n");
    else
        printf("The new sched_priority = %d\n", param.sched_priority);
    /* set the scheduling policy to FIFO */
    if (pthread_attr_setschedpolicy(&attr, SCHED_FIFO) != 0)
        printf("Unable to set policy to SCHED_FIFO.\n");
    /* get the current scheduling policy */
    if (pthread_attr_getschedpolicy(&attr, &policy) != 0)
        printf("Unable to get policy.\n");
    else {
        printf("The new scheduling policy is ");
        if (policy == SCHED_OTHER)
            printf("SCHED_OTHER\n");
        else if (policy == SCHED_RR)
            printf("SCHED_RR\n");
        else if (policy == SCHED_FIFO)
            printf("SCHED_FIFO\n");
    }
    /* get the current priority */
    if (pthread_attr_getschedparam(&attr, &param) != 0)
        printf("Unable to get prioty from SCHED_FIFO.\n");
    else
        printf("current sched_priority = %d\n", param.sched_priority);
    printf("priority_min of FIFO is %d, max is %d\n",
           sched_get_priority_min(SCHED_FIFO), sched_get_priority_max(SCHED_FIFO));
    /* set the priority to 50 */
    param.sched_priority = 50;
    if (pthread_attr_setschedparam(&attr, &param) != 0)
        printf("Unable to set prority.\n");
    /* get the current priority */
    if (pthread_attr_getschedparam(&attr, &param) != 0)
        printf("Unable to get prioty from SCHED_FIFO\n");
    else
        printf("The new sched_priority = %d\n", param.sched_priority);
    /* create the threads */
    for (i = 0; i < NUM_THREADS; i++)
        pthread_create(&tid[i], &attr, &runner, NULL);
    /* now join on each thread */
    for (i = 0; i < NUM_THREADS; i++)
        pthread_join(tid[i], NULL);
}

/* Each thread will begin control in this function */
void *runner(void *param) {
    /* do some work ... */
    pthread_exit(0);
}