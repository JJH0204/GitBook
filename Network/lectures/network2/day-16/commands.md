# 0. 16일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [16일차 · 쿠버네티스로 배포하기](README.md)
> 📌 `🐧` = WSL 안 · `🪟` = Windows 브라우저
> 🚨 **Pod 이름은 각자 다르다.** `kubectl get pods` 로 확인해서 쓴다
> 🚨 **터미널 두 개**를 띄워 둔다

---

# ▶ STEP 0 · 몸풀기 + 클러스터 다시 만들기 (15분)

### 0-1 🐧 점검

```bash
stat -fc %T /sys/fs/cgroup         # 🚨 cgroup2fs (15일차와 같은 점검)
ps -p 1 -o comm=
docker info --format '{{.ServerVersion}}'
kind get clusters
docker images | grep mysite        # ⭐ 14일차 이미지가 있나
```

### 0-2 🐧 ⭐ 이미지가 없는 사람 — 지금 다시 굽는다

```bash
cd ~ && git clone https://github.com/<내 아이디>/myweb.git 2>/dev/null; cd ~/myweb
docker build -t mysite:1.0 .
docker images | grep mysite
```

> ⭐ 저장소만 있으면 어느 PC 에서든 같은 이미지가 나온다 — 14일차에 증명하려던 그것이다.

### 0-3 🐧 🚨 클러스터를 **설정 파일로** 다시 만든다

```bash
cat > ~/kind-config.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
EOF

kind delete cluster --name student          # 🛑 15일차 것은 포트 구멍이 없다
kind create cluster --name student --config ~/kind-config.yaml
docker ps                                   # ⭐ 0.0.0.0:8080->30080 이 보인다
kubectl get nodes
```

> 🗣 **"클러스터도 파일로 적어 다시 만듭니다. 어제 배운 선언형이 클러스터 자체에도 적용됩니다."**
> ⏱ 두 번째라 **1~2분**이면 된다.

---

# ▶ STEP 1 · 내 이미지를 클러스터로 (35분) — [1_내_이미지를_클러스터로](lesson-1.md) ⭐⭐

> 🗣 **도입** — "15일차에 띄운 건 남의 nginx 였습니다. 오늘은 여러분 것을 올립니다."
> 칠판 — **노드가 보는 이미지 목록 ≠ 내 Docker 의 목록**

### 1-1 🐧 ⭐ 파일로 떠서 넣는다 (이 길로 간다)

```bash
docker image save --platform linux/amd64 -o /tmp/mysite.tar mysite:1.0
kind load image-archive /tmp/mysite.tar --name student
docker exec -it student-control-plane crictl images | grep mysite    # ④ 확인
```

> 🚨 **짧은 길(`kind load docker-image mysite:1.0 --name student`)도 있다.** 될 때도 있지만 **Docker 29 에서 실패할 수 있다**(`ctr: content digest ... not found`). 그래서 처음부터 위 두 줄로 간다.

### 1-2 🐧 🚨 일부러 틀려 본다 — `ErrImagePull`

```bash
kubectl create deployment bad --image=mysite:latest
kubectl get pods
kubectl describe pod -l app=bad | tail -8
kubectl delete deployment bad
```

> 🗣 **"`latest` 라서 밖에서 받으려 한 겁니다. 14일차에 태그를 올리라고 한 이유가 이겁니다."**

### 1-3 🐧 매니페스트로 띄운다

```bash
mkdir -p ~/myweb/k8s && cd ~/myweb/k8s
nano deployment.yaml        # image: mysite:1.0 · imagePullPolicy: IfNotPresent
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment.yaml
kubectl get pods            # Running ⭐
```

### 1-4 🐧🪟 확인

```bash
kubectl port-forward deployment/mysite 8080:80
```

```
🪟 http://localhost:8080   →  13일차에 만든 내 포트폴리오 ⭐
```

> 🗣 **"13일차 코드가, 14일차 이미지가 되어, 15일차 클러스터에서 돕니다."** → `Ctrl+C`

---

# ▶ STEP 2 · ConfigMap 과 Secret (30분) — [2_설정과_비밀](lesson-2.md) ⭐

### 2-1 🐧 만든다

```bash
kubectl create configmap site-config \
  --from-literal=SITE_TITLE="코리아IT 네트워크 2" --from-literal=SITE_ENV=class

kubectl create secret generic db-secret --from-literal=DB_PASSWORD='example-password'
```

### 2-2 🐧 ⭐⭐ base64 는 암호가 아니다 — **전원이 직접 친다**

```bash
kubectl get secret db-secret -o yaml | grep DB_PASSWORD
echo 'ZXhhbXBsZS1wYXNzd29yZA==' | base64 -d        # ⚠️ 각자 출력된 값으로
```

> 🗣 **"풀렸습니다. Secret 이라는 이름에 속으면 안 됩니다."**
> 칠판 — 13일차 Q3 을 다시 띄운다: **비밀은 지워도 이력에 남는다**

### 2-3 🐧 Pod 에 넣는다

```bash
nano ~/myweb/k8s/deployment.yaml      # envFrom 추가
kubectl apply -f ~/myweb/k8s/deployment.yaml
kubectl exec -it $(kubectl get pod -l app=mysite -o name | head -1) -- env | grep -E 'SITE_|DB_'
```

---

