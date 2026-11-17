# Day 05. 텍스처 입히고 가위로 오리기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-005-MP |
| 목적 | 텍스처를 샘플링해 `_BaseColor`와 곱하고, `clip()`으로 알파가 기준보다 낮은 픽셀을 버린다 |
| 적용 대상 | Unity 6000.3, URP 17.x. Day 04 완료 상태의 `MyToon.shader`, `Assets/Textures/Lab_Base` |
| 소요 시간 | 약 60분 (코드 25분, 설명 15분, 실험 20분) |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리한 것이며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `TEXTURE2D`, `SAMPLER`, `SAMPLE_TEXTURE2D`, `TRANSFORM_TEX` 매크로는 URP(SRP Core) 버전에 따라 정의가 다를 수 있다. URP 버전 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day04-varyings-debug.md](day04-varyings-debug.md) | GMD-TSL-004-MP | 이전: Varyings와 디버그 보기 |
| [day06-first-light.md](day06-first-light.md) | GMD-TSL-006-MP | 다음: 첫 조명 |
| [day09-cast-shadows.md](day09-cast-shadows.md) | GMD-TSL-009-MP | 그림자에도 같은 `clip`을 적용하는 Day |
| [toon-shader-study Day 05](../toon-shader-study/day05-textures-and-uv.md) | - | 텍스처와 UV (짝꿍 과정) |
| [LearnOpenGL Textures](https://learnopengl.com/Getting-started/Textures), [UV mapping](https://en.wikipedia.org/wiki/UV_mapping), [Microsoft clip](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-clip) | - | 샘플러, UV, `clip` 참고 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | `Assets/MyToon/MyToon.shader` | Day 04 완료 상태 | |
| 2 | `Assets/Textures/Lab_Base` | 흰 바탕, 연한 줄무늬, 투명한 원이 있는 PNG | 실습 저장소에 포함 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 텍스처는 숫자가 아니므로 CBUFFER 안에 선언하지 않는다. `_BaseMap_ST`는 CBUFFER 안에 선언한다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Day 04 코드가 컴파일된다 | Console 오류 0건 |
| 2 | `Lab_Base` 텍스처가 있다 | `Assets/Textures`에서 확인한다 |

## 5. 절차

### A. Properties 추가

1. (5-A-01) `_BaseColor` 아래에 두 줄을 추가한다. `"white" {}`는 텍스처를 넣지 않았을 때 흰색(1)을 쓰게 한다. 흰색은 곱해도 변화가 없다. → 결과: Inspector에 `Base Map`과 `Alpha Cutoff` 칸이 나타난다.

```shaderlab
        [MainTexture] _BaseMap ("Base Map", 2D) = "white" {}
        _Cutoff ("Alpha Cutoff", Range(0, 1)) = 0
```

### B. 텍스처 선언과 CBUFFER 수정

텍스처(`TEXTURE2D`)는 이미지 자체이고 샘플러(`SAMPLER`)는 읽는 규칙(확대 시 보간 방식, 가장자리 반복 여부)이다. `_BaseMap_ST`는 Properties에 쓰지 않아도 머티리얼의 `Tiling`, `Offset` 값이 `<텍스처이름>_ST`로 자동으로 들어온다.

1. (5-B-01) `#include` 아래, CBUFFER 위에 텍스처를 선언하고 CBUFFER에 두 줄을 추가한다. → 결과: 컴파일 오류가 없다.

```hlsl
TEXTURE2D(_BaseMap);    SAMPLER(sampler_BaseMap);

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;    // 추가: 타일링(xy)·오프셋(zw). 이름 끝 _ST 는 Unity 가 자동으로 채운다
    half4  _BaseColor;
    half   _Cutoff;        // 추가
    half   _DebugView;
CBUFFER_END
```

### C. vert에 타일링 적용

1. (5-C-01) `o.uv = input.uv;`를 다음으로 바꾼다. `TRANSFORM_TEX(uv, _BaseMap)`은 `uv * _BaseMap_ST.xy + _BaseMap_ST.zw`와 같다. → 결과: 컴파일 오류가 없다.

```hlsl
    o.uv         = TRANSFORM_TEX(input.uv, _BaseMap);   // 타일링·오프셋 적용
```

### D. frag 수정

1. (5-D-01) `frag`를 다음으로 바꾼다. `clip(x)`는 `x`가 0보다 작으면 픽셀을 버린다. 색과 깊이를 남기지 않는다. → 결과: 컴파일 오류가 없다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
    clip(baseColor.a - _Cutoff);   // 투명도가 기준보다 낮으면 이 픽셀을 버린다
    half3 N = normalize(input.normalWS);

    // 디버그 보기: 눈에 안 보이는 값을 색으로 꺼내 본다
    if (_DebugView > 1.5h) return half4(input.uv, 0.0h, 1.0h);
    if (_DebugView > 0.5h) return half4(N * 0.5h + 0.5h, 1.0h);

    return baseColor;
}
```

정답 파일: [`Assets/Solutions/Day05/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day05/MyToon.shader)

