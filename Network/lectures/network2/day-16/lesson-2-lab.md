# ConfigMap과 Secret 실습

> 상위: [16일차 · 쿠버네티스로 배포하고 공개하기](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-16-010-MP |
| 목적 | ConfigMap과 Secret을 만들고, Secret의 base64 값을 직접 풀어 보고, 두 오브젝트를 Pod의 환경변수로 넣어 확인한다 |
| 적용 대상 | Windows 10/11의 WSL(Ubuntu 24.04), kind 클러스터 `student`, `mysite` Deployment가 떠 있는 상태 |
| 소요 시간 | 약 30분 |
| 확인 상태 | 미검증 (원본 대본을 정리한 것이며 클러스터에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-2.md](lesson-2.md) | LEC-N2-16-002-DO | 설정과 비밀 |
| [lesson-1-lab.md](lesson-1-lab.md) | LEC-N2-16-009-MP | 내 이미지 올리기 실습 |
| [commands.md](commands.md) | LEC-N2-16-007-REF | 16일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL(Ubuntu) | 24.04 | 터미널 한 개 |
| 2 | `~/myweb/k8s/deployment.yaml` | 내 이미지 올리기 실습에서 만든 것 | 5-C에서 고친다 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 실습용 비밀번호는 실제로 쓰는 비밀번호를 넣지 않는다. 임의의 실습용 문자열을 쓴다. Secret의 값은 base64로 풀리므로 파일로 만들어 Git에 커밋하지 않는다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `mysite` Deployment가 떠 있다 | `kubectl get pods`에서 `mysite-...`가 `Running`이다 |
| 2 | 매니페스트 파일이 있다 | `ls ~/myweb/k8s/deployment.yaml`이 파일을 출력한다 |

## 5. 절차

### A. 만든다

1. (5-A-01) ConfigMap을 만든다: `kubectl create configmap site-config --from-literal=SITE_TITLE="코리아IT 네트워크 2" --from-literal=SITE_ENV=class` → 결과: `configmap/site-config created`.
2. (5-A-02) Secret을 만든다: `kubectl create secret generic db-secret --from-literal=DB_PASSWORD='<password>'` → 결과: `secret/db-secret created`. `<password>`는 임의의 실습용 문자열로 바꾼다.

### B. base64는 암호가 아니다: 전원이 직접 친다

1. (5-B-01) Secret의 값을 본다: `kubectl get secret db-secret -o yaml | grep DB_PASSWORD` → 결과: `DB_PASSWORD:` 뒤에 base64 문자열이 보인다.
2. (5-B-02) 값을 푼다: `echo '<base64 문자열>' | base64 -d` → 결과: 5-A-02에서 넣은 실습용 문자열이 그대로 출력된다. `<base64 문자열>`은 5-B-01에서 본 각자의 값으로 바꾼다.
3. (5-B-03) ConfigMap을 본다: `kubectl get configmap site-config -o yaml` → 결과: `data:` 아래에 값이 평문으로 보인다.

### C. Pod에 넣는다

1. (5-C-01) `nano ~/myweb/k8s/deployment.yaml`로 파일을 연다.
2. (5-C-02) `imagePullPolicy` 줄 아래에 `envFrom`을 추가하고 저장한다(`Ctrl+O`, Enter, `Ctrl+X`). 들여쓰기는 `imagePullPolicy`와 같은 칸이다.

```yaml
        envFrom:
        - configMapRef:
            name: site-config
        - secretRef:
            name: db-secret
```

3. (5-C-03) 적용한다: `kubectl apply -f ~/myweb/k8s/deployment.yaml` → 결과: `deployment.apps/mysite configured`.
4. (5-C-04) 새 Pod가 뜰 때까지 확인한다: `kubectl get pods` → 결과: `mysite-...`가 `Running`이고 옛 Pod가 사라진다.
5. (5-C-05) 환경변수를 확인한다: `kubectl exec $(kubectl get pod -l app=mysite -o name | head -1) -- env | grep -E 'SITE_|DB_'` → 결과: `SITE_TITLE`, `SITE_ENV`, `DB_PASSWORD` 세 줄이 보인다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kubectl get configmap site-config` | 한 줄 | 이름이 보인다 |
| 2 | `kubectl get secret db-secret` | 한 줄 | 이름이 보인다 |
| 3 | 5-B-02의 출력 | 내가 넣은 실습용 문자열 | 한 줄로 풀렸다 |
| 4 | 5-C-05의 출력 | 환경변수 세 줄 | 세 값이 모두 보인다 |

## 7. 복구

1. (7-01) `envFrom` 네 줄을 `deployment.yaml`에서 지우고 `kubectl apply -f ~/myweb/k8s/deployment.yaml`을 다시 실행한다. → 결과: `deployment.apps/mysite configured`.
2. (7-02) ConfigMap과 Secret을 지운다: `kubectl delete configmap site-config` 와 `kubectl delete secret db-secret` → 결과: 각각 `deleted`가 출력된다.

{% hint style="warning" %}
CAUTION: `envFrom`이 가리키는 ConfigMap이나 Secret을 먼저 지우면 새 Pod가 `CreateContainerConfigError`로 뜨지 않을 수 있다. 7-01을 먼저 하고 7-02를 한다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 `lesson-2.md`와 `commands.md`의 실습 항목을 AMM 형식으로 재작성. 복구 절을 추가했다. 실습용 비밀번호를 `<password>`로 바꿨다 |
