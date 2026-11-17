# 빌드 및 도구 (Build & Tools)

C 소스 코드가 실행 파일이 되는 과정(전처리, 컴파일, 링크)과 여러 파일을 묶어 빌드하는 방법을 정리한 그룹이다. 문서 번호(Task ID)는 `PRG-BLD-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| PRG-BLD-001-DO | D&O | [전처리 과정 (Preprocessing)](preprocessing.md) | 주석 제거, 매크로 치환, 파일 포함을 이해한다 |
| PRG-BLD-002-DO | D&O | [컴파일 과정 (Compile)](compile.md) | 컴파일 단계와 최적화 옵션, 어셈블리 출력을 이해한다 |
| PRG-BLD-003-TS | TS | [C 모듈화 에러 해결](cmodularizationerror.md) | 여러 파일 빌드의 `Undefined symbols` 링크 오류를 해결한다 |
| PRG-BLD-004-REF | REF | [main.c 작성 및 진입점](main.c.md) | 연결 스택을 쓰는 `main.c` 예제와 빌드 명령을 찾는다 |
| PRG-BLD-005-MP | MP | [CMake 빌드 도구 (CMake)](cmake.md) | CMake로 C 프로젝트를 설정하고 빌드한다 |

## 읽는 순서

1. PRG-BLD-001-DO와 PRG-BLD-002-DO로 빌드 단계를 익힌다.
2. PRG-BLD-004-REF의 예제를 여러 파일로 빌드하다 링크 오류가 나면 PRG-BLD-003-TS를 본다.
3. 파일 수가 늘어나면 PRG-BLD-005-MP로 CMake를 설정한다.

## 관련 문서

* CMake 개념과 `CMakeLists.txt` 명령 전반은 DevTool 스페이스의 [CMake 개요 및 활용](../../../../DevTool/build-system/cmake.md)(DEV-BLD-001-DO)을 따른다.
