# 연결 리스트 상세 (Linked List)

## 연결 리스트 소개

링크드 리스트는 그 구현을 위해 포인터를 사용하는 동적 데이터 구조의 가장 우수하고 간단한 예이다. 그러나 포인터를 이해하는 것은 링크된 목록의 작동 방식을 이해하는 데 매우 중요하므로 포인터 튜토리얼을 건너뛰었다면 돌아가서 다시 실행해야 한다. 동적 메모리 할당 및 구조에 대해서도 잘 알고 있어야 합니다.

기본적으로, 링크된 리스트들은 배열의 임의의 지점으로부터 필요에 따라 성장하고 축소할 수 있는 배열로서 기능한다.

연결 리스트는 배열에 비해 몇 가지 장점이 있습니다:

* Items can be added or removed from the middle of the list
* there is no need to define an initial size

그러나 링크 리스트에는 몇 가지 단점이 있다:

* There is no "random" access - it is impossible to reach the nth item in the array without first iterating over all items up until that item. This means we have to start from the beginning of the list and count how many times we advance in the list until we get to the desired item.
* Dynamic memory allocation and pointers are required, which complicates the code and increases the risk of memory leaks and segment faults.
* Linked lists have a much larger overhead over arrays, since linked list items are dynamically allocated (which is less efficient in memory usage) and each item in the list also must store an additional pointer.

## 연결 리스트란 무엇입니까?

연결 리스트는 동적으로 할당된 노드들의 세트로서, 각각의 노드가 하나의 값과 하나의 포인터를 포함하는 방식으로 배열된다. 포인터는 항상 목록의 다음 구성원을 가리킵니다. 포인터가 NULL이면 목록의 마지막 노드입니다.

연결 리스트는 목록의 첫 번째 항목을 가리키는 로컬 포인터 변수를 사용하여 유지된다.(헤더 포인터라고 한다.) 해당 포인터도 NULL이면 목록이 비어 있는 것으로 간주됩니다.

```
------------------------------              ------------------------------
|              |             |            \ |              |             |
|     DATA     |     NEXT    |--------------|     DATA     |     NEXT    |
|              |             |            / |              |             |
------------------------------              ------------------------------
```

연결 리스트의 노드를 정의해 보겠습니다:

```
typedef struct node {
    int val;
    struct node * next;
} node_t;
```

Notice that we are defining the struct in a recursive manner, which is possible in C. Let's name our node type node\_t.

이제 노드를 사용할 수 있습니다. 리스트의 첫 번째 항목(헤드라고 함)을 가리키는 로컬 변수를 만들어 보자.

```
node_t * head = NULL;
head = (node_t *) malloc(sizeof(node_t));
if (head == NULL) {
    return 1;
}

head->val = 1;
head->next = NULL;
```

방금 리스트의 첫 번째 변수를 만들었습니다. 목록 채우기를 완료하려면 값을 설정하고 다음 항목을 비워 두어야 합니다. malloc함수가 NULL 값을 반환했는지 여부를 항상 확인해야 합니다.

목록 끝에 변수를 추가하려면 다음 포인터로 계속 이동하면 됩니다:

```
node_t * head = NULL;
head = (node_t *) malloc(sizeof(node_t));
head->val = 1;
head->next = (node_t *) malloc(sizeof(node_t));
head->next->val = 2;
head->next->next = NULL;
```

계속할 수 있지만, 다음 항목이 Null을 가리키는 마지막 항목으로 이동해야 한다.

## 목록 순환

리스트의 모든 항목을 출력하는 기능을 구축해 봅시다. 이를 위해서는 현재 인쇄 중인 노드를 추적할 전류(current) 포인터를 사용해야 합니다. 노드의 값을 인쇄한 후 다음 노드로 현재 포인터를 설정하고 목록의 끝에 도달할 때까지 다시 인쇄합니다.

```
void print_list(node_t * head) {
    node_t * current = head;

    while (current != NULL) {
        printf("%d\n", current->val);
        current = current->next;
    }
}
```

## 리스트 끝에 항목 추가

연결 리스트의 모든 구성원들을 반복하기 위해, 우리는 전류(current)라고 불리는 포인터 변수를 사용한다. 헤드에서 시작하도록 설정한 다음 각 단계에서 마지막 리스트에 도달할 때까지 리스트의 다음 항목으로 포인터를 이동한다.

```
void push(node_t * head, int val) {
    node_t * current = head;
    while (current->next != NULL) {
        current = current->next;
    }

    /* now we can add a new variable */
    current->next = (node_t *) malloc(sizeof(node_t));
    current->next->val = val;
    current->next->next = NULL;
}
```

