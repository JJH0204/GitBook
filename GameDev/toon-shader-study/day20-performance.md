# Day 20. 성능 — 택배를 적게, 짐을 가볍게

> ⏱ **약 1시간** — 읽기 30분 · 코드 따라 읽기 15분 · 해보기 15분
> 🧸 **오늘의 비유**: 드로우콜은 **택배 발송 건수**예요. 같은 물건은 **한 상자에 묶어** 보내고, 창고에 **재료표를 미리** 둬요.

## 오늘 배울 것

- [ ] 드로우콜과 "상태 바꾸기"가 왜 비싼지 안다
- [ ] SRP Batcher가 CBUFFER 모양이 같아야 동작하는 이유를 안다
- [ ] MaterialPropertyBlock을 쓰면 배처에서 빠진다는 대가를 안다
- [ ] GPU 인스턴싱과 GPU Resident Drawer가 무엇인지 안다
- [ ] LOD 크로스페이드와 거리 품질 페이드를 안다

---

## 1. 택배 건수가 문제

CPU가 GPU에게 "이 물체를 이 셰이더로 그려"라고 부탁하는 한 번이 **드로우콜**이에요. 부탁할 때마다 "재료는 이거, 텍스처는 저거" 하고 **설정을 바꾸는** 준비가 필요한데, 이게 GPU가 그리는 시간보다 오래 걸리기도 해요. 물건보다 **포장과 송장 쓰기**가 더 오래 걸리는 거예요.

그래서 목표는 두 가지예요.
1. **설정 바꾸기를 줄인다** → SRP Batcher
2. **같은 물건은 한 번에 보낸다** → 인스턴싱, GPU Resident Drawer

## 2. SRP Batcher — 창고에 재료표를 미리 둔다

SRP Batcher는 머티리얼마다의 재료 값(CBUFFER)을 **GPU 창고에 미리 올려 두고**, 그릴 때는 "3번 재료표 써" 하고 **번호만** 불러요. 그래서 머티리얼이 달라도 **같은 셰이더**를 쓰는 물체들은 아주 빠르게 이어서 그려요.

조건이 있어요. **모든 패스의 재료표 모양이 똑같아야** 해요. 그래서 이 셰이더 패키지는 CBUFFER를 한 파일에서만 정의해요.

[ToonInput.hlsl L4–5](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L4-L5)

```hlsl
// 모든 패스가 이 파일 하나만 include 한다.
// UnityPerMaterial CBUFFER 레이아웃을 단일 정의로 강제 -> 전 패스 동일 레이아웃 (SRP Batcher 핵심)
```

[L33](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L33)에는 "순서/타입 변경 금지"라고까지 적혀 있어요. 색칠 패스에만 변수를 하나 추가하면 그 패스의 재료표 모양이 달라져서 배처가 꺼져요.

이것도 같은 이유예요.

- `_UseNormalMap`, `_UseRim` 같은 **키워드용 숫자도 CBUFFER에** 넣어요 ([L49](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L49) "batcher 유지 위해 CBUFFER 포함").
- 매 프레임 바뀌는 캐릭터 조명은 **CBUFFER 밖** 글로벌로 둬요 (Day 09).

## 3. MaterialPropertyBlock의 대가

Day 15에서 얼굴 방향을 렌더러마다 다르게 넣으려고 **포스트잇**(MaterialPropertyBlock)을 썼어요. 포스트잇은 창고의 재료표와 **다른 값**을 덧붙이는 거라, 그 렌더러는 SRP Batcher의 빠른 길에서 **빠져요**.

| 방법 | 렌더러마다 다른 값 | SRP Batcher |
|---|---|---|
| 머티리얼을 캐릭터마다 복사 | ✅ | ✅ 유지 (대신 머티리얼 관리가 번거로움) |
| MaterialPropertyBlock | ✅ | ❌ 빠짐 |
| 글로벌 (`SetGlobal`) | ❌ 모두 같은 값 | ✅ 유지 |

