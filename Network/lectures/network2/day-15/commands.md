# 0. 15일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [15일차 · 쿠버네티스 입문](README.md)
> 📌 `🐧` = WSL 안 · `🪟` = Windows 브라우저
> 🚨 **Pod 이름은 각자 다르다.** 대본의 이름을 그대로 치지 말고 `kubectl get pods` 로 확인해서 쓴다
> 🚨 **터미널을 두 개** 띄워 둔다 — `port-forward`·`proxy`·`get -w` 가 하나를 점유한다

---

# ▶ STEP 0 · 몸풀기 (10분)

### 0-1 🐧 환경 점검 — 네 줄

```bash
stat -fc %T /sys/fs/cgroup                  # 🚨 cgroup2fs 여야 한다 (tmpfs 면 오늘 못 한다)
ps -p 1 -o comm=                            # systemd 여야 한다 (12일차)
docker info --format '{{.ServerVersion}}'   # 29.x — 14일차에 설치한 것
ip route get 1.1.1.1 | head -1              # 내 WSL 주소
free -h                                     # ⭐ 2GB 이상 여유가 있어야 한다
```

> 🚨 **첫 줄에서 `tmpfs` 가 나오는 PC 는 클러스터가 안 뜬다.** 노드 이미지를 낮춰도 안 된다(실측).
> 👉 그 자리에서 고치려 하지 말고 **2인 1조로 묶는다.** 수업 뒤에 WSL cgroup v2 설정을 따로 안내한다.

### 0-2 🐧 inotify 한도 올리기 — 🚨 **클러스터 만들기 전에 반드시**

```bash
sudo sysctl fs.inotify.max_user_watches=524288
sudo sysctl fs.inotify.max_user_instances=512
```

> 🚨 안 하면 클러스터를 만들다 **`too many open files`** 로 멈춘다. 재부팅까지만 유효하다.

### 0-3 🐧 설치 미리 걸어 두기 ⏱ (이 사이에 STEP 1 판서)

```bash
sudo apt update && sudo apt install -y jq

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client

# jq가 설치되어 있는 경우 깔끔하게 값만 출력 
curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r .tag_name

# kind  ⚠️ 버전 번호는 수업 전에 공식 문서에서 확인할 것
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.33.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
kind --version
```

### 0-4 🐧 14일차 결과물 열어 두기 (도입에 쓴다)

```bash
cd ~/myweb && cat compose.yaml
```

---

# ▶ STEP 1 · 왜 쿠버네티스인가 (판서 25분) — [1_왜_쿠버네티스인가](lesson-1.md) ⭐

> 🗣 **도입** — 학생이 `compose.yaml` 을 띄워 놓은 채로
> **"이 한 줄을, 새벽 3시에 누가 지켜보고 있나요?"**
>
> 칠판 1 — **Compose 가 못 하는 셋**: 죽으면 내가 · 늘리면 내가 · 한 대 안
> 칠판 2 — ⭐⭐ **`docker run`(해라) ↔ `kubectl apply`(이렇게 되어 있어라)**
> 칠판 3 — **에어컨 비유**: "3분 틀어라" vs **"24도 유지해라"**
> 칠판 4 — 조정 루프 (화살표 두 개면 충분하다)
> 마무리 — **"안 써도 되는 경우"** 도 꼭 말한다 (④)

---

# ▶ STEP 2 · 클러스터 생성 (35분) — [2_클러스터_세우기](lesson-2.md) ⭐

### 2-1 🐧 만든다

```bash
kind create cluster --name student
```

> ⏱ **처음은 수 분.** 노드 이미지를 받는다. **중간에 끊지 않는다.**

### 2-2 🐧 ④ 확인

```bash
kubectl get nodes               # STATUS 가 Ready 면 성공
kubectl config current-context  # kind-student
kubectl get pods -A             # 쿠버네티스 자신의 부품들
```

