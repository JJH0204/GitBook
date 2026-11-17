# 툰 셰이더 공부 노트 (Toon Shader Study)

실제 게임 프로젝트에서 쓰는 Unity URP 툰 셰이더(`com.blueigloo.shader` v0.2.0)의 소스를 **처음부터 한 줄씩** 읽으며 셰이더를 배우는 22일 과정이에요.

- 📅 **하루 1시간**, 22일 (주 5일이면 약 4주 반)
- 🧸 어린이에게 설명하듯 **비유**로 시작하고, 진짜 코드로 끝나요
- 🖼️ 개념 그림 + 실제 Unity에서 찍은 **수정 전·후 캡처**
- 🧮 필요한 수학은 본문에서 짧게, 깊이는 **참고 링크**로
- 📝 매일 끝에 [액기스 요약](essence.md)

![샘플](../.gitbook/assets/day01-sample-spheres.png)

{% hint style="success" %}
**직접 짜면서 배우고 싶다면** 짝꿍 과정 [툰 셰이더 실습실](../toon-shader-lab/README.md)에서 시작하세요. 빈 Unity 프로젝트에서 HLSL을 한 줄씩 쳐서 22일 만에 툰 셰이더를 완성하는 실습 과정이에요. 이 자료는 그다음에 "실제 게임 셰이더는 어떻게 하나"를 읽는 자료예요. 이 자료의 "해보기"에서 Unity 실습이 필요하면 부모 프로젝트 대신 그 실습 프로젝트를 써도 돼요.
{% endhint %}

## 공부하는 법

하루 한 파일을 이 순서로 보세요.

