# Day 22. 졸업 — 한 픽셀의 일생

> ⏱ **약 1시간** — 통째로 읽기 35분 · 숙제 설계 15분 · 다음 공부 10분
> 🧸 **오늘의 비유**: 픽셀 하나가 태어나서 화면에 칠해질 때까지의 **여행기**를 처음부터 끝까지 따라가요.

## 오늘 배울 것

- [ ] [CharacterToon.shader의 frag](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L285-L666)를 처음부터 끝까지 막힘없이 읽는다
- [ ] 기능을 하나 추가할 때 고쳐야 하는 곳의 목록을 안다
- [ ] 다음에 무엇을 공부할지 정한다

---

## 1. 한 픽셀의 여행기

아래 표를 옆에 두고 [L285–666](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L285-L666)을 위에서 아래로 읽어 보세요. 모르는 줄이 나오면 그 Day로 돌아가세요.

| 줄 | 여행 단계 | 하는 일 | Day |
|---|---|---|---|
| 285–290 | 👶 태어남 | 앞면/뒷면 확인, 뒷면이면 노멀 뒤집기 | 18 |
| 292 | 👕 옷 입기 | 바탕 텍스처 × 바탕 색 | 05 |
| 297 | ✂️ 가위 | 오릴 곳이면 여기서 끝 | 05, 18 |
| 302–307 | 🧭 방향 찾기 | 노멀 N (노멀맵), 시선 V | 06, 16 |
| 313–319 | 🏠 구석 확인 | SSAO 값 | 10 |
| 321–329 | 🔭 거리 확인 | 멀면 장식 줄이기 (hqAmount) | 20 |
| 332–337 | 🌞 해 찾기 | 메인 라이트 + 그림자 정보 + 레이어 | 08, 09 |
| 340–343 | 🗺️ 지도 펼치기 | ILM 맵 | 05 |
| 347–352 | 📸 조명 고르기 | 캐릭터 조명 or 해 | 06, 09 |
| 355–358 | 🔦 손전등 점수 | 하프 램버트 + ILM 편향 → `lightVal` | 06 |
| 363–405 | 🙂 얼굴이면 | SDF 지도로 `faceLit` | 15 |
| 408–410 | 🌳 드리운 그림자 | `lightVal`에 그림자 곱하기 | 08 |
| 415–420 | 🚫 그림자 억제 | 마스크로 그림자 지우기 | 19 |
| 424–448 | 🪜 계단 만들기 | 1·2차 밴드 (또는 램프) | 07 |
| 452–455 | 🎨 빛 색 | 캐릭터 조명 색 or 해 색 | 09 |
| 461–465 | ☁️ 하늘빛 | SH 환경광 (그림자 쪽엔 덜) + 바닥 | 10 |
| 469–470 | 📸 추가 캐릭터 조명 | 2순위 이하 더하기 | 09 |
| 475–493 | 💡 보조 조명 | 포인트·스폿 더하기 | 09 |
| 496–520 | ✨ 테두리 빛 | 프레넬 림 + 깊이 림 | 11 |
| 524–573 | 🔮 구슬 스티커 | MatCap 1, 2 | 17 |
| 581–609 | 💎 반짝임 | 툰 스펙큘러 + 환경 반사 | 17 |
| 612–628 | 😇 천사 고리 | 머리카락 이방성 하이라이트 | 17 |
| 633–639 | 🩸 피부 | SSS (사용 중단 예정) | — |
| 640 | | 림 더하기 | 11 |
| 648–655 | 👁️ 눈 | 시차로 깊이감 | 16 |
| 658–661 | 💡 발광 | Emission 더하기 | — |
| 664–665 | 🌫️ 안개, 끝 | 안개 섞고 **출력!** | — |

{% hint style="success" %}
흐름의 뼈대는 딱 세 줄이에요.
1. **`lightVal`을 만든다** (손전등 점수 + 지도 + 그림자)
2. **계단으로 바꿔 색을 정한다** (1·2차 그림자 색)
3. **빛나는 것들을 더한다** (하늘빛, 보조 조명, 림, MatCap, 반짝임, 발광)

나머지는 전부 이 세 단계의 장식이에요.
{% endhint %}

## 2. 숙제: 기능 하나 추가해 보기

