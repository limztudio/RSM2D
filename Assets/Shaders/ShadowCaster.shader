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

                float4 wldPosXY_depthZW : TEXCOORD0;
                float4 wldNorXY_texUV : TEXCOORD1;
            };
            struct f2o{
                float4 wldPosXY_depth_wldNorX : SV_Target0;
                float4 fluxRGB_wldNorY : SV_Target1;
            };

            uniform float4 _LightColor;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata input){
                v2f output;

                output.vertex = UnityObjectToClipPos(input.vertex);

                output.wldPosXY_depthZW.xy = mul(unity_ObjectToWorld, input.vertex).xy;
                output.wldPosXY_depthZW.zw = output.vertex.zw;

                output.wldNorXY_texUV.xy = normalize(mul((float3x3)unity_ObjectToWorld, input.normal).xy);
                output.wldNorXY_texUV.zw = TRANSFORM_TEX(input.uv, _MainTex);

                return output;
            }
            f2o frag(v2f input){
                f2o output;

                float2 texUV = input.wldNorXY_texUV.zw;

                float2 worldSpacePosXY = input.wldPosXY_depthZW.xy;
                float2 worldSpaceNormalXY = normalize(input.wldNorXY_texUV.xy);
                float shadowSpaceDepth = input.wldPosXY_depthZW.z / input.wldPosXY_depthZW.w;

                output.wldPosXY_depth_wldNorX.xy = worldSpacePosXY;
                output.wldPosXY_depth_wldNorX.z = shadowSpaceDepth;

                output.wldPosXY_depth_wldNorX.w = worldSpaceNormalXY.x;
                output.fluxRGB_wldNorY.w = worldSpaceNormalXY.y;

                // flux for directional light will be constant color(guess the directional light is uniform parallel light)
                output.fluxRGB_wldNorY.xyz = tex2D(_MainTex, texUV).rgb;
                output.fluxRGB_wldNorY.xyz *= _LightColor.rgb;

                return output;
            }

            ENDCG
        }
    }
}
