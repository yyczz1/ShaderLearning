Shader "ElliotCustom/10Distort"
{
    Properties
    {
        _DistortTex("DistortTex",2D) = "white"{}
        _DistortValue("SpeedX(X) SpeedY(Y) Distort(Z)",Vector) = (0,0,0.1,0)
    }
    SubShader
    {
        Tags {"Queue" = "Transparent"}
        GrabPass {"_GrabTex"}
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
            };

            sampler2D _GrabTex;
            sampler2D _DistortTex;
            fixed4 _DistortTex_ST;
            fixed4 _DistortValue;

            v2f vert (appdata i)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.uv = TRANSFORM_TEX(i.uv,_DistortTex) + _DistortValue.xy * _Time.y;
                //o.screenPos = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // float2 screenUV = i.screenPos.xy / i.screenPos.w;
                float2 screenUV = i.pos.xy / _ScreenParams.xy;
                fixed4 distortTex = tex2D(_DistortTex,i.uv);
                fixed2 grabUV = lerp(screenUV,distortTex,_DistortValue.z);
                fixed4 grabTex = tex2D(_GrabTex,grabUV);
                return grabTex;
            }
            ENDCG
        }
    }
}
