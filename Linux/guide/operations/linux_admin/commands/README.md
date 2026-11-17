---
description: 디렉터리, 파일, 비교, 일반 시스템 명령어와 CentOS 기준 관리 명령 참조
---

# 관리자 기본 명령어

관리자가 서버에서 자주 쓰는 명령어를 명령별 옵션 표로 정리한다. 문서 번호(Task ID)는 `LNX-LAC-<번호>-<유형>` 형식이다. 이 그룹의 문서는 개념 설명(DO) 2개와 표(REF) 6개다.

{% hint style="info" %}
NOTE: 같은 스페이스의 [리눅스 명령어](../../../commands/README.md) 그룹(`LNX-CMD-*`)과 일부 명령이 겹친다. 겹치는 명령은 이 그룹에서 한 줄로 요약하고 그 그룹의 문서로 연결한다.
{% endhint %}

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| LNX-LAC-001-DO | 개념 | [파이썬 가상환경과 커널](aboutvirtualenvandkernel.md) | 가상환경과 커널의 두 가지 뜻을 구분한다 |
| LNX-LAC-002-REF | 표 | [별칭 및 경로 명령어 (alias, which)](accountmanagementcommands.md) | 별칭 설정과 명령 경로 확인 명령을 찾는다 |
| LNX-LAC-003-REF | 표 | [디렉터리 조작 명령어 (pwd, cd, mkdir)](directorycommands.md) | 디렉터리 이동·생성·삭제 명령을 찾는다 |
| LNX-LAC-004-DO | 개념 | [브라우저 자바스크립트 콘솔](console.md) | 브라우저 콘솔의 용도와 여는 방법을 확인한다 |
| LNX-LAC-005-REF | 표 | [CentOS 기본 명령어 모음](centos-basic-command.md) | RHEL 계열의 자동 업데이트, IP 설정, 경로, 편집기 명령을 찾는다 |
| LNX-LAC-006-REF | 표 | [파일 비교 명령어 (diff, cmp, comm)](filecomparisoncommands.md) | 두 파일을 비교하는 명령을 찾는다 |
| LNX-LAC-007-REF | 표 | [파일 조작 명령어 (ls, cp, rm)](filecommands.md) | 파일 목록·복사·이동·삭제·검색 명령을 찾는다 |
| LNX-LAC-008-REF | 표 | [일반 시스템 명령어 (history, tree, su)](generalcommands.md) | 달력, 시간, 메시지, 사용자 전환 등 단일 명령을 찾는다 |

## 읽는 순서

1. LNX-LAC-003-REF로 디렉터리 명령을 익힌다.
2. LNX-LAC-007-REF로 파일 명령을 익힌다.
3. 필요할 때 LNX-LAC-006-REF, LNX-LAC-008-REF를 찾아본다.
4. CentOS 계열 서버를 다룰 때 LNX-LAC-005-REF를 본다.
