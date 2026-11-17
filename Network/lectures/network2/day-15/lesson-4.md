# 4. 선언형 — 매니페스트와 apply

> 상위: [15일차 · 쿠버네티스 입문](README.md) · 대본 [STEP 4](commands.md)

## 🎯 학습 목표

- 3번 절에서 **명령으로 만든 것**을 **파일로 적는다**
- **매니페스트(YAML)** 의 네 줄 머리(`apiVersion`·`kind`·`metadata`·`spec`)를 읽는다
- **`kubectl apply -f`** 로 적용하고, 같은 파일을 **여러 번 적용해도 안전**한 것을 확인한다
- 14일차 `compose.yaml` 과 **나란히 놓고** 비교한다 ⭐
- 매니페스트를 **Git 저장소에 넣는다** (13·14일차의 그 자리) ⭐

## 🌉 다리 놓기: "그래서 이걸 어떻게 전달하죠?"

14일차에 똑같은 질문을 했다.

> 🗣 **"`docker run` 명령을 옆자리에 어떻게 전달하죠? 카톡으로요?"**

그때의 답은 **`compose.yaml`** 이었다. 오늘도 답은 같다. **명령을 파일로 적는다.**

```
 13일차:  Git = 코드
 14일차:  Git = 코드 + 돌리는 방법 (Dockerfile · compose.yaml)
 15일차:  Git = 코드 + 돌리는 방법 + 원하는 상태 (매니페스트)  ⭐
```

---

## 📖 ① 지금 만든 것을 파일로 꺼내 본다

```bash
kubectl get deployment web -o yaml | head -20
```

쏟아져 나온다. **쿠버네티스가 채워 넣은 기본값과 현재 상태까지** 전부 들어 있기 때문이다.

> 📌 **이걸 그대로 쓰지 않는다.** 우리가 적을 것은 **"원하는 것"** 뿐이고, 나머지는 쿠버네티스가 채운다.
> 💡 14일차 `docker inspect` 가 쏟아내던 것과 같은 느낌이다. 읽는 용도지 쓰는 용도가 아니다.

---

## 📖 ② 매니페스트는 네 줄로 시작한다

```yaml
apiVersion: apps/v1     # 이 문서의 규격 버전
kind: Deployment        # 무엇을 만들 것인가
metadata:               # 이름표
  name: web
spec:                   # 원하는 상태
  ...
```

| 줄 | 뜻 | 빠뜨리면 |
|----|-----|----------|
| `apiVersion` | 이 종류의 **규격 버전** | `no matches for kind ...` |
| `kind` | **무엇**을 만드는가 (`Deployment`·`Service`·`Pod`…) | 같은 에러 |
| `metadata.name` | **이름** | 이름 없이는 못 만든다 |
| `spec` | **원하는 상태** (핵심) | 빈 껍데기가 생긴다 |

> ⚠️ **`kind` 는 종류를 뜻하는 쿠버네티스 용어다.** 우리가 쓰는 도구 `kind` 와 **글자만 같고 아무 상관이 없다.** 오늘 가장 헷갈리는 지점이니 칠판에 적어 둔다.

---

## 📖 ③ 직접 적어 본다

```bash
mkdir -p ~/k8s && cd ~/k8s
nano deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web          # ← 이 라벨이 붙은 Pod 를 내 것으로 본다
  template:             # ← 여기서부터가 "Pod 를 어떻게 만들지"
    metadata:
      labels:
        app: web        # ← 만들 Pod 에 붙일 라벨 (위와 같아야 한다)
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

> ⭐ **`selector.matchLabels` 와 `template.metadata.labels` 는 같아야 한다.** Deployment 가 "내가 관리할 Pod"를 찾는 방법이 **라벨**이기 때문이다. 다르면 Pod 가 생겼다 사라졌다 한다.
> 💡 **비유**: 근무 규정에 **"파란 조끼를 입은 사람이 내 직원"** 이라고 적어 두고, 새로 뽑는 직원에게 **파란 조끼**를 입히는 것이다. 두 색이 다르면 자기 직원을 못 알아본다.

```bash
nano service.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web            # ← 이 라벨의 Pod 들에게 보낸다
  ports:
  - port: 80
    targetPort: 80
