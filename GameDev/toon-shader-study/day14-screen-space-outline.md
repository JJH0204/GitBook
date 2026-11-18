# Day 14. 외곽선 ③ — 다 그린 그림 위에 펜으로 긋기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-015-DO |
| 유형 | D&O (개념) + 코드 읽기 + 실습 |
| 목적 | 깊이·노멀 버퍼의 이웃 차이로 경계를 찾는 화면 공간 외곽선과 Renderer Feature 구조를 설명한다 |
| 소요 시간 | 약 1시간 (읽기 20분, 코드 읽기 25분, 실습 15분) |
| 선수 지식 | [Day 12](day12-outline-inverted-hull.md), [Day 13](day13-outline-pixel-width.md) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- [ ] 화면 공간 외곽선(포스트 프로세스)이 인버티드 헐과 어떻게 다른지 안다
- [ ] 깊이 엣지와 노멀 엣지 검출 방법을 손으로 계산할 수 있다
- [ ] Renderer Feature가 URP에 패스를 끼워 넣는 방법을 안다
- [ ] RenderGraph와 블릿(Blit)이 무엇인지 설명할 수 있다

## 1. 정의

화면 공간 외곽선은 장면을 다 그린 뒤 깊이 버퍼와 노멀 버퍼에서 이웃 픽셀과의 차이가 큰 곳을 경계로 판정해, 그 위에 선 색을 덧그리는 포스트 프로세스다.

비유: 그림을 다 그린 뒤 깊이가 확 바뀌는 곳을 찾아 펜으로 선을 긋는 화가.

## 2. 구성 요소

### 2.1 인버티드 헐과의 비교

| 항목 | 인버티드 헐 (Day 12–13) | 화면 공간 외곽선 (오늘) |
|---|---|---|
| 방식 | 물체마다 부푼 껍질을 한 번 더 그린다 | 다 그린 화면에서 경계를 찾아 선을 덧그린다 |
| 비용 | 물체 수에 비례 | 화면 크기에 비례(물체 수와 무관) |
| 잘하는 것 | 캐릭터 실루엣, 물체별 색·두께 | 배경 전체, 안쪽 주름·모서리 선 |
| 약점 | 안쪽 선을 못 그린다 | 물체별 세밀한 조절이 어렵다 |

이 패키지는 둘 다 쓴다. 캐릭터는 인버티드 헐, 배경과 안쪽 선은 화면 공간 외곽선이다.

![화면 공간 외곽선](../.gitbook/assets/day14-screen-space-outline.png)

### 2.2 구성 파일

| 파일 | 역할 |
|---|---|
| `ScreenSpaceOutline.shader` | 화면 전체에 적용하는 외곽선 셰이더 |
| `CharacterToonRendererFeature.cs` | URP 렌더러에 패스를 끼우는 Renderer Feature |
| DepthNormals 패스 | 깊이·노멀 텍스처 생성([Day 18](day18-passes.md)) |

## 3. 동작 원리

각 픽셀에서 이웃과 깊이를 비교한다. 몸통과 배경 사이처럼 깊이가 크게 뛰는 곳이 경계다. 깊이만으로는 같은 거리의 접힌 면(책상 모서리, 옷 주름)을 찾지 못하므로 노멀도 비교한다. 노멀이 크게 바뀌는 곳은 면이 꺾이는 곳이다.

![엣지 검출](../.gitbook/assets/concept-edge-detection.png)

| 검출 | 식 | 잡는 경계 |
|---|---|---|
| 깊이 엣지 | `\|dC−dX\| + \|dC−dY\| + \|dC−dXY\|` | 물체와 배경 사이 |
| 노멀 엣지 | `distance(nC,nX) + distance(nC,nY)` | 같은 깊이의 꺾인 면 |

{% hint style="info" %}
NOTE: 이미지 처리의 대표 엣지 필터는 Roberts cross(대각선 두 쌍의 차)와 Sobel(3×3 가중 합)이다. 아래 코드는 중심 픽셀과 이웃 세 칸의 차이를 더하는 단순 전방 차분이며 Roberts cross 자체는 아니다.
{% endhint %}

## 4. 코드 읽기

### 4.1 프래그먼트 셰이더

