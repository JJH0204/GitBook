---
description: 도커 개념, 설치, 명령어, Dockerfile, Docker Hub, 배포 실습 문서 모음
---

# 도커 (Docker)

도커(Docker)의 개념, 설치, 명령어, 이미지 빌드, Docker Hub 공유, 실습 절차를 정리한다. 문서 번호(Task ID)는 `CLD-DKR-<번호>-<유형>` 형식이다. 유형은 DO(개념), MP(절차), REF(표)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| CLD-DKR-001-DO | 개념 | [도커 개요 (Docker)](docker.md) | 도커가 무엇이고 왜 쓰는지 이해한다 |
| CLD-DKR-002-DO | 개념 | [도커 핵심 이론 (Docker)](dockertheory.md) | 가상 머신과 컨테이너의 차이, 명령어 분류, 볼륨을 이해한다 |
| CLD-DKR-003-DO | 개념 | [도커 이미지 개념 (Docker Image)](docker_image.md) | 이미지와 태그를 이해한다 |
| CLD-DKR-004-DO | 개념 | [도커 컨테이너 (Docker Container)](docker_container.md) | 컨테이너의 정의와 격리 방식을 이해한다 |
| CLD-DKR-005-MP | 절차 | [Ubuntu 환경 도커 설치](docker_install.md) | Ubuntu 22.04에 도커 엔진을 설치한다 |
| CLD-DKR-006-MP | 절차 | [RHEL 계열 도커 설치](docker-install-rhel.md) | RHEL 계열에 도커 엔진을 설치한다 |
| CLD-DKR-007-REF | 표 | [도커 필수 명령어 (Docker Command)](docker_commend.md) | 자주 쓰는 도커 명령과 옵션을 찾는다 |
| CLD-DKR-008-MP | 절차 | [도커 컨테이너 실행과 관리](docker-container-run.md) | 컨테이너를 실행, 중지, 삭제한다 |
| CLD-DKR-009-MP | 절차 | [도커 이미지 빌드 (Docker Build)](docker_build.md) | Dockerfile로 이미지를 빌드한다 |
| CLD-DKR-010-REF | 표 | [Dockerfile 작성법 및 실습](dockerfile.md) | Dockerfile 지시어를 찾는다 |
| CLD-DKR-011-MP | 절차 | [Dockerfile 실습: Nginx 웹 페이지 이미지](dockerfile-practice-nginx.md) | Nginx 이미지를 두 버전으로 빌드한다 |
| CLD-DKR-012-MP | 절차 | [Dockerfile 실습: Ubuntu Apache 이미지](dockerfile-practice-apache.md) | Ubuntu 기반 Apache 이미지를 빌드한다 |
| CLD-DKR-013-MP | 절차 | [Dockerfile 실습: Fedora Nginx 이미지](dockerfile-practice-fedora.md) | Fedora 기반 Nginx 이미지를 빌드한다 |
| CLD-DKR-014-REF | 표 | [Dockerfile 이미지 쿠버네티스 배포 명령](dockerfile-k8s-deploy.md) | 빌드한 이미지를 배포하는 `kubectl` 명령을 찾는다 |
| CLD-DKR-015-MP | 절차 | [도커 허브 활용 가이드 (Docker Hub)](docker_hub.md) | 이미지를 Docker Hub에 올리고 내려받는다 |
| CLD-DKR-016-MP | 절차 | [도커 컨테이너 이미지화와 Compose 공유](docker-hub-compose-share.md) | 여러 컨테이너를 이미지로 저장해 Compose로 공유한다 |
| CLD-DKR-017-MP | 절차 | [도커 허브 이미지 공유 실습](docker-hub-image-share.md) | WordPress 컨테이너를 이미지로 저장해 공유한다 |
| CLD-DKR-018-MP | 절차 | [Ubuntu 워드프레스 도커 배포](ubuntu-wordpress-docker.md) | 단일 Ubuntu 컨테이너에 WordPress와 MariaDB를 구성한다 |
| CLD-DKR-019-DO | 개념 | [[생성형 AI] 도커 네트워크 — 브리지와 포트 게시](docker-network.md) | 컨테이너 통신과 포트 게시를 이해한다 |
| CLD-DKR-020-DO | 개념 | [[생성형 AI] 도커 볼륨과 데이터 보존](docker-volume.md) | 볼륨, 바인드 마운트, 백업을 이해한다 |
| CLD-DKR-021-REF | 표 | [[생성형 AI] Docker Compose 파일 작성법](docker-compose-file.md) | Compose 키와 명령을 찾는다 |
| CLD-DKR-022-INS | 점검 | [[생성형 AI] Dockerfile·이미지 보안 점검표](docker-security-checklist.md) | 이미지와 실행 옵션을 점검한다 |
| CLD-DKR-023-TS | 문제 해결 | [[생성형 AI] 컨테이너 장애 진단](docker-troubleshooting.md) | 시작 실패·접속 불가 원인을 좁힌다 |
| CLD-DKR-024-DO | 개념 | [[생성형 AI] 멀티 스테이지 빌드와 이미지 경량화](docker-multistage-build.md) | 빌드 단계를 나눠 이미지를 작게 만든다 |
| CLD-DKR-025-REF | 표 | [[생성형 AI] 컨테이너 로그와 리소스 제한](docker-logs-resources.md) | 로그 조회·보관과 CPU·메모리 제한 옵션을 찾는다 |

하위 실습: [도커 실습 (Docker Practice)](docker-1/README.md)

## 읽는 순서

1. CLD-DKR-001-DO ~ 004-DO로 개념을 익힌다.
2. 운영체제에 맞는 설치 문서(005-MP 또는 006-MP)를 수행한다.
3. 008-MP로 컨테이너를 실행하고, 007-REF로 명령을 찾는다.
4. 009-MP, 010-REF, 011-MP ~ 013-MP로 이미지를 빌드한다.
5. 015-MP ~ 017-MP로 이미지를 공유하고, 018-MP로 서비스를 배포한다.
