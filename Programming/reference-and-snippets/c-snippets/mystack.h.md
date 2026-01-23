# MyStack.h

{% code title="MyStack.h" %}
```c
//  MyStack.h
//  C_HeaderTest
//
//  Created by admin on 3/16/24.
//

#ifndef MyStack_h
#define MyStack_h
#include <stdio.h>
#include <stdlib.h>

typedef struct StackNode
{
    char cData;
    struct StackNode *pNext;
} node;
  
typedef struct LinkedStack
{
    node *pTop;
    int nCurrentCount;
} stack;
  
int initStack(stack *_pStack_);
  
stack *createStack(void);
  
int initNode(node *_pNode_, const char _cData_);
  
int push(stack *_pStack_, const char _cData_);
  
node *pop(stack *_pStack_);
  
node *peek(const stack *_pStack_);
  
int displayStack(const stack *_pStack_);
  
int deleteStack(stack *_pStack_);
#endif /* MyStack_h */
```
{% endcode %}
