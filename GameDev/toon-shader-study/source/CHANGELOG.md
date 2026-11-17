# 툰 셰이더 패키지 변경 이력 (CHANGELOG)

## 작업 식별

| 항목 | 내용 |
|---|---|
| Task ID | GMD-TSR-002-REF |
| 유형 | REF (버전별 변경 이력) |
| 목적 | `com.blueigloo.shader`의 버전별 수정, 변경, 추가, 삭제 내역을 찾아본다 |
| 대상 | v0.2.0 (2026-11-16) 까지 |
| 확인 상태 | 미검증 (원본 변경 이력을 그대로 옮겼으며 이 문서로 재검증하지 않았다) |
| 개정 | R1 (2026-11-18) |

{% hint style="info" %}
NOTE: 아래 본문은 패키지의 `CHANGELOG.md` 원문이다. 본문의 카드 번호(A1~C8, PLAN-19)는 학습 노트의 "실제로 있었던 일"이 가리키는 작업 단위다. 패키지 안내는 [README](README.md)(GMD-TSR-001-MP), 파일 목록은 [소스 지도](../source-map.md)(GMD-TSS-025-REF)에 있다.
{% endhint %}

## 원문

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-11-16

### Fixed

- **셰이더 이름 변경 회귀(A1).** 0.1.0 재구성에서 셰이더 이름이 `com.blueigloo/...`로 바뀌었는데
  C#은 옛 이름을 그대로 써서, 인스펙터의 Lit/Unlit 전환이 "셰이더를 찾을 수 없습니다"로 실패하고
  `CharacterToonShaderStripper`·`SceneToonShaderStripper`가 아무것도 걸러내지 않았다. 이름을 고치고
  `CompileCheck`가 C#이 참조하는 셰이더 이름을 `Shader.Find`로 확인하게 했다.

- **renderScale < 1에서 Depth Rim·아웃라인 폭이 틀어짐(A2).** 화면 좌표를 `_ScreenParams`(출력
  해상도)로 나누고 있었는데 URP는 렌더 타깃을 `_ScaledScreenParams` 크기로 그린다. 모바일 에셋
  (renderScale 0.8)에서 Depth Rim UV가 0..0.8로 어긋나 테두리 대신 구체 한가운데에 호가 그려졌고,
  아웃라인 최소 1px은 렌더 타깃에서 0.8px가 되어 PLAN-19 자글거림이 돌아왔다. Depth Rim은
  `GetNormalizedScreenSpaceUV`, 아웃라인과 스크린스페이스 아웃라인은 `_ScaledScreenParams`를 쓴다.
  renderScale이 1이 아닌 경우 픽셀 단위 값(아웃라인 px, Depth Rim 폭, SS 아웃라인 두께)은 이제
  출력 픽셀이 아니라 렌더 타깃 픽셀 기준이다.

- **캐릭터가 둘 이상이면 얼굴 SDF 방향이 섞임(A3).** `_FaceForwardWS`/`_FaceRightWS`가 글로벌이라
  모든 얼굴이 마지막에 쓴 `CharacterToonFace`의 방향을 따랐다. 이제 머티리얼 CBUFFER 값이고,
  `CharacterToonFace`가 자기와 자식 중 Part=Face 렌더러에만 MaterialPropertyBlock으로 넣는다.
  기존 씬은 그대로 동작한다(컴포넌트가 얼굴 메시 오브젝트나 그 부모에 붙어 있으면 된다).
  얼굴 렌더러는 MPB 때문에 SRP Batcher 묶음에서 빠진다. Face SDF Validator 창도 글로벌 대신
  열린 씬의 얼굴 렌더러에 값을 넣는다. 캐릭터 키라이트(`_CharacterLightDirWS`)는 여전히 글로벌이다.

- **스텐실 마스크로 잘라낸 영역이 그림자·외곽선·깊이에 남음(A4).** `_USE_STENCIL_MASK` clip이
  ForwardToon에만 있어서, 잘라낸 부분이 그림자를 드리우고 외곽선 헐이 그 자리를 채웠으며 깊이·노멀
  텍스처(SSAO, Depth Rim, SS 아웃라인)에도 남았다. `ToonInput.hlsl`의 `ClipStencilMask`를
  Outline·ShadowCaster·DepthOnly·DepthNormals 패스도 부른다.

