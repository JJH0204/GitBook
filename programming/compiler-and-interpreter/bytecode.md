# Bytecode

## 바이트코드란?

프로그래밍 언어로 작성된 코드가 중간 단계에서 변환된 이진 코드를 의미한다.&#x20;

완전한 기계어(머신 코드)가 아니라 가상 머신(Virtual Machine)에서 실행할 수 있도록 변환된 코드다.

***

## 바이트코드의 특징

1. 플랫폼 독립성 (independence)
2. 가상 머신에서 실행
3. 기계어보다 속도가 느릴 수 있다.
4. 보안성이 높다.

***

## 바이트코드를 사용하는 대표적인 언어

| 언어     | 사용되는 바이트코드                            | 실행환경                               |
| ------ | ------------------------------------- | ---------------------------------- |
| Java   | JVM 바이트코드                             | JVM (Java Virtual Machine)         |
| Python | Python 바이트코드 (.pyc)                   | CPython (Python interpreter)       |
| C#     | MSIL(Microsoft Intermediate Language) | .NET CLR (Common Language Runtime) |
| Kotlin | JVM 바이트코드                             | JVM (Java Virtual Machine)         |
| Scala  | JVM 바이트코드                             | JVM (Java Virtual Machine)         |

***

## 바이트코드의 동작 방식

1. Java 소스 코드 작성

```java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

2. 바이트코드로 컴파일 (javac HelloWorld.java)
   * Java 컴파일러(javac)가 .java 파일을 JVM 바이트코드(.class 파일)로 변환
3. JVM이 바이트코드를 실행 (java HelloWorld)
   * JVM 이 .class 파일을 읽고 실행
   * 실행 시 JIT(Just-In-Time) 컴파일러를 통해 일부 코드를 네이티브 코드로 변환하여 실행 속도를 최적화 한다.

***

## 바이트코드의 장점과 단점

| 장점                              | 단점                         |
| ------------------------------- | -------------------------- |
| 플랫폼 독립성 - 가상 머신만 있으면 어디서든 실행 가능 | 네이티브 코드보다 실행 속도가 느릴 수 있음   |
| 보안성이 뛰어남 (실행 전에 검증 가능)          | 가상 머신이 필요하므로 실행 환경을 구축해야 함 |
| 코드의 이동성이 높아 네트워크 전송이 용이         | JIT 컴파일이 없으면 속도 저하 가능      |

***

## 바이트코드 vs 기계어(머신코드)

| 비교항목    | 바이트코드                    | 기계어          |
| ------- | ------------------------ | ------------ |
| 실행환경    | 가상 머신에서 실행               | CPU에서 직접 실행  |
| 플랫폼 독립성 | 높음                       | 없음           |
| 실행 속도   | 상대적으로 느림                 | 빠름           |
| 예제      | Java 바이트코드, Python 바이트코드 | x86, ARM 기계어 |
