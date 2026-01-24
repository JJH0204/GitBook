# SegmentationFault

[wiki link](https://ko.wikipedia.org/wiki/%EC%84%B8%EA%B7%B8%EB%A9%98%ED%85%8C%EC%9D%B4%EC%85%98_%EC%98%A4%EB%A5%98)

{% hint style="info" %}
세그멘테이션 오류(또는 세그멘테이션 결함)는 컴퓨터 소프트웨어의 실행 중에 일어날 수 있는 특수한 오류\
세그멘테이션 위반, 세그멘테이션 실패로 불리기도 하며 세그폴트(Segfault)로 줄여 쓴다.
{% endhint %}

### 세그멘테이션 오류(Segmentation Fault)란?

### 원인

* 허용되지 않는 메모리 영역에 접근을 시도하거나, 허용되지 않은 방법으로 메모리 영역에 접근을 시도할 경우 발생\
  (읽기 전용 영역에 어떤 내용을 쓰려고 시도하거나, 운영 체제에서 사용하는 영역에 다른 내용을 덮어쓰려 하는 경우)
* 운영 체제에서 사용하는 메모리 관리 및 보호의 한 기법

### 예제

다음은 메모리 보호를 사용하는 플랫폼에서 세그멘테이션 오류를 만드는 [ANSI C](https://ko.wikipedia.org/wiki/ANSI_C) 코드이다.

```
const char *s = "hello world";
*s = 'H';
```

위 코드를 포함하는 프로그램이 [컴파일](https://ko.wikipedia.org/wiki/%EC%BB%B4%ED%8C%8C%EC%9D%BC)되면, 문자열 "hello world"는 이 프로그램에서 읽기 전용이 된다. 프로그램이 로드되었을 때, 운영 체제는 이 문자열과 상수 데이터를 메모리의 읽기 전용 세그먼트에 배치한다. 프로그램이 실행되면, 변수 's'는 이 문자열의 위치를 가리키게 되고, 'H'라는 문자열을 변수 s를 통해 메모리에 기록하려는 시도는 곧 세그멘테이션 오류를 일으키게 된다.

[OpenBSD](https://ko.wikipedia.org/wiki/OpenBSD) 4.0에서 이런 프로그램을 컴파일하고 실행하면 다음과 같은 [런타임 오류](https://ko.wikipedia.org/wiki/%EB%9F%B0%ED%83%80%EC%9E%84_%EC%98%A4%EB%A5%98)가 발생한다.

```
$ gcc segfault.c -g -o segfault
$ ./segfault
Segmentation fault
```

[GDB](https://ko.wikipedia.org/wiki/GDB)(GNU 디버거)를 통한 추적 결과:

```
Program received signal SIGSEGV, Segmentation fault.
0x1c0005c2 in main () at segfault.c:6
6               *s = 'H';
```

대조적으로, [GNU/Linux](https://ko.wikipedia.org/wiki/GNU/Linux)에서 [GCC](https://ko.wikipedia.org/wiki/GNU_%EC%BB%B4%ED%8C%8C%EC%9D%BC%EB%9F%AC_%EB%AA%A8%EC%9D%8C) 4.1.1로 같은 시도를 하면 컴파일 에러가 발생한다.

```
$ gcc segfault.c -g -o segfault
segfault.c: In function ‘main’:
segfault.c:4: error: assignment of read-only location
```

즉 세그멘테이션 경고가 발생하는 조건이나 그것을 사용자에게 알려주는 방법은 운영 체제에 따라서도 다르다.

[널 포인터](https://ko.wikipedia.org/wiki/%EB%84%90_%ED%8F%AC%EC%9D%B8%ED%84%B0) 역참조(주소 '0'을 참조하는 포인터인 널 포인터를 통한 읽기나 쓰기로, C에서 '아무것도 가리키지 않는 포인터'를 나타내기 위해서 또는 오류 지시자로 사용)는 흔히 일어나는 오류이기 때문에, 대부분의 운영 체제는 메모리의 첫 페이지(주소 0에서 시작하는)를 살피며, 따라서 여기에 접근하면 세그멘테이션 오류이 발생한다.

```
int* ptr = (int*) 0x00000000;
*ptr = 1;
```

위 샘플 코드는 메모리 주소 0x00000000에 접근하는 포인터를 생성하고, 그 곳에 값을 할당하려고 시도한다. 이런 행동은 많은 컴파일러에서 세그멘테이션 오류를 일으킨다.
