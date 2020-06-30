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

                float2 uv : TEXCOORD0;
            };
            struct v2f{
                float4 vertex : SV_POSITION;

                float2 uv : TEXCOORD0;
                float4 pos : TEXCOORD1;
            };
            struct f2s{
                fixed4 color : SV_Target0;
            };

            float4x4 _TransformShadow;
            sampler1D _ShadowMap0;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata input){
                v2f output;

                output.vertex = UnityObjectToClipPos(input.vertex);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);

                output.pos = mul(_TransformShadow, input.vertex);

                return output;
            }
            f2s frag(v2f input){
                f2s output;

                float3 shadowSpacePos = input.pos.xyz / input.pos.w;

                float shadowU = shadowSpacePos.x * 0.5f + 0.5f;

                float4 shadowMap0 = tex1D(_ShadowMap0, shadowU);

                float curShadowDepth = saturate(shadowSpacePos.z);
                float cmpShadowDepth = shadowMap0.z;

                output.color = tex2D(_MainTex, input.uv);

                if(curShadowDepth < cmpShadowDepth)
                    output.color.rgb *= abs(cmpShadowDepth - curShadowDepth);

                return output;
            }

            ENDCG
        }
    }
}
