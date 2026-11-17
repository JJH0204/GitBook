# 소스 지도 — 파일마다 한눈에

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSS-025-REF |
| 유형 | REF (파일 목록 표) |
| 목적 | `source/`의 파일별 역할, 주요 내용, 학습하는 Day를 찾아본다 |
| 대상 | `com.blueigloo.shader` v0.2.0 (`.meta` 파일을 제외하고 복사한 것) |
| 확인 상태 | 미검증 (파일 목록과 본문을 대조해 작성했으며 Unity에서 컴파일·실행하지 않았다) |
| 개정 | R1 (2026-11-18) |

표의 "역할"은 비유를 괄호로 덧붙인 한 줄 설명이다. 줄 번호는 `source/`에 복사된 v0.2.0 기준이다.

## 셰이더 (`.shader`) — 셰이더 본체

| 파일 | 역할 | 주요 내용 | Day |
|---|---|---|---|
| [CharacterToon/Shaders/CharacterToon.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader) | 캐릭터 셰이더 전체 (주인공의 전체 지시서) | 패스 6개. ForwardToon(L197–668): 셀 밴드, 얼굴 SDF, 그림자, 추가광, 림, MatCap, 스펙큘러, 천사 고리, 눈, 발광. Outline(L673), ShadowCaster(L752), DepthOnly(L829), DepthNormals(L869), MotionVectors(L924) | 03–20 |
| [CharacterToon/Shaders/CharacterToon_Unlit.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon_Unlit.shader) | 조명 계산이 없는 가벼운 변형 | 색칠 패스만 따로 두고 나머지는 `UsePass`로 Lit 셰이더의 패스를 빌려 쓴다 (L289–293) | 18 |
| [CharacterToon/Shaders/ScreenSpaceOutline.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/ScreenSpaceOutline.shader) | 화면 공간 외곽선 (펜으로 선 긋기) | 깊이·노멀 엣지(이웃 픽셀 차분), 물체별 억제(w 채널) | 14 |
| [SceneToon/Shaders/SceneToon.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon.shader) | 배경 오브젝트 셰이더 | 공유 코어 셀 음영, 라이트맵 GI 계단화, SSAO, 섀도마스크, 트라이플래너, 정점 색 블렌딩, 바람, 잎 투과, 인스턴싱·GRD·LOD 크로스페이드 | 10, 20, 21 |
| [SceneToon/Shaders/SceneToon_Terrain.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon_Terrain.shader) | 지형 셰이더 | 4-스플랫, Draw Instanced, 라이트맵, Meta 패스, `BaseMapShader` | 21 |
| [SceneToon/Shaders/SceneToon_Sky.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon_Sky.shader) | 하늘 셰이더 (70줄, 입문용) | 위·수평·아래 세 색 그라데이션 | 03 |

## 셰이더 라이브러리 (`.hlsl`) — 공용 함수 모음

| 파일 | 역할 | 주요 내용 | Day |
|---|---|---|---|
| [CharacterToon/ShaderLibrary/ToonInput.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl) | 캐릭터 입력·상수 정의 (재료 창고) | 텍스처 선언, **CBUFFER 단일 정의**(SRP Batcher), `ClipToonSurface()`(모든 패스 공용 가위), 캐릭터 조명 글로벌 | 04, 05, 09, 20 |
| [CharacterToon/ShaderLibrary/ToonLighting.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonLighting.hlsl) | 캐릭터 조명 함수 | `SafeNormalizeXZ`, `GetUVTangentWS`(미분 탄젠트), `ApplyNormalMapDerivative`(탄젠트 없는 노멀맵), `ShadeAdditionalToon`, 추가 캐릭터 조명 합산 | 06, 09, 16 |
| [CharacterToon/ShaderLibrary/ToonOutline.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonOutline.hlsl) | 외곽선 계산 (풍선 부풀리기) | 스무스 노멀 검사, 폭 조절 장치, 픽셀 단위 폭(`× w`), 최소 1px 게이트 | 12, 13 |
| [CharacterToon/ShaderLibrary/ToonMotionVectors.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonMotionVectors.hlsl) | 모션 벡터 계산 | 오브젝트 모션 벡터(URP 식과 같음) + 알파·스텐실 clip | 18 |
| [SceneToon/ShaderLibrary/SceneToonInput.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/ShaderLibrary/SceneToonInput.hlsl) | 배경 입력·상수 정의 | CBUFFER, `SceneLODFade`, `ApplyWindWS`(바람), `SampleTriplanar`, `SelectVertexChannel` | 20, 21 |
| [SceneToon/ShaderLibrary/SceneTerrainInput.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/ShaderLibrary/SceneTerrainInput.hlsl) | 지형 입력 정의 | `TerrainInstancing`(높이 지도 → 정점), `SampleTerrainAlbedo`(스플랫 무게 평균) | 21 |
| [ToonShared/ShaderLibrary/ToonRamp.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonRamp.hlsl) | 배경 공용: 하프 램버트·램프 | `ToonHalfLambert`, `ToonRampU`, `SampleToonRamp` | 06, 07 |
| [ToonShared/ShaderLibrary/ToonBandShadow.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonBandShadow.hlsl) | 배경 공용: 음영 계단 | `ToonBandFactor`, `ToonShadeBands`(1·2차 밴드), `ToonPosterize`(GI 계단) | 07, 10 |
| [ToonShared/ShaderLibrary/ToonRim.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonRim.hlsl) | 배경 공용: 림 라이트 (17줄) | `ToonRim` — 프레넬 림 | 04, 11 |
| [ToonShared/ShaderLibrary/ToonAdditionalLights.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonAdditionalLights.hlsl) | 배경 공용: 추가광 | `ToonAdditionalLightCel`, `ToonAdditionalLightsSum`(Forward+ 디렉셔널 + `LIGHT_LOOP`, 3-인자 그림자) | 09 |

