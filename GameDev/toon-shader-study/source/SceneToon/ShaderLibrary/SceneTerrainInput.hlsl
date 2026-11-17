#ifndef SCENETOON_TERRAIN_INPUT_INCLUDED
#define SCENETOON_TERRAIN_INPUT_INCLUDED

// 지형(Unity Terrain) 전용 입력 — B2 초안 (Docs/10 §7.3, D-4 Unity Terrain 경로).
//   4-스플랫(_Control RGBA + _Splat0..3) 1차 블렌딩. 공유 음영 코어로 SceneToon 과 동일 셀 톤.
//   한계: 5+ 레이어(add pass)·터레인 홀·레이어별 노멀맵 미지원. Draw Instanced·라이트맵·Meta 는 B12 에서 지원.

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "../../ToonShared/ShaderLibrary/ToonRamp.hlsl"
#include "../../ToonShared/ShaderLibrary/ToonBandShadow.hlsl"

TEXTURE2D(_Control); SAMPLER(sampler_Control);
TEXTURE2D(_Splat0);  SAMPLER(sampler_Splat0);
TEXTURE2D(_Splat1);  SAMPLER(sampler_Splat1);
TEXTURE2D(_Splat2);  SAMPLER(sampler_Splat2);
TEXTURE2D(_Splat3);  SAMPLER(sampler_Splat3);

CBUFFER_START(UnityPerMaterial)
    float4 _Control_ST;
    float4 _Splat0_ST;
    float4 _Splat1_ST;
    float4 _Splat2_ST;
    float4 _Splat3_ST;

    half4  _ShadowColor;
    half4  _Shadow2ndColor;
    half4  _GIShadeColor;

    half   _ShadowBorder;
    half   _ShadowBlur;
    half   _Shadow2ndBorder;
    half   _Shadow2ndBlur;
    half   _ShadowStrength;
    half   _ReceiveShadowStrength;

    half   _ShadeFloor;
    half   _AmbientStrength;
    half   _GIBandCount;
    half   _GIBandSoftness;
    half   _AdditionalLightStrength;   // B8: 부가광 세기(SceneToon 과 같은 의미)
#ifdef UNITY_INSTANCING_ENABLED
    float4 _TerrainHeightmapRecipSize;   // (1/w, 1/h, 1/(w-1), 1/(h-1)) — Terrain 이 채운다
    float4 _TerrainHeightmapScale;       // (hmScale.x, hmScale.y / kMaxHeight, hmScale.z, 0)
#endif
CBUFFER_END

// B12: Terrain "Draw Instanced". 지형이 패치 단위로 인스턴싱되며 정점 위치·노멀·UV 를 하이트맵에서 복원한다.
//   셰이더에 인스턴싱 배리언트가 없으면 Draw Instanced 지형이 아예 그려지지 않았다.
//   식은 URP TerrainLitInput.hlsl 의 TerrainInstancing 과 같다.
#ifdef UNITY_INSTANCING_ENABLED
TEXTURE2D(_TerrainHeightmapTexture);
TEXTURE2D(_TerrainNormalmapTexture);
SAMPLER(sampler_TerrainNormalmapTexture);
#endif
UNITY_INSTANCING_BUFFER_START(Terrain)
    UNITY_DEFINE_INSTANCED_PROP(float4, _TerrainPatchInstanceData)   // (xBase, yBase, skipScale, ~)
UNITY_INSTANCING_BUFFER_END(Terrain)

void TerrainInstancing(inout float4 positionOS, inout float3 normalOS, inout float2 uv)
{
#ifdef UNITY_INSTANCING_ENABLED
    float4 instanceData = UNITY_ACCESS_INSTANCED_PROP(Terrain, _TerrainPatchInstanceData);
    float2 sampleCoords = (positionOS.xy + instanceData.xy) * instanceData.z;
    float height = UnpackHeightmap(_TerrainHeightmapTexture.Load(int3(sampleCoords, 0)));
    positionOS.xz = sampleCoords * _TerrainHeightmapScale.xz;
    positionOS.y = height * _TerrainHeightmapScale.y;
    normalOS = _TerrainNormalmapTexture.Load(int3(sampleCoords, 0)).rgb * 2 - 1;
    uv = sampleCoords * _TerrainHeightmapRecipSize.zw;
#endif
}

// 4-스플랫 알베도 블렌딩.
half3 SampleTerrainAlbedo(float2 uv)
{
    half4 ctrl = SAMPLE_TEXTURE2D(_Control, sampler_Control, uv * _Control_ST.xy + _Control_ST.zw);
    half3 a0 = SAMPLE_TEXTURE2D(_Splat0, sampler_Splat0, uv * _Splat0_ST.xy + _Splat0_ST.zw).rgb;
    half3 a1 = SAMPLE_TEXTURE2D(_Splat1, sampler_Splat1, uv * _Splat1_ST.xy + _Splat1_ST.zw).rgb;
    half3 a2 = SAMPLE_TEXTURE2D(_Splat2, sampler_Splat2, uv * _Splat2_ST.xy + _Splat2_ST.zw).rgb;
    half3 a3 = SAMPLE_TEXTURE2D(_Splat3, sampler_Splat3, uv * _Splat3_ST.xy + _Splat3_ST.zw).rgb;
    half wsum = max(ctrl.r + ctrl.g + ctrl.b + ctrl.a, 1e-4h);
    return (a0 * ctrl.r + a1 * ctrl.g + a2 * ctrl.b + a3 * ctrl.a) / wsum;
}

#endif // SCENETOON_TERRAIN_INPUT_INCLUDED
