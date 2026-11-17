# 연결 스택 구현 (MyStack.c)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-REF-002-REF |
| 유형 | REF (코드 정본) |
| 목적 | [MyStack.h](mystack.h.md)에 선언한 연결 스택 함수의 구현을 한곳에 둔다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 함수 이름의 `stack_*` 대응과 반환값 규약은 [연결 스택 헤더 (MyStack.h)](mystack.h.md)(PRG-REF-001-REF) 5절에 있다. 호출 예(`main`)는 [main.c 작성 및 진입점](../../languages/c-and-c++/build-and-tooling/main.c.md)에 있다.
{% endhint %}

## 1. 구성

| 함수 | 역할 | 시간 복잡도 |
|---|---|---|
| `initStack` | 이미 할당된 스택을 빈 상태로 초기화한다 | O(1) |
| `createStack` | 스택을 할당하고 초기화한다 | O(1) |
| `initNode` | 노드에 값을 넣고 `pNext`를 `NULL`로 둔다 | O(1) |
| `push` | 노드를 할당해 top에 연결한다 | O(1) |
| `pop` | top 노드를 분리해 반환한다 | O(1) |
| `peek` | top 값을 복사한 새 노드를 반환한다 | O(1) |
| `displayStack` | top부터 아래로 출력한다 | O(n) |
| `deleteStack` | 모든 노드와 스택 본체를 해제한다 | O(n) |

## 2. 정정 내용

| 함수 | 원본의 문제 | 정정 |
|---|---|---|
| `createStack` | `initStack` 실패 시 `pResult`를 해제하지 않고 `NULL`을 반환한다(메모리 누수) | 반환 전에 `free(pResult)`를 호출한다 |
| `push` | `initNode` 실패 시 `pNewNode`를 해제하지 않는다. 오류 메시지의 함수 이름이 `createStack()`이다 | `free(pNewNode)`를 추가하고 메시지를 `push()`로 고친다 |
| `pop` | 빈 스택 검사가 `pTop == NULL && nCurrentCount == 0`이다. 두 값이 어긋나면(`pTop`만 `NULL`) 아래에서 `NULL`을 역참조한다 | `pTop == NULL`만 검사한다. 노드 연결이 기준이므로 개수는 조건에 넣지 않는다 |
| `peek` | `pop`과 같은 `&&` 검사. `initNode` 실패 시 `pPeekNode`를 해제하지 않는다 | `pTop == NULL`만 검사하고 실패 시 `free(pPeekNode)`를 호출한다 |
| `displayStack` | 문제 없음 | 원본 유지 |
| `deleteStack` | 문제 없음. 호출 후 호출자의 포인터는 해제된 주소를 가리킨다 | 코드는 유지하고 사용 후 `NULL`을 대입하라고 3절 NOTE에 적는다 |
| 공통 | `malloc` 결과를 `(stack*)`, `(node*)`로 형변환한다 | 유지. C에서는 필요 없지만 오류가 아니며 C++로 컴파일할 때는 필요하다 |

## 3. 구현 코드

