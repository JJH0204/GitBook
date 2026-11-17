# Day 13 · 렌더링 파이프라인 한 바퀴 🎮

> 3주차 렌더링과 측정 · 60분 · 준비물: 🎮 Unity 6 (`practice/UnityLab`, URP)

## 오늘의 목표
- 한 프레임이 메인 스레드, 렌더 스레드, 드라이버, GPU를 거쳐 화면에 그려지는 흐름을 설명할 수 있다.
- 드로우 콜(`draw call`)과 `SetPass call`의 차이, 그리고 왜 그리기 명령 자체보다 상태 변경이 비싼지 설명할 수 있다.
- 프로파일러 마커와 해상도 조절로 현재 프레임이 CPU 바운드인지 GPU 바운드인지 구분할 수 있다.

---

## 1. 읽기 (20분)

### 1-1. 한 프레임이 화면에 나오기까지: 스레드와 하드웨어

Unity가 한 프레임을 그릴 때는 CPU와 GPU가 파이프라인처럼 분담해 일한다.

```
[메인 스레드] ──(고수준 렌더 명령)──▶ [렌더 스레드] ──(API 호출)──▶ [그래픽 드라이버] ──▶ [GPU]
```

| 단계 | 하는 일 |
|---|---|
| **메인 스레드(`Main Thread`)** | `Update`/애니메이션/물리 실행 → 카메라 시야 밖 오브젝트 제외(`컬링(culling)`) → 그릴 순서 정렬(`sorting`) → 무엇을 어떻게 그릴지 고수준 렌더링 명령 기록 |
| **렌더 스레드(`Render Thread`)** | 메인 스레드가 넘긴 명령을 그래픽스 API 호출(D3D12, Vulkan, Metal, D3D11)로 번역 |
| **그래픽 드라이버(`Driver`)** | API 호출과 렌더 상태를 검증(`validation`)하고 GPU가 읽을 하드웨어 명령 버퍼로 변환해 제출 |
| **GPU** | 명령 버퍼를 받아 정점과 픽셀을 대규모 병렬로 처리해 렌더 타깃(`render target`)에 기록 |

GPU가 N번 프레임을 그리는 동안 CPU는 N+1번 프레임을 준비한다. 어느 한쪽이 늦어지면 다른 쪽이 기다리게 된다.

### 1-2. GPU 파이프라인 단계

GPU로 넘어간 메시는 다음 단계를 순서대로 거친다.

| 순서 | 단계 | 역할 |
|---|---|---|
| 1 | `입력 어셈블리(Input Assembly)` | 정점 버퍼(`vertex buffer`)와 인덱스 버퍼(`index buffer`)에서 삼각형의 정점 데이터를 읽는다 |
| 2 | `정점 셰이더(Vertex Shader)` | 정점마다 실행된다. 로컬 좌표를 월드 → 뷰 → 클립 공간(`clip space`) 좌표로 변환한다 |
| 3 | `래스터화(Rasterization)` | 삼각형이 화면의 어느 픽셀(`프래그먼트(fragment)`)을 덮는지 계산하고 정점 속성을 보간한다(고정 기능 하드웨어) |
| 4 | `프래그먼트 셰이더(Fragment/Pixel Shader)` | 픽셀마다 실행되어 텍스처 샘플링과 조명 계산으로 최종 색상을 구한다 |
| 5 | `깊이·스텐실 테스트(Depth/Stencil Test)` | 깊이 버퍼(`Z-buffer`)와 비교해 이미 더 가까운 픽셀에 가려진 픽셀을 버린다 |
| 6 | `블렌딩(Blending)` | 테스트를 통과한 색을 렌더 타깃의 기존 픽셀 색과 합쳐 기록한다 |

### 1-3. 드로우 콜과 SetPass call: 왜 비싼가

`드로우 콜(draw call)`은 CPU가 GPU에 "이 메시를 지금 바인딩된 셰이더·머티리얼 상태로 그려라"라고 내리는 명령 하나다. 흔히 "드로우 콜이 많으면 GPU가 힘들다"고 오해하지만, **드로우 콜 비용의 본질은 CPU 비용**이다.

