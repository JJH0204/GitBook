# 16일차 · 쿠버네티스로 배포하고 공개하기

> 2단계 · 서버 구축 및 활용. 상위: [네트워크 2](../README.md)
> 이전: [15일차 · 쿠버네티스 입문](../day-15/README.md)

## 개요

15일차에 클러스터를 세우고 `nginx`를 띄웠다. 그런데 그것은 남이 만든 이미지였다. 13일차에 만든 포트폴리오, 14일차에 구운 내 이미지는 언제 올리는가?

오늘 올린다. 그리고 밖에서 접속할 수 있게 연다. 16일 과정의 마지막 날이다.

```bash
docker image save -o /tmp/mysite.tar mysite:1.0   # 내 이미지를 파일로
kind load image-archive /tmp/mysite.tar           # 클러스터에 넣고
kubectl apply -f k8s/                             # 원하는 상태를 적고
curl http://localhost:8080                        # 열린다
```

| 질문 | 오늘의 답 | 노트 |
|---|---|---|
| 내가 만든 이미지를 어떻게 넣나? | `kind load`. 레지스트리 없이 넣는다 | 1 |
| 그런데 왜 실패하나? | Docker 29의 이미지 저장소가 바뀌었다. `image-archive`로 우회한다 | 1 |
| 왜 `ErrImagePull`이 뜨나? | 태그를 `latest`로 두면 밖에서 받으려 한다 | 1 |
| `.env`는 어디로 가나? | ConfigMap과 Secret | 2 |
| Secret이면 안전한가? | 아니다. base64는 암호가 아니다 | 2 |
| 밖에서 접속하려면? | NodePort. 그리고 Ingress(시연) | 3 |
| 고친 것을 다시 올리려면? | 태그를 올리고 `set image`. 끊기지 않는다 | 4 |
| 잘못 올렸으면? | `rollout undo`. 13일차 되돌리기와 같은 자리다 | 4 |
| 16일 동안 무엇을 했나? | 한 장으로 되짚는다 | 5 |

## 오늘의 목표

- 14일차에 구운 내 이미지를 클러스터에 넣고 띄운다.
- `kind load docker-image`가 실패할 때의 이유와 대안을 안다.
- `imagePullPolicy`와 태그를 고정해야 하는 이유를 설명한다.
- 14일차 `.env`를 ConfigMap과 Secret으로 옮기고, Secret이 암호화가 아님을 안다.
- ClusterIP, NodePort, Ingress로 문을 여는 세 단계를 구분한다.
- 롤링 업데이트로 끊김 없이 바꾸고, 롤백으로 되돌린다.
- 16일 과정 전체를 한 장으로 되짚는다.

## 문서 목록과 읽는 순서

실습 중에는 0번(명령어 대본)을 화면에 띄워 둔다. 개념 문서(D&O)를 읽은 뒤 바로 뒤의 실습 문서(MP)를 수행한다.

