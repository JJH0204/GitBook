# 전처리 과정 (Preprocessing)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-BLD-001-DO |
| 유형 | D&O (원리) |
| 목적 | C 컴파일 전에 실행되는 전처리(preprocessing)의 처리 항목과 `gcc -E` 확인 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 출력을 읽고 정리했으며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

전처리는 컴파일러가 소스 코드를 어셈블리어로 번역하기 전에 소스를 필요한 형식으로 가공하는 단계다. 언어마다 처리 내용이 조금 다르다. 이 문서는 C 기준이다.

## 2. 구성 요소

| 처리 항목 | 대상 | 결과 |
|---|---|---|
| 주석 제거 | `//`, `/* */` | 주석이 공백으로 대체된다 |
| 매크로 치환 | `#define`으로 정의한 이름 | 정의된 코드 또는 값으로 바뀐다 |
| 파일 포함 | `#include` | 지정한 헤더 파일의 내용이 그 자리에 텍스트로 삽입된다 |

{% hint style="info" %}
NOTE: 여러 소스 파일을 따로 컴파일한 오브젝트를 합치는 일은 전처리가 아니라 링크 단계에서 한다. [PRG-BLD-003-TS](cmodularizationerror.md)를 따른다.
{% endhint %}

## 3. 동작 원리

{% stepper %}
{% step %}
### 주석 제거

전처리 단계에서 소스 코드의 주석이 제거된다.
{% endstep %}

{% step %}
### 매크로 치환

`#define`으로 정의한 매크로를 정의된 코드 또는 값으로 치환한다.
{% endstep %}

{% step %}
### 파일 포함

`#include`는 지정한 헤더 파일의 내용을 그 자리에 텍스트로 삽입한다.
{% endstep %}
{% endstepper %}

## 4. 전처리 결과 확인 (REF)

| 명령 | 설명 |
|---|---|
| `gcc -E add.c > add.i` | `add.c`의 전처리 결과를 `add.i`에 저장한다 |
| `cat add.i` | 결과를 출력한다 |

```sh
$ gcc -E add.c > add.i
$ cat add.i
```

`add.c`를 `add.i`로 전처리한 결과는 다음과 같다.

```
# 1 "add.c"

# 1 "<built-in>"

# 1 "<command-line>"

# 31 "<command-line>"

# 1 "/usr/include/stdc-predef.h" 1 3 4

# 32 "<command-line>" 2

# 1 "add.c"

# 1 "add.h" 1
int add(int a, int b);

# 2 "add.c" 2

int add(int a, int b) { return a + b + 3; }
```

| 출력 | 의미 |
|---|---|
| `# 1 "add.c"` 같은 줄 | 줄 번호와 원본 파일 정보(linemarker)다. 컴파일러가 오류 위치를 알려 주는 데 쓴다 |
| `int add(int a, int b);` | `add.h`의 내용이 `#include`에 의해 삽입되었다 |
| `int add(int a, int b) { return a + b + 3; }` | `add.c`의 본문이다. 주석은 출력에 없다 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 전처리를 거친 `.i` 파일을 직접 열어 본 경험이 있는가? 무엇을 확인했는가?
- [ ] `#include`와 링크는 각각 무엇을 합치는가?