그리기 명령을 내리기 직전에 다른 머티리얼이나 셰이더로 바뀌면, CPU와 그래픽 드라이버는 새 셰이더 프로그램, 텍스처, 상수 버퍼(`constant buffer`), 블렌드·깊이 상태를 다시 바인딩하고 이 조합이 유효한지 검증해야 한다. 이 상태 전환을 Unity에서는 `SetPass call`이라고 부른다.

| 지표 (Stats 창 / Frame Debugger) | 의미 |
|---|---|
| `Batches` | 엔진이 묶어서 제출한 드로우 단위 수(내부적으로 하나 이상의 드로우 콜 포함) |
| `SetPass calls` | 셰이더 패스(렌더 상태)를 전환한 횟수. 상태 검증 비용이 커서 줄이는 것이 핵심이다 |

### 1-4. CPU 바운드 vs GPU 바운드

최종 프레임 시간은 CPU 시간과 GPU 시간 중 **더 긴 쪽**이 결정한다.

- **GPU 바운드(`GPU-bound`) 징후**:
  - Profiler에서 메인 스레드가 `Gfx.WaitForPresentOnGfxThread`에서 오래 멈춰 있거나, 렌더 스레드가 GPU 완료를 기다린다. CPU는 자기 할 일을 다 끝내고 GPU가 이전 프레임을 다 그릴 때까지 블로킹된 상태다.
  - 해상도를 절반으로 줄였을 때 프레임 시간이 눈에 띄게 줄어든다(픽셀 처리량, 즉 `필레이트(fill rate)` 병목).
- **CPU 바운드(`CPU-bound`) 징후**:
  - `Update`, 물리, 컬링, 혹은 과도한 드로우 제출 때문에 메인 스레드나 렌더 스레드 자체가 길다. 해상도를 낮춰도 프레임 시간이 거의 그대로다.
- **혼동 주의 — `WaitForTargetFPS`**:
  - VSync나 `Application.targetFrameRate`에 맞추려고 남은 시간을 **일부러 쉬는 마커**다. 성능 병목이 아니라 오히려 여유 시간이 있다는 뜻이다.

### 1-5. URP의 한 프레임 구조

URP(`Universal Render Pipeline`)는 카메라마다 다음 순서로 프레임을 그린다.

1. **카메라별 컬링(`Culling`)**: 카메라 시야(`Frustum`) 안에 있는 렌더러만 추린다.
2. **불투명 오브젝트(`Opaques`)**: 카메라에서 가까운 것부터 먼 순서(앞→뒤)로 그려 깊이 버퍼를 먼저 채운다.
3. **스카이박스(`Skybox`)**: 아직 아무것도 안 그려진 빈 배경 픽셀에만 하늘을 그린다.
4. **반투명 오브젝트(`Transparents`)**: 먼 것부터 가까운 순서(뒤→앞)로 정렬해 기존 색 위에 블렌딩한다.
5. **포스트 프로세싱(`Post-processing`)**: 완성된 화면 텍스처에 블룸, 톤매핑 등을 적용한다.

URP가 제공하는 렌더링 경로(`Rendering Path`) 3가지도 한 줄로 구분해 둔다.
- `Forward`: 오브젝트마다 영향을 주는 라이트를 순회하며 그린다. 오브젝트당 실시간 추가 라이트 개수 제한이 있다.
- `Forward+`: 화면을 작은 타일로 나눠 타일별 라이트 목록을 만든다. 오브젝트당 라이트 개수 제한 없이 많은 조명을 그릴 수 있다.
- `Deferred`: 기하 정보(색, 법선, 깊이)를 먼저 `G-Buffer`에 그린 뒤 화면 공간에서 조명을 한 번에 계산한다. 조명이 매우 많을 때 유리하지만 메모리 대역폭을 많이 쓰고 반투명은 여전히 Forward로 처리한다.

---

## 2. 손으로 확인 (30분)

> AI, 자동완성, 검색 없이. 막히면 위의 읽기로 돌아간다.

### 실습 1: 큐브 100개와 머티리얼 조건별 Batches / SetPass 비교 (20분)

`practice/UnityLab`에서 빈 씬을 열고 아래 스크립트를 작성해 빈 GameObject에 붙인다.
인스펙터에 넣을 머티리얼 배열을 준비한다.

