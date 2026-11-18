# VN-Pipeline 서버: 라우팅과 요청 처리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-VNP-003-REF |
| 유형 | REF (API 경로 표) + 처리 흐름 해설 |
| 목적 | `studio/server.py`의 구성, 미들웨어, API 경로, 요청 한 건의 처리 흐름을 보인다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 것이며 서버를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [structure.md](structure.md) | PRJ-VNP-002-REF | VN-Pipeline 구조 지도: 디렉터리와 진입점 |
| [jobs-library.md](jobs-library.md) | PRJ-VNP-004-DO | VN-Pipeline 작업 큐와 라이브러리·갤러리 |
| [secret-remote.md](secret-remote.md) | PRJ-VNP-005-DO | VN-Pipeline 시크릿 모드와 원격 접속 |

## 이 영역이 하는 일

`studio/server.py`(833줄)는 `aiohttp` 앱을 만들고, 라우트를 등록하고, 미들웨어 두 개(`errors`, `guard`)를 건다. 실제 일은 모듈별 매니저 객체가 한다. 서버 파일은 "요청을 받아 매니저에 넘기고 JSON으로 돌려주는" 얇은 층이다.

## 구성 요소

| 객체 | 파일 | 맡는 일 |
|---|---|---|
| `Studio` | `studio/server.py` | 모든 매니저를 묶는 앱 상태, 상태 방송 루프, 시작·종료 순서 |
| `EventHub` | `studio/events.py` | SSE 구독자 큐, 이벤트 방송 |
| `ComfyLink` | `studio/comfy_link.py` | ComfyUI HTTP·WebSocket·프로세스 관리 |
| `JobManager` | `studio/jobs.py` | 작업 제출·추적·취소·복구 |
| `Library` | `studio/library.py` | 모델 스캔, 프리셋, LoRA 메모, 설정 |
| `Gallery` | `studio/gallery.py` | 이미지 스캔, 메타데이터, 썸네일, 휴지통 |
| `DownloadManager` | `studio/downloads.py` | 모델 URL 다운로드 |
| `Tagging`, `Poses`, `Motion` | `studio/tagging.py`, `poses.py`, `motion.py` | 태그 추출, 포즈 라이브러리, 모션 |
| `Remote` | `studio/remote.py` | 원격 요청 판별, 테일넷 상태 |
| `Secret` | `studio/secret.py` | 시크릿 모드 |
| `chars_api` | `studio/chars_api.py` | 캐릭터 CRUD (함수 모음) |
| `common` | `studio/common.py` | 경로 상수, `ApiError`, JSON 응답, `safe_path`, 값 검증, `Throttle` |

## 요청 처리 층

```
 요청 --> [errors 미들웨어] --> [guard 미들웨어] --> 라우트 핸들러 --> 매니저 --> JSON 응답
              ^  예외를 JSON 오류로 변환      |
              |                              +-- Host·원격·Origin 검사 (실패하면 403, 핸들러까지 가지 않음)
              +-- 핸들러에서 던진 ApiError / HTTPException / 그 밖의 예외
```

### `errors` 미들웨어

| 잡는 예외 | 응답 |
|---|---|
| `config.ConfigError` | 500, 설정 파일 경로가 든 한국어 메시지 |
| `ApiError(status, message, **extra)` | `status`와 `{"error": message, ...extra}` |
| `web.HTTPException`(400 이상) | `HTTP_MESSAGES` 표의 한국어 문구 |
| 그 밖의 예외 | 500, 예외 이름과 메시지(최대 500자). 로그에 스택을 남긴다 |

오류 응답은 항상 `{"error": "한국어 메시지"}` 모양이다. 화면은 이 키 하나만 보고 알림을 띄운다.

### `guard` 미들웨어

1. `remote.identify(request, port, app_session)`로 요청이 로컬인지, 허용된 원격 사용자인지 판별한다. 모르는 Host(DNS 리바인딩)나 허용되지 않은 원격은 `Denied`(403)로 끝난다.
2. 원격 요청이면 `remote.local_only_reason`으로 "로컬에서만 되는 동작"인지 확인한다.
3. 상태를 바꾸는 메서드(`POST`, `PUT`, `DELETE`, `PATCH`)는 `remote.check_origin`으로 `Origin` 헤더가 같은 쪽인지 확인한다(CSRF 방지). `Origin`이 없으면 통과한다.
4. 판별 결과를 `request["client"]`에 넣고, 변경 요청은 로그에 한 줄 남긴다(원격이면 로그인 이름과 IP 표시).

