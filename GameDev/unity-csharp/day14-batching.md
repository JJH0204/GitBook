# Day 14 · 배칭 🎮

> 3주차 렌더링과 측정 · 60분 · 준비물: 🎮 Unity 6 (`practice/UnityLab`, URP)

## 오늘의 목표
- 정적 배칭(`Static Batching`), 동적 배칭(`Dynamic Batching`), `SRP Batcher`, `GPU Instancing`이 각각 무엇을 줄이고 어떤 비용을 치르는지 비교할 수 있다.
- 왜 URP에서 `MaterialPropertyBlock`을 쓰면 오히려 느려질 수 있는지 `SRP Batcher`의 원리로 설명할 수 있다.
- Frame Debugger의 배칭 실패 사유(`Why this draw call can't be batched with the previous one`)를 읽고 원인을 고칠 수 있다.

---

## 1. 읽기 (20분)

### 1-1. 배칭의 진짜 목적: 드로우당 CPU 비용 줄이기

Day 13에서 봤듯이 드로우가 많을 때의 병목은 GPU가 아니라 **CPU가 상태를 바꾸고(`SetPass call`) 드로우를 제출하는 비용**이다. 배칭 기법들은 모두 이 CPU 비용을 줄이려 하지만, 줄이는 대상이 서로 다르다.

| 기법 | 줄이는 것 | 조건 | 대가(단점) |
|---|---|---|---|
| **Static Batching** | 드로우 콜 수 | `Batching Static` 체크, **같은 머티리얼** | 합쳐진 메시만큼 **메모리 사용량 증가**, 이동 불가 |
| **Dynamic Batching** | 드로우 콜 수 | 작은 메시(정점 약 300개 / 정점 속성 900개 이하), 같은 머티리얼 | 매 프레임 CPU가 정점을 월드 좌표로 변환 → **오히려 CPU 비용 증가 가능**(URP 기본 꺼짐) |
| **SRP Batcher** | **`SetPass` 상태 전환 비용** (드로우 콜 수는 안 줄임) | 호환 셰이더(`UnityPerMaterial` 상수 버퍼 규격), **같은 셰이더 variant** | 메시/머티리얼이 달라도 되지만 `MaterialPropertyBlock` 사용 시 깨짐 |
| **GPU Instancing** | 드로우 콜 수 | **같은 메시 + 같은 머티리얼**(인스턴스별 프로퍼티 가능) | 메시 종류가 다양하면 효과가 작음. SRP Batcher 대상이면 SRP Batcher가 우선됨 |

### 1-2. Static Batching과 Dynamic Batching

- **Static Batching**: 빌드 시점(또는 런타임 초기화 시점)에 움직이지 않는 오브젝트들의 메시를 월드 좌표로 변환해 큰 공유 정점·인덱스 버퍼로 합친다. 같은 머티리얼을 쓰는 정적 오브젝트들을 한 번(또는 적은 횟수)의 드로우로 그린다. 단, 똑같은 나무 프리팹 100개를 배치하면 나무 정점 데이터가 100벌 복사되어 **메모리를 크게 먹는다**.
- **Dynamic Batching**: 움직이는 작은 메시들을 매 프레임 CPU에서 합쳐 그린다. 정점 수 제한(보통 정점 속성 900개 이하, 즉 일반 셰이더 기준 정점 300개 이하)이 빡빡하고, 현대 그래픽스 API에서는 합치는 CPU 비용이 드로우 제출 비용보다 클 때가 많아 URP에서는 기본으로 꺼져 있으며 거의 권장하지 않는다.

### 1-3. SRP Batcher: 드로우 수는 그대로, 상태 전환만 공짜에 가깝게

URP의 기본이자 가장 중요한 최적화다. `SRP Batcher`는 메시를 합치지 않아서 **드로우 콜 자체의 개수는 줄이지 않는다.** 대신 머티리얼 프로퍼티를 GPU의 영속 상수 버퍼(`persistent CBUFFER`, `UnityPerMaterial`)에 미리 올려 두고, 오브젝트별 행렬도 큰 GPU 버퍼(`UnityPerDraw`)에 모아 둔다.

그 결과 **서로 다른 머티리얼과 서로 다른 메시**라도 **같은 셰이더 variant**만 쓰면 CPU가 머티리얼 상태를 다시 바인딩할 필요가 없다. `SetPass call`을 1번만 내고 오프셋만 바꿔가며 빠르게 드로우를 던진다.

