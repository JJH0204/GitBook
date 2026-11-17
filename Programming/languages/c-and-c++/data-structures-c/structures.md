# 구조체 (Structures)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DSC-001-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 구조체의 정의, 멤버 접근, 크기 특성을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

구조체(structure)는 서로 다른 타입의 변수 여러 개를 하나의 이름으로 묶은 사용자 정의 자료형이다. 묶인 각 변수를 멤버(member)라 한다. 각 멤버는 자기 메모리를 가진다. 멤버끼리 메모리를 공유하는 공용체는 [공용체 상세](unions_kr.md)(PRG-DSC-002-DO)를 따른다.

## 2. 구성 요소

| 요소 | 문법 | 설명 |
|---|---|---|
| 정의 | `struct 태그 { 멤버들 };` | 새 타입을 만든다 |
| 별칭 | `typedef struct { ... } 이름;` | `struct` 키워드 없이 `이름`으로 쓴다 |
| 멤버 접근 | `변수.멤버` | 구조체 변수의 멤버를 읽고 쓴다 |
| 포인터로 접근 | `포인터->멤버` | `(*포인터).멤버`와 같다 |

## 3. 동작 원리

1. 컴파일러는 멤버를 선언한 순서대로 메모리에 배치한다.
2. 멤버 사이에는 정렬(alignment)을 위한 패딩(padding)이 들어갈 수 있다. 따라서 `sizeof`는 멤버 크기의 합 이상이다.
3. 같은 구조체 타입의 변수끼리 대입하면 모든 멤버가 복사된다. 포인터 멤버는 주소만 복사된다.

## 4. 예제 코드

{% code title="structures.c" %}
```c
//structures.c
#include <stdio.h>

/* define the person struct here using the typedef syntax */
typedef struct
{
    const char * name;
    int age;
} person;

int main(void)
{
    person john;

    /* testing code */
    john.name = "John";
    john.age = 27;
    printf("%s is %d years old.\n", john.name, john.age);
    return 0;
}
```
{% endcode %}

## 5. 코드 설명

| 줄 | 설명 |
|---|---|
| `typedef struct { ... } person;` | 이름 없는 구조체에 `person`이라는 별칭을 붙인다 |
| `const char * name;` | 문자열 리터럴을 가리키는 포인터 멤버다. 문자열 자체는 복사되지 않는다 |
| `person john;` | `person` 타입 변수 `john`을 만든다. 멤버는 초기화되지 않은 상태다 |
| `john.name = "John";` | 문자열 리터럴의 주소를 대입한다 |
| `printf(...)` | 두 멤버를 출력한다. 예상 출력은 `John is 27 years old.`다 |

## 6. 한계와 주의

{% hint style="warning" %}
CAUTION: 문자열 리터럴을 수정하면 정의되지 않은 동작(UB)이다. 멤버가 가리키는 문자열을 바꿔야 하면 `char name[32];` 같은 배열 멤버를 쓴다.
{% endhint %}

* 원본 코드의 `char * name`은 `const char * name`으로, `int main()`은 `int main(void)`로 정정했고 `return 0;`과 출력 끝의 `\n`을 추가했다.
* 이름 없는 구조체는 자기 자신을 가리키는 포인터 멤버(연결 리스트의 `next`)를 만들 수 없다. 이때는 태그를 붙인다(`typedef struct Node { struct Node *next; } Node;`).

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 구조체 변수의 `sizeof`가 멤버 크기의 합과 다를 수 있는 이유는 무엇인가?
- [ ] `.`와 `->`는 각각 언제 쓰는가?
- [ ] 문자열을 멤버로 저장할 때 `const char *`와 `char[N]`의 차이는 무엇인가?
