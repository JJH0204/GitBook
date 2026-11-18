# VN-Pipeline 작업 큐와 라이브러리·갤러리

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-VNP-004-DO |
| 유형 | D&O (구조와 동작 원리) |
| 목적 | 작업 큐(`jobs.py`), 라이브러리(`library.py`), 갤러리(`gallery.py`)와 곁가지(다운로드, 캐릭터 API)의 구조와 데이터 흐름을 설명한다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [server.md](server.md) | PRJ-VNP-003-REF | VN-Pipeline 서버: 라우팅과 요청 처리 |
| [graphs-presets.md](graphs-presets.md) | PRJ-VNP-101-DO | VN-Pipeline 생성 그래프와 프리셋 |

## 이 영역이 하는 일

세 모듈은 "생성 요청 → 진행 추적 → 결과 관리"의 앞·가운데·뒤를 맡는다.

| 모듈 | 단계 | 한 줄 요약 |
|---|---|---|
| `studio/library.py` | 요청 전 | 어떤 모델·프리셋·설정으로 만들지 정한다 |
| `studio/jobs.py` | 요청 중 | 그래프를 엔진에 제출하고, 엔진의 이벤트로 진행률과 결과를 추적한다 |
| `studio/gallery.py` | 요청 후 | 저장된 이미지를 훑어 목록·메타데이터·썸네일로 보인다 |

## 구성 요소

| 파일 | 줄 | 핵심 클래스·함수 | 역할 |
|---|---|---|---|
| `studio/jobs.py` | 1,069 | `JobStore`, `JobState`, `JobManager`, `sanitize_spec`, `graph_weights`, `check_models` | 작업 기록 저장, 진행 추적, 입력 검증 |
| `studio/comfy_link.py` | 610 | `ComfyLink` | 엔진 HTTP·WebSocket·프로세스 관리 |
| `studio/library.py` | 352 | `Library`, `scan_models`, `SETTING_RULES` | 모델 스캔, 프리셋, LoRA 메모, 설정 저장 |
| `studio/gallery.py` | 611 | `Gallery`, `classify`, `read_meta`, `_make_thumb` | 스캔, 메타데이터, 썸네일, 휴지통 |
| `studio/downloads.py` | 249 | `DownloadManager` | 모델 URL 다운로드 |
| `studio/chars_api.py` | 146 | `create`, `update`, `delete`, `set_seed` | 캐릭터 입력 검증과 저장 |
| `studio/events.py` | 57 | `EventHub` | SSE 방송 |

## 동작 원리

### 1. 작업의 생애

```
 submit ──> queued ──> running ──> done
              |           |   \──> error
              |           \────> cancelled
              \──────────────> cancelled (대기 중 취소)

 상태 값: queued / running / done / error / cancelled   (TERMINAL = done, error, cancelled)
```

작업 한 건은 두 곳에 산다.

| 위치 | 내용 | 수명 |
|---|---|---|
| `JobStore` (SQLite, `user/studio/jobs.sqlite3`) | `jobs`(id, 생성 시각, prompt_id, 상태, 작업 JSON, 내부 추적 정보), `outputs`(이미지 경로 → 작업·시드·프리셋) | 영구 |
| `JobManager.active` / `JobState` | 진행 중 작업의 추적 정보: 노드 제목, 가중치, 캐시된 노드, 끝난 노드, 현재 노드와 스텝 | 작업이 끝날 때까지 메모리 |

DB는 WAL 모드(`journal_mode=WAL`, `synchronous=NORMAL`)로 열고, 파일이 손상돼 열리지 않으면 `.broken-<날짜시간>`으로 옮기고 새로 만든다.

### 2. 제출

`JobManager.submit`의 순서는 [서버](server.md)의 흐름 그림 5단계와 같다. 설계상 중요한 점은 세 가지다.

* **`prompt_id`를 서버가 먼저 정한다.** 엔진에 넘기는 요청에 UUID를 실어, 실행 시작 메시지를 놓치지 않게 한다. 엔진이 다른 ID를 돌려주면(구버전) 그 값으로 바꾼다.
* **응답이 늦어도 버리지 않는다.** `/prompt` 응답이 시간 안에 오지 않으면(`ComfyTimeout`) 접수된 것으로 보고 `prompt_id`로 계속 추적한다. 실제로 없으면 `reconcile`이 곧 "기록을 찾을 수 없음" 오류로 정리한다.
* **제출 전에 모델 파일을 확인한다.** `check_models`가 체크포인트·LoRA·업스케일러·ControlNet 파일이 있는지 보고, 없으면 한국어 400 오류로 돌려준다. 엔진이 내는 긴 영어 오류를 사용자가 보지 않게 하려는 것이다.

