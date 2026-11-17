# Day 03. 머티리얼에서 색 고르기 — Properties와 CBUFFER

> ⏱ **약 1시간** — 코드 20분 · 설명 20분 · 실험 20분
> 🧸 **오늘의 비유**: `Properties`는 **재료 목록**(인스펙터에 보이는 칸), `CBUFFER`는 그 값을 GPU에 보내는 **택배 상자**예요.

![Day 03 결과](../.gitbook/assets/day03-materials.png)

## 오늘 만들 것

코드에 박혀 있던 주황색을 **머티리얼 인스펙터에서 고르는 색**으로 바꿔요. 그러면 셰이더 하나로 빨강·초록·파랑 머티리얼을 따로 만들 수 있어요.

## 오늘 배울 것

- [ ] `Properties` 블록으로 인스펙터 칸을 만든다
- [ ] 같은 이름의 변수를 `CBUFFER_START(UnityPerMaterial)`에 선언한다
- [ ] 셰이더 하나로 머티리얼 여러 개를 만드는 이유를 안다
- [ ] SRP Batcher 호환 여부를 확인할 수 있다

---

## 1. 숨쉬기 되돌리기

Day 02의 실험을 정리해요. `vert` 안을 원래의 한 줄로 되돌려요. (`Attributes`의 `normalOS`는 Day 04에 다시 쓰니까 **그대로 둬요.**)

```hlsl
Varyings vert(Attributes input)
{
    Varyings o = (Varyings)0;
    o.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    return o;
}
```

## 2. 재료 목록 만들기: Properties

`Shader "MyToon/Toon"` 바로 아래, `SubShader` **위에** 추가해요.

```shaderlab
Shader "MyToon/Toon"
{
    Properties
    {
        [MainColor] _BaseColor ("Base Color", Color) = (1, 0.55, 0.3, 1)
    }

    SubShader
    ...
```

한 줄은 이렇게 읽어요.

```
[꾸밈] 변수이름 ("인스펙터에 보일 이름", 종류) = 기본값
```

- `Color` → 색 고르는 칸. `Range(0, 1)` → 슬라이더, `Float` → 숫자, `2D` → 텍스처 (내일부터 나와요)
- `[MainColor]` → "이게 이 머티리얼의 대표 색이에요" 표시. C#에서 `material.color`로 접근할 때 이 칸을 써요.
- 변수 이름은 관례상 `_`로 시작해요.

## 3. GPU에 값 보내기: CBUFFER

`#include` 줄 **아래**, `struct Attributes` **위에** 추가해요.

```hlsl
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
CBUFFER_END
```

그리고 `frag`가 그 값을 돌려주게 바꿔요.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    return _BaseColor;
}
```

{% hint style="warning" %}
`Properties`에 적은 이름과 HLSL 변수 이름이 **글자 하나까지 같아야** 연결돼요. `_BaseColor`와 `_Basecolor`는 남남이에요. 이름이 틀리면 오류는 안 나지만 값이 안 들어와서 검정(0)이 돼요. 가장 찾기 어려운 실수 1위예요.
{% endhint %}

### 왜 CBUFFER에 넣을까? — SRP Batcher

머티리얼마다 다른 숫자들을 **한 상자(UnityPerMaterial)** 에 모아 두면, URP의 **SRP Batcher**가 그 상자를 GPU 창고에 미리 올려 두고 그릴 때는 "3번 상자 써" 하고 번호만 불러요. 그래서 머티리얼이 많아도 빨라요.

**확인**: Project 창에서 `MyToon.shader`를 클릭하면 Inspector에 **SRP Batcher: compatible**라고 나와요. 머티리얼 값을 상자 밖에 선언하면 이 표시가 compatible이 아니게 바뀌어요.

정답: [`Assets/Solutions/Day03/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day03/MyToon.shader)

## 4. 실험해 보기 (20분)

1. **머티리얼 세 개** — `MyToon` 머티리얼을 선택하고 `Ctrl+D`로 두 번 복제해 `MyToon_Red`, `MyToon_Green`, `MyToon_Blue`를 만들어요. 색을 고르고 물체마다 다른 머티리얼을 입혀 보세요(맨 위 그림). **셰이더는 하나, 머티리얼은 셋**이에요. 다 끝나면 다시 `MyToon` 하나로 통일해 두세요.
2. **밝기 슬라이더 추가** — 직접 해 보세요.
   - Properties: `_Brightness ("Brightness", Range(0, 2)) = 1`
   - CBUFFER: `half _Brightness;`
   - frag: `return half4(_BaseColor.rgb * _Brightness, _BaseColor.a);`
   - 슬라이더를 움직여 보고 확인이 끝나면 지워요(정답 코드에는 없어요).
3. **상자 밖에 두기** — `half4 _BaseColor;`를 `CBUFFER_END` 아래로 옮기면 Inspector의 SRP Batcher 표시가 compatible에서 바뀌어요(옆에 나오는 이유 문구는 Unity 버전마다 달라요). 확인 후 되돌려요.
4. 커밋: `git commit -am "Day 03: Properties와 CBUFFER"`

## 5. 오늘의 액기스

👉 [ESSENCE.md — Day 03](essence.md#day-03)

## 더 읽을거리

- [Unity — Properties 블록](https://docs.unity3d.com/Manual/SL-Properties.html) · [SRP Batcher](https://docs.unity3d.com/Manual/SRPBatcher.html)
- 더 깊이: [toon-shader-study Day 03 — 셰이더 파일의 뼈대](../toon-shader-study/day03-shaderlab-skeleton.md) · [Day 20 — 성능 (SRP Batcher)](../toon-shader-study/day20-performance.md)

---

[← Day 02](day02-vertex-shader.md) · [목차](README.md) · [다음: Day 04 →](day04-varyings-debug.md)