연결 리스트의 가장 적합한 사용 사례는 스택과 큐이며, 앞으로 구현할 것입니다.

## 리스트 맨 앞에 항목 추가 (pushing to the list)

목록의 처음에 추가하려면 다음을 수행해야 합니다:

{% stepper %}
{% step %}
### 새 노드 생성

새 노드를 생성하고 값을 저장합니다.
{% endstep %}

{% step %}
### 새 노드를 기존 헤드를 가리키도록 연결

새 노드의 next 포인터를 기존 헤드 포인터가 가리키던 곳으로 설정합니다.
{% endstep %}

{% step %}
### 헤드를 새 노드로 설정

리스트의 헤드 변수를 새 노드로 변경합니다.
{% endstep %}
{% endstepper %}

함수를 사용하여 헤더 변수를 수정할 수 있어야 하기 때문에 인수로 포인터 변수(이중 포인터)에 포인터를 전달해야 포인터 자체를 수정할 수 있다.

```
void push(node_t ** head, int val) {
    node_t * new_node;
    new_node = (node_t *) malloc(sizeof(node_t));

    new_node->val = val;
    new_node->next = *head;
    *head = new_node;
}
```

## 첫 번째 항목 제거 (popping from the list)

변수를 제거하려면 다음 작업(Push)을 반대로 수행해야 합니다:

{% stepper %}
{% step %}
### 다음 노드 저장

머리가 가리키는 다음 항목을 가져가서 저장합니다.
{% endstep %}

{% step %}
### 현재 헤드 해제

헤드 항목을 free()로 해제합니다.
{% endstep %}

{% step %}
### 헤드를 다음 노드로 설정 및 반환값 제공

헤드를 옆에 보관한 다음 항목으로 설정하고 제거한 값(또는 오류 코드)을 반환합니다.
{% endstep %}
{% endstepper %}

코드는 다음과 같습니다:

```
int pop(node_t ** head) {
    int retval = -1;
    node_t * next_node = NULL;

    if (*head == NULL) {
        return -1;
    }

    next_node = (*head)->next;
    retval = (*head)->val;
    free(*head);
    *head = next_node;

    return retval;
}
```

## 목록의 마지막 항목 제거

목록에서 마지막 항목을 제거하는 것은 목록 끝에 항목을 추가하는 것과 매우 유사하지만 한 가지 큰 예외가 있습니다 - 마지막 항목 이전에 한 항목을 변경해야 하기 때문에 실제로 두 항목을 미리 살펴보고 다음 항목이 목록의 마지막 항목인지 확인해야 합니다:

```
int remove_last(node_t * head) {
    int retval = 0;
    /* if there is only one item in the list, remove it */
    if (head->next == NULL) {
        retval = head->val;
        free(head);
        return retval;
    }

    /* get to the second to last node in the list */
    node_t * current = head;
    while (current->next->next != NULL) {
        current = current->next;
    }

    /* now current points to the second to last item of the list, so let's remove current->next */
    retval = current->next->val;
    free(current->next);
    current->next = NULL;
    return retval;

}
```

## 특정 항목 제거

목록에서 특정 항목을 제거하려면 목록의 처음부터 해당 항목의 인덱스 또는 해당 값으로 제거하려면 모든 항목을 검토하고 제거하려는 항목 이전에 노드에 도달했는지 여부를 계속해서 확인해야 합니다. 이전 노드가 가리키는 위치로 위치도 변경해야 하기 때문입니다.

알고리즘은 다음과 같습니다:

{% stepper %}
{% step %}
삭제할 노드 이전의 노드를 반복합니다.
{% endstep %}

{% step %}
삭제할 노드를 임시 포인터에 저장합니다.
{% endstep %}

{% step %}
삭제할 노드 뒤에 있는 노드를 가리키도록 이전 노드의 next 포인터를 설정합니다.
{% endstep %}

{% step %}
임시 포인터를 사용하여 노드를 free()로 삭제합니다.
{% endstep %}
{% endstepper %}

저희가 처리해야 할 엣지 케이스가 몇 개 있으니 코드를 이해했는지 확인하세요.

```
int remove_by_index(node_t ** head, int n) {
    int i = 0;
    int retval = -1;
    node_t * current = *head;
    node_t * temp_node = NULL;

    if (n == 0) {
        return pop(head);
    }

    for (i = 0; i < n-1; i++) {
        if (current->next == NULL) {
            return -1;
        }
        current = current->next;
    }

    if (current->next == NULL) {
        return -1;
    }

    temp_node = current->next;
    retval = temp_node->val;
    current->next = temp_node->next;
    free(temp_node);

    return retval;

}
```

## 연결 리스트 ADT의 C 구현

