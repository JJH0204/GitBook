# CMake 빌드 도구 (CMake)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-BLD-005-MP |
| 목적 | 여러 소스 파일로 나뉜 C 프로젝트를 CMake로 설정하고 빌드한다 |
| 적용 대상 | Windows(MinGW), macOS, CMake 3.11 이상 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 명령을 정리한 것이며 이 환경에서 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 CMake 전반이 아니라 VS Code에서 C 모듈화 빌드 문제를 겪으며 필요했던 최소 설정만 담는다. 프로젝트 규모가 크면 DevTool 스페이스의 [CMake 개요 및 활용](../../../../DevTool/build-system/cmake.md)(DEV-BLD-001-DO)을 따른다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [cmodularizationerror.md](cmodularizationerror.md) | PRG-BLD-003-TS | C 모듈화 에러 해결 |
| [../../../../DevTool/build-system/cmake.md](../../../../DevTool/build-system/cmake.md) | DEV-BLD-001-DO | CMake 개요 및 활용 |

배경은 다음과 같다.

| 항목 | 설명 |
|---|---|
| 문제 | VS Code는 편집기이며 프로젝트 안 소스 파일의 링크를 관리하지 않는다. 빌드 명령에 파일 목록을 직접 넘겨야 한다 |
| 빌드 프로그램 | 프로젝트 빌드에는 `make`나 Ninja 같은 빌드 프로그램을 쓴다 |
| CMake의 역할 | `CMakeLists.txt`를 읽어 `make` 등이 쓰는 빌드 파일(Makefile)을 생성한다. Windows와 macOS에서 한 설정을 공유할 수 있다 |
| 빌드 순서 | `CMakeLists.txt` → CMake → Makefile → make → 실행 파일 |
| 주의 | CMake는 학습 곡선이 있고 권장 사용법(best practice)이 버전에 따라 많이 바뀐다 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | CMake | 3.11 이상 | 아래 준비 절에서 설치 |
| 2 | C 컴파일러 | Windows: MinGW gcc, macOS: Apple clang | |
| 3 | 빌드 프로그램 | `make` (Windows MinGW: `mingw32-make`) | 확인 필요: MinGW 설치 구성에 따라 이름이 다르다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 빌드 결과물이 소스 폴더에 섞이지 않도록 `build` 폴더를 따로 만들어 그 안에서 실행한다. 소스 폴더에서 `cmake .`를 실행하면 생성 파일이 소스와 섞인다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | CMake를 설치한다 (아래 A 구역) | `cmake --version`에 버전이 출력된다 |
| 2 | 프로젝트 최상위 폴더에 `CMakeLists.txt`를 둘 위치를 정한다 | 폴더를 확인한다 |
| 3 | 링크할 모든 `.c` 파일 경로를 정리한다 | 목록을 작성한다 |

## 5. 절차

### A. CMake 설치

**Windows**

1. (5-A-01) `https://cmake.org/download/`를 연다.
2. (5-A-02) Windows 버전을 선택해 내려받아 설치한다.
3. (5-A-03) 설치 중 `Add CMake to the system PATH for all users`를 선택한다. → 결과: 어느 폴더에서든 `cmake`를 실행할 수 있다.
4. (5-A-04) `cmd`에서 `cmake`를 실행한다. → 결과: Usage 안내가 출력되면 설치에 성공한 것이다.

**macOS**

1. (5-A-05) 터미널에서 `brew install cmake`를 실행한다.
2. (5-A-06) `cmake --version`을 실행한다. → 결과: 버전 번호가 출력된다.

### B. CMakeLists.txt 작성

1. (5-B-01) 프로젝트 최상위 폴더에 `CMakeLists.txt` 파일을 만든다. 소스 파일이 같은 폴더에 있을 필요는 없다.
2. (5-B-02) 최소 CMake 버전과 프로젝트 정보를 쓴다. 이 두 항목은 최상위 `CMakeLists.txt`에 반드시 있어야 한다. CMake 버전별 기능 차이가 커서 최소 버전을 3.0 이상으로 둔다.

