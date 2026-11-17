---
description: 쉘 스크립트 문법과 실습, 로그 정리 스크립트, cron 예약 작업
---

# 스크립트 및 자동화

쉘 스크립트로 반복 작업을 만들고 cron으로 주기 실행하는 방법을 다룬다. 문서 번호(Task ID)는 `LNX-SCR-<번호>-<유형>` 형식이다. 유형은 D&O(개념), MP(절차), REF(표)다. 삭제나 덮어쓰기를 하는 스크립트와 cron 등록은 반복 실행되어 복구할 수 없으므로 각 문서의 WARNING을 먼저 읽는다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| LNX-SCR-001-DO | 개념 | [쉘 스크립트 프로그래밍 기초](shell-script.md) | 쉘 종류, 셔뱅, 변수 범위, 실행 방식을 이해한다 |
| LNX-SCR-002-REF | 표 | [쉘 스크립트 문법 참조](shell-script-syntax.md) | 변수, 조건, 반복, 배열, 함수, 종료 코드 문법을 찾는다 |
| LNX-SCR-003-MP | 절차 | [쉘 스크립트 작성과 실행](shell-script-practice.md) | 스크립트 네 개를 작성하고 실행 권한을 주어 실행한다 |
| LNX-SCR-004-MP | 절차 | [오래된 로그 파일 정리 스크립트 작성](shell-script-logclean.md) | 오래된 로그를 압축·삭제하는 스크립트를 만든다 |
| LNX-SCR-005-REF | 표 | [쉘 스크립트 작성 실습 예제](scripts.md) | Nmap NSE 스크립트 `http-wordpress-brute`의 사양을 찾는다 |
| LNX-SCR-006-DO | 개념 | [작업 예약 스케줄러 (cron)](cron.md) | cron 구조, 시간 필드, 실행 환경을 이해한다 |
| LNX-SCR-007-MP | 절차 | [cron 작업 등록과 확인](cron-register.md) | 작업을 등록하고 로그로 확인한 뒤 제거한다 |
| LNX-SCR-008-REF | 표 | [cron 시간 문법 참조](cron-syntax.md) | 시간 표기, 특수 문자, 예약어를 찾는다 |

## 읽는 순서

1. LNX-SCR-001-DO로 개념을 익힌다.
2. LNX-SCR-003-MP로 스크립트를 작성하고 실행한다. 문법이 필요하면 LNX-SCR-002-REF를 본다.
3. LNX-SCR-004-MP로 로그 정리 스크립트를 만든다.
4. LNX-SCR-006-DO를 읽고 LNX-SCR-007-MP로 스크립트를 주기 실행에 등록한다. 시간 표기는 LNX-SCR-008-REF를 본다.
