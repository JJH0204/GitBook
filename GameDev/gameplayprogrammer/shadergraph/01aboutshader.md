# 셰이더 기초 개념과 종류 (Shader)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-SGR-001-DO |
| 유형 | D&O (개념) |
| 목적 | 셰이더가 무엇이고 어떤 종류·언어·API·Unity 포맷이 있는지 설명한다 |
| 확인 상태 | 미검증 (원본 노트를 정리한 것이며 이 환경에서 Unity를 실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

## 1. 목적

셰이더(shader)는 GPU에서 실행되는 그래픽 처리 전용 코드다. 3D 모델 표면에 적용할 시각 효과를 결정하며 게임·시뮬레이션의 실시간 렌더링에 쓰인다.

* 조명 각도에 따른 물의 반사, 인공 조명에 의한 그림자처럼 물리 현상에 기반한 그래픽을 처리한다.
* 외부 개발자가 만든 셰이더 팩을 리소스에 추가해 기존보다 향상된 그래픽을 쓸 수 있다.

## 2. 구성 요소

### 셰이더의 종류

| 종류 | 역할 | 예·비고 |
|---|---|---|
| Vertex Shader | 정점(vertex)의 위치, 색상, 조명을 계산한다 | 모델의 형태와 애니메이션 처리 |
| Fragment Shader (Pixel Shader) | 각 픽셀의 색상을 계산한다 | 텍스처, 라이트, 그림자, 반사 |
| Geometry Shader | 정점 사이에 새 기하 구조를 만든다 | 실시간 실루엣, 아웃라인. Metal(Apple)은 지원하지 않고 느린 편이라 모바일에서는 피한다 |
| Compute Shader | 그래픽 파이프라인 밖에서 병렬 연산을 한다 | 물리 계산, 파티클 시뮬레이션, AI 처리 |
| Tessellation Shader | 정점을 더 촘촘히 세분화한다 | 고해상도 곡면(캐릭터 얼굴 등). 헐 셰이더(분할 정도 결정)와 도메인 셰이더(새 정점 위치 계산) 두 단계 |

### 셰이더 언어와 파일 형식

| 이름 | 설명 |
|---|---|
| HLSL (High-Level Shading Language) | DirectX의 셰이더 언어. Unity도 HLSL로 쓰고 플랫폼에 맞게 GLSL·Metal 등으로 자동 변환한다 |
| GLSL (OpenGL Shading Language) | OpenGL·WebGL의 셰이더 언어 |
| Cg (C for Graphics) | Nvidia가 만든 언어. 개발이 중단됐다. Unity의 `CGPROGRAM`은 그 흔적이고 지금은 `HLSLPROGRAM`을 쓴다 |
| ShaderLab | 언어가 아니라 Unity의 셰이더 파일 형식. 프로퍼티, 패스, 렌더 상태를 정의하고 그 안에 HLSL 코드를 넣는다 |

### 그래픽 API

| API | 주로 쓰는 곳 |
|---|---|
| Direct3D 11/12 (DirectX) | Windows, Xbox |
| Vulkan | Windows, Linux, Android (크로스 플랫폼) |
| Metal | macOS, iOS |
| OpenGL, OpenGL ES, WebGL | 크로스 플랫폼, 구형 모바일, 웹 |

{% hint style="info" %}
NOTE: Nvidia는 GPU 제조사이며 그래픽 API가 아니다.
{% endhint %}

### Unity 셰이더 포맷

| 포맷 | 설명 | Built-in | URP | HDRP |
|---|---|---|---|---|
| Custom Shader | ShaderLab 안에 HLSL을 직접 작성한다 | 가능 | 가능 | 가능 (확인 필요) |
| Surface Shader | Built-in 전용 래퍼 | 가능 | 불가 | 불가 |
| Shader Graph | 노드 기반 비주얼 툴 | 버전별 상이 (버전 확인 필요) | 가능 | 가능 |

{% hint style="info" %}
NOTE: Custom Shader를 URP·HDRP에서 쓰려면 해당 파이프라인의 패스(`LightMode` 태그)와 라이브러리 include 형식에 맞춰야 한다. Built-in용 셰이더를 그대로 복사하면 분홍색(오류)으로 보일 수 있다. Shader Graph의 Built-in 지원 여부와 시작 버전은 사용 중인 Unity 문서로 확인해야 한다(버전 확인 필요).
{% endhint %}

## 3. 동작 원리

GPU는 모델 하나를 다음 순서로 그린다.

1. 버텍스 셰이더가 정점마다 한 번 실행된다. 정점의 화면 위치를 계산한다.
2. 정점이 삼각형으로 묶이고 화면의 픽셀로 변환된다.
3. 프래그먼트 셰이더가 픽셀(조각)마다 한 번 실행된다. 최종 색을 계산한다.

실행 횟수는 버텍스 셰이더가 정점 수, 프래그먼트 셰이더가 화면에 덮이는 픽셀 수에 비례한다. 선택적 단계(테셀레이션, 지오메트리)는 1~2단계 사이에 들어간다.

## 4. 약어·용어

| 용어 | 뜻 |
|---|---|
| 정점 (vertex) | 메시를 이루는 점. 위치, 법선, UV, 색을 가진다 |
| 프래그먼트 (fragment) | 화면 픽셀 하나가 될 후보. 깊이 테스트 등을 통과하면 픽셀이 된다 |
| 패스 (pass) | 오브젝트를 한 번 그리는 단위. 셰이더 하나가 여러 패스를 가질 수 있다 |
| URP / HDRP | Universal / High Definition Render Pipeline. Unity의 렌더 파이프라인 |

## 5. 참조

* <https://learn.unity.com/search/?k=%5B%22q%3Ashader%22%5D>
* <https://thebookofshaders.com/>
* <https://catlikecoding.com/unity/tutorials/rendering/>
* <https://youtu.be/KnueAgpUL3Y> (고라니TV 강의, [GMD-SGR-004-REF](goranitvshadertimeline.md))
* [툰 셰이더 공부 노트 Day 01 · 셰이더가 뭐예요?](../../toon-shader-study/day01-what-is-a-shader.md)
* [툰 셰이더 공부 노트 Day 03 · 셰이더 파일의 뼈대](../../toon-shader-study/day03-shaderlab-skeleton.md)
* [툰 셰이더 실습실 Day 01 · 첫 셰이더 짜기](../../toon-shader-lab/day01-first-shader.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 버텍스 셰이더와 프래그먼트 셰이더가 각각 몇 번 실행되는지(정점 수? 픽셀 수?), 그 차이가 성능에 어떤 뜻인지 쓴다.
- [ ] URP 프로젝트에서 셰이더를 만드는 두 가지 방법(HLSL 직접 작성, Shader Graph)의 장단점을 쓴다.
