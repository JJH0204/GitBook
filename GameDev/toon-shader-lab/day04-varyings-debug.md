# Day 04. 택배 상자 늘리기 — 노멀과 UV를 눈으로 보기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-004-MP |
| 목적 | `Varyings`에 UV와 월드 노멀을 추가하고, 인스펙터의 `Debug View`로 두 값을 색으로 확인하는 장치를 만든다 |
| 적용 대상 | Unity 6000.3, URP 17.x. Day 03 완료 상태의 `MyToon.shader` |
| 소요 시간 | 약 60분 (코드 25분, 설명 15분, 실험 20분) |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리한 것이며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `Debug View`는 이후 Day에서 계속 쓰는 확인 도구다. 값이 보이지 않을 때는 먼저 이 드롭다운으로 중간 값을 색으로 본다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day03-properties.md](day03-properties.md) | GMD-TSL-003-MP | 이전: Properties와 CBUFFER |
| [day05-textures.md](day05-textures.md) | GMD-TSL-005-MP | 다음: 텍스처와 알파 클립 |
| [toon-shader-study Day 04](../toon-shader-study/day04-hlsl-basics.md) | - | HLSL 문법 기초 (짝꿍 과정) |
| [Microsoft HLSL 시맨틱](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-semantics), [자료형](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-data-types) | - | 시맨틱, 자료형 |
| [Barycentric coordinates](https://en.wikipedia.org/wiki/Barycentric_coordinate_system), [Swizzling](https://en.wikipedia.org/wiki/Swizzling_(computer_graphics)) | - | 보간과 스위즐 참고 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | `Assets/MyToon/MyToon.shader` | Day 03 완료 상태 | |
| 2 | 머티리얼 `MyToon` | | |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: `Properties`에 값을 추가하면 같은 이름을 CBUFFER에도 선언한다. 빠뜨려도 오류는 나지 않고 값이 0이 되며 SRP Batcher 호환이 깨질 수 있다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Day 03 셰이더가 컴파일된다 | Console 오류 0건 |
| 2 | `_BaseColor`가 CBUFFER에 있다 | 코드에서 확인한다 |

## 5. 절차

### A. Debug View 프로퍼티 추가

1. (5-A-01) `Properties`의 `_BaseColor` 아래에 다음 두 줄을 추가한다. `[Enum(이름,값,...)]`은 숫자 칸을 드롭다운으로 보여 주고, `[Header(Debug)]`는 제목 줄을 그린다. → 결과: Inspector에 `Debug` 제목과 `Debug View` 드롭다운이 나타난다.

```shaderlab
        [Header(Debug)]
        [Enum(Off,0,Normal,1,UV,2)] _DebugView ("Debug View", Float) = 0
```

2. (5-A-02) CBUFFER에 `_DebugView`를 추가한다.

```hlsl
CBUFFER_START(UnityPerMaterial)
    half4  _BaseColor;
    half   _DebugView;
CBUFFER_END
```

### B. Attributes와 Varyings 확장

`TEXCOORD0`은 메시의 첫 번째 UV를 받는 입력 시맨틱이다. `Varyings`의 `TEXCOORD0`, `TEXCOORD1`은 보간 값을 담는 칸 번호이며 이름과 달리 노멀도 담을 수 있다.

1. (5-B-01) 두 구조체를 다음과 같이 수정한다. → 결과: 컴파일 오류가 없다.

```hlsl
struct Attributes
{
    float4 positionOS : POSITION;
    float3 normalOS   : NORMAL;
    float2 uv         : TEXCOORD0;    // 추가: 텍스처 좌표
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    float2 uv         : TEXCOORD0;    // 추가
    float3 normalWS   : TEXCOORD1;    // 추가
};
```

### C. vert 채우기

1. (5-C-01) `vert`를 다음으로 바꾼다. → 결과: 컴파일 오류가 없다.

```hlsl
Varyings vert(Attributes input)
{
    Varyings o = (Varyings)0;
    o.positionCS = TransformObjectToHClip(input.positionOS.xyz);
    o.normalWS   = TransformObjectToWorldNormal(input.normalOS);   // 추가
    o.uv         = input.uv;                                        // 추가
    return o;
}
```

### D. frag에서 값 꺼내기

1. (5-D-01) `frag`를 다음으로 바꾼다. → 결과: `Debug View`가 `Off`일 때 Day 03과 같은 단색이 나온다.

```hlsl
half4 frag(Varyings input) : SV_Target
{
    half3 N = normalize(input.normalWS);

    // 디버그 보기: 눈에 안 보이는 값을 색으로 꺼내 본다
    if (_DebugView > 1.5h) return half4(input.uv, 0.0h, 1.0h);
    if (_DebugView > 0.5h) return half4(N * 0.5h + 0.5h, 1.0h);

    return _BaseColor;
}
```

정답 파일: [`Assets/Solutions/Day04/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day04/MyToon.shader)

### E. 화면 확인

1. (5-E-01) 머티리얼의 `Debug View`를 `Normal`로 바꾼다. → 결과: 월드 +X를 향한 면은 빨강, +Y(위)는 초록, +Z는 파랑 쪽 색이 된다. 노멀 `(x, y, z)`는 -1~1이고 색은 0~1이므로 `N * 0.5 + 0.5`로 옮긴 값이다.
2. (5-E-02) `Debug View`를 `UV`로 바꾼다. → 결과: UV (0,0) 위치가 검정이다. u가 커질수록 빨강, v가 커질수록 초록이 된다. Cube는 면마다 0~1이 반복된다.

![Day 04 결과: Normal, UV 디버그 화면](../.gitbook/assets/day04-debug-views.png)

### F. 개념 확인

| 항목 | 설명 |
|---|---|
| 보간(interpolation) | `vert`는 삼각형 꼭짓점 3개에서만 실행된다. 그 사이 픽셀 값은 GPU가 꼭짓점 값을 거리에 따라 섞어 만든다 |
| `normalize` 필요 이유 | 길이 1인 노멀 둘을 보간하면 길이가 1보다 짧아진다. frag에서 `normalize`로 길이를 1로 되돌린다 |
| 디버그 `if` 비용 | `_DebugView`는 머티리얼 값이라 한 물체의 모든 픽셀이 같은 분기를 택한다. 비용이 작다 |

{% hint style="warning" %}
CAUTION: 픽셀마다 결과가 다른 `if`는 비용이 클 수 있다. 위 설명은 머티리얼 값으로 분기하는 경우에만 해당한다.
{% endhint %}

스위즐(swizzle) 표기는 다음과 같다.

| 코드 | 결과 |
|---|---|
| `v.xyz`, `v.rgb` | 앞 세 칸 (위치는 xyz, 색은 rgb 표기를 쓴다) |
| `v.xz` | 1번과 3번 칸 |
| `v.xxx` | 1번 칸 값을 세 번 복사 (흑백 색) |
| `half4(input.uv, 0, 1)` | 2칸 uv에 0과 1을 붙여 4칸으로 만든다 |

### G. 실험

1. (5-G-01) `half3 N = input.normalWS;`로 바꾸고 `Normal` 화면을 본다. → 결과: 저폴리 구에서 색이 약간 어두워지는 곳이 생긴다. 확인 후 되돌린다.
2. (5-G-02) `Normal` 분기를 `return half4(N.yyy * 0.5h + 0.5h, 1.0h);`로 바꾼다. → 결과: 위를 볼수록 흰색이 되는 흑백 화면이 나온다. Day 06의 조명 계산과 비슷한 형태다.
3. (5-G-03) UV 분기를 `return half4(frac(input.uv * 4.0), 0.0h, 1.0h);`로 바꾼다. → 결과: 4x4로 반복되는 격자가 보인다. `frac`은 소수 부분만 남긴다.
4. (5-G-04) 커밋한다: `git commit -am "Day 04: 노멀과 UV 디버그 보기"`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `Debug View = Normal` | 방향별 색이 매끈하게 변한다 | 위쪽 면이 초록 계열 |
| 2 | `Debug View = UV` | 빨강-초록 그라데이션 | (0,0) 위치가 검정 |
| 3 | `Debug View = Off` | 단색 | `Base Color`와 일치 |

## 7. 복구

1. (7-01) 실험 코드(5-G)를 원래 분기로 되돌린다: `Ctrl+Z` 또는 `git restore Assets/MyToon/MyToon.shader`.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 Day 04 페이지를 AMM 형식으로 재작성. 노멀 색 설명을 월드 축 기준으로 정정 (원본의 "카메라 반대 방향이 파랑"은 카메라가 아니라 월드 +Z 기준이다) |

[← Day 03](day03-properties.md) · [목차](README.md) · [다음: Day 05 →](day05-textures.md)
