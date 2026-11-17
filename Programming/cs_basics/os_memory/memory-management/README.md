---
description: 기억장치, 메모리 레이아웃, 가상 메모리, 페이지 교체, 세그멘테이션 결함, 메모리 포렌식을 다룬다
---

# 메모리 관리 (Memory Mgmt)

기억장치의 종류부터 프로세스 메모리 구조, 가상 메모리와 페이지 교체, 메모리 오류, 메모리 덤프 분석까지 정리한다. 문서 번호(Task ID)는 `PRG-MEM-<번호>-<유형>` 형식이다. D&O는 개념 설명, TS는 문제 해결, MP는 절차다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-MEM-001-DO | D&O | [기억장치 개요 (Memory)](memory.md) | 주기억장치, 보조기억장치, 메모리 계층을 구분한다 |
| PRG-MEM-002-DO | D&O | [메모리 레이아웃 (Layout)](memorylayout.md) | 프로세스 가상 주소 공간의 구획과 성장 방향을 확인한다 |
| PRG-MEM-003-DO | D&O | [메모리 세그먼트 (Segment)](memorysegment.md) | 프로그램 세그먼트와 세그멘테이션 기법을 구분한다 |
| PRG-MEM-004-TS | TS | [세그멘테이션 결함 상세 (Segfault)](segmentationfault.md) | 세그멘테이션 결함의 원인을 찾아 고친다 |
| PRG-MEM-005-DO | D&O + 예제 | [메모리 할당 유효성 검사](memoryallocationvaliditycheck.md) | `malloc` 실패를 처리하는 코드를 작성한다 |
| PRG-MEM-006-DO | D&O | [운영체제 개요 (OS)](operating_system.md) | 커널, 셸, 시스템 콜, 운영체제 종류를 구분한다 |
| PRG-MEM-007-MP | MP | [Volatility 메모리 분석 도구](memorycheck.md) | Volatility 3를 설치하고 메모리 덤프를 분석한다 |
| PRG-MEM-008-DO | D&O | [가상 메모리와 페이징](virtualmemory.md) | 가상 주소 변환, 페이징, 세그멘테이션, 단편화를 설명한다 |
| PRG-MEM-009-DO | D&O + 예제 | [페이지 교체 알고리즘](pagereplacement.md) | FIFO, LRU, Optimal의 페이지 부재 횟수를 계산한다 |

## 읽는 순서

1. PRG-MEM-006-DO로 운영체제가 메모리를 관리하는 이유를 본다.
2. PRG-MEM-001-DO, PRG-MEM-002-DO, PRG-MEM-003-DO 순서로 메모리 구조를 본다.
3. PRG-MEM-008-DO, PRG-MEM-009-DO로 가상 메모리의 동작을 본다.
4. PRG-MEM-004-TS, PRG-MEM-005-DO로 코드 수준의 메모리 오류를 다룬다.
5. 메모리 덤프 분석이 필요하면 PRG-MEM-007-MP를 수행한다.