* 포인터를 이용하여 리스트를 구현
* 데이터를 저장하는 부분과 연결을 위한 포인터로 구성된 노드

### 노드 구조

* 실제 저장하려는 **데이터**와 다음 데이터의 링크(포인트)를 멤버 변수로 가지는 구조체

{% code title="node 구조체" %}
```c
typedef struct LinkedListNodeType
{
    int nData;

    struct LinkedListNodeType* pNext; 
} node;
```
{% endcode %}

```
------------------------------              ------------------------------
|              |             |            \ |              |             |
|    nData     |    pNext    |--------------|    nData     |    pNext    |
|              |             |            / |              |             |
------------------------------              ------------------------------
```

{% hint style="info" %}
헤더 노드(header node)의 존재

헤더 노드란?

* 연결 리스트에 구성된 멤버 변수
* 자료를 저장하는 노드가 아닌 첫번째 노드를 가리키는 포인터 변수
* 헤더 노드 == NULL = "연결 리스트가 비어있다."
{% endhint %}

**할당 과정에서 최대 개수 값이 필요 없다.**

> 데이터를 추가, 제거하는 과정에서 노드를 별도로 생성, 제거한 후 연결만 하면된다.\
> 배열 리스트와 달리 인덱스를 초과한 데이터 저장이 가능하다.

{% code title="linkedList 구조체" %}
```c
typedef struct LinkedList
{
    int nCurrentCount;
    node nodeHeader;
} linkedList;
```
{% endcode %}

***

### 연결 리스트 구현

{% code title="createList()" %}
```c
linkedList* createList()
{
    linkedList* pResult = (linkedList*)malloc(sizeof(linkedList));
    if (pResult == NULL)
        return NULL;
    memset(pResult, 0, sizeof(linkedList));
    return pResult;
}  
```
{% endcode %}

{% code title="getListData()" %}
```c
int getListData(linkedList* _pList_, const int _nIndex_)
{
    int i = 0;
    node* pCurrent = NULL;
    if (_pList_ == NULL)
        return 1;
    if (_nIndex_ >= _pList_->nCurrentCount)
        return 2;
    
    pCurrent = &(_pList_->nodeHeader);

    while (i <= _nIndex_)
    {
        pCurrent = pCurrent->pNext;
        i++;
    }
    return pCurrent->nData;
}
```
{% endcode %}

{% code title="addListData()" %}
```c
int addListData(linkedList* _pList_, int _nVal_, const int _nIndex_)
{
    int i = 0;
    node* pPrevious = NULL;
    node* pNewNode = NULL;

    if (_pList_ == NULL)
        return 1;
    if ((_nIndex_ > _pList_->nCurrentCount) || (_nIndex_ < 0))
        return 2;
    
    pNewNode = (node*)malloc(sizeof(node));
    pNewNode->nData = _nVal_;
    pNewNode->pNext = NULL;

    pPrevious = &(_pList_->nodeHeader);
    while (i < _nIndex_)
    {
        pPrevious = pPrevious->pNext;
        // pCurrent = pCurrent->pNext;
        i++;
    }
    pNewNode->pNext = pPrevious->pNext;
    pPrevious->pNext = pNewNode;

    (_pList_->nCurrentCount)++;
    return 0;
}
```
{% endcode %}

{% code title="removeListData()" %}
```c
int removeListData(linkedList* _pList_, const int _nIndex_)
{
    int i = 0;
    node* pCurrent = NULL;
    node* pPrevious = NULL;
    
    if (_pList_ == NULL)
        return 1;
    if ((_nIndex_ >= _pList_->nCurrentCount) || (_nIndex_ < 0))
        return 2;
    
    pPrevious = &(_pList_->nodeHeader);

    for (; i < _nIndex_; i++)
        pPrevious = pPrevious->pNext;
    
    pCurrent = pPrevious->pNext;
    pPrevious->pNext = pCurrent->pNext;

    free(pCurrent);

    (_pList_->nCurrentCount)--;
    return 0;
}
```
{% endcode %}

{% code title="deleteList()" %}
```c
int deleteList(linkedList* _pList_)
{
    node* pCurrent = NULL;
    node* pDelete = NULL;
    if (_pList_ == NULL)
        return 1;
    
    pCurrent = (_pList_->nodeHeader).pNext;
    
    while (pCurrent != NULL)
    {
        pDelete = pCurrent;
        pCurrent = pCurrent->pNext;

        free(pDelete);
    }

    free(_pList_);
    return 0;
}
```
{% endcode %}

<details>

<summary>error correction</summary>

