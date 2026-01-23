# CMake

[What\_CMake](https://growing-dev101.tistory.com/entry/%EA%B0%9C%EB%B0%9C%ED%99%98%EA%B2%BD-CMake)\
[sup\_CMake\_GIT](https://gist.github.com/luncliff/6e2d4eb7ca29a0afd5b592f72b80cb5c?permalink_comment_id=2831356)\
[CMake\_SET](https://growingdev.blog/entry/%EA%B0%9C%EB%B0%9C-%ED%99%98%EA%B2%BD-CMake-%EA%B8%B0%EB%B3%B8-%EC%84%A4%EC%A0%95-%EB%94%B0%EB%9D%BC%ED%95%98%EA%B8%B0-feat-VS-Code)\
[CMake 설치 for Mac](/broken/pages/e7c364053de289e096d0f210c33f1329ed7fd092)\
[CMake 설치 for windows](https://ndb796.tistory.com/365)

## CMake 가 뭔데?

* make 또는 [Ninja](/broken/pages/7b4461d6b6075022e39d975f775c7f509d59fb9b) 같은 빌드 프로그램에서 프로젝트 빌드를 할 수 있도록 빌드 파일을 만들어 주는 툴
* make 시스템을 사용한다면 Makefile을 생성, [Ninja](/broken/pages/7b4461d6b6075022e39d975f775c7f509d59fb9b)를 쓴다면 .ninja를 생성 할 것이다.
* 대부분의 C/C++ 프로젝트에서 사용되는 프로그램
* make와 같이 [러닝 커브](/broken/pages/774639584897e5f4d91b543cef95e1a87000f30d)가 있고, 긴 역사 만큼 옳바른 사용법(Best practice)이 버전에 따라 많이 바뀐다.

### 개요

* CMake를 사용하는 모든 프로젝트에는 반드시 프로젝트 최상위 디렉토리에 [CMakeLists.txt](/broken/pages/bf053101474c22798eca61183453387c0daee36c) 파일이 있어야 한다.
* CMakeLists.txt > CMake > Makefile > make > 실행파일 순으로 컴파일된다.
* 최상위 CMakeLists.txt 에는 반드시 아래 두 내용이 들어가야 된다.

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

* 주석은 (#)을 사용하면 된다.
* CMake 버전별 지원 기능의 차이가 커 최소 버전을 3.0 이상으로 설정해 놓는다.
* [project()](file:///3578414/projects/project\(\).md)에 프로젝트 정보를 간단히 명시 (프로젝트 이름은 필수)
* 실행 파일을 빌드하기 위해서 CMakeLists.txt 와 소스코드 파일은 같은 경로에 있어야 한다.
* CMake에서 권장하는 빌드 파일 생성 방법으로 빌드 파일과 작업하는 디렉토리는 서로 분리한다. 예: build 라는 별도의 폴더를 만들어 사용

### 참고 사이트

* [모두의 코드](https://modoocode.com/332)
* [Mac os에서 CMake 사용하기](https://popcorn16.tistory.com/31)
* https://answer-me.tistory.com/87
* https://gist.github.com/luncliff/6e2d4eb7ca29a0afd5b592f72b80cb5c
* https://chat.openai.com/share/a9766652-c2f0-4db1-9c2e-a2dd1c61d38b
