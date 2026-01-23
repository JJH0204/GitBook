# Segmentation

[wiki link](https://ko.wikipedia.org/wiki/%EC%84%B8%EA%B7%B8%EB%A9%98%ED%85%8C%EC%9D%B4%EC%85%98_%EC%98%A4%EB%A5%98)

{% hint style="info" %}
세그멘테이션 오류(또는 세그멘테이션 결함)는 컴퓨터 소프트웨어의 실행 중에 일어날 수 있는 특수한 오류입니다.\
세그멘테이션 위반, 세그멘테이션 실패로 불리기도 하며 세그폴트(Segfault)로 줄여 쓴다.
{% endhint %}

### 원인

* 허용되지 않는 메모리 영역에 접근을 시도하거나, 허용되지 않은 방법으로 메모리 영역에 접근을 시도할 경우 발생\
  (예: 읽기 전용 영역에 쓰기를 시도하거나, 운영 체제에서 사용하는 영역에 덮어쓰기)
* 운영 체제의 메모리 관리 및 보호 기법에 의해 발생

### 예제

다음은 메모리 보호를 사용하는 플랫폼에서 세그멘테이션 오류를 만드는 [ANSI C](https://ko.wikipedia.org/wiki/ANSI_C) 코드이다.

{% code title="segfault.c" %}
```c
const char *s = "hello world";
*s = 'H';
```
{% endcode %}

이 프로그램이 컴파일되면 문자열 "hello world"는 읽기 전용이 된다. 프로그램이 로드될 때 운영 체제는 이 문자열과 상수 데이터를 메모리의 읽기 전용 세그먼트에 배치한다. 실행 중 변수 s는 이 문자열의 위치를 가리키고, 'H'를 통해 메모리에 기록하려는 시도는 세그멘테이션 오류를 일으킨다.

OpenBSD 4.0에서 이 프로그램을 컴파일하고 실행하면 다음과 같은 런타임 오류가 발생한다:

{% code title="터미널" %}
```bash
$ gcc segfault.c -g -o segfault
$ ./segfault
Segmentation fault
```
{% endcode %}

[GDB](https://ko.wikipedia.org/wiki/GDB)(GNU 디버거)를 통한 추적 결과:

{% code title="gdb" %}
```
Program received signal SIGSEGV, Segmentation fault.
0x1c0005c2 in main () at segfault.c:6
6               *s = 'H';
```
{% endcode %}

대조적으로, [GNU/Linux](https://ko.wikipedia.org/wiki/GNU/Linux)에서 [GCC](https://ko.wikipedia.org/wiki/GNU_%EC%BB%B4%ED%8C%8C%EC%9D%BC%EB%9F%AC_%EB%AA%A8%EC%9D%8C) 4.1.1로 같은 코드를 컴파일하면 컴파일 에러가 발생한다:

{% code title="컴파일 에러" %}
```bash
$ gcc segfault.c -g -o segfault
segfault.c: In function ‘main’:
segfault.c:4: error: assignment of read-only location
```
{% endcode %}

즉, 세그멘테이션 오류가 발생하는 조건이나 이를 사용자에게 알리는 방식은 운영 체제와 도구에 따라 다르다.

널 포인터 역참조(주소 0을 참조하는 포인터를 통한 읽기/쓰기)는 흔한 원인이다. 대부분의 운영 체제는 메모리의 첫 페이지(주소 0)를 보호하며, 여기에 접근하면 세그멘테이션 오류가 발생한다.

{% code title="널 포인터 예제" %}
```c
int* ptr = (int*) 0x00000000;
*ptr = 1;
```
{% endcode %}