# ▶ STEP 3 · 밖으로 여는 법 (45분) — [3_밖으로_여는_법](lesson-3.md) ⭐⭐

> 🗣 **도입** — 칠판에 **세 단계**부터 그린다
> `ClusterIP`(안만) → **`NodePort`**(밖) → **`Ingress`**(이름으로 나눠)
> 그리고 14일차 대응: `-p` 없음 → `127.0.0.1:` → `-p 8080:80` → 리버스 프록시

### 3-1 🐧 NodePort 로 연다

```bash
nano ~/myweb/k8s/service.yaml       # type: NodePort · nodePort: 30080
kubectl apply -f ~/myweb/k8s/service.yaml
kubectl get svc mysite
curl http://localhost:8080          # ⭐ port-forward 없이 열린다
```

```
🪟 http://localhost:8080
```

> ⭐ **터미널을 점유하지 않는다.** 이게 진짜로 연 것이다.
> 칠판 — 번호 네 개: `port` · `targetPort` · `nodePort` · `hostPort`

### 3-2 🐧 🚨 열린 문을 센다 (11일차 회수)

```bash
kubectl get svc
sudo ss -tulnp | grep 8080
```

> 🗣 **"문이 몇 개죠? DB 를 올린다면 그건 어떤 타입이어야 할까요?"**

### 3-3 🎬 Ingress — **강사 시연 · 개념까지만**

```
 밖 ── :80 ──▶ [ Ingress ]  /        → 포트폴리오
                            /board   → 게시판
```

> ⚠️ **컨트롤러 설치까지 가지 않는다.** 마지막 날을 못 끝낸다. **매니페스트를 보여주고 그림으로 설명**하고 넘어간다.
> ⭐ 12일차 `squid`(포워드 프록시)의 **방향을 뒤집은 것**이 리버스 프록시임을 짚는다.

---

# ▶ STEP 4 · 롤링 업데이트와 롤백 (30분) — [4_고치고_되돌리기](lesson-4.md) ⭐

### 4-0 🐧 그림이 깨끗하게 나오도록

```bash
kubectl scale deployment mysite --replicas=2
```

### 4-1 🐧 고쳐서 다시 굽는다

```bash
cd ~/myweb && nano site/index.html
docker build -t mysite:1.1 .
docker image save --platform linux/amd64 -o /tmp/mysite-1.1.tar mysite:1.1
kind load image-archive /tmp/mysite-1.1.tar --name student
```

### 4-2 🐧 **터미널 A** — 지켜본다

```bash
kubectl get pods -w
```

### 4-3 🐧 **터미널 B** — 바꾼다

```bash
kubectl set image deployment/mysite mysite=mysite:1.1
kubectl rollout status deployment/mysite
curl http://localhost:8080
```

> ⭐⭐ **터미널 A 의 순서를 손가락으로 짚는다** — 새 Pod 가 `Running` 이 된 **뒤에** 옛 Pod 가 `Terminating`.
> 🗣 **"교대 근무입니다. 다음 사람이 앉은 뒤에 앞사람이 퇴근하죠."**

### 4-4 🐧 되돌린다

```bash
kubectl rollout history deployment/mysite
kubectl rollout undo deployment/mysite
kubectl rollout status deployment/mysite
curl http://localhost:8080             # 1.0 으로 돌아왔다 ⭐
```

### 4-5 🐧 Git 에 적어 둔다

```bash
cd ~/myweb && git add k8s/ && git commit -m "쿠버네티스 배포 매니페스트" && git push
```

---

# ▶ STEP 5 · 16일 되짚기 (25분) — [5_16일_되짚기](lesson-5.md)

> ⏱ **이 25분은 반드시 지킨다.** 4번 절을 줄여서라도.
>
> 1. **1일차 노트를 실제로 띄운다** — "네트워크란 무엇인가"
> 2. 칠판에 **16일 지도**
> 3. ⭐⭐ **다섯 가지를 번호로 먼저 적고** 학생에게 사례를 묻는다
>    ① 여섯 단계 ② 열지 않은 것은 닫혀 있다 ③ 되돌릴 수 있게 ④ 기억 말고 적어 두기 ⑤ 한 포트에 한 프로그램
> 4. **③ 할 수 있게 된 일**은 학생이 직접 말하게 한다
> 5. ④ 다음 공부거리 — 자격증 · 클라우드 · 자동화 · **정보보안 과정**
> 6. 🗣 **마지막 한 줄**은 읽지 말고 말한다. 짧게, 한 번만

---

# ▶ STEP 6 · 오늘의 문제 (20분) — [6_오늘의_문제](lesson-6.md)

> ⭐ **Q8 이 마지막 문제다.** 답보다 **학생이 네 날을 스스로 꿰는 것**이 목적이다.

---

# 🧹 수업 끝 · 정리

```bash
# 결과물 확인 — 이력서에 적을 것 셋
#   ① GitHub 저장소  ② GitHub Pages 주소  ③ Dockerfile + 매니페스트가 든 저장소
cd ~/myweb && git log --oneline | head -10
ls k8s/

# 클러스터를 지우려면 (집에서 다시 해보려면 남겨 둔다)
# kind delete cluster --name student        # 🛑 3초 멈춤
```

> 🗣 **"오늘 만든 저장소는 지우지 마세요. 그게 16일의 증거입니다."**
