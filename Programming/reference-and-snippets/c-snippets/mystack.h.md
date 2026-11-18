# 연결 스택 헤더 (MyStack.h)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-REF-001-REF |
| 유형 | REF (코드 정본) |
| 목적 | 연결 리스트 기반 문자(`char`) 스택의 자료형과 함수 선언을 한곳에 둔다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서와 [연결 스택 구현 (MyStack.c)](mystack.c.md)(PRG-REF-002-REF)가 이 저장소의 스택 구현 정본이다. 개념은 [스택 (Stack)](../../cs-fundamentals/data-structures/stack.md)(PRG-DST-003-DO)에 있다. 함수 선언의 시그니처는 원본과 같고 주석과 헤더 가드 주석만 보강했다.
{% endhint %}

## 1. 자료형

| 이름 | 정의 | 역할 |
|---|---|---|
| `node` | `struct StackNode`. 멤버는 `char cData`, `struct StackNode *pNext` | 스택 노드 하나. 문자 한 개와 아래 노드 포인터를 가진다 |
| `stack` | `struct LinkedStack`. 멤버는 `node *pTop`, `int nCurrentCount` | 스택 본체. top 노드와 현재 요소 수를 가진다 |

## 2. 반환값 규약

| 함수 | 성공 | 실패 |
|---|---|---|
| `initStack`, `initNode`, `displayStack`, `deleteStack` | `0` | 음수(`-1`: 인자가 `NULL`) |
| `push` | `0` | `-1`: 스택이 `NULL`, `-2`: 메모리 할당 실패, `-3`: 노드 초기화 실패 |
| `createStack` | 새 스택 포인터 | `NULL` |
| `pop` | 떼어낸 노드 포인터. 호출자가 `free`한다 | `NULL`(스택이 `NULL`이거나 비어 있음) |
| `peek` | top 값을 복사한 새 노드. 호출자가 `free`한다 | `NULL`(스택이 `NULL`, 비어 있음, 할당 실패) |

스택 오버플로(overflow)는 용량 제한이 없는 연결 구현에서 `malloc` 실패(`push`의 `-2`)로 나타난다. 언더플로(underflow)는 빈 스택에서 `pop`/`peek`이 `NULL`을 반환하는 것이다.

## 3. 헤더 코드

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

// 반환값: 성공 0, 실패 음수
int initStack(stack *_pStack_);

// 반환값: 새 스택, 실패 시 NULL. 사용 후 deleteStack으로 해제한다
stack *createStack(void);

// 반환값: 성공 0, 실패 음수
int initNode(node *_pNode_, const char _cData_);

// 반환값: 성공 0, 실패 음수(-1: 스택 NULL, -2: 할당 실패, -3: 초기화 실패)
int push(stack *_pStack_, const char _cData_);

// 반환값: top 노드(스택에서 분리됨), 비었거나 오류면 NULL. 호출자가 free한다
node *pop(stack *_pStack_);

// 반환값: top 값을 복사한 새 노드, 비었거나 오류면 NULL. 호출자가 free한다
node *peek(const stack *_pStack_);

// 반환값: 성공 0, 실패 음수
int displayStack(const stack *_pStack_);

// 남은 노드와 스택 본체를 모두 해제한다. 호출 후 _pStack_ 포인터는 사용하지 않는다
int deleteStack(stack *_pStack_);
#endif /* MyStack_h */
```
{% endcode %}

## 4. 정정 내용

| 위치 | 원본 | 정정 | 이유 |
|---|---|---|---|
| 선언 주석 | 없음 | 반환값·소유권 주석 추가 | `pop`과 `peek`의 반환 노드를 누가 `free`하는지 헤더만 봐서는 알 수 없었다 |
| 헤더 가드 | `MyStack_h` | 유지 | 유효한 식별자이며 다른 헤더와 겹치지 않는다. 대문자 관례(`MYSTACK_H`)로 바꿔도 된다 |
| 매개변수 이름 | `_pStack_` 등 | 유지 | 밑줄로 시작하고 소문자가 이어지는 이름은 파일 범위에서만 예약된다. 매개변수는 해당하지 않는다 |

## 5. 다른 문서의 `stack_*` 함수와의 대응

{% hint style="info" %}
NOTE: [이진 트리 (Binary Tree)](../../cs-fundamentals/data-structures/binarytrees_kr.md)(PRG-DST-001-DO)의 비재귀 순회 코드는 `stack_*` 이름을 쓴다. 이름은 아래처럼 대응하지만 자료형이 달라 그대로 바꿔 쓸 수 없다.
{% endhint %}

| 이진 트리 문서의 함수 | 이 문서의 함수 | 차이 |
|---|---|---|
| `stack_Create()` | `createStack()` | 같은 역할 |
| `stack_Push(pStack, ptr)` | `push(pStack, c)` | 트리 코드는 `node *` 포인터를 넣고, 이 스택은 `char` 한 개를 넣는다 |
| `stack_Pop(pStack)` | `pop(pStack)` | 트리 코드는 넣었던 포인터를 바로 돌려받는다. 이 스택은 스택 노드를 반환하므로 `cData`를 읽은 뒤 `free`해야 한다 |
| `stack_Peek(pStack)` | `peek(pStack)` | 이 스택은 복사한 노드를 새로 할당해 반환한다. 호출마다 `free`가 필요하다 |
| `stack_Delete(pStack)` | `deleteStack(pStack)` | 같은 역할 |
| `pStack->nCurrentCount` | `pStack->nCurrentCount` | 같은 이름 |

차이는 두 가지다. 첫째, 트리 순회는 `node *`(트리 노드)를 저장해야 하는데 이 스택의 요소는 `char`다. 둘째, 두 문서가 모두 `node`라는 이름의 자료형을 쓰므로 한 프로그램에 함께 넣으면 이름이 충돌한다. 트리 순회에 쓰려면 요소 타입을 `void *`로 바꾼 별도 스택을 만들고 함수 이름을 `stack_*`로 맞춘다.

## 6. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [mystack.c.md](mystack.c.md) | PRG-REF-002-REF | 연결 스택 구현 (MyStack.c) |
| [stack.md](../../cs-fundamentals/data-structures/stack.md) | PRG-DST-003-DO | 스택 (Stack) |
| [binarytrees_kr.md](../../cs-fundamentals/data-structures/binarytrees_kr.md) | PRG-DST-001-DO | 이진 트리 (Binary Tree) |

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 반환값 규약 표, `stack_*` 대응 표 추가 |
