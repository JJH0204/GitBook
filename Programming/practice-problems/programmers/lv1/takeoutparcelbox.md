# 프로그래머스: 택배 상자 꺼내기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PPR-005-DO |
| 유형 | D&O (접근·복잡도) + 예제 코드 |
| 목적 | 지그재그로 쌓은 택배 상자에서 특정 번호를 꺼낼 때 꺼내야 하는 상자 수를 구하는 문제를 스택 시뮬레이션과 수식 두 가지로 푼다 |
| 언어 | C++ |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 문제 개요

상자 `1`부터 `n`까지를 한 층에 `w`개씩 쌓는다. 첫 층은 왼쪽에서 오른쪽으로, 다음 층은 오른쪽에서 왼쪽으로, 이후 번갈아 가며 놓는다. 번호 `num`인 상자를 꺼내려면 그 위의 상자를 모두 먼저 꺼내야 한다. `num`을 포함해 꺼내야 하는 상자 수를 구한다. 입력 범위와 그림은 프로그래머스 문제 페이지에서 확인한다.

## 2. 동작 원리

### 2-1. 아이디어 비교

| 아이디어 | 방법 | 시간 | 공간 |
|---|---|---|---|
| 1. 스택 시뮬레이션 | 열(column)마다 스택을 두고 `1..n`을 지그재그로 쌓은 뒤 `num`이 나올 때까지 꺼낸다 | O(n) | O(n) |
| 2. 수식 | `num`이 있는 열에서 그 위 상자 번호를 수식으로 건너뛰며 센다 | O(n / w) | O(1) |

### 2-2. 시뮬레이션: 쌓기

열 인덱스 `index`와 방향 `pivot`을 둔다. 각 상자를 `truck[index]`에 넣고 방향대로 `index`를 옮긴다. 끝을 벗어나면 방향을 뒤집고 `index`를 한 칸 되돌린다.

| 상황 | 처리 |
|---|---|
| `index >= w` (오른쪽 끝을 넘음) | `pivot = true`, `index--`. 마지막 열에 한 번 더 쌓고 왼쪽으로 간다 |
| `index < 0` (왼쪽 끝을 넘음) | `pivot = false`, `index++`. 첫 열에 한 번 더 쌓고 오른쪽으로 간다 |

### 2-3. 시뮬레이션: `num`이 있는 열 찾기

층 번호(0부터)는 `(num - 1) / w`다. 층 번호가 짝수면 왼쪽에서 오른쪽, 홀수면 오른쪽에서 왼쪽으로 놓인 층이다.

| 층 | 열 인덱스 |
|---|---|
| 짝수 층 (왼쪽 → 오른쪽) | `(num - 1) % w` |
| 홀수 층 (오른쪽 → 왼쪽) | `w - 1 - (num - 1) % w` |

원본은 이를 `fmod`로 `num / w`의 짝홀을 가려 계산했다. 아래 코드는 원본 식을 그대로 두었고 정수 식과 결과가 같다.

### 2-4. 수식 풀이

한 열에서 바로 위층의 상자 번호는 `현재 번호 + 2 × (w - 1 - (현재 번호 - 1) % w) + 1`이다. 현재 번호가 `n` 이하인 동안 이 식을 반복하며 센다. 상자가 놓이는 방향이 층마다 반대라서 위 상자까지의 번호 차이는 현재 열이 가장자리까지 남은 거리의 두 배에 1을 더한 값이 된다.

## 3. 복잡도

| 항목 | 시뮬레이션 | 수식 |
|---|---|---|
| 시간 | O(n) | O(n / w) |
| 공간 | O(n) | O(1) |

## 4. 예제 코드

### 4-1. 스택 시뮬레이션

```cpp
#include <string>
#include <vector>
#include <stack>
#include <cmath>

using namespace std;

int solution(int n, int w, int num) {
    int answer = 0;
    vector<stack<int>> truck(w);
    int box = 1, index = 0;
    bool pivot = false;

    while (box <= n)
    {
        if (index >= w)
        {
            pivot = true;
            index--;
        }
        else if (index < 0)
        {
            pivot = false;
            index++;
        }
        truck[index].push(box);
        if (pivot)
            index--;
        else
            index++;
        box++;
    }

    index = 0;
    float dump = fmod ( (float) num / (float) w, 2.0f );

    if ( 0.0f < dump && dump <= 1.0f )
        index = (num - 1) % w;
    else
        index = (num % w == 0) ? 0 : w - (num % w);

    int boxValue = 0;
    do
    {
        if (truck[index].empty())
            return 0;
        boxValue = truck[index].top();
        truck[index].pop();
        answer++;
    } while(boxValue != num);

    return answer;
}
```

### 4-2. 수식 풀이

```cpp
#include <string>
#include <vector>

using namespace std;

int solution(int n, int w, int num) {
    int answer = 0;
    while (num <= n)
    {
        answer++;
        num += (w - 1 - (w + num - 1) % w) * 2 + 1;
    }
    return answer;
}
```

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| `vector<stack<int>> truck(w)` | 열마다 스택 하나. 맨 위 상자가 스택의 `top`이다 |
| 쌓기 반복 | 2-2절의 `pivot`으로 방향을 바꾼다. 가장자리 열에는 연속 두 상자가 쌓인다(층이 바뀌는 지점) |
| `fmod` 분기 | `num / w`를 2로 나눈 나머지가 `(0, 1]`이면 왼쪽에서 오른쪽으로 놓인 층이다. 그 외는 반대 방향이다. 열 인덱스는 2-3절 표와 같다 |
| 꺼내기 `do-while` | `num`이 나올 때까지 `top`을 꺼내며 센다. 스택이 비면 0을 반환한다 |
| 수식 반복 | 2-4절의 식으로 `num`을 위 상자 번호로 바꾸며 `n`을 넘으면 멈춘다 |

## 6. 한계·주의

* 원본 메모의 첫 시도는 열 인덱스를 `num % w - 1`로 계산했고 `num`이 `w`의 배수이면 `-1`이 되어 배열 범위를 벗어나 `illegal instruction`으로 종료됐다. 정정한 식은 `(num - 1) % w`(왼쪽에서 오른쪽 층)와 `num % w == 0 ? 0 : w - num % w`(반대 층)이다. 배수일 때 인덱스를 0으로 둔다.
* `fmod`와 `float` 나눗셈은 부동소수점이다. 값이 작은 범위에서는 `num`이 `w`의 배수일 때 몫이 정확히 정수로 계산되어 문제가 없다. 정수만 쓰려면 층 번호 `(num - 1) / w`의 짝홀로 판단한다.
* 변수 이름 `index`는 일부 환경의 `<strings.h>`에 있는 함수 `index`와 같지만 지역 변수이므로 컴파일에는 영향이 없다.
* 수식 풀이는 열 구조를 따로 만들지 않아 가장 짧고 빠르다. 대신 식이 나오는 과정(2-4절)을 이해해야 오류를 찾을 수 있다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 상자를 꺼내는 규칙이 스택(LIFO)과 같은 이유를 적는다.
- [ ] 수식 풀이에서 위 상자의 번호 차이가 `2 × (가장자리까지 남은 거리) + 1`이 되는 이유를 그림 없이 설명한다.
