# VN-Pipeline 포즈 ControlNet

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | PRJ-VNP-102-MP |
| 대상 레포 | [JJH0204/VN-Pipeline](https://github.com/JJH0204/VN-Pipeline) (공개 레포) |
| 읽은 파일 | `vnlib/pose.py`, `vnlib/graphs.py`(`resolve_pose`, `Ctx.apply_pose`), `studio/poses.py`, `studio/web/js/pose.js`(머리말), `vnlib/config.py`(포즈 설정) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 문서는 코드를 읽고 쓴 해설이다. DWPose 모델, ControlNet 파일, ComfyUI가 없어 실행하지 않았다.
{% endhint %}

## 이 영역이 하는 일

"자세"를 OpenPose 뼈대 그림(포즈 맵)으로 만들어 두고, 생성할 때 SDXL ControlNet(OpenPose)이 그 자세를 따라 그리게 한다. 팔다리 위치와 몸 방향은 포즈가, 얼굴·옷·장소는 프롬프트가 정한다. 포즈를 얻는 길은 세 가지다.

| 출처(`source`) | 방법 | 계산 위치 |
|---|---|---|
| `3d` | 3D 모델의 관절 좌표를 브라우저가 계산해 키포인트로 보낸다 | 브라우저 → `POST /api/poses` |
| `image` | 그림에서 DWPose(ONNX)로 사람 자세를 감지한다 | 서버 CPU, `pose.detect()` |
| `upload` | 이미 그려진 OpenPose 그림을 올린다 | 검증·재인코딩만 한다 |

## 구성 요소

| 파일 | 역할 |
|---|---|
| `vnlib/pose.py` | 이름 규칙, 키포인트 검증(`clean_keypoints`), 맵 그리기(`draw`), 감지(`detect`), 저장·목록·삭제, 크기 계산(`gen_size`) |
| `vnlib/graphs.py` | `resolve_pose()`가 JobSpec의 `pose`를 검증하고, `Ctx.apply_pose()`가 ControlNet 노드를 단다 |
| `studio/poses.py` | 포즈 라이브러리 API(목록·조회·생성·감지·삭제), 감지 모델 15분 유휴 해제 |
| `studio/web/js/pose.js` | 포즈 카드, 포즈 고르기 창, 강도·구간·ControlNet 선택 UI |
| `config/settings.json` | `pose_model`, `pose_strength`, `pose_end` 기본값 |
| `input/poses/` | 포즈 파일 폴더(ComfyUI 입력 폴더 아래) |

### 포즈 파일 한 벌

| 파일 | 내용 |
|---|---|
| `pose_<날짜>_<시각>_<4hex>.png` | standard 맵(얇은 선) |
| `pose_….thick.png` | thick 맵(굵은 선) |
| `pose_….json` | 메타 + 정규화 키포인트(0~1) |
| `pose_….src.jpg` | 원본·렌더 미리보기(선택, 긴 변 1024 이하) |

삭제하면 `user/trash/poses/`로 옮긴다(`TRASH_DIR`).

### 사용하는 ControlNet 두 종류

`vnlib/pose.py`의 `CONTROLNETS` 표가 모델 이름에 맵 스타일과 권장 강도를 붙인다. 표에 없는 모델은 `standard`, 강도 1.0이다.

| 파일 이름 | 맵 스타일 | 권장 강도 |
|---|---|---|
| `noob_openpose.safetensors` (기본) | standard | 1.0 |
| `controlnet-openpose-sdxl-1.0.safetensors` | thick | 1.2 |

파일 이름으로 스타일을 판단하므로 이름을 바꾸면 안 된다(`style_for`). 모델 가중치는 레포에 없다.

## 데이터 흐름

```
3D 모델 ─(브라우저가 관절 계산)─┐
그림  ─ pose.detect(DWPose) ───┼─► 정규화 키포인트 {"people":[{"body":18점, "left_hand":21, "right_hand":21}]}
OpenPose 그림 업로드 ──────────┘            │
                                           ▼
                        pose.save_pose() ─ draw(standard) + draw(thick) ─► input/poses/*.png, .json
                                           │
 JobSpec.pose = {"name", "strength"?, "end"?, "model"?}
                                           ▼
        graphs.resolve_pose(): 파일·범위·SDXL 계열 확인 → 맵 변형(variant_for) 선택 → 맵 크기 읽기
                                           ▼
        Ctx.apply_pose(): LoadImage → (크기 다르면 ImageScale 가운데 자르기) → ControlNetLoader
                          → ControlNetApplyAdvanced(positive, negative) → 1차 KSampler 에만 연결
                                           ▼
                        하이레즈·얼굴·손 보정은 포즈 없는 원래 conditioning
```

## 핵심 코드 해설

### 1. 18점 키포인트와 그리기 규칙

점 순서는 OpenPose 18점이다: 0 코, 1 목, 2~4 오른팔, 5~7 왼팔, 8~10 오른다리, 11~13 왼다리, 14~17 눈·귀(좌우는 인물 기준). 선 연결은 `LIMB_SEQ`, 선 색은 `COLORS`에 상수로 있다. 맵은 `draw()` 한 곳에서만 그린다.

{% code title="vnlib/pose.py (draw 발췌)" %}
```python
k = min(W, H) / 512
stick = int(4 * stick_scale * k)
rad = max(1, round(4 * k))
...
for person in kp["people"]:
    pts = [(p[0] * W, p[1] * H) if p else None for p in person["body"]]
    for (a, b), c in zip(LIMB_SEQ, COLORS):  # 먼저 모든 선
        P, Q = pts[a - 1], pts[b - 1]
        if P is None or Q is None:
            continue
        mx, my = (P[0] + Q[0]) / 2, (P[1] + Q[1]) / 2
        length = math.hypot(P[0] - Q[0], P[1] - Q[1])
        angle = math.degrees(math.atan2(P[1] - Q[1], P[0] - Q[0]))
        poly = cv2.ellipse2Poly((int(mx), int(my)), (int(length / 2), stick), int(angle), 0, 360, 1)
        cv2.fillConvexPoly(canvas, poly, [int(v * 0.6) for v in c])
    for pt, c in zip(pts, COLORS):  # 그다음 점
        if pt is not None:
            cv2.circle(canvas, (int(pt[0]), int(pt[1])), rad, c, thickness=-1)
```
{% endcode %}

- 키포인트는 0~1로 정규화해 저장하므로 같은 키포인트로 어떤 크기의 맵도 다시 그린다.
- 선은 두 점 사이를 장축으로 하는 타원 다각형이고, 색은 원색의 60%다. 점은 원색 그대로다.
- `thick`은 `md = max(W,H)/k`가 500 이상일 때 선 굵기 배율을 `min(2 + int(md // 1000), 7)`로 키운다(xinsir ControlNet용).
- `hands=True`면 손 21점을 `HAND_EDGES`로 무지개색 선으로 더 그린다.

### 2. 그림에서 포즈 감지

`detect()`는 `comfyui_controlnet_aux`가 엔진 쪽에 설치한 `dw_onnx` 코드를 파일 경로로 직접 불러와 onnxruntime(CPU)으로 돌린다. ComfyUI의 `DWPreprocessor` 노드와 torch는 쓰지 않는다. 사람 상자는 YOLOX(`yolox_l.onnx`), 관절은 `dw-ll_ucoco_384.onnx`다.

| 단계 | 규칙 |
|---|---|
| 상자 찾기 | 점수 0.3 초과 상자 사용 |
| 없으면 | 2배 흰 캔버스 가운데에 놓고 다시 감지 → 점수 0.02 이상 최선 상자 → 그림 전체를 상자로 |
| 여러 명 | 상자 면적이 가장 큰 1명(`all_people=True`면 전부) |
| 관절 | 점수 0.3 이하 점은 없는 것으로 처리 |
| 채널 | 상자 검출은 BGR, 관절 추정은 RGB (코드 주석: 관절에 BGR을 주면 손이 빠진다) |
| 실패 | 관절이 2개 미만이면 `no_person` 오류 |

### 3. 크기 맞추기

`gen_size(w, h)`는 포즈 크기를 SDXL에 알맞은 생성 크기로 바꾼다. 비율이 기본 크기 이름표와 ±1.5% 이내면 그 크기를 쓰고, 아니면 넓이를 약 1024×1024에 맞춰 8의 배수로 만든다. 코드 주석은 "1메가픽셀보다 훨씬 크게 그리면 몸이 겹치고 느려진다"는 실측을 이유로 든다. 생성 크기가 맵 크기와 다르면 `ImageScale(crop="center")`로 가운데 기준으로 잘라 맞춘다(`Ctx.pose_image`).

### 4. 그래프에 붙이는 방법

{% code title="vnlib/graphs.py (Ctx.apply_pose 발췌)" %}
```python
cn = self._once("cn", lambda: g.out(g.add("ControlNetLoader", "ControlNet 로드", control_net_name=ps["model"])))
node = g.add("ControlNetApplyAdvanced", "포즈 적용", positive=p, negative=n, control_net=cn,
             image=self.pose_image(w, h), strength=float(ps["strength"]), start_percent=0.0,
             end_percent=float(ps["end"]), vae=self.vae)
return g.out(node, 0), g.out(node, 1)
```
{% endcode %}

`render()`에서 이 결과를 1차 `KSampler`에만 넣는다. 강도는 0.1~2.0, 적용 구간 끝은 0.1~1.0으로 검사한다(`POSE_STRENGTH`, `POSE_END`). `resolve_pose()`는 체크포인트가 SDXL 계열(또는 판별 불가)이 아니면 오류를 낸다. `bg`·`pixel`·`icon`·`sheet` 모드는 포즈 지정을 받지 않는다(`NO_PEOPLE_MODES`).

### 5. 이름과 경로 안전

`normalize_name()`은 `pose_x.png`, `poses/pose_x.png`, 포즈 폴더 안의 절대 경로만 받아 파일 이름 하나로 줄인다. `..`, 다른 폴더, `.thick.png`·`.src.png` 이름은 거부한다. 심볼릭 링크가 포즈 폴더 밖을 가리키면 `pose_path()`가 거부한다. 업로드는 20MB 제한, 검증·재인코딩 후 포즈 폴더에만 저장하고 원본 파일은 남기지 않는다(`studio/poses.py`).

## 따라 만들기

확인 상태: 미검증.

1. 18점 순서·연결표·색 상수를 정의하고, 정규화 키포인트(0~1, 없으면 `null`)를 받는 `draw(keypoints, W, H, style)`을 만든다. → 결과: 검은 배경에 색 선과 점이 있는 PNG 배열이 나온다. 같은 키포인트로 `standard`와 `thick` 두 장을 만든다.
2. 키포인트를 검증해 `input/poses/pose_<날짜>_<시각>_<4hex>.png`, `.thick.png`, `.json`으로 저장하는 함수를 만든다. → 결과: 포즈 한 벌이 폴더에 생긴다. 이름은 정규식으로 검사한다.
3. 포즈를 얻는 길을 하나 이상 붙인다. 3D 관절 좌표를 직접 보내거나, DWPose ONNX를 `detect()`처럼 호출한다. → 결과: 그림 한 장에서 키포인트 JSON이 나온다.
4. JobSpec의 `pose`를 검증하는 `resolve_pose()`를 만든다. 파일 존재, 강도·구간 범위, SDXL 계열 여부, 모델 스타일에 맞는 맵(`variant_for`)을 확인한다. → 결과: 잘못된 값은 한국어 오류로 거절된다.
5. 1차 `KSampler` 앞에 `LoadImage` → `ControlNetLoader` → `ControlNetApplyAdvanced`를 달고 하이레즈 이후는 원래 conditioning을 쓴다. → 결과: 같은 시드로 포즈 유무를 비교하면 팔다리 위치만 달라진다.

## 알려진 한계·주의

- 감지는 전신 그림에서 정확하고, 얼굴이 화면을 채운 클로즈업은 부정확할 수 있다(원본 README의 설명이며 직접 확인하지 않았다).
- README는 ControlNet 사용 시 1차 생성이 약 40% 느려진다고 적는다(실측치, 이 문서에서 재현하지 않았다).
- `noob_openpose.safetensors`는 저장소에 라이선스 표기가 없어 NoobAI와 같은 비상업 조건으로 보는 것이 안전하다고 원본이 적는다.
- 3D → 키포인트 계산은 브라우저 JavaScript(`studio/web/js/viewer3d.js`)에 있다. 이 문서는 서버 쪽 저장·적용만 다룬다.
- 다운로드 토큰 등 비밀값은 이 영역에 없다.

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 최초 작성(소스 해체) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 포즈를 1차 생성에만 적용하고 하이레즈·보정에는 적용하지 않은 이유를 어떻게 이해했는가?
- [ ] 얇은 선과 굵은 선 맵을 둘 다 저장해 두는 방식의 장단점은 무엇인가?