이제 직접 고쳐 볼 차례예요. 부모 프로젝트(`unity-toonshader`)에서 해 보세요. 예제 과제: **"그림자 색을 시간에 따라 천천히 바꾸는 `_ShadowHueShift` 슬라이더"** (밤낮 연출 흉내).

기능 하나를 추가할 때 손대야 하는 곳의 **체크리스트**예요. 22일 동안 배운 규칙들이 다 들어 있어요.

- [ ] **Properties** — 슬라이더 추가 ([CharacterToon.shader L5–184](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L5-L184), Day 03)
- [ ] **CBUFFER** — [ToonInput.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L34-L178)에 같은 이름으로 추가. 색칠 패스에만 넣으면 안 돼요! (Day 04, 20)
- [ ] **켜고 끄기** — 키워드로 할까(`shader_feature_local_fragment`), 숫자 분기로 할까? (Day 19)
- [ ] **계산** — frag의 알맞은 위치. 그림자 색이니까 "계단 만들기"(L424–448) 근처 (Day 07)
- [ ] **NaN 방지** — 나눗셈, `normalize`, `smoothstep` 폭에 바닥 깔기 (Day 06, 07)
- [ ] **다른 패스** — 모양이나 구멍을 바꾸는 기능이면 **모든 패스**에 (Day 18). 색만 바꾸면 ForwardToon만.
- [ ] **Unlit 셰이더** — 같은 기능이 필요한가? ([CharacterToon_Unlit.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon_Unlit.shader))
- [ ] **배경 셰이더** — 톤을 맞춰야 하면 [ToonShared](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary)도 (Day 06의 "동기화 약속")
- [ ] **인스펙터** — [CharacterToonShaderGUI.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonShaderGUI.cs)에 슬라이더 그리기 (Day 19)
- [ ] **검증** — 기본값에서 화면이 **안 바뀌는지**(중립 값), 켰을 때 원하는 대로 바뀌는지 **수정 전·후 캡처**로 비교

{% hint style="warning" %}
이 셰이더 패키지의 이미지 대부분은 실제로 이런 **수정 전·후 캡처**예요. "고쳤다고 생각한 것"과 "화면이 실제로 바뀐 것"은 다를 수 있어요. 고친 다음에는 꼭 눈으로 비교해 보세요.
{% endhint %}

힌트: `_Time.y`는 게임 시작 후 흐른 초예요(Day 21의 바람). `sin(_Time.y * 속도) * 0.5 + 0.5`는 0~1을 오가요.

## 3. 다음에 공부할 것

| 하고 싶은 것 | 추천 자료 |
|---|---|
| 셰이더 수학을 더 손에 익히기 | [The Book of Shaders (한국어)](https://thebookofshaders.com/?lan=kr) 전체 — 모양 함수, 노이즈, 패턴 |
| Unity 렌더링을 바닥부터 | [Catlike Coding — Rendering 시리즈](https://catlikecoding.com/unity/tutorials/rendering/part-1/) → [Custom SRP](https://catlikecoding.com/unity/tutorials/custom-srp/) |
| URP 내부 함수가 진짜 뭘 하는지 | [URP ShaderLibrary 소스 (GitHub)](https://github.com/Unity-Technologies/Graphics/tree/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary) — `Lighting.hlsl`, `Shadows.hlsl`부터 |
| 다른 툰 셰이더와 비교 | [Unity Toon Shader](https://github.com/Unity-Technologies/com.unity.toonshader) · [lilToon](https://github.com/lilxyzw/lilToon) · [URP Toon Lit 예제 (NiloCat)](https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample) |
| 그래픽스 이론 정리 | [LearnOpenGL](https://learnopengl.com/) Lighting · Advanced Lighting 장 |
| 선형대수를 제대로 | 🎥 [3Blue1Brown — Essence of Linear Algebra](https://www.3blue1brown.com/topics/linear-algebra) 전체 |

## 4. 22일 돌아보기

[ESSENCE.md](essence.md)를 처음부터 끝까지 한 번 읽어 보세요. 22일치 액기스가 한 페이지에 모여 있어요. 각 줄을 읽을 때 **비유가 바로 떠오르면** 졸업이에요. 🎓

## 5. 오늘의 액기스

👉 [ESSENCE.md — Day 22](essence.md#day-22)

---

[← Day 21](day21-background-shaders.md) · [목차](README.md)
