# Link

> 여러 목적 파일들을 연결하여 실행 가능한 바이너리로 만드는 과정

{% code title="hello-world.c" %}
```c
// Name: hello-world.c
// Compile: gcc -o hello-world hello-world.c

#include <stdio.h>

int main() { printf("Hello, world!"); }
```
{% endcode %}

위 코드를 예시로 링크가 필요한 이유를 설명할 수 있다.

* `main()`에서 호출한 `printf` 함수의 정의는 `hello-world.c` 파일에는 없다.
* `printf()`는 gcc 기본 라이브러리 경로의 `libc`라는 공유 라이브러리에 존재한다.
* 링커는 바이너리가 `printf()`를 호출하면 `libc`의 함수가 실행되도록 연결(링크)해준다.
* 링크를 거치면 실행할 수 있는 프로그램이 완성된다.

{% code title="링크 예시 (쉘)" %}
```sh
$ gcc add.o -o add -Xlinker --unresolved-symbols=ignore-in-object-files
$ file add
add: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/l, ...
```
{% endcode %}

다음은 `add.o`를 링크하는 명령어다.

* 링크 과정에서 `main` 함수를 찾는데, `add`의 소스 코드에는 `main` 함수의 정의가 없음으로 에러가 발생할 수 있다.
* 에러를 방지하기 위해 `--unresolved-symbols`를 컴파일 옵션에 추가한다.
