Shader "RSM/Block"{
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
            };
            struct f2o{
                fixed4 color : SV_Target0;
            };

            SamplerState sampler_point_repeat;

            Texture2D _MainTex;
            float4 _MainTex_ST;

            v2f vert(appdata input){
                v2f output;

                output.vertex = UnityObjectToClipPos(input.vertex);
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);

                return output;
            }
            f2o frag(v2f input){
                f2o output;

                output.color = UNITY_SAMPLE_TEX2D_SAMPLER(_MainTex, _point_repeat, input.uv);

                return output;
            }

            ENDCG
        }
    }
}
