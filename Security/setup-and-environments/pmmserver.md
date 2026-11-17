# PMM 모니터링 서버 구축

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | SEC-ENV-005-MP |
| 목적 | Docker로 Percona Monitoring and Management(PMM) 서버를 설치하고 실행한다 |
| 적용 대상 | 허가받은 격리 실습 환경. `dnf`를 쓰는 RHEL 계열 Linux VM, 관리자 권한 |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본 명령을 정리한 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: PMM은 설치 방식이 소스 코드, 패키지 관리자(클라이언트), Docker(서버)로 나뉜다. 이 문서는 서버를 Docker로 설치한다. 클라이언트(에이전트) 설정은 [pmmagent.md](pmmagent.md)(SEC-ENV-006-MP)를 따른다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [pmmagent.md](pmmagent.md) | SEC-ENV-006-MP | PMM 에이전트 설정 |
| Percona PMM 공식 문서 | - | 서버 설치, 기본 계정 안내 (공식 사이트에서 확인) |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Linux VM | RHEL 계열(`dnf` 사용), 격리 네트워크 | 예: `192.168.56.x` |
| 2 | Docker | `dnf`로 설치 | |
| 3 | 컨테이너 이미지 | `percona/pmm-server` | 공식 이미지 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: PMM 서버는 443 포트를 공개한다. 인터넷에 직접 노출하지 않고 호스트 전용 또는 격리 네트워크에서만 실행한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 기본 계정은 공식 문서를 확인하고, 첫 로그인 후 즉시 비밀번호를 변경한다. 이 문서에 비밀번호를 적지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | VM에서 인터넷(패키지 저장소) 접근이 되는지 확인한다 | `dnf` 명령이 저장소에 접속한다 |
| 2 | 443 포트가 비어 있는지 확인한다 | `ss -tlnp`에 443이 없다 |

## 5. 절차

**A. Docker 설치**

1. (SUBTASK 5-A-01) 패키지를 갱신한다: `dnf update -y` → 결과: 갱신이 끝난다.
2. (SUBTASK 5-A-02) Docker를 설치한다: `dnf install -y docker` → 결과: 설치가 끝난다.

**B. 이미지와 볼륨 준비**

1. (SUBTASK 5-B-01) 이미지를 받는다: `docker pull percona/pmm-server:latest` → 결과: 다운로드가 끝난다.
2. (SUBTASK 5-B-02) 이미지를 확인한다: `docker images` → 결과: `percona/pmm-server`가 목록에 있다.
3. (SUBTASK 5-B-03) 데이터 볼륨을 만든다: `docker volume create pmm-data` → 결과: `pmm-data`가 출력된다.

**C. 서버 실행**

1. (SUBTASK 5-C-01) 컨테이너를 실행한다. → 결과: 컨테이너 ID가 출력된다.

```sh
docker run --detach --restart always --publish 443:443 -v pmm-data:/srv --name pmm-server docker.io/percona/pmm-server:latest
```

2. (SUBTASK 5-C-02) 실행 상태를 확인한다: `docker ps` → 결과: `pmm-server`의 상태가 `Up`이다. 중지된 컨테이너까지 보려면 `docker ps -a`를 쓴다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 브라우저에서 `https://<서버 IP>/`를 연다 | PMM 로그인 화면이 나타난다 | 인증서 경고는 자체 서명 인증서 때문이다 |
| 2 | 공식 문서의 기본 계정으로 로그인한다 | 대시보드가 열린다 | 비밀번호 변경 요구가 나오면 변경한다 |

## 7. 복구

1. (SUBTASK 7-01) 컨테이너를 중지하고 삭제한다: `docker stop pmm-server` 후 `docker rm pmm-server` → 결과: `docker ps -a`에 없다.
2. (SUBTASK 7-02) 수집 데이터까지 지우려면 볼륨을 삭제한다: `docker volume rm pmm-data` → 결과: 데이터가 복구되지 않는다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 서버 설치와 에이전트 설정을 분리(에이전트는 `pmmagent.md`). 원본의 기본 계정 비밀번호를 삭제 |
