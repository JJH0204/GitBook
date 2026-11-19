---
description: Windows 프로세스 메모리 레이아웃(PE 섹션)과 가상 메모리 시스템 파일을 다룬다
---

# [생성형 AI] Windows 내부 구조 (Internals)

Windows 실행 파일(PE)의 섹션 구성, 프로세스 메모리 레이아웃, 가상 메모리 관련 시스템 파일을 정리한다. 문서 번호(Task ID)는 `PRG-WIN-<번호>-<유형>` 형식이다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| 유형 | 그룹 README (안내) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (하위 문서 목록과 링크를 기준으로 작성했으며 본문 내용을 새로 검증하지 않았다) |

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-WIN-001-DO | D&O + 예제 | [Windows PE 메모리 레이아웃](windowsmemorylayout.md) | PE 섹션과 스택·힙의 구성과 권한을 확인한다 |
| PRG-WIN-002-REF | REF | [가상 메모리 시스템 파일](windowssystemfile.md) | pagefile.sys, hiberfile.sys, swapfile.sys의 용도를 찾는다 |
| PRG-WIN-003-REF | REF | [Windows Server 내부 구조](windowserver.md) | 서버 구축 관련 문서 위치를 찾는다 |

## 읽는 순서

1. [메모리 레이아웃](../memory-management/memorylayout.md)(PRG-MEM-002-DO)으로 일반 구조를 본다.
2. PRG-WIN-001-DO로 Windows PE 구조를 본다.
3. PRG-WIN-002-REF로 가상 메모리 파일을 확인한다.

## 이 그룹이 다루는 것

Windows 프로그램이 메모리에서 어떻게 배치되는지, 가상 메모리를 지원하는 시스템 파일이 무엇인지를 다룬다. 일반 메모리 레이아웃을 먼저 익히고 Windows 고유의 구조(PE 섹션, 페이지 파일)를 비교하며 읽는다.

## 선수 지식과 핵심 용어

* 선수 지식: 프로세스 메모리 영역(코드, 데이터, 힙, 스택)의 개념.
* PE(Portable Executable): Windows 실행 파일 형식.
* 섹션(section): PE 파일 안에서 코드나 데이터를 나누는 단위(예: `.text`, `.data`).
* 가상 메모리: 프로세스마다 독립된 주소 공간을 제공하고 물리 메모리와 디스크를 함께 쓰는 방식.
* `pagefile.sys`: 물리 메모리가 부족할 때 쓰는 디스크 영역. `hiberfile.sys`: 최대 절전 모드 저장 파일. `swapfile.sys`: 최신 앱용 스왑 파일.
