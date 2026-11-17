# 액기스 모음 — 22일치 핵심만

> 각 Day를 다 읽은 뒤 복습용으로 보세요. **비유 → 핵심 → 코드 한 줄** 순서예요.
> 본문은 [README의 목차](README.md#커리큘럼)에서 찾아가세요.

---

## Day 01

**셰이더가 뭐예요?** · [본문](day01-what-is-a-shader.md)

🧸 셰이더 = GPU 아르바이트생 수천 명이 똑같이 받는 **작업 지시서**

- GPU 공장 순서: 메시 → **버텍스 셰이더**(점 위치) → 래스터라이저(픽셀로 쪼개기) → **프래그먼트 셰이더**(픽셀 색) → 화면
- 우리가 쓰는 건 버텍스·프래그먼트 두 가지. 툰의 마법은 대부분 프래그먼트에서 일어난다
- 툰 셰이딩 = 빛을 **계단**(2~3칸)으로 + **외곽선**
- 셰이더 = 레시피, 머티리얼 = 재료 양을 정한 한 접시
- `.shader` = 지시서 본체, `.hlsl` = 공구함, `Runtime/*.cs` = 실행 중 값 넣기, `Editor/*.cs` = 에디터 도구

```hlsl
half4 frag(...) : SV_TARGET { ... return half4(shaded, baseColor.a); }   // "이 색으로 칠해!"
```

## Day 02

**좌표 공간 여행** · [본문](day02-coordinate-spaces.md)

🧸 좌표 공간 = **주소 체계**, 행렬 = **주소를 바꿔 주는 기계**

- 오브젝트(OS) → 월드(WS) → 뷰(VS) → 클립(CS) → 화면. **변수 이름 끝 두 글자가 동네 이름**
- 행렬 = 이동·회전·크기를 한 번에 하는 기계. 행렬 곱 = 기계 이어 붙이기
- 클립 공간의 `w` = "얼마나 멀리" 메모. GPU가 `xy / w` → 먼 것은 작게 (원근 나눗셈) → NDC는 -1~1
- 노멀은 `TransformObjectToWorldNormal`로 따로 옮긴다 (비균등 스케일 대비)
- 같은 동네 주소끼리 빼면 방향(화살표)

```hlsl
o.positionCS = TransformObjectToHClip(input.positionOS.xyz);   // 버텍스 셰이더의 필수 임무
```

## Day 03

**셰이더 파일의 뼈대** · [본문](day03-shaderlab-skeleton.md)

🧸 `.shader` = **요리책**. Properties = 재료 목록, SubShader = 주방별 레시피, Pass = 조리 단계

- `Properties` = 인스펙터 칸, `CBUFFER` = 같은 값을 GPU에 넘기기 (이름 같아야 함)
- `Tags { "LightMode" = ... }` = "이 패스는 언제 불러 주세요" 이름표
- 렌더 스테이트: `Cull`(앞/뒤/양면), `ZWrite`(깊이 기록), `ZTest`(깊이 비교), `Blend`(섞기), `ColorMask`, `Stencil`
- `[_Cull]`처럼 대괄호로 쓰면 머티리얼에서 값을 정함
- 큐: Background 1000 → Geometry 2000 → Transparent 3000 순서로 그림
- 하늘 셰이더: `dir.y`로 위·아래를 판단해 `lerp`로 세 색을 섞음

```shaderlab
Pass { Name "ForwardToon"  Tags { "LightMode" = "UniversalForwardOnly" }  Cull [_Cull] ... }
```

## Day 04

**HLSL 문법 기초** · [본문](day04-hlsl-basics.md)

🧸 `struct` = **택배 상자**, 시맨틱 = **칸 이름표**, `#include` = **공구함 가져오기**

- `float`(정밀한 자) = 위치·UV·깊이, `half`(대충 자) = 색·노멀·밝기
- 스위즐: `.xyz`, `.rgb`, `.xz`, `.xxx` — 원하는 칸만 원하는 순서로
- `Attributes`(메시→버텍스), `Varyings`(버텍스→프래그먼트). 프래그먼트에 도착한 값은 **보간**된 값 → 노멀은 다시 `normalize`
- `#ifndef/#define` = 중복 방지 스티커, `#if defined(KEY)` = 키워드 꺼지면 코드가 아예 없음
- 내장 함수 10개: `saturate lerp min max normalize dot cross pow step smoothstep clip`
- CBUFFER(UnityPerMaterial)는 한 파일에서만 정의 — 모든 패스가 같은 모양이어야 함

```hlsl
half3 N = normalize(input.normalWS);   // 보간으로 줄어든 길이를 1로
```

## Day 05

**텍스처와 UV** · [본문](day05-textures-and-uv.md)

🧸 UV = **전개도 좌표**(항상 0~1), `clip` = **가위**

- `SAMPLE_TEXTURE2D(텍스처, 샘플러, uv)`. 샘플러 = 읽는 규칙(필터, 반복)
- `_ST` = Tiling(xy)·Offset(zw). `uv * ST.xy + ST.zw`
- **채널 패킹**: ILM 맵 한 장에 R(MatCap 마스크)·G(그림자 편향)·B(스펙 폭)·A(외곽선 억제)
- 중립 값·기본 텍스처(`white`/`black`/`bump`)는 "안 넣으면 효과 없음"이 되도록 고른다
- `clip(x)`: x<0이면 픽셀 버림. 알파 클립 = `a × BaseColor.a − Cutoff`
- 버텍스에서 텍스처 읽기는 `_LOD` (이웃 픽셀이 없어 밉 크기를 직접 지정)

```hlsl
clip(SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).a * _BaseColor.a - _Cutoff);
```

## Day 06

**벡터와 빛** · [본문](day06-vectors-and-light.md)

🧸 내적 = **두 화살표가 같은 쪽을 보는 점수**, 빛 = **손전등**

- N(표면이 보는 방향), L(표면→빛), V(표면→눈). URP의 `light.direction`은 **빛 쪽을 가리킴**
- `normalize` = 길이 1로. 길이 0이면 NaN → `SafeNormalize`, `max(…, 1e-4)`
- `dot(A, B)` = cos θ (길이 1일 때): 같은 방향 1, 직각 0, 반대 −1
- 램버트 `max(0, N·L)`: 뒤쪽이 전부 0. **하프 램버트 `N·L × 0.5 + 0.5`**: 0~1을 고르게 → 툰 입력에 적합
- `lightVal = saturate(halfLambert + (ILM.G − 0.5) × scale)` — 툰 셰이더의 심장 박동

```hlsl
half lightVal = saturate(dot(N, L) * 0.5h + 0.5h + (ilm.g - 0.5h) * _ShadowOffsetScale);
```

## Day 07

**툰 계단 만들기** · [본문](day07-toon-steps.md)

🧸 실사 빛 = **미끄럼틀**, 툰 빛 = **계단**, `smoothstep` = 계단 모서리를 다듬는 **사포**

- `smoothstep(Border − Blur, Border + Blur, lightVal)`: Border = 계단 위치, Blur = 모서리 부드러움
- Blur 0 → 0/0 → NaN. 항상 `max(blur, 1e-4)`
- 그림자 정도 = `1 − smoothstep(...)`. 1차(0.5), 2차(0.25) 두 칸을 `lerp`로 덧칠
- 그림자 색 = **바탕색 × 틴트** (회색 섞기 X). 살짝 푸른 틴트 → 만화 그림자
- `shadeMask` = "얼마나 그림자인가" 기록 (환경광 조절에 씀)
- 대안: Ramp LUT — `lightVal`을 U로 써서 그라데이션 그림에서 색 찾기
- 배경은 같은 식을 `ToonShadeBands()` 함수로 (동기화 약속)

```hlsl
shadedAlbedo = lerp(baseColor.rgb, baseColor.rgb * _ShadowColor.rgb, shadow1);
```

## Day 08

**그림자** · [본문](day08-shadows.md)

🧸 섀도맵 = **빛이 자기 자리에서 찍은 거리 사진**

- 모양 그림자(N·L) vs 드리운 그림자(섀도맵)
- 내 거리 > 섀도맵 거리 → 누가 가림 → 그림자
- ShadowCaster 패스: `ColorMask 0`(거리만), `ApplyShadowBias`로 **그림자 여드름** 방지
- `GetMainLight(shadowCoord).shadowAttenuation`: 1 = 빛, 0 = 그림자
- 툰의 비결: 그림자 결과를 **`lightVal`에 곱해** 같은 계단 색으로 칠함
- 하이라이트에도 `rcvShadow`를 곱해야 그림자 속에서 안 빛남 (B6)

```hlsl
lightVal *= lerp(1.0h, mainLight.shadowAttenuation, _ReceiveShadowStrength);
```

## Day 09

**여러 개의 빛** · [본문](day09-many-lights.md)

🧸 해 = 주인공 조명, 포인트·스폿 = **보조 조명**, 캐릭터 라이트 = **인물 사진 조명**

- 보조 조명은 `distanceAttenuation × shadowAttenuation × 계단` 을 **더하기만** (그림자 쪽을 어둡게 안 함)
- Forward = 물체마다 조명 목록, **Forward+ = 화면 바둑판 칸마다** 조명 목록 → `LIGHT_LOOP_BEGIN/END`
- Forward+에서 추가 Directional은 바둑판 밖 → 앞에서 따로 반복
- `GetAdditionalLight` 인자 2개는 그림자 1 고정 → **3개짜리** 써야 그림자 (A5)
- 라이트 레이어: `IsMatchingLightLayer(light.layerMask, GetMeshRenderingLayer())` (A7)
- 값 넣기 3종: 머티리얼(개인 메모) / `Shader.SetGlobal…`(전체 방송) / MPB(포스트잇)

```hlsl
LIGHT_LOOP_BEGIN(addCount) addSum += ShadeAdditionalToon(GetAdditionalLight(lightIndex, posWS, shadowMask), ...); LIGHT_LOOP_END
```

## Day 10

**환경광, GI, SSAO** · [본문](day10-ambient-gi-ssao.md)

🧸 간접광 = **튕겨 온 빛**, SH = **날씨 요약 엽서**, 라이트맵 = **구워 둔 빛 스티커**, SSAO = **구석 그늘**

- 캐릭터: `SampleSH(N)`을 **그림자 쪽엔 덜** 더함(`× (1 − shadeMask)`) → 밝은 조명에서 셀 대비 유지
- `_ShadeFloor`: 그림자가 너무 까매지지 않게 바닥
- 배경: GI 밝기만 뽑아(휘도 0.2126/0.7152/0.0722) **`ToonPosterize`로 계단화**, 색조는 유지
- SSAO: 간접광엔 indirect, 직접광엔 direct AO. `_AOStrength`로 다이얼
- 배경도 SSAO 키워드가 있어야 반응 (B2)

```hlsl
shaded += SampleSH(N) * _AmbientStrength * baseColor.rgb * (1.0h - shadeMask) * aoIndirect;
```

## Day 11

**림 라이트** · [본문](day11-rim-light.md)

🧸 림 = 역광 사진에서 **가장자리가 반짝이는 것**

- 테두리 = 시선과 직각인 곳 → **프레넬 `1 − N·V`** 가 커짐
- `smoothstep(threshold, threshold + softness, fresnel)` (softness도 `max(…,1e-4)`, C4)
- 깊이 림: 화면에서 노멀 방향으로 N픽셀 옆 깊이를 보고 **훨씬 멀면** 실루엣 → 거리와 무관한 두께
- 깊이 값은 비선형 → `LinearEyeDepth`로 진짜 거리
- 렌더 스케일 함정: 그리는 도화지는 `_ScaledScreenParams`. 화면 UV는 `GetNormalizedScreenSpaceUV` (A2)

```hlsl
half rim = smoothstep(_RimThreshold, _RimThreshold + max(_RimSoftness, 1e-4h), 1.0h - saturate(dot(N, V)));
```

## Day 12

**외곽선 ① 인버티드 헐** · [본문](day12-outline-inverted-hull.md)

🧸 살짝 큰 **검은 풍선을 뒤집어 씌우기**

- Outline 패스: 노멀 방향으로 부풀림 + **`Cull Front`**(뒷면만) + 검게. `LightMode = SRPDefaultUnlit`
- 각진 모델은 면 노멀로 밀면 모서리가 벌어짐 → **스무스(평균) 노멀**을 **TANGENT 칸**에 구워 둠
- TANGENT가 노멀과 거의 직각(dot < 0.02)이면 "안 구운 모델" → 원래 노멀 (C5: 0.3은 너무 높았음)
- 폭 조절: 마스크 R, ILM.A, 정점 색, 근접 축소(FixWidth), 원거리 페이드 — lilToon 방식
- 대가: TANGENT를 빼앗겨 캐릭터 노멀맵은 미분 방식으로 (Day 16)

```hlsl
Cull Front   // 부푼 껍질의 뒷면만 → 몸 뒤로 삐져나온 테두리만 보임
```

## Day 13

**외곽선 ② 픽셀 두께** · [본문](day13-outline-pixel-width.md)

🧸 아주 가는 실은 멀리서 **반짝반짝 깜빡임** → 두께를 "보이는 굵기"로 정한다

- 월드 폭은 거리에 반비례 → 6m에서 0.18px → 서브픽셀이 프레임마다 깜빡 (자글거림)
- **나중에 `w`로 나눠질 걸 알고 미리 `w`를 곱한다** → 화면 오프셋이 거리와 무관
- NDC 폭 2 → 1px = `2 / 화면크기`. 클립 오프셋 = `방향 × px × 2/화면 × w`
- 최소 1px 클램프 + **게이트**(마스크·폭 0인 곳은 되살리지 않음)
- Depth Priming = `ZTest Equal` 강제 → 몸보다 뒤에 있는 외곽선 전부 탈락 → 인스펙터 경고 (C2)

```hlsl
posCS.xy += dirPix * (targetPix * 2.0 / _ScaledScreenParams.xy) * w;
```

## Day 14

**외곽선 ③ 화면 공간** · [본문](day14-screen-space-outline.md)

🧸 다 그린 그림을 보고 **깊이가 확 바뀌는 곳에 펜으로 선 긋기**

- 인버티드 헐(물체별, 실루엣) vs 화면 공간(화면 단위, 안쪽 선까지)
- 깊이 엣지: 2×2 대각 비교(로버츠 크로스), 멀면 기준을 넉넉하게(`÷ 깊이`, B3)
- 노멀 엣지: 노멀끼리의 거리. 노멀 텍스처 w 칸 = 물체별 "선 긋지 마"
- Renderer Feature = URP 확장 카드. `Create()`에서 이전 머티리얼 정리 (C6 누수)
- RenderGraph = 요리 순서표. 블릿 = 복사하며 필터 씌우기. 읽는 텍스처는 `UseTexture`로 선언 (B11)

```hlsl
float edge = saturate(step(_OutlineSSDepthThreshold, depthEdge) + step(_OutlineSSNormalThreshold, normalEdge));
```

## Day 15

**얼굴 SDF 그림자** · [본문](day15-face-sdf.md)

🧸 SDF 텍스처 = **밀물 지도**. 물높이(빛 각도)가 오르면 낮은 곳부터 잠김

- 얼굴은 N·L 그림자가 지저분 → 그림자 모양을 그림으로 미리 그려 둠
- 빛·얼굴 방향을 **XZ로 눌러** `FdotL`(앞뒤), `RdotL`(좌우) 두 내적
- 좌우는 UV를 **뒤집어** 한 장으로 해결, `coverage = (1 − FdotL) / 2`
- `faceLit = saturate((sdf − coverage) / width + 0.5)`, 폭에 `fwidth` → 항상 매끈한 경계 (smoothstep보다 선형)
- 얼굴 방향은 캐릭터마다 다름 → 글로벌 X, **MaterialPropertyBlock** (A3). 대가: SRP Batcher에서 빠짐

```hlsl
faceLit = saturate((sdf - coverage) / max(_SDFSoftness * 2.0h + fwidth(sdf) * 1.5h, 1e-4h) + 0.5h);
```

## Day 16

**노멀맵과 미분** · [본문](day16-normal-maps-and-derivatives.md)

🧸 노멀맵 = **빛에게만 하는 거짓말**, `ddx/ddy` = **옆자리 친구 답안 보기**

- 노멀맵 색 = 화살표 × 0.5 + 0.5. 평평 = (0.5, 0.5, 1) = 연보라
- 탄젠트 공간 T(u 방향)·B(v 방향)·N(바깥) → 행렬로 월드로
- GPU는 **2×2 쿼드**로 칠함 → `ddx`(가로 차이), `ddy`(세로 차이), `fwidth = |ddx| + |ddy|`
- 캐릭터는 TANGENT가 없어서 **위치·UV의 미분으로 T, B를 즉석 계산** (Schüler 방식)
- 절대 크기 기준은 근거리에서 틀림 → 방향만 쓰고 0 나눗셈만 막기
- 픽셀마다 답이 다른 `if` 안에서는 미분 금지

```hlsl
float3 dp1 = ddx(positionWS); float2 duv1 = ddx(uv);   // "옆으로 한 칸 가면 위치·UV가 이만큼 변한다"
```

## Day 17

**반짝임 3종** · [본문](day17-highlights.md)

🧸 스펙큘러 = **거울에 비친 해**, 천사 고리 = **결 따라 흐르는 빛 띠**, MatCap = **반사 구슬 스티커**

- 블린-퐁: `H = normalize(L + V)`, `pow(N·H, 지수)` — 지수가 클수록 작고 날카롭게
- `exp2(smoothness × 11)` = 1~2048. 결과를 `smoothstep`으로 **딱 끊긴 하이라이트**
- 천사 고리(이방성): `1 − |T·H|` — 결과 H가 **수직**일수록 밝음. `cos/sin`으로 결 방향 회전
- MatCap: 뷰 공간 노멀 `xy × 0.5 + 0.5` = UV → 공 사진에서 색 읽기
- 마스크는 토글이 켜졌을 때만 읽기 (C7, 숫자 분기)

```hlsl
float2 matcapUV = mul((float3x3)UNITY_MATRIX_V, N).xy * 0.5 + 0.5;
```

## Day 18

**패스 총정리** · [본문](day18-passes.md)

🧸 캐릭터 하나를 찍는 **촬영 팀 여섯**. 모든 팀이 **같은 대본**을 따라야 함

- 색 / 외곽선 / 그림자(거리) / 깊이 / 깊이+노멀 / 모션 벡터
- **모든 패스가 같은 곳을 자른다** (`ClipToonSurface`, A4) — 아니면 유령 그림자·외곽선·깊이
- **모든 패스가 같은 Cull**, 뒷면은 노멀 뒤집기 (`IS_FRONT_VFACE`, A6·B3)
- `UsePass`로 패스 빌려 쓰기 → 복사본 버그 방지
- 모션 벡터 = 지금 위치 − 지난 프레임 위치 (흔들림 없는 행렬로). TAA·모션 블러가 씀 (C1)
- 스텐실 = 도장판. 눈썹이 찍고 앞머리가 피함 → 앞머리 너머 눈썹

```hlsl
input.normalWS *= IS_FRONT_VFACE(faceSign, 1.0, -1.0);   // 뒷면이면 노멀 반대로
```

## Day 19

**키워드와 배리언트** · [본문](day19-keywords-and-variants.md)

🧸 셰이더는 **옵션마다 따로 굽는 빵집**. 옵션 하나에 빵 종류 2배

- `#if`로 갈린 코드 = 다른 셰이더(배리언트). 꺼진 기능은 비용 0, 대신 사본 2ⁿ
- `multi_compile` = 매일 굽는 빵(엔진이 켬, 전부 빌드), `shader_feature` = 주문받은 것만(머티리얼이 씀)
- `_local`(전용 키워드), `_fragment`(프래그먼트만 갈림 → 사본 절약)
- 가벼운 옵션은 **머티리얼 숫자 분기** — 한 물체의 픽셀이 다 같은 답 → 거의 공짜
- 스트리퍼 = 말 안 되는 조합 버리기. 단, 머티리얼을 **먼저 정리**(Sanitizer)해야 유일한 배리언트를 안 잃음
- 외곽선 끈 머티리얼은 `SetShaderPassEnabled`로 패스 자체를 끔 (B4)

```hlsl
#pragma shader_feature_local_fragment _ _ALPHATEST_ON
```

## Day 20

**성능** · [본문](day20-performance.md)

🧸 드로우콜 = **택배 발송 건수**. 묶어 보내고, 재료표는 창고에 미리

- SRP Batcher = 재료표를 GPU에 미리 → 번호만 부름. **모든 패스의 CBUFFER 모양이 같아야**
- MaterialPropertyBlock = 포스트잇 → 배처에서 빠짐. 대가를 알고 고르기
- GPU 인스턴싱: `multi_compile_instancing` + `UNITY_VERTEX_INPUT_INSTANCE_ID` + `UNITY_SETUP_INSTANCE_ID`
- GPU Resident Drawer는 **DOTS 인스턴싱 배리언트**가 있어야 셰이더를 씀 (B1: 20 → 40)
- LOD 크로스페이드 = 점점이 바꿔치기, 모든 패스에서
- 거리 품질 페이드: 물체 원점 거리로 비싼 장식 생략·페이드

```hlsl
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
```

## Day 21

**배경 셰이더** · [본문](day21-background-shaders.md)

🧸 스플랫맵 = **물감 네 통을 어디에 얼마나 칠할지 적은 지도**

- 배경은 `ToonShared` 함수로 캐릭터와 같은 톤
- 트라이플래너 = 세 방향 프로젝터. 월드 위치가 UV, `pow(|N|, sharp)`로 섞기
- 정점 색으로 이끼·눈 레이어 블렌딩
- 바람: `sin` 파도 여러 개, 밑동 고정(로컬 y), 위치마다 박자 다르게. **모든 패스**에서
- 지형: Control RGBA로 4레이어 무게 평균. Draw Instanced는 **높이 지도에서 정점 복원** (B12)
- Meta 패스 = 라이트맵 베이커에게 색 알려 주기, `Dependency "BaseMapShader"` 없으면 베이크에서 빠짐

```hlsl
return (a0 * ctrl.r + a1 * ctrl.g + a2 * ctrl.b + a3 * ctrl.a) / wsum;
```

## Day 22

**졸업 — 한 픽셀의 일생** · [본문](day22-graduation.md)

🧸 frag 380줄 = 픽셀 하나의 **여행기**

- 뼈대 세 줄: ① `lightVal` 만들기 ② 계단으로 색 정하기 ③ 빛나는 것들 더하기
- 기능 추가 체크리스트: Properties → CBUFFER(한 파일) → 키워드 or 숫자 → 계산 → NaN 방지 → 다른 패스 → Unlit·배경 → 인스펙터 → **수정 전·후 캡처로 검증**
- 다음 공부: The Book of Shaders, Catlike Coding, URP ShaderLibrary 소스, 다른 툰 셰이더 비교

```hlsl
shaded = MixFog(shaded, input.fogFactor);
return half4(shaded, baseColor.a);   // 여행 끝
```
