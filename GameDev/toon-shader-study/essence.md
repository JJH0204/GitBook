# 액기스 모음 — 22일치 핵심만

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-024-REF |
| 유형 | REF (요약 표·핵심 목록) |
| 목적 | Day 01~22의 핵심을 "비유 → 핵심 → 코드 한 줄" 순서로 모아 복습에 쓴다 |
| 사용 시점 | 각 Day를 읽은 뒤 복습할 때 |
| 확인 상태 | 미검증 (본문과 소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

본문은 [README의 커리큘럼](README.md#커리큘럼)에서 찾는다. 각 절의 `## Day NN` 제목은 본문의 `essence.md#day-NN` 링크가 가리키므로 바꾸지 않는다.

{% hint style="info" %}
NOTE: URP 기능 이름(Forward+, Render Graph, GPU Resident Drawer 등)은 Unity·URP 버전에 따라 유무와 이름이 다르다. 각 항목의 버전 조건은 해당 Day 본문에 적혀 있다.
{% endhint %}

---

## Day 01

**셰이더란 무엇인가** · [본문](day01-what-is-a-shader.md)

비유: 셰이더는 GPU의 수많은 작업자가 똑같이 받는 작업 지시서다.

- GPU 처리 순서: 메시 → **버텍스 셰이더**(점 위치) → 래스터라이저(픽셀로 분할) → **프래그먼트 셰이더**(픽셀 색) → 화면.
- 이 패키지가 쓰는 단계는 버텍스·프래그먼트다. 툰 표현의 대부분은 프래그먼트에서 계산한다.
- 툰 셰이딩 = 빛을 2~3단 계단으로 나누는 음영 + 외곽선.
- 셰이더는 레시피, 머티리얼은 프로퍼티 값을 정한 인스턴스다.
- 파일 구분: `.shader`는 본체, `.hlsl`은 공용 함수 모음, `Runtime/*.cs`는 실행 중 값 전달, `Editor/*.cs`는 에디터 도구다.

```hlsl
half4 frag(...) : SV_TARGET { ... return half4(shaded, baseColor.a); }   // 이 픽셀의 최종 색을 반환
```

## Day 02

**좌표 공간** · [본문](day02-coordinate-spaces.md)

비유: 좌표 공간은 주소 체계이고 행렬은 주소를 바꾸는 기계다.

- 변환 순서: 오브젝트(OS) → 월드(WS) → 뷰(VS) → 클립(CS) → NDC → 화면. 변수 이름 끝 두 글자가 공간을 나타낸다.
- 행렬은 이동·회전·크기를 한 번에 적용한다. 행렬 곱은 변환을 이어 붙인다. 열벡터 관례에서 합성 순서는 `P × V × M`이다.
- 클립 공간의 `w`는 거리 정보다. GPU가 `xy / w`로 나눠(원근 나눗셈) 먼 물체를 작게 만든다. NDC의 x, y 범위는 -1~1이다.
- 노멀은 `TransformObjectToWorldNormal`로 따로 변환한다(비균등 스케일 대응).
- 같은 공간의 위치끼리 빼면 방향 벡터가 나온다.

```hlsl
o.positionCS = TransformObjectToHClip(input.positionOS.xyz);   // 버텍스 셰이더의 필수 출력
```

## Day 03

**셰이더 파일의 뼈대** · [본문](day03-shaderlab-skeleton.md)

비유: `.shader`는 요리책이다. Properties는 재료 목록, SubShader는 환경별 레시피, Pass는 조리 단계다.

- `Properties`는 인스펙터 칸이고 `CBUFFER`는 같은 값을 GPU로 넘기는 상수 버퍼다. 두 이름은 같아야 한다.
- `Tags { "LightMode" = ... }`는 이 패스를 언제 호출할지 정하는 태그다.
- 렌더 스테이트: `Cull`(앞/뒤/양면), `ZWrite`(깊이 기록), `ZTest`(깊이 비교), `Blend`(혼합), `ColorMask`, `Stencil`.
- `[_Cull]`처럼 대괄호로 쓰면 머티리얼 값으로 정한다.
- 렌더 큐: Background 1000 → Geometry 2000 → Transparent 3000 순으로 그린다.
- 하늘 셰이더는 `dir.y`로 위·아래를 판단해 `lerp`로 세 색을 섞는다.

```shaderlab
Pass { Name "ForwardToon"  Tags { "LightMode" = "UniversalForwardOnly" }  Cull [_Cull] ... }
```

## Day 04

**HLSL 문법 기초** · [본문](day04-hlsl-basics.md)

비유: `struct`는 택배 상자, 시맨틱은 칸 이름표, `#include`는 공구함이다.

- `float`은 위치·UV·깊이처럼 정밀도가 필요한 값, `half`는 색·노멀·밝기에 쓴다.
- 스위즐: `.xyz`, `.rgb`, `.xz`, `.xxx`로 원하는 성분만 원하는 순서로 꺼낸다.
- `Attributes`는 메시 → 버텍스, `Varyings`는 버텍스 → 프래그먼트 입력이다. 프래그먼트에 도착한 값은 보간된 값이므로 노멀은 다시 `normalize`한다.
- `#ifndef/#define`은 중복 포함 방지, `#if defined(KEY)`는 키워드가 꺼지면 코드가 컴파일에서 빠진다.
- 내장 함수 10개: `saturate lerp min max normalize dot cross pow step smoothstep clip`.
- `CBUFFER(UnityPerMaterial)`는 한 파일에서만 정의한다. 모든 패스의 모양이 같아야 한다.

```hlsl
half3 N = normalize(input.normalWS);   // 보간으로 줄어든 길이를 1로 복원
```

## Day 05

**텍스처와 UV** · [본문](day05-textures-and-uv.md)

비유: UV는 전개도 좌표(0~1)이고 `clip`은 가위다.

- `SAMPLE_TEXTURE2D(텍스처, 샘플러, uv)`. 샘플러는 필터·반복 방식을 정한다.
- `_ST`는 Tiling(xy)·Offset(zw)이다. `uv * ST.xy + ST.zw`로 적용한다.
- 채널 패킹: ILM 맵 한 장에 R(MatCap 마스크), G(그림자 편향), B(스펙 폭), A(외곽선 억제)를 담는다.
- 기본 텍스처(`white`/`black`/`bump`)는 지정하지 않아도 효과가 없도록 중립 값으로 고른다.
- `clip(x)`는 x가 0보다 작으면 픽셀을 버린다. 알파 클립은 `a × BaseColor.a − Cutoff`다.
- 버텍스 셰이더에서는 이웃 픽셀이 없어 밉 레벨을 직접 지정하는 `_LOD` 샘플링을 쓴다.

```hlsl
clip(SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv).a * _BaseColor.a - _Cutoff);
```

## Day 06

**벡터와 빛** · [본문](day06-vectors-and-light.md)

비유: 내적은 두 화살표가 같은 쪽을 보는 정도이고 빛은 손전등이다.

- N은 표면이 향하는 방향, L은 표면에서 빛으로 향하는 방향, V는 표면에서 눈으로 향하는 방향이다. URP의 `light.direction`은 빛 쪽을 가리킨다.
- `normalize`는 길이를 1로 만든다. 길이 0이면 NaN이 나오므로 `SafeNormalize` 또는 `max(…, 1e-4)`로 막는다.
- `dot(A, B)`는 길이가 1일 때 cos θ다. 같은 방향 1, 직각 0, 반대 -1이다.
- 램버트 `max(0, N·L)`은 뒷면이 모두 0이다. 하프 램버트 `N·L × 0.5 + 0.5`는 0~1로 고르게 퍼져 툰 입력에 적합하다.
- `lightVal = saturate(halfLambert + (ILM.G − 0.5) × scale)`가 툰 음영의 입력값이다.

```hlsl
half lightVal = saturate(dot(N, L) * 0.5h + 0.5h + (ilm.g - 0.5h) * _ShadowOffsetScale);
```

## Day 07

**툰 계단 만들기** · [본문](day07-toon-steps.md)

비유: 실사 빛은 미끄럼틀, 툰 빛은 계단이다. `smoothstep`은 계단 모서리를 다듬는다.

- `smoothstep(Border − Blur, Border + Blur, lightVal)`에서 Border는 계단 위치, Blur는 모서리 부드러움이다.
- Blur가 0이면 `smoothstep`의 입력 두 값이 같아져 0으로 나누게 된다(NaN). 항상 `max(blur, 1e-4)`를 쓴다.
- 그림자 정도 = `1 − smoothstep(...)`. 1차(0.5)와 2차(0.25) 두 단을 `lerp`로 덧칠한다.
- 그림자 색은 바탕색 × 틴트다(회색 혼합이 아님). 약한 푸른 틴트가 만화풍 그림자를 만든다.
- `shadeMask`는 그림자 정도를 기록해 환경광 조절에 쓴다.
- 대안은 Ramp LUT다. `lightVal`을 U 좌표로 써 그라데이션 텍스처에서 색을 읽는다.
- 배경은 같은 식을 `ToonShadeBands()` 함수로 가진다(동기화 약속).

```hlsl
shadedAlbedo = lerp(baseColor.rgb, baseColor.rgb * _ShadowColor.rgb, shadow1);
```

## Day 08

**그림자** · [본문](day08-shadows.md)

비유: 섀도맵은 빛의 위치에서 찍은 거리 사진이다.

- 모양 그림자(N·L)와 드리운 그림자(섀도맵)는 다르다.
- 판정: 내 거리가 섀도맵 거리보다 멀면 가려진 것이므로 그림자다.
- ShadowCaster 패스는 `ColorMask 0`으로 깊이만 기록하고 `ApplyShadowBias`로 그림자 아크네(shadow acne)를 막는다.
- `GetMainLight(shadowCoord).shadowAttenuation`은 1이면 빛, 0이면 그림자다.
- 툰 처리: 그림자 결과를 `lightVal`에 곱해 같은 계단 색으로 칠한다.
- 하이라이트에도 `rcvShadow`를 곱해야 그림자 속에서 빛나지 않는다(카드 B6).

```hlsl
lightVal *= lerp(1.0h, mainLight.shadowAttenuation, _ReceiveShadowStrength);
```

## Day 09

**여러 개의 빛** · [본문](day09-many-lights.md)

비유: 주 광원은 주인공 조명, 포인트·스폿은 보조 조명, 캐릭터 라이트는 인물 사진용 조명이다.

- 보조 조명은 `distanceAttenuation × shadowAttenuation × 계단` 값을 더하기만 한다(그림자 쪽을 어둡게 하지 않는다).
- Forward는 오브젝트별 조명 목록, Forward+는 화면 타일별 조명 목록을 쓴다. 루프는 `LIGHT_LOOP_BEGIN/END`다.
- Forward+에서 추가 Directional 라이트는 타일 목록에 들지 않아 앞에서 따로 반복한다.
- `GetAdditionalLight`의 2인자 버전은 그림자가 1로 고정된다. 그림자를 받으려면 3인자 버전을 쓴다(카드 A5).
- 라이트 레이어: `IsMatchingLightLayer(light.layerMask, GetMeshRenderingLayer())`(카드 A7).
- 셰이더에 값을 넣는 방법 3종: 머티리얼(개별), `Shader.SetGlobal…`(전역), MaterialPropertyBlock(렌더러별).

```hlsl
LIGHT_LOOP_BEGIN(addCount) addSum += ShadeAdditionalToon(GetAdditionalLight(lightIndex, posWS, shadowMask), ...); LIGHT_LOOP_END
```

## Day 10

**환경광, GI, SSAO** · [본문](day10-ambient-gi-ssao.md)

비유: 간접광은 반사되어 온 빛, SH는 주변광 요약, 라이트맵은 구워 둔 빛, SSAO는 구석의 그늘이다.

- 캐릭터: `SampleSH(N)`을 그림자 쪽에는 덜 더한다(`× (1 − shadeMask)`). 밝은 조명에서도 셀 대비가 유지된다.
- `_ShadeFloor`는 그림자가 지나치게 어두워지지 않게 하는 하한이다.
- 배경: GI의 밝기만 추출하고(휘도 0.2126/0.7152/0.0722) `ToonPosterize`로 계단화한다. 색조는 유지한다.
- SSAO: 간접광에는 indirect AO, 직접광에는 direct AO를 적용한다. `_AOStrength`로 세기를 조절한다.
- 배경도 SSAO 키워드가 있어야 AO에 반응한다(카드 B2).

```hlsl
shaded += SampleSH(N) * _AmbientStrength * baseColor.rgb * (1.0h - shadeMask) * aoIndirect;
```

## Day 11

**림 라이트** · [본문](day11-rim-light.md)

비유: 림은 역광 사진에서 가장자리가 빛나는 현상이다.

- 테두리는 시선과 직각인 곳이다. 프레넬 항 `1 − N·V`가 커진다.
- `smoothstep(threshold, threshold + softness, fresnel)`. softness도 `max(…, 1e-4)`로 막는다(카드 C4).
- 깊이 림: 화면에서 노멀 방향으로 N픽셀 옆의 깊이를 읽어 훨씬 멀면 실루엣으로 본다. 두께가 거리와 무관하다.
- 깊이 버퍼 값은 비선형이므로 `LinearEyeDepth`로 실제 거리로 바꾼다.
- 렌더 스케일 주의: 실제 렌더 타깃 크기는 `_ScaledScreenParams`다. 화면 UV는 `GetNormalizedScreenSpaceUV`로 구한다(카드 A2).

```hlsl
half rim = smoothstep(_RimThreshold, _RimThreshold + max(_RimSoftness, 1e-4h), 1.0h - saturate(dot(N, V)));
```

## Day 12

**외곽선 ① 인버티드 헐** · [본문](day12-outline-inverted-hull.md)

비유: 조금 큰 검은 껍질을 뒤집어 씌운다.

- Outline 패스: 노멀 방향으로 부풀리고 `Cull Front`(뒷면만 그림)로 검게 칠한다. `LightMode = SRPDefaultUnlit`이다.
- 각진 모델은 면 노멀로 밀면 모서리가 벌어진다. 평균(스무스) 노멀을 TANGENT 채널에 구워 쓴다.
- TANGENT가 노멀과 거의 직각(dot < 0.02)이면 굽지 않은 모델로 보고 원래 노멀을 쓴다(카드 C5: 0.3은 너무 높았다).
- 폭 조절: 마스크 R, ILM.A, 정점 색, 근접 축소(FixWidth), 원거리 페이드. lilToon 방식을 참고했다.
- 대가: TANGENT를 쓰므로 캐릭터 노멀맵은 미분 방식으로 처리한다(Day 16).

```hlsl
Cull Front   // 부푼 껍질의 뒷면만 그려 몸 뒤로 삐져나온 테두리만 보인다
```

## Day 13

**외곽선 ② 픽셀 두께** · [본문](day13-outline-pixel-width.md)

비유: 매우 가는 선은 멀리서 깜빡이므로 두께를 화면에서 보이는 굵기로 정한다.

- 월드 단위 폭은 거리에 반비례해 6m에서 0.18px이 되고, 서브픽셀 폭이 프레임마다 깜빡인다.
- 나중에 `w`로 나눠지므로 미리 `w`를 곱한다. 화면 오프셋이 거리와 무관해진다.
- NDC 폭은 2이므로 1px = `2 / 화면 크기`다. 클립 오프셋 = `방향 × px × 2 / 화면 × w`다.
- 최소 1px 클램프를 쓰되 게이트(마스크·폭 0인 곳은 되살리지 않음)를 둔다.
- Depth Priming은 `ZTest Equal`을 강제해 몸보다 뒤에 있는 외곽선이 모두 탈락한다. 인스펙터에서 경고한다(카드 C2).

```hlsl
posCS.xy += dirPix * (targetPix * 2.0 / _ScaledScreenParams.xy) * w;
```

## Day 14

**외곽선 ③ 화면 공간** · [본문](day14-screen-space-outline.md)

비유: 다 그린 화면에서 깊이가 급변하는 곳에 선을 긋는다.

- 인버티드 헐은 오브젝트별 실루엣이고, 화면 공간 방식은 화면 단위이며 안쪽 선까지 잡는다.
- 깊이 엣지: 중심과 이웃 세 칸의 깊이 차이 합(단순 전방 차분). 멀수록 기준을 넓힌다(`÷ 깊이`, 카드 B3).
- 노멀 엣지: 노멀 사이의 거리. 노멀 텍스처의 w 채널이 오브젝트별 "선 긋지 않음" 표시다.
- Renderer Feature는 URP 확장 지점이다. `Create()`에서 이전 머티리얼을 정리한다(카드 C6, 누수).
- Render Graph는 패스 실행 순서와 리소스 의존을 선언하는 구조다. 블릿은 복사하면서 필터를 적용한다. 읽는 텍스처는 `UseTexture`로 선언한다(카드 B11).

```hlsl
float edge = saturate(step(_OutlineSSDepthThreshold, depthEdge) + step(_OutlineSSNormalThreshold, normalEdge));
```

## Day 15

**얼굴 SDF 그림자** · [본문](day15-face-sdf.md)

비유: SDF 텍스처는 밀물 지도다. 수위(빛 각도)가 오르면 낮은 곳부터 잠긴다.

- 얼굴은 N·L 그림자가 지저분하므로 그림자 모양을 텍스처로 미리 그려 둔다.
- 빛·얼굴 방향을 XZ 평면에 투영해 내적 두 개를 구한다. `FdotL`은 앞뒤, `RdotL`은 좌우다.
- 좌우 대칭은 UV를 뒤집어 한 장으로 처리한다. `coverage = (1 − FdotL) / 2`다.
- `faceLit = saturate((sdf − coverage) / width + 0.5)`. 폭에 `fwidth`를 더해 경계가 항상 매끈하다(`smoothstep`보다 선형에 가깝다).
- 얼굴 방향은 캐릭터마다 다르므로 전역 값이 아니라 MaterialPropertyBlock으로 넣는다(카드 A3). 대가는 SRP Batcher에서 빠지는 것이다.

```hlsl
faceLit = saturate((sdf - coverage) / max(_SDFSoftness * 2.0h + fwidth(sdf) * 1.5h, 1e-4h) + 0.5h);
```

## Day 16

**노멀맵과 미분** · [본문](day16-normal-maps-and-derivatives.md)

비유: 노멀맵은 빛에게만 하는 거짓말이고, `ddx/ddy`는 옆 픽셀의 값을 읽는 것이다.

- 노멀맵 색 = 방향 벡터 × 0.5 + 0.5. 평평한 면은 (0.5, 0.5, 1)로 연보라색이다.
- 탄젠트 공간: T(u 방향), B(v 방향), N(바깥). 행렬로 월드 공간에 옮긴다.
- GPU는 2×2 쿼드 단위로 셰이딩한다. `ddx`는 가로 차이, `ddy`는 세로 차이, `fwidth = |ddx| + |ddy|`다.
- 캐릭터는 TANGENT를 외곽선에 쓰므로 위치·UV 미분으로 T, B를 즉석에서 계산한다(Schüler 방식).
- 절대 크기 기준은 근거리에서 틀리므로 방향만 쓰고 0으로 나누는 경우만 막는다.
- 픽셀마다 결과가 다른 `if` 안에서는 미분 함수를 쓰지 않는다.

```hlsl
float3 dp1 = ddx(positionWS); float2 duv1 = ddx(uv);   // 가로로 한 픽셀 이동할 때 위치·UV 변화량
```

## Day 17

**반짝임 3종** · [본문](day17-highlights.md)

비유: 스펙큘러는 거울에 비친 해, 천사 고리는 결 방향으로 흐르는 빛 띠, MatCap은 반사 구슬 스티커다.

- 블린-퐁: `H = normalize(L + V)`, `pow(N·H, 지수)`. 지수가 클수록 하이라이트가 작고 날카롭다.
- `exp2(smoothness × 11)`은 1~2048 범위다. 결과를 `smoothstep`으로 잘라 경계가 분명한 하이라이트를 만든다.
- 천사 고리(이방성): `1 − |T·H|`. H가 결 방향 T에 수직일수록 밝다. `cos/sin`으로 결 방향을 회전한다.
- MatCap: 뷰 공간 노멀의 `xy × 0.5 + 0.5`를 UV로 써서 구 텍스처에서 색을 읽는다.
- 마스크는 토글이 켜졌을 때만 읽는다(카드 C7, 숫자 분기).

```hlsl
float2 matcapUV = mul((float3x3)UNITY_MATRIX_V, N).xy * 0.5 + 0.5;
```

## Day 18

**패스 총정리** · [본문](day18-passes.md)

비유: 캐릭터 하나를 찍는 촬영 팀 여섯이며 모든 팀이 같은 대본을 따라야 한다.

- 패스 여섯: 색 / 외곽선 / 그림자(거리) / 깊이 / 깊이+노멀 / 모션 벡터.
- 모든 패스가 같은 곳을 잘라야 한다(`ClipToonSurface`, 카드 A4). 그렇지 않으면 그림자·외곽선·깊이가 어긋난다.
- 모든 패스가 같은 `Cull`을 쓰고 뒷면은 노멀을 뒤집는다(`IS_FRONT_VFACE`, 카드 A6·B3).
- `UsePass`로 패스를 빌려 쓰면 복사본 불일치를 막는다.
- 모션 벡터 = 현재 위치 − 이전 프레임 위치(지터 없는 행렬 사용). TAA·모션 블러가 쓴다(카드 C1).
- 스텐실은 도장판이다. 눈썹이 기록하고 앞머리가 피하면 앞머리 너머로 눈썹이 보인다.

```hlsl
input.normalWS *= IS_FRONT_VFACE(faceSign, 1.0, -1.0);   // 뒷면이면 노멀을 반대로
```

## Day 19

**키워드와 배리언트** · [본문](day19-keywords-and-variants.md)

비유: 셰이더는 옵션마다 따로 굽는 빵집이다. 옵션 하나가 늘면 종류가 2배가 된다.

- `#if`로 갈린 코드는 서로 다른 셰이더(배리언트)가 된다. 꺼진 기능은 비용이 0이고 대신 사본이 2ⁿ개로 늘어난다.
- `multi_compile`은 모든 조합을 항상 빌드한다(엔진이 런타임에 켜는 키워드에 쓴다). `shader_feature`는 빌드에 포함된 머티리얼이 쓰는 조합만 빌드한다(런타임에 코드로 켜는 키워드에는 맞지 않는다).
- `_local`은 전용 키워드(전역 키워드 한도 절약), `_fragment`는 프래그먼트 스테이지에서만 갈려 사본이 줄어든다.
- 가벼운 옵션은 머티리얼 숫자 분기로 처리한다. 한 오브젝트의 픽셀이 모두 같은 분기를 타므로 비용이 거의 없다.
- 스트리퍼는 불가능한 조합을 빌드에서 뺀다. 머티리얼을 먼저 정리(Sanitizer)해야 유일한 배리언트를 잃지 않는다.
- 외곽선을 끈 머티리얼은 `SetShaderPassEnabled`로 패스 자체를 끈다(카드 B4).

```hlsl
#pragma shader_feature_local_fragment _ _ALPHATEST_ON
```

## Day 20

**성능** · [본문](day20-performance.md)

비유: 드로우콜은 택배 발송 건수다. 묶어서 보내고 재료표는 창고에 미리 둔다.

- SRP Batcher는 머티리얼 상수를 GPU 버퍼에 미리 올리고 드로우마다 바인딩만 바꾼다. 모든 패스의 `CBUFFER(UnityPerMaterial)` 모양이 같아야 호환된다.
- MaterialPropertyBlock을 쓰면 그 렌더러는 SRP Batcher에서 빠진다. 대가를 알고 고른다.
- GPU 인스턴싱: `multi_compile_instancing` + `UNITY_VERTEX_INPUT_INSTANCE_ID` + `UNITY_SETUP_INSTANCE_ID`.
- GPU Resident Drawer는 DOTS 인스턴싱 배리언트가 있어야 셰이더를 쓴다(카드 B1). Unity 6 이상 기능이다.
- LOD 크로스페이드는 점묘 디더로 전환하며 모든 패스에 적용해야 한다.
- 거리 품질 페이드: 오브젝트 원점 거리로 비싼 장식을 생략하거나 페이드한다.

```hlsl
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"
```

## Day 21

**배경 셰이더** · [본문](day21-background-shaders.md)

비유: 스플랫맵은 물감 네 통을 어디에 얼마나 칠할지 적은 지도다.

- 배경은 `ToonShared` 함수로 캐릭터와 같은 톤을 낸다.
- 트라이플래너: 세 축 방향 투영. 월드 위치를 UV로 쓰고 `pow(|N|, sharp)`로 섞는다.
- 정점 색으로 이끼·눈 레이어를 블렌딩한다.
- 바람: `sin` 파형 여러 개, 밑동 고정(로컬 y), 위치마다 위상을 다르게 한다. 모든 패스에 적용한다.
- 지형: Control RGBA로 4레이어 가중 평균. Draw Instanced는 높이 맵에서 정점을 복원한다(카드 B12).
- Meta 패스는 라이트맵 베이커에 색을 알린다. `Dependency "BaseMapShader"`가 없으면 베이크에서 빠진다.

```hlsl
return (a0 * ctrl.r + a1 * ctrl.g + a2 * ctrl.b + a3 * ctrl.a) / wsum;
```

## Day 22

**졸업 — 한 픽셀의 일생** · [본문](day22-graduation.md)

비유: `frag` 380줄은 픽셀 하나의 여정이다.

- 뼈대 세 단계: ① `lightVal` 만들기 ② 계단으로 색 정하기 ③ 빛나는 요소 더하기.
- 기능 추가 체크리스트: Properties → CBUFFER(한 파일) → 키워드 또는 숫자 분기 → 계산 → NaN 방지 → 다른 패스 → Unlit·배경 → 인스펙터 → 수정 전·후 캡처로 검증.
- 다음 공부: The Book of Shaders, Catlike Coding, URP ShaderLibrary 소스, 다른 툰 셰이더 비교.

```hlsl
shaded = MixFog(shaded, input.fogFactor);
return half4(shaded, baseColor.a);   // 최종 색 반환
```
