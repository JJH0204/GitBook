# 동적 메모리 할당 (Allocation)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PTR-005-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | `malloc`으로 힙 메모리를 할당하고 `free`로 해제하는 규칙과 흔한 오류 유형을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳. (1) `Ex_Fun`의 `printDynamicAlloc(person_1)` 첫 호출은 `malloc`만 한 직후라 `name`이 초기화되지 않은 상태로 `%s`에 쓰여 UB였다. 값을 대입한 뒤에 출력하도록 순서를 바꿨다. (2) `free(person_1)` 후 그 포인터로 `printDynamicAlloc`을 호출하는 것은 해제 후 사용(UB)이다. 해제 직후 `person_1 = NULL;`을 대입하도록 정정했다(원본 주석이 이 사실을 안내했다). (3) `malloc` 반환값 검사를 추가했다. (4) `person_1->name`은 문자열 리터럴 포인터이므로 `const char *`로 바꿨다.
{% endhint %}

## 1. 정의

동적 메모리 할당은 실행 중에 힙(heap)에서 필요한 크기만큼 메모리를 얻는 것이다. `<stdlib.h>`의 `malloc`으로 얻고 `free`로 돌려준다. 할당한 크기와 수명은 프로그래머가 관리한다.

## 2. 구성 요소

| 요소 | 역할 | 주의 |
|---|---|---|
| `malloc(size)` | `size`바이트를 할당하고 `void *`를 반환한다 | 실패하면 `NULL`. 내용은 초기화되지 않는다 |
| `calloc(n, size)` | `n * size`바이트를 할당하고 0으로 채운다 | 실패하면 `NULL` |
| `free(p)` | 할당한 메모리를 반환한다 | `free(NULL)`은 안전하다. 포인터 값은 바뀌지 않는다 |
| `sizeof(type)` | 타입의 크기를 계산한다 | 함수가 아니라 컴파일 시점 연산자다 |
| `->` | 포인터로 구조체 멤버에 접근한다 | `p->age`는 `(*p).age`와 같다 |

C에서는 `void *`가 다른 포인터 타입으로 암시 변환되므로 `malloc`의 반환 값 캐스트는 필요하지 않다. 원본 코드는 캐스트를 쓰며, 이는 C에서 허용되지만 C++에서는 필수다. `sizeof(*p)`를 쓰면 타입이 바뀌어도 크기가 어긋나지 않는다.

### 오류 유형 구분

| 오류 | 설명 | 분류 |
|---|---|---|
| 메모리 누수(leak) | 할당하고 해제하지 않는다. 프로그램이 계속 메모리를 점유한다 | 버그. 표준이 정의한 UB는 아니다 |
| 이중 해제(double free) | 이미 `free`한 포인터를 다시 `free`한다 | UB |
| 해제 후 사용(use after free) | `free` 후 그 메모리를 읽거나 쓴다 | UB |
| 초기화 안 한 메모리 읽기 | `malloc` 직후 내용을 읽는다 | 값이 정해지지 않음(UB에 이를 수 있다) |
| `NULL` 역참조 | `malloc` 실패를 검사하지 않고 쓴다 | UB |
| 범위 밖 접근 | 할당 크기를 넘어 읽고 쓴다 | UB |

## 3. 동작 원리

```
malloc  ->  [값 대입]  ->  사용  ->  free  ->  p = NULL
```

1. `malloc`이 `NULL`이면 즉시 처리한다(실패 반환).
2. 값을 채운 뒤 사용한다.
3. 다 쓰면 `free`한다.
4. `free`는 포인터를 `NULL`로 바꾸지 않는다. 해제 직후 `p = NULL;`을 직접 대입한다.

## 4. 예제 코드

