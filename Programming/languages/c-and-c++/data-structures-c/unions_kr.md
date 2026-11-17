# 공용체 상세 (Unions)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DSC-002-DO |
| 유형 | D&O (원리) + 예제 코드 |
| 목적 | 공용체(union)의 메모리 공유 방식과 바이트 보기, 태그된 유니언, 익명 유니언 사용법을 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

공용체(union, 유니언)는 구조체와 문법이 같지만, 모든 멤버가 같은 메모리를 공유한다. 구조체는 멤버마다 고유의 메모리를 가진다. 공용체는 같은 메모리를 서로 다른 이름과 타입으로 볼 수 있게 한다. 공용체의 크기는 가장 큰 멤버의 크기 이상이며 정렬 패딩이 더해질 수 있다.

구조체는 [구조체](structures.md)(PRG-DSC-001-DO)를 따른다.

## 2. 구성 요소

| 구성 | 설명 | 절 |
|---|---|---|
| 바이트 보기 | 공용체로 정수의 각 바이트를 읽는다 | 4-1 |
| 포인터 방식 | 같은 결과를 포인터 캐스팅으로 얻는다 | 4-2 |
| 태그된 유니언 | 구조체의 `type` 멤버로 현재 유효한 멤버를 표시한다 | 4-3 |
| 익명 유니언 | 이름 없는 공용체의 멤버를 바깥 구조체에서 직접 접근한다 | 4-4 |
| 구조체+배열 | 이름과 인덱스로 같은 데이터를 접근한다 | 4-5 |

## 3. 동작 원리

1. 공용체의 모든 멤버는 시작 주소가 같다.
2. 한 멤버에 값을 쓰면 같은 바이트가 다른 멤버의 값으로도 보인다.
3. 마지막에 쓴 멤버가 유효한 멤버다. 다른 멤버를 읽을 때의 결과는 아래 한계 절을 따른다.

## 4. 예제 코드

### 4-1. 정수의 바이트 보기

{% code title="intParts 예" %}
```c
union intParts {
    int theInt;
    char bytes[sizeof(int)];
};
```
{% endcode %}

포인터 캐스팅이나 포인터 산술 없이 각 바이트를 개별로 볼 수 있다.

{% code title="유니언으로 바이트 보기" %}
```c
union intParts parts;
parts.theInt = 5968145; // 임의의 숫자 > 255 (1 바이트)

printf("The int is %i\nThe bytes are [%i, %i, %i, %i]\n",
    parts.theInt, parts.bytes[0], parts.bytes[1], parts.bytes[2], parts.bytes[3]);
```
{% endcode %}

{% hint style="info" %}
NOTE: `char`의 부호 여부는 구현에 따라 다르다. `char`가 부호 있는 타입이면 0x80 이상인 바이트는 음수로 출력된다. 이 예의 `5968145`는 16진수 `0x5B0A91`이며 바이트 `0x91`은 음수(`-111`)로 출력될 수 있다. 값 그대로 보려면 `unsigned char`를 쓴다.
{% endhint %}

### 4-2. 포인터 연산으로 같은 동작

{% code title="포인터 연산으로 바이트 보기 (동일 결과)" %}
```c
int theInt = parts.theInt;
printf("The int is %i\nThe bytes are [%i, %i, %i, %i]\n",
    theInt, *((char*)&theInt+0), *((char*)&theInt+1), *((char*)&theInt+2), *((char*)&theInt+3));

// 또는 배열 문법으로
printf("The int is %i\nThe bytes are [%i, %i, %i, %i]\n",
    theInt, ((char*)&theInt)[0], ((char*)&theInt)[1], ((char*)&theInt)[2], ((char*)&theInt)[3]);
```
{% endcode %}

### 4-3. 태그된 유니언

여러 타입을 한 번에 하나씩만 저장할 때 쓴다. 다음 구조체는 세 값을 모두 담느라 메모리를 낭비한다.

{% code title="불필요한 구조체 예" %}
```c
struct operator {
    int intNum;
    float floatNum;
    int type;
    double doubleNum;
};
```
{% endcode %}

변수가 많고 모든 변수에 메모리를 할당하기 비싸면 공용체로 메모리를 줄인다.

{% code title="태그된 유니언 사용 예" %}
```c
struct operator {
    int type;
    union {
        int intNum;
        float floatNum;
        double doubleNum;
    } types;
};
```
{% endcode %}