### E. 텍스처 연결

1. (5-E-01) 머티리얼 `MyToon`의 `Base Map` 칸에 `Assets/Textures/Lab_Base`를 끌어다 놓는다. → 결과: 물체에 줄무늬가 입혀지고 주황색이 곱해진다.
2. (5-E-02) `Alpha Cutoff`가 0인 상태를 확인한다. → 결과: 구멍이 보이지 않는다.
3. (5-E-03) `Alpha Cutoff`를 0.5로 올린다. → 결과: 텍스처의 투명한 원이 뚫린다.

![Day 05 결과: Alpha Cutoff 0과 0.5](../.gitbook/assets/day05-alpha-clip.png)

### F. 개념 확인

| 텍스처 알파 | Base Color 알파 | Cutoff | `a - Cutoff` | 결과 |
|---|---|---|---|---|
| 1.0 | 1.0 | 0.5 | +0.5 | 남긴다 |
| 0.0 (구멍) | 1.0 | 0.5 | -0.5 | 버린다 |
| 0.0 (구멍) | 1.0 | 0 | 0 | 남긴다 (0은 음수가 아니다) |

- UV는 전개도 좌표다. 해상도와 관계없이 범위가 0~1이다.
- Cutoff 기본값을 0으로 두면 아무것도 오려지지 않는다. 기본값이 효과 없음이 되도록 정한다.

{% hint style="info" %}
NOTE: 이 Day의 셰이더에는 그림자를 드리우는 패스가 없어 바닥에 물체 그림자가 생기지 않는다. Day 09에서 패스를 추가하고 그림자에도 같은 구멍이 뚫리게 한다(GMD-TSL-009-MP).
{% endhint %}

### G. 실험

1. (5-G-01) `Base Map`의 `Tiling`을 (3, 3)으로 바꾼다. → 결과: 무늬가 촘촘해진다. `Debug View = UV`에서는 UV 값이 0~3이 되어 색이 1을 넘어 노랗게 뭉개진다.
2. (5-G-02) `Alpha Cutoff` 0.5에서 `Base Color`의 A를 0.4로 내린다. → 결과: 알파가 곱해져 모든 픽셀이 0.5 미만이 되어 물체가 사라진다.
3. (5-G-03) `Base Map`을 비운다(None). → 결과: 흰 텍스처가 쓰여 Day 04처럼 단색이 된다.
4. (5-G-04) 커밋한다: `git commit -am "Day 05: 텍스처와 알파 클립"`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `Alpha Cutoff = 0` | 구멍 없이 줄무늬 | 투명 원이 안 보인다 |
| 2 | `Alpha Cutoff = 0.5` | 투명 원이 뚫린다 | 뒤 배경이 보인다 |
| 3 | `Base Map = None` | 단색 | `Base Color`와 일치 |

## 7. 복구

1. (7-01) 변경을 되돌린다: `Ctrl+Z` 또는 `git restore Assets/MyToon/MyToon.shader`.
2. (7-02) 머티리얼 값을 되돌린다: `Alpha Cutoff` 0, `Base Color` A 1, `Tiling` (1, 1).

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 Day 05 페이지를 AMM 형식으로 재작성. 비유 삭제 |

[← Day 04](day04-varyings-debug.md) · [목차](README.md) · [다음: Day 06 →](day06-first-light.md)
