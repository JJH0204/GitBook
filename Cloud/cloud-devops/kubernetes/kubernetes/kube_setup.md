# 쿠버네티스 노드 설치 및 설정

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | CLD-K8T-002-MP |
| 목적 | Ubuntu 서버 3대(컨트롤 플레인 1, 워커 2)에 containerd, kubeadm, kubelet, kubectl을 설치하고 Calico 네트워크로 멀티 노드 클러스터를 구성한다 |
| 적용 대상 | Ubuntu 24.04 서버 3대(원본 기준), 쿠버네티스 v1.31 패키지 저장소, 각 노드 `sudo` 권한 |
| 소요 시간 | 약 60분 (패키지·이미지 내려받기 시간 제외) |
| 확인 상태 | 미검증 (원본의 영상 튜토리얼 명령을 정리한 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 원본은 패키지 저장소 키를 `v1.30` 주소에서, 저장소 줄은 `v1.31` 주소에서 받도록 적어 서로 달랐다. 이 문서는 `v1.31`로 통일했다. 설치할 버전을 바꾸려면 두 곳을 같은 버전으로 바꾼다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [kubernetestheory.md](kubernetestheory.md) | CLD-K8T-001-DO | 쿠버네티스 핵심 이론 (Kubernetes) |
| [kube_webdashboard.md](kube_webdashboard.md) | CLD-K8T-003-MP | 쿠버네티스 대시보드 배포 |
| [kubernetes_in_windows.md](../kubernetes_in_windows.md) | CLD-K8S-001-MP | Windows 환경 Kind 쿠버네티스 설치 |

외부 참조:

* kubeadm 설치 공식 문서: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
* Calico 공식 문서: https://docs.tigera.io/calico/latest/getting-started/kubernetes/self-managed-onprem/onpremises

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | 컨트롤 플레인 노드 | Ubuntu 24.04, 2 vCPU 이상, RAM 2 GB 이상 | 호스트명 `k8s-control-node` |
| 2 | 워커 노드 2대 | Ubuntu 24.04, RAM 2 GB 이상 | 호스트명 `k8s-worker01-node`, `k8s-worker02-node` |
| 3 | 노드 간 네트워크 | 서로 통신 가능한 사설 IP | 원본은 NAT와 Host-Only 어댑터를 함께 썼다 |
| 4 | 인터넷 연결 | 패키지·매니페스트 내려받기 | 저장소 `pkgs.k8s.io`, `download.docker.com`, `raw.githubusercontent.com` |
| 5 | 컨테이너 런타임 | containerd.io | 5-C에서 설치 |
| 6 | CNI 플러그인 | Calico v3.28.2 | 5-I에서 설치 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `kubeadm init`이 출력하는 `kubeadm join` 명령에는 토큰과 인증서 해시가 들어 있다. 이 값으로 누구나 클러스터에 노드를 추가할 수 있다. 문서, 채팅, 저장소에 붙여 넣지 않는다. 토큰 기본 유효 시간은 24시간이다.
{% endhint %}

{% hint style="danger" %}
WARNING: `/etc/kubernetes/admin.conf`와 `$HOME/.kube/config`는 클러스터 관리자 자격 증명이다. 외부에 공유하지 않는다. 파일 권한은 소유자만 읽도록 유지한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 5-B-04는 `/etc/fstab`에서 swap 줄을 주석 처리한다. 재부팅 뒤에도 swap이 꺼진 상태가 유지된다. swap을 다시 쓰려면 7절의 복구를 따른다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 원본처럼 노드 IP가 `192.168.x.x` 사설 대역이면 Calico 매니페스트의 기본 파드 대역(`192.168.0.0/16`)과 겹칠 수 있다. 겹치면 파드 통신이 실패할 수 있다. 대응 방법은 구역 G의 NOTE에 적었다. 이 충돌 여부는 확인 필요다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 노드 3대의 IP를 정한다 | 각 노드에서 `ip -br addr`로 IP를 확인한다 |
| 2 | 노드 간 통신이 된다 | 한 노드에서 다른 노드로 `ping -c 3 <노드 IP 주소>`가 성공한다 |
| 3 | 노드 3대의 `product_uuid`가 서로 다르다 | `sudo cat /sys/class/dmi/id/product_uuid`가 노드마다 다르다 |
| 4 | 컨트롤 플레인의 6443 포트가 막히지 않았다 | 방화벽에서 노드 간 TCP 6443을 허용한다 |

## 5. 절차

구역 A~F는 모든 노드에서, G는 컨트롤 플레인 노드에서, H는 워커 노드에서, I~K는 컨트롤 플레인 노드에서 수행한다. 구역 이름 앞에 대상 노드를 적었다.

### A. [전체 노드] 호스트명 설정과 hosts 파일 갱신

1. (5-A-01) 컨트롤 플레인 노드에서 호스트명을 설정한다: `sudo hostnamectl set-hostname "k8s-control-node"` → 결과: 오류 없이 끝난다.
2. (5-A-02) 워커 노드 1에서 호스트명을 설정한다: `sudo hostnamectl set-hostname "k8s-worker01-node"`
3. (5-A-03) 워커 노드 2에서 호스트명을 설정한다: `sudo hostnamectl set-hostname "k8s-worker02-node"`
4. (5-A-04) 각 노드의 `/etc/hosts`에 세 노드의 IP와 호스트명을 추가한다. → 결과: 노드에서 호스트명으로 다른 노드에 `ping`이 된다.

```
<컨트롤 플레인 IP 주소>  k8s-control-node
<워커 1 IP 주소>        k8s-worker01-node
<워커 2 IP 주소>        k8s-worker02-node
```

### B. [전체 노드] swap 해제와 커널 설정

{% hint style="info" %}
NOTE: 원본은 "클러스터가 잘 동작하지 않으면 selinux와 firewalld를 끈다"고 적었다. SELinux와 firewalld는 RHEL 계열의 기본 구성이다. Ubuntu에는 기본으로 설치돼 있지 않아 5-B-01은 RHEL 계열 노드에서만 해당한다. 보안 설정을 낮추는 작업이므로 문제 해결 목적일 때만 수행한다.
{% endhint %}

1. (5-B-01) (RHEL 계열만, 선택) firewalld를 중지하고 SELinux를 permissive로 바꾼다. → 결과: `getenforce`가 `Permissive`다.

```bash
sudo systemctl stop firewalld
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
```

2. (5-B-02) swap을 끈다: `sudo swapoff -a` → 결과: `free -h`의 Swap 행이 0이다.
3. (5-B-03) 커널 모듈 `overlay`와 `br_netfilter`를 불러온다: `sudo modprobe overlay && sudo modprobe br_netfilter` → 결과: 오류 없이 끝난다.
4. (5-B-04) 재부팅 뒤에도 swap이 꺼지도록 `/etc/fstab`의 swap 줄을 주석 처리한다: `sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab` → 결과: `grep swap /etc/fstab`의 줄이 `#`로 시작한다.
5. (5-B-05) 부팅 때 모듈이 로드되도록 파일을 만든다. → 결과: 파일이 생성된다.

```bash
sudo tee /etc/modules-load.d/k8s.conf << EOF
overlay
br_netfilter
EOF
```

6. (5-B-06) 커널 네트워크 매개변수 파일을 만든다. → 결과: 파일이 생성된다.

```bash
sudo tee /etc/sysctl.d/kubernetes.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
```

7. (5-B-07) 설정을 적용한다: `sudo sysctl --system` → 결과: 출력에 `net.ipv4.ip_forward = 1`이 보인다.

### C. [전체 노드] containerd 설치

{% hint style="info" %}
NOTE: 쿠버네티스 1.24부터 Docker Engine을 런타임으로 직접 지원하지 않는다(dockershim 제거). 이 문서는 containerd를 런타임으로 쓴다. 패키지는 도커 저장소의 `containerd.io`를 쓴다.
{% endhint %}

1. (5-C-01) 필요한 도구를 설치한다: `sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates` → 결과: 설치가 끝난다.
2. (5-C-02) 도커 저장소 서명 키를 등록한다: `sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/containerd.gpg` → 결과: 오류 없이 끝난다.
3. (5-C-03) 도커 저장소를 추가한다: `sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"` → 결과: 저장소 목록이 갱신된다.
4. (5-C-04) containerd를 설치한다: `sudo apt update && sudo apt install containerd.io -y` → 결과: 설치가 끝난다.
5. (5-C-05) 기본 설정 파일을 생성한다: `containerd config default | sudo tee /etc/containerd/config.toml` → 결과: 설정이 출력되고 파일이 저장된다.
6. (5-C-06) cgroup 드라이버를 systemd로 바꾼다: `sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml` → 결과: `grep SystemdCgroup /etc/containerd/config.toml`이 `true`를 출력한다.
7. (5-C-07) containerd를 재시작한다: `sudo systemctl restart containerd` → 결과: `systemctl is-active containerd`가 `active`다.

### D. [전체 노드] 쿠버네티스 패키지 저장소 추가

1. (5-D-01) 키 보관 폴더가 없으면 만든다: `sudo mkdir -p -m 755 /etc/apt/keyrings` → 결과: 오류 없이 끝난다.
2. (5-D-02) 저장소 서명 키를 등록한다: `curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/k8s.gpg` → 결과: `/etc/apt/keyrings/k8s.gpg`가 생성된다.
3. (5-D-03) 저장소를 추가한다: `echo 'deb [signed-by=/etc/apt/keyrings/k8s.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/k8s.list` → 결과: 저장소 줄이 출력된다.

### E. [전체 노드] kubelet, kubeadm, kubectl 설치

1. (5-E-01) 패키지를 설치한다: `sudo apt update && sudo apt install kubelet kubeadm kubectl -y` → 결과: 설치가 끝난다.
2. (5-E-02) 자동 업그레이드를 막는다: `sudo apt-mark hold kubelet kubeadm kubectl` → 결과: 세 패키지가 `set on hold`로 출력된다. (원본에 없던 단계, 공식 문서 권장)
3. (5-E-03) 버전을 확인한다: `kubeadm version` → 결과: `v1.31.x` 형식의 버전이 출력된다.

### F. [전체 노드] 설치 점검

1. (5-F-01) containerd가 실행 중인지 확인한다: `systemctl is-active containerd` → 결과: `active`가 출력된다.
2. (5-F-02) swap이 꺼졌는지 확인한다: `free -h` → 결과: Swap 행이 0이다.

### G. [컨트롤 플레인 노드] 클러스터 초기화

{% hint style="info" %}
NOTE: Calico 기본 파드 대역과 노드 IP 대역이 겹치면 `kubeadm init`에 `--pod-network-cidr=<파드 대역>`을 추가하고, Calico 매니페스트의 `CALICO_IPV4POOL_CIDR`도 같은 값으로 맞춘다. 파드 대역은 노드 IP 대역과 겹치지 않아야 한다. 이 방법은 Calico 문서 기준이며 이 문서로 확인하지 않았다.
{% endhint %}

1. (5-G-01) 컨트롤 플레인을 초기화한다: `sudo kubeadm init --control-plane-endpoint=k8s-control-node` → 결과: `Your Kubernetes control-plane has initialized successfully!`가 출력되고, 끝에 `kubeadm join` 명령이 표시된다.
2. (5-G-02) 출력된 `kubeadm join` 명령을 워커 노드에서 쓸 수 있게 임시로 복사한다. 복사한 값은 작업이 끝나면 지운다. → 결과: 토큰과 해시가 보관된다.
3. (5-G-03) kubectl 설정 폴더를 만든다: `mkdir -p $HOME/.kube`
4. (5-G-04) 관리자 설정 파일을 복사한다: `sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config`
5. (5-G-05) 파일 소유자를 현재 사용자로 바꾼다: `sudo chown $(id -u):$(id -g) $HOME/.kube/config` → 결과: `kubectl get nodes`가 컨트롤 플레인 노드 1개를 `NotReady`로 출력한다.

{% hint style="info" %}
NOTE: 원본은 마지막에 `export KUBECONFIG=/etc/kubernetes/admin.conf`도 적었다. `sudo` 없이 `kubectl`을 쓰려면 5-G-03~05의 복사만으로 충분하다. `export`는 root로 작업할 때만 쓴다.
{% endhint %}

### H. [워커 노드] 클러스터 조인

{% hint style="danger" %}
WARNING: 아래 명령의 `<토큰>`과 `<인증서 해시>`는 5-G-01 출력의 실제 값으로 바꿔 입력한다. 이 값을 문서에 적지 않는다.
{% endhint %}

1. (5-H-01) 워커 노드 1에서 조인한다: `sudo kubeadm join k8s-control-node:6443 --token <토큰> --discovery-token-ca-cert-hash sha256:<인증서 해시>` → 결과: `This node has joined the cluster`가 출력된다.
2. (5-H-02) 워커 노드 2에서 같은 명령을 실행한다. → 결과: 같은 메시지가 출력된다.
3. (5-H-03) 토큰이 만료됐으면 컨트롤 플레인에서 새로 만든다: `kubeadm token create --print-join-command` → 결과: 새 `kubeadm join` 명령이 출력된다.

### I. [컨트롤 플레인 노드] 노드 상태 확인과 Calico 설치

1. (5-I-01) 노드 상태를 확인한다: `kubectl get nodes` → 결과: 노드 3개가 `NotReady`로 보인다. 네트워크 플러그인이 없어서 정상이다.
2. (5-I-02) Calico를 설치한다: `kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml` → 결과: 여러 리소스가 `created`로 출력된다.
3. (5-I-03) 시스템 파드를 확인한다: `kubectl get pods -n kube-system` → 결과: calico 관련 파드가 `Running`이 될 때까지 1~2분 걸린다.
4. (5-I-04) 노드 상태를 다시 확인한다: `kubectl get nodes` → 결과: 노드 3개가 모두 `Ready`다.

### J. [컨트롤 플레인 노드] 설치 테스트

1. (5-J-01) 네임스페이스를 만든다: `kubectl create ns demo-app` → 결과: `namespace/demo-app created`
2. (5-J-02) nginx Deployment를 만든다: `kubectl create deployment nginx-app --image nginx --replicas 2 --namespace demo-app` → 결과: `deployment.apps/nginx-app created`
3. (5-J-03) 배포를 확인한다: `kubectl get deployment -n demo-app` → 결과: READY가 `2/2`다.
4. (5-J-04) 파드를 확인한다: `kubectl get pods -n demo-app` → 결과: 파드 2개가 `Running`이다.
5. (5-J-05) NodePort 서비스로 노출한다: `kubectl expose deployment nginx-app -n demo-app --type NodePort --port 80` → 결과: `service/nginx-app exposed`
6. (5-J-06) 서비스의 NodePort를 확인한다: `kubectl get svc -n demo-app` → 결과: PORT(S) 열이 `80:<노드포트>/TCP` 형식이다. 노드포트는 30000-32767 범위에서 자동 할당된다.
7. (5-J-07) 워커 노드 IP와 노드포트로 접속한다: `curl http://<워커 IP 주소>:<노드포트>` → 결과: `Welcome to nginx!` 페이지 HTML이 출력된다.

### K. [선택] Helm 설치

1. (5-K-01) 컨트롤 플레인 노드에 Helm을 설치한다: `sudo snap install helm --classic` → 결과: 설치가 끝난다.
2. (5-K-02) 설치를 확인한다: `helm version` → 결과: 버전이 출력된다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kubectl get nodes` | 노드 3개 | 모두 `Ready` |
| 2 | `kubectl get pods -n kube-system` | 시스템 파드 | 모두 `Running` |
| 3 | `kubectl get pods -n demo-app` | nginx 파드 2개 | 모두 `Running` |
| 4 | `curl http://<워커 IP 주소>:<노드포트>` | nginx 기본 페이지 | `Welcome to nginx!` 포함 |

## 7. 복구

{% hint style="danger" %}
WARNING: `kubeadm reset`은 그 노드의 쿠버네티스 구성과 클러스터 소속 정보를 지운다. 컨트롤 플레인 노드에서 실행하면 클러스터 데이터(etcd)가 사라진다. 되돌릴 수 없다. 대상 노드를 확인한 뒤 실행한다.
{% endhint %}

1. (7-01) 테스트 리소스를 삭제한다: `kubectl delete ns demo-app` → 결과: `namespace "demo-app" deleted`가 출력된다. 네임스페이스 안의 Deployment, 파드, 서비스가 함께 삭제된다.
2. (7-02) 워커 노드를 클러스터에서 뺀다. 컨트롤 플레인에서 `kubectl drain <노드 이름> --ignore-daemonsets --delete-emptydir-data`, 이어서 `kubectl delete node <노드 이름>`을 실행한다. → 결과: 노드가 `kubectl get nodes`에서 사라진다.
3. (7-03) 각 노드에서 구성을 초기화한다: `sudo kubeadm reset` → 결과: 확인 질문에 `y`를 입력하면 초기화가 끝난다.
4. (7-04) 필요하면 swap을 다시 켠다. `/etc/fstab`의 swap 줄에서 `#`를 지우고 `sudo swapon -a`를 실행한다. → 결과: `free -h`의 Swap 행이 0이 아니다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 페이지를 AMM 형식으로 재작성. 조인 토큰과 인증서 해시, 노드 IP, NodePort 번호를 자리 표시자로 바꿨고 저장소 버전을 v1.31로 통일했다. 영상 홍보 문구를 삭제했다. 안전 사항, 기능 확인, 복구 절차를 추가했다. 대시보드 문서 링크 카드는 참조 절로 옮겼다 |
