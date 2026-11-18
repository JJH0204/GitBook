---
description: MariaDB 보안 설정, 명령어, 계정 관리, 원격 접속, 서버 자원 확인
---

# 데이터베이스 운영 및 관리

MariaDB 서버를 설정하고 운영하는 문서를 모았다. 문서 번호(Task ID)는 `DB-OPS-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| DB-OPS-001-MP | 절차 | [MariaDB 기본 사용법](mariadb.md) | 서비스 상태를 확인하고 보안 설정 후 root로 접속한다 |
| DB-OPS-002-REF | 표 | [MariaDB 명령어 참조](mariadb-commands.md) | 데이터베이스·테이블·행 명령을 찾는다 |
| DB-OPS-003-REF | 표 | [DB 서버 자원 확인과 성능 튜닝](dbperformanceinfo.md) | 메모리, swap, CPU, 디스크를 확인하고 swappiness를 조정한다 |
| DB-OPS-004-MP | 절차 | [DB 사용자 계정 생성과 권한 관리](dbusermanagement.md) | 계정을 만들고 권한을 부여·회수하고 계정을 삭제한다 |
| DB-OPS-005-MP | 절차 | [MariaDB 원격 접속 허용 설정](mariadb-remote-access.md) | `bind-address`, 포트, 방화벽을 설정해 원격 접속을 연다 |
| DB-OPS-006-MP | 절차 | [[생성형 AI] MariaDB 논리 백업과 복원](mariadb-backup-restore.md) | `mysqldump`로 백업하고 새 데이터베이스에 복원해 확인한다 |
| DB-OPS-007-DO | 개념 | [[생성형 AI] SQL 인젝션 방어](sql-injection-defense.md) | 바인딩과 최소 권한으로 SQL 인젝션을 막는 방법을 이해한다 |

## 읽는 순서

1. DB-OPS-001-MP로 보안 설정을 마친다.
2. DB-OPS-004-MP로 계정을 만든다.
3. 원격 접속이 필요하면 DB-OPS-005-MP를 수행한다.
4. 명령이 필요하면 DB-OPS-002-REF, 서버 자원 확인은 DB-OPS-003-REF를 본다.
