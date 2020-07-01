Shader "RSM/Plane"{
    Properties{
        _MainTex("Texture", 2D) = "white" {}
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

                float4 wldPosXZ_wldNorXZ : TEXCOORD0;
                float3 shdXZW : TEXCOORD1;
                float2 texUV : TEXCOORD2;
                
            };
            struct f2o{
                fixed4 color : SV_Target0;
            };

            float4x4 _TransformShadow;
            sampler1D _ShadowMap0;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata input){
                v2f output;

                output.vertex = UnityObjectToClipPos(input.vertex);

                output.wldPosXZ_wldNorXZ.xy = mul(unity_ObjectToWorld, input.vertex).xz;
                output.wldPosXZ_wldNorXZ.zw = normalize(mul((float3x3)unity_ObjectToWorld, input.normal).xz);

                output.shdXZW.xyz = mul(_TransformShadow, input.vertex).xzw;

                output.texUV.xy = TRANSFORM_TEX(input.uv, _MainTex);

                return output;
            }
            f2o frag(v2f input){
                f2o output;

                float2 texUV = input.texUV;

                float2 worldSpacePosXZ = input.wldPosXZ_wldNorXZ.xy;
                float2 worldSpaceNormalXZ = input.wldPosXZ_wldNorXZ.zw;

                float2 shadowSpacePosXZ = input.shdXZW.xy / input.shdXZW.z;
                shadowSpacePosXZ.x = shadowSpacePosXZ.x * 0.5f + 0.5f;

                float4 shadowMap0 = tex1D(_ShadowMap0, shadowSpacePosXZ.x);

                float curShadowDepth = saturate(shadowSpacePosXZ.y);
                float cmpShadowDepth = shadowMap0.z;

                output.color = tex2D(_MainTex, texUV);

                if(curShadowDepth < cmpShadowDepth)
                    output.color.rgb *= abs(cmpShadowDepth - curShadowDepth);

                return output;
            }

            ENDCG
        }
    }
}
