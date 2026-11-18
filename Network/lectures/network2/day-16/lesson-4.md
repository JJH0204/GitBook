# 4. 고치고 되돌리기 — 롤링 업데이트와 롤백

> 상위: [16일차 · 쿠버네티스로 배포하고 공개하기](README.md) · 절차는 [롤링 업데이트와 롤백 실습](lesson-4-lab.md), 대본은 [STEP 4](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-16-004-DO |
| 유형 | D&O (개념) |
| 목적 | 새 태그로 이미지를 다시 굽는 이유, 롤링 업데이트가 끊김 없이 바꾸는 원리, `rollout undo`로 되돌리는 방법, 13일차와 14일차 되돌리기와의 공통점을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 코드를 고쳐 새 태그로 이미지를 다시 굽는다(14일차 회수).
- 롤링 업데이트로 끊김 없이 바꾼다.
- `rollout undo`로 되돌린다(13일차 되돌리기 회수).
- 태그를 올려 두면 되돌릴 수 있다는 것을 체감한다.

## 1. 목적

배포는 한 번으로 끝나지 않는다. 13일차에 배포의 한살이를 배웠다. 고치고, `push`하고, 서버에서 `pull`한다. 그런데 그때는 잠깐 끊겼다. 사람들이 보고 있는데 사이트를 바꿔야 한다면 끊지 않고 바꿀 수 있는가? 이 문서는 그 방법과 되돌리는 방법을 설명한다.

## 2. 구성 요소

### 고쳐서 다시 굽는다: 14일차 그대로

```bash
cd ~/myweb
nano site/index.html                     # 제목을 바꿔 본다
docker build -t mysite:1.1 .             # 태그를 올린다
docker images | grep mysite              # 1.0과 1.1이 모두 있다
```

```bash
docker image save --platform linux/amd64 -o /tmp/mysite-1.1.tar mysite:1.1
kind load image-archive /tmp/mysite-1.1.tar --name student
```

1.0을 지우지 않았다. 되돌릴 자리를 남겨 두는 것이다. 13일차 커밋과 같은 역할이다.

### 바꾼다: 롤링 업데이트

터미널 A에서 지켜본다.

```bash
kubectl get pods -w
```

터미널 B에서 바꾼다.

```bash
kubectl set image deployment/mysite mysite=mysite:1.1
kubectl rollout status deployment/mysite
```

터미널 A에서 벌어지는 일은 다음과 같다.

```
mysite-7c9d8f6b5-2xk4p   1/1   Running       ← 옛 버전
mysite-6b4a7c2d9-m8p3q   0/1   Pending       ← 새 버전이 먼저 뜬다
mysite-6b4a7c2d9-m8p3q   1/1   Running       ← 새 것이 준비되고 나서
mysite-7c9d8f6b5-2xk4p   1/1   Terminating   ← 그 다음에 옛 것이 내려간다
```

새 것이 준비된 다음에 옛 것을 내린다. 그래서 끊기지 않는다. 이것이 롤링 업데이트이다. 비유는 교대 근무이다. 다음 사람이 와서 자리에 앉은 뒤에 앞사람이 퇴근한다. 카운터가 비는 순간이 없다.

```bash
curl http://localhost:8080        # 바뀐 제목이 보인다
```

| | 13일차(`git pull`) | 14일차(컨테이너 교체) | 오늘 |
|---|---|---|---|
| 방법 | 서버에서 `pull` | `rm -f` 후 `run` | `set image` |
| 끊기나 | 잠깐 | 끊긴다 | 끊기지 않는다 |
| 되돌리기 | `git checkout` | 옛 이미지로 다시 `run` | `rollout undo` |

### 되돌린다: `rollout undo`

새 버전에 문제가 있다고 해 본다.

```bash
kubectl rollout history deployment/mysite
kubectl rollout undo deployment/mysite
kubectl rollout status deployment/mysite
curl http://localhost:8080                 # 1.0의 제목으로 돌아왔다
```

한 줄로 돌아왔다. 쿠버네티스가 직전에 무엇이었는지 기억하고 있기 때문이다. 되돌리는 것도 롤링이다. 되돌리는 동안에도 끊기지 않는다.

```bash
kubectl rollout undo deployment/mysite --to-revision=2    # 특정 지점으로
```

{% hint style="warning" %}
CAUTION: `mysite:1.0` 이미지가 노드에 남아 있어야 되돌릴 수 있다. 지워 버렸으면 돌아가지 못한다. `latest` 하나로 덮어쓰면 되돌릴 자리가 없어진다. 1번 절에서 배운 것과 같은 이유이다.
{% endhint %}

## 3. 동작 원리

롤링 업데이트의 순서는 다음과 같다.

1. `set image`가 Deployment의 이미지 필드를 `mysite:1.1`로 바꾼다.
2. 쿠버네티스가 새 버전의 Pod를 먼저 만든다.
3. 새 Pod가 `Running`이 되면 옛 Pod 하나를 `Terminating`으로 내린다.
4. 옛 Pod가 모두 내려갈 때까지 반복한다.
5. 바뀐 내용은 리비전으로 남는다. `rollout undo`는 직전 리비전을 같은 롤링 방식으로 다시 적용한다.

### 13일차에서 16일차까지

```
 13일차   커밋을 쌓는다        → 언제든 그 시점으로
 14일차   이미지 태그를 올린다  → 1.0과 1.1이 공존
 16일차   리비전이 쌓인다      → rollout undo로 한 줄
```

되돌릴 수 있게 해 두는 것. 그것이 13일차부터 오늘까지 계속 한 이야기이다.

| | 되돌리는 명령 | 되돌릴 수 있는 이유 |
|---|---|---|
| 13일차 Git | `git checkout <커밋>` | 커밋을 쌓아 뒀으니까 |
| 14일차 Docker | `docker run mysite:1.0` | 태그를 올려 뒀으니까 |
| 16일차 K8s | `kubectl rollout undo` | 리비전이 남아 있으니까 |

## 4. 약어와 용어

| 용어 | 뜻 |
|---|---|
| 롤링 업데이트(rolling update) | 새 Pod를 먼저 띄우고 옛 Pod를 하나씩 내리며 바꾸는 방식 |
| 리비전(revision) | Deployment의 변경 이력 한 칸 |
| `set image` | Deployment의 컨테이너 이미지를 바꾸는 명령 |
| `rollout undo` | 직전 리비전(또는 지정한 리비전)으로 되돌리는 명령 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 13일차, 14일차, 16일차 되돌리기 | 3절의 세 줄을 칠판에 적고 마무리한다. 판서로 그린다 |

## 강의 메모

- 터미널 A의 화면이 이 절의 전부이다. 새 Pod가 먼저 뜨고 옛 Pod가 나중에 내려가는 순서를 손가락으로 짚는다.
- 교대 근무 비유가 잘 먹힌다.
- `replicas: 1`이면 순간적으로 끊길 수 있다는 것이 원본의 설명이다. 미리 `replicas: 2`로 올려 두고 실습하면 그림이 깨끗하다.
- 3절의 표가 13, 14, 16일차를 꿰는 자리이다. 칠판에 세 줄로 적고 마무리한다.
- 이론 10분, 실습 20분으로 30분이다. 시간이 모자라면 되돌리기만 강사 시연으로 한다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 롤링 업데이트 중에 `curl`을 계속 치면 어떤 응답이 섞여 나올까? 왜 그럴까?
- [ ] 14일차에 "태그를 올리라"고 한 이유를 오늘 배운 것으로 다시 설명해 보자.
- [ ] 되돌릴 수 있게 해 두지 않아 곤란했던 경험이 있다면 적어 보자.
