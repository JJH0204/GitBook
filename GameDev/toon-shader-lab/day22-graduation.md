# Day 22. 졸업 — 내가 짠 셰이더 돌아보기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-022-INS |
| 유형 | INS (점검) |
| 목적 | 22일간 만든 `MyToon.shader`를 처음부터 끝까지 점검하고 실제 게임 툰 셰이더와의 차이, 다음 과제를 정리한다 |
| 적용 대상 | Unity 6000.3, URP 17.x. Day 01~21 완료 상태 |
| 소요 시간 | 약 60분 (통독 25분, 비교 20분, 다음 과제 15분) |
| 확인 상태 | 미검증 (원본 내용을 정리한 것이며 이 환경에서 Unity로 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 점검 항목의 URP 함수와 키워드는 Day별 NOTE와 같이 URP 버전에 따라 다를 수 있다. URP 버전 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day21-screen-outline.md](day21-screen-outline.md) | GMD-TSL-021-MP | 이전: 화면 공간 외곽선 |
| [essence.md](essence.md#day-22) | GMD-TSL-023-REF | 액기스 모음 |
| [README.md](README.md) | - | 과정 개요 |
| [toon-shader-study](../toon-shader-study/README.md) | - | 실제 게임 툰 셰이더를 읽는 짝꿍 과정 |

## 2. 점검 항목

### A. frag 통독 (기준: `frag` 12단계를 막힘없이 설명한다)

`Assets/Solutions/Day20/MyToon.shader`([링크](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day20/MyToon.shader))의 `frag` 또는 내 `MyToon.shader`를 위에서부터 읽는다. 모르는 줄은 해당 Day로 돌아간다.

| 순서 | 점검 항목 | 해당 Day | 합격 | 불합격 |
|---|---|---|---|---|
| 1 | 뒷면이면 노멀을 뒤집는다 (`IS_FRONT_VFACE`) | 20 | [ ] | [ ] |
| 2 | 바탕색 = 텍스처 x `Base Color`, `ClipAlpha`로 오린다 | 05, 09 | [ ] | [ ] |
| 3 | `N`을 정규화하고 노멀맵으로 바꾼다 | 04, 17 | [ ] | [ ] |
| 4 | `V` = 시선 방향을 구한다 | 12 | [ ] | [ ] |
| 5 | 메인 라이트와 그림자로 `lightVal` = 하프 램버트 x 그림자를 만든다 | 06, 08 | [ ] | [ ] |
| 6 | `Debug View` 분기를 설명한다 | 04 | [ ] | [ ] |
| 7 | 계단 두 칸으로 그림자 색을 덧칠한다 | 07 | [ ] | [ ] |
| 8 | SSAO 값을 받는다 | 19 | [ ] | [ ] |
| 9 | 색 = 계단 x 빛 색 + 환경광(그림자 쪽 감소) + 바닥값 | 10 | [ ] | [ ] |
| 10 | 보조 조명을 더한다 | 11 | [ ] | [ ] |
| 11 | 림, 스페큘러, MatCap을 키워드로 켜고 끈다 | 12, 15, 16, 18 | [ ] | [ ] |
| 12 | 안개를 섞어 출력한다 | 10 | [ ] | [ ] |

{% hint style="info" %}
NOTE: 셰이더의 뼈대는 세 단계다. 1) `lightVal` 만들기 2) 계단으로 색 정하기 3) 빛나는 요소 더하기. 나머지는 이 위에 얹은 장식이다.
{% endhint %}

### B. 구조 점검 (기준: 모두 일치)

| 번호 | 점검 항목 | 기준값 | 확인 방법 | 합격 |
|---|---|---|---|---|
| 1 | 패스 수 | 5개 (Forward, Outline, ShadowCaster, DepthOnly, DepthNormals) + 화면 셰이더 1개 | `MyToon.shader`의 `Pass` 개수 | [ ] |
| 2 | CBUFFER 위치 | `HLSLINCLUDE` 한 곳 | 패스 안에 CBUFFER 없음 | [ ] |
| 3 | `ClipAlpha` 사용 | 5개 패스 중 색을 출력하는 모든 패스 | 각 패스의 frag 확인 | [ ] |
| 4 | `Cull [_Cull]` | Forward, ShadowCaster, DepthOnly, DepthNormals | Outline만 `Cull Front` | [ ] |
| 5 | SRP Batcher | `compatible` | Shader Inspector | [ ] |

## 3. 실제 게임 셰이더와의 비교

짝꿍 과정 [toon-shader-study](../toon-shader-study/README.md)는 실제 게임 프로젝트에서 쓰는 툰 셰이더를 읽는 자료다.

