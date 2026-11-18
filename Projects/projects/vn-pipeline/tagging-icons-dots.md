# VN-Pipeline 태깅·도트·아이콘

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-VNP-104-D&O |
| 대상 레포 | [JJH0204/VN-Pipeline](https://github.com/JJH0204/VN-Pipeline) (공개 레포) |
| 읽은 파일 | `vnlib/tagger.py`, `studio/tagging.py`, `vnlib/graphs.py`(`pixel`, `icon` 모드와 `pixelize`, `icon_on_tile`), `vnlib/config.py`(태거 설정) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 코드를 읽고 쓴 해설이다. 태거 모델과 ComfyUI가 없어 실행하지 않았다. 세 기능은 서로 독립적이며 한 문서에 묶은 이유는 모두 "그림 한 장을 다른 형태로 바꾸는 후처리"이기 때문이다.
{% endhint %}

## 이 영역이 하는 일

| 기능 | 입력 → 출력 | 실행 위치 |
|---|---|---|
| 태깅(프롬프트 추출) | 그림 → Danbooru 태그와 확률 → 프롬프트 문자열 | Studio 서버 CPU (ONNX), ComfyUI 불필요 |
| 도트(`pixel` 모드) | 프롬프트 → 그림 → 실제 픽셀 크기의 팔레트 제한 PNG | ComfyUI 그래프 |
| 아이콘(`icon` 모드) | 줄마다 하나의 설명 → 같은 스타일의 투명 PNG와 크기별 PNG | ComfyUI 그래프 |

생성 그래프의 공통 부분은 [생성 그래프와 프리셋](graphs-presets.md)에 있다.

## 구성 요소

| 파일 | 역할 |
|---|---|
| `vnlib/tagger.py` | WD 태거 v3 ONNX 추론(`Tagger`), 태그 그룹 분류(`classify`), 프롬프트 조립(`to_prompt`), 모델 목록 |
| `studio/tagging.py` | 비동기 래퍼: 업로드 검사(20MB), 전역 락(한 번에 하나), 15분 유휴 시 모델 해제 |
| `vnlib/graphs.py` `Ctx.pixelize` | 면적 평균 축소 → 팔레트 양자화 → 1비트 알파 |
| `vnlib/graphs.py` `icon_on_tile` | 심볼을 둥근 사각 타일 가운데에 합성 |
| `PIXEL_SUBJECTS`, `ICON_STYLES` | 모드별 추가 태그·네거티브·크기 기본값 |
| `config/settings.json` | `tagger_model`, `tagger_threshold`, `tagger_char_threshold` |

## 1. 태깅

### 데이터 흐름

```
이미지(파일·붙여넣기·갤러리) 또는 3D 렌더 캡처
  │  open_image: 크기·화소 검사(5천만 화소 초과 거부)
  ▼
Tagger.prepare: EXIF 회전 보정 → 투명은 흰 배경에 합성 → RGB
                → 긴 변 기준 흰색 정사각 패딩(가운데) → 모델 입력 크기로 BICUBIC → BGR, float32 [1,S,S,3]
  ▼
onnxruntime(CPUExecutionProvider) → 시그모이드 확률
  ▼
selected_tags.csv 의 category: 0 일반 · 4 캐릭터 · 9 등급(rating)
  ├ 일반 태그: 점수 ≥ 0.15(FLOOR)만 반환
  └ 캐릭터 태그: 점수 ≥ 0.5(CHAR_FLOOR)만 반환
  ▼
classify(tag) → 그룹 id → UI가 기준값 슬라이더(일반 0.35 / 캐릭터 0.85 기본)로 다시 거름
  ▼
to_prompt(tags): 그룹 순서로 정렬, 괄호 escape, ', '로 결합
```

### 핵심 코드 해설

모델 폴더는 `models/tagger/<이름>/`이고 안에 `model.onnx`와 `selected_tags.csv` 두 파일이 있어야 한다(`list_models`). 기본 모델 이름은 `wd-eva02-large-tagger-v3`이다. 원본 README는 이 모델이 SmilingWolf 제작, Apache-2.0이라고 적는다(직접 확인하지 않았다). 모델 파일은 레포에 없다.

{% code title="vnlib/tagger.py (그룹 순서와 이름)" %}
```python
GROUPS = ("count", "character", "appearance", "outfit", "expression", "pose",
          "composition", "background", "other", "meta")
GROUP_LABELS = {"count": "인원", "character": "캐릭터", "appearance": "외형", "outfit": "의상",
                "expression": "표정", "pose": "포즈", "composition": "구도", "background": "배경",
                "other": "기타", "meta": "제외 권장"}
```
{% endcode %}

- **분류 규칙**: `classify()`는 정확 일치 표(`EXACT`) → 정규식 목록(`RULES`) 순으로 처음 맞는 그룹을 고르고, 없으면 `other`다. 캐릭터 종류는 항상 `character`다. 결과는 `lru_cache`로 저장한다.
- **제외 권장(`meta`)**: `3d`, `signature`, `watermark`, `tachi-e`, `jpeg artifacts` 같은 "원본 특성" 태그는 생성 프롬프트에 넣지 않는 편이 좋아 별도 그룹이다(`META_EXACT`).
- **밑줄 처리**: 태그의 `_`를 공백으로 바꾸되, `^_^`, `>_<` 같은 이모티콘 태그는 그대로 둔다(`EMOTICONS`).
- **프롬프트 조립**: `to_prompt()`는 같은 그룹 안에서는 받은 순서를 유지하고, 중복을 빼고, `(`와 `)`를 `\(`, `\)`로 바꾼다(ComfyUI 가중치 문법 `(tag:1.2)`과 충돌을 막는다).
- **안전장치**: 긴 변이 4096을 넘는 직사각형은 패딩 전에 줄인다(`PAD_MAX`). 16비트·부동소수 흑백 이미지는 8비트로 바꾼다. 입력 모양이 NHWC 3채널이 아니거나 출력 개수가 태그 수와 다르면 모델을 거부한다.
- **서버 쪽**: 업로드는 디스크에 저장하지 않고 메모리에서 처리한다. 마지막 사용 후 15분이 지나면 모델(약 1.5GB로 문서화됨)을 내린다(`IDLE_UNLOAD`).

### 따라 만들기

확인 상태: 미검증.

1. 태그 CSV(`name`, `category` 열)와 ONNX 모델을 읽어 입력 모양(NHWC)과 출력 개수를 검사한다. → 결과: 모델이 로드되고 입력 크기 S를 안다.
2. 이미지를 흰 배경 정사각 패딩 → S×S → BGR float32로 바꾼다. → 결과: `[1, S, S, 3]` 배열이 나온다.
3. 추론 후 카테고리별로 임계값을 적용한다(일반 0.35, 캐릭터 0.85가 설정 기본값). → 결과: `{tag, score, kind, group}` 목록이 점수순으로 나온다.
4. 태그 → 그룹 분류표를 만든다. 정확 일치와 정규식 순서가 곧 우선순위다. → 결과: 외형·의상·표정 등으로 묶인 칩 목록이 나온다.
5. 선택한 태그를 그룹 순서로 이어 붙여 프롬프트 문자열을 만든다. → 결과: 생성 탭에 넣을 수 있는 한 줄이 나온다.

## 2. 도트(`pixel` 모드)

### 규칙

`resolve_pixel()`이 검증하는 값과 기본값(`PIXEL_DEFAULTS`)은 다음과 같다.

| 옵션 | 범위·선택지 | 기본값 |
|---|---|---|
| `subject` | `character`, `object`, `scene` | `object` |
| `width` | 16~512 (투명이면 대상에 맞춰 자른 뒤 긴 변, 불투명이면 가로) | 128 |
| `colors` | 2~256 (팔레트 색 수) | 32 |
| `dither` | `none`, `bayer-2`, `bayer-4`, `floyd-steinberg` | `none` |
| `transparent` | `scene`은 항상 불투명 | 대상별 기본값 |

`pixel` 모드는 도트로 줄이면 디테일이 사라지므로 1차 생성만 한다(`hires=False, face=False, hands=False`). 프롬프트에는 `PIXEL_POS`(`pixel art, retro game, sprite, limited palette ...`)와 대상별 태그가 붙는다.

### 핵심 코드 해설: 불투명 도트화

{% code title="vnlib/graphs.py (Ctx.pixelize, 불투명 경로)" %}
```python
small = g.out(g.add("ImageScale", "도트 크기로 축소", image=image, upscale_method="area",
                    width=tw, height=th, crop="disabled"))
img = g.out(g.add("ImageQuantize", f"팔레트 {colors}색", image=small, colors=int(colors), dither=dither))
if not transparent:
    return img
```
{% endcode %}

- 축소는 `area`(면적 평균) 방식이다. 코드 주석은 "면적 평균으로 실제 픽셀 크기까지 줄인다"고만 적고 다른 방식과 비교한 기록은 없다.
- 도트 크기는 `pixel_size(w, h, px_w)`가 생성 크기의 비율을 유지해 계산한다(예: 와이드 1344×768을 가로 128로 줄이면 128×73).

### 투명 도트: 알파를 따로 줄여 1비트로 자른다

`ImageQuantize`는 RGB만 받기 때문에 알파는 마스크로 따로 처리한다.

| 단계 | 노드 | 하는 일 |
|---|---|---|
| 1 | `RemoveBackground`(`birefnet.safetensors`) | 전경 마스크를 얻는다 |
| 2 | `ThresholdMask`(0.5) → `MaskToSEGS` → `SEGSToImageList` | 대상의 테두리에 맞춰 자른다(`fit`) |
| 3 | `ImageScaleToMaxDimension`(`area`) | 긴 변을 `width` 픽셀로 줄인다 |
| 4 | `SplitImageWithAlpha` → `ImageQuantize` | RGB만 팔레트 양자화한다 |
| 5 | `ThresholdMask`(0.5) → `JoinImageWithAlpha` | 알파를 0 또는 1로 자르고 다시 합친다 |

대상에 맞춰 먼저 자르는 이유는 코드 주석이 밝힌다: 빈 여백에 픽셀을 쓰지 않고, 그림 속 대상이 작게 그려져도 결과 도트 크기를 일정하게 하기 위해서다.

### 따라 만들기

확인 상태: 미검증.

1. 대상(`character`, `object`, `scene`)마다 생성 크기, 추가 태그, 추가 네거티브, 투명 기본값 표를 만든다. → 결과: 입력 한 줄로 프롬프트가 완성된다.
2. 하이레즈·얼굴·손 보정을 끄고 1차 생성만 한다. → 결과: 큰 그림 한 장이 나온다.
3. `area` 축소 후 `ImageQuantize`로 색 수를 제한한다. → 결과: 불투명 도트 PNG가 나온다.
4. 투명이 필요하면 전경 마스크를 대상 테두리로 자르고, 알파를 임계값 0.5로 1비트화해 다시 합친다. → 결과: 가장자리가 번지지 않는 투명 도트가 나온다.
5. 파일 이름에 도트 크기와 시드를 넣어 저장한다(`pixel/<이름>_<긴 변>px_seed<시드>`). → 결과: 같은 설정의 결과를 파일 이름으로 구분한다.

## 3. 아이콘(`icon` 모드)

### 규칙

- 입력은 줄마다 하나다. `이름: 설명` 형식이면 앞부분이 파일 이름, 아니면 설명에서 이름을 만든다. `#`로 시작하는 줄은 무시하고 같은 이름은 `_2`, `_3`을 붙인다(`icon_lines`). 한 번에 최대 32개(`ICON_MAX`).
- 한 세트는 같은 시드 목록을 써서 구도·그림체를 맞춘다. 아이콘마다 변형은 최대 8장(`per`).
- 원본은 1024×1024로 생성하고, 추가 크기(기본 256, 128, 64; 16~512 범위)는 원본보다 작을 때만 저장한다.

| 스타일 | 후처리 | 비고 |
|---|---|---|
| `game` | 배경 제거(BiRefNet) | 투명 기본 켬 |
| `flat` | 배경 제거 | 벡터풍 태그 |
| `glossy` | 심볼을 둥근 사각 타일에 합성(`icon_on_tile`) | 하이레즈 끔. 타일 색 8종 또는 `auto`(아이콘마다 순환) |
| `pixel` | 64픽셀·24색 도트화 | 크기별 저장 안 함(줄이면 픽셀이 뭉개짐) |

### 핵심 코드 해설: glossy는 모델이 아니라 코드가 타일을 그린다

코드 주석이 밝히는 이유: 애니 모델은 "둥근 사각 앱 아이콘"을 안정적으로 그리지 못한다(사진 같은 봉투, 모서리 잡음 등 실측). 그래서 모델은 가운데 심볼만 그리고 타일은 Pillow로 그려 합성한다.

{% code title="vnlib/graphs.py (icon_tile 발췌)" %}
```python
S = size * 4
grad = Image.linear_gradient("L").resize((S, S))  # 위 0 → 아래 255
tile = Image.composite(Image.new("RGB", (S, S), bottom), Image.new("RGB", (S, S), top), grad)
gloss = Image.new("L", (S, S), 0)
ImageDraw.Draw(gloss).ellipse((-S * 0.25, -S * 0.62, S * 1.25, S * 0.42), fill=56)
tile = Image.composite(Image.new("RGB", (S, S), "white"), tile, gloss)
alpha = Image.new("L", (S, S), 0)
ImageDraw.Draw(alpha).rounded_rectangle((0, 0, S - 1, S - 1), radius=int(S * TILE_RADIUS), fill=255)
```
{% endcode %}

- 4배 크기로 그린 뒤 LANCZOS로 줄여 모서리를 매끈하게 한다. 완성 타일은 `input/icon_tiles/<색>_<크기>_v1.png`에 한 번만 만든다.
- `icon_on_tile()`은 전경 마스크로 심볼 테두리에 맞춰 자르고 긴 변을 타일의 64%(`TILE_SYMBOL`)로 맞춘 뒤 타일 가운데에 합성한다. 모델이 크게·작게 그려도 세트가 고르게 보이게 하는 장치다.
- 프롬프트에서 `3d icon`, `emoji` 같은 단어를 피한 이유도 주석에 있다(받침을 또 그리거나 모든 심볼에 웃는 얼굴을 그림).

### 따라 만들기

확인 상태: 미검증.

1. 입력 줄을 `이름: 설명`으로 나누는 파서를 만든다. → 결과: `(파일 이름, 설명)` 목록이 나온다.
2. 스타일별 추가 태그·네거티브 표를 만들고 세트 전체에 같은 시드 목록을 쓴다. → 결과: 구도와 그림체가 비슷한 아이콘 세트가 나온다.
3. `game`·`flat`은 배경을 제거해 투명 PNG로 저장한다. → 결과: 1024 원본이 나온다.
4. `glossy`는 Pillow로 그라데이션 타일을 그리고 심볼을 64% 크기로 가운데에 합성한다. → 결과: 앱 아이콘 모양 PNG가 나온다.
5. 지정한 작은 크기들을 `<폴더>/<크기>px/`에 추가로 저장한다. → 결과: 256, 128, 64 크기 PNG가 같은 이름으로 쌓인다.

## 알려진 한계·주의

- 태거의 머리색·눈 색은 조명에 따라 틀리기 쉽다(원본 README의 주의 문구). 결과를 사람이 확인한다.
- 남의 그림·3D 모델을 입력으로 쓸 때는 저작권과 이용 약관을 확인한다. 이 레포는 업로드를 저장하지 않지만 판단은 사용자 몫이다.
- 투명 도트와 아이콘 배경 제거는 BiRefNet 모델(`birefnet.safetensors`)과 해당 ComfyUI 노드가 있어야 한다. 모델 파일은 레포에 없다.
- `ImageQuantize`의 디더링 옵션 이름은 ComfyUI 쪽 정의에 의존한다. 엔진 버전에 따라 다를 수 있다(확인 필요).

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성(소스 해체) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 태그 기준값을 낮추거나 높이면 프롬프트가 어떻게 달라진다고 생각하는가? 직접 해 본 결과가 있다면 적는다.
- [ ] 도트 그림에서 팔레트 색 수와 디더링 중 무엇이 결과 인상을 더 크게 바꿨는가?
- [ ] 앱 아이콘 타일을 모델이 아니라 코드로 그린 선택에 동의하는가? 이유는?
