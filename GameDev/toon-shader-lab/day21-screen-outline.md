# Day 21. 화면 공간 외곽선 — 다 그린 그림 위에 펜으로

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-021-MP |
| 목적 | 깊이 텍스처와 노멀 텍스처의 이웃 픽셀 차이로 경계를 찾는 풀스크린 셰이더를 만들고 Full Screen Pass Renderer Feature에 연결한다 |
| 적용 대상 | Unity 6000.3, URP 17.x, `Assets/Settings/PC_Renderer`. Day 09(`DepthOnly`)와 Day 19(`DepthNormals`) 완료 상태 |
| 소요 시간 | 약 60분 (개념 10분, 셰이더 25분, 연결 15분, 실험 10분) |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리한 것이며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 Day는 URP 버전과 Render Graph 사용 여부에 크게 의존한다. `Blit.hlsl`의 `Varyings`, `_BlitTexture`, `sampler_LinearClamp`, `SampleSceneDepth`, `SampleSceneNormals`, Full Screen Pass Renderer Feature의 설정 항목(`Injection Point`, `Fetch Color Buffer`, `Requirements`)은 URP 버전마다 이름과 동작이 다르다. `SampleSceneNormals`가 읽는 노멀 형식은 Day 19의 `DepthNormals` 패스 출력 형식과 맞아야 한다. URP 버전 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day09-cast-shadows.md](day09-cast-shadows.md) | GMD-TSL-009-MP | `DepthOnly` 패스 |
| [day13-outline-pass.md](day13-outline-pass.md) | GMD-TSL-013-MP | 물체별 외곽선(비교 대상) |
| [day19-depthnormals-ssao.md](day19-depthnormals-ssao.md) | GMD-TSL-019-MP | `DepthNormals` 패스 |
| [day20-two-sided.md](day20-two-sided.md) | GMD-TSL-020-MP | 이전: 양면 그리기 |
| [day22-graduation.md](day22-graduation.md) | GMD-TSL-022-INS | 다음: 졸업 점검 |
| [toon-shader-study Day 14](../toon-shader-study/day14-screen-space-outline.md) | - | C# Renderer Feature와 RenderGraph (짝꿍 과정) |
| [Roberts cross](https://en.wikipedia.org/wiki/Roberts_cross), [Sobel operator](https://en.wikipedia.org/wiki/Sobel_operator), [Edge detection](https://en.wikipedia.org/wiki/Edge_detection), [LearnOpenGL Depth testing](https://learnopengl.com/Advanced-OpenGL/Depth-testing) | - | 경계 검출, 깊이 비선형성 참고 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | `Assets/Settings/PC_Renderer` | URP Renderer Data | 이 에셋에 피처를 추가한다 |
| 2 | `Assets/MyToon` 폴더 | | 셰이더와 머티리얼 저장 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: Renderer Feature는 프로젝트 전체 렌더러에 적용된다. 실습이 끝나면 `PC_Renderer`의 변경을 되돌릴 수 있게 작업 전에 커밋한다. 실습 프로젝트의 `PC_Renderer`에는 이 피처가 처음부터 들어 있지 않다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | `DepthOnly`, `DepthNormals` 패스가 `MyToon.shader`에 있다 | Day 09, 19 완료 |
| 2 | 현재 상태를 커밋한다 | `git status`가 깨끗하다 |

## 5. 절차

### A. 개념 확인

화면 각 픽셀에서 이웃 픽셀과 깊이를 비교한다. 깊이가 급격히 변하는 곳이 경계다. 같은 거리에서 꺾인 면(Cube 모서리)은 깊이만으로 찾을 수 없으므로 노멀도 비교한다.

| 항목 | 외곽선 패스 (Day 13) | 화면 외곽선 (Day 21) |
|---|---|---|
| 방식 | 물체마다 부푼 껍질 | 완성된 화면에서 경계 검출 |
| 강점 | 실루엣, 물체별 색과 두께 | 안쪽 모서리, 배경 전체 |
| 필요 조건 | 메시 노멀 | `DepthOnly`, `DepthNormals` 패스 |

### B. 풀스크린 셰이더 작성

1. (5-B-01) `MyToon` 폴더를 우클릭하고 `Create > Shader > Unlit Shader`를 눌러 이름을 `MyScreenOutline`으로 한다.
2. (5-B-02) 파일 내용을 전부 지우고 다음 코드를 입력한다. → 결과: 컴파일 오류가 없다.

```hlsl
// 화면 전체에 한 번 칠하는 셰이더. URP 의 Full Screen Pass Renderer Feature 가 이 머티리얼로 화면을 다시 그린다.
Shader "MyToon/Screen Outline"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (0.12, 0.1, 0.16, 1)
        _Thickness ("Thickness (px)", Range(0.5, 4)) = 1
        _DepthThreshold ("Depth Threshold", Range(0.001, 1)) = 0.05
        _NormalThreshold ("Normal Threshold", Range(0.01, 2)) = 0.6
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }
        ZWrite Off
        ZTest Always
        Cull Off

        Pass
        {
            Name "ScreenOutline"

            HLSLPROGRAM
            #pragma vertex Vert          // Blit.hlsl 이 주는 '화면 전체 삼각형' 버텍스 셰이더
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"

            half4 _OutlineColor;
            float _Thickness;
            float _DepthThreshold;
            float _NormalThreshold;

            float EyeDepth(float2 uv)
            {
                return LinearEyeDepth(SampleSceneDepth(uv), _ZBufferParams);   // 깊이 버퍼 값 → 진짜 거리(m)
            }

            half4 Frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                float2 uv = input.texcoord;
                half4 color = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);   // 지금까지 그린 그림

                float2 t = _Thickness / _ScaledScreenParams.xy;   // 몇 픽셀 옆을 볼지 (UV 단위)

                // ① 깊이 경계: 나와 오른쪽·위·대각선 이웃의 거리 차이. 멀수록 차이가 커지니 내 거리로 나눈다.
                float d  = EyeDepth(uv);
                float dx = EyeDepth(uv + float2(t.x, 0));
                float dy = EyeDepth(uv + float2(0, t.y));
                float dd = EyeDepth(uv + t);
                float depthEdge = (abs(d - dx) + abs(d - dy) + abs(d - dd)) / max(d, 1e-3);

                // ② 노멀 경계: 면이 꺾이는 곳
                half3 n  = SampleSceneNormals(uv);
                half3 nx = SampleSceneNormals(uv + float2(t.x, 0));
                half3 ny = SampleSceneNormals(uv + float2(0, t.y));
                float normalEdge = distance(n, nx) + distance(n, ny);

                float edge = saturate(step(_DepthThreshold, depthEdge) + step(_NormalThreshold, normalEdge));
                return lerp(color, _OutlineColor, edge * _OutlineColor.a);
            }
            ENDHLSL
        }
    }
}
```

| 부분 | 의미 |
|---|---|
| `#pragma vertex Vert` + `Blit.hlsl` | 화면을 덮는 삼각형 하나를 그리는 URP 표준 버텍스 셰이더. `Frag`만 작성하면 된다 |
| `_BlitTexture` | URP가 넘기는 지금까지 그린 화면 |
| `SampleSceneDepth`, `SampleSceneNormals` | Day 09, 19의 패스가 만든 깊이, 노멀 텍스처를 읽는다 |
| `LinearEyeDepth` | 깊이 버퍼는 가까운 곳을 촘촘히 저장해 거리와 비례하지 않는다. 실제 거리(m)로 바꾼다 |
| `/ max(d, 1e-3)` | 먼 바닥은 깊이 차가 원래 커서 줄무늬가 생긴다. 자기 거리로 나눠 비율로 비교한다 |
| `distance(n, nx)` | 노멀 벡터 간 거리. 같은 면이면 0, 꺾이면 커진다 |
| `step(기준, 값)` | 값이 기준 이상이면 1 |
| `lerp(color, 선 색, edge)` | 경계면 선 색, 아니면 원래 화면 |

이 셰이더는 화면 전체에 한 번만 쓰므로 SRP Batcher와 무관하다. 그래서 `CBUFFER` 없이 선언했다.

정답 파일: [`Assets/Solutions/Day21/MyScreenOutline.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day21/MyScreenOutline.shader)

### C. URP에 연결

1. (5-C-01) `MyToon` 폴더에서 `Create > Material`을 눌러 이름을 `MyScreenOutline`으로 한다.
2. (5-C-02) 머티리얼의 `Shader`를 `MyToon > Screen Outline`으로 지정한다.
3. (5-C-03) `Assets/Settings/PC_Renderer`를 선택하고 Inspector 맨 아래에서 `Add Renderer Feature` > `Full Screen Pass Renderer Feature`를 누른다. → 결과: 피처가 목록에 추가된다.
4. (5-C-04) 추가된 피처를 다음 표와 같이 설정한다. → 결과: Game 뷰와 Scene 뷰 모두에 선이 생긴다.

| 항목 | 값 | 이유 |
|---|---|---|
| `Pass Material` | `MyScreenOutline` | 이 Day의 셰이더 |
| `Injection Point` | `Before Rendering Post Processing` | 불투명, 투명을 다 그린 뒤 후처리 전 |
| `Fetch Color Buffer` | 켬 | 지금까지 그린 화면을 `_BlitTexture`로 받는다 |
| `Requirements` | `Depth`, `Normal` | 깊이와 노멀 텍스처가 필요함을 URP에 알린다 |

![Day 21 결과: 화면 공간 외곽선](../.gitbook/assets/day21-screen-outline.png)

### D. 확인과 실험

1. (5-D-01) Cube의 안쪽 모서리(면과 면이 만나는 세로선)를 본다. → 결과: 선이 생긴다. Day 13 외곽선은 실루엣에만 있었다.
2. (5-D-02) `Normal Threshold`를 0.1로 내린다. → 결과: `Use Normal Map`이 켜져 있으면 노멀맵 홈에도 선이 생긴다. 2로 올리면 안쪽 선이 사라진다.
3. (5-D-03) `Thickness`를 2로 올린다. → 결과: 선이 굵어진다.
4. (5-D-04) 한쪽 기준(`Depth Threshold` 또는 `Normal Threshold`)을 최대로 올린다. → 결과: 깊이 기준과 노멀 기준이 각각 어떤 선을 그리는지 비교할 수 있다.
5. (5-D-05) 렌더러 피처 체크를 껐다 켠다. → 결과: 선이 사라지고 나타난다.
6. (5-D-06) 커밋한다: `git add Assets && git commit -m "Day 21: 화면 공간 외곽선"`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Cube 안쪽 모서리를 본다 | 선이 있다 | 선이 보인다 |
| 2 | 렌더러 피처를 끈다 | 선이 사라진다 | Day 20과 같은 화면 |
| 3 | `Thickness = 2` | 선이 굵어진다 | `Thickness = 1`보다 굵다 |

## 7. 복구

1. (7-01) 렌더러 피처를 끈다: `PC_Renderer`의 `Full Screen Pass Renderer Feature` 체크를 해제한다.
2. (7-02) 렌더러를 원래대로 되돌린다: `git restore Assets/Settings/PC_Renderer.asset`
3. (7-03) 새로 만든 `MyScreenOutline.shader`, `MyScreenOutline` 머티리얼을 삭제한다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 Day 21 페이지를 AMM 형식으로 재작성. 비유 삭제, URP 버전·Render Graph 의존 NOTE 추가 |

[← Day 20](day20-two-sided.md) · [목차](README.md) · [다음: Day 22 →](day22-graduation.md)
