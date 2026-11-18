# Day 16 · 셰이더 variant와 첫 사용 스톨 🎮

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-UCS-017-DO |
| 유형 | D&O (개념) + 확인 실습 |
| 목적 | 셰이더 키워드의 variant 폭증, 첫 사용 스톨, 웜업 방법의 차이를 설명하고 확인한다 |
| 적용 대상 | Unity 6 (URP), `practice/UnityLab`. 🎮 표시 날 |
| 소요 시간 | 3주차 렌더링과 측정 · 60분 (읽기 20, 실습 30, 문제 10) |
| 확인 상태 | 미검증 (코드를 읽고 작성했으며 이 환경에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 학습 목표

- 셰이더 키워드(`keyword`)가 왜 `2^n`개의 `셰이더 변형(shader variant)` 폭증을 부르는지, `multi_compile`과 `shader_feature`의 차이를 설명할 수 있다.
- 런타임에 새 이펙트가 처음 나올 때 왜 프레임이 튀는지 그래픽스 API별(`D3D11` vs `D3D12`/`Vulkan`/`Metal`의 `PSO`)로 설명할 수 있다.
- `ShaderVariantCollection`, Unity 6 `GraphicsStateCollection`, 오프스크린 사전 렌더링의 차이와 드라이버 캐시 함정을 설명할 수 있다.

## 2. 구성 요소

| 이름 | 위치 | 역할 |
|---|---|---|
| `#pragma multi_compile` | 셰이더 소스 | 선언한 키워드의 모든 조합을 빌드에 포함한다 |
| `#pragma shader_feature` | 셰이더 소스 | 빌드에 포함된 머티리얼이 쓰는 조합만 포함한다 |
| `_local` 접미사 | 셰이더 소스 | 키워드를 해당 셰이더 로컬로 제한한다 |
| 스트리핑(stripping) | URP Asset, Graphics Settings, `IPreprocessShaders` | 빌드에서 안 쓰는 variant를 뺀다 |
| `ShaderVariantCollection` | 에셋 | 셰이더와 키워드 조합 목록을 모아 `WarmUp()`으로 준비한다 |
| `GraphicsStateCollection` | 에셋 (Unity 6) | 실제 PSO 상태를 기록해 로딩 화면에서 `WarmUp()`한다 |
| 더미 렌더링 | 로딩 화면 | 프리팹·VFX를 1~2프레임 실제로 그려 드라이버 준비를 끝낸다 |

## 3. 동작 원리

### 3-1. 키워드와 variant 폭증 (`2^n`)

Unity의 우버 셰이더(`URP/Lit` 등)는 하나의 셰이더 파일 안에 노말맵, 그림자, 안개, 라이트맵 같은 조건 분기를 `#pragma` 키워드로 넣어 두고, 빌드할 때 각 조합을 **별도의 셰이더 프로그램(`shader variant`)**으로 미리 컴파일한다.

독립된 on/off 키워드가 `n`개면 조합의 수는 최대 **`2^n`개**가 된다. 키워드 10개면 1,024개, 거기에 패스(Forward, ShadowCaster, DepthOnly 등) 수까지 곱해지면 한 셰이더에서 수만 개가 나와 빌드 시간과 메모리, 런타임 스톨을 키운다.

| 지시문 | 빌드에 포함되는 기준 | 용도 |
|---|---|---|
| `#pragma multi_compile A B` | **모든 조합**을 무조건 빌드에 포함 | 런타임에 전역 설정(그림자, 안개, 라이트맵 등)으로 바뀔 수 있는 키워드 |
| `#pragma shader_feature A B` | 빌드에 포함된 머티리얼이 **실제로 쓰는 조합만** 포함 | 머티리얼 인스펙터에서 켜고 끄는 정적 옵션(노말맵 사용 여부 등). 단, 런타임에 스크립트로 처음 켜는 키워드는 빌드에서 빠져 있을 수 있음 |
| `..._local` 접미사 (`shader_feature_local` 등) | 키워드를 전역이 아닌 **해당 셰이더 로컬**로 제한 | 전역 키워드 개수 제한을 아끼고 다른 셰이더와의 이름 충돌을 방지 |

### 3-2. 빌드 타임 스트리핑 (Stripping)

안 쓰는 variant를 빌드에서 빼는 과정을 **`스트리핑(stripping)`**이라고 한다.
- **URP Asset / Graphics Settings**: 안 쓰는 렌더링 기능(예: 안개 모드, 추가 라이트 그림자, Light Probe 옵션, Debug Display)을 끄면 관련 키워드 조합이 통째로 제거된다.
- **`IPreprocessShaders`**: 에디터 빌드 파이프라인 콜백(`OnProcessShader`)을 구현해 프로젝트에서 절대 쓰지 않는 패스나 키워드 조합을 코드로 직접 걸러낸다.

### 3-3. 런타임 첫 사용 스톨(First-use Hitch)과 PSO

빌드에 컴파일된 셰이더 바이트코드가 들어 있어도, GPU가 바로 실행할 수는 없다. **그래픽 드라이버가 현재 GPU 아키텍처에 맞는 기계어로 최종 변환하고 파이프라인 객체를 생성**해야 한다. 이 작업이 게임 도중 새 머티리얼이나 VFX가 처음 화면에 등장하는 프레임에 일어나면 수십~수백 ms짜리 프레임 스파이크(첫 사용 스톨)가 발생한다.

| 그래픽스 API | 첫 사용 시 드라이버가 만드는 것 | 특징 |
|---|---|---|
| **D3D11 / OpenGL** | 개별 셰이더 객체(`Shader Object`) | 정점·픽셀 셰이더 코드만 있으면 비교적 단순하게 생성 |
| **D3D12 / Vulkan / Metal** | **`PSO(Pipeline State Object)`** | 셰이더 바이트코드뿐만 아니라 **렌더 상태(블렌드, 깊이·스텐실, 컬링 모드) + 정점 레이아웃(`Vertex Layout`) + 렌더 타깃 포맷(`Render Target Format`)**까지 하나로 묶어 컴파일 |

### 3-4. 웜업(Warm-up) 방법 3가지와 드라이버 캐시 함정

전투 중에 렉이 걸리지 않게 하려면 **로딩 화면에서 미리 생성(웜업, `warm-up`)**해 두어야 한다.

1. **`ShaderVariantCollection.WarmUp()`**:
   - 필요한 셰이더와 키워드 조합 목록을 에셋으로 모아 로드 시점에 준비시킨다.
   - `D3D11` 같은 구형 API에서는 효과적이지만, **`D3D12`/`Vulkan`/`Metal`에서는 불완전**하다. `PSO`를 만들려면 셰이더 외에 실제로 어떤 메시(정점 레이아웃)와 어떤 렌더 타깃 포맷에 그려질지 알아야 하는데, `ShaderVariantCollection`에는 그 렌더 상태 정보가 없기 때문이다.
2. **Unity 6 `GraphicsStateCollection`** (Unity 6 이상, 버전 확인 필요):
   - 개발 빌드에서 게임을 플레이하며 실제로 생성된 `PSO` 상태(셰이더 variant + 렌더 상태 + 정점 포맷 + 렌더 타깃 포맷)를 기록한 뒤, 로딩 화면에서 `WarmUp()`으로 `PSO`까지 미리 생성한다.
3. **로딩 화면에서 실제로 한두 프레임 그리기 (오프스크린/더미 렌더링)**:
   - 프리팹이나 VFX를 로딩 중에 카메라 앞(가림막 뒤나 작은 렌더 텍스처)에 띄워 1~2프레임 실제로 렌더링한다. API 종류와 무관하게 실제 드로우 경로를 그대로 타므로 드라이버 준비와 내부 버퍼 초기화를 가장 확실하게 끝낸다.

**측정할 때의 함정 — 그래픽 드라이버 셰이더 캐시**:
한 번 컴파일된 셰이더/PSO는 OS나 그래픽 드라이버가 디스크 캐시에 저장한다. 그래서 **같은 PC에서 두 번째 실행할 때는 스톨이 사라진다.** 개발자 PC에서는 매끄러운데 유저가 게임을 처음 깔고 첫 전투에 들어가면 멈추는 이유다. 정확한 전후 비교를 하려면 드라이버 셰이더 캐시를 지우거나 클린 조건에서 측정해야 한다.

### 3-5. 팀 프로젝트 사례: 전투 초반 프레임 스파이크

실제 팀 프로젝트(Unity 6000.3, URP, D3D12)에서 겪은 수치다.
- **원인**: 전투 초반의 큰 프레임 스파이크는 `Instantiate` 때문이 아니라 대부분 **VFX Graph의 첫 사용 초기화(셰이더 variant 컴파일 및 PSO 생성)** 때문이었다.
- **D3D12에서의 해결**: 개발 빌드에서 `-tracePSO` 인자로 `GraphicsStateCollection`에 PSO들을 기록하고 로딩 화면에서 웜업했다. 그 결과 **전투 중 100 ms 초과 프레임이 4회 → 0회**로 줄었다(대가: 부팅/로딩 시간 약 **+1.1초** 증가).
- **D3D11 전환 이후**: 이후 프로젝트 그래픽스 API를 D3D11로 전환하자 트레이스에 기록되는 PSO가 0개였고 프레임당 셰이더 비용도 1 ms 미만으로 유지되었다. 이에 따라 PSO 웜업을 제거하고, 대신 **로딩 화면에서 전투 VFX를 2프레임 동안 미리 그리는 방식**으로 대체했다. 이 사례는 Day 22에서 트러블슈팅 노트로 직접 작성한다.


## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 키워드(keyword) | 셰이더 안 조건 분기를 켜고 끄는 이름. `#pragma`로 선언한다 |
| variant | 키워드 조합 하나에 대응해 컴파일된 셰이더 프로그램 |
| PSO(Pipeline State Object) | 셰이더와 렌더 상태·정점 레이아웃·렌더 타깃 포맷을 묶은 파이프라인 객체 (D3D12, Vulkan, Metal) |
| 스트리핑(stripping) | 안 쓰는 variant를 빌드에서 제외하는 과정 |
| 웜업(warm-up) | 첫 사용 전에 variant·PSO를 미리 만들어 두는 작업 |
| 첫 사용 스톨(first-use hitch) | 새 셰이더·이펙트가 처음 나오는 프레임에 생기는 프레임 스파이크 |

## 5. 확인 실습

{% hint style="info" %}
NOTE: AI, 자동완성, 검색 없이 진행한다. 막히면 3절로 돌아간다.
{% endhint %}

### 실습 1: 키워드 추가에 따른 variant 수 계산과 인스펙터 확인 (15분)

`practice/UnityLab`에서 간단한 커스텀 셰이더(`VariantTest.shader`)를 만들고 키워드 지시문을 바꿔가며 Unity가 계산하는 variant 수를 확인한다.

```hlsl
Shader "Custom/VariantTest"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // ① 처음엔 multi_compile로 확인한 뒤, shader_feature_local로 바꿔 비교한다.
            #pragma multi_compile _ USE_RED_TINT
            #pragma multi_compile _ USE_HALF_BRIGHT
            #pragma multi_compile _ INVERT_COLOR

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes { float4 positionOS : POSITION; };
            struct Varyings  { float4 positionHCS : SV_POSITION; };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }

            half4 frag() : SV_Target
            {
                half4 col = half4(0.2, 0.6, 1.0, 1.0);
                #if defined(USE_RED_TINT)
                col.r = 1.0;
                #endif
                #if defined(USE_HALF_BRIGHT)
                col.rgb *= 0.5;
                #endif
                #if defined(INVERT_COLOR)
                col.rgb = 1.0 - col.rgb;
                #endif
                return col;
            }
            ENDHLSL
        }
    }
}
```

아래 표의 예측 칸을 먼저 채운 뒤, 셰이더 에셋을 클릭해 인스펙터에서 variant 수를 확인한다(표시 위치와 이름은 Unity 버전에 따라 조금 다르다. `Compile and show code` 주변을 찾아본다).

| 설정 | 예측 variant 수 (`2^n`) | 인스펙터에 표시된 Total variants | 차이나는 이유 |
|---|---|---|---|
| 1) `#pragma multi_compile` 2개 (on/off 2개) | | | |
| 2) `#pragma multi_compile` 3개 (on/off 3개) | | | |
| 3) 3개 모두 `#pragma shader_feature_local`로 변경 (참조 머티리얼 0개일 때 `Included currently`) | | | |

