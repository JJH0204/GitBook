Shader "com.blueigloo/SceneToon/Terrain"
{
    // 배경 지형(Unity Terrain) 툰 셰이더 — B2 초안 (Docs/10 §7.3, D-4).
    //   4-스플랫 블렌딩 + 공유 코어(밴드 음영 + GI 툰화)로 SceneToon 과 동일 셀 톤. 지형 Material 슬롯에 지정해 사용.
    //   draft: 5+ 레이어/홀/레이어별 노멀맵/메시 트라이플래너는 B4+. GI 는 SH 앰비언트(라이트맵은 B4).
    Properties
    {
        [HideInInspector] _Control ("Control (RGBA splat)", 2D) = "red" {}
        [HideInInspector] _Splat0 ("Layer 0", 2D) = "white" {}
        [HideInInspector] _Splat1 ("Layer 1", 2D) = "white" {}
        [HideInInspector] _Splat2 ("Layer 2", 2D) = "white" {}
        [HideInInspector] _Splat3 ("Layer 3", 2D) = "white" {}

        [Header(Shadow Bands)]
        _ShadowColor ("Shadow Color 1st", Color) = (0.72,0.74,0.82,1)
        _ShadowBorder ("Shadow Border 1st", Range(0,1)) = 0.5
        _ShadowBlur ("Shadow Blur 1st", Range(0,1)) = 0.1
        _Shadow2ndColor ("Shadow Color 2nd", Color) = (0.55,0.57,0.66,1)
        _Shadow2ndBorder ("Shadow Border 2nd", Range(0,1)) = 0.25
        _Shadow2ndBlur ("Shadow Blur 2nd", Range(0,1)) = 0.1
        _ShadowStrength ("Shadow Strength", Range(0,1)) = 1.0
        _ReceiveShadowStrength ("Receive Cast Shadow", Range(0,1)) = 1.0
        _ShadeFloor ("Shade Floor", Range(0,1)) = 0.2
        _AmbientStrength ("Ambient Strength", Range(0,2)) = 1.0

        [Header(GI Toonify)]
        [HDR] _GIShadeColor ("GI Shade Color", Color) = (0.6,0.62,0.72,1)
        _GIBandCount ("GI Band Count", Range(1,6)) = 3
        _GIBandSoftness ("GI Band Softness", Range(0,0.5)) = 0.1

        [Header(Additional Lights)]
        _AdditionalLightStrength ("Additional Light Strength", Range(0,2)) = 1.0
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry-100" "TerrainCompatible" = "True" }

        // ===================== Forward =====================
        Pass
        {
            Name "TerrainForward"
            Tags { "LightMode" = "UniversalForwardOnly" }
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fog
            // B8: SceneToon 과 같은 라이팅 범위 — 부가광(그림자·Forward+), 라이트 레이어, SSAO
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _CLUSTER_LIGHT_LOOP
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            // B12: 베이크 라이트맵(정적 지형 GI) + Draw Instanced
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../ShaderLibrary/SceneTerrainInput.hlsl"
            #include "../../ToonShared/ShaderLibrary/ToonAdditionalLights.hlsl"

            struct Attributes { float4 positionOS : POSITION; float3 normalOS : NORMAL; float2 uv : TEXCOORD0; UNITY_VERTEX_INPUT_INSTANCE_ID };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                half   fogFactor  : TEXCOORD3;
            #if defined(LIGHTMAP_ON)
                float2 lightmapUV : TEXCOORD4;   // 지형은 uv0 를 라이트맵 UV 로 쓴다
            #endif
            };

            Varyings vert(Attributes input)
            {
                Varyings o = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                TerrainInstancing(input.positionOS, input.normalOS, input.uv);
                VertexPositionInputs p = GetVertexPositionInputs(input.positionOS.xyz);
                o.positionCS = p.positionCS;
                o.positionWS = p.positionWS;
                o.normalWS   = TransformObjectToWorldNormal(input.normalOS);
                o.uv = input.uv;
                o.fogFactor = (half)ComputeFogFactor(p.positionCS.z);
            #if defined(LIGHTMAP_ON)
                o.lightmapUV = input.uv * unity_LightmapST.xy + unity_LightmapST.zw;
            #endif
                return o;
            }

            half4 frag(Varyings input) : SV_TARGET
            {
                half3 albedo = SampleTerrainAlbedo(input.uv);
                half3 N = normalize(input.normalWS);

                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                Light mainLight = GetMainLight(shadowCoord);
            #ifdef _LIGHT_LAYERS
                if (!IsMatchingLightLayer(mainLight.layerMask, GetMeshRenderingLayer())) mainLight.color = (half3)0.0h;
            #endif
                half3 L = mainLight.direction;
                AmbientOcclusionFactor ssao = GetScreenSpaceAmbientOcclusion(GetNormalizedScreenSpaceUV(input.positionCS));

                half lightVal = ToonRampU(ToonHalfLambert(dot(N, L)), 0.0h);   // ToonShared
                half rcvShadow = lerp(1.0h, mainLight.shadowAttenuation, _ReceiveShadowStrength);
                lightVal *= rcvShadow;

                half shadeMask;
                half3 shadedAlbedo = ToonShadeBands(
                    albedo, lightVal,
                    _ShadowBorder,    _ShadowBlur,    _ShadowColor.rgb,
                    _Shadow2ndBorder, _Shadow2ndBlur, _Shadow2ndColor.rgb,
                    _ShadowStrength, shadeMask);

                half3 shaded = shadedAlbedo * mainLight.color * ssao.directAmbientOcclusion;

                // GI 툰화 (draft: SH 앰비언트 — 라이트맵은 B4)
            #if defined(LIGHTMAP_ON)
                half3 sh = SampleLightmap(input.lightmapUV, N);   // B12: 베이크 GI
            #else
                half3 sh = SampleSH(N);
            #endif
                half giLum  = max(dot(sh, half3(0.2126h, 0.7152h, 0.0722h)), 1e-4h);
                half giBand = ToonPosterize(giLum, _GIBandCount, _GIBandSoftness);
                half3 toonGI = sh * (giBand / giLum) * lerp(_GIShadeColor.rgb, half3(1.0h,1.0h,1.0h), giBand);
                shaded += toonGI * albedo * _AmbientStrength * (1.0h - shadeMask) * ssao.indirectAmbientOcclusion;
                shaded = max(shaded, albedo * _ShadeFloor);

            #if defined(_ADDITIONAL_LIGHTS)
                shaded += ToonAdditionalLightsSum(input.positionWS, input.positionCS, N, albedo,
                                                  _ShadowBorder, max(_ShadowBlur, 1e-4h), half4(1, 1, 1, 1))
                          * _AdditionalLightStrength * ssao.directAmbientOcclusion;
            #endif

                shaded = MixFog(shaded, input.fogFactor);
                return half4(shaded, 1.0h);
            }
            ENDHLSL
        }

        // ===================== ShadowCaster =====================
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            ZWrite On ZTest LEqual ColorMask 0 Cull Back

            HLSLPROGRAM
            #pragma vertex ShadowVert
            #pragma fragment ShadowFrag
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "../ShaderLibrary/SceneTerrainInput.hlsl"

            float3 _LightDirection;
            float3 _LightPosition;

            struct Attributes { float4 positionOS : POSITION; float3 normalOS : NORMAL; UNITY_VERTEX_INPUT_INSTANCE_ID };
            struct Varyings   { float4 positionCS : SV_POSITION; };

            Varyings ShadowVert(Attributes input)
            {
                Varyings o = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                float2 uv = 0;
                TerrainInstancing(input.positionOS, input.normalOS, uv);
                float3 posWS = TransformObjectToWorld(input.positionOS.xyz);
                float3 nrmWS = TransformObjectToWorldNormal(input.normalOS);
            #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                float3 lightDir = normalize(_LightPosition - posWS);
            #else
                float3 lightDir = _LightDirection;
            #endif
                float4 cs = TransformWorldToHClip(ApplyShadowBias(posWS, nrmWS, lightDir));
            #if UNITY_REVERSED_Z
                cs.z = min(cs.z, UNITY_NEAR_CLIP_VALUE);
            #else
                cs.z = max(cs.z, UNITY_NEAR_CLIP_VALUE);
            #endif
                o.positionCS = cs;
                return o;
            }

            half4 ShadowFrag(Varyings input) : SV_TARGET { return 0; }
            ENDHLSL
        }

        // ===================== DepthOnly =====================
        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }
            ZWrite On ColorMask R Cull Back

            HLSLPROGRAM
            #pragma vertex DepthVert
            #pragma fragment DepthFrag
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "../ShaderLibrary/SceneTerrainInput.hlsl"

            struct Attributes { float4 positionOS : POSITION; float3 normalOS : NORMAL; UNITY_VERTEX_INPUT_INSTANCE_ID };
            struct Varyings   { float4 positionCS : SV_POSITION; };

            Varyings DepthVert(Attributes input)
            {
                Varyings o = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                float2 uv = 0;
                TerrainInstancing(input.positionOS, input.normalOS, uv);
                o.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return o;
            }
            half4 DepthFrag(Varyings input) : SV_TARGET { return 0; }
            ENDHLSL
        }

        // ===================== DepthNormals (스크린스페이스 아웃라인 참여) =====================
        Pass
        {
            Name "DepthNormals"
            Tags { "LightMode" = "DepthNormals" }
            ZWrite On Cull Back

            HLSLPROGRAM
            #pragma vertex DepthNormalsVert
            #pragma fragment DepthNormalsFrag
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "../ShaderLibrary/SceneTerrainInput.hlsl"

            struct Attributes { float4 positionOS : POSITION; float3 normalOS : NORMAL; UNITY_VERTEX_INPUT_INSTANCE_ID };
            struct Varyings   { float4 positionCS : SV_POSITION; float3 normalWS : TEXCOORD0; };

            Varyings DepthNormalsVert(Attributes input)
            {
                Varyings o = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                float2 uv = 0;
                TerrainInstancing(input.positionOS, input.normalOS, uv);
                o.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                o.normalWS = TransformObjectToWorldNormal(input.normalOS);
                return o;
            }
            half4 DepthNormalsFrag(Varyings input) : SV_TARGET
            {
                return half4(normalize(input.normalWS), 0.0h);
            }
            ENDHLSL
        }

        // ===================== Meta (B12: 라이트맵 베이크용 알베도) =====================
        Pass
        {
            Name "Meta"
            Tags { "LightMode" = "Meta" }
            Cull Off

            HLSLPROGRAM
            #pragma vertex TerrainMetaVert
            #pragma fragment TerrainMetaFrag
            #pragma shader_feature EDITOR_VISUALIZATION
            #pragma multi_compile_instancing
            #pragma instancing_options assumeuniformscaling nomatrices nolightprobe nolightmap
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
            #include "../ShaderLibrary/SceneTerrainInput.hlsl"

            struct Attributes { float4 positionOS : POSITION; float3 normalOS : NORMAL; float2 uv0 : TEXCOORD0; UNITY_VERTEX_INPUT_INSTANCE_ID };
            struct Varyings   { float4 positionCS : SV_POSITION; float2 uv : TEXCOORD0; };

            Varyings TerrainMetaVert(Attributes input)
            {
                Varyings o = (Varyings)0;
                UNITY_SETUP_INSTANCE_ID(input);
                TerrainInstancing(input.positionOS, input.normalOS, input.uv0);
                // 지형은 uv0 를 라이트맵·실시간 GI UV 로 쓴다(URP TerrainLit 과 같음).
                o.positionCS = UnityMetaVertexPosition(input.positionOS.xyz, input.uv0, input.uv0);
                o.uv = input.uv0;
                return o;
            }

            half4 TerrainMetaFrag(Varyings input) : SV_TARGET
            {
                MetaInput meta = (MetaInput)0;
                meta.Albedo = SampleTerrainAlbedo(input.uv);
                return UnityMetaFragment(meta);
            }
            ENDHLSL
        }
    }

    // B12: 지형은 원거리(basemap)와 라이트맵 베이크에 BaseMapShader 를 쓴다. 지정이 없으면 베이커가 이 지형을
    //   "머티리얼 없는 인스턴스"로 보고 라이트맵 입력에서 뺐다. 같은 셰이더(Meta 패스 포함)를 쓰게 한다.
    Dependency "BaseMapShader" = "com.blueigloo/SceneToon/Terrain"

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
