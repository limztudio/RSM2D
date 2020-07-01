Shader "RSM/ShadowCaster"{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
    }
    SubShader{
        Tags{
            "Queue" = "Geometry"
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

                float4 wldPosXZ_depthZW : TEXCOORD0;
                float4 wldNorXZ_texUV : TEXCOORD1;
            };
            struct f2o{
                float4 wldPosXZ_depth_wldNorX : SV_Target0;
                float4 fluxRGB_wldNorZ : SV_Target1;
            };

            uniform float4 _LightColor;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata input){
                v2f output;

                output.vertex = UnityObjectToClipPos(input.vertex);

                output.wldPosXZ_depthZW.xy = mul(unity_ObjectToWorld, input.vertex).xz;
                output.wldPosXZ_depthZW.zw = output.vertex.zw;

                output.wldNorXZ_texUV.xy = normalize(mul((float3x3)unity_ObjectToWorld, input.normal).xz);
                output.wldNorXZ_texUV.zw = TRANSFORM_TEX(input.uv, _MainTex);

                return output;
            }
            f2o frag(v2f input){
                f2o output;

                float2 texUV = input.wldNorXZ_texUV.zw;

                float2 worldSpacePosXZ = input.wldPosXZ_depthZW.xy;
                float2 worldSpaceNormalXZ = input.wldNorXZ_texUV.xy;
                float shadowSpaceDepth = input.wldPosXZ_depthZW.z / input.wldPosXZ_depthZW.w;

                output.wldPosXZ_depth_wldNorX.xy = worldSpacePosXZ;
                output.wldPosXZ_depth_wldNorX.z = shadowSpaceDepth;

                output.wldPosXZ_depth_wldNorX.w = worldSpacePosXZ.x;
                output.fluxRGB_wldNorZ.w = worldSpacePosXZ.y;

                // flux for directional light will be constant color(guess the directional light is uniform parallel light)
                output.fluxRGB_wldNorZ.xyz = tex2D(_MainTex, texUV).rgb;
                //output.fluxRGB_wldNorZ.xyz *= _LightColor.rgb;

                return output;
            }

            ENDCG
        }
    }
}
