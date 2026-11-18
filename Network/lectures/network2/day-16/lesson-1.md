# 1. 내 이미지를 클러스터로 — 레지스트리 없이

> 상위: [16일차 · 쿠버네티스로 배포하고 공개하기](README.md) · 절차는 [내 이미지 올리기 실습](lesson-1-lab.md), 대본은 [STEP 1](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-16-001-DO |
| 유형 | D&O (개념) |
| 목적 | 클러스터가 이미지를 찾는 위치, 레지스트리 없이 이미지를 넣는 방법, Docker 29에서 `kind load docker-image`가 실패하는 이유, `imagePullPolicy`와 태그 고정의 이유를 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 클러스터가 이미지를 어디서 찾는지 안다.
- 내가 구운 이미지를 레지스트리 없이 클러스터에 넣는다.
- `kind load docker-image`가 실패할 때의 원인과 대안을 안다.
- `imagePullPolicy`와 태그를 고정해야 하는 이유를 설명한다.

## 1. 목적

15일차에 띄운 것은 남의 것이었다.

```bash
kubectl create deployment web --image=nginx
```

`nginx`는 Docker Hub에 있는 이미지이다. 클러스터가 인터넷에서 받아 왔다. 그런데 14일차에 구운 이미지는 어디에 있는가?

```bash
docker images | grep mysite
# mysite   1.0   a1b2c3d4   2 days ago   48MB
```

내 WSL의 Docker 안에만 있다. 클러스터는 이것을 모른다. 이 문서는 내 이미지를 클러스터가 쓸 수 있게 넣는 방법과, 넣었는데도 실패하는 경우를 설명한다.

## 2. 구성 요소

### 클러스터가 이미지를 찾는 순서

```
   Pod를 만들라고 하면
        │
        ▼
   노드에 그 이미지가 있나?  ──있다──▶  그것을 쓴다
        │ 없다
        ▼
   레지스트리에서 받는다 (Docker Hub 등)  ──못 받으면──▶  ErrImagePull
```

노드가 본다. 내 WSL의 Docker가 아니라 kind 노드 컨테이너 안의 이미지 목록을 본다. 15일차에 배운 대로 노드는 컨테이너 한 개이다. 그 안은 내 Docker와 별개의 공간이다.

### 이미지를 넣는 방법 둘

| 방법 | 어떻게 | 언제 |
|---|---|---|
| 레지스트리에 올린다 | `docker push`로 Docker Hub에 올린다 | 실무의 정석. 계정과 공개 설정이 필요하다 |
| 노드에 직접 넣는다 | `kind load` | 수업과 개발용. 계정이 필요 없다 |

오늘은 아래쪽으로 간다. 14일차에 Docker Hub 계정을 만들지 않았기 때문이다.

### `kind load docker-image`가 실패할 수 있다

교과서적인 명령은 다음이다.

```bash
kind load docker-image mysite:1.0 --name student
```

다음 오류로 끝날 수 있다.

```
ERROR: failed to load image: ... ctr: content digest sha256:...: not found
```

원인은 14일차에 깔린 Docker 29이다. Docker Engine 29부터 새로 설치하면 이미지 저장 방식(containerd 이미지 저장소)이 기본으로 바뀌었다. `kind load docker-image`가 아직 그 방식에서 이미지를 꺼내지 못하는 경우가 있다.

### 대안: 파일로 떠서 넣는다

```bash
docker image save --platform linux/amd64 -o /tmp/mysite.tar mysite:1.0
kind load image-archive /tmp/mysite.tar --name student
```

노드 안에 들어갔는지 확인한다.

```bash
docker exec student-control-plane crictl images | grep mysite
```

| 부분 | 뜻 |
|---|---|
| `save` | 이미지를 하나의 파일(tar)로 뜬다. 12일차에 `scp`로 파일을 옮기던 감각 그대로이다 |
| `kind load image-archive` | 그 파일을 노드에 넣는다 |
| `--platform linux/amd64` | 어느 CPU용 이미지인지 못 박는다. 빼면 여러 개가 섞여 같은 오류가 날 수 있다 |

교과서에 한 줄로 적힌 것이 안 될 때가 있다. 그때 왜 안 되는지 알면 두 줄로 돌아갈 수 있다.

### 태그와 `imagePullPolicy`

```bash
kubectl create deployment mysite --image=mysite:1.0
kubectl get pods
```

이미지를 노드에 넣지 않았다면 다음처럼 보인다.

```
NAME                      READY   STATUS             RESTARTS   AGE
mysite-7c9d8f6b5-2xk4p    0/1     ErrImagePull       0          15s
```

원인은 `describe`로 본다(15일차 B안에서 배운 그 자리).

```bash
kubectl describe pod <Pod 이름> | tail -15
```

```
  Warning  Failed  ...  Failed to pull image "mysite:1.0": ...
```

이미지를 노드에 넣은 뒤에는 태그가 결과를 가른다.

| 이미지 태그 | 기본 `imagePullPolicy` | 결과 |
|---|---|---|
| `mysite:1.0` (고정 태그) | `IfNotPresent` | 노드에 있으면 그것을 쓴다 (성공) |
| `mysite:latest` 또는 태그 없음 | `Always` | 매번 밖에서 받으려 한다 (실패) |

`latest`를 쓰면 안 되는 이유가 여기서 나온다. "항상 최신을 받아라"로 해석되어, 로컬에 있어도 무시하고 레지스트리를 찾는다. 14일차에 `mysite:1.0`처럼 태그를 올려 쓰라고 한 이유가 오늘 증명된다.

{% hint style="info" %}
NOTE: 원본은 노드에 `mysite:1.0`을 넣은 뒤에도 `mysite:1.0` 배포가 `ErrImagePull`이 되는 것처럼 적었다. 고정 태그는 기본 정책이 `IfNotPresent`이므로 노드에 넣었다면 `Running`이 된다. 위 `ErrImagePull` 출력은 이미지를 넣지 않은 경우 또는 `latest` 태그의 경우로 정정했다.
{% endhint %}

매니페스트로 정책을 못 박으면 확실하다.

```yaml
      containers:
      - name: mysite
        image: mysite:1.0
        imagePullPolicy: IfNotPresent     # 노드에 있으면 그것을 쓴다
        ports:
        - containerPort: 80
```

## 3. 동작 원리

1. 14일차에 만든 이미지가 내 Docker에 있다.
2. `docker image save`가 이미지를 tar 파일로 뜬다.
3. `kind load image-archive`가 tar를 kind 노드 컨테이너 안의 이미지 저장소에 넣는다.
4. `kubectl apply`로 Deployment를 만든다. 노드는 이미지 목록에서 `mysite:1.0`을 찾는다.
5. 고정 태그이므로 `IfNotPresent`가 적용되어 노드의 이미지를 쓴다. Pod가 `Running`이 된다.
6. `kubectl port-forward`로 확인하면 13일차에 만든 포트폴리오가 보인다.

```
 13일차   코드를 Git에
 14일차   + 돌리는 방법 (Dockerfile)   → 이미지로 구웠다
 15일차   + 원하는 상태 (매니페스트)    → 클러스터를 세웠다
 16일차   그 이미지를 그 클러스터에       오늘
```

14일차 이미지가 없으면 저장소에서 다시 굽는다. 저장소만 있으면 어느 PC에서든 같은 이미지가 나온다. 14일차에 증명하려던 바로 그것이다.

## 4. 약어와 용어

| 용어 | 뜻 |
|---|---|
| 레지스트리(registry) | 이미지를 저장하고 내려받는 서버. Docker Hub가 대표적이다 |
| `kind load` | kind 노드 컨테이너에 이미지를 직접 넣는 명령 |
| `image-archive` | tar 파일로 뜬 이미지를 노드에 넣는 `kind load`의 하위 명령 |
| `ErrImagePull` | 노드에 이미지가 없고 레지스트리에서도 받지 못했을 때의 Pod 상태 |
| `imagePullPolicy` | 이미지를 언제 받을지 정하는 필드. `IfNotPresent`, `Always`, `Never` |
| containerd 이미지 저장소 | Docker 29부터 새 설치의 기본 이미지 저장 방식 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 노드가 보는 이미지 목록 | 노드가 보는 이미지 목록은 내 Docker의 목록과 다르다. 판서로 그린다 |

## 강의 메모

- 오늘의 승부처이다. 여기서 막히면 3번 절까지 전부 밀린다.
- `kind load docker-image`가 실패할 수 있다는 것을 먼저 말하고 들어간다. 실패를 보고 당황하는 것보다 "이렇게 될 수 있다"를 듣고 만나는 것이 낫다. 대본은 처음부터 `save`와 `image-archive`로 가고, `docker-image`는 "짧은 길인데 될 때도 있다"로 소개한다.
- `ErrImagePull`을 일부러 한 번 만든다. `latest` 태그로 만든다. 그래야 `imagePullPolicy`가 머리에 남는다. 10, 12, 13, 14일차 포트 충돌처럼 일부러 내는 오류가 가장 잘 남는다.
- `crictl images` 출력이 길다. `| grep mysite`로 자른다.
- 복구 경로(이미지 다시 굽기)는 STEP 0에서 미리 돌려 둔다. 1번 절에 와서 시작하면 늦다.
- 이론 10분, 실습 25분으로 35분이다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `docker images`에는 보이는데 클러스터는 못 찾는다. 두 목록이 다른 이유를 내 말로 설명해 보자.
- [ ] 실무에서는 왜 `kind load`가 아니라 레지스트리를 쓸까?
- [ ] `docker image save`로 뜬 `.tar`를 USB에 담아 가면 인터넷 없는 PC에서도 쓸 수 있을까? 어떤 경우에 쓰고 싶은가?
