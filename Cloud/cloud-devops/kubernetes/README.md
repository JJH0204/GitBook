---
description: 쿠버네티스 클러스터 구축·설치 문서 그룹 (Windows Kind 설치, 클러스터 구축 하위 그룹)
---

# 쿠버네티스 (Kubernetes)

쿠버네티스 설치와 구축 문서를 모은 그룹이다. 문서 번호(Task ID)는 `CLD-K8S-<번호>-<유형>` 형식이다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| CLD-K8S-001-MP | 절차 | [Windows 환경 Kind 쿠버네티스 설치](kubernetes_in_windows.md) | Windows에서 Docker Desktop과 Kind로 3노드 클러스터를 만든다 |
| - | - | [쿠버네티스 클러스터 구축](kubernetes/README.md) | EKS, 노드 설치, 대시보드, 이론 문서를 모은 하위 그룹 |

## 읽는 순서

1. [도커 핵심 이론](../docker/dockertheory.md)에서 컨테이너 개념을 확인한다.
2. CLD-K8S-001-MP로 로컬 클러스터를 만든다.
3. [쿠버네티스 클러스터 구축](kubernetes/README.md)의 문서를 순서대로 따른다.
