# Day 09. 여러 개의 빛 — 무대 조명 팀

> ⏱ **약 1시간** — 읽기 25분 · 코드 따라 읽기 20분 · 해보기 15분
> 🧸 **오늘의 비유**: 해는 **주인공 조명**, 포인트·스폿 라이트는 **보조 조명**, 캐릭터 라이트는 **인물 사진 전용 조명**이에요.

## 오늘 배울 것

- [ ] 메인 라이트와 추가 라이트의 차이를 안다
- [ ] 툰 셰이더가 추가 라이트를 "더하기만" 하는 이유를 안다
- [ ] Forward와 Forward+가 빛 목록을 찾는 방법의 차이를 안다
- [ ] 라이트 레이어가 무엇인지 안다
- [ ] C# 스크립트가 셰이더에 값을 넣는 방법(글로벌 프로퍼티)을 안다

---

## 1. 무대 조명 팀

| 조명 | URP 이름 | 특징 |
|---|---|---|
| 🌞 주인공 조명 | **메인 라이트** (가장 밝은 Directional Light) | 무한히 멀리서, 모든 곳에 같은 방향으로 |
| 💡 보조 조명 | **추가 라이트** (Point, Spot, 다른 Directional) | 위치가 있고, **멀수록 약해짐** |
| 📸 인물 조명 | **캐릭터 라이트** (이 셰이더 패키지만의 기능) | 캐릭터만 예쁘게 비추는 전용 방향 |

## 2. 추가 라이트 하나 계산하기

