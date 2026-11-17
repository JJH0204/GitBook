# C 모듈화 에러 해결

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-BLD-003-TS |
| 유형 | TS (문제 해결) |
| 목적 | 헤더와 소스를 나눈 C 프로그램을 VS Code에서 빌드할 때 나는 `Undefined symbols` 링크 오류의 원인을 찾고 해결한다 |
| 적용 대상 | macOS(Apple clang 15), VS Code, gcc 또는 clang 명령 빌드 (원본 작성 환경) |
| 확인 상태 | 미검증 (원본 기록을 정리했으며 이 환경에서 재현하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 증상

스택을 헤더(`MyStack.h`)와 구현(`MyStack.c`), 사용(`main.c`) 파일로 나눠 VS Code에서 빌드하면 링크 단계에서 다음 오류가 나온다. Xcode에서는 같은 코드가 정상 실행된다.

```
ld: Undefined symbols:
  _createStack, referenced from:
      _main in main-c2b05d.o
  _push, referenced from:
      _main in main-c2b05d.o
  ...
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

| 항목 | 내용 |
|---|---|
| 오류 형태 | macOS 링커는 `Undefined symbols`, Linux의 GNU 링커는 `undefined reference to`로 표시한다 |
| 오류 단계 | 컴파일은 성공하고 링크에서 실패한다 |
| 관련 코드 | [MyStack.h](../../../reference-and-snippets/c-snippets/mystack.h.md), [MyStack.c](../../../reference-and-snippets/c-snippets/mystack.c.md), [main.c](main.c.md) |

## 2. 가능 원인

| 번호 | 가능 원인 | 확인 방법 | 판정 |
|---|---|---|---|
| 1 | 빌드 명령이 `main.c`만 컴파일한다(구현 파일이 빠졌다) | 빌드 로그의 명령에 `MyStack.c`가 있는지 본다 | 원본의 최종 원인 |
| 2 | 작성한 IDE(Xcode)와 VS Code의 파일 생성 방식 차이 | Xcode 프로젝트 폴더를 VS Code에서 열어 같은 빌드를 한다 | 기각. 같은 오류가 재현됐다 |
| 3 | `gcc`와 clang의 동작 차이 | `gcc -v`로 실제 컴파일러를 확인한다 | 기각. macOS의 `gcc`는 Apple clang이다 |

{% hint style="info" %}
NOTE: 3번의 원본 기록은 `gcc -v`가 `Apple clang version 15.0.0`으로 나온 것이다. macOS에서 `gcc` 명령은 보통 clang을 가리킨다. clang은 LLVM을 백엔드로 쓰는 C/C++ 컴파일러다.
{% endhint %}

## 3. 격리 절차

1. (3-01) 빌드 로그의 컴파일 명령을 읽는다. → 결과: VS Code의 기본 작업은 `gcc -g <현재 열린 파일> -o <출력>` 형태로 현재 파일 하나만 넘긴다.
2. (3-02) 링커가 찾지 못하는 심볼 이름(`_createStack`, `_push`, `_pop`)이 어느 파일에 정의되어 있는지 확인한다. → 결과: 모두 `MyStack.c`에 있다.
3. (3-03) `MyStack.c`가 위 명령에 포함됐는지 확인한다. → 결과: 포함되지 않았다. 헤더(`MyStack.h`)는 선언만 담으므로 구현을 대신하지 못한다.

## 4. 시정 조치

1. (4-01) 구현 파일을 모두 한 명령에 넣어 빌드한다.

```sh
gcc main.c MyStack.c -o main
```

→ 결과: 링크 오류 없이 `main` 실행 파일이 생성된다.

2. (4-02) 헤더 파일(`.h`)은 명령에 넘기지 않는다. 헤더는 `#include`로 포함된다.
3. (4-03) 파일 수가 많으면 CMake로 소스 목록을 관리한다. [PRG-BLD-005-MP](cmake.md)를 따른다.

{% hint style="warning" %}
CAUTION: 원본은 `gcc reverseString.c Stack.c Stack.h -o reverseString`처럼 헤더를 명령에 포함했다. 이 동작은 컴파일러에 따라 경고나 오류가 될 수 있다(확인 필요).
{% endhint %}

### 4-A. Windows PowerShell에서 실행 파일을 실행할 때

PowerShell은 현재 폴더의 프로그램을 이름만으로 실행하지 않는다. `.\reverseString`처럼 경로를 붙인다. 원본 기록에서 `reverseString`과 `reverseString.exe`는 `CommandNotFoundException`이 났고 `.\reverseString`은 출력 없이 끝났다.

## 5. 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `gcc main.c MyStack.c -o main` | 오류 없이 끝난다 | 종료 코드 0 |
| 2 | `./main` | 스택 7개 문자 출력, `Pop - [U]`, `Peek - [O]`가 나온다 | [main.c](main.c.md)의 예상 출력과 일치 |

## 6. 경위 기록 (원본 보존)

원본 작성자가 거친 시도 순서는 다음과 같다.

1. Xcode에서 정상이던 프로젝트를 VS Code에서 열어 같은 오류를 확인했다. VS Code 쪽 문제로 좁혔다.
2. `gcc -v`로 컴파일러를 확인했다. 출력은 Apple clang이었다. 설치 경로는 `/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin`이었다.
3. `/Library/Developer/CommandLineTools/usr/bin/`에 컴파일러가 있음을 확인했다. `Xcode.app`을 삭제한 뒤 `gcc -v`의 `InstalledDir`이 이 경로로 바뀌었다.
4. VS Code의 `C/C++: gcc 활성 파일 빌드` 작업이 같은 오류를 냈다. `tasks.json`, `launch.json`이 열렸고 `c_cpp_properties.json`도 설정 파일임을 알았다.
5. 터미널에서 `gcc reverseString.c Stack.c Stack.h -o reverseString`처럼 파일을 직접 넘겨 빌드했다. 이후 실행 시 `zsh: segmentation fault`가 났다.

{% hint style="warning" %}
CAUTION: 5번의 세그멘테이션 폴트(segmentation fault)는 링크 오류와 별개의 실행 오류다. 원본은 원인을 확인하지 않았다(`무한루프 등`으로만 기록). 원인은 확인 필요다.
{% endhint %}

{% hint style="danger" %}
WARNING: 원본의 3번 시도에서 `Xcode.app`을 삭제했다. 이 문서의 원인(구현 파일 누락)과 무관하다. 링크 오류 해결을 위해 Xcode를 삭제할 필요는 없다.
{% endhint %}

## 7. 참조

* [Mac Clang C++17 컴파일러 환경 설정](https://headf1rst.github.io/c++/clang-c++17/)
* [windows c/c++ 개발환경 설정](https://blog.amylo.diskstation.me/algorithm/Starting_Algorithm_with_VSCode_C++/)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 헤더 파일의 선언과 소스 파일의 정의는 각각 어느 단계(컴파일/링크)에서 쓰이는가?
- [ ] 이 오류를 처음 봤을 때 Xcode와 VS Code의 차이를 어떻게 설명했는가? 지금은 어떻게 설명하는가?
