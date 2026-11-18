---
description: CMake, Ninja, 빌드/배포 흐름 정리
---

# 빌드 시스템 (Build System)

빌드 도구를 "설치 → 설정 → 실행" 순서로 정리한다. 문서 번호(Task ID)는 `DEV-BLD-<번호>-<유형>` 형식이다. 유형은 D&O(개념), MP(절차), REF(표·예제)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| DEV-BLD-001-DO | 개념 | [CMake 개요 및 활용](cmake.md) | CMake가 무엇이고 어떻게 동작하는지 이해한다 |
| DEV-BLD-002-MP | 절차 | [macOS CMake 설치](cmakeinstallationformac.md) | macOS에 CMake를 설치한다 |
| DEV-BLD-003-DO | 개념 | [Ninja 빌드 시스템](ninja.md) | Ninja가 무엇이고 CMake와 어떤 관계인지 이해한다 |
| DEV-BLD-004-MP | 절차 | [CMakeLists.txt 작성 가이드](cmakelists.txt.md) | 최소 `CMakeLists.txt`를 작성한다 |
| DEV-BLD-005-MP | 절차 | [Ninja 설치와 CMake 빌드](ninjabuild.md) | Ninja를 설치하고 CMake 프로젝트를 빌드한다 |
| DEV-BLD-006-REF | 표·예제 | [CMakeLists.txt 예제 모음](cmakelistsreference.md) | 명령어 표와 다중 프로젝트 예제를 참조한다 |
| DEV-BLD-007-MP | 절차 | [[생성형 AI] Makefile 작성과 make 사용](make-basics.md) | 최소 Makefile로 증분 빌드를 확인한다 |

## 읽는 순서

1. DEV-BLD-001-DO로 CMake의 역할을 이해한다.
2. DEV-BLD-002-MP로 CMake를 설치한다.
3. DEV-BLD-004-MP로 `CMakeLists.txt`를 작성한다.
4. DEV-BLD-003-DO와 DEV-BLD-005-MP로 Ninja를 설치하고 빌드한다.
