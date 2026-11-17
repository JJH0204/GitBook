# C++ 문법 및 기본 개념 (C++)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CPP-001-REF |
| 유형 | REF (자료형 표 + 작성 예정 주제) |
| 목적 | C++ 기본 자료형의 일반적인 크기를 찾고, 이후 정리할 주제를 확인한다 |
| 확인 상태 | 미검증 (원본 표를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. Hello World 예제

{% code title="hello.cpp" %}
```cpp
#include <iostream>
/* C++ 표준 라이브러리 포함 선언 */
#include "includeBasics.h"
using namespace std;
/* 네임스페이스 std를 명시적으로 선언,
이후 사용하는 cout객체를 네임스페이스 선언없이 호출할 수 있다. */

/* --- Cpp 기본 : Hello World --- */
void ex_HelloWorld(void)
{
    // using namespace std;
    cout << "Hello World" << endl;
    // endl <- 줄 바꿈 의미 (출력 버퍼도 비운다)
}
```
{% endcode %}

| 줄 | 설명 |
|---|---|
| `#include <iostream>` | 표준 입출력 스트림(`cout` 등)을 포함한다 |
| `#include "includeBasics.h"` | 작성자의 프로젝트 헤더다. 이 문서에는 내용이 없어 단독으로 컴파일되지 않는다 |
| `using namespace std;` | `std::`를 생략하게 한다. 헤더 파일에서는 쓰지 않는 것이 관례다 |
| `cout << ... << endl;` | 문자열을 출력하고 줄을 바꾼다 |

## 2. 자료형

{% hint style="info" %}
NOTE: 크기는 구현(컴파일러, 운영체제)에 따라 다르다. 표준이 보장하는 것은 `sizeof(char) == 1`과 크기의 대소 관계 등이다. 아래 값은 일반적인 값이다.
{% endhint %}

| 자료형 | 설명 | 일반적인 크기 |
|---|---|---|
| `bool` | 논리형. 참(`true`) 또는 거짓(`false`) | 1 byte |
| `char` | 문자형. 단일 문자를 저장 | 1 byte (표준이 보장) |
| `wchar_t` | 와이드 문자형. 더 큰 문자 집합(유니코드 등) | 2 또는 4 bytes (Windows 2, Linux 4) |
| `char16_t` | UTF-16 문자형 (C++11) | 2 bytes |
| `char32_t` | UTF-32 문자형 (C++11) | 4 bytes |
| `short` | 짧은 정수형 | 2 bytes |
| `int` | 정수형 | 4 bytes |
| `long` | 긴 정수형 | 4 또는 8 bytes |
| `long long` | 더 긴 정수형 (C++11) | 8 bytes |
| `unsigned` | 부호 없는 정수형 (`unsigned int`와 같다) | 4 bytes |
| `unsigned short` | 부호 없는 짧은 정수형 | 2 bytes |
| `unsigned long` | 부호 없는 긴 정수형 | 4 또는 8 bytes |
| `unsigned long long` | 부호 없는 더 긴 정수형 | 8 bytes |
| `float` | 단정밀도 부동소수점형 | 4 bytes |
| `double` | 배정밀도 부동소수점형 | 8 bytes |
| `long double` | 확장 정밀도 부동소수점형 | 8, 12 또는 16 bytes |
| `void` | 자료형이 없음을 나타낸다. 함수의 반환형으로 주로 쓴다 | `sizeof(void)`는 표준에서 불가 |
| `std::nullptr_t` | null 포인터 리터럴 `nullptr`의 타입 (C++11) | `sizeof(void*)`와 같다 |

## 3. 작성 예정 주제

원본에 제목만 있고 내용이 없는 주제다.

| 주제 | 상태 |
|---|---|
| 헝가리안 표기법 | 미작성 |
| 형변환 | [PRG-CPP-002-DO](type-cast.md) |
| 레퍼런스 | 미작성 |
| 오버로딩 | 미작성 |
| 함수 디폴트 인자 | 미작성 |
| 메모리 동적 할당 | 미작성 |
| 헤더 가드 | 미작성 |
| 네임스페이스 | 미작성 |
| 템플릿 | 미작성 |

## 4. 참조

* [About Cpp (CPPBasics 저장소)](https://github.com/JJH0204/CPPBasics)
