# GDB 디버거 사용법

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-CMP-003-MP |
| 목적 | gdb를 설치하고 프로그램을 열어 함수의 어셈블리 코드와 메모리 값을 확인한다 |
| 적용 대상 | Linux (Ubuntu, RHEL 계열), x86-64. macOS는 lldb 권장(5절 구역 A 참고) |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 환경에서 gdb를 설치하거나 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 아직 실행해 확인하지 않았다. 사용자가 실행해 확인하면 `확인 상태`를 바꾼다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [디버거 개요 (Debugger)](debugger.md) | DEV-CMP-002-DO | 디버거 개념을 설명한다 |
| [GDB 명령어 표](gdbreference.md) | DEV-CMP-005-REF | 자주 쓰는 gdb 명령을 모아 둔다 |
| [Windows MinGW-w64 설치](mingww64installation.md) | DEV-CMP-004-MP | Windows에서 gdb를 함께 설치한다 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 터미널 | Linux 터미널 | |
| 2 | 관리자 권한 | `sudo` 사용 가능 | 설치에만 필요하다 |
| 3 | 디버깅할 실행 파일 | x86-64 ELF 파일 | 아래 예시의 파일 이름은 `<프로그램 이름>`으로 쓴다 |
| 4 | 네트워크 | 인터넷 연결 | 패키지를 내려받는다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: gdb는 프로그램을 실제로 실행한다. 출처를 모르는 실행 파일은 격리된 환경(가상 머신 등)에서만 연다.
{% endhint %}

{% hint style="info" %}
NOTE: 이 문서의 예시 실행 파일은 `gets` 함수를 호출한다. `gets`는 입력 길이를 검사하지 않아 버퍼 오버플로가 생기는 대표적인 함수다. 분석 연습용 코드이며 실제 서비스 코드에 쓰지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 터미널을 연다 | 프롬프트가 나타난다 |
| 2 | 디버깅할 실행 파일 경로를 확인한다: `ls <프로그램 이름>` | 파일 이름이 출력된다 |
| 3 | 소스 줄 단위 디버깅이 필요하면 `gcc -g -o <프로그램 이름> <소스 파일>`로 다시 컴파일한다 | `file <프로그램 이름>` 출력에 `with debug_info`가 있다 |

## 5. 절차

### A. gdb 설치

1. (5-A-01) 사용 중인 배포판에 맞는 명령을 입력한다.

| 환경 | 명령 |
|---|---|
| Ubuntu, Debian | `sudo apt install -y gdb` |
| Rocky, RHEL, Fedora | `sudo dnf install -y gdb` |
| macOS | gdb 대신 lldb를 쓴다. `xcode-select --install`로 명령줄 도구를 설치하면 `lldb`가 들어 있다 |

→ 결과: 설치가 오류 없이 끝나고 프롬프트로 돌아온다.

2. (5-A-02) 설치를 확인한다: `gdb --version` → 결과: `GNU gdb` 버전이 출력된다.

{% hint style="info" %}
NOTE: 원본 페이지는 `dnf install -y gdb`(RHEL 계열)만 안내했다. Ubuntu 명령과 macOS 안내는 이 개정에서 추가했다. macOS에서 gdb 설치와 코드 서명은 번거롭고 Apple Silicon은 지원이 제한적이므로 lldb를 권장한다. lldb 명령은 gdb와 이름이 다르다.
{% endhint %}

### B. 프로그램 열기

1. (5-B-01) 아래 명령을 입력한다.

```bash
gdb <프로그램 이름>
```

→ 결과: gdb 시작 문구가 출력되고 `(gdb)` 프롬프트가 나타난다.

출력 예시 (Rocky Linux, 디버그 정보 없는 파일):

```
GNU gdb (GDB) Rocky Linux 10.2-13.el9
Copyright (C) 2021 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-redhat-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<https://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from <프로그램 이름>...
(No debugging symbols found in <프로그램 이름>)
(gdb)
```

{% hint style="info" %}
NOTE: `(No debugging symbols found ...)`는 디버그 정보가 없다는 뜻이다. 어셈블리 단위로는 디버깅할 수 있다.
{% endhint %}

### C. 함수의 어셈블리 코드 확인

1. (5-C-01) `(gdb)` 프롬프트에 입력한다: `disas main` → 결과: `Dump of assembler code for function main:`으로 시작하는 목록이 출력된다.

출력 예시:

