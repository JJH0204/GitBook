# 셰이더 기초 개념과 종류 (Shader)

### 쉐이더란?

* GPU에서 실행되는 그래픽 처리 전용 코드
* 3D 모델의 표면에 적용할 시각적 효과를 결정
* 실시간 렌더링에 중요한 역할을 수행 (게임, 시뮬레이션 등)
* 외부 개발자가 만든 쉐이더 팩을 게임 리소스에 추가하여 기존 게임 그래픽보다 향상된 그래픽을 즐길 수 있음.
* 조명(해)의 각도에 따른 물의 반사, 인공 조명에 의한 그림자 등 실제 물리현상 기반의 사실적인 그래픽 처리 가능.

### 쉐이더의 종류

#### Vertex Shader

* 정점(Vertex)의 위치, 색상, 조명 등을 계산
* 주로 모델의 형태와 애니메이션 관련 처리

#### Fragment Shader (Pixel Shader)

* 각 픽셀의 색상을 계산
* 주로 텍스처, 라이트, 그림자, 반사 등 시각 효과 담당

#### Geometry Shader

* 정점 사이에 새로운 기하 구조 생성
* 예: 실시간 실루엣, 아웃라인 등
* Metal(Apple)에서는 지원하지 않고 느린 편이라 모바일에서는 피한다.

#### Compute Shader

* 그래픽 파이프라인 외에서 병렬 연산 수행
* 예: 물리 계산, 파티클 시뮬레이션, AI 처리 등

#### Tessellation Shader

* 정점을 더 촘촘하게 세분화
* 고해상도 곡면 표현에 사용 (캐릭터 얼굴 등)
* 헐 셰이더(분할 정도 결정)와 도메인 셰이더(새 정점 위치 계산) 두 단계로 이뤄진다.

### 쉐이더 언어

* HLSL (High-Level Shading Language): DirectX의 셰이더 언어. Unity도 HLSL로 쓰고, 플랫폼에 맞게 GLSL·Metal 등으로 자동 변환한다.
* GLSL (OpenGL Shading Language): OpenGL·WebGL의 셰이더 언어
* Cg (C for Graphics): Nvidia가 만든 언어로 지금은 개발이 중단됐다. Unity의 `CGPROGRAM`은 그 흔적이고, 지금은 `HLSLPROGRAM`을 쓴다.
* ShaderLab: 언어가 아니라 Unity의 셰이더 파일 형식. 프로퍼티, 패스, 렌더 상태를 정의하고 그 안에 HLSL 코드를 넣는다.

### 그래픽 API

| API | 주로 쓰는 곳 |
|---|---|
| Direct3D 11/12 (DirectX) | Windows, Xbox |
| Vulkan | Windows, Linux, Android (크로스 플랫폼) |
| Metal | macOS, iOS |
| OpenGL, OpenGL ES, WebGL | 크로스 플랫폼, 구형 모바일, 웹 |

* Nvidia는 GPU 제조사라 그래픽 API가 아니다.

### Unity 엔진 쉐이더 포맷

* Custom Shader: ShaderLab 안에 HLSL을 직접 작성한다. URP에서도 쓸 수 있다.
* Surface Shader: Built-in 렌더 파이프라인 전용 래퍼. URP·HDRP에서는 동작하지 않는다.
* Shader Graph: 노드 기반 비주얼 툴. URP·HDRP용이다.

### 리소스

* https://learn.unity.com/search/?k=%5B%22q%3Ashader%22%5D
* https://thebookofshaders.com/
* https://catlikecoding.com/unity/tutorials/rendering/
* https://youtu.be/KnueAgpUL3Y?si=V92O9PHGQTccBANf
* [툰 셰이더 공부 노트 Day 01 · 셰이더가 뭐예요?](../../toon-shader-study/day01-what-is-a-shader.md)
* [툰 셰이더 공부 노트 Day 03 · 셰이더 파일의 뼈대](../../toon-shader-study/day03-shaderlab-skeleton.md)
* [툰 셰이더 실습실 Day 01 · 첫 셰이더 짜기](../../toon-shader-lab/day01-first-shader.md)

## 내 말로 채우기

{% hint style="info" %}
AI 없이 답을 적는다. 다 쓰면 체크하고, 이 안내는 지워도 된다.
{% endhint %}

- [ ] 버텍스 셰이더와 프래그먼트 셰이더가 각각 몇 번 실행되는지(정점 수? 픽셀 수?), 그 차이가 성능에 어떤 뜻인지 쓴다.
- [ ] URP 프로젝트에서 셰이더를 만드는 두 가지 방법(HLSL 직접 작성, Shader Graph)의 장단점을 쓴다.
