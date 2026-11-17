# main.c 작성 및 진입점

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-BLD-004-REF |
| 유형 | REF (코드 + 빌드 명령) |
| 목적 | 연결 스택(`MyStack`)을 사용하는 `main.c` 예제와 빌드·실행 명령을 찾는다 |
| 확인 상태 | 미검증 (코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [MyStack.h](../../../reference-and-snippets/c-snippets/mystack.h.md) | (스니펫) | 연결 스택 헤더 |
| [MyStack.c](../../../reference-and-snippets/c-snippets/mystack.c.md) | (스니펫) | 연결 스택 구현 |
| [cmodularizationerror.md](cmodularizationerror.md) | PRG-BLD-003-TS | 링크 오류 해결 |

{% hint style="info" %}
NOTE: 스택 구현(`MyStack.h`, `MyStack.c`)의 정본은 `reference-and-snippets/c-snippets/`에 있다. 이 문서에는 사용 코드인 `main.c`만 둔다.
{% endhint %}

## 2. 빌드와 실행

| 명령 | 설명 |
|---|---|
| `gcc main.c MyStack.c -o main` | 두 소스 파일을 한 번에 컴파일하고 링크한다 |
| `./main` | 실행한다 (PowerShell: `.\main`) |

## 3. main.c

{% code title="main.c" %}
```c
//  main.c
//  C_test
//  Created by admin on 3/16/24.
#include "MyStack.h"

int main(void) {

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
        printf("Stack underflow: main()\n");
        deleteStack(pStack);
        return -2;
    }
    printf("Pop - [%c]\n", pNode->cData);
    free(pNode);

    displayStack(pStack);
    pNode = peek(pStack);
    if (pNode == NULL)
    {
        printf("No data in stack: main()\n");
        deleteStack(pStack);
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

## 4. 코드 설명

| 구간 | 설명 |
|---|---|
| `createStack()` | 스택을 만든다. 실패하면 `NULL`을 반환하므로 검사한다 |
| `push` 7회 | `L O V E Y O U` 순으로 넣는다. 맨 위는 `U`다 |
| `pop` | 맨 위 노드를 스택에서 떼어 반환한다. 호출자가 `free`한다 |
| `peek` | 맨 위 값을 복사한 새 노드를 반환한다. 스택은 바뀌지 않으며 호출자가 `free`한다 |
| `deleteStack` | 남은 노드와 스택 자체를 해제한다 |

예상 출력(코드 기준)은 다음과 같다. 처음 `displayStack`은 7개, `pop` 이후는 6개를 표시한다.

```
current stack: 7 number
[7]-[U]
[6]-[O]
[5]-[Y]
[4]-[E]
[3]-[V]
[2]-[O]
[1]-[L]
Pop - [U]
current stack: 6 number
[6]-[O]
...
Peek - [O]
```

## 5. 정정 내용

* `int main(int argc, const char * argv[])`를 `int main(void)`로 바꿨다. 인자를 쓰지 않는다.
* `pop`, `peek` 실패 메시지가 `Memory initialization failed`로 같아 원인을 구분할 수 없었다. 각각 `Stack underflow`, `No data in stack`으로 바꿨다.
* 오류로 일찍 반환하는 경로(`-2`, `-3`)에서 `deleteStack(pStack)`을 호출하도록 추가해 메모리 누수를 막았다.
