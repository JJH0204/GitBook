# 프로그래머스: 개인정보 수집 유효기간

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PPR-003-DO |
| 유형 | D&O (접근·복잡도) + 예제 코드 |
| 목적 | 개인정보 수집일에 약관별 보관 개월 수를 더해 오늘 파기할 항목 번호를 구하는 문제의 풀이를 정리한다 |
| 언어 | C++ (2번째 코드는 C++17) |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 문제 개요

오늘 날짜(`today`), 약관별 보관 개월 수(`terms`), 수집 날짜와 약관 종류의 쌍(`privacies`)이 문자열로 주어진다. 수집 날짜에 보관 개월 수를 더한 날부터 파기 대상이며, 파기 대상 항목의 번호(1부터)를 오름차순으로 반환한다. 문제는 모든 달을 28일로 가정한다. 입력 형식과 예시는 프로그래머스 문제 페이지에서 확인한다.

## 2. 동작 원리

### 2-1. 핵심 판단

수집일 + 보관 개월 수 = 만료일이다. 만료일 당일부터 파기 대상이다. 즉 보관 가능한 마지막 날은 만료일 전날이다. 따라서 `만료일 <= 오늘`이면 파기한다.

| 비교 | 결과 |
|---|---|
| `만료일 < 오늘` | 틀림. 만료일 당일이 빠진다 |
| `만료일 <= 오늘` | 맞음 |

원본 메모는 처음에 `<`로 비교해 일부 테스트가 실패했고 `<=`로 고쳤다.

### 2-2. 월 덧셈

모든 달이 28일이라 일(day)은 바꾸지 않고 연·월만 계산한다.

```
총월     = 월 + 개월수
연      += (총월 - 1) / 12
월       = (총월 - 1) % 12 + 1
```

`- 1`과 `+ 1`은 월이 1부터 12까지이기 때문이다. 12월에 1개월을 더하면 `(13 - 1) / 12 = 1`, `(13 - 1) % 12 + 1 = 1`로 다음 해 1월이 된다.

### 2-3. 날짜 비교

`YYYYMMDD`를 `연 * 10000 + 월 * 100 + 일` 정수로 바꾸면 정수 비교가 날짜 비교와 같다.

### 2-4. 단계

1. `terms`를 공백으로 나눠 약관 종류와 개월 수를 저장한다.
2. `privacies` 각 항목을 공백으로 나눠 수집일과 약관 종류를 얻는다.
3. 약관 종류로 개월 수를 찾아 만료일을 계산한다.
4. 만료일 정수와 오늘 정수를 `<=`로 비교해 항목 번호(`i + 1`)를 저장한다.

## 3. 복잡도

| 항목 | 값 | 이유 |
|---|---|---|
| 시간 | O(P × T) | 개인정보 P개마다 약관 T개를 선형 탐색한다. 약관을 `map`에 넣으면 O(P log T)가 된다 |
| 공간 | O(T + P) | 약관 목록과 결과 배열 |

## 4. 예제 코드

### 4-1. 기본 풀이

```cpp
#include <string>
#include <vector>

using namespace std;

int toDateInt(string date) {
    return stoi(date.substr(0, 4)) * 10000 +
           stoi(date.substr(5, 2)) * 100 +
           stoi(date.substr(8, 2));
}

vector<int> solution(string today, vector<string> terms, vector<string> privacies) {
    vector<int> answer;
    vector<string> _termType;   // 약관 종류
    vector<int> _termValue;     // 약관에 명시된 개월수

    for (int i = 0; i < terms.size(); i++)
    {
        size_t pos = terms[i].find(' ');
        _termType.push_back(terms[i].substr(0, pos));
        _termValue.push_back(stoi(terms[i].substr(pos + 1)));
    }

    for (int i = 0; i < privacies.size(); i++)
    {
        vector<string> _privacie;
        size_t pos = privacies[i].find(' ');
        _privacie.push_back(privacies[i].substr(0, pos));     // 약관 동의 날짜
        _privacie.push_back(privacies[i].substr(pos + 1));    // 약관 타입

        int termValue = 0;
        for (int x = 0; x < _termType.size(); x++)
        {
            if (_termType[x] == _privacie[1])
                termValue = _termValue[x];
        }

        int privacieYear = stoi(_privacie[0].substr(0, 4));
        int privacieMonth = stoi(_privacie[0].substr(5, 2));
        int privacieDate = stoi(_privacie[0].substr(8));

        privacieYear += (privacieMonth + termValue - 1) / 12;
        privacieMonth = (privacieMonth + termValue - 1) % 12 + 1;

        int newDate = privacieYear * 10000 + privacieMonth * 100 + privacieDate;

        if (newDate <= toDateInt(today))
            answer.push_back(i + 1);
    }

    return answer;
}
```

### 4-2. 분리 함수 단계

날짜와 문자열을 구분자로 나누는 함수다. `stringstream`을 쓰므로 `<sstream>`이 필요하다.

