# 7. 더 들어가기 — 라벨 · 로그 · 진단

> 상위: [15일차 · 쿠버네티스 입문](README.md) · 절차는 [라벨과 진단 실습](lesson-7-lab.md), 대본은 [STEP 7](commands.md)
> 이 노트는 [6. kubectl 은 API 클라이언트다](lesson-6.md)와 택1이다(B안). 설치가 늦어졌거나 반이 어려워할 때 이쪽으로 간다. 새 개념을 더하지 않고 오늘 것을 굳힌다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-007-DO |
| 유형 | D&O (개념) |
| 목적 | 라벨과 셀렉터가 쿠버네티스를 묶는 방식, `logs`, `describe`, `exec`의 사용(14일차 대응), 안 될 때 좁혀 가는 순서, 네임스페이스를 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 라벨과 셀렉터가 쿠버네티스를 묶는 방식임을 안다.
- `kubectl logs`, `describe`, `exec`로 안을 들여다본다(14일차 대응).
- 문제가 생겼을 때 좁혀 가는 순서를 익힌다(12일차 진단 회수).
- 네임스페이스가 무엇인지 한 줄로 안다.

## 1. 목적

12일차에 네 단계로 좁히는 법을 배웠다. 14일차에는 `docker logs`와 `docker exec`로 컨테이너 안을 봤다. 오늘도 같은 일을 한다. 이름만 다르다. 이 절은 "안 될 때는 어디를 보는가"에 답한다.

## 2. 구성 요소

### 라벨: 쿠버네티스가 묶는 방법

4번 노트에서 `app: web`을 두 번 적었다. 그것이 라벨이다.

```bash
kubectl get pods --show-labels
kubectl get pods -l app=web          # 라벨로 고르기
kubectl get pods -l app!=web         # 아닌 것
```

쿠버네티스에는 "소속"이 없다. Deployment가 Pod를 품고 있는 것이 아니라, 라벨이 맞는 Pod를 자기 것으로 센다. Service도 같은 방식으로 보낼 곳을 고른다.

비유는 조끼 색이다. 근무 규정도 "파란 조끼 3명", 손님 안내도 "파란 조끼에게"이다. 조끼를 갈아입히면 소속이 바뀐다.

```bash
kubectl label pod <Pod 이름> app=other --overwrite   # 조끼를 갈아입힌다
kubectl get pods                                     # 새 Pod 가 하나 생긴다
```

라벨을 바꾸면 Deployment가 "하나 모자라네" 하고 새로 만든다. 5번 노트의 그 원리가 라벨로 돌아간다는 증거다.

{% hint style="warning" %}
CAUTION: 실습 후 정리한다: `kubectl delete pod -l app=other`.
{% endhint %}

### 들여다보는 세 가지: 14일차와 같은 자리

| 하고 싶은 일 | 14일차(docker) | 오늘(kubectl) |
|---|---|---|
| 로그 | `docker logs web` | `kubectl logs <Pod>` |
| 로그 실시간 | `docker logs -f web` | `kubectl logs -f <Pod>` |
| 자세히 | `docker inspect web` | `kubectl describe pod <Pod>` |
| 안에 들어가기 | `docker exec -it web bash` | `kubectl exec -it <Pod> -- bash` |

```bash
kubectl logs -l app=web --tail=20        # 라벨로 한꺼번에
kubectl describe pod <Pod 이름>
kubectl exec -it <Pod 이름> -- sh
```

`describe`의 맨 아래에 Events가 있다.

```
Events:
  Type     Reason     Age   From               Message
  ----     ------     ----  ----               -------
  Normal   Scheduled  30s   default-scheduler  Successfully assigned ...
  Normal   Pulling    29s   kubelet            Pulling image "nginx"
  Normal   Created    25s   kubelet            Created container nginx
  Normal   Started    25s   kubelet            Started container nginx
```

{% hint style="info" %}
NOTE: 안 될 때 가장 먼저 볼 곳이 Events다. 12일차 `journalctl`과 같은 자리다. 이미지를 못 받았는지, 자리가 없는지, 죽어서 다시 뜨는지가 영어 한 줄로 적혀 있다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `kubectl exec`의 `--`는 "여기부터는 컨테이너 안에서 실행할 명령"이라는 표시다. 빼먹으면 옵션으로 오해한다. `nginx` 이미지에는 `bash`가 있지만 가벼운 이미지에는 `sh`만 있다. 14일차 알파인에서 겪은 것과 같다.
{% endhint %}

### 안 될 때: 좁혀 가는 순서

