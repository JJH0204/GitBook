# 15일차 · 쿠버네티스 입문

> 2단계 · 서버 구축 및 활용. 상위: [네트워크 2](../README.md)
> 이전: [14일차 · 도커 기초](../day-14/README.md) · 다음: [16일차 · 쿠버네티스로 배포하고 공개하기](../day-16/README.md)

## 개요

14일차 마지막에 `docker compose up -d` 한 줄로 웹과 DB를 세웠다. 환경 전체를 파일에 적어 Git에 넣었으니, 어디서든 그 한 줄이면 된다.

그런데 그 한 줄은 내가 지켜보고 있어야 한다. 컨테이너가 죽으면 내가 다시 `up` 해야 한다. 접속이 몰리면 내가 더 띄워야 한다. 그리고 그 전부는 내 PC 한 대 안에서만 일어난다.

오늘의 답은 원하는 상태를 적어 두면 그 상태를 지켜 주는 것, 쿠버네티스(Kubernetes)다.

```bash
kubectl apply -f deployment.yaml     # "web 을 3개 띄워 둬라"
kubectl delete pod web-xxxx          # 하나 지워도
kubectl get pods                     # 다시 3개가 되어 있다
```

| 질문 | 오늘의 답 | 노트 |
|---|---|---|
| Compose로 충분하지 않은가? | 죽으면 되살리고, 몰리면 늘리고, 여러 대에 나눈다 | 1 |
| `docker run`과 무엇이 다른가? | "해라"(명령형)에서 "이렇게 되어 있어라"(선언형)로 | 1 |
| 클러스터는 어떻게 세우는가? | kind. 14일차 Docker 위에 올린다. 노드가 곧 컨테이너다 | 2 |
| 또 여섯 단계인가? | 그렇다. ① 설치 ② 설정 ③ 기동 ④ 확인 | 2 |
| 외울 단어는 몇 개인가? | Pod, Deployment, Service 셋 | 3 |
| Compose 파일은 어디로 갔는가? | 매니페스트(YAML)로. `apply`가 `up` 자리다 | 4 |
| 정말 알아서 되살아나는가? | Pod를 지워 본다 | 5 |
| `kubectl`은 무엇을 하고 있는가? | API를 부르고 있다(A안) | 6 |
| 안 될 때는 어디를 보는가? | 라벨, `logs`, `describe`, `exec`(B안) | 7 |

## 오늘의 목표

- Compose로 안 되는 일 세 가지를 들고, 쿠버네티스가 그중 무엇을 푸는지 말한다.
- 명령형과 선언형의 차이를 한 문장으로 설명한다.
- kind로 클러스터를 세우고, 그 노드가 Docker 컨테이너임을 확인한다.
- Pod, Deployment, Service를 구분하고 각각을 만든다.
- 매니페스트(YAML)를 쓰고 `kubectl apply -f`로 적용한다.
- Pod를 지워도 되살아나는 것과, `replicas`로 개수가 맞춰지는 것을 눈으로 본다.
- (A안) `kubectl`이 API 클라이언트임을 `curl`과 `jq`로 확인한다.
- (B안) 라벨과 셀렉터를 이해하고 `logs`, `describe`, `exec`로 들여다본다.

## 문서 목록과 읽는 순서

실습 중에는 0번(명령어 대본)을 화면에 띄워 둔다. 6번과 7번은 택1이다. 당일 설치 속도와 반 분위기를 보고 고른다.

