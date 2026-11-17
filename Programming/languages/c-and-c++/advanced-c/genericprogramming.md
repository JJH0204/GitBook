# 제네릭 프로그래밍 (Generics)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ADC-002-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 제네릭 프로그래밍의 정의와 C에서 `void *`로 제네릭 스택을 구현하는 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

제네릭 프로그래밍(generic programming)은 타입을 매개변수로 두어 하나의 코드를 여러 데이터 타입에 재사용하는 프로그래밍 기법이다. C++ 템플릿, C#과 Swift의 제네릭이 대표적이다.

* 코드의 재사용성을 높인다.
* 알고리즘, 데이터 구조, 메모리 할당 방식 등 소프트웨어 구성 요소를 체계적으로 결합해 재사용성, 모듈화, 사용 편의성을 높이는 것이 목적이다.

스택처럼 자료형만 다른 코드를 반복해 쓰는 문제를 제네릭 프로그래밍으로 푼다.

## 2. 구성 요소

### 2-1. C에서의 제네릭 구현 수단

| 수단 | 역할 | 한계 |
|---|---|---|
| `void *` | 어떤 타입의 포인터든 저장한다 | 컴파일러가 타입을 검사하지 못한다 |
| 크기(`size_t`) | 요소 하나의 바이트 수를 함께 전달한다(값을 복사할 때 필요) | 호출하는 쪽이 정확한 값을 줘야 한다 |
| 콜백 함수(함수 포인터) | 타입에 맞는 비교, 출력, 해제 동작을 호출하는 쪽에서 전달한다 | 시그니처를 맞춰야 한다 |
| C11 `_Generic` | 컴파일 시점에 인자의 타입에 따라 식을 선택한다 | 타입별 선택만 가능하며 하나의 코드를 여러 타입에 재사용하는 템플릿 기능이 아니다 |

C는 템플릿 같은 제네릭 기능을 직접 지원하지 않는다. 따라서 `void *`, 크기, 콜백 함수를 조합해 비슷한 기능을 구현한다.

### 2-2. 스택 자료 구조

스택 노드의 데이터 타입을 `void *`로 선언하면 어떤 타입의 포인터든 저장할 수 있다. 데이터를 저장하거나 꺼낼 때 타입에 맞는 처리는 콜백 함수로 한다.

{% code title="node.h" %}
```c
typedef struct Node {
    void *data;          // 제네릭 데이터 포인터
    struct Node *next;   // 다음 노드를 가리키는 포인터
} Node;
```
{% endcode %}

{% code title="stack.h" %}
```c
typedef struct Stack {
    Node *top;           // 스택의 상단을 가리키는 포인터
} Stack;
```
{% endcode %}

## 3. 동작 원리

1. `Push`는 새 노드를 만들고 `data`에 포인터를 저장한 뒤, 새 노드의 `next`를 기존 `top`으로 연결하고 `top`을 새 노드로 바꾼다.
2. `Pop`은 `top` 노드의 `data`를 꺼내고 `top`을 다음 노드로 옮긴 뒤 노드를 해제한다.
3. 호출하는 쪽은 `Pop`이 돌려준 `void *`를 원래 타입 포인터로 캐스팅해 사용한다.

## 4. 예제 코드

{% code title="stack.c (Push)" %}
```c
#include <stdlib.h>

int Push(Stack *stack, void *data) {
    Node *newNode = (Node *)malloc(sizeof(Node));
    if (newNode == NULL) return -1;   // 할당 실패
    newNode->data = data;             // void 포인터로 어떤 타입의 데이터도 저장
    newNode->next = stack->top;
    stack->top = newNode;
    return 0;
}
```
{% endcode %}

{% code title="stack.c (Pop)" %}
```c
void *Pop(Stack *stack) {
    if (stack->top == NULL) return NULL;

    Node *topNode = stack->top;
    void *data = topNode->data;
    stack->top = topNode->next;
    free(topNode);
    return data;    // 제네릭 포인터 반환
}
```
{% endcode %}

### 사용 예

아래 `main`은 원본에 없는 예시로, `int` 값의 주소를 저장하고 꺼낸다.

```c
#include <stdio.h>

int main(void) {
    Stack stack = { NULL };
    int a = 10, b = 20;

    Push(&stack, &a);
    Push(&stack, &b);

    int *p = (int *)Pop(&stack);   // void *를 int *로 캐스팅
    printf("%d\n", *p);            // 20
    return 0;
}
```

## 5. 코드 설명

| 대상 | 설명 |
|---|---|
| `Push` 반환값 | 원본은 `malloc` 실패를 검사하지 않았다. 실패 시 `-1`을 반환하도록 정정했다 |
| `Pop` | 스택이 비어 있으면 `NULL`을 반환한다. 호출하는 쪽은 반환값이 `NULL`인지 확인한다 |
| 캐스팅 | `void *`를 사용하려는 타입의 포인터(`int *` 등)로 캐스팅한다. 실제 가리키는 타입과 다르게 캐스팅하면 동작이 정의되지 않는다 |
| 수명 | 스택은 포인터만 저장한다. 가리키는 데이터(`a`, `b`)는 스택에서 꺼내 쓸 때까지 유효해야 한다 |

## 6. 한계와 주의

{% hint style="warning" %}
CAUTION: 정수와 포인터 크기 불일치. 정수를 `void *`로 직접 변환해 저장하는 방식은 위험하다.
{% endhint %}

* 32비트 환경에서 `void *`와 `int`는 모두 4바이트다.
* 64비트 환경에서 `void *`는 8바이트, `int`는 4바이트다. 데이터 모델(LP64, LLP64 등)에 따라 크기가 달라진다.
* 정수와 포인터를 직접 변환하면 컴파일러가 경고를 낸다.
* 정수와 포인터를 변환해야 하면 `<stdint.h>`의 `intptr_t`/`uintptr_t`를 사용한다. 이 두 타입은 C99 표준에서 선택 사항이므로 모든 구현이 제공한다고 가정하지 않는다.
* 정수 값 자체를 저장하려면 정수의 주소를 저장하는 방식(위 사용 예)이 더 안전하다.

사용 예시(원본 보존. `pQueueNode`, `pQueue`, `nLoopCount`는 원본 프로젝트의 변수이며 이 문서에서는 정의하지 않는다):

{% code title="example.c" %}
```c
#include <stdint.h>

intptr_t nodeIndex = (intptr_t)pQueueNode->nodeData;

queue_enqueue(pQueue, (void *)(intptr_t)nLoopCount);
```
{% endcode %}

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] C++ 템플릿과 C의 `void *` 방식은 타입 검사에서 어떻게 다른가?
- [ ] `void *` 스택에 지역 변수의 주소를 저장할 때 어떤 문제가 생길 수 있는가?
- [ ] 내가 같은 코드를 자료형만 바꿔 반복해 쓴 경험을 적어 보면?