- **SceneToon 추가광에 그림자가 없고 Forward+에서 추가 디렉셔널이 빠짐(A5).** 2-인자
  `GetAdditionalLight`는 그림자 감쇠를 1로 고정한다. 그래서 `_ADDITIONAL_LIGHT_SHADOWS`를 컴파일하면서도
  포인트·스폿 그림자가 생기지 않았다. 또 Forward+(PC 렌더러)에서는 추가 디렉셔널 광원이 클러스터
  밖이라 루프에서 빠졌다. 배경 전용 `ToonShared/ShaderLibrary/ToonAdditionalLights.hlsl`로 루프를
  옮겨 두 문제를 고쳤다. CharacterToon은 그대로다(D-3: 캐릭터는 ToonShared에 의존하지 않는다).
- **라이트 레이어 무시(A7).** 두 RP 에셋 모두 Rendering Layers를 켜 두었는데, CharacterToon과
  SceneToon이 `_LIGHT_LAYERS`를 처리하지 않아 캐릭터 전용 라이트가 배경까지 비췄다(반대도 마찬가지).
  메인 라이트와 추가광 모두 `IsMatchingLightLayer`로 거른다(URP Lit과 같은 규칙). 메인 라이트가
  레이어 밖이면 직접광만 0이 되고 셀 밴드 방향·앰비언트는 그대로다. 두 셰이더의 Forward 패스
  배리언트가 `_LIGHT_LAYERS`만큼 늘어난다.
- **SceneToon 양면 머티리얼의 뒷면이 반대 노멀을 씀(B3).** DepthNormals 패스가 `Cull [_Cull]`로 뒷면을
  그리면서 노멀을 뒤집지 않아, 식생 뒷면이 카메라 반대쪽 노멀을 `_CameraNormalsTexture`에 남겼다
  (SSAO·스크린스페이스 아웃라인 오류). SceneForward와 같은 `IS_FRONT_VFACE` 반전을 넣었다.
- 값으로만 분기하는 토글(`_UseShadowMask`, `_UseMatCapMask`, `_UseMatCap2Mask`, SceneToon `_UseOcclusion`)을
  `[Toggle]` 대신 `[ToggleUI]`로 그린다(C8). `[Toggle]`은 셰이더가 선언하지 않은 `_USEMATCAPMASK_ON` 같은 키워드를
  머티리얼에 붙였다. 이미 붙은 키워드는 무시되며 남아 있어도 해가 없다.
- MatCap·MatCap2 별도 마스크를 토글이 켜졌을 때만 샘플한다(C7, 머티리얼 상수 분기). 렌더 결과는 같다.
- `CharacterToonRendererFeature.Create()`가 다시 불릴 때마다(인스펙터 값 변경 시) 이전 아웃라인 머티리얼을
  해제하지 않아 누수됐다(C6, 5회 호출에 5개). 이제 먼저 해제한다.
- **스무스 노멀 외곽선(C5).** (1) TANGENT에 스무스 노멀을 넣은 뒤에도 블렌드셰이프의 탄젠트 델타(원래
  탄젠트의 변화량)가 남아 표정 모프 때 외곽선 방향이 흔들렸다. 자동 베이크(`SmoothNormalUtil.BakeIntoTangents`)와
  수동 베이커 모두 탄젠트 델타를 비운다(정점·노멀 델타는 유지). (2) 외곽선이 "미베이크 메시"로 판정하는
  임계값을 dot < 0.3 에서 0.02 로 낮췄다. 0.3(≈72.5°)은 날카로운 주름의 진짜 스무스 노멀까지 미베이크로 보고
  원래 노멀로 되돌렸다. 미베이크 탄젠트는 노멀과 거의 정확히 직교한다.
- `_RimSoftness`·`_SpecularStep`이 0일 때 smoothstep이 0/0이 되던 것을 `max(…, 1e-4)`로 막았다(C4,
  `_ShadowBlur`와 같은 가드). 기본값 결과는 같고, 폭 0에선 경계에 정확히 걸린 픽셀만 바뀐다.
