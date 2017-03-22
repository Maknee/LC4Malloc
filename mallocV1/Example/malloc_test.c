/*
 * MallocTest.c: Made by Henry Zhu
 */

#include "malloc.h"
#include "lc4libc.h"

/************************************************
 *  Printnum - 
 *  Prints out the value on the lc4
 ***********************************************/

void printnum (int n) {
  int abs_n;
  char str[10], *ptr;

  // Corner case (n == 0)
  if (n == 0) {
    lc4_puts ((lc4uint*)"0");
    return;
  }
 
  abs_n = (n < 0) ? -n : n;

  // Corner case (n == -32768) no corresponding +ve value
  if (abs_n < 0) {
    lc4_puts ((lc4uint*)"-32768");
    return;
  }

  ptr = str + 10; // beyond last character in string

  *(--ptr) = 0; // null termination

  while (abs_n) {
    *(--ptr) = (abs_n % 10) + 48; // generate ascii code for digit
    abs_n /= 10;
  }

  // Handle -ve numbers by adding - sign
  if (n < 0) *(--ptr) = '-';

  lc4_puts((lc4uint*)ptr);
}

/************************************************
 *  endl - 
 *  Ends a line by printing a newline character
 ***********************************************/
void endl () {
    lc4_puts((lc4uint*)"\n");
}

typedef struct linked_list
{
    struct linked_list* prev;
    struct linked_list* next;
    int val;
}Linked_List;

int main()
{
    Linked_List* list1;
    Linked_List* list2;
    Linked_List* list3;

    //ALWAYS MAKE THIS CALL
    intialize_heap();

    list1 = malloc(sizeof(Linked_List));
    list2 = malloc(sizeof(Linked_List));
    list3 = malloc(sizeof(Linked_List));

    list1->prev = NULL;
    list1->next = list2;
    list1->val = 1;

    list2->prev = list1;
    list2->next = list3;
    list2->val = 2;

    list3->prev = list2;
    list3->next = NULL;
    list3->val = 3;

    printnum(list2->prev->val);
    endl();
    printnum(list2->val);
    endl();
    printnum(list2->next->val);
    endl();
    return 0;
}
