# TakeOutParcelBox

## Code Block

{% code title="solution.cpp" %}
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
{% endcode %}

***

## Excalidraw Data

### Text Elements (original Korean content)

1. n의 번호가 있는 택배 상자가 창고에 있습니다. 당신은 택배 상자들을 다음과 같이 정리했습니다.

왼쪽에서 오른쪽으로 가면서 1번 상자부터 번호 순서대로 택배 상자를 한 개씩 놓습니다. 가로로 택배 상자를 w개 놓았다면 이번에는 오른쪽에서 왼쪽으로 가면서 그 위층에 택배 상자를 한 개씩 놓습니다. 그 층에 상자를 w개 놓아 가장 왼쪽으로 돌아왔다면 또다시 왼쪽에서 오른쪽으로 가면서 그 위층에 상자를 놓습니다. 이러한 방식으로 n개의 택배 상자를 모두 놓을 때까지 한 층에 w개씩 상자를 쌓습니다.

다음 날 손님은 자신의 택배를 찾으러 창고에 왔습니다. 당신은 손님이 자신의 택배 상자 번호를 말하면 해당 택배 상자를 꺼내줍니다. 택배 상자 A를 꺼내려면 먼저 A 위에 있는 다른 모든 상자를 꺼내야 A를 꺼낼 수 있습니다. 예를 들어, 위 그림에서 8번 상자를 꺼내려면 먼저 20번, 17번 상자를 꺼내야 합니다.

당신은 꺼내려는 상자 번호가 주어졌을 때, 꺼내려는 상자를 포함해 총 몇 개의 택배 상자를 꺼내야 하는지 알고 싶습니다.

창고에 있는 택배 상자의 개수를 나타내는 정수 n, 가로로 놓는 상자의 개수를 나타내는 정수 w와 꺼내려는 택배 상자의 번호를 나타내는 정수 num이 매개변수로 주어집니다. 이때, 꺼내야 하는 상자의 총개수를 return 하도록 solution 함수를 완성해 주세요.

위 그림은 w = 6일 때 택배 상자 22개를 쌓은 예시입니다.

n = 22 (전체 상자 개수)\
w = 6 (가로 길이)\
num = 8 (찾는 상자)\
answer = 3 (찾는 상자 포함 꺼내는 개수)

아이디어 1: 스택 자료형을 사용하면 쉽게 풀릴 것 같다.\
아이디어 2: 단순 꺼내야할 상자 개수를 반환하는 거라면 수식으로만 해결하는 것도 좋을 것 같다.

w 만큼의 stack 자료형의 배열을 선언한다.\
vector\<stack> truck;\
이름을 트럭이라 지었다.

(아래는 제작 과정에서 사용한 코드 조각 및 설명 일부 — 원문 그대로 유지)

\#include #include #include #include

using namespace std;

int solution(int n, int w, int num) { int answer = 0; return answer; }

int box = 1 , index = 0; bool pivot = false;

while (box <= n) { truck\[index].push(box); if (pivot) index--; else index++; box++; }

if (index >= w) { pivot = true; index--; } else if (index < 0 ) { pivot = flase; index++; }

사용자가 찾는 물건이 몇번째에 있는지 검사한다.

num = 8

(중간 생략된 행들 — 원문 그대로 유지, 위치 계산과 예제들)

num / w 의 값이 0 또는 2의 배수인 경우 짝수 칸, 홀수 층 등 조건 설명이 이어짐.

(float) num / (float) w = 8.0 / 6.0 = 1.33333333

x = fmod((float)num/(float)w, 2.0f) if (0.0f < x && x <= 1.0f) 짝수 층 else 홀수 층

int index float dump = fmod ( (float) num / (float) w, 2.0f )

if ( 0.0f < dump && dump <= 1.0f ) { index = num % w - 1; } else { index = w - (num % w) }

몇번째에 저장되었는지 알게 되었으니 이제 직접 꺼내면서 값을 확인하면 되겠다.

int boxCount = 0; int boxValue = 0;

do { if (truck\[index].empty()) return 0; boxValue = truck\[index].top(); truck\[index].pop(); boxCount++; } while(boxValue != num)

return boxCount;

(문제 해결 중 발생한 오류 로그 및 추가 메모 일부 — 원문 그대로 유지) signal: illegal instruction (core dumped)

참조할 인덱스를 결정하는 과정에서 잘못된 참조가 일어나는 것 같다.

(추가 테스트와 수식 기반 접근 제안)

\#include #include

using namespace std;

int solution(int n, int w, int num) { int answer = 0; while(num<=n) { answer++; num+=(w-1-(w+num-1)%w)\*2+1; } return answer; }

num % w == 0 일때 w - 1 은 잘못된 처리 > 0으로 만들어서 인덱스 처음을 참조하도록 한다.

***

### 아이디어 요약 (스텝 형식)

{% stepper %}
{% step %}
### 아이디어 1

스택 자료형을 사용하여 각 가로 칸을 stack으로 표현하고 실제로 상자를 쌓아 시뮬레이션한 뒤, 찾는 상자 위치 칸에서 위쪽부터 꺼내며 카운트한다.
{% endstep %}

{% step %}
### 아이디어 2

수식으로만 해결: 찾는 상자 num이 어느 칸(열)에 쌓여있는지를 계산한 뒤, 그 칸에서 num이 나올 때까지 꺼내는 개수를 수식으로 계산한다.
{% endstep %}
{% endstepper %}

***

### 예시 스택 배치 (원문에 있던 배열 스냅샷 텍스트 일부 — 그대로 유지)

truck 0 1 2 3 4 5

(이하 각 칸에 쌓인 상자 번호 순서가 원문에 나열되어 있음 — 원문 그대로 유지)

***

### Element Links

* 9uQ6dz0M: [택배상자꺼내기#Code Block](/broken/pages/3c7d9b099de1aa3727c147e52a31836da5313b41)

***

### Embedded Files / Images

(원문에 포함된 이미지 파일 참조들 — 파일명 및 경로는 변경하지 않음)

* 88984b65f8e298fcf9cbe224ddeae8426899a116: \[\[topics/assets/images/스크린샷 2025-06-05 오전 10.16.54.png]]
* bef3ffde815edf5e6da2637f2c9f49af8bedc249: \[\[topics/assets/images/스크린샷 2025-06-05 오후 12.41.06.png]]
* 7f28d6fd89978e181ea18c3b11d81a5bf62a7b84: \[\[topics/assets/images/스크린샷 2025-06-05 오후 12.41.18.png]]
* 341466066c24c5114eabdcf24ceed178fae81a15: \[\[topics/assets/images/스크린샷 2025-06-05 오후 12.41.33.png]]

***

### Drawing (compressed JSON)

(원문 그대로 유지 — 압축된 Excalidraw 데이터)

```compressed-json
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

(이하 원문 압축 데이터 계속)
```
