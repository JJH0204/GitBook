# Day 15 · 오버드로우, 투명, 컬링 🎮

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-016-DO |
| 유형 | D&O (개념) + 확인 실습 |
| 목적 | 깊이 버퍼와 `Early-Z`, 반투명 오버드로우, 컬링 기법의 원리와 한계를 설명한다. |
| 적용 대상 | Unity 6 (URP), `practice/UnityLab` |
| 소요 시간 | 60분 (3주차 렌더링과 측정) |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 준비물: 🎮 Unity 6 (`practice/UnityLab`, URP)
{% endhint %}

## 1. 학습 목표

- 깊이 버퍼(`Z-buffer`)와 `Early-Z`가 어떻게 불투명 오브젝트의 픽셀 연산을 아껴 주는지 설명할 수 있다.
- 반투명 오브젝트와 알파 테스트(`Alpha Clip`)가 왜 오버드로우(`overdraw`)와 필레이트(`fill rate`) 병목을 부르는지 설명할 수 있다.
- 프러스텀 컬링(`frustum culling`)과 오클루전 컬링(`occlusion culling`)의 차이와 오클루전 컬링이 오히려 손해인 상황을 구분할 수 있다.

## 2. 구성 요소

| 요소 | 위치 | 역할 |
|---|---|---|
| 깊이 버퍼(`Z-buffer`) | GPU 렌더 타깃 옆 | 픽셀마다 카메라로부터의 거리를 기록한다 |
| `Early-Z` | 프래그먼트 셰이더 직전 | 가려진 픽셀의 셰이더 실행을 건너뛴다 |
| `ZWrite` | 머티리얼 / 셰이더 | 깊이 버퍼에 쓸지 정한다. 반투명은 끈다 |
| Rendering Debugger | `Window > Analysis > Rendering Debugger` | 오버드로우를 색으로 보여 준다 |
| 프러스텀 컬링 | CPU, 자동 | 시야 절두체와 `Bounds`가 겹치는지 검사한다 |
| 오클루전 컬링 | CPU, 베이크 데이터 필요 | 정적 가림막 뒤의 오브젝트를 제외한다 |
| `Camera.layerCullDistances` | 카메라 | 레이어별 최대 표시 거리를 정한다 |
| `LOD Group` | 오브젝트 | 거리에 따라 메시 해상도를 바꾸거나 컬링한다 |

## 3. 동작 원리

### 3-1. 깊이 버퍼와 Early-Z: 불투명이 앞→뒤로 그려지는 이유

화면의 한 픽셀에 오브젝트 10개가 겹쳐 있어도 결국 눈에 보이는 불투명 픽셀은 **가장 앞에 있는 1개**뿐이다. GPU는 픽셀마다 카메라로부터의 거리를 기록하는 **깊이 버퍼(`Depth Buffer`, `Z-buffer`)**를 둔다.

현대 GPU는 무거운 프래그먼트 셰이더를 실행하기 **직전에** 깊이 테스트를 먼저 수행하는 **`Early-Z`** 최적화를 지원한다.
1. Unity가 불투명 오브젝트(`Opaques`)를 카메라에서 **가까운 순서(앞→뒤)**로 정렬해 그린다.
2. 가장 앞의 오브젝트가 깊이 버퍼를 작은 깊이값으로 먼저 채운다.
3. 뒤에 있는 오브젝트들은 래스터화 직후 `Early-Z`에서 "이미 앞에 뭔가 있다"고 판정되어 **프래그먼트 셰이더를 아예 실행하지 않고 버려진다.**

### 3-2. 반투명과 알파 테스트가 비싼 이유: 오버드로우

한 픽셀이 한 프레임 동안 여러 번 칠해지는 현상을 **`오버드로우(overdraw)`**라고 한다.

