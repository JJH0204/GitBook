---
description: 기본 설정, SSH 키, GitHub Desktop, 명령어, VS Code 연동
---

# Git 가이드 (Git)

Git을 처음 쓰는 PC에서 필요한 절차를 모았다. 문서 번호(Task ID)는 `DEV-GIT-<번호>-<유형>` 형식이다. 유형은 MP(절차), REF(참조)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| DEV-GIT-001-MP | 절차 | [사용하지 않는 PC의 Git 접근 해제](gitdisconnect.md) | 쓰지 않는 PC의 Git 사용자 정보, SSH 키, 자격 증명을 제거한다 |
| DEV-GIT-002-MP | 절차 | [Git 기본 설정](git.md) | 사용자 이름과 이메일을 설정한다. 외부 참조 링크를 모았다 |
| DEV-GIT-003-MP | 절차 | [Git SSH 키 생성과 등록](gitsshkey.md) | SSH 키를 만들어 GitHub에 등록한다 |
| DEV-GIT-004-MP | 절차 | [Git 사용법 (GitHub Desktop)](how2usegit.md) | GitHub Desktop으로 저장소를 만들고 커밋·푸시한다 |
| DEV-GIT-005-REF | 참조 | [Git Bash 기본 명령어](gitbashcommands.md) | clone, add, commit, push, pull 명령을 참조한다 |
| DEV-GIT-006-REF | 참조 | [VS Code Git 및 GitHub 연동](vscodegithubintegration.md) | VS Code의 Git 연동 자료를 참조한다 |

## 읽는 순서

1. DEV-GIT-002-MP로 사용자 정보를 설정한다.
2. SSH로 접속하려면 DEV-GIT-003-MP를 수행한다.
3. GUI로 쓰려면 DEV-GIT-004-MP, 명령어로 쓰려면 DEV-GIT-005-REF를 본다.
4. VS Code에서 쓰려면 DEV-GIT-006-REF를 본다.
5. PC를 더 이상 쓰지 않을 때 DEV-GIT-001-MP를 수행한다.
