# 첫 배포 실습

> 상위: [15일차 · 쿠버네티스 입문](README.md)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-011-MP |
| 목적 | `kubectl create deployment`로 nginx를 띄우고, Service로 묶어 이름으로 통신을 확인한 뒤, `port-forward`로 Windows 브라우저에서 확인한다 |
| 적용 대상 | 클러스터 생성 실습(LEC-N2-15-010-MP)을 마친 WSL(Ubuntu 24.04), kind 클러스터 `student`, Windows 브라우저 |
| 소요 시간 | 약 25분 |
| 확인 상태 | 미검증 (원본에 "`create deployment`, `expose`, `port-forward`의 실제 동작은 확인하지 못했다"라는 기록이 있으며, 이 문서는 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [lesson-3.md](lesson-3.md) | LEC-N2-15-003-DO | 첫 배포 |
| [lesson-2-lab.md](lesson-2-lab.md) | LEC-N2-15-010-MP | 클러스터 생성 실습 |
| [commands.md](commands.md) | LEC-N2-15-009-REF | 15일차 실습 명령어 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | WSL 터미널 2개 | Ubuntu 24.04 | `port-forward`가 터미널 하나를 점유한다 |
| 2 | kind 클러스터 `student` | 노드 `Ready` | 클러스터 생성 실습에서 만든다 |
| 3 | Windows 브라우저 | | `http://localhost:8080` 확인 |
| 4 | 인터넷 | `nginx`, `busybox` 이미지 다운로드 | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: Pod 이름은 각자 다르다. 대본의 이름을 그대로 치지 않고 `kubectl get pods`로 확인한 자기 이름을 쓴다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 5-A-05는 옵션이 많아 오타가 나기 쉽다. 강사가 먼저 치고 결과를 보여 준 뒤 따라 친다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | 클러스터가 떠 있다 | `kubectl get nodes`의 STATUS가 `Ready`이다 |
| 2 | 터미널 B를 열어 둔다 | 두 번째 WSL 터미널이 열려 있다 |

## 5. 절차

### A. Deployment와 Service

1. (5-A-01) Deployment를 만든다: `kubectl create deployment web --image=nginx` → 결과: `deployment.apps/web created`가 출력된다.
2. (5-A-02) Deployment를 확인한다: `kubectl get deployments` → 결과: `web`의 READY가 `1/1`이다.
3. (5-A-03) Pod를 확인한다: `kubectl get pods` → 결과: `web-<해시>-<해시>` 이름의 Pod가 `Running`이다. 이 이름을 적어 둔다(5번 노트에서 쓴다).
4. (5-A-04) Service를 만든다: `kubectl expose deployment web --port=80` → 결과: `service/web exposed`가 출력된다.
5. (5-A-05) 이름으로 통신을 확인한다: `kubectl run tmp --image=busybox --rm -it --restart=Never -- wget -qO- http://web` → 결과: `Welcome to nginx!`가 포함된 HTML이 출력된다.
6. (5-A-06) Service를 확인한다: `kubectl get services` → 결과: `web`의 TYPE이 `ClusterIP`이고 CLUSTER-IP가 붙어 있다.

### B. 내 브라우저에서 확인

1. (5-B-01) 터미널 A에서 통로를 연다: `kubectl port-forward service/web 8080:80` → 결과: `Forwarding from 127.0.0.1:8080 -> 80`이 출력된다. 이 터미널은 점유된다.
2. (5-B-02) Windows 브라우저에서 `http://localhost:8080`을 연다. → 결과: `Welcome to nginx!`가 보인다.
3. (5-B-03) 터미널 A에서 `Ctrl+C`를 누른다. → 결과: 통로가 닫힌다.
4. (5-B-04) 브라우저를 새로고침한다. → 결과: 접속되지 않는다.

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `kubectl get pods` | Pod 1개 | STATUS가 `Running` |
| 2 | `kubectl get services` | `web` Service | TYPE이 `ClusterIP` |
| 3 | `wget -qO- http://web`(임시 Pod) | nginx 환영 페이지 | HTML에 `Welcome to nginx!`가 있다 |
| 4 | `http://localhost:8080`(`port-forward` 중) | nginx 환영 페이지 | 페이지가 열린다 |

{% hint style="warning" %}
CAUTION: Pod 상태별 조치는 다음과 같다. `ContainerCreating`이면 이미지를 받는 중이므로 기다린다. `ImagePullBackOff`, `ErrImagePull`이면 이미지 이름과 태그의 오타를 확인한다. `CrashLoopBackOff`이면 `kubectl logs <Pod 이름>`을 본다. `Pending`이면 메모리 부족을 의심한다.
{% endhint %}

## 7. 복구

1. (7-01) `port-forward`가 켜져 있으면 `Ctrl+C`로 끈다.
2. (7-02) 이 실습에서 만든 것을 지우려면: `kubectl delete service web` 과 `kubectl delete deployment web` → 결과: `kubectl get all`에 `web`이 없다.

{% hint style="info" %}
NOTE: 다음 실습(매니페스트 적용, 자가 치유)에서 `web`을 계속 쓰므로, 이어서 진행한다면 지우지 않는다.
{% endhint %}

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 원본 `lesson-3.md`와 `commands.md`의 STEP 3 실습을 분리해 AMM 형식으로 재작성 |
