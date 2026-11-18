# 배열 (Arrays)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CFD-006-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 배열의 선언, 요소 접근, 경계 규칙을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳. 두 `printf`에 줄 바꿈(`\n`)을 추가했다. 출력이 한 줄로 이어지는 문제를 막기 위해서다.
{% endhint %}

## 1. 정의

배열은 같은 자료형의 값을 메모리에 연속으로 저장하는 구조다. 요소는 0부터 시작하는 인덱스로 접근한다.

## 2. 구성 요소

| 요소 | 예 | 역할 |
|---|---|---|
| 선언 | `int a_numbers[10];` | 크기가 10인 `int` 배열. 유효한 인덱스는 0~9 |
| 초기화 | `int a[] = {1, 2, 3};` | 크기를 초기화 목록에서 정한다 |
| 접근 | `a_numbers[6]` | 7번째 요소 |
| 대입 | `a_numbers[i] = 10 * i;` | 요소에 값을 저장한다 |

## 3. 예제 코드

{% code title="arrays.c" %}
```c
#include <stdio.h>

int main(void)
{
    int a_numbers[10];
    int max_Array = 10;

    for (int i=0; i < max_Array; i++)
    {
        a_numbers[i] = 10 * i;
    }

    printf("The 7th number in the array is %d.\n", a_numbers[6]);

    /* TODO: define the grades variable here */
    int grades[3];
    int average;

    grades[0] = 80;
    /* TODO: define the missing grade
       so that the average will sum to 85. */
    grades[1] = 85;
    grades[2] = 90;

    average = (grades[0] + grades[1] + grades[2]) / 3;
    printf("The average of the 3 grades is: %d\n", average);

    return 0;
}
```
{% endcode %}

## 4. 코드 설명

1. `a_numbers[i] = 10 * i;`로 0, 10, 20, ..., 90을 저장한다.
2. 7번째 요소는 인덱스 6이므로 `60`을 출력한다.
3. `grades`는 80, 85, 90을 저장한다. 합 255를 3으로 나누면 85이며 정수 나눗셈이라 소수점 이하는 버려진다.
4. `for (int i = ...)`처럼 반복문 안에서 변수를 선언하는 문법은 C99부터 가능하다.

## 5. 한계·주의

* 범위 밖 인덱스(`a_numbers[10]`, `a_numbers[-1]`)에 접근하면 UB다. 컴파일러는 경계를 검사하지 않는다.
* 선언만 하고 값을 넣지 않은 요소는 읽으면 안 된다. 예제는 읽기 전에 모든 요소에 값을 대입한다.
* 배열 크기는 `sizeof(a_numbers) / sizeof(a_numbers[0])`로 계산할 수 있다. 함수 인자로 넘기면 포인터로 바뀌어 이 계산이 불가능하다([배열과 포인터](../pointers-and-memory/arrays-and-pointers.md)).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 배열 인덱스가 0부터 시작하는 이유와, 범위를 벗어나면 왜 위험한지 내 말로 설명해 보자.
- [ ] `average`가 `int`일 때와 `float`일 때 결과가 어떻게 다른지 적어 보자.
- [ ] 배열 크기를 상수로 정하는 방식과 `sizeof`로 계산하는 방식 중 어느 쪽을 쓸지, 이유와 함께 적어 보자.
