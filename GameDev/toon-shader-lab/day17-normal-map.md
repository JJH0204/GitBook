# Day 17. 노멀맵 — 빛에게만 하는 거짓말

> ⏱ **약 1시간** — 개념 20분 · 코드 20분 · 실험 20분
> 🧸 **오늘의 비유**: 노멀맵은 **평평한 벽에 붙인 요철 벽지**예요. 모양은 그대로인데 빛에게만 "여기 울퉁불퉁해요"라고 거짓말을 해요.

![Day 17 결과](../.gitbook/assets/day17-normal-map.png)

## 오늘 만들 것

매끈한 물체 표면에 **벽돌 홈**이 생긴 것처럼 음영이 져요(오른쪽). 점은 하나도 늘지 않았어요.

## 오늘 배울 것

- [ ] 노멀맵이 화살표를 색으로 저장한다는 걸 안다
- [ ] 탄젠트 공간(T, B, N)을 안다
- [ ] 메시의 `TANGENT`를 받아 노멀맵을 월드로 바꾼다

---

## 1. 노멀맵 (개념 20분)

노멀맵은 화살표 `(x, y, z)`를 색 `(r, g, b)`로 저장해요. 화살표는 -1~1, 색은 0~1이라 바꿔서 저장해요.

```
저장: 색 = 화살표 × 0.5 + 0.5
읽기: 화살표 = 색 × 2 - 1       ← UnpackNormal 이 해 줘요
```

평평한 곳은 노멀이 "바로 위" `(0, 0, 1)` → 색 `(0.5, 0.5, 1)` = **연보라**. 그래서 노멀맵은 보라색이에요. `Assets/Textures/Lab_Normal`을 열어 보세요.

### 탄젠트 공간 = 표면 위의 작은 지도

노멀맵의 화살표는 **표면 기준**이에요.

| 축 | 이름 | 뜻 |
|---|---|---|
| T | 탄젠트 | 텍스처 u가 커지는 방향 (지도의 동쪽) |
| B | 바이탄젠트 | v가 커지는 방향 (지도의 북쪽) |
| N | 노멀 | 표면 바깥 (하늘) |

이 세 화살표로 **기계(3×3 행렬)** 를 만들어 노멀맵 화살표를 월드로 옮겨요. T는 메시가 `TANGENT` 칸에 갖고 있고, B는 N과 T에 모두 수직이니 **외적**(`cross`)으로 만들어요.

## 2. 코드 고치기 (20분)

### ① Properties (`_Cutoff` 아래)

```shaderlab

        [Header(Normal Map)]
        [Normal] _BumpMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Normal Strength", Range(0, 2)) = 1
```

`"bump"` 기본값 = 평평한 노멀맵 (0.5, 0.5, 1). 안 넣으면 효과 없음.

### ② 텍스처 선언 + CBUFFER

```hlsl
        TEXTURE2D(_BumpMap);    SAMPLER(sampler_BumpMap);     // HLSLINCLUDE, _BaseMap 아래
```

```hlsl
            half   _BumpScale;                                // CBUFFER, _Cutoff 아래
```

### ③ 택배 상자

```hlsl
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;    // ← 추가: xyz = 탄젠트, w = 거울 UV 부호
                float2 uv         : TEXCOORD0;
            };
```

```hlsl
                half4  tangentWS  : TEXCOORD4;   // xyz = 탄젠트, w = 바이탄젠트 방향(+1/-1)   ← Varyings 에 추가
```

### ④ vert (`o.normalWS` 줄 아래)

```hlsl
                float3 tangentWS = TransformObjectToWorldDir(input.tangentOS.xyz);
                o.tangentWS  = half4(tangentWS, input.tangentOS.w * GetOddNegativeScale());
```

`tangentOS.w`는 UV를 거울처럼 뒤집어 펼친 곳에서 B의 방향을 뒤집는 ±1이에요. `GetOddNegativeScale()`은 물체를 음수 크기로 뒤집었을 때 한 번 더 바로잡아요.

### ⑤ frag (`half3 N = normalize(...)` 바로 아래)

```hlsl
                half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uv), _BumpScale);
                half3 T = normalize(input.tangentWS.xyz);
                half3 B = cross(N, T) * input.tangentWS.w;
                N = normalize(mul(normalTS, half3x3(T, B, N)));   // 표면 지도(탄젠트 공간) → 월드
```

그 아래의 모든 계산(빛, 림, 반짝임, MatCap)이 **바뀐 N**을 쓰니까 전부 울퉁불퉁하게 반응해요.

### ⑥ 텍스처 넣기

머티리얼 **Normal Map** 칸에 `Assets/Textures/Lab_Normal`을 넣어요. (텍스처 Inspector의 Texture Type이 **Normal map**인지 확인 — 이미 그렇게 설정돼 있어요.)

정답: [`Assets/Solutions/Day17/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day17/MyToon.shader)

## 3. 확인하기

물체에 **벽돌 홈**이 음영과 하이라이트로 드러나요. Debug View를 **Normal**로 바꾸면 노멀 색이 벽돌 모양으로 흔들리는 게 보여요(Day 04의 돋보기 활약!).

## 4. 실험해 보기 (20분)

1. **세기** — Normal Strength 0이면 평평, 2면 더 깊은 홈.
2. **노멀맵 색 해석** — 색 (1, 0.5, 0.5)는 어떤 화살표? (`(1, 0, 0)` — 완전히 오른쪽으로 누운 노멀)
3. **외곽선은?** — 외곽선 패스는 노멀맵을 안 써서(메시 노멀로 밀어요) 테두리는 매끈해요. 노멀맵은 **빛에게만** 하는 거짓말이라 실루엣은 안 바뀐다는 증거예요.
4. 커밋: `git commit -am "Day 17: 노멀맵"`

## 5. 오늘의 액기스

👉 [ESSENCE.md — Day 17](essence.md#day-17)

## 수학 참고 자료

- [LearnOpenGL — Normal Mapping](https://learnopengl.com/Advanced-Lighting/Normal-Mapping) — 탄젠트 공간 그림
- 🎥 [3Blue1Brown — 외적](https://www.3blue1brown.com/lessons/cross-products) · [위키백과 — 벡터곱](https://ko.wikipedia.org/wiki/%EB%B2%A1%ED%84%B0%EA%B3%B1)
- [Wikipedia — Normal mapping](https://en.wikipedia.org/wiki/Normal_mapping) · [Catlike Coding — Bumpiness](https://catlikecoding.com/unity/tutorials/rendering/part-6/)
- 더 깊이: [toon-shader-study Day 16 — 노멀맵과 미분](../toon-shader-study/day16-normal-maps-and-derivatives.md) (탄젠트가 없을 때 `ddx/ddy`로 만드는 방법)

---

[← Day 16](day16-matcap.md) · [목차](README.md) · [다음: Day 18 →](day18-keywords.md)
