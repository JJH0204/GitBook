---
description: Windows 프로세스 메모리 레이아웃(PE 섹션)과 가상 메모리 시스템 파일을 다룬다
---

# Windows 내부 구조 (Internals)

Windows 실행 파일(PE)의 섹션 구성, 프로세스 메모리 레이아웃, 가상 메모리 관련 시스템 파일을 정리한다. 문서 번호(Task ID)는 `PRG-WIN-<번호>-<유형>` 형식이다.

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