```
 ① kubectl get pods          →  STATUS 가 Running 인가?
 ② kubectl describe pod ...  →  Events 에 뭐라고 적혀 있나?
 ③ kubectl logs ...          →  프로그램이 뱉은 말은?
 ④ kubectl get svc,endpoints →  Service 가 Pod 를 찾고 있나?
```

| 증상 | 가장 흔한 원인 | 볼 곳 |
|---|---|---|
| `ImagePullBackOff` | 이미지 이름·태그 오타 | ② Events |
| `CrashLoopBackOff` | 떴다가 바로 죽는다 | ③ logs |
| `Pending` | 올릴 자리가 없다(메모리) | ② Events |
| Pod는 `Running`인데 접속이 안 된다 | 라벨이 안 맞는다 | ④ endpoints가 비어 있다 |

`kubectl get endpoints <서비스>`가 비어 있으면 라벨 문제다. 14일차에 `ss`로 "듣고 있나"를 보던 자리와 같다.

{% hint style="info" %}
NOTE: Endpoints API는 EndpointSlice로 대체되는 중이다. `kubectl get endpoints`가 경고를 출력하면 `kubectl get endpointslices -l kubernetes.io/service-name=<서비스>`를 쓴다(이 문서에서 확인하지 않았다).
{% endhint %}

### 네임스페이스: 방을 나눈다 (개념만)

```bash
kubectl get pods -A                  # 모든 방
kubectl get ns                       # 방 목록
kubectl get pods -n kube-system      # 쿠버네티스 자신의 방
```

네임스페이스는 한 클러스터 안의 칸막이다. 이름이 겹쳐도 방이 다르면 상관없다. 팀별, 환경별(개발, 운영)로 나눌 때 쓴다. 우리는 계속 `default` 방에서만 놀았다. 오늘은 "그런 것이 있다"까지만 다룬다.

{% hint style="danger" %}
WARNING: `kubectl delete ns <이름>`은 3초 멈춘다. 그 방의 전부가 사라진다.
{% endhint %}

## 3. 동작 원리

1. Pod에 라벨(`app=web`)이 붙어 있다.
2. Deployment는 `selector.matchLabels`에 맞는 Pod의 개수를 센다.
3. Service는 `spec.selector`에 맞는 Pod를 찾아 보낼 곳 목록(endpoints)을 만든다.
4. 라벨을 바꾸면 소속이 바뀐다. Deployment는 개수가 모자라 새 Pod를 만들고, Service는 목록에서 그 Pod를 뺀다.
5. 문제가 생기면 ① `get pods`, ② `describe`(Events), ③ `logs`, ④ `get svc,endpoints` 순으로 좁힌다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 라벨(label) | Pod 등에 붙이는 이름표(`app=web`) |
| 셀렉터(selector) | 어떤 라벨을 고를지 적은 조건 |
| Events | `describe` 맨 아래에 나오는 일어난 일의 기록 |
| endpoints | Service가 보낼 Pod 주소의 목록 |
| 네임스페이스(namespace) | 한 클러스터 안의 칸막이 |
| `-A` | 모든 네임스페이스를 대상으로 한다 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 14일차 대응표 | 14일차 대응표와 같은 모양으로 칠판에 그린다(세 번째 반복) |
| 2 | 좁혀 가는 순서 | ①~④ 네 단계 |

## 강의 메모

- 라벨 바꾸기 실습이 이 절의 하이라이트다. 5번 노트의 원리를 다른 각도에서 한 번 더 때린다.
- `describe`의 Events를 "안 되면 여기부터"로 못 박는다. 이 한 줄이 남으면 현업에서 산다.
- 14일차 대응표와 같은 모양으로 칠판에 그린다(세 번째 반복이다).
- `exec`의 `--`를 빠뜨리는 실수가 많다. 일부러 한 번 틀리게 쳐 보여 준다.
- 네임스페이스는 깊이 들어가지 않는다. `-A` 옵션의 뜻 정도만 다룬다.
- 25분(이론 10, 실습 15). 시간이 모자라면 네임스페이스를 생략한다.

### 토의 질문

- `kubectl get pods -l app=web`과 `kubectl get pods`의 결과가 같다. 왜인가? 언제 달라지는가?
- 라벨을 바꿨더니 Pod가 하나 더 생겼다. 원래 Pod는 어떻게 됐는가?
- `kubectl exec -it <Pod> bash`(`--` 없이)를 치면 어떻게 되는가?

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `describe`와 `logs` 중 "이미지를 못 받았다"를 알려 주는 쪽은 어느 쪽인가? 이유와 함께 적는다.
- [ ] Service에 접속이 안 되고 `endpoints`가 비어 있다면 어디를 고쳐야 하는가?
- [ ] 쿠버네티스에 "소속"이 없고 라벨만 있다는 말을 내 말로 설명한다.