```csharp
// Unity: CubeGridSpawner.cs
using UnityEngine;

public class CubeGridSpawner : MonoBehaviour
{
    public enum MaterialMode
    {
        OneSharedMaterial,
        TenMaterialsSameShader,
        TenMaterialsDifferentKeywords
    }

    [SerializeField] private MaterialMode mode = MaterialMode.OneSharedMaterial;
    [SerializeField] private Material sharedMaterial;
    [SerializeField] private Material[] tenSameShaderMaterials;
    [SerializeField] private Material[] tenDifferentKeywordMaterials;

    private void Start()
    {
        for (int i = 0; i < 100; i++)
        {
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.transform.SetParent(transform);
            cube.transform.position = new Vector3((i % 10) * 1.5f, (i / 10) * 1.5f, 0f);

            MeshRenderer renderer = cube.GetComponent<MeshRenderer>();
            if (mode == MaterialMode.OneSharedMaterial && sharedMaterial != null)
            {
                renderer.sharedMaterial = sharedMaterial;
            }
            else if (mode == MaterialMode.TenMaterialsSameShader && tenSameShaderMaterials.Length > 0)
            {
                renderer.sharedMaterial = tenSameShaderMaterials[i % tenSameShaderMaterials.Length];
            }
            else if (mode == MaterialMode.TenMaterialsDifferentKeywords && tenDifferentKeywordMaterials.Length > 0)
            {
                renderer.sharedMaterial = tenDifferentKeywordMaterials[i % tenDifferentKeywordMaterials.Length];
            }
        }
    }
}
```

1. `URP/Lit` 머티리얼 1개(`sharedMaterial`), 색상만 다른 `URP/Lit` 머티리얼 10개(`tenSameShaderMaterials`), 그리고 서로 다른 셰이더(예: `URP/Lit`, `URP/Simple Lit`, `URP/Unlit`, 노말맵·에미션 키워드 조합이 다른 머티리얼 등) 10개(`tenDifferentKeywordMaterials`)를 만든다.
2. 실행하기 전에 각 모드에서 `Batches`와 `SetPass calls`가 어떻게 달라질지 **예측 칸에 먼저 적는다.**
3. Play 모드에서 Game 뷰 우측 상단 `Stats` 창을 열고 표를 채운다(방향광 그림자는 끄고 비교하면 숫자 해석이 쉽다).

| 조건 | 예측 Batches | 예측 SetPass | 실측 Batches | 실측 SetPass | 왜 이렇게 나왔는가 |
|---|---|---|---|---|---|
| 1) 머티리얼 1개 공유 | | | | | |
| 2) 같은 셰이더(`URP/Lit`) 머티리얼 10개 | | | | | |
| 3) 다른 셰이더/키워드 머티리얼 10개 | | | | | |

<details><summary>해설 및 확인 포인트</summary>

- 정확한 숫자는 카메라는 물론 씬의 조명, 그림자, 스카이박스 여부에 따라 기본 패스가 몇 개 추가되므로 환경마다 조금씩 다르다.
- 핵심은 **차이**다.
  - 1번(머티리얼 1개 공유)과 2번(같은 셰이더 variant를 쓰는 머티리얼 10개)은 URP의 기본 기능인 `SRP Batcher`(Day 14)가 켜져 있으면 셰이더 패스를 바꾸지 않고 상수 버퍼만 바꿔 그리므로 **`SetPass calls`가 거의 늘어나지 않는다.**
  - 반면 3번처럼 셰이더 자체가 다르거나 키워드 조합(variant)이 다르면 그때마다 렌더 상태를 새로 바인딩해야 하므로 **`SetPass calls`가 큰 폭으로 증가**한다.

</details>

### 실습 2: Frame Debugger로 URP 한 프레임 해부하기 (10분)

Play 모드(또는 정지 상태)에서 `Window > Analysis > Frame Debugger`를 열고 `Enable`을 누른다.
왼쪽 트리에서 위에서 아래로 한 단계씩 클릭하며 오른쪽 뷰와 상세 패널(Shader, Pass, 메시에 바인딩된 버퍼)을 확인하고 아래 표를 채운다.

| Frame Debugger 구간 | 그리는 대상 | 정렬 순서(앞→뒤 / 뒤→앞 / 해당 없음) | 확인한 Shader 이름과 Pass 이름 |
|---|---|---|---|
| `DrawOpaqueObjects` | | | |
| `DrawSkybox` | | | |
| `DrawTransparentObjects` | | | |
| `PostProcessing` (켜져 있을 때) | | | |