### 3. 진행률 계산

엔진은 "지금 몇 번째 스텝"만 알려 준다. 서버는 그래프의 모든 노드에 가중치를 매겨 전체 진행률을 만든다.

| 노드 종류 | 가중치 |
|---|---|
| 샘플러(`KSampler` 등) | 스텝 수 (ControlNet이 걸린 샘플러는 ×1.4) |
| `FaceDetailer` | 스텝 수 × 0.8 |
| 체크포인트 로더 | 4.0 |
| 업스케일·배경 제거 | 3.0 |
| `ControlNetLoader` | 2.0 |
| `VAEDecode`, `VAEEncode` | 1.5 |
| 그 밖 | 0.3 |

{% code title="studio/jobs.py (JobState.update_progress, 발췌)" %}
```python
total_w = sum(self.weights[k] for k in todo) or 1.0
done_w = sum(self.weights[k] for k in done)
...
pct = round(min(99.5, (done_w + frac) / total_w * 100.0), 1)
p["percent"] = pct if allow_drop else max(pct, float(p.get("percent") or 0.0))
```
{% endcode %}

* `todo`는 전체 노드에서 엔진이 캐시로 건너뛴 노드(`execution_cached`)를 뺀 것이다. 캐시된 노드는 완료로 친다.
* 진행률은 99.5%에서 멈추고, `done`이 확정될 때 100%로 올린다.
* `max(...)`로 뒤로 가지 않게 한다. 얼굴·손 보정은 감지된 영역마다 스텝이 0부터 다시 시작하기 때문이다. 서버 재시작으로 중간부터 추적하는 작업만 한 번 내려갈 수 있다(`allow_drop`).

### 4. 엔진 메시지 처리

`ComfyLink.ws_loop`가 WebSocket을 상시 연결하고(끊기면 2초 뒤 재접속), 메시지를 `JobManager.on_message`·`on_binary`로 넘긴다.

| 엔진 메시지 | 처리 |
|---|---|
| `execution_start` | 해당 작업을 `running`으로 표시 |
| `execution_cached` | 캐시된 노드 집합 기록, 진행률 갱신 |
| `executing` (노드 있음) | 이전 노드를 끝난 것으로, 현재 노드를 갱신 |
| `executing` (노드 `null`) | 이 prompt 완료 → `finalize` |
| `progress` | 현재 노드의 `step/steps` 갱신 |
| `progress_state` | 재개 작업의 끝난 노드를 정확히 맞춤 |
| `executed` | 출력 이미지 정보 저장 |
| `execution_success` / `execution_error` / `execution_interrupted` | `finalize`에 힌트와 함께 전달 |
| 바이너리 | 미리보기 이미지(타입 1, 4) → 최근 24개까지 메모리에 보관, `preview` 이벤트 방송 |

`finalize`는 엔진의 `/history/{prompt_id}`를 "단일 진실 공급원"으로 본다. history가 있으면 거기서 상태와 출력 파일을 확정하고, 없으면 WebSocket에서 받은 정보와 힌트로 판단한다.

### 5. 어긋남 보정과 복구

| 장치 | 언제 | 하는 일 |
|---|---|---|
| `reconcile` | `status_loop`에서 약 2초마다 | `/queue` 기준으로 대기 순번 갱신, 대기열에도 실행 중에도 없는 작업을 `finalize` |
| 엔진 연결 끊김 | 연속 3회 이상 연결 실패 | 활성 작업을 오류로 종료("엔진이 종료되었을 수 있습니다") |
| `on_comfy_stopping` | 사용자가 엔진을 중지·재시작 | 활성 작업을 취소 처리 |
| `recover` | 서버 시작 시 | DB의 `queued`/`running` 작업을 엔진의 큐·history와 대조해 추적을 재개하거나 확정. 근거가 없으면 "서버 재시작으로 추적 불가" 오류 |
| `_cancel_watchdog` | 실행 중 작업을 취소한 뒤 | 20초 안에 중단 메시지가 안 오면 강제로 확정 |

### 6. 라이브러리

`Library`는 설정 파일과 모델 폴더의 창구다.

