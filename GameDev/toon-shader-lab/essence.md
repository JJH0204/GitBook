# 액기스 모음 — 22일치 핵심만

> 하루를 마친 뒤 복습용이에요. **비유 → 핵심 → 오늘의 코드 한 줄** 순서예요. 본문은 [README 목차](README.md#커리큘럼)에서.

---

## Day 01

**실험실 열고 첫 셰이더** · [본문](day01-first-shader.md)

🧸 셰이더 = GPU 아르바이트생 수천 명이 똑같이 받는 **작업 지시서**

- 뼈대: `Shader "이름"` → `SubShader`(Tags) → `Pass`(LightMode) → `HLSLPROGRAM … ENDHLSL`
- `#pragma vertex vert` = 점마다 위치 계산, `#pragma fragment frag` = 픽셀마다 색 계산
- `Attributes`(메시→vert), `Varyings`(vert→frag) 택배 상자. `: POSITION`, `: SV_POSITION`, `: SV_Target`은 칸 이름표
- 셰이더 = 레시피, 머티리얼 = 그 레시피로 만든 한 접시
- 오류가 나면 물체가 **마젠타**. Console에서 줄 번호를 읽는다

```hlsl
o.positionCS = TransformObjectToHClip(input.positionOS.xyz);   // vert 의 필수 임무
```

## Day 02

**버텍스 셰이더 — 점 움직이기** · [본문](day02-vertex-shader.md)

🧸 좌표 공간 = **주소 체계**, 행렬 = **주소를 바꿔 주는 기계**

- 오브젝트(OS) → 월드(WS) → 뷰(VS) → 클립(CS). 변수 이름 끝 두 글자가 동네 이름
- `TransformObjectToWorld`, `TransformWorldToHClip`, 노멀은 `TransformObjectToWorldNormal`
- `_Time.y` = 흐른 초, `sin` = -1~1 파도
- **노멀 방향으로 밀기** = 부풀리기 (Day 13 외곽선의 씨앗)
- 어느 공간에서 계산하느냐에 따라 결과가 다르다 (월드 무늬는 세상에, 오브젝트 무늬는 물체에 붙음)

```hlsl
positionWS += normalWS * (sin(_Time.y * 3.0 + positionWS.y * 8.0) * 0.03);
```

## Day 03

**Properties와 CBUFFER** · [본문](day03-properties.md)

🧸 Properties = **재료 목록**(인스펙터 칸), CBUFFER = GPU로 보내는 **값 상자**

- `[꾸밈] _이름 ("보일 이름", 종류) = 기본값`. 종류: `Color`, `Range(a,b)`, `Float`, `2D`
- Properties와 HLSL 변수 이름은 **글자 하나까지 같아야** 연결된다
- 머티리얼 값은 `CBUFFER_START(UnityPerMaterial)` 안에 → **SRP Batcher** 호환
- 셰이더 하나로 머티리얼 여러 개

```hlsl
CBUFFER_START(UnityPerMaterial)  half4 _BaseColor;  CBUFFER_END
```

## Day 04

**택배 상자 늘리기 — 디버그 보기** · [본문](day04-varyings-debug.md)

🧸 Varyings = vert가 frag에게 보내는 **택배 상자**. 도착한 값은 세 꼭짓점 값이 **섞인(보간된)** 값

- `TEXCOORD0`(Attributes) = 메시의 첫 UV, Varyings의 `TEXCOORD1, 2…`는 그냥 칸 번호
- 보간된 노멀은 길이가 줄어든다 → frag 첫머리에서 `normalize`
- 스위즐: `.xyz`, `.rgb`, `.xz`, `.xxx`
- 안 보이는 값을 색으로: 노멀 `N*0.5+0.5`, UV `(u, v, 0)`
- 머티리얼 값으로 갈리는 `if`는 모든 픽셀이 같은 답 → 거의 공짜

```hlsl
if (_DebugView > 0.5h) return half4(N * 0.5h + 0.5h, 1.0h);
```

## Day 05

**텍스처와 알파 클립** · [본문](day05-textures.md)

🧸 UV = **전개도 좌표**(항상 0~1), `clip` = **가위**

- `TEXTURE2D` + `SAMPLER` 선언(CBUFFER 밖), `SAMPLE_TEXTURE2D(tex, sampler, uv)`
- `_BaseMap_ST` = 타일링(xy)·오프셋(zw), `TRANSFORM_TEX`가 적용
- 기본 텍스처 `"white"` = 곱해도 그대로 (안 넣어도 안전)
- `clip(x)`: x < 0이면 픽셀 버림. 기본 Cutoff 0이면 아무것도 안 오림

```hlsl
clip(baseColor.a - _Cutoff);
```

## Day 06

**첫 조명** · [본문](day06-first-light.md)

🧸 빛 = **손전등**, 내적 = **두 화살표가 같은 쪽을 보는 점수**

- N(표면 방향), L(표면 → 해). `GetMainLight()`의 `direction`, `color`
- `dot(N, L)` = cos θ: 정면 1, 직각 0, 반대 -1
- 램버트 `max(0, N·L)`은 뒤쪽이 전부 0, **하프 램버트 `N·L×0.5+0.5`** 는 0~1 고르게 → 툰 입력에 딱
- 이 값 `lightVal`이 툰 셰이더의 심장

```hlsl
half lightVal = dot(N, mainLight.direction) * 0.5h + 0.5h;
```

## Day 07

**툰 계단** · [본문](day07-toon-steps.md)

🧸 실사 = **미끄럼틀**, 툰 = **계단**, `smoothstep` = 계단 모서리를 다듬는 **사포**

- `smoothstep(Border - Blur, Border + Blur, lightVal)`: Border = 위치, Blur = 부드러움
- Blur 0 → 0으로 나누기 → `max(blur, 1e-4)` 바닥
- 같은 계산 두 번 → **함수** `CelStep`
- 그림자 색 = **바탕색 × 틴트**, `lerp`로 1차 → 2차 덧칠

```hlsl
half3 toon = lerp(albedo, albedo * _ShadowColor.rgb, 1.0h - CelStep(lightVal, _ShadowBorder, _ShadowBlur));
```

## Day 08

**그림자 받기** · [본문](day08-receive-shadows.md)

🧸 섀도맵 = **빛이 자기 자리에서 찍은 거리 사진**

- 모양 그림자(N·L)와 드리운 그림자(섀도맵)는 다르다
- `multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE` + `_SHADOWS_SOFT`
- 월드 위치를 frag로 → `TransformWorldToShadowCoord` → `GetMainLight(shadowCoord).shadowAttenuation`
- **툰의 비결**: 그림자를 색이 아니라 `lightVal`에 곱해서 같은 계단 색으로

```hlsl
lightVal *= lerp(1.0h, mainLight.shadowAttenuation, _ReceiveShadow);
```

## Day 09

**그림자 드리우기** · [본문](day09-cast-shadows.md)

🧸 촬영 팀이 늘어난다: 색칠 팀 + **그림자 팀** + **깊이 팀**. 공용 준비물은 한곳에

- `HLSLINCLUDE` = 모든 패스 앞에 붙는 공용 코드 (Core include, 텍스처, **CBUFFER**, 공용 함수)
- ShadowCaster 패스: `ColorMask 0`, `ApplyShadowBias`로 **그림자 여드름** 방지
- DepthOnly 패스: 깊이 지도에 찍히기 (SSAO, 화면 효과가 씀)
- **모든 패스가 같은 가위**(`ClipAlpha`)를 써야 구멍이 그림자에도 뚫린다

```hlsl
o.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirWS));
```

## Day 10

**하늘빛과 안개** · [본문](day10-ambient-fog.md)

🧸 간접광 = **튕겨서 온 빛**, SH = 사방의 하늘빛을 줄인 **날씨 엽서**

- `SampleSH(N)` = 그 방향 하늘빛
- 툰에서는 **그림자 쪽엔 덜** 더해야 밝은 조명에서 계단이 안 사라진다
- `max(color, albedo * _ShadeFloor)` = 너무 까매지지 않게 바닥
- 안개: `multi_compile_fog`, vert `ComputeFogFactor`, frag `MixFog`

```hlsl
color += SampleSH(N) * albedo * _AmbientStrength * (1.0h - shadeMask);
```

## Day 11

**보조 조명과 공구함 파일** · [본문](day11-additional-lights.md)

🧸 해 = 주인공 조명, 포인트·스폿 = **보조 조명**(더하기만)

- 내 `.hlsl` 파일 + `#include "MyToonLighting.hlsl"`, `#ifndef` **중복 방지 스티커**
- `distanceAttenuation`(멀수록 어둡게) × `shadowAttenuation` × 계단
- **인자 3개**짜리 `GetAdditionalLight`라야 보조 조명 그림자가 들어온다
- Forward(물체마다 목록) vs **Forward+**(화면 바둑판 칸마다 목록) → `LIGHT_LOOP_BEGIN/END`

```hlsl
LIGHT_LOOP_BEGIN(count) sum += ShadeAdditionalLight(GetAdditionalLight(lightIndex, positionWS, shadowMask), ...); LIGHT_LOOP_END
```

## Day 12

**림 라이트** · [본문](day12-rim-light.md)

🧸 림 = 역광 사진에서 **가장자리가 반짝이는 것**

- V = `GetWorldSpaceNormalizeViewDir(positionWS)` (표면 → 눈)
- 테두리 = 시선과 직각 → **프레넬 `1 - N·V`** 가 커짐
- 같은 `CelStep`으로 딱 끊긴 림
- 평평한 면은 통째로 빛나는 약점 (실제 셰이더는 깊이 림으로 보완)

```hlsl
half rim = CelStep(1.0h - saturate(dot(N, V)), _RimThreshold, _RimSoftness);
```

## Day 13

**외곽선 ① 뒤집힌 풍선** · [본문](day13-outline-pass.md)

🧸 살짝 큰 **검은 풍선을 뒤집어 씌우기**

- 두 번째 색칠 패스 `LightMode = SRPDefaultUnlit` (URP가 덤으로 그려 줌)
- 노멀 방향으로 부풀리기 + **`Cull Front`**(뒷면만) + 어두운 색
- 각진 큐브는 면마다 노멀이 달라 모서리가 **벌어진다** (실제로는 스무스 노멀을 구워 둠)
- 월드 단위(cm) 폭은 멀어지면 1픽셀보다 얇아져 끊긴다

```hlsl
positionWS += normalWS * (_OutlineWidth * 0.01);
```

## Day 14

**외곽선 ② 픽셀 두께** · [본문](day14-outline-pixels.md)

🧸 4명이 나눠 가질 걸 알면 처음부터 4배를 준다 = **나중에 `w`로 나눌 걸 알고 미리 `w`를 곱한다**

- 클립 좌표 `xy / w` = 화면 좌표(NDC, 폭 2) → 1픽셀 = `2 / 화면크기`
- 오프셋 = 화면 방향 × (픽셀 × 2 / 화면크기) × **w** → 거리와 상관없이 일정한 두께
- 화면 방향은 픽셀 공간에서 정규화 (가로세로 비율), 길이 0이면 건너뛰기
- 크기는 실제 도화지인 `_ScaledScreenParams`로

```hlsl
positionCS.xy += (dirPx / len) * (_OutlineWidth * 2.0 / _ScaledScreenParams.xy) * positionCS.w;
```

## Day 15

**반짝임** · [본문](day15-specular.md)

🧸 스펙큘러 = **거울에 비친 해**

- 하프 벡터 `H = normalize(L + V)`, `dot(N, H)`가 1에 가까울수록 반짝
- `pow(…, 지수)`: 지수가 클수록 작고 날카롭게. `exp2(smoothness × 11)` = 1~2048
- `CelStep(spec, 0.5, step)`으로 **딱 끊긴 만화 하이라이트**
- 그림자 속에서는 꺼야 한다 (`* receive`)

```hlsl
half spec = pow(saturate(dot(N, H)), exp2(_Smoothness * 11.0h));
```

## Day 16

**MatCap** · [본문](day16-matcap.md)

🧸 MatCap = **반사가 그려진 구슬 사진 스티커**

- 노멀을 뷰 공간으로(`UNITY_MATRIX_V`) → `xy × 0.5 + 0.5` = UV
- 공 사진에서 그 자리 색을 더한다. 빛 계산 없음
- 해를 돌려도 안 움직이고, 보는 방향을 따라간다 (스펙큘러와 대비)
- 기본 텍스처 `"black"` = 더해도 그대로

```hlsl
half2 matcapUV = mul((float3x3)UNITY_MATRIX_V, N).xy * 0.5h + 0.5h;
```

## Day 17

**노멀맵** · [본문](day17-normal-map.md)

🧸 노멀맵 = **빛에게만 하는 거짓말**(요철 벽지)

- 색 = 화살표 × 0.5 + 0.5. 평평 = (0.5, 0.5, 1) = 연보라 = `"bump"`
- 탄젠트 공간 T(u 방향), B(v 방향, `cross`), N(바깥) → 3×3 행렬로 월드로
- 메시의 `TANGENT`(w는 거울 UV 부호) 받기, `UnpackNormalScale`로 풀기
- 실루엣(외곽선)은 안 바뀐다 — 빛에게만 하는 거짓말이라서

```hlsl
N = normalize(mul(normalTS, half3x3(T, B, N)));
```

## Day 18

**키워드** · [본문](day18-keywords.md)

🧸 셰이더는 **옵션마다 따로 굽는 빵집**. 옵션 하나에 빵 종류 2배

- `#if defined(KEY)` 안 코드는 꺼지면 **아예 없다** = 비용 0, 대신 배리언트 2ⁿ
- `multi_compile`(엔진이 켬, 전부 빌드) vs `shader_feature`(머티리얼이 켬, 쓰는 것만)
- `_local`(전용), `_fragment`(frag만 갈림 → 절약)
- `[Toggle(KEY)]` 체크박스. **키워드 선언은 패스마다 따로**

```hlsl
#pragma shader_feature_local_fragment _ _USE_RIM
```

## Day 19

**DepthNormals와 SSAO** · [본문](day19-depthnormals-ssao.md)

🧸 SSAO = **방 구석에 쌓인 그늘**

- DepthNormals 패스가 없으면 SSAO에게 우리 물체는 **투명 인간**
- DepthNormals 패스: 색 대신 월드 노멀을 출력
- `_SCREEN_SPACE_OCCLUSION` → `GetScreenSpaceAmbientOcclusion(화면 UV)`
- indirect AO는 하늘빛에, direct AO는 해에

```hlsl
AmbientOcclusionFactor ao = GetScreenSpaceAmbientOcclusion(GetNormalizedScreenSpaceUV(input.positionCS));
```

## Day 20

**양면과 마무리 점검** · [본문](day20-two-sided.md)

🧸 종이 인형 양면 칠하기 — 뒷면에서는 **"앞"이 반대**라고 알려 줘야 한다

- `[Enum(UnityEngine.Rendering.CullMode)] _Cull` + 네 패스에 `Cull [_Cull]` (외곽선은 `Cull Front` 그대로)
- 뒷면이면 노멀 뒤집기: `IS_FRONT_VFACE(faceSign, 1, -1)` — Forward와 DepthNormals 둘 다
- **모든 팀이 같은 대본**: 같은 CBUFFER, 같은 가위, 같은 컬
- SRP Batcher 호환 확인, Frame Debugger로 패스 순서 보기

```hlsl
input.normalWS *= IS_FRONT_VFACE(faceSign, 1.0, -1.0);
```

## Day 21

**화면 공간 외곽선** · [본문](day21-screen-outline.md)

🧸 다 그린 그림을 보고 **경계에 펜으로 선 긋는 화가**

- 풀스크린 셰이더: `Blit.hlsl`의 `Vert` + `_BlitTexture`(지금까지 그린 화면)
- 깊이 경계(`LinearEyeDepth` 차이 ÷ 내 거리) + 노멀 경계(노멀끼리의 거리)
- **Full Screen Pass Renderer Feature**: Fetch Color Buffer, Requirements = Depth + Normal
- 외곽선 패스가 못 그리는 **안쪽 모서리**까지

```hlsl
float edge = saturate(step(_DepthThreshold, depthEdge) + step(_NormalThreshold, normalEdge));
```

## Day 22

**졸업** · [본문](day22-graduation.md)

🧸 40줄 씨앗이 450줄 나무로

- 뼈대 세 줄: ① `lightVal` 만들기 ② 계단으로 색 ③ 빛나는 것들 더하기
- 실제 게임 셰이더에만 있는 것: 얼굴 SDF, 천사 고리, 깊이 림, 스무스 노멀, 캐릭터 조명, 스텐실, 모션 벡터
- 새 기능 체크리스트: Properties ↔ CBUFFER, 모든 패스 규칙, 0 나누기 방지, 중립 기본값, **수정 전·후 화면 비교**

```hlsl
return half4(color, baseColor.a);   // 한 픽셀의 여행 끝
```
