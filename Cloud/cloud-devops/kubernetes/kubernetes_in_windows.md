# Windows 환경 Kind 쿠버네티스 설치

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8S-001-MP |
| 목적 | Windows에서 Docker Desktop과 Kind(Kubernetes in Docker)로 Control Plane 1개, Worker Node 2개의 로컬 쿠버네티스 클러스터를 만들고 테스트 파드를 배포한다 |
| 적용 대상 | Windows 10/11 64비트, 가상화 활성화(BIOS), WSL2 기반 Docker Desktop, PowerShell. 설치 단계(5-A)는 관리자 권한이 필요하다 |
| 소요 시간 | 약 30분 (이미지 내려받기 시간 제외) |
| 확인 상태 | 미검증 (원본 페이지의 명령 블록이 비어 있어 명령은 Kind와 kubectl의 통상 사용법으로 보충했다. 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서의 노드 수와 노드 이미지 버전(`kindest/node:v1.27.4`)은 원본 출력 예시를 따른다. 실제 버전은 설치한 Kind 버전에 따라 다르다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [kubernetes/README.md](kubernetes/README.md) | - | 쿠버네티스 클러스터 구축 |
| [kubernetes-on-dockerimage.md](kubernetes/kubernetes-on-dockerimage.md) | - | Kind 클러스터 도커 이미지 배포 |
| [kubernetestheory.md](kubernetes/kubernetestheory.md) | - | 쿠버네티스 핵심 이론 |

외부 참조:

* Docker Desktop 다운로드: https://www.docker.com/products/docker-desktop/
* Kind 공식 문서: https://kind.sigs.k8s.io/

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Windows PC | Windows 10/11 64비트, RAM 8 GB 이상 권장, BIOS 가상화 켜짐 | 노드 3개를 컨테이너로 띄운다 |
| 2 | WSL2 | 설치됨 | Docker Desktop의 WSL2 백엔드에 필요 |
| 3 | Docker Desktop | 최신 안정 버전 | 5-A에서 설치 |
| 4 | Kind | 최신 안정 버전 | 5-B에서 설치 |
| 5 | kubectl | 클러스터 버전과 마이너 버전 1 이내 | Docker Desktop이 함께 설치할 수 있다 |
| 6 | PowerShell | 5.1 이상 | 이 문서의 모든 명령은 PowerShell에서 실행한다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: Docker Desktop을 설치하면 WSL2 또는 Hyper-V 기능이 켜지고 재부팅이 필요할 수 있다. 저장하지 않은 작업을 먼저 저장한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: Docker Desktop 자체의 Kubernetes 기능(설정 > Kubernetes)과 Kind는 서로 다른 클러스터를 만든다. 원본 페이지는 Docker Desktop의 Kubernetes 옵션을 켜지 않는 것을 전제로 한다. 두 클러스터를 함께 쓰면 `kubectl` 컨텍스트가 섞일 수 있으므로 5-E-01에서 컨텍스트를 확인한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 가상화가 켜져 있다 | 작업 관리자 > 성능 > CPU에서 `가상화`가 `사용`이다 |
| 2 | WSL2가 설치돼 있다 | `wsl --status`가 기본 버전 2를 출력한다 |
| 3 | PowerShell을 관리자 권한으로 연다 | 창 제목에 `관리자`가 표시된다 |
| 4 | 디스크 여유 공간이 20 GB 이상이다 | 탐색기에서 `C:` 드라이브의 여유 공간을 본다 |

## 5. 절차

### A. Docker Desktop 설치

1. (5-A-01) Docker Desktop 설치 파일을 내려받아 실행한다. 설치 옵션에서 `Use WSL 2 instead of Hyper-V`를 선택한다. → 결과: 설치가 끝나고 재부팅 안내가 나타난다.
2. (5-A-02) 필요하면 PC를 재부팅한다. → 결과: 재부팅 뒤 Docker Desktop이 시작된다.
3. (5-A-03) Docker Desktop의 상태 표시가 `Engine running`(초록색)이 될 때까지 기다린다. → 결과: 상태가 초록색이다.
4. (5-A-04) PowerShell에서 도커를 확인한다: `docker version` → 결과: Client와 Server 정보가 모두 출력된다.

### B. Kind 설치

1. (5-B-01) PowerShell에서 Kind를 설치한다: `winget install Kubernetes.kind` → 결과: 설치가 완료된다.
2. (5-B-02) kubectl이 없으면 설치한다: `winget install Kubernetes.kubectl` → 결과: 설치가 완료된다.
3. (5-B-03) 새 PowerShell 창을 연다. → 결과: PATH 변경이 적용된다.
4. (5-B-04) Kind 설치를 확인한다: `kind version` → 결과: `kind v0.x.x` 형식의 버전이 출력된다.
5. (5-B-05) kubectl 설치를 확인한다: `kubectl version --client` → 결과: Client Version이 출력된다.

### C. 클러스터 설정 파일 작성

Control Plane(과거 용어 Master Node) 1개와 Worker Node 2개를 정의하는 YAML 파일을 만든다.

1. (5-C-01) 작업 폴더에 `cluster-config.yaml` 파일을 만들고 아래 내용을 저장한다. → 결과: 파일이 저장된다.

{% code title="cluster-config.yaml" %}
```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```
{% endcode %}

### D. 클러스터 생성

1. (5-D-01) 설정 파일로 클러스터를 만든다: `kind create cluster --config cluster-config.yaml` → 결과: 노드 이미지를 내려받은 뒤 `Set kubectl context to "kind-kind"`가 출력된다.
2. (5-D-02) 도커 컨테이너로 노드를 확인한다: `docker ps` → 결과: 컨테이너 3개가 `Up` 상태로 보인다.

```
CONTAINER ID   IMAGE                  COMMAND                  STATUS       NAMES
abc123         kindest/node:v1.27.4   "/usr/local/bin/entr…"   Up 2 minutes kind-worker
def456         kindest/node:v1.27.4   "/usr/local/bin/entr…"   Up 2 minutes kind-worker2
ghi789         kindest/node:v1.27.4   "/usr/local/bin/entr…"   Up 2 minutes kind-control-plane
```

`kind-worker`와 `kind-worker2`는 Worker Node이고, `kind-control-plane`은 Control Plane이다.

### E. 클러스터 상태 확인

1. (5-E-01) 현재 컨텍스트를 확인한다: `kubectl config current-context` → 결과: `kind-kind`가 출력된다. 다른 값이면 `kubectl config use-context kind-kind`를 실행한다.
2. (5-E-02) 노드 상태를 확인한다: `kubectl get nodes` → 결과: 노드 3개가 모두 `Ready`다. Worker Node의 ROLES는 `<none>`으로 표시된다.

```
NAME                 STATUS   ROLES           AGE   VERSION
kind-control-plane   Ready    control-plane   1m    v1.27.4
kind-worker          Ready    <none>          1m    v1.27.4
kind-worker2         Ready    <none>          1m    v1.27.4
```

### F. Worker Node 테스트

파드(Pod)가 Worker Node에서 실행되는지 확인한다. Control Plane에는 기본 taint가 있어 일반 파드가 배치되지 않는다.

1. (5-F-01) nginx Deployment를 만든다: `kubectl create deployment nginx --image=nginx` → 결과: `deployment.apps/nginx created`가 출력된다.
2. (5-F-02) 파드 배치 노드를 확인한다: `kubectl get pods -o wide` → 결과: `STATUS`가 `Running`이고 `NODE` 열이 `kind-worker` 또는 `kind-worker2`다. 이미지를 내려받는 동안 `ContainerCreating`이 먼저 보일 수 있다.

```
NAME                 READY   STATUS    NODE           ...
nginx-xxxxxxx-yyyy   1/1     Running   kind-worker    ...
```

### G. 추가 구성 (선택)

원본 페이지는 아래 두 항목을 목록으로만 적었다. 구체 명령은 원본에 없었다.

* Ingress Controller: 로컬 환경에서 외부 요청을 클러스터로 라우팅하는 Ingress를 설치한다. Kind에서는 5-C-01의 설정 파일에 `extraPortMappings`와 노드 라벨(`ingress-ready=true`) 설정이 필요하다. 절차는 Kind 공식 문서의 Ingress 항목을 따른다.
* 스토리지 추가: Persistent Volume과 Persistent Volume Claim을 설정해 데이터 영속성을 확보한다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kind get clusters` | 클러스터 이름이 출력된다 | `kind`가 목록에 있다 |
| 2 | `kubectl get nodes` | 노드 3개가 보인다 | 모두 `Ready` |
| 3 | `kubectl get pods -o wide` | nginx 파드가 Worker Node에서 실행된다 | `Running`, NODE가 `kind-worker*` |

## 7. 복구

{% hint style="danger" %}
WARNING: `kind delete cluster`는 클러스터와 그 안에 만든 모든 리소스(Deployment, 파드, 저장 데이터)를 삭제한다. 되돌릴 수 없다. 남길 매니페스트는 먼저 파일로 저장한다.
{% endhint %}

1. (7-01) 테스트 Deployment만 삭제한다: `kubectl delete deployment nginx` → 결과: `deployment.apps "nginx" deleted`가 출력된다.
2. (7-02) 클러스터를 삭제한다: `kind delete cluster` → 결과: `Deleted clusters: ["kind"]`가 출력된다. 이름을 지정해 만들었다면 `--name <클러스터 이름>`을 붙인다.
3. (7-03) 삭제를 확인한다: `docker ps` → 결과: `kind-*` 컨테이너가 없다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. 비어 있던 명령 블록(Kind 설치, 설정 파일, 생성, 확인, 배포, 삭제)을 통상 명령으로 보충했고, 복구 절차와 기능 확인 표를 추가했다 |