```cmake
# CMake 최소 버전 설정
cmake_minimum_required(VERSION 3.11)

# 프로젝트 설정 (주석은 # 로 쓴다)
project(DEVBASICS VERSION 0.1 LANGUAGES C)
```

{% hint style="info" %}
NOTE: `project()`의 이름은 필수이고 `VERSION`, `DESCRIPTION`, `LANGUAGES`는 선택이다. C 프로젝트는 `LANGUAGES C`로 지정한다. 원본의 `LANGUAGES CXX` 예시는 C++ 프로젝트용이다.
{% endhint %}

3. (5-B-03) C 표준을 지정한다.

```cmake
# C 표준 설정
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED True)
```

4. (5-B-04) 반복해서 쓰는 값은 변수로 만든다.

```cmake
set(SOURCE_DIR source/DSNA/non-Linear)
```

5. (5-B-05) 실행 파일 이름과 소스 파일을 연결한다. 링크할 `.c` 파일을 모두 나열한다.

```cmake
add_executable(linkedGraph ${SOURCE_DIR}/mainGraph.c ${SOURCE_DIR}/includeLinkedGraph.c ${SOURCE_DIR}/includeGenericStructure.c)
```

6. (5-B-06) 헤더 파일 폴더를 검색 경로에 추가한다.

```cmake
# 헤더 파일 검색 경로 추가 (라이브러리 링크는 target_link_libraries로 한다)
include_directories(include)
```

7. (5-B-07) 운영체제별 설정이 필요하면 조건문을 쓴다.

```cmake
if(WIN32)
    # windows 설정

elseif(APPLE)
    # mac 설정

endif()
```

→ 결과: `CMakeLists.txt`가 저장된다.

### C. 빌드 (Windows)

1. (5-C-01) 빌드 폴더를 만들고 이동한다: `cd build/build_win`
2. (5-C-02) 빌드 파일을 생성한다: `cmake -G "MinGW Makefiles" ../../` → 결과: 빌드 폴더에 `Makefile`이 생긴다.
3. (5-C-03) 빌드한다: `cmake --build .` → 결과: 실행 파일이 생성된다.

### D. 빌드 (macOS)

1. (5-D-01) 빌드 폴더로 이동한다: `cd build/build_mac`
2. (5-D-02) 빌드 파일을 생성한다: `cmake ../../` → 결과: `Makefile`이 생긴다.
3. (5-D-03) 빌드한다: `make` → 결과: 실행 파일이 생성된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `cmake --version` | 버전이 출력된다 | 3.11 이상 |
| 2 | 빌드 명령 실행 | 오류 없이 끝난다 | 종료 코드 0 |
| 3 | 빌드 폴더의 실행 파일 실행 | 프로그램이 동작한다 | `Undefined symbols` 오류 없음 |

## 7. 복구

1. (7-01) 생성 파일을 지우려면 `build` 폴더의 내용을 삭제한다. 소스와 `CMakeLists.txt`는 영향받지 않는다.

## 8. 참조 링크

* [What\_CMake](https://growing-dev101.tistory.com/entry/%EA%B0%9C%EB%B0%9C%ED%99%98%EA%B2%BD-CMake)
* [sup\_CMake\_GIT](https://gist.github.com/luncliff/6e2d4eb7ca29a0afd5b592f72b80cb5c?permalink_comment_id=2831356)
* [CMake\_SET](https://growingdev.blog/entry/%EA%B0%9C%EB%B0%9C-%ED%99%98%EA%B2%BD-CMake-%EA%B8%B0%EB%B3%B8-%EC%84%A4%EC%A0%95-%EB%94%B0%EB%9D%BC%ED%95%98%EA%B8%B0-feat-VS-Code)
* [CMake 설치 for windows](https://ndb796.tistory.com/365)
* [모두의 코드](https://modoocode.com/332)
* [Mac os에서 CMake 사용하기](https://popcorn16.tistory.com/31)
* [answer-me.tistory.com/87](https://answer-me.tistory.com/87)
* [luncliff gist](https://gist.github.com/luncliff/6e2d4eb7ca29a0afd5b592f72b80cb5c)

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. ChatGPT 공유 링크 삭제, 빌드 자동화 실행 파일 언급(원본에 파일 없음) 삭제 |