### 실습 2: 첫 등장 시점의 셰이더 생성 마커와 사전 렌더링 웜업 비교 (15분)

런타임 도중 스페이스바를 누르면 새로운 키워드 조합을 켠 머티리얼의 큐브를 화면에 처음 등장시키는 스크립트를 작성한다.

```csharp
// Unity: ShaderWarmupTest.cs
using System.Collections;
using UnityEngine;

public class ShaderWarmupTest : MonoBehaviour
{
    [SerializeField] private Shader testShader;
    [SerializeField] private bool preRenderOnStart = false;

    private Material runtimeMat;
    private GameObject hiddenWarmupCube;
    private Camera cam;

    private IEnumerator Start()
    {
        cam = Camera.main;   // Update에서 반복 조회하지 않도록 한 번만 캐싱한다
        runtimeMat = new Material(testShader);
        runtimeMat.EnableKeyword("USE_RED_TINT");
        runtimeMat.EnableKeyword("USE_HALF_BRIGHT");
        runtimeMat.EnableKeyword("INVERT_COLOR");

        if (preRenderOnStart)
        {
            // 카메라 시야 안에서 2프레임 미리 그려 드라이버/PSO 초기화를 끝낸다
            hiddenWarmupCube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            hiddenWarmupCube.transform.position = cam.transform.position + cam.transform.forward * 2f;
            hiddenWarmupCube.GetComponent<MeshRenderer>().sharedMaterial = runtimeMat;
            yield return null;
            yield return null;
            Destroy(hiddenWarmupCube);
        }
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            GameObject go = GameObject.CreatePrimitive(PrimitiveType.Cube);
            go.transform.position = cam.transform.position + cam.transform.forward * 3f;
            go.GetComponent<MeshRenderer>().sharedMaterial = runtimeMat;
        }
    }
}
```

