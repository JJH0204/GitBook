# 소스 지도 — 파일마다 한눈에

`source/`는 `com.blueigloo.shader` **v0.2.0**을 그대로 옮긴 거예요(`.meta` 파일만 뺐어요). 파일마다 **무엇을 하는지(비유)**, **주요 내용**, **배우는 날**을 정리했어요.

## 셰이더 (`.shader`) — 지시서 본체

| 파일 | 비유 | 주요 내용 | Day |
|---|---|---|---|
| [CharacterToon/Shaders/CharacterToon.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon.shader) | 주인공의 **전체 지시서** | 패스 6개. ForwardToon(L197–668): 셀 밴드, 얼굴 SDF, 그림자, 추가광, 림, MatCap, 스펙큘러, 천사 고리, 눈, 발광. Outline(L673), ShadowCaster(L752), DepthOnly(L829), DepthNormals(L869), MotionVectors(L924) | 03–20 |
| [CharacterToon/Shaders/CharacterToon_Unlit.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/CharacterToon_Unlit.shader) | 조명 계산 없는 **가벼운 지시서** | 색칠 패스만 따로, 나머지는 `UsePass`로 Lit 것을 빌려 씀 (L289–293) | 18 |
| [CharacterToon/Shaders/ScreenSpaceOutline.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Shaders/ScreenSpaceOutline.shader) | 다 그린 그림에 **펜으로 선 긋기** | 깊이(로버츠 크로스)·노멀 엣지, 물체별 억제(w 채널) | 14 |
| [SceneToon/Shaders/SceneToon.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon.shader) | 배경 물체 지시서 | 공유 코어 셀 음영, 라이트맵 GI 계단화, SSAO, 섀도마스크, 트라이플래너, 정점 색 블렌딩, 바람, 잎 투과, 인스턴싱·GRD·LOD 크로스페이드 | 10, 20, 21 |
| [SceneToon/Shaders/SceneToon_Terrain.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon_Terrain.shader) | 땅 지시서 | 4-스플랫, Draw Instanced, 라이트맵, Meta 패스, `BaseMapShader` | 21 |
| [SceneToon/Shaders/SceneToon_Sky.shader](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Shaders/SceneToon_Sky.shader) | 하늘 지시서 (70줄, **입문용**) | 위·수평·아래 세 색 그라데이션 | 03 |

## 셰이더 라이브러리 (`.hlsl`) — 공구함

| 파일 | 비유 | 주요 내용 | Day |
|---|---|---|---|
| [CharacterToon/ShaderLibrary/ToonInput.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonInput.hlsl) | 캐릭터의 **재료 창고** | 텍스처 선언, **CBUFFER 단일 정의**(SRP Batcher), `ClipToonSurface()`(모든 패스 공용 가위), 캐릭터 조명 글로벌 | 04, 05, 09, 20 |
| [CharacterToon/ShaderLibrary/ToonLighting.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonLighting.hlsl) | 캐릭터 **조명 도구** | `SafeNormalizeXZ`, `GetUVTangentWS`(미분 탄젠트), `ApplyNormalMapDerivative`(탄젠트 없는 노멀맵), `ShadeAdditionalToon`, 추가 캐릭터 조명 합산 | 06, 09, 16 |
| [CharacterToon/ShaderLibrary/ToonOutline.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonOutline.hlsl) | **풍선 부풀리기** 계산 | 스무스 노멀 검사, 폭 조절 장치, 픽셀 단위 폭(`× w`), 최소 1px 게이트 | 12, 13 |
| [CharacterToon/ShaderLibrary/ToonMotionVectors.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/ShaderLibrary/ToonMotionVectors.hlsl) | **지난 프레임과 비교** | 오브젝트 모션 벡터(URP 식과 같음) + 알파·스텐실 clip | 18 |
| [SceneToon/ShaderLibrary/SceneToonInput.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/ShaderLibrary/SceneToonInput.hlsl) | 배경의 재료 창고 | CBUFFER, `SceneLODFade`, `ApplyWindWS`(바람), `SampleTriplanar`, `SelectVertexChannel` | 20, 21 |
| [SceneToon/ShaderLibrary/SceneTerrainInput.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/ShaderLibrary/SceneTerrainInput.hlsl) | 땅의 재료 창고 | `TerrainInstancing`(높이 지도 → 정점), `SampleTerrainAlbedo`(스플랫 무게 평균) | 21 |
| [ToonShared/ShaderLibrary/ToonRamp.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonRamp.hlsl) | 배경 공용: **손전등 점수** | `ToonHalfLambert`, `ToonRampU`, `SampleToonRamp` | 06, 07 |
| [ToonShared/ShaderLibrary/ToonBandShadow.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonBandShadow.hlsl) | 배경 공용: **계단** | `ToonBandFactor`, `ToonShadeBands`(1·2차 밴드), `ToonPosterize`(GI 계단) | 07, 10 |
| [ToonShared/ShaderLibrary/ToonRim.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonRim.hlsl) | 배경 공용: **테두리 빛** (17줄) | `ToonRim` — 프레넬 림 | 04, 11 |
| [ToonShared/ShaderLibrary/ToonAdditionalLights.hlsl](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/ToonShared/ShaderLibrary/ToonAdditionalLights.hlsl) | 배경 공용: **보조 조명 팀** | `ToonAdditionalLightCel`, `ToonAdditionalLightsSum`(Forward+ 디렉셔널 + `LIGHT_LOOP`, 3-인자 그림자) | 09 |