| 순서 | Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|---|
| 1 | LEC-N2-15-009-REF | REF | [0. 15일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)](commands.md) | STEP 0~8 명령 대본, 환경 점검, 정리 |
| 2 | LEC-N2-15-001-DO | D&O | [1. 왜 쿠버네티스인가 — Compose가 못 하는 세 가지](lesson-1.md) | Compose의 한계 셋, 명령형과 선언형, 조정 루프 |
| 3 | LEC-N2-15-002-DO | D&O | [2. 클러스터를 세운다 — kind는 Docker 위에 올라간다](lesson-2.md) | `kubectl`과 `kind`, 노드는 컨테이너, 알려진 함정 |
| 4 | LEC-N2-15-010-MP | MP | [클러스터 생성 실습](lesson-2-lab.md) | `kubectl`, `kind` 설치, 클러스터 생성, `docker ps` 확인 |
| 5 | LEC-N2-15-003-DO | D&O | [3. 첫 배포 — Pod · Deployment · Service](lesson-3.md) | 세 단어, Service, `port-forward`, 14일차 대응표 |
| 6 | LEC-N2-15-011-MP | MP | [첫 배포 실습](lesson-3-lab.md) | `create deployment`, `expose`, 이름 통신, `port-forward` |
| 7 | LEC-N2-15-004-DO | D&O | [4. 선언형 — 매니페스트와 apply](lesson-4.md) | 매니페스트 네 줄 머리, 라벨 짝, `apply`, Compose 대응표 |
| 8 | LEC-N2-15-012-MP | MP | [매니페스트 적용 실습](lesson-4-lab.md) | YAML 작성, `apply`, 두 번 적용, Git에 넣기 |
| 9 | LEC-N2-15-005-DO | D&O | [5. 자가 치유와 스케일 — 지워도 돌아온다](lesson-5.md) | 개수 맞춤, 스케일, 프로브 개념 |
| 10 | LEC-N2-15-013-MP | MP | [Pod 삭제와 스케일 실습](lesson-5-lab.md) | Pod 삭제, `scale`, 파일로 반영 |
| 11 | LEC-N2-15-006-DO | D&O | [6. kubectl은 API 클라이언트다](lesson-6.md) | A안. API, REST, `-v=6`, `proxy`, `jq` |
| 12 | LEC-N2-15-014-MP | MP | [API 들여다보기 실습](lesson-6-lab.md) | A안. `-v=6`, `kubectl proxy`, `curl`, `jq` |
| 13 | LEC-N2-15-007-DO | D&O | [7. 더 들어가기 — 라벨 · 로그 · 진단](lesson-7.md) | B안. 라벨, `describe`의 Events, 진단 순서, 네임스페이스 |
| 14 | LEC-N2-15-015-MP | MP | [라벨과 진단 실습](lesson-7-lab.md) | B안. 라벨 바꾸기, `logs`, `describe`, `exec` |
| 15 | LEC-N2-15-008-INS | INS | [8. 오늘의 문제](lesson-8.md) | 문제 10문항(Q9는 A안, Q10은 B안 전용) |

## 오늘의 실습 환경: WSL + Docker Engine + kind

```
   Windows  --localhost-->  WSL (Ubuntu 24.04)
                              ├─ Docker Engine 29.x        ← 14일차에 설치한 그것
                              │    └─ kind 노드 = 컨테이너 1개
                              │         └─ 그 안에서 Pod 들이 돈다
                              └─ kubectl, kind             ← 오늘 받는 바이너리 두 개
```

{% hint style="info" %}
NOTE: 클러스터는 Docker 위에 선다. 14일차에 세운 Docker Engine을 그대로 쓰고, 노드는 `docker ps`에 컨테이너로 보인다. 이 장면이 14일차와 오늘을 잇는 다리다.
{% endhint %}

### 수업 시작 전 점검: 다섯 줄

```bash
stat -fc %T /sys/fs/cgroup         # cgroup2fs 여야 한다. tmpfs 면 클러스터가 안 뜬다
ps -p 1 -o comm=                   # systemd 여야 한다(12일차에 켰다)
docker info --format '{{.ServerVersion}}'   # 29.x. 14일차에 설치한 것
ip route get 203.0.113.1 | head -1 # 내 WSL 주소(src 뒤)
free -h                            # 클러스터는 메모리를 먹는다. 2GB 이상 여유
```

{% hint style="danger" %}
WARNING: 첫 줄이 가장 중요하다. `cgroup2fs`가 아니면 클러스터 생성이 실패한다. 리허설에서 실제로 막힌 지점이다(아래 함정 표).
{% endhint %}

### WSL에서 kind를 돌릴 때의 알려진 함정

