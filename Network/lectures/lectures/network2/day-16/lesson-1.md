# 1. 내 이미지를 클러스터로 — 레지스트리 없이 ⭐⭐

> 상위: [16일차 · 쿠버네티스로 배포하기](README.md) · 대본 [STEP 1](commands.md)

## 🎯 학습 목표

- 클러스터가 이미지를 **어디서 찾는지** 안다 ⭐
- 내가 구운 이미지를 **레지스트리 없이** 클러스터에 넣는다 ⭐⭐
- 🚨 `kind load docker-image` 가 **실패할 때**의 원인과 대안을 안다
- **`imagePullPolicy`** 와 **태그를 고정해야 하는 이유**를 설명한다 ⭐

## 🌉 다리 놓기: 15일차에 띄운 건 남의 것이었다

```bash
kubectl create deployment web --image=nginx
```

`nginx` 는 **Docker Hub 에 있는** 이미지다. 클러스터가 인터넷에서 받아 왔다.

그런데 14일차에 우리가 구운 이미지는 어디에 있나?

```bash
docker images | grep mysite
# mysite   1.0   a1b2c3d4   2 days ago   48MB
```

> 🗣 **"내 WSL 의 Docker 안에만 있습니다. 클러스터는 이걸 모릅니다."**

---

## 📖 ① 클러스터는 이미지를 어디서 찾나

```
   Pod 를 만들라고 하면
        │
        ▼
   노드에 그 이미지가 있나?  ──있다──▶  그걸 쓴다
        │ 없다
        ▼
   레지스트리에서 받는다 (Docker Hub 등)  ──못 받으면──▶  ErrImagePull
```

> 📌 **노드가 본다.** 내 WSL 의 Docker 가 아니라 **kind 노드 컨테이너 안의** 이미지 목록을 본다.
> 💡 15일차에 배운 것 — 노드는 **컨테이너 한 개**다. 그 안은 내 Docker 와 **별개의 공간**이다.

**방법은 둘이다.**

| 방법 | 어떻게 | 언제 |
|------|--------|------|
| **레지스트리에 올린다** | `docker push` → Docker Hub | 실무의 정석. 계정과 공개 설정이 필요 |
| **노드에 직접 넣는다** ⭐ | **`kind load`** | 수업·개발용. **계정이 필요 없다** |

> 🗣 **"오늘은 아래쪽으로 갑니다. 14일차에 Docker Hub 계정을 안 만들었으니까요."**

---

## 📖 ② 넣는다 — 그리고 🚨 실패할 수 있다

교과서적인 명령은 이것이다.

```bash
kind load docker-image mysite:1.0 --name student
```

**그런데 이렇게 끝날 수 있다.**

```
ERROR: failed to load image: ... ctr: content digest sha256:...: not found
```

> 🚨 **원인은 14일차에 깔린 Docker 29 다.** Docker Engine 29 부터 **새로 설치하면 이미지 저장 방식(containerd 이미지 저장소)이 기본**으로 바뀌었다. `kind load docker-image` 가 아직 그 방식에서 이미지를 꺼내지 못하는 경우가 있다.

### ⭐ 대안 — 파일로 떠서 넣는다 (이 길로 간다)

```bash
docker image save --platform linux/amd64 -o /tmp/mysite.tar mysite:1.0
kind load image-archive /tmp/mysite.tar --name student
```

```bash
# ④ 확인 — 노드 안에 들어갔나
docker exec -it student-control-plane crictl images | grep mysite
```

> 💡 **`save` 는 이미지를 하나의 파일(tar)로 뜨는 것**이다. 12일차에 `scp` 로 파일을 옮기던 감각 그대로다. **떠서(save) → 넣는다(load)**.
> 📌 `--platform linux/amd64` 는 **어느 CPU 용 이미지인지**를 못 박는 것이다. 빼면 여러 개가 섞여 같은 오류가 날 수 있다.

> 🗣 **"교과서에 한 줄로 적힌 게 안 될 때가 있습니다. 그때 왜 안 되는지 알면, 두 줄로 돌아갈 수 있습니다."**

---

## 📖 ③ 띄운다 — 그리고 🚨 `ErrImagePull`

```bash
kubectl create deployment mysite --image=mysite:1.0
kubectl get pods
```

```
NAME                      READY   STATUS             RESTARTS   AGE
mysite-7c9d8f6b5-2xk4p    0/1     ErrImagePull       0          15s
```

