# 7. 더 들어가기 — 라벨 · 로그 · 진단 🅱️

> 상위: [15일차 · 쿠버네티스 입문](README.md) · 대본 [STEP 7](commands.md)
> ⚖️ **이 절은 [6_API로_들여다보기](lesson-6.md) 와 택1이다.** 설치가 늦어졌거나 반이 어려워할 때 이쪽으로 간다. 새 개념을 더하지 않고 **오늘 것을 굳힌다.**

## 🎯 학습 목표

- **라벨과 셀렉터**가 쿠버네티스를 묶는 방식임을 안다 ⭐
- `kubectl logs` · `describe` · `exec` 로 안을 들여다본다 (14일차 대응) ⭐
- 문제가 생겼을 때 **좁혀 가는 순서**를 익힌다 (12일차 진단 회수)
- **네임스페이스**가 무엇인지 한 줄로 안다

## 🌉 다리 놓기: "안 될 때는 어디를 보나요?"

12일차에 **네 단계로 좁히는 법**을 배웠다. 14일차에는 `docker logs` 와 `docker exec` 로 컨테이너 안을 봤다. 오늘도 같은 일을 한다. **이름만 다르다.**

---

## 📖 ① 라벨 — 쿠버네티스가 묶는 방법 ⭐

4번 절에서 `app: web` 을 두 번 적었다. 그게 **라벨**이다.

```bash
kubectl get pods --show-labels
kubectl get pods -l app=web          # 라벨로 고르기
kubectl get pods -l app!=web         # 아닌 것
```

> 📌 **쿠버네티스에는 "소속"이 없다.** Deployment 가 Pod 를 **품고 있는 게 아니라**, 라벨이 맞는 Pod 를 **자기 것으로 센다.** Service 도 같은 방식으로 **보낼 곳을 고른다.**

> 💡 **비유: 조끼 색.** 근무 규정도 "파란 조끼 3명", 손님 안내도 "파란 조끼에게". 조끼를 갈아입히면 **소속이 바뀐다.**

```bash
kubectl label pod <Pod 이름> app=other --overwrite   # 조끼를 갈아입힌다
kubectl get pods                                     # ⭐ 새 Pod 가 하나 생긴다!
```

> ⭐ **라벨을 바꾸면 Deployment 가 "하나 모자라네" 하고 새로 만든다.** 5번 절의 그 원리가 **라벨로** 돌아간다는 증거다.
> ⚠️ 실습 후 정리: `kubectl delete pod -l app=other`

---

## 📖 ② 들여다보는 세 가지 — 14일차와 같은 자리

| 하고 싶은 일 | 14일차 (docker) | 오늘 (kubectl) |
|--------------|-----------------|----------------|
| 로그 | `docker logs web` | **`kubectl logs <Pod>`** |
| 로그 실시간 | `docker logs -f web` | **`kubectl logs -f <Pod>`** |
| 자세히 | `docker inspect web` | **`kubectl describe pod <Pod>`** ⭐ |
| 안에 들어가기 | `docker exec -it web bash` | **`kubectl exec -it <Pod> -- bash`** |

```bash
kubectl logs -l app=web --tail=20        # 라벨로 한꺼번에 ⭐
kubectl describe pod <Pod 이름>
kubectl exec -it <Pod 이름> -- sh
```

### ⭐ `describe` 의 맨 아래 — Events

```
Events:
  Type     Reason     Age   From               Message
  ----     ------     ----  ----               -------
  Normal   Scheduled  30s   default-scheduler  Successfully assigned ...
  Normal   Pulling    29s   kubelet            Pulling image "nginx"
  Normal   Created    25s   kubelet            Created container nginx
  Normal   Started    25s   kubelet            Started container nginx
```

> ⭐⭐ **안 될 때 가장 먼저 볼 곳이 Events 다.** 12일차 `journalctl` 과 같은 자리다. 이미지를 못 받았는지, 자리가 없는지, 죽어서 다시 뜨는지가 **한국어보다 정확한 영어 한 줄**로 적혀 있다.

> 📌 `kubectl exec` 의 `--` 는 **"여기부터는 컨테이너 안에서 실행할 명령"** 이라는 표시다. 빼먹으면 옵션으로 오해한다.
> ⚠️ `nginx` 이미지에는 `bash` 가 있지만 **가벼운 이미지에는 `sh` 만** 있다. 14일차 알파인에서 겪은 것과 같다.

---

## 📖 ③ 안 될 때 — 좁혀 가는 순서

```
 ① kubectl get pods          →  STATUS 가 Running 인가?
 ② kubectl describe pod ...  →  Events 에 뭐라고 적혀 있나?
 ③ kubectl logs ...          →  프로그램이 뱉은 말은?
 ④ kubectl get svc,endpoints →  Service 가 Pod 를 찾고 있나?
```

| 증상 | 가장 흔한 원인 | 볼 곳 |
|------|----------------|-------|
| `ImagePullBackOff` | 이미지 이름·태그 오타 | ② Events |
| `CrashLoopBackOff` | 떴다가 바로 죽는다 | ③ logs |
| `Pending` | 올릴 자리가 없다(메모리) | ② Events |
| Pod 는 `Running` 인데 접속이 안 된다 | **라벨이 안 맞는다** | ④ endpoints 가 비어 있다 ⭐ |

> ⭐ **`kubectl get endpoints <서비스>` 가 비어 있으면 라벨 문제다.** 14일차에 `ss` 로 "듣고 있나"를 보던 자리와 같다.

---

## 📖 ④ 네임스페이스 — 방을 나눈다 (개념만)

```bash
kubectl get pods -A                  # 모든 방
kubectl get ns                       # 방 목록
kubectl get pods -n kube-system      # 쿠버네티스 자신의 방
```

> 📌 **네임스페이스 = 한 클러스터 안의 칸막이.** 이름이 겹쳐도 방이 다르면 상관없다. 팀별·환경별(개발/운영)로 나눌 때 쓴다.
> 📌 우리는 계속 **`default` 방**에서만 놀았다. 오늘은 **"그런 게 있다"** 까지.
> 🛑 **`kubectl delete ns <이름>` 은 3초 멈춤** — 그 방의 **전부**가 사라진다.

---

## 🧪 실습 / 질문

- `kubectl get pods -l app=web` 과 `kubectl get pods` 의 결과가 같다. 왜일까? 언제 달라지나?
- 라벨을 바꿨더니 Pod 가 하나 더 생겼다. 원래 Pod 는 어떻게 됐나?
- `describe` 와 `logs` 중 **"이미지를 못 받았다"** 를 알려주는 쪽은?
- Service 에 접속이 안 된다. `endpoints` 가 비어 있다면 어디를 고쳐야 하나?
- `kubectl exec -it <Pod> bash` (`--` 없이) 를 치면 어떻게 되나?

## 📝 강의 메모

- ⭐ **①의 라벨 바꾸기 실습**이 이 절의 하이라이트다. 5번 절 원리를 **다른 각도**에서 한 번 더 때린다
- ⭐⭐ **`describe` 의 Events** 를 "안 되면 여기부터" 로 못 박는다. 이 한 줄이 남으면 현업에서 산다
- 📌 14일차 대응표와 **같은 모양**으로 칠판에 그린다 (세 번째 반복이다)
- ⚠️ `exec` 의 `--` 를 빠뜨리는 실수가 많다. 일부러 한 번 틀리게 쳐 보여줄 것
- ⚠️ 네임스페이스는 **깊이 들어가지 않는다.** `-A` 옵션의 뜻 정도만
- ⏱ 25분 (이론 10 + 실습 15). 시간이 모자라면 ④를 생략