- **PBR 툰 스페큘러가 캐스트 그림자 안에서도 빛남(B6).** 받는 그림자 감쇠(`rcvShadow`)를 곱한다.
  그림자 밖 결과는 같다. 환경 반사는 빛 방향과 무관해 그대로다.
- **툰 지형이 Draw Instanced에서 사라지고 라이트맵에 안 들어감(B12).** 인스턴싱 배리언트가 없어 Draw
  Instanced를 켠 지형이 아예 그려지지 않았다. URP TerrainLit과 같은 `TerrainInstancing`(하이트맵에서 정점
  복원)을 모든 패스에 넣었다. 또 `BaseMapShader` 지정이 없어 라이트 베이커가 지형을 "머티리얼 없는 인스턴스"로
  보고 라이트맵 입력에서 뺐다. 자기 자신을 `BaseMapShader`로 지정하고 Meta 패스와 `LIGHTMAP_ON` 샘플링을 넣었다.
- **툰 지형이 부가광·라이트 레이어·SSAO를 받지 않음(B8).** `SceneToon_Terrain`은 메인 라이트만 계산해서
  지형 위 포인트·스폿 라이트가 지형에는 안 닿고 그 위 소품에만 닿았다. SceneToon과 같은
  `ToonAdditionalLightsSum`(그림자·Forward+ 디렉셔널 포함), 라이트 레이어, SSAO를 넣었다.
  `_AdditionalLightStrength` 추가.
- **Unlit 변형이 Render Face를 무시함(A6).** `CharacterToon_Unlit`은 `Cull Back` 고정에 뒷면 노멀
  반전도 없어서 Lit→Unlit 전환 시 양면 설정이 사라졌다. `_Cull`과 뒷면 노멀 반전을 Lit과 같게 넣었다.

### Changed

- **SceneToon이 GPU Resident Drawer·GPU 인스턴싱·LOD 크로스페이드를 지원(B1).** PC 에셋은 GPU Resident
  Drawer를, 두 에셋 모두 LOD 크로스페이드를 켜 두었는데 SceneToon에는 DOTS 인스턴싱 배리언트가 없어
  GRD가 배경 오브젝트를 전부 건너뛰었다(플레이 모드 측정: SceneToon 큐브 20개가 0개로 잡힘 → 이제 20개).
  네 패스에 `multi_compile_instancing`, `DOTS.hlsl`, `LOD_FADE_CROSSFADE`를 넣었다(URP Lit과 같은 구성).
  그만큼 배리언트가 늘며, 쓰지 않는 조합은 URP 스트리핑 설정이 거른다.
- **SceneToon이 SSAO와 혼합 조명(섀도마스크·Subtractive)을 반영(B2).** PC 렌더러는 SSAO를 켜 두었는데
  배경은 AO를 받지 않아 캐릭터에만 접지감이 생겼다. 간접광에는 indirect, 직접광·추가광에는 direct AO를
  곱한다(URP Lit과 같은 배분, `_OcclusionMap`과는 곱). 섀도마스크(`SHADOWS_SHADOWMASK`,
  `LIGHTMAP_SHADOW_MIXING`)를 메인·추가광 그림자에 넘기고, Subtractive는 `MixRealtimeAndBakedGI`로 처리한다.
  `ToonAdditionalLightsSum`에 `shadowMask` 인자가 추가됐다.
- **아웃라인을 끈 머티리얼은 Outline 패스 자체를 끈다(B4).** 키워드가 꺼져도 셰이더는 정점을 화면 밖으로
  보낼 뿐이라 드로우콜과 스키닝된 정점 처리는 남았다. `CharacterToonKeywordSanitizer`가 `_USE_OUTLINE`에
  맞춰 `SetShaderPassEnabled("SRPDefaultUnlit", …)`를 맞춘다(인스펙터·빌드 직전).
- CharacterToon 인스펙터에서 효과 없는 "Enable GPU Instancing" 체크박스를 뺐다. 캐릭터 셰이더에는
  인스턴싱 배리언트가 없고 스킨드 메시는 인스턴싱 대상이 아니다.