```cpp
vector<int> splitDate(const string& str, char delimiter)
{
    vector<int> result;
    stringstream ss(str);
    string token;

    while (getline(ss, token, delimiter))
    {
        if (!token.empty())
            result.push_back(stoi(token));
    }
    return result;
}

vector<string> splitString(const string& str, char delimiter)
{
    vector<string> result;
    stringstream ss(str);
    string token;

    while (getline(ss, token, delimiter))
    {
        if (!token.empty())
            result.push_back(token);
    }
    return result;
}
```

두 함수는 반환 타입만 다르므로 템플릿 하나로 합칠 수 있다. 아래 4-3절 코드의 `split<T>`가 그 형태다.

### 4-3. 템플릿 분리 함수를 쓴 풀이

`if constexpr`는 C++17부터 쓸 수 있고 `is_same`은 `<type_traits>`에 있다.

```cpp
#include <string>
#include <vector>
#include <sstream>
#include <type_traits>

using namespace std;

template <typename T>
vector<T> split(const string& str, char delimiter) {
    vector<T> result;
    stringstream ss(str);
    string token;

    while (getline(ss, token, delimiter)) {
        if (!token.empty()) {
            if constexpr (is_same<T, string>::value) {
                result.push_back(token);
            } else if constexpr (is_same<T, int>::value) {
                result.push_back(stoi(token));
            } else if constexpr (is_same<T, double>::value) {
                result.push_back(stod(token));
            }
        }
    }

    return result;
}

int toDateInt(const string& date) {
    return stoi(date.substr(0, 4)) * 10000 +
           stoi(date.substr(5, 2)) * 100 +
           stoi(date.substr(8, 2));
}

vector<int> solution(string today, vector<string> terms, vector<string> privacies) {
    vector<int> answer;
    vector<int> _today = split<int>(today, '.');

    // parse terms
    vector<pair<string,int>> parsedTerms;
    for (const auto& t : terms) {
        auto parts = split<string>(t, ' ');
        parsedTerms.push_back({parts[0], stoi(parts[1])});
    }

    for (int i = 0; i < privacies.size(); ++i) {
        auto parts = split<string>(privacies[i], ' ');
        auto date = split<int>(parts[0], '.');
        string termType = parts[1];
        int monthsToAdd = 0;

        for (const auto& pt : parsedTerms) {
            if (pt.first == termType) {
                monthsToAdd = pt.second;
                break;
            }
        }
        if (monthsToAdd == 0) continue;

        int total_month = date[1] + monthsToAdd;
        date[0] += (total_month - 1) / 12;
        date[1] = (total_month - 1) % 12 + 1;

        int newDate = date[0] * 10000 + date[1] * 100 + date[2];
        int todayInt = _today[0] * 10000 + _today[1] * 100 + _today[2];

        if (newDate <= todayInt) answer.push_back(i + 1);
    }

    return answer;
}
```

## 5. 코드 설명

| 위치 | 설명 |
|---|---|
| `toDateInt` | `"YYYY.MM.DD"`의 고정 위치(0~3, 5~6, 8~9)를 잘라 정수로 합친다 |
| 약관 파싱 | 공백 위치를 `find`로 찾아 종류와 개월 수로 나눈다 |
| 월 덧셈 | 2-2절의 식. 일(day)은 그대로 둔다 |
| 비교 | `newDate <= toDateInt(today)`이면 번호 `i + 1`을 결과에 넣는다. 번호가 1부터이므로 `i + 1`이다 |
| `split<T>` | 구분자(`char`)로 나눠 `T`로 변환한다. 구분자는 문자(`'.'`)이며 문자열(`"."`)이 아니다 |

## 6. 한계·주의

* 4-3절 코드에서 `<type_traits>`를 추가했다. 원본은 포함하지 않았고 일부 표준 라이브러리 구현에서는 다른 헤더를 통해 우연히 들어오기도 하지만 보장되지 않는다.
* 원본 요약은 `split(today, ".")`라고 적었다. 구분자는 `char`이므로 `split<int>(today, '.')`가 맞다.
* 4-3절의 `monthsToAdd == 0` 검사는 약관에 없는 종류를 건너뛴다. 4-1절 코드는 약관을 못 찾으면 개월 수 0으로 두어 오늘 이전 수집분을 파기 대상으로 판단한다. 정상 입력에서는 약관이 항상 존재한다.
* 날짜 형식이 `YYYY.MM.DD` 고정 폭이라는 가정에 의존한다.
* 모든 달이 28일이라는 조건이 없으면 일 덧셈과 말일 처리가 필요하다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 만료일 당일을 파기 대상에 넣는 이유와 비교 연산자를 `<=`로 쓴 이유를 적는다.
- [ ] 월 덧셈 식에서 `- 1`과 `+ 1`이 필요한 이유를 12월 + 1개월 예로 설명한다.
