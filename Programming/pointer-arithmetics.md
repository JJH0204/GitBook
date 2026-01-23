# pointer arithmetics

### 소스 코드 링크

* P[ointerArithmetics](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/PointerArithmetics.c)
* [ExPointerArithmetics](https://github.com/JJH0204/DevBasics/blob/main/source/C_language/ExPointerArithmetics.c)

## 포인터 연산자

포인터가 무엇인지, 포인터를 활용하는 방법을 이전에 배웠습니다. 이 튜토리얼에서는 포인터에 대한 산술 연산을 배우게 됩니다. C 포인터에 적용할 수 있는 산술 연산은 여러 가지가 있습니다: ++, --, -, +

### (++)를 사용하여 포인터 증가

다른 변수들과 마찬가지로 ++연산은 그 변수의 값을 증가시킨다. 이 경우 변수는 포인터이므로 값을 늘리면 포인터가 가리키는 메모리의 주소가 증가합니다. 예제에서는 이 작업을 배열과 결합해 보겠습니다.

{% code title="PointerArithmetics.c" %}
```c
#include <stdio.h>

int main()
{
    int intarray[5] = {10,20,30,40,50};

    int i;
    for(i = 0; i < 5; i++)
        printf("intarray[%d] has value %d - and address @ %x\n", i, intarray[i], &intarray[i]);

    int *intpointer = &intarray[3]; //point to the 4th element in the array
    printf("address: %x - has value %d\n", intpointer, *intpointer); //print the address of the 4th element

    intpointer++; //now increase the pointer's address so it points to the 5th elemnt in the array
    printf("address: %x - has value %d\n", intpointer, *intpointer); //print the address of the 5th element

    return 0;
}
```
{% endcode %}

### (--)를 사용하여 포인터 감소

이전 예제와 마찬가지로 연산자를 사용하여 포인터가 가리키는 주소를 1만큼 늘렸고, 감소 연산자(--)를 사용하여 가리키는 주소를 1만큼 줄일 수 있습니다.

{% code title="ExPointerArithmetics_decrement.c" %}
```c
#include <stdio.h>

int main()
{
    int intarray[5] = {10,20,30,40,50};

    int i;
    for(i = 0; i < 5; i++)
        printf("intarray[%d] has value %d - and address @ %x\n", i, intarray[i], &intarray[i]);

    int *intpointer = &intarray[4]; //point to the 5th element in the array
    printf("address: %x - has value %d\n", intpointer, *intpointer); //print the address of the 5th element

    intpointer--; //now decrease the point's address so it points to the 4th element in the array
    printf("address: %x - has value %d\n", intpointer, *intpointer); //print the address of the 4th element

    return 0;
}
```
{% endcode %}

### (+)로 포인터 추가하기

이전에는 포인터가 가리키는 주소를 1만큼 늘렸습니다. 다음과 같이 정수 값으로 늘릴 수도 있습니다.

{% code title="PointerArithmetics_add.c" %}
```c
#include <stdio.h>

int main()
{
    int intarray[5] = {10,20,30,40,50};

    int i;
    for(i = 0; i < 5; i++)
        printf("intarray[%d] has value: %d - and address @ %x\n", i, intarray[i], &intarray[i]);

    int *intpointer = &intarray[1]; //point to the 2nd element in the array
    printf("address: %x - has value %d\n", intpointer, *intpointer); //print the address of the 2nd element

    intpointer += 2; //now shift by two the point's address so it points to the 4th element in the array
    printf("address: %x - has value %d\n", intpointer, *intpointer); //print the addres of the 4th element

    return 0;
}
```
{% endcode %}

출력에서 주소가 메모리에서 8단계만큼 이동한 방법에 유의하세요. 포인터가 int 포인터이고 int 변수의 크기가 4바이트이기 때문에 메모리는 2 \* 4바이트 = 8바이트 만큼 이동합니다.

{% hint style="info" %}
포인터에 정수를 더하거나 빼면 실제 바이트 단위가 아니라 해당 타입의 크기만큼 이동합니다. 예: int 포인터에 1을 더하면 주소는 sizeof(int)만큼 증가합니다.
{% endhint %}

### (-) 포인터 빼기

마찬가지로 포인터에서 정수를 뺄 수 있습니다.

{% code title="PointerArithmetics_subtract.c" %}
```c
#include <stdio.h>

int main()
{
    int intarray[5] = {10,20,30,40,50};

    int i;
    for(i = 0; i < 5; i++)
        printf("intarray[%d] has value: %d - and address @ %x\n", i, intarray[i], &intarray[i]);

    int *intpointer = &intarray[4]; //point to the 5th element in the array
    printf("address: %x - has value %d\n", intpointer, *intpointer); //print the address of the 5th element

    intpointer -= 2; //now shift by two the point's address so it points to the 3rd element in the array
    printf("address: %x - has value %d\n", intpointer, *intpointer); //print the address of the 3rd element

    return 0;
}
```
{% endcode %}

다시 한번 주소가 해당 타입의 바이트 블록만큼 이동됩니다(int의 경우 sizeof(int) 바이트).

### 기타 연산자

비교 연산자(>, <, == 등)도 포인터에 적용할 수 있습니다. 이들은 변수 비교와 유사하지만 이 경우 메모리 주소를 비교합니다.
