# Day 11. 보조 조명 — 그리고 나만의 공구함 파일

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-011-MP |
| 목적 | 조명 계산을 `MyToonLighting.hlsl`로 분리하고 포인트, 스폿 라이트(보조 조명)를 툰 계단으로 더한다 |
| 적용 대상 | Unity 6000.3, URP 17.x, Forward 또는 Forward+ 렌더링. Day 10 완료 상태의 `MyToon.shader` |
| 소요 시간 | 약 60분 (파일 작성 25분, 연결 15분, 실험 20분) |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리한 것이며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 이 Day의 코드는 URP 버전에 크게 의존한다. `_ADDITIONAL_LIGHTS`, `_ADDITIONAL_LIGHT_SHADOWS`, `_CLUSTER_LIGHT_LOOP` 키워드(이전 버전은 `_FORWARD_PLUS`), `USE_CLUSTER_LIGHT_LOOP`, `LIGHT_LOOP_BEGIN`, `URP_FP_DIRECTIONAL_LIGHTS_COUNT`, `GetAdditionalLight` 오버로드, `GetNormalizedScreenSpaceUV`는 URP 버전마다 이름과 시그니처가 다르다. URP 버전 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day07-toon-steps.md](day07-toon-steps.md) | GMD-TSL-007-MP | `CelStep` 정의 |
| [day10-ambient-fog.md](day10-ambient-fog.md) | GMD-TSL-010-MP | 이전: 환경광과 안개 |
| [day12-rim-light.md](day12-rim-light.md) | GMD-TSL-012-MP | 다음: 림 라이트 |
| [day18-keywords.md](day18-keywords.md) | GMD-TSL-018-MP | 키워드와 변형 |
| [toon-shader-study Day 09](../toon-shader-study/day09-many-lights.md) | - | 여러 개의 빛 (짝꿍 과정) |
| [LearnOpenGL Light casters](https://learnopengl.com/Lighting/Light-casters), [Multiple lights](https://learnopengl.com/Lighting/Multiple-lights), [URP Forward+ 렌더링 경로](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/rendering/forward-plus-rendering-path.html) | - | 거리 감쇠, Forward+ 참고 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | `Assets/MyToon/MyToon.shader` | Day 10 완료 상태 | |
| 2 | 파일 탐색기 | | `.hlsl` 파일 생성에 사용 |
| 3 | Lab 씬의 `Point Light` | 기본 비활성 | 빨간 전구 |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: `GetAdditionalLight`는 인자 3개(`index, positionWS, shadowMask`) 버전을 써야 보조 조명의 그림자가 반영된다. 인자 2개 버전은 그림자 감쇠가 항상 1이라 빛이 물체를 뚫고 비춘다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Day 10 코드가 컴파일된다 | Console 오류 0건 |
| 2 | `CelStep` 함수가 `MyToon.shader`에 있다 | 5-B-01에서 이동한다 |

## 5. 절차

### A. 공구함 파일 만들기

같은 `CelStep`을 메인 라이트와 보조 조명이 함께 쓰므로 조명 함수를 별도 파일로 분리한다.

1. (5-A-01) Project 창에서 `MyToon` 폴더를 우클릭하고 `Show in Explorer`를 누른다. → 결과: 파일 탐색기가 열린다.
2. (5-A-02) 새 텍스트 파일을 만들어 이름을 `MyToonLighting.hlsl`로 바꾼다. → 결과: 확장자가 `.txt`로 남지 않는다.
3. (5-A-03) 다음 내용을 입력하고 저장한다. → 결과: Unity가 파일을 인식한다.

```hlsl
// 툰 조명 공구함. URP Lighting.hlsl 다음에 include 할 것 (Light 타입, GetAdditionalLight 가 필요하다).
#ifndef MYTOON_LIGHTING_INCLUDED
#define MYTOON_LIGHTING_INCLUDED

// 계단 하나: value 가 border 를 넘으면 1, 아니면 0. blur 폭만큼 모서리를 다듬는다.
half CelStep(half value, half border, half blur)
{
    half b = max(blur, 1e-4h);   // blur 가 0 이면 0 으로 나누게 되므로 바닥을 깐다
    return smoothstep(border - b, border + b, value);
}

// 보조 조명 하나의 툰 기여. 빛 쪽만 밝히고 그림자 쪽은 건드리지 않는다(더하기만).
half3 ShadeAdditionalLight(Light light, half3 N, half3 albedo, half border, half blur)
{
    half lightVal = dot(N, light.direction) * 0.5h + 0.5h;
    half lit = CelStep(lightVal, border, blur);
    return albedo * light.color * (light.distanceAttenuation * light.shadowAttenuation * lit);
}

// 이 픽셀에 닿는 보조 조명을 모두 더한다. Forward 와 Forward+ 둘 다 동작한다.
half3 AdditionalLightsToon(float3 positionWS, float4 positionCS, half3 N, half3 albedo, half border, half blur)
{
    half3 sum = 0;
#if defined(_ADDITIONAL_LIGHTS)
    // LIGHT_LOOP_BEGIN 매크로가 'inputData' 라는 이름의 변수를 읽는다 (Forward+ 의 바둑판 칸 찾기)
    InputData inputData = (InputData)0;
    inputData.positionWS = positionWS;
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(positionCS);
    half4 shadowMask = half4(1, 1, 1, 1);

  #if USE_CLUSTER_LIGHT_LOOP
    // Forward+: 해가 아닌 다른 Directional 조명은 바둑판에 안 들어가서 따로 돈다
    for (uint di = 0u; di < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); di++)
        sum += ShadeAdditionalLight(GetAdditionalLight(di, positionWS, shadowMask), N, albedo, border, blur);
  #endif

    uint count = GetAdditionalLightsCount();
    LIGHT_LOOP_BEGIN(count)
        // 인자 3개짜리 GetAdditionalLight 라야 보조 조명의 그림자가 들어간다
        sum += ShadeAdditionalLight(GetAdditionalLight(lightIndex, positionWS, shadowMask), N, albedo, border, blur);
    LIGHT_LOOP_END
#endif
    return sum;
}

#endif // MYTOON_LIGHTING_INCLUDED
```

| 코드 | 의미 |
|---|---|
| `#ifndef X` / `#define X` / `#endif` | 중복 방지 가드. 같은 파일이 두 번 include돼도 함수가 두 번 정의되지 않는다 |
| `light.distanceAttenuation` | 거리 감쇠. 거리가 멀수록 어두워진다(대략 거리 제곱에 반비례) |
| `light.shadowAttenuation` | 보조 조명의 그림자. 인자 3개 `GetAdditionalLight`에서만 반영된다 |
| `LIGHT_LOOP_BEGIN` / `LIGHT_LOOP_END` | URP가 제공하는 반복문 매크로. 렌더러 설정에 맞는 반복문으로 바뀐다 |
| `#if defined(_ADDITIONAL_LIGHTS)` | 보조 조명이 꺼진 설정이면 이 계산을 통째로 제외한다 |

| 방식 | 설명 |
|---|---|
| Forward | 물체마다 영향을 주는 조명 목록을 준다(물체당 개수 제한) |
| Forward+ | 화면을 타일(바둑판)로 나누고 타일마다 조명 목록을 만든다 (원본 프로젝트 설정) |

`inputData.normalizedScreenSpaceUV`는 Forward+에서 현재 픽셀이 속한 타일을 찾는 데 쓴다. 메인 라이트 외의 Directional 조명은 타일에 들어가지 않아 별도 루프로 처리한다.

### B. 셰이더에 연결

1. (5-B-01) `MyToon.shader`에서 Day 07에 만든 `CelStep` 함수를 삭제한다. → 결과: 공구함 파일의 정의만 남는다.
2. (5-B-02) Forward 패스의 `#pragma` 줄들 아래에 키워드 세 줄을 추가한다.

```hlsl
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
```

3. (5-B-03) `Lighting.hlsl` include 아래에 공구함을 include한다.

```hlsl
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "MyToonLighting.hlsl"     // 같은 폴더의 내 파일
```

4. (5-B-04) Properties의 `_ShadeFloor` 아래에 추가한다.

```shaderlab
        _AdditionalLightStrength ("Additional Light Strength", Range(0, 2)) = 1     // _ShadeFloor 아래
```

5. (5-B-05) CBUFFER의 `_ShadeFloor` 아래에 추가한다.

```hlsl
            half   _AdditionalLightStrength;     // CBUFFER, _ShadeFloor 아래
```

6. (5-B-06) frag의 `color = max(...)` 다음, `MixFog` 앞에 추가한다. frag에서 `input.positionCS`는 픽셀 좌표를 담고 있다. → 결과: 컴파일 오류가 없다.

```hlsl
                // 보조 조명(포인트·스폿)은 더하기만 한다
                color += AdditionalLightsToon(input.positionWS, input.positionCS, N, albedo,
                                              _ShadowBorder, _ShadowBlur) * _AdditionalLightStrength;
```

정답 파일: [`Assets/Solutions/Day11/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day11/MyToon.shader), [`MyToonLighting.hlsl`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day11/MyToonLighting.hlsl)

### C. 화면 확인

1. (5-C-01) Hierarchy에서 `Point Light`를 켠다. → 결과: Cube 앞면과 Capsule 옆면이 빨간 계단으로 밝아진다. 같은 Border, Blur를 쓰므로 경계가 해 그림자와 비슷한 느낌이다.
2. (5-C-02) `Point Light`를 움직인다. → 결과: 빛이 따라온다.
3. (5-C-03) `Point Light`를 Cube 뒤로 보낸다. → 결과: Cube 그림자에 가려 Capsule에 빛이 닿지 않는다(보조 조명 그림자).

![Day 11 결과: 포인트 라이트](../.gitbook/assets/day11-point-light.png)

### D. 실험

1. (5-D-01) `GetAdditionalLight(lightIndex, positionWS, shadowMask)`의 세 번째 인자를 지운다. → 결과: 그림자 없이 물체를 뚫고 비춘다. 확인 후 되돌린다.
2. (5-D-02) `Point Light`의 `Type`을 `Spot`으로 바꾸고 각도를 좁힌다. → 결과: 같은 코드로 동작한다.
3. (5-D-03) `Point Light`의 `Intensity`를 10으로 올린다. → 결과: 메인 라이트가 만든 그림자 모양은 그대로이고 빨간 쪽만 밝아진다. 확인 후 `Point Light`를 끈다.
4. (5-D-04) 커밋한다: `git add Assets/MyToon && git commit -m "Day 11: 보조 조명과 공구함 파일"`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `Point Light` 켬 | 물체가 빨간 계단으로 비춰진다 | 경계가 뚜렷하다 |
| 2 | `Point Light`를 Cube 뒤로 이동 | 가려진 면에 빛이 닿지 않는다 | 그림자 반영 |
| 3 | `Point Light` 끔 | Day 10 화면과 같다 | 차이 없음 |

## 7. 복구

1. (7-01) `Point Light`를 끈다.
2. (7-02) 변경을 되돌린다: `git restore Assets/MyToon/MyToon.shader`. 새 파일 `MyToonLighting.hlsl`은 삭제한다.
3. (7-03) 5-B-01에서 지운 `CelStep` 함수를 Day 07 코드에서 다시 가져온다(GMD-TSL-007-MP).

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 Day 11 페이지를 AMM 형식으로 재작성. 키워드 이름의 URP 버전 의존 NOTE 추가 |

[← Day 10](day10-ambient-fog.md) · [목차](README.md) · [다음: Day 12 →](day12-rim-light.md)
