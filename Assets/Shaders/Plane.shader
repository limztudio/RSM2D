Shader "RSM/Plane"{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
        _SampleMaxDist("SampleMaxDist", Float) = 0.03
    }
    SubShader{
        Tags {
            "RenderType" = "Opaque"
        }

        Lighting Off
        Blend Off
        Cull Back
        ZWrite On

        Pass{
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata{
                float4 vertex : POSITION;

                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct v2f{
                float4 vertex : SV_POSITION;

                float4 wldPosXY_texUV : TEXCOORD0;
                float3 shdXZW : TEXCOORD1;
                
            };
            struct f2o{
                fixed4 color : SV_Target0;
            };

            uniform int _SampleCount;
            uniform StructuredBuffer<float> _SampleTerm : register(t1);

            uniform float4x4 _TransformShadow;
            uniform sampler1D _ShadowComponent0;
            uniform sampler1D _ShadowComponent1;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _SampleMaxDist;

            v2f vert(appdata input){
                v2f output;

                output.vertex = UnityObjectToClipPos(input.vertex);

                output.wldPosXY_texUV.xy = mul(unity_ObjectToWorld, input.vertex).xy;
                output.wldPosXY_texUV.zw = TRANSFORM_TEX(input.uv, _MainTex);

                output.shdXZW.xyz = mul(_TransformShadow, input.vertex).xzw;

                return output;
            }
            f2o frag(v2f input){
                f2o output;

                float2 texUV = input.wldPosXY_texUV.zw;

                float2 worldSpacePosXY = input.wldPosXY_texUV.xy;

                float2 shadowSpacePosXZ = input.shdXZW.xy / input.shdXZW.z;
                shadowSpacePosXZ.x = shadowSpacePosXZ.x * 0.5f + 0.5f;

                float4 shadowComponent0 = tex1D(_ShadowComponent0, shadowSpacePosXZ.x);

                float curShadowDepth = saturate(shadowSpacePosXZ.y);
                float cmpShadowDepth = shadowComponent0.z;

                float3 irradiance = float3(0.f, 0.f, 0.f);
                for(int i = 0; i < _SampleCount; ++i){
                    float rand = _SampleTerm[i];
                    float nearbyShadowSpacePosX = shadowSpacePosXZ.x + (rand * _SampleMaxDist);

                    float4 nearbyShadowComponent0 = tex1D(_ShadowComponent0, nearbyShadowSpacePosX);
                    float4 nearbyShadowComponent1 = tex1D(_ShadowComponent1, nearbyShadowSpacePosX);

                    float2 nearbyWorldSpacePosXY = nearbyShadowComponent0.xy;
                    float2 nearbyWorldSpaceNormalXY = float2(nearbyShadowComponent0.w, nearbyShadowComponent1.w);
                    float3 nearbyFlux = nearbyShadowComponent1.xyz;

                    float2 diffPos = worldSpacePosXY - nearbyWorldSpacePosXY;
                    //diffPos = normalize(diffPos);
                    float dividor = dot(diffPos, diffPos);
                    dividor *= dividor;

                    float3 radiance = max(0.f, dot(nearbyWorldSpaceNormalXY, diffPos));
                    radiance /= dividor;
                    radiance *= nearbyFlux;

                    radiance *= rand;
                    radiance *= rand;

                    irradiance += radiance;
                }

                output.color = tex2D(_MainTex, texUV);

                if(curShadowDepth < cmpShadowDepth)
                    output.color.rgb *= 0.5f;

                output.color.rgb = saturate(output.color.rgb + irradiance);

                return output;
            }

            ENDCG
        }
    }
}
