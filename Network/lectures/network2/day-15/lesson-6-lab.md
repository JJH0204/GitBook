# API 들여다보기 실습

> 상위: [15일차 · 쿠버네티스 입문](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-014-MP |
| 목적 | `kubectl get pods -v=6`으로 `kubectl`이 보내는 HTTP 요청을 확인하고, `kubectl proxy`로 연 통로에 `curl`로 같은 정보를 요청해 `jq`로 읽는다 |
| 적용 대상 | A안 진행 시. Pod를 삭제하고 스케일한 실습(LEC-N2-15-013-MP)을 마친 WSL(Ubuntu 24.04), kind 클러스터 `student`, `jq` 설치 |
| 소요 시간 | 약 15분 |
| 확인 상태 | 미검증 (원본에 "`kubectl proxy` + `curl` + `jq`는 확인하지 못했다. 교실 리허설에서 확인한다"라는 기록이 있으며, 이 문서는 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-6.md](lesson-6.md) | LEC-N2-15-006-DO | kubectl은 API 클라이언트다 |
| [lesson-5-lab.md](lesson-5-lab.md) | LEC-N2-15-013-MP | Pod 삭제와 스케일 실습 |
| [commands.md](commands.md) | LEC-N2-15-009-REF | 15일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL 터미널 2개 | Ubuntu 24.04 | A는 `proxy`를 켜 두는 창, B는 `curl`을 치는 창 |
| 2 | `jq` | | 없으면 `sudo apt install -y jq` |
| 3 | kind 클러스터 `student` | Pod 1개 이상 | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `kubectl proxy`는 인증 없이 열린 통로다. 실습이 끝나면 반드시 터미널 A에서 `Ctrl+C`로 끈다. 켜 둔 채 다음 수업에 오면 포트가 물려 있다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `-v=8`은 출력이 길다. 한 번만 보고 넘어간다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `jq`가 설치돼 있다 | `jq --version`이 버전을 출력한다 |
| 2 | Pod가 있다 | `kubectl get pods`에 Pod가 1개 이상 보인다 |
| 3 | 터미널 두 개가 열려 있다 | 터미널 A, B |

## 5. 절차

### A. kubectl이 보내는 요청 보기

1. (5-A-01) 요청을 본다: `kubectl get pods -v=6` → 결과: `GET https://127.0.0.1:<포트>/api/v1/namespaces/default/pods?limit=500 200 OK`가 보인다.
2. (5-A-02) 더 자세히 본다(한 번만): `kubectl get pods -v=8 2>&1 | head -30` → 결과: 헤더와 응답이 보인다.

### B. proxy와 curl

1. (5-B-01) 터미널 A에서 통로를 연다: `kubectl proxy` → 결과: `Starting to serve on 127.0.0.1:8001`이 출력된다. 이 터미널은 점유된다.
2. (5-B-02) 터미널 B에서 요청한다: `curl -s http://127.0.0.1:8001/api/v1/namespaces/default/pods | head -20` → 결과: JSON이 출력된다.
3. (5-B-03) 이름만 꺼낸다: `curl -s http://127.0.0.1:8001/api/v1/namespaces/default/pods | jq '.items[].metadata.name'` → 결과: `kubectl get pods`와 같은 Pod 이름이 따옴표와 함께 나온다.
4. (5-B-04) 이름과 상태를 꺼낸다: `curl -s http://127.0.0.1:8001/api/v1/namespaces/default/pods | jq -r '.items[] | "\(.metadata.name)  \(.status.phase)"'` → 결과: `<이름>  Running` 형태의 줄이 나온다.
5. (5-B-05) 노드 이름을 꺼낸다: `curl -s http://127.0.0.1:8001/api/v1/nodes | jq -r '.items[].metadata.name'` → 결과: `student-control-plane`.
6. (5-B-06) 네임스페이스 목록을 꺼낸다: `curl -s http://127.0.0.1:8001/api/v1/namespaces | jq -r '.items[].metadata.name'` → 결과: `default`, `kube-system` 등이 나온다.

### C. 통로 닫기

1. (5-C-01) 터미널 A에서 `Ctrl+C`를 누른다. → 결과: `proxy`가 종료된다.
2. (5-C-02) 터미널 B에서 `curl -s http://127.0.0.1:8001/api/v1/nodes`(파이프 없이)를 친 뒤 `echo $?`를 친다. → 결과: JSON이 나오지 않고 종료 코드가 `7`(연결 실패)이다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kubectl get pods -v=6` | `GET ... 200 OK` | 출력에 `GET`과 `200 OK`가 있다 |
| 2 | `curl ... \| jq '.items[].metadata.name'` | Pod 이름 목록 | `kubectl get pods`의 이름과 같다 |
| 3 | `proxy` 종료 후 `curl` | 연결 실패 | 응답이 오지 않는다 |

## 7. 복구

1. (7-01) `proxy`가 켜져 있으면 `Ctrl+C`로 끈다.
2. (7-02) 이 실습은 클러스터 상태를 바꾸지 않았으므로 그 밖의 복구는 필요 없다. 이 문서의 `curl`은 `GET`만 사용했다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-6.md`와 `commands.md`의 STEP 6 실습을 분리해 AMM 형식으로 재작성 |