- **CharacterToon에 MotionVectors 패스 추가(C1).** 없어서 URP의 오브젝트 모션 벡터에서 툰 캐릭터가
  빠졌다(모션 블러 "Camera and Objects"에서 움직이는 툰 오브젝트만 선명, TAA·STP 잔상 원인). 식은 URP
  `ObjectMotionVectors.hlsl`과 같지만 `ToonMotionVectors.hlsl`로 따로 둔다: 그 파일을 `include_with_pragmas`로
  가져오면 `DOTS_INSTANCING_ON` 선언 때문에 GPU Resident Drawer가 CharacterToon MeshRenderer를 가져가
  ForwardToon을 에러(마젠타)로 그렸고, 일반 `#include`로는 pragma 경고 8개가 남았다. 색 패스처럼 알파·스텐실
  clip(`ClipToonSurface`)도 한다. Unlit은 `UsePass`로 같은 패스를 쓴다.
- `CharacterToon_Unlit`의 Outline·ShadowCaster·DepthOnly·DepthNormals 패스를 복사본(229줄) 대신
  Lit 패스 `UsePass`로 쓴다. 복사본에는 Lit에만 들어간 수정(Render Face, 뒷면 노멀, A4 스텐실 clip)이
  빠져 있었다.

- **스무스 노멀 자동 베이크 폴더를 Project Settings에서 정한다(B7).** 코드에 `/sample/fbx/`가 박혀 있어
  패키지를 쓰는 프로젝트에서는 폴더 자동 베이크가 동작하지 않았다(FBX별 등록만 됐다). 이제
  Project Settings > CharacterToon의 "Auto Smooth Normal Folders"(`ProjectSettings/CharacterToonSettings.asset`,
  기본값 `Assets/Sample/FBX`)를 쓴다. "Reimport Models" 메뉴는 등록된 FBX도 함께 다시 임포트한다.

- CharacterToon 인스펙터의 Outline 섹션이 URP 렌더러에 Depth Priming이 켜져 있으면 경고한다(C2).
  켜지면 URP가 불투명 드로우를 ZTest Equal/ZWrite Off로 덮어써서 인버티드 헐 외곽선과 ZTest Always(앞머리
  투과)가 사라진다(Forced로 실측 확인). 판정은 `CharacterToonManager.AnyRendererUsesDepthPriming()`.
- 스크린스페이스 아웃라인 패스가 읽는 `_CameraDepthTexture`·`_CameraNormalsTexture`를 RenderGraph에 선언한다(B11).
  선언 없는 전역 텍스처 읽기는 RenderGraph에서 정의되지 않은 동작이다. 현재 URP에서 재현되는 문제는 없었다.

### Removed

- `ToonLighting.hlsl`의 쓰이지 않는 헬퍼 `SampleILM`, `GetCharacterLightDirection`(B10). 후자는
  본문(`CharacterToon.shader`)에 있는 0-벡터 가드가 빠진 옛 사본이었다.
- **죽은 키워드(B5).** CharacterToon의 `_PART_NONE`/`_PART_CLOTH`(파트 분기는 Face/Hair/Skin뿐이라 같은
  셰이더가 두 번 컴파일됐다), Unlit의 `_PART_*` 전부(쓰는 곳 없음), CharacterToon·SceneToon의
  `_ADDITIONAL_LIGHTS_VERTEX`(정점 부가광 경로가 없어 부가광 없는 배리언트와 같았다). None/Cloth 머티리얼은
  기본 배리언트를 쓰며 렌더 결과는 같다. RP 에셋이 Per Vertex 부가광 모드면 툰 셰이더에 부가광이 들어가지
  않는다(이전과 동일, 현재 두 에셋 모두 Per Pixel).

### Added

- **CharacterToon 알파 클립(C3).** `Alpha Clipping`(`_ALPHATEST_ON`)·`Alpha Cutoff`. 헤어 카드·속눈썹용.
  BaseMap 알파 × Base Color 알파로 색·깊이·노멀·그림자·외곽선 패스가 함께 버린다(A4의 `ClipStencilMask`를
  `ClipToonSurface`로 넓혔다). Lit·Unlit 모두.
