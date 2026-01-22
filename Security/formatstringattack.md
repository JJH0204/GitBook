# FormatStringAttack

* 오래된 공격 기법
* 프로그래밍 언어에서 사용하는 포맷 스트링의 허점을 사용
* 최근에는 취약점을 개선한 함수를 사용해 보완

### 예제 코드

{% code title="vulnerable.c" %}
```c
#include <stdio.h>

int main()
{
    char *buffer = "jaeho\n";

    printf(buffer);

    return 0;
}
```
{% endcode %}

#### 포맷 스트링을 활용한 메모리 주소 검출

{% code title="memory_leak.c" %}
```c
#include <stdio.h>

int main()
{
    char *buffer = "jaeho\n%x\n"; // %x insert

    printf(buffer);

    return 0;
}
```
{% endcode %}

#### GDB를 활용한 디버깅

https://dining-developer.tistory.com/13

컴파일 옵션 추가: -g

`jaeho\n%x\n` 원래는 한줄의 문자열로 인식해야 하는데 `%x`가 양의 16진수를 입력 받도록 함수처럼 사용된다.

#### 포맷 스트링을 활용한 메모리 탐색

`jaeho\n%x\n%x\n%x\n%x\n%x\n` 가 저장되어 있는 메모리의 다음 주소들이 순차적으로 출력되는 것을 확인할 수 있다. 이렇게 메모리 주소를 공격자가 알 수 있게 되면 공격 대상이 될 수 있다.

### 포맷 스트링 공격을 막는 방법

(line9) 안전한 코드는 입력 받은 매개변수가 문자열로 정확하게 출력되었다.\
(line11) 안전하지 않은 코드의 경우 버퍼 사이즈를 넘어 출력을 실행하기 때문에 [SegmentationFault](file:///2237607/cs_basics/SegmentationFault.md)를 발생시킨다.

{% hint style="warning" %}
print 함수는 종류에 상관 없이 출력 시 포맷 스트링을 사용하도록 시큐어 코딩이 요구된다.
{% endhint %}
