# 액기스 모음 — 22일치 핵심만

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-023-REF |
| 유형 | REF (표와 코드 한 줄) |
| 목적 | Day 01~22의 핵심 규칙과 대표 코드 한 줄을 복습용으로 찾아본다 |
| 확인 상태 | 미검증 (각 Day 문서의 내용을 요약한 것이다) |
| 개정 | R1 (2026-11-18) |

각 Day 제목의 앵커(`#day-01` 등)는 다른 문서가 링크한다. 제목을 바꾸지 않는다. 본문 목록은 [README.md](README.md#커리큘럼)에 있다.

---

## Day 01

[본문: GMD-TSL-001-MP](day01-first-shader.md) | 첫 셰이더

| 항목 | 핵심 |
|---|---|
| 뼈대 | `Shader "이름"` > `SubShader`(Tags) > `Pass`(LightMode) > `HLSLPROGRAM ... ENDHLSL` |
| 진입점 | `#pragma vertex vert`는 정점마다 위치 계산, `#pragma fragment frag`는 픽셀마다 색 계산 |
| 구조체 | `Attributes`(메시에서 vert), `Varyings`(vert에서 frag). `: POSITION`, `: SV_POSITION`, `: SV_Target`은 시맨틱 |
| 셰이더와 머티리얼 | 셰이더는 코드, 머티리얼은 그 코드를 쓰는 설정 묶음 |
| 오류 표시 | 컴파일 실패 시 물체가 마젠타. Console에서 줄 번호를 읽는다 |

```hlsl
o.positionCS = TransformObjectToHClip(input.positionOS.xyz);   // vert 의 필수 임무
```

## Day 02

[본문: GMD-TSL-002-MP](day02-vertex-shader.md) | 버텍스 셰이더

| 항목 | 핵심 |
|---|---|
| 좌표 공간 | 오브젝트(OS), 월드(WS), 뷰(VS), 클립(CS). 변수 이름 끝 두 글자가 공간 |
| 변환 함수 | `TransformObjectToWorld`, `TransformWorldToHClip`, 노멀은 `TransformObjectToWorldNormal` |
| 시간 | `_Time.y`는 경과 초, `sin`은 -1~1 왕복 |
| 노멀 방향 이동 | 부풀리기. Day 13 외곽선의 기초 |
| 공간 선택 | 월드 기준 무늬는 씬에 고정, 오브젝트 기준 무늬는 물체에 붙는다 |

```hlsl
positionWS += normalWS * (sin(_Time.y * 3.0 + positionWS.y * 8.0) * 0.03);
```

## Day 03

[본문: GMD-TSL-003-MP](day03-properties.md) | Properties와 CBUFFER

| 항목 | 핵심 |
|---|---|
| 형식 | `[꾸밈] _이름 ("표시 이름", 종류) = 기본값`. 종류는 `Color`, `Range(a,b)`, `Float`, `2D` |
| 이름 일치 | Properties와 HLSL 변수 이름은 대소문자까지 같아야 연결된다 |
| CBUFFER | 머티리얼 값은 `CBUFFER_START(UnityPerMaterial)` 안에 선언해야 SRP Batcher 호환 |
| 재사용 | 셰이더 하나로 머티리얼 여러 개 |

```hlsl
CBUFFER_START(UnityPerMaterial)  half4 _BaseColor;  CBUFFER_END
```

## Day 04

[본문: GMD-TSL-004-MP](day04-varyings-debug.md) | Varyings와 디버그 보기

| 항목 | 핵심 |
|---|---|
| 보간 | frag에 도착한 값은 삼각형 세 꼭짓점 값이 섞인 값이다 |
| 시맨틱 | `Attributes`의 `TEXCOORD0`은 메시의 첫 UV. `Varyings`의 `TEXCOORD1`, `TEXCOORD2`는 칸 번호 |
| 정규화 | 보간된 노멀은 길이가 줄므로 frag 첫머리에서 `normalize` |
| 스위즐 | `.xyz`, `.rgb`, `.xz`, `.xxx` |
| 디버그 색 | 노멀은 `N*0.5+0.5`, UV는 `(u, v, 0)` |
| 분기 비용 | 머티리얼 값으로 갈리는 `if`는 모든 픽셀이 같은 분기를 택해 비용이 작다 |

```hlsl
if (_DebugView > 0.5h) return half4(N * 0.5h + 0.5h, 1.0h);
```

## Day 05

[본문: GMD-TSL-005-MP](day05-textures.md) | 텍스처와 알파 클립

| 항목 | 핵심 |
|---|---|
| 선언 | `TEXTURE2D`, `SAMPLER`는 CBUFFER 밖. `SAMPLE_TEXTURE2D(tex, sampler, uv)`로 읽는다 |
| 타일링 | `_BaseMap_ST`는 타일링(xy), 오프셋(zw). `TRANSFORM_TEX`가 적용 |
| 기본 텍스처 | `"white"`는 곱해도 변화 없음 |
| `clip(x)` | x < 0이면 픽셀 버림. 기본 `Cutoff` 0이면 아무것도 오려지지 않는다 |

```hlsl
clip(baseColor.a - _Cutoff);
```

## Day 06

[본문: GMD-TSL-006-MP](day06-first-light.md) | 첫 조명

| 항목 | 핵심 |
|---|---|
| 벡터 | N은 표면 방향, L은 표면에서 광원으로. `GetMainLight()`의 `direction`, `color` |
| 내적 | `dot(N, L)` = cos 값. 정면 1, 직각 0, 반대 -1 |
| 램버트 | `saturate(dot(N, L))`. 뒤쪽 절반이 모두 0 |
| 하프 램버트 | `dot(N, L)*0.5+0.5`. 0~1로 고르게 변해 툰 입력에 적합 |

```hlsl
half lightVal = dot(N, mainLight.direction) * 0.5h + 0.5h;
```

## Day 07

[본문: GMD-TSL-007-MP](day07-toon-steps.md) | 툰 계단

| 항목 | 핵심 |
|---|---|
| 계단 | `smoothstep(Border - Blur, Border + Blur, lightVal)`. Border는 위치, Blur는 부드러움 |
| 0 방지 | Blur가 0이면 0으로 나누기. `max(blur, 1e-4)` |
| 함수화 | 같은 계산을 두 번 하므로 `CelStep` 함수로 만든다 |
| 그림자 색 | 바탕색 x 틴트. `lerp`로 1차, 2차를 덧칠한다 |

```hlsl
half3 toon = lerp(albedo, albedo * _ShadowColor.rgb, 1.0h - CelStep(lightVal, _ShadowBorder, _ShadowBlur));
```

## Day 08

[본문: GMD-TSL-008-MP](day08-receive-shadows.md) | 그림자 받기

| 항목 | 핵심 |
|---|---|
| 개념 | 섀도맵은 광원 위치에서 찍은 깊이 텍스처. 모양 음영(N·L)과 다르다 |
| 키워드 | `multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE`, `_SHADOWS_SOFT` |
| 호출 | 월드 위치를 frag로 전달 > `TransformWorldToShadowCoord` > `GetMainLight(shadowCoord).shadowAttenuation` |
| 툰의 핵심 | 그림자를 색이 아니라 `lightVal`에 곱해 같은 계단 색으로 칠한다 |

```hlsl
lightVal *= lerp(1.0h, mainLight.shadowAttenuation, _ReceiveShadow);
```

## Day 09

[본문: GMD-TSL-009-MP](day09-cast-shadows.md) | 그림자 드리우기

| 항목 | 핵심 |
|---|---|
| `HLSLINCLUDE` | 모든 패스 앞에 붙는 공용 코드(Core include, 텍스처, CBUFFER, 공용 함수) |
| ShadowCaster | `ColorMask 0`, `ApplyShadowBias`로 그림자 여드름 방지 |
| DepthOnly | 카메라 깊이 텍스처에 기록. SSAO와 화면 효과가 사용 |
| 공통 규칙 | 모든 패스가 같은 `ClipAlpha`를 써야 구멍이 그림자에도 뚫린다 |

```hlsl
o.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirWS));
```

## Day 10

[본문: GMD-TSL-010-MP](day10-ambient-fog.md) | 환경광과 안개

| 항목 | 핵심 |
|---|---|
| `SampleSH(N)` | 그 방향의 환경광(SH) |
| 툰 규칙 | 환경광은 그림자 쪽에 덜 더해야 밝은 조명에서 계단이 안 사라진다 |
| 바닥값 | `max(color, albedo * _ShadeFloor)` |
| 안개 | `multi_compile_fog`, vert의 `ComputeFogFactor`, frag의 `MixFog` |

```hlsl
color += SampleSH(N) * albedo * _AmbientStrength * (1.0h - shadeMask);
```

## Day 11

[본문: GMD-TSL-011-MP](day11-additional-lights.md) | 보조 조명

| 항목 | 핵심 |
|---|---|
| 파일 분리 | `MyToonLighting.hlsl`을 `#include`. `#ifndef`로 중복 방지 |
| 보조 조명 계산 | `distanceAttenuation` x `shadowAttenuation` x 계단 |
| 그림자 | 인자 3개 `GetAdditionalLight`라야 보조 조명 그림자가 반영된다 |
| 렌더 경로 | Forward(물체마다 목록)와 Forward+(화면 타일마다 목록). `LIGHT_LOOP_BEGIN/END` |

```hlsl
LIGHT_LOOP_BEGIN(count) sum += ShadeAdditionalLight(GetAdditionalLight(lightIndex, positionWS, shadowMask), ...); LIGHT_LOOP_END
```

## Day 12

[본문: GMD-TSL-012-MP](day12-rim-light.md) | 림 라이트

| 항목 | 핵심 |
|---|---|
| 시선 방향 | `V = GetWorldSpaceNormalizeViewDir(positionWS)` (표면에서 눈으로) |
| 프레넬 | `1 - N·V`. 테두리에서 커진다 |
| 계단화 | 같은 `CelStep`으로 끊는다 |
| 한계 | 평평한 면은 통째로 빛난다. 실제 셰이더는 깊이 림으로 보완 |

```hlsl
half rim = CelStep(1.0h - saturate(dot(N, V)), _RimThreshold, _RimSoftness);
```

## Day 13

[본문: GMD-TSL-013-MP](day13-outline-pass.md) | 외곽선 1 (인버티드 헐)

| 항목 | 핵심 |
|---|---|
| 패스 | 두 번째 패스 `LightMode = SRPDefaultUnlit` |
| 방식 | 노멀 방향으로 부풀리기 + `Cull Front`(뒷면만) + 어두운 색 |
| 한계 | 각진 Cube는 면마다 노멀이 달라 모서리가 벌어진다. 실제로는 스무스 노멀을 별도 저장 |
| 월드 단위 폭 | 멀어지면 1픽셀보다 얇아져 끊긴다 |

```hlsl
positionWS += normalWS * (_OutlineWidth * 0.01);
```

## Day 14

[본문: GMD-TSL-014-MP](day14-outline-pixels.md) | 외곽선 2 (픽셀 두께)

| 항목 | 핵심 |
|---|---|
| NDC | 클립 `xy / w`. 폭 2이므로 1픽셀 = `2 / 화면 크기` |
| 오프셋 | 화면 방향 x (픽셀 x 2 / 화면 크기) x `w`. 거리와 무관하게 일정한 두께 |
| 방향 | 픽셀 공간에서 정규화(가로세로 비율). 길이 0이면 건너뜀 |
| 해상도 | 실제 렌더 타깃 크기 `_ScaledScreenParams`를 쓴다 |

```hlsl
positionCS.xy += (dirPx / len) * (_OutlineWidth * 2.0 / _ScaledScreenParams.xy) * positionCS.w;
```

## Day 15

[본문: GMD-TSL-015-MP](day15-specular.md) | 스페큘러

| 항목 | 핵심 |
|---|---|
| 하프 벡터 | `H = normalize(L + V)`. `dot(N, H)`가 1에 가까울수록 반짝 |
| `pow` | 지수가 클수록 작고 날카롭다. `exp2(smoothness * 11)` = 1~2048 |
| 툰 처리 | `CelStep(spec, 0.5, step)`으로 끊는다 |
| 그림자 | 그림자 속에서는 `* receive`로 끈다 |

```hlsl
half spec = pow(saturate(dot(N, H)), exp2(_Smoothness * 11.0h));
```

## Day 16

[본문: GMD-TSL-016-MP](day16-matcap.md) | MatCap

| 항목 | 핵심 |
|---|---|
| UV | 노멀을 뷰 공간으로(`UNITY_MATRIX_V`) 바꾼 뒤 `xy * 0.5 + 0.5` |
| 샘플링 | MatCap 텍스처의 그 위치 색을 더한다. 빛 계산이 없다 |
| 특성 | 광원을 돌려도 안 움직이고 카메라를 따라간다(스페큘러와 반대) |
| 기본 텍스처 | `"black"`은 더해도 변화 없음 |

```hlsl
half2 matcapUV = mul((float3x3)UNITY_MATRIX_V, N).xy * 0.5h + 0.5h;
```

## Day 17

[본문: GMD-TSL-017-MP](day17-normal-map.md) | 노멀맵

| 항목 | 핵심 |
|---|---|
| 인코딩 | 색 = 법선 x 0.5 + 0.5. 평평한 면은 (0.5, 0.5, 1) = `"bump"` |
| TBN | T(u 방향), B(v 방향, `cross`), N(바깥). 3x3 행렬로 월드 변환 |
| 입력 | 메시의 `TANGENT`(w는 거울 UV 부호), `UnpackNormalScale` |
| 한계 | 외곽선(실루엣)은 바뀌지 않는다 |

```hlsl
N = normalize(mul(normalTS, half3x3(T, B, N)));
```

## Day 18

[본문: GMD-TSL-018-MP](day18-keywords.md) | 키워드

| 항목 | 핵심 |
|---|---|
| 배리언트 | `#if defined(KEY)`가 꺼지면 코드가 없다. 비용 0, 배리언트 수는 2^n |
| 종류 | `multi_compile`(엔진이 켠다, 전부 빌드)과 `shader_feature`(머티리얼이 켠다, 쓰는 것만 빌드) |
| 꼬리말 | `_local`은 셰이더 전용, `_fragment`는 frag에서만 갈림 |
| 체크박스 | `[Toggle(KEY)]`. 키워드 선언은 패스마다 따로 |

```hlsl
#pragma shader_feature_local_fragment _ _USE_RIM
```

## Day 19

[본문: GMD-TSL-019-MP](day19-depthnormals-ssao.md) | DepthNormals와 SSAO

| 항목 | 핵심 |
|---|---|
| 패스 필요성 | `DepthNormals` 패스가 없으면 SSAO가 이 물체를 인식하지 못한다 |
| 출력 | 색 대신 월드 노멀(URP 버전별 형식 확인 필요) |
| 키워드 | `_SCREEN_SPACE_OCCLUSION`, `GetScreenSpaceAmbientOcclusion(화면 UV)` |
| 적용 | indirect AO는 환경광에, direct AO는 메인 라이트에 |

```hlsl
AmbientOcclusionFactor ao = GetScreenSpaceAmbientOcclusion(GetNormalizedScreenSpaceUV(input.positionCS));
```

## Day 20

[본문: GMD-TSL-020-MP](day20-two-sided.md) | 양면과 마무리 점검

| 항목 | 핵심 |
|---|---|
| 컬 | `[Enum(UnityEngine.Rendering.CullMode)] _Cull`, 4개 패스에 `Cull [_Cull]`(외곽선은 `Cull Front` 유지) |
| 뒷면 노멀 | `IS_FRONT_VFACE(faceSign, 1, -1)`. Forward와 DepthNormals 모두 |
| 규칙 | 같은 CBUFFER, 같은 가위, 같은 컬 |
| 점검 | SRP Batcher 호환 확인, Frame Debugger로 패스 순서 확인 |

```hlsl
input.normalWS *= IS_FRONT_VFACE(faceSign, 1.0, -1.0);
```

## Day 21

[본문: GMD-TSL-021-MP](day21-screen-outline.md) | 화면 공간 외곽선

| 항목 | 핵심 |
|---|---|
| 풀스크린 셰이더 | `Blit.hlsl`의 `Vert`와 `_BlitTexture`(지금까지 그린 화면) |
| 경계 검출 | 깊이(`LinearEyeDepth` 차이 / 자기 거리)와 노멀(노멀 벡터 간 거리) |
| 연결 | Full Screen Pass Renderer Feature. `Fetch Color Buffer`, `Requirements = Depth, Normal` |
| 강점 | 외곽선 패스가 못 그리는 안쪽 모서리 |

```hlsl
float edge = saturate(step(_DepthThreshold, depthEdge) + step(_NormalThreshold, normalEdge));
```

## Day 22

[본문: GMD-TSL-022-INS](day22-graduation.md) | 졸업 점검

| 항목 | 핵심 |
|---|---|
| 뼈대 | 1) `lightVal` 만들기 2) 계단으로 색 정하기 3) 빛나는 요소 더하기 |
| 실제 게임 셰이더에만 있는 것 | 얼굴 SDF, 천사 고리, 깊이 림, 스무스 노멀, 캐릭터 전용 조명, 스텐실, 모션 벡터 |
| 새 기능 체크리스트 | Properties와 CBUFFER 일치, 모든 패스 규칙, 0 나누기 방지, 중립 기본값, 변경 전후 화면 비교 |

```hlsl
return half4(color, baseColor.a);   // 한 픽셀의 여행 끝
```

## 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 액기스 페이지를 REF 형식(표)으로 재작성. 비유 문장 삭제, Day별 본문 Task ID 링크 추가 |
