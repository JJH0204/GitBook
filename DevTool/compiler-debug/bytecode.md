# 바이트코드 개념 (Bytecode)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-CMP-001-DO |
| 유형 | D&O (개념·원리) |
| 목적 | 바이트코드가 무엇이고 어떤 순서로 만들어져 실행되는지 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 공식 설명을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 개념 설명이다. 디버거 개념은 DEV-CMP-002-DO를 따른다.
{% endhint %}

## 1. 목적

바이트코드(bytecode)는 소스 코드를 컴파일해 만든 중간 단계의 이진 코드다. 완전한 기계어(머신 코드)가 아니다. 가상 머신(Virtual Machine, VM)이 읽어 실행하도록 만든 코드다.

## 2. 구성 요소

| 번호 | 이름 | 위치 | 역할 |
|---|---|---|---|
| 1 | 소스 코드 | 개발자가 작성한 파일 (예: `.java`) | 사람이 읽는 프로그램이다 |
| 2 | 컴파일러 | 개발 PC (예: `javac`) | 소스 코드를 바이트코드로 바꾼다 |
| 3 | 바이트코드 파일 | 디스크 (예: `.class`, `.pyc`) | 가상 머신이 읽는 중간 코드다 |
| 4 | 가상 머신 | 실행 PC (예: JVM, CLR) | 바이트코드를 읽고 실행한다 |
| 5 | JIT 컴파일러 | 가상 머신 안 | 실행 중에 자주 쓰는 바이트코드를 네이티브 코드로 바꿔 속도를 높인다 |

### 대표 언어와 실행 환경

| 언어 | 사용되는 바이트코드 | 실행 환경 |
|---|---|---|
| Java | JVM 바이트코드 | JVM (Java Virtual Machine) |
| Python | Python 바이트코드 (`.pyc`) | CPython (Python 인터프리터) |
| C# | CIL (Common Intermediate Language) | .NET CLR (Common Language Runtime) |
| Kotlin | JVM 바이트코드 | JVM |
| Scala | JVM 바이트코드 | JVM |

{% hint style="info" %}
NOTE: C#의 중간 언어는 원래 MSIL(Microsoft Intermediate Language)이라 불렀다. 현재 공식 명칭은 CIL이다. 문서와 도구에 MSIL이라는 이름이 남아 있을 수 있다.
{% endhint %}

## 3. 동작 원리

Java를 예로 든다. 순서는 아래와 같다.

```
HelloWorld.java > javac > HelloWorld.class > JVM(+JIT) > 실행
```

1. 개발자가 Java 소스 코드를 작성한다.

```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

2. `javac HelloWorld.java`를 실행한다. javac가 `.java` 파일을 JVM 바이트코드(`.class` 파일)로 바꾼다.
3. `java HelloWorld`를 실행한다. JVM이 `.class` 파일을 읽고 실행한다.
4. 실행 중에 JIT(Just-In-Time) 컴파일러가 일부 코드를 네이티브 코드로 바꾼다. 실행 속도가 빨라진다.

### 특징

1. 플랫폼 독립성: 같은 바이트코드를 가상 머신이 있는 모든 OS에서 실행한다.
2. 가상 머신에서 실행한다.
3. 기계어보다 느릴 수 있다. JIT가 이 차이를 줄인다.
4. 실행 전에 검증(verification)할 수 있다. 가상 머신이 잘못된 바이트코드를 실행 전에 걸러 낸다.

{% hint style="warning" %}
CAUTION: 검증이 가능하다는 것은 보안이 높다는 뜻이 아니다. 바이트코드는 원본 구조를 많이 담고 있어 디컴파일(decompile)하기 쉽다. 원본 페이지의 "보안성이 높다"는 서술을 이 문서에서 정정했다.
{% endhint %}

### 장점과 단점

| 장점 | 단점 |
|---|---|
| 가상 머신만 있으면 어디서든 실행한다 | 네이티브 코드보다 느릴 수 있다 |
| 실행 전에 검증할 수 있다 | 가상 머신이 필요해 실행 환경을 갖춰야 한다 |
| 크기가 작고 이동하기 쉬워 네트워크로 보내기 쉽다 | JIT가 없으면 속도가 떨어질 수 있다 |

### 바이트코드와 기계어 비교

| 비교 항목 | 바이트코드 | 기계어 |
|---|---|---|
| 실행 환경 | 가상 머신 | CPU가 직접 실행 |
| 플랫폼 독립성 | 높다 | 없다 |
| 실행 속도 | 상대적으로 느리다 | 빠르다 |
| 예 | Java 바이트코드, Python 바이트코드 | x86, ARM 기계어 |

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 가상 머신 (Virtual Machine, VM) | 바이트코드를 읽어 실행하는 프로그램 |
| JVM | Java Virtual Machine |
| CLR | Common Language Runtime. .NET의 실행 환경 |
| CIL | Common Intermediate Language. C#의 중간 언어 (옛 이름 MSIL) |
| JIT | Just-In-Time. 실행 중에 네이티브 코드로 바꾸는 방식 |
| 네이티브 코드 | CPU가 직접 실행하는 기계어 |
| 디컴파일 | 컴파일된 코드를 사람이 읽는 코드로 되돌리는 일 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [디버거 개요 (Debugger)](debugger.md) | DEV-CMP-002-DO | 디버거 개념 |
| [GDB 디버거 사용법](gdb.md) | DEV-CMP-003-MP | 네이티브 코드를 gdb로 디버깅한다 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM D&O 형식으로 재작성. "보안성이 높다"를 "검증이 가능하다"로 정정하고 MSIL 표기를 CIL로 고쳤다. 구성 요소 표와 용어 표를 추가했다 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 바이트코드는 기계어와 무엇이 다르고, 왜 만드는가?
- [ ] JIT 컴파일러는 어떤 문제를 해결하는가?
- [ ] "검증이 가능하다"와 "보안이 높다"는 어떻게 다른가?