판별 규칙의 상세는 [시크릿 모드와 원격 접속](secret-remote.md)에 있다.

## API 경로 표

`원격` 칸의 "로컬"은 원격(테일넷) 요청을 `guard`가 막는 경로다. 요청 본문이 JSON인 경로는 `read_json`을 거치며, 본문은 JSON 객체여야 하고 앱 전체 한도는 8MB다. `multipart` 업로드는 핸들러가 스트리밍으로 크기를 따로 검사한다.

### 정적·파일

| 메서드 | 경로 | 역할 | 원격 |
|---|---|---|---|
| GET | `/` | `studio/web/index.html` (없으면 안내 페이지) | 허용 |
| GET | `/favicon.ico` | 파비콘, 없으면 204 | 허용 |
| GET | `/static/{path}` | `studio/web/` 아래 파일 (`safe_path`로 경로 탈출 차단, `no-cache`) | 허용 |
| GET | `/files/{path}` | `output/` 아래 파일 원본. `?download=1`이면 첨부 파일 헤더 | 허용 |
| GET | `/thumbs/{path}?w=` | 썸네일(`w`는 32~2048, 가까운 규격으로 맞춤) | 허용 |
| GET | `/poses/{name}`, `/poses/{name}/src` | 포즈 PNG, 원본 미리보기 JPEG | 허용 |

### 상태·엔진

| 메서드 | 경로 | 역할 | 원격 |
|---|---|---|---|
| GET | `/api/ping` | 엔진을 기다리지 않는 생존 확인(버전, 포트, PID) | 허용 |
| GET | `/api/status` | 엔진 상태, 큐, 다운로드, 작업, 원격·시크릿 요약, 설정 복구 경고, 요청자 `client` | 허용 |
| POST | `/api/comfy/start` | `start.sh` 실행 | 허용 |
| POST | `/api/comfy/stop` | 엔진 중지(진행 중 작업은 취소 처리) | 허용 |
| POST | `/api/comfy/restart` | 엔진 재시작 | 허용 |
| GET | `/api/comfy/log?lines=` | 엔진 로그 끝부분(1~3000줄) | 허용 |
| POST | `/api/shutdown` | Studio 종료(엔진도 함께, `stop_comfy`로 끌 수 있음) | 로컬 |
| GET | `/api/events` | SSE 스트림 | 허용 |

### 모델·프리셋·설정·다운로드

| 메서드 | 경로 | 역할 | 원격 |
|---|---|---|---|
| GET | `/api/models` | 체크포인트·LoRA·업스케일러·ControlNet 목록, 호환성, 샘플러 목록 | 허용 |
| GET | `/api/presets` | 프리셋과 기본 프리셋 | 허용 |
| PUT | `/api/presets/{name}` | 프리셋 저장(검증 후) | 허용 |
| DELETE | `/api/presets/{name}` | 프리셋 삭제(기본·마지막 1개는 거부) | 허용 |
| POST | `/api/presets/default` | 기본 프리셋 지정 | 허용 |
| PUT | `/api/loras/{filename}/meta` | LoRA 메모(트리거·강도·설명) 저장 | 허용 |
| GET / PUT | `/api/settings` | 전역 설정 읽기 / 저장(허용 키만, 범위 검증) | 허용 |
| POST | `/api/models/download` | 모델 URL 다운로드 시작 | 허용 |
| GET | `/api/downloads` | 다운로드 목록 | 허용 |
| POST | `/api/downloads/{id}/cancel` | 다운로드 취소 | 허용 |

### 캐릭터

| 메서드 | 경로 | 역할 | 원격 |
|---|---|---|---|
| GET | `/api/characters` | 목록(썸네일·종류별 장수 포함) | 허용 |
| POST | `/api/characters` | 새 캐릭터(ID 중복 409, 예약어 `template`·`new` 거부) | 허용 |
| GET | `/api/characters/template` | 빈 캐릭터 틀 | 허용 |
| GET / PUT / DELETE | `/api/characters/{id}` | 읽기 / 수정(ID 변경 불가) / 휴지통으로 이동 | 허용 |
| POST | `/api/characters/{id}/seed` | 시드만 갱신 | 허용 |

