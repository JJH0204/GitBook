# 프로그래머스: 성격 유형 검사하기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PPR-002-DO |
| 유형 | D&O (접근·복잡도) + 예제 코드 |
| 목적 | 설문 응답을 네 지표(R/T, C/F, J/M, A/N)의 점수로 누적해 성격 유형 문자열을 만드는 문제의 풀이를 정리한다 |
| 언어 | C++ |
| 확인 상태 | 미검증 (원본의 조각 코드를 읽고 하나로 조립·정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 문제 개요

설문 항목마다 두 글자 문자열(예: `"RT"`)과 1~7 선택지가 주어진다. 선택지가 4보다 작으면 앞 글자에, 4보다 크면 뒤 글자에 점수를 준다. 4는 점수가 없다. 네 지표에서 점수가 높은 글자를 이어 붙인 4글자 문자열을 구하고, 점수가 같으면 사전 순으로 앞선 글자를 고른다. 입력 범위와 점수표는 프로그래머스 문제 페이지에서 확인한다.

## 2. 동작 원리

### 2-1. 자료 구조

지표 네 쌍을 유형 이름과 점수를 가진 구조체의 2차원 배열로 둔다. 쌍의 순서는 각 쌍의 첫 글자가 사전 순으로 앞서도록 `R,T` / `C,F` / `J,M` / `A,N`으로 둔다. 이 순서 덕분에 동점일 때 첫 글자를 고르면 사전 순 규칙을 만족한다.

```
indicator[0] = { {R,0}, {T,0} }
indicator[1] = { {C,0}, {F,0} }
indicator[2] = { {J,0}, {M,0} }
indicator[3] = { {A,0}, {N,0} }
```

### 2-2. 점수 계산

| 선택지 `choices[i]` | 점수를 받는 글자 | 점수 |
|---|---|---|
| 1, 2, 3 | `survey[i]`의 앞 글자 | `4 - choices[i]` |
| 4 | 없음 | 0 |
| 5, 6, 7 | `survey[i]`의 뒤 글자 | `choices[i] - 4` |

### 2-3. 단계

1. 4×2 구조체 배열을 0점으로 만든다.
2. 설문 항목마다 점수를 받을 글자와 점수를 구한다. 선택지가 4이면 건너뛴다.
3. 배열을 돌며 그 글자를 찾아 점수를 더한다.
4. 네 쌍마다 앞 글자 점수가 뒤 글자 점수 이상이면 앞 글자를, 아니면 뒤 글자를 결과에 붙인다.

## 3. 복잡도

| 항목 | 값 | 이유 |
|---|---|---|
| 시간 | O(n) | 설문 n개마다 8칸(상수)을 탐색한다 |
| 공간 | O(1) | 지표 8칸 고정 |

## 4. 예제 코드

원본은 조각으로 흩어져 있었고 그대로는 컴파일되지 않는다. 아래는 원본 접근(구조체 배열 + 탐색)을 유지해 조립하고 정정한 코드다.

```cpp
#include <string>
#include <vector>

using namespace std;

struct Indic
{
    string _type;
    int _value;
};

string solution(vector<string> survey, vector<int> choices) {
    vector<vector<Indic>> indicator = {
        {{"R", 0}, {"T", 0}},
        {{"C", 0}, {"F", 0}},
        {{"J", 0}, {"M", 0}},
        {{"A", 0}, {"N", 0}}
    };

    for (int i = 0; i < (int)survey.size(); i++)
    {
        int v = 0;
        string findSurvey;

        if ( choices[i] < 4 )
        {
            v = 4 - choices[i];
            findSurvey = survey[i].substr(0, 1);
        }
        else if ( choices[i] > 4 )
        {
            v = choices[i] - 4;
            findSurvey = survey[i].substr(1, 1);
        }
        else
            continue;

        bool isFind = false;
        for ( int y = 0; y < (int)indicator.size() && !isFind; y++)
        {
            for ( int x = 0; x < (int)indicator[y].size() && !isFind; x++)
            {
                if ( findSurvey == indicator[y][x]._type)
                {
                    indicator[y][x]._value += v;
                    isFind = true;
                }
            }
        }
    }

    string answer;
    for (int y = 0; y < (int)indicator.size(); y++)
    {
        if (indicator[y][0]._value >= indicator[y][1]._value)
            answer += indicator[y][0]._type;
        else
            answer += indicator[y][1]._type;
    }
    return answer;
}
```

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| `struct Indic` | 유형 이름 `_type`과 누적 점수 `_value`를 묶는다 |
| `indicator` 초기값 | 문자열 리터럴(`"R"`)로 채운다 |
| `choices[i] < 4` 분기 | 앞 글자(`substr(0, 1)`)에 `4 - choices[i]`점을 준다 |
| `choices[i] > 4` 분기 | 뒤 글자(`substr(1, 1)`)에 `choices[i] - 4`점을 준다 |
| 탐색 이중 반복 | 받을 글자와 같은 `_type`을 찾아 점수를 더하고 두 반복을 모두 끝낸다 |
| 마지막 반복 | `>=`로 비교해 동점이면 앞 글자를 고른다 |

## 6. 한계·주의

원본 조각에서 정정한 내용은 다음과 같다.

| 원본 | 문제 | 정정 |
|---|---|---|
| `typedef struct Indic { ... };` | 별칭 이름이 없는 `typedef`라 경고 또는 오류가 난다 | `struct Indic { ... };` |
| `{{R, 0}, {T, 0}}` | `R`, `T`는 선언되지 않은 식별자다 | `{"R", 0}`처럼 문자열 리터럴 |
| `findSurvey.push_back(denial)` (`string` 대 `string`) | `std::string::push_back`은 `char` 한 개를 받는다 | 대입(`findSurvey = survey[i].substr(...)`) |
| 점수 누적을 survey 반복문 밖에 둠 | 마지막 항목만 반영된다 | 누적 탐색을 survey 반복문 안으로 옮김 |
| 선택지 4 처리 없음 | `v`와 `findSurvey`가 이전 값이나 빈 값으로 남는다 | `continue`로 건너뜀 |
| 마지막 코드 블록 | 코드 펜스가 깨져 있었다 | 정상 코드 블록으로 복원 |

* 원본의 변수 이름 `denial`(비동의), `positive`(동의)는 선택지 값에 따라 점수를 받는 글자의 이름이었다. 이 문서에서는 사용하지 않는다.
* 글자 8개뿐이므로 `map<char, int>`로 더 짧게 쓸 수 있다. 원본 접근을 보존하려고 구조체 배열을 유지했다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 지표 쌍의 순서를 사전 순으로 두면 동점 규칙이 왜 `>=` 비교 하나로 끝나는지 적는다.
- [ ] 이 문제를 `map<char, int>`로 풀면 코드가 어떻게 달라질지 설명한다.