### 2-3 🐧 ⭐⭐ 노드가 컨테이너다 — **이건 꼭 친다**

```bash
docker ps
```

> 🗣 **"방금 만든 '노드'가 `docker ps` 에 보입니다. 클러스터 전체가 지금은 컨테이너 한 개입니다."**
> 칠판 — WSL → Docker → kind 노드(컨테이너) → 그 안의 Pod

### 2-4 🐧 일회용이라는 감각 (시간 있으면)

```bash
kind get clusters
# kind delete cluster --name student     # 🛑 3초 멈춤 — 안의 것이 전부 사라진다
```

---

# ▶ STEP 3 · 첫 배포 (40분) — [3_첫_배포](lesson-3.md) ⭐⭐

### 3-1 🐧 띄운다

```bash
kubectl create deployment web --image=nginx
kubectl get deployments
kubectl get pods                # ⭐ 이름을 적어 둔다 (5번 절에서 쓴다)
```

### 3-2 🐧 Service 로 묶는다

```bash
kubectl expose deployment web --port=80
kubectl get services            # ClusterIP 가 붙는다
```

### 3-3 🐧 이름으로 통하는지 — **강사가 먼저 치고 보여준 뒤 따라 치게**

```bash
kubectl run tmp --image=busybox --rm -it --restart=Never -- wget -qO- http://web
```

> ⭐ **`http://web`** 이 통했다. 14일차 Compose 의 내부 DNS 와 같은 일이다.

### 3-4 🐧🪟 내 브라우저에서 — 터미널 B 를 점유한다

```bash
kubectl port-forward service/web 8080:80
```

```
🪟 http://localhost:8080   →  Welcome to nginx!
```

> ⭐ 14일차 **`-p 127.0.0.1:8080:80`** 과 같은 자리. **나만 보는 통로**다. `Ctrl+C` 로 끈다.

---

# ▶ STEP 4 · 매니페스트와 apply (30분) — [4_선언형_YAML](lesson-4.md)

### 4-1 🐧 지금 것을 파일로 꺼내 본다 (읽기만)

```bash
kubectl get deployment web -o yaml | head -20
```

### 4-2 🐧 직접 적는다 — ⏱ **강사가 파일을 공유하면 10분 번다**

```bash
mkdir -p ~/k8s && cd ~/k8s
nano deployment.yaml
nano service.yaml
```

> 🚨 칠판에 **`kind:` = 종류 / `kind` = 도구** 를 적어 둘 것. 오늘 1번 혼동 지점이다.
> ⭐ 두 `app: web` 을 **같은 색 형광펜**으로 표시해 보여준다.

### 4-3 🐧 적용

```bash
kubectl apply -f deployment.yaml --dry-run=client     # ⭐ 먼저 문법 검사
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get deploy,svc,pods
```

### 4-4 🐧 ⭐ 두 번 쳐 본다

```bash
kubectl apply -f deployment.yaml      # deployment.apps/web unchanged
```

> 🗣 **"아무 일도 안 일어났습니다. 이미 그 상태니까요. 이게 선언형입니다."**

### 4-5 🐧 Git 에 넣는다

```bash
cd ~/myweb && mkdir -p k8s && cp ~/k8s/*.yaml k8s/
git add k8s/ && git commit -m "쿠버네티스 매니페스트 추가" && git push
```

---

# ▶ STEP 5 · 자가 치유와 스케일 (25분) — [5_자가치유와_스케일](lesson-5.md) ⭐⭐

### 5-1 🐧 **터미널 A** — 지켜보는 창

```bash
kubectl get pods -w
```

### 5-2 🐧 **터미널 B** — 깨뜨리는 창

```bash
kubectl get pods                       # 내 Pod 이름 확인 ⭐
kubectl delete pod <여기에 내 Pod 이름>
```

> 🗣 **"터미널 A 를 보세요. 그리고 이름을 보세요. 되살아난 게 아니라 새로 생긴 겁니다."**
> ⭐⭐ **오늘의 하이라이트.** 전원이 직접 친다.

