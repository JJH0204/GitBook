# 프로그래머스: 가장 많이 받은 선물

## Code Block

```cpp
#include <string>
#include <vector>

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
    
    return answer;
}
```

## Problem Description (한글)

선물을 직접 전하기 힘들 때 카카오톡 선물하기 기능을 이용해 축하 선물을 보낼 수 있습니다.\
당신의 친구들이 이번 달까지 선물을 주고받은 기록을 바탕으로 다음 달에 누가 선물을 많이 받을지 예측하려고 합니다.

* 두 사람이 선물을 주고받은 기록이 있다면, 이번 달까지 두 사람 사이에 더 많은 선물을 준 사람이 다음 달에 선물을 하나 받습니다.\
  예: A가 B에게 선물을 5번 줬고, B가 A에게 선물을 3번 줬다면 다음 달엔 A가 B에게 선물을 하나 받습니다.
* 두 사람이 선물을 주고받은 기록이 하나도 없거나 주고받은 수가 같다면, 선물 지수가 더 큰 사람이 선물 지수가 더 작은 사람에게 선물을 하나 받습니다.
  * 선물 지수는 이번 달까지 자신이 친구들에게 준 선물의 수에서 받은 선물의 수를 뺀 값입니다.
  * 예: A가 준 선물 3개, 받은 선물 10개 → A의 선물 지수 = -7. B가 준 선물 3개, 받은 선물 2개 → B의 선물 지수 = 1.\
    A와 B가 선물을 주고받은 적이 없거나 같은 수로 주고받았다면 다음 달엔 B가 A에게 선물을 하나 받습니다.
  * 만약 두 사람의 선물 지수도 같다면 다음 달에 선물을 주고받지 않습니다.

위 규칙대로 다음 달에 선물을 주고받을 때, 가장 많은 선물을 받을 친구가 받을 선물의 수를 구하는 문제입니다.

입력:

* friends: 친구들의 이름을 담은 문자열 배열
* gifts: 이번 달까지 친구들이 주고받은 선물 기록을 담은 문자열 배열 (각 원소는 "giver receiver" 형태)

출력:

* 다음 달에 가장 많은 선물을 받는 친구가 받을 선물의 수를 return

## 풀이 아이디어 / 과정

{% stepper %}
{% step %}
### 입력 처리 및 초기화

* 사용자의 입력을 받는다.
* 기본 골격:

```cpp
#include <string>
#include <vector>

using namespace std;

int solution(vector<string> friends, vector<string> gifts) {
    int answer = 0;
    return answer;
}
```
{% endstep %}

{% step %}
### 2차원 행렬(선물 지표) 생성

* friends 값을 이용해 n x n 2차원 행렬을 생성한다. (n = friends.size())
* 행렬은 선물을 주고받은 정보를 관리하는 giftIndicator로 사용한다.

예: friends = \["muzi", "ryan", "frodo", "neo"]

인덱스: 0 1 2 3 (이름에 대한 인덱스 매핑을 상정)

기본 형태 (초기 상태)

```
    0  1  2  3
0   0  0  0  0
1   0  0  0  0
2   0  0  0  0
3   0  0  0  0
```
{% endstep %}

{% step %}
### 행렬 초기화 및 선물 지수 행렬 준비

* 행렬을 모두 0으로 초기화 한다.
* 동일한 크기의 행렬을 하나 더 준비한다. 이 행렬은 선물 지수(giftIndex)를 표현하기 위한 1차원 배열로도 사용한다(1차원으로 축소 가능).

예시 초기화 결과:

```
    0  1  2  3
0   0  0  0  0
1   0  0  0  0
2   0  0  0  0
3   0  0  0  0
```

(위 행렬을 giftIndicator로 사용)
{% endstep %}

{% step %}
### gifts로 행렬 업데이트

* gifts 배열의 각 원소(예: "muzi frodo")를 파싱하여 giftIndicator\[giverIndex]\[receiverIndex]를 증가시킨다.

예:

```
gifts = ["muzi frodo", "muzi frodo", "ryan muzi", "ryan muzi", "ryan muzi",
         "frodo muzi", "frodo ryan", "neo muzi"]
friends = ["muzi", "ryan", "frodo", "neo"]
```

업데이트된 giftIndicator 예시:

```
    0  1  2  3
0   0  0  2  0
1   3  0  0  0
2   1  1  0  0
3   1  0  0  0
```

* giftIndex(선물 지수) 계산 예제:

```
giftIndex = [-3, 2, 0, 1]
```

(각 인덱스는 해당 친구가 준 선물 수 합 - 받은 선물 수 합)
{% endstep %}

{% step %}
### 다음 달 예측: 각 친구가 몇 명에게 선물을 받을지 계산

