# 연결 리스트 상세 (Linked List)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-005-DO |
| 유형 | D&O (원리·복잡도) + 예제 코드 |
| 목적 | 단일 연결 리스트의 구조, 기본 연산, C 구현(ADT)과 배열 리스트와의 차이를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

연결 리스트(linked list)는 동적으로 할당한 노드들을 포인터로 이어 붙인 선형 자료구조다. 각 노드는 값 하나와 다음 노드를 가리키는 포인터 하나를 가진다. 마지막 노드의 포인터는 `NULL`이다.

이 문서는 단일 연결 리스트(노드가 다음 노드만 가리키는 리스트)를 다룬다. 포인터와 동적 메모리 할당(`malloc`, `free`)을 알고 있다고 가정한다.

### 배열과의 차이

| 구분 | 연결 리스트 | 배열 |
|---|---|---|
| 크기 | 필요에 따라 늘리고 줄인다. 초기 크기를 정하지 않는다 | 선언 시 크기가 정해진다(동적 배열은 재할당이 필요하다) |
| 중간 삽입·삭제 | 위치의 앞 노드를 알면 O(1) | 뒤 요소를 이동하므로 O(n) |
| 임의 접근 | 불가. n번째 노드까지 앞에서부터 따라가야 하므로 O(n) | 인덱스로 O(1) |
| 메모리 | 노드마다 포인터 한 개가 더 필요하고 할당 비용이 든다 | 연속된 공간이라 오버헤드가 작다 |
| 오류 위험 | 포인터와 동적 할당 때문에 메모리 누수, 세그먼트 오류 위험이 크다 | 상대적으로 작다 |

## 2. 구성 요소

### 2-1. 기본 노드와 헤드 포인터

{% code title="노드 정의" %}
```c
typedef struct node {
    int val;
    struct node * next;
} node_t;
```
{% endcode %}

노드는 자기 자신의 타입을 가리키는 포인터를 멤버로 갖는다. C에서는 구조체 이름(`struct node`)이 정의 중에도 쓸 수 있어서 이런 재귀적 정의가 가능하다.

```
------------------------------              ------------------------------
|              |             |            \ |              |             |
|     DATA     |     NEXT    |--------------|     DATA     |     NEXT    |
|              |             |            / |              |             |
------------------------------              ------------------------------
```

리스트는 첫 노드를 가리키는 헤드 포인터(head) 변수 하나로 유지한다. 헤드가 `NULL`이면 빈 리스트다.

### 2-2. 헤더 노드(센티널)와 헤드 포인터의 차이

{% hint style="info" %}
NOTE: 이 문서에는 두 가지 구현이 나온다. 3절의 `node_t` 예제는 헤드 포인터 방식이고, 5절의 ADT 구현은 헤더 노드(센티널, sentinel) 방식이다.
{% endhint %}

| 방식 | 비어 있는 상태 | 첫 노드 |
|---|---|---|
| 헤드 포인터 | `head == NULL` | `head`가 가리키는 노드 |
| 헤더 노드(센티널) | `nodeHeader.pNext == NULL`(`nCurrentCount == 0`) | `nodeHeader.pNext`가 가리키는 노드 |

5절 코드의 `nodeHeader`는 포인터가 아니라 데이터를 저장하지 않는 더미 노드 구조체다. 센티널을 두면 첫 위치에 넣거나 지울 때도 "앞 노드"가 항상 있어 처리가 같아진다.

## 3. 동작 원리: 기본 연산 (헤드 포인터 방식)

### 3-1. 첫 노드 만들기

```c
node_t * head = NULL;
head = (node_t *) malloc(sizeof(node_t));
if (head == NULL) {
    return 1;
}

head->val = 1;
head->next = NULL;
```

`malloc`이 `NULL`을 반환했는지 항상 확인한다. 값을 넣고 `next`를 `NULL`로 비워 두면 노드 하나짜리 리스트가 된다.

노드를 더 이으려면 `next`를 따라간다.