Profiler(`Window > Analysis > Profiler`)의 CPU Usage 모듈을 켜고, 스페이스바를 누른 프레임에서 `Shader.CreateGPUProgram` 또는 그래픽스 파이프라인 생성 관련 마커가 잡히는지 확인한다(팁: 드라이버 캐시 영향을 피하려면 에디터 재시작 또는 셰이더의 상수를 살짝 수정해 재컴파일한 직후 첫 실행을 비교한다).

{% hint style="info" %}
NOTE: 에디터는 기본으로 셰이더를 비동기로 컴파일한다(처음엔 하늘색 임시 셰이더로 그린다). 그래서 에디터에서는 스톨이 작게 보일 수 있다. `Project Settings > Editor > Asynchronous Shader Compilation`을 끄고 비교하거나, 개발 빌드에 프로파일러를 붙여 잰다.
{% endhint %}

{% hint style="info" %}
NOTE: 코드의 `Input.GetKeyDown`은 `Project Settings > Player > Active Input Handling`이 `Both`(또는 `Input Manager (Old)`)일 때만 동작한다. 새 Input System 전용이면 버전 확인 필요.
{% endhint %}

| 조건 | 스페이스바를 누른 프레임의 CPU 시간 (ms) | 관찰된 셰이더/렌더링 관련 마커 |
|---|---|---|
| 1) `preRenderOnStart = false` (셰이더 수정 직후 첫 등장) | | |
| 2) `preRenderOnStart = true` (시작 시 2프레임 사전 렌더링 후 스페이스바) | | |


