# 2. 설정과 비밀 — ConfigMap 과 Secret ⭐

> 상위: [16일차 · 쿠버네티스로 배포하기](README.md) · 대본 [STEP 2](commands.md)

## 🎯 학습 목표

- 14일차 **`.env`** 가 쿠버네티스에서 어디로 가는지 안다
- **ConfigMap**(설정)과 **Secret**(비밀)을 구분해서 만든다
- 🚨 **Secret 은 암호화가 아니다**를 직접 확인한다 ⭐⭐
- 매니페스트는 올리고 **값은 안 올리는** 방법을 안다 (13 · 14일차 회수)

## 🌉 다리 놓기: `.env` 는 어디로 갔나

14일차 `compose.yaml` 을 다시 보자.

```yaml
  db:
    image: mariadb
    environment:
      MARIADB_ROOT_PASSWORD: ${DB_PASSWORD}     # ← .env 에서 온다
```

그리고 우리는 이렇게 정리했다. **구조는 공개, 값은 비공개.** `compose.yaml` 과 `.env.example` 은 커밋하고, `.env` 는 `.gitignore` 에 넣었다.

> 🗣 **"쿠버네티스에서도 생각은 똑같습니다. 그릇의 이름만 둘로 나뉩니다."**

---

## 📖 ① 둘로 나뉜다

| | **ConfigMap** | **Secret** |
|---|---|---|
| 담는 것 | 설정값 (포트·모드·문구) | **비밀** (비밀번호·토큰·키) |
| 예 | `SITE_TITLE=코리아IT` | `DB_PASSWORD=...` |
| 저장 형태 | 평문 | **base64 로 인코딩** |
| 🚨 암호화되나 | 아니다 | **아니다** ⭐ |

> 📌 **왜 나눴나?** 쓰임이 다르기 때문이다. Secret 은 **다루는 규칙을 따로 걸 수 있다**(누가 볼 수 있는지 등). 값 자체가 안전해지는 것은 아니다.

---

## 📖 ② ConfigMap — 설정

```bash
kubectl create configmap site-config \
  --from-literal=SITE_TITLE="코리아IT 네트워크 2" \
  --from-literal=SITE_ENV=class

kubectl get configmap site-config -o yaml
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: site-config
data:
  SITE_TITLE: 코리아IT 네트워크 2
  SITE_ENV: class
```

> 📌 **그냥 보인다.** 설정이니까 보여도 된다.

---

## 📖 ③ Secret — 그리고 🚨 base64 는 암호가 아니다 ⭐⭐

```bash
kubectl create secret generic db-secret \
  --from-literal=DB_PASSWORD='example-password'

kubectl get secret db-secret -o yaml
```

```yaml
data:
  DB_PASSWORD: ZXhhbXBsZS1wYXNzd29yZA==
```

**암호처럼 보인다. 풀어 보자.**

```bash
echo 'ZXhhbXBsZS1wYXNzd29yZA==' | base64 -d
```

```
example-password
```

> 🚨🚨 **한 줄로 풀렸다.** base64 는 **암호화가 아니라 표현 방식**이다. 아무나 되돌릴 수 있다.

> 🗣 **"Secret 이라는 이름에 속으면 안 됩니다. 이건 '숨긴 것'이 아니라 '다르게 적은 것'입니다."**

| 잘못된 믿음 | 실제 |
|-------------|------|
| "Secret 이니까 안전하다" | **base64 는 1초면 풀린다** |
| "매니페스트에 Secret 을 적어 커밋해도 된다" | 🚨 **절대 안 된다** — 13일차 `.env` 사고 그대로 |
| "클러스터에 넣었으니 끝" | 볼 수 있는 사람은 다 본다 |

> ⭐ **13일차 Q3 의 그 교훈이 한 층 올라온 것이다.** 비밀은 **커밋하면 지워도 이력에 남는다.** Secret 매니페스트도 **파일로 만들어 커밋하면 똑같다.**

### 그래서 어떻게 하나