```c
node_t * head = NULL;
head = (node_t *) malloc(sizeof(node_t));
head->val = 1;
head->next = (node_t *) malloc(sizeof(node_t));
head->next->val = 2;
head->next->next = NULL;
```

이 방식으로는 계속 이을 수 없으므로 마지막 노드까지 이동하는 반복문이 필요하다.

### 3-2. 순회(traverse)와 출력

순회에는 현재 노드를 가리키는 `current` 포인터를 쓴다. 값을 출력한 뒤 `current`를 다음 노드로 옮기고, 리스트 끝(`NULL`)에서 멈춘다.

```c
void print_list(node_t * head) {
    node_t * current = head;

    while (current != NULL) {
        printf("%d\n", current->val);
        current = current->next;
    }
}
```

### 3-3. 리스트 끝에 추가

헤드에서 시작해 `next`가 `NULL`인 마지막 노드까지 이동한 뒤 새 노드를 붙인다. 시간은 O(n)이다.

```c
void push_back(node_t * head, int val) {
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

{% hint style="warning" %}
CAUTION: 이 함수는 `head`가 `NULL`이면(빈 리스트) `head->next`를 읽어 NULL을 역참조한다. 빈 리스트에는 쓸 수 없고, `malloc` 반환값도 검사하지 않는다. 원본에서 `push`였던 함수 이름은 아래 맨 앞 추가 함수와 겹치지 않게 `push_back`으로 바꿨다.
{% endhint %}

### 3-4. 리스트 맨 앞에 추가

{% stepper %}
{% step %}
### 새 노드 생성

새 노드를 만들고 값을 저장한다.
{% endstep %}

{% step %}
### 새 노드를 기존 헤드에 연결

새 노드의 `next`를 기존 헤드 포인터가 가리키던 노드로 설정한다.
{% endstep %}

{% step %}
### 헤드를 새 노드로 설정

리스트의 헤드 변수를 새 노드로 바꾼다.
{% endstep %}
{% endstepper %}

함수 안에서 호출자의 헤드 변수 자체를 바꿔야 하므로 헤드 포인터의 주소(이중 포인터)를 인자로 받는다.

```c
int push_front(node_t ** head, int val) {
    node_t * new_node;
    new_node = (node_t *) malloc(sizeof(node_t));
    if (new_node == NULL) {
        return -1;
    }

    new_node->val = val;
    new_node->next = *head;
    *head = new_node;
    return 0;
}
```

원본에는 `malloc` 검사가 없었다. 실패 시 `-1`, 성공 시 `0`을 반환하도록 정정했다. 시간은 O(1)이다.

### 3-5. 첫 노드 제거

{% stepper %}
{% step %}
### 다음 노드 저장

헤드가 가리키는 노드의 `next`를 임시 변수에 저장한다.
{% endstep %}

{% step %}
### 현재 헤드 해제

헤드 노드의 값을 보관한 뒤 `free()`로 해제한다.
{% endstep %}

{% step %}
### 헤드를 다음 노드로 설정하고 값을 반환

헤드를 저장해 둔 다음 노드로 바꾸고 제거한 값을 반환한다.
{% endstep %}
{% endstepper %}

```c
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

{% hint style="info" %}
NOTE: 이 함수는 오류 값 `-1`과 정상 데이터를 같은 반환값으로 돌려준다. 값이 `-1`인 노드를 지우면 오류와 구분할 수 없다. 5절의 `getListData` 정정 방식(결과는 출력 인자로, 반환값은 상태 코드로)을 쓰면 해결된다.
{% endhint %}

### 3-6. 마지막 노드 제거

마지막 노드 제거는 끝에 추가하는 것과 비슷하지만, 마지막 노드의 바로 앞 노드의 `next`를 바꿔야 한다. 그래서 `current->next->next`가 `NULL`인지 두 칸 앞을 보며 이동한다. 시간은 O(n)이다.

노드가 하나뿐이면 헤드 자체가 지워지므로 호출자의 헤드 변수도 `NULL`로 바뀌어야 한다. 그래서 이중 포인터를 받는다.

