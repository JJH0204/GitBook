
# [생성형 AI] Linux

명령어, 계정·권한, 서비스, 보안, 운영을 정리한 리눅스 노트다. 리눅스마스터 준비 자료도 있다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| 유형 | 스페이스 안내 (허브) |
| 목적 | Linux 스페이스의 구성, 읽는 순서, 문서 표기 규칙을 안내한다 |
| 확인 상태 | 미검증 (링크 구조와 표기 규칙은 SUMMARY 및 각 그룹 README 기준으로 정리했다) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 개정 | R1 (2026-11-19) |

## 묶음 한눈에 보기

| 묶음 | 페이지 |
|---|---|
| **리눅스** | [개요 및 설치](guide/intro/README.md), [기본 사용법](guide/basic-usage/README.md), [리눅스 명령어](guide/commands/README.md), [계정 및 권한 관리](guide/accounts-permissions/README.md), [네트워크 및 원격 접속](guide/network-remote/README.md), [리눅스 보안](guide/security/README.md), [리눅스 서버 서비스](guide/services/README.md), [스토리지 및 부팅](guide/storage-boot/README.md), [시스템 운영 및 관리](guide/operations/README.md), [로깅 및 모니터링](guide/logging-monitoring/README.md), [스크립트 및 자동화](guide/scripting/README.md), [자격증 시험 준비](guide/study/README.md), [참고자료 및 링크](guide/references/README.md), [파일 아카이브 및 압축](guide/archive/README.md) |

## 그룹별 안내

| 그룹 | 다루는 내용 | 문서 번호 접두사 |
|---|---|---|
| [개요 및 설치](guide/intro/README.md) | 리눅스 개요와 역사, VirtualBox 가상 머신 설치 | `LNX-INT` |
| [기본 사용법](guide/basic-usage/README.md) | 디렉터리 구조, `vi` 편집기, 환경 변수 | `LNX-BAS` |
| [리눅스 명령어](guide/commands/README.md) | 도움말, 텍스트 처리, 프로세스, 리다이렉션과 파이프 | `LNX-CMD` |
| [계정 및 권한 관리](guide/accounts-permissions/README.md) | 사용자, 그룹, 비밀번호 정책, 파일 권한, sudo | `LNX-ACC` |
| [네트워크 및 원격 접속](guide/network-remote/README.md) | 네트워크 진단, SSH, VPN, VLAN | `LNX-NRM` |
| [리눅스 보안](guide/security/README.md) | firewalld, iptables, SELinux, TCP 래퍼 | `LNX-SEC` |
| [리눅스 서버 서비스](guide/services/README.md) | NIS 개념, 불필요한 서비스 점검과 비활성화 | `LNX-SVC` |
| [스토리지 및 부팅](guide/storage-boot/README.md) | 파티션, 마운트, 디스크 점검, 부트 로더, 런레벨, LVM | `LNX-STB` |
| [시스템 운영 및 관리](guide/operations/README.md) | 패키지 관리(RPM, DNF), 관리자 가이드 | `LNX-OPS` |
| [로깅 및 모니터링](guide/logging-monitoring/README.md) | 로그 파일, 로그 회전, 성능 통계, journalctl | `LNX-LOG` |
| [스크립트 및 자동화](guide/scripting/README.md) | 쉘 스크립트, cron | `LNX-SCR` |
| [자격증 시험 준비](guide/study/README.md) | 리눅스마스터 2급 안내와 기출 문제 | `LNX-STU` |
| [참고자료 및 링크](guide/references/README.md) | 링커, 하드 링크와 심볼릭 링크 | 해당 그룹 README 참조 |
| [파일 아카이브 및 압축](guide/archive/README.md) | tar, xz, gzip, bzip2 | `LNX-ARC` |

## 읽는 순서

1. 처음이면 [개요 및 설치](guide/intro/README.md)로 실습 환경을 만든다.
2. [기본 사용법](guide/basic-usage/README.md)과 [리눅스 명령어](guide/commands/README.md)로 셸 사용에 익숙해진다.
3. [계정 및 권한 관리](guide/accounts-permissions/README.md)로 사용자와 권한을 다룬다.
4. 서버 운영은 [네트워크 및 원격 접속](guide/network-remote/README.md), [리눅스 보안](guide/security/README.md), [스토리지 및 부팅](guide/storage-boot/README.md), [로깅 및 모니터링](guide/logging-monitoring/README.md), [스크립트 및 자동화](guide/scripting/README.md) 순으로 필요한 것을 고른다.
5. 시험 준비가 목적이면 [자격증 시험 준비](guide/study/README.md)를 먼저 보고 해당 영역의 그룹으로 돌아온다.

## 문서 표기 규칙

- 문서 번호(Task ID)는 `LNX-<그룹>-<번호>-<유형>` 형식이다. 유형은 DO(개념), MP(절차), REF(표), INS(점검)다.
- 제목이 `[생성형 AI]`로 시작하는 문서는 생성형 AI가 작성한 초안이며 사람 검토 전이다.
- 각 문서의 `확인 상태`가 `미검증`이면 실제 환경에서 실행해 확인하지 않은 내용이다. 서버에 적용하기 전에 실습용 가상 머신에서 먼저 실행한다.
- 이 스페이스의 명령은 RHEL 계열(Rocky Linux 등) 실습 환경을 전제로 한 문서가 많다. 배포판이 다르면 패키지 관리자와 설정 파일 경로가 다를 수 있다.
