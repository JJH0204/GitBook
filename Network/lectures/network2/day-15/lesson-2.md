# 2. 클러스터를 세운다 — kind 는 Docker 위에 올라간다

> 상위: [15일차 · 쿠버네티스 입문](README.md) · 절차는 [클러스터 생성 실습](lesson-2-lab.md), 대본은 [STEP 2](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-002-DO |
| 유형 | D&O (개념) |
| 목적 | `kubectl`과 `kind`의 역할, 클러스터 생성이 12일차 여섯 단계와 같은 흐름임, 클러스터의 노드가 Docker 컨테이너임, 클러스터가 일회용임, WSL에서의 알려진 함정을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- `kubectl`과 `kind`가 각각 무엇인지 구분한다.
- 클러스터를 세우는 과정이 12일차 여섯 단계임을 확인한다.
- 클러스터의 노드가 Docker 컨테이너라는 것을 `docker ps`로 직접 본다.
- 클러스터를 지우고 다시 만든다(일회용이라는 감각).

## 1. 목적

쿠버네티스는 서버가 여러 대일 때 쓴다. 그런데 교실에는 PC 한 대씩밖에 없다. 그래서 오늘은 한 대 안에 클러스터 흉내를 낸다.

> 강사 대사: "14일차에 세운 Docker 기억하시죠? 그 위에 올립니다. 노드가 곧 컨테이너입니다."

kind라는 도구가 그 일을 한다. 이름 그대로 **K**ubernetes **IN** **D**ocker다.

## 2. 구성 요소

### 받는 것은 바이너리 두 개

| 도구 | 무엇인가 | 14일차로 치면 |
|---|---|---|
| `kubectl` | 클러스터에 명령을 보내는 쪽 | `docker` 명령어 |
| `kind` | 클러스터를 만들고 지우는 쪽 | (14일차에는 없던 것) |

{% hint style="info" %}
NOTE: 둘은 다른 도구다. `kind`로 클러스터를 만들고, 그 뒤로는 거의 전부 `kubectl`을 친다. Docker 때와 달리 apt 저장소를 등록하지 않는다. 실행 파일 하나를 받아 `PATH`에 두는 방식이다.
{% endhint %}

`kubectl` 받기 명령(구역 A는 [클러스터 생성 실습](lesson-2-lab.md)):

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
```

`$(curl ... stable.txt)`가 현재 안정 버전 번호를 받아 URL에 끼워 넣는다. 14일차에 우분투 코드명을 자동으로 넣던 그 수법이다.

{% hint style="warning" %}
CAUTION: kind의 버전 번호는 바뀐다. 수업 전에 kind 공식 문서의 Quick Start에서 현재 안정 버전을 확인하고 숫자를 맞춘다.
{% endhint %}

### 클러스터 생성도 여섯 단계다

```bash
kind create cluster --name student
```

```
Creating cluster "student" ...
 ✓ Ensuring node image ...
 ✓ Preparing nodes
 ✓ Writing configuration
 ✓ Starting control-plane
 ✓ Installing CNI
 ✓ Installing StorageClass
Set kubectl context to "kind-student"
```

{% hint style="info" %}
NOTE: 처음 한 번은 수 분 걸린다. 노드 이미지를 받기 때문이다. 두 번째부터는 훨씬 빠르다.
{% endhint %}

| 단계 | 12일차(apt) | 14일차(docker) | 오늘(kind) |
|---|---|---|---|
| ① 설치 | `apt install` | 이미지 안에 | 바이너리 두 개를 받는다 |
| ② 설정 | `nano /etc/...` | `-e`, `compose.yaml` | `kind-config.yaml`(16일차) |
| ③ 기동 | `systemctl enable --now` | `docker run -d` | `kind create cluster` |
| ④ 확인 | `ss`, `systemctl status` | `docker ps` | `kubectl get nodes` |
| ⑤ 개방 | `ufw allow` | `-p 8080:80` | (16일차) |
| ⑥ 검증 | 브라우저 | `curl` | `kubectl get pods -A` |

④ 확인의 출력은 다음과 같다.

```
NAME                    STATUS   ROLES           AGE   VERSION
student-control-plane   Ready    control-plane   60s   v1.37.0
```

`VERSION`은 kind 버전이 정한다. kind `v0.33.0`은 노드 이미지 `kindest/node:v1.37.0`을 쓴다(실측). 숫자를 외우지 않고 `Ready`가 떴는지만 본다.

`kubectl get pods -A`(⑥ 검증)를 치면 쿠버네티스 자신의 부품들이 보인다. `kube-system` 네임스페이스에 `coredns`, `etcd`, `kube-apiserver` 같은 것들이 떠 있다. 쿠버네티스 자신도 컨테이너로 돈다. 지금은 "이런 것이 있다"까지만 안다.

### 노드는 컨테이너다

14일차 명령을 그대로 친다.

```bash
docker ps
```

```
CONTAINER ID   IMAGE                  ...   NAMES
a1b2c3d4e5f6   kindest/node:v1.xx.x   ...   student-control-plane
```

> 강사 대사: "방금 만든 '노드'가 `docker ps`에 보입니다. 쿠버네티스 클러스터 전체가, 지금 여러분 PC에서는 컨테이너 한 개입니다."

```
 WSL
  └─ Docker Engine                       ← 14일차
       └─ 컨테이너 1개 = kind 노드        ← 오늘
            └─ 그 안에서 Pod 들이 돈다     ← 3번 노트
```

이 그림이 오늘의 공포를 없앤다. 쿠버네티스는 새로운 세계가 아니라 14일차 위에 올라간 한 층이다. 14일차 1번 노트의 "VM 위의 컨테이너"를 기억한다. 오늘은 "컨테이너 안의 쿠버네티스"이고, 층은 계속 쌓인다.

### 클러스터는 일회용이다

| 명령 | 뜻 |
|---|---|
| `kind get clusters` | 클러스터 목록 |
| `kind delete cluster --name student` | 클러스터 삭제 |
| `kind create cluster --name student` | 다시 만든다(두 번째는 빠르다) |

14일차 "컨테이너는 일회용"이 한 칸 올라간 것이다. 클러스터도 일회용이다. 망가지면 고치려 애쓰지 않고 지우고 다시 만든다.

{% hint style="danger" %}
WARNING: `kind delete cluster`는 3초 멈춘다. 안에 있던 것이 전부 사라진다. 11일차 `ufw reset`, 14일차 `docker system prune -a`와 같은 자리다.
{% endhint %}

`kubectl config current-context`(결과: `kind-student`)는 kubectl이 어느 클러스터를 보고 있는지 보여 준다. `kind create cluster`는 kubectl이 바라볼 곳을 자동으로 바꿔 준다. 클러스터를 여러 개 만들면 이 값으로 구분한다.

### 안 될 때: 우리 환경의 알려진 함정

| 증상 | 원인 | 대응 |
|---|---|---|
| `Starting control-plane ✗` | 호스트가 cgroup v1 | cgroup v2로 올린다. 아래 참조 |
| `too many open files` | inotify 한도가 낮다 | `sudo sysctl fs.inotify.max_user_watches=524288`, `sudo sysctl fs.inotify.max_user_instances=512` |
| 노드는 `Ready`인데 통신이 안 된다 | VPN과 172.17 대역 충돌 | VPN을 끄고 다시 시도한다 |
| 만들다 멈춘 것 같다 | 노드 이미지를 받는 중 | 기다린다. 중간에 끊지 않는다 |

cgroup 버전은 다음 한 줄로 확인한다.

```bash
stat -fc %T /sys/fs/cgroup        # cgroup2fs 이면 정상, tmpfs 이면 cgroup v1
```

`tmpfs`가 나오면 cgroup v1이다. 클러스터를 만들면 `Starting control-plane`에서 ✗로 멈추고, 노드 안 kubelet이 이렇게 말한다(리허설 실측).

```
kubelet is configured to not run on a host using cgroup v1.
cgroup v1 support is unsupported and will be removed in a future release
```

{% hint style="danger" %}
WARNING: 노드 이미지를 낮춰도 안 된다. `--image kindest/node:v1.33.1`, `v1.32.5`로도 kind가 `cgroup v1 is deprecated ... please upgrade to cgroup v2`라고 경고하고 실패한다(실측). 탈출구는 호스트를 cgroup v2로 올리는 것뿐이다. 최신 WSL2는 대개 v2지만, 수업 전에 학생 PC에서 위 한 줄을 꼭 확인한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 원본에는 "kind는 Windows와 WSL을 공식 지원 대상으로 두지 않는다. 대부분의 WSL2에서 잘 돌지만 반드시 리허설로 확인한다"라고 적혀 있다. 이 문장의 정확성은 확인되지 않았다. 설치가 끝까지 안 되는 PC가 나오면 2인 1조로 묶는다. 14일차에 쓴 방법 그대로다.
{% endhint %}

## 3. 동작 원리

1. `kind create cluster`가 `kindest/node` 이미지를 받는다.
2. 그 이미지로 Docker 컨테이너 한 개(노드)를 만든다.
3. 노드 안에서 쿠버네티스 부품(`kube-apiserver`, `etcd`, `coredns` 등)이 컨테이너로 뜬다.
4. kind가 kubectl이 바라볼 곳(context)을 `kind-<이름>`으로 바꾼다.
5. 이후 `kubectl` 명령은 그 클러스터의 API 서버로 간다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| `kubectl` | 클러스터에 명령을 보내는 도구 |
| `kind` | Kubernetes IN Docker. 클러스터를 컨테이너로 만드는 도구 |
| 노드(node) | 컨테이너가 도는 곳. 오늘은 Docker 컨테이너 1개 |
| context | `kubectl`이 바라보는 클러스터 |
| cgroup | 리눅스가 프로세스의 자원을 나누는 기능. kind는 v2가 필요하다 |
| `kube-system` | 쿠버네티스 자신의 부품이 사는 네임스페이스 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 여섯 단계 표 | 12일차, 14일차에 이어 세 번째로 칠판에 다시 그린다 |
| 2 | 층 그림 | WSL, Docker Engine, kind 노드(컨테이너), Pod |

## 강의 메모

- 설치가 오늘의 최대 병목이다. STEP 0에서 `kubectl` 다운로드까지 미리 돌려 두고 그 사이 1번 노트를 판서한다.
- `docker ps`는 무슨 일이 있어도 친다. "노드 = 컨테이너" 한 장면이 오늘 절반이다.
- 여섯 단계 표를 칠판에 다시 그린다. 12일차, 14일차에 이어 세 번째다. 학생이 먼저 ③④를 말하기 시작한다.
- `kubectl get pods -A` 출력이 길어서 겁먹는다. "이건 쿠버네티스 자기 부품" 한 줄로 넘긴다.
- 버전 번호를 칠판에 적지 않는다. `kubectl get nodes`의 `Ready`만 확인시킨다.
- 리허설이 필수다. 알려진 함정 표는 전부 교실에서 확인해야 한다. 특히 cgroup 오류다.
- 35분(설치 15, 생성과 확인 20).

### 토의 질문

- `kubectl`과 `kind`는 각각 무슨 일을 하는가? 클러스터를 만든 뒤 더 많이 치는 쪽은?
- `docker ps`에 보이는 그 컨테이너를 `docker stop`하면 클러스터는 어떻게 되는가? (해 보기 전에 예상한다)
- `kind delete cluster` 후 `kubectl get nodes`를 치면 무슨 일이 생기는가?

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 클러스터를 만드는 과정을 여섯 단계로 다시 말한다. 빠진 단계는 무엇이고 언제 하는가?
- [ ] "노드가 컨테이너다"를 직접 본 뒤, 쿠버네티스에 대한 느낌이 어떻게 바뀌었는가?
- [ ] 클러스터가 일회용이라는 것은 운영에서 어떤 장점과 위험이 있는가?
