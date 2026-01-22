# DynamicAnalysis

### 동적 분석

{% hint style="info" %}
프로그램을 실행시키면서 분석하는 방법
{% endhint %}

#### 장점

* 코드를 자세히 분석해보지 않고도 프로그램의 개략적인 동작을 파악할 수 있다.

#### 단점

* 분석 환경을 구축하기 어려울 수 있다.
* 난독화처럼 디버깅(동적 분석의 일종)을 방해하는 안티 디버깅(Anti Debugging) 기술이 있다.

```c
if (is_debugging()) // 디버깅인지 확인
  exit(-1); // 프로그램 종료
Func();
```

### 동적 분석의 예

* 윈도우의 대표적인 동적 분석 도구로 [디버거](file:///2237607/web/BrowserDevTools.md) 중 하나인 x64dbg가 있다.
* 아래 코드를 컴파일한 HelloWorld.exe를 x64dbg로 동적 분석하는 예시다.

{% code title="helloworld.c" %}
```c
#include <stdio.h>

int main()
{
  int n = 0x31337;
  printf("Hello World 0x%x\n", n);
  return 0;
}
```
{% endcode %}
