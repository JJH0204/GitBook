# Ninja 설치와 CMake 빌드

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-BLD-005-MP |
| 목적 | Ninja를 설치하고 CMake 프로젝트를 Ninja로 빌드한다 |
| 적용 대상 | macOS(Homebrew) 또는 Debian/Ubuntu(apt), CMake 3.13 이상 설치됨, `CMakeLists.txt`가 있는 프로젝트 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본에는 설치·실행 명령이 없었다. 이 문서의 명령은 작성자가 일반 지식으로 보충했으며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서의 명령은 모두 미검증이다. 원본 페이지에는 명령이 없었으므로 처음 실행할 때 출력이 다르면 이 문서를 고친다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Ninja 빌드 시스템](ninja.md) | DEV-BLD-003-DO | Ninja가 무엇인지 설명한다 |
| [macOS CMake 설치](cmakeinstallationformac.md) | DEV-BLD-002-MP | CMake 설치 |
| [CMakeLists.txt 작성 가이드](cmakelists.txt.md) | DEV-BLD-004-MP | 빌드할 파일 작성 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | 터미널 | | |
| 2 | CMake | 3.13 이상 | `-S`, `-B` 옵션을 쓰기 위한 조건이다 |
| 3 | 패키지 관리자 | Homebrew(macOS) 또는 apt(Debian/Ubuntu) | |
| 4 | 프로젝트 | 최상위에 `CMakeLists.txt`가 있다 | DEV-BLD-004-MP 결과물이면 된다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 7절의 `rm -r build`는 `build` 폴더를 통째로 지운다. 폴더 이름이 `build`가 맞는지 확인한 뒤 실행한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | CMake 버전을 확인한다: `cmake --version` | 3.13 이상이다 |
| 2 | 프로젝트 최상위 폴더로 이동한다 | `ls`에 `CMakeLists.txt`가 보인다 |

## 5. 절차

### A. Ninja 설치

1. (5-A-01) macOS는 아래 명령을 입력한다: `brew install ninja` → 결과: 설치가 오류 없이 끝난다.
2. (5-A-02) Debian/Ubuntu는 아래 명령을 입력한다: `sudo apt install ninja-build` → 결과: 설치가 오류 없이 끝난다.
3. (5-A-03) 설치를 확인한다: `ninja --version` → 결과: 버전 번호가 출력된다.

### B. Ninja용 빌드 파일 생성

1. (5-B-01) 아래 명령을 입력한다.

```bash
cmake -S . -B build -G Ninja
```

→ 결과: `Build files have been written to`가 출력되고 `build/build.ninja` 파일이 생긴다.

### C. 빌드

1. (5-C-01) 아래 명령을 입력한다.

```bash
cmake --build build
```

→ 결과: 컴파일이 끝나고 `build` 폴더 안에 실행 파일이 생긴다.

### D. 재빌드 확인

1. (5-D-01) 소스를 바꾸지 않고 5-C-01의 명령을 다시 입력한다. → 결과: 컴파일이 일어나지 않고 `ninja: no work to do.`가 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `ninja --version` | 버전 출력 | 오류 없음 |
| 2 | `ls build/build.ninja` | 파일이 있다 | 파일이 존재한다 |
| 3 | 5-D-01 | 재빌드가 즉시 끝난다 | `ninja: no work to do.` 출력 |

## 7. 복구

1. (7-01) 빌드 폴더를 지운다: `rm -r build` → 결과: `build` 폴더가 없어진다.
2. (7-02) macOS에서 Ninja를 제거한다: `brew uninstall ninja`
3. (7-03) Debian/Ubuntu에서 Ninja를 제거한다: `sudo apt remove ninja-build`

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 신규 작성. 원본 `ninja.md`의 "사용 방법" 서술을 설치·빌드 절차로 구체화했다 (원본에 없던 명령을 보충) |
