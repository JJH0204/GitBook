# 프로그래머스: 가장 많이 받은 선물

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PPR-004-DO |
| 유형 | D&O (접근·복잡도) + 예제 코드 |
| 목적 | 친구 사이의 선물 기록으로 다음 달 가장 많은 선물을 받을 친구의 선물 수를 구하는 문제의 풀이를 정리한다 |
| 언어 | C++ |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 문제 개요

친구 이름 목록(`friends`)과 이번 달까지의 선물 기록(`gifts`, 각 원소는 `"준 사람 받은 사람"`)이 주어진다. 두 사람 사이에서 더 많이 준 사람이 다음 달에 선물을 하나 받는다. 주고받은 수가 같거나 기록이 없으면 선물 지수(준 수 - 받은 수)가 큰 사람이 받는다. 지수도 같으면 주고받지 않는다. 다음 달에 가장 많이 받는 친구의 선물 수를 구한다. 입력 범위와 예시는 프로그래머스 문제 페이지에서 확인한다.

## 2. 동작 원리

### 2-1. 자료 구조

| 이름 | 형태 | 의미 |
|---|---|---|
| `giftIndicator[i][j]` | n × n 정수 행렬 | 친구 `i`가 친구 `j`에게 준 선물 수. 행이 준 사람, 열이 받은 사람이다 |
| `giftIndex[i]` | 길이 n 배열 | 친구 `i`의 선물 지수. 행 `i`의 합(준 수)에서 열 `i`의 합(받은 수)을 뺀 값 |

대각선(`i == j`)은 자기 자신이므로 합산에서 뺀다.

### 2-2. 단계

1. n × n 행렬을 0으로 만든다.
2. `friends`의 모든 순서쌍 `(i, j)`에 대해 문자열 `"friends[i] friends[j]"`가 `gifts`에 몇 번 있는지 세어 `giftIndicator[i][j]`에 넣는다.
3. 각 친구의 선물 지수를 계산한다.
4. 친구 `i`마다 다른 친구 `j`와 비교해 받을 선물 수 `result`를 센다.

| 조건 (`dump = giftIndicator[i][j] - giftIndicator[j][i]`) | `result` |
|---|---|
| `dump > 0` | +1 (`i`가 더 많이 줬다) |
| `dump < 0` | 변화 없음 (`j`가 받는다) |
| `dump == 0`이고 `giftIndex[i] > giftIndex[j]` | +1 |
| `dump == 0`이고 `giftIndex[i] <= giftIndex[j]` | 변화 없음 |

5. 모든 `result` 중 최댓값이 답이다.

## 3. 복잡도

| 항목 | 값 | 이유 |
|---|---|---|
| 시간 (원본 코드) | O(n² × m) | 순서쌍 n²개마다 `gifts` m개를 선형 탐색한다 |
| 시간 (개선) | O(m × n + n²) | `gifts`를 한 번 훑으며 이름을 인덱스로 바꿔 `giftIndicator`를 직접 올리면 된다 |
| 공간 | O(n²) | 행렬 |

n이 작은 문제라 원본 방식으로도 풀린다. 입력 범위는 문제 페이지에서 확인한다.

## 4. 예제 코드

`find`는 `<algorithm>` 헤더가 필요하다. 원본 코드는 이 헤더가 빠져 있었고 동적 할당한 배열을 해제하지 않았다. 아래는 헤더를 추가하고 `delete[]`를 보강한 코드다.

```cpp
#include <string>
#include <vector>
#include <algorithm>

using namespace std;

int solution(vector<string> friends, vector<string> gifts)
{
    int answer = 0;
    int size = friends.size();
    int** giftIndicator = new int*[size];

    // 2차원 선물지표 행렬 초기화
    for (int i = 0; i < size; i++)
    {
        giftIndicator[i] = new int[size];
        for (int j = 0; j < size; j++)
        {
            giftIndicator[i][j] = 0;
        }
    }

    // 행렬 업데이트
    for (int i = 0; i < size; i++)
    {
        for (int j = 0; j < size; j++)
        {
            string target = friends[i] + " " + friends[j];
            auto it = gifts.begin();
            while ((it = find(it, gifts.end(), target)) != gifts.end())
            {
                giftIndicator[i][j]++;
                ++it;
            }
        }
    }

    // 선물 지수 계산
    int* giftIndex = new int[size];
    for (int i = 0; i < size; i++)
    {
        giftIndex[i] = 0;
        for (int x = 0; x < size; x++)
        {
            giftIndex[i] += (i != x) ? giftIndicator[i][x] : 0;
        }

        for (int y = 0; y < size; y++)
        {
            giftIndex[i] -= (i != y) ? giftIndicator[y][i] : 0;
        }
    }

    // 문제 답 계산
    int result;
    for (int i = 0; i < size; i++)
    {
        result = 0;
        for (int j = 0; j < size; j++)
        {
            if (i == j) continue;

            int dump = giftIndicator[i][j] - giftIndicator[j][i];
            if (dump > 0)
                result++;
            else if (dump == 0)
                result += (giftIndex[i] > giftIndex[j]) ? 1 : 0;
        }
        answer = (answer >= result) ? answer : result;
    }

    // 동적 할당 해제
    for (int i = 0; i < size; i++)
        delete[] giftIndicator[i];
    delete[] giftIndicator;
    delete[] giftIndex;

    return answer;
}
```

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| 행렬 초기화 | `new int*[size]`로 행 포인터 배열을, 행마다 `new int[size]`로 열을 할당하고 0으로 채운다 |
| 행렬 업데이트 | 대상 문자열 `"A B"`를 만들고 `find`를 `it`부터 반복 호출해 일치하는 기록 수를 센다. 찾은 뒤 `++it`로 다음 위치에서 다시 찾는다 |
| 선물 지수 | 행 합(준 수)을 더하고 열 합(받은 수)을 뺀다. 대각선은 제외한다 |
| 답 계산 | 2-2절의 표대로 `result`를 세고 최댓값을 `answer`에 둔다 |
| 해제 | 행마다 `delete[]`한 뒤 행 포인터 배열과 `giftIndex`를 `delete[]`한다 |

## 6. 한계·주의

* `find`는 `<algorithm>` 헤더가 필요하다. 원본 메모에도 같은 주의가 있었다.
* 원본 코드는 `new[]`로 할당한 행렬과 `giftIndex`를 해제하지 않아 호출마다 메모리가 누수된다. 해제 코드를 추가했다. `vector<vector<int>>`를 쓰면 해제가 필요 없다.
* 대조 조건에서 `dump < 0`은 상대가 받으므로 `result`를 올리지 않는다. 원본 메모의 "`dump < 0` 이면 `j`가 `i`에게서..." 설명은 `j`가 받는 경우를 뜻한다.
* 지수가 같고 `dump == 0`이면 아무도 받지 않는다. 코드의 `>` 비교가 이를 처리한다.
* 원본 메모의 순서쌍은 `friends` 인덱스를 이름 대신 쓰기 위해 행렬로 푼다는 아이디어였다. 이름 → 인덱스 `map<string, int>`를 쓰면 `find` 탐색이 필요 없다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 선물 지수를 행렬의 행 합과 열 합으로 구하는 이유를 적는다.
- [ ] 원본 방식의 시간 복잡도를 줄이려면 어떤 자료구조를 쓸지 설명한다.
