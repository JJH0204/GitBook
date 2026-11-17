# 6. kubectl 은 API 클라이언트다 🅰️

> 상위: [15일차 · 쿠버네티스 입문](README.md) · 대본 [STEP 6](commands.md)
> ⚖️ **이 절은 [7_더_들어가기](lesson-7.md) 와 택1이다.** 설치가 순조로워 시간이 남을 때 이쪽으로 간다.

## 🎯 학습 목표

- **API** 가 무엇인지 한 줄로 말한다 (10일차 클라이언트–서버 회수)
- `kubectl` 이 **HTTP 요청을 보내고 있다**는 것을 직접 본다 ⭐
- **`curl`** 로 같은 정보를 꺼내고 **`jq`** 로 JSON 을 읽는다 ⭐
- **REST** 의 모양(경로 + 메서드)을 쿠버네티스 주소에서 읽어 낸다

## 🌉 다리 놓기: "`kubectl` 은 어떻게 알고 있나요?"

오늘 하루 종일 `kubectl get pods` 를 쳤다. 그런데 이 명령은 **어디서** 답을 가져오는 걸까?

> 🗣 **"`kubectl` 은 똑똑한 프로그램이 아닙니다. 물어보고 받아 적는 심부름꾼입니다."**

10일차에 배운 그림을 다시 꺼내 보자 — **클라이언트와 서버**. `kubectl` 이 클라이언트고, 클러스터 안의 **API 서버**가 서버다.

---

## 📖 ① API 란 — 프로그램이 쓰는 창구

| | 사람이 쓰는 창구 | 프로그램이 쓰는 창구 |
|---|---|---|
| 모양 | 웹 화면 · 버튼 | **주소 + 정해진 규칙** |
| 돌려주는 것 | 보기 좋은 화면(HTML) | **기계가 읽기 좋은 데이터(JSON)** |
| 예 | 날씨 사이트 | 날씨 **API** |

> 📌 **API** = 프로그램끼리 주고받기로 **미리 약속해 둔 창구**.
> 💡 **비유: 은행.** 창구 직원에게 말하는 게 사람용이고, **ATM 에 카드를 넣는 것**이 API 다. 정해진 순서로만 요청할 수 있고 정해진 형식으로만 답이 온다.

**REST** 는 그 약속을 **주소와 동사**로 짜는 흔한 방식이다.

| 하고 싶은 일 | HTTP 메서드 | 주소 |
|--------------|-------------|------|
| 목록 보기 | `GET` | `/api/v1/namespaces/default/pods` |
| 하나 보기 | `GET` | `/api/v1/namespaces/default/pods/web-xxxx` |
| 만들기 | `POST` | `/api/v1/namespaces/default/pods` |
| 지우기 | `DELETE` | `/api/v1/namespaces/default/pods/web-xxxx` |

> ⭐ **주소가 곧 "무엇을"이고, 메서드가 "어떻게"다.** `kubectl get` 은 `GET`, `kubectl delete` 는 `DELETE` 다.

---

## 📖 ② ⭐ kubectl 이 무엇을 보내는지 본다

```bash
kubectl get pods -v=6
```

```
GET https://127.0.0.1:XXXXX/api/v1/namespaces/default/pods?limit=500 200 OK in 12 milliseconds
```

> 🗣 **"보이시죠? `GET` 과 주소와 `200 OK`. 10일차에 배운 그 HTTP 입니다."**

`-v=6` 은 **얼마나 자세히 보여줄지**를 정하는 옵션이다. 숫자를 올리면 더 나온다.

```bash
kubectl get pods -v=8 2>&1 | head -30     # 헤더와 응답까지
```

> ⚠️ `-v=8` 은 출력이 길다. **한 번만 보여주고 넘어간다.**

---

## 📖 ③ ⭐ curl 로 직접 물어본다

API 서버는 **아무나 못 들어온다.** 인증서가 필요하다. 그래서 `kubectl` 이 **대신 인증해 주는 통로**를 연다.

```bash
# 터미널 A — 통로를 연다 (켜 둔다)
kubectl proxy
```

```
Starting to serve on 127.0.0.1:8001
```

