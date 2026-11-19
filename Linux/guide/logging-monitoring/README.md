---
description: 로그 파일, 로그 회전, 로그 보고서, 성능 통계
---

# 로깅 및 모니터링

시스템 로그 파일의 위치와 읽는 법, 로그 회전, 로그 요약 보고서, 성능 통계 수집을 다룬다. 문서 번호(Task ID)는 `LNX-LOG-<번호>-<유형>` 형식이다. 유형은 D&O(개념), MP(절차), REF(표)다. 이 폴더의 명령은 실습용 가상 환경(RHEL 계열 9)을 전제로 한다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| LNX-LOG-001-REF | 표 | [시스템 로그 파일 분석 (/var/log)](log_file.md) | 로그 파일 위치와 조회 명령을 찾는다 |
| LNX-LOG-002-DO | 개념 | [로그 회전 관리 (Logrotate)](logrotate.md) | logrotate 동작 방식과 설정 지시자를 이해한다 |
| LNX-LOG-003-MP | 절차 | [로그 분석 및 보고 (Logwatch)](logwatch.md) | logwatch를 설치하고 보고서를 만든다 |
| LNX-LOG-004-MP | 절차 | [시스템 성능 모니터링 (sysstat)](sysstat.md) | sysstat을 설치하고 수집을 확인한다 |
| LNX-LOG-005-REF | 표 | [sar·iostat 명령 참조 (sysstat)](sysstatcommands.md) | 성능 통계 명령과 옵션을 찾는다 |
| LNX-LOG-006-MP | 절차 | [[생성형 AI] journalctl로 systemd 로그 조회](journalctl.md) | 서비스, 부팅, 시간, 우선순위별 로그를 조회한다 |

## 읽는 순서

1. LNX-LOG-001-REF로 로그 파일 위치와 조회 명령을 익힌다.
2. LNX-LOG-002-DO로 로그가 쌓이고 지워지는 방식을 이해한다.
3. LNX-LOG-003-MP로 로그 요약 보고서를 만든다.
4. LNX-LOG-004-MP로 성능 통계 수집을 켜고 LNX-LOG-005-REF로 결과를 읽는다.
