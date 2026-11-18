# Windows MinGW-w64 설치

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-CMP-004-MP |
| 목적 | Windows에 MinGW-w64 C/C++ 컴파일러(gcc, g++)와 gdb를 MSYS2로 설치하고 PATH에 등록한다 |
| 적용 대상 | Windows 10/11 64비트, 관리자 권한 없이 사용자 계정으로 설치 가능한 PC |
| 소요 시간 | 약 20분 (네트워크 속도에 따라 다르다) |
| 확인 상태 | 미검증 (MSYS2 공식 안내와 VS Code 공식 문서의 절차를 정리한 것이며 이 환경에서 설치하거나 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 아직 실행해 확인하지 않았다. 사용자가 실행해 확인하면 `확인 상태`를 바꾼다.
{% endhint %}

Windows에서 Visual Studio Code로 C/C++ 개발을 하려면 컴파일러가 먼저 필요하다. 이 문서는 그 초기 설정이다.

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [GDB 디버거 사용법](gdb.md) | DEV-CMP-003-MP | 설치한 gdb로 디버깅한다 |
| [GDB 명령어 표](gdbreference.md) | DEV-CMP-005-REF | gdb 명령 목록 |

외부 자료 (원본에 있던 링크):

* [MinGW-w64 - SourceForge](https://sourceforge.net/projects/mingw-w64/): 예전에는 이 사이트의 exe 설치 파일로 설치했다. 오랫동안 정상 운영되지 않아 현재는 권장하지 않는다.
* [MinGW-w64 직접 설치 방법 (블로그)](https://sooseongcom.com/post/MinGW-w64-HowToInstall): zip 파일을 직접 내려받아 설치하는 방법이다. 이 문서의 MSYS2 방식 대신 쓸 수 있다.

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | MSYS2 설치 프로그램 | [msys2.org](https://www.msys2.org/)에서 받는다 | 기본 설치 경로는 `C:\msys64`다 |
| 2 | 네트워크 | 인터넷 연결 | 패키지를 내려받는다 |
| 3 | 디스크 공간 | 약 2 GB 이상 | 툴체인 설치 크기는 버전에 따라 다르다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: PATH 환경 변수를 편집할 때 기존 항목을 지우지 않는다. 항목을 새로 추가만 한다. 기존 항목을 지우면 다른 프로그램이 실행되지 않을 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 이미 설치된 gcc가 있는지 확인한다: PowerShell에서 `gcc --version` | `gcc`를 찾을 수 없다는 오류가 나오거나 설치된 버전이 출력된다 |
| 2 | 설치 경로에 공백과 한글이 없는지 확인한다 | 기본 경로 `C:\msys64`를 쓴다 |

## 5. 절차

### A. MSYS2 설치

1. (5-A-01) 브라우저에서 `https://www.msys2.org/`를 연다.
2. (5-A-02) 설치 프로그램을 내려받아 실행한다.
3. (5-A-03) 설치 경로를 `C:\msys64`로 두고 설치를 끝낸다. → 결과: 시작 메뉴에 `MSYS2 UCRT64` 항목이 생긴다.

### B. 컴파일러 설치

1. (5-B-01) 시작 메뉴에서 `MSYS2 UCRT64`를 연다. → 결과: 터미널 창이 열린다.
2. (5-B-02) 패키지 목록을 갱신한다.

```bash
pacman -Syu
```

→ 결과: 갱신이 끝난다. 창을 닫으라는 안내가 나오면 창을 닫고 5-B-01부터 다시 한다.

3. (5-B-03) 툴체인을 설치한다.

```bash
pacman -S --needed base-devel mingw-w64-ucrt-x86_64-toolchain
```

→ 결과: 설치할 패키지 선택을 묻는다. 기본값(전체)으로 Enter를 누른다. `gcc`, `g++`, `gdb`, `make`가 설치된다.

{% hint style="info" %}
NOTE: gcc만 필요하면 `pacman -S mingw-w64-ucrt-x86_64-gcc`로 gcc 하나만 설치할 수 있다. 이 경우 gdb는 `pacman -S mingw-w64-ucrt-x86_64-gdb`로 따로 설치한다.
{% endhint %}

### C. PATH 등록

1. (5-C-01) Windows 검색에서 `시스템 환경 변수 편집`을 연다.
2. (5-C-02) `환경 변수`를 누른다.
3. (5-C-03) `사용자 변수`의 `Path`를 선택하고 `편집`을 누른다.
4. (5-C-04) `새로 만들기`를 누르고 `C:\msys64\ucrt64\bin`을 입력한다.
5. (5-C-05) 모든 창에서 `확인`을 누른다. → 결과: 창이 닫힌다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 새 PowerShell을 열고 `gcc --version` | gcc 버전이 출력된다 | 오류가 없다 |
| 2 | `g++ --version` | g++ 버전이 출력된다 | 오류가 없다 |
| 3 | `gdb --version` | gdb 버전이 출력된다 | 오류가 없다 |

{% hint style="info" %}
NOTE: PATH를 바꾸기 전에 열려 있던 터미널과 VS Code는 새 값을 읽지 못한다. 확인 전에 새로 연다.
{% endhint %}

## 7. 복구

1. (7-01) `Path`에서 `C:\msys64\ucrt64\bin` 항목을 삭제한다. 5-C-01~05와 같은 경로로 연다. → 결과: 새 PowerShell에서 `gcc --version`이 오류를 출력한다.
2. (7-02) `C:\msys64` 폴더를 삭제한다. 또는 `설정 > 앱`에서 MSYS2를 제거한다. → 결과: 폴더가 없어진다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM MP 형식으로 재작성. 외부 블로그에 위임하던 설치를 MSYS2 `pacman` 절차와 PATH 등록으로 구체화했다. 블로그 링크는 참조로 옮겼다 |