[ToonLighting.hlsl L62–72](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonLighting.hlsl#L62-L72)

```hlsl
half3 ShadeAdditionalToon(Light light, half3 N, half3 albedo, half border, half blur)
{
#ifdef _LIGHT_LAYERS
    if (!IsMatchingLightLayer(light.layerMask, GetMeshRenderingLayer()))   // 이름표가 안 맞는 조명은
        return (half3)0.0h;                                                 //   무시 (아래 4절)
#endif
    half nl  = saturate(dot(N, light.direction) * 0.5h + 0.5h);   // 하프 램버트 (Day 06)
    half lit = smoothstep(border - blur, border + blur, nl);       // 같은 계단 (Day 07)
    half atten = light.distanceAttenuation * light.shadowAttenuation;   // 거리 감쇠 × 그림자
    return albedo * light.color * (atten * lit);
}
```

새로 나온 건 `distanceAttenuation` 하나예요. 촛불에 가까이 가면 밝고 멀어지면 어둡죠. 빛의 세기는 대략 **거리의 제곱에 반비례**해서 줄어들어요(2배 멀면 1/4). URP가 이 값을 계산해서 넘겨줘요.

{% hint style="success" %}
보조 조명은 **결과에 더하기만** 해요([L491](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L491) `shaded += addSum * …`). 빛이 안 닿는 쪽은 `lit = 0`이니까 0을 더할 뿐, **어둡게 만들지는 않아요.** 그래서 주인공 조명이 만든 셀 그림자 모양은 그대로 두고, 보조 조명이 닿는 쪽만 그 색으로 밝아져요.
{% endhint %}

## 3. 빛 목록 찾기: Forward vs Forward+

화면에 보조 조명이 50개 있다고 해 봐요. 픽셀마다 50개를 다 계산하면 너무 느려요. **"이 픽셀에 영향 주는 조명만"** 골라야 해요.

| 방식 | 비유 | 특징 |
|---|---|---|
| **Forward** | **물체마다** "너한테 닿는 조명 목록" 쪽지를 줌 | 물체당 조명 개수 제한 있음 (모바일에서 씀) |
| **Forward+** | 화면을 **바둑판(클러스터)** 으로 나누고 **칸마다** 조명 목록을 만듦 | 조명이 많아도 빠름 (PC에서 씀) |

코드는 두 방식을 모두 처리해요. [CharacterToon.shader L475–493](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L475-L493)

```hlsl
#if defined(_ADDITIONAL_LIGHTS) && defined(_USE_ADD_LIGHTS)
{
    InputData inputData = (InputData)0;
    inputData.positionWS = input.positionWS;
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);  // 바둑판 칸 찾기용
    uint addCount = GetAdditionalLightsCount();
#if USE_CLUSTER_LIGHT_LOOP
    // Forward+: 추가 Directional 조명은 바둑판에 안 들어가서 따로 돈다
    for (uint di = 0u; di < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); di++)
        addSum += ShadeAdditionalToon(GetAdditionalLight(di, inputData.positionWS, half4(1,1,1,1)), ...);
#endif
    LIGHT_LOOP_BEGIN(addCount)     // ← Forward면 물체 목록, Forward+면 바둑판 칸 목록을 돈다
        addSum += ShadeAdditionalToon(GetAdditionalLight(lightIndex, inputData.positionWS, half4(1,1,1,1)), ...);
    LIGHT_LOOP_END
    shaded += addSum * _AdditionalLightStrength * aoDirect;
}
#endif
```

- `LIGHT_LOOP_BEGIN` / `LIGHT_LOOP_END`는 URP가 주는 **매크로**예요. 렌더러 설정에 따라 알맞은 반복문으로 바뀌어요. 이 매크로가 `inputData`라는 **이름의 변수**를 읽기 때문에 위에서 그 이름으로 만들어 둬야 해요.
- 해 말고 다른 Directional 조명은 어디에나 닿으니까 바둑판에 넣을 수 없어요. 그래서 Forward+에서는 **앞에서 따로** 한 바퀴 돌아요.
- 배경 셰이더는 같은 코드를 함수로 묶어 써요: [ToonAdditionalLights.hlsl L23–38](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonAdditionalLights.hlsl#L23-L38)

{% hint style="warning" %}
**💡 이 프로젝트에서 실제로 있었던 일 (A5)**
배경 셰이더(SceneToon)는 `GetAdditionalLight(index, positionWS)` — 인자 **2개**짜리 함수를 쓰고 있었어요. 이 버전은 그림자 정보를 안 넣고 `shadowAttenuation = 1`로 고정해요. 그래서 포인트·스폿 조명이 **그림자 없이 물체를 뚫고** 비쳤어요. 게다가 Forward+에서 추가 Directional 조명을 도는 앞쪽 반복문도 빠져 있었어요. 루프를 [ToonAdditionalLights.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonAdditionalLights.hlsl)로 옮기면서 인자 **3개**짜리(세 번째가 shadowMask)를 쓰고 앞쪽 반복문도 넣어 고쳤어요. 캐릭터 셰이더는 원래 3개짜리를 쓰고 있었어요.

![추가 라이트 그림자](../.gitbook/assets/day09-additional-light-shadows.png)
{% endhint %}

## 4. 라이트 레이어 — 이름표가 맞는 조명만

무대에서 "이 조명은 주인공만 비춰", "저 조명은 배경만 비춰"라고 정하고 싶을 때가 있어요. URP는 조명과 물체에 **레이어 이름표**를 붙이고, 이름표가 겹칠 때만 빛을 주게 해요. 이걸 **라이트 레이어**(Rendering Layers)라고 해요.

- 조명의 이름표: `light.layerMask`
- 물체의 이름표: `GetMeshRenderingLayer()`
- 비교: `IsMatchingLightLayer(조명, 물체)`

메인 라이트도 똑같이 확인해요. [L334–337](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L334-L337)

```hlsl
#ifdef _LIGHT_LAYERS
    if (!IsMatchingLightLayer(mainLight.layerMask, GetMeshRenderingLayer())) mainLight.color = (half3)0.0h;
#endif
```

{% hint style="warning" %}
**💡 실제로 있었던 일 (A7)**: 원래 이 셰이더는 라이트 레이어를 무시해서 "구체만 비춰"라고 설정한 빨간 조명이 **바닥까지** 비췄어요. URP Lit 셰이더와 같은 규칙으로 고쳤어요.

![라이트 레이어](../.gitbook/assets/day09-light-layers.png)
{% endhint %}

## 5. 캐릭터 라이트 — C#이 셰이더에 값을 넣는 법

게임에서는 배경 조명과 상관없이 **캐릭터를 늘 예쁜 각도로** 비추고 싶을 때가 많아요. 사진관의 인물 조명처럼요. 이 셰이더 패키지는 `CharacterToonLight` 컴포넌트가 그 방향을 정하고, `CharacterToonManager`가 **셰이더 전체에 공지**해요.

[CharacterToonManager.cs L90–91](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonManager.cs#L90-L91)

```csharp
Shader.SetGlobalVector(IdLightDir, dir0);      // 모든 셰이더의 _CharacterLightDirWS 에 값을 넣는다
Shader.SetGlobalVector(IdLightColor, col0);
```

셰이더 쪽은 **CBUFFER 밖에** 그 이름의 변수를 선언해 두면 받아요. [ToonInput.hlsl L193–203](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L193-L203)

```hlsl
// --- 매 프레임 스크립트가 주입하는 글로벌 (UnityPerMaterial 밖!) ---
float4 _CharacterLightDirWS;
float4 _CharacterLightColor;
#define CHARACTER_EXTRA_LIGHT_MAX 3
float4 _CharacterExtraLightDir[CHARACTER_EXTRA_LIGHT_MAX];   // 2순위 이하 캐릭터 라이트 (최대 3개)
...
```

| 값을 넣는 방법 | 비유 | 범위 |
|---|---|---|
| 머티리얼 프로퍼티 (CBUFFER) | 접시마다 붙인 **개인 메모** | 그 머티리얼만 |
| `Shader.SetGlobal…` | 학교 **전체 방송** | 이 변수를 가진 모든 셰이더 |
| MaterialPropertyBlock | 물체 하나에 붙인 **포스트잇** | 그 렌더러만 (Day 15, 20) |

1순위 캐릭터 라이트는 Day 06에서 본 `L` 고르기에 쓰이고, 2순위부터는 보조 조명처럼 **더해져요**: [ToonLighting.hlsl L85–96](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonLighting.hlsl#L85-L96).

## 6. 해보기 (15분)

1. **거리 감쇠 감각** — 1m에서 밝기 1이면 2m에서는? (약 1/4) 4m에서는? (약 1/16) 보조 조명이 금방 약해지는 이유예요.
2. **더하기 계산** — 그림자 쪽 픽셀(`shaded = 0.3`)에 보조 조명이 `lit = 1`, `atten = 0.5`, 색 (1, 0.2, 0.2), albedo 1로 닿으면? `0.3 + (0.5, 0.1, 0.1) = (0.8, 0.4, 0.4)` — 붉게 밝아져요.
3. **방송 추적** — [CharacterToonManager.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonManager.cs)에서 `SetGlobal`을 검색해 보세요. 각 줄이 [ToonInput.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl#L195-L203)의 어느 변수에 값을 넣는지 연결해 보세요.
4. **w의 의미** — 매니저가 캐릭터 라이트가 없을 때 [L140](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonManager.cs#L140)에서 `w = 0`을 넣어요. 셰이더 [L348](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L348)은 그걸 보고 무엇을 하나요? (메인 라이트로 대신 씀)

## 7. 오늘의 액기스

👉 [ESSENCE.md — Day 09](essence.md#day-09)

## 더 읽을거리

- [LearnOpenGL — Light casters](https://learnopengl.com/Lighting/Light-casters) (거리 감쇠 공식) · [Multiple lights](https://learnopengl.com/Lighting/Multiple-lights) (영어)
- [URP — Forward+ 렌더링 경로](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/rendering/forward-plus-rendering-path.html) · [Rendering Layers](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/features/rendering-layers.html) (영어)
- [Unity — Shader.SetGlobalVector](https://docs.unity3d.com/ScriptReference/Shader.SetGlobalVector.html)
- [Catlike Coding — Rendering 5: Multiple Lights](https://catlikecoding.com/unity/tutorials/rendering/part-5/) (영어)

---

[← Day 08](day08-shadows.md) · [목차](README.md) · [다음: Day 10 →](day10-ambient-gi-ssao.md)
