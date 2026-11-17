#ifndef CHARACTERTOON_OUTLINE_INCLUDED
#define CHARACTERTOON_OUTLINE_INCLUDED

// =============================================================================
// 인버티드 헐 아웃라인 정점 계산 (CharacterToon.shader / CharacterToon_Unlit.shader 공용)
//
// 두 셰이더에 같은 로직이 복붙돼 있어 한쪽만 고치면 조용히 어긋났다. 여기로 모은다.
// ToonInput.hlsl(_Outline* 프로퍼티)을 먼저 include 한 뒤 이 파일을 include 할 것.
//
// PLAN-19 (아웃라인 자글거림)
//   원인: 폭이 월드 단위(_OutlineWidth×0.01)라 화면상 두께가 카메라 거리에 반비례한다.
//         실측 _OutlineWidth=0.113 → 월드 1.13mm → FOV 60°/1080p 기준 6m에서 0.18px.
//         서브픽셀 폭의 삼각형 띠는 프레임마다 픽셀 중심을 덮었다 말았다 하며 기어다닌다.
//   대응: 폭 결정을 화면(픽셀) 공간으로 옮긴다.
//         - Screen 모드: _OutlineWidthPixels 픽셀로 고정 → 거리·FOV·오브젝트 스케일 무관.
//         - 최소 폭 클램프(_OutlineMinPixels): 두 모드 공통. 서브픽셀 조건 자체를 제거한다.
//         원근 나눗셈에서 상쇄되도록 클립 공간 오프셋에 w를 곱하는 것이 요점.
// =============================================================================

// 폭 가중(widthMul)과 폭 자체를 분리해 받는다.
//   widthMul: 호출부에서 샘플링한 값(폭 마스크 R, ILM.a 억제 등)을 곱해 넘긴다.
//   분리하는 이유 — 최소 폭 클램프가 "여긴 외곽선 없음(mask=0)"을 무시하고 선을 되살리면 안 된다.
float4 CharacterToonOutlinePositionCS(
    float3 positionOS,
    float3 normalOS,
    float3 bakedSmoothNormalOS,   // TANGENT.xyz (스무스 노멀 베이크 결과)
    float4 vertexColor,
    half   widthMul)
{
    // --- 스무스 노멀 유효성 검사 -------------------------------------------------
    // 베이크 안 된 메시는 TANGENT가 '진짜 탄젠트'(노멀과 ~수직)라 외곽선이 엉뚱하게 부풀어 끊긴다.
    float3 smoothNormalOS = bakedSmoothNormalOS;
    float  tlen = length(smoothNormalOS);
    // C5: 임계값 0.3(≈72.5°)은 날카로운 주름(머리 끝·옷 단)의 진짜 스무스 노멀까지 '미베이크'로 오판해
    //   그 정점만 원래 노멀로 돌아가 외곽선이 갈라졌다. 미베이크 탄젠트는 노멀과 거의 정확히 직교(dot≈0)이므로
    //   0.02(≈177.7° 주름까지 허용)로 낮춘다.
    if (tlen < 1e-4 || dot(smoothNormalOS / max(tlen, 1e-5), normalOS) < 0.02)
        smoothNormalOS = normalOS;

    float3 positionWS = TransformObjectToWorld(positionOS);
    float3 normalWS   = normalize(TransformObjectToWorldNormal(smoothNormalOS));

    // --- 폭 가중 ---------------------------------------------------------------
    float widthScale = widthMul;
    // lilToon _OutlineVertexR2Width: 0=끔 / 1=color.R / 2=color.A
    if (_OutlineVertexColorWidth > 1.5h)      widthScale *= vertexColor.a;
    else if (_OutlineVertexColorWidth > 0.5h) widthScale *= vertexColor.r;

    float3 toCam   = _WorldSpaceCameraPos - positionWS;
    float  camDist = length(toCam);
    // lilToon _OutlineFixWidth: 카메라 매우 가까울 때(거리<1) 폭 축소.
    widthScale *= lerp(1.0, saturate(camDist), _OutlineFixWidth);
    // (확장) 원거리 페이드. _OutlineDistanceFade=0 이면 영향 없음.
    widthScale *= lerp(1.0, saturate(_OutlineFadeStart / max(camDist, 1e-3)), _OutlineDistanceFade);
    widthScale = max(widthScale, 0.0);

    // --- lilToon _OutlineZBias: 시선 방향으로 카메라에서 밀기(기본 0) ----------------
    float3 viewDirWS = (camDist > 1e-5) ? toCam / camDist : float3(0, 0, 0);
    positionWS -= viewDirWS * _OutlineDepthOffset;

    float4 posCS = TransformWorldToHClip(positionWS);

    // --- 폭을 픽셀로 환산 --------------------------------------------------------
    // w<=0(카메라 뒤) 정점은 어차피 클리핑되지만, 나눗셈 부호가 뒤집혀 근평면 근처 삼각형이
    // 뒤틀리는 것을 막기 위해 환산과 복원에 '같은' 클램프된 w를 쓴다.
    float w = max(posCS.w, 1e-4);

    // 단위 노멀의 클립 공간 방향 → NDC → 픽셀
    // 픽셀은 '렌더 타깃' 픽셀(_ScaledScreenParams). 래스터화가 거기서 일어나므로 서브픽셀 판정도 거기서 해야 한다.
    // _ScreenParams(출력 해상도)를 쓰면 renderScale 0.8(모바일)에서 최소 1px이 0.8px로 줄어 자글거림이 돌아온다.
    float2 dirCS = mul(GetWorldToHClipMatrix(), float4(normalWS, 0.0)).xy;
    float2 wPix  = dirCS * ((_OutlineWidth * 0.01 * widthScale) / w) * 0.5 * _ScaledScreenParams.xy;
    float  pixLen = length(wPix);

    // 확장 방향(픽셀 공간 단위 벡터). 노멀이 시선축과 거의 평행하면 화면상 방향이 정의되지 않는데,
    // 그런 정점은 실루엣이 아니라 본체 뒤에 가려지므로 확장을 건너뛴다.
    float2 dirPix = (pixLen > 1e-6) ? (wPix / pixLen)
                                    : ((length(dirCS) > 1e-6) ? normalize(dirCS * _ScaledScreenParams.xy) : float2(0, 0));

    // --- 목표 픽셀 폭 ------------------------------------------------------------
    // Screen 모드는 픽셀 폭을 직접 지정, World 모드는 위에서 환산한 값을 그대로 쓴다.
    float screenPix = _OutlineWidthPixels * widthScale;
    float targetPix = (_OutlineWidthMode > 0.5h) ? screenPix : pixLen;

    // 최소 폭 클램프. 폭을 0으로 꺼둔 머티리얼이나 마스크로 지운 부위를 되살리면 안 되므로
    // '원래 그려질 예정이었는지'로 게이트한다.
    half  baseWidth = (_OutlineWidthMode > 0.5h) ? _OutlineWidthPixels : _OutlineWidth;
    float enable    = step(1e-6, baseWidth) * saturate(widthScale);
    targetPix = max(targetPix, _OutlineMinPixels * enable);

    // --- 클립 공간에 픽셀 폭으로 확장 ----------------------------------------------
    // w를 곱해 원근 나눗셈에서 상쇄시킨다 → 화면상 두께가 거리와 무관하게 고정된다.
    posCS.xy += dirPix * (targetPix * 2.0 / _ScaledScreenParams.xy) * w;

    return posCS;
}

#endif // CHARACTERTOON_OUTLINE_INCLUDED
