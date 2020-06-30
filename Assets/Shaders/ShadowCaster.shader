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
            };
            struct v2f{
                float4 vertex : SV_POSITION;

                float4 pos : TEXCOORD0;
            };
            struct f2s{
                float4 pos : SV_Target0;
            };

            v2f vert(appdata input){
                v2f output;

                output.vertex = UnityObjectToClipPos(input.vertex);
                output.pos = output.vertex;

                return output;
            }
            f2s frag(v2f input){
                f2s output;

                output.pos = input.pos / input.pos.w;

                return output;
            }

            ENDCG
        }
    }
}
