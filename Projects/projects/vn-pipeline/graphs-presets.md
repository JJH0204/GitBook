# VN-Pipeline 생성 그래프와 프리셋

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-VNP-101-D&O |
| 대상 레포 | [JJH0204/VN-Pipeline](https://github.com/JJH0204/VN-Pipeline) (공개 레포) |
| 읽은 파일 | `vnlib/config.py`, `vnlib/graphs.py`, `vnlib/comfy.py`, `vnlib/characters.py`, `vnlib/modelinfo.py`, `workflows/*.json` |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서의 동작 설명은 소스 코드를 읽고 판단한 것이다. ComfyUI와 모델 파일이 필요해 이 환경에서는 실행하지 않았다.
{% endhint %}

## 이 영역이 하는 일

VN-Pipeline은 "작업 명세(JobSpec) 한 덩어리"를 ComfyUI가 실행할 수 있는 API 그래프(JSON)로 바꾸고, 그 그래프를 ComfyUI에 보내 결과 파일을 받는다. 이 변환기가 `vnlib/graphs.py`의 `build(job)`이다. 프리셋은 "어떤 체크포인트를 어떤 샘플러·CFG·품질 태그로 돌릴지"를 이름 하나로 묶어 둔 설정이다.

전체 구조(폴더, 서버, 작업 큐)는 [프로젝트 개요](README.md)와 [소스 구조](structure.md)에, 작업 큐가 이 그래프를 받아 실행하는 쪽은 [작업 큐와 라이브러리](jobs-library.md)에 있다.

## 구성 요소

| 파일 | 역할 |
|---|---|
| `config/presets.json` | 프리셋 목록. 없으면 `vnlib/config.py`의 `DEFAULT_PRESETS`로 자동 생성한다 |
| `config/settings.json` | 전역 설정(기본 프리셋, 하이레즈 배율·스텝·강도, 업스케일러, 포즈·태거 기본값) |
| `config/loras.json` | LoRA별 메모(트리거 단어, 기본 강도, 설명) |
| `vnlib/config.py` | 위 세 파일의 읽기·쓰기, 모델 검색 경로(`MODEL_ROOTS`), 크기 이름표(`SIZES`) |
| `vnlib/characters.py` | `characters/<id>.json` 캐릭터 스펙(외형·의상·표정·시드·모델) |
| `vnlib/modelinfo.py` | safetensors 헤더만 읽어 체크포인트·LoRA의 계열(SDXL 등)과 v-prediction 여부 판별 |
| `vnlib/graphs.py` | JobSpec → ComfyUI API 그래프. `Graph`(노드 추가), `Ctx`(공통 단계), `build()`(모드별 분기) |
| `vnlib/comfy.py` | CLI용 동기 ComfyUI 클라이언트. `submit()`으로 보내고 `wait()`로 기다린다 |
| `workflows/haru_*_api.json` | `vn.py export`가 저장한 예시 그래프(prompt·concept·sprite) |

### 프리셋이 담는 값

`DEFAULT_PRESETS`의 네 항목(`wai`, `noob`, `noob-hq`, `noob-eps`)은 모두 같은 키를 갖는다.

| 키 | 뜻 | 예 (`noob`) |
|---|---|---|
| `ckpt` | 체크포인트 파일 이름 | `NoobAI-XL-Vpred-v1.0.safetensors` |
| `vpred` | v-prediction 모델 여부 | `True` |
| `sampler`, `scheduler` | KSampler 설정 | `euler`, `normal` |
| `cfg`, `steps` | CFG, 1차 생성 스텝 | `5.0`, `30` |
| `quality` | 긍정 프롬프트 끝에 붙는 품질 태그 | `masterpiece, best quality, ...` |
| `negative` | 기본 네거티브 | `nsfw, worst quality, ...` |
| `loras` | 기본 LoRA 목록 `[{name, weight}]` | `[]` |
| `label`, `note` | 화면 표시용 이름·메모 | |

## 데이터 흐름

```
JobSpec(dict)                       preset 이름 결정 순서
 mode, prompt, character,           job.preset → 캐릭터의 model → settings.default_preset
 preset, size, count, seed,
 pose, hires/face/hands ...                │
        │                                  ▼
        ▼                      config/presets.json  +  config/settings.json
  graphs.build(job) ──────────────────────┘
        │   Ctx: 체크포인트 로드 → LoRA 체인 → (v-pred 설정) → 프롬프트 인코딩
        │   모드별 분기(prompt / concept / sprite / cg / bg / pixel / icon / sheet)
        ▼
 {"graph", "titles", "seeds", "preset", "summary", "prefixes", "pose"}
        │
        ▼
 comfy.submit(server, graph)  →  POST <ComfyUI>/prompt  → prompt_id
 comfy.wait(server, prompt_id) →  GET  /history/<id> 를 2초마다 확인
        │
        ▼
 output/ 기준 상대 경로 목록 (SaveImage 결과)
```

Studio(GUI)는 `comfy.py` 대신 비동기 클라이언트(`studio/comfy_link.py`, `studio/jobs.py`)로 같은 그래프를 보낸다. 변환 코드(`build`)는 CLI와 Studio가 공유한다.

## 핵심 코드 해설

### 1. 그래프는 "노드 번호 → 노드" 딕셔너리다

`Graph.add()`는 번호를 1씩 늘리며 노드를 쌓고, 연결은 `[노드번호, 출력 인덱스]` 형태 값으로 표현한다.

{% code title="vnlib/graphs.py (Graph)" %}
```python
class Graph:
    def __init__(self):
        self.nodes, self.n = {}, 0

    def add(self, cls, _title=None, **inputs):
        self.n += 1
        nid = str(self.n)
        node = {"class_type": cls, "inputs": inputs}
        if _title:
            node["_meta"] = {"title": _title}
        self.nodes[nid] = node
        return nid

    @staticmethod
    def out(nid, idx=0):
        return [nid, idx]
```
{% endcode %}

`workflows/haru_prompt_api.json`이 이 구조 그대로다. `"model": ["1", 0]`은 "1번 노드의 0번 출력"이라는 뜻이다.

### 2. 프리셋이 그래프의 앞부분을 정한다

`Ctx.__init__`은 프리셋의 `ckpt`로 `CheckpointLoaderSimple`을 만들고, LoRA를 한 줄로 이어 붙이고, `vpred`면 두 노드를 더 단다.

{% code title="vnlib/graphs.py (Ctx.__init__ 발췌)" %}
```python
ck = g.add("CheckpointLoaderSimple", "모델 로드", ckpt_name=preset["ckpt"])
m, clip = g.out(ck, 0), g.out(ck, 1)
merged = {}  # 같은 LoRA가 중복되면 한 번만 (나중 것의 강도 우선)
for lo in normalize_loras(preset.get("loras")) + normalize_loras(extra_loras):
    merged[lo["name"]] = lo
for lo in merged.values():
    n = g.add("LoraLoader", f"LoRA {lo['name']}", model=m, clip=clip, lora_name=lo["name"],
              strength_model=lo["weight"], strength_clip=lo["weight"])
    m, clip = g.out(n, 0), g.out(n, 1)
if preset.get("vpred"):  # v-prediction 모델 필수 설정
    m = g.out(g.add("ModelSamplingDiscrete", "v-pred 설정", model=m, sampling="v_prediction", zsnr=True))
    m = g.out(g.add("RescaleCFG", "RescaleCFG", model=m, multiplier=0.7))
```
{% endcode %}

LoRA는 프리셋 → 캐릭터 → 작업 순서로 모이고, 같은 이름이면 나중 값이 이긴다.

### 3. 1차 생성 → 하이레즈 → 얼굴·손 보정

`Ctx.render()`가 모든 그림 모드의 공통 파이프라인이다.

| 단계 | 노드 | 켜고 끄는 값 |
|---|---|---|
| 1차 생성 | `EmptyLatentImage` → `KSampler`(denoise 1.0) → `VAEDecode` | 항상 |
| 하이레즈 | `ImageUpscaleWithModel` → `ImageScale`(배율 `hires_scale`, 8의 배수) → `VAEEncode` → `KSampler`(denoise `hires_denoise`) | `hires` (기본 켬) |
| 얼굴 보정 | `UltralyticsDetectorProvider`(`face_yolov8m.pt`) → `FaceDetailer` | `face` (기본 켬) |
| 손 보정 | 같은 방식, `hand_yolov8s.pt` | `hands` (기본 켬) |

포즈(ControlNet)가 있으면 1차 생성의 positive·negative에만 `ControlNetApplyAdvanced`를 거친다. 하이레즈·보정은 원래 conditioning을 쓴다(자세한 내용은 [포즈 ControlNet](pose-controlnet.md)).

### 4. 모드는 같은 부품의 다른 조합이다

| 모드 | 기본 크기 | 결과 위치(`output/` 기준) | 특징 |
|---|---|---|---|
| `prompt` | portrait 832×1216 | `prompt/` | 자유 프롬프트. 캐릭터는 선택 |
| `concept` | portrait | `<id>/concept/` | 캐릭터 시안 |
| `sprite` | portrait | `<id>/sprite/` | 기본 포즈 1장 + 표정별 `FaceDetailer`(`force_inpaint`) + 배경 제거 |
| `cg` | wide 1344×768 | `<id>/cg/` | 장면 프롬프트 필수 |
| `bg` | wide | `backgrounds/` | `no humans, scenery`, 얼굴·손 보정 없음 |
| `pixel`, `icon`, `sheet` | | `pixel/`, `icons/`, `sheets/` | [태깅·도트·아이콘](tagging-icons-dots.md), [스프라이트 시트](spritesheet.md) 참조 |

크기 이름표는 `SIZES`에 있다: `portrait` 832×1216, `landscape` 1216×832, `wide` 1344×768, `tall` 768×1344, `square` 1024×1024. 직접 지정하면 8의 배수로 내리고 512~2048 범위만 허용한다(`resolve_size`).

### 5. 시드와 장수

`seeds_for()`는 시드가 있으면 `seed, seed+1, ...`(32비트로 순환), 없으면 장수만큼 무작위 값을 만든다. 장수는 1~32로 제한한다(`build`의 `count`). 파일 이름에 시드가 들어가므로(`..._seed<번호>`) 결과에서 시드를 되짚을 수 있다.

### 6. ComfyUI 호출과 결과 대기

{% code title="vnlib/comfy.py (submit 발췌)" %}
```python
def submit(server, graph, client_id=None):
    body = json.dumps({"prompt": graph, "client_id": client_id or str(uuid.uuid4())}).encode()
    req = urllib.request.Request(f"{server}/prompt", body, {"Content-Type": "application/json"})
    try:
        return json.load(urllib.request.urlopen(req))["prompt_id"]
```
{% endcode %}

`wait()`는 2초마다 `/history/<id>`를 읽는다. 다음 경우를 오류로 끝낸다.

| 상황 | 판정 |
|---|---|
| history 요청이 연달아 3번 실패 | 연결 끊김(엔진 종료·재시작) |
| history에 `status_str == "error"` | 실행 실패(중단·취소는 별도 메시지) |
| 약 6초마다 `/queue`를 확인해 두 번 연속 큐에 없음 | 작업 사라짐(재시작·큐 비우기) |

완료되면 `outputs`의 `type == "output"` 이미지를 `subfolder/filename` 경로 목록으로 돌려준다.

### 7. 설정 파일은 깨져도 복구한다

`config._read()`는 JSON 문법 오류·빈 파일·객체가 아닌 파일을 `<이름>.broken-<날짜시간>`으로 옮기고 기본값으로 다시 만든다(`RECOVERED`에 기록). 저장은 임시 파일에 쓴 뒤 `os.replace`하는 원자적 방식이다(`write_json`).

## 따라 만들기

확인 상태: 미검증. 아래 5단계는 이 변환기의 최소 구조를 같은 순서로 다시 만드는 순서다.

1. `Graph` 클래스를 만든다. → 결과: `add()`로 노드를 쌓고 `[노드번호, 출력 인덱스]`로 연결하는 딕셔너리가 생긴다.
2. 프리셋 JSON(`ckpt`, `sampler`, `cfg`, `steps`, `quality`, `negative`, `loras`, `vpred`)과 불러오기 함수를 만든다. → 결과: 파일이 없으면 기본값으로 자동 생성된다.
3. 체크포인트 → LoRA 체인 → (v-pred 설정) → `CLIPTextEncode` 2개 → `EmptyLatentImage` → `KSampler` → `VAEDecode` → `SaveImage`를 `Graph`로 조립한다. → 결과: `workflows/haru_prompt_api.json`과 같은 모양의 딕셔너리가 나온다.
4. 하이레즈(업스케일 → 리사이즈 → 인코드 → denoise 0.4 `KSampler`)와 `FaceDetailer` 단계를 옵션으로 덧붙인다. → 결과: `hires`·`face`·`hands` 값에 따라 노드 수가 늘고 준다.
5. `submit()`으로 `/prompt`에 보내고 `wait()`로 `/history/<id>`를 확인한다. → 결과: `output/` 아래 이미지 경로 목록을 받는다.

## 알려진 한계·주의

{% hint style="warning" %}
CAUTION: `vnlib/graphs.py`의 `NO_PEOPLE_MODES` 줄에 같은 뜻의 주석이 두 번 붙어 있다. 동작에는 영향이 없다.
{% endhint %}

- `UltralyticsDetectorProvider`, `FaceDetailer`, `RemoveBackground`, `ImageQuantize` 등은 ComfyUI 기본 노드가 아니라 커스텀 노드나 최근 코어 노드다. 이 노드들이 설치된 엔진이 없으면 서버가 `/prompt`를 거절한다. 필요한 정확한 노드 패키지 목록은 원본에 정리되어 있지 않다(확인 필요).
- 모델 파일(체크포인트, LoRA, ControlNet, 업스케일러)은 레포에 없다. 검색 경로는 `config.MODEL_ROOTS` 순서(레포 `models/` → 엔진 기본 `models` → 공유 폴더)다.
- 일부 프리셋의 모델은 비상업 라이선스다(`noob*` 프리셋의 `note`에 적혀 있다). 산출물을 상업적으로 쓰기 전에 모델 라이선스를 확인한다.
- 모델 내려받기용 토큰 설정 키가 `settings.json`에 있다. 값은 이 문서에 쓰지 않는다. 레포에 커밋하지 않는다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성(소스 해체) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 프리셋을 코드가 아니라 JSON으로 둔 이유는 무엇이라고 생각하는가?
- [ ] 같은 프롬프트를 `wai`와 `noob`로 돌렸을 때 그림이 어떻게 달랐는가?
- [ ] 하이레즈와 얼굴·손 보정 중 하나만 켠다면 무엇을 고르겠는가? 이유는?
