# 5. 자가 치유와 스케일 — 지워도 돌아온다 ⭐⭐

> 상위: [15일차 · 쿠버네티스 입문](README.md) · 대본 [STEP 5](commands.md)

## 🎯 학습 목표

- Pod 를 **일부러 지우고**, 새 Pod 가 생기는 것을 눈으로 본다 ⭐⭐
- `replicas` 를 바꿔 **개수가 맞춰지는 것**을 본다
- **"되살리는 게 아니라 개수를 맞춘다"** 를 설명한다 ⭐
- 1번 절의 **명령형 vs 선언형**이 여기서 증명되는 것을 확인한다

## 🌉 다리 놓기: 1번 절의 약속

오늘 처음에 이렇게 말했다.

> 🗣 **"`docker run` 은 '해라', 쿠버네티스는 '이렇게 되어 있어라' 입니다."**

말로는 알겠는데 와닿지 않는다. **직접 깨뜨려 보면** 안다.

---

## 📖 ① ⭐⭐ Pod 를 지워 본다

터미널을 **두 개** 띄운다.

```bash
# 터미널 A — 지켜보는 창
kubectl get pods -w
```

```bash
# 터미널 B — 깨뜨리는 창
kubectl get pods                       # 이름 확인 (각자 다르다!)
kubectl delete pod web-5d8f9c7b4-x7k2p
```

**터미널 A 에서 벌어지는 일**

```
web-5d8f9c7b4-x7k2p   1/1   Running       0     5m
web-5d8f9c7b4-x7k2p   1/1   Terminating   0     5m
web-5d8f9c7b4-q9w1r   0/1   Pending       0     0s     ← 새 Pod 가 벌써
web-5d8f9c7b4-q9w1r   0/1   ContainerCreating  0  0s
web-5d8f9c7b4-q9w1r   1/1   Running       0     2s     ⭐
```

> 🗣 **"지운 Pod 가 살아난 게 아닙니다. 이름을 보세요. 다른 Pod 입니다."**

> ⭐⭐ **이것이 오늘의 결론이다.** 쿠버네티스는 지운 것을 되살리지 않는다. **"1개여야 하는데 0개네"** 를 보고 **새로 하나 만든** 것이다.
> 💡 에어컨 비유로 — 껐더니 24도가 깨졌고, 에어컨이 **다시 돌기 시작한** 것이다.

### 14일차와 비교

| | 14일차 Compose | 오늘 쿠버네티스 |
|---|---|---|
| 컨테이너를 지우면 | `docker rm -f web` → **없어진다** | **새 Pod 가 생긴다** |
| `restart: unless-stopped` 면 | 죽었을 때 **같은 컨테이너**를 다시 켠다 | 애초에 **개수**를 본다 |
| 내가 할 일 | `docker compose up -d` 를 다시 | **없다** |

> ⚠️ **진짜로 없애려면 Deployment 를 지운다.**
> ```bash
> kubectl delete deployment web     # 이제 Pod 도 따라 사라진다
> kubectl apply -f deployment.yaml  # 다시 만든다
> ```

---

## 📖 ② 개수를 바꿔 본다 — 스케일

```bash
kubectl scale deployment web --replicas=3
kubectl get pods
```

```
NAME                   READY   STATUS    AGE
web-5d8f9c7b4-q9w1r    1/1     Running   3m
web-5d8f9c7b4-h2n8c    1/1     Running   8s
web-5d8f9c7b4-k4j7v    1/1     Running   8s
```

> ⭐ **한 줄로 3개가 됐다.** 14일차에 이걸 하려면 `docker run` 을 세 번 치고 이름과 포트를 각각 달리 줘야 했다.

**Service 는 셋에게 나눠 보낸다**

```bash
kubectl get endpoints web        # 세 Pod 의 주소가 등록돼 있다
```

> 📌 Service 는 **라벨이 맞는 Pod 를 계속 찾아** 목록을 갱신한다. 하나가 죽으면 **자동으로 목록에서 빠진다.** 1번 절에서 "Compose 는 이걸 사람이 한다"고 했던 그 일이다.

**줄이는 것도 같다**

```bash
kubectl scale deployment web --replicas=1
kubectl get pods                 # 둘이 Terminating
```

### 파일로 하는 것이 정석이다 ⭐

```bash
nano deployment.yaml             # replicas: 3
kubectl apply -f deployment.yaml
```

> ⚠️ **`kubectl scale` 로 바꾼 것은 파일에 남지 않는다.** 다음에 누가 `apply` 하면 **파일에 적힌 숫자로 돌아간다.**
> 📌 13일차 **"서버에서 직접 고치지 않는다"** 와 **완전히 같은 교훈**이다. 고치는 곳은 **파일 하나**다.

---

## 📖 ③ 죽지 않았는데 먹통일 때 (개념만)

1번 절에서 Compose 의 한계로 들었던 것이다. 쿠버네티스는 **살아 있는지 물어볼 수 있다.**

```yaml
        livenessProbe:            # "살아 있나?" 주기적으로 묻는다
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
```

- 응답이 없으면 **컨테이너를 다시 시작**한다
- 비슷한 것으로 **`readinessProbe`** 가 있다 — **"손님 받을 준비가 됐나"**. 준비되기 전에는 Service 가 **보내지 않는다**

> 📌 14일차 MariaDB 에서 **`ready for connections` 를 기다리던 일**을 기억하는가. 그걸 **사람이 눈으로** 하던 것을 **쿠버네티스가 대신** 한다.
> ⏱ **오늘은 개념까지만.** 실습은 하지 않는다 — 시간이 모자라면 이 절을 통째로 넘긴다.

---

## 📖 ④ 오늘 가져갈 한 줄

> 🗣 **"쿠버네티스는 되살리지 않습니다. 세어 보고 모자라면 만듭니다."**

```
 원하는 상태:  web 3개
 실제:         web 2개        ← 하나가 죽었다
 ──────────────────────────
 차이:         1개 모자람  →  만든다
```

---

## 🧪 실습 / 질문

- Pod 를 지웠을 때 **이름이 바뀌는 것**이 왜 중요한가? (3번 절 Service 와 엮어 보자)
- `kubectl delete pod` 를 세 번 연속 치면? Deployment 를 지우면?
- `kubectl scale --replicas=3` 한 뒤 `kubectl apply -f deployment.yaml`(파일은 1) 을 치면 몇 개가 되나?
- `replicas: 0` 으로 두면 어떻게 되나? 이게 쓸모 있는 경우는?
- `livenessProbe` 가 없으면 못 잡는 고장을 하나 들어 보자

## 📝 강의 메모

- ⭐⭐ **오늘의 하이라이트다. 전원이 직접 친다.** 터미널 두 개(`-w` 창 + 치는 창)를 꼭 띄우게 할 것
- ⭐ **"이름을 보세요"** 가 핵심 대사다. 지운 것이 살아난 게 아니라는 걸 이름으로 증명한다
- ⚠️ 학생들이 **강사 화면의 Pod 이름을 그대로 친다** → `kubectl get pods` 로 자기 이름을 확인하게 한다
  - 👉 복사가 귀찮으면 `kubectl delete pod $(kubectl get pods -o name | head -1)` 를 알려줘도 된다
- ⭐ **②의 `kubectl scale` 뒤 반드시 ③(파일이 정석)** 을 짚는다. 안 그러면 "명령으로 하면 되네"가 남는다
- ⏱ 25분 (실습 20 + 개념 5). ③ probe 는 시간 없으면 생략
- 📌 이 절이 끝나면 **1번 절 칠판(명령형/선언형)을 다시 가리킨다.** 수미상관으로 닫는다
