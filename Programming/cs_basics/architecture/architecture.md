# 컴퓨터 구조 개요 (Architecture)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-ARC-001-DO |
| 유형 | D&O (개념) |
| 목적 | 컴퓨터 구조의 계층과 이 그룹 문서의 위치를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 일반 컴퓨터 구조 교재 지식을 정리한 것이며 출처를 다시 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 제목과 빈 헤더 4개(범용, 세그먼트, 플래그, 명령어 포인터 레지스터)뿐이었다. 레지스터 설명은 [PRG-ARC-012-DO](x8664architecture.md)에 있어 이 문서에서는 위치만 안내한다.
{% endhint %}

## 1. 목적

컴퓨터 구조(Computer Architecture)는 하드웨어와 소프트웨어가 만나는 경계를 설계하는 분야다. 이 문서는 구조를 계층으로 나누어, 각 계층을 설명하는 문서가 어디에 있는지 알려 준다.

## 2. 구성 요소

### 2.1 구조의 계층

| 계층 | 설명 | 문서 |
|---|---|---|
| 응용 프로그램, 운영체제 | 고급 언어로 작성되고 컴파일되어 기계어가 된다 | [PRG-ARC-003-DO](assemble.md), [PRG-ARC-004-DO](assembly-language.md) |
| 명령어 집합 구조 (ISA) | CPU가 해석하는 명령어와 레지스터의 규격. 소프트웨어가 보는 하드웨어의 경계다 | [PRG-ARC-010-DO](instructionsetarchitecture.md), [PRG-ARC-012-DO](x8664architecture.md) |
| 마이크로아키텍처 | ISA를 실제 회로로 구현하는 방식(파이프라인, 캐시 등) | [PRG-ARC-007-DO](computerarchitecture.md) |
| 기능 구조 | CPU, 메모리, 입출력 장치, 버스의 구성 | [PRG-ARC-011-DO](vonneumannarchitecture.md), [PRG-ARC-005-DO](cpu.md), [PRG-ARC-006-DO](bus.md) |

### 2.2 x86-64 레지스터 종류

| 종류 | 설명 위치 |
|---|---|
| 범용 레지스터 | [PRG-ARC-012-DO](x8664architecture.md) 범용 레지스터 절 |
| 세그먼트 레지스터 | [PRG-ARC-012-DO](x8664architecture.md) 세그먼트 레지스터 절 |
| 플래그 레지스터 | [PRG-ARC-012-DO](x8664architecture.md) 플래그 레지스터 절 |
| 명령어 포인터 레지스터 | [PRG-ARC-012-DO](x8664architecture.md) 명령어 포인터 절 |

## 3. 동작 원리

소프트웨어는 ISA로 표현된 명령어 열로 CPU에 전달된다. 마이크로아키텍처가 이 명령어를 하드웨어에서 실행한다. 같은 ISA를 구현한 CPU는 마이크로아키텍처가 달라도 같은 프로그램을 실행한다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| ISA | Instruction Set Architecture. 명령어 집합 구조 |
| CPU | Central Processing Unit. 중앙처리장치 |
| 마이크로아키텍처 | ISA를 구현하는 CPU 내부 설계 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [README.md](README.md) | | 컴퓨터 구조 그룹 목차 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] ISA와 마이크로아키텍처의 차이를 내 말로 설명해 본다.
- [ ] 내가 쓰는 컴퓨터(또는 폰)의 CPU는 어떤 ISA를 쓰는지 찾아 적어 본다.
