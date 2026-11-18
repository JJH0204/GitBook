# VN-Pipeline 모션 파이프라인

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-VNP-105-D&O |
| 대상 레포 | [JJH0204/VN-Pipeline](https://github.com/JJH0204/VN-Pipeline) (공개 레포) |
| 읽은 파일 | `motion/cli.py`, `motion/estimate.py`, `motion/bvh.py`, `motion/provenance.py`, `studio/motion.py`, `scripts/motion.sh`, `scripts/blender/bvh_to_fbx.py`, `config/motion_licenses.json`, `tests/motion/test_motion.py`, `docs/MOTION_CAPTURE_PLAN.md` |
| 확인 상태 | 미검증 (소스와 계획 문서를 읽고 작성했다. **아무것도 실행하지 않았다**) |
| 개정 | R1 (2026-11-18) |

{% hint style="danger" %}
WARNING: 이 파이프라인은 이 문서를 쓴 환경에서 실행할 수 없다. 추정 모델 가중치(접근 승인이 필요한 모델 포함), 별도 Python 환경(`envs/sam3d`), Apple Silicon의 MPS, Blender가 모두 필요하며 모두 레포에 들어 있지 않다. 이 문서의 동작·수치는 코드 주석과 계획 문서의 기록을 옮긴 것이다. 아래 "실행 안 되는 부분"을 먼저 읽는다.
{% endhint %}

## 이 영역이 하는 일

영상 속 한 사람의 동작을 3D 동작으로 바꿔 Unity Humanoid용 FBX로 내보낸다. 영상 한 편이 아래 결과물이 된다.

| 결과물 | 내용 |
|---|---|
| `<이름>_<보정>.bvh` | 표준 골격(Mixamo식 뼈 이름 52개, 손가락 포함) 동작 |
| `<이름>_<보정>.fbx` | Blender 헤드리스로 BVH를 변환한 Unity용 FBX |
| `<이름>_<보정>.motion.json` | 출처·등급·보정 옵션·손 품질 기록(표기만 하고 내보내기를 막지 않는다) |
| `reference_tpose.fbx` | Unity가 Humanoid 아바타를 만들 때 쓰는 T자세 기준 파일 |
| `src.mp4`, `guide_audio.wav`, `frames/` | 자른 원본, 박자 가이드용 오디오, 프레임별 추정 결과(`f000000.npz` + 오버레이 JPEG) |

이미지 생성 쪽과는 코드가 분리되어 있다. 생성 큐와 메모리를 나눠 쓰는 점만 [작업 큐와 라이브러리](jobs-library.md)와 겹친다. 전체 구조는 [소스 구조](structure.md)에 있다.

## 실행 안 되는 부분과 한계

| 항목 | 상태 | 근거 |
|---|---|---|
| 이 문서의 모든 단계 | 미검증. 실행하지 않았다 | 환경 없음 |
| 모델 가중치 | 레포에 없음. 일부는 접근 승인이 필요하다 | `motion/estimate.py`가 `models/motion/` 경로를 읽는다 |
| Python 환경 | 새로 만드는 스크립트가 없다. `motion/requirements.lock`과 패치 파일(`motion/sam3d-apple-silicon.patch`)만 있고 "새 설치는 시험 안 함"이라고 계획 문서가 적는다 | `docs/MOTION_CAPTURE_PLAN.md` 1단계 구현 결과 |
| 장치 | 코드의 기본 장치가 `mps`다. CUDA나 CPU 경로는 시험한 기록이 없다 | `estimate(..., device="mps")` |
| 계획 중 미구현 | 발 고정(2-본 IK), 루프 블렌딩, 프레임레이트 변환, SMPL-24 입력, 외부 FBX·BVH 가져오기, 이미지 → 키프레임 클립 | 계획 문서 "하지 않은 것"과 2~3단계 |
| 단일 인물·고정 카메라 전제 | 루트 이동은 카메라 이동 값에서 얻어 고정 카메라에서만 실제 이동이 된다 | `convert()` 주석 |
| 입력 영상 품질 | 사람 키 700px 미만이면 손가락이 뭉개질 수 있다. 손 등급으로 표기만 한다 | 계획 문서 "소스 영상 품질 규칙" |
| 테스트 | `tests/motion/test_motion.py` 함수 8개. 별도 환경에서만 돌고 이 문서에서는 돌리지 않았다 | 파일 머리말 |
| Unity 검증 | 계획 문서가 기록한 Unity 6000.3 임포트 시험 결과는 이 문서에서 재현하지 않았다 | 계획 문서 |

{% hint style="warning" %}
CAUTION: 계획 문서의 3~5단계(외부 클립, Unity 영상 제작)는 구현이 아니라 계획이다. 이 문서는 구현된 1단계(공통 백엔드)와 Studio 모션 탭의 서버 쪽만 다룬다.
{% endhint %}

## 구성 요소

| 파일 | 역할 |
|---|---|
| `scripts/motion.sh` | 환경 변수(`env.sh`)를 읽고 `envs/sam3d`의 Python으로 `motion.cli`를 실행. 표준 입력은 닫는다 |
| `motion/cli.py` | 명령 `run`(자르기 → 추정 → FBX), `export`(보정만 다시), `info`(영상 정보 JSON), `frame`(한 프레임 JPEG) |
| `motion/estimate.py` | SAM 3D Body로 프레임별 추정. 사람 고르기·추적, 프레임마다 `f<번호>.npz`와 오버레이 JPEG 저장 |
| `motion/bvh.py` | 추정 결과 → 표준 골격 회전, 평활, 바닥 맞춤, BVH 쓰기 |
| `scripts/blender/bvh_to_fbx.py` | Blender 헤드리스 BVH → FBX |
| `motion/provenance.py` | 출처 등급(세 축 중 최악)과 손 등급, `.motion.json` 기록 |
| `config/motion_licenses.json` | 도구별 등급표(요약·조문 인용·링크·확인 날짜) |
| `studio/motion.py` | Studio 서버 쪽: 업로드, 실행기(한 번에 1개), 진행률, 클립 목록, 다시 내보내기, Unity 묶음(zip), 삭제 |
| `studio/web/js/views/motion.js` | 모션 탭 화면(이 문서에서 읽지 않았다) |

## 데이터 흐름

```
영상 업로드(최대 16GB, mp4·mov·m4v·mkv·webm·avi)
  │  Studio: 이미지 작업·ComfyUI 큐가 비어 있을 때까지 대기 → ComfyUI에서 모델 내리기 → 하위 프로세스 시작
  ▼
scripts/motion.sh run <영상> <이름> --source … --choreo …
  ├ 단계: 자르기        ffmpeg → src.mp4(libx264, crf 12, 오디오 없음) + guide_audio.wav
  ├ source.json         출처 입력값 저장
  ├ 단계: 모델 불러오기  SAM 3D Body + MHR 모델 + 시야각 추정(MoGe-2) + 사람 탐지기(ViTDet, CPU)
  │   프레임마다: 사람 상자 → 추정 → f<번호>.npz + 오버레이 JPEG
  └ 단계: FBX 변환
        bvh.convert(): MHR 순전파로 관절 월드 회전 → 휴식 자세 대비 회전 → 중앙값(5프레임)+가우시안 평활
                       → 표준 골격 회전으로 재배치 → 바닥 높이 보정 → BVH(Euler YXZ)
        Blender --background → FBX
        provenance.record() → <이름>_<보정>.motion.json
  ▼
Studio: 클립 카드·미리보기, 다시 내보내기(추정 없이), Unity 묶음 zip
```

Studio의 진행률은 하위 프로세스가 찍는 `단계: …` 줄과 `f000123 2.30s` 형태의 프레임 줄을 정규식으로 읽어 만든다(`STAGE_RE`, `FRAME_RE`). 실행 로그 전체는 `output/motion/<이름>/run.log`에 남고, 취소·서버 종료는 프로세스 그룹째 끝낸다.

## 핵심 코드 해설

### 1. 사람을 고르고 따라간다 (`motion/estimate.py`)

- 첫 프레임에서 탐지된 상자 중 `--pick x,y`에 가장 가까운 것을 고른다. 지정하지 않으면 맨 왼쪽 사람이다.
- 이후 `--det-every`(기본 8)프레임마다 다시 탐지해, 직전 상자와 겹침(IoU)이 0.3을 넘는 상자로 갱신한다. 넘지 않으면 이전 상자를 유지한다.
- 탐지하지 않는 프레임에서는 직전 프레임의 2D 관절 범위에 탐지 때의 여백 비율을 씌워 상자를 만든다. 계획 문서는 매 프레임 탐지하면 메모리 부족이었고 이 방식이 프레임당 약 2.3초였다고 기록한다(재현하지 않았다).
- 화각(카메라 내부 변수)은 첫 프레임 값을 재사용한다. 사람을 못 찾는 프레임은 건너뛰고, 내보낼 때 직전 프레임을 반복한다.

{% code title="motion/estimate.py (카메라 값 재사용)" %}
```python
K, f = [], fov.get_cam_intrinsics  # fixed lens: reuse the first frame's intrinsics
fov.get_cam_intrinsics = lambda img, **k: K[0] if K else (K.append(f(img, **k)) or K[0])
```
{% endcode %}

### 2. 회전 기반 리타겟 (`motion/bvh.py`)

위치를 IK로 맞추지 않고 관절의 월드 회전을 휴식 자세 기준 차이로 옮긴다. 모든 클립이 같은 고정 골격(MHR 평균 체형)을 쓰므로 Unity 기준 아바타 하나가 모든 클립에 맞는다. 모듈 머리말은 그 이유를 "메시 없는 FBX는 Unity가 첫 애니메이션 프레임에서 기본 자세를 읽기 때문"이라고 적는다. 그래서 Unity에서는 T자세 기준 FBX로 아바타를 만들고 클립은 "Copy From Other Avatar"를 쓴다(계획 문서 4단계).

### 3. 평활과 바닥 맞춤

{% code title="motion/bvh.py (평활 프리셋)" %}
```python
SMOOTH = {"off": 0, "light": 0.75, "strong": 1.5}
FINGERS = np.r_[43:65, 79:101]  # MHR r/l pinky0 .. thumb_null
```
{% endcode %}

- `smooth()`는 5프레임 중앙값으로 한두 프레임 튐을 지우고, 쿼터니언을 같은 반구로 맞춘 뒤 가우시안 평활을 한다. 손가락은 시그마를 2배로 쓴다.
- `light`는 빠른 손동작을 덜 지우고 `strong`은 떨림을 가장 많이 지운다. 주석은 `strong`이 3.3Hz 손 흔들기를 40%로 줄였다고 적는다.
- 바닥은 발 접촉점의 높이를 1초 구간 최솟값으로 구해 빼서 맞춘다. 발이 바닥에 닿고, 짧은 점프는 공중에 남고, 느린 드리프트는 사라진다.
- `--in-place`는 수평 이동(x, z)을 0으로 만든다.

### 4. 출처 등급 (`motion/provenance.py`)

등급은 도구·원본·안무 세 축 중 가장 나쁜 쪽이다(`ok < check < no`). 원본이 직접 촬영·직접 만든 AI 영상이면 `ok`, 남의 영상·라이브러리·서비스·출처 불명이면 `check`다. 안무는 자체·안무 아님이 `ok`, 남의 안무가 `check`다. 막거나 묻지 않고 표기만 한다.

손 등급은 두 손 중 낮은 쪽의 "손 상자 짧은 변이 64px를 넘는 프레임 비율"이다. A는 90% 이상, B는 50~90%, C는 50% 미만이다. 근거는 추정 모델이 손 상자가 64px 이하이면 손 정밀 추정 결과를 버린다는 점이라고 주석이 적는다.

## 따라 만들기

확인 상태: 미검증. 환경이 갖춰진 경우에만 의미가 있는 순서다. 각 단계의 "→ 결과"는 코드와 계획 문서에 적힌 기대값이다.

1. 모델 가중치와 소스를 받아 `models/motion/`, `envs/src/`에 둔다(접근 승인 필요). 환경은 `motion/requirements.lock`과 패치로 만든다. → 결과: `scripts/motion.sh info <영상>`이 길이·fps·크기를 JSON 한 줄로 낸다.
2. `scripts/motion.sh run <영상> <이름> --source own --choreo none --duration 3`을 실행한다. → 결과: `output/motion/<이름>/frames/`에 프레임별 `.npz`가 쌓이고 마지막에 FBX가 만들어진다. 계획 문서는 3초 구간이 약 4분 26초 걸렸다고 기록한다.
3. 결과 폴더에서 `<이름>_light.bvh`, `.fbx`, `.motion.json`을 확인한다. → 결과: `.motion.json`의 `license.level`이 `ok`, 손 등급이 A~C로 적힌다.
4. 보정만 바꾼다. `scripts/motion.sh export <이름> --smooth strong`. → 결과: 추정 없이 수 초 안에 `<이름>_strong.*`가 만들어진다(계획 문서의 기록).
5. Unity에서 `reference_tpose.fbx`로 Humanoid 아바타를 만들고(Spine2를 UpperChest로 지정) 클립은 "Copy From Other Avatar", Root Transform 기준은 Original로 둔다. → 결과: 아바타가 유효하고 클립 길이가 `.motion.json`의 프레임 수와 맞는다.

## 알려진 한계·주의

{% hint style="warning" %}
CAUTION: 추정 모델과 인체 모델, 학습 데이터의 라이선스 조건이 서로 다르다. 계획 문서는 일부가 비상업·한국 제외 등 명시적 제한이라고 적는다. 이 문서는 등급표(`config/motion_licenses.json`)의 구조만 설명하며 법적 판단을 하지 않는다. 영상을 쓰기 전에 직접 확인한다.
{% endhint %}

- 남의 영상, 남의 안무는 모델 라이선스와 별개로 원본 권리 문제가 있다. 출처 등급이 `check`가 되는 이유다.
- `motion/cli.py`의 `frame`·`info`는 영상을 디코딩해 첫 프레임 크기를 읽는다. 휴대폰 회전이 적용된 방향이 추정에 쓰이는 방향과 같다는 주석이 있다.
- 오디오는 `guide_audio.wav`로 따로 저장될 뿐 FBX에는 들어가지 않는다.
- Studio는 올린 영상을 최근 5개만 남긴다(`KEEP_UPLOADS`).
- 계획 문서가 적은 알려진 편향: 추정기가 앞으로 숙이고 무릎을 굽히는 경향, 걷기에서 발이 뜨는 현상. 이 문서에서 확인하지 않았다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성(소스 해체, 실행 안 되는 부분 명시) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 영상 한 편에서 3D 동작을 뽑을 때 가장 먼저 부딪힌 문제는 무엇이었는가?
- [ ] 출처 등급을 "막지 않고 표기만" 하기로 한 결정에 대해 어떻게 생각하는가?
- [ ] 이 파이프라인을 직접 돌려 본 뒤 이 문서에서 틀렸거나 빠진 부분을 적는다.