**함정 — `MaterialPropertyBlock`과의 충돌**:
과거 Built-in 파이프라인에서는 머티리얼 인스턴스를 늘리지 않고 색상을 바꾸려고 `Renderer.SetPropertyBlock(mpb)`을 즐겨 썼다. 하지만 URP에서 렌더러에 `MaterialPropertyBlock`을 붙이면 그 오브젝트는 영속 CBUFFER 경로를 탈 수 없어 **`SRP Batcher`에서 즉시 탈락**한다. 오브젝트마다 색이 조금씩 다르다면 차라리 같은 셰이더를 쓰는 별도 머티리얼 에셋(또는 인스턴스)을 쓰거나, 대량 복제라면 GPU Instancing을 쓰는 편이 낫다.

### 1-4. GPU Instancing과 Unity 6의 GPU Resident Drawer

`GPU Instancing`은 **같은 메시와 같은 머티리얼**을 쓰는 오브젝트 수백~수천 개를 단 한 번의 드로우 콜로 그린다. 위치·회전·색상 같은 인스턴스별 데이터는 배열 버퍼로 묶어 보낸다.

주의할 점은 **우선순위**다. 일반 `MeshRenderer`가 `SRP Batcher`와 호환되면 Unity는 머티리얼의 `Enable GPU Instancing`을 켜도 **`SRP Batcher`를 우선 사용**한다. 진짜 인스턴싱으로 대량 드로우를 묶고 싶다면:
1. `Graphics.RenderMeshInstanced` API로 직접 행렬 배열을 넘겨 그리거나,
2. 셰이더를 SRP Batcher 비호환으로 만들거나(비권장),
3. Unity 6의 **`GPU Resident Drawer`**를 사용한다.

**Unity 6 `GPU Resident Drawer`**: `BatchRendererGroup(BRG)` 위에 구축된 기능으로, `Forward+` 렌더링 경로에서 씬의 정적·동적 `MeshRenderer`를 자동으로 인스턴싱해 GPU 주도(`GPU-driven`)로 그린다. 수동으로 API를 호출하거나 메시를 합치지 않아도 같은 메시를 공유하는 오브젝트들의 드로우 콜과 CPU 제출 비용을 크게 줄여 준다.

### 1-5. UI와 2D 스프라이트 배칭

2D와 `uGUI`는 메커니즘이 조금 다르다. UI는 `Canvas` 단위로 하위 요소들의 메시를 매번 합쳐서(리빌드, `Canvas rebuild`) 배칭한다. 이때 서로 다른 텍스처를 쓰거나 그리기 순서상 다른 텍스처가 사이에 끼면 배칭이 깨진다. 그래서 UI 아이콘과 2D 스프라이트는 **`Sprite Atlas`**로 한 장의 텍스처에 묶어야 `SetPass`와 드로우가 줄어든다. 또한 매 프레임 바뀌는 텍스트·체력바와 가만히 있는 배경 UI를 한 `Canvas`에 두면 전체 메시를 다시 합치느라 CPU가 낭비되므로 **동적 UI와 정적 UI의 `Canvas`를 분리**한다.

### 1-6. Frame Debugger에서 배칭이 깨진 이유 읽기

Frame Debugger에서 `SRP Batch`나 `Dynamic Batch`, `Draw Mesh (Instanced)` 항목을 누르면 오른쪽 상단에 **`Why this draw call can't be batched with the previous one`** 문구가 나온다. 자주 나오는 사유는 다음과 같다(정확한 문구는 Unity 버전마다 조금 다르다).

- `Node has different shader / different shader keywords`: 이전 드로우와 셰이더나 키워드 조합(variant)이 다르다.
- `Node is not compatible with SRP Batcher (Node has MaterialPropertyBlock)`: `MaterialPropertyBlock` 때문에 SRP Batcher에서 빠졌다.
- `Objects have different Materials / Meshes`: 정적·동적 배칭이나 인스턴싱에서 머티리얼 또는 메시가 달라 묶이지 못했다.
- `Lightmapped objects use different lightmaps`: 라이트맵 텍스처 인덱스가 달라 배칭이 나뉘었다.

---

## 2. 손으로 확인 (30분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 실습 1: 배칭 방식별 수치 비교와 MaterialPropertyBlock 함정 확인 (20분)

`practice/UnityLab`에서 아래 스크립트를 붙여 큐브 200개를 생성하고, 조건을 바꿔가며 `Stats` 창과 `Frame Debugger`를 확인한다.

