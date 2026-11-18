# 라벨과 진단 실습

> 상위: [15일차 · 쿠버네티스 입문](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-015-MP |
| 목적 | 라벨을 바꿔 Deployment가 새 Pod를 만드는 것을 확인하고, `logs`, `describe`(Events), `exec`로 Pod 안을 들여다본다 |
| 적용 대상 | B안 진행 시. Pod를 삭제하고 스케일한 실습(LEC-N2-15-013-MP)을 마친 WSL(Ubuntu 24.04), kind 클러스터 `student`, Deployment `web`(라벨 `app=web`) |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본에는 이 실습의 실행 확인 기록이 없으며, 이 문서는 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-7.md](lesson-7.md) | LEC-N2-15-007-DO | 더 들어가기 |
| [lesson-5-lab.md](lesson-5-lab.md) | LEC-N2-15-013-MP | Pod 삭제와 스케일 실습 |
| [commands.md](commands.md) | LEC-N2-15-009-REF | 15일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL 터미널 | Ubuntu 24.04 | |
| 2 | Deployment `web`, Service `web` | Pod 1개 이상 | 라벨 `app=web` |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 5-A-05에서 바꾼 라벨의 Pod는 Deployment에서 분리된다. 실습이 끝나면 5-A-08로 반드시 정리한다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `kubectl exec`의 `--`를 빠뜨리지 않는다. 빠뜨리면 옵션으로 오해한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Pod가 있다 | `kubectl get pods`에 `web-...` Pod가 `Running`으로 보인다 |
| 2 | 내 Pod 이름을 안다 | 이름 하나를 적어 둔다 |

## 5. 절차

### A. 라벨

1. (5-A-01) 라벨을 본다: `kubectl get pods --show-labels` → 결과: LABELS 열에 `app=web`이 보인다.
2. (5-A-02) 라벨로 고른다: `kubectl get pods -l app=web` → 결과: 5-A-01과 같은 Pod가 나온다.
3. (5-A-03) 라벨이 아닌 것을 고른다: `kubectl get pods -l app!=web` → 결과: `No resources found`가 나온다.
4. (5-A-04) Pod 개수를 적어 둔다.
5. (5-A-05) 라벨을 바꾼다: `kubectl label pod <내 Pod 이름> app=other --overwrite` → 결과: `pod/<이름> labeled`가 출력된다.
6. (5-A-06) Pod 목록을 본다: `kubectl get pods --show-labels` → 결과: 라벨이 `app=other`인 Pod가 남아 있고, `app=web`인 새 Pod가 하나 더 생겼다(5-A-04보다 1개 많다).
7. (5-A-07) Service 목록을 본다: `kubectl get endpoints web` → 결과: 새 Pod의 주소만 있고 `app=other` Pod의 주소는 빠졌다. 경고가 나오면 `kubectl get endpointslices -l kubernetes.io/service-name=web`을 쓴다.
8. (5-A-08) 정리한다: `kubectl delete pod -l app=other` → 결과: `app=other` Pod가 삭제된다.

### B. 들여다보기

1. (5-B-01) 로그를 본다: `kubectl logs -l app=web --tail=20` → 결과: nginx의 로그가 최대 20줄 나온다.
2. (5-B-02) 자세히 본다: `kubectl describe pod <내 Pod 이름>` → 결과: 긴 출력이 나온다.
3. (5-B-03) 맨 아래의 Events를 읽는다. → 결과: `Scheduled`, `Pulling`, `Created`, `Started` 같은 줄이 있다.
4. (5-B-04) Pod 안에 들어간다: `kubectl exec -it <내 Pod 이름> -- sh` → 결과: 프롬프트가 컨테이너 안으로 바뀐다.
5. (5-B-05) 안에서 `exit`를 친다. → 결과: WSL 프롬프트로 돌아온다.

### C. 좁혀 가는 순서 확인

1. (5-C-01) 순서를 적는다: ① `get pods` ② `describe`(Events) ③ `logs` ④ `get svc,endpoints` → 결과: 네 단계를 보지 않고 말할 수 있다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | 라벨 변경 후 `kubectl get pods` | 새 Pod가 생겼다 | Pod 개수가 변경 전보다 1개 많다 |
| 2 | `kubectl describe pod <Pod>`의 Events | `Started` 줄이 있다 | 오류(`Warning`)가 없다 |
| 3 | `kubectl exec -it <Pod> -- sh` | 컨테이너 안 프롬프트 | `exit`로 돌아온다 |
| 4 | 5-A-08 후 `kubectl get pods --show-labels` | `app=other` Pod가 없다 | 모든 Pod의 라벨이 `app=web`이다 |

## 7. 복구

1. (7-01) `app=other` Pod가 남아 있으면 지운다: `kubectl delete pod -l app=other` → 결과: Pod가 삭제된다.
2. (7-02) Pod 개수가 `replicas`보다 많거나 적으면 Deployment가 맞춘다. 잠시 기다린 뒤 `kubectl get pods`로 확인한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-7.md`와 `commands.md`의 STEP 7 실습을 분리해 AMM 형식으로 재작성 |
