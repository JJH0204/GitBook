# Day 01. 실험실 열고 첫 셰이더 짜기

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSL-001-MP |
| 목적 | 실습 프로젝트를 열고 물체를 단색으로 칠하는 가장 작은 URP 셰이더를 작성한다 |
| 적용 대상 | Unity 6000.3 (Unity 6.3 LTS, 원본 기준 6000.3.27f2), Universal Render Pipeline(URP), Git 설치됨 |
| 소요 시간 | 약 60분 (프로젝트 열기 15분, 코드 입력 25분, 실험 20분) |
| 확인 상태 | 미검증 (원본 코드를 읽고 정리한 것이며 이 환경에서 Unity로 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 셰이더(shader)는 GPU가 정점마다, 픽셀마다 실행하는 작은 프로그램이다. 이 과정은 22일 동안 이 파일 하나를 키워 툰 셰이더를 완성한다. 코드는 복사하지 않고 직접 입력한다.
{% endhint %}

{% hint style="info" %}
NOTE: `TransformObjectToHClip`, `Core.hlsl` 경로, 패스 태그는 URP 버전에 따라 다를 수 있다. URP 버전 확인 필요. 이 문서는 Unity 6000.3에 포함된 URP 17.x를 기준으로 한다.
{% endhint %}

## 1. 참조

| 참조 문서 | Task ID | 제목 |
|---|---|---|
| [README.md](README.md) | - | 툰 셰이더 실습실 (과정 개요) |
| [day02-vertex-shader.md](day02-vertex-shader.md) | GMD-TSL-002-MP | 다음 단계: 버텍스 셰이더 |
| [essence.md](essence.md#day-01) | GMD-TSL-023-REF | 액기스 모음 (Day 01 항목) |
| [toon-shader-study Day 01](../toon-shader-study/day01-what-is-a-shader.md) | - | 셰이더 개념 (짝꿍 과정) |
| [toon-shader-study Day 03](../toon-shader-study/day03-shaderlab-skeleton.md) | - | 셰이더 파일의 뼈대 (짝꿍 과정) |
| [URP에서 셰이더 쓰기 (Unity 공식)](https://docs.unity3d.com/Packages/com.unity.render-pipelines.universal@17.0/manual/writing-custom-shaders-urp.html) | - | 공식 문서 |

## 2. 필요 장비와 자재

| 번호 | 이름 | 사양·버전 | 비고 |
|---|---|---|---|
| 1 | Unity Hub와 Unity Editor | 6000.3.x (Unity 6.3 LTS) | 원본은 6000.3.27f2로 작성했다 |
| 2 | Git | 2.x | 클론과 커밋에 사용한다 |
| 3 | 코드 편집기 | Visual Studio, VS Code, Rider 중 하나 | `.shader` 파일을 연다 |
| 4 | 실습 저장소 | `toon-shader-lab` (비공개 저장소) | 접근 권한이 있어야 클론할 수 있다 |

## 3. 안전 사항

{% hint style="warning" %}
CAUTION: 실습용 씬을 망가뜨렸을 때는 메뉴 `Lab > Rebuild Lab Scene`으로 초기 상태로 되돌린다. 작업 전에 씬을 저장하지 않고 닫으면 변경 내용이 사라진다.
{% endhint %}

## 4. 준비

| 번호 | 항목 | 확인 방법 |
|---|---|---|
| 1 | Unity 6000.3.x가 설치돼 있다 | Unity Hub의 `Installs`에 6000.3.x가 보인다 |
| 2 | Git이 설치돼 있다 | `git --version`이 버전 번호를 출력한다 |
| 3 | 저장소 접근 권한이 있다 | 5-A-01의 클론이 오류 없이 끝난다 |

## 5. 절차

### A. 프로젝트 열기

1. (5-A-01) 저장소를 클론한다: `git clone https://github.com/JJH0204/toon-shader-lab.git` → 결과: `toon-shader-lab` 폴더가 생긴다.
2. (5-A-02) 폴더로 이동한다: `cd toon-shader-lab`
3. (5-A-03) 작업용 브랜치를 만든다: `git switch -c my-toon` → 결과: 정답 브랜치(`main`)와 섞이지 않는다.
4. (5-A-04) Unity Hub에서 `Add` > `Add project from disk`를 눌러 클론한 폴더를 고른다.
5. (5-A-05) 프로젝트를 연다. → 결과: 첫 실행은 라이브러리 생성에 수 분이 걸린다.
6. (5-A-06) Project 창에서 `Assets/Scenes/Lab`을 더블클릭한다. → 결과: Lab 씬이 열린다.

Lab 씬의 구성 요소는 다음과 같다.

| 이름 | 역할 |
|---|---|
| Sphere, Capsule, Cube | 셰이더를 입힐 실험 대상 (둥근 것, 긴 것, 각진 것) |
| Ground | 바닥. Unity 기본 Lit 셰이더라 그림자를 받는다 |
| Directional Light | 해. 오른쪽 앞 위에서 비춘다 |
| Point Light | 빨간 전구. 꺼져 있다. Day 11에서 켠다 |
| Shadow Beam | 화면 밖 위쪽의 막대. 꺼져 있다. Day 08에서 켠다 |

### B. 셰이더 파일 만들기

1. (5-B-01) Project 창에서 `Assets`를 우클릭하고 `Create > Folder`를 눌러 `MyToon`이라는 이름을 입력한다. → 결과: `Assets/MyToon` 폴더가 생긴다. 이후 작성하는 코드는 모두 이 폴더에 둔다.
2. (5-B-02) `MyToon` 폴더를 우클릭하고 `Create > Shader > Unlit Shader`를 눌러 이름을 `MyToon`으로 한다.
3. (5-B-03) `MyToon.shader`를 더블클릭해 코드 편집기로 연다.
4. (5-B-04) 파일 내용을 전부 지운다. → 결과: 빈 파일이 된다. (기본 템플릿은 이 과정과 맞지 않는다.)

### C. 코드 입력

1. (5-C-01) 다음 코드를 입력하고 저장한다. → 결과: Unity로 돌아오면 자동으로 컴파일된다.

```shaderlab
Shader "MyToon/Toon"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass
        {
            Name "Forward"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings o = (Varyings)0;
                o.positionCS = TransformObjectToHClip(input.positionOS.xyz);   // 오브젝트 주소 → 클립 주소
                return o;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return half4(1.0h, 0.55h, 0.3h, 1.0h);   // 주황색 (R, G, B, A)
            }
            ENDHLSL
        }
    }
}
```

### D. 머티리얼 만들어 입히기

머티리얼(material)은 셰이더를 사용해 만든 설정 묶음이다. 셰이더가 레시피라면 머티리얼은 그 레시피로 만든 결과물이다.

1. (5-D-01) `MyToon` 폴더를 우클릭하고 `Create > Material`을 눌러 이름을 `MyToon`으로 한다.
2. (5-D-02) 머티리얼 Inspector 맨 위의 `Shader` 드롭다운에서 `MyToon > Toon`을 고른다.
3. (5-D-03) 머티리얼을 Scene 뷰의 Sphere, Capsule, Cube 위로 끌어다 놓는다. → 결과: 세 물체가 명암 없는 주황색으로 보인다.

![Day 01 결과: 주황색 단색 물체 셋](../.gitbook/assets/day01-first-shader.png)

{% hint style="info" %}
NOTE: 정답 셰이더는 `Assets/Solutions/Day01/MyToon.shader`에 있다. 셰이더 이름만 `Solutions/Day01`로 다르다. 막히면 열어서 비교한다.
{% endhint %}

### E. 코드 구조 확인

| 코드 | 의미 |
|---|---|
| `Shader "MyToon/Toon"` | 셰이더 이름. `/`는 머티리얼 드롭다운의 폴더가 된다 |
| `SubShader`와 `Tags { "RenderPipeline" = "UniversalPipeline" ... }` | URP에서 쓰는 셰이더임을 표시한다. `Queue = Geometry`는 불투명 물체 순서로 그린다는 뜻이다 |
| `Pass` | 화면에 한 번 그리는 단위. 이후 그림자용, 외곽선용 패스가 추가된다 |
| `Tags { "LightMode" = "UniversalForward" }` | URP가 색칠 단계에서 이 패스를 호출하게 하는 이름표 |
| `HLSLPROGRAM` ... `ENDHLSL` | GPU가 실행하는 HLSL 코드 구간 |
| `#pragma vertex vert` | 버텍스 셰이더 함수는 `vert`라고 지정한다 |
| `#pragma fragment frag` | 프래그먼트 셰이더 함수는 `frag`라고 지정한다 |
| `#include ".../Core.hlsl"` | URP 공용 함수를 불러온다. `TransformObjectToHClip`이 여기에 있다 |
| `struct Attributes` | 메시에서 버텍스 셰이더로 들어오는 입력. `: POSITION`은 정점 위치를 이 칸에 넣는다는 의미(시맨틱) |
| `struct Varyings` | 버텍스 셰이더에서 프래그먼트 셰이더로 넘기는 값. `SV_POSITION`(화면 위치)은 필수다 |
| `vert` | 정점마다 한 번 실행한다. 정점이 화면 어디에 찍힐지 계산한다 |
| `frag` | 픽셀마다 한 번 실행한다. 픽셀 색을 반환한다. `: SV_Target`은 최종 출력 색이라는 의미 |
| `half4(1.0h, 0.55h, 0.3h, 1.0h)` | R 1, G 0.55, B 0.3, 불투명도 1. `h`는 half 정밀도 리터럴 표시 |

| 변수 이름 끝 | 좌표 공간 |
|---|---|
| `OS` | 오브젝트(object space). 모델 자신이 기준 |
| `CS` | 클립(clip space). 화면 직전 상자. Day 02에서 상세히 다룬다 |

### F. 실험

1. (5-F-01) 색을 바꾼다: `half4(0.3h, 0.8h, 1.0h, 1.0h)`로 수정하고 저장한다. → 결과: 하늘색이 된다.
2. (5-F-02) 일부러 오류를 만든다: `return` 줄 끝의 `;`를 지우고 저장한다. → 결과: 물체가 분홍색(마젠타)으로 바뀐다. 셰이더 컴파일 실패를 뜻한다.
3. (5-F-03) 오류 위치를 읽는다: `Window > General > Console`과 셰이더 파일 Inspector를 연다. → 결과: 오류가 난 줄 번호가 보인다.
4. (5-F-04) `;`를 되돌린다. → 결과: 주황색으로 돌아온다.
5. (5-F-05) 작업을 커밋한다: `git add Assets/MyToon` 후 `git commit -m "Day 01: 단색 셰이더"`

{% hint style="info" %}
NOTE: 셰이더 이름을 `Study/Hello` 등으로 바꾸면 드롭다운 위치가 바뀐다. 확인 후 `MyToon/Toon`으로 되돌린다. 이후 Day의 설명은 `MyToon/Toon`을 기준으로 한다.
{% endhint %}

## 6. 기능 확인

| 번호 | 확인 동작 | 기대 결과 | 합격 기준 |
|---|---|---|---|
| 1 | Lab 씬에서 세 물체를 본다 | 명암 없는 주황색 | 세 물체 모두 단색 주황색 (분홍색 아님) |
| 2 | Console 창을 본다 | 셰이더 오류 없음 | 빨간 오류 0건 |
| 3 | 머티리얼 Inspector의 `Shader` 항목을 본다 | `MyToon/Toon` | 이름 일치 |

## 7. 복구

1. (7-01) 코드를 되돌린다: `git restore Assets/MyToon/MyToon.shader` (커밋 전 상태로 복원한다). 에디터에서는 `Ctrl+Z`로 되돌릴 수 있다.
2. (7-02) 씬을 초기화한다: 메뉴 `Lab > Rebuild Lab Scene`을 실행한다. → 결과: Lab 씬이 처음 상태가 된다.
3. (7-03) 정답과 비교한다: `Assets/Solutions/Day01/MyToon.shader`를 연다.

## 8. 개정 이력

| 개정 | 날짜 | 변경 내용 |
|---|---|---|
| R1 | 2026-11-18 | 기존 Day 01 페이지를 AMM 형식으로 재작성. 비유 문장 삭제, 코드 보존 |

[목차](README.md) · [다음: Day 02](day02-vertex-shader.md)