### 5-3 🐧 개수를 바꾼다

```bash
kubectl scale deployment web --replicas=3
kubectl get pods
kubectl get endpoints web              # 세 주소가 등록돼 있다
kubectl scale deployment web --replicas=1
```

### 5-4 🐧 ⭐ 파일이 정석이다

```bash
nano ~/k8s/deployment.yaml             # replicas: 3
kubectl apply -f ~/k8s/deployment.yaml
```

> 🗣 **"`scale` 로 바꾼 건 파일에 안 남습니다. 13일차 그 교훈이죠 — 고치는 곳은 하나."**

---

# ▶ STEP 6 · 🅰️ API 로 들여다보기 (25분) — [6_API로_들여다보기](lesson-6.md)

> ⚖️ **STEP 7 과 택1.** 시간이 남고 반이 따라올 때 이쪽.

### 6-1 🐧 ⭐ kubectl 이 무엇을 보내나

```bash
kubectl get pods -v=6
```

> 🗣 **"`GET`, 주소, `200 OK`. 10일차에 배운 그 HTTP 입니다."**

### 6-2 🐧 **터미널 A** — 통로를 연다

```bash
kubectl proxy
```

### 6-3 🐧 **터미널 B** — curl 과 jq

```bash
curl -s http://127.0.0.1:8001/api/v1/namespaces/default/pods | jq '.items[].metadata.name'
curl -s http://127.0.0.1:8001/api/v1/namespaces/default/pods \
  | jq -r '.items[] | "\(.metadata.name)  \(.status.phase)"'
curl -s http://127.0.0.1:8001/api/v1/nodes | jq -r '.items[].metadata.name'
```

### 6-4 🚨 정리

```
터미널 A 에서  Ctrl + C      ← 인증 없이 열린 통로다. 반드시 끈다
```

---

# ▶ STEP 7 · 🅱️ 더 들어가기 (25분) — [7_더_들어가기](lesson-7.md)

> ⚖️ **STEP 6 과 택1.** 설치가 늦어졌거나 반이 벅차할 때 이쪽. **새 개념 없이 오늘 것을 굳힌다.**

### 7-1 🐧 라벨

```bash
kubectl get pods --show-labels
kubectl get pods -l app=web
kubectl label pod <내 Pod 이름> app=other --overwrite
kubectl get pods                       # ⭐ 하나 더 생긴다
kubectl delete pod -l app=other        # 정리
```

### 7-2 🐧 들여다보는 셋

```bash
kubectl logs -l app=web --tail=20
kubectl describe pod <내 Pod 이름>      # ⭐⭐ 맨 아래 Events
kubectl exec -it <내 Pod 이름> -- sh    # ⚠️ -- 를 빠뜨리지 않는다
```

### 7-3 🐧 좁혀 가는 순서 (칠판)

```
① get pods → ② describe(Events) → ③ logs → ④ get svc,endpoints
```

---

# ▶ STEP 8 · 오늘의 문제 (20분) — [8_오늘의_문제](lesson-8.md)

> ⭐ **Q1(명령형/선언형) · Q7(지워도 돌아온다)** 은 한 쌍이다. 반드시 같이 짚는다.
> 📌 끝맺음 — **"오늘 우리는 컨테이너를 띄운 게 아니라, 띄워진 상태를 적어 뒀습니다."**

---

# 🧹 수업 끝 · 정리

```bash
# 클러스터는 남겨 둔다 — 16일차에 그대로 쓴다
kubectl get nodes

# 켜 둔 것만 끈다
#   port-forward · kubectl proxy  → Ctrl + C
```

> 🚨 **다음 시간 준비물** — 14일차 저장소(`Dockerfile`·`compose.yaml`)와 오늘의 `k8s/` 폴더를 **`push` 해 둘 것**