### 작업

| 메서드 | 경로 | 역할 | 원격 |
|---|---|---|---|
| POST | `/api/jobs` | JobSpec 제출 → `{"job": ...}` | 허용 |
| GET | `/api/jobs?limit=&status=` | 최신순 목록(1~1000) | 허용 |
| GET / DELETE | `/api/jobs/{id}` | 조회 / 기록 삭제(진행 중이면 409) | 허용 |
| POST | `/api/jobs/{id}/cancel` | 취소 | 허용 |
| POST | `/api/jobs/{id}/retry` | 같은 spec으로 다시 제출 | 허용 |
| GET | `/api/jobs/{id}/preview` | 최신 실시간 미리보기 이미지 | 허용 |

### 갤러리·폴더

| 메서드 | 경로 | 역할 | 원격 |
|---|---|---|---|
| GET | `/api/gallery` | 폴더·검색어·캐릭터·종류 필터, `limit` 1~500, `offset` | 허용 |
| GET | `/api/gallery/info?path=` | 이미지 1장의 프롬프트·시드·모델·LoRA·포즈 정보 | 허용 |
| POST | `/api/gallery/delete` | 휴지통(`output/.trash/`)으로 이동(시크릿 그림은 즉시 삭제) | 허용 |
| POST | `/api/gallery/reveal` | Finder에서 보기(`open -R`) | 로컬 |
| POST | `/api/open-folder` | 지정한 폴더 열기(`which`는 허용 목록 12개) | 로컬 |

### 태그·포즈·모션

| 메서드 | 경로 | 역할 | 원격 |
|---|---|---|---|
| GET | `/api/tagger` | 태거 모델 목록과 사용 가능 여부 | 허용 |
| POST | `/api/interrogate` | 이미지(multipart 20MB 이하) 또는 `{path}`에서 태그 추출 | 허용 |
| GET / POST | `/api/poses` | 포즈 목록 / 포즈 저장(3D 관절 또는 그려진 그림) | 허용 |
| POST | `/api/poses/detect` | 그림에서 자세 감지 | 허용 |
| GET / DELETE | `/api/poses/{name}` | 관절 좌표 포함 조회 / 휴지통으로(쓰는 작업이 있으면 409) | 허용 |
| GET | `/api/motion` | 모션 개요(실행 중인 것, 클립 목록, 소요 시간 통계) | 허용 |
| POST | `/api/motion/uploads` | 영상 업로드(디스크로 스트리밍, 최대 16GB) | 허용 |
| GET | `/api/motion/uploads/{id}` | 업로드 정보 | 허용 |
| GET | `/api/motion/uploads/{id}/frame?t=` | 해당 시각 프레임 JPEG | 허용 |
| POST | `/api/motion/runs` | 동작 추정 시작 | 허용 |
| POST | `/api/motion/runs/cancel` | 진행 중인 추정 취소 | 허용 |
| POST | `/api/motion/clips/{name}/export` | 보정만 바꿔 다시 내보내기 | 허용 |
| GET | `/api/motion/clips/{name}/bundle?smooth=` | Unity용 zip | 허용 |
| DELETE | `/api/motion/clips/{name}` | 클립 폴더를 휴지통으로 | 허용 |

### 시크릿·원격

| 메서드 | 경로 | 역할 | 원격 |
|---|---|---|---|
| GET | `/api/secret` | 시크릿 상태와 쌓인 양(파일 수·바이트·작업 수) | 허용 |
| POST | `/api/secret/enable` | 켜기 | 허용 |
| POST | `/api/secret/disable` | 끄기(기록 삭제) | 허용 |
| GET | `/api/remote` | 원격 접속 상태 | 허용 |
| PUT | `/api/remote` | 허용 계정 목록 변경 | 로컬 |
| POST | `/api/remote/enable` | 원격 접속 켜기 | 로컬 |
| POST | `/api/remote/disable` | 원격 접속 끄기 | 로컬 |

