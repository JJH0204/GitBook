# GDB 명령어 표

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-CMP-005-REF |
| 유형 | REF (명령어 표) |
| 목적 | 자주 쓰는 gdb 명령과 사용 예를 참조한다 |
| 확인 상태 | 미검증 (gdb 공식 문서를 기준으로 정리했으며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 설치와 실행 절차는 DEV-CMP-003-MP를 따른다. 개념은 DEV-CMP-002-DO를 따른다. 이 문서는 원본 페이지에 없던 새 문서다.
{% endhint %}

## 1. 실행 제어

| 명령 | 줄임말 | 역할 | 예 |
|---|---|---|---|
| `run [인자]` | `r` | 프로그램을 시작한다 | `run` |
| `break <위치>` | `b` | 중단점을 만든다. 위치는 함수 이름, 줄 번호, `*<주소>` | `break main` |
| `continue` | `c` | 다음 중단점까지 실행한다 | `continue` |
| `next` | `n` | 한 줄 실행한다. 함수 안으로 들어가지 않는다 | `next` |
| `step` | `s` | 한 줄 실행한다. 함수 안으로 들어간다 | `step` |
| `nexti`, `stepi` | `ni`, `si` | 어셈블리 명령 한 개를 실행한다 | `stepi` |
| `finish` | | 현재 함수가 끝날 때까지 실행한다 | `finish` |
| `watch <변수>` | | 값이 바뀌면 멈춘다 | `watch count` |
| `info breakpoints` | `i b` | 중단점 목록을 본다 | |
| `delete <번호>` | `d` | 중단점을 지운다 | `delete 1` |
| `quit` | `q` | gdb를 종료한다 | `q` |

## 2. 상태 확인

| 명령 | 역할 | 예 |
|---|---|---|
| `disas <함수>` | 함수의 어셈블리 코드를 본다 | `disas main` |
| `info registers` | 레지스터 값을 본다 | `info registers rip` |
| `print <식>` | 변수나 식의 값을 본다 (`p`) | `print count` |
| `x/<개수><형식><단위> <주소>` | 메모리를 본다 | `x/s 0x402010`, `x/8xb $rsp` |
| `bt` | 호출 스택(backtrace)을 본다 | `bt` |
| `info locals` | 현재 함수의 지역 변수를 본다 | |
| `list` | 소스 코드를 본다. 디버그 정보(`-g`)가 필요하다 | `list main` |

### `x` 명령의 형식 글자

| 글자 | 뜻 |
|---|---|
| `s` | 문자열 |
| `x` | 16진수 |
| `d` | 10진수 |
| `i` | 어셈블리 명령 |
| `b`, `h`, `w`, `g` | 단위: 1, 2, 4, 8바이트 |

## 3. 설정

| 명령 | 역할 |
|---|---|
| `set disassembly-flavor intel` | 어셈블리를 Intel 문법으로 표시한다. 기본은 AT&T 문법(`mov %rsp,%rbp`)이다 |
| `help <명령>` | 명령 도움말을 본다 |

## 4. 사용 예

```
(gdb) break main
(gdb) run
(gdb) next
(gdb) print count
(gdb) bt
(gdb) continue
```

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [GDB 디버거 사용법](gdb.md) | DEV-CMP-003-MP | gdb 설치와 실행 절차 |
| [디버거 개요 (Debugger)](debugger.md) | DEV-CMP-002-DO | 디버거 개념 |

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 새로 작성. gdb.md에 있던 `disas`, `x/s`, `q` 명령과 일반적인 gdb 명령을 표로 정리했다 |
