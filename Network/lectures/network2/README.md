# 네트워크 2 — 2단계 · 서버 구축 및 활용

> 상위: [강의 (Lectures)](../README.md) · 이전 단계: [네트워크 1](../network1/README.md)

패킷트레이서와 리눅스를 활용한 네트워크 기초이론과 실습 과정이다. 도구는 리눅스(우분투), Docker, 클라우드이고 9~16일차를 다룬다. 9일차부터 AI 도구를 활용한다.

## 문서 목록과 읽는 순서

일차 순서대로 읽는다. 각 일차 README에 그날의 문서 목록과 Task ID가 있다.

| 순서 | 문서 | 주제 | 핵심 내용 |
|---|---|---|---|
| 1 | [9일차 · 리눅스 설명](day-09/README.md) | 리눅스 설명 | 리눅스 설치, VM, SSH 서버 직접 구축, 접속 |
| 2 | [10일차 · 서버 기초](day-10/README.md) | 서버 기초 | (오전) 리눅스 기본 명령어, AI 활용(9일차 이월) (오후) 서버 개념, TCP/UDP와 포트, NAT/DNS/DHCP |
| 3 | [11일차 · 서버 보안](day-11/README.md) | 서버 보안 | (앞) 무선랜, PT 공유기(10일차 이월) ACL, 방화벽, AI 활용 |
| 4 | [12일차 · 리눅스 서버 구축](day-12/README.md) | 리눅스 서버 구축 | 여섯 단계로 SSH, FTP, NFS, DNS, Mail, Proxy 서버 구축, AI 활용 |
| 5 | [13일차 · Git 과 GitHub](day-13/README.md) | Git과 GitHub | 버전 관리, SSH 키 인증, 서버에 `git clone` 배포, AI 활용 |
| 6 | [14일차 · 도커 기초](day-14/README.md) | 도커 기초 | 왜 컨테이너인가, 포트, ufw 우회, 볼륨, Dockerfile, Compose, AI 활용 |
| 7 | [15일차 · 쿠버네티스 입문](day-15/README.md) | 쿠버네티스 입문 | 왜 K8S인가, kind 클러스터, Pod/Deployment/Service, 선언형, 자가 치유, AI 활용 |
| 8 | [16일차 · 쿠버네티스로 배포하고 공개하기](day-16/README.md) | 쿠버네티스로 배포하기 | 내 이미지 올리기, ConfigMap/Secret, NodePort/Ingress, 롤링 업데이트, 16일 되짚기 |

## 선행 과정

[네트워크 1](../network1/README.md)의 1~8일차를 마친 뒤 시작한다. 8일차까지는 패킷트레이서 안의 서버를 체크박스로 켰다. 9일차부터는 그 서버를 리눅스로 직접 만든다.
