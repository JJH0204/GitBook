# Day 08. 그림자 — 빛의 자리에서 찍은 사진

> ⏱ **약 1시간** — 읽기 25분 · 코드 따라 읽기 20분 · 해보기 15분
> 🧸 **오늘의 비유**: 섀도맵은 **빛이 자기 자리에서 찍어 둔 거리 사진**이에요.

## 오늘 배울 것

- [ ] "모양 그림자"와 "드리운 그림자"의 차이를 안다
- [ ] 섀도맵이 어떻게 그림자를 판정하는지 설명할 수 있다
- [ ] ShadowCaster 패스의 역할과 `ApplyShadowBias`가 필요한 이유를 안다
- [ ] 툰 셰이더가 드리운 그림자를 셀 밴드에 합치는 방법을 안다

---

## 1. 그림자는 두 종류

| | 모양 그림자 (Self Shading) | 드리운 그림자 (Cast Shadow) |
|---|---|---|
| 뜻 | 빛 반대편을 향한 면이 어두운 것 | **다른 물체가 빛을 가려서** 생긴 그림자 |
| 예 | 공의 아래쪽 절반 | 나무 아래 바닥, 모자 챙 아래 얼굴 |
| 계산 | `dot(N, L)` — Day 06~07 | **섀도맵** — 오늘 |

`dot(N, L)`은 내 표면의 방향만 봐요. 내 앞에 **누가 서 있는지는 몰라요.** 그래서 드리운 그림자는 다른 방법이 필요해요.

## 2. 섀도맵 = 빛이 찍은 거리 사진

![섀도맵 원리](../.gitbook/assets/concept-shadow-map.png)

1. **빛의 자리에 카메라를 놓고** 장면을 찍어요. 단, 색이 아니라 **"가장 가까운 물체까지의 거리"** 만 기록해요. 이게 섀도맵이에요.
2. 진짜 카메라로 화면을 그릴 때, 픽셀마다 "빛에서 나까지의 거리"를 계산해요.
3. 그 거리를 섀도맵의 값과 비교해요.
   - 섀도맵 값과 **같으면** → 빛에서 가장 가까운 게 나 → **빛 받음**
   - 섀도맵 값보다 **멀면** → 나보다 가까운 누군가가 빛을 가림 → **그림자**

햇빛 아래 줄을 선 아이들을 생각해 보세요. 해 쪽에서 보면 맨 앞 아이만 보여요. 뒤에 선 아이들은 맨 앞 아이보다 "멀리" 있으니까 그림자 속이에요.

## 3. ShadowCaster 패스 — 사진 찍히는 담당

1단계(빛 자리에서 찍기)에서 URP는 모든 물체의 **ShadowCaster 패스**를 불러요.

[CharacterToon.shader L752–824](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L752-L824)

```shaderlab
Pass
{
    Name "ShadowCaster"
    Tags { "LightMode" = "ShadowCaster" }
    ZWrite On          // 거리(깊이)를 기록
    ZTest LEqual
    ColorMask 0        // 색은 안 씀 — 거리 사진이니까
    Cull [_Cull]
```

버텍스 셰이더의 핵심은 [L789–808](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L789-L808)이에요.

```hlsl
float4 GetShadowPositionHClip(Attributes input)
{
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    float3 normalWS   = TransformObjectToWorldNormal(input.normalOS);
#if defined(_CASTING_PUNCTUAL_LIGHT_SHADOW)
    float3 lightDirectionWS = normalize(_LightPosition - positionWS);   // 포인트/스폿: 빛 위치에서 방향 계산
#else
    float3 lightDirectionWS = _LightDirection;                          // 해: 모두 같은 방향
#endif
    float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
    ...
}
```

### 왜 `ApplyShadowBias`가 필요할까? — 그림자 여드름

섀도맵은 픽셀로 된 **사진**이라 해상도가 한정돼요. 비스듬한 면은 한 섀도맵 픽셀 안에서도 거리가 조금씩 달라서, **자기 자신을 가린다고 착각**해요. 그러면 표면에 줄무늬·점무늬 그림자가 생겨요. 이걸 **그림자 여드름**(shadow acne)이라고 해요.

`ApplyShadowBias`는 사진 찍을 때 표면을 **빛 쪽과 노멀 쪽으로 살짝 밀어서** 이 착각을 막아요. 너무 많이 밀면 그림자가 물체에서 떨어져 보이니까(피터팬 현상) 적당히 밀어요. 값은 Light 컴포넌트의 Bias 설정에서 와요.

### 텍스처 구멍도 그림자에 반영

[L818–822](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L818-L822)

```hlsl
half4 frag(Varyings input) : SV_TARGET
{
    ClipToonSurface(input.uv);   // 오려 낸 곳은 그림자도 안 생김 (Day 05)
    return 0;
}
```

