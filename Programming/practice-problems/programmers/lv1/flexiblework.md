# 프로그래머스: 유연근무제

## Code Block

```cpp
#include <string>
#include <vector>

using namespace std;

int solution(vector<int> schedules, vector<vector<int>> timelogs, int startday) {
    int answer = 0;
    
    int hour = 0;
    int minute = 0;
    int limitTime = 0;

    bool isFail = false;

    for (int i = 0; i < schedules.size(); i++)
    {
        isFail = false;
        
        hour = schedules[i] / 100;
        minute = schedules[i] % 100 + 10;
        if (minute >= 60)
        {
            hour += 1;
            minute -= 60;
        }
        limitTime = hour * 100 + minute;

        for (int j = 0; j < 7 && !isFail; j++)
        {
            int day = (j + startday - 1) % 7;  // 0~6
            if (day == 5 || day == 6) continue;  // 5: 토, 6: 일
            
            if ( limitTime < timelogs[i][j] )  // 지각인지 점검
                isFail = true;
        }

        if (!isFail)
            answer++;
    }

    return answer;
}
```

프로그래머스 사이트를 운영하는 그렙에서는 재택근무와 함께 출근 희망 시각을 자유롭게 정하는 유연근무제를 시행하고 있습니다. 제도 정착을 위해 오늘부터 일주일 동안 각자 설정한 출근 희망 시각에 늦지 않고 출근한 직원들에게 상품을 주는 이벤트를 진행하려고 합니다.

직원들은 일주일동안 자신이 설정한 출근 희망 시각 + 10분까지 어플로 출근해야 합니다. 예를 들어 출근 희망 시각이 9시 58분인 직원은 10시 8분까지 출근해야 합니다. 단, 토요일, 일요일의 출근 시각은 이벤트에 영향을 끼치지 않습니다. 직원들은 매일 한 번씩만 어플로 출근하고, 모든 시각은 시에 100을 곱하고 분을 더한 정수로 표현됩니다. 예를 들어 10시 13분은 1013이 되고 9시 58분은 958이 됩니다.

당신은 직원들이 설정한 출근 희망 시각과 실제로 출근한 기록을 바탕으로 상품을 받을 직원이 몇 명인지 알고 싶습니다.

직원 n명이 설정한 출근 희망 시각을 담은 1차원 정수 배열 schedules, 직원들이 일주일 동안 출근한 시각을 담은 2차원 정수 배열 timelogs, 이벤트를 시작한 요일을 의미하는 정수 startday가 매개변수로 주어집니다. 이때 상품을 받을 직원의 수를 return 하도록 solution 함수를 완성해주세요.

schedules : 직원 n명이 설정한 출근 희망 시간 timelogs : 직원들이 실제 1주 동안 출근한 시각 startday : 이벤트 시작 요일 (월 \~ 일)

1주 동안 설정한 시각에 늦지 않고 출근한 직원의 수?

지각: 출근 시간 + 10 분을 초과

단, 주말(토,일)의 출근 시각은 이벤트에 반영 x

int solution(vector schedules, vector\<vector> timelogs, int startday) {

\#include

\#include

using namespace std;

int answer = 0;

return answer;

}

// Code's

직원의 출근 기한 = schedules\[i] + 10; for ( int j = 0; j < timelogs\[i].size(); j++) {

for (int i = 0; i < schedules.size(); i ++) {

if ( (j + startday) % 6 == 0 || (j + startday) % 7 == 0 ) continue;

직원의 실제 출근시간 = timelogs\[i]\[j];

if ( 직원의 출근 기한 < 직원의 실제 출근시간 ) { isFail = true; break; }

}

bool isFail = false; // 실패여부

if (!isFail) answer++;

}

시간의 성질을 반영한 덧셈을 구현해야 한다.

9시 50분에 출근하기로한 직원은

+10 > 즉, 10시 까지 출근해야 한다.

950 + 10

960

1000

10의 자리 수가 6이되면 60을 빼고 100을 더한다.

schedules\[i] + 10 = 960 = dump

dump % 100 = 60 = x

if ( x >= 60 ) dump - 60 + 100 ;

dump + 40

schedules\[i] + 10 + 40;

schedules\[i] + 50;

직원의 출근 기한 = (schedules\[i] + 10) % 100 >= 60 ? schedules\[i] + 50 : schedules\[i] + 10;

일부 테스트는 통과하지 못했는데 이유가 뭘까? 어떤 입력 값을 처리하지 못한 것인지 경우의 수를 다시 고려해야 겠다.

startday = 2: 화요일

0 1 2 3 4 5 6

2 3 4 5 6 7 8

2 3 4 5 0 1 2

6으로 나눔

2 3 4 5 6 0 1

7으로 나눔

j =

### 참고 링크

KXxlAGPx: 2025/Programmers/LV1/유연근무제.md#Code Block
