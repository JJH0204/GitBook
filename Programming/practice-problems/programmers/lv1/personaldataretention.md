# PersonalDataRetention

## Code Block

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

## Excalidraw Data

### Text Elements

고객의 약관 동의를 얻어서 수집된 1\~n번으로 분류되는 개인정보 n개가 있습니다. 약관 종류는 여러 가지 있으며 각 약관마다 개인정보 보관 유효기간이 정해져 있습니다. 당신은 각 개인정보가 어떤 약관으로 수집됐는지 알고 있습니다. 수집된 개인정보는 유효기간 전까지만 보관 가능하며, 유효기간이 지났다면 반드시 파기해야 합니다. ^h2yM4wJ4

예를 들어, A라는 약관의 유효기간이 12 달이고, 2021년 1월 5일에 수집된 개인정보가 A약관으로 수집되었다면 해당 개인정보는 2022년 1월 4일까지 보관 가능하며 2022년 1월 5일부터 파기해야 할 개인정보입니다. ^4cJMtTLd

당신은 오늘 날짜로 파기해야 할 개인정보 번호들을 구하려 합니다. ^P756GnpC

모든 달은 28일까지 있다고 가정합니다. ^dIB2ApXm

다음은 오늘 날짜가 2022.05.19일 때의 예시입니다. ^5rFN9m3X

첫 번째 개인정보는 A약관에 의해 2021년 11월 1일까지 보관 가능하며, 유효기간이 지났으므로 파기해야 할 개인정보입니다. ^ol0QKhcm

두 번째 개인정보는 B약관에 의해 2022년 6월 28일까지 보관 가능하며, 유효기간이 지나지 않았으므로 아직 보관 가능합니다. ^Dw0QukFm

세 번째 개인정보는 C약관에 의해 2022년 5월 18일까지 보관 가능하며, 유효기간이 지났으므로 파기해야 할 개인정보입니다. ^tGMiQKG2

네 번째 개인정보는 C약관에 의해 2022년 5월 19일까지 보관 가능하며, 유효기간이 지나지 않았으므로 아직 보관 가능합니다. ^YD0n8wSt

따라서 파기해야 할 개인정보 번호는 \[1, 3]입니다. ^YOKklUxg

오늘 날짜를 의미하는 문자열 today, 약관의 유효기간을 담은 1차원 문자열 배열 terms와 수집된 개인정보의 정보를 담은 1차원 문자열 배열 privacies가 매개변수로 주어집니다. 이때 파기해야 할 개인정보의 번호를 오름차순으로 1차원 정수 배열에 담아return 하도록 solution 함수를 완성해 주세요. ^EwqaksHb

vector solution(string today, vector terms, vector privacies) { vector answer; return answer; } ^udcjPc0B

아... 그래서 newDate와 today가 같으면 파기하는 거구나... 문제를 똑바로 읽자... ^DtiPN46d

< 가 아니라 <= 로 비교 했어야 했구나 ^osXXZqed

### Steps

{% stepper %}
{% step %}
### today 문자열 -> int YYYY, MM, DD 로 구분 함수 구현

```cpp
vector<int> splitDate(const string& str, char delimiter);

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
```
{% endstep %}

{% step %}
### 문자열을 띄어쓰기를 기준으로 나누는 함수 구현

```cpp
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

템플릿 버전 예시:

```cpp
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
```

사용 예시(구현 흐름 요약):

* today를 split(today, ".")로 분해하여 연,월,일을 얻음.
* terms를 split(term, " ")로 분해하여 약관 타입과 개월수를 얻음.
* privacies 각 항목을 split하여 날짜와 약관 타입을 얻고, 해당 약관의 개월수만큼 더함.
* 모든 달은 28일까지라고 가정하므로 월 계산은 (month + monthsToAdd - 1)로 처리하여 연도/월을 올바르게 계산.
* 만료일(newDate)과 today를 비교할 때는 newDate <= today 라면 파기 대상.
{% endstep %}
{% endstepper %}

## Combined C++ Implementation

```cpp
#include <string>
#include <vector>
#include <sstream>

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

## Drawing (Excalidraw compressed data)

```compressed-json
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
...
```

(Compressed drawing JSON truncated for brevity; original compressed JSON preserved in the source.)