* **모델 스캔** (`scan_models`, 스레드에서 실행): 체크포인트·LoRA 파일의 safetensors 헤더만 읽고 파일 수정 시각으로 캐시한다. 7GB 체크포인트도 헤더만 읽는다.
* **호환성 판정**: LoRA마다 프리셋별로 `ok / warn / bad`와 이유를 계산한다(`modelinfo.compatibility`). 프리셋의 체크포인트 파일이 없으면 `warn`이다.
* **프리셋 저장**: 이름 형식(`^[a-z0-9][a-z0-9_-]{0,39}$`), 체크포인트 존재, `cfg` 1~20, `steps` 5~80, 샘플러·스케줄러(엔진에서 읽은 목록 기준)를 검증한다.
* **프리셋 삭제**: 기본 프리셋과 마지막 1개는 거부하고, 그 프리셋을 쓰던 캐릭터는 모델 지정을 비워 기본 프리셋으로 돌린다.
* **전역 설정 저장**: `SETTING_RULES`의 숫자 키는 범위를 검증하고, 목록에 없는 키는 값이 같을 때만 조용히 넘기고 다르면 `ignored`에 담는다. 원격 접속 키와 `comfy_url`, `studio_port`는 이 경로로 바꿀 수 없다.

| 설정 키 | 범위 |
|---|---|
| `hires_scale` | 1.0~2.0 |
| `hires_steps`, `detail_steps` | 4~60 |
| `hires_denoise`, `face_denoise`, `hand_denoise`, `expr_denoise` | 0.05~1.0 |
| `tagger_threshold` / `tagger_char_threshold` | 0.05~0.95 / 0.3~0.99 |
| `pose_strength` / `pose_end` | 0.1~2.0 / 0.1~1.0 |

### 7. 갤러리

갤러리는 DB 없이 디스크를 읽는 쪽이다. 작업 DB는 보조 정보(작업 ID, 시드, 프리셋)로만 쓴다.

```
 GET /api/gallery ──> Gallery.scan(): output/ 을 os.scandir 로 순회
                        (숨김 폴더·.trash·심볼릭 링크·output/motion 제외, 확장자 png/jpg/jpeg/webp)
                  ──> mtime 내림차순 정렬 ──> folder/char/kind/검색어 필터 ──> offset/limit 페이지
                  ──> 페이지의 항목만 read_meta (PNG 텍스트 청크의 ComfyUI 그래프를 해석)
                  ──> 작업 DB(outputs 표)로 job_id·시드·프리셋 보충
```

* **종류 판정** (`classify`): 경로 규칙으로 정한다. `prompt/` → prompt, `backgrounds/` → bg, `pixel/`, `sheets/`, `icons/`, `<캐릭터>/concept|sprite|cg/`. 시크릿 폴더(`_secret/`)는 접두사를 떼고 같은 규칙을 쓴다.
* **메타데이터**: PNG의 `prompt` 텍스트 청크(엔진이 저장 시 넣는 그래프 JSON)를 해석해 긍정·부정 프롬프트, 시드, 체크포인트, LoRA, 샘플러, 포즈를 뽑는다. 청크가 없으면 `parameters`(다른 도구 형식)를 시도한다. 파일 수정 시각과 크기로 메모리에 캐시한다.
* **썸네일** (`thumb`): 요청한 너비를 규격(96~1024) 중 가장 가까운 것으로 맞추고, `해시-너비-수정시각-크기` 이름으로 `user/studio/thumbs/`에 캐시한다. 같은 이미지를 동시에 요청하면 한 번만 만들고(`_inflight`), 동시 생성은 3개로 제한한다. 작은 도트 그림은 정수 배 최근접 확대 후 무손실로 저장해 흐려지지 않게 한다.
* **삭제**: `output/.trash/<원래 경로>`로 이동한다. 같은 이름이 있으면 시각을 붙인다. 시크릿 그림은 이동하지 않고 바로 지운다. 한 번에 1,000개까지다.

### 8. 곁가지: 다운로드와 캐릭터

* **다운로드** (`DownloadManager`): `http(s)`만 받고 폴더는 `checkpoints`, `loras`, `upscale_models` 세 가지로 제한한다. 확장자는 `.safetensors`, `.pth`, `.pt`, `.ckpt`만 허용한다. `.part` 파일로 받고, 크기가 맞는지와 safetensors 헤더가 올바른지 확인한 뒤 `os.replace`로 이름을 바꾼다. 같은 이름이 어느 모델 폴더에든 있으면 409로 거절해, 기존 모델을 조용히 가리지 않게 한다. 디스크 여유가 파일 크기 + 512MB보다 적으면 507로 거절한다. 토큰은 설정에서 읽어 요청 주소에만 붙이고, 목록에 보이는 주소에서는 지운다.
* **캐릭터** (`chars_api`): 필드별 길이 한도와 시드(0~2³²−1) 범위를 검증하고, 프리셋 이름이 실제로 있는지 확인한다. 저장은 `vnlib.characters`가 하고, 삭제는 휴지통(`user/trash/characters`)으로 옮긴다.

