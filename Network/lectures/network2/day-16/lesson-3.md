# 3. 밖으로 여는 법 — NodePort 와 Ingress ⭐⭐

> 상위: [16일차 · 쿠버네티스로 배포하기](README.md) · 대본 [STEP 3](commands.md)

## 🎯 학습 목표

- 문을 여는 **세 단계**를 구분한다 — `port-forward` → **NodePort** → **Ingress** ⭐⭐
- kind 클러스터에 **포트 구멍**을 뚫어 다시 만든다
- **NodePort** 로 밖에서 접속한다
- **Ingress** 가 무엇을 푸는지 안다 (12일차 프록시 회수) ⭐
- 11 · 14일차 **최소 개방**이 쿠버네티스에서 어떻게 나타나는지 말한다 ⭐

## 🌉 다리 놓기: 지금까지는 나만 봤다

15일차부터 우리가 쓴 것은 `kubectl port-forward` 였다.

```bash
kubectl port-forward deployment/mysite 8080:80
```

> 🗣 **"이건 제가 터미널을 켜 둔 동안만 열리는 통로입니다. 끄면 닫히죠. 옆자리는 못 봅니다."**

14일차에 **`-p 127.0.0.1:8080:80`** 으로 묶어 뒀던 그 상태다. 오늘은 **제대로 연다.**

---

## 📖 ① 문을 여는 세 단계 ⭐⭐

```
 ① ClusterIP      클러스터 안에서만            ← 기본값. 15일차에 쓴 것
       │          (+ port-forward 로 잠깐 들여다보기)
       ▼
 ② NodePort       노드의 포트를 연다           ← 오늘 실습
       │          밖에서 노드 주소:포트 로 들어온다
       ▼
 ③ Ingress        이름으로 나눠 보내는 한 문    ← 오늘 개념 · 시연
                  하나의 80 번으로 여러 서비스
```

| | 누가 볼 수 있나 | 14일차로 치면 |
|---|---|---|
| **ClusterIP** | 클러스터 안만 | `-p` 를 **안 쓴** 컨테이너 |
| **ClusterIP + port-forward** | 나만, 켜 둔 동안 | **`-p 127.0.0.1:8080:80`** |
| **NodePort** | 밖에서 | **`-p 8080:80`** |
| **Ingress** | 밖에서, **이름으로** | **앞에 세운 리버스 프록시** ⭐ |

> ⭐ **11일차 최소 개방이 그대로 올라왔다.** 쿠버네티스는 **아무것도 안 하면 안 열린다.** 열고 싶으면 **명시해야** 한다.

---

## 📖 ② 🚨 kind 는 포트를 미리 뚫어 둬야 한다

여기서 15일차와 달라진다. 노드가 **Docker 컨테이너**이므로, 그 컨테이너에 **`-p` 가 없으면** 밖에서 못 들어온다.

```bash
docker ps        # 15일차에 만든 노드에는 포트 매핑이 없다
```

> 🗣 **"14일차에 배운 그대로입니다. 컨테이너는 `-p` 없이는 안 열립니다. 노드도 컨테이너니까요."**

**그래서 클러스터를 설정 파일로 다시 만든다.**

```bash
nano ~/kind-config.yaml
```

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080      # 노드 안쪽 (NodePort 번호)
    hostPort: 8080            # 내 WSL 쪽
```

```bash
kind delete cluster --name student          # 🛑 3초 멈춤
kind create cluster --name student --config ~/kind-config.yaml
docker ps                                   # ⭐ 이번엔 0.0.0.0:8080->30080 이 보인다
```

> ⭐ **클러스터도 파일로 적어 다시 만든다.** 15일차 4번 절의 선언형이 **클러스터 자체**에도 적용된 것이다.
> ⚠️ **클러스터를 지웠으니 안의 것이 전부 사라졌다.** 이미지도 다시 넣고 매니페스트도 다시 `apply` 한다 → 1번 절 명령을 **그대로 다시 친다.**
> 📌 그래서 **대본은 STEP 0 에서 이 설정으로 클러스터를 만든다.** 수업에서는 지우고 다시 만들 시간이 없다.

---

## 📖 ③ NodePort 로 연다

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysite
spec:
  type: NodePort             # ⭐ 기본값 ClusterIP 에서 바꾼다
  selector:
    app: mysite
  ports:
  - port: 80                 # Service 가 받는 번호
    targetPort: 80           # Pod 가 듣는 번호
    nodePort: 30080          # ⭐ 노드에 열 번호 (kind-config 와 맞춘다)
```

```bash
kubectl apply -f k8s/service.yaml
kubectl get svc mysite
curl http://localhost:8080          # ⭐ port-forward 없이 열린다
```

```
🪟 http://localhost:8080   →  내 포트폴리오
```

> ⭐ **터미널을 점유하지 않는다.** `port-forward` 를 껐는데도 열려 있다. 이것이 **진짜로 연 것**이다.

| 번호 | 누가 쓰나 |
|------|-----------|
| `port: 80` | 클러스터 안에서 `http://mysite` 로 부를 때 |
| `targetPort: 80` | Pod 안의 nginx 가 듣는 번호 |
| `nodePort: 30080` | **노드 바깥**에서 들어올 때 |
| `hostPort: 8080` (kind-config) | **내 WSL** 에서 들어올 때 |

