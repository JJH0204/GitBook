# CMakeLists.txt 작성 가이드

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-BLD-004-MP |
| 목적 | 소스 파일 하나로 실행 파일을 만드는 최소 `CMakeLists.txt`를 작성한다 |
| 적용 대상 | CMake 3.10 이상 설치됨, C 컴파일러 설치됨, 터미널 사용 가능 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 페이지의 예시를 정리한 것이며 이 문서로 다시 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 아직 실행해 확인하지 않았다. 여러 서브 프로젝트 예제와 명령어 표는 DEV-BLD-006-REF를 따른다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [CMake 개요 및 활용](cmake.md) | DEV-BLD-001-DO | CMake가 하는 일 |
| [macOS CMake 설치](cmakeinstallationformac.md) | DEV-BLD-002-MP | CMake 설치 |
| [CMakeLists.txt 예제 모음](cmakelistsreference.md) | DEV-BLD-006-REF | 명령어 표와 큰 예제 |
| [Ninja 설치와 CMake 빌드](ninjabuild.md) | DEV-BLD-005-MP | 작성한 파일로 빌드 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | CMake | 3.10 이상 | `cmake --version`으로 확인한다 |
| 2 | C 컴파일러 | gcc 또는 clang | |
| 3 | 소스 파일 | `checkBracketMatch.c`, `Stack.c` | 원본 예시의 파일 이름이다. 본인 파일 이름으로 바꿔도 된다 |
| 4 | 텍스트 편집기 | 아무 편집기 | |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 이 작업은 데이터 손실 위험이 없다. 새 파일 `CMakeLists.txt` 하나를 만든다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | CMake가 설치돼 있는지 확인한다: `cmake --version` | 버전 번호가 출력된다 |
| 2 | 프로젝트 최상위 폴더로 이동한다 | 소스 파일이 이 폴더 또는 하위 폴더에 있다 |

## 5. 절차

### A. CMakeLists.txt 작성

1. (5-A-01) 프로젝트 최상위 폴더에 `CMakeLists.txt` 파일을 만든다. → 결과: 폴더에 파일이 생긴다.
2. (5-A-02) 아래 내용을 입력한다.

{% code title="CMakeLists.txt (간단 예시)" %}
```cmake
# 예시
cmake_minimum_required(VERSION 3.10)
project(UsingStack)
add_executable(checkBracketMatch checkBracketMatch.c Stack.c)
```
{% endcode %}

3. (5-A-03) 파일을 저장한다. → 결과: 파일 내용이 3줄이다.

### B. 문법 확인

각 줄의 형식은 다음과 같다. 아래는 문법 설명이며 그대로 실행하는 코드가 아니다.

```
cmake_minimum_required(VERSION <최소 버전>)
project(<프로젝트 이름>)
add_executable(<실행 파일 이름> <소스 파일>.c <추가 소스 파일>.c ...)
```

| 줄 | 뜻 |
|---|---|
| `cmake_minimum_required` | 필요한 CMake 최소 버전을 지정한다 |
| `project` | 프로젝트 이름을 지정한다 |
| `add_executable` | 실행 파일 이름과 그 파일을 만드는 소스 파일 목록을 지정한다 |

### C. VS Code에서 실행 (선택)

{% hint style="info" %}
NOTE: 이 구역은 VS Code CMake 확장을 쓸 때만 수행한다. 원본에 "맥에서 실행이 안 되는 경우가 있음"이라고 적혀 있다.
{% endhint %}

1. (5-C-01) `F1`을 누른다.
2. (5-C-02) `CMake: Quick Start`를 선택한다. (원본 표기는 `CMake: quickStart`이며 화면 글자는 확인하지 않았다.)
3. (5-C-03) 빌드를 진행한다.
4. (5-C-04) 실행한다. → 결과: 실행 파일이 만들어져 실행된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `cmake -S . -B build` | 설정이 끝난다 | 마지막 줄 근처에 `Build files have been written to`가 출력되고 `build` 폴더가 생긴다 |
| 2 | `cmake --build build` | 빌드가 끝난다 | 오류 없이 끝나고 `build` 안에 `checkBracketMatch` 실행 파일이 생긴다 |

## 7. 복구

1. (7-01) 생성된 `build` 폴더를 삭제한다: `rm -r build` → 결과: `build` 폴더가 없어진다.
2. (7-02) 필요하면 `CMakeLists.txt`를 삭제한다. 소스 파일은 건드리지 않는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. 최소 예시는 MP로 두고 큰 예제와 명령어 표는 DEV-BLD-006-REF로 분리했다. 기능 확인 절을 추가했다 |
