# 변수와 자료형 (Variables)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CFD-002-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | C의 기본 자료형, 값의 범위, boolean 표현 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳. 출력 문구를 실제 변수 이름(`i`, `f`, `d`)에 맞췄고 줄 바꿈을 추가했다. boolean 설명에 C99 `_Bool`과 `<stdbool.h>`를 명시했다.
{% endhint %}

## 1. 정의

변수(variable)는 값을 저장하는 이름 붙은 메모리 공간이다. 자료형(type)은 그 공간의 크기와 값을 해석하는 방법을 정한다.

## 2. 구성 요소

### 2-1. 기본 자료형

| 분류 | 자료형 | 설명 |
|---|---|---|
| 정수 | `char`, `short`, `int`, `long`, `long long` | 부호가 있는 정수. `long long`은 C99부터 표준이다 |
| 부호 없는 정수 | `unsigned char`, `unsigned short`, `unsigned int`, `unsigned long`, `unsigned long long` | 0 이상의 정수만 저장한다 |
| 부동 소수점 | `float`, `double` | 분수가 있는 실수. 일반적으로 IEEE 754 형식이다 |
| 구조체 | `struct` | 여러 값을 묶는다. [구조체](../data-structures-c/structures.md)에서 다룬다 |

### 2-2. 범위

자료형마다 저장할 수 있는 값의 범위가 다르다. 예를 들어 `char`가 signed이면 -128~127이고, 4바이트 `long`이면 -2,147,483,648~2,147,483,647이다.

{% hint style="info" %}
NOTE: 범위는 플랫폼마다 다르다. 64비트 Linux·macOS(LP64 데이터 모델)에서 `long`은 8바이트라 -9,223,372,036,854,775,808~9,223,372,036,854,775,807이다. 64비트 Windows(LLP64)에서 `long`은 4바이트다. `char`의 부호 여부도 구현에 따라 다르며, -128~127은 `char`가 signed일 때의 범위다. 정확한 범위는 `<limits.h>`와 `sizeof`로 확인한다.
{% endhint %}

크기를 고정해야 하면 `<stdint.h>`(C99)의 `int32_t`, `uint64_t` 등을 쓴다.

### 2-3. boolean

C89/C90에는 boolean 타입이 없어 매크로로 정의해 썼다. C99부터는 `_Bool` 타입과 `<stdbool.h>`의 `bool`, `true`, `false`를 쓸 수 있다.

{% code title="bool_like.h" %}
```c
#define BOOL char
#define FALSE 0
#define TRUE 1
```
{% endcode %}

C99 이상 방식:

```c
#include <stdbool.h>

bool is_ready = true;
```

## 3. 예제 코드

{% code title="example.c" %}
```c
#include <stdio.h>

int main(void)
{
    int i = 3;
    float f = 4.5;
    double d = 5.25;
    float sum;

    sum = i + f + d;
    // float f2i = (float)i;
    // float f2d = (float)d;

    // sum = f + f2i + f2d;

    printf("The sum of i, f, and d is %f.\n", sum);
    return 0;
}
```
{% endcode %}

## 4. 코드 설명

1. `i + f + d`에서 `int`는 `float`로, 그 합(`float`)은 `double`로 변환되어 더해진다(일반 산술 변환). 결과는 `double` 값 12.75이다.
2. 그 값을 `float sum`에 대입한다. 12.75는 `float`로 정확히 표현되므로 값이 유지된다.
3. `printf`의 `%f`는 `double`을 받는다. `float` 인자는 가변 인자 전달 시 `double`로 승격된다.
4. 예상 출력: `The sum of i, f, and d is 12.750000.`
5. 주석 처리된 줄은 명시적 형변환 `(float)i`로 같은 계산을 하는 대안이다.

## 5. 한계·주의

* `float`, `double`은 2진 소수라 0.1 같은 값을 정확히 표현하지 못한다. 같음 비교(`==`)에 쓰지 않는다.
* 정수 오버플로: signed 정수가 범위를 넘으면 UB다. unsigned는 2^n으로 나눈 나머지로 감싼다(wrap).
* 초기화하지 않은 지역 변수를 읽으면 값이 정해지지 않는다(UB에 이를 수 있다).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `int`, `long`, `char`의 범위가 플랫폼마다 달라질 수 있는 이유를 내 말로 설명해 보자.
- [ ] 내가 쓰는 환경에서 `sizeof(long)`이 얼마였는지, 그 결과를 어떻게 확인했는지 적어 보자.
- [ ] boolean을 매크로로 정의하는 방식과 `<stdbool.h>`를 쓰는 방식 중 어느 쪽을 쓸지, 이유와 함께 적어 보자.