* 모든 친구 i에 대해 다른 모든 친구 j와 비교:
  * i == j 면 건너뜀
  * dump = giftIndicator\[i]\[j] - giftIndicator\[j]\[i]
    * dump > 0 이면 i가 더 많이 줬으므로 i가 j에게서 선물 하나 받음 → i의 수 증가
    * dump < 0 이면 j가 i에게서 선물 하나 받음 → 해당 케이스에서는 상대가 받게 되므로 i 증가 X
    * dump == 0 이면 giftIndex 비교:
      * giftIndex\[i] > giftIndex\[j] 이면 i가 j에게 선물 하나 받음 → i 증가
      * giftIndex\[i] <= giftIndex\[j] 이면 증가 없음 (동일하면 주고받지 않음)
* 각 i에 대해 세어본 값을 result라 하고, 모든 i에서 최대값을 answer로 설정한다.

관련 코드 조각(루프):

```cpp
int result = 0;
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
    answer = answer >= result ? answer : result;
}
```

주의: find 메서드는 algorithm 헤더파일을 포함해야 사용 가능하다.
{% endstep %}
{% endstepper %}

선물을 직접 전하기 힘들 때 카카오톡 선물하기 기능을 이용해 축하 선물을 보낼 수 있습니다. 당신의 친구들이 이번 달까지 선물을 주고받은 기록을 바탕으로 다음 달에 누가 선물을 많이 받을지 예측하려고 합니다.

* 두 사람이 선물을 주고받은 기록이 있다면, 이번 달까지 두 사람 사이에 더 많은 선물을 준 사람이 다음 달에 선물을 하나 받습니다. ㄴ 예를 들어 A가 B에게 선물을 5번 줬고, B가 A에게 선물을 3번 줬다면 다음 달엔 A가 B에게 선물을 하나 받습니다.
* 두 사람이 선물을 주고받은 기록이 하나도 없거나 주고받은 수가 같다면, 선물 지수가 더 큰 사람이 선물 지수가 더 작은 사람에게 선물을 하나 받습니다. ㄴ 선물 지수는 이번 달까지 자신이 친구들에게 준 선물의 수에서 받은 선물의 수를 뺀 값입니다. ㄴ 예를 들어 A가 친구들에게 준 선물이 3개고 받은 선물이 10개라면 A의 선물 지수는 -7입니다. B가 친구들에게 준 선물이 3개고 받은 선물이 2개라면 B의 선물 지수는 1입니다. 만약 A와 B가 선물을 주고받은 적이 없거나 정확히 같은 수로 선물을 주고받았다면, 다음 달엔 B가 A에게 선물을 하나 받습니다. ㄴ 만약 두 사람의 선물 지수도 같다면 다음 달에 선물을 주고받지 않습니다.

위에서 설명한 규칙대로 다음 달에 선물을 주고받을 때, 당신은 선물을 가장 많이 받을 친구가 받을 선물의 수를 알고 싶습니다.

친구들의 이름을 담은 1차원 문자열 배열 friends 이번 달까지 친구들이 주고받은 선물 기록을 담은 1차원 문자열 배열 gifts가 매개변수로 주어집니다. 이때, 다음달에 가장 많은 선물을 받는 친구가 받을 선물의 수를 return 하도록 solution 함수를 완성해 주세요.

입력 예

2차원 행렬 그래프로 풀면 되지 않을까?

1. 사용자의 입력을 받는다. ()

\#include #include

using namespace std;

int solution(vector friends, vector gifts) { int answer = 0; return answer; }

2. 받은 입력 값 중 friends 값을 이용해 2차원 행렬을 생성한다.

\["muzi", "ryan", "frodo", "neo"]

0 1 2 3

```
    0        1        2        3
```

0\
1\
2\
3

2.1. 행렬을 모두 0으로 초기화 한다.

```
    0        1        2        3
```

0 0 0 0 0 1 0 0 0 0 2 0 0 0 0 3 0 0 0 0

2.2. 2.1번에 초기화 한 2차원 행렬을 복제한다. > 이 행렬은 선물 지수를 표현한다.

이 행렬은 선물을 주고받은 정보를 관리하는 2차원 배열로 사용한다.

3. 2.1번 행렬(이하 선물지표)를 gifts를 이용해 갱신(Update)한다.

\["muzi frodo", "muzi frodo", "ryan muzi", "ryan muzi", "ryan muzi", "frodo muzi", "frodo ryan", "neo muzi"]

\["muzi", "ryan", "frodo", "neo"]

0 1 2 3

```
    0        1        2        3
```

0 0 0 2 0 1 3 0 0 0 2 1 1 0 0 3 1 0 0 0

0 1 2 3 -3 2 0 1

giftIndex

giftIndicator

int result = 0; for (int i = 0; i < size; i++) {

result = 0; for (int j = 0; j < size; j++) {

if (dump > 0 ) {

result ++;

int dump = giftIndicator\[i]\[j] - giftIndicator\[j]\[i];

} else if (dump == 0) {

result += (giftIndex\[i] > giftIndex\[j])? 1 : 0;

}

if (i == j) continue;

} answer = answer >= result ? answer : result;

}

(주의)find 메서드는 algorithm 헤더파일을 포함해야 사용가능하다.

### 참고 링크

bZV5QIrk: 가장많이받은선물#Code Block
