# 반복문 (Loops)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CFD-004-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | `for`, `while`과 `continue`, `break`로 코드를 반복하는 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

반복문은 조건이 거짓이 될 때까지 코드 블록을 되풀이한다. 횟수가 정해져 있으면 `for`, 조건으로 끝나면 `while`을 쓴다.

## 2. 구성 요소

| 요소 | 문법 | 역할 |
|---|---|---|
| `for` | `for (초기식; 조건식; 증감식) { ... }` | 초기식을 한 번 실행하고, 조건이 참인 동안 본문과 증감식을 반복한다 |
| `while` | `while (조건) { ... }` | 본문 실행 전에 조건을 검사한다 |
| `do ... while` | `do { ... } while (조건);` | 본문을 먼저 실행하고 나중에 조건을 검사한다. 최소 1회 실행한다 |
| `continue` | `continue;` | 이번 반복의 나머지를 건너뛰고 다음 반복으로 간다 |
| `break` | `break;` | 가장 안쪽 반복문을 즉시 끝낸다 |

## 3. 예제 코드

{% code title="loops.c" %}
```c
//loops.c
#include <stdio.h>

void ForLoops(void)
{
    int array[] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int factorial = 1;
    int i;

    /* calculate the factorial using a for loop  here*/
    for (i = 0; i < 10; i++)
    {
        factorial *= array[i];
    }

    printf("10! is %d.\n", factorial);
}

void WhileLoops(void)
{
    /*인쇄를 앞둔 현재 개수가 5개 미만이면 인쇄하지 마십시오.
    인쇄하려는 현재 번호가 10보다 크면 인쇄하지 말고 루프를 중지하십시오.*/
    int array[] = {1, 7, 4, 5, 9, 3, 5, 11, 6, 3, 4};
    int i = 0;

    while (i < 10)
    {
       /* your code goes here */
        if (array[i] < 5)
        {
            i++;
            continue;
        }
        else if (array[i] > 10)
        {
            break;
        }
        printf("%d\n", array[i]);
        i++;
    }
}

int main(void)
{
    // ForLoops();
    WhileLoops();
    return 0;
}
```
{% endcode %}

## 4. 코드 설명

1. `ForLoops`: `i`가 0~9인 동안 `factorial`에 `array[i]`(1~10)를 곱한다. 결과는 10! = 3,628,800이다. 32비트 `int`는 12!(479,001,600)까지 표현한다. 13!(6,227,020,800)부터는 범위를 넘어 signed 오버플로(UB)가 되므로 곱할 숫자를 늘릴 때 주의한다.
2. `WhileLoops`: 배열은 11개 요소지만 `i < 10`이므로 인덱스 0~9만 검사한다.
3. 5 미만(1, 4, 3)은 `i++` 후 `continue`로 건너뛴다. `continue` 전에 `i++`를 하지 않으면 무한 루프가 된다.
4. 10 초과(11)를 만나면 `break`로 끝낸다.
5. 예상 출력(`WhileLoops`): 7, 5, 9, 5를 한 줄씩. 인덱스 7(값 11)에서 멈추므로 그 뒤의 6, 3은 검사하지 않는다.
6. `main`에서 `ForLoops()`는 주석 처리되어 있어 실행되지 않는다.

## 5. 한계·주의

* 배열 길이와 반복 횟수를 따로 적으면 어긋나기 쉽다. 범위 밖 배열 접근은 UB다. `sizeof(array) / sizeof(array[0])`로 요소 수를 계산할 수 있다.
* `continue`를 쓸 때 증감 위치를 확인한다. `for`는 증감식이 자동 실행되지만 `while`은 직접 써야 한다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `for`와 `while`을 어떤 기준으로 골라 쓰는지 내 말로 설명해 보자.
- [ ] `WhileLoops`에서 `i++` 없이 `continue`만 쓰면 어떻게 되는지 적어 보자.
- [ ] 반복문에서 무한 루프나 경계 오류를 겪은 경험이 있다면 적어 보자.
