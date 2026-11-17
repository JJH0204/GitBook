# 15일차 · 쿠버네티스 입문

> 2단계 · 서버 구축 및 활용 — 상위: [네트워크 2](../README.md)
> 이전: [14일차 · 도커 기초](../day-14/README.md) · 다음: [16일차 · 쿠버네티스로 배포하기](../day-16/README.md)

14일차 마지막에 우리는 `docker compose up -d` 한 줄로 웹과 DB 를 세웠다. 환경 전체를 파일에 적어 Git 에 넣었으니, 이제 어디서든 그 한 줄이면 된다.

> 🗣 **"그런데 그 한 줄은, 제가 지켜보고 있어야 합니다."**

컨테이너가 죽으면 내가 다시 `up` 해야 한다. 접속이 몰리면 내가 더 띄워야 한다. 그리고 그 전부는 **내 PC 한 대 안**에서만 일어난다.

오늘의 답 — **원하는 상태를 적어 두면 그 상태를 지켜 주는 것**, 쿠버네티스다.

```bash
kubectl apply -f deployment.yaml     # "web 을 3개 띄워 둬라"
kubectl delete pod web-xxxx          # 하나 지워도
kubectl get pods                     # ⭐ 다시 3개가 되어 있다
```

| 질문 | 오늘의 답 | 노트 |
|------|-----------|------|
| Compose 로 충분하지 않나? | **죽으면 되살리고 · 몰리면 늘리고 · 여러 대에 나눈다** | 1 |
| `docker run` 과 뭐가 다른가? | **"해라"(명령형) → "이렇게 되어 있어라"(선언형)** ⭐ | 1 |
| 클러스터는 어떻게 세우나? | **kind** — 14일차 Docker 위에 올린다. 노드가 곧 컨테이너다 ⭐ | 2 |
| 또 여섯 단계인가? | 그렇다. ①설치 ②설정 ③기동 ④확인 | 2 |
| 외울 단어는 몇 개인가? | **Pod · Deployment · Service** 셋 | 3 |
| Compose 파일은 어디로 갔나? | **매니페스트(YAML)** 로. `apply` 가 `up` 자리다 | 4 |
| 정말 알아서 되살아나나? | **Pod 를 지워 본다** ⭐⭐ | 5 |
| `kubectl` 은 무엇을 하고 있나? | **API 를 부르고 있다** (A안) | 6 |
| 안 될 때는 어디를 보나? | **라벨 · logs · describe · exec** (B안) | 7 |

## 🎯 오늘의 목표

- Compose 로 안 되는 일 **세 가지**를 들고, 쿠버네티스가 그중 무엇을 푸는지 말한다
- **명령형과 선언형**의 차이를 한 문장으로 설명한다 ⭐
- **kind** 로 클러스터를 세우고, 그 노드가 **Docker 컨테이너**임을 확인한다 ⭐
- **Pod · Deployment · Service** 를 구분하고 각각을 만든다
- 매니페스트(YAML)를 쓰고 **`kubectl apply -f`** 로 적용한다
- Pod 를 지워도 **되살아나는 것**과, `replicas` 로 **개수가 맞춰지는 것**을 눈으로 본다 ⭐⭐
- (A안) `kubectl` 이 **API 클라이언트**임을 `curl` 과 `jq` 로 확인한다
- (B안) 라벨·셀렉터를 이해하고 **`logs`·`describe`·`exec`** 로 들여다본다

## 📑 목차

0. [🖐 실습 명령어 대본 — 수업 흐름 그대로 (실습 중 띄워둘 것)](commands.md)
1. [왜 쿠버네티스인가 — Compose 가 못 하는 세 가지](lesson-1.md) ⭐
2. [클러스터를 세운다 — kind 는 Docker 위에 올라간다](lesson-2.md) ⭐
3. [첫 배포 — Pod · Deployment · Service](lesson-3.md) ⭐⭐
4. [선언형 — 매니페스트와 apply](lesson-4.md)
5. [자가 치유와 스케일 — 지워도 돌아온다](lesson-5.md) ⭐⭐
6. [kubectl 은 API 클라이언트다](lesson-6.md) 🅰️
7. [더 들어가기 — 라벨 · 로그 · 진단](lesson-7.md) 🅱️
8. [🎯 오늘의 문제](lesson-8.md)

> ⚖️ **6번과 7번은 택1이다.** 당일 설치 속도와 반 분위기를 보고 고른다.

## ⏱ 오늘의 진행 — 4시간(240분) · 두 가지 안

### 🅰️ A안 — API 를 함께 (원래 커리큘럼의 API 실습을 살린다)

