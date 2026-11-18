# RHEL 계열 도커 설치

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-006-MP |
| 목적 | RHEL 계열 Linux에 Docker 저장소를 등록하고 도커 엔진을 설치해 서비스를 시작한다 |
| 적용 대상 | RHEL 계열 Linux 8 이상(Rocky Linux 포함), `dnf` 사용, root 권한 |
| 소요 시간 | 약 10분 |
| 확인 상태 | 미검증 (원본 `dockertheory.md`의 설치 단계 요약을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [Ubuntu 환경 도커 설치](docker_install.md) | CLD-DKR-005-MP | Ubuntu용 설치 |
| [도커 핵심 이론](dockertheory.md) | CLD-DKR-002-DO | 원본 설치 요약 위치 |
| [Docker 저장소 (RHEL)](https://download.docker.com/linux/rhel/) | - | 외부 문서 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 설치 대상 서버 | RHEL 계열 8 이상 | |
| 2 | 계정 | root 또는 `sudo` 사용자 | |
| 3 | 네트워크 | `download.docker.com` 접속 가능 | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 이 절차는 시스템에 패키지 저장소를 추가하고 서비스를 부팅 시 자동 시작으로 등록한다. 운영 서버에서는 변경 승인을 받은 뒤 수행한다.
{% endhint %}

{% hint style="info" %}
NOTE: Docker 공식 문서는 RHEL, CentOS, Fedora별로 저장소 경로가 다르다. 이 문서는 원본의 `rhel` 저장소 경로를 따른다. CentOS 계열이면 공식 문서의 해당 경로를 확인한다. 미검증이다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 운영체제 버전을 확인한다: `cat /etc/os-release` | `VERSION_ID`가 8 이상이다 |
| 2 | 도커가 설치돼 있는지 확인한다: `docker --version` | `command not found`가 나온다 |

## 5. 절차

### A. 저장소 등록과 설치

1. (5-A-01) 패키지 관리자를 갱신한다: `dnf makecache` → 결과: 오류 없이 끝난다.
2. (5-A-02) 저장소 관리 도구를 설치한다: `dnf install -y dnf-plugins-core` → 결과: 설치가 끝난다.
3. (5-A-03) Docker 저장소를 추가한다: `dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo` → 결과: `/etc/yum.repos.d/docker-ce.repo` 파일이 생긴다.
4. (5-A-04) 도커 엔진을 설치한다: `dnf install -y docker-ce` → 결과: 설치가 끝난다.
5. (5-A-05) 설치된 버전을 확인한다: `docker --version` → 결과: `Docker version`으로 시작하는 줄이 출력된다.

### B. 서비스 시작

1. (5-B-01) 서비스를 활성화하고 시작한다: `systemctl enable --now docker` → 결과: 오류 없이 끝난다.
2. (5-B-02) 서비스 상태를 확인한다: `systemctl status docker` → 결과: `active (running)`이 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `docker --version` | 버전이 출력된다 | `Docker version` 줄이 나온다 |
| 2 | `systemctl is-active docker` | 서비스가 동작 중이다 | `active`가 출력된다 |
| 3 | `docker run hello-world` | 테스트 이미지가 실행된다 | `Hello from Docker!`가 출력된다 |

## 7. 복구

1. (7-01) 서비스를 중지하고 자동 시작을 해제한다: `systemctl disable --now docker`
2. (7-02) 패키지를 제거한다: `dnf remove -y docker-ce`
3. (7-03) 저장소 파일을 제거한다: `rm /etc/yum.repos.d/docker-ce.repo`

{% hint style="danger" %}
WARNING: 이미지, 컨테이너, 볼륨 데이터는 `/var/lib/docker`에 있다. 이 디렉터리를 삭제하면 모든 도커 데이터가 사라진다. 이 문서에서는 삭제하지 않는다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | `dockertheory.md`의 설치 단계 요약을 독립 MP로 분리. `dnf-plugins-core` 설치, 서비스 상태 확인, 복구 절차를 추가했다 |
