---
description: 포인터, 포인터 연산, 참조에 의한 전달, 동적 메모리 할당, static 예제 모음
---

# 포인터와 메모리 (Pointers)

C의 포인터와 메모리 관리를 예제 코드로 정리한다. 문서 번호(Task ID)는 `PRG-PTR-<번호>-<유형>` 형식이다. 이 그룹의 문서는 모두 D&O(개념) + 예제 코드다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-PTR-001-DO | 개념+코드 | [포인터 기본 (Pointers)](pointers.md) | 주소 연산자 `&`와 역참조 `*`를 확인한다 |
| PRG-PTR-002-DO | 개념+코드 | [배열과 포인터 (Pointers)](arrays-and-pointers.md) | 배열 이름과 포인터의 관계, 동적 2차원 배열을 확인한다 |
| PRG-PTR-003-DO | 개념+코드 | [포인터 연산 상세 (Arithmetics)](pointer-arithmetics_kr.md) | 포인터에 `++`, `--`, `+`, `-`를 적용할 때 이동 단위를 확인한다 |
| PRG-PTR-004-DO | 개념+코드 | [참조에 의한 전달 (Call by Ref)](function-arguments-by-reference.md) | 포인터로 호출한 쪽 변수를 바꾸는 방법을 확인한다 |
| PRG-PTR-005-DO | 개념+코드 | [동적 메모리 할당 (Allocation)](dynamic-allocation.md) | `malloc`과 `free`의 사용 규칙과 오류 유형을 확인한다 |
| PRG-PTR-006-DO | 개념+코드 | [정적 변수 및 함수 (Static)](static.md) | `static` 지역 변수와 내부 링키지를 확인한다 |

## 읽는 순서

1. [C 언어 기초](../c-fundamentals/README.md)의 배열과 함수를 먼저 읽는다.
2. PRG-PTR-001-DO부터 006까지 번호 순서로 읽는다.
3. 관련 개념은 [Segmentation Fault](../../../cs_basics/os_memory/memory-management/segmentationfault.md), [메모리 할당 유효성 점검](../../../cs_basics/os_memory/memory-management/memoryallocationvaliditycheck.md)에서 이어진다.

{% hint style="info" %}
NOTE: 이 그룹의 예제 코드는 읽고 정정한 것이며 이 환경에서 컴파일·실행하지 않았다.
{% endhint %}