| 증상 | 원인 | 대응 |
|---|---|---|
| `Starting control-plane ✗`로 멈춘다 | 호스트가 cgroup v1 | cgroup v2로 올려야 한다. 노드 이미지를 낮춰도 안 된다(실측) |
| `too many open files` | inotify 한도가 낮다 | `sudo sysctl fs.inotify.max_user_watches=524288`, `sudo sysctl fs.inotify.max_user_instances=512` |
| 노드는 떴는데 통신이 안 된다 | VPN(Tailscale 등)과 172.17 대역 충돌 | `/etc/docker/daemon.json`의 `default-address-pools`로 대역을 옮긴다 |

{% hint style="danger" %}
WARNING: cgroup v1이면 어떤 노드 이미지를 써도 클러스터가 뜨지 않는다. kubelet이 `kubelet is configured to not run on a host using cgroup v1`이라고 말하고 멈춘다. 낮은 쿠버네티스 이미지(v1.33, v1.32)로도 kind가 경고하고 실패한다. 탈출구는 cgroup v2뿐이다.
{% endhint %}

{% hint style="danger" %}
WARNING: 이 표는 리허설 없이 교실에 들고 가면 안 된다. 설치는 14일차에도 최대 병목이었다. [STEP 0](commands.md)에서 미리 걸어 두는 것이 유일한 방어다.
{% endhint %}

## 오늘의 진행: 4시간(240분), 두 가지 안

### A안: API를 함께 (원래 커리큘럼의 API 실습을 살린다)

| 순서 | 내용 | 이론 | 실습 | 누적 |
|---|---|---|---|---|
| 0 | 몸풀기. WSL 점검, 설치 미리 걸기 | 5분 | 5분 | 10분 |
| 1 | 왜 쿠버네티스인가(판서) | 25분 | | 35분 |
| 2 | 설치, 클러스터 생성 | 10분 | 25분 | 70분 |
| | 쉬는 시간 10분 | | | 80분 |
| 3 | Pod, Deployment, Service | 15분 | 25분 | 120분 |
| 4 | 매니페스트와 `apply` | 10분 | 20분 | 150분 |
| | 쉬는 시간 10분 | | | 160분 |
| 5 | 자가 치유, 스케일 | 5분 | 20분 | 185분 |
| 6 | A안: API로 들여다보기(`proxy`, `curl`, `jq`) | 10분 | 15분 | 210분 |
| 8 | 오늘의 문제 | 20분 | | 230분 |

### B안: 쿠버네티스로 꽉 채운다 (설치가 늦어졌거나 반이 어려워할 때)

| 순서 | 내용 | 이론 | 실습 | 누적 |
|---|---|---|---|---|
| 0 | 몸풀기, 설치 미리 걸기 | 5분 | 5분 | 10분 |
| 1 | 왜 쿠버네티스인가(판서) | 25분 | | 35분 |
| 2 | 설치, 클러스터 생성 | 10분 | 30분 | 75분 |
| | 쉬는 시간 10분 | | | 85분 |
| 3 | Pod, Deployment, Service | 15분 | 30분 | 130분 |
| 4 | 매니페스트와 `apply` | 10분 | 25분 | 165분 |
| | 쉬는 시간 10분 | | | 175분 |
| 5 | 자가 치유, 스케일 | 5분 | 20분 | 200분 |
| 7 | B안: 더 들어가기. 라벨, `logs`, `describe`, `exec` | 10분 | 15분 | 225분 |
| 8 | 오늘의 문제(5문항만) | 10분 | | 235분 |

{% hint style="info" %}
NOTE: 필수는 2, 3, 5번이다. 시간이 모자라면 4번(강사가 파일을 나눠 주고 읽기만), 6번과 7번(생략) 순으로 줄인다. 5번(Pod를 지워도 돌아온다)은 오늘의 결론이다. 여기까지는 무슨 일이 있어도 간다.
{% endhint %}

## AI 활용

- 매니페스트 초안, `kubectl` 옵션 해석, 에러 메시지 읽기에 쓴다.
- 10일차 [AI 검증 원칙](../day-10/lesson-5.md)을 그대로 따른다. 초안은 AI가 쓰고 확인은 공식 문서로 한다. 쿠버네티스는 버전마다 필드가 달라지므로 특히 그렇다.

