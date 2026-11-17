# CMake 개요 및 활용

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-BLD-001-DO |
| 유형 | D&O (개념·원리) |
| 목적 | CMake의 역할, 구성 요소, 동작 순서를 설명한다 |
| 확인 상태 | 미검증 (원본 페이지와 공식 동작 설명을 정리한 것이며 직접 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 개념 설명이다. 설치는 DEV-BLD-002-MP, 파일 작성은 DEV-BLD-004-MP를 따른다.
{% endhint %}

## 1. 목적

CMake는 make 또는 [Ninja](ninja.md) 같은 빌드 프로그램이 프로젝트를 빌드할 수 있도록 빌드 파일을 만들어 주는 도구다. 대부분의 C/C++ 프로젝트에서 쓴다.

make와 같이 러닝 커브(학습 부담)가 있다. 역사가 길어 올바른 사용법(Best practice)이 버전에 따라 많이 바뀐다.

## 2. 구성 요소

| 번호 | 이름 | 위치 | 역할 |
|---|---|---|---|
| 1 | `CMakeLists.txt` | 프로젝트 최상위 디렉토리 | 프로젝트 정보와 빌드 방법을 적는 입력 파일이다. CMake를 쓰는 모든 프로젝트에 반드시 있어야 한다 |
| 2 | `cmake` 프로그램 | 시스템 PATH | `CMakeLists.txt`를 읽어 빌드 파일을 만든다 |
| 3 | 빌드 파일 | 빌드 디렉토리 | make를 쓰면 `Makefile`, Ninja를 쓰면 `build.ninja`가 만들어진다 |
| 4 | 빌드 프로그램 | 시스템 PATH | 빌드 파일을 읽어 컴파일러를 호출한다 (make, [Ninja](ninja.md)) |
| 5 | 빌드 디렉토리 | 소스와 분리된 폴더 (예: `build`) | 생성된 빌드 파일과 결과물을 모아 둔다 |

## 3. 동작 원리

기본 순서는 다음과 같다.

```
CMakeLists.txt > CMake > Makefile > make > 실행 파일
```

1. CMake가 `CMakeLists.txt`를 읽는다.
2. CMake가 빌드 파일을 만든다.
3. 빌드 프로그램이 빌드 파일을 읽어 컴파일한다.
4. 실행 파일이 만들어진다.

{% hint style="info" %}
NOTE: 위 순서의 `Makefile`과 `make`는 기본 생성기를 쓸 때의 예다. 생성기(generator)를 바꾸면 빌드 파일과 빌드 프로그램이 달라진다. Ninja를 쓰면 `Makefile` 대신 `build.ninja`가 생기고 `make` 대신 `ninja`가 실행된다. 자세한 내용은 DEV-BLD-003-DO를 따른다.
{% endhint %}

### 최상위 CMakeLists.txt의 필수 내용

최상위 `CMakeLists.txt`에는 반드시 아래 두 가지가 들어간다.

{% code title="CMakeLists.txt" %}
```cmake
# CMake 프로그램 최소 버전
cmake_minimum_required(VERSION 3.11)

# 프로젝트 정보
project(
    ProjectName
    VERSION 0.1
    DESCRIPTION "예제 프로젝트"
    LANGUAGES CXX
)
```
{% endcode %}

### 규칙

* 주석은 `#`을 사용한다.
* `cmake_minimum_required`는 CMake 버전별 지원 기능의 차이가 크므로 쓴다. 이 문서의 예시는 `3.11`을 쓴다. (원본의 "3.0 이상" 권고는 낡았다. 최소 버전은 사용하는 기능이 필요로 하는 버전에 맞춘다.)
* `project()`에 프로젝트 정보를 간단히 적는다. 프로젝트 이름은 필수다.
* `CMakeLists.txt`와 소스 파일이 같은 폴더에 있을 필요는 없다. 소스 경로를 `add_executable()`에 적으면 된다.
* CMake가 권장하는 방식은 빌드 파일과 작업 디렉토리를 분리하는 것이다. 예를 들어 `build`라는 별도 폴더를 만들어 쓴다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 생성기 (generator) | CMake가 만들어 내는 빌드 파일의 종류. Makefile, Ninja 등 |
| 빌드 디렉토리 | 생성된 빌드 파일과 결과물을 두는 폴더. 소스 폴더와 분리한다 |
| 러닝 커브 (learning curve) | 익히는 데 드는 학습 부담 |
| Best practice | 현재 권장되는 올바른 사용법 |

## 5. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [macOS CMake 설치](cmakeinstallationformac.md) | DEV-BLD-002-MP | macOS CMake 설치 |
| [Ninja 빌드 시스템](ninja.md) | DEV-BLD-003-DO | Ninja 빌드 시스템 |
| [CMakeLists.txt 작성 가이드](cmakelists.txt.md) | DEV-BLD-004-MP | CMakeLists.txt 작성 |
| [CMakeLists.txt 예제 모음](cmakelistsreference.md) | DEV-BLD-006-REF | CMakeLists.txt 예제 모음 |

외부 자료 (원본에 있던 링크):

* [What\_CMake](https://growing-dev101.tistory.com/entry/%EA%B0%9C%EB%B0%9C%ED%99%98%EA%B2%BD-CMake)
* [sup\_CMake\_GIT](https://gist.github.com/luncliff/6e2d4eb7ca29a0afd5b592f72b80cb5c?permalink_comment_id=2831356)
* [CMake\_SET](https://growingdev.blog/entry/%EA%B0%9C%EB%B0%9C-%ED%99%98%EA%B2%BD-CMake-%EA%B8%B0%EB%B3%B8-%EC%84%A4%EC%A0%95-%EB%94%B0%EB%9D%BC%ED%95%98%EA%B8%B0-feat-VS-Code)
* [CMake 설치 for windows](https://ndb796.tistory.com/365)
* [모두의 코드](https://modoocode.com/332)
* [Mac os에서 CMake 사용하기](https://popcorn16.tistory.com/31)
* [answer-me.tistory.com/87](https://answer-me.tistory.com/87)
* [luncliff gist](https://gist.github.com/luncliff/6e2d4eb7ca29a0afd5b592f72b80cb5c)

## 6. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM D&O 형식으로 재작성. "소스와 같은 경로" 서술을 정정하고 최소 버전 권고를 고쳤다. 설치 절차는 DEV-BLD-002-MP로, 작성 절차는 DEV-BLD-004-MP로 분리했다 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] CMake는 무엇을 만들어 주는 도구이고, 직접 컴파일도 하는가?
- [ ] 빌드 디렉토리를 소스와 분리하면 무엇이 좋은가?
