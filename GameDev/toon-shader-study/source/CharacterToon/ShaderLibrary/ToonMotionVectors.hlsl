#ifndef CHARACTER_TOON_MOTION_VECTORS_INCLUDED
#define CHARACTER_TOON_MOTION_VECTORS_INCLUDED

// C1: 오브젝트 모션 벡터(MotionVectors 패스). 식은 URP ObjectMotionVectors.hlsl 본문과 같다. 그 파일을 쓰지 않는 이유:
//   - include_with_pragmas 로 가져오면 DOTS_INSTANCING_ON 선언 때문에 GPU Resident Drawer 가 CharacterToon
//     MeshRenderer 를 가져가 DOTS 배리언트 없는 ForwardToon 을 에러로 그린다.
//   - 일반 include 로 가져오면 그 안의 pragma 마다 "unknown pragma ignored" 경고가 남는다.
//   - 알파·스텐실 clip 을 색 패스(ClipToonSurface)와 맞춰야 한다.
// ToonInput.hlsl 다음에 include 할 것.
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MotionVectorsCommon.hlsl"

struct ToonMotionAttributes
{
    float4 positionOS  : POSITION;
    float2 uv          : TEXCOORD0;
    float3 positionOld : TEXCOORD4;   // 스키닝/모프 이전 프레임 위치(엔진이 채움)
};

struct ToonMotionVaryings
{
    float4 positionCS                 : SV_POSITION;
    float4 positionCSNoJitter         : POSITION_CS_NO_JITTER;
    float4 previousPositionCSNoJitter : PREV_POSITION_CS_NO_JITTER;
    float2 uv                         : TEXCOORD0;
};

ToonMotionVaryings ToonMotionVert(ToonMotionAttributes input)
{
    ToonMotionVaryings o = (ToonMotionVaryings)0;
    o.positionCS = TransformObjectToHClip(input.positionOS.xyz);   // 지터 포함(이 프레임과 같은 래스터)
    o.positionCSNoJitter = mul(_NonJitteredViewProjMatrix, mul(UNITY_MATRIX_M, input.positionOS));
    float4 prevPos = (unity_MotionVectorsParams.x == 1) ? float4(input.positionOld, 1) : input.positionOS;
    o.previousPositionCSNoJitter = mul(_PrevViewProjMatrix, mul(UNITY_PREV_MATRIX_M, prevPos));
    o.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    return o;
}

float4 ToonMotionFrag(ToonMotionVaryings input) : SV_Target
{
    ClipToonSurface(input.uv);
    return float4(CalcNdcMotionVectorFromCsPositions(input.positionCSNoJitter, input.previousPositionCSNoJitter), 0, 0);
}

#endif // CHARACTER_TOON_MOTION_VECTORS_INCLUDED
