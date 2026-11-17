# Day 22. 졸업 — 한 픽셀의 일생

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-023-DO |
| 유형 | D&O (개념 종합) + 코드 읽기 + 실습 과제 |
| 목적 | 캐릭터 셰이더 `frag` 전체의 처리 순서를 설명하고 기능 추가 시 수정할 곳의 목록을 만든다 |
| 소요 시간 | 약 1시간 (통독 35분, 과제 설계 15분, 다음 학습 계획 10분) |
| 선수 지식 | Day 01–21 |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- [ ] [CharacterToon.shader의 frag](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L285-L666)를 처음부터 끝까지 막힘없이 읽는다
- [ ] 기능을 하나 추가할 때 고쳐야 하는 곳의 목록을 안다
- [ ] 다음에 무엇을 공부할지 정한다

## 1. 정의

프래그먼트 셰이더 `frag`는 픽셀 하나의 최종 색을 계산하는 함수다. 이 소스의 `frag`는 앞면 판정에서 안개 합성까지 순서대로 진행되며, 각 단계는 앞선 Day에서 다룬 개념이다.

비유: 픽셀 하나가 태어나서 화면에 칠해질 때까지의 여행기를 처음부터 끝까지 따라간다.

## 2. 구성 요소

[L285–666](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L285-L666)을 위에서 아래로 읽을 때 쓰는 표다. 모르는 줄이 나오면 해당 Day로 돌아간다.

| 줄 | 여행 단계 | 하는 일 | Day |
|---|---|---|---|
| 285–290 | 태어남 | 앞면/뒷면 확인, 뒷면이면 노멀 뒤집기 | 18 |
| 292 | 옷 입기 | 바탕 텍스처 × 바탕 색 | 05 |
| 297 | 가위 | 오릴 곳이면 여기서 끝 | 05, 18 |
| 302–307 | 방향 찾기 | 노멀 N (노멀맵), 시선 V | 06, 16 |
| 313–319 | 구석 확인 | SSAO 값 | 10 |
| 321–329 | 거리 확인 | 멀면 장식 줄이기 (hqAmount) | 20 |
| 332–337 | 해 찾기 | 메인 라이트 + 그림자 정보 + 레이어 | 08, 09 |
| 340–343 | 지도 펼치기 | ILM 맵 | 05 |
| 347–352 | 조명 고르기 | 캐릭터 조명 or 해 | 06, 09 |
| 355–358 | 손전등 점수 | 하프 램버트 + ILM 편향 → `lightVal` | 06 |
| 363–405 | 얼굴이면 | SDF 지도로 `faceLit` | 15 |
| 408–410 | 드리운 그림자 | `lightVal`에 그림자 곱하기 | 08 |
| 415–420 | 그림자 억제 | 마스크로 그림자 지우기 | 19 |
| 424–448 | 계단 만들기 | 1·2차 밴드 (또는 램프) | 07 |
| 452–455 | 빛 색 | 캐릭터 조명 색 or 해 색 | 09 |
| 461–465 | 하늘빛 | SH 환경광 (그림자 쪽엔 덜) + 바닥 | 10 |
| 469–470 | 추가 캐릭터 조명 | 2순위 이하 더하기 | 09 |
| 475–493 | 보조 조명 | 포인트·스폿 더하기 | 09 |
| 496–520 | 테두리 빛 | 프레넬 림 + 깊이 림 | 11 |
| 524–573 | 구슬 스티커 | MatCap 1, 2 | 17 |
| 581–609 | 반짝임 | 툰 스펙큘러 + 환경 반사 | 17 |
| 612–628 | 천사 고리 | 머리카락 이방성 하이라이트 | 17 |
| 633–639 | 피부 | SSS (사용 중단 예정) | — |
| 640 | 림 합성 | 림 더하기 | 11 |
| 648–655 | 눈 | 시차로 깊이감 | 16 |
| 658–661 | 발광 | Emission 더하기 | — |
| 664–665 | 안개, 끝 | 안개 섞고 출력 | — |

## 3. 동작 원리

흐름의 뼈대는 세 단계다.

| 단계 | 내용 |
|---|---|
| 1 | `lightVal`을 만든다(하프 램버트 + ILM 지도 + 그림자) |
| 2 | 계단으로 바꿔 색을 정한다(1·2차 그림자 색) |
| 3 | 빛나는 것들을 더한다(환경광, 보조 조명, 림, MatCap, 스펙큘러, 발광) |

나머지 단계는 이 세 단계를 보조한다.

## 4. 코드 읽기

1. 위 표의 순서대로 [L285–666](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L285-L666)을 읽는다.
2. 단계마다 입력(어느 변수를 읽는가)과 출력(어느 변수를 바꾸는가)을 한 줄로 적는다.

## 5. 숙제: 기능 하나 추가하기