| 구분 | 깊이 쓰기(`ZWrite`) | 그리는 순서 | GPU에서 벌어지는 일 |
|---|---|---|---|
| **불투명(`Opaque`)** | 켬(`On`) | 앞 → 뒤 | 앞이 가리면 뒤는 `Early-Z`로 프래그먼트 셰이더 생략 |
| **반투명(`Transparent`)** | **끔(`Off`)** | **뒤 → 앞** | 뒤 픽셀부터 다 계산한 뒤 앞 픽셀을 **블렌딩(`Blending`)**으로 덮어씀. 겹친 수만큼 셰이더와 메모리 대역폭 소모 |
| **알파 테스트(`Alpha Clip` / `discard`)** | 켬(`On`) | 불투명 뒤(보통 `AlphaTest` 큐) | 프래그먼트 셰이더를 실행해 봐야 구멍이 뚫렸는지 알 수 있어 **`Early-Z`가 무력화**될 수 있음(특히 모바일 TBDR GPU) |

반투명의 또 다른 한계는 **정렬 단위**다. Unity는 반투명 정렬을 픽셀 단위가 아니라 **오브젝트(메시 중심점 또는 바운딩 박스) 단위**로 한다. 그래서 큰 반투명 평면 두 개가 서로 교차하거나 카메라 각도가 바뀌면 앞뒤 순서가 뒤집혀 깜빡이는 정렬 오류(`sorting artifact`)가 난다.

실무에서 오버드로우의 주범은 **파티클 이펙트(연기·불꽃이 화면 가득 겹침)**와 **전체 화면을 덮는 투명 UI 패널**이다. 빈 여백이 넓은 사각형(`Quad`)에 투명 텍스처를 씌우면 눈에 안 보이는 알파 0 영역까지 전부 프래그먼트 셰이더와 블렌딩을 탄다.

### 3-3. 필레이트와 URP Rendering Debugger

GPU가 초당 화면에 칠할 수 있는 픽셀 수를 **`필레이트(fill rate)`**라고 한다. 고해상도(4K, 모바일 레티나 디스플레이)에서 큰 반투명 이펙트가 여러 겹 겹치면 드로우 콜이 몇 개 안 돼도 필레이트와 메모리 대역폭 한계로 프레임이 급락한다. 특히 모바일 GPU(`TBDR`, 타일 기반 지연 렌더링)는 대역폭이 작고 발열에 민감해 오버드로우와 `discard`(`clip`)에 훨씬 취약하다.

URP에서 오버드로우를 눈으로 확인하려면 **`Window > Analysis > Rendering Debugger`**를 열고 `Rendering` 패널의 `Overdraw Mode`를 켠다(위치와 이름은 URP 버전에 따라 조금 다르다). 많이 겹쳐 칠해진 픽셀일수록 밝게(또는 겹친 횟수 색으로) 빛난다.

### 3-4. 안 보이는 것은 아예 제출하지 않기: 컬링과 LOD

픽셀을 아끼는 것보다 더 좋은 것은 아예 드로우 콜을 제출하지 않는 **`컬링(culling)`**이다.

| 기법 | 원리 | 특징과 주의점 |
|---|---|---|
| **프러스텀 컬링(`Frustum Culling`)** | 카메라 시야 절두체(`Frustum`)와 렌더러의 경계 상자(`Bounds`)가 겹치는지 CPU에서 검사 | **항상 자동 동작**. 시야 밖 오브젝트는 드로우를 제출하지 않음 |
| **오클루전 컬링(`Occlusion Culling`)** | 벽·건물(`Occluder`) 뒤에 완전히 가려진 오브젝트(`Occludee`)를 CPU에서 제외 | 정적 오브젝트 기준 **사전 베이크(`Bake`) 데이터** 필요. 매 프레임 가시성 판정에 **CPU 시간과 메모리**를 쓰므로, 가려지는 게 별로 없는 탁 트인 맵이나 탑뷰 게임에서는 **오히려 켜는 것이 손해** |
| **레이어별 컬 거리(`Camera.layerCullDistances`)** | 레이어마다 카메라 최대 표시 거리를 다르게 설정 | 작은 소품·잔디 레이어는 30m 밖에서 일찍 컬링하고 큰 산·건물은 멀리까지 유지 |
| **`LOD Group`** | 카메라 거리에 따라 고해상도 메시(`LOD0`) → 저해상도 메시(`LOD1`, `LOD2`) → 컬링(`Culled`) 전환 | 정점 수와 작은 삼각형 오버드로우 감소. 단, 메시 에셋을 여러 벌 들고 있어야 하므로 메모리 증가 |

