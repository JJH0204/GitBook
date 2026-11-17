# 프로그래머스: 택배 상자 꺼내기

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

### 참고 링크

* 택배상자꺼내기#Code Block

***