## 6. 확인 문제

소리 내어 30초 안에 답해 보고 펼쳐서 비교한다.

**Q1. `#pragma multi_compile`과 `#pragma shader_feature`의 차이와 언제 어느 것을 써야 하는지 설명해 주세요.**
<details><summary>모범 답안</summary>
`multi_compile`은 선언된 키워드의 모든 조합을 빌드 결과물에 무조건 포함하고, `shader_feature`는 빌드에 포함된 머티리얼들이 실제로 활성화해 둔 키워드 조합만 빌드에 포함합니다. 따라서 그림자나 안개처럼 런타임 전역 상태에 따라 동적으로 바뀌는 키워드에는 `multi_compile`을 쓰고, 머티리얼 에셋마다 고정해서 쓰는 노말맵·에미션 여부 같은 옵션에는 `shader_feature`(가급적 `_local`)를 써서 불필요한 variant 폭증을 막아야 합니다.

</details>

**Q2. 전투 중 이펙트가 처음 나올 때 프레임이 한 번 크게 튀고, 두 번째 나올 때부터는 안 튑니다. 원인과 해결 방법은 무엇인가요?**
<details><summary>모범 답안</summary>
오브젝트 생성 자체보다 그 이펙트가 사용하는 셰이더 variant나 PSO(Pipeline State Object)가 그 프레임에 처음 GPU에 제출되면서 그래픽 드라이버가 런타임 컴파일 및 상태 객체 생성을 수행하기 때문입니다. 한 번 생성된 뒤에는 메모리와 드라이버 캐시에 올라가므로 두 번째부터는 빠릅니다. 이를 막으려면 로딩 화면에서 `GraphicsStateCollection`이나 `ShaderVariantCollection`으로 웜업하거나, 해당 이펙트를 로딩 중에 1~2프레임 미리 렌더링해 초기화를 끝내 두어야 합니다.