{% hint style="danger" %}
WARNING: `kubectl delete -f .`, `kind delete cluster`, `kubectl delete ns`가 AI의 답에 있으면 3초 멈춘다. 안의 것이 통째로 사라진다.
{% endhint %}

## 강의 메모

- 도입: 학생이 14일차 `compose.yaml`을 열어 놓고 시작한다. 질문은 "이 한 줄을 누가 지켜보고 있는가?"이다.
- 명령형과 선언형이 오늘의 전부다. 나머지 용어는 거기 딸린 것이다. 칠판에 `docker run`(해라)과 `kubectl apply`(이렇게 되어 있어라)를 적는다.
- 2번에서 `docker ps`를 꼭 친다. 노드가 컨테이너라는 것을 보면 "완전히 새로운 것"이라는 공포가 사라진다.
- 5번에서 Pod를 지우는 장면은 반드시 전원이 직접 친다. 설명 열 마디보다 낫다.
- 최대 병목은 세 가지이다.
  1. 설치와 클러스터 생성. 노드 이미지를 받느라 수 분이 걸린다. STEP 0에서 미리 건다.
  2. YAML 들여쓰기. 14일차 Compose에서 한 번 겪었다. `kubectl apply --dry-run=client`를 습관으로 만든다.
  3. 용어 폭격. Pod, Deployment, Service 셋만 쓴다. ReplicaSet과 Namespace는 B안에서만 다룬다.
- 발표용 Excalidraw 그림은 아직 없다. Deployment, ReplicaSet, Pod 그림은 판서로 그린다.

## 리허설로 확인한 것

환경: 클라우드 컨테이너(WSL 아님), 2026-10-20. Docker Engine 29.9.1과 containerd 이미지 저장소(교실과 같은 조건), 커널 6.18, cgroup v1. WSL 고유 조건(네트워크 모드 등)은 확인되지 않았다.

### 확인된 것

| 항목 | 결과 |
|---|---|
| `kubectl` 설치(dl.k8s.io) | `stable.txt`로 v1.37.1을 받아 설치됨 |
| kind v0.33.0 | 실재하는 안정 버전 |
| 노드 이미지 | kind v0.33.0은 `kindest/node:v1.37.0`을 쓴다 |
| `kind-config.yaml`(extraPortMappings) | 문법 유효. `Writing configuration ✓`까지 통과 |
| `kubectl create deployment --dry-run=client -o yaml` | 4번 노트의 매니페스트와 같은 구조가 생성된다(라벨 짝 포함) |
| `kind load` 하위 명령 | `docker-image`, `image-archive` 둘 다 존재 |

### 고친 것

1. cgroup v1에서는 클러스터가 안 뜬다. 실제로 `Starting control-plane ✗`에서 멈추고 kubelet이 `kubelet is configured to not run on a host using cgroup v1`을 남긴다. 노드 이미지를 v1.33, v1.32로 낮춰도 kind가 경고하고 실패한다. 사전 점검에 `stat -fc %T /sys/fs/cgroup` 한 줄을 넣었다.
2. inotify는 원인이 아니었다. 한도를 올려도(128에서 512로) 같은 지점에서 실패했다. 다만 kind 문서가 권하는 설정이라 대본에는 남겼다.
3. `kubectl apply --dry-run=client`는 완전한 오프라인 검사가 아니다. 클러스터에 한 번 물어본다. 클러스터가 죽어 있으면 `connection refused`가 뜬다(문법 오류가 아니다). 4번 노트에 주석을 달았다.

### 확인하지 못한 것(교실 리허설에서 확인할 것)

- 클러스터가 실제로 뜨는 것 전부: `kubectl get nodes`, `docker ps`에 노드가 보이는 장면.
- 3번 노트의 `create deployment`, `expose`, `port-forward`의 실제 동작.
- 5번 노트의 Pod를 지우면 새 Pod가 생기는 장면(오늘의 하이라이트).
- 6번 노트(A안)의 `kubectl proxy`, `curl`, `jq`.
- WSL에서의 cgroup 버전. 학생 PC마다 다를 수 있다. 수업 전 공지로 위 점검 한 줄을 미리 확인시키는 것이 가장 안전하다.