```csharp
// Unity: BatchingLab.cs
using UnityEngine;

public class BatchingLab : MonoBehaviour
{
    public enum ColorMode
    {
        SharedMaterial,
        PerRendererPropertyBlock,
        SeparateMaterialInstances
    }

    [SerializeField] private int count = 200;
    [SerializeField] private Material baseMaterial;
    [SerializeField] private ColorMode colorMode = ColorMode.SharedMaterial;
    [SerializeField] private bool useRenderMeshInstanced = false;
    [SerializeField] private Mesh instancedMesh;

    private Matrix4x4[] matrices;

    private void Start()
    {
        if (useRenderMeshInstanced)
        {
            matrices = new Matrix4x4[count];
            for (int i = 0; i < count; i++)
            {
                Vector3 pos = new Vector3((i % 20) * 1.5f, (i / 20) * 1.5f, 0f);
                matrices[i] = Matrix4x4.TRS(pos, Quaternion.identity, Vector3.one);
            }
            return;
        }

        MaterialPropertyBlock mpb = new MaterialPropertyBlock();
        for (int i = 0; i < count; i++)
        {
            GameObject go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            go.transform.SetParent(transform);
            go.transform.position = new Vector3((i % 20) * 1.5f, (i / 20) * 1.5f, 0f);

            MeshRenderer r = go.GetComponent<MeshRenderer>();
            r.sharedMaterial = baseMaterial;

            Color c = Color.HSVToRGB((float)i / count, 0.8f, 0.9f);
            if (colorMode == ColorMode.PerRendererPropertyBlock)
            {
                mpb.SetColor("_BaseColor", c);
                r.SetPropertyBlock(mpb);
            }
            else if (colorMode == ColorMode.SeparateMaterialInstances)
            {
                r.material.SetColor("_BaseColor", c); // 인스턴스 머티리얼 생성
            }
        }
    }

    private void Update()
    {
        if (useRenderMeshInstanced && instancedMesh != null && baseMaterial != null)
        {
            Graphics.RenderMeshInstanced(new RenderParams(baseMaterial), instancedMesh, 0, matrices);
        }
    }
}
```

실행 전에 각 조건에서 `SRP Batcher`가 작동할지 예측한 뒤, 실행하여 표를 채운다(`baseMaterial`은 `URP/Lit`에 `Enable GPU Instancing`을 체크해 둔다).

| 조건 | 예측: SRP Batcher 작동 여부 | Batches | SetPass calls | Frame Debugger에 표시된 드로우 이름과 배칭 실패 사유 |
|---|---|---|---|---|
| 1) `SharedMaterial` (기본) | | | | |
| 2) `PerRendererPropertyBlock` (`MaterialPropertyBlock`) | | | | |
| 3) `SeparateMaterialInstances` (`r.material` 색상 변경) | | | | |
| 4) `useRenderMeshInstanced` 체크 (`Graphics.RenderMeshInstanced`) | | | | |
| 5) 씬에 미리 놓은 큐브 20개를 `Batching Static`으로 체크 | | | | |

<details><summary>해설 및 확인 포인트</summary>

- **2번(`PerRendererPropertyBlock`)**: `MaterialPropertyBlock`을 쓰는 순간 그 렌더러들이 `SRP Batch`에서 빠지고, 배칭 실패 사유에 `MaterialPropertyBlock`이 언급된다. 머티리얼에 GPU Instancing이 켜져 있으므로 인스턴싱으로 묶이는지, 개별 드로우로 쪼개지는지도 직접 확인해 기록한다(`_BaseColor`는 URP/Lit에서 인스턴스별 프로퍼티가 아니다).
- **3번(`SeparateMaterialInstances`)**: 머티리얼 인스턴스가 200개 생겼는데도 모두 같은 `URP/Lit` 셰이더 variant를 쓰므로 **`SRP Batcher` 하나로 묶여 `SetPass calls`가 그대로 유지**된다(단, 끝날 때 생성된 머티리얼 인스턴스를 `Destroy`하지 않으면 메모리에 남는다).
- **4번(`Graphics.RenderMeshInstanced`)**: GameObject 없이 200개가 `Draw Mesh (Instanced)` 1번으로 그려진다.
- **5번(`Batching Static`)**: Frame Debugger에서 메시 이름이 `Combined Mesh (root: scene)`으로 바뀐다. 합쳐진 버퍼를 쓰는 드로우가 몇 개로 나오는지, SRP Batcher와 어떻게 함께 표시되는지 기록한다.

</details>

