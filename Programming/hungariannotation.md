# HungarianNotation

{% stepper %}
{% step %}
### 시스템 헝가리안 표기법

* 시스템 헝가리안 표기법은 변수의 데이터 타입을 나타내는 접두어를 사용합니다.
* 예를 들어, 변수의 타입이 정수(integer)일 경우 `i`, 문자열(string)일 경우 `str`, 부동소수점(float)일 경우 `f` 등의 접두어를 붙입니다.

{% code title="예시 (C)" %}
```c
int iCount;    // 정수를 나타내는 변수
char cLetter;  // 문자를 나타내는 변수
float fPrice;  // 부동소수점을 나타내는 변수
string strName;// 문자열을 나타내는 변수
```
{% endcode %}

* 장점: 코드를 읽는 사람이 변수의 타입을 쉽게 파악할 수 있습니다.
* 단점: 현대의 많은 IDE(통합 개발 환경)들이 변수 타입을 쉽게 확인할 수 있는 기능을 제공하기 때문에, 이 표기법은 점차 덜 사용되고 있습니다.
{% endstep %}

{% step %}
### 애플리케이션 헝가리안 표기법

* 애플리케이션 헝가리안 표기법은 변수의 데이터 타입 대신 그 변수의 목적이나 역할을 나타내는 접두어를 사용합니다.
* 이 방법은 변수의 의미를 더 명확하게 이해하는 데 도움을 줍니다.

{% code title="예시 (접두어 의미)" %}
```c
rwWidth: 읽기/쓰기 가능의 너비(Read/Write Width)
usUserCount: 사용자 수(User Count)
bIsVisible: 논리값 변수로서 보이는지 여부(Boolean Is Visible)
```
{% endcode %}

* 장점: 변수의 용도를 쉽게 파악할 수 있어 코드의 가독성이 높아지고 유지보수가 용이해집니다.

**애플리케이션 헝가리안 표기법 사용 예시**

{% code title="예시 (C)" %}
```c
int iTotal = 0;
float fAverage = 0.0;
string strUserName = "John Doe";
bool bIsLoggedIn = false;

// 함수 사용 예시
void UpdateUserScore(int iScore) {
    // 함수 내부 로직
}
```
{% endcode %}
{% endstep %}

{% step %}
### 정리

* 헝가리안 표기법은 코드를 더 명확하고 이해하기 쉽게 만들기 위한 방법으로, 변수의 타입이나 목적을 변수명에 포함시켜 사용하는 표기법입니다.
* 시스템 헝가리안 표기법은 변수의 데이터 타입을 나타내고, 애플리케이션 헝가리안 표기법은 변수의 역할이나 목적을 나타냅니다.
* 이 표기법은 특히 큰 규모의 프로젝트에서 코드의 가독성과 유지보수성을 향상시키는 데 유용할 수 있습니다.
{% endstep %}
{% endstepper %}