예제 과제는 그림자 색을 시간에 따라 천천히 바꾸는 `_ShadowHueShift` 슬라이더다(밤낮 연출). 부모 프로젝트(`unity-toonshader`)에서 수행한다. 아래는 기능 하나를 추가할 때 손댈 곳의 체크리스트다.

- [ ] **Properties**: 슬라이더를 추가한다([CharacterToon.shader L5–184](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L5-L184), Day 03)
- [ ] **CBUFFER**: [ToonInput.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L34-L178)에 같은 이름으로 추가한다. 색 패스에만 넣으면 SRP Batcher가 꺼진다(Day 04, 20)
- [ ] **켜고 끄기**: 키워드(`shader_feature_local_fragment`)로 할지 숫자 분기로 할지 정한다(Day 19)
- [ ] **계산**: `frag`의 알맞은 위치에 넣는다. 그림자 색이므로 계단 만들기(L424–448) 근처다(Day 07)
- [ ] **NaN 방지**: 나눗셈, `normalize`, `smoothstep` 폭에 하한을 둔다(Day 06, 07)
- [ ] **다른 패스**: 모양이나 구멍을 바꾸는 기능이면 모든 패스에 넣는다(Day 18). 색만 바꾸면 ForwardToon만 고친다
- [ ] **Unlit 셰이더**: 같은 기능이 필요한지 확인한다([CharacterToon_Unlit.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon_Unlit.shader))
- [ ] **배경 셰이더**: 톤을 맞춰야 하면 [ToonShared](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary)도 고친다(Day 06의 "동기화 약속")
- [ ] **인스펙터**: [CharacterToonShaderGUI.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonShaderGUI.cs)에 슬라이더를 추가한다(Day 19)
- [ ] **검증**: 기본값에서 화면이 바뀌지 않는지(중립 값), 켰을 때 의도대로 바뀌는지를 수정 전·후 캡처로 비교한다

{% hint style="info" %}
NOTE: 이 패키지의 이미지 대부분은 수정 전·후 캡처다. 고쳤다고 생각한 것과 화면에서 실제로 바뀐 것은 다를 수 있으므로 고친 뒤에는 화면으로 비교한다.
{% endhint %}

힌트: `_Time.y`는 게임 시작 후 흐른 초다(Day 21의 바람). `sin(_Time.y * 속도) * 0.5 + 0.5`는 0~1을 오간다.

{% hint style="info" %}
NOTE: SSS 단계(L633–639)는 소스에서 사용 중단 예정으로 표시된 기능이다. 과제에서 건드리지 않는다.
{% endhint %}

## 6. 실습 (최종 점검)

1. 위 표의 각 행을 읽고 대응하는 Day의 비유를 떠올린다. → 결과: 모르는 줄이 남은 행 번호의 목록이 만들어진다.
2. [ESSENCE.md](essence.md)를 처음부터 끝까지 읽는다. → 결과: 22일치 요약을 한 번에 훑고, 각 줄에서 비유가 바로 떠오르면 학습 완료다.
3. 5장의 과제를 수행한다. → 결과: 체크리스트 10개 항목에 대한 변경 목록과 전·후 캡처가 남는다. 되돌리려면 작업 전에 만든 브랜치나 백업으로 복귀한다.

## 7. 참조

- 오늘의 액기스: [ESSENCE.md — Day 22](essence.md#day-22)

| 하고 싶은 것 | 추천 자료 |
|---|---|
| 셰이더 수학을 손에 익히기 | [The Book of Shaders (한국어)](https://thebookofshaders.com/?lan=kr) 전체 |
| Unity 렌더링을 바닥부터 | [Catlike Coding — Rendering 시리즈](https://catlikecoding.com/unity/tutorials/rendering/part-1/), [Custom SRP](https://catlikecoding.com/unity/tutorials/custom-srp/) |
| URP 내부 함수 확인 | [URP ShaderLibrary 소스 (GitHub)](https://github.com/Unity-Technologies/Graphics/tree/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary) — `Lighting.hlsl`, `Shadows.hlsl`부터 |
| 다른 툰 셰이더와 비교 | [Unity Toon Shader](https://github.com/Unity-Technologies/com.unity.toonshader), [lilToon](https://github.com/lilxyzw/lilToon), [URP Toon Lit 예제 (NiloCat)](https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample) |
| 그래픽스 이론 | [LearnOpenGL](https://learnopengl.com/) Lighting, Advanced Lighting 장 |
| 선형대수 | [3Blue1Brown — Essence of Linear Algebra](https://www.3blue1brown.com/topics/linear-algebra) |

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 22일 동안 가장 이해하기 어려웠던 개념과 그것을 이해하게 된 계기를 적는다.
- [ ] 과제로 정한 기능이 `frag`의 어느 단계에 들어가야 하는지, 왜 그런지 적는다.
- [ ] 다음에 공부할 주제 한 가지와 이유를 적는다.

---

[← Day 21](day21-background-shaders.md) · [목차](README.md)