{% hint style="info" %}
**동기화 약속**: 캐릭터 셰이더는 `ToonShared`를 쓰지 않고 같은 식을 직접 가지고 있어요(안정된 캐릭터를 배경 작업에서 독립시키려고). 한쪽 공식을 바꾸면 다른 쪽도 손으로 맞춰야 해요.
{% endhint %}

## 실행 중 스크립트 (`Runtime/*.cs`) — 셰이더에 값 넣기

| 파일 | 비유 | 주요 내용 | Day |
|---|---|---|---|
| [CharacterToonLight.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonLight.cs) | **인물 조명** 하나 | 방향(키 라이트 or Transform), 색·세기, 우선순위 → `GetRig()` | 09 |
| [CharacterToonManager.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonManager.cs) | 조명 **방송실** | 캐릭터 조명을 우선순위로 정렬 → `Shader.SetGlobalVector` 방송. `AnyRendererUsesDepthPriming()` | 09, 13 |
| [CharacterToonFace.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonFace.cs) | 얼굴 방향 **포스트잇** | 얼굴 렌더러마다 MPB로 `_FaceForwardWS/_FaceRightWS` | 15, 20 |
| [CharacterToonRendererFeature.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Runtime/CharacterToonRendererFeature.cs) | URP **확장 카드** | 매 카메라 조명 방송 + 화면 공간 외곽선 패스(RenderGraph 블릿) | 14 |

## 에디터 도구 (`Editor/*.cs`) — 만드는 사람을 돕는 도구

| 파일 | 비유 | 주요 내용 | Day |
|---|---|---|---|
| [CharacterToonShaderGUI.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonShaderGUI.cs) | 머티리얼 **인스펙터 화면** | 섹션·파트별 옵션, Surface 모드 → Blend/ZWrite/큐, Depth Priming 경고 | 13, 19 |
| [CharacterToonKeywordSanitizer.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonKeywordSanitizer.cs) | 빌드 전 **머티리얼 정리기** | 파트와 안 맞는 키워드 끄기, 디버그 끄기, Outline 패스 켜고 끄기 | 19 |
| [CharacterToonShaderStripper.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonShaderStripper.cs) | 안 팔리는 **빵 버리기** | 디버그·불가능 조합 배리언트 제거 | 19 |
| [CompileCheck.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CompileCheck.cs) | **점검표** | 셰이더 컴파일 오류, C#이 쓰는 셰이더 이름 확인 | 19 |
| [SmoothNormalUtil.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalUtil.cs) · [SmoothNormalBaker.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalBaker.cs) · [SmoothNormalModelPostprocessor.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalModelPostprocessor.cs) · [SmoothNormalFbxBakeTool.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/SmoothNormalFbxBakeTool.cs) | **평균 노멀 굽기** | 같은 위치 정점의 노멀 평균 → TANGENT에 저장, 블렌드셰이프 탄젠트 델타 비우기, 폴더 자동 베이크 | 12 |
| [CharacterToonProjectSettings.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/CharacterToonProjectSettings.cs) | 프로젝트 **설정 페이지** | 자동 베이크할 폴더 목록 (Project Settings > CharacterToon) | 12 |
| [FaceSdfValidatorWindow.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/FaceSdfValidatorWindow.cs) | 얼굴 SDF **검사 창** | 조명 각도·얼굴 방향을 돌려 보며 그림자 경계가 좌우 튐 없이 매끄럽게 움직이는지 확인 | 15 |
| [ILMPackerWindow.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/ILMPackerWindow.cs) | **채널 패킹** 도구 | 흑백 텍스처 4장 → ILM 한 장(RGBA) | 05 |
| [URATextureImportPostprocessor.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CharacterToon/Editor/URATextureImportPostprocessor.cs) | 텍스처 **가져오기 규칙** (지금은 꺼짐) | URA 샘플 텍스처의 임포트 설정을 강제하던 도구. 파일 전체가 주석 처리돼 있어요 | — |
| [SceneToonShaderGUI.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Editor/SceneToonShaderGUI.cs) · [SceneToonShaderStripper.cs](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/SceneToon/Editor/SceneToonShaderStripper.cs) | 배경용 인스펙터·스트리퍼 | 캐릭터 쪽과 같은 역할 | 19 |

## 그 밖의 파일

| 파일 | 내용 |
|---|---|
| [CHANGELOG.md](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/CHANGELOG.md) | 버전별 변경 기록. 본문의 "💡 실제로 있었던 일"(A1~C8 카드)이 전부 여기에 있어요 |
| [README.md](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/README.md) | 패키지 설명서 (설치·사용법) |
| [package.json](https://github.com/JJH0204/GitBook/blob/main/GameDev/toon-shader-study/source/package.json) | Unity 패키지 정보 (이름, 버전 0.2.0, 의존성) |