[ScreenSpaceOutline.shader L31–64](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/ScreenSpaceOutline.shader#L31-L64)

```hlsl
half4 Frag(Varyings input) : SV_Target
{
    float2 uv = input.texcoord;
    half4 srcColor = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_LinearClamp, uv);   // 다 그린 그림

    float2 t = _OutlineSSThickness / _ScaledScreenParams.xy;                     // 몇 픽셀 옆을 볼지 (UV로)

    // ① 깊이 엣지 — 나, 오른쪽, 아래, 대각선 4칸
    float dC  = LinearEyeDepth(SampleSceneDepth(uv),                  _ZBufferParams);
    float dX  = LinearEyeDepth(SampleSceneDepth(uv + float2(t.x, 0)), _ZBufferParams);
    float dY  = LinearEyeDepth(SampleSceneDepth(uv + float2(0, t.y)), _ZBufferParams);
    float dXY = LinearEyeDepth(SampleSceneDepth(uv + t),             _ZBufferParams);
    float depthEdge = abs(dC - dX) + abs(dC - dY) + abs(dC - dXY);
    float depthRef = lerp(1.0, max(dC, 1e-3), _OutlineSSDepthScale);   // ② 멀수록 기준을 넉넉하게
    depthEdge /= depthRef;

    // ③ 노멀 엣지
    half3 nC = SampleSceneNormals(uv);
    half3 nX = SampleSceneNormals(uv + float2(t.x, 0));
    half3 nY = SampleSceneNormals(uv + float2(0, t.y));
    float normalEdge = distance(nC, nX) + distance(nC, nY);

    // ④ 둘 중 하나라도 기준을 넘으면 선
    float edge = saturate(step(_OutlineSSDepthThreshold,  depthEdge)
                        + step(_OutlineSSNormalThreshold, normalEdge));

    // ⑤ 물체별 '여기는 선 긋지 마' 표시
    float suppress = SAMPLE_TEXTURE2D_X(_CameraNormalsTexture, sampler_PointClamp, uv).w;
    edge *= (1.0 - saturate(suppress));

    return lerp(srcColor, _OutlineSSColor, edge * _OutlineSSColor.a);   // 원래 그림 위에 선 색 섞기
}
```

| 단계 | 설명 |
|---|---|
| ① | 중심과 이웃 세 칸(오른쪽, 아래, 대각선)의 선형 눈 깊이(`LinearEyeDepth`) 차를 더한다 |
| ② | 먼 배경은 깊이 차가 원래 크다. `_OutlineSSDepthScale`을 올리면 자기 깊이로 나눠 가까운 곳과 먼 곳에 같은 기준을 쓴다(B3) |
| ③ | 노멀 벡터 사이의 거리. 같은 방향이면 0, 크게 꺾이면 커진다 |
| ④ | `step`은 기준을 넘으면 1이다. 둘을 더하고 `saturate`로 0~1에 맞춘다 |
| ⑤ | 노멀 텍스처의 남는 채널 w에 억제 정도를 기록하는 방식이다. 배경 셰이더의 DepthNormals 패스가 `_OutlineSuppress`를 기록한다: [SceneToon.shader L484–489](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon.shader#L484-L489) |

{% hint style="info" %}
NOTE: 셰이더 이름 `Hidden/CharacterToon/ScreenSpaceOutline`의 `Hidden/` 접두사는 머티리얼의 셰이더 드롭다운에 표시되지 않게 한다. 물체용이 아니라 C# 코드가 화면 전체에 쓰는 셰이더이기 때문이다.
{% endhint %}

### 4.2 Renderer Feature

이 셰이더는 물체에 붙지 않는다. URP 렌더러 에셋에 추가하는 Renderer Feature가 실행한다. [CharacterToonRendererFeature.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonRendererFeature.cs)

`Create()` (L43–54):

```csharp
public override void Create()
{
    CoreUtils.Destroy(_outlineMaterial);   // 이전 머티리얼 먼저 정리
    _outlineMaterial = null;
    _outlinePass = null;
    if (outline.shader != null)
    {
        _outlineMaterial = CoreUtils.CreateEngineMaterial(outline.shader);
        _outlinePass = new ScreenSpaceOutlinePass(_outlineMaterial);
    }
}
```

{% hint style="warning" %}
CAUTION (이 프로젝트의 실제 사례, C6): URP는 인스펙터 값이 바뀔 때마다 `Create()`를 다시 호출한다. 이전 머티리얼을 지우지 않던 때는 슬라이더를 움직일 때마다 머티리얼이 쌓여 메모리가 누수됐다. 첫 줄에서 지우도록 고쳤다.
{% endhint %}

`AddRenderPasses()` (L56–77)는 게임 카메라와 씬 카메라일 때만 머티리얼에 값을 넣고 `renderer.EnqueuePass(_outlinePass)`로 패스를 대기열에 넣는다.

패스 설정 (L100–108):

```csharp
requiresIntermediateTexture = true;                                                // 중간 렌더 타깃 필요
ConfigureInput(ScriptableRenderPassInput.Depth | ScriptableRenderPassInput.Normal);   // 깊이·노멀 텍스처 요청
```

`ConfigureInput`으로 깊이·노멀 텍스처를 요청하면 URP가 DepthNormals 패스를 실행해 만든다([Day 18](day18-passes.md)).

### 4.3 RenderGraph와 블릿

[L110–139](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonRendererFeature.cs#L110-L139)

```csharp
TextureHandle source = resourceData.activeColorTexture;          // 지금까지 그린 그림
TextureHandle dest = renderGraph.CreateTexture(desc);            // 새 빈 도화지
var blit = new RenderGraphUtils.BlitMaterialParameters(source, dest, _material, 0);
using (var builder = renderGraph.AddBlitPass(blit, "CharacterToon SS Outline", returnBuilder: true))
{
    if (resourceData.cameraDepthTexture.IsValid())   builder.UseTexture(resourceData.cameraDepthTexture);
    if (resourceData.cameraNormalsTexture.IsValid()) builder.UseTexture(resourceData.cameraNormalsTexture);
}
resourceData.cameraColor = dest;                                  // 이제부터 새 도화지가 '현재 그림'
```

| 용어 | 설명 |
|---|---|
| RenderGraph | 패스가 만들고 읽는 리소스를 선언하면 URP가 실행 순서와 메모리 수명을 정리하는 구조. 비유: 요리 순서표 |
| 블릿(Blit) | 한 텍스처를 다른 텍스처로 복사하면서 머티리얼 셰이더를 적용하는 전체 화면 그리기. `source`가 `_BlitTexture`로 전달된다 |
| `UseTexture` | 이 패스가 해당 텍스처를 읽는다고 그래프에 선언한다. 선언하지 않으면 RenderGraph가 텍스처를 일찍 해제하거나 재활용할 수 있다(B11) |
| 마지막 줄 | 복사본을 원래 자리로 다시 옮기지 않고 `cameraColor`를 `dest`로 교체해 복사 한 번을 아낀다 |

{% hint style="info" %}
NOTE: RenderGraph API(`TextureHandle`, `AddBlitPass`, `RenderGraphUtils`)와 `ScriptableRenderPassInput`은 Unity 6(URP 17) 기준이다. 이전 버전의 URP는 `Execute`와 `CommandBuffer.Blit` 방식이므로 이 코드를 그대로 쓸 수 없다. `_BlitTexture`, `SampleSceneNormals` 같은 이름도 URP 버전에 따라 다르다. 버전 확인 필요.
{% endhint %}

## 5. 주의

{% hint style="warning" %}
CAUTION: 깊이 차 기준은 거리에 따라 달라진다. 먼 지면에서 깊이 차 1이 기준 0.2를 넘으면 줄무늬가 생긴다. `_OutlineSSDepthScale`로 깊이 정규화를 켠다.
{% endhint %}

## 6. 실습

1. 깊이 엣지를 계산한다. `dC = 3`, `dX = 3`, `dY = 9`, `dXY = 9`이다. → 결과: `depthEdge = 0 + 6 + 6 = 12`이며 기준 0.2보다 크므로 선이 생긴다. 넷 다 3이면 0이라 선이 없다.
2. 노멀 엣지를 계산한다. `nC = (0,1,0)`, `nX = (1,0,0)`이다. → 결과: `distance = √2 ≈ 1.41`이며 기준 0.4보다 크므로 선이 생긴다.
3. 깊이 정규화를 확인한다. 배경 `dC = 50`, 옆 칸 51이면 차이 1이다. → 결과: 기준 0.2에서 선이 생긴다. `_OutlineSSDepthScale = 1`이면 `1 / 50 = 0.02`로 선이 없다.
4. (Unity가 있다면) PC_Renderer 에셋에서 Character Toon Renderer Feature를 찾아 Thickness와 Threshold를 바꾼다. 되돌리려면 Ctrl+Z 또는 원래 값을 입력한다. → 결과: 선 두께와 검출 민감도가 바뀐다.

## 7. 참조

- [Day 14 액기스](essence.md#day-14)
- [Wikipedia — Roberts cross](https://en.wikipedia.org/wiki/Roberts_cross), [Sobel operator](https://en.wikipedia.org/wiki/Sobel_operator), [Edge detection](https://en.wikipedia.org/wiki/Edge_detection)
- [URP — Renderer Feature로 패스 끼워 넣기](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/renderer-features/scriptable-renderer-features/inject-a-pass-using-a-scriptable-renderer-feature.html)
- [URP — Render Graph](https://docs.unity3d.com/6000.0/Documentation/Manual/urp/render-graph.html)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 인버티드 헐과 화면 공간 외곽선 중 내 프로젝트에 어느 쪽이 맞는지, 이유와 함께 적는다.
- [ ] 깊이 엣지만으로 못 잡는 경계의 예를 직접 본 장면에서 찾아 적는다.
- [ ] Renderer Feature가 필요한 이유를 내 말로 설명한다.

---

[← Day 13](day13-outline-pixel-width.md) · [목차](README.md) · [다음: Day 15 →](day15-face-sdf.md)
