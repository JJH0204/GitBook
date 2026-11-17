---
description: Code Runner 터미널 실행, C/C++ 개발 환경, macOS 설정 파일
---

# VS Code 가이드

VS Code에서 C/C++ 코드를 실행하고 디버깅하는 설정을 모았다. 문서 번호(Task ID)는 `DEV-VSC-<번호>-<유형>` 형식이다. 유형은 MP(절차), REF(참조)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| DEV-VSC-001-MP | 절차 | [VS Code 터미널 실행 설정](runinterminalsetup.md) | Code Runner의 실행 결과를 터미널에서 보게 한다 |
| DEV-VSC-002-REF | 참조 | [VS Code C 및 C++ 개발 환경 설정](vscodecppdevelopment.md) | 환경별 설치 문서, 확장, 참고 자료를 참조한다 |
| DEV-VSC-003-MP | 절차 | [macOS VS Code C 및 C++ 설정](vs-code-macos.md) | macOS에서 빌드·디버그 설정 파일을 만들고 실행한다 |
| DEV-VSC-004-REF | 참조 | [macOS VS Code C 및 C++ 설정 파일 예시](vscodemacosjson.md) | `c_cpp_properties.json`, `launch.json`, `tasks.json` 내용을 참조한다 |

## 읽는 순서

1. DEV-VSC-002-REF에서 자신의 OS에 맞는 설치 문서를 확인한다.
2. macOS라면 DEV-VSC-003-MP를 수행한다. 설정 파일 내용은 DEV-VSC-004-REF에 있다.
3. 실행 결과를 터미널에서 보려면 DEV-VSC-001-MP를 수행한다.
