---
description: 폰 노이만 구조, CPU, 버스, ISA, x86-64 레지스터, 어셈블리어, 어셈블 과정, MBR, 배포 단위
---

# 컴퓨터 구조 (Architecture)

컴퓨터 하드웨어 구조와 CPU 명령어 수준의 개념을 정리한다. 문서 번호(Task ID)는 `PRG-ARC-<번호>-<유형>` 형식이다. 이 그룹의 문서는 모두 D&O(개념·원리)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-ARC-001-DO | 개념 | [컴퓨터 구조 개요 (Architecture)](architecture.md) | 구조의 계층(소프트웨어, ISA, 마이크로아키텍처)과 이 그룹의 문서 위치를 파악한다 |
| PRG-ARC-002-DO | 개념 | [애플리케이션 배포 단위](applicationdeploymentunit.md) | 실행 파일, 라이브러리, 패키지, 컨테이너, VM 이미지의 차이를 구분한다 |
| PRG-ARC-003-DO | 개념 | [어셈블 과정 (Assemble)](assemble.md) | 어셈블리 코드가 목적 파일(ELF)이 되는 과정을 16진수 덤프로 읽는다 |
| PRG-ARC-004-DO | 개념 | [어셈블리어 기초 (Assembly)](assembly-language.md) | 명령어 형식, Intel·AT&T 문법, 함수 프롤로그·에필로그를 읽는다 |
| PRG-ARC-005-DO | 개념 | [중앙처리장치 (CPU)](cpu.md) | CPU 구성 요소와 명령어 사이클을 이해한다 |
| PRG-ARC-006-DO | 개념 | [시스템 버스 (Bus)](bus.md) | 데이터·주소·제어 버스의 역할과 주소 공간의 관계를 이해한다 |
| PRG-ARC-007-DO | 개념 | [컴퓨터 구조 설계](computerarchitecture.md) | 기능 구조, ISA, 마이크로아키텍처, DMA의 위치를 구분한다 |
| PRG-ARC-008-DO | 개념 | [컴퓨터 과학 개론 (CS)](computerscience.md) | CS 기초 주제와 해당 문서 위치를 찾는다 |
| PRG-ARC-009-DO | 개념 | [마스터 부트 레코드 (MBR)](mbr.md) | MBR의 구조, 시그니처, 한계를 이해한다 |
| PRG-ARC-010-DO | 개념 | [명령어 집합 구조 (ISA)](instructionsetarchitecture.md) | ISA 종류와 n비트 아키텍처의 의미를 구분한다 |
| PRG-ARC-011-DO | 개념 | [폰 노이만 구조 (Von Neumann)](vonneumannarchitecture.md) | 프로그램 내장 방식, 폰 노이만 병목, 하버드 구조와의 차이를 이해한다 |
| PRG-ARC-012-DO | 개념 | [x86-64 아키텍처 및 레지스터](x8664architecture.md) | x86-64 레지스터, 호출 규약, 플래그를 찾는다 |

## 읽는 순서

1. PRG-ARC-011-DO, PRG-ARC-005-DO, PRG-ARC-006-DO로 하드웨어의 기본 구성을 본다.
2. PRG-ARC-010-DO, PRG-ARC-012-DO로 ISA와 x86-64 레지스터를 본다.
3. PRG-ARC-004-DO, PRG-ARC-003-DO로 어셈블리와 목적 파일을 읽는다.
