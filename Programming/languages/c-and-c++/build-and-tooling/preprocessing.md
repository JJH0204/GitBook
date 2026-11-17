# 전처리 과정 (Preprocessing)

컴파일러가 소스 코드를 어셈블리어로 컴파일하기 전에, 필요한 형식으로 가공하는 과정\
(언어마다 조금 다름)

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

`#include`는 지정한 헤더 파일의 내용을 그 자리에 텍스트로 삽입한다. 여러 소스 파일을 따로 컴파일한 오브젝트를 합치는 일은 전처리가 아니라 링크 단계에서 한다.
{% endstep %}
{% endstepper %}

gcc에서는 `-E` 옵션을 사용하여 소스 코드의 전처리 결과를 확인할 수 있다.

```sh
$ gcc -E add.c > add.i
$ cat add.i
```

add.c를 add.i로 전처리한 결과:

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

* 주석이 사라지고 매크로가 값으로 치환되었다.
* `add.h`의 내용이 `#include`에 의해 삽입되었다.