**자주 겪는 버그 — 잘못된 `Bounds`로 오브젝트가 갑자기 사라짐**:
프러스텀 컬링은 정점을 일일이 검사하지 않고 렌더러의 `Bounds`(AABB 상자)만 본다.
- 정점 셰이더에서 정점 위치를 크게 옮기거나,
- `SkinnedMeshRenderer`(캐릭터 애니메이션)가 루트 본에서 멀리 이동했는데 원본 바운딩 박스는 제자리에 남아 있으면,
카메라가 아직 캐릭터를 보고 있는데도 CPU가 "시야 밖"으로 착각해 통째로 꺼버린다. 이때는 메시의 `Bounds`를 넉넉히 키우거나, `SkinnedMeshRenderer`의 `Update When Offscreen`(비용 있음)을 확인한다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 오버드로우(overdraw) | 한 픽셀이 한 프레임에 여러 번 칠해지는 현상 |
| `Early-Z` | 프래그먼트 셰이더 실행 전에 하는 깊이 테스트 최적화 |
| `Alpha Clip` / `discard` | 셰이더 안에서 픽셀을 버려 구멍을 내는 방식 |
| `TBDR` | 타일 기반 지연 렌더링. 모바일 GPU 구조 |
| `Bounds` (AABB) | 렌더러를 감싸는 축 정렬 경계 상자. 컬링 검사에 쓴다 |
| `Occluder` / `Occludee` | 가리는 오브젝트 / 가려지는 오브젝트 |
| `LOD` | 거리별 세부 수준(Level of Detail) |

## 5. 확인 실습

{% hint style="info" %}
NOTE: 이 절은 AI, 자동완성, 검색 없이 진행한다. 막히면 3절로 돌아간다.
{% endhint %}

### 실습 1: 불투명 50겹 vs 반투명 50겹 오버드로우와 해상도 실험 (20분)

카메라 바로 앞에 화면을 가득 채우는 `Quad` 50장을 0.05 간격으로 겹쳐 세우는 스크립트를 작성한다.

```csharp
// Unity: OverdrawQuadStack.cs
using UnityEngine;

public class OverdrawQuadStack : MonoBehaviour
{
    [SerializeField] private int count = 50;
    [SerializeField] private Material targetMaterial;

    private void Start()
    {
        Camera cam = Camera.main;
        if (cam == null) return;

        for (int i = 0; i < count; i++)
        {
            GameObject quad = GameObject.CreatePrimitive(PrimitiveType.Quad);
            quad.transform.SetParent(transform);
            quad.transform.position = cam.transform.position + cam.transform.forward * (2f + i * 0.05f);
            quad.transform.rotation = cam.transform.rotation;
            quad.transform.localScale = new Vector3(6f, 6f, 1f);

            if (targetMaterial != null)
            {
                quad.GetComponent<MeshRenderer>().sharedMaterial = targetMaterial;
            }
        }
    }
}
```

1. `URP/Lit` 머티리얼 두 개를 만든다: 하나는 `Surface Type = Opaque`, 다른 하나는 `Surface Type = Transparent`(알파값 0.1).
2. `Window > Analysis > Rendering Debugger` → `Rendering` → `Overdraw Mode`를 켜고 두 머티리얼일 때 화면 밝기가 어떻게 다른지 확인한다.
3. Game 뷰 해상도를 `Low (예: 960x540)`와 `High (예: 3840x2160 / 4K)`로 바꿔가며 `Stats` 창의 프레임 시간(또는 Profiler의 CPU/GPU 시간 — Mac 환경에서 GPU 프로파일러가 지원되지 않으면 `Stats` 창의 ms 또는 Frame Timing으로 비교)을 측정해 표를 채운다.

