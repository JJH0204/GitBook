# Variables and Types

```c
#include <stdio.h>

int main(void)
{
    int i = 3;
    float f = 4.5;
    double d = 5.25;
    float sum;

    sum = i + f + d;
    // float f2i = (float)i;
    // float f2d = (float)d;

    // sum = f + f2i + f2d;

    printf("The sum of a a, b, and c is %f.", sum);
    return 0;
}
```

C에는 여러 가지 변수 타입이 있지만, 몇 가지 기본 타입이 있습니다:

* **정수**: 양수 또는 음수일 수 있는 정수. `char`, `int`, `short`, `long` 또는 `long long`을 사용하여 정의됩니다.
* **부호 없는 정수**: 양수만 될 수 있는 정수. `unsigned char`, `unsigned int`, `unsigned short`, `unsigned long` 또는 `unsigned long long`을 사용하여 정의됩니다.
* **부동 소수점 숫자**: 분수가 있는 실수. `float` 및 `double`을 사용하여 정의됩니다.
* **구조체**: 구조체 섹션에서 나중에 설명됩니다.

다양한 변수 타입은 그들의 범위를 정의합니다.

`char`는 -128에서 127까지만 범위가 가능하지만, `long`은 -2,147,483,648에서 2,147,483,647까지 범위가 가능합니다

(다른 컴퓨터에서는 `long` 및 다른 숫자 데이터 타입의 범위가 다를 수 있습니다. 예를 들어 64비트 컴퓨터에서는 -9,223,372,036,854,775,808에서 9,223,372,036,854,775,807까지 범위가 가능합니다).

C에는 boolean 타입이 없다는 점에 유의하세요. 일반적으로 다음 표기법을 사용하여 정의됩니다:

```c
#define BOOL char
#define FALSE 0
#define TRUE 1
```

