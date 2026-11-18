# Hello World 예제

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CFD-001-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | C 프로그램의 최소 구조와 컴파일·실행 흐름을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

C 프로그램은 `main` 함수에서 실행이 시작된다. 소스 파일(`.c`)을 컴파일러로 번역해 실행 파일을 만든 뒤 실행한다.

## 2. 구성 요소

| 요소 | 코드 | 역할 |
|---|---|---|
| 헤더 포함 | `#include <stdio.h>` | 표준 입출력 함수(`printf`)의 선언을 가져온다 |
| 진입점 | `int main(void)` | 프로그램이 시작되는 함수. 인자를 받지 않는다 |
| 출력 | `printf("hello world\n");` | 문자열을 표준 출력에 쓴다. `\n`은 줄 바꿈이다 |
| 종료 값 | `return 0;` | 운영체제에 종료 상태를 알린다. 0은 정상 종료다 |

## 3. 예제 코드

{% code title="hello.c" lineNumbers="true" %}
```c
// hello.c
#include <stdio.h>

int main (void)
{
    printf("hello world\n");
    return 0;
}
```
{% endcode %}

## 4. 코드 설명

1. `#include <stdio.h>`는 전처리기가 컴파일 전에 헤더 내용을 소스에 삽입한다.
2. `int main(void)`의 `void`는 인자가 없음을 뜻한다. C에서 `int main()`은 "인자를 지정하지 않음"이라 `(void)`를 쓰는 것이 정확하다.
3. `printf`가 `hello world`와 줄 바꿈을 출력한다.
4. `return 0;`으로 정상 종료한다. C99부터 `main`은 `return`을 생략하면 0을 반환한다.

## 5. 컴파일과 실행 (미검증)

```
gcc hello.c -o hello
./hello
```

{% hint style="info" %}
NOTE: Windows(MinGW-w64)에서는 실행 파일 이름이 `hello.exe`이며 PowerShell에서 `.\hello.exe`로 실행한다. 컴파일러 설치는 [VS Code C/C++ 환경 설정](../setup/intro.md)을 따른다. 위 명령은 이 환경에서 실행하지 않았다.
{% endhint %}

## 6. 한계·주의

* 출력 끝에 `\n`이 없으면 일부 터미널에서 프롬프트가 같은 줄에 붙는다.
* 호스트 환경(운영체제 위에서 실행하는 일반 프로그램)에서 `main`의 반환 형식은 `int`다. `void main`은 표준 형식이 아니므로 쓰지 않는다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 소스 파일에서 실행 파일이 만들어지기까지 어떤 단계를 거치는지 내 말로 설명해 보자.
- [ ] `int main()`과 `int main(void)`의 차이를 내 말로 적어 보자.
- [ ] 처음 컴파일했을 때 겪은 오류가 있다면 무엇이었고 어떻게 풀었는지 적어 보자.
