# Binary

{% hint style="info" %}
키워드

* 기계어(Machine Language)
* 어셈블리어(Assembly Language)
* 어셈블러(Assembler)
* 컴파일러(Compiler)
* 고급 언어(High-Level Language)
* 저급 언어(Low-Level Language)
{% endhint %}

## 프로그램과 컴파일

### 프로그램(Program)

***

* 연산 장치가 수행해야 할 동작을 정의한 일종의 문서
* 사용자가 정의한 프로그램을 해석하여 명령어를 처리할 수 있는 연산 장치를 programmable\
  그렇지 않은 연산 장치를 non-programmable라고 한다.
* 과거에 내부 저장 장치가 없어 직접 전선을 연결하거나 천공 카드(punched card)에 기록해 사용하는 방법을 사용했다.
* 기존의 컴퓨터의 단점을 개선한 Stored-Program Computer가 상용화되고 프로그램이 저장 장치에 이진(Binary) 형태로 저장되었다.
* 이후 프로그램을 바이너리(Binary)라고 부르기도 한다.

### 컴파일러와 인터프리터

***

* **프로그래밍 언어(Programming Language)**: 프로그램을 개발하기 위해 사용하는 언어
* **소스 코드(Source Code)**: CPU가 수행해야 할 명령들을 프로그래밍 언어로 작성한 것
* **컴파일(Compile)**: 소스 코드를 기계어 형식으로 번역하는 행위
* **컴파일러(Compiler)**: 컴파일을 하는 소프트웨어 (GCC, Clang, MSVC 등)
* Python, Javascript 등 언어는 컴파일을 필요로 하지 않는다.
  * 사용자의 입력, 작성한 스크립트를 그때 그때 번역하는 **인터프리팅(Interpreting)** 방식으로 실행
  * 인터프리팅을 수행하는 소프트웨어를 **인터프리터(Interpreter)** 라고 한다.

### 컴파일 과정

***

* [C 언어](/broken/pages/f5ef16332e72d62bbd8ce2abb86d1ca7f93c59dd)로 작성된 코드는 일반적으로 전처리(Preprocess) > 컴파일(Compile) > 어셈블(Assemble) > 링크(Link)의 과정을 거쳐 바이너리로 번역된다.

{% stepper %}
{% step %}
### 전처리 (Preprocess)

헤더 포함, 매크로 전개 등 소스 코드 전처리를 수행합니다.
{% endstep %}

{% step %}
### 컴파일 (Compile)

전처리된 소스 파일을 어셈블리어 등 중간 목적 코드로 변환합니다.
{% endstep %}

{% step %}
### 어셈블 (Assemble)

어셈블리어를 기계어(오브젝트 코드)로 변환합니다.
{% endstep %}

{% step %}
### 링크 (Link)

여러 오브젝트 파일과 라이브러리를 결합해 실행 가능한 바이너리(또는 라이브러리)를 생성합니다.
{% endstep %}
{% endstepper %}

예제 코드:

{% code title="add.c" %}
```c
// Name: add.c

#include "add.h"

#define HI 3

int add(int a, int b) { return a + b + HI; }  // return a+b

```
{% endcode %}

{% code title="add.h" %}
```c
// Name: add.h

int add(int a, int b);

```
{% endcode %}

{% hint style="info" %}
컴파일의 정확한 의미는 어떤 언어로 작성된 소스 코드를 다른 언어의 목적 코드(Object Code)로 번역하는 것입니다.\
이 맥락에서, 소스 코드를 어셈블리어로, 또는 소스코드를 기계어로 번역하는 것 모두 컴파일이라 볼 수 있습니다.
{% endhint %}

## 디스어셈블과 디컴파일

### 디스어셈블 (Disassemble)

***

바이너리를 분석하려면 바이너리를 읽을 수 있어야 합니다.\
컴파일된 바이너리는 기계어로 작성되어 있어 이해하기 어렵습니다.\
어셈블의 역과정을 통해 이를 가능하게 하려고 하며 이를 디스어셈블이라 합니다.

디스어셈블 결과:

```
$ objdump -d ./add -M intel
...
000000000000061a <add>:
 61a:   55                      push   rbp
 61b:   48 89 e5                mov    rbp,rsp
 61e:   89 7d fc                mov    DWORD PTR [rbp-0x4],edi
 621:   89 75 f8                mov    DWORD PTR [rbp-0x8],esi
 624:   8b 55 fc                mov    edx,DWORD PTR [rbp-0x4]
 627:   8b 45 f8                mov    eax,DWORD PTR [rbp-0x8]
 62a:   01 d0                   add    eax,edx
 62c:   5d                      pop    rbp
 62d:   c3                      ret
 62e:   66 90                   xchg   ax,ax
...
```

### 디컴파일 (Decompil)

***

* 디스어셈블 기술을 통해 바이너리를 읽고 분석할 수 있게 되었지만 큰 바이너리의 동작은 어셈블리 코드만으로 이해하기 어렵다.
* 어셈블리어보다 고급 언어로 바이너리를 번역하는 디컴파일러를 개발하게 되었다.

디컴파일과 디스어셈블의 차이:

* 어셈블리어와 기계어는 거의 일대일로 대응되어 오차가 없는 디스어셈블러를 개발할 수 있다.
* 고급 언어와 어셈블리어 사이에는 이런 대응 관계가 없다.
* 디컴파일러는 바이너리의 소스 코드와 동일한 코드를 생성하지 못한다.
* 그러나, 이 오차가 바이너리의 동작을 왜곡하지는 않으며, 디스어셈블러를 사용하는 것보다 분석 효율을 압도적으로 높여주기 때문에, 디컴파일러를 사용할 수 있다면 반드시 디컴파일러를 사용하는 것이 유리하다.
* IDA Freeware, Hex Rays, Ghidra를 비롯한 뛰어난 디컴파일러들이 개발되어서 분석의 효율을 더욱 높여준다.
