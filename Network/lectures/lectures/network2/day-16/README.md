# 16일차 · 쿠버네티스로 배포하고 공개하기

> 2단계 · 서버 구축 및 활용 — 상위: [네트워크 2](../README.md)
> 이전: [15일차 · 쿠버네티스 입문](../day-15/README.md)

15일차에 클러스터를 세우고 `nginx` 를 띄웠다. 그런데 그건 **남이 만든 이미지**였다.

> 🗣 **"13일차에 만든 포트폴리오, 14일차에 구운 내 이미지. 그건 언제 올리나요?"**

오늘 올린다. 그리고 **밖에서 접속**할 수 있게 연다. **16일 과정의 마지막 날**이다.

```bash
docker image save -o /tmp/mysite.tar mysite:1.0   # 내 이미지를 파일로
kind load image-archive /tmp/mysite.tar           # 클러스터에 넣고
kubectl apply -f k8s/                             # 원하는 상태를 적고
curl http://localhost:8080                        # 열린다
```

| 질문 | 오늘의 답 | 노트 |
|------|-----------|------|
| 내가 만든 이미지를 어떻게 넣나? | **`kind load`** — 레지스트리 없이 ⭐⭐ | 1 |
| 🚨 그런데 왜 실패하나? | Docker 29 의 **이미지 저장소가 바뀌었다** → `image-archive` | 1 |
| 왜 `ErrImagePull` 이 뜨나? | **태그를 `latest` 로 두면** 밖에서 받으려 한다 ⭐ | 1 |
| `.env` 는 어디로 가나? | **ConfigMap · Secret** | 2 |
| Secret 이면 안전한가? | 🚨 **아니다. base64 는 암호가 아니다** ⭐ | 2 |
| 밖에서 접속하려면? | **NodePort** · 그리고 **Ingress**(시연) ⭐⭐ | 3 |
| 고친 걸 다시 올리려면? | 태그를 올리고 **`set image`** · 끊기지 않는다 ⭐ | 4 |
| 잘못 올렸으면? | **`rollout undo`** — 13일차 되돌리기와 같은 자리 | 4 |
| 16일 동안 무엇을 했나? | **한 장으로 되짚는다** | 5 |

## 🎯 오늘의 목표

- 14일차에 구운 **내 이미지**를 클러스터에 넣고 띄운다 ⭐⭐
- 🚨 **`kind load docker-image` 가 실패할 때**의 이유와 대안을 안다
- `imagePullPolicy` 와 **태그를 고정해야 하는 이유**를 설명한다 ⭐
- 14일차 `.env` 를 **ConfigMap · Secret** 으로 옮기고, **Secret 이 암호화가 아님**을 안다 ⭐
- **ClusterIP → NodePort → Ingress** 로 문을 여는 세 단계를 구분한다 ⭐⭐
- **롤링 업데이트**로 끊김 없이 바꾸고, **롤백**으로 되돌린다 ⭐
- 16일 과정 전체를 **한 장으로** 되짚는다

## 📑 목차

0. [🖐 실습 명령어 대본 — 수업 흐름 그대로 (실습 중 띄워둘 것)](commands.md)
1. [내 이미지를 클러스터로 — 레지스트리 없이](lesson-1.md) ⭐⭐
2. [설정과 비밀 — ConfigMap 과 Secret](lesson-2.md) ⭐
3. [밖으로 여는 법 — NodePort 와 Ingress](lesson-3.md) ⭐⭐
4. [고치고 되돌리기 — 롤링 업데이트와 롤백](lesson-4.md) ⭐
5. [16일을 되짚는다](lesson-5.md)
6. [🎯 오늘의 문제](lesson-6.md)

## ⏱ 오늘의 진행 — 4시간(240분)

| 순서 | 내용 | 이론 | 실습 | 누적 |
|------|------|------|------|------|
| **0** | 🔁 몸풀기 · **클러스터를 config 로 다시 만든다** ⭐ | 5분 | 10분 | 15분 |
| **1** | **내 이미지를 클러스터로** ⭐⭐ | 10분 | 25분 | 50분 |
| **2** | ConfigMap · Secret ⭐ | 10분 | 20분 | 80분 |
| | ── 쉬는 시간 10분 ── | | | 90분 |
| **3** | **밖으로 여는 법** — NodePort · Ingress(시연) ⭐⭐ | 20분 | 25분 | 135분 |
| | ── 쉬는 시간 10분 ── | | | 145분 |
| **4** | 롤링 업데이트 · 롤백 ⭐ | 10분 | 20분 | 175분 |
| **5** | **16일 되짚기** · 다음 공부거리 | 25분 | — | 200분 |
| **6** | 오늘의 문제 | 20분 | | **220분** |

> ⏱ **필수**: 1 · 3 · 5. 시간이 모자라면 **4(강사 시연) → 2(Secret 만) → 1 의 재현 실험** 순으로 줄인다.
> ⭐ **5번(되짚기)** 은 마지막 날의 결말이다. **25분을 반드시 남긴다.** 여기가 잘리면 과정이 흐지부지 끝난다.

## 🧪 오늘의 실습 환경