```bash
# ○ 명령으로 만든다 (파일로 안 남는다)
kubectl create secret generic db-secret --from-literal=DB_PASSWORD='...'

# ○ 또는 .env 처럼 값 파일을 .gitignore 에 두고 거기서 읽는다
kubectl create secret generic db-secret --from-env-file=.env
```

> 📌 실무에서는 **외부 비밀 저장소**(Vault·클라우드 Secret Manager)를 붙이거나, 암호화해서 커밋하는 도구를 쓴다. **"그런 자리가 있다"** 까지만 안다.
> 🚨 **`.env` 는 여전히 `.gitignore` 에.** 쿠버네티스를 쓴다고 그 규칙이 사라지지 않는다.

---

## 📖 ④ Pod 에 넣는다

```yaml
    spec:
      containers:
      - name: mysite
        image: mysite:1.0
        imagePullPolicy: IfNotPresent
        env:
        - name: SITE_TITLE                    # ConfigMap 에서 하나
          valueFrom:
            configMapKeyRef:
              name: site-config
              key: SITE_TITLE
        - name: DB_PASSWORD                   # Secret 에서 하나
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: DB_PASSWORD
```

**통째로 넣는 짧은 방법도 있다.**

```yaml
        envFrom:
        - configMapRef:
            name: site-config
        - secretRef:
            name: db-secret
```

```bash
kubectl apply -f k8s/deployment.yaml
kubectl exec -it <Pod 이름> -- env | grep -E 'SITE_|DB_'
```

```
SITE_TITLE=코리아IT 네트워크 2
SITE_ENV=class
DB_PASSWORD=example-password
```

> ⭐ 14일차 `docker run -e KEY=VALUE` 가 **한 겹 분리된 것**이다. 값은 바깥(ConfigMap·Secret)에, 매니페스트에는 **어디서 가져올지만** 적는다.

---

## 📖 ⑤ 14일차와 나란히

| | 14일차 (Compose) | 16일차 (쿠버네티스) |
|---|---|---|
| 설정값 | `environment:` 에 직접 | **ConfigMap** |
| 비밀 | `.env` + `${DB_PASSWORD}` | **Secret** |
| 커밋하는 것 | `compose.yaml` · `.env.example` | **매니페스트** (값은 빼고) |
| 커밋 안 하는 것 | **`.env`** | **Secret 의 실제 값** |
| 원칙 | **구조는 공개, 값은 비공개** | **같다** ⭐ |

---

## 🧪 실습 / 질문

- `kubectl get secret ... -o yaml` 의 값을 `base64 -d` 로 풀어 보자. 무엇이 보이나?
- Secret 매니페스트를 파일로 만들어 Git 에 커밋하면 무슨 일이 생기나? (13일차 Q3)
- ConfigMap 의 값을 바꾸면 이미 떠 있는 Pod 에 **바로** 반영될까?
- `envFrom` 과 `valueFrom` 은 각각 언제 쓰나?
- 14일차 `.env` 와 오늘 Secret 중, **더 안전한** 쪽은? (함정 문제다)

## 📝 강의 메모

- ⭐⭐ **③의 `base64 -d` 한 줄이 이 절의 전부다.** 반드시 전원이 직접 쳐서 **자기 비밀번호가 풀리는 걸** 본다
  - 🗣 **"Secret 이라는 이름에 속지 마세요"** 를 칠판에 적어 둘 것
- ⭐ 13일차 Q3(비밀은 이력에 남는다)을 **다시 띄워 놓고** 짚는다. 세 번째 반복이다
- ⚠️ `valueFrom` YAML 은 들여쓰기가 깊어 오타가 많다 → **강사가 파일 공유**, 학생은 키 이름만 고치게
- ⚠️ ConfigMap 을 바꿔도 **이미 뜬 Pod 의 환경변수는 안 바뀐다**(Pod 를 다시 만들어야 한다). 질문이 나오면 4번 절 롤링 업데이트로 연결
- ⏱ 30분 (이론 10 + 실습 20). 시간이 모자라면 **Secret 만** 하고 ConfigMap 은 표로