- `CharacterToonKeywordSanitizer` — 파트(`_PART_*`)와 맞지 않는 기능 키워드(`_USE_ANGELRING`,
  `_USE_SSS`, `_USE_HAIR_SHADOW`, `_DEBUG_FACELIT`)를 머티리얼에서 끈다. 인스펙터(`ValidateMaterial`)와
  빌드 직전에 돈다. 스트리퍼가 살아나면서 이 정리가 필요해졌다: `_UseAngelRing` 기본값이 1이라 헤어가
  아닌 머티리얼 대부분이 `_USE_ANGELRING`을 켠 채였고, 스트리퍼가 그 조합을 지우면 해당 머티리얼은
  빌드에서 쓸 배리언트를 잃는다. 빌드 직전에는 디버그 뷰(`_DEBUG_FACELIT`)도 끈다.

## [0.1.1] - 2026-08-20

### Fixed

- **PLAN-19 아웃라인 자글거림.** 폭이 월드 단위(`_OutlineWidth × 0.01`)라 화면상 두께가
  카메라 거리에 반비례했다. 실측 `_OutlineWidth=0.113` → 월드 1.13mm → FOV 60°/1080p
  기준 6m(쿼터뷰)에서 **0.18px**. 서브픽셀 폭의 삼각형 띠는 프레임마다 픽셀 중심을
  덮었다 말았다 하며 실루엣을 따라 기어다닌다. 폭 결정을 화면(픽셀) 공간으로 옮겨
  해결했다. 기본값 `Min Width (px) = 1`이 기존 머티리얼에도 자동 적용되므로
  아트 재작업 없이 증상이 사라진다.
- `CompileCheck`가 검사할 셰이더를 하나도 못 찾고 있었다. 0.1.0에서 셰이더가
  `Assets/` → `Packages/`로 옮겨졌는데 검사 경로가 `Assets/*`에 남아 있어
  **셰이더 0개를 뒤지고 errors=0으로 통과 보고**했다. 경로를 패키지로 고치고,
  0개를 찾으면 실패로 세도록 가드를 넣었다.

### Added

- `_OutlineWidthMode` (World / Screen) — Screen은 폭을 픽셀로 고정해 거리·FOV·
  오브젝트 스케일과 무관하게 일정한 두께를 낸다. 기본은 World(레거시 호환).
- `_OutlineWidthPixels` — Screen 모드의 폭(px).
- `_OutlineMinPixels` — 두 모드 공통 최소 폭(px), 기본 1. 서브픽셀 조건 자체를 없앤다.
  폭을 0으로 껐거나 Width Mask로 지운 부위는 이 값과 무관하게 그대로 그려지지 않는다.

### Changed

- 아웃라인 정점 계산을 `CharacterToon/ShaderLibrary/ToonOutline.hlsl`로 추출했다.
  `CharacterToon.shader`와 `CharacterToon_Unlit.shader`에 같은 로직이 복붙돼 있어
  한쪽만 고치면 조용히 어긋나던 것을 없앴다.

## [0.1.0] - 2026-08-20

### Added

- 독립 UPM 패키지로서의 첫 릴리스. 저장소 루트가 패키지 루트이므로 UPM URL에 `?path=`가 필요 없다.
- `SceneToon.Editor` asmdef 추가. 이 폴더에는 asmdef가 없었고, 패키지 코드는 asmdef에
  속해야만 컴파일되므로 `SceneToonShaderGUI`와 `SceneToonShaderStripper`가 조용히
  누락되던 상태였다(머티리얼 인스펙터 없음, 빌드 시 배리언트 스트리핑 없음).

### Changed

- `BlueIgloo/unity-toonshader`의 `Assets/{CharacterToon,SceneToon,ToonShared}`에서
  이 저장소로 분리했다. 셰이더 이력 16커밋은 `git filter-repo`로 그대로 옮겼다.
- `.meta` GUID 42개가 전부 보존됐다. 기존 머티리얼과 asmdef 참조는 그대로 해석된다.

### Removed

- 이 저장소에는 Git LFS와 바이너리 에셋을 두지 않는다. 시각 검증용 샘플은 저작
  프로젝트에 남겨, UPM clone이 수백 MB를 끌어오지 않게 했다.
