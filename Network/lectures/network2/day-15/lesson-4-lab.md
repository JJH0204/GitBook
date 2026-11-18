# 매니페스트 적용 실습

> 상위: [15일차 · 쿠버네티스 입문](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-012-MP |
| 목적 | Deployment와 Service 매니페스트를 파일로 작성해 `apply`하고, 같은 파일을 두 번 적용해 `unchanged`를 확인한 뒤, 14일차 저장소에 `k8s/` 폴더로 `push`한다 |
| 적용 대상 | 첫 배포 실습(LEC-N2-15-011-MP)을 마친 WSL(Ubuntu 24.04), kind 클러스터 `student`, 14일차 저장소 `~/myweb`(GitHub 연결 완료, SSH 키 인증) |
| 소요 시간 | 약 20분(강사가 파일을 공유하면 10분 단축) |
| 확인 상태 | 미검증 (원본에 "`--dry-run=client`는 클러스터에 한 번 묻는다는 것을 실측했다"라는 기록이 있으나, 이 문서는 이번 재작성에서 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-4.md](lesson-4.md) | LEC-N2-15-004-DO | 선언형 — 매니페스트와 apply |
| [lesson-3-lab.md](lesson-3-lab.md) | LEC-N2-15-011-MP | 첫 배포 실습 |
| [commands.md](commands.md) | LEC-N2-15-009-REF | 15일차 실습 명령어 |
| [13일차 · Git 과 GitHub](../day-13/README.md) | | `git add`, `commit`, `push` |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL 터미널 | Ubuntu 24.04 | |
| 2 | 텍스트 편집기 | `nano` | YAML은 들여쓰기가 문법이다 |
| 3 | kind 클러스터 `student` | 노드 `Ready` | |
| 4 | 14일차 저장소 | `~/myweb` | 마지막 구역에서 `push` |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `selector.matchLabels`와 `template.metadata.labels`는 같아야 한다. 다르면 Deployment가 Pod를 자기 것으로 알아보지 못한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 파일 작성이 오래 걸리면 강사가 공유한 파일을 고쳐 쓴다. 시간이 모자라면 5-B를 읽기만 하고 5-C부터 한다.
{% endhint %}

{% hint style="info" %}
NOTE: 3번 실습에서 `web` Deployment와 Service를 이미 만들었다. 같은 이름의 `apply`는 기존 것을 이어받는다. 충돌이 나면 `kubectl delete deployment web`, `kubectl delete service web`을 한 뒤 5-C부터 다시 한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 클러스터가 떠 있다 | `kubectl get nodes`가 `Ready`이다 |
| 2 | `~/myweb` 저장소가 있다 | `cd ~/myweb && git status`가 오류 없이 끝난다 |

## 5. 절차

### A. 지금 만든 것을 읽기만 한다

1. (5-A-01) 현재 Deployment를 YAML로 본다: `kubectl get deployment web -o yaml | head -20` → 결과: 기본값과 현재 상태가 섞인 긴 출력이 나온다. 이 출력은 읽기만 하고 쓰지 않는다.

### B. 매니페스트 작성

1. (5-B-01) 폴더를 만든다: `mkdir -p ~/k8s && cd ~/k8s`
2. (5-B-02) 편집기를 연다: `nano deployment.yaml`
3. (5-B-03) 다음 내용을 입력하고 저장한다.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

4. (5-B-04) 두 `app: web`(`selector.matchLabels`와 `template.metadata.labels`)이 같은지 눈으로 확인한다.
5. (5-B-05) 편집기를 연다: `nano service.yaml`
6. (5-B-06) 다음 내용을 입력하고 저장한다.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
```

### C. 적용

1. (5-C-01) 문법을 먼저 검사한다: `kubectl apply -f deployment.yaml --dry-run=client` → 결과: `deployment.apps/web created (dry run)` 또는 `configured (dry run)`이 출력된다. 클러스터가 죽어 있으면 `connection refused`가 나온다(문법 오류가 아니다).
2. (5-C-02) Deployment를 적용한다: `kubectl apply -f deployment.yaml`
3. (5-C-03) Service를 적용한다: `kubectl apply -f service.yaml`
4. (5-C-04) 결과를 본다: `kubectl get deploy,svc,pods` → 결과: Deployment `web`, Service `web`, Pod 1개가 보인다.

### D. 같은 파일을 두 번 적용

1. (5-D-01) 다시 적용한다: `kubectl apply -f deployment.yaml` → 결과: `deployment.apps/web unchanged`가 출력된다. 이미 그 상태이므로 아무 일도 일어나지 않는다.

### E. Git에 넣기

1. (5-E-01) 저장소로 이동한다: `cd ~/myweb`
2. (5-E-02) 폴더를 만들고 복사한다: `mkdir -p k8s && cp ~/k8s/*.yaml k8s/`
3. (5-E-03) 스테이지에 담는다: `git add k8s/`
4. (5-E-04) 커밋한다: `git commit -m "쿠버네티스 매니페스트 추가"` → 결과: 커밋 요약이 출력된다.
5. (5-E-05) 올린다: `git push` → 결과: 오류 없이 끝난다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kubectl get deploy,svc,pods` | Deployment, Service, Pod | Pod STATUS가 `Running` |
| 2 | `kubectl apply -f deployment.yaml` 재실행 | `unchanged` | 출력에 `unchanged`가 있다 |
| 3 | GitHub 저장소 화면 | `k8s/` 폴더 | `deployment.yaml`, `service.yaml`이 보인다 |

## 7. 복구

1. (7-01) 적용한 것을 내린다: `kubectl delete -f ~/k8s/` → 결과: Deployment와 Service가 삭제된다.

{% hint style="info" %}
NOTE: 다음 실습(Pod 삭제와 스케일)에서 `web`을 계속 쓰므로, 이어서 진행한다면 지우지 않는다. `k8s/` 폴더는 16일차에 그대로 쓰므로 `push`한 커밋을 되돌리지 않는다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-4.md`와 `commands.md`의 STEP 4 실습을 분리해 AMM 형식으로 재작성 |
