# 포인터 연산 상세 (Arithmetics)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-PTR-003-DO |
| 유형 | D&O (개념) + 예제 코드 |
| 목적 | 포인터에 정수를 더하고 빼거나 증감할 때 주소가 이동하는 단위와 유효 범위를 설명한다 |
| 확인 상태 | 미검증 (원본 코드를 읽고 정정했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 정정한 곳. (1) 원본은 `%x`로 포인터를 출력했다. `%x`는 `unsigned int`용이라 포인터 출력은 UB이며, 64비트에서는 주소가 잘린다. `%p`와 `(void *)` 형변환으로 바꿨다. (2) `int main()`을 `int main(void)`로 바꿨다. (3) 유효 범위 규칙(배열 끝 다음까지)과 포인터 뺄셈을 추가했다.
{% endhint %}

## 1. 정의

포인터 연산은 포인터가 가리키는 위치를 요소 단위로 옮기는 연산이다. 지원 연산은 `++`, `--`, `+`(정수), `-`(정수), 포인터끼리의 `-`, 비교 연산자다.

{% hint style="info" %}
NOTE: 포인터에 정수 `n`을 더하거나 빼면 주소는 바이트가 아니라 `n * sizeof(가리키는 타입)`만큼 이동한다. `int *`에 1을 더하면 주소는 `sizeof(int)`만큼 증가한다.
{% endhint %}

## 2. 구성 요소

| 연산 | 예 | 결과 |
|---|---|---|
| 증가 | `p++` | 다음 요소를 가리킨다 (+ `sizeof(*p)` 바이트) |
| 감소 | `p--` | 이전 요소를 가리킨다 (- `sizeof(*p)` 바이트) |
| 덧셈 | `p + n`, `p += n` | n개 뒤 요소를 가리킨다 |
| 뺄셈 | `p - n`, `p -= n` | n개 앞 요소를 가리킨다 |
| 포인터 뺄셈 | `p2 - p1` | 두 포인터 사이의 요소 개수(`ptrdiff_t`). 같은 배열의 포인터일 때만 정의된다 |
| 비교 | `p1 < p2`, `p1 == p2` | 주소를 비교한다. `<`, `>`는 같은 배열 안의 포인터끼리만 정의된다 |

### 유효 범위

* 포인터 연산의 결과는 같은 배열의 요소, 또는 마지막 요소 바로 다음 위치(one-past-the-end)까지만 정의된다.
* 이 범위를 넘는 포인터를 만드는 것 자체가 UB다. 역참조는 마지막 요소까지만 가능하며 one-past-the-end 위치는 역참조할 수 없다.
* 배열 5개(`intarray[5]`)에서 유효한 포인터는 `intarray + 0`부터 `intarray + 5`까지다. 역참조는 `intarray + 4`까지다.

## 3. 예제 코드

다음 네 예제는 모두 `intarray`의 요소를 가리키는 `intpointer`를 만든 뒤 연산을 적용한다.

### 3-1. `++`로 포인터 증가

{% code title="pointer_increment.c" %}
```c
#include <stdio.h>

int main(void)
{
    int intarray[5] = {10,20,30,40,50};

    int i;
    for(i = 0; i < 5; i++)
        printf("intarray[%d] has value %d - and address @ %p\n", i, intarray[i], (void *)&intarray[i]);

    int *intpointer = &intarray[3]; // point to the 4th element in the array
    printf("address: %p - has value %d\n", (void *)intpointer, *intpointer); // print the address of the 4th element

    intpointer++; // now increase the pointer's address so it points to the 5th element in the array
    printf("address: %p - has value %d\n", (void *)intpointer, *intpointer); // print the address of the 5th element

    return 0;
}
```
{% endcode %}

### 3-2. `--`로 포인터 감소

{% code title="pointer_decrement.c" %}
```c
#include <stdio.h>

int main(void)
{
    int intarray[5] = {10,20,30,40,50};

    int i;
    for(i = 0; i < 5; i++)
        printf("intarray[%d] has value %d - and address @ %p\n", i, intarray[i], (void *)&intarray[i]);

    int *intpointer = &intarray[4]; // point to the 5th element in the array
    printf("address: %p - has value %d\n", (void *)intpointer, *intpointer); // print the address of the 5th element

    intpointer--; // now decrease the pointer's address so it points to the 4th element in the array
    printf("address: %p - has value %d\n", (void *)intpointer, *intpointer); // print the address of the 4th element

    return 0;
}
```
{% endcode %}

### 3-3. `+`로 포인터 더하기

{% code title="pointer_addition.c" %}
```c
#include <stdio.h>

int main(void)
{
    int intarray[5] = {10,20,30,40,50};

    int i;
    for(i = 0; i < 5; i++)
        printf("intarray[%d] has value %d - and address @ %p\n", i, intarray[i], (void *)&intarray[i]);

    int *intpointer = &intarray[1]; // point to the 2nd element in the array
    printf("address: %p - has value %d\n", (void *)intpointer, *intpointer); // print the address of the 2nd element

    intpointer += 2; // now shift by two the pointer's address so it points to the 4th element in the array
    printf("address: %p - has value %d\n", (void *)intpointer, *intpointer); // print the address of the 4th element

    return 0;
}
```
{% endcode %}

### 3-4. `-`로 포인터 빼기

{% code title="pointer_subtraction.c" %}
```c
#include <stdio.h>

int main(void)
{
    int intarray[5] = {10,20,30,40,50};

    int i;
    for(i = 0; i < 5; i++)
        printf("intarray[%d] has value %d - and address @ %p\n", i, intarray[i], (void *)&intarray[i]);

    int *intpointer = &intarray[4]; // point to the 5th element in the array
    printf("address: %p - has value %d\n", (void *)intpointer, *intpointer); // print the address of the 5th element

    intpointer -= 2; // now shift by two the pointer's address so it points to the 3rd element in the array
    printf("address: %p - has value %d\n", (void *)intpointer, *intpointer); // print the address of the 3rd element

    return 0;
}
```
{% endcode %}

## 4. 코드 설명

1. 네 예제 모두 먼저 5개 요소의 주소와 값을 출력한다. 주소는 실행마다 다르다. 이웃한 주소의 차이는 `sizeof(int)`(보통 4바이트)다.
2. `++`: 인덱스 3(40)에서 4(50)로 이동한다. 주소는 4바이트 증가한다.
3. `--`: 인덱스 4(50)에서 3(40)으로 이동한다. 주소는 4바이트 감소한다.
4. `+= 2`: 인덱스 1(20)에서 3(40)으로 이동한다. 주소는 2 x 4 = 8바이트 증가한다. 포인터가 `int *`이고 `int`가 4바이트이기 때문이다.
5. `-= 2`: 인덱스 4(50)에서 2(30)로 이동한다. 주소는 8바이트 감소한다.
6. 출력 값 예: `address: 0x... - has value 40`, 이어서 `address: 0x... - has value 50`(`++` 예제).

## 5. 한계·주의

* `%p`는 `void *`를 받는다. 다른 타입의 포인터는 `(void *)`로 변환해 넘긴다. 주소 출력 형식(`0x` 붙음 여부 등)은 구현에 따라 다르다.
* `intpointer++` 후 `*intpointer`는 이동한 위치에 유효한 요소가 있을 때만 읽을 수 있다. 예제에서 `intarray[4]`에서 `++`한 뒤 역참조하면 배열 밖이므로 UB다.
* 서로 다른 배열이나 객체의 포인터를 `<`로 비교하거나 빼면 정의되지 않는다.
* `void *`에는 포인터 연산을 쓸 수 없다(표준 C). GCC는 확장으로 허용하지만 이식되지 않는다.

## 6. 소스 코드 링크

* [PointerArithmetics](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/PointerArithmetics.c)
* [ExPointerArithmetics](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/ExPointerArithmetics.c)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 포인터에 1을 더하면 주소가 1바이트가 아니라 `sizeof` 단위로 움직이는 이유를 내 말로 설명해 보자.
- [ ] "배열 끝 다음 위치"까지만 포인터를 만들 수 있다는 규칙이 왜 필요한지 적어 보자.
- [ ] `p[i]`가 `*(p + i)`와 같다는 사실을 이 문서의 예제와 연결해 설명해 보자.