{% code title="MyStack.c" %}
```c
//
//  MyStack.c
//  C_HeaderTest
//  Created by admin on 3/16/24.
//

#include "MyStack.h"

int initStack(stack *_pStack_)
{
    if (_pStack_ == NULL)
    {
        printf("Unallocated memory access error: initStack()\n");
        return -1;
    }

    _pStack_->nCurrentCount = 0;
    _pStack_->pTop = NULL;
    return 0;
}

stack *createStack(void)
{
    stack *pResult = (stack*)malloc(sizeof(stack));
    if (pResult == NULL)
    {
        printf("memory allocation error: createStack()\n");
        return NULL;
    }
    if (initStack(pResult) != 0)
    {
        printf("Memory initialization failed: createStack()\n");
        free(pResult);
        return NULL;
    }
    return pResult;
}

int initNode(node *_pNode_, const char _cData_)
{
    if (_pNode_ == NULL)
    {
        printf("Unallocated memory access error: initNode()\n");
        return -1;
    }
    _pNode_->cData = _cData_;
    _pNode_->pNext = NULL;
    return 0;
}

int push(stack *_pStack_, const char _cData_)
{
    node *pNewNode = NULL;
    if (_pStack_ == NULL)
    {
        printf("Unallocated memory access error: push()\n");
        return -1;
    }
    pNewNode = (node*)malloc(sizeof(node));
    if (pNewNode == NULL)
    {
        printf("memory allocation error: push()\n");
        return -2;
    }
    if (initNode(pNewNode, _cData_) != 0)
    {
        printf("Memory initialization failed: push()\n");
        free(pNewNode);
        return -3;
    }
    pNewNode->pNext = _pStack_->pTop;
    _pStack_->pTop = pNewNode;
    _pStack_->nCurrentCount++;
    return 0;
}

node *pop(stack *_pStack_)
{
    node *pPopNode = NULL;
    if (_pStack_ == NULL)
    {
        printf("Unallocated memory access error: pop()\n");
        return NULL;
    }
    if (_pStack_->pTop == NULL)
    {
        printf("Stack underflow error: pop()\n");
        return NULL;
    }
    pPopNode = _pStack_->pTop;
    _pStack_->pTop = pPopNode->pNext;
    pPopNode->pNext = NULL;
    _pStack_->nCurrentCount--;
    return pPopNode;
}

node *peek(const stack *_pStack_)
{
    node *pPeekNode = NULL;
    if (_pStack_ == NULL)
    {
        printf("Unallocated memory access error: peek()\n");
        return NULL;
    }
    if (_pStack_->pTop == NULL)
    {
        printf("No data in stack: peek()\n");
        return NULL;
    }
    pPeekNode = (node*)malloc(sizeof(node));
    if (pPeekNode == NULL)
    {
        printf("memory allocation error: peek()\n");
        return NULL;
    }
    if (initNode(pPeekNode, _pStack_->pTop->cData) != 0)
    {
        printf("Memory initialization failed: peek()\n");
        free(pPeekNode);
        return NULL;
    }
    return pPeekNode;
}

int displayStack(const stack *_pStack_)
{
    node *pNode = NULL;
    int nCount = 0;
    if (_pStack_ == NULL)
    {
        printf("Unallocated memory access error: displayStack()\n");
        return -1;
    }

    printf("current stack: %d number\n", _pStack_->nCurrentCount);
    pNode = _pStack_->pTop;
    for ( ; pNode != NULL; pNode = pNode->pNext)
    {
        printf("[%d]-[%c]\n", _pStack_->nCurrentCount - nCount, pNode->cData);
        nCount++;
    }

    return 0;
}

int deleteStack(stack *_pStack_)
{
    node *delNode = NULL;
    if (_pStack_ == NULL)
    {
        printf("Unallocated memory access error: deleteStack()\n");
        return -1;
    }
    while (_pStack_->pTop != NULL)
    {
        delNode = _pStack_->pTop;
        _pStack_->pTop = delNode->pNext;
        free(delNode);
    }
    free(_pStack_);
    return 0;
}
```
{% endcode %}

{% hint style="warning" %}
CAUTION: `pop`과 `peek`이 반환한 노드는 호출자가 `free`해야 한다. `deleteStack(pStack)` 뒤에는 `pStack`이 해제된 메모리를 가리키므로 `pStack = NULL;`을 대입하고 이후에 사용하지 않는다. `peek`은 호출마다 노드를 새로 할당하므로 값만 읽을 때는 `pStack->pTop->cData`를 직접 읽는 편이 싸다(빈 스택이 아닌지 먼저 확인한다).
{% endhint %}

## 4. 설계상 한계

| 항목 | 내용 |
|---|---|
| 요소 형식 | `char` 한 개만 저장한다. 다른 형식은 `node`의 `cData`와 함수 시그니처를 바꿔야 한다 |
| 오류 출력 | 라이브러리 함수가 `printf`(표준 출력)로 오류를 출력한다. 표준 오류(`fprintf(stderr, ...)`)로 보내는 편이 일반적이다 |
| 스레드 안전성 | 없다. 여러 스레드에서 같은 스택에 접근하려면 잠금이 필요하다 |
| 개수 오버플로 | `nCurrentCount`는 `int`다. `INT_MAX`개 이상 넣는 경우는 메모리가 먼저 부족하므로 검사하지 않는다 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [mystack.h.md](mystack.h.md) | PRG-REF-001-REF | 연결 스택 헤더 (MyStack.h) |
| [stack.md](../../cs-fundamentals/data-structures/stack.md) | PRG-DST-003-DO | 스택 (Stack) |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 메모리 누수 3건(`createStack`, `push`, `peek`)과 빈 스택 검사 조건(`pop`, `peek`) 정정 |