```

> 📌 **`port` 는 Service 가 받는 번호, `targetPort` 는 Pod 가 듣는 번호다.** 14일차 `-p 8080:80` 의 **왼쪽/오른쪽**과 같은 감각이다.

---

## 📖 ④ 적용한다 — `apply`

```bash
kubectl apply -f deployment.yaml --dry-run=client    # 먼저 문법 검사 ⭐
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get deploy,svc,pods
```

> ⭐ **`--dry-run=client` 를 먼저 치는 습관.** 12일차 `nginx -t`, 14일차 `docker compose config` 와 **같은 자리**다. YAML 은 들여쓰기가 문법이라 이 한 줄이 사고를 막는다.
> ⚠️ **다만 완전한 오프라인 검사는 아니다.** `--dry-run=client` 도 **클러스터에 한 번 물어본다**(어떤 종류가 있는지 확인하려고). 클러스터가 죽어 있으면 `connection refused` 가 뜬다 — **문법이 틀린 게 아니다.** 실측으로 확인했다.

```bash
kubectl apply -f .          # 폴더 안 전부
```

### 여러 번 적용해도 괜찮다 ⭐

```bash
kubectl apply -f deployment.yaml
kubectl apply -f deployment.yaml      # 또 쳐도 안전하다
```

```
deployment.apps/web unchanged
```

> ⭐ **이것이 선언형이다.** "만들어라"가 아니라 **"이 상태여야 한다"** 이므로, 이미 그 상태면 **아무 일도 하지 않는다.**
> 📌 14일차 `docker run` 을 두 번 치면 **이름 충돌**이 났다. `apply` 는 그렇지 않다.

**고칠 때도 같은 파일을 고쳐서 다시 `apply`** 한다.

```bash
nano deployment.yaml        # replicas: 1 → 3
kubectl apply -f deployment.yaml
kubectl get pods            # 3개가 되어 있다
```

---

## 📖 ⑤ 14일차 Compose 와 나란히 ⭐

| 하고 싶은 일 | `compose.yaml` | 쿠버네티스 매니페스트 |
|--------------|----------------|------------------------|
| 무엇을 띄울까 | `services:` 아래 이름 | **`kind: Deployment`** + `metadata.name` |
| 어떤 이미지 | `image: nginx` | `spec.template.spec.containers[].image` |
| 몇 개 | *(없음)* | **`spec.replicas`** ⭐ |
| 포트 | `ports: ["8080:80"]` | `containerPort` + **Service** 가 따로 |
| 환경 변수 | `environment:` | `env:` *(16일차 ConfigMap·Secret)* |
| 볼륨 | `volumes:` | `volumes` + `volumeMounts` |
| 재시작 | `restart: unless-stopped` | **기본이 그렇다** (적을 필요가 없다) ⭐ |
| 올리기 | `docker compose up -d` | **`kubectl apply -f .`** |
| 내리기 | `docker compose down` | **`kubectl delete -f .`** |

> ⭐ **`restart` 가 사라진 것**이 오늘의 요점이다. Compose 에서는 "죽으면 켜라"를 **적어야** 했지만, 쿠버네티스는 **원래 그렇게 동작한다.**
> ⚠️ **대신 파일이 길어졌다.** Compose 10줄이 매니페스트 25줄이 된다. 이게 쿠버네티스의 값이다.

---

## 📖 ⑥ Git 에 넣는다 — 13 · 14일차 그 자리 ⭐

```bash
cd ~/myweb                       # 14일차 저장소
mkdir -p k8s
cp ~/k8s/*.yaml k8s/
git add k8s/
git commit -m "쿠버네티스 매니페스트 추가"
git push
```

```
 13일차:  내 코드
 14일차:  + Dockerfile · compose.yaml  (한 대에서 돌리는 방법)
 15일차:  + k8s/*.yaml                 (클러스터에서 원하는 상태)  ⭐
```

> 🗣 **"오늘도 결론은 같습니다. 기억하지 말고 저장소에 적어 둡니다."**
> 📌 **16일차에 이 폴더를 그대로 쓴다.**

---

## 🧪 실습 / 질문

- `selector.matchLabels` 와 `template.metadata.labels` 를 **일부러 다르게** 해서 `apply` 하면 어떻게 되나?
- `kubectl apply` 를 세 번 연속 쳤다. 두 번째·세 번째 출력은 무엇인가? 왜 그런가?
- Compose 의 `restart: unless-stopped` 에 해당하는 줄이 매니페스트에 없다. 왜 없어도 되나?
- `kubectl delete -f service.yaml` 만 하면 Pod 는 어떻게 되나?
- 쿠버네티스의 `kind` 와 도구 `kind` 는 무엇이 다른가?

## 📝 강의 메모

- ⚠️ **`kind` 혼동을 먼저 못 박는다.** 칠판 한구석에 `kind:` = 종류 / `kind` = 도구 를 적어 두고 시작
- ⭐ **라벨 짝 맞추기**가 1번 사고다. 두 `app: web` 을 **형광펜으로 같은 색** 표시해 보여줄 것
- ⭐⭐ **같은 파일을 두 번 `apply` 하는 장면**을 꼭 보여준다 — `unchanged` 한 줄이 선언형의 증거다
- ⚠️ YAML 을 처음부터 타이핑시키면 시간을 다 먹는다 → **강사가 파일을 공유**하고 학생은 **고쳐 쓰는** 방식 권장
  - 시간이 모자라면 ③을 **읽기만** 하고 ④부터 따라 치게 한다
- 📌 ⑤ 대응표는 14일차 Compose 노트를 **옆에 띄워 놓고** 짚는다
- ⏱ 30분 (이론 10 + 실습 20)
