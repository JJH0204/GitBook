# 3. 첫 배포 — Pod · Deployment · Service ⭐⭐

> 상위: [15일차 · 쿠버네티스 입문](README.md) · 대본 [STEP 3](commands.md)

## 🎯 학습 목표

- **Pod · Deployment · Service** 세 단어를 구분한다 ⭐⭐
- `kubectl create deployment` 로 첫 배포를 하고 Pod 를 확인한다
- **Service** 로 Pod 묶음에 이름과 고정 주소를 준다
- **`kubectl port-forward`** 로 내 브라우저에서 확인한다
- 14일차 Compose 와 **단어를 맞대어** 본다

## 🌉 다리 놓기: 클러스터는 섰다. 그럼 무엇을 올리나

14일차에는 이렇게 띄웠다.

```bash
docker run -d -p 8080:80 --name web nginx
```

쿠버네티스에서는 이렇게 한다.

```bash
kubectl create deployment web --image=nginx
```

> 🗣 **"`-p` 가 없습니다. `--name` 도 뜻이 다릅니다. 하나씩 봅시다."**

---

## 📖 ① 세 단어만 외운다 ⭐⭐

```
  Deployment            ReplicaSet(숨어 있다)            Pod
  "web 을 3개 유지해라"  ──▶  개수를 맞춘다  ──▶   ┌──────┐ ┌──────┐ ┌──────┐
                                                  │ Pod  │ │ Pod  │ │ Pod  │
                                                  │ nginx│ │ nginx│ │ nginx│
                                                  └──────┘ └──────┘ └──────┘
                                                       ▲
                        Service "web"  ───────────────┘
                        이름 하나 · 고정 주소 하나로 묶어 준다
```

| 단어 | 한 줄 | 14일차로 치면 |
|------|-------|---------------|
| **Pod** | 컨테이너를 감싼 **가장 작은 단위** | 컨테이너 하나 |
| **Deployment** | **"몇 개를 유지해라"** 를 적은 것 | `compose.yaml` 의 서비스 한 칸 + `restart` |
| **Service** | Pod 묶음에 **이름과 고정 주소** | Compose 의 **서비스 이름으로 통하던 그것** ⭐ |

> 💡 **비유: 식당의 홀 서빙.**
> **Pod** = 서빙하는 직원 한 명. **Deployment** = "홀에 항상 3명이 있어야 한다"는 근무 규정. 한 명이 조퇴하면 규정이 새 사람을 부른다.
> **Service** = 손님이 부르는 **"여기요"**. 누가 오든 상관없다. 손님은 **직원 이름을 모른다.**

> 📌 **왜 Pod 라는 한 겹이 더 있나?** 컨테이너 **여러 개를 한 몸처럼** 묶어야 할 때가 있기 때문이다(같은 주소를 쓰고 같이 뜨고 같이 죽는다). 입문 단계에서는 **"Pod ≈ 컨테이너 하나"** 로 둔다.

> ⭐ **Pod 이름을 외우지 않는다.** `web-5d8f9c7b4-x7k2p` 처럼 **매번 바뀐다.** 바뀌는 게 정상이고, 그래서 **Service** 가 필요하다.

---

## 📖 ② 띄워 본다

```bash
kubectl create deployment web --image=nginx
kubectl get deployments
kubectl get pods
```

```
NAME                   READY   UP-TO-DATE   AVAILABLE
web                    1/1     1            1

NAME                   READY   STATUS    RESTARTS   AGE
web-5d8f9c7b4-x7k2p    1/1     Running   0          20s
```

> 🔎 **Pod 이름 = `Deployment 이름 - 임의 문자열 - 임의 문자열`.** 가운데 덩어리가 ReplicaSet, 끝이 Pod 고유값이다. 외울 것이 아니라 **복사해서 쓰는** 값이다.

**상태가 `Running` 이 아니라면** 14일차 ④ 확인 단계와 같은 자리다.

| STATUS | 뜻 | 볼 곳 |
|--------|-----|-------|
| `ContainerCreating` | 이미지를 받는 중 | 기다린다 |
| `ImagePullBackOff` · `ErrImagePull` | **이미지를 못 찾는다** | 이름·태그 오타 (16일차에 다시 만난다) |
| `CrashLoopBackOff` | 떴다가 **계속 죽는다** | `kubectl logs <Pod>` |
| `Pending` | 올릴 자리가 없다 | 메모리 부족 등 |

---

## 📖 ③ Service — 이름과 고정 주소를 준다

Pod 는 주소가 **바뀐다.** 지우고 다시 만들면 IP 가 달라진다. 그래서 앞에 **Service** 를 둔다.

```bash
kubectl expose deployment web --port=80
kubectl get services
```

```
NAME         TYPE        CLUSTER-IP      PORT(S)   AGE
kubernetes   ClusterIP   10.96.0.1       443/TCP   10m
web          ClusterIP   10.96.123.45    80/TCP    5s
```

