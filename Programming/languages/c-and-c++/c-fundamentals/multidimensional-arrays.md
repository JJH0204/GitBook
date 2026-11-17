# 다차원 배열 (Multidim Arrays)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CFD-008-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 2차원 배열의 선언, 초기화, 중첩 반복문 순회를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳. `int main()`을 `int main(void)`로 바꿨다. 나머지는 원본 그대로다.
{% endhint %}

## 1. 정의

다차원 배열은 배열의 배열이다. `int grades[2][5]`는 "`int` 5개짜리 배열" 2개를 가진 배열이다. 메모리에는 행(row) 순서로 연속 저장된다(row-major).

## 2. 구성 요소

| 요소 | 예 | 역할 |
|---|---|---|
| 선언 | `int grades[2][5];` | 2행 5열 |
| 초기화 | `{ {80, 70, ...}, {85, 80, ...} }` | 행마다 중괄호로 묶는다 |
| 접근 | `grades[1][3]` | 2행 4열 요소 |
| 순회 | 바깥 `for`는 행, 안쪽 `for`는 열 | 모든 요소를 방문한다 |

## 3. 예제 코드

{% code title="multidim.c" %}
```c
#include <stdio.h>

int main(void)
{
    /* TODO: declare the 2D array grades here */
    float average;
    int i;
    int j;

    int grades[2][5] = {
        {80, 70, 65, 89, 90},
        {85, 80, 80, 82, 87}
    };
    /*
    grades[0][0] = 80;
    grades[0][1] = 70;
    grades[0][2] = 65;
    grades[0][3] = 89;
    grades[0][4] = 90;

    grades[1][0] = 85;
    grades[1][1] = 80;
    grades[1][2] = 80;
    grades[1][3] = 82;
    grades[1][4] = 87;*/

    /* TODO: complete the for loop with appropriate terminating conditions */
    for (i = 0; i < 2; i++)
    {
        average = 0;
        for (j = 0; j < 5; j++)
        {
            average += grades[i][j];
        }

        /* TODO: compute the average marks for subject i */
        average = average/5;
        printf("The average marks obtained in subject %d is: %.2f\n", i, average);
    }

    return 0;
}
```
{% endcode %}

## 4. 코드 설명

1. `grades[2][5]`를 초기화 목록으로 만든다. 주석 처리된 블록은 요소별 대입으로 같은 결과를 만드는 대안이다.
2. 바깥 `for`(`i`)는 과목(행)을 바꾸고, `average`를 0으로 초기화한다.
3. 안쪽 `for`(`j`)는 5개 점수를 `average`에 더한다. 합이 `float`에 누적된다.
4. `average / 5`로 평균을 구해 소수점 둘째 자리까지 출력한다.
5. 예상 출력: 과목 0은 합 394 → `78.80`, 과목 1은 합 414 → `82.80`.

## 5. 한계·주의

* 반복 한계 `2`, `5`는 선언 크기와 같아야 한다. 어긋나면 범위 밖 접근(UB)이다.
* 함수에 2차원 배열을 넘길 때는 열 크기를 명시해야 한다(`int a[][5]` 또는 `int (*a)[5]`). 포인터로 바뀌는 방식은 [배열과 포인터](../pointers-and-memory/arrays-and-pointers.md)를 본다.
* 평균을 `int`로 계산하면 소수점이 버려진다. 예제는 `float`를 쓴다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 2차원 배열이 메모리에 어떤 순서로 저장되는지 내 말로 설명해 보자.
- [ ] 행과 열을 바꿔 순회하면 무엇이 달라지는지 적어 보자.
- [ ] 2차원 배열을 쓰는 실제 사례(성적표, 격자 등) 하나를 골라 적어 보자.