얼굴 렌더러는 캐릭터당 몇 개뿐이라 MPB를 골랐어요. **정답은 상황마다 달라요.** 대가를 알고 고르는 게 중요해요.

## 4. GPU 인스턴싱 — 같은 나무 100그루

같은 메시 + 같은 머티리얼인 물체가 많으면(나무, 풀, 돌) **한 번의 부탁으로 여러 개**를 그릴 수 있어요. 물체마다 다른 건 위치(행렬)뿐이니까, 위치 목록만 따로 넘겨요. 이게 **GPU 인스턴싱**이에요.

배경 셰이더는 인스턴싱을 지원해요. [SceneToon.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon.shader)

```hlsl
#pragma multi_compile_instancing                               // L135: 인스턴싱 배리언트
struct Attributes { ... UNITY_VERTEX_INPUT_INSTANCE_ID };      // L151: "나는 몇 번째 나무" 번호 칸
Varyings vert(Attributes input)
{
    UNITY_SETUP_INSTANCE_ID(input);          // L170: 번호로 내 위치 행렬 찾기
    UNITY_TRANSFER_INSTANCE_ID(input, o);    // L171: 프래그먼트에도 번호 전달
```

이 매크로 세 개만 넣으면 `TransformObjectToWorld`가 **내 번호의 행렬**을 알아서 써요.

## 5. GPU Resident Drawer — 창고 관리를 GPU에게

Unity 6의 **GPU Resident Drawer**(GRD)는 한 발 더 나아가요. 장면의 정적인 물체 정보를 **GPU 메모리에 상주**시키고, GPU가 직접 "보이는 것만 골라 묶어서" 그려요. CPU 부담이 크게 줄어요.