> 📌 **`ClusterIP` 는 클러스터 안에서만 쓰는 주소다.** 밖에서는 아직 못 들어온다 — 14일차에 `-p` 를 **안 쓴 DB** 와 같은 상태다.
> ⭐ 11일차 **최소 개방**이 쿠버네티스에서는 **기본값**이다. 아무것도 안 하면 밖에 안 열린다.

### 이름으로 통하는지 확인한다

```bash
kubectl run tmp --image=busybox --rm -it --restart=Never -- wget -qO- http://web
```

```
<!DOCTYPE html>
<html>
<head><title>Welcome to nginx!</title>
```

> ⭐ **`http://web`** 이 통했다. IP 를 쓰지 않았다. 14일차 Compose 에서 `getent hosts db` 로 확인한 **그 내부 DNS** 가 여기서도 같은 방식으로 동작한다.
> 🔎 `--rm` 은 끝나면 지우라는 뜻, `--restart=Never` 는 "한 번만 돌고 끝"이라는 뜻이다. 일회용 디버깅 Pod 를 띄우는 상투적인 방법이다.

---

## 📖 ④ 내 브라우저에서 보기 — `port-forward`

클러스터 안에만 열려 있으니, 내 PC 와 **임시로 통로**를 뚫는다.

```bash
kubectl port-forward service/web 8080:80
```

```
Forwarding from 127.0.0.1:8080 -> 80
```

```
🪟 http://localhost:8080   →  Welcome to nginx!
```

> 📌 **이 명령은 켜 둔 동안만 유효하다.** `Ctrl+C` 로 끄면 통로가 닫힌다. **배포가 아니라 들여다보기용**이다.
> ⭐ 14일차 **`-p 127.0.0.1:8080:80`** 과 같은 자리다 — **나만 볼 수 있게** 여는 것. 밖으로 제대로 여는 법은 **16일차**에서.
> ⚠️ 터미널 하나를 **점유한다.** 다른 명령을 치려면 터미널을 하나 더 열거나 `Ctrl+C` 로 끈다.

---

## 📖 ⑤ 14일차와 단어 맞대기

| 하고 싶은 일 | 14일차 (docker) | 오늘 (kubectl) |
|--------------|-----------------|----------------|
| 띄우기 | `docker run -d --name web nginx` | `kubectl create deployment web --image=nginx` |
| 떠 있나 | `docker ps` | **`kubectl get pods`** |
| 자세히 | `docker inspect` | **`kubectl describe pod <이름>`** |
| 로그 | `docker logs web` | **`kubectl logs <Pod 이름>`** |
| 안에 들어가기 | `docker exec -it web bash` | **`kubectl exec -it <Pod> -- bash`** |
| 지우기 | `docker rm -f web` | **`kubectl delete deployment web`** ⚠️ |
| 이름으로 통신 | Compose 서비스 이름 | **Service 이름** |

> 🚨 **지우는 것만 자리가 다르다.** `kubectl delete pod` 를 해도 **Deployment 가 다시 만든다.** 진짜로 없애려면 **Deployment 를 지워야** 한다. 이것이 5번 절의 주제다.

---

## 🧪 실습 / 질문

- `kubectl get pods` 의 Pod 이름을 적어 두자. 뒤에서 어떻게 바뀌는지 볼 것이다
- Service 를 만들기 전에 `http://web` 으로 접속하면 어떻게 될까?
- `kubectl port-forward` 를 `Ctrl+C` 로 끈 뒤 브라우저를 새로고침하면?
- `docker run -p 8080:80` 과 `kubectl port-forward 8080:80` 은 무엇이 같고 무엇이 다른가?
- 손님이 직원 이름을 모르는 게 왜 좋은 일일까? (Service 비유)

## 📝 강의 메모

- ⭐⭐ **세 단어만.** ReplicaSet 은 그림에 "숨어 있다"고만 쓰고 이름을 외우게 하지 않는다
- ⭐ **식당 비유**를 하루 끝까지 같은 말로 쓴다 — Pod=직원, Deployment=근무 규정, Service=여기요
- ⭐ **Pod 이름이 매번 다르다**는 것을 일부러 짚는다. 학생들이 강사 화면의 이름을 그대로 따라 치다 막힌다
  - 👉 **`kubectl get pods` 로 자기 이름을 확인해서 쓰라**고 세 번 말할 것
- ⚠️ `kubectl run tmp ...` 한 줄은 **강사가 먼저 치고 결과를 보여준 뒤** 따라 치게 한다. 옵션이 많아 오타가 난다
- ⚠️ `port-forward` 가 터미널을 점유한다 → **터미널 두 개**를 띄워 두게 미리 안내
- 📌 ⑤ 표는 14일차 노트의 대응표와 **같은 모양**으로 그린다. "또 그 표네" 가 나오면 성공이다
- ⏱ 40분 (이론 15 + 실습 25)
