# 리눅스 기초 대시보드 (Linux Basic)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-LBS-001-REF |
| 유형 | REF (링크 표) |
| 목적 | 리눅스 기초 학습에 필요한 문서를 Linux 스페이스에서 찾아 연결한다 |
| 확인 상태 | 미검증 (원본 페이지의 링크 목록을 정리한 것이며 문서 내용은 각 링크 문서를 따른다) |
| 개정 | R1 (2026-11-18) |

리눅스 상세 문서는 Linux 스페이스에 있다. 이 페이지는 클라우드 학습에 필요한 리눅스 문서로 가는 길만 모은다.

## 1. 추천 학습 순서

1. 개요와 설치: [리눅스 개요와 설치](../../Linux/guide/intro/README.md)
2. 기본 사용: [리눅스 기본 사용](../../Linux/guide/basic-usage/README.md)
3. 명령어: [리눅스 명령어](../../Linux/guide/commands/README.md)
4. 운영 주제: [계정·권한](../../Linux/guide/accounts-permissions/README.md), [네트워크·원격](../../Linux/guide/network-remote/README.md), [보안](../../Linux/guide/security/README.md)

## 2. 주제별 문서

| 주제 | 문서 |
|---|---|
| 개요·설치 | [intro](../../Linux/guide/intro/README.md) |
| 기본 사용 | [basic-usage](../../Linux/guide/basic-usage/README.md) |
| 명령어 | [commands](../../Linux/guide/commands/README.md) |
| 계정·권한 | [accounts-permissions](../../Linux/guide/accounts-permissions/README.md) |
| 네트워크·원격 | [network-remote](../../Linux/guide/network-remote/README.md) |
| 보안 | [security](../../Linux/guide/security/README.md) |
| 서비스 | [services](../../Linux/guide/services/README.md) |
| 스토리지·부팅 | [storage-boot](../../Linux/guide/storage-boot/README.md) |
| 운영·관리 | [operations](../../Linux/guide/operations/README.md) |
| 로깅·모니터링 | [logging-monitoring](../../Linux/guide/logging-monitoring/README.md) |
| 스크립트·자동화 | [scripting](../../Linux/guide/scripting/README.md) |
| 시험·학습 | [study](../../Linux/guide/study/README.md) |
| 링크·참고 | [references](../../Linux/guide/references/README.md) |
| 아카이브 | [archive](../../Linux/guide/archive/README.md) |

## 3. 자주 쓰는 레퍼런스

| 항목 | 문서 | Task ID |
|---|---|---|
| 기본 필수 명령어 | [리눅스 기본 필수 명령어](../../Linux/guide/commands/linuxcommand.md) | LNX-CMD-002-REF |
| 권한과 소유권 | [파일 및 디렉터리 접근 권한](../../Linux/guide/accounts-permissions/permission.md) | LNX-ACC-008-DO |
| 네트워크 명령어 | [네트워크 진단 명령어](../../Linux/guide/network-remote/networkcommands.md) | LNX-NRM-001-REF |
| 원격 접속(SSH) | [VS Code 원격 SSH 연결](../../Linux/guide/network-remote/remote-ssh.md) | LNX-NRM-003-MP |
| 마운트 | [파일 시스템 마운트 (mount)](../../Linux/guide/storage-boot/mount.md) | LNX-STB-008-REF |
| 작업 예약(cron) | [작업 예약 스케줄러 (cron)](../../Linux/guide/scripting/cron.md) | LNX-SCR-006-DO |
| 패키지 관리(dnf, rpm) | [패키지 관리 도구 (RPM, DNF)](../../Linux/guide/operations/linuxpackagemanagementtool.md) | LNX-OPS-002-REF |

## 4. 참조

| 참조 문서 | 비고 |
|---|---|
| [가상 머신 복제 (VirtualBox)](https://www.whatwant.com/entry/VirtualBox-Copy) | 외부 문서 |
| [가상 머신 공유 폴더와 파일 복사](https://www.wookoa.com/2024/01/how-to-share-and-copy-vmware-virtual-machine-files.html) | 외부 문서 |
| [리눅스 마스터 기출 문제](https://www.ihd.or.kr/guidequestion.do) | 외부 문서 |

{% hint style="info" %}
NOTE: 아래 두 표현은 같은 디렉터리를 가리킨다. 사용자 이름이 `<사용자명>`일 때 `cd /home/<사용자명>`과 `cd ~<사용자명>`은 같다.
{% endhint %}

다음 단계: 서버 운영은 [운영·관리](../../Linux/guide/operations/README.md)로 이어진다.
