# 4. 선언형 — 매니페스트와 apply

> 상위: [15일차 · 쿠버네티스 입문](README.md) · 절차는 [매니페스트 적용 실습](lesson-4-lab.md), 대본은 [STEP 4](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-004-DO |
| 유형 | D&O (개념) |
| 목적 | 명령으로 만든 것을 파일(매니페스트)로 적는 이유, 매니페스트의 네 줄 머리, 라벨 짝, `apply`의 멱등성, Compose 파일과의 대응, 매니페스트를 Git에 넣는 이유를 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 3번 노트에서 명령으로 만든 것을 파일로 적는다.
- 매니페스트(YAML)의 네 줄 머리(`apiVersion`, `kind`, `metadata`, `spec`)를 읽는다.
- `kubectl apply -f`로 적용하고, 같은 파일을 여러 번 적용해도 안전한 것을 확인한다.
- 14일차 `compose.yaml`과 나란히 놓고 비교한다.
- 매니페스트를 Git 저장소에 넣는다(13일차, 14일차의 그 자리).

## 1. 목적

14일차에 같은 질문을 했다.

> 강사 대사: "`docker run` 명령을 옆자리에 어떻게 전달하죠? 카톡으로요?"

그때의 답은 `compose.yaml`이었다. 오늘도 답은 같다. 명령을 파일로 적는다.

```
 13일차:  Git = 코드
 14일차:  Git = 코드 + 돌리는 방법 (Dockerfile · compose.yaml)
 15일차:  Git = 코드 + 돌리는 방법 + 원하는 상태 (매니페스트)
```

## 2. 구성 요소

### 지금 만든 것을 파일로 꺼내 본다

```bash
kubectl get deployment web -o yaml | head -20
```

쏟아져 나온다. 쿠버네티스가 채워 넣은 기본값과 현재 상태까지 전부 들어 있기 때문이다.

{% hint style="info" %}
NOTE: 이 출력을 그대로 쓰지 않는다. 우리가 적을 것은 "원하는 것"뿐이고, 나머지는 쿠버네티스가 채운다. 14일차 `docker inspect`가 쏟아내던 것과 같다. 읽는 용도지 쓰는 용도가 아니다.
{% endhint %}

### 매니페스트는 네 줄로 시작한다

```yaml
apiVersion: apps/v1     # 이 문서의 규격 버전
kind: Deployment        # 무엇을 만들 것인가
metadata:               # 이름표
  name: web
spec:                   # 원하는 상태
  ...
```

| 줄 | 뜻 | 빠뜨리거나 틀리면 |
|---|---|---|
| `apiVersion` | 이 종류의 규격 버전 | 값이 틀리면 `no matches for kind ...`. 없으면 `apiVersion not set` |
| `kind` | 무엇을 만드는가(`Deployment`, `Service`, `Pod` 등) | 없으면 `kind not set` |
| `metadata.name` | 이름 | 이름 없이는 만들 수 없다 |
| `spec` | 원하는 상태(핵심) | 필수 필드가 없으면 검증 오류가 난다(Deployment는 `selector`, `template`이 필요하다) |

{% hint style="warning" %}
CAUTION: `kind`는 종류를 뜻하는 쿠버네티스 용어다. 우리가 쓰는 도구 `kind`와 글자만 같고 아무 상관이 없다. 오늘 가장 헷갈리는 지점이므로 칠판에 적어 둔다.
{% endhint %}

{% hint style="info" %}
NOTE: 위 표의 "빠뜨리거나 틀리면" 열은 원본의 표(`no matches for kind ...`, "빈 껍데기가 생긴다")를 정정한 것이며 실행해 확인하지 않았다.
{% endhint %}

### Deployment 매니페스트

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

{% hint style="danger" %}
WARNING: `selector.matchLabels`와 `template.metadata.labels`는 같아야 한다. Deployment가 "내가 관리할 Pod"를 찾는 방법이 라벨이기 때문이다. 다르면 Pod가 생겼다 사라졌다 한다.
{% endhint %}

비유는 근무 규정이다. 규정에 "파란 조끼를 입은 사람이 내 직원"이라고 적어 두고, 새로 뽑는 직원에게 파란 조끼를 입히는 것이다. 두 색이 다르면 자기 직원을 못 알아본다.

### Service 매니페스트

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

`port`는 Service가 받는 번호, `targetPort`는 Pod가 듣는 번호다. 14일차 `-p 8080:80`의 왼쪽과 오른쪽과 같은 감각이다.

### `apply`

```bash
kubectl apply -f deployment.yaml --dry-run=client    # 먼저 문법 검사
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get deploy,svc,pods
kubectl apply -f .          # 폴더 안 전부
```

`--dry-run=client`를 먼저 치는 습관을 들인다. 12일차 `nginx -t`, 14일차 `docker compose config`와 같은 자리다. YAML은 들여쓰기가 문법이라 이 한 줄이 사고를 막는다.

{% hint style="warning" %}
CAUTION: `--dry-run=client`는 완전한 오프라인 검사가 아니다. 클러스터에 한 번 물어본다(어떤 종류가 있는지 확인하려고). 클러스터가 죽어 있으면 `connection refused`가 뜬다. 문법이 틀린 것이 아니다(실측).
{% endhint %}

같은 파일을 여러 번 적용해도 괜찮다.

```bash
kubectl apply -f deployment.yaml
kubectl apply -f deployment.yaml      # 또 쳐도 안전하다
```

```
deployment.apps/web unchanged
```

이것이 선언형이다. "만들어라"가 아니라 "이 상태여야 한다"이므로, 이미 그 상태면 아무 일도 하지 않는다. 14일차 `docker run`을 두 번 치면 이름 충돌이 났다. `apply`는 그렇지 않다.

고칠 때도 같은 파일을 고쳐서 다시 `apply`한다.

```bash
nano deployment.yaml        # replicas: 1 → 3
kubectl apply -f deployment.yaml
kubectl get pods            # 3개가 되어 있다
```

### 14일차 Compose와 나란히

| 하고 싶은 일 | `compose.yaml` | 쿠버네티스 매니페스트 |
|---|---|---|
| 무엇을 띄울까 | `services:` 아래 이름 | `kind: Deployment` + `metadata.name` |
| 어떤 이미지 | `image: nginx` | `spec.template.spec.containers[].image` |
| 몇 개 | (없음) | `spec.replicas` |
| 포트 | `ports: ["8080:80"]` | `containerPort` + Service가 따로 |
| 환경 변수 | `environment:` | `env:`(16일차 ConfigMap, Secret) |
| 볼륨 | `volumes:` | `volumes` + `volumeMounts` |
| 재시작 | `restart: unless-stopped` | 기본이 그렇다(적을 필요가 없다) |
| 올리기 | `docker compose up -d` | `kubectl apply -f .` |
| 내리기 | `docker compose down` | `kubectl delete -f .` |

`restart`가 사라진 것이 오늘의 요점이다. Compose에서는 "죽으면 켜라"를 적어야 했지만, 쿠버네티스는 원래 그렇게 동작한다. 대신 파일이 길어졌다. Compose 10줄이 매니페스트 25줄이 된다. 이것이 쿠버네티스의 값이다.

### Git에 넣는다

```
 13일차:  내 코드
 14일차:  + Dockerfile · compose.yaml  (한 대에서 돌리는 방법)
 15일차:  + k8s/*.yaml                 (클러스터에서 원하는 상태)
```

> 강사 대사: "오늘도 결론은 같습니다. 기억하지 말고 저장소에 적어 둡니다."

16일차에 이 폴더(`k8s/`)를 그대로 쓴다.

## 3. 동작 원리

1. 매니페스트에 원하는 상태를 적는다(`replicas: 1`).
2. `kubectl apply -f`가 그 파일을 API 서버에 보낸다.
3. 쿠버네티스가 현재 상태와 파일을 비교한다.
4. 차이가 있으면 맞추고, 없으면 `unchanged`를 출력하고 끝낸다.
5. 고칠 때는 파일을 고쳐 다시 `apply`한다(고치는 곳은 파일 하나).

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 매니페스트(manifest) | 원하는 상태를 적은 YAML 파일 |
| `apiVersion` | 이 종류의 규격 버전 |
| `kind` | 만들 것의 종류(도구 `kind`와 다르다) |
| `metadata` | 이름과 라벨 같은 이름표 |
| `spec` | 원하는 상태 |
| 라벨(label) | `app: web` 같은 이름표. Deployment와 Service가 Pod를 찾는 방법 |
| 셀렉터(selector) | 어떤 라벨의 Pod를 고를지 적은 조건 |
| 멱등성 | 같은 명령을 여러 번 해도 결과가 같은 성질. `apply`가 이렇다 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 라벨 짝 | 두 `app: web`을 같은 색 형광펜으로 표시해 보여 준다 |
| 2 | Compose 대응표 | 14일차 Compose 노트를 옆에 띄워 놓고 짚는다 |

## 강의 메모

- `kind` 혼동을 먼저 못 박는다. 칠판 한구석에 `kind:` = 종류, `kind` = 도구를 적어 두고 시작한다.
- 라벨 짝 맞추기가 1번 사고다. 두 `app: web`을 형광펜으로 같은 색 표시해 보여 준다.
- 같은 파일을 두 번 `apply`하는 장면을 꼭 보여 준다. `unchanged` 한 줄이 선언형의 증거다.
- YAML을 처음부터 타이핑시키면 시간을 다 먹는다. 강사가 파일을 공유하고 학생은 고쳐 쓰는 방식을 권장한다. 시간이 모자라면 매니페스트 작성은 읽기만 하고 `apply`부터 따라 치게 한다.
- 대응표는 14일차 Compose 노트를 옆에 띄워 놓고 짚는다.
- 30분(이론 10, 실습 20).

### 토의 질문

- `selector.matchLabels`와 `template.metadata.labels`를 일부러 다르게 해서 `apply`하면 어떻게 되는가?
- `kubectl delete -f service.yaml`만 하면 Pod는 어떻게 되는가?
- 쿠버네티스의 `kind`와 도구 `kind`는 무엇이 다른가?

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `kubectl apply`를 세 번 연속 쳤다. 두 번째와 세 번째 출력은 무엇인가? 왜 그런가?
- [ ] Compose의 `restart: unless-stopped`에 해당하는 줄이 매니페스트에 없다. 왜 없어도 되는가?
- [ ] 명령으로 만드는 것과 파일로 적어 `apply`하는 것 중 팀 작업에 맞는 쪽은 무엇인가? 이유와 함께 적는다.