**노드에 넣었는데도 못 찾는다?** `describe` 로 본다 (15일차 B안에서 배운 그 자리).

```bash
kubectl describe pod <Pod 이름> | tail -15
```

```
  Warning  Failed  ...  Failed to pull image "mysite:1.0": ...
```

### 원인 — 태그와 `imagePullPolicy` ⭐

| 이미지 태그 | 기본 `imagePullPolicy` | 결과 |
|-------------|------------------------|------|
| `mysite:1.0` (고정 태그) | **`IfNotPresent`** | 노드에 있으면 **그걸 쓴다** ○ |
| `mysite:latest` 또는 태그 없음 | **`Always`** | **매번 밖에서 받으려 한다** → 실패 × |

> 🚨 **`latest` 를 쓰면 안 되는 이유가 여기서 나온다.** "항상 최신을 받아라"로 해석되어, **로컬에 있어도 무시하고 레지스트리를 찾는다.**
> ⭐ 14일차에 **`mysite:1.0` 처럼 태그를 올려 쓰라**고 한 이유가 오늘 증명된다.

**매니페스트로 못 박으면 확실하다.**

```yaml
      containers:
      - name: mysite
        image: mysite:1.0
        imagePullPolicy: IfNotPresent     # ⭐ 노드에 있으면 그걸 쓴다
        ports:
        - containerPort: 80
```

```bash
kubectl apply -f k8s/deployment.yaml
kubectl get pods            # Running ⭐
```

---

## 📖 ④ 확인한다

```bash
kubectl port-forward deployment/mysite 8080:80
```

```
🪟 http://localhost:8080   →  13일차에 만든 내 포트폴리오 ⭐
```

> 🗣 **"13일차에 만든 코드가, 14일차에 구운 이미지가 되어, 15일차에 세운 클러스터에서 돕니다."**

```
 13일차   코드를 Git 에
 14일차   + 돌리는 방법 (Dockerfile)   → 이미지로 구웠다
 15일차   + 원하는 상태 (매니페스트)    → 클러스터를 세웠다
 16일차   그 이미지를 그 클러스터에       ⭐ 오늘
```

---

## 📖 ⑤ 🔧 14일차 이미지가 없는 사람 (복구 경로)

WSL 을 지웠거나 14일차를 못 따라왔다면 **저장소에서 다시 굽는다.**

```bash
cd ~ && git clone https://github.com/<내 아이디>/myweb.git && cd myweb
docker build -t mysite:1.0 .
docker images | grep mysite
```

> ⭐ **이게 14일차에 증명하려던 바로 그것이다.** 저장소만 있으면 **어느 PC 에서든 같은 이미지가 나온다.**
> 📌 14일차 〈연습 3〉을 집에서 해본 사람은 이미 해 본 길이다.

---

## 🧪 실습 / 질문

- `kind load` 를 하지 않고 바로 `kubectl create deployment` 를 하면 어떤 STATUS 가 뜨나?
- `mysite:1.0` 대신 `mysite:latest` 로 태그를 달면 왜 실패하나?
- `docker images` 에는 보이는데 클러스터는 못 찾는다. 두 목록이 다른 이유는?
- 실무에서는 왜 `kind load` 가 아니라 레지스트리를 쓸까?
- `docker image save` 로 뜬 `.tar` 를 USB 에 담아 가면 인터넷 없는 PC 에서도 쓸 수 있을까?

## 📝 강의 메모

- ⭐⭐ **오늘의 승부처다.** 여기서 막히면 3번 절까지 전부 밀린다
- 🚨 **`kind load docker-image` 가 실패할 수 있다는 걸 먼저 말하고 들어간다.** 실패를 보고 당황하는 것보다, **"이렇게 될 수 있다"** 를 듣고 만나는 게 낫다
  - 👉 대본은 **처음부터 `save` + `image-archive`** 로 간다. `docker-image` 는 "짧은 길인데 될 때도 있다" 로 소개
- ⭐ **`ErrImagePull` 을 일부러 한 번 만든다** — `latest` 태그로. 그래야 `imagePullPolicy` 가 머리에 남는다
  - 10 · 12 · 13 · 14일차 포트 충돌처럼, **일부러 내는 에러**가 가장 잘 남는다
- ⚠️ `crictl images` 출력이 길다 → `| grep mysite` 로 자른다
- ⚠️ ⑤ 복구 경로는 **STEP 0 에서 미리** 돌려 둔다. 1번 절에 와서 시작하면 늦는다
- ⏱ 35분 (이론 10 + 실습 25)
