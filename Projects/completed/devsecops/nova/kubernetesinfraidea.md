# 쿠버네티스 인프라 구상 (K8s)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-NOV-005-MP |
| 목적 | kind(Kubernetes in Docker)로 로컬 쿠버네티스 클러스터를 설치·생성·확인·삭제한다 |
| 적용 대상 | Docker가 설치된 Linux 호스트, Go 설치 환경(`go install` 사용 시), kind v0.26.0 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본 명령을 정리한 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [elkstack.md](elkstack.md) | PRJ-NOV-006-DO | ELK 스택 구축 구상 (ELK) |
| [task.md](task.md) | PRJ-NOV-004-REF | 환경 구축 작업 목록 (Task) |

## 2. 배경

kind는 각 노드를 도커 컨테이너로 실행하는 로컬 클러스터 도구다.

| 특징 | 내용 |
|---|---|
| 로컬 클러스터 구축 | 각 노드를 도커 컨테이너로 실행해 관리가 쉽다 |
| 테스트·개발 용이 | 자체 테스트용으로 설계됐으며 로컬 개발이나 CI 환경에서도 쓴다 |
| 멀티 노드 지원 | 단일 노드와 멀티 노드 클러스터를 모두 구성할 수 있다 |
| kubeadm 기반 | 노드 구성에 공식 도구 kubeadm을 써 실제 배포 환경과 비슷한 설정을 제공한다 |

## 3. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Docker | 최신 안정판 | kind의 노드 컨테이너 실행에 필요하다 |
| 2 | Go | `go install`을 쓸 때만 필요 | 원본의 설치 방법 |
| 3 | kind | v0.26.0 | |
| 4 | kubectl | 클러스터 버전과 호환되는 버전 | 클러스터 확인에 쓴다. 원본에 설치 안내 없음 |

## 4. 안전 사항

{% hint style="warning" %}
CAUTION: `kind delete cluster`는 클러스터와 그 안의 모든 리소스를 지운다. 보존할 데이터가 있으면 삭제 전에 꺼낸다.
{% endhint %}

## 5. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Docker가 실행 중이다 | `docker ps`가 오류 없이 목록을 출력한다 |
| 2 | Go의 bin 디렉터리가 `PATH`에 있다 | `go env GOPATH`의 `bin` 경로를 `PATH`에 포함한다. 미검증 |

## 6. 절차

### A. kind 설치

1. (6-A-01) Docker를 설치한다. 설치 방법은 원본에 없다. 운영체제의 공식 설치 안내를 따른다.
2. (6-A-02) kind를 설치한다: `go install sigs.k8s.io/kind@v0.26.0` → 결과: 오류 없이 끝난다.
3. (6-A-03) 설치를 확인한다: `kind version` → 결과: `v0.26.0`이 출력된다. 이 확인 명령은 원본에 없다. 미검증.

### B. 기본 클러스터 생성

1. (6-B-01) 클러스터를 만든다: `kind create cluster` → 결과: 단일 노드(control-plane) 클러스터가 만들어진다.

### C. 멀티 노드 클러스터 생성

1. (6-C-01) 설정 파일 `kind-config.yaml`을 만든다.

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
```

2. (6-C-02) 설정 파일로 클러스터를 만든다: `kind create cluster --config=kind-config.yaml` → 결과: 컨트롤 플레인 1개와 워커 1개로 이루어진 클러스터가 만들어진다.

{% hint style="info" %}
NOTE: B와 C는 같은 이름(`kind`)의 클러스터를 만든다. C를 수행하기 전에 B의 클러스터를 지우거나 `--name <이름>`을 지정한다.
{% endhint %}

### D. 클러스터 상태 확인

1. (6-D-01) 노드를 확인한다: `kubectl get nodes` → 결과: 노드가 `Ready` 상태로 표시된다.
2. (6-D-02) 모든 네임스페이스의 파드를 확인한다: `kubectl get pods -A` → 결과: 시스템 파드가 `Running` 상태로 표시된다.

## 7. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kubectl get nodes` | 설정한 노드 수만큼 표시된다 | 모든 노드가 `Ready` |
| 2 | `kubectl get pods -A` | 시스템 파드가 표시된다 | 모든 파드가 `Running` 또는 `Completed` |

## 8. 복구

1. (8-01) 클러스터를 삭제한다: `kind delete cluster` → 결과: 클러스터와 노드 컨테이너가 사라진다.

## 9. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. 원본의 소제목 목록(docker 설치, 클러스터 생성, kind 설치, 클러스터 확인, 클러스터 삭제)을 절차 구역으로 정리 |

## 작성자 메모

이 페이지의 제목은 "인프라 구상"이지만 원본은 kind 사용법 중심이다. 이 프로젝트에서 구상한 전체 클러스터 구조는 [ELK 스택 구축 구상](elkstack.md)에 있다.
