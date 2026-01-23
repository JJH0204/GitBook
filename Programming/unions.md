# unions

### 소스 코드 링크

* [Unions](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/Unions.c)
* [ExUnions](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/ExUnions.c)
* [ExUnionsTest](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/ExUnions_test.c)

## Unions

C 유니언은 각각 고유의 메모리를 가진 여러 변수를 포함하는 대신 동일한 변수에 대해 여러 이름을 허용한다는 점을 제외하고는 본질적으로 C 구조와 동일하다. 이 이름들은 메모리를 다른 유형으로 취급할 수 있다. (그리고 조합의 크기는 컴파일러가 부여하기로 결정할 수 있는 가장 큰 유형의 크기가 될 것이다.)

따라서 변수의 메모리를 다른 방식으로 읽을 수 있기를 원한다면, 예를 들어 한 번에 정수 1바이트를 읽는 것과 같이 다음과 같은 것을 가질 수 있습니다:

```c
union intParts {
    int theInt;
    char bytes[sizeof(int)];
};
```

포인터를 캐스팅하지 않고 포인터 산술을 사용하지 않고 각 바이트를 개별적으로 볼 수 있습니다:

```c
union intParts parts;
parts.theInt = 5968145; // arbitrary number > 255 (1 byte)

printf("The int is %i\nThe bytes are [%i, %i, %i, %i]\n",
parts.theInt, parts.bytes[0], parts.bytes[1], parts.bytes[2], parts.bytes[3]);

// vs

int theInt = parts.theInt;
printf("The int is %i\nThe bytes are [%i, %i, %i, %i]\n",
theInt, *((char*)&theInt+0), *((char*)&theInt+1), *((char*)&theInt+2), *((char*)&theInt+3));

// or with array syntax which can be a tiny bit nicer sometimes

printf("The int is %i\nThe bytes are [%i, %i, %i, %i]\n",
    theInt, ((char*)&theInt)[0], ((char*)&theInt)[1], ((char*)&theInt)[2], ((char*)&theInt)[3]);
```

다음은 구조체와 결합하여 여러 다른 유형을 한 번에 하나씩 저장하는 데 사용할 수 있는 "태그된" 결합의 예시입니다.

{% stepper %}
{% step %}
### 기본: 태그된 유니언 (구조체 + 유니언)

예를 들어, "숫자" 구조를 가질 수 있지만 다음과 같은 것을 사용하고 싶지는 않습니다:

```c
struct operator {
    int intNum;
    float floatNum;
    int type;
    double doubleNum;
};
```

메모리를 절약하려면 다음과 같이 유니언을 구조체 안에 넣어 사용할 수 있습니다:

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

이와 같이 구조물의 크기는 유니언에서 가장 큰 형태(예: double)의 크기만큼만 추가로 필요합니다.

사용 예:

```c
operator op;
op.type = 0; // int, probably better as an enum or macro constant
op.types.intNum = 352;
```
{% endstep %}

{% step %}
### 익명 유니언 (unnamed union) — 구조체에서 직접 접근

유니언에 이름을 지정하지 않으면, 유니언 멤버는 구조체에서 직접 액세스됩니다:

```c
struct operator {
    int type;
    union {
        int intNum;
        float floatNum;
        double doubleNum;
    }; // no name!
};

operator op;
op.type = 0; // int
// intNum is part of the union, but since it's not named you access it directly off the struct itself
op.intNum = 352;
```
{% endstep %}

{% step %}
### 동일 유형의 변수들을 이름과 인덱스로 함께 접근하는 예

동일한 유형의 변수가 항상 여러 개 있고 이름(가독성)과 인덱스(반복하기 쉬움)를 모두 사용하고 싶을 때 유용한 패턴:

```c
union Coins {
    struct {
        int quarter;
        int dime;
        int nickel;
        int penny;
    }; // 익명 구조체는 익명 유니언과 동일한 방식으로 작동하며 멤버는 외부 컨테이너에 있습니다.
    int coins[4];
};
```

이 예에서는 4개의 동전(quarter, dime, nickel, penny)을 가지는 구조와 동일한 메모리를 coins 배열로도 접근할 수 있습니다.

사용 예:

```c
union Coins change;
for(int i = 0; i < sizeof(change) / sizeof(int); ++i)
{
    scanf("%i", change.coins + i); // 잘못된 코드입니다! 입력은 항상 주의해야 합니다.
}
printf("There are %i quarters, %i dimes, %i nickels, and %i pennies\n",
    change.quarter, change.dime, change.nickel, change.penny);
```
{% endstep %}
{% endstepper %}

{% hint style="info" %}
유니언은 멤버들이 동일한 메모리를 공유하도록 만든다. 따라서 한 멤버에 값을 쓰고 다른 멤버에서 읽으면 정의되지 않은 동작이나 구현 정의된 결과(예: 엔디안 차이)에 의존할 수 있다. 태그 필드(type)를 함께 사용해 어떤 멤버가 유효한지 명시하는 패턴이 일반적이다.
{% endhint %}
