# 0. 16일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)

> 상위: [16일차 · 쿠버네티스로 배포하고 공개하기](README.md) · 절차는 [클러스터 재생성 실습](lesson-0-lab.md), [내 이미지 올리기 실습](lesson-1-lab.md), [ConfigMap과 Secret 실습](lesson-2-lab.md), [NodePort 공개 실습](lesson-3-lab.md), [롤링 업데이트와 롤백 실습](lesson-4-lab.md)

## 문서 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-16-007-REF |
| 유형 | REF (명령어 대본, 표) |
| 목적 | 16일차 실습 명령을 수업 흐름 순서대로 모아, 실습 중 화면에 띄우거나 인쇄해 따라 치게 한다 |
| 확인 상태 | 미검증 (원본 명령 대본을 정리한 것이며 이번 재작성에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 읽는 법

- `[WSL]`은 WSL 터미널, `[브라우저]`는 Windows 브라우저이다.
- `#` 뒤의 글은 설명이다. 안 쳐도 된다.
- `<꺾쇠>`는 본인 값으로 바꾼다.
- Pod 이름은 사람마다 다르다. `kubectl get pods`로 확인해서 쓴다.
- 터미널을 두 개 띄워 둔다.

---

## STEP 0. 몸풀기와 클러스터 다시 만들기 (15분) — [클러스터 재생성 실습](lesson-0-lab.md)

### 0-1 [WSL] 점검

```bash
stat -fc %T /sys/fs/cgroup         # cgroup2fs (15일차와 같은 점검)
ps -p 1 -o comm=
docker info --format '{{.ServerVersion}}'
kind get clusters
docker images | grep mysite        # 14일차 이미지가 있나
```

### 0-2 [WSL] 이미지가 없는 사람은 지금 다시 굽는다

```bash
cd ~ && git clone https://github.com/<내 아이디>/myweb.git 2>/dev/null; cd ~/myweb
docker build -t mysite:1.0 .
docker images | grep mysite
```

저장소만 있으면 어느 PC에서든 같은 이미지가 나온다. 14일차에 증명하려던 그것이다.

### 0-3 [WSL] 클러스터를 설정 파일로 다시 만든다

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

kind delete cluster --name student          # 15일차 것은 포트 구멍이 없다
kind create cluster --name student --config ~/kind-config.yaml
docker ps                                   # 0.0.0.0:8080->30080이 보인다
kubectl get nodes
```

{% hint style="danger" %}
WARNING: `kind delete cluster`는 3초 멈추고 실행한다. 클러스터와 안의 것이 전부 사라진다.
{% endhint %}

- 도입 질문: "클러스터도 파일로 적어 다시 만든다. 어제 배운 선언형이 클러스터 자체에도 적용된다."
- 두 번째라 1~2분이면 된다.

---

## STEP 1. 내 이미지를 클러스터로 (35분) — [내 이미지 올리기 실습](lesson-1-lab.md), 개념 [1. 내 이미지를 클러스터로](lesson-1.md)

- 도입: "15일차에 띄운 것은 남의 nginx였다. 오늘은 여러분 것을 올린다."
- 칠판: 노드가 보는 이미지 목록은 내 Docker의 목록과 다르다.

### 1-1 [WSL] 파일로 떠서 넣는다

```bash
docker image save --platform linux/amd64 -o /tmp/mysite.tar mysite:1.0
kind load image-archive /tmp/mysite.tar --name student
docker exec student-control-plane crictl images | grep mysite    # 확인
```

{% hint style="warning" %}
CAUTION: 짧은 길(`kind load docker-image mysite:1.0 --name student`)도 있다. 될 때도 있지만 Docker 29에서 실패할 수 있다(`ctr: content digest ... not found`). 그래서 처음부터 위 두 줄로 간다.
{% endhint %}

### 1-2 [WSL] 일부러 틀려 본다: `ErrImagePull`

```bash
kubectl create deployment bad --image=mysite:latest
kubectl get pods
kubectl describe pod -l app=bad | tail -8
kubectl delete deployment bad
```

설명: `latest`라서 밖에서 받으려 한 것이다. 14일차에 태그를 올리라고 한 이유이다.

### 1-3 [WSL] 매니페스트로 띄운다

```bash
mkdir -p ~/myweb/k8s && cd ~/myweb/k8s
nano deployment.yaml        # image: mysite:1.0, imagePullPolicy: IfNotPresent
kubectl apply -f deployment.yaml --dry-run=client
kubectl apply -f deployment.yaml
kubectl get pods            # Running
```

### 1-4 [WSL][브라우저] 확인

```bash
kubectl port-forward deployment/mysite 8081:80
```

```
[브라우저] http://localhost:8081   →  13일차에 만든 내 포트폴리오
```

설명: 13일차 코드가, 14일차 이미지가 되어, 15일차 클러스터에서 돈다. 확인 후 `Ctrl+C`로 끝낸다.

{% hint style="info" %}
NOTE: 원본은 `8080:80`이었다. STEP 0에서 호스트 8080을 노드 컨테이너에 연결했으므로 포트 충돌이 날 수 있어 8081로 바꿨다.
{% endhint %}

---

## STEP 2. ConfigMap과 Secret (30분) — [ConfigMap과 Secret 실습](lesson-2-lab.md), 개념 [2. 설정과 비밀](lesson-2.md)

### 2-1 [WSL] 만든다

```bash
kubectl create configmap site-config \
  --from-literal=SITE_TITLE="코리아IT 네트워크 2" --from-literal=SITE_ENV=class

kubectl create secret generic db-secret --from-literal=DB_PASSWORD='<password>'
```

### 2-2 [WSL] base64는 암호가 아니다. 전원이 직접 친다

```bash
kubectl get secret db-secret -o yaml | grep DB_PASSWORD
echo '<base64 문자열>' | base64 -d        # 각자 출력된 값으로
```

- 설명: 풀렸다. Secret이라는 이름에 속으면 안 된다.
- 칠판: 13일차 Q3을 다시 띄운다. 비밀은 지워도 이력에 남는다.

### 2-3 [WSL] Pod에 넣는다

```bash
nano ~/myweb/k8s/deployment.yaml      # envFrom 추가
kubectl apply -f ~/myweb/k8s/deployment.yaml
kubectl exec $(kubectl get pod -l app=mysite -o name | head -1) -- env | grep -E 'SITE_|DB_'
```

---

## STEP 3. 밖으로 여는 법 (45분) — [NodePort 공개 실습](lesson-3-lab.md), 개념 [3. 밖으로 여는 법](lesson-3.md)

- 도입: 칠판에 세 단계부터 그린다. `ClusterIP`(안만), `NodePort`(밖), `Ingress`(이름으로 나눠).
- 14일차 대응: `-p` 없음, `127.0.0.1:`, `-p 8080:80`, 리버스 프록시.

### 3-1 [WSL] NodePort로 연다

```bash
nano ~/myweb/k8s/service.yaml       # type: NodePort, nodePort: 30080
kubectl apply -f ~/myweb/k8s/service.yaml
kubectl get svc mysite
curl http://localhost:8080          # port-forward 없이 열린다
```

```
[브라우저] http://localhost:8080
```

- 터미널을 점유하지 않는다. 이것이 진짜로 연 것이다.
- 칠판: 번호 네 개 `port`, `targetPort`, `nodePort`, `hostPort`.

### 3-2 [WSL] 열린 문을 센다(11일차 회수)

```bash
kubectl get svc
sudo ss -tulnp | grep 8080
```

질문: 문이 몇 개인가? DB를 올린다면 그것은 어떤 타입이어야 하는가?

### 3-3 [강사 시연] Ingress. 개념까지만

```
 밖 ── :80 ──▶ [ Ingress ]  /        → 포트폴리오
                            /board   → 게시판
```

{% hint style="warning" %}
CAUTION: 컨트롤러 설치까지 가지 않는다. 마지막 날을 끝내지 못한다. 매니페스트를 보여 주고 그림으로 설명한 뒤 넘어간다. 12일차 `squid`(포워드 프록시)의 방향을 뒤집은 것이 리버스 프록시임을 짚는다.
{% endhint %}

---

## STEP 4. 롤링 업데이트와 롤백 (30분) — [롤링 업데이트와 롤백 실습](lesson-4-lab.md), 개념 [4. 고치고 되돌리기](lesson-4.md)

### 4-0 [WSL] 그림이 깨끗하게 나오도록

```bash
kubectl scale deployment mysite --replicas=2
```

### 4-1 [WSL] 고쳐서 다시 굽는다

```bash
cd ~/myweb && nano site/index.html
docker build -t mysite:1.1 .
docker image save --platform linux/amd64 -o /tmp/mysite-1.1.tar mysite:1.1
kind load image-archive /tmp/mysite-1.1.tar --name student
```

### 4-2 [WSL] 터미널 A: 지켜본다

```bash
kubectl get pods -w
```

### 4-3 [WSL] 터미널 B: 바꾼다

```bash
kubectl set image deployment/mysite mysite=mysite:1.1
kubectl rollout status deployment/mysite
curl http://localhost:8080
```

터미널 A의 순서를 손가락으로 짚는다. 새 Pod가 `Running`이 된 뒤에 옛 Pod가 `Terminating`이 된다. 교대 근무이다. 다음 사람이 앉은 뒤에 앞사람이 퇴근한다.

### 4-4 [WSL] 되돌린다

```bash
kubectl rollout history deployment/mysite
kubectl rollout undo deployment/mysite
kubectl rollout status deployment/mysite
curl http://localhost:8080             # 1.0으로 돌아왔다
```

### 4-5 [WSL] Git에 적어 둔다

```bash
cd ~/myweb && git add k8s/ && git commit -m "쿠버네티스 배포 매니페스트" && git push
```

---

## STEP 5. 16일 되짚기 (25분) — [5. 16일을 되짚는다](lesson-5.md)

{% hint style="warning" %}
CAUTION: 이 25분은 반드시 지킨다. 4번 절을 줄여서라도 지킨다.
{% endhint %}

1. 1일차 노트를 실제로 띄운다. "네트워크란 무엇인가"를 보여 준다.
2. 칠판에 16일 지도를 그린다.
3. 다섯 가지를 번호로 먼저 적고 학생에게 사례를 묻는다. ① 여섯 단계 ② 열지 않은 것은 닫혀 있다 ③ 되돌릴 수 있게 ④ 기억 말고 적어 두기 ⑤ 한 포트에 한 프로그램.
4. 지금 할 수 있게 된 일은 학생이 직접 말하게 한다.
5. 다음 공부거리(자격증, 클라우드, 자동화, 정보보안 과정)를 안내한다.
6. 마지막 한 줄은 읽지 않고 말한다. 짧게, 한 번만 한다.

---

## STEP 6. 오늘의 문제 (20분) — [6. 오늘의 문제](lesson-6.md)

Q8이 마지막 문제이다. 답보다 학생이 네 날을 스스로 꿰는 것이 목적이다.

---

## 수업 끝: 정리

```bash
# 결과물 확인. 이력서에 적을 것 셋
#   ① GitHub 저장소  ② GitHub Pages 주소  ③ Dockerfile과 매니페스트가 든 저장소
cd ~/myweb && git log --oneline | head -10
ls k8s/

# 클러스터를 지우려면 (집에서 다시 해보려면 남겨 둔다)
# kind delete cluster --name student        # 3초 멈춤
```

오늘 만든 저장소는 지우지 않는다. 그것이 16일의 증거이다.

## 안 될 때 점검표

| 증상 | 원인 | 해결 |
|---|---|---|
| `kind load docker-image`가 `ctr: content digest ... not found`로 실패 | Docker 29의 containerd 이미지 저장소 | `docker image save --platform linux/amd64`와 `kind load image-archive`로 우회한다 |
| Pod가 `ErrImagePull` | 노드에 이미지가 없거나 태그가 `latest`이다 | `crictl images`로 확인하고 고정 태그와 `imagePullPolicy: IfNotPresent`를 쓴다 |
| 이미지가 있는데 클러스터가 못 찾는다 | 노드의 이미지 목록은 내 Docker와 별개이다 | `kind load image-archive`로 노드에 넣는다 |
| `curl http://localhost:8080`이 열리지 않는다 | 클러스터를 포트 매핑 없이 만들었다 | `docker ps`에서 `0.0.0.0:8080->30080`을 확인하고 없으면 STEP 0-3을 다시 한다 |
| `curl`이 열리지 않는다 | `nodePort`와 `kind-config`의 `containerPort`가 다르다 | 두 값을 30080으로 맞춘다 |
| 클러스터를 재생성한 뒤 Pod가 없다 | 클러스터를 지우면 안의 것이 사라진다 | 이미지를 다시 넣고 `kubectl apply -f ~/myweb/k8s/`를 다시 한다 |
| 롤링 업데이트 중 순간 끊김 | `replicas: 1`이다 | `kubectl scale deployment mysite --replicas=2` |
| `rollout undo`가 실패한다 | `mysite:1.0` 이미지를 노드에서 지웠다 | 이미지를 다시 `kind load`한다 |
| `valueFrom` 적용 오류 | 들여쓰기 오타 | `kubectl apply --dry-run=client`로 거른다. 강사 공유 파일을 쓴다 |

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | AMM 형식으로 재작성. 이모지 제거, 실습 절차는 각 MP 문서로 연결, 안 될 때 점검표를 추가했다. `port-forward` 포트를 8081로, 비밀번호 예시를 `<password>`로 바꿨다 |