GRD가 셰이더를 쓰려면 **DOTS 인스턴싱 배리언트**가 있어야 해요. [SceneToon.shader L134–137](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon.shader#L134-L137)

```hlsl
#pragma multi_compile _ LOD_FADE_CROSSFADE
#pragma multi_compile_instancing
#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"   // ← DOTS 인스턴싱
#pragma instancing_options renderinglayer      // 라이트 레이어(Day 09)를 인스턴스마다
```

![GPU Resident Drawer](../.gitbook/assets/day20-gpu-resident-drawer.png)

{% hint style="warning" %}
**💡 실제로 있었던 일 (B1)**
PC 설정은 GRD를 켜 두었는데, 배경 셰이더에 DOTS 배리언트가 없어서 GRD가 배경 물체를 **전부 건너뛰었어요.** URP Lit 큐브 20개와 SceneToon 큐브 20개를 놓고 플레이 모드에서 세어 보니 GRD가 관리하는 수가 **20개**(Lit만)였어요. 위 네 줄을 넣은 뒤 **40개**가 됐어요. 화면은 같아 보여도 CPU 일이 달라요.

반대로 캐릭터 셰이더에는 일부러 DOTS를 **안** 넣어요. 캐릭터는 스킨드 메시라 GRD 대상이 아니고, Day 18에서 봤듯 실수로 DOTS 선언이 들어가자 GRD가 캐릭터를 가져가서 에러로 그렸어요(C1).
{% endhint %}

## 6. LOD 크로스페이드 — 점점이 바꿔치기

멀리 있는 물체는 **점이 적은 간단한 모델**(LOD)로 바꿔 그려요. 그런데 갑자기 바뀌면 "툭" 튀어 보여요. **크로스페이드**는 바뀌는 동안 두 모델을 **점점이(디더)** 섞어요. 한쪽은 픽셀을 50% 버리고, 다른 쪽은 나머지 50%를 버리는 식이에요.

[SceneToonInput.hlsl L18–23](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/ShaderLibrary/SceneToonInput.hlsl#L18-L23)

```hlsl
void SceneLODFade(float4 positionCS)
{
#if defined(LOD_FADE_CROSSFADE)
    LODFadeCrossFade(positionCS);     // 내부에서 clip() — 화면 위치에 따라 점점이 버림
#endif
}
```

모든 패스의 프래그먼트 첫머리에서 불러요. **그림자와 깊이도 같이** 점점이 버려야 바뀌는 동안 그림자만 튀지 않아요. Day 18의 "모든 팀이 같은 곳을 자른다" 규칙이에요.

## 7. 거리 품질 페이드 — 멀면 비싼 장식은 생략

캐릭터가 여러 명이면 멀리 있는 캐릭터의 MatCap, 천사 고리, 깊이 림 같은 **비싼 장식**은 어차피 잘 안 보여요. [CharacterToon.shader L321–329](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L321-L329)

```hlsl
half hqAmount = 1.0h;
#if defined(_USE_QUALITY_FADE)
    float3 objPosWS = float3(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23);   // 물체 원점
    float distToCam = distance(objPosWS, _WorldSpaceCameraPos);
    hqAmount = saturate(1.0h - (half)((distToCam - _QualityFadeStart) / max(_QualityFadeEnd - _QualityFadeStart, 1e-3)));
#endif
```

그리고 장식마다 `if (hqAmount > 0.0h) { ... * hqAmount }` — 멀면 **아예 건너뛰고**, 경계 근처에선 **서서히** 줄여서 툭 사라지지 않게 해요.

물체 **원점**으로 거리를 재는 이유는 Day 16에서 봤어요. 한 물체의 모든 픽셀이 같은 답을 내야 `if`가 싸고, `if` 안의 미분과 밉맵이 안전해요.

## 8. 작은 습관들

- **`half` 쓰기** — 모바일 GPU는 `half` 계산이 더 빨라요. 색·노멀·밝기는 `half`, 위치·깊이·UV는 `float` (Day 04).
- **안 쓰는 텍스처는 안 읽기** — 숫자 분기로 읽기 건너뛰기 (Day 19, C7).
- **안 쓰는 패스는 끄기** — `SetShaderPassEnabled` (Day 19, B4).
- **안 쓰는 배리언트는 안 굽기** — `shader_feature`, `_fragment`, 스트리퍼 (Day 19).

## 9. 해보기 (15분)

1. **(Unity가 있다면) Frame Debugger** — Window → Analysis → Frame Debugger를 열고 Enable. 왼쪽 목록에서 **"SRP Batch"** 항목을 찾아 보세요. 클릭하면 오른쪽에 "왜 이전 묶음과 이어지지 않았는지" 이유가 나와요. 얼굴 렌더러를 찾아 MPB 때문에 따로 그려지는지 확인해 보세요.
2. **품질 페이드 계산** — Start 15, End 40, 거리 30이면 `hqAmount = 1 - (30-15)/25 = 0.4`. 거리 45면? (`saturate(1 - 1.2) = 0` → 장식 전부 생략)
3. **재료표 모양** — 색칠 패스에만 `half _Glitter;`를 CBUFFER에 추가하면 무슨 일이? (다른 패스와 모양이 달라져서 SRP Batcher가 꺼져요. 그래서 반드시 [ToonInput.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl)에 넣어요.)

## 10. 오늘의 액기스

👉 [ESSENCE.md — Day 20](essence.md#day-20)

## 더 읽을거리

- Unity: [SRP Batcher](https://docs.unity3d.com/Manual/SRPBatcher.html) · [GPU 인스턴싱](https://docs.unity3d.com/Manual/GPUInstancing.html) · [Frame Debugger](https://docs.unity3d.com/Manual/FrameDebugger.html) · [LOD Group](https://docs.unity3d.com/Manual/class-LODGroup.html) · [MaterialPropertyBlock](https://docs.unity3d.com/ScriptReference/MaterialPropertyBlock.html)
- [URP — GPU Resident Drawer](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/gpu-resident-drawer.html)
- [LearnOpenGL — Instancing](https://learnopengl.com/Advanced-OpenGL/Instancing) · [Wikipedia — Geometry instancing](https://en.wikipedia.org/wiki/Geometry_instancing) (영어)

---

[← Day 19](day19-keywords-and-variants.md) · [목차](README.md) · [다음: Day 21 →](day21-background-shaders.md)
