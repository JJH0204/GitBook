---
description: 도움말, 전원, 텍스트 처리, find 시간 옵션 등 기본 명령어 참조
---

# 리눅스 명령어

리눅스 기본 명령어를 주제별 옵션 표로 정리한다. 문서 번호(Task ID)는 `LNX-CMD-<번호>-<유형>` 형식이다. 이 그룹의 문서는 모두 REF(표)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| LNX-CMD-001-REF | 표 | [도움말 명령어 (man, info)](helpcommands.md) | 명령어 사용법과 위치를 찾는다 |
| LNX-CMD-002-REF | 표 | [리눅스 기본 필수 명령어](linuxcommand.md) | 전원, 런레벨, 이동, 목록, 와일드카드 명령을 찾는다 |
| LNX-CMD-003-REF | 표 | [리눅스 명령어 마인드맵](linux_command.md) | 명령어 분류와 상세 문서 위치를 찾는다 |
| LNX-CMD-004-REF | 표 | [기타 유용한 명령어](misccommands.md) | cal, date, time, wall, su 등 단일 명령을 찾는다 |
| LNX-CMD-005-REF | 표 | [텍스트 파일 처리 명령어](textfilecommands.md) | cat, grep, sort, cut 등 텍스트 처리 명령을 찾는다 |
| LNX-CMD-006-REF | 표 | [find 시간 옵션 및 파일 속성](find_time.md) | atime, mtime, ctime과 `find` 시간 조건을 찾는다 |
| LNX-CMD-007-REF | 표 | [[생성형 AI] 프로세스 관리 명령어 (ps, top, kill, nice)](process-commands.md) | 프로세스를 조회, 종료하고 우선순위를 바꾼다 |
| LNX-CMD-008-REF | 표 | [[생성형 AI] 입출력 리다이렉션과 파이프](redirect-pipe.md) | `>`, `2>`, `|` 문법을 찾는다 |
| LNX-CMD-009-REF | 표 | [[생성형 AI] sed·awk 기본](sed-awk.md) | 치환, 열 추출, 집계 문법을 찾는다 |
| LNX-CMD-010-REF | 표 | [[생성형 AI] 시스템 상태 조회 명령어 (free, du, lsblk, uptime)](system-status.md) | 메모리, 용량, 블록 장치, 부하를 조회한다 |

## 읽는 순서

1. LNX-CMD-003-REF로 전체 분류를 본다.
2. 필요한 주제의 문서를 연다.
3. 옵션 설명이 필요하면 LNX-CMD-001-REF로 `man <명령어>`를 확인한다.
