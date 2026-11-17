# 4. 고치고 되돌리기 — 롤링 업데이트와 롤백 ⭐

> 상위: [16일차 · 쿠버네티스로 배포하기](README.md) · 대본 [STEP 4](commands.md)

## 🎯 학습 목표

- 코드를 고쳐 **새 태그로 이미지를 다시 굽는다** (14일차 회수)
- **롤링 업데이트**로 **끊김 없이** 바꾼다 ⭐
- **`rollout undo`** 로 되돌린다 (13일차 되돌리기 회수) ⭐
- **태그를 올려 두면 되돌릴 수 있다**는 것을 체감한다

## 🌉 다리 놓기: 배포는 한 번으로 끝나지 않는다

13일차에 배포의 한살이를 배웠다. **고치고 → push → 서버에서 pull.** 그런데 그때는 **잠깐 끊겼다.**

> 🗣 **"사람들이 보고 있는데 사이트를 바꿔야 합니다. 끊지 않고 바꿀 수 있을까요?"**

---

## 📖 ① 고쳐서 다시 굽는다 — 14일차 그대로

```bash
cd ~/myweb
nano site/index.html                     # 제목을 바꿔 본다
docker build -t mysite:1.1 .             # ⭐ 태그를 올린다
docker images | grep mysite              # 1.0 과 1.1 이 모두 있다
```

```bash
docker image save --platform linux/amd64 -o /tmp/mysite-1.1.tar mysite:1.1
kind load image-archive /tmp/mysite-1.1.tar --name student
```

> ⭐ **1.0 을 지우지 않았다.** 되돌릴 자리를 남겨 두는 것이다. 13일차 커밋과 같은 역할이다.

---

## 📖 ② 바꾼다 — 롤링 업데이트 ⭐

**터미널 A** 에서 지켜본다.

```bash
kubectl get pods -w
```

**터미널 B** 에서 바꾼다.

```bash
kubectl set image deployment/mysite mysite=mysite:1.1
kubectl rollout status deployment/mysite
```

**터미널 A 에서 벌어지는 일**

```
mysite-7c9d8f6b5-2xk4p   1/1   Running       ← 옛 버전
mysite-6b4a7c2d9-m8p3q   0/1   Pending       ← 새 버전이 먼저 뜬다
mysite-6b4a7c2d9-m8p3q   1/1   Running       ← 새 것이 준비되고 나서
mysite-7c9d8f6b5-2xk4p   1/1   Terminating   ⭐ 그 다음에 옛 것이 내려간다
```

> ⭐⭐ **새 것이 준비된 다음에 옛 것을 내린다.** 그래서 **끊기지 않는다.** 이것이 **롤링 업데이트**다.
> 💡 **비유: 교대 근무.** 다음 사람이 와서 자리에 앉은 뒤에 앞사람이 퇴근한다. 카운터가 비는 순간이 없다.

```bash
curl http://localhost:8080        # 바뀐 제목이 보인다
```

| | 13일차 (`git pull`) | 14일차 (컨테이너 교체) | 오늘 |
|---|---|---|---|
| 방법 | 서버에서 `pull` | `rm -f` 후 `run` | **`set image`** |
| 끊기나 | 잠깐 | **끊긴다** | **안 끊긴다** ⭐ |
| 되돌리기 | `git checkout` | 옛 이미지로 다시 `run` | **`rollout undo`** |

---

## 📖 ③ 되돌린다 — `rollout undo` ⭐

새 버전에 문제가 있다고 해 보자.

```bash
kubectl rollout history deployment/mysite
kubectl rollout undo deployment/mysite
kubectl rollout status deployment/mysite
curl http://localhost:8080                 # 1.0 의 제목으로 돌아왔다 ⭐
```

> ⭐ **한 줄로 돌아왔다.** 쿠버네티스가 **직전에 무엇이었는지 기억**하고 있기 때문이다.
> 📌 되돌리는 것도 **롤링**이다. 되돌리는 동안에도 안 끊긴다.

```bash
kubectl rollout undo deployment/mysite --to-revision=2    # 특정 지점으로
```

> ⚠️ **`mysite:1.0` 이미지가 노드에 남아 있어야** 되돌릴 수 있다. 지워 버렸으면 못 돌아간다.
> 🚨 **그래서 `latest` 하나로 덮어쓰면 안 된다.** 되돌릴 자리가 없어진다. 1번 절에서 배운 것과 **같은 이유**다.

---

## 📖 ④ 13일차와 한 줄로

```
 13일차   커밋을 쌓는다        → 언제든 그 시점으로
 14일차   이미지 태그를 올린다  → 1.0 과 1.1 이 공존
 16일차   리비전이 쌓인다      → rollout undo 로 한 줄  ⭐
```

> 🗣 **"되돌릴 수 있게 해 두는 것. 그게 13일차부터 오늘까지 계속 한 이야기입니다."**

| | 되돌리는 명령 | 되돌릴 수 있는 이유 |
|---|---|---|
| 13일차 Git | `git checkout <커밋>` | **커밋을 쌓아 뒀으니까** |
| 14일차 Docker | `docker run mysite:1.0` | **태그를 올려 뒀으니까** |
| 16일차 K8s | `kubectl rollout undo` | **리비전이 남아 있으니까** |

---

## 🧪 실습 / 질문

- 롤링 업데이트 중에 `curl` 을 계속 치면 어떤 응답이 섞여 나올까? 왜 그럴까?
- `replicas: 1` 일 때도 정말 안 끊길까? (해보고 생각해 보자)
- `kubectl rollout undo` 를 두 번 연속 치면 어떻게 되나?
- `mysite:1.0` 을 노드에서 지운 뒤 `undo` 하면?
- 14일차에 "태그를 올리라"고 한 이유를 오늘 말로 다시 설명해 보자

## 📝 강의 메모

- ⭐⭐ **②의 터미널 A 화면이 이 절의 전부다.** 새 Pod 가 먼저 뜨고 옛 Pod 가 나중에 내려가는 **순서**를 손가락으로 짚는다
- ⭐ **교대 근무 비유**가 잘 먹힌다
- ⚠️ `replicas: 1` 이면 순간적으로 끊길 수 있다 → **미리 `replicas: 2` 로** 올려 두고 실습하면 그림이 깨끗하다
- ⭐ **④의 표가 13 → 14 → 16일차를 꿰는 자리**다. 칠판에 세 줄로 적고 마무리
- ⏱ 30분 (이론 10 + 실습 20). 시간이 모자라면 **③만 강사 시연**
