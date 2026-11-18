# VN-Pipeline 구조 지도: 디렉터리와 진입점

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-VNP-002-REF |
| 유형 | REF (파일·진입점 목록) |
| 목적 | 레포의 디렉터리와 세 가지 진입점(`vn.py`, `studio.sh`, `start.sh`)의 역할과 실행 순서를 보인다 |
| 확인 상태 | 미검증 (소스를 읽고 쓴 것이며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [README.md](README.md) | PRJ-VNP-001-DO | VN-Pipeline 해체 분석 |
| [server.md](server.md) | PRJ-VNP-003-REF | VN-Pipeline 서버: 라우팅과 요청 처리 |

## 이 영역이 하는 일

레포는 "그래프를 만드는 라이브러리"(`vnlib/`), 그 라이브러리를 부르는 두 얼굴(CLI `vn.py`, 웹 서버 `studio/`), 외부 엔진(ComfyUI)을 켜는 스크립트로 나뉜다. 어떤 파일이 어느 계층에 속하는지를 먼저 알면 이후 페이지가 쉬워진다.

## 디렉터리 지도

레포 기준 상대 경로다. 줄 수는 읽은 시점의 값이다.

| 경로 | 역할 | 비고 |
|---|---|---|
| `vn.py` (433줄) | CLI 진입점. `prompt`, `concept`, `sprite`, `cg`, `bg`, `sheet`, `pixel`, `icon`, `export`, `tag`, `pose` 모드 | ComfyUI에 직접 제출 |
| `vnlib/` | CLI와 GUI가 함께 쓰는 생성 로직 | `graphs.py` 872줄, `pose.py` 1,027줄, `tagger.py` 850줄 |
| `studio/` | 웹 GUI 서버(`*.py`)와 화면(`web/`) | 서버는 `aiohttp` |
| `studio/web/` | 순수 HTML·CSS·JS. `index.html`, `js/`, `js/views/`, `css/`, `help/` | `vendor/`는 3D 뷰어·QR 라이브러리 번들(수정 금지) |
| `studio.sh` (277줄) | Studio 서버 실행기(zsh) | 중복 실행 방지, 로그 회전, 앱 창 열기 |
| `start.sh` (13줄) | ComfyUI 엔진 단독 실행(zsh) | Studio가 자식 프로세스로 부른다 |
| `config/` | `presets.json`, `loras.json`, `motion_licenses.json`(추적), `settings.json`(기기별, 추적 안 함) | GUI에서 편집 |
| `characters/` | 캐릭터 JSON (`haru.json`, `lena.json`) | 캐릭터 탭에서 편집 |
| `workflows/` | `vn.py export`가 쓰는 ComfyUI API 포맷 JSON(`haru_concept_api.json` 등 3개) | ComfyUI 화면에서 열어 볼 수 있는 내보내기 결과 |
| `motion/` | 영상 → 3D 동작 하위 프로세스(`cli.py`, `estimate.py`, `bvh.py`, `provenance.py`) | [모션 파이프라인](motion.md) |
| `scripts/` | `stop_studio.sh`, `autostart.sh`, `make_app.sh`, `motion.sh`, `env.sh`, `blender.sh`, `download_models.sh` | 운영 보조 |
| `docs/` | `STUDIO_SPEC.md`(670줄, 구현 계약서), `MOTION_CAPTURE_PLAN.md`(341줄) | 설계 문서 |
| `tests/motion/` | `test_motion.py` 한 파일 | 모션 보정·등급 단위 테스트 |
| `extra_model_paths.yaml` | ComfyUI가 모델을 찾을 폴더 목록 | `start.sh`가 넘긴다 |

레포에 없고 실행 중에 생기는 폴더는 `.gitignore`로 제외한다.

| 경로 | 내용 |
|---|---|
| `models/` | 체크포인트, LoRA, 업스케일러, ControlNet, 태거 모델 |
| `output/` | 결과 이미지. `prompt/`, `<캐릭터ID>/concept|sprite|cg/`, `backgrounds/`, `sheets/`, `pixel/`, `icons/`, `_secret/`, `.trash/` |
| `input/` | 엔진 입력 폴더. 포즈 라이브러리(`poses/`), 스프라이트 시트용 포즈 맵 |
| `user/` | 엔진 로그(`server.log`), Studio 로그(`studio.log`), `studio/jobs.sqlite3`, `studio/thumbs/` |
| `ComfyUI/` | 엔진 설치본(약 25GB, 공유 모델 포함) |
| `envs/` | 모션 추정용 별도 Python 환경 |

## 진입점 세 개

| 진입점 | 누가 부르나 | 하는 일 | 엔진 필요 |
|---|---|---|---|
| `vn.py` | 사람(터미널) | 모드별 JobSpec을 만들어 `vnlib.graphs.build()`로 그래프를 얻고 ComfyUI에 제출·대기 | `tag`, `pose detect`, `pose list`를 빼고 필요 |
| `studio.sh` | 사람 또는 앱 래퍼 | 엔진 Python으로 `studio/server.py`를 백그라운드 실행 | 필요 없음(서버가 켠다) |
| `start.sh` | `studio/comfy_link.py` | ComfyUI를 `127.0.0.1:8188`에 바인드해 실행 | 엔진 자체 |

## 데이터 흐름

```
 사람 --> studio.sh --> studio/server.py --(자동 시작)--> start.sh --> ComfyUI 8188
                              |                                        ^
                              +-- /prompt, /queue, WebSocket ----------+
 사람 --> vn.py --- vnlib.graphs.build() ---- /prompt 직접 제출 --------+
```

## 핵심 코드 해설

### `studio.sh`: 실행 조건과 순서

`studio.sh`는 서버를 띄우기 전에 다음을 순서대로 확인한다.

1. 이미 실행 중인지 `GET /api/ping`(2초), 없으면 `GET /api/status`(6초)로 확인한다. 응답에 `"studio"`가 들어 있어야 우리 서버로 본다.
2. 잠금 디렉터리를 만들어 동시 실행을 막는다. 60초가 넘은 잠금은 비정상 종료의 흔적으로 보고 지운다.
3. 엔진 Python 실행 파일과 `studio/server.py`가 있는지, 포트를 다른 프로그램이 쓰는지 점검한다.
4. 사용자 환경의 Python 변수(`PYTHONPATH` 등)를 지우고 `nohup`으로 서버를 실행한다. `--open`으로 부르면 서버에 `--app`을 붙인다.
5. 최대 20초 동안 `/api/ping` 응답을 기다린다. 성공하면 `--open`일 때 Chrome 앱 창(없으면 기본 브라우저)을 연다.

포트는 환경 변수 `VN_STUDIO_PORT` → `config/settings.json`의 `studio_port` → 8190 순으로 정한다.

{% hint style="info" %}
NOTE: `--app` 플래그는 원격 접속과 연결된다. 앱 창으로 연 서버만 원격 요청을 받는다. 자세한 구조는 [시크릿 모드와 원격 접속](secret-remote.md)에 있다.
{% endhint %}

### `start.sh`: 엔진 실행 인자

{% code title="start.sh (발췌)" %}
```sh
exec "$ENGINE/standalone-env/bin/python" main.py \
  --listen 127.0.0.1 --port 8188 \
  --extra-model-paths-config "$P/extra_model_paths.yaml" \
  --output-directory "$P/output" \
  --input-directory "$P/input" \
  --user-directory "$P/user" \
  --preview-method auto \
  --disable-auto-launch "$@"
```
{% endcode %}

* 입출력·사용자 폴더를 모두 레포 폴더 안으로 돌린다. 엔진 설치본은 읽기 전용으로 두고 결과와 설정이 레포 쪽에 모인다.
* `--preview-method auto`는 생성 중 실시간 미리보기를 켠다. Studio가 이를 WebSocket 바이너리 메시지로 받는다.

### `vn.py`: 모드에서 제출까지

`vn.py`의 `run(job)`은 네 줄로 요약된다.

1. `build(job)`으로 그래프와 시드를 얻는다.
2. 저장 노드(`SaveImage`)마다 `cli_run` 입력에 임의 값을 넣어 ComfyUI의 실행 캐시를 우회한다. 같은 설정을 다시 돌려도 저장 노드가 새로 실행된다.
3. `comfy.submit`으로 제출한다.
4. `comfy.wait`로 끝날 때까지 기다리며 출력 파일 이름을 찍는다.

`tag`, `pose` 하위 명령은 엔진 없이 동작한다. `onnxruntime`이 엔진 Python에만 있으므로, 모듈이 없다는 오류가 나면 `vn.py`가 엔진 Python으로 다시 실행하는 경로(`_reexec_with_engine`)가 있다.

## 따라 만들기

이 페이지는 구조 목록이라 구현 단계는 [서버](server.md)와 [작업 큐](jobs-library.md)에 둔다. 뼈대를 같게 시작하려면 다음 순서로 폴더를 만든다.

1. 라이브러리 폴더(`vnlib/`)를 만들고 "작업 설정 dict → 그래프 dict" 함수 하나를 정한다. → 결과: CLI와 서버가 같은 함수를 부를 자리가 생긴다.
2. 설정·캐릭터 JSON 읽기·쓰기를 `vnlib/config.py` 한 곳에 모은다. 저장은 임시 파일 + `os.replace`로 한다. → 결과: 저장 중 전원이 꺼져도 파일이 깨지지 않는다.
3. CLI(`vn.py`)가 그래프를 만들어 엔진에 제출하게 한다. → 결과: 서버 없이도 한 장이 나온다.
4. 엔진 실행 스크립트(`start.sh`)를 만들어 입출력 폴더를 레포 안으로 돌린다. → 결과: 결과물이 레포 폴더 한 곳에 모인다.
5. 서버(`studio/server.py`)를 추가하고, 서버가 같은 `build()`를 부르게 한다. → 결과: GUI와 CLI의 결과가 같다.
6. 실행기(`studio.sh`)에 "이미 실행 중이면 재사용"과 "동시 실행 잠금"을 넣는다. → 결과: 앱을 연달아 눌러도 서버가 하나만 뜬다.

## 알려진 한계·주의

* 경로와 설치 위치(외장 SSD, 엔진 Python)가 설계 문서와 스크립트에 고정돼 있다. 다른 PC에 옮기려면 `studio.sh`, `start.sh`, 설계 문서의 경로를 함께 바꿔야 한다.
* `studio.sh`, `start.sh`는 zsh 전용이고 `lsof`, `osascript`, `open` 같은 macOS 명령을 쓴다.
* `docs/STUDIO_SPEC.md` 0절은 "엔진 Python에는 그 밖의 pip 설치 금지"라고 적는다. 엔진 환경 오염을 피하려는 규칙이다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성 |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 생성 로직을 라이브러리로 떼어 CLI와 서버가 함께 쓰게 한 이유를 내 말로 적어 보자.
- [ ] 실행기가 "이미 실행 중이면 재사용"하게 만들면서 어떤 경우를 걱정했는지 적어 보자.
