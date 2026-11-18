# 스택 (Stack)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-DST-003-DO |
| 유형 | D&O (개념) |
| 목적 | 스택의 정의, 연산, 용도를 설명하고 구현 코드의 정본 위치를 안내한다 |
| 확인 상태 | 미검증 (원본과 일반 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 정의

스택(stack)은 쌓아 놓은 더미처럼 한쪽 끝(top)에서만 삽입과 삭제가 일어나는 선형 자료구조다. 마지막에 넣은 요소가 가장 먼저 나오므로 후입선출(LIFO, Last-In First-Out)이라 한다.

## 2. 구성 요소

| 연산 | 동작 | 시간 복잡도 |
|---|---|---|
| push | top에 요소를 넣는다 | O(1) |
| pop | top의 요소를 꺼내 제거한다 | O(1) |
| peek | top의 요소를 제거하지 않고 읽는다 | O(1) |
| 임의 요소 탐색 | top부터 차례로 확인한다 | O(n) |

배열로도, 연결 리스트로도 구현한다. 배열 구현은 용량 초과(overflow) 검사가, 두 구현 모두 빈 스택에서의 pop(underflow) 검사가 필요하다.

## 3. 용도

* 프로그램 실행 중 함수 호출을 호출 스택으로 관리한다.
* 깊이 우선 탐색(DFS)과 트리의 비재귀 순회에서 되돌아갈 위치를 기억한다.
* 괄호 짝 검사, 후위 표기식 계산에 쓴다.

## 4. 구현 위치

중복을 피하려고 구현 코드는 한 곳에만 둔다.

| 내용 | 문서 |
|---|---|
| 배열 기반 스택 예제와 선형 구조 비교 | [선형 자료구조 개요 (Linear)](../overviews/datastructuresalgorithms/lineardatastructureoverview.md) |
| 연결 리스트 기반 스택 구현 | [연결 스택 구현 (MyStack.c)](../../reference-and-snippets/c-snippets/mystack.c.md), [연결 스택 헤더 (MyStack.h)](../../reference-and-snippets/c-snippets/mystack.h.md) |
| 스택을 쓰는 트리 순회 | [이진 트리 (Binary Tree)](binarytrees_kr.md) |

## 5. 참조

* [Stack Github](https://github.com/JJH0204/DevBasics/blob/main/markdown/DataStructure/stack.md)

## 6. 약어·용어

| 용어 | 뜻 |
|---|---|
| LIFO | Last-In First-Out. 후입선출 |
| overflow / underflow | 가득 찬 스택에 push, 빈 스택에 pop하는 오류 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 함수 호출이 스택으로 관리되는 이유를 재귀 호출 예로 설명한다.
- [ ] 스택을 배열과 연결 리스트로 구현할 때 각각 어떤 오류를 검사해야 하는지 적는다.
