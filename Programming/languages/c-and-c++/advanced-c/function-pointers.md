# 함수 포인터 (Function Pointer)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ADC-001-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 함수 포인터의 선언 문법, 호출 방법, `qsort` 비교 함수(콜백) 사용법을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

함수 포인터(function pointer)는 함수의 주소를 저장하는 포인터다. 포인터가 데이터를 가리키듯 함수 포인터는 함수를 가리키며, 포인터를 통해 그 함수를 호출할 수 있다.

함수를 이름으로 직접 호출할 수 있는데도 함수 포인터를 쓰는 이유는 호출할 함수를 실행 중에 바꾸기 위해서다. 예를 들어 정렬 함수가 오름차순과 내림차순을 모두 지원해야 하면, 비교 규칙을 함수 포인터로 전달받는다.

## 2. 구성 요소

### 2-1. 선언 문법

```c
void (*pf)(int);
```

| 부분 | 의미 |
|---|---|
| `pf` | 변수 이름 |
| `(*pf)` | `pf`는 포인터다 |
| `(int)` | 가리키는 함수는 `int` 하나를 인자로 받는다 |
| 맨 앞 `void` | 가리키는 함수는 `void`를 반환한다 |

읽는 순서는 변수 이름에서 시작해 안쪽에서 바깥쪽으로 읽는다. `pf`는 "`int`를 받아 `void`를 반환하는 함수에 대한 포인터"다.

{% hint style="warning" %}
CAUTION: `*pf` 주위의 괄호를 빼면 의미가 달라진다. `void *pf(int);`는 `void *`를 반환하는 함수 `pf`의 선언이다.
{% endhint %}

다른 형태의 예는 다음과 같다.

```c
char * (*pf)(int *);
```

1. `pf`는 함수 포인터다.
2. `char *`는 가리키는 함수의 반환 타입이다.
3. `int *`는 인자의 타입이다.

### 2-2. 함수 포인터를 쓰는 이유

| 용도 | 설명 |
|---|---|
| 실행 흐름 제어 | 콜백 함수 등을 구현해 실행 흐름을 유연하게 제어한다 |
| 동작 전달 | 함수 포인터를 매개변수로 받는 함수는 전달된 인자에 따라 다르게 동작한다 |
| 재사용성·유지 보수성 | 호출하는 쪽 코드를 바꾸지 않고 동작만 교체한다 |

## 3. 동작 원리

1. 함수 이름은 식 안에서 그 함수의 주소로 변환된다. 따라서 `pf = someFunction;`과 `pf = &someFunction;`은 같다.
2. 호출은 `(*pf)(5)` 또는 `pf(5)`로 한다.
3. `qsort`는 비교 함수 포인터를 받아 두 요소를 비교할 때마다 이 함수를 호출한다(콜백).

## 4. 예제 코드

### 4-1. 함수 포인터로 함수 호출

```c
#include <stdio.h>

void someFunction(int arg)
{
    printf("This is someFunction being called and arg is: %d\n", arg);
    printf("Whoops leaving the function now!\n");
}

int main(void)
{
    void (*pf)(int);
    pf = &someFunction;
    printf("We're about to call someFunction() using a pointer!\n");
    (pf)(5);
    printf("Wow that was cool. Back to main now!\n\n");
    return 0;
}
```

### 4-2. `qsort`에 비교 함수 전달

`qsort`는 비교 함수가 반환하는 값의 부호로 순서를 정한다. 아래 `compare`는 반대 순서(내림차순)로 정렬하도록 만든 비교 함수다.

```c
#include <stdio.h>
#include <stdlib.h> // for qsort()

int compare(const void *left, const void *right)
{
    int l = *(const int *)left;
    int r = *(const int *)right;
    return (l < r) - (l > r); // 내림차순: 큰 값이 앞에 온다
}

int main(void)
{
    int (*cmp)(const void *, const void *);
    cmp = &compare;

    int iarray[] = {1, 2, 3, 4, 5, 6, 7, 8, 9};
    size_t n = sizeof(iarray) / sizeof(*iarray);
    qsort(iarray, n, sizeof(*iarray), cmp);

    for (size_t c = 0; c < n; c++)
    {
        printf("%d \t", iarray[c]);
    }
    printf("\n");
    return 0;
}
```

예상 출력은 `9 8 7 6 5 4 3 2 1`이다.

## 5. 코드 설명

| 대상 | 설명 |
|---|---|
| `int main(void)` | C99 이후 암묵적 `int`(반환형 생략)는 허용되지 않으므로 `main`의 반환형을 `int`로 쓴다 |
| `qsort(base, n, size, cmp)` | 배열 시작 주소, 요소 개수, 요소 크기, 비교 함수 순서로 인자를 받는다 |
| `(l < r) - (l > r)` | 비교 결과를 -1, 0, 1로 만든다 |
| `size_t n` | `sizeof`의 결과 타입에 맞춰 부호 없는 타입으로 반복한다 |

## 6. 한계와 주의

{% hint style="danger" %}
WARNING: 원본은 비교 함수를 `*(int *)right - *(int *)left`로 썼다. 뺄셈은 값의 차이가 `int` 범위를 넘으면 오버플로(부호 있는 정수 오버플로는 정의되지 않은 동작)가 발생할 수 있다. `(a > b) - (a < b)` 형태로 비교한다.
{% endhint %}

* 이 문서의 원본은 정렬 함수를 `sort()`라고 불렀으나 C 표준 라이브러리 함수는 `qsort()`다. `sort()`는 C++ 표준 라이브러리(`std::sort`)에 있다.
* 가리키는 함수와 시그니처(반환 타입, 인자 타입)가 다른 함수의 주소를 대입하거나 그 타입으로 호출하면 동작이 정의되지 않는다.
* 비교 함수는 `qsort`가 요구하는 `int (*)(const void *, const void *)` 형태여야 한다.

## 7. 참조

* [qsort — cplusplus.com](http://www.cplusplus.com/reference/cstdlib/qsort/)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 함수를 이름으로 호출하지 않고 함수 포인터로 호출해야 하는 상황을 내 경험으로 설명하면?
- [ ] `void (*pf)(int);`를 내 말로 읽어 보면?
- [ ] `qsort`의 비교 함수 반환값이 정렬 순서를 어떻게 정하는가?
