# 툰 셰이더 실습실 (Toon Shader Lab)

**빈 Unity 프로젝트에서 HLSL을 한 줄씩 직접 짜서** 툰 셰이더를 완성하는 22일 과정이에요. 하루 1시간.

![완성](../.gitbook/assets/day22-final.png)

- 🧑‍💻 매일 **내 손으로 코드를 치고**, 끝나면 화면에서 결과를 확인해요
- 🧸 개념은 어린이에게 설명하듯 **비유**로, 수학은 짧게 + **참고 링크**로
- ✅ 날짜별 **정답 셰이더**가 있어서 막히면 비교할 수 있어요 (Unity 6000.3에서 전부 컴파일·렌더링 확인)
- 🖼️ 레슨의 결과 화면은 모두 이 프로젝트에서 정답 셰이더로 실제로 찍은 것이에요
- 📝 매일 끝에 [액기스 요약](essence.md)

{% hint style="info" %}
짝꿍 과정 [툰 셰이더 공부 노트](../toon-shader-study/README.md)는 실제 게임에 쓰는 완성형 툰 셰이더를 **읽으며** 배우는 자료예요. 이 과정에서 **직접 만들고**, 그쪽에서 "실전에서는 어떻게 하나"를 보면 좋아요. 레슨마다 "더 깊이" 링크로 이어져 있어요.
{% endhint %}

## 시작하기

