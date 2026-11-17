Shader "com.blueigloo/CharacterToon/Character Unlit"
{
    // ===========================================================================================
    // CharacterToon 의 Unlit(무광) 변형. 같은 CharacterToon/Character 머티리얼에서 "셰이더만 교체"하면
    // Lit ↔ Unlit 전환이 된다 (프로퍼티/프리셋 값 유지).
    //   - 핵심: ToonInput.hlsl 을 그대로 include 하여 UnityPerMaterial CBUFFER 레이아웃이 Lit과 100% 동일.
    //     => 머티리얼의 Shader 드롭다운만 바꿔도 모든 값이 보존되고 SRP Batcher 규율도 유지.
    //   - 같은 ShaderGUI 재사용. (FindProperty(..,false) 라 언릿에 안 쓰는 프로퍼티는 조용히 스킵)
    //
    // Lit과의 차이(ForwardToon 패스):
    //   - 빛 방향(NdotL)에 의존하는 항목 전부 제거: Ramp/파라메트릭 그림자 밴드, Face SDF,
    //     부가광 셀셰이딩, PBR 툰 스페큘러, Skin SSS, Angel Ring, 받는 캐스트 그림자.
    //   - 유지(빛과 무관, 뷰/노멀 기반): Base, Normal map, MatCap×2, Rim(프레넬), Emission,
    //     Eye parallax, Stencil 영역 마스크, 거리 품질 페이드(MatCap 가산항).
    //   - 즉 "알베도 + 뷰 기반 스타일라이즈"를 평면 출력. 텍스처에 음영이 그려진 캐릭터/이펙트용.
    //
    // Outline / ShadowCaster / DepthOnly / DepthNormals 는 라이팅을 하지 않으므로 Lit 패스를 UsePass 로 그대로 쓴다.
    // ===========================================================================================
    Properties
    {
        [Header(Surface)]
        [Enum(Opaque,0,Transparent,1)] _Surface ("Rendering Mode", Float) = 0
        [HideInInspector] _SrcBlend ("__src", Float) = 1
        [HideInInspector] _DstBlend ("__dst", Float) = 0
        [HideInInspector] _ZWrite ("__zw", Float) = 1
        // 렌더 면(Lit과 동일). Lit↔Unlit 전환 시 양면 설정이 유지되도록 같은 프로퍼티를 쓴다.
        [Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull (Render Face)", Float) = 2

        [Header(Base)]
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
        // C3: 알파 클립(헤어 카드·속눈썹). 색·깊이·노멀·그림자·외곽선 패스가 같은 기준(BaseMap.a × BaseColor.a)으로 버린다.
        [Toggle(_ALPHATEST_ON)] _AlphaClip ("Alpha Clipping", Float) = 0
        _Cutoff ("Alpha Cutoff", Range(0,1)) = 0.5

        [Header(Normal)]
        [Toggle(_USE_NORMALMAP)] _UseNormalMap ("Use Normal Map", Float) = 0
        [Normal] _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Range(0,2)) = 1.0

        // ILM (언릿에서는 MatCap 마스크 베이스로만 사용 — R 채널)
        _ILMMap("ILM Map (RGBA)", 2D) = "black" {}
        [Toggle(_USE_ILM)] _UseILM ("Use ILM Map", Float) = 0

        [Header(Part)]
        [KeywordEnum(None, Face, Hair, Skin, Cloth)] _Part ("Part Type", Float) = 0

        [Header(Rim)]
        [Toggle(_USE_RIM)] _UseRim ("Use Rim Light", Float) = 0
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimThreshold("Rim Threshold", Range(0,1)) = 0.6
        _RimSoftness("Rim Softness", Range(0,0.5)) = 0.05
        _RimIntensity("Rim Intensity", Range(0,4)) = 1.0
        _RimInteractionBoost("Rim Interaction Boost", Range(1,4)) = 1.0

        // ── Outline (lilToon 외곽선 방식 충실 이식 — Lit과 동일) ──
        [Header(Outline)]
        [Toggle(_USE_OUTLINE)] _UseOutline ("Use Outline", Float) = 1
        [HDR] _OutlineColor("Outline Color", Color) = (0,0,0,1)
        _OutlineMap("Outline Tex", 2D) = "white" {}
        _OutlineWidth("Outline Width", Range(0,1)) = 0.08
        // PLAN-19: 폭 결정 공간. World=레거시(월드 단위) / Screen=픽셀 고정. Lit과 동일.
        [Enum(World,0,Screen,1)] _OutlineWidthMode("Outline Width Mode", Float) = 0
        _OutlineWidthPixels("Outline Width (px)", Range(0,10)) = 1.5
        _OutlineMinPixels("Min Width (px)", Range(0,4)) = 1.0
        _OutlineMask("Outline Width Mask (R)", 2D) = "white" {}
        _OutlineFixWidth("Outline Fix Width (near cam)", Range(0,1)) = 0.5
        [Enum(Off,0,VertexColor R,1,VertexColor A,2)] _OutlineVertexColorWidth("Vertex Color Width", Float) = 0
        _OutlineDepthOffset("Outline Z Bias", Float) = 0.0
        _OutlineDistanceFade("Outline Distance Fade", Range(0,1)) = 0.0
        _OutlineFadeStart("Outline Fade Start Dist", Range(0.1,50)) = 5.0

        [Header(MatCap)]
        [Toggle(_USE_MATCAP)] _UseMatCap ("Use MatCap", Float) = 0
        _MatCap("MatCap", 2D) = "black" {}
        _MatCapStrength("MatCap Strength", Range(0,4)) = 1.0
        [HDR] _MatCapColor("MatCap Color", Color) = (1,1,1,1)
        _MatCapBlur("MatCap Blur", Range(0,1)) = 0.0
        _MatCapNormalStrength("MatCap Normal Influence", Range(0,1)) = 1.0
        [ToggleUI] _UseMatCapMask ("Use Separate MatCap Mask", Float) = 0
        _MatCapMask("MatCap Mask (R)", 2D) = "white" {}
        [Toggle(_USE_MATCAP2)] _UseMatCap2 ("Use Second MatCap", Float) = 0
        _MatCap2("Second MatCap", 2D) = "black" {}
        _MatCap2Strength("Second MatCap Strength", Range(0,4)) = 1.0
        [HDR] _MatCap2Color("Second MatCap Color", Color) = (1,1,1,1)
        _MatCap2Blur("Second MatCap Blur", Range(0,1)) = 0.0
        [Enum(Add,0,Multiply,1)] _MatCap2Blend("Second MatCap Blend", Float) = 0
        [ToggleUI] _UseMatCap2Mask ("Use Second MatCap Mask", Float) = 0
        _MatCap2Mask("Second MatCap Mask (R)", 2D) = "white" {}

        [Header(Eyes)]
        [Toggle(_USE_EYE_PARALLAX)] _UseEyeParallax ("Use Eye Parallax", Float) = 0
        _EyeMap("Eye Overlay (RGB=detail, A=mask)", 2D) = "black" {}
        _EyeParallaxStrength("Eye Parallax", Range(0,0.2)) = 0.03
        _EyeHighlightStrength("Eye Overlay Strength", Range(0,4)) = 1.0

        [Header(Emission)]
        _EmissionMap("Emission Map", 2D) = "black" {}
        [HDR] _EmissionColor("Emission Color", Color) = (0,0,0,1)
        [Toggle(_USE_EMISSION)] _UseEmission ("Use Emission", Float) = 0

        [Header(Stencil)]
        [IntRange] _StencilRef("Stencil Ref", Range(0,255)) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp("Stencil Comp", Float) = 8
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilPass("Stencil Pass Op", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTestMode("ZTest", Float) = 4
        [Toggle(_USE_STENCIL_MASK)] _UseStencilMask ("Use Stencil Mask", Float) = 0
        _StencilMask("Stencil Mask (R)", 2D) = "white" {}
        _StencilMaskCutoff("Stencil Mask Cutoff", Range(0,1)) = 0.5

        [Header(Quality)]
        [Toggle(_USE_QUALITY_FADE)] _UseQualityFade ("Use Distance Quality Fade", Float) = 0
        _QualityFadeStart("Quality Fade Start Dist", Range(0,100)) = 15.0
        _QualityFadeEnd("Quality Fade End Dist", Range(0,200)) = 40.0
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" "Queue" = "Geometry" }

        // =========================================================
        // ForwardToon (Unlit) — 알베도 + 뷰/노멀 기반 스타일라이즈만. 빛 방향 무관.
        // =========================================================
        Pass
        {
            Name "ForwardToon"
            Tags { "LightMode" = "UniversalForwardOnly" }

            Cull [_Cull]
            Blend [_SrcBlend] [_DstBlend]   // Opaque=One,Zero / Transparent=SrcAlpha,OneMinusSrcAlpha
            ZWrite [_ZWrite]
            ZTest [_ZTestMode]
            Stencil { Ref [_StencilRef] Comp [_StencilComp] Pass [_StencilPass] }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // 언릿: 라이트/그림자 multi_compile 불필요 (빛을 읽지 않음). 변형 수 최소화.
            #pragma shader_feature_local _ _USE_NORMALMAP
            #pragma shader_feature_local _ _USE_ILM
            #pragma shader_feature_local _ _USE_RIM
            #pragma shader_feature_local _ _USE_MATCAP
            #pragma shader_feature_local _ _USE_MATCAP2
            #pragma shader_feature_local _ _USE_EYE_PARALLAX
            #pragma shader_feature_local _ _USE_EMISSION
            #pragma shader_feature_local _ _USE_STENCIL_MASK
            #pragma shader_feature_local_fragment _ _ALPHATEST_ON
            #pragma shader_feature_local _ _USE_QUALITY_FADE
            #pragma multi_compile_fog

            #include "../ShaderLibrary/ToonInput.hlsl"
            #include "../ShaderLibrary/ToonLighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
                float3 normalWS   : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                half   fogFactor  : TEXCOORD3;
            };

            Varyings vert(Attributes input)
            {
                Varyings o = (Varyings)0;
                VertexPositionInputs p = GetVertexPositionInputs(input.positionOS.xyz);
                VertexNormalInputs   n = GetVertexNormalInputs(input.normalOS);
                o.positionCS = p.positionCS;
                o.positionWS = p.positionWS;
                o.normalWS   = n.normalWS;
                o.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                o.fogFactor = (half)ComputeFogFactor(p.positionCS.z);
                return o;
            }

            half4 frag(Varyings input, FRONT_FACE_TYPE faceSign : FRONT_FACE_SEMANTIC) : SV_TARGET
            {
                // 양면·뒷면 렌더 시 뒷면 노멀 반전(Lit과 동일) → MatCap·Rim 정합. 앞면만이면 ×1.
                input.normalWS *= IS_FRONT_VFACE(faceSign, 1.0, -1.0);

                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;

                ClipToonSurface(input.uv);   // 스텐실 영역 마스크(Lit과 같은 함수). 기본 white=no-op.

                // 노멀(MatCap/Rim 구동용). 노멀맵 키워드 off → 보간 노멀 그대로.
                half3 N = normalize(input.normalWS);
            #if defined(_USE_NORMALMAP)
                half3 normalTS = UnpackNormalScale(SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, input.uv), _BumpScale);
                N = ApplyNormalMapDerivative(N, input.positionWS, input.uv, normalTS);
            #endif
                half3 V = normalize(GetWorldSpaceViewDir(input.positionWS));

                // ILM (있으면 MatCap 마스크 베이스로만 사용). 없으면 중립 폴백.
                half4 ilm = half4(0.0h, 0.5h, 0.5h, 0.0h);
            #if defined(_USE_ILM)
                ilm = SAMPLE_TEXTURE2D(_ILMMap, sampler_ILMMap, input.uv);
            #endif

                // 거리 품질 페이드 계수(1=근거리, 0=원거리). off면 상수 1(no-op).
                half hqAmount = 1.0h;
            #if defined(_USE_QUALITY_FADE)
                float3 objPosWS = float3(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23);
                float distToCam = distance(objPosWS, _WorldSpaceCameraPos);
                hqAmount = saturate(1.0h - (half)((distToCam - _QualityFadeStart) / max(_QualityFadeEnd - _QualityFadeStart, 1e-3)));
            #endif

                // === Unlit: 알베도를 그대로 출력값으로 ===
                half3 shaded = baseColor.rgb;

                // Rim (프레넬 — 뷰/노멀 기반, 빛 무관). 언릿 기본 off.
            #if defined(_USE_RIM)
                half fresnel = 1.0h - saturate(dot(N, V));
                half rim = smoothstep(_RimThreshold, _RimThreshold + max(_RimSoftness, 1e-4h), fresnel);   // C4: 0폭 → 0/0 방지
                shaded += rim * _RimColor.rgb * _RimIntensity * _RimInteractionBoost;
            #endif

                // MatCap (뷰공간 가짜광 — 씬 라이트 무관). 가산형.
            #if defined(_USE_MATCAP)
                if (hqAmount > 0.0h)
                {
                    half3 mcN = SafeNormalize(lerp((half3)normalize(input.normalWS), N, _MatCapNormalStrength));
                    float3 normalVS = mul((float3x3)UNITY_MATRIX_V, mcN);
                    float2 matcapUV = normalVS.xy * 0.5 + 0.5;
                    // 블러: 밉 바이어스로 소프트닝(분기 quad-uniform → BIAS 안전). 베이스 컬러: 틴트 곱.
                    half3 matcap = SAMPLE_TEXTURE2D_BIAS(_MatCap, sampler_MatCap, matcapUV, _MatCapBlur * CHAR_MATCAP_BLUR_MAX).rgb * _MatCapColor.rgb;
                    half matcapMask = 1.0h;
                #if defined(_USE_ILM)
                    matcapMask = ilm.r;
                #endif
                    if (_UseMatCapMask > 0.5h)   // C7: 별도 마스크는 토글이 켜졌을 때만 샘플(머티리얼 상수 분기 → 꺼지면 페치 생략)
                        matcapMask = SAMPLE_TEXTURE2D(_MatCapMask, sampler_MatCapMask, input.uv).r;
                    shaded += matcap * matcapMask * _MatCapStrength * hqAmount;
                }
            #endif

                // 두 번째 MatCap — Add/Multiply 선택 (Lit과 동일 규칙).
            #if defined(_USE_MATCAP2)
                if (hqAmount > 0.0h)
                {
                    half3 mcN2 = SafeNormalize(lerp((half3)normalize(input.normalWS), N, _MatCapNormalStrength));
                    float3 normalVS2 = mul((float3x3)UNITY_MATRIX_V, mcN2);
                    float2 matcap2UV = normalVS2.xy * 0.5 + 0.5;
                    half3 matcap2 = SAMPLE_TEXTURE2D_BIAS(_MatCap2, sampler_MatCap2, matcap2UV, _MatCap2Blur * CHAR_MATCAP_BLUR_MAX).rgb * _MatCap2Color.rgb;
                    half matcap2Mask = 1.0h;
                #if defined(_USE_ILM)
                    matcap2Mask = ilm.r;
                #endif
                    if (_UseMatCap2Mask > 0.5h)   // C7: 별도 마스크는 토글이 켜졌을 때만 샘플(머티리얼 상수 분기 → 꺼지면 페치 생략)
                        matcap2Mask = SAMPLE_TEXTURE2D(_MatCap2Mask, sampler_MatCap2Mask, input.uv).r;
                    if (_MatCap2Blend < 0.5h)
                        shaded += matcap2 * matcap2Mask * _MatCap2Strength * hqAmount;
                    else
                        shaded = lerp(shaded, shaded * matcap2, saturate(matcap2Mask * _MatCap2Strength) * hqAmount);
                }
            #endif

                // Eye parallax 오버레이 (시선 기반, 빛 무관). 기본 black=가산 0.
            #if defined(_USE_EYE_PARALLAX)
                half3 eyeT = (half3)GetUVTangentWS(input.positionWS, input.uv);
                half3 eyeB = cross(N, eyeT);
                half2 viewTS = half2(dot(V, eyeT), dot(V, eyeB));
                float2 eyeUV = input.uv + viewTS * _EyeParallaxStrength;
                half4 eyeSample = SAMPLE_TEXTURE2D(_EyeMap, sampler_EyeMap, eyeUV);
                shaded += eyeSample.rgb * eyeSample.a * _EyeHighlightStrength;
            #endif

                // Emission. 기본 (0,0,0) → no-op.
            #if defined(_USE_EMISSION)
                half3 emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, input.uv).rgb * _EmissionColor.rgb;
                shaded += emission;
            #endif

                shaded = MixFog(shaded, input.fogFactor);
                return half4(shaded, baseColor.a);
            }
            ENDHLSL
        }

        // Lit 의 비조명 패스를 그대로 쓴다. 복붙해 두었을 땐 Lit 에만 들어간 수정(Render Face, 뒷면 노멀 반전,
        // 스텐실 마스크 clip)이 여기서 빠졌다. 같은 ToonInput CBUFFER 라 SRP Batcher 규율도 그대로다.
        UsePass "com.blueigloo/CharacterToon/Character/OUTLINE"
        UsePass "com.blueigloo/CharacterToon/Character/SHADOWCASTER"
        UsePass "com.blueigloo/CharacterToon/Character/DEPTHONLY"
        UsePass "com.blueigloo/CharacterToon/Character/DEPTHNORMALS"
        UsePass "com.blueigloo/CharacterToon/Character/MOTIONVECTORS"
    }

    CustomEditor "CharacterToon.Editor.CharacterToonShaderGUI"
    FallBack "Universal Render Pipeline/Unlit"
}
