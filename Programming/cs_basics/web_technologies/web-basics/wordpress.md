# Docker 워드프레스 배포 (Wordpress)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRG-WBB-005-MP |
| 목적 | Rocky Linux에 Docker 공식 저장소를 등록한다(워드프레스 배포는 원본이 미완성이라 포함하지 않는다) |
| 적용 대상(Effectivity) | Rocky Linux(RHEL 계열), `dnf`, root 또는 sudo 권한, 테스트 서버 |
| 소요 시간 | 약 5분 |
| 확인 상태 | 미검증 (원본 페이지의 명령을 정리한 것이며 이 문서로 다시 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 "Docker 설치" 단계가 `-`로 비어 있고 워드프레스 배포 단계가 없다. 비어 있는 단계는 지어내지 않았다. 완성 시 이 문서에 이어 쓴다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [webserver.md](webserver.md) | PRG-WBB-004-MP | 웹 서버 설정 및 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 서버 | Rocky Linux, 인터넷 연결 | 테스트용 |
| 2 | 패키지 | `dnf-plugins-core` | `dnf config-manager` 명령을 제공한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 외부 저장소를 등록하면 이후 `dnf` 업데이트가 그 저장소의 패키지를 받는다. 신뢰할 수 있는 공식 주소인지 확인한 뒤 등록한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | root 또는 sudo 권한이 있다 | `id` 결과를 확인한다 |
| 2 | `dnf config-manager`를 쓸 수 있다 | `dnf config-manager --help`가 출력된다. 없으면 `dnf install dnf-plugins-core -y`를 수행한다 |

## 5. 절차

### A. Docker 저장소 등록

Docker 패키지는 기본 Rocky Linux 저장소에 포함되어 있지 않아 Docker 공식 저장소를 추가해야 한다.

1. (5-A-01) 저장소를 추가한다: `dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo` → 결과: 저장소 추가 메시지가 출력된다.

### B. Docker 설치

미완성(원본에 내용 없음).

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `dnf repolist` | Docker 저장소가 목록에 있다 | `docker-ce-stable`이 보인다 |

## 7. 복구

1. (7-01) 저장소 파일을 삭제한다: `rm /etc/yum.repos.d/docker-ce.repo` → 결과: `dnf repolist`에서 Docker 저장소가 사라진다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식(MP)으로 재작성. 미완성 단계는 표시만 했다 |
