# 운영체제와 메모리 (OS Memory)

운영체제가 프로세스, 메모리, 실행 파일을 다루는 방식을 정리한다. 문서 번호(Task ID)는 `PRG-<그룹>-<번호>-<유형>` 형식이며 그룹별 약어는 각 하위 그룹 README에 있다.

## 하위 그룹

| 그룹 | 폴더 | 다루는 내용 |
|---|---|---|
| 메모리 관리 | [메모리 관리](memory-management/README.md) | 기억장치, 메모리 세그먼트·레이아웃, 운영체제 개요, 세그멘테이션 결함 |
| 동시성 및 동기화 (PRG-CON) | [동시성 및 동기화](concurrency-and-synchronization/README.md) | 병행 프로세스, 컨텍스트, PCB, 스레드, 임계 구역, 동기화 도구, 스케줄링 |
| 실행 파일 및 링킹 (PRG-EXL) | [실행 파일 및 링킹](executables-and-linking/README.md) | 정적·동적 링크, DLL, ELF, 링커와 로더 |
| Windows 내부 구조 | [Windows 내부 구조](windows-internals/README.md) | Windows 메모리 레이아웃, 가상 메모리 시스템 파일 |

## 읽는 순서

1. 메모리 관리로 프로세스의 메모리 구조를 익힌다.
2. 동시성 및 동기화에서 프로세스, 스레드, 경쟁 상태와 동기화를 읽는다.
3. 실행 파일 및 링킹에서 코드가 실행 파일이 되고 메모리에 올라가는 과정을 읽는다.
4. Windows 내부 구조는 Windows 환경을 다룰 때 읽는다.
