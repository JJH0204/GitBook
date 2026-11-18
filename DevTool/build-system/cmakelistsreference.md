# CMakeLists.txt 예제 모음

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-BLD-006-REF |
| 유형 | REF (표·예제) |
| 목적 | 자주 쓰는 CMake 명령어와 다중 서브 프로젝트 예제를 참조한다 |
| 확인 상태 | 미검증 (원본 페이지의 예제를 옮긴 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 명령어 표

| 명령 | 역할 |
|---|---|
| `cmake_minimum_required(VERSION <버전>)` | 필요한 CMake 최소 버전을 지정한다 |
| `project(<이름> VERSION <버전> LANGUAGES <언어>)` | 프로젝트 이름, 버전, 언어를 지정한다 |
| `set(CMAKE_CXX_STANDARD <값>)` | C++ 표준을 지정한다. 아래 예제는 `17`이다 |
| `set(CMAKE_CXX_STANDARD_REQUIRED True)` | 지정한 표준을 반드시 쓰게 한다 |
| `add_compile_options(...)` | 컴파일 옵션을 추가한다 |
| `add_subdirectory(<폴더>)` | 하위 폴더의 `CMakeLists.txt`를 포함한다 |
| `find_package(<이름> REQUIRED)` | 외부 라이브러리를 찾는다. 못 찾으면 오류로 멈춘다 |
| `file(GLOB <변수> "<패턴>")` | 패턴에 맞는 파일 목록을 변수에 담는다 |
| `add_executable(<이름> <소스>...)` | 실행 파일 이름과 소스 파일을 지정한다 |
| `target_link_libraries(<이름> PRIVATE <라이브러리>)` | 대상에 라이브러리를 연결한다 |
| `target_include_directories(<이름> PRIVATE <폴더>)` | 대상의 헤더 검색 경로를 추가한다 |

## 2. 예제 1: 루트 CMakeLists.txt (서브 프로젝트 3개)

루트 디렉토리에 저장되어 있고 서브 프로젝트 3개를 관리하는 `CMakeLists.txt` 예시다.

{% code title="CMakeLists.txt (루트 — CppProject)" %}
```cmake
# CMake 최소 버전 설정
cmake_minimum_required(VERSION 3.11)

# 프로젝트 설정
project(CppProject VERSION 0.1 LANGUAGES CXX)

#c++ 표준 설정
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# UTF-8 인코딩을 위한 컴파일러 옵션 설정
add_compile_options(
    $<$<CXX_COMPILER_ID:GNU>:-finput-charset=UTF-8>
    $<$<CXX_COMPILER_ID:Clang>:-finput-charset=UTF-8>
)

# 디버그 모드 설정
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -g")

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    # macOS-specific settings
    message(STATUS "Configuring for macOS")

    # 서브 프로젝트 추가: project_Basics
    add_subdirectory(Basics)
    add_subdirectory(OOP)
    add_subdirectory(Tetris)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    # Windows-specific settings
    message(STATUS "Configuring for Windows")
    # 서브 프로젝트 추가: project_Basics
    add_subdirectory(Basics)
    add_subdirectory(OOP)
    add_subdirectory(Tetris)
else()
    message(STATUS "Configuring for Other OS")
    # 서브 프로젝트 추가: project_Basics
    add_subdirectory(Basics)
    add_subdirectory(OOP)
    add_subdirectory(Tetris)
endif()
```
{% endcode %}

* 위 파일은 루트에서 Basics, OOP, Tetris 세 서브 디렉토리를 `add_subdirectory`로 포함한다.
* Tetris는 루트의 서브 프로젝트 중 가장 최신 C++ 프로젝트다. (관련 페이지: C++ 프로젝트)
* 세 `if` 분기의 `add_subdirectory` 호출이 같다. 운영체제에 따라 메시지만 다르다.

## 3. 예제 2: Tetris 서브프로젝트

{% code title="Tetris/CMakeLists.txt" %}
```cmake
cmake_minimum_required(VERSION 3.10)
project(Tetris)

# ncurses 라이브러리 찾기
find_package(Curses REQUIRED)

# source 디렉토리 내의 모든 cpp 파일 수집
file(GLOB SOURCES "source/*.cpp")

# 실행 파일 생성 및 소스 파일 지정
add_executable(Tetris main.cpp ${SOURCES})

# ncurses 라이브러리 링크
target_link_libraries(Tetris PRIVATE ${CURSES_LIBRARIES})

# 추가 라이브러리 링크 혹은 옵션 지정
target_include_directories(Tetris PRIVATE ${CURSES_INCLUDE_DIR} include)
```
{% endcode %}

{% hint style="info" %}
NOTE: `file(GLOB ...)`는 CMake를 설정할 때 한 번 파일 목록을 만든다. `source` 폴더에 파일을 추가하면 CMake 설정을 다시 실행해야 목록에 들어간다.
{% endhint %}

## 4. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [CMakeLists.txt 작성 가이드](cmakelists.txt.md) | DEV-BLD-004-MP | 최소 예시 작성 절차 |
| [CMake 개요 및 활용](cmake.md) | DEV-BLD-001-DO | CMake 개념 |

## 5. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `cmakelists.txt.md`의 큰 예제를 REF 형식으로 분리했다. 명령어 표와 `file(GLOB)` 주의를 추가했고, 예제 2의 주석 "src 디렉토리"를 실제 경로 `source`에 맞게 고쳤다 |