```bash
# 터미널 B — 이제 평범한 HTTP 다
curl -s http://127.0.0.1:8001/api/v1/namespaces/default/pods | head -20
```

JSON 이 쏟아진다. **14일차 `docker inspect` 때와 같은 느낌**이다. 읽을 수 있게 잘라 보자.

```bash
sudo apt install -y jq        # 없으면
curl -s http://127.0.0.1:8001/api/v1/namespaces/default/pods \
  | jq '.items[].metadata.name'
```

```
"web-5d8f9c7b4-q9w1r"
"web-5d8f9c7b4-h2n8c"
"web-5d8f9c7b4-k4j7v"
```

> ⭐ **`kubectl get pods` 와 같은 답을 `curl` 로 받았다.** `kubectl` 이 하던 일을 우리가 손으로 한 것이다.

### jq 로 더 잘라 보기

```bash
# 이름과 상태만
curl -s http://127.0.0.1:8001/api/v1/namespaces/default/pods \
  | jq -r '.items[] | "\(.metadata.name)  \(.status.phase)"'

# 노드 이름
curl -s http://127.0.0.1:8001/api/v1/nodes | jq -r '.items[].metadata.name'

# 네임스페이스 목록
curl -s http://127.0.0.1:8001/api/v1/namespaces | jq -r '.items[].metadata.name'
```

| jq 표현 | 뜻 |
|---------|-----|
| `.items[]` | `items` 배열을 **하나씩** 꺼낸다 |
| `.metadata.name` | 그 안의 `metadata` 아래 `name` |
| `-r` | 따옴표 없이 **날것으로** 출력 |
| `"\(...)"` | 문자열 안에 값을 끼워 넣는다 |

> 💡 **`jq` 는 JSON 판 `grep` 이다.** 10일차에 파이프와 `grep` 으로 텍스트를 잘랐듯, JSON 은 `jq` 로 자른다.

---

## 📖 ④ 그래서 무엇이 달라지나

> 📌 **사람이 안 쳐도 된다.** 주소로 물어볼 수 있다는 건 **프로그램이 대신 물어볼 수 있다**는 뜻이다.

- 모니터링 도구가 **주기적으로 물어봐서** 그래프를 그린다
- 자동화 스크립트가 **조건을 보고** 개수를 늘린다
- 웹 대시보드가 같은 API 를 불러 **화면으로** 보여준다

> ⭐ 1번 절에서 말한 **"원하는 상태를 지켜 주는 것"** 도 결국 이 API 를 **계속 보고 있는 프로그램**이 하는 일이다.

```bash
# 끝나면 터미널 A 에서
Ctrl + C
```

> 🚨 **`kubectl proxy` 는 인증 없이 열린 통로다.** 실습이 끝나면 **반드시 끈다.** 11일차 최소 개방 감각 그대로다.

---

## 🧪 실습 / 질문

- `kubectl get nodes -v=6` 을 쳐 보고 주소가 어떻게 달라지는지 비교해 보자
- `jq '.items | length'` 는 무엇을 돌려줄까?
- `kubectl proxy` 를 끄고 `curl` 을 다시 치면?
- 사람이 보는 화면(HTML)과 API 가 주는 JSON 의 차이를 한 문장으로 말해 보자
- `DELETE` 요청을 `curl` 로 보내면 Pod 가 지워질까? (지우지는 말고 생각만)

## 📝 강의 메모

- ⭐ **②의 `-v=6` 한 줄**이 이 절의 전부다. "kubectl 이 HTTP 를 쏜다"를 보여주면 API 가 추상적이지 않게 된다
- ⚠️ `kubectl proxy` 도 터미널을 점유한다 → 3번 절 `port-forward` 때와 같은 안내
- ⚠️ `jq` 가 안 깔려 있을 수 있다 → **STEP 0 에서 미리** `apt install -y jq`
- 📌 JSON 구조를 다 설명하지 않는다. **`.items[].metadata.name` 하나**만 손에 익히면 충분하다
- 🚨 **마지막에 `Ctrl+C` 로 proxy 끄기**를 꼭 시킨다. 켜 둔 채 다음 수업에 오면 포트가 물려 있다
- ⏱ 25분 (이론 10 + 실습 15)
