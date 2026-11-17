---
description: C 언어 기초 문법(변수, 조건문, 반복문, 함수, 배열, 문자열) 예제 모음
---

# C 언어 기초 (C Fundamentals)

C 언어의 기본 문법을 짧은 예제 코드로 정리한다. 문서 번호(Task ID)는 `PRG-CFD-<번호>-<유형>` 형식이다. 이 그룹의 문서는 모두 D&O(개념) + 예제 코드다. 예제는 [Learn-C.org](https://www.learn-c.org/) 연습 문제를 바탕으로 했다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-CFD-001-DO | 개념+코드 | [Hello World 예제](helloworld.md) | C 프로그램의 최소 구조를 확인한다 |
| PRG-CFD-002-DO | 개념+코드 | [변수와 자료형 (Variables)](variables-and-types.md) | 기본 자료형, 범위, boolean 표현을 확인한다 |
| PRG-CFD-003-DO | 개념+코드 | [조건문 (Conditions)](conditions.md) | `if`/`else` 분기를 확인한다 |
| PRG-CFD-004-DO | 개념+코드 | [반복문 (Loops)](loop.md) | `for`, `while`, `continue`, `break`를 확인한다 |
| PRG-CFD-005-DO | 개념+코드 | [함수 (Functions)](functions.md) | 함수 정의와 호출을 확인한다 |
| PRG-CFD-006-DO | 개념+코드 | [배열 (Arrays)](arrays.md) | 배열 선언, 접근, 경계를 확인한다 |
| PRG-CFD-007-DO | 개념+코드 | [문자열 (Strings)](strings.md) | C 문자열과 `<string.h>` 함수를 확인한다 |
| PRG-CFD-008-DO | 개념+코드 | [다차원 배열 (Multidim Arrays)](multidimensional-arrays.md) | 2차원 배열 선언과 순회를 확인한다 |

## 읽는 순서

1. PRG-CFD-001-DO에서 컴파일과 실행 흐름을 확인한다. 환경이 없으면 [VS Code C/C++ 환경 설정](../setup/intro.md)(PRG-CST-001-MP)을 먼저 한다.
2. PRG-CFD-002-DO부터 008까지 번호 순서로 읽는다.
3. 포인터는 [포인터와 메모리](../pointers-and-memory/README.md)에서 이어진다.

{% hint style="info" %}
NOTE: 이 그룹의 예제 코드는 읽고 정정한 것이며 이 환경에서 컴파일·실행하지 않았다. 각 문서의 출력은 코드를 읽고 계산한 값이다.
{% endhint %}