## 핵심 코드 해설

{% code title="studio/jobs.py (JobManager.submit, 발췌)" %}
```python
for n in graph.values():
    if n.get("class_type") == "SaveImage":
        n.setdefault("inputs", {})["studio_job"] = job_id
prompt_id = str(uuid.uuid4())   # 미리 정해서 넘기면 실행 시작 메시지를 놓치지 않는다
```
{% endcode %}

* `studio_job`은 노드가 선언하지 않은 입력이라 노드 동작에는 영향이 없고, 엔진의 캐시 키에만 들어간다. 같은 그래프를 다시 제출해도 저장 노드가 새로 실행된다.
* CLI(`vn.py`)는 같은 목적으로 `cli_run` 입력을 쓴다.

{% code title="studio/jobs.py (JobManager.reconcile, 발췌)" %}
```python
if pid in running:
    ...
    continue
if pid in pending:
    pos = pending.index(pid) + 1 + len(running)
    ...
    continue
if time.time() - st.submitted < 4 or st.finalizing:
    continue
self._spawn(self.finalize(st))
```
{% endcode %}

* 엔진의 `/queue`를 정답으로 삼아 "실행 중 / 대기 중 / 둘 다 아님"을 가른다. 둘 다 아니면 끝났거나 사라진 것이므로 `finalize`가 history로 확인한다.
* 제출 직후 4초는 기다린다. 접수와 큐 반영 사이의 틈에서 잘못 종료하지 않기 위해서다.

## 따라 만들기

1. 작업 한 건을 JSON 하나(`id`, `spec`, `status`, `progress`, `outputs`)로 정의한다. → 결과: DB·SSE·API가 같은 모양을 쓴다.
2. SQLite에 `jobs`, `outputs` 표를 만들고 WAL 모드로 연다. → 결과: 읽기와 쓰기가 서로 막지 않는다.
3. 제출 함수에서 입력 검증 → 그래프 생성 → 모델 파일 확인 → 엔진 제출 → 기록 저장 순서를 지킨다. → 결과: 잘못된 요청이 엔진까지 가지 않는다.
4. 엔진 WebSocket을 상시 연결하고, `prompt_id`로 작업을 찾아 노드별 진행을 기록한다. → 결과: 진행 단계명이 화면에 뜬다.
5. 노드 가중치 표로 진행률을 계산하고 뒤로 가지 않게 한다. → 결과: 진행 막대가 매끄럽다.
6. 주기 점검(`reconcile`)과 시작 시 복구(`recover`)를 넣는다. → 결과: 메시지를 놓치거나 서버를 재시작해도 작업이 "진행 중"에 멈춰 있지 않는다.
7. 갤러리는 폴더를 직접 스캔하고 PNG 텍스트 청크에서 프롬프트를 읽는다. → 결과: 작업 DB가 없는 파일도 정보가 보인다.
8. 썸네일을 수정 시각이 든 이름으로 캐시한다. → 결과: 파일이 바뀌면 새 썸네일이 만들어지고 옛것은 지워진다.

## 알려진 한계·주의

* 작업 큐의 실제 대기열은 ComfyUI가 가진다. 서버는 그 상태를 읽어 보여 줄 뿐이라, 엔진을 직접 조작하면(다른 클라이언트로 제출 등) 서버가 모르는 작업이 생긴다.
* `_secret/`과 `output/motion/`처럼 갤러리 스캔이 특별 취급하는 폴더가 있다. 새 출력 폴더를 만들 때 `classify`와 `scan`을 함께 확인해야 한다.
* 갤러리 목록은 요청마다 `output/` 전체를 훑는다. 파일이 수만 장으로 늘면 느려질 수 있다(이 레포에는 이를 위한 색인이 없다).
* `GET /api/settings`는 `config/settings.json` 전체를 돌려준다. 이 파일에는 선택 입력인 다운로드 토큰 칸이 있어, 원격 허용 사용자에게 그 칸이 보일 수 있는지 확인이 필요하다(확인 필요, 실행해 보지 않았다).

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 엔진이 스텝만 알려 주는데 전체 진행률을 노드 가중치로 계산하게 한 이유를 내 말로 적어 보자.
- [ ] 서버를 재시작했을 때 진행 중이던 작업을 어떻게 이어 갔는지 겪은 문제와 함께 적어 보자.
- [ ] 갤러리를 DB가 아니라 디스크 스캔 방식으로 만든 장단점을 적어 보자.