| 조건 | 예측: 실제 픽셀 셰이더가 도는 겹 수 | Rendering Debugger Overdraw 색상/밝기 | 저해상도 ms | 고해상도(4K) ms |
|---|---|---|---|---|
| 1) `Opaque` Quad 50겹 | | | | |
| 2) `Transparent` Quad 50겹 | | | | |

<details><summary>해설 및 확인 포인트</summary>

- **불투명 50겹**: 앞에서 뒤로 정렬되어 그려지므로 맨 앞 1장이 깊이 버퍼를 채우면 나머지 49장은 `Early-Z`로 픽셀 셰이더를 건너뛴다(단, URP 설정이나 Depth Prepass 유무에 따라 깊이 패스는 돌 수 있다).
- **반투명 50겹**: 뒤에서 앞으로 50장 모두 프래그먼트 셰이더와 알파 블렌딩을 수행한다. 해상도를 960x540에서 4K로 올리면 픽셀 수가 16배가 되고, 그 16배를 50겹 모두 칠하므로 프레임 시간이 눈에 띄게 느려진다.

</details>

### 실습 2: 레이어별 컬 거리와 잘못된 Bounds로 사라지는 버그 재현 (10분)

1. 큐브에 아래 `BrokenBoundsDemo` 스크립트를 붙여 메시의 `bounds`를 아주 작게(또는 엉뚱한 위치로) 강제 변경해 보고, 카메라를 조금만 돌려도 화면 한가운데 있던 큐브가 통째로 사라지는 현상을 확인한다.

```csharp
// Unity: BrokenBoundsDemo.cs
using UnityEngine;

public class BrokenBoundsDemo : MonoBehaviour
{
    [SerializeField] private Vector3 customBoundsCenter = new Vector3(0f, 0f, 50f);
    [SerializeField] private float smallDetailCullDistance = 10f;

    private void Start()
    {
        MeshFilter mf = GetComponent<MeshFilter>();
        if (mf != null)
        {
            // 실제 정점은 (0,0,0)에 있는데 Bounds 중심을 (0,0,50)으로 속임
            mf.mesh.bounds = new Bounds(customBoundsCenter, Vector3.one);
        }

        Camera cam = Camera.main;
        if (cam != null)
        {
            float[] distances = new float[32];
            distances[gameObject.layer] = smallDetailCullDistance;
            cam.layerCullDistances = distances;
        }
    }
}
```

2. 두 현상은 한 번에 하나씩 본다. 가짜 `Bounds`만 볼 때는 `smallDetailCullDistance`를 0으로 둔다(0이면 카메라의 Far 값을 쓴다). 컬 거리만 볼 때는 `customBoundsCenter`를 `(0, 0, 0)`으로 둔다. 가짜 중심이 50m 밖에 있으면 10m 컬 거리에 항상 걸려 버리기 때문이다.
3. Scene 뷰와 Game 뷰를 나란히 놓고 카메라를 회전하거나 뒤로 빼면서 아래 표를 채운다.

| 확인 항목 | 관찰 결과 |
|---|---|
| `customBoundsCenter`가 `(0, 0, 50)`일 때 카메라를 살짝 돌리면 큐브가 왜 사라지는가? | |
| 카메라와의 거리가 `smallDetailCullDistance(10m)`를 넘을 때 일어나는 일은? | |

## 6. 확인 문제

소리 내어 30초 안에 답해 본 뒤 펼쳐서 비교한다.

**Q1. 반투명(Transparent) 오브젝트가 불투명(Opaque) 오브젝트보다 렌더링 비용이 비싼 이유는 무엇인가요?**
<details><summary>모범 답안</summary>
불투명 오브젝트는 앞에서 뒤로 정렬해 그리고 깊이 버퍼에 값을 기록하므로, 앞 오브젝트에 가려진 뒤쪽 픽셀들은 GPU의 `Early-Z` 테스트에서 걸러져 프래그먼트 셰이더 실행을 건너뜁니다. 반면 반투명 오브젝트는 깊이 버퍼 쓰기를 끄고 뒤에서 앞으로 정렬해 그리기 때문에 가려진 픽셀이라도 모두 프래그먼트 셰이더를 실행하고 알파 블렌딩까지 수행해야 합니다. 이 과정에서 겹친 횟수만큼 오버드로우와 메모리 대역폭 소모가 발생합니다.