이 구조체의 크기는 `type` 크기와 공용체 크기(가장 큰 멤버인 `double` 기준)에 정렬 패딩이 더해진 값이다. 보통 단순한 합보다 크다. 사용 예는 다음과 같다.

{% code title="사용 예" %}
```c
struct operator op;
op.type = 0; // int, 보통 enum 또는 매크로 상수로 정의하는 것이 낫다
op.types.intNum = 352;
```
{% endcode %}

### 4-4. 익명 유니언

공용체에 이름을 붙이지 않으면 그 멤버를 구조체에서 직접 접근한다. 익명 구조체·공용체는 C11에서 표준이 됐다(그 전에는 컴파일러 확장).

{% code title="익명 유니언 예" %}
```c
struct operator {
    int type;
    union {
        int intNum;
        float floatNum;
        double doubleNum;
    }; // 이름 없음!
};

struct operator op;
op.type = 0; // int
// intNum은 유니언의 일부지만, 유니언이 익명이므로 구조체에서 직접 접근 가능
op.intNum = 352;
```
{% endcode %}

### 4-5. 구조체와 배열을 함께 쓰는 유니언

같은 타입 변수가 항상 여러 개 있을 때 이름(가독성)과 인덱스(반복 처리)를 둘 다 쓴다.

{% code title="구조체와 배열을 함께 사용한 유니언" %}
```c
union Coins {
    struct {
        int quarter;
        int dime;
        int nickel;
        int penny;
    }; // 익명 구조체: 멤버들이 외부 컨테이너에 존재하는 것처럼 작동
    int coins[4];
};
```
{% endcode %}

4개의 미국 동전을 나타낸다. 공용체는 메모리를 공유하므로 배열 `coins`와 구조체의 각 `int` 멤버는 순서대로 같은 메모리를 가리킨다.

{% code title="Coins 사용 예" %}
```c
union Coins change;
for (int i = 0; i < (int)(sizeof(change) / sizeof(int)); ++i)
{
    if (scanf("%i", change.coins + i) != 1)
    {
        return 1; // 입력 오류 (main 안에서 쓰는 경우)
    }
}
printf("There are %i quarters, %i dimes, %i nickels, and %i pennies\n",
    change.quarter, change.dime, change.nickel, change.penny);
```
{% endcode %}

## 5. 코드 설명

| 예제 | 핵심 |
|---|---|
| 4-1 | `theInt`에 쓴 값을 `bytes[]`로 읽으면 같은 메모리의 각 바이트가 나온다. 바이트 순서는 CPU의 엔디언(endianness)에 따른다 |
| 4-2 | `char *`로 캐스팅한 주소에 오프셋을 더해 같은 바이트를 읽는다. `char *`로 읽는 것은 별칭 규칙(aliasing)상 허용된다 |
| 4-3 | `type`이 어느 멤버가 유효한지 알려 준다. 공용체 자체는 현재 유효한 멤버를 기억하지 않는다 |
| 4-4 | `op.types.intNum` 대신 `op.intNum`으로 접근한다 |
| 4-5 | `sizeof(change) / sizeof(int)`는 4다. 구조체 멤버 사이에 패딩이 없다는 가정이 필요하며 `int` 4개에서는 일반적으로 성립한다 |

## 6. 한계와 주의

{% hint style="warning" %}
CAUTION: 한 멤버에 값을 쓰고 다른 멤버로 읽는 것(type punning)은 C에서 허용되지만 결과 값은 구현이 정의하며 읽은 값이 트랩 표현(trap representation)일 수 있다. C++에서는 정의되지 않은 동작(UB)이다. 엔디언과 타입 크기에 의존하는 코드는 이식성 문제를 일으킨다.
{% endhint %}

* 원본 코드의 `operator op;`는 C에서 `struct` 키워드가 필요하므로 `struct operator op;`로 정정했다.
* 원본 `scanf`는 반환값을 검사하지 않았다. 입력 실패를 검사하도록 추가했다.
* `sizeof(...) / sizeof(int)`는 `size_t`이므로 `int` 루프 변수와 비교하도록 `(int)` 캐스팅을 추가했다.

## 7. 참조

* [Unions 소스](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/Unions.c)
* [ExUnions 소스](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/ExUnions.c)
* [ExUnionsTest 소스](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/ExUnions_test.c)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 구조체와 공용체의 메모리 배치는 어떻게 다른가?
- [ ] 태그된 유니언에서 `type` 멤버가 없으면 어떤 문제가 생기는가?
- [ ] 바이트 보기 예제의 출력이 CPU마다 달라질 수 있는 이유는 무엇인가?