> ⚠️ **NodePort 는 30000~32767 범위**에서만 고를 수 있다. 80 을 직접 쓸 수 없다.
> 🚨 **그래서 실무에서 NodePort 를 그대로 쓰지 않는다.** 포트 번호가 지저분하고, 서비스가 늘어나면 번호를 외울 수 없다. 그 답이 ④다.

---

## 📖 ④ Ingress — 이름으로 나눠 보내는 한 문 ⭐ (개념 · 시연)

서비스가 셋이 되면 이렇게 된다.

```
  포트폴리오   →  :30080
  게시판       →  :30081
  관리자       →  :30082     ← 번호를 외워야 한다. 문이 세 개다
```

> 🗣 **"문을 세 개 열었습니다. 11일차에 뭐라고 했죠? 문이 많을수록 공격 표면이 넓어집니다."**

**Ingress** 는 **문 하나(80/443)** 를 두고, **주소의 이름이나 경로를 보고** 안에서 나눠 보낸다.

```
                     ┌──────────────────────────┐
  밖 ── :80 ──▶      │  Ingress                 │
                     │  /          → 포트폴리오 │
                     │  /board     → 게시판     │
                     │  admin.***  → 관리자     │
                     └──────────────────────────┘
```

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mysite
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: mysite
            port:
              number: 80
```

> ⭐⭐ **12일차 7번(프록시)이 여기서 회수된다.** 그때는 `squid`(포워드 프록시)를 다뤘고, 방향을 뒤집은 것이 **리버스 프록시**다. Ingress 는 **쿠버네티스가 리버스 프록시를 다루는 방식**이다.
> ⭐ 14일차 3번 절에서 미뤄 둔 **"그럼 제대로 공개하려면?"** 의 답이 이것이다.

> ⚠️ **Ingress 는 규칙일 뿐이다.** 실제로 트래픽을 받아 나눠 주는 **컨트롤러**가 클러스터에 따로 있어야 동작한다. 설치 방법은 쿠버네티스 배포판마다 다르다.
> 📌 **오늘은 개념과 강사 시연까지.** 학생 실습은 **NodePort 로 완결**한다 — 컨트롤러 설치가 또 하나의 병목이 되면 마지막 날을 못 끝낸다.

---

## 📖 ⑤ 🚨 열기 전에 — 11 · 14일차 점검

```bash
kubectl get svc                  # 지금 밖에 열린 문이 몇 개인가
sudo ss -tulnp | grep 8080       # 호스트 쪽에서도 확인
```

| 11일차에 배운 것 | 쿠버네티스에서 |
|------------------|----------------|
| 공격 표면 = `LISTEN` 한 줄 한 줄 | **`type: NodePort` 인 Service 하나하나** |
| 기본 거부 | **기본이 `ClusterIP`** — 안 열려 있다 ⭐ |
| 최소 개방 | **꼭 필요한 것만 NodePort/Ingress** |
| DB 는 밖에 열지 않는다 | **DB Service 는 ClusterIP 로 둔다** ⭐ |

> ⭐ 14일차 Compose 의 결말 — **`ports` 가 없는 db** — 가 쿠버네티스에서는 **`type` 을 안 바꾸는 것**으로 나타난다. 생각이 완전히 같다.
> 🚨 14일차의 **"Docker 가 ufw 를 우회한다"** 도 그대로 유효하다. kind 노드는 컨테이너이므로, **`ufw` 로 막았다고 안심하면 안 된다.**

---

## 🧪 실습 / 질문

- `port-forward` 를 끄고 `curl http://localhost:8080` 을 쳤다. NodePort 전과 후는 어떻게 다른가?
- `kind-config.yaml` 없이 만든 클러스터에서 NodePort 를 쓰면 왜 안 열리나?
- `nodePort: 30080` 을 `30081` 로 바꾸면? (kind-config 는 그대로)
- 서비스가 다섯 개가 되면 NodePort 는 무엇이 불편한가?
- DB 를 밖에서 보게 하려면 어떻게 해야 하나? 그리고 **왜 하면 안 되나**?

## 📝 강의 메모

- ⭐⭐ **①의 세 단계 그림을 칠판에 먼저** 그리고 시작한다. 오늘 가장 헷갈리는 절이다
- 🚨 **②는 STEP 0 에서 끝내 둔다.** 수업 중에 클러스터를 지우고 다시 만들면 **15분이 날아간다**
  - 대본은 처음부터 `--config ~/kind-config.yaml` 로 만든다
- ⭐ **번호 네 개(`port`·`targetPort`·`nodePort`·`hostPort`)** 가 폭격이다. **표를 칠판에 그려 두고** 하나씩 가리킨다
  - 🗣 "14일차 `-p 8080:80` 이 네 칸으로 늘어난 겁니다"
- ⭐⭐ **⑤의 표가 과정 전체의 회수 지점**이다. 11일차 공격 표면 → 14일차 `-p` → 오늘 Service 타입
- ⚠️ Ingress 는 **욕심내지 않는다.** 컨트롤러 설치까지 가면 마지막 날을 못 끝낸다. **개념 + 시연**으로 끊을 것
- ⏱ 45분 (이론 20 + 실습 25)
