---
description: 컴파일러/인터프리터 개요, 디버깅, GDB, MinGW 등
---

# 컴파일러 및 디버깅 (Compiler & Debug)

도구별 개념, 설치, 사용 흐름으로 정리한다. 문서 번호(Task ID)는 `DEV-CMP-<번호>-<유형>` 형식이다. 유형은 D&O(개념), MP(절차), TS(문제 해결), REF(표)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| DEV-CMP-001-DO | 개념 | [바이트코드 개념 (Bytecode)](bytecode.md) | 바이트코드와 가상 머신의 실행 순서를 이해한다 |
| DEV-CMP-002-DO | 개념 | [디버거 개요 (Debugger)](debugger.md) | 디버거가 보여 주는 정보와 기능을 이해한다 |
| DEV-CMP-003-MP | 절차 | [GDB 디버거 사용법](gdb.md) | gdb를 설치하고 어셈블리·메모리를 확인한다 |
| DEV-CMP-004-MP | 절차 | [Windows MinGW-w64 설치](mingww64installation.md) | Windows에 gcc와 gdb를 설치한다 |
| DEV-CMP-005-REF | 표 | [GDB 명령어 표](gdbreference.md) | 자주 쓰는 gdb 명령을 참조한다 |
| DEV-CMP-006-DO | 개념 | [[생성형 AI] gcc 빌드 4단계와 자주 쓰는 옵션](gcc-build-stages.md) | 전처리·컴파일·어셈블·링크와 gcc 옵션을 이해한다 |
| DEV-CMP-007-TS | 문제 해결 | [[생성형 AI] 컴파일·링크 오류 진단](build-error-diagnosis.md) | 대표 gcc 오류의 원인을 구분하고 고친다 |

컴파일러와 인터프리터의 차이는 [Programming 스페이스의 컴파일 문서](../../Programming/languages/c-and-c++/build-and-tooling/compile.md)를 참고한다.

## 읽는 순서

1. DEV-CMP-001-DO로 바이트코드와 실행 환경을 이해한다.
2. DEV-CMP-002-DO로 디버거 개념을 이해한다.
3. Windows라면 DEV-CMP-004-MP로 컴파일러를 설치한다.
4. DEV-CMP-003-MP로 gdb를 설치하고 실행한다.
5. DEV-CMP-005-REF로 명령을 찾아 쓴다.
