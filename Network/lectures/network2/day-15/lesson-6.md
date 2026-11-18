# 6. kubectl 은 API 클라이언트다

> 상위: [15일차 · 쿠버네티스 입문](README.md) · 절차는 [API 들여다보기 실습](lesson-6-lab.md), 대본은 [STEP 6](commands.md)
> 이 노트는 [7. 더 들어가기](lesson-7.md)와 택1이다(A안). 설치가 순조로워 시간이 남을 때 이쪽으로 간다.

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | LEC-N2-15-006-DO |
| 유형 | D&O (개념) |
| 목적 | API와 REST의 뜻, `kubectl`이 API 서버에 HTTP 요청을 보내는 클라이언트임, `kubectl proxy`와 `curl`, `jq`로 같은 정보를 꺼내는 방법을 설명한다 |
| 확인 상태 | 미검증 (원본 강의 노트를 AMM 형식으로 옮긴 것이며 실행해 확인하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- API가 무엇인지 한 줄로 말한다(10일차 클라이언트-서버 회수).
- `kubectl`이 HTTP 요청을 보내고 있다는 것을 직접 본다.
- `curl`로 같은 정보를 꺼내고 `jq`로 JSON을 읽는다.
- REST의 모양(경로 + 메서드)을 쿠버네티스 주소에서 읽어 낸다.

## 1. 목적

오늘 하루 종일 `kubectl get pods`를 쳤다. 그런데 이 명령은 어디서 답을 가져오는가?

> 강사 대사: "`kubectl`은 똑똑한 프로그램이 아닙니다. 물어보고 받아 적는 심부름꾼입니다."

10일차에 배운 클라이언트와 서버 그림을 다시 꺼낸다. `kubectl`이 클라이언트이고, 클러스터 안의 API 서버가 서버다.

## 2. 구성 요소

### API: 프로그램이 쓰는 창구

| | 사람이 쓰는 창구 | 프로그램이 쓰는 창구 |
|---|---|---|
| 모양 | 웹 화면, 버튼 | 주소 + 정해진 규칙 |
| 돌려주는 것 | 보기 좋은 화면(HTML) | 기계가 읽기 좋은 데이터(JSON) |
| 예 | 날씨 사이트 | 날씨 API |

API는 프로그램끼리 주고받기로 미리 약속해 둔 창구다. 비유는 은행이다. 창구 직원에게 말하는 것이 사람용이고, ATM에 카드를 넣는 것이 API다. 정해진 순서로만 요청할 수 있고 정해진 형식으로만 답이 온다.

REST는 그 약속을 주소와 동사로 짜는 흔한 방식이다.

| 하고 싶은 일 | HTTP 메서드 | 주소 |
|---|---|---|
| 목록 보기 | `GET` | `/api/v1/namespaces/default/pods` |
| 하나 보기 | `GET` | `/api/v1/namespaces/default/pods/web-xxxx` |
| 만들기 | `POST` | `/api/v1/namespaces/default/pods` |
| 지우기 | `DELETE` | `/api/v1/namespaces/default/pods/web-xxxx` |

주소가 곧 "무엇을"이고, 메서드가 "어떻게"다. `kubectl get`은 `GET`, `kubectl delete`는 `DELETE`다.

### kubectl이 무엇을 보내는지 본다

```bash
kubectl get pods -v=6
```

```
GET https://127.0.0.1:XXXXX/api/v1/namespaces/default/pods?limit=500 200 OK in 12 milliseconds
```

> 강사 대사: "보이시죠? `GET`과 주소와 `200 OK`. 10일차에 배운 그 HTTP입니다."

`-v=6`은 얼마나 자세히 보여 줄지를 정하는 옵션이다. 숫자를 올리면 더 나온다. `kubectl get pods -v=8 2>&1 | head -30`은 헤더와 응답까지 보여 주며 출력이 길다. 한 번만 보여 주고 넘어간다.

### curl로 직접 물어본다

API 서버는 아무나 못 들어온다. 인증서가 필요하다. 그래서 `kubectl`이 대신 인증해 주는 통로를 연다.

```bash
# 터미널 A: 통로를 연다 (켜 둔다)
kubectl proxy
```

```
Starting to serve on 127.0.0.1:8001
```

```bash
# 터미널 B: 이제 평범한 HTTP 다
curl -s http://127.0.0.1:8001/api/v1/namespaces/default/pods | head -20
```

JSON이 쏟아진다. 14일차 `docker inspect` 때와 같은 느낌이다. 읽을 수 있게 `jq`로 자른다.

```bash
curl -s http://127.0.0.1:8001/api/v1/namespaces/default/pods \
  | jq '.items[].metadata.name'
```

```
"web-5d8f9c7b4-q9w1r"
"web-5d8f9c7b4-h2n8c"
"web-5d8f9c7b4-k4j7v"
```

`kubectl get pods`와 같은 답을 `curl`로 받았다. `kubectl`이 하던 일을 우리가 손으로 한 것이다.

### jq로 더 잘라 보기

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
|---|---|
| `.items[]` | `items` 배열을 하나씩 꺼낸다 |
| `.metadata.name` | 그 안의 `metadata` 아래 `name` |
| `-r` | 따옴표 없이 날것으로 출력 |
| `"\(...)"` | 문자열 안에 값을 끼워 넣는다 |

`jq`는 JSON 판 `grep`이다. 10일차에 파이프와 `grep`으로 텍스트를 잘랐듯, JSON은 `jq`로 자른다.

### 그래서 무엇이 달라지는가

사람이 안 쳐도 된다. 주소로 물어볼 수 있다는 것은 프로그램이 대신 물어볼 수 있다는 뜻이다.

- 모니터링 도구가 주기적으로 물어봐서 그래프를 그린다.
- 자동화 스크립트가 조건을 보고 개수를 늘린다.
- 웹 대시보드가 같은 API를 불러 화면으로 보여 준다.

1번 노트에서 말한 "원하는 상태를 지켜 주는 것"도 결국 이 API를 계속 보고 있는 프로그램이 하는 일이다.

{% hint style="danger" %}
WARNING: `kubectl proxy`는 인증 없이 열린 통로다. 실습이 끝나면 반드시 `Ctrl+C`로 끈다. 11일차 최소 개방 감각 그대로다.
{% endhint %}

## 3. 동작 원리

1. `kubectl get pods`를 친다.
2. `kubectl`이 API 서버에 `GET /api/v1/namespaces/default/pods`를 보낸다.
3. API 서버가 Pod 목록을 JSON으로 돌려준다(`200 OK`).
4. `kubectl`이 JSON을 사람이 읽기 좋은 표로 바꿔 출력한다.
5. `kubectl proxy`를 켜면 인증을 대신 해 주는 통로가 `127.0.0.1:8001`에 열린다. `curl`이 그 통로로 같은 요청을 보내면 JSON을 그대로 받는다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| API(Application Programming Interface) | 프로그램끼리 주고받기로 약속한 창구 |
| REST | 주소와 HTTP 메서드로 API를 짜는 방식 |
| JSON | 기계가 읽기 좋은 데이터 형식 |
| API 서버 | 클러스터의 창구. `kubectl`이 말을 거는 곳 |
| `jq` | JSON을 자르고 읽는 도구 |
| `-v=6` | `kubectl`이 보내는 요청을 보여 주는 상세 출력 옵션 |

## 그림 목록

| 번호 | 그림 | 설명 |
|---|---|---|
| 1 | 클라이언트와 서버 | `kubectl`(클라이언트)과 API 서버(서버). 10일차 그림을 다시 쓴다 |

## 강의 메모

- `-v=6` 한 줄이 이 절의 전부다. "kubectl이 HTTP를 쏜다"를 보여 주면 API가 추상적이지 않게 된다.
- `kubectl proxy`도 터미널을 점유한다. 3번 노트 `port-forward` 때와 같은 안내를 한다.
- `jq`가 안 깔려 있을 수 있다. STEP 0에서 미리 `apt install -y jq`를 한다.
- JSON 구조를 다 설명하지 않는다. `.items[].metadata.name` 하나만 손에 익히면 충분하다.
- 마지막에 `Ctrl+C`로 proxy 끄기를 꼭 시킨다. 켜 둔 채 다음 수업에 오면 포트가 물려 있다.
- 25분(이론 10, 실습 15).

### 토의 질문

- `kubectl get nodes -v=6`을 쳐 보고 주소가 어떻게 달라지는지 비교한다.
- `jq '.items | length'`는 무엇을 돌려주는가?
- `kubectl proxy`를 끄고 `curl`을 다시 치면?
- `DELETE` 요청을 `curl`로 보내면 Pod가 지워지는가? (지우지 말고 생각만 한다)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 사람이 보는 화면(HTML)과 API가 주는 JSON의 차이를 한 문장으로 말한다.
- [ ] `kubectl`이 "심부름꾼"이라는 말은 무엇을 뜻하는가? 내 말로 설명한다.
- [ ] 인증 없이 열린 통로(`kubectl proxy`)가 위험한 이유를 11일차 최소 개방과 엮어 적는다.
