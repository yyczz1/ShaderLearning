Shader "ElliotCustom/7Texture"
{
    Properties
    {
        [Header(Base)]
        [NoScaleOffset]_MainTex ("MainTexture",2D) = "white"{}
        _Color ("MainColor",Color) = (0,0,0,0)
        
        [Header(Dissolve)]
        [Toggle]_DissolveEnable ("DissolveEnable",int) = 0
        _DissolveTex ("DissolveTex",2D) = "white"{}
        _ClipValue ("ClipValue",Range(0,1)) = 0
		[NoScaleOffset]_RampTex ("RampTex(RGB)",2D) = "white"{}
    }

    SubShader
    {
        Pass
        {
            Name "DissolveTexture"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _DISSOLVEENABLE_ON
            
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            fixed4 _Color;

            sampler2D _DissolveTex;
            float4 _DissolveTex_ST;
            float _ClipValue;
			
			sampler _RampTex;

            struct appdata
            {
                float4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex) ;
                o.uv.xy = v.uv.xy ;
                o.uv.zw = v.uv.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
                // o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                return o;
                
            }

            float4 frag(v2f i):SV_TARGET
            {
                float4 finalColor;
                float4 texCol = tex2D(_MainTex,i.uv.xy);
                finalColor = texCol + _Color;

                #if _DISSOLVEENABLE_ON
                float4 dissolveCol = tex2D(_DissolveTex,i.uv.zw);
                clip(dissolveCol.r - _ClipValue);
				// fixed4 rampCol = tex2D(_RampTex,smoothstep(_ClipValue,_ClipValue+0.1,dissolveCol.r));
				float dissolveValue = saturate((dissolveCol.r-_ClipValue)/(0.1));
				float4 rampCol = tex1D(_RampTex,dissolveValue);
				finalColor += rampCol;
                #endif

                return finalColor;
            }

            ENDCG
        }
    }
}