| 순서 | 내용 | 이론 | 실습 | 누적 |
|------|------|------|------|------|
| **0** | 🔁 몸풀기 — WSL 점검 · **설치 미리 걸기** | 5분 | 5분 | 10분 |
| **1** | **왜 쿠버네티스인가** (판서) ⭐ | 25분 | — | 35분 |
| **2** | 설치 · **클러스터 생성** ⭐ | 10분 | 25분 | 70분 |
| | ── 쉬는 시간 10분 ── | | | 80분 |
| **3** | **Pod · Deployment · Service** ⭐⭐ | 15분 | 25분 | 120분 |
| **4** | 매니페스트와 `apply` | 10분 | 20분 | 150분 |
| | ── 쉬는 시간 10분 ── | | | 160분 |
| **5** | **자가 치유 · 스케일** ⭐⭐ | 5분 | 20분 | 185분 |
| **6** | 🅰️ **API 로 들여다보기** (`proxy` · `curl` · `jq`) | 10분 | 15분 | 210분 |
| **8** | 오늘의 문제 | 20분 | | **230분** |

### 🅱️ B안 — 쿠버네티스로 꽉 채운다 (설치가 늦어졌거나 반이 어려워할 때)

| 순서 | 내용 | 이론 | 실습 | 누적 |
|------|------|------|------|------|
| **0** | 🔁 몸풀기 · 설치 미리 걸기 | 5분 | 5분 | 10분 |
| **1** | 왜 쿠버네티스인가 (판서) ⭐ | 25분 | — | 35분 |
| **2** | 설치 · 클러스터 생성 ⭐ | 10분 | **30분** | 75분 |
| | ── 쉬는 시간 10분 ── | | | 85분 |
| **3** | Pod · Deployment · Service ⭐⭐ | 15분 | **30분** | 130분 |
| **4** | 매니페스트와 `apply` | 10분 | **25분** | 165분 |
| | ── 쉬는 시간 10분 ── | | | 175분 |
| **5** | 자가 치유 · 스케일 ⭐⭐ | 5분 | **20분** | 200분 |
| **7** | 🅱️ **더 들어가기** — 라벨 · `logs` · `describe` · `exec` | 10분 | 15분 | 225분 |
| **8** | 오늘의 문제 *(5문항만)* | 10분 | | **235분** |

> ⏱ **필수**: 2 · 3 · 5. 시간이 모자라면 **4(강사가 파일을 나눠 주고 읽기만) → 6/7(생략)** 순으로 줄인다.
> ⭐ **5번(Pod 를 지워도 돌아온다)** 은 오늘의 결론이다. 여기까지는 무슨 일이 있어도 간다.

## 🧪 오늘의 실습 환경 — WSL + Docker Engine + **kind**

```
   🪟 Windows  ──localhost──▶  🐧 WSL (Ubuntu 24.04)
                                 ├─ Docker Engine 29.x        ← 14일차에 설치한 그것
                                 │    └─ kind 노드 = 컨테이너 1개 ⭐
                                 │         └─ 그 안에서 Pod 들이 돈다
                                 └─ kubectl · kind            ← 오늘 받는 바이너리 두 개
```

> 📌 **클러스터는 Docker 위에 선다.** 14일차에 세운 Docker Engine 을 그대로 쓰고, 노드는 `docker ps` 에 **컨테이너로 보인다.** 이 장면이 14일차와 오늘을 잇는 다리다.

### 🚨 수업 시작 전 점검 — 네 줄

```bash
stat -fc %T /sys/fs/cgroup         # 🚨 cgroup2fs 여야 한다 — tmpfs 면 클러스터가 안 뜬다
ps -p 1 -o comm=                   # systemd 여야 한다 (12일차에 켰다)
docker info --format '{{.ServerVersion}}'   # 29.x — 14일차에 설치한 것
ip route get 1.1.1.1 | head -1     # 내 WSL 주소
free -h                            # ⭐ 클러스터는 메모리를 먹는다. 2GB 이상 여유
```

> 🚨 **첫 줄이 가장 중요하다.** `cgroup2fs` 가 아니면 **클러스터 생성이 실패한다.** 리허설에서 실제로 막힌 지점이다(아래 함정표).

### 🚨 WSL 에서 kind 를 돌릴 때의 알려진 함정

| 증상 | 원인 | 대응 |
|------|------|------|
| 🚨 `Starting control-plane ✗` 로 멈춘다 | **호스트가 cgroup v1** | **cgroup v2 로 올려야 한다.** 노드 이미지를 낮춰도 **안 된다**(실측) |
| `too many open files` | inotify 한도가 낮다 | `sudo sysctl fs.inotify.max_user_watches=524288` · `sudo sysctl fs.inotify.max_user_instances=512` |
| 노드는 떴는데 통신이 안 된다 | VPN(Tailscale 등)과 **172.17 대역 충돌** | `/etc/docker/daemon.json` 의 `default-address-pools` 로 대역을 옮긴다 |

> 🚨 **cgroup v1 이면 어떤 노드 이미지를 써도 안 된다.** kubelet 이 이렇게 말하고 멈춘다 —
> `kubelet is configured to not run on a host using cgroup v1`
> 낮은 쿠버네티스 이미지(v1.33 · v1.32)로도 **kind 가 경고하고 실패**한다. **탈출구는 cgroup v2 뿐이다.**