| 순서 | Task ID | 유형 | 문서 | 용도 |
|---|---|---|---|---|
| 1 | LEC-N2-16-007-REF | REF | [0. 16일차 실습 명령어 — 수업 흐름 그대로 (이어치기 대본)](commands.md) | STEP 0~6 명령 대본, 정리 |
| 2 | LEC-N2-16-008-MP | MP | [클러스터 재생성 실습](lesson-0-lab.md) | 점검, 이미지 복구, 포트 매핑 설정 파일로 클러스터 재생성 |
| 3 | LEC-N2-16-001-DO | D&O | [1. 내 이미지를 클러스터로 — 레지스트리 없이](lesson-1.md) | 이미지 위치, `kind load`, Docker 29 문제, `imagePullPolicy` |
| 4 | LEC-N2-16-009-MP | MP | [내 이미지 올리기 실습](lesson-1-lab.md) | `image save`, `image-archive`, `ErrImagePull` 재현, 매니페스트로 기동 |
| 5 | LEC-N2-16-002-DO | D&O | [2. 설정과 비밀 — ConfigMap과 Secret](lesson-2.md) | ConfigMap, Secret, base64, `envFrom` |
| 6 | LEC-N2-16-010-MP | MP | [ConfigMap과 Secret 실습](lesson-2-lab.md) | 생성, base64 해독, Pod 주입 |
| 7 | LEC-N2-16-003-DO | D&O | [3. 밖으로 여는 법 — NodePort와 Ingress](lesson-3.md) | 문을 여는 세 단계, 포트 번호 네 개, Ingress |
| 8 | LEC-N2-16-011-MP | MP | [NodePort 공개 실습](lesson-3-lab.md) | NodePort 서비스, `curl` 확인, 열린 문 세기 |
| 9 | LEC-N2-16-004-DO | D&O | [4. 고치고 되돌리기 — 롤링 업데이트와 롤백](lesson-4.md) | 롤링 업데이트, `rollout undo`, 13~16일차 되돌리기 비교 |
| 10 | LEC-N2-16-012-MP | MP | [롤링 업데이트와 롤백 실습](lesson-4-lab.md) | 새 태그 굽기, `set image`, `rollout undo`, 커밋 |
| 11 | LEC-N2-16-005-DO | D&O | [5. 16일을 되짚는다](lesson-5.md) | 16일 지도, 반복된 생각 다섯 가지, 다음 공부거리 |
| 12 | LEC-N2-16-006-INS | INS | [6. 오늘의 문제](lesson-6.md) | 문제 8문항 |

## 오늘의 실습 환경

```
   Windows --localhost:8080--> WSL
                                └─ Docker Engine 29.x
                                     └─ kind 노드 (컨테이너)
                                          │  extraPortMappings로 8080을 뚫어 둔다
                                          └─ Pod (내 포트폴리오 이미지)
```

{% hint style="danger" %}
WARNING: 클러스터를 다시 만든다. 15일차 클러스터에는 포트 구멍이 없다. 오늘은 설정 파일로 만든다. 클러스터를 지우면 안의 것이 전부 사라진다.
{% endhint %}

클러스터도 파일로 적어 다시 만든다. 그 자체가 오늘의 교재이다.

### 수업 시작 전 점검

```bash
ps -p 1 -o comm=                            # systemd
docker info --format '{{.ServerVersion}}'   # 29.x
kind get clusters                           # 15일차 것이 남아 있나
docker images | grep mysite                 # 14일차에 구운 이미지가 있나
```

{% hint style="warning" %}
CAUTION: 14일차 이미지가 없는 학생이 반드시 있다(WSL을 지웠거나 따라오지 못한 경우). STEP 0에서 저장소를 `clone`해 `docker build`부터 다시 하게 한다. 복구 절차는 [클러스터 재생성 실습](lesson-0-lab.md)에 있다.
{% endhint %}

## 오늘의 진행: 4시간(240분)

| 순서 | 내용 | 이론 | 실습 | 누적 |
|---|---|---|---|---|
| 0 | 몸풀기, 클러스터를 설정 파일로 다시 만든다 | 5분 | 10분 | 15분 |
| 1 | 내 이미지를 클러스터로 | 10분 | 25분 | 50분 |
| 2 | ConfigMap과 Secret | 10분 | 20분 | 80분 |
| | 쉬는 시간 10분 | | | 90분 |
| 3 | 밖으로 여는 법: NodePort, Ingress(시연) | 20분 | 25분 | 135분 |
| | 쉬는 시간 10분 | | | 145분 |
| 4 | 롤링 업데이트와 롤백 | 10분 | 20분 | 175분 |
| 5 | 16일 되짚기, 다음 공부거리 | 25분 | | 200분 |
| 6 | 오늘의 문제 | 20분 | | 220분 |

{% hint style="info" %}
NOTE: 필수는 1, 3, 5번이다. 시간이 모자라면 4(강사 시연), 2(Secret만), 1의 재현 실험 순으로 줄인다. 5번(되짚기)은 마지막 날의 결말이므로 25분을 반드시 남긴다. 여기가 잘리면 과정이 흐지부지 끝난다.
{% endhint %}

