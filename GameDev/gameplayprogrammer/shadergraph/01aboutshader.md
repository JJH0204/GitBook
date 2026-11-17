# 셰이더 기초 개념과 종류 (Shader)

{% hint style="warning" %}
{% endhint %}

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

#### Compute Shader

* 그래픽 파이프라인 외에서 병렬 연산 수행
* 예: 물리 계산, 파티클 시뮬레이션, AI 처리 등

#### Tessellation Shader

* 정점을 더 촘촘하게 세분화
* 고해상도 곡면 표현에 사용 (캐릭터 얼굴 등)

### 쉐이더 언어

* HLSL (High-Level Shading Language)
* GLSL (OpenGL Shading Language)
* Cg (C for Graphics)
* ShaderLab + HLSL/GLSL

### 플랫폼 / API

* DirectX (Windows 중심)
* OpenGL, WebGL (크로스 플랫폼)
* Nvidia (하드웨어/도구 관련)

### Unity 엔진 쉐이더 포맷

* Custom Shader (HLSL 직접 작성)
* Surface Shader (Unity 전용 래퍼)
* Shader Graph (노드 기반 비주얼 툴)

### 리소스

* https://learn.unity.com/search/?k=%5B%22q%3Ashader%22%5D
* https://thebookofshaders.com/
* https://catlikecoding.com/unity/tutorials/rendering/
* https://youtu.be/KnueAgpUL3Y?si=V92O9PHGQTccBANf
