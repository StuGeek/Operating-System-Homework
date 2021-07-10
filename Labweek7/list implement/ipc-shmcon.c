#include "ipc-shmcon.h"

int main() {
    StaticLinkList lists;
    initialStaticLinkList(&lists);

    Student stu1 = {id: 30, name: "name1"};
    Student stu2 = {id: 20, name: "name2"};
    Student stu3 = {id: 40, name: "name3"};
    Student stu4 = {id: 50, name: "name4"};
    Student stu5 = {id: 10, name: "name5"};
    Student stu6 = {id: 5, name: "name6"};
    Student stu7 = {id: 25, name: "name7"};
    
    /*insertListAtHead(&lists, stu1);
    insertListAtHead(&lists, stu2);
    insertListAtHead(&lists, stu3);
    insertListAtHead(&lists, stu4);
    insertListAtHead(&lists, stu5);*/

    pushHeap(&lists, &stu1);
    pushHeap(&lists, &stu2);
    pushHeap(&lists, &stu3);
    pushHeap(&lists, &stu4);
    pushHeap(&lists, &stu5);

    printf("---------------------------------------------------\n");
    printf("Before initiation:\n");
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);
    printf("---------------------------------------------------\n\n");

    printf("---------------------------------------------------\n");
    printf("Turn the list into a heap after initiation:\n\n");
    initialHeap(&lists);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);
    printf("---------------------------------------------------\n\n");

    printf("---------------------------------------------------\n");
    printf("Push stu6 into the heap(id: 5, name: name6)\n\n");
    pushHeap(&lists, &stu6);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);
    printf("---------------------------------------------------\n\n");

    printf("---------------------------------------------------\n");
    printf("Push stu7 into the heap(id: 25, name: name7)\n\n");
    pushHeap(&lists, &stu7);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);
    printf("---------------------------------------------------\n\n");
    
    printf("---------------------------------------------------\n");
    printf("Pop heap the first time\n\n");
    popHeap(&lists);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);
    printf("---------------------------------------------------\n\n");

    printf("---------------------------------------------------\n");
    printf("Pop heap the second time\n\n");
    popHeap(&lists);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);
    printf("---------------------------------------------------\n\n");

    printf("---------------------------------------------------\n");
    printf("Change stu4's id to 5\n\n");
    modifyId(&lists, &stu4, 5);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);
    printf("---------------------------------------------------\n\n");

    printf("---------------------------------------------------\n");
    printf("Change the first student's id in the heap to 90\n\n");
    modifyIdByIndex(&lists, 0, 90);
    printHeap(&lists);
    printf("\n");
    printStaticLinkList(&lists);
    printf("---------------------------------------------------\n\n");

    printf("---------------------------------------------------\n");
    printf("Find the stu3's index\n\n");
    int index = findHeap(&lists, &stu3, 0);
    printf("The stu3 is in the index %d\n", index);
    printf("---------------------------------------------------\n\n");
}