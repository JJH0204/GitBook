# VN-Pipeline 스프라이트 시트

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-VNP-103-MP |
| 대상 레포 | [JJH0204/VN-Pipeline](https://github.com/JJH0204/VN-Pipeline) (공개 레포) |
| 읽은 파일 | `vnlib/spritesheet.py`, `vnlib/graphs.py`(`resolve_sheet`, `sheet` 모드), `vn.py`(`sheet` 옵션) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 코드를 읽고 쓴 해설이다. 포즈 맵을 직접 그려 보지도, 시트를 생성해 보지도 않았다.
{% endhint %}

## 이 영역이 하는 일

게임용 캐릭터 애니메이션 시트를 만든다. 줄 = 동작 × 방향, 칸 = 프레임이다. 사람이 그린 그림 대신 **코드로 계산한 뼈대(포즈 맵)를 ControlNet에 넣어** 프레임마다 자세를 지정하고, 같은 줄의 프레임은 한 장에 나란히 그려 얼굴·옷이 맞게 한다. 포즈 맵을 그리고 적용하는 원리는 [포즈 ControlNet](pose-controlnet.md)에 있다.

| 항목 | 값 |
|---|---|
| 동작 7개(줄 순서) | `idle` 대기, `walk` 걷기, `run` 달리기, `attack` 공격, `pickup` 줍기, `down` 쓰러짐, `rest` 휴식 |
| 방향 4개(줄 순서) | `down`(정면), `left`, `right`, `up`(뒷모습) |
| 프레임 수 | 4 또는 6 |
| 최대 줄 수 | 28 (동작 수 × 방향 수) |
| 출력 | `output/sheets/<이름>_<칸W>x<칸H>_<프레임>x<줄>_seed<시드>_*.png` (투명 PNG 격자) |

## 구성 요소

| 파일·함수 | 역할 |
|---|---|
| `vnlib/spritesheet.py` `ATTACK`, `PICKUP`, `DOWN`, `REST` | 한 번 하는 동작의 키프레임 표(시간 → 관절 각도) |
| `angles(motion, t)` | 시간 t(0~1) → 관절 각도 dict. 걷기·달리기는 사인 곡선(`_cycle`), 나머지는 키프레임 보간(`_keys`, smoothstep) |
| `skeleton(a)` | 각도 → 18점 3D 좌표(lat 좌우, up 위, fwd 앞), 골반이 원점, 키 = 1.0 |
| `project(pts, direction)` | 3D → 화면 2D. 방향별 정사영과 탑다운 기울기(`TILT = 0.5`) |
| `frame_points`, `row_scale` | 바닥선 맞추기, 한 줄에 같은 배율 적용 |
| `row_keypoints` | 한 줄의 프레임들을 가로로 이어 붙인 키포인트 |
| `row_map`, `frame_map` | 포즈 맵 PNG를 `input/spritesheet/`에 해시 이름으로 저장 |
| `vnlib/graphs.py` `sheet` 모드 | 줄마다 생성 → 좌우 반전 → 줄 쌓기 → 알파 → (도트화) → 저장 |

## 데이터 흐름

```
동작 × 방향 × 프레임 수
   │  times(): 프레임 시간 (반복 동작 [0,1) 균등, 한 번 동작 [0,1] 양 끝 포함)
   ▼
angles(t) → skeleton() → project(방향) → frame_points() → row_keypoints()
   │                                                    (한 줄 = 프레임 N개를 가로로 연결)
   ▼
poselib.draw(style) → input/spritesheet/<동작>_<방향>_<N>f_<스타일>_<해시12자>.png  (같은 내용이면 재사용)
   ▼
줄마다 ControlNetApplyAdvanced → KSampler(같은 시드) → VAEDecode
   │      일반 줄: 한 줄 한 장으로 생성 (선택: 하이레즈)
   │      분리 줄: 프레임마다 768×1152로 따로 생성 → 칸 크기로 줄여 ImageStitch
   ▼
left = right 를 좌우 반전(칸 순서를 되돌려 다시 이음)
   ▼
ImageStitch(direction=down)로 줄 쌓기 → BiRefNet 마스크 → 알파 합성 → (도트화) → SaveImage
```

## 핵심 코드 해설

### 1. 걷기 = 사인 곡선 하나

{% code title="vnlib/spritesheet.py" %}
```python
def _cycle(t, amp_th, amp_kn, amp_ar, el, bob, lean):
    s = math.sin(2 * math.pi * t)
    c = math.cos(2 * math.pi * t)
    return _p(torso=lean, thR=amp_th * s, thL=-amp_th * s,
              knR=8 + amp_kn * max(0.0, c), knL=8 + amp_kn * max(0.0, -c),
              arR=-amp_ar * s, arL=amp_ar * s, elR=el, elL=el, abR=6, abL=6, bob=bob * abs(c))
```
{% endcode %}

- `thR`/`thL`(허벅지)은 서로 반대 위상, 팔(`arR`/`arL`)은 다리와 반대로 흔든다.
- 걷기는 `_cycle(t, 30, 40, 26, 15, 0.015, 3)`, 달리기는 `_cycle(t, 42, 85, 50, 85, 0.03, 12)`(함수 `angles`). 인수 순서는 허벅지·무릎·팔 진폭, 팔꿈치, 위아래 흔들림, 몸 기울기다.
- 관절 각도 이름: `torso, thR/thL(허벅지), knR/knL(무릎), arR/arL(어깨), elR/elL(팔꿈치), abR/abL(벌림), fall(쓰러짐 회전), bob(상하), head`. 기본값은 `ZERO`.

### 2. 한 번 하는 동작 = 키프레임 표

`ATTACK`(칼 휘두르기), `PICKUP`, `DOWN`, `REST`는 `(시간, 각도 dict)` 목록이다. `_keys()`가 그 사이를 smoothstep으로 이어 준다. 반복 동작은 `times()`가 `[0, 1)` 균등 분할(끝 = 처음)이고, 한 번 동작은 양 끝을 포함한다.

### 3. 3D → 화면, 방향별 처리

`project()`는 방향별로 좌표축을 바꾼다. `down`은 앞으로 나온 점을 화면 아래로(`y + TILT*fwd`), `up`은 위로, `left`/`right`는 `fwd`를 가로축으로 쓴다. 보이지 않는 얼굴 점은 `HIDDEN`이 `None`으로 만든다(뒷모습은 코·눈 없음). `쓰러짐(fall)`은 발 사이를 축으로 화면에서 회전한다.

### 4. 칸 크기와 배율

{% code title="vnlib/spritesheet.py" %}
```python
CELL_ASPECT = 2 / 3  # 칸 가로/세로

def cell_size(frames):
    w = {4: 384, 6: 336}.get(frames)
    ...
    return w, int(w / CELL_ASPECT) // 8 * 8
```
{% endcode %}

4프레임 칸은 384×576, 6프레임 칸은 336×504다. 한 줄의 넓이는 SDXL 1메가픽셀 근처다. `row_scale()`은 누운 프레임처럼 칸보다 넓어지는 자세가 있으면 **줄 전체의 모든 프레임을 같이** 줄인다(프레임마다 배율이 다르면 재생 중 캐릭터 크기가 바뀐다). 바닥선은 `GROUND = 0.95`, 서 있는 키는 칸 높이의 `FIG_H = 0.86`이다.

### 5. 한 장에 그릴 줄, 따로 그릴 줄

`separate(motion, direction)`이 참이면(`down` 동작 또는 `up` 방향) 프레임마다 768×1152로 따로 생성해 칸 크기로 줄인 뒤 `ImageStitch`로 잇는다. 코드 주석의 이유: 한 장에 나란히 그리면 쓰러짐은 누운 몸들을 한 사람으로 잇고, 뒷모습은 프레임 하나를 정면으로 그린다(실측, 칸 사이 틈이나 덧대기로도 안 고쳐짐). 대가는 생성 횟수가 프레임 수만큼 늘어나는 것이다.

### 6. 좌우 반전으로 절반 생성

`mirror`(기본 켬)이고 `left`가 요청되면 `right`를 만들어 `ImageFlip`으로 뒤집는다. 뒤집으면 프레임 순서가 거꾸로 되므로 `ImageCrop`으로 칸을 잘라 원래 순서로 다시 잇는다(`mirror_cells`).

### 7. 방향·동작별 프롬프트 보정

`DIRECTIONS`는 방향별 태그(`from front`, `from side`, `from behind` 등), `DIR_NEG`는 방향별 네거티브(뒷모습에 `looking at viewer, face, eyes ...`), `MOTION_NEG`는 `rest`에 `chair, stool, bench, furniture, box`를 막는다. 각 보정에는 "실측" 주석이 붙어 있어 시행착오의 기록이다.

## 따라 만들기

확인 상태: 미검증. 같은 구조를 다시 만드는 순서다.

1. 관절 각도 dict(`ZERO`)와 동작 함수를 만든다. 반복 동작은 사인 곡선, 한 번 동작은 키프레임 표와 smoothstep 보간. → 결과: `angles("walk", 0.25)`처럼 시간으로 각도를 얻는다.
2. 각도로 18점 3D 골격을 계산하고 방향별로 2D에 투영한다. 가장 낮은 점을 바닥선에 맞춘다. → 결과: 프레임 하나의 정규화 키포인트(0~1)가 나온다.
3. 줄 하나(프레임 N개)를 가로로 이은 키포인트를 만들고 [포즈 ControlNet](pose-controlnet.md)의 `draw()`로 맵 PNG를 저장한다. 파일 이름에 내용 해시를 넣어 같은 맵을 다시 그리지 않는다. → 결과: `input/spritesheet/`에 줄마다 맵이 생긴다.
4. 줄마다 `ControlNetApplyAdvanced` → `KSampler`(같은 시드·같은 캐릭터 프롬프트)로 생성한다. 쓰러짐·뒷모습은 프레임별로 나눈다. → 결과: 줄 이미지가 나온다.
5. 왼쪽 줄은 오른쪽을 뒤집어 만들고, 줄을 아래로 쌓은 뒤 배경 제거 마스크로 알파를 붙여 저장한다. 파일 이름에 칸 크기·열×줄·시드를 넣는다. → 결과: 게임 엔진에서 칸 크기로 바로 자를 수 있는 시트 한 장이 나온다.

## 같은 결과를 다시 얻는 절차

확인 상태: 미검증. 코드가 결정적인 부분과 아닌 부분을 나눠 적는다.

| 항목 | 결정적인가 | 근거 |
|---|---|---|
| 포즈 맵(뼈대) | 예 | 순수 계산이다. 파일 이름이 동작·방향·프레임·스타일·키포인트 해시로 정해진다 |
| 시드 | 지정하면 고정 | `seeds_for`: `--seed`가 있으면 그 값, 없으면 캐릭터의 `seed`, 없으면 무작위 |
| 그림 | 환경 의존 | 같은 시드·프리셋이라도 GPU·드라이버·ComfyUI 버전에 따라 달라질 수 있다 (원본에 없음, 확인 필요) |

1. 캐릭터 스펙(`characters/<id>.json`)의 `appearance`, `outfit`, `negative`, `model`, `seed`를 기록한다.
2. 프리셋(`config/presets.json`의 해당 항목)과 설정값(`pose_model`, `pose_strength`, `pose_end`, `hires_*`)을 기록한다.
3. 같은 명령을 시드를 지정해 실행한다. 예: `python3 vn.py sheet <캐릭터ID> --motions walk,attack --frames 4 --seed <시드>`. 도트 시트는 `--cell-px <칸 가로 픽셀>`을 더한다.
4. 결과 파일 이름의 칸 크기·열×줄·시드가 기록과 같은지 확인한다.
5. 그림이 다르면 ControlNet 파일, 체크포인트 파일, 엔진 버전부터 비교한다.

## 알려진 한계·주의

- 스프라이트 시트는 SDXL 계열 체크포인트와 포즈 ControlNet 파일이 있어야 시작한다. 없으면 `JobError`로 거절된다.
- 프레임 수 6은 칸이 336×504로 더 작다. 하이레즈를 켜면(`--hires`, 기본 끔) 줄마다 업스케일·리파인이 더 걸린다.
- 분리 줄이 있으면 생성 시간이 프레임 수만큼 늘어난다.
- `sheet` 모드의 도트화 옵션은 칸 가로 16~256픽셀, 색 2~256이다(`resolve_sheet`).
- 움직임 표(`ATTACK` 등)의 각도는 수치 실험으로 정한 값이며 모션 캡처 데이터가 아니다. 영상에서 3D 동작을 뽑는 파이프라인은 [모션 파이프라인](motion.md)에서 별도로 다룬다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성(소스 해체) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 한 줄을 한 장에 그리는 방식과 프레임마다 따로 그리는 방식의 차이를, 직접 써 본 경험이 있다면 적는다.
- [ ] 직접 손으로 그린 포즈 대신 코드로 계산한 뼈대를 쓴 장점과 한계는 무엇인가?