{% hint style="warning" %}
CAUTION: 캐릭터 셰이더는 `ToonShared`를 쓰지 않고 같은 식을 직접 가지고 있다(안정된 캐릭터 셰이더를 배경 작업에서 분리하려는 설계다). 한쪽 공식을 바꾸면 다른 쪽도 수동으로 맞춘다.
{% endhint %}

## 실행 중 스크립트 (`Runtime/*.cs`) — 셰이더에 값 전달

| 파일 | 역할 | 주요 내용 | Day |
|---|---|---|---|
| [CharacterToonLight.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonLight.cs) | 캐릭터 조명 한 개 (인물 조명) | 방향(키 라이트 or Transform), 색·세기, 우선순위 → `GetRig()` | 09 |
| [CharacterToonManager.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonManager.cs) | 조명 전역 전달 (방송실) | 캐릭터 조명을 우선순위로 정렬 → `Shader.SetGlobalVector` 방송. `AnyRendererUsesDepthPriming()` | 09, 13 |
| [CharacterToonFace.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonFace.cs) | 얼굴 방향 전달 (렌더러별 MaterialPropertyBlock) | 얼굴 렌더러마다 MaterialPropertyBlock으로 `_FaceForwardWS/_FaceRightWS` | 15, 20 |
| [CharacterToonRendererFeature.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonRendererFeature.cs) | URP Renderer Feature | 매 카메라 조명 방송 + 화면 공간 외곽선 패스(RenderGraph 블릿) | 14 |

## 에디터 도구 (`Editor/*.cs`) — 제작 보조 도구

| 파일 | 역할 | 주요 내용 | Day |
|---|---|---|---|
| [CharacterToonShaderGUI.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonShaderGUI.cs) | 머티리얼 인스펙터 GUI | 섹션·파트별 옵션, Surface 모드 → Blend/ZWrite/큐, Depth Priming 경고 | 13, 19 |
| [CharacterToonKeywordSanitizer.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonKeywordSanitizer.cs) | 머티리얼 키워드 정리 (빌드 전) | 파트와 안 맞는 키워드 끄기, 디버그 끄기, Outline 패스 켜고 끄기 | 19 |
| [CharacterToonShaderStripper.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonShaderStripper.cs) | 배리언트 스트리핑 | 디버그·불가능 조합 배리언트 제거 | 19 |
| [CompileCheck.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CompileCheck.cs) | 컴파일 점검 | 셰이더 컴파일 오류, C#이 쓰는 셰이더 이름 확인 | 19 |
| [SmoothNormalUtil.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalUtil.cs) · [SmoothNormalBaker.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalBaker.cs) · [SmoothNormalModelPostprocessor.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalModelPostprocessor.cs) · [SmoothNormalFbxBakeTool.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalFbxBakeTool.cs) | 스무스 노멀 베이크 | 같은 위치 정점의 노멀 평균 → TANGENT에 저장, 블렌드셰이프 탄젠트 델타 비우기, 폴더 자동 베이크 | 12 |
| [CharacterToonProjectSettings.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonProjectSettings.cs) | 프로젝트 설정 페이지 | 자동 베이크할 폴더 목록 (Project Settings > CharacterToon) | 12 |
| [FaceSdfValidatorWindow.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/FaceSdfValidatorWindow.cs) | 얼굴 SDF 검사 창 | 조명 각도·얼굴 방향을 돌려 보며 그림자 경계가 좌우 튐 없이 매끄럽게 움직이는지 확인 | 15 |
| [ILMPackerWindow.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/ILMPackerWindow.cs) | 채널 패킹 도구 | 흑백 텍스처 4장 → ILM 한 장(RGBA) | 05 |
| [URATextureImportPostprocessor.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/URATextureImportPostprocessor.cs) | 텍스처 임포트 규칙 (현재 비활성) | URA 샘플 텍스처의 임포트 설정을 강제하던 도구. 파일 전체가 주석 처리돼 있다 | — |
| [SceneToonShaderGUI.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Editor/SceneToonShaderGUI.cs) · [SceneToonShaderStripper.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Editor/SceneToonShaderStripper.cs) | 배경용 인스펙터·스트리퍼 | 캐릭터 쪽과 같은 역할 | 19 |

## 그 밖의 파일

| 파일 | 내용 |
|---|---|
| [CHANGELOG.md](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CHANGELOG.md) | 버전별 변경 기록. 본문의 "실제로 있었던 일"(A1~C8 카드)이 모두 여기에 있다 |
| [README.md](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/README.md) | 패키지 설명서 (설치·사용법) |
| [package.json](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/package.json) | Unity 패키지 정보 (이름, 버전 0.2.0, 의존성) |
