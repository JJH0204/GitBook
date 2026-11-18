---
description: 기본 설정, SSH 키, GitHub Desktop, 명령어, VS Code 연동
---

# Git 가이드 (Git)

Git을 처음 쓰는 PC에서 필요한 절차를 모았다. 문서 번호(Task ID)는 `DEV-GIT-<번호>-<유형>` 형식이다. 유형은 D&O(개념), MP(절차), TS(문제 해결), REF(참조)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| DEV-GIT-001-MP | 절차 | [사용하지 않는 PC의 Git 접근 해제](gitdisconnect.md) | 쓰지 않는 PC의 Git 사용자 정보, SSH 키, 자격 증명을 제거한다 |
| DEV-GIT-002-MP | 절차 | [Git 기본 설정](git.md) | 사용자 이름과 이메일을 설정한다. 외부 참조 링크를 모았다 |
| DEV-GIT-003-MP | 절차 | [Git SSH 키 생성과 등록](gitsshkey.md) | SSH 키를 만들어 GitHub에 등록한다 |
| DEV-GIT-004-MP | 절차 | [Git 사용법 (GitHub Desktop)](how2usegit.md) | GitHub Desktop으로 저장소를 만들고 커밋·푸시한다 |
| DEV-GIT-005-REF | 참조 | [Git Bash 기본 명령어](gitbashcommands.md) | clone, add, commit, push, pull 명령을 참조한다 |
| DEV-GIT-006-REF | 참조 | [VS Code Git 및 GitHub 연동](vscodegithubintegration.md) | VS Code의 Git 연동 자료를 참조한다 |
| DEV-GIT-007-DO | 개념 | [[생성형 AI] Git 기본 개념 — 작업 트리·스테이징·커밋](git-concepts.md) | 세 영역과 커밋이 만들어지는 흐름을 이해한다 |
| DEV-GIT-008-MP | 절차 | [[생성형 AI] 브랜치 만들기와 병합](git-branch-merge.md) | 브랜치에서 작업하고 `main`에 병합한다 |
| DEV-GIT-009-TS | 문제 해결 | [[생성형 AI] 병합 충돌 해결](git-merge-conflict.md) | `CONFLICT`가 났을 때 해결하거나 취소한다 |
| DEV-GIT-010-REF | 참조 | [[생성형 AI] 변경 되돌리기 명령 정리](git-undo.md) | `restore`, `reset`, `revert`, `reflog`를 상황별로 고른다 |
| DEV-GIT-011-MP | 절차 | [[생성형 AI] .gitignore 작성](gitignore.md) | 커밋하지 않을 파일을 지정한다 |
| DEV-GIT-012-MP | 절차 | [[생성형 AI] 변경 임시 저장 (stash)](git-stash.md) | 커밋 전 변경을 치워 두었다가 꺼낸다 |
| DEV-GIT-013-MP | 절차 | [[생성형 AI] 원격 저장소와 push·pull](git-remote-sync.md) | `push`, `fetch`, `pull`의 차이를 로컬 원격으로 연습한다 |
| DEV-GIT-014-REF | 참조 | [[생성형 AI] 상태·이력 확인 명령 정리](git-inspect.md) | `status`, `diff`, `log`, `blame` 등 읽기 명령을 참조한다 |

## 읽는 순서

1. DEV-GIT-002-MP로 사용자 정보를 설정한다.
2. SSH로 접속하려면 DEV-GIT-003-MP를 수행한다.
3. GUI로 쓰려면 DEV-GIT-004-MP, 명령어로 쓰려면 DEV-GIT-005-REF를 본다.
4. VS Code에서 쓰려면 DEV-GIT-006-REF를 본다.
5. PC를 더 이상 쓰지 않을 때 DEV-GIT-001-MP를 수행한다.