LinkedList(89647,0x1dea25000) malloc: \*\*\* error for object 0x12a605f28: pointer being freed was not allocated\
LinkedList(89647,0x1dea25000) malloc: \*\*\* set a breakpoint in malloc\_error\_break to debug

</details>

{% code title="getListLength()" %}
```c
int getListLength(linkedList* _pList_)
{
    if (_pList_ == NULL)
        return 0;
    
    return _pList_->nCurrentCount;
}
```
{% endcode %}

{% code title="displayList()" %}
```c
int displayList(linkedList* _pList_)
{
    int i = 0;
    if (_pList_ == NULL)
        return 0;
    for (; i < _pList_->nCurrentCount; i++)
        printf("[%d] %d\n", i, getListData(_pList_, i));
    return 0;
}
```
{% endcode %}

<details>

<summary>displayList() 성능 관련 설명</summary>

displayList() 함수에서 실행되는 for문은 리스트에 저장된 데이터의 수에 따라 비례하게 증가한다. O(n)\
for문 이후 호출되는 getListData() 또한 리스트의 처음부터 인덱스 위치까지 순차적으로 참조하기에 O(n)의 속도를 가진다.\
for문이 n번 실행되면 getListData()도 동일하게 n번 실행되기에 n \* n = n^2 = O(n^2)의 시간 복잡도를 가진다.\
따라서, 리스트 전체를 출력하는 로직 치고는 매우 비효율적이다.

</details>

{% code title="iterateLinkedList()" %}
```c
int iterateLinkedList(linkedList* _pList_)
{
    int nCount = 0;
    node* pCurrent = NULL;
    if (_pList_ == NULL)
        return 1;

    pCurrent = _pList_->nodeHeader.pNext;
    while (pCurrent != NULL)
    {
        printf("[%d] %d\n", nCount, pCurrent->nData);
        nCount++;
        pCurrent = pCurrent->pNext;
    }
    printf("Node's: %d\n", nCount);

    return 0;
}
```
{% endcode %}

{% hint style="info" %}
iterateLinkedList()는 리스트를 순회하면서 바로 데이터를 출력하므로 불필요한 반복 계산이 없다.\
displayList()와 같은 추상 자료형을 사용하지만 내부 구현에서 성능 차이가 발생한다.
{% endhint %}

{% code title="concatList()" %}
```c
int concatList(linkedList* _pListA_, linkedList* _pListB_)
{
    node* pCurrent = NULL;
    if ((_pListA_ == NULL) && (_pListB_ == NULL))
        return 1;
    
    pCurrent = _pListA_->nodeHeader.pNext;
    while (pCurrent != NULL && pCurrent->pNext != NULL)
        pCurrent = pCurrent->pNext;
    
    pCurrent->pNext = _pListB_->nodeHeader.pNext;
    // _pListB_->nodeHeader.pNext = NULL;
    memset(_pListB_, 0, sizeof(linkedList));
    return 0;
}
```
{% endcode %}

***

### 배열 리스트와 연결 리스트 비교

| 구분     | 구현 방식 | 순차적 저장을 구현한 방식 | 접근 속도 | 구현 난이도 |       제약 사항 |
| ------ | :---: | :------------: | :---: | :----: | ----------: |
| 배열 리스트 |   배열  | 물리적 저장 순서가 순차적 |   빠름  |   낮음   | 최대 저장 개수 필요 |
| 연결 리스트 |  포인터  | 논리적 저장 순서가 순차적 |   느림  |   높음   |           - |

#### 배열리스트 > 연결리스트

* 배열리스트의 접근 속도가 O(1)인 이유는 저장 공간에 물리적으로 연속해 저장되어 있어 인덱스 번호만으로 바로 접근이 가능하기 때문
* 연결리스트의 경우 리스트를 구성하는 데이터의 수가 n개라면 접근 연산은 O(n)이라 배열리스트에 비해 느리다.
* 연결리스트의 경우 메모리 누수(leak)로 인한 오류 가능성으로 인해 구현 난이도가 높다.

#### 연결리스트 > 배열리스트

* 연결리스트의 경우 물리적으로 연속된 메모리 공간을 필요로 하지 않음
* 동적 할당과 해제를 통해 원하는 만큼 메모리를 사용할 수 있어 효율이 좋다.

#### 배열리스트 = 연결리스트

* 자료 추가 및 삭제 시 O(n)
* 다만, 배열리스트는 데이터의 복사 연산 자체가 많은 반면, 연결리스트는 적절한 노드 위치를 찾는 연산에 시간을 소요
* 데이터 추가와 삭제가 빈번한 경우 배열리스트 < 연결리스트

## 소스 코드 링크

* [LinkedLists.c](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/LinkedLists.c)
* [EXLinkedLists.c](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/ExLinkedLists.c)