---

## 3. 면접 대비 (10분)

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. 드로우 콜(Draw Call)이 무엇이고, 왜 많아지면 성능이 떨어지나요?**
<details><summary>모범 답안</summary>
드로우 콜은 CPU가 GPU에 메시 하나를 현재 설정된 렌더 상태로 그리라고 내리는 명령입니다. 그리기 명령 자체보다 그 직전에 셰이더, 텍스처, 상수 버퍼 같은 렌더 상태를 바인딩하고 그래픽 드라이버가 이를 검증하는 과정이 비쌉니다. 즉 드로우 콜 과다의 핵심 병목은 GPU가 아니라 CPU의 메인·렌더 스레드와 드라이버 오버헤드입니다.

</details>

**Q2. Unity Stats 창의 Batches와 SetPass calls는 어떻게 다른가요?**
<details><summary>모범 답안</summary>
SetPass calls는 셰이더 패스, 즉 GPU의 렌더 상태가 바뀐 횟수이고, Batches는 실제로 제출된 드로우 묶음의 수입니다. 같은 셰이더 variant를 쓰는 오브젝트를 연속으로 그리면 Batches는 여러 개라도 SetPass call은 한 번으로 묶일 수 있습니다. 드라이버 상태 검증 비용은 SetPass call에서 크게 발생하므로, 최적화할 때는 단순 드로우 수뿐 아니라 SetPass calls를 줄이는 것이 중요합니다.

</details>

**Q3. 게임이 느려졌을 때 CPU 바운드인지 GPU 바운드인지 어떻게 판단하나요?**
<details><summary>모범 답안</summary>
먼저 프로파일러에서 메인 스레드가 `Gfx.WaitForPresentOnGfxThread`에서 오래 대기하거나 렌더 스레드가 GPU 완료를 기다리는지 봅니다. 그렇다면 CPU는 일을 마치고 GPU를 기다리는 GPU 바운드입니다. 또한 해상도를 절반으로 줄였을 때 프레임이 빨라지면 필레이트 중심의 GPU 바운드이고, 해상도를 줄여도 그대로라면 스크립트·물리·드로우 제출 쪽의 CPU 바운드로 판단합니다.

</details>

**Q4. 프로파일러에서 `WaitForTargetFPS`가 프레임 시간의 절반을 차지합니다. 어디를 최적화해야 하나요?**
<details><summary>모범 답안</summary>
최적화할 병목이 아닙니다. `WaitForTargetFPS`는 VSync나 `Application.targetFrameRate`로 지정한 목표 프레임 시간보다 작업이 일찍 끝나서 남은 시간을 대기하는 마커입니다. 오히려 현재 프레임에 여유 시간이 충분하다는 뜻이며, 실제 CPU 비용을 보려면 이 마커를 제외한 작업 시간을 확인해야 합니다.

</details>

**Q5. URP가 한 프레임에서 불투명 오브젝트와 반투명 오브젝트를 그리는 순서와 이유가 무엇인가요?**
<details><summary>모범 답안</summary>
불투명 오브젝트를 카메라에서 가까운 순서(앞→뒤)로 먼저 그린 뒤 스카이박스를 그리고, 마지막에 반투명 오브젝트를 먼 순서(뒤→앞)로 그립니다. 불투명을 앞→뒤로 그리면 깊이 버퍼가 먼저 채워져 뒤에 가려진 픽셀의 프래그먼트 셰이더 실행을 건너뛸 수 있습니다. 반면 반투명은 깊이 버퍼에 값을 쓰지 않고 기존 색 위에 알파 블렌딩해야 하므로 뒤에서 앞으로 정렬해 그립니다.

</details>

---

## 오늘의 한 줄
> (내 말로 한 문장)

## 더 보기
- [드로우 콜 배칭 소개 (Unity 공식 문서)](https://docs.unity3d.com/Manual/DrawCallBatching.html)
- [프레임 디버거 (Unity 공식 문서)](https://docs.unity3d.com/Manual/FrameDebugger.html)
- [URP 렌더링 경로 비교 (Unity 공식 문서)](https://docs.unity3d.com/Manual/urp/rendering-paths-comparison.html)
