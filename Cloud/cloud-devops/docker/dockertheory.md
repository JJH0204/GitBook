# 도커 핵심 이론 (Docker)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-DKR-002-DO |
| 유형 | D&O (개념) |
| 목적 | 가상 머신과 컨테이너의 구조 차이, 도커 명령어 분류, 이미지 태그, 볼륨, 컨테이너 수명 주기를 설명한다 |
| 확인 상태 | 미검증 (원본 메모와 일반 지식을 정리한 것이며 이 환경에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 설치 단계, 명령어 메모, 스크립트가 섞여 있었다. 설치는 [RHEL 계열 도커 설치](docker-install-rhel.md)(CLD-DKR-006-MP), 실행과 삭제는 [도커 컨테이너 실행과 관리](docker-container-run.md)(CLD-DKR-008-MP), 명령 표는 [도커 필수 명령어](docker_commend.md)(CLD-DKR-007-REF)로 옮겼다. 이 문서는 개념만 남겼다.
{% endhint %}

## 1. 목적

컨테이너 기반 서비스는 호스트 시스템 위에 이미지로 격리 환경을 만들어 필요한 개발 환경을 쉽게 구축하게 한다. 내가 만든 이미지를 다른 사람에게 공유할 수도 있다. 이 문서는 그 바탕이 되는 개념을 정리한다.

## 2. 구성 요소

### 2.1 가상 머신과 컨테이너 비교

| 번호 | 항목 | 가상 머신(VM) | 도커 컨테이너 |
|---|---|---|---|
| 1 | 구조 | 인프라 > 호스트 OS > 하이퍼바이저(예: Hyper-V) > VM1, VM2, VM3 > 각 VM의 앱 | 인프라 > 호스트 OS > 도커 엔진 > 앱(이미지) 여러 개 |
| 2 | 자원 | 자원을 VM별로 나눠 쓴다. VM을 삭제하지 않으면 점유한 자원을 호스트 OS나 다른 VM에 돌려줄 수 없다 | 이미지로 만든 프로세스가 호스트 자원을 공유한다 |
| 3 | 의존성 | VM은 인프라에 종속된다. 호스트 OS의 여유 자원이 중요하다 | 호스트 커널을 공유한다 |

### 2.2 도커 명령어 분류

| 번호 | 분류 | 명령 예 |
|---|---|---|
| 1 | system | `docker version`, `docker system info`, `docker system df`, `docker system prune`, `docker login`, `docker logout` |
| 2 | image | `docker images`, `docker image ls`, `docker image inspect`, `docker image prune`, `docker pull`, `docker push`, `docker image rm` |
| 3 | container | `docker container ps`, `docker container stats`, `docker container logs`, `docker container ls`, `docker container port` |
| 4 | network | `docker network ls`, `docker network create`, `docker network connect`, `docker network disconnect`, `docker network inspect`, `docker network rm` |
| 5 | volume | `docker volume ls`, `docker volume create`, `docker volume inspect` |

원본의 `docker system info`, `docker image ls` 계열 표기는 그대로 두었다. 옵션과 사용 예는 CLD-DKR-007-REF를 따른다.

### 2.3 컨테이너와 볼륨

| 번호 | 개념 | 설명 |
|---|---|---|
| 1 | 컨테이너 | 격리된 환경이다. 다른 컨테이너끼리 서로 영향을 줄 수 없다. 예: 컨테이너마다 다른 Python 버전을 쓸 수 있다 |
| 2 | 이미지 | 패키징된 내용이다. 컨테이너를 만들 때 이미지에서 복사해 온다 |
| 3 | 볼륨(Volume) | 컨테이너의 데이터를 관리하는 메커니즘이다. 파일과 디렉터리를 컨테이너 밖에 두거나, 컨테이너와 컨테이너, 컨테이너와 호스트 사이에서 공유할 때 쓴다 |

{% hint style="warning" %}
CAUTION: 볼륨 없이 컨테이너 안에 저장한 데이터는 컨테이너를 삭제할 때 함께 사라진다. 보존이 필요한 데이터는 볼륨에 둔다.
{% endhint %}

### 2.4 이미지 태그와 내려받기

| 번호 | 항목 | 설명 |
|---|---|---|
| 1 | 자동 내려받기 | 컨테이너를 실행할 때 이미지가 로컬에 없으면 Docker Hub에서 같은 이름의 이미지를 `pull`한다. 태그를 생략하면 `latest`를 받는다 |
| 2 | 태그 | 원하는 버전의 이미지를 구분해 설치·관리하려고 쓴다. 앱에 필요한 도구·IDE 버전을 태그로 골라 쓴다 |
| 3 | 공식 이미지 | Docker Hub 검색에서 공식(Official) 이미지만 걸러 볼 수 있다 |

### 2.5 컨테이너 수명 주기

| 번호 | 단계 | 명령 | 설명 |
|---|---|---|---|
| 1 | 생성 | `docker create` | 이미지로 컨테이너만 만든다. 실행하지 않는다 |
| 2 | 생성과 실행 | `docker run` | 컨테이너를 만들고 바로 실행한다 |
| 3 | 시작 | `docker start` | 중지된 컨테이너를 시작한다 |
| 4 | 종료 | `docker stop` | 실행 중인 컨테이너를 중지한다 |
| 5 | 삭제 | `docker rm` | 컨테이너를 삭제한다. 이미지는 삭제되지 않는다 |

컨테이너를 만든 뒤 중지하고 다시 시작해도 컨테이너 ID는 바뀌지 않는다.

{% hint style="info" %}
NOTE: 백그라운드 실행(`-d`)을 지정하지 않으면 컨테이너의 표준 입출력이 현재 터미널에 연결된다. 원본의 "해당 머신 안으로 들어가게 된다"는 표현은 `-it`로 셸을 지정했을 때의 동작이다.
{% endhint %}

### 2.6 도커 권한

도커 엔진을 설치하면 `docker` 그룹이 만들어진다. 일반 사용자는 기본적으로 `docker` 명령을 쓸 수 없다. 사용자를 `docker` 그룹에 추가하면 쓸 수 있다. 절차는 CLD-DKR-005-MP의 구역 B를 따른다.

### 2.7 DevOps 순환

원본 Dockerfile 페이지에 있던 DevOps 순환 설명이다.

| 번호 | 단계 | 내용 |
|---|---|---|
| 1 | 기획, 개발 | 요구사항을 정의하고 애플리케이션을 개발한다 |
| 2 | CI(빌드, 테스트), CD(배포) | 코드가 바뀌면 자동으로 빌드, 테스트, 배포 파이프라인을 실행한다 |
| 3 | 운영, 모니터링 | 배포한 서비스를 운영하고 성능과 장애를 감시한다 |
| 4 | 수정, 반복 | 피드백이나 버그를 수정하고 1단계로 돌아간다 |

## 3. 동작 원리

1. 사용자가 `docker run <이미지>`를 실행한다.
2. 도커 엔진이 로컬에서 이미지를 찾는다.
3. 이미지가 없으면 레지스트리(Docker Hub)에서 내려받는다.
4. 이미지로 컨테이너를 만들고 지정한 명령을 실행한다.
5. 컨테이너의 주 프로세스가 끝나면 컨테이너는 종료 상태가 된다. 삭제하기 전까지 `docker ps -a`에 남는다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| VM | Virtual Machine. 가상 머신 |
| 하이퍼바이저(Hypervisor) | 가상 머신을 만들고 실행하는 소프트웨어 |
| 볼륨(Volume) | 컨테이너 데이터를 컨테이너 밖에 보관하는 도커 저장 단위 |
| CI/CD | Continuous Integration / Continuous Delivery(또는 Deployment). 자동 통합·배포 |
| 태그(Tag) | 이미지 버전 이름 |

## 5. 참조

| 참조 문서 | 비고 |
|---|---|
| [도커 개요](docker.md) | CLD-DKR-001-DO |
| [도커 이미지 개념](docker_image.md) | CLD-DKR-003-DO |
| [도커 컨테이너](docker_container.md) | CLD-DKR-004-DO |
| [Docker 공식 사이트](https://www.docker.com/) | 외부 문서 |
| [Docker 공식 문서](https://docs.docker.com/) | 외부 문서 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 가상 머신과 컨테이너의 구조 차이를 그림이나 말로 설명해 본다.
- [ ] 볼륨이 필요한 상황을 내가 만들 서비스 하나로 예를 들어 본다.
- [ ] `docker create`와 `docker run`의 차이는 무엇이고, 각각 언제 쓰고 싶을까?