</details>

**Q2. 오클루전 컬링(Occlusion Culling)은 켜면 항상 성능에 이득인가요?**
<details><summary>모범 답안</summary>
항상 이득은 아닙니다. 오클루전 컬링은 사전 베이크된 가시성 데이터를 메모리에 올리고 매 프레임 CPU에서 가려짐 여부를 계산하는 비용이 듭니다. 실내 복도나 빌딩 숲처럼 큰 벽이 많은 맵에서는 드로우 콜을 크게 줄여 이득이지만, 가리는 장애물이 적은 오픈 필드나 위에서 내려다보는 탑뷰·쿼터뷰 게임에서는 컬링되는 오브젝트는 거의 없는데 CPU 판정 비용만 추가되어 오히려 손해일 수 있습니다.

</details>

**Q3. 알파 블렌딩 대신 알파 테스트(`Alpha Clip`, 셰이더의 `clip`/`discard`)를 쓰면 반투명 문제가 다 해결되나요?**
<details><summary>모범 답안</summary>
정렬 문제는 해결되지만 성능 함정이 있습니다. 알파 테스트는 프래그먼트 셰이더 안에서 픽셀을 버릴지 결정하기 때문에, GPU가 셰이더 실행 전에 깊이를 판정하는 `Early-Z` 최적화를 제대로 쓰지 못하게 만듭니다. 특히 모바일의 타일 기반(TBDR) GPU에서는 `discard`가 타일 내 숨은 면 제거(HSR) 효율을 크게 떨어뜨릴 수 있어 꼭 필요한 곳에만 제한적으로 써야 합니다.

</details>

**Q4. 캐릭터나 이펙트가 카메라 화면 안에 분명히 있는데 특정 각도에서 갑자기 통째로 사라졌다가 나타납니다. 원인이 무엇일까요?**
<details><summary>모범 답안</summary>
프러스텀 컬링에 사용되는 렌더러의 바운딩 박스(`Bounds`)가 실제 화면에 그려지는 정점 위치와 맞지 않기 때문입니다. 본 애니메이션으로 메시는 멀리 이동했는데 `SkinnedMeshRenderer`의 `Bounds`가 갱신되지 않았거나, 정점 셰이더에서 정점 위치를 크게 변형했을 때 자주 발생합니다. 메시의 `Bounds` 크기를 여유 있게 늘리거나 `SkinnedMeshRenderer`의 `localBounds` 또는 `Update When Offscreen` 설정을 점검해 해결합니다.

</details>

## 참조

- [오클루전 컬링 (Unity 공식 문서)](https://docs.unity3d.com/Manual/OcclusionCulling.html)
- [URP Rendering Debugger (Unity 공식 문서)](https://docs.unity3d.com/Manual/urp/features/rendering-debugger.html)
- [LOD Group (Unity 공식 문서)](https://docs.unity3d.com/Manual/class-LODGroup.html)
- [Camera.layerCullDistances API 문서](https://docs.unity3d.com/ScriptReference/Camera-layerCullDistances.html)

이전: [Day 14 · 배칭 🎮](day14-batching.md) · 다음: [Day 16 · 셰이더 variant와 첫 사용 스톨 🎮](day16-shader-variants-warmup.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오늘의 한 줄: 이 날의 핵심을 내 말로 한 문장으로 적는다.
- [ ] 반투명 이펙트가 불투명보다 비싼 이유를 내 말로 설명하면?
- [ ] 오클루전 컬링을 켜지 않는 편이 나은 내 프로젝트(또는 가상의 게임) 사례는?
