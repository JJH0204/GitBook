# Day 20. 양면 그리기와 마무리 점검

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-020-MP |
| 목적 | `Cull [_Cull]`로 렌더 면을 머티리얼에서 고르고 뒷면에서 노멀을 뒤집은 뒤, SRP Batcher와 Frame Debugger로 셰이더를 점검한다 |
| 적용 대상 | Unity 6000.3, URP 17.x. Day 19 완료 상태의 `MyToon.shader` |
| 소요 시간 | 약 60분 (코드 20분, 점검 25분, 실험 15분) |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리한 것이며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: `FRONT_FACE_TYPE`, `FRONT_FACE_SEMANTIC`, `IS_FRONT_VFACE` 매크로는 URP(SRP Core) 버전과 플랫폼에 따라 정의가 다르다. Frame Debugger의 단계 이름도 Unity 버전마다 다르다. URP 버전 확인 필요.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [day03-properties.md](day03-properties.md) | GMD-TSL-003-MP | SRP Batcher |
| [day09-cast-shadows.md](day09-cast-shadows.md) | GMD-TSL-009-MP | 모든 패스가 같은 `ClipAlpha`를 쓰는 규칙 |
| [day13-outline-pass.md](day13-outline-pass.md) | GMD-TSL-013-MP | `Cull Front` 외곽선 |
| [day19-depthnormals-ssao.md](day19-depthnormals-ssao.md) | GMD-TSL-019-MP | 이전: DepthNormals와 SSAO |
| [day21-screen-outline.md](day21-screen-outline.md) | GMD-TSL-021-MP | 다음: 화면 공간 외곽선 |
| [toon-shader-study Day 18](../toon-shader-study/day18-passes.md), [Day 20](../toon-shader-study/day20-performance.md) | - | 패스 총정리, 성능 (짝꿍 과정) |
| [Unity Cull](https://docs.unity3d.com/Manual/SL-Cull.html), [Frame Debugger](https://docs.unity3d.com/Manual/FrameDebugger.html), [SRP Batcher](https://docs.unity3d.com/Manual/SRPBatcher.html), [LearnOpenGL Face culling](https://learnopengl.com/Advanced-OpenGL/Face-culling) | - | 공식 문서 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | `Assets/MyToon/MyToon.shader` | Day 19 완료 상태 | |
| 2 | Frame Debugger | `Window > Analysis > Frame Debugger` | |

## 3. 안전 사항

{% hint style="danger" %}
WARNING: 모든 패스(Forward, ShadowCaster, DepthOnly, DepthNormals)가 같은 컬링 규칙을 따라야 한다. 색칠 패스만 양면으로 그리고 그림자 패스가 앞면만 그리면 뒷면은 그림자를 드리우지 않는다.
{% endhint %}

{% hint style="warning" %}
CAUTION: 양면 렌더링은 그리는 면이 두 배가 된다. 나뭇잎, 머리카락 카드, 망토처럼 필요한 경우에만 켠다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Day 19 코드가 컴파일된다 | Console 오류 0건 |
| 2 | `Alpha Clip`을 켜면 구멍 속에 검은 점이 보인다 | Day 18의 5-E-03 |

## 5. 절차

### A. Render Face 프로퍼티 추가

1. (5-A-01) `Properties`의 `_Cutoff` 아래에 추가한다. `[Enum(UnityEngine.Rendering.CullMode)]`는 Unity 컬 모드 목록(Off = 0, Front = 1, Back = 2)을 드롭다운으로 보여 준다. → 결과: Inspector에 `Render Face (Cull)` 드롭다운이 나타난다.

```shaderlab
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Render Face (Cull)", Float) = 2
```

### B. 네 패스에 컬 적용

1. (5-B-01) Forward, ShadowCaster, DepthOnly, DepthNormals 패스의 `Tags` 줄 아래(또는 `ColorMask` 줄 아래)에 각각 한 줄을 추가한다. → 결과: 4개 패스 모두 `_Cull` 값을 따른다.

```shaderlab
            Cull [_Cull]
```

2. (5-B-02) Outline 패스는 `Cull Front`를 그대로 둔다. → 결과: 외곽선은 항상 뒷면만 그린다.

### C. 뒷면에서 노멀 뒤집기

메시 노멀은 앞면 기준이라 뒷면에서는 반대 방향을 가리킨다. 그대로 쓰면 빛 계산이 거꾸로 된다. `IS_FRONT_VFACE(값, 앞면일 때, 뒷면일 때)`는 현재 그리는 면이 앞면인지에 따라 값을 고르는 URP 매크로다.

1. (5-C-01) Forward `frag`의 선언과 첫 줄을 바꾼다. → 결과: 컴파일 오류가 없다.

```hlsl
            half4 frag(Varyings input, FRONT_FACE_TYPE faceSign : FRONT_FACE_SEMANTIC) : SV_Target
            {
                input.normalWS *= IS_FRONT_VFACE(faceSign, 1.0, -1.0);   // 뒷면이면 노멀을 뒤집는다
```

### D. DepthNormals도 같게 수정

1. (5-D-01) `DepthNormalsFrag`를 다음으로 바꾼다. 뒤집지 않으면 SSAO가 뒷면에서 틀린 노멀을 읽는다. 실제 프로젝트에서 나뭇잎 뒷면 SSAO가 깨진 원인이었다. → 결과: 컴파일 오류가 없다.

```hlsl
            half4 DepthNormalsFrag(DepthNormalsVaryings input, FRONT_FACE_TYPE faceSign : FRONT_FACE_SEMANTIC) : SV_Target
            {
                ClipAlpha(input.uv);
                half3 normalWS = normalize(input.normalWS) * IS_FRONT_VFACE(faceSign, 1.0, -1.0);
                return half4(normalWS, 0.0h);
            }
```

정답 파일: [`Assets/Solutions/Day20/MyToon.shader`](https://github.com/JJH0204/toon-shader-lab/blob/main/Assets/Solutions/Day20/MyToon.shader)

### E. 화면 확인

1. (5-E-01) 머티리얼에서 `Alpha Clip`을 켠다. → 결과: 구멍 속이 검은 점(외곽선 껍질의 안쪽)으로 보인다.
2. (5-E-02) `Render Face`를 `Off`로 바꾼다. → 결과: 구멍 너머로 안쪽 면이 제대로 칠해진다. Cube 안쪽 벽이 그림자 색으로 보이는 것은 노멀 뒤집기 덕분이다.
3. (5-E-03) 확인 후 `Alpha Clip`을 끄고 `Render Face`를 `Back`으로 되돌린다.

![Day 20 결과: 구멍 속 안쪽 면](../.gitbook/assets/day20-cull.png)

### F. 마무리 점검

1. (5-F-01) `MyToon.shader`를 선택하고 Inspector를 본다. → 결과: `SRP Batcher: compatible`이 표시된다. 모든 패스가 `HLSLINCLUDE`의 같은 CBUFFER를 쓰기 때문이다.
2. (5-F-02) `Window > Analysis > Frame Debugger`를 열고 `Enable`을 누른다. → 결과: 왼쪽에 렌더 단계 목록이 나타난다.
3. (5-F-03) 이름에 `Shadow`가 들어간 단계를 누른다. → 결과: 이 물체가 `ShadowCaster` 패스로 그려진다.
4. (5-F-04) 이름에 `DepthNormals`가 들어간 단계를 누른다. → 결과: `DepthNormals` 패스로 그려진다.
5. (5-F-05) `Draw Opaque Objects` 단계를 누른다. → 결과: Forward 패스 다음에 Outline 패스(`SRPDefaultUnlit`)가 그려진다. 오른쪽에 셰이더, 패스, 키워드, `SRP Batch` 묶음이 표시된다. 단계 이름은 Unity 버전마다 다르므로 항목을 하나씩 눌러 찾는다.

패스 정리표는 다음과 같다.

| 패스 | LightMode | 그리는 것 | 사용처 | 배운 Day |
|---|---|---|---|---|
| Forward | `UniversalForward` | 색 | 화면 | 01 이후 |
| Outline | `SRPDefaultUnlit` | 외곽선 | 화면 | 13 |
| ShadowCaster | `ShadowCaster` | 광원 기준 거리 | 그림자 판정 | 09 |
| DepthOnly | `DepthOnly` | 카메라 기준 깊이 | 깊이 텍스처 | 09 |
| DepthNormals | `DepthNormals` | 깊이와 노멀 | SSAO, 화면 효과 | 19 |

### G. 실험

1. (5-G-01) `input.normalWS *= ...` 줄을 지우고 `Render Face = Off`, `Alpha Clip` 켬 상태로 본다. → 결과: 안쪽 벽이 엉뚱하게 밝아진다. 확인 후 되돌린다.
2. (5-G-02) ShadowCaster의 `Cull [_Cull]`을 `Cull Back`으로 바꾸고 양면일 때 그림자 모양을 본다. → 결과: 그림자 모양이 달라지는지 비교한다. 확인 후 되돌린다.
3. (5-G-03) 커밋한다: `git commit -am "Day 20: 양면과 마무리 점검"`

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | `Alpha Clip` 켬, `Render Face = Off` | 구멍 너머로 안쪽 면이 칠해진다 | 검은 점이 없다 |
| 2 | Inspector | `SRP Batcher: compatible` | 표시 일치 |
| 3 | Frame Debugger | 4개 패스 단계가 보인다 | Shadow, DepthNormals, Forward, Outline 확인 |

## 7. 복구

1. (7-01) 변경을 되돌린다: `Ctrl+Z` 또는 `git restore Assets/MyToon/MyToon.shader`.
2. (7-02) 머티리얼의 `Alpha Clip`을 끄고 `Render Face`를 `Back`으로 둔다.
3. (7-03) `Frame Debugger`의 `Enable`을 끈다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 Day 20 페이지를 AMM 형식으로 재작성. 비유 삭제, 패스 표 보존 |

[← Day 19](day19-depthnormals-ssao.md) · [목차](README.md) · [다음: Day 21 →](day21-screen-outline.md)
