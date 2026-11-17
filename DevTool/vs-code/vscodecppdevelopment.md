# VS Code C 및 C++ 개발 환경 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | DEV-VSC-002-REF |
| 유형 | REF (설치 문서·확장·참고 자료 표) |
| 목적 | VS Code에서 C/C++ 개발 환경을 만들 때 필요한 문서와 확장을 참조한다 |
| 확인 상태 | 미검증 (원본 페이지의 링크를 표로 정리한 것이며 링크 내용을 이 환경에서 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 같은 주제가 Programming 스페이스의 [VS Code C/C++ 환경 설정](../../Programming/languages/c-and-c++/setup/intro.md)에도 있다. 이 스페이스(DevTool)는 환경 설정 절차를 다루고, Programming은 C/C++ 개념과 학습 흐름을 다룬다. 설정 절차는 이 문서와 아래 표의 문서를 정본으로 한다.
{% endhint %}

## 1. 환경별 설치 문서

| 환경 | 문서 | 설명 |
|---|---|---|
| Windows | [윈도우 VSCode C/C++ 초기 세팅](https://m.blog.naver.com/dorergiverny/221889473340) | Windows에서 VS Code를 C/C++ 용으로 세팅하는 블로그 글 |
| Windows | [Windows MinGW-w64 설치](../compiler-debug/mingww64installation.md) | 컴파일러 MinGW-w64 설치 절차 |
| macOS | [macOS VS Code C 및 C++ 설정](vs-code-macos.md) | 빌드·디버그 설정 파일 절차 (DEV-VSC-003-MP) |
| macOS | [macOS 환경 변수 설정](../env-setup/macosenvvariablesetup.md) | 환경 변수 확인과 설정 절차 |
| macOS | [맥 OS에서 VSCode C/C++ 초기 세팅](../../Programming/languages/c-and-c++/setup/intro.md) | Programming 스페이스의 설정 문서 |
| 공통 | [VS Code Git 및 GitHub 연동](../git/vscodegithubintegration.md) | VS Code에서 Git을 쓰는 자료 (DEV-GIT-006-REF) |
| 공통 | [VS Code 개발 환경 글](https://growing-dev101.tistory.com/entry/%EA%B0%9C%EB%B0%9C-%ED%99%98%EA%B2%BD-VS-Code) | VS Code 개발 환경 구성 블로그 글 |

{% hint style="info" %}
NOTE: macOS의 `gcc` 명령은 GNU GCC가 아니라 Apple clang의 별칭이다. macOS 설정 파일이 `clang`과 `clang++`를 쓰는 이유다.
{% endhint %}

## 2. 확장(Extension)

| 확장 | 용도 |
|---|---|
| [Korean Language Pack for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=MS-CEINTL.vscode-language-pack-ko) | VS Code 화면을 한국어로 바꾼다 |
| [Translator (sculove)](https://marketplace.visualstudio.com/items?itemName=sculove.translator) | 구글 번역기로 선택한 텍스트를 번역한다 |
| [GitHub Theme](https://marketplace.visualstudio.com/items?itemName=GitHub.github-vscode-theme) | GitHub 스타일 색 테마 |
| [vscode-icons](https://marketplace.visualstudio.com/items?itemName=vscode-icons-team.vscode-icons) | 파일 아이콘 |
| [TODO Highlight](https://marketplace.visualstudio.com/items?itemName=wayou.vscode-todo-highlight) | `TODO` 같은 주석 표시를 강조한다 |
| [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one) | 마크다운 편집 보조 |
| [indent-rainbow](https://marketplace.visualstudio.com/items?itemName=oderwat.indent-rainbow) | 들여쓰기 단계를 색으로 구분한다 |

## 3. 팁

| 자료 | 설명 |
|---|---|
| [YouTube 영상](https://www.youtube.com/watch?v=r750vOVbS9M) | VS Code 사용 팁 영상 |
| [VS Code 팁 블로그 글](https://gyuha.tistory.com/534) | VS Code 사용 팁 정리 |

## 4. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 링크 목록을 참조 표로 정리하고 Programming 스페이스와의 정본 구분을 NOTE로 명시 |