{% hint style="info" %}
NOTE: 포즈·모션·태그 라우트의 내부 동작은 이 시리즈의 [포즈 ControlNet](pose-controlnet.md), [모션 파이프라인](motion.md), [태깅·도트·아이콘](tagging-icons-dots.md)에서 다룬다.
{% endhint %}

## 요청 한 건의 처리 흐름

가장 긴 경로인 `POST /api/jobs`(생성 요청)를 따라간다.

```
 1. 브라우저 --POST /api/jobs {mode, prompt, ...}--> server
 2. errors  : try 시작
 3. guard   : identify -> (원격이면 local_only 확인) -> check_origin -> request["client"] 저장 -> 로그 한 줄
 4. job_submit : body = read_json(request)           # JSON 객체 아니면 400
 5. JobManager.submit(body)
      a. sanitize_spec(body)      허용 키만 남기고 값 범위 검증 (잘못되면 400)
      b. graphs.build(spec)       ComfyUI API 그래프 + 단계명 + 시드 + 저장 접두사 (실패하면 400)
      c. check_models(graph)      그래프가 쓰는 모델 파일이 있는지 확인
      d. 시크릿 모드면 저장 접두사를 _secret/ 아래로 바꿈
      e. job_id, prompt_id(uuid) 발급, SaveImage 마다 studio_job=<job_id> 를 넣어 실행 캐시 재사용 방지
      f. ComfyLink.post_json("/prompt", ...)  -- 엔진이 꺼져 있으면 503, 거절하면 400/502
      g. JobStore.save(job) 로 SQLite 에 기록, EventHub 로 job 이벤트 방송
 6. server  : s.poke() 로 status 이벤트 점검 -> {"job": {...}} JSON 응답
 7. (이후, 별도 경로) ComfyUI WebSocket 메시지 -> JobManager.on_message -> 진행률 갱신 -> SSE 방송
    완료 메시지 -> /history/{prompt_id} 로 출력 파일 확정 -> status=done
```

5단계 e의 `studio_job` 입력은 노드가 선언하지 않은 값이라 노드에는 전달되지 않고 ComfyUI의 캐시 키에만 반영된다. 같은 설정을 다시 걸어도 저장 노드는 새로 실행되고, 앞쪽 계산 결과는 캐시를 재사용한다.

## 핵심 코드 해설

{% code title="studio/server.py (guard 미들웨어, 발췌)" %}
```python
client = remote.identify(request, port, request.app["studio"].remote.app_session)
if client["remote"]:
    reason = remote.local_only_reason(request)
    if reason:  # 종료·Finder 열기·원격 설정 변경은 Mac에서만
        raise remote.Denied("local_only", reason)
# CSRF 방지: 상태를 바꾸는 요청은 같은 출처만 (Origin 이 있을 때)
if request.method in MUTATING:
    remote.check_origin(request, client, port)
```
{% endcode %}

* 검사는 라우트 핸들러보다 먼저 일어난다. 핸들러는 허용된 요청만 받는다.
* `local_only_reason`은 요청 경로 문자열이 아니라 aiohttp가 실제로 고른 라우트(`resource.canonical`)로 비교한다. 경로 표기를 바꿔서 차단을 피하는 방법이 통하지 않게 하려는 설계다.

{% code title="studio/server.py (SSE 핸들러, 발췌)" %}
```python
sub = s.hub.subscribe()  # 스냅샷보다 먼저 구독 → 사이의 이벤트 유실 없음
try:
    await resp.write(b"retry: 3000\n\n" + encode_event("status", dict(s.status(), client=client)))
    for job in s.jobs.active_jobs():
        await resp.write(encode_event("job", job))
```
{% endcode %}

* 구독을 먼저 하고 현재 상태를 보낸다. 그래야 스냅샷을 만드는 사이에 생긴 이벤트를 놓치지 않는다.
* 연결 직후 진행 중인 작업, 받는 중인 다운로드, 모션 상태를 한 번씩 보내 화면을 맞춘다. 이후 15초마다 `: ping` 줄을 보낸다.
* `EventHub.publish`는 큐(최대 2,000개)가 가득 찬 느린 구독자를 끊는다. 브라우저의 `EventSource`가 자동으로 다시 붙는다.

### 방송되는 이벤트