### 실습 2: URP Asset에서 SRP Batcher를 껐을 때 비교 (10분)

프로젝트의 현재 `URP Asset` 인스펙터(고급 설정)에서 `SRP Batcher` 체크를 끄고, 위 실습의 **1번(`SharedMaterial`)**과 **3번(`SeparateMaterialInstances`)**을 다시 측정해 본다.

1. `SharedMaterial`일 때 `SRP Batcher`를 끄면 대신 어떤 배칭이 동작하는가? (`Enable GPU Instancing`이 켜져 있을 때)
2. `SeparateMaterialInstances`일 때 `SRP Batcher`를 끄면 `Batches`와 `SetPass calls`가 어떻게 폭증하는가?

---

## 3. 면접 대비 (10분)

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. SRP Batcher와 GPU Instancing의 차이를 설명해 주세요.**
<details><summary>모범 답안</summary>
SRP Batcher는 드로우 콜의 개수를 줄이지 않고, 같은 셰이더 variant를 쓰는 드로우들의 머티리얼 데이터를 GPU 영속 버퍼에 유지해 `SetPass` 상태 전환 비용을 없애는 방식입니다. 따라서 메시와 머티리얼이 서로 달라도 셰이더 variant만 같으면 묶입니다. 반면 GPU Instancing은 반드시 같은 메시와 같은 머티리얼을 쓰는 오브젝트들을 하나의 드로우 콜로 합쳐 그리는 방식이라 풀이나 총알처럼 동일 메시가 대량으로 반복될 때 효과적입니다.

</details>

**Q2. URP 프로젝트에서 오브젝트마다 색상을 다르게 주려고 `MaterialPropertyBlock`을 썼더니 오히려 느려졌습니다. 왜 그럴까요?**
<details><summary>모범 답안</summary>
URP에서는 기본적으로 SRP Batcher가 켜져 있는데, 렌더러에 `MaterialPropertyBlock`을 사용하면 영속 상수 버퍼 구조와 호환되지 않아 그 오브젝트가 SRP Batcher에서 빠져나오기 때문입니다. 결과적으로 배칭이 끊기며 전후로 상태 전환 비용이 발생합니다. URP에서는 같은 셰이더를 공유하는 머티리얼 인스턴스를 쓰거나, 동일 메시 대량 렌더링이라면 GPU Instancing용 인스턴스 프로퍼티나 `GPU Resident Drawer`를 쓰는 것이 맞습니다.

</details>

**Q3. Static Batching의 원리와 주의할 점은 무엇인가요?**
<details><summary>모범 답안</summary>
움직이지 않는 오브젝트들의 메시를 월드 좌표 기준으로 미리 하나의 큰 정점·인덱스 버퍼로 합쳐 드로우 콜을 줄이는 기법입니다. 런타임 CPU 부담이 거의 없다는 장점이 있지만, 같은 프리팹을 여러 개 배치하면 각 오브젝트의 정점 데이터가 중복으로 복사되어 메모리 사용량이 크게 늘어납니다. 따라서 정점 수가 많은 메시가 수백 개 반복되는 숲 같은 곳에서는 Static Batching보다 GPU Instancing이 메모리에 유리합니다.

</details>

**Q4. UI(uGUI)에서 드로우 콜이 늘어나는 주된 원인과 해결 방법은 무엇인가요?**
<details><summary>모범 답안</summary>
uGUI는 같은 `Canvas` 안에서 머티리얼과 텍스처가 같고 깊이 순서가 연속된 요소들을 하나의 메시로 합쳐 그립니다. 만약 서로 다른 텍스처를 가진 이미지나 텍스트가 겹치며 번갈아 배치되면 배칭이 계속 끊깁니다. 이를 줄이려면 UI 스프라이트들을 `Sprite Atlas`로 묶어 같은 텍스처를 참조하게 하고, 자주 바뀌는 UI와 고정된 UI의 `Canvas`를 분리해 불필요한 메시 리빌드 비용도 함께 막아야 합니다.

</details>

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [SRP Batcher (Unity 공식 문서)](https://docs.unity3d.com/Manual/SRPBatcher.html)
- [GPU Instancing (Unity 공식 문서)](https://docs.unity3d.com/Manual/GPUInstancing.html)
- [GPU Resident Drawer (Unity 6 공식 문서)](https://docs.unity3d.com/Manual/urp/gpu-resident-drawer.html)
- [정적 배칭과 동적 배칭 (Unity 공식 문서)](https://docs.unity3d.com/Manual/DrawCallBatching.html)