{% code title="DynamicAllocation.c" %}
```c
//DynamicAllocation.c
#include <stdio.h>
#include <stdlib.h> // 반드시 포함해야 함

/* 구조체 */
typedef struct {
    const char * name;
    int age;
} person;

void printDynamicAlloc(person * p);

/* 예제 1 */
void Ex_Fun(void)
{
    /* 동적 할당 사용 방법 */
    person * person_1 = (person *)malloc(sizeof(person));
    /*
    malloc()은 "void 포인터"를 반환합니다. 따라서 데이터 타입을 "person *"로 설정해야 합니다.
    sizeof는 실제 함수가 아니며, 컴파일러가 이를 해석하여 person 구조체의 실제 메모리 크기로 변환합니다.
    */
    if (person_1 == NULL)
    {
        return;
    }

    /* 구조체 멤버에 접근하려면 "->"를 사용할 수 있습니다 */
    person_1->name = "Jaeho";
    person_1->age = 27;

    printDynamicAlloc(person_1);

    /* 동적으로 할당된 구조체를 다 사용한 후에는 "free"를 사용하여 해제할 수 있습니다 */
    free(person_1);
    person_1 = NULL;

    printDynamicAlloc(person_1);
}

/* 확인 함수 */
void printDynamicAlloc(person * p)
{
    if (p == NULL)
    {
        // 주의: free()는 포인터를 NULL로 바꾸지 않는다. 해제된 포인터를 다시 쓰면 UB이므로 해제 직후 p = NULL;로 직접 지운다
        printf("메모리가 정리되었습니다~\n");
        return;
    }

    printf("사람 이름: %s, 나이: %d\n", p->name, p->age);
}

/* 연습 */
typedef struct {
  int x;
  int y;
} point;

int main(void)
{
    // Ex_Fun();

    point * mypoint = NULL;

    /* mypoint가 가리키는 새로운 point 구조체를 동적으로 할당합니다 */
    mypoint = (point*)malloc(sizeof(point));
    if (mypoint == NULL)
    {
        return 1;
    }

    mypoint->x = 10;
    mypoint->y = 5;
    printf("mypoint 좌표: %d, %d\n", mypoint->x, mypoint->y);

    free(mypoint);
    mypoint = NULL;

    return 0;
}
```
{% endcode %}

## 5. 코드 설명

1. `Ex_Fun`: `person` 하나를 할당하고 `NULL`이면 반환한다. 이름과 나이를 대입한 뒤 출력한다. 출력: `사람 이름: Jaeho, 나이: 27`.
2. `free(person_1)` 뒤 `person_1 = NULL;`로 지운다. 이후 `printDynamicAlloc(NULL)`은 `메모리가 정리되었습니다~`를 출력한다. `NULL`로 지우지 않고 그 포인터를 쓰면 해제 후 사용(UB)이다.
3. `main`은 `Ex_Fun()` 호출이 주석 처리되어 있어 연습 부분만 실행한다. `point`를 하나 할당해 `x=10, y=5`를 대입하고 출력한다. 출력: `mypoint 좌표: 10, 5`.
4. 마지막에 `free(mypoint)`로 해제해 누수를 막는다.

## 6. 한계·주의

* `malloc`이 실패할 수 있으므로 반환값을 항상 검사한다.
* `malloc`한 메모리는 초기화되지 않는다. 0으로 시작해야 하면 `calloc`을 쓴다.
* 같은 포인터를 두 곳에서 해제하지 않는다. 소유권을 한 곳에서만 갖는다.
* 구조체의 `name` 같은 멤버가 별도로 `malloc`한 메모리를 가리키면 그것도 따로 `free`해야 한다. 이 예제의 `name`은 리터럴이라 `free`하면 안 된다(UB).
* 할당 크기를 계산할 때 `n * sizeof(T)`가 `size_t`를 넘지 않는지(오버플로) 주의한다. 배열이면 `calloc(n, sizeof(T))`가 곱셈 오버플로를 검사한다.
* 관련 개념: [Segmentation Fault](../../../cs_basics/os_memory/memory-management/segmentationfault.md), [메모리 할당 유효성 점검](../../../cs_basics/os_memory/memory-management/memoryallocationvaliditycheck.md).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 메모리 누수와 이중 해제가 어떻게 다른지, 어느 쪽이 UB인지 내 말로 설명해 보자.
- [ ] `free(p)` 후 `p = NULL;`을 대입하는 이유를 적어 보자.
- [ ] `malloc`이 `NULL`을 반환하는 상황이 언제 생길 수 있는지 적어 보자.
