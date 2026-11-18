# 클러스터 생성 실습

> 상위: [15일차 · 쿠버네티스 입문](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-010-MP |
| 목적 | WSL에서 `kubectl`과 `kind`를 설치하고, kind로 클러스터를 만들어 노드가 Docker 컨테이너임을 확인한다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), systemd 사용, 14일차에 설치한 Docker Engine 29.x, cgroup v2, 여유 메모리 2GB 이상 |
| 소요 시간 | 약 35분(설치 15분, 생성과 확인 20분. 첫 생성은 노드 이미지 다운로드로 수 분 더 걸린다) |
| 확인 상태 | 미검증 (원본에 "클러스터가 실제로 뜨는 것은 확인하지 못했다. 교실 리허설에서 확인한다"라는 기록이 있으며, 이 문서는 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-N2-15-002-DO | 클러스터를 세운다 |
| [commands.md](commands.md) | LEC-N2-15-009-REF | 15일차 실습 명령어 |
| [14일차 · 도커 기초](../day-14/README.md) | | Docker Engine 설치 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04, systemd 사용 | `sudo` 권한 필요 |
| 2 | Docker Engine | 29.x | 14일차에 설치한 것 |
| 3 | `kubectl` | 현재 안정 버전(리허설: v1.37.1) | `dl.k8s.io`에서 받는다 |
| 4 | `kind` | v0.33.0(리허설) | 수업 전에 공식 문서에서 현재 안정 버전을 확인한다 |
| 5 | 인터넷 | 노드 이미지 다운로드 | 첫 생성에 수 분 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `cgroup2fs`가 아니면(`tmpfs`) 클러스터가 뜨지 않는다. 노드 이미지를 낮춰도 해결되지 않는다. 4절의 점검에서 `tmpfs`가 나오면 이 실습을 중단하고 2인 1조로 묶는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 5-A-02(inotify)를 하지 않으면 클러스터 생성 중 `too many open files`로 멈출 수 있다. 재부팅까지만 유효한 설정이다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `kind create cluster`가 수 분 걸려도 중간에 끊지 않는다. 노드 이미지를 받는 중이다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | cgroup v2이다 | `stat -fc %T /sys/fs/cgroup`이 `cgroup2fs`를 출력한다 |
| 2 | systemd가 PID 1이다 | `ps -p 1 -o comm=`이 `systemd`를 출력한다 |
| 3 | Docker가 동작한다 | `docker info --format '{{.ServerVersion}}'`이 `29.x`를 출력한다 |
| 4 | 메모리 여유가 있다 | `free -h`의 available이 2GB 이상이다 |
| 5 | 내 WSL 주소를 안다 | `ip route get 203.0.113.1 \| head -1`의 `src` 뒤 주소를 적는다 |

## 5. 절차

### A. 사전 설정과 설치

1. (5-A-01) `jq`를 설치한다: `sudo apt update && sudo apt install -y jq` → 결과: 오류 없이 끝난다.
2. (5-A-02) inotify 한도를 올린다: `sudo sysctl fs.inotify.max_user_watches=524288` 과 `sudo sysctl fs.inotify.max_user_instances=512` → 결과: 두 값이 설정된 줄이 출력된다.
3. (5-A-03) `kubectl`을 받는다: `curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"` → 결과: 현재 폴더에 `kubectl` 파일이 생긴다.
4. (5-A-04) 설치한다: `sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl`
5. (5-A-05) 버전을 확인한다: `kubectl version --client` → 결과: Client Version이 출력된다.
6. (5-A-06) `kind`를 받는다: `curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64` → 결과: 현재 폴더에 `kind` 파일이 생긴다.
7. (5-A-07) 실행 권한을 주고 옮긴다: `chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind`
8. (5-A-08) 버전을 확인한다: `kind --version` → 결과: `kind version 0.33.0`이 출력된다.

{% hint style="info" %}
NOTE: 5-A-06의 `v0.33.0`은 버전 번호이므로 수업 전에 kind 공식 문서의 Quick Start에서 현재 안정 버전으로 맞춘다. 원본에는 GitHub API로 최신 태그를 조회하는 `curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r .tag_name`도 있다.
{% endhint %}

### B. 클러스터 생성

1. (5-B-01) 클러스터를 만든다: `kind create cluster --name student` → 결과: `Starting control-plane`, `Installing CNI`, `Installing StorageClass`에 ✓가 붙고 `Set kubectl context to "kind-student"`가 출력된다.
2. (5-B-02) 노드를 확인한다: `kubectl get nodes` → 결과: `student-control-plane`의 STATUS가 `Ready`이다.
3. (5-B-03) 현재 context를 확인한다: `kubectl config current-context` → 결과: `kind-student`.
4. (5-B-04) 쿠버네티스 자신의 부품을 확인한다: `kubectl get pods -A` → 결과: `kube-system`에 `coredns`, `etcd`, `kube-apiserver` 등이 보인다.

### C. 노드가 컨테이너임을 확인

1. (5-C-01) Docker 컨테이너를 본다: `docker ps` → 결과: `kindest/node` 이미지의 컨테이너 `student-control-plane`이 보인다.

### D. 일회용 감각 (시간이 있을 때)

1. (5-D-01) 클러스터 목록을 본다: `kind get clusters` → 결과: `student`가 보인다.

{% hint style="danger" %}
WARNING: 5-D-02는 클러스터 안의 모든 것을 지운다. 이 실습이 끝난 뒤에도 16일차까지 클러스터를 남겨야 하면 실행하지 않는다.
{% endhint %}

2. (5-D-02) 클러스터를 지운다: `kind delete cluster --name student` → 결과: `Deleted clusters: ["student"]`가 출력된다.
3. (5-D-03) 목록을 확인한다: `kind get clusters` → 결과: 출력이 비어 있다.
4. (5-D-04) 다시 만든다: `kind create cluster --name student` → 결과: 첫 생성보다 빠르게 끝난다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kubectl get nodes` | 노드 1개 | STATUS가 `Ready` |
| 2 | `kubectl config current-context` | `kind-student` | 문자열 일치 |
| 3 | `docker ps` | 노드 컨테이너 | `student-control-plane`이 목록에 있다 |
| 4 | `kubectl get pods -A` | `kube-system` Pod 목록 | 모든 Pod가 `Running` 또는 `Completed`이다 |

{% hint style="warning" %}
CAUTION: 증상별 조치는 다음과 같다. `Starting control-plane ✗`이면 `stat -fc %T /sys/fs/cgroup`을 확인하고 cgroup v2가 아니면 중단한다. `too many open files`이면 5-A-02를 하고 다시 만든다. 노드는 `Ready`인데 통신이 안 되면 VPN과 172.17 대역이 충돌한 것이므로 VPN을 끄거나 `/etc/docker/daemon.json`의 `default-address-pools`로 대역을 옮긴다.
{% endhint %}

## 7. 복구

1. (7-01) 클러스터를 지운다: `kind delete cluster --name student` → 결과: `kind get clusters`가 비어 있다.
2. (7-02) `kubectl`, `kind`를 지우려면: `sudo rm /usr/local/bin/kubectl /usr/local/bin/kind`
3. (7-03) inotify 설정은 재부팅하면 원래 값으로 돌아간다.

{% hint style="info" %}
NOTE: 클러스터는 16일차에도 쓰므로 수업이 끝나도 지우지 않고 남겨 둔다(`kubectl get nodes`로 확인만 한다).
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-2.md`와 `commands.md`의 STEP 0, STEP 2 실습을 분리해 AMM 형식으로 재작성 |