| 이벤트 | 보내는 곳 | 내용 |
|---|---|---|
| `status` | `Studio._maybe_publish_status` | 상태 요약. 값이 바뀔 때, 그리고 10초마다 |
| `job` | `JobManager._send_job` | 작업 객체 전체. 진행 이벤트는 작업당 빈도를 제한한다 |
| `preview` | `JobManager._send_preview` | `{job_id, t}`. 화면이 `/api/jobs/{id}/preview`를 다시 요청한다 |
| `download` | `DownloadManager._emit` | 다운로드 객체 |
| `motion` | `Motion.publish` | 모션 실행 상태 |
| `log` | `ComfyLink` | 엔진 로그 새 줄(최대 200줄) |

## 시작과 종료 순서

| 단계 | 시작(`startup`, `_boot`) | 종료(`shutdown`) |
|---|---|---|
| 1 | ComfyUI 연결 열기, 실행 방식 로그(앱 세션 여부) | 모든 SSE 연결 닫기 |
| 2 | 백그라운드 태스크: WebSocket 루프, 로그 꼬리 읽기, `_boot`, 원격 세션 시작 | 태스크 취소 |
| 3 | 작업 복구(`jobs.recover`) | 시크릿 기록 삭제(DB를 닫기 전, 20초 제한) |
| 4 | 지난번 시크릿 잔여물 정리 | 다운로드·태깅·포즈·모션 정리, 원격 Serve 떼기 |
| 5 | 필요하면 ComfyUI 자동 시작 | 작업 DB·엔진 연결 닫기, 시크릿 파일 최종 삭제 |
| 6 | 2초마다 상태 점검 루프(`status_loop`) | |

## 따라 만들기

1. `aiohttp`로 `web.Application`을 만들고 `127.0.0.1`에만 바인드한다. → 결과: 같은 PC의 브라우저에서만 열린다.
2. `ApiError(status, message)`를 정의하고, 미들웨어에서 `{"error": message}` JSON으로 바꾼다. → 결과: 모든 오류가 같은 모양이다.
3. `safe_path(base, rel)`을 만든다. `..`, 절대 경로, 숨김 경로, 링크로 폴더 밖을 가리키는 경우를 모두 막는다. → 결과: 파일 제공 경로가 폴더 밖으로 나가지 않는다.
4. `guard` 미들웨어에서 Host·Origin을 검사한다. → 결과: 다른 사이트의 페이지가 로컬 서버에 변경 요청을 보내지 못한다.
5. 매니저 객체(작업, 갤러리, 라이브러리)를 `Studio` 하나에 묶고 핸들러는 매니저를 부르기만 한다. → 결과: 라우트 파일이 얇게 유지된다.
6. `EventHub`(구독자별 `asyncio.Queue`)와 SSE 핸들러를 만든다. → 결과: 화면이 폴링 없이 진행률을 받는다.
7. `startup`에서 백그라운드 태스크와 작업 복구를 시작하고 `shutdown`에서 역순으로 정리한다. → 결과: 재시작해도 진행 중이던 작업 기록이 이어진다.

## 알려진 한계·주의

* 라우트 등록 코드가 한 함수(`setup_routes`) 안에 모여 있어 파일이 길다. 핸들러는 짧고 일은 매니저에 있다.
* `Studio.status()`의 `"secret"` 항목 줄에 원격 항목의 주석이 붙어 있다(`# {enabled, url|null}`). 동작에는 영향이 없는 주석 위치 오류다.
* `server.py`에서 `quote`를 파일 위쪽과 `files` 핸들러 안에서 두 번 가져온다. 동작에는 영향이 없다.
* `/api/gallery/reveal`, `/api/open-folder`는 macOS의 `/usr/bin/open`을 부른다. 다른 OS에서는 동작하지 않는다.
* 설계 문서의 API 목록은 코드보다 오래됐다(예: `/api/jobs?status=`, 갤러리 `kind` 필터). 이 페이지는 코드를 기준으로 썼다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 검사 로직을 핸들러마다 두지 않고 미들웨어 한 곳에 모은 이유를 내 말로 적어 보자.
- [ ] 진행률을 폴링 대신 SSE로 보내게 했을 때 얻은 점과 불편했던 점을 적어 보자.
- [ ] 요청 한 건이 서버 안에서 거치는 층을 내 말로 순서대로 설명해 보자.