| 기능 | 이 과정의 셰이더 | 실제 게임 셰이더 | 읽을 곳 |
|---|---|---|---|
| 셀 밴드 1차, 2차 | 있음 | Ramp 텍스처 방식, ILM 맵으로 부위별 그림자 편향 | [Day 07](../toon-shader-study/day07-toon-steps.md) |
| 외곽선 | 픽셀 단위 | 최소 1px 보장, 부위별 두께 마스크, 스무스 노멀 저장 | [Day 12](../toon-shader-study/day12-outline-inverted-hull.md), [13](../toon-shader-study/day13-outline-pixel-width.md) |
| 림 | 프레넬 | 깊이 림(화면 깊이 차로 평평한 면도 처리) | [Day 11](../toon-shader-study/day11-rim-light.md) |
| 얼굴 그림자 | 없음 | SDF 얼굴 그림자(그림자 모양을 텍스처로 제어) | [Day 15](../toon-shader-study/day15-face-sdf.md) |
| 머리카락 | 없음 | 천사 고리(이방성 하이라이트) | [Day 17](../toon-shader-study/day17-highlights.md) |
| 노멀맵 | 메시 탄젠트 | `ddx/ddy`로 탄젠트 없이 계산 | [Day 16](../toon-shader-study/day16-normal-maps-and-derivatives.md) |
| 조명 | 메인 + 보조 | 캐릭터 전용 조명(C#이 전역 값으로 전달), 라이트 레이어 | [Day 09](../toon-shader-study/day09-many-lights.md) |
| 패스 | 5개 | MotionVectors(TAA, 모션 블러), 스텐실(앞머리 너머 눈썹) | [Day 18](../toon-shader-study/day18-passes.md) |
| 키워드 관리 | `shader_feature` | 빌드 스트리퍼, 머티리얼 정리 도구, 전용 인스펙터 | [Day 19](../toon-shader-study/day19-keywords-and-variants.md) |
| 성능 | SRP Batcher | 거리별 품질 페이드, 인스턴싱, GPU Resident Drawer(배경) | [Day 20](../toon-shader-study/day20-performance.md) |

## 4. 다음 과제 (1개 선택)

내 `MyToon.shader`에 직접 추가한다. 정답은 없다. 3절의 "읽을 곳"을 참고한다.

| 난이도 | 과제 | 힌트 |
|---|---|---|
| 쉬움 | 외곽선 끄기 토글 | `[Toggle(_USE_OUTLINE)]`을 만들고 꺼졌을 때 Outline 패스의 `vert`에서 정점을 화면 밖으로 보낸다. 더 나은 방법은 C#의 `material.SetShaderPassEnabled("SRPDefaultUnlit", false)` |
| 쉬움 | 역광 림 | 광원을 등진 테두리만 빛나게 한다 (GMD-TSL-012-MP의 5-E-03) |
| 보통 | 최소 1px 외곽선 | GMD-TSL-014-MP의 외곽선에 마스크가 0이 아니면 최소 1픽셀 규칙을 넣는다 |
| 보통 | 그림자 색 Ramp 텍스처 | 가로 그라데이션 텍스처에서 `lightVal`을 U로 써서 그림자 색을 읽는다 |
| 어려움 | 깊이 림 | GMD-TSL-021-MP의 깊이 텍스처 읽기를 Forward 패스에서 써서, 옆 픽셀이 훨씬 멀면(배경) 테두리를 빛나게 한다 |

### 새 기능 추가 체크리스트

- [ ] `Properties`를 추가하면 `HLSLINCLUDE`의 CBUFFER에도 같은 이름으로 추가했다
- [ ] 키워드로 만들지 숫자 `if`로 만들지 정했다. 키워드면 필요한 모든 패스에 `#pragma`를 추가했다
- [ ] 나눗셈, `normalize`, `smoothstep` 폭에 0 방지 값을 넣었다
- [ ] 모양이나 구멍을 바꾸면 모든 패스에 같은 규칙을 적용했다
- [ ] 기본값에서 화면이 바뀌지 않는지(중립 값) 확인했다
- [ ] 변경 전후 화면을 캡처해 비교했다

## 5. 다음 학습 자료

| 목적 | 자료 |
|---|---|
| 셰이더 수학 | [The Book of Shaders (한국어)](https://thebookofshaders.com/?lan=kr) |
| Unity 렌더링 기초 | [Catlike Coding Rendering](https://catlikecoding.com/unity/tutorials/rendering/part-1/), [Custom SRP](https://catlikecoding.com/unity/tutorials/custom-srp/) |
| URP 함수 소스 | [URP ShaderLibrary](https://github.com/Unity-Technologies/Graphics/tree/master/Packages/com.unity.render-pipelines.universal/ShaderLibrary) (`Lighting.hlsl`, `Shadows.hlsl`부터) |
| 다른 툰 셰이더 | [Unity Toon Shader](https://github.com/Unity-Technologies/com.unity.toonshader), [lilToon](https://github.com/lilxyzw/lilToon), [URP Toon Lit 예제](https://github.com/ColinLeung-NiloCat/UnityURPToonLitShaderExample) |
| 선형대수 | [3Blue1Brown Essence of Linear Algebra](https://www.3blue1brown.com/topics/linear-algebra) |

{% hint style="info" %}
NOTE: 위 외부 저장소의 라이선스와 배포 조건은 각 저장소에서 확인한다. 코드를 가져다 쓰기 전에 라이선스 확인 필요.
{% endhint %}

## 6. 합격 판정

| 번호 | 기준 | 합격 |
|---|---|---|
| 1 | 2절 A의 12개 항목 중 설명하지 못하는 항목이 0개다 | [ ] |
| 2 | 2절 B의 5개 항목이 모두 일치한다 | [ ] |
| 3 | [essence.md](essence.md)를 읽고 각 줄의 코드가 바로 떠오른다 | [ ] |
| 4 | 4절에서 과제 1개를 골랐다 | [ ] |

판정 후 커밋한다: `git commit -am "졸업"`. 내 `Assets/MyToon/MyToon.shader`와 정답 `Assets/Solutions/Day20/MyToon.shader`를 나란히 열어 비교한다(VS Code는 두 파일을 선택하고 우클릭 후 `Compare Selected`).

![완성](../.gitbook/assets/day22-final.png)

## 7. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 Day 22 페이지를 INS 형식으로 재작성. 비유 삭제, 특정 게임 패키지 이름을 일반 표현으로 바꿈, 합격 판정 표 추가 |

[← Day 21](day21-screen-outline.md) · [목차](README.md)
