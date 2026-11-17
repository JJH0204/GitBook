# VS Code C/C++ 환경 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-CST-001-MP |
| 목적 | VS Code와 C/C++ 컴파일러를 설치해 `.c`, `.cpp` 파일을 작성할 수 있는 환경을 만든다 |
| 적용 대상 | Windows 64비트(MinGW-w64), macOS(Xcode Command Line Tools) |
| 소요 시간 | 약 20~30분 |
| 확인 상태 | 미검증 (원본 페이지의 절차를 정리한 것이며 이 문서로 설치·실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: VS Code는 마이크로소프트가 개발한 소스 코드 편집기다. 컴파일러는 포함하지 않으므로 구역 A(Windows) 또는 구역 B(macOS)에서 컴파일러를 따로 설치한다. Linux는 이 문서의 범위가 아니다.
{% endhint %}

{% hint style="info" %}
NOTE: 같은 주제의 DevTool 스페이스 문서가 있다. 설정 절차의 정본은 [VS Code C/C++ 개발 환경](../../../../DevTool/vs-code/vscodecppdevelopment.md)이다. 이 문서는 Programming 스페이스의 학습용 사본이다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [README.md](README.md) | | C/C++ 개발 환경 설정 (그룹 안내) |
| [clanguage.md](clanguage.md) | PRG-CST-002-REF | C 언어 학습 로드맵 및 메모 |
| [helloworld.md](../c-fundamentals/helloworld.md) | PRG-CFD-001-DO | Hello World 예제 (설치 후 첫 컴파일 대상) |

외부 참조(원본에 있던 링크)는 이 문서 끝의 "외부 참조"에 있다.

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 인터넷 연결 | | 다운로드와 확장 설치에 쓴다 |
| 2 | Windows PC | 64비트 Windows | 구역 A용 |
| 3 | MinGW-w64 `.zip` 파일 | [공식 누리집](https://www.mingw-w64.org/) 안내의 빌드 배포처에서 받는다 | `.exe` 설치 프로그램은 쓰지 않는다 |
| 4 | macOS 컴퓨터 | | 구역 B용 |
| 5 | VS Code | [설치 링크](https://code.visualstudio.com/download) | 구역 C |
| 6 | 압축 해제 도구 | | `.zip`을 푼다 (`.7z`로 배포되면 7-Zip이 필요하다) |

### MinGW-w64 파일 이름 읽는 법

파일 이름은 `Architecture-Threads-Exception` 순서다. 필요한 값을 고른다.

| 항목 | 값 | 선택 기준 |
|---|---|---|
| Architecture | `x86_64` | 64비트(x64, AMD64) 컴파일러가 필요할 때 |
| Architecture | `i686` | 32비트(x86) 컴파일러가 필요할 때 |
| Threads | `posix` | C++11/C11 멀티스레딩 기능이 필요할 때 |
| Threads | `win32` | 멀티스레딩 기능이 필요 없을 때 |
| Exception | `seh`, `sjlj`, `dwarf` 등 | 예외 처리 방식. 64비트는 일반적으로 `seh`를 쓴다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 환경 변수 `Path`를 편집할 때는 기존 항목을 지우지 않는다. 기존 항목을 지우면 다른 프로그램이 실행되지 않을 수 있다. 구역 A의 5-A-06 전에 현재 `Path` 값을 메모장에 복사해 둔다.
{% endhint %}

{% hint style="info" %}
NOTE: 원본은 설치 위치로 `C:\Program Files`를 안내했다. 이 폴더에는 관리자 권한이 필요할 수 있다. 권한 문제가 생기면 `C:\mingw64`처럼 공백이 없는 경로를 쓴다. 이 경우 5-A-05, 5-A-07의 경로를 같은 경로로 바꾼다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 운영체제를 확인한다 | Windows는 `설정 > 시스템 > 정보`에서 시스템 종류가 64비트 운영 체제인지 본다 |
| 2 | 기존 컴파일러 설치 여부를 확인한다 | 터미널에서 `gcc --version`을 실행한다. 버전이 나오면 구역 A 또는 B를 건너뛰고 구역 C로 간다 |

## 5. 절차

### A. Windows: MinGW-w64 설치

1. (5-A-01) 공식 누리집에서 `.zip` 배포 링크를 연다. → 결과: 파일 목록 페이지가 열린다.
2. (5-A-02) 2절의 표를 보고 `x86_64`, `posix`, `seh` 조합의 `.zip` 파일을 내려받는다. `.exe` 파일은 받지 않는다.
3. (5-A-03) 받은 `.zip` 파일을 압축 해제한다. → 결과: `mingw64` 폴더가 생긴다.
4. (5-A-04) 현재 `Path` 값을 메모장에 복사해 둔다. 환경 변수 편집 화면은 Windows 검색에서 "환경 변수"를 입력해 연다.
5. (5-A-05) `mingw64` 폴더를 `C:\Program Files`로 이동한다. (32비트 컴파일러를 64비트 Windows에 설치하는 경우 `C:\Program Files (x86)`.) → 결과: `C:\Program Files\mingw64\bin\gcc.exe`가 존재한다.
6. (5-A-06) 환경 변수 편집 창에서 `시스템 변수`의 `Path`를 선택하고 `편집`을 누른다.
7. (5-A-07) `새로 만들기`를 누르고 `C:\Program Files\mingw64\bin`을 입력한다. 실제 압축 해제 폴더 경로에 `\bin`을 붙인 값이다.
8. (5-A-08) `확인`을 눌러 열린 창을 모두 닫는다. → 결과: 환경 변수 창이 모두 닫힌다.
9. (5-A-09) 이미 열려 있는 터미널을 모두 닫는다. 새 터미널에서만 변경된 `Path`가 적용된다.
10. (5-A-10) 새 터미널을 열고 `gcc -v`를 실행한다. → 결과: 버전 정보가 출력된다.
11. (5-A-11) `g++ -v`를 실행한다. → 결과: 버전 정보가 출력된다.

{% hint style="info" %}
NOTE: 5-A-10 또는 5-A-11이 실패하면 `Path`에 입력한 경로를 다시 확인한다. 원본은 "처음부터 다시 진행"하도록 안내했다. 경로가 틀린 경우가 대부분이므로 5-A-07부터 다시 확인한다.
{% endhint %}

### B. macOS: Xcode Command Line Tools 설치

1. (5-B-01) 터미널을 열고 `xcode-select --install`을 실행한다. → 결과: 도구 설치 확인 창이 나타난다.
2. (5-B-02) `설치`를 선택한다.
3. (5-B-03) 사용 조건 창에서 `동의`를 선택한다.
4. (5-B-04) 설치가 끝날 때까지 기다린다.
5. (5-B-05) 터미널에서 `gcc --version`을 실행한다. → 결과: 버전 정보가 출력된다.

{% hint style="info" %}
NOTE: macOS에서 `gcc`는 GNU GCC가 아니라 Apple clang의 별칭이다. 출력에 `clang`과 `Apple`이 포함되는 것이 정상이다.
{% endhint %}

### C. VS Code 설치와 C/C++ 확장

1. (5-C-01) [VS Code 설치 링크](https://code.visualstudio.com/download)에서 운영체제에 맞는 설치 파일을 받아 설치한다. → 결과: VS Code가 실행된다.
2. (5-C-02) 왼쪽 막대의 `확장`(Extensions)을 연다.
3. (5-C-03) 검색창에 `C/C++`를 입력한다.
4. (5-C-04) 게시자가 Microsoft인 `C/C++` 확장을 설치한다. → 결과: 확장 목록에 `설치됨`으로 표시된다.
5. (5-C-05) 작업용 폴더를 만들고 VS Code에서 연다.
6. (5-C-06) 폴더 안에 `hello.c` 파일을 만든다. 코드는 [Hello World 예제](../c-fundamentals/helloworld.md)를 쓴다.

### D. 추천 확장 (선택)

필수가 아니다. 필요한 것만 설치한다.

| 확장 | 용도 |
|---|---|
| [한국어 언어 팩](https://marketplace.visualstudio.com/items?itemName=MS-CEINTL.vscode-language-pack-ko) | VS Code 화면을 한국어로 바꾼다 |
| [Translator](https://marketplace.visualstudio.com/items?itemName=sculove.translator) | 선택한 텍스트를 번역한다 |
| [GitHub Theme](https://marketplace.visualstudio.com/items?itemName=GitHub.github-vscode-theme) | 색상 테마 |
| [Material Icon Theme](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme) | 파일 아이콘 테마 |
| [TODO Highlight](https://marketplace.visualstudio.com/items?itemName=wayou.vscode-todo-highlight) | `TODO` 주석을 강조한다 |
| [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one) | 마크다운 편집을 돕는다 |
| [indent-rainbow](https://marketplace.visualstudio.com/items?itemName=oderwat.indent-rainbow) | 들여쓰기 깊이를 색으로 구분한다 |
| [Git Graph](https://marketplace.visualstudio.com/items?itemName=mhutchie.git-graph) | Git 이력을 그래프로 본다 |
| [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker) | 코드와 주석의 맞춤법을 검사한다 |

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 새 터미널에서 `gcc --version` | 버전 정보가 출력된다 | 오류 없이 출력된다 (macOS는 clang 정보) |
| 2 | 새 터미널에서 `g++ --version` | 버전 정보가 출력된다 | 오류 없이 출력된다 |
| 3 | `hello.c`가 있는 폴더에서 `gcc hello.c -o hello`를 실행한다 | 실행 파일이 생긴다 | 컴파일 오류가 없다 |
| 4 | 생성된 파일을 실행한다 (Windows `.\hello.exe`, macOS `./hello`) | `hello world`가 출력된다 | 출력이 일치한다 |

## 7. 복구

1. (7-01) Windows: 환경 변수 `Path`에서 5-A-07에서 추가한 항목을 삭제한다. → 결과: 새 터미널에서 `gcc -v`가 "찾을 수 없음" 오류를 낸다.
2. (7-02) Windows: `mingw64` 폴더를 삭제한다.
3. (7-03) macOS: Command Line Tools를 지우려면 `/Library/Developer/CommandLineTools` 폴더를 삭제한다. 이 절차는 확인하지 않았으므로 Apple 안내를 확인한다.
4. (7-04) VS Code 확장은 `확장` 화면에서 `제거`를 누른다.

## 외부 참조

* [수성컴전자방 블로그: MinGW-w64 설치](https://sooseongcom.com/post/MinGW-w64-HowToInstall)
* [전문 해커의 VS Code 세팅 (영상)](https://www.youtube.com/watch?v=r750vOVbS9M)
* [JetBrains Mono 폰트 설정](https://gyuha.tistory.com/534)
* [VS Code C/C++ 환경 세팅](https://m.blog.naver.com/dorergiverny/221889473340)
* [MinGW-w64 threads: posix vs win32](https://stackoverflow.com/questions/17242516/mingw-w64-threads-posix-vs-win32)
* [MinGW-w64 예외 처리: seh와 sjlj의 차이](https://stackoverflow.com/questions/30739099/what-is-the-difference-between-mingw-seh-and-mingw-sjlj)

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식(MP)으로 재작성. 절차를 단계별로 나누고 기능 확인·복구·외부 참조 절을 추가 |
