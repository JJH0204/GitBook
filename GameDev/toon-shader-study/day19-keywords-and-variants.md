# Day 19. 키워드와 배리언트 — 옵션마다 따로 굽는 빵집

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-020-DO |
| 유형 | D&O (개념) + 코드 읽기 + 실습 |
| 목적 | 셰이더 키워드와 배리언트의 관계, `multi_compile`과 `shader_feature`의 차이, 배리언트 폭발을 줄이는 방법을 설명한다 |
| 소요 시간 | 약 1시간 (읽기 25분, 코드 읽기 25분, 실습 10분) |
| 선수 지식 | Day 04(`#if`, 전처리), Day 12(외곽선 패스) |
| 확인 상태 | 미검증 (소스를 읽고 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 학습 목표

- [ ] 키워드와 배리언트(셰이더 사본)의 관계를 안다
- [ ] `shader_feature`와 `multi_compile`의 차이를 안다
- [ ] `_local`, `_fragment` 꼬리말의 뜻을 안다
- [ ] 키워드 대신 머티리얼 값 분기를 쓰는 경우를 안다
- [ ] 스트리퍼가 무엇을 하고 왜 정리기(Sanitizer)가 먼저 돌아야 하는지 안다

## 1. 정의

키워드(keyword)는 `#if defined(...)`로 코드를 켜고 끄는 컴파일 시점 스위치다. 키워드 조합 하나마다 컴파일된 셰이더 프로그램이 하나 생기며, 이를 배리언트(variant, 변형)라고 한다. 꺼진 키워드의 코드는 그 배리언트에 존재하지 않는다.

| 항목 | 내용 |
|---|---|
| 장점 | 꺼진 기능의 실행 비용이 0이다. 런타임 `if`보다 빠르다 |
| 단점 | 배리언트 수가 늘어 빌드 시간, 메모리, 빌드 크기가 늘어난다 |

비유: 옵션별 완성품을 미리 구워 두는 빵집이다. 옵션이 하나 늘 때마다 빵 종류가 두 배가 된다.

## 2. 구성 요소

### 2.1 배리언트 수

| 항목 | 값 |
|---|---|
| 총 배리언트 수 | 각 키워드 그룹의 선택지 수의 곱 |
| 키워드 10개(각 on/off) | 2^10 = 1,024 |
| 키워드 20개(각 on/off) | 2^20 ≈ 1,048,576 |

![배리언트 폭발](../.gitbook/assets/concept-variant-explosion.png)

### 2.2 `#pragma` 종류

| 종류 | 빌드에 포함되는 조합 | 쓰는 곳 | 런타임 키워드 전환 |
|---|---|---|---|
| `multi_compile` | 모든 조합 | 엔진이 런타임에 켜고 끄는 키워드(그림자 방식, 추가광 등) | 가능 |
| `shader_feature` | 빌드에 포함된 머티리얼이 실제로 쓰는 조합만 | 머티리얼 체크박스 | 부적합. 빌드에 없는 조합은 런타임에 만들 수 없다 |

비유: `multi_compile`은 매일 굽는 기본 빵, `shader_feature`는 주문 들어온 것만 굽는 빵이다.

### 2.3 꼬리말

| 꼬리말 | 뜻 |
|---|---|
| `_local` | 이 셰이더 전용 키워드. 프로젝트 전체(전역) 키워드 수 한도를 아낀다 |
| `_fragment` | 프래그먼트 스테이지에서만 갈리는 키워드. 버텍스 스테이지의 사본이 늘지 않아 컴파일 수를 줄인다 |
| `_vertex` | 버텍스 스테이지에서만 갈리는 키워드(`_CASTING_PUNCTUAL_LIGHT_SHADOW`, L765) |

## 3. 동작 원리

### 3.1 선택지 목록의 맨 앞 `_`

`#pragma shader_feature_local _ _USE_RIM`에서 맨 앞 `_`는 "키워드 없음"이다. 그래서 선택지가 끔/켬 두 개가 된다. `_ _A _B _C`처럼 여러 개를 쓰면 그중 하나만 켜지는 묶음이 된다(파트 선택 `_PART_FACE/HAIR/SKIN`).

### 3.2 체크박스와 키워드 연결

[Properties](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L5-L184)의 속성 꾸밈말이 키워드를 켜고 끈다.

| 꾸밈말 | 동작 |
|---|---|
| `[Toggle(_USE_RIM)]` | 체크하면 `_USE_RIM` 키워드를 켠다 |
| `[KeywordEnum(None, Face, Hair, Skin, Cloth)]` | 선택에 따라 `_PART_FACE` 등을 켠다 |
| `[ToggleUI]` | 숫자만 0/1로 바꾸고 키워드는 만들지 않는다 |

{% hint style="info" %}
NOTE: 이 프로젝트에서 실제로 있었던 일(B5, C8)이다. `KeywordEnum`은 `_PART_NONE`, `_PART_CLOTH`도 만들지만 코드에서 갈리는 것은 Face/Hair/Skin뿐이었다. 그래서 None과 Cloth가 같은 셰이더를 두 번 굽고 있었다. `#pragma`에서 둘을 빼 기본(`_`) 배리언트를 쓰게 했다(L225–227 주석). 또 숫자로만 쓰는 토글에 `[Toggle]`을 붙였더니 셰이더에 없는 `_USEMATCAPMASK_ON` 같은 키워드가 머티리얼에 붙었다. `[ToggleUI]`로 바꿨다.
{% endhint %}

### 3.3 키워드 대신 숫자 분기

가벼운 옵션은 머티리얼 숫자 하나로 `if` 분기한다. 한 물체를 그리는 동안 모든 픽셀이 같은 값을 읽으므로 GPU의 스레드 묶음이 모두 같은 쪽으로 간다. 이런 균일한(uniform) 분기는 비용이 작고 배리언트도 늘지 않는다. 픽셀마다 답이 다른 `if`는 양쪽을 모두 실행할 수 있어 비싸다.

| 방식 | 배리언트 | 꺼진 기능의 비용 | 적합한 경우 |
|---|---|---|---|
| 키워드 | 증가 | 0 | 코드 양이 크거나 텍스처·연산이 많은 기능 |
| 머티리얼 값 분기 | 증가 없음 | 분기 비용(작음) | 텍스처 1회 읽기 정도의 가벼운 기능 |

### 3.4 스트리핑과 정리기

빌드 전에 Unity는 배리언트 목록을 스트리퍼(`IPreprocessShaders`)에 넘기고, 스트리퍼가 쓰지 않는 조합을 목록에서 뺀다.

| 단계 | 하는 일 | 시점 |
|---|---|---|
| 정리기(Sanitizer) | 파트와 안 맞는 키워드를 머티리얼에서 끈다. 불필요한 패스도 끈다 | 빌드 전, 머티리얼 검증 시 |
| 스트리퍼 | 의미 없는 조합의 배리언트를 목록에서 제거한다 | 셰이더 컴파일 직전 |

정리기가 스트리퍼보다 먼저 돌아야 하는 이유는 5장 주의에 있다.

## 4. 코드 읽기

### 4.1 `#pragma` 선언

[CharacterToon.shader L215–249](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L215-L249)

```hlsl
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#pragma multi_compile_fragment _ _SHADOWS_SOFT
#pragma multi_compile _ _ADDITIONAL_LIGHTS
...
#pragma shader_feature_local _ _USE_RIM
#pragma shader_feature_local_fragment _ _ALPHATEST_ON
```

`_ALPHATEST_ON`이 `_fragment`인 이유: 알파 클립은 프래그먼트의 `clip()`에서만 쓰인다.

### 4.2 숫자 분기

[L415–420](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L415-L420)

```hlsl
if (_UseShadowMask > 0.5h)      // 머티리얼 값 — 한 물체의 모든 픽셀이 같은 답
{
    half shadowMaskTex = SAMPLE_TEXTURE2D(_ShadowMaskTex, sampler_ShadowMaskTex, input.uv).r;
    ...
}
```

### 4.3 스트리퍼

[CharacterToonShaderStripper.cs L31–58](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonShaderStripper.cs#L31-L58)

```csharp
public void OnProcessShader(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data)
{
    if (shader == null || shader.name != TargetShaderName) return;
    ...
    for (int i = data.Count - 1; i >= 0; i--)
    {
        var ks = data[i].shaderKeywordSet;
        bool strip = ks.IsEnabled(kDebug);                                                   // 디버그용은 빌드에서 빼고
        if (!strip && ks.IsEnabled(kHairShadow) && !ks.IsEnabled(kPartFace)) strip = true;   // 말이 안 되는 조합도 빼고
        if (!strip && ks.IsEnabled(kAngelRing)  && !ks.IsEnabled(kPartHair)) strip = true;
        if (!strip && ks.IsEnabled(kSSS)        && !ks.IsEnabled(kPartSkin)) strip = true;
        if (strip) data.RemoveAt(i);
    }
}
```

| 제거 조건 | 이유 |
|---|---|
| 디버그 키워드 켬 | 릴리스 빌드에 불필요 |
| 앞머리 그림자 켬 + 얼굴 아님 | 코드가 `#if defined(_PART_FACE)` 안에 있어 효과가 없다 |
| 천사 고리 켬 + 헤어 아님 | 동일 |
| SSS 켬 + 피부 아님 | 동일 |

리스트를 역순으로 순회하며 `RemoveAt`해야 인덱스가 어긋나지 않는다.

### 4.4 패스 통째로 끄기

외곽선을 끈 머티리얼도 키워드만 꺼서는 Outline 패스가 실행된다(Day 12의 "화면 밖 한 점" 방식). 정리기가 패스 자체를 끈다. [CharacterToonKeywordSanitizer.cs L59–62](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonKeywordSanitizer.cs#L59-L62)

```csharp
bool outlineOn = m.IsKeywordEnabled("_USE_OUTLINE");
...
m.SetShaderPassEnabled(OutlinePassTag, outlineOn);   // "SRPDefaultUnlit" 패스를 켜고 끔
```

![Outline 패스 켬/끔](../.gitbook/assets/day19-outline-pass-toggle.png)

화면은 같지만 끈 쪽은 드로우콜과 스키닝된 정점 계산이 사라진다(B4).

### 4.5 ShaderGUI

[CharacterToon.shader L943](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader#L943)의 `CustomEditor "CharacterToon.Editor.CharacterToonShaderGUI"`가 머티리얼 인스펙터를 C#으로 그린다. [CharacterToonShaderGUI.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonShaderGUI.cs)

| 기능 | 설명 |
|---|---|
| 섹션 접기, 파트별 옵션 표시 | 현재 파트에 맞는 옵션만 보여 준다 |
| Surface 모드 | Blend/ZWrite/큐를 설정한다(Day 18) |
| `ValidateMaterial` | 정리기 실행, Depth Priming 경고(Day 13) |

## 5. 주의

{% hint style="warning" %}
CAUTION: 이 프로젝트에서 실제로 있었던 일(A1, Sanitizer)이다. (1) 셰이더 이름을 `com.blueigloo/...`로 바꿨는데 스트리퍼는 옛 이름을 찾고 있어 아무것도 버리지 못했다(A1). 이름을 고치고 [CompileCheck.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CompileCheck.cs)에 C#이 찾는 셰이더 이름이 실제로 있는지 검사하는 기능을 추가했다. (2) 스트리퍼가 동작하자 `_UseAngelRing` 기본값이 1이라 헤어가 아닌 머티리얼 대부분이 "헤어 아님 + 천사 고리 켬" 조합이 됐고, 그 조합이 제거되어 머티리얼에 쓸 배리언트가 하나도 없어졌다. (3) 그래서 빌드 전에 머티리얼을 정리하는 [CharacterToonKeywordSanitizer.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonKeywordSanitizer.cs)를 만들었다.
{% endhint %}

{% hint style="warning" %}
CAUTION: `shader_feature` 키워드를 스크립트에서 런타임에 `Material.EnableKeyword`로 켜는 용도로 쓰면 빌드에서 해당 배리언트가 없을 수 있다. 런타임에 바뀌는 키워드는 `multi_compile`로 선언한다.
{% endhint %}

{% hint style="info" %}
NOTE: 전역 키워드 수 한도와 `_local` 키워드 수 한도는 Unity 버전마다 다르다. 사용하는 버전의 문서에서 확인한다.
{% endhint %}

## 6. 실습 (10분)

1. `shader_feature_local _ _A`가 3줄, `multi_compile _ _B _C`가 1줄일 때 이론상 최대 배리언트 수를 계산한다. → 결과: 2 × 2 × 2 × 3 = 24.
2. 프래그먼트에서만 반짝이를 더하고 머티리얼 체크박스로 켜는 새 옵션 `_USE_GLITTER`의 선언을 쓴다. → 결과: `#pragma shader_feature_local_fragment _ _USE_GLITTER`.
3. "마스크 텍스처를 읽을까 말까"처럼 텍스처 1회 읽기만 아끼는 옵션에 키워드와 숫자 분기 중 무엇이 적합한지 판단한다. → 결과: 숫자 분기. 배리언트가 늘지 않는다.
4. (Unity 사용 시) 머티리얼 인스펙터 우측 상단 메뉴에서 Debug 모드를 연다. → 결과: Valid Keywords와 Invalid Keywords 목록이 보인다. 체크박스를 켜고 끄면 목록이 바뀐다. 되돌리려면 같은 메뉴에서 Normal 모드로 바꾼다.

## 7. 참조

- 오늘의 액기스: [ESSENCE.md — Day 19](essence.md#day-19)
- [Unity — 셰이더 배리언트와 키워드](https://docs.unity3d.com/Manual/SL-MultipleProgramVariants.html), [배리언트 스트리핑](https://docs.unity3d.com/Manual/shader-variant-stripping.html), [pragma 지시어](https://docs.unity3d.com/Manual/SL-PragmaDirectives.html)
- [Material.SetShaderPassEnabled](https://docs.unity3d.com/ScriptReference/Material.SetShaderPassEnabled.html), [MaterialPropertyDrawer (Toggle, KeywordEnum 등)](https://docs.unity3d.com/ScriptReference/MaterialPropertyDrawer.html)
- 수학: 스위치 n개로 만들 수 있는 조합은 2^n개(경우의 수)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] `multi_compile`과 `shader_feature`를 언제 각각 쓰는지 내 프로젝트의 옵션 하나로 예를 든다.
- [ ] 키워드로 만들 옵션과 숫자 분기로 둘 옵션을 가르는 내 기준을 적는다.
- [ ] 스트리퍼가 조합을 제거해 머티리얼이 깨질 수 있는 상황을 내 말로 설명한다.

---

[← Day 18](day18-passes.md) · [목차](README.md) · [다음: Day 20 →](day20-performance.md)
