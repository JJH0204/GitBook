# 2. 설정과 비밀 — ConfigMap 과 Secret

> 상위: [16일차 · 쿠버네티스로 배포하고 공개하기](README.md) · 절차는 [ConfigMap과 Secret 실습](lesson-2-lab.md), 대본은 [STEP 2](commands.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-16-002-DO |
| 유형 | D&O (개념) |
| 목적 | 14일차 `.env`가 쿠버네티스에서 ConfigMap과 Secret으로 나뉘는 방식, Secret이 암호화가 아니라는 사실, 매니페스트는 올리고 값은 올리지 않는 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- 14일차 `.env`가 쿠버네티스에서 어디로 가는지 안다.
- ConfigMap(설정)과 Secret(비밀)을 구분해서 만든다.
- Secret은 암호화가 아니라는 것을 직접 확인한다.
- 매니페스트는 올리고 값은 올리지 않는 방법을 안다(13일차, 14일차 회수).

## 1. 목적

14일차 `compose.yaml`을 다시 본다.

```yaml
  db:
    image: mariadb
    environment:
      MARIADB_ROOT_PASSWORD: ${DB_PASSWORD}     # .env에서 온다
```

그리고 다음과 같이 정리했다. 구조는 공개, 값은 비공개이다. `compose.yaml`과 `.env.example`은 커밋하고, `.env`는 `.gitignore`에 넣었다. 쿠버네티스에서도 생각은 같다. 그릇의 이름만 둘로 나뉜다.

## 2. 구성 요소

### ConfigMap과 Secret

| | ConfigMap | Secret |
|---|---|---|
| 담는 것 | 설정값(포트, 모드, 문구) | 비밀(비밀번호, 토큰, 키) |
| 예 | `SITE_TITLE=코리아IT` | `DB_PASSWORD=<password>` |
| 저장 형태 | 평문 | base64로 인코딩 |
| 암호화되나 | 아니다 | 아니다 |

둘을 나눈 이유는 쓰임이 다르기 때문이다. Secret은 다루는 규칙을 따로 걸 수 있다(누가 볼 수 있는지 등). 값 자체가 안전해지는 것은 아니다.

### ConfigMap: 설정

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

그냥 보인다. 설정이니까 보여도 된다.

### Secret: base64는 암호가 아니다

```bash
kubectl create secret generic db-secret \
  --from-literal=DB_PASSWORD='<password>'

kubectl get secret db-secret -o yaml
```

```yaml
data:
  DB_PASSWORD: PHBhc3N3b3JkPg==
```

암호처럼 보인다. 풀어 본다.

```bash
echo 'PHBhc3N3b3JkPg==' | base64 -d
```

```
<password>
```

한 줄로 풀렸다. base64는 암호화가 아니라 표현 방식이다. 아무나 되돌릴 수 있다. Secret이라는 이름에 속으면 안 된다. 이것은 "숨긴 것"이 아니라 "다르게 적은 것"이다.

{% hint style="info" %}
NOTE: 위 출력은 값으로 문자열 `<password>`를 그대로 넣었을 때의 예이다. 실습에서는 `<password>` 자리에 임의의 실습용 문자열을 쓴다. 출력되는 base64 값은 그 문자열에 따라 달라진다.
{% endhint %}

| 잘못된 믿음 | 실제 |
|---|---|
| "Secret이니까 안전하다" | base64는 1초면 풀린다 |
| "매니페스트에 Secret을 적어 커밋해도 된다" | 안 된다. 13일차 `.env` 사고와 같다 |
| "클러스터에 넣었으니 끝" | 볼 수 있는 사람은 다 본다 |

13일차 Q3의 교훈이 한 층 올라온 것이다. 비밀은 커밋하면 지워도 이력에 남는다. Secret 매니페스트도 파일로 만들어 커밋하면 똑같다.

{% hint style="danger" %}
WARNING: Secret의 실제 값을 파일로 만들어 Git에 커밋하지 않는다. 커밋하면 파일을 지워도 이력에 남는다. 쿠버네티스를 쓴다고 `.env`를 `.gitignore`에 넣는 규칙이 사라지지 않는다.
{% endhint %}

그래서 다음과 같이 한다.

```bash
# 명령으로 만든다 (파일로 안 남는다)
kubectl create secret generic db-secret --from-literal=DB_PASSWORD='<password>'

# 또는 .env처럼 값 파일을 .gitignore에 두고 거기서 읽는다
kubectl create secret generic db-secret --from-env-file=.env
```

실무에서는 외부 비밀 저장소(Vault, 클라우드 Secret Manager)를 붙이거나, 암호화해서 커밋하는 도구를 쓴다. "그런 자리가 있다"까지만 안다.

### Pod에 넣는다

```yaml
    spec:
      containers:
      - name: mysite
        image: mysite:1.0
        imagePullPolicy: IfNotPresent
        env:
        - name: SITE_TITLE                    # ConfigMap에서 하나
          valueFrom:
            configMapKeyRef:
              name: site-config
              key: SITE_TITLE
        - name: DB_PASSWORD                   # Secret에서 하나
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: DB_PASSWORD
```

통째로 넣는 짧은 방법도 있다.

```yaml
        envFrom:
        - configMapRef:
            name: site-config
        - secretRef:
            name: db-secret
```

Pod 안에서 확인한다.

```bash
kubectl exec <Pod 이름> -- env | grep -E 'SITE_|DB_'
```

```
SITE_TITLE=코리아IT 네트워크 2
SITE_ENV=class
DB_PASSWORD=<password>
```

14일차 `docker run -e KEY=VALUE`가 한 겹 분리된 것이다. 값은 바깥(ConfigMap, Secret)에 두고, 매니페스트에는 어디서 가져올지만 적는다.

{% hint style="info" %}
NOTE: 원본은 `kubectl exec -it <Pod> -- env | grep ...`이었다. 출력을 파이프로 넘기면 `-it`의 TTY 옵션이 의미가 없고 경고가 날 수 있어 `-it`를 뺐다.
{% endhint %}

## 3. 동작 원리

1. 설정값은 ConfigMap, 비밀은 Secret으로 클러스터에 만든다. 값은 명령에서 직접 넣고 파일로 남기지 않는다.
2. Deployment 매니페스트는 `valueFrom` 또는 `envFrom`으로 어디서 가져올지만 적는다.
3. Pod가 만들어질 때 값이 환경변수로 주입된다.
4. 이미 떠 있는 Pod의 환경변수는 ConfigMap을 바꿔도 바뀌지 않는다. Pod를 다시 만들어야 반영된다. 이것은 4번 절 롤링 업데이트로 이어진다.

### 14일차와 나란히

| | 14일차(Compose) | 16일차(쿠버네티스) |
|---|---|---|
| 설정값 | `environment:`에 직접 | ConfigMap |
| 비밀 | `.env`와 `${DB_PASSWORD}` | Secret |
| 커밋하는 것 | `compose.yaml`, `.env.example` | 매니페스트(값은 빼고) |
| 커밋 안 하는 것 | `.env` | Secret의 실제 값 |
| 원칙 | 구조는 공개, 값은 비공개 | 같다 |

## 4. 약어와 용어

| 용어 | 뜻 |
|---|---|
| ConfigMap | 설정값을 키와 값으로 담는 쿠버네티스 오브젝트. 평문 |
| Secret | 비밀을 담는 오브젝트. base64로 인코딩될 뿐 암호화되지 않는다 |
| base64 | 바이트를 문자로 바꿔 적는 표현 방식. 암호화가 아니다 |
| `valueFrom` | 환경변수 하나를 ConfigMap 또는 Secret의 키 하나에서 가져온다 |
| `envFrom` | ConfigMap 또는 Secret 전체를 환경변수로 넣는다 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 14일차와 16일차 비교 | 위 3절 표를 칠판에 옮긴다. 판서로 그린다 |

## 강의 메모

- 3절의 `base64 -d` 한 줄이 이 절의 전부이다. 전원이 직접 쳐서 자기 비밀번호가 풀리는 것을 본다. "Secret이라는 이름에 속지 마세요"를 칠판에 적어 둔다.
- 13일차 Q3(비밀은 이력에 남는다)을 다시 띄워 놓고 짚는다. 세 번째 반복이다.
- `valueFrom` YAML은 들여쓰기가 깊어 오타가 많다. 강사가 파일을 공유하고 학생은 키 이름만 고치게 한다.
- ConfigMap을 바꿔도 이미 뜬 Pod의 환경변수는 바뀌지 않는다(Pod를 다시 만들어야 한다). 질문이 나오면 4번 절 롤링 업데이트로 연결한다.
- 이론 10분, 실습 20분으로 30분이다. 시간이 모자라면 Secret만 하고 ConfigMap은 표로 넘긴다.

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] Secret 매니페스트를 파일로 만들어 Git에 커밋하면 무슨 일이 생기는지 내 말로 설명해 보자.
- [ ] `envFrom`과 `valueFrom`은 각각 언제 쓰고 싶은가? 이유는 무엇인가?
- [ ] 14일차 `.env`와 오늘 Secret 중 더 안전한 쪽은 어디인가? 그렇게 생각한 이유는 무엇인가?
