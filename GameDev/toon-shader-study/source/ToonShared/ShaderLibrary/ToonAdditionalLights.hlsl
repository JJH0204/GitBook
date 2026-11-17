#ifndef TOON_ADDITIONAL_LIGHTS_INCLUDED
#define TOON_ADDITIONAL_LIGHTS_INCLUDED

// 배경 셀 코어: 부가광(point/spot/추가 디렉셔널)을 셀 단계화해 합산한다. (ToonShared = 배경 전용, Docs/10 D-3)
// 식은 CharacterToon.shader 의 ShadeAdditionalToon 루프와 같다 — 한쪽을 바꾸면 다른 쪽도 맞출 것.
// 규약: CBUFFER 비참조, 인자 전달만. URP Lighting.hlsl 을 먼저 include 할 것(Light, GetAdditionalLight).
//
// 그림자: 3-인자 GetAdditionalLight 라야 _ADDITIONAL_LIGHT_SHADOWS 가 반영된다(2-인자는 감쇠 1 고정).
// Forward+: 추가 디렉셔널 광원은 클러스터에 들어가지 않으므로 LIGHT_LOOP 앞에서 따로 돈다(URP Lit 패턴).

half3 ToonAdditionalLightCel(Light light, half3 N, half3 albedo, half border, half blur)
{
#ifdef _LIGHT_LAYERS
    if (!IsMatchingLightLayer(light.layerMask, GetMeshRenderingLayer()))   // A7: 이 렌더러의 Rendering Layer 밖 광원
        return (half3)0.0h;
#endif
    half nl  = saturate(dot(N, light.direction) * 0.5h + 0.5h);   // half-Lambert
    half lit = smoothstep(border - blur, border + blur, nl);       // 메인과 같은 1차 밴드 경계로 셀 스텝
    return albedo * light.color * (light.distanceAttenuation * light.shadowAttenuation * lit);
}

// shadowMask: SAMPLE_SHADOWMASK 결과(베이크 그림자·프로브 오클루전). 없으면 half4(1,1,1,1).
half3 ToonAdditionalLightsSum(float3 positionWS, float4 positionCS, half3 N, half3 albedo, half border, half blur, half4 shadowMask)
{
    half3 sum = (half3)0.0h;
    InputData inputData = (InputData)0;   // LIGHT_LOOP_BEGIN(Forward+) 이 이 이름의 필드를 읽는다
    inputData.positionWS = positionWS;
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(positionCS);
#if USE_CLUSTER_LIGHT_LOOP
    for (uint di = 0u; di < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); di++)
        sum += ToonAdditionalLightCel(GetAdditionalLight(di, positionWS, shadowMask), N, albedo, border, blur);
#endif
    uint count = GetAdditionalLightsCount();
    LIGHT_LOOP_BEGIN(count)
        sum += ToonAdditionalLightCel(GetAdditionalLight(lightIndex, positionWS, shadowMask), N, albedo, border, blur);
    LIGHT_LOOP_END
    return sum;
}

#endif // TOON_ADDITIONAL_LIGHTS_INCLUDED
