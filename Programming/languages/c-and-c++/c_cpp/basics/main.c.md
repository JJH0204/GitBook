# Main.c

{% code title="main.c" %}
```c
//  main.c
//  C_test
//  Created by admin on 3/16/24.
#include "MyStack.h"

int main(int argc, const char * argv[]) {

    stack *pStack = NULL;

    node *pNode = NULL;

    pStack = createStack();

    if (pStack == NULL)
    {
        printf("Memory initialization failed: main()\n");
        return -1;
    }
    push(pStack, 'L');
    push(pStack, 'O');
    push(pStack, 'V');
    push(pStack, 'E');
    push(pStack, 'Y');
    push(pStack, 'O');
    push(pStack, 'U');
    displayStack(pStack);

    pNode = pop(pStack);
    if (pNode == NULL)
    {
        printf("Memory initialization failed: main()\n");
        return -2;
    }
    printf("Pop - [%c]\n", pNode->cData);
    free(pNode);

    displayStack(pStack);
    pNode = peek(pStack);
    if (pNode == NULL)
    {
        printf("Memory initialization failed: main()\n");
        return -3;
    }
    printf("Peek - [%c]\n", pNode->cData);
    free(pNode);

    displayStack(pStack);
    deleteStack(pStack);
    return 0;
}
```
{% endcode %}