1. **오늘 배울 것** 체크리스트를 먼저 읽어요 (1분)
2. **비유와 그림**으로 개념을 잡아요 (20~25분)
3. **실제 코드 읽기** — 링크를 누르면 `source/`의 해당 줄로 바로 가요 (20분)
4. **해보기** — 손계산, [Desmos](https://www.desmos.com/calculator) 그래프, (가능하면) Unity에서 슬라이더 움직이기 (15분)
5. **[액기스](essence.md)** 로 복습 (2분)

{% hint style="success" %}
코드를 다 이해하지 못해도 괜찮아요. 처음엔 **"이 줄은 무슨 역할인가"** 만 잡고 넘어가세요. Day 22에서 전체를 다시 읽을 때 연결돼요.
{% endhint %}

**준비물**
- 선택: Unity 6 + 부모 프로젝트 `unity-toonshader` — "해보기"에서 슬라이더를 직접 움직여 볼 수 있어요. 없어도 손계산과 그림으로 따라올 수 있어요.

## 커리큘럼

### 1주차 — 셰이더의 기본기

| Day | 주제 | 오늘의 비유 | 주로 읽는 소스 |
|---|---|---|---|
| [01](day01-what-is-a-shader.md) | 셰이더가 뭐예요? | GPU 공장의 작업 지시서 | 소스 전체 지도 |
| [02](day02-coordinate-spaces.md) | 좌표 공간 여행 | 주소 체계와 주소 바꾸는 기계 | `vert()` 함수들 |
| [03](day03-shaderlab-skeleton.md) | 셰이더 파일의 뼈대 | 요리책 한 권 | `SceneToon_Sky.shader` 통째로 |
| [04](day04-hlsl-basics.md) | HLSL 문법 기초 | 택배 상자와 이름표 | `ToonRim.hlsl`, `ToonInput.hlsl` |
| [05](day05-textures-and-uv.md) | 텍스처와 UV | 전개도 좌표와 가위 | `ClipToonSurface`, ILM 맵 |

### 2주차 — 빛과 그림자

| Day | 주제 | 오늘의 비유 | 주로 읽는 소스 |
|---|---|---|---|
| [06](day06-vectors-and-light.md) | 벡터와 빛 | 화살표 점수, 손전등 | 하프 램버트, `lightVal` |
| [07](day07-toon-steps.md) | 툰 계단 만들기 | 미끄럼틀 → 계단, 사포 | 1·2차 그림자 밴드 |
| [08](day08-shadows.md) | 그림자 | 빛이 찍은 거리 사진 | ShadowCaster 패스 |
| [09](day09-many-lights.md) | 여러 개의 빛 | 무대 조명 팀 | 추가광, Forward+, 캐릭터 조명 |
| [10](day10-ambient-gi-ssao.md) | 환경광, GI, SSAO | 튕겨 온 빛, 날씨 엽서, 구석 그늘 | `SampleSH`, `ToonPosterize` |
| [11](day11-rim-light.md) | 림 라이트 | 역광에 빛나는 가장자리 | 프레넬 림, 깊이 림 |

### 3주차 — 툰 효과들

| Day | 주제 | 오늘의 비유 | 주로 읽는 소스 |
|---|---|---|---|
| [12](day12-outline-inverted-hull.md) | 외곽선 ① 인버티드 헐 | 뒤집힌 검은 풍선 | Outline 패스, 스무스 노멀 |
| [13](day13-outline-pixel-width.md) | 외곽선 ② 픽셀 두께 | 멀면 깜빡이는 가는 실 | `ToonOutline.hlsl`의 `× w` |
| [14](day14-screen-space-outline.md) | 외곽선 ③ 화면 공간 | 다 그린 그림에 펜으로 | `ScreenSpaceOutline`, Renderer Feature |
| [15](day15-face-sdf.md) | 얼굴 SDF 그림자 | 밀물 지도 | Face SDF, MaterialPropertyBlock |
| [16](day16-normal-maps-and-derivatives.md) | 노멀맵과 미분 | 빛에게 하는 거짓말, 옆자리 답안 | `ddx/ddy`, 탄젠트 없는 노멀맵 |
| [17](day17-highlights.md) | 반짝임 3종 | 거울의 해, 결 따라 빛 띠, 구슬 스티커 | 스펙큘러, 천사 고리, MatCap |

### 4주차 — 엔지니어링과 마무리

| Day | 주제 | 오늘의 비유 | 주로 읽는 소스 |
|---|---|---|---|
| [18](day18-passes.md) | 패스 총정리 | 촬영 팀 여섯 | Depth/Normals/MotionVectors, 스텐실 |
| [19](day19-keywords-and-variants.md) | 키워드와 배리언트 | 옵션별로 굽는 빵집 | `#pragma`, 스트리퍼, 정리기 |
| [20](day20-performance.md) | 성능 | 택배 건수와 창고 재료표 | SRP Batcher, 인스턴싱, GRD |
| [21](day21-background-shaders.md) | 배경 셰이더 | 물감 네 통 지도 | SceneToon, 지형, 바람 |
| [22](day22-graduation.md) | 졸업 — 한 픽셀의 일생 | 픽셀의 여행기 | `frag` 전체 + 숙제 |

### 진도 체크

GitBook에서 이 페이지를 편집해서 체크하면 진도표가 돼요.

- [ ] Day 01 · [ ] Day 02 · [ ] Day 03 · [ ] Day 04 · [ ] Day 05
- [ ] Day 06 · [ ] Day 07 · [ ] Day 08 · [ ] Day 09 · [ ] Day 10 · [ ] Day 11
- [ ] Day 12 · [ ] Day 13 · [ ] Day 14 · [ ] Day 15 · [ ] Day 16 · [ ] Day 17
- [ ] Day 18 · [ ] Day 19 · [ ] Day 20 · [ ] Day 21 · [ ] Day 22

## 자료 구성

- 이 페이지 아래: Day 01–22, [액기스 모음](essence.md), [소스 지도](source-map.md)
- 셰이더 소스: [GameDev/toon-shader-study/source](https://github.com/JJH0204/GitBook/tree/main/GameDev/toon-shader-study/source) (com.blueigloo.shader v0.2.0, 본문의 줄 번호 링크가 여기로 가요)
- 개념 그림 스크립트: [GameDev/toon-shader-study/tools](https://github.com/JJH0204/GitBook/tree/main/GameDev/toon-shader-study/tools)

## 수학이 걱정된다면

이 과정에 나오는 수학은 딱 이만큼이에요. 처음 나올 때 본문에서 비유로 설명하고 링크를 달아 뒀어요.

| 수학 | 처음 나오는 날 | 먼저 보면 좋은 자료 |
|---|---|---|
| 벡터, 내적 | Day 06 | 🎥 [3Blue1Brown — 벡터](https://www.3blue1brown.com/lessons/vectors), [내적](https://www.3blue1brown.com/lessons/dot-products) |
| 행렬, 좌표 변환 | Day 02 | 🎥 [3Blue1Brown — 선형 변환](https://www.3blue1brown.com/lessons/linear-transformations), [행렬 곱셈](https://www.3blue1brown.com/lessons/matrix-multiplication) |
| 동차좌표 (`w`) | Day 02, 13 | [위키백과 — 동차좌표](https://ko.wikipedia.org/wiki/%EB%8F%99%EC%B0%A8%EC%A2%8C%ED%91%9C), [LearnOpenGL — Coordinate Systems](https://learnopengl.com/Getting-started/Coordinate-Systems) |
| cos, sin | Day 06, 17, 21 | [위키백과 — 삼각함수](https://ko.wikipedia.org/wiki/%EC%82%BC%EA%B0%81%ED%95%A8%EC%88%98) |
| 보간 (lerp), smoothstep | Day 03, 07 | [The Book of Shaders — Shaping Functions (한국어)](https://thebookofshaders.com/05/?lan=kr) |
| 외적 | Day 16 | 🎥 [3Blue1Brown — 외적](https://www.3blue1brown.com/lessons/cross-products) |
| 유한 차분 (미분 어림) | Day 16 | [Wikipedia — Finite difference](https://en.wikipedia.org/wiki/Finite_difference) |

전체를 한 번에 잡고 싶으면 🎥 [3Blue1Brown — Essence of Linear Algebra](https://www.3blue1brown.com/topics/linear-algebra) (YouTube, 한국어 자막)을 추천해요.

## 자료 출처

- **소스**: `com.blueigloo.shader` 태그 `v0.2.0` (커밋 `6b0b466`). `.meta` 파일만 빼고 그대로 복사했어요. 원본이 바뀌어도 이 자료는 그대로라서 본문의 줄 번호 링크가 어긋나지 않아요.
- **수정 전·후 캡처** (`images/` 중 "고치기 전/고친 뒤" 그림): v0.2.0 개선 작업(카드 A1~C8) 때 부모 프로젝트에서 Unity로 실제로 찍은 화면이에요. 본문의 "💡 이 프로젝트에서 실제로 있었던 일"이 그 이야기예요. 자세한 기록은 [source/CHANGELOG.md](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CHANGELOG.md).
- **개념 그림** (그래프·도식): [tools/](https://github.com/JJH0204/GitBook/tree/main/GameDev/toon-shader-study/tools)의 Python(matplotlib) 스크립트로 만들었어요. matplotlib과 맑은 고딕 글꼴(Windows)이 있으면 `python tools/make_diagrams.py images`, `python tools/make_diagrams2.py images` 로 다시 만들 수 있어요.
