# macOS VS Code C 및 C++ 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-VSC-003-MP |
| 목적 | macOS의 VS Code에서 C/C++ 활성 파일을 clang++로 빌드하고 lldb로 디버그하는 설정 파일 3개를 만든다 |
| 적용 대상 | macOS, VS Code, C/C++ 확장(Microsoft), Xcode Command Line Tools |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 페이지의 설정 파일을 절차로 옮긴 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: macOS의 `gcc`는 GNU GCC가 아니라 Apple clang의 별칭이다. 이 문서는 `clang`과 `clang++`를 직접 쓴다.
{% endhint %}

{% hint style="info" %}
NOTE: 디버깅에는 `tasks.json`(빌드)과 `launch.json`(디버거 실행)이 둘 다 필요하다. `c_cpp_properties.json`만 있으면 자동 완성은 되지만 F5 디버깅은 되지 않는다. 각 필드의 설명은 원본에 없었으므로 확인 필요 항목으로 남긴다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [vscodemacosjson.md](vscodemacosjson.md) | DEV-VSC-004-REF | macOS VS Code C 및 C++ 설정 파일 예시 |
| [vscodecppdevelopment.md](vscodecppdevelopment.md) | DEV-VSC-002-REF | VS Code C 및 C++ 개발 환경 설정 |
| [intro.md](../../Programming/languages/c-and-c++/setup/intro.md) | | Programming 스페이스의 C/C++ 환경 설정 개념 문서 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양 | 비고 |
|---|---|---|---|
| 1 | VS Code | 최신 버전 | |
| 2 | C/C++ 확장 | Microsoft 제작 (`ms-vscode.cpptools`) | `cppdbg` 디버그 유형을 제공한다 |
| 3 | Xcode Command Line Tools | `/usr/bin/clang++`가 있어야 한다 | 터미널에서 `xcode-select --install`로 설치한다 |

## 3. 안전 사항

{% hint style="info" %}
NOTE: 이 절차는 작업 폴더의 `.vscode/` 안에 파일을 만든다. 같은 이름의 파일이 이미 있으면 내용을 덮어쓰기 전에 백업한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 컴파일러가 있는지 확인한다 | 터미널에서 `clang++ --version`이 버전을 출력한다 |
| 2 | C/C++ 확장이 설치돼 있는지 확인한다 | 확장 탭의 설치됨 목록에 있다 |
| 3 | Apple Silicon인지 Intel인지 확인한다 | 이 Mac 정보에서 칩을 확인한다. Intel이면 DEV-VSC-004-REF의 NOTE에 따라 `intelliSenseMode`를 바꾼다 |

## 5. 절차

### A. 설정 파일 만들기

1. (5-A-01) 작업 폴더를 VS Code로 연다. → 결과: 탐색기에 폴더 내용이 보인다.
2. (5-A-02) 작업 폴더 안에 `.vscode` 폴더를 만든다. → 결과: `.vscode` 폴더가 보인다.
3. (5-A-03) `.vscode/c_cpp_properties.json`을 만들고 DEV-VSC-004-REF의 내용을 붙여 넣는다.
4. (5-A-04) `.vscode/tasks.json`을 만들고 DEV-VSC-004-REF의 내용을 붙여 넣는다.
5. (5-A-05) `.vscode/launch.json`을 만들고 DEV-VSC-004-REF의 내용을 붙여 넣는다. → 결과: 세 파일 모두 저장돼 있다.

### B. 빌드와 디버그 실행

1. (5-B-01) `.cpp` 소스 파일을 연다. → 결과: 편집기에 파일이 열린다.
2. (5-B-02) 실행할 줄의 왼쪽 여백을 눌러 중단점을 만든다. → 결과: 빨간 점이 나타난다.
3. (5-B-03) `F5`를 누른다. → 결과: 빌드 작업이 실행되고 중단점에서 멈춘다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 소스 파일 폴더를 확인한다 | 파일 이름과 같은 실행 파일이 생겼다 | 확장자 없는 실행 파일이 있다 |
| 2 | `F5`로 디버그한다 | 중단점에서 멈춘다 | 변수 패널에 값이 보인다 |

## 7. 복구

1. (7-01) `.vscode` 폴더의 세 파일을 삭제하거나 백업본으로 되돌린다. → 결과: 빌드·디버그 설정이 제거된다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | JSON 예시를 DEV-VSC-004-REF로 분리하고 파일 생성·실행 절차를 추가 |
