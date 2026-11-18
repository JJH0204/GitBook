# 5. 자가 치유와 스케일 — 지워도 돌아온다

> 상위: [15일차 · 쿠버네티스 입문](README.md) · 절차는 [Pod 삭제와 스케일 실습](lesson-5-lab.md), 대본은 [STEP 5](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-005-DO |
| 유형 | D&O (개념) |
| 목적 | Pod를 지워도 새 Pod가 생기는 이유("되살리는 것이 아니라 개수를 맞춘다"), `replicas`와 스케일, 파일로 개수를 정해야 하는 이유, 프로브(개념)를 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- Pod를 일부러 지우고, 새 Pod가 생기는 것을 눈으로 본다.
- `replicas`를 바꿔 개수가 맞춰지는 것을 본다.
- "되살리는 것이 아니라 개수를 맞춘다"를 설명한다.
- 1번 노트의 명령형과 선언형이 여기서 증명되는 것을 확인한다.

## 1. 목적

오늘 처음에 이렇게 말했다.

> 강사 대사: "`docker run`은 '해라', 쿠버네티스는 '이렇게 되어 있어라'입니다."

말로는 알겠는데 와닿지 않는다. 직접 깨뜨려 보면 안다. 이 절은 오늘의 결론인 자가 치유(self-healing)를 설명한다.

## 2. 구성 요소

### Pod를 지워 본다

터미널을 두 개 띄운다. 터미널 A는 지켜보는 창, 터미널 B는 깨뜨리는 창이다.

```bash
# 터미널 A
kubectl get pods -w
```

```bash
# 터미널 B
kubectl get pods                       # 이름 확인 (각자 다르다)
kubectl delete pod web-5d8f9c7b4-x7k2p
```

터미널 A에서 벌어지는 일은 다음과 같다.

```
web-5d8f9c7b4-x7k2p   1/1   Running       0     5m
web-5d8f9c7b4-x7k2p   1/1   Terminating   0     5m
web-5d8f9c7b4-q9w1r   0/1   Pending       0     0s     ← 새 Pod 가 벌써
web-5d8f9c7b4-q9w1r   0/1   ContainerCreating  0  0s
web-5d8f9c7b4-q9w1r   1/1   Running       0     2s
```

> 강사 대사: "지운 Pod가 살아난 것이 아닙니다. 이름을 보세요. 다른 Pod입니다."

{% hint style="info" %}
NOTE: 이것이 오늘의 결론이다. 쿠버네티스는 지운 것을 되살리지 않는다. "1개여야 하는데 0개네"를 보고 새로 하나 만든 것이다. 에어컨 비유로는 껐더니 24도가 깨졌고, 에어컨이 다시 돌기 시작한 것이다.
{% endhint %}

| | 14일차 Compose | 오늘 쿠버네티스 |
|---|---|---|
| 컨테이너를 지우면 | `docker rm -f web`으로 없어진다 | 새 Pod가 생긴다 |
| `restart: unless-stopped`이면 | 죽었을 때 같은 컨테이너를 다시 켠다 | 애초에 개수를 본다 |
| 내가 할 일 | `docker compose up -d`를 다시 | 없다 |

{% hint style="danger" %}
WARNING: 진짜로 없애려면 Deployment를 지운다. `kubectl delete deployment web`을 하면 Pod도 따라 사라진다. 다시 만들려면 `kubectl apply -f deployment.yaml`을 한다.
{% endhint %}

### 개수를 바꿔 본다: 스케일

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

한 줄로 3개가 됐다. 14일차에 이것을 하려면 `docker run`을 세 번 치고 이름과 포트를 각각 달리 줘야 했다.

Service는 셋에게 나눠 보낸다.

```bash
kubectl get endpoints web        # 세 Pod 의 주소가 등록돼 있다
```

Service는 라벨이 맞는 Pod를 계속 찾아 목록을 갱신한다. 하나가 죽으면 자동으로 목록에서 빠진다. 1번 노트에서 "Compose는 이것을 사람이 한다"고 했던 그 일이다.

{% hint style="info" %}
NOTE: 원본 명령 `kubectl get endpoints`의 Endpoints API는 쿠버네티스 최신 버전에서 EndpointSlice로 대체되는 중이다(v1.33부터 deprecated 경고가 출력된다고 알려져 있으나 이 문서에서 확인하지 않았다). 경고가 나오면 `kubectl get endpointslices -l kubernetes.io/service-name=web`을 쓴다.
{% endhint %}

줄이는 것도 같다.

```bash
kubectl scale deployment web --replicas=1
kubectl get pods                 # 둘이 Terminating
```

### 파일로 하는 것이 정석이다

```bash
nano deployment.yaml             # replicas: 3
kubectl apply -f deployment.yaml
```

{% hint style="warning" %}
CAUTION: `kubectl scale`로 바꾼 것은 파일에 남지 않는다. 다음에 누가 `apply`하면 파일에 적힌 숫자로 돌아간다. 13일차 "서버에서 직접 고치지 않는다"와 완전히 같은 교훈이다. 고치는 곳은 파일 하나다.
{% endhint %}

### 죽지 않았는데 먹통일 때 (개념만)

1번 노트에서 Compose의 한계로 들었던 것이다. 쿠버네티스는 살아 있는지 물어볼 수 있다.

```yaml
        livenessProbe:            # "살아 있나?" 주기적으로 묻는다
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
```

- 응답이 없으면 컨테이너를 다시 시작한다.
- 비슷한 것으로 `readinessProbe`가 있다. "손님 받을 준비가 됐나"를 묻는다. 준비되기 전에는 Service가 보내지 않는다.

14일차 MariaDB에서 `ready for connections`를 기다리던 일을 기억한다. 그것을 사람이 눈으로 하던 것을 쿠버네티스가 대신 한다. 오늘은 개념까지만 다루고 실습은 하지 않는다.

### 오늘 가져갈 한 줄

> 강사 대사: "쿠버네티스는 되살리지 않습니다. 세어 보고 모자라면 만듭니다."

```
 원하는 상태:  web 3개
 실제:         web 2개        ← 하나가 죽었다
 ──────────────────────────
 차이:         1개 모자람  →  만든다
```

## 3. 동작 원리

1. Deployment에 `replicas: N`이 적혀 있다.
2. 쿠버네티스가 라벨이 맞는 Pod의 실제 개수를 센다.
3. 실제가 N보다 적으면 새 Pod를 만든다. 많으면 줄인다.
4. Pod를 지우면 실제 개수가 줄고, 2~3이 다시 돌아 새 Pod(다른 이름)가 생긴다.
5. `scale`이나 파일 수정으로 N을 바꾸면 같은 방식으로 개수가 맞춰진다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 자가 치유(self-healing) | 원하는 상태가 깨지면 스스로 되돌리는 성질 |
| 스케일(scale) | Pod 개수를 늘리거나 줄이는 것 |
| `replicas` | 유지할 Pod 개수 |
| `livenessProbe` | 살아 있는지 주기적으로 묻는 검사 |
| `readinessProbe` | 손님을 받을 준비가 됐는지 묻는 검사 |
| `Terminating` | 지워지는 중인 Pod의 상태 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 명령형과 선언형 칠판 | 1번 노트의 칠판을 다시 가리키며 수미상관으로 닫는다 |
| 2 | 개수 차이 그림 | 원하는 상태, 실제, 차이, 만든다 |

## 강의 메모

- 오늘의 하이라이트다. 전원이 직접 친다. 터미널 두 개(`-w` 창과 치는 창)를 꼭 띄우게 한다.
- "이름을 보세요"가 핵심 대사다. 지운 것이 살아난 것이 아니라는 것을 이름으로 증명한다.
- 학생들이 강사 화면의 Pod 이름을 그대로 친다. `kubectl get pods`로 자기 이름을 확인하게 한다. 복사가 귀찮으면 `kubectl delete pod $(kubectl get pods -o name | head -1)`을 알려 줘도 된다.
- `kubectl scale` 뒤에 반드시 "파일이 정석이다"를 짚는다. 안 그러면 "명령으로 하면 되네"가 남는다.
- 25분(실습 20, 개념 5). 프로브는 시간이 없으면 생략한다.
- 이 절이 끝나면 1번 노트의 칠판(명령형, 선언형)을 다시 가리킨다.

### 토의 질문

- `kubectl delete pod`를 세 번 연속 치면? Deployment를 지우면?
- `kubectl scale --replicas=3`을 한 뒤 `kubectl apply -f deployment.yaml`(파일은 1)을 치면 몇 개가 되는가?
- `replicas: 0`으로 두면 어떻게 되는가? 이것이 쓸모 있는 경우는?
- `livenessProbe`가 없으면 못 잡는 고장을 하나 든다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Pod를 지웠을 때 이름이 바뀌는 것이 왜 중요한가? 3번 노트의 Service와 엮어 적는다.
- [ ] "쿠버네티스는 되살리지 않는다. 세어 보고 모자라면 만든다"를 내 말로 다시 설명한다.
- [ ] `scale`로 바꾼 개수가 `apply` 한 번에 되돌아갔다면, 실무에서 어떤 사고가 날 수 있는가?
