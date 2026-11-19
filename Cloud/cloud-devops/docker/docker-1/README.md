---
description: Docker Compose로 워드프레스와 MariaDB를 실행하고 이미지를 Docker Hub에 올리는 실습
---

# [생성형 AI] 도커 실습 (Docker Practice)

## 작업 식별

| 항목 | 내용 |
|---|---|
| 유형 | 그룹 README (허브) |
| 작성 | 생성형 AI 초안 (사람 검토 전) |
| 확인 상태 | 미검증 (하위 문서 제목과 용도만 정리했으며 실행하지 않았다) |

Docker Compose 실습 문서를 모은 그룹이다. 문서 번호(Task ID)는 `CLD-DK1-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| CLD-DK1-001-MP | 절차 | [Docker Compose 워드프레스 실습](dockerpractice.md) | Compose로 워드프레스와 MariaDB를 실행하고 이미지를 Docker Hub에 올린다 |

## 읽는 순서

1. [Ubuntu 환경 도커 설치](../docker_install.md)로 도커를 설치한다.
2. [도커 허브 이미지 공유 실습](../docker-hub-image-share.md)으로 `docker login`과 이미지 업로드 흐름을 본다.
3. CLD-DK1-001-MP를 수행한다.

## 이 영역이 다루는 것

Docker Compose로 여러 컨테이너(워드프레스, MariaDB)를 한 번에 실행하고, 만든 이미지를 Docker Hub에 올리는 실습을 모은 그룹이다. 도커 설치와 기본 명령을 익힌 입문자가 대상이다.

## 핵심 용어

- Docker Compose: 여러 컨테이너를 YAML 파일 하나로 정의하고 실행하는 도구
- 이미지와 컨테이너: 실행 파일 묶음(이미지)과 그 실행 인스턴스(컨테이너)
- Docker Hub: 이미지를 공유하는 레지스트리

## 선수 지식

- 도커 설치와 `docker run` 기본 사용
- YAML 문법의 기초
