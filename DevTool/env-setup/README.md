---
description: macOS/Windows 개발 환경, Python/IDE 세팅
---

# 개발 환경 설정 (Environment Setup)

새 PC를 세팅할 때 필요한 절차를 모았다. 문서 번호(Task ID)는 `DEV-ENV-<번호>-<유형>` 형식이다. 유형은 D&O(개념), MP(절차)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| DEV-ENV-001-MP | 절차 | [macOS Python 환경 설정](pythonidesetupformac.md) | macOS에서 Python 버전·경로를 확인하고 pyenv를 설치한다 |
| DEV-ENV-002-MP | 절차 | [macOS 환경 변수 설정](macosenvvariablesetup.md) | macOS에서 환경 변수를 확인하고 설정한다 |
| DEV-ENV-003-MP | 절차 | [Windows Python 환경 설정 (pyenv)](pythonsettingwin.md) | Windows에 pyenv-win과 venv 가상환경을 만든다 |
| DEV-ENV-004-DO | 개념 | [Poetry 패키지 관리자](poetry.md) | Poetry의 역할과 pip + venv와의 차이를 이해한다 |
| DEV-ENV-005-MP | 절차 | [Poetry 설치와 사용](poetryinstallation.md) | Poetry를 설치하고 프로젝트를 만든다 |

## 읽는 순서

1. macOS라면 DEV-ENV-002-MP로 환경 변수 개념을 익힌 뒤 DEV-ENV-001-MP를 수행한다.
2. Windows라면 DEV-ENV-003-MP를 수행한다.
3. DEV-ENV-004-DO로 Poetry 개념을 이해한다.
4. DEV-ENV-005-MP로 Poetry를 설치하고 프로젝트를 만든다.
