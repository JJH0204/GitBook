# Unions\_kr

C 유니언은 각각 고유의 메모리를 가진 여러 변수를 포함하는 대신 동일한 메모리를 공유하는 여러 이름을 허용한다는 점을 제외하고는 본질적으로 C 구조체와 동일하다. 이 이름들은 같은 메모리를 서로 다른 타입으로 취급할 수 있다. (그리고 유니언의 크기는 컴파일러가 정하는 가장 큰 멤버 타입의 크기가 된다.)

따라서 변수의 메모리를 다른 방식으로 읽고 싶을 때 유니언을 사용할 수 있다. 예: 정수를 바이트 단위로 각각 볼 때:

{% code title="intParts 예" %}
```c
union intParts {
    int theInt;
    char bytes[sizeof(int)];
};
```
{% endcode %}

포인터를 캐스팅하거나 포인터 산술을 직접 사용하지 않고도 각 바이트를 개별적으로 볼 수 있다:

{% code title="유니언으로 바이트 보기" %}
```c
union intParts parts;
parts.theInt = 5968145; // 임의의 숫자 > 255 (1 바이트)

printf("The int is %i\nThe bytes are [%i, %i, %i, %i]\n",
    parts.theInt, parts.bytes[0], parts.bytes[1], parts.bytes[2], parts.bytes[3]);
```
{% endcode %}

동일한 동작을 포인터 연산으로 수행하면 다음과 같다:

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

구조체와 결합하면 여러 다른 타입을 한 번에 하나씩 저장하는 데 사용할 수 있는 "태그된" 유니언을 만들 수 있다.

예를 들어, 다음과 같은 구조체를 원하지 않을 때:

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

프로그램에 많은 변수가 있고 모든 변수에 대해 메모리를 모두 할당하기에 비용이 클 경우, 유니언을 사용해 메모리를 절약할 수 있다:

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

이 경우 구조체의 크기는 유니언에서 가장 큰 멤버(예: double)의 크기와 type 멤버의 크기의 합이 된다. 다음과 같이 사용한다:

{% code title="사용 예" %}
```c
operator op;
op.type = 0; // int, 보통 enum 또는 매크로 상수로 정의하는 것이 낫다
op.types.intNum = 352;
```
{% endcode %}

유니언에 이름을 지정하지 않으면 그 유니언의 멤버는 구조체에서 직접 접근할 수 있다:

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

operator op;
op.type = 0; // int
// intNum은 유니언의 일부지만, 유니언이 익명이므로 구조체에서 직접 접근 가능
op.intNum = 352;
```
{% endcode %}

또 다른 유용한 패턴은 동일한 타입의 변수가 항상 여러 개 있고 이름(가독성)과 인덱스(반복 처리용) 둘 다 사용하고 싶을 때이다:

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

이 예에서 4개의 미국 동전을 나타내는 구조가 있다. 유니언은 동일한 메모리를 공유하므로 배열 coins와 구조의 각 int 멤버는 순서대로 동일한 메모리를 가리킨다.

{% code title="Coins 사용 예" %}
```c
union Coins change;
for(int i = 0; i < sizeof(change) / sizeof(int); ++i)
{
    scanf("%i", change.coins + i); // 주의: 입력 시 항상 조심할 것
}
printf("There are %i quarters, %i dimes, %i nickels, and %i pennies\n",
    change.quarter, change.dime, change.nickel, change.penny);
```
{% endcode %}

{% hint style="warning" %}
유니언의 멤버들은 동일한 메모리를 공유한다는 점을 잊지 마십시오. 한 멤버에 값을 쓰고 다른 멤버로 읽을 때의 동작은 의도한 바에 따라 달라지며, 특히 정렬(endianness)이나 타입 크기에 의존하는 코드는 이식성 문제를 일으킬 수 있습니다.
{% endhint %}