## AI 활용

- 매니페스트 초안, `kubectl` 오류 메시지 해석, YAML 들여쓰기 교정에 쓴다.
- 버전마다 필드가 달라진다. AI가 준 매니페스트는 `kubectl apply --dry-run=client`로 거른다(10일차 검증 원칙).

{% hint style="danger" %}
WARNING: `kubectl delete -f .`, `kind delete cluster`, `kubectl delete ns`가 AI의 답에 있으면 3초 멈춘다.
{% endhint %}

## 강의 메모

- 도입 질문은 "15일차에 띄운 것은 남의 nginx였다. 오늘은 여러분 것을 올린다."이다.
- 1번 절이 오늘의 승부처이다. 14일차에서 16일차가 여기서 한 줄로 이어진다. Docker 29의 containerd 이미지 저장소 때문에 `kind load docker-image`가 실패할 수 있으므로 대안을 먼저 가르친다.
- 3번 절은 11일차와 14일차 회수의 결말이다. "문을 여는 것은 `-p`뿐"이 "문을 여는 것은 NodePort와 Ingress뿐"으로 올라간다.
- 5번 되짚기에서 1일차 첫 장을 다시 띄운다. "네트워크란 무엇인가"로 시작해 내가 만든 것이 열리는 것으로 끝난다.
- 최대 병목은 세 가지이다.
  1. 이미지 넣기 실패. 1번 절 대안 경로를 먼저 안내한다.
  2. 클러스터 재생성. STEP 0에서 미리 건다(두 번째라 1~2분).
  3. YAML 분량. 매니페스트를 강사가 공유하고 고쳐 쓰게 한다.
- 발표용 Excalidraw 그림은 아직 없다. 문 세 단계 그림은 판서로 그린다.

## 리허설 기록

2026-10-20, 클라우드 컨테이너에서 했다(WSL 아님). Docker Engine 29.9.1과 containerd 이미지 저장소로, 14일차에 학생들이 설치한 것과 같은 조건이다.

### 확인된 것

| 항목 | 결과 |
|---|---|
| 14일차 `Dockerfile`로 `docker build -t mysite:1.0 .` | 성공(nginx:alpine 기반, 102MB) |
| `docker image save --platform linux/amd64 -o /tmp/mysite.tar mysite:1.0` | 동작한다(1초, 28MB) |
| `--platform` 없이 `docker image save` | 이 환경에서는 같은 결과 |
| 나온 tar의 형식 | `oci-layout`, `index.json`, `manifest.json`을 모두 포함한다. `ctr images import` 계열이 읽는 형태이다 |

16일차의 중심 명령이 Docker 29와 containerd 저장소에서 그대로 동작한다. 대본의 두 줄 경로는 유효하다.

### 확인하지 못한 것

클러스터를 띄우지 못해(호스트가 cgroup v1) 클러스터가 필요한 것은 전부 미검증이다. 교실 리허설에서 확인한다.

- `kind load image-archive`가 그 tar를 실제로 받아들이는지(가장 중요하다)
- `kubectl create deployment --image=mysite:1.0`이 `Running`이 되는지
- `latest` 태그로 `ErrImagePull`이 재현되는지, `imagePullPolicy: IfNotPresent`로 풀리는지
- NodePort와 `extraPortMappings`로 `curl http://localhost:8080`이 열리는지(가장 중요하다)
- `kubectl set image`의 롤링 순서와 `rollout undo`
- ConfigMap과 Secret 주입(`envFrom`)

{% hint style="info" %}
NOTE: `kind load docker-image`가 Docker 29에서 실패한다는 것도 직접 확인하지 못했다. 공식 문서가 기록한 알려진 문제이고, 이 환경이 그 조건(containerd 저장소)이다. 대본은 처음부터 `image-archive`로 가므로 영향은 없다.
{% endhint %}