## 4. 받는 쪽: 그림자 정도 읽기

2단계(화면 그리기)는 ForwardToon 패스에서 해요. [L332–333](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L332-L333)

```hlsl
float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);   // 이 픽셀의 '섀도맵 위 주소'
Light mainLight = GetMainLight(shadowCoord);                          // 그림자 비교 결과가 담긴 빛 정보
```

`mainLight.shadowAttenuation`에 결과가 들어 있어요. **1이면 빛, 0이면 그림자**예요.

관련 키워드(Day 19)도 알아 두세요. [L215–216](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L215-L216)

| 키워드 | 뜻 |
|---|---|
| `_MAIN_LIGHT_SHADOWS` | 해의 그림자 켜짐 |
| `_MAIN_LIGHT_SHADOWS_CASCADE` | **캐스케이드**: 가까운 곳은 촘촘한 지도, 먼 곳은 듬성한 지도를 따로 씀 |
| `_MAIN_LIGHT_SHADOWS_SCREEN` | 그림자를 화면 단위로 미리 계산해 둠 |
| `_SHADOWS_SOFT` | 그림자 가장자리를 여러 번 비교해 부드럽게 |

## 5. 툰 셰이더의 비결: 같은 계단에 합치기

드리운 그림자를 그냥 색에 곱하면 그림자 속이 **새까맣게** 되거나 셀 그림자와 **다른 색**이 돼요. 이 셰이더는 그림자 결과를 **`lightVal`에 곱해서** Day 07의 계단에 넣어요.

[L408–410](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L408-L410)

```hlsl
half rcvShadow = lerp(1.0h, mainLight.shadowAttenuation, _ReceiveShadowStrength);
lightVal *= rcvShadow;     // 그림자 속이면 lightVal 이 0 쪽으로 → 계단에서 그림자 색으로
faceLit  *= rcvShadow;     // 얼굴 SDF 값에도 똑같이 (Day 15)
```

그러면 드리운 그림자도 **같은 1차·2차 그림자 색**으로 칠해져요. 만화에서 모자 그림자와 얼굴 음영이 같은 색인 것처럼요.

`_ReceiveShadowStrength`(Receive Cast Shadow 슬라이더)는 "드리운 그림자를 얼마나 받을까"예요. 0이면 다른 물체 그림자를 무시해요.

{% hint style="warning" %}
**💡 이 프로젝트에서 실제로 있었던 일 (B6)**
반짝이는 하이라이트(스펙큘러, Day 17)는 이 `rcvShadow`를 안 곱하고 있었어요. 그래서 **그림자 속에서도 반짝임이 둥둥 떠 있었어요**. 하이라이트에도 `rcvShadow`를 곱해서 고쳤어요([L600](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L600)).

![그림자 속 하이라이트](../.gitbook/assets/day08-specular-in-shadow.png)
{% endhint %}

## 6. 해보기 (15분)

1. **섀도맵 판정** — 섀도맵에 적힌 거리가 5m, 내 픽셀의 빛까지 거리가 5.0m면 빛, 7m면? (그림자) 4.98m면? (빛 — 바이어스 덕분에 오차를 봐줌)
2. **rcvShadow 계산** — `shadowAttenuation = 0`(완전 그림자), `_ReceiveShadowStrength = 0.6`이면 `rcvShadow = lerp(1, 0, 0.6) = 0.4`. `lightVal = 0.9`였다면 `0.36`이 돼요. Border 0.5보다 작으니 1차 그림자 쪽, Border 0.25보다는 크니 2차는 아직이에요.
3. **배경도 같을까?** — [SceneToon.shader L242–243](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon.shader#L242-L243)을 열어 같은 방식인지 확인해 보세요.
4. **(Unity가 있다면)** 캐릭터 위에 큐브를 띄우고 Receive Cast Shadow를 0 ↔ 1로 움직여 보세요.

## 7. 오늘의 액기스

👉 [ESSENCE.md — Day 08](essence.md#day-08)

## 더 읽을거리

- [LearnOpenGL — Shadow Mapping](https://learnopengl.com/Advanced-Lighting/Shadows/Shadow-Mapping) — 그림자 여드름, 피터팬 현상을 그림으로 보여 줘요. (영어)
- [Wikipedia — Shadow mapping](https://en.wikipedia.org/wiki/Shadow_mapping) · [Z-buffering](https://en.wikipedia.org/wiki/Z-buffering) (영어)
- [Catlike Coding — Rendering 7: Shadows](https://catlikecoding.com/unity/tutorials/rendering/part-7/) — Unity에서 섀도맵을 단계별로 (영어)

---

[← Day 07](day07-toon-steps.md) · [목차](README.md) · [다음: Day 09 →](day09-many-lights.md)
