# Day 07. 툰 셰이딩의 심장 — 미끄럼틀을 계단으로

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-008-DO |
| 유형 | D&O (개념) + 코드 읽기·실습 |
| 목적 | `lightVal`을 `smoothstep`으로 계단화해 1차·2차 그림자 밴드와 그림자 틴트를 만드는 방법을 설명한다 |
| 소요 시간 | 약 1시간 (읽기 25분, 코드 읽기 20분, 실습 15분) |
| 선수 지식 | Day 06 (`lightVal`, 하프 램버트) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

비유: 실사 빛은 미끄럼틀이고 툰 빛은 계단이다. `smoothstep`은 계단 모서리를 다듬는 사포다.

## 학습 목표

- [ ] `step`과 `smoothstep`의 차이를 그래프로 안다
- [ ] Border(경계 위치)와 Blur(경계 부드러움)가 무엇을 바꾸는지 안다
- [ ] 1차·2차 그림자 밴드가 `lerp`로 섞이는 과정을 따라갈 수 있다
- [ ] 그림자 색을 회색이 아니라 틴트로 곱하는 이유를 안다
- [ ] Ramp 텍스처 방식이 무엇인지 안다

## 1. 정의

툰 셰이딩은 연속 값 `lightVal`(0~1)을 몇 단계의 불연속 값으로 바꾸어 만화 같은 명암을 만드는 기법이다. 이 셰이더는 `step`의 날카로운 경계를 `smoothstep`으로 다듬은 밴드를 두 겹(1차, 2차 그림자) 쌓는다. 그림자 색은 바탕색에 틴트를 곱해 만든다.

## 2. 구성 요소

| 구성 요소 | 역할 | 기본값 (소스 기준) |
|---|---|---|
| `step(a, x)` | `x ≥ a`이면 1, 아니면 0 | — |
| `smoothstep(a, b, x)` | `x ≤ a`이면 0, `x ≥ b`이면 1, 사이는 S자 곡선 | — |
| Border | 계단 위치. 0.5이면 빛과 직각인 곳에서 그림자가 시작된다 | 1차 0.5, 2차 0.25 |
| Blur | 계단 모서리의 반폭. 0.01이면 칼같이, 0.25이면 흐릿하게 | — |
| `_ShadowStrength` | 그림자 전체 세기. 0이면 그림자가 없다 | — |
| `_ShadowColor`, `_Shadow2ndColor` | 1차·2차 그림자 틴트 | 1차 (0.72, 0.74, 0.82) |
| `shadeMask` | 그림자 정도 기록. Day 10에서 환경광 가중에 쓴다 | — |

## 3. 동작 원리

### 3.1 step에서 smoothstep으로

`step`은 경계가 날카로워 화면에서 톱니처럼 깨진다(앨리어싱). `smoothstep`은 두 경계 `a`, `b` 사이를 S자로 잇는다. 이 셰이더는 두 경계를 다음처럼 정한다.

```
a = Border - Blur,   b = Border + Blur
```

![smoothstep과 Blur](../.gitbook/assets/concept-smoothstep-blur.png)

`smoothstep` 내부 수식은 다음과 같다.

```
t = saturate((x - a) / (b - a))     // a~b 사이에서 0~1 로 늘이기
결과 = t × t × (3 - 2 × t)          // S자로 휘기
```

