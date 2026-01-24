# MostReceivedGift

{% hint style="warning" %}
⚠ Switch to EXCALIDRAW VIEW in the MORE OPTIONS menu of this document. ⚠\
You can decompress Drawing data with the command palette: "Decompress current Excalidraw file". For more info check in plugin settings under "Saving".
{% endhint %}

## Code Block

```cpp
#include <string>
#include <vector>

using namespace std;

int solution(vector<string> friends, vector<string> gifts)
{
    int answer = 0;
    int size = friends.size()
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
    * dump > 0 이면 j가 i에게 선물 하나 받음 → i의 수 증가
    * dump < 0 이면 i가 j에게 선물 하나 받음 → 해당 케이스에서는 상대가 받게 되므로 i 증가 X
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

## Excalidraw Data

### Text Elements

선물을 직접 전하기 힘들 때 카카오톡 선물하기 기능을 이용해 축하 선물을 보낼 수 있습니다. 당신의 친구들이 이번 달까지 선물을 주고받은 기록을 바탕으로 다음 달에 누가 선물을 많이 받을지 예측하려고 합니다.

* 두 사람이 선물을 주고받은 기록이 있다면, 이번 달까지 두 사람 사이에 더 많은 선물을 준 사람이 다음 달에 선물을 하나 받습니다. ㄴ 예를 들어 A가 B에게 선물을 5번 줬고, B가 A에게 선물을 3번 줬다면 다음 달엔 A가 B에게 선물을 하나 받습니다.
* 두 사람이 선물을 주고받은 기록이 하나도 없거나 주고받은 수가 같다면, 선물 지수가 더 큰 사람이 선물 지수가 더 작은 사람에게 선물을 하나 받습니다. ㄴ 선물 지수는 이번 달까지 자신이 친구들에게 준 선물의 수에서 받은 선물의 수를 뺀 값입니다. ㄴ 예를 들어 A가 친구들에게 준 선물이 3개고 받은 선물이 10개라면 A의 선물 지수는 -7입니다. B가 친구들에게 준 선물이 3개고 받은 선물이 2개라면 B의 선물 지수는 1입니다. 만약 A와 B가 선물을 주고받은 적이 없거나 정확히 같은 수로 선물을 주고받았다면, 다음 달엔 B가 A에게 선물을 하나 받습니다. ㄴ 만약 두 사람의 선물 지수도 같다면 다음 달에 선물을 주고받지 않습니다.

위에서 설명한 규칙대로 다음 달에 선물을 주고받을 때, 당신은 선물을 가장 많이 받을 친구가 받을 선물의 수를 알고 싶습니다.

친구들의 이름을 담은 1차원 문자열 배열 friends 이번 달까지 친구들이 주고받은 선물 기록을 담은 1차원 문자열 배열 gifts가 매개변수로 주어집니다. 이때, 다음달에 가장 많은 선물을 받는 친구가 받을 선물의 수를 return 하도록 solution 함수를 완성해 주세요. ^4laWyp7Z

입력 예 ^c1ItL7hd

2차원 행렬 그래프로 풀면 되지 않을까? ^pvva0KYg

1. 사용자의 입력을 받는다. () ^s7fYvnTB

\#include #include

using namespace std;

int solution(vector friends, vector gifts) { int answer = 0; return answer; } ^w7OXlqBB

2. 받은 입력 값 중 friends 값을 이용해 2차원 행렬을 생성한다. ^eE2nuoyr

\["muzi", "ryan", "frodo", "neo"] ^ezvkCruB

0 1 2 3 ^021Gtnjp

```
    0        1        2        3
```

0\
1\
2\
3 ^PbkjJ32T

2.1. 행렬을 모두 0으로 초기화 한다. ^SlhyKJQS

```
    0        1        2        3
```

0 0 0 0 0 1 0 0 0 0 2 0 0 0 0 3 0 0 0 0 ^YoDCcfgR

2.2. 2.1번에 초기화 한 2차원 행렬을 복제한다. > 이 행렬은 선물 지수를 표현한다. ^Hwlw5I0b

이 행렬은 선물을 주고받은 정보를 관리하는 2차원 배열로 사용한다. ^Xx5xM5b8

3. 2.1번 행렬(이하 선물지표)를 gifts를 이용해 갱신(Update)한다.

^pkuQ16GE

\["muzi frodo", "muzi frodo", "ryan muzi", "ryan muzi", "ryan muzi", "frodo muzi", "frodo ryan", "neo muzi"] ^72STGzAr

\["muzi", "ryan", "frodo", "neo"] ^sEcrM2it

0 1 2 3 ^qEBQExa2

```
    0        1        2        3
```

0 0 0 2 0 1 3 0 0 0 2 1 1 0 0 3 1 0 0 0 ^tfHoPUqb

0 1 2 3 -3 2 0 1 ^n10yLGha

giftIndex ^655Q0pPP

giftIndicator ^6qkWIn6B

int result = 0; for (int i = 0; i < size; i++) { ^soPHZnwU

result = 0; for (int j = 0; j < size; j++) { ^5EBL1k5s

if (dump > 0 ) { ^vo9sO33A

result ++; ^N4RSzl7v

int dump = giftIndicator\[i]\[j] - giftIndicator\[j]\[i]; ^NeciLWqq

} else if (dump == 0) { ^QaS3TNPE

result += (giftIndex\[i] > giftIndex\[j])? 1 : 0; ^yUx2lUM2

} ^VGIm8eIV

if (i == j) continue; ^G9WDxGiT

} answer = answer >= result ? answer : result; ^aC7A03I6

} ^oVPcBNVj

(주의)find 메서드는 algorithm 헤더파일을 포함해야 사용가능하다. ^ZSw4eXuS

### Element Links

bZV5QIrk: [가장많이받은선물#Code Block](/broken/pages/d4060be7e5f7bed1f7c2685d5ceebe6634301b24)

### Embedded Files

0411b6f646b7bfd3ab6294f2ee0746e7025baee3: \[\[topics/assets/images/스크린샷 2025-06-04 오후 3.31.23.png]]

6f08a8609a1c8afeeb4c912608dca67f41e63903: \[\[topics/assets/images/스크린샷 2025-06-04 오후 3.36.20.png]]

%%

### Drawing

```compressed-json
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

... (compressed JSON continues)
```

(원본의 compressed JSON 블록은 변경하지 않았습니다.)