```c
int remove_last(node_t ** head) {
    int retval = -1;
    node_t * current = NULL;

    if (*head == NULL) {
        return -1;
    }

    /* if there is only one item in the list, remove it */
    if ((*head)->next == NULL) {
        retval = (*head)->val;
        free(*head);
        *head = NULL;
        return retval;
    }

    /* get to the second to last node in the list */
    current = *head;
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

정정 내용은 다음과 같다. 원본은 `node_t * head`를 받아 노드가 하나일 때 `free(head)`만 하고 호출자의 `head`를 갱신하지 못해 해제된 주소를 가리키게 됐다(dangling pointer). 이중 포인터로 바꾸고 `*head = NULL`을 추가했으며 빈 리스트 검사를 넣었다.

### 3-7. 특정 위치의 노드 제거

앞 노드를 찾아야 하므로 헤드부터 순회한다.

{% stepper %}
{% step %}
삭제할 노드 이전의 노드까지 이동한다.
{% endstep %}

{% step %}
삭제할 노드를 임시 포인터에 저장한다.
{% endstep %}

{% step %}
이전 노드의 `next`를 삭제할 노드 뒤의 노드로 바꾼다.
{% endstep %}

{% step %}
임시 포인터로 노드를 `free()`한다.
{% endstep %}
{% endstepper %}

```c
int remove_by_index(node_t ** head, int n) {
    int i = 0;
    int retval = -1;
    node_t * current = *head;
    node_t * temp_node = NULL;

    if (n < 0) {
        return -1;
    }

    if (n == 0) {
        return pop(head);
    }

    if (current == NULL) {
        return -1;
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

정정 내용은 다음과 같다. `n < 0`이면 반복문이 돌지 않아 인덱스 1이 지워지던 문제를 막는 검사와, 빈 리스트에서 `n > 0`일 때 `current->next`가 NULL 역참조가 되던 문제를 막는 검사를 추가했다. 오류 값 `-1`과 데이터가 섞이는 한계는 `pop`과 같다.

## 4. 복잡도

| 연산 | 헤드 포인터만 있을 때 | 비고 |
|---|---|---|
| 맨 앞 삽입·삭제 | O(1) | |
| 맨 뒤 삽입 | O(n) | tail 포인터를 따로 유지하면 O(1) |
| 맨 뒤 삭제 | O(n) | 단일 연결 리스트에서는 tail 포인터가 있어도 바로 앞 노드를 찾아야 하므로 O(n) |
| 인덱스로 접근 | O(n) | |
| 인덱스로 삽입·삭제 | O(n) | 위치 탐색이 O(n), 연결 변경은 O(1) |
| 앞 노드를 이미 가진 상태의 삽입·삭제 | O(1) | |
| 탐색(값 찾기) | O(n) | |

## 5. 예제 코드: 연결 리스트 ADT의 C 구현

헤더 노드(센티널) 방식이다. 아래 코드는 `<stdio.h>`, `<stdlib.h>`, `<string.h>`를 포함한 파일 하나에 모으는 것을 가정한다. 반환 코드는 `0` 성공, `1` 리스트 포인터가 `NULL`, `2` 인덱스 범위 오류, `3` 메모리 할당 실패다.

### 5-1. 노드와 리스트 구조

* 노드는 저장할 데이터(`nData`)와 다음 노드의 주소(`pNext`)를 멤버로 갖는 구조체다.
* 리스트는 노드 개수(`nCurrentCount`)와 센티널 노드(`nodeHeader`)를 가진다.
* 최대 개수를 미리 정할 필요가 없다. 추가·삭제 때 노드를 만들고 해제한 뒤 연결만 바꾼다.

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

{% code title="linkedList 구조체" %}
```c
typedef struct LinkedList
{
    int nCurrentCount;
    node nodeHeader;
} linkedList;
```
{% endcode %}

### 5-2. 구현

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
int getListData(linkedList* _pList_, const int _nIndex_, int* _pOut_)
{
    int i = 0;
    node* pCurrent = NULL;
    if (_pList_ == NULL || _pOut_ == NULL)
        return 1;
    if (_nIndex_ < 0 || _nIndex_ >= _pList_->nCurrentCount)
        return 2;
    
    pCurrent = &(_pList_->nodeHeader);

    while (i <= _nIndex_)
    {
        pCurrent = pCurrent->pNext;
        i++;
    }
    *_pOut_ = pCurrent->nData;
    return 0;
}
```
{% endcode %}

정정 내용은 다음과 같다. 원본은 `int getListData(list, index)`가 오류 코드(1, 2)와 데이터를 같은 반환값으로 돌려줬다. 데이터가 1이나 2인 노드와 오류를 구분할 수 없었다. 결과를 출력 인자 `_pOut_`로 받고 반환값은 상태 코드로만 쓰도록 바꿨고, 음수 인덱스 검사를 추가했다.

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
    if (pNewNode == NULL)
        return 3;
    pNewNode->nData = _nVal_;
    pNewNode->pNext = NULL;

    pPrevious = &(_pList_->nodeHeader);
    while (i < _nIndex_)
    {
        pPrevious = pPrevious->pNext;
        i++;
    }
    pNewNode->pNext = pPrevious->pNext;
    pPrevious->pNext = pNewNode;

    (_pList_->nCurrentCount)++;
    return 0;
}
```
{% endcode %}

`_nIndex_`는 `0`부터 `nCurrentCount`까지 허용한다. `nCurrentCount`는 맨 뒤에 추가하는 위치다. `malloc` 실패 검사(반환 코드 3)를 추가했다.

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

범위 검사는 `_nIndex_ >= nCurrentCount`이다. `>`를 쓰면 `_nIndex_ == nCurrentCount`일 때 `pCurrent`가 `NULL`이 되어 역참조한다.

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

{% hint style="warning" %}
CAUTION: `pointer being freed was not allocated`는 `malloc`으로 받지 않은 주소나 이미 해제한 주소를 `free`할 때 나오는 오류다. 이 리스트에서는 `concatList` 뒤에 B의 노드가 A에 속하는데, B를 `memset`으로 비우지 않고 A와 B 양쪽에 `deleteList`를 호출하면 같은 노드를 두 번 해제해 생긴다. 센티널 `nodeHeader`는 `linkedList` 구조체 안에 포함돼 있으므로 따로 `free`하지 않는다.
{% endhint %}

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
    int nData = 0;
    if (_pList_ == NULL)
        return 1;
    for (; i < _pList_->nCurrentCount; i++)
    {
        if (getListData(_pList_, i, &nData) == 0)
            printf("[%d] %d\n", i, nData);
    }
    return 0;
}
```
{% endcode %}

`getListData`의 새 시그니처에 맞춰 수정했다. 리스트가 `NULL`일 때 다른 함수와 같이 `1`을 반환한다(원본은 `0`).

`displayList()`의 시간 복잡도는 O(n²)다. `for`문이 n번 돌고, 매번 `getListData()`가 처음부터 인덱스 위치까지 따라가 O(n)이 걸리기 때문이다. 전체 출력 치고는 비효율적이다.

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
NOTE: `iterateLinkedList()`는 리스트를 한 번만 순회하므로 O(n)이다. `displayList()`와 결과는 같지만 내부 구현 때문에 성능 차이가 난다.
{% endhint %}

{% code title="concatList()" %}
```c
int concatList(linkedList* _pListA_, linkedList* _pListB_)
{
    node* pCurrent = NULL;
    if ((_pListA_ == NULL) || (_pListB_ == NULL))
        return 1;
    if (_pListA_ == _pListB_)
        return 2;
    
    pCurrent = &(_pListA_->nodeHeader);
    while (pCurrent->pNext != NULL)
        pCurrent = pCurrent->pNext;
    
    pCurrent->pNext = _pListB_->nodeHeader.pNext;
    _pListA_->nCurrentCount += _pListB_->nCurrentCount;
    memset(_pListB_, 0, sizeof(linkedList));
    return 0;
}
```
{% endcode %}

정정 내용은 다음과 같다.

* 검사 조건을 `&&`에서 `||`로 바꿨다. `&&`는 둘 다 `NULL`일 때만 오류로 보므로 한쪽만 `NULL`이면 아래에서 NULL을 역참조한다.
* 탐색 시작점을 `A->nodeHeader.pNext`가 아니라 센티널 `&(A->nodeHeader)`로 바꿨다. A가 빈 리스트이면 원본은 `pCurrent`가 `NULL`이 되어 `pCurrent->pNext`에서 역참조한다.
* `A->nCurrentCount`에 `B->nCurrentCount`를 더하는 줄을 추가했다. 원본은 개수를 갱신하지 않아 연결된 B의 노드를 `getListData`, `displayList`, `removeListData`가 범위 밖으로 취급했다.
* A와 B가 같은 리스트이면 순환이 생기므로 반환 코드 2로 막았다.
* 연결 후 B를 `memset`으로 비운다. B의 노드는 A가 소유하며, B에 대해 `deleteList`를 호출해도 구조체만 해제되고 노드는 이중 해제되지 않는다.

## 6. 배열 리스트와 연결 리스트 비교

| 구분 | 배열 리스트 | 연결 리스트 |
|---|---|---|
| 구현 방식 | 배열 | 포인터 |
| 저장 방식 | 물리적으로 연속 | 논리적으로 순차(메모리상 흩어짐) |
| 인덱스 접근 | O(1) | O(n) |
| 맨 앞 삽입·삭제 | O(n) (요소 이동) | O(1) |
| 중간 삽입·삭제(위치를 이미 알 때) | O(n) (요소 이동) | O(1) |
| 중간 삽입·삭제(인덱스로 지정) | O(n) (요소 이동) | O(n) (위치 탐색) |
| 구현 난이도 | 낮음 | 높음 |
| 제약 | 최대 저장 개수 필요 | 노드마다 포인터 메모리 사용 |

해석은 다음과 같다.

* 배열 리스트의 접근이 O(1)인 이유는 연속된 공간에 저장돼 인덱스만으로 주소를 계산할 수 있기 때문이다.
* 연결 리스트는 물리적으로 연속된 메모리를 요구하지 않고, 필요한 만큼 할당·해제할 수 있다. 다만 노드가 흩어져 있어 CPU 캐시 효율은 배열보다 나쁜 경우가 많다.
* 인덱스로 지정해 추가·삭제할 때는 둘 다 O(n)이다. 배열은 요소 복사에, 연결 리스트는 위치 탐색에 시간을 쓴다.
* 맨 앞이나 이미 찾아 둔 위치에 삽입·삭제가 빈번하면 연결 리스트가 유리하다. 인덱스 접근이 빈번하면 배열 리스트가 유리하다.

스택과 큐도 연결 리스트로 구현할 수 있다. 스택은 [스택 (Stack)](stack.md)(PRG-DST-003-DO)을 참조한다.

## 7. 참조

* [LinkedLists.c](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/LinkedLists.c)
* [EXLinkedLists.c](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/ExLinkedLists.c)
* 3절 앞부분의 설명은 learn-c.org의 연결 리스트 튜토리얼을 바탕으로 한 것으로 보인다(출처 미확인).

## 8. 약어·용어

| 용어 | 뜻 |
|---|---|
| 헤드(head) 포인터 | 첫 노드를 가리키는 포인터 변수 |
| 센티널(sentinel) 노드 | 데이터를 저장하지 않고 리스트 맨 앞에 두는 더미 노드. 코드의 `nodeHeader` |
| ADT | Abstract Data Type. 추상 자료형. 연산만 정의하고 구현은 숨긴다 |
| dangling pointer | 이미 해제된 메모리를 가리키는 포인터 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 단일 연결 리스트에서 맨 앞 삽입은 O(1)이고 맨 뒤 삭제는 O(n)인 이유를 적는다.
- [ ] 센티널 노드를 두면 코드가 어떻게 단순해지는지 `addListData`로 설명한다.
- [ ] 배열 대신 연결 리스트를 골랐던 상황, 또는 고르지 않아야 했던 상황을 하나 적는다.
