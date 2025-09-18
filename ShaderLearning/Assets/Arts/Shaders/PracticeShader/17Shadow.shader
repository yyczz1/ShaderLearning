Shader "ElliotCustom/17Shadow"
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
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _DISSOLVEENABLE_ON
            #pragma multi_compile DIRECTIONAL SHADOWS_SCREEN            
            #pragma multi_compile SHADOWS_SCREEN

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

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
                float3 worldPos : TEXCOORD1;
                UNITY_SHADOW_COORDS(2)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy;
                o.uv.zw = v.uv.xy * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                // o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                TRANSFER_SHADOW(o);
                return o;
            }

            float4 frag(v2f i):SV_TARGET
            {
                float4 finalColor;
                float4 texCol = tex2D(_MainTex, i.uv.xy);
                finalColor = texCol * _Color;

                #if _DISSOLVEENABLE_ON
                float4 dissolveCol = tex2D(_DissolveTex,i.uv.zw);
                clip(dissolveCol.r - _ClipValue);
				// fixed4 rampCol = tex2D(_RampTex,smoothstep(_ClipValue,_ClipValue+0.1,dissolveCol.r));
				float dissolveValue = saturate((dissolveCol.r-_ClipValue)/(0.1));
				float4 rampCol = tex1D(_RampTex,dissolveValue);
				finalColor += rampCol;
                #endif
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
                finalColor *= atten;
                return finalColor;
            }
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
            CGPROGRAM
            // Upgrade NOTE: excluded shader from DX11; has structs without semantics (struct v2f members worldPos)
            #pragma exclude_renderers d3d11
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _DISSOLVEENABLE_ON
            #pragma multi_compile_shadowcaster
            // #pragma multi_compile_fwdadd


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                half3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                V2F_SHADOW_CASTER;
            };

            sampler2D _DissolveTex;

            float4 _DissolveTex_ST;

            float _ClipValue;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv * _DissolveTex_ST.xy + _DissolveTex_ST.zw;
                    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // sample the texture
                #if _DISSOLVEENABLE_ON
                float4 dissolveCol = tex2D(_DissolveTex,i.uv);
                clip(dissolveCol.r - _ClipValue);
                #endif

                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
    }
}