</details>

**Q3. 왜 D3D12나 Vulkan, Metal에서는 기존 `ShaderVariantCollection.WarmUp()`만으로 첫 사용 스톨을 완전히 막기 어렵나요?**
<details><summary>모범 답안</summary>
D3D11에서는 셰이더 바이트코드만으로 드라이버 셰이더 객체를 준비할 수 있었지만, D3D12·Vulkan·Metal 같은 현대 저수준 API는 셰이더 코드에 더해 블렌드·깊이 상태, 정점 레이아웃, 렌더 타깃 포맷까지 하나로 묶은 PSO(Pipeline State Object)를 생성해야 합니다. `ShaderVariantCollection`에는 어떤 메시와 어떤 렌더 타깃에 그려질지 정보가 없어 실제 드로우 시점의 PSO를 온전히 만들지 못합니다. 따라서 Unity 6의 `GraphicsStateCollection`으로 실제 PSO를 기록해 웜업하거나 로딩 중 더미 드로우를 수행해야 합니다.

</details>

**Q4. 셰이더 스톨을 최적화할 때 "내 PC에서는 두 번째 실행부터 안 끊기는데 해결된 것 아닌가?"라고 판단하면 왜 위험한가요?**
<details><summary>모범 답안</summary>
그래픽 드라이버와 OS가 한 번 컴파일한 셰이더나 PSO를 로컬 디스크의 셰이더 캐시에 저장해 두기 때문입니다. 개발자 PC에서는 이미 캐시가 워밍업되어 스톨이 안 보이지만, 게임을 처음 설치한 유저나 그래픽 드라이버를 업데이트한 유저는 첫 전투에서 그대로 스톨을 겪습니다. 따라서 성능을 검증할 때는 캐시 영향을 배제한 첫 실행 조건에서 확인해야 합니다.

</details>

## 참조

- [셰이더 변형과 키워드 (Unity 공식 문서)](https://docs.unity3d.com/Manual/shader-variants.html)
- [셰이더 로딩과 웜업 (Unity 공식 문서)](https://docs.unity3d.com/Manual/shader-loading.html)
- [GraphicsStateCollection API 문서 (Unity 6)](https://docs.unity3d.com/ScriptReference/Rendering.GraphicsStateCollection.html)
- [IPreprocessShaders API 문서](https://docs.unity3d.com/ScriptReference/Build.IPreprocessShaders.html)

이전: [Day 15 오버드로우, 투명, 컬링](day15-overdraw-culling.md) · 다음: [Day 17 프로파일러 읽는 법](day17-profiler.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 오늘의 한 줄: 이 날의 핵심을 내 말로 한 문장으로 쓴다.
- [ ] multi_compile과 shader_feature 중 내 프로젝트의 키워드에 맞는 것은 무엇이고 그 이유는?
- [ ] 내가 겪었거나 겪을 수 있는 "처음 나올 때만 끊기는" 이펙트는 무엇이고, 어떻게 확인하겠는가?