```asm
   0x0000000000401136 <+0>:     push   %rbp
   0x0000000000401137 <+1>:     mov    %rsp,%rbp
   0x000000000040113a <+4>:     sub    $0x110,%rsp
   0x0000000000401141 <+11>:    mov    %edi,-0x104(%rbp)
   0x0000000000401147 <+17>:    mov    %rsi,-0x110(%rbp)
   0x000000000040114e <+24>:    movq   $0x0,-0x100(%rbp)
   0x0000000000401159 <+35>:    movq   $0x0,-0xf8(%rbp)
   0x0000000000401164 <+46>:    movq   $0x0,-0xf0(%rbp)
   0x000000000040116f <+57>:    movq   $0x0,-0xe8(%rbp)
   0x000000000040117a <+68>:    movq   $0x0,-0xe0(%rbp)
   0x0000000000401185 <+79>:    movq   $0x0,-0xd8(%rbp)
   0x0000000000401190 <+90>:    movq   $0x0,-0xd0(%rbp)
   0x000000000040119b <+101>:   movq   $0x0,-0xc8(%rbp)
   0x00000000004011a6 <+112>:   movq   $0x0,-0xc0(%rbp)
   0x00000000004011b1 <+123>:   movq   $0x0,-0xb8(%rbp)
   0x00000000004011bc <+134>:   movq   $0x0,-0xb0(%rbp)
   0x00000000004011c7 <+145>:   movq   $0x0,-0xa8(%rbp)
   0x00000000004011d2 <+156>:   movq   $0x0,-0xa0(%rbp)
   0x00000000004011dd <+167>:   movq   $0x0,-0x98(%rbp)
   0x00000000004011e8 <+178>:   movq   $0x0,-0x90(%rbp)
   0x00000000004011f3 <+189>:   movq   $0x0,-0x88(%rbp)
   0x00000000004011fe <+200>:   movq   $0x0,-0x80(%rbp)
   0x0000000000401206 <+208>:   movq   $0x0,-0x78(%rbp)
   0x000000000040120e <+216>:   movq   $0x0,-0x70(%rbp)
   0x0000000000401216 <+224>:   movq   $0x0,-0x68(%rbp)
   0x000000000040121e <+232>:   movq   $0x0,-0x60(%rbp)
   0x0000000000401226 <+240>:   movq   $0x0,-0x58(%rbp)
   0x000000000040122e <+248>:   movq   $0x0,-0x50(%rbp)
   0x0000000000401236 <+256>:   movq   $0x0,-0x48(%rbp)
   0x000000000040123e <+264>:   movq   $0x0,-0x40(%rbp)
   0x0000000000401246 <+272>:   movq   $0x0,-0x38(%rbp)
   0x000000000040124e <+280>:   movq   $0x0,-0x30(%rbp)
   0x0000000000401256 <+288>:   movq   $0x0,-0x28(%rbp)
   0x000000000040125e <+296>:   movq   $0x0,-0x20(%rbp)
   0x0000000000401266 <+304>:   movq   $0x0,-0x18(%rbp)
   0x000000000040126e <+312>:   movq   $0x0,-0x10(%rbp)
   0x0000000000401276 <+320>:   movq   $0x0,-0x8(%rbp)
   0x000000000040127e <+328>:   mov    $0x402010,%edi
   0x0000000000401283 <+333>:   mov    $0x0,%eax
   0x0000000000401288 <+338>:   call   0x401030 <printf@plt> # 함수를 호출하는 명령어를 저장한 메모리 주소
   0x000000000040128d <+343>:   lea    -0x100(%rbp),%rax # 함수 존재
   0x0000000000401294 <+350>:   mov    %rax,%rdi
   0x0000000000401297 <+353>:   mov    $0x0,%eax
   0x000000000040129c <+358>:   call   0x401040 <gets@plt> # 함수 호출 명령어
   0x00000000004012a1 <+363>:   mov    $0x0,%eax
   0x00000000004012a6 <+368>:   leave
   0x00000000004012a7 <+369>:   ret
End of assembler dump.
```

2. (5-C-02) 출력을 읽는다. → 결과: `call` 줄에서 호출하는 함수(`printf@plt`, `gets@plt`)를 찾을 수 있다.

{% hint style="info" %}
NOTE: 어셈블리 코드를 읽으려면 어셈블리 언어를 알아야 한다. 위 예시의 `call` 줄 뒤 주석(`#`)은 설명용이며 실제 출력에는 없다.
{% endhint %}

### D. 메모리 값 확인

1. (5-D-01) 문자열이 놓인 주소를 찾는다. 위 예시에서 `printf`를 부르기 직전의 `mov $0x402010,%edi`가 문자열 주소 `0x402010`을 인자로 넘긴다.
2. (5-D-02) `(gdb)` 프롬프트에 입력한다: `x/s 0x402010` → 결과: 그 주소의 문자열이 출력된다.

{% hint style="warning" %}
CAUTION: `x/s`는 데이터 주소에 쓴다. 코드 주소(예: `call` 명령이 있는 `0x401288`)에 쓰면 명령어 바이트가 깨진 문자열로 출력된다. 원본 페이지의 예시는 코드 주소를 썼으므로 이 개정에서 데이터 주소 예시로 고쳤다.
{% endhint %}

### E. 종료

1. (5-E-01) `(gdb)` 프롬프트에 `q`를 입력한다. → 결과: gdb가 종료되고 셸 프롬프트로 돌아온다. (프로그램이 실행 중이면 종료 확인을 묻는다. `y`를 입력한다.)

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `gdb --version` | 버전이 출력된다 | `command not found`가 나오지 않는다 |
| 2 | `gdb <프로그램 이름>` 후 `disas main` | `main`의 어셈블리 목록이 출력된다 | `Dump of assembler code for function main:`이 보인다 |
| 3 | `q` | gdb가 종료된다 | 셸 프롬프트로 돌아온다 |

## 7. 복구

1. (7-01) gdb를 제거한다. Ubuntu는 `sudo apt remove -y gdb`, RHEL 계열은 `sudo dnf remove -y gdb`를 입력한다. → 결과: 제거 후 `gdb --version`이 `command not found`를 출력한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM MP 형식으로 재작성. Ubuntu·macOS 설치 안내, 준비·복구 절을 추가했다. `x/s` 예시를 데이터 주소로 정정했다. 명령 표는 DEV-CMP-005-REF로 분리했다 |