레슨은 이 GitBook에 있고, 실습용 Unity 프로젝트는 GitHub 저장소 [toon-shader-lab](https://github.com/JJH0204/toon-shader-lab)(비공개)에 있어요.

1. **Unity 6000.3** (Unity 6.3 LTS)을 설치해요. 이 프로젝트는 6000.3.27f2로 만들었어요.
2. 클론하고 내 작업용 브랜치를 만들어요.
   ```bash
   git clone https://github.com/JJH0204/toon-shader-lab.git
   cd toon-shader-lab
   git switch -c my-toon
   ```
3. Unity Hub → Add project from disk → 이 폴더. 열리면 `Assets/Scenes/Lab`을 열어요.
4. [Day 01](day01-first-shader.md)부터 시작!

## 규칙

| 폴더 | 내용 |
|---|---|
| `Assets/MyToon/` | **내가 짜는 곳.** 처음엔 없어요. Day 01에 직접 만들어요 |
| `Assets/Solutions/DayNN/` | 날짜별 **정답**. 그날 끝난 상태의 셰이더 전체 + 머티리얼. 셰이더 이름은 `Solutions/DayNN` |
| `Assets/Scenes/Lab.unity` | 실험 씬: 구·캡슐·큐브, 바닥, 해, (꺼진) 빨간 전구와 그림자 막대 |
| `Assets/Textures/` | 실습 텍스처: 줄무늬+구멍(`Lab_Base`), MatCap 공(`Lab_MatCap`), 벽돌 노멀맵(`Lab_Normal`) |
| `Assets/LabTools/` | 메뉴 **Lab → Rebuild Lab Scene**(씬 초기화)과 문서용 캡처 도구 |
| `tools/` | 정답 셰이더·문서 이미지를 다시 만드는 스크립트 (학습에는 필요 없어요) |

## 커리큘럼

### 1주차 — 셰이더의 뼈대

| Day | 오늘 만드는 것 | 새로 배우는 것 |
|---|---|---|
| [01](day01-first-shader.md) | 단색 셰이더 | 셰이더 뼈대, vert/frag, 머티리얼 |
| [02](day02-vertex-shader.md) | 숨쉬는 물체 | 좌표 공간, 노멀, `_Time`, `sin` |
| [03](day03-properties.md) | 인스펙터에서 색 고르기 | Properties, CBUFFER, SRP Batcher |
| [04](day04-varyings-debug.md) | 노멀·UV 디버그 보기 | Varyings, 보간, 스위즐 |
| [05](day05-textures.md) | 텍스처 + 구멍 뚫기 | 텍스처 샘플링, 타일링, `clip` |

### 2주차 — 빛과 그림자

| Day | 오늘 만드는 것 | 새로 배우는 것 |
|---|---|---|
| [06](day06-first-light.md) | 해를 받는 물체 | 내적, 하프 램버트, `GetMainLight` |
| [07](day07-toon-steps.md) | **툰 계단** 두 칸 | `smoothstep`, 함수, `lerp` |
| [08](day08-receive-shadows.md) | 그림자 받기 | 섀도맵, `multi_compile` |
| [09](day09-cast-shadows.md) | 그림자 드리우기 | HLSLINCLUDE, ShadowCaster·DepthOnly 패스 |
| [10](day10-ambient-fog.md) | 맑은 그림자 + 안개 | SH 환경광, 안개 |
| [11](day11-additional-lights.md) | 빨간 전구 받기 | 보조 조명 루프, Forward+, `.hlsl` 파일 |

### 3주차 — 툰 효과

| Day | 오늘 만드는 것 | 새로 배우는 것 |
|---|---|---|
| [12](day12-rim-light.md) | 테두리 빛 | 프레넬, 시선 방향 V |
| [13](day13-outline-pass.md) | 외곽선 | 두 번째 색칠 패스, `Cull Front` |
| [14](day14-outline-pixels.md) | 항상 2픽셀 외곽선 | 클립 공간 `w`, NDC |
| [15](day15-specular.md) | 만화식 반짝임 | 하프 벡터, `pow` |
| [16](day16-matcap.md) | MatCap 광택 | 뷰 공간 노멀 → UV |
| [17](day17-normal-map.md) | 벽돌 노멀맵 | 탄젠트 공간, `cross` |

### 4주차 — 마무리

| Day | 오늘 만드는 것 | 새로 배우는 것 |
|---|---|---|
| [18](day18-keywords.md) | 기능 체크박스 | 키워드, 배리언트, `shader_feature` |
| [19](day19-depthnormals-ssao.md) | 구석 그늘 | DepthNormals 패스, SSAO |
| [20](day20-two-sided.md) | 양면 그리기 | `Cull [_Cull]`, `IS_FRONT_VFACE`, 점검 |
| [21](day21-screen-outline.md) | 화면 공간 외곽선 | 풀스크린 셰이더, Renderer Feature |
| [22](day22-graduation.md) | 졸업 | 전체 복습, 실제 게임 셰이더와 비교 |

### 진도 체크

- [ ] 01 · [ ] 02 · [ ] 03 · [ ] 04 · [ ] 05
- [ ] 06 · [ ] 07 · [ ] 08 · [ ] 09 · [ ] 10 · [ ] 11
- [ ] 12 · [ ] 13 · [ ] 14 · [ ] 15 · [ ] 16 · [ ] 17
- [ ] 18 · [ ] 19 · [ ] 20 · [ ] 21 · [ ] 22

## 수학이 걱정된다면

| 수학 | 처음 나오는 날 | 먼저 보면 좋은 자료 |
|---|---|---|
| 좌표 변환, 행렬 | Day 02 | 🎥 [3Blue1Brown — 선형 변환](https://www.3blue1brown.com/lessons/linear-transformations) |
| sin 파도 | Day 02 | [위키백과 — 삼각함수](https://ko.wikipedia.org/wiki/%EC%82%BC%EA%B0%81%ED%95%A8%EC%88%98) |
| 벡터, 내적 | Day 06 | 🎥 [3Blue1Brown — 내적](https://www.3blue1brown.com/lessons/dot-products) |
| smoothstep, lerp | Day 07 | [The Book of Shaders — Shaping Functions (한국어)](https://thebookofshaders.com/05/?lan=kr) |
| 동차좌표 `w` | Day 14 | [위키백과 — 동차좌표](https://ko.wikipedia.org/wiki/%EB%8F%99%EC%B0%A8%EC%A2%8C%ED%91%9C) |
| 외적 | Day 17 | 🎥 [3Blue1Brown — 외적](https://www.3blue1brown.com/lessons/cross-products) |

## 다시 만들기 (관리용)

- 정답 셰이더는 `tools/templates/*.tpl` 한 벌에서 날짜별로 뽑아요: `python tools/gen_solutions.py`. 템플릿의 `//@ 9-`(9일차부터), `//@ -8`(8일차까지), `//@ end` 표시로 날짜별 코드를 고릅니다.
- 문서 이미지: 에디터에서 `ToonShaderLab.Editor.LabDocCaptures.CaptureAll("<폴더>")` → `python tools/compose_docs_images.py <폴더>`.
- 개념 그림(`docs/images/concept-*.png`)은 [toon-shader-study](../toon-shader-study/README.md)의 `tools/`에서 만든 것이에요.

## 원본 레포

* [JJH0204/toon-shader-lab](https://github.com/JJH0204/toon-shader-lab) (비공개, 참고용): 실습용 Unity 프로젝트가 있는 레포다. 레슨은 이 GitBook에서 본다.
