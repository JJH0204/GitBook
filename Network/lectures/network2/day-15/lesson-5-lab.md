# Pod 삭제와 스케일 실습

> 상위: [15일차 · 쿠버네티스 입문](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-013-MP |
| 목적 | Pod를 삭제해 새 Pod(다른 이름)가 생기는 것을 확인하고, `kubectl scale`로 개수를 바꾼 뒤 파일 수정과 `apply`로 개수를 정한다 |
| 적용 대상 | 매니페스트 적용 실습(LEC-N2-15-012-MP)을 마친 WSL(Ubuntu 24.04), kind 클러스터 `student`, Deployment `web`과 Service `web` |
| 소요 시간 | 약 20분 |
| 확인 상태 | 미검증 (원본에 "Pod를 지우면 새 Pod가 생기는 장면은 확인하지 못했다. 교실 리허설에서 확인한다"라는 기록이 있으며, 이 문서는 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-5.md](lesson-5.md) | LEC-N2-15-005-DO | 자가 치유와 스케일 |
| [lesson-4-lab.md](lesson-4-lab.md) | LEC-N2-15-012-MP | 매니페스트 적용 실습 |
| [commands.md](commands.md) | LEC-N2-15-009-REF | 15일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL 터미널 2개 | Ubuntu 24.04 | A는 지켜보는 창, B는 깨뜨리는 창 |
| 2 | Deployment `web` | `replicas: 1` | `~/k8s/deployment.yaml`로 적용돼 있다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: Pod 이름은 각자 다르다. 강사 화면의 이름을 그대로 치지 않고 `kubectl get pods`로 확인한 자기 이름을 쓴다.
{% endhint %}

{% hint style="danger" %}
WARNING: Deployment를 지우면 Pod도 사라진다. 이 실습에서는 지우지 않는다. 지운 경우 `kubectl apply -f ~/k8s/deployment.yaml`로 다시 만든다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Deployment `web`이 있다 | `kubectl get deployments`에 `web`이 `1/1`로 보인다 |
| 2 | 터미널 두 개가 열려 있다 | 터미널 A, B |

## 5. 절차

### A. Pod 삭제

1. (5-A-01) 터미널 A에서 지켜본다: `kubectl get pods -w` → 결과: Pod 목록이 출력되고 대기한다.
2. (5-A-02) 터미널 B에서 Pod 이름을 확인한다: `kubectl get pods` → 결과: `web-<해시>-<해시>` 이름이 보인다. 이 이름을 적는다.
3. (5-A-03) 터미널 B에서 Pod를 지운다: `kubectl delete pod <내 Pod 이름>` → 결과: `pod "<이름>" deleted`가 출력된다.
4. (5-A-04) 터미널 A를 본다. → 결과: 지운 Pod가 `Terminating`이 되고, 다른 이름의 새 Pod가 `Pending`, `ContainerCreating`, `Running` 순으로 나타난다.
5. (5-A-05) 두 이름을 비교한다. → 결과: 이름이 서로 다르다(되살아난 것이 아니라 새로 만든 것이다).
6. (5-A-06) 터미널 A에서 `Ctrl+C`를 눌러 지켜보기를 끝낸다.

### B. 개수 바꾸기

1. (5-B-01) 3개로 늘린다: `kubectl scale deployment web --replicas=3` → 결과: `deployment.apps/web scaled`가 출력된다.
2. (5-B-02) Pod를 확인한다: `kubectl get pods` → 결과: Pod 3개가 `Running`이다.
3. (5-B-03) Service에 등록된 주소를 확인한다: `kubectl get endpoints web` → 결과: 세 주소가 보인다. 경고가 나오면 `kubectl get endpointslices -l kubernetes.io/service-name=web`을 쓴다.
4. (5-B-04) 1개로 줄인다: `kubectl scale deployment web --replicas=1` → 결과: 둘이 `Terminating`이 된다.

### C. 파일이 정석이다

1. (5-C-01) 파일을 연다: `nano ~/k8s/deployment.yaml`
2. (5-C-02) `replicas: 1`을 `replicas: 3`으로 고치고 저장한다.
3. (5-C-03) 적용한다: `kubectl apply -f ~/k8s/deployment.yaml` → 결과: `deployment.apps/web configured`가 출력된다.
4. (5-C-04) Pod를 확인한다: `kubectl get pods` → 결과: Pod 3개가 `Running`이다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Pod 삭제 직후 `kubectl get pods` | 새 Pod가 있다 | 개수가 `replicas`와 같고 이름이 삭제한 것과 다르다 |
| 2 | `kubectl scale ... --replicas=3` 뒤 `kubectl get pods` | Pod 3개 | 3개가 모두 `Running` |
| 3 | `kubectl apply -f ~/k8s/deployment.yaml`(파일 `replicas: 3`) | `configured` 또는 `unchanged` | Pod가 3개로 유지된다 |

## 7. 복구

1. (7-01) 개수를 원래대로 돌린다: `nano ~/k8s/deployment.yaml`에서 `replicas: 1`로 고치고 `kubectl apply -f ~/k8s/deployment.yaml` → 결과: Pod가 1개가 된다.
2. (7-02) 실습을 끝내면서 모두 내리려면: `kubectl delete -f ~/k8s/` → 결과: Deployment, Service, Pod가 없다.

{% hint style="info" %}
NOTE: 클러스터는 16일차에도 쓰므로 지우지 않고 남겨 둔다. 켜 둔 `port-forward`가 있으면 `Ctrl+C`로 끈다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-5.md`와 `commands.md`의 STEP 5 실습을 분리해 AMM 형식으로 재작성 |
