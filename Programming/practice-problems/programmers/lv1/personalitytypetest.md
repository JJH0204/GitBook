# 프로그래머스: 성격 유형 검사하기

지표값을 저장할 2차원 배열을 만들자

C++ (vector declaration)

{% code title="indicator-declaration.cpp" %}
```
```
{% endcode %}

```cpp
vector<vector<int>> indicator;
```

(예시 값) 0 1 0 1 2 3

int type으로 만들지 말고 유형과 값을 저장할 구조체로 만들어서 관리하자

C struct example

{% code title="Indic-struct.cpp" %}
```
```
{% endcode %}

```cpp
typedef struct Indic
{
    string _type;
    int _value;
};
```

2차원 배열 예시 (구조체 활용)

{% code title="indicator-struct-init.cpp" %}
```
```
{% endcode %}

```cpp
vector<vector<Indic>> indicator = {
    {{R, 0}, {T, 0}},
    {{C, 0}, {F, 0}},
    {{J, 0}, {M, 0}},
    {{A, 0}, {N, 0}}
};
```

choices 값이 4 미만인 경우\
초과인 경우

계산 예시

{% code title="choices-calculation.cpp" %}
```
```
{% endcode %}

```cpp
int v = 4 - choices[i];   // when choices[i] < 4
int v = choices[i] - 4;   // when choices[i] > 4
```

survey 처리 루프 예시

{% code title="survey-loop.cpp" %}
```
```
{% endcode %}

```cpp
for (int i = 0; i < survey.size() ; i++ )
{
    // survey 분리
    string denial = survey[i].substr(0,1);
    string positive = survey[i].substr(1,1);

    if ( choices[i] < 4 )
    {
        v = 4 - choices[i];
        findSurvey.push_back(denial);
    }
    else if ( choices[i] > 4 )
    {
        v = choices[i] - 4;
        findSurvey.push_back(positive);
    }
}
```

대입할 값과 지표를 선정

2차원 배열을 순회하면서 찾는 지표 값인지 확인

{% code title="find-and-accumulate.cpp" %}
```
```
{% endcode %}

```cpp
int v = 0;
string findSurvey;
bool isFind = false;

for ( int y = 0; y < indicator.size(); y++)
{
    for ( int x = 0; x < indicator[y].size(); x++)
    {
        if ( findSurvey == indicator[y][x]._type)
        {
            indicator[y][x]._value += v;
            isFind = true;
        }

        if (isFind)
            break;
    }
    if (isFind)
        break;
}
```

최종 판정 예시

{% code title="determine-answer.cpp" %}
```
```
{% endcode %}

\`\`\`cpp string answer;

for (int y = 0; y < indicator.size(); y++) { if (indicator\[y]\[0].\_value >= indicator\[y]\[1].\_value) answer += indicator\[y]\[0].\_type; else answer += indicator\[y]\[1].\_type; } return answer;


---