```
   🪟 Windows ──localhost:8080──▶ 🐧 WSL
                                   └─ Docker Engine 29.x
                                        └─ kind 노드 (컨테이너)
                                             │  ⭐ extraPortMappings 로 8080 을 뚫어 둔다
                                             └─ Pod (내 포트폴리오 이미지)
```

> 🚨 **클러스터를 다시 만든다.** 15일차 클러스터에는 포트 구멍이 없다. 오늘은 **설정 파일로** 만든다.
> 📌 그 자체가 교재다 — **클러스터도 파일로 적어 다시 만든다.**

### 🚨 수업 시작 전 점검

```bash
ps -p 1 -o comm=                            # systemd
docker info --format '{{.ServerVersion}}'   # 29.x
kind get clusters                           # 15일차 것이 남아 있나
docker images | grep mysite                 # ⭐ 14일차에 구운 이미지가 있나
```

> ⚠️ **14일차 이미지가 없는 학생**이 반드시 있다(WSL 을 지웠거나 못 따라왔거나).
> 👉 STEP 0 에서 **저장소를 `clone` 해 `docker build` 부터** 다시 하게 한다. 그래서 1번 절 앞에 **복구 경로**를 넣어 뒀다.

## 🤖 AI 활용

- 매니페스트 초안 · `kubectl` 에러 메시지 해석 · YAML 들여쓰기 교정
- 🛑 `kubectl delete -f .` · `kind delete cluster` · `kubectl delete ns` 는 **3초 멈춤**
- 📌 **버전마다 필드가 달라진다.** AI 가 준 매니페스트는 `kubectl apply --dry-run=client` 로 꼭 거른다 (10일차 검증 원칙)

## 📝 강의 메모

- 🗣 도입: **"15일차에 띄운 건 남의 nginx 였습니다. 오늘은 여러분 것을 올립니다."**
- ⭐⭐ **1번 절이 오늘의 승부처다.** 14일차 → 16일차가 여기서 한 줄로 이어진다
  - 🚨 **Docker 29 의 containerd 이미지 저장소** 때문에 `kind load docker-image` 가 실패할 수 있다. **대안을 먼저 가르친다**
- ⭐⭐ **3번 절은 11 · 14일차 회수의 결말**이다 — "문을 여는 것은 `-p` 뿐" 이 "문을 여는 것은 NodePort/Ingress 뿐" 으로 올라간다
- ⭐ **5번 되짚기에서 1일차 첫 장을 다시 띄운다.** "네트워크란 무엇인가" 로 시작해 **내가 만든 것이 열리는 것**으로 끝난다
- ⚠️ 최대 병목
  1. **이미지 넣기 실패** — 1번 절 ③의 대안 경로를 **먼저** 안내한다
  2. **클러스터 재생성** — STEP 0 에서 미리 건다 (두 번째라 1~2분)
  3. **YAML 분량** — 매니페스트를 강사가 공유하고 **고쳐 쓰게** 한다
- 📌 발표용 Excalidraw 드로잉은 **아직 없다** (문 세 단계 그림은 판서)

## 🔎 리허설로 확인한 것 (2026-10-20 · 클라우드 컨테이너, **WSL 아님**)

> 📌 **환경**: Docker Engine **29.9.1** + **containerd 이미지 저장소** — 14일차에 학생들이 설치한 것과 **같은 조건**이다.

### ✅ 확인된 것 — 1번 절의 핵심 명령

| 항목 | 결과 |
|------|------|
| 14일차 `Dockerfile` 로 `docker build -t mysite:1.0 .` | ✅ 성공 (nginx:alpine 기반, 102MB) |
| **`docker image save --platform linux/amd64 -o /tmp/mysite.tar mysite:1.0`** | ✅ **동작한다** (1초, 28MB) |
| `--platform` 없이 `docker image save` | ✅ 이 환경에서는 같은 결과 |
| 나온 tar 의 형식 | ✅ **`oci-layout` · `index.json` · `manifest.json` 을 모두 포함** → `ctr images import` 계열이 읽는 형태 |

> ⭐ **16일차의 중심 명령이 Docker 29 + containerd 저장소에서 그대로 동작한다.** 대본의 두 줄 경로는 유효하다.

### ⚠️ 확인하지 못한 것 — **교실 리허설에서 확인할 것**

클러스터를 띄우지 못해(호스트가 cgroup v1) **클러스터가 필요한 것은 전부 미검증**이다.

- **`kind load image-archive` 가 그 tar 를 실제로 받아들이는지** ⭐ 가장 중요하다
- `kubectl create deployment --image=mysite:1.0` 이 `Running` 이 되는지
- `latest` 태그로 **`ErrImagePull` 이 재현되는지**, `imagePullPolicy: IfNotPresent` 로 풀리는지
- **NodePort + extraPortMappings 로 `curl http://localhost:8080` 이 열리는지** ⭐
- `kubectl set image` 의 **롤링 순서**와 `rollout undo`
- ConfigMap · Secret 주입 (`envFrom`)

> 🚨 `kind load docker-image`(짧은 길)가 Docker 29 에서 실패한다는 것도 **직접 확인하지는 못했다.** 공식 문서가 기록한 알려진 문제이고, 이 환경이 바로 그 조건(containerd 저장소)이다. 👉 **대본은 어차피 `image-archive` 로 가므로 영향은 없다.**