{% hint style="warning" %}
CAUTION: Blur가 0이면 `a = b`가 되어 `(b - a) = 0`으로 나눈다. HLSL에서 `a ≥ b`일 때 `smoothstep`의 결과는 정의되지 않으며 NaN 또는 불연속이 나올 수 있다. 그래서 코드는 `max(Blur, 1e-4)`로 바닥을 깐다. [CharacterToon.shader L434–435](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L434-L435) · [ToonBandShadow.hlsl L13](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonBandShadow.hlsl#L13)
{% endhint %}

{% hint style="warning" %}
CAUTION: 프로젝트 이력(C4). 림 라이트의 `_RimSoftness`와 스펙큘러의 `_SpecularStep`에는 이 바닥이 없어서 슬라이더를 0으로 내리면 해당 부분이 깨졌다. 같은 바닥을 추가해 고쳤다([L499](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L499), [L595](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L595)).
{% endhint %}

### 3.2 그림자 두 칸

만화 그림자는 보통 두 단계다. 살짝 어두운 1차 그림자와 그 안쪽의 진한 2차 그림자다. 2차 Border(0.25)가 1차 Border(0.5)보다 작으므로 2차 그림자는 더 깊은 그림자 안쪽에만 생긴다.

| 단계 | 계산 | 의미 |
|---|---|---|
| 1 | `smoothstep(Border-Blur, Border+Blur, lightVal)` | 빛 쪽인 정도 |
| 2 | `1 - (1단계)` | 그림자 쪽인 정도 |
| 3 | `× _ShadowStrength` | 그림자 세기 적용 |
| 4 | 밝은 색에서 시작해 1차 색을 `lerp`, 그 위에 2차 색을 `lerp` | 색 덧칠 |
| 5 | `shadeMask = saturate(max(shadow1, shadow2))` | 그림자 정도 기록 |

![툰 밴드](../.gitbook/assets/concept-toon-bands.png)

그림에서 Blur를 줄이면 경계가 칼같아지고, 1차 Border를 올리면 그림자 영역이 넓어진다. 이 두 슬라이더가 캐릭터 인상을 크게 바꾼다.

### 3.3 그림자 색은 곱하기 틴트

그림자를 검정이나 회색과 섞지 않고 `바탕색 × 그림자 틴트`로 만든다.

| 바탕색 | 틴트 | 결과 | 비고 |
|---|---|---|---|
| (1, 0.2, 0.2) 빨강 | (0.72, 0.74, 0.82) | (0.72, 0.148, 0.164) | 같은 계열의 어두운 빨강 |
| (1, 0.2, 0.2) 빨강 | 회색을 섞음 | 탁한 회색빛 빨강 | 채도가 떨어진다 |

틴트의 파란 값(0.82)이 빨강·초록보다 커서 그림자가 약간 차갑게 보인다. 이는 만화에서 그림자에 같은 계열의 푸르스름한 색을 쓰는 관행과 같다.

### 3.4 Ramp 텍스처 방식

공식 대신 그라데이션 텍스처 한 장으로 그림자 색을 정할 수 있다. 가로가 빛 값(0~1), 세로가 재질 종류인 작은 이미지이며 Ramp LUT(색 사전)라고 한다. `lightVal`을 U 좌표, `_RampRow`를 V 좌표로 쓴다. 화가가 그림자 색을 직접 그릴 수 있는 것이 장점이다. 이 패키지는 기본으로 슬라이더 방식(1·2차 밴드)을 쓰고 `_USE_RAMP`를 켜면 Ramp 방식으로 바뀐다.

## 4. 코드 읽기

### 4.1 캐릭터의 그림자 밴드

[CharacterToon.shader L433–447](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L433-L447) (얼굴 SDF 부분은 Day 15에서 다룬다)

```hlsl
half blur1 = max(_ShadowBlur,    1e-4h);
half blur2 = max(_Shadow2ndBlur, 1e-4h);
// 그림자 정도 = 1 - (빛 정도)
half shadow1Band = (1.0h - smoothstep(_ShadowBorder    - blur1, _ShadowBorder    + blur1, lightVal)) * _ShadowStrength;
half shadow2Band = (1.0h - smoothstep(_Shadow2ndBorder - blur2, _Shadow2ndBorder + blur2, lightVal)) * _ShadowStrength;
...
shadedAlbedo = baseColor.rgb;                                                     // 밝은 색에서 시작
shadedAlbedo = lerp(shadedAlbedo, baseColor.rgb * _ShadowColor.rgb,    shadow1);  // 1차 그림자 색 덧칠
shadedAlbedo = lerp(shadedAlbedo, baseColor.rgb * _Shadow2ndColor.rgb, shadow2);  // 2차 그림자 색 덧칠
shadeMask = saturate(max(shadow1, shadow2));                                       // "얼마나 그림자인가" 기록
```

| 줄 | 설명 |
|---|---|
| `blur1`, `blur2` | Blur 바닥 `1e-4`로 0 나누기를 막는다 |
| `shadow1Band`, `shadow2Band` | `smoothstep`을 뒤집어 그림자 정도로 바꾸고 세기를 곱한다 |
| `lerp(A, B, t)` | `A*(1-t) + B*t`. `shadow1 = 1`이면 1차 색 100%, 0.3이면 30% 섞인다 |
| `shadeMask` | Day 10에서 그림자 쪽에 환경광을 덜 더하는 데 쓴다 |

### 4.2 Ramp 방식

[CharacterToon.shader L426–431](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L426-L431)

```hlsl
#if defined(_USE_RAMP)
    half rampVal = lerp(lightVal, faceLit, sdfApply);
    half3 ramp = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, half2(rampVal, _RampRow)).rgb;
    shadedAlbedo = baseColor.rgb * ramp;
```

### 4.3 배경 셰이더도 같은 식

[ToonBandShadow.hlsl L11–32](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonBandShadow.hlsl#L11-L32)

```hlsl
half ToonBandFactor(half lightVal, half border, half blur, half strength)
{
    half b = max(blur, 1e-4h);
    return (1.0h - smoothstep(border - b, border + b, lightVal)) * strength;
}

half3 ToonShadeBands(half3 albedo, half lightVal, ..., out half shadeMask)
{
    half s1 = ToonBandFactor(lightVal, border1, blur1, strength);
    half s2 = ToonBandFactor(lightVal, border2, blur2, strength);
    half3 c = albedo;
    c = lerp(c, albedo * shadowColor1, s1);
    c = lerp(c, albedo * shadowColor2, s2);
    shadeMask = saturate(max(s1, s2));
    return c;
}
```

캐릭터 코드와 같은 계산을 함수로 묶은 것이다. `out half shadeMask`는 반환값 외에 값 하나를 더 밖으로 내보내는 출력 매개변수다. 캐릭터와 배경의 그림자 톤이 같아야 한 화면에서 어색하지 않다.

## 5. 주의

{% hint style="info" %}
NOTE: `smoothstep(a, b, x)`는 `a < b`를 전제로 한다. Border와 Blur를 슬라이더로 노출할 때는 항상 Blur 바닥을 둔다.
{% endhint %}

- Border는 `lightVal`의 범위(0~1) 안에 있어야 의미가 있다. 2차 Border를 1차보다 크게 두면 2차 그림자가 1차보다 먼저 생겨 의도와 다른 색 순서가 된다.
- 틴트는 `0~1` 범위에서 1보다 작게 둔다. 1보다 크면 그림자가 바탕색보다 밝아진다.

## 6. 실습

1. `smoothstep`을 손으로 계산한다. `lightVal = 0.55`, Border 0.5, Blur 0.1이면 `a = 0.4`, `b = 0.6`, `t = (0.55 - 0.4) / 0.2 = 0.75`다. → 결과: `smoothstep = 0.75² × (3 - 1.5) = 0.844`, `shadow1 = 1 - 0.844 = 0.156`이다. 1차 그림자 색이 15.6%만 섞인다.
2. Blur를 0.01로 바꿔 계산한다. `a = 0.49`, `b = 0.51`이고 `x = 0.55 > b`이다. → 결과: `smoothstep = 1`, `shadow1 = 0`이다. Blur가 작으면 경계 근처 값이 급격히 갈린다.
3. [Desmos](https://www.desmos.com/calculator)에 아래를 입력하고 `B`(Border), `b`(Blur) 슬라이더를 움직인다. → 결과: Blur가 작을수록 S자가 가파라진다.
   ```
   s(x) = \min(\max((x-(B-b))/(2b), 0), 1)
   y = s(x)^2 (3 - 2s(x))
   ```
4. (Unity가 있다면) 샘플 머티리얼의 Shadow Border 1st와 Shadow Blur 1st 슬라이더를 움직인다. → 결과: 그림의 밴드처럼 경계 위치와 부드러움이 바뀐다. 값을 바꾸기 전에 머티리얼 설정을 기록해 두고 Ctrl+Z 또는 기록한 값으로 되돌린다.

## 7. 참조

- [The Book of Shaders — 5장 Shaping Functions (한국어)](https://thebookofshaders.com/05/?lan=kr)
- [Wikipedia — Smoothstep](https://en.wikipedia.org/wiki/Smoothstep) (영어)
- [Microsoft — smoothstep](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-smoothstep) · [lerp](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-lerp)
- [Wikipedia — Linear interpolation](https://en.wikipedia.org/wiki/Linear_interpolation) · [Cel shading](https://en.wikipedia.org/wiki/Cel_shading) (영어)
- [Desmos 그래프 계산기](https://www.desmos.com/calculator)
- 오늘의 요약: [ESSENCE.md — Day 07](essence.md#day-07)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `step` 대신 `smoothstep`을 쓰는 이유를 적는다.
- [ ] 그림자 색을 회색이 아니라 "바탕색 × 틴트"로 만드는 이유를 적는다.
- [ ] 좋아하는 만화나 게임 캐릭터의 그림자가 몇 단계인지 관찰해 적는다.

---

[← Day 06](day06-vectors-and-light.md) · [목차](README.md) · [다음: Day 08 →](day08-shadows.md)
