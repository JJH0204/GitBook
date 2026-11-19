# 쿠버네티스 클러스터 구축

쿠버네티스 클러스터의 개념, 노드 설치, 대시보드, 이미지 배포, AWS EKS 구축 문서를 모은 그룹이다. 문서 번호(Task ID)는 `CLD-K8T-<번호>-<유형>` 형식이다. 유형은 DO(개념), MP(절차)다.

## 문서 목록

| Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|
| CLD-K8T-001-DO | 개념 | [쿠버네티스 핵심 이론 (Kubernetes)](kubernetestheory.md) | 클러스터 구성 요소와 동작 원리를 이해한다 |
| CLD-K8T-002-MP | 절차 | [쿠버네티스 노드 설치 및 설정](kube_setup.md) | Ubuntu 서버 3대에 kubeadm으로 클러스터를 만든다 |
| CLD-K8T-003-MP | 절차 | [쿠버네티스 대시보드 배포](kube_webdashboard.md) | 웹 대시보드를 배포하고 토큰으로 접속한다 |
| CLD-K8T-004-MP | 절차 | [Kind 클러스터 도커 이미지 배포](kubernetes-on-dockerimage.md) | Kind 노드에 이미지를 로드해 배포한다 |
| CLD-K8T-005-MP | 절차 | [AWS EKS 구축 및 운영](eks.md) | `eksctl`로 EKS 클러스터를 만들고 정리한다 |
| CLD-K8T-006-DO | 개념 | [보안 중심 SDLC와 SAST/DAST](devsecops-sdlc.md) | 단계별 보안 활동과 정적·동적 분석을 이해한다 |
| CLD-K8T-007-REF | 표 | [[생성형 AI] kubectl 명령 정리](kubectl-reference.md) | 자주 쓰는 `kubectl` 명령을 찾는다 |
| CLD-K8T-008-REF | 표 | [[생성형 AI] 쿠버네티스 매니페스트 기본 — 파드·디플로이먼트·서비스](manifest-basics.md) | YAML 필드와 예를 찾는다 |
| CLD-K8T-009-DO | 개념 | [[생성형 AI] 컨피그맵과 시크릿](configmap-secret.md) | 설정과 비밀값 전달 방식을 이해한다 |
| CLD-K8T-010-TS | 문제 해결 | [[생성형 AI] 파드 장애 진단](pod-troubleshooting.md) | 파드 상태별 원인을 좁힌다 |

## 읽는 순서

1. CLD-K8T-001-DO로 구성 요소를 이해한다.
2. 로컬 연습은 [Windows 환경 Kind 쿠버네티스 설치](../kubernetes_in_windows.md)(CLD-K8S-001-MP) 후 CLD-K8T-004-MP를 따른다.
3. 서버 클러스터는 CLD-K8T-002-MP 후 CLD-K8T-003-MP를 따른다.
4. 클라우드 클러스터는 CLD-K8T-005-MP를 따른다. 과금에 주의한다.