> 🚨 **이 표는 리허설 없이 교실에 들고 가면 안 된다.** 설치는 14일차에도 최대 병목이었다 → [STEP 0](commands.md) 에서 **미리 걸어 두는 것**이 유일한 방어다.

## 🤖 AI 활용

- **매니페스트 초안** · `kubectl` 옵션 해석 · 에러 메시지 읽기
- 🛑 `kubectl delete -f .` · `kind delete cluster` · `kubectl delete ns` 가 답에 있으면 **3초 멈춤** — 통째로 사라진다
- 📌 10일차 [AI 검증 원칙](../day-10/lesson-5.md) 그대로 — **초안은 AI, 확인은 공식 문서**. 쿠버네티스는 **버전마다 필드가 달라지므로** 특히 그렇다

## 📝 강의 메모

- 🗣 도입: 학생이 14일차 `compose.yaml` 을 열어 놓고 시작한다 → **"이 한 줄을 누가 지켜보고 있나요?"**
- ⭐⭐ **명령형 vs 선언형**이 오늘의 전부다. 나머지 용어는 거기 딸린 것이다
  - 칠판: `docker run`(해라) ↔ `kubectl apply`(이렇게 되어 있어라)
- ⭐ **2번에서 `docker ps` 를 꼭 친다** — 노드가 컨테이너라는 것을 보면 "완전히 새로운 것"이라는 공포가 사라진다
- ⭐⭐ **5번에서 Pod 를 지우는 장면**은 반드시 전원이 직접 친다. 설명 열 마디보다 낫다
- ⚠️ 최대 병목
  1. **설치와 클러스터 생성** — 노드 이미지를 받느라 수 분. STEP 0 에서 미리 건다
  2. **YAML 들여쓰기** — 14일차 Compose 에서 한 번 겪었다. `kubectl apply --dry-run=client` 를 습관으로
  3. **용어 폭격** — Pod/Deployment/Service **셋만** 쓴다. ReplicaSet·Namespace 는 B안에서만
- 📌 발표용 Excalidraw 드로잉은 **아직 없다** (Deployment → ReplicaSet → Pod 그림은 판서)

## 🔎 리허설로 확인한 것 (2026-10-20 · 클라우드 컨테이너, **WSL 아님**)

> 📌 **환경**: Docker Engine **29.9.1** + **containerd 이미지 저장소**(교실과 같은 조건) · 커널 6.18 · **cgroup v1**
> 🚨 **WSL 이 아니므로 WSL 고유 조건(네트워크 모드 등)은 확인되지 않았다.**

### ✅ 확인된 것

| 항목 | 결과 |
|------|------|
| `kubectl` 설치 (dl.k8s.io) | ✅ `stable.txt` → **v1.37.1** 받아 설치됨 |
| **kind v0.33.0** | ✅ 실재하는 안정 버전 |
| **노드 이미지** | ✅ kind v0.33.0 은 **`kindest/node:v1.37.0`** 을 쓴다 |
| `kind-config.yaml`(extraPortMappings) | ✅ **문법 유효** — `Writing configuration ✓` 까지 통과 |
| `kubectl create deployment --dry-run=client -o yaml` | ✅ 4번 절 매니페스트와 **같은 구조**가 생성된다(라벨 짝 포함) |
| `kind load` 하위 명령 | ✅ `docker-image` · `image-archive` 둘 다 존재 |

### 🚨 고친 것

1. **cgroup v1 에서는 클러스터가 안 뜬다** — 실제로 막혔다. `Starting control-plane ✗` 에서 멈추고 kubelet 이
   `kubelet is configured to not run on a host using cgroup v1` 을 남긴다.
   **노드 이미지를 v1.33 · v1.32 로 낮춰도 kind 가 경고하고 실패**한다 → **사전 점검에 `stat -fc %T /sys/fs/cgroup` 한 줄을 넣었다**
2. **inotify 는 원인이 아니었다** — 한도를 올려도(`128` → `512`) 같은 지점에서 실패했다. 다만 kind 문서가 권하는 설정이라 대본에는 남겼다
3. **`kubectl apply --dry-run=client` 는 완전한 오프라인 검사가 아니다** — 클러스터에 한 번 물어본다. 클러스터가 죽어 있으면 `connection refused` 가 뜬다(문법 오류가 아니다). 4번 절에 주석을 달았다

### ⚠️ 확인하지 못한 것 — **교실 리허설에서 확인할 것**

- 클러스터가 **실제로 뜨는 것** 전부: `kubectl get nodes` · `docker ps` 에 노드가 보이는 장면
- 3번 절 — `create deployment` · `expose` · `port-forward` 의 실제 동작
- 5번 절 — **Pod 를 지우면 새 Pod 가 생기는 장면**(오늘의 하이라이트)
- 6번 절 🅰️ — `kubectl proxy` + `curl` + `jq`
- **WSL 에서의 cgroup 버전** — 학생 PC 마다 다를 수 있다. 👉 **수업 전 공지로 위 한 줄을 미리 확인시키는 것이 가장 안전하다**
