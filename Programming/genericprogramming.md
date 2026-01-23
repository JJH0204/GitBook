# GenericProgramming

* 데이터 형식에 의존하지 않고, 하나의 값이 여러 다른 데이터 타입들을 가질 수 있는 기술에 중점을 둔 프로그래밍 기법
* 코드의 재사용성을 높인다.
* 여러 가지 유용한 소프트웨어 컴포넌트들을 체계적으로 융합하는 방법을 연구하는 것으로
* 그 목적은 알고리즘, 데이터 구조, 메모리 할당 메커니즘, 그리고 기타 여러 소프트웨어적인 장치들을 발전시켜 이들의 재사용성, 모듈화, 사용 편의성을 보다 높은 수준으로 끌어 올리고자 하는 것이다.

당신이 스택을 구현하면서 겪고 있는 문제에 대한 해결책은 "제네릭 프로그래밍"을 적용하는 것입니다. 제네릭 프로그래밍을 사용하면 데이터 타입을 일반화하여 다양한 자료형에 대해 코드를 재사용할 수 있습니다. C 언어에서는 제네릭 프로그래밍을 직접적으로 지원하지 않지만, `void *` 포인터와 콜백 함수를 활용하여 유사한 기능을 구현할 수 있습니다.

스택의 노드에 저장되는 데이터의 타입을 `void *`로 선언하여, 어떤 타입의 포인터든 저장할 수 있게 합니다. 이렇게 하면 스택을 여러 자료형에 대해 재사용할 수 있습니다. 그리고 데이터를 스택에 저장하거나 스택에서 꺼낼 때 해당 데이터의 타입에 맞는 처리를 위해 콜백 함수를 사용할 수 있습니다.

아래는 `void *`를 사용하여 다양한 데이터 타입을 처리할 수 있는 스택의 기본 구조와 간단한 예시입니다.

### 스택 노드 구조체 정의

{% code title="node.h" %}
```c
typedef struct Node {
    void *data;          // 제네릭 데이터 포인터
    struct Node *next;   // 다음 노드를 가리키는 포인터
} Node;
```
{% endcode %}

### 스택 구조체 정의

{% code title="stack.h" %}
```c
typedef struct Stack {
    Node *top;           // 스택의 상단을 가리키는 포인터
} Stack;
```
{% endcode %}

### 데이터를 스택에 푸시하는 함수

{% code title="stack.c" %}
```c
#include <stdlib.h>

void Push(Stack *stack, void *data) {
    Node *newNode = (Node *)malloc(sizeof(Node));
    newNode->data = data;   // void 포인터를 통해 어떤 타입의 데이터도 저장 가능
    newNode->next = stack->top;
    stack->top = newNode;
}
```
{% endcode %}

### 스택에서 데이터를 팝하는 함수

{% code title="stack.c (Pop)" %}
```c
#include <stdlib.h>

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

이 예시에서 `Push`와 `Pop` 함수는 `void *`를 사용하여 어떤 타입의 데이터도 처리할 수 있습니다. 데이터를 스택에 저장하거나 스택에서 꺼낼 때, 해당 데이터의 실제 타입에 맞게 캐스팅해서 사용하면 됩니다. 예를 들어, `int` 타입의 데이터를 스택에 저장하려면 `int` 타입의 포인터를 `void *`로 캐스팅하여 `Push` 함수에 전달하고, `Pop` 함수로부터 반환된 `void *` 데이터를 `int *`로 캐스팅하여 사용하면 됩니다.

이 방법을 통해 스택 구현 시 노드의 멤버 변수 자료형을 일반화하면, 스택 구현체를 다양한 자료형에 대해 재사용할 수 있으며, 유연성과 재사용성을 높일 수 있습니다.

{% hint style="warning" %}
### 정수와 포인터 크기 불일치 경고 우려

* 32bit 운영체제에서 `void *`와 `int`는 동일한 메모리 사이즈를 갖는다 (4 byte).
* 64bit 운영체제에서 `void *`는 8 byte, `int`는 4 byte를 갖는다.
* 운영체제에 따라 참조하는 메모리 사이즈가 달라질 수 있으므로, 정수와 포인터를 직접 변환하는 방식은 위험하며 컴파일러가 경고를 발생시킵니다.
* 이 문제를 보완하려면 적절한 포인터 정수 타입을 사용하세요 (`stdint.h`의 `intptr_t`/`uintptr_t` 등).

사용 예시:

{% code title="example.c" %}
```c
#include <stdint.h>

intptr_t nodeIndex = (intptr_t)pQueueNode->nodeData;

queue_enqueue(pQueue, (void *)(intptr_t)nLoopCount);
```
{% endcode %}
{% endhint %}
